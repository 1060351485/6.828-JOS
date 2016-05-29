
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
  800060:	c7 04 24 20 27 80 00 	movl   $0x802720,(%esp)
  800067:	e8 d5 18 00 00       	call   801941 <printf>
			bol = 0;
  80006c:	c7 05 00 30 80 00 00 	movl   $0x0,0x803000
  800073:	00 00 00 
		}
		if ((r = write(1, &c, 1)) != 1)
  800076:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  80007d:	00 
  80007e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800082:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800089:	e8 03 13 00 00       	call   801391 <write>
  80008e:	83 f8 01             	cmp    $0x1,%eax
  800091:	74 24                	je     8000b7 <num+0x83>
			panic("write error copying %s: %e", s, r);
  800093:	89 44 24 10          	mov    %eax,0x10(%esp)
  800097:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80009b:	c7 44 24 08 25 27 80 	movl   $0x802725,0x8(%esp)
  8000a2:	00 
  8000a3:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
  8000aa:	00 
  8000ab:	c7 04 24 40 27 80 00 	movl   $0x802740,(%esp)
  8000b2:	e8 65 01 00 00       	call   80021c <_panic>
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
  8000d6:	e8 db 11 00 00       	call   8012b6 <read>
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
  8000ef:	c7 44 24 08 4b 27 80 	movl   $0x80274b,0x8(%esp)
  8000f6:	00 
  8000f7:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%esp)
  8000fe:	00 
  8000ff:	c7 04 24 40 27 80 00 	movl   $0x802740,(%esp)
  800106:	e8 11 01 00 00       	call   80021c <_panic>
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
  80011c:	c7 05 04 30 80 00 60 	movl   $0x802760,0x803004
  800123:	27 80 00 
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
  800139:	c7 44 24 04 64 27 80 	movl   $0x802764,0x4(%esp)
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
  80015f:	e8 28 16 00 00       	call   80178c <open>
  800164:	89 c6                	mov    %eax,%esi
			if (f < 0)
  800166:	85 c0                	test   %eax,%eax
  800168:	79 29                	jns    800193 <umain+0x80>
				panic("can't open %s: %e", argv[i], f);
  80016a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80016e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800171:	8b 02                	mov    (%edx),%eax
  800173:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800177:	c7 44 24 08 6c 27 80 	movl   $0x80276c,0x8(%esp)
  80017e:	00 
  80017f:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  800186:	00 
  800187:	c7 04 24 40 27 80 00 	movl   $0x802740,(%esp)
  80018e:	e8 89 00 00 00       	call   80021c <_panic>
			else {
				num(f, argv[i]);
  800193:	8b 03                	mov    (%ebx),%eax
  800195:	89 44 24 04          	mov    %eax,0x4(%esp)
  800199:	89 34 24             	mov    %esi,(%esp)
  80019c:	e8 93 fe ff ff       	call   800034 <num>
				close(f);
  8001a1:	89 34 24             	mov    %esi,(%esp)
  8001a4:	e8 a9 0f 00 00       	call   801152 <close>

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
  8001b2:	e8 51 00 00 00       	call   800208 <exit>
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
  8001ce:	e8 a0 0a 00 00       	call   800c73 <sys_getenvid>
  8001d3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001d8:	c1 e0 07             	shl    $0x7,%eax
  8001db:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001e0:	a3 0c 40 80 00       	mov    %eax,0x80400c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001e5:	85 f6                	test   %esi,%esi
  8001e7:	7e 07                	jle    8001f0 <libmain+0x30>
		binaryname = argv[0];
  8001e9:	8b 03                	mov    (%ebx),%eax
  8001eb:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8001f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001f4:	89 34 24             	mov    %esi,(%esp)
  8001f7:	e8 17 ff ff ff       	call   800113 <umain>

	// exit gracefully
	exit();
  8001fc:	e8 07 00 00 00       	call   800208 <exit>
}
  800201:	83 c4 10             	add    $0x10,%esp
  800204:	5b                   	pop    %ebx
  800205:	5e                   	pop    %esi
  800206:	5d                   	pop    %ebp
  800207:	c3                   	ret    

00800208 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800208:	55                   	push   %ebp
  800209:	89 e5                	mov    %esp,%ebp
  80020b:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  80020e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800215:	e8 07 0a 00 00       	call   800c21 <sys_env_destroy>
}
  80021a:	c9                   	leave  
  80021b:	c3                   	ret    

0080021c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	56                   	push   %esi
  800220:	53                   	push   %ebx
  800221:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800224:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800227:	8b 1d 04 30 80 00    	mov    0x803004,%ebx
  80022d:	e8 41 0a 00 00       	call   800c73 <sys_getenvid>
  800232:	8b 55 0c             	mov    0xc(%ebp),%edx
  800235:	89 54 24 10          	mov    %edx,0x10(%esp)
  800239:	8b 55 08             	mov    0x8(%ebp),%edx
  80023c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800240:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800244:	89 44 24 04          	mov    %eax,0x4(%esp)
  800248:	c7 04 24 88 27 80 00 	movl   $0x802788,(%esp)
  80024f:	e8 c0 00 00 00       	call   800314 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800254:	89 74 24 04          	mov    %esi,0x4(%esp)
  800258:	8b 45 10             	mov    0x10(%ebp),%eax
  80025b:	89 04 24             	mov    %eax,(%esp)
  80025e:	e8 50 00 00 00       	call   8002b3 <vcprintf>
	cprintf("\n");
  800263:	c7 04 24 e8 2b 80 00 	movl   $0x802be8,(%esp)
  80026a:	e8 a5 00 00 00       	call   800314 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80026f:	cc                   	int3   
  800270:	eb fd                	jmp    80026f <_panic+0x53>
	...

00800274 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	53                   	push   %ebx
  800278:	83 ec 14             	sub    $0x14,%esp
  80027b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80027e:	8b 03                	mov    (%ebx),%eax
  800280:	8b 55 08             	mov    0x8(%ebp),%edx
  800283:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800287:	40                   	inc    %eax
  800288:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80028a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80028f:	75 19                	jne    8002aa <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800291:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800298:	00 
  800299:	8d 43 08             	lea    0x8(%ebx),%eax
  80029c:	89 04 24             	mov    %eax,(%esp)
  80029f:	e8 40 09 00 00       	call   800be4 <sys_cputs>
		b->idx = 0;
  8002a4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8002aa:	ff 43 04             	incl   0x4(%ebx)
}
  8002ad:	83 c4 14             	add    $0x14,%esp
  8002b0:	5b                   	pop    %ebx
  8002b1:	5d                   	pop    %ebp
  8002b2:	c3                   	ret    

008002b3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002b3:	55                   	push   %ebp
  8002b4:	89 e5                	mov    %esp,%ebp
  8002b6:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8002bc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002c3:	00 00 00 
	b.cnt = 0;
  8002c6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002cd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002da:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002de:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e8:	c7 04 24 74 02 80 00 	movl   $0x800274,(%esp)
  8002ef:	e8 82 01 00 00       	call   800476 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002f4:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002fe:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800304:	89 04 24             	mov    %eax,(%esp)
  800307:	e8 d8 08 00 00       	call   800be4 <sys_cputs>

	return b.cnt;
}
  80030c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800312:	c9                   	leave  
  800313:	c3                   	ret    

00800314 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800314:	55                   	push   %ebp
  800315:	89 e5                	mov    %esp,%ebp
  800317:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80031a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80031d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800321:	8b 45 08             	mov    0x8(%ebp),%eax
  800324:	89 04 24             	mov    %eax,(%esp)
  800327:	e8 87 ff ff ff       	call   8002b3 <vcprintf>
	va_end(ap);

	return cnt;
}
  80032c:	c9                   	leave  
  80032d:	c3                   	ret    
	...

00800330 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800330:	55                   	push   %ebp
  800331:	89 e5                	mov    %esp,%ebp
  800333:	57                   	push   %edi
  800334:	56                   	push   %esi
  800335:	53                   	push   %ebx
  800336:	83 ec 3c             	sub    $0x3c,%esp
  800339:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80033c:	89 d7                	mov    %edx,%edi
  80033e:	8b 45 08             	mov    0x8(%ebp),%eax
  800341:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800344:	8b 45 0c             	mov    0xc(%ebp),%eax
  800347:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80034a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80034d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800350:	85 c0                	test   %eax,%eax
  800352:	75 08                	jne    80035c <printnum+0x2c>
  800354:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800357:	39 45 10             	cmp    %eax,0x10(%ebp)
  80035a:	77 57                	ja     8003b3 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80035c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800360:	4b                   	dec    %ebx
  800361:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800365:	8b 45 10             	mov    0x10(%ebp),%eax
  800368:	89 44 24 08          	mov    %eax,0x8(%esp)
  80036c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800370:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800374:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80037b:	00 
  80037c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80037f:	89 04 24             	mov    %eax,(%esp)
  800382:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800385:	89 44 24 04          	mov    %eax,0x4(%esp)
  800389:	e8 3e 21 00 00       	call   8024cc <__udivdi3>
  80038e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800392:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800396:	89 04 24             	mov    %eax,(%esp)
  800399:	89 54 24 04          	mov    %edx,0x4(%esp)
  80039d:	89 fa                	mov    %edi,%edx
  80039f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003a2:	e8 89 ff ff ff       	call   800330 <printnum>
  8003a7:	eb 0f                	jmp    8003b8 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003a9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003ad:	89 34 24             	mov    %esi,(%esp)
  8003b0:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003b3:	4b                   	dec    %ebx
  8003b4:	85 db                	test   %ebx,%ebx
  8003b6:	7f f1                	jg     8003a9 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003b8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003bc:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8003c0:	8b 45 10             	mov    0x10(%ebp),%eax
  8003c3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003c7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003ce:	00 
  8003cf:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003d2:	89 04 24             	mov    %eax,(%esp)
  8003d5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003dc:	e8 0b 22 00 00       	call   8025ec <__umoddi3>
  8003e1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003e5:	0f be 80 ab 27 80 00 	movsbl 0x8027ab(%eax),%eax
  8003ec:	89 04 24             	mov    %eax,(%esp)
  8003ef:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8003f2:	83 c4 3c             	add    $0x3c,%esp
  8003f5:	5b                   	pop    %ebx
  8003f6:	5e                   	pop    %esi
  8003f7:	5f                   	pop    %edi
  8003f8:	5d                   	pop    %ebp
  8003f9:	c3                   	ret    

008003fa <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003fa:	55                   	push   %ebp
  8003fb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003fd:	83 fa 01             	cmp    $0x1,%edx
  800400:	7e 0e                	jle    800410 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800402:	8b 10                	mov    (%eax),%edx
  800404:	8d 4a 08             	lea    0x8(%edx),%ecx
  800407:	89 08                	mov    %ecx,(%eax)
  800409:	8b 02                	mov    (%edx),%eax
  80040b:	8b 52 04             	mov    0x4(%edx),%edx
  80040e:	eb 22                	jmp    800432 <getuint+0x38>
	else if (lflag)
  800410:	85 d2                	test   %edx,%edx
  800412:	74 10                	je     800424 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800414:	8b 10                	mov    (%eax),%edx
  800416:	8d 4a 04             	lea    0x4(%edx),%ecx
  800419:	89 08                	mov    %ecx,(%eax)
  80041b:	8b 02                	mov    (%edx),%eax
  80041d:	ba 00 00 00 00       	mov    $0x0,%edx
  800422:	eb 0e                	jmp    800432 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800424:	8b 10                	mov    (%eax),%edx
  800426:	8d 4a 04             	lea    0x4(%edx),%ecx
  800429:	89 08                	mov    %ecx,(%eax)
  80042b:	8b 02                	mov    (%edx),%eax
  80042d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800432:	5d                   	pop    %ebp
  800433:	c3                   	ret    

00800434 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800434:	55                   	push   %ebp
  800435:	89 e5                	mov    %esp,%ebp
  800437:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80043a:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80043d:	8b 10                	mov    (%eax),%edx
  80043f:	3b 50 04             	cmp    0x4(%eax),%edx
  800442:	73 08                	jae    80044c <sprintputch+0x18>
		*b->buf++ = ch;
  800444:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800447:	88 0a                	mov    %cl,(%edx)
  800449:	42                   	inc    %edx
  80044a:	89 10                	mov    %edx,(%eax)
}
  80044c:	5d                   	pop    %ebp
  80044d:	c3                   	ret    

0080044e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80044e:	55                   	push   %ebp
  80044f:	89 e5                	mov    %esp,%ebp
  800451:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800454:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800457:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80045b:	8b 45 10             	mov    0x10(%ebp),%eax
  80045e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800462:	8b 45 0c             	mov    0xc(%ebp),%eax
  800465:	89 44 24 04          	mov    %eax,0x4(%esp)
  800469:	8b 45 08             	mov    0x8(%ebp),%eax
  80046c:	89 04 24             	mov    %eax,(%esp)
  80046f:	e8 02 00 00 00       	call   800476 <vprintfmt>
	va_end(ap);
}
  800474:	c9                   	leave  
  800475:	c3                   	ret    

00800476 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800476:	55                   	push   %ebp
  800477:	89 e5                	mov    %esp,%ebp
  800479:	57                   	push   %edi
  80047a:	56                   	push   %esi
  80047b:	53                   	push   %ebx
  80047c:	83 ec 4c             	sub    $0x4c,%esp
  80047f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800482:	8b 75 10             	mov    0x10(%ebp),%esi
  800485:	eb 12                	jmp    800499 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800487:	85 c0                	test   %eax,%eax
  800489:	0f 84 6b 03 00 00    	je     8007fa <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80048f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800493:	89 04 24             	mov    %eax,(%esp)
  800496:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800499:	0f b6 06             	movzbl (%esi),%eax
  80049c:	46                   	inc    %esi
  80049d:	83 f8 25             	cmp    $0x25,%eax
  8004a0:	75 e5                	jne    800487 <vprintfmt+0x11>
  8004a2:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8004a6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8004ad:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8004b2:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8004b9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004be:	eb 26                	jmp    8004e6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c0:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004c3:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8004c7:	eb 1d                	jmp    8004e6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c9:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004cc:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8004d0:	eb 14                	jmp    8004e6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8004d5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004dc:	eb 08                	jmp    8004e6 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004de:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8004e1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e6:	0f b6 06             	movzbl (%esi),%eax
  8004e9:	8d 56 01             	lea    0x1(%esi),%edx
  8004ec:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004ef:	8a 16                	mov    (%esi),%dl
  8004f1:	83 ea 23             	sub    $0x23,%edx
  8004f4:	80 fa 55             	cmp    $0x55,%dl
  8004f7:	0f 87 e1 02 00 00    	ja     8007de <vprintfmt+0x368>
  8004fd:	0f b6 d2             	movzbl %dl,%edx
  800500:	ff 24 95 e0 28 80 00 	jmp    *0x8028e0(,%edx,4)
  800507:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80050a:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80050f:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800512:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800516:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800519:	8d 50 d0             	lea    -0x30(%eax),%edx
  80051c:	83 fa 09             	cmp    $0x9,%edx
  80051f:	77 2a                	ja     80054b <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800521:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800522:	eb eb                	jmp    80050f <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800524:	8b 45 14             	mov    0x14(%ebp),%eax
  800527:	8d 50 04             	lea    0x4(%eax),%edx
  80052a:	89 55 14             	mov    %edx,0x14(%ebp)
  80052d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800532:	eb 17                	jmp    80054b <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800534:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800538:	78 98                	js     8004d2 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80053d:	eb a7                	jmp    8004e6 <vprintfmt+0x70>
  80053f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800542:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800549:	eb 9b                	jmp    8004e6 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80054b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80054f:	79 95                	jns    8004e6 <vprintfmt+0x70>
  800551:	eb 8b                	jmp    8004de <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800553:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800554:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800557:	eb 8d                	jmp    8004e6 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800559:	8b 45 14             	mov    0x14(%ebp),%eax
  80055c:	8d 50 04             	lea    0x4(%eax),%edx
  80055f:	89 55 14             	mov    %edx,0x14(%ebp)
  800562:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800566:	8b 00                	mov    (%eax),%eax
  800568:	89 04 24             	mov    %eax,(%esp)
  80056b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800571:	e9 23 ff ff ff       	jmp    800499 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800576:	8b 45 14             	mov    0x14(%ebp),%eax
  800579:	8d 50 04             	lea    0x4(%eax),%edx
  80057c:	89 55 14             	mov    %edx,0x14(%ebp)
  80057f:	8b 00                	mov    (%eax),%eax
  800581:	85 c0                	test   %eax,%eax
  800583:	79 02                	jns    800587 <vprintfmt+0x111>
  800585:	f7 d8                	neg    %eax
  800587:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800589:	83 f8 11             	cmp    $0x11,%eax
  80058c:	7f 0b                	jg     800599 <vprintfmt+0x123>
  80058e:	8b 04 85 40 2a 80 00 	mov    0x802a40(,%eax,4),%eax
  800595:	85 c0                	test   %eax,%eax
  800597:	75 23                	jne    8005bc <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800599:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80059d:	c7 44 24 08 c3 27 80 	movl   $0x8027c3,0x8(%esp)
  8005a4:	00 
  8005a5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ac:	89 04 24             	mov    %eax,(%esp)
  8005af:	e8 9a fe ff ff       	call   80044e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005b7:	e9 dd fe ff ff       	jmp    800499 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8005bc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005c0:	c7 44 24 08 7d 2b 80 	movl   $0x802b7d,0x8(%esp)
  8005c7:	00 
  8005c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8005cf:	89 14 24             	mov    %edx,(%esp)
  8005d2:	e8 77 fe ff ff       	call   80044e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005da:	e9 ba fe ff ff       	jmp    800499 <vprintfmt+0x23>
  8005df:	89 f9                	mov    %edi,%ecx
  8005e1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005e4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ea:	8d 50 04             	lea    0x4(%eax),%edx
  8005ed:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f0:	8b 30                	mov    (%eax),%esi
  8005f2:	85 f6                	test   %esi,%esi
  8005f4:	75 05                	jne    8005fb <vprintfmt+0x185>
				p = "(null)";
  8005f6:	be bc 27 80 00       	mov    $0x8027bc,%esi
			if (width > 0 && padc != '-')
  8005fb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005ff:	0f 8e 84 00 00 00    	jle    800689 <vprintfmt+0x213>
  800605:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800609:	74 7e                	je     800689 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80060b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80060f:	89 34 24             	mov    %esi,(%esp)
  800612:	e8 8b 02 00 00       	call   8008a2 <strnlen>
  800617:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80061a:	29 c2                	sub    %eax,%edx
  80061c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80061f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800623:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800626:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800629:	89 de                	mov    %ebx,%esi
  80062b:	89 d3                	mov    %edx,%ebx
  80062d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80062f:	eb 0b                	jmp    80063c <vprintfmt+0x1c6>
					putch(padc, putdat);
  800631:	89 74 24 04          	mov    %esi,0x4(%esp)
  800635:	89 3c 24             	mov    %edi,(%esp)
  800638:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80063b:	4b                   	dec    %ebx
  80063c:	85 db                	test   %ebx,%ebx
  80063e:	7f f1                	jg     800631 <vprintfmt+0x1bb>
  800640:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800643:	89 f3                	mov    %esi,%ebx
  800645:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800648:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80064b:	85 c0                	test   %eax,%eax
  80064d:	79 05                	jns    800654 <vprintfmt+0x1de>
  80064f:	b8 00 00 00 00       	mov    $0x0,%eax
  800654:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800657:	29 c2                	sub    %eax,%edx
  800659:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80065c:	eb 2b                	jmp    800689 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80065e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800662:	74 18                	je     80067c <vprintfmt+0x206>
  800664:	8d 50 e0             	lea    -0x20(%eax),%edx
  800667:	83 fa 5e             	cmp    $0x5e,%edx
  80066a:	76 10                	jbe    80067c <vprintfmt+0x206>
					putch('?', putdat);
  80066c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800670:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800677:	ff 55 08             	call   *0x8(%ebp)
  80067a:	eb 0a                	jmp    800686 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  80067c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800680:	89 04 24             	mov    %eax,(%esp)
  800683:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800686:	ff 4d e4             	decl   -0x1c(%ebp)
  800689:	0f be 06             	movsbl (%esi),%eax
  80068c:	46                   	inc    %esi
  80068d:	85 c0                	test   %eax,%eax
  80068f:	74 21                	je     8006b2 <vprintfmt+0x23c>
  800691:	85 ff                	test   %edi,%edi
  800693:	78 c9                	js     80065e <vprintfmt+0x1e8>
  800695:	4f                   	dec    %edi
  800696:	79 c6                	jns    80065e <vprintfmt+0x1e8>
  800698:	8b 7d 08             	mov    0x8(%ebp),%edi
  80069b:	89 de                	mov    %ebx,%esi
  80069d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8006a0:	eb 18                	jmp    8006ba <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006a2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006a6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006ad:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006af:	4b                   	dec    %ebx
  8006b0:	eb 08                	jmp    8006ba <vprintfmt+0x244>
  8006b2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006b5:	89 de                	mov    %ebx,%esi
  8006b7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8006ba:	85 db                	test   %ebx,%ebx
  8006bc:	7f e4                	jg     8006a2 <vprintfmt+0x22c>
  8006be:	89 7d 08             	mov    %edi,0x8(%ebp)
  8006c1:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006c6:	e9 ce fd ff ff       	jmp    800499 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006cb:	83 f9 01             	cmp    $0x1,%ecx
  8006ce:	7e 10                	jle    8006e0 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8006d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d3:	8d 50 08             	lea    0x8(%eax),%edx
  8006d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d9:	8b 30                	mov    (%eax),%esi
  8006db:	8b 78 04             	mov    0x4(%eax),%edi
  8006de:	eb 26                	jmp    800706 <vprintfmt+0x290>
	else if (lflag)
  8006e0:	85 c9                	test   %ecx,%ecx
  8006e2:	74 12                	je     8006f6 <vprintfmt+0x280>
		return va_arg(*ap, long);
  8006e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e7:	8d 50 04             	lea    0x4(%eax),%edx
  8006ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ed:	8b 30                	mov    (%eax),%esi
  8006ef:	89 f7                	mov    %esi,%edi
  8006f1:	c1 ff 1f             	sar    $0x1f,%edi
  8006f4:	eb 10                	jmp    800706 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8006f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f9:	8d 50 04             	lea    0x4(%eax),%edx
  8006fc:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ff:	8b 30                	mov    (%eax),%esi
  800701:	89 f7                	mov    %esi,%edi
  800703:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800706:	85 ff                	test   %edi,%edi
  800708:	78 0a                	js     800714 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80070a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80070f:	e9 8c 00 00 00       	jmp    8007a0 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800714:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800718:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80071f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800722:	f7 de                	neg    %esi
  800724:	83 d7 00             	adc    $0x0,%edi
  800727:	f7 df                	neg    %edi
			}
			base = 10;
  800729:	b8 0a 00 00 00       	mov    $0xa,%eax
  80072e:	eb 70                	jmp    8007a0 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800730:	89 ca                	mov    %ecx,%edx
  800732:	8d 45 14             	lea    0x14(%ebp),%eax
  800735:	e8 c0 fc ff ff       	call   8003fa <getuint>
  80073a:	89 c6                	mov    %eax,%esi
  80073c:	89 d7                	mov    %edx,%edi
			base = 10;
  80073e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800743:	eb 5b                	jmp    8007a0 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  800745:	89 ca                	mov    %ecx,%edx
  800747:	8d 45 14             	lea    0x14(%ebp),%eax
  80074a:	e8 ab fc ff ff       	call   8003fa <getuint>
  80074f:	89 c6                	mov    %eax,%esi
  800751:	89 d7                	mov    %edx,%edi
			base = 8;
  800753:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800758:	eb 46                	jmp    8007a0 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  80075a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80075e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800765:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800768:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80076c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800773:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800776:	8b 45 14             	mov    0x14(%ebp),%eax
  800779:	8d 50 04             	lea    0x4(%eax),%edx
  80077c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80077f:	8b 30                	mov    (%eax),%esi
  800781:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800786:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80078b:	eb 13                	jmp    8007a0 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80078d:	89 ca                	mov    %ecx,%edx
  80078f:	8d 45 14             	lea    0x14(%ebp),%eax
  800792:	e8 63 fc ff ff       	call   8003fa <getuint>
  800797:	89 c6                	mov    %eax,%esi
  800799:	89 d7                	mov    %edx,%edi
			base = 16;
  80079b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007a0:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8007a4:	89 54 24 10          	mov    %edx,0x10(%esp)
  8007a8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007ab:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007af:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007b3:	89 34 24             	mov    %esi,(%esp)
  8007b6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007ba:	89 da                	mov    %ebx,%edx
  8007bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bf:	e8 6c fb ff ff       	call   800330 <printnum>
			break;
  8007c4:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007c7:	e9 cd fc ff ff       	jmp    800499 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007d0:	89 04 24             	mov    %eax,(%esp)
  8007d3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007d9:	e9 bb fc ff ff       	jmp    800499 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007de:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e2:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007e9:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007ec:	eb 01                	jmp    8007ef <vprintfmt+0x379>
  8007ee:	4e                   	dec    %esi
  8007ef:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007f3:	75 f9                	jne    8007ee <vprintfmt+0x378>
  8007f5:	e9 9f fc ff ff       	jmp    800499 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8007fa:	83 c4 4c             	add    $0x4c,%esp
  8007fd:	5b                   	pop    %ebx
  8007fe:	5e                   	pop    %esi
  8007ff:	5f                   	pop    %edi
  800800:	5d                   	pop    %ebp
  800801:	c3                   	ret    

00800802 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	83 ec 28             	sub    $0x28,%esp
  800808:	8b 45 08             	mov    0x8(%ebp),%eax
  80080b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80080e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800811:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800815:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800818:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80081f:	85 c0                	test   %eax,%eax
  800821:	74 30                	je     800853 <vsnprintf+0x51>
  800823:	85 d2                	test   %edx,%edx
  800825:	7e 33                	jle    80085a <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800827:	8b 45 14             	mov    0x14(%ebp),%eax
  80082a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80082e:	8b 45 10             	mov    0x10(%ebp),%eax
  800831:	89 44 24 08          	mov    %eax,0x8(%esp)
  800835:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800838:	89 44 24 04          	mov    %eax,0x4(%esp)
  80083c:	c7 04 24 34 04 80 00 	movl   $0x800434,(%esp)
  800843:	e8 2e fc ff ff       	call   800476 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800848:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80084b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80084e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800851:	eb 0c                	jmp    80085f <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800853:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800858:	eb 05                	jmp    80085f <vsnprintf+0x5d>
  80085a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80085f:	c9                   	leave  
  800860:	c3                   	ret    

00800861 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800861:	55                   	push   %ebp
  800862:	89 e5                	mov    %esp,%ebp
  800864:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800867:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80086a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80086e:	8b 45 10             	mov    0x10(%ebp),%eax
  800871:	89 44 24 08          	mov    %eax,0x8(%esp)
  800875:	8b 45 0c             	mov    0xc(%ebp),%eax
  800878:	89 44 24 04          	mov    %eax,0x4(%esp)
  80087c:	8b 45 08             	mov    0x8(%ebp),%eax
  80087f:	89 04 24             	mov    %eax,(%esp)
  800882:	e8 7b ff ff ff       	call   800802 <vsnprintf>
	va_end(ap);

	return rc;
}
  800887:	c9                   	leave  
  800888:	c3                   	ret    
  800889:	00 00                	add    %al,(%eax)
	...

0080088c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80088c:	55                   	push   %ebp
  80088d:	89 e5                	mov    %esp,%ebp
  80088f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800892:	b8 00 00 00 00       	mov    $0x0,%eax
  800897:	eb 01                	jmp    80089a <strlen+0xe>
		n++;
  800899:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80089a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80089e:	75 f9                	jne    800899 <strlen+0xd>
		n++;
	return n;
}
  8008a0:	5d                   	pop    %ebp
  8008a1:	c3                   	ret    

008008a2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8008a8:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b0:	eb 01                	jmp    8008b3 <strnlen+0x11>
		n++;
  8008b2:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008b3:	39 d0                	cmp    %edx,%eax
  8008b5:	74 06                	je     8008bd <strnlen+0x1b>
  8008b7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008bb:	75 f5                	jne    8008b2 <strnlen+0x10>
		n++;
	return n;
}
  8008bd:	5d                   	pop    %ebp
  8008be:	c3                   	ret    

008008bf <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008bf:	55                   	push   %ebp
  8008c0:	89 e5                	mov    %esp,%ebp
  8008c2:	53                   	push   %ebx
  8008c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8008ce:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8008d1:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008d4:	42                   	inc    %edx
  8008d5:	84 c9                	test   %cl,%cl
  8008d7:	75 f5                	jne    8008ce <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008d9:	5b                   	pop    %ebx
  8008da:	5d                   	pop    %ebp
  8008db:	c3                   	ret    

008008dc <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008dc:	55                   	push   %ebp
  8008dd:	89 e5                	mov    %esp,%ebp
  8008df:	53                   	push   %ebx
  8008e0:	83 ec 08             	sub    $0x8,%esp
  8008e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008e6:	89 1c 24             	mov    %ebx,(%esp)
  8008e9:	e8 9e ff ff ff       	call   80088c <strlen>
	strcpy(dst + len, src);
  8008ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008f1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008f5:	01 d8                	add    %ebx,%eax
  8008f7:	89 04 24             	mov    %eax,(%esp)
  8008fa:	e8 c0 ff ff ff       	call   8008bf <strcpy>
	return dst;
}
  8008ff:	89 d8                	mov    %ebx,%eax
  800901:	83 c4 08             	add    $0x8,%esp
  800904:	5b                   	pop    %ebx
  800905:	5d                   	pop    %ebp
  800906:	c3                   	ret    

00800907 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	56                   	push   %esi
  80090b:	53                   	push   %ebx
  80090c:	8b 45 08             	mov    0x8(%ebp),%eax
  80090f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800912:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800915:	b9 00 00 00 00       	mov    $0x0,%ecx
  80091a:	eb 0c                	jmp    800928 <strncpy+0x21>
		*dst++ = *src;
  80091c:	8a 1a                	mov    (%edx),%bl
  80091e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800921:	80 3a 01             	cmpb   $0x1,(%edx)
  800924:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800927:	41                   	inc    %ecx
  800928:	39 f1                	cmp    %esi,%ecx
  80092a:	75 f0                	jne    80091c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80092c:	5b                   	pop    %ebx
  80092d:	5e                   	pop    %esi
  80092e:	5d                   	pop    %ebp
  80092f:	c3                   	ret    

00800930 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800930:	55                   	push   %ebp
  800931:	89 e5                	mov    %esp,%ebp
  800933:	56                   	push   %esi
  800934:	53                   	push   %ebx
  800935:	8b 75 08             	mov    0x8(%ebp),%esi
  800938:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80093b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80093e:	85 d2                	test   %edx,%edx
  800940:	75 0a                	jne    80094c <strlcpy+0x1c>
  800942:	89 f0                	mov    %esi,%eax
  800944:	eb 1a                	jmp    800960 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800946:	88 18                	mov    %bl,(%eax)
  800948:	40                   	inc    %eax
  800949:	41                   	inc    %ecx
  80094a:	eb 02                	jmp    80094e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80094c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80094e:	4a                   	dec    %edx
  80094f:	74 0a                	je     80095b <strlcpy+0x2b>
  800951:	8a 19                	mov    (%ecx),%bl
  800953:	84 db                	test   %bl,%bl
  800955:	75 ef                	jne    800946 <strlcpy+0x16>
  800957:	89 c2                	mov    %eax,%edx
  800959:	eb 02                	jmp    80095d <strlcpy+0x2d>
  80095b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  80095d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800960:	29 f0                	sub    %esi,%eax
}
  800962:	5b                   	pop    %ebx
  800963:	5e                   	pop    %esi
  800964:	5d                   	pop    %ebp
  800965:	c3                   	ret    

00800966 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800966:	55                   	push   %ebp
  800967:	89 e5                	mov    %esp,%ebp
  800969:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80096c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80096f:	eb 02                	jmp    800973 <strcmp+0xd>
		p++, q++;
  800971:	41                   	inc    %ecx
  800972:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800973:	8a 01                	mov    (%ecx),%al
  800975:	84 c0                	test   %al,%al
  800977:	74 04                	je     80097d <strcmp+0x17>
  800979:	3a 02                	cmp    (%edx),%al
  80097b:	74 f4                	je     800971 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80097d:	0f b6 c0             	movzbl %al,%eax
  800980:	0f b6 12             	movzbl (%edx),%edx
  800983:	29 d0                	sub    %edx,%eax
}
  800985:	5d                   	pop    %ebp
  800986:	c3                   	ret    

00800987 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	53                   	push   %ebx
  80098b:	8b 45 08             	mov    0x8(%ebp),%eax
  80098e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800991:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800994:	eb 03                	jmp    800999 <strncmp+0x12>
		n--, p++, q++;
  800996:	4a                   	dec    %edx
  800997:	40                   	inc    %eax
  800998:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800999:	85 d2                	test   %edx,%edx
  80099b:	74 14                	je     8009b1 <strncmp+0x2a>
  80099d:	8a 18                	mov    (%eax),%bl
  80099f:	84 db                	test   %bl,%bl
  8009a1:	74 04                	je     8009a7 <strncmp+0x20>
  8009a3:	3a 19                	cmp    (%ecx),%bl
  8009a5:	74 ef                	je     800996 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a7:	0f b6 00             	movzbl (%eax),%eax
  8009aa:	0f b6 11             	movzbl (%ecx),%edx
  8009ad:	29 d0                	sub    %edx,%eax
  8009af:	eb 05                	jmp    8009b6 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009b1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009b6:	5b                   	pop    %ebx
  8009b7:	5d                   	pop    %ebp
  8009b8:	c3                   	ret    

008009b9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009b9:	55                   	push   %ebp
  8009ba:	89 e5                	mov    %esp,%ebp
  8009bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bf:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009c2:	eb 05                	jmp    8009c9 <strchr+0x10>
		if (*s == c)
  8009c4:	38 ca                	cmp    %cl,%dl
  8009c6:	74 0c                	je     8009d4 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009c8:	40                   	inc    %eax
  8009c9:	8a 10                	mov    (%eax),%dl
  8009cb:	84 d2                	test   %dl,%dl
  8009cd:	75 f5                	jne    8009c4 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8009cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d4:	5d                   	pop    %ebp
  8009d5:	c3                   	ret    

008009d6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009d6:	55                   	push   %ebp
  8009d7:	89 e5                	mov    %esp,%ebp
  8009d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009dc:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009df:	eb 05                	jmp    8009e6 <strfind+0x10>
		if (*s == c)
  8009e1:	38 ca                	cmp    %cl,%dl
  8009e3:	74 07                	je     8009ec <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009e5:	40                   	inc    %eax
  8009e6:	8a 10                	mov    (%eax),%dl
  8009e8:	84 d2                	test   %dl,%dl
  8009ea:	75 f5                	jne    8009e1 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8009ec:	5d                   	pop    %ebp
  8009ed:	c3                   	ret    

008009ee <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
  8009f1:	57                   	push   %edi
  8009f2:	56                   	push   %esi
  8009f3:	53                   	push   %ebx
  8009f4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009fa:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009fd:	85 c9                	test   %ecx,%ecx
  8009ff:	74 30                	je     800a31 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a01:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a07:	75 25                	jne    800a2e <memset+0x40>
  800a09:	f6 c1 03             	test   $0x3,%cl
  800a0c:	75 20                	jne    800a2e <memset+0x40>
		c &= 0xFF;
  800a0e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a11:	89 d3                	mov    %edx,%ebx
  800a13:	c1 e3 08             	shl    $0x8,%ebx
  800a16:	89 d6                	mov    %edx,%esi
  800a18:	c1 e6 18             	shl    $0x18,%esi
  800a1b:	89 d0                	mov    %edx,%eax
  800a1d:	c1 e0 10             	shl    $0x10,%eax
  800a20:	09 f0                	or     %esi,%eax
  800a22:	09 d0                	or     %edx,%eax
  800a24:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a26:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a29:	fc                   	cld    
  800a2a:	f3 ab                	rep stos %eax,%es:(%edi)
  800a2c:	eb 03                	jmp    800a31 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a2e:	fc                   	cld    
  800a2f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a31:	89 f8                	mov    %edi,%eax
  800a33:	5b                   	pop    %ebx
  800a34:	5e                   	pop    %esi
  800a35:	5f                   	pop    %edi
  800a36:	5d                   	pop    %ebp
  800a37:	c3                   	ret    

00800a38 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a38:	55                   	push   %ebp
  800a39:	89 e5                	mov    %esp,%ebp
  800a3b:	57                   	push   %edi
  800a3c:	56                   	push   %esi
  800a3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a40:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a43:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a46:	39 c6                	cmp    %eax,%esi
  800a48:	73 34                	jae    800a7e <memmove+0x46>
  800a4a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a4d:	39 d0                	cmp    %edx,%eax
  800a4f:	73 2d                	jae    800a7e <memmove+0x46>
		s += n;
		d += n;
  800a51:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a54:	f6 c2 03             	test   $0x3,%dl
  800a57:	75 1b                	jne    800a74 <memmove+0x3c>
  800a59:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a5f:	75 13                	jne    800a74 <memmove+0x3c>
  800a61:	f6 c1 03             	test   $0x3,%cl
  800a64:	75 0e                	jne    800a74 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a66:	83 ef 04             	sub    $0x4,%edi
  800a69:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a6c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a6f:	fd                   	std    
  800a70:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a72:	eb 07                	jmp    800a7b <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a74:	4f                   	dec    %edi
  800a75:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a78:	fd                   	std    
  800a79:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a7b:	fc                   	cld    
  800a7c:	eb 20                	jmp    800a9e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a7e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a84:	75 13                	jne    800a99 <memmove+0x61>
  800a86:	a8 03                	test   $0x3,%al
  800a88:	75 0f                	jne    800a99 <memmove+0x61>
  800a8a:	f6 c1 03             	test   $0x3,%cl
  800a8d:	75 0a                	jne    800a99 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a8f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a92:	89 c7                	mov    %eax,%edi
  800a94:	fc                   	cld    
  800a95:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a97:	eb 05                	jmp    800a9e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a99:	89 c7                	mov    %eax,%edi
  800a9b:	fc                   	cld    
  800a9c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a9e:	5e                   	pop    %esi
  800a9f:	5f                   	pop    %edi
  800aa0:	5d                   	pop    %ebp
  800aa1:	c3                   	ret    

00800aa2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aa2:	55                   	push   %ebp
  800aa3:	89 e5                	mov    %esp,%ebp
  800aa5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800aa8:	8b 45 10             	mov    0x10(%ebp),%eax
  800aab:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aaf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ab6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab9:	89 04 24             	mov    %eax,(%esp)
  800abc:	e8 77 ff ff ff       	call   800a38 <memmove>
}
  800ac1:	c9                   	leave  
  800ac2:	c3                   	ret    

00800ac3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ac3:	55                   	push   %ebp
  800ac4:	89 e5                	mov    %esp,%ebp
  800ac6:	57                   	push   %edi
  800ac7:	56                   	push   %esi
  800ac8:	53                   	push   %ebx
  800ac9:	8b 7d 08             	mov    0x8(%ebp),%edi
  800acc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800acf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ad2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad7:	eb 16                	jmp    800aef <memcmp+0x2c>
		if (*s1 != *s2)
  800ad9:	8a 04 17             	mov    (%edi,%edx,1),%al
  800adc:	42                   	inc    %edx
  800add:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800ae1:	38 c8                	cmp    %cl,%al
  800ae3:	74 0a                	je     800aef <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800ae5:	0f b6 c0             	movzbl %al,%eax
  800ae8:	0f b6 c9             	movzbl %cl,%ecx
  800aeb:	29 c8                	sub    %ecx,%eax
  800aed:	eb 09                	jmp    800af8 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aef:	39 da                	cmp    %ebx,%edx
  800af1:	75 e6                	jne    800ad9 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800af3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af8:	5b                   	pop    %ebx
  800af9:	5e                   	pop    %esi
  800afa:	5f                   	pop    %edi
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	8b 45 08             	mov    0x8(%ebp),%eax
  800b03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b06:	89 c2                	mov    %eax,%edx
  800b08:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b0b:	eb 05                	jmp    800b12 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b0d:	38 08                	cmp    %cl,(%eax)
  800b0f:	74 05                	je     800b16 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b11:	40                   	inc    %eax
  800b12:	39 d0                	cmp    %edx,%eax
  800b14:	72 f7                	jb     800b0d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b16:	5d                   	pop    %ebp
  800b17:	c3                   	ret    

00800b18 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b18:	55                   	push   %ebp
  800b19:	89 e5                	mov    %esp,%ebp
  800b1b:	57                   	push   %edi
  800b1c:	56                   	push   %esi
  800b1d:	53                   	push   %ebx
  800b1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b21:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b24:	eb 01                	jmp    800b27 <strtol+0xf>
		s++;
  800b26:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b27:	8a 02                	mov    (%edx),%al
  800b29:	3c 20                	cmp    $0x20,%al
  800b2b:	74 f9                	je     800b26 <strtol+0xe>
  800b2d:	3c 09                	cmp    $0x9,%al
  800b2f:	74 f5                	je     800b26 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b31:	3c 2b                	cmp    $0x2b,%al
  800b33:	75 08                	jne    800b3d <strtol+0x25>
		s++;
  800b35:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b36:	bf 00 00 00 00       	mov    $0x0,%edi
  800b3b:	eb 13                	jmp    800b50 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b3d:	3c 2d                	cmp    $0x2d,%al
  800b3f:	75 0a                	jne    800b4b <strtol+0x33>
		s++, neg = 1;
  800b41:	8d 52 01             	lea    0x1(%edx),%edx
  800b44:	bf 01 00 00 00       	mov    $0x1,%edi
  800b49:	eb 05                	jmp    800b50 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b4b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b50:	85 db                	test   %ebx,%ebx
  800b52:	74 05                	je     800b59 <strtol+0x41>
  800b54:	83 fb 10             	cmp    $0x10,%ebx
  800b57:	75 28                	jne    800b81 <strtol+0x69>
  800b59:	8a 02                	mov    (%edx),%al
  800b5b:	3c 30                	cmp    $0x30,%al
  800b5d:	75 10                	jne    800b6f <strtol+0x57>
  800b5f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b63:	75 0a                	jne    800b6f <strtol+0x57>
		s += 2, base = 16;
  800b65:	83 c2 02             	add    $0x2,%edx
  800b68:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b6d:	eb 12                	jmp    800b81 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b6f:	85 db                	test   %ebx,%ebx
  800b71:	75 0e                	jne    800b81 <strtol+0x69>
  800b73:	3c 30                	cmp    $0x30,%al
  800b75:	75 05                	jne    800b7c <strtol+0x64>
		s++, base = 8;
  800b77:	42                   	inc    %edx
  800b78:	b3 08                	mov    $0x8,%bl
  800b7a:	eb 05                	jmp    800b81 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b7c:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b81:	b8 00 00 00 00       	mov    $0x0,%eax
  800b86:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b88:	8a 0a                	mov    (%edx),%cl
  800b8a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b8d:	80 fb 09             	cmp    $0x9,%bl
  800b90:	77 08                	ja     800b9a <strtol+0x82>
			dig = *s - '0';
  800b92:	0f be c9             	movsbl %cl,%ecx
  800b95:	83 e9 30             	sub    $0x30,%ecx
  800b98:	eb 1e                	jmp    800bb8 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b9a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b9d:	80 fb 19             	cmp    $0x19,%bl
  800ba0:	77 08                	ja     800baa <strtol+0x92>
			dig = *s - 'a' + 10;
  800ba2:	0f be c9             	movsbl %cl,%ecx
  800ba5:	83 e9 57             	sub    $0x57,%ecx
  800ba8:	eb 0e                	jmp    800bb8 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800baa:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800bad:	80 fb 19             	cmp    $0x19,%bl
  800bb0:	77 12                	ja     800bc4 <strtol+0xac>
			dig = *s - 'A' + 10;
  800bb2:	0f be c9             	movsbl %cl,%ecx
  800bb5:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bb8:	39 f1                	cmp    %esi,%ecx
  800bba:	7d 0c                	jge    800bc8 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800bbc:	42                   	inc    %edx
  800bbd:	0f af c6             	imul   %esi,%eax
  800bc0:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800bc2:	eb c4                	jmp    800b88 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800bc4:	89 c1                	mov    %eax,%ecx
  800bc6:	eb 02                	jmp    800bca <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bc8:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800bca:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bce:	74 05                	je     800bd5 <strtol+0xbd>
		*endptr = (char *) s;
  800bd0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bd3:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800bd5:	85 ff                	test   %edi,%edi
  800bd7:	74 04                	je     800bdd <strtol+0xc5>
  800bd9:	89 c8                	mov    %ecx,%eax
  800bdb:	f7 d8                	neg    %eax
}
  800bdd:	5b                   	pop    %ebx
  800bde:	5e                   	pop    %esi
  800bdf:	5f                   	pop    %edi
  800be0:	5d                   	pop    %ebp
  800be1:	c3                   	ret    
	...

00800be4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800be4:	55                   	push   %ebp
  800be5:	89 e5                	mov    %esp,%ebp
  800be7:	57                   	push   %edi
  800be8:	56                   	push   %esi
  800be9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bea:	b8 00 00 00 00       	mov    $0x0,%eax
  800bef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf5:	89 c3                	mov    %eax,%ebx
  800bf7:	89 c7                	mov    %eax,%edi
  800bf9:	89 c6                	mov    %eax,%esi
  800bfb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bfd:	5b                   	pop    %ebx
  800bfe:	5e                   	pop    %esi
  800bff:	5f                   	pop    %edi
  800c00:	5d                   	pop    %ebp
  800c01:	c3                   	ret    

00800c02 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c02:	55                   	push   %ebp
  800c03:	89 e5                	mov    %esp,%ebp
  800c05:	57                   	push   %edi
  800c06:	56                   	push   %esi
  800c07:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c08:	ba 00 00 00 00       	mov    $0x0,%edx
  800c0d:	b8 01 00 00 00       	mov    $0x1,%eax
  800c12:	89 d1                	mov    %edx,%ecx
  800c14:	89 d3                	mov    %edx,%ebx
  800c16:	89 d7                	mov    %edx,%edi
  800c18:	89 d6                	mov    %edx,%esi
  800c1a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c1c:	5b                   	pop    %ebx
  800c1d:	5e                   	pop    %esi
  800c1e:	5f                   	pop    %edi
  800c1f:	5d                   	pop    %ebp
  800c20:	c3                   	ret    

00800c21 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800c2a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c2f:	b8 03 00 00 00       	mov    $0x3,%eax
  800c34:	8b 55 08             	mov    0x8(%ebp),%edx
  800c37:	89 cb                	mov    %ecx,%ebx
  800c39:	89 cf                	mov    %ecx,%edi
  800c3b:	89 ce                	mov    %ecx,%esi
  800c3d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c3f:	85 c0                	test   %eax,%eax
  800c41:	7e 28                	jle    800c6b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c43:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c47:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c4e:	00 
  800c4f:	c7 44 24 08 a7 2a 80 	movl   $0x802aa7,0x8(%esp)
  800c56:	00 
  800c57:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c5e:	00 
  800c5f:	c7 04 24 c4 2a 80 00 	movl   $0x802ac4,(%esp)
  800c66:	e8 b1 f5 ff ff       	call   80021c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c6b:	83 c4 2c             	add    $0x2c,%esp
  800c6e:	5b                   	pop    %ebx
  800c6f:	5e                   	pop    %esi
  800c70:	5f                   	pop    %edi
  800c71:	5d                   	pop    %ebp
  800c72:	c3                   	ret    

00800c73 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c73:	55                   	push   %ebp
  800c74:	89 e5                	mov    %esp,%ebp
  800c76:	57                   	push   %edi
  800c77:	56                   	push   %esi
  800c78:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c79:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7e:	b8 02 00 00 00       	mov    $0x2,%eax
  800c83:	89 d1                	mov    %edx,%ecx
  800c85:	89 d3                	mov    %edx,%ebx
  800c87:	89 d7                	mov    %edx,%edi
  800c89:	89 d6                	mov    %edx,%esi
  800c8b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c8d:	5b                   	pop    %ebx
  800c8e:	5e                   	pop    %esi
  800c8f:	5f                   	pop    %edi
  800c90:	5d                   	pop    %ebp
  800c91:	c3                   	ret    

00800c92 <sys_yield>:

void
sys_yield(void)
{
  800c92:	55                   	push   %ebp
  800c93:	89 e5                	mov    %esp,%ebp
  800c95:	57                   	push   %edi
  800c96:	56                   	push   %esi
  800c97:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c98:	ba 00 00 00 00       	mov    $0x0,%edx
  800c9d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ca2:	89 d1                	mov    %edx,%ecx
  800ca4:	89 d3                	mov    %edx,%ebx
  800ca6:	89 d7                	mov    %edx,%edi
  800ca8:	89 d6                	mov    %edx,%esi
  800caa:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cac:	5b                   	pop    %ebx
  800cad:	5e                   	pop    %esi
  800cae:	5f                   	pop    %edi
  800caf:	5d                   	pop    %ebp
  800cb0:	c3                   	ret    

00800cb1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cb1:	55                   	push   %ebp
  800cb2:	89 e5                	mov    %esp,%ebp
  800cb4:	57                   	push   %edi
  800cb5:	56                   	push   %esi
  800cb6:	53                   	push   %ebx
  800cb7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cba:	be 00 00 00 00       	mov    $0x0,%esi
  800cbf:	b8 04 00 00 00       	mov    $0x4,%eax
  800cc4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cca:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccd:	89 f7                	mov    %esi,%edi
  800ccf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cd1:	85 c0                	test   %eax,%eax
  800cd3:	7e 28                	jle    800cfd <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cd9:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800ce0:	00 
  800ce1:	c7 44 24 08 a7 2a 80 	movl   $0x802aa7,0x8(%esp)
  800ce8:	00 
  800ce9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cf0:	00 
  800cf1:	c7 04 24 c4 2a 80 00 	movl   $0x802ac4,(%esp)
  800cf8:	e8 1f f5 ff ff       	call   80021c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cfd:	83 c4 2c             	add    $0x2c,%esp
  800d00:	5b                   	pop    %ebx
  800d01:	5e                   	pop    %esi
  800d02:	5f                   	pop    %edi
  800d03:	5d                   	pop    %ebp
  800d04:	c3                   	ret    

00800d05 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d05:	55                   	push   %ebp
  800d06:	89 e5                	mov    %esp,%ebp
  800d08:	57                   	push   %edi
  800d09:	56                   	push   %esi
  800d0a:	53                   	push   %ebx
  800d0b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0e:	b8 05 00 00 00       	mov    $0x5,%eax
  800d13:	8b 75 18             	mov    0x18(%ebp),%esi
  800d16:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d19:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d22:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d24:	85 c0                	test   %eax,%eax
  800d26:	7e 28                	jle    800d50 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d28:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d2c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d33:	00 
  800d34:	c7 44 24 08 a7 2a 80 	movl   $0x802aa7,0x8(%esp)
  800d3b:	00 
  800d3c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d43:	00 
  800d44:	c7 04 24 c4 2a 80 00 	movl   $0x802ac4,(%esp)
  800d4b:	e8 cc f4 ff ff       	call   80021c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d50:	83 c4 2c             	add    $0x2c,%esp
  800d53:	5b                   	pop    %ebx
  800d54:	5e                   	pop    %esi
  800d55:	5f                   	pop    %edi
  800d56:	5d                   	pop    %ebp
  800d57:	c3                   	ret    

00800d58 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d58:	55                   	push   %ebp
  800d59:	89 e5                	mov    %esp,%ebp
  800d5b:	57                   	push   %edi
  800d5c:	56                   	push   %esi
  800d5d:	53                   	push   %ebx
  800d5e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d61:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d66:	b8 06 00 00 00       	mov    $0x6,%eax
  800d6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d71:	89 df                	mov    %ebx,%edi
  800d73:	89 de                	mov    %ebx,%esi
  800d75:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d77:	85 c0                	test   %eax,%eax
  800d79:	7e 28                	jle    800da3 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d7f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d86:	00 
  800d87:	c7 44 24 08 a7 2a 80 	movl   $0x802aa7,0x8(%esp)
  800d8e:	00 
  800d8f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d96:	00 
  800d97:	c7 04 24 c4 2a 80 00 	movl   $0x802ac4,(%esp)
  800d9e:	e8 79 f4 ff ff       	call   80021c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800da3:	83 c4 2c             	add    $0x2c,%esp
  800da6:	5b                   	pop    %ebx
  800da7:	5e                   	pop    %esi
  800da8:	5f                   	pop    %edi
  800da9:	5d                   	pop    %ebp
  800daa:	c3                   	ret    

00800dab <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dab:	55                   	push   %ebp
  800dac:	89 e5                	mov    %esp,%ebp
  800dae:	57                   	push   %edi
  800daf:	56                   	push   %esi
  800db0:	53                   	push   %ebx
  800db1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db9:	b8 08 00 00 00       	mov    $0x8,%eax
  800dbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc1:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc4:	89 df                	mov    %ebx,%edi
  800dc6:	89 de                	mov    %ebx,%esi
  800dc8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dca:	85 c0                	test   %eax,%eax
  800dcc:	7e 28                	jle    800df6 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dce:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dd2:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800dd9:	00 
  800dda:	c7 44 24 08 a7 2a 80 	movl   $0x802aa7,0x8(%esp)
  800de1:	00 
  800de2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800de9:	00 
  800dea:	c7 04 24 c4 2a 80 00 	movl   $0x802ac4,(%esp)
  800df1:	e8 26 f4 ff ff       	call   80021c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800df6:	83 c4 2c             	add    $0x2c,%esp
  800df9:	5b                   	pop    %ebx
  800dfa:	5e                   	pop    %esi
  800dfb:	5f                   	pop    %edi
  800dfc:	5d                   	pop    %ebp
  800dfd:	c3                   	ret    

00800dfe <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dfe:	55                   	push   %ebp
  800dff:	89 e5                	mov    %esp,%ebp
  800e01:	57                   	push   %edi
  800e02:	56                   	push   %esi
  800e03:	53                   	push   %ebx
  800e04:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e07:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e0c:	b8 09 00 00 00       	mov    $0x9,%eax
  800e11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e14:	8b 55 08             	mov    0x8(%ebp),%edx
  800e17:	89 df                	mov    %ebx,%edi
  800e19:	89 de                	mov    %ebx,%esi
  800e1b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e1d:	85 c0                	test   %eax,%eax
  800e1f:	7e 28                	jle    800e49 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e21:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e25:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e2c:	00 
  800e2d:	c7 44 24 08 a7 2a 80 	movl   $0x802aa7,0x8(%esp)
  800e34:	00 
  800e35:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e3c:	00 
  800e3d:	c7 04 24 c4 2a 80 00 	movl   $0x802ac4,(%esp)
  800e44:	e8 d3 f3 ff ff       	call   80021c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e49:	83 c4 2c             	add    $0x2c,%esp
  800e4c:	5b                   	pop    %ebx
  800e4d:	5e                   	pop    %esi
  800e4e:	5f                   	pop    %edi
  800e4f:	5d                   	pop    %ebp
  800e50:	c3                   	ret    

00800e51 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800e5a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e5f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e67:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6a:	89 df                	mov    %ebx,%edi
  800e6c:	89 de                	mov    %ebx,%esi
  800e6e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e70:	85 c0                	test   %eax,%eax
  800e72:	7e 28                	jle    800e9c <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e74:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e78:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e7f:	00 
  800e80:	c7 44 24 08 a7 2a 80 	movl   $0x802aa7,0x8(%esp)
  800e87:	00 
  800e88:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e8f:	00 
  800e90:	c7 04 24 c4 2a 80 00 	movl   $0x802ac4,(%esp)
  800e97:	e8 80 f3 ff ff       	call   80021c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e9c:	83 c4 2c             	add    $0x2c,%esp
  800e9f:	5b                   	pop    %ebx
  800ea0:	5e                   	pop    %esi
  800ea1:	5f                   	pop    %edi
  800ea2:	5d                   	pop    %ebp
  800ea3:	c3                   	ret    

00800ea4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
  800ea7:	57                   	push   %edi
  800ea8:	56                   	push   %esi
  800ea9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eaa:	be 00 00 00 00       	mov    $0x0,%esi
  800eaf:	b8 0c 00 00 00       	mov    $0xc,%eax
  800eb4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800eb7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ebd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ec2:	5b                   	pop    %ebx
  800ec3:	5e                   	pop    %esi
  800ec4:	5f                   	pop    %edi
  800ec5:	5d                   	pop    %ebp
  800ec6:	c3                   	ret    

00800ec7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ec7:	55                   	push   %ebp
  800ec8:	89 e5                	mov    %esp,%ebp
  800eca:	57                   	push   %edi
  800ecb:	56                   	push   %esi
  800ecc:	53                   	push   %ebx
  800ecd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ed5:	b8 0d 00 00 00       	mov    $0xd,%eax
  800eda:	8b 55 08             	mov    0x8(%ebp),%edx
  800edd:	89 cb                	mov    %ecx,%ebx
  800edf:	89 cf                	mov    %ecx,%edi
  800ee1:	89 ce                	mov    %ecx,%esi
  800ee3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ee5:	85 c0                	test   %eax,%eax
  800ee7:	7e 28                	jle    800f11 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eed:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800ef4:	00 
  800ef5:	c7 44 24 08 a7 2a 80 	movl   $0x802aa7,0x8(%esp)
  800efc:	00 
  800efd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f04:	00 
  800f05:	c7 04 24 c4 2a 80 00 	movl   $0x802ac4,(%esp)
  800f0c:	e8 0b f3 ff ff       	call   80021c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f11:	83 c4 2c             	add    $0x2c,%esp
  800f14:	5b                   	pop    %ebx
  800f15:	5e                   	pop    %esi
  800f16:	5f                   	pop    %edi
  800f17:	5d                   	pop    %ebp
  800f18:	c3                   	ret    

00800f19 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800f19:	55                   	push   %ebp
  800f1a:	89 e5                	mov    %esp,%ebp
  800f1c:	57                   	push   %edi
  800f1d:	56                   	push   %esi
  800f1e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f1f:	ba 00 00 00 00       	mov    $0x0,%edx
  800f24:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f29:	89 d1                	mov    %edx,%ecx
  800f2b:	89 d3                	mov    %edx,%ebx
  800f2d:	89 d7                	mov    %edx,%edi
  800f2f:	89 d6                	mov    %edx,%esi
  800f31:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800f33:	5b                   	pop    %ebx
  800f34:	5e                   	pop    %esi
  800f35:	5f                   	pop    %edi
  800f36:	5d                   	pop    %ebp
  800f37:	c3                   	ret    

00800f38 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char* pck, size_t length){
  800f38:	55                   	push   %ebp
  800f39:	89 e5                	mov    %esp,%ebp
  800f3b:	57                   	push   %edi
  800f3c:	56                   	push   %esi
  800f3d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f3e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f43:	b8 10 00 00 00       	mov    $0x10,%eax
  800f48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f4b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f4e:	89 df                	mov    %ebx,%edi
  800f50:	89 de                	mov    %ebx,%esi
  800f52:	cd 30                	int    $0x30
}

int 
sys_e1000_transmit(char* pck, size_t length){
	return syscall(SYS_e1000_transmit, 0, (uint32_t)pck, length, 0, 0, 0);
}
  800f54:	5b                   	pop    %ebx
  800f55:	5e                   	pop    %esi
  800f56:	5f                   	pop    %edi
  800f57:	5d                   	pop    %ebp
  800f58:	c3                   	ret    

00800f59 <sys_e1000_receive>:

int 
sys_e1000_receive(char* pck, size_t* length){
  800f59:	55                   	push   %ebp
  800f5a:	89 e5                	mov    %esp,%ebp
  800f5c:	57                   	push   %edi
  800f5d:	56                   	push   %esi
  800f5e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f5f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f64:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f6f:	89 df                	mov    %ebx,%edi
  800f71:	89 de                	mov    %ebx,%esi
  800f73:	cd 30                	int    $0x30
}

int 
sys_e1000_receive(char* pck, size_t* length){
	return syscall(SYS_e1000_receive, 0, (uint32_t)pck, (uint32_t)length, 0, 0, 0);
}
  800f75:	5b                   	pop    %ebx
  800f76:	5e                   	pop    %esi
  800f77:	5f                   	pop    %edi
  800f78:	5d                   	pop    %ebp
  800f79:	c3                   	ret    

00800f7a <sys_e1000_get_mac>:

int 
sys_e1000_get_mac(uint8_t* mac_addr){
  800f7a:	55                   	push   %ebp
  800f7b:	89 e5                	mov    %esp,%ebp
  800f7d:	57                   	push   %edi
  800f7e:	56                   	push   %esi
  800f7f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f80:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f85:	b8 11 00 00 00       	mov    $0x11,%eax
  800f8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800f8d:	89 cb                	mov    %ecx,%ebx
  800f8f:	89 cf                	mov    %ecx,%edi
  800f91:	89 ce                	mov    %ecx,%esi
  800f93:	cd 30                	int    $0x30
}

int 
sys_e1000_get_mac(uint8_t* mac_addr){
	return syscall(SYS_e1000_get_mac, 0, (uint32_t)mac_addr, 0, 0, 0, 0);
}
  800f95:	5b                   	pop    %ebx
  800f96:	5e                   	pop    %esi
  800f97:	5f                   	pop    %edi
  800f98:	5d                   	pop    %ebp
  800f99:	c3                   	ret    
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
  801092:	8b 04 95 50 2b 80 00 	mov    0x802b50(,%edx,4),%eax
  801099:	85 c0                	test   %eax,%eax
  80109b:	75 e7                	jne    801084 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80109d:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8010a2:	8b 40 48             	mov    0x48(%eax),%eax
  8010a5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010ad:	c7 04 24 d4 2a 80 00 	movl   $0x802ad4,(%esp)
  8010b4:	e8 5b f2 ff ff       	call   800314 <cprintf>
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
  801144:	e8 0f fc ff ff       	call   800d58 <sys_page_unmap>
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
  80123f:	e8 c1 fa ff ff       	call   800d05 <sys_page_map>
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
  80127a:	e8 86 fa ff ff       	call   800d05 <sys_page_map>
  80127f:	89 c3                	mov    %eax,%ebx
  801281:	85 c0                	test   %eax,%eax
  801283:	79 25                	jns    8012aa <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801285:	89 74 24 04          	mov    %esi,0x4(%esp)
  801289:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801290:	e8 c3 fa ff ff       	call   800d58 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801295:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801298:	89 44 24 04          	mov    %eax,0x4(%esp)
  80129c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012a3:	e8 b0 fa ff ff       	call   800d58 <sys_page_unmap>
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
  8012f9:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8012fe:	8b 40 48             	mov    0x48(%eax),%eax
  801301:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801305:	89 44 24 04          	mov    %eax,0x4(%esp)
  801309:	c7 04 24 15 2b 80 00 	movl   $0x802b15,(%esp)
  801310:	e8 ff ef ff ff       	call   800314 <cprintf>
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
  8013cf:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8013d4:	8b 40 48             	mov    0x48(%eax),%eax
  8013d7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013df:	c7 04 24 31 2b 80 00 	movl   $0x802b31,(%esp)
  8013e6:	e8 29 ef ff ff       	call   800314 <cprintf>
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
  801486:	a1 0c 40 80 00       	mov    0x80400c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80148b:	8b 40 48             	mov    0x48(%eax),%eax
  80148e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801492:	89 44 24 04          	mov    %eax,0x4(%esp)
  801496:	c7 04 24 f4 2a 80 00 	movl   $0x802af4,(%esp)
  80149d:	e8 72 ee ff ff       	call   800314 <cprintf>
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
  801598:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  80159f:	75 11                	jne    8015b2 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8015a1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8015a8:	e8 a2 0e 00 00       	call   80244f <ipc_find_env>
  8015ad:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8015b2:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8015b9:	00 
  8015ba:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8015c1:	00 
  8015c2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015c6:	a1 04 40 80 00       	mov    0x804004,%eax
  8015cb:	89 04 24             	mov    %eax,(%esp)
  8015ce:	e8 0e 0e 00 00       	call   8023e1 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8015d3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015da:	00 
  8015db:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015e6:	e8 8d 0d 00 00       	call   802378 <ipc_recv>
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
  801671:	e8 49 f2 ff ff       	call   8008bf <strcpy>
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
  8016d2:	e8 61 f3 ff ff       	call   800a38 <memmove>
	 
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
  80171d:	c7 44 24 0c 64 2b 80 	movl   $0x802b64,0xc(%esp)
  801724:	00 
  801725:	c7 44 24 08 6b 2b 80 	movl   $0x802b6b,0x8(%esp)
  80172c:	00 
  80172d:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801734:	00 
  801735:	c7 04 24 80 2b 80 00 	movl   $0x802b80,(%esp)
  80173c:	e8 db ea ff ff       	call   80021c <_panic>
	assert(r <= PGSIZE);
  801741:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801746:	7e 24                	jle    80176c <devfile_read+0x84>
  801748:	c7 44 24 0c 8b 2b 80 	movl   $0x802b8b,0xc(%esp)
  80174f:	00 
  801750:	c7 44 24 08 6b 2b 80 	movl   $0x802b6b,0x8(%esp)
  801757:	00 
  801758:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  80175f:	00 
  801760:	c7 04 24 80 2b 80 00 	movl   $0x802b80,(%esp)
  801767:	e8 b0 ea ff ff       	call   80021c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80176c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801770:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801777:	00 
  801778:	8b 45 0c             	mov    0xc(%ebp),%eax
  80177b:	89 04 24             	mov    %eax,(%esp)
  80177e:	e8 b5 f2 ff ff       	call   800a38 <memmove>
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
  80179a:	e8 ed f0 ff ff       	call   80088c <strlen>
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
  8017c2:	e8 f8 f0 ff ff       	call   8008bf <strcpy>
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
  8018f5:	e8 7c eb ff ff       	call   800476 <vprintfmt>
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

00801964 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801964:	55                   	push   %ebp
  801965:	89 e5                	mov    %esp,%ebp
  801967:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  80196a:	c7 44 24 04 97 2b 80 	movl   $0x802b97,0x4(%esp)
  801971:	00 
  801972:	8b 45 0c             	mov    0xc(%ebp),%eax
  801975:	89 04 24             	mov    %eax,(%esp)
  801978:	e8 42 ef ff ff       	call   8008bf <strcpy>
	return 0;
}
  80197d:	b8 00 00 00 00       	mov    $0x0,%eax
  801982:	c9                   	leave  
  801983:	c3                   	ret    

00801984 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801984:	55                   	push   %ebp
  801985:	89 e5                	mov    %esp,%ebp
  801987:	53                   	push   %ebx
  801988:	83 ec 14             	sub    $0x14,%esp
  80198b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80198e:	89 1c 24             	mov    %ebx,(%esp)
  801991:	e8 f2 0a 00 00       	call   802488 <pageref>
  801996:	83 f8 01             	cmp    $0x1,%eax
  801999:	75 0d                	jne    8019a8 <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  80199b:	8b 43 0c             	mov    0xc(%ebx),%eax
  80199e:	89 04 24             	mov    %eax,(%esp)
  8019a1:	e8 1f 03 00 00       	call   801cc5 <nsipc_close>
  8019a6:	eb 05                	jmp    8019ad <devsock_close+0x29>
	else
		return 0;
  8019a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019ad:	83 c4 14             	add    $0x14,%esp
  8019b0:	5b                   	pop    %ebx
  8019b1:	5d                   	pop    %ebp
  8019b2:	c3                   	ret    

008019b3 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8019b3:	55                   	push   %ebp
  8019b4:	89 e5                	mov    %esp,%ebp
  8019b6:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8019b9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8019c0:	00 
  8019c1:	8b 45 10             	mov    0x10(%ebp),%eax
  8019c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d2:	8b 40 0c             	mov    0xc(%eax),%eax
  8019d5:	89 04 24             	mov    %eax,(%esp)
  8019d8:	e8 e3 03 00 00       	call   801dc0 <nsipc_send>
}
  8019dd:	c9                   	leave  
  8019de:	c3                   	ret    

008019df <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8019df:	55                   	push   %ebp
  8019e0:	89 e5                	mov    %esp,%ebp
  8019e2:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8019e5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8019ec:	00 
  8019ed:	8b 45 10             	mov    0x10(%ebp),%eax
  8019f0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8019fe:	8b 40 0c             	mov    0xc(%eax),%eax
  801a01:	89 04 24             	mov    %eax,(%esp)
  801a04:	e8 37 03 00 00       	call   801d40 <nsipc_recv>
}
  801a09:	c9                   	leave  
  801a0a:	c3                   	ret    

00801a0b <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801a0b:	55                   	push   %ebp
  801a0c:	89 e5                	mov    %esp,%ebp
  801a0e:	56                   	push   %esi
  801a0f:	53                   	push   %ebx
  801a10:	83 ec 20             	sub    $0x20,%esp
  801a13:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801a15:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a18:	89 04 24             	mov    %eax,(%esp)
  801a1b:	e8 a7 f5 ff ff       	call   800fc7 <fd_alloc>
  801a20:	89 c3                	mov    %eax,%ebx
  801a22:	85 c0                	test   %eax,%eax
  801a24:	78 21                	js     801a47 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a26:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801a2d:	00 
  801a2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a31:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a35:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a3c:	e8 70 f2 ff ff       	call   800cb1 <sys_page_alloc>
  801a41:	89 c3                	mov    %eax,%ebx
  801a43:	85 c0                	test   %eax,%eax
  801a45:	79 0a                	jns    801a51 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  801a47:	89 34 24             	mov    %esi,(%esp)
  801a4a:	e8 76 02 00 00       	call   801cc5 <nsipc_close>
		return r;
  801a4f:	eb 22                	jmp    801a73 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801a51:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801a57:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a5a:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a5f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801a66:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801a69:	89 04 24             	mov    %eax,(%esp)
  801a6c:	e8 2b f5 ff ff       	call   800f9c <fd2num>
  801a71:	89 c3                	mov    %eax,%ebx
}
  801a73:	89 d8                	mov    %ebx,%eax
  801a75:	83 c4 20             	add    $0x20,%esp
  801a78:	5b                   	pop    %ebx
  801a79:	5e                   	pop    %esi
  801a7a:	5d                   	pop    %ebp
  801a7b:	c3                   	ret    

00801a7c <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801a7c:	55                   	push   %ebp
  801a7d:	89 e5                	mov    %esp,%ebp
  801a7f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a82:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a85:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a89:	89 04 24             	mov    %eax,(%esp)
  801a8c:	e8 89 f5 ff ff       	call   80101a <fd_lookup>
  801a91:	85 c0                	test   %eax,%eax
  801a93:	78 17                	js     801aac <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801a95:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a98:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801a9e:	39 10                	cmp    %edx,(%eax)
  801aa0:	75 05                	jne    801aa7 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801aa2:	8b 40 0c             	mov    0xc(%eax),%eax
  801aa5:	eb 05                	jmp    801aac <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801aa7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801aac:	c9                   	leave  
  801aad:	c3                   	ret    

00801aae <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801aae:	55                   	push   %ebp
  801aaf:	89 e5                	mov    %esp,%ebp
  801ab1:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ab4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab7:	e8 c0 ff ff ff       	call   801a7c <fd2sockid>
  801abc:	85 c0                	test   %eax,%eax
  801abe:	78 1f                	js     801adf <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ac0:	8b 55 10             	mov    0x10(%ebp),%edx
  801ac3:	89 54 24 08          	mov    %edx,0x8(%esp)
  801ac7:	8b 55 0c             	mov    0xc(%ebp),%edx
  801aca:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ace:	89 04 24             	mov    %eax,(%esp)
  801ad1:	e8 38 01 00 00       	call   801c0e <nsipc_accept>
  801ad6:	85 c0                	test   %eax,%eax
  801ad8:	78 05                	js     801adf <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801ada:	e8 2c ff ff ff       	call   801a0b <alloc_sockfd>
}
  801adf:	c9                   	leave  
  801ae0:	c3                   	ret    

00801ae1 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ae1:	55                   	push   %ebp
  801ae2:	89 e5                	mov    %esp,%ebp
  801ae4:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ae7:	8b 45 08             	mov    0x8(%ebp),%eax
  801aea:	e8 8d ff ff ff       	call   801a7c <fd2sockid>
  801aef:	85 c0                	test   %eax,%eax
  801af1:	78 16                	js     801b09 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801af3:	8b 55 10             	mov    0x10(%ebp),%edx
  801af6:	89 54 24 08          	mov    %edx,0x8(%esp)
  801afa:	8b 55 0c             	mov    0xc(%ebp),%edx
  801afd:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b01:	89 04 24             	mov    %eax,(%esp)
  801b04:	e8 5b 01 00 00       	call   801c64 <nsipc_bind>
}
  801b09:	c9                   	leave  
  801b0a:	c3                   	ret    

00801b0b <shutdown>:

int
shutdown(int s, int how)
{
  801b0b:	55                   	push   %ebp
  801b0c:	89 e5                	mov    %esp,%ebp
  801b0e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b11:	8b 45 08             	mov    0x8(%ebp),%eax
  801b14:	e8 63 ff ff ff       	call   801a7c <fd2sockid>
  801b19:	85 c0                	test   %eax,%eax
  801b1b:	78 0f                	js     801b2c <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801b1d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b20:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b24:	89 04 24             	mov    %eax,(%esp)
  801b27:	e8 77 01 00 00       	call   801ca3 <nsipc_shutdown>
}
  801b2c:	c9                   	leave  
  801b2d:	c3                   	ret    

00801b2e <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b2e:	55                   	push   %ebp
  801b2f:	89 e5                	mov    %esp,%ebp
  801b31:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b34:	8b 45 08             	mov    0x8(%ebp),%eax
  801b37:	e8 40 ff ff ff       	call   801a7c <fd2sockid>
  801b3c:	85 c0                	test   %eax,%eax
  801b3e:	78 16                	js     801b56 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801b40:	8b 55 10             	mov    0x10(%ebp),%edx
  801b43:	89 54 24 08          	mov    %edx,0x8(%esp)
  801b47:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b4a:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b4e:	89 04 24             	mov    %eax,(%esp)
  801b51:	e8 89 01 00 00       	call   801cdf <nsipc_connect>
}
  801b56:	c9                   	leave  
  801b57:	c3                   	ret    

00801b58 <listen>:

int
listen(int s, int backlog)
{
  801b58:	55                   	push   %ebp
  801b59:	89 e5                	mov    %esp,%ebp
  801b5b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b5e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b61:	e8 16 ff ff ff       	call   801a7c <fd2sockid>
  801b66:	85 c0                	test   %eax,%eax
  801b68:	78 0f                	js     801b79 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801b6a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b6d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b71:	89 04 24             	mov    %eax,(%esp)
  801b74:	e8 a5 01 00 00       	call   801d1e <nsipc_listen>
}
  801b79:	c9                   	leave  
  801b7a:	c3                   	ret    

00801b7b <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801b7b:	55                   	push   %ebp
  801b7c:	89 e5                	mov    %esp,%ebp
  801b7e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801b81:	8b 45 10             	mov    0x10(%ebp),%eax
  801b84:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b88:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b8f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b92:	89 04 24             	mov    %eax,(%esp)
  801b95:	e8 99 02 00 00       	call   801e33 <nsipc_socket>
  801b9a:	85 c0                	test   %eax,%eax
  801b9c:	78 05                	js     801ba3 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801b9e:	e8 68 fe ff ff       	call   801a0b <alloc_sockfd>
}
  801ba3:	c9                   	leave  
  801ba4:	c3                   	ret    
  801ba5:	00 00                	add    %al,(%eax)
	...

00801ba8 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801ba8:	55                   	push   %ebp
  801ba9:	89 e5                	mov    %esp,%ebp
  801bab:	53                   	push   %ebx
  801bac:	83 ec 14             	sub    $0x14,%esp
  801baf:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801bb1:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  801bb8:	75 11                	jne    801bcb <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801bba:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801bc1:	e8 89 08 00 00       	call   80244f <ipc_find_env>
  801bc6:	a3 08 40 80 00       	mov    %eax,0x804008
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801bcb:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801bd2:	00 
  801bd3:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801bda:	00 
  801bdb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801bdf:	a1 08 40 80 00       	mov    0x804008,%eax
  801be4:	89 04 24             	mov    %eax,(%esp)
  801be7:	e8 f5 07 00 00       	call   8023e1 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801bec:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801bf3:	00 
  801bf4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801bfb:	00 
  801bfc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c03:	e8 70 07 00 00       	call   802378 <ipc_recv>
}
  801c08:	83 c4 14             	add    $0x14,%esp
  801c0b:	5b                   	pop    %ebx
  801c0c:	5d                   	pop    %ebp
  801c0d:	c3                   	ret    

00801c0e <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c0e:	55                   	push   %ebp
  801c0f:	89 e5                	mov    %esp,%ebp
  801c11:	56                   	push   %esi
  801c12:	53                   	push   %ebx
  801c13:	83 ec 10             	sub    $0x10,%esp
  801c16:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801c19:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801c21:	8b 06                	mov    (%esi),%eax
  801c23:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801c28:	b8 01 00 00 00       	mov    $0x1,%eax
  801c2d:	e8 76 ff ff ff       	call   801ba8 <nsipc>
  801c32:	89 c3                	mov    %eax,%ebx
  801c34:	85 c0                	test   %eax,%eax
  801c36:	78 23                	js     801c5b <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801c38:	a1 10 60 80 00       	mov    0x806010,%eax
  801c3d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c41:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801c48:	00 
  801c49:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c4c:	89 04 24             	mov    %eax,(%esp)
  801c4f:	e8 e4 ed ff ff       	call   800a38 <memmove>
		*addrlen = ret->ret_addrlen;
  801c54:	a1 10 60 80 00       	mov    0x806010,%eax
  801c59:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801c5b:	89 d8                	mov    %ebx,%eax
  801c5d:	83 c4 10             	add    $0x10,%esp
  801c60:	5b                   	pop    %ebx
  801c61:	5e                   	pop    %esi
  801c62:	5d                   	pop    %ebp
  801c63:	c3                   	ret    

00801c64 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c64:	55                   	push   %ebp
  801c65:	89 e5                	mov    %esp,%ebp
  801c67:	53                   	push   %ebx
  801c68:	83 ec 14             	sub    $0x14,%esp
  801c6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801c6e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c71:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801c76:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c7d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c81:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801c88:	e8 ab ed ff ff       	call   800a38 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801c8d:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801c93:	b8 02 00 00 00       	mov    $0x2,%eax
  801c98:	e8 0b ff ff ff       	call   801ba8 <nsipc>
}
  801c9d:	83 c4 14             	add    $0x14,%esp
  801ca0:	5b                   	pop    %ebx
  801ca1:	5d                   	pop    %ebp
  801ca2:	c3                   	ret    

00801ca3 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801ca3:	55                   	push   %ebp
  801ca4:	89 e5                	mov    %esp,%ebp
  801ca6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801ca9:	8b 45 08             	mov    0x8(%ebp),%eax
  801cac:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801cb1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cb4:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801cb9:	b8 03 00 00 00       	mov    $0x3,%eax
  801cbe:	e8 e5 fe ff ff       	call   801ba8 <nsipc>
}
  801cc3:	c9                   	leave  
  801cc4:	c3                   	ret    

00801cc5 <nsipc_close>:

int
nsipc_close(int s)
{
  801cc5:	55                   	push   %ebp
  801cc6:	89 e5                	mov    %esp,%ebp
  801cc8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801ccb:	8b 45 08             	mov    0x8(%ebp),%eax
  801cce:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801cd3:	b8 04 00 00 00       	mov    $0x4,%eax
  801cd8:	e8 cb fe ff ff       	call   801ba8 <nsipc>
}
  801cdd:	c9                   	leave  
  801cde:	c3                   	ret    

00801cdf <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801cdf:	55                   	push   %ebp
  801ce0:	89 e5                	mov    %esp,%ebp
  801ce2:	53                   	push   %ebx
  801ce3:	83 ec 14             	sub    $0x14,%esp
  801ce6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801ce9:	8b 45 08             	mov    0x8(%ebp),%eax
  801cec:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801cf1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801cf5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cf8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cfc:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801d03:	e8 30 ed ff ff       	call   800a38 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801d08:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801d0e:	b8 05 00 00 00       	mov    $0x5,%eax
  801d13:	e8 90 fe ff ff       	call   801ba8 <nsipc>
}
  801d18:	83 c4 14             	add    $0x14,%esp
  801d1b:	5b                   	pop    %ebx
  801d1c:	5d                   	pop    %ebp
  801d1d:	c3                   	ret    

00801d1e <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801d1e:	55                   	push   %ebp
  801d1f:	89 e5                	mov    %esp,%ebp
  801d21:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801d24:	8b 45 08             	mov    0x8(%ebp),%eax
  801d27:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801d2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d2f:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801d34:	b8 06 00 00 00       	mov    $0x6,%eax
  801d39:	e8 6a fe ff ff       	call   801ba8 <nsipc>
}
  801d3e:	c9                   	leave  
  801d3f:	c3                   	ret    

00801d40 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801d40:	55                   	push   %ebp
  801d41:	89 e5                	mov    %esp,%ebp
  801d43:	56                   	push   %esi
  801d44:	53                   	push   %ebx
  801d45:	83 ec 10             	sub    $0x10,%esp
  801d48:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d4e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801d53:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801d59:	8b 45 14             	mov    0x14(%ebp),%eax
  801d5c:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d61:	b8 07 00 00 00       	mov    $0x7,%eax
  801d66:	e8 3d fe ff ff       	call   801ba8 <nsipc>
  801d6b:	89 c3                	mov    %eax,%ebx
  801d6d:	85 c0                	test   %eax,%eax
  801d6f:	78 46                	js     801db7 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801d71:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801d76:	7f 04                	jg     801d7c <nsipc_recv+0x3c>
  801d78:	39 c6                	cmp    %eax,%esi
  801d7a:	7d 24                	jge    801da0 <nsipc_recv+0x60>
  801d7c:	c7 44 24 0c a3 2b 80 	movl   $0x802ba3,0xc(%esp)
  801d83:	00 
  801d84:	c7 44 24 08 6b 2b 80 	movl   $0x802b6b,0x8(%esp)
  801d8b:	00 
  801d8c:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  801d93:	00 
  801d94:	c7 04 24 b8 2b 80 00 	movl   $0x802bb8,(%esp)
  801d9b:	e8 7c e4 ff ff       	call   80021c <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801da0:	89 44 24 08          	mov    %eax,0x8(%esp)
  801da4:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801dab:	00 
  801dac:	8b 45 0c             	mov    0xc(%ebp),%eax
  801daf:	89 04 24             	mov    %eax,(%esp)
  801db2:	e8 81 ec ff ff       	call   800a38 <memmove>
	}

	return r;
}
  801db7:	89 d8                	mov    %ebx,%eax
  801db9:	83 c4 10             	add    $0x10,%esp
  801dbc:	5b                   	pop    %ebx
  801dbd:	5e                   	pop    %esi
  801dbe:	5d                   	pop    %ebp
  801dbf:	c3                   	ret    

00801dc0 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801dc0:	55                   	push   %ebp
  801dc1:	89 e5                	mov    %esp,%ebp
  801dc3:	53                   	push   %ebx
  801dc4:	83 ec 14             	sub    $0x14,%esp
  801dc7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801dca:	8b 45 08             	mov    0x8(%ebp),%eax
  801dcd:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801dd2:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801dd8:	7e 24                	jle    801dfe <nsipc_send+0x3e>
  801dda:	c7 44 24 0c c4 2b 80 	movl   $0x802bc4,0xc(%esp)
  801de1:	00 
  801de2:	c7 44 24 08 6b 2b 80 	movl   $0x802b6b,0x8(%esp)
  801de9:	00 
  801dea:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  801df1:	00 
  801df2:	c7 04 24 b8 2b 80 00 	movl   $0x802bb8,(%esp)
  801df9:	e8 1e e4 ff ff       	call   80021c <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801dfe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e02:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e05:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e09:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  801e10:	e8 23 ec ff ff       	call   800a38 <memmove>
	nsipcbuf.send.req_size = size;
  801e15:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801e1b:	8b 45 14             	mov    0x14(%ebp),%eax
  801e1e:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801e23:	b8 08 00 00 00       	mov    $0x8,%eax
  801e28:	e8 7b fd ff ff       	call   801ba8 <nsipc>
}
  801e2d:	83 c4 14             	add    $0x14,%esp
  801e30:	5b                   	pop    %ebx
  801e31:	5d                   	pop    %ebp
  801e32:	c3                   	ret    

00801e33 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801e33:	55                   	push   %ebp
  801e34:	89 e5                	mov    %esp,%ebp
  801e36:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801e39:	8b 45 08             	mov    0x8(%ebp),%eax
  801e3c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801e41:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e44:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801e49:	8b 45 10             	mov    0x10(%ebp),%eax
  801e4c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801e51:	b8 09 00 00 00       	mov    $0x9,%eax
  801e56:	e8 4d fd ff ff       	call   801ba8 <nsipc>
}
  801e5b:	c9                   	leave  
  801e5c:	c3                   	ret    
  801e5d:	00 00                	add    %al,(%eax)
	...

00801e60 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e60:	55                   	push   %ebp
  801e61:	89 e5                	mov    %esp,%ebp
  801e63:	56                   	push   %esi
  801e64:	53                   	push   %ebx
  801e65:	83 ec 10             	sub    $0x10,%esp
  801e68:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e6b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e6e:	89 04 24             	mov    %eax,(%esp)
  801e71:	e8 36 f1 ff ff       	call   800fac <fd2data>
  801e76:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801e78:	c7 44 24 04 d0 2b 80 	movl   $0x802bd0,0x4(%esp)
  801e7f:	00 
  801e80:	89 34 24             	mov    %esi,(%esp)
  801e83:	e8 37 ea ff ff       	call   8008bf <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e88:	8b 43 04             	mov    0x4(%ebx),%eax
  801e8b:	2b 03                	sub    (%ebx),%eax
  801e8d:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801e93:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801e9a:	00 00 00 
	stat->st_dev = &devpipe;
  801e9d:	c7 86 88 00 00 00 40 	movl   $0x803040,0x88(%esi)
  801ea4:	30 80 00 
	return 0;
}
  801ea7:	b8 00 00 00 00       	mov    $0x0,%eax
  801eac:	83 c4 10             	add    $0x10,%esp
  801eaf:	5b                   	pop    %ebx
  801eb0:	5e                   	pop    %esi
  801eb1:	5d                   	pop    %ebp
  801eb2:	c3                   	ret    

00801eb3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801eb3:	55                   	push   %ebp
  801eb4:	89 e5                	mov    %esp,%ebp
  801eb6:	53                   	push   %ebx
  801eb7:	83 ec 14             	sub    $0x14,%esp
  801eba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ebd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ec1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ec8:	e8 8b ee ff ff       	call   800d58 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ecd:	89 1c 24             	mov    %ebx,(%esp)
  801ed0:	e8 d7 f0 ff ff       	call   800fac <fd2data>
  801ed5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ed9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ee0:	e8 73 ee ff ff       	call   800d58 <sys_page_unmap>
}
  801ee5:	83 c4 14             	add    $0x14,%esp
  801ee8:	5b                   	pop    %ebx
  801ee9:	5d                   	pop    %ebp
  801eea:	c3                   	ret    

00801eeb <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801eeb:	55                   	push   %ebp
  801eec:	89 e5                	mov    %esp,%ebp
  801eee:	57                   	push   %edi
  801eef:	56                   	push   %esi
  801ef0:	53                   	push   %ebx
  801ef1:	83 ec 2c             	sub    $0x2c,%esp
  801ef4:	89 c7                	mov    %eax,%edi
  801ef6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ef9:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801efe:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801f01:	89 3c 24             	mov    %edi,(%esp)
  801f04:	e8 7f 05 00 00       	call   802488 <pageref>
  801f09:	89 c6                	mov    %eax,%esi
  801f0b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f0e:	89 04 24             	mov    %eax,(%esp)
  801f11:	e8 72 05 00 00       	call   802488 <pageref>
  801f16:	39 c6                	cmp    %eax,%esi
  801f18:	0f 94 c0             	sete   %al
  801f1b:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801f1e:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  801f24:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f27:	39 cb                	cmp    %ecx,%ebx
  801f29:	75 08                	jne    801f33 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801f2b:	83 c4 2c             	add    $0x2c,%esp
  801f2e:	5b                   	pop    %ebx
  801f2f:	5e                   	pop    %esi
  801f30:	5f                   	pop    %edi
  801f31:	5d                   	pop    %ebp
  801f32:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801f33:	83 f8 01             	cmp    $0x1,%eax
  801f36:	75 c1                	jne    801ef9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f38:	8b 42 58             	mov    0x58(%edx),%eax
  801f3b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801f42:	00 
  801f43:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f47:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f4b:	c7 04 24 d7 2b 80 00 	movl   $0x802bd7,(%esp)
  801f52:	e8 bd e3 ff ff       	call   800314 <cprintf>
  801f57:	eb a0                	jmp    801ef9 <_pipeisclosed+0xe>

00801f59 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f59:	55                   	push   %ebp
  801f5a:	89 e5                	mov    %esp,%ebp
  801f5c:	57                   	push   %edi
  801f5d:	56                   	push   %esi
  801f5e:	53                   	push   %ebx
  801f5f:	83 ec 1c             	sub    $0x1c,%esp
  801f62:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f65:	89 34 24             	mov    %esi,(%esp)
  801f68:	e8 3f f0 ff ff       	call   800fac <fd2data>
  801f6d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f6f:	bf 00 00 00 00       	mov    $0x0,%edi
  801f74:	eb 3c                	jmp    801fb2 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f76:	89 da                	mov    %ebx,%edx
  801f78:	89 f0                	mov    %esi,%eax
  801f7a:	e8 6c ff ff ff       	call   801eeb <_pipeisclosed>
  801f7f:	85 c0                	test   %eax,%eax
  801f81:	75 38                	jne    801fbb <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f83:	e8 0a ed ff ff       	call   800c92 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f88:	8b 43 04             	mov    0x4(%ebx),%eax
  801f8b:	8b 13                	mov    (%ebx),%edx
  801f8d:	83 c2 20             	add    $0x20,%edx
  801f90:	39 d0                	cmp    %edx,%eax
  801f92:	73 e2                	jae    801f76 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f94:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f97:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801f9a:	89 c2                	mov    %eax,%edx
  801f9c:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801fa2:	79 05                	jns    801fa9 <devpipe_write+0x50>
  801fa4:	4a                   	dec    %edx
  801fa5:	83 ca e0             	or     $0xffffffe0,%edx
  801fa8:	42                   	inc    %edx
  801fa9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801fad:	40                   	inc    %eax
  801fae:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fb1:	47                   	inc    %edi
  801fb2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801fb5:	75 d1                	jne    801f88 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801fb7:	89 f8                	mov    %edi,%eax
  801fb9:	eb 05                	jmp    801fc0 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801fbb:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801fc0:	83 c4 1c             	add    $0x1c,%esp
  801fc3:	5b                   	pop    %ebx
  801fc4:	5e                   	pop    %esi
  801fc5:	5f                   	pop    %edi
  801fc6:	5d                   	pop    %ebp
  801fc7:	c3                   	ret    

00801fc8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fc8:	55                   	push   %ebp
  801fc9:	89 e5                	mov    %esp,%ebp
  801fcb:	57                   	push   %edi
  801fcc:	56                   	push   %esi
  801fcd:	53                   	push   %ebx
  801fce:	83 ec 1c             	sub    $0x1c,%esp
  801fd1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801fd4:	89 3c 24             	mov    %edi,(%esp)
  801fd7:	e8 d0 ef ff ff       	call   800fac <fd2data>
  801fdc:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fde:	be 00 00 00 00       	mov    $0x0,%esi
  801fe3:	eb 3a                	jmp    80201f <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801fe5:	85 f6                	test   %esi,%esi
  801fe7:	74 04                	je     801fed <devpipe_read+0x25>
				return i;
  801fe9:	89 f0                	mov    %esi,%eax
  801feb:	eb 40                	jmp    80202d <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801fed:	89 da                	mov    %ebx,%edx
  801fef:	89 f8                	mov    %edi,%eax
  801ff1:	e8 f5 fe ff ff       	call   801eeb <_pipeisclosed>
  801ff6:	85 c0                	test   %eax,%eax
  801ff8:	75 2e                	jne    802028 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ffa:	e8 93 ec ff ff       	call   800c92 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801fff:	8b 03                	mov    (%ebx),%eax
  802001:	3b 43 04             	cmp    0x4(%ebx),%eax
  802004:	74 df                	je     801fe5 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802006:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80200b:	79 05                	jns    802012 <devpipe_read+0x4a>
  80200d:	48                   	dec    %eax
  80200e:	83 c8 e0             	or     $0xffffffe0,%eax
  802011:	40                   	inc    %eax
  802012:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  802016:	8b 55 0c             	mov    0xc(%ebp),%edx
  802019:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  80201c:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80201e:	46                   	inc    %esi
  80201f:	3b 75 10             	cmp    0x10(%ebp),%esi
  802022:	75 db                	jne    801fff <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802024:	89 f0                	mov    %esi,%eax
  802026:	eb 05                	jmp    80202d <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802028:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80202d:	83 c4 1c             	add    $0x1c,%esp
  802030:	5b                   	pop    %ebx
  802031:	5e                   	pop    %esi
  802032:	5f                   	pop    %edi
  802033:	5d                   	pop    %ebp
  802034:	c3                   	ret    

00802035 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802035:	55                   	push   %ebp
  802036:	89 e5                	mov    %esp,%ebp
  802038:	57                   	push   %edi
  802039:	56                   	push   %esi
  80203a:	53                   	push   %ebx
  80203b:	83 ec 3c             	sub    $0x3c,%esp
  80203e:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802041:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802044:	89 04 24             	mov    %eax,(%esp)
  802047:	e8 7b ef ff ff       	call   800fc7 <fd_alloc>
  80204c:	89 c3                	mov    %eax,%ebx
  80204e:	85 c0                	test   %eax,%eax
  802050:	0f 88 45 01 00 00    	js     80219b <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802056:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80205d:	00 
  80205e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802061:	89 44 24 04          	mov    %eax,0x4(%esp)
  802065:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80206c:	e8 40 ec ff ff       	call   800cb1 <sys_page_alloc>
  802071:	89 c3                	mov    %eax,%ebx
  802073:	85 c0                	test   %eax,%eax
  802075:	0f 88 20 01 00 00    	js     80219b <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80207b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80207e:	89 04 24             	mov    %eax,(%esp)
  802081:	e8 41 ef ff ff       	call   800fc7 <fd_alloc>
  802086:	89 c3                	mov    %eax,%ebx
  802088:	85 c0                	test   %eax,%eax
  80208a:	0f 88 f8 00 00 00    	js     802188 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802090:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802097:	00 
  802098:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80209b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80209f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020a6:	e8 06 ec ff ff       	call   800cb1 <sys_page_alloc>
  8020ab:	89 c3                	mov    %eax,%ebx
  8020ad:	85 c0                	test   %eax,%eax
  8020af:	0f 88 d3 00 00 00    	js     802188 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8020b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020b8:	89 04 24             	mov    %eax,(%esp)
  8020bb:	e8 ec ee ff ff       	call   800fac <fd2data>
  8020c0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020c2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8020c9:	00 
  8020ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020ce:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020d5:	e8 d7 eb ff ff       	call   800cb1 <sys_page_alloc>
  8020da:	89 c3                	mov    %eax,%ebx
  8020dc:	85 c0                	test   %eax,%eax
  8020de:	0f 88 91 00 00 00    	js     802175 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8020e7:	89 04 24             	mov    %eax,(%esp)
  8020ea:	e8 bd ee ff ff       	call   800fac <fd2data>
  8020ef:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8020f6:	00 
  8020f7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020fb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802102:	00 
  802103:	89 74 24 04          	mov    %esi,0x4(%esp)
  802107:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80210e:	e8 f2 eb ff ff       	call   800d05 <sys_page_map>
  802113:	89 c3                	mov    %eax,%ebx
  802115:	85 c0                	test   %eax,%eax
  802117:	78 4c                	js     802165 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802119:	8b 15 40 30 80 00    	mov    0x803040,%edx
  80211f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802122:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802124:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802127:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80212e:	8b 15 40 30 80 00    	mov    0x803040,%edx
  802134:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802137:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802139:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80213c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802143:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802146:	89 04 24             	mov    %eax,(%esp)
  802149:	e8 4e ee ff ff       	call   800f9c <fd2num>
  80214e:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802150:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802153:	89 04 24             	mov    %eax,(%esp)
  802156:	e8 41 ee ff ff       	call   800f9c <fd2num>
  80215b:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  80215e:	bb 00 00 00 00       	mov    $0x0,%ebx
  802163:	eb 36                	jmp    80219b <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  802165:	89 74 24 04          	mov    %esi,0x4(%esp)
  802169:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802170:	e8 e3 eb ff ff       	call   800d58 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802175:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802178:	89 44 24 04          	mov    %eax,0x4(%esp)
  80217c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802183:	e8 d0 eb ff ff       	call   800d58 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802188:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80218b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80218f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802196:	e8 bd eb ff ff       	call   800d58 <sys_page_unmap>
    err:
	return r;
}
  80219b:	89 d8                	mov    %ebx,%eax
  80219d:	83 c4 3c             	add    $0x3c,%esp
  8021a0:	5b                   	pop    %ebx
  8021a1:	5e                   	pop    %esi
  8021a2:	5f                   	pop    %edi
  8021a3:	5d                   	pop    %ebp
  8021a4:	c3                   	ret    

008021a5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8021a5:	55                   	push   %ebp
  8021a6:	89 e5                	mov    %esp,%ebp
  8021a8:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8021b5:	89 04 24             	mov    %eax,(%esp)
  8021b8:	e8 5d ee ff ff       	call   80101a <fd_lookup>
  8021bd:	85 c0                	test   %eax,%eax
  8021bf:	78 15                	js     8021d6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8021c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021c4:	89 04 24             	mov    %eax,(%esp)
  8021c7:	e8 e0 ed ff ff       	call   800fac <fd2data>
	return _pipeisclosed(fd, p);
  8021cc:	89 c2                	mov    %eax,%edx
  8021ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021d1:	e8 15 fd ff ff       	call   801eeb <_pipeisclosed>
}
  8021d6:	c9                   	leave  
  8021d7:	c3                   	ret    

008021d8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8021d8:	55                   	push   %ebp
  8021d9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8021db:	b8 00 00 00 00       	mov    $0x0,%eax
  8021e0:	5d                   	pop    %ebp
  8021e1:	c3                   	ret    

008021e2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8021e2:	55                   	push   %ebp
  8021e3:	89 e5                	mov    %esp,%ebp
  8021e5:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8021e8:	c7 44 24 04 ef 2b 80 	movl   $0x802bef,0x4(%esp)
  8021ef:	00 
  8021f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021f3:	89 04 24             	mov    %eax,(%esp)
  8021f6:	e8 c4 e6 ff ff       	call   8008bf <strcpy>
	return 0;
}
  8021fb:	b8 00 00 00 00       	mov    $0x0,%eax
  802200:	c9                   	leave  
  802201:	c3                   	ret    

00802202 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802202:	55                   	push   %ebp
  802203:	89 e5                	mov    %esp,%ebp
  802205:	57                   	push   %edi
  802206:	56                   	push   %esi
  802207:	53                   	push   %ebx
  802208:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80220e:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802213:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802219:	eb 30                	jmp    80224b <devcons_write+0x49>
		m = n - tot;
  80221b:	8b 75 10             	mov    0x10(%ebp),%esi
  80221e:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802220:	83 fe 7f             	cmp    $0x7f,%esi
  802223:	76 05                	jbe    80222a <devcons_write+0x28>
			m = sizeof(buf) - 1;
  802225:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80222a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80222e:	03 45 0c             	add    0xc(%ebp),%eax
  802231:	89 44 24 04          	mov    %eax,0x4(%esp)
  802235:	89 3c 24             	mov    %edi,(%esp)
  802238:	e8 fb e7 ff ff       	call   800a38 <memmove>
		sys_cputs(buf, m);
  80223d:	89 74 24 04          	mov    %esi,0x4(%esp)
  802241:	89 3c 24             	mov    %edi,(%esp)
  802244:	e8 9b e9 ff ff       	call   800be4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802249:	01 f3                	add    %esi,%ebx
  80224b:	89 d8                	mov    %ebx,%eax
  80224d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802250:	72 c9                	jb     80221b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802252:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802258:	5b                   	pop    %ebx
  802259:	5e                   	pop    %esi
  80225a:	5f                   	pop    %edi
  80225b:	5d                   	pop    %ebp
  80225c:	c3                   	ret    

0080225d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80225d:	55                   	push   %ebp
  80225e:	89 e5                	mov    %esp,%ebp
  802260:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  802263:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802267:	75 07                	jne    802270 <devcons_read+0x13>
  802269:	eb 25                	jmp    802290 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80226b:	e8 22 ea ff ff       	call   800c92 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802270:	e8 8d e9 ff ff       	call   800c02 <sys_cgetc>
  802275:	85 c0                	test   %eax,%eax
  802277:	74 f2                	je     80226b <devcons_read+0xe>
  802279:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80227b:	85 c0                	test   %eax,%eax
  80227d:	78 1d                	js     80229c <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80227f:	83 f8 04             	cmp    $0x4,%eax
  802282:	74 13                	je     802297 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802284:	8b 45 0c             	mov    0xc(%ebp),%eax
  802287:	88 10                	mov    %dl,(%eax)
	return 1;
  802289:	b8 01 00 00 00       	mov    $0x1,%eax
  80228e:	eb 0c                	jmp    80229c <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802290:	b8 00 00 00 00       	mov    $0x0,%eax
  802295:	eb 05                	jmp    80229c <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802297:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80229c:	c9                   	leave  
  80229d:	c3                   	ret    

0080229e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80229e:	55                   	push   %ebp
  80229f:	89 e5                	mov    %esp,%ebp
  8022a1:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8022a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8022a7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8022aa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8022b1:	00 
  8022b2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022b5:	89 04 24             	mov    %eax,(%esp)
  8022b8:	e8 27 e9 ff ff       	call   800be4 <sys_cputs>
}
  8022bd:	c9                   	leave  
  8022be:	c3                   	ret    

008022bf <getchar>:

int
getchar(void)
{
  8022bf:	55                   	push   %ebp
  8022c0:	89 e5                	mov    %esp,%ebp
  8022c2:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8022c5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8022cc:	00 
  8022cd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022d4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022db:	e8 d6 ef ff ff       	call   8012b6 <read>
	if (r < 0)
  8022e0:	85 c0                	test   %eax,%eax
  8022e2:	78 0f                	js     8022f3 <getchar+0x34>
		return r;
	if (r < 1)
  8022e4:	85 c0                	test   %eax,%eax
  8022e6:	7e 06                	jle    8022ee <getchar+0x2f>
		return -E_EOF;
	return c;
  8022e8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8022ec:	eb 05                	jmp    8022f3 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8022ee:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8022f3:	c9                   	leave  
  8022f4:	c3                   	ret    

008022f5 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8022f5:	55                   	push   %ebp
  8022f6:	89 e5                	mov    %esp,%ebp
  8022f8:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  802302:	8b 45 08             	mov    0x8(%ebp),%eax
  802305:	89 04 24             	mov    %eax,(%esp)
  802308:	e8 0d ed ff ff       	call   80101a <fd_lookup>
  80230d:	85 c0                	test   %eax,%eax
  80230f:	78 11                	js     802322 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802311:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802314:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  80231a:	39 10                	cmp    %edx,(%eax)
  80231c:	0f 94 c0             	sete   %al
  80231f:	0f b6 c0             	movzbl %al,%eax
}
  802322:	c9                   	leave  
  802323:	c3                   	ret    

00802324 <opencons>:

int
opencons(void)
{
  802324:	55                   	push   %ebp
  802325:	89 e5                	mov    %esp,%ebp
  802327:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80232a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80232d:	89 04 24             	mov    %eax,(%esp)
  802330:	e8 92 ec ff ff       	call   800fc7 <fd_alloc>
  802335:	85 c0                	test   %eax,%eax
  802337:	78 3c                	js     802375 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802339:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802340:	00 
  802341:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802344:	89 44 24 04          	mov    %eax,0x4(%esp)
  802348:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80234f:	e8 5d e9 ff ff       	call   800cb1 <sys_page_alloc>
  802354:	85 c0                	test   %eax,%eax
  802356:	78 1d                	js     802375 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802358:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  80235e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802361:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802363:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802366:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80236d:	89 04 24             	mov    %eax,(%esp)
  802370:	e8 27 ec ff ff       	call   800f9c <fd2num>
}
  802375:	c9                   	leave  
  802376:	c3                   	ret    
	...

00802378 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802378:	55                   	push   %ebp
  802379:	89 e5                	mov    %esp,%ebp
  80237b:	56                   	push   %esi
  80237c:	53                   	push   %ebx
  80237d:	83 ec 10             	sub    $0x10,%esp
  802380:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802383:	8b 45 0c             	mov    0xc(%ebp),%eax
  802386:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int r;
		
	r = sys_ipc_recv(pg?pg:(void*)UTOP);
  802389:	85 c0                	test   %eax,%eax
  80238b:	75 05                	jne    802392 <ipc_recv+0x1a>
  80238d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802392:	89 04 24             	mov    %eax,(%esp)
  802395:	e8 2d eb ff ff       	call   800ec7 <sys_ipc_recv>
	if (from_env_store != NULL)
  80239a:	85 db                	test   %ebx,%ebx
  80239c:	74 0b                	je     8023a9 <ipc_recv+0x31>
		*from_env_store = thisenv->env_ipc_from; 
  80239e:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  8023a4:	8b 52 74             	mov    0x74(%edx),%edx
  8023a7:	89 13                	mov    %edx,(%ebx)
	if (perm_store != NULL)
  8023a9:	85 f6                	test   %esi,%esi
  8023ab:	74 0b                	je     8023b8 <ipc_recv+0x40>
		*perm_store = thisenv->env_ipc_perm;
  8023ad:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  8023b3:	8b 52 78             	mov    0x78(%edx),%edx
  8023b6:	89 16                	mov    %edx,(%esi)
	
	if (r < 0){
  8023b8:	85 c0                	test   %eax,%eax
  8023ba:	79 16                	jns    8023d2 <ipc_recv+0x5a>
		if(from_env_store != NULL)
  8023bc:	85 db                	test   %ebx,%ebx
  8023be:	74 06                	je     8023c6 <ipc_recv+0x4e>
			*from_env_store = 0;
  8023c0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store != NULL)	
  8023c6:	85 f6                	test   %esi,%esi
  8023c8:	74 10                	je     8023da <ipc_recv+0x62>
			*perm_store = 0;
  8023ca:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8023d0:	eb 08                	jmp    8023da <ipc_recv+0x62>
		return r;
	}
	
	return thisenv->env_ipc_value;
  8023d2:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8023d7:	8b 40 70             	mov    0x70(%eax),%eax
}
  8023da:	83 c4 10             	add    $0x10,%esp
  8023dd:	5b                   	pop    %ebx
  8023de:	5e                   	pop    %esi
  8023df:	5d                   	pop    %ebp
  8023e0:	c3                   	ret    

008023e1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8023e1:	55                   	push   %ebp
  8023e2:	89 e5                	mov    %esp,%ebp
  8023e4:	57                   	push   %edi
  8023e5:	56                   	push   %esi
  8023e6:	53                   	push   %ebx
  8023e7:	83 ec 1c             	sub    $0x1c,%esp
  8023ea:	8b 75 08             	mov    0x8(%ebp),%esi
  8023ed:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8023f0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  8023f3:	eb 2a                	jmp    80241f <ipc_send+0x3e>
		if (r != -E_IPC_NOT_RECV)
  8023f5:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8023f8:	74 20                	je     80241a <ipc_send+0x39>
			panic("ipc_send: sys_ipc_try_send failed %e", r);
  8023fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023fe:	c7 44 24 08 fc 2b 80 	movl   $0x802bfc,0x8(%esp)
  802405:	00 
  802406:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  80240d:	00 
  80240e:	c7 04 24 24 2c 80 00 	movl   $0x802c24,(%esp)
  802415:	e8 02 de ff ff       	call   80021c <_panic>
		sys_yield();
  80241a:	e8 73 e8 ff ff       	call   800c92 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  80241f:	85 db                	test   %ebx,%ebx
  802421:	75 07                	jne    80242a <ipc_send+0x49>
  802423:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802428:	eb 02                	jmp    80242c <ipc_send+0x4b>
  80242a:	89 d8                	mov    %ebx,%eax
  80242c:	8b 55 14             	mov    0x14(%ebp),%edx
  80242f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802433:	89 44 24 08          	mov    %eax,0x8(%esp)
  802437:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80243b:	89 34 24             	mov    %esi,(%esp)
  80243e:	e8 61 ea ff ff       	call   800ea4 <sys_ipc_try_send>
  802443:	85 c0                	test   %eax,%eax
  802445:	78 ae                	js     8023f5 <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: sys_ipc_try_send failed %e", r);
		sys_yield();
	}
}
  802447:	83 c4 1c             	add    $0x1c,%esp
  80244a:	5b                   	pop    %ebx
  80244b:	5e                   	pop    %esi
  80244c:	5f                   	pop    %edi
  80244d:	5d                   	pop    %ebp
  80244e:	c3                   	ret    

0080244f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80244f:	55                   	push   %ebp
  802450:	89 e5                	mov    %esp,%ebp
  802452:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802455:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80245a:	89 c2                	mov    %eax,%edx
  80245c:	c1 e2 07             	shl    $0x7,%edx
  80245f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802465:	8b 52 50             	mov    0x50(%edx),%edx
  802468:	39 ca                	cmp    %ecx,%edx
  80246a:	75 0d                	jne    802479 <ipc_find_env+0x2a>
			return envs[i].env_id;
  80246c:	c1 e0 07             	shl    $0x7,%eax
  80246f:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802474:	8b 40 40             	mov    0x40(%eax),%eax
  802477:	eb 0c                	jmp    802485 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802479:	40                   	inc    %eax
  80247a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80247f:	75 d9                	jne    80245a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802481:	66 b8 00 00          	mov    $0x0,%ax
}
  802485:	5d                   	pop    %ebp
  802486:	c3                   	ret    
	...

00802488 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802488:	55                   	push   %ebp
  802489:	89 e5                	mov    %esp,%ebp
  80248b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80248e:	89 c2                	mov    %eax,%edx
  802490:	c1 ea 16             	shr    $0x16,%edx
  802493:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80249a:	f6 c2 01             	test   $0x1,%dl
  80249d:	74 1e                	je     8024bd <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  80249f:	c1 e8 0c             	shr    $0xc,%eax
  8024a2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8024a9:	a8 01                	test   $0x1,%al
  8024ab:	74 17                	je     8024c4 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8024ad:	c1 e8 0c             	shr    $0xc,%eax
  8024b0:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8024b7:	ef 
  8024b8:	0f b7 c0             	movzwl %ax,%eax
  8024bb:	eb 0c                	jmp    8024c9 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8024bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8024c2:	eb 05                	jmp    8024c9 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8024c4:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8024c9:	5d                   	pop    %ebp
  8024ca:	c3                   	ret    
	...

008024cc <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8024cc:	55                   	push   %ebp
  8024cd:	57                   	push   %edi
  8024ce:	56                   	push   %esi
  8024cf:	83 ec 10             	sub    $0x10,%esp
  8024d2:	8b 74 24 20          	mov    0x20(%esp),%esi
  8024d6:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8024da:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024de:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  8024e2:	89 cd                	mov    %ecx,%ebp
  8024e4:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8024e8:	85 c0                	test   %eax,%eax
  8024ea:	75 2c                	jne    802518 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8024ec:	39 f9                	cmp    %edi,%ecx
  8024ee:	77 68                	ja     802558 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8024f0:	85 c9                	test   %ecx,%ecx
  8024f2:	75 0b                	jne    8024ff <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8024f4:	b8 01 00 00 00       	mov    $0x1,%eax
  8024f9:	31 d2                	xor    %edx,%edx
  8024fb:	f7 f1                	div    %ecx
  8024fd:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8024ff:	31 d2                	xor    %edx,%edx
  802501:	89 f8                	mov    %edi,%eax
  802503:	f7 f1                	div    %ecx
  802505:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802507:	89 f0                	mov    %esi,%eax
  802509:	f7 f1                	div    %ecx
  80250b:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80250d:	89 f0                	mov    %esi,%eax
  80250f:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802511:	83 c4 10             	add    $0x10,%esp
  802514:	5e                   	pop    %esi
  802515:	5f                   	pop    %edi
  802516:	5d                   	pop    %ebp
  802517:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802518:	39 f8                	cmp    %edi,%eax
  80251a:	77 2c                	ja     802548 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80251c:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  80251f:	83 f6 1f             	xor    $0x1f,%esi
  802522:	75 4c                	jne    802570 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802524:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802526:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80252b:	72 0a                	jb     802537 <__udivdi3+0x6b>
  80252d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802531:	0f 87 ad 00 00 00    	ja     8025e4 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802537:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80253c:	89 f0                	mov    %esi,%eax
  80253e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802540:	83 c4 10             	add    $0x10,%esp
  802543:	5e                   	pop    %esi
  802544:	5f                   	pop    %edi
  802545:	5d                   	pop    %ebp
  802546:	c3                   	ret    
  802547:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802548:	31 ff                	xor    %edi,%edi
  80254a:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80254c:	89 f0                	mov    %esi,%eax
  80254e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802550:	83 c4 10             	add    $0x10,%esp
  802553:	5e                   	pop    %esi
  802554:	5f                   	pop    %edi
  802555:	5d                   	pop    %ebp
  802556:	c3                   	ret    
  802557:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802558:	89 fa                	mov    %edi,%edx
  80255a:	89 f0                	mov    %esi,%eax
  80255c:	f7 f1                	div    %ecx
  80255e:	89 c6                	mov    %eax,%esi
  802560:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802562:	89 f0                	mov    %esi,%eax
  802564:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802566:	83 c4 10             	add    $0x10,%esp
  802569:	5e                   	pop    %esi
  80256a:	5f                   	pop    %edi
  80256b:	5d                   	pop    %ebp
  80256c:	c3                   	ret    
  80256d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802570:	89 f1                	mov    %esi,%ecx
  802572:	d3 e0                	shl    %cl,%eax
  802574:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802578:	b8 20 00 00 00       	mov    $0x20,%eax
  80257d:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80257f:	89 ea                	mov    %ebp,%edx
  802581:	88 c1                	mov    %al,%cl
  802583:	d3 ea                	shr    %cl,%edx
  802585:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802589:	09 ca                	or     %ecx,%edx
  80258b:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  80258f:	89 f1                	mov    %esi,%ecx
  802591:	d3 e5                	shl    %cl,%ebp
  802593:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  802597:	89 fd                	mov    %edi,%ebp
  802599:	88 c1                	mov    %al,%cl
  80259b:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  80259d:	89 fa                	mov    %edi,%edx
  80259f:	89 f1                	mov    %esi,%ecx
  8025a1:	d3 e2                	shl    %cl,%edx
  8025a3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8025a7:	88 c1                	mov    %al,%cl
  8025a9:	d3 ef                	shr    %cl,%edi
  8025ab:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8025ad:	89 f8                	mov    %edi,%eax
  8025af:	89 ea                	mov    %ebp,%edx
  8025b1:	f7 74 24 08          	divl   0x8(%esp)
  8025b5:	89 d1                	mov    %edx,%ecx
  8025b7:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  8025b9:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8025bd:	39 d1                	cmp    %edx,%ecx
  8025bf:	72 17                	jb     8025d8 <__udivdi3+0x10c>
  8025c1:	74 09                	je     8025cc <__udivdi3+0x100>
  8025c3:	89 fe                	mov    %edi,%esi
  8025c5:	31 ff                	xor    %edi,%edi
  8025c7:	e9 41 ff ff ff       	jmp    80250d <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8025cc:	8b 54 24 04          	mov    0x4(%esp),%edx
  8025d0:	89 f1                	mov    %esi,%ecx
  8025d2:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8025d4:	39 c2                	cmp    %eax,%edx
  8025d6:	73 eb                	jae    8025c3 <__udivdi3+0xf7>
		{
		  q0--;
  8025d8:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8025db:	31 ff                	xor    %edi,%edi
  8025dd:	e9 2b ff ff ff       	jmp    80250d <__udivdi3+0x41>
  8025e2:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8025e4:	31 f6                	xor    %esi,%esi
  8025e6:	e9 22 ff ff ff       	jmp    80250d <__udivdi3+0x41>
	...

008025ec <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8025ec:	55                   	push   %ebp
  8025ed:	57                   	push   %edi
  8025ee:	56                   	push   %esi
  8025ef:	83 ec 20             	sub    $0x20,%esp
  8025f2:	8b 44 24 30          	mov    0x30(%esp),%eax
  8025f6:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8025fa:	89 44 24 14          	mov    %eax,0x14(%esp)
  8025fe:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  802602:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802606:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80260a:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  80260c:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80260e:	85 ed                	test   %ebp,%ebp
  802610:	75 16                	jne    802628 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  802612:	39 f1                	cmp    %esi,%ecx
  802614:	0f 86 a6 00 00 00    	jbe    8026c0 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80261a:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  80261c:	89 d0                	mov    %edx,%eax
  80261e:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802620:	83 c4 20             	add    $0x20,%esp
  802623:	5e                   	pop    %esi
  802624:	5f                   	pop    %edi
  802625:	5d                   	pop    %ebp
  802626:	c3                   	ret    
  802627:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802628:	39 f5                	cmp    %esi,%ebp
  80262a:	0f 87 ac 00 00 00    	ja     8026dc <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802630:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  802633:	83 f0 1f             	xor    $0x1f,%eax
  802636:	89 44 24 10          	mov    %eax,0x10(%esp)
  80263a:	0f 84 a8 00 00 00    	je     8026e8 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802640:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802644:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802646:	bf 20 00 00 00       	mov    $0x20,%edi
  80264b:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80264f:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802653:	89 f9                	mov    %edi,%ecx
  802655:	d3 e8                	shr    %cl,%eax
  802657:	09 e8                	or     %ebp,%eax
  802659:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  80265d:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802661:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802665:	d3 e0                	shl    %cl,%eax
  802667:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80266b:	89 f2                	mov    %esi,%edx
  80266d:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80266f:	8b 44 24 14          	mov    0x14(%esp),%eax
  802673:	d3 e0                	shl    %cl,%eax
  802675:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802679:	8b 44 24 14          	mov    0x14(%esp),%eax
  80267d:	89 f9                	mov    %edi,%ecx
  80267f:	d3 e8                	shr    %cl,%eax
  802681:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802683:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802685:	89 f2                	mov    %esi,%edx
  802687:	f7 74 24 18          	divl   0x18(%esp)
  80268b:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80268d:	f7 64 24 0c          	mull   0xc(%esp)
  802691:	89 c5                	mov    %eax,%ebp
  802693:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802695:	39 d6                	cmp    %edx,%esi
  802697:	72 67                	jb     802700 <__umoddi3+0x114>
  802699:	74 75                	je     802710 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80269b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80269f:	29 e8                	sub    %ebp,%eax
  8026a1:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8026a3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8026a7:	d3 e8                	shr    %cl,%eax
  8026a9:	89 f2                	mov    %esi,%edx
  8026ab:	89 f9                	mov    %edi,%ecx
  8026ad:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8026af:	09 d0                	or     %edx,%eax
  8026b1:	89 f2                	mov    %esi,%edx
  8026b3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8026b7:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8026b9:	83 c4 20             	add    $0x20,%esp
  8026bc:	5e                   	pop    %esi
  8026bd:	5f                   	pop    %edi
  8026be:	5d                   	pop    %ebp
  8026bf:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8026c0:	85 c9                	test   %ecx,%ecx
  8026c2:	75 0b                	jne    8026cf <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8026c4:	b8 01 00 00 00       	mov    $0x1,%eax
  8026c9:	31 d2                	xor    %edx,%edx
  8026cb:	f7 f1                	div    %ecx
  8026cd:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8026cf:	89 f0                	mov    %esi,%eax
  8026d1:	31 d2                	xor    %edx,%edx
  8026d3:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8026d5:	89 f8                	mov    %edi,%eax
  8026d7:	e9 3e ff ff ff       	jmp    80261a <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8026dc:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8026de:	83 c4 20             	add    $0x20,%esp
  8026e1:	5e                   	pop    %esi
  8026e2:	5f                   	pop    %edi
  8026e3:	5d                   	pop    %ebp
  8026e4:	c3                   	ret    
  8026e5:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8026e8:	39 f5                	cmp    %esi,%ebp
  8026ea:	72 04                	jb     8026f0 <__umoddi3+0x104>
  8026ec:	39 f9                	cmp    %edi,%ecx
  8026ee:	77 06                	ja     8026f6 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8026f0:	89 f2                	mov    %esi,%edx
  8026f2:	29 cf                	sub    %ecx,%edi
  8026f4:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8026f6:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8026f8:	83 c4 20             	add    $0x20,%esp
  8026fb:	5e                   	pop    %esi
  8026fc:	5f                   	pop    %edi
  8026fd:	5d                   	pop    %ebp
  8026fe:	c3                   	ret    
  8026ff:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802700:	89 d1                	mov    %edx,%ecx
  802702:	89 c5                	mov    %eax,%ebp
  802704:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802708:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  80270c:	eb 8d                	jmp    80269b <__umoddi3+0xaf>
  80270e:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802710:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802714:	72 ea                	jb     802700 <__umoddi3+0x114>
  802716:	89 f1                	mov    %esi,%ecx
  802718:	eb 81                	jmp    80269b <__umoddi3+0xaf>
