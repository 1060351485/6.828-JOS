
obj/user/testkbd.debug:     file format elf32-i386


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
  80002c:	e8 8b 02 00 00       	call   8002bc <libmain>
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
  800037:	53                   	push   %ebx
  800038:	83 ec 14             	sub    $0x14,%esp
  80003b:	bb 0a 00 00 00       	mov    $0xa,%ebx
	int i, r;

	// Spin for a bit to let the console quiet
	for (i = 0; i < 10; ++i)
		sys_yield();
  800040:	e8 35 0e 00 00       	call   800e7a <sys_yield>
umain(int argc, char **argv)
{
	int i, r;

	// Spin for a bit to let the console quiet
	for (i = 0; i < 10; ++i)
  800045:	4b                   	dec    %ebx
  800046:	75 f8                	jne    800040 <umain+0xc>
		sys_yield();

	close(0);
  800048:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80004f:	e8 66 12 00 00       	call   8012ba <close>
	if ((r = opencons()) < 0)
  800054:	e8 0f 02 00 00       	call   800268 <opencons>
  800059:	85 c0                	test   %eax,%eax
  80005b:	79 20                	jns    80007d <umain+0x49>
		panic("opencons: %e", r);
  80005d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800061:	c7 44 24 08 00 22 80 	movl   $0x802200,0x8(%esp)
  800068:	00 
  800069:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  800070:	00 
  800071:	c7 04 24 0d 22 80 00 	movl   $0x80220d,(%esp)
  800078:	e8 a7 02 00 00       	call   800324 <_panic>
	if (r != 0)
  80007d:	85 c0                	test   %eax,%eax
  80007f:	74 20                	je     8000a1 <umain+0x6d>
		panic("first opencons used fd %d", r);
  800081:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800085:	c7 44 24 08 1c 22 80 	movl   $0x80221c,0x8(%esp)
  80008c:	00 
  80008d:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800094:	00 
  800095:	c7 04 24 0d 22 80 00 	movl   $0x80220d,(%esp)
  80009c:	e8 83 02 00 00       	call   800324 <_panic>
	if ((r = dup(0, 1)) < 0)
  8000a1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8000a8:	00 
  8000a9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b0:	e8 56 12 00 00       	call   80130b <dup>
  8000b5:	85 c0                	test   %eax,%eax
  8000b7:	79 20                	jns    8000d9 <umain+0xa5>
		panic("dup: %e", r);
  8000b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000bd:	c7 44 24 08 36 22 80 	movl   $0x802236,0x8(%esp)
  8000c4:	00 
  8000c5:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
  8000cc:	00 
  8000cd:	c7 04 24 0d 22 80 00 	movl   $0x80220d,(%esp)
  8000d4:	e8 4b 02 00 00       	call   800324 <_panic>

	for(;;){
		char *buf;

		buf = readline("Type a line: ");
  8000d9:	c7 04 24 3e 22 80 00 	movl   $0x80223e,(%esp)
  8000e0:	e8 af 08 00 00       	call   800994 <readline>
		if (buf != NULL)
  8000e5:	85 c0                	test   %eax,%eax
  8000e7:	74 1a                	je     800103 <umain+0xcf>
			fprintf(1, "%s\n", buf);
  8000e9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000ed:	c7 44 24 04 4c 22 80 	movl   $0x80224c,0x4(%esp)
  8000f4:	00 
  8000f5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8000fc:	e8 87 19 00 00       	call   801a88 <fprintf>
  800101:	eb d6                	jmp    8000d9 <umain+0xa5>
		else
			fprintf(1, "(end of file received)\n");
  800103:	c7 44 24 04 50 22 80 	movl   $0x802250,0x4(%esp)
  80010a:	00 
  80010b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800112:	e8 71 19 00 00       	call   801a88 <fprintf>
  800117:	eb c0                	jmp    8000d9 <umain+0xa5>
  800119:	00 00                	add    %al,(%eax)
	...

0080011c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80011f:	b8 00 00 00 00       	mov    $0x0,%eax
  800124:	5d                   	pop    %ebp
  800125:	c3                   	ret    

00800126 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800126:	55                   	push   %ebp
  800127:	89 e5                	mov    %esp,%ebp
  800129:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  80012c:	c7 44 24 04 68 22 80 	movl   $0x802268,0x4(%esp)
  800133:	00 
  800134:	8b 45 0c             	mov    0xc(%ebp),%eax
  800137:	89 04 24             	mov    %eax,(%esp)
  80013a:	e8 68 09 00 00       	call   800aa7 <strcpy>
	return 0;
}
  80013f:	b8 00 00 00 00       	mov    $0x0,%eax
  800144:	c9                   	leave  
  800145:	c3                   	ret    

00800146 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800146:	55                   	push   %ebp
  800147:	89 e5                	mov    %esp,%ebp
  800149:	57                   	push   %edi
  80014a:	56                   	push   %esi
  80014b:	53                   	push   %ebx
  80014c:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800152:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800157:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80015d:	eb 30                	jmp    80018f <devcons_write+0x49>
		m = n - tot;
  80015f:	8b 75 10             	mov    0x10(%ebp),%esi
  800162:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  800164:	83 fe 7f             	cmp    $0x7f,%esi
  800167:	76 05                	jbe    80016e <devcons_write+0x28>
			m = sizeof(buf) - 1;
  800169:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80016e:	89 74 24 08          	mov    %esi,0x8(%esp)
  800172:	03 45 0c             	add    0xc(%ebp),%eax
  800175:	89 44 24 04          	mov    %eax,0x4(%esp)
  800179:	89 3c 24             	mov    %edi,(%esp)
  80017c:	e8 9f 0a 00 00       	call   800c20 <memmove>
		sys_cputs(buf, m);
  800181:	89 74 24 04          	mov    %esi,0x4(%esp)
  800185:	89 3c 24             	mov    %edi,(%esp)
  800188:	e8 3f 0c 00 00       	call   800dcc <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80018d:	01 f3                	add    %esi,%ebx
  80018f:	89 d8                	mov    %ebx,%eax
  800191:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800194:	72 c9                	jb     80015f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800196:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  80019c:	5b                   	pop    %ebx
  80019d:	5e                   	pop    %esi
  80019e:	5f                   	pop    %edi
  80019f:	5d                   	pop    %ebp
  8001a0:	c3                   	ret    

008001a1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8001a7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8001ab:	75 07                	jne    8001b4 <devcons_read+0x13>
  8001ad:	eb 25                	jmp    8001d4 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8001af:	e8 c6 0c 00 00       	call   800e7a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8001b4:	e8 31 0c 00 00       	call   800dea <sys_cgetc>
  8001b9:	85 c0                	test   %eax,%eax
  8001bb:	74 f2                	je     8001af <devcons_read+0xe>
  8001bd:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8001bf:	85 c0                	test   %eax,%eax
  8001c1:	78 1d                	js     8001e0 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8001c3:	83 f8 04             	cmp    $0x4,%eax
  8001c6:	74 13                	je     8001db <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8001c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001cb:	88 10                	mov    %dl,(%eax)
	return 1;
  8001cd:	b8 01 00 00 00       	mov    $0x1,%eax
  8001d2:	eb 0c                	jmp    8001e0 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8001d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8001d9:	eb 05                	jmp    8001e0 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8001db:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8001e0:	c9                   	leave  
  8001e1:	c3                   	ret    

008001e2 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8001e2:	55                   	push   %ebp
  8001e3:	89 e5                	mov    %esp,%ebp
  8001e5:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8001e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8001eb:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8001ee:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8001f5:	00 
  8001f6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8001f9:	89 04 24             	mov    %eax,(%esp)
  8001fc:	e8 cb 0b 00 00       	call   800dcc <sys_cputs>
}
  800201:	c9                   	leave  
  800202:	c3                   	ret    

00800203 <getchar>:

int
getchar(void)
{
  800203:	55                   	push   %ebp
  800204:	89 e5                	mov    %esp,%ebp
  800206:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800209:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  800210:	00 
  800211:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800214:	89 44 24 04          	mov    %eax,0x4(%esp)
  800218:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80021f:	e8 fa 11 00 00       	call   80141e <read>
	if (r < 0)
  800224:	85 c0                	test   %eax,%eax
  800226:	78 0f                	js     800237 <getchar+0x34>
		return r;
	if (r < 1)
  800228:	85 c0                	test   %eax,%eax
  80022a:	7e 06                	jle    800232 <getchar+0x2f>
		return -E_EOF;
	return c;
  80022c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800230:	eb 05                	jmp    800237 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800232:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800237:	c9                   	leave  
  800238:	c3                   	ret    

00800239 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800239:	55                   	push   %ebp
  80023a:	89 e5                	mov    %esp,%ebp
  80023c:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80023f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800242:	89 44 24 04          	mov    %eax,0x4(%esp)
  800246:	8b 45 08             	mov    0x8(%ebp),%eax
  800249:	89 04 24             	mov    %eax,(%esp)
  80024c:	e8 31 0f 00 00       	call   801182 <fd_lookup>
  800251:	85 c0                	test   %eax,%eax
  800253:	78 11                	js     800266 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800255:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800258:	8b 15 00 30 80 00    	mov    0x803000,%edx
  80025e:	39 10                	cmp    %edx,(%eax)
  800260:	0f 94 c0             	sete   %al
  800263:	0f b6 c0             	movzbl %al,%eax
}
  800266:	c9                   	leave  
  800267:	c3                   	ret    

00800268 <opencons>:

int
opencons(void)
{
  800268:	55                   	push   %ebp
  800269:	89 e5                	mov    %esp,%ebp
  80026b:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80026e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800271:	89 04 24             	mov    %eax,(%esp)
  800274:	e8 b6 0e 00 00       	call   80112f <fd_alloc>
  800279:	85 c0                	test   %eax,%eax
  80027b:	78 3c                	js     8002b9 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80027d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800284:	00 
  800285:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800288:	89 44 24 04          	mov    %eax,0x4(%esp)
  80028c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800293:	e8 01 0c 00 00       	call   800e99 <sys_page_alloc>
  800298:	85 c0                	test   %eax,%eax
  80029a:	78 1d                	js     8002b9 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80029c:	8b 15 00 30 80 00    	mov    0x803000,%edx
  8002a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8002a5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8002a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8002aa:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8002b1:	89 04 24             	mov    %eax,(%esp)
  8002b4:	e8 4b 0e 00 00       	call   801104 <fd2num>
}
  8002b9:	c9                   	leave  
  8002ba:	c3                   	ret    
	...

008002bc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	56                   	push   %esi
  8002c0:	53                   	push   %ebx
  8002c1:	83 ec 10             	sub    $0x10,%esp
  8002c4:	8b 75 08             	mov    0x8(%ebp),%esi
  8002c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8002ca:	e8 8c 0b 00 00       	call   800e5b <sys_getenvid>
  8002cf:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002d4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8002db:	c1 e0 07             	shl    $0x7,%eax
  8002de:	29 d0                	sub    %edx,%eax
  8002e0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002e5:	a3 04 44 80 00       	mov    %eax,0x804404

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002ea:	85 f6                	test   %esi,%esi
  8002ec:	7e 07                	jle    8002f5 <libmain+0x39>
		binaryname = argv[0];
  8002ee:	8b 03                	mov    (%ebx),%eax
  8002f0:	a3 1c 30 80 00       	mov    %eax,0x80301c

	// call user main routine
	umain(argc, argv);
  8002f5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002f9:	89 34 24             	mov    %esi,(%esp)
  8002fc:	e8 33 fd ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800301:	e8 0a 00 00 00       	call   800310 <exit>
}
  800306:	83 c4 10             	add    $0x10,%esp
  800309:	5b                   	pop    %ebx
  80030a:	5e                   	pop    %esi
  80030b:	5d                   	pop    %ebp
  80030c:	c3                   	ret    
  80030d:	00 00                	add    %al,(%eax)
	...

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
  80031d:	e8 e7 0a 00 00       	call   800e09 <sys_env_destroy>
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
  80032f:	8b 1d 1c 30 80 00    	mov    0x80301c,%ebx
  800335:	e8 21 0b 00 00       	call   800e5b <sys_getenvid>
  80033a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80033d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800341:	8b 55 08             	mov    0x8(%ebp),%edx
  800344:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800348:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80034c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800350:	c7 04 24 80 22 80 00 	movl   $0x802280,(%esp)
  800357:	e8 c0 00 00 00       	call   80041c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80035c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800360:	8b 45 10             	mov    0x10(%ebp),%eax
  800363:	89 04 24             	mov    %eax,(%esp)
  800366:	e8 50 00 00 00       	call   8003bb <vcprintf>
	cprintf("\n");
  80036b:	c7 04 24 66 22 80 00 	movl   $0x802266,(%esp)
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
  8003a7:	e8 20 0a 00 00       	call   800dcc <sys_cputs>
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
  80040f:	e8 b8 09 00 00       	call   800dcc <sys_cputs>

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
  800491:	e8 0e 1b 00 00       	call   801fa4 <__udivdi3>
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
  8004e4:	e8 db 1b 00 00       	call   8020c4 <__umoddi3>
  8004e9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004ed:	0f be 80 a3 22 80 00 	movsbl 0x8022a3(%eax),%eax
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
  800608:	ff 24 95 e0 23 80 00 	jmp    *0x8023e0(,%edx,4)
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
  800691:	83 f8 0f             	cmp    $0xf,%eax
  800694:	7f 0b                	jg     8006a1 <vprintfmt+0x123>
  800696:	8b 04 85 40 25 80 00 	mov    0x802540(,%eax,4),%eax
  80069d:	85 c0                	test   %eax,%eax
  80069f:	75 23                	jne    8006c4 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8006a1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006a5:	c7 44 24 08 bb 22 80 	movl   $0x8022bb,0x8(%esp)
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
  8006c8:	c7 44 24 08 81 26 80 	movl   $0x802681,0x8(%esp)
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
  8006fe:	be b4 22 80 00       	mov    $0x8022b4,%esi
			if (width > 0 && padc != '-')
  800703:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800707:	0f 8e 84 00 00 00    	jle    800791 <vprintfmt+0x213>
  80070d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800711:	74 7e                	je     800791 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800713:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800717:	89 34 24             	mov    %esi,(%esp)
  80071a:	e8 6b 03 00 00       	call   800a8a <strnlen>
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

00800994 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
  800997:	57                   	push   %edi
  800998:	56                   	push   %esi
  800999:	53                   	push   %ebx
  80099a:	83 ec 1c             	sub    $0x1c,%esp
  80099d:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  8009a0:	85 c0                	test   %eax,%eax
  8009a2:	74 18                	je     8009bc <readline+0x28>
		fprintf(1, "%s", prompt);
  8009a4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009a8:	c7 44 24 04 81 26 80 	movl   $0x802681,0x4(%esp)
  8009af:	00 
  8009b0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8009b7:	e8 cc 10 00 00       	call   801a88 <fprintf>
#endif

	i = 0;
	echoing = iscons(0);
  8009bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8009c3:	e8 71 f8 ff ff       	call   800239 <iscons>
  8009c8:	89 c7                	mov    %eax,%edi
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  8009ca:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  8009cf:	e8 2f f8 ff ff       	call   800203 <getchar>
  8009d4:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  8009d6:	85 c0                	test   %eax,%eax
  8009d8:	79 20                	jns    8009fa <readline+0x66>
			if (c != -E_EOF)
  8009da:	83 f8 f8             	cmp    $0xfffffff8,%eax
  8009dd:	0f 84 82 00 00 00    	je     800a65 <readline+0xd1>
				cprintf("read error: %e\n", c);
  8009e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009e7:	c7 04 24 9f 25 80 00 	movl   $0x80259f,(%esp)
  8009ee:	e8 29 fa ff ff       	call   80041c <cprintf>
			return NULL;
  8009f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f8:	eb 70                	jmp    800a6a <readline+0xd6>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  8009fa:	83 f8 08             	cmp    $0x8,%eax
  8009fd:	74 05                	je     800a04 <readline+0x70>
  8009ff:	83 f8 7f             	cmp    $0x7f,%eax
  800a02:	75 17                	jne    800a1b <readline+0x87>
  800a04:	85 f6                	test   %esi,%esi
  800a06:	7e 13                	jle    800a1b <readline+0x87>
			if (echoing)
  800a08:	85 ff                	test   %edi,%edi
  800a0a:	74 0c                	je     800a18 <readline+0x84>
				cputchar('\b');
  800a0c:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  800a13:	e8 ca f7 ff ff       	call   8001e2 <cputchar>
			i--;
  800a18:	4e                   	dec    %esi
  800a19:	eb b4                	jmp    8009cf <readline+0x3b>
		} else if (c >= ' ' && i < BUFLEN-1) {
  800a1b:	83 fb 1f             	cmp    $0x1f,%ebx
  800a1e:	7e 1d                	jle    800a3d <readline+0xa9>
  800a20:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  800a26:	7f 15                	jg     800a3d <readline+0xa9>
			if (echoing)
  800a28:	85 ff                	test   %edi,%edi
  800a2a:	74 08                	je     800a34 <readline+0xa0>
				cputchar(c);
  800a2c:	89 1c 24             	mov    %ebx,(%esp)
  800a2f:	e8 ae f7 ff ff       	call   8001e2 <cputchar>
			buf[i++] = c;
  800a34:	88 9e 00 40 80 00    	mov    %bl,0x804000(%esi)
  800a3a:	46                   	inc    %esi
  800a3b:	eb 92                	jmp    8009cf <readline+0x3b>
		} else if (c == '\n' || c == '\r') {
  800a3d:	83 fb 0a             	cmp    $0xa,%ebx
  800a40:	74 05                	je     800a47 <readline+0xb3>
  800a42:	83 fb 0d             	cmp    $0xd,%ebx
  800a45:	75 88                	jne    8009cf <readline+0x3b>
			if (echoing)
  800a47:	85 ff                	test   %edi,%edi
  800a49:	74 0c                	je     800a57 <readline+0xc3>
				cputchar('\n');
  800a4b:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800a52:	e8 8b f7 ff ff       	call   8001e2 <cputchar>
			buf[i] = 0;
  800a57:	c6 86 00 40 80 00 00 	movb   $0x0,0x804000(%esi)
			return buf;
  800a5e:	b8 00 40 80 00       	mov    $0x804000,%eax
  800a63:	eb 05                	jmp    800a6a <readline+0xd6>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  800a65:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
  800a6a:	83 c4 1c             	add    $0x1c,%esp
  800a6d:	5b                   	pop    %ebx
  800a6e:	5e                   	pop    %esi
  800a6f:	5f                   	pop    %edi
  800a70:	5d                   	pop    %ebp
  800a71:	c3                   	ret    
	...

00800a74 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a74:	55                   	push   %ebp
  800a75:	89 e5                	mov    %esp,%ebp
  800a77:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a7a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7f:	eb 01                	jmp    800a82 <strlen+0xe>
		n++;
  800a81:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a82:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a86:	75 f9                	jne    800a81 <strlen+0xd>
		n++;
	return n;
}
  800a88:	5d                   	pop    %ebp
  800a89:	c3                   	ret    

00800a8a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a8a:	55                   	push   %ebp
  800a8b:	89 e5                	mov    %esp,%ebp
  800a8d:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800a90:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a93:	b8 00 00 00 00       	mov    $0x0,%eax
  800a98:	eb 01                	jmp    800a9b <strnlen+0x11>
		n++;
  800a9a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a9b:	39 d0                	cmp    %edx,%eax
  800a9d:	74 06                	je     800aa5 <strnlen+0x1b>
  800a9f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800aa3:	75 f5                	jne    800a9a <strnlen+0x10>
		n++;
	return n;
}
  800aa5:	5d                   	pop    %ebp
  800aa6:	c3                   	ret    

00800aa7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800aa7:	55                   	push   %ebp
  800aa8:	89 e5                	mov    %esp,%ebp
  800aaa:	53                   	push   %ebx
  800aab:	8b 45 08             	mov    0x8(%ebp),%eax
  800aae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ab1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab6:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800ab9:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800abc:	42                   	inc    %edx
  800abd:	84 c9                	test   %cl,%cl
  800abf:	75 f5                	jne    800ab6 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800ac1:	5b                   	pop    %ebx
  800ac2:	5d                   	pop    %ebp
  800ac3:	c3                   	ret    

00800ac4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800ac4:	55                   	push   %ebp
  800ac5:	89 e5                	mov    %esp,%ebp
  800ac7:	53                   	push   %ebx
  800ac8:	83 ec 08             	sub    $0x8,%esp
  800acb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ace:	89 1c 24             	mov    %ebx,(%esp)
  800ad1:	e8 9e ff ff ff       	call   800a74 <strlen>
	strcpy(dst + len, src);
  800ad6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ad9:	89 54 24 04          	mov    %edx,0x4(%esp)
  800add:	01 d8                	add    %ebx,%eax
  800adf:	89 04 24             	mov    %eax,(%esp)
  800ae2:	e8 c0 ff ff ff       	call   800aa7 <strcpy>
	return dst;
}
  800ae7:	89 d8                	mov    %ebx,%eax
  800ae9:	83 c4 08             	add    $0x8,%esp
  800aec:	5b                   	pop    %ebx
  800aed:	5d                   	pop    %ebp
  800aee:	c3                   	ret    

00800aef <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800aef:	55                   	push   %ebp
  800af0:	89 e5                	mov    %esp,%ebp
  800af2:	56                   	push   %esi
  800af3:	53                   	push   %ebx
  800af4:	8b 45 08             	mov    0x8(%ebp),%eax
  800af7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800afa:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800afd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b02:	eb 0c                	jmp    800b10 <strncpy+0x21>
		*dst++ = *src;
  800b04:	8a 1a                	mov    (%edx),%bl
  800b06:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b09:	80 3a 01             	cmpb   $0x1,(%edx)
  800b0c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b0f:	41                   	inc    %ecx
  800b10:	39 f1                	cmp    %esi,%ecx
  800b12:	75 f0                	jne    800b04 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b14:	5b                   	pop    %ebx
  800b15:	5e                   	pop    %esi
  800b16:	5d                   	pop    %ebp
  800b17:	c3                   	ret    

00800b18 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b18:	55                   	push   %ebp
  800b19:	89 e5                	mov    %esp,%ebp
  800b1b:	56                   	push   %esi
  800b1c:	53                   	push   %ebx
  800b1d:	8b 75 08             	mov    0x8(%ebp),%esi
  800b20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b23:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b26:	85 d2                	test   %edx,%edx
  800b28:	75 0a                	jne    800b34 <strlcpy+0x1c>
  800b2a:	89 f0                	mov    %esi,%eax
  800b2c:	eb 1a                	jmp    800b48 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b2e:	88 18                	mov    %bl,(%eax)
  800b30:	40                   	inc    %eax
  800b31:	41                   	inc    %ecx
  800b32:	eb 02                	jmp    800b36 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b34:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800b36:	4a                   	dec    %edx
  800b37:	74 0a                	je     800b43 <strlcpy+0x2b>
  800b39:	8a 19                	mov    (%ecx),%bl
  800b3b:	84 db                	test   %bl,%bl
  800b3d:	75 ef                	jne    800b2e <strlcpy+0x16>
  800b3f:	89 c2                	mov    %eax,%edx
  800b41:	eb 02                	jmp    800b45 <strlcpy+0x2d>
  800b43:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800b45:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800b48:	29 f0                	sub    %esi,%eax
}
  800b4a:	5b                   	pop    %ebx
  800b4b:	5e                   	pop    %esi
  800b4c:	5d                   	pop    %ebp
  800b4d:	c3                   	ret    

00800b4e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b4e:	55                   	push   %ebp
  800b4f:	89 e5                	mov    %esp,%ebp
  800b51:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b54:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b57:	eb 02                	jmp    800b5b <strcmp+0xd>
		p++, q++;
  800b59:	41                   	inc    %ecx
  800b5a:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b5b:	8a 01                	mov    (%ecx),%al
  800b5d:	84 c0                	test   %al,%al
  800b5f:	74 04                	je     800b65 <strcmp+0x17>
  800b61:	3a 02                	cmp    (%edx),%al
  800b63:	74 f4                	je     800b59 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b65:	0f b6 c0             	movzbl %al,%eax
  800b68:	0f b6 12             	movzbl (%edx),%edx
  800b6b:	29 d0                	sub    %edx,%eax
}
  800b6d:	5d                   	pop    %ebp
  800b6e:	c3                   	ret    

00800b6f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b6f:	55                   	push   %ebp
  800b70:	89 e5                	mov    %esp,%ebp
  800b72:	53                   	push   %ebx
  800b73:	8b 45 08             	mov    0x8(%ebp),%eax
  800b76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b79:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800b7c:	eb 03                	jmp    800b81 <strncmp+0x12>
		n--, p++, q++;
  800b7e:	4a                   	dec    %edx
  800b7f:	40                   	inc    %eax
  800b80:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b81:	85 d2                	test   %edx,%edx
  800b83:	74 14                	je     800b99 <strncmp+0x2a>
  800b85:	8a 18                	mov    (%eax),%bl
  800b87:	84 db                	test   %bl,%bl
  800b89:	74 04                	je     800b8f <strncmp+0x20>
  800b8b:	3a 19                	cmp    (%ecx),%bl
  800b8d:	74 ef                	je     800b7e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b8f:	0f b6 00             	movzbl (%eax),%eax
  800b92:	0f b6 11             	movzbl (%ecx),%edx
  800b95:	29 d0                	sub    %edx,%eax
  800b97:	eb 05                	jmp    800b9e <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b99:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b9e:	5b                   	pop    %ebx
  800b9f:	5d                   	pop    %ebp
  800ba0:	c3                   	ret    

00800ba1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ba1:	55                   	push   %ebp
  800ba2:	89 e5                	mov    %esp,%ebp
  800ba4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba7:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800baa:	eb 05                	jmp    800bb1 <strchr+0x10>
		if (*s == c)
  800bac:	38 ca                	cmp    %cl,%dl
  800bae:	74 0c                	je     800bbc <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800bb0:	40                   	inc    %eax
  800bb1:	8a 10                	mov    (%eax),%dl
  800bb3:	84 d2                	test   %dl,%dl
  800bb5:	75 f5                	jne    800bac <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800bb7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bbc:	5d                   	pop    %ebp
  800bbd:	c3                   	ret    

00800bbe <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bbe:	55                   	push   %ebp
  800bbf:	89 e5                	mov    %esp,%ebp
  800bc1:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc4:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800bc7:	eb 05                	jmp    800bce <strfind+0x10>
		if (*s == c)
  800bc9:	38 ca                	cmp    %cl,%dl
  800bcb:	74 07                	je     800bd4 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800bcd:	40                   	inc    %eax
  800bce:	8a 10                	mov    (%eax),%dl
  800bd0:	84 d2                	test   %dl,%dl
  800bd2:	75 f5                	jne    800bc9 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800bd4:	5d                   	pop    %ebp
  800bd5:	c3                   	ret    

00800bd6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	57                   	push   %edi
  800bda:	56                   	push   %esi
  800bdb:	53                   	push   %ebx
  800bdc:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bdf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800be2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800be5:	85 c9                	test   %ecx,%ecx
  800be7:	74 30                	je     800c19 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800be9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bef:	75 25                	jne    800c16 <memset+0x40>
  800bf1:	f6 c1 03             	test   $0x3,%cl
  800bf4:	75 20                	jne    800c16 <memset+0x40>
		c &= 0xFF;
  800bf6:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bf9:	89 d3                	mov    %edx,%ebx
  800bfb:	c1 e3 08             	shl    $0x8,%ebx
  800bfe:	89 d6                	mov    %edx,%esi
  800c00:	c1 e6 18             	shl    $0x18,%esi
  800c03:	89 d0                	mov    %edx,%eax
  800c05:	c1 e0 10             	shl    $0x10,%eax
  800c08:	09 f0                	or     %esi,%eax
  800c0a:	09 d0                	or     %edx,%eax
  800c0c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c0e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800c11:	fc                   	cld    
  800c12:	f3 ab                	rep stos %eax,%es:(%edi)
  800c14:	eb 03                	jmp    800c19 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c16:	fc                   	cld    
  800c17:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c19:	89 f8                	mov    %edi,%eax
  800c1b:	5b                   	pop    %ebx
  800c1c:	5e                   	pop    %esi
  800c1d:	5f                   	pop    %edi
  800c1e:	5d                   	pop    %ebp
  800c1f:	c3                   	ret    

00800c20 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c20:	55                   	push   %ebp
  800c21:	89 e5                	mov    %esp,%ebp
  800c23:	57                   	push   %edi
  800c24:	56                   	push   %esi
  800c25:	8b 45 08             	mov    0x8(%ebp),%eax
  800c28:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c2b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c2e:	39 c6                	cmp    %eax,%esi
  800c30:	73 34                	jae    800c66 <memmove+0x46>
  800c32:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c35:	39 d0                	cmp    %edx,%eax
  800c37:	73 2d                	jae    800c66 <memmove+0x46>
		s += n;
		d += n;
  800c39:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c3c:	f6 c2 03             	test   $0x3,%dl
  800c3f:	75 1b                	jne    800c5c <memmove+0x3c>
  800c41:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c47:	75 13                	jne    800c5c <memmove+0x3c>
  800c49:	f6 c1 03             	test   $0x3,%cl
  800c4c:	75 0e                	jne    800c5c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c4e:	83 ef 04             	sub    $0x4,%edi
  800c51:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c54:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c57:	fd                   	std    
  800c58:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c5a:	eb 07                	jmp    800c63 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c5c:	4f                   	dec    %edi
  800c5d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c60:	fd                   	std    
  800c61:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c63:	fc                   	cld    
  800c64:	eb 20                	jmp    800c86 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c66:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c6c:	75 13                	jne    800c81 <memmove+0x61>
  800c6e:	a8 03                	test   $0x3,%al
  800c70:	75 0f                	jne    800c81 <memmove+0x61>
  800c72:	f6 c1 03             	test   $0x3,%cl
  800c75:	75 0a                	jne    800c81 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c77:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c7a:	89 c7                	mov    %eax,%edi
  800c7c:	fc                   	cld    
  800c7d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c7f:	eb 05                	jmp    800c86 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c81:	89 c7                	mov    %eax,%edi
  800c83:	fc                   	cld    
  800c84:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c86:	5e                   	pop    %esi
  800c87:	5f                   	pop    %edi
  800c88:	5d                   	pop    %ebp
  800c89:	c3                   	ret    

00800c8a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
  800c8d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c90:	8b 45 10             	mov    0x10(%ebp),%eax
  800c93:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c97:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c9a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca1:	89 04 24             	mov    %eax,(%esp)
  800ca4:	e8 77 ff ff ff       	call   800c20 <memmove>
}
  800ca9:	c9                   	leave  
  800caa:	c3                   	ret    

00800cab <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cab:	55                   	push   %ebp
  800cac:	89 e5                	mov    %esp,%ebp
  800cae:	57                   	push   %edi
  800caf:	56                   	push   %esi
  800cb0:	53                   	push   %ebx
  800cb1:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cb4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cb7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cba:	ba 00 00 00 00       	mov    $0x0,%edx
  800cbf:	eb 16                	jmp    800cd7 <memcmp+0x2c>
		if (*s1 != *s2)
  800cc1:	8a 04 17             	mov    (%edi,%edx,1),%al
  800cc4:	42                   	inc    %edx
  800cc5:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800cc9:	38 c8                	cmp    %cl,%al
  800ccb:	74 0a                	je     800cd7 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800ccd:	0f b6 c0             	movzbl %al,%eax
  800cd0:	0f b6 c9             	movzbl %cl,%ecx
  800cd3:	29 c8                	sub    %ecx,%eax
  800cd5:	eb 09                	jmp    800ce0 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cd7:	39 da                	cmp    %ebx,%edx
  800cd9:	75 e6                	jne    800cc1 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800cdb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ce0:	5b                   	pop    %ebx
  800ce1:	5e                   	pop    %esi
  800ce2:	5f                   	pop    %edi
  800ce3:	5d                   	pop    %ebp
  800ce4:	c3                   	ret    

00800ce5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ce5:	55                   	push   %ebp
  800ce6:	89 e5                	mov    %esp,%ebp
  800ce8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ceb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800cee:	89 c2                	mov    %eax,%edx
  800cf0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cf3:	eb 05                	jmp    800cfa <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cf5:	38 08                	cmp    %cl,(%eax)
  800cf7:	74 05                	je     800cfe <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cf9:	40                   	inc    %eax
  800cfa:	39 d0                	cmp    %edx,%eax
  800cfc:	72 f7                	jb     800cf5 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800cfe:	5d                   	pop    %ebp
  800cff:	c3                   	ret    

00800d00 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d00:	55                   	push   %ebp
  800d01:	89 e5                	mov    %esp,%ebp
  800d03:	57                   	push   %edi
  800d04:	56                   	push   %esi
  800d05:	53                   	push   %ebx
  800d06:	8b 55 08             	mov    0x8(%ebp),%edx
  800d09:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d0c:	eb 01                	jmp    800d0f <strtol+0xf>
		s++;
  800d0e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d0f:	8a 02                	mov    (%edx),%al
  800d11:	3c 20                	cmp    $0x20,%al
  800d13:	74 f9                	je     800d0e <strtol+0xe>
  800d15:	3c 09                	cmp    $0x9,%al
  800d17:	74 f5                	je     800d0e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d19:	3c 2b                	cmp    $0x2b,%al
  800d1b:	75 08                	jne    800d25 <strtol+0x25>
		s++;
  800d1d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d1e:	bf 00 00 00 00       	mov    $0x0,%edi
  800d23:	eb 13                	jmp    800d38 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d25:	3c 2d                	cmp    $0x2d,%al
  800d27:	75 0a                	jne    800d33 <strtol+0x33>
		s++, neg = 1;
  800d29:	8d 52 01             	lea    0x1(%edx),%edx
  800d2c:	bf 01 00 00 00       	mov    $0x1,%edi
  800d31:	eb 05                	jmp    800d38 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d33:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d38:	85 db                	test   %ebx,%ebx
  800d3a:	74 05                	je     800d41 <strtol+0x41>
  800d3c:	83 fb 10             	cmp    $0x10,%ebx
  800d3f:	75 28                	jne    800d69 <strtol+0x69>
  800d41:	8a 02                	mov    (%edx),%al
  800d43:	3c 30                	cmp    $0x30,%al
  800d45:	75 10                	jne    800d57 <strtol+0x57>
  800d47:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d4b:	75 0a                	jne    800d57 <strtol+0x57>
		s += 2, base = 16;
  800d4d:	83 c2 02             	add    $0x2,%edx
  800d50:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d55:	eb 12                	jmp    800d69 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800d57:	85 db                	test   %ebx,%ebx
  800d59:	75 0e                	jne    800d69 <strtol+0x69>
  800d5b:	3c 30                	cmp    $0x30,%al
  800d5d:	75 05                	jne    800d64 <strtol+0x64>
		s++, base = 8;
  800d5f:	42                   	inc    %edx
  800d60:	b3 08                	mov    $0x8,%bl
  800d62:	eb 05                	jmp    800d69 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800d64:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800d69:	b8 00 00 00 00       	mov    $0x0,%eax
  800d6e:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d70:	8a 0a                	mov    (%edx),%cl
  800d72:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d75:	80 fb 09             	cmp    $0x9,%bl
  800d78:	77 08                	ja     800d82 <strtol+0x82>
			dig = *s - '0';
  800d7a:	0f be c9             	movsbl %cl,%ecx
  800d7d:	83 e9 30             	sub    $0x30,%ecx
  800d80:	eb 1e                	jmp    800da0 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800d82:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d85:	80 fb 19             	cmp    $0x19,%bl
  800d88:	77 08                	ja     800d92 <strtol+0x92>
			dig = *s - 'a' + 10;
  800d8a:	0f be c9             	movsbl %cl,%ecx
  800d8d:	83 e9 57             	sub    $0x57,%ecx
  800d90:	eb 0e                	jmp    800da0 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800d92:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d95:	80 fb 19             	cmp    $0x19,%bl
  800d98:	77 12                	ja     800dac <strtol+0xac>
			dig = *s - 'A' + 10;
  800d9a:	0f be c9             	movsbl %cl,%ecx
  800d9d:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800da0:	39 f1                	cmp    %esi,%ecx
  800da2:	7d 0c                	jge    800db0 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800da4:	42                   	inc    %edx
  800da5:	0f af c6             	imul   %esi,%eax
  800da8:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800daa:	eb c4                	jmp    800d70 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800dac:	89 c1                	mov    %eax,%ecx
  800dae:	eb 02                	jmp    800db2 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800db0:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800db2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800db6:	74 05                	je     800dbd <strtol+0xbd>
		*endptr = (char *) s;
  800db8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800dbb:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800dbd:	85 ff                	test   %edi,%edi
  800dbf:	74 04                	je     800dc5 <strtol+0xc5>
  800dc1:	89 c8                	mov    %ecx,%eax
  800dc3:	f7 d8                	neg    %eax
}
  800dc5:	5b                   	pop    %ebx
  800dc6:	5e                   	pop    %esi
  800dc7:	5f                   	pop    %edi
  800dc8:	5d                   	pop    %ebp
  800dc9:	c3                   	ret    
	...

00800dcc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800dcc:	55                   	push   %ebp
  800dcd:	89 e5                	mov    %esp,%ebp
  800dcf:	57                   	push   %edi
  800dd0:	56                   	push   %esi
  800dd1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd2:	b8 00 00 00 00       	mov    $0x0,%eax
  800dd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dda:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddd:	89 c3                	mov    %eax,%ebx
  800ddf:	89 c7                	mov    %eax,%edi
  800de1:	89 c6                	mov    %eax,%esi
  800de3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800de5:	5b                   	pop    %ebx
  800de6:	5e                   	pop    %esi
  800de7:	5f                   	pop    %edi
  800de8:	5d                   	pop    %ebp
  800de9:	c3                   	ret    

00800dea <sys_cgetc>:

int
sys_cgetc(void)
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
  800df5:	b8 01 00 00 00       	mov    $0x1,%eax
  800dfa:	89 d1                	mov    %edx,%ecx
  800dfc:	89 d3                	mov    %edx,%ebx
  800dfe:	89 d7                	mov    %edx,%edi
  800e00:	89 d6                	mov    %edx,%esi
  800e02:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e04:	5b                   	pop    %ebx
  800e05:	5e                   	pop    %esi
  800e06:	5f                   	pop    %edi
  800e07:	5d                   	pop    %ebp
  800e08:	c3                   	ret    

00800e09 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800e12:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e17:	b8 03 00 00 00       	mov    $0x3,%eax
  800e1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1f:	89 cb                	mov    %ecx,%ebx
  800e21:	89 cf                	mov    %ecx,%edi
  800e23:	89 ce                	mov    %ecx,%esi
  800e25:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e27:	85 c0                	test   %eax,%eax
  800e29:	7e 28                	jle    800e53 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e2f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800e36:	00 
  800e37:	c7 44 24 08 af 25 80 	movl   $0x8025af,0x8(%esp)
  800e3e:	00 
  800e3f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e46:	00 
  800e47:	c7 04 24 cc 25 80 00 	movl   $0x8025cc,(%esp)
  800e4e:	e8 d1 f4 ff ff       	call   800324 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e53:	83 c4 2c             	add    $0x2c,%esp
  800e56:	5b                   	pop    %ebx
  800e57:	5e                   	pop    %esi
  800e58:	5f                   	pop    %edi
  800e59:	5d                   	pop    %ebp
  800e5a:	c3                   	ret    

00800e5b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e5b:	55                   	push   %ebp
  800e5c:	89 e5                	mov    %esp,%ebp
  800e5e:	57                   	push   %edi
  800e5f:	56                   	push   %esi
  800e60:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e61:	ba 00 00 00 00       	mov    $0x0,%edx
  800e66:	b8 02 00 00 00       	mov    $0x2,%eax
  800e6b:	89 d1                	mov    %edx,%ecx
  800e6d:	89 d3                	mov    %edx,%ebx
  800e6f:	89 d7                	mov    %edx,%edi
  800e71:	89 d6                	mov    %edx,%esi
  800e73:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e75:	5b                   	pop    %ebx
  800e76:	5e                   	pop    %esi
  800e77:	5f                   	pop    %edi
  800e78:	5d                   	pop    %ebp
  800e79:	c3                   	ret    

00800e7a <sys_yield>:

void
sys_yield(void)
{
  800e7a:	55                   	push   %ebp
  800e7b:	89 e5                	mov    %esp,%ebp
  800e7d:	57                   	push   %edi
  800e7e:	56                   	push   %esi
  800e7f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e80:	ba 00 00 00 00       	mov    $0x0,%edx
  800e85:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e8a:	89 d1                	mov    %edx,%ecx
  800e8c:	89 d3                	mov    %edx,%ebx
  800e8e:	89 d7                	mov    %edx,%edi
  800e90:	89 d6                	mov    %edx,%esi
  800e92:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e94:	5b                   	pop    %ebx
  800e95:	5e                   	pop    %esi
  800e96:	5f                   	pop    %edi
  800e97:	5d                   	pop    %ebp
  800e98:	c3                   	ret    

00800e99 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e99:	55                   	push   %ebp
  800e9a:	89 e5                	mov    %esp,%ebp
  800e9c:	57                   	push   %edi
  800e9d:	56                   	push   %esi
  800e9e:	53                   	push   %ebx
  800e9f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea2:	be 00 00 00 00       	mov    $0x0,%esi
  800ea7:	b8 04 00 00 00       	mov    $0x4,%eax
  800eac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eaf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb5:	89 f7                	mov    %esi,%edi
  800eb7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eb9:	85 c0                	test   %eax,%eax
  800ebb:	7e 28                	jle    800ee5 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ebd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ec1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800ec8:	00 
  800ec9:	c7 44 24 08 af 25 80 	movl   $0x8025af,0x8(%esp)
  800ed0:	00 
  800ed1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ed8:	00 
  800ed9:	c7 04 24 cc 25 80 00 	movl   $0x8025cc,(%esp)
  800ee0:	e8 3f f4 ff ff       	call   800324 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ee5:	83 c4 2c             	add    $0x2c,%esp
  800ee8:	5b                   	pop    %ebx
  800ee9:	5e                   	pop    %esi
  800eea:	5f                   	pop    %edi
  800eeb:	5d                   	pop    %ebp
  800eec:	c3                   	ret    

00800eed <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800eed:	55                   	push   %ebp
  800eee:	89 e5                	mov    %esp,%ebp
  800ef0:	57                   	push   %edi
  800ef1:	56                   	push   %esi
  800ef2:	53                   	push   %ebx
  800ef3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef6:	b8 05 00 00 00       	mov    $0x5,%eax
  800efb:	8b 75 18             	mov    0x18(%ebp),%esi
  800efe:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f01:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f07:	8b 55 08             	mov    0x8(%ebp),%edx
  800f0a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f0c:	85 c0                	test   %eax,%eax
  800f0e:	7e 28                	jle    800f38 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f10:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f14:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f1b:	00 
  800f1c:	c7 44 24 08 af 25 80 	movl   $0x8025af,0x8(%esp)
  800f23:	00 
  800f24:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f2b:	00 
  800f2c:	c7 04 24 cc 25 80 00 	movl   $0x8025cc,(%esp)
  800f33:	e8 ec f3 ff ff       	call   800324 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f38:	83 c4 2c             	add    $0x2c,%esp
  800f3b:	5b                   	pop    %ebx
  800f3c:	5e                   	pop    %esi
  800f3d:	5f                   	pop    %edi
  800f3e:	5d                   	pop    %ebp
  800f3f:	c3                   	ret    

00800f40 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f40:	55                   	push   %ebp
  800f41:	89 e5                	mov    %esp,%ebp
  800f43:	57                   	push   %edi
  800f44:	56                   	push   %esi
  800f45:	53                   	push   %ebx
  800f46:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f49:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f4e:	b8 06 00 00 00       	mov    $0x6,%eax
  800f53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f56:	8b 55 08             	mov    0x8(%ebp),%edx
  800f59:	89 df                	mov    %ebx,%edi
  800f5b:	89 de                	mov    %ebx,%esi
  800f5d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f5f:	85 c0                	test   %eax,%eax
  800f61:	7e 28                	jle    800f8b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f63:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f67:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f6e:	00 
  800f6f:	c7 44 24 08 af 25 80 	movl   $0x8025af,0x8(%esp)
  800f76:	00 
  800f77:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f7e:	00 
  800f7f:	c7 04 24 cc 25 80 00 	movl   $0x8025cc,(%esp)
  800f86:	e8 99 f3 ff ff       	call   800324 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f8b:	83 c4 2c             	add    $0x2c,%esp
  800f8e:	5b                   	pop    %ebx
  800f8f:	5e                   	pop    %esi
  800f90:	5f                   	pop    %edi
  800f91:	5d                   	pop    %ebp
  800f92:	c3                   	ret    

00800f93 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f93:	55                   	push   %ebp
  800f94:	89 e5                	mov    %esp,%ebp
  800f96:	57                   	push   %edi
  800f97:	56                   	push   %esi
  800f98:	53                   	push   %ebx
  800f99:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f9c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fa1:	b8 08 00 00 00       	mov    $0x8,%eax
  800fa6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa9:	8b 55 08             	mov    0x8(%ebp),%edx
  800fac:	89 df                	mov    %ebx,%edi
  800fae:	89 de                	mov    %ebx,%esi
  800fb0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fb2:	85 c0                	test   %eax,%eax
  800fb4:	7e 28                	jle    800fde <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fb6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fba:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800fc1:	00 
  800fc2:	c7 44 24 08 af 25 80 	movl   $0x8025af,0x8(%esp)
  800fc9:	00 
  800fca:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fd1:	00 
  800fd2:	c7 04 24 cc 25 80 00 	movl   $0x8025cc,(%esp)
  800fd9:	e8 46 f3 ff ff       	call   800324 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800fde:	83 c4 2c             	add    $0x2c,%esp
  800fe1:	5b                   	pop    %ebx
  800fe2:	5e                   	pop    %esi
  800fe3:	5f                   	pop    %edi
  800fe4:	5d                   	pop    %ebp
  800fe5:	c3                   	ret    

00800fe6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800fe6:	55                   	push   %ebp
  800fe7:	89 e5                	mov    %esp,%ebp
  800fe9:	57                   	push   %edi
  800fea:	56                   	push   %esi
  800feb:	53                   	push   %ebx
  800fec:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fef:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ff4:	b8 09 00 00 00       	mov    $0x9,%eax
  800ff9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ffc:	8b 55 08             	mov    0x8(%ebp),%edx
  800fff:	89 df                	mov    %ebx,%edi
  801001:	89 de                	mov    %ebx,%esi
  801003:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801005:	85 c0                	test   %eax,%eax
  801007:	7e 28                	jle    801031 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801009:	89 44 24 10          	mov    %eax,0x10(%esp)
  80100d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801014:	00 
  801015:	c7 44 24 08 af 25 80 	movl   $0x8025af,0x8(%esp)
  80101c:	00 
  80101d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801024:	00 
  801025:	c7 04 24 cc 25 80 00 	movl   $0x8025cc,(%esp)
  80102c:	e8 f3 f2 ff ff       	call   800324 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801031:	83 c4 2c             	add    $0x2c,%esp
  801034:	5b                   	pop    %ebx
  801035:	5e                   	pop    %esi
  801036:	5f                   	pop    %edi
  801037:	5d                   	pop    %ebp
  801038:	c3                   	ret    

00801039 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801039:	55                   	push   %ebp
  80103a:	89 e5                	mov    %esp,%ebp
  80103c:	57                   	push   %edi
  80103d:	56                   	push   %esi
  80103e:	53                   	push   %ebx
  80103f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801042:	bb 00 00 00 00       	mov    $0x0,%ebx
  801047:	b8 0a 00 00 00       	mov    $0xa,%eax
  80104c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80104f:	8b 55 08             	mov    0x8(%ebp),%edx
  801052:	89 df                	mov    %ebx,%edi
  801054:	89 de                	mov    %ebx,%esi
  801056:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801058:	85 c0                	test   %eax,%eax
  80105a:	7e 28                	jle    801084 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80105c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801060:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801067:	00 
  801068:	c7 44 24 08 af 25 80 	movl   $0x8025af,0x8(%esp)
  80106f:	00 
  801070:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801077:	00 
  801078:	c7 04 24 cc 25 80 00 	movl   $0x8025cc,(%esp)
  80107f:	e8 a0 f2 ff ff       	call   800324 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801084:	83 c4 2c             	add    $0x2c,%esp
  801087:	5b                   	pop    %ebx
  801088:	5e                   	pop    %esi
  801089:	5f                   	pop    %edi
  80108a:	5d                   	pop    %ebp
  80108b:	c3                   	ret    

0080108c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80108c:	55                   	push   %ebp
  80108d:	89 e5                	mov    %esp,%ebp
  80108f:	57                   	push   %edi
  801090:	56                   	push   %esi
  801091:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801092:	be 00 00 00 00       	mov    $0x0,%esi
  801097:	b8 0c 00 00 00       	mov    $0xc,%eax
  80109c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80109f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010aa:	5b                   	pop    %ebx
  8010ab:	5e                   	pop    %esi
  8010ac:	5f                   	pop    %edi
  8010ad:	5d                   	pop    %ebp
  8010ae:	c3                   	ret    

008010af <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010af:	55                   	push   %ebp
  8010b0:	89 e5                	mov    %esp,%ebp
  8010b2:	57                   	push   %edi
  8010b3:	56                   	push   %esi
  8010b4:	53                   	push   %ebx
  8010b5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010b8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010bd:	b8 0d 00 00 00       	mov    $0xd,%eax
  8010c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8010c5:	89 cb                	mov    %ecx,%ebx
  8010c7:	89 cf                	mov    %ecx,%edi
  8010c9:	89 ce                	mov    %ecx,%esi
  8010cb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010cd:	85 c0                	test   %eax,%eax
  8010cf:	7e 28                	jle    8010f9 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010d1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010d5:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8010dc:	00 
  8010dd:	c7 44 24 08 af 25 80 	movl   $0x8025af,0x8(%esp)
  8010e4:	00 
  8010e5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010ec:	00 
  8010ed:	c7 04 24 cc 25 80 00 	movl   $0x8025cc,(%esp)
  8010f4:	e8 2b f2 ff ff       	call   800324 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8010f9:	83 c4 2c             	add    $0x2c,%esp
  8010fc:	5b                   	pop    %ebx
  8010fd:	5e                   	pop    %esi
  8010fe:	5f                   	pop    %edi
  8010ff:	5d                   	pop    %ebp
  801100:	c3                   	ret    
  801101:	00 00                	add    %al,(%eax)
	...

00801104 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801104:	55                   	push   %ebp
  801105:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801107:	8b 45 08             	mov    0x8(%ebp),%eax
  80110a:	05 00 00 00 30       	add    $0x30000000,%eax
  80110f:	c1 e8 0c             	shr    $0xc,%eax
}
  801112:	5d                   	pop    %ebp
  801113:	c3                   	ret    

00801114 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801114:	55                   	push   %ebp
  801115:	89 e5                	mov    %esp,%ebp
  801117:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  80111a:	8b 45 08             	mov    0x8(%ebp),%eax
  80111d:	89 04 24             	mov    %eax,(%esp)
  801120:	e8 df ff ff ff       	call   801104 <fd2num>
  801125:	05 20 00 0d 00       	add    $0xd0020,%eax
  80112a:	c1 e0 0c             	shl    $0xc,%eax
}
  80112d:	c9                   	leave  
  80112e:	c3                   	ret    

0080112f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80112f:	55                   	push   %ebp
  801130:	89 e5                	mov    %esp,%ebp
  801132:	53                   	push   %ebx
  801133:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801136:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80113b:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80113d:	89 c2                	mov    %eax,%edx
  80113f:	c1 ea 16             	shr    $0x16,%edx
  801142:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801149:	f6 c2 01             	test   $0x1,%dl
  80114c:	74 11                	je     80115f <fd_alloc+0x30>
  80114e:	89 c2                	mov    %eax,%edx
  801150:	c1 ea 0c             	shr    $0xc,%edx
  801153:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80115a:	f6 c2 01             	test   $0x1,%dl
  80115d:	75 09                	jne    801168 <fd_alloc+0x39>
			*fd_store = fd;
  80115f:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801161:	b8 00 00 00 00       	mov    $0x0,%eax
  801166:	eb 17                	jmp    80117f <fd_alloc+0x50>
  801168:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80116d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801172:	75 c7                	jne    80113b <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801174:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80117a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80117f:	5b                   	pop    %ebx
  801180:	5d                   	pop    %ebp
  801181:	c3                   	ret    

00801182 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801182:	55                   	push   %ebp
  801183:	89 e5                	mov    %esp,%ebp
  801185:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801188:	83 f8 1f             	cmp    $0x1f,%eax
  80118b:	77 36                	ja     8011c3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80118d:	05 00 00 0d 00       	add    $0xd0000,%eax
  801192:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801195:	89 c2                	mov    %eax,%edx
  801197:	c1 ea 16             	shr    $0x16,%edx
  80119a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011a1:	f6 c2 01             	test   $0x1,%dl
  8011a4:	74 24                	je     8011ca <fd_lookup+0x48>
  8011a6:	89 c2                	mov    %eax,%edx
  8011a8:	c1 ea 0c             	shr    $0xc,%edx
  8011ab:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011b2:	f6 c2 01             	test   $0x1,%dl
  8011b5:	74 1a                	je     8011d1 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011ba:	89 02                	mov    %eax,(%edx)
	return 0;
  8011bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8011c1:	eb 13                	jmp    8011d6 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011c8:	eb 0c                	jmp    8011d6 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011cf:	eb 05                	jmp    8011d6 <fd_lookup+0x54>
  8011d1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011d6:	5d                   	pop    %ebp
  8011d7:	c3                   	ret    

008011d8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011d8:	55                   	push   %ebp
  8011d9:	89 e5                	mov    %esp,%ebp
  8011db:	53                   	push   %ebx
  8011dc:	83 ec 14             	sub    $0x14,%esp
  8011df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8011e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8011ea:	eb 0e                	jmp    8011fa <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8011ec:	39 08                	cmp    %ecx,(%eax)
  8011ee:	75 09                	jne    8011f9 <dev_lookup+0x21>
			*dev = devtab[i];
  8011f0:	89 03                	mov    %eax,(%ebx)
			return 0;
  8011f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8011f7:	eb 33                	jmp    80122c <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011f9:	42                   	inc    %edx
  8011fa:	8b 04 95 58 26 80 00 	mov    0x802658(,%edx,4),%eax
  801201:	85 c0                	test   %eax,%eax
  801203:	75 e7                	jne    8011ec <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801205:	a1 04 44 80 00       	mov    0x804404,%eax
  80120a:	8b 40 48             	mov    0x48(%eax),%eax
  80120d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801211:	89 44 24 04          	mov    %eax,0x4(%esp)
  801215:	c7 04 24 dc 25 80 00 	movl   $0x8025dc,(%esp)
  80121c:	e8 fb f1 ff ff       	call   80041c <cprintf>
	*dev = 0;
  801221:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801227:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80122c:	83 c4 14             	add    $0x14,%esp
  80122f:	5b                   	pop    %ebx
  801230:	5d                   	pop    %ebp
  801231:	c3                   	ret    

00801232 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801232:	55                   	push   %ebp
  801233:	89 e5                	mov    %esp,%ebp
  801235:	56                   	push   %esi
  801236:	53                   	push   %ebx
  801237:	83 ec 30             	sub    $0x30,%esp
  80123a:	8b 75 08             	mov    0x8(%ebp),%esi
  80123d:	8a 45 0c             	mov    0xc(%ebp),%al
  801240:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801243:	89 34 24             	mov    %esi,(%esp)
  801246:	e8 b9 fe ff ff       	call   801104 <fd2num>
  80124b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80124e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801252:	89 04 24             	mov    %eax,(%esp)
  801255:	e8 28 ff ff ff       	call   801182 <fd_lookup>
  80125a:	89 c3                	mov    %eax,%ebx
  80125c:	85 c0                	test   %eax,%eax
  80125e:	78 05                	js     801265 <fd_close+0x33>
	    || fd != fd2)
  801260:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801263:	74 0d                	je     801272 <fd_close+0x40>
		return (must_exist ? r : 0);
  801265:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801269:	75 46                	jne    8012b1 <fd_close+0x7f>
  80126b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801270:	eb 3f                	jmp    8012b1 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801272:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801275:	89 44 24 04          	mov    %eax,0x4(%esp)
  801279:	8b 06                	mov    (%esi),%eax
  80127b:	89 04 24             	mov    %eax,(%esp)
  80127e:	e8 55 ff ff ff       	call   8011d8 <dev_lookup>
  801283:	89 c3                	mov    %eax,%ebx
  801285:	85 c0                	test   %eax,%eax
  801287:	78 18                	js     8012a1 <fd_close+0x6f>
		if (dev->dev_close)
  801289:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80128c:	8b 40 10             	mov    0x10(%eax),%eax
  80128f:	85 c0                	test   %eax,%eax
  801291:	74 09                	je     80129c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801293:	89 34 24             	mov    %esi,(%esp)
  801296:	ff d0                	call   *%eax
  801298:	89 c3                	mov    %eax,%ebx
  80129a:	eb 05                	jmp    8012a1 <fd_close+0x6f>
		else
			r = 0;
  80129c:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012a1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012a5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012ac:	e8 8f fc ff ff       	call   800f40 <sys_page_unmap>
	return r;
}
  8012b1:	89 d8                	mov    %ebx,%eax
  8012b3:	83 c4 30             	add    $0x30,%esp
  8012b6:	5b                   	pop    %ebx
  8012b7:	5e                   	pop    %esi
  8012b8:	5d                   	pop    %ebp
  8012b9:	c3                   	ret    

008012ba <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012ba:	55                   	push   %ebp
  8012bb:	89 e5                	mov    %esp,%ebp
  8012bd:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ca:	89 04 24             	mov    %eax,(%esp)
  8012cd:	e8 b0 fe ff ff       	call   801182 <fd_lookup>
  8012d2:	85 c0                	test   %eax,%eax
  8012d4:	78 13                	js     8012e9 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8012d6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8012dd:	00 
  8012de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012e1:	89 04 24             	mov    %eax,(%esp)
  8012e4:	e8 49 ff ff ff       	call   801232 <fd_close>
}
  8012e9:	c9                   	leave  
  8012ea:	c3                   	ret    

008012eb <close_all>:

void
close_all(void)
{
  8012eb:	55                   	push   %ebp
  8012ec:	89 e5                	mov    %esp,%ebp
  8012ee:	53                   	push   %ebx
  8012ef:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012f2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012f7:	89 1c 24             	mov    %ebx,(%esp)
  8012fa:	e8 bb ff ff ff       	call   8012ba <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012ff:	43                   	inc    %ebx
  801300:	83 fb 20             	cmp    $0x20,%ebx
  801303:	75 f2                	jne    8012f7 <close_all+0xc>
		close(i);
}
  801305:	83 c4 14             	add    $0x14,%esp
  801308:	5b                   	pop    %ebx
  801309:	5d                   	pop    %ebp
  80130a:	c3                   	ret    

0080130b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80130b:	55                   	push   %ebp
  80130c:	89 e5                	mov    %esp,%ebp
  80130e:	57                   	push   %edi
  80130f:	56                   	push   %esi
  801310:	53                   	push   %ebx
  801311:	83 ec 4c             	sub    $0x4c,%esp
  801314:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801317:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80131a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80131e:	8b 45 08             	mov    0x8(%ebp),%eax
  801321:	89 04 24             	mov    %eax,(%esp)
  801324:	e8 59 fe ff ff       	call   801182 <fd_lookup>
  801329:	89 c3                	mov    %eax,%ebx
  80132b:	85 c0                	test   %eax,%eax
  80132d:	0f 88 e1 00 00 00    	js     801414 <dup+0x109>
		return r;
	close(newfdnum);
  801333:	89 3c 24             	mov    %edi,(%esp)
  801336:	e8 7f ff ff ff       	call   8012ba <close>

	newfd = INDEX2FD(newfdnum);
  80133b:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801341:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801344:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801347:	89 04 24             	mov    %eax,(%esp)
  80134a:	e8 c5 fd ff ff       	call   801114 <fd2data>
  80134f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801351:	89 34 24             	mov    %esi,(%esp)
  801354:	e8 bb fd ff ff       	call   801114 <fd2data>
  801359:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80135c:	89 d8                	mov    %ebx,%eax
  80135e:	c1 e8 16             	shr    $0x16,%eax
  801361:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801368:	a8 01                	test   $0x1,%al
  80136a:	74 46                	je     8013b2 <dup+0xa7>
  80136c:	89 d8                	mov    %ebx,%eax
  80136e:	c1 e8 0c             	shr    $0xc,%eax
  801371:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801378:	f6 c2 01             	test   $0x1,%dl
  80137b:	74 35                	je     8013b2 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80137d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801384:	25 07 0e 00 00       	and    $0xe07,%eax
  801389:	89 44 24 10          	mov    %eax,0x10(%esp)
  80138d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801390:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801394:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80139b:	00 
  80139c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013a7:	e8 41 fb ff ff       	call   800eed <sys_page_map>
  8013ac:	89 c3                	mov    %eax,%ebx
  8013ae:	85 c0                	test   %eax,%eax
  8013b0:	78 3b                	js     8013ed <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013b5:	89 c2                	mov    %eax,%edx
  8013b7:	c1 ea 0c             	shr    $0xc,%edx
  8013ba:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013c1:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8013c7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8013cb:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8013cf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8013d6:	00 
  8013d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013e2:	e8 06 fb ff ff       	call   800eed <sys_page_map>
  8013e7:	89 c3                	mov    %eax,%ebx
  8013e9:	85 c0                	test   %eax,%eax
  8013eb:	79 25                	jns    801412 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013ed:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013f1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013f8:	e8 43 fb ff ff       	call   800f40 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013fd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801400:	89 44 24 04          	mov    %eax,0x4(%esp)
  801404:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80140b:	e8 30 fb ff ff       	call   800f40 <sys_page_unmap>
	return r;
  801410:	eb 02                	jmp    801414 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801412:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801414:	89 d8                	mov    %ebx,%eax
  801416:	83 c4 4c             	add    $0x4c,%esp
  801419:	5b                   	pop    %ebx
  80141a:	5e                   	pop    %esi
  80141b:	5f                   	pop    %edi
  80141c:	5d                   	pop    %ebp
  80141d:	c3                   	ret    

0080141e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80141e:	55                   	push   %ebp
  80141f:	89 e5                	mov    %esp,%ebp
  801421:	53                   	push   %ebx
  801422:	83 ec 24             	sub    $0x24,%esp
  801425:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801428:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80142b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80142f:	89 1c 24             	mov    %ebx,(%esp)
  801432:	e8 4b fd ff ff       	call   801182 <fd_lookup>
  801437:	85 c0                	test   %eax,%eax
  801439:	78 6d                	js     8014a8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80143b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80143e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801442:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801445:	8b 00                	mov    (%eax),%eax
  801447:	89 04 24             	mov    %eax,(%esp)
  80144a:	e8 89 fd ff ff       	call   8011d8 <dev_lookup>
  80144f:	85 c0                	test   %eax,%eax
  801451:	78 55                	js     8014a8 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801453:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801456:	8b 50 08             	mov    0x8(%eax),%edx
  801459:	83 e2 03             	and    $0x3,%edx
  80145c:	83 fa 01             	cmp    $0x1,%edx
  80145f:	75 23                	jne    801484 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801461:	a1 04 44 80 00       	mov    0x804404,%eax
  801466:	8b 40 48             	mov    0x48(%eax),%eax
  801469:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80146d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801471:	c7 04 24 1d 26 80 00 	movl   $0x80261d,(%esp)
  801478:	e8 9f ef ff ff       	call   80041c <cprintf>
		return -E_INVAL;
  80147d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801482:	eb 24                	jmp    8014a8 <read+0x8a>
	}
	if (!dev->dev_read)
  801484:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801487:	8b 52 08             	mov    0x8(%edx),%edx
  80148a:	85 d2                	test   %edx,%edx
  80148c:	74 15                	je     8014a3 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80148e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801491:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801495:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801498:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80149c:	89 04 24             	mov    %eax,(%esp)
  80149f:	ff d2                	call   *%edx
  8014a1:	eb 05                	jmp    8014a8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014a3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8014a8:	83 c4 24             	add    $0x24,%esp
  8014ab:	5b                   	pop    %ebx
  8014ac:	5d                   	pop    %ebp
  8014ad:	c3                   	ret    

008014ae <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014ae:	55                   	push   %ebp
  8014af:	89 e5                	mov    %esp,%ebp
  8014b1:	57                   	push   %edi
  8014b2:	56                   	push   %esi
  8014b3:	53                   	push   %ebx
  8014b4:	83 ec 1c             	sub    $0x1c,%esp
  8014b7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014ba:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014bd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014c2:	eb 23                	jmp    8014e7 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014c4:	89 f0                	mov    %esi,%eax
  8014c6:	29 d8                	sub    %ebx,%eax
  8014c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014cf:	01 d8                	add    %ebx,%eax
  8014d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014d5:	89 3c 24             	mov    %edi,(%esp)
  8014d8:	e8 41 ff ff ff       	call   80141e <read>
		if (m < 0)
  8014dd:	85 c0                	test   %eax,%eax
  8014df:	78 10                	js     8014f1 <readn+0x43>
			return m;
		if (m == 0)
  8014e1:	85 c0                	test   %eax,%eax
  8014e3:	74 0a                	je     8014ef <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014e5:	01 c3                	add    %eax,%ebx
  8014e7:	39 f3                	cmp    %esi,%ebx
  8014e9:	72 d9                	jb     8014c4 <readn+0x16>
  8014eb:	89 d8                	mov    %ebx,%eax
  8014ed:	eb 02                	jmp    8014f1 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8014ef:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8014f1:	83 c4 1c             	add    $0x1c,%esp
  8014f4:	5b                   	pop    %ebx
  8014f5:	5e                   	pop    %esi
  8014f6:	5f                   	pop    %edi
  8014f7:	5d                   	pop    %ebp
  8014f8:	c3                   	ret    

008014f9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014f9:	55                   	push   %ebp
  8014fa:	89 e5                	mov    %esp,%ebp
  8014fc:	53                   	push   %ebx
  8014fd:	83 ec 24             	sub    $0x24,%esp
  801500:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801503:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801506:	89 44 24 04          	mov    %eax,0x4(%esp)
  80150a:	89 1c 24             	mov    %ebx,(%esp)
  80150d:	e8 70 fc ff ff       	call   801182 <fd_lookup>
  801512:	85 c0                	test   %eax,%eax
  801514:	78 68                	js     80157e <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801516:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801519:	89 44 24 04          	mov    %eax,0x4(%esp)
  80151d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801520:	8b 00                	mov    (%eax),%eax
  801522:	89 04 24             	mov    %eax,(%esp)
  801525:	e8 ae fc ff ff       	call   8011d8 <dev_lookup>
  80152a:	85 c0                	test   %eax,%eax
  80152c:	78 50                	js     80157e <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80152e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801531:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801535:	75 23                	jne    80155a <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801537:	a1 04 44 80 00       	mov    0x804404,%eax
  80153c:	8b 40 48             	mov    0x48(%eax),%eax
  80153f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801543:	89 44 24 04          	mov    %eax,0x4(%esp)
  801547:	c7 04 24 39 26 80 00 	movl   $0x802639,(%esp)
  80154e:	e8 c9 ee ff ff       	call   80041c <cprintf>
		return -E_INVAL;
  801553:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801558:	eb 24                	jmp    80157e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80155a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80155d:	8b 52 0c             	mov    0xc(%edx),%edx
  801560:	85 d2                	test   %edx,%edx
  801562:	74 15                	je     801579 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801564:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801567:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80156b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80156e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801572:	89 04 24             	mov    %eax,(%esp)
  801575:	ff d2                	call   *%edx
  801577:	eb 05                	jmp    80157e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801579:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80157e:	83 c4 24             	add    $0x24,%esp
  801581:	5b                   	pop    %ebx
  801582:	5d                   	pop    %ebp
  801583:	c3                   	ret    

00801584 <seek>:

int
seek(int fdnum, off_t offset)
{
  801584:	55                   	push   %ebp
  801585:	89 e5                	mov    %esp,%ebp
  801587:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80158a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80158d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801591:	8b 45 08             	mov    0x8(%ebp),%eax
  801594:	89 04 24             	mov    %eax,(%esp)
  801597:	e8 e6 fb ff ff       	call   801182 <fd_lookup>
  80159c:	85 c0                	test   %eax,%eax
  80159e:	78 0e                	js     8015ae <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8015a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015a6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015ae:	c9                   	leave  
  8015af:	c3                   	ret    

008015b0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015b0:	55                   	push   %ebp
  8015b1:	89 e5                	mov    %esp,%ebp
  8015b3:	53                   	push   %ebx
  8015b4:	83 ec 24             	sub    $0x24,%esp
  8015b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015ba:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015c1:	89 1c 24             	mov    %ebx,(%esp)
  8015c4:	e8 b9 fb ff ff       	call   801182 <fd_lookup>
  8015c9:	85 c0                	test   %eax,%eax
  8015cb:	78 61                	js     80162e <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d7:	8b 00                	mov    (%eax),%eax
  8015d9:	89 04 24             	mov    %eax,(%esp)
  8015dc:	e8 f7 fb ff ff       	call   8011d8 <dev_lookup>
  8015e1:	85 c0                	test   %eax,%eax
  8015e3:	78 49                	js     80162e <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015ec:	75 23                	jne    801611 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015ee:	a1 04 44 80 00       	mov    0x804404,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015f3:	8b 40 48             	mov    0x48(%eax),%eax
  8015f6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8015fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015fe:	c7 04 24 fc 25 80 00 	movl   $0x8025fc,(%esp)
  801605:	e8 12 ee ff ff       	call   80041c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80160a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80160f:	eb 1d                	jmp    80162e <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801611:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801614:	8b 52 18             	mov    0x18(%edx),%edx
  801617:	85 d2                	test   %edx,%edx
  801619:	74 0e                	je     801629 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80161b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80161e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801622:	89 04 24             	mov    %eax,(%esp)
  801625:	ff d2                	call   *%edx
  801627:	eb 05                	jmp    80162e <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801629:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80162e:	83 c4 24             	add    $0x24,%esp
  801631:	5b                   	pop    %ebx
  801632:	5d                   	pop    %ebp
  801633:	c3                   	ret    

00801634 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801634:	55                   	push   %ebp
  801635:	89 e5                	mov    %esp,%ebp
  801637:	53                   	push   %ebx
  801638:	83 ec 24             	sub    $0x24,%esp
  80163b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80163e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801641:	89 44 24 04          	mov    %eax,0x4(%esp)
  801645:	8b 45 08             	mov    0x8(%ebp),%eax
  801648:	89 04 24             	mov    %eax,(%esp)
  80164b:	e8 32 fb ff ff       	call   801182 <fd_lookup>
  801650:	85 c0                	test   %eax,%eax
  801652:	78 52                	js     8016a6 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801654:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801657:	89 44 24 04          	mov    %eax,0x4(%esp)
  80165b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80165e:	8b 00                	mov    (%eax),%eax
  801660:	89 04 24             	mov    %eax,(%esp)
  801663:	e8 70 fb ff ff       	call   8011d8 <dev_lookup>
  801668:	85 c0                	test   %eax,%eax
  80166a:	78 3a                	js     8016a6 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  80166c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80166f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801673:	74 2c                	je     8016a1 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801675:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801678:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80167f:	00 00 00 
	stat->st_isdir = 0;
  801682:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801689:	00 00 00 
	stat->st_dev = dev;
  80168c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801692:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801696:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801699:	89 14 24             	mov    %edx,(%esp)
  80169c:	ff 50 14             	call   *0x14(%eax)
  80169f:	eb 05                	jmp    8016a6 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016a1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016a6:	83 c4 24             	add    $0x24,%esp
  8016a9:	5b                   	pop    %ebx
  8016aa:	5d                   	pop    %ebp
  8016ab:	c3                   	ret    

008016ac <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016ac:	55                   	push   %ebp
  8016ad:	89 e5                	mov    %esp,%ebp
  8016af:	56                   	push   %esi
  8016b0:	53                   	push   %ebx
  8016b1:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016b4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8016bb:	00 
  8016bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8016bf:	89 04 24             	mov    %eax,(%esp)
  8016c2:	e8 2d 02 00 00       	call   8018f4 <open>
  8016c7:	89 c3                	mov    %eax,%ebx
  8016c9:	85 c0                	test   %eax,%eax
  8016cb:	78 1b                	js     8016e8 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8016cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016d4:	89 1c 24             	mov    %ebx,(%esp)
  8016d7:	e8 58 ff ff ff       	call   801634 <fstat>
  8016dc:	89 c6                	mov    %eax,%esi
	close(fd);
  8016de:	89 1c 24             	mov    %ebx,(%esp)
  8016e1:	e8 d4 fb ff ff       	call   8012ba <close>
	return r;
  8016e6:	89 f3                	mov    %esi,%ebx
}
  8016e8:	89 d8                	mov    %ebx,%eax
  8016ea:	83 c4 10             	add    $0x10,%esp
  8016ed:	5b                   	pop    %ebx
  8016ee:	5e                   	pop    %esi
  8016ef:	5d                   	pop    %ebp
  8016f0:	c3                   	ret    
  8016f1:	00 00                	add    %al,(%eax)
	...

008016f4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016f4:	55                   	push   %ebp
  8016f5:	89 e5                	mov    %esp,%ebp
  8016f7:	56                   	push   %esi
  8016f8:	53                   	push   %ebx
  8016f9:	83 ec 10             	sub    $0x10,%esp
  8016fc:	89 c3                	mov    %eax,%ebx
  8016fe:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801700:	83 3d 00 44 80 00 00 	cmpl   $0x0,0x804400
  801707:	75 11                	jne    80171a <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801709:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801710:	e8 06 08 00 00       	call   801f1b <ipc_find_env>
  801715:	a3 00 44 80 00       	mov    %eax,0x804400
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80171a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801721:	00 
  801722:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801729:	00 
  80172a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80172e:	a1 00 44 80 00       	mov    0x804400,%eax
  801733:	89 04 24             	mov    %eax,(%esp)
  801736:	e8 72 07 00 00       	call   801ead <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80173b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801742:	00 
  801743:	89 74 24 04          	mov    %esi,0x4(%esp)
  801747:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80174e:	e8 f1 06 00 00       	call   801e44 <ipc_recv>
}
  801753:	83 c4 10             	add    $0x10,%esp
  801756:	5b                   	pop    %ebx
  801757:	5e                   	pop    %esi
  801758:	5d                   	pop    %ebp
  801759:	c3                   	ret    

0080175a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80175a:	55                   	push   %ebp
  80175b:	89 e5                	mov    %esp,%ebp
  80175d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801760:	8b 45 08             	mov    0x8(%ebp),%eax
  801763:	8b 40 0c             	mov    0xc(%eax),%eax
  801766:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80176b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80176e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801773:	ba 00 00 00 00       	mov    $0x0,%edx
  801778:	b8 02 00 00 00       	mov    $0x2,%eax
  80177d:	e8 72 ff ff ff       	call   8016f4 <fsipc>
}
  801782:	c9                   	leave  
  801783:	c3                   	ret    

00801784 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801784:	55                   	push   %ebp
  801785:	89 e5                	mov    %esp,%ebp
  801787:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80178a:	8b 45 08             	mov    0x8(%ebp),%eax
  80178d:	8b 40 0c             	mov    0xc(%eax),%eax
  801790:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801795:	ba 00 00 00 00       	mov    $0x0,%edx
  80179a:	b8 06 00 00 00       	mov    $0x6,%eax
  80179f:	e8 50 ff ff ff       	call   8016f4 <fsipc>
}
  8017a4:	c9                   	leave  
  8017a5:	c3                   	ret    

008017a6 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017a6:	55                   	push   %ebp
  8017a7:	89 e5                	mov    %esp,%ebp
  8017a9:	53                   	push   %ebx
  8017aa:	83 ec 14             	sub    $0x14,%esp
  8017ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b3:	8b 40 0c             	mov    0xc(%eax),%eax
  8017b6:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c0:	b8 05 00 00 00       	mov    $0x5,%eax
  8017c5:	e8 2a ff ff ff       	call   8016f4 <fsipc>
  8017ca:	85 c0                	test   %eax,%eax
  8017cc:	78 2b                	js     8017f9 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017ce:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8017d5:	00 
  8017d6:	89 1c 24             	mov    %ebx,(%esp)
  8017d9:	e8 c9 f2 ff ff       	call   800aa7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017de:	a1 80 50 80 00       	mov    0x805080,%eax
  8017e3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017e9:	a1 84 50 80 00       	mov    0x805084,%eax
  8017ee:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017f9:	83 c4 14             	add    $0x14,%esp
  8017fc:	5b                   	pop    %ebx
  8017fd:	5d                   	pop    %ebp
  8017fe:	c3                   	ret    

008017ff <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017ff:	55                   	push   %ebp
  801800:	89 e5                	mov    %esp,%ebp
  801802:	83 ec 18             	sub    $0x18,%esp
  801805:	8b 55 10             	mov    0x10(%ebp),%edx
  801808:	89 d0                	mov    %edx,%eax
  80180a:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  801810:	76 05                	jbe    801817 <devfile_write+0x18>
  801812:	b8 00 10 00 00       	mov    $0x1000,%eax
	//panic("devfile_write not implemented");
	int r;
	//uint32_t maxsize = BLKSIZE - sizeof(int) - sizeof(size_t);	
	if (n > BLKSIZE)
		n = BLKSIZE;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801817:	8b 55 08             	mov    0x8(%ebp),%edx
  80181a:	8b 52 0c             	mov    0xc(%edx),%edx
  80181d:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801823:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801828:	89 44 24 08          	mov    %eax,0x8(%esp)
  80182c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80182f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801833:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  80183a:	e8 e1 f3 ff ff       	call   800c20 <memmove>
	 
	return fsipc(FSREQ_WRITE, NULL);
  80183f:	ba 00 00 00 00       	mov    $0x0,%edx
  801844:	b8 04 00 00 00       	mov    $0x4,%eax
  801849:	e8 a6 fe ff ff       	call   8016f4 <fsipc>
}
  80184e:	c9                   	leave  
  80184f:	c3                   	ret    

00801850 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801850:	55                   	push   %ebp
  801851:	89 e5                	mov    %esp,%ebp
  801853:	56                   	push   %esi
  801854:	53                   	push   %ebx
  801855:	83 ec 10             	sub    $0x10,%esp
  801858:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80185b:	8b 45 08             	mov    0x8(%ebp),%eax
  80185e:	8b 40 0c             	mov    0xc(%eax),%eax
  801861:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801866:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80186c:	ba 00 00 00 00       	mov    $0x0,%edx
  801871:	b8 03 00 00 00       	mov    $0x3,%eax
  801876:	e8 79 fe ff ff       	call   8016f4 <fsipc>
  80187b:	89 c3                	mov    %eax,%ebx
  80187d:	85 c0                	test   %eax,%eax
  80187f:	78 6a                	js     8018eb <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801881:	39 c6                	cmp    %eax,%esi
  801883:	73 24                	jae    8018a9 <devfile_read+0x59>
  801885:	c7 44 24 0c 68 26 80 	movl   $0x802668,0xc(%esp)
  80188c:	00 
  80188d:	c7 44 24 08 6f 26 80 	movl   $0x80266f,0x8(%esp)
  801894:	00 
  801895:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  80189c:	00 
  80189d:	c7 04 24 84 26 80 00 	movl   $0x802684,(%esp)
  8018a4:	e8 7b ea ff ff       	call   800324 <_panic>
	assert(r <= PGSIZE);
  8018a9:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018ae:	7e 24                	jle    8018d4 <devfile_read+0x84>
  8018b0:	c7 44 24 0c 8f 26 80 	movl   $0x80268f,0xc(%esp)
  8018b7:	00 
  8018b8:	c7 44 24 08 6f 26 80 	movl   $0x80266f,0x8(%esp)
  8018bf:	00 
  8018c0:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8018c7:	00 
  8018c8:	c7 04 24 84 26 80 00 	movl   $0x802684,(%esp)
  8018cf:	e8 50 ea ff ff       	call   800324 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018d8:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8018df:	00 
  8018e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018e3:	89 04 24             	mov    %eax,(%esp)
  8018e6:	e8 35 f3 ff ff       	call   800c20 <memmove>
	return r;
}
  8018eb:	89 d8                	mov    %ebx,%eax
  8018ed:	83 c4 10             	add    $0x10,%esp
  8018f0:	5b                   	pop    %ebx
  8018f1:	5e                   	pop    %esi
  8018f2:	5d                   	pop    %ebp
  8018f3:	c3                   	ret    

008018f4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018f4:	55                   	push   %ebp
  8018f5:	89 e5                	mov    %esp,%ebp
  8018f7:	56                   	push   %esi
  8018f8:	53                   	push   %ebx
  8018f9:	83 ec 20             	sub    $0x20,%esp
  8018fc:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018ff:	89 34 24             	mov    %esi,(%esp)
  801902:	e8 6d f1 ff ff       	call   800a74 <strlen>
  801907:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80190c:	7f 60                	jg     80196e <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80190e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801911:	89 04 24             	mov    %eax,(%esp)
  801914:	e8 16 f8 ff ff       	call   80112f <fd_alloc>
  801919:	89 c3                	mov    %eax,%ebx
  80191b:	85 c0                	test   %eax,%eax
  80191d:	78 54                	js     801973 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80191f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801923:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  80192a:	e8 78 f1 ff ff       	call   800aa7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80192f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801932:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801937:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80193a:	b8 01 00 00 00       	mov    $0x1,%eax
  80193f:	e8 b0 fd ff ff       	call   8016f4 <fsipc>
  801944:	89 c3                	mov    %eax,%ebx
  801946:	85 c0                	test   %eax,%eax
  801948:	79 15                	jns    80195f <open+0x6b>
		fd_close(fd, 0);
  80194a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801951:	00 
  801952:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801955:	89 04 24             	mov    %eax,(%esp)
  801958:	e8 d5 f8 ff ff       	call   801232 <fd_close>
		return r;
  80195d:	eb 14                	jmp    801973 <open+0x7f>
	}

	return fd2num(fd);
  80195f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801962:	89 04 24             	mov    %eax,(%esp)
  801965:	e8 9a f7 ff ff       	call   801104 <fd2num>
  80196a:	89 c3                	mov    %eax,%ebx
  80196c:	eb 05                	jmp    801973 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80196e:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801973:	89 d8                	mov    %ebx,%eax
  801975:	83 c4 20             	add    $0x20,%esp
  801978:	5b                   	pop    %ebx
  801979:	5e                   	pop    %esi
  80197a:	5d                   	pop    %ebp
  80197b:	c3                   	ret    

0080197c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80197c:	55                   	push   %ebp
  80197d:	89 e5                	mov    %esp,%ebp
  80197f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801982:	ba 00 00 00 00       	mov    $0x0,%edx
  801987:	b8 08 00 00 00       	mov    $0x8,%eax
  80198c:	e8 63 fd ff ff       	call   8016f4 <fsipc>
}
  801991:	c9                   	leave  
  801992:	c3                   	ret    
	...

00801994 <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  801994:	55                   	push   %ebp
  801995:	89 e5                	mov    %esp,%ebp
  801997:	53                   	push   %ebx
  801998:	83 ec 14             	sub    $0x14,%esp
  80199b:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  80199d:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8019a1:	7e 32                	jle    8019d5 <writebuf+0x41>
		ssize_t result = write(b->fd, b->buf, b->idx);
  8019a3:	8b 40 04             	mov    0x4(%eax),%eax
  8019a6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019aa:	8d 43 10             	lea    0x10(%ebx),%eax
  8019ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019b1:	8b 03                	mov    (%ebx),%eax
  8019b3:	89 04 24             	mov    %eax,(%esp)
  8019b6:	e8 3e fb ff ff       	call   8014f9 <write>
		if (result > 0)
  8019bb:	85 c0                	test   %eax,%eax
  8019bd:	7e 03                	jle    8019c2 <writebuf+0x2e>
			b->result += result;
  8019bf:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8019c2:	39 43 04             	cmp    %eax,0x4(%ebx)
  8019c5:	74 0e                	je     8019d5 <writebuf+0x41>
			b->error = (result < 0 ? result : 0);
  8019c7:	89 c2                	mov    %eax,%edx
  8019c9:	85 c0                	test   %eax,%eax
  8019cb:	7e 05                	jle    8019d2 <writebuf+0x3e>
  8019cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8019d2:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  8019d5:	83 c4 14             	add    $0x14,%esp
  8019d8:	5b                   	pop    %ebx
  8019d9:	5d                   	pop    %ebp
  8019da:	c3                   	ret    

008019db <putch>:

static void
putch(int ch, void *thunk)
{
  8019db:	55                   	push   %ebp
  8019dc:	89 e5                	mov    %esp,%ebp
  8019de:	53                   	push   %ebx
  8019df:	83 ec 04             	sub    $0x4,%esp
  8019e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8019e5:	8b 43 04             	mov    0x4(%ebx),%eax
  8019e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8019eb:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  8019ef:	40                   	inc    %eax
  8019f0:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  8019f3:	3d 00 01 00 00       	cmp    $0x100,%eax
  8019f8:	75 0e                	jne    801a08 <putch+0x2d>
		writebuf(b);
  8019fa:	89 d8                	mov    %ebx,%eax
  8019fc:	e8 93 ff ff ff       	call   801994 <writebuf>
		b->idx = 0;
  801a01:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801a08:	83 c4 04             	add    $0x4,%esp
  801a0b:	5b                   	pop    %ebx
  801a0c:	5d                   	pop    %ebp
  801a0d:	c3                   	ret    

00801a0e <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801a0e:	55                   	push   %ebp
  801a0f:	89 e5                	mov    %esp,%ebp
  801a11:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  801a17:	8b 45 08             	mov    0x8(%ebp),%eax
  801a1a:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801a20:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801a27:	00 00 00 
	b.result = 0;
  801a2a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801a31:	00 00 00 
	b.error = 1;
  801a34:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801a3b:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801a3e:	8b 45 10             	mov    0x10(%ebp),%eax
  801a41:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a45:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a48:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a4c:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801a52:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a56:	c7 04 24 db 19 80 00 	movl   $0x8019db,(%esp)
  801a5d:	e8 1c eb ff ff       	call   80057e <vprintfmt>
	if (b.idx > 0)
  801a62:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801a69:	7e 0b                	jle    801a76 <vfprintf+0x68>
		writebuf(&b);
  801a6b:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801a71:	e8 1e ff ff ff       	call   801994 <writebuf>

	return (b.result ? b.result : b.error);
  801a76:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801a7c:	85 c0                	test   %eax,%eax
  801a7e:	75 06                	jne    801a86 <vfprintf+0x78>
  801a80:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  801a86:	c9                   	leave  
  801a87:	c3                   	ret    

00801a88 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801a88:	55                   	push   %ebp
  801a89:	89 e5                	mov    %esp,%ebp
  801a8b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a8e:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801a91:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a95:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a98:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a9c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a9f:	89 04 24             	mov    %eax,(%esp)
  801aa2:	e8 67 ff ff ff       	call   801a0e <vfprintf>
	va_end(ap);

	return cnt;
}
  801aa7:	c9                   	leave  
  801aa8:	c3                   	ret    

00801aa9 <printf>:

int
printf(const char *fmt, ...)
{
  801aa9:	55                   	push   %ebp
  801aaa:	89 e5                	mov    %esp,%ebp
  801aac:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801aaf:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801ab2:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ab6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801abd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801ac4:	e8 45 ff ff ff       	call   801a0e <vfprintf>
	va_end(ap);

	return cnt;
}
  801ac9:	c9                   	leave  
  801aca:	c3                   	ret    
	...

00801acc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801acc:	55                   	push   %ebp
  801acd:	89 e5                	mov    %esp,%ebp
  801acf:	56                   	push   %esi
  801ad0:	53                   	push   %ebx
  801ad1:	83 ec 10             	sub    $0x10,%esp
  801ad4:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ad7:	8b 45 08             	mov    0x8(%ebp),%eax
  801ada:	89 04 24             	mov    %eax,(%esp)
  801add:	e8 32 f6 ff ff       	call   801114 <fd2data>
  801ae2:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801ae4:	c7 44 24 04 9b 26 80 	movl   $0x80269b,0x4(%esp)
  801aeb:	00 
  801aec:	89 34 24             	mov    %esi,(%esp)
  801aef:	e8 b3 ef ff ff       	call   800aa7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801af4:	8b 43 04             	mov    0x4(%ebx),%eax
  801af7:	2b 03                	sub    (%ebx),%eax
  801af9:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801aff:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801b06:	00 00 00 
	stat->st_dev = &devpipe;
  801b09:	c7 86 88 00 00 00 3c 	movl   $0x80303c,0x88(%esi)
  801b10:	30 80 00 
	return 0;
}
  801b13:	b8 00 00 00 00       	mov    $0x0,%eax
  801b18:	83 c4 10             	add    $0x10,%esp
  801b1b:	5b                   	pop    %ebx
  801b1c:	5e                   	pop    %esi
  801b1d:	5d                   	pop    %ebp
  801b1e:	c3                   	ret    

00801b1f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b1f:	55                   	push   %ebp
  801b20:	89 e5                	mov    %esp,%ebp
  801b22:	53                   	push   %ebx
  801b23:	83 ec 14             	sub    $0x14,%esp
  801b26:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b29:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b2d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b34:	e8 07 f4 ff ff       	call   800f40 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b39:	89 1c 24             	mov    %ebx,(%esp)
  801b3c:	e8 d3 f5 ff ff       	call   801114 <fd2data>
  801b41:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b45:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b4c:	e8 ef f3 ff ff       	call   800f40 <sys_page_unmap>
}
  801b51:	83 c4 14             	add    $0x14,%esp
  801b54:	5b                   	pop    %ebx
  801b55:	5d                   	pop    %ebp
  801b56:	c3                   	ret    

00801b57 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b57:	55                   	push   %ebp
  801b58:	89 e5                	mov    %esp,%ebp
  801b5a:	57                   	push   %edi
  801b5b:	56                   	push   %esi
  801b5c:	53                   	push   %ebx
  801b5d:	83 ec 2c             	sub    $0x2c,%esp
  801b60:	89 c7                	mov    %eax,%edi
  801b62:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b65:	a1 04 44 80 00       	mov    0x804404,%eax
  801b6a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801b6d:	89 3c 24             	mov    %edi,(%esp)
  801b70:	e8 eb 03 00 00       	call   801f60 <pageref>
  801b75:	89 c6                	mov    %eax,%esi
  801b77:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b7a:	89 04 24             	mov    %eax,(%esp)
  801b7d:	e8 de 03 00 00       	call   801f60 <pageref>
  801b82:	39 c6                	cmp    %eax,%esi
  801b84:	0f 94 c0             	sete   %al
  801b87:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801b8a:	8b 15 04 44 80 00    	mov    0x804404,%edx
  801b90:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b93:	39 cb                	cmp    %ecx,%ebx
  801b95:	75 08                	jne    801b9f <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801b97:	83 c4 2c             	add    $0x2c,%esp
  801b9a:	5b                   	pop    %ebx
  801b9b:	5e                   	pop    %esi
  801b9c:	5f                   	pop    %edi
  801b9d:	5d                   	pop    %ebp
  801b9e:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801b9f:	83 f8 01             	cmp    $0x1,%eax
  801ba2:	75 c1                	jne    801b65 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ba4:	8b 42 58             	mov    0x58(%edx),%eax
  801ba7:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801bae:	00 
  801baf:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bb3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801bb7:	c7 04 24 a2 26 80 00 	movl   $0x8026a2,(%esp)
  801bbe:	e8 59 e8 ff ff       	call   80041c <cprintf>
  801bc3:	eb a0                	jmp    801b65 <_pipeisclosed+0xe>

00801bc5 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bc5:	55                   	push   %ebp
  801bc6:	89 e5                	mov    %esp,%ebp
  801bc8:	57                   	push   %edi
  801bc9:	56                   	push   %esi
  801bca:	53                   	push   %ebx
  801bcb:	83 ec 1c             	sub    $0x1c,%esp
  801bce:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801bd1:	89 34 24             	mov    %esi,(%esp)
  801bd4:	e8 3b f5 ff ff       	call   801114 <fd2data>
  801bd9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bdb:	bf 00 00 00 00       	mov    $0x0,%edi
  801be0:	eb 3c                	jmp    801c1e <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801be2:	89 da                	mov    %ebx,%edx
  801be4:	89 f0                	mov    %esi,%eax
  801be6:	e8 6c ff ff ff       	call   801b57 <_pipeisclosed>
  801beb:	85 c0                	test   %eax,%eax
  801bed:	75 38                	jne    801c27 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801bef:	e8 86 f2 ff ff       	call   800e7a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bf4:	8b 43 04             	mov    0x4(%ebx),%eax
  801bf7:	8b 13                	mov    (%ebx),%edx
  801bf9:	83 c2 20             	add    $0x20,%edx
  801bfc:	39 d0                	cmp    %edx,%eax
  801bfe:	73 e2                	jae    801be2 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c00:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c03:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801c06:	89 c2                	mov    %eax,%edx
  801c08:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801c0e:	79 05                	jns    801c15 <devpipe_write+0x50>
  801c10:	4a                   	dec    %edx
  801c11:	83 ca e0             	or     $0xffffffe0,%edx
  801c14:	42                   	inc    %edx
  801c15:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c19:	40                   	inc    %eax
  801c1a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c1d:	47                   	inc    %edi
  801c1e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c21:	75 d1                	jne    801bf4 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c23:	89 f8                	mov    %edi,%eax
  801c25:	eb 05                	jmp    801c2c <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c27:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c2c:	83 c4 1c             	add    $0x1c,%esp
  801c2f:	5b                   	pop    %ebx
  801c30:	5e                   	pop    %esi
  801c31:	5f                   	pop    %edi
  801c32:	5d                   	pop    %ebp
  801c33:	c3                   	ret    

00801c34 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c34:	55                   	push   %ebp
  801c35:	89 e5                	mov    %esp,%ebp
  801c37:	57                   	push   %edi
  801c38:	56                   	push   %esi
  801c39:	53                   	push   %ebx
  801c3a:	83 ec 1c             	sub    $0x1c,%esp
  801c3d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c40:	89 3c 24             	mov    %edi,(%esp)
  801c43:	e8 cc f4 ff ff       	call   801114 <fd2data>
  801c48:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c4a:	be 00 00 00 00       	mov    $0x0,%esi
  801c4f:	eb 3a                	jmp    801c8b <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c51:	85 f6                	test   %esi,%esi
  801c53:	74 04                	je     801c59 <devpipe_read+0x25>
				return i;
  801c55:	89 f0                	mov    %esi,%eax
  801c57:	eb 40                	jmp    801c99 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c59:	89 da                	mov    %ebx,%edx
  801c5b:	89 f8                	mov    %edi,%eax
  801c5d:	e8 f5 fe ff ff       	call   801b57 <_pipeisclosed>
  801c62:	85 c0                	test   %eax,%eax
  801c64:	75 2e                	jne    801c94 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c66:	e8 0f f2 ff ff       	call   800e7a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c6b:	8b 03                	mov    (%ebx),%eax
  801c6d:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c70:	74 df                	je     801c51 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c72:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801c77:	79 05                	jns    801c7e <devpipe_read+0x4a>
  801c79:	48                   	dec    %eax
  801c7a:	83 c8 e0             	or     $0xffffffe0,%eax
  801c7d:	40                   	inc    %eax
  801c7e:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801c82:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c85:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801c88:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c8a:	46                   	inc    %esi
  801c8b:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c8e:	75 db                	jne    801c6b <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c90:	89 f0                	mov    %esi,%eax
  801c92:	eb 05                	jmp    801c99 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c94:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c99:	83 c4 1c             	add    $0x1c,%esp
  801c9c:	5b                   	pop    %ebx
  801c9d:	5e                   	pop    %esi
  801c9e:	5f                   	pop    %edi
  801c9f:	5d                   	pop    %ebp
  801ca0:	c3                   	ret    

00801ca1 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ca1:	55                   	push   %ebp
  801ca2:	89 e5                	mov    %esp,%ebp
  801ca4:	57                   	push   %edi
  801ca5:	56                   	push   %esi
  801ca6:	53                   	push   %ebx
  801ca7:	83 ec 3c             	sub    $0x3c,%esp
  801caa:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801cad:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801cb0:	89 04 24             	mov    %eax,(%esp)
  801cb3:	e8 77 f4 ff ff       	call   80112f <fd_alloc>
  801cb8:	89 c3                	mov    %eax,%ebx
  801cba:	85 c0                	test   %eax,%eax
  801cbc:	0f 88 45 01 00 00    	js     801e07 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cc2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801cc9:	00 
  801cca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ccd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cd1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cd8:	e8 bc f1 ff ff       	call   800e99 <sys_page_alloc>
  801cdd:	89 c3                	mov    %eax,%ebx
  801cdf:	85 c0                	test   %eax,%eax
  801ce1:	0f 88 20 01 00 00    	js     801e07 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ce7:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801cea:	89 04 24             	mov    %eax,(%esp)
  801ced:	e8 3d f4 ff ff       	call   80112f <fd_alloc>
  801cf2:	89 c3                	mov    %eax,%ebx
  801cf4:	85 c0                	test   %eax,%eax
  801cf6:	0f 88 f8 00 00 00    	js     801df4 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cfc:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d03:	00 
  801d04:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d07:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d0b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d12:	e8 82 f1 ff ff       	call   800e99 <sys_page_alloc>
  801d17:	89 c3                	mov    %eax,%ebx
  801d19:	85 c0                	test   %eax,%eax
  801d1b:	0f 88 d3 00 00 00    	js     801df4 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d21:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d24:	89 04 24             	mov    %eax,(%esp)
  801d27:	e8 e8 f3 ff ff       	call   801114 <fd2data>
  801d2c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d2e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d35:	00 
  801d36:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d3a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d41:	e8 53 f1 ff ff       	call   800e99 <sys_page_alloc>
  801d46:	89 c3                	mov    %eax,%ebx
  801d48:	85 c0                	test   %eax,%eax
  801d4a:	0f 88 91 00 00 00    	js     801de1 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d50:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d53:	89 04 24             	mov    %eax,(%esp)
  801d56:	e8 b9 f3 ff ff       	call   801114 <fd2data>
  801d5b:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801d62:	00 
  801d63:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d67:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d6e:	00 
  801d6f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d73:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d7a:	e8 6e f1 ff ff       	call   800eed <sys_page_map>
  801d7f:	89 c3                	mov    %eax,%ebx
  801d81:	85 c0                	test   %eax,%eax
  801d83:	78 4c                	js     801dd1 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d85:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d8b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d8e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d90:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d93:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d9a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801da0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801da3:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801da5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801da8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801daf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801db2:	89 04 24             	mov    %eax,(%esp)
  801db5:	e8 4a f3 ff ff       	call   801104 <fd2num>
  801dba:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801dbc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801dbf:	89 04 24             	mov    %eax,(%esp)
  801dc2:	e8 3d f3 ff ff       	call   801104 <fd2num>
  801dc7:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801dca:	bb 00 00 00 00       	mov    $0x0,%ebx
  801dcf:	eb 36                	jmp    801e07 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801dd1:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dd5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ddc:	e8 5f f1 ff ff       	call   800f40 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801de1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801de4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801de8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801def:	e8 4c f1 ff ff       	call   800f40 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801df4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801df7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dfb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e02:	e8 39 f1 ff ff       	call   800f40 <sys_page_unmap>
    err:
	return r;
}
  801e07:	89 d8                	mov    %ebx,%eax
  801e09:	83 c4 3c             	add    $0x3c,%esp
  801e0c:	5b                   	pop    %ebx
  801e0d:	5e                   	pop    %esi
  801e0e:	5f                   	pop    %edi
  801e0f:	5d                   	pop    %ebp
  801e10:	c3                   	ret    

00801e11 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e11:	55                   	push   %ebp
  801e12:	89 e5                	mov    %esp,%ebp
  801e14:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e17:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e1a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e1e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e21:	89 04 24             	mov    %eax,(%esp)
  801e24:	e8 59 f3 ff ff       	call   801182 <fd_lookup>
  801e29:	85 c0                	test   %eax,%eax
  801e2b:	78 15                	js     801e42 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e30:	89 04 24             	mov    %eax,(%esp)
  801e33:	e8 dc f2 ff ff       	call   801114 <fd2data>
	return _pipeisclosed(fd, p);
  801e38:	89 c2                	mov    %eax,%edx
  801e3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e3d:	e8 15 fd ff ff       	call   801b57 <_pipeisclosed>
}
  801e42:	c9                   	leave  
  801e43:	c3                   	ret    

00801e44 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e44:	55                   	push   %ebp
  801e45:	89 e5                	mov    %esp,%ebp
  801e47:	56                   	push   %esi
  801e48:	53                   	push   %ebx
  801e49:	83 ec 10             	sub    $0x10,%esp
  801e4c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801e4f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e52:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int r;
		
	r = sys_ipc_recv(pg?pg:(void*)UTOP);
  801e55:	85 c0                	test   %eax,%eax
  801e57:	75 05                	jne    801e5e <ipc_recv+0x1a>
  801e59:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801e5e:	89 04 24             	mov    %eax,(%esp)
  801e61:	e8 49 f2 ff ff       	call   8010af <sys_ipc_recv>
	if (from_env_store != NULL)
  801e66:	85 db                	test   %ebx,%ebx
  801e68:	74 0b                	je     801e75 <ipc_recv+0x31>
		*from_env_store = thisenv->env_ipc_from; 
  801e6a:	8b 15 04 44 80 00    	mov    0x804404,%edx
  801e70:	8b 52 74             	mov    0x74(%edx),%edx
  801e73:	89 13                	mov    %edx,(%ebx)
	if (perm_store != NULL)
  801e75:	85 f6                	test   %esi,%esi
  801e77:	74 0b                	je     801e84 <ipc_recv+0x40>
		*perm_store = thisenv->env_ipc_perm;
  801e79:	8b 15 04 44 80 00    	mov    0x804404,%edx
  801e7f:	8b 52 78             	mov    0x78(%edx),%edx
  801e82:	89 16                	mov    %edx,(%esi)
	
	if (r < 0){
  801e84:	85 c0                	test   %eax,%eax
  801e86:	79 16                	jns    801e9e <ipc_recv+0x5a>
		if(from_env_store != NULL)
  801e88:	85 db                	test   %ebx,%ebx
  801e8a:	74 06                	je     801e92 <ipc_recv+0x4e>
			*from_env_store = 0;
  801e8c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store != NULL)	
  801e92:	85 f6                	test   %esi,%esi
  801e94:	74 10                	je     801ea6 <ipc_recv+0x62>
			*perm_store = 0;
  801e96:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801e9c:	eb 08                	jmp    801ea6 <ipc_recv+0x62>
		return r;
	}
	
	return thisenv->env_ipc_value;
  801e9e:	a1 04 44 80 00       	mov    0x804404,%eax
  801ea3:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ea6:	83 c4 10             	add    $0x10,%esp
  801ea9:	5b                   	pop    %ebx
  801eaa:	5e                   	pop    %esi
  801eab:	5d                   	pop    %ebp
  801eac:	c3                   	ret    

00801ead <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ead:	55                   	push   %ebp
  801eae:	89 e5                	mov    %esp,%ebp
  801eb0:	57                   	push   %edi
  801eb1:	56                   	push   %esi
  801eb2:	53                   	push   %ebx
  801eb3:	83 ec 1c             	sub    $0x1c,%esp
  801eb6:	8b 75 08             	mov    0x8(%ebp),%esi
  801eb9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801ebc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  801ebf:	eb 2a                	jmp    801eeb <ipc_send+0x3e>
		if (r != -E_IPC_NOT_RECV)
  801ec1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ec4:	74 20                	je     801ee6 <ipc_send+0x39>
			panic("ipc_send: sys_ipc_try_send failed %e", r);
  801ec6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801eca:	c7 44 24 08 bc 26 80 	movl   $0x8026bc,0x8(%esp)
  801ed1:	00 
  801ed2:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  801ed9:	00 
  801eda:	c7 04 24 e4 26 80 00 	movl   $0x8026e4,(%esp)
  801ee1:	e8 3e e4 ff ff       	call   800324 <_panic>
		sys_yield();
  801ee6:	e8 8f ef ff ff       	call   800e7a <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  801eeb:	85 db                	test   %ebx,%ebx
  801eed:	75 07                	jne    801ef6 <ipc_send+0x49>
  801eef:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ef4:	eb 02                	jmp    801ef8 <ipc_send+0x4b>
  801ef6:	89 d8                	mov    %ebx,%eax
  801ef8:	8b 55 14             	mov    0x14(%ebp),%edx
  801efb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801eff:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f03:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801f07:	89 34 24             	mov    %esi,(%esp)
  801f0a:	e8 7d f1 ff ff       	call   80108c <sys_ipc_try_send>
  801f0f:	85 c0                	test   %eax,%eax
  801f11:	78 ae                	js     801ec1 <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: sys_ipc_try_send failed %e", r);
		sys_yield();
	}
}
  801f13:	83 c4 1c             	add    $0x1c,%esp
  801f16:	5b                   	pop    %ebx
  801f17:	5e                   	pop    %esi
  801f18:	5f                   	pop    %edi
  801f19:	5d                   	pop    %ebp
  801f1a:	c3                   	ret    

00801f1b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f1b:	55                   	push   %ebp
  801f1c:	89 e5                	mov    %esp,%ebp
  801f1e:	53                   	push   %ebx
  801f1f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801f22:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f27:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801f2e:	89 c2                	mov    %eax,%edx
  801f30:	c1 e2 07             	shl    $0x7,%edx
  801f33:	29 ca                	sub    %ecx,%edx
  801f35:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f3b:	8b 52 50             	mov    0x50(%edx),%edx
  801f3e:	39 da                	cmp    %ebx,%edx
  801f40:	75 0f                	jne    801f51 <ipc_find_env+0x36>
			return envs[i].env_id;
  801f42:	c1 e0 07             	shl    $0x7,%eax
  801f45:	29 c8                	sub    %ecx,%eax
  801f47:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801f4c:	8b 40 40             	mov    0x40(%eax),%eax
  801f4f:	eb 0c                	jmp    801f5d <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f51:	40                   	inc    %eax
  801f52:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f57:	75 ce                	jne    801f27 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f59:	66 b8 00 00          	mov    $0x0,%ax
}
  801f5d:	5b                   	pop    %ebx
  801f5e:	5d                   	pop    %ebp
  801f5f:	c3                   	ret    

00801f60 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f60:	55                   	push   %ebp
  801f61:	89 e5                	mov    %esp,%ebp
  801f63:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f66:	89 c2                	mov    %eax,%edx
  801f68:	c1 ea 16             	shr    $0x16,%edx
  801f6b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801f72:	f6 c2 01             	test   $0x1,%dl
  801f75:	74 1e                	je     801f95 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f77:	c1 e8 0c             	shr    $0xc,%eax
  801f7a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801f81:	a8 01                	test   $0x1,%al
  801f83:	74 17                	je     801f9c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f85:	c1 e8 0c             	shr    $0xc,%eax
  801f88:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801f8f:	ef 
  801f90:	0f b7 c0             	movzwl %ax,%eax
  801f93:	eb 0c                	jmp    801fa1 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801f95:	b8 00 00 00 00       	mov    $0x0,%eax
  801f9a:	eb 05                	jmp    801fa1 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801f9c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801fa1:	5d                   	pop    %ebp
  801fa2:	c3                   	ret    
	...

00801fa4 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801fa4:	55                   	push   %ebp
  801fa5:	57                   	push   %edi
  801fa6:	56                   	push   %esi
  801fa7:	83 ec 10             	sub    $0x10,%esp
  801faa:	8b 74 24 20          	mov    0x20(%esp),%esi
  801fae:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801fb2:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fb6:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  801fba:	89 cd                	mov    %ecx,%ebp
  801fbc:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801fc0:	85 c0                	test   %eax,%eax
  801fc2:	75 2c                	jne    801ff0 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801fc4:	39 f9                	cmp    %edi,%ecx
  801fc6:	77 68                	ja     802030 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801fc8:	85 c9                	test   %ecx,%ecx
  801fca:	75 0b                	jne    801fd7 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801fcc:	b8 01 00 00 00       	mov    $0x1,%eax
  801fd1:	31 d2                	xor    %edx,%edx
  801fd3:	f7 f1                	div    %ecx
  801fd5:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801fd7:	31 d2                	xor    %edx,%edx
  801fd9:	89 f8                	mov    %edi,%eax
  801fdb:	f7 f1                	div    %ecx
  801fdd:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801fdf:	89 f0                	mov    %esi,%eax
  801fe1:	f7 f1                	div    %ecx
  801fe3:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801fe5:	89 f0                	mov    %esi,%eax
  801fe7:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801fe9:	83 c4 10             	add    $0x10,%esp
  801fec:	5e                   	pop    %esi
  801fed:	5f                   	pop    %edi
  801fee:	5d                   	pop    %ebp
  801fef:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801ff0:	39 f8                	cmp    %edi,%eax
  801ff2:	77 2c                	ja     802020 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801ff4:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  801ff7:	83 f6 1f             	xor    $0x1f,%esi
  801ffa:	75 4c                	jne    802048 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801ffc:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801ffe:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802003:	72 0a                	jb     80200f <__udivdi3+0x6b>
  802005:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802009:	0f 87 ad 00 00 00    	ja     8020bc <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80200f:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802014:	89 f0                	mov    %esi,%eax
  802016:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802018:	83 c4 10             	add    $0x10,%esp
  80201b:	5e                   	pop    %esi
  80201c:	5f                   	pop    %edi
  80201d:	5d                   	pop    %ebp
  80201e:	c3                   	ret    
  80201f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802020:	31 ff                	xor    %edi,%edi
  802022:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802024:	89 f0                	mov    %esi,%eax
  802026:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802028:	83 c4 10             	add    $0x10,%esp
  80202b:	5e                   	pop    %esi
  80202c:	5f                   	pop    %edi
  80202d:	5d                   	pop    %ebp
  80202e:	c3                   	ret    
  80202f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802030:	89 fa                	mov    %edi,%edx
  802032:	89 f0                	mov    %esi,%eax
  802034:	f7 f1                	div    %ecx
  802036:	89 c6                	mov    %eax,%esi
  802038:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80203a:	89 f0                	mov    %esi,%eax
  80203c:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80203e:	83 c4 10             	add    $0x10,%esp
  802041:	5e                   	pop    %esi
  802042:	5f                   	pop    %edi
  802043:	5d                   	pop    %ebp
  802044:	c3                   	ret    
  802045:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802048:	89 f1                	mov    %esi,%ecx
  80204a:	d3 e0                	shl    %cl,%eax
  80204c:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802050:	b8 20 00 00 00       	mov    $0x20,%eax
  802055:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802057:	89 ea                	mov    %ebp,%edx
  802059:	88 c1                	mov    %al,%cl
  80205b:	d3 ea                	shr    %cl,%edx
  80205d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802061:	09 ca                	or     %ecx,%edx
  802063:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  802067:	89 f1                	mov    %esi,%ecx
  802069:	d3 e5                	shl    %cl,%ebp
  80206b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  80206f:	89 fd                	mov    %edi,%ebp
  802071:	88 c1                	mov    %al,%cl
  802073:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802075:	89 fa                	mov    %edi,%edx
  802077:	89 f1                	mov    %esi,%ecx
  802079:	d3 e2                	shl    %cl,%edx
  80207b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80207f:	88 c1                	mov    %al,%cl
  802081:	d3 ef                	shr    %cl,%edi
  802083:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802085:	89 f8                	mov    %edi,%eax
  802087:	89 ea                	mov    %ebp,%edx
  802089:	f7 74 24 08          	divl   0x8(%esp)
  80208d:	89 d1                	mov    %edx,%ecx
  80208f:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802091:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802095:	39 d1                	cmp    %edx,%ecx
  802097:	72 17                	jb     8020b0 <__udivdi3+0x10c>
  802099:	74 09                	je     8020a4 <__udivdi3+0x100>
  80209b:	89 fe                	mov    %edi,%esi
  80209d:	31 ff                	xor    %edi,%edi
  80209f:	e9 41 ff ff ff       	jmp    801fe5 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8020a4:	8b 54 24 04          	mov    0x4(%esp),%edx
  8020a8:	89 f1                	mov    %esi,%ecx
  8020aa:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8020ac:	39 c2                	cmp    %eax,%edx
  8020ae:	73 eb                	jae    80209b <__udivdi3+0xf7>
		{
		  q0--;
  8020b0:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8020b3:	31 ff                	xor    %edi,%edi
  8020b5:	e9 2b ff ff ff       	jmp    801fe5 <__udivdi3+0x41>
  8020ba:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8020bc:	31 f6                	xor    %esi,%esi
  8020be:	e9 22 ff ff ff       	jmp    801fe5 <__udivdi3+0x41>
	...

008020c4 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8020c4:	55                   	push   %ebp
  8020c5:	57                   	push   %edi
  8020c6:	56                   	push   %esi
  8020c7:	83 ec 20             	sub    $0x20,%esp
  8020ca:	8b 44 24 30          	mov    0x30(%esp),%eax
  8020ce:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8020d2:	89 44 24 14          	mov    %eax,0x14(%esp)
  8020d6:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  8020da:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020de:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8020e2:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  8020e4:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8020e6:	85 ed                	test   %ebp,%ebp
  8020e8:	75 16                	jne    802100 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  8020ea:	39 f1                	cmp    %esi,%ecx
  8020ec:	0f 86 a6 00 00 00    	jbe    802198 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8020f2:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8020f4:	89 d0                	mov    %edx,%eax
  8020f6:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8020f8:	83 c4 20             	add    $0x20,%esp
  8020fb:	5e                   	pop    %esi
  8020fc:	5f                   	pop    %edi
  8020fd:	5d                   	pop    %ebp
  8020fe:	c3                   	ret    
  8020ff:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802100:	39 f5                	cmp    %esi,%ebp
  802102:	0f 87 ac 00 00 00    	ja     8021b4 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802108:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  80210b:	83 f0 1f             	xor    $0x1f,%eax
  80210e:	89 44 24 10          	mov    %eax,0x10(%esp)
  802112:	0f 84 a8 00 00 00    	je     8021c0 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802118:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80211c:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80211e:	bf 20 00 00 00       	mov    $0x20,%edi
  802123:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802127:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80212b:	89 f9                	mov    %edi,%ecx
  80212d:	d3 e8                	shr    %cl,%eax
  80212f:	09 e8                	or     %ebp,%eax
  802131:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  802135:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802139:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80213d:	d3 e0                	shl    %cl,%eax
  80213f:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802143:	89 f2                	mov    %esi,%edx
  802145:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802147:	8b 44 24 14          	mov    0x14(%esp),%eax
  80214b:	d3 e0                	shl    %cl,%eax
  80214d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802151:	8b 44 24 14          	mov    0x14(%esp),%eax
  802155:	89 f9                	mov    %edi,%ecx
  802157:	d3 e8                	shr    %cl,%eax
  802159:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80215b:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80215d:	89 f2                	mov    %esi,%edx
  80215f:	f7 74 24 18          	divl   0x18(%esp)
  802163:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802165:	f7 64 24 0c          	mull   0xc(%esp)
  802169:	89 c5                	mov    %eax,%ebp
  80216b:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80216d:	39 d6                	cmp    %edx,%esi
  80216f:	72 67                	jb     8021d8 <__umoddi3+0x114>
  802171:	74 75                	je     8021e8 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802173:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802177:	29 e8                	sub    %ebp,%eax
  802179:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80217b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80217f:	d3 e8                	shr    %cl,%eax
  802181:	89 f2                	mov    %esi,%edx
  802183:	89 f9                	mov    %edi,%ecx
  802185:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802187:	09 d0                	or     %edx,%eax
  802189:	89 f2                	mov    %esi,%edx
  80218b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80218f:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802191:	83 c4 20             	add    $0x20,%esp
  802194:	5e                   	pop    %esi
  802195:	5f                   	pop    %edi
  802196:	5d                   	pop    %ebp
  802197:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802198:	85 c9                	test   %ecx,%ecx
  80219a:	75 0b                	jne    8021a7 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80219c:	b8 01 00 00 00       	mov    $0x1,%eax
  8021a1:	31 d2                	xor    %edx,%edx
  8021a3:	f7 f1                	div    %ecx
  8021a5:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8021a7:	89 f0                	mov    %esi,%eax
  8021a9:	31 d2                	xor    %edx,%edx
  8021ab:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8021ad:	89 f8                	mov    %edi,%eax
  8021af:	e9 3e ff ff ff       	jmp    8020f2 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8021b4:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8021b6:	83 c4 20             	add    $0x20,%esp
  8021b9:	5e                   	pop    %esi
  8021ba:	5f                   	pop    %edi
  8021bb:	5d                   	pop    %ebp
  8021bc:	c3                   	ret    
  8021bd:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8021c0:	39 f5                	cmp    %esi,%ebp
  8021c2:	72 04                	jb     8021c8 <__umoddi3+0x104>
  8021c4:	39 f9                	cmp    %edi,%ecx
  8021c6:	77 06                	ja     8021ce <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8021c8:	89 f2                	mov    %esi,%edx
  8021ca:	29 cf                	sub    %ecx,%edi
  8021cc:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8021ce:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8021d0:	83 c4 20             	add    $0x20,%esp
  8021d3:	5e                   	pop    %esi
  8021d4:	5f                   	pop    %edi
  8021d5:	5d                   	pop    %ebp
  8021d6:	c3                   	ret    
  8021d7:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8021d8:	89 d1                	mov    %edx,%ecx
  8021da:	89 c5                	mov    %eax,%ebp
  8021dc:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8021e0:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8021e4:	eb 8d                	jmp    802173 <__umoddi3+0xaf>
  8021e6:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8021e8:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8021ec:	72 ea                	jb     8021d8 <__umoddi3+0x114>
  8021ee:	89 f1                	mov    %esi,%ecx
  8021f0:	eb 81                	jmp    802173 <__umoddi3+0xaf>
