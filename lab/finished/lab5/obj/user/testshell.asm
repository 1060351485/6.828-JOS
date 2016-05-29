
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
  800050:	e8 cf 1a 00 00       	call   801b24 <seek>
	seek(kfd, off);
  800055:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800059:	89 34 24             	mov    %esi,(%esp)
  80005c:	e8 c3 1a 00 00       	call   801b24 <seek>

	cprintf("shell produced incorrect output.\n");
  800061:	c7 04 24 e0 2d 80 00 	movl   $0x802de0,(%esp)
  800068:	e8 27 06 00 00       	call   800694 <cprintf>
	cprintf("expected:\n===\n");
  80006d:	c7 04 24 4b 2e 80 00 	movl   $0x802e4b,(%esp)
  800074:	e8 1b 06 00 00       	call   800694 <cprintf>
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800079:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  80007c:	eb 0c                	jmp    80008a <wrong+0x56>
		sys_cputs(buf, n);
  80007e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800082:	89 1c 24             	mov    %ebx,(%esp)
  800085:	e8 da 0e 00 00       	call   800f64 <sys_cputs>
	seek(rfd, off);
	seek(kfd, off);

	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  80008a:	c7 44 24 08 63 00 00 	movl   $0x63,0x8(%esp)
  800091:	00 
  800092:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800096:	89 34 24             	mov    %esi,(%esp)
  800099:	e8 20 19 00 00       	call   8019be <read>
  80009e:	85 c0                	test   %eax,%eax
  8000a0:	7f dc                	jg     80007e <wrong+0x4a>
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
  8000a2:	c7 04 24 5a 2e 80 00 	movl   $0x802e5a,(%esp)
  8000a9:	e8 e6 05 00 00       	call   800694 <cprintf>
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000ae:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  8000b1:	eb 0c                	jmp    8000bf <wrong+0x8b>
		sys_cputs(buf, n);
  8000b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b7:	89 1c 24             	mov    %ebx,(%esp)
  8000ba:	e8 a5 0e 00 00       	call   800f64 <sys_cputs>
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
  8000ce:	e8 eb 18 00 00       	call   8019be <read>
  8000d3:	85 c0                	test   %eax,%eax
  8000d5:	7f dc                	jg     8000b3 <wrong+0x7f>
		sys_cputs(buf, n);
	cprintf("===\n");
  8000d7:	c7 04 24 55 2e 80 00 	movl   $0x802e55,(%esp)
  8000de:	e8 b1 05 00 00       	call   800694 <cprintf>
	exit();
  8000e3:	e8 a0 04 00 00       	call   800588 <exit>
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
  800103:	e8 52 17 00 00       	call   80185a <close>
	close(1);
  800108:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80010f:	e8 46 17 00 00       	call   80185a <close>
	opencons();
  800114:	e8 c7 03 00 00       	call   8004e0 <opencons>
	opencons();
  800119:	e8 c2 03 00 00       	call   8004e0 <opencons>

	if ((rfd = open("testshell.sh", O_RDONLY)) < 0)
  80011e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800125:	00 
  800126:	c7 04 24 68 2e 80 00 	movl   $0x802e68,(%esp)
  80012d:	e8 62 1d 00 00       	call   801e94 <open>
  800132:	89 c3                	mov    %eax,%ebx
  800134:	85 c0                	test   %eax,%eax
  800136:	79 20                	jns    800158 <umain+0x65>
		panic("open testshell.sh: %e", rfd);
  800138:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80013c:	c7 44 24 08 75 2e 80 	movl   $0x802e75,0x8(%esp)
  800143:	00 
  800144:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
  80014b:	00 
  80014c:	c7 04 24 8b 2e 80 00 	movl   $0x802e8b,(%esp)
  800153:	e8 44 04 00 00       	call   80059c <_panic>
	if ((wfd = pipe(pfds)) < 0)
  800158:	8d 45 dc             	lea    -0x24(%ebp),%eax
  80015b:	89 04 24             	mov    %eax,(%esp)
  80015e:	e8 1e 26 00 00       	call   802781 <pipe>
  800163:	85 c0                	test   %eax,%eax
  800165:	79 20                	jns    800187 <umain+0x94>
		panic("pipe: %e", wfd);
  800167:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80016b:	c7 44 24 08 9c 2e 80 	movl   $0x802e9c,0x8(%esp)
  800172:	00 
  800173:	c7 44 24 04 15 00 00 	movl   $0x15,0x4(%esp)
  80017a:	00 
  80017b:	c7 04 24 8b 2e 80 00 	movl   $0x802e8b,(%esp)
  800182:	e8 15 04 00 00       	call   80059c <_panic>
	wfd = pfds[1];
  800187:	8b 75 e0             	mov    -0x20(%ebp),%esi

	cprintf("running sh -x < testshell.sh | cat\n");
  80018a:	c7 04 24 04 2e 80 00 	movl   $0x802e04,(%esp)
  800191:	e8 fe 04 00 00       	call   800694 <cprintf>
	if ((r = fork()) < 0)
  800196:	e8 10 12 00 00       	call   8013ab <fork>
  80019b:	85 c0                	test   %eax,%eax
  80019d:	79 20                	jns    8001bf <umain+0xcc>
		panic("fork: %e", r);
  80019f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001a3:	c7 44 24 08 a5 2e 80 	movl   $0x802ea5,0x8(%esp)
  8001aa:	00 
  8001ab:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  8001b2:	00 
  8001b3:	c7 04 24 8b 2e 80 00 	movl   $0x802e8b,(%esp)
  8001ba:	e8 dd 03 00 00       	call   80059c <_panic>
	if (r == 0) {
  8001bf:	85 c0                	test   %eax,%eax
  8001c1:	0f 85 9f 00 00 00    	jne    800266 <umain+0x173>
		dup(rfd, 0);
  8001c7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8001ce:	00 
  8001cf:	89 1c 24             	mov    %ebx,(%esp)
  8001d2:	e8 d4 16 00 00       	call   8018ab <dup>
		dup(wfd, 1);
  8001d7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8001de:	00 
  8001df:	89 34 24             	mov    %esi,(%esp)
  8001e2:	e8 c4 16 00 00       	call   8018ab <dup>
		close(rfd);
  8001e7:	89 1c 24             	mov    %ebx,(%esp)
  8001ea:	e8 6b 16 00 00       	call   80185a <close>
		close(wfd);
  8001ef:	89 34 24             	mov    %esi,(%esp)
  8001f2:	e8 63 16 00 00       	call   80185a <close>
		if ((r = spawnl("/sh", "sh", "-x", 0)) < 0)
  8001f7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001fe:	00 
  8001ff:	c7 44 24 08 ae 2e 80 	movl   $0x802eae,0x8(%esp)
  800206:	00 
  800207:	c7 44 24 04 72 2e 80 	movl   $0x802e72,0x4(%esp)
  80020e:	00 
  80020f:	c7 04 24 b1 2e 80 00 	movl   $0x802eb1,(%esp)
  800216:	e8 21 23 00 00       	call   80253c <spawnl>
  80021b:	89 c7                	mov    %eax,%edi
  80021d:	85 c0                	test   %eax,%eax
  80021f:	79 20                	jns    800241 <umain+0x14e>
			panic("spawn: %e", r);
  800221:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800225:	c7 44 24 08 b5 2e 80 	movl   $0x802eb5,0x8(%esp)
  80022c:	00 
  80022d:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  800234:	00 
  800235:	c7 04 24 8b 2e 80 00 	movl   $0x802e8b,(%esp)
  80023c:	e8 5b 03 00 00       	call   80059c <_panic>
		close(0);
  800241:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800248:	e8 0d 16 00 00       	call   80185a <close>
		close(1);
  80024d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800254:	e8 01 16 00 00       	call   80185a <close>
		wait(r);
  800259:	89 3c 24             	mov    %edi,(%esp)
  80025c:	e8 c3 26 00 00       	call   802924 <wait>
		exit();
  800261:	e8 22 03 00 00       	call   800588 <exit>
	}
	close(rfd);
  800266:	89 1c 24             	mov    %ebx,(%esp)
  800269:	e8 ec 15 00 00       	call   80185a <close>
	close(wfd);
  80026e:	89 34 24             	mov    %esi,(%esp)
  800271:	e8 e4 15 00 00       	call   80185a <close>

	rfd = pfds[0];
  800276:	8b 7d dc             	mov    -0x24(%ebp),%edi
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  800279:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800280:	00 
  800281:	c7 04 24 bf 2e 80 00 	movl   $0x802ebf,(%esp)
  800288:	e8 07 1c 00 00       	call   801e94 <open>
  80028d:	89 c6                	mov    %eax,%esi
  80028f:	85 c0                	test   %eax,%eax
  800291:	79 20                	jns    8002b3 <umain+0x1c0>
		panic("open testshell.key for reading: %e", kfd);
  800293:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800297:	c7 44 24 08 28 2e 80 	movl   $0x802e28,0x8(%esp)
  80029e:	00 
  80029f:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8002a6:	00 
  8002a7:	c7 04 24 8b 2e 80 00 	movl   $0x802e8b,(%esp)
  8002ae:	e8 e9 02 00 00       	call   80059c <_panic>
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
  8002d3:	e8 e6 16 00 00       	call   8019be <read>
  8002d8:	89 c3                	mov    %eax,%ebx
		n2 = read(kfd, &c2, 1);
  8002da:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8002e1:	00 
  8002e2:	8d 45 e6             	lea    -0x1a(%ebp),%eax
  8002e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e9:	89 34 24             	mov    %esi,(%esp)
  8002ec:	e8 cd 16 00 00       	call   8019be <read>
		if (n1 < 0)
  8002f1:	85 db                	test   %ebx,%ebx
  8002f3:	79 20                	jns    800315 <umain+0x222>
			panic("reading testshell.out: %e", n1);
  8002f5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002f9:	c7 44 24 08 cd 2e 80 	movl   $0x802ecd,0x8(%esp)
  800300:	00 
  800301:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  800308:	00 
  800309:	c7 04 24 8b 2e 80 00 	movl   $0x802e8b,(%esp)
  800310:	e8 87 02 00 00       	call   80059c <_panic>
		if (n2 < 0)
  800315:	85 c0                	test   %eax,%eax
  800317:	79 20                	jns    800339 <umain+0x246>
			panic("reading testshell.key: %e", n2);
  800319:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80031d:	c7 44 24 08 e7 2e 80 	movl   $0x802ee7,0x8(%esp)
  800324:	00 
  800325:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
  80032c:	00 
  80032d:	c7 04 24 8b 2e 80 00 	movl   $0x802e8b,(%esp)
  800334:	e8 63 02 00 00       	call   80059c <_panic>
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
  80037c:	c7 04 24 01 2f 80 00 	movl   $0x802f01,(%esp)
  800383:	e8 0c 03 00 00       	call   800694 <cprintf>
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
  8003a4:	c7 44 24 04 16 2f 80 	movl   $0x802f16,0x4(%esp)
  8003ab:	00 
  8003ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003af:	89 04 24             	mov    %eax,(%esp)
  8003b2:	e8 88 08 00 00       	call   800c3f <strcpy>
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
  8003f4:	e8 bf 09 00 00       	call   800db8 <memmove>
		sys_cputs(buf, m);
  8003f9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003fd:	89 3c 24             	mov    %edi,(%esp)
  800400:	e8 5f 0b 00 00       	call   800f64 <sys_cputs>
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
  800427:	e8 e6 0b 00 00       	call   801012 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80042c:	e8 51 0b 00 00       	call   800f82 <sys_cgetc>
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
  800474:	e8 eb 0a 00 00       	call   800f64 <sys_cputs>
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
  800497:	e8 22 15 00 00       	call   8019be <read>
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
  8004c4:	e8 59 12 00 00       	call   801722 <fd_lookup>
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
  8004ec:	e8 de 11 00 00       	call   8016cf <fd_alloc>
  8004f1:	85 c0                	test   %eax,%eax
  8004f3:	78 3c                	js     800531 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8004f5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8004fc:	00 
  8004fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800500:	89 44 24 04          	mov    %eax,0x4(%esp)
  800504:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80050b:	e8 21 0b 00 00       	call   801031 <sys_page_alloc>
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
  80052c:	e8 73 11 00 00       	call   8016a4 <fd2num>
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
  800542:	e8 ac 0a 00 00       	call   800ff3 <sys_getenvid>
  800547:	25 ff 03 00 00       	and    $0x3ff,%eax
  80054c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800553:	c1 e0 07             	shl    $0x7,%eax
  800556:	29 d0                	sub    %edx,%eax
  800558:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80055d:	a3 04 50 80 00       	mov    %eax,0x805004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800562:	85 f6                	test   %esi,%esi
  800564:	7e 07                	jle    80056d <libmain+0x39>
		binaryname = argv[0];
  800566:	8b 03                	mov    (%ebx),%eax
  800568:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  80056d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800571:	89 34 24             	mov    %esi,(%esp)
  800574:	e8 7a fb ff ff       	call   8000f3 <umain>

	// exit gracefully
	exit();
  800579:	e8 0a 00 00 00       	call   800588 <exit>
}
  80057e:	83 c4 10             	add    $0x10,%esp
  800581:	5b                   	pop    %ebx
  800582:	5e                   	pop    %esi
  800583:	5d                   	pop    %ebp
  800584:	c3                   	ret    
  800585:	00 00                	add    %al,(%eax)
	...

00800588 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800588:	55                   	push   %ebp
  800589:	89 e5                	mov    %esp,%ebp
  80058b:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  80058e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800595:	e8 07 0a 00 00       	call   800fa1 <sys_env_destroy>
}
  80059a:	c9                   	leave  
  80059b:	c3                   	ret    

0080059c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80059c:	55                   	push   %ebp
  80059d:	89 e5                	mov    %esp,%ebp
  80059f:	56                   	push   %esi
  8005a0:	53                   	push   %ebx
  8005a1:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8005a4:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8005a7:	8b 1d 1c 40 80 00    	mov    0x80401c,%ebx
  8005ad:	e8 41 0a 00 00       	call   800ff3 <sys_getenvid>
  8005b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005b5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8005b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8005bc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005c0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005c8:	c7 04 24 2c 2f 80 00 	movl   $0x802f2c,(%esp)
  8005cf:	e8 c0 00 00 00       	call   800694 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8005d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005d8:	8b 45 10             	mov    0x10(%ebp),%eax
  8005db:	89 04 24             	mov    %eax,(%esp)
  8005de:	e8 50 00 00 00       	call   800633 <vcprintf>
	cprintf("\n");
  8005e3:	c7 04 24 58 2e 80 00 	movl   $0x802e58,(%esp)
  8005ea:	e8 a5 00 00 00       	call   800694 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8005ef:	cc                   	int3   
  8005f0:	eb fd                	jmp    8005ef <_panic+0x53>
	...

008005f4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8005f4:	55                   	push   %ebp
  8005f5:	89 e5                	mov    %esp,%ebp
  8005f7:	53                   	push   %ebx
  8005f8:	83 ec 14             	sub    $0x14,%esp
  8005fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8005fe:	8b 03                	mov    (%ebx),%eax
  800600:	8b 55 08             	mov    0x8(%ebp),%edx
  800603:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800607:	40                   	inc    %eax
  800608:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80060a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80060f:	75 19                	jne    80062a <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800611:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800618:	00 
  800619:	8d 43 08             	lea    0x8(%ebx),%eax
  80061c:	89 04 24             	mov    %eax,(%esp)
  80061f:	e8 40 09 00 00       	call   800f64 <sys_cputs>
		b->idx = 0;
  800624:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80062a:	ff 43 04             	incl   0x4(%ebx)
}
  80062d:	83 c4 14             	add    $0x14,%esp
  800630:	5b                   	pop    %ebx
  800631:	5d                   	pop    %ebp
  800632:	c3                   	ret    

00800633 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800633:	55                   	push   %ebp
  800634:	89 e5                	mov    %esp,%ebp
  800636:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80063c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800643:	00 00 00 
	b.cnt = 0;
  800646:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80064d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800650:	8b 45 0c             	mov    0xc(%ebp),%eax
  800653:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800657:	8b 45 08             	mov    0x8(%ebp),%eax
  80065a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80065e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800664:	89 44 24 04          	mov    %eax,0x4(%esp)
  800668:	c7 04 24 f4 05 80 00 	movl   $0x8005f4,(%esp)
  80066f:	e8 82 01 00 00       	call   8007f6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800674:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80067a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80067e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800684:	89 04 24             	mov    %eax,(%esp)
  800687:	e8 d8 08 00 00       	call   800f64 <sys_cputs>

	return b.cnt;
}
  80068c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800692:	c9                   	leave  
  800693:	c3                   	ret    

00800694 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800694:	55                   	push   %ebp
  800695:	89 e5                	mov    %esp,%ebp
  800697:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80069a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80069d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a4:	89 04 24             	mov    %eax,(%esp)
  8006a7:	e8 87 ff ff ff       	call   800633 <vcprintf>
	va_end(ap);

	return cnt;
}
  8006ac:	c9                   	leave  
  8006ad:	c3                   	ret    
	...

008006b0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8006b0:	55                   	push   %ebp
  8006b1:	89 e5                	mov    %esp,%ebp
  8006b3:	57                   	push   %edi
  8006b4:	56                   	push   %esi
  8006b5:	53                   	push   %ebx
  8006b6:	83 ec 3c             	sub    $0x3c,%esp
  8006b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006bc:	89 d7                	mov    %edx,%edi
  8006be:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006c7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006ca:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8006cd:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8006d0:	85 c0                	test   %eax,%eax
  8006d2:	75 08                	jne    8006dc <printnum+0x2c>
  8006d4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8006d7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8006da:	77 57                	ja     800733 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8006dc:	89 74 24 10          	mov    %esi,0x10(%esp)
  8006e0:	4b                   	dec    %ebx
  8006e1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8006e5:	8b 45 10             	mov    0x10(%ebp),%eax
  8006e8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006ec:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8006f0:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8006f4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8006fb:	00 
  8006fc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8006ff:	89 04 24             	mov    %eax,(%esp)
  800702:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800705:	89 44 24 04          	mov    %eax,0x4(%esp)
  800709:	e8 7a 24 00 00       	call   802b88 <__udivdi3>
  80070e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800712:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800716:	89 04 24             	mov    %eax,(%esp)
  800719:	89 54 24 04          	mov    %edx,0x4(%esp)
  80071d:	89 fa                	mov    %edi,%edx
  80071f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800722:	e8 89 ff ff ff       	call   8006b0 <printnum>
  800727:	eb 0f                	jmp    800738 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800729:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80072d:	89 34 24             	mov    %esi,(%esp)
  800730:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800733:	4b                   	dec    %ebx
  800734:	85 db                	test   %ebx,%ebx
  800736:	7f f1                	jg     800729 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800738:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80073c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800740:	8b 45 10             	mov    0x10(%ebp),%eax
  800743:	89 44 24 08          	mov    %eax,0x8(%esp)
  800747:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80074e:	00 
  80074f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800752:	89 04 24             	mov    %eax,(%esp)
  800755:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800758:	89 44 24 04          	mov    %eax,0x4(%esp)
  80075c:	e8 47 25 00 00       	call   802ca8 <__umoddi3>
  800761:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800765:	0f be 80 4f 2f 80 00 	movsbl 0x802f4f(%eax),%eax
  80076c:	89 04 24             	mov    %eax,(%esp)
  80076f:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800772:	83 c4 3c             	add    $0x3c,%esp
  800775:	5b                   	pop    %ebx
  800776:	5e                   	pop    %esi
  800777:	5f                   	pop    %edi
  800778:	5d                   	pop    %ebp
  800779:	c3                   	ret    

0080077a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80077a:	55                   	push   %ebp
  80077b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80077d:	83 fa 01             	cmp    $0x1,%edx
  800780:	7e 0e                	jle    800790 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800782:	8b 10                	mov    (%eax),%edx
  800784:	8d 4a 08             	lea    0x8(%edx),%ecx
  800787:	89 08                	mov    %ecx,(%eax)
  800789:	8b 02                	mov    (%edx),%eax
  80078b:	8b 52 04             	mov    0x4(%edx),%edx
  80078e:	eb 22                	jmp    8007b2 <getuint+0x38>
	else if (lflag)
  800790:	85 d2                	test   %edx,%edx
  800792:	74 10                	je     8007a4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800794:	8b 10                	mov    (%eax),%edx
  800796:	8d 4a 04             	lea    0x4(%edx),%ecx
  800799:	89 08                	mov    %ecx,(%eax)
  80079b:	8b 02                	mov    (%edx),%eax
  80079d:	ba 00 00 00 00       	mov    $0x0,%edx
  8007a2:	eb 0e                	jmp    8007b2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8007a4:	8b 10                	mov    (%eax),%edx
  8007a6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007a9:	89 08                	mov    %ecx,(%eax)
  8007ab:	8b 02                	mov    (%edx),%eax
  8007ad:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007b2:	5d                   	pop    %ebp
  8007b3:	c3                   	ret    

008007b4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007ba:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8007bd:	8b 10                	mov    (%eax),%edx
  8007bf:	3b 50 04             	cmp    0x4(%eax),%edx
  8007c2:	73 08                	jae    8007cc <sprintputch+0x18>
		*b->buf++ = ch;
  8007c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c7:	88 0a                	mov    %cl,(%edx)
  8007c9:	42                   	inc    %edx
  8007ca:	89 10                	mov    %edx,(%eax)
}
  8007cc:	5d                   	pop    %ebp
  8007cd:	c3                   	ret    

008007ce <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007ce:	55                   	push   %ebp
  8007cf:	89 e5                	mov    %esp,%ebp
  8007d1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8007d4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007db:	8b 45 10             	mov    0x10(%ebp),%eax
  8007de:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ec:	89 04 24             	mov    %eax,(%esp)
  8007ef:	e8 02 00 00 00       	call   8007f6 <vprintfmt>
	va_end(ap);
}
  8007f4:	c9                   	leave  
  8007f5:	c3                   	ret    

008007f6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8007f6:	55                   	push   %ebp
  8007f7:	89 e5                	mov    %esp,%ebp
  8007f9:	57                   	push   %edi
  8007fa:	56                   	push   %esi
  8007fb:	53                   	push   %ebx
  8007fc:	83 ec 4c             	sub    $0x4c,%esp
  8007ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800802:	8b 75 10             	mov    0x10(%ebp),%esi
  800805:	eb 12                	jmp    800819 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800807:	85 c0                	test   %eax,%eax
  800809:	0f 84 6b 03 00 00    	je     800b7a <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80080f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800813:	89 04 24             	mov    %eax,(%esp)
  800816:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800819:	0f b6 06             	movzbl (%esi),%eax
  80081c:	46                   	inc    %esi
  80081d:	83 f8 25             	cmp    $0x25,%eax
  800820:	75 e5                	jne    800807 <vprintfmt+0x11>
  800822:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800826:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80082d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800832:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800839:	b9 00 00 00 00       	mov    $0x0,%ecx
  80083e:	eb 26                	jmp    800866 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800840:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800843:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800847:	eb 1d                	jmp    800866 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800849:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80084c:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800850:	eb 14                	jmp    800866 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800852:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800855:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80085c:	eb 08                	jmp    800866 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80085e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800861:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800866:	0f b6 06             	movzbl (%esi),%eax
  800869:	8d 56 01             	lea    0x1(%esi),%edx
  80086c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80086f:	8a 16                	mov    (%esi),%dl
  800871:	83 ea 23             	sub    $0x23,%edx
  800874:	80 fa 55             	cmp    $0x55,%dl
  800877:	0f 87 e1 02 00 00    	ja     800b5e <vprintfmt+0x368>
  80087d:	0f b6 d2             	movzbl %dl,%edx
  800880:	ff 24 95 a0 30 80 00 	jmp    *0x8030a0(,%edx,4)
  800887:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80088a:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80088f:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800892:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800896:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800899:	8d 50 d0             	lea    -0x30(%eax),%edx
  80089c:	83 fa 09             	cmp    $0x9,%edx
  80089f:	77 2a                	ja     8008cb <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8008a1:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8008a2:	eb eb                	jmp    80088f <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a7:	8d 50 04             	lea    0x4(%eax),%edx
  8008aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8008ad:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008af:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008b2:	eb 17                	jmp    8008cb <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8008b4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008b8:	78 98                	js     800852 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ba:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008bd:	eb a7                	jmp    800866 <vprintfmt+0x70>
  8008bf:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008c2:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8008c9:	eb 9b                	jmp    800866 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8008cb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008cf:	79 95                	jns    800866 <vprintfmt+0x70>
  8008d1:	eb 8b                	jmp    80085e <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8008d3:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008d4:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8008d7:	eb 8d                	jmp    800866 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8008d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8008dc:	8d 50 04             	lea    0x4(%eax),%edx
  8008df:	89 55 14             	mov    %edx,0x14(%ebp)
  8008e2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008e6:	8b 00                	mov    (%eax),%eax
  8008e8:	89 04 24             	mov    %eax,(%esp)
  8008eb:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ee:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8008f1:	e9 23 ff ff ff       	jmp    800819 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8008f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f9:	8d 50 04             	lea    0x4(%eax),%edx
  8008fc:	89 55 14             	mov    %edx,0x14(%ebp)
  8008ff:	8b 00                	mov    (%eax),%eax
  800901:	85 c0                	test   %eax,%eax
  800903:	79 02                	jns    800907 <vprintfmt+0x111>
  800905:	f7 d8                	neg    %eax
  800907:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800909:	83 f8 0f             	cmp    $0xf,%eax
  80090c:	7f 0b                	jg     800919 <vprintfmt+0x123>
  80090e:	8b 04 85 00 32 80 00 	mov    0x803200(,%eax,4),%eax
  800915:	85 c0                	test   %eax,%eax
  800917:	75 23                	jne    80093c <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800919:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80091d:	c7 44 24 08 67 2f 80 	movl   $0x802f67,0x8(%esp)
  800924:	00 
  800925:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800929:	8b 45 08             	mov    0x8(%ebp),%eax
  80092c:	89 04 24             	mov    %eax,(%esp)
  80092f:	e8 9a fe ff ff       	call   8007ce <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800934:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800937:	e9 dd fe ff ff       	jmp    800819 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80093c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800940:	c7 44 24 08 21 34 80 	movl   $0x803421,0x8(%esp)
  800947:	00 
  800948:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80094c:	8b 55 08             	mov    0x8(%ebp),%edx
  80094f:	89 14 24             	mov    %edx,(%esp)
  800952:	e8 77 fe ff ff       	call   8007ce <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800957:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80095a:	e9 ba fe ff ff       	jmp    800819 <vprintfmt+0x23>
  80095f:	89 f9                	mov    %edi,%ecx
  800961:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800964:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800967:	8b 45 14             	mov    0x14(%ebp),%eax
  80096a:	8d 50 04             	lea    0x4(%eax),%edx
  80096d:	89 55 14             	mov    %edx,0x14(%ebp)
  800970:	8b 30                	mov    (%eax),%esi
  800972:	85 f6                	test   %esi,%esi
  800974:	75 05                	jne    80097b <vprintfmt+0x185>
				p = "(null)";
  800976:	be 60 2f 80 00       	mov    $0x802f60,%esi
			if (width > 0 && padc != '-')
  80097b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80097f:	0f 8e 84 00 00 00    	jle    800a09 <vprintfmt+0x213>
  800985:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800989:	74 7e                	je     800a09 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80098b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80098f:	89 34 24             	mov    %esi,(%esp)
  800992:	e8 8b 02 00 00       	call   800c22 <strnlen>
  800997:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80099a:	29 c2                	sub    %eax,%edx
  80099c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80099f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8009a3:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8009a6:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8009a9:	89 de                	mov    %ebx,%esi
  8009ab:	89 d3                	mov    %edx,%ebx
  8009ad:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009af:	eb 0b                	jmp    8009bc <vprintfmt+0x1c6>
					putch(padc, putdat);
  8009b1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009b5:	89 3c 24             	mov    %edi,(%esp)
  8009b8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009bb:	4b                   	dec    %ebx
  8009bc:	85 db                	test   %ebx,%ebx
  8009be:	7f f1                	jg     8009b1 <vprintfmt+0x1bb>
  8009c0:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8009c3:	89 f3                	mov    %esi,%ebx
  8009c5:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8009c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8009cb:	85 c0                	test   %eax,%eax
  8009cd:	79 05                	jns    8009d4 <vprintfmt+0x1de>
  8009cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8009d7:	29 c2                	sub    %eax,%edx
  8009d9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8009dc:	eb 2b                	jmp    800a09 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8009de:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8009e2:	74 18                	je     8009fc <vprintfmt+0x206>
  8009e4:	8d 50 e0             	lea    -0x20(%eax),%edx
  8009e7:	83 fa 5e             	cmp    $0x5e,%edx
  8009ea:	76 10                	jbe    8009fc <vprintfmt+0x206>
					putch('?', putdat);
  8009ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009f0:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8009f7:	ff 55 08             	call   *0x8(%ebp)
  8009fa:	eb 0a                	jmp    800a06 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8009fc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a00:	89 04 24             	mov    %eax,(%esp)
  800a03:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a06:	ff 4d e4             	decl   -0x1c(%ebp)
  800a09:	0f be 06             	movsbl (%esi),%eax
  800a0c:	46                   	inc    %esi
  800a0d:	85 c0                	test   %eax,%eax
  800a0f:	74 21                	je     800a32 <vprintfmt+0x23c>
  800a11:	85 ff                	test   %edi,%edi
  800a13:	78 c9                	js     8009de <vprintfmt+0x1e8>
  800a15:	4f                   	dec    %edi
  800a16:	79 c6                	jns    8009de <vprintfmt+0x1e8>
  800a18:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a1b:	89 de                	mov    %ebx,%esi
  800a1d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800a20:	eb 18                	jmp    800a3a <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a22:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a26:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800a2d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a2f:	4b                   	dec    %ebx
  800a30:	eb 08                	jmp    800a3a <vprintfmt+0x244>
  800a32:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a35:	89 de                	mov    %ebx,%esi
  800a37:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800a3a:	85 db                	test   %ebx,%ebx
  800a3c:	7f e4                	jg     800a22 <vprintfmt+0x22c>
  800a3e:	89 7d 08             	mov    %edi,0x8(%ebp)
  800a41:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a43:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800a46:	e9 ce fd ff ff       	jmp    800819 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a4b:	83 f9 01             	cmp    $0x1,%ecx
  800a4e:	7e 10                	jle    800a60 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800a50:	8b 45 14             	mov    0x14(%ebp),%eax
  800a53:	8d 50 08             	lea    0x8(%eax),%edx
  800a56:	89 55 14             	mov    %edx,0x14(%ebp)
  800a59:	8b 30                	mov    (%eax),%esi
  800a5b:	8b 78 04             	mov    0x4(%eax),%edi
  800a5e:	eb 26                	jmp    800a86 <vprintfmt+0x290>
	else if (lflag)
  800a60:	85 c9                	test   %ecx,%ecx
  800a62:	74 12                	je     800a76 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800a64:	8b 45 14             	mov    0x14(%ebp),%eax
  800a67:	8d 50 04             	lea    0x4(%eax),%edx
  800a6a:	89 55 14             	mov    %edx,0x14(%ebp)
  800a6d:	8b 30                	mov    (%eax),%esi
  800a6f:	89 f7                	mov    %esi,%edi
  800a71:	c1 ff 1f             	sar    $0x1f,%edi
  800a74:	eb 10                	jmp    800a86 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800a76:	8b 45 14             	mov    0x14(%ebp),%eax
  800a79:	8d 50 04             	lea    0x4(%eax),%edx
  800a7c:	89 55 14             	mov    %edx,0x14(%ebp)
  800a7f:	8b 30                	mov    (%eax),%esi
  800a81:	89 f7                	mov    %esi,%edi
  800a83:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800a86:	85 ff                	test   %edi,%edi
  800a88:	78 0a                	js     800a94 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800a8a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a8f:	e9 8c 00 00 00       	jmp    800b20 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800a94:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a98:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800a9f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800aa2:	f7 de                	neg    %esi
  800aa4:	83 d7 00             	adc    $0x0,%edi
  800aa7:	f7 df                	neg    %edi
			}
			base = 10;
  800aa9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800aae:	eb 70                	jmp    800b20 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800ab0:	89 ca                	mov    %ecx,%edx
  800ab2:	8d 45 14             	lea    0x14(%ebp),%eax
  800ab5:	e8 c0 fc ff ff       	call   80077a <getuint>
  800aba:	89 c6                	mov    %eax,%esi
  800abc:	89 d7                	mov    %edx,%edi
			base = 10;
  800abe:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800ac3:	eb 5b                	jmp    800b20 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  800ac5:	89 ca                	mov    %ecx,%edx
  800ac7:	8d 45 14             	lea    0x14(%ebp),%eax
  800aca:	e8 ab fc ff ff       	call   80077a <getuint>
  800acf:	89 c6                	mov    %eax,%esi
  800ad1:	89 d7                	mov    %edx,%edi
			base = 8;
  800ad3:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800ad8:	eb 46                	jmp    800b20 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  800ada:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ade:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800ae5:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800ae8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800aec:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800af3:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800af6:	8b 45 14             	mov    0x14(%ebp),%eax
  800af9:	8d 50 04             	lea    0x4(%eax),%edx
  800afc:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800aff:	8b 30                	mov    (%eax),%esi
  800b01:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b06:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800b0b:	eb 13                	jmp    800b20 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b0d:	89 ca                	mov    %ecx,%edx
  800b0f:	8d 45 14             	lea    0x14(%ebp),%eax
  800b12:	e8 63 fc ff ff       	call   80077a <getuint>
  800b17:	89 c6                	mov    %eax,%esi
  800b19:	89 d7                	mov    %edx,%edi
			base = 16;
  800b1b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b20:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800b24:	89 54 24 10          	mov    %edx,0x10(%esp)
  800b28:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800b2b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800b2f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b33:	89 34 24             	mov    %esi,(%esp)
  800b36:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b3a:	89 da                	mov    %ebx,%edx
  800b3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3f:	e8 6c fb ff ff       	call   8006b0 <printnum>
			break;
  800b44:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800b47:	e9 cd fc ff ff       	jmp    800819 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b4c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b50:	89 04 24             	mov    %eax,(%esp)
  800b53:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b56:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800b59:	e9 bb fc ff ff       	jmp    800819 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b5e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b62:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800b69:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b6c:	eb 01                	jmp    800b6f <vprintfmt+0x379>
  800b6e:	4e                   	dec    %esi
  800b6f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800b73:	75 f9                	jne    800b6e <vprintfmt+0x378>
  800b75:	e9 9f fc ff ff       	jmp    800819 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800b7a:	83 c4 4c             	add    $0x4c,%esp
  800b7d:	5b                   	pop    %ebx
  800b7e:	5e                   	pop    %esi
  800b7f:	5f                   	pop    %edi
  800b80:	5d                   	pop    %ebp
  800b81:	c3                   	ret    

00800b82 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b82:	55                   	push   %ebp
  800b83:	89 e5                	mov    %esp,%ebp
  800b85:	83 ec 28             	sub    $0x28,%esp
  800b88:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b8e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b91:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800b95:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800b98:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b9f:	85 c0                	test   %eax,%eax
  800ba1:	74 30                	je     800bd3 <vsnprintf+0x51>
  800ba3:	85 d2                	test   %edx,%edx
  800ba5:	7e 33                	jle    800bda <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ba7:	8b 45 14             	mov    0x14(%ebp),%eax
  800baa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bae:	8b 45 10             	mov    0x10(%ebp),%eax
  800bb1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bb5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800bb8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bbc:	c7 04 24 b4 07 80 00 	movl   $0x8007b4,(%esp)
  800bc3:	e8 2e fc ff ff       	call   8007f6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800bc8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bcb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800bce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bd1:	eb 0c                	jmp    800bdf <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800bd3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800bd8:	eb 05                	jmp    800bdf <vsnprintf+0x5d>
  800bda:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800bdf:	c9                   	leave  
  800be0:	c3                   	ret    

00800be1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800be1:	55                   	push   %ebp
  800be2:	89 e5                	mov    %esp,%ebp
  800be4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800be7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800bea:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bee:	8b 45 10             	mov    0x10(%ebp),%eax
  800bf1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bf5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bf8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bfc:	8b 45 08             	mov    0x8(%ebp),%eax
  800bff:	89 04 24             	mov    %eax,(%esp)
  800c02:	e8 7b ff ff ff       	call   800b82 <vsnprintf>
	va_end(ap);

	return rc;
}
  800c07:	c9                   	leave  
  800c08:	c3                   	ret    
  800c09:	00 00                	add    %al,(%eax)
	...

00800c0c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c0c:	55                   	push   %ebp
  800c0d:	89 e5                	mov    %esp,%ebp
  800c0f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c12:	b8 00 00 00 00       	mov    $0x0,%eax
  800c17:	eb 01                	jmp    800c1a <strlen+0xe>
		n++;
  800c19:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c1a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c1e:	75 f9                	jne    800c19 <strlen+0xd>
		n++;
	return n;
}
  800c20:	5d                   	pop    %ebp
  800c21:	c3                   	ret    

00800c22 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c22:	55                   	push   %ebp
  800c23:	89 e5                	mov    %esp,%ebp
  800c25:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800c28:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c2b:	b8 00 00 00 00       	mov    $0x0,%eax
  800c30:	eb 01                	jmp    800c33 <strnlen+0x11>
		n++;
  800c32:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c33:	39 d0                	cmp    %edx,%eax
  800c35:	74 06                	je     800c3d <strnlen+0x1b>
  800c37:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800c3b:	75 f5                	jne    800c32 <strnlen+0x10>
		n++;
	return n;
}
  800c3d:	5d                   	pop    %ebp
  800c3e:	c3                   	ret    

00800c3f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c3f:	55                   	push   %ebp
  800c40:	89 e5                	mov    %esp,%ebp
  800c42:	53                   	push   %ebx
  800c43:	8b 45 08             	mov    0x8(%ebp),%eax
  800c46:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c49:	ba 00 00 00 00       	mov    $0x0,%edx
  800c4e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800c51:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800c54:	42                   	inc    %edx
  800c55:	84 c9                	test   %cl,%cl
  800c57:	75 f5                	jne    800c4e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800c59:	5b                   	pop    %ebx
  800c5a:	5d                   	pop    %ebp
  800c5b:	c3                   	ret    

00800c5c <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c5c:	55                   	push   %ebp
  800c5d:	89 e5                	mov    %esp,%ebp
  800c5f:	53                   	push   %ebx
  800c60:	83 ec 08             	sub    $0x8,%esp
  800c63:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800c66:	89 1c 24             	mov    %ebx,(%esp)
  800c69:	e8 9e ff ff ff       	call   800c0c <strlen>
	strcpy(dst + len, src);
  800c6e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c71:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c75:	01 d8                	add    %ebx,%eax
  800c77:	89 04 24             	mov    %eax,(%esp)
  800c7a:	e8 c0 ff ff ff       	call   800c3f <strcpy>
	return dst;
}
  800c7f:	89 d8                	mov    %ebx,%eax
  800c81:	83 c4 08             	add    $0x8,%esp
  800c84:	5b                   	pop    %ebx
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	56                   	push   %esi
  800c8b:	53                   	push   %ebx
  800c8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c92:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c95:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c9a:	eb 0c                	jmp    800ca8 <strncpy+0x21>
		*dst++ = *src;
  800c9c:	8a 1a                	mov    (%edx),%bl
  800c9e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ca1:	80 3a 01             	cmpb   $0x1,(%edx)
  800ca4:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ca7:	41                   	inc    %ecx
  800ca8:	39 f1                	cmp    %esi,%ecx
  800caa:	75 f0                	jne    800c9c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800cac:	5b                   	pop    %ebx
  800cad:	5e                   	pop    %esi
  800cae:	5d                   	pop    %ebp
  800caf:	c3                   	ret    

00800cb0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800cb0:	55                   	push   %ebp
  800cb1:	89 e5                	mov    %esp,%ebp
  800cb3:	56                   	push   %esi
  800cb4:	53                   	push   %ebx
  800cb5:	8b 75 08             	mov    0x8(%ebp),%esi
  800cb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbb:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800cbe:	85 d2                	test   %edx,%edx
  800cc0:	75 0a                	jne    800ccc <strlcpy+0x1c>
  800cc2:	89 f0                	mov    %esi,%eax
  800cc4:	eb 1a                	jmp    800ce0 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800cc6:	88 18                	mov    %bl,(%eax)
  800cc8:	40                   	inc    %eax
  800cc9:	41                   	inc    %ecx
  800cca:	eb 02                	jmp    800cce <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ccc:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800cce:	4a                   	dec    %edx
  800ccf:	74 0a                	je     800cdb <strlcpy+0x2b>
  800cd1:	8a 19                	mov    (%ecx),%bl
  800cd3:	84 db                	test   %bl,%bl
  800cd5:	75 ef                	jne    800cc6 <strlcpy+0x16>
  800cd7:	89 c2                	mov    %eax,%edx
  800cd9:	eb 02                	jmp    800cdd <strlcpy+0x2d>
  800cdb:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800cdd:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800ce0:	29 f0                	sub    %esi,%eax
}
  800ce2:	5b                   	pop    %ebx
  800ce3:	5e                   	pop    %esi
  800ce4:	5d                   	pop    %ebp
  800ce5:	c3                   	ret    

00800ce6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ce6:	55                   	push   %ebp
  800ce7:	89 e5                	mov    %esp,%ebp
  800ce9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cec:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800cef:	eb 02                	jmp    800cf3 <strcmp+0xd>
		p++, q++;
  800cf1:	41                   	inc    %ecx
  800cf2:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800cf3:	8a 01                	mov    (%ecx),%al
  800cf5:	84 c0                	test   %al,%al
  800cf7:	74 04                	je     800cfd <strcmp+0x17>
  800cf9:	3a 02                	cmp    (%edx),%al
  800cfb:	74 f4                	je     800cf1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800cfd:	0f b6 c0             	movzbl %al,%eax
  800d00:	0f b6 12             	movzbl (%edx),%edx
  800d03:	29 d0                	sub    %edx,%eax
}
  800d05:	5d                   	pop    %ebp
  800d06:	c3                   	ret    

00800d07 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d07:	55                   	push   %ebp
  800d08:	89 e5                	mov    %esp,%ebp
  800d0a:	53                   	push   %ebx
  800d0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d11:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800d14:	eb 03                	jmp    800d19 <strncmp+0x12>
		n--, p++, q++;
  800d16:	4a                   	dec    %edx
  800d17:	40                   	inc    %eax
  800d18:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d19:	85 d2                	test   %edx,%edx
  800d1b:	74 14                	je     800d31 <strncmp+0x2a>
  800d1d:	8a 18                	mov    (%eax),%bl
  800d1f:	84 db                	test   %bl,%bl
  800d21:	74 04                	je     800d27 <strncmp+0x20>
  800d23:	3a 19                	cmp    (%ecx),%bl
  800d25:	74 ef                	je     800d16 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d27:	0f b6 00             	movzbl (%eax),%eax
  800d2a:	0f b6 11             	movzbl (%ecx),%edx
  800d2d:	29 d0                	sub    %edx,%eax
  800d2f:	eb 05                	jmp    800d36 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800d31:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800d36:	5b                   	pop    %ebx
  800d37:	5d                   	pop    %ebp
  800d38:	c3                   	ret    

00800d39 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d39:	55                   	push   %ebp
  800d3a:	89 e5                	mov    %esp,%ebp
  800d3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800d42:	eb 05                	jmp    800d49 <strchr+0x10>
		if (*s == c)
  800d44:	38 ca                	cmp    %cl,%dl
  800d46:	74 0c                	je     800d54 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d48:	40                   	inc    %eax
  800d49:	8a 10                	mov    (%eax),%dl
  800d4b:	84 d2                	test   %dl,%dl
  800d4d:	75 f5                	jne    800d44 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800d4f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d54:	5d                   	pop    %ebp
  800d55:	c3                   	ret    

00800d56 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d56:	55                   	push   %ebp
  800d57:	89 e5                	mov    %esp,%ebp
  800d59:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800d5f:	eb 05                	jmp    800d66 <strfind+0x10>
		if (*s == c)
  800d61:	38 ca                	cmp    %cl,%dl
  800d63:	74 07                	je     800d6c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800d65:	40                   	inc    %eax
  800d66:	8a 10                	mov    (%eax),%dl
  800d68:	84 d2                	test   %dl,%dl
  800d6a:	75 f5                	jne    800d61 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800d6c:	5d                   	pop    %ebp
  800d6d:	c3                   	ret    

00800d6e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d6e:	55                   	push   %ebp
  800d6f:	89 e5                	mov    %esp,%ebp
  800d71:	57                   	push   %edi
  800d72:	56                   	push   %esi
  800d73:	53                   	push   %ebx
  800d74:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d77:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d7a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d7d:	85 c9                	test   %ecx,%ecx
  800d7f:	74 30                	je     800db1 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d81:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d87:	75 25                	jne    800dae <memset+0x40>
  800d89:	f6 c1 03             	test   $0x3,%cl
  800d8c:	75 20                	jne    800dae <memset+0x40>
		c &= 0xFF;
  800d8e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d91:	89 d3                	mov    %edx,%ebx
  800d93:	c1 e3 08             	shl    $0x8,%ebx
  800d96:	89 d6                	mov    %edx,%esi
  800d98:	c1 e6 18             	shl    $0x18,%esi
  800d9b:	89 d0                	mov    %edx,%eax
  800d9d:	c1 e0 10             	shl    $0x10,%eax
  800da0:	09 f0                	or     %esi,%eax
  800da2:	09 d0                	or     %edx,%eax
  800da4:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800da6:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800da9:	fc                   	cld    
  800daa:	f3 ab                	rep stos %eax,%es:(%edi)
  800dac:	eb 03                	jmp    800db1 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800dae:	fc                   	cld    
  800daf:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800db1:	89 f8                	mov    %edi,%eax
  800db3:	5b                   	pop    %ebx
  800db4:	5e                   	pop    %esi
  800db5:	5f                   	pop    %edi
  800db6:	5d                   	pop    %ebp
  800db7:	c3                   	ret    

00800db8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800db8:	55                   	push   %ebp
  800db9:	89 e5                	mov    %esp,%ebp
  800dbb:	57                   	push   %edi
  800dbc:	56                   	push   %esi
  800dbd:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dc3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800dc6:	39 c6                	cmp    %eax,%esi
  800dc8:	73 34                	jae    800dfe <memmove+0x46>
  800dca:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800dcd:	39 d0                	cmp    %edx,%eax
  800dcf:	73 2d                	jae    800dfe <memmove+0x46>
		s += n;
		d += n;
  800dd1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800dd4:	f6 c2 03             	test   $0x3,%dl
  800dd7:	75 1b                	jne    800df4 <memmove+0x3c>
  800dd9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ddf:	75 13                	jne    800df4 <memmove+0x3c>
  800de1:	f6 c1 03             	test   $0x3,%cl
  800de4:	75 0e                	jne    800df4 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800de6:	83 ef 04             	sub    $0x4,%edi
  800de9:	8d 72 fc             	lea    -0x4(%edx),%esi
  800dec:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800def:	fd                   	std    
  800df0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800df2:	eb 07                	jmp    800dfb <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800df4:	4f                   	dec    %edi
  800df5:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800df8:	fd                   	std    
  800df9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800dfb:	fc                   	cld    
  800dfc:	eb 20                	jmp    800e1e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800dfe:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e04:	75 13                	jne    800e19 <memmove+0x61>
  800e06:	a8 03                	test   $0x3,%al
  800e08:	75 0f                	jne    800e19 <memmove+0x61>
  800e0a:	f6 c1 03             	test   $0x3,%cl
  800e0d:	75 0a                	jne    800e19 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800e0f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800e12:	89 c7                	mov    %eax,%edi
  800e14:	fc                   	cld    
  800e15:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e17:	eb 05                	jmp    800e1e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e19:	89 c7                	mov    %eax,%edi
  800e1b:	fc                   	cld    
  800e1c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e1e:	5e                   	pop    %esi
  800e1f:	5f                   	pop    %edi
  800e20:	5d                   	pop    %ebp
  800e21:	c3                   	ret    

00800e22 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e22:	55                   	push   %ebp
  800e23:	89 e5                	mov    %esp,%ebp
  800e25:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800e28:	8b 45 10             	mov    0x10(%ebp),%eax
  800e2b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e32:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e36:	8b 45 08             	mov    0x8(%ebp),%eax
  800e39:	89 04 24             	mov    %eax,(%esp)
  800e3c:	e8 77 ff ff ff       	call   800db8 <memmove>
}
  800e41:	c9                   	leave  
  800e42:	c3                   	ret    

00800e43 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e43:	55                   	push   %ebp
  800e44:	89 e5                	mov    %esp,%ebp
  800e46:	57                   	push   %edi
  800e47:	56                   	push   %esi
  800e48:	53                   	push   %ebx
  800e49:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e4c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e4f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e52:	ba 00 00 00 00       	mov    $0x0,%edx
  800e57:	eb 16                	jmp    800e6f <memcmp+0x2c>
		if (*s1 != *s2)
  800e59:	8a 04 17             	mov    (%edi,%edx,1),%al
  800e5c:	42                   	inc    %edx
  800e5d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800e61:	38 c8                	cmp    %cl,%al
  800e63:	74 0a                	je     800e6f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800e65:	0f b6 c0             	movzbl %al,%eax
  800e68:	0f b6 c9             	movzbl %cl,%ecx
  800e6b:	29 c8                	sub    %ecx,%eax
  800e6d:	eb 09                	jmp    800e78 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e6f:	39 da                	cmp    %ebx,%edx
  800e71:	75 e6                	jne    800e59 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e73:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e78:	5b                   	pop    %ebx
  800e79:	5e                   	pop    %esi
  800e7a:	5f                   	pop    %edi
  800e7b:	5d                   	pop    %ebp
  800e7c:	c3                   	ret    

00800e7d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e7d:	55                   	push   %ebp
  800e7e:	89 e5                	mov    %esp,%ebp
  800e80:	8b 45 08             	mov    0x8(%ebp),%eax
  800e83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800e86:	89 c2                	mov    %eax,%edx
  800e88:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e8b:	eb 05                	jmp    800e92 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e8d:	38 08                	cmp    %cl,(%eax)
  800e8f:	74 05                	je     800e96 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e91:	40                   	inc    %eax
  800e92:	39 d0                	cmp    %edx,%eax
  800e94:	72 f7                	jb     800e8d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e96:	5d                   	pop    %ebp
  800e97:	c3                   	ret    

00800e98 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e98:	55                   	push   %ebp
  800e99:	89 e5                	mov    %esp,%ebp
  800e9b:	57                   	push   %edi
  800e9c:	56                   	push   %esi
  800e9d:	53                   	push   %ebx
  800e9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ea4:	eb 01                	jmp    800ea7 <strtol+0xf>
		s++;
  800ea6:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ea7:	8a 02                	mov    (%edx),%al
  800ea9:	3c 20                	cmp    $0x20,%al
  800eab:	74 f9                	je     800ea6 <strtol+0xe>
  800ead:	3c 09                	cmp    $0x9,%al
  800eaf:	74 f5                	je     800ea6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800eb1:	3c 2b                	cmp    $0x2b,%al
  800eb3:	75 08                	jne    800ebd <strtol+0x25>
		s++;
  800eb5:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800eb6:	bf 00 00 00 00       	mov    $0x0,%edi
  800ebb:	eb 13                	jmp    800ed0 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ebd:	3c 2d                	cmp    $0x2d,%al
  800ebf:	75 0a                	jne    800ecb <strtol+0x33>
		s++, neg = 1;
  800ec1:	8d 52 01             	lea    0x1(%edx),%edx
  800ec4:	bf 01 00 00 00       	mov    $0x1,%edi
  800ec9:	eb 05                	jmp    800ed0 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ecb:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ed0:	85 db                	test   %ebx,%ebx
  800ed2:	74 05                	je     800ed9 <strtol+0x41>
  800ed4:	83 fb 10             	cmp    $0x10,%ebx
  800ed7:	75 28                	jne    800f01 <strtol+0x69>
  800ed9:	8a 02                	mov    (%edx),%al
  800edb:	3c 30                	cmp    $0x30,%al
  800edd:	75 10                	jne    800eef <strtol+0x57>
  800edf:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ee3:	75 0a                	jne    800eef <strtol+0x57>
		s += 2, base = 16;
  800ee5:	83 c2 02             	add    $0x2,%edx
  800ee8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800eed:	eb 12                	jmp    800f01 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800eef:	85 db                	test   %ebx,%ebx
  800ef1:	75 0e                	jne    800f01 <strtol+0x69>
  800ef3:	3c 30                	cmp    $0x30,%al
  800ef5:	75 05                	jne    800efc <strtol+0x64>
		s++, base = 8;
  800ef7:	42                   	inc    %edx
  800ef8:	b3 08                	mov    $0x8,%bl
  800efa:	eb 05                	jmp    800f01 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800efc:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800f01:	b8 00 00 00 00       	mov    $0x0,%eax
  800f06:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f08:	8a 0a                	mov    (%edx),%cl
  800f0a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800f0d:	80 fb 09             	cmp    $0x9,%bl
  800f10:	77 08                	ja     800f1a <strtol+0x82>
			dig = *s - '0';
  800f12:	0f be c9             	movsbl %cl,%ecx
  800f15:	83 e9 30             	sub    $0x30,%ecx
  800f18:	eb 1e                	jmp    800f38 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800f1a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800f1d:	80 fb 19             	cmp    $0x19,%bl
  800f20:	77 08                	ja     800f2a <strtol+0x92>
			dig = *s - 'a' + 10;
  800f22:	0f be c9             	movsbl %cl,%ecx
  800f25:	83 e9 57             	sub    $0x57,%ecx
  800f28:	eb 0e                	jmp    800f38 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800f2a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800f2d:	80 fb 19             	cmp    $0x19,%bl
  800f30:	77 12                	ja     800f44 <strtol+0xac>
			dig = *s - 'A' + 10;
  800f32:	0f be c9             	movsbl %cl,%ecx
  800f35:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800f38:	39 f1                	cmp    %esi,%ecx
  800f3a:	7d 0c                	jge    800f48 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800f3c:	42                   	inc    %edx
  800f3d:	0f af c6             	imul   %esi,%eax
  800f40:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800f42:	eb c4                	jmp    800f08 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800f44:	89 c1                	mov    %eax,%ecx
  800f46:	eb 02                	jmp    800f4a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800f48:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800f4a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f4e:	74 05                	je     800f55 <strtol+0xbd>
		*endptr = (char *) s;
  800f50:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f53:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800f55:	85 ff                	test   %edi,%edi
  800f57:	74 04                	je     800f5d <strtol+0xc5>
  800f59:	89 c8                	mov    %ecx,%eax
  800f5b:	f7 d8                	neg    %eax
}
  800f5d:	5b                   	pop    %ebx
  800f5e:	5e                   	pop    %esi
  800f5f:	5f                   	pop    %edi
  800f60:	5d                   	pop    %ebp
  800f61:	c3                   	ret    
	...

00800f64 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800f64:	55                   	push   %ebp
  800f65:	89 e5                	mov    %esp,%ebp
  800f67:	57                   	push   %edi
  800f68:	56                   	push   %esi
  800f69:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f6a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f72:	8b 55 08             	mov    0x8(%ebp),%edx
  800f75:	89 c3                	mov    %eax,%ebx
  800f77:	89 c7                	mov    %eax,%edi
  800f79:	89 c6                	mov    %eax,%esi
  800f7b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800f7d:	5b                   	pop    %ebx
  800f7e:	5e                   	pop    %esi
  800f7f:	5f                   	pop    %edi
  800f80:	5d                   	pop    %ebp
  800f81:	c3                   	ret    

00800f82 <sys_cgetc>:

int
sys_cgetc(void)
{
  800f82:	55                   	push   %ebp
  800f83:	89 e5                	mov    %esp,%ebp
  800f85:	57                   	push   %edi
  800f86:	56                   	push   %esi
  800f87:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f88:	ba 00 00 00 00       	mov    $0x0,%edx
  800f8d:	b8 01 00 00 00       	mov    $0x1,%eax
  800f92:	89 d1                	mov    %edx,%ecx
  800f94:	89 d3                	mov    %edx,%ebx
  800f96:	89 d7                	mov    %edx,%edi
  800f98:	89 d6                	mov    %edx,%esi
  800f9a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800f9c:	5b                   	pop    %ebx
  800f9d:	5e                   	pop    %esi
  800f9e:	5f                   	pop    %edi
  800f9f:	5d                   	pop    %ebp
  800fa0:	c3                   	ret    

00800fa1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800fa1:	55                   	push   %ebp
  800fa2:	89 e5                	mov    %esp,%ebp
  800fa4:	57                   	push   %edi
  800fa5:	56                   	push   %esi
  800fa6:	53                   	push   %ebx
  800fa7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800faa:	b9 00 00 00 00       	mov    $0x0,%ecx
  800faf:	b8 03 00 00 00       	mov    $0x3,%eax
  800fb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb7:	89 cb                	mov    %ecx,%ebx
  800fb9:	89 cf                	mov    %ecx,%edi
  800fbb:	89 ce                	mov    %ecx,%esi
  800fbd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fbf:	85 c0                	test   %eax,%eax
  800fc1:	7e 28                	jle    800feb <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fc3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fc7:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800fce:	00 
  800fcf:	c7 44 24 08 5f 32 80 	movl   $0x80325f,0x8(%esp)
  800fd6:	00 
  800fd7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fde:	00 
  800fdf:	c7 04 24 7c 32 80 00 	movl   $0x80327c,(%esp)
  800fe6:	e8 b1 f5 ff ff       	call   80059c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800feb:	83 c4 2c             	add    $0x2c,%esp
  800fee:	5b                   	pop    %ebx
  800fef:	5e                   	pop    %esi
  800ff0:	5f                   	pop    %edi
  800ff1:	5d                   	pop    %ebp
  800ff2:	c3                   	ret    

00800ff3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ff3:	55                   	push   %ebp
  800ff4:	89 e5                	mov    %esp,%ebp
  800ff6:	57                   	push   %edi
  800ff7:	56                   	push   %esi
  800ff8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ff9:	ba 00 00 00 00       	mov    $0x0,%edx
  800ffe:	b8 02 00 00 00       	mov    $0x2,%eax
  801003:	89 d1                	mov    %edx,%ecx
  801005:	89 d3                	mov    %edx,%ebx
  801007:	89 d7                	mov    %edx,%edi
  801009:	89 d6                	mov    %edx,%esi
  80100b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80100d:	5b                   	pop    %ebx
  80100e:	5e                   	pop    %esi
  80100f:	5f                   	pop    %edi
  801010:	5d                   	pop    %ebp
  801011:	c3                   	ret    

00801012 <sys_yield>:

void
sys_yield(void)
{
  801012:	55                   	push   %ebp
  801013:	89 e5                	mov    %esp,%ebp
  801015:	57                   	push   %edi
  801016:	56                   	push   %esi
  801017:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801018:	ba 00 00 00 00       	mov    $0x0,%edx
  80101d:	b8 0b 00 00 00       	mov    $0xb,%eax
  801022:	89 d1                	mov    %edx,%ecx
  801024:	89 d3                	mov    %edx,%ebx
  801026:	89 d7                	mov    %edx,%edi
  801028:	89 d6                	mov    %edx,%esi
  80102a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80102c:	5b                   	pop    %ebx
  80102d:	5e                   	pop    %esi
  80102e:	5f                   	pop    %edi
  80102f:	5d                   	pop    %ebp
  801030:	c3                   	ret    

00801031 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801031:	55                   	push   %ebp
  801032:	89 e5                	mov    %esp,%ebp
  801034:	57                   	push   %edi
  801035:	56                   	push   %esi
  801036:	53                   	push   %ebx
  801037:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80103a:	be 00 00 00 00       	mov    $0x0,%esi
  80103f:	b8 04 00 00 00       	mov    $0x4,%eax
  801044:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801047:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80104a:	8b 55 08             	mov    0x8(%ebp),%edx
  80104d:	89 f7                	mov    %esi,%edi
  80104f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801051:	85 c0                	test   %eax,%eax
  801053:	7e 28                	jle    80107d <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  801055:	89 44 24 10          	mov    %eax,0x10(%esp)
  801059:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  801060:	00 
  801061:	c7 44 24 08 5f 32 80 	movl   $0x80325f,0x8(%esp)
  801068:	00 
  801069:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801070:	00 
  801071:	c7 04 24 7c 32 80 00 	movl   $0x80327c,(%esp)
  801078:	e8 1f f5 ff ff       	call   80059c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80107d:	83 c4 2c             	add    $0x2c,%esp
  801080:	5b                   	pop    %ebx
  801081:	5e                   	pop    %esi
  801082:	5f                   	pop    %edi
  801083:	5d                   	pop    %ebp
  801084:	c3                   	ret    

00801085 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801085:	55                   	push   %ebp
  801086:	89 e5                	mov    %esp,%ebp
  801088:	57                   	push   %edi
  801089:	56                   	push   %esi
  80108a:	53                   	push   %ebx
  80108b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80108e:	b8 05 00 00 00       	mov    $0x5,%eax
  801093:	8b 75 18             	mov    0x18(%ebp),%esi
  801096:	8b 7d 14             	mov    0x14(%ebp),%edi
  801099:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80109c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80109f:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010a4:	85 c0                	test   %eax,%eax
  8010a6:	7e 28                	jle    8010d0 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010a8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010ac:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8010b3:	00 
  8010b4:	c7 44 24 08 5f 32 80 	movl   $0x80325f,0x8(%esp)
  8010bb:	00 
  8010bc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010c3:	00 
  8010c4:	c7 04 24 7c 32 80 00 	movl   $0x80327c,(%esp)
  8010cb:	e8 cc f4 ff ff       	call   80059c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8010d0:	83 c4 2c             	add    $0x2c,%esp
  8010d3:	5b                   	pop    %ebx
  8010d4:	5e                   	pop    %esi
  8010d5:	5f                   	pop    %edi
  8010d6:	5d                   	pop    %ebp
  8010d7:	c3                   	ret    

008010d8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8010d8:	55                   	push   %ebp
  8010d9:	89 e5                	mov    %esp,%ebp
  8010db:	57                   	push   %edi
  8010dc:	56                   	push   %esi
  8010dd:	53                   	push   %ebx
  8010de:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010e6:	b8 06 00 00 00       	mov    $0x6,%eax
  8010eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f1:	89 df                	mov    %ebx,%edi
  8010f3:	89 de                	mov    %ebx,%esi
  8010f5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010f7:	85 c0                	test   %eax,%eax
  8010f9:	7e 28                	jle    801123 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010fb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010ff:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801106:	00 
  801107:	c7 44 24 08 5f 32 80 	movl   $0x80325f,0x8(%esp)
  80110e:	00 
  80110f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801116:	00 
  801117:	c7 04 24 7c 32 80 00 	movl   $0x80327c,(%esp)
  80111e:	e8 79 f4 ff ff       	call   80059c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801123:	83 c4 2c             	add    $0x2c,%esp
  801126:	5b                   	pop    %ebx
  801127:	5e                   	pop    %esi
  801128:	5f                   	pop    %edi
  801129:	5d                   	pop    %ebp
  80112a:	c3                   	ret    

0080112b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80112b:	55                   	push   %ebp
  80112c:	89 e5                	mov    %esp,%ebp
  80112e:	57                   	push   %edi
  80112f:	56                   	push   %esi
  801130:	53                   	push   %ebx
  801131:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801134:	bb 00 00 00 00       	mov    $0x0,%ebx
  801139:	b8 08 00 00 00       	mov    $0x8,%eax
  80113e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801141:	8b 55 08             	mov    0x8(%ebp),%edx
  801144:	89 df                	mov    %ebx,%edi
  801146:	89 de                	mov    %ebx,%esi
  801148:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80114a:	85 c0                	test   %eax,%eax
  80114c:	7e 28                	jle    801176 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80114e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801152:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  801159:	00 
  80115a:	c7 44 24 08 5f 32 80 	movl   $0x80325f,0x8(%esp)
  801161:	00 
  801162:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801169:	00 
  80116a:	c7 04 24 7c 32 80 00 	movl   $0x80327c,(%esp)
  801171:	e8 26 f4 ff ff       	call   80059c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801176:	83 c4 2c             	add    $0x2c,%esp
  801179:	5b                   	pop    %ebx
  80117a:	5e                   	pop    %esi
  80117b:	5f                   	pop    %edi
  80117c:	5d                   	pop    %ebp
  80117d:	c3                   	ret    

0080117e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80117e:	55                   	push   %ebp
  80117f:	89 e5                	mov    %esp,%ebp
  801181:	57                   	push   %edi
  801182:	56                   	push   %esi
  801183:	53                   	push   %ebx
  801184:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801187:	bb 00 00 00 00       	mov    $0x0,%ebx
  80118c:	b8 09 00 00 00       	mov    $0x9,%eax
  801191:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801194:	8b 55 08             	mov    0x8(%ebp),%edx
  801197:	89 df                	mov    %ebx,%edi
  801199:	89 de                	mov    %ebx,%esi
  80119b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80119d:	85 c0                	test   %eax,%eax
  80119f:	7e 28                	jle    8011c9 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011a1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011a5:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8011ac:	00 
  8011ad:	c7 44 24 08 5f 32 80 	movl   $0x80325f,0x8(%esp)
  8011b4:	00 
  8011b5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011bc:	00 
  8011bd:	c7 04 24 7c 32 80 00 	movl   $0x80327c,(%esp)
  8011c4:	e8 d3 f3 ff ff       	call   80059c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8011c9:	83 c4 2c             	add    $0x2c,%esp
  8011cc:	5b                   	pop    %ebx
  8011cd:	5e                   	pop    %esi
  8011ce:	5f                   	pop    %edi
  8011cf:	5d                   	pop    %ebp
  8011d0:	c3                   	ret    

008011d1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8011d1:	55                   	push   %ebp
  8011d2:	89 e5                	mov    %esp,%ebp
  8011d4:	57                   	push   %edi
  8011d5:	56                   	push   %esi
  8011d6:	53                   	push   %ebx
  8011d7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011da:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011df:	b8 0a 00 00 00       	mov    $0xa,%eax
  8011e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011e7:	8b 55 08             	mov    0x8(%ebp),%edx
  8011ea:	89 df                	mov    %ebx,%edi
  8011ec:	89 de                	mov    %ebx,%esi
  8011ee:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011f0:	85 c0                	test   %eax,%eax
  8011f2:	7e 28                	jle    80121c <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011f4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011f8:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8011ff:	00 
  801200:	c7 44 24 08 5f 32 80 	movl   $0x80325f,0x8(%esp)
  801207:	00 
  801208:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80120f:	00 
  801210:	c7 04 24 7c 32 80 00 	movl   $0x80327c,(%esp)
  801217:	e8 80 f3 ff ff       	call   80059c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80121c:	83 c4 2c             	add    $0x2c,%esp
  80121f:	5b                   	pop    %ebx
  801220:	5e                   	pop    %esi
  801221:	5f                   	pop    %edi
  801222:	5d                   	pop    %ebp
  801223:	c3                   	ret    

00801224 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801224:	55                   	push   %ebp
  801225:	89 e5                	mov    %esp,%ebp
  801227:	57                   	push   %edi
  801228:	56                   	push   %esi
  801229:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80122a:	be 00 00 00 00       	mov    $0x0,%esi
  80122f:	b8 0c 00 00 00       	mov    $0xc,%eax
  801234:	8b 7d 14             	mov    0x14(%ebp),%edi
  801237:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80123a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80123d:	8b 55 08             	mov    0x8(%ebp),%edx
  801240:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801242:	5b                   	pop    %ebx
  801243:	5e                   	pop    %esi
  801244:	5f                   	pop    %edi
  801245:	5d                   	pop    %ebp
  801246:	c3                   	ret    

00801247 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801247:	55                   	push   %ebp
  801248:	89 e5                	mov    %esp,%ebp
  80124a:	57                   	push   %edi
  80124b:	56                   	push   %esi
  80124c:	53                   	push   %ebx
  80124d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801250:	b9 00 00 00 00       	mov    $0x0,%ecx
  801255:	b8 0d 00 00 00       	mov    $0xd,%eax
  80125a:	8b 55 08             	mov    0x8(%ebp),%edx
  80125d:	89 cb                	mov    %ecx,%ebx
  80125f:	89 cf                	mov    %ecx,%edi
  801261:	89 ce                	mov    %ecx,%esi
  801263:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801265:	85 c0                	test   %eax,%eax
  801267:	7e 28                	jle    801291 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801269:	89 44 24 10          	mov    %eax,0x10(%esp)
  80126d:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801274:	00 
  801275:	c7 44 24 08 5f 32 80 	movl   $0x80325f,0x8(%esp)
  80127c:	00 
  80127d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801284:	00 
  801285:	c7 04 24 7c 32 80 00 	movl   $0x80327c,(%esp)
  80128c:	e8 0b f3 ff ff       	call   80059c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801291:	83 c4 2c             	add    $0x2c,%esp
  801294:	5b                   	pop    %ebx
  801295:	5e                   	pop    %esi
  801296:	5f                   	pop    %edi
  801297:	5d                   	pop    %ebp
  801298:	c3                   	ret    
  801299:	00 00                	add    %al,(%eax)
	...

0080129c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80129c:	55                   	push   %ebp
  80129d:	89 e5                	mov    %esp,%ebp
  80129f:	53                   	push   %ebx
  8012a0:	83 ec 24             	sub    $0x24,%esp
  8012a3:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8012a6:	8b 18                	mov    (%eax),%ebx
	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	if ((err & FEC_WR) == 0)
  8012a8:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8012ac:	75 20                	jne    8012ce <pgfault+0x32>
		panic("pgfault: faulting address [%08x] not a write\n", addr);
  8012ae:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8012b2:	c7 44 24 08 8c 32 80 	movl   $0x80328c,0x8(%esp)
  8012b9:	00 
  8012ba:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  8012c1:	00 
  8012c2:	c7 04 24 0c 33 80 00 	movl   $0x80330c,(%esp)
  8012c9:	e8 ce f2 ff ff       	call   80059c <_panic>

	void *page_aligned_addr = (void *) ROUNDDOWN(addr, PGSIZE);
  8012ce:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t page_num = (uint32_t) page_aligned_addr / PGSIZE;
  8012d4:	89 d8                	mov    %ebx,%eax
  8012d6:	c1 e8 0c             	shr    $0xc,%eax
	if (!(uvpt[page_num] & PTE_COW))
  8012d9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012e0:	f6 c4 08             	test   $0x8,%ah
  8012e3:	75 1c                	jne    801301 <pgfault+0x65>
		panic("pgfault: fault was not on a copy-on-write page\n");
  8012e5:	c7 44 24 08 bc 32 80 	movl   $0x8032bc,0x8(%esp)
  8012ec:	00 
  8012ed:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012f4:	00 
  8012f5:	c7 04 24 0c 33 80 00 	movl   $0x80330c,(%esp)
  8012fc:	e8 9b f2 ff ff       	call   80059c <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.

	// Allocate
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  801301:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801308:	00 
  801309:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801310:	00 
  801311:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801318:	e8 14 fd ff ff       	call   801031 <sys_page_alloc>
  80131d:	85 c0                	test   %eax,%eax
  80131f:	79 20                	jns    801341 <pgfault+0xa5>
		panic("sys_page_alloc: %e\n", r);
  801321:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801325:	c7 44 24 08 17 33 80 	movl   $0x803317,0x8(%esp)
  80132c:	00 
  80132d:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  801334:	00 
  801335:	c7 04 24 0c 33 80 00 	movl   $0x80330c,(%esp)
  80133c:	e8 5b f2 ff ff       	call   80059c <_panic>

	// Copy over
	void *src_addr = (void *) ROUNDDOWN(addr, PGSIZE);
	memmove(PFTEMP, src_addr, PGSIZE);
  801341:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801348:	00 
  801349:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80134d:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801354:	e8 5f fa ff ff       	call   800db8 <memmove>

	// Remap
	if ((r = sys_page_map(0, PFTEMP, 0, src_addr, PTE_P | PTE_U | PTE_W)) < 0)
  801359:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801360:	00 
  801361:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801365:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80136c:	00 
  80136d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801374:	00 
  801375:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80137c:	e8 04 fd ff ff       	call   801085 <sys_page_map>
  801381:	85 c0                	test   %eax,%eax
  801383:	79 20                	jns    8013a5 <pgfault+0x109>
		panic("sys_page_map: %e\n", r);
  801385:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801389:	c7 44 24 08 2b 33 80 	movl   $0x80332b,0x8(%esp)
  801390:	00 
  801391:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  801398:	00 
  801399:	c7 04 24 0c 33 80 00 	movl   $0x80330c,(%esp)
  8013a0:	e8 f7 f1 ff ff       	call   80059c <_panic>

}
  8013a5:	83 c4 24             	add    $0x24,%esp
  8013a8:	5b                   	pop    %ebx
  8013a9:	5d                   	pop    %ebp
  8013aa:	c3                   	ret    

008013ab <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8013ab:	55                   	push   %ebp
  8013ac:	89 e5                	mov    %esp,%ebp
  8013ae:	57                   	push   %edi
  8013af:	56                   	push   %esi
  8013b0:	53                   	push   %ebx
  8013b1:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	int r;
	envid_t child_envid;

	set_pgfault_handler(pgfault);
  8013b4:	c7 04 24 9c 12 80 00 	movl   $0x80129c,(%esp)
  8013bb:	e8 d0 15 00 00       	call   802990 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8013c0:	ba 07 00 00 00       	mov    $0x7,%edx
  8013c5:	89 d0                	mov    %edx,%eax
  8013c7:	cd 30                	int    $0x30
  8013c9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8013cc:	89 45 e0             	mov    %eax,-0x20(%ebp)

	child_envid = sys_exofork();
	if (child_envid < 0)
  8013cf:	85 c0                	test   %eax,%eax
  8013d1:	79 20                	jns    8013f3 <fork+0x48>
		panic("sys_exofork: %e\n", child_envid);
  8013d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013d7:	c7 44 24 08 3d 33 80 	movl   $0x80333d,0x8(%esp)
  8013de:	00 
  8013df:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  8013e6:	00 
  8013e7:	c7 04 24 0c 33 80 00 	movl   $0x80330c,(%esp)
  8013ee:	e8 a9 f1 ff ff       	call   80059c <_panic>
	if (child_envid == 0) { // child
  8013f3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8013f7:	75 25                	jne    80141e <fork+0x73>
		// Fix thisenv like dumbfork does and return 0
		thisenv = &envs[ENVX(sys_getenvid())];
  8013f9:	e8 f5 fb ff ff       	call   800ff3 <sys_getenvid>
  8013fe:	25 ff 03 00 00       	and    $0x3ff,%eax
  801403:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80140a:	c1 e0 07             	shl    $0x7,%eax
  80140d:	29 d0                	sub    %edx,%eax
  80140f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801414:	a3 04 50 80 00       	mov    %eax,0x805004
		return 0;
  801419:	e9 58 02 00 00       	jmp    801676 <fork+0x2cb>
	set_pgfault_handler(pgfault);

	child_envid = sys_exofork();
	if (child_envid < 0)
		panic("sys_exofork: %e\n", child_envid);
	if (child_envid == 0) { // child
  80141e:	bf 00 00 00 00       	mov    $0x0,%edi
  801423:	be 00 00 00 00       	mov    $0x0,%esi
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
  801428:	89 f0                	mov    %esi,%eax
  80142a:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  80142d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801434:	a8 01                	test   $0x1,%al
  801436:	0f 84 7a 01 00 00    	je     8015b6 <fork+0x20b>
			((uvpt[page_num] & PTE_P) == PTE_P)) {
  80143c:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  801443:	a8 01                	test   $0x1,%al
  801445:	0f 84 6b 01 00 00    	je     8015b6 <fork+0x20b>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	envid_t this_envid = thisenv->env_id;
  80144b:	a1 04 50 80 00       	mov    0x805004,%eax
  801450:	8b 40 48             	mov    0x48(%eax),%eax
  801453:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	if (uvpt[pn] & PTE_SHARE) {
  801456:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80145d:	f6 c4 04             	test   $0x4,%ah
  801460:	74 52                	je     8014b4 <fork+0x109>
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  801462:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801469:	25 07 0e 00 00       	and    $0xe07,%eax
  80146e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801472:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801476:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801479:	89 44 24 08          	mov    %eax,0x8(%esp)
  80147d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801481:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801484:	89 04 24             	mov    %eax,(%esp)
  801487:	e8 f9 fb ff ff       	call   801085 <sys_page_map>
  80148c:	85 c0                	test   %eax,%eax
  80148e:	0f 89 22 01 00 00    	jns    8015b6 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  801494:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801498:	c7 44 24 08 2b 33 80 	movl   $0x80332b,0x8(%esp)
  80149f:	00 
  8014a0:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  8014a7:	00 
  8014a8:	c7 04 24 0c 33 80 00 	movl   $0x80330c,(%esp)
  8014af:	e8 e8 f0 ff ff       	call   80059c <_panic>
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
  8014b4:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8014bb:	f6 c4 08             	test   $0x8,%ah
  8014be:	75 0f                	jne    8014cf <fork+0x124>
  8014c0:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8014c7:	a8 02                	test   $0x2,%al
  8014c9:	0f 84 99 00 00 00    	je     801568 <fork+0x1bd>
		if (uvpt[pn] & PTE_U)
  8014cf:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8014d6:	83 e0 04             	and    $0x4,%eax
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
  8014d9:	83 f8 01             	cmp    $0x1,%eax
  8014dc:	19 db                	sbb    %ebx,%ebx
  8014de:	83 e3 fc             	and    $0xfffffffc,%ebx
  8014e1:	81 c3 05 08 00 00    	add    $0x805,%ebx
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
		if (uvpt[pn] & PTE_U)
			perm |= PTE_U;

		// Map page COW, U and P in child
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), perm)) < 0)
  8014e7:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8014eb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8014ef:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8014f2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014f6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8014fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014fd:	89 04 24             	mov    %eax,(%esp)
  801500:	e8 80 fb ff ff       	call   801085 <sys_page_map>
  801505:	85 c0                	test   %eax,%eax
  801507:	79 20                	jns    801529 <fork+0x17e>
			panic("sys_page_map: %e\n", r);
  801509:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80150d:	c7 44 24 08 2b 33 80 	movl   $0x80332b,0x8(%esp)
  801514:	00 
  801515:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  80151c:	00 
  80151d:	c7 04 24 0c 33 80 00 	movl   $0x80330c,(%esp)
  801524:	e8 73 f0 ff ff       	call   80059c <_panic>

		// Map page COW, U and P in parent
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), this_envid, (void *) (pn*PGSIZE), perm)) < 0)
  801529:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80152d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801531:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801534:	89 44 24 08          	mov    %eax,0x8(%esp)
  801538:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80153c:	89 04 24             	mov    %eax,(%esp)
  80153f:	e8 41 fb ff ff       	call   801085 <sys_page_map>
  801544:	85 c0                	test   %eax,%eax
  801546:	79 6e                	jns    8015b6 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  801548:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80154c:	c7 44 24 08 2b 33 80 	movl   $0x80332b,0x8(%esp)
  801553:	00 
  801554:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  80155b:	00 
  80155c:	c7 04 24 0c 33 80 00 	movl   $0x80330c,(%esp)
  801563:	e8 34 f0 ff ff       	call   80059c <_panic>

	} else { // map pages that are present but not writable or COW with their original permissions
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  801568:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80156f:	25 07 0e 00 00       	and    $0xe07,%eax
  801574:	89 44 24 10          	mov    %eax,0x10(%esp)
  801578:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80157c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80157f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801583:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801587:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80158a:	89 04 24             	mov    %eax,(%esp)
  80158d:	e8 f3 fa ff ff       	call   801085 <sys_page_map>
  801592:	85 c0                	test   %eax,%eax
  801594:	79 20                	jns    8015b6 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  801596:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80159a:	c7 44 24 08 2b 33 80 	movl   $0x80332b,0x8(%esp)
  8015a1:	00 
  8015a2:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  8015a9:	00 
  8015aa:	c7 04 24 0c 33 80 00 	movl   $0x80330c,(%esp)
  8015b1:	e8 e6 ef ff ff       	call   80059c <_panic>
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
  8015b6:	46                   	inc    %esi
  8015b7:	81 c7 00 10 00 00    	add    $0x1000,%edi
  8015bd:	81 fe ff eb 0e 00    	cmp    $0xeebff,%esi
  8015c3:	0f 85 5f fe ff ff    	jne    801428 <fork+0x7d>
	}

	// Allocate exception stack space for child. The child can't do this themselves
	// because the mechanism by which it would is to run the pgfault handler, which
	// needs to run on the exception stack (catch 22).
	if ((r = sys_page_alloc(child_envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8015c9:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8015d0:	00 
  8015d1:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8015d8:	ee 
  8015d9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8015dc:	89 04 24             	mov    %eax,(%esp)
  8015df:	e8 4d fa ff ff       	call   801031 <sys_page_alloc>
  8015e4:	85 c0                	test   %eax,%eax
  8015e6:	79 20                	jns    801608 <fork+0x25d>
		panic("sys_page_alloc: %e\n", r);
  8015e8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015ec:	c7 44 24 08 17 33 80 	movl   $0x803317,0x8(%esp)
  8015f3:	00 
  8015f4:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  8015fb:	00 
  8015fc:	c7 04 24 0c 33 80 00 	movl   $0x80330c,(%esp)
  801603:	e8 94 ef ff ff       	call   80059c <_panic>

	// Set page fault handler for the child
	if ((r = sys_env_set_pgfault_upcall(child_envid, _pgfault_upcall)) < 0)
  801608:	c7 44 24 04 04 2a 80 	movl   $0x802a04,0x4(%esp)
  80160f:	00 
  801610:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801613:	89 04 24             	mov    %eax,(%esp)
  801616:	e8 b6 fb ff ff       	call   8011d1 <sys_env_set_pgfault_upcall>
  80161b:	85 c0                	test   %eax,%eax
  80161d:	79 20                	jns    80163f <fork+0x294>
		panic("sys_env_set_pgfault_upcall: %e\n", r);
  80161f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801623:	c7 44 24 08 ec 32 80 	movl   $0x8032ec,0x8(%esp)
  80162a:	00 
  80162b:	c7 44 24 04 a1 00 00 	movl   $0xa1,0x4(%esp)
  801632:	00 
  801633:	c7 04 24 0c 33 80 00 	movl   $0x80330c,(%esp)
  80163a:	e8 5d ef ff ff       	call   80059c <_panic>

	// Mark child environment as runnable
	if ((r = sys_env_set_status(child_envid, ENV_RUNNABLE)) < 0)
  80163f:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801646:	00 
  801647:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80164a:	89 04 24             	mov    %eax,(%esp)
  80164d:	e8 d9 fa ff ff       	call   80112b <sys_env_set_status>
  801652:	85 c0                	test   %eax,%eax
  801654:	79 20                	jns    801676 <fork+0x2cb>
		panic("sys_env_set_status: %e\n", r);
  801656:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80165a:	c7 44 24 08 4e 33 80 	movl   $0x80334e,0x8(%esp)
  801661:	00 
  801662:	c7 44 24 04 a5 00 00 	movl   $0xa5,0x4(%esp)
  801669:	00 
  80166a:	c7 04 24 0c 33 80 00 	movl   $0x80330c,(%esp)
  801671:	e8 26 ef ff ff       	call   80059c <_panic>

	return child_envid;
}
  801676:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801679:	83 c4 3c             	add    $0x3c,%esp
  80167c:	5b                   	pop    %ebx
  80167d:	5e                   	pop    %esi
  80167e:	5f                   	pop    %edi
  80167f:	5d                   	pop    %ebp
  801680:	c3                   	ret    

00801681 <sfork>:

// Challenge!
int
sfork(void)
{
  801681:	55                   	push   %ebp
  801682:	89 e5                	mov    %esp,%ebp
  801684:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801687:	c7 44 24 08 66 33 80 	movl   $0x803366,0x8(%esp)
  80168e:	00 
  80168f:	c7 44 24 04 ae 00 00 	movl   $0xae,0x4(%esp)
  801696:	00 
  801697:	c7 04 24 0c 33 80 00 	movl   $0x80330c,(%esp)
  80169e:	e8 f9 ee ff ff       	call   80059c <_panic>
	...

008016a4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8016a4:	55                   	push   %ebp
  8016a5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8016a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8016aa:	05 00 00 00 30       	add    $0x30000000,%eax
  8016af:	c1 e8 0c             	shr    $0xc,%eax
}
  8016b2:	5d                   	pop    %ebp
  8016b3:	c3                   	ret    

008016b4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8016b4:	55                   	push   %ebp
  8016b5:	89 e5                	mov    %esp,%ebp
  8016b7:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8016ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8016bd:	89 04 24             	mov    %eax,(%esp)
  8016c0:	e8 df ff ff ff       	call   8016a4 <fd2num>
  8016c5:	05 20 00 0d 00       	add    $0xd0020,%eax
  8016ca:	c1 e0 0c             	shl    $0xc,%eax
}
  8016cd:	c9                   	leave  
  8016ce:	c3                   	ret    

008016cf <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8016cf:	55                   	push   %ebp
  8016d0:	89 e5                	mov    %esp,%ebp
  8016d2:	53                   	push   %ebx
  8016d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8016d6:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8016db:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8016dd:	89 c2                	mov    %eax,%edx
  8016df:	c1 ea 16             	shr    $0x16,%edx
  8016e2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8016e9:	f6 c2 01             	test   $0x1,%dl
  8016ec:	74 11                	je     8016ff <fd_alloc+0x30>
  8016ee:	89 c2                	mov    %eax,%edx
  8016f0:	c1 ea 0c             	shr    $0xc,%edx
  8016f3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8016fa:	f6 c2 01             	test   $0x1,%dl
  8016fd:	75 09                	jne    801708 <fd_alloc+0x39>
			*fd_store = fd;
  8016ff:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801701:	b8 00 00 00 00       	mov    $0x0,%eax
  801706:	eb 17                	jmp    80171f <fd_alloc+0x50>
  801708:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80170d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801712:	75 c7                	jne    8016db <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801714:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80171a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80171f:	5b                   	pop    %ebx
  801720:	5d                   	pop    %ebp
  801721:	c3                   	ret    

00801722 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801722:	55                   	push   %ebp
  801723:	89 e5                	mov    %esp,%ebp
  801725:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801728:	83 f8 1f             	cmp    $0x1f,%eax
  80172b:	77 36                	ja     801763 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80172d:	05 00 00 0d 00       	add    $0xd0000,%eax
  801732:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801735:	89 c2                	mov    %eax,%edx
  801737:	c1 ea 16             	shr    $0x16,%edx
  80173a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801741:	f6 c2 01             	test   $0x1,%dl
  801744:	74 24                	je     80176a <fd_lookup+0x48>
  801746:	89 c2                	mov    %eax,%edx
  801748:	c1 ea 0c             	shr    $0xc,%edx
  80174b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801752:	f6 c2 01             	test   $0x1,%dl
  801755:	74 1a                	je     801771 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801757:	8b 55 0c             	mov    0xc(%ebp),%edx
  80175a:	89 02                	mov    %eax,(%edx)
	return 0;
  80175c:	b8 00 00 00 00       	mov    $0x0,%eax
  801761:	eb 13                	jmp    801776 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801763:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801768:	eb 0c                	jmp    801776 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80176a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80176f:	eb 05                	jmp    801776 <fd_lookup+0x54>
  801771:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801776:	5d                   	pop    %ebp
  801777:	c3                   	ret    

00801778 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801778:	55                   	push   %ebp
  801779:	89 e5                	mov    %esp,%ebp
  80177b:	53                   	push   %ebx
  80177c:	83 ec 14             	sub    $0x14,%esp
  80177f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801782:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801785:	ba 00 00 00 00       	mov    $0x0,%edx
  80178a:	eb 0e                	jmp    80179a <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  80178c:	39 08                	cmp    %ecx,(%eax)
  80178e:	75 09                	jne    801799 <dev_lookup+0x21>
			*dev = devtab[i];
  801790:	89 03                	mov    %eax,(%ebx)
			return 0;
  801792:	b8 00 00 00 00       	mov    $0x0,%eax
  801797:	eb 33                	jmp    8017cc <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801799:	42                   	inc    %edx
  80179a:	8b 04 95 f8 33 80 00 	mov    0x8033f8(,%edx,4),%eax
  8017a1:	85 c0                	test   %eax,%eax
  8017a3:	75 e7                	jne    80178c <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8017a5:	a1 04 50 80 00       	mov    0x805004,%eax
  8017aa:	8b 40 48             	mov    0x48(%eax),%eax
  8017ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b5:	c7 04 24 7c 33 80 00 	movl   $0x80337c,(%esp)
  8017bc:	e8 d3 ee ff ff       	call   800694 <cprintf>
	*dev = 0;
  8017c1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8017c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8017cc:	83 c4 14             	add    $0x14,%esp
  8017cf:	5b                   	pop    %ebx
  8017d0:	5d                   	pop    %ebp
  8017d1:	c3                   	ret    

008017d2 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8017d2:	55                   	push   %ebp
  8017d3:	89 e5                	mov    %esp,%ebp
  8017d5:	56                   	push   %esi
  8017d6:	53                   	push   %ebx
  8017d7:	83 ec 30             	sub    $0x30,%esp
  8017da:	8b 75 08             	mov    0x8(%ebp),%esi
  8017dd:	8a 45 0c             	mov    0xc(%ebp),%al
  8017e0:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8017e3:	89 34 24             	mov    %esi,(%esp)
  8017e6:	e8 b9 fe ff ff       	call   8016a4 <fd2num>
  8017eb:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8017ee:	89 54 24 04          	mov    %edx,0x4(%esp)
  8017f2:	89 04 24             	mov    %eax,(%esp)
  8017f5:	e8 28 ff ff ff       	call   801722 <fd_lookup>
  8017fa:	89 c3                	mov    %eax,%ebx
  8017fc:	85 c0                	test   %eax,%eax
  8017fe:	78 05                	js     801805 <fd_close+0x33>
	    || fd != fd2)
  801800:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801803:	74 0d                	je     801812 <fd_close+0x40>
		return (must_exist ? r : 0);
  801805:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801809:	75 46                	jne    801851 <fd_close+0x7f>
  80180b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801810:	eb 3f                	jmp    801851 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801812:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801815:	89 44 24 04          	mov    %eax,0x4(%esp)
  801819:	8b 06                	mov    (%esi),%eax
  80181b:	89 04 24             	mov    %eax,(%esp)
  80181e:	e8 55 ff ff ff       	call   801778 <dev_lookup>
  801823:	89 c3                	mov    %eax,%ebx
  801825:	85 c0                	test   %eax,%eax
  801827:	78 18                	js     801841 <fd_close+0x6f>
		if (dev->dev_close)
  801829:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80182c:	8b 40 10             	mov    0x10(%eax),%eax
  80182f:	85 c0                	test   %eax,%eax
  801831:	74 09                	je     80183c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801833:	89 34 24             	mov    %esi,(%esp)
  801836:	ff d0                	call   *%eax
  801838:	89 c3                	mov    %eax,%ebx
  80183a:	eb 05                	jmp    801841 <fd_close+0x6f>
		else
			r = 0;
  80183c:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801841:	89 74 24 04          	mov    %esi,0x4(%esp)
  801845:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80184c:	e8 87 f8 ff ff       	call   8010d8 <sys_page_unmap>
	return r;
}
  801851:	89 d8                	mov    %ebx,%eax
  801853:	83 c4 30             	add    $0x30,%esp
  801856:	5b                   	pop    %ebx
  801857:	5e                   	pop    %esi
  801858:	5d                   	pop    %ebp
  801859:	c3                   	ret    

0080185a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80185a:	55                   	push   %ebp
  80185b:	89 e5                	mov    %esp,%ebp
  80185d:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801860:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801863:	89 44 24 04          	mov    %eax,0x4(%esp)
  801867:	8b 45 08             	mov    0x8(%ebp),%eax
  80186a:	89 04 24             	mov    %eax,(%esp)
  80186d:	e8 b0 fe ff ff       	call   801722 <fd_lookup>
  801872:	85 c0                	test   %eax,%eax
  801874:	78 13                	js     801889 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801876:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80187d:	00 
  80187e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801881:	89 04 24             	mov    %eax,(%esp)
  801884:	e8 49 ff ff ff       	call   8017d2 <fd_close>
}
  801889:	c9                   	leave  
  80188a:	c3                   	ret    

0080188b <close_all>:

void
close_all(void)
{
  80188b:	55                   	push   %ebp
  80188c:	89 e5                	mov    %esp,%ebp
  80188e:	53                   	push   %ebx
  80188f:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801892:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801897:	89 1c 24             	mov    %ebx,(%esp)
  80189a:	e8 bb ff ff ff       	call   80185a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80189f:	43                   	inc    %ebx
  8018a0:	83 fb 20             	cmp    $0x20,%ebx
  8018a3:	75 f2                	jne    801897 <close_all+0xc>
		close(i);
}
  8018a5:	83 c4 14             	add    $0x14,%esp
  8018a8:	5b                   	pop    %ebx
  8018a9:	5d                   	pop    %ebp
  8018aa:	c3                   	ret    

008018ab <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8018ab:	55                   	push   %ebp
  8018ac:	89 e5                	mov    %esp,%ebp
  8018ae:	57                   	push   %edi
  8018af:	56                   	push   %esi
  8018b0:	53                   	push   %ebx
  8018b1:	83 ec 4c             	sub    $0x4c,%esp
  8018b4:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8018b7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8018ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018be:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c1:	89 04 24             	mov    %eax,(%esp)
  8018c4:	e8 59 fe ff ff       	call   801722 <fd_lookup>
  8018c9:	89 c3                	mov    %eax,%ebx
  8018cb:	85 c0                	test   %eax,%eax
  8018cd:	0f 88 e1 00 00 00    	js     8019b4 <dup+0x109>
		return r;
	close(newfdnum);
  8018d3:	89 3c 24             	mov    %edi,(%esp)
  8018d6:	e8 7f ff ff ff       	call   80185a <close>

	newfd = INDEX2FD(newfdnum);
  8018db:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8018e1:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8018e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018e7:	89 04 24             	mov    %eax,(%esp)
  8018ea:	e8 c5 fd ff ff       	call   8016b4 <fd2data>
  8018ef:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8018f1:	89 34 24             	mov    %esi,(%esp)
  8018f4:	e8 bb fd ff ff       	call   8016b4 <fd2data>
  8018f9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8018fc:	89 d8                	mov    %ebx,%eax
  8018fe:	c1 e8 16             	shr    $0x16,%eax
  801901:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801908:	a8 01                	test   $0x1,%al
  80190a:	74 46                	je     801952 <dup+0xa7>
  80190c:	89 d8                	mov    %ebx,%eax
  80190e:	c1 e8 0c             	shr    $0xc,%eax
  801911:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801918:	f6 c2 01             	test   $0x1,%dl
  80191b:	74 35                	je     801952 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80191d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801924:	25 07 0e 00 00       	and    $0xe07,%eax
  801929:	89 44 24 10          	mov    %eax,0x10(%esp)
  80192d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801930:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801934:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80193b:	00 
  80193c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801940:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801947:	e8 39 f7 ff ff       	call   801085 <sys_page_map>
  80194c:	89 c3                	mov    %eax,%ebx
  80194e:	85 c0                	test   %eax,%eax
  801950:	78 3b                	js     80198d <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801952:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801955:	89 c2                	mov    %eax,%edx
  801957:	c1 ea 0c             	shr    $0xc,%edx
  80195a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801961:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801967:	89 54 24 10          	mov    %edx,0x10(%esp)
  80196b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80196f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801976:	00 
  801977:	89 44 24 04          	mov    %eax,0x4(%esp)
  80197b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801982:	e8 fe f6 ff ff       	call   801085 <sys_page_map>
  801987:	89 c3                	mov    %eax,%ebx
  801989:	85 c0                	test   %eax,%eax
  80198b:	79 25                	jns    8019b2 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80198d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801991:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801998:	e8 3b f7 ff ff       	call   8010d8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80199d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8019a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019ab:	e8 28 f7 ff ff       	call   8010d8 <sys_page_unmap>
	return r;
  8019b0:	eb 02                	jmp    8019b4 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8019b2:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8019b4:	89 d8                	mov    %ebx,%eax
  8019b6:	83 c4 4c             	add    $0x4c,%esp
  8019b9:	5b                   	pop    %ebx
  8019ba:	5e                   	pop    %esi
  8019bb:	5f                   	pop    %edi
  8019bc:	5d                   	pop    %ebp
  8019bd:	c3                   	ret    

008019be <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8019be:	55                   	push   %ebp
  8019bf:	89 e5                	mov    %esp,%ebp
  8019c1:	53                   	push   %ebx
  8019c2:	83 ec 24             	sub    $0x24,%esp
  8019c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019cf:	89 1c 24             	mov    %ebx,(%esp)
  8019d2:	e8 4b fd ff ff       	call   801722 <fd_lookup>
  8019d7:	85 c0                	test   %eax,%eax
  8019d9:	78 6d                	js     801a48 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019e5:	8b 00                	mov    (%eax),%eax
  8019e7:	89 04 24             	mov    %eax,(%esp)
  8019ea:	e8 89 fd ff ff       	call   801778 <dev_lookup>
  8019ef:	85 c0                	test   %eax,%eax
  8019f1:	78 55                	js     801a48 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8019f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019f6:	8b 50 08             	mov    0x8(%eax),%edx
  8019f9:	83 e2 03             	and    $0x3,%edx
  8019fc:	83 fa 01             	cmp    $0x1,%edx
  8019ff:	75 23                	jne    801a24 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801a01:	a1 04 50 80 00       	mov    0x805004,%eax
  801a06:	8b 40 48             	mov    0x48(%eax),%eax
  801a09:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a11:	c7 04 24 bd 33 80 00 	movl   $0x8033bd,(%esp)
  801a18:	e8 77 ec ff ff       	call   800694 <cprintf>
		return -E_INVAL;
  801a1d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a22:	eb 24                	jmp    801a48 <read+0x8a>
	}
	if (!dev->dev_read)
  801a24:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a27:	8b 52 08             	mov    0x8(%edx),%edx
  801a2a:	85 d2                	test   %edx,%edx
  801a2c:	74 15                	je     801a43 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801a2e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801a31:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801a35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a38:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801a3c:	89 04 24             	mov    %eax,(%esp)
  801a3f:	ff d2                	call   *%edx
  801a41:	eb 05                	jmp    801a48 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801a43:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801a48:	83 c4 24             	add    $0x24,%esp
  801a4b:	5b                   	pop    %ebx
  801a4c:	5d                   	pop    %ebp
  801a4d:	c3                   	ret    

00801a4e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801a4e:	55                   	push   %ebp
  801a4f:	89 e5                	mov    %esp,%ebp
  801a51:	57                   	push   %edi
  801a52:	56                   	push   %esi
  801a53:	53                   	push   %ebx
  801a54:	83 ec 1c             	sub    $0x1c,%esp
  801a57:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a5a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801a5d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a62:	eb 23                	jmp    801a87 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801a64:	89 f0                	mov    %esi,%eax
  801a66:	29 d8                	sub    %ebx,%eax
  801a68:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a6f:	01 d8                	add    %ebx,%eax
  801a71:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a75:	89 3c 24             	mov    %edi,(%esp)
  801a78:	e8 41 ff ff ff       	call   8019be <read>
		if (m < 0)
  801a7d:	85 c0                	test   %eax,%eax
  801a7f:	78 10                	js     801a91 <readn+0x43>
			return m;
		if (m == 0)
  801a81:	85 c0                	test   %eax,%eax
  801a83:	74 0a                	je     801a8f <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801a85:	01 c3                	add    %eax,%ebx
  801a87:	39 f3                	cmp    %esi,%ebx
  801a89:	72 d9                	jb     801a64 <readn+0x16>
  801a8b:	89 d8                	mov    %ebx,%eax
  801a8d:	eb 02                	jmp    801a91 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801a8f:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801a91:	83 c4 1c             	add    $0x1c,%esp
  801a94:	5b                   	pop    %ebx
  801a95:	5e                   	pop    %esi
  801a96:	5f                   	pop    %edi
  801a97:	5d                   	pop    %ebp
  801a98:	c3                   	ret    

00801a99 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801a99:	55                   	push   %ebp
  801a9a:	89 e5                	mov    %esp,%ebp
  801a9c:	53                   	push   %ebx
  801a9d:	83 ec 24             	sub    $0x24,%esp
  801aa0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801aa3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801aa6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aaa:	89 1c 24             	mov    %ebx,(%esp)
  801aad:	e8 70 fc ff ff       	call   801722 <fd_lookup>
  801ab2:	85 c0                	test   %eax,%eax
  801ab4:	78 68                	js     801b1e <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ab6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ab9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801abd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ac0:	8b 00                	mov    (%eax),%eax
  801ac2:	89 04 24             	mov    %eax,(%esp)
  801ac5:	e8 ae fc ff ff       	call   801778 <dev_lookup>
  801aca:	85 c0                	test   %eax,%eax
  801acc:	78 50                	js     801b1e <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801ace:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ad1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801ad5:	75 23                	jne    801afa <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801ad7:	a1 04 50 80 00       	mov    0x805004,%eax
  801adc:	8b 40 48             	mov    0x48(%eax),%eax
  801adf:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ae3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ae7:	c7 04 24 d9 33 80 00 	movl   $0x8033d9,(%esp)
  801aee:	e8 a1 eb ff ff       	call   800694 <cprintf>
		return -E_INVAL;
  801af3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801af8:	eb 24                	jmp    801b1e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801afa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801afd:	8b 52 0c             	mov    0xc(%edx),%edx
  801b00:	85 d2                	test   %edx,%edx
  801b02:	74 15                	je     801b19 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801b04:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801b07:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801b0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b0e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801b12:	89 04 24             	mov    %eax,(%esp)
  801b15:	ff d2                	call   *%edx
  801b17:	eb 05                	jmp    801b1e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801b19:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801b1e:	83 c4 24             	add    $0x24,%esp
  801b21:	5b                   	pop    %ebx
  801b22:	5d                   	pop    %ebp
  801b23:	c3                   	ret    

00801b24 <seek>:

int
seek(int fdnum, off_t offset)
{
  801b24:	55                   	push   %ebp
  801b25:	89 e5                	mov    %esp,%ebp
  801b27:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b2a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801b2d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b31:	8b 45 08             	mov    0x8(%ebp),%eax
  801b34:	89 04 24             	mov    %eax,(%esp)
  801b37:	e8 e6 fb ff ff       	call   801722 <fd_lookup>
  801b3c:	85 c0                	test   %eax,%eax
  801b3e:	78 0e                	js     801b4e <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801b40:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801b43:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b46:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801b49:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b4e:	c9                   	leave  
  801b4f:	c3                   	ret    

00801b50 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801b50:	55                   	push   %ebp
  801b51:	89 e5                	mov    %esp,%ebp
  801b53:	53                   	push   %ebx
  801b54:	83 ec 24             	sub    $0x24,%esp
  801b57:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b5a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b5d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b61:	89 1c 24             	mov    %ebx,(%esp)
  801b64:	e8 b9 fb ff ff       	call   801722 <fd_lookup>
  801b69:	85 c0                	test   %eax,%eax
  801b6b:	78 61                	js     801bce <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b6d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b70:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b74:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b77:	8b 00                	mov    (%eax),%eax
  801b79:	89 04 24             	mov    %eax,(%esp)
  801b7c:	e8 f7 fb ff ff       	call   801778 <dev_lookup>
  801b81:	85 c0                	test   %eax,%eax
  801b83:	78 49                	js     801bce <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801b85:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b88:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801b8c:	75 23                	jne    801bb1 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801b8e:	a1 04 50 80 00       	mov    0x805004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801b93:	8b 40 48             	mov    0x48(%eax),%eax
  801b96:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b9a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b9e:	c7 04 24 9c 33 80 00 	movl   $0x80339c,(%esp)
  801ba5:	e8 ea ea ff ff       	call   800694 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801baa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801baf:	eb 1d                	jmp    801bce <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801bb1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bb4:	8b 52 18             	mov    0x18(%edx),%edx
  801bb7:	85 d2                	test   %edx,%edx
  801bb9:	74 0e                	je     801bc9 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801bbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bbe:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801bc2:	89 04 24             	mov    %eax,(%esp)
  801bc5:	ff d2                	call   *%edx
  801bc7:	eb 05                	jmp    801bce <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801bc9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801bce:	83 c4 24             	add    $0x24,%esp
  801bd1:	5b                   	pop    %ebx
  801bd2:	5d                   	pop    %ebp
  801bd3:	c3                   	ret    

00801bd4 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801bd4:	55                   	push   %ebp
  801bd5:	89 e5                	mov    %esp,%ebp
  801bd7:	53                   	push   %ebx
  801bd8:	83 ec 24             	sub    $0x24,%esp
  801bdb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801bde:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801be1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801be5:	8b 45 08             	mov    0x8(%ebp),%eax
  801be8:	89 04 24             	mov    %eax,(%esp)
  801beb:	e8 32 fb ff ff       	call   801722 <fd_lookup>
  801bf0:	85 c0                	test   %eax,%eax
  801bf2:	78 52                	js     801c46 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801bf4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bf7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bfe:	8b 00                	mov    (%eax),%eax
  801c00:	89 04 24             	mov    %eax,(%esp)
  801c03:	e8 70 fb ff ff       	call   801778 <dev_lookup>
  801c08:	85 c0                	test   %eax,%eax
  801c0a:	78 3a                	js     801c46 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801c0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c0f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801c13:	74 2c                	je     801c41 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801c15:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801c18:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801c1f:	00 00 00 
	stat->st_isdir = 0;
  801c22:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c29:	00 00 00 
	stat->st_dev = dev;
  801c2c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801c32:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c36:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c39:	89 14 24             	mov    %edx,(%esp)
  801c3c:	ff 50 14             	call   *0x14(%eax)
  801c3f:	eb 05                	jmp    801c46 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801c41:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801c46:	83 c4 24             	add    $0x24,%esp
  801c49:	5b                   	pop    %ebx
  801c4a:	5d                   	pop    %ebp
  801c4b:	c3                   	ret    

00801c4c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801c4c:	55                   	push   %ebp
  801c4d:	89 e5                	mov    %esp,%ebp
  801c4f:	56                   	push   %esi
  801c50:	53                   	push   %ebx
  801c51:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801c54:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c5b:	00 
  801c5c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c5f:	89 04 24             	mov    %eax,(%esp)
  801c62:	e8 2d 02 00 00       	call   801e94 <open>
  801c67:	89 c3                	mov    %eax,%ebx
  801c69:	85 c0                	test   %eax,%eax
  801c6b:	78 1b                	js     801c88 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801c6d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c70:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c74:	89 1c 24             	mov    %ebx,(%esp)
  801c77:	e8 58 ff ff ff       	call   801bd4 <fstat>
  801c7c:	89 c6                	mov    %eax,%esi
	close(fd);
  801c7e:	89 1c 24             	mov    %ebx,(%esp)
  801c81:	e8 d4 fb ff ff       	call   80185a <close>
	return r;
  801c86:	89 f3                	mov    %esi,%ebx
}
  801c88:	89 d8                	mov    %ebx,%eax
  801c8a:	83 c4 10             	add    $0x10,%esp
  801c8d:	5b                   	pop    %ebx
  801c8e:	5e                   	pop    %esi
  801c8f:	5d                   	pop    %ebp
  801c90:	c3                   	ret    
  801c91:	00 00                	add    %al,(%eax)
	...

00801c94 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801c94:	55                   	push   %ebp
  801c95:	89 e5                	mov    %esp,%ebp
  801c97:	56                   	push   %esi
  801c98:	53                   	push   %ebx
  801c99:	83 ec 10             	sub    $0x10,%esp
  801c9c:	89 c3                	mov    %eax,%ebx
  801c9e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801ca0:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801ca7:	75 11                	jne    801cba <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801ca9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801cb0:	e8 4a 0e 00 00       	call   802aff <ipc_find_env>
  801cb5:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801cba:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801cc1:	00 
  801cc2:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801cc9:	00 
  801cca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cce:	a1 00 50 80 00       	mov    0x805000,%eax
  801cd3:	89 04 24             	mov    %eax,(%esp)
  801cd6:	e8 b6 0d 00 00       	call   802a91 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801cdb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ce2:	00 
  801ce3:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ce7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cee:	e8 35 0d 00 00       	call   802a28 <ipc_recv>
}
  801cf3:	83 c4 10             	add    $0x10,%esp
  801cf6:	5b                   	pop    %ebx
  801cf7:	5e                   	pop    %esi
  801cf8:	5d                   	pop    %ebp
  801cf9:	c3                   	ret    

00801cfa <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801cfa:	55                   	push   %ebp
  801cfb:	89 e5                	mov    %esp,%ebp
  801cfd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801d00:	8b 45 08             	mov    0x8(%ebp),%eax
  801d03:	8b 40 0c             	mov    0xc(%eax),%eax
  801d06:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801d0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d0e:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801d13:	ba 00 00 00 00       	mov    $0x0,%edx
  801d18:	b8 02 00 00 00       	mov    $0x2,%eax
  801d1d:	e8 72 ff ff ff       	call   801c94 <fsipc>
}
  801d22:	c9                   	leave  
  801d23:	c3                   	ret    

00801d24 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801d24:	55                   	push   %ebp
  801d25:	89 e5                	mov    %esp,%ebp
  801d27:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801d2a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d2d:	8b 40 0c             	mov    0xc(%eax),%eax
  801d30:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801d35:	ba 00 00 00 00       	mov    $0x0,%edx
  801d3a:	b8 06 00 00 00       	mov    $0x6,%eax
  801d3f:	e8 50 ff ff ff       	call   801c94 <fsipc>
}
  801d44:	c9                   	leave  
  801d45:	c3                   	ret    

00801d46 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801d46:	55                   	push   %ebp
  801d47:	89 e5                	mov    %esp,%ebp
  801d49:	53                   	push   %ebx
  801d4a:	83 ec 14             	sub    $0x14,%esp
  801d4d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801d50:	8b 45 08             	mov    0x8(%ebp),%eax
  801d53:	8b 40 0c             	mov    0xc(%eax),%eax
  801d56:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801d5b:	ba 00 00 00 00       	mov    $0x0,%edx
  801d60:	b8 05 00 00 00       	mov    $0x5,%eax
  801d65:	e8 2a ff ff ff       	call   801c94 <fsipc>
  801d6a:	85 c0                	test   %eax,%eax
  801d6c:	78 2b                	js     801d99 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801d6e:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801d75:	00 
  801d76:	89 1c 24             	mov    %ebx,(%esp)
  801d79:	e8 c1 ee ff ff       	call   800c3f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801d7e:	a1 80 60 80 00       	mov    0x806080,%eax
  801d83:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801d89:	a1 84 60 80 00       	mov    0x806084,%eax
  801d8e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801d94:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d99:	83 c4 14             	add    $0x14,%esp
  801d9c:	5b                   	pop    %ebx
  801d9d:	5d                   	pop    %ebp
  801d9e:	c3                   	ret    

00801d9f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801d9f:	55                   	push   %ebp
  801da0:	89 e5                	mov    %esp,%ebp
  801da2:	83 ec 18             	sub    $0x18,%esp
  801da5:	8b 55 10             	mov    0x10(%ebp),%edx
  801da8:	89 d0                	mov    %edx,%eax
  801daa:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  801db0:	76 05                	jbe    801db7 <devfile_write+0x18>
  801db2:	b8 00 10 00 00       	mov    $0x1000,%eax
	//panic("devfile_write not implemented");
	int r;
	//uint32_t maxsize = BLKSIZE - sizeof(int) - sizeof(size_t);	
	if (n > BLKSIZE)
		n = BLKSIZE;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801db7:	8b 55 08             	mov    0x8(%ebp),%edx
  801dba:	8b 52 0c             	mov    0xc(%edx),%edx
  801dbd:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801dc3:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801dc8:	89 44 24 08          	mov    %eax,0x8(%esp)
  801dcc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dcf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dd3:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  801dda:	e8 d9 ef ff ff       	call   800db8 <memmove>
	 
	return fsipc(FSREQ_WRITE, NULL);
  801ddf:	ba 00 00 00 00       	mov    $0x0,%edx
  801de4:	b8 04 00 00 00       	mov    $0x4,%eax
  801de9:	e8 a6 fe ff ff       	call   801c94 <fsipc>
}
  801dee:	c9                   	leave  
  801def:	c3                   	ret    

00801df0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801df0:	55                   	push   %ebp
  801df1:	89 e5                	mov    %esp,%ebp
  801df3:	56                   	push   %esi
  801df4:	53                   	push   %ebx
  801df5:	83 ec 10             	sub    $0x10,%esp
  801df8:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801dfb:	8b 45 08             	mov    0x8(%ebp),%eax
  801dfe:	8b 40 0c             	mov    0xc(%eax),%eax
  801e01:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801e06:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801e0c:	ba 00 00 00 00       	mov    $0x0,%edx
  801e11:	b8 03 00 00 00       	mov    $0x3,%eax
  801e16:	e8 79 fe ff ff       	call   801c94 <fsipc>
  801e1b:	89 c3                	mov    %eax,%ebx
  801e1d:	85 c0                	test   %eax,%eax
  801e1f:	78 6a                	js     801e8b <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801e21:	39 c6                	cmp    %eax,%esi
  801e23:	73 24                	jae    801e49 <devfile_read+0x59>
  801e25:	c7 44 24 0c 08 34 80 	movl   $0x803408,0xc(%esp)
  801e2c:	00 
  801e2d:	c7 44 24 08 0f 34 80 	movl   $0x80340f,0x8(%esp)
  801e34:	00 
  801e35:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801e3c:	00 
  801e3d:	c7 04 24 24 34 80 00 	movl   $0x803424,(%esp)
  801e44:	e8 53 e7 ff ff       	call   80059c <_panic>
	assert(r <= PGSIZE);
  801e49:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801e4e:	7e 24                	jle    801e74 <devfile_read+0x84>
  801e50:	c7 44 24 0c 2f 34 80 	movl   $0x80342f,0xc(%esp)
  801e57:	00 
  801e58:	c7 44 24 08 0f 34 80 	movl   $0x80340f,0x8(%esp)
  801e5f:	00 
  801e60:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801e67:	00 
  801e68:	c7 04 24 24 34 80 00 	movl   $0x803424,(%esp)
  801e6f:	e8 28 e7 ff ff       	call   80059c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801e74:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e78:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801e7f:	00 
  801e80:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e83:	89 04 24             	mov    %eax,(%esp)
  801e86:	e8 2d ef ff ff       	call   800db8 <memmove>
	return r;
}
  801e8b:	89 d8                	mov    %ebx,%eax
  801e8d:	83 c4 10             	add    $0x10,%esp
  801e90:	5b                   	pop    %ebx
  801e91:	5e                   	pop    %esi
  801e92:	5d                   	pop    %ebp
  801e93:	c3                   	ret    

00801e94 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801e94:	55                   	push   %ebp
  801e95:	89 e5                	mov    %esp,%ebp
  801e97:	56                   	push   %esi
  801e98:	53                   	push   %ebx
  801e99:	83 ec 20             	sub    $0x20,%esp
  801e9c:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801e9f:	89 34 24             	mov    %esi,(%esp)
  801ea2:	e8 65 ed ff ff       	call   800c0c <strlen>
  801ea7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801eac:	7f 60                	jg     801f0e <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801eae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eb1:	89 04 24             	mov    %eax,(%esp)
  801eb4:	e8 16 f8 ff ff       	call   8016cf <fd_alloc>
  801eb9:	89 c3                	mov    %eax,%ebx
  801ebb:	85 c0                	test   %eax,%eax
  801ebd:	78 54                	js     801f13 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801ebf:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ec3:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801eca:	e8 70 ed ff ff       	call   800c3f <strcpy>
	fsipcbuf.open.req_omode = mode;
  801ecf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ed2:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801ed7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801eda:	b8 01 00 00 00       	mov    $0x1,%eax
  801edf:	e8 b0 fd ff ff       	call   801c94 <fsipc>
  801ee4:	89 c3                	mov    %eax,%ebx
  801ee6:	85 c0                	test   %eax,%eax
  801ee8:	79 15                	jns    801eff <open+0x6b>
		fd_close(fd, 0);
  801eea:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801ef1:	00 
  801ef2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef5:	89 04 24             	mov    %eax,(%esp)
  801ef8:	e8 d5 f8 ff ff       	call   8017d2 <fd_close>
		return r;
  801efd:	eb 14                	jmp    801f13 <open+0x7f>
	}

	return fd2num(fd);
  801eff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f02:	89 04 24             	mov    %eax,(%esp)
  801f05:	e8 9a f7 ff ff       	call   8016a4 <fd2num>
  801f0a:	89 c3                	mov    %eax,%ebx
  801f0c:	eb 05                	jmp    801f13 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801f0e:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801f13:	89 d8                	mov    %ebx,%eax
  801f15:	83 c4 20             	add    $0x20,%esp
  801f18:	5b                   	pop    %ebx
  801f19:	5e                   	pop    %esi
  801f1a:	5d                   	pop    %ebp
  801f1b:	c3                   	ret    

00801f1c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801f1c:	55                   	push   %ebp
  801f1d:	89 e5                	mov    %esp,%ebp
  801f1f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801f22:	ba 00 00 00 00       	mov    $0x0,%edx
  801f27:	b8 08 00 00 00       	mov    $0x8,%eax
  801f2c:	e8 63 fd ff ff       	call   801c94 <fsipc>
}
  801f31:	c9                   	leave  
  801f32:	c3                   	ret    
	...

00801f34 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801f34:	55                   	push   %ebp
  801f35:	89 e5                	mov    %esp,%ebp
  801f37:	57                   	push   %edi
  801f38:	56                   	push   %esi
  801f39:	53                   	push   %ebx
  801f3a:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801f40:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801f47:	00 
  801f48:	8b 45 08             	mov    0x8(%ebp),%eax
  801f4b:	89 04 24             	mov    %eax,(%esp)
  801f4e:	e8 41 ff ff ff       	call   801e94 <open>
  801f53:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
  801f59:	85 c0                	test   %eax,%eax
  801f5b:	0f 88 8c 05 00 00    	js     8024ed <spawn+0x5b9>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801f61:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  801f68:	00 
  801f69:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801f6f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f73:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801f79:	89 04 24             	mov    %eax,(%esp)
  801f7c:	e8 cd fa ff ff       	call   801a4e <readn>
  801f81:	3d 00 02 00 00       	cmp    $0x200,%eax
  801f86:	75 0c                	jne    801f94 <spawn+0x60>
	    || elf->e_magic != ELF_MAGIC) {
  801f88:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801f8f:	45 4c 46 
  801f92:	74 3b                	je     801fcf <spawn+0x9b>
		close(fd);
  801f94:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801f9a:	89 04 24             	mov    %eax,(%esp)
  801f9d:	e8 b8 f8 ff ff       	call   80185a <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801fa2:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  801fa9:	46 
  801faa:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  801fb0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fb4:	c7 04 24 3b 34 80 00 	movl   $0x80343b,(%esp)
  801fbb:	e8 d4 e6 ff ff       	call   800694 <cprintf>
		return -E_NOT_EXEC;
  801fc0:	c7 85 88 fd ff ff f2 	movl   $0xfffffff2,-0x278(%ebp)
  801fc7:	ff ff ff 
  801fca:	e9 2a 05 00 00       	jmp    8024f9 <spawn+0x5c5>
  801fcf:	ba 07 00 00 00       	mov    $0x7,%edx
  801fd4:	89 d0                	mov    %edx,%eax
  801fd6:	cd 30                	int    $0x30
  801fd8:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801fde:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801fe4:	85 c0                	test   %eax,%eax
  801fe6:	0f 88 0d 05 00 00    	js     8024f9 <spawn+0x5c5>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801fec:	25 ff 03 00 00       	and    $0x3ff,%eax
  801ff1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801ff8:	c1 e0 07             	shl    $0x7,%eax
  801ffb:	29 d0                	sub    %edx,%eax
  801ffd:	8d b0 00 00 c0 ee    	lea    -0x11400000(%eax),%esi
  802003:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  802009:	b9 11 00 00 00       	mov    $0x11,%ecx
  80200e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  802010:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  802016:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80201c:	be 00 00 00 00       	mov    $0x0,%esi
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  802021:	bb 00 00 00 00       	mov    $0x0,%ebx
  802026:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802029:	eb 0d                	jmp    802038 <spawn+0x104>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  80202b:	89 04 24             	mov    %eax,(%esp)
  80202e:	e8 d9 eb ff ff       	call   800c0c <strlen>
  802033:	8d 5c 18 01          	lea    0x1(%eax,%ebx,1),%ebx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802037:	46                   	inc    %esi
  802038:	89 f2                	mov    %esi,%edx
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  80203a:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802041:	8b 04 b7             	mov    (%edi,%esi,4),%eax
  802044:	85 c0                	test   %eax,%eax
  802046:	75 e3                	jne    80202b <spawn+0xf7>
  802048:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
  80204e:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  802054:	bf 00 10 40 00       	mov    $0x401000,%edi
  802059:	29 df                	sub    %ebx,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  80205b:	89 f8                	mov    %edi,%eax
  80205d:	83 e0 fc             	and    $0xfffffffc,%eax
  802060:	f7 d2                	not    %edx
  802062:	8d 14 90             	lea    (%eax,%edx,4),%edx
  802065:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  80206b:	89 d0                	mov    %edx,%eax
  80206d:	83 e8 08             	sub    $0x8,%eax
  802070:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  802075:	0f 86 8f 04 00 00    	jbe    80250a <spawn+0x5d6>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80207b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802082:	00 
  802083:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80208a:	00 
  80208b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802092:	e8 9a ef ff ff       	call   801031 <sys_page_alloc>
  802097:	85 c0                	test   %eax,%eax
  802099:	0f 88 70 04 00 00    	js     80250f <spawn+0x5db>
  80209f:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020a4:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  8020aa:	8b 75 0c             	mov    0xc(%ebp),%esi
  8020ad:	eb 2e                	jmp    8020dd <spawn+0x1a9>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  8020af:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8020b5:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  8020bb:	89 04 9a             	mov    %eax,(%edx,%ebx,4)
		strcpy(string_store, argv[i]);
  8020be:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  8020c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020c5:	89 3c 24             	mov    %edi,(%esp)
  8020c8:	e8 72 eb ff ff       	call   800c3f <strcpy>
		string_store += strlen(argv[i]) + 1;
  8020cd:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  8020d0:	89 04 24             	mov    %eax,(%esp)
  8020d3:	e8 34 eb ff ff       	call   800c0c <strlen>
  8020d8:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8020dc:	43                   	inc    %ebx
  8020dd:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  8020e3:	7c ca                	jl     8020af <spawn+0x17b>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  8020e5:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  8020eb:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  8020f1:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  8020f8:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  8020fe:	74 24                	je     802124 <spawn+0x1f0>
  802100:	c7 44 24 0c c8 34 80 	movl   $0x8034c8,0xc(%esp)
  802107:	00 
  802108:	c7 44 24 08 0f 34 80 	movl   $0x80340f,0x8(%esp)
  80210f:	00 
  802110:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
  802117:	00 
  802118:	c7 04 24 55 34 80 00 	movl   $0x803455,(%esp)
  80211f:	e8 78 e4 ff ff       	call   80059c <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  802124:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  80212a:	2d 00 30 80 11       	sub    $0x11803000,%eax
  80212f:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  802135:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  802138:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  80213e:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  802141:	89 d0                	mov    %edx,%eax
  802143:	2d 08 30 80 11       	sub    $0x11803008,%eax
  802148:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  80214e:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  802155:	00 
  802156:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  80215d:	ee 
  80215e:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802164:	89 44 24 08          	mov    %eax,0x8(%esp)
  802168:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80216f:	00 
  802170:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802177:	e8 09 ef ff ff       	call   801085 <sys_page_map>
  80217c:	89 c3                	mov    %eax,%ebx
  80217e:	85 c0                	test   %eax,%eax
  802180:	78 1a                	js     80219c <spawn+0x268>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  802182:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802189:	00 
  80218a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802191:	e8 42 ef ff ff       	call   8010d8 <sys_page_unmap>
  802196:	89 c3                	mov    %eax,%ebx
  802198:	85 c0                	test   %eax,%eax
  80219a:	79 1f                	jns    8021bb <spawn+0x287>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  80219c:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8021a3:	00 
  8021a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021ab:	e8 28 ef ff ff       	call   8010d8 <sys_page_unmap>
	return r;
  8021b0:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  8021b6:	e9 3e 03 00 00       	jmp    8024f9 <spawn+0x5c5>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8021bb:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  8021c1:	03 95 04 fe ff ff    	add    -0x1fc(%ebp),%edx
  8021c7:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8021cd:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  8021d4:	00 00 00 
  8021d7:	e9 bb 01 00 00       	jmp    802397 <spawn+0x463>
		if (ph->p_type != ELF_PROG_LOAD)
  8021dc:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8021e2:	83 38 01             	cmpl   $0x1,(%eax)
  8021e5:	0f 85 9f 01 00 00    	jne    80238a <spawn+0x456>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  8021eb:	89 c2                	mov    %eax,%edx
  8021ed:	8b 40 18             	mov    0x18(%eax),%eax
  8021f0:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  8021f3:	83 f8 01             	cmp    $0x1,%eax
  8021f6:	19 c0                	sbb    %eax,%eax
  8021f8:	83 e0 fe             	and    $0xfffffffe,%eax
  8021fb:	83 c0 07             	add    $0x7,%eax
  8021fe:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  802204:	8b 52 04             	mov    0x4(%edx),%edx
  802207:	89 95 78 fd ff ff    	mov    %edx,-0x288(%ebp)
  80220d:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802213:	8b 40 10             	mov    0x10(%eax),%eax
  802216:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  80221c:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  802222:	8b 52 14             	mov    0x14(%edx),%edx
  802225:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  80222b:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802231:	8b 78 08             	mov    0x8(%eax),%edi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  802234:	89 f8                	mov    %edi,%eax
  802236:	25 ff 0f 00 00       	and    $0xfff,%eax
  80223b:	74 16                	je     802253 <spawn+0x31f>
		va -= i;
  80223d:	29 c7                	sub    %eax,%edi
		memsz += i;
  80223f:	01 c2                	add    %eax,%edx
  802241:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
		filesz += i;
  802247:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  80224d:	29 85 78 fd ff ff    	sub    %eax,-0x288(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  802253:	bb 00 00 00 00       	mov    $0x0,%ebx
  802258:	e9 1f 01 00 00       	jmp    80237c <spawn+0x448>
		if (i >= filesz) {
  80225d:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  802263:	77 2b                	ja     802290 <spawn+0x35c>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  802265:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  80226b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80226f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802273:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802279:	89 04 24             	mov    %eax,(%esp)
  80227c:	e8 b0 ed ff ff       	call   801031 <sys_page_alloc>
  802281:	85 c0                	test   %eax,%eax
  802283:	0f 89 e7 00 00 00    	jns    802370 <spawn+0x43c>
  802289:	89 c6                	mov    %eax,%esi
  80228b:	e9 39 02 00 00       	jmp    8024c9 <spawn+0x595>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802290:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802297:	00 
  802298:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80229f:	00 
  8022a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022a7:	e8 85 ed ff ff       	call   801031 <sys_page_alloc>
  8022ac:	85 c0                	test   %eax,%eax
  8022ae:	0f 88 0b 02 00 00    	js     8024bf <spawn+0x58b>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  8022b4:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  8022ba:	01 f0                	add    %esi,%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8022bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022c0:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  8022c6:	89 04 24             	mov    %eax,(%esp)
  8022c9:	e8 56 f8 ff ff       	call   801b24 <seek>
  8022ce:	85 c0                	test   %eax,%eax
  8022d0:	0f 88 ed 01 00 00    	js     8024c3 <spawn+0x58f>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  8022d6:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8022dc:	29 f0                	sub    %esi,%eax
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8022de:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8022e3:	76 05                	jbe    8022ea <spawn+0x3b6>
  8022e5:	b8 00 10 00 00       	mov    $0x1000,%eax
  8022ea:	89 44 24 08          	mov    %eax,0x8(%esp)
  8022ee:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8022f5:	00 
  8022f6:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  8022fc:	89 04 24             	mov    %eax,(%esp)
  8022ff:	e8 4a f7 ff ff       	call   801a4e <readn>
  802304:	85 c0                	test   %eax,%eax
  802306:	0f 88 bb 01 00 00    	js     8024c7 <spawn+0x593>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  80230c:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  802312:	89 54 24 10          	mov    %edx,0x10(%esp)
  802316:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80231a:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802320:	89 44 24 08          	mov    %eax,0x8(%esp)
  802324:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80232b:	00 
  80232c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802333:	e8 4d ed ff ff       	call   801085 <sys_page_map>
  802338:	85 c0                	test   %eax,%eax
  80233a:	79 20                	jns    80235c <spawn+0x428>
				panic("spawn: sys_page_map data: %e", r);
  80233c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802340:	c7 44 24 08 61 34 80 	movl   $0x803461,0x8(%esp)
  802347:	00 
  802348:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
  80234f:	00 
  802350:	c7 04 24 55 34 80 00 	movl   $0x803455,(%esp)
  802357:	e8 40 e2 ff ff       	call   80059c <_panic>
			sys_page_unmap(0, UTEMP);
  80235c:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802363:	00 
  802364:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80236b:	e8 68 ed ff ff       	call   8010d8 <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  802370:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802376:	81 c7 00 10 00 00    	add    $0x1000,%edi
  80237c:	89 de                	mov    %ebx,%esi
  80237e:	3b 9d 8c fd ff ff    	cmp    -0x274(%ebp),%ebx
  802384:	0f 82 d3 fe ff ff    	jb     80225d <spawn+0x329>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80238a:	ff 85 7c fd ff ff    	incl   -0x284(%ebp)
  802390:	83 85 80 fd ff ff 20 	addl   $0x20,-0x280(%ebp)
  802397:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  80239e:	39 85 7c fd ff ff    	cmp    %eax,-0x284(%ebp)
  8023a4:	0f 8c 32 fe ff ff    	jl     8021dc <spawn+0x2a8>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  8023aa:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  8023b0:	89 04 24             	mov    %eax,(%esp)
  8023b3:	e8 a2 f4 ff ff       	call   80185a <close>
{
	// LAB 5: Your code here.
	int r;
	uint32_t page_num;
	
	for (page_num = 0; page_num < PGNUM(UTOP); page_num++) {
  8023b8:	be 00 00 00 00       	mov    $0x0,%esi
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES)/NPDENTRIES;
  8023bd:	89 f0                	mov    %esi,%eax
  8023bf:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx]&PTE_P) && (uvpt[page_num]&PTE_P) && (uvpt[page_num]&PTE_SHARE)){
  8023c2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8023c9:	a8 01                	test   $0x1,%al
  8023cb:	0f 84 82 00 00 00    	je     802453 <spawn+0x51f>
  8023d1:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8023d8:	a8 01                	test   $0x1,%al
  8023da:	74 77                	je     802453 <spawn+0x51f>
  8023dc:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8023e3:	f6 c4 04             	test   $0x4,%ah
  8023e6:	74 6b                	je     802453 <spawn+0x51f>
			if ((r = sys_page_map(sys_getenvid(), (void*)(page_num*PGSIZE), child, (void*)(page_num*PGSIZE), uvpt[page_num]&PTE_SYSCALL)) < 0){
  8023e8:	8b 3c b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edi
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  8023ef:	89 f3                	mov    %esi,%ebx
  8023f1:	c1 e3 0c             	shl    $0xc,%ebx
	uint32_t page_num;
	
	for (page_num = 0; page_num < PGNUM(UTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES)/NPDENTRIES;
		if ((uvpd[pdx]&PTE_P) && (uvpt[page_num]&PTE_P) && (uvpt[page_num]&PTE_SHARE)){
			if ((r = sys_page_map(sys_getenvid(), (void*)(page_num*PGSIZE), child, (void*)(page_num*PGSIZE), uvpt[page_num]&PTE_SYSCALL)) < 0){
  8023f4:	e8 fa eb ff ff       	call   800ff3 <sys_getenvid>
  8023f9:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  8023ff:	89 7c 24 10          	mov    %edi,0x10(%esp)
  802403:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  802407:	8b 95 88 fd ff ff    	mov    -0x278(%ebp),%edx
  80240d:	89 54 24 08          	mov    %edx,0x8(%esp)
  802411:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802415:	89 04 24             	mov    %eax,(%esp)
  802418:	e8 68 ec ff ff       	call   801085 <sys_page_map>
  80241d:	85 c0                	test   %eax,%eax
  80241f:	79 32                	jns    802453 <spawn+0x51f>
  802421:	89 c3                	mov    %eax,%ebx
				cprintf("copy_shared_pages: sys_page_map failed, %e", r);
  802423:	89 44 24 04          	mov    %eax,0x4(%esp)
  802427:	c7 04 24 f0 34 80 00 	movl   $0x8034f0,(%esp)
  80242e:	e8 61 e2 ff ff       	call   800694 <cprintf>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  802433:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  802437:	c7 44 24 08 7e 34 80 	movl   $0x80347e,0x8(%esp)
  80243e:	00 
  80243f:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  802446:	00 
  802447:	c7 04 24 55 34 80 00 	movl   $0x803455,(%esp)
  80244e:	e8 49 e1 ff ff       	call   80059c <_panic>
{
	// LAB 5: Your code here.
	int r;
	uint32_t page_num;
	
	for (page_num = 0; page_num < PGNUM(UTOP); page_num++) {
  802453:	46                   	inc    %esi
  802454:	81 fe 00 ec 0e 00    	cmp    $0xeec00,%esi
  80245a:	0f 85 5d ff ff ff    	jne    8023bd <spawn+0x489>
  802460:	e9 b2 00 00 00       	jmp    802517 <spawn+0x5e3>
	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  802465:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802469:	c7 44 24 08 94 34 80 	movl   $0x803494,0x8(%esp)
  802470:	00 
  802471:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  802478:	00 
  802479:	c7 04 24 55 34 80 00 	movl   $0x803455,(%esp)
  802480:	e8 17 e1 ff ff       	call   80059c <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802485:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80248c:	00 
  80248d:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802493:	89 04 24             	mov    %eax,(%esp)
  802496:	e8 90 ec ff ff       	call   80112b <sys_env_set_status>
  80249b:	85 c0                	test   %eax,%eax
  80249d:	79 5a                	jns    8024f9 <spawn+0x5c5>
		panic("sys_env_set_status: %e", r);
  80249f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024a3:	c7 44 24 08 ae 34 80 	movl   $0x8034ae,0x8(%esp)
  8024aa:	00 
  8024ab:	c7 44 24 04 88 00 00 	movl   $0x88,0x4(%esp)
  8024b2:	00 
  8024b3:	c7 04 24 55 34 80 00 	movl   $0x803455,(%esp)
  8024ba:	e8 dd e0 ff ff       	call   80059c <_panic>
  8024bf:	89 c6                	mov    %eax,%esi
  8024c1:	eb 06                	jmp    8024c9 <spawn+0x595>
  8024c3:	89 c6                	mov    %eax,%esi
  8024c5:	eb 02                	jmp    8024c9 <spawn+0x595>
  8024c7:	89 c6                	mov    %eax,%esi

	return child;

error:
	sys_env_destroy(child);
  8024c9:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8024cf:	89 04 24             	mov    %eax,(%esp)
  8024d2:	e8 ca ea ff ff       	call   800fa1 <sys_env_destroy>
	close(fd);
  8024d7:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  8024dd:	89 04 24             	mov    %eax,(%esp)
  8024e0:	e8 75 f3 ff ff       	call   80185a <close>
	return r;
  8024e5:	89 b5 88 fd ff ff    	mov    %esi,-0x278(%ebp)
  8024eb:	eb 0c                	jmp    8024f9 <spawn+0x5c5>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  8024ed:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  8024f3:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  8024f9:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8024ff:	81 c4 ac 02 00 00    	add    $0x2ac,%esp
  802505:	5b                   	pop    %ebx
  802506:	5e                   	pop    %esi
  802507:	5f                   	pop    %edi
  802508:	5d                   	pop    %ebp
  802509:	c3                   	ret    
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  80250a:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  80250f:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  802515:	eb e2                	jmp    8024f9 <spawn+0x5c5>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802517:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  80251d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802521:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802527:	89 04 24             	mov    %eax,(%esp)
  80252a:	e8 4f ec ff ff       	call   80117e <sys_env_set_trapframe>
  80252f:	85 c0                	test   %eax,%eax
  802531:	0f 89 4e ff ff ff    	jns    802485 <spawn+0x551>
  802537:	e9 29 ff ff ff       	jmp    802465 <spawn+0x531>

0080253c <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  80253c:	55                   	push   %ebp
  80253d:	89 e5                	mov    %esp,%ebp
  80253f:	57                   	push   %edi
  802540:	56                   	push   %esi
  802541:	53                   	push   %ebx
  802542:	83 ec 1c             	sub    $0x1c,%esp
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
  802545:	8d 45 10             	lea    0x10(%ebp),%eax
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802548:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  80254d:	eb 03                	jmp    802552 <spawnl+0x16>
		argc++;
  80254f:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802550:	89 d0                	mov    %edx,%eax
  802552:	8d 50 04             	lea    0x4(%eax),%edx
  802555:	83 38 00             	cmpl   $0x0,(%eax)
  802558:	75 f5                	jne    80254f <spawnl+0x13>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  80255a:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  802561:	83 e0 f0             	and    $0xfffffff0,%eax
  802564:	29 c4                	sub    %eax,%esp
  802566:	8d 7c 24 17          	lea    0x17(%esp),%edi
  80256a:	83 e7 f0             	and    $0xfffffff0,%edi
  80256d:	89 fe                	mov    %edi,%esi
	argv[0] = arg0;
  80256f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802572:	89 07                	mov    %eax,(%edi)
	argv[argc+1] = NULL;
  802574:	c7 44 8f 04 00 00 00 	movl   $0x0,0x4(%edi,%ecx,4)
  80257b:	00 

	va_start(vl, arg0);
  80257c:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  80257f:	b8 00 00 00 00       	mov    $0x0,%eax
  802584:	eb 09                	jmp    80258f <spawnl+0x53>
		argv[i+1] = va_arg(vl, const char *);
  802586:	40                   	inc    %eax
  802587:	8b 1a                	mov    (%edx),%ebx
  802589:	89 1c 86             	mov    %ebx,(%esi,%eax,4)
  80258c:	8d 52 04             	lea    0x4(%edx),%edx
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  80258f:	39 c8                	cmp    %ecx,%eax
  802591:	75 f3                	jne    802586 <spawnl+0x4a>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802593:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802597:	8b 45 08             	mov    0x8(%ebp),%eax
  80259a:	89 04 24             	mov    %eax,(%esp)
  80259d:	e8 92 f9 ff ff       	call   801f34 <spawn>
}
  8025a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025a5:	5b                   	pop    %ebx
  8025a6:	5e                   	pop    %esi
  8025a7:	5f                   	pop    %edi
  8025a8:	5d                   	pop    %ebp
  8025a9:	c3                   	ret    
	...

008025ac <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8025ac:	55                   	push   %ebp
  8025ad:	89 e5                	mov    %esp,%ebp
  8025af:	56                   	push   %esi
  8025b0:	53                   	push   %ebx
  8025b1:	83 ec 10             	sub    $0x10,%esp
  8025b4:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8025b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8025ba:	89 04 24             	mov    %eax,(%esp)
  8025bd:	e8 f2 f0 ff ff       	call   8016b4 <fd2data>
  8025c2:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8025c4:	c7 44 24 04 1b 35 80 	movl   $0x80351b,0x4(%esp)
  8025cb:	00 
  8025cc:	89 34 24             	mov    %esi,(%esp)
  8025cf:	e8 6b e6 ff ff       	call   800c3f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8025d4:	8b 43 04             	mov    0x4(%ebx),%eax
  8025d7:	2b 03                	sub    (%ebx),%eax
  8025d9:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8025df:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8025e6:	00 00 00 
	stat->st_dev = &devpipe;
  8025e9:	c7 86 88 00 00 00 3c 	movl   $0x80403c,0x88(%esi)
  8025f0:	40 80 00 
	return 0;
}
  8025f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8025f8:	83 c4 10             	add    $0x10,%esp
  8025fb:	5b                   	pop    %ebx
  8025fc:	5e                   	pop    %esi
  8025fd:	5d                   	pop    %ebp
  8025fe:	c3                   	ret    

008025ff <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8025ff:	55                   	push   %ebp
  802600:	89 e5                	mov    %esp,%ebp
  802602:	53                   	push   %ebx
  802603:	83 ec 14             	sub    $0x14,%esp
  802606:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802609:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80260d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802614:	e8 bf ea ff ff       	call   8010d8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802619:	89 1c 24             	mov    %ebx,(%esp)
  80261c:	e8 93 f0 ff ff       	call   8016b4 <fd2data>
  802621:	89 44 24 04          	mov    %eax,0x4(%esp)
  802625:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80262c:	e8 a7 ea ff ff       	call   8010d8 <sys_page_unmap>
}
  802631:	83 c4 14             	add    $0x14,%esp
  802634:	5b                   	pop    %ebx
  802635:	5d                   	pop    %ebp
  802636:	c3                   	ret    

00802637 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802637:	55                   	push   %ebp
  802638:	89 e5                	mov    %esp,%ebp
  80263a:	57                   	push   %edi
  80263b:	56                   	push   %esi
  80263c:	53                   	push   %ebx
  80263d:	83 ec 2c             	sub    $0x2c,%esp
  802640:	89 c7                	mov    %eax,%edi
  802642:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802645:	a1 04 50 80 00       	mov    0x805004,%eax
  80264a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80264d:	89 3c 24             	mov    %edi,(%esp)
  802650:	e8 ef 04 00 00       	call   802b44 <pageref>
  802655:	89 c6                	mov    %eax,%esi
  802657:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80265a:	89 04 24             	mov    %eax,(%esp)
  80265d:	e8 e2 04 00 00       	call   802b44 <pageref>
  802662:	39 c6                	cmp    %eax,%esi
  802664:	0f 94 c0             	sete   %al
  802667:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  80266a:	8b 15 04 50 80 00    	mov    0x805004,%edx
  802670:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802673:	39 cb                	cmp    %ecx,%ebx
  802675:	75 08                	jne    80267f <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  802677:	83 c4 2c             	add    $0x2c,%esp
  80267a:	5b                   	pop    %ebx
  80267b:	5e                   	pop    %esi
  80267c:	5f                   	pop    %edi
  80267d:	5d                   	pop    %ebp
  80267e:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  80267f:	83 f8 01             	cmp    $0x1,%eax
  802682:	75 c1                	jne    802645 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802684:	8b 42 58             	mov    0x58(%edx),%eax
  802687:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  80268e:	00 
  80268f:	89 44 24 08          	mov    %eax,0x8(%esp)
  802693:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802697:	c7 04 24 22 35 80 00 	movl   $0x803522,(%esp)
  80269e:	e8 f1 df ff ff       	call   800694 <cprintf>
  8026a3:	eb a0                	jmp    802645 <_pipeisclosed+0xe>

008026a5 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8026a5:	55                   	push   %ebp
  8026a6:	89 e5                	mov    %esp,%ebp
  8026a8:	57                   	push   %edi
  8026a9:	56                   	push   %esi
  8026aa:	53                   	push   %ebx
  8026ab:	83 ec 1c             	sub    $0x1c,%esp
  8026ae:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8026b1:	89 34 24             	mov    %esi,(%esp)
  8026b4:	e8 fb ef ff ff       	call   8016b4 <fd2data>
  8026b9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8026bb:	bf 00 00 00 00       	mov    $0x0,%edi
  8026c0:	eb 3c                	jmp    8026fe <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8026c2:	89 da                	mov    %ebx,%edx
  8026c4:	89 f0                	mov    %esi,%eax
  8026c6:	e8 6c ff ff ff       	call   802637 <_pipeisclosed>
  8026cb:	85 c0                	test   %eax,%eax
  8026cd:	75 38                	jne    802707 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8026cf:	e8 3e e9 ff ff       	call   801012 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8026d4:	8b 43 04             	mov    0x4(%ebx),%eax
  8026d7:	8b 13                	mov    (%ebx),%edx
  8026d9:	83 c2 20             	add    $0x20,%edx
  8026dc:	39 d0                	cmp    %edx,%eax
  8026de:	73 e2                	jae    8026c2 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8026e0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8026e3:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  8026e6:	89 c2                	mov    %eax,%edx
  8026e8:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8026ee:	79 05                	jns    8026f5 <devpipe_write+0x50>
  8026f0:	4a                   	dec    %edx
  8026f1:	83 ca e0             	or     $0xffffffe0,%edx
  8026f4:	42                   	inc    %edx
  8026f5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8026f9:	40                   	inc    %eax
  8026fa:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8026fd:	47                   	inc    %edi
  8026fe:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802701:	75 d1                	jne    8026d4 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802703:	89 f8                	mov    %edi,%eax
  802705:	eb 05                	jmp    80270c <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802707:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80270c:	83 c4 1c             	add    $0x1c,%esp
  80270f:	5b                   	pop    %ebx
  802710:	5e                   	pop    %esi
  802711:	5f                   	pop    %edi
  802712:	5d                   	pop    %ebp
  802713:	c3                   	ret    

00802714 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802714:	55                   	push   %ebp
  802715:	89 e5                	mov    %esp,%ebp
  802717:	57                   	push   %edi
  802718:	56                   	push   %esi
  802719:	53                   	push   %ebx
  80271a:	83 ec 1c             	sub    $0x1c,%esp
  80271d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802720:	89 3c 24             	mov    %edi,(%esp)
  802723:	e8 8c ef ff ff       	call   8016b4 <fd2data>
  802728:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80272a:	be 00 00 00 00       	mov    $0x0,%esi
  80272f:	eb 3a                	jmp    80276b <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802731:	85 f6                	test   %esi,%esi
  802733:	74 04                	je     802739 <devpipe_read+0x25>
				return i;
  802735:	89 f0                	mov    %esi,%eax
  802737:	eb 40                	jmp    802779 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802739:	89 da                	mov    %ebx,%edx
  80273b:	89 f8                	mov    %edi,%eax
  80273d:	e8 f5 fe ff ff       	call   802637 <_pipeisclosed>
  802742:	85 c0                	test   %eax,%eax
  802744:	75 2e                	jne    802774 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802746:	e8 c7 e8 ff ff       	call   801012 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80274b:	8b 03                	mov    (%ebx),%eax
  80274d:	3b 43 04             	cmp    0x4(%ebx),%eax
  802750:	74 df                	je     802731 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802752:	25 1f 00 00 80       	and    $0x8000001f,%eax
  802757:	79 05                	jns    80275e <devpipe_read+0x4a>
  802759:	48                   	dec    %eax
  80275a:	83 c8 e0             	or     $0xffffffe0,%eax
  80275d:	40                   	inc    %eax
  80275e:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  802762:	8b 55 0c             	mov    0xc(%ebp),%edx
  802765:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  802768:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80276a:	46                   	inc    %esi
  80276b:	3b 75 10             	cmp    0x10(%ebp),%esi
  80276e:	75 db                	jne    80274b <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802770:	89 f0                	mov    %esi,%eax
  802772:	eb 05                	jmp    802779 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802774:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802779:	83 c4 1c             	add    $0x1c,%esp
  80277c:	5b                   	pop    %ebx
  80277d:	5e                   	pop    %esi
  80277e:	5f                   	pop    %edi
  80277f:	5d                   	pop    %ebp
  802780:	c3                   	ret    

00802781 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802781:	55                   	push   %ebp
  802782:	89 e5                	mov    %esp,%ebp
  802784:	57                   	push   %edi
  802785:	56                   	push   %esi
  802786:	53                   	push   %ebx
  802787:	83 ec 3c             	sub    $0x3c,%esp
  80278a:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80278d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802790:	89 04 24             	mov    %eax,(%esp)
  802793:	e8 37 ef ff ff       	call   8016cf <fd_alloc>
  802798:	89 c3                	mov    %eax,%ebx
  80279a:	85 c0                	test   %eax,%eax
  80279c:	0f 88 45 01 00 00    	js     8028e7 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8027a2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8027a9:	00 
  8027aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8027ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8027b8:	e8 74 e8 ff ff       	call   801031 <sys_page_alloc>
  8027bd:	89 c3                	mov    %eax,%ebx
  8027bf:	85 c0                	test   %eax,%eax
  8027c1:	0f 88 20 01 00 00    	js     8028e7 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8027c7:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8027ca:	89 04 24             	mov    %eax,(%esp)
  8027cd:	e8 fd ee ff ff       	call   8016cf <fd_alloc>
  8027d2:	89 c3                	mov    %eax,%ebx
  8027d4:	85 c0                	test   %eax,%eax
  8027d6:	0f 88 f8 00 00 00    	js     8028d4 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8027dc:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8027e3:	00 
  8027e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8027e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8027f2:	e8 3a e8 ff ff       	call   801031 <sys_page_alloc>
  8027f7:	89 c3                	mov    %eax,%ebx
  8027f9:	85 c0                	test   %eax,%eax
  8027fb:	0f 88 d3 00 00 00    	js     8028d4 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802801:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802804:	89 04 24             	mov    %eax,(%esp)
  802807:	e8 a8 ee ff ff       	call   8016b4 <fd2data>
  80280c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80280e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802815:	00 
  802816:	89 44 24 04          	mov    %eax,0x4(%esp)
  80281a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802821:	e8 0b e8 ff ff       	call   801031 <sys_page_alloc>
  802826:	89 c3                	mov    %eax,%ebx
  802828:	85 c0                	test   %eax,%eax
  80282a:	0f 88 91 00 00 00    	js     8028c1 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802830:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802833:	89 04 24             	mov    %eax,(%esp)
  802836:	e8 79 ee ff ff       	call   8016b4 <fd2data>
  80283b:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802842:	00 
  802843:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802847:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80284e:	00 
  80284f:	89 74 24 04          	mov    %esi,0x4(%esp)
  802853:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80285a:	e8 26 e8 ff ff       	call   801085 <sys_page_map>
  80285f:	89 c3                	mov    %eax,%ebx
  802861:	85 c0                	test   %eax,%eax
  802863:	78 4c                	js     8028b1 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802865:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  80286b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80286e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802870:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802873:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80287a:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802880:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802883:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802885:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802888:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80288f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802892:	89 04 24             	mov    %eax,(%esp)
  802895:	e8 0a ee ff ff       	call   8016a4 <fd2num>
  80289a:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  80289c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80289f:	89 04 24             	mov    %eax,(%esp)
  8028a2:	e8 fd ed ff ff       	call   8016a4 <fd2num>
  8028a7:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8028aa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8028af:	eb 36                	jmp    8028e7 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  8028b1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8028b5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8028bc:	e8 17 e8 ff ff       	call   8010d8 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8028c1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8028c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8028c8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8028cf:	e8 04 e8 ff ff       	call   8010d8 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8028d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8028d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8028db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8028e2:	e8 f1 e7 ff ff       	call   8010d8 <sys_page_unmap>
    err:
	return r;
}
  8028e7:	89 d8                	mov    %ebx,%eax
  8028e9:	83 c4 3c             	add    $0x3c,%esp
  8028ec:	5b                   	pop    %ebx
  8028ed:	5e                   	pop    %esi
  8028ee:	5f                   	pop    %edi
  8028ef:	5d                   	pop    %ebp
  8028f0:	c3                   	ret    

008028f1 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8028f1:	55                   	push   %ebp
  8028f2:	89 e5                	mov    %esp,%ebp
  8028f4:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8028f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8028fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8028fe:	8b 45 08             	mov    0x8(%ebp),%eax
  802901:	89 04 24             	mov    %eax,(%esp)
  802904:	e8 19 ee ff ff       	call   801722 <fd_lookup>
  802909:	85 c0                	test   %eax,%eax
  80290b:	78 15                	js     802922 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80290d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802910:	89 04 24             	mov    %eax,(%esp)
  802913:	e8 9c ed ff ff       	call   8016b4 <fd2data>
	return _pipeisclosed(fd, p);
  802918:	89 c2                	mov    %eax,%edx
  80291a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80291d:	e8 15 fd ff ff       	call   802637 <_pipeisclosed>
}
  802922:	c9                   	leave  
  802923:	c3                   	ret    

00802924 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802924:	55                   	push   %ebp
  802925:	89 e5                	mov    %esp,%ebp
  802927:	56                   	push   %esi
  802928:	53                   	push   %ebx
  802929:	83 ec 10             	sub    $0x10,%esp
  80292c:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  80292f:	85 f6                	test   %esi,%esi
  802931:	75 24                	jne    802957 <wait+0x33>
  802933:	c7 44 24 0c 3a 35 80 	movl   $0x80353a,0xc(%esp)
  80293a:	00 
  80293b:	c7 44 24 08 0f 34 80 	movl   $0x80340f,0x8(%esp)
  802942:	00 
  802943:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  80294a:	00 
  80294b:	c7 04 24 45 35 80 00 	movl   $0x803545,(%esp)
  802952:	e8 45 dc ff ff       	call   80059c <_panic>
	e = &envs[ENVX(envid)];
  802957:	89 f3                	mov    %esi,%ebx
  802959:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  80295f:	8d 04 9d 00 00 00 00 	lea    0x0(,%ebx,4),%eax
  802966:	c1 e3 07             	shl    $0x7,%ebx
  802969:	29 c3                	sub    %eax,%ebx
  80296b:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802971:	eb 05                	jmp    802978 <wait+0x54>
		sys_yield();
  802973:	e8 9a e6 ff ff       	call   801012 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802978:	8b 43 48             	mov    0x48(%ebx),%eax
  80297b:	39 f0                	cmp    %esi,%eax
  80297d:	75 07                	jne    802986 <wait+0x62>
  80297f:	8b 43 54             	mov    0x54(%ebx),%eax
  802982:	85 c0                	test   %eax,%eax
  802984:	75 ed                	jne    802973 <wait+0x4f>
		sys_yield();
}
  802986:	83 c4 10             	add    $0x10,%esp
  802989:	5b                   	pop    %ebx
  80298a:	5e                   	pop    %esi
  80298b:	5d                   	pop    %ebp
  80298c:	c3                   	ret    
  80298d:	00 00                	add    %al,(%eax)
	...

00802990 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802990:	55                   	push   %ebp
  802991:	89 e5                	mov    %esp,%ebp
  802993:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  802996:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  80299d:	75 58                	jne    8029f7 <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.	
		//panic("set_pgfault_handler not implemented");
		
		if (sys_page_alloc(thisenv->env_id,(void *) (UXSTACKTOP - PGSIZE),(PTE_W|PTE_U|PTE_P)) != 0){
  80299f:	a1 04 50 80 00       	mov    0x805004,%eax
  8029a4:	8b 40 48             	mov    0x48(%eax),%eax
  8029a7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8029ae:	00 
  8029af:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8029b6:	ee 
  8029b7:	89 04 24             	mov    %eax,(%esp)
  8029ba:	e8 72 e6 ff ff       	call   801031 <sys_page_alloc>
  8029bf:	85 c0                	test   %eax,%eax
  8029c1:	74 1c                	je     8029df <set_pgfault_handler+0x4f>
			panic("set_pg_fault_handler");
  8029c3:	c7 44 24 08 50 35 80 	movl   $0x803550,0x8(%esp)
  8029ca:	00 
  8029cb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8029d2:	00 
  8029d3:	c7 04 24 65 35 80 00 	movl   $0x803565,(%esp)
  8029da:	e8 bd db ff ff       	call   80059c <_panic>
		}
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  8029df:	a1 04 50 80 00       	mov    0x805004,%eax
  8029e4:	8b 40 48             	mov    0x48(%eax),%eax
  8029e7:	c7 44 24 04 04 2a 80 	movl   $0x802a04,0x4(%esp)
  8029ee:	00 
  8029ef:	89 04 24             	mov    %eax,(%esp)
  8029f2:	e8 da e7 ff ff       	call   8011d1 <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8029f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8029fa:	a3 00 70 80 00       	mov    %eax,0x807000
}
  8029ff:	c9                   	leave  
  802a00:	c3                   	ret    
  802a01:	00 00                	add    %al,(%eax)
	...

00802a04 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802a04:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802a05:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802a0a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802a0c:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// Save trap-time eip in eax
	movl 0x28(%esp), %eax
  802a0f:	8b 44 24 28          	mov    0x28(%esp),%eax

	// Save our current stack
	movl %esp, %ebp
  802a13:	89 e5                	mov    %esp,%ebp

	// Switch to trap-time stack
	movl 0x30(%esp), %esp
  802a15:	8b 64 24 30          	mov    0x30(%esp),%esp

	// Push trap-time eip to the trap-time stack
	pushl %eax
  802a19:	50                   	push   %eax

	// We now have to update the trap-time esp with its new value
	movl %esp, 0x30(%ebp)
  802a1a:	89 65 30             	mov    %esp,0x30(%ebp)

	// Go back to our exception stack
	movl %ebp, %esp
  802a1d:	89 ec                	mov    %ebp,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// Pop fault_va and err, both can be ignored
	popl %eax
  802a1f:	58                   	pop    %eax
	popl %eax
  802a20:	58                   	pop    %eax

	// Pop all registers back
	popal
  802a21:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// Skip %eip
	addl $0x4, %esp
  802a22:	83 c4 04             	add    $0x4,%esp

	// Pop eflags back
	popfl
  802a25:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	
	popl %esp
  802a26:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  802a27:	c3                   	ret    

00802a28 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802a28:	55                   	push   %ebp
  802a29:	89 e5                	mov    %esp,%ebp
  802a2b:	56                   	push   %esi
  802a2c:	53                   	push   %ebx
  802a2d:	83 ec 10             	sub    $0x10,%esp
  802a30:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802a33:	8b 45 0c             	mov    0xc(%ebp),%eax
  802a36:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int r;
		
	r = sys_ipc_recv(pg?pg:(void*)UTOP);
  802a39:	85 c0                	test   %eax,%eax
  802a3b:	75 05                	jne    802a42 <ipc_recv+0x1a>
  802a3d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802a42:	89 04 24             	mov    %eax,(%esp)
  802a45:	e8 fd e7 ff ff       	call   801247 <sys_ipc_recv>
	if (from_env_store != NULL)
  802a4a:	85 db                	test   %ebx,%ebx
  802a4c:	74 0b                	je     802a59 <ipc_recv+0x31>
		*from_env_store = thisenv->env_ipc_from; 
  802a4e:	8b 15 04 50 80 00    	mov    0x805004,%edx
  802a54:	8b 52 74             	mov    0x74(%edx),%edx
  802a57:	89 13                	mov    %edx,(%ebx)
	if (perm_store != NULL)
  802a59:	85 f6                	test   %esi,%esi
  802a5b:	74 0b                	je     802a68 <ipc_recv+0x40>
		*perm_store = thisenv->env_ipc_perm;
  802a5d:	8b 15 04 50 80 00    	mov    0x805004,%edx
  802a63:	8b 52 78             	mov    0x78(%edx),%edx
  802a66:	89 16                	mov    %edx,(%esi)
	
	if (r < 0){
  802a68:	85 c0                	test   %eax,%eax
  802a6a:	79 16                	jns    802a82 <ipc_recv+0x5a>
		if(from_env_store != NULL)
  802a6c:	85 db                	test   %ebx,%ebx
  802a6e:	74 06                	je     802a76 <ipc_recv+0x4e>
			*from_env_store = 0;
  802a70:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store != NULL)	
  802a76:	85 f6                	test   %esi,%esi
  802a78:	74 10                	je     802a8a <ipc_recv+0x62>
			*perm_store = 0;
  802a7a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  802a80:	eb 08                	jmp    802a8a <ipc_recv+0x62>
		return r;
	}
	
	return thisenv->env_ipc_value;
  802a82:	a1 04 50 80 00       	mov    0x805004,%eax
  802a87:	8b 40 70             	mov    0x70(%eax),%eax
}
  802a8a:	83 c4 10             	add    $0x10,%esp
  802a8d:	5b                   	pop    %ebx
  802a8e:	5e                   	pop    %esi
  802a8f:	5d                   	pop    %ebp
  802a90:	c3                   	ret    

00802a91 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802a91:	55                   	push   %ebp
  802a92:	89 e5                	mov    %esp,%ebp
  802a94:	57                   	push   %edi
  802a95:	56                   	push   %esi
  802a96:	53                   	push   %ebx
  802a97:	83 ec 1c             	sub    $0x1c,%esp
  802a9a:	8b 75 08             	mov    0x8(%ebp),%esi
  802a9d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802aa0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  802aa3:	eb 2a                	jmp    802acf <ipc_send+0x3e>
		if (r != -E_IPC_NOT_RECV)
  802aa5:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802aa8:	74 20                	je     802aca <ipc_send+0x39>
			panic("ipc_send: sys_ipc_try_send failed %e", r);
  802aaa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802aae:	c7 44 24 08 74 35 80 	movl   $0x803574,0x8(%esp)
  802ab5:	00 
  802ab6:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  802abd:	00 
  802abe:	c7 04 24 9c 35 80 00 	movl   $0x80359c,(%esp)
  802ac5:	e8 d2 da ff ff       	call   80059c <_panic>
		sys_yield();
  802aca:	e8 43 e5 ff ff       	call   801012 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  802acf:	85 db                	test   %ebx,%ebx
  802ad1:	75 07                	jne    802ada <ipc_send+0x49>
  802ad3:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802ad8:	eb 02                	jmp    802adc <ipc_send+0x4b>
  802ada:	89 d8                	mov    %ebx,%eax
  802adc:	8b 55 14             	mov    0x14(%ebp),%edx
  802adf:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802ae3:	89 44 24 08          	mov    %eax,0x8(%esp)
  802ae7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802aeb:	89 34 24             	mov    %esi,(%esp)
  802aee:	e8 31 e7 ff ff       	call   801224 <sys_ipc_try_send>
  802af3:	85 c0                	test   %eax,%eax
  802af5:	78 ae                	js     802aa5 <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: sys_ipc_try_send failed %e", r);
		sys_yield();
	}
}
  802af7:	83 c4 1c             	add    $0x1c,%esp
  802afa:	5b                   	pop    %ebx
  802afb:	5e                   	pop    %esi
  802afc:	5f                   	pop    %edi
  802afd:	5d                   	pop    %ebp
  802afe:	c3                   	ret    

00802aff <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802aff:	55                   	push   %ebp
  802b00:	89 e5                	mov    %esp,%ebp
  802b02:	53                   	push   %ebx
  802b03:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  802b06:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802b0b:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802b12:	89 c2                	mov    %eax,%edx
  802b14:	c1 e2 07             	shl    $0x7,%edx
  802b17:	29 ca                	sub    %ecx,%edx
  802b19:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802b1f:	8b 52 50             	mov    0x50(%edx),%edx
  802b22:	39 da                	cmp    %ebx,%edx
  802b24:	75 0f                	jne    802b35 <ipc_find_env+0x36>
			return envs[i].env_id;
  802b26:	c1 e0 07             	shl    $0x7,%eax
  802b29:	29 c8                	sub    %ecx,%eax
  802b2b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802b30:	8b 40 40             	mov    0x40(%eax),%eax
  802b33:	eb 0c                	jmp    802b41 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802b35:	40                   	inc    %eax
  802b36:	3d 00 04 00 00       	cmp    $0x400,%eax
  802b3b:	75 ce                	jne    802b0b <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802b3d:	66 b8 00 00          	mov    $0x0,%ax
}
  802b41:	5b                   	pop    %ebx
  802b42:	5d                   	pop    %ebp
  802b43:	c3                   	ret    

00802b44 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802b44:	55                   	push   %ebp
  802b45:	89 e5                	mov    %esp,%ebp
  802b47:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802b4a:	89 c2                	mov    %eax,%edx
  802b4c:	c1 ea 16             	shr    $0x16,%edx
  802b4f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802b56:	f6 c2 01             	test   $0x1,%dl
  802b59:	74 1e                	je     802b79 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802b5b:	c1 e8 0c             	shr    $0xc,%eax
  802b5e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802b65:	a8 01                	test   $0x1,%al
  802b67:	74 17                	je     802b80 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802b69:	c1 e8 0c             	shr    $0xc,%eax
  802b6c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802b73:	ef 
  802b74:	0f b7 c0             	movzwl %ax,%eax
  802b77:	eb 0c                	jmp    802b85 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802b79:	b8 00 00 00 00       	mov    $0x0,%eax
  802b7e:	eb 05                	jmp    802b85 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802b80:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802b85:	5d                   	pop    %ebp
  802b86:	c3                   	ret    
	...

00802b88 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802b88:	55                   	push   %ebp
  802b89:	57                   	push   %edi
  802b8a:	56                   	push   %esi
  802b8b:	83 ec 10             	sub    $0x10,%esp
  802b8e:	8b 74 24 20          	mov    0x20(%esp),%esi
  802b92:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802b96:	89 74 24 04          	mov    %esi,0x4(%esp)
  802b9a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  802b9e:	89 cd                	mov    %ecx,%ebp
  802ba0:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802ba4:	85 c0                	test   %eax,%eax
  802ba6:	75 2c                	jne    802bd4 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802ba8:	39 f9                	cmp    %edi,%ecx
  802baa:	77 68                	ja     802c14 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802bac:	85 c9                	test   %ecx,%ecx
  802bae:	75 0b                	jne    802bbb <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802bb0:	b8 01 00 00 00       	mov    $0x1,%eax
  802bb5:	31 d2                	xor    %edx,%edx
  802bb7:	f7 f1                	div    %ecx
  802bb9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802bbb:	31 d2                	xor    %edx,%edx
  802bbd:	89 f8                	mov    %edi,%eax
  802bbf:	f7 f1                	div    %ecx
  802bc1:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802bc3:	89 f0                	mov    %esi,%eax
  802bc5:	f7 f1                	div    %ecx
  802bc7:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802bc9:	89 f0                	mov    %esi,%eax
  802bcb:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802bcd:	83 c4 10             	add    $0x10,%esp
  802bd0:	5e                   	pop    %esi
  802bd1:	5f                   	pop    %edi
  802bd2:	5d                   	pop    %ebp
  802bd3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802bd4:	39 f8                	cmp    %edi,%eax
  802bd6:	77 2c                	ja     802c04 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802bd8:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  802bdb:	83 f6 1f             	xor    $0x1f,%esi
  802bde:	75 4c                	jne    802c2c <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802be0:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802be2:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802be7:	72 0a                	jb     802bf3 <__udivdi3+0x6b>
  802be9:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802bed:	0f 87 ad 00 00 00    	ja     802ca0 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802bf3:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802bf8:	89 f0                	mov    %esi,%eax
  802bfa:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802bfc:	83 c4 10             	add    $0x10,%esp
  802bff:	5e                   	pop    %esi
  802c00:	5f                   	pop    %edi
  802c01:	5d                   	pop    %ebp
  802c02:	c3                   	ret    
  802c03:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802c04:	31 ff                	xor    %edi,%edi
  802c06:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802c08:	89 f0                	mov    %esi,%eax
  802c0a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802c0c:	83 c4 10             	add    $0x10,%esp
  802c0f:	5e                   	pop    %esi
  802c10:	5f                   	pop    %edi
  802c11:	5d                   	pop    %ebp
  802c12:	c3                   	ret    
  802c13:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802c14:	89 fa                	mov    %edi,%edx
  802c16:	89 f0                	mov    %esi,%eax
  802c18:	f7 f1                	div    %ecx
  802c1a:	89 c6                	mov    %eax,%esi
  802c1c:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802c1e:	89 f0                	mov    %esi,%eax
  802c20:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802c22:	83 c4 10             	add    $0x10,%esp
  802c25:	5e                   	pop    %esi
  802c26:	5f                   	pop    %edi
  802c27:	5d                   	pop    %ebp
  802c28:	c3                   	ret    
  802c29:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802c2c:	89 f1                	mov    %esi,%ecx
  802c2e:	d3 e0                	shl    %cl,%eax
  802c30:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802c34:	b8 20 00 00 00       	mov    $0x20,%eax
  802c39:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802c3b:	89 ea                	mov    %ebp,%edx
  802c3d:	88 c1                	mov    %al,%cl
  802c3f:	d3 ea                	shr    %cl,%edx
  802c41:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802c45:	09 ca                	or     %ecx,%edx
  802c47:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  802c4b:	89 f1                	mov    %esi,%ecx
  802c4d:	d3 e5                	shl    %cl,%ebp
  802c4f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  802c53:	89 fd                	mov    %edi,%ebp
  802c55:	88 c1                	mov    %al,%cl
  802c57:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802c59:	89 fa                	mov    %edi,%edx
  802c5b:	89 f1                	mov    %esi,%ecx
  802c5d:	d3 e2                	shl    %cl,%edx
  802c5f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802c63:	88 c1                	mov    %al,%cl
  802c65:	d3 ef                	shr    %cl,%edi
  802c67:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802c69:	89 f8                	mov    %edi,%eax
  802c6b:	89 ea                	mov    %ebp,%edx
  802c6d:	f7 74 24 08          	divl   0x8(%esp)
  802c71:	89 d1                	mov    %edx,%ecx
  802c73:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802c75:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802c79:	39 d1                	cmp    %edx,%ecx
  802c7b:	72 17                	jb     802c94 <__udivdi3+0x10c>
  802c7d:	74 09                	je     802c88 <__udivdi3+0x100>
  802c7f:	89 fe                	mov    %edi,%esi
  802c81:	31 ff                	xor    %edi,%edi
  802c83:	e9 41 ff ff ff       	jmp    802bc9 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802c88:	8b 54 24 04          	mov    0x4(%esp),%edx
  802c8c:	89 f1                	mov    %esi,%ecx
  802c8e:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802c90:	39 c2                	cmp    %eax,%edx
  802c92:	73 eb                	jae    802c7f <__udivdi3+0xf7>
		{
		  q0--;
  802c94:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802c97:	31 ff                	xor    %edi,%edi
  802c99:	e9 2b ff ff ff       	jmp    802bc9 <__udivdi3+0x41>
  802c9e:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802ca0:	31 f6                	xor    %esi,%esi
  802ca2:	e9 22 ff ff ff       	jmp    802bc9 <__udivdi3+0x41>
	...

00802ca8 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802ca8:	55                   	push   %ebp
  802ca9:	57                   	push   %edi
  802caa:	56                   	push   %esi
  802cab:	83 ec 20             	sub    $0x20,%esp
  802cae:	8b 44 24 30          	mov    0x30(%esp),%eax
  802cb2:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802cb6:	89 44 24 14          	mov    %eax,0x14(%esp)
  802cba:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  802cbe:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802cc2:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802cc6:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802cc8:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802cca:	85 ed                	test   %ebp,%ebp
  802ccc:	75 16                	jne    802ce4 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  802cce:	39 f1                	cmp    %esi,%ecx
  802cd0:	0f 86 a6 00 00 00    	jbe    802d7c <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802cd6:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802cd8:	89 d0                	mov    %edx,%eax
  802cda:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802cdc:	83 c4 20             	add    $0x20,%esp
  802cdf:	5e                   	pop    %esi
  802ce0:	5f                   	pop    %edi
  802ce1:	5d                   	pop    %ebp
  802ce2:	c3                   	ret    
  802ce3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802ce4:	39 f5                	cmp    %esi,%ebp
  802ce6:	0f 87 ac 00 00 00    	ja     802d98 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802cec:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  802cef:	83 f0 1f             	xor    $0x1f,%eax
  802cf2:	89 44 24 10          	mov    %eax,0x10(%esp)
  802cf6:	0f 84 a8 00 00 00    	je     802da4 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802cfc:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802d00:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802d02:	bf 20 00 00 00       	mov    $0x20,%edi
  802d07:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802d0b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802d0f:	89 f9                	mov    %edi,%ecx
  802d11:	d3 e8                	shr    %cl,%eax
  802d13:	09 e8                	or     %ebp,%eax
  802d15:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  802d19:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802d1d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802d21:	d3 e0                	shl    %cl,%eax
  802d23:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802d27:	89 f2                	mov    %esi,%edx
  802d29:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802d2b:	8b 44 24 14          	mov    0x14(%esp),%eax
  802d2f:	d3 e0                	shl    %cl,%eax
  802d31:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802d35:	8b 44 24 14          	mov    0x14(%esp),%eax
  802d39:	89 f9                	mov    %edi,%ecx
  802d3b:	d3 e8                	shr    %cl,%eax
  802d3d:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802d3f:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802d41:	89 f2                	mov    %esi,%edx
  802d43:	f7 74 24 18          	divl   0x18(%esp)
  802d47:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802d49:	f7 64 24 0c          	mull   0xc(%esp)
  802d4d:	89 c5                	mov    %eax,%ebp
  802d4f:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802d51:	39 d6                	cmp    %edx,%esi
  802d53:	72 67                	jb     802dbc <__umoddi3+0x114>
  802d55:	74 75                	je     802dcc <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802d57:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802d5b:	29 e8                	sub    %ebp,%eax
  802d5d:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802d5f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802d63:	d3 e8                	shr    %cl,%eax
  802d65:	89 f2                	mov    %esi,%edx
  802d67:	89 f9                	mov    %edi,%ecx
  802d69:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802d6b:	09 d0                	or     %edx,%eax
  802d6d:	89 f2                	mov    %esi,%edx
  802d6f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802d73:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802d75:	83 c4 20             	add    $0x20,%esp
  802d78:	5e                   	pop    %esi
  802d79:	5f                   	pop    %edi
  802d7a:	5d                   	pop    %ebp
  802d7b:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802d7c:	85 c9                	test   %ecx,%ecx
  802d7e:	75 0b                	jne    802d8b <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802d80:	b8 01 00 00 00       	mov    $0x1,%eax
  802d85:	31 d2                	xor    %edx,%edx
  802d87:	f7 f1                	div    %ecx
  802d89:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802d8b:	89 f0                	mov    %esi,%eax
  802d8d:	31 d2                	xor    %edx,%edx
  802d8f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802d91:	89 f8                	mov    %edi,%eax
  802d93:	e9 3e ff ff ff       	jmp    802cd6 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802d98:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802d9a:	83 c4 20             	add    $0x20,%esp
  802d9d:	5e                   	pop    %esi
  802d9e:	5f                   	pop    %edi
  802d9f:	5d                   	pop    %ebp
  802da0:	c3                   	ret    
  802da1:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802da4:	39 f5                	cmp    %esi,%ebp
  802da6:	72 04                	jb     802dac <__umoddi3+0x104>
  802da8:	39 f9                	cmp    %edi,%ecx
  802daa:	77 06                	ja     802db2 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802dac:	89 f2                	mov    %esi,%edx
  802dae:	29 cf                	sub    %ecx,%edi
  802db0:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802db2:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802db4:	83 c4 20             	add    $0x20,%esp
  802db7:	5e                   	pop    %esi
  802db8:	5f                   	pop    %edi
  802db9:	5d                   	pop    %ebp
  802dba:	c3                   	ret    
  802dbb:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802dbc:	89 d1                	mov    %edx,%ecx
  802dbe:	89 c5                	mov    %eax,%ebp
  802dc0:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802dc4:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802dc8:	eb 8d                	jmp    802d57 <__umoddi3+0xaf>
  802dca:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802dcc:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802dd0:	72 ea                	jb     802dbc <__umoddi3+0x114>
  802dd2:	89 f1                	mov    %esi,%ecx
  802dd4:	eb 81                	jmp    802d57 <__umoddi3+0xaf>
