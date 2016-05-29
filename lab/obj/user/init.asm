
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
  80006c:	c7 04 24 40 2d 80 00 	movl   $0x802d40,(%esp)
  800073:	e8 c0 04 00 00       	call   800538 <cprintf>

	want = 0xf989e;
	if ((x = sum((char*)&data, sizeof data)) != want)
  800078:	c7 44 24 04 70 17 00 	movl   $0x1770,0x4(%esp)
  80007f:	00 
  800080:	c7 04 24 00 40 80 00 	movl   $0x804000,(%esp)
  800087:	e8 a8 ff ff ff       	call   800034 <sum>
  80008c:	3d 9e 98 0f 00       	cmp    $0xf989e,%eax
  800091:	74 1a                	je     8000ad <umain+0x50>
		cprintf("init: data is not initialized: got sum %08x wanted %08x\n",
  800093:	c7 44 24 08 9e 98 0f 	movl   $0xf989e,0x8(%esp)
  80009a:	00 
  80009b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80009f:	c7 04 24 08 2e 80 00 	movl   $0x802e08,(%esp)
  8000a6:	e8 8d 04 00 00       	call   800538 <cprintf>
  8000ab:	eb 0c                	jmp    8000b9 <umain+0x5c>
			x, want);
	else
		cprintf("init: data seems okay\n");
  8000ad:	c7 04 24 4f 2d 80 00 	movl   $0x802d4f,(%esp)
  8000b4:	e8 7f 04 00 00       	call   800538 <cprintf>
	if ((x = sum(bss, sizeof bss)) != 0)
  8000b9:	c7 44 24 04 70 17 00 	movl   $0x1770,0x4(%esp)
  8000c0:	00 
  8000c1:	c7 04 24 20 60 80 00 	movl   $0x806020,(%esp)
  8000c8:	e8 67 ff ff ff       	call   800034 <sum>
  8000cd:	85 c0                	test   %eax,%eax
  8000cf:	74 12                	je     8000e3 <umain+0x86>
		cprintf("bss is not initialized: wanted sum 0 got %08x\n", x);
  8000d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000d5:	c7 04 24 44 2e 80 00 	movl   $0x802e44,(%esp)
  8000dc:	e8 57 04 00 00       	call   800538 <cprintf>
  8000e1:	eb 0c                	jmp    8000ef <umain+0x92>
	else
		cprintf("init: bss seems okay\n");
  8000e3:	c7 04 24 66 2d 80 00 	movl   $0x802d66,(%esp)
  8000ea:	e8 49 04 00 00       	call   800538 <cprintf>

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
  8000ef:	c7 44 24 04 7c 2d 80 	movl   $0x802d7c,0x4(%esp)
  8000f6:	00 
  8000f7:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8000fd:	89 04 24             	mov    %eax,(%esp)
  800100:	e8 fb 09 00 00       	call   800b00 <strcat>
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
  800112:	c7 44 24 04 88 2d 80 	movl   $0x802d88,0x4(%esp)
  800119:	00 
  80011a:	89 34 24             	mov    %esi,(%esp)
  80011d:	e8 de 09 00 00       	call   800b00 <strcat>
		strcat(args, argv[i]);
  800122:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  800125:	89 44 24 04          	mov    %eax,0x4(%esp)
  800129:	89 34 24             	mov    %esi,(%esp)
  80012c:	e8 cf 09 00 00       	call   800b00 <strcat>
		strcat(args, "'");
  800131:	c7 44 24 04 89 2d 80 	movl   $0x802d89,0x4(%esp)
  800138:	00 
  800139:	89 34 24             	mov    %esi,(%esp)
  80013c:	e8 bf 09 00 00       	call   800b00 <strcat>
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
  800151:	c7 04 24 8b 2d 80 00 	movl   $0x802d8b,(%esp)
  800158:	e8 db 03 00 00       	call   800538 <cprintf>

	cprintf("init: running sh\n");
  80015d:	c7 04 24 8f 2d 80 00 	movl   $0x802d8f,(%esp)
  800164:	e8 cf 03 00 00       	call   800538 <cprintf>

	// being run directly from kernel, so no file descriptors open yet
	close(0);
  800169:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800170:	e8 01 12 00 00       	call   801376 <close>
	if ((r = opencons()) < 0)
  800175:	e8 16 02 00 00       	call   800390 <opencons>
  80017a:	85 c0                	test   %eax,%eax
  80017c:	79 20                	jns    80019e <umain+0x141>
		panic("opencons: %e", r);
  80017e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800182:	c7 44 24 08 a1 2d 80 	movl   $0x802da1,0x8(%esp)
  800189:	00 
  80018a:	c7 44 24 04 37 00 00 	movl   $0x37,0x4(%esp)
  800191:	00 
  800192:	c7 04 24 ae 2d 80 00 	movl   $0x802dae,(%esp)
  800199:	e8 a2 02 00 00       	call   800440 <_panic>
	if (r != 0)
  80019e:	85 c0                	test   %eax,%eax
  8001a0:	74 20                	je     8001c2 <umain+0x165>
		panic("first opencons used fd %d", r);
  8001a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001a6:	c7 44 24 08 ba 2d 80 	movl   $0x802dba,0x8(%esp)
  8001ad:	00 
  8001ae:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  8001b5:	00 
  8001b6:	c7 04 24 ae 2d 80 00 	movl   $0x802dae,(%esp)
  8001bd:	e8 7e 02 00 00       	call   800440 <_panic>
	if ((r = dup(0, 1)) < 0)
  8001c2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8001c9:	00 
  8001ca:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001d1:	e8 f1 11 00 00       	call   8013c7 <dup>
  8001d6:	85 c0                	test   %eax,%eax
  8001d8:	79 20                	jns    8001fa <umain+0x19d>
		panic("dup: %e", r);
  8001da:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001de:	c7 44 24 08 d4 2d 80 	movl   $0x802dd4,0x8(%esp)
  8001e5:	00 
  8001e6:	c7 44 24 04 3b 00 00 	movl   $0x3b,0x4(%esp)
  8001ed:	00 
  8001ee:	c7 04 24 ae 2d 80 00 	movl   $0x802dae,(%esp)
  8001f5:	e8 46 02 00 00       	call   800440 <_panic>
	while (1) {
		cprintf("init: starting sh\n");
  8001fa:	c7 04 24 dc 2d 80 00 	movl   $0x802ddc,(%esp)
  800201:	e8 32 03 00 00       	call   800538 <cprintf>
		r = spawnl("/sh", "sh", (char*)0);
  800206:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80020d:	00 
  80020e:	c7 44 24 04 f0 2d 80 	movl   $0x802df0,0x4(%esp)
  800215:	00 
  800216:	c7 04 24 ef 2d 80 00 	movl   $0x802def,(%esp)
  80021d:	e8 30 1e 00 00       	call   802052 <spawnl>
		if (r < 0) {
  800222:	85 c0                	test   %eax,%eax
  800224:	79 12                	jns    800238 <umain+0x1db>
			cprintf("init: spawn sh: %e\n", r);
  800226:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022a:	c7 04 24 f3 2d 80 00 	movl   $0x802df3,(%esp)
  800231:	e8 02 03 00 00       	call   800538 <cprintf>
			continue;
  800236:	eb c2                	jmp    8001fa <umain+0x19d>
		}
		wait(r);
  800238:	89 04 24             	mov    %eax,(%esp)
  80023b:	e8 f4 26 00 00       	call   802934 <wait>
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
  800254:	c7 44 24 04 73 2e 80 	movl   $0x802e73,0x4(%esp)
  80025b:	00 
  80025c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80025f:	89 04 24             	mov    %eax,(%esp)
  800262:	e8 7c 08 00 00       	call   800ae3 <strcpy>
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
  8002a4:	e8 b3 09 00 00       	call   800c5c <memmove>
		sys_cputs(buf, m);
  8002a9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002ad:	89 3c 24             	mov    %edi,(%esp)
  8002b0:	e8 53 0b 00 00       	call   800e08 <sys_cputs>
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
  8002d7:	e8 da 0b 00 00       	call   800eb6 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8002dc:	e8 45 0b 00 00       	call   800e26 <sys_cgetc>
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
  800324:	e8 df 0a 00 00       	call   800e08 <sys_cputs>
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
  800347:	e8 8e 11 00 00       	call   8014da <read>
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
  800374:	e8 c5 0e 00 00       	call   80123e <fd_lookup>
  800379:	85 c0                	test   %eax,%eax
  80037b:	78 11                	js     80038e <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80037d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800380:	8b 15 70 57 80 00    	mov    0x805770,%edx
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
  80039c:	e8 4a 0e 00 00       	call   8011eb <fd_alloc>
  8003a1:	85 c0                	test   %eax,%eax
  8003a3:	78 3c                	js     8003e1 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8003a5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8003ac:	00 
  8003ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8003b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8003bb:	e8 15 0b 00 00       	call   800ed5 <sys_page_alloc>
  8003c0:	85 c0                	test   %eax,%eax
  8003c2:	78 1d                	js     8003e1 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8003c4:	8b 15 70 57 80 00    	mov    0x805770,%edx
  8003ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8003cd:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8003cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8003d2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8003d9:	89 04 24             	mov    %eax,(%esp)
  8003dc:	e8 df 0d 00 00       	call   8011c0 <fd2num>
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
  8003f2:	e8 a0 0a 00 00       	call   800e97 <sys_getenvid>
  8003f7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8003fc:	c1 e0 07             	shl    $0x7,%eax
  8003ff:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800404:	a3 90 77 80 00       	mov    %eax,0x807790

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800409:	85 f6                	test   %esi,%esi
  80040b:	7e 07                	jle    800414 <libmain+0x30>
		binaryname = argv[0];
  80040d:	8b 03                	mov    (%ebx),%eax
  80040f:	a3 8c 57 80 00       	mov    %eax,0x80578c

	// call user main routine
	umain(argc, argv);
  800414:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800418:	89 34 24             	mov    %esi,(%esp)
  80041b:	e8 3d fc ff ff       	call   80005d <umain>

	// exit gracefully
	exit();
  800420:	e8 07 00 00 00       	call   80042c <exit>
}
  800425:	83 c4 10             	add    $0x10,%esp
  800428:	5b                   	pop    %ebx
  800429:	5e                   	pop    %esi
  80042a:	5d                   	pop    %ebp
  80042b:	c3                   	ret    

0080042c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80042c:	55                   	push   %ebp
  80042d:	89 e5                	mov    %esp,%ebp
  80042f:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  800432:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800439:	e8 07 0a 00 00       	call   800e45 <sys_env_destroy>
}
  80043e:	c9                   	leave  
  80043f:	c3                   	ret    

00800440 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800440:	55                   	push   %ebp
  800441:	89 e5                	mov    %esp,%ebp
  800443:	56                   	push   %esi
  800444:	53                   	push   %ebx
  800445:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800448:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80044b:	8b 1d 8c 57 80 00    	mov    0x80578c,%ebx
  800451:	e8 41 0a 00 00       	call   800e97 <sys_getenvid>
  800456:	8b 55 0c             	mov    0xc(%ebp),%edx
  800459:	89 54 24 10          	mov    %edx,0x10(%esp)
  80045d:	8b 55 08             	mov    0x8(%ebp),%edx
  800460:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800464:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800468:	89 44 24 04          	mov    %eax,0x4(%esp)
  80046c:	c7 04 24 8c 2e 80 00 	movl   $0x802e8c,(%esp)
  800473:	e8 c0 00 00 00       	call   800538 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800478:	89 74 24 04          	mov    %esi,0x4(%esp)
  80047c:	8b 45 10             	mov    0x10(%ebp),%eax
  80047f:	89 04 24             	mov    %eax,(%esp)
  800482:	e8 50 00 00 00       	call   8004d7 <vcprintf>
	cprintf("\n");
  800487:	c7 04 24 e8 33 80 00 	movl   $0x8033e8,(%esp)
  80048e:	e8 a5 00 00 00       	call   800538 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800493:	cc                   	int3   
  800494:	eb fd                	jmp    800493 <_panic+0x53>
	...

00800498 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800498:	55                   	push   %ebp
  800499:	89 e5                	mov    %esp,%ebp
  80049b:	53                   	push   %ebx
  80049c:	83 ec 14             	sub    $0x14,%esp
  80049f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8004a2:	8b 03                	mov    (%ebx),%eax
  8004a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8004a7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8004ab:	40                   	inc    %eax
  8004ac:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8004ae:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004b3:	75 19                	jne    8004ce <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8004b5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8004bc:	00 
  8004bd:	8d 43 08             	lea    0x8(%ebx),%eax
  8004c0:	89 04 24             	mov    %eax,(%esp)
  8004c3:	e8 40 09 00 00       	call   800e08 <sys_cputs>
		b->idx = 0;
  8004c8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8004ce:	ff 43 04             	incl   0x4(%ebx)
}
  8004d1:	83 c4 14             	add    $0x14,%esp
  8004d4:	5b                   	pop    %ebx
  8004d5:	5d                   	pop    %ebp
  8004d6:	c3                   	ret    

008004d7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004d7:	55                   	push   %ebp
  8004d8:	89 e5                	mov    %esp,%ebp
  8004da:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8004e0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004e7:	00 00 00 
	b.cnt = 0;
  8004ea:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004f1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004f7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fe:	89 44 24 08          	mov    %eax,0x8(%esp)
  800502:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800508:	89 44 24 04          	mov    %eax,0x4(%esp)
  80050c:	c7 04 24 98 04 80 00 	movl   $0x800498,(%esp)
  800513:	e8 82 01 00 00       	call   80069a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800518:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80051e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800522:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800528:	89 04 24             	mov    %eax,(%esp)
  80052b:	e8 d8 08 00 00       	call   800e08 <sys_cputs>

	return b.cnt;
}
  800530:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800536:	c9                   	leave  
  800537:	c3                   	ret    

00800538 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800538:	55                   	push   %ebp
  800539:	89 e5                	mov    %esp,%ebp
  80053b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80053e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800541:	89 44 24 04          	mov    %eax,0x4(%esp)
  800545:	8b 45 08             	mov    0x8(%ebp),%eax
  800548:	89 04 24             	mov    %eax,(%esp)
  80054b:	e8 87 ff ff ff       	call   8004d7 <vcprintf>
	va_end(ap);

	return cnt;
}
  800550:	c9                   	leave  
  800551:	c3                   	ret    
	...

00800554 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800554:	55                   	push   %ebp
  800555:	89 e5                	mov    %esp,%ebp
  800557:	57                   	push   %edi
  800558:	56                   	push   %esi
  800559:	53                   	push   %ebx
  80055a:	83 ec 3c             	sub    $0x3c,%esp
  80055d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800560:	89 d7                	mov    %edx,%edi
  800562:	8b 45 08             	mov    0x8(%ebp),%eax
  800565:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800568:	8b 45 0c             	mov    0xc(%ebp),%eax
  80056b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80056e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800571:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800574:	85 c0                	test   %eax,%eax
  800576:	75 08                	jne    800580 <printnum+0x2c>
  800578:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80057b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80057e:	77 57                	ja     8005d7 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800580:	89 74 24 10          	mov    %esi,0x10(%esp)
  800584:	4b                   	dec    %ebx
  800585:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800589:	8b 45 10             	mov    0x10(%ebp),%eax
  80058c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800590:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800594:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800598:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80059f:	00 
  8005a0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005a3:	89 04 24             	mov    %eax,(%esp)
  8005a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ad:	e8 36 25 00 00       	call   802ae8 <__udivdi3>
  8005b2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005b6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8005ba:	89 04 24             	mov    %eax,(%esp)
  8005bd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005c1:	89 fa                	mov    %edi,%edx
  8005c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005c6:	e8 89 ff ff ff       	call   800554 <printnum>
  8005cb:	eb 0f                	jmp    8005dc <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8005cd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005d1:	89 34 24             	mov    %esi,(%esp)
  8005d4:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005d7:	4b                   	dec    %ebx
  8005d8:	85 db                	test   %ebx,%ebx
  8005da:	7f f1                	jg     8005cd <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8005dc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005e0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8005e4:	8b 45 10             	mov    0x10(%ebp),%eax
  8005e7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005eb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005f2:	00 
  8005f3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005f6:	89 04 24             	mov    %eax,(%esp)
  8005f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800600:	e8 03 26 00 00       	call   802c08 <__umoddi3>
  800605:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800609:	0f be 80 af 2e 80 00 	movsbl 0x802eaf(%eax),%eax
  800610:	89 04 24             	mov    %eax,(%esp)
  800613:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800616:	83 c4 3c             	add    $0x3c,%esp
  800619:	5b                   	pop    %ebx
  80061a:	5e                   	pop    %esi
  80061b:	5f                   	pop    %edi
  80061c:	5d                   	pop    %ebp
  80061d:	c3                   	ret    

0080061e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80061e:	55                   	push   %ebp
  80061f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800621:	83 fa 01             	cmp    $0x1,%edx
  800624:	7e 0e                	jle    800634 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800626:	8b 10                	mov    (%eax),%edx
  800628:	8d 4a 08             	lea    0x8(%edx),%ecx
  80062b:	89 08                	mov    %ecx,(%eax)
  80062d:	8b 02                	mov    (%edx),%eax
  80062f:	8b 52 04             	mov    0x4(%edx),%edx
  800632:	eb 22                	jmp    800656 <getuint+0x38>
	else if (lflag)
  800634:	85 d2                	test   %edx,%edx
  800636:	74 10                	je     800648 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800638:	8b 10                	mov    (%eax),%edx
  80063a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80063d:	89 08                	mov    %ecx,(%eax)
  80063f:	8b 02                	mov    (%edx),%eax
  800641:	ba 00 00 00 00       	mov    $0x0,%edx
  800646:	eb 0e                	jmp    800656 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800648:	8b 10                	mov    (%eax),%edx
  80064a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80064d:	89 08                	mov    %ecx,(%eax)
  80064f:	8b 02                	mov    (%edx),%eax
  800651:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800656:	5d                   	pop    %ebp
  800657:	c3                   	ret    

00800658 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800658:	55                   	push   %ebp
  800659:	89 e5                	mov    %esp,%ebp
  80065b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80065e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800661:	8b 10                	mov    (%eax),%edx
  800663:	3b 50 04             	cmp    0x4(%eax),%edx
  800666:	73 08                	jae    800670 <sprintputch+0x18>
		*b->buf++ = ch;
  800668:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80066b:	88 0a                	mov    %cl,(%edx)
  80066d:	42                   	inc    %edx
  80066e:	89 10                	mov    %edx,(%eax)
}
  800670:	5d                   	pop    %ebp
  800671:	c3                   	ret    

00800672 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800672:	55                   	push   %ebp
  800673:	89 e5                	mov    %esp,%ebp
  800675:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800678:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80067b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80067f:	8b 45 10             	mov    0x10(%ebp),%eax
  800682:	89 44 24 08          	mov    %eax,0x8(%esp)
  800686:	8b 45 0c             	mov    0xc(%ebp),%eax
  800689:	89 44 24 04          	mov    %eax,0x4(%esp)
  80068d:	8b 45 08             	mov    0x8(%ebp),%eax
  800690:	89 04 24             	mov    %eax,(%esp)
  800693:	e8 02 00 00 00       	call   80069a <vprintfmt>
	va_end(ap);
}
  800698:	c9                   	leave  
  800699:	c3                   	ret    

0080069a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80069a:	55                   	push   %ebp
  80069b:	89 e5                	mov    %esp,%ebp
  80069d:	57                   	push   %edi
  80069e:	56                   	push   %esi
  80069f:	53                   	push   %ebx
  8006a0:	83 ec 4c             	sub    $0x4c,%esp
  8006a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006a6:	8b 75 10             	mov    0x10(%ebp),%esi
  8006a9:	eb 12                	jmp    8006bd <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006ab:	85 c0                	test   %eax,%eax
  8006ad:	0f 84 6b 03 00 00    	je     800a1e <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8006b3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b7:	89 04 24             	mov    %eax,(%esp)
  8006ba:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006bd:	0f b6 06             	movzbl (%esi),%eax
  8006c0:	46                   	inc    %esi
  8006c1:	83 f8 25             	cmp    $0x25,%eax
  8006c4:	75 e5                	jne    8006ab <vprintfmt+0x11>
  8006c6:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8006ca:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8006d1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8006d6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8006dd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006e2:	eb 26                	jmp    80070a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e4:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8006e7:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8006eb:	eb 1d                	jmp    80070a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ed:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8006f0:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8006f4:	eb 14                	jmp    80070a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8006f9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800700:	eb 08                	jmp    80070a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800702:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800705:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070a:	0f b6 06             	movzbl (%esi),%eax
  80070d:	8d 56 01             	lea    0x1(%esi),%edx
  800710:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800713:	8a 16                	mov    (%esi),%dl
  800715:	83 ea 23             	sub    $0x23,%edx
  800718:	80 fa 55             	cmp    $0x55,%dl
  80071b:	0f 87 e1 02 00 00    	ja     800a02 <vprintfmt+0x368>
  800721:	0f b6 d2             	movzbl %dl,%edx
  800724:	ff 24 95 00 30 80 00 	jmp    *0x803000(,%edx,4)
  80072b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80072e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800733:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800736:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80073a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80073d:	8d 50 d0             	lea    -0x30(%eax),%edx
  800740:	83 fa 09             	cmp    $0x9,%edx
  800743:	77 2a                	ja     80076f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800745:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800746:	eb eb                	jmp    800733 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800748:	8b 45 14             	mov    0x14(%ebp),%eax
  80074b:	8d 50 04             	lea    0x4(%eax),%edx
  80074e:	89 55 14             	mov    %edx,0x14(%ebp)
  800751:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800753:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800756:	eb 17                	jmp    80076f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800758:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80075c:	78 98                	js     8006f6 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80075e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800761:	eb a7                	jmp    80070a <vprintfmt+0x70>
  800763:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800766:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80076d:	eb 9b                	jmp    80070a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80076f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800773:	79 95                	jns    80070a <vprintfmt+0x70>
  800775:	eb 8b                	jmp    800702 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800777:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800778:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80077b:	eb 8d                	jmp    80070a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80077d:	8b 45 14             	mov    0x14(%ebp),%eax
  800780:	8d 50 04             	lea    0x4(%eax),%edx
  800783:	89 55 14             	mov    %edx,0x14(%ebp)
  800786:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80078a:	8b 00                	mov    (%eax),%eax
  80078c:	89 04 24             	mov    %eax,(%esp)
  80078f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800792:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800795:	e9 23 ff ff ff       	jmp    8006bd <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80079a:	8b 45 14             	mov    0x14(%ebp),%eax
  80079d:	8d 50 04             	lea    0x4(%eax),%edx
  8007a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a3:	8b 00                	mov    (%eax),%eax
  8007a5:	85 c0                	test   %eax,%eax
  8007a7:	79 02                	jns    8007ab <vprintfmt+0x111>
  8007a9:	f7 d8                	neg    %eax
  8007ab:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8007ad:	83 f8 11             	cmp    $0x11,%eax
  8007b0:	7f 0b                	jg     8007bd <vprintfmt+0x123>
  8007b2:	8b 04 85 60 31 80 00 	mov    0x803160(,%eax,4),%eax
  8007b9:	85 c0                	test   %eax,%eax
  8007bb:	75 23                	jne    8007e0 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8007bd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007c1:	c7 44 24 08 c7 2e 80 	movl   $0x802ec7,0x8(%esp)
  8007c8:	00 
  8007c9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d0:	89 04 24             	mov    %eax,(%esp)
  8007d3:	e8 9a fe ff ff       	call   800672 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d8:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8007db:	e9 dd fe ff ff       	jmp    8006bd <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8007e0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007e4:	c7 44 24 08 9d 32 80 	movl   $0x80329d,0x8(%esp)
  8007eb:	00 
  8007ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8007f3:	89 14 24             	mov    %edx,(%esp)
  8007f6:	e8 77 fe ff ff       	call   800672 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007fb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007fe:	e9 ba fe ff ff       	jmp    8006bd <vprintfmt+0x23>
  800803:	89 f9                	mov    %edi,%ecx
  800805:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800808:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80080b:	8b 45 14             	mov    0x14(%ebp),%eax
  80080e:	8d 50 04             	lea    0x4(%eax),%edx
  800811:	89 55 14             	mov    %edx,0x14(%ebp)
  800814:	8b 30                	mov    (%eax),%esi
  800816:	85 f6                	test   %esi,%esi
  800818:	75 05                	jne    80081f <vprintfmt+0x185>
				p = "(null)";
  80081a:	be c0 2e 80 00       	mov    $0x802ec0,%esi
			if (width > 0 && padc != '-')
  80081f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800823:	0f 8e 84 00 00 00    	jle    8008ad <vprintfmt+0x213>
  800829:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80082d:	74 7e                	je     8008ad <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80082f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800833:	89 34 24             	mov    %esi,(%esp)
  800836:	e8 8b 02 00 00       	call   800ac6 <strnlen>
  80083b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80083e:	29 c2                	sub    %eax,%edx
  800840:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800843:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800847:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80084a:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80084d:	89 de                	mov    %ebx,%esi
  80084f:	89 d3                	mov    %edx,%ebx
  800851:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800853:	eb 0b                	jmp    800860 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800855:	89 74 24 04          	mov    %esi,0x4(%esp)
  800859:	89 3c 24             	mov    %edi,(%esp)
  80085c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80085f:	4b                   	dec    %ebx
  800860:	85 db                	test   %ebx,%ebx
  800862:	7f f1                	jg     800855 <vprintfmt+0x1bb>
  800864:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800867:	89 f3                	mov    %esi,%ebx
  800869:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80086c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80086f:	85 c0                	test   %eax,%eax
  800871:	79 05                	jns    800878 <vprintfmt+0x1de>
  800873:	b8 00 00 00 00       	mov    $0x0,%eax
  800878:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80087b:	29 c2                	sub    %eax,%edx
  80087d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800880:	eb 2b                	jmp    8008ad <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800882:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800886:	74 18                	je     8008a0 <vprintfmt+0x206>
  800888:	8d 50 e0             	lea    -0x20(%eax),%edx
  80088b:	83 fa 5e             	cmp    $0x5e,%edx
  80088e:	76 10                	jbe    8008a0 <vprintfmt+0x206>
					putch('?', putdat);
  800890:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800894:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80089b:	ff 55 08             	call   *0x8(%ebp)
  80089e:	eb 0a                	jmp    8008aa <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8008a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008a4:	89 04 24             	mov    %eax,(%esp)
  8008a7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008aa:	ff 4d e4             	decl   -0x1c(%ebp)
  8008ad:	0f be 06             	movsbl (%esi),%eax
  8008b0:	46                   	inc    %esi
  8008b1:	85 c0                	test   %eax,%eax
  8008b3:	74 21                	je     8008d6 <vprintfmt+0x23c>
  8008b5:	85 ff                	test   %edi,%edi
  8008b7:	78 c9                	js     800882 <vprintfmt+0x1e8>
  8008b9:	4f                   	dec    %edi
  8008ba:	79 c6                	jns    800882 <vprintfmt+0x1e8>
  8008bc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008bf:	89 de                	mov    %ebx,%esi
  8008c1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8008c4:	eb 18                	jmp    8008de <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8008c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008ca:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8008d1:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8008d3:	4b                   	dec    %ebx
  8008d4:	eb 08                	jmp    8008de <vprintfmt+0x244>
  8008d6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008d9:	89 de                	mov    %ebx,%esi
  8008db:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8008de:	85 db                	test   %ebx,%ebx
  8008e0:	7f e4                	jg     8008c6 <vprintfmt+0x22c>
  8008e2:	89 7d 08             	mov    %edi,0x8(%ebp)
  8008e5:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008e7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008ea:	e9 ce fd ff ff       	jmp    8006bd <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008ef:	83 f9 01             	cmp    $0x1,%ecx
  8008f2:	7e 10                	jle    800904 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8008f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f7:	8d 50 08             	lea    0x8(%eax),%edx
  8008fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8008fd:	8b 30                	mov    (%eax),%esi
  8008ff:	8b 78 04             	mov    0x4(%eax),%edi
  800902:	eb 26                	jmp    80092a <vprintfmt+0x290>
	else if (lflag)
  800904:	85 c9                	test   %ecx,%ecx
  800906:	74 12                	je     80091a <vprintfmt+0x280>
		return va_arg(*ap, long);
  800908:	8b 45 14             	mov    0x14(%ebp),%eax
  80090b:	8d 50 04             	lea    0x4(%eax),%edx
  80090e:	89 55 14             	mov    %edx,0x14(%ebp)
  800911:	8b 30                	mov    (%eax),%esi
  800913:	89 f7                	mov    %esi,%edi
  800915:	c1 ff 1f             	sar    $0x1f,%edi
  800918:	eb 10                	jmp    80092a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80091a:	8b 45 14             	mov    0x14(%ebp),%eax
  80091d:	8d 50 04             	lea    0x4(%eax),%edx
  800920:	89 55 14             	mov    %edx,0x14(%ebp)
  800923:	8b 30                	mov    (%eax),%esi
  800925:	89 f7                	mov    %esi,%edi
  800927:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80092a:	85 ff                	test   %edi,%edi
  80092c:	78 0a                	js     800938 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80092e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800933:	e9 8c 00 00 00       	jmp    8009c4 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800938:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80093c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800943:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800946:	f7 de                	neg    %esi
  800948:	83 d7 00             	adc    $0x0,%edi
  80094b:	f7 df                	neg    %edi
			}
			base = 10;
  80094d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800952:	eb 70                	jmp    8009c4 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800954:	89 ca                	mov    %ecx,%edx
  800956:	8d 45 14             	lea    0x14(%ebp),%eax
  800959:	e8 c0 fc ff ff       	call   80061e <getuint>
  80095e:	89 c6                	mov    %eax,%esi
  800960:	89 d7                	mov    %edx,%edi
			base = 10;
  800962:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800967:	eb 5b                	jmp    8009c4 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  800969:	89 ca                	mov    %ecx,%edx
  80096b:	8d 45 14             	lea    0x14(%ebp),%eax
  80096e:	e8 ab fc ff ff       	call   80061e <getuint>
  800973:	89 c6                	mov    %eax,%esi
  800975:	89 d7                	mov    %edx,%edi
			base = 8;
  800977:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80097c:	eb 46                	jmp    8009c4 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  80097e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800982:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800989:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80098c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800990:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800997:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80099a:	8b 45 14             	mov    0x14(%ebp),%eax
  80099d:	8d 50 04             	lea    0x4(%eax),%edx
  8009a0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8009a3:	8b 30                	mov    (%eax),%esi
  8009a5:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8009aa:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8009af:	eb 13                	jmp    8009c4 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8009b1:	89 ca                	mov    %ecx,%edx
  8009b3:	8d 45 14             	lea    0x14(%ebp),%eax
  8009b6:	e8 63 fc ff ff       	call   80061e <getuint>
  8009bb:	89 c6                	mov    %eax,%esi
  8009bd:	89 d7                	mov    %edx,%edi
			base = 16;
  8009bf:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8009c4:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8009c8:	89 54 24 10          	mov    %edx,0x10(%esp)
  8009cc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8009cf:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8009d3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009d7:	89 34 24             	mov    %esi,(%esp)
  8009da:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009de:	89 da                	mov    %ebx,%edx
  8009e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e3:	e8 6c fb ff ff       	call   800554 <printnum>
			break;
  8009e8:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8009eb:	e9 cd fc ff ff       	jmp    8006bd <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8009f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009f4:	89 04 24             	mov    %eax,(%esp)
  8009f7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009fa:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8009fd:	e9 bb fc ff ff       	jmp    8006bd <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a02:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a06:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a0d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a10:	eb 01                	jmp    800a13 <vprintfmt+0x379>
  800a12:	4e                   	dec    %esi
  800a13:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800a17:	75 f9                	jne    800a12 <vprintfmt+0x378>
  800a19:	e9 9f fc ff ff       	jmp    8006bd <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800a1e:	83 c4 4c             	add    $0x4c,%esp
  800a21:	5b                   	pop    %ebx
  800a22:	5e                   	pop    %esi
  800a23:	5f                   	pop    %edi
  800a24:	5d                   	pop    %ebp
  800a25:	c3                   	ret    

00800a26 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	83 ec 28             	sub    $0x28,%esp
  800a2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a32:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a35:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a39:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a3c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a43:	85 c0                	test   %eax,%eax
  800a45:	74 30                	je     800a77 <vsnprintf+0x51>
  800a47:	85 d2                	test   %edx,%edx
  800a49:	7e 33                	jle    800a7e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a4b:	8b 45 14             	mov    0x14(%ebp),%eax
  800a4e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a52:	8b 45 10             	mov    0x10(%ebp),%eax
  800a55:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a59:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a5c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a60:	c7 04 24 58 06 80 00 	movl   $0x800658,(%esp)
  800a67:	e8 2e fc ff ff       	call   80069a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a6f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a75:	eb 0c                	jmp    800a83 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a77:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a7c:	eb 05                	jmp    800a83 <vsnprintf+0x5d>
  800a7e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a83:	c9                   	leave  
  800a84:	c3                   	ret    

00800a85 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a85:	55                   	push   %ebp
  800a86:	89 e5                	mov    %esp,%ebp
  800a88:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a8b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a8e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a92:	8b 45 10             	mov    0x10(%ebp),%eax
  800a95:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a99:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a9c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aa0:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa3:	89 04 24             	mov    %eax,(%esp)
  800aa6:	e8 7b ff ff ff       	call   800a26 <vsnprintf>
	va_end(ap);

	return rc;
}
  800aab:	c9                   	leave  
  800aac:	c3                   	ret    
  800aad:	00 00                	add    %al,(%eax)
	...

00800ab0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ab6:	b8 00 00 00 00       	mov    $0x0,%eax
  800abb:	eb 01                	jmp    800abe <strlen+0xe>
		n++;
  800abd:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800abe:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ac2:	75 f9                	jne    800abd <strlen+0xd>
		n++;
	return n;
}
  800ac4:	5d                   	pop    %ebp
  800ac5:	c3                   	ret    

00800ac6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ac6:	55                   	push   %ebp
  800ac7:	89 e5                	mov    %esp,%ebp
  800ac9:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800acc:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800acf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad4:	eb 01                	jmp    800ad7 <strnlen+0x11>
		n++;
  800ad6:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ad7:	39 d0                	cmp    %edx,%eax
  800ad9:	74 06                	je     800ae1 <strnlen+0x1b>
  800adb:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800adf:	75 f5                	jne    800ad6 <strnlen+0x10>
		n++;
	return n;
}
  800ae1:	5d                   	pop    %ebp
  800ae2:	c3                   	ret    

00800ae3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800ae3:	55                   	push   %ebp
  800ae4:	89 e5                	mov    %esp,%ebp
  800ae6:	53                   	push   %ebx
  800ae7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800aed:	ba 00 00 00 00       	mov    $0x0,%edx
  800af2:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800af5:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800af8:	42                   	inc    %edx
  800af9:	84 c9                	test   %cl,%cl
  800afb:	75 f5                	jne    800af2 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800afd:	5b                   	pop    %ebx
  800afe:	5d                   	pop    %ebp
  800aff:	c3                   	ret    

00800b00 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b00:	55                   	push   %ebp
  800b01:	89 e5                	mov    %esp,%ebp
  800b03:	53                   	push   %ebx
  800b04:	83 ec 08             	sub    $0x8,%esp
  800b07:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b0a:	89 1c 24             	mov    %ebx,(%esp)
  800b0d:	e8 9e ff ff ff       	call   800ab0 <strlen>
	strcpy(dst + len, src);
  800b12:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b15:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b19:	01 d8                	add    %ebx,%eax
  800b1b:	89 04 24             	mov    %eax,(%esp)
  800b1e:	e8 c0 ff ff ff       	call   800ae3 <strcpy>
	return dst;
}
  800b23:	89 d8                	mov    %ebx,%eax
  800b25:	83 c4 08             	add    $0x8,%esp
  800b28:	5b                   	pop    %ebx
  800b29:	5d                   	pop    %ebp
  800b2a:	c3                   	ret    

00800b2b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b2b:	55                   	push   %ebp
  800b2c:	89 e5                	mov    %esp,%ebp
  800b2e:	56                   	push   %esi
  800b2f:	53                   	push   %ebx
  800b30:	8b 45 08             	mov    0x8(%ebp),%eax
  800b33:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b36:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b39:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b3e:	eb 0c                	jmp    800b4c <strncpy+0x21>
		*dst++ = *src;
  800b40:	8a 1a                	mov    (%edx),%bl
  800b42:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b45:	80 3a 01             	cmpb   $0x1,(%edx)
  800b48:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b4b:	41                   	inc    %ecx
  800b4c:	39 f1                	cmp    %esi,%ecx
  800b4e:	75 f0                	jne    800b40 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b50:	5b                   	pop    %ebx
  800b51:	5e                   	pop    %esi
  800b52:	5d                   	pop    %ebp
  800b53:	c3                   	ret    

00800b54 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b54:	55                   	push   %ebp
  800b55:	89 e5                	mov    %esp,%ebp
  800b57:	56                   	push   %esi
  800b58:	53                   	push   %ebx
  800b59:	8b 75 08             	mov    0x8(%ebp),%esi
  800b5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b5f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b62:	85 d2                	test   %edx,%edx
  800b64:	75 0a                	jne    800b70 <strlcpy+0x1c>
  800b66:	89 f0                	mov    %esi,%eax
  800b68:	eb 1a                	jmp    800b84 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b6a:	88 18                	mov    %bl,(%eax)
  800b6c:	40                   	inc    %eax
  800b6d:	41                   	inc    %ecx
  800b6e:	eb 02                	jmp    800b72 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b70:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800b72:	4a                   	dec    %edx
  800b73:	74 0a                	je     800b7f <strlcpy+0x2b>
  800b75:	8a 19                	mov    (%ecx),%bl
  800b77:	84 db                	test   %bl,%bl
  800b79:	75 ef                	jne    800b6a <strlcpy+0x16>
  800b7b:	89 c2                	mov    %eax,%edx
  800b7d:	eb 02                	jmp    800b81 <strlcpy+0x2d>
  800b7f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800b81:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800b84:	29 f0                	sub    %esi,%eax
}
  800b86:	5b                   	pop    %ebx
  800b87:	5e                   	pop    %esi
  800b88:	5d                   	pop    %ebp
  800b89:	c3                   	ret    

00800b8a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b8a:	55                   	push   %ebp
  800b8b:	89 e5                	mov    %esp,%ebp
  800b8d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b90:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b93:	eb 02                	jmp    800b97 <strcmp+0xd>
		p++, q++;
  800b95:	41                   	inc    %ecx
  800b96:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b97:	8a 01                	mov    (%ecx),%al
  800b99:	84 c0                	test   %al,%al
  800b9b:	74 04                	je     800ba1 <strcmp+0x17>
  800b9d:	3a 02                	cmp    (%edx),%al
  800b9f:	74 f4                	je     800b95 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ba1:	0f b6 c0             	movzbl %al,%eax
  800ba4:	0f b6 12             	movzbl (%edx),%edx
  800ba7:	29 d0                	sub    %edx,%eax
}
  800ba9:	5d                   	pop    %ebp
  800baa:	c3                   	ret    

00800bab <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800bab:	55                   	push   %ebp
  800bac:	89 e5                	mov    %esp,%ebp
  800bae:	53                   	push   %ebx
  800baf:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800bb8:	eb 03                	jmp    800bbd <strncmp+0x12>
		n--, p++, q++;
  800bba:	4a                   	dec    %edx
  800bbb:	40                   	inc    %eax
  800bbc:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800bbd:	85 d2                	test   %edx,%edx
  800bbf:	74 14                	je     800bd5 <strncmp+0x2a>
  800bc1:	8a 18                	mov    (%eax),%bl
  800bc3:	84 db                	test   %bl,%bl
  800bc5:	74 04                	je     800bcb <strncmp+0x20>
  800bc7:	3a 19                	cmp    (%ecx),%bl
  800bc9:	74 ef                	je     800bba <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800bcb:	0f b6 00             	movzbl (%eax),%eax
  800bce:	0f b6 11             	movzbl (%ecx),%edx
  800bd1:	29 d0                	sub    %edx,%eax
  800bd3:	eb 05                	jmp    800bda <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800bd5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800bda:	5b                   	pop    %ebx
  800bdb:	5d                   	pop    %ebp
  800bdc:	c3                   	ret    

00800bdd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800bdd:	55                   	push   %ebp
  800bde:	89 e5                	mov    %esp,%ebp
  800be0:	8b 45 08             	mov    0x8(%ebp),%eax
  800be3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800be6:	eb 05                	jmp    800bed <strchr+0x10>
		if (*s == c)
  800be8:	38 ca                	cmp    %cl,%dl
  800bea:	74 0c                	je     800bf8 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800bec:	40                   	inc    %eax
  800bed:	8a 10                	mov    (%eax),%dl
  800bef:	84 d2                	test   %dl,%dl
  800bf1:	75 f5                	jne    800be8 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800bf3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bf8:	5d                   	pop    %ebp
  800bf9:	c3                   	ret    

00800bfa <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bfa:	55                   	push   %ebp
  800bfb:	89 e5                	mov    %esp,%ebp
  800bfd:	8b 45 08             	mov    0x8(%ebp),%eax
  800c00:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800c03:	eb 05                	jmp    800c0a <strfind+0x10>
		if (*s == c)
  800c05:	38 ca                	cmp    %cl,%dl
  800c07:	74 07                	je     800c10 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c09:	40                   	inc    %eax
  800c0a:	8a 10                	mov    (%eax),%dl
  800c0c:	84 d2                	test   %dl,%dl
  800c0e:	75 f5                	jne    800c05 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800c10:	5d                   	pop    %ebp
  800c11:	c3                   	ret    

00800c12 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	57                   	push   %edi
  800c16:	56                   	push   %esi
  800c17:	53                   	push   %ebx
  800c18:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c1e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c21:	85 c9                	test   %ecx,%ecx
  800c23:	74 30                	je     800c55 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c25:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c2b:	75 25                	jne    800c52 <memset+0x40>
  800c2d:	f6 c1 03             	test   $0x3,%cl
  800c30:	75 20                	jne    800c52 <memset+0x40>
		c &= 0xFF;
  800c32:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c35:	89 d3                	mov    %edx,%ebx
  800c37:	c1 e3 08             	shl    $0x8,%ebx
  800c3a:	89 d6                	mov    %edx,%esi
  800c3c:	c1 e6 18             	shl    $0x18,%esi
  800c3f:	89 d0                	mov    %edx,%eax
  800c41:	c1 e0 10             	shl    $0x10,%eax
  800c44:	09 f0                	or     %esi,%eax
  800c46:	09 d0                	or     %edx,%eax
  800c48:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c4a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800c4d:	fc                   	cld    
  800c4e:	f3 ab                	rep stos %eax,%es:(%edi)
  800c50:	eb 03                	jmp    800c55 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c52:	fc                   	cld    
  800c53:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c55:	89 f8                	mov    %edi,%eax
  800c57:	5b                   	pop    %ebx
  800c58:	5e                   	pop    %esi
  800c59:	5f                   	pop    %edi
  800c5a:	5d                   	pop    %ebp
  800c5b:	c3                   	ret    

00800c5c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c5c:	55                   	push   %ebp
  800c5d:	89 e5                	mov    %esp,%ebp
  800c5f:	57                   	push   %edi
  800c60:	56                   	push   %esi
  800c61:	8b 45 08             	mov    0x8(%ebp),%eax
  800c64:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c67:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c6a:	39 c6                	cmp    %eax,%esi
  800c6c:	73 34                	jae    800ca2 <memmove+0x46>
  800c6e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c71:	39 d0                	cmp    %edx,%eax
  800c73:	73 2d                	jae    800ca2 <memmove+0x46>
		s += n;
		d += n;
  800c75:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c78:	f6 c2 03             	test   $0x3,%dl
  800c7b:	75 1b                	jne    800c98 <memmove+0x3c>
  800c7d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c83:	75 13                	jne    800c98 <memmove+0x3c>
  800c85:	f6 c1 03             	test   $0x3,%cl
  800c88:	75 0e                	jne    800c98 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c8a:	83 ef 04             	sub    $0x4,%edi
  800c8d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c90:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c93:	fd                   	std    
  800c94:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c96:	eb 07                	jmp    800c9f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c98:	4f                   	dec    %edi
  800c99:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c9c:	fd                   	std    
  800c9d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c9f:	fc                   	cld    
  800ca0:	eb 20                	jmp    800cc2 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ca2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ca8:	75 13                	jne    800cbd <memmove+0x61>
  800caa:	a8 03                	test   $0x3,%al
  800cac:	75 0f                	jne    800cbd <memmove+0x61>
  800cae:	f6 c1 03             	test   $0x3,%cl
  800cb1:	75 0a                	jne    800cbd <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800cb3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800cb6:	89 c7                	mov    %eax,%edi
  800cb8:	fc                   	cld    
  800cb9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cbb:	eb 05                	jmp    800cc2 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800cbd:	89 c7                	mov    %eax,%edi
  800cbf:	fc                   	cld    
  800cc0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800cc2:	5e                   	pop    %esi
  800cc3:	5f                   	pop    %edi
  800cc4:	5d                   	pop    %ebp
  800cc5:	c3                   	ret    

00800cc6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800cc6:	55                   	push   %ebp
  800cc7:	89 e5                	mov    %esp,%ebp
  800cc9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ccc:	8b 45 10             	mov    0x10(%ebp),%eax
  800ccf:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cd3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cd6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cda:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdd:	89 04 24             	mov    %eax,(%esp)
  800ce0:	e8 77 ff ff ff       	call   800c5c <memmove>
}
  800ce5:	c9                   	leave  
  800ce6:	c3                   	ret    

00800ce7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	57                   	push   %edi
  800ceb:	56                   	push   %esi
  800cec:	53                   	push   %ebx
  800ced:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cf0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cf3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cf6:	ba 00 00 00 00       	mov    $0x0,%edx
  800cfb:	eb 16                	jmp    800d13 <memcmp+0x2c>
		if (*s1 != *s2)
  800cfd:	8a 04 17             	mov    (%edi,%edx,1),%al
  800d00:	42                   	inc    %edx
  800d01:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800d05:	38 c8                	cmp    %cl,%al
  800d07:	74 0a                	je     800d13 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800d09:	0f b6 c0             	movzbl %al,%eax
  800d0c:	0f b6 c9             	movzbl %cl,%ecx
  800d0f:	29 c8                	sub    %ecx,%eax
  800d11:	eb 09                	jmp    800d1c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d13:	39 da                	cmp    %ebx,%edx
  800d15:	75 e6                	jne    800cfd <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d17:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d1c:	5b                   	pop    %ebx
  800d1d:	5e                   	pop    %esi
  800d1e:	5f                   	pop    %edi
  800d1f:	5d                   	pop    %ebp
  800d20:	c3                   	ret    

00800d21 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d21:	55                   	push   %ebp
  800d22:	89 e5                	mov    %esp,%ebp
  800d24:	8b 45 08             	mov    0x8(%ebp),%eax
  800d27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800d2a:	89 c2                	mov    %eax,%edx
  800d2c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d2f:	eb 05                	jmp    800d36 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d31:	38 08                	cmp    %cl,(%eax)
  800d33:	74 05                	je     800d3a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d35:	40                   	inc    %eax
  800d36:	39 d0                	cmp    %edx,%eax
  800d38:	72 f7                	jb     800d31 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    

00800d3c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	57                   	push   %edi
  800d40:	56                   	push   %esi
  800d41:	53                   	push   %ebx
  800d42:	8b 55 08             	mov    0x8(%ebp),%edx
  800d45:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d48:	eb 01                	jmp    800d4b <strtol+0xf>
		s++;
  800d4a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d4b:	8a 02                	mov    (%edx),%al
  800d4d:	3c 20                	cmp    $0x20,%al
  800d4f:	74 f9                	je     800d4a <strtol+0xe>
  800d51:	3c 09                	cmp    $0x9,%al
  800d53:	74 f5                	je     800d4a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d55:	3c 2b                	cmp    $0x2b,%al
  800d57:	75 08                	jne    800d61 <strtol+0x25>
		s++;
  800d59:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d5a:	bf 00 00 00 00       	mov    $0x0,%edi
  800d5f:	eb 13                	jmp    800d74 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d61:	3c 2d                	cmp    $0x2d,%al
  800d63:	75 0a                	jne    800d6f <strtol+0x33>
		s++, neg = 1;
  800d65:	8d 52 01             	lea    0x1(%edx),%edx
  800d68:	bf 01 00 00 00       	mov    $0x1,%edi
  800d6d:	eb 05                	jmp    800d74 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d6f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d74:	85 db                	test   %ebx,%ebx
  800d76:	74 05                	je     800d7d <strtol+0x41>
  800d78:	83 fb 10             	cmp    $0x10,%ebx
  800d7b:	75 28                	jne    800da5 <strtol+0x69>
  800d7d:	8a 02                	mov    (%edx),%al
  800d7f:	3c 30                	cmp    $0x30,%al
  800d81:	75 10                	jne    800d93 <strtol+0x57>
  800d83:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d87:	75 0a                	jne    800d93 <strtol+0x57>
		s += 2, base = 16;
  800d89:	83 c2 02             	add    $0x2,%edx
  800d8c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d91:	eb 12                	jmp    800da5 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800d93:	85 db                	test   %ebx,%ebx
  800d95:	75 0e                	jne    800da5 <strtol+0x69>
  800d97:	3c 30                	cmp    $0x30,%al
  800d99:	75 05                	jne    800da0 <strtol+0x64>
		s++, base = 8;
  800d9b:	42                   	inc    %edx
  800d9c:	b3 08                	mov    $0x8,%bl
  800d9e:	eb 05                	jmp    800da5 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800da0:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800da5:	b8 00 00 00 00       	mov    $0x0,%eax
  800daa:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800dac:	8a 0a                	mov    (%edx),%cl
  800dae:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800db1:	80 fb 09             	cmp    $0x9,%bl
  800db4:	77 08                	ja     800dbe <strtol+0x82>
			dig = *s - '0';
  800db6:	0f be c9             	movsbl %cl,%ecx
  800db9:	83 e9 30             	sub    $0x30,%ecx
  800dbc:	eb 1e                	jmp    800ddc <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800dbe:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800dc1:	80 fb 19             	cmp    $0x19,%bl
  800dc4:	77 08                	ja     800dce <strtol+0x92>
			dig = *s - 'a' + 10;
  800dc6:	0f be c9             	movsbl %cl,%ecx
  800dc9:	83 e9 57             	sub    $0x57,%ecx
  800dcc:	eb 0e                	jmp    800ddc <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800dce:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800dd1:	80 fb 19             	cmp    $0x19,%bl
  800dd4:	77 12                	ja     800de8 <strtol+0xac>
			dig = *s - 'A' + 10;
  800dd6:	0f be c9             	movsbl %cl,%ecx
  800dd9:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ddc:	39 f1                	cmp    %esi,%ecx
  800dde:	7d 0c                	jge    800dec <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800de0:	42                   	inc    %edx
  800de1:	0f af c6             	imul   %esi,%eax
  800de4:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800de6:	eb c4                	jmp    800dac <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800de8:	89 c1                	mov    %eax,%ecx
  800dea:	eb 02                	jmp    800dee <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800dec:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800dee:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800df2:	74 05                	je     800df9 <strtol+0xbd>
		*endptr = (char *) s;
  800df4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800df7:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800df9:	85 ff                	test   %edi,%edi
  800dfb:	74 04                	je     800e01 <strtol+0xc5>
  800dfd:	89 c8                	mov    %ecx,%eax
  800dff:	f7 d8                	neg    %eax
}
  800e01:	5b                   	pop    %ebx
  800e02:	5e                   	pop    %esi
  800e03:	5f                   	pop    %edi
  800e04:	5d                   	pop    %ebp
  800e05:	c3                   	ret    
	...

00800e08 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e08:	55                   	push   %ebp
  800e09:	89 e5                	mov    %esp,%ebp
  800e0b:	57                   	push   %edi
  800e0c:	56                   	push   %esi
  800e0d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0e:	b8 00 00 00 00       	mov    $0x0,%eax
  800e13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e16:	8b 55 08             	mov    0x8(%ebp),%edx
  800e19:	89 c3                	mov    %eax,%ebx
  800e1b:	89 c7                	mov    %eax,%edi
  800e1d:	89 c6                	mov    %eax,%esi
  800e1f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e21:	5b                   	pop    %ebx
  800e22:	5e                   	pop    %esi
  800e23:	5f                   	pop    %edi
  800e24:	5d                   	pop    %ebp
  800e25:	c3                   	ret    

00800e26 <sys_cgetc>:

int
sys_cgetc(void)
{
  800e26:	55                   	push   %ebp
  800e27:	89 e5                	mov    %esp,%ebp
  800e29:	57                   	push   %edi
  800e2a:	56                   	push   %esi
  800e2b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2c:	ba 00 00 00 00       	mov    $0x0,%edx
  800e31:	b8 01 00 00 00       	mov    $0x1,%eax
  800e36:	89 d1                	mov    %edx,%ecx
  800e38:	89 d3                	mov    %edx,%ebx
  800e3a:	89 d7                	mov    %edx,%edi
  800e3c:	89 d6                	mov    %edx,%esi
  800e3e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e40:	5b                   	pop    %ebx
  800e41:	5e                   	pop    %esi
  800e42:	5f                   	pop    %edi
  800e43:	5d                   	pop    %ebp
  800e44:	c3                   	ret    

00800e45 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e45:	55                   	push   %ebp
  800e46:	89 e5                	mov    %esp,%ebp
  800e48:	57                   	push   %edi
  800e49:	56                   	push   %esi
  800e4a:	53                   	push   %ebx
  800e4b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e53:	b8 03 00 00 00       	mov    $0x3,%eax
  800e58:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5b:	89 cb                	mov    %ecx,%ebx
  800e5d:	89 cf                	mov    %ecx,%edi
  800e5f:	89 ce                	mov    %ecx,%esi
  800e61:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e63:	85 c0                	test   %eax,%eax
  800e65:	7e 28                	jle    800e8f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e67:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e6b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800e72:	00 
  800e73:	c7 44 24 08 c7 31 80 	movl   $0x8031c7,0x8(%esp)
  800e7a:	00 
  800e7b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e82:	00 
  800e83:	c7 04 24 e4 31 80 00 	movl   $0x8031e4,(%esp)
  800e8a:	e8 b1 f5 ff ff       	call   800440 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e8f:	83 c4 2c             	add    $0x2c,%esp
  800e92:	5b                   	pop    %ebx
  800e93:	5e                   	pop    %esi
  800e94:	5f                   	pop    %edi
  800e95:	5d                   	pop    %ebp
  800e96:	c3                   	ret    

00800e97 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e97:	55                   	push   %ebp
  800e98:	89 e5                	mov    %esp,%ebp
  800e9a:	57                   	push   %edi
  800e9b:	56                   	push   %esi
  800e9c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e9d:	ba 00 00 00 00       	mov    $0x0,%edx
  800ea2:	b8 02 00 00 00       	mov    $0x2,%eax
  800ea7:	89 d1                	mov    %edx,%ecx
  800ea9:	89 d3                	mov    %edx,%ebx
  800eab:	89 d7                	mov    %edx,%edi
  800ead:	89 d6                	mov    %edx,%esi
  800eaf:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800eb1:	5b                   	pop    %ebx
  800eb2:	5e                   	pop    %esi
  800eb3:	5f                   	pop    %edi
  800eb4:	5d                   	pop    %ebp
  800eb5:	c3                   	ret    

00800eb6 <sys_yield>:

void
sys_yield(void)
{
  800eb6:	55                   	push   %ebp
  800eb7:	89 e5                	mov    %esp,%ebp
  800eb9:	57                   	push   %edi
  800eba:	56                   	push   %esi
  800ebb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ebc:	ba 00 00 00 00       	mov    $0x0,%edx
  800ec1:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ec6:	89 d1                	mov    %edx,%ecx
  800ec8:	89 d3                	mov    %edx,%ebx
  800eca:	89 d7                	mov    %edx,%edi
  800ecc:	89 d6                	mov    %edx,%esi
  800ece:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ed0:	5b                   	pop    %ebx
  800ed1:	5e                   	pop    %esi
  800ed2:	5f                   	pop    %edi
  800ed3:	5d                   	pop    %ebp
  800ed4:	c3                   	ret    

00800ed5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ed5:	55                   	push   %ebp
  800ed6:	89 e5                	mov    %esp,%ebp
  800ed8:	57                   	push   %edi
  800ed9:	56                   	push   %esi
  800eda:	53                   	push   %ebx
  800edb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ede:	be 00 00 00 00       	mov    $0x0,%esi
  800ee3:	b8 04 00 00 00       	mov    $0x4,%eax
  800ee8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eeb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eee:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef1:	89 f7                	mov    %esi,%edi
  800ef3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ef5:	85 c0                	test   %eax,%eax
  800ef7:	7e 28                	jle    800f21 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ef9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800efd:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800f04:	00 
  800f05:	c7 44 24 08 c7 31 80 	movl   $0x8031c7,0x8(%esp)
  800f0c:	00 
  800f0d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f14:	00 
  800f15:	c7 04 24 e4 31 80 00 	movl   $0x8031e4,(%esp)
  800f1c:	e8 1f f5 ff ff       	call   800440 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f21:	83 c4 2c             	add    $0x2c,%esp
  800f24:	5b                   	pop    %ebx
  800f25:	5e                   	pop    %esi
  800f26:	5f                   	pop    %edi
  800f27:	5d                   	pop    %ebp
  800f28:	c3                   	ret    

00800f29 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f29:	55                   	push   %ebp
  800f2a:	89 e5                	mov    %esp,%ebp
  800f2c:	57                   	push   %edi
  800f2d:	56                   	push   %esi
  800f2e:	53                   	push   %ebx
  800f2f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f32:	b8 05 00 00 00       	mov    $0x5,%eax
  800f37:	8b 75 18             	mov    0x18(%ebp),%esi
  800f3a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f3d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f43:	8b 55 08             	mov    0x8(%ebp),%edx
  800f46:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f48:	85 c0                	test   %eax,%eax
  800f4a:	7e 28                	jle    800f74 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f4c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f50:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f57:	00 
  800f58:	c7 44 24 08 c7 31 80 	movl   $0x8031c7,0x8(%esp)
  800f5f:	00 
  800f60:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f67:	00 
  800f68:	c7 04 24 e4 31 80 00 	movl   $0x8031e4,(%esp)
  800f6f:	e8 cc f4 ff ff       	call   800440 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f74:	83 c4 2c             	add    $0x2c,%esp
  800f77:	5b                   	pop    %ebx
  800f78:	5e                   	pop    %esi
  800f79:	5f                   	pop    %edi
  800f7a:	5d                   	pop    %ebp
  800f7b:	c3                   	ret    

00800f7c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f7c:	55                   	push   %ebp
  800f7d:	89 e5                	mov    %esp,%ebp
  800f7f:	57                   	push   %edi
  800f80:	56                   	push   %esi
  800f81:	53                   	push   %ebx
  800f82:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f85:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f8a:	b8 06 00 00 00       	mov    $0x6,%eax
  800f8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f92:	8b 55 08             	mov    0x8(%ebp),%edx
  800f95:	89 df                	mov    %ebx,%edi
  800f97:	89 de                	mov    %ebx,%esi
  800f99:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f9b:	85 c0                	test   %eax,%eax
  800f9d:	7e 28                	jle    800fc7 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f9f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fa3:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800faa:	00 
  800fab:	c7 44 24 08 c7 31 80 	movl   $0x8031c7,0x8(%esp)
  800fb2:	00 
  800fb3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fba:	00 
  800fbb:	c7 04 24 e4 31 80 00 	movl   $0x8031e4,(%esp)
  800fc2:	e8 79 f4 ff ff       	call   800440 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800fc7:	83 c4 2c             	add    $0x2c,%esp
  800fca:	5b                   	pop    %ebx
  800fcb:	5e                   	pop    %esi
  800fcc:	5f                   	pop    %edi
  800fcd:	5d                   	pop    %ebp
  800fce:	c3                   	ret    

00800fcf <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800fd8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fdd:	b8 08 00 00 00       	mov    $0x8,%eax
  800fe2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe5:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe8:	89 df                	mov    %ebx,%edi
  800fea:	89 de                	mov    %ebx,%esi
  800fec:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fee:	85 c0                	test   %eax,%eax
  800ff0:	7e 28                	jle    80101a <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ff2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ff6:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800ffd:	00 
  800ffe:	c7 44 24 08 c7 31 80 	movl   $0x8031c7,0x8(%esp)
  801005:	00 
  801006:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80100d:	00 
  80100e:	c7 04 24 e4 31 80 00 	movl   $0x8031e4,(%esp)
  801015:	e8 26 f4 ff ff       	call   800440 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80101a:	83 c4 2c             	add    $0x2c,%esp
  80101d:	5b                   	pop    %ebx
  80101e:	5e                   	pop    %esi
  80101f:	5f                   	pop    %edi
  801020:	5d                   	pop    %ebp
  801021:	c3                   	ret    

00801022 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801022:	55                   	push   %ebp
  801023:	89 e5                	mov    %esp,%ebp
  801025:	57                   	push   %edi
  801026:	56                   	push   %esi
  801027:	53                   	push   %ebx
  801028:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80102b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801030:	b8 09 00 00 00       	mov    $0x9,%eax
  801035:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801038:	8b 55 08             	mov    0x8(%ebp),%edx
  80103b:	89 df                	mov    %ebx,%edi
  80103d:	89 de                	mov    %ebx,%esi
  80103f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801041:	85 c0                	test   %eax,%eax
  801043:	7e 28                	jle    80106d <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801045:	89 44 24 10          	mov    %eax,0x10(%esp)
  801049:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801050:	00 
  801051:	c7 44 24 08 c7 31 80 	movl   $0x8031c7,0x8(%esp)
  801058:	00 
  801059:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801060:	00 
  801061:	c7 04 24 e4 31 80 00 	movl   $0x8031e4,(%esp)
  801068:	e8 d3 f3 ff ff       	call   800440 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80106d:	83 c4 2c             	add    $0x2c,%esp
  801070:	5b                   	pop    %ebx
  801071:	5e                   	pop    %esi
  801072:	5f                   	pop    %edi
  801073:	5d                   	pop    %ebp
  801074:	c3                   	ret    

00801075 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801075:	55                   	push   %ebp
  801076:	89 e5                	mov    %esp,%ebp
  801078:	57                   	push   %edi
  801079:	56                   	push   %esi
  80107a:	53                   	push   %ebx
  80107b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80107e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801083:	b8 0a 00 00 00       	mov    $0xa,%eax
  801088:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80108b:	8b 55 08             	mov    0x8(%ebp),%edx
  80108e:	89 df                	mov    %ebx,%edi
  801090:	89 de                	mov    %ebx,%esi
  801092:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801094:	85 c0                	test   %eax,%eax
  801096:	7e 28                	jle    8010c0 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801098:	89 44 24 10          	mov    %eax,0x10(%esp)
  80109c:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8010a3:	00 
  8010a4:	c7 44 24 08 c7 31 80 	movl   $0x8031c7,0x8(%esp)
  8010ab:	00 
  8010ac:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010b3:	00 
  8010b4:	c7 04 24 e4 31 80 00 	movl   $0x8031e4,(%esp)
  8010bb:	e8 80 f3 ff ff       	call   800440 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010c0:	83 c4 2c             	add    $0x2c,%esp
  8010c3:	5b                   	pop    %ebx
  8010c4:	5e                   	pop    %esi
  8010c5:	5f                   	pop    %edi
  8010c6:	5d                   	pop    %ebp
  8010c7:	c3                   	ret    

008010c8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010c8:	55                   	push   %ebp
  8010c9:	89 e5                	mov    %esp,%ebp
  8010cb:	57                   	push   %edi
  8010cc:	56                   	push   %esi
  8010cd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ce:	be 00 00 00 00       	mov    $0x0,%esi
  8010d3:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010d8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010db:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8010e4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010e6:	5b                   	pop    %ebx
  8010e7:	5e                   	pop    %esi
  8010e8:	5f                   	pop    %edi
  8010e9:	5d                   	pop    %ebp
  8010ea:	c3                   	ret    

008010eb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010eb:	55                   	push   %ebp
  8010ec:	89 e5                	mov    %esp,%ebp
  8010ee:	57                   	push   %edi
  8010ef:	56                   	push   %esi
  8010f0:	53                   	push   %ebx
  8010f1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010f9:	b8 0d 00 00 00       	mov    $0xd,%eax
  8010fe:	8b 55 08             	mov    0x8(%ebp),%edx
  801101:	89 cb                	mov    %ecx,%ebx
  801103:	89 cf                	mov    %ecx,%edi
  801105:	89 ce                	mov    %ecx,%esi
  801107:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801109:	85 c0                	test   %eax,%eax
  80110b:	7e 28                	jle    801135 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80110d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801111:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801118:	00 
  801119:	c7 44 24 08 c7 31 80 	movl   $0x8031c7,0x8(%esp)
  801120:	00 
  801121:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801128:	00 
  801129:	c7 04 24 e4 31 80 00 	movl   $0x8031e4,(%esp)
  801130:	e8 0b f3 ff ff       	call   800440 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801135:	83 c4 2c             	add    $0x2c,%esp
  801138:	5b                   	pop    %ebx
  801139:	5e                   	pop    %esi
  80113a:	5f                   	pop    %edi
  80113b:	5d                   	pop    %ebp
  80113c:	c3                   	ret    

0080113d <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80113d:	55                   	push   %ebp
  80113e:	89 e5                	mov    %esp,%ebp
  801140:	57                   	push   %edi
  801141:	56                   	push   %esi
  801142:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801143:	ba 00 00 00 00       	mov    $0x0,%edx
  801148:	b8 0e 00 00 00       	mov    $0xe,%eax
  80114d:	89 d1                	mov    %edx,%ecx
  80114f:	89 d3                	mov    %edx,%ebx
  801151:	89 d7                	mov    %edx,%edi
  801153:	89 d6                	mov    %edx,%esi
  801155:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801157:	5b                   	pop    %ebx
  801158:	5e                   	pop    %esi
  801159:	5f                   	pop    %edi
  80115a:	5d                   	pop    %ebp
  80115b:	c3                   	ret    

0080115c <sys_e1000_transmit>:

int 
sys_e1000_transmit(char* pck, size_t length){
  80115c:	55                   	push   %ebp
  80115d:	89 e5                	mov    %esp,%ebp
  80115f:	57                   	push   %edi
  801160:	56                   	push   %esi
  801161:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801162:	bb 00 00 00 00       	mov    $0x0,%ebx
  801167:	b8 10 00 00 00       	mov    $0x10,%eax
  80116c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80116f:	8b 55 08             	mov    0x8(%ebp),%edx
  801172:	89 df                	mov    %ebx,%edi
  801174:	89 de                	mov    %ebx,%esi
  801176:	cd 30                	int    $0x30
}

int 
sys_e1000_transmit(char* pck, size_t length){
	return syscall(SYS_e1000_transmit, 0, (uint32_t)pck, length, 0, 0, 0);
}
  801178:	5b                   	pop    %ebx
  801179:	5e                   	pop    %esi
  80117a:	5f                   	pop    %edi
  80117b:	5d                   	pop    %ebp
  80117c:	c3                   	ret    

0080117d <sys_e1000_receive>:

int 
sys_e1000_receive(char* pck, size_t* length){
  80117d:	55                   	push   %ebp
  80117e:	89 e5                	mov    %esp,%ebp
  801180:	57                   	push   %edi
  801181:	56                   	push   %esi
  801182:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801183:	bb 00 00 00 00       	mov    $0x0,%ebx
  801188:	b8 0f 00 00 00       	mov    $0xf,%eax
  80118d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801190:	8b 55 08             	mov    0x8(%ebp),%edx
  801193:	89 df                	mov    %ebx,%edi
  801195:	89 de                	mov    %ebx,%esi
  801197:	cd 30                	int    $0x30
}

int 
sys_e1000_receive(char* pck, size_t* length){
	return syscall(SYS_e1000_receive, 0, (uint32_t)pck, (uint32_t)length, 0, 0, 0);
}
  801199:	5b                   	pop    %ebx
  80119a:	5e                   	pop    %esi
  80119b:	5f                   	pop    %edi
  80119c:	5d                   	pop    %ebp
  80119d:	c3                   	ret    

0080119e <sys_e1000_get_mac>:

int 
sys_e1000_get_mac(uint8_t* mac_addr){
  80119e:	55                   	push   %ebp
  80119f:	89 e5                	mov    %esp,%ebp
  8011a1:	57                   	push   %edi
  8011a2:	56                   	push   %esi
  8011a3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011a4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011a9:	b8 11 00 00 00       	mov    $0x11,%eax
  8011ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8011b1:	89 cb                	mov    %ecx,%ebx
  8011b3:	89 cf                	mov    %ecx,%edi
  8011b5:	89 ce                	mov    %ecx,%esi
  8011b7:	cd 30                	int    $0x30
}

int 
sys_e1000_get_mac(uint8_t* mac_addr){
	return syscall(SYS_e1000_get_mac, 0, (uint32_t)mac_addr, 0, 0, 0, 0);
}
  8011b9:	5b                   	pop    %ebx
  8011ba:	5e                   	pop    %esi
  8011bb:	5f                   	pop    %edi
  8011bc:	5d                   	pop    %ebp
  8011bd:	c3                   	ret    
	...

008011c0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011c0:	55                   	push   %ebp
  8011c1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c6:	05 00 00 00 30       	add    $0x30000000,%eax
  8011cb:	c1 e8 0c             	shr    $0xc,%eax
}
  8011ce:	5d                   	pop    %ebp
  8011cf:	c3                   	ret    

008011d0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011d0:	55                   	push   %ebp
  8011d1:	89 e5                	mov    %esp,%ebp
  8011d3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8011d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d9:	89 04 24             	mov    %eax,(%esp)
  8011dc:	e8 df ff ff ff       	call   8011c0 <fd2num>
  8011e1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8011e6:	c1 e0 0c             	shl    $0xc,%eax
}
  8011e9:	c9                   	leave  
  8011ea:	c3                   	ret    

008011eb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011eb:	55                   	push   %ebp
  8011ec:	89 e5                	mov    %esp,%ebp
  8011ee:	53                   	push   %ebx
  8011ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8011f2:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8011f7:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011f9:	89 c2                	mov    %eax,%edx
  8011fb:	c1 ea 16             	shr    $0x16,%edx
  8011fe:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801205:	f6 c2 01             	test   $0x1,%dl
  801208:	74 11                	je     80121b <fd_alloc+0x30>
  80120a:	89 c2                	mov    %eax,%edx
  80120c:	c1 ea 0c             	shr    $0xc,%edx
  80120f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801216:	f6 c2 01             	test   $0x1,%dl
  801219:	75 09                	jne    801224 <fd_alloc+0x39>
			*fd_store = fd;
  80121b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80121d:	b8 00 00 00 00       	mov    $0x0,%eax
  801222:	eb 17                	jmp    80123b <fd_alloc+0x50>
  801224:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801229:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80122e:	75 c7                	jne    8011f7 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801230:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801236:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80123b:	5b                   	pop    %ebx
  80123c:	5d                   	pop    %ebp
  80123d:	c3                   	ret    

0080123e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80123e:	55                   	push   %ebp
  80123f:	89 e5                	mov    %esp,%ebp
  801241:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801244:	83 f8 1f             	cmp    $0x1f,%eax
  801247:	77 36                	ja     80127f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801249:	05 00 00 0d 00       	add    $0xd0000,%eax
  80124e:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801251:	89 c2                	mov    %eax,%edx
  801253:	c1 ea 16             	shr    $0x16,%edx
  801256:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80125d:	f6 c2 01             	test   $0x1,%dl
  801260:	74 24                	je     801286 <fd_lookup+0x48>
  801262:	89 c2                	mov    %eax,%edx
  801264:	c1 ea 0c             	shr    $0xc,%edx
  801267:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80126e:	f6 c2 01             	test   $0x1,%dl
  801271:	74 1a                	je     80128d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801273:	8b 55 0c             	mov    0xc(%ebp),%edx
  801276:	89 02                	mov    %eax,(%edx)
	return 0;
  801278:	b8 00 00 00 00       	mov    $0x0,%eax
  80127d:	eb 13                	jmp    801292 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80127f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801284:	eb 0c                	jmp    801292 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801286:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80128b:	eb 05                	jmp    801292 <fd_lookup+0x54>
  80128d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801292:	5d                   	pop    %ebp
  801293:	c3                   	ret    

00801294 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801294:	55                   	push   %ebp
  801295:	89 e5                	mov    %esp,%ebp
  801297:	53                   	push   %ebx
  801298:	83 ec 14             	sub    $0x14,%esp
  80129b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80129e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8012a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8012a6:	eb 0e                	jmp    8012b6 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8012a8:	39 08                	cmp    %ecx,(%eax)
  8012aa:	75 09                	jne    8012b5 <dev_lookup+0x21>
			*dev = devtab[i];
  8012ac:	89 03                	mov    %eax,(%ebx)
			return 0;
  8012ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8012b3:	eb 33                	jmp    8012e8 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012b5:	42                   	inc    %edx
  8012b6:	8b 04 95 70 32 80 00 	mov    0x803270(,%edx,4),%eax
  8012bd:	85 c0                	test   %eax,%eax
  8012bf:	75 e7                	jne    8012a8 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012c1:	a1 90 77 80 00       	mov    0x807790,%eax
  8012c6:	8b 40 48             	mov    0x48(%eax),%eax
  8012c9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012d1:	c7 04 24 f4 31 80 00 	movl   $0x8031f4,(%esp)
  8012d8:	e8 5b f2 ff ff       	call   800538 <cprintf>
	*dev = 0;
  8012dd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8012e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012e8:	83 c4 14             	add    $0x14,%esp
  8012eb:	5b                   	pop    %ebx
  8012ec:	5d                   	pop    %ebp
  8012ed:	c3                   	ret    

008012ee <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012ee:	55                   	push   %ebp
  8012ef:	89 e5                	mov    %esp,%ebp
  8012f1:	56                   	push   %esi
  8012f2:	53                   	push   %ebx
  8012f3:	83 ec 30             	sub    $0x30,%esp
  8012f6:	8b 75 08             	mov    0x8(%ebp),%esi
  8012f9:	8a 45 0c             	mov    0xc(%ebp),%al
  8012fc:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012ff:	89 34 24             	mov    %esi,(%esp)
  801302:	e8 b9 fe ff ff       	call   8011c0 <fd2num>
  801307:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80130a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80130e:	89 04 24             	mov    %eax,(%esp)
  801311:	e8 28 ff ff ff       	call   80123e <fd_lookup>
  801316:	89 c3                	mov    %eax,%ebx
  801318:	85 c0                	test   %eax,%eax
  80131a:	78 05                	js     801321 <fd_close+0x33>
	    || fd != fd2)
  80131c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80131f:	74 0d                	je     80132e <fd_close+0x40>
		return (must_exist ? r : 0);
  801321:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801325:	75 46                	jne    80136d <fd_close+0x7f>
  801327:	bb 00 00 00 00       	mov    $0x0,%ebx
  80132c:	eb 3f                	jmp    80136d <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80132e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801331:	89 44 24 04          	mov    %eax,0x4(%esp)
  801335:	8b 06                	mov    (%esi),%eax
  801337:	89 04 24             	mov    %eax,(%esp)
  80133a:	e8 55 ff ff ff       	call   801294 <dev_lookup>
  80133f:	89 c3                	mov    %eax,%ebx
  801341:	85 c0                	test   %eax,%eax
  801343:	78 18                	js     80135d <fd_close+0x6f>
		if (dev->dev_close)
  801345:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801348:	8b 40 10             	mov    0x10(%eax),%eax
  80134b:	85 c0                	test   %eax,%eax
  80134d:	74 09                	je     801358 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80134f:	89 34 24             	mov    %esi,(%esp)
  801352:	ff d0                	call   *%eax
  801354:	89 c3                	mov    %eax,%ebx
  801356:	eb 05                	jmp    80135d <fd_close+0x6f>
		else
			r = 0;
  801358:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80135d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801361:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801368:	e8 0f fc ff ff       	call   800f7c <sys_page_unmap>
	return r;
}
  80136d:	89 d8                	mov    %ebx,%eax
  80136f:	83 c4 30             	add    $0x30,%esp
  801372:	5b                   	pop    %ebx
  801373:	5e                   	pop    %esi
  801374:	5d                   	pop    %ebp
  801375:	c3                   	ret    

00801376 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801376:	55                   	push   %ebp
  801377:	89 e5                	mov    %esp,%ebp
  801379:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80137c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80137f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801383:	8b 45 08             	mov    0x8(%ebp),%eax
  801386:	89 04 24             	mov    %eax,(%esp)
  801389:	e8 b0 fe ff ff       	call   80123e <fd_lookup>
  80138e:	85 c0                	test   %eax,%eax
  801390:	78 13                	js     8013a5 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801392:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801399:	00 
  80139a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80139d:	89 04 24             	mov    %eax,(%esp)
  8013a0:	e8 49 ff ff ff       	call   8012ee <fd_close>
}
  8013a5:	c9                   	leave  
  8013a6:	c3                   	ret    

008013a7 <close_all>:

void
close_all(void)
{
  8013a7:	55                   	push   %ebp
  8013a8:	89 e5                	mov    %esp,%ebp
  8013aa:	53                   	push   %ebx
  8013ab:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013ae:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013b3:	89 1c 24             	mov    %ebx,(%esp)
  8013b6:	e8 bb ff ff ff       	call   801376 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013bb:	43                   	inc    %ebx
  8013bc:	83 fb 20             	cmp    $0x20,%ebx
  8013bf:	75 f2                	jne    8013b3 <close_all+0xc>
		close(i);
}
  8013c1:	83 c4 14             	add    $0x14,%esp
  8013c4:	5b                   	pop    %ebx
  8013c5:	5d                   	pop    %ebp
  8013c6:	c3                   	ret    

008013c7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013c7:	55                   	push   %ebp
  8013c8:	89 e5                	mov    %esp,%ebp
  8013ca:	57                   	push   %edi
  8013cb:	56                   	push   %esi
  8013cc:	53                   	push   %ebx
  8013cd:	83 ec 4c             	sub    $0x4c,%esp
  8013d0:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013d3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013da:	8b 45 08             	mov    0x8(%ebp),%eax
  8013dd:	89 04 24             	mov    %eax,(%esp)
  8013e0:	e8 59 fe ff ff       	call   80123e <fd_lookup>
  8013e5:	89 c3                	mov    %eax,%ebx
  8013e7:	85 c0                	test   %eax,%eax
  8013e9:	0f 88 e1 00 00 00    	js     8014d0 <dup+0x109>
		return r;
	close(newfdnum);
  8013ef:	89 3c 24             	mov    %edi,(%esp)
  8013f2:	e8 7f ff ff ff       	call   801376 <close>

	newfd = INDEX2FD(newfdnum);
  8013f7:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8013fd:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801400:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801403:	89 04 24             	mov    %eax,(%esp)
  801406:	e8 c5 fd ff ff       	call   8011d0 <fd2data>
  80140b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80140d:	89 34 24             	mov    %esi,(%esp)
  801410:	e8 bb fd ff ff       	call   8011d0 <fd2data>
  801415:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801418:	89 d8                	mov    %ebx,%eax
  80141a:	c1 e8 16             	shr    $0x16,%eax
  80141d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801424:	a8 01                	test   $0x1,%al
  801426:	74 46                	je     80146e <dup+0xa7>
  801428:	89 d8                	mov    %ebx,%eax
  80142a:	c1 e8 0c             	shr    $0xc,%eax
  80142d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801434:	f6 c2 01             	test   $0x1,%dl
  801437:	74 35                	je     80146e <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801439:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801440:	25 07 0e 00 00       	and    $0xe07,%eax
  801445:	89 44 24 10          	mov    %eax,0x10(%esp)
  801449:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80144c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801450:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801457:	00 
  801458:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80145c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801463:	e8 c1 fa ff ff       	call   800f29 <sys_page_map>
  801468:	89 c3                	mov    %eax,%ebx
  80146a:	85 c0                	test   %eax,%eax
  80146c:	78 3b                	js     8014a9 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80146e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801471:	89 c2                	mov    %eax,%edx
  801473:	c1 ea 0c             	shr    $0xc,%edx
  801476:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80147d:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801483:	89 54 24 10          	mov    %edx,0x10(%esp)
  801487:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80148b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801492:	00 
  801493:	89 44 24 04          	mov    %eax,0x4(%esp)
  801497:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80149e:	e8 86 fa ff ff       	call   800f29 <sys_page_map>
  8014a3:	89 c3                	mov    %eax,%ebx
  8014a5:	85 c0                	test   %eax,%eax
  8014a7:	79 25                	jns    8014ce <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014a9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014ad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014b4:	e8 c3 fa ff ff       	call   800f7c <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014b9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8014bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014c7:	e8 b0 fa ff ff       	call   800f7c <sys_page_unmap>
	return r;
  8014cc:	eb 02                	jmp    8014d0 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8014ce:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8014d0:	89 d8                	mov    %ebx,%eax
  8014d2:	83 c4 4c             	add    $0x4c,%esp
  8014d5:	5b                   	pop    %ebx
  8014d6:	5e                   	pop    %esi
  8014d7:	5f                   	pop    %edi
  8014d8:	5d                   	pop    %ebp
  8014d9:	c3                   	ret    

008014da <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014da:	55                   	push   %ebp
  8014db:	89 e5                	mov    %esp,%ebp
  8014dd:	53                   	push   %ebx
  8014de:	83 ec 24             	sub    $0x24,%esp
  8014e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014eb:	89 1c 24             	mov    %ebx,(%esp)
  8014ee:	e8 4b fd ff ff       	call   80123e <fd_lookup>
  8014f3:	85 c0                	test   %eax,%eax
  8014f5:	78 6d                	js     801564 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801501:	8b 00                	mov    (%eax),%eax
  801503:	89 04 24             	mov    %eax,(%esp)
  801506:	e8 89 fd ff ff       	call   801294 <dev_lookup>
  80150b:	85 c0                	test   %eax,%eax
  80150d:	78 55                	js     801564 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80150f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801512:	8b 50 08             	mov    0x8(%eax),%edx
  801515:	83 e2 03             	and    $0x3,%edx
  801518:	83 fa 01             	cmp    $0x1,%edx
  80151b:	75 23                	jne    801540 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80151d:	a1 90 77 80 00       	mov    0x807790,%eax
  801522:	8b 40 48             	mov    0x48(%eax),%eax
  801525:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801529:	89 44 24 04          	mov    %eax,0x4(%esp)
  80152d:	c7 04 24 35 32 80 00 	movl   $0x803235,(%esp)
  801534:	e8 ff ef ff ff       	call   800538 <cprintf>
		return -E_INVAL;
  801539:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80153e:	eb 24                	jmp    801564 <read+0x8a>
	}
	if (!dev->dev_read)
  801540:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801543:	8b 52 08             	mov    0x8(%edx),%edx
  801546:	85 d2                	test   %edx,%edx
  801548:	74 15                	je     80155f <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80154a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80154d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801551:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801554:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801558:	89 04 24             	mov    %eax,(%esp)
  80155b:	ff d2                	call   *%edx
  80155d:	eb 05                	jmp    801564 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80155f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801564:	83 c4 24             	add    $0x24,%esp
  801567:	5b                   	pop    %ebx
  801568:	5d                   	pop    %ebp
  801569:	c3                   	ret    

0080156a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80156a:	55                   	push   %ebp
  80156b:	89 e5                	mov    %esp,%ebp
  80156d:	57                   	push   %edi
  80156e:	56                   	push   %esi
  80156f:	53                   	push   %ebx
  801570:	83 ec 1c             	sub    $0x1c,%esp
  801573:	8b 7d 08             	mov    0x8(%ebp),%edi
  801576:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801579:	bb 00 00 00 00       	mov    $0x0,%ebx
  80157e:	eb 23                	jmp    8015a3 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801580:	89 f0                	mov    %esi,%eax
  801582:	29 d8                	sub    %ebx,%eax
  801584:	89 44 24 08          	mov    %eax,0x8(%esp)
  801588:	8b 45 0c             	mov    0xc(%ebp),%eax
  80158b:	01 d8                	add    %ebx,%eax
  80158d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801591:	89 3c 24             	mov    %edi,(%esp)
  801594:	e8 41 ff ff ff       	call   8014da <read>
		if (m < 0)
  801599:	85 c0                	test   %eax,%eax
  80159b:	78 10                	js     8015ad <readn+0x43>
			return m;
		if (m == 0)
  80159d:	85 c0                	test   %eax,%eax
  80159f:	74 0a                	je     8015ab <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015a1:	01 c3                	add    %eax,%ebx
  8015a3:	39 f3                	cmp    %esi,%ebx
  8015a5:	72 d9                	jb     801580 <readn+0x16>
  8015a7:	89 d8                	mov    %ebx,%eax
  8015a9:	eb 02                	jmp    8015ad <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8015ab:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8015ad:	83 c4 1c             	add    $0x1c,%esp
  8015b0:	5b                   	pop    %ebx
  8015b1:	5e                   	pop    %esi
  8015b2:	5f                   	pop    %edi
  8015b3:	5d                   	pop    %ebp
  8015b4:	c3                   	ret    

008015b5 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015b5:	55                   	push   %ebp
  8015b6:	89 e5                	mov    %esp,%ebp
  8015b8:	53                   	push   %ebx
  8015b9:	83 ec 24             	sub    $0x24,%esp
  8015bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015bf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015c6:	89 1c 24             	mov    %ebx,(%esp)
  8015c9:	e8 70 fc ff ff       	call   80123e <fd_lookup>
  8015ce:	85 c0                	test   %eax,%eax
  8015d0:	78 68                	js     80163a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015dc:	8b 00                	mov    (%eax),%eax
  8015de:	89 04 24             	mov    %eax,(%esp)
  8015e1:	e8 ae fc ff ff       	call   801294 <dev_lookup>
  8015e6:	85 c0                	test   %eax,%eax
  8015e8:	78 50                	js     80163a <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ed:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015f1:	75 23                	jne    801616 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015f3:	a1 90 77 80 00       	mov    0x807790,%eax
  8015f8:	8b 40 48             	mov    0x48(%eax),%eax
  8015fb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8015ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801603:	c7 04 24 51 32 80 00 	movl   $0x803251,(%esp)
  80160a:	e8 29 ef ff ff       	call   800538 <cprintf>
		return -E_INVAL;
  80160f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801614:	eb 24                	jmp    80163a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801616:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801619:	8b 52 0c             	mov    0xc(%edx),%edx
  80161c:	85 d2                	test   %edx,%edx
  80161e:	74 15                	je     801635 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801620:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801623:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801627:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80162a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80162e:	89 04 24             	mov    %eax,(%esp)
  801631:	ff d2                	call   *%edx
  801633:	eb 05                	jmp    80163a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801635:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80163a:	83 c4 24             	add    $0x24,%esp
  80163d:	5b                   	pop    %ebx
  80163e:	5d                   	pop    %ebp
  80163f:	c3                   	ret    

00801640 <seek>:

int
seek(int fdnum, off_t offset)
{
  801640:	55                   	push   %ebp
  801641:	89 e5                	mov    %esp,%ebp
  801643:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801646:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801649:	89 44 24 04          	mov    %eax,0x4(%esp)
  80164d:	8b 45 08             	mov    0x8(%ebp),%eax
  801650:	89 04 24             	mov    %eax,(%esp)
  801653:	e8 e6 fb ff ff       	call   80123e <fd_lookup>
  801658:	85 c0                	test   %eax,%eax
  80165a:	78 0e                	js     80166a <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80165c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80165f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801662:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801665:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80166a:	c9                   	leave  
  80166b:	c3                   	ret    

0080166c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80166c:	55                   	push   %ebp
  80166d:	89 e5                	mov    %esp,%ebp
  80166f:	53                   	push   %ebx
  801670:	83 ec 24             	sub    $0x24,%esp
  801673:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801676:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801679:	89 44 24 04          	mov    %eax,0x4(%esp)
  80167d:	89 1c 24             	mov    %ebx,(%esp)
  801680:	e8 b9 fb ff ff       	call   80123e <fd_lookup>
  801685:	85 c0                	test   %eax,%eax
  801687:	78 61                	js     8016ea <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801689:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80168c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801690:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801693:	8b 00                	mov    (%eax),%eax
  801695:	89 04 24             	mov    %eax,(%esp)
  801698:	e8 f7 fb ff ff       	call   801294 <dev_lookup>
  80169d:	85 c0                	test   %eax,%eax
  80169f:	78 49                	js     8016ea <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016a4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016a8:	75 23                	jne    8016cd <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016aa:	a1 90 77 80 00       	mov    0x807790,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016af:	8b 40 48             	mov    0x48(%eax),%eax
  8016b2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ba:	c7 04 24 14 32 80 00 	movl   $0x803214,(%esp)
  8016c1:	e8 72 ee ff ff       	call   800538 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016cb:	eb 1d                	jmp    8016ea <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8016cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016d0:	8b 52 18             	mov    0x18(%edx),%edx
  8016d3:	85 d2                	test   %edx,%edx
  8016d5:	74 0e                	je     8016e5 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016da:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8016de:	89 04 24             	mov    %eax,(%esp)
  8016e1:	ff d2                	call   *%edx
  8016e3:	eb 05                	jmp    8016ea <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016e5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8016ea:	83 c4 24             	add    $0x24,%esp
  8016ed:	5b                   	pop    %ebx
  8016ee:	5d                   	pop    %ebp
  8016ef:	c3                   	ret    

008016f0 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016f0:	55                   	push   %ebp
  8016f1:	89 e5                	mov    %esp,%ebp
  8016f3:	53                   	push   %ebx
  8016f4:	83 ec 24             	sub    $0x24,%esp
  8016f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016fa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801701:	8b 45 08             	mov    0x8(%ebp),%eax
  801704:	89 04 24             	mov    %eax,(%esp)
  801707:	e8 32 fb ff ff       	call   80123e <fd_lookup>
  80170c:	85 c0                	test   %eax,%eax
  80170e:	78 52                	js     801762 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801710:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801713:	89 44 24 04          	mov    %eax,0x4(%esp)
  801717:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80171a:	8b 00                	mov    (%eax),%eax
  80171c:	89 04 24             	mov    %eax,(%esp)
  80171f:	e8 70 fb ff ff       	call   801294 <dev_lookup>
  801724:	85 c0                	test   %eax,%eax
  801726:	78 3a                	js     801762 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801728:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80172b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80172f:	74 2c                	je     80175d <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801731:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801734:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80173b:	00 00 00 
	stat->st_isdir = 0;
  80173e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801745:	00 00 00 
	stat->st_dev = dev;
  801748:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80174e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801752:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801755:	89 14 24             	mov    %edx,(%esp)
  801758:	ff 50 14             	call   *0x14(%eax)
  80175b:	eb 05                	jmp    801762 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80175d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801762:	83 c4 24             	add    $0x24,%esp
  801765:	5b                   	pop    %ebx
  801766:	5d                   	pop    %ebp
  801767:	c3                   	ret    

00801768 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801768:	55                   	push   %ebp
  801769:	89 e5                	mov    %esp,%ebp
  80176b:	56                   	push   %esi
  80176c:	53                   	push   %ebx
  80176d:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801770:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801777:	00 
  801778:	8b 45 08             	mov    0x8(%ebp),%eax
  80177b:	89 04 24             	mov    %eax,(%esp)
  80177e:	e8 2d 02 00 00       	call   8019b0 <open>
  801783:	89 c3                	mov    %eax,%ebx
  801785:	85 c0                	test   %eax,%eax
  801787:	78 1b                	js     8017a4 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801789:	8b 45 0c             	mov    0xc(%ebp),%eax
  80178c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801790:	89 1c 24             	mov    %ebx,(%esp)
  801793:	e8 58 ff ff ff       	call   8016f0 <fstat>
  801798:	89 c6                	mov    %eax,%esi
	close(fd);
  80179a:	89 1c 24             	mov    %ebx,(%esp)
  80179d:	e8 d4 fb ff ff       	call   801376 <close>
	return r;
  8017a2:	89 f3                	mov    %esi,%ebx
}
  8017a4:	89 d8                	mov    %ebx,%eax
  8017a6:	83 c4 10             	add    $0x10,%esp
  8017a9:	5b                   	pop    %ebx
  8017aa:	5e                   	pop    %esi
  8017ab:	5d                   	pop    %ebp
  8017ac:	c3                   	ret    
  8017ad:	00 00                	add    %al,(%eax)
	...

008017b0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017b0:	55                   	push   %ebp
  8017b1:	89 e5                	mov    %esp,%ebp
  8017b3:	56                   	push   %esi
  8017b4:	53                   	push   %ebx
  8017b5:	83 ec 10             	sub    $0x10,%esp
  8017b8:	89 c3                	mov    %eax,%ebx
  8017ba:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8017bc:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8017c3:	75 11                	jne    8017d6 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017c5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8017cc:	e8 9a 12 00 00       	call   802a6b <ipc_find_env>
  8017d1:	a3 00 60 80 00       	mov    %eax,0x806000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017d6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8017dd:	00 
  8017de:	c7 44 24 08 00 80 80 	movl   $0x808000,0x8(%esp)
  8017e5:	00 
  8017e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017ea:	a1 00 60 80 00       	mov    0x806000,%eax
  8017ef:	89 04 24             	mov    %eax,(%esp)
  8017f2:	e8 06 12 00 00       	call   8029fd <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017f7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017fe:	00 
  8017ff:	89 74 24 04          	mov    %esi,0x4(%esp)
  801803:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80180a:	e8 85 11 00 00       	call   802994 <ipc_recv>
}
  80180f:	83 c4 10             	add    $0x10,%esp
  801812:	5b                   	pop    %ebx
  801813:	5e                   	pop    %esi
  801814:	5d                   	pop    %ebp
  801815:	c3                   	ret    

00801816 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801816:	55                   	push   %ebp
  801817:	89 e5                	mov    %esp,%ebp
  801819:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80181c:	8b 45 08             	mov    0x8(%ebp),%eax
  80181f:	8b 40 0c             	mov    0xc(%eax),%eax
  801822:	a3 00 80 80 00       	mov    %eax,0x808000
	fsipcbuf.set_size.req_size = newsize;
  801827:	8b 45 0c             	mov    0xc(%ebp),%eax
  80182a:	a3 04 80 80 00       	mov    %eax,0x808004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80182f:	ba 00 00 00 00       	mov    $0x0,%edx
  801834:	b8 02 00 00 00       	mov    $0x2,%eax
  801839:	e8 72 ff ff ff       	call   8017b0 <fsipc>
}
  80183e:	c9                   	leave  
  80183f:	c3                   	ret    

00801840 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801840:	55                   	push   %ebp
  801841:	89 e5                	mov    %esp,%ebp
  801843:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801846:	8b 45 08             	mov    0x8(%ebp),%eax
  801849:	8b 40 0c             	mov    0xc(%eax),%eax
  80184c:	a3 00 80 80 00       	mov    %eax,0x808000
	return fsipc(FSREQ_FLUSH, NULL);
  801851:	ba 00 00 00 00       	mov    $0x0,%edx
  801856:	b8 06 00 00 00       	mov    $0x6,%eax
  80185b:	e8 50 ff ff ff       	call   8017b0 <fsipc>
}
  801860:	c9                   	leave  
  801861:	c3                   	ret    

00801862 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801862:	55                   	push   %ebp
  801863:	89 e5                	mov    %esp,%ebp
  801865:	53                   	push   %ebx
  801866:	83 ec 14             	sub    $0x14,%esp
  801869:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80186c:	8b 45 08             	mov    0x8(%ebp),%eax
  80186f:	8b 40 0c             	mov    0xc(%eax),%eax
  801872:	a3 00 80 80 00       	mov    %eax,0x808000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801877:	ba 00 00 00 00       	mov    $0x0,%edx
  80187c:	b8 05 00 00 00       	mov    $0x5,%eax
  801881:	e8 2a ff ff ff       	call   8017b0 <fsipc>
  801886:	85 c0                	test   %eax,%eax
  801888:	78 2b                	js     8018b5 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80188a:	c7 44 24 04 00 80 80 	movl   $0x808000,0x4(%esp)
  801891:	00 
  801892:	89 1c 24             	mov    %ebx,(%esp)
  801895:	e8 49 f2 ff ff       	call   800ae3 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80189a:	a1 80 80 80 00       	mov    0x808080,%eax
  80189f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018a5:	a1 84 80 80 00       	mov    0x808084,%eax
  8018aa:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018b5:	83 c4 14             	add    $0x14,%esp
  8018b8:	5b                   	pop    %ebx
  8018b9:	5d                   	pop    %ebp
  8018ba:	c3                   	ret    

008018bb <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018bb:	55                   	push   %ebp
  8018bc:	89 e5                	mov    %esp,%ebp
  8018be:	83 ec 18             	sub    $0x18,%esp
  8018c1:	8b 55 10             	mov    0x10(%ebp),%edx
  8018c4:	89 d0                	mov    %edx,%eax
  8018c6:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  8018cc:	76 05                	jbe    8018d3 <devfile_write+0x18>
  8018ce:	b8 00 10 00 00       	mov    $0x1000,%eax
	//panic("devfile_write not implemented");
	int r;
	//uint32_t maxsize = BLKSIZE - sizeof(int) - sizeof(size_t);	
	if (n > BLKSIZE)
		n = BLKSIZE;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8018d6:	8b 52 0c             	mov    0xc(%edx),%edx
  8018d9:	89 15 00 80 80 00    	mov    %edx,0x808000
	fsipcbuf.write.req_n = n;
  8018df:	a3 04 80 80 00       	mov    %eax,0x808004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8018e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ef:	c7 04 24 08 80 80 00 	movl   $0x808008,(%esp)
  8018f6:	e8 61 f3 ff ff       	call   800c5c <memmove>
	 
	return fsipc(FSREQ_WRITE, NULL);
  8018fb:	ba 00 00 00 00       	mov    $0x0,%edx
  801900:	b8 04 00 00 00       	mov    $0x4,%eax
  801905:	e8 a6 fe ff ff       	call   8017b0 <fsipc>
}
  80190a:	c9                   	leave  
  80190b:	c3                   	ret    

0080190c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80190c:	55                   	push   %ebp
  80190d:	89 e5                	mov    %esp,%ebp
  80190f:	56                   	push   %esi
  801910:	53                   	push   %ebx
  801911:	83 ec 10             	sub    $0x10,%esp
  801914:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801917:	8b 45 08             	mov    0x8(%ebp),%eax
  80191a:	8b 40 0c             	mov    0xc(%eax),%eax
  80191d:	a3 00 80 80 00       	mov    %eax,0x808000
	fsipcbuf.read.req_n = n;
  801922:	89 35 04 80 80 00    	mov    %esi,0x808004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801928:	ba 00 00 00 00       	mov    $0x0,%edx
  80192d:	b8 03 00 00 00       	mov    $0x3,%eax
  801932:	e8 79 fe ff ff       	call   8017b0 <fsipc>
  801937:	89 c3                	mov    %eax,%ebx
  801939:	85 c0                	test   %eax,%eax
  80193b:	78 6a                	js     8019a7 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  80193d:	39 c6                	cmp    %eax,%esi
  80193f:	73 24                	jae    801965 <devfile_read+0x59>
  801941:	c7 44 24 0c 84 32 80 	movl   $0x803284,0xc(%esp)
  801948:	00 
  801949:	c7 44 24 08 8b 32 80 	movl   $0x80328b,0x8(%esp)
  801950:	00 
  801951:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801958:	00 
  801959:	c7 04 24 a0 32 80 00 	movl   $0x8032a0,(%esp)
  801960:	e8 db ea ff ff       	call   800440 <_panic>
	assert(r <= PGSIZE);
  801965:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80196a:	7e 24                	jle    801990 <devfile_read+0x84>
  80196c:	c7 44 24 0c ab 32 80 	movl   $0x8032ab,0xc(%esp)
  801973:	00 
  801974:	c7 44 24 08 8b 32 80 	movl   $0x80328b,0x8(%esp)
  80197b:	00 
  80197c:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801983:	00 
  801984:	c7 04 24 a0 32 80 00 	movl   $0x8032a0,(%esp)
  80198b:	e8 b0 ea ff ff       	call   800440 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801990:	89 44 24 08          	mov    %eax,0x8(%esp)
  801994:	c7 44 24 04 00 80 80 	movl   $0x808000,0x4(%esp)
  80199b:	00 
  80199c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80199f:	89 04 24             	mov    %eax,(%esp)
  8019a2:	e8 b5 f2 ff ff       	call   800c5c <memmove>
	return r;
}
  8019a7:	89 d8                	mov    %ebx,%eax
  8019a9:	83 c4 10             	add    $0x10,%esp
  8019ac:	5b                   	pop    %ebx
  8019ad:	5e                   	pop    %esi
  8019ae:	5d                   	pop    %ebp
  8019af:	c3                   	ret    

008019b0 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019b0:	55                   	push   %ebp
  8019b1:	89 e5                	mov    %esp,%ebp
  8019b3:	56                   	push   %esi
  8019b4:	53                   	push   %ebx
  8019b5:	83 ec 20             	sub    $0x20,%esp
  8019b8:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019bb:	89 34 24             	mov    %esi,(%esp)
  8019be:	e8 ed f0 ff ff       	call   800ab0 <strlen>
  8019c3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019c8:	7f 60                	jg     801a2a <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019cd:	89 04 24             	mov    %eax,(%esp)
  8019d0:	e8 16 f8 ff ff       	call   8011eb <fd_alloc>
  8019d5:	89 c3                	mov    %eax,%ebx
  8019d7:	85 c0                	test   %eax,%eax
  8019d9:	78 54                	js     801a2f <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019db:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019df:	c7 04 24 00 80 80 00 	movl   $0x808000,(%esp)
  8019e6:	e8 f8 f0 ff ff       	call   800ae3 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ee:	a3 00 84 80 00       	mov    %eax,0x808400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8019fb:	e8 b0 fd ff ff       	call   8017b0 <fsipc>
  801a00:	89 c3                	mov    %eax,%ebx
  801a02:	85 c0                	test   %eax,%eax
  801a04:	79 15                	jns    801a1b <open+0x6b>
		fd_close(fd, 0);
  801a06:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a0d:	00 
  801a0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a11:	89 04 24             	mov    %eax,(%esp)
  801a14:	e8 d5 f8 ff ff       	call   8012ee <fd_close>
		return r;
  801a19:	eb 14                	jmp    801a2f <open+0x7f>
	}

	return fd2num(fd);
  801a1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a1e:	89 04 24             	mov    %eax,(%esp)
  801a21:	e8 9a f7 ff ff       	call   8011c0 <fd2num>
  801a26:	89 c3                	mov    %eax,%ebx
  801a28:	eb 05                	jmp    801a2f <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a2a:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a2f:	89 d8                	mov    %ebx,%eax
  801a31:	83 c4 20             	add    $0x20,%esp
  801a34:	5b                   	pop    %ebx
  801a35:	5e                   	pop    %esi
  801a36:	5d                   	pop    %ebp
  801a37:	c3                   	ret    

00801a38 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a38:	55                   	push   %ebp
  801a39:	89 e5                	mov    %esp,%ebp
  801a3b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a3e:	ba 00 00 00 00       	mov    $0x0,%edx
  801a43:	b8 08 00 00 00       	mov    $0x8,%eax
  801a48:	e8 63 fd ff ff       	call   8017b0 <fsipc>
}
  801a4d:	c9                   	leave  
  801a4e:	c3                   	ret    
	...

00801a50 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801a50:	55                   	push   %ebp
  801a51:	89 e5                	mov    %esp,%ebp
  801a53:	57                   	push   %edi
  801a54:	56                   	push   %esi
  801a55:	53                   	push   %ebx
  801a56:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801a5c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a63:	00 
  801a64:	8b 45 08             	mov    0x8(%ebp),%eax
  801a67:	89 04 24             	mov    %eax,(%esp)
  801a6a:	e8 41 ff ff ff       	call   8019b0 <open>
  801a6f:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
  801a75:	85 c0                	test   %eax,%eax
  801a77:	0f 88 86 05 00 00    	js     802003 <spawn+0x5b3>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801a7d:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  801a84:	00 
  801a85:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801a8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a8f:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801a95:	89 04 24             	mov    %eax,(%esp)
  801a98:	e8 cd fa ff ff       	call   80156a <readn>
  801a9d:	3d 00 02 00 00       	cmp    $0x200,%eax
  801aa2:	75 0c                	jne    801ab0 <spawn+0x60>
	    || elf->e_magic != ELF_MAGIC) {
  801aa4:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801aab:	45 4c 46 
  801aae:	74 3b                	je     801aeb <spawn+0x9b>
		close(fd);
  801ab0:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801ab6:	89 04 24             	mov    %eax,(%esp)
  801ab9:	e8 b8 f8 ff ff       	call   801376 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801abe:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  801ac5:	46 
  801ac6:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  801acc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ad0:	c7 04 24 b7 32 80 00 	movl   $0x8032b7,(%esp)
  801ad7:	e8 5c ea ff ff       	call   800538 <cprintf>
		return -E_NOT_EXEC;
  801adc:	c7 85 88 fd ff ff f2 	movl   $0xfffffff2,-0x278(%ebp)
  801ae3:	ff ff ff 
  801ae6:	e9 24 05 00 00       	jmp    80200f <spawn+0x5bf>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801aeb:	ba 07 00 00 00       	mov    $0x7,%edx
  801af0:	89 d0                	mov    %edx,%eax
  801af2:	cd 30                	int    $0x30
  801af4:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801afa:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801b00:	85 c0                	test   %eax,%eax
  801b02:	0f 88 07 05 00 00    	js     80200f <spawn+0x5bf>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801b08:	89 c6                	mov    %eax,%esi
  801b0a:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801b10:	c1 e6 07             	shl    $0x7,%esi
  801b13:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801b19:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801b1f:	b9 11 00 00 00       	mov    $0x11,%ecx
  801b24:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801b26:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801b2c:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801b32:	be 00 00 00 00       	mov    $0x0,%esi
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801b37:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b3c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801b3f:	eb 0d                	jmp    801b4e <spawn+0xfe>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801b41:	89 04 24             	mov    %eax,(%esp)
  801b44:	e8 67 ef ff ff       	call   800ab0 <strlen>
  801b49:	8d 5c 18 01          	lea    0x1(%eax,%ebx,1),%ebx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801b4d:	46                   	inc    %esi
  801b4e:	89 f2                	mov    %esi,%edx
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801b50:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801b57:	8b 04 b7             	mov    (%edi,%esi,4),%eax
  801b5a:	85 c0                	test   %eax,%eax
  801b5c:	75 e3                	jne    801b41 <spawn+0xf1>
  801b5e:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
  801b64:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801b6a:	bf 00 10 40 00       	mov    $0x401000,%edi
  801b6f:	29 df                	sub    %ebx,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801b71:	89 f8                	mov    %edi,%eax
  801b73:	83 e0 fc             	and    $0xfffffffc,%eax
  801b76:	f7 d2                	not    %edx
  801b78:	8d 14 90             	lea    (%eax,%edx,4),%edx
  801b7b:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801b81:	89 d0                	mov    %edx,%eax
  801b83:	83 e8 08             	sub    $0x8,%eax
  801b86:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801b8b:	0f 86 8f 04 00 00    	jbe    802020 <spawn+0x5d0>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b91:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801b98:	00 
  801b99:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801ba0:	00 
  801ba1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ba8:	e8 28 f3 ff ff       	call   800ed5 <sys_page_alloc>
  801bad:	85 c0                	test   %eax,%eax
  801baf:	0f 88 70 04 00 00    	js     802025 <spawn+0x5d5>
  801bb5:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bba:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  801bc0:	8b 75 0c             	mov    0xc(%ebp),%esi
  801bc3:	eb 2e                	jmp    801bf3 <spawn+0x1a3>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801bc5:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801bcb:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801bd1:	89 04 9a             	mov    %eax,(%edx,%ebx,4)
		strcpy(string_store, argv[i]);
  801bd4:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  801bd7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bdb:	89 3c 24             	mov    %edi,(%esp)
  801bde:	e8 00 ef ff ff       	call   800ae3 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801be3:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  801be6:	89 04 24             	mov    %eax,(%esp)
  801be9:	e8 c2 ee ff ff       	call   800ab0 <strlen>
  801bee:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801bf2:	43                   	inc    %ebx
  801bf3:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801bf9:	7c ca                	jl     801bc5 <spawn+0x175>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801bfb:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801c01:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801c07:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801c0e:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801c14:	74 24                	je     801c3a <spawn+0x1ea>
  801c16:	c7 44 24 0c 44 33 80 	movl   $0x803344,0xc(%esp)
  801c1d:	00 
  801c1e:	c7 44 24 08 8b 32 80 	movl   $0x80328b,0x8(%esp)
  801c25:	00 
  801c26:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
  801c2d:	00 
  801c2e:	c7 04 24 d1 32 80 00 	movl   $0x8032d1,(%esp)
  801c35:	e8 06 e8 ff ff       	call   800440 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801c3a:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801c40:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801c45:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801c4b:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  801c4e:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801c54:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801c57:	89 d0                	mov    %edx,%eax
  801c59:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801c5e:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801c64:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801c6b:	00 
  801c6c:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  801c73:	ee 
  801c74:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801c7a:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c7e:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801c85:	00 
  801c86:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c8d:	e8 97 f2 ff ff       	call   800f29 <sys_page_map>
  801c92:	89 c3                	mov    %eax,%ebx
  801c94:	85 c0                	test   %eax,%eax
  801c96:	78 1a                	js     801cb2 <spawn+0x262>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801c98:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801c9f:	00 
  801ca0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ca7:	e8 d0 f2 ff ff       	call   800f7c <sys_page_unmap>
  801cac:	89 c3                	mov    %eax,%ebx
  801cae:	85 c0                	test   %eax,%eax
  801cb0:	79 1f                	jns    801cd1 <spawn+0x281>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801cb2:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801cb9:	00 
  801cba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cc1:	e8 b6 f2 ff ff       	call   800f7c <sys_page_unmap>
	return r;
  801cc6:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801ccc:	e9 3e 03 00 00       	jmp    80200f <spawn+0x5bf>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801cd1:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  801cd7:	03 95 04 fe ff ff    	add    -0x1fc(%ebp),%edx
  801cdd:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801ce3:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  801cea:	00 00 00 
  801ced:	e9 bb 01 00 00       	jmp    801ead <spawn+0x45d>
		if (ph->p_type != ELF_PROG_LOAD)
  801cf2:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801cf8:	83 38 01             	cmpl   $0x1,(%eax)
  801cfb:	0f 85 9f 01 00 00    	jne    801ea0 <spawn+0x450>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801d01:	89 c2                	mov    %eax,%edx
  801d03:	8b 40 18             	mov    0x18(%eax),%eax
  801d06:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  801d09:	83 f8 01             	cmp    $0x1,%eax
  801d0c:	19 c0                	sbb    %eax,%eax
  801d0e:	83 e0 fe             	and    $0xfffffffe,%eax
  801d11:	83 c0 07             	add    $0x7,%eax
  801d14:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801d1a:	8b 52 04             	mov    0x4(%edx),%edx
  801d1d:	89 95 78 fd ff ff    	mov    %edx,-0x288(%ebp)
  801d23:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801d29:	8b 40 10             	mov    0x10(%eax),%eax
  801d2c:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801d32:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  801d38:	8b 52 14             	mov    0x14(%edx),%edx
  801d3b:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  801d41:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801d47:	8b 78 08             	mov    0x8(%eax),%edi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801d4a:	89 f8                	mov    %edi,%eax
  801d4c:	25 ff 0f 00 00       	and    $0xfff,%eax
  801d51:	74 16                	je     801d69 <spawn+0x319>
		va -= i;
  801d53:	29 c7                	sub    %eax,%edi
		memsz += i;
  801d55:	01 c2                	add    %eax,%edx
  801d57:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
		filesz += i;
  801d5d:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  801d63:	29 85 78 fd ff ff    	sub    %eax,-0x288(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801d69:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d6e:	e9 1f 01 00 00       	jmp    801e92 <spawn+0x442>
		if (i >= filesz) {
  801d73:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  801d79:	77 2b                	ja     801da6 <spawn+0x356>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801d7b:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  801d81:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d85:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801d89:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801d8f:	89 04 24             	mov    %eax,(%esp)
  801d92:	e8 3e f1 ff ff       	call   800ed5 <sys_page_alloc>
  801d97:	85 c0                	test   %eax,%eax
  801d99:	0f 89 e7 00 00 00    	jns    801e86 <spawn+0x436>
  801d9f:	89 c6                	mov    %eax,%esi
  801da1:	e9 39 02 00 00       	jmp    801fdf <spawn+0x58f>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801da6:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801dad:	00 
  801dae:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801db5:	00 
  801db6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dbd:	e8 13 f1 ff ff       	call   800ed5 <sys_page_alloc>
  801dc2:	85 c0                	test   %eax,%eax
  801dc4:	0f 88 0b 02 00 00    	js     801fd5 <spawn+0x585>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801dca:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  801dd0:	01 f0                	add    %esi,%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801dd2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dd6:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801ddc:	89 04 24             	mov    %eax,(%esp)
  801ddf:	e8 5c f8 ff ff       	call   801640 <seek>
  801de4:	85 c0                	test   %eax,%eax
  801de6:	0f 88 ed 01 00 00    	js     801fd9 <spawn+0x589>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801dec:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801df2:	29 f0                	sub    %esi,%eax
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801df4:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801df9:	76 05                	jbe    801e00 <spawn+0x3b0>
  801dfb:	b8 00 10 00 00       	mov    $0x1000,%eax
  801e00:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e04:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801e0b:	00 
  801e0c:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801e12:	89 04 24             	mov    %eax,(%esp)
  801e15:	e8 50 f7 ff ff       	call   80156a <readn>
  801e1a:	85 c0                	test   %eax,%eax
  801e1c:	0f 88 bb 01 00 00    	js     801fdd <spawn+0x58d>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801e22:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  801e28:	89 54 24 10          	mov    %edx,0x10(%esp)
  801e2c:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801e30:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801e36:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e3a:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801e41:	00 
  801e42:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e49:	e8 db f0 ff ff       	call   800f29 <sys_page_map>
  801e4e:	85 c0                	test   %eax,%eax
  801e50:	79 20                	jns    801e72 <spawn+0x422>
				panic("spawn: sys_page_map data: %e", r);
  801e52:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e56:	c7 44 24 08 dd 32 80 	movl   $0x8032dd,0x8(%esp)
  801e5d:	00 
  801e5e:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
  801e65:	00 
  801e66:	c7 04 24 d1 32 80 00 	movl   $0x8032d1,(%esp)
  801e6d:	e8 ce e5 ff ff       	call   800440 <_panic>
			sys_page_unmap(0, UTEMP);
  801e72:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801e79:	00 
  801e7a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e81:	e8 f6 f0 ff ff       	call   800f7c <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801e86:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801e8c:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801e92:	89 de                	mov    %ebx,%esi
  801e94:	3b 9d 8c fd ff ff    	cmp    -0x274(%ebp),%ebx
  801e9a:	0f 82 d3 fe ff ff    	jb     801d73 <spawn+0x323>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801ea0:	ff 85 7c fd ff ff    	incl   -0x284(%ebp)
  801ea6:	83 85 80 fd ff ff 20 	addl   $0x20,-0x280(%ebp)
  801ead:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801eb4:	39 85 7c fd ff ff    	cmp    %eax,-0x284(%ebp)
  801eba:	0f 8c 32 fe ff ff    	jl     801cf2 <spawn+0x2a2>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801ec0:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801ec6:	89 04 24             	mov    %eax,(%esp)
  801ec9:	e8 a8 f4 ff ff       	call   801376 <close>
{
	// LAB 5: Your code here.
	int r;
	uint32_t page_num;
	
	for (page_num = 0; page_num < PGNUM(UTOP); page_num++) {
  801ece:	be 00 00 00 00       	mov    $0x0,%esi
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES)/NPDENTRIES;
  801ed3:	89 f0                	mov    %esi,%eax
  801ed5:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx]&PTE_P) && (uvpt[page_num]&PTE_P) && (uvpt[page_num]&PTE_SHARE)){
  801ed8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801edf:	a8 01                	test   $0x1,%al
  801ee1:	0f 84 82 00 00 00    	je     801f69 <spawn+0x519>
  801ee7:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801eee:	a8 01                	test   $0x1,%al
  801ef0:	74 77                	je     801f69 <spawn+0x519>
  801ef2:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801ef9:	f6 c4 04             	test   $0x4,%ah
  801efc:	74 6b                	je     801f69 <spawn+0x519>
			if ((r = sys_page_map(sys_getenvid(), (void*)(page_num*PGSIZE), child, (void*)(page_num*PGSIZE), uvpt[page_num]&PTE_SYSCALL)) < 0){
  801efe:	8b 3c b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edi
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801f05:	89 f3                	mov    %esi,%ebx
  801f07:	c1 e3 0c             	shl    $0xc,%ebx
	uint32_t page_num;
	
	for (page_num = 0; page_num < PGNUM(UTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES)/NPDENTRIES;
		if ((uvpd[pdx]&PTE_P) && (uvpt[page_num]&PTE_P) && (uvpt[page_num]&PTE_SHARE)){
			if ((r = sys_page_map(sys_getenvid(), (void*)(page_num*PGSIZE), child, (void*)(page_num*PGSIZE), uvpt[page_num]&PTE_SYSCALL)) < 0){
  801f0a:	e8 88 ef ff ff       	call   800e97 <sys_getenvid>
  801f0f:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  801f15:	89 7c 24 10          	mov    %edi,0x10(%esp)
  801f19:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801f1d:	8b 95 88 fd ff ff    	mov    -0x278(%ebp),%edx
  801f23:	89 54 24 08          	mov    %edx,0x8(%esp)
  801f27:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f2b:	89 04 24             	mov    %eax,(%esp)
  801f2e:	e8 f6 ef ff ff       	call   800f29 <sys_page_map>
  801f33:	85 c0                	test   %eax,%eax
  801f35:	79 32                	jns    801f69 <spawn+0x519>
  801f37:	89 c3                	mov    %eax,%ebx
				cprintf("copy_shared_pages: sys_page_map failed, %e", r);
  801f39:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f3d:	c7 04 24 6c 33 80 00 	movl   $0x80336c,(%esp)
  801f44:	e8 ef e5 ff ff       	call   800538 <cprintf>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801f49:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801f4d:	c7 44 24 08 fa 32 80 	movl   $0x8032fa,0x8(%esp)
  801f54:	00 
  801f55:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  801f5c:	00 
  801f5d:	c7 04 24 d1 32 80 00 	movl   $0x8032d1,(%esp)
  801f64:	e8 d7 e4 ff ff       	call   800440 <_panic>
{
	// LAB 5: Your code here.
	int r;
	uint32_t page_num;
	
	for (page_num = 0; page_num < PGNUM(UTOP); page_num++) {
  801f69:	46                   	inc    %esi
  801f6a:	81 fe 00 ec 0e 00    	cmp    $0xeec00,%esi
  801f70:	0f 85 5d ff ff ff    	jne    801ed3 <spawn+0x483>
  801f76:	e9 b2 00 00 00       	jmp    80202d <spawn+0x5dd>
	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  801f7b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f7f:	c7 44 24 08 10 33 80 	movl   $0x803310,0x8(%esp)
  801f86:	00 
  801f87:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  801f8e:	00 
  801f8f:	c7 04 24 d1 32 80 00 	movl   $0x8032d1,(%esp)
  801f96:	e8 a5 e4 ff ff       	call   800440 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801f9b:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801fa2:	00 
  801fa3:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801fa9:	89 04 24             	mov    %eax,(%esp)
  801fac:	e8 1e f0 ff ff       	call   800fcf <sys_env_set_status>
  801fb1:	85 c0                	test   %eax,%eax
  801fb3:	79 5a                	jns    80200f <spawn+0x5bf>
		panic("sys_env_set_status: %e", r);
  801fb5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fb9:	c7 44 24 08 2a 33 80 	movl   $0x80332a,0x8(%esp)
  801fc0:	00 
  801fc1:	c7 44 24 04 88 00 00 	movl   $0x88,0x4(%esp)
  801fc8:	00 
  801fc9:	c7 04 24 d1 32 80 00 	movl   $0x8032d1,(%esp)
  801fd0:	e8 6b e4 ff ff       	call   800440 <_panic>
  801fd5:	89 c6                	mov    %eax,%esi
  801fd7:	eb 06                	jmp    801fdf <spawn+0x58f>
  801fd9:	89 c6                	mov    %eax,%esi
  801fdb:	eb 02                	jmp    801fdf <spawn+0x58f>
  801fdd:	89 c6                	mov    %eax,%esi

	return child;

error:
	sys_env_destroy(child);
  801fdf:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801fe5:	89 04 24             	mov    %eax,(%esp)
  801fe8:	e8 58 ee ff ff       	call   800e45 <sys_env_destroy>
	close(fd);
  801fed:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801ff3:	89 04 24             	mov    %eax,(%esp)
  801ff6:	e8 7b f3 ff ff       	call   801376 <close>
	return r;
  801ffb:	89 b5 88 fd ff ff    	mov    %esi,-0x278(%ebp)
  802001:	eb 0c                	jmp    80200f <spawn+0x5bf>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  802003:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  802009:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  80200f:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802015:	81 c4 ac 02 00 00    	add    $0x2ac,%esp
  80201b:	5b                   	pop    %ebx
  80201c:	5e                   	pop    %esi
  80201d:	5f                   	pop    %edi
  80201e:	5d                   	pop    %ebp
  80201f:	c3                   	ret    
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  802020:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  802025:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  80202b:	eb e2                	jmp    80200f <spawn+0x5bf>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  80202d:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802033:	89 44 24 04          	mov    %eax,0x4(%esp)
  802037:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  80203d:	89 04 24             	mov    %eax,(%esp)
  802040:	e8 dd ef ff ff       	call   801022 <sys_env_set_trapframe>
  802045:	85 c0                	test   %eax,%eax
  802047:	0f 89 4e ff ff ff    	jns    801f9b <spawn+0x54b>
  80204d:	e9 29 ff ff ff       	jmp    801f7b <spawn+0x52b>

00802052 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802052:	55                   	push   %ebp
  802053:	89 e5                	mov    %esp,%ebp
  802055:	57                   	push   %edi
  802056:	56                   	push   %esi
  802057:	53                   	push   %ebx
  802058:	83 ec 1c             	sub    $0x1c,%esp
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
  80205b:	8d 45 10             	lea    0x10(%ebp),%eax
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  80205e:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802063:	eb 03                	jmp    802068 <spawnl+0x16>
		argc++;
  802065:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802066:	89 d0                	mov    %edx,%eax
  802068:	8d 50 04             	lea    0x4(%eax),%edx
  80206b:	83 38 00             	cmpl   $0x0,(%eax)
  80206e:	75 f5                	jne    802065 <spawnl+0x13>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802070:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  802077:	83 e0 f0             	and    $0xfffffff0,%eax
  80207a:	29 c4                	sub    %eax,%esp
  80207c:	8d 7c 24 17          	lea    0x17(%esp),%edi
  802080:	83 e7 f0             	and    $0xfffffff0,%edi
  802083:	89 fe                	mov    %edi,%esi
	argv[0] = arg0;
  802085:	8b 45 0c             	mov    0xc(%ebp),%eax
  802088:	89 07                	mov    %eax,(%edi)
	argv[argc+1] = NULL;
  80208a:	c7 44 8f 04 00 00 00 	movl   $0x0,0x4(%edi,%ecx,4)
  802091:	00 

	va_start(vl, arg0);
  802092:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  802095:	b8 00 00 00 00       	mov    $0x0,%eax
  80209a:	eb 09                	jmp    8020a5 <spawnl+0x53>
		argv[i+1] = va_arg(vl, const char *);
  80209c:	40                   	inc    %eax
  80209d:	8b 1a                	mov    (%edx),%ebx
  80209f:	89 1c 86             	mov    %ebx,(%esi,%eax,4)
  8020a2:	8d 52 04             	lea    0x4(%edx),%edx
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  8020a5:	39 c8                	cmp    %ecx,%eax
  8020a7:	75 f3                	jne    80209c <spawnl+0x4a>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  8020a9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8020ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8020b0:	89 04 24             	mov    %eax,(%esp)
  8020b3:	e8 98 f9 ff ff       	call   801a50 <spawn>
}
  8020b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020bb:	5b                   	pop    %ebx
  8020bc:	5e                   	pop    %esi
  8020bd:	5f                   	pop    %edi
  8020be:	5d                   	pop    %ebp
  8020bf:	c3                   	ret    

008020c0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8020c0:	55                   	push   %ebp
  8020c1:	89 e5                	mov    %esp,%ebp
  8020c3:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  8020c6:	c7 44 24 04 97 33 80 	movl   $0x803397,0x4(%esp)
  8020cd:	00 
  8020ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020d1:	89 04 24             	mov    %eax,(%esp)
  8020d4:	e8 0a ea ff ff       	call   800ae3 <strcpy>
	return 0;
}
  8020d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8020de:	c9                   	leave  
  8020df:	c3                   	ret    

008020e0 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8020e0:	55                   	push   %ebp
  8020e1:	89 e5                	mov    %esp,%ebp
  8020e3:	53                   	push   %ebx
  8020e4:	83 ec 14             	sub    $0x14,%esp
  8020e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8020ea:	89 1c 24             	mov    %ebx,(%esp)
  8020ed:	e8 b2 09 00 00       	call   802aa4 <pageref>
  8020f2:	83 f8 01             	cmp    $0x1,%eax
  8020f5:	75 0d                	jne    802104 <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  8020f7:	8b 43 0c             	mov    0xc(%ebx),%eax
  8020fa:	89 04 24             	mov    %eax,(%esp)
  8020fd:	e8 1f 03 00 00       	call   802421 <nsipc_close>
  802102:	eb 05                	jmp    802109 <devsock_close+0x29>
	else
		return 0;
  802104:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802109:	83 c4 14             	add    $0x14,%esp
  80210c:	5b                   	pop    %ebx
  80210d:	5d                   	pop    %ebp
  80210e:	c3                   	ret    

0080210f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  80210f:	55                   	push   %ebp
  802110:	89 e5                	mov    %esp,%ebp
  802112:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  802115:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80211c:	00 
  80211d:	8b 45 10             	mov    0x10(%ebp),%eax
  802120:	89 44 24 08          	mov    %eax,0x8(%esp)
  802124:	8b 45 0c             	mov    0xc(%ebp),%eax
  802127:	89 44 24 04          	mov    %eax,0x4(%esp)
  80212b:	8b 45 08             	mov    0x8(%ebp),%eax
  80212e:	8b 40 0c             	mov    0xc(%eax),%eax
  802131:	89 04 24             	mov    %eax,(%esp)
  802134:	e8 e3 03 00 00       	call   80251c <nsipc_send>
}
  802139:	c9                   	leave  
  80213a:	c3                   	ret    

0080213b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80213b:	55                   	push   %ebp
  80213c:	89 e5                	mov    %esp,%ebp
  80213e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802141:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802148:	00 
  802149:	8b 45 10             	mov    0x10(%ebp),%eax
  80214c:	89 44 24 08          	mov    %eax,0x8(%esp)
  802150:	8b 45 0c             	mov    0xc(%ebp),%eax
  802153:	89 44 24 04          	mov    %eax,0x4(%esp)
  802157:	8b 45 08             	mov    0x8(%ebp),%eax
  80215a:	8b 40 0c             	mov    0xc(%eax),%eax
  80215d:	89 04 24             	mov    %eax,(%esp)
  802160:	e8 37 03 00 00       	call   80249c <nsipc_recv>
}
  802165:	c9                   	leave  
  802166:	c3                   	ret    

00802167 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  802167:	55                   	push   %ebp
  802168:	89 e5                	mov    %esp,%ebp
  80216a:	56                   	push   %esi
  80216b:	53                   	push   %ebx
  80216c:	83 ec 20             	sub    $0x20,%esp
  80216f:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  802171:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802174:	89 04 24             	mov    %eax,(%esp)
  802177:	e8 6f f0 ff ff       	call   8011eb <fd_alloc>
  80217c:	89 c3                	mov    %eax,%ebx
  80217e:	85 c0                	test   %eax,%eax
  802180:	78 21                	js     8021a3 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  802182:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802189:	00 
  80218a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80218d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802191:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802198:	e8 38 ed ff ff       	call   800ed5 <sys_page_alloc>
  80219d:	89 c3                	mov    %eax,%ebx
  80219f:	85 c0                	test   %eax,%eax
  8021a1:	79 0a                	jns    8021ad <alloc_sockfd+0x46>
		nsipc_close(sockid);
  8021a3:	89 34 24             	mov    %esi,(%esp)
  8021a6:	e8 76 02 00 00       	call   802421 <nsipc_close>
		return r;
  8021ab:	eb 22                	jmp    8021cf <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8021ad:	8b 15 ac 57 80 00    	mov    0x8057ac,%edx
  8021b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021b6:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8021b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021bb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8021c2:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8021c5:	89 04 24             	mov    %eax,(%esp)
  8021c8:	e8 f3 ef ff ff       	call   8011c0 <fd2num>
  8021cd:	89 c3                	mov    %eax,%ebx
}
  8021cf:	89 d8                	mov    %ebx,%eax
  8021d1:	83 c4 20             	add    $0x20,%esp
  8021d4:	5b                   	pop    %ebx
  8021d5:	5e                   	pop    %esi
  8021d6:	5d                   	pop    %ebp
  8021d7:	c3                   	ret    

008021d8 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8021d8:	55                   	push   %ebp
  8021d9:	89 e5                	mov    %esp,%ebp
  8021db:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8021de:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8021e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021e5:	89 04 24             	mov    %eax,(%esp)
  8021e8:	e8 51 f0 ff ff       	call   80123e <fd_lookup>
  8021ed:	85 c0                	test   %eax,%eax
  8021ef:	78 17                	js     802208 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8021f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021f4:	8b 15 ac 57 80 00    	mov    0x8057ac,%edx
  8021fa:	39 10                	cmp    %edx,(%eax)
  8021fc:	75 05                	jne    802203 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8021fe:	8b 40 0c             	mov    0xc(%eax),%eax
  802201:	eb 05                	jmp    802208 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  802203:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  802208:	c9                   	leave  
  802209:	c3                   	ret    

0080220a <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80220a:	55                   	push   %ebp
  80220b:	89 e5                	mov    %esp,%ebp
  80220d:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802210:	8b 45 08             	mov    0x8(%ebp),%eax
  802213:	e8 c0 ff ff ff       	call   8021d8 <fd2sockid>
  802218:	85 c0                	test   %eax,%eax
  80221a:	78 1f                	js     80223b <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80221c:	8b 55 10             	mov    0x10(%ebp),%edx
  80221f:	89 54 24 08          	mov    %edx,0x8(%esp)
  802223:	8b 55 0c             	mov    0xc(%ebp),%edx
  802226:	89 54 24 04          	mov    %edx,0x4(%esp)
  80222a:	89 04 24             	mov    %eax,(%esp)
  80222d:	e8 38 01 00 00       	call   80236a <nsipc_accept>
  802232:	85 c0                	test   %eax,%eax
  802234:	78 05                	js     80223b <accept+0x31>
		return r;
	return alloc_sockfd(r);
  802236:	e8 2c ff ff ff       	call   802167 <alloc_sockfd>
}
  80223b:	c9                   	leave  
  80223c:	c3                   	ret    

0080223d <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80223d:	55                   	push   %ebp
  80223e:	89 e5                	mov    %esp,%ebp
  802240:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802243:	8b 45 08             	mov    0x8(%ebp),%eax
  802246:	e8 8d ff ff ff       	call   8021d8 <fd2sockid>
  80224b:	85 c0                	test   %eax,%eax
  80224d:	78 16                	js     802265 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  80224f:	8b 55 10             	mov    0x10(%ebp),%edx
  802252:	89 54 24 08          	mov    %edx,0x8(%esp)
  802256:	8b 55 0c             	mov    0xc(%ebp),%edx
  802259:	89 54 24 04          	mov    %edx,0x4(%esp)
  80225d:	89 04 24             	mov    %eax,(%esp)
  802260:	e8 5b 01 00 00       	call   8023c0 <nsipc_bind>
}
  802265:	c9                   	leave  
  802266:	c3                   	ret    

00802267 <shutdown>:

int
shutdown(int s, int how)
{
  802267:	55                   	push   %ebp
  802268:	89 e5                	mov    %esp,%ebp
  80226a:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80226d:	8b 45 08             	mov    0x8(%ebp),%eax
  802270:	e8 63 ff ff ff       	call   8021d8 <fd2sockid>
  802275:	85 c0                	test   %eax,%eax
  802277:	78 0f                	js     802288 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  802279:	8b 55 0c             	mov    0xc(%ebp),%edx
  80227c:	89 54 24 04          	mov    %edx,0x4(%esp)
  802280:	89 04 24             	mov    %eax,(%esp)
  802283:	e8 77 01 00 00       	call   8023ff <nsipc_shutdown>
}
  802288:	c9                   	leave  
  802289:	c3                   	ret    

0080228a <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80228a:	55                   	push   %ebp
  80228b:	89 e5                	mov    %esp,%ebp
  80228d:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802290:	8b 45 08             	mov    0x8(%ebp),%eax
  802293:	e8 40 ff ff ff       	call   8021d8 <fd2sockid>
  802298:	85 c0                	test   %eax,%eax
  80229a:	78 16                	js     8022b2 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  80229c:	8b 55 10             	mov    0x10(%ebp),%edx
  80229f:	89 54 24 08          	mov    %edx,0x8(%esp)
  8022a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022a6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022aa:	89 04 24             	mov    %eax,(%esp)
  8022ad:	e8 89 01 00 00       	call   80243b <nsipc_connect>
}
  8022b2:	c9                   	leave  
  8022b3:	c3                   	ret    

008022b4 <listen>:

int
listen(int s, int backlog)
{
  8022b4:	55                   	push   %ebp
  8022b5:	89 e5                	mov    %esp,%ebp
  8022b7:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8022ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8022bd:	e8 16 ff ff ff       	call   8021d8 <fd2sockid>
  8022c2:	85 c0                	test   %eax,%eax
  8022c4:	78 0f                	js     8022d5 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8022c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022c9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022cd:	89 04 24             	mov    %eax,(%esp)
  8022d0:	e8 a5 01 00 00       	call   80247a <nsipc_listen>
}
  8022d5:	c9                   	leave  
  8022d6:	c3                   	ret    

008022d7 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8022d7:	55                   	push   %ebp
  8022d8:	89 e5                	mov    %esp,%ebp
  8022da:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8022dd:	8b 45 10             	mov    0x10(%ebp),%eax
  8022e0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8022e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8022ee:	89 04 24             	mov    %eax,(%esp)
  8022f1:	e8 99 02 00 00       	call   80258f <nsipc_socket>
  8022f6:	85 c0                	test   %eax,%eax
  8022f8:	78 05                	js     8022ff <socket+0x28>
		return r;
	return alloc_sockfd(r);
  8022fa:	e8 68 fe ff ff       	call   802167 <alloc_sockfd>
}
  8022ff:	c9                   	leave  
  802300:	c3                   	ret    
  802301:	00 00                	add    %al,(%eax)
	...

00802304 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802304:	55                   	push   %ebp
  802305:	89 e5                	mov    %esp,%ebp
  802307:	53                   	push   %ebx
  802308:	83 ec 14             	sub    $0x14,%esp
  80230b:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80230d:	83 3d 04 60 80 00 00 	cmpl   $0x0,0x806004
  802314:	75 11                	jne    802327 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802316:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  80231d:	e8 49 07 00 00       	call   802a6b <ipc_find_env>
  802322:	a3 04 60 80 00       	mov    %eax,0x806004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802327:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80232e:	00 
  80232f:	c7 44 24 08 00 90 80 	movl   $0x809000,0x8(%esp)
  802336:	00 
  802337:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80233b:	a1 04 60 80 00       	mov    0x806004,%eax
  802340:	89 04 24             	mov    %eax,(%esp)
  802343:	e8 b5 06 00 00       	call   8029fd <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802348:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80234f:	00 
  802350:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802357:	00 
  802358:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80235f:	e8 30 06 00 00       	call   802994 <ipc_recv>
}
  802364:	83 c4 14             	add    $0x14,%esp
  802367:	5b                   	pop    %ebx
  802368:	5d                   	pop    %ebp
  802369:	c3                   	ret    

0080236a <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80236a:	55                   	push   %ebp
  80236b:	89 e5                	mov    %esp,%ebp
  80236d:	56                   	push   %esi
  80236e:	53                   	push   %ebx
  80236f:	83 ec 10             	sub    $0x10,%esp
  802372:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  802375:	8b 45 08             	mov    0x8(%ebp),%eax
  802378:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80237d:	8b 06                	mov    (%esi),%eax
  80237f:	a3 04 90 80 00       	mov    %eax,0x809004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802384:	b8 01 00 00 00       	mov    $0x1,%eax
  802389:	e8 76 ff ff ff       	call   802304 <nsipc>
  80238e:	89 c3                	mov    %eax,%ebx
  802390:	85 c0                	test   %eax,%eax
  802392:	78 23                	js     8023b7 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802394:	a1 10 90 80 00       	mov    0x809010,%eax
  802399:	89 44 24 08          	mov    %eax,0x8(%esp)
  80239d:	c7 44 24 04 00 90 80 	movl   $0x809000,0x4(%esp)
  8023a4:	00 
  8023a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023a8:	89 04 24             	mov    %eax,(%esp)
  8023ab:	e8 ac e8 ff ff       	call   800c5c <memmove>
		*addrlen = ret->ret_addrlen;
  8023b0:	a1 10 90 80 00       	mov    0x809010,%eax
  8023b5:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  8023b7:	89 d8                	mov    %ebx,%eax
  8023b9:	83 c4 10             	add    $0x10,%esp
  8023bc:	5b                   	pop    %ebx
  8023bd:	5e                   	pop    %esi
  8023be:	5d                   	pop    %ebp
  8023bf:	c3                   	ret    

008023c0 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8023c0:	55                   	push   %ebp
  8023c1:	89 e5                	mov    %esp,%ebp
  8023c3:	53                   	push   %ebx
  8023c4:	83 ec 14             	sub    $0x14,%esp
  8023c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8023ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8023cd:	a3 00 90 80 00       	mov    %eax,0x809000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8023d2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023dd:	c7 04 24 04 90 80 00 	movl   $0x809004,(%esp)
  8023e4:	e8 73 e8 ff ff       	call   800c5c <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8023e9:	89 1d 14 90 80 00    	mov    %ebx,0x809014
	return nsipc(NSREQ_BIND);
  8023ef:	b8 02 00 00 00       	mov    $0x2,%eax
  8023f4:	e8 0b ff ff ff       	call   802304 <nsipc>
}
  8023f9:	83 c4 14             	add    $0x14,%esp
  8023fc:	5b                   	pop    %ebx
  8023fd:	5d                   	pop    %ebp
  8023fe:	c3                   	ret    

008023ff <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8023ff:	55                   	push   %ebp
  802400:	89 e5                	mov    %esp,%ebp
  802402:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802405:	8b 45 08             	mov    0x8(%ebp),%eax
  802408:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.shutdown.req_how = how;
  80240d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802410:	a3 04 90 80 00       	mov    %eax,0x809004
	return nsipc(NSREQ_SHUTDOWN);
  802415:	b8 03 00 00 00       	mov    $0x3,%eax
  80241a:	e8 e5 fe ff ff       	call   802304 <nsipc>
}
  80241f:	c9                   	leave  
  802420:	c3                   	ret    

00802421 <nsipc_close>:

int
nsipc_close(int s)
{
  802421:	55                   	push   %ebp
  802422:	89 e5                	mov    %esp,%ebp
  802424:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802427:	8b 45 08             	mov    0x8(%ebp),%eax
  80242a:	a3 00 90 80 00       	mov    %eax,0x809000
	return nsipc(NSREQ_CLOSE);
  80242f:	b8 04 00 00 00       	mov    $0x4,%eax
  802434:	e8 cb fe ff ff       	call   802304 <nsipc>
}
  802439:	c9                   	leave  
  80243a:	c3                   	ret    

0080243b <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80243b:	55                   	push   %ebp
  80243c:	89 e5                	mov    %esp,%ebp
  80243e:	53                   	push   %ebx
  80243f:	83 ec 14             	sub    $0x14,%esp
  802442:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802445:	8b 45 08             	mov    0x8(%ebp),%eax
  802448:	a3 00 90 80 00       	mov    %eax,0x809000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  80244d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802451:	8b 45 0c             	mov    0xc(%ebp),%eax
  802454:	89 44 24 04          	mov    %eax,0x4(%esp)
  802458:	c7 04 24 04 90 80 00 	movl   $0x809004,(%esp)
  80245f:	e8 f8 e7 ff ff       	call   800c5c <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802464:	89 1d 14 90 80 00    	mov    %ebx,0x809014
	return nsipc(NSREQ_CONNECT);
  80246a:	b8 05 00 00 00       	mov    $0x5,%eax
  80246f:	e8 90 fe ff ff       	call   802304 <nsipc>
}
  802474:	83 c4 14             	add    $0x14,%esp
  802477:	5b                   	pop    %ebx
  802478:	5d                   	pop    %ebp
  802479:	c3                   	ret    

0080247a <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  80247a:	55                   	push   %ebp
  80247b:	89 e5                	mov    %esp,%ebp
  80247d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802480:	8b 45 08             	mov    0x8(%ebp),%eax
  802483:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.listen.req_backlog = backlog;
  802488:	8b 45 0c             	mov    0xc(%ebp),%eax
  80248b:	a3 04 90 80 00       	mov    %eax,0x809004
	return nsipc(NSREQ_LISTEN);
  802490:	b8 06 00 00 00       	mov    $0x6,%eax
  802495:	e8 6a fe ff ff       	call   802304 <nsipc>
}
  80249a:	c9                   	leave  
  80249b:	c3                   	ret    

0080249c <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80249c:	55                   	push   %ebp
  80249d:	89 e5                	mov    %esp,%ebp
  80249f:	56                   	push   %esi
  8024a0:	53                   	push   %ebx
  8024a1:	83 ec 10             	sub    $0x10,%esp
  8024a4:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8024a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8024aa:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.recv.req_len = len;
  8024af:	89 35 04 90 80 00    	mov    %esi,0x809004
	nsipcbuf.recv.req_flags = flags;
  8024b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8024b8:	a3 08 90 80 00       	mov    %eax,0x809008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8024bd:	b8 07 00 00 00       	mov    $0x7,%eax
  8024c2:	e8 3d fe ff ff       	call   802304 <nsipc>
  8024c7:	89 c3                	mov    %eax,%ebx
  8024c9:	85 c0                	test   %eax,%eax
  8024cb:	78 46                	js     802513 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  8024cd:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8024d2:	7f 04                	jg     8024d8 <nsipc_recv+0x3c>
  8024d4:	39 c6                	cmp    %eax,%esi
  8024d6:	7d 24                	jge    8024fc <nsipc_recv+0x60>
  8024d8:	c7 44 24 0c a3 33 80 	movl   $0x8033a3,0xc(%esp)
  8024df:	00 
  8024e0:	c7 44 24 08 8b 32 80 	movl   $0x80328b,0x8(%esp)
  8024e7:	00 
  8024e8:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  8024ef:	00 
  8024f0:	c7 04 24 b8 33 80 00 	movl   $0x8033b8,(%esp)
  8024f7:	e8 44 df ff ff       	call   800440 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8024fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  802500:	c7 44 24 04 00 90 80 	movl   $0x809000,0x4(%esp)
  802507:	00 
  802508:	8b 45 0c             	mov    0xc(%ebp),%eax
  80250b:	89 04 24             	mov    %eax,(%esp)
  80250e:	e8 49 e7 ff ff       	call   800c5c <memmove>
	}

	return r;
}
  802513:	89 d8                	mov    %ebx,%eax
  802515:	83 c4 10             	add    $0x10,%esp
  802518:	5b                   	pop    %ebx
  802519:	5e                   	pop    %esi
  80251a:	5d                   	pop    %ebp
  80251b:	c3                   	ret    

0080251c <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80251c:	55                   	push   %ebp
  80251d:	89 e5                	mov    %esp,%ebp
  80251f:	53                   	push   %ebx
  802520:	83 ec 14             	sub    $0x14,%esp
  802523:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802526:	8b 45 08             	mov    0x8(%ebp),%eax
  802529:	a3 00 90 80 00       	mov    %eax,0x809000
	assert(size < 1600);
  80252e:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802534:	7e 24                	jle    80255a <nsipc_send+0x3e>
  802536:	c7 44 24 0c c4 33 80 	movl   $0x8033c4,0xc(%esp)
  80253d:	00 
  80253e:	c7 44 24 08 8b 32 80 	movl   $0x80328b,0x8(%esp)
  802545:	00 
  802546:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  80254d:	00 
  80254e:	c7 04 24 b8 33 80 00 	movl   $0x8033b8,(%esp)
  802555:	e8 e6 de ff ff       	call   800440 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80255a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80255e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802561:	89 44 24 04          	mov    %eax,0x4(%esp)
  802565:	c7 04 24 0c 90 80 00 	movl   $0x80900c,(%esp)
  80256c:	e8 eb e6 ff ff       	call   800c5c <memmove>
	nsipcbuf.send.req_size = size;
  802571:	89 1d 04 90 80 00    	mov    %ebx,0x809004
	nsipcbuf.send.req_flags = flags;
  802577:	8b 45 14             	mov    0x14(%ebp),%eax
  80257a:	a3 08 90 80 00       	mov    %eax,0x809008
	return nsipc(NSREQ_SEND);
  80257f:	b8 08 00 00 00       	mov    $0x8,%eax
  802584:	e8 7b fd ff ff       	call   802304 <nsipc>
}
  802589:	83 c4 14             	add    $0x14,%esp
  80258c:	5b                   	pop    %ebx
  80258d:	5d                   	pop    %ebp
  80258e:	c3                   	ret    

0080258f <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80258f:	55                   	push   %ebp
  802590:	89 e5                	mov    %esp,%ebp
  802592:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802595:	8b 45 08             	mov    0x8(%ebp),%eax
  802598:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.socket.req_type = type;
  80259d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025a0:	a3 04 90 80 00       	mov    %eax,0x809004
	nsipcbuf.socket.req_protocol = protocol;
  8025a5:	8b 45 10             	mov    0x10(%ebp),%eax
  8025a8:	a3 08 90 80 00       	mov    %eax,0x809008
	return nsipc(NSREQ_SOCKET);
  8025ad:	b8 09 00 00 00       	mov    $0x9,%eax
  8025b2:	e8 4d fd ff ff       	call   802304 <nsipc>
}
  8025b7:	c9                   	leave  
  8025b8:	c3                   	ret    
  8025b9:	00 00                	add    %al,(%eax)
	...

008025bc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8025bc:	55                   	push   %ebp
  8025bd:	89 e5                	mov    %esp,%ebp
  8025bf:	56                   	push   %esi
  8025c0:	53                   	push   %ebx
  8025c1:	83 ec 10             	sub    $0x10,%esp
  8025c4:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8025c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8025ca:	89 04 24             	mov    %eax,(%esp)
  8025cd:	e8 fe eb ff ff       	call   8011d0 <fd2data>
  8025d2:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8025d4:	c7 44 24 04 d0 33 80 	movl   $0x8033d0,0x4(%esp)
  8025db:	00 
  8025dc:	89 34 24             	mov    %esi,(%esp)
  8025df:	e8 ff e4 ff ff       	call   800ae3 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8025e4:	8b 43 04             	mov    0x4(%ebx),%eax
  8025e7:	2b 03                	sub    (%ebx),%eax
  8025e9:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8025ef:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8025f6:	00 00 00 
	stat->st_dev = &devpipe;
  8025f9:	c7 86 88 00 00 00 c8 	movl   $0x8057c8,0x88(%esi)
  802600:	57 80 00 
	return 0;
}
  802603:	b8 00 00 00 00       	mov    $0x0,%eax
  802608:	83 c4 10             	add    $0x10,%esp
  80260b:	5b                   	pop    %ebx
  80260c:	5e                   	pop    %esi
  80260d:	5d                   	pop    %ebp
  80260e:	c3                   	ret    

0080260f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80260f:	55                   	push   %ebp
  802610:	89 e5                	mov    %esp,%ebp
  802612:	53                   	push   %ebx
  802613:	83 ec 14             	sub    $0x14,%esp
  802616:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802619:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80261d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802624:	e8 53 e9 ff ff       	call   800f7c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802629:	89 1c 24             	mov    %ebx,(%esp)
  80262c:	e8 9f eb ff ff       	call   8011d0 <fd2data>
  802631:	89 44 24 04          	mov    %eax,0x4(%esp)
  802635:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80263c:	e8 3b e9 ff ff       	call   800f7c <sys_page_unmap>
}
  802641:	83 c4 14             	add    $0x14,%esp
  802644:	5b                   	pop    %ebx
  802645:	5d                   	pop    %ebp
  802646:	c3                   	ret    

00802647 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802647:	55                   	push   %ebp
  802648:	89 e5                	mov    %esp,%ebp
  80264a:	57                   	push   %edi
  80264b:	56                   	push   %esi
  80264c:	53                   	push   %ebx
  80264d:	83 ec 2c             	sub    $0x2c,%esp
  802650:	89 c7                	mov    %eax,%edi
  802652:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802655:	a1 90 77 80 00       	mov    0x807790,%eax
  80265a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80265d:	89 3c 24             	mov    %edi,(%esp)
  802660:	e8 3f 04 00 00       	call   802aa4 <pageref>
  802665:	89 c6                	mov    %eax,%esi
  802667:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80266a:	89 04 24             	mov    %eax,(%esp)
  80266d:	e8 32 04 00 00       	call   802aa4 <pageref>
  802672:	39 c6                	cmp    %eax,%esi
  802674:	0f 94 c0             	sete   %al
  802677:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  80267a:	8b 15 90 77 80 00    	mov    0x807790,%edx
  802680:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802683:	39 cb                	cmp    %ecx,%ebx
  802685:	75 08                	jne    80268f <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  802687:	83 c4 2c             	add    $0x2c,%esp
  80268a:	5b                   	pop    %ebx
  80268b:	5e                   	pop    %esi
  80268c:	5f                   	pop    %edi
  80268d:	5d                   	pop    %ebp
  80268e:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  80268f:	83 f8 01             	cmp    $0x1,%eax
  802692:	75 c1                	jne    802655 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802694:	8b 42 58             	mov    0x58(%edx),%eax
  802697:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  80269e:	00 
  80269f:	89 44 24 08          	mov    %eax,0x8(%esp)
  8026a3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8026a7:	c7 04 24 d7 33 80 00 	movl   $0x8033d7,(%esp)
  8026ae:	e8 85 de ff ff       	call   800538 <cprintf>
  8026b3:	eb a0                	jmp    802655 <_pipeisclosed+0xe>

008026b5 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8026b5:	55                   	push   %ebp
  8026b6:	89 e5                	mov    %esp,%ebp
  8026b8:	57                   	push   %edi
  8026b9:	56                   	push   %esi
  8026ba:	53                   	push   %ebx
  8026bb:	83 ec 1c             	sub    $0x1c,%esp
  8026be:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8026c1:	89 34 24             	mov    %esi,(%esp)
  8026c4:	e8 07 eb ff ff       	call   8011d0 <fd2data>
  8026c9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8026cb:	bf 00 00 00 00       	mov    $0x0,%edi
  8026d0:	eb 3c                	jmp    80270e <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8026d2:	89 da                	mov    %ebx,%edx
  8026d4:	89 f0                	mov    %esi,%eax
  8026d6:	e8 6c ff ff ff       	call   802647 <_pipeisclosed>
  8026db:	85 c0                	test   %eax,%eax
  8026dd:	75 38                	jne    802717 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8026df:	e8 d2 e7 ff ff       	call   800eb6 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8026e4:	8b 43 04             	mov    0x4(%ebx),%eax
  8026e7:	8b 13                	mov    (%ebx),%edx
  8026e9:	83 c2 20             	add    $0x20,%edx
  8026ec:	39 d0                	cmp    %edx,%eax
  8026ee:	73 e2                	jae    8026d2 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8026f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8026f3:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  8026f6:	89 c2                	mov    %eax,%edx
  8026f8:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8026fe:	79 05                	jns    802705 <devpipe_write+0x50>
  802700:	4a                   	dec    %edx
  802701:	83 ca e0             	or     $0xffffffe0,%edx
  802704:	42                   	inc    %edx
  802705:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802709:	40                   	inc    %eax
  80270a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80270d:	47                   	inc    %edi
  80270e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802711:	75 d1                	jne    8026e4 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802713:	89 f8                	mov    %edi,%eax
  802715:	eb 05                	jmp    80271c <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802717:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80271c:	83 c4 1c             	add    $0x1c,%esp
  80271f:	5b                   	pop    %ebx
  802720:	5e                   	pop    %esi
  802721:	5f                   	pop    %edi
  802722:	5d                   	pop    %ebp
  802723:	c3                   	ret    

00802724 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802724:	55                   	push   %ebp
  802725:	89 e5                	mov    %esp,%ebp
  802727:	57                   	push   %edi
  802728:	56                   	push   %esi
  802729:	53                   	push   %ebx
  80272a:	83 ec 1c             	sub    $0x1c,%esp
  80272d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802730:	89 3c 24             	mov    %edi,(%esp)
  802733:	e8 98 ea ff ff       	call   8011d0 <fd2data>
  802738:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80273a:	be 00 00 00 00       	mov    $0x0,%esi
  80273f:	eb 3a                	jmp    80277b <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802741:	85 f6                	test   %esi,%esi
  802743:	74 04                	je     802749 <devpipe_read+0x25>
				return i;
  802745:	89 f0                	mov    %esi,%eax
  802747:	eb 40                	jmp    802789 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802749:	89 da                	mov    %ebx,%edx
  80274b:	89 f8                	mov    %edi,%eax
  80274d:	e8 f5 fe ff ff       	call   802647 <_pipeisclosed>
  802752:	85 c0                	test   %eax,%eax
  802754:	75 2e                	jne    802784 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802756:	e8 5b e7 ff ff       	call   800eb6 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80275b:	8b 03                	mov    (%ebx),%eax
  80275d:	3b 43 04             	cmp    0x4(%ebx),%eax
  802760:	74 df                	je     802741 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802762:	25 1f 00 00 80       	and    $0x8000001f,%eax
  802767:	79 05                	jns    80276e <devpipe_read+0x4a>
  802769:	48                   	dec    %eax
  80276a:	83 c8 e0             	or     $0xffffffe0,%eax
  80276d:	40                   	inc    %eax
  80276e:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  802772:	8b 55 0c             	mov    0xc(%ebp),%edx
  802775:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  802778:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80277a:	46                   	inc    %esi
  80277b:	3b 75 10             	cmp    0x10(%ebp),%esi
  80277e:	75 db                	jne    80275b <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802780:	89 f0                	mov    %esi,%eax
  802782:	eb 05                	jmp    802789 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802784:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802789:	83 c4 1c             	add    $0x1c,%esp
  80278c:	5b                   	pop    %ebx
  80278d:	5e                   	pop    %esi
  80278e:	5f                   	pop    %edi
  80278f:	5d                   	pop    %ebp
  802790:	c3                   	ret    

00802791 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802791:	55                   	push   %ebp
  802792:	89 e5                	mov    %esp,%ebp
  802794:	57                   	push   %edi
  802795:	56                   	push   %esi
  802796:	53                   	push   %ebx
  802797:	83 ec 3c             	sub    $0x3c,%esp
  80279a:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80279d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8027a0:	89 04 24             	mov    %eax,(%esp)
  8027a3:	e8 43 ea ff ff       	call   8011eb <fd_alloc>
  8027a8:	89 c3                	mov    %eax,%ebx
  8027aa:	85 c0                	test   %eax,%eax
  8027ac:	0f 88 45 01 00 00    	js     8028f7 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8027b2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8027b9:	00 
  8027ba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8027bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8027c8:	e8 08 e7 ff ff       	call   800ed5 <sys_page_alloc>
  8027cd:	89 c3                	mov    %eax,%ebx
  8027cf:	85 c0                	test   %eax,%eax
  8027d1:	0f 88 20 01 00 00    	js     8028f7 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8027d7:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8027da:	89 04 24             	mov    %eax,(%esp)
  8027dd:	e8 09 ea ff ff       	call   8011eb <fd_alloc>
  8027e2:	89 c3                	mov    %eax,%ebx
  8027e4:	85 c0                	test   %eax,%eax
  8027e6:	0f 88 f8 00 00 00    	js     8028e4 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8027ec:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8027f3:	00 
  8027f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8027f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802802:	e8 ce e6 ff ff       	call   800ed5 <sys_page_alloc>
  802807:	89 c3                	mov    %eax,%ebx
  802809:	85 c0                	test   %eax,%eax
  80280b:	0f 88 d3 00 00 00    	js     8028e4 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802811:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802814:	89 04 24             	mov    %eax,(%esp)
  802817:	e8 b4 e9 ff ff       	call   8011d0 <fd2data>
  80281c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80281e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802825:	00 
  802826:	89 44 24 04          	mov    %eax,0x4(%esp)
  80282a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802831:	e8 9f e6 ff ff       	call   800ed5 <sys_page_alloc>
  802836:	89 c3                	mov    %eax,%ebx
  802838:	85 c0                	test   %eax,%eax
  80283a:	0f 88 91 00 00 00    	js     8028d1 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802840:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802843:	89 04 24             	mov    %eax,(%esp)
  802846:	e8 85 e9 ff ff       	call   8011d0 <fd2data>
  80284b:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802852:	00 
  802853:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802857:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80285e:	00 
  80285f:	89 74 24 04          	mov    %esi,0x4(%esp)
  802863:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80286a:	e8 ba e6 ff ff       	call   800f29 <sys_page_map>
  80286f:	89 c3                	mov    %eax,%ebx
  802871:	85 c0                	test   %eax,%eax
  802873:	78 4c                	js     8028c1 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802875:	8b 15 c8 57 80 00    	mov    0x8057c8,%edx
  80287b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80287e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802880:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802883:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80288a:	8b 15 c8 57 80 00    	mov    0x8057c8,%edx
  802890:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802893:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802895:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802898:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80289f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8028a2:	89 04 24             	mov    %eax,(%esp)
  8028a5:	e8 16 e9 ff ff       	call   8011c0 <fd2num>
  8028aa:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8028ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8028af:	89 04 24             	mov    %eax,(%esp)
  8028b2:	e8 09 e9 ff ff       	call   8011c0 <fd2num>
  8028b7:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8028ba:	bb 00 00 00 00       	mov    $0x0,%ebx
  8028bf:	eb 36                	jmp    8028f7 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  8028c1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8028c5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8028cc:	e8 ab e6 ff ff       	call   800f7c <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8028d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8028d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8028d8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8028df:	e8 98 e6 ff ff       	call   800f7c <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8028e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8028e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8028eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8028f2:	e8 85 e6 ff ff       	call   800f7c <sys_page_unmap>
    err:
	return r;
}
  8028f7:	89 d8                	mov    %ebx,%eax
  8028f9:	83 c4 3c             	add    $0x3c,%esp
  8028fc:	5b                   	pop    %ebx
  8028fd:	5e                   	pop    %esi
  8028fe:	5f                   	pop    %edi
  8028ff:	5d                   	pop    %ebp
  802900:	c3                   	ret    

00802901 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802901:	55                   	push   %ebp
  802902:	89 e5                	mov    %esp,%ebp
  802904:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802907:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80290a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80290e:	8b 45 08             	mov    0x8(%ebp),%eax
  802911:	89 04 24             	mov    %eax,(%esp)
  802914:	e8 25 e9 ff ff       	call   80123e <fd_lookup>
  802919:	85 c0                	test   %eax,%eax
  80291b:	78 15                	js     802932 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80291d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802920:	89 04 24             	mov    %eax,(%esp)
  802923:	e8 a8 e8 ff ff       	call   8011d0 <fd2data>
	return _pipeisclosed(fd, p);
  802928:	89 c2                	mov    %eax,%edx
  80292a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80292d:	e8 15 fd ff ff       	call   802647 <_pipeisclosed>
}
  802932:	c9                   	leave  
  802933:	c3                   	ret    

00802934 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802934:	55                   	push   %ebp
  802935:	89 e5                	mov    %esp,%ebp
  802937:	56                   	push   %esi
  802938:	53                   	push   %ebx
  802939:	83 ec 10             	sub    $0x10,%esp
  80293c:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  80293f:	85 f6                	test   %esi,%esi
  802941:	75 24                	jne    802967 <wait+0x33>
  802943:	c7 44 24 0c ef 33 80 	movl   $0x8033ef,0xc(%esp)
  80294a:	00 
  80294b:	c7 44 24 08 8b 32 80 	movl   $0x80328b,0x8(%esp)
  802952:	00 
  802953:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  80295a:	00 
  80295b:	c7 04 24 fa 33 80 00 	movl   $0x8033fa,(%esp)
  802962:	e8 d9 da ff ff       	call   800440 <_panic>
	e = &envs[ENVX(envid)];
  802967:	89 f3                	mov    %esi,%ebx
  802969:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  80296f:	c1 e3 07             	shl    $0x7,%ebx
  802972:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802978:	eb 05                	jmp    80297f <wait+0x4b>
		sys_yield();
  80297a:	e8 37 e5 ff ff       	call   800eb6 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80297f:	8b 43 48             	mov    0x48(%ebx),%eax
  802982:	39 f0                	cmp    %esi,%eax
  802984:	75 07                	jne    80298d <wait+0x59>
  802986:	8b 43 54             	mov    0x54(%ebx),%eax
  802989:	85 c0                	test   %eax,%eax
  80298b:	75 ed                	jne    80297a <wait+0x46>
		sys_yield();
}
  80298d:	83 c4 10             	add    $0x10,%esp
  802990:	5b                   	pop    %ebx
  802991:	5e                   	pop    %esi
  802992:	5d                   	pop    %ebp
  802993:	c3                   	ret    

00802994 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802994:	55                   	push   %ebp
  802995:	89 e5                	mov    %esp,%ebp
  802997:	56                   	push   %esi
  802998:	53                   	push   %ebx
  802999:	83 ec 10             	sub    $0x10,%esp
  80299c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80299f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8029a2:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int r;
		
	r = sys_ipc_recv(pg?pg:(void*)UTOP);
  8029a5:	85 c0                	test   %eax,%eax
  8029a7:	75 05                	jne    8029ae <ipc_recv+0x1a>
  8029a9:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8029ae:	89 04 24             	mov    %eax,(%esp)
  8029b1:	e8 35 e7 ff ff       	call   8010eb <sys_ipc_recv>
	if (from_env_store != NULL)
  8029b6:	85 db                	test   %ebx,%ebx
  8029b8:	74 0b                	je     8029c5 <ipc_recv+0x31>
		*from_env_store = thisenv->env_ipc_from; 
  8029ba:	8b 15 90 77 80 00    	mov    0x807790,%edx
  8029c0:	8b 52 74             	mov    0x74(%edx),%edx
  8029c3:	89 13                	mov    %edx,(%ebx)
	if (perm_store != NULL)
  8029c5:	85 f6                	test   %esi,%esi
  8029c7:	74 0b                	je     8029d4 <ipc_recv+0x40>
		*perm_store = thisenv->env_ipc_perm;
  8029c9:	8b 15 90 77 80 00    	mov    0x807790,%edx
  8029cf:	8b 52 78             	mov    0x78(%edx),%edx
  8029d2:	89 16                	mov    %edx,(%esi)
	
	if (r < 0){
  8029d4:	85 c0                	test   %eax,%eax
  8029d6:	79 16                	jns    8029ee <ipc_recv+0x5a>
		if(from_env_store != NULL)
  8029d8:	85 db                	test   %ebx,%ebx
  8029da:	74 06                	je     8029e2 <ipc_recv+0x4e>
			*from_env_store = 0;
  8029dc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store != NULL)	
  8029e2:	85 f6                	test   %esi,%esi
  8029e4:	74 10                	je     8029f6 <ipc_recv+0x62>
			*perm_store = 0;
  8029e6:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8029ec:	eb 08                	jmp    8029f6 <ipc_recv+0x62>
		return r;
	}
	
	return thisenv->env_ipc_value;
  8029ee:	a1 90 77 80 00       	mov    0x807790,%eax
  8029f3:	8b 40 70             	mov    0x70(%eax),%eax
}
  8029f6:	83 c4 10             	add    $0x10,%esp
  8029f9:	5b                   	pop    %ebx
  8029fa:	5e                   	pop    %esi
  8029fb:	5d                   	pop    %ebp
  8029fc:	c3                   	ret    

008029fd <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8029fd:	55                   	push   %ebp
  8029fe:	89 e5                	mov    %esp,%ebp
  802a00:	57                   	push   %edi
  802a01:	56                   	push   %esi
  802a02:	53                   	push   %ebx
  802a03:	83 ec 1c             	sub    $0x1c,%esp
  802a06:	8b 75 08             	mov    0x8(%ebp),%esi
  802a09:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802a0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  802a0f:	eb 2a                	jmp    802a3b <ipc_send+0x3e>
		if (r != -E_IPC_NOT_RECV)
  802a11:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802a14:	74 20                	je     802a36 <ipc_send+0x39>
			panic("ipc_send: sys_ipc_try_send failed %e", r);
  802a16:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802a1a:	c7 44 24 08 08 34 80 	movl   $0x803408,0x8(%esp)
  802a21:	00 
  802a22:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  802a29:	00 
  802a2a:	c7 04 24 30 34 80 00 	movl   $0x803430,(%esp)
  802a31:	e8 0a da ff ff       	call   800440 <_panic>
		sys_yield();
  802a36:	e8 7b e4 ff ff       	call   800eb6 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  802a3b:	85 db                	test   %ebx,%ebx
  802a3d:	75 07                	jne    802a46 <ipc_send+0x49>
  802a3f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802a44:	eb 02                	jmp    802a48 <ipc_send+0x4b>
  802a46:	89 d8                	mov    %ebx,%eax
  802a48:	8b 55 14             	mov    0x14(%ebp),%edx
  802a4b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802a4f:	89 44 24 08          	mov    %eax,0x8(%esp)
  802a53:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802a57:	89 34 24             	mov    %esi,(%esp)
  802a5a:	e8 69 e6 ff ff       	call   8010c8 <sys_ipc_try_send>
  802a5f:	85 c0                	test   %eax,%eax
  802a61:	78 ae                	js     802a11 <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: sys_ipc_try_send failed %e", r);
		sys_yield();
	}
}
  802a63:	83 c4 1c             	add    $0x1c,%esp
  802a66:	5b                   	pop    %ebx
  802a67:	5e                   	pop    %esi
  802a68:	5f                   	pop    %edi
  802a69:	5d                   	pop    %ebp
  802a6a:	c3                   	ret    

00802a6b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802a6b:	55                   	push   %ebp
  802a6c:	89 e5                	mov    %esp,%ebp
  802a6e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802a71:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802a76:	89 c2                	mov    %eax,%edx
  802a78:	c1 e2 07             	shl    $0x7,%edx
  802a7b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802a81:	8b 52 50             	mov    0x50(%edx),%edx
  802a84:	39 ca                	cmp    %ecx,%edx
  802a86:	75 0d                	jne    802a95 <ipc_find_env+0x2a>
			return envs[i].env_id;
  802a88:	c1 e0 07             	shl    $0x7,%eax
  802a8b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802a90:	8b 40 40             	mov    0x40(%eax),%eax
  802a93:	eb 0c                	jmp    802aa1 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802a95:	40                   	inc    %eax
  802a96:	3d 00 04 00 00       	cmp    $0x400,%eax
  802a9b:	75 d9                	jne    802a76 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802a9d:	66 b8 00 00          	mov    $0x0,%ax
}
  802aa1:	5d                   	pop    %ebp
  802aa2:	c3                   	ret    
	...

00802aa4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802aa4:	55                   	push   %ebp
  802aa5:	89 e5                	mov    %esp,%ebp
  802aa7:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802aaa:	89 c2                	mov    %eax,%edx
  802aac:	c1 ea 16             	shr    $0x16,%edx
  802aaf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802ab6:	f6 c2 01             	test   $0x1,%dl
  802ab9:	74 1e                	je     802ad9 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802abb:	c1 e8 0c             	shr    $0xc,%eax
  802abe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802ac5:	a8 01                	test   $0x1,%al
  802ac7:	74 17                	je     802ae0 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802ac9:	c1 e8 0c             	shr    $0xc,%eax
  802acc:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802ad3:	ef 
  802ad4:	0f b7 c0             	movzwl %ax,%eax
  802ad7:	eb 0c                	jmp    802ae5 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802ad9:	b8 00 00 00 00       	mov    $0x0,%eax
  802ade:	eb 05                	jmp    802ae5 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802ae0:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802ae5:	5d                   	pop    %ebp
  802ae6:	c3                   	ret    
	...

00802ae8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802ae8:	55                   	push   %ebp
  802ae9:	57                   	push   %edi
  802aea:	56                   	push   %esi
  802aeb:	83 ec 10             	sub    $0x10,%esp
  802aee:	8b 74 24 20          	mov    0x20(%esp),%esi
  802af2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802af6:	89 74 24 04          	mov    %esi,0x4(%esp)
  802afa:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  802afe:	89 cd                	mov    %ecx,%ebp
  802b00:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802b04:	85 c0                	test   %eax,%eax
  802b06:	75 2c                	jne    802b34 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802b08:	39 f9                	cmp    %edi,%ecx
  802b0a:	77 68                	ja     802b74 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802b0c:	85 c9                	test   %ecx,%ecx
  802b0e:	75 0b                	jne    802b1b <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802b10:	b8 01 00 00 00       	mov    $0x1,%eax
  802b15:	31 d2                	xor    %edx,%edx
  802b17:	f7 f1                	div    %ecx
  802b19:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802b1b:	31 d2                	xor    %edx,%edx
  802b1d:	89 f8                	mov    %edi,%eax
  802b1f:	f7 f1                	div    %ecx
  802b21:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802b23:	89 f0                	mov    %esi,%eax
  802b25:	f7 f1                	div    %ecx
  802b27:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802b29:	89 f0                	mov    %esi,%eax
  802b2b:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802b2d:	83 c4 10             	add    $0x10,%esp
  802b30:	5e                   	pop    %esi
  802b31:	5f                   	pop    %edi
  802b32:	5d                   	pop    %ebp
  802b33:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802b34:	39 f8                	cmp    %edi,%eax
  802b36:	77 2c                	ja     802b64 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802b38:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  802b3b:	83 f6 1f             	xor    $0x1f,%esi
  802b3e:	75 4c                	jne    802b8c <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802b40:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802b42:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802b47:	72 0a                	jb     802b53 <__udivdi3+0x6b>
  802b49:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802b4d:	0f 87 ad 00 00 00    	ja     802c00 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802b53:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802b58:	89 f0                	mov    %esi,%eax
  802b5a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802b5c:	83 c4 10             	add    $0x10,%esp
  802b5f:	5e                   	pop    %esi
  802b60:	5f                   	pop    %edi
  802b61:	5d                   	pop    %ebp
  802b62:	c3                   	ret    
  802b63:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802b64:	31 ff                	xor    %edi,%edi
  802b66:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802b68:	89 f0                	mov    %esi,%eax
  802b6a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802b6c:	83 c4 10             	add    $0x10,%esp
  802b6f:	5e                   	pop    %esi
  802b70:	5f                   	pop    %edi
  802b71:	5d                   	pop    %ebp
  802b72:	c3                   	ret    
  802b73:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802b74:	89 fa                	mov    %edi,%edx
  802b76:	89 f0                	mov    %esi,%eax
  802b78:	f7 f1                	div    %ecx
  802b7a:	89 c6                	mov    %eax,%esi
  802b7c:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802b7e:	89 f0                	mov    %esi,%eax
  802b80:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802b82:	83 c4 10             	add    $0x10,%esp
  802b85:	5e                   	pop    %esi
  802b86:	5f                   	pop    %edi
  802b87:	5d                   	pop    %ebp
  802b88:	c3                   	ret    
  802b89:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802b8c:	89 f1                	mov    %esi,%ecx
  802b8e:	d3 e0                	shl    %cl,%eax
  802b90:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802b94:	b8 20 00 00 00       	mov    $0x20,%eax
  802b99:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802b9b:	89 ea                	mov    %ebp,%edx
  802b9d:	88 c1                	mov    %al,%cl
  802b9f:	d3 ea                	shr    %cl,%edx
  802ba1:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802ba5:	09 ca                	or     %ecx,%edx
  802ba7:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  802bab:	89 f1                	mov    %esi,%ecx
  802bad:	d3 e5                	shl    %cl,%ebp
  802baf:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  802bb3:	89 fd                	mov    %edi,%ebp
  802bb5:	88 c1                	mov    %al,%cl
  802bb7:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802bb9:	89 fa                	mov    %edi,%edx
  802bbb:	89 f1                	mov    %esi,%ecx
  802bbd:	d3 e2                	shl    %cl,%edx
  802bbf:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802bc3:	88 c1                	mov    %al,%cl
  802bc5:	d3 ef                	shr    %cl,%edi
  802bc7:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802bc9:	89 f8                	mov    %edi,%eax
  802bcb:	89 ea                	mov    %ebp,%edx
  802bcd:	f7 74 24 08          	divl   0x8(%esp)
  802bd1:	89 d1                	mov    %edx,%ecx
  802bd3:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802bd5:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802bd9:	39 d1                	cmp    %edx,%ecx
  802bdb:	72 17                	jb     802bf4 <__udivdi3+0x10c>
  802bdd:	74 09                	je     802be8 <__udivdi3+0x100>
  802bdf:	89 fe                	mov    %edi,%esi
  802be1:	31 ff                	xor    %edi,%edi
  802be3:	e9 41 ff ff ff       	jmp    802b29 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802be8:	8b 54 24 04          	mov    0x4(%esp),%edx
  802bec:	89 f1                	mov    %esi,%ecx
  802bee:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802bf0:	39 c2                	cmp    %eax,%edx
  802bf2:	73 eb                	jae    802bdf <__udivdi3+0xf7>
		{
		  q0--;
  802bf4:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802bf7:	31 ff                	xor    %edi,%edi
  802bf9:	e9 2b ff ff ff       	jmp    802b29 <__udivdi3+0x41>
  802bfe:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802c00:	31 f6                	xor    %esi,%esi
  802c02:	e9 22 ff ff ff       	jmp    802b29 <__udivdi3+0x41>
	...

00802c08 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802c08:	55                   	push   %ebp
  802c09:	57                   	push   %edi
  802c0a:	56                   	push   %esi
  802c0b:	83 ec 20             	sub    $0x20,%esp
  802c0e:	8b 44 24 30          	mov    0x30(%esp),%eax
  802c12:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802c16:	89 44 24 14          	mov    %eax,0x14(%esp)
  802c1a:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  802c1e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802c22:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802c26:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802c28:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802c2a:	85 ed                	test   %ebp,%ebp
  802c2c:	75 16                	jne    802c44 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  802c2e:	39 f1                	cmp    %esi,%ecx
  802c30:	0f 86 a6 00 00 00    	jbe    802cdc <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802c36:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802c38:	89 d0                	mov    %edx,%eax
  802c3a:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802c3c:	83 c4 20             	add    $0x20,%esp
  802c3f:	5e                   	pop    %esi
  802c40:	5f                   	pop    %edi
  802c41:	5d                   	pop    %ebp
  802c42:	c3                   	ret    
  802c43:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802c44:	39 f5                	cmp    %esi,%ebp
  802c46:	0f 87 ac 00 00 00    	ja     802cf8 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802c4c:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  802c4f:	83 f0 1f             	xor    $0x1f,%eax
  802c52:	89 44 24 10          	mov    %eax,0x10(%esp)
  802c56:	0f 84 a8 00 00 00    	je     802d04 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802c5c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802c60:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802c62:	bf 20 00 00 00       	mov    $0x20,%edi
  802c67:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802c6b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802c6f:	89 f9                	mov    %edi,%ecx
  802c71:	d3 e8                	shr    %cl,%eax
  802c73:	09 e8                	or     %ebp,%eax
  802c75:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  802c79:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802c7d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802c81:	d3 e0                	shl    %cl,%eax
  802c83:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802c87:	89 f2                	mov    %esi,%edx
  802c89:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802c8b:	8b 44 24 14          	mov    0x14(%esp),%eax
  802c8f:	d3 e0                	shl    %cl,%eax
  802c91:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802c95:	8b 44 24 14          	mov    0x14(%esp),%eax
  802c99:	89 f9                	mov    %edi,%ecx
  802c9b:	d3 e8                	shr    %cl,%eax
  802c9d:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802c9f:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802ca1:	89 f2                	mov    %esi,%edx
  802ca3:	f7 74 24 18          	divl   0x18(%esp)
  802ca7:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802ca9:	f7 64 24 0c          	mull   0xc(%esp)
  802cad:	89 c5                	mov    %eax,%ebp
  802caf:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802cb1:	39 d6                	cmp    %edx,%esi
  802cb3:	72 67                	jb     802d1c <__umoddi3+0x114>
  802cb5:	74 75                	je     802d2c <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802cb7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802cbb:	29 e8                	sub    %ebp,%eax
  802cbd:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802cbf:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802cc3:	d3 e8                	shr    %cl,%eax
  802cc5:	89 f2                	mov    %esi,%edx
  802cc7:	89 f9                	mov    %edi,%ecx
  802cc9:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802ccb:	09 d0                	or     %edx,%eax
  802ccd:	89 f2                	mov    %esi,%edx
  802ccf:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802cd3:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802cd5:	83 c4 20             	add    $0x20,%esp
  802cd8:	5e                   	pop    %esi
  802cd9:	5f                   	pop    %edi
  802cda:	5d                   	pop    %ebp
  802cdb:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802cdc:	85 c9                	test   %ecx,%ecx
  802cde:	75 0b                	jne    802ceb <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802ce0:	b8 01 00 00 00       	mov    $0x1,%eax
  802ce5:	31 d2                	xor    %edx,%edx
  802ce7:	f7 f1                	div    %ecx
  802ce9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802ceb:	89 f0                	mov    %esi,%eax
  802ced:	31 d2                	xor    %edx,%edx
  802cef:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802cf1:	89 f8                	mov    %edi,%eax
  802cf3:	e9 3e ff ff ff       	jmp    802c36 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802cf8:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802cfa:	83 c4 20             	add    $0x20,%esp
  802cfd:	5e                   	pop    %esi
  802cfe:	5f                   	pop    %edi
  802cff:	5d                   	pop    %ebp
  802d00:	c3                   	ret    
  802d01:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802d04:	39 f5                	cmp    %esi,%ebp
  802d06:	72 04                	jb     802d0c <__umoddi3+0x104>
  802d08:	39 f9                	cmp    %edi,%ecx
  802d0a:	77 06                	ja     802d12 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802d0c:	89 f2                	mov    %esi,%edx
  802d0e:	29 cf                	sub    %ecx,%edi
  802d10:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802d12:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802d14:	83 c4 20             	add    $0x20,%esp
  802d17:	5e                   	pop    %esi
  802d18:	5f                   	pop    %edi
  802d19:	5d                   	pop    %ebp
  802d1a:	c3                   	ret    
  802d1b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802d1c:	89 d1                	mov    %edx,%ecx
  802d1e:	89 c5                	mov    %eax,%ebp
  802d20:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802d24:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802d28:	eb 8d                	jmp    802cb7 <__umoddi3+0xaf>
  802d2a:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802d2c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802d30:	72 ea                	jb     802d1c <__umoddi3+0x114>
  802d32:	89 f1                	mov    %esi,%ecx
  802d34:	eb 81                	jmp    802cb7 <__umoddi3+0xaf>
