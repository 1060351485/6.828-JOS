
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
  80003a:	c7 04 24 00 28 80 00 	movl   $0x802800,(%esp)
  800041:	e8 ea 01 00 00       	call   800230 <cprintf>
	exit();
  800046:	e8 31 01 00 00       	call   80017c <exit>
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
  800070:	e8 43 0e 00 00       	call   800eb8 <argstart>
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
  800096:	e8 56 0e 00 00       	call   800ef1 <argnext>
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
  8000b1:	e8 8a 14 00 00       	call   801540 <fstat>
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
  8000de:	c7 44 24 04 14 28 80 	movl   $0x802814,0x4(%esp)
  8000e5:	00 
  8000e6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8000ed:	e8 a2 18 00 00       	call   801994 <fprintf>
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
  800114:	c7 04 24 14 28 80 00 	movl   $0x802814,(%esp)
  80011b:	e8 10 01 00 00       	call   800230 <cprintf>
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
  800142:	e8 48 0a 00 00       	call   800b8f <sys_getenvid>
  800147:	25 ff 03 00 00       	and    $0x3ff,%eax
  80014c:	c1 e0 07             	shl    $0x7,%eax
  80014f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800154:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800159:	85 f6                	test   %esi,%esi
  80015b:	7e 07                	jle    800164 <libmain+0x30>
		binaryname = argv[0];
  80015d:	8b 03                	mov    (%ebx),%eax
  80015f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800164:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800168:	89 34 24             	mov    %esi,(%esp)
  80016b:	e8 dd fe ff ff       	call   80004d <umain>

	// exit gracefully
	exit();
  800170:	e8 07 00 00 00       	call   80017c <exit>
}
  800175:	83 c4 10             	add    $0x10,%esp
  800178:	5b                   	pop    %ebx
  800179:	5e                   	pop    %esi
  80017a:	5d                   	pop    %ebp
  80017b:	c3                   	ret    

0080017c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80017c:	55                   	push   %ebp
  80017d:	89 e5                	mov    %esp,%ebp
  80017f:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  800182:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800189:	e8 af 09 00 00       	call   800b3d <sys_env_destroy>
}
  80018e:	c9                   	leave  
  80018f:	c3                   	ret    

00800190 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	53                   	push   %ebx
  800194:	83 ec 14             	sub    $0x14,%esp
  800197:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80019a:	8b 03                	mov    (%ebx),%eax
  80019c:	8b 55 08             	mov    0x8(%ebp),%edx
  80019f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001a3:	40                   	inc    %eax
  8001a4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001a6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001ab:	75 19                	jne    8001c6 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001ad:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001b4:	00 
  8001b5:	8d 43 08             	lea    0x8(%ebx),%eax
  8001b8:	89 04 24             	mov    %eax,(%esp)
  8001bb:	e8 40 09 00 00       	call   800b00 <sys_cputs>
		b->idx = 0;
  8001c0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001c6:	ff 43 04             	incl   0x4(%ebx)
}
  8001c9:	83 c4 14             	add    $0x14,%esp
  8001cc:	5b                   	pop    %ebx
  8001cd:	5d                   	pop    %ebp
  8001ce:	c3                   	ret    

008001cf <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001cf:	55                   	push   %ebp
  8001d0:	89 e5                	mov    %esp,%ebp
  8001d2:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001d8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001df:	00 00 00 
	b.cnt = 0;
  8001e2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001e9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001ef:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001fa:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800200:	89 44 24 04          	mov    %eax,0x4(%esp)
  800204:	c7 04 24 90 01 80 00 	movl   $0x800190,(%esp)
  80020b:	e8 82 01 00 00       	call   800392 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800210:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800216:	89 44 24 04          	mov    %eax,0x4(%esp)
  80021a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800220:	89 04 24             	mov    %eax,(%esp)
  800223:	e8 d8 08 00 00       	call   800b00 <sys_cputs>

	return b.cnt;
}
  800228:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80022e:	c9                   	leave  
  80022f:	c3                   	ret    

00800230 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800236:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800239:	89 44 24 04          	mov    %eax,0x4(%esp)
  80023d:	8b 45 08             	mov    0x8(%ebp),%eax
  800240:	89 04 24             	mov    %eax,(%esp)
  800243:	e8 87 ff ff ff       	call   8001cf <vcprintf>
	va_end(ap);

	return cnt;
}
  800248:	c9                   	leave  
  800249:	c3                   	ret    
	...

0080024c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80024c:	55                   	push   %ebp
  80024d:	89 e5                	mov    %esp,%ebp
  80024f:	57                   	push   %edi
  800250:	56                   	push   %esi
  800251:	53                   	push   %ebx
  800252:	83 ec 3c             	sub    $0x3c,%esp
  800255:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800258:	89 d7                	mov    %edx,%edi
  80025a:	8b 45 08             	mov    0x8(%ebp),%eax
  80025d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800260:	8b 45 0c             	mov    0xc(%ebp),%eax
  800263:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800266:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800269:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80026c:	85 c0                	test   %eax,%eax
  80026e:	75 08                	jne    800278 <printnum+0x2c>
  800270:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800273:	39 45 10             	cmp    %eax,0x10(%ebp)
  800276:	77 57                	ja     8002cf <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800278:	89 74 24 10          	mov    %esi,0x10(%esp)
  80027c:	4b                   	dec    %ebx
  80027d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800281:	8b 45 10             	mov    0x10(%ebp),%eax
  800284:	89 44 24 08          	mov    %eax,0x8(%esp)
  800288:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80028c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800290:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800297:	00 
  800298:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80029b:	89 04 24             	mov    %eax,(%esp)
  80029e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a5:	e8 ee 22 00 00       	call   802598 <__udivdi3>
  8002aa:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002ae:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002b2:	89 04 24             	mov    %eax,(%esp)
  8002b5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002b9:	89 fa                	mov    %edi,%edx
  8002bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002be:	e8 89 ff ff ff       	call   80024c <printnum>
  8002c3:	eb 0f                	jmp    8002d4 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002c5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002c9:	89 34 24             	mov    %esi,(%esp)
  8002cc:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002cf:	4b                   	dec    %ebx
  8002d0:	85 db                	test   %ebx,%ebx
  8002d2:	7f f1                	jg     8002c5 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002d4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002d8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8002df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002e3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002ea:	00 
  8002eb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002ee:	89 04 24             	mov    %eax,(%esp)
  8002f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f8:	e8 bb 23 00 00       	call   8026b8 <__umoddi3>
  8002fd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800301:	0f be 80 46 28 80 00 	movsbl 0x802846(%eax),%eax
  800308:	89 04 24             	mov    %eax,(%esp)
  80030b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80030e:	83 c4 3c             	add    $0x3c,%esp
  800311:	5b                   	pop    %ebx
  800312:	5e                   	pop    %esi
  800313:	5f                   	pop    %edi
  800314:	5d                   	pop    %ebp
  800315:	c3                   	ret    

00800316 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800316:	55                   	push   %ebp
  800317:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800319:	83 fa 01             	cmp    $0x1,%edx
  80031c:	7e 0e                	jle    80032c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80031e:	8b 10                	mov    (%eax),%edx
  800320:	8d 4a 08             	lea    0x8(%edx),%ecx
  800323:	89 08                	mov    %ecx,(%eax)
  800325:	8b 02                	mov    (%edx),%eax
  800327:	8b 52 04             	mov    0x4(%edx),%edx
  80032a:	eb 22                	jmp    80034e <getuint+0x38>
	else if (lflag)
  80032c:	85 d2                	test   %edx,%edx
  80032e:	74 10                	je     800340 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800330:	8b 10                	mov    (%eax),%edx
  800332:	8d 4a 04             	lea    0x4(%edx),%ecx
  800335:	89 08                	mov    %ecx,(%eax)
  800337:	8b 02                	mov    (%edx),%eax
  800339:	ba 00 00 00 00       	mov    $0x0,%edx
  80033e:	eb 0e                	jmp    80034e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800340:	8b 10                	mov    (%eax),%edx
  800342:	8d 4a 04             	lea    0x4(%edx),%ecx
  800345:	89 08                	mov    %ecx,(%eax)
  800347:	8b 02                	mov    (%edx),%eax
  800349:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80034e:	5d                   	pop    %ebp
  80034f:	c3                   	ret    

00800350 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800350:	55                   	push   %ebp
  800351:	89 e5                	mov    %esp,%ebp
  800353:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800356:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800359:	8b 10                	mov    (%eax),%edx
  80035b:	3b 50 04             	cmp    0x4(%eax),%edx
  80035e:	73 08                	jae    800368 <sprintputch+0x18>
		*b->buf++ = ch;
  800360:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800363:	88 0a                	mov    %cl,(%edx)
  800365:	42                   	inc    %edx
  800366:	89 10                	mov    %edx,(%eax)
}
  800368:	5d                   	pop    %ebp
  800369:	c3                   	ret    

0080036a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
  80036d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800370:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800373:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800377:	8b 45 10             	mov    0x10(%ebp),%eax
  80037a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80037e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800381:	89 44 24 04          	mov    %eax,0x4(%esp)
  800385:	8b 45 08             	mov    0x8(%ebp),%eax
  800388:	89 04 24             	mov    %eax,(%esp)
  80038b:	e8 02 00 00 00       	call   800392 <vprintfmt>
	va_end(ap);
}
  800390:	c9                   	leave  
  800391:	c3                   	ret    

00800392 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800392:	55                   	push   %ebp
  800393:	89 e5                	mov    %esp,%ebp
  800395:	57                   	push   %edi
  800396:	56                   	push   %esi
  800397:	53                   	push   %ebx
  800398:	83 ec 4c             	sub    $0x4c,%esp
  80039b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80039e:	8b 75 10             	mov    0x10(%ebp),%esi
  8003a1:	eb 12                	jmp    8003b5 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003a3:	85 c0                	test   %eax,%eax
  8003a5:	0f 84 6b 03 00 00    	je     800716 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8003ab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003af:	89 04 24             	mov    %eax,(%esp)
  8003b2:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003b5:	0f b6 06             	movzbl (%esi),%eax
  8003b8:	46                   	inc    %esi
  8003b9:	83 f8 25             	cmp    $0x25,%eax
  8003bc:	75 e5                	jne    8003a3 <vprintfmt+0x11>
  8003be:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003c2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8003c9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003ce:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003d5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003da:	eb 26                	jmp    800402 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003dc:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003df:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8003e3:	eb 1d                	jmp    800402 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003e8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8003ec:	eb 14                	jmp    800402 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ee:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003f1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003f8:	eb 08                	jmp    800402 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003fa:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8003fd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800402:	0f b6 06             	movzbl (%esi),%eax
  800405:	8d 56 01             	lea    0x1(%esi),%edx
  800408:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80040b:	8a 16                	mov    (%esi),%dl
  80040d:	83 ea 23             	sub    $0x23,%edx
  800410:	80 fa 55             	cmp    $0x55,%dl
  800413:	0f 87 e1 02 00 00    	ja     8006fa <vprintfmt+0x368>
  800419:	0f b6 d2             	movzbl %dl,%edx
  80041c:	ff 24 95 80 29 80 00 	jmp    *0x802980(,%edx,4)
  800423:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800426:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80042b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80042e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800432:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800435:	8d 50 d0             	lea    -0x30(%eax),%edx
  800438:	83 fa 09             	cmp    $0x9,%edx
  80043b:	77 2a                	ja     800467 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80043d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80043e:	eb eb                	jmp    80042b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800440:	8b 45 14             	mov    0x14(%ebp),%eax
  800443:	8d 50 04             	lea    0x4(%eax),%edx
  800446:	89 55 14             	mov    %edx,0x14(%ebp)
  800449:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80044e:	eb 17                	jmp    800467 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800450:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800454:	78 98                	js     8003ee <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800456:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800459:	eb a7                	jmp    800402 <vprintfmt+0x70>
  80045b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80045e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800465:	eb 9b                	jmp    800402 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800467:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80046b:	79 95                	jns    800402 <vprintfmt+0x70>
  80046d:	eb 8b                	jmp    8003fa <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80046f:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800470:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800473:	eb 8d                	jmp    800402 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800475:	8b 45 14             	mov    0x14(%ebp),%eax
  800478:	8d 50 04             	lea    0x4(%eax),%edx
  80047b:	89 55 14             	mov    %edx,0x14(%ebp)
  80047e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800482:	8b 00                	mov    (%eax),%eax
  800484:	89 04 24             	mov    %eax,(%esp)
  800487:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80048d:	e9 23 ff ff ff       	jmp    8003b5 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800492:	8b 45 14             	mov    0x14(%ebp),%eax
  800495:	8d 50 04             	lea    0x4(%eax),%edx
  800498:	89 55 14             	mov    %edx,0x14(%ebp)
  80049b:	8b 00                	mov    (%eax),%eax
  80049d:	85 c0                	test   %eax,%eax
  80049f:	79 02                	jns    8004a3 <vprintfmt+0x111>
  8004a1:	f7 d8                	neg    %eax
  8004a3:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004a5:	83 f8 11             	cmp    $0x11,%eax
  8004a8:	7f 0b                	jg     8004b5 <vprintfmt+0x123>
  8004aa:	8b 04 85 e0 2a 80 00 	mov    0x802ae0(,%eax,4),%eax
  8004b1:	85 c0                	test   %eax,%eax
  8004b3:	75 23                	jne    8004d8 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004b5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004b9:	c7 44 24 08 5e 28 80 	movl   $0x80285e,0x8(%esp)
  8004c0:	00 
  8004c1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c8:	89 04 24             	mov    %eax,(%esp)
  8004cb:	e8 9a fe ff ff       	call   80036a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d0:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004d3:	e9 dd fe ff ff       	jmp    8003b5 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8004d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004dc:	c7 44 24 08 1d 2c 80 	movl   $0x802c1d,0x8(%esp)
  8004e3:	00 
  8004e4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8004eb:	89 14 24             	mov    %edx,(%esp)
  8004ee:	e8 77 fe ff ff       	call   80036a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004f6:	e9 ba fe ff ff       	jmp    8003b5 <vprintfmt+0x23>
  8004fb:	89 f9                	mov    %edi,%ecx
  8004fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800500:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800503:	8b 45 14             	mov    0x14(%ebp),%eax
  800506:	8d 50 04             	lea    0x4(%eax),%edx
  800509:	89 55 14             	mov    %edx,0x14(%ebp)
  80050c:	8b 30                	mov    (%eax),%esi
  80050e:	85 f6                	test   %esi,%esi
  800510:	75 05                	jne    800517 <vprintfmt+0x185>
				p = "(null)";
  800512:	be 57 28 80 00       	mov    $0x802857,%esi
			if (width > 0 && padc != '-')
  800517:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80051b:	0f 8e 84 00 00 00    	jle    8005a5 <vprintfmt+0x213>
  800521:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800525:	74 7e                	je     8005a5 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800527:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80052b:	89 34 24             	mov    %esi,(%esp)
  80052e:	e8 8b 02 00 00       	call   8007be <strnlen>
  800533:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800536:	29 c2                	sub    %eax,%edx
  800538:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80053b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80053f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800542:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800545:	89 de                	mov    %ebx,%esi
  800547:	89 d3                	mov    %edx,%ebx
  800549:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80054b:	eb 0b                	jmp    800558 <vprintfmt+0x1c6>
					putch(padc, putdat);
  80054d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800551:	89 3c 24             	mov    %edi,(%esp)
  800554:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800557:	4b                   	dec    %ebx
  800558:	85 db                	test   %ebx,%ebx
  80055a:	7f f1                	jg     80054d <vprintfmt+0x1bb>
  80055c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80055f:	89 f3                	mov    %esi,%ebx
  800561:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800564:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800567:	85 c0                	test   %eax,%eax
  800569:	79 05                	jns    800570 <vprintfmt+0x1de>
  80056b:	b8 00 00 00 00       	mov    $0x0,%eax
  800570:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800573:	29 c2                	sub    %eax,%edx
  800575:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800578:	eb 2b                	jmp    8005a5 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80057a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80057e:	74 18                	je     800598 <vprintfmt+0x206>
  800580:	8d 50 e0             	lea    -0x20(%eax),%edx
  800583:	83 fa 5e             	cmp    $0x5e,%edx
  800586:	76 10                	jbe    800598 <vprintfmt+0x206>
					putch('?', putdat);
  800588:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80058c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800593:	ff 55 08             	call   *0x8(%ebp)
  800596:	eb 0a                	jmp    8005a2 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800598:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80059c:	89 04 24             	mov    %eax,(%esp)
  80059f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005a2:	ff 4d e4             	decl   -0x1c(%ebp)
  8005a5:	0f be 06             	movsbl (%esi),%eax
  8005a8:	46                   	inc    %esi
  8005a9:	85 c0                	test   %eax,%eax
  8005ab:	74 21                	je     8005ce <vprintfmt+0x23c>
  8005ad:	85 ff                	test   %edi,%edi
  8005af:	78 c9                	js     80057a <vprintfmt+0x1e8>
  8005b1:	4f                   	dec    %edi
  8005b2:	79 c6                	jns    80057a <vprintfmt+0x1e8>
  8005b4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005b7:	89 de                	mov    %ebx,%esi
  8005b9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005bc:	eb 18                	jmp    8005d6 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005be:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005c2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005c9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005cb:	4b                   	dec    %ebx
  8005cc:	eb 08                	jmp    8005d6 <vprintfmt+0x244>
  8005ce:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005d1:	89 de                	mov    %ebx,%esi
  8005d3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005d6:	85 db                	test   %ebx,%ebx
  8005d8:	7f e4                	jg     8005be <vprintfmt+0x22c>
  8005da:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005dd:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005df:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005e2:	e9 ce fd ff ff       	jmp    8003b5 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005e7:	83 f9 01             	cmp    $0x1,%ecx
  8005ea:	7e 10                	jle    8005fc <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8005ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ef:	8d 50 08             	lea    0x8(%eax),%edx
  8005f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f5:	8b 30                	mov    (%eax),%esi
  8005f7:	8b 78 04             	mov    0x4(%eax),%edi
  8005fa:	eb 26                	jmp    800622 <vprintfmt+0x290>
	else if (lflag)
  8005fc:	85 c9                	test   %ecx,%ecx
  8005fe:	74 12                	je     800612 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800600:	8b 45 14             	mov    0x14(%ebp),%eax
  800603:	8d 50 04             	lea    0x4(%eax),%edx
  800606:	89 55 14             	mov    %edx,0x14(%ebp)
  800609:	8b 30                	mov    (%eax),%esi
  80060b:	89 f7                	mov    %esi,%edi
  80060d:	c1 ff 1f             	sar    $0x1f,%edi
  800610:	eb 10                	jmp    800622 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800612:	8b 45 14             	mov    0x14(%ebp),%eax
  800615:	8d 50 04             	lea    0x4(%eax),%edx
  800618:	89 55 14             	mov    %edx,0x14(%ebp)
  80061b:	8b 30                	mov    (%eax),%esi
  80061d:	89 f7                	mov    %esi,%edi
  80061f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800622:	85 ff                	test   %edi,%edi
  800624:	78 0a                	js     800630 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800626:	b8 0a 00 00 00       	mov    $0xa,%eax
  80062b:	e9 8c 00 00 00       	jmp    8006bc <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800630:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800634:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80063b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80063e:	f7 de                	neg    %esi
  800640:	83 d7 00             	adc    $0x0,%edi
  800643:	f7 df                	neg    %edi
			}
			base = 10;
  800645:	b8 0a 00 00 00       	mov    $0xa,%eax
  80064a:	eb 70                	jmp    8006bc <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80064c:	89 ca                	mov    %ecx,%edx
  80064e:	8d 45 14             	lea    0x14(%ebp),%eax
  800651:	e8 c0 fc ff ff       	call   800316 <getuint>
  800656:	89 c6                	mov    %eax,%esi
  800658:	89 d7                	mov    %edx,%edi
			base = 10;
  80065a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80065f:	eb 5b                	jmp    8006bc <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  800661:	89 ca                	mov    %ecx,%edx
  800663:	8d 45 14             	lea    0x14(%ebp),%eax
  800666:	e8 ab fc ff ff       	call   800316 <getuint>
  80066b:	89 c6                	mov    %eax,%esi
  80066d:	89 d7                	mov    %edx,%edi
			base = 8;
  80066f:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800674:	eb 46                	jmp    8006bc <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  800676:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80067a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800681:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800684:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800688:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80068f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800692:	8b 45 14             	mov    0x14(%ebp),%eax
  800695:	8d 50 04             	lea    0x4(%eax),%edx
  800698:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80069b:	8b 30                	mov    (%eax),%esi
  80069d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006a2:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006a7:	eb 13                	jmp    8006bc <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006a9:	89 ca                	mov    %ecx,%edx
  8006ab:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ae:	e8 63 fc ff ff       	call   800316 <getuint>
  8006b3:	89 c6                	mov    %eax,%esi
  8006b5:	89 d7                	mov    %edx,%edi
			base = 16;
  8006b7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006bc:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8006c0:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006c4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006c7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006cb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006cf:	89 34 24             	mov    %esi,(%esp)
  8006d2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006d6:	89 da                	mov    %ebx,%edx
  8006d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006db:	e8 6c fb ff ff       	call   80024c <printnum>
			break;
  8006e0:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006e3:	e9 cd fc ff ff       	jmp    8003b5 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ec:	89 04 24             	mov    %eax,(%esp)
  8006ef:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006f5:	e9 bb fc ff ff       	jmp    8003b5 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006fa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006fe:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800705:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800708:	eb 01                	jmp    80070b <vprintfmt+0x379>
  80070a:	4e                   	dec    %esi
  80070b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80070f:	75 f9                	jne    80070a <vprintfmt+0x378>
  800711:	e9 9f fc ff ff       	jmp    8003b5 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800716:	83 c4 4c             	add    $0x4c,%esp
  800719:	5b                   	pop    %ebx
  80071a:	5e                   	pop    %esi
  80071b:	5f                   	pop    %edi
  80071c:	5d                   	pop    %ebp
  80071d:	c3                   	ret    

0080071e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80071e:	55                   	push   %ebp
  80071f:	89 e5                	mov    %esp,%ebp
  800721:	83 ec 28             	sub    $0x28,%esp
  800724:	8b 45 08             	mov    0x8(%ebp),%eax
  800727:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80072a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80072d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800731:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800734:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80073b:	85 c0                	test   %eax,%eax
  80073d:	74 30                	je     80076f <vsnprintf+0x51>
  80073f:	85 d2                	test   %edx,%edx
  800741:	7e 33                	jle    800776 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800743:	8b 45 14             	mov    0x14(%ebp),%eax
  800746:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80074a:	8b 45 10             	mov    0x10(%ebp),%eax
  80074d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800751:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800754:	89 44 24 04          	mov    %eax,0x4(%esp)
  800758:	c7 04 24 50 03 80 00 	movl   $0x800350,(%esp)
  80075f:	e8 2e fc ff ff       	call   800392 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800764:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800767:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80076a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80076d:	eb 0c                	jmp    80077b <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80076f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800774:	eb 05                	jmp    80077b <vsnprintf+0x5d>
  800776:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80077b:	c9                   	leave  
  80077c:	c3                   	ret    

0080077d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80077d:	55                   	push   %ebp
  80077e:	89 e5                	mov    %esp,%ebp
  800780:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800783:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800786:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80078a:	8b 45 10             	mov    0x10(%ebp),%eax
  80078d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800791:	8b 45 0c             	mov    0xc(%ebp),%eax
  800794:	89 44 24 04          	mov    %eax,0x4(%esp)
  800798:	8b 45 08             	mov    0x8(%ebp),%eax
  80079b:	89 04 24             	mov    %eax,(%esp)
  80079e:	e8 7b ff ff ff       	call   80071e <vsnprintf>
	va_end(ap);

	return rc;
}
  8007a3:	c9                   	leave  
  8007a4:	c3                   	ret    
  8007a5:	00 00                	add    %al,(%eax)
	...

008007a8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b3:	eb 01                	jmp    8007b6 <strlen+0xe>
		n++;
  8007b5:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ba:	75 f9                	jne    8007b5 <strlen+0xd>
		n++;
	return n;
}
  8007bc:	5d                   	pop    %ebp
  8007bd:	c3                   	ret    

008007be <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007be:	55                   	push   %ebp
  8007bf:	89 e5                	mov    %esp,%ebp
  8007c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8007c4:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007cc:	eb 01                	jmp    8007cf <strnlen+0x11>
		n++;
  8007ce:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007cf:	39 d0                	cmp    %edx,%eax
  8007d1:	74 06                	je     8007d9 <strnlen+0x1b>
  8007d3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007d7:	75 f5                	jne    8007ce <strnlen+0x10>
		n++;
	return n;
}
  8007d9:	5d                   	pop    %ebp
  8007da:	c3                   	ret    

008007db <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007db:	55                   	push   %ebp
  8007dc:	89 e5                	mov    %esp,%ebp
  8007de:	53                   	push   %ebx
  8007df:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8007ea:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007ed:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007f0:	42                   	inc    %edx
  8007f1:	84 c9                	test   %cl,%cl
  8007f3:	75 f5                	jne    8007ea <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007f5:	5b                   	pop    %ebx
  8007f6:	5d                   	pop    %ebp
  8007f7:	c3                   	ret    

008007f8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	53                   	push   %ebx
  8007fc:	83 ec 08             	sub    $0x8,%esp
  8007ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800802:	89 1c 24             	mov    %ebx,(%esp)
  800805:	e8 9e ff ff ff       	call   8007a8 <strlen>
	strcpy(dst + len, src);
  80080a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80080d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800811:	01 d8                	add    %ebx,%eax
  800813:	89 04 24             	mov    %eax,(%esp)
  800816:	e8 c0 ff ff ff       	call   8007db <strcpy>
	return dst;
}
  80081b:	89 d8                	mov    %ebx,%eax
  80081d:	83 c4 08             	add    $0x8,%esp
  800820:	5b                   	pop    %ebx
  800821:	5d                   	pop    %ebp
  800822:	c3                   	ret    

00800823 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	56                   	push   %esi
  800827:	53                   	push   %ebx
  800828:	8b 45 08             	mov    0x8(%ebp),%eax
  80082b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80082e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800831:	b9 00 00 00 00       	mov    $0x0,%ecx
  800836:	eb 0c                	jmp    800844 <strncpy+0x21>
		*dst++ = *src;
  800838:	8a 1a                	mov    (%edx),%bl
  80083a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80083d:	80 3a 01             	cmpb   $0x1,(%edx)
  800840:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800843:	41                   	inc    %ecx
  800844:	39 f1                	cmp    %esi,%ecx
  800846:	75 f0                	jne    800838 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800848:	5b                   	pop    %ebx
  800849:	5e                   	pop    %esi
  80084a:	5d                   	pop    %ebp
  80084b:	c3                   	ret    

0080084c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80084c:	55                   	push   %ebp
  80084d:	89 e5                	mov    %esp,%ebp
  80084f:	56                   	push   %esi
  800850:	53                   	push   %ebx
  800851:	8b 75 08             	mov    0x8(%ebp),%esi
  800854:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800857:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80085a:	85 d2                	test   %edx,%edx
  80085c:	75 0a                	jne    800868 <strlcpy+0x1c>
  80085e:	89 f0                	mov    %esi,%eax
  800860:	eb 1a                	jmp    80087c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800862:	88 18                	mov    %bl,(%eax)
  800864:	40                   	inc    %eax
  800865:	41                   	inc    %ecx
  800866:	eb 02                	jmp    80086a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800868:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80086a:	4a                   	dec    %edx
  80086b:	74 0a                	je     800877 <strlcpy+0x2b>
  80086d:	8a 19                	mov    (%ecx),%bl
  80086f:	84 db                	test   %bl,%bl
  800871:	75 ef                	jne    800862 <strlcpy+0x16>
  800873:	89 c2                	mov    %eax,%edx
  800875:	eb 02                	jmp    800879 <strlcpy+0x2d>
  800877:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800879:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  80087c:	29 f0                	sub    %esi,%eax
}
  80087e:	5b                   	pop    %ebx
  80087f:	5e                   	pop    %esi
  800880:	5d                   	pop    %ebp
  800881:	c3                   	ret    

00800882 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800888:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80088b:	eb 02                	jmp    80088f <strcmp+0xd>
		p++, q++;
  80088d:	41                   	inc    %ecx
  80088e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80088f:	8a 01                	mov    (%ecx),%al
  800891:	84 c0                	test   %al,%al
  800893:	74 04                	je     800899 <strcmp+0x17>
  800895:	3a 02                	cmp    (%edx),%al
  800897:	74 f4                	je     80088d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800899:	0f b6 c0             	movzbl %al,%eax
  80089c:	0f b6 12             	movzbl (%edx),%edx
  80089f:	29 d0                	sub    %edx,%eax
}
  8008a1:	5d                   	pop    %ebp
  8008a2:	c3                   	ret    

008008a3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008a3:	55                   	push   %ebp
  8008a4:	89 e5                	mov    %esp,%ebp
  8008a6:	53                   	push   %ebx
  8008a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ad:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008b0:	eb 03                	jmp    8008b5 <strncmp+0x12>
		n--, p++, q++;
  8008b2:	4a                   	dec    %edx
  8008b3:	40                   	inc    %eax
  8008b4:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008b5:	85 d2                	test   %edx,%edx
  8008b7:	74 14                	je     8008cd <strncmp+0x2a>
  8008b9:	8a 18                	mov    (%eax),%bl
  8008bb:	84 db                	test   %bl,%bl
  8008bd:	74 04                	je     8008c3 <strncmp+0x20>
  8008bf:	3a 19                	cmp    (%ecx),%bl
  8008c1:	74 ef                	je     8008b2 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c3:	0f b6 00             	movzbl (%eax),%eax
  8008c6:	0f b6 11             	movzbl (%ecx),%edx
  8008c9:	29 d0                	sub    %edx,%eax
  8008cb:	eb 05                	jmp    8008d2 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008cd:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008d2:	5b                   	pop    %ebx
  8008d3:	5d                   	pop    %ebp
  8008d4:	c3                   	ret    

008008d5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008d5:	55                   	push   %ebp
  8008d6:	89 e5                	mov    %esp,%ebp
  8008d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008db:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008de:	eb 05                	jmp    8008e5 <strchr+0x10>
		if (*s == c)
  8008e0:	38 ca                	cmp    %cl,%dl
  8008e2:	74 0c                	je     8008f0 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008e4:	40                   	inc    %eax
  8008e5:	8a 10                	mov    (%eax),%dl
  8008e7:	84 d2                	test   %dl,%dl
  8008e9:	75 f5                	jne    8008e0 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8008eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f0:	5d                   	pop    %ebp
  8008f1:	c3                   	ret    

008008f2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f8:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008fb:	eb 05                	jmp    800902 <strfind+0x10>
		if (*s == c)
  8008fd:	38 ca                	cmp    %cl,%dl
  8008ff:	74 07                	je     800908 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800901:	40                   	inc    %eax
  800902:	8a 10                	mov    (%eax),%dl
  800904:	84 d2                	test   %dl,%dl
  800906:	75 f5                	jne    8008fd <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800908:	5d                   	pop    %ebp
  800909:	c3                   	ret    

0080090a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	57                   	push   %edi
  80090e:	56                   	push   %esi
  80090f:	53                   	push   %ebx
  800910:	8b 7d 08             	mov    0x8(%ebp),%edi
  800913:	8b 45 0c             	mov    0xc(%ebp),%eax
  800916:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800919:	85 c9                	test   %ecx,%ecx
  80091b:	74 30                	je     80094d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80091d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800923:	75 25                	jne    80094a <memset+0x40>
  800925:	f6 c1 03             	test   $0x3,%cl
  800928:	75 20                	jne    80094a <memset+0x40>
		c &= 0xFF;
  80092a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80092d:	89 d3                	mov    %edx,%ebx
  80092f:	c1 e3 08             	shl    $0x8,%ebx
  800932:	89 d6                	mov    %edx,%esi
  800934:	c1 e6 18             	shl    $0x18,%esi
  800937:	89 d0                	mov    %edx,%eax
  800939:	c1 e0 10             	shl    $0x10,%eax
  80093c:	09 f0                	or     %esi,%eax
  80093e:	09 d0                	or     %edx,%eax
  800940:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800942:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800945:	fc                   	cld    
  800946:	f3 ab                	rep stos %eax,%es:(%edi)
  800948:	eb 03                	jmp    80094d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80094a:	fc                   	cld    
  80094b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80094d:	89 f8                	mov    %edi,%eax
  80094f:	5b                   	pop    %ebx
  800950:	5e                   	pop    %esi
  800951:	5f                   	pop    %edi
  800952:	5d                   	pop    %ebp
  800953:	c3                   	ret    

00800954 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800954:	55                   	push   %ebp
  800955:	89 e5                	mov    %esp,%ebp
  800957:	57                   	push   %edi
  800958:	56                   	push   %esi
  800959:	8b 45 08             	mov    0x8(%ebp),%eax
  80095c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80095f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800962:	39 c6                	cmp    %eax,%esi
  800964:	73 34                	jae    80099a <memmove+0x46>
  800966:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800969:	39 d0                	cmp    %edx,%eax
  80096b:	73 2d                	jae    80099a <memmove+0x46>
		s += n;
		d += n;
  80096d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800970:	f6 c2 03             	test   $0x3,%dl
  800973:	75 1b                	jne    800990 <memmove+0x3c>
  800975:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80097b:	75 13                	jne    800990 <memmove+0x3c>
  80097d:	f6 c1 03             	test   $0x3,%cl
  800980:	75 0e                	jne    800990 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800982:	83 ef 04             	sub    $0x4,%edi
  800985:	8d 72 fc             	lea    -0x4(%edx),%esi
  800988:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80098b:	fd                   	std    
  80098c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80098e:	eb 07                	jmp    800997 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800990:	4f                   	dec    %edi
  800991:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800994:	fd                   	std    
  800995:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800997:	fc                   	cld    
  800998:	eb 20                	jmp    8009ba <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80099a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009a0:	75 13                	jne    8009b5 <memmove+0x61>
  8009a2:	a8 03                	test   $0x3,%al
  8009a4:	75 0f                	jne    8009b5 <memmove+0x61>
  8009a6:	f6 c1 03             	test   $0x3,%cl
  8009a9:	75 0a                	jne    8009b5 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009ab:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009ae:	89 c7                	mov    %eax,%edi
  8009b0:	fc                   	cld    
  8009b1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b3:	eb 05                	jmp    8009ba <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009b5:	89 c7                	mov    %eax,%edi
  8009b7:	fc                   	cld    
  8009b8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ba:	5e                   	pop    %esi
  8009bb:	5f                   	pop    %edi
  8009bc:	5d                   	pop    %ebp
  8009bd:	c3                   	ret    

008009be <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009be:	55                   	push   %ebp
  8009bf:	89 e5                	mov    %esp,%ebp
  8009c1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009c4:	8b 45 10             	mov    0x10(%ebp),%eax
  8009c7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d5:	89 04 24             	mov    %eax,(%esp)
  8009d8:	e8 77 ff ff ff       	call   800954 <memmove>
}
  8009dd:	c9                   	leave  
  8009de:	c3                   	ret    

008009df <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	57                   	push   %edi
  8009e3:	56                   	push   %esi
  8009e4:	53                   	push   %ebx
  8009e5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009e8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009eb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8009f3:	eb 16                	jmp    800a0b <memcmp+0x2c>
		if (*s1 != *s2)
  8009f5:	8a 04 17             	mov    (%edi,%edx,1),%al
  8009f8:	42                   	inc    %edx
  8009f9:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8009fd:	38 c8                	cmp    %cl,%al
  8009ff:	74 0a                	je     800a0b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a01:	0f b6 c0             	movzbl %al,%eax
  800a04:	0f b6 c9             	movzbl %cl,%ecx
  800a07:	29 c8                	sub    %ecx,%eax
  800a09:	eb 09                	jmp    800a14 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a0b:	39 da                	cmp    %ebx,%edx
  800a0d:	75 e6                	jne    8009f5 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a0f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a14:	5b                   	pop    %ebx
  800a15:	5e                   	pop    %esi
  800a16:	5f                   	pop    %edi
  800a17:	5d                   	pop    %ebp
  800a18:	c3                   	ret    

00800a19 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a19:	55                   	push   %ebp
  800a1a:	89 e5                	mov    %esp,%ebp
  800a1c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a22:	89 c2                	mov    %eax,%edx
  800a24:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a27:	eb 05                	jmp    800a2e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a29:	38 08                	cmp    %cl,(%eax)
  800a2b:	74 05                	je     800a32 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a2d:	40                   	inc    %eax
  800a2e:	39 d0                	cmp    %edx,%eax
  800a30:	72 f7                	jb     800a29 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a32:	5d                   	pop    %ebp
  800a33:	c3                   	ret    

00800a34 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a34:	55                   	push   %ebp
  800a35:	89 e5                	mov    %esp,%ebp
  800a37:	57                   	push   %edi
  800a38:	56                   	push   %esi
  800a39:	53                   	push   %ebx
  800a3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a3d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a40:	eb 01                	jmp    800a43 <strtol+0xf>
		s++;
  800a42:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a43:	8a 02                	mov    (%edx),%al
  800a45:	3c 20                	cmp    $0x20,%al
  800a47:	74 f9                	je     800a42 <strtol+0xe>
  800a49:	3c 09                	cmp    $0x9,%al
  800a4b:	74 f5                	je     800a42 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a4d:	3c 2b                	cmp    $0x2b,%al
  800a4f:	75 08                	jne    800a59 <strtol+0x25>
		s++;
  800a51:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a52:	bf 00 00 00 00       	mov    $0x0,%edi
  800a57:	eb 13                	jmp    800a6c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a59:	3c 2d                	cmp    $0x2d,%al
  800a5b:	75 0a                	jne    800a67 <strtol+0x33>
		s++, neg = 1;
  800a5d:	8d 52 01             	lea    0x1(%edx),%edx
  800a60:	bf 01 00 00 00       	mov    $0x1,%edi
  800a65:	eb 05                	jmp    800a6c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a67:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a6c:	85 db                	test   %ebx,%ebx
  800a6e:	74 05                	je     800a75 <strtol+0x41>
  800a70:	83 fb 10             	cmp    $0x10,%ebx
  800a73:	75 28                	jne    800a9d <strtol+0x69>
  800a75:	8a 02                	mov    (%edx),%al
  800a77:	3c 30                	cmp    $0x30,%al
  800a79:	75 10                	jne    800a8b <strtol+0x57>
  800a7b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a7f:	75 0a                	jne    800a8b <strtol+0x57>
		s += 2, base = 16;
  800a81:	83 c2 02             	add    $0x2,%edx
  800a84:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a89:	eb 12                	jmp    800a9d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a8b:	85 db                	test   %ebx,%ebx
  800a8d:	75 0e                	jne    800a9d <strtol+0x69>
  800a8f:	3c 30                	cmp    $0x30,%al
  800a91:	75 05                	jne    800a98 <strtol+0x64>
		s++, base = 8;
  800a93:	42                   	inc    %edx
  800a94:	b3 08                	mov    $0x8,%bl
  800a96:	eb 05                	jmp    800a9d <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a98:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a9d:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa2:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800aa4:	8a 0a                	mov    (%edx),%cl
  800aa6:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800aa9:	80 fb 09             	cmp    $0x9,%bl
  800aac:	77 08                	ja     800ab6 <strtol+0x82>
			dig = *s - '0';
  800aae:	0f be c9             	movsbl %cl,%ecx
  800ab1:	83 e9 30             	sub    $0x30,%ecx
  800ab4:	eb 1e                	jmp    800ad4 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800ab6:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ab9:	80 fb 19             	cmp    $0x19,%bl
  800abc:	77 08                	ja     800ac6 <strtol+0x92>
			dig = *s - 'a' + 10;
  800abe:	0f be c9             	movsbl %cl,%ecx
  800ac1:	83 e9 57             	sub    $0x57,%ecx
  800ac4:	eb 0e                	jmp    800ad4 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800ac6:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800ac9:	80 fb 19             	cmp    $0x19,%bl
  800acc:	77 12                	ja     800ae0 <strtol+0xac>
			dig = *s - 'A' + 10;
  800ace:	0f be c9             	movsbl %cl,%ecx
  800ad1:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ad4:	39 f1                	cmp    %esi,%ecx
  800ad6:	7d 0c                	jge    800ae4 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800ad8:	42                   	inc    %edx
  800ad9:	0f af c6             	imul   %esi,%eax
  800adc:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800ade:	eb c4                	jmp    800aa4 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ae0:	89 c1                	mov    %eax,%ecx
  800ae2:	eb 02                	jmp    800ae6 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ae4:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800ae6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aea:	74 05                	je     800af1 <strtol+0xbd>
		*endptr = (char *) s;
  800aec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800aef:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800af1:	85 ff                	test   %edi,%edi
  800af3:	74 04                	je     800af9 <strtol+0xc5>
  800af5:	89 c8                	mov    %ecx,%eax
  800af7:	f7 d8                	neg    %eax
}
  800af9:	5b                   	pop    %ebx
  800afa:	5e                   	pop    %esi
  800afb:	5f                   	pop    %edi
  800afc:	5d                   	pop    %ebp
  800afd:	c3                   	ret    
	...

00800b00 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b00:	55                   	push   %ebp
  800b01:	89 e5                	mov    %esp,%ebp
  800b03:	57                   	push   %edi
  800b04:	56                   	push   %esi
  800b05:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b06:	b8 00 00 00 00       	mov    $0x0,%eax
  800b0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b11:	89 c3                	mov    %eax,%ebx
  800b13:	89 c7                	mov    %eax,%edi
  800b15:	89 c6                	mov    %eax,%esi
  800b17:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b19:	5b                   	pop    %ebx
  800b1a:	5e                   	pop    %esi
  800b1b:	5f                   	pop    %edi
  800b1c:	5d                   	pop    %ebp
  800b1d:	c3                   	ret    

00800b1e <sys_cgetc>:

int
sys_cgetc(void)
{
  800b1e:	55                   	push   %ebp
  800b1f:	89 e5                	mov    %esp,%ebp
  800b21:	57                   	push   %edi
  800b22:	56                   	push   %esi
  800b23:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b24:	ba 00 00 00 00       	mov    $0x0,%edx
  800b29:	b8 01 00 00 00       	mov    $0x1,%eax
  800b2e:	89 d1                	mov    %edx,%ecx
  800b30:	89 d3                	mov    %edx,%ebx
  800b32:	89 d7                	mov    %edx,%edi
  800b34:	89 d6                	mov    %edx,%esi
  800b36:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b38:	5b                   	pop    %ebx
  800b39:	5e                   	pop    %esi
  800b3a:	5f                   	pop    %edi
  800b3b:	5d                   	pop    %ebp
  800b3c:	c3                   	ret    

00800b3d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b3d:	55                   	push   %ebp
  800b3e:	89 e5                	mov    %esp,%ebp
  800b40:	57                   	push   %edi
  800b41:	56                   	push   %esi
  800b42:	53                   	push   %ebx
  800b43:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b46:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b4b:	b8 03 00 00 00       	mov    $0x3,%eax
  800b50:	8b 55 08             	mov    0x8(%ebp),%edx
  800b53:	89 cb                	mov    %ecx,%ebx
  800b55:	89 cf                	mov    %ecx,%edi
  800b57:	89 ce                	mov    %ecx,%esi
  800b59:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b5b:	85 c0                	test   %eax,%eax
  800b5d:	7e 28                	jle    800b87 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b5f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b63:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b6a:	00 
  800b6b:	c7 44 24 08 47 2b 80 	movl   $0x802b47,0x8(%esp)
  800b72:	00 
  800b73:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b7a:	00 
  800b7b:	c7 04 24 64 2b 80 00 	movl   $0x802b64,(%esp)
  800b82:	e8 65 18 00 00       	call   8023ec <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b87:	83 c4 2c             	add    $0x2c,%esp
  800b8a:	5b                   	pop    %ebx
  800b8b:	5e                   	pop    %esi
  800b8c:	5f                   	pop    %edi
  800b8d:	5d                   	pop    %ebp
  800b8e:	c3                   	ret    

00800b8f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	57                   	push   %edi
  800b93:	56                   	push   %esi
  800b94:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b95:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9a:	b8 02 00 00 00       	mov    $0x2,%eax
  800b9f:	89 d1                	mov    %edx,%ecx
  800ba1:	89 d3                	mov    %edx,%ebx
  800ba3:	89 d7                	mov    %edx,%edi
  800ba5:	89 d6                	mov    %edx,%esi
  800ba7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ba9:	5b                   	pop    %ebx
  800baa:	5e                   	pop    %esi
  800bab:	5f                   	pop    %edi
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    

00800bae <sys_yield>:

void
sys_yield(void)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	57                   	push   %edi
  800bb2:	56                   	push   %esi
  800bb3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb9:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bbe:	89 d1                	mov    %edx,%ecx
  800bc0:	89 d3                	mov    %edx,%ebx
  800bc2:	89 d7                	mov    %edx,%edi
  800bc4:	89 d6                	mov    %edx,%esi
  800bc6:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bc8:	5b                   	pop    %ebx
  800bc9:	5e                   	pop    %esi
  800bca:	5f                   	pop    %edi
  800bcb:	5d                   	pop    %ebp
  800bcc:	c3                   	ret    

00800bcd <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bcd:	55                   	push   %ebp
  800bce:	89 e5                	mov    %esp,%ebp
  800bd0:	57                   	push   %edi
  800bd1:	56                   	push   %esi
  800bd2:	53                   	push   %ebx
  800bd3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd6:	be 00 00 00 00       	mov    $0x0,%esi
  800bdb:	b8 04 00 00 00       	mov    $0x4,%eax
  800be0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800be3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be6:	8b 55 08             	mov    0x8(%ebp),%edx
  800be9:	89 f7                	mov    %esi,%edi
  800beb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bed:	85 c0                	test   %eax,%eax
  800bef:	7e 28                	jle    800c19 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bf5:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800bfc:	00 
  800bfd:	c7 44 24 08 47 2b 80 	movl   $0x802b47,0x8(%esp)
  800c04:	00 
  800c05:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c0c:	00 
  800c0d:	c7 04 24 64 2b 80 00 	movl   $0x802b64,(%esp)
  800c14:	e8 d3 17 00 00       	call   8023ec <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c19:	83 c4 2c             	add    $0x2c,%esp
  800c1c:	5b                   	pop    %ebx
  800c1d:	5e                   	pop    %esi
  800c1e:	5f                   	pop    %edi
  800c1f:	5d                   	pop    %ebp
  800c20:	c3                   	ret    

00800c21 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c21:	55                   	push   %ebp
  800c22:	89 e5                	mov    %esp,%ebp
  800c24:	57                   	push   %edi
  800c25:	56                   	push   %esi
  800c26:	53                   	push   %ebx
  800c27:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2a:	b8 05 00 00 00       	mov    $0x5,%eax
  800c2f:	8b 75 18             	mov    0x18(%ebp),%esi
  800c32:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c35:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c40:	85 c0                	test   %eax,%eax
  800c42:	7e 28                	jle    800c6c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c44:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c48:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c4f:	00 
  800c50:	c7 44 24 08 47 2b 80 	movl   $0x802b47,0x8(%esp)
  800c57:	00 
  800c58:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c5f:	00 
  800c60:	c7 04 24 64 2b 80 00 	movl   $0x802b64,(%esp)
  800c67:	e8 80 17 00 00       	call   8023ec <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c6c:	83 c4 2c             	add    $0x2c,%esp
  800c6f:	5b                   	pop    %ebx
  800c70:	5e                   	pop    %esi
  800c71:	5f                   	pop    %edi
  800c72:	5d                   	pop    %ebp
  800c73:	c3                   	ret    

00800c74 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	57                   	push   %edi
  800c78:	56                   	push   %esi
  800c79:	53                   	push   %ebx
  800c7a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c82:	b8 06 00 00 00       	mov    $0x6,%eax
  800c87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8d:	89 df                	mov    %ebx,%edi
  800c8f:	89 de                	mov    %ebx,%esi
  800c91:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c93:	85 c0                	test   %eax,%eax
  800c95:	7e 28                	jle    800cbf <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c97:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c9b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800ca2:	00 
  800ca3:	c7 44 24 08 47 2b 80 	movl   $0x802b47,0x8(%esp)
  800caa:	00 
  800cab:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cb2:	00 
  800cb3:	c7 04 24 64 2b 80 00 	movl   $0x802b64,(%esp)
  800cba:	e8 2d 17 00 00       	call   8023ec <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cbf:	83 c4 2c             	add    $0x2c,%esp
  800cc2:	5b                   	pop    %ebx
  800cc3:	5e                   	pop    %esi
  800cc4:	5f                   	pop    %edi
  800cc5:	5d                   	pop    %ebp
  800cc6:	c3                   	ret    

00800cc7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cc7:	55                   	push   %ebp
  800cc8:	89 e5                	mov    %esp,%ebp
  800cca:	57                   	push   %edi
  800ccb:	56                   	push   %esi
  800ccc:	53                   	push   %ebx
  800ccd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd5:	b8 08 00 00 00       	mov    $0x8,%eax
  800cda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce0:	89 df                	mov    %ebx,%edi
  800ce2:	89 de                	mov    %ebx,%esi
  800ce4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce6:	85 c0                	test   %eax,%eax
  800ce8:	7e 28                	jle    800d12 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cea:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cee:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800cf5:	00 
  800cf6:	c7 44 24 08 47 2b 80 	movl   $0x802b47,0x8(%esp)
  800cfd:	00 
  800cfe:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d05:	00 
  800d06:	c7 04 24 64 2b 80 00 	movl   $0x802b64,(%esp)
  800d0d:	e8 da 16 00 00       	call   8023ec <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d12:	83 c4 2c             	add    $0x2c,%esp
  800d15:	5b                   	pop    %ebx
  800d16:	5e                   	pop    %esi
  800d17:	5f                   	pop    %edi
  800d18:	5d                   	pop    %ebp
  800d19:	c3                   	ret    

00800d1a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d1a:	55                   	push   %ebp
  800d1b:	89 e5                	mov    %esp,%ebp
  800d1d:	57                   	push   %edi
  800d1e:	56                   	push   %esi
  800d1f:	53                   	push   %ebx
  800d20:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d23:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d28:	b8 09 00 00 00       	mov    $0x9,%eax
  800d2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d30:	8b 55 08             	mov    0x8(%ebp),%edx
  800d33:	89 df                	mov    %ebx,%edi
  800d35:	89 de                	mov    %ebx,%esi
  800d37:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d39:	85 c0                	test   %eax,%eax
  800d3b:	7e 28                	jle    800d65 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d41:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d48:	00 
  800d49:	c7 44 24 08 47 2b 80 	movl   $0x802b47,0x8(%esp)
  800d50:	00 
  800d51:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d58:	00 
  800d59:	c7 04 24 64 2b 80 00 	movl   $0x802b64,(%esp)
  800d60:	e8 87 16 00 00       	call   8023ec <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d65:	83 c4 2c             	add    $0x2c,%esp
  800d68:	5b                   	pop    %ebx
  800d69:	5e                   	pop    %esi
  800d6a:	5f                   	pop    %edi
  800d6b:	5d                   	pop    %ebp
  800d6c:	c3                   	ret    

00800d6d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d6d:	55                   	push   %ebp
  800d6e:	89 e5                	mov    %esp,%ebp
  800d70:	57                   	push   %edi
  800d71:	56                   	push   %esi
  800d72:	53                   	push   %ebx
  800d73:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d76:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d7b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d83:	8b 55 08             	mov    0x8(%ebp),%edx
  800d86:	89 df                	mov    %ebx,%edi
  800d88:	89 de                	mov    %ebx,%esi
  800d8a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d8c:	85 c0                	test   %eax,%eax
  800d8e:	7e 28                	jle    800db8 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d90:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d94:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800d9b:	00 
  800d9c:	c7 44 24 08 47 2b 80 	movl   $0x802b47,0x8(%esp)
  800da3:	00 
  800da4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dab:	00 
  800dac:	c7 04 24 64 2b 80 00 	movl   $0x802b64,(%esp)
  800db3:	e8 34 16 00 00       	call   8023ec <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800db8:	83 c4 2c             	add    $0x2c,%esp
  800dbb:	5b                   	pop    %ebx
  800dbc:	5e                   	pop    %esi
  800dbd:	5f                   	pop    %edi
  800dbe:	5d                   	pop    %ebp
  800dbf:	c3                   	ret    

00800dc0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
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
  800dc6:	be 00 00 00 00       	mov    $0x0,%esi
  800dcb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dd0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dd3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddc:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dde:	5b                   	pop    %ebx
  800ddf:	5e                   	pop    %esi
  800de0:	5f                   	pop    %edi
  800de1:	5d                   	pop    %ebp
  800de2:	c3                   	ret    

00800de3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800de3:	55                   	push   %ebp
  800de4:	89 e5                	mov    %esp,%ebp
  800de6:	57                   	push   %edi
  800de7:	56                   	push   %esi
  800de8:	53                   	push   %ebx
  800de9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dec:	b9 00 00 00 00       	mov    $0x0,%ecx
  800df1:	b8 0d 00 00 00       	mov    $0xd,%eax
  800df6:	8b 55 08             	mov    0x8(%ebp),%edx
  800df9:	89 cb                	mov    %ecx,%ebx
  800dfb:	89 cf                	mov    %ecx,%edi
  800dfd:	89 ce                	mov    %ecx,%esi
  800dff:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e01:	85 c0                	test   %eax,%eax
  800e03:	7e 28                	jle    800e2d <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e05:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e09:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e10:	00 
  800e11:	c7 44 24 08 47 2b 80 	movl   $0x802b47,0x8(%esp)
  800e18:	00 
  800e19:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e20:	00 
  800e21:	c7 04 24 64 2b 80 00 	movl   $0x802b64,(%esp)
  800e28:	e8 bf 15 00 00       	call   8023ec <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e2d:	83 c4 2c             	add    $0x2c,%esp
  800e30:	5b                   	pop    %ebx
  800e31:	5e                   	pop    %esi
  800e32:	5f                   	pop    %edi
  800e33:	5d                   	pop    %ebp
  800e34:	c3                   	ret    

00800e35 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e35:	55                   	push   %ebp
  800e36:	89 e5                	mov    %esp,%ebp
  800e38:	57                   	push   %edi
  800e39:	56                   	push   %esi
  800e3a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e40:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e45:	89 d1                	mov    %edx,%ecx
  800e47:	89 d3                	mov    %edx,%ebx
  800e49:	89 d7                	mov    %edx,%edi
  800e4b:	89 d6                	mov    %edx,%esi
  800e4d:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e4f:	5b                   	pop    %ebx
  800e50:	5e                   	pop    %esi
  800e51:	5f                   	pop    %edi
  800e52:	5d                   	pop    %ebp
  800e53:	c3                   	ret    

00800e54 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char* pck, size_t length){
  800e54:	55                   	push   %ebp
  800e55:	89 e5                	mov    %esp,%ebp
  800e57:	57                   	push   %edi
  800e58:	56                   	push   %esi
  800e59:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e5f:	b8 10 00 00 00       	mov    $0x10,%eax
  800e64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e67:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6a:	89 df                	mov    %ebx,%edi
  800e6c:	89 de                	mov    %ebx,%esi
  800e6e:	cd 30                	int    $0x30
}

int 
sys_e1000_transmit(char* pck, size_t length){
	return syscall(SYS_e1000_transmit, 0, (uint32_t)pck, length, 0, 0, 0);
}
  800e70:	5b                   	pop    %ebx
  800e71:	5e                   	pop    %esi
  800e72:	5f                   	pop    %edi
  800e73:	5d                   	pop    %ebp
  800e74:	c3                   	ret    

00800e75 <sys_e1000_receive>:

int 
sys_e1000_receive(char* pck, size_t* length){
  800e75:	55                   	push   %ebp
  800e76:	89 e5                	mov    %esp,%ebp
  800e78:	57                   	push   %edi
  800e79:	56                   	push   %esi
  800e7a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e7b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e80:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e88:	8b 55 08             	mov    0x8(%ebp),%edx
  800e8b:	89 df                	mov    %ebx,%edi
  800e8d:	89 de                	mov    %ebx,%esi
  800e8f:	cd 30                	int    $0x30
}

int 
sys_e1000_receive(char* pck, size_t* length){
	return syscall(SYS_e1000_receive, 0, (uint32_t)pck, (uint32_t)length, 0, 0, 0);
}
  800e91:	5b                   	pop    %ebx
  800e92:	5e                   	pop    %esi
  800e93:	5f                   	pop    %edi
  800e94:	5d                   	pop    %ebp
  800e95:	c3                   	ret    

00800e96 <sys_e1000_get_mac>:

int 
sys_e1000_get_mac(uint8_t* mac_addr){
  800e96:	55                   	push   %ebp
  800e97:	89 e5                	mov    %esp,%ebp
  800e99:	57                   	push   %edi
  800e9a:	56                   	push   %esi
  800e9b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e9c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ea1:	b8 11 00 00 00       	mov    $0x11,%eax
  800ea6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea9:	89 cb                	mov    %ecx,%ebx
  800eab:	89 cf                	mov    %ecx,%edi
  800ead:	89 ce                	mov    %ecx,%esi
  800eaf:	cd 30                	int    $0x30
}

int 
sys_e1000_get_mac(uint8_t* mac_addr){
	return syscall(SYS_e1000_get_mac, 0, (uint32_t)mac_addr, 0, 0, 0, 0);
}
  800eb1:	5b                   	pop    %ebx
  800eb2:	5e                   	pop    %esi
  800eb3:	5f                   	pop    %edi
  800eb4:	5d                   	pop    %ebp
  800eb5:	c3                   	ret    
	...

00800eb8 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  800eb8:	55                   	push   %ebp
  800eb9:	89 e5                	mov    %esp,%ebp
  800ebb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec1:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  800ec4:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  800ec6:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  800ec9:	83 3a 01             	cmpl   $0x1,(%edx)
  800ecc:	7e 0b                	jle    800ed9 <argstart+0x21>
  800ece:	85 c9                	test   %ecx,%ecx
  800ed0:	75 0e                	jne    800ee0 <argstart+0x28>
  800ed2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ed7:	eb 0c                	jmp    800ee5 <argstart+0x2d>
  800ed9:	ba 00 00 00 00       	mov    $0x0,%edx
  800ede:	eb 05                	jmp    800ee5 <argstart+0x2d>
  800ee0:	ba 11 28 80 00       	mov    $0x802811,%edx
  800ee5:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  800ee8:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  800eef:	5d                   	pop    %ebp
  800ef0:	c3                   	ret    

00800ef1 <argnext>:

int
argnext(struct Argstate *args)
{
  800ef1:	55                   	push   %ebp
  800ef2:	89 e5                	mov    %esp,%ebp
  800ef4:	53                   	push   %ebx
  800ef5:	83 ec 14             	sub    $0x14,%esp
  800ef8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  800efb:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  800f02:	8b 43 08             	mov    0x8(%ebx),%eax
  800f05:	85 c0                	test   %eax,%eax
  800f07:	74 6c                	je     800f75 <argnext+0x84>
		return -1;

	if (!*args->curarg) {
  800f09:	80 38 00             	cmpb   $0x0,(%eax)
  800f0c:	75 4d                	jne    800f5b <argnext+0x6a>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  800f0e:	8b 0b                	mov    (%ebx),%ecx
  800f10:	83 39 01             	cmpl   $0x1,(%ecx)
  800f13:	74 52                	je     800f67 <argnext+0x76>
		    || args->argv[1][0] != '-'
  800f15:	8b 53 04             	mov    0x4(%ebx),%edx
  800f18:	8b 42 04             	mov    0x4(%edx),%eax
  800f1b:	80 38 2d             	cmpb   $0x2d,(%eax)
  800f1e:	75 47                	jne    800f67 <argnext+0x76>
		    || args->argv[1][1] == '\0')
  800f20:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800f24:	74 41                	je     800f67 <argnext+0x76>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  800f26:	40                   	inc    %eax
  800f27:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800f2a:	8b 01                	mov    (%ecx),%eax
  800f2c:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  800f33:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f37:	8d 42 08             	lea    0x8(%edx),%eax
  800f3a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f3e:	83 c2 04             	add    $0x4,%edx
  800f41:	89 14 24             	mov    %edx,(%esp)
  800f44:	e8 0b fa ff ff       	call   800954 <memmove>
		(*args->argc)--;
  800f49:	8b 03                	mov    (%ebx),%eax
  800f4b:	ff 08                	decl   (%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  800f4d:	8b 43 08             	mov    0x8(%ebx),%eax
  800f50:	80 38 2d             	cmpb   $0x2d,(%eax)
  800f53:	75 06                	jne    800f5b <argnext+0x6a>
  800f55:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800f59:	74 0c                	je     800f67 <argnext+0x76>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  800f5b:	8b 53 08             	mov    0x8(%ebx),%edx
  800f5e:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  800f61:	42                   	inc    %edx
  800f62:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  800f65:	eb 13                	jmp    800f7a <argnext+0x89>

    endofargs:
	args->curarg = 0;
  800f67:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  800f6e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800f73:	eb 05                	jmp    800f7a <argnext+0x89>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  800f75:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  800f7a:	83 c4 14             	add    $0x14,%esp
  800f7d:	5b                   	pop    %ebx
  800f7e:	5d                   	pop    %ebp
  800f7f:	c3                   	ret    

00800f80 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  800f80:	55                   	push   %ebp
  800f81:	89 e5                	mov    %esp,%ebp
  800f83:	53                   	push   %ebx
  800f84:	83 ec 14             	sub    $0x14,%esp
  800f87:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  800f8a:	8b 43 08             	mov    0x8(%ebx),%eax
  800f8d:	85 c0                	test   %eax,%eax
  800f8f:	74 59                	je     800fea <argnextvalue+0x6a>
		return 0;
	if (*args->curarg) {
  800f91:	80 38 00             	cmpb   $0x0,(%eax)
  800f94:	74 0c                	je     800fa2 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  800f96:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  800f99:	c7 43 08 11 28 80 00 	movl   $0x802811,0x8(%ebx)
  800fa0:	eb 43                	jmp    800fe5 <argnextvalue+0x65>
	} else if (*args->argc > 1) {
  800fa2:	8b 03                	mov    (%ebx),%eax
  800fa4:	83 38 01             	cmpl   $0x1,(%eax)
  800fa7:	7e 2e                	jle    800fd7 <argnextvalue+0x57>
		args->argvalue = args->argv[1];
  800fa9:	8b 53 04             	mov    0x4(%ebx),%edx
  800fac:	8b 4a 04             	mov    0x4(%edx),%ecx
  800faf:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800fb2:	8b 00                	mov    (%eax),%eax
  800fb4:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  800fbb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fbf:	8d 42 08             	lea    0x8(%edx),%eax
  800fc2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fc6:	83 c2 04             	add    $0x4,%edx
  800fc9:	89 14 24             	mov    %edx,(%esp)
  800fcc:	e8 83 f9 ff ff       	call   800954 <memmove>
		(*args->argc)--;
  800fd1:	8b 03                	mov    (%ebx),%eax
  800fd3:	ff 08                	decl   (%eax)
  800fd5:	eb 0e                	jmp    800fe5 <argnextvalue+0x65>
	} else {
		args->argvalue = 0;
  800fd7:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  800fde:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  800fe5:	8b 43 0c             	mov    0xc(%ebx),%eax
  800fe8:	eb 05                	jmp    800fef <argnextvalue+0x6f>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  800fea:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  800fef:	83 c4 14             	add    $0x14,%esp
  800ff2:	5b                   	pop    %ebx
  800ff3:	5d                   	pop    %ebp
  800ff4:	c3                   	ret    

00800ff5 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  800ff5:	55                   	push   %ebp
  800ff6:	89 e5                	mov    %esp,%ebp
  800ff8:	83 ec 18             	sub    $0x18,%esp
  800ffb:	8b 55 08             	mov    0x8(%ebp),%edx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  800ffe:	8b 42 0c             	mov    0xc(%edx),%eax
  801001:	85 c0                	test   %eax,%eax
  801003:	75 08                	jne    80100d <argvalue+0x18>
  801005:	89 14 24             	mov    %edx,(%esp)
  801008:	e8 73 ff ff ff       	call   800f80 <argnextvalue>
}
  80100d:	c9                   	leave  
  80100e:	c3                   	ret    
	...

00801010 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801010:	55                   	push   %ebp
  801011:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801013:	8b 45 08             	mov    0x8(%ebp),%eax
  801016:	05 00 00 00 30       	add    $0x30000000,%eax
  80101b:	c1 e8 0c             	shr    $0xc,%eax
}
  80101e:	5d                   	pop    %ebp
  80101f:	c3                   	ret    

00801020 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801020:	55                   	push   %ebp
  801021:	89 e5                	mov    %esp,%ebp
  801023:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801026:	8b 45 08             	mov    0x8(%ebp),%eax
  801029:	89 04 24             	mov    %eax,(%esp)
  80102c:	e8 df ff ff ff       	call   801010 <fd2num>
  801031:	05 20 00 0d 00       	add    $0xd0020,%eax
  801036:	c1 e0 0c             	shl    $0xc,%eax
}
  801039:	c9                   	leave  
  80103a:	c3                   	ret    

0080103b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80103b:	55                   	push   %ebp
  80103c:	89 e5                	mov    %esp,%ebp
  80103e:	53                   	push   %ebx
  80103f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801042:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801047:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801049:	89 c2                	mov    %eax,%edx
  80104b:	c1 ea 16             	shr    $0x16,%edx
  80104e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801055:	f6 c2 01             	test   $0x1,%dl
  801058:	74 11                	je     80106b <fd_alloc+0x30>
  80105a:	89 c2                	mov    %eax,%edx
  80105c:	c1 ea 0c             	shr    $0xc,%edx
  80105f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801066:	f6 c2 01             	test   $0x1,%dl
  801069:	75 09                	jne    801074 <fd_alloc+0x39>
			*fd_store = fd;
  80106b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80106d:	b8 00 00 00 00       	mov    $0x0,%eax
  801072:	eb 17                	jmp    80108b <fd_alloc+0x50>
  801074:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801079:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80107e:	75 c7                	jne    801047 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801080:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801086:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80108b:	5b                   	pop    %ebx
  80108c:	5d                   	pop    %ebp
  80108d:	c3                   	ret    

0080108e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80108e:	55                   	push   %ebp
  80108f:	89 e5                	mov    %esp,%ebp
  801091:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801094:	83 f8 1f             	cmp    $0x1f,%eax
  801097:	77 36                	ja     8010cf <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801099:	05 00 00 0d 00       	add    $0xd0000,%eax
  80109e:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010a1:	89 c2                	mov    %eax,%edx
  8010a3:	c1 ea 16             	shr    $0x16,%edx
  8010a6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010ad:	f6 c2 01             	test   $0x1,%dl
  8010b0:	74 24                	je     8010d6 <fd_lookup+0x48>
  8010b2:	89 c2                	mov    %eax,%edx
  8010b4:	c1 ea 0c             	shr    $0xc,%edx
  8010b7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010be:	f6 c2 01             	test   $0x1,%dl
  8010c1:	74 1a                	je     8010dd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010c6:	89 02                	mov    %eax,(%edx)
	return 0;
  8010c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8010cd:	eb 13                	jmp    8010e2 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010d4:	eb 0c                	jmp    8010e2 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010db:	eb 05                	jmp    8010e2 <fd_lookup+0x54>
  8010dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8010e2:	5d                   	pop    %ebp
  8010e3:	c3                   	ret    

008010e4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8010e4:	55                   	push   %ebp
  8010e5:	89 e5                	mov    %esp,%ebp
  8010e7:	53                   	push   %ebx
  8010e8:	83 ec 14             	sub    $0x14,%esp
  8010eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8010f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8010f6:	eb 0e                	jmp    801106 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8010f8:	39 08                	cmp    %ecx,(%eax)
  8010fa:	75 09                	jne    801105 <dev_lookup+0x21>
			*dev = devtab[i];
  8010fc:	89 03                	mov    %eax,(%ebx)
			return 0;
  8010fe:	b8 00 00 00 00       	mov    $0x0,%eax
  801103:	eb 33                	jmp    801138 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801105:	42                   	inc    %edx
  801106:	8b 04 95 f0 2b 80 00 	mov    0x802bf0(,%edx,4),%eax
  80110d:	85 c0                	test   %eax,%eax
  80110f:	75 e7                	jne    8010f8 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801111:	a1 08 40 80 00       	mov    0x804008,%eax
  801116:	8b 40 48             	mov    0x48(%eax),%eax
  801119:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80111d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801121:	c7 04 24 74 2b 80 00 	movl   $0x802b74,(%esp)
  801128:	e8 03 f1 ff ff       	call   800230 <cprintf>
	*dev = 0;
  80112d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801133:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801138:	83 c4 14             	add    $0x14,%esp
  80113b:	5b                   	pop    %ebx
  80113c:	5d                   	pop    %ebp
  80113d:	c3                   	ret    

0080113e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80113e:	55                   	push   %ebp
  80113f:	89 e5                	mov    %esp,%ebp
  801141:	56                   	push   %esi
  801142:	53                   	push   %ebx
  801143:	83 ec 30             	sub    $0x30,%esp
  801146:	8b 75 08             	mov    0x8(%ebp),%esi
  801149:	8a 45 0c             	mov    0xc(%ebp),%al
  80114c:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80114f:	89 34 24             	mov    %esi,(%esp)
  801152:	e8 b9 fe ff ff       	call   801010 <fd2num>
  801157:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80115a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80115e:	89 04 24             	mov    %eax,(%esp)
  801161:	e8 28 ff ff ff       	call   80108e <fd_lookup>
  801166:	89 c3                	mov    %eax,%ebx
  801168:	85 c0                	test   %eax,%eax
  80116a:	78 05                	js     801171 <fd_close+0x33>
	    || fd != fd2)
  80116c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80116f:	74 0d                	je     80117e <fd_close+0x40>
		return (must_exist ? r : 0);
  801171:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801175:	75 46                	jne    8011bd <fd_close+0x7f>
  801177:	bb 00 00 00 00       	mov    $0x0,%ebx
  80117c:	eb 3f                	jmp    8011bd <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80117e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801181:	89 44 24 04          	mov    %eax,0x4(%esp)
  801185:	8b 06                	mov    (%esi),%eax
  801187:	89 04 24             	mov    %eax,(%esp)
  80118a:	e8 55 ff ff ff       	call   8010e4 <dev_lookup>
  80118f:	89 c3                	mov    %eax,%ebx
  801191:	85 c0                	test   %eax,%eax
  801193:	78 18                	js     8011ad <fd_close+0x6f>
		if (dev->dev_close)
  801195:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801198:	8b 40 10             	mov    0x10(%eax),%eax
  80119b:	85 c0                	test   %eax,%eax
  80119d:	74 09                	je     8011a8 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80119f:	89 34 24             	mov    %esi,(%esp)
  8011a2:	ff d0                	call   *%eax
  8011a4:	89 c3                	mov    %eax,%ebx
  8011a6:	eb 05                	jmp    8011ad <fd_close+0x6f>
		else
			r = 0;
  8011a8:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011ad:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011b8:	e8 b7 fa ff ff       	call   800c74 <sys_page_unmap>
	return r;
}
  8011bd:	89 d8                	mov    %ebx,%eax
  8011bf:	83 c4 30             	add    $0x30,%esp
  8011c2:	5b                   	pop    %ebx
  8011c3:	5e                   	pop    %esi
  8011c4:	5d                   	pop    %ebp
  8011c5:	c3                   	ret    

008011c6 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8011c6:	55                   	push   %ebp
  8011c7:	89 e5                	mov    %esp,%ebp
  8011c9:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d6:	89 04 24             	mov    %eax,(%esp)
  8011d9:	e8 b0 fe ff ff       	call   80108e <fd_lookup>
  8011de:	85 c0                	test   %eax,%eax
  8011e0:	78 13                	js     8011f5 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8011e2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8011e9:	00 
  8011ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011ed:	89 04 24             	mov    %eax,(%esp)
  8011f0:	e8 49 ff ff ff       	call   80113e <fd_close>
}
  8011f5:	c9                   	leave  
  8011f6:	c3                   	ret    

008011f7 <close_all>:

void
close_all(void)
{
  8011f7:	55                   	push   %ebp
  8011f8:	89 e5                	mov    %esp,%ebp
  8011fa:	53                   	push   %ebx
  8011fb:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8011fe:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801203:	89 1c 24             	mov    %ebx,(%esp)
  801206:	e8 bb ff ff ff       	call   8011c6 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80120b:	43                   	inc    %ebx
  80120c:	83 fb 20             	cmp    $0x20,%ebx
  80120f:	75 f2                	jne    801203 <close_all+0xc>
		close(i);
}
  801211:	83 c4 14             	add    $0x14,%esp
  801214:	5b                   	pop    %ebx
  801215:	5d                   	pop    %ebp
  801216:	c3                   	ret    

00801217 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801217:	55                   	push   %ebp
  801218:	89 e5                	mov    %esp,%ebp
  80121a:	57                   	push   %edi
  80121b:	56                   	push   %esi
  80121c:	53                   	push   %ebx
  80121d:	83 ec 4c             	sub    $0x4c,%esp
  801220:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801223:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801226:	89 44 24 04          	mov    %eax,0x4(%esp)
  80122a:	8b 45 08             	mov    0x8(%ebp),%eax
  80122d:	89 04 24             	mov    %eax,(%esp)
  801230:	e8 59 fe ff ff       	call   80108e <fd_lookup>
  801235:	89 c3                	mov    %eax,%ebx
  801237:	85 c0                	test   %eax,%eax
  801239:	0f 88 e1 00 00 00    	js     801320 <dup+0x109>
		return r;
	close(newfdnum);
  80123f:	89 3c 24             	mov    %edi,(%esp)
  801242:	e8 7f ff ff ff       	call   8011c6 <close>

	newfd = INDEX2FD(newfdnum);
  801247:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80124d:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801250:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801253:	89 04 24             	mov    %eax,(%esp)
  801256:	e8 c5 fd ff ff       	call   801020 <fd2data>
  80125b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80125d:	89 34 24             	mov    %esi,(%esp)
  801260:	e8 bb fd ff ff       	call   801020 <fd2data>
  801265:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801268:	89 d8                	mov    %ebx,%eax
  80126a:	c1 e8 16             	shr    $0x16,%eax
  80126d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801274:	a8 01                	test   $0x1,%al
  801276:	74 46                	je     8012be <dup+0xa7>
  801278:	89 d8                	mov    %ebx,%eax
  80127a:	c1 e8 0c             	shr    $0xc,%eax
  80127d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801284:	f6 c2 01             	test   $0x1,%dl
  801287:	74 35                	je     8012be <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801289:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801290:	25 07 0e 00 00       	and    $0xe07,%eax
  801295:	89 44 24 10          	mov    %eax,0x10(%esp)
  801299:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80129c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012a0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012a7:	00 
  8012a8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8012ac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012b3:	e8 69 f9 ff ff       	call   800c21 <sys_page_map>
  8012b8:	89 c3                	mov    %eax,%ebx
  8012ba:	85 c0                	test   %eax,%eax
  8012bc:	78 3b                	js     8012f9 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012c1:	89 c2                	mov    %eax,%edx
  8012c3:	c1 ea 0c             	shr    $0xc,%edx
  8012c6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012cd:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8012d3:	89 54 24 10          	mov    %edx,0x10(%esp)
  8012d7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8012db:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012e2:	00 
  8012e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012e7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012ee:	e8 2e f9 ff ff       	call   800c21 <sys_page_map>
  8012f3:	89 c3                	mov    %eax,%ebx
  8012f5:	85 c0                	test   %eax,%eax
  8012f7:	79 25                	jns    80131e <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8012f9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012fd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801304:	e8 6b f9 ff ff       	call   800c74 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801309:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80130c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801310:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801317:	e8 58 f9 ff ff       	call   800c74 <sys_page_unmap>
	return r;
  80131c:	eb 02                	jmp    801320 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80131e:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801320:	89 d8                	mov    %ebx,%eax
  801322:	83 c4 4c             	add    $0x4c,%esp
  801325:	5b                   	pop    %ebx
  801326:	5e                   	pop    %esi
  801327:	5f                   	pop    %edi
  801328:	5d                   	pop    %ebp
  801329:	c3                   	ret    

0080132a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80132a:	55                   	push   %ebp
  80132b:	89 e5                	mov    %esp,%ebp
  80132d:	53                   	push   %ebx
  80132e:	83 ec 24             	sub    $0x24,%esp
  801331:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801334:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801337:	89 44 24 04          	mov    %eax,0x4(%esp)
  80133b:	89 1c 24             	mov    %ebx,(%esp)
  80133e:	e8 4b fd ff ff       	call   80108e <fd_lookup>
  801343:	85 c0                	test   %eax,%eax
  801345:	78 6d                	js     8013b4 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801347:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80134a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80134e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801351:	8b 00                	mov    (%eax),%eax
  801353:	89 04 24             	mov    %eax,(%esp)
  801356:	e8 89 fd ff ff       	call   8010e4 <dev_lookup>
  80135b:	85 c0                	test   %eax,%eax
  80135d:	78 55                	js     8013b4 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80135f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801362:	8b 50 08             	mov    0x8(%eax),%edx
  801365:	83 e2 03             	and    $0x3,%edx
  801368:	83 fa 01             	cmp    $0x1,%edx
  80136b:	75 23                	jne    801390 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80136d:	a1 08 40 80 00       	mov    0x804008,%eax
  801372:	8b 40 48             	mov    0x48(%eax),%eax
  801375:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801379:	89 44 24 04          	mov    %eax,0x4(%esp)
  80137d:	c7 04 24 b5 2b 80 00 	movl   $0x802bb5,(%esp)
  801384:	e8 a7 ee ff ff       	call   800230 <cprintf>
		return -E_INVAL;
  801389:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80138e:	eb 24                	jmp    8013b4 <read+0x8a>
	}
	if (!dev->dev_read)
  801390:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801393:	8b 52 08             	mov    0x8(%edx),%edx
  801396:	85 d2                	test   %edx,%edx
  801398:	74 15                	je     8013af <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80139a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80139d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013a4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8013a8:	89 04 24             	mov    %eax,(%esp)
  8013ab:	ff d2                	call   *%edx
  8013ad:	eb 05                	jmp    8013b4 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013af:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8013b4:	83 c4 24             	add    $0x24,%esp
  8013b7:	5b                   	pop    %ebx
  8013b8:	5d                   	pop    %ebp
  8013b9:	c3                   	ret    

008013ba <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013ba:	55                   	push   %ebp
  8013bb:	89 e5                	mov    %esp,%ebp
  8013bd:	57                   	push   %edi
  8013be:	56                   	push   %esi
  8013bf:	53                   	push   %ebx
  8013c0:	83 ec 1c             	sub    $0x1c,%esp
  8013c3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013c6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013c9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013ce:	eb 23                	jmp    8013f3 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013d0:	89 f0                	mov    %esi,%eax
  8013d2:	29 d8                	sub    %ebx,%eax
  8013d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013db:	01 d8                	add    %ebx,%eax
  8013dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e1:	89 3c 24             	mov    %edi,(%esp)
  8013e4:	e8 41 ff ff ff       	call   80132a <read>
		if (m < 0)
  8013e9:	85 c0                	test   %eax,%eax
  8013eb:	78 10                	js     8013fd <readn+0x43>
			return m;
		if (m == 0)
  8013ed:	85 c0                	test   %eax,%eax
  8013ef:	74 0a                	je     8013fb <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013f1:	01 c3                	add    %eax,%ebx
  8013f3:	39 f3                	cmp    %esi,%ebx
  8013f5:	72 d9                	jb     8013d0 <readn+0x16>
  8013f7:	89 d8                	mov    %ebx,%eax
  8013f9:	eb 02                	jmp    8013fd <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8013fb:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8013fd:	83 c4 1c             	add    $0x1c,%esp
  801400:	5b                   	pop    %ebx
  801401:	5e                   	pop    %esi
  801402:	5f                   	pop    %edi
  801403:	5d                   	pop    %ebp
  801404:	c3                   	ret    

00801405 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801405:	55                   	push   %ebp
  801406:	89 e5                	mov    %esp,%ebp
  801408:	53                   	push   %ebx
  801409:	83 ec 24             	sub    $0x24,%esp
  80140c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80140f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801412:	89 44 24 04          	mov    %eax,0x4(%esp)
  801416:	89 1c 24             	mov    %ebx,(%esp)
  801419:	e8 70 fc ff ff       	call   80108e <fd_lookup>
  80141e:	85 c0                	test   %eax,%eax
  801420:	78 68                	js     80148a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801422:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801425:	89 44 24 04          	mov    %eax,0x4(%esp)
  801429:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80142c:	8b 00                	mov    (%eax),%eax
  80142e:	89 04 24             	mov    %eax,(%esp)
  801431:	e8 ae fc ff ff       	call   8010e4 <dev_lookup>
  801436:	85 c0                	test   %eax,%eax
  801438:	78 50                	js     80148a <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80143a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80143d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801441:	75 23                	jne    801466 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801443:	a1 08 40 80 00       	mov    0x804008,%eax
  801448:	8b 40 48             	mov    0x48(%eax),%eax
  80144b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80144f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801453:	c7 04 24 d1 2b 80 00 	movl   $0x802bd1,(%esp)
  80145a:	e8 d1 ed ff ff       	call   800230 <cprintf>
		return -E_INVAL;
  80145f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801464:	eb 24                	jmp    80148a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801466:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801469:	8b 52 0c             	mov    0xc(%edx),%edx
  80146c:	85 d2                	test   %edx,%edx
  80146e:	74 15                	je     801485 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801470:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801473:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801477:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80147a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80147e:	89 04 24             	mov    %eax,(%esp)
  801481:	ff d2                	call   *%edx
  801483:	eb 05                	jmp    80148a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801485:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80148a:	83 c4 24             	add    $0x24,%esp
  80148d:	5b                   	pop    %ebx
  80148e:	5d                   	pop    %ebp
  80148f:	c3                   	ret    

00801490 <seek>:

int
seek(int fdnum, off_t offset)
{
  801490:	55                   	push   %ebp
  801491:	89 e5                	mov    %esp,%ebp
  801493:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801496:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801499:	89 44 24 04          	mov    %eax,0x4(%esp)
  80149d:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a0:	89 04 24             	mov    %eax,(%esp)
  8014a3:	e8 e6 fb ff ff       	call   80108e <fd_lookup>
  8014a8:	85 c0                	test   %eax,%eax
  8014aa:	78 0e                	js     8014ba <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8014ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014b2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014ba:	c9                   	leave  
  8014bb:	c3                   	ret    

008014bc <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014bc:	55                   	push   %ebp
  8014bd:	89 e5                	mov    %esp,%ebp
  8014bf:	53                   	push   %ebx
  8014c0:	83 ec 24             	sub    $0x24,%esp
  8014c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014cd:	89 1c 24             	mov    %ebx,(%esp)
  8014d0:	e8 b9 fb ff ff       	call   80108e <fd_lookup>
  8014d5:	85 c0                	test   %eax,%eax
  8014d7:	78 61                	js     80153a <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014e3:	8b 00                	mov    (%eax),%eax
  8014e5:	89 04 24             	mov    %eax,(%esp)
  8014e8:	e8 f7 fb ff ff       	call   8010e4 <dev_lookup>
  8014ed:	85 c0                	test   %eax,%eax
  8014ef:	78 49                	js     80153a <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014f4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014f8:	75 23                	jne    80151d <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8014fa:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8014ff:	8b 40 48             	mov    0x48(%eax),%eax
  801502:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801506:	89 44 24 04          	mov    %eax,0x4(%esp)
  80150a:	c7 04 24 94 2b 80 00 	movl   $0x802b94,(%esp)
  801511:	e8 1a ed ff ff       	call   800230 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801516:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80151b:	eb 1d                	jmp    80153a <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  80151d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801520:	8b 52 18             	mov    0x18(%edx),%edx
  801523:	85 d2                	test   %edx,%edx
  801525:	74 0e                	je     801535 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801527:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80152a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80152e:	89 04 24             	mov    %eax,(%esp)
  801531:	ff d2                	call   *%edx
  801533:	eb 05                	jmp    80153a <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801535:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80153a:	83 c4 24             	add    $0x24,%esp
  80153d:	5b                   	pop    %ebx
  80153e:	5d                   	pop    %ebp
  80153f:	c3                   	ret    

00801540 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801540:	55                   	push   %ebp
  801541:	89 e5                	mov    %esp,%ebp
  801543:	53                   	push   %ebx
  801544:	83 ec 24             	sub    $0x24,%esp
  801547:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80154a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80154d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801551:	8b 45 08             	mov    0x8(%ebp),%eax
  801554:	89 04 24             	mov    %eax,(%esp)
  801557:	e8 32 fb ff ff       	call   80108e <fd_lookup>
  80155c:	85 c0                	test   %eax,%eax
  80155e:	78 52                	js     8015b2 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801560:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801563:	89 44 24 04          	mov    %eax,0x4(%esp)
  801567:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80156a:	8b 00                	mov    (%eax),%eax
  80156c:	89 04 24             	mov    %eax,(%esp)
  80156f:	e8 70 fb ff ff       	call   8010e4 <dev_lookup>
  801574:	85 c0                	test   %eax,%eax
  801576:	78 3a                	js     8015b2 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801578:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80157b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80157f:	74 2c                	je     8015ad <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801581:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801584:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80158b:	00 00 00 
	stat->st_isdir = 0;
  80158e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801595:	00 00 00 
	stat->st_dev = dev;
  801598:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80159e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015a2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015a5:	89 14 24             	mov    %edx,(%esp)
  8015a8:	ff 50 14             	call   *0x14(%eax)
  8015ab:	eb 05                	jmp    8015b2 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015ad:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015b2:	83 c4 24             	add    $0x24,%esp
  8015b5:	5b                   	pop    %ebx
  8015b6:	5d                   	pop    %ebp
  8015b7:	c3                   	ret    

008015b8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015b8:	55                   	push   %ebp
  8015b9:	89 e5                	mov    %esp,%ebp
  8015bb:	56                   	push   %esi
  8015bc:	53                   	push   %ebx
  8015bd:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015c0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8015c7:	00 
  8015c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8015cb:	89 04 24             	mov    %eax,(%esp)
  8015ce:	e8 2d 02 00 00       	call   801800 <open>
  8015d3:	89 c3                	mov    %eax,%ebx
  8015d5:	85 c0                	test   %eax,%eax
  8015d7:	78 1b                	js     8015f4 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8015d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015e0:	89 1c 24             	mov    %ebx,(%esp)
  8015e3:	e8 58 ff ff ff       	call   801540 <fstat>
  8015e8:	89 c6                	mov    %eax,%esi
	close(fd);
  8015ea:	89 1c 24             	mov    %ebx,(%esp)
  8015ed:	e8 d4 fb ff ff       	call   8011c6 <close>
	return r;
  8015f2:	89 f3                	mov    %esi,%ebx
}
  8015f4:	89 d8                	mov    %ebx,%eax
  8015f6:	83 c4 10             	add    $0x10,%esp
  8015f9:	5b                   	pop    %ebx
  8015fa:	5e                   	pop    %esi
  8015fb:	5d                   	pop    %ebp
  8015fc:	c3                   	ret    
  8015fd:	00 00                	add    %al,(%eax)
	...

00801600 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801600:	55                   	push   %ebp
  801601:	89 e5                	mov    %esp,%ebp
  801603:	56                   	push   %esi
  801604:	53                   	push   %ebx
  801605:	83 ec 10             	sub    $0x10,%esp
  801608:	89 c3                	mov    %eax,%ebx
  80160a:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  80160c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801613:	75 11                	jne    801626 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801615:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80161c:	e8 fa 0e 00 00       	call   80251b <ipc_find_env>
  801621:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801626:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80162d:	00 
  80162e:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801635:	00 
  801636:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80163a:	a1 00 40 80 00       	mov    0x804000,%eax
  80163f:	89 04 24             	mov    %eax,(%esp)
  801642:	e8 66 0e 00 00       	call   8024ad <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801647:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80164e:	00 
  80164f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801653:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80165a:	e8 e5 0d 00 00       	call   802444 <ipc_recv>
}
  80165f:	83 c4 10             	add    $0x10,%esp
  801662:	5b                   	pop    %ebx
  801663:	5e                   	pop    %esi
  801664:	5d                   	pop    %ebp
  801665:	c3                   	ret    

00801666 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801666:	55                   	push   %ebp
  801667:	89 e5                	mov    %esp,%ebp
  801669:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80166c:	8b 45 08             	mov    0x8(%ebp),%eax
  80166f:	8b 40 0c             	mov    0xc(%eax),%eax
  801672:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801677:	8b 45 0c             	mov    0xc(%ebp),%eax
  80167a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80167f:	ba 00 00 00 00       	mov    $0x0,%edx
  801684:	b8 02 00 00 00       	mov    $0x2,%eax
  801689:	e8 72 ff ff ff       	call   801600 <fsipc>
}
  80168e:	c9                   	leave  
  80168f:	c3                   	ret    

00801690 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801690:	55                   	push   %ebp
  801691:	89 e5                	mov    %esp,%ebp
  801693:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801696:	8b 45 08             	mov    0x8(%ebp),%eax
  801699:	8b 40 0c             	mov    0xc(%eax),%eax
  80169c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a6:	b8 06 00 00 00       	mov    $0x6,%eax
  8016ab:	e8 50 ff ff ff       	call   801600 <fsipc>
}
  8016b0:	c9                   	leave  
  8016b1:	c3                   	ret    

008016b2 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016b2:	55                   	push   %ebp
  8016b3:	89 e5                	mov    %esp,%ebp
  8016b5:	53                   	push   %ebx
  8016b6:	83 ec 14             	sub    $0x14,%esp
  8016b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8016bf:	8b 40 0c             	mov    0xc(%eax),%eax
  8016c2:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8016cc:	b8 05 00 00 00       	mov    $0x5,%eax
  8016d1:	e8 2a ff ff ff       	call   801600 <fsipc>
  8016d6:	85 c0                	test   %eax,%eax
  8016d8:	78 2b                	js     801705 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016da:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8016e1:	00 
  8016e2:	89 1c 24             	mov    %ebx,(%esp)
  8016e5:	e8 f1 f0 ff ff       	call   8007db <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016ea:	a1 80 50 80 00       	mov    0x805080,%eax
  8016ef:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016f5:	a1 84 50 80 00       	mov    0x805084,%eax
  8016fa:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801700:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801705:	83 c4 14             	add    $0x14,%esp
  801708:	5b                   	pop    %ebx
  801709:	5d                   	pop    %ebp
  80170a:	c3                   	ret    

0080170b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80170b:	55                   	push   %ebp
  80170c:	89 e5                	mov    %esp,%ebp
  80170e:	83 ec 18             	sub    $0x18,%esp
  801711:	8b 55 10             	mov    0x10(%ebp),%edx
  801714:	89 d0                	mov    %edx,%eax
  801716:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  80171c:	76 05                	jbe    801723 <devfile_write+0x18>
  80171e:	b8 00 10 00 00       	mov    $0x1000,%eax
	//panic("devfile_write not implemented");
	int r;
	//uint32_t maxsize = BLKSIZE - sizeof(int) - sizeof(size_t);	
	if (n > BLKSIZE)
		n = BLKSIZE;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801723:	8b 55 08             	mov    0x8(%ebp),%edx
  801726:	8b 52 0c             	mov    0xc(%edx),%edx
  801729:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80172f:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801734:	89 44 24 08          	mov    %eax,0x8(%esp)
  801738:	8b 45 0c             	mov    0xc(%ebp),%eax
  80173b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80173f:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801746:	e8 09 f2 ff ff       	call   800954 <memmove>
	 
	return fsipc(FSREQ_WRITE, NULL);
  80174b:	ba 00 00 00 00       	mov    $0x0,%edx
  801750:	b8 04 00 00 00       	mov    $0x4,%eax
  801755:	e8 a6 fe ff ff       	call   801600 <fsipc>
}
  80175a:	c9                   	leave  
  80175b:	c3                   	ret    

0080175c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80175c:	55                   	push   %ebp
  80175d:	89 e5                	mov    %esp,%ebp
  80175f:	56                   	push   %esi
  801760:	53                   	push   %ebx
  801761:	83 ec 10             	sub    $0x10,%esp
  801764:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801767:	8b 45 08             	mov    0x8(%ebp),%eax
  80176a:	8b 40 0c             	mov    0xc(%eax),%eax
  80176d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801772:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801778:	ba 00 00 00 00       	mov    $0x0,%edx
  80177d:	b8 03 00 00 00       	mov    $0x3,%eax
  801782:	e8 79 fe ff ff       	call   801600 <fsipc>
  801787:	89 c3                	mov    %eax,%ebx
  801789:	85 c0                	test   %eax,%eax
  80178b:	78 6a                	js     8017f7 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  80178d:	39 c6                	cmp    %eax,%esi
  80178f:	73 24                	jae    8017b5 <devfile_read+0x59>
  801791:	c7 44 24 0c 04 2c 80 	movl   $0x802c04,0xc(%esp)
  801798:	00 
  801799:	c7 44 24 08 0b 2c 80 	movl   $0x802c0b,0x8(%esp)
  8017a0:	00 
  8017a1:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8017a8:	00 
  8017a9:	c7 04 24 20 2c 80 00 	movl   $0x802c20,(%esp)
  8017b0:	e8 37 0c 00 00       	call   8023ec <_panic>
	assert(r <= PGSIZE);
  8017b5:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017ba:	7e 24                	jle    8017e0 <devfile_read+0x84>
  8017bc:	c7 44 24 0c 2b 2c 80 	movl   $0x802c2b,0xc(%esp)
  8017c3:	00 
  8017c4:	c7 44 24 08 0b 2c 80 	movl   $0x802c0b,0x8(%esp)
  8017cb:	00 
  8017cc:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8017d3:	00 
  8017d4:	c7 04 24 20 2c 80 00 	movl   $0x802c20,(%esp)
  8017db:	e8 0c 0c 00 00       	call   8023ec <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017e0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017e4:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8017eb:	00 
  8017ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017ef:	89 04 24             	mov    %eax,(%esp)
  8017f2:	e8 5d f1 ff ff       	call   800954 <memmove>
	return r;
}
  8017f7:	89 d8                	mov    %ebx,%eax
  8017f9:	83 c4 10             	add    $0x10,%esp
  8017fc:	5b                   	pop    %ebx
  8017fd:	5e                   	pop    %esi
  8017fe:	5d                   	pop    %ebp
  8017ff:	c3                   	ret    

00801800 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801800:	55                   	push   %ebp
  801801:	89 e5                	mov    %esp,%ebp
  801803:	56                   	push   %esi
  801804:	53                   	push   %ebx
  801805:	83 ec 20             	sub    $0x20,%esp
  801808:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80180b:	89 34 24             	mov    %esi,(%esp)
  80180e:	e8 95 ef ff ff       	call   8007a8 <strlen>
  801813:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801818:	7f 60                	jg     80187a <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80181a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80181d:	89 04 24             	mov    %eax,(%esp)
  801820:	e8 16 f8 ff ff       	call   80103b <fd_alloc>
  801825:	89 c3                	mov    %eax,%ebx
  801827:	85 c0                	test   %eax,%eax
  801829:	78 54                	js     80187f <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80182b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80182f:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801836:	e8 a0 ef ff ff       	call   8007db <strcpy>
	fsipcbuf.open.req_omode = mode;
  80183b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80183e:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801843:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801846:	b8 01 00 00 00       	mov    $0x1,%eax
  80184b:	e8 b0 fd ff ff       	call   801600 <fsipc>
  801850:	89 c3                	mov    %eax,%ebx
  801852:	85 c0                	test   %eax,%eax
  801854:	79 15                	jns    80186b <open+0x6b>
		fd_close(fd, 0);
  801856:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80185d:	00 
  80185e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801861:	89 04 24             	mov    %eax,(%esp)
  801864:	e8 d5 f8 ff ff       	call   80113e <fd_close>
		return r;
  801869:	eb 14                	jmp    80187f <open+0x7f>
	}

	return fd2num(fd);
  80186b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80186e:	89 04 24             	mov    %eax,(%esp)
  801871:	e8 9a f7 ff ff       	call   801010 <fd2num>
  801876:	89 c3                	mov    %eax,%ebx
  801878:	eb 05                	jmp    80187f <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80187a:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80187f:	89 d8                	mov    %ebx,%eax
  801881:	83 c4 20             	add    $0x20,%esp
  801884:	5b                   	pop    %ebx
  801885:	5e                   	pop    %esi
  801886:	5d                   	pop    %ebp
  801887:	c3                   	ret    

00801888 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801888:	55                   	push   %ebp
  801889:	89 e5                	mov    %esp,%ebp
  80188b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80188e:	ba 00 00 00 00       	mov    $0x0,%edx
  801893:	b8 08 00 00 00       	mov    $0x8,%eax
  801898:	e8 63 fd ff ff       	call   801600 <fsipc>
}
  80189d:	c9                   	leave  
  80189e:	c3                   	ret    
	...

008018a0 <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  8018a0:	55                   	push   %ebp
  8018a1:	89 e5                	mov    %esp,%ebp
  8018a3:	53                   	push   %ebx
  8018a4:	83 ec 14             	sub    $0x14,%esp
  8018a7:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  8018a9:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8018ad:	7e 32                	jle    8018e1 <writebuf+0x41>
		ssize_t result = write(b->fd, b->buf, b->idx);
  8018af:	8b 40 04             	mov    0x4(%eax),%eax
  8018b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018b6:	8d 43 10             	lea    0x10(%ebx),%eax
  8018b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018bd:	8b 03                	mov    (%ebx),%eax
  8018bf:	89 04 24             	mov    %eax,(%esp)
  8018c2:	e8 3e fb ff ff       	call   801405 <write>
		if (result > 0)
  8018c7:	85 c0                	test   %eax,%eax
  8018c9:	7e 03                	jle    8018ce <writebuf+0x2e>
			b->result += result;
  8018cb:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8018ce:	39 43 04             	cmp    %eax,0x4(%ebx)
  8018d1:	74 0e                	je     8018e1 <writebuf+0x41>
			b->error = (result < 0 ? result : 0);
  8018d3:	89 c2                	mov    %eax,%edx
  8018d5:	85 c0                	test   %eax,%eax
  8018d7:	7e 05                	jle    8018de <writebuf+0x3e>
  8018d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8018de:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  8018e1:	83 c4 14             	add    $0x14,%esp
  8018e4:	5b                   	pop    %ebx
  8018e5:	5d                   	pop    %ebp
  8018e6:	c3                   	ret    

008018e7 <putch>:

static void
putch(int ch, void *thunk)
{
  8018e7:	55                   	push   %ebp
  8018e8:	89 e5                	mov    %esp,%ebp
  8018ea:	53                   	push   %ebx
  8018eb:	83 ec 04             	sub    $0x4,%esp
  8018ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8018f1:	8b 43 04             	mov    0x4(%ebx),%eax
  8018f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8018f7:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  8018fb:	40                   	inc    %eax
  8018fc:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  8018ff:	3d 00 01 00 00       	cmp    $0x100,%eax
  801904:	75 0e                	jne    801914 <putch+0x2d>
		writebuf(b);
  801906:	89 d8                	mov    %ebx,%eax
  801908:	e8 93 ff ff ff       	call   8018a0 <writebuf>
		b->idx = 0;
  80190d:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801914:	83 c4 04             	add    $0x4,%esp
  801917:	5b                   	pop    %ebx
  801918:	5d                   	pop    %ebp
  801919:	c3                   	ret    

0080191a <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  80191a:	55                   	push   %ebp
  80191b:	89 e5                	mov    %esp,%ebp
  80191d:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  801923:	8b 45 08             	mov    0x8(%ebp),%eax
  801926:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  80192c:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801933:	00 00 00 
	b.result = 0;
  801936:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80193d:	00 00 00 
	b.error = 1;
  801940:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801947:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  80194a:	8b 45 10             	mov    0x10(%ebp),%eax
  80194d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801951:	8b 45 0c             	mov    0xc(%ebp),%eax
  801954:	89 44 24 08          	mov    %eax,0x8(%esp)
  801958:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80195e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801962:	c7 04 24 e7 18 80 00 	movl   $0x8018e7,(%esp)
  801969:	e8 24 ea ff ff       	call   800392 <vprintfmt>
	if (b.idx > 0)
  80196e:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801975:	7e 0b                	jle    801982 <vfprintf+0x68>
		writebuf(&b);
  801977:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80197d:	e8 1e ff ff ff       	call   8018a0 <writebuf>

	return (b.result ? b.result : b.error);
  801982:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801988:	85 c0                	test   %eax,%eax
  80198a:	75 06                	jne    801992 <vfprintf+0x78>
  80198c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  801992:	c9                   	leave  
  801993:	c3                   	ret    

00801994 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801994:	55                   	push   %ebp
  801995:	89 e5                	mov    %esp,%ebp
  801997:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80199a:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  80199d:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ab:	89 04 24             	mov    %eax,(%esp)
  8019ae:	e8 67 ff ff ff       	call   80191a <vfprintf>
	va_end(ap);

	return cnt;
}
  8019b3:	c9                   	leave  
  8019b4:	c3                   	ret    

008019b5 <printf>:

int
printf(const char *fmt, ...)
{
  8019b5:	55                   	push   %ebp
  8019b6:	89 e5                	mov    %esp,%ebp
  8019b8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8019bb:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8019be:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019c9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8019d0:	e8 45 ff ff ff       	call   80191a <vfprintf>
	va_end(ap);

	return cnt;
}
  8019d5:	c9                   	leave  
  8019d6:	c3                   	ret    
	...

008019d8 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8019d8:	55                   	push   %ebp
  8019d9:	89 e5                	mov    %esp,%ebp
  8019db:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  8019de:	c7 44 24 04 37 2c 80 	movl   $0x802c37,0x4(%esp)
  8019e5:	00 
  8019e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019e9:	89 04 24             	mov    %eax,(%esp)
  8019ec:	e8 ea ed ff ff       	call   8007db <strcpy>
	return 0;
}
  8019f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8019f6:	c9                   	leave  
  8019f7:	c3                   	ret    

008019f8 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8019f8:	55                   	push   %ebp
  8019f9:	89 e5                	mov    %esp,%ebp
  8019fb:	53                   	push   %ebx
  8019fc:	83 ec 14             	sub    $0x14,%esp
  8019ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801a02:	89 1c 24             	mov    %ebx,(%esp)
  801a05:	e8 4a 0b 00 00       	call   802554 <pageref>
  801a0a:	83 f8 01             	cmp    $0x1,%eax
  801a0d:	75 0d                	jne    801a1c <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  801a0f:	8b 43 0c             	mov    0xc(%ebx),%eax
  801a12:	89 04 24             	mov    %eax,(%esp)
  801a15:	e8 1f 03 00 00       	call   801d39 <nsipc_close>
  801a1a:	eb 05                	jmp    801a21 <devsock_close+0x29>
	else
		return 0;
  801a1c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a21:	83 c4 14             	add    $0x14,%esp
  801a24:	5b                   	pop    %ebx
  801a25:	5d                   	pop    %ebp
  801a26:	c3                   	ret    

00801a27 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801a27:	55                   	push   %ebp
  801a28:	89 e5                	mov    %esp,%ebp
  801a2a:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801a2d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801a34:	00 
  801a35:	8b 45 10             	mov    0x10(%ebp),%eax
  801a38:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a3f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a43:	8b 45 08             	mov    0x8(%ebp),%eax
  801a46:	8b 40 0c             	mov    0xc(%eax),%eax
  801a49:	89 04 24             	mov    %eax,(%esp)
  801a4c:	e8 e3 03 00 00       	call   801e34 <nsipc_send>
}
  801a51:	c9                   	leave  
  801a52:	c3                   	ret    

00801a53 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801a53:	55                   	push   %ebp
  801a54:	89 e5                	mov    %esp,%ebp
  801a56:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801a59:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801a60:	00 
  801a61:	8b 45 10             	mov    0x10(%ebp),%eax
  801a64:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a68:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a6b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a6f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a72:	8b 40 0c             	mov    0xc(%eax),%eax
  801a75:	89 04 24             	mov    %eax,(%esp)
  801a78:	e8 37 03 00 00       	call   801db4 <nsipc_recv>
}
  801a7d:	c9                   	leave  
  801a7e:	c3                   	ret    

00801a7f <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801a7f:	55                   	push   %ebp
  801a80:	89 e5                	mov    %esp,%ebp
  801a82:	56                   	push   %esi
  801a83:	53                   	push   %ebx
  801a84:	83 ec 20             	sub    $0x20,%esp
  801a87:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801a89:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a8c:	89 04 24             	mov    %eax,(%esp)
  801a8f:	e8 a7 f5 ff ff       	call   80103b <fd_alloc>
  801a94:	89 c3                	mov    %eax,%ebx
  801a96:	85 c0                	test   %eax,%eax
  801a98:	78 21                	js     801abb <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a9a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801aa1:	00 
  801aa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aa5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aa9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ab0:	e8 18 f1 ff ff       	call   800bcd <sys_page_alloc>
  801ab5:	89 c3                	mov    %eax,%ebx
  801ab7:	85 c0                	test   %eax,%eax
  801ab9:	79 0a                	jns    801ac5 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  801abb:	89 34 24             	mov    %esi,(%esp)
  801abe:	e8 76 02 00 00       	call   801d39 <nsipc_close>
		return r;
  801ac3:	eb 22                	jmp    801ae7 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801ac5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801acb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ace:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801ada:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801add:	89 04 24             	mov    %eax,(%esp)
  801ae0:	e8 2b f5 ff ff       	call   801010 <fd2num>
  801ae5:	89 c3                	mov    %eax,%ebx
}
  801ae7:	89 d8                	mov    %ebx,%eax
  801ae9:	83 c4 20             	add    $0x20,%esp
  801aec:	5b                   	pop    %ebx
  801aed:	5e                   	pop    %esi
  801aee:	5d                   	pop    %ebp
  801aef:	c3                   	ret    

00801af0 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801af0:	55                   	push   %ebp
  801af1:	89 e5                	mov    %esp,%ebp
  801af3:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801af6:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801af9:	89 54 24 04          	mov    %edx,0x4(%esp)
  801afd:	89 04 24             	mov    %eax,(%esp)
  801b00:	e8 89 f5 ff ff       	call   80108e <fd_lookup>
  801b05:	85 c0                	test   %eax,%eax
  801b07:	78 17                	js     801b20 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801b09:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b0c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b12:	39 10                	cmp    %edx,(%eax)
  801b14:	75 05                	jne    801b1b <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801b16:	8b 40 0c             	mov    0xc(%eax),%eax
  801b19:	eb 05                	jmp    801b20 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801b1b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801b20:	c9                   	leave  
  801b21:	c3                   	ret    

00801b22 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b22:	55                   	push   %ebp
  801b23:	89 e5                	mov    %esp,%ebp
  801b25:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b28:	8b 45 08             	mov    0x8(%ebp),%eax
  801b2b:	e8 c0 ff ff ff       	call   801af0 <fd2sockid>
  801b30:	85 c0                	test   %eax,%eax
  801b32:	78 1f                	js     801b53 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b34:	8b 55 10             	mov    0x10(%ebp),%edx
  801b37:	89 54 24 08          	mov    %edx,0x8(%esp)
  801b3b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b3e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b42:	89 04 24             	mov    %eax,(%esp)
  801b45:	e8 38 01 00 00       	call   801c82 <nsipc_accept>
  801b4a:	85 c0                	test   %eax,%eax
  801b4c:	78 05                	js     801b53 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801b4e:	e8 2c ff ff ff       	call   801a7f <alloc_sockfd>
}
  801b53:	c9                   	leave  
  801b54:	c3                   	ret    

00801b55 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b55:	55                   	push   %ebp
  801b56:	89 e5                	mov    %esp,%ebp
  801b58:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5e:	e8 8d ff ff ff       	call   801af0 <fd2sockid>
  801b63:	85 c0                	test   %eax,%eax
  801b65:	78 16                	js     801b7d <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801b67:	8b 55 10             	mov    0x10(%ebp),%edx
  801b6a:	89 54 24 08          	mov    %edx,0x8(%esp)
  801b6e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b71:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b75:	89 04 24             	mov    %eax,(%esp)
  801b78:	e8 5b 01 00 00       	call   801cd8 <nsipc_bind>
}
  801b7d:	c9                   	leave  
  801b7e:	c3                   	ret    

00801b7f <shutdown>:

int
shutdown(int s, int how)
{
  801b7f:	55                   	push   %ebp
  801b80:	89 e5                	mov    %esp,%ebp
  801b82:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b85:	8b 45 08             	mov    0x8(%ebp),%eax
  801b88:	e8 63 ff ff ff       	call   801af0 <fd2sockid>
  801b8d:	85 c0                	test   %eax,%eax
  801b8f:	78 0f                	js     801ba0 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801b91:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b94:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b98:	89 04 24             	mov    %eax,(%esp)
  801b9b:	e8 77 01 00 00       	call   801d17 <nsipc_shutdown>
}
  801ba0:	c9                   	leave  
  801ba1:	c3                   	ret    

00801ba2 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ba2:	55                   	push   %ebp
  801ba3:	89 e5                	mov    %esp,%ebp
  801ba5:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ba8:	8b 45 08             	mov    0x8(%ebp),%eax
  801bab:	e8 40 ff ff ff       	call   801af0 <fd2sockid>
  801bb0:	85 c0                	test   %eax,%eax
  801bb2:	78 16                	js     801bca <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801bb4:	8b 55 10             	mov    0x10(%ebp),%edx
  801bb7:	89 54 24 08          	mov    %edx,0x8(%esp)
  801bbb:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bbe:	89 54 24 04          	mov    %edx,0x4(%esp)
  801bc2:	89 04 24             	mov    %eax,(%esp)
  801bc5:	e8 89 01 00 00       	call   801d53 <nsipc_connect>
}
  801bca:	c9                   	leave  
  801bcb:	c3                   	ret    

00801bcc <listen>:

int
listen(int s, int backlog)
{
  801bcc:	55                   	push   %ebp
  801bcd:	89 e5                	mov    %esp,%ebp
  801bcf:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bd2:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd5:	e8 16 ff ff ff       	call   801af0 <fd2sockid>
  801bda:	85 c0                	test   %eax,%eax
  801bdc:	78 0f                	js     801bed <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801bde:	8b 55 0c             	mov    0xc(%ebp),%edx
  801be1:	89 54 24 04          	mov    %edx,0x4(%esp)
  801be5:	89 04 24             	mov    %eax,(%esp)
  801be8:	e8 a5 01 00 00       	call   801d92 <nsipc_listen>
}
  801bed:	c9                   	leave  
  801bee:	c3                   	ret    

00801bef <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801bef:	55                   	push   %ebp
  801bf0:	89 e5                	mov    %esp,%ebp
  801bf2:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801bf5:	8b 45 10             	mov    0x10(%ebp),%eax
  801bf8:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bfc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c03:	8b 45 08             	mov    0x8(%ebp),%eax
  801c06:	89 04 24             	mov    %eax,(%esp)
  801c09:	e8 99 02 00 00       	call   801ea7 <nsipc_socket>
  801c0e:	85 c0                	test   %eax,%eax
  801c10:	78 05                	js     801c17 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801c12:	e8 68 fe ff ff       	call   801a7f <alloc_sockfd>
}
  801c17:	c9                   	leave  
  801c18:	c3                   	ret    
  801c19:	00 00                	add    %al,(%eax)
	...

00801c1c <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801c1c:	55                   	push   %ebp
  801c1d:	89 e5                	mov    %esp,%ebp
  801c1f:	53                   	push   %ebx
  801c20:	83 ec 14             	sub    $0x14,%esp
  801c23:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801c25:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801c2c:	75 11                	jne    801c3f <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801c2e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801c35:	e8 e1 08 00 00       	call   80251b <ipc_find_env>
  801c3a:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801c3f:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801c46:	00 
  801c47:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801c4e:	00 
  801c4f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c53:	a1 04 40 80 00       	mov    0x804004,%eax
  801c58:	89 04 24             	mov    %eax,(%esp)
  801c5b:	e8 4d 08 00 00       	call   8024ad <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801c60:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c67:	00 
  801c68:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c6f:	00 
  801c70:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c77:	e8 c8 07 00 00       	call   802444 <ipc_recv>
}
  801c7c:	83 c4 14             	add    $0x14,%esp
  801c7f:	5b                   	pop    %ebx
  801c80:	5d                   	pop    %ebp
  801c81:	c3                   	ret    

00801c82 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c82:	55                   	push   %ebp
  801c83:	89 e5                	mov    %esp,%ebp
  801c85:	56                   	push   %esi
  801c86:	53                   	push   %ebx
  801c87:	83 ec 10             	sub    $0x10,%esp
  801c8a:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801c8d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c90:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801c95:	8b 06                	mov    (%esi),%eax
  801c97:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801c9c:	b8 01 00 00 00       	mov    $0x1,%eax
  801ca1:	e8 76 ff ff ff       	call   801c1c <nsipc>
  801ca6:	89 c3                	mov    %eax,%ebx
  801ca8:	85 c0                	test   %eax,%eax
  801caa:	78 23                	js     801ccf <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801cac:	a1 10 60 80 00       	mov    0x806010,%eax
  801cb1:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cb5:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801cbc:	00 
  801cbd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cc0:	89 04 24             	mov    %eax,(%esp)
  801cc3:	e8 8c ec ff ff       	call   800954 <memmove>
		*addrlen = ret->ret_addrlen;
  801cc8:	a1 10 60 80 00       	mov    0x806010,%eax
  801ccd:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801ccf:	89 d8                	mov    %ebx,%eax
  801cd1:	83 c4 10             	add    $0x10,%esp
  801cd4:	5b                   	pop    %ebx
  801cd5:	5e                   	pop    %esi
  801cd6:	5d                   	pop    %ebp
  801cd7:	c3                   	ret    

00801cd8 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801cd8:	55                   	push   %ebp
  801cd9:	89 e5                	mov    %esp,%ebp
  801cdb:	53                   	push   %ebx
  801cdc:	83 ec 14             	sub    $0x14,%esp
  801cdf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801ce2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce5:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801cea:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801cee:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cf1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cf5:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801cfc:	e8 53 ec ff ff       	call   800954 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801d01:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801d07:	b8 02 00 00 00       	mov    $0x2,%eax
  801d0c:	e8 0b ff ff ff       	call   801c1c <nsipc>
}
  801d11:	83 c4 14             	add    $0x14,%esp
  801d14:	5b                   	pop    %ebx
  801d15:	5d                   	pop    %ebp
  801d16:	c3                   	ret    

00801d17 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801d17:	55                   	push   %ebp
  801d18:	89 e5                	mov    %esp,%ebp
  801d1a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801d1d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d20:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801d25:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d28:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801d2d:	b8 03 00 00 00       	mov    $0x3,%eax
  801d32:	e8 e5 fe ff ff       	call   801c1c <nsipc>
}
  801d37:	c9                   	leave  
  801d38:	c3                   	ret    

00801d39 <nsipc_close>:

int
nsipc_close(int s)
{
  801d39:	55                   	push   %ebp
  801d3a:	89 e5                	mov    %esp,%ebp
  801d3c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801d3f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d42:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801d47:	b8 04 00 00 00       	mov    $0x4,%eax
  801d4c:	e8 cb fe ff ff       	call   801c1c <nsipc>
}
  801d51:	c9                   	leave  
  801d52:	c3                   	ret    

00801d53 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d53:	55                   	push   %ebp
  801d54:	89 e5                	mov    %esp,%ebp
  801d56:	53                   	push   %ebx
  801d57:	83 ec 14             	sub    $0x14,%esp
  801d5a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801d5d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d60:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801d65:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d69:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d6c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d70:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801d77:	e8 d8 eb ff ff       	call   800954 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801d7c:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801d82:	b8 05 00 00 00       	mov    $0x5,%eax
  801d87:	e8 90 fe ff ff       	call   801c1c <nsipc>
}
  801d8c:	83 c4 14             	add    $0x14,%esp
  801d8f:	5b                   	pop    %ebx
  801d90:	5d                   	pop    %ebp
  801d91:	c3                   	ret    

00801d92 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801d92:	55                   	push   %ebp
  801d93:	89 e5                	mov    %esp,%ebp
  801d95:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801d98:	8b 45 08             	mov    0x8(%ebp),%eax
  801d9b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801da0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801da3:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801da8:	b8 06 00 00 00       	mov    $0x6,%eax
  801dad:	e8 6a fe ff ff       	call   801c1c <nsipc>
}
  801db2:	c9                   	leave  
  801db3:	c3                   	ret    

00801db4 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801db4:	55                   	push   %ebp
  801db5:	89 e5                	mov    %esp,%ebp
  801db7:	56                   	push   %esi
  801db8:	53                   	push   %ebx
  801db9:	83 ec 10             	sub    $0x10,%esp
  801dbc:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801dbf:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801dc7:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801dcd:	8b 45 14             	mov    0x14(%ebp),%eax
  801dd0:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801dd5:	b8 07 00 00 00       	mov    $0x7,%eax
  801dda:	e8 3d fe ff ff       	call   801c1c <nsipc>
  801ddf:	89 c3                	mov    %eax,%ebx
  801de1:	85 c0                	test   %eax,%eax
  801de3:	78 46                	js     801e2b <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801de5:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801dea:	7f 04                	jg     801df0 <nsipc_recv+0x3c>
  801dec:	39 c6                	cmp    %eax,%esi
  801dee:	7d 24                	jge    801e14 <nsipc_recv+0x60>
  801df0:	c7 44 24 0c 43 2c 80 	movl   $0x802c43,0xc(%esp)
  801df7:	00 
  801df8:	c7 44 24 08 0b 2c 80 	movl   $0x802c0b,0x8(%esp)
  801dff:	00 
  801e00:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  801e07:	00 
  801e08:	c7 04 24 58 2c 80 00 	movl   $0x802c58,(%esp)
  801e0f:	e8 d8 05 00 00       	call   8023ec <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801e14:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e18:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801e1f:	00 
  801e20:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e23:	89 04 24             	mov    %eax,(%esp)
  801e26:	e8 29 eb ff ff       	call   800954 <memmove>
	}

	return r;
}
  801e2b:	89 d8                	mov    %ebx,%eax
  801e2d:	83 c4 10             	add    $0x10,%esp
  801e30:	5b                   	pop    %ebx
  801e31:	5e                   	pop    %esi
  801e32:	5d                   	pop    %ebp
  801e33:	c3                   	ret    

00801e34 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801e34:	55                   	push   %ebp
  801e35:	89 e5                	mov    %esp,%ebp
  801e37:	53                   	push   %ebx
  801e38:	83 ec 14             	sub    $0x14,%esp
  801e3b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801e3e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e41:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801e46:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801e4c:	7e 24                	jle    801e72 <nsipc_send+0x3e>
  801e4e:	c7 44 24 0c 64 2c 80 	movl   $0x802c64,0xc(%esp)
  801e55:	00 
  801e56:	c7 44 24 08 0b 2c 80 	movl   $0x802c0b,0x8(%esp)
  801e5d:	00 
  801e5e:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  801e65:	00 
  801e66:	c7 04 24 58 2c 80 00 	movl   $0x802c58,(%esp)
  801e6d:	e8 7a 05 00 00       	call   8023ec <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801e72:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e76:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e79:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e7d:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  801e84:	e8 cb ea ff ff       	call   800954 <memmove>
	nsipcbuf.send.req_size = size;
  801e89:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801e8f:	8b 45 14             	mov    0x14(%ebp),%eax
  801e92:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801e97:	b8 08 00 00 00       	mov    $0x8,%eax
  801e9c:	e8 7b fd ff ff       	call   801c1c <nsipc>
}
  801ea1:	83 c4 14             	add    $0x14,%esp
  801ea4:	5b                   	pop    %ebx
  801ea5:	5d                   	pop    %ebp
  801ea6:	c3                   	ret    

00801ea7 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801ea7:	55                   	push   %ebp
  801ea8:	89 e5                	mov    %esp,%ebp
  801eaa:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801ead:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb0:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801eb5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eb8:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801ebd:	8b 45 10             	mov    0x10(%ebp),%eax
  801ec0:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801ec5:	b8 09 00 00 00       	mov    $0x9,%eax
  801eca:	e8 4d fd ff ff       	call   801c1c <nsipc>
}
  801ecf:	c9                   	leave  
  801ed0:	c3                   	ret    
  801ed1:	00 00                	add    %al,(%eax)
	...

00801ed4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ed4:	55                   	push   %ebp
  801ed5:	89 e5                	mov    %esp,%ebp
  801ed7:	56                   	push   %esi
  801ed8:	53                   	push   %ebx
  801ed9:	83 ec 10             	sub    $0x10,%esp
  801edc:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801edf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee2:	89 04 24             	mov    %eax,(%esp)
  801ee5:	e8 36 f1 ff ff       	call   801020 <fd2data>
  801eea:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801eec:	c7 44 24 04 70 2c 80 	movl   $0x802c70,0x4(%esp)
  801ef3:	00 
  801ef4:	89 34 24             	mov    %esi,(%esp)
  801ef7:	e8 df e8 ff ff       	call   8007db <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801efc:	8b 43 04             	mov    0x4(%ebx),%eax
  801eff:	2b 03                	sub    (%ebx),%eax
  801f01:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801f07:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801f0e:	00 00 00 
	stat->st_dev = &devpipe;
  801f11:	c7 86 88 00 00 00 3c 	movl   $0x80303c,0x88(%esi)
  801f18:	30 80 00 
	return 0;
}
  801f1b:	b8 00 00 00 00       	mov    $0x0,%eax
  801f20:	83 c4 10             	add    $0x10,%esp
  801f23:	5b                   	pop    %ebx
  801f24:	5e                   	pop    %esi
  801f25:	5d                   	pop    %ebp
  801f26:	c3                   	ret    

00801f27 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f27:	55                   	push   %ebp
  801f28:	89 e5                	mov    %esp,%ebp
  801f2a:	53                   	push   %ebx
  801f2b:	83 ec 14             	sub    $0x14,%esp
  801f2e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f31:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f35:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f3c:	e8 33 ed ff ff       	call   800c74 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f41:	89 1c 24             	mov    %ebx,(%esp)
  801f44:	e8 d7 f0 ff ff       	call   801020 <fd2data>
  801f49:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f4d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f54:	e8 1b ed ff ff       	call   800c74 <sys_page_unmap>
}
  801f59:	83 c4 14             	add    $0x14,%esp
  801f5c:	5b                   	pop    %ebx
  801f5d:	5d                   	pop    %ebp
  801f5e:	c3                   	ret    

00801f5f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801f5f:	55                   	push   %ebp
  801f60:	89 e5                	mov    %esp,%ebp
  801f62:	57                   	push   %edi
  801f63:	56                   	push   %esi
  801f64:	53                   	push   %ebx
  801f65:	83 ec 2c             	sub    $0x2c,%esp
  801f68:	89 c7                	mov    %eax,%edi
  801f6a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801f6d:	a1 08 40 80 00       	mov    0x804008,%eax
  801f72:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801f75:	89 3c 24             	mov    %edi,(%esp)
  801f78:	e8 d7 05 00 00       	call   802554 <pageref>
  801f7d:	89 c6                	mov    %eax,%esi
  801f7f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f82:	89 04 24             	mov    %eax,(%esp)
  801f85:	e8 ca 05 00 00       	call   802554 <pageref>
  801f8a:	39 c6                	cmp    %eax,%esi
  801f8c:	0f 94 c0             	sete   %al
  801f8f:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801f92:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f98:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f9b:	39 cb                	cmp    %ecx,%ebx
  801f9d:	75 08                	jne    801fa7 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801f9f:	83 c4 2c             	add    $0x2c,%esp
  801fa2:	5b                   	pop    %ebx
  801fa3:	5e                   	pop    %esi
  801fa4:	5f                   	pop    %edi
  801fa5:	5d                   	pop    %ebp
  801fa6:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801fa7:	83 f8 01             	cmp    $0x1,%eax
  801faa:	75 c1                	jne    801f6d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801fac:	8b 42 58             	mov    0x58(%edx),%eax
  801faf:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801fb6:	00 
  801fb7:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fbb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801fbf:	c7 04 24 77 2c 80 00 	movl   $0x802c77,(%esp)
  801fc6:	e8 65 e2 ff ff       	call   800230 <cprintf>
  801fcb:	eb a0                	jmp    801f6d <_pipeisclosed+0xe>

00801fcd <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801fcd:	55                   	push   %ebp
  801fce:	89 e5                	mov    %esp,%ebp
  801fd0:	57                   	push   %edi
  801fd1:	56                   	push   %esi
  801fd2:	53                   	push   %ebx
  801fd3:	83 ec 1c             	sub    $0x1c,%esp
  801fd6:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801fd9:	89 34 24             	mov    %esi,(%esp)
  801fdc:	e8 3f f0 ff ff       	call   801020 <fd2data>
  801fe1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fe3:	bf 00 00 00 00       	mov    $0x0,%edi
  801fe8:	eb 3c                	jmp    802026 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801fea:	89 da                	mov    %ebx,%edx
  801fec:	89 f0                	mov    %esi,%eax
  801fee:	e8 6c ff ff ff       	call   801f5f <_pipeisclosed>
  801ff3:	85 c0                	test   %eax,%eax
  801ff5:	75 38                	jne    80202f <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ff7:	e8 b2 eb ff ff       	call   800bae <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ffc:	8b 43 04             	mov    0x4(%ebx),%eax
  801fff:	8b 13                	mov    (%ebx),%edx
  802001:	83 c2 20             	add    $0x20,%edx
  802004:	39 d0                	cmp    %edx,%eax
  802006:	73 e2                	jae    801fea <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802008:	8b 55 0c             	mov    0xc(%ebp),%edx
  80200b:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  80200e:	89 c2                	mov    %eax,%edx
  802010:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  802016:	79 05                	jns    80201d <devpipe_write+0x50>
  802018:	4a                   	dec    %edx
  802019:	83 ca e0             	or     $0xffffffe0,%edx
  80201c:	42                   	inc    %edx
  80201d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802021:	40                   	inc    %eax
  802022:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802025:	47                   	inc    %edi
  802026:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802029:	75 d1                	jne    801ffc <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80202b:	89 f8                	mov    %edi,%eax
  80202d:	eb 05                	jmp    802034 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80202f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802034:	83 c4 1c             	add    $0x1c,%esp
  802037:	5b                   	pop    %ebx
  802038:	5e                   	pop    %esi
  802039:	5f                   	pop    %edi
  80203a:	5d                   	pop    %ebp
  80203b:	c3                   	ret    

0080203c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80203c:	55                   	push   %ebp
  80203d:	89 e5                	mov    %esp,%ebp
  80203f:	57                   	push   %edi
  802040:	56                   	push   %esi
  802041:	53                   	push   %ebx
  802042:	83 ec 1c             	sub    $0x1c,%esp
  802045:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802048:	89 3c 24             	mov    %edi,(%esp)
  80204b:	e8 d0 ef ff ff       	call   801020 <fd2data>
  802050:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802052:	be 00 00 00 00       	mov    $0x0,%esi
  802057:	eb 3a                	jmp    802093 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802059:	85 f6                	test   %esi,%esi
  80205b:	74 04                	je     802061 <devpipe_read+0x25>
				return i;
  80205d:	89 f0                	mov    %esi,%eax
  80205f:	eb 40                	jmp    8020a1 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802061:	89 da                	mov    %ebx,%edx
  802063:	89 f8                	mov    %edi,%eax
  802065:	e8 f5 fe ff ff       	call   801f5f <_pipeisclosed>
  80206a:	85 c0                	test   %eax,%eax
  80206c:	75 2e                	jne    80209c <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80206e:	e8 3b eb ff ff       	call   800bae <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802073:	8b 03                	mov    (%ebx),%eax
  802075:	3b 43 04             	cmp    0x4(%ebx),%eax
  802078:	74 df                	je     802059 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80207a:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80207f:	79 05                	jns    802086 <devpipe_read+0x4a>
  802081:	48                   	dec    %eax
  802082:	83 c8 e0             	or     $0xffffffe0,%eax
  802085:	40                   	inc    %eax
  802086:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80208a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80208d:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  802090:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802092:	46                   	inc    %esi
  802093:	3b 75 10             	cmp    0x10(%ebp),%esi
  802096:	75 db                	jne    802073 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802098:	89 f0                	mov    %esi,%eax
  80209a:	eb 05                	jmp    8020a1 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80209c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8020a1:	83 c4 1c             	add    $0x1c,%esp
  8020a4:	5b                   	pop    %ebx
  8020a5:	5e                   	pop    %esi
  8020a6:	5f                   	pop    %edi
  8020a7:	5d                   	pop    %ebp
  8020a8:	c3                   	ret    

008020a9 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8020a9:	55                   	push   %ebp
  8020aa:	89 e5                	mov    %esp,%ebp
  8020ac:	57                   	push   %edi
  8020ad:	56                   	push   %esi
  8020ae:	53                   	push   %ebx
  8020af:	83 ec 3c             	sub    $0x3c,%esp
  8020b2:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8020b5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8020b8:	89 04 24             	mov    %eax,(%esp)
  8020bb:	e8 7b ef ff ff       	call   80103b <fd_alloc>
  8020c0:	89 c3                	mov    %eax,%ebx
  8020c2:	85 c0                	test   %eax,%eax
  8020c4:	0f 88 45 01 00 00    	js     80220f <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020ca:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8020d1:	00 
  8020d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020d9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020e0:	e8 e8 ea ff ff       	call   800bcd <sys_page_alloc>
  8020e5:	89 c3                	mov    %eax,%ebx
  8020e7:	85 c0                	test   %eax,%eax
  8020e9:	0f 88 20 01 00 00    	js     80220f <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8020ef:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8020f2:	89 04 24             	mov    %eax,(%esp)
  8020f5:	e8 41 ef ff ff       	call   80103b <fd_alloc>
  8020fa:	89 c3                	mov    %eax,%ebx
  8020fc:	85 c0                	test   %eax,%eax
  8020fe:	0f 88 f8 00 00 00    	js     8021fc <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802104:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80210b:	00 
  80210c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80210f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802113:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80211a:	e8 ae ea ff ff       	call   800bcd <sys_page_alloc>
  80211f:	89 c3                	mov    %eax,%ebx
  802121:	85 c0                	test   %eax,%eax
  802123:	0f 88 d3 00 00 00    	js     8021fc <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802129:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80212c:	89 04 24             	mov    %eax,(%esp)
  80212f:	e8 ec ee ff ff       	call   801020 <fd2data>
  802134:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802136:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80213d:	00 
  80213e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802142:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802149:	e8 7f ea ff ff       	call   800bcd <sys_page_alloc>
  80214e:	89 c3                	mov    %eax,%ebx
  802150:	85 c0                	test   %eax,%eax
  802152:	0f 88 91 00 00 00    	js     8021e9 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802158:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80215b:	89 04 24             	mov    %eax,(%esp)
  80215e:	e8 bd ee ff ff       	call   801020 <fd2data>
  802163:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  80216a:	00 
  80216b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80216f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802176:	00 
  802177:	89 74 24 04          	mov    %esi,0x4(%esp)
  80217b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802182:	e8 9a ea ff ff       	call   800c21 <sys_page_map>
  802187:	89 c3                	mov    %eax,%ebx
  802189:	85 c0                	test   %eax,%eax
  80218b:	78 4c                	js     8021d9 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80218d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802193:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802196:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802198:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80219b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8021a2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8021a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8021ab:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8021ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8021b0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8021b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8021ba:	89 04 24             	mov    %eax,(%esp)
  8021bd:	e8 4e ee ff ff       	call   801010 <fd2num>
  8021c2:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8021c4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8021c7:	89 04 24             	mov    %eax,(%esp)
  8021ca:	e8 41 ee ff ff       	call   801010 <fd2num>
  8021cf:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8021d2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8021d7:	eb 36                	jmp    80220f <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  8021d9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021dd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021e4:	e8 8b ea ff ff       	call   800c74 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8021e9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8021ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021f7:	e8 78 ea ff ff       	call   800c74 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8021fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8021ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  802203:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80220a:	e8 65 ea ff ff       	call   800c74 <sys_page_unmap>
    err:
	return r;
}
  80220f:	89 d8                	mov    %ebx,%eax
  802211:	83 c4 3c             	add    $0x3c,%esp
  802214:	5b                   	pop    %ebx
  802215:	5e                   	pop    %esi
  802216:	5f                   	pop    %edi
  802217:	5d                   	pop    %ebp
  802218:	c3                   	ret    

00802219 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802219:	55                   	push   %ebp
  80221a:	89 e5                	mov    %esp,%ebp
  80221c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80221f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802222:	89 44 24 04          	mov    %eax,0x4(%esp)
  802226:	8b 45 08             	mov    0x8(%ebp),%eax
  802229:	89 04 24             	mov    %eax,(%esp)
  80222c:	e8 5d ee ff ff       	call   80108e <fd_lookup>
  802231:	85 c0                	test   %eax,%eax
  802233:	78 15                	js     80224a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802235:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802238:	89 04 24             	mov    %eax,(%esp)
  80223b:	e8 e0 ed ff ff       	call   801020 <fd2data>
	return _pipeisclosed(fd, p);
  802240:	89 c2                	mov    %eax,%edx
  802242:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802245:	e8 15 fd ff ff       	call   801f5f <_pipeisclosed>
}
  80224a:	c9                   	leave  
  80224b:	c3                   	ret    

0080224c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80224c:	55                   	push   %ebp
  80224d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80224f:	b8 00 00 00 00       	mov    $0x0,%eax
  802254:	5d                   	pop    %ebp
  802255:	c3                   	ret    

00802256 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802256:	55                   	push   %ebp
  802257:	89 e5                	mov    %esp,%ebp
  802259:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  80225c:	c7 44 24 04 8f 2c 80 	movl   $0x802c8f,0x4(%esp)
  802263:	00 
  802264:	8b 45 0c             	mov    0xc(%ebp),%eax
  802267:	89 04 24             	mov    %eax,(%esp)
  80226a:	e8 6c e5 ff ff       	call   8007db <strcpy>
	return 0;
}
  80226f:	b8 00 00 00 00       	mov    $0x0,%eax
  802274:	c9                   	leave  
  802275:	c3                   	ret    

00802276 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802276:	55                   	push   %ebp
  802277:	89 e5                	mov    %esp,%ebp
  802279:	57                   	push   %edi
  80227a:	56                   	push   %esi
  80227b:	53                   	push   %ebx
  80227c:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802282:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802287:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80228d:	eb 30                	jmp    8022bf <devcons_write+0x49>
		m = n - tot;
  80228f:	8b 75 10             	mov    0x10(%ebp),%esi
  802292:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802294:	83 fe 7f             	cmp    $0x7f,%esi
  802297:	76 05                	jbe    80229e <devcons_write+0x28>
			m = sizeof(buf) - 1;
  802299:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80229e:	89 74 24 08          	mov    %esi,0x8(%esp)
  8022a2:	03 45 0c             	add    0xc(%ebp),%eax
  8022a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022a9:	89 3c 24             	mov    %edi,(%esp)
  8022ac:	e8 a3 e6 ff ff       	call   800954 <memmove>
		sys_cputs(buf, m);
  8022b1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022b5:	89 3c 24             	mov    %edi,(%esp)
  8022b8:	e8 43 e8 ff ff       	call   800b00 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022bd:	01 f3                	add    %esi,%ebx
  8022bf:	89 d8                	mov    %ebx,%eax
  8022c1:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8022c4:	72 c9                	jb     80228f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8022c6:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8022cc:	5b                   	pop    %ebx
  8022cd:	5e                   	pop    %esi
  8022ce:	5f                   	pop    %edi
  8022cf:	5d                   	pop    %ebp
  8022d0:	c3                   	ret    

008022d1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8022d1:	55                   	push   %ebp
  8022d2:	89 e5                	mov    %esp,%ebp
  8022d4:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8022d7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8022db:	75 07                	jne    8022e4 <devcons_read+0x13>
  8022dd:	eb 25                	jmp    802304 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8022df:	e8 ca e8 ff ff       	call   800bae <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8022e4:	e8 35 e8 ff ff       	call   800b1e <sys_cgetc>
  8022e9:	85 c0                	test   %eax,%eax
  8022eb:	74 f2                	je     8022df <devcons_read+0xe>
  8022ed:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8022ef:	85 c0                	test   %eax,%eax
  8022f1:	78 1d                	js     802310 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8022f3:	83 f8 04             	cmp    $0x4,%eax
  8022f6:	74 13                	je     80230b <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8022f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022fb:	88 10                	mov    %dl,(%eax)
	return 1;
  8022fd:	b8 01 00 00 00       	mov    $0x1,%eax
  802302:	eb 0c                	jmp    802310 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802304:	b8 00 00 00 00       	mov    $0x0,%eax
  802309:	eb 05                	jmp    802310 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80230b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802310:	c9                   	leave  
  802311:	c3                   	ret    

00802312 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802312:	55                   	push   %ebp
  802313:	89 e5                	mov    %esp,%ebp
  802315:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802318:	8b 45 08             	mov    0x8(%ebp),%eax
  80231b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80231e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802325:	00 
  802326:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802329:	89 04 24             	mov    %eax,(%esp)
  80232c:	e8 cf e7 ff ff       	call   800b00 <sys_cputs>
}
  802331:	c9                   	leave  
  802332:	c3                   	ret    

00802333 <getchar>:

int
getchar(void)
{
  802333:	55                   	push   %ebp
  802334:	89 e5                	mov    %esp,%ebp
  802336:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802339:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802340:	00 
  802341:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802344:	89 44 24 04          	mov    %eax,0x4(%esp)
  802348:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80234f:	e8 d6 ef ff ff       	call   80132a <read>
	if (r < 0)
  802354:	85 c0                	test   %eax,%eax
  802356:	78 0f                	js     802367 <getchar+0x34>
		return r;
	if (r < 1)
  802358:	85 c0                	test   %eax,%eax
  80235a:	7e 06                	jle    802362 <getchar+0x2f>
		return -E_EOF;
	return c;
  80235c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802360:	eb 05                	jmp    802367 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802362:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802367:	c9                   	leave  
  802368:	c3                   	ret    

00802369 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802369:	55                   	push   %ebp
  80236a:	89 e5                	mov    %esp,%ebp
  80236c:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80236f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802372:	89 44 24 04          	mov    %eax,0x4(%esp)
  802376:	8b 45 08             	mov    0x8(%ebp),%eax
  802379:	89 04 24             	mov    %eax,(%esp)
  80237c:	e8 0d ed ff ff       	call   80108e <fd_lookup>
  802381:	85 c0                	test   %eax,%eax
  802383:	78 11                	js     802396 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802385:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802388:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80238e:	39 10                	cmp    %edx,(%eax)
  802390:	0f 94 c0             	sete   %al
  802393:	0f b6 c0             	movzbl %al,%eax
}
  802396:	c9                   	leave  
  802397:	c3                   	ret    

00802398 <opencons>:

int
opencons(void)
{
  802398:	55                   	push   %ebp
  802399:	89 e5                	mov    %esp,%ebp
  80239b:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80239e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023a1:	89 04 24             	mov    %eax,(%esp)
  8023a4:	e8 92 ec ff ff       	call   80103b <fd_alloc>
  8023a9:	85 c0                	test   %eax,%eax
  8023ab:	78 3c                	js     8023e9 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023ad:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8023b4:	00 
  8023b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023c3:	e8 05 e8 ff ff       	call   800bcd <sys_page_alloc>
  8023c8:	85 c0                	test   %eax,%eax
  8023ca:	78 1d                	js     8023e9 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8023cc:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8023d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023d5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8023d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023da:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8023e1:	89 04 24             	mov    %eax,(%esp)
  8023e4:	e8 27 ec ff ff       	call   801010 <fd2num>
}
  8023e9:	c9                   	leave  
  8023ea:	c3                   	ret    
	...

008023ec <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8023ec:	55                   	push   %ebp
  8023ed:	89 e5                	mov    %esp,%ebp
  8023ef:	56                   	push   %esi
  8023f0:	53                   	push   %ebx
  8023f1:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8023f4:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8023f7:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8023fd:	e8 8d e7 ff ff       	call   800b8f <sys_getenvid>
  802402:	8b 55 0c             	mov    0xc(%ebp),%edx
  802405:	89 54 24 10          	mov    %edx,0x10(%esp)
  802409:	8b 55 08             	mov    0x8(%ebp),%edx
  80240c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802410:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802414:	89 44 24 04          	mov    %eax,0x4(%esp)
  802418:	c7 04 24 9c 2c 80 00 	movl   $0x802c9c,(%esp)
  80241f:	e8 0c de ff ff       	call   800230 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802424:	89 74 24 04          	mov    %esi,0x4(%esp)
  802428:	8b 45 10             	mov    0x10(%ebp),%eax
  80242b:	89 04 24             	mov    %eax,(%esp)
  80242e:	e8 9c dd ff ff       	call   8001cf <vcprintf>
	cprintf("\n");
  802433:	c7 04 24 10 28 80 00 	movl   $0x802810,(%esp)
  80243a:	e8 f1 dd ff ff       	call   800230 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80243f:	cc                   	int3   
  802440:	eb fd                	jmp    80243f <_panic+0x53>
	...

00802444 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802444:	55                   	push   %ebp
  802445:	89 e5                	mov    %esp,%ebp
  802447:	56                   	push   %esi
  802448:	53                   	push   %ebx
  802449:	83 ec 10             	sub    $0x10,%esp
  80244c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80244f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802452:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int r;
		
	r = sys_ipc_recv(pg?pg:(void*)UTOP);
  802455:	85 c0                	test   %eax,%eax
  802457:	75 05                	jne    80245e <ipc_recv+0x1a>
  802459:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80245e:	89 04 24             	mov    %eax,(%esp)
  802461:	e8 7d e9 ff ff       	call   800de3 <sys_ipc_recv>
	if (from_env_store != NULL)
  802466:	85 db                	test   %ebx,%ebx
  802468:	74 0b                	je     802475 <ipc_recv+0x31>
		*from_env_store = thisenv->env_ipc_from; 
  80246a:	8b 15 08 40 80 00    	mov    0x804008,%edx
  802470:	8b 52 74             	mov    0x74(%edx),%edx
  802473:	89 13                	mov    %edx,(%ebx)
	if (perm_store != NULL)
  802475:	85 f6                	test   %esi,%esi
  802477:	74 0b                	je     802484 <ipc_recv+0x40>
		*perm_store = thisenv->env_ipc_perm;
  802479:	8b 15 08 40 80 00    	mov    0x804008,%edx
  80247f:	8b 52 78             	mov    0x78(%edx),%edx
  802482:	89 16                	mov    %edx,(%esi)
	
	if (r < 0){
  802484:	85 c0                	test   %eax,%eax
  802486:	79 16                	jns    80249e <ipc_recv+0x5a>
		if(from_env_store != NULL)
  802488:	85 db                	test   %ebx,%ebx
  80248a:	74 06                	je     802492 <ipc_recv+0x4e>
			*from_env_store = 0;
  80248c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store != NULL)	
  802492:	85 f6                	test   %esi,%esi
  802494:	74 10                	je     8024a6 <ipc_recv+0x62>
			*perm_store = 0;
  802496:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80249c:	eb 08                	jmp    8024a6 <ipc_recv+0x62>
		return r;
	}
	
	return thisenv->env_ipc_value;
  80249e:	a1 08 40 80 00       	mov    0x804008,%eax
  8024a3:	8b 40 70             	mov    0x70(%eax),%eax
}
  8024a6:	83 c4 10             	add    $0x10,%esp
  8024a9:	5b                   	pop    %ebx
  8024aa:	5e                   	pop    %esi
  8024ab:	5d                   	pop    %ebp
  8024ac:	c3                   	ret    

008024ad <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8024ad:	55                   	push   %ebp
  8024ae:	89 e5                	mov    %esp,%ebp
  8024b0:	57                   	push   %edi
  8024b1:	56                   	push   %esi
  8024b2:	53                   	push   %ebx
  8024b3:	83 ec 1c             	sub    $0x1c,%esp
  8024b6:	8b 75 08             	mov    0x8(%ebp),%esi
  8024b9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8024bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  8024bf:	eb 2a                	jmp    8024eb <ipc_send+0x3e>
		if (r != -E_IPC_NOT_RECV)
  8024c1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8024c4:	74 20                	je     8024e6 <ipc_send+0x39>
			panic("ipc_send: sys_ipc_try_send failed %e", r);
  8024c6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024ca:	c7 44 24 08 c0 2c 80 	movl   $0x802cc0,0x8(%esp)
  8024d1:	00 
  8024d2:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  8024d9:	00 
  8024da:	c7 04 24 e8 2c 80 00 	movl   $0x802ce8,(%esp)
  8024e1:	e8 06 ff ff ff       	call   8023ec <_panic>
		sys_yield();
  8024e6:	e8 c3 e6 ff ff       	call   800bae <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  8024eb:	85 db                	test   %ebx,%ebx
  8024ed:	75 07                	jne    8024f6 <ipc_send+0x49>
  8024ef:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8024f4:	eb 02                	jmp    8024f8 <ipc_send+0x4b>
  8024f6:	89 d8                	mov    %ebx,%eax
  8024f8:	8b 55 14             	mov    0x14(%ebp),%edx
  8024fb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8024ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  802503:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802507:	89 34 24             	mov    %esi,(%esp)
  80250a:	e8 b1 e8 ff ff       	call   800dc0 <sys_ipc_try_send>
  80250f:	85 c0                	test   %eax,%eax
  802511:	78 ae                	js     8024c1 <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: sys_ipc_try_send failed %e", r);
		sys_yield();
	}
}
  802513:	83 c4 1c             	add    $0x1c,%esp
  802516:	5b                   	pop    %ebx
  802517:	5e                   	pop    %esi
  802518:	5f                   	pop    %edi
  802519:	5d                   	pop    %ebp
  80251a:	c3                   	ret    

0080251b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80251b:	55                   	push   %ebp
  80251c:	89 e5                	mov    %esp,%ebp
  80251e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802521:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802526:	89 c2                	mov    %eax,%edx
  802528:	c1 e2 07             	shl    $0x7,%edx
  80252b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802531:	8b 52 50             	mov    0x50(%edx),%edx
  802534:	39 ca                	cmp    %ecx,%edx
  802536:	75 0d                	jne    802545 <ipc_find_env+0x2a>
			return envs[i].env_id;
  802538:	c1 e0 07             	shl    $0x7,%eax
  80253b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802540:	8b 40 40             	mov    0x40(%eax),%eax
  802543:	eb 0c                	jmp    802551 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802545:	40                   	inc    %eax
  802546:	3d 00 04 00 00       	cmp    $0x400,%eax
  80254b:	75 d9                	jne    802526 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80254d:	66 b8 00 00          	mov    $0x0,%ax
}
  802551:	5d                   	pop    %ebp
  802552:	c3                   	ret    
	...

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
