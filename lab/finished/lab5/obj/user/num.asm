
obj/user/num.debug:     file format elf32-i386


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
  80002c:	e8 8f 01 00 00       	call   8001c0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <num>:
int bol = 1;
int line = 0;

void
num(int f, const char *s)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 3c             	sub    $0x3c,%esp
  80003d:	8b 75 08             	mov    0x8(%ebp),%esi
  800040:	8b 7d 0c             	mov    0xc(%ebp),%edi
	long n;
	int r;
	char c;

	while ((n = read(f, &c, 1)) > 0) {
  800043:	8d 5d e7             	lea    -0x19(%ebp),%ebx
  800046:	eb 7f                	jmp    8000c7 <num+0x93>
		if (bol) {
  800048:	83 3d 00 30 80 00 00 	cmpl   $0x0,0x803000
  80004f:	74 25                	je     800076 <num+0x42>
			printf("%5d ", ++line);
  800051:	a1 00 40 80 00       	mov    0x804000,%eax
  800056:	40                   	inc    %eax
  800057:	a3 00 40 80 00       	mov    %eax,0x804000
  80005c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800060:	c7 04 24 c0 21 80 00 	movl   $0x8021c0,(%esp)
  800067:	e8 61 18 00 00       	call   8018cd <printf>
			bol = 0;
  80006c:	c7 05 00 30 80 00 00 	movl   $0x0,0x803000
  800073:	00 00 00 
		}
		if ((r = write(1, &c, 1)) != 1)
  800076:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  80007d:	00 
  80007e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800082:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800089:	e8 8f 12 00 00       	call   80131d <write>
  80008e:	83 f8 01             	cmp    $0x1,%eax
  800091:	74 24                	je     8000b7 <num+0x83>
			panic("write error copying %s: %e", s, r);
  800093:	89 44 24 10          	mov    %eax,0x10(%esp)
  800097:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80009b:	c7 44 24 08 c5 21 80 	movl   $0x8021c5,0x8(%esp)
  8000a2:	00 
  8000a3:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
  8000aa:	00 
  8000ab:	c7 04 24 e0 21 80 00 	movl   $0x8021e0,(%esp)
  8000b2:	e8 71 01 00 00       	call   800228 <_panic>
		if (c == '\n')
  8000b7:	80 7d e7 0a          	cmpb   $0xa,-0x19(%ebp)
  8000bb:	75 0a                	jne    8000c7 <num+0x93>
			bol = 1;
  8000bd:	c7 05 00 30 80 00 01 	movl   $0x1,0x803000
  8000c4:	00 00 00 
{
	long n;
	int r;
	char c;

	while ((n = read(f, &c, 1)) > 0) {
  8000c7:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8000ce:	00 
  8000cf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000d3:	89 34 24             	mov    %esi,(%esp)
  8000d6:	e8 67 11 00 00       	call   801242 <read>
  8000db:	85 c0                	test   %eax,%eax
  8000dd:	0f 8f 65 ff ff ff    	jg     800048 <num+0x14>
		if ((r = write(1, &c, 1)) != 1)
			panic("write error copying %s: %e", s, r);
		if (c == '\n')
			bol = 1;
	}
	if (n < 0)
  8000e3:	85 c0                	test   %eax,%eax
  8000e5:	79 24                	jns    80010b <num+0xd7>
		panic("error reading %s: %e", s, n);
  8000e7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000eb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8000ef:	c7 44 24 08 eb 21 80 	movl   $0x8021eb,0x8(%esp)
  8000f6:	00 
  8000f7:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%esp)
  8000fe:	00 
  8000ff:	c7 04 24 e0 21 80 00 	movl   $0x8021e0,(%esp)
  800106:	e8 1d 01 00 00       	call   800228 <_panic>
}
  80010b:	83 c4 3c             	add    $0x3c,%esp
  80010e:	5b                   	pop    %ebx
  80010f:	5e                   	pop    %esi
  800110:	5f                   	pop    %edi
  800111:	5d                   	pop    %ebp
  800112:	c3                   	ret    

00800113 <umain>:

void
umain(int argc, char **argv)
{
  800113:	55                   	push   %ebp
  800114:	89 e5                	mov    %esp,%ebp
  800116:	57                   	push   %edi
  800117:	56                   	push   %esi
  800118:	53                   	push   %ebx
  800119:	83 ec 3c             	sub    $0x3c,%esp
	int f, i;

	binaryname = "num";
  80011c:	c7 05 04 30 80 00 00 	movl   $0x802200,0x803004
  800123:	22 80 00 
	if (argc == 1)
  800126:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  80012a:	74 0d                	je     800139 <umain+0x26>
	if (n < 0)
		panic("error reading %s: %e", s, n);
}

void
umain(int argc, char **argv)
  80012c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80012f:	83 c3 04             	add    $0x4,%ebx
  800132:	bf 01 00 00 00       	mov    $0x1,%edi
  800137:	eb 74                	jmp    8001ad <umain+0x9a>
{
	int f, i;

	binaryname = "num";
	if (argc == 1)
		num(0, "<stdin>");
  800139:	c7 44 24 04 04 22 80 	movl   $0x802204,0x4(%esp)
  800140:	00 
  800141:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800148:	e8 e7 fe ff ff       	call   800034 <num>
  80014d:	eb 63                	jmp    8001b2 <umain+0x9f>
	else
		for (i = 1; i < argc; i++) {
			f = open(argv[i], O_RDONLY);
  80014f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800152:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800159:	00 
  80015a:	8b 03                	mov    (%ebx),%eax
  80015c:	89 04 24             	mov    %eax,(%esp)
  80015f:	e8 b4 15 00 00       	call   801718 <open>
  800164:	89 c6                	mov    %eax,%esi
			if (f < 0)
  800166:	85 c0                	test   %eax,%eax
  800168:	79 29                	jns    800193 <umain+0x80>
				panic("can't open %s: %e", argv[i], f);
  80016a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80016e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800171:	8b 02                	mov    (%edx),%eax
  800173:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800177:	c7 44 24 08 0c 22 80 	movl   $0x80220c,0x8(%esp)
  80017e:	00 
  80017f:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  800186:	00 
  800187:	c7 04 24 e0 21 80 00 	movl   $0x8021e0,(%esp)
  80018e:	e8 95 00 00 00       	call   800228 <_panic>
			else {
				num(f, argv[i]);
  800193:	8b 03                	mov    (%ebx),%eax
  800195:	89 44 24 04          	mov    %eax,0x4(%esp)
  800199:	89 34 24             	mov    %esi,(%esp)
  80019c:	e8 93 fe ff ff       	call   800034 <num>
				close(f);
  8001a1:	89 34 24             	mov    %esi,(%esp)
  8001a4:	e8 35 0f 00 00       	call   8010de <close>

	binaryname = "num";
	if (argc == 1)
		num(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  8001a9:	47                   	inc    %edi
  8001aa:	83 c3 04             	add    $0x4,%ebx
  8001ad:	3b 7d 08             	cmp    0x8(%ebp),%edi
  8001b0:	7c 9d                	jl     80014f <umain+0x3c>
			else {
				num(f, argv[i]);
				close(f);
			}
		}
	exit();
  8001b2:	e8 5d 00 00 00       	call   800214 <exit>
}
  8001b7:	83 c4 3c             	add    $0x3c,%esp
  8001ba:	5b                   	pop    %ebx
  8001bb:	5e                   	pop    %esi
  8001bc:	5f                   	pop    %edi
  8001bd:	5d                   	pop    %ebp
  8001be:	c3                   	ret    
	...

008001c0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	56                   	push   %esi
  8001c4:	53                   	push   %ebx
  8001c5:	83 ec 10             	sub    $0x10,%esp
  8001c8:	8b 75 08             	mov    0x8(%ebp),%esi
  8001cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001ce:	e8 ac 0a 00 00       	call   800c7f <sys_getenvid>
  8001d3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001d8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8001df:	c1 e0 07             	shl    $0x7,%eax
  8001e2:	29 d0                	sub    %edx,%eax
  8001e4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001e9:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001ee:	85 f6                	test   %esi,%esi
  8001f0:	7e 07                	jle    8001f9 <libmain+0x39>
		binaryname = argv[0];
  8001f2:	8b 03                	mov    (%ebx),%eax
  8001f4:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8001f9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001fd:	89 34 24             	mov    %esi,(%esp)
  800200:	e8 0e ff ff ff       	call   800113 <umain>

	// exit gracefully
	exit();
  800205:	e8 0a 00 00 00       	call   800214 <exit>
}
  80020a:	83 c4 10             	add    $0x10,%esp
  80020d:	5b                   	pop    %ebx
  80020e:	5e                   	pop    %esi
  80020f:	5d                   	pop    %ebp
  800210:	c3                   	ret    
  800211:	00 00                	add    %al,(%eax)
	...

00800214 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  80021a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800221:	e8 07 0a 00 00       	call   800c2d <sys_env_destroy>
}
  800226:	c9                   	leave  
  800227:	c3                   	ret    

00800228 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800228:	55                   	push   %ebp
  800229:	89 e5                	mov    %esp,%ebp
  80022b:	56                   	push   %esi
  80022c:	53                   	push   %ebx
  80022d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800230:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800233:	8b 1d 04 30 80 00    	mov    0x803004,%ebx
  800239:	e8 41 0a 00 00       	call   800c7f <sys_getenvid>
  80023e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800241:	89 54 24 10          	mov    %edx,0x10(%esp)
  800245:	8b 55 08             	mov    0x8(%ebp),%edx
  800248:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80024c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800250:	89 44 24 04          	mov    %eax,0x4(%esp)
  800254:	c7 04 24 28 22 80 00 	movl   $0x802228,(%esp)
  80025b:	e8 c0 00 00 00       	call   800320 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800260:	89 74 24 04          	mov    %esi,0x4(%esp)
  800264:	8b 45 10             	mov    0x10(%ebp),%eax
  800267:	89 04 24             	mov    %eax,(%esp)
  80026a:	e8 50 00 00 00       	call   8002bf <vcprintf>
	cprintf("\n");
  80026f:	c7 04 24 43 26 80 00 	movl   $0x802643,(%esp)
  800276:	e8 a5 00 00 00       	call   800320 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80027b:	cc                   	int3   
  80027c:	eb fd                	jmp    80027b <_panic+0x53>
	...

00800280 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	53                   	push   %ebx
  800284:	83 ec 14             	sub    $0x14,%esp
  800287:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80028a:	8b 03                	mov    (%ebx),%eax
  80028c:	8b 55 08             	mov    0x8(%ebp),%edx
  80028f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800293:	40                   	inc    %eax
  800294:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800296:	3d ff 00 00 00       	cmp    $0xff,%eax
  80029b:	75 19                	jne    8002b6 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80029d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8002a4:	00 
  8002a5:	8d 43 08             	lea    0x8(%ebx),%eax
  8002a8:	89 04 24             	mov    %eax,(%esp)
  8002ab:	e8 40 09 00 00       	call   800bf0 <sys_cputs>
		b->idx = 0;
  8002b0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8002b6:	ff 43 04             	incl   0x4(%ebx)
}
  8002b9:	83 c4 14             	add    $0x14,%esp
  8002bc:	5b                   	pop    %ebx
  8002bd:	5d                   	pop    %ebp
  8002be:	c3                   	ret    

008002bf <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002bf:	55                   	push   %ebp
  8002c0:	89 e5                	mov    %esp,%ebp
  8002c2:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8002c8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002cf:	00 00 00 
	b.cnt = 0;
  8002d2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002d9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002df:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ea:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f4:	c7 04 24 80 02 80 00 	movl   $0x800280,(%esp)
  8002fb:	e8 82 01 00 00       	call   800482 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800300:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800306:	89 44 24 04          	mov    %eax,0x4(%esp)
  80030a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800310:	89 04 24             	mov    %eax,(%esp)
  800313:	e8 d8 08 00 00       	call   800bf0 <sys_cputs>

	return b.cnt;
}
  800318:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80031e:	c9                   	leave  
  80031f:	c3                   	ret    

00800320 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800326:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800329:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032d:	8b 45 08             	mov    0x8(%ebp),%eax
  800330:	89 04 24             	mov    %eax,(%esp)
  800333:	e8 87 ff ff ff       	call   8002bf <vcprintf>
	va_end(ap);

	return cnt;
}
  800338:	c9                   	leave  
  800339:	c3                   	ret    
	...

0080033c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80033c:	55                   	push   %ebp
  80033d:	89 e5                	mov    %esp,%ebp
  80033f:	57                   	push   %edi
  800340:	56                   	push   %esi
  800341:	53                   	push   %ebx
  800342:	83 ec 3c             	sub    $0x3c,%esp
  800345:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800348:	89 d7                	mov    %edx,%edi
  80034a:	8b 45 08             	mov    0x8(%ebp),%eax
  80034d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800350:	8b 45 0c             	mov    0xc(%ebp),%eax
  800353:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800356:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800359:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80035c:	85 c0                	test   %eax,%eax
  80035e:	75 08                	jne    800368 <printnum+0x2c>
  800360:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800363:	39 45 10             	cmp    %eax,0x10(%ebp)
  800366:	77 57                	ja     8003bf <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800368:	89 74 24 10          	mov    %esi,0x10(%esp)
  80036c:	4b                   	dec    %ebx
  80036d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800371:	8b 45 10             	mov    0x10(%ebp),%eax
  800374:	89 44 24 08          	mov    %eax,0x8(%esp)
  800378:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80037c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800380:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800387:	00 
  800388:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80038b:	89 04 24             	mov    %eax,(%esp)
  80038e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800391:	89 44 24 04          	mov    %eax,0x4(%esp)
  800395:	e8 ce 1b 00 00       	call   801f68 <__udivdi3>
  80039a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80039e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003a2:	89 04 24             	mov    %eax,(%esp)
  8003a5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003a9:	89 fa                	mov    %edi,%edx
  8003ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003ae:	e8 89 ff ff ff       	call   80033c <printnum>
  8003b3:	eb 0f                	jmp    8003c4 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003b5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003b9:	89 34 24             	mov    %esi,(%esp)
  8003bc:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003bf:	4b                   	dec    %ebx
  8003c0:	85 db                	test   %ebx,%ebx
  8003c2:	7f f1                	jg     8003b5 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003c4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003c8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8003cc:	8b 45 10             	mov    0x10(%ebp),%eax
  8003cf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003d3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003da:	00 
  8003db:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003de:	89 04 24             	mov    %eax,(%esp)
  8003e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003e8:	e8 9b 1c 00 00       	call   802088 <__umoddi3>
  8003ed:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003f1:	0f be 80 4b 22 80 00 	movsbl 0x80224b(%eax),%eax
  8003f8:	89 04 24             	mov    %eax,(%esp)
  8003fb:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8003fe:	83 c4 3c             	add    $0x3c,%esp
  800401:	5b                   	pop    %ebx
  800402:	5e                   	pop    %esi
  800403:	5f                   	pop    %edi
  800404:	5d                   	pop    %ebp
  800405:	c3                   	ret    

00800406 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800406:	55                   	push   %ebp
  800407:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800409:	83 fa 01             	cmp    $0x1,%edx
  80040c:	7e 0e                	jle    80041c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80040e:	8b 10                	mov    (%eax),%edx
  800410:	8d 4a 08             	lea    0x8(%edx),%ecx
  800413:	89 08                	mov    %ecx,(%eax)
  800415:	8b 02                	mov    (%edx),%eax
  800417:	8b 52 04             	mov    0x4(%edx),%edx
  80041a:	eb 22                	jmp    80043e <getuint+0x38>
	else if (lflag)
  80041c:	85 d2                	test   %edx,%edx
  80041e:	74 10                	je     800430 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800420:	8b 10                	mov    (%eax),%edx
  800422:	8d 4a 04             	lea    0x4(%edx),%ecx
  800425:	89 08                	mov    %ecx,(%eax)
  800427:	8b 02                	mov    (%edx),%eax
  800429:	ba 00 00 00 00       	mov    $0x0,%edx
  80042e:	eb 0e                	jmp    80043e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800430:	8b 10                	mov    (%eax),%edx
  800432:	8d 4a 04             	lea    0x4(%edx),%ecx
  800435:	89 08                	mov    %ecx,(%eax)
  800437:	8b 02                	mov    (%edx),%eax
  800439:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80043e:	5d                   	pop    %ebp
  80043f:	c3                   	ret    

00800440 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800440:	55                   	push   %ebp
  800441:	89 e5                	mov    %esp,%ebp
  800443:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800446:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800449:	8b 10                	mov    (%eax),%edx
  80044b:	3b 50 04             	cmp    0x4(%eax),%edx
  80044e:	73 08                	jae    800458 <sprintputch+0x18>
		*b->buf++ = ch;
  800450:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800453:	88 0a                	mov    %cl,(%edx)
  800455:	42                   	inc    %edx
  800456:	89 10                	mov    %edx,(%eax)
}
  800458:	5d                   	pop    %ebp
  800459:	c3                   	ret    

0080045a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80045a:	55                   	push   %ebp
  80045b:	89 e5                	mov    %esp,%ebp
  80045d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800460:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800463:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800467:	8b 45 10             	mov    0x10(%ebp),%eax
  80046a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80046e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800471:	89 44 24 04          	mov    %eax,0x4(%esp)
  800475:	8b 45 08             	mov    0x8(%ebp),%eax
  800478:	89 04 24             	mov    %eax,(%esp)
  80047b:	e8 02 00 00 00       	call   800482 <vprintfmt>
	va_end(ap);
}
  800480:	c9                   	leave  
  800481:	c3                   	ret    

00800482 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800482:	55                   	push   %ebp
  800483:	89 e5                	mov    %esp,%ebp
  800485:	57                   	push   %edi
  800486:	56                   	push   %esi
  800487:	53                   	push   %ebx
  800488:	83 ec 4c             	sub    $0x4c,%esp
  80048b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80048e:	8b 75 10             	mov    0x10(%ebp),%esi
  800491:	eb 12                	jmp    8004a5 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800493:	85 c0                	test   %eax,%eax
  800495:	0f 84 6b 03 00 00    	je     800806 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80049b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80049f:	89 04 24             	mov    %eax,(%esp)
  8004a2:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004a5:	0f b6 06             	movzbl (%esi),%eax
  8004a8:	46                   	inc    %esi
  8004a9:	83 f8 25             	cmp    $0x25,%eax
  8004ac:	75 e5                	jne    800493 <vprintfmt+0x11>
  8004ae:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8004b2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8004b9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8004be:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8004c5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004ca:	eb 26                	jmp    8004f2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cc:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004cf:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8004d3:	eb 1d                	jmp    8004f2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004d8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8004dc:	eb 14                	jmp    8004f2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004de:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8004e1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004e8:	eb 08                	jmp    8004f2 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004ea:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8004ed:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f2:	0f b6 06             	movzbl (%esi),%eax
  8004f5:	8d 56 01             	lea    0x1(%esi),%edx
  8004f8:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004fb:	8a 16                	mov    (%esi),%dl
  8004fd:	83 ea 23             	sub    $0x23,%edx
  800500:	80 fa 55             	cmp    $0x55,%dl
  800503:	0f 87 e1 02 00 00    	ja     8007ea <vprintfmt+0x368>
  800509:	0f b6 d2             	movzbl %dl,%edx
  80050c:	ff 24 95 80 23 80 00 	jmp    *0x802380(,%edx,4)
  800513:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800516:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80051b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80051e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800522:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800525:	8d 50 d0             	lea    -0x30(%eax),%edx
  800528:	83 fa 09             	cmp    $0x9,%edx
  80052b:	77 2a                	ja     800557 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80052d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80052e:	eb eb                	jmp    80051b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800530:	8b 45 14             	mov    0x14(%ebp),%eax
  800533:	8d 50 04             	lea    0x4(%eax),%edx
  800536:	89 55 14             	mov    %edx,0x14(%ebp)
  800539:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80053e:	eb 17                	jmp    800557 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800540:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800544:	78 98                	js     8004de <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800546:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800549:	eb a7                	jmp    8004f2 <vprintfmt+0x70>
  80054b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80054e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800555:	eb 9b                	jmp    8004f2 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800557:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80055b:	79 95                	jns    8004f2 <vprintfmt+0x70>
  80055d:	eb 8b                	jmp    8004ea <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80055f:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800560:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800563:	eb 8d                	jmp    8004f2 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800565:	8b 45 14             	mov    0x14(%ebp),%eax
  800568:	8d 50 04             	lea    0x4(%eax),%edx
  80056b:	89 55 14             	mov    %edx,0x14(%ebp)
  80056e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800572:	8b 00                	mov    (%eax),%eax
  800574:	89 04 24             	mov    %eax,(%esp)
  800577:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80057d:	e9 23 ff ff ff       	jmp    8004a5 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800582:	8b 45 14             	mov    0x14(%ebp),%eax
  800585:	8d 50 04             	lea    0x4(%eax),%edx
  800588:	89 55 14             	mov    %edx,0x14(%ebp)
  80058b:	8b 00                	mov    (%eax),%eax
  80058d:	85 c0                	test   %eax,%eax
  80058f:	79 02                	jns    800593 <vprintfmt+0x111>
  800591:	f7 d8                	neg    %eax
  800593:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800595:	83 f8 0f             	cmp    $0xf,%eax
  800598:	7f 0b                	jg     8005a5 <vprintfmt+0x123>
  80059a:	8b 04 85 e0 24 80 00 	mov    0x8024e0(,%eax,4),%eax
  8005a1:	85 c0                	test   %eax,%eax
  8005a3:	75 23                	jne    8005c8 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8005a5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005a9:	c7 44 24 08 63 22 80 	movl   $0x802263,0x8(%esp)
  8005b0:	00 
  8005b1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8005b8:	89 04 24             	mov    %eax,(%esp)
  8005bb:	e8 9a fe ff ff       	call   80045a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c0:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005c3:	e9 dd fe ff ff       	jmp    8004a5 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8005c8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005cc:	c7 44 24 08 11 26 80 	movl   $0x802611,0x8(%esp)
  8005d3:	00 
  8005d4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8005db:	89 14 24             	mov    %edx,(%esp)
  8005de:	e8 77 fe ff ff       	call   80045a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005e6:	e9 ba fe ff ff       	jmp    8004a5 <vprintfmt+0x23>
  8005eb:	89 f9                	mov    %edi,%ecx
  8005ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005f0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f6:	8d 50 04             	lea    0x4(%eax),%edx
  8005f9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fc:	8b 30                	mov    (%eax),%esi
  8005fe:	85 f6                	test   %esi,%esi
  800600:	75 05                	jne    800607 <vprintfmt+0x185>
				p = "(null)";
  800602:	be 5c 22 80 00       	mov    $0x80225c,%esi
			if (width > 0 && padc != '-')
  800607:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80060b:	0f 8e 84 00 00 00    	jle    800695 <vprintfmt+0x213>
  800611:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800615:	74 7e                	je     800695 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800617:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80061b:	89 34 24             	mov    %esi,(%esp)
  80061e:	e8 8b 02 00 00       	call   8008ae <strnlen>
  800623:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800626:	29 c2                	sub    %eax,%edx
  800628:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80062b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80062f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800632:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800635:	89 de                	mov    %ebx,%esi
  800637:	89 d3                	mov    %edx,%ebx
  800639:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80063b:	eb 0b                	jmp    800648 <vprintfmt+0x1c6>
					putch(padc, putdat);
  80063d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800641:	89 3c 24             	mov    %edi,(%esp)
  800644:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800647:	4b                   	dec    %ebx
  800648:	85 db                	test   %ebx,%ebx
  80064a:	7f f1                	jg     80063d <vprintfmt+0x1bb>
  80064c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80064f:	89 f3                	mov    %esi,%ebx
  800651:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800654:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800657:	85 c0                	test   %eax,%eax
  800659:	79 05                	jns    800660 <vprintfmt+0x1de>
  80065b:	b8 00 00 00 00       	mov    $0x0,%eax
  800660:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800663:	29 c2                	sub    %eax,%edx
  800665:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800668:	eb 2b                	jmp    800695 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80066a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80066e:	74 18                	je     800688 <vprintfmt+0x206>
  800670:	8d 50 e0             	lea    -0x20(%eax),%edx
  800673:	83 fa 5e             	cmp    $0x5e,%edx
  800676:	76 10                	jbe    800688 <vprintfmt+0x206>
					putch('?', putdat);
  800678:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80067c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800683:	ff 55 08             	call   *0x8(%ebp)
  800686:	eb 0a                	jmp    800692 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800688:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80068c:	89 04 24             	mov    %eax,(%esp)
  80068f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800692:	ff 4d e4             	decl   -0x1c(%ebp)
  800695:	0f be 06             	movsbl (%esi),%eax
  800698:	46                   	inc    %esi
  800699:	85 c0                	test   %eax,%eax
  80069b:	74 21                	je     8006be <vprintfmt+0x23c>
  80069d:	85 ff                	test   %edi,%edi
  80069f:	78 c9                	js     80066a <vprintfmt+0x1e8>
  8006a1:	4f                   	dec    %edi
  8006a2:	79 c6                	jns    80066a <vprintfmt+0x1e8>
  8006a4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006a7:	89 de                	mov    %ebx,%esi
  8006a9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8006ac:	eb 18                	jmp    8006c6 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006ae:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006b2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006b9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006bb:	4b                   	dec    %ebx
  8006bc:	eb 08                	jmp    8006c6 <vprintfmt+0x244>
  8006be:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c1:	89 de                	mov    %ebx,%esi
  8006c3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8006c6:	85 db                	test   %ebx,%ebx
  8006c8:	7f e4                	jg     8006ae <vprintfmt+0x22c>
  8006ca:	89 7d 08             	mov    %edi,0x8(%ebp)
  8006cd:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006cf:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006d2:	e9 ce fd ff ff       	jmp    8004a5 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006d7:	83 f9 01             	cmp    $0x1,%ecx
  8006da:	7e 10                	jle    8006ec <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8006dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006df:	8d 50 08             	lea    0x8(%eax),%edx
  8006e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e5:	8b 30                	mov    (%eax),%esi
  8006e7:	8b 78 04             	mov    0x4(%eax),%edi
  8006ea:	eb 26                	jmp    800712 <vprintfmt+0x290>
	else if (lflag)
  8006ec:	85 c9                	test   %ecx,%ecx
  8006ee:	74 12                	je     800702 <vprintfmt+0x280>
		return va_arg(*ap, long);
  8006f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f3:	8d 50 04             	lea    0x4(%eax),%edx
  8006f6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f9:	8b 30                	mov    (%eax),%esi
  8006fb:	89 f7                	mov    %esi,%edi
  8006fd:	c1 ff 1f             	sar    $0x1f,%edi
  800700:	eb 10                	jmp    800712 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800702:	8b 45 14             	mov    0x14(%ebp),%eax
  800705:	8d 50 04             	lea    0x4(%eax),%edx
  800708:	89 55 14             	mov    %edx,0x14(%ebp)
  80070b:	8b 30                	mov    (%eax),%esi
  80070d:	89 f7                	mov    %esi,%edi
  80070f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800712:	85 ff                	test   %edi,%edi
  800714:	78 0a                	js     800720 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800716:	b8 0a 00 00 00       	mov    $0xa,%eax
  80071b:	e9 8c 00 00 00       	jmp    8007ac <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800720:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800724:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80072b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80072e:	f7 de                	neg    %esi
  800730:	83 d7 00             	adc    $0x0,%edi
  800733:	f7 df                	neg    %edi
			}
			base = 10;
  800735:	b8 0a 00 00 00       	mov    $0xa,%eax
  80073a:	eb 70                	jmp    8007ac <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80073c:	89 ca                	mov    %ecx,%edx
  80073e:	8d 45 14             	lea    0x14(%ebp),%eax
  800741:	e8 c0 fc ff ff       	call   800406 <getuint>
  800746:	89 c6                	mov    %eax,%esi
  800748:	89 d7                	mov    %edx,%edi
			base = 10;
  80074a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80074f:	eb 5b                	jmp    8007ac <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  800751:	89 ca                	mov    %ecx,%edx
  800753:	8d 45 14             	lea    0x14(%ebp),%eax
  800756:	e8 ab fc ff ff       	call   800406 <getuint>
  80075b:	89 c6                	mov    %eax,%esi
  80075d:	89 d7                	mov    %edx,%edi
			base = 8;
  80075f:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800764:	eb 46                	jmp    8007ac <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  800766:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80076a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800771:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800774:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800778:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80077f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800782:	8b 45 14             	mov    0x14(%ebp),%eax
  800785:	8d 50 04             	lea    0x4(%eax),%edx
  800788:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80078b:	8b 30                	mov    (%eax),%esi
  80078d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800792:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800797:	eb 13                	jmp    8007ac <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800799:	89 ca                	mov    %ecx,%edx
  80079b:	8d 45 14             	lea    0x14(%ebp),%eax
  80079e:	e8 63 fc ff ff       	call   800406 <getuint>
  8007a3:	89 c6                	mov    %eax,%esi
  8007a5:	89 d7                	mov    %edx,%edi
			base = 16;
  8007a7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007ac:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8007b0:	89 54 24 10          	mov    %edx,0x10(%esp)
  8007b4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007b7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007bb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007bf:	89 34 24             	mov    %esi,(%esp)
  8007c2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007c6:	89 da                	mov    %ebx,%edx
  8007c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cb:	e8 6c fb ff ff       	call   80033c <printnum>
			break;
  8007d0:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007d3:	e9 cd fc ff ff       	jmp    8004a5 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007dc:	89 04 24             	mov    %eax,(%esp)
  8007df:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007e2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007e5:	e9 bb fc ff ff       	jmp    8004a5 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007ea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ee:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007f5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007f8:	eb 01                	jmp    8007fb <vprintfmt+0x379>
  8007fa:	4e                   	dec    %esi
  8007fb:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007ff:	75 f9                	jne    8007fa <vprintfmt+0x378>
  800801:	e9 9f fc ff ff       	jmp    8004a5 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800806:	83 c4 4c             	add    $0x4c,%esp
  800809:	5b                   	pop    %ebx
  80080a:	5e                   	pop    %esi
  80080b:	5f                   	pop    %edi
  80080c:	5d                   	pop    %ebp
  80080d:	c3                   	ret    

0080080e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80080e:	55                   	push   %ebp
  80080f:	89 e5                	mov    %esp,%ebp
  800811:	83 ec 28             	sub    $0x28,%esp
  800814:	8b 45 08             	mov    0x8(%ebp),%eax
  800817:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80081a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80081d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800821:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800824:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80082b:	85 c0                	test   %eax,%eax
  80082d:	74 30                	je     80085f <vsnprintf+0x51>
  80082f:	85 d2                	test   %edx,%edx
  800831:	7e 33                	jle    800866 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800833:	8b 45 14             	mov    0x14(%ebp),%eax
  800836:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80083a:	8b 45 10             	mov    0x10(%ebp),%eax
  80083d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800841:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800844:	89 44 24 04          	mov    %eax,0x4(%esp)
  800848:	c7 04 24 40 04 80 00 	movl   $0x800440,(%esp)
  80084f:	e8 2e fc ff ff       	call   800482 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800854:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800857:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80085a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80085d:	eb 0c                	jmp    80086b <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80085f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800864:	eb 05                	jmp    80086b <vsnprintf+0x5d>
  800866:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80086b:	c9                   	leave  
  80086c:	c3                   	ret    

0080086d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80086d:	55                   	push   %ebp
  80086e:	89 e5                	mov    %esp,%ebp
  800870:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800873:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800876:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80087a:	8b 45 10             	mov    0x10(%ebp),%eax
  80087d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800881:	8b 45 0c             	mov    0xc(%ebp),%eax
  800884:	89 44 24 04          	mov    %eax,0x4(%esp)
  800888:	8b 45 08             	mov    0x8(%ebp),%eax
  80088b:	89 04 24             	mov    %eax,(%esp)
  80088e:	e8 7b ff ff ff       	call   80080e <vsnprintf>
	va_end(ap);

	return rc;
}
  800893:	c9                   	leave  
  800894:	c3                   	ret    
  800895:	00 00                	add    %al,(%eax)
	...

00800898 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800898:	55                   	push   %ebp
  800899:	89 e5                	mov    %esp,%ebp
  80089b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80089e:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a3:	eb 01                	jmp    8008a6 <strlen+0xe>
		n++;
  8008a5:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008a6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008aa:	75 f9                	jne    8008a5 <strlen+0xd>
		n++;
	return n;
}
  8008ac:	5d                   	pop    %ebp
  8008ad:	c3                   	ret    

008008ae <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008ae:	55                   	push   %ebp
  8008af:	89 e5                	mov    %esp,%ebp
  8008b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8008b4:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8008bc:	eb 01                	jmp    8008bf <strnlen+0x11>
		n++;
  8008be:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008bf:	39 d0                	cmp    %edx,%eax
  8008c1:	74 06                	je     8008c9 <strnlen+0x1b>
  8008c3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008c7:	75 f5                	jne    8008be <strnlen+0x10>
		n++;
	return n;
}
  8008c9:	5d                   	pop    %ebp
  8008ca:	c3                   	ret    

008008cb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008cb:	55                   	push   %ebp
  8008cc:	89 e5                	mov    %esp,%ebp
  8008ce:	53                   	push   %ebx
  8008cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8008da:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8008dd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008e0:	42                   	inc    %edx
  8008e1:	84 c9                	test   %cl,%cl
  8008e3:	75 f5                	jne    8008da <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008e5:	5b                   	pop    %ebx
  8008e6:	5d                   	pop    %ebp
  8008e7:	c3                   	ret    

008008e8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	53                   	push   %ebx
  8008ec:	83 ec 08             	sub    $0x8,%esp
  8008ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008f2:	89 1c 24             	mov    %ebx,(%esp)
  8008f5:	e8 9e ff ff ff       	call   800898 <strlen>
	strcpy(dst + len, src);
  8008fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008fd:	89 54 24 04          	mov    %edx,0x4(%esp)
  800901:	01 d8                	add    %ebx,%eax
  800903:	89 04 24             	mov    %eax,(%esp)
  800906:	e8 c0 ff ff ff       	call   8008cb <strcpy>
	return dst;
}
  80090b:	89 d8                	mov    %ebx,%eax
  80090d:	83 c4 08             	add    $0x8,%esp
  800910:	5b                   	pop    %ebx
  800911:	5d                   	pop    %ebp
  800912:	c3                   	ret    

00800913 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800913:	55                   	push   %ebp
  800914:	89 e5                	mov    %esp,%ebp
  800916:	56                   	push   %esi
  800917:	53                   	push   %ebx
  800918:	8b 45 08             	mov    0x8(%ebp),%eax
  80091b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80091e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800921:	b9 00 00 00 00       	mov    $0x0,%ecx
  800926:	eb 0c                	jmp    800934 <strncpy+0x21>
		*dst++ = *src;
  800928:	8a 1a                	mov    (%edx),%bl
  80092a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80092d:	80 3a 01             	cmpb   $0x1,(%edx)
  800930:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800933:	41                   	inc    %ecx
  800934:	39 f1                	cmp    %esi,%ecx
  800936:	75 f0                	jne    800928 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800938:	5b                   	pop    %ebx
  800939:	5e                   	pop    %esi
  80093a:	5d                   	pop    %ebp
  80093b:	c3                   	ret    

0080093c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80093c:	55                   	push   %ebp
  80093d:	89 e5                	mov    %esp,%ebp
  80093f:	56                   	push   %esi
  800940:	53                   	push   %ebx
  800941:	8b 75 08             	mov    0x8(%ebp),%esi
  800944:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800947:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80094a:	85 d2                	test   %edx,%edx
  80094c:	75 0a                	jne    800958 <strlcpy+0x1c>
  80094e:	89 f0                	mov    %esi,%eax
  800950:	eb 1a                	jmp    80096c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800952:	88 18                	mov    %bl,(%eax)
  800954:	40                   	inc    %eax
  800955:	41                   	inc    %ecx
  800956:	eb 02                	jmp    80095a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800958:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80095a:	4a                   	dec    %edx
  80095b:	74 0a                	je     800967 <strlcpy+0x2b>
  80095d:	8a 19                	mov    (%ecx),%bl
  80095f:	84 db                	test   %bl,%bl
  800961:	75 ef                	jne    800952 <strlcpy+0x16>
  800963:	89 c2                	mov    %eax,%edx
  800965:	eb 02                	jmp    800969 <strlcpy+0x2d>
  800967:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800969:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  80096c:	29 f0                	sub    %esi,%eax
}
  80096e:	5b                   	pop    %ebx
  80096f:	5e                   	pop    %esi
  800970:	5d                   	pop    %ebp
  800971:	c3                   	ret    

00800972 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800972:	55                   	push   %ebp
  800973:	89 e5                	mov    %esp,%ebp
  800975:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800978:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80097b:	eb 02                	jmp    80097f <strcmp+0xd>
		p++, q++;
  80097d:	41                   	inc    %ecx
  80097e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80097f:	8a 01                	mov    (%ecx),%al
  800981:	84 c0                	test   %al,%al
  800983:	74 04                	je     800989 <strcmp+0x17>
  800985:	3a 02                	cmp    (%edx),%al
  800987:	74 f4                	je     80097d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800989:	0f b6 c0             	movzbl %al,%eax
  80098c:	0f b6 12             	movzbl (%edx),%edx
  80098f:	29 d0                	sub    %edx,%eax
}
  800991:	5d                   	pop    %ebp
  800992:	c3                   	ret    

00800993 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800993:	55                   	push   %ebp
  800994:	89 e5                	mov    %esp,%ebp
  800996:	53                   	push   %ebx
  800997:	8b 45 08             	mov    0x8(%ebp),%eax
  80099a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80099d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8009a0:	eb 03                	jmp    8009a5 <strncmp+0x12>
		n--, p++, q++;
  8009a2:	4a                   	dec    %edx
  8009a3:	40                   	inc    %eax
  8009a4:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009a5:	85 d2                	test   %edx,%edx
  8009a7:	74 14                	je     8009bd <strncmp+0x2a>
  8009a9:	8a 18                	mov    (%eax),%bl
  8009ab:	84 db                	test   %bl,%bl
  8009ad:	74 04                	je     8009b3 <strncmp+0x20>
  8009af:	3a 19                	cmp    (%ecx),%bl
  8009b1:	74 ef                	je     8009a2 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b3:	0f b6 00             	movzbl (%eax),%eax
  8009b6:	0f b6 11             	movzbl (%ecx),%edx
  8009b9:	29 d0                	sub    %edx,%eax
  8009bb:	eb 05                	jmp    8009c2 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009bd:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009c2:	5b                   	pop    %ebx
  8009c3:	5d                   	pop    %ebp
  8009c4:	c3                   	ret    

008009c5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009c5:	55                   	push   %ebp
  8009c6:	89 e5                	mov    %esp,%ebp
  8009c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cb:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009ce:	eb 05                	jmp    8009d5 <strchr+0x10>
		if (*s == c)
  8009d0:	38 ca                	cmp    %cl,%dl
  8009d2:	74 0c                	je     8009e0 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009d4:	40                   	inc    %eax
  8009d5:	8a 10                	mov    (%eax),%dl
  8009d7:	84 d2                	test   %dl,%dl
  8009d9:	75 f5                	jne    8009d0 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8009db:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e0:	5d                   	pop    %ebp
  8009e1:	c3                   	ret    

008009e2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009e2:	55                   	push   %ebp
  8009e3:	89 e5                	mov    %esp,%ebp
  8009e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e8:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009eb:	eb 05                	jmp    8009f2 <strfind+0x10>
		if (*s == c)
  8009ed:	38 ca                	cmp    %cl,%dl
  8009ef:	74 07                	je     8009f8 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009f1:	40                   	inc    %eax
  8009f2:	8a 10                	mov    (%eax),%dl
  8009f4:	84 d2                	test   %dl,%dl
  8009f6:	75 f5                	jne    8009ed <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8009f8:	5d                   	pop    %ebp
  8009f9:	c3                   	ret    

008009fa <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	57                   	push   %edi
  8009fe:	56                   	push   %esi
  8009ff:	53                   	push   %ebx
  800a00:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a03:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a06:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a09:	85 c9                	test   %ecx,%ecx
  800a0b:	74 30                	je     800a3d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a0d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a13:	75 25                	jne    800a3a <memset+0x40>
  800a15:	f6 c1 03             	test   $0x3,%cl
  800a18:	75 20                	jne    800a3a <memset+0x40>
		c &= 0xFF;
  800a1a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a1d:	89 d3                	mov    %edx,%ebx
  800a1f:	c1 e3 08             	shl    $0x8,%ebx
  800a22:	89 d6                	mov    %edx,%esi
  800a24:	c1 e6 18             	shl    $0x18,%esi
  800a27:	89 d0                	mov    %edx,%eax
  800a29:	c1 e0 10             	shl    $0x10,%eax
  800a2c:	09 f0                	or     %esi,%eax
  800a2e:	09 d0                	or     %edx,%eax
  800a30:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a32:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a35:	fc                   	cld    
  800a36:	f3 ab                	rep stos %eax,%es:(%edi)
  800a38:	eb 03                	jmp    800a3d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a3a:	fc                   	cld    
  800a3b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a3d:	89 f8                	mov    %edi,%eax
  800a3f:	5b                   	pop    %ebx
  800a40:	5e                   	pop    %esi
  800a41:	5f                   	pop    %edi
  800a42:	5d                   	pop    %ebp
  800a43:	c3                   	ret    

00800a44 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a44:	55                   	push   %ebp
  800a45:	89 e5                	mov    %esp,%ebp
  800a47:	57                   	push   %edi
  800a48:	56                   	push   %esi
  800a49:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a4f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a52:	39 c6                	cmp    %eax,%esi
  800a54:	73 34                	jae    800a8a <memmove+0x46>
  800a56:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a59:	39 d0                	cmp    %edx,%eax
  800a5b:	73 2d                	jae    800a8a <memmove+0x46>
		s += n;
		d += n;
  800a5d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a60:	f6 c2 03             	test   $0x3,%dl
  800a63:	75 1b                	jne    800a80 <memmove+0x3c>
  800a65:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a6b:	75 13                	jne    800a80 <memmove+0x3c>
  800a6d:	f6 c1 03             	test   $0x3,%cl
  800a70:	75 0e                	jne    800a80 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a72:	83 ef 04             	sub    $0x4,%edi
  800a75:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a78:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a7b:	fd                   	std    
  800a7c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a7e:	eb 07                	jmp    800a87 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a80:	4f                   	dec    %edi
  800a81:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a84:	fd                   	std    
  800a85:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a87:	fc                   	cld    
  800a88:	eb 20                	jmp    800aaa <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a8a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a90:	75 13                	jne    800aa5 <memmove+0x61>
  800a92:	a8 03                	test   $0x3,%al
  800a94:	75 0f                	jne    800aa5 <memmove+0x61>
  800a96:	f6 c1 03             	test   $0x3,%cl
  800a99:	75 0a                	jne    800aa5 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a9b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a9e:	89 c7                	mov    %eax,%edi
  800aa0:	fc                   	cld    
  800aa1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa3:	eb 05                	jmp    800aaa <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800aa5:	89 c7                	mov    %eax,%edi
  800aa7:	fc                   	cld    
  800aa8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aaa:	5e                   	pop    %esi
  800aab:	5f                   	pop    %edi
  800aac:	5d                   	pop    %ebp
  800aad:	c3                   	ret    

00800aae <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aae:	55                   	push   %ebp
  800aaf:	89 e5                	mov    %esp,%ebp
  800ab1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ab4:	8b 45 10             	mov    0x10(%ebp),%eax
  800ab7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800abb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800abe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ac2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac5:	89 04 24             	mov    %eax,(%esp)
  800ac8:	e8 77 ff ff ff       	call   800a44 <memmove>
}
  800acd:	c9                   	leave  
  800ace:	c3                   	ret    

00800acf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800acf:	55                   	push   %ebp
  800ad0:	89 e5                	mov    %esp,%ebp
  800ad2:	57                   	push   %edi
  800ad3:	56                   	push   %esi
  800ad4:	53                   	push   %ebx
  800ad5:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ad8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800adb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ade:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae3:	eb 16                	jmp    800afb <memcmp+0x2c>
		if (*s1 != *s2)
  800ae5:	8a 04 17             	mov    (%edi,%edx,1),%al
  800ae8:	42                   	inc    %edx
  800ae9:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800aed:	38 c8                	cmp    %cl,%al
  800aef:	74 0a                	je     800afb <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800af1:	0f b6 c0             	movzbl %al,%eax
  800af4:	0f b6 c9             	movzbl %cl,%ecx
  800af7:	29 c8                	sub    %ecx,%eax
  800af9:	eb 09                	jmp    800b04 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800afb:	39 da                	cmp    %ebx,%edx
  800afd:	75 e6                	jne    800ae5 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800aff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b04:	5b                   	pop    %ebx
  800b05:	5e                   	pop    %esi
  800b06:	5f                   	pop    %edi
  800b07:	5d                   	pop    %ebp
  800b08:	c3                   	ret    

00800b09 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b09:	55                   	push   %ebp
  800b0a:	89 e5                	mov    %esp,%ebp
  800b0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b12:	89 c2                	mov    %eax,%edx
  800b14:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b17:	eb 05                	jmp    800b1e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b19:	38 08                	cmp    %cl,(%eax)
  800b1b:	74 05                	je     800b22 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b1d:	40                   	inc    %eax
  800b1e:	39 d0                	cmp    %edx,%eax
  800b20:	72 f7                	jb     800b19 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b22:	5d                   	pop    %ebp
  800b23:	c3                   	ret    

00800b24 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
  800b27:	57                   	push   %edi
  800b28:	56                   	push   %esi
  800b29:	53                   	push   %ebx
  800b2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b30:	eb 01                	jmp    800b33 <strtol+0xf>
		s++;
  800b32:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b33:	8a 02                	mov    (%edx),%al
  800b35:	3c 20                	cmp    $0x20,%al
  800b37:	74 f9                	je     800b32 <strtol+0xe>
  800b39:	3c 09                	cmp    $0x9,%al
  800b3b:	74 f5                	je     800b32 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b3d:	3c 2b                	cmp    $0x2b,%al
  800b3f:	75 08                	jne    800b49 <strtol+0x25>
		s++;
  800b41:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b42:	bf 00 00 00 00       	mov    $0x0,%edi
  800b47:	eb 13                	jmp    800b5c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b49:	3c 2d                	cmp    $0x2d,%al
  800b4b:	75 0a                	jne    800b57 <strtol+0x33>
		s++, neg = 1;
  800b4d:	8d 52 01             	lea    0x1(%edx),%edx
  800b50:	bf 01 00 00 00       	mov    $0x1,%edi
  800b55:	eb 05                	jmp    800b5c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b57:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b5c:	85 db                	test   %ebx,%ebx
  800b5e:	74 05                	je     800b65 <strtol+0x41>
  800b60:	83 fb 10             	cmp    $0x10,%ebx
  800b63:	75 28                	jne    800b8d <strtol+0x69>
  800b65:	8a 02                	mov    (%edx),%al
  800b67:	3c 30                	cmp    $0x30,%al
  800b69:	75 10                	jne    800b7b <strtol+0x57>
  800b6b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b6f:	75 0a                	jne    800b7b <strtol+0x57>
		s += 2, base = 16;
  800b71:	83 c2 02             	add    $0x2,%edx
  800b74:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b79:	eb 12                	jmp    800b8d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b7b:	85 db                	test   %ebx,%ebx
  800b7d:	75 0e                	jne    800b8d <strtol+0x69>
  800b7f:	3c 30                	cmp    $0x30,%al
  800b81:	75 05                	jne    800b88 <strtol+0x64>
		s++, base = 8;
  800b83:	42                   	inc    %edx
  800b84:	b3 08                	mov    $0x8,%bl
  800b86:	eb 05                	jmp    800b8d <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b88:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b8d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b92:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b94:	8a 0a                	mov    (%edx),%cl
  800b96:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b99:	80 fb 09             	cmp    $0x9,%bl
  800b9c:	77 08                	ja     800ba6 <strtol+0x82>
			dig = *s - '0';
  800b9e:	0f be c9             	movsbl %cl,%ecx
  800ba1:	83 e9 30             	sub    $0x30,%ecx
  800ba4:	eb 1e                	jmp    800bc4 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800ba6:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ba9:	80 fb 19             	cmp    $0x19,%bl
  800bac:	77 08                	ja     800bb6 <strtol+0x92>
			dig = *s - 'a' + 10;
  800bae:	0f be c9             	movsbl %cl,%ecx
  800bb1:	83 e9 57             	sub    $0x57,%ecx
  800bb4:	eb 0e                	jmp    800bc4 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800bb6:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800bb9:	80 fb 19             	cmp    $0x19,%bl
  800bbc:	77 12                	ja     800bd0 <strtol+0xac>
			dig = *s - 'A' + 10;
  800bbe:	0f be c9             	movsbl %cl,%ecx
  800bc1:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bc4:	39 f1                	cmp    %esi,%ecx
  800bc6:	7d 0c                	jge    800bd4 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800bc8:	42                   	inc    %edx
  800bc9:	0f af c6             	imul   %esi,%eax
  800bcc:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800bce:	eb c4                	jmp    800b94 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800bd0:	89 c1                	mov    %eax,%ecx
  800bd2:	eb 02                	jmp    800bd6 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bd4:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800bd6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bda:	74 05                	je     800be1 <strtol+0xbd>
		*endptr = (char *) s;
  800bdc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bdf:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800be1:	85 ff                	test   %edi,%edi
  800be3:	74 04                	je     800be9 <strtol+0xc5>
  800be5:	89 c8                	mov    %ecx,%eax
  800be7:	f7 d8                	neg    %eax
}
  800be9:	5b                   	pop    %ebx
  800bea:	5e                   	pop    %esi
  800beb:	5f                   	pop    %edi
  800bec:	5d                   	pop    %ebp
  800bed:	c3                   	ret    
	...

00800bf0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bf0:	55                   	push   %ebp
  800bf1:	89 e5                	mov    %esp,%ebp
  800bf3:	57                   	push   %edi
  800bf4:	56                   	push   %esi
  800bf5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf6:	b8 00 00 00 00       	mov    $0x0,%eax
  800bfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800c01:	89 c3                	mov    %eax,%ebx
  800c03:	89 c7                	mov    %eax,%edi
  800c05:	89 c6                	mov    %eax,%esi
  800c07:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c09:	5b                   	pop    %ebx
  800c0a:	5e                   	pop    %esi
  800c0b:	5f                   	pop    %edi
  800c0c:	5d                   	pop    %ebp
  800c0d:	c3                   	ret    

00800c0e <sys_cgetc>:

int
sys_cgetc(void)
{
  800c0e:	55                   	push   %ebp
  800c0f:	89 e5                	mov    %esp,%ebp
  800c11:	57                   	push   %edi
  800c12:	56                   	push   %esi
  800c13:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c14:	ba 00 00 00 00       	mov    $0x0,%edx
  800c19:	b8 01 00 00 00       	mov    $0x1,%eax
  800c1e:	89 d1                	mov    %edx,%ecx
  800c20:	89 d3                	mov    %edx,%ebx
  800c22:	89 d7                	mov    %edx,%edi
  800c24:	89 d6                	mov    %edx,%esi
  800c26:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c28:	5b                   	pop    %ebx
  800c29:	5e                   	pop    %esi
  800c2a:	5f                   	pop    %edi
  800c2b:	5d                   	pop    %ebp
  800c2c:	c3                   	ret    

00800c2d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800c36:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c3b:	b8 03 00 00 00       	mov    $0x3,%eax
  800c40:	8b 55 08             	mov    0x8(%ebp),%edx
  800c43:	89 cb                	mov    %ecx,%ebx
  800c45:	89 cf                	mov    %ecx,%edi
  800c47:	89 ce                	mov    %ecx,%esi
  800c49:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c4b:	85 c0                	test   %eax,%eax
  800c4d:	7e 28                	jle    800c77 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c53:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c5a:	00 
  800c5b:	c7 44 24 08 3f 25 80 	movl   $0x80253f,0x8(%esp)
  800c62:	00 
  800c63:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c6a:	00 
  800c6b:	c7 04 24 5c 25 80 00 	movl   $0x80255c,(%esp)
  800c72:	e8 b1 f5 ff ff       	call   800228 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c77:	83 c4 2c             	add    $0x2c,%esp
  800c7a:	5b                   	pop    %ebx
  800c7b:	5e                   	pop    %esi
  800c7c:	5f                   	pop    %edi
  800c7d:	5d                   	pop    %ebp
  800c7e:	c3                   	ret    

00800c7f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c7f:	55                   	push   %ebp
  800c80:	89 e5                	mov    %esp,%ebp
  800c82:	57                   	push   %edi
  800c83:	56                   	push   %esi
  800c84:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c85:	ba 00 00 00 00       	mov    $0x0,%edx
  800c8a:	b8 02 00 00 00       	mov    $0x2,%eax
  800c8f:	89 d1                	mov    %edx,%ecx
  800c91:	89 d3                	mov    %edx,%ebx
  800c93:	89 d7                	mov    %edx,%edi
  800c95:	89 d6                	mov    %edx,%esi
  800c97:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c99:	5b                   	pop    %ebx
  800c9a:	5e                   	pop    %esi
  800c9b:	5f                   	pop    %edi
  800c9c:	5d                   	pop    %ebp
  800c9d:	c3                   	ret    

00800c9e <sys_yield>:

void
sys_yield(void)
{
  800c9e:	55                   	push   %ebp
  800c9f:	89 e5                	mov    %esp,%ebp
  800ca1:	57                   	push   %edi
  800ca2:	56                   	push   %esi
  800ca3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca9:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cae:	89 d1                	mov    %edx,%ecx
  800cb0:	89 d3                	mov    %edx,%ebx
  800cb2:	89 d7                	mov    %edx,%edi
  800cb4:	89 d6                	mov    %edx,%esi
  800cb6:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cb8:	5b                   	pop    %ebx
  800cb9:	5e                   	pop    %esi
  800cba:	5f                   	pop    %edi
  800cbb:	5d                   	pop    %ebp
  800cbc:	c3                   	ret    

00800cbd <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cbd:	55                   	push   %ebp
  800cbe:	89 e5                	mov    %esp,%ebp
  800cc0:	57                   	push   %edi
  800cc1:	56                   	push   %esi
  800cc2:	53                   	push   %ebx
  800cc3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc6:	be 00 00 00 00       	mov    $0x0,%esi
  800ccb:	b8 04 00 00 00       	mov    $0x4,%eax
  800cd0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd9:	89 f7                	mov    %esi,%edi
  800cdb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cdd:	85 c0                	test   %eax,%eax
  800cdf:	7e 28                	jle    800d09 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ce5:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800cec:	00 
  800ced:	c7 44 24 08 3f 25 80 	movl   $0x80253f,0x8(%esp)
  800cf4:	00 
  800cf5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cfc:	00 
  800cfd:	c7 04 24 5c 25 80 00 	movl   $0x80255c,(%esp)
  800d04:	e8 1f f5 ff ff       	call   800228 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d09:	83 c4 2c             	add    $0x2c,%esp
  800d0c:	5b                   	pop    %ebx
  800d0d:	5e                   	pop    %esi
  800d0e:	5f                   	pop    %edi
  800d0f:	5d                   	pop    %ebp
  800d10:	c3                   	ret    

00800d11 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d11:	55                   	push   %ebp
  800d12:	89 e5                	mov    %esp,%ebp
  800d14:	57                   	push   %edi
  800d15:	56                   	push   %esi
  800d16:	53                   	push   %ebx
  800d17:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1a:	b8 05 00 00 00       	mov    $0x5,%eax
  800d1f:	8b 75 18             	mov    0x18(%ebp),%esi
  800d22:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d25:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d30:	85 c0                	test   %eax,%eax
  800d32:	7e 28                	jle    800d5c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d34:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d38:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d3f:	00 
  800d40:	c7 44 24 08 3f 25 80 	movl   $0x80253f,0x8(%esp)
  800d47:	00 
  800d48:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d4f:	00 
  800d50:	c7 04 24 5c 25 80 00 	movl   $0x80255c,(%esp)
  800d57:	e8 cc f4 ff ff       	call   800228 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d5c:	83 c4 2c             	add    $0x2c,%esp
  800d5f:	5b                   	pop    %ebx
  800d60:	5e                   	pop    %esi
  800d61:	5f                   	pop    %edi
  800d62:	5d                   	pop    %ebp
  800d63:	c3                   	ret    

00800d64 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d64:	55                   	push   %ebp
  800d65:	89 e5                	mov    %esp,%ebp
  800d67:	57                   	push   %edi
  800d68:	56                   	push   %esi
  800d69:	53                   	push   %ebx
  800d6a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d72:	b8 06 00 00 00       	mov    $0x6,%eax
  800d77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7d:	89 df                	mov    %ebx,%edi
  800d7f:	89 de                	mov    %ebx,%esi
  800d81:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d83:	85 c0                	test   %eax,%eax
  800d85:	7e 28                	jle    800daf <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d87:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d8b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d92:	00 
  800d93:	c7 44 24 08 3f 25 80 	movl   $0x80253f,0x8(%esp)
  800d9a:	00 
  800d9b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800da2:	00 
  800da3:	c7 04 24 5c 25 80 00 	movl   $0x80255c,(%esp)
  800daa:	e8 79 f4 ff ff       	call   800228 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800daf:	83 c4 2c             	add    $0x2c,%esp
  800db2:	5b                   	pop    %ebx
  800db3:	5e                   	pop    %esi
  800db4:	5f                   	pop    %edi
  800db5:	5d                   	pop    %ebp
  800db6:	c3                   	ret    

00800db7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800db7:	55                   	push   %ebp
  800db8:	89 e5                	mov    %esp,%ebp
  800dba:	57                   	push   %edi
  800dbb:	56                   	push   %esi
  800dbc:	53                   	push   %ebx
  800dbd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc5:	b8 08 00 00 00       	mov    $0x8,%eax
  800dca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dcd:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd0:	89 df                	mov    %ebx,%edi
  800dd2:	89 de                	mov    %ebx,%esi
  800dd4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dd6:	85 c0                	test   %eax,%eax
  800dd8:	7e 28                	jle    800e02 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dda:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dde:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800de5:	00 
  800de6:	c7 44 24 08 3f 25 80 	movl   $0x80253f,0x8(%esp)
  800ded:	00 
  800dee:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800df5:	00 
  800df6:	c7 04 24 5c 25 80 00 	movl   $0x80255c,(%esp)
  800dfd:	e8 26 f4 ff ff       	call   800228 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e02:	83 c4 2c             	add    $0x2c,%esp
  800e05:	5b                   	pop    %ebx
  800e06:	5e                   	pop    %esi
  800e07:	5f                   	pop    %edi
  800e08:	5d                   	pop    %ebp
  800e09:	c3                   	ret    

00800e0a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	57                   	push   %edi
  800e0e:	56                   	push   %esi
  800e0f:	53                   	push   %ebx
  800e10:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e13:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e18:	b8 09 00 00 00       	mov    $0x9,%eax
  800e1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e20:	8b 55 08             	mov    0x8(%ebp),%edx
  800e23:	89 df                	mov    %ebx,%edi
  800e25:	89 de                	mov    %ebx,%esi
  800e27:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e29:	85 c0                	test   %eax,%eax
  800e2b:	7e 28                	jle    800e55 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e31:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e38:	00 
  800e39:	c7 44 24 08 3f 25 80 	movl   $0x80253f,0x8(%esp)
  800e40:	00 
  800e41:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e48:	00 
  800e49:	c7 04 24 5c 25 80 00 	movl   $0x80255c,(%esp)
  800e50:	e8 d3 f3 ff ff       	call   800228 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e55:	83 c4 2c             	add    $0x2c,%esp
  800e58:	5b                   	pop    %ebx
  800e59:	5e                   	pop    %esi
  800e5a:	5f                   	pop    %edi
  800e5b:	5d                   	pop    %ebp
  800e5c:	c3                   	ret    

00800e5d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e5d:	55                   	push   %ebp
  800e5e:	89 e5                	mov    %esp,%ebp
  800e60:	57                   	push   %edi
  800e61:	56                   	push   %esi
  800e62:	53                   	push   %ebx
  800e63:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e66:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e6b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e73:	8b 55 08             	mov    0x8(%ebp),%edx
  800e76:	89 df                	mov    %ebx,%edi
  800e78:	89 de                	mov    %ebx,%esi
  800e7a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e7c:	85 c0                	test   %eax,%eax
  800e7e:	7e 28                	jle    800ea8 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e80:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e84:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e8b:	00 
  800e8c:	c7 44 24 08 3f 25 80 	movl   $0x80253f,0x8(%esp)
  800e93:	00 
  800e94:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e9b:	00 
  800e9c:	c7 04 24 5c 25 80 00 	movl   $0x80255c,(%esp)
  800ea3:	e8 80 f3 ff ff       	call   800228 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ea8:	83 c4 2c             	add    $0x2c,%esp
  800eab:	5b                   	pop    %ebx
  800eac:	5e                   	pop    %esi
  800ead:	5f                   	pop    %edi
  800eae:	5d                   	pop    %ebp
  800eaf:	c3                   	ret    

00800eb0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800eb0:	55                   	push   %ebp
  800eb1:	89 e5                	mov    %esp,%ebp
  800eb3:	57                   	push   %edi
  800eb4:	56                   	push   %esi
  800eb5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb6:	be 00 00 00 00       	mov    $0x0,%esi
  800ebb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ec0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ec3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ec6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ecc:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ece:	5b                   	pop    %ebx
  800ecf:	5e                   	pop    %esi
  800ed0:	5f                   	pop    %edi
  800ed1:	5d                   	pop    %ebp
  800ed2:	c3                   	ret    

00800ed3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ed3:	55                   	push   %ebp
  800ed4:	89 e5                	mov    %esp,%ebp
  800ed6:	57                   	push   %edi
  800ed7:	56                   	push   %esi
  800ed8:	53                   	push   %ebx
  800ed9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800edc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ee1:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ee6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee9:	89 cb                	mov    %ecx,%ebx
  800eeb:	89 cf                	mov    %ecx,%edi
  800eed:	89 ce                	mov    %ecx,%esi
  800eef:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ef1:	85 c0                	test   %eax,%eax
  800ef3:	7e 28                	jle    800f1d <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ef5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ef9:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f00:	00 
  800f01:	c7 44 24 08 3f 25 80 	movl   $0x80253f,0x8(%esp)
  800f08:	00 
  800f09:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f10:	00 
  800f11:	c7 04 24 5c 25 80 00 	movl   $0x80255c,(%esp)
  800f18:	e8 0b f3 ff ff       	call   800228 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f1d:	83 c4 2c             	add    $0x2c,%esp
  800f20:	5b                   	pop    %ebx
  800f21:	5e                   	pop    %esi
  800f22:	5f                   	pop    %edi
  800f23:	5d                   	pop    %ebp
  800f24:	c3                   	ret    
  800f25:	00 00                	add    %al,(%eax)
	...

00800f28 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f28:	55                   	push   %ebp
  800f29:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f2e:	05 00 00 00 30       	add    $0x30000000,%eax
  800f33:	c1 e8 0c             	shr    $0xc,%eax
}
  800f36:	5d                   	pop    %ebp
  800f37:	c3                   	ret    

00800f38 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f38:	55                   	push   %ebp
  800f39:	89 e5                	mov    %esp,%ebp
  800f3b:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800f3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f41:	89 04 24             	mov    %eax,(%esp)
  800f44:	e8 df ff ff ff       	call   800f28 <fd2num>
  800f49:	05 20 00 0d 00       	add    $0xd0020,%eax
  800f4e:	c1 e0 0c             	shl    $0xc,%eax
}
  800f51:	c9                   	leave  
  800f52:	c3                   	ret    

00800f53 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f53:	55                   	push   %ebp
  800f54:	89 e5                	mov    %esp,%ebp
  800f56:	53                   	push   %ebx
  800f57:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800f5a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800f5f:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f61:	89 c2                	mov    %eax,%edx
  800f63:	c1 ea 16             	shr    $0x16,%edx
  800f66:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f6d:	f6 c2 01             	test   $0x1,%dl
  800f70:	74 11                	je     800f83 <fd_alloc+0x30>
  800f72:	89 c2                	mov    %eax,%edx
  800f74:	c1 ea 0c             	shr    $0xc,%edx
  800f77:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f7e:	f6 c2 01             	test   $0x1,%dl
  800f81:	75 09                	jne    800f8c <fd_alloc+0x39>
			*fd_store = fd;
  800f83:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800f85:	b8 00 00 00 00       	mov    $0x0,%eax
  800f8a:	eb 17                	jmp    800fa3 <fd_alloc+0x50>
  800f8c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f91:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f96:	75 c7                	jne    800f5f <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f98:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800f9e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800fa3:	5b                   	pop    %ebx
  800fa4:	5d                   	pop    %ebp
  800fa5:	c3                   	ret    

00800fa6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800fa6:	55                   	push   %ebp
  800fa7:	89 e5                	mov    %esp,%ebp
  800fa9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800fac:	83 f8 1f             	cmp    $0x1f,%eax
  800faf:	77 36                	ja     800fe7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800fb1:	05 00 00 0d 00       	add    $0xd0000,%eax
  800fb6:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800fb9:	89 c2                	mov    %eax,%edx
  800fbb:	c1 ea 16             	shr    $0x16,%edx
  800fbe:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fc5:	f6 c2 01             	test   $0x1,%dl
  800fc8:	74 24                	je     800fee <fd_lookup+0x48>
  800fca:	89 c2                	mov    %eax,%edx
  800fcc:	c1 ea 0c             	shr    $0xc,%edx
  800fcf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fd6:	f6 c2 01             	test   $0x1,%dl
  800fd9:	74 1a                	je     800ff5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800fdb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fde:	89 02                	mov    %eax,(%edx)
	return 0;
  800fe0:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe5:	eb 13                	jmp    800ffa <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fe7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fec:	eb 0c                	jmp    800ffa <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ff3:	eb 05                	jmp    800ffa <fd_lookup+0x54>
  800ff5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ffa:	5d                   	pop    %ebp
  800ffb:	c3                   	ret    

00800ffc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ffc:	55                   	push   %ebp
  800ffd:	89 e5                	mov    %esp,%ebp
  800fff:	53                   	push   %ebx
  801000:	83 ec 14             	sub    $0x14,%esp
  801003:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801006:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801009:	ba 00 00 00 00       	mov    $0x0,%edx
  80100e:	eb 0e                	jmp    80101e <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801010:	39 08                	cmp    %ecx,(%eax)
  801012:	75 09                	jne    80101d <dev_lookup+0x21>
			*dev = devtab[i];
  801014:	89 03                	mov    %eax,(%ebx)
			return 0;
  801016:	b8 00 00 00 00       	mov    $0x0,%eax
  80101b:	eb 33                	jmp    801050 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80101d:	42                   	inc    %edx
  80101e:	8b 04 95 e8 25 80 00 	mov    0x8025e8(,%edx,4),%eax
  801025:	85 c0                	test   %eax,%eax
  801027:	75 e7                	jne    801010 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801029:	a1 08 40 80 00       	mov    0x804008,%eax
  80102e:	8b 40 48             	mov    0x48(%eax),%eax
  801031:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801035:	89 44 24 04          	mov    %eax,0x4(%esp)
  801039:	c7 04 24 6c 25 80 00 	movl   $0x80256c,(%esp)
  801040:	e8 db f2 ff ff       	call   800320 <cprintf>
	*dev = 0;
  801045:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80104b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801050:	83 c4 14             	add    $0x14,%esp
  801053:	5b                   	pop    %ebx
  801054:	5d                   	pop    %ebp
  801055:	c3                   	ret    

00801056 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801056:	55                   	push   %ebp
  801057:	89 e5                	mov    %esp,%ebp
  801059:	56                   	push   %esi
  80105a:	53                   	push   %ebx
  80105b:	83 ec 30             	sub    $0x30,%esp
  80105e:	8b 75 08             	mov    0x8(%ebp),%esi
  801061:	8a 45 0c             	mov    0xc(%ebp),%al
  801064:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801067:	89 34 24             	mov    %esi,(%esp)
  80106a:	e8 b9 fe ff ff       	call   800f28 <fd2num>
  80106f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801072:	89 54 24 04          	mov    %edx,0x4(%esp)
  801076:	89 04 24             	mov    %eax,(%esp)
  801079:	e8 28 ff ff ff       	call   800fa6 <fd_lookup>
  80107e:	89 c3                	mov    %eax,%ebx
  801080:	85 c0                	test   %eax,%eax
  801082:	78 05                	js     801089 <fd_close+0x33>
	    || fd != fd2)
  801084:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801087:	74 0d                	je     801096 <fd_close+0x40>
		return (must_exist ? r : 0);
  801089:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80108d:	75 46                	jne    8010d5 <fd_close+0x7f>
  80108f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801094:	eb 3f                	jmp    8010d5 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801096:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801099:	89 44 24 04          	mov    %eax,0x4(%esp)
  80109d:	8b 06                	mov    (%esi),%eax
  80109f:	89 04 24             	mov    %eax,(%esp)
  8010a2:	e8 55 ff ff ff       	call   800ffc <dev_lookup>
  8010a7:	89 c3                	mov    %eax,%ebx
  8010a9:	85 c0                	test   %eax,%eax
  8010ab:	78 18                	js     8010c5 <fd_close+0x6f>
		if (dev->dev_close)
  8010ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010b0:	8b 40 10             	mov    0x10(%eax),%eax
  8010b3:	85 c0                	test   %eax,%eax
  8010b5:	74 09                	je     8010c0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8010b7:	89 34 24             	mov    %esi,(%esp)
  8010ba:	ff d0                	call   *%eax
  8010bc:	89 c3                	mov    %eax,%ebx
  8010be:	eb 05                	jmp    8010c5 <fd_close+0x6f>
		else
			r = 0;
  8010c0:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8010c5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010c9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010d0:	e8 8f fc ff ff       	call   800d64 <sys_page_unmap>
	return r;
}
  8010d5:	89 d8                	mov    %ebx,%eax
  8010d7:	83 c4 30             	add    $0x30,%esp
  8010da:	5b                   	pop    %ebx
  8010db:	5e                   	pop    %esi
  8010dc:	5d                   	pop    %ebp
  8010dd:	c3                   	ret    

008010de <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8010de:	55                   	push   %ebp
  8010df:	89 e5                	mov    %esp,%ebp
  8010e1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ee:	89 04 24             	mov    %eax,(%esp)
  8010f1:	e8 b0 fe ff ff       	call   800fa6 <fd_lookup>
  8010f6:	85 c0                	test   %eax,%eax
  8010f8:	78 13                	js     80110d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8010fa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801101:	00 
  801102:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801105:	89 04 24             	mov    %eax,(%esp)
  801108:	e8 49 ff ff ff       	call   801056 <fd_close>
}
  80110d:	c9                   	leave  
  80110e:	c3                   	ret    

0080110f <close_all>:

void
close_all(void)
{
  80110f:	55                   	push   %ebp
  801110:	89 e5                	mov    %esp,%ebp
  801112:	53                   	push   %ebx
  801113:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801116:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80111b:	89 1c 24             	mov    %ebx,(%esp)
  80111e:	e8 bb ff ff ff       	call   8010de <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801123:	43                   	inc    %ebx
  801124:	83 fb 20             	cmp    $0x20,%ebx
  801127:	75 f2                	jne    80111b <close_all+0xc>
		close(i);
}
  801129:	83 c4 14             	add    $0x14,%esp
  80112c:	5b                   	pop    %ebx
  80112d:	5d                   	pop    %ebp
  80112e:	c3                   	ret    

0080112f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80112f:	55                   	push   %ebp
  801130:	89 e5                	mov    %esp,%ebp
  801132:	57                   	push   %edi
  801133:	56                   	push   %esi
  801134:	53                   	push   %ebx
  801135:	83 ec 4c             	sub    $0x4c,%esp
  801138:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80113b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80113e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801142:	8b 45 08             	mov    0x8(%ebp),%eax
  801145:	89 04 24             	mov    %eax,(%esp)
  801148:	e8 59 fe ff ff       	call   800fa6 <fd_lookup>
  80114d:	89 c3                	mov    %eax,%ebx
  80114f:	85 c0                	test   %eax,%eax
  801151:	0f 88 e1 00 00 00    	js     801238 <dup+0x109>
		return r;
	close(newfdnum);
  801157:	89 3c 24             	mov    %edi,(%esp)
  80115a:	e8 7f ff ff ff       	call   8010de <close>

	newfd = INDEX2FD(newfdnum);
  80115f:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801165:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801168:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80116b:	89 04 24             	mov    %eax,(%esp)
  80116e:	e8 c5 fd ff ff       	call   800f38 <fd2data>
  801173:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801175:	89 34 24             	mov    %esi,(%esp)
  801178:	e8 bb fd ff ff       	call   800f38 <fd2data>
  80117d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801180:	89 d8                	mov    %ebx,%eax
  801182:	c1 e8 16             	shr    $0x16,%eax
  801185:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80118c:	a8 01                	test   $0x1,%al
  80118e:	74 46                	je     8011d6 <dup+0xa7>
  801190:	89 d8                	mov    %ebx,%eax
  801192:	c1 e8 0c             	shr    $0xc,%eax
  801195:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80119c:	f6 c2 01             	test   $0x1,%dl
  80119f:	74 35                	je     8011d6 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8011a1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011a8:	25 07 0e 00 00       	and    $0xe07,%eax
  8011ad:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011b1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8011b4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011b8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011bf:	00 
  8011c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011c4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011cb:	e8 41 fb ff ff       	call   800d11 <sys_page_map>
  8011d0:	89 c3                	mov    %eax,%ebx
  8011d2:	85 c0                	test   %eax,%eax
  8011d4:	78 3b                	js     801211 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011d9:	89 c2                	mov    %eax,%edx
  8011db:	c1 ea 0c             	shr    $0xc,%edx
  8011de:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011e5:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8011eb:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011ef:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011f3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011fa:	00 
  8011fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801206:	e8 06 fb ff ff       	call   800d11 <sys_page_map>
  80120b:	89 c3                	mov    %eax,%ebx
  80120d:	85 c0                	test   %eax,%eax
  80120f:	79 25                	jns    801236 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801211:	89 74 24 04          	mov    %esi,0x4(%esp)
  801215:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80121c:	e8 43 fb ff ff       	call   800d64 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801221:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801224:	89 44 24 04          	mov    %eax,0x4(%esp)
  801228:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80122f:	e8 30 fb ff ff       	call   800d64 <sys_page_unmap>
	return r;
  801234:	eb 02                	jmp    801238 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801236:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801238:	89 d8                	mov    %ebx,%eax
  80123a:	83 c4 4c             	add    $0x4c,%esp
  80123d:	5b                   	pop    %ebx
  80123e:	5e                   	pop    %esi
  80123f:	5f                   	pop    %edi
  801240:	5d                   	pop    %ebp
  801241:	c3                   	ret    

00801242 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801242:	55                   	push   %ebp
  801243:	89 e5                	mov    %esp,%ebp
  801245:	53                   	push   %ebx
  801246:	83 ec 24             	sub    $0x24,%esp
  801249:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80124c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80124f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801253:	89 1c 24             	mov    %ebx,(%esp)
  801256:	e8 4b fd ff ff       	call   800fa6 <fd_lookup>
  80125b:	85 c0                	test   %eax,%eax
  80125d:	78 6d                	js     8012cc <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80125f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801262:	89 44 24 04          	mov    %eax,0x4(%esp)
  801266:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801269:	8b 00                	mov    (%eax),%eax
  80126b:	89 04 24             	mov    %eax,(%esp)
  80126e:	e8 89 fd ff ff       	call   800ffc <dev_lookup>
  801273:	85 c0                	test   %eax,%eax
  801275:	78 55                	js     8012cc <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801277:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80127a:	8b 50 08             	mov    0x8(%eax),%edx
  80127d:	83 e2 03             	and    $0x3,%edx
  801280:	83 fa 01             	cmp    $0x1,%edx
  801283:	75 23                	jne    8012a8 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801285:	a1 08 40 80 00       	mov    0x804008,%eax
  80128a:	8b 40 48             	mov    0x48(%eax),%eax
  80128d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801291:	89 44 24 04          	mov    %eax,0x4(%esp)
  801295:	c7 04 24 ad 25 80 00 	movl   $0x8025ad,(%esp)
  80129c:	e8 7f f0 ff ff       	call   800320 <cprintf>
		return -E_INVAL;
  8012a1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012a6:	eb 24                	jmp    8012cc <read+0x8a>
	}
	if (!dev->dev_read)
  8012a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012ab:	8b 52 08             	mov    0x8(%edx),%edx
  8012ae:	85 d2                	test   %edx,%edx
  8012b0:	74 15                	je     8012c7 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8012b2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8012b5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012bc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8012c0:	89 04 24             	mov    %eax,(%esp)
  8012c3:	ff d2                	call   *%edx
  8012c5:	eb 05                	jmp    8012cc <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8012c7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8012cc:	83 c4 24             	add    $0x24,%esp
  8012cf:	5b                   	pop    %ebx
  8012d0:	5d                   	pop    %ebp
  8012d1:	c3                   	ret    

008012d2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8012d2:	55                   	push   %ebp
  8012d3:	89 e5                	mov    %esp,%ebp
  8012d5:	57                   	push   %edi
  8012d6:	56                   	push   %esi
  8012d7:	53                   	push   %ebx
  8012d8:	83 ec 1c             	sub    $0x1c,%esp
  8012db:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012de:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012e6:	eb 23                	jmp    80130b <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8012e8:	89 f0                	mov    %esi,%eax
  8012ea:	29 d8                	sub    %ebx,%eax
  8012ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012f3:	01 d8                	add    %ebx,%eax
  8012f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012f9:	89 3c 24             	mov    %edi,(%esp)
  8012fc:	e8 41 ff ff ff       	call   801242 <read>
		if (m < 0)
  801301:	85 c0                	test   %eax,%eax
  801303:	78 10                	js     801315 <readn+0x43>
			return m;
		if (m == 0)
  801305:	85 c0                	test   %eax,%eax
  801307:	74 0a                	je     801313 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801309:	01 c3                	add    %eax,%ebx
  80130b:	39 f3                	cmp    %esi,%ebx
  80130d:	72 d9                	jb     8012e8 <readn+0x16>
  80130f:	89 d8                	mov    %ebx,%eax
  801311:	eb 02                	jmp    801315 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801313:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801315:	83 c4 1c             	add    $0x1c,%esp
  801318:	5b                   	pop    %ebx
  801319:	5e                   	pop    %esi
  80131a:	5f                   	pop    %edi
  80131b:	5d                   	pop    %ebp
  80131c:	c3                   	ret    

0080131d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80131d:	55                   	push   %ebp
  80131e:	89 e5                	mov    %esp,%ebp
  801320:	53                   	push   %ebx
  801321:	83 ec 24             	sub    $0x24,%esp
  801324:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801327:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80132a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80132e:	89 1c 24             	mov    %ebx,(%esp)
  801331:	e8 70 fc ff ff       	call   800fa6 <fd_lookup>
  801336:	85 c0                	test   %eax,%eax
  801338:	78 68                	js     8013a2 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80133a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80133d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801341:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801344:	8b 00                	mov    (%eax),%eax
  801346:	89 04 24             	mov    %eax,(%esp)
  801349:	e8 ae fc ff ff       	call   800ffc <dev_lookup>
  80134e:	85 c0                	test   %eax,%eax
  801350:	78 50                	js     8013a2 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801352:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801355:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801359:	75 23                	jne    80137e <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80135b:	a1 08 40 80 00       	mov    0x804008,%eax
  801360:	8b 40 48             	mov    0x48(%eax),%eax
  801363:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801367:	89 44 24 04          	mov    %eax,0x4(%esp)
  80136b:	c7 04 24 c9 25 80 00 	movl   $0x8025c9,(%esp)
  801372:	e8 a9 ef ff ff       	call   800320 <cprintf>
		return -E_INVAL;
  801377:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80137c:	eb 24                	jmp    8013a2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80137e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801381:	8b 52 0c             	mov    0xc(%edx),%edx
  801384:	85 d2                	test   %edx,%edx
  801386:	74 15                	je     80139d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801388:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80138b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80138f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801392:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801396:	89 04 24             	mov    %eax,(%esp)
  801399:	ff d2                	call   *%edx
  80139b:	eb 05                	jmp    8013a2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80139d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8013a2:	83 c4 24             	add    $0x24,%esp
  8013a5:	5b                   	pop    %ebx
  8013a6:	5d                   	pop    %ebp
  8013a7:	c3                   	ret    

008013a8 <seek>:

int
seek(int fdnum, off_t offset)
{
  8013a8:	55                   	push   %ebp
  8013a9:	89 e5                	mov    %esp,%ebp
  8013ab:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013ae:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8013b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b8:	89 04 24             	mov    %eax,(%esp)
  8013bb:	e8 e6 fb ff ff       	call   800fa6 <fd_lookup>
  8013c0:	85 c0                	test   %eax,%eax
  8013c2:	78 0e                	js     8013d2 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8013c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8013c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013ca:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8013cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013d2:	c9                   	leave  
  8013d3:	c3                   	ret    

008013d4 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8013d4:	55                   	push   %ebp
  8013d5:	89 e5                	mov    %esp,%ebp
  8013d7:	53                   	push   %ebx
  8013d8:	83 ec 24             	sub    $0x24,%esp
  8013db:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013de:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e5:	89 1c 24             	mov    %ebx,(%esp)
  8013e8:	e8 b9 fb ff ff       	call   800fa6 <fd_lookup>
  8013ed:	85 c0                	test   %eax,%eax
  8013ef:	78 61                	js     801452 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013fb:	8b 00                	mov    (%eax),%eax
  8013fd:	89 04 24             	mov    %eax,(%esp)
  801400:	e8 f7 fb ff ff       	call   800ffc <dev_lookup>
  801405:	85 c0                	test   %eax,%eax
  801407:	78 49                	js     801452 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801409:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80140c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801410:	75 23                	jne    801435 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801412:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801417:	8b 40 48             	mov    0x48(%eax),%eax
  80141a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80141e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801422:	c7 04 24 8c 25 80 00 	movl   $0x80258c,(%esp)
  801429:	e8 f2 ee ff ff       	call   800320 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80142e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801433:	eb 1d                	jmp    801452 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801435:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801438:	8b 52 18             	mov    0x18(%edx),%edx
  80143b:	85 d2                	test   %edx,%edx
  80143d:	74 0e                	je     80144d <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80143f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801442:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801446:	89 04 24             	mov    %eax,(%esp)
  801449:	ff d2                	call   *%edx
  80144b:	eb 05                	jmp    801452 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80144d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801452:	83 c4 24             	add    $0x24,%esp
  801455:	5b                   	pop    %ebx
  801456:	5d                   	pop    %ebp
  801457:	c3                   	ret    

00801458 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801458:	55                   	push   %ebp
  801459:	89 e5                	mov    %esp,%ebp
  80145b:	53                   	push   %ebx
  80145c:	83 ec 24             	sub    $0x24,%esp
  80145f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801462:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801465:	89 44 24 04          	mov    %eax,0x4(%esp)
  801469:	8b 45 08             	mov    0x8(%ebp),%eax
  80146c:	89 04 24             	mov    %eax,(%esp)
  80146f:	e8 32 fb ff ff       	call   800fa6 <fd_lookup>
  801474:	85 c0                	test   %eax,%eax
  801476:	78 52                	js     8014ca <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801478:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80147b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80147f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801482:	8b 00                	mov    (%eax),%eax
  801484:	89 04 24             	mov    %eax,(%esp)
  801487:	e8 70 fb ff ff       	call   800ffc <dev_lookup>
  80148c:	85 c0                	test   %eax,%eax
  80148e:	78 3a                	js     8014ca <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801490:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801493:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801497:	74 2c                	je     8014c5 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801499:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80149c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8014a3:	00 00 00 
	stat->st_isdir = 0;
  8014a6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8014ad:	00 00 00 
	stat->st_dev = dev;
  8014b0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8014b6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014ba:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014bd:	89 14 24             	mov    %edx,(%esp)
  8014c0:	ff 50 14             	call   *0x14(%eax)
  8014c3:	eb 05                	jmp    8014ca <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8014c5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8014ca:	83 c4 24             	add    $0x24,%esp
  8014cd:	5b                   	pop    %ebx
  8014ce:	5d                   	pop    %ebp
  8014cf:	c3                   	ret    

008014d0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8014d0:	55                   	push   %ebp
  8014d1:	89 e5                	mov    %esp,%ebp
  8014d3:	56                   	push   %esi
  8014d4:	53                   	push   %ebx
  8014d5:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8014d8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8014df:	00 
  8014e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e3:	89 04 24             	mov    %eax,(%esp)
  8014e6:	e8 2d 02 00 00       	call   801718 <open>
  8014eb:	89 c3                	mov    %eax,%ebx
  8014ed:	85 c0                	test   %eax,%eax
  8014ef:	78 1b                	js     80150c <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8014f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014f8:	89 1c 24             	mov    %ebx,(%esp)
  8014fb:	e8 58 ff ff ff       	call   801458 <fstat>
  801500:	89 c6                	mov    %eax,%esi
	close(fd);
  801502:	89 1c 24             	mov    %ebx,(%esp)
  801505:	e8 d4 fb ff ff       	call   8010de <close>
	return r;
  80150a:	89 f3                	mov    %esi,%ebx
}
  80150c:	89 d8                	mov    %ebx,%eax
  80150e:	83 c4 10             	add    $0x10,%esp
  801511:	5b                   	pop    %ebx
  801512:	5e                   	pop    %esi
  801513:	5d                   	pop    %ebp
  801514:	c3                   	ret    
  801515:	00 00                	add    %al,(%eax)
	...

00801518 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801518:	55                   	push   %ebp
  801519:	89 e5                	mov    %esp,%ebp
  80151b:	56                   	push   %esi
  80151c:	53                   	push   %ebx
  80151d:	83 ec 10             	sub    $0x10,%esp
  801520:	89 c3                	mov    %eax,%ebx
  801522:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801524:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  80152b:	75 11                	jne    80153e <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80152d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801534:	e8 a6 09 00 00       	call   801edf <ipc_find_env>
  801539:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80153e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801545:	00 
  801546:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  80154d:	00 
  80154e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801552:	a1 04 40 80 00       	mov    0x804004,%eax
  801557:	89 04 24             	mov    %eax,(%esp)
  80155a:	e8 12 09 00 00       	call   801e71 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80155f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801566:	00 
  801567:	89 74 24 04          	mov    %esi,0x4(%esp)
  80156b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801572:	e8 91 08 00 00       	call   801e08 <ipc_recv>
}
  801577:	83 c4 10             	add    $0x10,%esp
  80157a:	5b                   	pop    %ebx
  80157b:	5e                   	pop    %esi
  80157c:	5d                   	pop    %ebp
  80157d:	c3                   	ret    

0080157e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80157e:	55                   	push   %ebp
  80157f:	89 e5                	mov    %esp,%ebp
  801581:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801584:	8b 45 08             	mov    0x8(%ebp),%eax
  801587:	8b 40 0c             	mov    0xc(%eax),%eax
  80158a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80158f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801592:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801597:	ba 00 00 00 00       	mov    $0x0,%edx
  80159c:	b8 02 00 00 00       	mov    $0x2,%eax
  8015a1:	e8 72 ff ff ff       	call   801518 <fsipc>
}
  8015a6:	c9                   	leave  
  8015a7:	c3                   	ret    

008015a8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8015a8:	55                   	push   %ebp
  8015a9:	89 e5                	mov    %esp,%ebp
  8015ab:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8015ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8015b1:	8b 40 0c             	mov    0xc(%eax),%eax
  8015b4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8015b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8015be:	b8 06 00 00 00       	mov    $0x6,%eax
  8015c3:	e8 50 ff ff ff       	call   801518 <fsipc>
}
  8015c8:	c9                   	leave  
  8015c9:	c3                   	ret    

008015ca <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8015ca:	55                   	push   %ebp
  8015cb:	89 e5                	mov    %esp,%ebp
  8015cd:	53                   	push   %ebx
  8015ce:	83 ec 14             	sub    $0x14,%esp
  8015d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8015d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8015d7:	8b 40 0c             	mov    0xc(%eax),%eax
  8015da:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8015df:	ba 00 00 00 00       	mov    $0x0,%edx
  8015e4:	b8 05 00 00 00       	mov    $0x5,%eax
  8015e9:	e8 2a ff ff ff       	call   801518 <fsipc>
  8015ee:	85 c0                	test   %eax,%eax
  8015f0:	78 2b                	js     80161d <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8015f2:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8015f9:	00 
  8015fa:	89 1c 24             	mov    %ebx,(%esp)
  8015fd:	e8 c9 f2 ff ff       	call   8008cb <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801602:	a1 80 50 80 00       	mov    0x805080,%eax
  801607:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80160d:	a1 84 50 80 00       	mov    0x805084,%eax
  801612:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801618:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80161d:	83 c4 14             	add    $0x14,%esp
  801620:	5b                   	pop    %ebx
  801621:	5d                   	pop    %ebp
  801622:	c3                   	ret    

00801623 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801623:	55                   	push   %ebp
  801624:	89 e5                	mov    %esp,%ebp
  801626:	83 ec 18             	sub    $0x18,%esp
  801629:	8b 55 10             	mov    0x10(%ebp),%edx
  80162c:	89 d0                	mov    %edx,%eax
  80162e:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  801634:	76 05                	jbe    80163b <devfile_write+0x18>
  801636:	b8 00 10 00 00       	mov    $0x1000,%eax
	//panic("devfile_write not implemented");
	int r;
	//uint32_t maxsize = BLKSIZE - sizeof(int) - sizeof(size_t);	
	if (n > BLKSIZE)
		n = BLKSIZE;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80163b:	8b 55 08             	mov    0x8(%ebp),%edx
  80163e:	8b 52 0c             	mov    0xc(%edx),%edx
  801641:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801647:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80164c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801650:	8b 45 0c             	mov    0xc(%ebp),%eax
  801653:	89 44 24 04          	mov    %eax,0x4(%esp)
  801657:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  80165e:	e8 e1 f3 ff ff       	call   800a44 <memmove>
	 
	return fsipc(FSREQ_WRITE, NULL);
  801663:	ba 00 00 00 00       	mov    $0x0,%edx
  801668:	b8 04 00 00 00       	mov    $0x4,%eax
  80166d:	e8 a6 fe ff ff       	call   801518 <fsipc>
}
  801672:	c9                   	leave  
  801673:	c3                   	ret    

00801674 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801674:	55                   	push   %ebp
  801675:	89 e5                	mov    %esp,%ebp
  801677:	56                   	push   %esi
  801678:	53                   	push   %ebx
  801679:	83 ec 10             	sub    $0x10,%esp
  80167c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80167f:	8b 45 08             	mov    0x8(%ebp),%eax
  801682:	8b 40 0c             	mov    0xc(%eax),%eax
  801685:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80168a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801690:	ba 00 00 00 00       	mov    $0x0,%edx
  801695:	b8 03 00 00 00       	mov    $0x3,%eax
  80169a:	e8 79 fe ff ff       	call   801518 <fsipc>
  80169f:	89 c3                	mov    %eax,%ebx
  8016a1:	85 c0                	test   %eax,%eax
  8016a3:	78 6a                	js     80170f <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8016a5:	39 c6                	cmp    %eax,%esi
  8016a7:	73 24                	jae    8016cd <devfile_read+0x59>
  8016a9:	c7 44 24 0c f8 25 80 	movl   $0x8025f8,0xc(%esp)
  8016b0:	00 
  8016b1:	c7 44 24 08 ff 25 80 	movl   $0x8025ff,0x8(%esp)
  8016b8:	00 
  8016b9:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8016c0:	00 
  8016c1:	c7 04 24 14 26 80 00 	movl   $0x802614,(%esp)
  8016c8:	e8 5b eb ff ff       	call   800228 <_panic>
	assert(r <= PGSIZE);
  8016cd:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8016d2:	7e 24                	jle    8016f8 <devfile_read+0x84>
  8016d4:	c7 44 24 0c 1f 26 80 	movl   $0x80261f,0xc(%esp)
  8016db:	00 
  8016dc:	c7 44 24 08 ff 25 80 	movl   $0x8025ff,0x8(%esp)
  8016e3:	00 
  8016e4:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8016eb:	00 
  8016ec:	c7 04 24 14 26 80 00 	movl   $0x802614,(%esp)
  8016f3:	e8 30 eb ff ff       	call   800228 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8016f8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016fc:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801703:	00 
  801704:	8b 45 0c             	mov    0xc(%ebp),%eax
  801707:	89 04 24             	mov    %eax,(%esp)
  80170a:	e8 35 f3 ff ff       	call   800a44 <memmove>
	return r;
}
  80170f:	89 d8                	mov    %ebx,%eax
  801711:	83 c4 10             	add    $0x10,%esp
  801714:	5b                   	pop    %ebx
  801715:	5e                   	pop    %esi
  801716:	5d                   	pop    %ebp
  801717:	c3                   	ret    

00801718 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801718:	55                   	push   %ebp
  801719:	89 e5                	mov    %esp,%ebp
  80171b:	56                   	push   %esi
  80171c:	53                   	push   %ebx
  80171d:	83 ec 20             	sub    $0x20,%esp
  801720:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801723:	89 34 24             	mov    %esi,(%esp)
  801726:	e8 6d f1 ff ff       	call   800898 <strlen>
  80172b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801730:	7f 60                	jg     801792 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801732:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801735:	89 04 24             	mov    %eax,(%esp)
  801738:	e8 16 f8 ff ff       	call   800f53 <fd_alloc>
  80173d:	89 c3                	mov    %eax,%ebx
  80173f:	85 c0                	test   %eax,%eax
  801741:	78 54                	js     801797 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801743:	89 74 24 04          	mov    %esi,0x4(%esp)
  801747:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  80174e:	e8 78 f1 ff ff       	call   8008cb <strcpy>
	fsipcbuf.open.req_omode = mode;
  801753:	8b 45 0c             	mov    0xc(%ebp),%eax
  801756:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80175b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80175e:	b8 01 00 00 00       	mov    $0x1,%eax
  801763:	e8 b0 fd ff ff       	call   801518 <fsipc>
  801768:	89 c3                	mov    %eax,%ebx
  80176a:	85 c0                	test   %eax,%eax
  80176c:	79 15                	jns    801783 <open+0x6b>
		fd_close(fd, 0);
  80176e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801775:	00 
  801776:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801779:	89 04 24             	mov    %eax,(%esp)
  80177c:	e8 d5 f8 ff ff       	call   801056 <fd_close>
		return r;
  801781:	eb 14                	jmp    801797 <open+0x7f>
	}

	return fd2num(fd);
  801783:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801786:	89 04 24             	mov    %eax,(%esp)
  801789:	e8 9a f7 ff ff       	call   800f28 <fd2num>
  80178e:	89 c3                	mov    %eax,%ebx
  801790:	eb 05                	jmp    801797 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801792:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801797:	89 d8                	mov    %ebx,%eax
  801799:	83 c4 20             	add    $0x20,%esp
  80179c:	5b                   	pop    %ebx
  80179d:	5e                   	pop    %esi
  80179e:	5d                   	pop    %ebp
  80179f:	c3                   	ret    

008017a0 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8017a0:	55                   	push   %ebp
  8017a1:	89 e5                	mov    %esp,%ebp
  8017a3:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8017a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ab:	b8 08 00 00 00       	mov    $0x8,%eax
  8017b0:	e8 63 fd ff ff       	call   801518 <fsipc>
}
  8017b5:	c9                   	leave  
  8017b6:	c3                   	ret    
	...

008017b8 <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  8017b8:	55                   	push   %ebp
  8017b9:	89 e5                	mov    %esp,%ebp
  8017bb:	53                   	push   %ebx
  8017bc:	83 ec 14             	sub    $0x14,%esp
  8017bf:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  8017c1:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8017c5:	7e 32                	jle    8017f9 <writebuf+0x41>
		ssize_t result = write(b->fd, b->buf, b->idx);
  8017c7:	8b 40 04             	mov    0x4(%eax),%eax
  8017ca:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017ce:	8d 43 10             	lea    0x10(%ebx),%eax
  8017d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d5:	8b 03                	mov    (%ebx),%eax
  8017d7:	89 04 24             	mov    %eax,(%esp)
  8017da:	e8 3e fb ff ff       	call   80131d <write>
		if (result > 0)
  8017df:	85 c0                	test   %eax,%eax
  8017e1:	7e 03                	jle    8017e6 <writebuf+0x2e>
			b->result += result;
  8017e3:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8017e6:	39 43 04             	cmp    %eax,0x4(%ebx)
  8017e9:	74 0e                	je     8017f9 <writebuf+0x41>
			b->error = (result < 0 ? result : 0);
  8017eb:	89 c2                	mov    %eax,%edx
  8017ed:	85 c0                	test   %eax,%eax
  8017ef:	7e 05                	jle    8017f6 <writebuf+0x3e>
  8017f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f6:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  8017f9:	83 c4 14             	add    $0x14,%esp
  8017fc:	5b                   	pop    %ebx
  8017fd:	5d                   	pop    %ebp
  8017fe:	c3                   	ret    

008017ff <putch>:

static void
putch(int ch, void *thunk)
{
  8017ff:	55                   	push   %ebp
  801800:	89 e5                	mov    %esp,%ebp
  801802:	53                   	push   %ebx
  801803:	83 ec 04             	sub    $0x4,%esp
  801806:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801809:	8b 43 04             	mov    0x4(%ebx),%eax
  80180c:	8b 55 08             	mov    0x8(%ebp),%edx
  80180f:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  801813:	40                   	inc    %eax
  801814:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  801817:	3d 00 01 00 00       	cmp    $0x100,%eax
  80181c:	75 0e                	jne    80182c <putch+0x2d>
		writebuf(b);
  80181e:	89 d8                	mov    %ebx,%eax
  801820:	e8 93 ff ff ff       	call   8017b8 <writebuf>
		b->idx = 0;
  801825:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  80182c:	83 c4 04             	add    $0x4,%esp
  80182f:	5b                   	pop    %ebx
  801830:	5d                   	pop    %ebp
  801831:	c3                   	ret    

00801832 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801832:	55                   	push   %ebp
  801833:	89 e5                	mov    %esp,%ebp
  801835:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  80183b:	8b 45 08             	mov    0x8(%ebp),%eax
  80183e:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801844:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  80184b:	00 00 00 
	b.result = 0;
  80184e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801855:	00 00 00 
	b.error = 1;
  801858:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  80185f:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801862:	8b 45 10             	mov    0x10(%ebp),%eax
  801865:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801869:	8b 45 0c             	mov    0xc(%ebp),%eax
  80186c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801870:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801876:	89 44 24 04          	mov    %eax,0x4(%esp)
  80187a:	c7 04 24 ff 17 80 00 	movl   $0x8017ff,(%esp)
  801881:	e8 fc eb ff ff       	call   800482 <vprintfmt>
	if (b.idx > 0)
  801886:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  80188d:	7e 0b                	jle    80189a <vfprintf+0x68>
		writebuf(&b);
  80188f:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801895:	e8 1e ff ff ff       	call   8017b8 <writebuf>

	return (b.result ? b.result : b.error);
  80189a:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8018a0:	85 c0                	test   %eax,%eax
  8018a2:	75 06                	jne    8018aa <vfprintf+0x78>
  8018a4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8018aa:	c9                   	leave  
  8018ab:	c3                   	ret    

008018ac <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8018ac:	55                   	push   %ebp
  8018ad:	89 e5                	mov    %esp,%ebp
  8018af:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8018b2:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8018b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c3:	89 04 24             	mov    %eax,(%esp)
  8018c6:	e8 67 ff ff ff       	call   801832 <vfprintf>
	va_end(ap);

	return cnt;
}
  8018cb:	c9                   	leave  
  8018cc:	c3                   	ret    

008018cd <printf>:

int
printf(const char *fmt, ...)
{
  8018cd:	55                   	push   %ebp
  8018ce:	89 e5                	mov    %esp,%ebp
  8018d0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8018d3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8018d6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018da:	8b 45 08             	mov    0x8(%ebp),%eax
  8018dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8018e8:	e8 45 ff ff ff       	call   801832 <vfprintf>
	va_end(ap);

	return cnt;
}
  8018ed:	c9                   	leave  
  8018ee:	c3                   	ret    
	...

008018f0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018f0:	55                   	push   %ebp
  8018f1:	89 e5                	mov    %esp,%ebp
  8018f3:	56                   	push   %esi
  8018f4:	53                   	push   %ebx
  8018f5:	83 ec 10             	sub    $0x10,%esp
  8018f8:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8018fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8018fe:	89 04 24             	mov    %eax,(%esp)
  801901:	e8 32 f6 ff ff       	call   800f38 <fd2data>
  801906:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801908:	c7 44 24 04 2b 26 80 	movl   $0x80262b,0x4(%esp)
  80190f:	00 
  801910:	89 34 24             	mov    %esi,(%esp)
  801913:	e8 b3 ef ff ff       	call   8008cb <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801918:	8b 43 04             	mov    0x4(%ebx),%eax
  80191b:	2b 03                	sub    (%ebx),%eax
  80191d:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801923:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80192a:	00 00 00 
	stat->st_dev = &devpipe;
  80192d:	c7 86 88 00 00 00 24 	movl   $0x803024,0x88(%esi)
  801934:	30 80 00 
	return 0;
}
  801937:	b8 00 00 00 00       	mov    $0x0,%eax
  80193c:	83 c4 10             	add    $0x10,%esp
  80193f:	5b                   	pop    %ebx
  801940:	5e                   	pop    %esi
  801941:	5d                   	pop    %ebp
  801942:	c3                   	ret    

00801943 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801943:	55                   	push   %ebp
  801944:	89 e5                	mov    %esp,%ebp
  801946:	53                   	push   %ebx
  801947:	83 ec 14             	sub    $0x14,%esp
  80194a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80194d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801951:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801958:	e8 07 f4 ff ff       	call   800d64 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80195d:	89 1c 24             	mov    %ebx,(%esp)
  801960:	e8 d3 f5 ff ff       	call   800f38 <fd2data>
  801965:	89 44 24 04          	mov    %eax,0x4(%esp)
  801969:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801970:	e8 ef f3 ff ff       	call   800d64 <sys_page_unmap>
}
  801975:	83 c4 14             	add    $0x14,%esp
  801978:	5b                   	pop    %ebx
  801979:	5d                   	pop    %ebp
  80197a:	c3                   	ret    

0080197b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80197b:	55                   	push   %ebp
  80197c:	89 e5                	mov    %esp,%ebp
  80197e:	57                   	push   %edi
  80197f:	56                   	push   %esi
  801980:	53                   	push   %ebx
  801981:	83 ec 2c             	sub    $0x2c,%esp
  801984:	89 c7                	mov    %eax,%edi
  801986:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801989:	a1 08 40 80 00       	mov    0x804008,%eax
  80198e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801991:	89 3c 24             	mov    %edi,(%esp)
  801994:	e8 8b 05 00 00       	call   801f24 <pageref>
  801999:	89 c6                	mov    %eax,%esi
  80199b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80199e:	89 04 24             	mov    %eax,(%esp)
  8019a1:	e8 7e 05 00 00       	call   801f24 <pageref>
  8019a6:	39 c6                	cmp    %eax,%esi
  8019a8:	0f 94 c0             	sete   %al
  8019ab:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8019ae:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8019b4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8019b7:	39 cb                	cmp    %ecx,%ebx
  8019b9:	75 08                	jne    8019c3 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8019bb:	83 c4 2c             	add    $0x2c,%esp
  8019be:	5b                   	pop    %ebx
  8019bf:	5e                   	pop    %esi
  8019c0:	5f                   	pop    %edi
  8019c1:	5d                   	pop    %ebp
  8019c2:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8019c3:	83 f8 01             	cmp    $0x1,%eax
  8019c6:	75 c1                	jne    801989 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8019c8:	8b 42 58             	mov    0x58(%edx),%eax
  8019cb:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  8019d2:	00 
  8019d3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019d7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019db:	c7 04 24 32 26 80 00 	movl   $0x802632,(%esp)
  8019e2:	e8 39 e9 ff ff       	call   800320 <cprintf>
  8019e7:	eb a0                	jmp    801989 <_pipeisclosed+0xe>

008019e9 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019e9:	55                   	push   %ebp
  8019ea:	89 e5                	mov    %esp,%ebp
  8019ec:	57                   	push   %edi
  8019ed:	56                   	push   %esi
  8019ee:	53                   	push   %ebx
  8019ef:	83 ec 1c             	sub    $0x1c,%esp
  8019f2:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8019f5:	89 34 24             	mov    %esi,(%esp)
  8019f8:	e8 3b f5 ff ff       	call   800f38 <fd2data>
  8019fd:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019ff:	bf 00 00 00 00       	mov    $0x0,%edi
  801a04:	eb 3c                	jmp    801a42 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a06:	89 da                	mov    %ebx,%edx
  801a08:	89 f0                	mov    %esi,%eax
  801a0a:	e8 6c ff ff ff       	call   80197b <_pipeisclosed>
  801a0f:	85 c0                	test   %eax,%eax
  801a11:	75 38                	jne    801a4b <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a13:	e8 86 f2 ff ff       	call   800c9e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a18:	8b 43 04             	mov    0x4(%ebx),%eax
  801a1b:	8b 13                	mov    (%ebx),%edx
  801a1d:	83 c2 20             	add    $0x20,%edx
  801a20:	39 d0                	cmp    %edx,%eax
  801a22:	73 e2                	jae    801a06 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a24:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a27:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801a2a:	89 c2                	mov    %eax,%edx
  801a2c:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801a32:	79 05                	jns    801a39 <devpipe_write+0x50>
  801a34:	4a                   	dec    %edx
  801a35:	83 ca e0             	or     $0xffffffe0,%edx
  801a38:	42                   	inc    %edx
  801a39:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a3d:	40                   	inc    %eax
  801a3e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a41:	47                   	inc    %edi
  801a42:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a45:	75 d1                	jne    801a18 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a47:	89 f8                	mov    %edi,%eax
  801a49:	eb 05                	jmp    801a50 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a4b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a50:	83 c4 1c             	add    $0x1c,%esp
  801a53:	5b                   	pop    %ebx
  801a54:	5e                   	pop    %esi
  801a55:	5f                   	pop    %edi
  801a56:	5d                   	pop    %ebp
  801a57:	c3                   	ret    

00801a58 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a58:	55                   	push   %ebp
  801a59:	89 e5                	mov    %esp,%ebp
  801a5b:	57                   	push   %edi
  801a5c:	56                   	push   %esi
  801a5d:	53                   	push   %ebx
  801a5e:	83 ec 1c             	sub    $0x1c,%esp
  801a61:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a64:	89 3c 24             	mov    %edi,(%esp)
  801a67:	e8 cc f4 ff ff       	call   800f38 <fd2data>
  801a6c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a6e:	be 00 00 00 00       	mov    $0x0,%esi
  801a73:	eb 3a                	jmp    801aaf <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a75:	85 f6                	test   %esi,%esi
  801a77:	74 04                	je     801a7d <devpipe_read+0x25>
				return i;
  801a79:	89 f0                	mov    %esi,%eax
  801a7b:	eb 40                	jmp    801abd <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a7d:	89 da                	mov    %ebx,%edx
  801a7f:	89 f8                	mov    %edi,%eax
  801a81:	e8 f5 fe ff ff       	call   80197b <_pipeisclosed>
  801a86:	85 c0                	test   %eax,%eax
  801a88:	75 2e                	jne    801ab8 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a8a:	e8 0f f2 ff ff       	call   800c9e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a8f:	8b 03                	mov    (%ebx),%eax
  801a91:	3b 43 04             	cmp    0x4(%ebx),%eax
  801a94:	74 df                	je     801a75 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a96:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801a9b:	79 05                	jns    801aa2 <devpipe_read+0x4a>
  801a9d:	48                   	dec    %eax
  801a9e:	83 c8 e0             	or     $0xffffffe0,%eax
  801aa1:	40                   	inc    %eax
  801aa2:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801aa6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801aa9:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801aac:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aae:	46                   	inc    %esi
  801aaf:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ab2:	75 db                	jne    801a8f <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ab4:	89 f0                	mov    %esi,%eax
  801ab6:	eb 05                	jmp    801abd <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ab8:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801abd:	83 c4 1c             	add    $0x1c,%esp
  801ac0:	5b                   	pop    %ebx
  801ac1:	5e                   	pop    %esi
  801ac2:	5f                   	pop    %edi
  801ac3:	5d                   	pop    %ebp
  801ac4:	c3                   	ret    

00801ac5 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ac5:	55                   	push   %ebp
  801ac6:	89 e5                	mov    %esp,%ebp
  801ac8:	57                   	push   %edi
  801ac9:	56                   	push   %esi
  801aca:	53                   	push   %ebx
  801acb:	83 ec 3c             	sub    $0x3c,%esp
  801ace:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ad1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801ad4:	89 04 24             	mov    %eax,(%esp)
  801ad7:	e8 77 f4 ff ff       	call   800f53 <fd_alloc>
  801adc:	89 c3                	mov    %eax,%ebx
  801ade:	85 c0                	test   %eax,%eax
  801ae0:	0f 88 45 01 00 00    	js     801c2b <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ae6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801aed:	00 
  801aee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801af1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801af5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801afc:	e8 bc f1 ff ff       	call   800cbd <sys_page_alloc>
  801b01:	89 c3                	mov    %eax,%ebx
  801b03:	85 c0                	test   %eax,%eax
  801b05:	0f 88 20 01 00 00    	js     801c2b <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b0b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801b0e:	89 04 24             	mov    %eax,(%esp)
  801b11:	e8 3d f4 ff ff       	call   800f53 <fd_alloc>
  801b16:	89 c3                	mov    %eax,%ebx
  801b18:	85 c0                	test   %eax,%eax
  801b1a:	0f 88 f8 00 00 00    	js     801c18 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b20:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801b27:	00 
  801b28:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b2b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b2f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b36:	e8 82 f1 ff ff       	call   800cbd <sys_page_alloc>
  801b3b:	89 c3                	mov    %eax,%ebx
  801b3d:	85 c0                	test   %eax,%eax
  801b3f:	0f 88 d3 00 00 00    	js     801c18 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b45:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b48:	89 04 24             	mov    %eax,(%esp)
  801b4b:	e8 e8 f3 ff ff       	call   800f38 <fd2data>
  801b50:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b52:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801b59:	00 
  801b5a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b5e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b65:	e8 53 f1 ff ff       	call   800cbd <sys_page_alloc>
  801b6a:	89 c3                	mov    %eax,%ebx
  801b6c:	85 c0                	test   %eax,%eax
  801b6e:	0f 88 91 00 00 00    	js     801c05 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b74:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b77:	89 04 24             	mov    %eax,(%esp)
  801b7a:	e8 b9 f3 ff ff       	call   800f38 <fd2data>
  801b7f:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801b86:	00 
  801b87:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b8b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b92:	00 
  801b93:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b97:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b9e:	e8 6e f1 ff ff       	call   800d11 <sys_page_map>
  801ba3:	89 c3                	mov    %eax,%ebx
  801ba5:	85 c0                	test   %eax,%eax
  801ba7:	78 4c                	js     801bf5 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ba9:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801baf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bb2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801bb4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bb7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801bbe:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801bc4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801bc7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801bc9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801bcc:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801bd3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bd6:	89 04 24             	mov    %eax,(%esp)
  801bd9:	e8 4a f3 ff ff       	call   800f28 <fd2num>
  801bde:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801be0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801be3:	89 04 24             	mov    %eax,(%esp)
  801be6:	e8 3d f3 ff ff       	call   800f28 <fd2num>
  801beb:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801bee:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bf3:	eb 36                	jmp    801c2b <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801bf5:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bf9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c00:	e8 5f f1 ff ff       	call   800d64 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801c05:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c08:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c0c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c13:	e8 4c f1 ff ff       	call   800d64 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801c18:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c1b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c1f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c26:	e8 39 f1 ff ff       	call   800d64 <sys_page_unmap>
    err:
	return r;
}
  801c2b:	89 d8                	mov    %ebx,%eax
  801c2d:	83 c4 3c             	add    $0x3c,%esp
  801c30:	5b                   	pop    %ebx
  801c31:	5e                   	pop    %esi
  801c32:	5f                   	pop    %edi
  801c33:	5d                   	pop    %ebp
  801c34:	c3                   	ret    

00801c35 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c35:	55                   	push   %ebp
  801c36:	89 e5                	mov    %esp,%ebp
  801c38:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c3b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c3e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c42:	8b 45 08             	mov    0x8(%ebp),%eax
  801c45:	89 04 24             	mov    %eax,(%esp)
  801c48:	e8 59 f3 ff ff       	call   800fa6 <fd_lookup>
  801c4d:	85 c0                	test   %eax,%eax
  801c4f:	78 15                	js     801c66 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c51:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c54:	89 04 24             	mov    %eax,(%esp)
  801c57:	e8 dc f2 ff ff       	call   800f38 <fd2data>
	return _pipeisclosed(fd, p);
  801c5c:	89 c2                	mov    %eax,%edx
  801c5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c61:	e8 15 fd ff ff       	call   80197b <_pipeisclosed>
}
  801c66:	c9                   	leave  
  801c67:	c3                   	ret    

00801c68 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c68:	55                   	push   %ebp
  801c69:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c6b:	b8 00 00 00 00       	mov    $0x0,%eax
  801c70:	5d                   	pop    %ebp
  801c71:	c3                   	ret    

00801c72 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c72:	55                   	push   %ebp
  801c73:	89 e5                	mov    %esp,%ebp
  801c75:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801c78:	c7 44 24 04 4a 26 80 	movl   $0x80264a,0x4(%esp)
  801c7f:	00 
  801c80:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c83:	89 04 24             	mov    %eax,(%esp)
  801c86:	e8 40 ec ff ff       	call   8008cb <strcpy>
	return 0;
}
  801c8b:	b8 00 00 00 00       	mov    $0x0,%eax
  801c90:	c9                   	leave  
  801c91:	c3                   	ret    

00801c92 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c92:	55                   	push   %ebp
  801c93:	89 e5                	mov    %esp,%ebp
  801c95:	57                   	push   %edi
  801c96:	56                   	push   %esi
  801c97:	53                   	push   %ebx
  801c98:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c9e:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ca3:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ca9:	eb 30                	jmp    801cdb <devcons_write+0x49>
		m = n - tot;
  801cab:	8b 75 10             	mov    0x10(%ebp),%esi
  801cae:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801cb0:	83 fe 7f             	cmp    $0x7f,%esi
  801cb3:	76 05                	jbe    801cba <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801cb5:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801cba:	89 74 24 08          	mov    %esi,0x8(%esp)
  801cbe:	03 45 0c             	add    0xc(%ebp),%eax
  801cc1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cc5:	89 3c 24             	mov    %edi,(%esp)
  801cc8:	e8 77 ed ff ff       	call   800a44 <memmove>
		sys_cputs(buf, m);
  801ccd:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cd1:	89 3c 24             	mov    %edi,(%esp)
  801cd4:	e8 17 ef ff ff       	call   800bf0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cd9:	01 f3                	add    %esi,%ebx
  801cdb:	89 d8                	mov    %ebx,%eax
  801cdd:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ce0:	72 c9                	jb     801cab <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ce2:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801ce8:	5b                   	pop    %ebx
  801ce9:	5e                   	pop    %esi
  801cea:	5f                   	pop    %edi
  801ceb:	5d                   	pop    %ebp
  801cec:	c3                   	ret    

00801ced <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ced:	55                   	push   %ebp
  801cee:	89 e5                	mov    %esp,%ebp
  801cf0:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801cf3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801cf7:	75 07                	jne    801d00 <devcons_read+0x13>
  801cf9:	eb 25                	jmp    801d20 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801cfb:	e8 9e ef ff ff       	call   800c9e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d00:	e8 09 ef ff ff       	call   800c0e <sys_cgetc>
  801d05:	85 c0                	test   %eax,%eax
  801d07:	74 f2                	je     801cfb <devcons_read+0xe>
  801d09:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801d0b:	85 c0                	test   %eax,%eax
  801d0d:	78 1d                	js     801d2c <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d0f:	83 f8 04             	cmp    $0x4,%eax
  801d12:	74 13                	je     801d27 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801d14:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d17:	88 10                	mov    %dl,(%eax)
	return 1;
  801d19:	b8 01 00 00 00       	mov    $0x1,%eax
  801d1e:	eb 0c                	jmp    801d2c <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801d20:	b8 00 00 00 00       	mov    $0x0,%eax
  801d25:	eb 05                	jmp    801d2c <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d27:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d2c:	c9                   	leave  
  801d2d:	c3                   	ret    

00801d2e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d2e:	55                   	push   %ebp
  801d2f:	89 e5                	mov    %esp,%ebp
  801d31:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801d34:	8b 45 08             	mov    0x8(%ebp),%eax
  801d37:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d3a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801d41:	00 
  801d42:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d45:	89 04 24             	mov    %eax,(%esp)
  801d48:	e8 a3 ee ff ff       	call   800bf0 <sys_cputs>
}
  801d4d:	c9                   	leave  
  801d4e:	c3                   	ret    

00801d4f <getchar>:

int
getchar(void)
{
  801d4f:	55                   	push   %ebp
  801d50:	89 e5                	mov    %esp,%ebp
  801d52:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d55:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801d5c:	00 
  801d5d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d60:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d64:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d6b:	e8 d2 f4 ff ff       	call   801242 <read>
	if (r < 0)
  801d70:	85 c0                	test   %eax,%eax
  801d72:	78 0f                	js     801d83 <getchar+0x34>
		return r;
	if (r < 1)
  801d74:	85 c0                	test   %eax,%eax
  801d76:	7e 06                	jle    801d7e <getchar+0x2f>
		return -E_EOF;
	return c;
  801d78:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d7c:	eb 05                	jmp    801d83 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d7e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d83:	c9                   	leave  
  801d84:	c3                   	ret    

00801d85 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d85:	55                   	push   %ebp
  801d86:	89 e5                	mov    %esp,%ebp
  801d88:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d8b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d92:	8b 45 08             	mov    0x8(%ebp),%eax
  801d95:	89 04 24             	mov    %eax,(%esp)
  801d98:	e8 09 f2 ff ff       	call   800fa6 <fd_lookup>
  801d9d:	85 c0                	test   %eax,%eax
  801d9f:	78 11                	js     801db2 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801da1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801da4:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801daa:	39 10                	cmp    %edx,(%eax)
  801dac:	0f 94 c0             	sete   %al
  801daf:	0f b6 c0             	movzbl %al,%eax
}
  801db2:	c9                   	leave  
  801db3:	c3                   	ret    

00801db4 <opencons>:

int
opencons(void)
{
  801db4:	55                   	push   %ebp
  801db5:	89 e5                	mov    %esp,%ebp
  801db7:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801dba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dbd:	89 04 24             	mov    %eax,(%esp)
  801dc0:	e8 8e f1 ff ff       	call   800f53 <fd_alloc>
  801dc5:	85 c0                	test   %eax,%eax
  801dc7:	78 3c                	js     801e05 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801dc9:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801dd0:	00 
  801dd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dd4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dd8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ddf:	e8 d9 ee ff ff       	call   800cbd <sys_page_alloc>
  801de4:	85 c0                	test   %eax,%eax
  801de6:	78 1d                	js     801e05 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801de8:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801dee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801df1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801df3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801df6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801dfd:	89 04 24             	mov    %eax,(%esp)
  801e00:	e8 23 f1 ff ff       	call   800f28 <fd2num>
}
  801e05:	c9                   	leave  
  801e06:	c3                   	ret    
	...

00801e08 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e08:	55                   	push   %ebp
  801e09:	89 e5                	mov    %esp,%ebp
  801e0b:	56                   	push   %esi
  801e0c:	53                   	push   %ebx
  801e0d:	83 ec 10             	sub    $0x10,%esp
  801e10:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801e13:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e16:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int r;
		
	r = sys_ipc_recv(pg?pg:(void*)UTOP);
  801e19:	85 c0                	test   %eax,%eax
  801e1b:	75 05                	jne    801e22 <ipc_recv+0x1a>
  801e1d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801e22:	89 04 24             	mov    %eax,(%esp)
  801e25:	e8 a9 f0 ff ff       	call   800ed3 <sys_ipc_recv>
	if (from_env_store != NULL)
  801e2a:	85 db                	test   %ebx,%ebx
  801e2c:	74 0b                	je     801e39 <ipc_recv+0x31>
		*from_env_store = thisenv->env_ipc_from; 
  801e2e:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801e34:	8b 52 74             	mov    0x74(%edx),%edx
  801e37:	89 13                	mov    %edx,(%ebx)
	if (perm_store != NULL)
  801e39:	85 f6                	test   %esi,%esi
  801e3b:	74 0b                	je     801e48 <ipc_recv+0x40>
		*perm_store = thisenv->env_ipc_perm;
  801e3d:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801e43:	8b 52 78             	mov    0x78(%edx),%edx
  801e46:	89 16                	mov    %edx,(%esi)
	
	if (r < 0){
  801e48:	85 c0                	test   %eax,%eax
  801e4a:	79 16                	jns    801e62 <ipc_recv+0x5a>
		if(from_env_store != NULL)
  801e4c:	85 db                	test   %ebx,%ebx
  801e4e:	74 06                	je     801e56 <ipc_recv+0x4e>
			*from_env_store = 0;
  801e50:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store != NULL)	
  801e56:	85 f6                	test   %esi,%esi
  801e58:	74 10                	je     801e6a <ipc_recv+0x62>
			*perm_store = 0;
  801e5a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801e60:	eb 08                	jmp    801e6a <ipc_recv+0x62>
		return r;
	}
	
	return thisenv->env_ipc_value;
  801e62:	a1 08 40 80 00       	mov    0x804008,%eax
  801e67:	8b 40 70             	mov    0x70(%eax),%eax
}
  801e6a:	83 c4 10             	add    $0x10,%esp
  801e6d:	5b                   	pop    %ebx
  801e6e:	5e                   	pop    %esi
  801e6f:	5d                   	pop    %ebp
  801e70:	c3                   	ret    

00801e71 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e71:	55                   	push   %ebp
  801e72:	89 e5                	mov    %esp,%ebp
  801e74:	57                   	push   %edi
  801e75:	56                   	push   %esi
  801e76:	53                   	push   %ebx
  801e77:	83 ec 1c             	sub    $0x1c,%esp
  801e7a:	8b 75 08             	mov    0x8(%ebp),%esi
  801e7d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801e80:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  801e83:	eb 2a                	jmp    801eaf <ipc_send+0x3e>
		if (r != -E_IPC_NOT_RECV)
  801e85:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e88:	74 20                	je     801eaa <ipc_send+0x39>
			panic("ipc_send: sys_ipc_try_send failed %e", r);
  801e8a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e8e:	c7 44 24 08 58 26 80 	movl   $0x802658,0x8(%esp)
  801e95:	00 
  801e96:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  801e9d:	00 
  801e9e:	c7 04 24 80 26 80 00 	movl   $0x802680,(%esp)
  801ea5:	e8 7e e3 ff ff       	call   800228 <_panic>
		sys_yield();
  801eaa:	e8 ef ed ff ff       	call   800c9e <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  801eaf:	85 db                	test   %ebx,%ebx
  801eb1:	75 07                	jne    801eba <ipc_send+0x49>
  801eb3:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801eb8:	eb 02                	jmp    801ebc <ipc_send+0x4b>
  801eba:	89 d8                	mov    %ebx,%eax
  801ebc:	8b 55 14             	mov    0x14(%ebp),%edx
  801ebf:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801ec3:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ec7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801ecb:	89 34 24             	mov    %esi,(%esp)
  801ece:	e8 dd ef ff ff       	call   800eb0 <sys_ipc_try_send>
  801ed3:	85 c0                	test   %eax,%eax
  801ed5:	78 ae                	js     801e85 <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: sys_ipc_try_send failed %e", r);
		sys_yield();
	}
}
  801ed7:	83 c4 1c             	add    $0x1c,%esp
  801eda:	5b                   	pop    %ebx
  801edb:	5e                   	pop    %esi
  801edc:	5f                   	pop    %edi
  801edd:	5d                   	pop    %ebp
  801ede:	c3                   	ret    

00801edf <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801edf:	55                   	push   %ebp
  801ee0:	89 e5                	mov    %esp,%ebp
  801ee2:	53                   	push   %ebx
  801ee3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801ee6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801eeb:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801ef2:	89 c2                	mov    %eax,%edx
  801ef4:	c1 e2 07             	shl    $0x7,%edx
  801ef7:	29 ca                	sub    %ecx,%edx
  801ef9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801eff:	8b 52 50             	mov    0x50(%edx),%edx
  801f02:	39 da                	cmp    %ebx,%edx
  801f04:	75 0f                	jne    801f15 <ipc_find_env+0x36>
			return envs[i].env_id;
  801f06:	c1 e0 07             	shl    $0x7,%eax
  801f09:	29 c8                	sub    %ecx,%eax
  801f0b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801f10:	8b 40 40             	mov    0x40(%eax),%eax
  801f13:	eb 0c                	jmp    801f21 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f15:	40                   	inc    %eax
  801f16:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f1b:	75 ce                	jne    801eeb <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f1d:	66 b8 00 00          	mov    $0x0,%ax
}
  801f21:	5b                   	pop    %ebx
  801f22:	5d                   	pop    %ebp
  801f23:	c3                   	ret    

00801f24 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f24:	55                   	push   %ebp
  801f25:	89 e5                	mov    %esp,%ebp
  801f27:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f2a:	89 c2                	mov    %eax,%edx
  801f2c:	c1 ea 16             	shr    $0x16,%edx
  801f2f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801f36:	f6 c2 01             	test   $0x1,%dl
  801f39:	74 1e                	je     801f59 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f3b:	c1 e8 0c             	shr    $0xc,%eax
  801f3e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801f45:	a8 01                	test   $0x1,%al
  801f47:	74 17                	je     801f60 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f49:	c1 e8 0c             	shr    $0xc,%eax
  801f4c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801f53:	ef 
  801f54:	0f b7 c0             	movzwl %ax,%eax
  801f57:	eb 0c                	jmp    801f65 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801f59:	b8 00 00 00 00       	mov    $0x0,%eax
  801f5e:	eb 05                	jmp    801f65 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801f60:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801f65:	5d                   	pop    %ebp
  801f66:	c3                   	ret    
	...

00801f68 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801f68:	55                   	push   %ebp
  801f69:	57                   	push   %edi
  801f6a:	56                   	push   %esi
  801f6b:	83 ec 10             	sub    $0x10,%esp
  801f6e:	8b 74 24 20          	mov    0x20(%esp),%esi
  801f72:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801f76:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f7a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  801f7e:	89 cd                	mov    %ecx,%ebp
  801f80:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801f84:	85 c0                	test   %eax,%eax
  801f86:	75 2c                	jne    801fb4 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801f88:	39 f9                	cmp    %edi,%ecx
  801f8a:	77 68                	ja     801ff4 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801f8c:	85 c9                	test   %ecx,%ecx
  801f8e:	75 0b                	jne    801f9b <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801f90:	b8 01 00 00 00       	mov    $0x1,%eax
  801f95:	31 d2                	xor    %edx,%edx
  801f97:	f7 f1                	div    %ecx
  801f99:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801f9b:	31 d2                	xor    %edx,%edx
  801f9d:	89 f8                	mov    %edi,%eax
  801f9f:	f7 f1                	div    %ecx
  801fa1:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801fa3:	89 f0                	mov    %esi,%eax
  801fa5:	f7 f1                	div    %ecx
  801fa7:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801fa9:	89 f0                	mov    %esi,%eax
  801fab:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801fad:	83 c4 10             	add    $0x10,%esp
  801fb0:	5e                   	pop    %esi
  801fb1:	5f                   	pop    %edi
  801fb2:	5d                   	pop    %ebp
  801fb3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801fb4:	39 f8                	cmp    %edi,%eax
  801fb6:	77 2c                	ja     801fe4 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801fb8:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  801fbb:	83 f6 1f             	xor    $0x1f,%esi
  801fbe:	75 4c                	jne    80200c <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801fc0:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801fc2:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801fc7:	72 0a                	jb     801fd3 <__udivdi3+0x6b>
  801fc9:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801fcd:	0f 87 ad 00 00 00    	ja     802080 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801fd3:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801fd8:	89 f0                	mov    %esi,%eax
  801fda:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801fdc:	83 c4 10             	add    $0x10,%esp
  801fdf:	5e                   	pop    %esi
  801fe0:	5f                   	pop    %edi
  801fe1:	5d                   	pop    %ebp
  801fe2:	c3                   	ret    
  801fe3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801fe4:	31 ff                	xor    %edi,%edi
  801fe6:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801fe8:	89 f0                	mov    %esi,%eax
  801fea:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801fec:	83 c4 10             	add    $0x10,%esp
  801fef:	5e                   	pop    %esi
  801ff0:	5f                   	pop    %edi
  801ff1:	5d                   	pop    %ebp
  801ff2:	c3                   	ret    
  801ff3:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801ff4:	89 fa                	mov    %edi,%edx
  801ff6:	89 f0                	mov    %esi,%eax
  801ff8:	f7 f1                	div    %ecx
  801ffa:	89 c6                	mov    %eax,%esi
  801ffc:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801ffe:	89 f0                	mov    %esi,%eax
  802000:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802002:	83 c4 10             	add    $0x10,%esp
  802005:	5e                   	pop    %esi
  802006:	5f                   	pop    %edi
  802007:	5d                   	pop    %ebp
  802008:	c3                   	ret    
  802009:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80200c:	89 f1                	mov    %esi,%ecx
  80200e:	d3 e0                	shl    %cl,%eax
  802010:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802014:	b8 20 00 00 00       	mov    $0x20,%eax
  802019:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80201b:	89 ea                	mov    %ebp,%edx
  80201d:	88 c1                	mov    %al,%cl
  80201f:	d3 ea                	shr    %cl,%edx
  802021:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802025:	09 ca                	or     %ecx,%edx
  802027:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  80202b:	89 f1                	mov    %esi,%ecx
  80202d:	d3 e5                	shl    %cl,%ebp
  80202f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  802033:	89 fd                	mov    %edi,%ebp
  802035:	88 c1                	mov    %al,%cl
  802037:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802039:	89 fa                	mov    %edi,%edx
  80203b:	89 f1                	mov    %esi,%ecx
  80203d:	d3 e2                	shl    %cl,%edx
  80203f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802043:	88 c1                	mov    %al,%cl
  802045:	d3 ef                	shr    %cl,%edi
  802047:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802049:	89 f8                	mov    %edi,%eax
  80204b:	89 ea                	mov    %ebp,%edx
  80204d:	f7 74 24 08          	divl   0x8(%esp)
  802051:	89 d1                	mov    %edx,%ecx
  802053:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802055:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802059:	39 d1                	cmp    %edx,%ecx
  80205b:	72 17                	jb     802074 <__udivdi3+0x10c>
  80205d:	74 09                	je     802068 <__udivdi3+0x100>
  80205f:	89 fe                	mov    %edi,%esi
  802061:	31 ff                	xor    %edi,%edi
  802063:	e9 41 ff ff ff       	jmp    801fa9 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802068:	8b 54 24 04          	mov    0x4(%esp),%edx
  80206c:	89 f1                	mov    %esi,%ecx
  80206e:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802070:	39 c2                	cmp    %eax,%edx
  802072:	73 eb                	jae    80205f <__udivdi3+0xf7>
		{
		  q0--;
  802074:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802077:	31 ff                	xor    %edi,%edi
  802079:	e9 2b ff ff ff       	jmp    801fa9 <__udivdi3+0x41>
  80207e:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802080:	31 f6                	xor    %esi,%esi
  802082:	e9 22 ff ff ff       	jmp    801fa9 <__udivdi3+0x41>
	...

00802088 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802088:	55                   	push   %ebp
  802089:	57                   	push   %edi
  80208a:	56                   	push   %esi
  80208b:	83 ec 20             	sub    $0x20,%esp
  80208e:	8b 44 24 30          	mov    0x30(%esp),%eax
  802092:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802096:	89 44 24 14          	mov    %eax,0x14(%esp)
  80209a:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  80209e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020a2:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8020a6:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  8020a8:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8020aa:	85 ed                	test   %ebp,%ebp
  8020ac:	75 16                	jne    8020c4 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  8020ae:	39 f1                	cmp    %esi,%ecx
  8020b0:	0f 86 a6 00 00 00    	jbe    80215c <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8020b6:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8020b8:	89 d0                	mov    %edx,%eax
  8020ba:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8020bc:	83 c4 20             	add    $0x20,%esp
  8020bf:	5e                   	pop    %esi
  8020c0:	5f                   	pop    %edi
  8020c1:	5d                   	pop    %ebp
  8020c2:	c3                   	ret    
  8020c3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8020c4:	39 f5                	cmp    %esi,%ebp
  8020c6:	0f 87 ac 00 00 00    	ja     802178 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8020cc:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  8020cf:	83 f0 1f             	xor    $0x1f,%eax
  8020d2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8020d6:	0f 84 a8 00 00 00    	je     802184 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8020dc:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8020e0:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8020e2:	bf 20 00 00 00       	mov    $0x20,%edi
  8020e7:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8020eb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8020ef:	89 f9                	mov    %edi,%ecx
  8020f1:	d3 e8                	shr    %cl,%eax
  8020f3:	09 e8                	or     %ebp,%eax
  8020f5:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  8020f9:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8020fd:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802101:	d3 e0                	shl    %cl,%eax
  802103:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802107:	89 f2                	mov    %esi,%edx
  802109:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80210b:	8b 44 24 14          	mov    0x14(%esp),%eax
  80210f:	d3 e0                	shl    %cl,%eax
  802111:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802115:	8b 44 24 14          	mov    0x14(%esp),%eax
  802119:	89 f9                	mov    %edi,%ecx
  80211b:	d3 e8                	shr    %cl,%eax
  80211d:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80211f:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802121:	89 f2                	mov    %esi,%edx
  802123:	f7 74 24 18          	divl   0x18(%esp)
  802127:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802129:	f7 64 24 0c          	mull   0xc(%esp)
  80212d:	89 c5                	mov    %eax,%ebp
  80212f:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802131:	39 d6                	cmp    %edx,%esi
  802133:	72 67                	jb     80219c <__umoddi3+0x114>
  802135:	74 75                	je     8021ac <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802137:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80213b:	29 e8                	sub    %ebp,%eax
  80213d:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80213f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802143:	d3 e8                	shr    %cl,%eax
  802145:	89 f2                	mov    %esi,%edx
  802147:	89 f9                	mov    %edi,%ecx
  802149:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80214b:	09 d0                	or     %edx,%eax
  80214d:	89 f2                	mov    %esi,%edx
  80214f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802153:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802155:	83 c4 20             	add    $0x20,%esp
  802158:	5e                   	pop    %esi
  802159:	5f                   	pop    %edi
  80215a:	5d                   	pop    %ebp
  80215b:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80215c:	85 c9                	test   %ecx,%ecx
  80215e:	75 0b                	jne    80216b <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802160:	b8 01 00 00 00       	mov    $0x1,%eax
  802165:	31 d2                	xor    %edx,%edx
  802167:	f7 f1                	div    %ecx
  802169:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80216b:	89 f0                	mov    %esi,%eax
  80216d:	31 d2                	xor    %edx,%edx
  80216f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802171:	89 f8                	mov    %edi,%eax
  802173:	e9 3e ff ff ff       	jmp    8020b6 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802178:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80217a:	83 c4 20             	add    $0x20,%esp
  80217d:	5e                   	pop    %esi
  80217e:	5f                   	pop    %edi
  80217f:	5d                   	pop    %ebp
  802180:	c3                   	ret    
  802181:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802184:	39 f5                	cmp    %esi,%ebp
  802186:	72 04                	jb     80218c <__umoddi3+0x104>
  802188:	39 f9                	cmp    %edi,%ecx
  80218a:	77 06                	ja     802192 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80218c:	89 f2                	mov    %esi,%edx
  80218e:	29 cf                	sub    %ecx,%edi
  802190:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802192:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802194:	83 c4 20             	add    $0x20,%esp
  802197:	5e                   	pop    %esi
  802198:	5f                   	pop    %edi
  802199:	5d                   	pop    %ebp
  80219a:	c3                   	ret    
  80219b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80219c:	89 d1                	mov    %edx,%ecx
  80219e:	89 c5                	mov    %eax,%ebp
  8021a0:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8021a4:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8021a8:	eb 8d                	jmp    802137 <__umoddi3+0xaf>
  8021aa:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8021ac:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8021b0:	72 ea                	jb     80219c <__umoddi3+0x114>
  8021b2:	89 f1                	mov    %esi,%ecx
  8021b4:	eb 81                	jmp    802137 <__umoddi3+0xaf>
