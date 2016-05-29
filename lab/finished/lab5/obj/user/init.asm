
obj/user/init.debug:     file format elf32-i386


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
  80002c:	e8 b3 03 00 00       	call   8003e4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <sum>:

char bss[6000];

int
sum(const char *s, int n)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	8b 75 08             	mov    0x8(%ebp),%esi
  80003c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i, tot = 0;
  80003f:	b8 00 00 00 00       	mov    $0x0,%eax
	for (i = 0; i < n; i++)
  800044:	ba 00 00 00 00       	mov    $0x0,%edx
  800049:	eb 0a                	jmp    800055 <sum+0x21>
		tot ^= i * s[i];
  80004b:	0f be 0c 16          	movsbl (%esi,%edx,1),%ecx
  80004f:	0f af ca             	imul   %edx,%ecx
  800052:	31 c8                	xor    %ecx,%eax

int
sum(const char *s, int n)
{
	int i, tot = 0;
	for (i = 0; i < n; i++)
  800054:	42                   	inc    %edx
  800055:	39 da                	cmp    %ebx,%edx
  800057:	7c f2                	jl     80004b <sum+0x17>
		tot ^= i * s[i];
	return tot;
}
  800059:	5b                   	pop    %ebx
  80005a:	5e                   	pop    %esi
  80005b:	5d                   	pop    %ebp
  80005c:	c3                   	ret    

0080005d <umain>:

void
umain(int argc, char **argv)
{
  80005d:	55                   	push   %ebp
  80005e:	89 e5                	mov    %esp,%ebp
  800060:	57                   	push   %edi
  800061:	56                   	push   %esi
  800062:	53                   	push   %ebx
  800063:	81 ec 1c 01 00 00    	sub    $0x11c,%esp
  800069:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int i, r, x, want;
	char args[256];

	cprintf("init: running\n");
  80006c:	c7 04 24 00 28 80 00 	movl   $0x802800,(%esp)
  800073:	e8 cc 04 00 00       	call   800544 <cprintf>

	want = 0xf989e;
	if ((x = sum((char*)&data, sizeof data)) != want)
  800078:	c7 44 24 04 70 17 00 	movl   $0x1770,0x4(%esp)
  80007f:	00 
  800080:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  800087:	e8 a8 ff ff ff       	call   800034 <sum>
  80008c:	3d 9e 98 0f 00       	cmp    $0xf989e,%eax
  800091:	74 1a                	je     8000ad <umain+0x50>
		cprintf("init: data is not initialized: got sum %08x wanted %08x\n",
  800093:	c7 44 24 08 9e 98 0f 	movl   $0xf989e,0x8(%esp)
  80009a:	00 
  80009b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80009f:	c7 04 24 c8 28 80 00 	movl   $0x8028c8,(%esp)
  8000a6:	e8 99 04 00 00       	call   800544 <cprintf>
  8000ab:	eb 0c                	jmp    8000b9 <umain+0x5c>
			x, want);
	else
		cprintf("init: data seems okay\n");
  8000ad:	c7 04 24 0f 28 80 00 	movl   $0x80280f,(%esp)
  8000b4:	e8 8b 04 00 00       	call   800544 <cprintf>
	if ((x = sum(bss, sizeof bss)) != 0)
  8000b9:	c7 44 24 04 70 17 00 	movl   $0x1770,0x4(%esp)
  8000c0:	00 
  8000c1:	c7 04 24 20 50 80 00 	movl   $0x805020,(%esp)
  8000c8:	e8 67 ff ff ff       	call   800034 <sum>
  8000cd:	85 c0                	test   %eax,%eax
  8000cf:	74 12                	je     8000e3 <umain+0x86>
		cprintf("bss is not initialized: wanted sum 0 got %08x\n", x);
  8000d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000d5:	c7 04 24 04 29 80 00 	movl   $0x802904,(%esp)
  8000dc:	e8 63 04 00 00       	call   800544 <cprintf>
  8000e1:	eb 0c                	jmp    8000ef <umain+0x92>
	else
		cprintf("init: bss seems okay\n");
  8000e3:	c7 04 24 26 28 80 00 	movl   $0x802826,(%esp)
  8000ea:	e8 55 04 00 00       	call   800544 <cprintf>

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
  8000ef:	c7 44 24 04 3c 28 80 	movl   $0x80283c,0x4(%esp)
  8000f6:	00 
  8000f7:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8000fd:	89 04 24             	mov    %eax,(%esp)
  800100:	e8 07 0a 00 00       	call   800b0c <strcat>
	for (i = 0; i < argc; i++) {
  800105:	bb 00 00 00 00       	mov    $0x0,%ebx
		strcat(args, " '");
  80010a:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
	for (i = 0; i < argc; i++) {
  800110:	eb 30                	jmp    800142 <umain+0xe5>
		strcat(args, " '");
  800112:	c7 44 24 04 48 28 80 	movl   $0x802848,0x4(%esp)
  800119:	00 
  80011a:	89 34 24             	mov    %esi,(%esp)
  80011d:	e8 ea 09 00 00       	call   800b0c <strcat>
		strcat(args, argv[i]);
  800122:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  800125:	89 44 24 04          	mov    %eax,0x4(%esp)
  800129:	89 34 24             	mov    %esi,(%esp)
  80012c:	e8 db 09 00 00       	call   800b0c <strcat>
		strcat(args, "'");
  800131:	c7 44 24 04 49 28 80 	movl   $0x802849,0x4(%esp)
  800138:	00 
  800139:	89 34 24             	mov    %esi,(%esp)
  80013c:	e8 cb 09 00 00       	call   800b0c <strcat>
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
	for (i = 0; i < argc; i++) {
  800141:	43                   	inc    %ebx
  800142:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  800145:	7c cb                	jl     800112 <umain+0xb5>
		strcat(args, " '");
		strcat(args, argv[i]);
		strcat(args, "'");
	}
	cprintf("%s\n", args);
  800147:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80014d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800151:	c7 04 24 4b 28 80 00 	movl   $0x80284b,(%esp)
  800158:	e8 e7 03 00 00       	call   800544 <cprintf>

	cprintf("init: running sh\n");
  80015d:	c7 04 24 4f 28 80 00 	movl   $0x80284f,(%esp)
  800164:	e8 db 03 00 00       	call   800544 <cprintf>

	// being run directly from kernel, so no file descriptors open yet
	close(0);
  800169:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800170:	e8 8d 11 00 00       	call   801302 <close>
	if ((r = opencons()) < 0)
  800175:	e8 16 02 00 00       	call   800390 <opencons>
  80017a:	85 c0                	test   %eax,%eax
  80017c:	79 20                	jns    80019e <umain+0x141>
		panic("opencons: %e", r);
  80017e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800182:	c7 44 24 08 61 28 80 	movl   $0x802861,0x8(%esp)
  800189:	00 
  80018a:	c7 44 24 04 37 00 00 	movl   $0x37,0x4(%esp)
  800191:	00 
  800192:	c7 04 24 6e 28 80 00 	movl   $0x80286e,(%esp)
  800199:	e8 ae 02 00 00       	call   80044c <_panic>
	if (r != 0)
  80019e:	85 c0                	test   %eax,%eax
  8001a0:	74 20                	je     8001c2 <umain+0x165>
		panic("first opencons used fd %d", r);
  8001a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001a6:	c7 44 24 08 7a 28 80 	movl   $0x80287a,0x8(%esp)
  8001ad:	00 
  8001ae:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  8001b5:	00 
  8001b6:	c7 04 24 6e 28 80 00 	movl   $0x80286e,(%esp)
  8001bd:	e8 8a 02 00 00       	call   80044c <_panic>
	if ((r = dup(0, 1)) < 0)
  8001c2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8001c9:	00 
  8001ca:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001d1:	e8 7d 11 00 00       	call   801353 <dup>
  8001d6:	85 c0                	test   %eax,%eax
  8001d8:	79 20                	jns    8001fa <umain+0x19d>
		panic("dup: %e", r);
  8001da:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001de:	c7 44 24 08 94 28 80 	movl   $0x802894,0x8(%esp)
  8001e5:	00 
  8001e6:	c7 44 24 04 3b 00 00 	movl   $0x3b,0x4(%esp)
  8001ed:	00 
  8001ee:	c7 04 24 6e 28 80 00 	movl   $0x80286e,(%esp)
  8001f5:	e8 52 02 00 00       	call   80044c <_panic>
	while (1) {
		cprintf("init: starting sh\n");
  8001fa:	c7 04 24 9c 28 80 00 	movl   $0x80289c,(%esp)
  800201:	e8 3e 03 00 00       	call   800544 <cprintf>
		r = spawnl("/sh", "sh", (char*)0);
  800206:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80020d:	00 
  80020e:	c7 44 24 04 b0 28 80 	movl   $0x8028b0,0x4(%esp)
  800215:	00 
  800216:	c7 04 24 af 28 80 00 	movl   $0x8028af,(%esp)
  80021d:	e8 c2 1d 00 00       	call   801fe4 <spawnl>
		if (r < 0) {
  800222:	85 c0                	test   %eax,%eax
  800224:	79 12                	jns    800238 <umain+0x1db>
			cprintf("init: spawn sh: %e\n", r);
  800226:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022a:	c7 04 24 b3 28 80 00 	movl   $0x8028b3,(%esp)
  800231:	e8 0e 03 00 00       	call   800544 <cprintf>
			continue;
  800236:	eb c2                	jmp    8001fa <umain+0x19d>
		}
		wait(r);
  800238:	89 04 24             	mov    %eax,(%esp)
  80023b:	e8 8c 21 00 00       	call   8023cc <wait>
  800240:	eb b8                	jmp    8001fa <umain+0x19d>
	...

00800244 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800247:	b8 00 00 00 00       	mov    $0x0,%eax
  80024c:	5d                   	pop    %ebp
  80024d:	c3                   	ret    

0080024e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80024e:	55                   	push   %ebp
  80024f:	89 e5                	mov    %esp,%ebp
  800251:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  800254:	c7 44 24 04 33 29 80 	movl   $0x802933,0x4(%esp)
  80025b:	00 
  80025c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80025f:	89 04 24             	mov    %eax,(%esp)
  800262:	e8 88 08 00 00       	call   800aef <strcpy>
	return 0;
}
  800267:	b8 00 00 00 00       	mov    $0x0,%eax
  80026c:	c9                   	leave  
  80026d:	c3                   	ret    

0080026e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80026e:	55                   	push   %ebp
  80026f:	89 e5                	mov    %esp,%ebp
  800271:	57                   	push   %edi
  800272:	56                   	push   %esi
  800273:	53                   	push   %ebx
  800274:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80027a:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80027f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800285:	eb 30                	jmp    8002b7 <devcons_write+0x49>
		m = n - tot;
  800287:	8b 75 10             	mov    0x10(%ebp),%esi
  80028a:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  80028c:	83 fe 7f             	cmp    $0x7f,%esi
  80028f:	76 05                	jbe    800296 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  800291:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800296:	89 74 24 08          	mov    %esi,0x8(%esp)
  80029a:	03 45 0c             	add    0xc(%ebp),%eax
  80029d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a1:	89 3c 24             	mov    %edi,(%esp)
  8002a4:	e8 bf 09 00 00       	call   800c68 <memmove>
		sys_cputs(buf, m);
  8002a9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002ad:	89 3c 24             	mov    %edi,(%esp)
  8002b0:	e8 5f 0b 00 00       	call   800e14 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8002b5:	01 f3                	add    %esi,%ebx
  8002b7:	89 d8                	mov    %ebx,%eax
  8002b9:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8002bc:	72 c9                	jb     800287 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8002be:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8002c4:	5b                   	pop    %ebx
  8002c5:	5e                   	pop    %esi
  8002c6:	5f                   	pop    %edi
  8002c7:	5d                   	pop    %ebp
  8002c8:	c3                   	ret    

008002c9 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8002c9:	55                   	push   %ebp
  8002ca:	89 e5                	mov    %esp,%ebp
  8002cc:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8002cf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8002d3:	75 07                	jne    8002dc <devcons_read+0x13>
  8002d5:	eb 25                	jmp    8002fc <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8002d7:	e8 e6 0b 00 00       	call   800ec2 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8002dc:	e8 51 0b 00 00       	call   800e32 <sys_cgetc>
  8002e1:	85 c0                	test   %eax,%eax
  8002e3:	74 f2                	je     8002d7 <devcons_read+0xe>
  8002e5:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8002e7:	85 c0                	test   %eax,%eax
  8002e9:	78 1d                	js     800308 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8002eb:	83 f8 04             	cmp    $0x4,%eax
  8002ee:	74 13                	je     800303 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8002f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002f3:	88 10                	mov    %dl,(%eax)
	return 1;
  8002f5:	b8 01 00 00 00       	mov    $0x1,%eax
  8002fa:	eb 0c                	jmp    800308 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8002fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800301:	eb 05                	jmp    800308 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800303:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800308:	c9                   	leave  
  800309:	c3                   	ret    

0080030a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  800310:	8b 45 08             	mov    0x8(%ebp),%eax
  800313:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800316:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80031d:	00 
  80031e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800321:	89 04 24             	mov    %eax,(%esp)
  800324:	e8 eb 0a 00 00       	call   800e14 <sys_cputs>
}
  800329:	c9                   	leave  
  80032a:	c3                   	ret    

0080032b <getchar>:

int
getchar(void)
{
  80032b:	55                   	push   %ebp
  80032c:	89 e5                	mov    %esp,%ebp
  80032e:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800331:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  800338:	00 
  800339:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80033c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800340:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800347:	e8 1a 11 00 00       	call   801466 <read>
	if (r < 0)
  80034c:	85 c0                	test   %eax,%eax
  80034e:	78 0f                	js     80035f <getchar+0x34>
		return r;
	if (r < 1)
  800350:	85 c0                	test   %eax,%eax
  800352:	7e 06                	jle    80035a <getchar+0x2f>
		return -E_EOF;
	return c;
  800354:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800358:	eb 05                	jmp    80035f <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80035a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80035f:	c9                   	leave  
  800360:	c3                   	ret    

00800361 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800361:	55                   	push   %ebp
  800362:	89 e5                	mov    %esp,%ebp
  800364:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800367:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80036a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80036e:	8b 45 08             	mov    0x8(%ebp),%eax
  800371:	89 04 24             	mov    %eax,(%esp)
  800374:	e8 51 0e 00 00       	call   8011ca <fd_lookup>
  800379:	85 c0                	test   %eax,%eax
  80037b:	78 11                	js     80038e <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80037d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800380:	8b 15 70 47 80 00    	mov    0x804770,%edx
  800386:	39 10                	cmp    %edx,(%eax)
  800388:	0f 94 c0             	sete   %al
  80038b:	0f b6 c0             	movzbl %al,%eax
}
  80038e:	c9                   	leave  
  80038f:	c3                   	ret    

00800390 <opencons>:

int
opencons(void)
{
  800390:	55                   	push   %ebp
  800391:	89 e5                	mov    %esp,%ebp
  800393:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800396:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800399:	89 04 24             	mov    %eax,(%esp)
  80039c:	e8 d6 0d 00 00       	call   801177 <fd_alloc>
  8003a1:	85 c0                	test   %eax,%eax
  8003a3:	78 3c                	js     8003e1 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8003a5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8003ac:	00 
  8003ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8003b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8003bb:	e8 21 0b 00 00       	call   800ee1 <sys_page_alloc>
  8003c0:	85 c0                	test   %eax,%eax
  8003c2:	78 1d                	js     8003e1 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8003c4:	8b 15 70 47 80 00    	mov    0x804770,%edx
  8003ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8003cd:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8003cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8003d2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8003d9:	89 04 24             	mov    %eax,(%esp)
  8003dc:	e8 6b 0d 00 00       	call   80114c <fd2num>
}
  8003e1:	c9                   	leave  
  8003e2:	c3                   	ret    
	...

008003e4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8003e4:	55                   	push   %ebp
  8003e5:	89 e5                	mov    %esp,%ebp
  8003e7:	56                   	push   %esi
  8003e8:	53                   	push   %ebx
  8003e9:	83 ec 10             	sub    $0x10,%esp
  8003ec:	8b 75 08             	mov    0x8(%ebp),%esi
  8003ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8003f2:	e8 ac 0a 00 00       	call   800ea3 <sys_getenvid>
  8003f7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8003fc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800403:	c1 e0 07             	shl    $0x7,%eax
  800406:	29 d0                	sub    %edx,%eax
  800408:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80040d:	a3 90 67 80 00       	mov    %eax,0x806790

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800412:	85 f6                	test   %esi,%esi
  800414:	7e 07                	jle    80041d <libmain+0x39>
		binaryname = argv[0];
  800416:	8b 03                	mov    (%ebx),%eax
  800418:	a3 8c 47 80 00       	mov    %eax,0x80478c

	// call user main routine
	umain(argc, argv);
  80041d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800421:	89 34 24             	mov    %esi,(%esp)
  800424:	e8 34 fc ff ff       	call   80005d <umain>

	// exit gracefully
	exit();
  800429:	e8 0a 00 00 00       	call   800438 <exit>
}
  80042e:	83 c4 10             	add    $0x10,%esp
  800431:	5b                   	pop    %ebx
  800432:	5e                   	pop    %esi
  800433:	5d                   	pop    %ebp
  800434:	c3                   	ret    
  800435:	00 00                	add    %al,(%eax)
	...

00800438 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800438:	55                   	push   %ebp
  800439:	89 e5                	mov    %esp,%ebp
  80043b:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  80043e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800445:	e8 07 0a 00 00       	call   800e51 <sys_env_destroy>
}
  80044a:	c9                   	leave  
  80044b:	c3                   	ret    

0080044c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80044c:	55                   	push   %ebp
  80044d:	89 e5                	mov    %esp,%ebp
  80044f:	56                   	push   %esi
  800450:	53                   	push   %ebx
  800451:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800454:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800457:	8b 1d 8c 47 80 00    	mov    0x80478c,%ebx
  80045d:	e8 41 0a 00 00       	call   800ea3 <sys_getenvid>
  800462:	8b 55 0c             	mov    0xc(%ebp),%edx
  800465:	89 54 24 10          	mov    %edx,0x10(%esp)
  800469:	8b 55 08             	mov    0x8(%ebp),%edx
  80046c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800470:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800474:	89 44 24 04          	mov    %eax,0x4(%esp)
  800478:	c7 04 24 4c 29 80 00 	movl   $0x80294c,(%esp)
  80047f:	e8 c0 00 00 00       	call   800544 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800484:	89 74 24 04          	mov    %esi,0x4(%esp)
  800488:	8b 45 10             	mov    0x10(%ebp),%eax
  80048b:	89 04 24             	mov    %eax,(%esp)
  80048e:	e8 50 00 00 00       	call   8004e3 <vcprintf>
	cprintf("\n");
  800493:	c7 04 24 63 2e 80 00 	movl   $0x802e63,(%esp)
  80049a:	e8 a5 00 00 00       	call   800544 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80049f:	cc                   	int3   
  8004a0:	eb fd                	jmp    80049f <_panic+0x53>
	...

008004a4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004a4:	55                   	push   %ebp
  8004a5:	89 e5                	mov    %esp,%ebp
  8004a7:	53                   	push   %ebx
  8004a8:	83 ec 14             	sub    $0x14,%esp
  8004ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8004ae:	8b 03                	mov    (%ebx),%eax
  8004b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8004b3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8004b7:	40                   	inc    %eax
  8004b8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8004ba:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004bf:	75 19                	jne    8004da <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8004c1:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8004c8:	00 
  8004c9:	8d 43 08             	lea    0x8(%ebx),%eax
  8004cc:	89 04 24             	mov    %eax,(%esp)
  8004cf:	e8 40 09 00 00       	call   800e14 <sys_cputs>
		b->idx = 0;
  8004d4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8004da:	ff 43 04             	incl   0x4(%ebx)
}
  8004dd:	83 c4 14             	add    $0x14,%esp
  8004e0:	5b                   	pop    %ebx
  8004e1:	5d                   	pop    %ebp
  8004e2:	c3                   	ret    

008004e3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004e3:	55                   	push   %ebp
  8004e4:	89 e5                	mov    %esp,%ebp
  8004e6:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8004ec:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004f3:	00 00 00 
	b.cnt = 0;
  8004f6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004fd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800500:	8b 45 0c             	mov    0xc(%ebp),%eax
  800503:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800507:	8b 45 08             	mov    0x8(%ebp),%eax
  80050a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80050e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800514:	89 44 24 04          	mov    %eax,0x4(%esp)
  800518:	c7 04 24 a4 04 80 00 	movl   $0x8004a4,(%esp)
  80051f:	e8 82 01 00 00       	call   8006a6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800524:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80052a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80052e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800534:	89 04 24             	mov    %eax,(%esp)
  800537:	e8 d8 08 00 00       	call   800e14 <sys_cputs>

	return b.cnt;
}
  80053c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800542:	c9                   	leave  
  800543:	c3                   	ret    

00800544 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800544:	55                   	push   %ebp
  800545:	89 e5                	mov    %esp,%ebp
  800547:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80054a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80054d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800551:	8b 45 08             	mov    0x8(%ebp),%eax
  800554:	89 04 24             	mov    %eax,(%esp)
  800557:	e8 87 ff ff ff       	call   8004e3 <vcprintf>
	va_end(ap);

	return cnt;
}
  80055c:	c9                   	leave  
  80055d:	c3                   	ret    
	...

00800560 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800560:	55                   	push   %ebp
  800561:	89 e5                	mov    %esp,%ebp
  800563:	57                   	push   %edi
  800564:	56                   	push   %esi
  800565:	53                   	push   %ebx
  800566:	83 ec 3c             	sub    $0x3c,%esp
  800569:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80056c:	89 d7                	mov    %edx,%edi
  80056e:	8b 45 08             	mov    0x8(%ebp),%eax
  800571:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800574:	8b 45 0c             	mov    0xc(%ebp),%eax
  800577:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80057a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80057d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800580:	85 c0                	test   %eax,%eax
  800582:	75 08                	jne    80058c <printnum+0x2c>
  800584:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800587:	39 45 10             	cmp    %eax,0x10(%ebp)
  80058a:	77 57                	ja     8005e3 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80058c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800590:	4b                   	dec    %ebx
  800591:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800595:	8b 45 10             	mov    0x10(%ebp),%eax
  800598:	89 44 24 08          	mov    %eax,0x8(%esp)
  80059c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8005a0:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8005a4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005ab:	00 
  8005ac:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005af:	89 04 24             	mov    %eax,(%esp)
  8005b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005b9:	e8 da 1f 00 00       	call   802598 <__udivdi3>
  8005be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005c2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8005c6:	89 04 24             	mov    %eax,(%esp)
  8005c9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005cd:	89 fa                	mov    %edi,%edx
  8005cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005d2:	e8 89 ff ff ff       	call   800560 <printnum>
  8005d7:	eb 0f                	jmp    8005e8 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8005d9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005dd:	89 34 24             	mov    %esi,(%esp)
  8005e0:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005e3:	4b                   	dec    %ebx
  8005e4:	85 db                	test   %ebx,%ebx
  8005e6:	7f f1                	jg     8005d9 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8005e8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005ec:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8005f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8005f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005f7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005fe:	00 
  8005ff:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800602:	89 04 24             	mov    %eax,(%esp)
  800605:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800608:	89 44 24 04          	mov    %eax,0x4(%esp)
  80060c:	e8 a7 20 00 00       	call   8026b8 <__umoddi3>
  800611:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800615:	0f be 80 6f 29 80 00 	movsbl 0x80296f(%eax),%eax
  80061c:	89 04 24             	mov    %eax,(%esp)
  80061f:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800622:	83 c4 3c             	add    $0x3c,%esp
  800625:	5b                   	pop    %ebx
  800626:	5e                   	pop    %esi
  800627:	5f                   	pop    %edi
  800628:	5d                   	pop    %ebp
  800629:	c3                   	ret    

0080062a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80062a:	55                   	push   %ebp
  80062b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80062d:	83 fa 01             	cmp    $0x1,%edx
  800630:	7e 0e                	jle    800640 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800632:	8b 10                	mov    (%eax),%edx
  800634:	8d 4a 08             	lea    0x8(%edx),%ecx
  800637:	89 08                	mov    %ecx,(%eax)
  800639:	8b 02                	mov    (%edx),%eax
  80063b:	8b 52 04             	mov    0x4(%edx),%edx
  80063e:	eb 22                	jmp    800662 <getuint+0x38>
	else if (lflag)
  800640:	85 d2                	test   %edx,%edx
  800642:	74 10                	je     800654 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800644:	8b 10                	mov    (%eax),%edx
  800646:	8d 4a 04             	lea    0x4(%edx),%ecx
  800649:	89 08                	mov    %ecx,(%eax)
  80064b:	8b 02                	mov    (%edx),%eax
  80064d:	ba 00 00 00 00       	mov    $0x0,%edx
  800652:	eb 0e                	jmp    800662 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800654:	8b 10                	mov    (%eax),%edx
  800656:	8d 4a 04             	lea    0x4(%edx),%ecx
  800659:	89 08                	mov    %ecx,(%eax)
  80065b:	8b 02                	mov    (%edx),%eax
  80065d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800662:	5d                   	pop    %ebp
  800663:	c3                   	ret    

00800664 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800664:	55                   	push   %ebp
  800665:	89 e5                	mov    %esp,%ebp
  800667:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80066a:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80066d:	8b 10                	mov    (%eax),%edx
  80066f:	3b 50 04             	cmp    0x4(%eax),%edx
  800672:	73 08                	jae    80067c <sprintputch+0x18>
		*b->buf++ = ch;
  800674:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800677:	88 0a                	mov    %cl,(%edx)
  800679:	42                   	inc    %edx
  80067a:	89 10                	mov    %edx,(%eax)
}
  80067c:	5d                   	pop    %ebp
  80067d:	c3                   	ret    

0080067e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80067e:	55                   	push   %ebp
  80067f:	89 e5                	mov    %esp,%ebp
  800681:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800684:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800687:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80068b:	8b 45 10             	mov    0x10(%ebp),%eax
  80068e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800692:	8b 45 0c             	mov    0xc(%ebp),%eax
  800695:	89 44 24 04          	mov    %eax,0x4(%esp)
  800699:	8b 45 08             	mov    0x8(%ebp),%eax
  80069c:	89 04 24             	mov    %eax,(%esp)
  80069f:	e8 02 00 00 00       	call   8006a6 <vprintfmt>
	va_end(ap);
}
  8006a4:	c9                   	leave  
  8006a5:	c3                   	ret    

008006a6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006a6:	55                   	push   %ebp
  8006a7:	89 e5                	mov    %esp,%ebp
  8006a9:	57                   	push   %edi
  8006aa:	56                   	push   %esi
  8006ab:	53                   	push   %ebx
  8006ac:	83 ec 4c             	sub    $0x4c,%esp
  8006af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006b2:	8b 75 10             	mov    0x10(%ebp),%esi
  8006b5:	eb 12                	jmp    8006c9 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006b7:	85 c0                	test   %eax,%eax
  8006b9:	0f 84 6b 03 00 00    	je     800a2a <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8006bf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c3:	89 04 24             	mov    %eax,(%esp)
  8006c6:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006c9:	0f b6 06             	movzbl (%esi),%eax
  8006cc:	46                   	inc    %esi
  8006cd:	83 f8 25             	cmp    $0x25,%eax
  8006d0:	75 e5                	jne    8006b7 <vprintfmt+0x11>
  8006d2:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8006d6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8006dd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8006e2:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8006e9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ee:	eb 26                	jmp    800716 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f0:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8006f3:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8006f7:	eb 1d                	jmp    800716 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f9:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8006fc:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800700:	eb 14                	jmp    800716 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800702:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800705:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80070c:	eb 08                	jmp    800716 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80070e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800711:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800716:	0f b6 06             	movzbl (%esi),%eax
  800719:	8d 56 01             	lea    0x1(%esi),%edx
  80071c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80071f:	8a 16                	mov    (%esi),%dl
  800721:	83 ea 23             	sub    $0x23,%edx
  800724:	80 fa 55             	cmp    $0x55,%dl
  800727:	0f 87 e1 02 00 00    	ja     800a0e <vprintfmt+0x368>
  80072d:	0f b6 d2             	movzbl %dl,%edx
  800730:	ff 24 95 c0 2a 80 00 	jmp    *0x802ac0(,%edx,4)
  800737:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80073a:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80073f:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800742:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800746:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800749:	8d 50 d0             	lea    -0x30(%eax),%edx
  80074c:	83 fa 09             	cmp    $0x9,%edx
  80074f:	77 2a                	ja     80077b <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800751:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800752:	eb eb                	jmp    80073f <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800754:	8b 45 14             	mov    0x14(%ebp),%eax
  800757:	8d 50 04             	lea    0x4(%eax),%edx
  80075a:	89 55 14             	mov    %edx,0x14(%ebp)
  80075d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80075f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800762:	eb 17                	jmp    80077b <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800764:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800768:	78 98                	js     800702 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80076a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80076d:	eb a7                	jmp    800716 <vprintfmt+0x70>
  80076f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800772:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800779:	eb 9b                	jmp    800716 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80077b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80077f:	79 95                	jns    800716 <vprintfmt+0x70>
  800781:	eb 8b                	jmp    80070e <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800783:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800784:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800787:	eb 8d                	jmp    800716 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800789:	8b 45 14             	mov    0x14(%ebp),%eax
  80078c:	8d 50 04             	lea    0x4(%eax),%edx
  80078f:	89 55 14             	mov    %edx,0x14(%ebp)
  800792:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800796:	8b 00                	mov    (%eax),%eax
  800798:	89 04 24             	mov    %eax,(%esp)
  80079b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80079e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8007a1:	e9 23 ff ff ff       	jmp    8006c9 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8007a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a9:	8d 50 04             	lea    0x4(%eax),%edx
  8007ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8007af:	8b 00                	mov    (%eax),%eax
  8007b1:	85 c0                	test   %eax,%eax
  8007b3:	79 02                	jns    8007b7 <vprintfmt+0x111>
  8007b5:	f7 d8                	neg    %eax
  8007b7:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8007b9:	83 f8 0f             	cmp    $0xf,%eax
  8007bc:	7f 0b                	jg     8007c9 <vprintfmt+0x123>
  8007be:	8b 04 85 20 2c 80 00 	mov    0x802c20(,%eax,4),%eax
  8007c5:	85 c0                	test   %eax,%eax
  8007c7:	75 23                	jne    8007ec <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8007c9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007cd:	c7 44 24 08 87 29 80 	movl   $0x802987,0x8(%esp)
  8007d4:	00 
  8007d5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007dc:	89 04 24             	mov    %eax,(%esp)
  8007df:	e8 9a fe ff ff       	call   80067e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007e4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8007e7:	e9 dd fe ff ff       	jmp    8006c9 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8007ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007f0:	c7 44 24 08 51 2d 80 	movl   $0x802d51,0x8(%esp)
  8007f7:	00 
  8007f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8007ff:	89 14 24             	mov    %edx,(%esp)
  800802:	e8 77 fe ff ff       	call   80067e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800807:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80080a:	e9 ba fe ff ff       	jmp    8006c9 <vprintfmt+0x23>
  80080f:	89 f9                	mov    %edi,%ecx
  800811:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800814:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800817:	8b 45 14             	mov    0x14(%ebp),%eax
  80081a:	8d 50 04             	lea    0x4(%eax),%edx
  80081d:	89 55 14             	mov    %edx,0x14(%ebp)
  800820:	8b 30                	mov    (%eax),%esi
  800822:	85 f6                	test   %esi,%esi
  800824:	75 05                	jne    80082b <vprintfmt+0x185>
				p = "(null)";
  800826:	be 80 29 80 00       	mov    $0x802980,%esi
			if (width > 0 && padc != '-')
  80082b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80082f:	0f 8e 84 00 00 00    	jle    8008b9 <vprintfmt+0x213>
  800835:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800839:	74 7e                	je     8008b9 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80083b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80083f:	89 34 24             	mov    %esi,(%esp)
  800842:	e8 8b 02 00 00       	call   800ad2 <strnlen>
  800847:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80084a:	29 c2                	sub    %eax,%edx
  80084c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80084f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800853:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800856:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800859:	89 de                	mov    %ebx,%esi
  80085b:	89 d3                	mov    %edx,%ebx
  80085d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80085f:	eb 0b                	jmp    80086c <vprintfmt+0x1c6>
					putch(padc, putdat);
  800861:	89 74 24 04          	mov    %esi,0x4(%esp)
  800865:	89 3c 24             	mov    %edi,(%esp)
  800868:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80086b:	4b                   	dec    %ebx
  80086c:	85 db                	test   %ebx,%ebx
  80086e:	7f f1                	jg     800861 <vprintfmt+0x1bb>
  800870:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800873:	89 f3                	mov    %esi,%ebx
  800875:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800878:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80087b:	85 c0                	test   %eax,%eax
  80087d:	79 05                	jns    800884 <vprintfmt+0x1de>
  80087f:	b8 00 00 00 00       	mov    $0x0,%eax
  800884:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800887:	29 c2                	sub    %eax,%edx
  800889:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80088c:	eb 2b                	jmp    8008b9 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80088e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800892:	74 18                	je     8008ac <vprintfmt+0x206>
  800894:	8d 50 e0             	lea    -0x20(%eax),%edx
  800897:	83 fa 5e             	cmp    $0x5e,%edx
  80089a:	76 10                	jbe    8008ac <vprintfmt+0x206>
					putch('?', putdat);
  80089c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008a0:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8008a7:	ff 55 08             	call   *0x8(%ebp)
  8008aa:	eb 0a                	jmp    8008b6 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8008ac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008b0:	89 04 24             	mov    %eax,(%esp)
  8008b3:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008b6:	ff 4d e4             	decl   -0x1c(%ebp)
  8008b9:	0f be 06             	movsbl (%esi),%eax
  8008bc:	46                   	inc    %esi
  8008bd:	85 c0                	test   %eax,%eax
  8008bf:	74 21                	je     8008e2 <vprintfmt+0x23c>
  8008c1:	85 ff                	test   %edi,%edi
  8008c3:	78 c9                	js     80088e <vprintfmt+0x1e8>
  8008c5:	4f                   	dec    %edi
  8008c6:	79 c6                	jns    80088e <vprintfmt+0x1e8>
  8008c8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008cb:	89 de                	mov    %ebx,%esi
  8008cd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8008d0:	eb 18                	jmp    8008ea <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8008d2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008d6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8008dd:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8008df:	4b                   	dec    %ebx
  8008e0:	eb 08                	jmp    8008ea <vprintfmt+0x244>
  8008e2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e5:	89 de                	mov    %ebx,%esi
  8008e7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8008ea:	85 db                	test   %ebx,%ebx
  8008ec:	7f e4                	jg     8008d2 <vprintfmt+0x22c>
  8008ee:	89 7d 08             	mov    %edi,0x8(%ebp)
  8008f1:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008f3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008f6:	e9 ce fd ff ff       	jmp    8006c9 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008fb:	83 f9 01             	cmp    $0x1,%ecx
  8008fe:	7e 10                	jle    800910 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800900:	8b 45 14             	mov    0x14(%ebp),%eax
  800903:	8d 50 08             	lea    0x8(%eax),%edx
  800906:	89 55 14             	mov    %edx,0x14(%ebp)
  800909:	8b 30                	mov    (%eax),%esi
  80090b:	8b 78 04             	mov    0x4(%eax),%edi
  80090e:	eb 26                	jmp    800936 <vprintfmt+0x290>
	else if (lflag)
  800910:	85 c9                	test   %ecx,%ecx
  800912:	74 12                	je     800926 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800914:	8b 45 14             	mov    0x14(%ebp),%eax
  800917:	8d 50 04             	lea    0x4(%eax),%edx
  80091a:	89 55 14             	mov    %edx,0x14(%ebp)
  80091d:	8b 30                	mov    (%eax),%esi
  80091f:	89 f7                	mov    %esi,%edi
  800921:	c1 ff 1f             	sar    $0x1f,%edi
  800924:	eb 10                	jmp    800936 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800926:	8b 45 14             	mov    0x14(%ebp),%eax
  800929:	8d 50 04             	lea    0x4(%eax),%edx
  80092c:	89 55 14             	mov    %edx,0x14(%ebp)
  80092f:	8b 30                	mov    (%eax),%esi
  800931:	89 f7                	mov    %esi,%edi
  800933:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800936:	85 ff                	test   %edi,%edi
  800938:	78 0a                	js     800944 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80093a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80093f:	e9 8c 00 00 00       	jmp    8009d0 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800944:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800948:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80094f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800952:	f7 de                	neg    %esi
  800954:	83 d7 00             	adc    $0x0,%edi
  800957:	f7 df                	neg    %edi
			}
			base = 10;
  800959:	b8 0a 00 00 00       	mov    $0xa,%eax
  80095e:	eb 70                	jmp    8009d0 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800960:	89 ca                	mov    %ecx,%edx
  800962:	8d 45 14             	lea    0x14(%ebp),%eax
  800965:	e8 c0 fc ff ff       	call   80062a <getuint>
  80096a:	89 c6                	mov    %eax,%esi
  80096c:	89 d7                	mov    %edx,%edi
			base = 10;
  80096e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800973:	eb 5b                	jmp    8009d0 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  800975:	89 ca                	mov    %ecx,%edx
  800977:	8d 45 14             	lea    0x14(%ebp),%eax
  80097a:	e8 ab fc ff ff       	call   80062a <getuint>
  80097f:	89 c6                	mov    %eax,%esi
  800981:	89 d7                	mov    %edx,%edi
			base = 8;
  800983:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800988:	eb 46                	jmp    8009d0 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  80098a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80098e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800995:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800998:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80099c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8009a3:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8009a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a9:	8d 50 04             	lea    0x4(%eax),%edx
  8009ac:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8009af:	8b 30                	mov    (%eax),%esi
  8009b1:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8009b6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8009bb:	eb 13                	jmp    8009d0 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8009bd:	89 ca                	mov    %ecx,%edx
  8009bf:	8d 45 14             	lea    0x14(%ebp),%eax
  8009c2:	e8 63 fc ff ff       	call   80062a <getuint>
  8009c7:	89 c6                	mov    %eax,%esi
  8009c9:	89 d7                	mov    %edx,%edi
			base = 16;
  8009cb:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8009d0:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8009d4:	89 54 24 10          	mov    %edx,0x10(%esp)
  8009d8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8009db:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8009df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009e3:	89 34 24             	mov    %esi,(%esp)
  8009e6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009ea:	89 da                	mov    %ebx,%edx
  8009ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ef:	e8 6c fb ff ff       	call   800560 <printnum>
			break;
  8009f4:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8009f7:	e9 cd fc ff ff       	jmp    8006c9 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8009fc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a00:	89 04 24             	mov    %eax,(%esp)
  800a03:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a06:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a09:	e9 bb fc ff ff       	jmp    8006c9 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a0e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a12:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a19:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a1c:	eb 01                	jmp    800a1f <vprintfmt+0x379>
  800a1e:	4e                   	dec    %esi
  800a1f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800a23:	75 f9                	jne    800a1e <vprintfmt+0x378>
  800a25:	e9 9f fc ff ff       	jmp    8006c9 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800a2a:	83 c4 4c             	add    $0x4c,%esp
  800a2d:	5b                   	pop    %ebx
  800a2e:	5e                   	pop    %esi
  800a2f:	5f                   	pop    %edi
  800a30:	5d                   	pop    %ebp
  800a31:	c3                   	ret    

00800a32 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a32:	55                   	push   %ebp
  800a33:	89 e5                	mov    %esp,%ebp
  800a35:	83 ec 28             	sub    $0x28,%esp
  800a38:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a3e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a41:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a45:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a48:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a4f:	85 c0                	test   %eax,%eax
  800a51:	74 30                	je     800a83 <vsnprintf+0x51>
  800a53:	85 d2                	test   %edx,%edx
  800a55:	7e 33                	jle    800a8a <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a57:	8b 45 14             	mov    0x14(%ebp),%eax
  800a5a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a5e:	8b 45 10             	mov    0x10(%ebp),%eax
  800a61:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a65:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a68:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a6c:	c7 04 24 64 06 80 00 	movl   $0x800664,(%esp)
  800a73:	e8 2e fc ff ff       	call   8006a6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a78:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a7b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a81:	eb 0c                	jmp    800a8f <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a83:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a88:	eb 05                	jmp    800a8f <vsnprintf+0x5d>
  800a8a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a8f:	c9                   	leave  
  800a90:	c3                   	ret    

00800a91 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a91:	55                   	push   %ebp
  800a92:	89 e5                	mov    %esp,%ebp
  800a94:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a97:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a9a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a9e:	8b 45 10             	mov    0x10(%ebp),%eax
  800aa1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aa5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aac:	8b 45 08             	mov    0x8(%ebp),%eax
  800aaf:	89 04 24             	mov    %eax,(%esp)
  800ab2:	e8 7b ff ff ff       	call   800a32 <vsnprintf>
	va_end(ap);

	return rc;
}
  800ab7:	c9                   	leave  
  800ab8:	c3                   	ret    
  800ab9:	00 00                	add    %al,(%eax)
	...

00800abc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ac2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac7:	eb 01                	jmp    800aca <strlen+0xe>
		n++;
  800ac9:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800aca:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ace:	75 f9                	jne    800ac9 <strlen+0xd>
		n++;
	return n;
}
  800ad0:	5d                   	pop    %ebp
  800ad1:	c3                   	ret    

00800ad2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ad2:	55                   	push   %ebp
  800ad3:	89 e5                	mov    %esp,%ebp
  800ad5:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800ad8:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800adb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae0:	eb 01                	jmp    800ae3 <strnlen+0x11>
		n++;
  800ae2:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ae3:	39 d0                	cmp    %edx,%eax
  800ae5:	74 06                	je     800aed <strnlen+0x1b>
  800ae7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800aeb:	75 f5                	jne    800ae2 <strnlen+0x10>
		n++;
	return n;
}
  800aed:	5d                   	pop    %ebp
  800aee:	c3                   	ret    

00800aef <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800aef:	55                   	push   %ebp
  800af0:	89 e5                	mov    %esp,%ebp
  800af2:	53                   	push   %ebx
  800af3:	8b 45 08             	mov    0x8(%ebp),%eax
  800af6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800af9:	ba 00 00 00 00       	mov    $0x0,%edx
  800afe:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800b01:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800b04:	42                   	inc    %edx
  800b05:	84 c9                	test   %cl,%cl
  800b07:	75 f5                	jne    800afe <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800b09:	5b                   	pop    %ebx
  800b0a:	5d                   	pop    %ebp
  800b0b:	c3                   	ret    

00800b0c <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	53                   	push   %ebx
  800b10:	83 ec 08             	sub    $0x8,%esp
  800b13:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b16:	89 1c 24             	mov    %ebx,(%esp)
  800b19:	e8 9e ff ff ff       	call   800abc <strlen>
	strcpy(dst + len, src);
  800b1e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b21:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b25:	01 d8                	add    %ebx,%eax
  800b27:	89 04 24             	mov    %eax,(%esp)
  800b2a:	e8 c0 ff ff ff       	call   800aef <strcpy>
	return dst;
}
  800b2f:	89 d8                	mov    %ebx,%eax
  800b31:	83 c4 08             	add    $0x8,%esp
  800b34:	5b                   	pop    %ebx
  800b35:	5d                   	pop    %ebp
  800b36:	c3                   	ret    

00800b37 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	56                   	push   %esi
  800b3b:	53                   	push   %ebx
  800b3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b42:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b45:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b4a:	eb 0c                	jmp    800b58 <strncpy+0x21>
		*dst++ = *src;
  800b4c:	8a 1a                	mov    (%edx),%bl
  800b4e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b51:	80 3a 01             	cmpb   $0x1,(%edx)
  800b54:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b57:	41                   	inc    %ecx
  800b58:	39 f1                	cmp    %esi,%ecx
  800b5a:	75 f0                	jne    800b4c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b5c:	5b                   	pop    %ebx
  800b5d:	5e                   	pop    %esi
  800b5e:	5d                   	pop    %ebp
  800b5f:	c3                   	ret    

00800b60 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b60:	55                   	push   %ebp
  800b61:	89 e5                	mov    %esp,%ebp
  800b63:	56                   	push   %esi
  800b64:	53                   	push   %ebx
  800b65:	8b 75 08             	mov    0x8(%ebp),%esi
  800b68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b6b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b6e:	85 d2                	test   %edx,%edx
  800b70:	75 0a                	jne    800b7c <strlcpy+0x1c>
  800b72:	89 f0                	mov    %esi,%eax
  800b74:	eb 1a                	jmp    800b90 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b76:	88 18                	mov    %bl,(%eax)
  800b78:	40                   	inc    %eax
  800b79:	41                   	inc    %ecx
  800b7a:	eb 02                	jmp    800b7e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b7c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800b7e:	4a                   	dec    %edx
  800b7f:	74 0a                	je     800b8b <strlcpy+0x2b>
  800b81:	8a 19                	mov    (%ecx),%bl
  800b83:	84 db                	test   %bl,%bl
  800b85:	75 ef                	jne    800b76 <strlcpy+0x16>
  800b87:	89 c2                	mov    %eax,%edx
  800b89:	eb 02                	jmp    800b8d <strlcpy+0x2d>
  800b8b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800b8d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800b90:	29 f0                	sub    %esi,%eax
}
  800b92:	5b                   	pop    %ebx
  800b93:	5e                   	pop    %esi
  800b94:	5d                   	pop    %ebp
  800b95:	c3                   	ret    

00800b96 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b96:	55                   	push   %ebp
  800b97:	89 e5                	mov    %esp,%ebp
  800b99:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b9c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b9f:	eb 02                	jmp    800ba3 <strcmp+0xd>
		p++, q++;
  800ba1:	41                   	inc    %ecx
  800ba2:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ba3:	8a 01                	mov    (%ecx),%al
  800ba5:	84 c0                	test   %al,%al
  800ba7:	74 04                	je     800bad <strcmp+0x17>
  800ba9:	3a 02                	cmp    (%edx),%al
  800bab:	74 f4                	je     800ba1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800bad:	0f b6 c0             	movzbl %al,%eax
  800bb0:	0f b6 12             	movzbl (%edx),%edx
  800bb3:	29 d0                	sub    %edx,%eax
}
  800bb5:	5d                   	pop    %ebp
  800bb6:	c3                   	ret    

00800bb7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800bb7:	55                   	push   %ebp
  800bb8:	89 e5                	mov    %esp,%ebp
  800bba:	53                   	push   %ebx
  800bbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc1:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800bc4:	eb 03                	jmp    800bc9 <strncmp+0x12>
		n--, p++, q++;
  800bc6:	4a                   	dec    %edx
  800bc7:	40                   	inc    %eax
  800bc8:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800bc9:	85 d2                	test   %edx,%edx
  800bcb:	74 14                	je     800be1 <strncmp+0x2a>
  800bcd:	8a 18                	mov    (%eax),%bl
  800bcf:	84 db                	test   %bl,%bl
  800bd1:	74 04                	je     800bd7 <strncmp+0x20>
  800bd3:	3a 19                	cmp    (%ecx),%bl
  800bd5:	74 ef                	je     800bc6 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800bd7:	0f b6 00             	movzbl (%eax),%eax
  800bda:	0f b6 11             	movzbl (%ecx),%edx
  800bdd:	29 d0                	sub    %edx,%eax
  800bdf:	eb 05                	jmp    800be6 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800be1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800be6:	5b                   	pop    %ebx
  800be7:	5d                   	pop    %ebp
  800be8:	c3                   	ret    

00800be9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
  800bec:	8b 45 08             	mov    0x8(%ebp),%eax
  800bef:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800bf2:	eb 05                	jmp    800bf9 <strchr+0x10>
		if (*s == c)
  800bf4:	38 ca                	cmp    %cl,%dl
  800bf6:	74 0c                	je     800c04 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800bf8:	40                   	inc    %eax
  800bf9:	8a 10                	mov    (%eax),%dl
  800bfb:	84 d2                	test   %dl,%dl
  800bfd:	75 f5                	jne    800bf4 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800bff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c04:	5d                   	pop    %ebp
  800c05:	c3                   	ret    

00800c06 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
  800c09:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800c0f:	eb 05                	jmp    800c16 <strfind+0x10>
		if (*s == c)
  800c11:	38 ca                	cmp    %cl,%dl
  800c13:	74 07                	je     800c1c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c15:	40                   	inc    %eax
  800c16:	8a 10                	mov    (%eax),%dl
  800c18:	84 d2                	test   %dl,%dl
  800c1a:	75 f5                	jne    800c11 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800c1c:	5d                   	pop    %ebp
  800c1d:	c3                   	ret    

00800c1e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c1e:	55                   	push   %ebp
  800c1f:	89 e5                	mov    %esp,%ebp
  800c21:	57                   	push   %edi
  800c22:	56                   	push   %esi
  800c23:	53                   	push   %ebx
  800c24:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c27:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c2a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c2d:	85 c9                	test   %ecx,%ecx
  800c2f:	74 30                	je     800c61 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c31:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c37:	75 25                	jne    800c5e <memset+0x40>
  800c39:	f6 c1 03             	test   $0x3,%cl
  800c3c:	75 20                	jne    800c5e <memset+0x40>
		c &= 0xFF;
  800c3e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c41:	89 d3                	mov    %edx,%ebx
  800c43:	c1 e3 08             	shl    $0x8,%ebx
  800c46:	89 d6                	mov    %edx,%esi
  800c48:	c1 e6 18             	shl    $0x18,%esi
  800c4b:	89 d0                	mov    %edx,%eax
  800c4d:	c1 e0 10             	shl    $0x10,%eax
  800c50:	09 f0                	or     %esi,%eax
  800c52:	09 d0                	or     %edx,%eax
  800c54:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c56:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800c59:	fc                   	cld    
  800c5a:	f3 ab                	rep stos %eax,%es:(%edi)
  800c5c:	eb 03                	jmp    800c61 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c5e:	fc                   	cld    
  800c5f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c61:	89 f8                	mov    %edi,%eax
  800c63:	5b                   	pop    %ebx
  800c64:	5e                   	pop    %esi
  800c65:	5f                   	pop    %edi
  800c66:	5d                   	pop    %ebp
  800c67:	c3                   	ret    

00800c68 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c68:	55                   	push   %ebp
  800c69:	89 e5                	mov    %esp,%ebp
  800c6b:	57                   	push   %edi
  800c6c:	56                   	push   %esi
  800c6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c70:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c73:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c76:	39 c6                	cmp    %eax,%esi
  800c78:	73 34                	jae    800cae <memmove+0x46>
  800c7a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c7d:	39 d0                	cmp    %edx,%eax
  800c7f:	73 2d                	jae    800cae <memmove+0x46>
		s += n;
		d += n;
  800c81:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c84:	f6 c2 03             	test   $0x3,%dl
  800c87:	75 1b                	jne    800ca4 <memmove+0x3c>
  800c89:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c8f:	75 13                	jne    800ca4 <memmove+0x3c>
  800c91:	f6 c1 03             	test   $0x3,%cl
  800c94:	75 0e                	jne    800ca4 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c96:	83 ef 04             	sub    $0x4,%edi
  800c99:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c9c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c9f:	fd                   	std    
  800ca0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ca2:	eb 07                	jmp    800cab <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ca4:	4f                   	dec    %edi
  800ca5:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ca8:	fd                   	std    
  800ca9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800cab:	fc                   	cld    
  800cac:	eb 20                	jmp    800cce <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cae:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cb4:	75 13                	jne    800cc9 <memmove+0x61>
  800cb6:	a8 03                	test   $0x3,%al
  800cb8:	75 0f                	jne    800cc9 <memmove+0x61>
  800cba:	f6 c1 03             	test   $0x3,%cl
  800cbd:	75 0a                	jne    800cc9 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800cbf:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800cc2:	89 c7                	mov    %eax,%edi
  800cc4:	fc                   	cld    
  800cc5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cc7:	eb 05                	jmp    800cce <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800cc9:	89 c7                	mov    %eax,%edi
  800ccb:	fc                   	cld    
  800ccc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800cce:	5e                   	pop    %esi
  800ccf:	5f                   	pop    %edi
  800cd0:	5d                   	pop    %ebp
  800cd1:	c3                   	ret    

00800cd2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800cd2:	55                   	push   %ebp
  800cd3:	89 e5                	mov    %esp,%ebp
  800cd5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800cd8:	8b 45 10             	mov    0x10(%ebp),%eax
  800cdb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cdf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ce2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ce6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce9:	89 04 24             	mov    %eax,(%esp)
  800cec:	e8 77 ff ff ff       	call   800c68 <memmove>
}
  800cf1:	c9                   	leave  
  800cf2:	c3                   	ret    

00800cf3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cf3:	55                   	push   %ebp
  800cf4:	89 e5                	mov    %esp,%ebp
  800cf6:	57                   	push   %edi
  800cf7:	56                   	push   %esi
  800cf8:	53                   	push   %ebx
  800cf9:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cfc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cff:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d02:	ba 00 00 00 00       	mov    $0x0,%edx
  800d07:	eb 16                	jmp    800d1f <memcmp+0x2c>
		if (*s1 != *s2)
  800d09:	8a 04 17             	mov    (%edi,%edx,1),%al
  800d0c:	42                   	inc    %edx
  800d0d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800d11:	38 c8                	cmp    %cl,%al
  800d13:	74 0a                	je     800d1f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800d15:	0f b6 c0             	movzbl %al,%eax
  800d18:	0f b6 c9             	movzbl %cl,%ecx
  800d1b:	29 c8                	sub    %ecx,%eax
  800d1d:	eb 09                	jmp    800d28 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d1f:	39 da                	cmp    %ebx,%edx
  800d21:	75 e6                	jne    800d09 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d23:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d28:	5b                   	pop    %ebx
  800d29:	5e                   	pop    %esi
  800d2a:	5f                   	pop    %edi
  800d2b:	5d                   	pop    %ebp
  800d2c:	c3                   	ret    

00800d2d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d2d:	55                   	push   %ebp
  800d2e:	89 e5                	mov    %esp,%ebp
  800d30:	8b 45 08             	mov    0x8(%ebp),%eax
  800d33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800d36:	89 c2                	mov    %eax,%edx
  800d38:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d3b:	eb 05                	jmp    800d42 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d3d:	38 08                	cmp    %cl,(%eax)
  800d3f:	74 05                	je     800d46 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d41:	40                   	inc    %eax
  800d42:	39 d0                	cmp    %edx,%eax
  800d44:	72 f7                	jb     800d3d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d46:	5d                   	pop    %ebp
  800d47:	c3                   	ret    

00800d48 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d48:	55                   	push   %ebp
  800d49:	89 e5                	mov    %esp,%ebp
  800d4b:	57                   	push   %edi
  800d4c:	56                   	push   %esi
  800d4d:	53                   	push   %ebx
  800d4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d51:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d54:	eb 01                	jmp    800d57 <strtol+0xf>
		s++;
  800d56:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d57:	8a 02                	mov    (%edx),%al
  800d59:	3c 20                	cmp    $0x20,%al
  800d5b:	74 f9                	je     800d56 <strtol+0xe>
  800d5d:	3c 09                	cmp    $0x9,%al
  800d5f:	74 f5                	je     800d56 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d61:	3c 2b                	cmp    $0x2b,%al
  800d63:	75 08                	jne    800d6d <strtol+0x25>
		s++;
  800d65:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d66:	bf 00 00 00 00       	mov    $0x0,%edi
  800d6b:	eb 13                	jmp    800d80 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d6d:	3c 2d                	cmp    $0x2d,%al
  800d6f:	75 0a                	jne    800d7b <strtol+0x33>
		s++, neg = 1;
  800d71:	8d 52 01             	lea    0x1(%edx),%edx
  800d74:	bf 01 00 00 00       	mov    $0x1,%edi
  800d79:	eb 05                	jmp    800d80 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d7b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d80:	85 db                	test   %ebx,%ebx
  800d82:	74 05                	je     800d89 <strtol+0x41>
  800d84:	83 fb 10             	cmp    $0x10,%ebx
  800d87:	75 28                	jne    800db1 <strtol+0x69>
  800d89:	8a 02                	mov    (%edx),%al
  800d8b:	3c 30                	cmp    $0x30,%al
  800d8d:	75 10                	jne    800d9f <strtol+0x57>
  800d8f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d93:	75 0a                	jne    800d9f <strtol+0x57>
		s += 2, base = 16;
  800d95:	83 c2 02             	add    $0x2,%edx
  800d98:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d9d:	eb 12                	jmp    800db1 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800d9f:	85 db                	test   %ebx,%ebx
  800da1:	75 0e                	jne    800db1 <strtol+0x69>
  800da3:	3c 30                	cmp    $0x30,%al
  800da5:	75 05                	jne    800dac <strtol+0x64>
		s++, base = 8;
  800da7:	42                   	inc    %edx
  800da8:	b3 08                	mov    $0x8,%bl
  800daa:	eb 05                	jmp    800db1 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800dac:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800db1:	b8 00 00 00 00       	mov    $0x0,%eax
  800db6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800db8:	8a 0a                	mov    (%edx),%cl
  800dba:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800dbd:	80 fb 09             	cmp    $0x9,%bl
  800dc0:	77 08                	ja     800dca <strtol+0x82>
			dig = *s - '0';
  800dc2:	0f be c9             	movsbl %cl,%ecx
  800dc5:	83 e9 30             	sub    $0x30,%ecx
  800dc8:	eb 1e                	jmp    800de8 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800dca:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800dcd:	80 fb 19             	cmp    $0x19,%bl
  800dd0:	77 08                	ja     800dda <strtol+0x92>
			dig = *s - 'a' + 10;
  800dd2:	0f be c9             	movsbl %cl,%ecx
  800dd5:	83 e9 57             	sub    $0x57,%ecx
  800dd8:	eb 0e                	jmp    800de8 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800dda:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800ddd:	80 fb 19             	cmp    $0x19,%bl
  800de0:	77 12                	ja     800df4 <strtol+0xac>
			dig = *s - 'A' + 10;
  800de2:	0f be c9             	movsbl %cl,%ecx
  800de5:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800de8:	39 f1                	cmp    %esi,%ecx
  800dea:	7d 0c                	jge    800df8 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800dec:	42                   	inc    %edx
  800ded:	0f af c6             	imul   %esi,%eax
  800df0:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800df2:	eb c4                	jmp    800db8 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800df4:	89 c1                	mov    %eax,%ecx
  800df6:	eb 02                	jmp    800dfa <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800df8:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800dfa:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dfe:	74 05                	je     800e05 <strtol+0xbd>
		*endptr = (char *) s;
  800e00:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e03:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800e05:	85 ff                	test   %edi,%edi
  800e07:	74 04                	je     800e0d <strtol+0xc5>
  800e09:	89 c8                	mov    %ecx,%eax
  800e0b:	f7 d8                	neg    %eax
}
  800e0d:	5b                   	pop    %ebx
  800e0e:	5e                   	pop    %esi
  800e0f:	5f                   	pop    %edi
  800e10:	5d                   	pop    %ebp
  800e11:	c3                   	ret    
	...

00800e14 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e14:	55                   	push   %ebp
  800e15:	89 e5                	mov    %esp,%ebp
  800e17:	57                   	push   %edi
  800e18:	56                   	push   %esi
  800e19:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1a:	b8 00 00 00 00       	mov    $0x0,%eax
  800e1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e22:	8b 55 08             	mov    0x8(%ebp),%edx
  800e25:	89 c3                	mov    %eax,%ebx
  800e27:	89 c7                	mov    %eax,%edi
  800e29:	89 c6                	mov    %eax,%esi
  800e2b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e2d:	5b                   	pop    %ebx
  800e2e:	5e                   	pop    %esi
  800e2f:	5f                   	pop    %edi
  800e30:	5d                   	pop    %ebp
  800e31:	c3                   	ret    

00800e32 <sys_cgetc>:

int
sys_cgetc(void)
{
  800e32:	55                   	push   %ebp
  800e33:	89 e5                	mov    %esp,%ebp
  800e35:	57                   	push   %edi
  800e36:	56                   	push   %esi
  800e37:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e38:	ba 00 00 00 00       	mov    $0x0,%edx
  800e3d:	b8 01 00 00 00       	mov    $0x1,%eax
  800e42:	89 d1                	mov    %edx,%ecx
  800e44:	89 d3                	mov    %edx,%ebx
  800e46:	89 d7                	mov    %edx,%edi
  800e48:	89 d6                	mov    %edx,%esi
  800e4a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e4c:	5b                   	pop    %ebx
  800e4d:	5e                   	pop    %esi
  800e4e:	5f                   	pop    %edi
  800e4f:	5d                   	pop    %ebp
  800e50:	c3                   	ret    

00800e51 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e51:	55                   	push   %ebp
  800e52:	89 e5                	mov    %esp,%ebp
  800e54:	57                   	push   %edi
  800e55:	56                   	push   %esi
  800e56:	53                   	push   %ebx
  800e57:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e5f:	b8 03 00 00 00       	mov    $0x3,%eax
  800e64:	8b 55 08             	mov    0x8(%ebp),%edx
  800e67:	89 cb                	mov    %ecx,%ebx
  800e69:	89 cf                	mov    %ecx,%edi
  800e6b:	89 ce                	mov    %ecx,%esi
  800e6d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e6f:	85 c0                	test   %eax,%eax
  800e71:	7e 28                	jle    800e9b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e73:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e77:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800e7e:	00 
  800e7f:	c7 44 24 08 7f 2c 80 	movl   $0x802c7f,0x8(%esp)
  800e86:	00 
  800e87:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e8e:	00 
  800e8f:	c7 04 24 9c 2c 80 00 	movl   $0x802c9c,(%esp)
  800e96:	e8 b1 f5 ff ff       	call   80044c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e9b:	83 c4 2c             	add    $0x2c,%esp
  800e9e:	5b                   	pop    %ebx
  800e9f:	5e                   	pop    %esi
  800ea0:	5f                   	pop    %edi
  800ea1:	5d                   	pop    %ebp
  800ea2:	c3                   	ret    

00800ea3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ea3:	55                   	push   %ebp
  800ea4:	89 e5                	mov    %esp,%ebp
  800ea6:	57                   	push   %edi
  800ea7:	56                   	push   %esi
  800ea8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea9:	ba 00 00 00 00       	mov    $0x0,%edx
  800eae:	b8 02 00 00 00       	mov    $0x2,%eax
  800eb3:	89 d1                	mov    %edx,%ecx
  800eb5:	89 d3                	mov    %edx,%ebx
  800eb7:	89 d7                	mov    %edx,%edi
  800eb9:	89 d6                	mov    %edx,%esi
  800ebb:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ebd:	5b                   	pop    %ebx
  800ebe:	5e                   	pop    %esi
  800ebf:	5f                   	pop    %edi
  800ec0:	5d                   	pop    %ebp
  800ec1:	c3                   	ret    

00800ec2 <sys_yield>:

void
sys_yield(void)
{
  800ec2:	55                   	push   %ebp
  800ec3:	89 e5                	mov    %esp,%ebp
  800ec5:	57                   	push   %edi
  800ec6:	56                   	push   %esi
  800ec7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ec8:	ba 00 00 00 00       	mov    $0x0,%edx
  800ecd:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ed2:	89 d1                	mov    %edx,%ecx
  800ed4:	89 d3                	mov    %edx,%ebx
  800ed6:	89 d7                	mov    %edx,%edi
  800ed8:	89 d6                	mov    %edx,%esi
  800eda:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800edc:	5b                   	pop    %ebx
  800edd:	5e                   	pop    %esi
  800ede:	5f                   	pop    %edi
  800edf:	5d                   	pop    %ebp
  800ee0:	c3                   	ret    

00800ee1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ee1:	55                   	push   %ebp
  800ee2:	89 e5                	mov    %esp,%ebp
  800ee4:	57                   	push   %edi
  800ee5:	56                   	push   %esi
  800ee6:	53                   	push   %ebx
  800ee7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eea:	be 00 00 00 00       	mov    $0x0,%esi
  800eef:	b8 04 00 00 00       	mov    $0x4,%eax
  800ef4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ef7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800efa:	8b 55 08             	mov    0x8(%ebp),%edx
  800efd:	89 f7                	mov    %esi,%edi
  800eff:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f01:	85 c0                	test   %eax,%eax
  800f03:	7e 28                	jle    800f2d <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f05:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f09:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800f10:	00 
  800f11:	c7 44 24 08 7f 2c 80 	movl   $0x802c7f,0x8(%esp)
  800f18:	00 
  800f19:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f20:	00 
  800f21:	c7 04 24 9c 2c 80 00 	movl   $0x802c9c,(%esp)
  800f28:	e8 1f f5 ff ff       	call   80044c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f2d:	83 c4 2c             	add    $0x2c,%esp
  800f30:	5b                   	pop    %ebx
  800f31:	5e                   	pop    %esi
  800f32:	5f                   	pop    %edi
  800f33:	5d                   	pop    %ebp
  800f34:	c3                   	ret    

00800f35 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f35:	55                   	push   %ebp
  800f36:	89 e5                	mov    %esp,%ebp
  800f38:	57                   	push   %edi
  800f39:	56                   	push   %esi
  800f3a:	53                   	push   %ebx
  800f3b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f3e:	b8 05 00 00 00       	mov    $0x5,%eax
  800f43:	8b 75 18             	mov    0x18(%ebp),%esi
  800f46:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f49:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f52:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f54:	85 c0                	test   %eax,%eax
  800f56:	7e 28                	jle    800f80 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f58:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f5c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f63:	00 
  800f64:	c7 44 24 08 7f 2c 80 	movl   $0x802c7f,0x8(%esp)
  800f6b:	00 
  800f6c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f73:	00 
  800f74:	c7 04 24 9c 2c 80 00 	movl   $0x802c9c,(%esp)
  800f7b:	e8 cc f4 ff ff       	call   80044c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f80:	83 c4 2c             	add    $0x2c,%esp
  800f83:	5b                   	pop    %ebx
  800f84:	5e                   	pop    %esi
  800f85:	5f                   	pop    %edi
  800f86:	5d                   	pop    %ebp
  800f87:	c3                   	ret    

00800f88 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f88:	55                   	push   %ebp
  800f89:	89 e5                	mov    %esp,%ebp
  800f8b:	57                   	push   %edi
  800f8c:	56                   	push   %esi
  800f8d:	53                   	push   %ebx
  800f8e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f91:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f96:	b8 06 00 00 00       	mov    $0x6,%eax
  800f9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa1:	89 df                	mov    %ebx,%edi
  800fa3:	89 de                	mov    %ebx,%esi
  800fa5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fa7:	85 c0                	test   %eax,%eax
  800fa9:	7e 28                	jle    800fd3 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fab:	89 44 24 10          	mov    %eax,0x10(%esp)
  800faf:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800fb6:	00 
  800fb7:	c7 44 24 08 7f 2c 80 	movl   $0x802c7f,0x8(%esp)
  800fbe:	00 
  800fbf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fc6:	00 
  800fc7:	c7 04 24 9c 2c 80 00 	movl   $0x802c9c,(%esp)
  800fce:	e8 79 f4 ff ff       	call   80044c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800fd3:	83 c4 2c             	add    $0x2c,%esp
  800fd6:	5b                   	pop    %ebx
  800fd7:	5e                   	pop    %esi
  800fd8:	5f                   	pop    %edi
  800fd9:	5d                   	pop    %ebp
  800fda:	c3                   	ret    

00800fdb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800fe4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fe9:	b8 08 00 00 00       	mov    $0x8,%eax
  800fee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ff1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff4:	89 df                	mov    %ebx,%edi
  800ff6:	89 de                	mov    %ebx,%esi
  800ff8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ffa:	85 c0                	test   %eax,%eax
  800ffc:	7e 28                	jle    801026 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ffe:	89 44 24 10          	mov    %eax,0x10(%esp)
  801002:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  801009:	00 
  80100a:	c7 44 24 08 7f 2c 80 	movl   $0x802c7f,0x8(%esp)
  801011:	00 
  801012:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801019:	00 
  80101a:	c7 04 24 9c 2c 80 00 	movl   $0x802c9c,(%esp)
  801021:	e8 26 f4 ff ff       	call   80044c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801026:	83 c4 2c             	add    $0x2c,%esp
  801029:	5b                   	pop    %ebx
  80102a:	5e                   	pop    %esi
  80102b:	5f                   	pop    %edi
  80102c:	5d                   	pop    %ebp
  80102d:	c3                   	ret    

0080102e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80102e:	55                   	push   %ebp
  80102f:	89 e5                	mov    %esp,%ebp
  801031:	57                   	push   %edi
  801032:	56                   	push   %esi
  801033:	53                   	push   %ebx
  801034:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801037:	bb 00 00 00 00       	mov    $0x0,%ebx
  80103c:	b8 09 00 00 00       	mov    $0x9,%eax
  801041:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801044:	8b 55 08             	mov    0x8(%ebp),%edx
  801047:	89 df                	mov    %ebx,%edi
  801049:	89 de                	mov    %ebx,%esi
  80104b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80104d:	85 c0                	test   %eax,%eax
  80104f:	7e 28                	jle    801079 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801051:	89 44 24 10          	mov    %eax,0x10(%esp)
  801055:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80105c:	00 
  80105d:	c7 44 24 08 7f 2c 80 	movl   $0x802c7f,0x8(%esp)
  801064:	00 
  801065:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80106c:	00 
  80106d:	c7 04 24 9c 2c 80 00 	movl   $0x802c9c,(%esp)
  801074:	e8 d3 f3 ff ff       	call   80044c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801079:	83 c4 2c             	add    $0x2c,%esp
  80107c:	5b                   	pop    %ebx
  80107d:	5e                   	pop    %esi
  80107e:	5f                   	pop    %edi
  80107f:	5d                   	pop    %ebp
  801080:	c3                   	ret    

00801081 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801081:	55                   	push   %ebp
  801082:	89 e5                	mov    %esp,%ebp
  801084:	57                   	push   %edi
  801085:	56                   	push   %esi
  801086:	53                   	push   %ebx
  801087:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80108a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80108f:	b8 0a 00 00 00       	mov    $0xa,%eax
  801094:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801097:	8b 55 08             	mov    0x8(%ebp),%edx
  80109a:	89 df                	mov    %ebx,%edi
  80109c:	89 de                	mov    %ebx,%esi
  80109e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010a0:	85 c0                	test   %eax,%eax
  8010a2:	7e 28                	jle    8010cc <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010a4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010a8:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8010af:	00 
  8010b0:	c7 44 24 08 7f 2c 80 	movl   $0x802c7f,0x8(%esp)
  8010b7:	00 
  8010b8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010bf:	00 
  8010c0:	c7 04 24 9c 2c 80 00 	movl   $0x802c9c,(%esp)
  8010c7:	e8 80 f3 ff ff       	call   80044c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010cc:	83 c4 2c             	add    $0x2c,%esp
  8010cf:	5b                   	pop    %ebx
  8010d0:	5e                   	pop    %esi
  8010d1:	5f                   	pop    %edi
  8010d2:	5d                   	pop    %ebp
  8010d3:	c3                   	ret    

008010d4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010d4:	55                   	push   %ebp
  8010d5:	89 e5                	mov    %esp,%ebp
  8010d7:	57                   	push   %edi
  8010d8:	56                   	push   %esi
  8010d9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010da:	be 00 00 00 00       	mov    $0x0,%esi
  8010df:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010e4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010e7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010f2:	5b                   	pop    %ebx
  8010f3:	5e                   	pop    %esi
  8010f4:	5f                   	pop    %edi
  8010f5:	5d                   	pop    %ebp
  8010f6:	c3                   	ret    

008010f7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010f7:	55                   	push   %ebp
  8010f8:	89 e5                	mov    %esp,%ebp
  8010fa:	57                   	push   %edi
  8010fb:	56                   	push   %esi
  8010fc:	53                   	push   %ebx
  8010fd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801100:	b9 00 00 00 00       	mov    $0x0,%ecx
  801105:	b8 0d 00 00 00       	mov    $0xd,%eax
  80110a:	8b 55 08             	mov    0x8(%ebp),%edx
  80110d:	89 cb                	mov    %ecx,%ebx
  80110f:	89 cf                	mov    %ecx,%edi
  801111:	89 ce                	mov    %ecx,%esi
  801113:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801115:	85 c0                	test   %eax,%eax
  801117:	7e 28                	jle    801141 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801119:	89 44 24 10          	mov    %eax,0x10(%esp)
  80111d:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801124:	00 
  801125:	c7 44 24 08 7f 2c 80 	movl   $0x802c7f,0x8(%esp)
  80112c:	00 
  80112d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801134:	00 
  801135:	c7 04 24 9c 2c 80 00 	movl   $0x802c9c,(%esp)
  80113c:	e8 0b f3 ff ff       	call   80044c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801141:	83 c4 2c             	add    $0x2c,%esp
  801144:	5b                   	pop    %ebx
  801145:	5e                   	pop    %esi
  801146:	5f                   	pop    %edi
  801147:	5d                   	pop    %ebp
  801148:	c3                   	ret    
  801149:	00 00                	add    %al,(%eax)
	...

0080114c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80114c:	55                   	push   %ebp
  80114d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80114f:	8b 45 08             	mov    0x8(%ebp),%eax
  801152:	05 00 00 00 30       	add    $0x30000000,%eax
  801157:	c1 e8 0c             	shr    $0xc,%eax
}
  80115a:	5d                   	pop    %ebp
  80115b:	c3                   	ret    

0080115c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80115c:	55                   	push   %ebp
  80115d:	89 e5                	mov    %esp,%ebp
  80115f:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801162:	8b 45 08             	mov    0x8(%ebp),%eax
  801165:	89 04 24             	mov    %eax,(%esp)
  801168:	e8 df ff ff ff       	call   80114c <fd2num>
  80116d:	05 20 00 0d 00       	add    $0xd0020,%eax
  801172:	c1 e0 0c             	shl    $0xc,%eax
}
  801175:	c9                   	leave  
  801176:	c3                   	ret    

00801177 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801177:	55                   	push   %ebp
  801178:	89 e5                	mov    %esp,%ebp
  80117a:	53                   	push   %ebx
  80117b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80117e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801183:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801185:	89 c2                	mov    %eax,%edx
  801187:	c1 ea 16             	shr    $0x16,%edx
  80118a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801191:	f6 c2 01             	test   $0x1,%dl
  801194:	74 11                	je     8011a7 <fd_alloc+0x30>
  801196:	89 c2                	mov    %eax,%edx
  801198:	c1 ea 0c             	shr    $0xc,%edx
  80119b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011a2:	f6 c2 01             	test   $0x1,%dl
  8011a5:	75 09                	jne    8011b0 <fd_alloc+0x39>
			*fd_store = fd;
  8011a7:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8011a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ae:	eb 17                	jmp    8011c7 <fd_alloc+0x50>
  8011b0:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011b5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011ba:	75 c7                	jne    801183 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011bc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8011c2:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011c7:	5b                   	pop    %ebx
  8011c8:	5d                   	pop    %ebp
  8011c9:	c3                   	ret    

008011ca <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011ca:	55                   	push   %ebp
  8011cb:	89 e5                	mov    %esp,%ebp
  8011cd:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011d0:	83 f8 1f             	cmp    $0x1f,%eax
  8011d3:	77 36                	ja     80120b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011d5:	05 00 00 0d 00       	add    $0xd0000,%eax
  8011da:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011dd:	89 c2                	mov    %eax,%edx
  8011df:	c1 ea 16             	shr    $0x16,%edx
  8011e2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011e9:	f6 c2 01             	test   $0x1,%dl
  8011ec:	74 24                	je     801212 <fd_lookup+0x48>
  8011ee:	89 c2                	mov    %eax,%edx
  8011f0:	c1 ea 0c             	shr    $0xc,%edx
  8011f3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011fa:	f6 c2 01             	test   $0x1,%dl
  8011fd:	74 1a                	je     801219 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  801202:	89 02                	mov    %eax,(%edx)
	return 0;
  801204:	b8 00 00 00 00       	mov    $0x0,%eax
  801209:	eb 13                	jmp    80121e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80120b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801210:	eb 0c                	jmp    80121e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801212:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801217:	eb 05                	jmp    80121e <fd_lookup+0x54>
  801219:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80121e:	5d                   	pop    %ebp
  80121f:	c3                   	ret    

00801220 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801220:	55                   	push   %ebp
  801221:	89 e5                	mov    %esp,%ebp
  801223:	53                   	push   %ebx
  801224:	83 ec 14             	sub    $0x14,%esp
  801227:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80122a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  80122d:	ba 00 00 00 00       	mov    $0x0,%edx
  801232:	eb 0e                	jmp    801242 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801234:	39 08                	cmp    %ecx,(%eax)
  801236:	75 09                	jne    801241 <dev_lookup+0x21>
			*dev = devtab[i];
  801238:	89 03                	mov    %eax,(%ebx)
			return 0;
  80123a:	b8 00 00 00 00       	mov    $0x0,%eax
  80123f:	eb 33                	jmp    801274 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801241:	42                   	inc    %edx
  801242:	8b 04 95 28 2d 80 00 	mov    0x802d28(,%edx,4),%eax
  801249:	85 c0                	test   %eax,%eax
  80124b:	75 e7                	jne    801234 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80124d:	a1 90 67 80 00       	mov    0x806790,%eax
  801252:	8b 40 48             	mov    0x48(%eax),%eax
  801255:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801259:	89 44 24 04          	mov    %eax,0x4(%esp)
  80125d:	c7 04 24 ac 2c 80 00 	movl   $0x802cac,(%esp)
  801264:	e8 db f2 ff ff       	call   800544 <cprintf>
	*dev = 0;
  801269:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80126f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801274:	83 c4 14             	add    $0x14,%esp
  801277:	5b                   	pop    %ebx
  801278:	5d                   	pop    %ebp
  801279:	c3                   	ret    

0080127a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80127a:	55                   	push   %ebp
  80127b:	89 e5                	mov    %esp,%ebp
  80127d:	56                   	push   %esi
  80127e:	53                   	push   %ebx
  80127f:	83 ec 30             	sub    $0x30,%esp
  801282:	8b 75 08             	mov    0x8(%ebp),%esi
  801285:	8a 45 0c             	mov    0xc(%ebp),%al
  801288:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80128b:	89 34 24             	mov    %esi,(%esp)
  80128e:	e8 b9 fe ff ff       	call   80114c <fd2num>
  801293:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801296:	89 54 24 04          	mov    %edx,0x4(%esp)
  80129a:	89 04 24             	mov    %eax,(%esp)
  80129d:	e8 28 ff ff ff       	call   8011ca <fd_lookup>
  8012a2:	89 c3                	mov    %eax,%ebx
  8012a4:	85 c0                	test   %eax,%eax
  8012a6:	78 05                	js     8012ad <fd_close+0x33>
	    || fd != fd2)
  8012a8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012ab:	74 0d                	je     8012ba <fd_close+0x40>
		return (must_exist ? r : 0);
  8012ad:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8012b1:	75 46                	jne    8012f9 <fd_close+0x7f>
  8012b3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012b8:	eb 3f                	jmp    8012f9 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012ba:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012c1:	8b 06                	mov    (%esi),%eax
  8012c3:	89 04 24             	mov    %eax,(%esp)
  8012c6:	e8 55 ff ff ff       	call   801220 <dev_lookup>
  8012cb:	89 c3                	mov    %eax,%ebx
  8012cd:	85 c0                	test   %eax,%eax
  8012cf:	78 18                	js     8012e9 <fd_close+0x6f>
		if (dev->dev_close)
  8012d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d4:	8b 40 10             	mov    0x10(%eax),%eax
  8012d7:	85 c0                	test   %eax,%eax
  8012d9:	74 09                	je     8012e4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012db:	89 34 24             	mov    %esi,(%esp)
  8012de:	ff d0                	call   *%eax
  8012e0:	89 c3                	mov    %eax,%ebx
  8012e2:	eb 05                	jmp    8012e9 <fd_close+0x6f>
		else
			r = 0;
  8012e4:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012e9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012ed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012f4:	e8 8f fc ff ff       	call   800f88 <sys_page_unmap>
	return r;
}
  8012f9:	89 d8                	mov    %ebx,%eax
  8012fb:	83 c4 30             	add    $0x30,%esp
  8012fe:	5b                   	pop    %ebx
  8012ff:	5e                   	pop    %esi
  801300:	5d                   	pop    %ebp
  801301:	c3                   	ret    

00801302 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801302:	55                   	push   %ebp
  801303:	89 e5                	mov    %esp,%ebp
  801305:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801308:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80130b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80130f:	8b 45 08             	mov    0x8(%ebp),%eax
  801312:	89 04 24             	mov    %eax,(%esp)
  801315:	e8 b0 fe ff ff       	call   8011ca <fd_lookup>
  80131a:	85 c0                	test   %eax,%eax
  80131c:	78 13                	js     801331 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80131e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801325:	00 
  801326:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801329:	89 04 24             	mov    %eax,(%esp)
  80132c:	e8 49 ff ff ff       	call   80127a <fd_close>
}
  801331:	c9                   	leave  
  801332:	c3                   	ret    

00801333 <close_all>:

void
close_all(void)
{
  801333:	55                   	push   %ebp
  801334:	89 e5                	mov    %esp,%ebp
  801336:	53                   	push   %ebx
  801337:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80133a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80133f:	89 1c 24             	mov    %ebx,(%esp)
  801342:	e8 bb ff ff ff       	call   801302 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801347:	43                   	inc    %ebx
  801348:	83 fb 20             	cmp    $0x20,%ebx
  80134b:	75 f2                	jne    80133f <close_all+0xc>
		close(i);
}
  80134d:	83 c4 14             	add    $0x14,%esp
  801350:	5b                   	pop    %ebx
  801351:	5d                   	pop    %ebp
  801352:	c3                   	ret    

00801353 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801353:	55                   	push   %ebp
  801354:	89 e5                	mov    %esp,%ebp
  801356:	57                   	push   %edi
  801357:	56                   	push   %esi
  801358:	53                   	push   %ebx
  801359:	83 ec 4c             	sub    $0x4c,%esp
  80135c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80135f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801362:	89 44 24 04          	mov    %eax,0x4(%esp)
  801366:	8b 45 08             	mov    0x8(%ebp),%eax
  801369:	89 04 24             	mov    %eax,(%esp)
  80136c:	e8 59 fe ff ff       	call   8011ca <fd_lookup>
  801371:	89 c3                	mov    %eax,%ebx
  801373:	85 c0                	test   %eax,%eax
  801375:	0f 88 e1 00 00 00    	js     80145c <dup+0x109>
		return r;
	close(newfdnum);
  80137b:	89 3c 24             	mov    %edi,(%esp)
  80137e:	e8 7f ff ff ff       	call   801302 <close>

	newfd = INDEX2FD(newfdnum);
  801383:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801389:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80138c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80138f:	89 04 24             	mov    %eax,(%esp)
  801392:	e8 c5 fd ff ff       	call   80115c <fd2data>
  801397:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801399:	89 34 24             	mov    %esi,(%esp)
  80139c:	e8 bb fd ff ff       	call   80115c <fd2data>
  8013a1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013a4:	89 d8                	mov    %ebx,%eax
  8013a6:	c1 e8 16             	shr    $0x16,%eax
  8013a9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013b0:	a8 01                	test   $0x1,%al
  8013b2:	74 46                	je     8013fa <dup+0xa7>
  8013b4:	89 d8                	mov    %ebx,%eax
  8013b6:	c1 e8 0c             	shr    $0xc,%eax
  8013b9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013c0:	f6 c2 01             	test   $0x1,%dl
  8013c3:	74 35                	je     8013fa <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013c5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013cc:	25 07 0e 00 00       	and    $0xe07,%eax
  8013d1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013d5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8013d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013dc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8013e3:	00 
  8013e4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013ef:	e8 41 fb ff ff       	call   800f35 <sys_page_map>
  8013f4:	89 c3                	mov    %eax,%ebx
  8013f6:	85 c0                	test   %eax,%eax
  8013f8:	78 3b                	js     801435 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013fd:	89 c2                	mov    %eax,%edx
  8013ff:	c1 ea 0c             	shr    $0xc,%edx
  801402:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801409:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80140f:	89 54 24 10          	mov    %edx,0x10(%esp)
  801413:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801417:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80141e:	00 
  80141f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801423:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80142a:	e8 06 fb ff ff       	call   800f35 <sys_page_map>
  80142f:	89 c3                	mov    %eax,%ebx
  801431:	85 c0                	test   %eax,%eax
  801433:	79 25                	jns    80145a <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801435:	89 74 24 04          	mov    %esi,0x4(%esp)
  801439:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801440:	e8 43 fb ff ff       	call   800f88 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801445:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801448:	89 44 24 04          	mov    %eax,0x4(%esp)
  80144c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801453:	e8 30 fb ff ff       	call   800f88 <sys_page_unmap>
	return r;
  801458:	eb 02                	jmp    80145c <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80145a:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80145c:	89 d8                	mov    %ebx,%eax
  80145e:	83 c4 4c             	add    $0x4c,%esp
  801461:	5b                   	pop    %ebx
  801462:	5e                   	pop    %esi
  801463:	5f                   	pop    %edi
  801464:	5d                   	pop    %ebp
  801465:	c3                   	ret    

00801466 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801466:	55                   	push   %ebp
  801467:	89 e5                	mov    %esp,%ebp
  801469:	53                   	push   %ebx
  80146a:	83 ec 24             	sub    $0x24,%esp
  80146d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801470:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801473:	89 44 24 04          	mov    %eax,0x4(%esp)
  801477:	89 1c 24             	mov    %ebx,(%esp)
  80147a:	e8 4b fd ff ff       	call   8011ca <fd_lookup>
  80147f:	85 c0                	test   %eax,%eax
  801481:	78 6d                	js     8014f0 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801483:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801486:	89 44 24 04          	mov    %eax,0x4(%esp)
  80148a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80148d:	8b 00                	mov    (%eax),%eax
  80148f:	89 04 24             	mov    %eax,(%esp)
  801492:	e8 89 fd ff ff       	call   801220 <dev_lookup>
  801497:	85 c0                	test   %eax,%eax
  801499:	78 55                	js     8014f0 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80149b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80149e:	8b 50 08             	mov    0x8(%eax),%edx
  8014a1:	83 e2 03             	and    $0x3,%edx
  8014a4:	83 fa 01             	cmp    $0x1,%edx
  8014a7:	75 23                	jne    8014cc <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014a9:	a1 90 67 80 00       	mov    0x806790,%eax
  8014ae:	8b 40 48             	mov    0x48(%eax),%eax
  8014b1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014b9:	c7 04 24 ed 2c 80 00 	movl   $0x802ced,(%esp)
  8014c0:	e8 7f f0 ff ff       	call   800544 <cprintf>
		return -E_INVAL;
  8014c5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014ca:	eb 24                	jmp    8014f0 <read+0x8a>
	}
	if (!dev->dev_read)
  8014cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014cf:	8b 52 08             	mov    0x8(%edx),%edx
  8014d2:	85 d2                	test   %edx,%edx
  8014d4:	74 15                	je     8014eb <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8014d9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014e0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8014e4:	89 04 24             	mov    %eax,(%esp)
  8014e7:	ff d2                	call   *%edx
  8014e9:	eb 05                	jmp    8014f0 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014eb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8014f0:	83 c4 24             	add    $0x24,%esp
  8014f3:	5b                   	pop    %ebx
  8014f4:	5d                   	pop    %ebp
  8014f5:	c3                   	ret    

008014f6 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014f6:	55                   	push   %ebp
  8014f7:	89 e5                	mov    %esp,%ebp
  8014f9:	57                   	push   %edi
  8014fa:	56                   	push   %esi
  8014fb:	53                   	push   %ebx
  8014fc:	83 ec 1c             	sub    $0x1c,%esp
  8014ff:	8b 7d 08             	mov    0x8(%ebp),%edi
  801502:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801505:	bb 00 00 00 00       	mov    $0x0,%ebx
  80150a:	eb 23                	jmp    80152f <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80150c:	89 f0                	mov    %esi,%eax
  80150e:	29 d8                	sub    %ebx,%eax
  801510:	89 44 24 08          	mov    %eax,0x8(%esp)
  801514:	8b 45 0c             	mov    0xc(%ebp),%eax
  801517:	01 d8                	add    %ebx,%eax
  801519:	89 44 24 04          	mov    %eax,0x4(%esp)
  80151d:	89 3c 24             	mov    %edi,(%esp)
  801520:	e8 41 ff ff ff       	call   801466 <read>
		if (m < 0)
  801525:	85 c0                	test   %eax,%eax
  801527:	78 10                	js     801539 <readn+0x43>
			return m;
		if (m == 0)
  801529:	85 c0                	test   %eax,%eax
  80152b:	74 0a                	je     801537 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80152d:	01 c3                	add    %eax,%ebx
  80152f:	39 f3                	cmp    %esi,%ebx
  801531:	72 d9                	jb     80150c <readn+0x16>
  801533:	89 d8                	mov    %ebx,%eax
  801535:	eb 02                	jmp    801539 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801537:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801539:	83 c4 1c             	add    $0x1c,%esp
  80153c:	5b                   	pop    %ebx
  80153d:	5e                   	pop    %esi
  80153e:	5f                   	pop    %edi
  80153f:	5d                   	pop    %ebp
  801540:	c3                   	ret    

00801541 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801541:	55                   	push   %ebp
  801542:	89 e5                	mov    %esp,%ebp
  801544:	53                   	push   %ebx
  801545:	83 ec 24             	sub    $0x24,%esp
  801548:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80154b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80154e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801552:	89 1c 24             	mov    %ebx,(%esp)
  801555:	e8 70 fc ff ff       	call   8011ca <fd_lookup>
  80155a:	85 c0                	test   %eax,%eax
  80155c:	78 68                	js     8015c6 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80155e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801561:	89 44 24 04          	mov    %eax,0x4(%esp)
  801565:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801568:	8b 00                	mov    (%eax),%eax
  80156a:	89 04 24             	mov    %eax,(%esp)
  80156d:	e8 ae fc ff ff       	call   801220 <dev_lookup>
  801572:	85 c0                	test   %eax,%eax
  801574:	78 50                	js     8015c6 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801576:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801579:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80157d:	75 23                	jne    8015a2 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80157f:	a1 90 67 80 00       	mov    0x806790,%eax
  801584:	8b 40 48             	mov    0x48(%eax),%eax
  801587:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80158b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80158f:	c7 04 24 09 2d 80 00 	movl   $0x802d09,(%esp)
  801596:	e8 a9 ef ff ff       	call   800544 <cprintf>
		return -E_INVAL;
  80159b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015a0:	eb 24                	jmp    8015c6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015a5:	8b 52 0c             	mov    0xc(%edx),%edx
  8015a8:	85 d2                	test   %edx,%edx
  8015aa:	74 15                	je     8015c1 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015ac:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015af:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015b6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8015ba:	89 04 24             	mov    %eax,(%esp)
  8015bd:	ff d2                	call   *%edx
  8015bf:	eb 05                	jmp    8015c6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015c1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8015c6:	83 c4 24             	add    $0x24,%esp
  8015c9:	5b                   	pop    %ebx
  8015ca:	5d                   	pop    %ebp
  8015cb:	c3                   	ret    

008015cc <seek>:

int
seek(int fdnum, off_t offset)
{
  8015cc:	55                   	push   %ebp
  8015cd:	89 e5                	mov    %esp,%ebp
  8015cf:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015d2:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8015dc:	89 04 24             	mov    %eax,(%esp)
  8015df:	e8 e6 fb ff ff       	call   8011ca <fd_lookup>
  8015e4:	85 c0                	test   %eax,%eax
  8015e6:	78 0e                	js     8015f6 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8015e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015ee:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015f6:	c9                   	leave  
  8015f7:	c3                   	ret    

008015f8 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015f8:	55                   	push   %ebp
  8015f9:	89 e5                	mov    %esp,%ebp
  8015fb:	53                   	push   %ebx
  8015fc:	83 ec 24             	sub    $0x24,%esp
  8015ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801602:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801605:	89 44 24 04          	mov    %eax,0x4(%esp)
  801609:	89 1c 24             	mov    %ebx,(%esp)
  80160c:	e8 b9 fb ff ff       	call   8011ca <fd_lookup>
  801611:	85 c0                	test   %eax,%eax
  801613:	78 61                	js     801676 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801615:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801618:	89 44 24 04          	mov    %eax,0x4(%esp)
  80161c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80161f:	8b 00                	mov    (%eax),%eax
  801621:	89 04 24             	mov    %eax,(%esp)
  801624:	e8 f7 fb ff ff       	call   801220 <dev_lookup>
  801629:	85 c0                	test   %eax,%eax
  80162b:	78 49                	js     801676 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80162d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801630:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801634:	75 23                	jne    801659 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801636:	a1 90 67 80 00       	mov    0x806790,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80163b:	8b 40 48             	mov    0x48(%eax),%eax
  80163e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801642:	89 44 24 04          	mov    %eax,0x4(%esp)
  801646:	c7 04 24 cc 2c 80 00 	movl   $0x802ccc,(%esp)
  80164d:	e8 f2 ee ff ff       	call   800544 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801652:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801657:	eb 1d                	jmp    801676 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801659:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80165c:	8b 52 18             	mov    0x18(%edx),%edx
  80165f:	85 d2                	test   %edx,%edx
  801661:	74 0e                	je     801671 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801663:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801666:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80166a:	89 04 24             	mov    %eax,(%esp)
  80166d:	ff d2                	call   *%edx
  80166f:	eb 05                	jmp    801676 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801671:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801676:	83 c4 24             	add    $0x24,%esp
  801679:	5b                   	pop    %ebx
  80167a:	5d                   	pop    %ebp
  80167b:	c3                   	ret    

0080167c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80167c:	55                   	push   %ebp
  80167d:	89 e5                	mov    %esp,%ebp
  80167f:	53                   	push   %ebx
  801680:	83 ec 24             	sub    $0x24,%esp
  801683:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801686:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801689:	89 44 24 04          	mov    %eax,0x4(%esp)
  80168d:	8b 45 08             	mov    0x8(%ebp),%eax
  801690:	89 04 24             	mov    %eax,(%esp)
  801693:	e8 32 fb ff ff       	call   8011ca <fd_lookup>
  801698:	85 c0                	test   %eax,%eax
  80169a:	78 52                	js     8016ee <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80169c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80169f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016a6:	8b 00                	mov    (%eax),%eax
  8016a8:	89 04 24             	mov    %eax,(%esp)
  8016ab:	e8 70 fb ff ff       	call   801220 <dev_lookup>
  8016b0:	85 c0                	test   %eax,%eax
  8016b2:	78 3a                	js     8016ee <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8016b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016b7:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016bb:	74 2c                	je     8016e9 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016bd:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016c0:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016c7:	00 00 00 
	stat->st_isdir = 0;
  8016ca:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016d1:	00 00 00 
	stat->st_dev = dev;
  8016d4:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016de:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016e1:	89 14 24             	mov    %edx,(%esp)
  8016e4:	ff 50 14             	call   *0x14(%eax)
  8016e7:	eb 05                	jmp    8016ee <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016e9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016ee:	83 c4 24             	add    $0x24,%esp
  8016f1:	5b                   	pop    %ebx
  8016f2:	5d                   	pop    %ebp
  8016f3:	c3                   	ret    

008016f4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016f4:	55                   	push   %ebp
  8016f5:	89 e5                	mov    %esp,%ebp
  8016f7:	56                   	push   %esi
  8016f8:	53                   	push   %ebx
  8016f9:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016fc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801703:	00 
  801704:	8b 45 08             	mov    0x8(%ebp),%eax
  801707:	89 04 24             	mov    %eax,(%esp)
  80170a:	e8 2d 02 00 00       	call   80193c <open>
  80170f:	89 c3                	mov    %eax,%ebx
  801711:	85 c0                	test   %eax,%eax
  801713:	78 1b                	js     801730 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801715:	8b 45 0c             	mov    0xc(%ebp),%eax
  801718:	89 44 24 04          	mov    %eax,0x4(%esp)
  80171c:	89 1c 24             	mov    %ebx,(%esp)
  80171f:	e8 58 ff ff ff       	call   80167c <fstat>
  801724:	89 c6                	mov    %eax,%esi
	close(fd);
  801726:	89 1c 24             	mov    %ebx,(%esp)
  801729:	e8 d4 fb ff ff       	call   801302 <close>
	return r;
  80172e:	89 f3                	mov    %esi,%ebx
}
  801730:	89 d8                	mov    %ebx,%eax
  801732:	83 c4 10             	add    $0x10,%esp
  801735:	5b                   	pop    %ebx
  801736:	5e                   	pop    %esi
  801737:	5d                   	pop    %ebp
  801738:	c3                   	ret    
  801739:	00 00                	add    %al,(%eax)
	...

0080173c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80173c:	55                   	push   %ebp
  80173d:	89 e5                	mov    %esp,%ebp
  80173f:	56                   	push   %esi
  801740:	53                   	push   %ebx
  801741:	83 ec 10             	sub    $0x10,%esp
  801744:	89 c3                	mov    %eax,%ebx
  801746:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801748:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80174f:	75 11                	jne    801762 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801751:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801758:	e8 b2 0d 00 00       	call   80250f <ipc_find_env>
  80175d:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801762:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801769:	00 
  80176a:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  801771:	00 
  801772:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801776:	a1 00 50 80 00       	mov    0x805000,%eax
  80177b:	89 04 24             	mov    %eax,(%esp)
  80177e:	e8 1e 0d 00 00       	call   8024a1 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801783:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80178a:	00 
  80178b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80178f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801796:	e8 9d 0c 00 00       	call   802438 <ipc_recv>
}
  80179b:	83 c4 10             	add    $0x10,%esp
  80179e:	5b                   	pop    %ebx
  80179f:	5e                   	pop    %esi
  8017a0:	5d                   	pop    %ebp
  8017a1:	c3                   	ret    

008017a2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017a2:	55                   	push   %ebp
  8017a3:	89 e5                	mov    %esp,%ebp
  8017a5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ab:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ae:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  8017b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017b6:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c0:	b8 02 00 00 00       	mov    $0x2,%eax
  8017c5:	e8 72 ff ff ff       	call   80173c <fsipc>
}
  8017ca:	c9                   	leave  
  8017cb:	c3                   	ret    

008017cc <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017cc:	55                   	push   %ebp
  8017cd:	89 e5                	mov    %esp,%ebp
  8017cf:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d5:	8b 40 0c             	mov    0xc(%eax),%eax
  8017d8:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  8017dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e2:	b8 06 00 00 00       	mov    $0x6,%eax
  8017e7:	e8 50 ff ff ff       	call   80173c <fsipc>
}
  8017ec:	c9                   	leave  
  8017ed:	c3                   	ret    

008017ee <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017ee:	55                   	push   %ebp
  8017ef:	89 e5                	mov    %esp,%ebp
  8017f1:	53                   	push   %ebx
  8017f2:	83 ec 14             	sub    $0x14,%esp
  8017f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fb:	8b 40 0c             	mov    0xc(%eax),%eax
  8017fe:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801803:	ba 00 00 00 00       	mov    $0x0,%edx
  801808:	b8 05 00 00 00       	mov    $0x5,%eax
  80180d:	e8 2a ff ff ff       	call   80173c <fsipc>
  801812:	85 c0                	test   %eax,%eax
  801814:	78 2b                	js     801841 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801816:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  80181d:	00 
  80181e:	89 1c 24             	mov    %ebx,(%esp)
  801821:	e8 c9 f2 ff ff       	call   800aef <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801826:	a1 80 70 80 00       	mov    0x807080,%eax
  80182b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801831:	a1 84 70 80 00       	mov    0x807084,%eax
  801836:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80183c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801841:	83 c4 14             	add    $0x14,%esp
  801844:	5b                   	pop    %ebx
  801845:	5d                   	pop    %ebp
  801846:	c3                   	ret    

00801847 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801847:	55                   	push   %ebp
  801848:	89 e5                	mov    %esp,%ebp
  80184a:	83 ec 18             	sub    $0x18,%esp
  80184d:	8b 55 10             	mov    0x10(%ebp),%edx
  801850:	89 d0                	mov    %edx,%eax
  801852:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  801858:	76 05                	jbe    80185f <devfile_write+0x18>
  80185a:	b8 00 10 00 00       	mov    $0x1000,%eax
	//panic("devfile_write not implemented");
	int r;
	//uint32_t maxsize = BLKSIZE - sizeof(int) - sizeof(size_t);	
	if (n > BLKSIZE)
		n = BLKSIZE;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80185f:	8b 55 08             	mov    0x8(%ebp),%edx
  801862:	8b 52 0c             	mov    0xc(%edx),%edx
  801865:	89 15 00 70 80 00    	mov    %edx,0x807000
	fsipcbuf.write.req_n = n;
  80186b:	a3 04 70 80 00       	mov    %eax,0x807004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801870:	89 44 24 08          	mov    %eax,0x8(%esp)
  801874:	8b 45 0c             	mov    0xc(%ebp),%eax
  801877:	89 44 24 04          	mov    %eax,0x4(%esp)
  80187b:	c7 04 24 08 70 80 00 	movl   $0x807008,(%esp)
  801882:	e8 e1 f3 ff ff       	call   800c68 <memmove>
	 
	return fsipc(FSREQ_WRITE, NULL);
  801887:	ba 00 00 00 00       	mov    $0x0,%edx
  80188c:	b8 04 00 00 00       	mov    $0x4,%eax
  801891:	e8 a6 fe ff ff       	call   80173c <fsipc>
}
  801896:	c9                   	leave  
  801897:	c3                   	ret    

00801898 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801898:	55                   	push   %ebp
  801899:	89 e5                	mov    %esp,%ebp
  80189b:	56                   	push   %esi
  80189c:	53                   	push   %ebx
  80189d:	83 ec 10             	sub    $0x10,%esp
  8018a0:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a6:	8b 40 0c             	mov    0xc(%eax),%eax
  8018a9:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  8018ae:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b9:	b8 03 00 00 00       	mov    $0x3,%eax
  8018be:	e8 79 fe ff ff       	call   80173c <fsipc>
  8018c3:	89 c3                	mov    %eax,%ebx
  8018c5:	85 c0                	test   %eax,%eax
  8018c7:	78 6a                	js     801933 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8018c9:	39 c6                	cmp    %eax,%esi
  8018cb:	73 24                	jae    8018f1 <devfile_read+0x59>
  8018cd:	c7 44 24 0c 38 2d 80 	movl   $0x802d38,0xc(%esp)
  8018d4:	00 
  8018d5:	c7 44 24 08 3f 2d 80 	movl   $0x802d3f,0x8(%esp)
  8018dc:	00 
  8018dd:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8018e4:	00 
  8018e5:	c7 04 24 54 2d 80 00 	movl   $0x802d54,(%esp)
  8018ec:	e8 5b eb ff ff       	call   80044c <_panic>
	assert(r <= PGSIZE);
  8018f1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018f6:	7e 24                	jle    80191c <devfile_read+0x84>
  8018f8:	c7 44 24 0c 5f 2d 80 	movl   $0x802d5f,0xc(%esp)
  8018ff:	00 
  801900:	c7 44 24 08 3f 2d 80 	movl   $0x802d3f,0x8(%esp)
  801907:	00 
  801908:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  80190f:	00 
  801910:	c7 04 24 54 2d 80 00 	movl   $0x802d54,(%esp)
  801917:	e8 30 eb ff ff       	call   80044c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80191c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801920:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  801927:	00 
  801928:	8b 45 0c             	mov    0xc(%ebp),%eax
  80192b:	89 04 24             	mov    %eax,(%esp)
  80192e:	e8 35 f3 ff ff       	call   800c68 <memmove>
	return r;
}
  801933:	89 d8                	mov    %ebx,%eax
  801935:	83 c4 10             	add    $0x10,%esp
  801938:	5b                   	pop    %ebx
  801939:	5e                   	pop    %esi
  80193a:	5d                   	pop    %ebp
  80193b:	c3                   	ret    

0080193c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80193c:	55                   	push   %ebp
  80193d:	89 e5                	mov    %esp,%ebp
  80193f:	56                   	push   %esi
  801940:	53                   	push   %ebx
  801941:	83 ec 20             	sub    $0x20,%esp
  801944:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801947:	89 34 24             	mov    %esi,(%esp)
  80194a:	e8 6d f1 ff ff       	call   800abc <strlen>
  80194f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801954:	7f 60                	jg     8019b6 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801956:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801959:	89 04 24             	mov    %eax,(%esp)
  80195c:	e8 16 f8 ff ff       	call   801177 <fd_alloc>
  801961:	89 c3                	mov    %eax,%ebx
  801963:	85 c0                	test   %eax,%eax
  801965:	78 54                	js     8019bb <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801967:	89 74 24 04          	mov    %esi,0x4(%esp)
  80196b:	c7 04 24 00 70 80 00 	movl   $0x807000,(%esp)
  801972:	e8 78 f1 ff ff       	call   800aef <strcpy>
	fsipcbuf.open.req_omode = mode;
  801977:	8b 45 0c             	mov    0xc(%ebp),%eax
  80197a:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80197f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801982:	b8 01 00 00 00       	mov    $0x1,%eax
  801987:	e8 b0 fd ff ff       	call   80173c <fsipc>
  80198c:	89 c3                	mov    %eax,%ebx
  80198e:	85 c0                	test   %eax,%eax
  801990:	79 15                	jns    8019a7 <open+0x6b>
		fd_close(fd, 0);
  801992:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801999:	00 
  80199a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80199d:	89 04 24             	mov    %eax,(%esp)
  8019a0:	e8 d5 f8 ff ff       	call   80127a <fd_close>
		return r;
  8019a5:	eb 14                	jmp    8019bb <open+0x7f>
	}

	return fd2num(fd);
  8019a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019aa:	89 04 24             	mov    %eax,(%esp)
  8019ad:	e8 9a f7 ff ff       	call   80114c <fd2num>
  8019b2:	89 c3                	mov    %eax,%ebx
  8019b4:	eb 05                	jmp    8019bb <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019b6:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019bb:	89 d8                	mov    %ebx,%eax
  8019bd:	83 c4 20             	add    $0x20,%esp
  8019c0:	5b                   	pop    %ebx
  8019c1:	5e                   	pop    %esi
  8019c2:	5d                   	pop    %ebp
  8019c3:	c3                   	ret    

008019c4 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019c4:	55                   	push   %ebp
  8019c5:	89 e5                	mov    %esp,%ebp
  8019c7:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8019cf:	b8 08 00 00 00       	mov    $0x8,%eax
  8019d4:	e8 63 fd ff ff       	call   80173c <fsipc>
}
  8019d9:	c9                   	leave  
  8019da:	c3                   	ret    
	...

008019dc <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8019dc:	55                   	push   %ebp
  8019dd:	89 e5                	mov    %esp,%ebp
  8019df:	57                   	push   %edi
  8019e0:	56                   	push   %esi
  8019e1:	53                   	push   %ebx
  8019e2:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8019e8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8019ef:	00 
  8019f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f3:	89 04 24             	mov    %eax,(%esp)
  8019f6:	e8 41 ff ff ff       	call   80193c <open>
  8019fb:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
  801a01:	85 c0                	test   %eax,%eax
  801a03:	0f 88 8c 05 00 00    	js     801f95 <spawn+0x5b9>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801a09:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  801a10:	00 
  801a11:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801a17:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a1b:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801a21:	89 04 24             	mov    %eax,(%esp)
  801a24:	e8 cd fa ff ff       	call   8014f6 <readn>
  801a29:	3d 00 02 00 00       	cmp    $0x200,%eax
  801a2e:	75 0c                	jne    801a3c <spawn+0x60>
	    || elf->e_magic != ELF_MAGIC) {
  801a30:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801a37:	45 4c 46 
  801a3a:	74 3b                	je     801a77 <spawn+0x9b>
		close(fd);
  801a3c:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801a42:	89 04 24             	mov    %eax,(%esp)
  801a45:	e8 b8 f8 ff ff       	call   801302 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801a4a:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  801a51:	46 
  801a52:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  801a58:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a5c:	c7 04 24 6b 2d 80 00 	movl   $0x802d6b,(%esp)
  801a63:	e8 dc ea ff ff       	call   800544 <cprintf>
		return -E_NOT_EXEC;
  801a68:	c7 85 88 fd ff ff f2 	movl   $0xfffffff2,-0x278(%ebp)
  801a6f:	ff ff ff 
  801a72:	e9 2a 05 00 00       	jmp    801fa1 <spawn+0x5c5>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801a77:	ba 07 00 00 00       	mov    $0x7,%edx
  801a7c:	89 d0                	mov    %edx,%eax
  801a7e:	cd 30                	int    $0x30
  801a80:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801a86:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801a8c:	85 c0                	test   %eax,%eax
  801a8e:	0f 88 0d 05 00 00    	js     801fa1 <spawn+0x5c5>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801a94:	25 ff 03 00 00       	and    $0x3ff,%eax
  801a99:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801aa0:	c1 e0 07             	shl    $0x7,%eax
  801aa3:	29 d0                	sub    %edx,%eax
  801aa5:	8d b0 00 00 c0 ee    	lea    -0x11400000(%eax),%esi
  801aab:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801ab1:	b9 11 00 00 00       	mov    $0x11,%ecx
  801ab6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801ab8:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801abe:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801ac4:	be 00 00 00 00       	mov    $0x0,%esi
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801ac9:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ace:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801ad1:	eb 0d                	jmp    801ae0 <spawn+0x104>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801ad3:	89 04 24             	mov    %eax,(%esp)
  801ad6:	e8 e1 ef ff ff       	call   800abc <strlen>
  801adb:	8d 5c 18 01          	lea    0x1(%eax,%ebx,1),%ebx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801adf:	46                   	inc    %esi
  801ae0:	89 f2                	mov    %esi,%edx
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801ae2:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801ae9:	8b 04 b7             	mov    (%edi,%esi,4),%eax
  801aec:	85 c0                	test   %eax,%eax
  801aee:	75 e3                	jne    801ad3 <spawn+0xf7>
  801af0:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
  801af6:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801afc:	bf 00 10 40 00       	mov    $0x401000,%edi
  801b01:	29 df                	sub    %ebx,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801b03:	89 f8                	mov    %edi,%eax
  801b05:	83 e0 fc             	and    $0xfffffffc,%eax
  801b08:	f7 d2                	not    %edx
  801b0a:	8d 14 90             	lea    (%eax,%edx,4),%edx
  801b0d:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801b13:	89 d0                	mov    %edx,%eax
  801b15:	83 e8 08             	sub    $0x8,%eax
  801b18:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801b1d:	0f 86 8f 04 00 00    	jbe    801fb2 <spawn+0x5d6>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b23:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801b2a:	00 
  801b2b:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801b32:	00 
  801b33:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b3a:	e8 a2 f3 ff ff       	call   800ee1 <sys_page_alloc>
  801b3f:	85 c0                	test   %eax,%eax
  801b41:	0f 88 70 04 00 00    	js     801fb7 <spawn+0x5db>
  801b47:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b4c:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  801b52:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b55:	eb 2e                	jmp    801b85 <spawn+0x1a9>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801b57:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801b5d:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801b63:	89 04 9a             	mov    %eax,(%edx,%ebx,4)
		strcpy(string_store, argv[i]);
  801b66:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  801b69:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b6d:	89 3c 24             	mov    %edi,(%esp)
  801b70:	e8 7a ef ff ff       	call   800aef <strcpy>
		string_store += strlen(argv[i]) + 1;
  801b75:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  801b78:	89 04 24             	mov    %eax,(%esp)
  801b7b:	e8 3c ef ff ff       	call   800abc <strlen>
  801b80:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801b84:	43                   	inc    %ebx
  801b85:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801b8b:	7c ca                	jl     801b57 <spawn+0x17b>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801b8d:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801b93:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801b99:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801ba0:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801ba6:	74 24                	je     801bcc <spawn+0x1f0>
  801ba8:	c7 44 24 0c f8 2d 80 	movl   $0x802df8,0xc(%esp)
  801baf:	00 
  801bb0:	c7 44 24 08 3f 2d 80 	movl   $0x802d3f,0x8(%esp)
  801bb7:	00 
  801bb8:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
  801bbf:	00 
  801bc0:	c7 04 24 85 2d 80 00 	movl   $0x802d85,(%esp)
  801bc7:	e8 80 e8 ff ff       	call   80044c <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801bcc:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801bd2:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801bd7:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801bdd:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  801be0:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801be6:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801be9:	89 d0                	mov    %edx,%eax
  801beb:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801bf0:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801bf6:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801bfd:	00 
  801bfe:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  801c05:	ee 
  801c06:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801c0c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c10:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801c17:	00 
  801c18:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c1f:	e8 11 f3 ff ff       	call   800f35 <sys_page_map>
  801c24:	89 c3                	mov    %eax,%ebx
  801c26:	85 c0                	test   %eax,%eax
  801c28:	78 1a                	js     801c44 <spawn+0x268>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801c2a:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801c31:	00 
  801c32:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c39:	e8 4a f3 ff ff       	call   800f88 <sys_page_unmap>
  801c3e:	89 c3                	mov    %eax,%ebx
  801c40:	85 c0                	test   %eax,%eax
  801c42:	79 1f                	jns    801c63 <spawn+0x287>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801c44:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801c4b:	00 
  801c4c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c53:	e8 30 f3 ff ff       	call   800f88 <sys_page_unmap>
	return r;
  801c58:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801c5e:	e9 3e 03 00 00       	jmp    801fa1 <spawn+0x5c5>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801c63:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  801c69:	03 95 04 fe ff ff    	add    -0x1fc(%ebp),%edx
  801c6f:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801c75:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  801c7c:	00 00 00 
  801c7f:	e9 bb 01 00 00       	jmp    801e3f <spawn+0x463>
		if (ph->p_type != ELF_PROG_LOAD)
  801c84:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801c8a:	83 38 01             	cmpl   $0x1,(%eax)
  801c8d:	0f 85 9f 01 00 00    	jne    801e32 <spawn+0x456>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801c93:	89 c2                	mov    %eax,%edx
  801c95:	8b 40 18             	mov    0x18(%eax),%eax
  801c98:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  801c9b:	83 f8 01             	cmp    $0x1,%eax
  801c9e:	19 c0                	sbb    %eax,%eax
  801ca0:	83 e0 fe             	and    $0xfffffffe,%eax
  801ca3:	83 c0 07             	add    $0x7,%eax
  801ca6:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801cac:	8b 52 04             	mov    0x4(%edx),%edx
  801caf:	89 95 78 fd ff ff    	mov    %edx,-0x288(%ebp)
  801cb5:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801cbb:	8b 40 10             	mov    0x10(%eax),%eax
  801cbe:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801cc4:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  801cca:	8b 52 14             	mov    0x14(%edx),%edx
  801ccd:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  801cd3:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801cd9:	8b 78 08             	mov    0x8(%eax),%edi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801cdc:	89 f8                	mov    %edi,%eax
  801cde:	25 ff 0f 00 00       	and    $0xfff,%eax
  801ce3:	74 16                	je     801cfb <spawn+0x31f>
		va -= i;
  801ce5:	29 c7                	sub    %eax,%edi
		memsz += i;
  801ce7:	01 c2                	add    %eax,%edx
  801ce9:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
		filesz += i;
  801cef:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  801cf5:	29 85 78 fd ff ff    	sub    %eax,-0x288(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801cfb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d00:	e9 1f 01 00 00       	jmp    801e24 <spawn+0x448>
		if (i >= filesz) {
  801d05:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  801d0b:	77 2b                	ja     801d38 <spawn+0x35c>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801d0d:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  801d13:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d17:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801d1b:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801d21:	89 04 24             	mov    %eax,(%esp)
  801d24:	e8 b8 f1 ff ff       	call   800ee1 <sys_page_alloc>
  801d29:	85 c0                	test   %eax,%eax
  801d2b:	0f 89 e7 00 00 00    	jns    801e18 <spawn+0x43c>
  801d31:	89 c6                	mov    %eax,%esi
  801d33:	e9 39 02 00 00       	jmp    801f71 <spawn+0x595>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801d38:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801d3f:	00 
  801d40:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801d47:	00 
  801d48:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d4f:	e8 8d f1 ff ff       	call   800ee1 <sys_page_alloc>
  801d54:	85 c0                	test   %eax,%eax
  801d56:	0f 88 0b 02 00 00    	js     801f67 <spawn+0x58b>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801d5c:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  801d62:	01 f0                	add    %esi,%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801d64:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d68:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801d6e:	89 04 24             	mov    %eax,(%esp)
  801d71:	e8 56 f8 ff ff       	call   8015cc <seek>
  801d76:	85 c0                	test   %eax,%eax
  801d78:	0f 88 ed 01 00 00    	js     801f6b <spawn+0x58f>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801d7e:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801d84:	29 f0                	sub    %esi,%eax
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801d86:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801d8b:	76 05                	jbe    801d92 <spawn+0x3b6>
  801d8d:	b8 00 10 00 00       	mov    $0x1000,%eax
  801d92:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d96:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801d9d:	00 
  801d9e:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801da4:	89 04 24             	mov    %eax,(%esp)
  801da7:	e8 4a f7 ff ff       	call   8014f6 <readn>
  801dac:	85 c0                	test   %eax,%eax
  801dae:	0f 88 bb 01 00 00    	js     801f6f <spawn+0x593>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801db4:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  801dba:	89 54 24 10          	mov    %edx,0x10(%esp)
  801dbe:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801dc2:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801dc8:	89 44 24 08          	mov    %eax,0x8(%esp)
  801dcc:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801dd3:	00 
  801dd4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ddb:	e8 55 f1 ff ff       	call   800f35 <sys_page_map>
  801de0:	85 c0                	test   %eax,%eax
  801de2:	79 20                	jns    801e04 <spawn+0x428>
				panic("spawn: sys_page_map data: %e", r);
  801de4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801de8:	c7 44 24 08 91 2d 80 	movl   $0x802d91,0x8(%esp)
  801def:	00 
  801df0:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
  801df7:	00 
  801df8:	c7 04 24 85 2d 80 00 	movl   $0x802d85,(%esp)
  801dff:	e8 48 e6 ff ff       	call   80044c <_panic>
			sys_page_unmap(0, UTEMP);
  801e04:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801e0b:	00 
  801e0c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e13:	e8 70 f1 ff ff       	call   800f88 <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801e18:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801e1e:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801e24:	89 de                	mov    %ebx,%esi
  801e26:	3b 9d 8c fd ff ff    	cmp    -0x274(%ebp),%ebx
  801e2c:	0f 82 d3 fe ff ff    	jb     801d05 <spawn+0x329>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801e32:	ff 85 7c fd ff ff    	incl   -0x284(%ebp)
  801e38:	83 85 80 fd ff ff 20 	addl   $0x20,-0x280(%ebp)
  801e3f:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801e46:	39 85 7c fd ff ff    	cmp    %eax,-0x284(%ebp)
  801e4c:	0f 8c 32 fe ff ff    	jl     801c84 <spawn+0x2a8>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801e52:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801e58:	89 04 24             	mov    %eax,(%esp)
  801e5b:	e8 a2 f4 ff ff       	call   801302 <close>
{
	// LAB 5: Your code here.
	int r;
	uint32_t page_num;
	
	for (page_num = 0; page_num < PGNUM(UTOP); page_num++) {
  801e60:	be 00 00 00 00       	mov    $0x0,%esi
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES)/NPDENTRIES;
  801e65:	89 f0                	mov    %esi,%eax
  801e67:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx]&PTE_P) && (uvpt[page_num]&PTE_P) && (uvpt[page_num]&PTE_SHARE)){
  801e6a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801e71:	a8 01                	test   $0x1,%al
  801e73:	0f 84 82 00 00 00    	je     801efb <spawn+0x51f>
  801e79:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801e80:	a8 01                	test   $0x1,%al
  801e82:	74 77                	je     801efb <spawn+0x51f>
  801e84:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801e8b:	f6 c4 04             	test   $0x4,%ah
  801e8e:	74 6b                	je     801efb <spawn+0x51f>
			if ((r = sys_page_map(sys_getenvid(), (void*)(page_num*PGSIZE), child, (void*)(page_num*PGSIZE), uvpt[page_num]&PTE_SYSCALL)) < 0){
  801e90:	8b 3c b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edi
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801e97:	89 f3                	mov    %esi,%ebx
  801e99:	c1 e3 0c             	shl    $0xc,%ebx
	uint32_t page_num;
	
	for (page_num = 0; page_num < PGNUM(UTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES)/NPDENTRIES;
		if ((uvpd[pdx]&PTE_P) && (uvpt[page_num]&PTE_P) && (uvpt[page_num]&PTE_SHARE)){
			if ((r = sys_page_map(sys_getenvid(), (void*)(page_num*PGSIZE), child, (void*)(page_num*PGSIZE), uvpt[page_num]&PTE_SYSCALL)) < 0){
  801e9c:	e8 02 f0 ff ff       	call   800ea3 <sys_getenvid>
  801ea1:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  801ea7:	89 7c 24 10          	mov    %edi,0x10(%esp)
  801eab:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801eaf:	8b 95 88 fd ff ff    	mov    -0x278(%ebp),%edx
  801eb5:	89 54 24 08          	mov    %edx,0x8(%esp)
  801eb9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ebd:	89 04 24             	mov    %eax,(%esp)
  801ec0:	e8 70 f0 ff ff       	call   800f35 <sys_page_map>
  801ec5:	85 c0                	test   %eax,%eax
  801ec7:	79 32                	jns    801efb <spawn+0x51f>
  801ec9:	89 c3                	mov    %eax,%ebx
				cprintf("copy_shared_pages: sys_page_map failed, %e", r);
  801ecb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ecf:	c7 04 24 20 2e 80 00 	movl   $0x802e20,(%esp)
  801ed6:	e8 69 e6 ff ff       	call   800544 <cprintf>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801edb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801edf:	c7 44 24 08 ae 2d 80 	movl   $0x802dae,0x8(%esp)
  801ee6:	00 
  801ee7:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  801eee:	00 
  801eef:	c7 04 24 85 2d 80 00 	movl   $0x802d85,(%esp)
  801ef6:	e8 51 e5 ff ff       	call   80044c <_panic>
{
	// LAB 5: Your code here.
	int r;
	uint32_t page_num;
	
	for (page_num = 0; page_num < PGNUM(UTOP); page_num++) {
  801efb:	46                   	inc    %esi
  801efc:	81 fe 00 ec 0e 00    	cmp    $0xeec00,%esi
  801f02:	0f 85 5d ff ff ff    	jne    801e65 <spawn+0x489>
  801f08:	e9 b2 00 00 00       	jmp    801fbf <spawn+0x5e3>
	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  801f0d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f11:	c7 44 24 08 c4 2d 80 	movl   $0x802dc4,0x8(%esp)
  801f18:	00 
  801f19:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  801f20:	00 
  801f21:	c7 04 24 85 2d 80 00 	movl   $0x802d85,(%esp)
  801f28:	e8 1f e5 ff ff       	call   80044c <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801f2d:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801f34:	00 
  801f35:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801f3b:	89 04 24             	mov    %eax,(%esp)
  801f3e:	e8 98 f0 ff ff       	call   800fdb <sys_env_set_status>
  801f43:	85 c0                	test   %eax,%eax
  801f45:	79 5a                	jns    801fa1 <spawn+0x5c5>
		panic("sys_env_set_status: %e", r);
  801f47:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f4b:	c7 44 24 08 de 2d 80 	movl   $0x802dde,0x8(%esp)
  801f52:	00 
  801f53:	c7 44 24 04 88 00 00 	movl   $0x88,0x4(%esp)
  801f5a:	00 
  801f5b:	c7 04 24 85 2d 80 00 	movl   $0x802d85,(%esp)
  801f62:	e8 e5 e4 ff ff       	call   80044c <_panic>
  801f67:	89 c6                	mov    %eax,%esi
  801f69:	eb 06                	jmp    801f71 <spawn+0x595>
  801f6b:	89 c6                	mov    %eax,%esi
  801f6d:	eb 02                	jmp    801f71 <spawn+0x595>
  801f6f:	89 c6                	mov    %eax,%esi

	return child;

error:
	sys_env_destroy(child);
  801f71:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801f77:	89 04 24             	mov    %eax,(%esp)
  801f7a:	e8 d2 ee ff ff       	call   800e51 <sys_env_destroy>
	close(fd);
  801f7f:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801f85:	89 04 24             	mov    %eax,(%esp)
  801f88:	e8 75 f3 ff ff       	call   801302 <close>
	return r;
  801f8d:	89 b5 88 fd ff ff    	mov    %esi,-0x278(%ebp)
  801f93:	eb 0c                	jmp    801fa1 <spawn+0x5c5>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801f95:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801f9b:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801fa1:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801fa7:	81 c4 ac 02 00 00    	add    $0x2ac,%esp
  801fad:	5b                   	pop    %ebx
  801fae:	5e                   	pop    %esi
  801faf:	5f                   	pop    %edi
  801fb0:	5d                   	pop    %ebp
  801fb1:	c3                   	ret    
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801fb2:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  801fb7:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  801fbd:	eb e2                	jmp    801fa1 <spawn+0x5c5>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801fbf:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801fc5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fc9:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801fcf:	89 04 24             	mov    %eax,(%esp)
  801fd2:	e8 57 f0 ff ff       	call   80102e <sys_env_set_trapframe>
  801fd7:	85 c0                	test   %eax,%eax
  801fd9:	0f 89 4e ff ff ff    	jns    801f2d <spawn+0x551>
  801fdf:	e9 29 ff ff ff       	jmp    801f0d <spawn+0x531>

00801fe4 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801fe4:	55                   	push   %ebp
  801fe5:	89 e5                	mov    %esp,%ebp
  801fe7:	57                   	push   %edi
  801fe8:	56                   	push   %esi
  801fe9:	53                   	push   %ebx
  801fea:	83 ec 1c             	sub    $0x1c,%esp
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
  801fed:	8d 45 10             	lea    0x10(%ebp),%eax
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801ff0:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801ff5:	eb 03                	jmp    801ffa <spawnl+0x16>
		argc++;
  801ff7:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801ff8:	89 d0                	mov    %edx,%eax
  801ffa:	8d 50 04             	lea    0x4(%eax),%edx
  801ffd:	83 38 00             	cmpl   $0x0,(%eax)
  802000:	75 f5                	jne    801ff7 <spawnl+0x13>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802002:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  802009:	83 e0 f0             	and    $0xfffffff0,%eax
  80200c:	29 c4                	sub    %eax,%esp
  80200e:	8d 7c 24 17          	lea    0x17(%esp),%edi
  802012:	83 e7 f0             	and    $0xfffffff0,%edi
  802015:	89 fe                	mov    %edi,%esi
	argv[0] = arg0;
  802017:	8b 45 0c             	mov    0xc(%ebp),%eax
  80201a:	89 07                	mov    %eax,(%edi)
	argv[argc+1] = NULL;
  80201c:	c7 44 8f 04 00 00 00 	movl   $0x0,0x4(%edi,%ecx,4)
  802023:	00 

	va_start(vl, arg0);
  802024:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  802027:	b8 00 00 00 00       	mov    $0x0,%eax
  80202c:	eb 09                	jmp    802037 <spawnl+0x53>
		argv[i+1] = va_arg(vl, const char *);
  80202e:	40                   	inc    %eax
  80202f:	8b 1a                	mov    (%edx),%ebx
  802031:	89 1c 86             	mov    %ebx,(%esi,%eax,4)
  802034:	8d 52 04             	lea    0x4(%edx),%edx
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802037:	39 c8                	cmp    %ecx,%eax
  802039:	75 f3                	jne    80202e <spawnl+0x4a>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  80203b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80203f:	8b 45 08             	mov    0x8(%ebp),%eax
  802042:	89 04 24             	mov    %eax,(%esp)
  802045:	e8 92 f9 ff ff       	call   8019dc <spawn>
}
  80204a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80204d:	5b                   	pop    %ebx
  80204e:	5e                   	pop    %esi
  80204f:	5f                   	pop    %edi
  802050:	5d                   	pop    %ebp
  802051:	c3                   	ret    
	...

00802054 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802054:	55                   	push   %ebp
  802055:	89 e5                	mov    %esp,%ebp
  802057:	56                   	push   %esi
  802058:	53                   	push   %ebx
  802059:	83 ec 10             	sub    $0x10,%esp
  80205c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80205f:	8b 45 08             	mov    0x8(%ebp),%eax
  802062:	89 04 24             	mov    %eax,(%esp)
  802065:	e8 f2 f0 ff ff       	call   80115c <fd2data>
  80206a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  80206c:	c7 44 24 04 4b 2e 80 	movl   $0x802e4b,0x4(%esp)
  802073:	00 
  802074:	89 34 24             	mov    %esi,(%esp)
  802077:	e8 73 ea ff ff       	call   800aef <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80207c:	8b 43 04             	mov    0x4(%ebx),%eax
  80207f:	2b 03                	sub    (%ebx),%eax
  802081:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  802087:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80208e:	00 00 00 
	stat->st_dev = &devpipe;
  802091:	c7 86 88 00 00 00 ac 	movl   $0x8047ac,0x88(%esi)
  802098:	47 80 00 
	return 0;
}
  80209b:	b8 00 00 00 00       	mov    $0x0,%eax
  8020a0:	83 c4 10             	add    $0x10,%esp
  8020a3:	5b                   	pop    %ebx
  8020a4:	5e                   	pop    %esi
  8020a5:	5d                   	pop    %ebp
  8020a6:	c3                   	ret    

008020a7 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8020a7:	55                   	push   %ebp
  8020a8:	89 e5                	mov    %esp,%ebp
  8020aa:	53                   	push   %ebx
  8020ab:	83 ec 14             	sub    $0x14,%esp
  8020ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8020b1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8020b5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020bc:	e8 c7 ee ff ff       	call   800f88 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8020c1:	89 1c 24             	mov    %ebx,(%esp)
  8020c4:	e8 93 f0 ff ff       	call   80115c <fd2data>
  8020c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020d4:	e8 af ee ff ff       	call   800f88 <sys_page_unmap>
}
  8020d9:	83 c4 14             	add    $0x14,%esp
  8020dc:	5b                   	pop    %ebx
  8020dd:	5d                   	pop    %ebp
  8020de:	c3                   	ret    

008020df <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8020df:	55                   	push   %ebp
  8020e0:	89 e5                	mov    %esp,%ebp
  8020e2:	57                   	push   %edi
  8020e3:	56                   	push   %esi
  8020e4:	53                   	push   %ebx
  8020e5:	83 ec 2c             	sub    $0x2c,%esp
  8020e8:	89 c7                	mov    %eax,%edi
  8020ea:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8020ed:	a1 90 67 80 00       	mov    0x806790,%eax
  8020f2:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8020f5:	89 3c 24             	mov    %edi,(%esp)
  8020f8:	e8 57 04 00 00       	call   802554 <pageref>
  8020fd:	89 c6                	mov    %eax,%esi
  8020ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802102:	89 04 24             	mov    %eax,(%esp)
  802105:	e8 4a 04 00 00       	call   802554 <pageref>
  80210a:	39 c6                	cmp    %eax,%esi
  80210c:	0f 94 c0             	sete   %al
  80210f:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  802112:	8b 15 90 67 80 00    	mov    0x806790,%edx
  802118:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80211b:	39 cb                	cmp    %ecx,%ebx
  80211d:	75 08                	jne    802127 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  80211f:	83 c4 2c             	add    $0x2c,%esp
  802122:	5b                   	pop    %ebx
  802123:	5e                   	pop    %esi
  802124:	5f                   	pop    %edi
  802125:	5d                   	pop    %ebp
  802126:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  802127:	83 f8 01             	cmp    $0x1,%eax
  80212a:	75 c1                	jne    8020ed <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80212c:	8b 42 58             	mov    0x58(%edx),%eax
  80212f:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  802136:	00 
  802137:	89 44 24 08          	mov    %eax,0x8(%esp)
  80213b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80213f:	c7 04 24 52 2e 80 00 	movl   $0x802e52,(%esp)
  802146:	e8 f9 e3 ff ff       	call   800544 <cprintf>
  80214b:	eb a0                	jmp    8020ed <_pipeisclosed+0xe>

0080214d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80214d:	55                   	push   %ebp
  80214e:	89 e5                	mov    %esp,%ebp
  802150:	57                   	push   %edi
  802151:	56                   	push   %esi
  802152:	53                   	push   %ebx
  802153:	83 ec 1c             	sub    $0x1c,%esp
  802156:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802159:	89 34 24             	mov    %esi,(%esp)
  80215c:	e8 fb ef ff ff       	call   80115c <fd2data>
  802161:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802163:	bf 00 00 00 00       	mov    $0x0,%edi
  802168:	eb 3c                	jmp    8021a6 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80216a:	89 da                	mov    %ebx,%edx
  80216c:	89 f0                	mov    %esi,%eax
  80216e:	e8 6c ff ff ff       	call   8020df <_pipeisclosed>
  802173:	85 c0                	test   %eax,%eax
  802175:	75 38                	jne    8021af <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802177:	e8 46 ed ff ff       	call   800ec2 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80217c:	8b 43 04             	mov    0x4(%ebx),%eax
  80217f:	8b 13                	mov    (%ebx),%edx
  802181:	83 c2 20             	add    $0x20,%edx
  802184:	39 d0                	cmp    %edx,%eax
  802186:	73 e2                	jae    80216a <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802188:	8b 55 0c             	mov    0xc(%ebp),%edx
  80218b:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  80218e:	89 c2                	mov    %eax,%edx
  802190:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  802196:	79 05                	jns    80219d <devpipe_write+0x50>
  802198:	4a                   	dec    %edx
  802199:	83 ca e0             	or     $0xffffffe0,%edx
  80219c:	42                   	inc    %edx
  80219d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8021a1:	40                   	inc    %eax
  8021a2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021a5:	47                   	inc    %edi
  8021a6:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8021a9:	75 d1                	jne    80217c <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8021ab:	89 f8                	mov    %edi,%eax
  8021ad:	eb 05                	jmp    8021b4 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8021af:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8021b4:	83 c4 1c             	add    $0x1c,%esp
  8021b7:	5b                   	pop    %ebx
  8021b8:	5e                   	pop    %esi
  8021b9:	5f                   	pop    %edi
  8021ba:	5d                   	pop    %ebp
  8021bb:	c3                   	ret    

008021bc <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8021bc:	55                   	push   %ebp
  8021bd:	89 e5                	mov    %esp,%ebp
  8021bf:	57                   	push   %edi
  8021c0:	56                   	push   %esi
  8021c1:	53                   	push   %ebx
  8021c2:	83 ec 1c             	sub    $0x1c,%esp
  8021c5:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8021c8:	89 3c 24             	mov    %edi,(%esp)
  8021cb:	e8 8c ef ff ff       	call   80115c <fd2data>
  8021d0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021d2:	be 00 00 00 00       	mov    $0x0,%esi
  8021d7:	eb 3a                	jmp    802213 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8021d9:	85 f6                	test   %esi,%esi
  8021db:	74 04                	je     8021e1 <devpipe_read+0x25>
				return i;
  8021dd:	89 f0                	mov    %esi,%eax
  8021df:	eb 40                	jmp    802221 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8021e1:	89 da                	mov    %ebx,%edx
  8021e3:	89 f8                	mov    %edi,%eax
  8021e5:	e8 f5 fe ff ff       	call   8020df <_pipeisclosed>
  8021ea:	85 c0                	test   %eax,%eax
  8021ec:	75 2e                	jne    80221c <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8021ee:	e8 cf ec ff ff       	call   800ec2 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8021f3:	8b 03                	mov    (%ebx),%eax
  8021f5:	3b 43 04             	cmp    0x4(%ebx),%eax
  8021f8:	74 df                	je     8021d9 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8021fa:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8021ff:	79 05                	jns    802206 <devpipe_read+0x4a>
  802201:	48                   	dec    %eax
  802202:	83 c8 e0             	or     $0xffffffe0,%eax
  802205:	40                   	inc    %eax
  802206:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80220a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80220d:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  802210:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802212:	46                   	inc    %esi
  802213:	3b 75 10             	cmp    0x10(%ebp),%esi
  802216:	75 db                	jne    8021f3 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802218:	89 f0                	mov    %esi,%eax
  80221a:	eb 05                	jmp    802221 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80221c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802221:	83 c4 1c             	add    $0x1c,%esp
  802224:	5b                   	pop    %ebx
  802225:	5e                   	pop    %esi
  802226:	5f                   	pop    %edi
  802227:	5d                   	pop    %ebp
  802228:	c3                   	ret    

00802229 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802229:	55                   	push   %ebp
  80222a:	89 e5                	mov    %esp,%ebp
  80222c:	57                   	push   %edi
  80222d:	56                   	push   %esi
  80222e:	53                   	push   %ebx
  80222f:	83 ec 3c             	sub    $0x3c,%esp
  802232:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802235:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802238:	89 04 24             	mov    %eax,(%esp)
  80223b:	e8 37 ef ff ff       	call   801177 <fd_alloc>
  802240:	89 c3                	mov    %eax,%ebx
  802242:	85 c0                	test   %eax,%eax
  802244:	0f 88 45 01 00 00    	js     80238f <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80224a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802251:	00 
  802252:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802255:	89 44 24 04          	mov    %eax,0x4(%esp)
  802259:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802260:	e8 7c ec ff ff       	call   800ee1 <sys_page_alloc>
  802265:	89 c3                	mov    %eax,%ebx
  802267:	85 c0                	test   %eax,%eax
  802269:	0f 88 20 01 00 00    	js     80238f <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80226f:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802272:	89 04 24             	mov    %eax,(%esp)
  802275:	e8 fd ee ff ff       	call   801177 <fd_alloc>
  80227a:	89 c3                	mov    %eax,%ebx
  80227c:	85 c0                	test   %eax,%eax
  80227e:	0f 88 f8 00 00 00    	js     80237c <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802284:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80228b:	00 
  80228c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80228f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802293:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80229a:	e8 42 ec ff ff       	call   800ee1 <sys_page_alloc>
  80229f:	89 c3                	mov    %eax,%ebx
  8022a1:	85 c0                	test   %eax,%eax
  8022a3:	0f 88 d3 00 00 00    	js     80237c <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8022a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8022ac:	89 04 24             	mov    %eax,(%esp)
  8022af:	e8 a8 ee ff ff       	call   80115c <fd2data>
  8022b4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022b6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8022bd:	00 
  8022be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022c2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022c9:	e8 13 ec ff ff       	call   800ee1 <sys_page_alloc>
  8022ce:	89 c3                	mov    %eax,%ebx
  8022d0:	85 c0                	test   %eax,%eax
  8022d2:	0f 88 91 00 00 00    	js     802369 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8022db:	89 04 24             	mov    %eax,(%esp)
  8022de:	e8 79 ee ff ff       	call   80115c <fd2data>
  8022e3:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8022ea:	00 
  8022eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022ef:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8022f6:	00 
  8022f7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802302:	e8 2e ec ff ff       	call   800f35 <sys_page_map>
  802307:	89 c3                	mov    %eax,%ebx
  802309:	85 c0                	test   %eax,%eax
  80230b:	78 4c                	js     802359 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80230d:	8b 15 ac 47 80 00    	mov    0x8047ac,%edx
  802313:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802316:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802318:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80231b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802322:	8b 15 ac 47 80 00    	mov    0x8047ac,%edx
  802328:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80232b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80232d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802330:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802337:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80233a:	89 04 24             	mov    %eax,(%esp)
  80233d:	e8 0a ee ff ff       	call   80114c <fd2num>
  802342:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802344:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802347:	89 04 24             	mov    %eax,(%esp)
  80234a:	e8 fd ed ff ff       	call   80114c <fd2num>
  80234f:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  802352:	bb 00 00 00 00       	mov    $0x0,%ebx
  802357:	eb 36                	jmp    80238f <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  802359:	89 74 24 04          	mov    %esi,0x4(%esp)
  80235d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802364:	e8 1f ec ff ff       	call   800f88 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802369:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80236c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802370:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802377:	e8 0c ec ff ff       	call   800f88 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  80237c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80237f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802383:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80238a:	e8 f9 eb ff ff       	call   800f88 <sys_page_unmap>
    err:
	return r;
}
  80238f:	89 d8                	mov    %ebx,%eax
  802391:	83 c4 3c             	add    $0x3c,%esp
  802394:	5b                   	pop    %ebx
  802395:	5e                   	pop    %esi
  802396:	5f                   	pop    %edi
  802397:	5d                   	pop    %ebp
  802398:	c3                   	ret    

00802399 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802399:	55                   	push   %ebp
  80239a:	89 e5                	mov    %esp,%ebp
  80239c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80239f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8023a9:	89 04 24             	mov    %eax,(%esp)
  8023ac:	e8 19 ee ff ff       	call   8011ca <fd_lookup>
  8023b1:	85 c0                	test   %eax,%eax
  8023b3:	78 15                	js     8023ca <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8023b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023b8:	89 04 24             	mov    %eax,(%esp)
  8023bb:	e8 9c ed ff ff       	call   80115c <fd2data>
	return _pipeisclosed(fd, p);
  8023c0:	89 c2                	mov    %eax,%edx
  8023c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023c5:	e8 15 fd ff ff       	call   8020df <_pipeisclosed>
}
  8023ca:	c9                   	leave  
  8023cb:	c3                   	ret    

008023cc <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8023cc:	55                   	push   %ebp
  8023cd:	89 e5                	mov    %esp,%ebp
  8023cf:	56                   	push   %esi
  8023d0:	53                   	push   %ebx
  8023d1:	83 ec 10             	sub    $0x10,%esp
  8023d4:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  8023d7:	85 f6                	test   %esi,%esi
  8023d9:	75 24                	jne    8023ff <wait+0x33>
  8023db:	c7 44 24 0c 6a 2e 80 	movl   $0x802e6a,0xc(%esp)
  8023e2:	00 
  8023e3:	c7 44 24 08 3f 2d 80 	movl   $0x802d3f,0x8(%esp)
  8023ea:	00 
  8023eb:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  8023f2:	00 
  8023f3:	c7 04 24 75 2e 80 00 	movl   $0x802e75,(%esp)
  8023fa:	e8 4d e0 ff ff       	call   80044c <_panic>
	e = &envs[ENVX(envid)];
  8023ff:	89 f3                	mov    %esi,%ebx
  802401:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  802407:	8d 04 9d 00 00 00 00 	lea    0x0(,%ebx,4),%eax
  80240e:	c1 e3 07             	shl    $0x7,%ebx
  802411:	29 c3                	sub    %eax,%ebx
  802413:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802419:	eb 05                	jmp    802420 <wait+0x54>
		sys_yield();
  80241b:	e8 a2 ea ff ff       	call   800ec2 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802420:	8b 43 48             	mov    0x48(%ebx),%eax
  802423:	39 f0                	cmp    %esi,%eax
  802425:	75 07                	jne    80242e <wait+0x62>
  802427:	8b 43 54             	mov    0x54(%ebx),%eax
  80242a:	85 c0                	test   %eax,%eax
  80242c:	75 ed                	jne    80241b <wait+0x4f>
		sys_yield();
}
  80242e:	83 c4 10             	add    $0x10,%esp
  802431:	5b                   	pop    %ebx
  802432:	5e                   	pop    %esi
  802433:	5d                   	pop    %ebp
  802434:	c3                   	ret    
  802435:	00 00                	add    %al,(%eax)
	...

00802438 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802438:	55                   	push   %ebp
  802439:	89 e5                	mov    %esp,%ebp
  80243b:	56                   	push   %esi
  80243c:	53                   	push   %ebx
  80243d:	83 ec 10             	sub    $0x10,%esp
  802440:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802443:	8b 45 0c             	mov    0xc(%ebp),%eax
  802446:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int r;
		
	r = sys_ipc_recv(pg?pg:(void*)UTOP);
  802449:	85 c0                	test   %eax,%eax
  80244b:	75 05                	jne    802452 <ipc_recv+0x1a>
  80244d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802452:	89 04 24             	mov    %eax,(%esp)
  802455:	e8 9d ec ff ff       	call   8010f7 <sys_ipc_recv>
	if (from_env_store != NULL)
  80245a:	85 db                	test   %ebx,%ebx
  80245c:	74 0b                	je     802469 <ipc_recv+0x31>
		*from_env_store = thisenv->env_ipc_from; 
  80245e:	8b 15 90 67 80 00    	mov    0x806790,%edx
  802464:	8b 52 74             	mov    0x74(%edx),%edx
  802467:	89 13                	mov    %edx,(%ebx)
	if (perm_store != NULL)
  802469:	85 f6                	test   %esi,%esi
  80246b:	74 0b                	je     802478 <ipc_recv+0x40>
		*perm_store = thisenv->env_ipc_perm;
  80246d:	8b 15 90 67 80 00    	mov    0x806790,%edx
  802473:	8b 52 78             	mov    0x78(%edx),%edx
  802476:	89 16                	mov    %edx,(%esi)
	
	if (r < 0){
  802478:	85 c0                	test   %eax,%eax
  80247a:	79 16                	jns    802492 <ipc_recv+0x5a>
		if(from_env_store != NULL)
  80247c:	85 db                	test   %ebx,%ebx
  80247e:	74 06                	je     802486 <ipc_recv+0x4e>
			*from_env_store = 0;
  802480:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store != NULL)	
  802486:	85 f6                	test   %esi,%esi
  802488:	74 10                	je     80249a <ipc_recv+0x62>
			*perm_store = 0;
  80248a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  802490:	eb 08                	jmp    80249a <ipc_recv+0x62>
		return r;
	}
	
	return thisenv->env_ipc_value;
  802492:	a1 90 67 80 00       	mov    0x806790,%eax
  802497:	8b 40 70             	mov    0x70(%eax),%eax
}
  80249a:	83 c4 10             	add    $0x10,%esp
  80249d:	5b                   	pop    %ebx
  80249e:	5e                   	pop    %esi
  80249f:	5d                   	pop    %ebp
  8024a0:	c3                   	ret    

008024a1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8024a1:	55                   	push   %ebp
  8024a2:	89 e5                	mov    %esp,%ebp
  8024a4:	57                   	push   %edi
  8024a5:	56                   	push   %esi
  8024a6:	53                   	push   %ebx
  8024a7:	83 ec 1c             	sub    $0x1c,%esp
  8024aa:	8b 75 08             	mov    0x8(%ebp),%esi
  8024ad:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8024b0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  8024b3:	eb 2a                	jmp    8024df <ipc_send+0x3e>
		if (r != -E_IPC_NOT_RECV)
  8024b5:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8024b8:	74 20                	je     8024da <ipc_send+0x39>
			panic("ipc_send: sys_ipc_try_send failed %e", r);
  8024ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024be:	c7 44 24 08 80 2e 80 	movl   $0x802e80,0x8(%esp)
  8024c5:	00 
  8024c6:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  8024cd:	00 
  8024ce:	c7 04 24 a8 2e 80 00 	movl   $0x802ea8,(%esp)
  8024d5:	e8 72 df ff ff       	call   80044c <_panic>
		sys_yield();
  8024da:	e8 e3 e9 ff ff       	call   800ec2 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  8024df:	85 db                	test   %ebx,%ebx
  8024e1:	75 07                	jne    8024ea <ipc_send+0x49>
  8024e3:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8024e8:	eb 02                	jmp    8024ec <ipc_send+0x4b>
  8024ea:	89 d8                	mov    %ebx,%eax
  8024ec:	8b 55 14             	mov    0x14(%ebp),%edx
  8024ef:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8024f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8024f7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8024fb:	89 34 24             	mov    %esi,(%esp)
  8024fe:	e8 d1 eb ff ff       	call   8010d4 <sys_ipc_try_send>
  802503:	85 c0                	test   %eax,%eax
  802505:	78 ae                	js     8024b5 <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: sys_ipc_try_send failed %e", r);
		sys_yield();
	}
}
  802507:	83 c4 1c             	add    $0x1c,%esp
  80250a:	5b                   	pop    %ebx
  80250b:	5e                   	pop    %esi
  80250c:	5f                   	pop    %edi
  80250d:	5d                   	pop    %ebp
  80250e:	c3                   	ret    

0080250f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80250f:	55                   	push   %ebp
  802510:	89 e5                	mov    %esp,%ebp
  802512:	53                   	push   %ebx
  802513:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  802516:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80251b:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802522:	89 c2                	mov    %eax,%edx
  802524:	c1 e2 07             	shl    $0x7,%edx
  802527:	29 ca                	sub    %ecx,%edx
  802529:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80252f:	8b 52 50             	mov    0x50(%edx),%edx
  802532:	39 da                	cmp    %ebx,%edx
  802534:	75 0f                	jne    802545 <ipc_find_env+0x36>
			return envs[i].env_id;
  802536:	c1 e0 07             	shl    $0x7,%eax
  802539:	29 c8                	sub    %ecx,%eax
  80253b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802540:	8b 40 40             	mov    0x40(%eax),%eax
  802543:	eb 0c                	jmp    802551 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802545:	40                   	inc    %eax
  802546:	3d 00 04 00 00       	cmp    $0x400,%eax
  80254b:	75 ce                	jne    80251b <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80254d:	66 b8 00 00          	mov    $0x0,%ax
}
  802551:	5b                   	pop    %ebx
  802552:	5d                   	pop    %ebp
  802553:	c3                   	ret    

00802554 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802554:	55                   	push   %ebp
  802555:	89 e5                	mov    %esp,%ebp
  802557:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80255a:	89 c2                	mov    %eax,%edx
  80255c:	c1 ea 16             	shr    $0x16,%edx
  80255f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802566:	f6 c2 01             	test   $0x1,%dl
  802569:	74 1e                	je     802589 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  80256b:	c1 e8 0c             	shr    $0xc,%eax
  80256e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802575:	a8 01                	test   $0x1,%al
  802577:	74 17                	je     802590 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802579:	c1 e8 0c             	shr    $0xc,%eax
  80257c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802583:	ef 
  802584:	0f b7 c0             	movzwl %ax,%eax
  802587:	eb 0c                	jmp    802595 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802589:	b8 00 00 00 00       	mov    $0x0,%eax
  80258e:	eb 05                	jmp    802595 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802590:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802595:	5d                   	pop    %ebp
  802596:	c3                   	ret    
	...

00802598 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802598:	55                   	push   %ebp
  802599:	57                   	push   %edi
  80259a:	56                   	push   %esi
  80259b:	83 ec 10             	sub    $0x10,%esp
  80259e:	8b 74 24 20          	mov    0x20(%esp),%esi
  8025a2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8025a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025aa:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  8025ae:	89 cd                	mov    %ecx,%ebp
  8025b0:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8025b4:	85 c0                	test   %eax,%eax
  8025b6:	75 2c                	jne    8025e4 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8025b8:	39 f9                	cmp    %edi,%ecx
  8025ba:	77 68                	ja     802624 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8025bc:	85 c9                	test   %ecx,%ecx
  8025be:	75 0b                	jne    8025cb <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8025c0:	b8 01 00 00 00       	mov    $0x1,%eax
  8025c5:	31 d2                	xor    %edx,%edx
  8025c7:	f7 f1                	div    %ecx
  8025c9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8025cb:	31 d2                	xor    %edx,%edx
  8025cd:	89 f8                	mov    %edi,%eax
  8025cf:	f7 f1                	div    %ecx
  8025d1:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8025d3:	89 f0                	mov    %esi,%eax
  8025d5:	f7 f1                	div    %ecx
  8025d7:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8025d9:	89 f0                	mov    %esi,%eax
  8025db:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8025dd:	83 c4 10             	add    $0x10,%esp
  8025e0:	5e                   	pop    %esi
  8025e1:	5f                   	pop    %edi
  8025e2:	5d                   	pop    %ebp
  8025e3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8025e4:	39 f8                	cmp    %edi,%eax
  8025e6:	77 2c                	ja     802614 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8025e8:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  8025eb:	83 f6 1f             	xor    $0x1f,%esi
  8025ee:	75 4c                	jne    80263c <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8025f0:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8025f2:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8025f7:	72 0a                	jb     802603 <__udivdi3+0x6b>
  8025f9:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8025fd:	0f 87 ad 00 00 00    	ja     8026b0 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802603:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802608:	89 f0                	mov    %esi,%eax
  80260a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80260c:	83 c4 10             	add    $0x10,%esp
  80260f:	5e                   	pop    %esi
  802610:	5f                   	pop    %edi
  802611:	5d                   	pop    %ebp
  802612:	c3                   	ret    
  802613:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802614:	31 ff                	xor    %edi,%edi
  802616:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802618:	89 f0                	mov    %esi,%eax
  80261a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80261c:	83 c4 10             	add    $0x10,%esp
  80261f:	5e                   	pop    %esi
  802620:	5f                   	pop    %edi
  802621:	5d                   	pop    %ebp
  802622:	c3                   	ret    
  802623:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802624:	89 fa                	mov    %edi,%edx
  802626:	89 f0                	mov    %esi,%eax
  802628:	f7 f1                	div    %ecx
  80262a:	89 c6                	mov    %eax,%esi
  80262c:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80262e:	89 f0                	mov    %esi,%eax
  802630:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802632:	83 c4 10             	add    $0x10,%esp
  802635:	5e                   	pop    %esi
  802636:	5f                   	pop    %edi
  802637:	5d                   	pop    %ebp
  802638:	c3                   	ret    
  802639:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80263c:	89 f1                	mov    %esi,%ecx
  80263e:	d3 e0                	shl    %cl,%eax
  802640:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802644:	b8 20 00 00 00       	mov    $0x20,%eax
  802649:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80264b:	89 ea                	mov    %ebp,%edx
  80264d:	88 c1                	mov    %al,%cl
  80264f:	d3 ea                	shr    %cl,%edx
  802651:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802655:	09 ca                	or     %ecx,%edx
  802657:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  80265b:	89 f1                	mov    %esi,%ecx
  80265d:	d3 e5                	shl    %cl,%ebp
  80265f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  802663:	89 fd                	mov    %edi,%ebp
  802665:	88 c1                	mov    %al,%cl
  802667:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802669:	89 fa                	mov    %edi,%edx
  80266b:	89 f1                	mov    %esi,%ecx
  80266d:	d3 e2                	shl    %cl,%edx
  80266f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802673:	88 c1                	mov    %al,%cl
  802675:	d3 ef                	shr    %cl,%edi
  802677:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802679:	89 f8                	mov    %edi,%eax
  80267b:	89 ea                	mov    %ebp,%edx
  80267d:	f7 74 24 08          	divl   0x8(%esp)
  802681:	89 d1                	mov    %edx,%ecx
  802683:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802685:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802689:	39 d1                	cmp    %edx,%ecx
  80268b:	72 17                	jb     8026a4 <__udivdi3+0x10c>
  80268d:	74 09                	je     802698 <__udivdi3+0x100>
  80268f:	89 fe                	mov    %edi,%esi
  802691:	31 ff                	xor    %edi,%edi
  802693:	e9 41 ff ff ff       	jmp    8025d9 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802698:	8b 54 24 04          	mov    0x4(%esp),%edx
  80269c:	89 f1                	mov    %esi,%ecx
  80269e:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8026a0:	39 c2                	cmp    %eax,%edx
  8026a2:	73 eb                	jae    80268f <__udivdi3+0xf7>
		{
		  q0--;
  8026a4:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8026a7:	31 ff                	xor    %edi,%edi
  8026a9:	e9 2b ff ff ff       	jmp    8025d9 <__udivdi3+0x41>
  8026ae:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8026b0:	31 f6                	xor    %esi,%esi
  8026b2:	e9 22 ff ff ff       	jmp    8025d9 <__udivdi3+0x41>
	...

008026b8 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8026b8:	55                   	push   %ebp
  8026b9:	57                   	push   %edi
  8026ba:	56                   	push   %esi
  8026bb:	83 ec 20             	sub    $0x20,%esp
  8026be:	8b 44 24 30          	mov    0x30(%esp),%eax
  8026c2:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8026c6:	89 44 24 14          	mov    %eax,0x14(%esp)
  8026ca:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  8026ce:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8026d2:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8026d6:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  8026d8:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8026da:	85 ed                	test   %ebp,%ebp
  8026dc:	75 16                	jne    8026f4 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  8026de:	39 f1                	cmp    %esi,%ecx
  8026e0:	0f 86 a6 00 00 00    	jbe    80278c <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8026e6:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8026e8:	89 d0                	mov    %edx,%eax
  8026ea:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8026ec:	83 c4 20             	add    $0x20,%esp
  8026ef:	5e                   	pop    %esi
  8026f0:	5f                   	pop    %edi
  8026f1:	5d                   	pop    %ebp
  8026f2:	c3                   	ret    
  8026f3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8026f4:	39 f5                	cmp    %esi,%ebp
  8026f6:	0f 87 ac 00 00 00    	ja     8027a8 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8026fc:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  8026ff:	83 f0 1f             	xor    $0x1f,%eax
  802702:	89 44 24 10          	mov    %eax,0x10(%esp)
  802706:	0f 84 a8 00 00 00    	je     8027b4 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80270c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802710:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802712:	bf 20 00 00 00       	mov    $0x20,%edi
  802717:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80271b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80271f:	89 f9                	mov    %edi,%ecx
  802721:	d3 e8                	shr    %cl,%eax
  802723:	09 e8                	or     %ebp,%eax
  802725:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  802729:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80272d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802731:	d3 e0                	shl    %cl,%eax
  802733:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802737:	89 f2                	mov    %esi,%edx
  802739:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80273b:	8b 44 24 14          	mov    0x14(%esp),%eax
  80273f:	d3 e0                	shl    %cl,%eax
  802741:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802745:	8b 44 24 14          	mov    0x14(%esp),%eax
  802749:	89 f9                	mov    %edi,%ecx
  80274b:	d3 e8                	shr    %cl,%eax
  80274d:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80274f:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802751:	89 f2                	mov    %esi,%edx
  802753:	f7 74 24 18          	divl   0x18(%esp)
  802757:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802759:	f7 64 24 0c          	mull   0xc(%esp)
  80275d:	89 c5                	mov    %eax,%ebp
  80275f:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802761:	39 d6                	cmp    %edx,%esi
  802763:	72 67                	jb     8027cc <__umoddi3+0x114>
  802765:	74 75                	je     8027dc <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802767:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80276b:	29 e8                	sub    %ebp,%eax
  80276d:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80276f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802773:	d3 e8                	shr    %cl,%eax
  802775:	89 f2                	mov    %esi,%edx
  802777:	89 f9                	mov    %edi,%ecx
  802779:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80277b:	09 d0                	or     %edx,%eax
  80277d:	89 f2                	mov    %esi,%edx
  80277f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802783:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802785:	83 c4 20             	add    $0x20,%esp
  802788:	5e                   	pop    %esi
  802789:	5f                   	pop    %edi
  80278a:	5d                   	pop    %ebp
  80278b:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80278c:	85 c9                	test   %ecx,%ecx
  80278e:	75 0b                	jne    80279b <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802790:	b8 01 00 00 00       	mov    $0x1,%eax
  802795:	31 d2                	xor    %edx,%edx
  802797:	f7 f1                	div    %ecx
  802799:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80279b:	89 f0                	mov    %esi,%eax
  80279d:	31 d2                	xor    %edx,%edx
  80279f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8027a1:	89 f8                	mov    %edi,%eax
  8027a3:	e9 3e ff ff ff       	jmp    8026e6 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8027a8:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8027aa:	83 c4 20             	add    $0x20,%esp
  8027ad:	5e                   	pop    %esi
  8027ae:	5f                   	pop    %edi
  8027af:	5d                   	pop    %ebp
  8027b0:	c3                   	ret    
  8027b1:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8027b4:	39 f5                	cmp    %esi,%ebp
  8027b6:	72 04                	jb     8027bc <__umoddi3+0x104>
  8027b8:	39 f9                	cmp    %edi,%ecx
  8027ba:	77 06                	ja     8027c2 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8027bc:	89 f2                	mov    %esi,%edx
  8027be:	29 cf                	sub    %ecx,%edi
  8027c0:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8027c2:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8027c4:	83 c4 20             	add    $0x20,%esp
  8027c7:	5e                   	pop    %esi
  8027c8:	5f                   	pop    %edi
  8027c9:	5d                   	pop    %ebp
  8027ca:	c3                   	ret    
  8027cb:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8027cc:	89 d1                	mov    %edx,%ecx
  8027ce:	89 c5                	mov    %eax,%ebp
  8027d0:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8027d4:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8027d8:	eb 8d                	jmp    802767 <__umoddi3+0xaf>
  8027da:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8027dc:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8027e0:	72 ea                	jb     8027cc <__umoddi3+0x114>
  8027e2:	89 f1                	mov    %esi,%ecx
  8027e4:	eb 81                	jmp    802767 <__umoddi3+0xaf>
