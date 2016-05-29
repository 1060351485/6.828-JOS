
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
  800040:	e8 29 0e 00 00       	call   800e6e <sys_yield>
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
  80004f:	e8 da 12 00 00       	call   80132e <close>
	if ((r = opencons()) < 0)
  800054:	e8 0f 02 00 00       	call   800268 <opencons>
  800059:	85 c0                	test   %eax,%eax
  80005b:	79 20                	jns    80007d <umain+0x49>
		panic("opencons: %e", r);
  80005d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800061:	c7 44 24 08 60 27 80 	movl   $0x802760,0x8(%esp)
  800068:	00 
  800069:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  800070:	00 
  800071:	c7 04 24 6d 27 80 00 	movl   $0x80276d,(%esp)
  800078:	e8 9b 02 00 00       	call   800318 <_panic>
	if (r != 0)
  80007d:	85 c0                	test   %eax,%eax
  80007f:	74 20                	je     8000a1 <umain+0x6d>
		panic("first opencons used fd %d", r);
  800081:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800085:	c7 44 24 08 7c 27 80 	movl   $0x80277c,0x8(%esp)
  80008c:	00 
  80008d:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800094:	00 
  800095:	c7 04 24 6d 27 80 00 	movl   $0x80276d,(%esp)
  80009c:	e8 77 02 00 00       	call   800318 <_panic>
	if ((r = dup(0, 1)) < 0)
  8000a1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8000a8:	00 
  8000a9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b0:	e8 ca 12 00 00       	call   80137f <dup>
  8000b5:	85 c0                	test   %eax,%eax
  8000b7:	79 20                	jns    8000d9 <umain+0xa5>
		panic("dup: %e", r);
  8000b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000bd:	c7 44 24 08 96 27 80 	movl   $0x802796,0x8(%esp)
  8000c4:	00 
  8000c5:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
  8000cc:	00 
  8000cd:	c7 04 24 6d 27 80 00 	movl   $0x80276d,(%esp)
  8000d4:	e8 3f 02 00 00       	call   800318 <_panic>

	for(;;){
		char *buf;

		buf = readline("Type a line: ");
  8000d9:	c7 04 24 9e 27 80 00 	movl   $0x80279e,(%esp)
  8000e0:	e8 a3 08 00 00       	call   800988 <readline>
		if (buf != NULL)
  8000e5:	85 c0                	test   %eax,%eax
  8000e7:	74 1a                	je     800103 <umain+0xcf>
			fprintf(1, "%s\n", buf);
  8000e9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000ed:	c7 44 24 04 ac 27 80 	movl   $0x8027ac,0x4(%esp)
  8000f4:	00 
  8000f5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8000fc:	e8 fb 19 00 00       	call   801afc <fprintf>
  800101:	eb d6                	jmp    8000d9 <umain+0xa5>
		else
			fprintf(1, "(end of file received)\n");
  800103:	c7 44 24 04 b0 27 80 	movl   $0x8027b0,0x4(%esp)
  80010a:	00 
  80010b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800112:	e8 e5 19 00 00       	call   801afc <fprintf>
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
  80012c:	c7 44 24 04 c8 27 80 	movl   $0x8027c8,0x4(%esp)
  800133:	00 
  800134:	8b 45 0c             	mov    0xc(%ebp),%eax
  800137:	89 04 24             	mov    %eax,(%esp)
  80013a:	e8 5c 09 00 00       	call   800a9b <strcpy>
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
  80017c:	e8 93 0a 00 00       	call   800c14 <memmove>
		sys_cputs(buf, m);
  800181:	89 74 24 04          	mov    %esi,0x4(%esp)
  800185:	89 3c 24             	mov    %edi,(%esp)
  800188:	e8 33 0c 00 00       	call   800dc0 <sys_cputs>
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
  8001af:	e8 ba 0c 00 00       	call   800e6e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8001b4:	e8 25 0c 00 00       	call   800dde <sys_cgetc>
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
  8001fc:	e8 bf 0b 00 00       	call   800dc0 <sys_cputs>
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
  80021f:	e8 6e 12 00 00       	call   801492 <read>
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
  80024c:	e8 a5 0f 00 00       	call   8011f6 <fd_lookup>
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
  800274:	e8 2a 0f 00 00       	call   8011a3 <fd_alloc>
  800279:	85 c0                	test   %eax,%eax
  80027b:	78 3c                	js     8002b9 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80027d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800284:	00 
  800285:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800288:	89 44 24 04          	mov    %eax,0x4(%esp)
  80028c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800293:	e8 f5 0b 00 00       	call   800e8d <sys_page_alloc>
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
  8002b4:	e8 bf 0e 00 00       	call   801178 <fd2num>
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
  8002ca:	e8 80 0b 00 00       	call   800e4f <sys_getenvid>
  8002cf:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002d4:	c1 e0 07             	shl    $0x7,%eax
  8002d7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002dc:	a3 08 44 80 00       	mov    %eax,0x804408

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002e1:	85 f6                	test   %esi,%esi
  8002e3:	7e 07                	jle    8002ec <libmain+0x30>
		binaryname = argv[0];
  8002e5:	8b 03                	mov    (%ebx),%eax
  8002e7:	a3 1c 30 80 00       	mov    %eax,0x80301c

	// call user main routine
	umain(argc, argv);
  8002ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002f0:	89 34 24             	mov    %esi,(%esp)
  8002f3:	e8 3c fd ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8002f8:	e8 07 00 00 00       	call   800304 <exit>
}
  8002fd:	83 c4 10             	add    $0x10,%esp
  800300:	5b                   	pop    %ebx
  800301:	5e                   	pop    %esi
  800302:	5d                   	pop    %ebp
  800303:	c3                   	ret    

00800304 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800304:	55                   	push   %ebp
  800305:	89 e5                	mov    %esp,%ebp
  800307:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  80030a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800311:	e8 e7 0a 00 00       	call   800dfd <sys_env_destroy>
}
  800316:	c9                   	leave  
  800317:	c3                   	ret    

00800318 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
  80031b:	56                   	push   %esi
  80031c:	53                   	push   %ebx
  80031d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800320:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800323:	8b 1d 1c 30 80 00    	mov    0x80301c,%ebx
  800329:	e8 21 0b 00 00       	call   800e4f <sys_getenvid>
  80032e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800331:	89 54 24 10          	mov    %edx,0x10(%esp)
  800335:	8b 55 08             	mov    0x8(%ebp),%edx
  800338:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80033c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800340:	89 44 24 04          	mov    %eax,0x4(%esp)
  800344:	c7 04 24 e0 27 80 00 	movl   $0x8027e0,(%esp)
  80034b:	e8 c0 00 00 00       	call   800410 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800350:	89 74 24 04          	mov    %esi,0x4(%esp)
  800354:	8b 45 10             	mov    0x10(%ebp),%eax
  800357:	89 04 24             	mov    %eax,(%esp)
  80035a:	e8 50 00 00 00       	call   8003af <vcprintf>
	cprintf("\n");
  80035f:	c7 04 24 c6 27 80 00 	movl   $0x8027c6,(%esp)
  800366:	e8 a5 00 00 00       	call   800410 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80036b:	cc                   	int3   
  80036c:	eb fd                	jmp    80036b <_panic+0x53>
	...

00800370 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800370:	55                   	push   %ebp
  800371:	89 e5                	mov    %esp,%ebp
  800373:	53                   	push   %ebx
  800374:	83 ec 14             	sub    $0x14,%esp
  800377:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80037a:	8b 03                	mov    (%ebx),%eax
  80037c:	8b 55 08             	mov    0x8(%ebp),%edx
  80037f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800383:	40                   	inc    %eax
  800384:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800386:	3d ff 00 00 00       	cmp    $0xff,%eax
  80038b:	75 19                	jne    8003a6 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80038d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800394:	00 
  800395:	8d 43 08             	lea    0x8(%ebx),%eax
  800398:	89 04 24             	mov    %eax,(%esp)
  80039b:	e8 20 0a 00 00       	call   800dc0 <sys_cputs>
		b->idx = 0;
  8003a0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8003a6:	ff 43 04             	incl   0x4(%ebx)
}
  8003a9:	83 c4 14             	add    $0x14,%esp
  8003ac:	5b                   	pop    %ebx
  8003ad:	5d                   	pop    %ebp
  8003ae:	c3                   	ret    

008003af <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003af:	55                   	push   %ebp
  8003b0:	89 e5                	mov    %esp,%ebp
  8003b2:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8003b8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003bf:	00 00 00 
	b.cnt = 0;
  8003c2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003c9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003da:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003e4:	c7 04 24 70 03 80 00 	movl   $0x800370,(%esp)
  8003eb:	e8 82 01 00 00       	call   800572 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003f0:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8003f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003fa:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800400:	89 04 24             	mov    %eax,(%esp)
  800403:	e8 b8 09 00 00       	call   800dc0 <sys_cputs>

	return b.cnt;
}
  800408:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80040e:	c9                   	leave  
  80040f:	c3                   	ret    

00800410 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800410:	55                   	push   %ebp
  800411:	89 e5                	mov    %esp,%ebp
  800413:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800416:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800419:	89 44 24 04          	mov    %eax,0x4(%esp)
  80041d:	8b 45 08             	mov    0x8(%ebp),%eax
  800420:	89 04 24             	mov    %eax,(%esp)
  800423:	e8 87 ff ff ff       	call   8003af <vcprintf>
	va_end(ap);

	return cnt;
}
  800428:	c9                   	leave  
  800429:	c3                   	ret    
	...

0080042c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80042c:	55                   	push   %ebp
  80042d:	89 e5                	mov    %esp,%ebp
  80042f:	57                   	push   %edi
  800430:	56                   	push   %esi
  800431:	53                   	push   %ebx
  800432:	83 ec 3c             	sub    $0x3c,%esp
  800435:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800438:	89 d7                	mov    %edx,%edi
  80043a:	8b 45 08             	mov    0x8(%ebp),%eax
  80043d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800440:	8b 45 0c             	mov    0xc(%ebp),%eax
  800443:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800446:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800449:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80044c:	85 c0                	test   %eax,%eax
  80044e:	75 08                	jne    800458 <printnum+0x2c>
  800450:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800453:	39 45 10             	cmp    %eax,0x10(%ebp)
  800456:	77 57                	ja     8004af <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800458:	89 74 24 10          	mov    %esi,0x10(%esp)
  80045c:	4b                   	dec    %ebx
  80045d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800461:	8b 45 10             	mov    0x10(%ebp),%eax
  800464:	89 44 24 08          	mov    %eax,0x8(%esp)
  800468:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80046c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800470:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800477:	00 
  800478:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80047b:	89 04 24             	mov    %eax,(%esp)
  80047e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800481:	89 44 24 04          	mov    %eax,0x4(%esp)
  800485:	e8 7e 20 00 00       	call   802508 <__udivdi3>
  80048a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80048e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800492:	89 04 24             	mov    %eax,(%esp)
  800495:	89 54 24 04          	mov    %edx,0x4(%esp)
  800499:	89 fa                	mov    %edi,%edx
  80049b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80049e:	e8 89 ff ff ff       	call   80042c <printnum>
  8004a3:	eb 0f                	jmp    8004b4 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004a5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004a9:	89 34 24             	mov    %esi,(%esp)
  8004ac:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004af:	4b                   	dec    %ebx
  8004b0:	85 db                	test   %ebx,%ebx
  8004b2:	7f f1                	jg     8004a5 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004b4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004b8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8004bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8004bf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004c3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004ca:	00 
  8004cb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004ce:	89 04 24             	mov    %eax,(%esp)
  8004d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004d8:	e8 4b 21 00 00       	call   802628 <__umoddi3>
  8004dd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004e1:	0f be 80 03 28 80 00 	movsbl 0x802803(%eax),%eax
  8004e8:	89 04 24             	mov    %eax,(%esp)
  8004eb:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8004ee:	83 c4 3c             	add    $0x3c,%esp
  8004f1:	5b                   	pop    %ebx
  8004f2:	5e                   	pop    %esi
  8004f3:	5f                   	pop    %edi
  8004f4:	5d                   	pop    %ebp
  8004f5:	c3                   	ret    

008004f6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004f6:	55                   	push   %ebp
  8004f7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004f9:	83 fa 01             	cmp    $0x1,%edx
  8004fc:	7e 0e                	jle    80050c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004fe:	8b 10                	mov    (%eax),%edx
  800500:	8d 4a 08             	lea    0x8(%edx),%ecx
  800503:	89 08                	mov    %ecx,(%eax)
  800505:	8b 02                	mov    (%edx),%eax
  800507:	8b 52 04             	mov    0x4(%edx),%edx
  80050a:	eb 22                	jmp    80052e <getuint+0x38>
	else if (lflag)
  80050c:	85 d2                	test   %edx,%edx
  80050e:	74 10                	je     800520 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800510:	8b 10                	mov    (%eax),%edx
  800512:	8d 4a 04             	lea    0x4(%edx),%ecx
  800515:	89 08                	mov    %ecx,(%eax)
  800517:	8b 02                	mov    (%edx),%eax
  800519:	ba 00 00 00 00       	mov    $0x0,%edx
  80051e:	eb 0e                	jmp    80052e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800520:	8b 10                	mov    (%eax),%edx
  800522:	8d 4a 04             	lea    0x4(%edx),%ecx
  800525:	89 08                	mov    %ecx,(%eax)
  800527:	8b 02                	mov    (%edx),%eax
  800529:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80052e:	5d                   	pop    %ebp
  80052f:	c3                   	ret    

00800530 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800530:	55                   	push   %ebp
  800531:	89 e5                	mov    %esp,%ebp
  800533:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800536:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800539:	8b 10                	mov    (%eax),%edx
  80053b:	3b 50 04             	cmp    0x4(%eax),%edx
  80053e:	73 08                	jae    800548 <sprintputch+0x18>
		*b->buf++ = ch;
  800540:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800543:	88 0a                	mov    %cl,(%edx)
  800545:	42                   	inc    %edx
  800546:	89 10                	mov    %edx,(%eax)
}
  800548:	5d                   	pop    %ebp
  800549:	c3                   	ret    

0080054a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80054a:	55                   	push   %ebp
  80054b:	89 e5                	mov    %esp,%ebp
  80054d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800550:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800553:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800557:	8b 45 10             	mov    0x10(%ebp),%eax
  80055a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80055e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800561:	89 44 24 04          	mov    %eax,0x4(%esp)
  800565:	8b 45 08             	mov    0x8(%ebp),%eax
  800568:	89 04 24             	mov    %eax,(%esp)
  80056b:	e8 02 00 00 00       	call   800572 <vprintfmt>
	va_end(ap);
}
  800570:	c9                   	leave  
  800571:	c3                   	ret    

00800572 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800572:	55                   	push   %ebp
  800573:	89 e5                	mov    %esp,%ebp
  800575:	57                   	push   %edi
  800576:	56                   	push   %esi
  800577:	53                   	push   %ebx
  800578:	83 ec 4c             	sub    $0x4c,%esp
  80057b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80057e:	8b 75 10             	mov    0x10(%ebp),%esi
  800581:	eb 12                	jmp    800595 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800583:	85 c0                	test   %eax,%eax
  800585:	0f 84 6b 03 00 00    	je     8008f6 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80058b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80058f:	89 04 24             	mov    %eax,(%esp)
  800592:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800595:	0f b6 06             	movzbl (%esi),%eax
  800598:	46                   	inc    %esi
  800599:	83 f8 25             	cmp    $0x25,%eax
  80059c:	75 e5                	jne    800583 <vprintfmt+0x11>
  80059e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8005a2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8005a9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8005ae:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8005b5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ba:	eb 26                	jmp    8005e2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bc:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8005bf:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8005c3:	eb 1d                	jmp    8005e2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005c8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8005cc:	eb 14                	jmp    8005e2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ce:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8005d1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8005d8:	eb 08                	jmp    8005e2 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8005da:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8005dd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e2:	0f b6 06             	movzbl (%esi),%eax
  8005e5:	8d 56 01             	lea    0x1(%esi),%edx
  8005e8:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005eb:	8a 16                	mov    (%esi),%dl
  8005ed:	83 ea 23             	sub    $0x23,%edx
  8005f0:	80 fa 55             	cmp    $0x55,%dl
  8005f3:	0f 87 e1 02 00 00    	ja     8008da <vprintfmt+0x368>
  8005f9:	0f b6 d2             	movzbl %dl,%edx
  8005fc:	ff 24 95 40 29 80 00 	jmp    *0x802940(,%edx,4)
  800603:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800606:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80060b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80060e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800612:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800615:	8d 50 d0             	lea    -0x30(%eax),%edx
  800618:	83 fa 09             	cmp    $0x9,%edx
  80061b:	77 2a                	ja     800647 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80061d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80061e:	eb eb                	jmp    80060b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800620:	8b 45 14             	mov    0x14(%ebp),%eax
  800623:	8d 50 04             	lea    0x4(%eax),%edx
  800626:	89 55 14             	mov    %edx,0x14(%ebp)
  800629:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80062e:	eb 17                	jmp    800647 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800630:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800634:	78 98                	js     8005ce <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800636:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800639:	eb a7                	jmp    8005e2 <vprintfmt+0x70>
  80063b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80063e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800645:	eb 9b                	jmp    8005e2 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800647:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80064b:	79 95                	jns    8005e2 <vprintfmt+0x70>
  80064d:	eb 8b                	jmp    8005da <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80064f:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800650:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800653:	eb 8d                	jmp    8005e2 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800655:	8b 45 14             	mov    0x14(%ebp),%eax
  800658:	8d 50 04             	lea    0x4(%eax),%edx
  80065b:	89 55 14             	mov    %edx,0x14(%ebp)
  80065e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800662:	8b 00                	mov    (%eax),%eax
  800664:	89 04 24             	mov    %eax,(%esp)
  800667:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80066d:	e9 23 ff ff ff       	jmp    800595 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800672:	8b 45 14             	mov    0x14(%ebp),%eax
  800675:	8d 50 04             	lea    0x4(%eax),%edx
  800678:	89 55 14             	mov    %edx,0x14(%ebp)
  80067b:	8b 00                	mov    (%eax),%eax
  80067d:	85 c0                	test   %eax,%eax
  80067f:	79 02                	jns    800683 <vprintfmt+0x111>
  800681:	f7 d8                	neg    %eax
  800683:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800685:	83 f8 11             	cmp    $0x11,%eax
  800688:	7f 0b                	jg     800695 <vprintfmt+0x123>
  80068a:	8b 04 85 a0 2a 80 00 	mov    0x802aa0(,%eax,4),%eax
  800691:	85 c0                	test   %eax,%eax
  800693:	75 23                	jne    8006b8 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800695:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800699:	c7 44 24 08 1b 28 80 	movl   $0x80281b,0x8(%esp)
  8006a0:	00 
  8006a1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a8:	89 04 24             	mov    %eax,(%esp)
  8006ab:	e8 9a fe ff ff       	call   80054a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b0:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8006b3:	e9 dd fe ff ff       	jmp    800595 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8006b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006bc:	c7 44 24 08 ed 2b 80 	movl   $0x802bed,0x8(%esp)
  8006c3:	00 
  8006c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8006cb:	89 14 24             	mov    %edx,(%esp)
  8006ce:	e8 77 fe ff ff       	call   80054a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006d6:	e9 ba fe ff ff       	jmp    800595 <vprintfmt+0x23>
  8006db:	89 f9                	mov    %edi,%ecx
  8006dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006e0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e6:	8d 50 04             	lea    0x4(%eax),%edx
  8006e9:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ec:	8b 30                	mov    (%eax),%esi
  8006ee:	85 f6                	test   %esi,%esi
  8006f0:	75 05                	jne    8006f7 <vprintfmt+0x185>
				p = "(null)";
  8006f2:	be 14 28 80 00       	mov    $0x802814,%esi
			if (width > 0 && padc != '-')
  8006f7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8006fb:	0f 8e 84 00 00 00    	jle    800785 <vprintfmt+0x213>
  800701:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800705:	74 7e                	je     800785 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800707:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80070b:	89 34 24             	mov    %esi,(%esp)
  80070e:	e8 6b 03 00 00       	call   800a7e <strnlen>
  800713:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800716:	29 c2                	sub    %eax,%edx
  800718:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80071b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80071f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800722:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800725:	89 de                	mov    %ebx,%esi
  800727:	89 d3                	mov    %edx,%ebx
  800729:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80072b:	eb 0b                	jmp    800738 <vprintfmt+0x1c6>
					putch(padc, putdat);
  80072d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800731:	89 3c 24             	mov    %edi,(%esp)
  800734:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800737:	4b                   	dec    %ebx
  800738:	85 db                	test   %ebx,%ebx
  80073a:	7f f1                	jg     80072d <vprintfmt+0x1bb>
  80073c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80073f:	89 f3                	mov    %esi,%ebx
  800741:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800744:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800747:	85 c0                	test   %eax,%eax
  800749:	79 05                	jns    800750 <vprintfmt+0x1de>
  80074b:	b8 00 00 00 00       	mov    $0x0,%eax
  800750:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800753:	29 c2                	sub    %eax,%edx
  800755:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800758:	eb 2b                	jmp    800785 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80075a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80075e:	74 18                	je     800778 <vprintfmt+0x206>
  800760:	8d 50 e0             	lea    -0x20(%eax),%edx
  800763:	83 fa 5e             	cmp    $0x5e,%edx
  800766:	76 10                	jbe    800778 <vprintfmt+0x206>
					putch('?', putdat);
  800768:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80076c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800773:	ff 55 08             	call   *0x8(%ebp)
  800776:	eb 0a                	jmp    800782 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800778:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80077c:	89 04 24             	mov    %eax,(%esp)
  80077f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800782:	ff 4d e4             	decl   -0x1c(%ebp)
  800785:	0f be 06             	movsbl (%esi),%eax
  800788:	46                   	inc    %esi
  800789:	85 c0                	test   %eax,%eax
  80078b:	74 21                	je     8007ae <vprintfmt+0x23c>
  80078d:	85 ff                	test   %edi,%edi
  80078f:	78 c9                	js     80075a <vprintfmt+0x1e8>
  800791:	4f                   	dec    %edi
  800792:	79 c6                	jns    80075a <vprintfmt+0x1e8>
  800794:	8b 7d 08             	mov    0x8(%ebp),%edi
  800797:	89 de                	mov    %ebx,%esi
  800799:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80079c:	eb 18                	jmp    8007b6 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80079e:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007a2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8007a9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007ab:	4b                   	dec    %ebx
  8007ac:	eb 08                	jmp    8007b6 <vprintfmt+0x244>
  8007ae:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007b1:	89 de                	mov    %ebx,%esi
  8007b3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8007b6:	85 db                	test   %ebx,%ebx
  8007b8:	7f e4                	jg     80079e <vprintfmt+0x22c>
  8007ba:	89 7d 08             	mov    %edi,0x8(%ebp)
  8007bd:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007bf:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007c2:	e9 ce fd ff ff       	jmp    800595 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007c7:	83 f9 01             	cmp    $0x1,%ecx
  8007ca:	7e 10                	jle    8007dc <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8007cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cf:	8d 50 08             	lea    0x8(%eax),%edx
  8007d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d5:	8b 30                	mov    (%eax),%esi
  8007d7:	8b 78 04             	mov    0x4(%eax),%edi
  8007da:	eb 26                	jmp    800802 <vprintfmt+0x290>
	else if (lflag)
  8007dc:	85 c9                	test   %ecx,%ecx
  8007de:	74 12                	je     8007f2 <vprintfmt+0x280>
		return va_arg(*ap, long);
  8007e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e3:	8d 50 04             	lea    0x4(%eax),%edx
  8007e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e9:	8b 30                	mov    (%eax),%esi
  8007eb:	89 f7                	mov    %esi,%edi
  8007ed:	c1 ff 1f             	sar    $0x1f,%edi
  8007f0:	eb 10                	jmp    800802 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8007f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f5:	8d 50 04             	lea    0x4(%eax),%edx
  8007f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8007fb:	8b 30                	mov    (%eax),%esi
  8007fd:	89 f7                	mov    %esi,%edi
  8007ff:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800802:	85 ff                	test   %edi,%edi
  800804:	78 0a                	js     800810 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800806:	b8 0a 00 00 00       	mov    $0xa,%eax
  80080b:	e9 8c 00 00 00       	jmp    80089c <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800810:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800814:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80081b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80081e:	f7 de                	neg    %esi
  800820:	83 d7 00             	adc    $0x0,%edi
  800823:	f7 df                	neg    %edi
			}
			base = 10;
  800825:	b8 0a 00 00 00       	mov    $0xa,%eax
  80082a:	eb 70                	jmp    80089c <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80082c:	89 ca                	mov    %ecx,%edx
  80082e:	8d 45 14             	lea    0x14(%ebp),%eax
  800831:	e8 c0 fc ff ff       	call   8004f6 <getuint>
  800836:	89 c6                	mov    %eax,%esi
  800838:	89 d7                	mov    %edx,%edi
			base = 10;
  80083a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80083f:	eb 5b                	jmp    80089c <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  800841:	89 ca                	mov    %ecx,%edx
  800843:	8d 45 14             	lea    0x14(%ebp),%eax
  800846:	e8 ab fc ff ff       	call   8004f6 <getuint>
  80084b:	89 c6                	mov    %eax,%esi
  80084d:	89 d7                	mov    %edx,%edi
			base = 8;
  80084f:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800854:	eb 46                	jmp    80089c <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  800856:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80085a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800861:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800864:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800868:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80086f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800872:	8b 45 14             	mov    0x14(%ebp),%eax
  800875:	8d 50 04             	lea    0x4(%eax),%edx
  800878:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80087b:	8b 30                	mov    (%eax),%esi
  80087d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800882:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800887:	eb 13                	jmp    80089c <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800889:	89 ca                	mov    %ecx,%edx
  80088b:	8d 45 14             	lea    0x14(%ebp),%eax
  80088e:	e8 63 fc ff ff       	call   8004f6 <getuint>
  800893:	89 c6                	mov    %eax,%esi
  800895:	89 d7                	mov    %edx,%edi
			base = 16;
  800897:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80089c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8008a0:	89 54 24 10          	mov    %edx,0x10(%esp)
  8008a4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008a7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8008ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008af:	89 34 24             	mov    %esi,(%esp)
  8008b2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008b6:	89 da                	mov    %ebx,%edx
  8008b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bb:	e8 6c fb ff ff       	call   80042c <printnum>
			break;
  8008c0:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008c3:	e9 cd fc ff ff       	jmp    800595 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008cc:	89 04 24             	mov    %eax,(%esp)
  8008cf:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008d2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008d5:	e9 bb fc ff ff       	jmp    800595 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008de:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008e5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008e8:	eb 01                	jmp    8008eb <vprintfmt+0x379>
  8008ea:	4e                   	dec    %esi
  8008eb:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008ef:	75 f9                	jne    8008ea <vprintfmt+0x378>
  8008f1:	e9 9f fc ff ff       	jmp    800595 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8008f6:	83 c4 4c             	add    $0x4c,%esp
  8008f9:	5b                   	pop    %ebx
  8008fa:	5e                   	pop    %esi
  8008fb:	5f                   	pop    %edi
  8008fc:	5d                   	pop    %ebp
  8008fd:	c3                   	ret    

008008fe <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008fe:	55                   	push   %ebp
  8008ff:	89 e5                	mov    %esp,%ebp
  800901:	83 ec 28             	sub    $0x28,%esp
  800904:	8b 45 08             	mov    0x8(%ebp),%eax
  800907:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80090a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80090d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800911:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800914:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80091b:	85 c0                	test   %eax,%eax
  80091d:	74 30                	je     80094f <vsnprintf+0x51>
  80091f:	85 d2                	test   %edx,%edx
  800921:	7e 33                	jle    800956 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800923:	8b 45 14             	mov    0x14(%ebp),%eax
  800926:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80092a:	8b 45 10             	mov    0x10(%ebp),%eax
  80092d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800931:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800934:	89 44 24 04          	mov    %eax,0x4(%esp)
  800938:	c7 04 24 30 05 80 00 	movl   $0x800530,(%esp)
  80093f:	e8 2e fc ff ff       	call   800572 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800944:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800947:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80094a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80094d:	eb 0c                	jmp    80095b <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80094f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800954:	eb 05                	jmp    80095b <vsnprintf+0x5d>
  800956:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80095b:	c9                   	leave  
  80095c:	c3                   	ret    

0080095d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80095d:	55                   	push   %ebp
  80095e:	89 e5                	mov    %esp,%ebp
  800960:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800963:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800966:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80096a:	8b 45 10             	mov    0x10(%ebp),%eax
  80096d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800971:	8b 45 0c             	mov    0xc(%ebp),%eax
  800974:	89 44 24 04          	mov    %eax,0x4(%esp)
  800978:	8b 45 08             	mov    0x8(%ebp),%eax
  80097b:	89 04 24             	mov    %eax,(%esp)
  80097e:	e8 7b ff ff ff       	call   8008fe <vsnprintf>
	va_end(ap);

	return rc;
}
  800983:	c9                   	leave  
  800984:	c3                   	ret    
  800985:	00 00                	add    %al,(%eax)
	...

00800988 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	57                   	push   %edi
  80098c:	56                   	push   %esi
  80098d:	53                   	push   %ebx
  80098e:	83 ec 1c             	sub    $0x1c,%esp
  800991:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  800994:	85 c0                	test   %eax,%eax
  800996:	74 18                	je     8009b0 <readline+0x28>
		fprintf(1, "%s", prompt);
  800998:	89 44 24 08          	mov    %eax,0x8(%esp)
  80099c:	c7 44 24 04 ed 2b 80 	movl   $0x802bed,0x4(%esp)
  8009a3:	00 
  8009a4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8009ab:	e8 4c 11 00 00       	call   801afc <fprintf>
#endif

	i = 0;
	echoing = iscons(0);
  8009b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8009b7:	e8 7d f8 ff ff       	call   800239 <iscons>
  8009bc:	89 c7                	mov    %eax,%edi
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  8009be:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  8009c3:	e8 3b f8 ff ff       	call   800203 <getchar>
  8009c8:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  8009ca:	85 c0                	test   %eax,%eax
  8009cc:	79 20                	jns    8009ee <readline+0x66>
			if (c != -E_EOF)
  8009ce:	83 f8 f8             	cmp    $0xfffffff8,%eax
  8009d1:	0f 84 82 00 00 00    	je     800a59 <readline+0xd1>
				cprintf("read error: %e\n", c);
  8009d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009db:	c7 04 24 07 2b 80 00 	movl   $0x802b07,(%esp)
  8009e2:	e8 29 fa ff ff       	call   800410 <cprintf>
			return NULL;
  8009e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ec:	eb 70                	jmp    800a5e <readline+0xd6>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  8009ee:	83 f8 08             	cmp    $0x8,%eax
  8009f1:	74 05                	je     8009f8 <readline+0x70>
  8009f3:	83 f8 7f             	cmp    $0x7f,%eax
  8009f6:	75 17                	jne    800a0f <readline+0x87>
  8009f8:	85 f6                	test   %esi,%esi
  8009fa:	7e 13                	jle    800a0f <readline+0x87>
			if (echoing)
  8009fc:	85 ff                	test   %edi,%edi
  8009fe:	74 0c                	je     800a0c <readline+0x84>
				cputchar('\b');
  800a00:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  800a07:	e8 d6 f7 ff ff       	call   8001e2 <cputchar>
			i--;
  800a0c:	4e                   	dec    %esi
  800a0d:	eb b4                	jmp    8009c3 <readline+0x3b>
		} else if (c >= ' ' && i < BUFLEN-1) {
  800a0f:	83 fb 1f             	cmp    $0x1f,%ebx
  800a12:	7e 1d                	jle    800a31 <readline+0xa9>
  800a14:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  800a1a:	7f 15                	jg     800a31 <readline+0xa9>
			if (echoing)
  800a1c:	85 ff                	test   %edi,%edi
  800a1e:	74 08                	je     800a28 <readline+0xa0>
				cputchar(c);
  800a20:	89 1c 24             	mov    %ebx,(%esp)
  800a23:	e8 ba f7 ff ff       	call   8001e2 <cputchar>
			buf[i++] = c;
  800a28:	88 9e 00 40 80 00    	mov    %bl,0x804000(%esi)
  800a2e:	46                   	inc    %esi
  800a2f:	eb 92                	jmp    8009c3 <readline+0x3b>
		} else if (c == '\n' || c == '\r') {
  800a31:	83 fb 0a             	cmp    $0xa,%ebx
  800a34:	74 05                	je     800a3b <readline+0xb3>
  800a36:	83 fb 0d             	cmp    $0xd,%ebx
  800a39:	75 88                	jne    8009c3 <readline+0x3b>
			if (echoing)
  800a3b:	85 ff                	test   %edi,%edi
  800a3d:	74 0c                	je     800a4b <readline+0xc3>
				cputchar('\n');
  800a3f:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800a46:	e8 97 f7 ff ff       	call   8001e2 <cputchar>
			buf[i] = 0;
  800a4b:	c6 86 00 40 80 00 00 	movb   $0x0,0x804000(%esi)
			return buf;
  800a52:	b8 00 40 80 00       	mov    $0x804000,%eax
  800a57:	eb 05                	jmp    800a5e <readline+0xd6>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  800a59:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
  800a5e:	83 c4 1c             	add    $0x1c,%esp
  800a61:	5b                   	pop    %ebx
  800a62:	5e                   	pop    %esi
  800a63:	5f                   	pop    %edi
  800a64:	5d                   	pop    %ebp
  800a65:	c3                   	ret    
	...

00800a68 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a68:	55                   	push   %ebp
  800a69:	89 e5                	mov    %esp,%ebp
  800a6b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a6e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a73:	eb 01                	jmp    800a76 <strlen+0xe>
		n++;
  800a75:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a76:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a7a:	75 f9                	jne    800a75 <strlen+0xd>
		n++;
	return n;
}
  800a7c:	5d                   	pop    %ebp
  800a7d:	c3                   	ret    

00800a7e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a7e:	55                   	push   %ebp
  800a7f:	89 e5                	mov    %esp,%ebp
  800a81:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800a84:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a87:	b8 00 00 00 00       	mov    $0x0,%eax
  800a8c:	eb 01                	jmp    800a8f <strnlen+0x11>
		n++;
  800a8e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a8f:	39 d0                	cmp    %edx,%eax
  800a91:	74 06                	je     800a99 <strnlen+0x1b>
  800a93:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a97:	75 f5                	jne    800a8e <strnlen+0x10>
		n++;
	return n;
}
  800a99:	5d                   	pop    %ebp
  800a9a:	c3                   	ret    

00800a9b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	53                   	push   %ebx
  800a9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800aa5:	ba 00 00 00 00       	mov    $0x0,%edx
  800aaa:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800aad:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800ab0:	42                   	inc    %edx
  800ab1:	84 c9                	test   %cl,%cl
  800ab3:	75 f5                	jne    800aaa <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800ab5:	5b                   	pop    %ebx
  800ab6:	5d                   	pop    %ebp
  800ab7:	c3                   	ret    

00800ab8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800ab8:	55                   	push   %ebp
  800ab9:	89 e5                	mov    %esp,%ebp
  800abb:	53                   	push   %ebx
  800abc:	83 ec 08             	sub    $0x8,%esp
  800abf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ac2:	89 1c 24             	mov    %ebx,(%esp)
  800ac5:	e8 9e ff ff ff       	call   800a68 <strlen>
	strcpy(dst + len, src);
  800aca:	8b 55 0c             	mov    0xc(%ebp),%edx
  800acd:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ad1:	01 d8                	add    %ebx,%eax
  800ad3:	89 04 24             	mov    %eax,(%esp)
  800ad6:	e8 c0 ff ff ff       	call   800a9b <strcpy>
	return dst;
}
  800adb:	89 d8                	mov    %ebx,%eax
  800add:	83 c4 08             	add    $0x8,%esp
  800ae0:	5b                   	pop    %ebx
  800ae1:	5d                   	pop    %ebp
  800ae2:	c3                   	ret    

00800ae3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ae3:	55                   	push   %ebp
  800ae4:	89 e5                	mov    %esp,%ebp
  800ae6:	56                   	push   %esi
  800ae7:	53                   	push   %ebx
  800ae8:	8b 45 08             	mov    0x8(%ebp),%eax
  800aeb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aee:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800af1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800af6:	eb 0c                	jmp    800b04 <strncpy+0x21>
		*dst++ = *src;
  800af8:	8a 1a                	mov    (%edx),%bl
  800afa:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800afd:	80 3a 01             	cmpb   $0x1,(%edx)
  800b00:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b03:	41                   	inc    %ecx
  800b04:	39 f1                	cmp    %esi,%ecx
  800b06:	75 f0                	jne    800af8 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b08:	5b                   	pop    %ebx
  800b09:	5e                   	pop    %esi
  800b0a:	5d                   	pop    %ebp
  800b0b:	c3                   	ret    

00800b0c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	56                   	push   %esi
  800b10:	53                   	push   %ebx
  800b11:	8b 75 08             	mov    0x8(%ebp),%esi
  800b14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b17:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b1a:	85 d2                	test   %edx,%edx
  800b1c:	75 0a                	jne    800b28 <strlcpy+0x1c>
  800b1e:	89 f0                	mov    %esi,%eax
  800b20:	eb 1a                	jmp    800b3c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b22:	88 18                	mov    %bl,(%eax)
  800b24:	40                   	inc    %eax
  800b25:	41                   	inc    %ecx
  800b26:	eb 02                	jmp    800b2a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b28:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800b2a:	4a                   	dec    %edx
  800b2b:	74 0a                	je     800b37 <strlcpy+0x2b>
  800b2d:	8a 19                	mov    (%ecx),%bl
  800b2f:	84 db                	test   %bl,%bl
  800b31:	75 ef                	jne    800b22 <strlcpy+0x16>
  800b33:	89 c2                	mov    %eax,%edx
  800b35:	eb 02                	jmp    800b39 <strlcpy+0x2d>
  800b37:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800b39:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800b3c:	29 f0                	sub    %esi,%eax
}
  800b3e:	5b                   	pop    %ebx
  800b3f:	5e                   	pop    %esi
  800b40:	5d                   	pop    %ebp
  800b41:	c3                   	ret    

00800b42 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b42:	55                   	push   %ebp
  800b43:	89 e5                	mov    %esp,%ebp
  800b45:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b48:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b4b:	eb 02                	jmp    800b4f <strcmp+0xd>
		p++, q++;
  800b4d:	41                   	inc    %ecx
  800b4e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b4f:	8a 01                	mov    (%ecx),%al
  800b51:	84 c0                	test   %al,%al
  800b53:	74 04                	je     800b59 <strcmp+0x17>
  800b55:	3a 02                	cmp    (%edx),%al
  800b57:	74 f4                	je     800b4d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b59:	0f b6 c0             	movzbl %al,%eax
  800b5c:	0f b6 12             	movzbl (%edx),%edx
  800b5f:	29 d0                	sub    %edx,%eax
}
  800b61:	5d                   	pop    %ebp
  800b62:	c3                   	ret    

00800b63 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b63:	55                   	push   %ebp
  800b64:	89 e5                	mov    %esp,%ebp
  800b66:	53                   	push   %ebx
  800b67:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b6d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800b70:	eb 03                	jmp    800b75 <strncmp+0x12>
		n--, p++, q++;
  800b72:	4a                   	dec    %edx
  800b73:	40                   	inc    %eax
  800b74:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b75:	85 d2                	test   %edx,%edx
  800b77:	74 14                	je     800b8d <strncmp+0x2a>
  800b79:	8a 18                	mov    (%eax),%bl
  800b7b:	84 db                	test   %bl,%bl
  800b7d:	74 04                	je     800b83 <strncmp+0x20>
  800b7f:	3a 19                	cmp    (%ecx),%bl
  800b81:	74 ef                	je     800b72 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b83:	0f b6 00             	movzbl (%eax),%eax
  800b86:	0f b6 11             	movzbl (%ecx),%edx
  800b89:	29 d0                	sub    %edx,%eax
  800b8b:	eb 05                	jmp    800b92 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b8d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b92:	5b                   	pop    %ebx
  800b93:	5d                   	pop    %ebp
  800b94:	c3                   	ret    

00800b95 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b95:	55                   	push   %ebp
  800b96:	89 e5                	mov    %esp,%ebp
  800b98:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b9e:	eb 05                	jmp    800ba5 <strchr+0x10>
		if (*s == c)
  800ba0:	38 ca                	cmp    %cl,%dl
  800ba2:	74 0c                	je     800bb0 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ba4:	40                   	inc    %eax
  800ba5:	8a 10                	mov    (%eax),%dl
  800ba7:	84 d2                	test   %dl,%dl
  800ba9:	75 f5                	jne    800ba0 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800bab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bb0:	5d                   	pop    %ebp
  800bb1:	c3                   	ret    

00800bb2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bb2:	55                   	push   %ebp
  800bb3:	89 e5                	mov    %esp,%ebp
  800bb5:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb8:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800bbb:	eb 05                	jmp    800bc2 <strfind+0x10>
		if (*s == c)
  800bbd:	38 ca                	cmp    %cl,%dl
  800bbf:	74 07                	je     800bc8 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800bc1:	40                   	inc    %eax
  800bc2:	8a 10                	mov    (%eax),%dl
  800bc4:	84 d2                	test   %dl,%dl
  800bc6:	75 f5                	jne    800bbd <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800bc8:	5d                   	pop    %ebp
  800bc9:	c3                   	ret    

00800bca <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bca:	55                   	push   %ebp
  800bcb:	89 e5                	mov    %esp,%ebp
  800bcd:	57                   	push   %edi
  800bce:	56                   	push   %esi
  800bcf:	53                   	push   %ebx
  800bd0:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bd3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bd6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bd9:	85 c9                	test   %ecx,%ecx
  800bdb:	74 30                	je     800c0d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bdd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800be3:	75 25                	jne    800c0a <memset+0x40>
  800be5:	f6 c1 03             	test   $0x3,%cl
  800be8:	75 20                	jne    800c0a <memset+0x40>
		c &= 0xFF;
  800bea:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bed:	89 d3                	mov    %edx,%ebx
  800bef:	c1 e3 08             	shl    $0x8,%ebx
  800bf2:	89 d6                	mov    %edx,%esi
  800bf4:	c1 e6 18             	shl    $0x18,%esi
  800bf7:	89 d0                	mov    %edx,%eax
  800bf9:	c1 e0 10             	shl    $0x10,%eax
  800bfc:	09 f0                	or     %esi,%eax
  800bfe:	09 d0                	or     %edx,%eax
  800c00:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c02:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800c05:	fc                   	cld    
  800c06:	f3 ab                	rep stos %eax,%es:(%edi)
  800c08:	eb 03                	jmp    800c0d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c0a:	fc                   	cld    
  800c0b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c0d:	89 f8                	mov    %edi,%eax
  800c0f:	5b                   	pop    %ebx
  800c10:	5e                   	pop    %esi
  800c11:	5f                   	pop    %edi
  800c12:	5d                   	pop    %ebp
  800c13:	c3                   	ret    

00800c14 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	57                   	push   %edi
  800c18:	56                   	push   %esi
  800c19:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c1f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c22:	39 c6                	cmp    %eax,%esi
  800c24:	73 34                	jae    800c5a <memmove+0x46>
  800c26:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c29:	39 d0                	cmp    %edx,%eax
  800c2b:	73 2d                	jae    800c5a <memmove+0x46>
		s += n;
		d += n;
  800c2d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c30:	f6 c2 03             	test   $0x3,%dl
  800c33:	75 1b                	jne    800c50 <memmove+0x3c>
  800c35:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c3b:	75 13                	jne    800c50 <memmove+0x3c>
  800c3d:	f6 c1 03             	test   $0x3,%cl
  800c40:	75 0e                	jne    800c50 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c42:	83 ef 04             	sub    $0x4,%edi
  800c45:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c48:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c4b:	fd                   	std    
  800c4c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c4e:	eb 07                	jmp    800c57 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c50:	4f                   	dec    %edi
  800c51:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c54:	fd                   	std    
  800c55:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c57:	fc                   	cld    
  800c58:	eb 20                	jmp    800c7a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c5a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c60:	75 13                	jne    800c75 <memmove+0x61>
  800c62:	a8 03                	test   $0x3,%al
  800c64:	75 0f                	jne    800c75 <memmove+0x61>
  800c66:	f6 c1 03             	test   $0x3,%cl
  800c69:	75 0a                	jne    800c75 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c6b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c6e:	89 c7                	mov    %eax,%edi
  800c70:	fc                   	cld    
  800c71:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c73:	eb 05                	jmp    800c7a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c75:	89 c7                	mov    %eax,%edi
  800c77:	fc                   	cld    
  800c78:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c7a:	5e                   	pop    %esi
  800c7b:	5f                   	pop    %edi
  800c7c:	5d                   	pop    %ebp
  800c7d:	c3                   	ret    

00800c7e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c7e:	55                   	push   %ebp
  800c7f:	89 e5                	mov    %esp,%ebp
  800c81:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c84:	8b 45 10             	mov    0x10(%ebp),%eax
  800c87:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c92:	8b 45 08             	mov    0x8(%ebp),%eax
  800c95:	89 04 24             	mov    %eax,(%esp)
  800c98:	e8 77 ff ff ff       	call   800c14 <memmove>
}
  800c9d:	c9                   	leave  
  800c9e:	c3                   	ret    

00800c9f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c9f:	55                   	push   %ebp
  800ca0:	89 e5                	mov    %esp,%ebp
  800ca2:	57                   	push   %edi
  800ca3:	56                   	push   %esi
  800ca4:	53                   	push   %ebx
  800ca5:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ca8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cae:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb3:	eb 16                	jmp    800ccb <memcmp+0x2c>
		if (*s1 != *s2)
  800cb5:	8a 04 17             	mov    (%edi,%edx,1),%al
  800cb8:	42                   	inc    %edx
  800cb9:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800cbd:	38 c8                	cmp    %cl,%al
  800cbf:	74 0a                	je     800ccb <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800cc1:	0f b6 c0             	movzbl %al,%eax
  800cc4:	0f b6 c9             	movzbl %cl,%ecx
  800cc7:	29 c8                	sub    %ecx,%eax
  800cc9:	eb 09                	jmp    800cd4 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ccb:	39 da                	cmp    %ebx,%edx
  800ccd:	75 e6                	jne    800cb5 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ccf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cd4:	5b                   	pop    %ebx
  800cd5:	5e                   	pop    %esi
  800cd6:	5f                   	pop    %edi
  800cd7:	5d                   	pop    %ebp
  800cd8:	c3                   	ret    

00800cd9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cd9:	55                   	push   %ebp
  800cda:	89 e5                	mov    %esp,%ebp
  800cdc:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ce2:	89 c2                	mov    %eax,%edx
  800ce4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ce7:	eb 05                	jmp    800cee <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ce9:	38 08                	cmp    %cl,(%eax)
  800ceb:	74 05                	je     800cf2 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ced:	40                   	inc    %eax
  800cee:	39 d0                	cmp    %edx,%eax
  800cf0:	72 f7                	jb     800ce9 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800cf2:	5d                   	pop    %ebp
  800cf3:	c3                   	ret    

00800cf4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	57                   	push   %edi
  800cf8:	56                   	push   %esi
  800cf9:	53                   	push   %ebx
  800cfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d00:	eb 01                	jmp    800d03 <strtol+0xf>
		s++;
  800d02:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d03:	8a 02                	mov    (%edx),%al
  800d05:	3c 20                	cmp    $0x20,%al
  800d07:	74 f9                	je     800d02 <strtol+0xe>
  800d09:	3c 09                	cmp    $0x9,%al
  800d0b:	74 f5                	je     800d02 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d0d:	3c 2b                	cmp    $0x2b,%al
  800d0f:	75 08                	jne    800d19 <strtol+0x25>
		s++;
  800d11:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d12:	bf 00 00 00 00       	mov    $0x0,%edi
  800d17:	eb 13                	jmp    800d2c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d19:	3c 2d                	cmp    $0x2d,%al
  800d1b:	75 0a                	jne    800d27 <strtol+0x33>
		s++, neg = 1;
  800d1d:	8d 52 01             	lea    0x1(%edx),%edx
  800d20:	bf 01 00 00 00       	mov    $0x1,%edi
  800d25:	eb 05                	jmp    800d2c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d27:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d2c:	85 db                	test   %ebx,%ebx
  800d2e:	74 05                	je     800d35 <strtol+0x41>
  800d30:	83 fb 10             	cmp    $0x10,%ebx
  800d33:	75 28                	jne    800d5d <strtol+0x69>
  800d35:	8a 02                	mov    (%edx),%al
  800d37:	3c 30                	cmp    $0x30,%al
  800d39:	75 10                	jne    800d4b <strtol+0x57>
  800d3b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d3f:	75 0a                	jne    800d4b <strtol+0x57>
		s += 2, base = 16;
  800d41:	83 c2 02             	add    $0x2,%edx
  800d44:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d49:	eb 12                	jmp    800d5d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800d4b:	85 db                	test   %ebx,%ebx
  800d4d:	75 0e                	jne    800d5d <strtol+0x69>
  800d4f:	3c 30                	cmp    $0x30,%al
  800d51:	75 05                	jne    800d58 <strtol+0x64>
		s++, base = 8;
  800d53:	42                   	inc    %edx
  800d54:	b3 08                	mov    $0x8,%bl
  800d56:	eb 05                	jmp    800d5d <strtol+0x69>
	else if (base == 0)
		base = 10;
  800d58:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800d5d:	b8 00 00 00 00       	mov    $0x0,%eax
  800d62:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d64:	8a 0a                	mov    (%edx),%cl
  800d66:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d69:	80 fb 09             	cmp    $0x9,%bl
  800d6c:	77 08                	ja     800d76 <strtol+0x82>
			dig = *s - '0';
  800d6e:	0f be c9             	movsbl %cl,%ecx
  800d71:	83 e9 30             	sub    $0x30,%ecx
  800d74:	eb 1e                	jmp    800d94 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800d76:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d79:	80 fb 19             	cmp    $0x19,%bl
  800d7c:	77 08                	ja     800d86 <strtol+0x92>
			dig = *s - 'a' + 10;
  800d7e:	0f be c9             	movsbl %cl,%ecx
  800d81:	83 e9 57             	sub    $0x57,%ecx
  800d84:	eb 0e                	jmp    800d94 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800d86:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d89:	80 fb 19             	cmp    $0x19,%bl
  800d8c:	77 12                	ja     800da0 <strtol+0xac>
			dig = *s - 'A' + 10;
  800d8e:	0f be c9             	movsbl %cl,%ecx
  800d91:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d94:	39 f1                	cmp    %esi,%ecx
  800d96:	7d 0c                	jge    800da4 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800d98:	42                   	inc    %edx
  800d99:	0f af c6             	imul   %esi,%eax
  800d9c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d9e:	eb c4                	jmp    800d64 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800da0:	89 c1                	mov    %eax,%ecx
  800da2:	eb 02                	jmp    800da6 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800da4:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800da6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800daa:	74 05                	je     800db1 <strtol+0xbd>
		*endptr = (char *) s;
  800dac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800daf:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800db1:	85 ff                	test   %edi,%edi
  800db3:	74 04                	je     800db9 <strtol+0xc5>
  800db5:	89 c8                	mov    %ecx,%eax
  800db7:	f7 d8                	neg    %eax
}
  800db9:	5b                   	pop    %ebx
  800dba:	5e                   	pop    %esi
  800dbb:	5f                   	pop    %edi
  800dbc:	5d                   	pop    %ebp
  800dbd:	c3                   	ret    
	...

00800dc0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	57                   	push   %edi
  800dc4:	56                   	push   %esi
  800dc5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc6:	b8 00 00 00 00       	mov    $0x0,%eax
  800dcb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dce:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd1:	89 c3                	mov    %eax,%ebx
  800dd3:	89 c7                	mov    %eax,%edi
  800dd5:	89 c6                	mov    %eax,%esi
  800dd7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800dd9:	5b                   	pop    %ebx
  800dda:	5e                   	pop    %esi
  800ddb:	5f                   	pop    %edi
  800ddc:	5d                   	pop    %ebp
  800ddd:	c3                   	ret    

00800dde <sys_cgetc>:

int
sys_cgetc(void)
{
  800dde:	55                   	push   %ebp
  800ddf:	89 e5                	mov    %esp,%ebp
  800de1:	57                   	push   %edi
  800de2:	56                   	push   %esi
  800de3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de4:	ba 00 00 00 00       	mov    $0x0,%edx
  800de9:	b8 01 00 00 00       	mov    $0x1,%eax
  800dee:	89 d1                	mov    %edx,%ecx
  800df0:	89 d3                	mov    %edx,%ebx
  800df2:	89 d7                	mov    %edx,%edi
  800df4:	89 d6                	mov    %edx,%esi
  800df6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800df8:	5b                   	pop    %ebx
  800df9:	5e                   	pop    %esi
  800dfa:	5f                   	pop    %edi
  800dfb:	5d                   	pop    %ebp
  800dfc:	c3                   	ret    

00800dfd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800dfd:	55                   	push   %ebp
  800dfe:	89 e5                	mov    %esp,%ebp
  800e00:	57                   	push   %edi
  800e01:	56                   	push   %esi
  800e02:	53                   	push   %ebx
  800e03:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e06:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e0b:	b8 03 00 00 00       	mov    $0x3,%eax
  800e10:	8b 55 08             	mov    0x8(%ebp),%edx
  800e13:	89 cb                	mov    %ecx,%ebx
  800e15:	89 cf                	mov    %ecx,%edi
  800e17:	89 ce                	mov    %ecx,%esi
  800e19:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e1b:	85 c0                	test   %eax,%eax
  800e1d:	7e 28                	jle    800e47 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e1f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e23:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800e2a:	00 
  800e2b:	c7 44 24 08 17 2b 80 	movl   $0x802b17,0x8(%esp)
  800e32:	00 
  800e33:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e3a:	00 
  800e3b:	c7 04 24 34 2b 80 00 	movl   $0x802b34,(%esp)
  800e42:	e8 d1 f4 ff ff       	call   800318 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e47:	83 c4 2c             	add    $0x2c,%esp
  800e4a:	5b                   	pop    %ebx
  800e4b:	5e                   	pop    %esi
  800e4c:	5f                   	pop    %edi
  800e4d:	5d                   	pop    %ebp
  800e4e:	c3                   	ret    

00800e4f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e4f:	55                   	push   %ebp
  800e50:	89 e5                	mov    %esp,%ebp
  800e52:	57                   	push   %edi
  800e53:	56                   	push   %esi
  800e54:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e55:	ba 00 00 00 00       	mov    $0x0,%edx
  800e5a:	b8 02 00 00 00       	mov    $0x2,%eax
  800e5f:	89 d1                	mov    %edx,%ecx
  800e61:	89 d3                	mov    %edx,%ebx
  800e63:	89 d7                	mov    %edx,%edi
  800e65:	89 d6                	mov    %edx,%esi
  800e67:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e69:	5b                   	pop    %ebx
  800e6a:	5e                   	pop    %esi
  800e6b:	5f                   	pop    %edi
  800e6c:	5d                   	pop    %ebp
  800e6d:	c3                   	ret    

00800e6e <sys_yield>:

void
sys_yield(void)
{
  800e6e:	55                   	push   %ebp
  800e6f:	89 e5                	mov    %esp,%ebp
  800e71:	57                   	push   %edi
  800e72:	56                   	push   %esi
  800e73:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e74:	ba 00 00 00 00       	mov    $0x0,%edx
  800e79:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e7e:	89 d1                	mov    %edx,%ecx
  800e80:	89 d3                	mov    %edx,%ebx
  800e82:	89 d7                	mov    %edx,%edi
  800e84:	89 d6                	mov    %edx,%esi
  800e86:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e88:	5b                   	pop    %ebx
  800e89:	5e                   	pop    %esi
  800e8a:	5f                   	pop    %edi
  800e8b:	5d                   	pop    %ebp
  800e8c:	c3                   	ret    

00800e8d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e8d:	55                   	push   %ebp
  800e8e:	89 e5                	mov    %esp,%ebp
  800e90:	57                   	push   %edi
  800e91:	56                   	push   %esi
  800e92:	53                   	push   %ebx
  800e93:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e96:	be 00 00 00 00       	mov    $0x0,%esi
  800e9b:	b8 04 00 00 00       	mov    $0x4,%eax
  800ea0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ea3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea9:	89 f7                	mov    %esi,%edi
  800eab:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ead:	85 c0                	test   %eax,%eax
  800eaf:	7e 28                	jle    800ed9 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eb5:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800ebc:	00 
  800ebd:	c7 44 24 08 17 2b 80 	movl   $0x802b17,0x8(%esp)
  800ec4:	00 
  800ec5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ecc:	00 
  800ecd:	c7 04 24 34 2b 80 00 	movl   $0x802b34,(%esp)
  800ed4:	e8 3f f4 ff ff       	call   800318 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ed9:	83 c4 2c             	add    $0x2c,%esp
  800edc:	5b                   	pop    %ebx
  800edd:	5e                   	pop    %esi
  800ede:	5f                   	pop    %edi
  800edf:	5d                   	pop    %ebp
  800ee0:	c3                   	ret    

00800ee1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800eea:	b8 05 00 00 00       	mov    $0x5,%eax
  800eef:	8b 75 18             	mov    0x18(%ebp),%esi
  800ef2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ef5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ef8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800efb:	8b 55 08             	mov    0x8(%ebp),%edx
  800efe:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f00:	85 c0                	test   %eax,%eax
  800f02:	7e 28                	jle    800f2c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f04:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f08:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f0f:	00 
  800f10:	c7 44 24 08 17 2b 80 	movl   $0x802b17,0x8(%esp)
  800f17:	00 
  800f18:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f1f:	00 
  800f20:	c7 04 24 34 2b 80 00 	movl   $0x802b34,(%esp)
  800f27:	e8 ec f3 ff ff       	call   800318 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f2c:	83 c4 2c             	add    $0x2c,%esp
  800f2f:	5b                   	pop    %ebx
  800f30:	5e                   	pop    %esi
  800f31:	5f                   	pop    %edi
  800f32:	5d                   	pop    %ebp
  800f33:	c3                   	ret    

00800f34 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f34:	55                   	push   %ebp
  800f35:	89 e5                	mov    %esp,%ebp
  800f37:	57                   	push   %edi
  800f38:	56                   	push   %esi
  800f39:	53                   	push   %ebx
  800f3a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f3d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f42:	b8 06 00 00 00       	mov    $0x6,%eax
  800f47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800f4d:	89 df                	mov    %ebx,%edi
  800f4f:	89 de                	mov    %ebx,%esi
  800f51:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f53:	85 c0                	test   %eax,%eax
  800f55:	7e 28                	jle    800f7f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f57:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f5b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f62:	00 
  800f63:	c7 44 24 08 17 2b 80 	movl   $0x802b17,0x8(%esp)
  800f6a:	00 
  800f6b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f72:	00 
  800f73:	c7 04 24 34 2b 80 00 	movl   $0x802b34,(%esp)
  800f7a:	e8 99 f3 ff ff       	call   800318 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f7f:	83 c4 2c             	add    $0x2c,%esp
  800f82:	5b                   	pop    %ebx
  800f83:	5e                   	pop    %esi
  800f84:	5f                   	pop    %edi
  800f85:	5d                   	pop    %ebp
  800f86:	c3                   	ret    

00800f87 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f87:	55                   	push   %ebp
  800f88:	89 e5                	mov    %esp,%ebp
  800f8a:	57                   	push   %edi
  800f8b:	56                   	push   %esi
  800f8c:	53                   	push   %ebx
  800f8d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f90:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f95:	b8 08 00 00 00       	mov    $0x8,%eax
  800f9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa0:	89 df                	mov    %ebx,%edi
  800fa2:	89 de                	mov    %ebx,%esi
  800fa4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fa6:	85 c0                	test   %eax,%eax
  800fa8:	7e 28                	jle    800fd2 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800faa:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fae:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800fb5:	00 
  800fb6:	c7 44 24 08 17 2b 80 	movl   $0x802b17,0x8(%esp)
  800fbd:	00 
  800fbe:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fc5:	00 
  800fc6:	c7 04 24 34 2b 80 00 	movl   $0x802b34,(%esp)
  800fcd:	e8 46 f3 ff ff       	call   800318 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800fd2:	83 c4 2c             	add    $0x2c,%esp
  800fd5:	5b                   	pop    %ebx
  800fd6:	5e                   	pop    %esi
  800fd7:	5f                   	pop    %edi
  800fd8:	5d                   	pop    %ebp
  800fd9:	c3                   	ret    

00800fda <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800fda:	55                   	push   %ebp
  800fdb:	89 e5                	mov    %esp,%ebp
  800fdd:	57                   	push   %edi
  800fde:	56                   	push   %esi
  800fdf:	53                   	push   %ebx
  800fe0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fe3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fe8:	b8 09 00 00 00       	mov    $0x9,%eax
  800fed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ff0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff3:	89 df                	mov    %ebx,%edi
  800ff5:	89 de                	mov    %ebx,%esi
  800ff7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ff9:	85 c0                	test   %eax,%eax
  800ffb:	7e 28                	jle    801025 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ffd:	89 44 24 10          	mov    %eax,0x10(%esp)
  801001:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801008:	00 
  801009:	c7 44 24 08 17 2b 80 	movl   $0x802b17,0x8(%esp)
  801010:	00 
  801011:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801018:	00 
  801019:	c7 04 24 34 2b 80 00 	movl   $0x802b34,(%esp)
  801020:	e8 f3 f2 ff ff       	call   800318 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801025:	83 c4 2c             	add    $0x2c,%esp
  801028:	5b                   	pop    %ebx
  801029:	5e                   	pop    %esi
  80102a:	5f                   	pop    %edi
  80102b:	5d                   	pop    %ebp
  80102c:	c3                   	ret    

0080102d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80102d:	55                   	push   %ebp
  80102e:	89 e5                	mov    %esp,%ebp
  801030:	57                   	push   %edi
  801031:	56                   	push   %esi
  801032:	53                   	push   %ebx
  801033:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801036:	bb 00 00 00 00       	mov    $0x0,%ebx
  80103b:	b8 0a 00 00 00       	mov    $0xa,%eax
  801040:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801043:	8b 55 08             	mov    0x8(%ebp),%edx
  801046:	89 df                	mov    %ebx,%edi
  801048:	89 de                	mov    %ebx,%esi
  80104a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80104c:	85 c0                	test   %eax,%eax
  80104e:	7e 28                	jle    801078 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801050:	89 44 24 10          	mov    %eax,0x10(%esp)
  801054:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80105b:	00 
  80105c:	c7 44 24 08 17 2b 80 	movl   $0x802b17,0x8(%esp)
  801063:	00 
  801064:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80106b:	00 
  80106c:	c7 04 24 34 2b 80 00 	movl   $0x802b34,(%esp)
  801073:	e8 a0 f2 ff ff       	call   800318 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801078:	83 c4 2c             	add    $0x2c,%esp
  80107b:	5b                   	pop    %ebx
  80107c:	5e                   	pop    %esi
  80107d:	5f                   	pop    %edi
  80107e:	5d                   	pop    %ebp
  80107f:	c3                   	ret    

00801080 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801080:	55                   	push   %ebp
  801081:	89 e5                	mov    %esp,%ebp
  801083:	57                   	push   %edi
  801084:	56                   	push   %esi
  801085:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801086:	be 00 00 00 00       	mov    $0x0,%esi
  80108b:	b8 0c 00 00 00       	mov    $0xc,%eax
  801090:	8b 7d 14             	mov    0x14(%ebp),%edi
  801093:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801096:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801099:	8b 55 08             	mov    0x8(%ebp),%edx
  80109c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80109e:	5b                   	pop    %ebx
  80109f:	5e                   	pop    %esi
  8010a0:	5f                   	pop    %edi
  8010a1:	5d                   	pop    %ebp
  8010a2:	c3                   	ret    

008010a3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010a3:	55                   	push   %ebp
  8010a4:	89 e5                	mov    %esp,%ebp
  8010a6:	57                   	push   %edi
  8010a7:	56                   	push   %esi
  8010a8:	53                   	push   %ebx
  8010a9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ac:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010b1:	b8 0d 00 00 00       	mov    $0xd,%eax
  8010b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8010b9:	89 cb                	mov    %ecx,%ebx
  8010bb:	89 cf                	mov    %ecx,%edi
  8010bd:	89 ce                	mov    %ecx,%esi
  8010bf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010c1:	85 c0                	test   %eax,%eax
  8010c3:	7e 28                	jle    8010ed <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010c5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010c9:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8010d0:	00 
  8010d1:	c7 44 24 08 17 2b 80 	movl   $0x802b17,0x8(%esp)
  8010d8:	00 
  8010d9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010e0:	00 
  8010e1:	c7 04 24 34 2b 80 00 	movl   $0x802b34,(%esp)
  8010e8:	e8 2b f2 ff ff       	call   800318 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8010ed:	83 c4 2c             	add    $0x2c,%esp
  8010f0:	5b                   	pop    %ebx
  8010f1:	5e                   	pop    %esi
  8010f2:	5f                   	pop    %edi
  8010f3:	5d                   	pop    %ebp
  8010f4:	c3                   	ret    

008010f5 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8010f5:	55                   	push   %ebp
  8010f6:	89 e5                	mov    %esp,%ebp
  8010f8:	57                   	push   %edi
  8010f9:	56                   	push   %esi
  8010fa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010fb:	ba 00 00 00 00       	mov    $0x0,%edx
  801100:	b8 0e 00 00 00       	mov    $0xe,%eax
  801105:	89 d1                	mov    %edx,%ecx
  801107:	89 d3                	mov    %edx,%ebx
  801109:	89 d7                	mov    %edx,%edi
  80110b:	89 d6                	mov    %edx,%esi
  80110d:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80110f:	5b                   	pop    %ebx
  801110:	5e                   	pop    %esi
  801111:	5f                   	pop    %edi
  801112:	5d                   	pop    %ebp
  801113:	c3                   	ret    

00801114 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char* pck, size_t length){
  801114:	55                   	push   %ebp
  801115:	89 e5                	mov    %esp,%ebp
  801117:	57                   	push   %edi
  801118:	56                   	push   %esi
  801119:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80111a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80111f:	b8 10 00 00 00       	mov    $0x10,%eax
  801124:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801127:	8b 55 08             	mov    0x8(%ebp),%edx
  80112a:	89 df                	mov    %ebx,%edi
  80112c:	89 de                	mov    %ebx,%esi
  80112e:	cd 30                	int    $0x30
}

int 
sys_e1000_transmit(char* pck, size_t length){
	return syscall(SYS_e1000_transmit, 0, (uint32_t)pck, length, 0, 0, 0);
}
  801130:	5b                   	pop    %ebx
  801131:	5e                   	pop    %esi
  801132:	5f                   	pop    %edi
  801133:	5d                   	pop    %ebp
  801134:	c3                   	ret    

00801135 <sys_e1000_receive>:

int 
sys_e1000_receive(char* pck, size_t* length){
  801135:	55                   	push   %ebp
  801136:	89 e5                	mov    %esp,%ebp
  801138:	57                   	push   %edi
  801139:	56                   	push   %esi
  80113a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80113b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801140:	b8 0f 00 00 00       	mov    $0xf,%eax
  801145:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801148:	8b 55 08             	mov    0x8(%ebp),%edx
  80114b:	89 df                	mov    %ebx,%edi
  80114d:	89 de                	mov    %ebx,%esi
  80114f:	cd 30                	int    $0x30
}

int 
sys_e1000_receive(char* pck, size_t* length){
	return syscall(SYS_e1000_receive, 0, (uint32_t)pck, (uint32_t)length, 0, 0, 0);
}
  801151:	5b                   	pop    %ebx
  801152:	5e                   	pop    %esi
  801153:	5f                   	pop    %edi
  801154:	5d                   	pop    %ebp
  801155:	c3                   	ret    

00801156 <sys_e1000_get_mac>:

int 
sys_e1000_get_mac(uint8_t* mac_addr){
  801156:	55                   	push   %ebp
  801157:	89 e5                	mov    %esp,%ebp
  801159:	57                   	push   %edi
  80115a:	56                   	push   %esi
  80115b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80115c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801161:	b8 11 00 00 00       	mov    $0x11,%eax
  801166:	8b 55 08             	mov    0x8(%ebp),%edx
  801169:	89 cb                	mov    %ecx,%ebx
  80116b:	89 cf                	mov    %ecx,%edi
  80116d:	89 ce                	mov    %ecx,%esi
  80116f:	cd 30                	int    $0x30
}

int 
sys_e1000_get_mac(uint8_t* mac_addr){
	return syscall(SYS_e1000_get_mac, 0, (uint32_t)mac_addr, 0, 0, 0, 0);
}
  801171:	5b                   	pop    %ebx
  801172:	5e                   	pop    %esi
  801173:	5f                   	pop    %edi
  801174:	5d                   	pop    %ebp
  801175:	c3                   	ret    
	...

00801178 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801178:	55                   	push   %ebp
  801179:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80117b:	8b 45 08             	mov    0x8(%ebp),%eax
  80117e:	05 00 00 00 30       	add    $0x30000000,%eax
  801183:	c1 e8 0c             	shr    $0xc,%eax
}
  801186:	5d                   	pop    %ebp
  801187:	c3                   	ret    

00801188 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801188:	55                   	push   %ebp
  801189:	89 e5                	mov    %esp,%ebp
  80118b:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  80118e:	8b 45 08             	mov    0x8(%ebp),%eax
  801191:	89 04 24             	mov    %eax,(%esp)
  801194:	e8 df ff ff ff       	call   801178 <fd2num>
  801199:	05 20 00 0d 00       	add    $0xd0020,%eax
  80119e:	c1 e0 0c             	shl    $0xc,%eax
}
  8011a1:	c9                   	leave  
  8011a2:	c3                   	ret    

008011a3 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011a3:	55                   	push   %ebp
  8011a4:	89 e5                	mov    %esp,%ebp
  8011a6:	53                   	push   %ebx
  8011a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8011aa:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8011af:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011b1:	89 c2                	mov    %eax,%edx
  8011b3:	c1 ea 16             	shr    $0x16,%edx
  8011b6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011bd:	f6 c2 01             	test   $0x1,%dl
  8011c0:	74 11                	je     8011d3 <fd_alloc+0x30>
  8011c2:	89 c2                	mov    %eax,%edx
  8011c4:	c1 ea 0c             	shr    $0xc,%edx
  8011c7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011ce:	f6 c2 01             	test   $0x1,%dl
  8011d1:	75 09                	jne    8011dc <fd_alloc+0x39>
			*fd_store = fd;
  8011d3:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8011d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8011da:	eb 17                	jmp    8011f3 <fd_alloc+0x50>
  8011dc:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011e1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011e6:	75 c7                	jne    8011af <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011e8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8011ee:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011f3:	5b                   	pop    %ebx
  8011f4:	5d                   	pop    %ebp
  8011f5:	c3                   	ret    

008011f6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011f6:	55                   	push   %ebp
  8011f7:	89 e5                	mov    %esp,%ebp
  8011f9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011fc:	83 f8 1f             	cmp    $0x1f,%eax
  8011ff:	77 36                	ja     801237 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801201:	05 00 00 0d 00       	add    $0xd0000,%eax
  801206:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801209:	89 c2                	mov    %eax,%edx
  80120b:	c1 ea 16             	shr    $0x16,%edx
  80120e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801215:	f6 c2 01             	test   $0x1,%dl
  801218:	74 24                	je     80123e <fd_lookup+0x48>
  80121a:	89 c2                	mov    %eax,%edx
  80121c:	c1 ea 0c             	shr    $0xc,%edx
  80121f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801226:	f6 c2 01             	test   $0x1,%dl
  801229:	74 1a                	je     801245 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80122b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80122e:	89 02                	mov    %eax,(%edx)
	return 0;
  801230:	b8 00 00 00 00       	mov    $0x0,%eax
  801235:	eb 13                	jmp    80124a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801237:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80123c:	eb 0c                	jmp    80124a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80123e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801243:	eb 05                	jmp    80124a <fd_lookup+0x54>
  801245:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80124a:	5d                   	pop    %ebp
  80124b:	c3                   	ret    

0080124c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80124c:	55                   	push   %ebp
  80124d:	89 e5                	mov    %esp,%ebp
  80124f:	53                   	push   %ebx
  801250:	83 ec 14             	sub    $0x14,%esp
  801253:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801256:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801259:	ba 00 00 00 00       	mov    $0x0,%edx
  80125e:	eb 0e                	jmp    80126e <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801260:	39 08                	cmp    %ecx,(%eax)
  801262:	75 09                	jne    80126d <dev_lookup+0x21>
			*dev = devtab[i];
  801264:	89 03                	mov    %eax,(%ebx)
			return 0;
  801266:	b8 00 00 00 00       	mov    $0x0,%eax
  80126b:	eb 33                	jmp    8012a0 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80126d:	42                   	inc    %edx
  80126e:	8b 04 95 c0 2b 80 00 	mov    0x802bc0(,%edx,4),%eax
  801275:	85 c0                	test   %eax,%eax
  801277:	75 e7                	jne    801260 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801279:	a1 08 44 80 00       	mov    0x804408,%eax
  80127e:	8b 40 48             	mov    0x48(%eax),%eax
  801281:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801285:	89 44 24 04          	mov    %eax,0x4(%esp)
  801289:	c7 04 24 44 2b 80 00 	movl   $0x802b44,(%esp)
  801290:	e8 7b f1 ff ff       	call   800410 <cprintf>
	*dev = 0;
  801295:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80129b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012a0:	83 c4 14             	add    $0x14,%esp
  8012a3:	5b                   	pop    %ebx
  8012a4:	5d                   	pop    %ebp
  8012a5:	c3                   	ret    

008012a6 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012a6:	55                   	push   %ebp
  8012a7:	89 e5                	mov    %esp,%ebp
  8012a9:	56                   	push   %esi
  8012aa:	53                   	push   %ebx
  8012ab:	83 ec 30             	sub    $0x30,%esp
  8012ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8012b1:	8a 45 0c             	mov    0xc(%ebp),%al
  8012b4:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012b7:	89 34 24             	mov    %esi,(%esp)
  8012ba:	e8 b9 fe ff ff       	call   801178 <fd2num>
  8012bf:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8012c2:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012c6:	89 04 24             	mov    %eax,(%esp)
  8012c9:	e8 28 ff ff ff       	call   8011f6 <fd_lookup>
  8012ce:	89 c3                	mov    %eax,%ebx
  8012d0:	85 c0                	test   %eax,%eax
  8012d2:	78 05                	js     8012d9 <fd_close+0x33>
	    || fd != fd2)
  8012d4:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012d7:	74 0d                	je     8012e6 <fd_close+0x40>
		return (must_exist ? r : 0);
  8012d9:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8012dd:	75 46                	jne    801325 <fd_close+0x7f>
  8012df:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012e4:	eb 3f                	jmp    801325 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012e6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ed:	8b 06                	mov    (%esi),%eax
  8012ef:	89 04 24             	mov    %eax,(%esp)
  8012f2:	e8 55 ff ff ff       	call   80124c <dev_lookup>
  8012f7:	89 c3                	mov    %eax,%ebx
  8012f9:	85 c0                	test   %eax,%eax
  8012fb:	78 18                	js     801315 <fd_close+0x6f>
		if (dev->dev_close)
  8012fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801300:	8b 40 10             	mov    0x10(%eax),%eax
  801303:	85 c0                	test   %eax,%eax
  801305:	74 09                	je     801310 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801307:	89 34 24             	mov    %esi,(%esp)
  80130a:	ff d0                	call   *%eax
  80130c:	89 c3                	mov    %eax,%ebx
  80130e:	eb 05                	jmp    801315 <fd_close+0x6f>
		else
			r = 0;
  801310:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801315:	89 74 24 04          	mov    %esi,0x4(%esp)
  801319:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801320:	e8 0f fc ff ff       	call   800f34 <sys_page_unmap>
	return r;
}
  801325:	89 d8                	mov    %ebx,%eax
  801327:	83 c4 30             	add    $0x30,%esp
  80132a:	5b                   	pop    %ebx
  80132b:	5e                   	pop    %esi
  80132c:	5d                   	pop    %ebp
  80132d:	c3                   	ret    

0080132e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80132e:	55                   	push   %ebp
  80132f:	89 e5                	mov    %esp,%ebp
  801331:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801334:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801337:	89 44 24 04          	mov    %eax,0x4(%esp)
  80133b:	8b 45 08             	mov    0x8(%ebp),%eax
  80133e:	89 04 24             	mov    %eax,(%esp)
  801341:	e8 b0 fe ff ff       	call   8011f6 <fd_lookup>
  801346:	85 c0                	test   %eax,%eax
  801348:	78 13                	js     80135d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80134a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801351:	00 
  801352:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801355:	89 04 24             	mov    %eax,(%esp)
  801358:	e8 49 ff ff ff       	call   8012a6 <fd_close>
}
  80135d:	c9                   	leave  
  80135e:	c3                   	ret    

0080135f <close_all>:

void
close_all(void)
{
  80135f:	55                   	push   %ebp
  801360:	89 e5                	mov    %esp,%ebp
  801362:	53                   	push   %ebx
  801363:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801366:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80136b:	89 1c 24             	mov    %ebx,(%esp)
  80136e:	e8 bb ff ff ff       	call   80132e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801373:	43                   	inc    %ebx
  801374:	83 fb 20             	cmp    $0x20,%ebx
  801377:	75 f2                	jne    80136b <close_all+0xc>
		close(i);
}
  801379:	83 c4 14             	add    $0x14,%esp
  80137c:	5b                   	pop    %ebx
  80137d:	5d                   	pop    %ebp
  80137e:	c3                   	ret    

0080137f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80137f:	55                   	push   %ebp
  801380:	89 e5                	mov    %esp,%ebp
  801382:	57                   	push   %edi
  801383:	56                   	push   %esi
  801384:	53                   	push   %ebx
  801385:	83 ec 4c             	sub    $0x4c,%esp
  801388:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80138b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80138e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801392:	8b 45 08             	mov    0x8(%ebp),%eax
  801395:	89 04 24             	mov    %eax,(%esp)
  801398:	e8 59 fe ff ff       	call   8011f6 <fd_lookup>
  80139d:	89 c3                	mov    %eax,%ebx
  80139f:	85 c0                	test   %eax,%eax
  8013a1:	0f 88 e1 00 00 00    	js     801488 <dup+0x109>
		return r;
	close(newfdnum);
  8013a7:	89 3c 24             	mov    %edi,(%esp)
  8013aa:	e8 7f ff ff ff       	call   80132e <close>

	newfd = INDEX2FD(newfdnum);
  8013af:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8013b5:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8013b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013bb:	89 04 24             	mov    %eax,(%esp)
  8013be:	e8 c5 fd ff ff       	call   801188 <fd2data>
  8013c3:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8013c5:	89 34 24             	mov    %esi,(%esp)
  8013c8:	e8 bb fd ff ff       	call   801188 <fd2data>
  8013cd:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013d0:	89 d8                	mov    %ebx,%eax
  8013d2:	c1 e8 16             	shr    $0x16,%eax
  8013d5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013dc:	a8 01                	test   $0x1,%al
  8013de:	74 46                	je     801426 <dup+0xa7>
  8013e0:	89 d8                	mov    %ebx,%eax
  8013e2:	c1 e8 0c             	shr    $0xc,%eax
  8013e5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013ec:	f6 c2 01             	test   $0x1,%dl
  8013ef:	74 35                	je     801426 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013f1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013f8:	25 07 0e 00 00       	and    $0xe07,%eax
  8013fd:	89 44 24 10          	mov    %eax,0x10(%esp)
  801401:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801404:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801408:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80140f:	00 
  801410:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801414:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80141b:	e8 c1 fa ff ff       	call   800ee1 <sys_page_map>
  801420:	89 c3                	mov    %eax,%ebx
  801422:	85 c0                	test   %eax,%eax
  801424:	78 3b                	js     801461 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801426:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801429:	89 c2                	mov    %eax,%edx
  80142b:	c1 ea 0c             	shr    $0xc,%edx
  80142e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801435:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80143b:	89 54 24 10          	mov    %edx,0x10(%esp)
  80143f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801443:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80144a:	00 
  80144b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80144f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801456:	e8 86 fa ff ff       	call   800ee1 <sys_page_map>
  80145b:	89 c3                	mov    %eax,%ebx
  80145d:	85 c0                	test   %eax,%eax
  80145f:	79 25                	jns    801486 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801461:	89 74 24 04          	mov    %esi,0x4(%esp)
  801465:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80146c:	e8 c3 fa ff ff       	call   800f34 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801471:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801474:	89 44 24 04          	mov    %eax,0x4(%esp)
  801478:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80147f:	e8 b0 fa ff ff       	call   800f34 <sys_page_unmap>
	return r;
  801484:	eb 02                	jmp    801488 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801486:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801488:	89 d8                	mov    %ebx,%eax
  80148a:	83 c4 4c             	add    $0x4c,%esp
  80148d:	5b                   	pop    %ebx
  80148e:	5e                   	pop    %esi
  80148f:	5f                   	pop    %edi
  801490:	5d                   	pop    %ebp
  801491:	c3                   	ret    

00801492 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801492:	55                   	push   %ebp
  801493:	89 e5                	mov    %esp,%ebp
  801495:	53                   	push   %ebx
  801496:	83 ec 24             	sub    $0x24,%esp
  801499:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80149c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80149f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014a3:	89 1c 24             	mov    %ebx,(%esp)
  8014a6:	e8 4b fd ff ff       	call   8011f6 <fd_lookup>
  8014ab:	85 c0                	test   %eax,%eax
  8014ad:	78 6d                	js     80151c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014b9:	8b 00                	mov    (%eax),%eax
  8014bb:	89 04 24             	mov    %eax,(%esp)
  8014be:	e8 89 fd ff ff       	call   80124c <dev_lookup>
  8014c3:	85 c0                	test   %eax,%eax
  8014c5:	78 55                	js     80151c <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ca:	8b 50 08             	mov    0x8(%eax),%edx
  8014cd:	83 e2 03             	and    $0x3,%edx
  8014d0:	83 fa 01             	cmp    $0x1,%edx
  8014d3:	75 23                	jne    8014f8 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014d5:	a1 08 44 80 00       	mov    0x804408,%eax
  8014da:	8b 40 48             	mov    0x48(%eax),%eax
  8014dd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014e5:	c7 04 24 85 2b 80 00 	movl   $0x802b85,(%esp)
  8014ec:	e8 1f ef ff ff       	call   800410 <cprintf>
		return -E_INVAL;
  8014f1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014f6:	eb 24                	jmp    80151c <read+0x8a>
	}
	if (!dev->dev_read)
  8014f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014fb:	8b 52 08             	mov    0x8(%edx),%edx
  8014fe:	85 d2                	test   %edx,%edx
  801500:	74 15                	je     801517 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801502:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801505:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801509:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80150c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801510:	89 04 24             	mov    %eax,(%esp)
  801513:	ff d2                	call   *%edx
  801515:	eb 05                	jmp    80151c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801517:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80151c:	83 c4 24             	add    $0x24,%esp
  80151f:	5b                   	pop    %ebx
  801520:	5d                   	pop    %ebp
  801521:	c3                   	ret    

00801522 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801522:	55                   	push   %ebp
  801523:	89 e5                	mov    %esp,%ebp
  801525:	57                   	push   %edi
  801526:	56                   	push   %esi
  801527:	53                   	push   %ebx
  801528:	83 ec 1c             	sub    $0x1c,%esp
  80152b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80152e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801531:	bb 00 00 00 00       	mov    $0x0,%ebx
  801536:	eb 23                	jmp    80155b <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801538:	89 f0                	mov    %esi,%eax
  80153a:	29 d8                	sub    %ebx,%eax
  80153c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801540:	8b 45 0c             	mov    0xc(%ebp),%eax
  801543:	01 d8                	add    %ebx,%eax
  801545:	89 44 24 04          	mov    %eax,0x4(%esp)
  801549:	89 3c 24             	mov    %edi,(%esp)
  80154c:	e8 41 ff ff ff       	call   801492 <read>
		if (m < 0)
  801551:	85 c0                	test   %eax,%eax
  801553:	78 10                	js     801565 <readn+0x43>
			return m;
		if (m == 0)
  801555:	85 c0                	test   %eax,%eax
  801557:	74 0a                	je     801563 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801559:	01 c3                	add    %eax,%ebx
  80155b:	39 f3                	cmp    %esi,%ebx
  80155d:	72 d9                	jb     801538 <readn+0x16>
  80155f:	89 d8                	mov    %ebx,%eax
  801561:	eb 02                	jmp    801565 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801563:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801565:	83 c4 1c             	add    $0x1c,%esp
  801568:	5b                   	pop    %ebx
  801569:	5e                   	pop    %esi
  80156a:	5f                   	pop    %edi
  80156b:	5d                   	pop    %ebp
  80156c:	c3                   	ret    

0080156d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80156d:	55                   	push   %ebp
  80156e:	89 e5                	mov    %esp,%ebp
  801570:	53                   	push   %ebx
  801571:	83 ec 24             	sub    $0x24,%esp
  801574:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801577:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80157a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80157e:	89 1c 24             	mov    %ebx,(%esp)
  801581:	e8 70 fc ff ff       	call   8011f6 <fd_lookup>
  801586:	85 c0                	test   %eax,%eax
  801588:	78 68                	js     8015f2 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80158a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80158d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801591:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801594:	8b 00                	mov    (%eax),%eax
  801596:	89 04 24             	mov    %eax,(%esp)
  801599:	e8 ae fc ff ff       	call   80124c <dev_lookup>
  80159e:	85 c0                	test   %eax,%eax
  8015a0:	78 50                	js     8015f2 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015a9:	75 23                	jne    8015ce <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015ab:	a1 08 44 80 00       	mov    0x804408,%eax
  8015b0:	8b 40 48             	mov    0x48(%eax),%eax
  8015b3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8015b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015bb:	c7 04 24 a1 2b 80 00 	movl   $0x802ba1,(%esp)
  8015c2:	e8 49 ee ff ff       	call   800410 <cprintf>
		return -E_INVAL;
  8015c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015cc:	eb 24                	jmp    8015f2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015d1:	8b 52 0c             	mov    0xc(%edx),%edx
  8015d4:	85 d2                	test   %edx,%edx
  8015d6:	74 15                	je     8015ed <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015d8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015db:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015e2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8015e6:	89 04 24             	mov    %eax,(%esp)
  8015e9:	ff d2                	call   *%edx
  8015eb:	eb 05                	jmp    8015f2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015ed:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8015f2:	83 c4 24             	add    $0x24,%esp
  8015f5:	5b                   	pop    %ebx
  8015f6:	5d                   	pop    %ebp
  8015f7:	c3                   	ret    

008015f8 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015f8:	55                   	push   %ebp
  8015f9:	89 e5                	mov    %esp,%ebp
  8015fb:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015fe:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801601:	89 44 24 04          	mov    %eax,0x4(%esp)
  801605:	8b 45 08             	mov    0x8(%ebp),%eax
  801608:	89 04 24             	mov    %eax,(%esp)
  80160b:	e8 e6 fb ff ff       	call   8011f6 <fd_lookup>
  801610:	85 c0                	test   %eax,%eax
  801612:	78 0e                	js     801622 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801614:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801617:	8b 55 0c             	mov    0xc(%ebp),%edx
  80161a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80161d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801622:	c9                   	leave  
  801623:	c3                   	ret    

00801624 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801624:	55                   	push   %ebp
  801625:	89 e5                	mov    %esp,%ebp
  801627:	53                   	push   %ebx
  801628:	83 ec 24             	sub    $0x24,%esp
  80162b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80162e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801631:	89 44 24 04          	mov    %eax,0x4(%esp)
  801635:	89 1c 24             	mov    %ebx,(%esp)
  801638:	e8 b9 fb ff ff       	call   8011f6 <fd_lookup>
  80163d:	85 c0                	test   %eax,%eax
  80163f:	78 61                	js     8016a2 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801641:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801644:	89 44 24 04          	mov    %eax,0x4(%esp)
  801648:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80164b:	8b 00                	mov    (%eax),%eax
  80164d:	89 04 24             	mov    %eax,(%esp)
  801650:	e8 f7 fb ff ff       	call   80124c <dev_lookup>
  801655:	85 c0                	test   %eax,%eax
  801657:	78 49                	js     8016a2 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801659:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80165c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801660:	75 23                	jne    801685 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801662:	a1 08 44 80 00       	mov    0x804408,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801667:	8b 40 48             	mov    0x48(%eax),%eax
  80166a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80166e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801672:	c7 04 24 64 2b 80 00 	movl   $0x802b64,(%esp)
  801679:	e8 92 ed ff ff       	call   800410 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80167e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801683:	eb 1d                	jmp    8016a2 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801685:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801688:	8b 52 18             	mov    0x18(%edx),%edx
  80168b:	85 d2                	test   %edx,%edx
  80168d:	74 0e                	je     80169d <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80168f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801692:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801696:	89 04 24             	mov    %eax,(%esp)
  801699:	ff d2                	call   *%edx
  80169b:	eb 05                	jmp    8016a2 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80169d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8016a2:	83 c4 24             	add    $0x24,%esp
  8016a5:	5b                   	pop    %ebx
  8016a6:	5d                   	pop    %ebp
  8016a7:	c3                   	ret    

008016a8 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016a8:	55                   	push   %ebp
  8016a9:	89 e5                	mov    %esp,%ebp
  8016ab:	53                   	push   %ebx
  8016ac:	83 ec 24             	sub    $0x24,%esp
  8016af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016bc:	89 04 24             	mov    %eax,(%esp)
  8016bf:	e8 32 fb ff ff       	call   8011f6 <fd_lookup>
  8016c4:	85 c0                	test   %eax,%eax
  8016c6:	78 52                	js     80171a <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016d2:	8b 00                	mov    (%eax),%eax
  8016d4:	89 04 24             	mov    %eax,(%esp)
  8016d7:	e8 70 fb ff ff       	call   80124c <dev_lookup>
  8016dc:	85 c0                	test   %eax,%eax
  8016de:	78 3a                	js     80171a <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8016e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016e3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016e7:	74 2c                	je     801715 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016e9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016ec:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016f3:	00 00 00 
	stat->st_isdir = 0;
  8016f6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016fd:	00 00 00 
	stat->st_dev = dev;
  801700:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801706:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80170a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80170d:	89 14 24             	mov    %edx,(%esp)
  801710:	ff 50 14             	call   *0x14(%eax)
  801713:	eb 05                	jmp    80171a <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801715:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80171a:	83 c4 24             	add    $0x24,%esp
  80171d:	5b                   	pop    %ebx
  80171e:	5d                   	pop    %ebp
  80171f:	c3                   	ret    

00801720 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801720:	55                   	push   %ebp
  801721:	89 e5                	mov    %esp,%ebp
  801723:	56                   	push   %esi
  801724:	53                   	push   %ebx
  801725:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801728:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80172f:	00 
  801730:	8b 45 08             	mov    0x8(%ebp),%eax
  801733:	89 04 24             	mov    %eax,(%esp)
  801736:	e8 2d 02 00 00       	call   801968 <open>
  80173b:	89 c3                	mov    %eax,%ebx
  80173d:	85 c0                	test   %eax,%eax
  80173f:	78 1b                	js     80175c <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801741:	8b 45 0c             	mov    0xc(%ebp),%eax
  801744:	89 44 24 04          	mov    %eax,0x4(%esp)
  801748:	89 1c 24             	mov    %ebx,(%esp)
  80174b:	e8 58 ff ff ff       	call   8016a8 <fstat>
  801750:	89 c6                	mov    %eax,%esi
	close(fd);
  801752:	89 1c 24             	mov    %ebx,(%esp)
  801755:	e8 d4 fb ff ff       	call   80132e <close>
	return r;
  80175a:	89 f3                	mov    %esi,%ebx
}
  80175c:	89 d8                	mov    %ebx,%eax
  80175e:	83 c4 10             	add    $0x10,%esp
  801761:	5b                   	pop    %ebx
  801762:	5e                   	pop    %esi
  801763:	5d                   	pop    %ebp
  801764:	c3                   	ret    
  801765:	00 00                	add    %al,(%eax)
	...

00801768 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801768:	55                   	push   %ebp
  801769:	89 e5                	mov    %esp,%ebp
  80176b:	56                   	push   %esi
  80176c:	53                   	push   %ebx
  80176d:	83 ec 10             	sub    $0x10,%esp
  801770:	89 c3                	mov    %eax,%ebx
  801772:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801774:	83 3d 00 44 80 00 00 	cmpl   $0x0,0x804400
  80177b:	75 11                	jne    80178e <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80177d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801784:	e8 02 0d 00 00       	call   80248b <ipc_find_env>
  801789:	a3 00 44 80 00       	mov    %eax,0x804400
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80178e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801795:	00 
  801796:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  80179d:	00 
  80179e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017a2:	a1 00 44 80 00       	mov    0x804400,%eax
  8017a7:	89 04 24             	mov    %eax,(%esp)
  8017aa:	e8 6e 0c 00 00       	call   80241d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017af:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017b6:	00 
  8017b7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017c2:	e8 ed 0b 00 00       	call   8023b4 <ipc_recv>
}
  8017c7:	83 c4 10             	add    $0x10,%esp
  8017ca:	5b                   	pop    %ebx
  8017cb:	5e                   	pop    %esi
  8017cc:	5d                   	pop    %ebp
  8017cd:	c3                   	ret    

008017ce <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017ce:	55                   	push   %ebp
  8017cf:	89 e5                	mov    %esp,%ebp
  8017d1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d7:	8b 40 0c             	mov    0xc(%eax),%eax
  8017da:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017e2:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ec:	b8 02 00 00 00       	mov    $0x2,%eax
  8017f1:	e8 72 ff ff ff       	call   801768 <fsipc>
}
  8017f6:	c9                   	leave  
  8017f7:	c3                   	ret    

008017f8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017f8:	55                   	push   %ebp
  8017f9:	89 e5                	mov    %esp,%ebp
  8017fb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801801:	8b 40 0c             	mov    0xc(%eax),%eax
  801804:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801809:	ba 00 00 00 00       	mov    $0x0,%edx
  80180e:	b8 06 00 00 00       	mov    $0x6,%eax
  801813:	e8 50 ff ff ff       	call   801768 <fsipc>
}
  801818:	c9                   	leave  
  801819:	c3                   	ret    

0080181a <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80181a:	55                   	push   %ebp
  80181b:	89 e5                	mov    %esp,%ebp
  80181d:	53                   	push   %ebx
  80181e:	83 ec 14             	sub    $0x14,%esp
  801821:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801824:	8b 45 08             	mov    0x8(%ebp),%eax
  801827:	8b 40 0c             	mov    0xc(%eax),%eax
  80182a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80182f:	ba 00 00 00 00       	mov    $0x0,%edx
  801834:	b8 05 00 00 00       	mov    $0x5,%eax
  801839:	e8 2a ff ff ff       	call   801768 <fsipc>
  80183e:	85 c0                	test   %eax,%eax
  801840:	78 2b                	js     80186d <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801842:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801849:	00 
  80184a:	89 1c 24             	mov    %ebx,(%esp)
  80184d:	e8 49 f2 ff ff       	call   800a9b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801852:	a1 80 50 80 00       	mov    0x805080,%eax
  801857:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80185d:	a1 84 50 80 00       	mov    0x805084,%eax
  801862:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801868:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80186d:	83 c4 14             	add    $0x14,%esp
  801870:	5b                   	pop    %ebx
  801871:	5d                   	pop    %ebp
  801872:	c3                   	ret    

00801873 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801873:	55                   	push   %ebp
  801874:	89 e5                	mov    %esp,%ebp
  801876:	83 ec 18             	sub    $0x18,%esp
  801879:	8b 55 10             	mov    0x10(%ebp),%edx
  80187c:	89 d0                	mov    %edx,%eax
  80187e:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  801884:	76 05                	jbe    80188b <devfile_write+0x18>
  801886:	b8 00 10 00 00       	mov    $0x1000,%eax
	//panic("devfile_write not implemented");
	int r;
	//uint32_t maxsize = BLKSIZE - sizeof(int) - sizeof(size_t);	
	if (n > BLKSIZE)
		n = BLKSIZE;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80188b:	8b 55 08             	mov    0x8(%ebp),%edx
  80188e:	8b 52 0c             	mov    0xc(%edx),%edx
  801891:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801897:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80189c:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a7:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  8018ae:	e8 61 f3 ff ff       	call   800c14 <memmove>
	 
	return fsipc(FSREQ_WRITE, NULL);
  8018b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b8:	b8 04 00 00 00       	mov    $0x4,%eax
  8018bd:	e8 a6 fe ff ff       	call   801768 <fsipc>
}
  8018c2:	c9                   	leave  
  8018c3:	c3                   	ret    

008018c4 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018c4:	55                   	push   %ebp
  8018c5:	89 e5                	mov    %esp,%ebp
  8018c7:	56                   	push   %esi
  8018c8:	53                   	push   %ebx
  8018c9:	83 ec 10             	sub    $0x10,%esp
  8018cc:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d2:	8b 40 0c             	mov    0xc(%eax),%eax
  8018d5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018da:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e5:	b8 03 00 00 00       	mov    $0x3,%eax
  8018ea:	e8 79 fe ff ff       	call   801768 <fsipc>
  8018ef:	89 c3                	mov    %eax,%ebx
  8018f1:	85 c0                	test   %eax,%eax
  8018f3:	78 6a                	js     80195f <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8018f5:	39 c6                	cmp    %eax,%esi
  8018f7:	73 24                	jae    80191d <devfile_read+0x59>
  8018f9:	c7 44 24 0c d4 2b 80 	movl   $0x802bd4,0xc(%esp)
  801900:	00 
  801901:	c7 44 24 08 db 2b 80 	movl   $0x802bdb,0x8(%esp)
  801908:	00 
  801909:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801910:	00 
  801911:	c7 04 24 f0 2b 80 00 	movl   $0x802bf0,(%esp)
  801918:	e8 fb e9 ff ff       	call   800318 <_panic>
	assert(r <= PGSIZE);
  80191d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801922:	7e 24                	jle    801948 <devfile_read+0x84>
  801924:	c7 44 24 0c fb 2b 80 	movl   $0x802bfb,0xc(%esp)
  80192b:	00 
  80192c:	c7 44 24 08 db 2b 80 	movl   $0x802bdb,0x8(%esp)
  801933:	00 
  801934:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  80193b:	00 
  80193c:	c7 04 24 f0 2b 80 00 	movl   $0x802bf0,(%esp)
  801943:	e8 d0 e9 ff ff       	call   800318 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801948:	89 44 24 08          	mov    %eax,0x8(%esp)
  80194c:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801953:	00 
  801954:	8b 45 0c             	mov    0xc(%ebp),%eax
  801957:	89 04 24             	mov    %eax,(%esp)
  80195a:	e8 b5 f2 ff ff       	call   800c14 <memmove>
	return r;
}
  80195f:	89 d8                	mov    %ebx,%eax
  801961:	83 c4 10             	add    $0x10,%esp
  801964:	5b                   	pop    %ebx
  801965:	5e                   	pop    %esi
  801966:	5d                   	pop    %ebp
  801967:	c3                   	ret    

00801968 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801968:	55                   	push   %ebp
  801969:	89 e5                	mov    %esp,%ebp
  80196b:	56                   	push   %esi
  80196c:	53                   	push   %ebx
  80196d:	83 ec 20             	sub    $0x20,%esp
  801970:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801973:	89 34 24             	mov    %esi,(%esp)
  801976:	e8 ed f0 ff ff       	call   800a68 <strlen>
  80197b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801980:	7f 60                	jg     8019e2 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801982:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801985:	89 04 24             	mov    %eax,(%esp)
  801988:	e8 16 f8 ff ff       	call   8011a3 <fd_alloc>
  80198d:	89 c3                	mov    %eax,%ebx
  80198f:	85 c0                	test   %eax,%eax
  801991:	78 54                	js     8019e7 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801993:	89 74 24 04          	mov    %esi,0x4(%esp)
  801997:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  80199e:	e8 f8 f0 ff ff       	call   800a9b <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019a6:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019ae:	b8 01 00 00 00       	mov    $0x1,%eax
  8019b3:	e8 b0 fd ff ff       	call   801768 <fsipc>
  8019b8:	89 c3                	mov    %eax,%ebx
  8019ba:	85 c0                	test   %eax,%eax
  8019bc:	79 15                	jns    8019d3 <open+0x6b>
		fd_close(fd, 0);
  8019be:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8019c5:	00 
  8019c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019c9:	89 04 24             	mov    %eax,(%esp)
  8019cc:	e8 d5 f8 ff ff       	call   8012a6 <fd_close>
		return r;
  8019d1:	eb 14                	jmp    8019e7 <open+0x7f>
	}

	return fd2num(fd);
  8019d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019d6:	89 04 24             	mov    %eax,(%esp)
  8019d9:	e8 9a f7 ff ff       	call   801178 <fd2num>
  8019de:	89 c3                	mov    %eax,%ebx
  8019e0:	eb 05                	jmp    8019e7 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019e2:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019e7:	89 d8                	mov    %ebx,%eax
  8019e9:	83 c4 20             	add    $0x20,%esp
  8019ec:	5b                   	pop    %ebx
  8019ed:	5e                   	pop    %esi
  8019ee:	5d                   	pop    %ebp
  8019ef:	c3                   	ret    

008019f0 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019f0:	55                   	push   %ebp
  8019f1:	89 e5                	mov    %esp,%ebp
  8019f3:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8019fb:	b8 08 00 00 00       	mov    $0x8,%eax
  801a00:	e8 63 fd ff ff       	call   801768 <fsipc>
}
  801a05:	c9                   	leave  
  801a06:	c3                   	ret    
	...

00801a08 <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  801a08:	55                   	push   %ebp
  801a09:	89 e5                	mov    %esp,%ebp
  801a0b:	53                   	push   %ebx
  801a0c:	83 ec 14             	sub    $0x14,%esp
  801a0f:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  801a11:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801a15:	7e 32                	jle    801a49 <writebuf+0x41>
		ssize_t result = write(b->fd, b->buf, b->idx);
  801a17:	8b 40 04             	mov    0x4(%eax),%eax
  801a1a:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a1e:	8d 43 10             	lea    0x10(%ebx),%eax
  801a21:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a25:	8b 03                	mov    (%ebx),%eax
  801a27:	89 04 24             	mov    %eax,(%esp)
  801a2a:	e8 3e fb ff ff       	call   80156d <write>
		if (result > 0)
  801a2f:	85 c0                	test   %eax,%eax
  801a31:	7e 03                	jle    801a36 <writebuf+0x2e>
			b->result += result;
  801a33:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801a36:	39 43 04             	cmp    %eax,0x4(%ebx)
  801a39:	74 0e                	je     801a49 <writebuf+0x41>
			b->error = (result < 0 ? result : 0);
  801a3b:	89 c2                	mov    %eax,%edx
  801a3d:	85 c0                	test   %eax,%eax
  801a3f:	7e 05                	jle    801a46 <writebuf+0x3e>
  801a41:	ba 00 00 00 00       	mov    $0x0,%edx
  801a46:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  801a49:	83 c4 14             	add    $0x14,%esp
  801a4c:	5b                   	pop    %ebx
  801a4d:	5d                   	pop    %ebp
  801a4e:	c3                   	ret    

00801a4f <putch>:

static void
putch(int ch, void *thunk)
{
  801a4f:	55                   	push   %ebp
  801a50:	89 e5                	mov    %esp,%ebp
  801a52:	53                   	push   %ebx
  801a53:	83 ec 04             	sub    $0x4,%esp
  801a56:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801a59:	8b 43 04             	mov    0x4(%ebx),%eax
  801a5c:	8b 55 08             	mov    0x8(%ebp),%edx
  801a5f:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  801a63:	40                   	inc    %eax
  801a64:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  801a67:	3d 00 01 00 00       	cmp    $0x100,%eax
  801a6c:	75 0e                	jne    801a7c <putch+0x2d>
		writebuf(b);
  801a6e:	89 d8                	mov    %ebx,%eax
  801a70:	e8 93 ff ff ff       	call   801a08 <writebuf>
		b->idx = 0;
  801a75:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801a7c:	83 c4 04             	add    $0x4,%esp
  801a7f:	5b                   	pop    %ebx
  801a80:	5d                   	pop    %ebp
  801a81:	c3                   	ret    

00801a82 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801a82:	55                   	push   %ebp
  801a83:	89 e5                	mov    %esp,%ebp
  801a85:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  801a8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a8e:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801a94:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801a9b:	00 00 00 
	b.result = 0;
  801a9e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801aa5:	00 00 00 
	b.error = 1;
  801aa8:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801aaf:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801ab2:	8b 45 10             	mov    0x10(%ebp),%eax
  801ab5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ab9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801abc:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ac0:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801ac6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aca:	c7 04 24 4f 1a 80 00 	movl   $0x801a4f,(%esp)
  801ad1:	e8 9c ea ff ff       	call   800572 <vprintfmt>
	if (b.idx > 0)
  801ad6:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801add:	7e 0b                	jle    801aea <vfprintf+0x68>
		writebuf(&b);
  801adf:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801ae5:	e8 1e ff ff ff       	call   801a08 <writebuf>

	return (b.result ? b.result : b.error);
  801aea:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801af0:	85 c0                	test   %eax,%eax
  801af2:	75 06                	jne    801afa <vfprintf+0x78>
  801af4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  801afa:	c9                   	leave  
  801afb:	c3                   	ret    

00801afc <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801afc:	55                   	push   %ebp
  801afd:	89 e5                	mov    %esp,%ebp
  801aff:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801b02:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801b05:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b09:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b0c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b10:	8b 45 08             	mov    0x8(%ebp),%eax
  801b13:	89 04 24             	mov    %eax,(%esp)
  801b16:	e8 67 ff ff ff       	call   801a82 <vfprintf>
	va_end(ap);

	return cnt;
}
  801b1b:	c9                   	leave  
  801b1c:	c3                   	ret    

00801b1d <printf>:

int
printf(const char *fmt, ...)
{
  801b1d:	55                   	push   %ebp
  801b1e:	89 e5                	mov    %esp,%ebp
  801b20:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801b23:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801b26:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b2a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b2d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b31:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801b38:	e8 45 ff ff ff       	call   801a82 <vfprintf>
	va_end(ap);

	return cnt;
}
  801b3d:	c9                   	leave  
  801b3e:	c3                   	ret    
	...

00801b40 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801b40:	55                   	push   %ebp
  801b41:	89 e5                	mov    %esp,%ebp
  801b43:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801b46:	c7 44 24 04 07 2c 80 	movl   $0x802c07,0x4(%esp)
  801b4d:	00 
  801b4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b51:	89 04 24             	mov    %eax,(%esp)
  801b54:	e8 42 ef ff ff       	call   800a9b <strcpy>
	return 0;
}
  801b59:	b8 00 00 00 00       	mov    $0x0,%eax
  801b5e:	c9                   	leave  
  801b5f:	c3                   	ret    

00801b60 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801b60:	55                   	push   %ebp
  801b61:	89 e5                	mov    %esp,%ebp
  801b63:	53                   	push   %ebx
  801b64:	83 ec 14             	sub    $0x14,%esp
  801b67:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801b6a:	89 1c 24             	mov    %ebx,(%esp)
  801b6d:	e8 52 09 00 00       	call   8024c4 <pageref>
  801b72:	83 f8 01             	cmp    $0x1,%eax
  801b75:	75 0d                	jne    801b84 <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  801b77:	8b 43 0c             	mov    0xc(%ebx),%eax
  801b7a:	89 04 24             	mov    %eax,(%esp)
  801b7d:	e8 1f 03 00 00       	call   801ea1 <nsipc_close>
  801b82:	eb 05                	jmp    801b89 <devsock_close+0x29>
	else
		return 0;
  801b84:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b89:	83 c4 14             	add    $0x14,%esp
  801b8c:	5b                   	pop    %ebx
  801b8d:	5d                   	pop    %ebp
  801b8e:	c3                   	ret    

00801b8f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801b8f:	55                   	push   %ebp
  801b90:	89 e5                	mov    %esp,%ebp
  801b92:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801b95:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801b9c:	00 
  801b9d:	8b 45 10             	mov    0x10(%ebp),%eax
  801ba0:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ba4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ba7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bab:	8b 45 08             	mov    0x8(%ebp),%eax
  801bae:	8b 40 0c             	mov    0xc(%eax),%eax
  801bb1:	89 04 24             	mov    %eax,(%esp)
  801bb4:	e8 e3 03 00 00       	call   801f9c <nsipc_send>
}
  801bb9:	c9                   	leave  
  801bba:	c3                   	ret    

00801bbb <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801bbb:	55                   	push   %ebp
  801bbc:	89 e5                	mov    %esp,%ebp
  801bbe:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801bc1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801bc8:	00 
  801bc9:	8b 45 10             	mov    0x10(%ebp),%eax
  801bcc:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bd0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bd3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bd7:	8b 45 08             	mov    0x8(%ebp),%eax
  801bda:	8b 40 0c             	mov    0xc(%eax),%eax
  801bdd:	89 04 24             	mov    %eax,(%esp)
  801be0:	e8 37 03 00 00       	call   801f1c <nsipc_recv>
}
  801be5:	c9                   	leave  
  801be6:	c3                   	ret    

00801be7 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801be7:	55                   	push   %ebp
  801be8:	89 e5                	mov    %esp,%ebp
  801bea:	56                   	push   %esi
  801beb:	53                   	push   %ebx
  801bec:	83 ec 20             	sub    $0x20,%esp
  801bef:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801bf1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bf4:	89 04 24             	mov    %eax,(%esp)
  801bf7:	e8 a7 f5 ff ff       	call   8011a3 <fd_alloc>
  801bfc:	89 c3                	mov    %eax,%ebx
  801bfe:	85 c0                	test   %eax,%eax
  801c00:	78 21                	js     801c23 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801c02:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801c09:	00 
  801c0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c11:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c18:	e8 70 f2 ff ff       	call   800e8d <sys_page_alloc>
  801c1d:	89 c3                	mov    %eax,%ebx
  801c1f:	85 c0                	test   %eax,%eax
  801c21:	79 0a                	jns    801c2d <alloc_sockfd+0x46>
		nsipc_close(sockid);
  801c23:	89 34 24             	mov    %esi,(%esp)
  801c26:	e8 76 02 00 00       	call   801ea1 <nsipc_close>
		return r;
  801c2b:	eb 22                	jmp    801c4f <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801c2d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c33:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c36:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801c38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c3b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801c42:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801c45:	89 04 24             	mov    %eax,(%esp)
  801c48:	e8 2b f5 ff ff       	call   801178 <fd2num>
  801c4d:	89 c3                	mov    %eax,%ebx
}
  801c4f:	89 d8                	mov    %ebx,%eax
  801c51:	83 c4 20             	add    $0x20,%esp
  801c54:	5b                   	pop    %ebx
  801c55:	5e                   	pop    %esi
  801c56:	5d                   	pop    %ebp
  801c57:	c3                   	ret    

00801c58 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801c58:	55                   	push   %ebp
  801c59:	89 e5                	mov    %esp,%ebp
  801c5b:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801c5e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801c61:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c65:	89 04 24             	mov    %eax,(%esp)
  801c68:	e8 89 f5 ff ff       	call   8011f6 <fd_lookup>
  801c6d:	85 c0                	test   %eax,%eax
  801c6f:	78 17                	js     801c88 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801c71:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c74:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c7a:	39 10                	cmp    %edx,(%eax)
  801c7c:	75 05                	jne    801c83 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801c7e:	8b 40 0c             	mov    0xc(%eax),%eax
  801c81:	eb 05                	jmp    801c88 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801c83:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801c88:	c9                   	leave  
  801c89:	c3                   	ret    

00801c8a <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c8a:	55                   	push   %ebp
  801c8b:	89 e5                	mov    %esp,%ebp
  801c8d:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c90:	8b 45 08             	mov    0x8(%ebp),%eax
  801c93:	e8 c0 ff ff ff       	call   801c58 <fd2sockid>
  801c98:	85 c0                	test   %eax,%eax
  801c9a:	78 1f                	js     801cbb <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801c9c:	8b 55 10             	mov    0x10(%ebp),%edx
  801c9f:	89 54 24 08          	mov    %edx,0x8(%esp)
  801ca3:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ca6:	89 54 24 04          	mov    %edx,0x4(%esp)
  801caa:	89 04 24             	mov    %eax,(%esp)
  801cad:	e8 38 01 00 00       	call   801dea <nsipc_accept>
  801cb2:	85 c0                	test   %eax,%eax
  801cb4:	78 05                	js     801cbb <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801cb6:	e8 2c ff ff ff       	call   801be7 <alloc_sockfd>
}
  801cbb:	c9                   	leave  
  801cbc:	c3                   	ret    

00801cbd <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801cbd:	55                   	push   %ebp
  801cbe:	89 e5                	mov    %esp,%ebp
  801cc0:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cc3:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc6:	e8 8d ff ff ff       	call   801c58 <fd2sockid>
  801ccb:	85 c0                	test   %eax,%eax
  801ccd:	78 16                	js     801ce5 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801ccf:	8b 55 10             	mov    0x10(%ebp),%edx
  801cd2:	89 54 24 08          	mov    %edx,0x8(%esp)
  801cd6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cd9:	89 54 24 04          	mov    %edx,0x4(%esp)
  801cdd:	89 04 24             	mov    %eax,(%esp)
  801ce0:	e8 5b 01 00 00       	call   801e40 <nsipc_bind>
}
  801ce5:	c9                   	leave  
  801ce6:	c3                   	ret    

00801ce7 <shutdown>:

int
shutdown(int s, int how)
{
  801ce7:	55                   	push   %ebp
  801ce8:	89 e5                	mov    %esp,%ebp
  801cea:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ced:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf0:	e8 63 ff ff ff       	call   801c58 <fd2sockid>
  801cf5:	85 c0                	test   %eax,%eax
  801cf7:	78 0f                	js     801d08 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801cf9:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cfc:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d00:	89 04 24             	mov    %eax,(%esp)
  801d03:	e8 77 01 00 00       	call   801e7f <nsipc_shutdown>
}
  801d08:	c9                   	leave  
  801d09:	c3                   	ret    

00801d0a <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d0a:	55                   	push   %ebp
  801d0b:	89 e5                	mov    %esp,%ebp
  801d0d:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d10:	8b 45 08             	mov    0x8(%ebp),%eax
  801d13:	e8 40 ff ff ff       	call   801c58 <fd2sockid>
  801d18:	85 c0                	test   %eax,%eax
  801d1a:	78 16                	js     801d32 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801d1c:	8b 55 10             	mov    0x10(%ebp),%edx
  801d1f:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d23:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d26:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d2a:	89 04 24             	mov    %eax,(%esp)
  801d2d:	e8 89 01 00 00       	call   801ebb <nsipc_connect>
}
  801d32:	c9                   	leave  
  801d33:	c3                   	ret    

00801d34 <listen>:

int
listen(int s, int backlog)
{
  801d34:	55                   	push   %ebp
  801d35:	89 e5                	mov    %esp,%ebp
  801d37:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d3a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d3d:	e8 16 ff ff ff       	call   801c58 <fd2sockid>
  801d42:	85 c0                	test   %eax,%eax
  801d44:	78 0f                	js     801d55 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801d46:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d49:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d4d:	89 04 24             	mov    %eax,(%esp)
  801d50:	e8 a5 01 00 00       	call   801efa <nsipc_listen>
}
  801d55:	c9                   	leave  
  801d56:	c3                   	ret    

00801d57 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801d57:	55                   	push   %ebp
  801d58:	89 e5                	mov    %esp,%ebp
  801d5a:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801d5d:	8b 45 10             	mov    0x10(%ebp),%eax
  801d60:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d64:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d67:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d6b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d6e:	89 04 24             	mov    %eax,(%esp)
  801d71:	e8 99 02 00 00       	call   80200f <nsipc_socket>
  801d76:	85 c0                	test   %eax,%eax
  801d78:	78 05                	js     801d7f <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801d7a:	e8 68 fe ff ff       	call   801be7 <alloc_sockfd>
}
  801d7f:	c9                   	leave  
  801d80:	c3                   	ret    
  801d81:	00 00                	add    %al,(%eax)
	...

00801d84 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801d84:	55                   	push   %ebp
  801d85:	89 e5                	mov    %esp,%ebp
  801d87:	53                   	push   %ebx
  801d88:	83 ec 14             	sub    $0x14,%esp
  801d8b:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801d8d:	83 3d 04 44 80 00 00 	cmpl   $0x0,0x804404
  801d94:	75 11                	jne    801da7 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801d96:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801d9d:	e8 e9 06 00 00       	call   80248b <ipc_find_env>
  801da2:	a3 04 44 80 00       	mov    %eax,0x804404
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801da7:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801dae:	00 
  801daf:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801db6:	00 
  801db7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801dbb:	a1 04 44 80 00       	mov    0x804404,%eax
  801dc0:	89 04 24             	mov    %eax,(%esp)
  801dc3:	e8 55 06 00 00       	call   80241d <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801dc8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801dcf:	00 
  801dd0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801dd7:	00 
  801dd8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ddf:	e8 d0 05 00 00       	call   8023b4 <ipc_recv>
}
  801de4:	83 c4 14             	add    $0x14,%esp
  801de7:	5b                   	pop    %ebx
  801de8:	5d                   	pop    %ebp
  801de9:	c3                   	ret    

00801dea <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801dea:	55                   	push   %ebp
  801deb:	89 e5                	mov    %esp,%ebp
  801ded:	56                   	push   %esi
  801dee:	53                   	push   %ebx
  801def:	83 ec 10             	sub    $0x10,%esp
  801df2:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801df5:	8b 45 08             	mov    0x8(%ebp),%eax
  801df8:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801dfd:	8b 06                	mov    (%esi),%eax
  801dff:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801e04:	b8 01 00 00 00       	mov    $0x1,%eax
  801e09:	e8 76 ff ff ff       	call   801d84 <nsipc>
  801e0e:	89 c3                	mov    %eax,%ebx
  801e10:	85 c0                	test   %eax,%eax
  801e12:	78 23                	js     801e37 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801e14:	a1 10 60 80 00       	mov    0x806010,%eax
  801e19:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e1d:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801e24:	00 
  801e25:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e28:	89 04 24             	mov    %eax,(%esp)
  801e2b:	e8 e4 ed ff ff       	call   800c14 <memmove>
		*addrlen = ret->ret_addrlen;
  801e30:	a1 10 60 80 00       	mov    0x806010,%eax
  801e35:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801e37:	89 d8                	mov    %ebx,%eax
  801e39:	83 c4 10             	add    $0x10,%esp
  801e3c:	5b                   	pop    %ebx
  801e3d:	5e                   	pop    %esi
  801e3e:	5d                   	pop    %ebp
  801e3f:	c3                   	ret    

00801e40 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801e40:	55                   	push   %ebp
  801e41:	89 e5                	mov    %esp,%ebp
  801e43:	53                   	push   %ebx
  801e44:	83 ec 14             	sub    $0x14,%esp
  801e47:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801e4a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e4d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801e52:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e56:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e59:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e5d:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801e64:	e8 ab ed ff ff       	call   800c14 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801e69:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801e6f:	b8 02 00 00 00       	mov    $0x2,%eax
  801e74:	e8 0b ff ff ff       	call   801d84 <nsipc>
}
  801e79:	83 c4 14             	add    $0x14,%esp
  801e7c:	5b                   	pop    %ebx
  801e7d:	5d                   	pop    %ebp
  801e7e:	c3                   	ret    

00801e7f <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801e7f:	55                   	push   %ebp
  801e80:	89 e5                	mov    %esp,%ebp
  801e82:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801e85:	8b 45 08             	mov    0x8(%ebp),%eax
  801e88:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801e8d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e90:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801e95:	b8 03 00 00 00       	mov    $0x3,%eax
  801e9a:	e8 e5 fe ff ff       	call   801d84 <nsipc>
}
  801e9f:	c9                   	leave  
  801ea0:	c3                   	ret    

00801ea1 <nsipc_close>:

int
nsipc_close(int s)
{
  801ea1:	55                   	push   %ebp
  801ea2:	89 e5                	mov    %esp,%ebp
  801ea4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801ea7:	8b 45 08             	mov    0x8(%ebp),%eax
  801eaa:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801eaf:	b8 04 00 00 00       	mov    $0x4,%eax
  801eb4:	e8 cb fe ff ff       	call   801d84 <nsipc>
}
  801eb9:	c9                   	leave  
  801eba:	c3                   	ret    

00801ebb <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ebb:	55                   	push   %ebp
  801ebc:	89 e5                	mov    %esp,%ebp
  801ebe:	53                   	push   %ebx
  801ebf:	83 ec 14             	sub    $0x14,%esp
  801ec2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801ec5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ec8:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801ecd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ed1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ed4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ed8:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801edf:	e8 30 ed ff ff       	call   800c14 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801ee4:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801eea:	b8 05 00 00 00       	mov    $0x5,%eax
  801eef:	e8 90 fe ff ff       	call   801d84 <nsipc>
}
  801ef4:	83 c4 14             	add    $0x14,%esp
  801ef7:	5b                   	pop    %ebx
  801ef8:	5d                   	pop    %ebp
  801ef9:	c3                   	ret    

00801efa <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801efa:	55                   	push   %ebp
  801efb:	89 e5                	mov    %esp,%ebp
  801efd:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801f00:	8b 45 08             	mov    0x8(%ebp),%eax
  801f03:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801f08:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f0b:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801f10:	b8 06 00 00 00       	mov    $0x6,%eax
  801f15:	e8 6a fe ff ff       	call   801d84 <nsipc>
}
  801f1a:	c9                   	leave  
  801f1b:	c3                   	ret    

00801f1c <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801f1c:	55                   	push   %ebp
  801f1d:	89 e5                	mov    %esp,%ebp
  801f1f:	56                   	push   %esi
  801f20:	53                   	push   %ebx
  801f21:	83 ec 10             	sub    $0x10,%esp
  801f24:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801f27:	8b 45 08             	mov    0x8(%ebp),%eax
  801f2a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801f2f:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801f35:	8b 45 14             	mov    0x14(%ebp),%eax
  801f38:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801f3d:	b8 07 00 00 00       	mov    $0x7,%eax
  801f42:	e8 3d fe ff ff       	call   801d84 <nsipc>
  801f47:	89 c3                	mov    %eax,%ebx
  801f49:	85 c0                	test   %eax,%eax
  801f4b:	78 46                	js     801f93 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801f4d:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801f52:	7f 04                	jg     801f58 <nsipc_recv+0x3c>
  801f54:	39 c6                	cmp    %eax,%esi
  801f56:	7d 24                	jge    801f7c <nsipc_recv+0x60>
  801f58:	c7 44 24 0c 13 2c 80 	movl   $0x802c13,0xc(%esp)
  801f5f:	00 
  801f60:	c7 44 24 08 db 2b 80 	movl   $0x802bdb,0x8(%esp)
  801f67:	00 
  801f68:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  801f6f:	00 
  801f70:	c7 04 24 28 2c 80 00 	movl   $0x802c28,(%esp)
  801f77:	e8 9c e3 ff ff       	call   800318 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801f7c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f80:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801f87:	00 
  801f88:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f8b:	89 04 24             	mov    %eax,(%esp)
  801f8e:	e8 81 ec ff ff       	call   800c14 <memmove>
	}

	return r;
}
  801f93:	89 d8                	mov    %ebx,%eax
  801f95:	83 c4 10             	add    $0x10,%esp
  801f98:	5b                   	pop    %ebx
  801f99:	5e                   	pop    %esi
  801f9a:	5d                   	pop    %ebp
  801f9b:	c3                   	ret    

00801f9c <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801f9c:	55                   	push   %ebp
  801f9d:	89 e5                	mov    %esp,%ebp
  801f9f:	53                   	push   %ebx
  801fa0:	83 ec 14             	sub    $0x14,%esp
  801fa3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801fa6:	8b 45 08             	mov    0x8(%ebp),%eax
  801fa9:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801fae:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801fb4:	7e 24                	jle    801fda <nsipc_send+0x3e>
  801fb6:	c7 44 24 0c 34 2c 80 	movl   $0x802c34,0xc(%esp)
  801fbd:	00 
  801fbe:	c7 44 24 08 db 2b 80 	movl   $0x802bdb,0x8(%esp)
  801fc5:	00 
  801fc6:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  801fcd:	00 
  801fce:	c7 04 24 28 2c 80 00 	movl   $0x802c28,(%esp)
  801fd5:	e8 3e e3 ff ff       	call   800318 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801fda:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fde:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fe1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fe5:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  801fec:	e8 23 ec ff ff       	call   800c14 <memmove>
	nsipcbuf.send.req_size = size;
  801ff1:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801ff7:	8b 45 14             	mov    0x14(%ebp),%eax
  801ffa:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801fff:	b8 08 00 00 00       	mov    $0x8,%eax
  802004:	e8 7b fd ff ff       	call   801d84 <nsipc>
}
  802009:	83 c4 14             	add    $0x14,%esp
  80200c:	5b                   	pop    %ebx
  80200d:	5d                   	pop    %ebp
  80200e:	c3                   	ret    

0080200f <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80200f:	55                   	push   %ebp
  802010:	89 e5                	mov    %esp,%ebp
  802012:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802015:	8b 45 08             	mov    0x8(%ebp),%eax
  802018:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  80201d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802020:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  802025:	8b 45 10             	mov    0x10(%ebp),%eax
  802028:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  80202d:	b8 09 00 00 00       	mov    $0x9,%eax
  802032:	e8 4d fd ff ff       	call   801d84 <nsipc>
}
  802037:	c9                   	leave  
  802038:	c3                   	ret    
  802039:	00 00                	add    %al,(%eax)
	...

0080203c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80203c:	55                   	push   %ebp
  80203d:	89 e5                	mov    %esp,%ebp
  80203f:	56                   	push   %esi
  802040:	53                   	push   %ebx
  802041:	83 ec 10             	sub    $0x10,%esp
  802044:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802047:	8b 45 08             	mov    0x8(%ebp),%eax
  80204a:	89 04 24             	mov    %eax,(%esp)
  80204d:	e8 36 f1 ff ff       	call   801188 <fd2data>
  802052:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  802054:	c7 44 24 04 40 2c 80 	movl   $0x802c40,0x4(%esp)
  80205b:	00 
  80205c:	89 34 24             	mov    %esi,(%esp)
  80205f:	e8 37 ea ff ff       	call   800a9b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802064:	8b 43 04             	mov    0x4(%ebx),%eax
  802067:	2b 03                	sub    (%ebx),%eax
  802069:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80206f:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  802076:	00 00 00 
	stat->st_dev = &devpipe;
  802079:	c7 86 88 00 00 00 58 	movl   $0x803058,0x88(%esi)
  802080:	30 80 00 
	return 0;
}
  802083:	b8 00 00 00 00       	mov    $0x0,%eax
  802088:	83 c4 10             	add    $0x10,%esp
  80208b:	5b                   	pop    %ebx
  80208c:	5e                   	pop    %esi
  80208d:	5d                   	pop    %ebp
  80208e:	c3                   	ret    

0080208f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80208f:	55                   	push   %ebp
  802090:	89 e5                	mov    %esp,%ebp
  802092:	53                   	push   %ebx
  802093:	83 ec 14             	sub    $0x14,%esp
  802096:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802099:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80209d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020a4:	e8 8b ee ff ff       	call   800f34 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8020a9:	89 1c 24             	mov    %ebx,(%esp)
  8020ac:	e8 d7 f0 ff ff       	call   801188 <fd2data>
  8020b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020b5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020bc:	e8 73 ee ff ff       	call   800f34 <sys_page_unmap>
}
  8020c1:	83 c4 14             	add    $0x14,%esp
  8020c4:	5b                   	pop    %ebx
  8020c5:	5d                   	pop    %ebp
  8020c6:	c3                   	ret    

008020c7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8020c7:	55                   	push   %ebp
  8020c8:	89 e5                	mov    %esp,%ebp
  8020ca:	57                   	push   %edi
  8020cb:	56                   	push   %esi
  8020cc:	53                   	push   %ebx
  8020cd:	83 ec 2c             	sub    $0x2c,%esp
  8020d0:	89 c7                	mov    %eax,%edi
  8020d2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8020d5:	a1 08 44 80 00       	mov    0x804408,%eax
  8020da:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8020dd:	89 3c 24             	mov    %edi,(%esp)
  8020e0:	e8 df 03 00 00       	call   8024c4 <pageref>
  8020e5:	89 c6                	mov    %eax,%esi
  8020e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020ea:	89 04 24             	mov    %eax,(%esp)
  8020ed:	e8 d2 03 00 00       	call   8024c4 <pageref>
  8020f2:	39 c6                	cmp    %eax,%esi
  8020f4:	0f 94 c0             	sete   %al
  8020f7:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8020fa:	8b 15 08 44 80 00    	mov    0x804408,%edx
  802100:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802103:	39 cb                	cmp    %ecx,%ebx
  802105:	75 08                	jne    80210f <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  802107:	83 c4 2c             	add    $0x2c,%esp
  80210a:	5b                   	pop    %ebx
  80210b:	5e                   	pop    %esi
  80210c:	5f                   	pop    %edi
  80210d:	5d                   	pop    %ebp
  80210e:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  80210f:	83 f8 01             	cmp    $0x1,%eax
  802112:	75 c1                	jne    8020d5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802114:	8b 42 58             	mov    0x58(%edx),%eax
  802117:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  80211e:	00 
  80211f:	89 44 24 08          	mov    %eax,0x8(%esp)
  802123:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802127:	c7 04 24 47 2c 80 00 	movl   $0x802c47,(%esp)
  80212e:	e8 dd e2 ff ff       	call   800410 <cprintf>
  802133:	eb a0                	jmp    8020d5 <_pipeisclosed+0xe>

00802135 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802135:	55                   	push   %ebp
  802136:	89 e5                	mov    %esp,%ebp
  802138:	57                   	push   %edi
  802139:	56                   	push   %esi
  80213a:	53                   	push   %ebx
  80213b:	83 ec 1c             	sub    $0x1c,%esp
  80213e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802141:	89 34 24             	mov    %esi,(%esp)
  802144:	e8 3f f0 ff ff       	call   801188 <fd2data>
  802149:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80214b:	bf 00 00 00 00       	mov    $0x0,%edi
  802150:	eb 3c                	jmp    80218e <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802152:	89 da                	mov    %ebx,%edx
  802154:	89 f0                	mov    %esi,%eax
  802156:	e8 6c ff ff ff       	call   8020c7 <_pipeisclosed>
  80215b:	85 c0                	test   %eax,%eax
  80215d:	75 38                	jne    802197 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80215f:	e8 0a ed ff ff       	call   800e6e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802164:	8b 43 04             	mov    0x4(%ebx),%eax
  802167:	8b 13                	mov    (%ebx),%edx
  802169:	83 c2 20             	add    $0x20,%edx
  80216c:	39 d0                	cmp    %edx,%eax
  80216e:	73 e2                	jae    802152 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802170:	8b 55 0c             	mov    0xc(%ebp),%edx
  802173:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  802176:	89 c2                	mov    %eax,%edx
  802178:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  80217e:	79 05                	jns    802185 <devpipe_write+0x50>
  802180:	4a                   	dec    %edx
  802181:	83 ca e0             	or     $0xffffffe0,%edx
  802184:	42                   	inc    %edx
  802185:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802189:	40                   	inc    %eax
  80218a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80218d:	47                   	inc    %edi
  80218e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802191:	75 d1                	jne    802164 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802193:	89 f8                	mov    %edi,%eax
  802195:	eb 05                	jmp    80219c <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802197:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80219c:	83 c4 1c             	add    $0x1c,%esp
  80219f:	5b                   	pop    %ebx
  8021a0:	5e                   	pop    %esi
  8021a1:	5f                   	pop    %edi
  8021a2:	5d                   	pop    %ebp
  8021a3:	c3                   	ret    

008021a4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8021a4:	55                   	push   %ebp
  8021a5:	89 e5                	mov    %esp,%ebp
  8021a7:	57                   	push   %edi
  8021a8:	56                   	push   %esi
  8021a9:	53                   	push   %ebx
  8021aa:	83 ec 1c             	sub    $0x1c,%esp
  8021ad:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8021b0:	89 3c 24             	mov    %edi,(%esp)
  8021b3:	e8 d0 ef ff ff       	call   801188 <fd2data>
  8021b8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021ba:	be 00 00 00 00       	mov    $0x0,%esi
  8021bf:	eb 3a                	jmp    8021fb <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8021c1:	85 f6                	test   %esi,%esi
  8021c3:	74 04                	je     8021c9 <devpipe_read+0x25>
				return i;
  8021c5:	89 f0                	mov    %esi,%eax
  8021c7:	eb 40                	jmp    802209 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8021c9:	89 da                	mov    %ebx,%edx
  8021cb:	89 f8                	mov    %edi,%eax
  8021cd:	e8 f5 fe ff ff       	call   8020c7 <_pipeisclosed>
  8021d2:	85 c0                	test   %eax,%eax
  8021d4:	75 2e                	jne    802204 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8021d6:	e8 93 ec ff ff       	call   800e6e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8021db:	8b 03                	mov    (%ebx),%eax
  8021dd:	3b 43 04             	cmp    0x4(%ebx),%eax
  8021e0:	74 df                	je     8021c1 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8021e2:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8021e7:	79 05                	jns    8021ee <devpipe_read+0x4a>
  8021e9:	48                   	dec    %eax
  8021ea:	83 c8 e0             	or     $0xffffffe0,%eax
  8021ed:	40                   	inc    %eax
  8021ee:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8021f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021f5:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8021f8:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021fa:	46                   	inc    %esi
  8021fb:	3b 75 10             	cmp    0x10(%ebp),%esi
  8021fe:	75 db                	jne    8021db <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802200:	89 f0                	mov    %esi,%eax
  802202:	eb 05                	jmp    802209 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802204:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802209:	83 c4 1c             	add    $0x1c,%esp
  80220c:	5b                   	pop    %ebx
  80220d:	5e                   	pop    %esi
  80220e:	5f                   	pop    %edi
  80220f:	5d                   	pop    %ebp
  802210:	c3                   	ret    

00802211 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802211:	55                   	push   %ebp
  802212:	89 e5                	mov    %esp,%ebp
  802214:	57                   	push   %edi
  802215:	56                   	push   %esi
  802216:	53                   	push   %ebx
  802217:	83 ec 3c             	sub    $0x3c,%esp
  80221a:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80221d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802220:	89 04 24             	mov    %eax,(%esp)
  802223:	e8 7b ef ff ff       	call   8011a3 <fd_alloc>
  802228:	89 c3                	mov    %eax,%ebx
  80222a:	85 c0                	test   %eax,%eax
  80222c:	0f 88 45 01 00 00    	js     802377 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802232:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802239:	00 
  80223a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80223d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802241:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802248:	e8 40 ec ff ff       	call   800e8d <sys_page_alloc>
  80224d:	89 c3                	mov    %eax,%ebx
  80224f:	85 c0                	test   %eax,%eax
  802251:	0f 88 20 01 00 00    	js     802377 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802257:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80225a:	89 04 24             	mov    %eax,(%esp)
  80225d:	e8 41 ef ff ff       	call   8011a3 <fd_alloc>
  802262:	89 c3                	mov    %eax,%ebx
  802264:	85 c0                	test   %eax,%eax
  802266:	0f 88 f8 00 00 00    	js     802364 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80226c:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802273:	00 
  802274:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802277:	89 44 24 04          	mov    %eax,0x4(%esp)
  80227b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802282:	e8 06 ec ff ff       	call   800e8d <sys_page_alloc>
  802287:	89 c3                	mov    %eax,%ebx
  802289:	85 c0                	test   %eax,%eax
  80228b:	0f 88 d3 00 00 00    	js     802364 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802291:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802294:	89 04 24             	mov    %eax,(%esp)
  802297:	e8 ec ee ff ff       	call   801188 <fd2data>
  80229c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80229e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8022a5:	00 
  8022a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022b1:	e8 d7 eb ff ff       	call   800e8d <sys_page_alloc>
  8022b6:	89 c3                	mov    %eax,%ebx
  8022b8:	85 c0                	test   %eax,%eax
  8022ba:	0f 88 91 00 00 00    	js     802351 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8022c3:	89 04 24             	mov    %eax,(%esp)
  8022c6:	e8 bd ee ff ff       	call   801188 <fd2data>
  8022cb:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8022d2:	00 
  8022d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022d7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8022de:	00 
  8022df:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022ea:	e8 f2 eb ff ff       	call   800ee1 <sys_page_map>
  8022ef:	89 c3                	mov    %eax,%ebx
  8022f1:	85 c0                	test   %eax,%eax
  8022f3:	78 4c                	js     802341 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8022f5:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8022fe:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802300:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802303:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80230a:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802310:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802313:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802315:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802318:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80231f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802322:	89 04 24             	mov    %eax,(%esp)
  802325:	e8 4e ee ff ff       	call   801178 <fd2num>
  80232a:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  80232c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80232f:	89 04 24             	mov    %eax,(%esp)
  802332:	e8 41 ee ff ff       	call   801178 <fd2num>
  802337:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  80233a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80233f:	eb 36                	jmp    802377 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  802341:	89 74 24 04          	mov    %esi,0x4(%esp)
  802345:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80234c:	e8 e3 eb ff ff       	call   800f34 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802351:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802354:	89 44 24 04          	mov    %eax,0x4(%esp)
  802358:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80235f:	e8 d0 eb ff ff       	call   800f34 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802364:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802367:	89 44 24 04          	mov    %eax,0x4(%esp)
  80236b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802372:	e8 bd eb ff ff       	call   800f34 <sys_page_unmap>
    err:
	return r;
}
  802377:	89 d8                	mov    %ebx,%eax
  802379:	83 c4 3c             	add    $0x3c,%esp
  80237c:	5b                   	pop    %ebx
  80237d:	5e                   	pop    %esi
  80237e:	5f                   	pop    %edi
  80237f:	5d                   	pop    %ebp
  802380:	c3                   	ret    

00802381 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802381:	55                   	push   %ebp
  802382:	89 e5                	mov    %esp,%ebp
  802384:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802387:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80238a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80238e:	8b 45 08             	mov    0x8(%ebp),%eax
  802391:	89 04 24             	mov    %eax,(%esp)
  802394:	e8 5d ee ff ff       	call   8011f6 <fd_lookup>
  802399:	85 c0                	test   %eax,%eax
  80239b:	78 15                	js     8023b2 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80239d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023a0:	89 04 24             	mov    %eax,(%esp)
  8023a3:	e8 e0 ed ff ff       	call   801188 <fd2data>
	return _pipeisclosed(fd, p);
  8023a8:	89 c2                	mov    %eax,%edx
  8023aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023ad:	e8 15 fd ff ff       	call   8020c7 <_pipeisclosed>
}
  8023b2:	c9                   	leave  
  8023b3:	c3                   	ret    

008023b4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8023b4:	55                   	push   %ebp
  8023b5:	89 e5                	mov    %esp,%ebp
  8023b7:	56                   	push   %esi
  8023b8:	53                   	push   %ebx
  8023b9:	83 ec 10             	sub    $0x10,%esp
  8023bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8023bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023c2:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int r;
		
	r = sys_ipc_recv(pg?pg:(void*)UTOP);
  8023c5:	85 c0                	test   %eax,%eax
  8023c7:	75 05                	jne    8023ce <ipc_recv+0x1a>
  8023c9:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8023ce:	89 04 24             	mov    %eax,(%esp)
  8023d1:	e8 cd ec ff ff       	call   8010a3 <sys_ipc_recv>
	if (from_env_store != NULL)
  8023d6:	85 db                	test   %ebx,%ebx
  8023d8:	74 0b                	je     8023e5 <ipc_recv+0x31>
		*from_env_store = thisenv->env_ipc_from; 
  8023da:	8b 15 08 44 80 00    	mov    0x804408,%edx
  8023e0:	8b 52 74             	mov    0x74(%edx),%edx
  8023e3:	89 13                	mov    %edx,(%ebx)
	if (perm_store != NULL)
  8023e5:	85 f6                	test   %esi,%esi
  8023e7:	74 0b                	je     8023f4 <ipc_recv+0x40>
		*perm_store = thisenv->env_ipc_perm;
  8023e9:	8b 15 08 44 80 00    	mov    0x804408,%edx
  8023ef:	8b 52 78             	mov    0x78(%edx),%edx
  8023f2:	89 16                	mov    %edx,(%esi)
	
	if (r < 0){
  8023f4:	85 c0                	test   %eax,%eax
  8023f6:	79 16                	jns    80240e <ipc_recv+0x5a>
		if(from_env_store != NULL)
  8023f8:	85 db                	test   %ebx,%ebx
  8023fa:	74 06                	je     802402 <ipc_recv+0x4e>
			*from_env_store = 0;
  8023fc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store != NULL)	
  802402:	85 f6                	test   %esi,%esi
  802404:	74 10                	je     802416 <ipc_recv+0x62>
			*perm_store = 0;
  802406:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80240c:	eb 08                	jmp    802416 <ipc_recv+0x62>
		return r;
	}
	
	return thisenv->env_ipc_value;
  80240e:	a1 08 44 80 00       	mov    0x804408,%eax
  802413:	8b 40 70             	mov    0x70(%eax),%eax
}
  802416:	83 c4 10             	add    $0x10,%esp
  802419:	5b                   	pop    %ebx
  80241a:	5e                   	pop    %esi
  80241b:	5d                   	pop    %ebp
  80241c:	c3                   	ret    

0080241d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80241d:	55                   	push   %ebp
  80241e:	89 e5                	mov    %esp,%ebp
  802420:	57                   	push   %edi
  802421:	56                   	push   %esi
  802422:	53                   	push   %ebx
  802423:	83 ec 1c             	sub    $0x1c,%esp
  802426:	8b 75 08             	mov    0x8(%ebp),%esi
  802429:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80242c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  80242f:	eb 2a                	jmp    80245b <ipc_send+0x3e>
		if (r != -E_IPC_NOT_RECV)
  802431:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802434:	74 20                	je     802456 <ipc_send+0x39>
			panic("ipc_send: sys_ipc_try_send failed %e", r);
  802436:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80243a:	c7 44 24 08 60 2c 80 	movl   $0x802c60,0x8(%esp)
  802441:	00 
  802442:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  802449:	00 
  80244a:	c7 04 24 88 2c 80 00 	movl   $0x802c88,(%esp)
  802451:	e8 c2 de ff ff       	call   800318 <_panic>
		sys_yield();
  802456:	e8 13 ea ff ff       	call   800e6e <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  80245b:	85 db                	test   %ebx,%ebx
  80245d:	75 07                	jne    802466 <ipc_send+0x49>
  80245f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802464:	eb 02                	jmp    802468 <ipc_send+0x4b>
  802466:	89 d8                	mov    %ebx,%eax
  802468:	8b 55 14             	mov    0x14(%ebp),%edx
  80246b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80246f:	89 44 24 08          	mov    %eax,0x8(%esp)
  802473:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802477:	89 34 24             	mov    %esi,(%esp)
  80247a:	e8 01 ec ff ff       	call   801080 <sys_ipc_try_send>
  80247f:	85 c0                	test   %eax,%eax
  802481:	78 ae                	js     802431 <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: sys_ipc_try_send failed %e", r);
		sys_yield();
	}
}
  802483:	83 c4 1c             	add    $0x1c,%esp
  802486:	5b                   	pop    %ebx
  802487:	5e                   	pop    %esi
  802488:	5f                   	pop    %edi
  802489:	5d                   	pop    %ebp
  80248a:	c3                   	ret    

0080248b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80248b:	55                   	push   %ebp
  80248c:	89 e5                	mov    %esp,%ebp
  80248e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802491:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802496:	89 c2                	mov    %eax,%edx
  802498:	c1 e2 07             	shl    $0x7,%edx
  80249b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8024a1:	8b 52 50             	mov    0x50(%edx),%edx
  8024a4:	39 ca                	cmp    %ecx,%edx
  8024a6:	75 0d                	jne    8024b5 <ipc_find_env+0x2a>
			return envs[i].env_id;
  8024a8:	c1 e0 07             	shl    $0x7,%eax
  8024ab:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8024b0:	8b 40 40             	mov    0x40(%eax),%eax
  8024b3:	eb 0c                	jmp    8024c1 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8024b5:	40                   	inc    %eax
  8024b6:	3d 00 04 00 00       	cmp    $0x400,%eax
  8024bb:	75 d9                	jne    802496 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8024bd:	66 b8 00 00          	mov    $0x0,%ax
}
  8024c1:	5d                   	pop    %ebp
  8024c2:	c3                   	ret    
	...

008024c4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8024c4:	55                   	push   %ebp
  8024c5:	89 e5                	mov    %esp,%ebp
  8024c7:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8024ca:	89 c2                	mov    %eax,%edx
  8024cc:	c1 ea 16             	shr    $0x16,%edx
  8024cf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8024d6:	f6 c2 01             	test   $0x1,%dl
  8024d9:	74 1e                	je     8024f9 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8024db:	c1 e8 0c             	shr    $0xc,%eax
  8024de:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8024e5:	a8 01                	test   $0x1,%al
  8024e7:	74 17                	je     802500 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8024e9:	c1 e8 0c             	shr    $0xc,%eax
  8024ec:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8024f3:	ef 
  8024f4:	0f b7 c0             	movzwl %ax,%eax
  8024f7:	eb 0c                	jmp    802505 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8024f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8024fe:	eb 05                	jmp    802505 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802500:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802505:	5d                   	pop    %ebp
  802506:	c3                   	ret    
	...

00802508 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802508:	55                   	push   %ebp
  802509:	57                   	push   %edi
  80250a:	56                   	push   %esi
  80250b:	83 ec 10             	sub    $0x10,%esp
  80250e:	8b 74 24 20          	mov    0x20(%esp),%esi
  802512:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802516:	89 74 24 04          	mov    %esi,0x4(%esp)
  80251a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  80251e:	89 cd                	mov    %ecx,%ebp
  802520:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802524:	85 c0                	test   %eax,%eax
  802526:	75 2c                	jne    802554 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802528:	39 f9                	cmp    %edi,%ecx
  80252a:	77 68                	ja     802594 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80252c:	85 c9                	test   %ecx,%ecx
  80252e:	75 0b                	jne    80253b <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802530:	b8 01 00 00 00       	mov    $0x1,%eax
  802535:	31 d2                	xor    %edx,%edx
  802537:	f7 f1                	div    %ecx
  802539:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80253b:	31 d2                	xor    %edx,%edx
  80253d:	89 f8                	mov    %edi,%eax
  80253f:	f7 f1                	div    %ecx
  802541:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802543:	89 f0                	mov    %esi,%eax
  802545:	f7 f1                	div    %ecx
  802547:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802549:	89 f0                	mov    %esi,%eax
  80254b:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80254d:	83 c4 10             	add    $0x10,%esp
  802550:	5e                   	pop    %esi
  802551:	5f                   	pop    %edi
  802552:	5d                   	pop    %ebp
  802553:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802554:	39 f8                	cmp    %edi,%eax
  802556:	77 2c                	ja     802584 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802558:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  80255b:	83 f6 1f             	xor    $0x1f,%esi
  80255e:	75 4c                	jne    8025ac <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802560:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802562:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802567:	72 0a                	jb     802573 <__udivdi3+0x6b>
  802569:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  80256d:	0f 87 ad 00 00 00    	ja     802620 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802573:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802578:	89 f0                	mov    %esi,%eax
  80257a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80257c:	83 c4 10             	add    $0x10,%esp
  80257f:	5e                   	pop    %esi
  802580:	5f                   	pop    %edi
  802581:	5d                   	pop    %ebp
  802582:	c3                   	ret    
  802583:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802584:	31 ff                	xor    %edi,%edi
  802586:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802588:	89 f0                	mov    %esi,%eax
  80258a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80258c:	83 c4 10             	add    $0x10,%esp
  80258f:	5e                   	pop    %esi
  802590:	5f                   	pop    %edi
  802591:	5d                   	pop    %ebp
  802592:	c3                   	ret    
  802593:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802594:	89 fa                	mov    %edi,%edx
  802596:	89 f0                	mov    %esi,%eax
  802598:	f7 f1                	div    %ecx
  80259a:	89 c6                	mov    %eax,%esi
  80259c:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80259e:	89 f0                	mov    %esi,%eax
  8025a0:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8025a2:	83 c4 10             	add    $0x10,%esp
  8025a5:	5e                   	pop    %esi
  8025a6:	5f                   	pop    %edi
  8025a7:	5d                   	pop    %ebp
  8025a8:	c3                   	ret    
  8025a9:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8025ac:	89 f1                	mov    %esi,%ecx
  8025ae:	d3 e0                	shl    %cl,%eax
  8025b0:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8025b4:	b8 20 00 00 00       	mov    $0x20,%eax
  8025b9:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8025bb:	89 ea                	mov    %ebp,%edx
  8025bd:	88 c1                	mov    %al,%cl
  8025bf:	d3 ea                	shr    %cl,%edx
  8025c1:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8025c5:	09 ca                	or     %ecx,%edx
  8025c7:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  8025cb:	89 f1                	mov    %esi,%ecx
  8025cd:	d3 e5                	shl    %cl,%ebp
  8025cf:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  8025d3:	89 fd                	mov    %edi,%ebp
  8025d5:	88 c1                	mov    %al,%cl
  8025d7:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  8025d9:	89 fa                	mov    %edi,%edx
  8025db:	89 f1                	mov    %esi,%ecx
  8025dd:	d3 e2                	shl    %cl,%edx
  8025df:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8025e3:	88 c1                	mov    %al,%cl
  8025e5:	d3 ef                	shr    %cl,%edi
  8025e7:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8025e9:	89 f8                	mov    %edi,%eax
  8025eb:	89 ea                	mov    %ebp,%edx
  8025ed:	f7 74 24 08          	divl   0x8(%esp)
  8025f1:	89 d1                	mov    %edx,%ecx
  8025f3:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  8025f5:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8025f9:	39 d1                	cmp    %edx,%ecx
  8025fb:	72 17                	jb     802614 <__udivdi3+0x10c>
  8025fd:	74 09                	je     802608 <__udivdi3+0x100>
  8025ff:	89 fe                	mov    %edi,%esi
  802601:	31 ff                	xor    %edi,%edi
  802603:	e9 41 ff ff ff       	jmp    802549 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802608:	8b 54 24 04          	mov    0x4(%esp),%edx
  80260c:	89 f1                	mov    %esi,%ecx
  80260e:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802610:	39 c2                	cmp    %eax,%edx
  802612:	73 eb                	jae    8025ff <__udivdi3+0xf7>
		{
		  q0--;
  802614:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802617:	31 ff                	xor    %edi,%edi
  802619:	e9 2b ff ff ff       	jmp    802549 <__udivdi3+0x41>
  80261e:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802620:	31 f6                	xor    %esi,%esi
  802622:	e9 22 ff ff ff       	jmp    802549 <__udivdi3+0x41>
	...

00802628 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802628:	55                   	push   %ebp
  802629:	57                   	push   %edi
  80262a:	56                   	push   %esi
  80262b:	83 ec 20             	sub    $0x20,%esp
  80262e:	8b 44 24 30          	mov    0x30(%esp),%eax
  802632:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802636:	89 44 24 14          	mov    %eax,0x14(%esp)
  80263a:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  80263e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802642:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802646:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802648:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80264a:	85 ed                	test   %ebp,%ebp
  80264c:	75 16                	jne    802664 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  80264e:	39 f1                	cmp    %esi,%ecx
  802650:	0f 86 a6 00 00 00    	jbe    8026fc <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802656:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802658:	89 d0                	mov    %edx,%eax
  80265a:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80265c:	83 c4 20             	add    $0x20,%esp
  80265f:	5e                   	pop    %esi
  802660:	5f                   	pop    %edi
  802661:	5d                   	pop    %ebp
  802662:	c3                   	ret    
  802663:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802664:	39 f5                	cmp    %esi,%ebp
  802666:	0f 87 ac 00 00 00    	ja     802718 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80266c:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  80266f:	83 f0 1f             	xor    $0x1f,%eax
  802672:	89 44 24 10          	mov    %eax,0x10(%esp)
  802676:	0f 84 a8 00 00 00    	je     802724 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80267c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802680:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802682:	bf 20 00 00 00       	mov    $0x20,%edi
  802687:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80268b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80268f:	89 f9                	mov    %edi,%ecx
  802691:	d3 e8                	shr    %cl,%eax
  802693:	09 e8                	or     %ebp,%eax
  802695:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  802699:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80269d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8026a1:	d3 e0                	shl    %cl,%eax
  8026a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8026a7:	89 f2                	mov    %esi,%edx
  8026a9:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8026ab:	8b 44 24 14          	mov    0x14(%esp),%eax
  8026af:	d3 e0                	shl    %cl,%eax
  8026b1:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8026b5:	8b 44 24 14          	mov    0x14(%esp),%eax
  8026b9:	89 f9                	mov    %edi,%ecx
  8026bb:	d3 e8                	shr    %cl,%eax
  8026bd:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8026bf:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8026c1:	89 f2                	mov    %esi,%edx
  8026c3:	f7 74 24 18          	divl   0x18(%esp)
  8026c7:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8026c9:	f7 64 24 0c          	mull   0xc(%esp)
  8026cd:	89 c5                	mov    %eax,%ebp
  8026cf:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8026d1:	39 d6                	cmp    %edx,%esi
  8026d3:	72 67                	jb     80273c <__umoddi3+0x114>
  8026d5:	74 75                	je     80274c <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8026d7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8026db:	29 e8                	sub    %ebp,%eax
  8026dd:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8026df:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8026e3:	d3 e8                	shr    %cl,%eax
  8026e5:	89 f2                	mov    %esi,%edx
  8026e7:	89 f9                	mov    %edi,%ecx
  8026e9:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8026eb:	09 d0                	or     %edx,%eax
  8026ed:	89 f2                	mov    %esi,%edx
  8026ef:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8026f3:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8026f5:	83 c4 20             	add    $0x20,%esp
  8026f8:	5e                   	pop    %esi
  8026f9:	5f                   	pop    %edi
  8026fa:	5d                   	pop    %ebp
  8026fb:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8026fc:	85 c9                	test   %ecx,%ecx
  8026fe:	75 0b                	jne    80270b <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802700:	b8 01 00 00 00       	mov    $0x1,%eax
  802705:	31 d2                	xor    %edx,%edx
  802707:	f7 f1                	div    %ecx
  802709:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80270b:	89 f0                	mov    %esi,%eax
  80270d:	31 d2                	xor    %edx,%edx
  80270f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802711:	89 f8                	mov    %edi,%eax
  802713:	e9 3e ff ff ff       	jmp    802656 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802718:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80271a:	83 c4 20             	add    $0x20,%esp
  80271d:	5e                   	pop    %esi
  80271e:	5f                   	pop    %edi
  80271f:	5d                   	pop    %ebp
  802720:	c3                   	ret    
  802721:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802724:	39 f5                	cmp    %esi,%ebp
  802726:	72 04                	jb     80272c <__umoddi3+0x104>
  802728:	39 f9                	cmp    %edi,%ecx
  80272a:	77 06                	ja     802732 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80272c:	89 f2                	mov    %esi,%edx
  80272e:	29 cf                	sub    %ecx,%edi
  802730:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802732:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802734:	83 c4 20             	add    $0x20,%esp
  802737:	5e                   	pop    %esi
  802738:	5f                   	pop    %edi
  802739:	5d                   	pop    %ebp
  80273a:	c3                   	ret    
  80273b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80273c:	89 d1                	mov    %edx,%ecx
  80273e:	89 c5                	mov    %eax,%ebp
  802740:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802744:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802748:	eb 8d                	jmp    8026d7 <__umoddi3+0xaf>
  80274a:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80274c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802750:	72 ea                	jb     80273c <__umoddi3+0x114>
  802752:	89 f1                	mov    %esi,%ecx
  802754:	eb 81                	jmp    8026d7 <__umoddi3+0xaf>
