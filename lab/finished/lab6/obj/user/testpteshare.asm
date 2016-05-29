
obj/user/testpteshare.debug:     file format elf32-i386


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
  80002c:	e8 8b 01 00 00       	call   8001bc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <childofspawn>:
	breakpoint();
}

void
childofspawn(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	strcpy(VA, msg2);
  80003a:	a1 00 40 80 00       	mov    0x804000,%eax
  80003f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800043:	c7 04 24 00 00 00 a0 	movl   $0xa0000000,(%esp)
  80004a:	e8 6c 08 00 00       	call   8008bb <strcpy>
	exit();
  80004f:	e8 b0 01 00 00       	call   800204 <exit>
}
  800054:	c9                   	leave  
  800055:	c3                   	ret    

00800056 <umain>:

void childofspawn(void);

void
umain(int argc, char **argv)
{
  800056:	55                   	push   %ebp
  800057:	89 e5                	mov    %esp,%ebp
  800059:	53                   	push   %ebx
  80005a:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (argc != 0)
  80005d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800061:	74 05                	je     800068 <umain+0x12>
		childofspawn();
  800063:	e8 cc ff ff ff       	call   800034 <childofspawn>

	if ((r = sys_page_alloc(0, VA, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800068:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80006f:	00 
  800070:	c7 44 24 04 00 00 00 	movl   $0xa0000000,0x4(%esp)
  800077:	a0 
  800078:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80007f:	e8 29 0c 00 00       	call   800cad <sys_page_alloc>
  800084:	85 c0                	test   %eax,%eax
  800086:	79 20                	jns    8000a8 <umain+0x52>
		panic("sys_page_alloc: %e", r);
  800088:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80008c:	c7 44 24 08 6c 31 80 	movl   $0x80316c,0x8(%esp)
  800093:	00 
  800094:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
  80009b:	00 
  80009c:	c7 04 24 7f 31 80 00 	movl   $0x80317f,(%esp)
  8000a3:	e8 70 01 00 00       	call   800218 <_panic>

	// check fork
	if ((r = fork()) < 0)
  8000a8:	e8 fa 0f 00 00       	call   8010a7 <fork>
  8000ad:	89 c3                	mov    %eax,%ebx
  8000af:	85 c0                	test   %eax,%eax
  8000b1:	79 20                	jns    8000d3 <umain+0x7d>
		panic("fork: %e", r);
  8000b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b7:	c7 44 24 08 93 31 80 	movl   $0x803193,0x8(%esp)
  8000be:	00 
  8000bf:	c7 44 24 04 17 00 00 	movl   $0x17,0x4(%esp)
  8000c6:	00 
  8000c7:	c7 04 24 7f 31 80 00 	movl   $0x80317f,(%esp)
  8000ce:	e8 45 01 00 00       	call   800218 <_panic>
	if (r == 0) {
  8000d3:	85 c0                	test   %eax,%eax
  8000d5:	75 1a                	jne    8000f1 <umain+0x9b>
		strcpy(VA, msg);
  8000d7:	a1 04 40 80 00       	mov    0x804004,%eax
  8000dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000e0:	c7 04 24 00 00 00 a0 	movl   $0xa0000000,(%esp)
  8000e7:	e8 cf 07 00 00       	call   8008bb <strcpy>
		exit();
  8000ec:	e8 13 01 00 00       	call   800204 <exit>
	}
	wait(r);
  8000f1:	89 1c 24             	mov    %ebx,(%esp)
  8000f4:	e8 0f 19 00 00       	call   801a08 <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000f9:	a1 04 40 80 00       	mov    0x804004,%eax
  8000fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800102:	c7 04 24 00 00 00 a0 	movl   $0xa0000000,(%esp)
  800109:	e8 54 08 00 00       	call   800962 <strcmp>
  80010e:	85 c0                	test   %eax,%eax
  800110:	75 07                	jne    800119 <umain+0xc3>
  800112:	b8 60 31 80 00       	mov    $0x803160,%eax
  800117:	eb 05                	jmp    80011e <umain+0xc8>
  800119:	b8 66 31 80 00       	mov    $0x803166,%eax
  80011e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800122:	c7 04 24 9c 31 80 00 	movl   $0x80319c,(%esp)
  800129:	e8 e2 01 00 00       	call   800310 <cprintf>

	// check spawn
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  80012e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800135:	00 
  800136:	c7 44 24 08 b7 31 80 	movl   $0x8031b7,0x8(%esp)
  80013d:	00 
  80013e:	c7 44 24 04 bc 31 80 	movl   $0x8031bc,0x4(%esp)
  800145:	00 
  800146:	c7 04 24 bb 31 80 00 	movl   $0x8031bb,(%esp)
  80014d:	e8 48 18 00 00       	call   80199a <spawnl>
  800152:	85 c0                	test   %eax,%eax
  800154:	79 20                	jns    800176 <umain+0x120>
		panic("spawn: %e", r);
  800156:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80015a:	c7 44 24 08 c9 31 80 	movl   $0x8031c9,0x8(%esp)
  800161:	00 
  800162:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  800169:	00 
  80016a:	c7 04 24 7f 31 80 00 	movl   $0x80317f,(%esp)
  800171:	e8 a2 00 00 00       	call   800218 <_panic>
	wait(r);
  800176:	89 04 24             	mov    %eax,(%esp)
  800179:	e8 8a 18 00 00       	call   801a08 <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  80017e:	a1 00 40 80 00       	mov    0x804000,%eax
  800183:	89 44 24 04          	mov    %eax,0x4(%esp)
  800187:	c7 04 24 00 00 00 a0 	movl   $0xa0000000,(%esp)
  80018e:	e8 cf 07 00 00       	call   800962 <strcmp>
  800193:	85 c0                	test   %eax,%eax
  800195:	75 07                	jne    80019e <umain+0x148>
  800197:	b8 60 31 80 00       	mov    $0x803160,%eax
  80019c:	eb 05                	jmp    8001a3 <umain+0x14d>
  80019e:	b8 66 31 80 00       	mov    $0x803166,%eax
  8001a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a7:	c7 04 24 d3 31 80 00 	movl   $0x8031d3,(%esp)
  8001ae:	e8 5d 01 00 00       	call   800310 <cprintf>
static __inline uint64_t read_tsc(void) __attribute__((always_inline));

static __inline void
breakpoint(void)
{
	__asm __volatile("int3");
  8001b3:	cc                   	int3   

	breakpoint();
}
  8001b4:	83 c4 14             	add    $0x14,%esp
  8001b7:	5b                   	pop    %ebx
  8001b8:	5d                   	pop    %ebp
  8001b9:	c3                   	ret    
	...

008001bc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	56                   	push   %esi
  8001c0:	53                   	push   %ebx
  8001c1:	83 ec 10             	sub    $0x10,%esp
  8001c4:	8b 75 08             	mov    0x8(%ebp),%esi
  8001c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001ca:	e8 a0 0a 00 00       	call   800c6f <sys_getenvid>
  8001cf:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001d4:	c1 e0 07             	shl    $0x7,%eax
  8001d7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001dc:	a3 08 50 80 00       	mov    %eax,0x805008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001e1:	85 f6                	test   %esi,%esi
  8001e3:	7e 07                	jle    8001ec <libmain+0x30>
		binaryname = argv[0];
  8001e5:	8b 03                	mov    (%ebx),%eax
  8001e7:	a3 08 40 80 00       	mov    %eax,0x804008

	// call user main routine
	umain(argc, argv);
  8001ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001f0:	89 34 24             	mov    %esi,(%esp)
  8001f3:	e8 5e fe ff ff       	call   800056 <umain>

	// exit gracefully
	exit();
  8001f8:	e8 07 00 00 00       	call   800204 <exit>
}
  8001fd:	83 c4 10             	add    $0x10,%esp
  800200:	5b                   	pop    %ebx
  800201:	5e                   	pop    %esi
  800202:	5d                   	pop    %ebp
  800203:	c3                   	ret    

00800204 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800204:	55                   	push   %ebp
  800205:	89 e5                	mov    %esp,%ebp
  800207:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  80020a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800211:	e8 07 0a 00 00       	call   800c1d <sys_env_destroy>
}
  800216:	c9                   	leave  
  800217:	c3                   	ret    

00800218 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
  80021b:	56                   	push   %esi
  80021c:	53                   	push   %ebx
  80021d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800220:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800223:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  800229:	e8 41 0a 00 00       	call   800c6f <sys_getenvid>
  80022e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800231:	89 54 24 10          	mov    %edx,0x10(%esp)
  800235:	8b 55 08             	mov    0x8(%ebp),%edx
  800238:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80023c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800240:	89 44 24 04          	mov    %eax,0x4(%esp)
  800244:	c7 04 24 18 32 80 00 	movl   $0x803218,(%esp)
  80024b:	e8 c0 00 00 00       	call   800310 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800250:	89 74 24 04          	mov    %esi,0x4(%esp)
  800254:	8b 45 10             	mov    0x10(%ebp),%eax
  800257:	89 04 24             	mov    %eax,(%esp)
  80025a:	e8 50 00 00 00       	call   8002af <vcprintf>
	cprintf("\n");
  80025f:	c7 04 24 8f 38 80 00 	movl   $0x80388f,(%esp)
  800266:	e8 a5 00 00 00       	call   800310 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80026b:	cc                   	int3   
  80026c:	eb fd                	jmp    80026b <_panic+0x53>
	...

00800270 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	53                   	push   %ebx
  800274:	83 ec 14             	sub    $0x14,%esp
  800277:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80027a:	8b 03                	mov    (%ebx),%eax
  80027c:	8b 55 08             	mov    0x8(%ebp),%edx
  80027f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800283:	40                   	inc    %eax
  800284:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800286:	3d ff 00 00 00       	cmp    $0xff,%eax
  80028b:	75 19                	jne    8002a6 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80028d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800294:	00 
  800295:	8d 43 08             	lea    0x8(%ebx),%eax
  800298:	89 04 24             	mov    %eax,(%esp)
  80029b:	e8 40 09 00 00       	call   800be0 <sys_cputs>
		b->idx = 0;
  8002a0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8002a6:	ff 43 04             	incl   0x4(%ebx)
}
  8002a9:	83 c4 14             	add    $0x14,%esp
  8002ac:	5b                   	pop    %ebx
  8002ad:	5d                   	pop    %ebp
  8002ae:	c3                   	ret    

008002af <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002af:	55                   	push   %ebp
  8002b0:	89 e5                	mov    %esp,%ebp
  8002b2:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8002b8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002bf:	00 00 00 
	b.cnt = 0;
  8002c2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002c9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002da:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e4:	c7 04 24 70 02 80 00 	movl   $0x800270,(%esp)
  8002eb:	e8 82 01 00 00       	call   800472 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002f0:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002fa:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800300:	89 04 24             	mov    %eax,(%esp)
  800303:	e8 d8 08 00 00       	call   800be0 <sys_cputs>

	return b.cnt;
}
  800308:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80030e:	c9                   	leave  
  80030f:	c3                   	ret    

00800310 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800310:	55                   	push   %ebp
  800311:	89 e5                	mov    %esp,%ebp
  800313:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800316:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800319:	89 44 24 04          	mov    %eax,0x4(%esp)
  80031d:	8b 45 08             	mov    0x8(%ebp),%eax
  800320:	89 04 24             	mov    %eax,(%esp)
  800323:	e8 87 ff ff ff       	call   8002af <vcprintf>
	va_end(ap);

	return cnt;
}
  800328:	c9                   	leave  
  800329:	c3                   	ret    
	...

0080032c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80032c:	55                   	push   %ebp
  80032d:	89 e5                	mov    %esp,%ebp
  80032f:	57                   	push   %edi
  800330:	56                   	push   %esi
  800331:	53                   	push   %ebx
  800332:	83 ec 3c             	sub    $0x3c,%esp
  800335:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800338:	89 d7                	mov    %edx,%edi
  80033a:	8b 45 08             	mov    0x8(%ebp),%eax
  80033d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800340:	8b 45 0c             	mov    0xc(%ebp),%eax
  800343:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800346:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800349:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80034c:	85 c0                	test   %eax,%eax
  80034e:	75 08                	jne    800358 <printnum+0x2c>
  800350:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800353:	39 45 10             	cmp    %eax,0x10(%ebp)
  800356:	77 57                	ja     8003af <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800358:	89 74 24 10          	mov    %esi,0x10(%esp)
  80035c:	4b                   	dec    %ebx
  80035d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800361:	8b 45 10             	mov    0x10(%ebp),%eax
  800364:	89 44 24 08          	mov    %eax,0x8(%esp)
  800368:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80036c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800370:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800377:	00 
  800378:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80037b:	89 04 24             	mov    %eax,(%esp)
  80037e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800381:	89 44 24 04          	mov    %eax,0x4(%esp)
  800385:	e8 6e 2b 00 00       	call   802ef8 <__udivdi3>
  80038a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80038e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800392:	89 04 24             	mov    %eax,(%esp)
  800395:	89 54 24 04          	mov    %edx,0x4(%esp)
  800399:	89 fa                	mov    %edi,%edx
  80039b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80039e:	e8 89 ff ff ff       	call   80032c <printnum>
  8003a3:	eb 0f                	jmp    8003b4 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003a5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003a9:	89 34 24             	mov    %esi,(%esp)
  8003ac:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003af:	4b                   	dec    %ebx
  8003b0:	85 db                	test   %ebx,%ebx
  8003b2:	7f f1                	jg     8003a5 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003b4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003b8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8003bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8003bf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003c3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003ca:	00 
  8003cb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003ce:	89 04 24             	mov    %eax,(%esp)
  8003d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003d8:	e8 3b 2c 00 00       	call   803018 <__umoddi3>
  8003dd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003e1:	0f be 80 3b 32 80 00 	movsbl 0x80323b(%eax),%eax
  8003e8:	89 04 24             	mov    %eax,(%esp)
  8003eb:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8003ee:	83 c4 3c             	add    $0x3c,%esp
  8003f1:	5b                   	pop    %ebx
  8003f2:	5e                   	pop    %esi
  8003f3:	5f                   	pop    %edi
  8003f4:	5d                   	pop    %ebp
  8003f5:	c3                   	ret    

008003f6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003f6:	55                   	push   %ebp
  8003f7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003f9:	83 fa 01             	cmp    $0x1,%edx
  8003fc:	7e 0e                	jle    80040c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003fe:	8b 10                	mov    (%eax),%edx
  800400:	8d 4a 08             	lea    0x8(%edx),%ecx
  800403:	89 08                	mov    %ecx,(%eax)
  800405:	8b 02                	mov    (%edx),%eax
  800407:	8b 52 04             	mov    0x4(%edx),%edx
  80040a:	eb 22                	jmp    80042e <getuint+0x38>
	else if (lflag)
  80040c:	85 d2                	test   %edx,%edx
  80040e:	74 10                	je     800420 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800410:	8b 10                	mov    (%eax),%edx
  800412:	8d 4a 04             	lea    0x4(%edx),%ecx
  800415:	89 08                	mov    %ecx,(%eax)
  800417:	8b 02                	mov    (%edx),%eax
  800419:	ba 00 00 00 00       	mov    $0x0,%edx
  80041e:	eb 0e                	jmp    80042e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800420:	8b 10                	mov    (%eax),%edx
  800422:	8d 4a 04             	lea    0x4(%edx),%ecx
  800425:	89 08                	mov    %ecx,(%eax)
  800427:	8b 02                	mov    (%edx),%eax
  800429:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80042e:	5d                   	pop    %ebp
  80042f:	c3                   	ret    

00800430 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800430:	55                   	push   %ebp
  800431:	89 e5                	mov    %esp,%ebp
  800433:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800436:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800439:	8b 10                	mov    (%eax),%edx
  80043b:	3b 50 04             	cmp    0x4(%eax),%edx
  80043e:	73 08                	jae    800448 <sprintputch+0x18>
		*b->buf++ = ch;
  800440:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800443:	88 0a                	mov    %cl,(%edx)
  800445:	42                   	inc    %edx
  800446:	89 10                	mov    %edx,(%eax)
}
  800448:	5d                   	pop    %ebp
  800449:	c3                   	ret    

0080044a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80044a:	55                   	push   %ebp
  80044b:	89 e5                	mov    %esp,%ebp
  80044d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800450:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800453:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800457:	8b 45 10             	mov    0x10(%ebp),%eax
  80045a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80045e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800461:	89 44 24 04          	mov    %eax,0x4(%esp)
  800465:	8b 45 08             	mov    0x8(%ebp),%eax
  800468:	89 04 24             	mov    %eax,(%esp)
  80046b:	e8 02 00 00 00       	call   800472 <vprintfmt>
	va_end(ap);
}
  800470:	c9                   	leave  
  800471:	c3                   	ret    

00800472 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800472:	55                   	push   %ebp
  800473:	89 e5                	mov    %esp,%ebp
  800475:	57                   	push   %edi
  800476:	56                   	push   %esi
  800477:	53                   	push   %ebx
  800478:	83 ec 4c             	sub    $0x4c,%esp
  80047b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80047e:	8b 75 10             	mov    0x10(%ebp),%esi
  800481:	eb 12                	jmp    800495 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800483:	85 c0                	test   %eax,%eax
  800485:	0f 84 6b 03 00 00    	je     8007f6 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80048b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80048f:	89 04 24             	mov    %eax,(%esp)
  800492:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800495:	0f b6 06             	movzbl (%esi),%eax
  800498:	46                   	inc    %esi
  800499:	83 f8 25             	cmp    $0x25,%eax
  80049c:	75 e5                	jne    800483 <vprintfmt+0x11>
  80049e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8004a2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8004a9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8004ae:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8004b5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004ba:	eb 26                	jmp    8004e2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bc:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004bf:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8004c3:	eb 1d                	jmp    8004e2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004c8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8004cc:	eb 14                	jmp    8004e2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ce:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8004d1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004d8:	eb 08                	jmp    8004e2 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004da:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8004dd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e2:	0f b6 06             	movzbl (%esi),%eax
  8004e5:	8d 56 01             	lea    0x1(%esi),%edx
  8004e8:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004eb:	8a 16                	mov    (%esi),%dl
  8004ed:	83 ea 23             	sub    $0x23,%edx
  8004f0:	80 fa 55             	cmp    $0x55,%dl
  8004f3:	0f 87 e1 02 00 00    	ja     8007da <vprintfmt+0x368>
  8004f9:	0f b6 d2             	movzbl %dl,%edx
  8004fc:	ff 24 95 80 33 80 00 	jmp    *0x803380(,%edx,4)
  800503:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800506:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80050b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80050e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800512:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800515:	8d 50 d0             	lea    -0x30(%eax),%edx
  800518:	83 fa 09             	cmp    $0x9,%edx
  80051b:	77 2a                	ja     800547 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80051d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80051e:	eb eb                	jmp    80050b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800520:	8b 45 14             	mov    0x14(%ebp),%eax
  800523:	8d 50 04             	lea    0x4(%eax),%edx
  800526:	89 55 14             	mov    %edx,0x14(%ebp)
  800529:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80052e:	eb 17                	jmp    800547 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800530:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800534:	78 98                	js     8004ce <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800536:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800539:	eb a7                	jmp    8004e2 <vprintfmt+0x70>
  80053b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80053e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800545:	eb 9b                	jmp    8004e2 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800547:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80054b:	79 95                	jns    8004e2 <vprintfmt+0x70>
  80054d:	eb 8b                	jmp    8004da <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80054f:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800550:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800553:	eb 8d                	jmp    8004e2 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800555:	8b 45 14             	mov    0x14(%ebp),%eax
  800558:	8d 50 04             	lea    0x4(%eax),%edx
  80055b:	89 55 14             	mov    %edx,0x14(%ebp)
  80055e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800562:	8b 00                	mov    (%eax),%eax
  800564:	89 04 24             	mov    %eax,(%esp)
  800567:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80056d:	e9 23 ff ff ff       	jmp    800495 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800572:	8b 45 14             	mov    0x14(%ebp),%eax
  800575:	8d 50 04             	lea    0x4(%eax),%edx
  800578:	89 55 14             	mov    %edx,0x14(%ebp)
  80057b:	8b 00                	mov    (%eax),%eax
  80057d:	85 c0                	test   %eax,%eax
  80057f:	79 02                	jns    800583 <vprintfmt+0x111>
  800581:	f7 d8                	neg    %eax
  800583:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800585:	83 f8 11             	cmp    $0x11,%eax
  800588:	7f 0b                	jg     800595 <vprintfmt+0x123>
  80058a:	8b 04 85 e0 34 80 00 	mov    0x8034e0(,%eax,4),%eax
  800591:	85 c0                	test   %eax,%eax
  800593:	75 23                	jne    8005b8 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800595:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800599:	c7 44 24 08 53 32 80 	movl   $0x803253,0x8(%esp)
  8005a0:	00 
  8005a1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8005a8:	89 04 24             	mov    %eax,(%esp)
  8005ab:	e8 9a fe ff ff       	call   80044a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b0:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005b3:	e9 dd fe ff ff       	jmp    800495 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8005b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005bc:	c7 44 24 08 90 36 80 	movl   $0x803690,0x8(%esp)
  8005c3:	00 
  8005c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8005cb:	89 14 24             	mov    %edx,(%esp)
  8005ce:	e8 77 fe ff ff       	call   80044a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005d6:	e9 ba fe ff ff       	jmp    800495 <vprintfmt+0x23>
  8005db:	89 f9                	mov    %edi,%ecx
  8005dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005e0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e6:	8d 50 04             	lea    0x4(%eax),%edx
  8005e9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ec:	8b 30                	mov    (%eax),%esi
  8005ee:	85 f6                	test   %esi,%esi
  8005f0:	75 05                	jne    8005f7 <vprintfmt+0x185>
				p = "(null)";
  8005f2:	be 4c 32 80 00       	mov    $0x80324c,%esi
			if (width > 0 && padc != '-')
  8005f7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005fb:	0f 8e 84 00 00 00    	jle    800685 <vprintfmt+0x213>
  800601:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800605:	74 7e                	je     800685 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800607:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80060b:	89 34 24             	mov    %esi,(%esp)
  80060e:	e8 8b 02 00 00       	call   80089e <strnlen>
  800613:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800616:	29 c2                	sub    %eax,%edx
  800618:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80061b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80061f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800622:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800625:	89 de                	mov    %ebx,%esi
  800627:	89 d3                	mov    %edx,%ebx
  800629:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80062b:	eb 0b                	jmp    800638 <vprintfmt+0x1c6>
					putch(padc, putdat);
  80062d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800631:	89 3c 24             	mov    %edi,(%esp)
  800634:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800637:	4b                   	dec    %ebx
  800638:	85 db                	test   %ebx,%ebx
  80063a:	7f f1                	jg     80062d <vprintfmt+0x1bb>
  80063c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80063f:	89 f3                	mov    %esi,%ebx
  800641:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800644:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800647:	85 c0                	test   %eax,%eax
  800649:	79 05                	jns    800650 <vprintfmt+0x1de>
  80064b:	b8 00 00 00 00       	mov    $0x0,%eax
  800650:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800653:	29 c2                	sub    %eax,%edx
  800655:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800658:	eb 2b                	jmp    800685 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80065a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80065e:	74 18                	je     800678 <vprintfmt+0x206>
  800660:	8d 50 e0             	lea    -0x20(%eax),%edx
  800663:	83 fa 5e             	cmp    $0x5e,%edx
  800666:	76 10                	jbe    800678 <vprintfmt+0x206>
					putch('?', putdat);
  800668:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80066c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800673:	ff 55 08             	call   *0x8(%ebp)
  800676:	eb 0a                	jmp    800682 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800678:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80067c:	89 04 24             	mov    %eax,(%esp)
  80067f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800682:	ff 4d e4             	decl   -0x1c(%ebp)
  800685:	0f be 06             	movsbl (%esi),%eax
  800688:	46                   	inc    %esi
  800689:	85 c0                	test   %eax,%eax
  80068b:	74 21                	je     8006ae <vprintfmt+0x23c>
  80068d:	85 ff                	test   %edi,%edi
  80068f:	78 c9                	js     80065a <vprintfmt+0x1e8>
  800691:	4f                   	dec    %edi
  800692:	79 c6                	jns    80065a <vprintfmt+0x1e8>
  800694:	8b 7d 08             	mov    0x8(%ebp),%edi
  800697:	89 de                	mov    %ebx,%esi
  800699:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80069c:	eb 18                	jmp    8006b6 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80069e:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006a2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006a9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006ab:	4b                   	dec    %ebx
  8006ac:	eb 08                	jmp    8006b6 <vprintfmt+0x244>
  8006ae:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006b1:	89 de                	mov    %ebx,%esi
  8006b3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8006b6:	85 db                	test   %ebx,%ebx
  8006b8:	7f e4                	jg     80069e <vprintfmt+0x22c>
  8006ba:	89 7d 08             	mov    %edi,0x8(%ebp)
  8006bd:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006bf:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006c2:	e9 ce fd ff ff       	jmp    800495 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006c7:	83 f9 01             	cmp    $0x1,%ecx
  8006ca:	7e 10                	jle    8006dc <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8006cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cf:	8d 50 08             	lea    0x8(%eax),%edx
  8006d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d5:	8b 30                	mov    (%eax),%esi
  8006d7:	8b 78 04             	mov    0x4(%eax),%edi
  8006da:	eb 26                	jmp    800702 <vprintfmt+0x290>
	else if (lflag)
  8006dc:	85 c9                	test   %ecx,%ecx
  8006de:	74 12                	je     8006f2 <vprintfmt+0x280>
		return va_arg(*ap, long);
  8006e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e3:	8d 50 04             	lea    0x4(%eax),%edx
  8006e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e9:	8b 30                	mov    (%eax),%esi
  8006eb:	89 f7                	mov    %esi,%edi
  8006ed:	c1 ff 1f             	sar    $0x1f,%edi
  8006f0:	eb 10                	jmp    800702 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8006f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f5:	8d 50 04             	lea    0x4(%eax),%edx
  8006f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006fb:	8b 30                	mov    (%eax),%esi
  8006fd:	89 f7                	mov    %esi,%edi
  8006ff:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800702:	85 ff                	test   %edi,%edi
  800704:	78 0a                	js     800710 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800706:	b8 0a 00 00 00       	mov    $0xa,%eax
  80070b:	e9 8c 00 00 00       	jmp    80079c <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800710:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800714:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80071b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80071e:	f7 de                	neg    %esi
  800720:	83 d7 00             	adc    $0x0,%edi
  800723:	f7 df                	neg    %edi
			}
			base = 10;
  800725:	b8 0a 00 00 00       	mov    $0xa,%eax
  80072a:	eb 70                	jmp    80079c <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80072c:	89 ca                	mov    %ecx,%edx
  80072e:	8d 45 14             	lea    0x14(%ebp),%eax
  800731:	e8 c0 fc ff ff       	call   8003f6 <getuint>
  800736:	89 c6                	mov    %eax,%esi
  800738:	89 d7                	mov    %edx,%edi
			base = 10;
  80073a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80073f:	eb 5b                	jmp    80079c <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  800741:	89 ca                	mov    %ecx,%edx
  800743:	8d 45 14             	lea    0x14(%ebp),%eax
  800746:	e8 ab fc ff ff       	call   8003f6 <getuint>
  80074b:	89 c6                	mov    %eax,%esi
  80074d:	89 d7                	mov    %edx,%edi
			base = 8;
  80074f:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800754:	eb 46                	jmp    80079c <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  800756:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80075a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800761:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800764:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800768:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80076f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800772:	8b 45 14             	mov    0x14(%ebp),%eax
  800775:	8d 50 04             	lea    0x4(%eax),%edx
  800778:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80077b:	8b 30                	mov    (%eax),%esi
  80077d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800782:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800787:	eb 13                	jmp    80079c <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800789:	89 ca                	mov    %ecx,%edx
  80078b:	8d 45 14             	lea    0x14(%ebp),%eax
  80078e:	e8 63 fc ff ff       	call   8003f6 <getuint>
  800793:	89 c6                	mov    %eax,%esi
  800795:	89 d7                	mov    %edx,%edi
			base = 16;
  800797:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80079c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8007a0:	89 54 24 10          	mov    %edx,0x10(%esp)
  8007a4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007a7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007af:	89 34 24             	mov    %esi,(%esp)
  8007b2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007b6:	89 da                	mov    %ebx,%edx
  8007b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bb:	e8 6c fb ff ff       	call   80032c <printnum>
			break;
  8007c0:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007c3:	e9 cd fc ff ff       	jmp    800495 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007cc:	89 04 24             	mov    %eax,(%esp)
  8007cf:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007d5:	e9 bb fc ff ff       	jmp    800495 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007de:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007e5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007e8:	eb 01                	jmp    8007eb <vprintfmt+0x379>
  8007ea:	4e                   	dec    %esi
  8007eb:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007ef:	75 f9                	jne    8007ea <vprintfmt+0x378>
  8007f1:	e9 9f fc ff ff       	jmp    800495 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8007f6:	83 c4 4c             	add    $0x4c,%esp
  8007f9:	5b                   	pop    %ebx
  8007fa:	5e                   	pop    %esi
  8007fb:	5f                   	pop    %edi
  8007fc:	5d                   	pop    %ebp
  8007fd:	c3                   	ret    

008007fe <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	83 ec 28             	sub    $0x28,%esp
  800804:	8b 45 08             	mov    0x8(%ebp),%eax
  800807:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80080a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80080d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800811:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800814:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80081b:	85 c0                	test   %eax,%eax
  80081d:	74 30                	je     80084f <vsnprintf+0x51>
  80081f:	85 d2                	test   %edx,%edx
  800821:	7e 33                	jle    800856 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800823:	8b 45 14             	mov    0x14(%ebp),%eax
  800826:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80082a:	8b 45 10             	mov    0x10(%ebp),%eax
  80082d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800831:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800834:	89 44 24 04          	mov    %eax,0x4(%esp)
  800838:	c7 04 24 30 04 80 00 	movl   $0x800430,(%esp)
  80083f:	e8 2e fc ff ff       	call   800472 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800844:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800847:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80084a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80084d:	eb 0c                	jmp    80085b <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80084f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800854:	eb 05                	jmp    80085b <vsnprintf+0x5d>
  800856:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80085b:	c9                   	leave  
  80085c:	c3                   	ret    

0080085d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80085d:	55                   	push   %ebp
  80085e:	89 e5                	mov    %esp,%ebp
  800860:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800863:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800866:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80086a:	8b 45 10             	mov    0x10(%ebp),%eax
  80086d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800871:	8b 45 0c             	mov    0xc(%ebp),%eax
  800874:	89 44 24 04          	mov    %eax,0x4(%esp)
  800878:	8b 45 08             	mov    0x8(%ebp),%eax
  80087b:	89 04 24             	mov    %eax,(%esp)
  80087e:	e8 7b ff ff ff       	call   8007fe <vsnprintf>
	va_end(ap);

	return rc;
}
  800883:	c9                   	leave  
  800884:	c3                   	ret    
  800885:	00 00                	add    %al,(%eax)
	...

00800888 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800888:	55                   	push   %ebp
  800889:	89 e5                	mov    %esp,%ebp
  80088b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80088e:	b8 00 00 00 00       	mov    $0x0,%eax
  800893:	eb 01                	jmp    800896 <strlen+0xe>
		n++;
  800895:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800896:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80089a:	75 f9                	jne    800895 <strlen+0xd>
		n++;
	return n;
}
  80089c:	5d                   	pop    %ebp
  80089d:	c3                   	ret    

0080089e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80089e:	55                   	push   %ebp
  80089f:	89 e5                	mov    %esp,%ebp
  8008a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8008a4:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ac:	eb 01                	jmp    8008af <strnlen+0x11>
		n++;
  8008ae:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008af:	39 d0                	cmp    %edx,%eax
  8008b1:	74 06                	je     8008b9 <strnlen+0x1b>
  8008b3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008b7:	75 f5                	jne    8008ae <strnlen+0x10>
		n++;
	return n;
}
  8008b9:	5d                   	pop    %ebp
  8008ba:	c3                   	ret    

008008bb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	53                   	push   %ebx
  8008bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8008ca:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8008cd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008d0:	42                   	inc    %edx
  8008d1:	84 c9                	test   %cl,%cl
  8008d3:	75 f5                	jne    8008ca <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008d5:	5b                   	pop    %ebx
  8008d6:	5d                   	pop    %ebp
  8008d7:	c3                   	ret    

008008d8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008d8:	55                   	push   %ebp
  8008d9:	89 e5                	mov    %esp,%ebp
  8008db:	53                   	push   %ebx
  8008dc:	83 ec 08             	sub    $0x8,%esp
  8008df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008e2:	89 1c 24             	mov    %ebx,(%esp)
  8008e5:	e8 9e ff ff ff       	call   800888 <strlen>
	strcpy(dst + len, src);
  8008ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ed:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008f1:	01 d8                	add    %ebx,%eax
  8008f3:	89 04 24             	mov    %eax,(%esp)
  8008f6:	e8 c0 ff ff ff       	call   8008bb <strcpy>
	return dst;
}
  8008fb:	89 d8                	mov    %ebx,%eax
  8008fd:	83 c4 08             	add    $0x8,%esp
  800900:	5b                   	pop    %ebx
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    

00800903 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	56                   	push   %esi
  800907:	53                   	push   %ebx
  800908:	8b 45 08             	mov    0x8(%ebp),%eax
  80090b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800911:	b9 00 00 00 00       	mov    $0x0,%ecx
  800916:	eb 0c                	jmp    800924 <strncpy+0x21>
		*dst++ = *src;
  800918:	8a 1a                	mov    (%edx),%bl
  80091a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80091d:	80 3a 01             	cmpb   $0x1,(%edx)
  800920:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800923:	41                   	inc    %ecx
  800924:	39 f1                	cmp    %esi,%ecx
  800926:	75 f0                	jne    800918 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800928:	5b                   	pop    %ebx
  800929:	5e                   	pop    %esi
  80092a:	5d                   	pop    %ebp
  80092b:	c3                   	ret    

0080092c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
  80092f:	56                   	push   %esi
  800930:	53                   	push   %ebx
  800931:	8b 75 08             	mov    0x8(%ebp),%esi
  800934:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800937:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80093a:	85 d2                	test   %edx,%edx
  80093c:	75 0a                	jne    800948 <strlcpy+0x1c>
  80093e:	89 f0                	mov    %esi,%eax
  800940:	eb 1a                	jmp    80095c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800942:	88 18                	mov    %bl,(%eax)
  800944:	40                   	inc    %eax
  800945:	41                   	inc    %ecx
  800946:	eb 02                	jmp    80094a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800948:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80094a:	4a                   	dec    %edx
  80094b:	74 0a                	je     800957 <strlcpy+0x2b>
  80094d:	8a 19                	mov    (%ecx),%bl
  80094f:	84 db                	test   %bl,%bl
  800951:	75 ef                	jne    800942 <strlcpy+0x16>
  800953:	89 c2                	mov    %eax,%edx
  800955:	eb 02                	jmp    800959 <strlcpy+0x2d>
  800957:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800959:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  80095c:	29 f0                	sub    %esi,%eax
}
  80095e:	5b                   	pop    %ebx
  80095f:	5e                   	pop    %esi
  800960:	5d                   	pop    %ebp
  800961:	c3                   	ret    

00800962 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800962:	55                   	push   %ebp
  800963:	89 e5                	mov    %esp,%ebp
  800965:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800968:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80096b:	eb 02                	jmp    80096f <strcmp+0xd>
		p++, q++;
  80096d:	41                   	inc    %ecx
  80096e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80096f:	8a 01                	mov    (%ecx),%al
  800971:	84 c0                	test   %al,%al
  800973:	74 04                	je     800979 <strcmp+0x17>
  800975:	3a 02                	cmp    (%edx),%al
  800977:	74 f4                	je     80096d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800979:	0f b6 c0             	movzbl %al,%eax
  80097c:	0f b6 12             	movzbl (%edx),%edx
  80097f:	29 d0                	sub    %edx,%eax
}
  800981:	5d                   	pop    %ebp
  800982:	c3                   	ret    

00800983 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800983:	55                   	push   %ebp
  800984:	89 e5                	mov    %esp,%ebp
  800986:	53                   	push   %ebx
  800987:	8b 45 08             	mov    0x8(%ebp),%eax
  80098a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80098d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800990:	eb 03                	jmp    800995 <strncmp+0x12>
		n--, p++, q++;
  800992:	4a                   	dec    %edx
  800993:	40                   	inc    %eax
  800994:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800995:	85 d2                	test   %edx,%edx
  800997:	74 14                	je     8009ad <strncmp+0x2a>
  800999:	8a 18                	mov    (%eax),%bl
  80099b:	84 db                	test   %bl,%bl
  80099d:	74 04                	je     8009a3 <strncmp+0x20>
  80099f:	3a 19                	cmp    (%ecx),%bl
  8009a1:	74 ef                	je     800992 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a3:	0f b6 00             	movzbl (%eax),%eax
  8009a6:	0f b6 11             	movzbl (%ecx),%edx
  8009a9:	29 d0                	sub    %edx,%eax
  8009ab:	eb 05                	jmp    8009b2 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009ad:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009b2:	5b                   	pop    %ebx
  8009b3:	5d                   	pop    %ebp
  8009b4:	c3                   	ret    

008009b5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009b5:	55                   	push   %ebp
  8009b6:	89 e5                	mov    %esp,%ebp
  8009b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bb:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009be:	eb 05                	jmp    8009c5 <strchr+0x10>
		if (*s == c)
  8009c0:	38 ca                	cmp    %cl,%dl
  8009c2:	74 0c                	je     8009d0 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009c4:	40                   	inc    %eax
  8009c5:	8a 10                	mov    (%eax),%dl
  8009c7:	84 d2                	test   %dl,%dl
  8009c9:	75 f5                	jne    8009c0 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8009cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d0:	5d                   	pop    %ebp
  8009d1:	c3                   	ret    

008009d2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009d2:	55                   	push   %ebp
  8009d3:	89 e5                	mov    %esp,%ebp
  8009d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d8:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009db:	eb 05                	jmp    8009e2 <strfind+0x10>
		if (*s == c)
  8009dd:	38 ca                	cmp    %cl,%dl
  8009df:	74 07                	je     8009e8 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009e1:	40                   	inc    %eax
  8009e2:	8a 10                	mov    (%eax),%dl
  8009e4:	84 d2                	test   %dl,%dl
  8009e6:	75 f5                	jne    8009dd <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8009e8:	5d                   	pop    %ebp
  8009e9:	c3                   	ret    

008009ea <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	57                   	push   %edi
  8009ee:	56                   	push   %esi
  8009ef:	53                   	push   %ebx
  8009f0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009f9:	85 c9                	test   %ecx,%ecx
  8009fb:	74 30                	je     800a2d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009fd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a03:	75 25                	jne    800a2a <memset+0x40>
  800a05:	f6 c1 03             	test   $0x3,%cl
  800a08:	75 20                	jne    800a2a <memset+0x40>
		c &= 0xFF;
  800a0a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a0d:	89 d3                	mov    %edx,%ebx
  800a0f:	c1 e3 08             	shl    $0x8,%ebx
  800a12:	89 d6                	mov    %edx,%esi
  800a14:	c1 e6 18             	shl    $0x18,%esi
  800a17:	89 d0                	mov    %edx,%eax
  800a19:	c1 e0 10             	shl    $0x10,%eax
  800a1c:	09 f0                	or     %esi,%eax
  800a1e:	09 d0                	or     %edx,%eax
  800a20:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a22:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a25:	fc                   	cld    
  800a26:	f3 ab                	rep stos %eax,%es:(%edi)
  800a28:	eb 03                	jmp    800a2d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a2a:	fc                   	cld    
  800a2b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a2d:	89 f8                	mov    %edi,%eax
  800a2f:	5b                   	pop    %ebx
  800a30:	5e                   	pop    %esi
  800a31:	5f                   	pop    %edi
  800a32:	5d                   	pop    %ebp
  800a33:	c3                   	ret    

00800a34 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a34:	55                   	push   %ebp
  800a35:	89 e5                	mov    %esp,%ebp
  800a37:	57                   	push   %edi
  800a38:	56                   	push   %esi
  800a39:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a3f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a42:	39 c6                	cmp    %eax,%esi
  800a44:	73 34                	jae    800a7a <memmove+0x46>
  800a46:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a49:	39 d0                	cmp    %edx,%eax
  800a4b:	73 2d                	jae    800a7a <memmove+0x46>
		s += n;
		d += n;
  800a4d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a50:	f6 c2 03             	test   $0x3,%dl
  800a53:	75 1b                	jne    800a70 <memmove+0x3c>
  800a55:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a5b:	75 13                	jne    800a70 <memmove+0x3c>
  800a5d:	f6 c1 03             	test   $0x3,%cl
  800a60:	75 0e                	jne    800a70 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a62:	83 ef 04             	sub    $0x4,%edi
  800a65:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a68:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a6b:	fd                   	std    
  800a6c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a6e:	eb 07                	jmp    800a77 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a70:	4f                   	dec    %edi
  800a71:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a74:	fd                   	std    
  800a75:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a77:	fc                   	cld    
  800a78:	eb 20                	jmp    800a9a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a7a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a80:	75 13                	jne    800a95 <memmove+0x61>
  800a82:	a8 03                	test   $0x3,%al
  800a84:	75 0f                	jne    800a95 <memmove+0x61>
  800a86:	f6 c1 03             	test   $0x3,%cl
  800a89:	75 0a                	jne    800a95 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a8b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a8e:	89 c7                	mov    %eax,%edi
  800a90:	fc                   	cld    
  800a91:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a93:	eb 05                	jmp    800a9a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a95:	89 c7                	mov    %eax,%edi
  800a97:	fc                   	cld    
  800a98:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a9a:	5e                   	pop    %esi
  800a9b:	5f                   	pop    %edi
  800a9c:	5d                   	pop    %ebp
  800a9d:	c3                   	ret    

00800a9e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a9e:	55                   	push   %ebp
  800a9f:	89 e5                	mov    %esp,%ebp
  800aa1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800aa4:	8b 45 10             	mov    0x10(%ebp),%eax
  800aa7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aab:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aae:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ab2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab5:	89 04 24             	mov    %eax,(%esp)
  800ab8:	e8 77 ff ff ff       	call   800a34 <memmove>
}
  800abd:	c9                   	leave  
  800abe:	c3                   	ret    

00800abf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800abf:	55                   	push   %ebp
  800ac0:	89 e5                	mov    %esp,%ebp
  800ac2:	57                   	push   %edi
  800ac3:	56                   	push   %esi
  800ac4:	53                   	push   %ebx
  800ac5:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ac8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800acb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ace:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad3:	eb 16                	jmp    800aeb <memcmp+0x2c>
		if (*s1 != *s2)
  800ad5:	8a 04 17             	mov    (%edi,%edx,1),%al
  800ad8:	42                   	inc    %edx
  800ad9:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800add:	38 c8                	cmp    %cl,%al
  800adf:	74 0a                	je     800aeb <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800ae1:	0f b6 c0             	movzbl %al,%eax
  800ae4:	0f b6 c9             	movzbl %cl,%ecx
  800ae7:	29 c8                	sub    %ecx,%eax
  800ae9:	eb 09                	jmp    800af4 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aeb:	39 da                	cmp    %ebx,%edx
  800aed:	75 e6                	jne    800ad5 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800aef:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af4:	5b                   	pop    %ebx
  800af5:	5e                   	pop    %esi
  800af6:	5f                   	pop    %edi
  800af7:	5d                   	pop    %ebp
  800af8:	c3                   	ret    

00800af9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800af9:	55                   	push   %ebp
  800afa:	89 e5                	mov    %esp,%ebp
  800afc:	8b 45 08             	mov    0x8(%ebp),%eax
  800aff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b02:	89 c2                	mov    %eax,%edx
  800b04:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b07:	eb 05                	jmp    800b0e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b09:	38 08                	cmp    %cl,(%eax)
  800b0b:	74 05                	je     800b12 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b0d:	40                   	inc    %eax
  800b0e:	39 d0                	cmp    %edx,%eax
  800b10:	72 f7                	jb     800b09 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b12:	5d                   	pop    %ebp
  800b13:	c3                   	ret    

00800b14 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	57                   	push   %edi
  800b18:	56                   	push   %esi
  800b19:	53                   	push   %ebx
  800b1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b1d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b20:	eb 01                	jmp    800b23 <strtol+0xf>
		s++;
  800b22:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b23:	8a 02                	mov    (%edx),%al
  800b25:	3c 20                	cmp    $0x20,%al
  800b27:	74 f9                	je     800b22 <strtol+0xe>
  800b29:	3c 09                	cmp    $0x9,%al
  800b2b:	74 f5                	je     800b22 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b2d:	3c 2b                	cmp    $0x2b,%al
  800b2f:	75 08                	jne    800b39 <strtol+0x25>
		s++;
  800b31:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b32:	bf 00 00 00 00       	mov    $0x0,%edi
  800b37:	eb 13                	jmp    800b4c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b39:	3c 2d                	cmp    $0x2d,%al
  800b3b:	75 0a                	jne    800b47 <strtol+0x33>
		s++, neg = 1;
  800b3d:	8d 52 01             	lea    0x1(%edx),%edx
  800b40:	bf 01 00 00 00       	mov    $0x1,%edi
  800b45:	eb 05                	jmp    800b4c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b47:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b4c:	85 db                	test   %ebx,%ebx
  800b4e:	74 05                	je     800b55 <strtol+0x41>
  800b50:	83 fb 10             	cmp    $0x10,%ebx
  800b53:	75 28                	jne    800b7d <strtol+0x69>
  800b55:	8a 02                	mov    (%edx),%al
  800b57:	3c 30                	cmp    $0x30,%al
  800b59:	75 10                	jne    800b6b <strtol+0x57>
  800b5b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b5f:	75 0a                	jne    800b6b <strtol+0x57>
		s += 2, base = 16;
  800b61:	83 c2 02             	add    $0x2,%edx
  800b64:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b69:	eb 12                	jmp    800b7d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b6b:	85 db                	test   %ebx,%ebx
  800b6d:	75 0e                	jne    800b7d <strtol+0x69>
  800b6f:	3c 30                	cmp    $0x30,%al
  800b71:	75 05                	jne    800b78 <strtol+0x64>
		s++, base = 8;
  800b73:	42                   	inc    %edx
  800b74:	b3 08                	mov    $0x8,%bl
  800b76:	eb 05                	jmp    800b7d <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b78:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b7d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b82:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b84:	8a 0a                	mov    (%edx),%cl
  800b86:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b89:	80 fb 09             	cmp    $0x9,%bl
  800b8c:	77 08                	ja     800b96 <strtol+0x82>
			dig = *s - '0';
  800b8e:	0f be c9             	movsbl %cl,%ecx
  800b91:	83 e9 30             	sub    $0x30,%ecx
  800b94:	eb 1e                	jmp    800bb4 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b96:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b99:	80 fb 19             	cmp    $0x19,%bl
  800b9c:	77 08                	ja     800ba6 <strtol+0x92>
			dig = *s - 'a' + 10;
  800b9e:	0f be c9             	movsbl %cl,%ecx
  800ba1:	83 e9 57             	sub    $0x57,%ecx
  800ba4:	eb 0e                	jmp    800bb4 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800ba6:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800ba9:	80 fb 19             	cmp    $0x19,%bl
  800bac:	77 12                	ja     800bc0 <strtol+0xac>
			dig = *s - 'A' + 10;
  800bae:	0f be c9             	movsbl %cl,%ecx
  800bb1:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bb4:	39 f1                	cmp    %esi,%ecx
  800bb6:	7d 0c                	jge    800bc4 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800bb8:	42                   	inc    %edx
  800bb9:	0f af c6             	imul   %esi,%eax
  800bbc:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800bbe:	eb c4                	jmp    800b84 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800bc0:	89 c1                	mov    %eax,%ecx
  800bc2:	eb 02                	jmp    800bc6 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bc4:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800bc6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bca:	74 05                	je     800bd1 <strtol+0xbd>
		*endptr = (char *) s;
  800bcc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bcf:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800bd1:	85 ff                	test   %edi,%edi
  800bd3:	74 04                	je     800bd9 <strtol+0xc5>
  800bd5:	89 c8                	mov    %ecx,%eax
  800bd7:	f7 d8                	neg    %eax
}
  800bd9:	5b                   	pop    %ebx
  800bda:	5e                   	pop    %esi
  800bdb:	5f                   	pop    %edi
  800bdc:	5d                   	pop    %ebp
  800bdd:	c3                   	ret    
	...

00800be0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800be0:	55                   	push   %ebp
  800be1:	89 e5                	mov    %esp,%ebp
  800be3:	57                   	push   %edi
  800be4:	56                   	push   %esi
  800be5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be6:	b8 00 00 00 00       	mov    $0x0,%eax
  800beb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bee:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf1:	89 c3                	mov    %eax,%ebx
  800bf3:	89 c7                	mov    %eax,%edi
  800bf5:	89 c6                	mov    %eax,%esi
  800bf7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bf9:	5b                   	pop    %ebx
  800bfa:	5e                   	pop    %esi
  800bfb:	5f                   	pop    %edi
  800bfc:	5d                   	pop    %ebp
  800bfd:	c3                   	ret    

00800bfe <sys_cgetc>:

int
sys_cgetc(void)
{
  800bfe:	55                   	push   %ebp
  800bff:	89 e5                	mov    %esp,%ebp
  800c01:	57                   	push   %edi
  800c02:	56                   	push   %esi
  800c03:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c04:	ba 00 00 00 00       	mov    $0x0,%edx
  800c09:	b8 01 00 00 00       	mov    $0x1,%eax
  800c0e:	89 d1                	mov    %edx,%ecx
  800c10:	89 d3                	mov    %edx,%ebx
  800c12:	89 d7                	mov    %edx,%edi
  800c14:	89 d6                	mov    %edx,%esi
  800c16:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c18:	5b                   	pop    %ebx
  800c19:	5e                   	pop    %esi
  800c1a:	5f                   	pop    %edi
  800c1b:	5d                   	pop    %ebp
  800c1c:	c3                   	ret    

00800c1d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c1d:	55                   	push   %ebp
  800c1e:	89 e5                	mov    %esp,%ebp
  800c20:	57                   	push   %edi
  800c21:	56                   	push   %esi
  800c22:	53                   	push   %ebx
  800c23:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c26:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c2b:	b8 03 00 00 00       	mov    $0x3,%eax
  800c30:	8b 55 08             	mov    0x8(%ebp),%edx
  800c33:	89 cb                	mov    %ecx,%ebx
  800c35:	89 cf                	mov    %ecx,%edi
  800c37:	89 ce                	mov    %ecx,%esi
  800c39:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c3b:	85 c0                	test   %eax,%eax
  800c3d:	7e 28                	jle    800c67 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c43:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c4a:	00 
  800c4b:	c7 44 24 08 47 35 80 	movl   $0x803547,0x8(%esp)
  800c52:	00 
  800c53:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c5a:	00 
  800c5b:	c7 04 24 64 35 80 00 	movl   $0x803564,(%esp)
  800c62:	e8 b1 f5 ff ff       	call   800218 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c67:	83 c4 2c             	add    $0x2c,%esp
  800c6a:	5b                   	pop    %ebx
  800c6b:	5e                   	pop    %esi
  800c6c:	5f                   	pop    %edi
  800c6d:	5d                   	pop    %ebp
  800c6e:	c3                   	ret    

00800c6f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c6f:	55                   	push   %ebp
  800c70:	89 e5                	mov    %esp,%ebp
  800c72:	57                   	push   %edi
  800c73:	56                   	push   %esi
  800c74:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c75:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7a:	b8 02 00 00 00       	mov    $0x2,%eax
  800c7f:	89 d1                	mov    %edx,%ecx
  800c81:	89 d3                	mov    %edx,%ebx
  800c83:	89 d7                	mov    %edx,%edi
  800c85:	89 d6                	mov    %edx,%esi
  800c87:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c89:	5b                   	pop    %ebx
  800c8a:	5e                   	pop    %esi
  800c8b:	5f                   	pop    %edi
  800c8c:	5d                   	pop    %ebp
  800c8d:	c3                   	ret    

00800c8e <sys_yield>:

void
sys_yield(void)
{
  800c8e:	55                   	push   %ebp
  800c8f:	89 e5                	mov    %esp,%ebp
  800c91:	57                   	push   %edi
  800c92:	56                   	push   %esi
  800c93:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c94:	ba 00 00 00 00       	mov    $0x0,%edx
  800c99:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c9e:	89 d1                	mov    %edx,%ecx
  800ca0:	89 d3                	mov    %edx,%ebx
  800ca2:	89 d7                	mov    %edx,%edi
  800ca4:	89 d6                	mov    %edx,%esi
  800ca6:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ca8:	5b                   	pop    %ebx
  800ca9:	5e                   	pop    %esi
  800caa:	5f                   	pop    %edi
  800cab:	5d                   	pop    %ebp
  800cac:	c3                   	ret    

00800cad <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cad:	55                   	push   %ebp
  800cae:	89 e5                	mov    %esp,%ebp
  800cb0:	57                   	push   %edi
  800cb1:	56                   	push   %esi
  800cb2:	53                   	push   %ebx
  800cb3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb6:	be 00 00 00 00       	mov    $0x0,%esi
  800cbb:	b8 04 00 00 00       	mov    $0x4,%eax
  800cc0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc9:	89 f7                	mov    %esi,%edi
  800ccb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ccd:	85 c0                	test   %eax,%eax
  800ccf:	7e 28                	jle    800cf9 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cd5:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800cdc:	00 
  800cdd:	c7 44 24 08 47 35 80 	movl   $0x803547,0x8(%esp)
  800ce4:	00 
  800ce5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cec:	00 
  800ced:	c7 04 24 64 35 80 00 	movl   $0x803564,(%esp)
  800cf4:	e8 1f f5 ff ff       	call   800218 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cf9:	83 c4 2c             	add    $0x2c,%esp
  800cfc:	5b                   	pop    %ebx
  800cfd:	5e                   	pop    %esi
  800cfe:	5f                   	pop    %edi
  800cff:	5d                   	pop    %ebp
  800d00:	c3                   	ret    

00800d01 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d01:	55                   	push   %ebp
  800d02:	89 e5                	mov    %esp,%ebp
  800d04:	57                   	push   %edi
  800d05:	56                   	push   %esi
  800d06:	53                   	push   %ebx
  800d07:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0a:	b8 05 00 00 00       	mov    $0x5,%eax
  800d0f:	8b 75 18             	mov    0x18(%ebp),%esi
  800d12:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d15:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d20:	85 c0                	test   %eax,%eax
  800d22:	7e 28                	jle    800d4c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d24:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d28:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d2f:	00 
  800d30:	c7 44 24 08 47 35 80 	movl   $0x803547,0x8(%esp)
  800d37:	00 
  800d38:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d3f:	00 
  800d40:	c7 04 24 64 35 80 00 	movl   $0x803564,(%esp)
  800d47:	e8 cc f4 ff ff       	call   800218 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d4c:	83 c4 2c             	add    $0x2c,%esp
  800d4f:	5b                   	pop    %ebx
  800d50:	5e                   	pop    %esi
  800d51:	5f                   	pop    %edi
  800d52:	5d                   	pop    %ebp
  800d53:	c3                   	ret    

00800d54 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d54:	55                   	push   %ebp
  800d55:	89 e5                	mov    %esp,%ebp
  800d57:	57                   	push   %edi
  800d58:	56                   	push   %esi
  800d59:	53                   	push   %ebx
  800d5a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d62:	b8 06 00 00 00       	mov    $0x6,%eax
  800d67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6d:	89 df                	mov    %ebx,%edi
  800d6f:	89 de                	mov    %ebx,%esi
  800d71:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d73:	85 c0                	test   %eax,%eax
  800d75:	7e 28                	jle    800d9f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d77:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d7b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d82:	00 
  800d83:	c7 44 24 08 47 35 80 	movl   $0x803547,0x8(%esp)
  800d8a:	00 
  800d8b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d92:	00 
  800d93:	c7 04 24 64 35 80 00 	movl   $0x803564,(%esp)
  800d9a:	e8 79 f4 ff ff       	call   800218 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d9f:	83 c4 2c             	add    $0x2c,%esp
  800da2:	5b                   	pop    %ebx
  800da3:	5e                   	pop    %esi
  800da4:	5f                   	pop    %edi
  800da5:	5d                   	pop    %ebp
  800da6:	c3                   	ret    

00800da7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800da7:	55                   	push   %ebp
  800da8:	89 e5                	mov    %esp,%ebp
  800daa:	57                   	push   %edi
  800dab:	56                   	push   %esi
  800dac:	53                   	push   %ebx
  800dad:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db5:	b8 08 00 00 00       	mov    $0x8,%eax
  800dba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbd:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc0:	89 df                	mov    %ebx,%edi
  800dc2:	89 de                	mov    %ebx,%esi
  800dc4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dc6:	85 c0                	test   %eax,%eax
  800dc8:	7e 28                	jle    800df2 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dca:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dce:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800dd5:	00 
  800dd6:	c7 44 24 08 47 35 80 	movl   $0x803547,0x8(%esp)
  800ddd:	00 
  800dde:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800de5:	00 
  800de6:	c7 04 24 64 35 80 00 	movl   $0x803564,(%esp)
  800ded:	e8 26 f4 ff ff       	call   800218 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800df2:	83 c4 2c             	add    $0x2c,%esp
  800df5:	5b                   	pop    %ebx
  800df6:	5e                   	pop    %esi
  800df7:	5f                   	pop    %edi
  800df8:	5d                   	pop    %ebp
  800df9:	c3                   	ret    

00800dfa <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dfa:	55                   	push   %ebp
  800dfb:	89 e5                	mov    %esp,%ebp
  800dfd:	57                   	push   %edi
  800dfe:	56                   	push   %esi
  800dff:	53                   	push   %ebx
  800e00:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e03:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e08:	b8 09 00 00 00       	mov    $0x9,%eax
  800e0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e10:	8b 55 08             	mov    0x8(%ebp),%edx
  800e13:	89 df                	mov    %ebx,%edi
  800e15:	89 de                	mov    %ebx,%esi
  800e17:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e19:	85 c0                	test   %eax,%eax
  800e1b:	7e 28                	jle    800e45 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e1d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e21:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e28:	00 
  800e29:	c7 44 24 08 47 35 80 	movl   $0x803547,0x8(%esp)
  800e30:	00 
  800e31:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e38:	00 
  800e39:	c7 04 24 64 35 80 00 	movl   $0x803564,(%esp)
  800e40:	e8 d3 f3 ff ff       	call   800218 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e45:	83 c4 2c             	add    $0x2c,%esp
  800e48:	5b                   	pop    %ebx
  800e49:	5e                   	pop    %esi
  800e4a:	5f                   	pop    %edi
  800e4b:	5d                   	pop    %ebp
  800e4c:	c3                   	ret    

00800e4d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e4d:	55                   	push   %ebp
  800e4e:	89 e5                	mov    %esp,%ebp
  800e50:	57                   	push   %edi
  800e51:	56                   	push   %esi
  800e52:	53                   	push   %ebx
  800e53:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e56:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e5b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e63:	8b 55 08             	mov    0x8(%ebp),%edx
  800e66:	89 df                	mov    %ebx,%edi
  800e68:	89 de                	mov    %ebx,%esi
  800e6a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e6c:	85 c0                	test   %eax,%eax
  800e6e:	7e 28                	jle    800e98 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e70:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e74:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e7b:	00 
  800e7c:	c7 44 24 08 47 35 80 	movl   $0x803547,0x8(%esp)
  800e83:	00 
  800e84:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e8b:	00 
  800e8c:	c7 04 24 64 35 80 00 	movl   $0x803564,(%esp)
  800e93:	e8 80 f3 ff ff       	call   800218 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e98:	83 c4 2c             	add    $0x2c,%esp
  800e9b:	5b                   	pop    %ebx
  800e9c:	5e                   	pop    %esi
  800e9d:	5f                   	pop    %edi
  800e9e:	5d                   	pop    %ebp
  800e9f:	c3                   	ret    

00800ea0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ea0:	55                   	push   %ebp
  800ea1:	89 e5                	mov    %esp,%ebp
  800ea3:	57                   	push   %edi
  800ea4:	56                   	push   %esi
  800ea5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea6:	be 00 00 00 00       	mov    $0x0,%esi
  800eab:	b8 0c 00 00 00       	mov    $0xc,%eax
  800eb0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800eb3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebc:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ebe:	5b                   	pop    %ebx
  800ebf:	5e                   	pop    %esi
  800ec0:	5f                   	pop    %edi
  800ec1:	5d                   	pop    %ebp
  800ec2:	c3                   	ret    

00800ec3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ec3:	55                   	push   %ebp
  800ec4:	89 e5                	mov    %esp,%ebp
  800ec6:	57                   	push   %edi
  800ec7:	56                   	push   %esi
  800ec8:	53                   	push   %ebx
  800ec9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ecc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ed1:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ed6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed9:	89 cb                	mov    %ecx,%ebx
  800edb:	89 cf                	mov    %ecx,%edi
  800edd:	89 ce                	mov    %ecx,%esi
  800edf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ee1:	85 c0                	test   %eax,%eax
  800ee3:	7e 28                	jle    800f0d <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ee9:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800ef0:	00 
  800ef1:	c7 44 24 08 47 35 80 	movl   $0x803547,0x8(%esp)
  800ef8:	00 
  800ef9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f00:	00 
  800f01:	c7 04 24 64 35 80 00 	movl   $0x803564,(%esp)
  800f08:	e8 0b f3 ff ff       	call   800218 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f0d:	83 c4 2c             	add    $0x2c,%esp
  800f10:	5b                   	pop    %ebx
  800f11:	5e                   	pop    %esi
  800f12:	5f                   	pop    %edi
  800f13:	5d                   	pop    %ebp
  800f14:	c3                   	ret    

00800f15 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800f15:	55                   	push   %ebp
  800f16:	89 e5                	mov    %esp,%ebp
  800f18:	57                   	push   %edi
  800f19:	56                   	push   %esi
  800f1a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f1b:	ba 00 00 00 00       	mov    $0x0,%edx
  800f20:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f25:	89 d1                	mov    %edx,%ecx
  800f27:	89 d3                	mov    %edx,%ebx
  800f29:	89 d7                	mov    %edx,%edi
  800f2b:	89 d6                	mov    %edx,%esi
  800f2d:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800f2f:	5b                   	pop    %ebx
  800f30:	5e                   	pop    %esi
  800f31:	5f                   	pop    %edi
  800f32:	5d                   	pop    %ebp
  800f33:	c3                   	ret    

00800f34 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char* pck, size_t length){
  800f34:	55                   	push   %ebp
  800f35:	89 e5                	mov    %esp,%ebp
  800f37:	57                   	push   %edi
  800f38:	56                   	push   %esi
  800f39:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f3a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f3f:	b8 10 00 00 00       	mov    $0x10,%eax
  800f44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f47:	8b 55 08             	mov    0x8(%ebp),%edx
  800f4a:	89 df                	mov    %ebx,%edi
  800f4c:	89 de                	mov    %ebx,%esi
  800f4e:	cd 30                	int    $0x30
}

int 
sys_e1000_transmit(char* pck, size_t length){
	return syscall(SYS_e1000_transmit, 0, (uint32_t)pck, length, 0, 0, 0);
}
  800f50:	5b                   	pop    %ebx
  800f51:	5e                   	pop    %esi
  800f52:	5f                   	pop    %edi
  800f53:	5d                   	pop    %ebp
  800f54:	c3                   	ret    

00800f55 <sys_e1000_receive>:

int 
sys_e1000_receive(char* pck, size_t* length){
  800f55:	55                   	push   %ebp
  800f56:	89 e5                	mov    %esp,%ebp
  800f58:	57                   	push   %edi
  800f59:	56                   	push   %esi
  800f5a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f5b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f60:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f68:	8b 55 08             	mov    0x8(%ebp),%edx
  800f6b:	89 df                	mov    %ebx,%edi
  800f6d:	89 de                	mov    %ebx,%esi
  800f6f:	cd 30                	int    $0x30
}

int 
sys_e1000_receive(char* pck, size_t* length){
	return syscall(SYS_e1000_receive, 0, (uint32_t)pck, (uint32_t)length, 0, 0, 0);
}
  800f71:	5b                   	pop    %ebx
  800f72:	5e                   	pop    %esi
  800f73:	5f                   	pop    %edi
  800f74:	5d                   	pop    %ebp
  800f75:	c3                   	ret    

00800f76 <sys_e1000_get_mac>:

int 
sys_e1000_get_mac(uint8_t* mac_addr){
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
  800f7c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f81:	b8 11 00 00 00       	mov    $0x11,%eax
  800f86:	8b 55 08             	mov    0x8(%ebp),%edx
  800f89:	89 cb                	mov    %ecx,%ebx
  800f8b:	89 cf                	mov    %ecx,%edi
  800f8d:	89 ce                	mov    %ecx,%esi
  800f8f:	cd 30                	int    $0x30
}

int 
sys_e1000_get_mac(uint8_t* mac_addr){
	return syscall(SYS_e1000_get_mac, 0, (uint32_t)mac_addr, 0, 0, 0, 0);
}
  800f91:	5b                   	pop    %ebx
  800f92:	5e                   	pop    %esi
  800f93:	5f                   	pop    %edi
  800f94:	5d                   	pop    %ebp
  800f95:	c3                   	ret    
	...

00800f98 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f98:	55                   	push   %ebp
  800f99:	89 e5                	mov    %esp,%ebp
  800f9b:	53                   	push   %ebx
  800f9c:	83 ec 24             	sub    $0x24,%esp
  800f9f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800fa2:	8b 18                	mov    (%eax),%ebx
	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	if ((err & FEC_WR) == 0)
  800fa4:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800fa8:	75 20                	jne    800fca <pgfault+0x32>
		panic("pgfault: faulting address [%08x] not a write\n", addr);
  800faa:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800fae:	c7 44 24 08 74 35 80 	movl   $0x803574,0x8(%esp)
  800fb5:	00 
  800fb6:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  800fbd:	00 
  800fbe:	c7 04 24 f4 35 80 00 	movl   $0x8035f4,(%esp)
  800fc5:	e8 4e f2 ff ff       	call   800218 <_panic>

	void *page_aligned_addr = (void *) ROUNDDOWN(addr, PGSIZE);
  800fca:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t page_num = (uint32_t) page_aligned_addr / PGSIZE;
  800fd0:	89 d8                	mov    %ebx,%eax
  800fd2:	c1 e8 0c             	shr    $0xc,%eax
	if (!(uvpt[page_num] & PTE_COW))
  800fd5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fdc:	f6 c4 08             	test   $0x8,%ah
  800fdf:	75 1c                	jne    800ffd <pgfault+0x65>
		panic("pgfault: fault was not on a copy-on-write page\n");
  800fe1:	c7 44 24 08 a4 35 80 	movl   $0x8035a4,0x8(%esp)
  800fe8:	00 
  800fe9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ff0:	00 
  800ff1:	c7 04 24 f4 35 80 00 	movl   $0x8035f4,(%esp)
  800ff8:	e8 1b f2 ff ff       	call   800218 <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.

	// Allocate
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800ffd:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801004:	00 
  801005:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80100c:	00 
  80100d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801014:	e8 94 fc ff ff       	call   800cad <sys_page_alloc>
  801019:	85 c0                	test   %eax,%eax
  80101b:	79 20                	jns    80103d <pgfault+0xa5>
		panic("sys_page_alloc: %e\n", r);
  80101d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801021:	c7 44 24 08 ff 35 80 	movl   $0x8035ff,0x8(%esp)
  801028:	00 
  801029:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  801030:	00 
  801031:	c7 04 24 f4 35 80 00 	movl   $0x8035f4,(%esp)
  801038:	e8 db f1 ff ff       	call   800218 <_panic>

	// Copy over
	void *src_addr = (void *) ROUNDDOWN(addr, PGSIZE);
	memmove(PFTEMP, src_addr, PGSIZE);
  80103d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801044:	00 
  801045:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801049:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801050:	e8 df f9 ff ff       	call   800a34 <memmove>

	// Remap
	if ((r = sys_page_map(0, PFTEMP, 0, src_addr, PTE_P | PTE_U | PTE_W)) < 0)
  801055:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80105c:	00 
  80105d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801061:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801068:	00 
  801069:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801070:	00 
  801071:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801078:	e8 84 fc ff ff       	call   800d01 <sys_page_map>
  80107d:	85 c0                	test   %eax,%eax
  80107f:	79 20                	jns    8010a1 <pgfault+0x109>
		panic("sys_page_map: %e\n", r);
  801081:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801085:	c7 44 24 08 13 36 80 	movl   $0x803613,0x8(%esp)
  80108c:	00 
  80108d:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  801094:	00 
  801095:	c7 04 24 f4 35 80 00 	movl   $0x8035f4,(%esp)
  80109c:	e8 77 f1 ff ff       	call   800218 <_panic>

}
  8010a1:	83 c4 24             	add    $0x24,%esp
  8010a4:	5b                   	pop    %ebx
  8010a5:	5d                   	pop    %ebp
  8010a6:	c3                   	ret    

008010a7 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010a7:	55                   	push   %ebp
  8010a8:	89 e5                	mov    %esp,%ebp
  8010aa:	57                   	push   %edi
  8010ab:	56                   	push   %esi
  8010ac:	53                   	push   %ebx
  8010ad:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	int r;
	envid_t child_envid;

	set_pgfault_handler(pgfault);
  8010b0:	c7 04 24 98 0f 80 00 	movl   $0x800f98,(%esp)
  8010b7:	e8 ac 09 00 00       	call   801a68 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8010bc:	ba 07 00 00 00       	mov    $0x7,%edx
  8010c1:	89 d0                	mov    %edx,%eax
  8010c3:	cd 30                	int    $0x30
  8010c5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8010c8:	89 45 e0             	mov    %eax,-0x20(%ebp)

	child_envid = sys_exofork();
	if (child_envid < 0)
  8010cb:	85 c0                	test   %eax,%eax
  8010cd:	79 20                	jns    8010ef <fork+0x48>
		panic("sys_exofork: %e\n", child_envid);
  8010cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010d3:	c7 44 24 08 25 36 80 	movl   $0x803625,0x8(%esp)
  8010da:	00 
  8010db:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  8010e2:	00 
  8010e3:	c7 04 24 f4 35 80 00 	movl   $0x8035f4,(%esp)
  8010ea:	e8 29 f1 ff ff       	call   800218 <_panic>
	if (child_envid == 0) { // child
  8010ef:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8010f3:	75 1c                	jne    801111 <fork+0x6a>
		// Fix thisenv like dumbfork does and return 0
		thisenv = &envs[ENVX(sys_getenvid())];
  8010f5:	e8 75 fb ff ff       	call   800c6f <sys_getenvid>
  8010fa:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010ff:	c1 e0 07             	shl    $0x7,%eax
  801102:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801107:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  80110c:	e9 58 02 00 00       	jmp    801369 <fork+0x2c2>
	set_pgfault_handler(pgfault);

	child_envid = sys_exofork();
	if (child_envid < 0)
		panic("sys_exofork: %e\n", child_envid);
	if (child_envid == 0) { // child
  801111:	bf 00 00 00 00       	mov    $0x0,%edi
  801116:	be 00 00 00 00       	mov    $0x0,%esi
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
  80111b:	89 f0                	mov    %esi,%eax
  80111d:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  801120:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801127:	a8 01                	test   $0x1,%al
  801129:	0f 84 7a 01 00 00    	je     8012a9 <fork+0x202>
			((uvpt[page_num] & PTE_P) == PTE_P)) {
  80112f:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  801136:	a8 01                	test   $0x1,%al
  801138:	0f 84 6b 01 00 00    	je     8012a9 <fork+0x202>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	envid_t this_envid = thisenv->env_id;
  80113e:	a1 08 50 80 00       	mov    0x805008,%eax
  801143:	8b 40 48             	mov    0x48(%eax),%eax
  801146:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	if (uvpt[pn] & PTE_SHARE) {
  801149:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801150:	f6 c4 04             	test   $0x4,%ah
  801153:	74 52                	je     8011a7 <fork+0x100>
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  801155:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80115c:	25 07 0e 00 00       	and    $0xe07,%eax
  801161:	89 44 24 10          	mov    %eax,0x10(%esp)
  801165:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801169:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80116c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801170:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801174:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801177:	89 04 24             	mov    %eax,(%esp)
  80117a:	e8 82 fb ff ff       	call   800d01 <sys_page_map>
  80117f:	85 c0                	test   %eax,%eax
  801181:	0f 89 22 01 00 00    	jns    8012a9 <fork+0x202>
			panic("sys_page_map: %e\n", r);
  801187:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80118b:	c7 44 24 08 13 36 80 	movl   $0x803613,0x8(%esp)
  801192:	00 
  801193:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  80119a:	00 
  80119b:	c7 04 24 f4 35 80 00 	movl   $0x8035f4,(%esp)
  8011a2:	e8 71 f0 ff ff       	call   800218 <_panic>
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
  8011a7:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011ae:	f6 c4 08             	test   $0x8,%ah
  8011b1:	75 0f                	jne    8011c2 <fork+0x11b>
  8011b3:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011ba:	a8 02                	test   $0x2,%al
  8011bc:	0f 84 99 00 00 00    	je     80125b <fork+0x1b4>
		if (uvpt[pn] & PTE_U)
  8011c2:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011c9:	83 e0 04             	and    $0x4,%eax
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
  8011cc:	83 f8 01             	cmp    $0x1,%eax
  8011cf:	19 db                	sbb    %ebx,%ebx
  8011d1:	83 e3 fc             	and    $0xfffffffc,%ebx
  8011d4:	81 c3 05 08 00 00    	add    $0x805,%ebx
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
		if (uvpt[pn] & PTE_U)
			perm |= PTE_U;

		// Map page COW, U and P in child
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), perm)) < 0)
  8011da:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8011de:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8011e5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011e9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011f0:	89 04 24             	mov    %eax,(%esp)
  8011f3:	e8 09 fb ff ff       	call   800d01 <sys_page_map>
  8011f8:	85 c0                	test   %eax,%eax
  8011fa:	79 20                	jns    80121c <fork+0x175>
			panic("sys_page_map: %e\n", r);
  8011fc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801200:	c7 44 24 08 13 36 80 	movl   $0x803613,0x8(%esp)
  801207:	00 
  801208:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  80120f:	00 
  801210:	c7 04 24 f4 35 80 00 	movl   $0x8035f4,(%esp)
  801217:	e8 fc ef ff ff       	call   800218 <_panic>

		// Map page COW, U and P in parent
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), this_envid, (void *) (pn*PGSIZE), perm)) < 0)
  80121c:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801220:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801224:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801227:	89 44 24 08          	mov    %eax,0x8(%esp)
  80122b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80122f:	89 04 24             	mov    %eax,(%esp)
  801232:	e8 ca fa ff ff       	call   800d01 <sys_page_map>
  801237:	85 c0                	test   %eax,%eax
  801239:	79 6e                	jns    8012a9 <fork+0x202>
			panic("sys_page_map: %e\n", r);
  80123b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80123f:	c7 44 24 08 13 36 80 	movl   $0x803613,0x8(%esp)
  801246:	00 
  801247:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  80124e:	00 
  80124f:	c7 04 24 f4 35 80 00 	movl   $0x8035f4,(%esp)
  801256:	e8 bd ef ff ff       	call   800218 <_panic>

	} else { // map pages that are present but not writable or COW with their original permissions
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  80125b:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801262:	25 07 0e 00 00       	and    $0xe07,%eax
  801267:	89 44 24 10          	mov    %eax,0x10(%esp)
  80126b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80126f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801272:	89 44 24 08          	mov    %eax,0x8(%esp)
  801276:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80127a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80127d:	89 04 24             	mov    %eax,(%esp)
  801280:	e8 7c fa ff ff       	call   800d01 <sys_page_map>
  801285:	85 c0                	test   %eax,%eax
  801287:	79 20                	jns    8012a9 <fork+0x202>
			panic("sys_page_map: %e\n", r);
  801289:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80128d:	c7 44 24 08 13 36 80 	movl   $0x803613,0x8(%esp)
  801294:	00 
  801295:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  80129c:	00 
  80129d:	c7 04 24 f4 35 80 00 	movl   $0x8035f4,(%esp)
  8012a4:	e8 6f ef ff ff       	call   800218 <_panic>
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
  8012a9:	46                   	inc    %esi
  8012aa:	81 c7 00 10 00 00    	add    $0x1000,%edi
  8012b0:	81 fe ff eb 0e 00    	cmp    $0xeebff,%esi
  8012b6:	0f 85 5f fe ff ff    	jne    80111b <fork+0x74>
	}

	// Allocate exception stack space for child. The child can't do this themselves
	// because the mechanism by which it would is to run the pgfault handler, which
	// needs to run on the exception stack (catch 22).
	if ((r = sys_page_alloc(child_envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8012bc:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8012c3:	00 
  8012c4:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8012cb:	ee 
  8012cc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012cf:	89 04 24             	mov    %eax,(%esp)
  8012d2:	e8 d6 f9 ff ff       	call   800cad <sys_page_alloc>
  8012d7:	85 c0                	test   %eax,%eax
  8012d9:	79 20                	jns    8012fb <fork+0x254>
		panic("sys_page_alloc: %e\n", r);
  8012db:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012df:	c7 44 24 08 ff 35 80 	movl   $0x8035ff,0x8(%esp)
  8012e6:	00 
  8012e7:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  8012ee:	00 
  8012ef:	c7 04 24 f4 35 80 00 	movl   $0x8035f4,(%esp)
  8012f6:	e8 1d ef ff ff       	call   800218 <_panic>

	// Set page fault handler for the child
	if ((r = sys_env_set_pgfault_upcall(child_envid, _pgfault_upcall)) < 0)
  8012fb:	c7 44 24 04 dc 1a 80 	movl   $0x801adc,0x4(%esp)
  801302:	00 
  801303:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801306:	89 04 24             	mov    %eax,(%esp)
  801309:	e8 3f fb ff ff       	call   800e4d <sys_env_set_pgfault_upcall>
  80130e:	85 c0                	test   %eax,%eax
  801310:	79 20                	jns    801332 <fork+0x28b>
		panic("sys_env_set_pgfault_upcall: %e\n", r);
  801312:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801316:	c7 44 24 08 d4 35 80 	movl   $0x8035d4,0x8(%esp)
  80131d:	00 
  80131e:	c7 44 24 04 a1 00 00 	movl   $0xa1,0x4(%esp)
  801325:	00 
  801326:	c7 04 24 f4 35 80 00 	movl   $0x8035f4,(%esp)
  80132d:	e8 e6 ee ff ff       	call   800218 <_panic>

	// Mark child environment as runnable
	if ((r = sys_env_set_status(child_envid, ENV_RUNNABLE)) < 0)
  801332:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801339:	00 
  80133a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80133d:	89 04 24             	mov    %eax,(%esp)
  801340:	e8 62 fa ff ff       	call   800da7 <sys_env_set_status>
  801345:	85 c0                	test   %eax,%eax
  801347:	79 20                	jns    801369 <fork+0x2c2>
		panic("sys_env_set_status: %e\n", r);
  801349:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80134d:	c7 44 24 08 36 36 80 	movl   $0x803636,0x8(%esp)
  801354:	00 
  801355:	c7 44 24 04 a5 00 00 	movl   $0xa5,0x4(%esp)
  80135c:	00 
  80135d:	c7 04 24 f4 35 80 00 	movl   $0x8035f4,(%esp)
  801364:	e8 af ee ff ff       	call   800218 <_panic>

	return child_envid;
}
  801369:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80136c:	83 c4 3c             	add    $0x3c,%esp
  80136f:	5b                   	pop    %ebx
  801370:	5e                   	pop    %esi
  801371:	5f                   	pop    %edi
  801372:	5d                   	pop    %ebp
  801373:	c3                   	ret    

00801374 <sfork>:

// Challenge!
int
sfork(void)
{
  801374:	55                   	push   %ebp
  801375:	89 e5                	mov    %esp,%ebp
  801377:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  80137a:	c7 44 24 08 4e 36 80 	movl   $0x80364e,0x8(%esp)
  801381:	00 
  801382:	c7 44 24 04 ae 00 00 	movl   $0xae,0x4(%esp)
  801389:	00 
  80138a:	c7 04 24 f4 35 80 00 	movl   $0x8035f4,(%esp)
  801391:	e8 82 ee ff ff       	call   800218 <_panic>
	...

00801398 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801398:	55                   	push   %ebp
  801399:	89 e5                	mov    %esp,%ebp
  80139b:	57                   	push   %edi
  80139c:	56                   	push   %esi
  80139d:	53                   	push   %ebx
  80139e:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8013a4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8013ab:	00 
  8013ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8013af:	89 04 24             	mov    %eax,(%esp)
  8013b2:	e8 39 0f 00 00       	call   8022f0 <open>
  8013b7:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
  8013bd:	85 c0                	test   %eax,%eax
  8013bf:	0f 88 86 05 00 00    	js     80194b <spawn+0x5b3>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8013c5:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8013cc:	00 
  8013cd:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8013d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d7:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  8013dd:	89 04 24             	mov    %eax,(%esp)
  8013e0:	e8 c5 0a 00 00       	call   801eaa <readn>
  8013e5:	3d 00 02 00 00       	cmp    $0x200,%eax
  8013ea:	75 0c                	jne    8013f8 <spawn+0x60>
	    || elf->e_magic != ELF_MAGIC) {
  8013ec:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8013f3:	45 4c 46 
  8013f6:	74 3b                	je     801433 <spawn+0x9b>
		close(fd);
  8013f8:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  8013fe:	89 04 24             	mov    %eax,(%esp)
  801401:	e8 b0 08 00 00       	call   801cb6 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801406:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  80140d:	46 
  80140e:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  801414:	89 44 24 04          	mov    %eax,0x4(%esp)
  801418:	c7 04 24 64 36 80 00 	movl   $0x803664,(%esp)
  80141f:	e8 ec ee ff ff       	call   800310 <cprintf>
		return -E_NOT_EXEC;
  801424:	c7 85 88 fd ff ff f2 	movl   $0xfffffff2,-0x278(%ebp)
  80142b:	ff ff ff 
  80142e:	e9 24 05 00 00       	jmp    801957 <spawn+0x5bf>
  801433:	ba 07 00 00 00       	mov    $0x7,%edx
  801438:	89 d0                	mov    %edx,%eax
  80143a:	cd 30                	int    $0x30
  80143c:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801442:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801448:	85 c0                	test   %eax,%eax
  80144a:	0f 88 07 05 00 00    	js     801957 <spawn+0x5bf>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801450:	89 c6                	mov    %eax,%esi
  801452:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801458:	c1 e6 07             	shl    $0x7,%esi
  80145b:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801461:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801467:	b9 11 00 00 00       	mov    $0x11,%ecx
  80146c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  80146e:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801474:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80147a:	be 00 00 00 00       	mov    $0x0,%esi
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  80147f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801484:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801487:	eb 0d                	jmp    801496 <spawn+0xfe>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801489:	89 04 24             	mov    %eax,(%esp)
  80148c:	e8 f7 f3 ff ff       	call   800888 <strlen>
  801491:	8d 5c 18 01          	lea    0x1(%eax,%ebx,1),%ebx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801495:	46                   	inc    %esi
  801496:	89 f2                	mov    %esi,%edx
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801498:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80149f:	8b 04 b7             	mov    (%edi,%esi,4),%eax
  8014a2:	85 c0                	test   %eax,%eax
  8014a4:	75 e3                	jne    801489 <spawn+0xf1>
  8014a6:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
  8014ac:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8014b2:	bf 00 10 40 00       	mov    $0x401000,%edi
  8014b7:	29 df                	sub    %ebx,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8014b9:	89 f8                	mov    %edi,%eax
  8014bb:	83 e0 fc             	and    $0xfffffffc,%eax
  8014be:	f7 d2                	not    %edx
  8014c0:	8d 14 90             	lea    (%eax,%edx,4),%edx
  8014c3:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8014c9:	89 d0                	mov    %edx,%eax
  8014cb:	83 e8 08             	sub    $0x8,%eax
  8014ce:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8014d3:	0f 86 8f 04 00 00    	jbe    801968 <spawn+0x5d0>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8014d9:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8014e0:	00 
  8014e1:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8014e8:	00 
  8014e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014f0:	e8 b8 f7 ff ff       	call   800cad <sys_page_alloc>
  8014f5:	85 c0                	test   %eax,%eax
  8014f7:	0f 88 70 04 00 00    	js     80196d <spawn+0x5d5>
  8014fd:	bb 00 00 00 00       	mov    $0x0,%ebx
  801502:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  801508:	8b 75 0c             	mov    0xc(%ebp),%esi
  80150b:	eb 2e                	jmp    80153b <spawn+0x1a3>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  80150d:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801513:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801519:	89 04 9a             	mov    %eax,(%edx,%ebx,4)
		strcpy(string_store, argv[i]);
  80151c:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  80151f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801523:	89 3c 24             	mov    %edi,(%esp)
  801526:	e8 90 f3 ff ff       	call   8008bb <strcpy>
		string_store += strlen(argv[i]) + 1;
  80152b:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  80152e:	89 04 24             	mov    %eax,(%esp)
  801531:	e8 52 f3 ff ff       	call   800888 <strlen>
  801536:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  80153a:	43                   	inc    %ebx
  80153b:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801541:	7c ca                	jl     80150d <spawn+0x175>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801543:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801549:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  80154f:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801556:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  80155c:	74 24                	je     801582 <spawn+0x1ea>
  80155e:	c7 44 24 0c 04 37 80 	movl   $0x803704,0xc(%esp)
  801565:	00 
  801566:	c7 44 24 08 7e 36 80 	movl   $0x80367e,0x8(%esp)
  80156d:	00 
  80156e:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
  801575:	00 
  801576:	c7 04 24 93 36 80 00 	movl   $0x803693,(%esp)
  80157d:	e8 96 ec ff ff       	call   800218 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801582:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801588:	2d 00 30 80 11       	sub    $0x11803000,%eax
  80158d:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801593:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  801596:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  80159c:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  80159f:	89 d0                	mov    %edx,%eax
  8015a1:	2d 08 30 80 11       	sub    $0x11803008,%eax
  8015a6:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8015ac:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8015b3:	00 
  8015b4:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  8015bb:	ee 
  8015bc:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8015c2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015c6:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8015cd:	00 
  8015ce:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015d5:	e8 27 f7 ff ff       	call   800d01 <sys_page_map>
  8015da:	89 c3                	mov    %eax,%ebx
  8015dc:	85 c0                	test   %eax,%eax
  8015de:	78 1a                	js     8015fa <spawn+0x262>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8015e0:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8015e7:	00 
  8015e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015ef:	e8 60 f7 ff ff       	call   800d54 <sys_page_unmap>
  8015f4:	89 c3                	mov    %eax,%ebx
  8015f6:	85 c0                	test   %eax,%eax
  8015f8:	79 1f                	jns    801619 <spawn+0x281>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  8015fa:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801601:	00 
  801602:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801609:	e8 46 f7 ff ff       	call   800d54 <sys_page_unmap>
	return r;
  80160e:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801614:	e9 3e 03 00 00       	jmp    801957 <spawn+0x5bf>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801619:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  80161f:	03 95 04 fe ff ff    	add    -0x1fc(%ebp),%edx
  801625:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80162b:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  801632:	00 00 00 
  801635:	e9 bb 01 00 00       	jmp    8017f5 <spawn+0x45d>
		if (ph->p_type != ELF_PROG_LOAD)
  80163a:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801640:	83 38 01             	cmpl   $0x1,(%eax)
  801643:	0f 85 9f 01 00 00    	jne    8017e8 <spawn+0x450>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801649:	89 c2                	mov    %eax,%edx
  80164b:	8b 40 18             	mov    0x18(%eax),%eax
  80164e:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  801651:	83 f8 01             	cmp    $0x1,%eax
  801654:	19 c0                	sbb    %eax,%eax
  801656:	83 e0 fe             	and    $0xfffffffe,%eax
  801659:	83 c0 07             	add    $0x7,%eax
  80165c:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801662:	8b 52 04             	mov    0x4(%edx),%edx
  801665:	89 95 78 fd ff ff    	mov    %edx,-0x288(%ebp)
  80166b:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801671:	8b 40 10             	mov    0x10(%eax),%eax
  801674:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  80167a:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  801680:	8b 52 14             	mov    0x14(%edx),%edx
  801683:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  801689:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  80168f:	8b 78 08             	mov    0x8(%eax),%edi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801692:	89 f8                	mov    %edi,%eax
  801694:	25 ff 0f 00 00       	and    $0xfff,%eax
  801699:	74 16                	je     8016b1 <spawn+0x319>
		va -= i;
  80169b:	29 c7                	sub    %eax,%edi
		memsz += i;
  80169d:	01 c2                	add    %eax,%edx
  80169f:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
		filesz += i;
  8016a5:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  8016ab:	29 85 78 fd ff ff    	sub    %eax,-0x288(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8016b1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016b6:	e9 1f 01 00 00       	jmp    8017da <spawn+0x442>
		if (i >= filesz) {
  8016bb:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  8016c1:	77 2b                	ja     8016ee <spawn+0x356>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  8016c3:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  8016c9:	89 54 24 08          	mov    %edx,0x8(%esp)
  8016cd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8016d1:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8016d7:	89 04 24             	mov    %eax,(%esp)
  8016da:	e8 ce f5 ff ff       	call   800cad <sys_page_alloc>
  8016df:	85 c0                	test   %eax,%eax
  8016e1:	0f 89 e7 00 00 00    	jns    8017ce <spawn+0x436>
  8016e7:	89 c6                	mov    %eax,%esi
  8016e9:	e9 39 02 00 00       	jmp    801927 <spawn+0x58f>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8016ee:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8016f5:	00 
  8016f6:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8016fd:	00 
  8016fe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801705:	e8 a3 f5 ff ff       	call   800cad <sys_page_alloc>
  80170a:	85 c0                	test   %eax,%eax
  80170c:	0f 88 0b 02 00 00    	js     80191d <spawn+0x585>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801712:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  801718:	01 f0                	add    %esi,%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  80171a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80171e:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801724:	89 04 24             	mov    %eax,(%esp)
  801727:	e8 54 08 00 00       	call   801f80 <seek>
  80172c:	85 c0                	test   %eax,%eax
  80172e:	0f 88 ed 01 00 00    	js     801921 <spawn+0x589>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801734:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  80173a:	29 f0                	sub    %esi,%eax
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  80173c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801741:	76 05                	jbe    801748 <spawn+0x3b0>
  801743:	b8 00 10 00 00       	mov    $0x1000,%eax
  801748:	89 44 24 08          	mov    %eax,0x8(%esp)
  80174c:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801753:	00 
  801754:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  80175a:	89 04 24             	mov    %eax,(%esp)
  80175d:	e8 48 07 00 00       	call   801eaa <readn>
  801762:	85 c0                	test   %eax,%eax
  801764:	0f 88 bb 01 00 00    	js     801925 <spawn+0x58d>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  80176a:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  801770:	89 54 24 10          	mov    %edx,0x10(%esp)
  801774:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801778:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  80177e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801782:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801789:	00 
  80178a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801791:	e8 6b f5 ff ff       	call   800d01 <sys_page_map>
  801796:	85 c0                	test   %eax,%eax
  801798:	79 20                	jns    8017ba <spawn+0x422>
				panic("spawn: sys_page_map data: %e", r);
  80179a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80179e:	c7 44 24 08 9f 36 80 	movl   $0x80369f,0x8(%esp)
  8017a5:	00 
  8017a6:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
  8017ad:	00 
  8017ae:	c7 04 24 93 36 80 00 	movl   $0x803693,(%esp)
  8017b5:	e8 5e ea ff ff       	call   800218 <_panic>
			sys_page_unmap(0, UTEMP);
  8017ba:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8017c1:	00 
  8017c2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017c9:	e8 86 f5 ff ff       	call   800d54 <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8017ce:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8017d4:	81 c7 00 10 00 00    	add    $0x1000,%edi
  8017da:	89 de                	mov    %ebx,%esi
  8017dc:	3b 9d 8c fd ff ff    	cmp    -0x274(%ebp),%ebx
  8017e2:	0f 82 d3 fe ff ff    	jb     8016bb <spawn+0x323>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8017e8:	ff 85 7c fd ff ff    	incl   -0x284(%ebp)
  8017ee:	83 85 80 fd ff ff 20 	addl   $0x20,-0x280(%ebp)
  8017f5:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  8017fc:	39 85 7c fd ff ff    	cmp    %eax,-0x284(%ebp)
  801802:	0f 8c 32 fe ff ff    	jl     80163a <spawn+0x2a2>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801808:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  80180e:	89 04 24             	mov    %eax,(%esp)
  801811:	e8 a0 04 00 00       	call   801cb6 <close>
{
	// LAB 5: Your code here.
	int r;
	uint32_t page_num;
	
	for (page_num = 0; page_num < PGNUM(UTOP); page_num++) {
  801816:	be 00 00 00 00       	mov    $0x0,%esi
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES)/NPDENTRIES;
  80181b:	89 f0                	mov    %esi,%eax
  80181d:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx]&PTE_P) && (uvpt[page_num]&PTE_P) && (uvpt[page_num]&PTE_SHARE)){
  801820:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801827:	a8 01                	test   $0x1,%al
  801829:	0f 84 82 00 00 00    	je     8018b1 <spawn+0x519>
  80182f:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801836:	a8 01                	test   $0x1,%al
  801838:	74 77                	je     8018b1 <spawn+0x519>
  80183a:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801841:	f6 c4 04             	test   $0x4,%ah
  801844:	74 6b                	je     8018b1 <spawn+0x519>
			if ((r = sys_page_map(sys_getenvid(), (void*)(page_num*PGSIZE), child, (void*)(page_num*PGSIZE), uvpt[page_num]&PTE_SYSCALL)) < 0){
  801846:	8b 3c b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edi
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  80184d:	89 f3                	mov    %esi,%ebx
  80184f:	c1 e3 0c             	shl    $0xc,%ebx
	uint32_t page_num;
	
	for (page_num = 0; page_num < PGNUM(UTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES)/NPDENTRIES;
		if ((uvpd[pdx]&PTE_P) && (uvpt[page_num]&PTE_P) && (uvpt[page_num]&PTE_SHARE)){
			if ((r = sys_page_map(sys_getenvid(), (void*)(page_num*PGSIZE), child, (void*)(page_num*PGSIZE), uvpt[page_num]&PTE_SYSCALL)) < 0){
  801852:	e8 18 f4 ff ff       	call   800c6f <sys_getenvid>
  801857:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  80185d:	89 7c 24 10          	mov    %edi,0x10(%esp)
  801861:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801865:	8b 95 88 fd ff ff    	mov    -0x278(%ebp),%edx
  80186b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80186f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801873:	89 04 24             	mov    %eax,(%esp)
  801876:	e8 86 f4 ff ff       	call   800d01 <sys_page_map>
  80187b:	85 c0                	test   %eax,%eax
  80187d:	79 32                	jns    8018b1 <spawn+0x519>
  80187f:	89 c3                	mov    %eax,%ebx
				cprintf("copy_shared_pages: sys_page_map failed, %e", r);
  801881:	89 44 24 04          	mov    %eax,0x4(%esp)
  801885:	c7 04 24 2c 37 80 00 	movl   $0x80372c,(%esp)
  80188c:	e8 7f ea ff ff       	call   800310 <cprintf>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801891:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801895:	c7 44 24 08 bc 36 80 	movl   $0x8036bc,0x8(%esp)
  80189c:	00 
  80189d:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  8018a4:	00 
  8018a5:	c7 04 24 93 36 80 00 	movl   $0x803693,(%esp)
  8018ac:	e8 67 e9 ff ff       	call   800218 <_panic>
{
	// LAB 5: Your code here.
	int r;
	uint32_t page_num;
	
	for (page_num = 0; page_num < PGNUM(UTOP); page_num++) {
  8018b1:	46                   	inc    %esi
  8018b2:	81 fe 00 ec 0e 00    	cmp    $0xeec00,%esi
  8018b8:	0f 85 5d ff ff ff    	jne    80181b <spawn+0x483>
  8018be:	e9 b2 00 00 00       	jmp    801975 <spawn+0x5dd>
	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  8018c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018c7:	c7 44 24 08 d2 36 80 	movl   $0x8036d2,0x8(%esp)
  8018ce:	00 
  8018cf:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  8018d6:	00 
  8018d7:	c7 04 24 93 36 80 00 	movl   $0x803693,(%esp)
  8018de:	e8 35 e9 ff ff       	call   800218 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  8018e3:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8018ea:	00 
  8018eb:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8018f1:	89 04 24             	mov    %eax,(%esp)
  8018f4:	e8 ae f4 ff ff       	call   800da7 <sys_env_set_status>
  8018f9:	85 c0                	test   %eax,%eax
  8018fb:	79 5a                	jns    801957 <spawn+0x5bf>
		panic("sys_env_set_status: %e", r);
  8018fd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801901:	c7 44 24 08 ec 36 80 	movl   $0x8036ec,0x8(%esp)
  801908:	00 
  801909:	c7 44 24 04 88 00 00 	movl   $0x88,0x4(%esp)
  801910:	00 
  801911:	c7 04 24 93 36 80 00 	movl   $0x803693,(%esp)
  801918:	e8 fb e8 ff ff       	call   800218 <_panic>
  80191d:	89 c6                	mov    %eax,%esi
  80191f:	eb 06                	jmp    801927 <spawn+0x58f>
  801921:	89 c6                	mov    %eax,%esi
  801923:	eb 02                	jmp    801927 <spawn+0x58f>
  801925:	89 c6                	mov    %eax,%esi

	return child;

error:
	sys_env_destroy(child);
  801927:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  80192d:	89 04 24             	mov    %eax,(%esp)
  801930:	e8 e8 f2 ff ff       	call   800c1d <sys_env_destroy>
	close(fd);
  801935:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  80193b:	89 04 24             	mov    %eax,(%esp)
  80193e:	e8 73 03 00 00       	call   801cb6 <close>
	return r;
  801943:	89 b5 88 fd ff ff    	mov    %esi,-0x278(%ebp)
  801949:	eb 0c                	jmp    801957 <spawn+0x5bf>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  80194b:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801951:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801957:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  80195d:	81 c4 ac 02 00 00    	add    $0x2ac,%esp
  801963:	5b                   	pop    %ebx
  801964:	5e                   	pop    %esi
  801965:	5f                   	pop    %edi
  801966:	5d                   	pop    %ebp
  801967:	c3                   	ret    
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801968:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  80196d:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  801973:	eb e2                	jmp    801957 <spawn+0x5bf>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801975:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  80197b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80197f:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801985:	89 04 24             	mov    %eax,(%esp)
  801988:	e8 6d f4 ff ff       	call   800dfa <sys_env_set_trapframe>
  80198d:	85 c0                	test   %eax,%eax
  80198f:	0f 89 4e ff ff ff    	jns    8018e3 <spawn+0x54b>
  801995:	e9 29 ff ff ff       	jmp    8018c3 <spawn+0x52b>

0080199a <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  80199a:	55                   	push   %ebp
  80199b:	89 e5                	mov    %esp,%ebp
  80199d:	57                   	push   %edi
  80199e:	56                   	push   %esi
  80199f:	53                   	push   %ebx
  8019a0:	83 ec 1c             	sub    $0x1c,%esp
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
  8019a3:	8d 45 10             	lea    0x10(%ebp),%eax
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  8019a6:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8019ab:	eb 03                	jmp    8019b0 <spawnl+0x16>
		argc++;
  8019ad:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8019ae:	89 d0                	mov    %edx,%eax
  8019b0:	8d 50 04             	lea    0x4(%eax),%edx
  8019b3:	83 38 00             	cmpl   $0x0,(%eax)
  8019b6:	75 f5                	jne    8019ad <spawnl+0x13>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  8019b8:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  8019bf:	83 e0 f0             	and    $0xfffffff0,%eax
  8019c2:	29 c4                	sub    %eax,%esp
  8019c4:	8d 7c 24 17          	lea    0x17(%esp),%edi
  8019c8:	83 e7 f0             	and    $0xfffffff0,%edi
  8019cb:	89 fe                	mov    %edi,%esi
	argv[0] = arg0;
  8019cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019d0:	89 07                	mov    %eax,(%edi)
	argv[argc+1] = NULL;
  8019d2:	c7 44 8f 04 00 00 00 	movl   $0x0,0x4(%edi,%ecx,4)
  8019d9:	00 

	va_start(vl, arg0);
  8019da:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  8019dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8019e2:	eb 09                	jmp    8019ed <spawnl+0x53>
		argv[i+1] = va_arg(vl, const char *);
  8019e4:	40                   	inc    %eax
  8019e5:	8b 1a                	mov    (%edx),%ebx
  8019e7:	89 1c 86             	mov    %ebx,(%esi,%eax,4)
  8019ea:	8d 52 04             	lea    0x4(%edx),%edx
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  8019ed:	39 c8                	cmp    %ecx,%eax
  8019ef:	75 f3                	jne    8019e4 <spawnl+0x4a>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  8019f1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8019f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f8:	89 04 24             	mov    %eax,(%esp)
  8019fb:	e8 98 f9 ff ff       	call   801398 <spawn>
}
  801a00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a03:	5b                   	pop    %ebx
  801a04:	5e                   	pop    %esi
  801a05:	5f                   	pop    %edi
  801a06:	5d                   	pop    %ebp
  801a07:	c3                   	ret    

00801a08 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801a08:	55                   	push   %ebp
  801a09:	89 e5                	mov    %esp,%ebp
  801a0b:	56                   	push   %esi
  801a0c:	53                   	push   %ebx
  801a0d:	83 ec 10             	sub    $0x10,%esp
  801a10:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801a13:	85 f6                	test   %esi,%esi
  801a15:	75 24                	jne    801a3b <wait+0x33>
  801a17:	c7 44 24 0c 57 37 80 	movl   $0x803757,0xc(%esp)
  801a1e:	00 
  801a1f:	c7 44 24 08 7e 36 80 	movl   $0x80367e,0x8(%esp)
  801a26:	00 
  801a27:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  801a2e:	00 
  801a2f:	c7 04 24 62 37 80 00 	movl   $0x803762,(%esp)
  801a36:	e8 dd e7 ff ff       	call   800218 <_panic>
	e = &envs[ENVX(envid)];
  801a3b:	89 f3                	mov    %esi,%ebx
  801a3d:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  801a43:	c1 e3 07             	shl    $0x7,%ebx
  801a46:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801a4c:	eb 05                	jmp    801a53 <wait+0x4b>
		sys_yield();
  801a4e:	e8 3b f2 ff ff       	call   800c8e <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801a53:	8b 43 48             	mov    0x48(%ebx),%eax
  801a56:	39 f0                	cmp    %esi,%eax
  801a58:	75 07                	jne    801a61 <wait+0x59>
  801a5a:	8b 43 54             	mov    0x54(%ebx),%eax
  801a5d:	85 c0                	test   %eax,%eax
  801a5f:	75 ed                	jne    801a4e <wait+0x46>
		sys_yield();
}
  801a61:	83 c4 10             	add    $0x10,%esp
  801a64:	5b                   	pop    %ebx
  801a65:	5e                   	pop    %esi
  801a66:	5d                   	pop    %ebp
  801a67:	c3                   	ret    

00801a68 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801a68:	55                   	push   %ebp
  801a69:	89 e5                	mov    %esp,%ebp
  801a6b:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801a6e:	83 3d 0c 50 80 00 00 	cmpl   $0x0,0x80500c
  801a75:	75 58                	jne    801acf <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.	
		//panic("set_pgfault_handler not implemented");
		
		if (sys_page_alloc(thisenv->env_id,(void *) (UXSTACKTOP - PGSIZE),(PTE_W|PTE_U|PTE_P)) != 0){
  801a77:	a1 08 50 80 00       	mov    0x805008,%eax
  801a7c:	8b 40 48             	mov    0x48(%eax),%eax
  801a7f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801a86:	00 
  801a87:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801a8e:	ee 
  801a8f:	89 04 24             	mov    %eax,(%esp)
  801a92:	e8 16 f2 ff ff       	call   800cad <sys_page_alloc>
  801a97:	85 c0                	test   %eax,%eax
  801a99:	74 1c                	je     801ab7 <set_pgfault_handler+0x4f>
			panic("set_pg_fault_handler");
  801a9b:	c7 44 24 08 6d 37 80 	movl   $0x80376d,0x8(%esp)
  801aa2:	00 
  801aa3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801aaa:	00 
  801aab:	c7 04 24 82 37 80 00 	movl   $0x803782,(%esp)
  801ab2:	e8 61 e7 ff ff       	call   800218 <_panic>
		}
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801ab7:	a1 08 50 80 00       	mov    0x805008,%eax
  801abc:	8b 40 48             	mov    0x48(%eax),%eax
  801abf:	c7 44 24 04 dc 1a 80 	movl   $0x801adc,0x4(%esp)
  801ac6:	00 
  801ac7:	89 04 24             	mov    %eax,(%esp)
  801aca:	e8 7e f3 ff ff       	call   800e4d <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801acf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad2:	a3 0c 50 80 00       	mov    %eax,0x80500c
}
  801ad7:	c9                   	leave  
  801ad8:	c3                   	ret    
  801ad9:	00 00                	add    %al,(%eax)
	...

00801adc <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801adc:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801add:	a1 0c 50 80 00       	mov    0x80500c,%eax
	call *%eax
  801ae2:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801ae4:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// Save trap-time eip in eax
	movl 0x28(%esp), %eax
  801ae7:	8b 44 24 28          	mov    0x28(%esp),%eax

	// Save our current stack
	movl %esp, %ebp
  801aeb:	89 e5                	mov    %esp,%ebp

	// Switch to trap-time stack
	movl 0x30(%esp), %esp
  801aed:	8b 64 24 30          	mov    0x30(%esp),%esp

	// Push trap-time eip to the trap-time stack
	pushl %eax
  801af1:	50                   	push   %eax

	// We now have to update the trap-time esp with its new value
	movl %esp, 0x30(%ebp)
  801af2:	89 65 30             	mov    %esp,0x30(%ebp)

	// Go back to our exception stack
	movl %ebp, %esp
  801af5:	89 ec                	mov    %ebp,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// Pop fault_va and err, both can be ignored
	popl %eax
  801af7:	58                   	pop    %eax
	popl %eax
  801af8:	58                   	pop    %eax

	// Pop all registers back
	popal
  801af9:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// Skip %eip
	addl $0x4, %esp
  801afa:	83 c4 04             	add    $0x4,%esp

	// Pop eflags back
	popfl
  801afd:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	
	popl %esp
  801afe:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  801aff:	c3                   	ret    

00801b00 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801b00:	55                   	push   %ebp
  801b01:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801b03:	8b 45 08             	mov    0x8(%ebp),%eax
  801b06:	05 00 00 00 30       	add    $0x30000000,%eax
  801b0b:	c1 e8 0c             	shr    $0xc,%eax
}
  801b0e:	5d                   	pop    %ebp
  801b0f:	c3                   	ret    

00801b10 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801b10:	55                   	push   %ebp
  801b11:	89 e5                	mov    %esp,%ebp
  801b13:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801b16:	8b 45 08             	mov    0x8(%ebp),%eax
  801b19:	89 04 24             	mov    %eax,(%esp)
  801b1c:	e8 df ff ff ff       	call   801b00 <fd2num>
  801b21:	05 20 00 0d 00       	add    $0xd0020,%eax
  801b26:	c1 e0 0c             	shl    $0xc,%eax
}
  801b29:	c9                   	leave  
  801b2a:	c3                   	ret    

00801b2b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801b2b:	55                   	push   %ebp
  801b2c:	89 e5                	mov    %esp,%ebp
  801b2e:	53                   	push   %ebx
  801b2f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801b32:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801b37:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801b39:	89 c2                	mov    %eax,%edx
  801b3b:	c1 ea 16             	shr    $0x16,%edx
  801b3e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801b45:	f6 c2 01             	test   $0x1,%dl
  801b48:	74 11                	je     801b5b <fd_alloc+0x30>
  801b4a:	89 c2                	mov    %eax,%edx
  801b4c:	c1 ea 0c             	shr    $0xc,%edx
  801b4f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801b56:	f6 c2 01             	test   $0x1,%dl
  801b59:	75 09                	jne    801b64 <fd_alloc+0x39>
			*fd_store = fd;
  801b5b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801b5d:	b8 00 00 00 00       	mov    $0x0,%eax
  801b62:	eb 17                	jmp    801b7b <fd_alloc+0x50>
  801b64:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801b69:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801b6e:	75 c7                	jne    801b37 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801b70:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801b76:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801b7b:	5b                   	pop    %ebx
  801b7c:	5d                   	pop    %ebp
  801b7d:	c3                   	ret    

00801b7e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801b7e:	55                   	push   %ebp
  801b7f:	89 e5                	mov    %esp,%ebp
  801b81:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801b84:	83 f8 1f             	cmp    $0x1f,%eax
  801b87:	77 36                	ja     801bbf <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801b89:	05 00 00 0d 00       	add    $0xd0000,%eax
  801b8e:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801b91:	89 c2                	mov    %eax,%edx
  801b93:	c1 ea 16             	shr    $0x16,%edx
  801b96:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801b9d:	f6 c2 01             	test   $0x1,%dl
  801ba0:	74 24                	je     801bc6 <fd_lookup+0x48>
  801ba2:	89 c2                	mov    %eax,%edx
  801ba4:	c1 ea 0c             	shr    $0xc,%edx
  801ba7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801bae:	f6 c2 01             	test   $0x1,%dl
  801bb1:	74 1a                	je     801bcd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801bb3:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bb6:	89 02                	mov    %eax,(%edx)
	return 0;
  801bb8:	b8 00 00 00 00       	mov    $0x0,%eax
  801bbd:	eb 13                	jmp    801bd2 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801bbf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801bc4:	eb 0c                	jmp    801bd2 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801bc6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801bcb:	eb 05                	jmp    801bd2 <fd_lookup+0x54>
  801bcd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801bd2:	5d                   	pop    %ebp
  801bd3:	c3                   	ret    

00801bd4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801bd4:	55                   	push   %ebp
  801bd5:	89 e5                	mov    %esp,%ebp
  801bd7:	53                   	push   %ebx
  801bd8:	83 ec 14             	sub    $0x14,%esp
  801bdb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bde:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801be1:	ba 00 00 00 00       	mov    $0x0,%edx
  801be6:	eb 0e                	jmp    801bf6 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801be8:	39 08                	cmp    %ecx,(%eax)
  801bea:	75 09                	jne    801bf5 <dev_lookup+0x21>
			*dev = devtab[i];
  801bec:	89 03                	mov    %eax,(%ebx)
			return 0;
  801bee:	b8 00 00 00 00       	mov    $0x0,%eax
  801bf3:	eb 33                	jmp    801c28 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801bf5:	42                   	inc    %edx
  801bf6:	8b 04 95 0c 38 80 00 	mov    0x80380c(,%edx,4),%eax
  801bfd:	85 c0                	test   %eax,%eax
  801bff:	75 e7                	jne    801be8 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801c01:	a1 08 50 80 00       	mov    0x805008,%eax
  801c06:	8b 40 48             	mov    0x48(%eax),%eax
  801c09:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c11:	c7 04 24 90 37 80 00 	movl   $0x803790,(%esp)
  801c18:	e8 f3 e6 ff ff       	call   800310 <cprintf>
	*dev = 0;
  801c1d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801c23:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801c28:	83 c4 14             	add    $0x14,%esp
  801c2b:	5b                   	pop    %ebx
  801c2c:	5d                   	pop    %ebp
  801c2d:	c3                   	ret    

00801c2e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801c2e:	55                   	push   %ebp
  801c2f:	89 e5                	mov    %esp,%ebp
  801c31:	56                   	push   %esi
  801c32:	53                   	push   %ebx
  801c33:	83 ec 30             	sub    $0x30,%esp
  801c36:	8b 75 08             	mov    0x8(%ebp),%esi
  801c39:	8a 45 0c             	mov    0xc(%ebp),%al
  801c3c:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801c3f:	89 34 24             	mov    %esi,(%esp)
  801c42:	e8 b9 fe ff ff       	call   801b00 <fd2num>
  801c47:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801c4a:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c4e:	89 04 24             	mov    %eax,(%esp)
  801c51:	e8 28 ff ff ff       	call   801b7e <fd_lookup>
  801c56:	89 c3                	mov    %eax,%ebx
  801c58:	85 c0                	test   %eax,%eax
  801c5a:	78 05                	js     801c61 <fd_close+0x33>
	    || fd != fd2)
  801c5c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801c5f:	74 0d                	je     801c6e <fd_close+0x40>
		return (must_exist ? r : 0);
  801c61:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801c65:	75 46                	jne    801cad <fd_close+0x7f>
  801c67:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c6c:	eb 3f                	jmp    801cad <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801c6e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c71:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c75:	8b 06                	mov    (%esi),%eax
  801c77:	89 04 24             	mov    %eax,(%esp)
  801c7a:	e8 55 ff ff ff       	call   801bd4 <dev_lookup>
  801c7f:	89 c3                	mov    %eax,%ebx
  801c81:	85 c0                	test   %eax,%eax
  801c83:	78 18                	js     801c9d <fd_close+0x6f>
		if (dev->dev_close)
  801c85:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c88:	8b 40 10             	mov    0x10(%eax),%eax
  801c8b:	85 c0                	test   %eax,%eax
  801c8d:	74 09                	je     801c98 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801c8f:	89 34 24             	mov    %esi,(%esp)
  801c92:	ff d0                	call   *%eax
  801c94:	89 c3                	mov    %eax,%ebx
  801c96:	eb 05                	jmp    801c9d <fd_close+0x6f>
		else
			r = 0;
  801c98:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801c9d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ca1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ca8:	e8 a7 f0 ff ff       	call   800d54 <sys_page_unmap>
	return r;
}
  801cad:	89 d8                	mov    %ebx,%eax
  801caf:	83 c4 30             	add    $0x30,%esp
  801cb2:	5b                   	pop    %ebx
  801cb3:	5e                   	pop    %esi
  801cb4:	5d                   	pop    %ebp
  801cb5:	c3                   	ret    

00801cb6 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801cb6:	55                   	push   %ebp
  801cb7:	89 e5                	mov    %esp,%ebp
  801cb9:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cbc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cbf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cc3:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc6:	89 04 24             	mov    %eax,(%esp)
  801cc9:	e8 b0 fe ff ff       	call   801b7e <fd_lookup>
  801cce:	85 c0                	test   %eax,%eax
  801cd0:	78 13                	js     801ce5 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801cd2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801cd9:	00 
  801cda:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cdd:	89 04 24             	mov    %eax,(%esp)
  801ce0:	e8 49 ff ff ff       	call   801c2e <fd_close>
}
  801ce5:	c9                   	leave  
  801ce6:	c3                   	ret    

00801ce7 <close_all>:

void
close_all(void)
{
  801ce7:	55                   	push   %ebp
  801ce8:	89 e5                	mov    %esp,%ebp
  801cea:	53                   	push   %ebx
  801ceb:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801cee:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801cf3:	89 1c 24             	mov    %ebx,(%esp)
  801cf6:	e8 bb ff ff ff       	call   801cb6 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801cfb:	43                   	inc    %ebx
  801cfc:	83 fb 20             	cmp    $0x20,%ebx
  801cff:	75 f2                	jne    801cf3 <close_all+0xc>
		close(i);
}
  801d01:	83 c4 14             	add    $0x14,%esp
  801d04:	5b                   	pop    %ebx
  801d05:	5d                   	pop    %ebp
  801d06:	c3                   	ret    

00801d07 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801d07:	55                   	push   %ebp
  801d08:	89 e5                	mov    %esp,%ebp
  801d0a:	57                   	push   %edi
  801d0b:	56                   	push   %esi
  801d0c:	53                   	push   %ebx
  801d0d:	83 ec 4c             	sub    $0x4c,%esp
  801d10:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801d13:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801d16:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d1a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d1d:	89 04 24             	mov    %eax,(%esp)
  801d20:	e8 59 fe ff ff       	call   801b7e <fd_lookup>
  801d25:	89 c3                	mov    %eax,%ebx
  801d27:	85 c0                	test   %eax,%eax
  801d29:	0f 88 e1 00 00 00    	js     801e10 <dup+0x109>
		return r;
	close(newfdnum);
  801d2f:	89 3c 24             	mov    %edi,(%esp)
  801d32:	e8 7f ff ff ff       	call   801cb6 <close>

	newfd = INDEX2FD(newfdnum);
  801d37:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801d3d:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801d40:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d43:	89 04 24             	mov    %eax,(%esp)
  801d46:	e8 c5 fd ff ff       	call   801b10 <fd2data>
  801d4b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801d4d:	89 34 24             	mov    %esi,(%esp)
  801d50:	e8 bb fd ff ff       	call   801b10 <fd2data>
  801d55:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801d58:	89 d8                	mov    %ebx,%eax
  801d5a:	c1 e8 16             	shr    $0x16,%eax
  801d5d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801d64:	a8 01                	test   $0x1,%al
  801d66:	74 46                	je     801dae <dup+0xa7>
  801d68:	89 d8                	mov    %ebx,%eax
  801d6a:	c1 e8 0c             	shr    $0xc,%eax
  801d6d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801d74:	f6 c2 01             	test   $0x1,%dl
  801d77:	74 35                	je     801dae <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801d79:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801d80:	25 07 0e 00 00       	and    $0xe07,%eax
  801d85:	89 44 24 10          	mov    %eax,0x10(%esp)
  801d89:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801d8c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d90:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d97:	00 
  801d98:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d9c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801da3:	e8 59 ef ff ff       	call   800d01 <sys_page_map>
  801da8:	89 c3                	mov    %eax,%ebx
  801daa:	85 c0                	test   %eax,%eax
  801dac:	78 3b                	js     801de9 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801dae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801db1:	89 c2                	mov    %eax,%edx
  801db3:	c1 ea 0c             	shr    $0xc,%edx
  801db6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801dbd:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801dc3:	89 54 24 10          	mov    %edx,0x10(%esp)
  801dc7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801dcb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801dd2:	00 
  801dd3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dd7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dde:	e8 1e ef ff ff       	call   800d01 <sys_page_map>
  801de3:	89 c3                	mov    %eax,%ebx
  801de5:	85 c0                	test   %eax,%eax
  801de7:	79 25                	jns    801e0e <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801de9:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ded:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801df4:	e8 5b ef ff ff       	call   800d54 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801df9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801dfc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e00:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e07:	e8 48 ef ff ff       	call   800d54 <sys_page_unmap>
	return r;
  801e0c:	eb 02                	jmp    801e10 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801e0e:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801e10:	89 d8                	mov    %ebx,%eax
  801e12:	83 c4 4c             	add    $0x4c,%esp
  801e15:	5b                   	pop    %ebx
  801e16:	5e                   	pop    %esi
  801e17:	5f                   	pop    %edi
  801e18:	5d                   	pop    %ebp
  801e19:	c3                   	ret    

00801e1a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801e1a:	55                   	push   %ebp
  801e1b:	89 e5                	mov    %esp,%ebp
  801e1d:	53                   	push   %ebx
  801e1e:	83 ec 24             	sub    $0x24,%esp
  801e21:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801e24:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e27:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e2b:	89 1c 24             	mov    %ebx,(%esp)
  801e2e:	e8 4b fd ff ff       	call   801b7e <fd_lookup>
  801e33:	85 c0                	test   %eax,%eax
  801e35:	78 6d                	js     801ea4 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801e37:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e3a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e41:	8b 00                	mov    (%eax),%eax
  801e43:	89 04 24             	mov    %eax,(%esp)
  801e46:	e8 89 fd ff ff       	call   801bd4 <dev_lookup>
  801e4b:	85 c0                	test   %eax,%eax
  801e4d:	78 55                	js     801ea4 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801e4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e52:	8b 50 08             	mov    0x8(%eax),%edx
  801e55:	83 e2 03             	and    $0x3,%edx
  801e58:	83 fa 01             	cmp    $0x1,%edx
  801e5b:	75 23                	jne    801e80 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801e5d:	a1 08 50 80 00       	mov    0x805008,%eax
  801e62:	8b 40 48             	mov    0x48(%eax),%eax
  801e65:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e69:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e6d:	c7 04 24 d1 37 80 00 	movl   $0x8037d1,(%esp)
  801e74:	e8 97 e4 ff ff       	call   800310 <cprintf>
		return -E_INVAL;
  801e79:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801e7e:	eb 24                	jmp    801ea4 <read+0x8a>
	}
	if (!dev->dev_read)
  801e80:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e83:	8b 52 08             	mov    0x8(%edx),%edx
  801e86:	85 d2                	test   %edx,%edx
  801e88:	74 15                	je     801e9f <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801e8a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801e8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e94:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801e98:	89 04 24             	mov    %eax,(%esp)
  801e9b:	ff d2                	call   *%edx
  801e9d:	eb 05                	jmp    801ea4 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801e9f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801ea4:	83 c4 24             	add    $0x24,%esp
  801ea7:	5b                   	pop    %ebx
  801ea8:	5d                   	pop    %ebp
  801ea9:	c3                   	ret    

00801eaa <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801eaa:	55                   	push   %ebp
  801eab:	89 e5                	mov    %esp,%ebp
  801ead:	57                   	push   %edi
  801eae:	56                   	push   %esi
  801eaf:	53                   	push   %ebx
  801eb0:	83 ec 1c             	sub    $0x1c,%esp
  801eb3:	8b 7d 08             	mov    0x8(%ebp),%edi
  801eb6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801eb9:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ebe:	eb 23                	jmp    801ee3 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801ec0:	89 f0                	mov    %esi,%eax
  801ec2:	29 d8                	sub    %ebx,%eax
  801ec4:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ec8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ecb:	01 d8                	add    %ebx,%eax
  801ecd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ed1:	89 3c 24             	mov    %edi,(%esp)
  801ed4:	e8 41 ff ff ff       	call   801e1a <read>
		if (m < 0)
  801ed9:	85 c0                	test   %eax,%eax
  801edb:	78 10                	js     801eed <readn+0x43>
			return m;
		if (m == 0)
  801edd:	85 c0                	test   %eax,%eax
  801edf:	74 0a                	je     801eeb <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801ee1:	01 c3                	add    %eax,%ebx
  801ee3:	39 f3                	cmp    %esi,%ebx
  801ee5:	72 d9                	jb     801ec0 <readn+0x16>
  801ee7:	89 d8                	mov    %ebx,%eax
  801ee9:	eb 02                	jmp    801eed <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801eeb:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801eed:	83 c4 1c             	add    $0x1c,%esp
  801ef0:	5b                   	pop    %ebx
  801ef1:	5e                   	pop    %esi
  801ef2:	5f                   	pop    %edi
  801ef3:	5d                   	pop    %ebp
  801ef4:	c3                   	ret    

00801ef5 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801ef5:	55                   	push   %ebp
  801ef6:	89 e5                	mov    %esp,%ebp
  801ef8:	53                   	push   %ebx
  801ef9:	83 ec 24             	sub    $0x24,%esp
  801efc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801eff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f02:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f06:	89 1c 24             	mov    %ebx,(%esp)
  801f09:	e8 70 fc ff ff       	call   801b7e <fd_lookup>
  801f0e:	85 c0                	test   %eax,%eax
  801f10:	78 68                	js     801f7a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f12:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f15:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f19:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f1c:	8b 00                	mov    (%eax),%eax
  801f1e:	89 04 24             	mov    %eax,(%esp)
  801f21:	e8 ae fc ff ff       	call   801bd4 <dev_lookup>
  801f26:	85 c0                	test   %eax,%eax
  801f28:	78 50                	js     801f7a <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801f2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f2d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801f31:	75 23                	jne    801f56 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801f33:	a1 08 50 80 00       	mov    0x805008,%eax
  801f38:	8b 40 48             	mov    0x48(%eax),%eax
  801f3b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f3f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f43:	c7 04 24 ed 37 80 00 	movl   $0x8037ed,(%esp)
  801f4a:	e8 c1 e3 ff ff       	call   800310 <cprintf>
		return -E_INVAL;
  801f4f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801f54:	eb 24                	jmp    801f7a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801f56:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f59:	8b 52 0c             	mov    0xc(%edx),%edx
  801f5c:	85 d2                	test   %edx,%edx
  801f5e:	74 15                	je     801f75 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801f60:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801f63:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f6a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801f6e:	89 04 24             	mov    %eax,(%esp)
  801f71:	ff d2                	call   *%edx
  801f73:	eb 05                	jmp    801f7a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801f75:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801f7a:	83 c4 24             	add    $0x24,%esp
  801f7d:	5b                   	pop    %ebx
  801f7e:	5d                   	pop    %ebp
  801f7f:	c3                   	ret    

00801f80 <seek>:

int
seek(int fdnum, off_t offset)
{
  801f80:	55                   	push   %ebp
  801f81:	89 e5                	mov    %esp,%ebp
  801f83:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f86:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801f89:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f8d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f90:	89 04 24             	mov    %eax,(%esp)
  801f93:	e8 e6 fb ff ff       	call   801b7e <fd_lookup>
  801f98:	85 c0                	test   %eax,%eax
  801f9a:	78 0e                	js     801faa <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801f9c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801f9f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fa2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801fa5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801faa:	c9                   	leave  
  801fab:	c3                   	ret    

00801fac <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801fac:	55                   	push   %ebp
  801fad:	89 e5                	mov    %esp,%ebp
  801faf:	53                   	push   %ebx
  801fb0:	83 ec 24             	sub    $0x24,%esp
  801fb3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801fb6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801fb9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fbd:	89 1c 24             	mov    %ebx,(%esp)
  801fc0:	e8 b9 fb ff ff       	call   801b7e <fd_lookup>
  801fc5:	85 c0                	test   %eax,%eax
  801fc7:	78 61                	js     80202a <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801fc9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fcc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fd3:	8b 00                	mov    (%eax),%eax
  801fd5:	89 04 24             	mov    %eax,(%esp)
  801fd8:	e8 f7 fb ff ff       	call   801bd4 <dev_lookup>
  801fdd:	85 c0                	test   %eax,%eax
  801fdf:	78 49                	js     80202a <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801fe1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fe4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801fe8:	75 23                	jne    80200d <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801fea:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801fef:	8b 40 48             	mov    0x48(%eax),%eax
  801ff2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ff6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ffa:	c7 04 24 b0 37 80 00 	movl   $0x8037b0,(%esp)
  802001:	e8 0a e3 ff ff       	call   800310 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  802006:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80200b:	eb 1d                	jmp    80202a <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  80200d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802010:	8b 52 18             	mov    0x18(%edx),%edx
  802013:	85 d2                	test   %edx,%edx
  802015:	74 0e                	je     802025 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  802017:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80201a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80201e:	89 04 24             	mov    %eax,(%esp)
  802021:	ff d2                	call   *%edx
  802023:	eb 05                	jmp    80202a <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  802025:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80202a:	83 c4 24             	add    $0x24,%esp
  80202d:	5b                   	pop    %ebx
  80202e:	5d                   	pop    %ebp
  80202f:	c3                   	ret    

00802030 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802030:	55                   	push   %ebp
  802031:	89 e5                	mov    %esp,%ebp
  802033:	53                   	push   %ebx
  802034:	83 ec 24             	sub    $0x24,%esp
  802037:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80203a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80203d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802041:	8b 45 08             	mov    0x8(%ebp),%eax
  802044:	89 04 24             	mov    %eax,(%esp)
  802047:	e8 32 fb ff ff       	call   801b7e <fd_lookup>
  80204c:	85 c0                	test   %eax,%eax
  80204e:	78 52                	js     8020a2 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802050:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802053:	89 44 24 04          	mov    %eax,0x4(%esp)
  802057:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80205a:	8b 00                	mov    (%eax),%eax
  80205c:	89 04 24             	mov    %eax,(%esp)
  80205f:	e8 70 fb ff ff       	call   801bd4 <dev_lookup>
  802064:	85 c0                	test   %eax,%eax
  802066:	78 3a                	js     8020a2 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  802068:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80206b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80206f:	74 2c                	je     80209d <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802071:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802074:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80207b:	00 00 00 
	stat->st_isdir = 0;
  80207e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802085:	00 00 00 
	stat->st_dev = dev;
  802088:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80208e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802092:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802095:	89 14 24             	mov    %edx,(%esp)
  802098:	ff 50 14             	call   *0x14(%eax)
  80209b:	eb 05                	jmp    8020a2 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80209d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8020a2:	83 c4 24             	add    $0x24,%esp
  8020a5:	5b                   	pop    %ebx
  8020a6:	5d                   	pop    %ebp
  8020a7:	c3                   	ret    

008020a8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8020a8:	55                   	push   %ebp
  8020a9:	89 e5                	mov    %esp,%ebp
  8020ab:	56                   	push   %esi
  8020ac:	53                   	push   %ebx
  8020ad:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8020b0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8020b7:	00 
  8020b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8020bb:	89 04 24             	mov    %eax,(%esp)
  8020be:	e8 2d 02 00 00       	call   8022f0 <open>
  8020c3:	89 c3                	mov    %eax,%ebx
  8020c5:	85 c0                	test   %eax,%eax
  8020c7:	78 1b                	js     8020e4 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8020c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020d0:	89 1c 24             	mov    %ebx,(%esp)
  8020d3:	e8 58 ff ff ff       	call   802030 <fstat>
  8020d8:	89 c6                	mov    %eax,%esi
	close(fd);
  8020da:	89 1c 24             	mov    %ebx,(%esp)
  8020dd:	e8 d4 fb ff ff       	call   801cb6 <close>
	return r;
  8020e2:	89 f3                	mov    %esi,%ebx
}
  8020e4:	89 d8                	mov    %ebx,%eax
  8020e6:	83 c4 10             	add    $0x10,%esp
  8020e9:	5b                   	pop    %ebx
  8020ea:	5e                   	pop    %esi
  8020eb:	5d                   	pop    %ebp
  8020ec:	c3                   	ret    
  8020ed:	00 00                	add    %al,(%eax)
	...

008020f0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8020f0:	55                   	push   %ebp
  8020f1:	89 e5                	mov    %esp,%ebp
  8020f3:	56                   	push   %esi
  8020f4:	53                   	push   %ebx
  8020f5:	83 ec 10             	sub    $0x10,%esp
  8020f8:	89 c3                	mov    %eax,%ebx
  8020fa:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8020fc:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  802103:	75 11                	jne    802116 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802105:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80210c:	e8 6a 0d 00 00       	call   802e7b <ipc_find_env>
  802111:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802116:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80211d:	00 
  80211e:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  802125:	00 
  802126:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80212a:	a1 00 50 80 00       	mov    0x805000,%eax
  80212f:	89 04 24             	mov    %eax,(%esp)
  802132:	e8 d6 0c 00 00       	call   802e0d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  802137:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80213e:	00 
  80213f:	89 74 24 04          	mov    %esi,0x4(%esp)
  802143:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80214a:	e8 55 0c 00 00       	call   802da4 <ipc_recv>
}
  80214f:	83 c4 10             	add    $0x10,%esp
  802152:	5b                   	pop    %ebx
  802153:	5e                   	pop    %esi
  802154:	5d                   	pop    %ebp
  802155:	c3                   	ret    

00802156 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802156:	55                   	push   %ebp
  802157:	89 e5                	mov    %esp,%ebp
  802159:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80215c:	8b 45 08             	mov    0x8(%ebp),%eax
  80215f:	8b 40 0c             	mov    0xc(%eax),%eax
  802162:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  802167:	8b 45 0c             	mov    0xc(%ebp),%eax
  80216a:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80216f:	ba 00 00 00 00       	mov    $0x0,%edx
  802174:	b8 02 00 00 00       	mov    $0x2,%eax
  802179:	e8 72 ff ff ff       	call   8020f0 <fsipc>
}
  80217e:	c9                   	leave  
  80217f:	c3                   	ret    

00802180 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802180:	55                   	push   %ebp
  802181:	89 e5                	mov    %esp,%ebp
  802183:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802186:	8b 45 08             	mov    0x8(%ebp),%eax
  802189:	8b 40 0c             	mov    0xc(%eax),%eax
  80218c:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  802191:	ba 00 00 00 00       	mov    $0x0,%edx
  802196:	b8 06 00 00 00       	mov    $0x6,%eax
  80219b:	e8 50 ff ff ff       	call   8020f0 <fsipc>
}
  8021a0:	c9                   	leave  
  8021a1:	c3                   	ret    

008021a2 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8021a2:	55                   	push   %ebp
  8021a3:	89 e5                	mov    %esp,%ebp
  8021a5:	53                   	push   %ebx
  8021a6:	83 ec 14             	sub    $0x14,%esp
  8021a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8021ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8021af:	8b 40 0c             	mov    0xc(%eax),%eax
  8021b2:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8021b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8021bc:	b8 05 00 00 00       	mov    $0x5,%eax
  8021c1:	e8 2a ff ff ff       	call   8020f0 <fsipc>
  8021c6:	85 c0                	test   %eax,%eax
  8021c8:	78 2b                	js     8021f5 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8021ca:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  8021d1:	00 
  8021d2:	89 1c 24             	mov    %ebx,(%esp)
  8021d5:	e8 e1 e6 ff ff       	call   8008bb <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8021da:	a1 80 60 80 00       	mov    0x806080,%eax
  8021df:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8021e5:	a1 84 60 80 00       	mov    0x806084,%eax
  8021ea:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8021f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8021f5:	83 c4 14             	add    $0x14,%esp
  8021f8:	5b                   	pop    %ebx
  8021f9:	5d                   	pop    %ebp
  8021fa:	c3                   	ret    

008021fb <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8021fb:	55                   	push   %ebp
  8021fc:	89 e5                	mov    %esp,%ebp
  8021fe:	83 ec 18             	sub    $0x18,%esp
  802201:	8b 55 10             	mov    0x10(%ebp),%edx
  802204:	89 d0                	mov    %edx,%eax
  802206:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  80220c:	76 05                	jbe    802213 <devfile_write+0x18>
  80220e:	b8 00 10 00 00       	mov    $0x1000,%eax
	//panic("devfile_write not implemented");
	int r;
	//uint32_t maxsize = BLKSIZE - sizeof(int) - sizeof(size_t);	
	if (n > BLKSIZE)
		n = BLKSIZE;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  802213:	8b 55 08             	mov    0x8(%ebp),%edx
  802216:	8b 52 0c             	mov    0xc(%edx),%edx
  802219:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  80221f:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  802224:	89 44 24 08          	mov    %eax,0x8(%esp)
  802228:	8b 45 0c             	mov    0xc(%ebp),%eax
  80222b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80222f:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  802236:	e8 f9 e7 ff ff       	call   800a34 <memmove>
	 
	return fsipc(FSREQ_WRITE, NULL);
  80223b:	ba 00 00 00 00       	mov    $0x0,%edx
  802240:	b8 04 00 00 00       	mov    $0x4,%eax
  802245:	e8 a6 fe ff ff       	call   8020f0 <fsipc>
}
  80224a:	c9                   	leave  
  80224b:	c3                   	ret    

0080224c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80224c:	55                   	push   %ebp
  80224d:	89 e5                	mov    %esp,%ebp
  80224f:	56                   	push   %esi
  802250:	53                   	push   %ebx
  802251:	83 ec 10             	sub    $0x10,%esp
  802254:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  802257:	8b 45 08             	mov    0x8(%ebp),%eax
  80225a:	8b 40 0c             	mov    0xc(%eax),%eax
  80225d:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  802262:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802268:	ba 00 00 00 00       	mov    $0x0,%edx
  80226d:	b8 03 00 00 00       	mov    $0x3,%eax
  802272:	e8 79 fe ff ff       	call   8020f0 <fsipc>
  802277:	89 c3                	mov    %eax,%ebx
  802279:	85 c0                	test   %eax,%eax
  80227b:	78 6a                	js     8022e7 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  80227d:	39 c6                	cmp    %eax,%esi
  80227f:	73 24                	jae    8022a5 <devfile_read+0x59>
  802281:	c7 44 24 0c 20 38 80 	movl   $0x803820,0xc(%esp)
  802288:	00 
  802289:	c7 44 24 08 7e 36 80 	movl   $0x80367e,0x8(%esp)
  802290:	00 
  802291:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  802298:	00 
  802299:	c7 04 24 27 38 80 00 	movl   $0x803827,(%esp)
  8022a0:	e8 73 df ff ff       	call   800218 <_panic>
	assert(r <= PGSIZE);
  8022a5:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8022aa:	7e 24                	jle    8022d0 <devfile_read+0x84>
  8022ac:	c7 44 24 0c 32 38 80 	movl   $0x803832,0xc(%esp)
  8022b3:	00 
  8022b4:	c7 44 24 08 7e 36 80 	movl   $0x80367e,0x8(%esp)
  8022bb:	00 
  8022bc:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8022c3:	00 
  8022c4:	c7 04 24 27 38 80 00 	movl   $0x803827,(%esp)
  8022cb:	e8 48 df ff ff       	call   800218 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8022d0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8022d4:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  8022db:	00 
  8022dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022df:	89 04 24             	mov    %eax,(%esp)
  8022e2:	e8 4d e7 ff ff       	call   800a34 <memmove>
	return r;
}
  8022e7:	89 d8                	mov    %ebx,%eax
  8022e9:	83 c4 10             	add    $0x10,%esp
  8022ec:	5b                   	pop    %ebx
  8022ed:	5e                   	pop    %esi
  8022ee:	5d                   	pop    %ebp
  8022ef:	c3                   	ret    

008022f0 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8022f0:	55                   	push   %ebp
  8022f1:	89 e5                	mov    %esp,%ebp
  8022f3:	56                   	push   %esi
  8022f4:	53                   	push   %ebx
  8022f5:	83 ec 20             	sub    $0x20,%esp
  8022f8:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8022fb:	89 34 24             	mov    %esi,(%esp)
  8022fe:	e8 85 e5 ff ff       	call   800888 <strlen>
  802303:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802308:	7f 60                	jg     80236a <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80230a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80230d:	89 04 24             	mov    %eax,(%esp)
  802310:	e8 16 f8 ff ff       	call   801b2b <fd_alloc>
  802315:	89 c3                	mov    %eax,%ebx
  802317:	85 c0                	test   %eax,%eax
  802319:	78 54                	js     80236f <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80231b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80231f:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  802326:	e8 90 e5 ff ff       	call   8008bb <strcpy>
	fsipcbuf.open.req_omode = mode;
  80232b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80232e:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  802333:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802336:	b8 01 00 00 00       	mov    $0x1,%eax
  80233b:	e8 b0 fd ff ff       	call   8020f0 <fsipc>
  802340:	89 c3                	mov    %eax,%ebx
  802342:	85 c0                	test   %eax,%eax
  802344:	79 15                	jns    80235b <open+0x6b>
		fd_close(fd, 0);
  802346:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80234d:	00 
  80234e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802351:	89 04 24             	mov    %eax,(%esp)
  802354:	e8 d5 f8 ff ff       	call   801c2e <fd_close>
		return r;
  802359:	eb 14                	jmp    80236f <open+0x7f>
	}

	return fd2num(fd);
  80235b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80235e:	89 04 24             	mov    %eax,(%esp)
  802361:	e8 9a f7 ff ff       	call   801b00 <fd2num>
  802366:	89 c3                	mov    %eax,%ebx
  802368:	eb 05                	jmp    80236f <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80236a:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80236f:	89 d8                	mov    %ebx,%eax
  802371:	83 c4 20             	add    $0x20,%esp
  802374:	5b                   	pop    %ebx
  802375:	5e                   	pop    %esi
  802376:	5d                   	pop    %ebp
  802377:	c3                   	ret    

00802378 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  802378:	55                   	push   %ebp
  802379:	89 e5                	mov    %esp,%ebp
  80237b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80237e:	ba 00 00 00 00       	mov    $0x0,%edx
  802383:	b8 08 00 00 00       	mov    $0x8,%eax
  802388:	e8 63 fd ff ff       	call   8020f0 <fsipc>
}
  80238d:	c9                   	leave  
  80238e:	c3                   	ret    
	...

00802390 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802390:	55                   	push   %ebp
  802391:	89 e5                	mov    %esp,%ebp
  802393:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  802396:	c7 44 24 04 3e 38 80 	movl   $0x80383e,0x4(%esp)
  80239d:	00 
  80239e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023a1:	89 04 24             	mov    %eax,(%esp)
  8023a4:	e8 12 e5 ff ff       	call   8008bb <strcpy>
	return 0;
}
  8023a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8023ae:	c9                   	leave  
  8023af:	c3                   	ret    

008023b0 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8023b0:	55                   	push   %ebp
  8023b1:	89 e5                	mov    %esp,%ebp
  8023b3:	53                   	push   %ebx
  8023b4:	83 ec 14             	sub    $0x14,%esp
  8023b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8023ba:	89 1c 24             	mov    %ebx,(%esp)
  8023bd:	e8 f2 0a 00 00       	call   802eb4 <pageref>
  8023c2:	83 f8 01             	cmp    $0x1,%eax
  8023c5:	75 0d                	jne    8023d4 <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  8023c7:	8b 43 0c             	mov    0xc(%ebx),%eax
  8023ca:	89 04 24             	mov    %eax,(%esp)
  8023cd:	e8 1f 03 00 00       	call   8026f1 <nsipc_close>
  8023d2:	eb 05                	jmp    8023d9 <devsock_close+0x29>
	else
		return 0;
  8023d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8023d9:	83 c4 14             	add    $0x14,%esp
  8023dc:	5b                   	pop    %ebx
  8023dd:	5d                   	pop    %ebp
  8023de:	c3                   	ret    

008023df <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8023df:	55                   	push   %ebp
  8023e0:	89 e5                	mov    %esp,%ebp
  8023e2:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8023e5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8023ec:	00 
  8023ed:	8b 45 10             	mov    0x10(%ebp),%eax
  8023f0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8023f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8023fe:	8b 40 0c             	mov    0xc(%eax),%eax
  802401:	89 04 24             	mov    %eax,(%esp)
  802404:	e8 e3 03 00 00       	call   8027ec <nsipc_send>
}
  802409:	c9                   	leave  
  80240a:	c3                   	ret    

0080240b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80240b:	55                   	push   %ebp
  80240c:	89 e5                	mov    %esp,%ebp
  80240e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802411:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802418:	00 
  802419:	8b 45 10             	mov    0x10(%ebp),%eax
  80241c:	89 44 24 08          	mov    %eax,0x8(%esp)
  802420:	8b 45 0c             	mov    0xc(%ebp),%eax
  802423:	89 44 24 04          	mov    %eax,0x4(%esp)
  802427:	8b 45 08             	mov    0x8(%ebp),%eax
  80242a:	8b 40 0c             	mov    0xc(%eax),%eax
  80242d:	89 04 24             	mov    %eax,(%esp)
  802430:	e8 37 03 00 00       	call   80276c <nsipc_recv>
}
  802435:	c9                   	leave  
  802436:	c3                   	ret    

00802437 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  802437:	55                   	push   %ebp
  802438:	89 e5                	mov    %esp,%ebp
  80243a:	56                   	push   %esi
  80243b:	53                   	push   %ebx
  80243c:	83 ec 20             	sub    $0x20,%esp
  80243f:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  802441:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802444:	89 04 24             	mov    %eax,(%esp)
  802447:	e8 df f6 ff ff       	call   801b2b <fd_alloc>
  80244c:	89 c3                	mov    %eax,%ebx
  80244e:	85 c0                	test   %eax,%eax
  802450:	78 21                	js     802473 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  802452:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802459:	00 
  80245a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80245d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802461:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802468:	e8 40 e8 ff ff       	call   800cad <sys_page_alloc>
  80246d:	89 c3                	mov    %eax,%ebx
  80246f:	85 c0                	test   %eax,%eax
  802471:	79 0a                	jns    80247d <alloc_sockfd+0x46>
		nsipc_close(sockid);
  802473:	89 34 24             	mov    %esi,(%esp)
  802476:	e8 76 02 00 00       	call   8026f1 <nsipc_close>
		return r;
  80247b:	eb 22                	jmp    80249f <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80247d:	8b 15 28 40 80 00    	mov    0x804028,%edx
  802483:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802486:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  802488:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80248b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  802492:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  802495:	89 04 24             	mov    %eax,(%esp)
  802498:	e8 63 f6 ff ff       	call   801b00 <fd2num>
  80249d:	89 c3                	mov    %eax,%ebx
}
  80249f:	89 d8                	mov    %ebx,%eax
  8024a1:	83 c4 20             	add    $0x20,%esp
  8024a4:	5b                   	pop    %ebx
  8024a5:	5e                   	pop    %esi
  8024a6:	5d                   	pop    %ebp
  8024a7:	c3                   	ret    

008024a8 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8024a8:	55                   	push   %ebp
  8024a9:	89 e5                	mov    %esp,%ebp
  8024ab:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8024ae:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8024b1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8024b5:	89 04 24             	mov    %eax,(%esp)
  8024b8:	e8 c1 f6 ff ff       	call   801b7e <fd_lookup>
  8024bd:	85 c0                	test   %eax,%eax
  8024bf:	78 17                	js     8024d8 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8024c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024c4:	8b 15 28 40 80 00    	mov    0x804028,%edx
  8024ca:	39 10                	cmp    %edx,(%eax)
  8024cc:	75 05                	jne    8024d3 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8024ce:	8b 40 0c             	mov    0xc(%eax),%eax
  8024d1:	eb 05                	jmp    8024d8 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8024d3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8024d8:	c9                   	leave  
  8024d9:	c3                   	ret    

008024da <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8024da:	55                   	push   %ebp
  8024db:	89 e5                	mov    %esp,%ebp
  8024dd:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8024e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8024e3:	e8 c0 ff ff ff       	call   8024a8 <fd2sockid>
  8024e8:	85 c0                	test   %eax,%eax
  8024ea:	78 1f                	js     80250b <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8024ec:	8b 55 10             	mov    0x10(%ebp),%edx
  8024ef:	89 54 24 08          	mov    %edx,0x8(%esp)
  8024f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8024f6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8024fa:	89 04 24             	mov    %eax,(%esp)
  8024fd:	e8 38 01 00 00       	call   80263a <nsipc_accept>
  802502:	85 c0                	test   %eax,%eax
  802504:	78 05                	js     80250b <accept+0x31>
		return r;
	return alloc_sockfd(r);
  802506:	e8 2c ff ff ff       	call   802437 <alloc_sockfd>
}
  80250b:	c9                   	leave  
  80250c:	c3                   	ret    

0080250d <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80250d:	55                   	push   %ebp
  80250e:	89 e5                	mov    %esp,%ebp
  802510:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802513:	8b 45 08             	mov    0x8(%ebp),%eax
  802516:	e8 8d ff ff ff       	call   8024a8 <fd2sockid>
  80251b:	85 c0                	test   %eax,%eax
  80251d:	78 16                	js     802535 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  80251f:	8b 55 10             	mov    0x10(%ebp),%edx
  802522:	89 54 24 08          	mov    %edx,0x8(%esp)
  802526:	8b 55 0c             	mov    0xc(%ebp),%edx
  802529:	89 54 24 04          	mov    %edx,0x4(%esp)
  80252d:	89 04 24             	mov    %eax,(%esp)
  802530:	e8 5b 01 00 00       	call   802690 <nsipc_bind>
}
  802535:	c9                   	leave  
  802536:	c3                   	ret    

00802537 <shutdown>:

int
shutdown(int s, int how)
{
  802537:	55                   	push   %ebp
  802538:	89 e5                	mov    %esp,%ebp
  80253a:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80253d:	8b 45 08             	mov    0x8(%ebp),%eax
  802540:	e8 63 ff ff ff       	call   8024a8 <fd2sockid>
  802545:	85 c0                	test   %eax,%eax
  802547:	78 0f                	js     802558 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  802549:	8b 55 0c             	mov    0xc(%ebp),%edx
  80254c:	89 54 24 04          	mov    %edx,0x4(%esp)
  802550:	89 04 24             	mov    %eax,(%esp)
  802553:	e8 77 01 00 00       	call   8026cf <nsipc_shutdown>
}
  802558:	c9                   	leave  
  802559:	c3                   	ret    

0080255a <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80255a:	55                   	push   %ebp
  80255b:	89 e5                	mov    %esp,%ebp
  80255d:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802560:	8b 45 08             	mov    0x8(%ebp),%eax
  802563:	e8 40 ff ff ff       	call   8024a8 <fd2sockid>
  802568:	85 c0                	test   %eax,%eax
  80256a:	78 16                	js     802582 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  80256c:	8b 55 10             	mov    0x10(%ebp),%edx
  80256f:	89 54 24 08          	mov    %edx,0x8(%esp)
  802573:	8b 55 0c             	mov    0xc(%ebp),%edx
  802576:	89 54 24 04          	mov    %edx,0x4(%esp)
  80257a:	89 04 24             	mov    %eax,(%esp)
  80257d:	e8 89 01 00 00       	call   80270b <nsipc_connect>
}
  802582:	c9                   	leave  
  802583:	c3                   	ret    

00802584 <listen>:

int
listen(int s, int backlog)
{
  802584:	55                   	push   %ebp
  802585:	89 e5                	mov    %esp,%ebp
  802587:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80258a:	8b 45 08             	mov    0x8(%ebp),%eax
  80258d:	e8 16 ff ff ff       	call   8024a8 <fd2sockid>
  802592:	85 c0                	test   %eax,%eax
  802594:	78 0f                	js     8025a5 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  802596:	8b 55 0c             	mov    0xc(%ebp),%edx
  802599:	89 54 24 04          	mov    %edx,0x4(%esp)
  80259d:	89 04 24             	mov    %eax,(%esp)
  8025a0:	e8 a5 01 00 00       	call   80274a <nsipc_listen>
}
  8025a5:	c9                   	leave  
  8025a6:	c3                   	ret    

008025a7 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8025a7:	55                   	push   %ebp
  8025a8:	89 e5                	mov    %esp,%ebp
  8025aa:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8025ad:	8b 45 10             	mov    0x10(%ebp),%eax
  8025b0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8025b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8025be:	89 04 24             	mov    %eax,(%esp)
  8025c1:	e8 99 02 00 00       	call   80285f <nsipc_socket>
  8025c6:	85 c0                	test   %eax,%eax
  8025c8:	78 05                	js     8025cf <socket+0x28>
		return r;
	return alloc_sockfd(r);
  8025ca:	e8 68 fe ff ff       	call   802437 <alloc_sockfd>
}
  8025cf:	c9                   	leave  
  8025d0:	c3                   	ret    
  8025d1:	00 00                	add    %al,(%eax)
	...

008025d4 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8025d4:	55                   	push   %ebp
  8025d5:	89 e5                	mov    %esp,%ebp
  8025d7:	53                   	push   %ebx
  8025d8:	83 ec 14             	sub    $0x14,%esp
  8025db:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8025dd:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  8025e4:	75 11                	jne    8025f7 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8025e6:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8025ed:	e8 89 08 00 00       	call   802e7b <ipc_find_env>
  8025f2:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8025f7:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8025fe:	00 
  8025ff:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  802606:	00 
  802607:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80260b:	a1 04 50 80 00       	mov    0x805004,%eax
  802610:	89 04 24             	mov    %eax,(%esp)
  802613:	e8 f5 07 00 00       	call   802e0d <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802618:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80261f:	00 
  802620:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802627:	00 
  802628:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80262f:	e8 70 07 00 00       	call   802da4 <ipc_recv>
}
  802634:	83 c4 14             	add    $0x14,%esp
  802637:	5b                   	pop    %ebx
  802638:	5d                   	pop    %ebp
  802639:	c3                   	ret    

0080263a <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80263a:	55                   	push   %ebp
  80263b:	89 e5                	mov    %esp,%ebp
  80263d:	56                   	push   %esi
  80263e:	53                   	push   %ebx
  80263f:	83 ec 10             	sub    $0x10,%esp
  802642:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  802645:	8b 45 08             	mov    0x8(%ebp),%eax
  802648:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80264d:	8b 06                	mov    (%esi),%eax
  80264f:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802654:	b8 01 00 00 00       	mov    $0x1,%eax
  802659:	e8 76 ff ff ff       	call   8025d4 <nsipc>
  80265e:	89 c3                	mov    %eax,%ebx
  802660:	85 c0                	test   %eax,%eax
  802662:	78 23                	js     802687 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802664:	a1 10 70 80 00       	mov    0x807010,%eax
  802669:	89 44 24 08          	mov    %eax,0x8(%esp)
  80266d:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802674:	00 
  802675:	8b 45 0c             	mov    0xc(%ebp),%eax
  802678:	89 04 24             	mov    %eax,(%esp)
  80267b:	e8 b4 e3 ff ff       	call   800a34 <memmove>
		*addrlen = ret->ret_addrlen;
  802680:	a1 10 70 80 00       	mov    0x807010,%eax
  802685:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  802687:	89 d8                	mov    %ebx,%eax
  802689:	83 c4 10             	add    $0x10,%esp
  80268c:	5b                   	pop    %ebx
  80268d:	5e                   	pop    %esi
  80268e:	5d                   	pop    %ebp
  80268f:	c3                   	ret    

00802690 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802690:	55                   	push   %ebp
  802691:	89 e5                	mov    %esp,%ebp
  802693:	53                   	push   %ebx
  802694:	83 ec 14             	sub    $0x14,%esp
  802697:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80269a:	8b 45 08             	mov    0x8(%ebp),%eax
  80269d:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8026a2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8026a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026ad:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  8026b4:	e8 7b e3 ff ff       	call   800a34 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8026b9:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  8026bf:	b8 02 00 00 00       	mov    $0x2,%eax
  8026c4:	e8 0b ff ff ff       	call   8025d4 <nsipc>
}
  8026c9:	83 c4 14             	add    $0x14,%esp
  8026cc:	5b                   	pop    %ebx
  8026cd:	5d                   	pop    %ebp
  8026ce:	c3                   	ret    

008026cf <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8026cf:	55                   	push   %ebp
  8026d0:	89 e5                	mov    %esp,%ebp
  8026d2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8026d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8026d8:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  8026dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026e0:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  8026e5:	b8 03 00 00 00       	mov    $0x3,%eax
  8026ea:	e8 e5 fe ff ff       	call   8025d4 <nsipc>
}
  8026ef:	c9                   	leave  
  8026f0:	c3                   	ret    

008026f1 <nsipc_close>:

int
nsipc_close(int s)
{
  8026f1:	55                   	push   %ebp
  8026f2:	89 e5                	mov    %esp,%ebp
  8026f4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8026f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8026fa:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  8026ff:	b8 04 00 00 00       	mov    $0x4,%eax
  802704:	e8 cb fe ff ff       	call   8025d4 <nsipc>
}
  802709:	c9                   	leave  
  80270a:	c3                   	ret    

0080270b <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80270b:	55                   	push   %ebp
  80270c:	89 e5                	mov    %esp,%ebp
  80270e:	53                   	push   %ebx
  80270f:	83 ec 14             	sub    $0x14,%esp
  802712:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802715:	8b 45 08             	mov    0x8(%ebp),%eax
  802718:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  80271d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802721:	8b 45 0c             	mov    0xc(%ebp),%eax
  802724:	89 44 24 04          	mov    %eax,0x4(%esp)
  802728:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  80272f:	e8 00 e3 ff ff       	call   800a34 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802734:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  80273a:	b8 05 00 00 00       	mov    $0x5,%eax
  80273f:	e8 90 fe ff ff       	call   8025d4 <nsipc>
}
  802744:	83 c4 14             	add    $0x14,%esp
  802747:	5b                   	pop    %ebx
  802748:	5d                   	pop    %ebp
  802749:	c3                   	ret    

0080274a <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  80274a:	55                   	push   %ebp
  80274b:	89 e5                	mov    %esp,%ebp
  80274d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802750:	8b 45 08             	mov    0x8(%ebp),%eax
  802753:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  802758:	8b 45 0c             	mov    0xc(%ebp),%eax
  80275b:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  802760:	b8 06 00 00 00       	mov    $0x6,%eax
  802765:	e8 6a fe ff ff       	call   8025d4 <nsipc>
}
  80276a:	c9                   	leave  
  80276b:	c3                   	ret    

0080276c <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80276c:	55                   	push   %ebp
  80276d:	89 e5                	mov    %esp,%ebp
  80276f:	56                   	push   %esi
  802770:	53                   	push   %ebx
  802771:	83 ec 10             	sub    $0x10,%esp
  802774:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802777:	8b 45 08             	mov    0x8(%ebp),%eax
  80277a:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  80277f:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  802785:	8b 45 14             	mov    0x14(%ebp),%eax
  802788:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80278d:	b8 07 00 00 00       	mov    $0x7,%eax
  802792:	e8 3d fe ff ff       	call   8025d4 <nsipc>
  802797:	89 c3                	mov    %eax,%ebx
  802799:	85 c0                	test   %eax,%eax
  80279b:	78 46                	js     8027e3 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  80279d:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8027a2:	7f 04                	jg     8027a8 <nsipc_recv+0x3c>
  8027a4:	39 c6                	cmp    %eax,%esi
  8027a6:	7d 24                	jge    8027cc <nsipc_recv+0x60>
  8027a8:	c7 44 24 0c 4a 38 80 	movl   $0x80384a,0xc(%esp)
  8027af:	00 
  8027b0:	c7 44 24 08 7e 36 80 	movl   $0x80367e,0x8(%esp)
  8027b7:	00 
  8027b8:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  8027bf:	00 
  8027c0:	c7 04 24 5f 38 80 00 	movl   $0x80385f,(%esp)
  8027c7:	e8 4c da ff ff       	call   800218 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8027cc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8027d0:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8027d7:	00 
  8027d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8027db:	89 04 24             	mov    %eax,(%esp)
  8027de:	e8 51 e2 ff ff       	call   800a34 <memmove>
	}

	return r;
}
  8027e3:	89 d8                	mov    %ebx,%eax
  8027e5:	83 c4 10             	add    $0x10,%esp
  8027e8:	5b                   	pop    %ebx
  8027e9:	5e                   	pop    %esi
  8027ea:	5d                   	pop    %ebp
  8027eb:	c3                   	ret    

008027ec <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8027ec:	55                   	push   %ebp
  8027ed:	89 e5                	mov    %esp,%ebp
  8027ef:	53                   	push   %ebx
  8027f0:	83 ec 14             	sub    $0x14,%esp
  8027f3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8027f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8027f9:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  8027fe:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802804:	7e 24                	jle    80282a <nsipc_send+0x3e>
  802806:	c7 44 24 0c 6b 38 80 	movl   $0x80386b,0xc(%esp)
  80280d:	00 
  80280e:	c7 44 24 08 7e 36 80 	movl   $0x80367e,0x8(%esp)
  802815:	00 
  802816:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  80281d:	00 
  80281e:	c7 04 24 5f 38 80 00 	movl   $0x80385f,(%esp)
  802825:	e8 ee d9 ff ff       	call   800218 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80282a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80282e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802831:	89 44 24 04          	mov    %eax,0x4(%esp)
  802835:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  80283c:	e8 f3 e1 ff ff       	call   800a34 <memmove>
	nsipcbuf.send.req_size = size;
  802841:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  802847:	8b 45 14             	mov    0x14(%ebp),%eax
  80284a:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  80284f:	b8 08 00 00 00       	mov    $0x8,%eax
  802854:	e8 7b fd ff ff       	call   8025d4 <nsipc>
}
  802859:	83 c4 14             	add    $0x14,%esp
  80285c:	5b                   	pop    %ebx
  80285d:	5d                   	pop    %ebp
  80285e:	c3                   	ret    

0080285f <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80285f:	55                   	push   %ebp
  802860:	89 e5                	mov    %esp,%ebp
  802862:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802865:	8b 45 08             	mov    0x8(%ebp),%eax
  802868:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  80286d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802870:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  802875:	8b 45 10             	mov    0x10(%ebp),%eax
  802878:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  80287d:	b8 09 00 00 00       	mov    $0x9,%eax
  802882:	e8 4d fd ff ff       	call   8025d4 <nsipc>
}
  802887:	c9                   	leave  
  802888:	c3                   	ret    
  802889:	00 00                	add    %al,(%eax)
	...

0080288c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80288c:	55                   	push   %ebp
  80288d:	89 e5                	mov    %esp,%ebp
  80288f:	56                   	push   %esi
  802890:	53                   	push   %ebx
  802891:	83 ec 10             	sub    $0x10,%esp
  802894:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802897:	8b 45 08             	mov    0x8(%ebp),%eax
  80289a:	89 04 24             	mov    %eax,(%esp)
  80289d:	e8 6e f2 ff ff       	call   801b10 <fd2data>
  8028a2:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8028a4:	c7 44 24 04 77 38 80 	movl   $0x803877,0x4(%esp)
  8028ab:	00 
  8028ac:	89 34 24             	mov    %esi,(%esp)
  8028af:	e8 07 e0 ff ff       	call   8008bb <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8028b4:	8b 43 04             	mov    0x4(%ebx),%eax
  8028b7:	2b 03                	sub    (%ebx),%eax
  8028b9:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8028bf:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8028c6:	00 00 00 
	stat->st_dev = &devpipe;
  8028c9:	c7 86 88 00 00 00 44 	movl   $0x804044,0x88(%esi)
  8028d0:	40 80 00 
	return 0;
}
  8028d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8028d8:	83 c4 10             	add    $0x10,%esp
  8028db:	5b                   	pop    %ebx
  8028dc:	5e                   	pop    %esi
  8028dd:	5d                   	pop    %ebp
  8028de:	c3                   	ret    

008028df <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8028df:	55                   	push   %ebp
  8028e0:	89 e5                	mov    %esp,%ebp
  8028e2:	53                   	push   %ebx
  8028e3:	83 ec 14             	sub    $0x14,%esp
  8028e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8028e9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8028ed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8028f4:	e8 5b e4 ff ff       	call   800d54 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8028f9:	89 1c 24             	mov    %ebx,(%esp)
  8028fc:	e8 0f f2 ff ff       	call   801b10 <fd2data>
  802901:	89 44 24 04          	mov    %eax,0x4(%esp)
  802905:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80290c:	e8 43 e4 ff ff       	call   800d54 <sys_page_unmap>
}
  802911:	83 c4 14             	add    $0x14,%esp
  802914:	5b                   	pop    %ebx
  802915:	5d                   	pop    %ebp
  802916:	c3                   	ret    

00802917 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802917:	55                   	push   %ebp
  802918:	89 e5                	mov    %esp,%ebp
  80291a:	57                   	push   %edi
  80291b:	56                   	push   %esi
  80291c:	53                   	push   %ebx
  80291d:	83 ec 2c             	sub    $0x2c,%esp
  802920:	89 c7                	mov    %eax,%edi
  802922:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802925:	a1 08 50 80 00       	mov    0x805008,%eax
  80292a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80292d:	89 3c 24             	mov    %edi,(%esp)
  802930:	e8 7f 05 00 00       	call   802eb4 <pageref>
  802935:	89 c6                	mov    %eax,%esi
  802937:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80293a:	89 04 24             	mov    %eax,(%esp)
  80293d:	e8 72 05 00 00       	call   802eb4 <pageref>
  802942:	39 c6                	cmp    %eax,%esi
  802944:	0f 94 c0             	sete   %al
  802947:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  80294a:	8b 15 08 50 80 00    	mov    0x805008,%edx
  802950:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802953:	39 cb                	cmp    %ecx,%ebx
  802955:	75 08                	jne    80295f <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  802957:	83 c4 2c             	add    $0x2c,%esp
  80295a:	5b                   	pop    %ebx
  80295b:	5e                   	pop    %esi
  80295c:	5f                   	pop    %edi
  80295d:	5d                   	pop    %ebp
  80295e:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  80295f:	83 f8 01             	cmp    $0x1,%eax
  802962:	75 c1                	jne    802925 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802964:	8b 42 58             	mov    0x58(%edx),%eax
  802967:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  80296e:	00 
  80296f:	89 44 24 08          	mov    %eax,0x8(%esp)
  802973:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802977:	c7 04 24 7e 38 80 00 	movl   $0x80387e,(%esp)
  80297e:	e8 8d d9 ff ff       	call   800310 <cprintf>
  802983:	eb a0                	jmp    802925 <_pipeisclosed+0xe>

00802985 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802985:	55                   	push   %ebp
  802986:	89 e5                	mov    %esp,%ebp
  802988:	57                   	push   %edi
  802989:	56                   	push   %esi
  80298a:	53                   	push   %ebx
  80298b:	83 ec 1c             	sub    $0x1c,%esp
  80298e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802991:	89 34 24             	mov    %esi,(%esp)
  802994:	e8 77 f1 ff ff       	call   801b10 <fd2data>
  802999:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80299b:	bf 00 00 00 00       	mov    $0x0,%edi
  8029a0:	eb 3c                	jmp    8029de <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8029a2:	89 da                	mov    %ebx,%edx
  8029a4:	89 f0                	mov    %esi,%eax
  8029a6:	e8 6c ff ff ff       	call   802917 <_pipeisclosed>
  8029ab:	85 c0                	test   %eax,%eax
  8029ad:	75 38                	jne    8029e7 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8029af:	e8 da e2 ff ff       	call   800c8e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8029b4:	8b 43 04             	mov    0x4(%ebx),%eax
  8029b7:	8b 13                	mov    (%ebx),%edx
  8029b9:	83 c2 20             	add    $0x20,%edx
  8029bc:	39 d0                	cmp    %edx,%eax
  8029be:	73 e2                	jae    8029a2 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8029c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8029c3:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  8029c6:	89 c2                	mov    %eax,%edx
  8029c8:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8029ce:	79 05                	jns    8029d5 <devpipe_write+0x50>
  8029d0:	4a                   	dec    %edx
  8029d1:	83 ca e0             	or     $0xffffffe0,%edx
  8029d4:	42                   	inc    %edx
  8029d5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8029d9:	40                   	inc    %eax
  8029da:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8029dd:	47                   	inc    %edi
  8029de:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8029e1:	75 d1                	jne    8029b4 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8029e3:	89 f8                	mov    %edi,%eax
  8029e5:	eb 05                	jmp    8029ec <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8029e7:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8029ec:	83 c4 1c             	add    $0x1c,%esp
  8029ef:	5b                   	pop    %ebx
  8029f0:	5e                   	pop    %esi
  8029f1:	5f                   	pop    %edi
  8029f2:	5d                   	pop    %ebp
  8029f3:	c3                   	ret    

008029f4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8029f4:	55                   	push   %ebp
  8029f5:	89 e5                	mov    %esp,%ebp
  8029f7:	57                   	push   %edi
  8029f8:	56                   	push   %esi
  8029f9:	53                   	push   %ebx
  8029fa:	83 ec 1c             	sub    $0x1c,%esp
  8029fd:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802a00:	89 3c 24             	mov    %edi,(%esp)
  802a03:	e8 08 f1 ff ff       	call   801b10 <fd2data>
  802a08:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802a0a:	be 00 00 00 00       	mov    $0x0,%esi
  802a0f:	eb 3a                	jmp    802a4b <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802a11:	85 f6                	test   %esi,%esi
  802a13:	74 04                	je     802a19 <devpipe_read+0x25>
				return i;
  802a15:	89 f0                	mov    %esi,%eax
  802a17:	eb 40                	jmp    802a59 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802a19:	89 da                	mov    %ebx,%edx
  802a1b:	89 f8                	mov    %edi,%eax
  802a1d:	e8 f5 fe ff ff       	call   802917 <_pipeisclosed>
  802a22:	85 c0                	test   %eax,%eax
  802a24:	75 2e                	jne    802a54 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802a26:	e8 63 e2 ff ff       	call   800c8e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802a2b:	8b 03                	mov    (%ebx),%eax
  802a2d:	3b 43 04             	cmp    0x4(%ebx),%eax
  802a30:	74 df                	je     802a11 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802a32:	25 1f 00 00 80       	and    $0x8000001f,%eax
  802a37:	79 05                	jns    802a3e <devpipe_read+0x4a>
  802a39:	48                   	dec    %eax
  802a3a:	83 c8 e0             	or     $0xffffffe0,%eax
  802a3d:	40                   	inc    %eax
  802a3e:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  802a42:	8b 55 0c             	mov    0xc(%ebp),%edx
  802a45:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  802a48:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802a4a:	46                   	inc    %esi
  802a4b:	3b 75 10             	cmp    0x10(%ebp),%esi
  802a4e:	75 db                	jne    802a2b <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802a50:	89 f0                	mov    %esi,%eax
  802a52:	eb 05                	jmp    802a59 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802a54:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802a59:	83 c4 1c             	add    $0x1c,%esp
  802a5c:	5b                   	pop    %ebx
  802a5d:	5e                   	pop    %esi
  802a5e:	5f                   	pop    %edi
  802a5f:	5d                   	pop    %ebp
  802a60:	c3                   	ret    

00802a61 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802a61:	55                   	push   %ebp
  802a62:	89 e5                	mov    %esp,%ebp
  802a64:	57                   	push   %edi
  802a65:	56                   	push   %esi
  802a66:	53                   	push   %ebx
  802a67:	83 ec 3c             	sub    $0x3c,%esp
  802a6a:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802a6d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802a70:	89 04 24             	mov    %eax,(%esp)
  802a73:	e8 b3 f0 ff ff       	call   801b2b <fd_alloc>
  802a78:	89 c3                	mov    %eax,%ebx
  802a7a:	85 c0                	test   %eax,%eax
  802a7c:	0f 88 45 01 00 00    	js     802bc7 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802a82:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802a89:	00 
  802a8a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802a8d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802a91:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802a98:	e8 10 e2 ff ff       	call   800cad <sys_page_alloc>
  802a9d:	89 c3                	mov    %eax,%ebx
  802a9f:	85 c0                	test   %eax,%eax
  802aa1:	0f 88 20 01 00 00    	js     802bc7 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802aa7:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802aaa:	89 04 24             	mov    %eax,(%esp)
  802aad:	e8 79 f0 ff ff       	call   801b2b <fd_alloc>
  802ab2:	89 c3                	mov    %eax,%ebx
  802ab4:	85 c0                	test   %eax,%eax
  802ab6:	0f 88 f8 00 00 00    	js     802bb4 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802abc:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802ac3:	00 
  802ac4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802ac7:	89 44 24 04          	mov    %eax,0x4(%esp)
  802acb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802ad2:	e8 d6 e1 ff ff       	call   800cad <sys_page_alloc>
  802ad7:	89 c3                	mov    %eax,%ebx
  802ad9:	85 c0                	test   %eax,%eax
  802adb:	0f 88 d3 00 00 00    	js     802bb4 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802ae1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802ae4:	89 04 24             	mov    %eax,(%esp)
  802ae7:	e8 24 f0 ff ff       	call   801b10 <fd2data>
  802aec:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802aee:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802af5:	00 
  802af6:	89 44 24 04          	mov    %eax,0x4(%esp)
  802afa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802b01:	e8 a7 e1 ff ff       	call   800cad <sys_page_alloc>
  802b06:	89 c3                	mov    %eax,%ebx
  802b08:	85 c0                	test   %eax,%eax
  802b0a:	0f 88 91 00 00 00    	js     802ba1 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802b10:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802b13:	89 04 24             	mov    %eax,(%esp)
  802b16:	e8 f5 ef ff ff       	call   801b10 <fd2data>
  802b1b:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802b22:	00 
  802b23:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802b27:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802b2e:	00 
  802b2f:	89 74 24 04          	mov    %esi,0x4(%esp)
  802b33:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802b3a:	e8 c2 e1 ff ff       	call   800d01 <sys_page_map>
  802b3f:	89 c3                	mov    %eax,%ebx
  802b41:	85 c0                	test   %eax,%eax
  802b43:	78 4c                	js     802b91 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802b45:	8b 15 44 40 80 00    	mov    0x804044,%edx
  802b4b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802b4e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802b50:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802b53:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802b5a:	8b 15 44 40 80 00    	mov    0x804044,%edx
  802b60:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802b63:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802b65:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802b68:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802b6f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802b72:	89 04 24             	mov    %eax,(%esp)
  802b75:	e8 86 ef ff ff       	call   801b00 <fd2num>
  802b7a:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802b7c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802b7f:	89 04 24             	mov    %eax,(%esp)
  802b82:	e8 79 ef ff ff       	call   801b00 <fd2num>
  802b87:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  802b8a:	bb 00 00 00 00       	mov    $0x0,%ebx
  802b8f:	eb 36                	jmp    802bc7 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  802b91:	89 74 24 04          	mov    %esi,0x4(%esp)
  802b95:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802b9c:	e8 b3 e1 ff ff       	call   800d54 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802ba1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802ba4:	89 44 24 04          	mov    %eax,0x4(%esp)
  802ba8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802baf:	e8 a0 e1 ff ff       	call   800d54 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802bb4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802bb7:	89 44 24 04          	mov    %eax,0x4(%esp)
  802bbb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802bc2:	e8 8d e1 ff ff       	call   800d54 <sys_page_unmap>
    err:
	return r;
}
  802bc7:	89 d8                	mov    %ebx,%eax
  802bc9:	83 c4 3c             	add    $0x3c,%esp
  802bcc:	5b                   	pop    %ebx
  802bcd:	5e                   	pop    %esi
  802bce:	5f                   	pop    %edi
  802bcf:	5d                   	pop    %ebp
  802bd0:	c3                   	ret    

00802bd1 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802bd1:	55                   	push   %ebp
  802bd2:	89 e5                	mov    %esp,%ebp
  802bd4:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802bd7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802bda:	89 44 24 04          	mov    %eax,0x4(%esp)
  802bde:	8b 45 08             	mov    0x8(%ebp),%eax
  802be1:	89 04 24             	mov    %eax,(%esp)
  802be4:	e8 95 ef ff ff       	call   801b7e <fd_lookup>
  802be9:	85 c0                	test   %eax,%eax
  802beb:	78 15                	js     802c02 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802bed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802bf0:	89 04 24             	mov    %eax,(%esp)
  802bf3:	e8 18 ef ff ff       	call   801b10 <fd2data>
	return _pipeisclosed(fd, p);
  802bf8:	89 c2                	mov    %eax,%edx
  802bfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802bfd:	e8 15 fd ff ff       	call   802917 <_pipeisclosed>
}
  802c02:	c9                   	leave  
  802c03:	c3                   	ret    

00802c04 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802c04:	55                   	push   %ebp
  802c05:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802c07:	b8 00 00 00 00       	mov    $0x0,%eax
  802c0c:	5d                   	pop    %ebp
  802c0d:	c3                   	ret    

00802c0e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802c0e:	55                   	push   %ebp
  802c0f:	89 e5                	mov    %esp,%ebp
  802c11:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802c14:	c7 44 24 04 96 38 80 	movl   $0x803896,0x4(%esp)
  802c1b:	00 
  802c1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  802c1f:	89 04 24             	mov    %eax,(%esp)
  802c22:	e8 94 dc ff ff       	call   8008bb <strcpy>
	return 0;
}
  802c27:	b8 00 00 00 00       	mov    $0x0,%eax
  802c2c:	c9                   	leave  
  802c2d:	c3                   	ret    

00802c2e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802c2e:	55                   	push   %ebp
  802c2f:	89 e5                	mov    %esp,%ebp
  802c31:	57                   	push   %edi
  802c32:	56                   	push   %esi
  802c33:	53                   	push   %ebx
  802c34:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802c3a:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802c3f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802c45:	eb 30                	jmp    802c77 <devcons_write+0x49>
		m = n - tot;
  802c47:	8b 75 10             	mov    0x10(%ebp),%esi
  802c4a:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802c4c:	83 fe 7f             	cmp    $0x7f,%esi
  802c4f:	76 05                	jbe    802c56 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  802c51:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802c56:	89 74 24 08          	mov    %esi,0x8(%esp)
  802c5a:	03 45 0c             	add    0xc(%ebp),%eax
  802c5d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802c61:	89 3c 24             	mov    %edi,(%esp)
  802c64:	e8 cb dd ff ff       	call   800a34 <memmove>
		sys_cputs(buf, m);
  802c69:	89 74 24 04          	mov    %esi,0x4(%esp)
  802c6d:	89 3c 24             	mov    %edi,(%esp)
  802c70:	e8 6b df ff ff       	call   800be0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802c75:	01 f3                	add    %esi,%ebx
  802c77:	89 d8                	mov    %ebx,%eax
  802c79:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802c7c:	72 c9                	jb     802c47 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802c7e:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802c84:	5b                   	pop    %ebx
  802c85:	5e                   	pop    %esi
  802c86:	5f                   	pop    %edi
  802c87:	5d                   	pop    %ebp
  802c88:	c3                   	ret    

00802c89 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802c89:	55                   	push   %ebp
  802c8a:	89 e5                	mov    %esp,%ebp
  802c8c:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  802c8f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802c93:	75 07                	jne    802c9c <devcons_read+0x13>
  802c95:	eb 25                	jmp    802cbc <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802c97:	e8 f2 df ff ff       	call   800c8e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802c9c:	e8 5d df ff ff       	call   800bfe <sys_cgetc>
  802ca1:	85 c0                	test   %eax,%eax
  802ca3:	74 f2                	je     802c97 <devcons_read+0xe>
  802ca5:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  802ca7:	85 c0                	test   %eax,%eax
  802ca9:	78 1d                	js     802cc8 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802cab:	83 f8 04             	cmp    $0x4,%eax
  802cae:	74 13                	je     802cc3 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802cb0:	8b 45 0c             	mov    0xc(%ebp),%eax
  802cb3:	88 10                	mov    %dl,(%eax)
	return 1;
  802cb5:	b8 01 00 00 00       	mov    $0x1,%eax
  802cba:	eb 0c                	jmp    802cc8 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802cbc:	b8 00 00 00 00       	mov    $0x0,%eax
  802cc1:	eb 05                	jmp    802cc8 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802cc3:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802cc8:	c9                   	leave  
  802cc9:	c3                   	ret    

00802cca <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802cca:	55                   	push   %ebp
  802ccb:	89 e5                	mov    %esp,%ebp
  802ccd:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802cd0:	8b 45 08             	mov    0x8(%ebp),%eax
  802cd3:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802cd6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802cdd:	00 
  802cde:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802ce1:	89 04 24             	mov    %eax,(%esp)
  802ce4:	e8 f7 de ff ff       	call   800be0 <sys_cputs>
}
  802ce9:	c9                   	leave  
  802cea:	c3                   	ret    

00802ceb <getchar>:

int
getchar(void)
{
  802ceb:	55                   	push   %ebp
  802cec:	89 e5                	mov    %esp,%ebp
  802cee:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802cf1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802cf8:	00 
  802cf9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802cfc:	89 44 24 04          	mov    %eax,0x4(%esp)
  802d00:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802d07:	e8 0e f1 ff ff       	call   801e1a <read>
	if (r < 0)
  802d0c:	85 c0                	test   %eax,%eax
  802d0e:	78 0f                	js     802d1f <getchar+0x34>
		return r;
	if (r < 1)
  802d10:	85 c0                	test   %eax,%eax
  802d12:	7e 06                	jle    802d1a <getchar+0x2f>
		return -E_EOF;
	return c;
  802d14:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802d18:	eb 05                	jmp    802d1f <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802d1a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802d1f:	c9                   	leave  
  802d20:	c3                   	ret    

00802d21 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802d21:	55                   	push   %ebp
  802d22:	89 e5                	mov    %esp,%ebp
  802d24:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802d27:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d2a:	89 44 24 04          	mov    %eax,0x4(%esp)
  802d2e:	8b 45 08             	mov    0x8(%ebp),%eax
  802d31:	89 04 24             	mov    %eax,(%esp)
  802d34:	e8 45 ee ff ff       	call   801b7e <fd_lookup>
  802d39:	85 c0                	test   %eax,%eax
  802d3b:	78 11                	js     802d4e <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802d3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d40:	8b 15 60 40 80 00    	mov    0x804060,%edx
  802d46:	39 10                	cmp    %edx,(%eax)
  802d48:	0f 94 c0             	sete   %al
  802d4b:	0f b6 c0             	movzbl %al,%eax
}
  802d4e:	c9                   	leave  
  802d4f:	c3                   	ret    

00802d50 <opencons>:

int
opencons(void)
{
  802d50:	55                   	push   %ebp
  802d51:	89 e5                	mov    %esp,%ebp
  802d53:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802d56:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d59:	89 04 24             	mov    %eax,(%esp)
  802d5c:	e8 ca ed ff ff       	call   801b2b <fd_alloc>
  802d61:	85 c0                	test   %eax,%eax
  802d63:	78 3c                	js     802da1 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802d65:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802d6c:	00 
  802d6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d70:	89 44 24 04          	mov    %eax,0x4(%esp)
  802d74:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802d7b:	e8 2d df ff ff       	call   800cad <sys_page_alloc>
  802d80:	85 c0                	test   %eax,%eax
  802d82:	78 1d                	js     802da1 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802d84:	8b 15 60 40 80 00    	mov    0x804060,%edx
  802d8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d8d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802d8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d92:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802d99:	89 04 24             	mov    %eax,(%esp)
  802d9c:	e8 5f ed ff ff       	call   801b00 <fd2num>
}
  802da1:	c9                   	leave  
  802da2:	c3                   	ret    
	...

00802da4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802da4:	55                   	push   %ebp
  802da5:	89 e5                	mov    %esp,%ebp
  802da7:	56                   	push   %esi
  802da8:	53                   	push   %ebx
  802da9:	83 ec 10             	sub    $0x10,%esp
  802dac:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802daf:	8b 45 0c             	mov    0xc(%ebp),%eax
  802db2:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int r;
		
	r = sys_ipc_recv(pg?pg:(void*)UTOP);
  802db5:	85 c0                	test   %eax,%eax
  802db7:	75 05                	jne    802dbe <ipc_recv+0x1a>
  802db9:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802dbe:	89 04 24             	mov    %eax,(%esp)
  802dc1:	e8 fd e0 ff ff       	call   800ec3 <sys_ipc_recv>
	if (from_env_store != NULL)
  802dc6:	85 db                	test   %ebx,%ebx
  802dc8:	74 0b                	je     802dd5 <ipc_recv+0x31>
		*from_env_store = thisenv->env_ipc_from; 
  802dca:	8b 15 08 50 80 00    	mov    0x805008,%edx
  802dd0:	8b 52 74             	mov    0x74(%edx),%edx
  802dd3:	89 13                	mov    %edx,(%ebx)
	if (perm_store != NULL)
  802dd5:	85 f6                	test   %esi,%esi
  802dd7:	74 0b                	je     802de4 <ipc_recv+0x40>
		*perm_store = thisenv->env_ipc_perm;
  802dd9:	8b 15 08 50 80 00    	mov    0x805008,%edx
  802ddf:	8b 52 78             	mov    0x78(%edx),%edx
  802de2:	89 16                	mov    %edx,(%esi)
	
	if (r < 0){
  802de4:	85 c0                	test   %eax,%eax
  802de6:	79 16                	jns    802dfe <ipc_recv+0x5a>
		if(from_env_store != NULL)
  802de8:	85 db                	test   %ebx,%ebx
  802dea:	74 06                	je     802df2 <ipc_recv+0x4e>
			*from_env_store = 0;
  802dec:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store != NULL)	
  802df2:	85 f6                	test   %esi,%esi
  802df4:	74 10                	je     802e06 <ipc_recv+0x62>
			*perm_store = 0;
  802df6:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  802dfc:	eb 08                	jmp    802e06 <ipc_recv+0x62>
		return r;
	}
	
	return thisenv->env_ipc_value;
  802dfe:	a1 08 50 80 00       	mov    0x805008,%eax
  802e03:	8b 40 70             	mov    0x70(%eax),%eax
}
  802e06:	83 c4 10             	add    $0x10,%esp
  802e09:	5b                   	pop    %ebx
  802e0a:	5e                   	pop    %esi
  802e0b:	5d                   	pop    %ebp
  802e0c:	c3                   	ret    

00802e0d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802e0d:	55                   	push   %ebp
  802e0e:	89 e5                	mov    %esp,%ebp
  802e10:	57                   	push   %edi
  802e11:	56                   	push   %esi
  802e12:	53                   	push   %ebx
  802e13:	83 ec 1c             	sub    $0x1c,%esp
  802e16:	8b 75 08             	mov    0x8(%ebp),%esi
  802e19:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802e1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  802e1f:	eb 2a                	jmp    802e4b <ipc_send+0x3e>
		if (r != -E_IPC_NOT_RECV)
  802e21:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802e24:	74 20                	je     802e46 <ipc_send+0x39>
			panic("ipc_send: sys_ipc_try_send failed %e", r);
  802e26:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802e2a:	c7 44 24 08 a4 38 80 	movl   $0x8038a4,0x8(%esp)
  802e31:	00 
  802e32:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  802e39:	00 
  802e3a:	c7 04 24 cc 38 80 00 	movl   $0x8038cc,(%esp)
  802e41:	e8 d2 d3 ff ff       	call   800218 <_panic>
		sys_yield();
  802e46:	e8 43 de ff ff       	call   800c8e <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  802e4b:	85 db                	test   %ebx,%ebx
  802e4d:	75 07                	jne    802e56 <ipc_send+0x49>
  802e4f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802e54:	eb 02                	jmp    802e58 <ipc_send+0x4b>
  802e56:	89 d8                	mov    %ebx,%eax
  802e58:	8b 55 14             	mov    0x14(%ebp),%edx
  802e5b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802e5f:	89 44 24 08          	mov    %eax,0x8(%esp)
  802e63:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802e67:	89 34 24             	mov    %esi,(%esp)
  802e6a:	e8 31 e0 ff ff       	call   800ea0 <sys_ipc_try_send>
  802e6f:	85 c0                	test   %eax,%eax
  802e71:	78 ae                	js     802e21 <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: sys_ipc_try_send failed %e", r);
		sys_yield();
	}
}
  802e73:	83 c4 1c             	add    $0x1c,%esp
  802e76:	5b                   	pop    %ebx
  802e77:	5e                   	pop    %esi
  802e78:	5f                   	pop    %edi
  802e79:	5d                   	pop    %ebp
  802e7a:	c3                   	ret    

00802e7b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802e7b:	55                   	push   %ebp
  802e7c:	89 e5                	mov    %esp,%ebp
  802e7e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802e81:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802e86:	89 c2                	mov    %eax,%edx
  802e88:	c1 e2 07             	shl    $0x7,%edx
  802e8b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802e91:	8b 52 50             	mov    0x50(%edx),%edx
  802e94:	39 ca                	cmp    %ecx,%edx
  802e96:	75 0d                	jne    802ea5 <ipc_find_env+0x2a>
			return envs[i].env_id;
  802e98:	c1 e0 07             	shl    $0x7,%eax
  802e9b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802ea0:	8b 40 40             	mov    0x40(%eax),%eax
  802ea3:	eb 0c                	jmp    802eb1 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802ea5:	40                   	inc    %eax
  802ea6:	3d 00 04 00 00       	cmp    $0x400,%eax
  802eab:	75 d9                	jne    802e86 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802ead:	66 b8 00 00          	mov    $0x0,%ax
}
  802eb1:	5d                   	pop    %ebp
  802eb2:	c3                   	ret    
	...

00802eb4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802eb4:	55                   	push   %ebp
  802eb5:	89 e5                	mov    %esp,%ebp
  802eb7:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802eba:	89 c2                	mov    %eax,%edx
  802ebc:	c1 ea 16             	shr    $0x16,%edx
  802ebf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802ec6:	f6 c2 01             	test   $0x1,%dl
  802ec9:	74 1e                	je     802ee9 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802ecb:	c1 e8 0c             	shr    $0xc,%eax
  802ece:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802ed5:	a8 01                	test   $0x1,%al
  802ed7:	74 17                	je     802ef0 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802ed9:	c1 e8 0c             	shr    $0xc,%eax
  802edc:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802ee3:	ef 
  802ee4:	0f b7 c0             	movzwl %ax,%eax
  802ee7:	eb 0c                	jmp    802ef5 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802ee9:	b8 00 00 00 00       	mov    $0x0,%eax
  802eee:	eb 05                	jmp    802ef5 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802ef0:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802ef5:	5d                   	pop    %ebp
  802ef6:	c3                   	ret    
	...

00802ef8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802ef8:	55                   	push   %ebp
  802ef9:	57                   	push   %edi
  802efa:	56                   	push   %esi
  802efb:	83 ec 10             	sub    $0x10,%esp
  802efe:	8b 74 24 20          	mov    0x20(%esp),%esi
  802f02:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802f06:	89 74 24 04          	mov    %esi,0x4(%esp)
  802f0a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  802f0e:	89 cd                	mov    %ecx,%ebp
  802f10:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802f14:	85 c0                	test   %eax,%eax
  802f16:	75 2c                	jne    802f44 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802f18:	39 f9                	cmp    %edi,%ecx
  802f1a:	77 68                	ja     802f84 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802f1c:	85 c9                	test   %ecx,%ecx
  802f1e:	75 0b                	jne    802f2b <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802f20:	b8 01 00 00 00       	mov    $0x1,%eax
  802f25:	31 d2                	xor    %edx,%edx
  802f27:	f7 f1                	div    %ecx
  802f29:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802f2b:	31 d2                	xor    %edx,%edx
  802f2d:	89 f8                	mov    %edi,%eax
  802f2f:	f7 f1                	div    %ecx
  802f31:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802f33:	89 f0                	mov    %esi,%eax
  802f35:	f7 f1                	div    %ecx
  802f37:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802f39:	89 f0                	mov    %esi,%eax
  802f3b:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802f3d:	83 c4 10             	add    $0x10,%esp
  802f40:	5e                   	pop    %esi
  802f41:	5f                   	pop    %edi
  802f42:	5d                   	pop    %ebp
  802f43:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802f44:	39 f8                	cmp    %edi,%eax
  802f46:	77 2c                	ja     802f74 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802f48:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  802f4b:	83 f6 1f             	xor    $0x1f,%esi
  802f4e:	75 4c                	jne    802f9c <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802f50:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802f52:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802f57:	72 0a                	jb     802f63 <__udivdi3+0x6b>
  802f59:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802f5d:	0f 87 ad 00 00 00    	ja     803010 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802f63:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802f68:	89 f0                	mov    %esi,%eax
  802f6a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802f6c:	83 c4 10             	add    $0x10,%esp
  802f6f:	5e                   	pop    %esi
  802f70:	5f                   	pop    %edi
  802f71:	5d                   	pop    %ebp
  802f72:	c3                   	ret    
  802f73:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802f74:	31 ff                	xor    %edi,%edi
  802f76:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802f78:	89 f0                	mov    %esi,%eax
  802f7a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802f7c:	83 c4 10             	add    $0x10,%esp
  802f7f:	5e                   	pop    %esi
  802f80:	5f                   	pop    %edi
  802f81:	5d                   	pop    %ebp
  802f82:	c3                   	ret    
  802f83:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802f84:	89 fa                	mov    %edi,%edx
  802f86:	89 f0                	mov    %esi,%eax
  802f88:	f7 f1                	div    %ecx
  802f8a:	89 c6                	mov    %eax,%esi
  802f8c:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802f8e:	89 f0                	mov    %esi,%eax
  802f90:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802f92:	83 c4 10             	add    $0x10,%esp
  802f95:	5e                   	pop    %esi
  802f96:	5f                   	pop    %edi
  802f97:	5d                   	pop    %ebp
  802f98:	c3                   	ret    
  802f99:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802f9c:	89 f1                	mov    %esi,%ecx
  802f9e:	d3 e0                	shl    %cl,%eax
  802fa0:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802fa4:	b8 20 00 00 00       	mov    $0x20,%eax
  802fa9:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802fab:	89 ea                	mov    %ebp,%edx
  802fad:	88 c1                	mov    %al,%cl
  802faf:	d3 ea                	shr    %cl,%edx
  802fb1:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802fb5:	09 ca                	or     %ecx,%edx
  802fb7:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  802fbb:	89 f1                	mov    %esi,%ecx
  802fbd:	d3 e5                	shl    %cl,%ebp
  802fbf:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  802fc3:	89 fd                	mov    %edi,%ebp
  802fc5:	88 c1                	mov    %al,%cl
  802fc7:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802fc9:	89 fa                	mov    %edi,%edx
  802fcb:	89 f1                	mov    %esi,%ecx
  802fcd:	d3 e2                	shl    %cl,%edx
  802fcf:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802fd3:	88 c1                	mov    %al,%cl
  802fd5:	d3 ef                	shr    %cl,%edi
  802fd7:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802fd9:	89 f8                	mov    %edi,%eax
  802fdb:	89 ea                	mov    %ebp,%edx
  802fdd:	f7 74 24 08          	divl   0x8(%esp)
  802fe1:	89 d1                	mov    %edx,%ecx
  802fe3:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802fe5:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802fe9:	39 d1                	cmp    %edx,%ecx
  802feb:	72 17                	jb     803004 <__udivdi3+0x10c>
  802fed:	74 09                	je     802ff8 <__udivdi3+0x100>
  802fef:	89 fe                	mov    %edi,%esi
  802ff1:	31 ff                	xor    %edi,%edi
  802ff3:	e9 41 ff ff ff       	jmp    802f39 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802ff8:	8b 54 24 04          	mov    0x4(%esp),%edx
  802ffc:	89 f1                	mov    %esi,%ecx
  802ffe:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  803000:	39 c2                	cmp    %eax,%edx
  803002:	73 eb                	jae    802fef <__udivdi3+0xf7>
		{
		  q0--;
  803004:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  803007:	31 ff                	xor    %edi,%edi
  803009:	e9 2b ff ff ff       	jmp    802f39 <__udivdi3+0x41>
  80300e:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  803010:	31 f6                	xor    %esi,%esi
  803012:	e9 22 ff ff ff       	jmp    802f39 <__udivdi3+0x41>
	...

00803018 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  803018:	55                   	push   %ebp
  803019:	57                   	push   %edi
  80301a:	56                   	push   %esi
  80301b:	83 ec 20             	sub    $0x20,%esp
  80301e:	8b 44 24 30          	mov    0x30(%esp),%eax
  803022:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  803026:	89 44 24 14          	mov    %eax,0x14(%esp)
  80302a:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  80302e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  803032:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  803036:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  803038:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80303a:	85 ed                	test   %ebp,%ebp
  80303c:	75 16                	jne    803054 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  80303e:	39 f1                	cmp    %esi,%ecx
  803040:	0f 86 a6 00 00 00    	jbe    8030ec <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  803046:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  803048:	89 d0                	mov    %edx,%eax
  80304a:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80304c:	83 c4 20             	add    $0x20,%esp
  80304f:	5e                   	pop    %esi
  803050:	5f                   	pop    %edi
  803051:	5d                   	pop    %ebp
  803052:	c3                   	ret    
  803053:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  803054:	39 f5                	cmp    %esi,%ebp
  803056:	0f 87 ac 00 00 00    	ja     803108 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80305c:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  80305f:	83 f0 1f             	xor    $0x1f,%eax
  803062:	89 44 24 10          	mov    %eax,0x10(%esp)
  803066:	0f 84 a8 00 00 00    	je     803114 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80306c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  803070:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  803072:	bf 20 00 00 00       	mov    $0x20,%edi
  803077:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80307b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80307f:	89 f9                	mov    %edi,%ecx
  803081:	d3 e8                	shr    %cl,%eax
  803083:	09 e8                	or     %ebp,%eax
  803085:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  803089:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80308d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  803091:	d3 e0                	shl    %cl,%eax
  803093:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  803097:	89 f2                	mov    %esi,%edx
  803099:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80309b:	8b 44 24 14          	mov    0x14(%esp),%eax
  80309f:	d3 e0                	shl    %cl,%eax
  8030a1:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8030a5:	8b 44 24 14          	mov    0x14(%esp),%eax
  8030a9:	89 f9                	mov    %edi,%ecx
  8030ab:	d3 e8                	shr    %cl,%eax
  8030ad:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8030af:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8030b1:	89 f2                	mov    %esi,%edx
  8030b3:	f7 74 24 18          	divl   0x18(%esp)
  8030b7:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8030b9:	f7 64 24 0c          	mull   0xc(%esp)
  8030bd:	89 c5                	mov    %eax,%ebp
  8030bf:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8030c1:	39 d6                	cmp    %edx,%esi
  8030c3:	72 67                	jb     80312c <__umoddi3+0x114>
  8030c5:	74 75                	je     80313c <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8030c7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8030cb:	29 e8                	sub    %ebp,%eax
  8030cd:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8030cf:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8030d3:	d3 e8                	shr    %cl,%eax
  8030d5:	89 f2                	mov    %esi,%edx
  8030d7:	89 f9                	mov    %edi,%ecx
  8030d9:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8030db:	09 d0                	or     %edx,%eax
  8030dd:	89 f2                	mov    %esi,%edx
  8030df:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8030e3:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8030e5:	83 c4 20             	add    $0x20,%esp
  8030e8:	5e                   	pop    %esi
  8030e9:	5f                   	pop    %edi
  8030ea:	5d                   	pop    %ebp
  8030eb:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8030ec:	85 c9                	test   %ecx,%ecx
  8030ee:	75 0b                	jne    8030fb <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8030f0:	b8 01 00 00 00       	mov    $0x1,%eax
  8030f5:	31 d2                	xor    %edx,%edx
  8030f7:	f7 f1                	div    %ecx
  8030f9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8030fb:	89 f0                	mov    %esi,%eax
  8030fd:	31 d2                	xor    %edx,%edx
  8030ff:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  803101:	89 f8                	mov    %edi,%eax
  803103:	e9 3e ff ff ff       	jmp    803046 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  803108:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80310a:	83 c4 20             	add    $0x20,%esp
  80310d:	5e                   	pop    %esi
  80310e:	5f                   	pop    %edi
  80310f:	5d                   	pop    %ebp
  803110:	c3                   	ret    
  803111:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  803114:	39 f5                	cmp    %esi,%ebp
  803116:	72 04                	jb     80311c <__umoddi3+0x104>
  803118:	39 f9                	cmp    %edi,%ecx
  80311a:	77 06                	ja     803122 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80311c:	89 f2                	mov    %esi,%edx
  80311e:	29 cf                	sub    %ecx,%edi
  803120:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  803122:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  803124:	83 c4 20             	add    $0x20,%esp
  803127:	5e                   	pop    %esi
  803128:	5f                   	pop    %edi
  803129:	5d                   	pop    %ebp
  80312a:	c3                   	ret    
  80312b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80312c:	89 d1                	mov    %edx,%ecx
  80312e:	89 c5                	mov    %eax,%ebp
  803130:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  803134:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  803138:	eb 8d                	jmp    8030c7 <__umoddi3+0xaf>
  80313a:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80313c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  803140:	72 ea                	jb     80312c <__umoddi3+0x114>
  803142:	89 f1                	mov    %esi,%ecx
  803144:	eb 81                	jmp    8030c7 <__umoddi3+0xaf>
