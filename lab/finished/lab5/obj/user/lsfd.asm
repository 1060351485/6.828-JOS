
obj/user/lsfd.debug:     file format elf32-i386


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
  80002c:	e8 03 01 00 00       	call   800134 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <usage>:
#include <inc/lib.h>

void
usage(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	cprintf("usage: lsfd [-1]\n");
  80003a:	c7 04 24 a0 22 80 00 	movl   $0x8022a0,(%esp)
  800041:	e8 f6 01 00 00       	call   80023c <cprintf>
	exit();
  800046:	e8 3d 01 00 00       	call   800188 <exit>
}
  80004b:	c9                   	leave  
  80004c:	c3                   	ret    

0080004d <umain>:

void
umain(int argc, char **argv)
{
  80004d:	55                   	push   %ebp
  80004e:	89 e5                	mov    %esp,%ebp
  800050:	57                   	push   %edi
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	81 ec cc 00 00 00    	sub    $0xcc,%esp
	int i, usefprint = 0;
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
  800059:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80005f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800063:	8b 45 0c             	mov    0xc(%ebp),%eax
  800066:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006a:	8d 45 08             	lea    0x8(%ebp),%eax
  80006d:	89 04 24             	mov    %eax,(%esp)
  800070:	e8 cf 0d 00 00       	call   800e44 <argstart>
}

void
umain(int argc, char **argv)
{
	int i, usefprint = 0;
  800075:	bf 00 00 00 00       	mov    $0x0,%edi
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  80007a:	8d 9d 4c ff ff ff    	lea    -0xb4(%ebp),%ebx
  800080:	eb 11                	jmp    800093 <umain+0x46>
		if (i == '1')
  800082:	83 f8 31             	cmp    $0x31,%eax
  800085:	74 07                	je     80008e <umain+0x41>
			usefprint = 1;
		else
			usage();
  800087:	e8 a8 ff ff ff       	call   800034 <usage>
  80008c:	eb 05                	jmp    800093 <umain+0x46>
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
		if (i == '1')
			usefprint = 1;
  80008e:	bf 01 00 00 00       	mov    $0x1,%edi
	int i, usefprint = 0;
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  800093:	89 1c 24             	mov    %ebx,(%esp)
  800096:	e8 e2 0d 00 00       	call   800e7d <argnext>
  80009b:	85 c0                	test   %eax,%eax
  80009d:	79 e3                	jns    800082 <umain+0x35>
  80009f:	bb 00 00 00 00       	mov    $0x0,%ebx
			usefprint = 1;
		else
			usage();

	for (i = 0; i < 32; i++)
		if (fstat(i, &st) >= 0) {
  8000a4:	8d b5 5c ff ff ff    	lea    -0xa4(%ebp),%esi
  8000aa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000ae:	89 1c 24             	mov    %ebx,(%esp)
  8000b1:	e8 16 14 00 00       	call   8014cc <fstat>
  8000b6:	85 c0                	test   %eax,%eax
  8000b8:	78 66                	js     800120 <umain+0xd3>
			if (usefprint)
  8000ba:	85 ff                	test   %edi,%edi
  8000bc:	74 36                	je     8000f4 <umain+0xa7>
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
  8000be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
			usage();

	for (i = 0; i < 32; i++)
		if (fstat(i, &st) >= 0) {
			if (usefprint)
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
  8000c1:	8b 40 04             	mov    0x4(%eax),%eax
  8000c4:	89 44 24 18          	mov    %eax,0x18(%esp)
  8000c8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8000cb:	89 44 24 14          	mov    %eax,0x14(%esp)
  8000cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8000d2:	89 44 24 10          	mov    %eax,0x10(%esp)
					i, st.st_name, st.st_isdir,
  8000d6:	89 74 24 0c          	mov    %esi,0xc(%esp)
			usage();

	for (i = 0; i < 32; i++)
		if (fstat(i, &st) >= 0) {
			if (usefprint)
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
  8000da:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000de:	c7 44 24 04 b4 22 80 	movl   $0x8022b4,0x4(%esp)
  8000e5:	00 
  8000e6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8000ed:	e8 2e 18 00 00       	call   801920 <fprintf>
  8000f2:	eb 2c                	jmp    800120 <umain+0xd3>
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
  8000f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
			if (usefprint)
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
  8000f7:	8b 40 04             	mov    0x4(%eax),%eax
  8000fa:	89 44 24 14          	mov    %eax,0x14(%esp)
  8000fe:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800101:	89 44 24 10          	mov    %eax,0x10(%esp)
  800105:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800108:	89 44 24 0c          	mov    %eax,0xc(%esp)
					i, st.st_name, st.st_isdir,
  80010c:	89 74 24 08          	mov    %esi,0x8(%esp)
			if (usefprint)
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
  800110:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800114:	c7 04 24 b4 22 80 00 	movl   $0x8022b4,(%esp)
  80011b:	e8 1c 01 00 00       	call   80023c <cprintf>
		if (i == '1')
			usefprint = 1;
		else
			usage();

	for (i = 0; i < 32; i++)
  800120:	43                   	inc    %ebx
  800121:	83 fb 20             	cmp    $0x20,%ebx
  800124:	75 84                	jne    8000aa <umain+0x5d>
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
		}
}
  800126:	81 c4 cc 00 00 00    	add    $0xcc,%esp
  80012c:	5b                   	pop    %ebx
  80012d:	5e                   	pop    %esi
  80012e:	5f                   	pop    %edi
  80012f:	5d                   	pop    %ebp
  800130:	c3                   	ret    
  800131:	00 00                	add    %al,(%eax)
	...

00800134 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	56                   	push   %esi
  800138:	53                   	push   %ebx
  800139:	83 ec 10             	sub    $0x10,%esp
  80013c:	8b 75 08             	mov    0x8(%ebp),%esi
  80013f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800142:	e8 54 0a 00 00       	call   800b9b <sys_getenvid>
  800147:	25 ff 03 00 00       	and    $0x3ff,%eax
  80014c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800153:	c1 e0 07             	shl    $0x7,%eax
  800156:	29 d0                	sub    %edx,%eax
  800158:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80015d:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800162:	85 f6                	test   %esi,%esi
  800164:	7e 07                	jle    80016d <libmain+0x39>
		binaryname = argv[0];
  800166:	8b 03                	mov    (%ebx),%eax
  800168:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80016d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800171:	89 34 24             	mov    %esi,(%esp)
  800174:	e8 d4 fe ff ff       	call   80004d <umain>

	// exit gracefully
	exit();
  800179:	e8 0a 00 00 00       	call   800188 <exit>
}
  80017e:	83 c4 10             	add    $0x10,%esp
  800181:	5b                   	pop    %ebx
  800182:	5e                   	pop    %esi
  800183:	5d                   	pop    %ebp
  800184:	c3                   	ret    
  800185:	00 00                	add    %al,(%eax)
	...

00800188 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800188:	55                   	push   %ebp
  800189:	89 e5                	mov    %esp,%ebp
  80018b:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  80018e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800195:	e8 af 09 00 00       	call   800b49 <sys_env_destroy>
}
  80019a:	c9                   	leave  
  80019b:	c3                   	ret    

0080019c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80019c:	55                   	push   %ebp
  80019d:	89 e5                	mov    %esp,%ebp
  80019f:	53                   	push   %ebx
  8001a0:	83 ec 14             	sub    $0x14,%esp
  8001a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a6:	8b 03                	mov    (%ebx),%eax
  8001a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ab:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001af:	40                   	inc    %eax
  8001b0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001b2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001b7:	75 19                	jne    8001d2 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001b9:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001c0:	00 
  8001c1:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c4:	89 04 24             	mov    %eax,(%esp)
  8001c7:	e8 40 09 00 00       	call   800b0c <sys_cputs>
		b->idx = 0;
  8001cc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001d2:	ff 43 04             	incl   0x4(%ebx)
}
  8001d5:	83 c4 14             	add    $0x14,%esp
  8001d8:	5b                   	pop    %ebx
  8001d9:	5d                   	pop    %ebp
  8001da:	c3                   	ret    

008001db <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001e4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001eb:	00 00 00 
	b.cnt = 0;
  8001ee:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001f5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800202:	89 44 24 08          	mov    %eax,0x8(%esp)
  800206:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80020c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800210:	c7 04 24 9c 01 80 00 	movl   $0x80019c,(%esp)
  800217:	e8 82 01 00 00       	call   80039e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80021c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800222:	89 44 24 04          	mov    %eax,0x4(%esp)
  800226:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80022c:	89 04 24             	mov    %eax,(%esp)
  80022f:	e8 d8 08 00 00       	call   800b0c <sys_cputs>

	return b.cnt;
}
  800234:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80023a:	c9                   	leave  
  80023b:	c3                   	ret    

0080023c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80023c:	55                   	push   %ebp
  80023d:	89 e5                	mov    %esp,%ebp
  80023f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800242:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800245:	89 44 24 04          	mov    %eax,0x4(%esp)
  800249:	8b 45 08             	mov    0x8(%ebp),%eax
  80024c:	89 04 24             	mov    %eax,(%esp)
  80024f:	e8 87 ff ff ff       	call   8001db <vcprintf>
	va_end(ap);

	return cnt;
}
  800254:	c9                   	leave  
  800255:	c3                   	ret    
	...

00800258 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800258:	55                   	push   %ebp
  800259:	89 e5                	mov    %esp,%ebp
  80025b:	57                   	push   %edi
  80025c:	56                   	push   %esi
  80025d:	53                   	push   %ebx
  80025e:	83 ec 3c             	sub    $0x3c,%esp
  800261:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800264:	89 d7                	mov    %edx,%edi
  800266:	8b 45 08             	mov    0x8(%ebp),%eax
  800269:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80026c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80026f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800272:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800275:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800278:	85 c0                	test   %eax,%eax
  80027a:	75 08                	jne    800284 <printnum+0x2c>
  80027c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80027f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800282:	77 57                	ja     8002db <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800284:	89 74 24 10          	mov    %esi,0x10(%esp)
  800288:	4b                   	dec    %ebx
  800289:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80028d:	8b 45 10             	mov    0x10(%ebp),%eax
  800290:	89 44 24 08          	mov    %eax,0x8(%esp)
  800294:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800298:	8b 74 24 0c          	mov    0xc(%esp),%esi
  80029c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002a3:	00 
  8002a4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002a7:	89 04 24             	mov    %eax,(%esp)
  8002aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b1:	e8 7e 1d 00 00       	call   802034 <__udivdi3>
  8002b6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002ba:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002be:	89 04 24             	mov    %eax,(%esp)
  8002c1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002c5:	89 fa                	mov    %edi,%edx
  8002c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002ca:	e8 89 ff ff ff       	call   800258 <printnum>
  8002cf:	eb 0f                	jmp    8002e0 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002d1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002d5:	89 34 24             	mov    %esi,(%esp)
  8002d8:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002db:	4b                   	dec    %ebx
  8002dc:	85 db                	test   %ebx,%ebx
  8002de:	7f f1                	jg     8002d1 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002e0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002e4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002e8:	8b 45 10             	mov    0x10(%ebp),%eax
  8002eb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ef:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002f6:	00 
  8002f7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002fa:	89 04 24             	mov    %eax,(%esp)
  8002fd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800300:	89 44 24 04          	mov    %eax,0x4(%esp)
  800304:	e8 4b 1e 00 00       	call   802154 <__umoddi3>
  800309:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80030d:	0f be 80 e6 22 80 00 	movsbl 0x8022e6(%eax),%eax
  800314:	89 04 24             	mov    %eax,(%esp)
  800317:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80031a:	83 c4 3c             	add    $0x3c,%esp
  80031d:	5b                   	pop    %ebx
  80031e:	5e                   	pop    %esi
  80031f:	5f                   	pop    %edi
  800320:	5d                   	pop    %ebp
  800321:	c3                   	ret    

00800322 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800322:	55                   	push   %ebp
  800323:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800325:	83 fa 01             	cmp    $0x1,%edx
  800328:	7e 0e                	jle    800338 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80032a:	8b 10                	mov    (%eax),%edx
  80032c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80032f:	89 08                	mov    %ecx,(%eax)
  800331:	8b 02                	mov    (%edx),%eax
  800333:	8b 52 04             	mov    0x4(%edx),%edx
  800336:	eb 22                	jmp    80035a <getuint+0x38>
	else if (lflag)
  800338:	85 d2                	test   %edx,%edx
  80033a:	74 10                	je     80034c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80033c:	8b 10                	mov    (%eax),%edx
  80033e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800341:	89 08                	mov    %ecx,(%eax)
  800343:	8b 02                	mov    (%edx),%eax
  800345:	ba 00 00 00 00       	mov    $0x0,%edx
  80034a:	eb 0e                	jmp    80035a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80034c:	8b 10                	mov    (%eax),%edx
  80034e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800351:	89 08                	mov    %ecx,(%eax)
  800353:	8b 02                	mov    (%edx),%eax
  800355:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80035a:	5d                   	pop    %ebp
  80035b:	c3                   	ret    

0080035c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80035c:	55                   	push   %ebp
  80035d:	89 e5                	mov    %esp,%ebp
  80035f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800362:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800365:	8b 10                	mov    (%eax),%edx
  800367:	3b 50 04             	cmp    0x4(%eax),%edx
  80036a:	73 08                	jae    800374 <sprintputch+0x18>
		*b->buf++ = ch;
  80036c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80036f:	88 0a                	mov    %cl,(%edx)
  800371:	42                   	inc    %edx
  800372:	89 10                	mov    %edx,(%eax)
}
  800374:	5d                   	pop    %ebp
  800375:	c3                   	ret    

00800376 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800376:	55                   	push   %ebp
  800377:	89 e5                	mov    %esp,%ebp
  800379:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80037c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80037f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800383:	8b 45 10             	mov    0x10(%ebp),%eax
  800386:	89 44 24 08          	mov    %eax,0x8(%esp)
  80038a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80038d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800391:	8b 45 08             	mov    0x8(%ebp),%eax
  800394:	89 04 24             	mov    %eax,(%esp)
  800397:	e8 02 00 00 00       	call   80039e <vprintfmt>
	va_end(ap);
}
  80039c:	c9                   	leave  
  80039d:	c3                   	ret    

0080039e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80039e:	55                   	push   %ebp
  80039f:	89 e5                	mov    %esp,%ebp
  8003a1:	57                   	push   %edi
  8003a2:	56                   	push   %esi
  8003a3:	53                   	push   %ebx
  8003a4:	83 ec 4c             	sub    $0x4c,%esp
  8003a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003aa:	8b 75 10             	mov    0x10(%ebp),%esi
  8003ad:	eb 12                	jmp    8003c1 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003af:	85 c0                	test   %eax,%eax
  8003b1:	0f 84 6b 03 00 00    	je     800722 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8003b7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003bb:	89 04 24             	mov    %eax,(%esp)
  8003be:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003c1:	0f b6 06             	movzbl (%esi),%eax
  8003c4:	46                   	inc    %esi
  8003c5:	83 f8 25             	cmp    $0x25,%eax
  8003c8:	75 e5                	jne    8003af <vprintfmt+0x11>
  8003ca:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003ce:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8003d5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003da:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003e1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003e6:	eb 26                	jmp    80040e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e8:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003eb:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8003ef:	eb 1d                	jmp    80040e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f1:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003f4:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8003f8:	eb 14                	jmp    80040e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fa:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003fd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800404:	eb 08                	jmp    80040e <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800406:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800409:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040e:	0f b6 06             	movzbl (%esi),%eax
  800411:	8d 56 01             	lea    0x1(%esi),%edx
  800414:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800417:	8a 16                	mov    (%esi),%dl
  800419:	83 ea 23             	sub    $0x23,%edx
  80041c:	80 fa 55             	cmp    $0x55,%dl
  80041f:	0f 87 e1 02 00 00    	ja     800706 <vprintfmt+0x368>
  800425:	0f b6 d2             	movzbl %dl,%edx
  800428:	ff 24 95 20 24 80 00 	jmp    *0x802420(,%edx,4)
  80042f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800432:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800437:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80043a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80043e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800441:	8d 50 d0             	lea    -0x30(%eax),%edx
  800444:	83 fa 09             	cmp    $0x9,%edx
  800447:	77 2a                	ja     800473 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800449:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80044a:	eb eb                	jmp    800437 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80044c:	8b 45 14             	mov    0x14(%ebp),%eax
  80044f:	8d 50 04             	lea    0x4(%eax),%edx
  800452:	89 55 14             	mov    %edx,0x14(%ebp)
  800455:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800457:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80045a:	eb 17                	jmp    800473 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  80045c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800460:	78 98                	js     8003fa <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800462:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800465:	eb a7                	jmp    80040e <vprintfmt+0x70>
  800467:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80046a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800471:	eb 9b                	jmp    80040e <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800473:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800477:	79 95                	jns    80040e <vprintfmt+0x70>
  800479:	eb 8b                	jmp    800406 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80047b:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80047f:	eb 8d                	jmp    80040e <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800481:	8b 45 14             	mov    0x14(%ebp),%eax
  800484:	8d 50 04             	lea    0x4(%eax),%edx
  800487:	89 55 14             	mov    %edx,0x14(%ebp)
  80048a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80048e:	8b 00                	mov    (%eax),%eax
  800490:	89 04 24             	mov    %eax,(%esp)
  800493:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800496:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800499:	e9 23 ff ff ff       	jmp    8003c1 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80049e:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a1:	8d 50 04             	lea    0x4(%eax),%edx
  8004a4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a7:	8b 00                	mov    (%eax),%eax
  8004a9:	85 c0                	test   %eax,%eax
  8004ab:	79 02                	jns    8004af <vprintfmt+0x111>
  8004ad:	f7 d8                	neg    %eax
  8004af:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004b1:	83 f8 0f             	cmp    $0xf,%eax
  8004b4:	7f 0b                	jg     8004c1 <vprintfmt+0x123>
  8004b6:	8b 04 85 80 25 80 00 	mov    0x802580(,%eax,4),%eax
  8004bd:	85 c0                	test   %eax,%eax
  8004bf:	75 23                	jne    8004e4 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004c1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004c5:	c7 44 24 08 fe 22 80 	movl   $0x8022fe,0x8(%esp)
  8004cc:	00 
  8004cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8004d4:	89 04 24             	mov    %eax,(%esp)
  8004d7:	e8 9a fe ff ff       	call   800376 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004dc:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004df:	e9 dd fe ff ff       	jmp    8003c1 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8004e4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004e8:	c7 44 24 08 b1 26 80 	movl   $0x8026b1,0x8(%esp)
  8004ef:	00 
  8004f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8004f7:	89 14 24             	mov    %edx,(%esp)
  8004fa:	e8 77 fe ff ff       	call   800376 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ff:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800502:	e9 ba fe ff ff       	jmp    8003c1 <vprintfmt+0x23>
  800507:	89 f9                	mov    %edi,%ecx
  800509:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80050c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80050f:	8b 45 14             	mov    0x14(%ebp),%eax
  800512:	8d 50 04             	lea    0x4(%eax),%edx
  800515:	89 55 14             	mov    %edx,0x14(%ebp)
  800518:	8b 30                	mov    (%eax),%esi
  80051a:	85 f6                	test   %esi,%esi
  80051c:	75 05                	jne    800523 <vprintfmt+0x185>
				p = "(null)";
  80051e:	be f7 22 80 00       	mov    $0x8022f7,%esi
			if (width > 0 && padc != '-')
  800523:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800527:	0f 8e 84 00 00 00    	jle    8005b1 <vprintfmt+0x213>
  80052d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800531:	74 7e                	je     8005b1 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800533:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800537:	89 34 24             	mov    %esi,(%esp)
  80053a:	e8 8b 02 00 00       	call   8007ca <strnlen>
  80053f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800542:	29 c2                	sub    %eax,%edx
  800544:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800547:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80054b:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80054e:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800551:	89 de                	mov    %ebx,%esi
  800553:	89 d3                	mov    %edx,%ebx
  800555:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800557:	eb 0b                	jmp    800564 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800559:	89 74 24 04          	mov    %esi,0x4(%esp)
  80055d:	89 3c 24             	mov    %edi,(%esp)
  800560:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800563:	4b                   	dec    %ebx
  800564:	85 db                	test   %ebx,%ebx
  800566:	7f f1                	jg     800559 <vprintfmt+0x1bb>
  800568:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80056b:	89 f3                	mov    %esi,%ebx
  80056d:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800570:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800573:	85 c0                	test   %eax,%eax
  800575:	79 05                	jns    80057c <vprintfmt+0x1de>
  800577:	b8 00 00 00 00       	mov    $0x0,%eax
  80057c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80057f:	29 c2                	sub    %eax,%edx
  800581:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800584:	eb 2b                	jmp    8005b1 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800586:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80058a:	74 18                	je     8005a4 <vprintfmt+0x206>
  80058c:	8d 50 e0             	lea    -0x20(%eax),%edx
  80058f:	83 fa 5e             	cmp    $0x5e,%edx
  800592:	76 10                	jbe    8005a4 <vprintfmt+0x206>
					putch('?', putdat);
  800594:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800598:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80059f:	ff 55 08             	call   *0x8(%ebp)
  8005a2:	eb 0a                	jmp    8005ae <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8005a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a8:	89 04 24             	mov    %eax,(%esp)
  8005ab:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ae:	ff 4d e4             	decl   -0x1c(%ebp)
  8005b1:	0f be 06             	movsbl (%esi),%eax
  8005b4:	46                   	inc    %esi
  8005b5:	85 c0                	test   %eax,%eax
  8005b7:	74 21                	je     8005da <vprintfmt+0x23c>
  8005b9:	85 ff                	test   %edi,%edi
  8005bb:	78 c9                	js     800586 <vprintfmt+0x1e8>
  8005bd:	4f                   	dec    %edi
  8005be:	79 c6                	jns    800586 <vprintfmt+0x1e8>
  8005c0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005c3:	89 de                	mov    %ebx,%esi
  8005c5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005c8:	eb 18                	jmp    8005e2 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005ca:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005ce:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005d5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005d7:	4b                   	dec    %ebx
  8005d8:	eb 08                	jmp    8005e2 <vprintfmt+0x244>
  8005da:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005dd:	89 de                	mov    %ebx,%esi
  8005df:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005e2:	85 db                	test   %ebx,%ebx
  8005e4:	7f e4                	jg     8005ca <vprintfmt+0x22c>
  8005e6:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005e9:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005eb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005ee:	e9 ce fd ff ff       	jmp    8003c1 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005f3:	83 f9 01             	cmp    $0x1,%ecx
  8005f6:	7e 10                	jle    800608 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8005f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fb:	8d 50 08             	lea    0x8(%eax),%edx
  8005fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800601:	8b 30                	mov    (%eax),%esi
  800603:	8b 78 04             	mov    0x4(%eax),%edi
  800606:	eb 26                	jmp    80062e <vprintfmt+0x290>
	else if (lflag)
  800608:	85 c9                	test   %ecx,%ecx
  80060a:	74 12                	je     80061e <vprintfmt+0x280>
		return va_arg(*ap, long);
  80060c:	8b 45 14             	mov    0x14(%ebp),%eax
  80060f:	8d 50 04             	lea    0x4(%eax),%edx
  800612:	89 55 14             	mov    %edx,0x14(%ebp)
  800615:	8b 30                	mov    (%eax),%esi
  800617:	89 f7                	mov    %esi,%edi
  800619:	c1 ff 1f             	sar    $0x1f,%edi
  80061c:	eb 10                	jmp    80062e <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80061e:	8b 45 14             	mov    0x14(%ebp),%eax
  800621:	8d 50 04             	lea    0x4(%eax),%edx
  800624:	89 55 14             	mov    %edx,0x14(%ebp)
  800627:	8b 30                	mov    (%eax),%esi
  800629:	89 f7                	mov    %esi,%edi
  80062b:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80062e:	85 ff                	test   %edi,%edi
  800630:	78 0a                	js     80063c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800632:	b8 0a 00 00 00       	mov    $0xa,%eax
  800637:	e9 8c 00 00 00       	jmp    8006c8 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80063c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800640:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800647:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80064a:	f7 de                	neg    %esi
  80064c:	83 d7 00             	adc    $0x0,%edi
  80064f:	f7 df                	neg    %edi
			}
			base = 10;
  800651:	b8 0a 00 00 00       	mov    $0xa,%eax
  800656:	eb 70                	jmp    8006c8 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800658:	89 ca                	mov    %ecx,%edx
  80065a:	8d 45 14             	lea    0x14(%ebp),%eax
  80065d:	e8 c0 fc ff ff       	call   800322 <getuint>
  800662:	89 c6                	mov    %eax,%esi
  800664:	89 d7                	mov    %edx,%edi
			base = 10;
  800666:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80066b:	eb 5b                	jmp    8006c8 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  80066d:	89 ca                	mov    %ecx,%edx
  80066f:	8d 45 14             	lea    0x14(%ebp),%eax
  800672:	e8 ab fc ff ff       	call   800322 <getuint>
  800677:	89 c6                	mov    %eax,%esi
  800679:	89 d7                	mov    %edx,%edi
			base = 8;
  80067b:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800680:	eb 46                	jmp    8006c8 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  800682:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800686:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80068d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800690:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800694:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80069b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80069e:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a1:	8d 50 04             	lea    0x4(%eax),%edx
  8006a4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006a7:	8b 30                	mov    (%eax),%esi
  8006a9:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006ae:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006b3:	eb 13                	jmp    8006c8 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006b5:	89 ca                	mov    %ecx,%edx
  8006b7:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ba:	e8 63 fc ff ff       	call   800322 <getuint>
  8006bf:	89 c6                	mov    %eax,%esi
  8006c1:	89 d7                	mov    %edx,%edi
			base = 16;
  8006c3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006c8:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8006cc:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006d0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006d3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006db:	89 34 24             	mov    %esi,(%esp)
  8006de:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006e2:	89 da                	mov    %ebx,%edx
  8006e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e7:	e8 6c fb ff ff       	call   800258 <printnum>
			break;
  8006ec:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006ef:	e9 cd fc ff ff       	jmp    8003c1 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f8:	89 04 24             	mov    %eax,(%esp)
  8006fb:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006fe:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800701:	e9 bb fc ff ff       	jmp    8003c1 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800706:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80070a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800711:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800714:	eb 01                	jmp    800717 <vprintfmt+0x379>
  800716:	4e                   	dec    %esi
  800717:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80071b:	75 f9                	jne    800716 <vprintfmt+0x378>
  80071d:	e9 9f fc ff ff       	jmp    8003c1 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800722:	83 c4 4c             	add    $0x4c,%esp
  800725:	5b                   	pop    %ebx
  800726:	5e                   	pop    %esi
  800727:	5f                   	pop    %edi
  800728:	5d                   	pop    %ebp
  800729:	c3                   	ret    

0080072a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80072a:	55                   	push   %ebp
  80072b:	89 e5                	mov    %esp,%ebp
  80072d:	83 ec 28             	sub    $0x28,%esp
  800730:	8b 45 08             	mov    0x8(%ebp),%eax
  800733:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800736:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800739:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80073d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800740:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800747:	85 c0                	test   %eax,%eax
  800749:	74 30                	je     80077b <vsnprintf+0x51>
  80074b:	85 d2                	test   %edx,%edx
  80074d:	7e 33                	jle    800782 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80074f:	8b 45 14             	mov    0x14(%ebp),%eax
  800752:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800756:	8b 45 10             	mov    0x10(%ebp),%eax
  800759:	89 44 24 08          	mov    %eax,0x8(%esp)
  80075d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800760:	89 44 24 04          	mov    %eax,0x4(%esp)
  800764:	c7 04 24 5c 03 80 00 	movl   $0x80035c,(%esp)
  80076b:	e8 2e fc ff ff       	call   80039e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800770:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800773:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800776:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800779:	eb 0c                	jmp    800787 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80077b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800780:	eb 05                	jmp    800787 <vsnprintf+0x5d>
  800782:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800787:	c9                   	leave  
  800788:	c3                   	ret    

00800789 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800789:	55                   	push   %ebp
  80078a:	89 e5                	mov    %esp,%ebp
  80078c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80078f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800792:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800796:	8b 45 10             	mov    0x10(%ebp),%eax
  800799:	89 44 24 08          	mov    %eax,0x8(%esp)
  80079d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a7:	89 04 24             	mov    %eax,(%esp)
  8007aa:	e8 7b ff ff ff       	call   80072a <vsnprintf>
	va_end(ap);

	return rc;
}
  8007af:	c9                   	leave  
  8007b0:	c3                   	ret    
  8007b1:	00 00                	add    %al,(%eax)
	...

008007b4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8007bf:	eb 01                	jmp    8007c2 <strlen+0xe>
		n++;
  8007c1:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007c6:	75 f9                	jne    8007c1 <strlen+0xd>
		n++;
	return n;
}
  8007c8:	5d                   	pop    %ebp
  8007c9:	c3                   	ret    

008007ca <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007ca:	55                   	push   %ebp
  8007cb:	89 e5                	mov    %esp,%ebp
  8007cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8007d0:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d8:	eb 01                	jmp    8007db <strnlen+0x11>
		n++;
  8007da:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007db:	39 d0                	cmp    %edx,%eax
  8007dd:	74 06                	je     8007e5 <strnlen+0x1b>
  8007df:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007e3:	75 f5                	jne    8007da <strnlen+0x10>
		n++;
	return n;
}
  8007e5:	5d                   	pop    %ebp
  8007e6:	c3                   	ret    

008007e7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007e7:	55                   	push   %ebp
  8007e8:	89 e5                	mov    %esp,%ebp
  8007ea:	53                   	push   %ebx
  8007eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8007f6:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007f9:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007fc:	42                   	inc    %edx
  8007fd:	84 c9                	test   %cl,%cl
  8007ff:	75 f5                	jne    8007f6 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800801:	5b                   	pop    %ebx
  800802:	5d                   	pop    %ebp
  800803:	c3                   	ret    

00800804 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800804:	55                   	push   %ebp
  800805:	89 e5                	mov    %esp,%ebp
  800807:	53                   	push   %ebx
  800808:	83 ec 08             	sub    $0x8,%esp
  80080b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80080e:	89 1c 24             	mov    %ebx,(%esp)
  800811:	e8 9e ff ff ff       	call   8007b4 <strlen>
	strcpy(dst + len, src);
  800816:	8b 55 0c             	mov    0xc(%ebp),%edx
  800819:	89 54 24 04          	mov    %edx,0x4(%esp)
  80081d:	01 d8                	add    %ebx,%eax
  80081f:	89 04 24             	mov    %eax,(%esp)
  800822:	e8 c0 ff ff ff       	call   8007e7 <strcpy>
	return dst;
}
  800827:	89 d8                	mov    %ebx,%eax
  800829:	83 c4 08             	add    $0x8,%esp
  80082c:	5b                   	pop    %ebx
  80082d:	5d                   	pop    %ebp
  80082e:	c3                   	ret    

0080082f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80082f:	55                   	push   %ebp
  800830:	89 e5                	mov    %esp,%ebp
  800832:	56                   	push   %esi
  800833:	53                   	push   %ebx
  800834:	8b 45 08             	mov    0x8(%ebp),%eax
  800837:	8b 55 0c             	mov    0xc(%ebp),%edx
  80083a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80083d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800842:	eb 0c                	jmp    800850 <strncpy+0x21>
		*dst++ = *src;
  800844:	8a 1a                	mov    (%edx),%bl
  800846:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800849:	80 3a 01             	cmpb   $0x1,(%edx)
  80084c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80084f:	41                   	inc    %ecx
  800850:	39 f1                	cmp    %esi,%ecx
  800852:	75 f0                	jne    800844 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800854:	5b                   	pop    %ebx
  800855:	5e                   	pop    %esi
  800856:	5d                   	pop    %ebp
  800857:	c3                   	ret    

00800858 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800858:	55                   	push   %ebp
  800859:	89 e5                	mov    %esp,%ebp
  80085b:	56                   	push   %esi
  80085c:	53                   	push   %ebx
  80085d:	8b 75 08             	mov    0x8(%ebp),%esi
  800860:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800863:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800866:	85 d2                	test   %edx,%edx
  800868:	75 0a                	jne    800874 <strlcpy+0x1c>
  80086a:	89 f0                	mov    %esi,%eax
  80086c:	eb 1a                	jmp    800888 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80086e:	88 18                	mov    %bl,(%eax)
  800870:	40                   	inc    %eax
  800871:	41                   	inc    %ecx
  800872:	eb 02                	jmp    800876 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800874:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800876:	4a                   	dec    %edx
  800877:	74 0a                	je     800883 <strlcpy+0x2b>
  800879:	8a 19                	mov    (%ecx),%bl
  80087b:	84 db                	test   %bl,%bl
  80087d:	75 ef                	jne    80086e <strlcpy+0x16>
  80087f:	89 c2                	mov    %eax,%edx
  800881:	eb 02                	jmp    800885 <strlcpy+0x2d>
  800883:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800885:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800888:	29 f0                	sub    %esi,%eax
}
  80088a:	5b                   	pop    %ebx
  80088b:	5e                   	pop    %esi
  80088c:	5d                   	pop    %ebp
  80088d:	c3                   	ret    

0080088e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80088e:	55                   	push   %ebp
  80088f:	89 e5                	mov    %esp,%ebp
  800891:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800894:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800897:	eb 02                	jmp    80089b <strcmp+0xd>
		p++, q++;
  800899:	41                   	inc    %ecx
  80089a:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80089b:	8a 01                	mov    (%ecx),%al
  80089d:	84 c0                	test   %al,%al
  80089f:	74 04                	je     8008a5 <strcmp+0x17>
  8008a1:	3a 02                	cmp    (%edx),%al
  8008a3:	74 f4                	je     800899 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a5:	0f b6 c0             	movzbl %al,%eax
  8008a8:	0f b6 12             	movzbl (%edx),%edx
  8008ab:	29 d0                	sub    %edx,%eax
}
  8008ad:	5d                   	pop    %ebp
  8008ae:	c3                   	ret    

008008af <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008af:	55                   	push   %ebp
  8008b0:	89 e5                	mov    %esp,%ebp
  8008b2:	53                   	push   %ebx
  8008b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008b9:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008bc:	eb 03                	jmp    8008c1 <strncmp+0x12>
		n--, p++, q++;
  8008be:	4a                   	dec    %edx
  8008bf:	40                   	inc    %eax
  8008c0:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008c1:	85 d2                	test   %edx,%edx
  8008c3:	74 14                	je     8008d9 <strncmp+0x2a>
  8008c5:	8a 18                	mov    (%eax),%bl
  8008c7:	84 db                	test   %bl,%bl
  8008c9:	74 04                	je     8008cf <strncmp+0x20>
  8008cb:	3a 19                	cmp    (%ecx),%bl
  8008cd:	74 ef                	je     8008be <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008cf:	0f b6 00             	movzbl (%eax),%eax
  8008d2:	0f b6 11             	movzbl (%ecx),%edx
  8008d5:	29 d0                	sub    %edx,%eax
  8008d7:	eb 05                	jmp    8008de <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008d9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008de:	5b                   	pop    %ebx
  8008df:	5d                   	pop    %ebp
  8008e0:	c3                   	ret    

008008e1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008e1:	55                   	push   %ebp
  8008e2:	89 e5                	mov    %esp,%ebp
  8008e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e7:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008ea:	eb 05                	jmp    8008f1 <strchr+0x10>
		if (*s == c)
  8008ec:	38 ca                	cmp    %cl,%dl
  8008ee:	74 0c                	je     8008fc <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008f0:	40                   	inc    %eax
  8008f1:	8a 10                	mov    (%eax),%dl
  8008f3:	84 d2                	test   %dl,%dl
  8008f5:	75 f5                	jne    8008ec <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8008f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008fc:	5d                   	pop    %ebp
  8008fd:	c3                   	ret    

008008fe <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008fe:	55                   	push   %ebp
  8008ff:	89 e5                	mov    %esp,%ebp
  800901:	8b 45 08             	mov    0x8(%ebp),%eax
  800904:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800907:	eb 05                	jmp    80090e <strfind+0x10>
		if (*s == c)
  800909:	38 ca                	cmp    %cl,%dl
  80090b:	74 07                	je     800914 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80090d:	40                   	inc    %eax
  80090e:	8a 10                	mov    (%eax),%dl
  800910:	84 d2                	test   %dl,%dl
  800912:	75 f5                	jne    800909 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800914:	5d                   	pop    %ebp
  800915:	c3                   	ret    

00800916 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800916:	55                   	push   %ebp
  800917:	89 e5                	mov    %esp,%ebp
  800919:	57                   	push   %edi
  80091a:	56                   	push   %esi
  80091b:	53                   	push   %ebx
  80091c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80091f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800922:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800925:	85 c9                	test   %ecx,%ecx
  800927:	74 30                	je     800959 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800929:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80092f:	75 25                	jne    800956 <memset+0x40>
  800931:	f6 c1 03             	test   $0x3,%cl
  800934:	75 20                	jne    800956 <memset+0x40>
		c &= 0xFF;
  800936:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800939:	89 d3                	mov    %edx,%ebx
  80093b:	c1 e3 08             	shl    $0x8,%ebx
  80093e:	89 d6                	mov    %edx,%esi
  800940:	c1 e6 18             	shl    $0x18,%esi
  800943:	89 d0                	mov    %edx,%eax
  800945:	c1 e0 10             	shl    $0x10,%eax
  800948:	09 f0                	or     %esi,%eax
  80094a:	09 d0                	or     %edx,%eax
  80094c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80094e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800951:	fc                   	cld    
  800952:	f3 ab                	rep stos %eax,%es:(%edi)
  800954:	eb 03                	jmp    800959 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800956:	fc                   	cld    
  800957:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800959:	89 f8                	mov    %edi,%eax
  80095b:	5b                   	pop    %ebx
  80095c:	5e                   	pop    %esi
  80095d:	5f                   	pop    %edi
  80095e:	5d                   	pop    %ebp
  80095f:	c3                   	ret    

00800960 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	57                   	push   %edi
  800964:	56                   	push   %esi
  800965:	8b 45 08             	mov    0x8(%ebp),%eax
  800968:	8b 75 0c             	mov    0xc(%ebp),%esi
  80096b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80096e:	39 c6                	cmp    %eax,%esi
  800970:	73 34                	jae    8009a6 <memmove+0x46>
  800972:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800975:	39 d0                	cmp    %edx,%eax
  800977:	73 2d                	jae    8009a6 <memmove+0x46>
		s += n;
		d += n;
  800979:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80097c:	f6 c2 03             	test   $0x3,%dl
  80097f:	75 1b                	jne    80099c <memmove+0x3c>
  800981:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800987:	75 13                	jne    80099c <memmove+0x3c>
  800989:	f6 c1 03             	test   $0x3,%cl
  80098c:	75 0e                	jne    80099c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80098e:	83 ef 04             	sub    $0x4,%edi
  800991:	8d 72 fc             	lea    -0x4(%edx),%esi
  800994:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800997:	fd                   	std    
  800998:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80099a:	eb 07                	jmp    8009a3 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80099c:	4f                   	dec    %edi
  80099d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009a0:	fd                   	std    
  8009a1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009a3:	fc                   	cld    
  8009a4:	eb 20                	jmp    8009c6 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ac:	75 13                	jne    8009c1 <memmove+0x61>
  8009ae:	a8 03                	test   $0x3,%al
  8009b0:	75 0f                	jne    8009c1 <memmove+0x61>
  8009b2:	f6 c1 03             	test   $0x3,%cl
  8009b5:	75 0a                	jne    8009c1 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009b7:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009ba:	89 c7                	mov    %eax,%edi
  8009bc:	fc                   	cld    
  8009bd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009bf:	eb 05                	jmp    8009c6 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009c1:	89 c7                	mov    %eax,%edi
  8009c3:	fc                   	cld    
  8009c4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009c6:	5e                   	pop    %esi
  8009c7:	5f                   	pop    %edi
  8009c8:	5d                   	pop    %ebp
  8009c9:	c3                   	ret    

008009ca <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ca:	55                   	push   %ebp
  8009cb:	89 e5                	mov    %esp,%ebp
  8009cd:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009d0:	8b 45 10             	mov    0x10(%ebp),%eax
  8009d3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009de:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e1:	89 04 24             	mov    %eax,(%esp)
  8009e4:	e8 77 ff ff ff       	call   800960 <memmove>
}
  8009e9:	c9                   	leave  
  8009ea:	c3                   	ret    

008009eb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009eb:	55                   	push   %ebp
  8009ec:	89 e5                	mov    %esp,%ebp
  8009ee:	57                   	push   %edi
  8009ef:	56                   	push   %esi
  8009f0:	53                   	push   %ebx
  8009f1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009f4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009f7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ff:	eb 16                	jmp    800a17 <memcmp+0x2c>
		if (*s1 != *s2)
  800a01:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a04:	42                   	inc    %edx
  800a05:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a09:	38 c8                	cmp    %cl,%al
  800a0b:	74 0a                	je     800a17 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a0d:	0f b6 c0             	movzbl %al,%eax
  800a10:	0f b6 c9             	movzbl %cl,%ecx
  800a13:	29 c8                	sub    %ecx,%eax
  800a15:	eb 09                	jmp    800a20 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a17:	39 da                	cmp    %ebx,%edx
  800a19:	75 e6                	jne    800a01 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a1b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a20:	5b                   	pop    %ebx
  800a21:	5e                   	pop    %esi
  800a22:	5f                   	pop    %edi
  800a23:	5d                   	pop    %ebp
  800a24:	c3                   	ret    

00800a25 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a25:	55                   	push   %ebp
  800a26:	89 e5                	mov    %esp,%ebp
  800a28:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a2e:	89 c2                	mov    %eax,%edx
  800a30:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a33:	eb 05                	jmp    800a3a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a35:	38 08                	cmp    %cl,(%eax)
  800a37:	74 05                	je     800a3e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a39:	40                   	inc    %eax
  800a3a:	39 d0                	cmp    %edx,%eax
  800a3c:	72 f7                	jb     800a35 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a3e:	5d                   	pop    %ebp
  800a3f:	c3                   	ret    

00800a40 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a40:	55                   	push   %ebp
  800a41:	89 e5                	mov    %esp,%ebp
  800a43:	57                   	push   %edi
  800a44:	56                   	push   %esi
  800a45:	53                   	push   %ebx
  800a46:	8b 55 08             	mov    0x8(%ebp),%edx
  800a49:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a4c:	eb 01                	jmp    800a4f <strtol+0xf>
		s++;
  800a4e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a4f:	8a 02                	mov    (%edx),%al
  800a51:	3c 20                	cmp    $0x20,%al
  800a53:	74 f9                	je     800a4e <strtol+0xe>
  800a55:	3c 09                	cmp    $0x9,%al
  800a57:	74 f5                	je     800a4e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a59:	3c 2b                	cmp    $0x2b,%al
  800a5b:	75 08                	jne    800a65 <strtol+0x25>
		s++;
  800a5d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a5e:	bf 00 00 00 00       	mov    $0x0,%edi
  800a63:	eb 13                	jmp    800a78 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a65:	3c 2d                	cmp    $0x2d,%al
  800a67:	75 0a                	jne    800a73 <strtol+0x33>
		s++, neg = 1;
  800a69:	8d 52 01             	lea    0x1(%edx),%edx
  800a6c:	bf 01 00 00 00       	mov    $0x1,%edi
  800a71:	eb 05                	jmp    800a78 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a73:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a78:	85 db                	test   %ebx,%ebx
  800a7a:	74 05                	je     800a81 <strtol+0x41>
  800a7c:	83 fb 10             	cmp    $0x10,%ebx
  800a7f:	75 28                	jne    800aa9 <strtol+0x69>
  800a81:	8a 02                	mov    (%edx),%al
  800a83:	3c 30                	cmp    $0x30,%al
  800a85:	75 10                	jne    800a97 <strtol+0x57>
  800a87:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a8b:	75 0a                	jne    800a97 <strtol+0x57>
		s += 2, base = 16;
  800a8d:	83 c2 02             	add    $0x2,%edx
  800a90:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a95:	eb 12                	jmp    800aa9 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a97:	85 db                	test   %ebx,%ebx
  800a99:	75 0e                	jne    800aa9 <strtol+0x69>
  800a9b:	3c 30                	cmp    $0x30,%al
  800a9d:	75 05                	jne    800aa4 <strtol+0x64>
		s++, base = 8;
  800a9f:	42                   	inc    %edx
  800aa0:	b3 08                	mov    $0x8,%bl
  800aa2:	eb 05                	jmp    800aa9 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800aa4:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800aa9:	b8 00 00 00 00       	mov    $0x0,%eax
  800aae:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ab0:	8a 0a                	mov    (%edx),%cl
  800ab2:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ab5:	80 fb 09             	cmp    $0x9,%bl
  800ab8:	77 08                	ja     800ac2 <strtol+0x82>
			dig = *s - '0';
  800aba:	0f be c9             	movsbl %cl,%ecx
  800abd:	83 e9 30             	sub    $0x30,%ecx
  800ac0:	eb 1e                	jmp    800ae0 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800ac2:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ac5:	80 fb 19             	cmp    $0x19,%bl
  800ac8:	77 08                	ja     800ad2 <strtol+0x92>
			dig = *s - 'a' + 10;
  800aca:	0f be c9             	movsbl %cl,%ecx
  800acd:	83 e9 57             	sub    $0x57,%ecx
  800ad0:	eb 0e                	jmp    800ae0 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800ad2:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800ad5:	80 fb 19             	cmp    $0x19,%bl
  800ad8:	77 12                	ja     800aec <strtol+0xac>
			dig = *s - 'A' + 10;
  800ada:	0f be c9             	movsbl %cl,%ecx
  800add:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ae0:	39 f1                	cmp    %esi,%ecx
  800ae2:	7d 0c                	jge    800af0 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800ae4:	42                   	inc    %edx
  800ae5:	0f af c6             	imul   %esi,%eax
  800ae8:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800aea:	eb c4                	jmp    800ab0 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800aec:	89 c1                	mov    %eax,%ecx
  800aee:	eb 02                	jmp    800af2 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800af0:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800af2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800af6:	74 05                	je     800afd <strtol+0xbd>
		*endptr = (char *) s;
  800af8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800afb:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800afd:	85 ff                	test   %edi,%edi
  800aff:	74 04                	je     800b05 <strtol+0xc5>
  800b01:	89 c8                	mov    %ecx,%eax
  800b03:	f7 d8                	neg    %eax
}
  800b05:	5b                   	pop    %ebx
  800b06:	5e                   	pop    %esi
  800b07:	5f                   	pop    %edi
  800b08:	5d                   	pop    %ebp
  800b09:	c3                   	ret    
	...

00800b0c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	57                   	push   %edi
  800b10:	56                   	push   %esi
  800b11:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b12:	b8 00 00 00 00       	mov    $0x0,%eax
  800b17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b1d:	89 c3                	mov    %eax,%ebx
  800b1f:	89 c7                	mov    %eax,%edi
  800b21:	89 c6                	mov    %eax,%esi
  800b23:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b25:	5b                   	pop    %ebx
  800b26:	5e                   	pop    %esi
  800b27:	5f                   	pop    %edi
  800b28:	5d                   	pop    %ebp
  800b29:	c3                   	ret    

00800b2a <sys_cgetc>:

int
sys_cgetc(void)
{
  800b2a:	55                   	push   %ebp
  800b2b:	89 e5                	mov    %esp,%ebp
  800b2d:	57                   	push   %edi
  800b2e:	56                   	push   %esi
  800b2f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b30:	ba 00 00 00 00       	mov    $0x0,%edx
  800b35:	b8 01 00 00 00       	mov    $0x1,%eax
  800b3a:	89 d1                	mov    %edx,%ecx
  800b3c:	89 d3                	mov    %edx,%ebx
  800b3e:	89 d7                	mov    %edx,%edi
  800b40:	89 d6                	mov    %edx,%esi
  800b42:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b44:	5b                   	pop    %ebx
  800b45:	5e                   	pop    %esi
  800b46:	5f                   	pop    %edi
  800b47:	5d                   	pop    %ebp
  800b48:	c3                   	ret    

00800b49 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b49:	55                   	push   %ebp
  800b4a:	89 e5                	mov    %esp,%ebp
  800b4c:	57                   	push   %edi
  800b4d:	56                   	push   %esi
  800b4e:	53                   	push   %ebx
  800b4f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b52:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b57:	b8 03 00 00 00       	mov    $0x3,%eax
  800b5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5f:	89 cb                	mov    %ecx,%ebx
  800b61:	89 cf                	mov    %ecx,%edi
  800b63:	89 ce                	mov    %ecx,%esi
  800b65:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b67:	85 c0                	test   %eax,%eax
  800b69:	7e 28                	jle    800b93 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b6b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b6f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b76:	00 
  800b77:	c7 44 24 08 df 25 80 	movl   $0x8025df,0x8(%esp)
  800b7e:	00 
  800b7f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b86:	00 
  800b87:	c7 04 24 fc 25 80 00 	movl   $0x8025fc,(%esp)
  800b8e:	e8 e9 12 00 00       	call   801e7c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b93:	83 c4 2c             	add    $0x2c,%esp
  800b96:	5b                   	pop    %ebx
  800b97:	5e                   	pop    %esi
  800b98:	5f                   	pop    %edi
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    

00800b9b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	57                   	push   %edi
  800b9f:	56                   	push   %esi
  800ba0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba6:	b8 02 00 00 00       	mov    $0x2,%eax
  800bab:	89 d1                	mov    %edx,%ecx
  800bad:	89 d3                	mov    %edx,%ebx
  800baf:	89 d7                	mov    %edx,%edi
  800bb1:	89 d6                	mov    %edx,%esi
  800bb3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bb5:	5b                   	pop    %ebx
  800bb6:	5e                   	pop    %esi
  800bb7:	5f                   	pop    %edi
  800bb8:	5d                   	pop    %ebp
  800bb9:	c3                   	ret    

00800bba <sys_yield>:

void
sys_yield(void)
{
  800bba:	55                   	push   %ebp
  800bbb:	89 e5                	mov    %esp,%ebp
  800bbd:	57                   	push   %edi
  800bbe:	56                   	push   %esi
  800bbf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bca:	89 d1                	mov    %edx,%ecx
  800bcc:	89 d3                	mov    %edx,%ebx
  800bce:	89 d7                	mov    %edx,%edi
  800bd0:	89 d6                	mov    %edx,%esi
  800bd2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bd4:	5b                   	pop    %ebx
  800bd5:	5e                   	pop    %esi
  800bd6:	5f                   	pop    %edi
  800bd7:	5d                   	pop    %ebp
  800bd8:	c3                   	ret    

00800bd9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
  800bdc:	57                   	push   %edi
  800bdd:	56                   	push   %esi
  800bde:	53                   	push   %ebx
  800bdf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be2:	be 00 00 00 00       	mov    $0x0,%esi
  800be7:	b8 04 00 00 00       	mov    $0x4,%eax
  800bec:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf5:	89 f7                	mov    %esi,%edi
  800bf7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bf9:	85 c0                	test   %eax,%eax
  800bfb:	7e 28                	jle    800c25 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c01:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c08:	00 
  800c09:	c7 44 24 08 df 25 80 	movl   $0x8025df,0x8(%esp)
  800c10:	00 
  800c11:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c18:	00 
  800c19:	c7 04 24 fc 25 80 00 	movl   $0x8025fc,(%esp)
  800c20:	e8 57 12 00 00       	call   801e7c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c25:	83 c4 2c             	add    $0x2c,%esp
  800c28:	5b                   	pop    %ebx
  800c29:	5e                   	pop    %esi
  800c2a:	5f                   	pop    %edi
  800c2b:	5d                   	pop    %ebp
  800c2c:	c3                   	ret    

00800c2d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c2d:	55                   	push   %ebp
  800c2e:	89 e5                	mov    %esp,%ebp
  800c30:	57                   	push   %edi
  800c31:	56                   	push   %esi
  800c32:	53                   	push   %ebx
  800c33:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c36:	b8 05 00 00 00       	mov    $0x5,%eax
  800c3b:	8b 75 18             	mov    0x18(%ebp),%esi
  800c3e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c41:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c47:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c4c:	85 c0                	test   %eax,%eax
  800c4e:	7e 28                	jle    800c78 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c50:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c54:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c5b:	00 
  800c5c:	c7 44 24 08 df 25 80 	movl   $0x8025df,0x8(%esp)
  800c63:	00 
  800c64:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c6b:	00 
  800c6c:	c7 04 24 fc 25 80 00 	movl   $0x8025fc,(%esp)
  800c73:	e8 04 12 00 00       	call   801e7c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c78:	83 c4 2c             	add    $0x2c,%esp
  800c7b:	5b                   	pop    %ebx
  800c7c:	5e                   	pop    %esi
  800c7d:	5f                   	pop    %edi
  800c7e:	5d                   	pop    %ebp
  800c7f:	c3                   	ret    

00800c80 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c80:	55                   	push   %ebp
  800c81:	89 e5                	mov    %esp,%ebp
  800c83:	57                   	push   %edi
  800c84:	56                   	push   %esi
  800c85:	53                   	push   %ebx
  800c86:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c89:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8e:	b8 06 00 00 00       	mov    $0x6,%eax
  800c93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c96:	8b 55 08             	mov    0x8(%ebp),%edx
  800c99:	89 df                	mov    %ebx,%edi
  800c9b:	89 de                	mov    %ebx,%esi
  800c9d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c9f:	85 c0                	test   %eax,%eax
  800ca1:	7e 28                	jle    800ccb <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ca7:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800cae:	00 
  800caf:	c7 44 24 08 df 25 80 	movl   $0x8025df,0x8(%esp)
  800cb6:	00 
  800cb7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cbe:	00 
  800cbf:	c7 04 24 fc 25 80 00 	movl   $0x8025fc,(%esp)
  800cc6:	e8 b1 11 00 00       	call   801e7c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ccb:	83 c4 2c             	add    $0x2c,%esp
  800cce:	5b                   	pop    %ebx
  800ccf:	5e                   	pop    %esi
  800cd0:	5f                   	pop    %edi
  800cd1:	5d                   	pop    %ebp
  800cd2:	c3                   	ret    

00800cd3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cd3:	55                   	push   %ebp
  800cd4:	89 e5                	mov    %esp,%ebp
  800cd6:	57                   	push   %edi
  800cd7:	56                   	push   %esi
  800cd8:	53                   	push   %ebx
  800cd9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cdc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce1:	b8 08 00 00 00       	mov    $0x8,%eax
  800ce6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cec:	89 df                	mov    %ebx,%edi
  800cee:	89 de                	mov    %ebx,%esi
  800cf0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cf2:	85 c0                	test   %eax,%eax
  800cf4:	7e 28                	jle    800d1e <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cfa:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d01:	00 
  800d02:	c7 44 24 08 df 25 80 	movl   $0x8025df,0x8(%esp)
  800d09:	00 
  800d0a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d11:	00 
  800d12:	c7 04 24 fc 25 80 00 	movl   $0x8025fc,(%esp)
  800d19:	e8 5e 11 00 00       	call   801e7c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d1e:	83 c4 2c             	add    $0x2c,%esp
  800d21:	5b                   	pop    %ebx
  800d22:	5e                   	pop    %esi
  800d23:	5f                   	pop    %edi
  800d24:	5d                   	pop    %ebp
  800d25:	c3                   	ret    

00800d26 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d26:	55                   	push   %ebp
  800d27:	89 e5                	mov    %esp,%ebp
  800d29:	57                   	push   %edi
  800d2a:	56                   	push   %esi
  800d2b:	53                   	push   %ebx
  800d2c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d34:	b8 09 00 00 00       	mov    $0x9,%eax
  800d39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3f:	89 df                	mov    %ebx,%edi
  800d41:	89 de                	mov    %ebx,%esi
  800d43:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d45:	85 c0                	test   %eax,%eax
  800d47:	7e 28                	jle    800d71 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d49:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d4d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d54:	00 
  800d55:	c7 44 24 08 df 25 80 	movl   $0x8025df,0x8(%esp)
  800d5c:	00 
  800d5d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d64:	00 
  800d65:	c7 04 24 fc 25 80 00 	movl   $0x8025fc,(%esp)
  800d6c:	e8 0b 11 00 00       	call   801e7c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d71:	83 c4 2c             	add    $0x2c,%esp
  800d74:	5b                   	pop    %ebx
  800d75:	5e                   	pop    %esi
  800d76:	5f                   	pop    %edi
  800d77:	5d                   	pop    %ebp
  800d78:	c3                   	ret    

00800d79 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800d82:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d87:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d92:	89 df                	mov    %ebx,%edi
  800d94:	89 de                	mov    %ebx,%esi
  800d96:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d98:	85 c0                	test   %eax,%eax
  800d9a:	7e 28                	jle    800dc4 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800da0:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800da7:	00 
  800da8:	c7 44 24 08 df 25 80 	movl   $0x8025df,0x8(%esp)
  800daf:	00 
  800db0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800db7:	00 
  800db8:	c7 04 24 fc 25 80 00 	movl   $0x8025fc,(%esp)
  800dbf:	e8 b8 10 00 00       	call   801e7c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dc4:	83 c4 2c             	add    $0x2c,%esp
  800dc7:	5b                   	pop    %ebx
  800dc8:	5e                   	pop    %esi
  800dc9:	5f                   	pop    %edi
  800dca:	5d                   	pop    %ebp
  800dcb:	c3                   	ret    

00800dcc <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
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
  800dd2:	be 00 00 00 00       	mov    $0x0,%esi
  800dd7:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ddc:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ddf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800de2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de5:	8b 55 08             	mov    0x8(%ebp),%edx
  800de8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dea:	5b                   	pop    %ebx
  800deb:	5e                   	pop    %esi
  800dec:	5f                   	pop    %edi
  800ded:	5d                   	pop    %ebp
  800dee:	c3                   	ret    

00800def <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800def:	55                   	push   %ebp
  800df0:	89 e5                	mov    %esp,%ebp
  800df2:	57                   	push   %edi
  800df3:	56                   	push   %esi
  800df4:	53                   	push   %ebx
  800df5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dfd:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e02:	8b 55 08             	mov    0x8(%ebp),%edx
  800e05:	89 cb                	mov    %ecx,%ebx
  800e07:	89 cf                	mov    %ecx,%edi
  800e09:	89 ce                	mov    %ecx,%esi
  800e0b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e0d:	85 c0                	test   %eax,%eax
  800e0f:	7e 28                	jle    800e39 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e11:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e15:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e1c:	00 
  800e1d:	c7 44 24 08 df 25 80 	movl   $0x8025df,0x8(%esp)
  800e24:	00 
  800e25:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e2c:	00 
  800e2d:	c7 04 24 fc 25 80 00 	movl   $0x8025fc,(%esp)
  800e34:	e8 43 10 00 00       	call   801e7c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e39:	83 c4 2c             	add    $0x2c,%esp
  800e3c:	5b                   	pop    %ebx
  800e3d:	5e                   	pop    %esi
  800e3e:	5f                   	pop    %edi
  800e3f:	5d                   	pop    %ebp
  800e40:	c3                   	ret    
  800e41:	00 00                	add    %al,(%eax)
	...

00800e44 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  800e44:	55                   	push   %ebp
  800e45:	89 e5                	mov    %esp,%ebp
  800e47:	8b 55 08             	mov    0x8(%ebp),%edx
  800e4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e4d:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  800e50:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  800e52:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  800e55:	83 3a 01             	cmpl   $0x1,(%edx)
  800e58:	7e 0b                	jle    800e65 <argstart+0x21>
  800e5a:	85 c9                	test   %ecx,%ecx
  800e5c:	75 0e                	jne    800e6c <argstart+0x28>
  800e5e:	ba 00 00 00 00       	mov    $0x0,%edx
  800e63:	eb 0c                	jmp    800e71 <argstart+0x2d>
  800e65:	ba 00 00 00 00       	mov    $0x0,%edx
  800e6a:	eb 05                	jmp    800e71 <argstart+0x2d>
  800e6c:	ba b1 22 80 00       	mov    $0x8022b1,%edx
  800e71:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  800e74:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  800e7b:	5d                   	pop    %ebp
  800e7c:	c3                   	ret    

00800e7d <argnext>:

int
argnext(struct Argstate *args)
{
  800e7d:	55                   	push   %ebp
  800e7e:	89 e5                	mov    %esp,%ebp
  800e80:	53                   	push   %ebx
  800e81:	83 ec 14             	sub    $0x14,%esp
  800e84:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  800e87:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  800e8e:	8b 43 08             	mov    0x8(%ebx),%eax
  800e91:	85 c0                	test   %eax,%eax
  800e93:	74 6c                	je     800f01 <argnext+0x84>
		return -1;

	if (!*args->curarg) {
  800e95:	80 38 00             	cmpb   $0x0,(%eax)
  800e98:	75 4d                	jne    800ee7 <argnext+0x6a>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  800e9a:	8b 0b                	mov    (%ebx),%ecx
  800e9c:	83 39 01             	cmpl   $0x1,(%ecx)
  800e9f:	74 52                	je     800ef3 <argnext+0x76>
		    || args->argv[1][0] != '-'
  800ea1:	8b 53 04             	mov    0x4(%ebx),%edx
  800ea4:	8b 42 04             	mov    0x4(%edx),%eax
  800ea7:	80 38 2d             	cmpb   $0x2d,(%eax)
  800eaa:	75 47                	jne    800ef3 <argnext+0x76>
		    || args->argv[1][1] == '\0')
  800eac:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800eb0:	74 41                	je     800ef3 <argnext+0x76>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  800eb2:	40                   	inc    %eax
  800eb3:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800eb6:	8b 01                	mov    (%ecx),%eax
  800eb8:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  800ebf:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ec3:	8d 42 08             	lea    0x8(%edx),%eax
  800ec6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800eca:	83 c2 04             	add    $0x4,%edx
  800ecd:	89 14 24             	mov    %edx,(%esp)
  800ed0:	e8 8b fa ff ff       	call   800960 <memmove>
		(*args->argc)--;
  800ed5:	8b 03                	mov    (%ebx),%eax
  800ed7:	ff 08                	decl   (%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  800ed9:	8b 43 08             	mov    0x8(%ebx),%eax
  800edc:	80 38 2d             	cmpb   $0x2d,(%eax)
  800edf:	75 06                	jne    800ee7 <argnext+0x6a>
  800ee1:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800ee5:	74 0c                	je     800ef3 <argnext+0x76>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  800ee7:	8b 53 08             	mov    0x8(%ebx),%edx
  800eea:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  800eed:	42                   	inc    %edx
  800eee:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  800ef1:	eb 13                	jmp    800f06 <argnext+0x89>

    endofargs:
	args->curarg = 0;
  800ef3:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  800efa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800eff:	eb 05                	jmp    800f06 <argnext+0x89>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  800f01:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  800f06:	83 c4 14             	add    $0x14,%esp
  800f09:	5b                   	pop    %ebx
  800f0a:	5d                   	pop    %ebp
  800f0b:	c3                   	ret    

00800f0c <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  800f0c:	55                   	push   %ebp
  800f0d:	89 e5                	mov    %esp,%ebp
  800f0f:	53                   	push   %ebx
  800f10:	83 ec 14             	sub    $0x14,%esp
  800f13:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  800f16:	8b 43 08             	mov    0x8(%ebx),%eax
  800f19:	85 c0                	test   %eax,%eax
  800f1b:	74 59                	je     800f76 <argnextvalue+0x6a>
		return 0;
	if (*args->curarg) {
  800f1d:	80 38 00             	cmpb   $0x0,(%eax)
  800f20:	74 0c                	je     800f2e <argnextvalue+0x22>
		args->argvalue = args->curarg;
  800f22:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  800f25:	c7 43 08 b1 22 80 00 	movl   $0x8022b1,0x8(%ebx)
  800f2c:	eb 43                	jmp    800f71 <argnextvalue+0x65>
	} else if (*args->argc > 1) {
  800f2e:	8b 03                	mov    (%ebx),%eax
  800f30:	83 38 01             	cmpl   $0x1,(%eax)
  800f33:	7e 2e                	jle    800f63 <argnextvalue+0x57>
		args->argvalue = args->argv[1];
  800f35:	8b 53 04             	mov    0x4(%ebx),%edx
  800f38:	8b 4a 04             	mov    0x4(%edx),%ecx
  800f3b:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800f3e:	8b 00                	mov    (%eax),%eax
  800f40:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  800f47:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f4b:	8d 42 08             	lea    0x8(%edx),%eax
  800f4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f52:	83 c2 04             	add    $0x4,%edx
  800f55:	89 14 24             	mov    %edx,(%esp)
  800f58:	e8 03 fa ff ff       	call   800960 <memmove>
		(*args->argc)--;
  800f5d:	8b 03                	mov    (%ebx),%eax
  800f5f:	ff 08                	decl   (%eax)
  800f61:	eb 0e                	jmp    800f71 <argnextvalue+0x65>
	} else {
		args->argvalue = 0;
  800f63:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  800f6a:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  800f71:	8b 43 0c             	mov    0xc(%ebx),%eax
  800f74:	eb 05                	jmp    800f7b <argnextvalue+0x6f>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  800f76:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  800f7b:	83 c4 14             	add    $0x14,%esp
  800f7e:	5b                   	pop    %ebx
  800f7f:	5d                   	pop    %ebp
  800f80:	c3                   	ret    

00800f81 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  800f81:	55                   	push   %ebp
  800f82:	89 e5                	mov    %esp,%ebp
  800f84:	83 ec 18             	sub    $0x18,%esp
  800f87:	8b 55 08             	mov    0x8(%ebp),%edx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  800f8a:	8b 42 0c             	mov    0xc(%edx),%eax
  800f8d:	85 c0                	test   %eax,%eax
  800f8f:	75 08                	jne    800f99 <argvalue+0x18>
  800f91:	89 14 24             	mov    %edx,(%esp)
  800f94:	e8 73 ff ff ff       	call   800f0c <argnextvalue>
}
  800f99:	c9                   	leave  
  800f9a:	c3                   	ret    
	...

00800f9c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f9c:	55                   	push   %ebp
  800f9d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa2:	05 00 00 00 30       	add    $0x30000000,%eax
  800fa7:	c1 e8 0c             	shr    $0xc,%eax
}
  800faa:	5d                   	pop    %ebp
  800fab:	c3                   	ret    

00800fac <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800fac:	55                   	push   %ebp
  800fad:	89 e5                	mov    %esp,%ebp
  800faf:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800fb2:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb5:	89 04 24             	mov    %eax,(%esp)
  800fb8:	e8 df ff ff ff       	call   800f9c <fd2num>
  800fbd:	05 20 00 0d 00       	add    $0xd0020,%eax
  800fc2:	c1 e0 0c             	shl    $0xc,%eax
}
  800fc5:	c9                   	leave  
  800fc6:	c3                   	ret    

00800fc7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800fc7:	55                   	push   %ebp
  800fc8:	89 e5                	mov    %esp,%ebp
  800fca:	53                   	push   %ebx
  800fcb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800fce:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800fd3:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800fd5:	89 c2                	mov    %eax,%edx
  800fd7:	c1 ea 16             	shr    $0x16,%edx
  800fda:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fe1:	f6 c2 01             	test   $0x1,%dl
  800fe4:	74 11                	je     800ff7 <fd_alloc+0x30>
  800fe6:	89 c2                	mov    %eax,%edx
  800fe8:	c1 ea 0c             	shr    $0xc,%edx
  800feb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ff2:	f6 c2 01             	test   $0x1,%dl
  800ff5:	75 09                	jne    801000 <fd_alloc+0x39>
			*fd_store = fd;
  800ff7:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800ff9:	b8 00 00 00 00       	mov    $0x0,%eax
  800ffe:	eb 17                	jmp    801017 <fd_alloc+0x50>
  801000:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801005:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80100a:	75 c7                	jne    800fd3 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80100c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801012:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801017:	5b                   	pop    %ebx
  801018:	5d                   	pop    %ebp
  801019:	c3                   	ret    

0080101a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80101a:	55                   	push   %ebp
  80101b:	89 e5                	mov    %esp,%ebp
  80101d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801020:	83 f8 1f             	cmp    $0x1f,%eax
  801023:	77 36                	ja     80105b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801025:	05 00 00 0d 00       	add    $0xd0000,%eax
  80102a:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80102d:	89 c2                	mov    %eax,%edx
  80102f:	c1 ea 16             	shr    $0x16,%edx
  801032:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801039:	f6 c2 01             	test   $0x1,%dl
  80103c:	74 24                	je     801062 <fd_lookup+0x48>
  80103e:	89 c2                	mov    %eax,%edx
  801040:	c1 ea 0c             	shr    $0xc,%edx
  801043:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80104a:	f6 c2 01             	test   $0x1,%dl
  80104d:	74 1a                	je     801069 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80104f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801052:	89 02                	mov    %eax,(%edx)
	return 0;
  801054:	b8 00 00 00 00       	mov    $0x0,%eax
  801059:	eb 13                	jmp    80106e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80105b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801060:	eb 0c                	jmp    80106e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801062:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801067:	eb 05                	jmp    80106e <fd_lookup+0x54>
  801069:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80106e:	5d                   	pop    %ebp
  80106f:	c3                   	ret    

00801070 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801070:	55                   	push   %ebp
  801071:	89 e5                	mov    %esp,%ebp
  801073:	53                   	push   %ebx
  801074:	83 ec 14             	sub    $0x14,%esp
  801077:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80107a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  80107d:	ba 00 00 00 00       	mov    $0x0,%edx
  801082:	eb 0e                	jmp    801092 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801084:	39 08                	cmp    %ecx,(%eax)
  801086:	75 09                	jne    801091 <dev_lookup+0x21>
			*dev = devtab[i];
  801088:	89 03                	mov    %eax,(%ebx)
			return 0;
  80108a:	b8 00 00 00 00       	mov    $0x0,%eax
  80108f:	eb 33                	jmp    8010c4 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801091:	42                   	inc    %edx
  801092:	8b 04 95 88 26 80 00 	mov    0x802688(,%edx,4),%eax
  801099:	85 c0                	test   %eax,%eax
  80109b:	75 e7                	jne    801084 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80109d:	a1 04 40 80 00       	mov    0x804004,%eax
  8010a2:	8b 40 48             	mov    0x48(%eax),%eax
  8010a5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010ad:	c7 04 24 0c 26 80 00 	movl   $0x80260c,(%esp)
  8010b4:	e8 83 f1 ff ff       	call   80023c <cprintf>
	*dev = 0;
  8010b9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8010bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8010c4:	83 c4 14             	add    $0x14,%esp
  8010c7:	5b                   	pop    %ebx
  8010c8:	5d                   	pop    %ebp
  8010c9:	c3                   	ret    

008010ca <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8010ca:	55                   	push   %ebp
  8010cb:	89 e5                	mov    %esp,%ebp
  8010cd:	56                   	push   %esi
  8010ce:	53                   	push   %ebx
  8010cf:	83 ec 30             	sub    $0x30,%esp
  8010d2:	8b 75 08             	mov    0x8(%ebp),%esi
  8010d5:	8a 45 0c             	mov    0xc(%ebp),%al
  8010d8:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8010db:	89 34 24             	mov    %esi,(%esp)
  8010de:	e8 b9 fe ff ff       	call   800f9c <fd2num>
  8010e3:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8010e6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8010ea:	89 04 24             	mov    %eax,(%esp)
  8010ed:	e8 28 ff ff ff       	call   80101a <fd_lookup>
  8010f2:	89 c3                	mov    %eax,%ebx
  8010f4:	85 c0                	test   %eax,%eax
  8010f6:	78 05                	js     8010fd <fd_close+0x33>
	    || fd != fd2)
  8010f8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8010fb:	74 0d                	je     80110a <fd_close+0x40>
		return (must_exist ? r : 0);
  8010fd:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801101:	75 46                	jne    801149 <fd_close+0x7f>
  801103:	bb 00 00 00 00       	mov    $0x0,%ebx
  801108:	eb 3f                	jmp    801149 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80110a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80110d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801111:	8b 06                	mov    (%esi),%eax
  801113:	89 04 24             	mov    %eax,(%esp)
  801116:	e8 55 ff ff ff       	call   801070 <dev_lookup>
  80111b:	89 c3                	mov    %eax,%ebx
  80111d:	85 c0                	test   %eax,%eax
  80111f:	78 18                	js     801139 <fd_close+0x6f>
		if (dev->dev_close)
  801121:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801124:	8b 40 10             	mov    0x10(%eax),%eax
  801127:	85 c0                	test   %eax,%eax
  801129:	74 09                	je     801134 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80112b:	89 34 24             	mov    %esi,(%esp)
  80112e:	ff d0                	call   *%eax
  801130:	89 c3                	mov    %eax,%ebx
  801132:	eb 05                	jmp    801139 <fd_close+0x6f>
		else
			r = 0;
  801134:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801139:	89 74 24 04          	mov    %esi,0x4(%esp)
  80113d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801144:	e8 37 fb ff ff       	call   800c80 <sys_page_unmap>
	return r;
}
  801149:	89 d8                	mov    %ebx,%eax
  80114b:	83 c4 30             	add    $0x30,%esp
  80114e:	5b                   	pop    %ebx
  80114f:	5e                   	pop    %esi
  801150:	5d                   	pop    %ebp
  801151:	c3                   	ret    

00801152 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801152:	55                   	push   %ebp
  801153:	89 e5                	mov    %esp,%ebp
  801155:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801158:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80115b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80115f:	8b 45 08             	mov    0x8(%ebp),%eax
  801162:	89 04 24             	mov    %eax,(%esp)
  801165:	e8 b0 fe ff ff       	call   80101a <fd_lookup>
  80116a:	85 c0                	test   %eax,%eax
  80116c:	78 13                	js     801181 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80116e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801175:	00 
  801176:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801179:	89 04 24             	mov    %eax,(%esp)
  80117c:	e8 49 ff ff ff       	call   8010ca <fd_close>
}
  801181:	c9                   	leave  
  801182:	c3                   	ret    

00801183 <close_all>:

void
close_all(void)
{
  801183:	55                   	push   %ebp
  801184:	89 e5                	mov    %esp,%ebp
  801186:	53                   	push   %ebx
  801187:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80118a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80118f:	89 1c 24             	mov    %ebx,(%esp)
  801192:	e8 bb ff ff ff       	call   801152 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801197:	43                   	inc    %ebx
  801198:	83 fb 20             	cmp    $0x20,%ebx
  80119b:	75 f2                	jne    80118f <close_all+0xc>
		close(i);
}
  80119d:	83 c4 14             	add    $0x14,%esp
  8011a0:	5b                   	pop    %ebx
  8011a1:	5d                   	pop    %ebp
  8011a2:	c3                   	ret    

008011a3 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8011a3:	55                   	push   %ebp
  8011a4:	89 e5                	mov    %esp,%ebp
  8011a6:	57                   	push   %edi
  8011a7:	56                   	push   %esi
  8011a8:	53                   	push   %ebx
  8011a9:	83 ec 4c             	sub    $0x4c,%esp
  8011ac:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8011af:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8011b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b9:	89 04 24             	mov    %eax,(%esp)
  8011bc:	e8 59 fe ff ff       	call   80101a <fd_lookup>
  8011c1:	89 c3                	mov    %eax,%ebx
  8011c3:	85 c0                	test   %eax,%eax
  8011c5:	0f 88 e1 00 00 00    	js     8012ac <dup+0x109>
		return r;
	close(newfdnum);
  8011cb:	89 3c 24             	mov    %edi,(%esp)
  8011ce:	e8 7f ff ff ff       	call   801152 <close>

	newfd = INDEX2FD(newfdnum);
  8011d3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8011d9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8011dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011df:	89 04 24             	mov    %eax,(%esp)
  8011e2:	e8 c5 fd ff ff       	call   800fac <fd2data>
  8011e7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8011e9:	89 34 24             	mov    %esi,(%esp)
  8011ec:	e8 bb fd ff ff       	call   800fac <fd2data>
  8011f1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8011f4:	89 d8                	mov    %ebx,%eax
  8011f6:	c1 e8 16             	shr    $0x16,%eax
  8011f9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801200:	a8 01                	test   $0x1,%al
  801202:	74 46                	je     80124a <dup+0xa7>
  801204:	89 d8                	mov    %ebx,%eax
  801206:	c1 e8 0c             	shr    $0xc,%eax
  801209:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801210:	f6 c2 01             	test   $0x1,%dl
  801213:	74 35                	je     80124a <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801215:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80121c:	25 07 0e 00 00       	and    $0xe07,%eax
  801221:	89 44 24 10          	mov    %eax,0x10(%esp)
  801225:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801228:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80122c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801233:	00 
  801234:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801238:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80123f:	e8 e9 f9 ff ff       	call   800c2d <sys_page_map>
  801244:	89 c3                	mov    %eax,%ebx
  801246:	85 c0                	test   %eax,%eax
  801248:	78 3b                	js     801285 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80124a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80124d:	89 c2                	mov    %eax,%edx
  80124f:	c1 ea 0c             	shr    $0xc,%edx
  801252:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801259:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80125f:	89 54 24 10          	mov    %edx,0x10(%esp)
  801263:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801267:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80126e:	00 
  80126f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801273:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80127a:	e8 ae f9 ff ff       	call   800c2d <sys_page_map>
  80127f:	89 c3                	mov    %eax,%ebx
  801281:	85 c0                	test   %eax,%eax
  801283:	79 25                	jns    8012aa <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801285:	89 74 24 04          	mov    %esi,0x4(%esp)
  801289:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801290:	e8 eb f9 ff ff       	call   800c80 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801295:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801298:	89 44 24 04          	mov    %eax,0x4(%esp)
  80129c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012a3:	e8 d8 f9 ff ff       	call   800c80 <sys_page_unmap>
	return r;
  8012a8:	eb 02                	jmp    8012ac <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8012aa:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8012ac:	89 d8                	mov    %ebx,%eax
  8012ae:	83 c4 4c             	add    $0x4c,%esp
  8012b1:	5b                   	pop    %ebx
  8012b2:	5e                   	pop    %esi
  8012b3:	5f                   	pop    %edi
  8012b4:	5d                   	pop    %ebp
  8012b5:	c3                   	ret    

008012b6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8012b6:	55                   	push   %ebp
  8012b7:	89 e5                	mov    %esp,%ebp
  8012b9:	53                   	push   %ebx
  8012ba:	83 ec 24             	sub    $0x24,%esp
  8012bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012c0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012c7:	89 1c 24             	mov    %ebx,(%esp)
  8012ca:	e8 4b fd ff ff       	call   80101a <fd_lookup>
  8012cf:	85 c0                	test   %eax,%eax
  8012d1:	78 6d                	js     801340 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012dd:	8b 00                	mov    (%eax),%eax
  8012df:	89 04 24             	mov    %eax,(%esp)
  8012e2:	e8 89 fd ff ff       	call   801070 <dev_lookup>
  8012e7:	85 c0                	test   %eax,%eax
  8012e9:	78 55                	js     801340 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8012eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ee:	8b 50 08             	mov    0x8(%eax),%edx
  8012f1:	83 e2 03             	and    $0x3,%edx
  8012f4:	83 fa 01             	cmp    $0x1,%edx
  8012f7:	75 23                	jne    80131c <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8012f9:	a1 04 40 80 00       	mov    0x804004,%eax
  8012fe:	8b 40 48             	mov    0x48(%eax),%eax
  801301:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801305:	89 44 24 04          	mov    %eax,0x4(%esp)
  801309:	c7 04 24 4d 26 80 00 	movl   $0x80264d,(%esp)
  801310:	e8 27 ef ff ff       	call   80023c <cprintf>
		return -E_INVAL;
  801315:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80131a:	eb 24                	jmp    801340 <read+0x8a>
	}
	if (!dev->dev_read)
  80131c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80131f:	8b 52 08             	mov    0x8(%edx),%edx
  801322:	85 d2                	test   %edx,%edx
  801324:	74 15                	je     80133b <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801326:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801329:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80132d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801330:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801334:	89 04 24             	mov    %eax,(%esp)
  801337:	ff d2                	call   *%edx
  801339:	eb 05                	jmp    801340 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80133b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801340:	83 c4 24             	add    $0x24,%esp
  801343:	5b                   	pop    %ebx
  801344:	5d                   	pop    %ebp
  801345:	c3                   	ret    

00801346 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801346:	55                   	push   %ebp
  801347:	89 e5                	mov    %esp,%ebp
  801349:	57                   	push   %edi
  80134a:	56                   	push   %esi
  80134b:	53                   	push   %ebx
  80134c:	83 ec 1c             	sub    $0x1c,%esp
  80134f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801352:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801355:	bb 00 00 00 00       	mov    $0x0,%ebx
  80135a:	eb 23                	jmp    80137f <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80135c:	89 f0                	mov    %esi,%eax
  80135e:	29 d8                	sub    %ebx,%eax
  801360:	89 44 24 08          	mov    %eax,0x8(%esp)
  801364:	8b 45 0c             	mov    0xc(%ebp),%eax
  801367:	01 d8                	add    %ebx,%eax
  801369:	89 44 24 04          	mov    %eax,0x4(%esp)
  80136d:	89 3c 24             	mov    %edi,(%esp)
  801370:	e8 41 ff ff ff       	call   8012b6 <read>
		if (m < 0)
  801375:	85 c0                	test   %eax,%eax
  801377:	78 10                	js     801389 <readn+0x43>
			return m;
		if (m == 0)
  801379:	85 c0                	test   %eax,%eax
  80137b:	74 0a                	je     801387 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80137d:	01 c3                	add    %eax,%ebx
  80137f:	39 f3                	cmp    %esi,%ebx
  801381:	72 d9                	jb     80135c <readn+0x16>
  801383:	89 d8                	mov    %ebx,%eax
  801385:	eb 02                	jmp    801389 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801387:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801389:	83 c4 1c             	add    $0x1c,%esp
  80138c:	5b                   	pop    %ebx
  80138d:	5e                   	pop    %esi
  80138e:	5f                   	pop    %edi
  80138f:	5d                   	pop    %ebp
  801390:	c3                   	ret    

00801391 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801391:	55                   	push   %ebp
  801392:	89 e5                	mov    %esp,%ebp
  801394:	53                   	push   %ebx
  801395:	83 ec 24             	sub    $0x24,%esp
  801398:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80139b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80139e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013a2:	89 1c 24             	mov    %ebx,(%esp)
  8013a5:	e8 70 fc ff ff       	call   80101a <fd_lookup>
  8013aa:	85 c0                	test   %eax,%eax
  8013ac:	78 68                	js     801416 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013b8:	8b 00                	mov    (%eax),%eax
  8013ba:	89 04 24             	mov    %eax,(%esp)
  8013bd:	e8 ae fc ff ff       	call   801070 <dev_lookup>
  8013c2:	85 c0                	test   %eax,%eax
  8013c4:	78 50                	js     801416 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013c9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013cd:	75 23                	jne    8013f2 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8013cf:	a1 04 40 80 00       	mov    0x804004,%eax
  8013d4:	8b 40 48             	mov    0x48(%eax),%eax
  8013d7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013df:	c7 04 24 69 26 80 00 	movl   $0x802669,(%esp)
  8013e6:	e8 51 ee ff ff       	call   80023c <cprintf>
		return -E_INVAL;
  8013eb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013f0:	eb 24                	jmp    801416 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8013f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013f5:	8b 52 0c             	mov    0xc(%edx),%edx
  8013f8:	85 d2                	test   %edx,%edx
  8013fa:	74 15                	je     801411 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8013fc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8013ff:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801403:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801406:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80140a:	89 04 24             	mov    %eax,(%esp)
  80140d:	ff d2                	call   *%edx
  80140f:	eb 05                	jmp    801416 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801411:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801416:	83 c4 24             	add    $0x24,%esp
  801419:	5b                   	pop    %ebx
  80141a:	5d                   	pop    %ebp
  80141b:	c3                   	ret    

0080141c <seek>:

int
seek(int fdnum, off_t offset)
{
  80141c:	55                   	push   %ebp
  80141d:	89 e5                	mov    %esp,%ebp
  80141f:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801422:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801425:	89 44 24 04          	mov    %eax,0x4(%esp)
  801429:	8b 45 08             	mov    0x8(%ebp),%eax
  80142c:	89 04 24             	mov    %eax,(%esp)
  80142f:	e8 e6 fb ff ff       	call   80101a <fd_lookup>
  801434:	85 c0                	test   %eax,%eax
  801436:	78 0e                	js     801446 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801438:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80143b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80143e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801441:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801446:	c9                   	leave  
  801447:	c3                   	ret    

00801448 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801448:	55                   	push   %ebp
  801449:	89 e5                	mov    %esp,%ebp
  80144b:	53                   	push   %ebx
  80144c:	83 ec 24             	sub    $0x24,%esp
  80144f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801452:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801455:	89 44 24 04          	mov    %eax,0x4(%esp)
  801459:	89 1c 24             	mov    %ebx,(%esp)
  80145c:	e8 b9 fb ff ff       	call   80101a <fd_lookup>
  801461:	85 c0                	test   %eax,%eax
  801463:	78 61                	js     8014c6 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801465:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801468:	89 44 24 04          	mov    %eax,0x4(%esp)
  80146c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80146f:	8b 00                	mov    (%eax),%eax
  801471:	89 04 24             	mov    %eax,(%esp)
  801474:	e8 f7 fb ff ff       	call   801070 <dev_lookup>
  801479:	85 c0                	test   %eax,%eax
  80147b:	78 49                	js     8014c6 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80147d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801480:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801484:	75 23                	jne    8014a9 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801486:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80148b:	8b 40 48             	mov    0x48(%eax),%eax
  80148e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801492:	89 44 24 04          	mov    %eax,0x4(%esp)
  801496:	c7 04 24 2c 26 80 00 	movl   $0x80262c,(%esp)
  80149d:	e8 9a ed ff ff       	call   80023c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8014a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014a7:	eb 1d                	jmp    8014c6 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8014a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014ac:	8b 52 18             	mov    0x18(%edx),%edx
  8014af:	85 d2                	test   %edx,%edx
  8014b1:	74 0e                	je     8014c1 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8014b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014b6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8014ba:	89 04 24             	mov    %eax,(%esp)
  8014bd:	ff d2                	call   *%edx
  8014bf:	eb 05                	jmp    8014c6 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8014c1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8014c6:	83 c4 24             	add    $0x24,%esp
  8014c9:	5b                   	pop    %ebx
  8014ca:	5d                   	pop    %ebp
  8014cb:	c3                   	ret    

008014cc <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8014cc:	55                   	push   %ebp
  8014cd:	89 e5                	mov    %esp,%ebp
  8014cf:	53                   	push   %ebx
  8014d0:	83 ec 24             	sub    $0x24,%esp
  8014d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014d6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e0:	89 04 24             	mov    %eax,(%esp)
  8014e3:	e8 32 fb ff ff       	call   80101a <fd_lookup>
  8014e8:	85 c0                	test   %eax,%eax
  8014ea:	78 52                	js     80153e <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014f6:	8b 00                	mov    (%eax),%eax
  8014f8:	89 04 24             	mov    %eax,(%esp)
  8014fb:	e8 70 fb ff ff       	call   801070 <dev_lookup>
  801500:	85 c0                	test   %eax,%eax
  801502:	78 3a                	js     80153e <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801504:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801507:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80150b:	74 2c                	je     801539 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80150d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801510:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801517:	00 00 00 
	stat->st_isdir = 0;
  80151a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801521:	00 00 00 
	stat->st_dev = dev;
  801524:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80152a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80152e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801531:	89 14 24             	mov    %edx,(%esp)
  801534:	ff 50 14             	call   *0x14(%eax)
  801537:	eb 05                	jmp    80153e <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801539:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80153e:	83 c4 24             	add    $0x24,%esp
  801541:	5b                   	pop    %ebx
  801542:	5d                   	pop    %ebp
  801543:	c3                   	ret    

00801544 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801544:	55                   	push   %ebp
  801545:	89 e5                	mov    %esp,%ebp
  801547:	56                   	push   %esi
  801548:	53                   	push   %ebx
  801549:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80154c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801553:	00 
  801554:	8b 45 08             	mov    0x8(%ebp),%eax
  801557:	89 04 24             	mov    %eax,(%esp)
  80155a:	e8 2d 02 00 00       	call   80178c <open>
  80155f:	89 c3                	mov    %eax,%ebx
  801561:	85 c0                	test   %eax,%eax
  801563:	78 1b                	js     801580 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801565:	8b 45 0c             	mov    0xc(%ebp),%eax
  801568:	89 44 24 04          	mov    %eax,0x4(%esp)
  80156c:	89 1c 24             	mov    %ebx,(%esp)
  80156f:	e8 58 ff ff ff       	call   8014cc <fstat>
  801574:	89 c6                	mov    %eax,%esi
	close(fd);
  801576:	89 1c 24             	mov    %ebx,(%esp)
  801579:	e8 d4 fb ff ff       	call   801152 <close>
	return r;
  80157e:	89 f3                	mov    %esi,%ebx
}
  801580:	89 d8                	mov    %ebx,%eax
  801582:	83 c4 10             	add    $0x10,%esp
  801585:	5b                   	pop    %ebx
  801586:	5e                   	pop    %esi
  801587:	5d                   	pop    %ebp
  801588:	c3                   	ret    
  801589:	00 00                	add    %al,(%eax)
	...

0080158c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80158c:	55                   	push   %ebp
  80158d:	89 e5                	mov    %esp,%ebp
  80158f:	56                   	push   %esi
  801590:	53                   	push   %ebx
  801591:	83 ec 10             	sub    $0x10,%esp
  801594:	89 c3                	mov    %eax,%ebx
  801596:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801598:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80159f:	75 11                	jne    8015b2 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8015a1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8015a8:	e8 fe 09 00 00       	call   801fab <ipc_find_env>
  8015ad:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8015b2:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8015b9:	00 
  8015ba:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8015c1:	00 
  8015c2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015c6:	a1 00 40 80 00       	mov    0x804000,%eax
  8015cb:	89 04 24             	mov    %eax,(%esp)
  8015ce:	e8 6a 09 00 00       	call   801f3d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8015d3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015da:	00 
  8015db:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015e6:	e8 e9 08 00 00       	call   801ed4 <ipc_recv>
}
  8015eb:	83 c4 10             	add    $0x10,%esp
  8015ee:	5b                   	pop    %ebx
  8015ef:	5e                   	pop    %esi
  8015f0:	5d                   	pop    %ebp
  8015f1:	c3                   	ret    

008015f2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8015f2:	55                   	push   %ebp
  8015f3:	89 e5                	mov    %esp,%ebp
  8015f5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8015f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8015fb:	8b 40 0c             	mov    0xc(%eax),%eax
  8015fe:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801603:	8b 45 0c             	mov    0xc(%ebp),%eax
  801606:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80160b:	ba 00 00 00 00       	mov    $0x0,%edx
  801610:	b8 02 00 00 00       	mov    $0x2,%eax
  801615:	e8 72 ff ff ff       	call   80158c <fsipc>
}
  80161a:	c9                   	leave  
  80161b:	c3                   	ret    

0080161c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80161c:	55                   	push   %ebp
  80161d:	89 e5                	mov    %esp,%ebp
  80161f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801622:	8b 45 08             	mov    0x8(%ebp),%eax
  801625:	8b 40 0c             	mov    0xc(%eax),%eax
  801628:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80162d:	ba 00 00 00 00       	mov    $0x0,%edx
  801632:	b8 06 00 00 00       	mov    $0x6,%eax
  801637:	e8 50 ff ff ff       	call   80158c <fsipc>
}
  80163c:	c9                   	leave  
  80163d:	c3                   	ret    

0080163e <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80163e:	55                   	push   %ebp
  80163f:	89 e5                	mov    %esp,%ebp
  801641:	53                   	push   %ebx
  801642:	83 ec 14             	sub    $0x14,%esp
  801645:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801648:	8b 45 08             	mov    0x8(%ebp),%eax
  80164b:	8b 40 0c             	mov    0xc(%eax),%eax
  80164e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801653:	ba 00 00 00 00       	mov    $0x0,%edx
  801658:	b8 05 00 00 00       	mov    $0x5,%eax
  80165d:	e8 2a ff ff ff       	call   80158c <fsipc>
  801662:	85 c0                	test   %eax,%eax
  801664:	78 2b                	js     801691 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801666:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80166d:	00 
  80166e:	89 1c 24             	mov    %ebx,(%esp)
  801671:	e8 71 f1 ff ff       	call   8007e7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801676:	a1 80 50 80 00       	mov    0x805080,%eax
  80167b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801681:	a1 84 50 80 00       	mov    0x805084,%eax
  801686:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80168c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801691:	83 c4 14             	add    $0x14,%esp
  801694:	5b                   	pop    %ebx
  801695:	5d                   	pop    %ebp
  801696:	c3                   	ret    

00801697 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801697:	55                   	push   %ebp
  801698:	89 e5                	mov    %esp,%ebp
  80169a:	83 ec 18             	sub    $0x18,%esp
  80169d:	8b 55 10             	mov    0x10(%ebp),%edx
  8016a0:	89 d0                	mov    %edx,%eax
  8016a2:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  8016a8:	76 05                	jbe    8016af <devfile_write+0x18>
  8016aa:	b8 00 10 00 00       	mov    $0x1000,%eax
	//panic("devfile_write not implemented");
	int r;
	//uint32_t maxsize = BLKSIZE - sizeof(int) - sizeof(size_t);	
	if (n > BLKSIZE)
		n = BLKSIZE;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8016af:	8b 55 08             	mov    0x8(%ebp),%edx
  8016b2:	8b 52 0c             	mov    0xc(%edx),%edx
  8016b5:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8016bb:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8016c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016cb:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  8016d2:	e8 89 f2 ff ff       	call   800960 <memmove>
	 
	return fsipc(FSREQ_WRITE, NULL);
  8016d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8016dc:	b8 04 00 00 00       	mov    $0x4,%eax
  8016e1:	e8 a6 fe ff ff       	call   80158c <fsipc>
}
  8016e6:	c9                   	leave  
  8016e7:	c3                   	ret    

008016e8 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8016e8:	55                   	push   %ebp
  8016e9:	89 e5                	mov    %esp,%ebp
  8016eb:	56                   	push   %esi
  8016ec:	53                   	push   %ebx
  8016ed:	83 ec 10             	sub    $0x10,%esp
  8016f0:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8016f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f6:	8b 40 0c             	mov    0xc(%eax),%eax
  8016f9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8016fe:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801704:	ba 00 00 00 00       	mov    $0x0,%edx
  801709:	b8 03 00 00 00       	mov    $0x3,%eax
  80170e:	e8 79 fe ff ff       	call   80158c <fsipc>
  801713:	89 c3                	mov    %eax,%ebx
  801715:	85 c0                	test   %eax,%eax
  801717:	78 6a                	js     801783 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801719:	39 c6                	cmp    %eax,%esi
  80171b:	73 24                	jae    801741 <devfile_read+0x59>
  80171d:	c7 44 24 0c 98 26 80 	movl   $0x802698,0xc(%esp)
  801724:	00 
  801725:	c7 44 24 08 9f 26 80 	movl   $0x80269f,0x8(%esp)
  80172c:	00 
  80172d:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801734:	00 
  801735:	c7 04 24 b4 26 80 00 	movl   $0x8026b4,(%esp)
  80173c:	e8 3b 07 00 00       	call   801e7c <_panic>
	assert(r <= PGSIZE);
  801741:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801746:	7e 24                	jle    80176c <devfile_read+0x84>
  801748:	c7 44 24 0c bf 26 80 	movl   $0x8026bf,0xc(%esp)
  80174f:	00 
  801750:	c7 44 24 08 9f 26 80 	movl   $0x80269f,0x8(%esp)
  801757:	00 
  801758:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  80175f:	00 
  801760:	c7 04 24 b4 26 80 00 	movl   $0x8026b4,(%esp)
  801767:	e8 10 07 00 00       	call   801e7c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80176c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801770:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801777:	00 
  801778:	8b 45 0c             	mov    0xc(%ebp),%eax
  80177b:	89 04 24             	mov    %eax,(%esp)
  80177e:	e8 dd f1 ff ff       	call   800960 <memmove>
	return r;
}
  801783:	89 d8                	mov    %ebx,%eax
  801785:	83 c4 10             	add    $0x10,%esp
  801788:	5b                   	pop    %ebx
  801789:	5e                   	pop    %esi
  80178a:	5d                   	pop    %ebp
  80178b:	c3                   	ret    

0080178c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80178c:	55                   	push   %ebp
  80178d:	89 e5                	mov    %esp,%ebp
  80178f:	56                   	push   %esi
  801790:	53                   	push   %ebx
  801791:	83 ec 20             	sub    $0x20,%esp
  801794:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801797:	89 34 24             	mov    %esi,(%esp)
  80179a:	e8 15 f0 ff ff       	call   8007b4 <strlen>
  80179f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017a4:	7f 60                	jg     801806 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017a9:	89 04 24             	mov    %eax,(%esp)
  8017ac:	e8 16 f8 ff ff       	call   800fc7 <fd_alloc>
  8017b1:	89 c3                	mov    %eax,%ebx
  8017b3:	85 c0                	test   %eax,%eax
  8017b5:	78 54                	js     80180b <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017b7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017bb:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8017c2:	e8 20 f0 ff ff       	call   8007e7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017ca:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017cf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017d2:	b8 01 00 00 00       	mov    $0x1,%eax
  8017d7:	e8 b0 fd ff ff       	call   80158c <fsipc>
  8017dc:	89 c3                	mov    %eax,%ebx
  8017de:	85 c0                	test   %eax,%eax
  8017e0:	79 15                	jns    8017f7 <open+0x6b>
		fd_close(fd, 0);
  8017e2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8017e9:	00 
  8017ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017ed:	89 04 24             	mov    %eax,(%esp)
  8017f0:	e8 d5 f8 ff ff       	call   8010ca <fd_close>
		return r;
  8017f5:	eb 14                	jmp    80180b <open+0x7f>
	}

	return fd2num(fd);
  8017f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017fa:	89 04 24             	mov    %eax,(%esp)
  8017fd:	e8 9a f7 ff ff       	call   800f9c <fd2num>
  801802:	89 c3                	mov    %eax,%ebx
  801804:	eb 05                	jmp    80180b <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801806:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80180b:	89 d8                	mov    %ebx,%eax
  80180d:	83 c4 20             	add    $0x20,%esp
  801810:	5b                   	pop    %ebx
  801811:	5e                   	pop    %esi
  801812:	5d                   	pop    %ebp
  801813:	c3                   	ret    

00801814 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801814:	55                   	push   %ebp
  801815:	89 e5                	mov    %esp,%ebp
  801817:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80181a:	ba 00 00 00 00       	mov    $0x0,%edx
  80181f:	b8 08 00 00 00       	mov    $0x8,%eax
  801824:	e8 63 fd ff ff       	call   80158c <fsipc>
}
  801829:	c9                   	leave  
  80182a:	c3                   	ret    
	...

0080182c <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  80182c:	55                   	push   %ebp
  80182d:	89 e5                	mov    %esp,%ebp
  80182f:	53                   	push   %ebx
  801830:	83 ec 14             	sub    $0x14,%esp
  801833:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  801835:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801839:	7e 32                	jle    80186d <writebuf+0x41>
		ssize_t result = write(b->fd, b->buf, b->idx);
  80183b:	8b 40 04             	mov    0x4(%eax),%eax
  80183e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801842:	8d 43 10             	lea    0x10(%ebx),%eax
  801845:	89 44 24 04          	mov    %eax,0x4(%esp)
  801849:	8b 03                	mov    (%ebx),%eax
  80184b:	89 04 24             	mov    %eax,(%esp)
  80184e:	e8 3e fb ff ff       	call   801391 <write>
		if (result > 0)
  801853:	85 c0                	test   %eax,%eax
  801855:	7e 03                	jle    80185a <writebuf+0x2e>
			b->result += result;
  801857:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80185a:	39 43 04             	cmp    %eax,0x4(%ebx)
  80185d:	74 0e                	je     80186d <writebuf+0x41>
			b->error = (result < 0 ? result : 0);
  80185f:	89 c2                	mov    %eax,%edx
  801861:	85 c0                	test   %eax,%eax
  801863:	7e 05                	jle    80186a <writebuf+0x3e>
  801865:	ba 00 00 00 00       	mov    $0x0,%edx
  80186a:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  80186d:	83 c4 14             	add    $0x14,%esp
  801870:	5b                   	pop    %ebx
  801871:	5d                   	pop    %ebp
  801872:	c3                   	ret    

00801873 <putch>:

static void
putch(int ch, void *thunk)
{
  801873:	55                   	push   %ebp
  801874:	89 e5                	mov    %esp,%ebp
  801876:	53                   	push   %ebx
  801877:	83 ec 04             	sub    $0x4,%esp
  80187a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  80187d:	8b 43 04             	mov    0x4(%ebx),%eax
  801880:	8b 55 08             	mov    0x8(%ebp),%edx
  801883:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  801887:	40                   	inc    %eax
  801888:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  80188b:	3d 00 01 00 00       	cmp    $0x100,%eax
  801890:	75 0e                	jne    8018a0 <putch+0x2d>
		writebuf(b);
  801892:	89 d8                	mov    %ebx,%eax
  801894:	e8 93 ff ff ff       	call   80182c <writebuf>
		b->idx = 0;
  801899:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8018a0:	83 c4 04             	add    $0x4,%esp
  8018a3:	5b                   	pop    %ebx
  8018a4:	5d                   	pop    %ebp
  8018a5:	c3                   	ret    

008018a6 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8018a6:	55                   	push   %ebp
  8018a7:	89 e5                	mov    %esp,%ebp
  8018a9:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  8018af:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b2:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8018b8:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8018bf:	00 00 00 
	b.result = 0;
  8018c2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8018c9:	00 00 00 
	b.error = 1;
  8018cc:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8018d3:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8018d6:	8b 45 10             	mov    0x10(%ebp),%eax
  8018d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018e0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018e4:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8018ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ee:	c7 04 24 73 18 80 00 	movl   $0x801873,(%esp)
  8018f5:	e8 a4 ea ff ff       	call   80039e <vprintfmt>
	if (b.idx > 0)
  8018fa:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801901:	7e 0b                	jle    80190e <vfprintf+0x68>
		writebuf(&b);
  801903:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801909:	e8 1e ff ff ff       	call   80182c <writebuf>

	return (b.result ? b.result : b.error);
  80190e:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801914:	85 c0                	test   %eax,%eax
  801916:	75 06                	jne    80191e <vfprintf+0x78>
  801918:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  80191e:	c9                   	leave  
  80191f:	c3                   	ret    

00801920 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801920:	55                   	push   %ebp
  801921:	89 e5                	mov    %esp,%ebp
  801923:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801926:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801929:	89 44 24 08          	mov    %eax,0x8(%esp)
  80192d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801930:	89 44 24 04          	mov    %eax,0x4(%esp)
  801934:	8b 45 08             	mov    0x8(%ebp),%eax
  801937:	89 04 24             	mov    %eax,(%esp)
  80193a:	e8 67 ff ff ff       	call   8018a6 <vfprintf>
	va_end(ap);

	return cnt;
}
  80193f:	c9                   	leave  
  801940:	c3                   	ret    

00801941 <printf>:

int
printf(const char *fmt, ...)
{
  801941:	55                   	push   %ebp
  801942:	89 e5                	mov    %esp,%ebp
  801944:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801947:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  80194a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80194e:	8b 45 08             	mov    0x8(%ebp),%eax
  801951:	89 44 24 04          	mov    %eax,0x4(%esp)
  801955:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80195c:	e8 45 ff ff ff       	call   8018a6 <vfprintf>
	va_end(ap);

	return cnt;
}
  801961:	c9                   	leave  
  801962:	c3                   	ret    
	...

00801964 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801964:	55                   	push   %ebp
  801965:	89 e5                	mov    %esp,%ebp
  801967:	56                   	push   %esi
  801968:	53                   	push   %ebx
  801969:	83 ec 10             	sub    $0x10,%esp
  80196c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80196f:	8b 45 08             	mov    0x8(%ebp),%eax
  801972:	89 04 24             	mov    %eax,(%esp)
  801975:	e8 32 f6 ff ff       	call   800fac <fd2data>
  80197a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  80197c:	c7 44 24 04 cb 26 80 	movl   $0x8026cb,0x4(%esp)
  801983:	00 
  801984:	89 34 24             	mov    %esi,(%esp)
  801987:	e8 5b ee ff ff       	call   8007e7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80198c:	8b 43 04             	mov    0x4(%ebx),%eax
  80198f:	2b 03                	sub    (%ebx),%eax
  801991:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801997:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80199e:	00 00 00 
	stat->st_dev = &devpipe;
  8019a1:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  8019a8:	30 80 00 
	return 0;
}
  8019ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b0:	83 c4 10             	add    $0x10,%esp
  8019b3:	5b                   	pop    %ebx
  8019b4:	5e                   	pop    %esi
  8019b5:	5d                   	pop    %ebp
  8019b6:	c3                   	ret    

008019b7 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019b7:	55                   	push   %ebp
  8019b8:	89 e5                	mov    %esp,%ebp
  8019ba:	53                   	push   %ebx
  8019bb:	83 ec 14             	sub    $0x14,%esp
  8019be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019c1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019c5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019cc:	e8 af f2 ff ff       	call   800c80 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019d1:	89 1c 24             	mov    %ebx,(%esp)
  8019d4:	e8 d3 f5 ff ff       	call   800fac <fd2data>
  8019d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019dd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019e4:	e8 97 f2 ff ff       	call   800c80 <sys_page_unmap>
}
  8019e9:	83 c4 14             	add    $0x14,%esp
  8019ec:	5b                   	pop    %ebx
  8019ed:	5d                   	pop    %ebp
  8019ee:	c3                   	ret    

008019ef <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019ef:	55                   	push   %ebp
  8019f0:	89 e5                	mov    %esp,%ebp
  8019f2:	57                   	push   %edi
  8019f3:	56                   	push   %esi
  8019f4:	53                   	push   %ebx
  8019f5:	83 ec 2c             	sub    $0x2c,%esp
  8019f8:	89 c7                	mov    %eax,%edi
  8019fa:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019fd:	a1 04 40 80 00       	mov    0x804004,%eax
  801a02:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a05:	89 3c 24             	mov    %edi,(%esp)
  801a08:	e8 e3 05 00 00       	call   801ff0 <pageref>
  801a0d:	89 c6                	mov    %eax,%esi
  801a0f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a12:	89 04 24             	mov    %eax,(%esp)
  801a15:	e8 d6 05 00 00       	call   801ff0 <pageref>
  801a1a:	39 c6                	cmp    %eax,%esi
  801a1c:	0f 94 c0             	sete   %al
  801a1f:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801a22:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a28:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a2b:	39 cb                	cmp    %ecx,%ebx
  801a2d:	75 08                	jne    801a37 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801a2f:	83 c4 2c             	add    $0x2c,%esp
  801a32:	5b                   	pop    %ebx
  801a33:	5e                   	pop    %esi
  801a34:	5f                   	pop    %edi
  801a35:	5d                   	pop    %ebp
  801a36:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801a37:	83 f8 01             	cmp    $0x1,%eax
  801a3a:	75 c1                	jne    8019fd <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a3c:	8b 42 58             	mov    0x58(%edx),%eax
  801a3f:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801a46:	00 
  801a47:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a4b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a4f:	c7 04 24 d2 26 80 00 	movl   $0x8026d2,(%esp)
  801a56:	e8 e1 e7 ff ff       	call   80023c <cprintf>
  801a5b:	eb a0                	jmp    8019fd <_pipeisclosed+0xe>

00801a5d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a5d:	55                   	push   %ebp
  801a5e:	89 e5                	mov    %esp,%ebp
  801a60:	57                   	push   %edi
  801a61:	56                   	push   %esi
  801a62:	53                   	push   %ebx
  801a63:	83 ec 1c             	sub    $0x1c,%esp
  801a66:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a69:	89 34 24             	mov    %esi,(%esp)
  801a6c:	e8 3b f5 ff ff       	call   800fac <fd2data>
  801a71:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a73:	bf 00 00 00 00       	mov    $0x0,%edi
  801a78:	eb 3c                	jmp    801ab6 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a7a:	89 da                	mov    %ebx,%edx
  801a7c:	89 f0                	mov    %esi,%eax
  801a7e:	e8 6c ff ff ff       	call   8019ef <_pipeisclosed>
  801a83:	85 c0                	test   %eax,%eax
  801a85:	75 38                	jne    801abf <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a87:	e8 2e f1 ff ff       	call   800bba <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a8c:	8b 43 04             	mov    0x4(%ebx),%eax
  801a8f:	8b 13                	mov    (%ebx),%edx
  801a91:	83 c2 20             	add    $0x20,%edx
  801a94:	39 d0                	cmp    %edx,%eax
  801a96:	73 e2                	jae    801a7a <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a98:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a9b:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801a9e:	89 c2                	mov    %eax,%edx
  801aa0:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801aa6:	79 05                	jns    801aad <devpipe_write+0x50>
  801aa8:	4a                   	dec    %edx
  801aa9:	83 ca e0             	or     $0xffffffe0,%edx
  801aac:	42                   	inc    %edx
  801aad:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ab1:	40                   	inc    %eax
  801ab2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ab5:	47                   	inc    %edi
  801ab6:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ab9:	75 d1                	jne    801a8c <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801abb:	89 f8                	mov    %edi,%eax
  801abd:	eb 05                	jmp    801ac4 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801abf:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ac4:	83 c4 1c             	add    $0x1c,%esp
  801ac7:	5b                   	pop    %ebx
  801ac8:	5e                   	pop    %esi
  801ac9:	5f                   	pop    %edi
  801aca:	5d                   	pop    %ebp
  801acb:	c3                   	ret    

00801acc <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801acc:	55                   	push   %ebp
  801acd:	89 e5                	mov    %esp,%ebp
  801acf:	57                   	push   %edi
  801ad0:	56                   	push   %esi
  801ad1:	53                   	push   %ebx
  801ad2:	83 ec 1c             	sub    $0x1c,%esp
  801ad5:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ad8:	89 3c 24             	mov    %edi,(%esp)
  801adb:	e8 cc f4 ff ff       	call   800fac <fd2data>
  801ae0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ae2:	be 00 00 00 00       	mov    $0x0,%esi
  801ae7:	eb 3a                	jmp    801b23 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ae9:	85 f6                	test   %esi,%esi
  801aeb:	74 04                	je     801af1 <devpipe_read+0x25>
				return i;
  801aed:	89 f0                	mov    %esi,%eax
  801aef:	eb 40                	jmp    801b31 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801af1:	89 da                	mov    %ebx,%edx
  801af3:	89 f8                	mov    %edi,%eax
  801af5:	e8 f5 fe ff ff       	call   8019ef <_pipeisclosed>
  801afa:	85 c0                	test   %eax,%eax
  801afc:	75 2e                	jne    801b2c <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801afe:	e8 b7 f0 ff ff       	call   800bba <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b03:	8b 03                	mov    (%ebx),%eax
  801b05:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b08:	74 df                	je     801ae9 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b0a:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801b0f:	79 05                	jns    801b16 <devpipe_read+0x4a>
  801b11:	48                   	dec    %eax
  801b12:	83 c8 e0             	or     $0xffffffe0,%eax
  801b15:	40                   	inc    %eax
  801b16:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801b1a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b1d:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801b20:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b22:	46                   	inc    %esi
  801b23:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b26:	75 db                	jne    801b03 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b28:	89 f0                	mov    %esi,%eax
  801b2a:	eb 05                	jmp    801b31 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b2c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b31:	83 c4 1c             	add    $0x1c,%esp
  801b34:	5b                   	pop    %ebx
  801b35:	5e                   	pop    %esi
  801b36:	5f                   	pop    %edi
  801b37:	5d                   	pop    %ebp
  801b38:	c3                   	ret    

00801b39 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b39:	55                   	push   %ebp
  801b3a:	89 e5                	mov    %esp,%ebp
  801b3c:	57                   	push   %edi
  801b3d:	56                   	push   %esi
  801b3e:	53                   	push   %ebx
  801b3f:	83 ec 3c             	sub    $0x3c,%esp
  801b42:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b45:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801b48:	89 04 24             	mov    %eax,(%esp)
  801b4b:	e8 77 f4 ff ff       	call   800fc7 <fd_alloc>
  801b50:	89 c3                	mov    %eax,%ebx
  801b52:	85 c0                	test   %eax,%eax
  801b54:	0f 88 45 01 00 00    	js     801c9f <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b5a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801b61:	00 
  801b62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b65:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b69:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b70:	e8 64 f0 ff ff       	call   800bd9 <sys_page_alloc>
  801b75:	89 c3                	mov    %eax,%ebx
  801b77:	85 c0                	test   %eax,%eax
  801b79:	0f 88 20 01 00 00    	js     801c9f <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b7f:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801b82:	89 04 24             	mov    %eax,(%esp)
  801b85:	e8 3d f4 ff ff       	call   800fc7 <fd_alloc>
  801b8a:	89 c3                	mov    %eax,%ebx
  801b8c:	85 c0                	test   %eax,%eax
  801b8e:	0f 88 f8 00 00 00    	js     801c8c <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b94:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801b9b:	00 
  801b9c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b9f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ba3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801baa:	e8 2a f0 ff ff       	call   800bd9 <sys_page_alloc>
  801baf:	89 c3                	mov    %eax,%ebx
  801bb1:	85 c0                	test   %eax,%eax
  801bb3:	0f 88 d3 00 00 00    	js     801c8c <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bb9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bbc:	89 04 24             	mov    %eax,(%esp)
  801bbf:	e8 e8 f3 ff ff       	call   800fac <fd2data>
  801bc4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bc6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801bcd:	00 
  801bce:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bd2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bd9:	e8 fb ef ff ff       	call   800bd9 <sys_page_alloc>
  801bde:	89 c3                	mov    %eax,%ebx
  801be0:	85 c0                	test   %eax,%eax
  801be2:	0f 88 91 00 00 00    	js     801c79 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801be8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801beb:	89 04 24             	mov    %eax,(%esp)
  801bee:	e8 b9 f3 ff ff       	call   800fac <fd2data>
  801bf3:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801bfa:	00 
  801bfb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bff:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c06:	00 
  801c07:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c0b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c12:	e8 16 f0 ff ff       	call   800c2d <sys_page_map>
  801c17:	89 c3                	mov    %eax,%ebx
  801c19:	85 c0                	test   %eax,%eax
  801c1b:	78 4c                	js     801c69 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c1d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c23:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c26:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c28:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c2b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c32:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c38:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c3b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c3d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c40:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c47:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c4a:	89 04 24             	mov    %eax,(%esp)
  801c4d:	e8 4a f3 ff ff       	call   800f9c <fd2num>
  801c52:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801c54:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c57:	89 04 24             	mov    %eax,(%esp)
  801c5a:	e8 3d f3 ff ff       	call   800f9c <fd2num>
  801c5f:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801c62:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c67:	eb 36                	jmp    801c9f <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801c69:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c6d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c74:	e8 07 f0 ff ff       	call   800c80 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801c79:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c7c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c80:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c87:	e8 f4 ef ff ff       	call   800c80 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801c8c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c8f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c93:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c9a:	e8 e1 ef ff ff       	call   800c80 <sys_page_unmap>
    err:
	return r;
}
  801c9f:	89 d8                	mov    %ebx,%eax
  801ca1:	83 c4 3c             	add    $0x3c,%esp
  801ca4:	5b                   	pop    %ebx
  801ca5:	5e                   	pop    %esi
  801ca6:	5f                   	pop    %edi
  801ca7:	5d                   	pop    %ebp
  801ca8:	c3                   	ret    

00801ca9 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ca9:	55                   	push   %ebp
  801caa:	89 e5                	mov    %esp,%ebp
  801cac:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801caf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cb2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cb6:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb9:	89 04 24             	mov    %eax,(%esp)
  801cbc:	e8 59 f3 ff ff       	call   80101a <fd_lookup>
  801cc1:	85 c0                	test   %eax,%eax
  801cc3:	78 15                	js     801cda <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801cc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc8:	89 04 24             	mov    %eax,(%esp)
  801ccb:	e8 dc f2 ff ff       	call   800fac <fd2data>
	return _pipeisclosed(fd, p);
  801cd0:	89 c2                	mov    %eax,%edx
  801cd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd5:	e8 15 fd ff ff       	call   8019ef <_pipeisclosed>
}
  801cda:	c9                   	leave  
  801cdb:	c3                   	ret    

00801cdc <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801cdc:	55                   	push   %ebp
  801cdd:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801cdf:	b8 00 00 00 00       	mov    $0x0,%eax
  801ce4:	5d                   	pop    %ebp
  801ce5:	c3                   	ret    

00801ce6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ce6:	55                   	push   %ebp
  801ce7:	89 e5                	mov    %esp,%ebp
  801ce9:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801cec:	c7 44 24 04 ea 26 80 	movl   $0x8026ea,0x4(%esp)
  801cf3:	00 
  801cf4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cf7:	89 04 24             	mov    %eax,(%esp)
  801cfa:	e8 e8 ea ff ff       	call   8007e7 <strcpy>
	return 0;
}
  801cff:	b8 00 00 00 00       	mov    $0x0,%eax
  801d04:	c9                   	leave  
  801d05:	c3                   	ret    

00801d06 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d06:	55                   	push   %ebp
  801d07:	89 e5                	mov    %esp,%ebp
  801d09:	57                   	push   %edi
  801d0a:	56                   	push   %esi
  801d0b:	53                   	push   %ebx
  801d0c:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d12:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d17:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d1d:	eb 30                	jmp    801d4f <devcons_write+0x49>
		m = n - tot;
  801d1f:	8b 75 10             	mov    0x10(%ebp),%esi
  801d22:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801d24:	83 fe 7f             	cmp    $0x7f,%esi
  801d27:	76 05                	jbe    801d2e <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801d29:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801d2e:	89 74 24 08          	mov    %esi,0x8(%esp)
  801d32:	03 45 0c             	add    0xc(%ebp),%eax
  801d35:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d39:	89 3c 24             	mov    %edi,(%esp)
  801d3c:	e8 1f ec ff ff       	call   800960 <memmove>
		sys_cputs(buf, m);
  801d41:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d45:	89 3c 24             	mov    %edi,(%esp)
  801d48:	e8 bf ed ff ff       	call   800b0c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d4d:	01 f3                	add    %esi,%ebx
  801d4f:	89 d8                	mov    %ebx,%eax
  801d51:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d54:	72 c9                	jb     801d1f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d56:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801d5c:	5b                   	pop    %ebx
  801d5d:	5e                   	pop    %esi
  801d5e:	5f                   	pop    %edi
  801d5f:	5d                   	pop    %ebp
  801d60:	c3                   	ret    

00801d61 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d61:	55                   	push   %ebp
  801d62:	89 e5                	mov    %esp,%ebp
  801d64:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801d67:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d6b:	75 07                	jne    801d74 <devcons_read+0x13>
  801d6d:	eb 25                	jmp    801d94 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d6f:	e8 46 ee ff ff       	call   800bba <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d74:	e8 b1 ed ff ff       	call   800b2a <sys_cgetc>
  801d79:	85 c0                	test   %eax,%eax
  801d7b:	74 f2                	je     801d6f <devcons_read+0xe>
  801d7d:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801d7f:	85 c0                	test   %eax,%eax
  801d81:	78 1d                	js     801da0 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d83:	83 f8 04             	cmp    $0x4,%eax
  801d86:	74 13                	je     801d9b <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801d88:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d8b:	88 10                	mov    %dl,(%eax)
	return 1;
  801d8d:	b8 01 00 00 00       	mov    $0x1,%eax
  801d92:	eb 0c                	jmp    801da0 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801d94:	b8 00 00 00 00       	mov    $0x0,%eax
  801d99:	eb 05                	jmp    801da0 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d9b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801da0:	c9                   	leave  
  801da1:	c3                   	ret    

00801da2 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801da2:	55                   	push   %ebp
  801da3:	89 e5                	mov    %esp,%ebp
  801da5:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801da8:	8b 45 08             	mov    0x8(%ebp),%eax
  801dab:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801dae:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801db5:	00 
  801db6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801db9:	89 04 24             	mov    %eax,(%esp)
  801dbc:	e8 4b ed ff ff       	call   800b0c <sys_cputs>
}
  801dc1:	c9                   	leave  
  801dc2:	c3                   	ret    

00801dc3 <getchar>:

int
getchar(void)
{
  801dc3:	55                   	push   %ebp
  801dc4:	89 e5                	mov    %esp,%ebp
  801dc6:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801dc9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801dd0:	00 
  801dd1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dd4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dd8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ddf:	e8 d2 f4 ff ff       	call   8012b6 <read>
	if (r < 0)
  801de4:	85 c0                	test   %eax,%eax
  801de6:	78 0f                	js     801df7 <getchar+0x34>
		return r;
	if (r < 1)
  801de8:	85 c0                	test   %eax,%eax
  801dea:	7e 06                	jle    801df2 <getchar+0x2f>
		return -E_EOF;
	return c;
  801dec:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801df0:	eb 05                	jmp    801df7 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801df2:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801df7:	c9                   	leave  
  801df8:	c3                   	ret    

00801df9 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801df9:	55                   	push   %ebp
  801dfa:	89 e5                	mov    %esp,%ebp
  801dfc:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e02:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e06:	8b 45 08             	mov    0x8(%ebp),%eax
  801e09:	89 04 24             	mov    %eax,(%esp)
  801e0c:	e8 09 f2 ff ff       	call   80101a <fd_lookup>
  801e11:	85 c0                	test   %eax,%eax
  801e13:	78 11                	js     801e26 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e15:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e18:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e1e:	39 10                	cmp    %edx,(%eax)
  801e20:	0f 94 c0             	sete   %al
  801e23:	0f b6 c0             	movzbl %al,%eax
}
  801e26:	c9                   	leave  
  801e27:	c3                   	ret    

00801e28 <opencons>:

int
opencons(void)
{
  801e28:	55                   	push   %ebp
  801e29:	89 e5                	mov    %esp,%ebp
  801e2b:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e2e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e31:	89 04 24             	mov    %eax,(%esp)
  801e34:	e8 8e f1 ff ff       	call   800fc7 <fd_alloc>
  801e39:	85 c0                	test   %eax,%eax
  801e3b:	78 3c                	js     801e79 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e3d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e44:	00 
  801e45:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e48:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e4c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e53:	e8 81 ed ff ff       	call   800bd9 <sys_page_alloc>
  801e58:	85 c0                	test   %eax,%eax
  801e5a:	78 1d                	js     801e79 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e5c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e62:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e65:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e67:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e6a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e71:	89 04 24             	mov    %eax,(%esp)
  801e74:	e8 23 f1 ff ff       	call   800f9c <fd2num>
}
  801e79:	c9                   	leave  
  801e7a:	c3                   	ret    
	...

00801e7c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e7c:	55                   	push   %ebp
  801e7d:	89 e5                	mov    %esp,%ebp
  801e7f:	56                   	push   %esi
  801e80:	53                   	push   %ebx
  801e81:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801e84:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e87:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801e8d:	e8 09 ed ff ff       	call   800b9b <sys_getenvid>
  801e92:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e95:	89 54 24 10          	mov    %edx,0x10(%esp)
  801e99:	8b 55 08             	mov    0x8(%ebp),%edx
  801e9c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801ea0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ea4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ea8:	c7 04 24 f8 26 80 00 	movl   $0x8026f8,(%esp)
  801eaf:	e8 88 e3 ff ff       	call   80023c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801eb4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801eb8:	8b 45 10             	mov    0x10(%ebp),%eax
  801ebb:	89 04 24             	mov    %eax,(%esp)
  801ebe:	e8 18 e3 ff ff       	call   8001db <vcprintf>
	cprintf("\n");
  801ec3:	c7 04 24 b0 22 80 00 	movl   $0x8022b0,(%esp)
  801eca:	e8 6d e3 ff ff       	call   80023c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ecf:	cc                   	int3   
  801ed0:	eb fd                	jmp    801ecf <_panic+0x53>
	...

00801ed4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ed4:	55                   	push   %ebp
  801ed5:	89 e5                	mov    %esp,%ebp
  801ed7:	56                   	push   %esi
  801ed8:	53                   	push   %ebx
  801ed9:	83 ec 10             	sub    $0x10,%esp
  801edc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801edf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ee2:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int r;
		
	r = sys_ipc_recv(pg?pg:(void*)UTOP);
  801ee5:	85 c0                	test   %eax,%eax
  801ee7:	75 05                	jne    801eee <ipc_recv+0x1a>
  801ee9:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801eee:	89 04 24             	mov    %eax,(%esp)
  801ef1:	e8 f9 ee ff ff       	call   800def <sys_ipc_recv>
	if (from_env_store != NULL)
  801ef6:	85 db                	test   %ebx,%ebx
  801ef8:	74 0b                	je     801f05 <ipc_recv+0x31>
		*from_env_store = thisenv->env_ipc_from; 
  801efa:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801f00:	8b 52 74             	mov    0x74(%edx),%edx
  801f03:	89 13                	mov    %edx,(%ebx)
	if (perm_store != NULL)
  801f05:	85 f6                	test   %esi,%esi
  801f07:	74 0b                	je     801f14 <ipc_recv+0x40>
		*perm_store = thisenv->env_ipc_perm;
  801f09:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801f0f:	8b 52 78             	mov    0x78(%edx),%edx
  801f12:	89 16                	mov    %edx,(%esi)
	
	if (r < 0){
  801f14:	85 c0                	test   %eax,%eax
  801f16:	79 16                	jns    801f2e <ipc_recv+0x5a>
		if(from_env_store != NULL)
  801f18:	85 db                	test   %ebx,%ebx
  801f1a:	74 06                	je     801f22 <ipc_recv+0x4e>
			*from_env_store = 0;
  801f1c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store != NULL)	
  801f22:	85 f6                	test   %esi,%esi
  801f24:	74 10                	je     801f36 <ipc_recv+0x62>
			*perm_store = 0;
  801f26:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801f2c:	eb 08                	jmp    801f36 <ipc_recv+0x62>
		return r;
	}
	
	return thisenv->env_ipc_value;
  801f2e:	a1 04 40 80 00       	mov    0x804004,%eax
  801f33:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f36:	83 c4 10             	add    $0x10,%esp
  801f39:	5b                   	pop    %ebx
  801f3a:	5e                   	pop    %esi
  801f3b:	5d                   	pop    %ebp
  801f3c:	c3                   	ret    

00801f3d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f3d:	55                   	push   %ebp
  801f3e:	89 e5                	mov    %esp,%ebp
  801f40:	57                   	push   %edi
  801f41:	56                   	push   %esi
  801f42:	53                   	push   %ebx
  801f43:	83 ec 1c             	sub    $0x1c,%esp
  801f46:	8b 75 08             	mov    0x8(%ebp),%esi
  801f49:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801f4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  801f4f:	eb 2a                	jmp    801f7b <ipc_send+0x3e>
		if (r != -E_IPC_NOT_RECV)
  801f51:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f54:	74 20                	je     801f76 <ipc_send+0x39>
			panic("ipc_send: sys_ipc_try_send failed %e", r);
  801f56:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f5a:	c7 44 24 08 1c 27 80 	movl   $0x80271c,0x8(%esp)
  801f61:	00 
  801f62:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  801f69:	00 
  801f6a:	c7 04 24 44 27 80 00 	movl   $0x802744,(%esp)
  801f71:	e8 06 ff ff ff       	call   801e7c <_panic>
		sys_yield();
  801f76:	e8 3f ec ff ff       	call   800bba <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  801f7b:	85 db                	test   %ebx,%ebx
  801f7d:	75 07                	jne    801f86 <ipc_send+0x49>
  801f7f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f84:	eb 02                	jmp    801f88 <ipc_send+0x4b>
  801f86:	89 d8                	mov    %ebx,%eax
  801f88:	8b 55 14             	mov    0x14(%ebp),%edx
  801f8b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801f8f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f93:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801f97:	89 34 24             	mov    %esi,(%esp)
  801f9a:	e8 2d ee ff ff       	call   800dcc <sys_ipc_try_send>
  801f9f:	85 c0                	test   %eax,%eax
  801fa1:	78 ae                	js     801f51 <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: sys_ipc_try_send failed %e", r);
		sys_yield();
	}
}
  801fa3:	83 c4 1c             	add    $0x1c,%esp
  801fa6:	5b                   	pop    %ebx
  801fa7:	5e                   	pop    %esi
  801fa8:	5f                   	pop    %edi
  801fa9:	5d                   	pop    %ebp
  801faa:	c3                   	ret    

00801fab <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fab:	55                   	push   %ebp
  801fac:	89 e5                	mov    %esp,%ebp
  801fae:	53                   	push   %ebx
  801faf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801fb2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fb7:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801fbe:	89 c2                	mov    %eax,%edx
  801fc0:	c1 e2 07             	shl    $0x7,%edx
  801fc3:	29 ca                	sub    %ecx,%edx
  801fc5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fcb:	8b 52 50             	mov    0x50(%edx),%edx
  801fce:	39 da                	cmp    %ebx,%edx
  801fd0:	75 0f                	jne    801fe1 <ipc_find_env+0x36>
			return envs[i].env_id;
  801fd2:	c1 e0 07             	shl    $0x7,%eax
  801fd5:	29 c8                	sub    %ecx,%eax
  801fd7:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801fdc:	8b 40 40             	mov    0x40(%eax),%eax
  801fdf:	eb 0c                	jmp    801fed <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fe1:	40                   	inc    %eax
  801fe2:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fe7:	75 ce                	jne    801fb7 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801fe9:	66 b8 00 00          	mov    $0x0,%ax
}
  801fed:	5b                   	pop    %ebx
  801fee:	5d                   	pop    %ebp
  801fef:	c3                   	ret    

00801ff0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ff0:	55                   	push   %ebp
  801ff1:	89 e5                	mov    %esp,%ebp
  801ff3:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ff6:	89 c2                	mov    %eax,%edx
  801ff8:	c1 ea 16             	shr    $0x16,%edx
  801ffb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802002:	f6 c2 01             	test   $0x1,%dl
  802005:	74 1e                	je     802025 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802007:	c1 e8 0c             	shr    $0xc,%eax
  80200a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802011:	a8 01                	test   $0x1,%al
  802013:	74 17                	je     80202c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802015:	c1 e8 0c             	shr    $0xc,%eax
  802018:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80201f:	ef 
  802020:	0f b7 c0             	movzwl %ax,%eax
  802023:	eb 0c                	jmp    802031 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802025:	b8 00 00 00 00       	mov    $0x0,%eax
  80202a:	eb 05                	jmp    802031 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  80202c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802031:	5d                   	pop    %ebp
  802032:	c3                   	ret    
	...

00802034 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802034:	55                   	push   %ebp
  802035:	57                   	push   %edi
  802036:	56                   	push   %esi
  802037:	83 ec 10             	sub    $0x10,%esp
  80203a:	8b 74 24 20          	mov    0x20(%esp),%esi
  80203e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802042:	89 74 24 04          	mov    %esi,0x4(%esp)
  802046:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  80204a:	89 cd                	mov    %ecx,%ebp
  80204c:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802050:	85 c0                	test   %eax,%eax
  802052:	75 2c                	jne    802080 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802054:	39 f9                	cmp    %edi,%ecx
  802056:	77 68                	ja     8020c0 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802058:	85 c9                	test   %ecx,%ecx
  80205a:	75 0b                	jne    802067 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80205c:	b8 01 00 00 00       	mov    $0x1,%eax
  802061:	31 d2                	xor    %edx,%edx
  802063:	f7 f1                	div    %ecx
  802065:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802067:	31 d2                	xor    %edx,%edx
  802069:	89 f8                	mov    %edi,%eax
  80206b:	f7 f1                	div    %ecx
  80206d:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80206f:	89 f0                	mov    %esi,%eax
  802071:	f7 f1                	div    %ecx
  802073:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802075:	89 f0                	mov    %esi,%eax
  802077:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802079:	83 c4 10             	add    $0x10,%esp
  80207c:	5e                   	pop    %esi
  80207d:	5f                   	pop    %edi
  80207e:	5d                   	pop    %ebp
  80207f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802080:	39 f8                	cmp    %edi,%eax
  802082:	77 2c                	ja     8020b0 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802084:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  802087:	83 f6 1f             	xor    $0x1f,%esi
  80208a:	75 4c                	jne    8020d8 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80208c:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80208e:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802093:	72 0a                	jb     80209f <__udivdi3+0x6b>
  802095:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802099:	0f 87 ad 00 00 00    	ja     80214c <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80209f:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8020a4:	89 f0                	mov    %esi,%eax
  8020a6:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8020a8:	83 c4 10             	add    $0x10,%esp
  8020ab:	5e                   	pop    %esi
  8020ac:	5f                   	pop    %edi
  8020ad:	5d                   	pop    %ebp
  8020ae:	c3                   	ret    
  8020af:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8020b0:	31 ff                	xor    %edi,%edi
  8020b2:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8020b4:	89 f0                	mov    %esi,%eax
  8020b6:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8020b8:	83 c4 10             	add    $0x10,%esp
  8020bb:	5e                   	pop    %esi
  8020bc:	5f                   	pop    %edi
  8020bd:	5d                   	pop    %ebp
  8020be:	c3                   	ret    
  8020bf:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8020c0:	89 fa                	mov    %edi,%edx
  8020c2:	89 f0                	mov    %esi,%eax
  8020c4:	f7 f1                	div    %ecx
  8020c6:	89 c6                	mov    %eax,%esi
  8020c8:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8020ca:	89 f0                	mov    %esi,%eax
  8020cc:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8020ce:	83 c4 10             	add    $0x10,%esp
  8020d1:	5e                   	pop    %esi
  8020d2:	5f                   	pop    %edi
  8020d3:	5d                   	pop    %ebp
  8020d4:	c3                   	ret    
  8020d5:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8020d8:	89 f1                	mov    %esi,%ecx
  8020da:	d3 e0                	shl    %cl,%eax
  8020dc:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8020e0:	b8 20 00 00 00       	mov    $0x20,%eax
  8020e5:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8020e7:	89 ea                	mov    %ebp,%edx
  8020e9:	88 c1                	mov    %al,%cl
  8020eb:	d3 ea                	shr    %cl,%edx
  8020ed:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8020f1:	09 ca                	or     %ecx,%edx
  8020f3:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  8020f7:	89 f1                	mov    %esi,%ecx
  8020f9:	d3 e5                	shl    %cl,%ebp
  8020fb:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  8020ff:	89 fd                	mov    %edi,%ebp
  802101:	88 c1                	mov    %al,%cl
  802103:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802105:	89 fa                	mov    %edi,%edx
  802107:	89 f1                	mov    %esi,%ecx
  802109:	d3 e2                	shl    %cl,%edx
  80210b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80210f:	88 c1                	mov    %al,%cl
  802111:	d3 ef                	shr    %cl,%edi
  802113:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802115:	89 f8                	mov    %edi,%eax
  802117:	89 ea                	mov    %ebp,%edx
  802119:	f7 74 24 08          	divl   0x8(%esp)
  80211d:	89 d1                	mov    %edx,%ecx
  80211f:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802121:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802125:	39 d1                	cmp    %edx,%ecx
  802127:	72 17                	jb     802140 <__udivdi3+0x10c>
  802129:	74 09                	je     802134 <__udivdi3+0x100>
  80212b:	89 fe                	mov    %edi,%esi
  80212d:	31 ff                	xor    %edi,%edi
  80212f:	e9 41 ff ff ff       	jmp    802075 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802134:	8b 54 24 04          	mov    0x4(%esp),%edx
  802138:	89 f1                	mov    %esi,%ecx
  80213a:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80213c:	39 c2                	cmp    %eax,%edx
  80213e:	73 eb                	jae    80212b <__udivdi3+0xf7>
		{
		  q0--;
  802140:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802143:	31 ff                	xor    %edi,%edi
  802145:	e9 2b ff ff ff       	jmp    802075 <__udivdi3+0x41>
  80214a:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80214c:	31 f6                	xor    %esi,%esi
  80214e:	e9 22 ff ff ff       	jmp    802075 <__udivdi3+0x41>
	...

00802154 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802154:	55                   	push   %ebp
  802155:	57                   	push   %edi
  802156:	56                   	push   %esi
  802157:	83 ec 20             	sub    $0x20,%esp
  80215a:	8b 44 24 30          	mov    0x30(%esp),%eax
  80215e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802162:	89 44 24 14          	mov    %eax,0x14(%esp)
  802166:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  80216a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80216e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802172:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802174:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802176:	85 ed                	test   %ebp,%ebp
  802178:	75 16                	jne    802190 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  80217a:	39 f1                	cmp    %esi,%ecx
  80217c:	0f 86 a6 00 00 00    	jbe    802228 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802182:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802184:	89 d0                	mov    %edx,%eax
  802186:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802188:	83 c4 20             	add    $0x20,%esp
  80218b:	5e                   	pop    %esi
  80218c:	5f                   	pop    %edi
  80218d:	5d                   	pop    %ebp
  80218e:	c3                   	ret    
  80218f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802190:	39 f5                	cmp    %esi,%ebp
  802192:	0f 87 ac 00 00 00    	ja     802244 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802198:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  80219b:	83 f0 1f             	xor    $0x1f,%eax
  80219e:	89 44 24 10          	mov    %eax,0x10(%esp)
  8021a2:	0f 84 a8 00 00 00    	je     802250 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8021a8:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8021ac:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8021ae:	bf 20 00 00 00       	mov    $0x20,%edi
  8021b3:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8021b7:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8021bb:	89 f9                	mov    %edi,%ecx
  8021bd:	d3 e8                	shr    %cl,%eax
  8021bf:	09 e8                	or     %ebp,%eax
  8021c1:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  8021c5:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8021c9:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8021cd:	d3 e0                	shl    %cl,%eax
  8021cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8021d3:	89 f2                	mov    %esi,%edx
  8021d5:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8021d7:	8b 44 24 14          	mov    0x14(%esp),%eax
  8021db:	d3 e0                	shl    %cl,%eax
  8021dd:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8021e1:	8b 44 24 14          	mov    0x14(%esp),%eax
  8021e5:	89 f9                	mov    %edi,%ecx
  8021e7:	d3 e8                	shr    %cl,%eax
  8021e9:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8021eb:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8021ed:	89 f2                	mov    %esi,%edx
  8021ef:	f7 74 24 18          	divl   0x18(%esp)
  8021f3:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8021f5:	f7 64 24 0c          	mull   0xc(%esp)
  8021f9:	89 c5                	mov    %eax,%ebp
  8021fb:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8021fd:	39 d6                	cmp    %edx,%esi
  8021ff:	72 67                	jb     802268 <__umoddi3+0x114>
  802201:	74 75                	je     802278 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802203:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802207:	29 e8                	sub    %ebp,%eax
  802209:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80220b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80220f:	d3 e8                	shr    %cl,%eax
  802211:	89 f2                	mov    %esi,%edx
  802213:	89 f9                	mov    %edi,%ecx
  802215:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802217:	09 d0                	or     %edx,%eax
  802219:	89 f2                	mov    %esi,%edx
  80221b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80221f:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802221:	83 c4 20             	add    $0x20,%esp
  802224:	5e                   	pop    %esi
  802225:	5f                   	pop    %edi
  802226:	5d                   	pop    %ebp
  802227:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802228:	85 c9                	test   %ecx,%ecx
  80222a:	75 0b                	jne    802237 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80222c:	b8 01 00 00 00       	mov    $0x1,%eax
  802231:	31 d2                	xor    %edx,%edx
  802233:	f7 f1                	div    %ecx
  802235:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802237:	89 f0                	mov    %esi,%eax
  802239:	31 d2                	xor    %edx,%edx
  80223b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80223d:	89 f8                	mov    %edi,%eax
  80223f:	e9 3e ff ff ff       	jmp    802182 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802244:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802246:	83 c4 20             	add    $0x20,%esp
  802249:	5e                   	pop    %esi
  80224a:	5f                   	pop    %edi
  80224b:	5d                   	pop    %ebp
  80224c:	c3                   	ret    
  80224d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802250:	39 f5                	cmp    %esi,%ebp
  802252:	72 04                	jb     802258 <__umoddi3+0x104>
  802254:	39 f9                	cmp    %edi,%ecx
  802256:	77 06                	ja     80225e <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802258:	89 f2                	mov    %esi,%edx
  80225a:	29 cf                	sub    %ecx,%edi
  80225c:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  80225e:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802260:	83 c4 20             	add    $0x20,%esp
  802263:	5e                   	pop    %esi
  802264:	5f                   	pop    %edi
  802265:	5d                   	pop    %ebp
  802266:	c3                   	ret    
  802267:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802268:	89 d1                	mov    %edx,%ecx
  80226a:	89 c5                	mov    %eax,%ebp
  80226c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802270:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802274:	eb 8d                	jmp    802203 <__umoddi3+0xaf>
  802276:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802278:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  80227c:	72 ea                	jb     802268 <__umoddi3+0x114>
  80227e:	89 f1                	mov    %esi,%ecx
  802280:	eb 81                	jmp    802203 <__umoddi3+0xaf>
