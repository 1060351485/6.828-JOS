
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
  80004a:	e8 78 08 00 00       	call   8008c7 <strcpy>
	exit();
  80004f:	e8 bc 01 00 00       	call   800210 <exit>
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
  80007f:	e8 35 0c 00 00       	call   800cb9 <sys_page_alloc>
  800084:	85 c0                	test   %eax,%eax
  800086:	79 20                	jns    8000a8 <umain+0x52>
		panic("sys_page_alloc: %e", r);
  800088:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80008c:	c7 44 24 08 0c 2c 80 	movl   $0x802c0c,0x8(%esp)
  800093:	00 
  800094:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
  80009b:	00 
  80009c:	c7 04 24 1f 2c 80 00 	movl   $0x802c1f,(%esp)
  8000a3:	e8 7c 01 00 00       	call   800224 <_panic>

	// check fork
	if ((r = fork()) < 0)
  8000a8:	e8 86 0f 00 00       	call   801033 <fork>
  8000ad:	89 c3                	mov    %eax,%ebx
  8000af:	85 c0                	test   %eax,%eax
  8000b1:	79 20                	jns    8000d3 <umain+0x7d>
		panic("fork: %e", r);
  8000b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b7:	c7 44 24 08 33 2c 80 	movl   $0x802c33,0x8(%esp)
  8000be:	00 
  8000bf:	c7 44 24 04 17 00 00 	movl   $0x17,0x4(%esp)
  8000c6:	00 
  8000c7:	c7 04 24 1f 2c 80 00 	movl   $0x802c1f,(%esp)
  8000ce:	e8 51 01 00 00       	call   800224 <_panic>
	if (r == 0) {
  8000d3:	85 c0                	test   %eax,%eax
  8000d5:	75 1a                	jne    8000f1 <umain+0x9b>
		strcpy(VA, msg);
  8000d7:	a1 04 40 80 00       	mov    0x804004,%eax
  8000dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000e0:	c7 04 24 00 00 00 a0 	movl   $0xa0000000,(%esp)
  8000e7:	e8 db 07 00 00       	call   8008c7 <strcpy>
		exit();
  8000ec:	e8 1f 01 00 00       	call   800210 <exit>
	}
	wait(r);
  8000f1:	89 1c 24             	mov    %ebx,(%esp)
  8000f4:	e8 ab 18 00 00       	call   8019a4 <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000f9:	a1 04 40 80 00       	mov    0x804004,%eax
  8000fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800102:	c7 04 24 00 00 00 a0 	movl   $0xa0000000,(%esp)
  800109:	e8 60 08 00 00       	call   80096e <strcmp>
  80010e:	85 c0                	test   %eax,%eax
  800110:	75 07                	jne    800119 <umain+0xc3>
  800112:	b8 00 2c 80 00       	mov    $0x802c00,%eax
  800117:	eb 05                	jmp    80011e <umain+0xc8>
  800119:	b8 06 2c 80 00       	mov    $0x802c06,%eax
  80011e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800122:	c7 04 24 3c 2c 80 00 	movl   $0x802c3c,(%esp)
  800129:	e8 ee 01 00 00       	call   80031c <cprintf>

	// check spawn
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  80012e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800135:	00 
  800136:	c7 44 24 08 57 2c 80 	movl   $0x802c57,0x8(%esp)
  80013d:	00 
  80013e:	c7 44 24 04 5c 2c 80 	movl   $0x802c5c,0x4(%esp)
  800145:	00 
  800146:	c7 04 24 5b 2c 80 00 	movl   $0x802c5b,(%esp)
  80014d:	e8 e2 17 00 00       	call   801934 <spawnl>
  800152:	85 c0                	test   %eax,%eax
  800154:	79 20                	jns    800176 <umain+0x120>
		panic("spawn: %e", r);
  800156:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80015a:	c7 44 24 08 69 2c 80 	movl   $0x802c69,0x8(%esp)
  800161:	00 
  800162:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  800169:	00 
  80016a:	c7 04 24 1f 2c 80 00 	movl   $0x802c1f,(%esp)
  800171:	e8 ae 00 00 00       	call   800224 <_panic>
	wait(r);
  800176:	89 04 24             	mov    %eax,(%esp)
  800179:	e8 26 18 00 00       	call   8019a4 <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  80017e:	a1 00 40 80 00       	mov    0x804000,%eax
  800183:	89 44 24 04          	mov    %eax,0x4(%esp)
  800187:	c7 04 24 00 00 00 a0 	movl   $0xa0000000,(%esp)
  80018e:	e8 db 07 00 00       	call   80096e <strcmp>
  800193:	85 c0                	test   %eax,%eax
  800195:	75 07                	jne    80019e <umain+0x148>
  800197:	b8 00 2c 80 00       	mov    $0x802c00,%eax
  80019c:	eb 05                	jmp    8001a3 <umain+0x14d>
  80019e:	b8 06 2c 80 00       	mov    $0x802c06,%eax
  8001a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a7:	c7 04 24 73 2c 80 00 	movl   $0x802c73,(%esp)
  8001ae:	e8 69 01 00 00       	call   80031c <cprintf>
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
  8001ca:	e8 ac 0a 00 00       	call   800c7b <sys_getenvid>
  8001cf:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001d4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8001db:	c1 e0 07             	shl    $0x7,%eax
  8001de:	29 d0                	sub    %edx,%eax
  8001e0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001e5:	a3 04 50 80 00       	mov    %eax,0x805004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001ea:	85 f6                	test   %esi,%esi
  8001ec:	7e 07                	jle    8001f5 <libmain+0x39>
		binaryname = argv[0];
  8001ee:	8b 03                	mov    (%ebx),%eax
  8001f0:	a3 08 40 80 00       	mov    %eax,0x804008

	// call user main routine
	umain(argc, argv);
  8001f5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001f9:	89 34 24             	mov    %esi,(%esp)
  8001fc:	e8 55 fe ff ff       	call   800056 <umain>

	// exit gracefully
	exit();
  800201:	e8 0a 00 00 00       	call   800210 <exit>
}
  800206:	83 c4 10             	add    $0x10,%esp
  800209:	5b                   	pop    %ebx
  80020a:	5e                   	pop    %esi
  80020b:	5d                   	pop    %ebp
  80020c:	c3                   	ret    
  80020d:	00 00                	add    %al,(%eax)
	...

00800210 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800210:	55                   	push   %ebp
  800211:	89 e5                	mov    %esp,%ebp
  800213:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  800216:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80021d:	e8 07 0a 00 00       	call   800c29 <sys_env_destroy>
}
  800222:	c9                   	leave  
  800223:	c3                   	ret    

00800224 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800224:	55                   	push   %ebp
  800225:	89 e5                	mov    %esp,%ebp
  800227:	56                   	push   %esi
  800228:	53                   	push   %ebx
  800229:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80022c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80022f:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  800235:	e8 41 0a 00 00       	call   800c7b <sys_getenvid>
  80023a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80023d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800241:	8b 55 08             	mov    0x8(%ebp),%edx
  800244:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800248:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80024c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800250:	c7 04 24 b8 2c 80 00 	movl   $0x802cb8,(%esp)
  800257:	e8 c0 00 00 00       	call   80031c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80025c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800260:	8b 45 10             	mov    0x10(%ebp),%eax
  800263:	89 04 24             	mov    %eax,(%esp)
  800266:	e8 50 00 00 00       	call   8002bb <vcprintf>
	cprintf("\n");
  80026b:	c7 04 24 ea 32 80 00 	movl   $0x8032ea,(%esp)
  800272:	e8 a5 00 00 00       	call   80031c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800277:	cc                   	int3   
  800278:	eb fd                	jmp    800277 <_panic+0x53>
	...

0080027c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	53                   	push   %ebx
  800280:	83 ec 14             	sub    $0x14,%esp
  800283:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800286:	8b 03                	mov    (%ebx),%eax
  800288:	8b 55 08             	mov    0x8(%ebp),%edx
  80028b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80028f:	40                   	inc    %eax
  800290:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800292:	3d ff 00 00 00       	cmp    $0xff,%eax
  800297:	75 19                	jne    8002b2 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800299:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8002a0:	00 
  8002a1:	8d 43 08             	lea    0x8(%ebx),%eax
  8002a4:	89 04 24             	mov    %eax,(%esp)
  8002a7:	e8 40 09 00 00       	call   800bec <sys_cputs>
		b->idx = 0;
  8002ac:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8002b2:	ff 43 04             	incl   0x4(%ebx)
}
  8002b5:	83 c4 14             	add    $0x14,%esp
  8002b8:	5b                   	pop    %ebx
  8002b9:	5d                   	pop    %ebp
  8002ba:	c3                   	ret    

008002bb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002bb:	55                   	push   %ebp
  8002bc:	89 e5                	mov    %esp,%ebp
  8002be:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8002c4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002cb:	00 00 00 
	b.cnt = 0;
  8002ce:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002d5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002db:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002df:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002e6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f0:	c7 04 24 7c 02 80 00 	movl   $0x80027c,(%esp)
  8002f7:	e8 82 01 00 00       	call   80047e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002fc:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800302:	89 44 24 04          	mov    %eax,0x4(%esp)
  800306:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80030c:	89 04 24             	mov    %eax,(%esp)
  80030f:	e8 d8 08 00 00       	call   800bec <sys_cputs>

	return b.cnt;
}
  800314:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80031a:	c9                   	leave  
  80031b:	c3                   	ret    

0080031c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80031c:	55                   	push   %ebp
  80031d:	89 e5                	mov    %esp,%ebp
  80031f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800322:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800325:	89 44 24 04          	mov    %eax,0x4(%esp)
  800329:	8b 45 08             	mov    0x8(%ebp),%eax
  80032c:	89 04 24             	mov    %eax,(%esp)
  80032f:	e8 87 ff ff ff       	call   8002bb <vcprintf>
	va_end(ap);

	return cnt;
}
  800334:	c9                   	leave  
  800335:	c3                   	ret    
	...

00800338 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800338:	55                   	push   %ebp
  800339:	89 e5                	mov    %esp,%ebp
  80033b:	57                   	push   %edi
  80033c:	56                   	push   %esi
  80033d:	53                   	push   %ebx
  80033e:	83 ec 3c             	sub    $0x3c,%esp
  800341:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800344:	89 d7                	mov    %edx,%edi
  800346:	8b 45 08             	mov    0x8(%ebp),%eax
  800349:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80034c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80034f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800352:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800355:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800358:	85 c0                	test   %eax,%eax
  80035a:	75 08                	jne    800364 <printnum+0x2c>
  80035c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80035f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800362:	77 57                	ja     8003bb <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800364:	89 74 24 10          	mov    %esi,0x10(%esp)
  800368:	4b                   	dec    %ebx
  800369:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80036d:	8b 45 10             	mov    0x10(%ebp),%eax
  800370:	89 44 24 08          	mov    %eax,0x8(%esp)
  800374:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800378:	8b 74 24 0c          	mov    0xc(%esp),%esi
  80037c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800383:	00 
  800384:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800387:	89 04 24             	mov    %eax,(%esp)
  80038a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80038d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800391:	e8 1a 26 00 00       	call   8029b0 <__udivdi3>
  800396:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80039a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80039e:	89 04 24             	mov    %eax,(%esp)
  8003a1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003a5:	89 fa                	mov    %edi,%edx
  8003a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003aa:	e8 89 ff ff ff       	call   800338 <printnum>
  8003af:	eb 0f                	jmp    8003c0 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003b1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003b5:	89 34 24             	mov    %esi,(%esp)
  8003b8:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003bb:	4b                   	dec    %ebx
  8003bc:	85 db                	test   %ebx,%ebx
  8003be:	7f f1                	jg     8003b1 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003c0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003c4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8003c8:	8b 45 10             	mov    0x10(%ebp),%eax
  8003cb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003cf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003d6:	00 
  8003d7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003da:	89 04 24             	mov    %eax,(%esp)
  8003dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003e4:	e8 e7 26 00 00       	call   802ad0 <__umoddi3>
  8003e9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003ed:	0f be 80 db 2c 80 00 	movsbl 0x802cdb(%eax),%eax
  8003f4:	89 04 24             	mov    %eax,(%esp)
  8003f7:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8003fa:	83 c4 3c             	add    $0x3c,%esp
  8003fd:	5b                   	pop    %ebx
  8003fe:	5e                   	pop    %esi
  8003ff:	5f                   	pop    %edi
  800400:	5d                   	pop    %ebp
  800401:	c3                   	ret    

00800402 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800402:	55                   	push   %ebp
  800403:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800405:	83 fa 01             	cmp    $0x1,%edx
  800408:	7e 0e                	jle    800418 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80040a:	8b 10                	mov    (%eax),%edx
  80040c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80040f:	89 08                	mov    %ecx,(%eax)
  800411:	8b 02                	mov    (%edx),%eax
  800413:	8b 52 04             	mov    0x4(%edx),%edx
  800416:	eb 22                	jmp    80043a <getuint+0x38>
	else if (lflag)
  800418:	85 d2                	test   %edx,%edx
  80041a:	74 10                	je     80042c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80041c:	8b 10                	mov    (%eax),%edx
  80041e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800421:	89 08                	mov    %ecx,(%eax)
  800423:	8b 02                	mov    (%edx),%eax
  800425:	ba 00 00 00 00       	mov    $0x0,%edx
  80042a:	eb 0e                	jmp    80043a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80042c:	8b 10                	mov    (%eax),%edx
  80042e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800431:	89 08                	mov    %ecx,(%eax)
  800433:	8b 02                	mov    (%edx),%eax
  800435:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80043a:	5d                   	pop    %ebp
  80043b:	c3                   	ret    

0080043c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80043c:	55                   	push   %ebp
  80043d:	89 e5                	mov    %esp,%ebp
  80043f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800442:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800445:	8b 10                	mov    (%eax),%edx
  800447:	3b 50 04             	cmp    0x4(%eax),%edx
  80044a:	73 08                	jae    800454 <sprintputch+0x18>
		*b->buf++ = ch;
  80044c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80044f:	88 0a                	mov    %cl,(%edx)
  800451:	42                   	inc    %edx
  800452:	89 10                	mov    %edx,(%eax)
}
  800454:	5d                   	pop    %ebp
  800455:	c3                   	ret    

00800456 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800456:	55                   	push   %ebp
  800457:	89 e5                	mov    %esp,%ebp
  800459:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80045c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80045f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800463:	8b 45 10             	mov    0x10(%ebp),%eax
  800466:	89 44 24 08          	mov    %eax,0x8(%esp)
  80046a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80046d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800471:	8b 45 08             	mov    0x8(%ebp),%eax
  800474:	89 04 24             	mov    %eax,(%esp)
  800477:	e8 02 00 00 00       	call   80047e <vprintfmt>
	va_end(ap);
}
  80047c:	c9                   	leave  
  80047d:	c3                   	ret    

0080047e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80047e:	55                   	push   %ebp
  80047f:	89 e5                	mov    %esp,%ebp
  800481:	57                   	push   %edi
  800482:	56                   	push   %esi
  800483:	53                   	push   %ebx
  800484:	83 ec 4c             	sub    $0x4c,%esp
  800487:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80048a:	8b 75 10             	mov    0x10(%ebp),%esi
  80048d:	eb 12                	jmp    8004a1 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80048f:	85 c0                	test   %eax,%eax
  800491:	0f 84 6b 03 00 00    	je     800802 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800497:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80049b:	89 04 24             	mov    %eax,(%esp)
  80049e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004a1:	0f b6 06             	movzbl (%esi),%eax
  8004a4:	46                   	inc    %esi
  8004a5:	83 f8 25             	cmp    $0x25,%eax
  8004a8:	75 e5                	jne    80048f <vprintfmt+0x11>
  8004aa:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8004ae:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8004b5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8004ba:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8004c1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004c6:	eb 26                	jmp    8004ee <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c8:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004cb:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8004cf:	eb 1d                	jmp    8004ee <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d1:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004d4:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8004d8:	eb 14                	jmp    8004ee <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004da:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8004dd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004e4:	eb 08                	jmp    8004ee <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004e6:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8004e9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ee:	0f b6 06             	movzbl (%esi),%eax
  8004f1:	8d 56 01             	lea    0x1(%esi),%edx
  8004f4:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004f7:	8a 16                	mov    (%esi),%dl
  8004f9:	83 ea 23             	sub    $0x23,%edx
  8004fc:	80 fa 55             	cmp    $0x55,%dl
  8004ff:	0f 87 e1 02 00 00    	ja     8007e6 <vprintfmt+0x368>
  800505:	0f b6 d2             	movzbl %dl,%edx
  800508:	ff 24 95 20 2e 80 00 	jmp    *0x802e20(,%edx,4)
  80050f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800512:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800517:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80051a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80051e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800521:	8d 50 d0             	lea    -0x30(%eax),%edx
  800524:	83 fa 09             	cmp    $0x9,%edx
  800527:	77 2a                	ja     800553 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800529:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80052a:	eb eb                	jmp    800517 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80052c:	8b 45 14             	mov    0x14(%ebp),%eax
  80052f:	8d 50 04             	lea    0x4(%eax),%edx
  800532:	89 55 14             	mov    %edx,0x14(%ebp)
  800535:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800537:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80053a:	eb 17                	jmp    800553 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  80053c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800540:	78 98                	js     8004da <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800542:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800545:	eb a7                	jmp    8004ee <vprintfmt+0x70>
  800547:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80054a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800551:	eb 9b                	jmp    8004ee <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800553:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800557:	79 95                	jns    8004ee <vprintfmt+0x70>
  800559:	eb 8b                	jmp    8004e6 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80055b:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80055f:	eb 8d                	jmp    8004ee <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800561:	8b 45 14             	mov    0x14(%ebp),%eax
  800564:	8d 50 04             	lea    0x4(%eax),%edx
  800567:	89 55 14             	mov    %edx,0x14(%ebp)
  80056a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80056e:	8b 00                	mov    (%eax),%eax
  800570:	89 04 24             	mov    %eax,(%esp)
  800573:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800576:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800579:	e9 23 ff ff ff       	jmp    8004a1 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80057e:	8b 45 14             	mov    0x14(%ebp),%eax
  800581:	8d 50 04             	lea    0x4(%eax),%edx
  800584:	89 55 14             	mov    %edx,0x14(%ebp)
  800587:	8b 00                	mov    (%eax),%eax
  800589:	85 c0                	test   %eax,%eax
  80058b:	79 02                	jns    80058f <vprintfmt+0x111>
  80058d:	f7 d8                	neg    %eax
  80058f:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800591:	83 f8 0f             	cmp    $0xf,%eax
  800594:	7f 0b                	jg     8005a1 <vprintfmt+0x123>
  800596:	8b 04 85 80 2f 80 00 	mov    0x802f80(,%eax,4),%eax
  80059d:	85 c0                	test   %eax,%eax
  80059f:	75 23                	jne    8005c4 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8005a1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005a5:	c7 44 24 08 f3 2c 80 	movl   $0x802cf3,0x8(%esp)
  8005ac:	00 
  8005ad:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8005b4:	89 04 24             	mov    %eax,(%esp)
  8005b7:	e8 9a fe ff ff       	call   800456 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bc:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005bf:	e9 dd fe ff ff       	jmp    8004a1 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8005c4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005c8:	c7 44 24 08 28 31 80 	movl   $0x803128,0x8(%esp)
  8005cf:	00 
  8005d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8005d7:	89 14 24             	mov    %edx,(%esp)
  8005da:	e8 77 fe ff ff       	call   800456 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005df:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005e2:	e9 ba fe ff ff       	jmp    8004a1 <vprintfmt+0x23>
  8005e7:	89 f9                	mov    %edi,%ecx
  8005e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005ec:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f2:	8d 50 04             	lea    0x4(%eax),%edx
  8005f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f8:	8b 30                	mov    (%eax),%esi
  8005fa:	85 f6                	test   %esi,%esi
  8005fc:	75 05                	jne    800603 <vprintfmt+0x185>
				p = "(null)";
  8005fe:	be ec 2c 80 00       	mov    $0x802cec,%esi
			if (width > 0 && padc != '-')
  800603:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800607:	0f 8e 84 00 00 00    	jle    800691 <vprintfmt+0x213>
  80060d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800611:	74 7e                	je     800691 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800613:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800617:	89 34 24             	mov    %esi,(%esp)
  80061a:	e8 8b 02 00 00       	call   8008aa <strnlen>
  80061f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800622:	29 c2                	sub    %eax,%edx
  800624:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800627:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80062b:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80062e:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800631:	89 de                	mov    %ebx,%esi
  800633:	89 d3                	mov    %edx,%ebx
  800635:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800637:	eb 0b                	jmp    800644 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800639:	89 74 24 04          	mov    %esi,0x4(%esp)
  80063d:	89 3c 24             	mov    %edi,(%esp)
  800640:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800643:	4b                   	dec    %ebx
  800644:	85 db                	test   %ebx,%ebx
  800646:	7f f1                	jg     800639 <vprintfmt+0x1bb>
  800648:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80064b:	89 f3                	mov    %esi,%ebx
  80064d:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800650:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800653:	85 c0                	test   %eax,%eax
  800655:	79 05                	jns    80065c <vprintfmt+0x1de>
  800657:	b8 00 00 00 00       	mov    $0x0,%eax
  80065c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80065f:	29 c2                	sub    %eax,%edx
  800661:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800664:	eb 2b                	jmp    800691 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800666:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80066a:	74 18                	je     800684 <vprintfmt+0x206>
  80066c:	8d 50 e0             	lea    -0x20(%eax),%edx
  80066f:	83 fa 5e             	cmp    $0x5e,%edx
  800672:	76 10                	jbe    800684 <vprintfmt+0x206>
					putch('?', putdat);
  800674:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800678:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80067f:	ff 55 08             	call   *0x8(%ebp)
  800682:	eb 0a                	jmp    80068e <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800684:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800688:	89 04 24             	mov    %eax,(%esp)
  80068b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80068e:	ff 4d e4             	decl   -0x1c(%ebp)
  800691:	0f be 06             	movsbl (%esi),%eax
  800694:	46                   	inc    %esi
  800695:	85 c0                	test   %eax,%eax
  800697:	74 21                	je     8006ba <vprintfmt+0x23c>
  800699:	85 ff                	test   %edi,%edi
  80069b:	78 c9                	js     800666 <vprintfmt+0x1e8>
  80069d:	4f                   	dec    %edi
  80069e:	79 c6                	jns    800666 <vprintfmt+0x1e8>
  8006a0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006a3:	89 de                	mov    %ebx,%esi
  8006a5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8006a8:	eb 18                	jmp    8006c2 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006aa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006ae:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006b5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006b7:	4b                   	dec    %ebx
  8006b8:	eb 08                	jmp    8006c2 <vprintfmt+0x244>
  8006ba:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006bd:	89 de                	mov    %ebx,%esi
  8006bf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8006c2:	85 db                	test   %ebx,%ebx
  8006c4:	7f e4                	jg     8006aa <vprintfmt+0x22c>
  8006c6:	89 7d 08             	mov    %edi,0x8(%ebp)
  8006c9:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006cb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006ce:	e9 ce fd ff ff       	jmp    8004a1 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006d3:	83 f9 01             	cmp    $0x1,%ecx
  8006d6:	7e 10                	jle    8006e8 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8006d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006db:	8d 50 08             	lea    0x8(%eax),%edx
  8006de:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e1:	8b 30                	mov    (%eax),%esi
  8006e3:	8b 78 04             	mov    0x4(%eax),%edi
  8006e6:	eb 26                	jmp    80070e <vprintfmt+0x290>
	else if (lflag)
  8006e8:	85 c9                	test   %ecx,%ecx
  8006ea:	74 12                	je     8006fe <vprintfmt+0x280>
		return va_arg(*ap, long);
  8006ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ef:	8d 50 04             	lea    0x4(%eax),%edx
  8006f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f5:	8b 30                	mov    (%eax),%esi
  8006f7:	89 f7                	mov    %esi,%edi
  8006f9:	c1 ff 1f             	sar    $0x1f,%edi
  8006fc:	eb 10                	jmp    80070e <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8006fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800701:	8d 50 04             	lea    0x4(%eax),%edx
  800704:	89 55 14             	mov    %edx,0x14(%ebp)
  800707:	8b 30                	mov    (%eax),%esi
  800709:	89 f7                	mov    %esi,%edi
  80070b:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80070e:	85 ff                	test   %edi,%edi
  800710:	78 0a                	js     80071c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800712:	b8 0a 00 00 00       	mov    $0xa,%eax
  800717:	e9 8c 00 00 00       	jmp    8007a8 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80071c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800720:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800727:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80072a:	f7 de                	neg    %esi
  80072c:	83 d7 00             	adc    $0x0,%edi
  80072f:	f7 df                	neg    %edi
			}
			base = 10;
  800731:	b8 0a 00 00 00       	mov    $0xa,%eax
  800736:	eb 70                	jmp    8007a8 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800738:	89 ca                	mov    %ecx,%edx
  80073a:	8d 45 14             	lea    0x14(%ebp),%eax
  80073d:	e8 c0 fc ff ff       	call   800402 <getuint>
  800742:	89 c6                	mov    %eax,%esi
  800744:	89 d7                	mov    %edx,%edi
			base = 10;
  800746:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80074b:	eb 5b                	jmp    8007a8 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  80074d:	89 ca                	mov    %ecx,%edx
  80074f:	8d 45 14             	lea    0x14(%ebp),%eax
  800752:	e8 ab fc ff ff       	call   800402 <getuint>
  800757:	89 c6                	mov    %eax,%esi
  800759:	89 d7                	mov    %edx,%edi
			base = 8;
  80075b:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800760:	eb 46                	jmp    8007a8 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  800762:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800766:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80076d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800770:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800774:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80077b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80077e:	8b 45 14             	mov    0x14(%ebp),%eax
  800781:	8d 50 04             	lea    0x4(%eax),%edx
  800784:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800787:	8b 30                	mov    (%eax),%esi
  800789:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80078e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800793:	eb 13                	jmp    8007a8 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800795:	89 ca                	mov    %ecx,%edx
  800797:	8d 45 14             	lea    0x14(%ebp),%eax
  80079a:	e8 63 fc ff ff       	call   800402 <getuint>
  80079f:	89 c6                	mov    %eax,%esi
  8007a1:	89 d7                	mov    %edx,%edi
			base = 16;
  8007a3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007a8:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8007ac:	89 54 24 10          	mov    %edx,0x10(%esp)
  8007b0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007b3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007b7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007bb:	89 34 24             	mov    %esi,(%esp)
  8007be:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007c2:	89 da                	mov    %ebx,%edx
  8007c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c7:	e8 6c fb ff ff       	call   800338 <printnum>
			break;
  8007cc:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007cf:	e9 cd fc ff ff       	jmp    8004a1 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007d4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007d8:	89 04 24             	mov    %eax,(%esp)
  8007db:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007de:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007e1:	e9 bb fc ff ff       	jmp    8004a1 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ea:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007f1:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007f4:	eb 01                	jmp    8007f7 <vprintfmt+0x379>
  8007f6:	4e                   	dec    %esi
  8007f7:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007fb:	75 f9                	jne    8007f6 <vprintfmt+0x378>
  8007fd:	e9 9f fc ff ff       	jmp    8004a1 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800802:	83 c4 4c             	add    $0x4c,%esp
  800805:	5b                   	pop    %ebx
  800806:	5e                   	pop    %esi
  800807:	5f                   	pop    %edi
  800808:	5d                   	pop    %ebp
  800809:	c3                   	ret    

0080080a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80080a:	55                   	push   %ebp
  80080b:	89 e5                	mov    %esp,%ebp
  80080d:	83 ec 28             	sub    $0x28,%esp
  800810:	8b 45 08             	mov    0x8(%ebp),%eax
  800813:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800816:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800819:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80081d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800820:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800827:	85 c0                	test   %eax,%eax
  800829:	74 30                	je     80085b <vsnprintf+0x51>
  80082b:	85 d2                	test   %edx,%edx
  80082d:	7e 33                	jle    800862 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80082f:	8b 45 14             	mov    0x14(%ebp),%eax
  800832:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800836:	8b 45 10             	mov    0x10(%ebp),%eax
  800839:	89 44 24 08          	mov    %eax,0x8(%esp)
  80083d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800840:	89 44 24 04          	mov    %eax,0x4(%esp)
  800844:	c7 04 24 3c 04 80 00 	movl   $0x80043c,(%esp)
  80084b:	e8 2e fc ff ff       	call   80047e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800850:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800853:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800856:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800859:	eb 0c                	jmp    800867 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80085b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800860:	eb 05                	jmp    800867 <vsnprintf+0x5d>
  800862:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800867:	c9                   	leave  
  800868:	c3                   	ret    

00800869 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800869:	55                   	push   %ebp
  80086a:	89 e5                	mov    %esp,%ebp
  80086c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80086f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800872:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800876:	8b 45 10             	mov    0x10(%ebp),%eax
  800879:	89 44 24 08          	mov    %eax,0x8(%esp)
  80087d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800880:	89 44 24 04          	mov    %eax,0x4(%esp)
  800884:	8b 45 08             	mov    0x8(%ebp),%eax
  800887:	89 04 24             	mov    %eax,(%esp)
  80088a:	e8 7b ff ff ff       	call   80080a <vsnprintf>
	va_end(ap);

	return rc;
}
  80088f:	c9                   	leave  
  800890:	c3                   	ret    
  800891:	00 00                	add    %al,(%eax)
	...

00800894 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80089a:	b8 00 00 00 00       	mov    $0x0,%eax
  80089f:	eb 01                	jmp    8008a2 <strlen+0xe>
		n++;
  8008a1:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008a2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008a6:	75 f9                	jne    8008a1 <strlen+0xd>
		n++;
	return n;
}
  8008a8:	5d                   	pop    %ebp
  8008a9:	c3                   	ret    

008008aa <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008aa:	55                   	push   %ebp
  8008ab:	89 e5                	mov    %esp,%ebp
  8008ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8008b0:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b8:	eb 01                	jmp    8008bb <strnlen+0x11>
		n++;
  8008ba:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008bb:	39 d0                	cmp    %edx,%eax
  8008bd:	74 06                	je     8008c5 <strnlen+0x1b>
  8008bf:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008c3:	75 f5                	jne    8008ba <strnlen+0x10>
		n++;
	return n;
}
  8008c5:	5d                   	pop    %ebp
  8008c6:	c3                   	ret    

008008c7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008c7:	55                   	push   %ebp
  8008c8:	89 e5                	mov    %esp,%ebp
  8008ca:	53                   	push   %ebx
  8008cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8008d6:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8008d9:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008dc:	42                   	inc    %edx
  8008dd:	84 c9                	test   %cl,%cl
  8008df:	75 f5                	jne    8008d6 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008e1:	5b                   	pop    %ebx
  8008e2:	5d                   	pop    %ebp
  8008e3:	c3                   	ret    

008008e4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	53                   	push   %ebx
  8008e8:	83 ec 08             	sub    $0x8,%esp
  8008eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008ee:	89 1c 24             	mov    %ebx,(%esp)
  8008f1:	e8 9e ff ff ff       	call   800894 <strlen>
	strcpy(dst + len, src);
  8008f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008f9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008fd:	01 d8                	add    %ebx,%eax
  8008ff:	89 04 24             	mov    %eax,(%esp)
  800902:	e8 c0 ff ff ff       	call   8008c7 <strcpy>
	return dst;
}
  800907:	89 d8                	mov    %ebx,%eax
  800909:	83 c4 08             	add    $0x8,%esp
  80090c:	5b                   	pop    %ebx
  80090d:	5d                   	pop    %ebp
  80090e:	c3                   	ret    

0080090f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80090f:	55                   	push   %ebp
  800910:	89 e5                	mov    %esp,%ebp
  800912:	56                   	push   %esi
  800913:	53                   	push   %ebx
  800914:	8b 45 08             	mov    0x8(%ebp),%eax
  800917:	8b 55 0c             	mov    0xc(%ebp),%edx
  80091a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80091d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800922:	eb 0c                	jmp    800930 <strncpy+0x21>
		*dst++ = *src;
  800924:	8a 1a                	mov    (%edx),%bl
  800926:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800929:	80 3a 01             	cmpb   $0x1,(%edx)
  80092c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80092f:	41                   	inc    %ecx
  800930:	39 f1                	cmp    %esi,%ecx
  800932:	75 f0                	jne    800924 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800934:	5b                   	pop    %ebx
  800935:	5e                   	pop    %esi
  800936:	5d                   	pop    %ebp
  800937:	c3                   	ret    

00800938 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800938:	55                   	push   %ebp
  800939:	89 e5                	mov    %esp,%ebp
  80093b:	56                   	push   %esi
  80093c:	53                   	push   %ebx
  80093d:	8b 75 08             	mov    0x8(%ebp),%esi
  800940:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800943:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800946:	85 d2                	test   %edx,%edx
  800948:	75 0a                	jne    800954 <strlcpy+0x1c>
  80094a:	89 f0                	mov    %esi,%eax
  80094c:	eb 1a                	jmp    800968 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80094e:	88 18                	mov    %bl,(%eax)
  800950:	40                   	inc    %eax
  800951:	41                   	inc    %ecx
  800952:	eb 02                	jmp    800956 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800954:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800956:	4a                   	dec    %edx
  800957:	74 0a                	je     800963 <strlcpy+0x2b>
  800959:	8a 19                	mov    (%ecx),%bl
  80095b:	84 db                	test   %bl,%bl
  80095d:	75 ef                	jne    80094e <strlcpy+0x16>
  80095f:	89 c2                	mov    %eax,%edx
  800961:	eb 02                	jmp    800965 <strlcpy+0x2d>
  800963:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800965:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800968:	29 f0                	sub    %esi,%eax
}
  80096a:	5b                   	pop    %ebx
  80096b:	5e                   	pop    %esi
  80096c:	5d                   	pop    %ebp
  80096d:	c3                   	ret    

0080096e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80096e:	55                   	push   %ebp
  80096f:	89 e5                	mov    %esp,%ebp
  800971:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800974:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800977:	eb 02                	jmp    80097b <strcmp+0xd>
		p++, q++;
  800979:	41                   	inc    %ecx
  80097a:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80097b:	8a 01                	mov    (%ecx),%al
  80097d:	84 c0                	test   %al,%al
  80097f:	74 04                	je     800985 <strcmp+0x17>
  800981:	3a 02                	cmp    (%edx),%al
  800983:	74 f4                	je     800979 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800985:	0f b6 c0             	movzbl %al,%eax
  800988:	0f b6 12             	movzbl (%edx),%edx
  80098b:	29 d0                	sub    %edx,%eax
}
  80098d:	5d                   	pop    %ebp
  80098e:	c3                   	ret    

0080098f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80098f:	55                   	push   %ebp
  800990:	89 e5                	mov    %esp,%ebp
  800992:	53                   	push   %ebx
  800993:	8b 45 08             	mov    0x8(%ebp),%eax
  800996:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800999:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  80099c:	eb 03                	jmp    8009a1 <strncmp+0x12>
		n--, p++, q++;
  80099e:	4a                   	dec    %edx
  80099f:	40                   	inc    %eax
  8009a0:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009a1:	85 d2                	test   %edx,%edx
  8009a3:	74 14                	je     8009b9 <strncmp+0x2a>
  8009a5:	8a 18                	mov    (%eax),%bl
  8009a7:	84 db                	test   %bl,%bl
  8009a9:	74 04                	je     8009af <strncmp+0x20>
  8009ab:	3a 19                	cmp    (%ecx),%bl
  8009ad:	74 ef                	je     80099e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009af:	0f b6 00             	movzbl (%eax),%eax
  8009b2:	0f b6 11             	movzbl (%ecx),%edx
  8009b5:	29 d0                	sub    %edx,%eax
  8009b7:	eb 05                	jmp    8009be <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009b9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009be:	5b                   	pop    %ebx
  8009bf:	5d                   	pop    %ebp
  8009c0:	c3                   	ret    

008009c1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009c1:	55                   	push   %ebp
  8009c2:	89 e5                	mov    %esp,%ebp
  8009c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c7:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009ca:	eb 05                	jmp    8009d1 <strchr+0x10>
		if (*s == c)
  8009cc:	38 ca                	cmp    %cl,%dl
  8009ce:	74 0c                	je     8009dc <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009d0:	40                   	inc    %eax
  8009d1:	8a 10                	mov    (%eax),%dl
  8009d3:	84 d2                	test   %dl,%dl
  8009d5:	75 f5                	jne    8009cc <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8009d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009dc:	5d                   	pop    %ebp
  8009dd:	c3                   	ret    

008009de <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
  8009e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e4:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009e7:	eb 05                	jmp    8009ee <strfind+0x10>
		if (*s == c)
  8009e9:	38 ca                	cmp    %cl,%dl
  8009eb:	74 07                	je     8009f4 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009ed:	40                   	inc    %eax
  8009ee:	8a 10                	mov    (%eax),%dl
  8009f0:	84 d2                	test   %dl,%dl
  8009f2:	75 f5                	jne    8009e9 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8009f4:	5d                   	pop    %ebp
  8009f5:	c3                   	ret    

008009f6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	57                   	push   %edi
  8009fa:	56                   	push   %esi
  8009fb:	53                   	push   %ebx
  8009fc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a02:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a05:	85 c9                	test   %ecx,%ecx
  800a07:	74 30                	je     800a39 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a09:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a0f:	75 25                	jne    800a36 <memset+0x40>
  800a11:	f6 c1 03             	test   $0x3,%cl
  800a14:	75 20                	jne    800a36 <memset+0x40>
		c &= 0xFF;
  800a16:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a19:	89 d3                	mov    %edx,%ebx
  800a1b:	c1 e3 08             	shl    $0x8,%ebx
  800a1e:	89 d6                	mov    %edx,%esi
  800a20:	c1 e6 18             	shl    $0x18,%esi
  800a23:	89 d0                	mov    %edx,%eax
  800a25:	c1 e0 10             	shl    $0x10,%eax
  800a28:	09 f0                	or     %esi,%eax
  800a2a:	09 d0                	or     %edx,%eax
  800a2c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a2e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a31:	fc                   	cld    
  800a32:	f3 ab                	rep stos %eax,%es:(%edi)
  800a34:	eb 03                	jmp    800a39 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a36:	fc                   	cld    
  800a37:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a39:	89 f8                	mov    %edi,%eax
  800a3b:	5b                   	pop    %ebx
  800a3c:	5e                   	pop    %esi
  800a3d:	5f                   	pop    %edi
  800a3e:	5d                   	pop    %ebp
  800a3f:	c3                   	ret    

00800a40 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a40:	55                   	push   %ebp
  800a41:	89 e5                	mov    %esp,%ebp
  800a43:	57                   	push   %edi
  800a44:	56                   	push   %esi
  800a45:	8b 45 08             	mov    0x8(%ebp),%eax
  800a48:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a4b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a4e:	39 c6                	cmp    %eax,%esi
  800a50:	73 34                	jae    800a86 <memmove+0x46>
  800a52:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a55:	39 d0                	cmp    %edx,%eax
  800a57:	73 2d                	jae    800a86 <memmove+0x46>
		s += n;
		d += n;
  800a59:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a5c:	f6 c2 03             	test   $0x3,%dl
  800a5f:	75 1b                	jne    800a7c <memmove+0x3c>
  800a61:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a67:	75 13                	jne    800a7c <memmove+0x3c>
  800a69:	f6 c1 03             	test   $0x3,%cl
  800a6c:	75 0e                	jne    800a7c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a6e:	83 ef 04             	sub    $0x4,%edi
  800a71:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a74:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a77:	fd                   	std    
  800a78:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a7a:	eb 07                	jmp    800a83 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a7c:	4f                   	dec    %edi
  800a7d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a80:	fd                   	std    
  800a81:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a83:	fc                   	cld    
  800a84:	eb 20                	jmp    800aa6 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a86:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a8c:	75 13                	jne    800aa1 <memmove+0x61>
  800a8e:	a8 03                	test   $0x3,%al
  800a90:	75 0f                	jne    800aa1 <memmove+0x61>
  800a92:	f6 c1 03             	test   $0x3,%cl
  800a95:	75 0a                	jne    800aa1 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a97:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a9a:	89 c7                	mov    %eax,%edi
  800a9c:	fc                   	cld    
  800a9d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a9f:	eb 05                	jmp    800aa6 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800aa1:	89 c7                	mov    %eax,%edi
  800aa3:	fc                   	cld    
  800aa4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aa6:	5e                   	pop    %esi
  800aa7:	5f                   	pop    %edi
  800aa8:	5d                   	pop    %ebp
  800aa9:	c3                   	ret    

00800aaa <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aaa:	55                   	push   %ebp
  800aab:	89 e5                	mov    %esp,%ebp
  800aad:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ab0:	8b 45 10             	mov    0x10(%ebp),%eax
  800ab3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ab7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aba:	89 44 24 04          	mov    %eax,0x4(%esp)
  800abe:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac1:	89 04 24             	mov    %eax,(%esp)
  800ac4:	e8 77 ff ff ff       	call   800a40 <memmove>
}
  800ac9:	c9                   	leave  
  800aca:	c3                   	ret    

00800acb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800acb:	55                   	push   %ebp
  800acc:	89 e5                	mov    %esp,%ebp
  800ace:	57                   	push   %edi
  800acf:	56                   	push   %esi
  800ad0:	53                   	push   %ebx
  800ad1:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ad4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ad7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ada:	ba 00 00 00 00       	mov    $0x0,%edx
  800adf:	eb 16                	jmp    800af7 <memcmp+0x2c>
		if (*s1 != *s2)
  800ae1:	8a 04 17             	mov    (%edi,%edx,1),%al
  800ae4:	42                   	inc    %edx
  800ae5:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800ae9:	38 c8                	cmp    %cl,%al
  800aeb:	74 0a                	je     800af7 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800aed:	0f b6 c0             	movzbl %al,%eax
  800af0:	0f b6 c9             	movzbl %cl,%ecx
  800af3:	29 c8                	sub    %ecx,%eax
  800af5:	eb 09                	jmp    800b00 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800af7:	39 da                	cmp    %ebx,%edx
  800af9:	75 e6                	jne    800ae1 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800afb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b00:	5b                   	pop    %ebx
  800b01:	5e                   	pop    %esi
  800b02:	5f                   	pop    %edi
  800b03:	5d                   	pop    %ebp
  800b04:	c3                   	ret    

00800b05 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b05:	55                   	push   %ebp
  800b06:	89 e5                	mov    %esp,%ebp
  800b08:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b0e:	89 c2                	mov    %eax,%edx
  800b10:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b13:	eb 05                	jmp    800b1a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b15:	38 08                	cmp    %cl,(%eax)
  800b17:	74 05                	je     800b1e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b19:	40                   	inc    %eax
  800b1a:	39 d0                	cmp    %edx,%eax
  800b1c:	72 f7                	jb     800b15 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b1e:	5d                   	pop    %ebp
  800b1f:	c3                   	ret    

00800b20 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	57                   	push   %edi
  800b24:	56                   	push   %esi
  800b25:	53                   	push   %ebx
  800b26:	8b 55 08             	mov    0x8(%ebp),%edx
  800b29:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b2c:	eb 01                	jmp    800b2f <strtol+0xf>
		s++;
  800b2e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b2f:	8a 02                	mov    (%edx),%al
  800b31:	3c 20                	cmp    $0x20,%al
  800b33:	74 f9                	je     800b2e <strtol+0xe>
  800b35:	3c 09                	cmp    $0x9,%al
  800b37:	74 f5                	je     800b2e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b39:	3c 2b                	cmp    $0x2b,%al
  800b3b:	75 08                	jne    800b45 <strtol+0x25>
		s++;
  800b3d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b3e:	bf 00 00 00 00       	mov    $0x0,%edi
  800b43:	eb 13                	jmp    800b58 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b45:	3c 2d                	cmp    $0x2d,%al
  800b47:	75 0a                	jne    800b53 <strtol+0x33>
		s++, neg = 1;
  800b49:	8d 52 01             	lea    0x1(%edx),%edx
  800b4c:	bf 01 00 00 00       	mov    $0x1,%edi
  800b51:	eb 05                	jmp    800b58 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b53:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b58:	85 db                	test   %ebx,%ebx
  800b5a:	74 05                	je     800b61 <strtol+0x41>
  800b5c:	83 fb 10             	cmp    $0x10,%ebx
  800b5f:	75 28                	jne    800b89 <strtol+0x69>
  800b61:	8a 02                	mov    (%edx),%al
  800b63:	3c 30                	cmp    $0x30,%al
  800b65:	75 10                	jne    800b77 <strtol+0x57>
  800b67:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b6b:	75 0a                	jne    800b77 <strtol+0x57>
		s += 2, base = 16;
  800b6d:	83 c2 02             	add    $0x2,%edx
  800b70:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b75:	eb 12                	jmp    800b89 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b77:	85 db                	test   %ebx,%ebx
  800b79:	75 0e                	jne    800b89 <strtol+0x69>
  800b7b:	3c 30                	cmp    $0x30,%al
  800b7d:	75 05                	jne    800b84 <strtol+0x64>
		s++, base = 8;
  800b7f:	42                   	inc    %edx
  800b80:	b3 08                	mov    $0x8,%bl
  800b82:	eb 05                	jmp    800b89 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b84:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b89:	b8 00 00 00 00       	mov    $0x0,%eax
  800b8e:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b90:	8a 0a                	mov    (%edx),%cl
  800b92:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b95:	80 fb 09             	cmp    $0x9,%bl
  800b98:	77 08                	ja     800ba2 <strtol+0x82>
			dig = *s - '0';
  800b9a:	0f be c9             	movsbl %cl,%ecx
  800b9d:	83 e9 30             	sub    $0x30,%ecx
  800ba0:	eb 1e                	jmp    800bc0 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800ba2:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ba5:	80 fb 19             	cmp    $0x19,%bl
  800ba8:	77 08                	ja     800bb2 <strtol+0x92>
			dig = *s - 'a' + 10;
  800baa:	0f be c9             	movsbl %cl,%ecx
  800bad:	83 e9 57             	sub    $0x57,%ecx
  800bb0:	eb 0e                	jmp    800bc0 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800bb2:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800bb5:	80 fb 19             	cmp    $0x19,%bl
  800bb8:	77 12                	ja     800bcc <strtol+0xac>
			dig = *s - 'A' + 10;
  800bba:	0f be c9             	movsbl %cl,%ecx
  800bbd:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bc0:	39 f1                	cmp    %esi,%ecx
  800bc2:	7d 0c                	jge    800bd0 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800bc4:	42                   	inc    %edx
  800bc5:	0f af c6             	imul   %esi,%eax
  800bc8:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800bca:	eb c4                	jmp    800b90 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800bcc:	89 c1                	mov    %eax,%ecx
  800bce:	eb 02                	jmp    800bd2 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bd0:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800bd2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bd6:	74 05                	je     800bdd <strtol+0xbd>
		*endptr = (char *) s;
  800bd8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bdb:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800bdd:	85 ff                	test   %edi,%edi
  800bdf:	74 04                	je     800be5 <strtol+0xc5>
  800be1:	89 c8                	mov    %ecx,%eax
  800be3:	f7 d8                	neg    %eax
}
  800be5:	5b                   	pop    %ebx
  800be6:	5e                   	pop    %esi
  800be7:	5f                   	pop    %edi
  800be8:	5d                   	pop    %ebp
  800be9:	c3                   	ret    
	...

00800bec <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	57                   	push   %edi
  800bf0:	56                   	push   %esi
  800bf1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf2:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfd:	89 c3                	mov    %eax,%ebx
  800bff:	89 c7                	mov    %eax,%edi
  800c01:	89 c6                	mov    %eax,%esi
  800c03:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c05:	5b                   	pop    %ebx
  800c06:	5e                   	pop    %esi
  800c07:	5f                   	pop    %edi
  800c08:	5d                   	pop    %ebp
  800c09:	c3                   	ret    

00800c0a <sys_cgetc>:

int
sys_cgetc(void)
{
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	57                   	push   %edi
  800c0e:	56                   	push   %esi
  800c0f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c10:	ba 00 00 00 00       	mov    $0x0,%edx
  800c15:	b8 01 00 00 00       	mov    $0x1,%eax
  800c1a:	89 d1                	mov    %edx,%ecx
  800c1c:	89 d3                	mov    %edx,%ebx
  800c1e:	89 d7                	mov    %edx,%edi
  800c20:	89 d6                	mov    %edx,%esi
  800c22:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c24:	5b                   	pop    %ebx
  800c25:	5e                   	pop    %esi
  800c26:	5f                   	pop    %edi
  800c27:	5d                   	pop    %ebp
  800c28:	c3                   	ret    

00800c29 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c29:	55                   	push   %ebp
  800c2a:	89 e5                	mov    %esp,%ebp
  800c2c:	57                   	push   %edi
  800c2d:	56                   	push   %esi
  800c2e:	53                   	push   %ebx
  800c2f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c32:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c37:	b8 03 00 00 00       	mov    $0x3,%eax
  800c3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3f:	89 cb                	mov    %ecx,%ebx
  800c41:	89 cf                	mov    %ecx,%edi
  800c43:	89 ce                	mov    %ecx,%esi
  800c45:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c47:	85 c0                	test   %eax,%eax
  800c49:	7e 28                	jle    800c73 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c4f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c56:	00 
  800c57:	c7 44 24 08 df 2f 80 	movl   $0x802fdf,0x8(%esp)
  800c5e:	00 
  800c5f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c66:	00 
  800c67:	c7 04 24 fc 2f 80 00 	movl   $0x802ffc,(%esp)
  800c6e:	e8 b1 f5 ff ff       	call   800224 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c73:	83 c4 2c             	add    $0x2c,%esp
  800c76:	5b                   	pop    %ebx
  800c77:	5e                   	pop    %esi
  800c78:	5f                   	pop    %edi
  800c79:	5d                   	pop    %ebp
  800c7a:	c3                   	ret    

00800c7b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c7b:	55                   	push   %ebp
  800c7c:	89 e5                	mov    %esp,%ebp
  800c7e:	57                   	push   %edi
  800c7f:	56                   	push   %esi
  800c80:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c81:	ba 00 00 00 00       	mov    $0x0,%edx
  800c86:	b8 02 00 00 00       	mov    $0x2,%eax
  800c8b:	89 d1                	mov    %edx,%ecx
  800c8d:	89 d3                	mov    %edx,%ebx
  800c8f:	89 d7                	mov    %edx,%edi
  800c91:	89 d6                	mov    %edx,%esi
  800c93:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c95:	5b                   	pop    %ebx
  800c96:	5e                   	pop    %esi
  800c97:	5f                   	pop    %edi
  800c98:	5d                   	pop    %ebp
  800c99:	c3                   	ret    

00800c9a <sys_yield>:

void
sys_yield(void)
{
  800c9a:	55                   	push   %ebp
  800c9b:	89 e5                	mov    %esp,%ebp
  800c9d:	57                   	push   %edi
  800c9e:	56                   	push   %esi
  800c9f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800caa:	89 d1                	mov    %edx,%ecx
  800cac:	89 d3                	mov    %edx,%ebx
  800cae:	89 d7                	mov    %edx,%edi
  800cb0:	89 d6                	mov    %edx,%esi
  800cb2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cb4:	5b                   	pop    %ebx
  800cb5:	5e                   	pop    %esi
  800cb6:	5f                   	pop    %edi
  800cb7:	5d                   	pop    %ebp
  800cb8:	c3                   	ret    

00800cb9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cb9:	55                   	push   %ebp
  800cba:	89 e5                	mov    %esp,%ebp
  800cbc:	57                   	push   %edi
  800cbd:	56                   	push   %esi
  800cbe:	53                   	push   %ebx
  800cbf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc2:	be 00 00 00 00       	mov    $0x0,%esi
  800cc7:	b8 04 00 00 00       	mov    $0x4,%eax
  800ccc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ccf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd5:	89 f7                	mov    %esi,%edi
  800cd7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cd9:	85 c0                	test   %eax,%eax
  800cdb:	7e 28                	jle    800d05 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ce1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800ce8:	00 
  800ce9:	c7 44 24 08 df 2f 80 	movl   $0x802fdf,0x8(%esp)
  800cf0:	00 
  800cf1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cf8:	00 
  800cf9:	c7 04 24 fc 2f 80 00 	movl   $0x802ffc,(%esp)
  800d00:	e8 1f f5 ff ff       	call   800224 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d05:	83 c4 2c             	add    $0x2c,%esp
  800d08:	5b                   	pop    %ebx
  800d09:	5e                   	pop    %esi
  800d0a:	5f                   	pop    %edi
  800d0b:	5d                   	pop    %ebp
  800d0c:	c3                   	ret    

00800d0d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d0d:	55                   	push   %ebp
  800d0e:	89 e5                	mov    %esp,%ebp
  800d10:	57                   	push   %edi
  800d11:	56                   	push   %esi
  800d12:	53                   	push   %ebx
  800d13:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d16:	b8 05 00 00 00       	mov    $0x5,%eax
  800d1b:	8b 75 18             	mov    0x18(%ebp),%esi
  800d1e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d21:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d27:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d2c:	85 c0                	test   %eax,%eax
  800d2e:	7e 28                	jle    800d58 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d30:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d34:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d3b:	00 
  800d3c:	c7 44 24 08 df 2f 80 	movl   $0x802fdf,0x8(%esp)
  800d43:	00 
  800d44:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d4b:	00 
  800d4c:	c7 04 24 fc 2f 80 00 	movl   $0x802ffc,(%esp)
  800d53:	e8 cc f4 ff ff       	call   800224 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d58:	83 c4 2c             	add    $0x2c,%esp
  800d5b:	5b                   	pop    %ebx
  800d5c:	5e                   	pop    %esi
  800d5d:	5f                   	pop    %edi
  800d5e:	5d                   	pop    %ebp
  800d5f:	c3                   	ret    

00800d60 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d60:	55                   	push   %ebp
  800d61:	89 e5                	mov    %esp,%ebp
  800d63:	57                   	push   %edi
  800d64:	56                   	push   %esi
  800d65:	53                   	push   %ebx
  800d66:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d69:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d6e:	b8 06 00 00 00       	mov    $0x6,%eax
  800d73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d76:	8b 55 08             	mov    0x8(%ebp),%edx
  800d79:	89 df                	mov    %ebx,%edi
  800d7b:	89 de                	mov    %ebx,%esi
  800d7d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d7f:	85 c0                	test   %eax,%eax
  800d81:	7e 28                	jle    800dab <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d83:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d87:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d8e:	00 
  800d8f:	c7 44 24 08 df 2f 80 	movl   $0x802fdf,0x8(%esp)
  800d96:	00 
  800d97:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d9e:	00 
  800d9f:	c7 04 24 fc 2f 80 00 	movl   $0x802ffc,(%esp)
  800da6:	e8 79 f4 ff ff       	call   800224 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dab:	83 c4 2c             	add    $0x2c,%esp
  800dae:	5b                   	pop    %ebx
  800daf:	5e                   	pop    %esi
  800db0:	5f                   	pop    %edi
  800db1:	5d                   	pop    %ebp
  800db2:	c3                   	ret    

00800db3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800db3:	55                   	push   %ebp
  800db4:	89 e5                	mov    %esp,%ebp
  800db6:	57                   	push   %edi
  800db7:	56                   	push   %esi
  800db8:	53                   	push   %ebx
  800db9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dbc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc1:	b8 08 00 00 00       	mov    $0x8,%eax
  800dc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcc:	89 df                	mov    %ebx,%edi
  800dce:	89 de                	mov    %ebx,%esi
  800dd0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dd2:	85 c0                	test   %eax,%eax
  800dd4:	7e 28                	jle    800dfe <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dda:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800de1:	00 
  800de2:	c7 44 24 08 df 2f 80 	movl   $0x802fdf,0x8(%esp)
  800de9:	00 
  800dea:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800df1:	00 
  800df2:	c7 04 24 fc 2f 80 00 	movl   $0x802ffc,(%esp)
  800df9:	e8 26 f4 ff ff       	call   800224 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dfe:	83 c4 2c             	add    $0x2c,%esp
  800e01:	5b                   	pop    %ebx
  800e02:	5e                   	pop    %esi
  800e03:	5f                   	pop    %edi
  800e04:	5d                   	pop    %ebp
  800e05:	c3                   	ret    

00800e06 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e06:	55                   	push   %ebp
  800e07:	89 e5                	mov    %esp,%ebp
  800e09:	57                   	push   %edi
  800e0a:	56                   	push   %esi
  800e0b:	53                   	push   %ebx
  800e0c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e14:	b8 09 00 00 00       	mov    $0x9,%eax
  800e19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1f:	89 df                	mov    %ebx,%edi
  800e21:	89 de                	mov    %ebx,%esi
  800e23:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e25:	85 c0                	test   %eax,%eax
  800e27:	7e 28                	jle    800e51 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e29:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e2d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e34:	00 
  800e35:	c7 44 24 08 df 2f 80 	movl   $0x802fdf,0x8(%esp)
  800e3c:	00 
  800e3d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e44:	00 
  800e45:	c7 04 24 fc 2f 80 00 	movl   $0x802ffc,(%esp)
  800e4c:	e8 d3 f3 ff ff       	call   800224 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e51:	83 c4 2c             	add    $0x2c,%esp
  800e54:	5b                   	pop    %ebx
  800e55:	5e                   	pop    %esi
  800e56:	5f                   	pop    %edi
  800e57:	5d                   	pop    %ebp
  800e58:	c3                   	ret    

00800e59 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e59:	55                   	push   %ebp
  800e5a:	89 e5                	mov    %esp,%ebp
  800e5c:	57                   	push   %edi
  800e5d:	56                   	push   %esi
  800e5e:	53                   	push   %ebx
  800e5f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e62:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e67:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e72:	89 df                	mov    %ebx,%edi
  800e74:	89 de                	mov    %ebx,%esi
  800e76:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e78:	85 c0                	test   %eax,%eax
  800e7a:	7e 28                	jle    800ea4 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e7c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e80:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e87:	00 
  800e88:	c7 44 24 08 df 2f 80 	movl   $0x802fdf,0x8(%esp)
  800e8f:	00 
  800e90:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e97:	00 
  800e98:	c7 04 24 fc 2f 80 00 	movl   $0x802ffc,(%esp)
  800e9f:	e8 80 f3 ff ff       	call   800224 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ea4:	83 c4 2c             	add    $0x2c,%esp
  800ea7:	5b                   	pop    %ebx
  800ea8:	5e                   	pop    %esi
  800ea9:	5f                   	pop    %edi
  800eaa:	5d                   	pop    %ebp
  800eab:	c3                   	ret    

00800eac <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800eac:	55                   	push   %ebp
  800ead:	89 e5                	mov    %esp,%ebp
  800eaf:	57                   	push   %edi
  800eb0:	56                   	push   %esi
  800eb1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb2:	be 00 00 00 00       	mov    $0x0,%esi
  800eb7:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ebc:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ebf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ec2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800eca:	5b                   	pop    %ebx
  800ecb:	5e                   	pop    %esi
  800ecc:	5f                   	pop    %edi
  800ecd:	5d                   	pop    %ebp
  800ece:	c3                   	ret    

00800ecf <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ecf:	55                   	push   %ebp
  800ed0:	89 e5                	mov    %esp,%ebp
  800ed2:	57                   	push   %edi
  800ed3:	56                   	push   %esi
  800ed4:	53                   	push   %ebx
  800ed5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800edd:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ee2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee5:	89 cb                	mov    %ecx,%ebx
  800ee7:	89 cf                	mov    %ecx,%edi
  800ee9:	89 ce                	mov    %ecx,%esi
  800eeb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eed:	85 c0                	test   %eax,%eax
  800eef:	7e 28                	jle    800f19 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ef1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ef5:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800efc:	00 
  800efd:	c7 44 24 08 df 2f 80 	movl   $0x802fdf,0x8(%esp)
  800f04:	00 
  800f05:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f0c:	00 
  800f0d:	c7 04 24 fc 2f 80 00 	movl   $0x802ffc,(%esp)
  800f14:	e8 0b f3 ff ff       	call   800224 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f19:	83 c4 2c             	add    $0x2c,%esp
  800f1c:	5b                   	pop    %ebx
  800f1d:	5e                   	pop    %esi
  800f1e:	5f                   	pop    %edi
  800f1f:	5d                   	pop    %ebp
  800f20:	c3                   	ret    
  800f21:	00 00                	add    %al,(%eax)
	...

00800f24 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f24:	55                   	push   %ebp
  800f25:	89 e5                	mov    %esp,%ebp
  800f27:	53                   	push   %ebx
  800f28:	83 ec 24             	sub    $0x24,%esp
  800f2b:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f2e:	8b 18                	mov    (%eax),%ebx
	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	if ((err & FEC_WR) == 0)
  800f30:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f34:	75 20                	jne    800f56 <pgfault+0x32>
		panic("pgfault: faulting address [%08x] not a write\n", addr);
  800f36:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f3a:	c7 44 24 08 0c 30 80 	movl   $0x80300c,0x8(%esp)
  800f41:	00 
  800f42:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  800f49:	00 
  800f4a:	c7 04 24 8c 30 80 00 	movl   $0x80308c,(%esp)
  800f51:	e8 ce f2 ff ff       	call   800224 <_panic>

	void *page_aligned_addr = (void *) ROUNDDOWN(addr, PGSIZE);
  800f56:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t page_num = (uint32_t) page_aligned_addr / PGSIZE;
  800f5c:	89 d8                	mov    %ebx,%eax
  800f5e:	c1 e8 0c             	shr    $0xc,%eax
	if (!(uvpt[page_num] & PTE_COW))
  800f61:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f68:	f6 c4 08             	test   $0x8,%ah
  800f6b:	75 1c                	jne    800f89 <pgfault+0x65>
		panic("pgfault: fault was not on a copy-on-write page\n");
  800f6d:	c7 44 24 08 3c 30 80 	movl   $0x80303c,0x8(%esp)
  800f74:	00 
  800f75:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f7c:	00 
  800f7d:	c7 04 24 8c 30 80 00 	movl   $0x80308c,(%esp)
  800f84:	e8 9b f2 ff ff       	call   800224 <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.

	// Allocate
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800f89:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800f90:	00 
  800f91:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f98:	00 
  800f99:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fa0:	e8 14 fd ff ff       	call   800cb9 <sys_page_alloc>
  800fa5:	85 c0                	test   %eax,%eax
  800fa7:	79 20                	jns    800fc9 <pgfault+0xa5>
		panic("sys_page_alloc: %e\n", r);
  800fa9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fad:	c7 44 24 08 97 30 80 	movl   $0x803097,0x8(%esp)
  800fb4:	00 
  800fb5:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  800fbc:	00 
  800fbd:	c7 04 24 8c 30 80 00 	movl   $0x80308c,(%esp)
  800fc4:	e8 5b f2 ff ff       	call   800224 <_panic>

	// Copy over
	void *src_addr = (void *) ROUNDDOWN(addr, PGSIZE);
	memmove(PFTEMP, src_addr, PGSIZE);
  800fc9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800fd0:	00 
  800fd1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800fd5:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800fdc:	e8 5f fa ff ff       	call   800a40 <memmove>

	// Remap
	if ((r = sys_page_map(0, PFTEMP, 0, src_addr, PTE_P | PTE_U | PTE_W)) < 0)
  800fe1:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800fe8:	00 
  800fe9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800fed:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ff4:	00 
  800ff5:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800ffc:	00 
  800ffd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801004:	e8 04 fd ff ff       	call   800d0d <sys_page_map>
  801009:	85 c0                	test   %eax,%eax
  80100b:	79 20                	jns    80102d <pgfault+0x109>
		panic("sys_page_map: %e\n", r);
  80100d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801011:	c7 44 24 08 ab 30 80 	movl   $0x8030ab,0x8(%esp)
  801018:	00 
  801019:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  801020:	00 
  801021:	c7 04 24 8c 30 80 00 	movl   $0x80308c,(%esp)
  801028:	e8 f7 f1 ff ff       	call   800224 <_panic>

}
  80102d:	83 c4 24             	add    $0x24,%esp
  801030:	5b                   	pop    %ebx
  801031:	5d                   	pop    %ebp
  801032:	c3                   	ret    

00801033 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801033:	55                   	push   %ebp
  801034:	89 e5                	mov    %esp,%ebp
  801036:	57                   	push   %edi
  801037:	56                   	push   %esi
  801038:	53                   	push   %ebx
  801039:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	int r;
	envid_t child_envid;

	set_pgfault_handler(pgfault);
  80103c:	c7 04 24 24 0f 80 00 	movl   $0x800f24,(%esp)
  801043:	e8 c8 09 00 00       	call   801a10 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801048:	ba 07 00 00 00       	mov    $0x7,%edx
  80104d:	89 d0                	mov    %edx,%eax
  80104f:	cd 30                	int    $0x30
  801051:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801054:	89 45 e0             	mov    %eax,-0x20(%ebp)

	child_envid = sys_exofork();
	if (child_envid < 0)
  801057:	85 c0                	test   %eax,%eax
  801059:	79 20                	jns    80107b <fork+0x48>
		panic("sys_exofork: %e\n", child_envid);
  80105b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80105f:	c7 44 24 08 bd 30 80 	movl   $0x8030bd,0x8(%esp)
  801066:	00 
  801067:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  80106e:	00 
  80106f:	c7 04 24 8c 30 80 00 	movl   $0x80308c,(%esp)
  801076:	e8 a9 f1 ff ff       	call   800224 <_panic>
	if (child_envid == 0) { // child
  80107b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80107f:	75 25                	jne    8010a6 <fork+0x73>
		// Fix thisenv like dumbfork does and return 0
		thisenv = &envs[ENVX(sys_getenvid())];
  801081:	e8 f5 fb ff ff       	call   800c7b <sys_getenvid>
  801086:	25 ff 03 00 00       	and    $0x3ff,%eax
  80108b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801092:	c1 e0 07             	shl    $0x7,%eax
  801095:	29 d0                	sub    %edx,%eax
  801097:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80109c:	a3 04 50 80 00       	mov    %eax,0x805004
		return 0;
  8010a1:	e9 58 02 00 00       	jmp    8012fe <fork+0x2cb>
	set_pgfault_handler(pgfault);

	child_envid = sys_exofork();
	if (child_envid < 0)
		panic("sys_exofork: %e\n", child_envid);
	if (child_envid == 0) { // child
  8010a6:	bf 00 00 00 00       	mov    $0x0,%edi
  8010ab:	be 00 00 00 00       	mov    $0x0,%esi
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
  8010b0:	89 f0                	mov    %esi,%eax
  8010b2:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  8010b5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010bc:	a8 01                	test   $0x1,%al
  8010be:	0f 84 7a 01 00 00    	je     80123e <fork+0x20b>
			((uvpt[page_num] & PTE_P) == PTE_P)) {
  8010c4:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  8010cb:	a8 01                	test   $0x1,%al
  8010cd:	0f 84 6b 01 00 00    	je     80123e <fork+0x20b>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	envid_t this_envid = thisenv->env_id;
  8010d3:	a1 04 50 80 00       	mov    0x805004,%eax
  8010d8:	8b 40 48             	mov    0x48(%eax),%eax
  8010db:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	if (uvpt[pn] & PTE_SHARE) {
  8010de:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010e5:	f6 c4 04             	test   $0x4,%ah
  8010e8:	74 52                	je     80113c <fork+0x109>
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  8010ea:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010f1:	25 07 0e 00 00       	and    $0xe07,%eax
  8010f6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010fa:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801101:	89 44 24 08          	mov    %eax,0x8(%esp)
  801105:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801109:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80110c:	89 04 24             	mov    %eax,(%esp)
  80110f:	e8 f9 fb ff ff       	call   800d0d <sys_page_map>
  801114:	85 c0                	test   %eax,%eax
  801116:	0f 89 22 01 00 00    	jns    80123e <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  80111c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801120:	c7 44 24 08 ab 30 80 	movl   $0x8030ab,0x8(%esp)
  801127:	00 
  801128:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  80112f:	00 
  801130:	c7 04 24 8c 30 80 00 	movl   $0x80308c,(%esp)
  801137:	e8 e8 f0 ff ff       	call   800224 <_panic>
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
  80113c:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801143:	f6 c4 08             	test   $0x8,%ah
  801146:	75 0f                	jne    801157 <fork+0x124>
  801148:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80114f:	a8 02                	test   $0x2,%al
  801151:	0f 84 99 00 00 00    	je     8011f0 <fork+0x1bd>
		if (uvpt[pn] & PTE_U)
  801157:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80115e:	83 e0 04             	and    $0x4,%eax
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
  801161:	83 f8 01             	cmp    $0x1,%eax
  801164:	19 db                	sbb    %ebx,%ebx
  801166:	83 e3 fc             	and    $0xfffffffc,%ebx
  801169:	81 c3 05 08 00 00    	add    $0x805,%ebx
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
		if (uvpt[pn] & PTE_U)
			perm |= PTE_U;

		// Map page COW, U and P in child
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), perm)) < 0)
  80116f:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801173:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801177:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80117a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80117e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801182:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801185:	89 04 24             	mov    %eax,(%esp)
  801188:	e8 80 fb ff ff       	call   800d0d <sys_page_map>
  80118d:	85 c0                	test   %eax,%eax
  80118f:	79 20                	jns    8011b1 <fork+0x17e>
			panic("sys_page_map: %e\n", r);
  801191:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801195:	c7 44 24 08 ab 30 80 	movl   $0x8030ab,0x8(%esp)
  80119c:	00 
  80119d:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  8011a4:	00 
  8011a5:	c7 04 24 8c 30 80 00 	movl   $0x80308c,(%esp)
  8011ac:	e8 73 f0 ff ff       	call   800224 <_panic>

		// Map page COW, U and P in parent
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), this_envid, (void *) (pn*PGSIZE), perm)) < 0)
  8011b1:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8011b5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011c0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011c4:	89 04 24             	mov    %eax,(%esp)
  8011c7:	e8 41 fb ff ff       	call   800d0d <sys_page_map>
  8011cc:	85 c0                	test   %eax,%eax
  8011ce:	79 6e                	jns    80123e <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  8011d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011d4:	c7 44 24 08 ab 30 80 	movl   $0x8030ab,0x8(%esp)
  8011db:	00 
  8011dc:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  8011e3:	00 
  8011e4:	c7 04 24 8c 30 80 00 	movl   $0x80308c,(%esp)
  8011eb:	e8 34 f0 ff ff       	call   800224 <_panic>

	} else { // map pages that are present but not writable or COW with their original permissions
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  8011f0:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011f7:	25 07 0e 00 00       	and    $0xe07,%eax
  8011fc:	89 44 24 10          	mov    %eax,0x10(%esp)
  801200:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801204:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801207:	89 44 24 08          	mov    %eax,0x8(%esp)
  80120b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80120f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801212:	89 04 24             	mov    %eax,(%esp)
  801215:	e8 f3 fa ff ff       	call   800d0d <sys_page_map>
  80121a:	85 c0                	test   %eax,%eax
  80121c:	79 20                	jns    80123e <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  80121e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801222:	c7 44 24 08 ab 30 80 	movl   $0x8030ab,0x8(%esp)
  801229:	00 
  80122a:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  801231:	00 
  801232:	c7 04 24 8c 30 80 00 	movl   $0x80308c,(%esp)
  801239:	e8 e6 ef ff ff       	call   800224 <_panic>
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
  80123e:	46                   	inc    %esi
  80123f:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801245:	81 fe ff eb 0e 00    	cmp    $0xeebff,%esi
  80124b:	0f 85 5f fe ff ff    	jne    8010b0 <fork+0x7d>
	}

	// Allocate exception stack space for child. The child can't do this themselves
	// because the mechanism by which it would is to run the pgfault handler, which
	// needs to run on the exception stack (catch 22).
	if ((r = sys_page_alloc(child_envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801251:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801258:	00 
  801259:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801260:	ee 
  801261:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801264:	89 04 24             	mov    %eax,(%esp)
  801267:	e8 4d fa ff ff       	call   800cb9 <sys_page_alloc>
  80126c:	85 c0                	test   %eax,%eax
  80126e:	79 20                	jns    801290 <fork+0x25d>
		panic("sys_page_alloc: %e\n", r);
  801270:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801274:	c7 44 24 08 97 30 80 	movl   $0x803097,0x8(%esp)
  80127b:	00 
  80127c:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  801283:	00 
  801284:	c7 04 24 8c 30 80 00 	movl   $0x80308c,(%esp)
  80128b:	e8 94 ef ff ff       	call   800224 <_panic>

	// Set page fault handler for the child
	if ((r = sys_env_set_pgfault_upcall(child_envid, _pgfault_upcall)) < 0)
  801290:	c7 44 24 04 84 1a 80 	movl   $0x801a84,0x4(%esp)
  801297:	00 
  801298:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80129b:	89 04 24             	mov    %eax,(%esp)
  80129e:	e8 b6 fb ff ff       	call   800e59 <sys_env_set_pgfault_upcall>
  8012a3:	85 c0                	test   %eax,%eax
  8012a5:	79 20                	jns    8012c7 <fork+0x294>
		panic("sys_env_set_pgfault_upcall: %e\n", r);
  8012a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012ab:	c7 44 24 08 6c 30 80 	movl   $0x80306c,0x8(%esp)
  8012b2:	00 
  8012b3:	c7 44 24 04 a1 00 00 	movl   $0xa1,0x4(%esp)
  8012ba:	00 
  8012bb:	c7 04 24 8c 30 80 00 	movl   $0x80308c,(%esp)
  8012c2:	e8 5d ef ff ff       	call   800224 <_panic>

	// Mark child environment as runnable
	if ((r = sys_env_set_status(child_envid, ENV_RUNNABLE)) < 0)
  8012c7:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8012ce:	00 
  8012cf:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012d2:	89 04 24             	mov    %eax,(%esp)
  8012d5:	e8 d9 fa ff ff       	call   800db3 <sys_env_set_status>
  8012da:	85 c0                	test   %eax,%eax
  8012dc:	79 20                	jns    8012fe <fork+0x2cb>
		panic("sys_env_set_status: %e\n", r);
  8012de:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012e2:	c7 44 24 08 ce 30 80 	movl   $0x8030ce,0x8(%esp)
  8012e9:	00 
  8012ea:	c7 44 24 04 a5 00 00 	movl   $0xa5,0x4(%esp)
  8012f1:	00 
  8012f2:	c7 04 24 8c 30 80 00 	movl   $0x80308c,(%esp)
  8012f9:	e8 26 ef ff ff       	call   800224 <_panic>

	return child_envid;
}
  8012fe:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801301:	83 c4 3c             	add    $0x3c,%esp
  801304:	5b                   	pop    %ebx
  801305:	5e                   	pop    %esi
  801306:	5f                   	pop    %edi
  801307:	5d                   	pop    %ebp
  801308:	c3                   	ret    

00801309 <sfork>:

// Challenge!
int
sfork(void)
{
  801309:	55                   	push   %ebp
  80130a:	89 e5                	mov    %esp,%ebp
  80130c:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  80130f:	c7 44 24 08 e6 30 80 	movl   $0x8030e6,0x8(%esp)
  801316:	00 
  801317:	c7 44 24 04 ae 00 00 	movl   $0xae,0x4(%esp)
  80131e:	00 
  80131f:	c7 04 24 8c 30 80 00 	movl   $0x80308c,(%esp)
  801326:	e8 f9 ee ff ff       	call   800224 <_panic>
	...

0080132c <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  80132c:	55                   	push   %ebp
  80132d:	89 e5                	mov    %esp,%ebp
  80132f:	57                   	push   %edi
  801330:	56                   	push   %esi
  801331:	53                   	push   %ebx
  801332:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801338:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80133f:	00 
  801340:	8b 45 08             	mov    0x8(%ebp),%eax
  801343:	89 04 24             	mov    %eax,(%esp)
  801346:	e8 4d 0f 00 00       	call   802298 <open>
  80134b:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
  801351:	85 c0                	test   %eax,%eax
  801353:	0f 88 8c 05 00 00    	js     8018e5 <spawn+0x5b9>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801359:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  801360:	00 
  801361:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801367:	89 44 24 04          	mov    %eax,0x4(%esp)
  80136b:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801371:	89 04 24             	mov    %eax,(%esp)
  801374:	e8 d9 0a 00 00       	call   801e52 <readn>
  801379:	3d 00 02 00 00       	cmp    $0x200,%eax
  80137e:	75 0c                	jne    80138c <spawn+0x60>
	    || elf->e_magic != ELF_MAGIC) {
  801380:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801387:	45 4c 46 
  80138a:	74 3b                	je     8013c7 <spawn+0x9b>
		close(fd);
  80138c:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801392:	89 04 24             	mov    %eax,(%esp)
  801395:	e8 c4 08 00 00       	call   801c5e <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  80139a:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  8013a1:	46 
  8013a2:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  8013a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ac:	c7 04 24 fc 30 80 00 	movl   $0x8030fc,(%esp)
  8013b3:	e8 64 ef ff ff       	call   80031c <cprintf>
		return -E_NOT_EXEC;
  8013b8:	c7 85 88 fd ff ff f2 	movl   $0xfffffff2,-0x278(%ebp)
  8013bf:	ff ff ff 
  8013c2:	e9 2a 05 00 00       	jmp    8018f1 <spawn+0x5c5>
  8013c7:	ba 07 00 00 00       	mov    $0x7,%edx
  8013cc:	89 d0                	mov    %edx,%eax
  8013ce:	cd 30                	int    $0x30
  8013d0:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8013d6:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8013dc:	85 c0                	test   %eax,%eax
  8013de:	0f 88 0d 05 00 00    	js     8018f1 <spawn+0x5c5>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8013e4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8013e9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8013f0:	c1 e0 07             	shl    $0x7,%eax
  8013f3:	29 d0                	sub    %edx,%eax
  8013f5:	8d b0 00 00 c0 ee    	lea    -0x11400000(%eax),%esi
  8013fb:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801401:	b9 11 00 00 00       	mov    $0x11,%ecx
  801406:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801408:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  80140e:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801414:	be 00 00 00 00       	mov    $0x0,%esi
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801419:	bb 00 00 00 00       	mov    $0x0,%ebx
  80141e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801421:	eb 0d                	jmp    801430 <spawn+0x104>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801423:	89 04 24             	mov    %eax,(%esp)
  801426:	e8 69 f4 ff ff       	call   800894 <strlen>
  80142b:	8d 5c 18 01          	lea    0x1(%eax,%ebx,1),%ebx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80142f:	46                   	inc    %esi
  801430:	89 f2                	mov    %esi,%edx
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801432:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801439:	8b 04 b7             	mov    (%edi,%esi,4),%eax
  80143c:	85 c0                	test   %eax,%eax
  80143e:	75 e3                	jne    801423 <spawn+0xf7>
  801440:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
  801446:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  80144c:	bf 00 10 40 00       	mov    $0x401000,%edi
  801451:	29 df                	sub    %ebx,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801453:	89 f8                	mov    %edi,%eax
  801455:	83 e0 fc             	and    $0xfffffffc,%eax
  801458:	f7 d2                	not    %edx
  80145a:	8d 14 90             	lea    (%eax,%edx,4),%edx
  80145d:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801463:	89 d0                	mov    %edx,%eax
  801465:	83 e8 08             	sub    $0x8,%eax
  801468:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  80146d:	0f 86 8f 04 00 00    	jbe    801902 <spawn+0x5d6>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801473:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80147a:	00 
  80147b:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801482:	00 
  801483:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80148a:	e8 2a f8 ff ff       	call   800cb9 <sys_page_alloc>
  80148f:	85 c0                	test   %eax,%eax
  801491:	0f 88 70 04 00 00    	js     801907 <spawn+0x5db>
  801497:	bb 00 00 00 00       	mov    $0x0,%ebx
  80149c:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  8014a2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8014a5:	eb 2e                	jmp    8014d5 <spawn+0x1a9>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  8014a7:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8014ad:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  8014b3:	89 04 9a             	mov    %eax,(%edx,%ebx,4)
		strcpy(string_store, argv[i]);
  8014b6:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  8014b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014bd:	89 3c 24             	mov    %edi,(%esp)
  8014c0:	e8 02 f4 ff ff       	call   8008c7 <strcpy>
		string_store += strlen(argv[i]) + 1;
  8014c5:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  8014c8:	89 04 24             	mov    %eax,(%esp)
  8014cb:	e8 c4 f3 ff ff       	call   800894 <strlen>
  8014d0:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8014d4:	43                   	inc    %ebx
  8014d5:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  8014db:	7c ca                	jl     8014a7 <spawn+0x17b>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  8014dd:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  8014e3:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  8014e9:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  8014f0:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  8014f6:	74 24                	je     80151c <spawn+0x1f0>
  8014f8:	c7 44 24 0c 9c 31 80 	movl   $0x80319c,0xc(%esp)
  8014ff:	00 
  801500:	c7 44 24 08 16 31 80 	movl   $0x803116,0x8(%esp)
  801507:	00 
  801508:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
  80150f:	00 
  801510:	c7 04 24 2b 31 80 00 	movl   $0x80312b,(%esp)
  801517:	e8 08 ed ff ff       	call   800224 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  80151c:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801522:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801527:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  80152d:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  801530:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801536:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801539:	89 d0                	mov    %edx,%eax
  80153b:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801540:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801546:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80154d:	00 
  80154e:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  801555:	ee 
  801556:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  80155c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801560:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801567:	00 
  801568:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80156f:	e8 99 f7 ff ff       	call   800d0d <sys_page_map>
  801574:	89 c3                	mov    %eax,%ebx
  801576:	85 c0                	test   %eax,%eax
  801578:	78 1a                	js     801594 <spawn+0x268>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  80157a:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801581:	00 
  801582:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801589:	e8 d2 f7 ff ff       	call   800d60 <sys_page_unmap>
  80158e:	89 c3                	mov    %eax,%ebx
  801590:	85 c0                	test   %eax,%eax
  801592:	79 1f                	jns    8015b3 <spawn+0x287>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801594:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80159b:	00 
  80159c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015a3:	e8 b8 f7 ff ff       	call   800d60 <sys_page_unmap>
	return r;
  8015a8:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  8015ae:	e9 3e 03 00 00       	jmp    8018f1 <spawn+0x5c5>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8015b3:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  8015b9:	03 95 04 fe ff ff    	add    -0x1fc(%ebp),%edx
  8015bf:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8015c5:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  8015cc:	00 00 00 
  8015cf:	e9 bb 01 00 00       	jmp    80178f <spawn+0x463>
		if (ph->p_type != ELF_PROG_LOAD)
  8015d4:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8015da:	83 38 01             	cmpl   $0x1,(%eax)
  8015dd:	0f 85 9f 01 00 00    	jne    801782 <spawn+0x456>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  8015e3:	89 c2                	mov    %eax,%edx
  8015e5:	8b 40 18             	mov    0x18(%eax),%eax
  8015e8:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  8015eb:	83 f8 01             	cmp    $0x1,%eax
  8015ee:	19 c0                	sbb    %eax,%eax
  8015f0:	83 e0 fe             	and    $0xfffffffe,%eax
  8015f3:	83 c0 07             	add    $0x7,%eax
  8015f6:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  8015fc:	8b 52 04             	mov    0x4(%edx),%edx
  8015ff:	89 95 78 fd ff ff    	mov    %edx,-0x288(%ebp)
  801605:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  80160b:	8b 40 10             	mov    0x10(%eax),%eax
  80160e:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801614:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  80161a:	8b 52 14             	mov    0x14(%edx),%edx
  80161d:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  801623:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801629:	8b 78 08             	mov    0x8(%eax),%edi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  80162c:	89 f8                	mov    %edi,%eax
  80162e:	25 ff 0f 00 00       	and    $0xfff,%eax
  801633:	74 16                	je     80164b <spawn+0x31f>
		va -= i;
  801635:	29 c7                	sub    %eax,%edi
		memsz += i;
  801637:	01 c2                	add    %eax,%edx
  801639:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
		filesz += i;
  80163f:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  801645:	29 85 78 fd ff ff    	sub    %eax,-0x288(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  80164b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801650:	e9 1f 01 00 00       	jmp    801774 <spawn+0x448>
		if (i >= filesz) {
  801655:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  80165b:	77 2b                	ja     801688 <spawn+0x35c>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  80165d:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  801663:	89 54 24 08          	mov    %edx,0x8(%esp)
  801667:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80166b:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801671:	89 04 24             	mov    %eax,(%esp)
  801674:	e8 40 f6 ff ff       	call   800cb9 <sys_page_alloc>
  801679:	85 c0                	test   %eax,%eax
  80167b:	0f 89 e7 00 00 00    	jns    801768 <spawn+0x43c>
  801681:	89 c6                	mov    %eax,%esi
  801683:	e9 39 02 00 00       	jmp    8018c1 <spawn+0x595>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801688:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80168f:	00 
  801690:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801697:	00 
  801698:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80169f:	e8 15 f6 ff ff       	call   800cb9 <sys_page_alloc>
  8016a4:	85 c0                	test   %eax,%eax
  8016a6:	0f 88 0b 02 00 00    	js     8018b7 <spawn+0x58b>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  8016ac:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  8016b2:	01 f0                	add    %esi,%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8016b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016b8:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  8016be:	89 04 24             	mov    %eax,(%esp)
  8016c1:	e8 62 08 00 00       	call   801f28 <seek>
  8016c6:	85 c0                	test   %eax,%eax
  8016c8:	0f 88 ed 01 00 00    	js     8018bb <spawn+0x58f>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  8016ce:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8016d4:	29 f0                	sub    %esi,%eax
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8016d6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8016db:	76 05                	jbe    8016e2 <spawn+0x3b6>
  8016dd:	b8 00 10 00 00       	mov    $0x1000,%eax
  8016e2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016e6:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8016ed:	00 
  8016ee:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  8016f4:	89 04 24             	mov    %eax,(%esp)
  8016f7:	e8 56 07 00 00       	call   801e52 <readn>
  8016fc:	85 c0                	test   %eax,%eax
  8016fe:	0f 88 bb 01 00 00    	js     8018bf <spawn+0x593>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801704:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  80170a:	89 54 24 10          	mov    %edx,0x10(%esp)
  80170e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801712:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801718:	89 44 24 08          	mov    %eax,0x8(%esp)
  80171c:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801723:	00 
  801724:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80172b:	e8 dd f5 ff ff       	call   800d0d <sys_page_map>
  801730:	85 c0                	test   %eax,%eax
  801732:	79 20                	jns    801754 <spawn+0x428>
				panic("spawn: sys_page_map data: %e", r);
  801734:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801738:	c7 44 24 08 37 31 80 	movl   $0x803137,0x8(%esp)
  80173f:	00 
  801740:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
  801747:	00 
  801748:	c7 04 24 2b 31 80 00 	movl   $0x80312b,(%esp)
  80174f:	e8 d0 ea ff ff       	call   800224 <_panic>
			sys_page_unmap(0, UTEMP);
  801754:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80175b:	00 
  80175c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801763:	e8 f8 f5 ff ff       	call   800d60 <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801768:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80176e:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801774:	89 de                	mov    %ebx,%esi
  801776:	3b 9d 8c fd ff ff    	cmp    -0x274(%ebp),%ebx
  80177c:	0f 82 d3 fe ff ff    	jb     801655 <spawn+0x329>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801782:	ff 85 7c fd ff ff    	incl   -0x284(%ebp)
  801788:	83 85 80 fd ff ff 20 	addl   $0x20,-0x280(%ebp)
  80178f:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801796:	39 85 7c fd ff ff    	cmp    %eax,-0x284(%ebp)
  80179c:	0f 8c 32 fe ff ff    	jl     8015d4 <spawn+0x2a8>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  8017a2:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  8017a8:	89 04 24             	mov    %eax,(%esp)
  8017ab:	e8 ae 04 00 00       	call   801c5e <close>
{
	// LAB 5: Your code here.
	int r;
	uint32_t page_num;
	
	for (page_num = 0; page_num < PGNUM(UTOP); page_num++) {
  8017b0:	be 00 00 00 00       	mov    $0x0,%esi
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES)/NPDENTRIES;
  8017b5:	89 f0                	mov    %esi,%eax
  8017b7:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx]&PTE_P) && (uvpt[page_num]&PTE_P) && (uvpt[page_num]&PTE_SHARE)){
  8017ba:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8017c1:	a8 01                	test   $0x1,%al
  8017c3:	0f 84 82 00 00 00    	je     80184b <spawn+0x51f>
  8017c9:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8017d0:	a8 01                	test   $0x1,%al
  8017d2:	74 77                	je     80184b <spawn+0x51f>
  8017d4:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8017db:	f6 c4 04             	test   $0x4,%ah
  8017de:	74 6b                	je     80184b <spawn+0x51f>
			if ((r = sys_page_map(sys_getenvid(), (void*)(page_num*PGSIZE), child, (void*)(page_num*PGSIZE), uvpt[page_num]&PTE_SYSCALL)) < 0){
  8017e0:	8b 3c b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edi
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  8017e7:	89 f3                	mov    %esi,%ebx
  8017e9:	c1 e3 0c             	shl    $0xc,%ebx
	uint32_t page_num;
	
	for (page_num = 0; page_num < PGNUM(UTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES)/NPDENTRIES;
		if ((uvpd[pdx]&PTE_P) && (uvpt[page_num]&PTE_P) && (uvpt[page_num]&PTE_SHARE)){
			if ((r = sys_page_map(sys_getenvid(), (void*)(page_num*PGSIZE), child, (void*)(page_num*PGSIZE), uvpt[page_num]&PTE_SYSCALL)) < 0){
  8017ec:	e8 8a f4 ff ff       	call   800c7b <sys_getenvid>
  8017f1:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  8017f7:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8017fb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8017ff:	8b 95 88 fd ff ff    	mov    -0x278(%ebp),%edx
  801805:	89 54 24 08          	mov    %edx,0x8(%esp)
  801809:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80180d:	89 04 24             	mov    %eax,(%esp)
  801810:	e8 f8 f4 ff ff       	call   800d0d <sys_page_map>
  801815:	85 c0                	test   %eax,%eax
  801817:	79 32                	jns    80184b <spawn+0x51f>
  801819:	89 c3                	mov    %eax,%ebx
				cprintf("copy_shared_pages: sys_page_map failed, %e", r);
  80181b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80181f:	c7 04 24 c4 31 80 00 	movl   $0x8031c4,(%esp)
  801826:	e8 f1 ea ff ff       	call   80031c <cprintf>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  80182b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80182f:	c7 44 24 08 54 31 80 	movl   $0x803154,0x8(%esp)
  801836:	00 
  801837:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  80183e:	00 
  80183f:	c7 04 24 2b 31 80 00 	movl   $0x80312b,(%esp)
  801846:	e8 d9 e9 ff ff       	call   800224 <_panic>
{
	// LAB 5: Your code here.
	int r;
	uint32_t page_num;
	
	for (page_num = 0; page_num < PGNUM(UTOP); page_num++) {
  80184b:	46                   	inc    %esi
  80184c:	81 fe 00 ec 0e 00    	cmp    $0xeec00,%esi
  801852:	0f 85 5d ff ff ff    	jne    8017b5 <spawn+0x489>
  801858:	e9 b2 00 00 00       	jmp    80190f <spawn+0x5e3>
	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  80185d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801861:	c7 44 24 08 6a 31 80 	movl   $0x80316a,0x8(%esp)
  801868:	00 
  801869:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  801870:	00 
  801871:	c7 04 24 2b 31 80 00 	movl   $0x80312b,(%esp)
  801878:	e8 a7 e9 ff ff       	call   800224 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  80187d:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801884:	00 
  801885:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  80188b:	89 04 24             	mov    %eax,(%esp)
  80188e:	e8 20 f5 ff ff       	call   800db3 <sys_env_set_status>
  801893:	85 c0                	test   %eax,%eax
  801895:	79 5a                	jns    8018f1 <spawn+0x5c5>
		panic("sys_env_set_status: %e", r);
  801897:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80189b:	c7 44 24 08 84 31 80 	movl   $0x803184,0x8(%esp)
  8018a2:	00 
  8018a3:	c7 44 24 04 88 00 00 	movl   $0x88,0x4(%esp)
  8018aa:	00 
  8018ab:	c7 04 24 2b 31 80 00 	movl   $0x80312b,(%esp)
  8018b2:	e8 6d e9 ff ff       	call   800224 <_panic>
  8018b7:	89 c6                	mov    %eax,%esi
  8018b9:	eb 06                	jmp    8018c1 <spawn+0x595>
  8018bb:	89 c6                	mov    %eax,%esi
  8018bd:	eb 02                	jmp    8018c1 <spawn+0x595>
  8018bf:	89 c6                	mov    %eax,%esi

	return child;

error:
	sys_env_destroy(child);
  8018c1:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8018c7:	89 04 24             	mov    %eax,(%esp)
  8018ca:	e8 5a f3 ff ff       	call   800c29 <sys_env_destroy>
	close(fd);
  8018cf:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  8018d5:	89 04 24             	mov    %eax,(%esp)
  8018d8:	e8 81 03 00 00       	call   801c5e <close>
	return r;
  8018dd:	89 b5 88 fd ff ff    	mov    %esi,-0x278(%ebp)
  8018e3:	eb 0c                	jmp    8018f1 <spawn+0x5c5>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  8018e5:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  8018eb:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  8018f1:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8018f7:	81 c4 ac 02 00 00    	add    $0x2ac,%esp
  8018fd:	5b                   	pop    %ebx
  8018fe:	5e                   	pop    %esi
  8018ff:	5f                   	pop    %edi
  801900:	5d                   	pop    %ebp
  801901:	c3                   	ret    
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801902:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  801907:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  80190d:	eb e2                	jmp    8018f1 <spawn+0x5c5>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  80190f:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801915:	89 44 24 04          	mov    %eax,0x4(%esp)
  801919:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  80191f:	89 04 24             	mov    %eax,(%esp)
  801922:	e8 df f4 ff ff       	call   800e06 <sys_env_set_trapframe>
  801927:	85 c0                	test   %eax,%eax
  801929:	0f 89 4e ff ff ff    	jns    80187d <spawn+0x551>
  80192f:	e9 29 ff ff ff       	jmp    80185d <spawn+0x531>

00801934 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801934:	55                   	push   %ebp
  801935:	89 e5                	mov    %esp,%ebp
  801937:	57                   	push   %edi
  801938:	56                   	push   %esi
  801939:	53                   	push   %ebx
  80193a:	83 ec 1c             	sub    $0x1c,%esp
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
  80193d:	8d 45 10             	lea    0x10(%ebp),%eax
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801940:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801945:	eb 03                	jmp    80194a <spawnl+0x16>
		argc++;
  801947:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801948:	89 d0                	mov    %edx,%eax
  80194a:	8d 50 04             	lea    0x4(%eax),%edx
  80194d:	83 38 00             	cmpl   $0x0,(%eax)
  801950:	75 f5                	jne    801947 <spawnl+0x13>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801952:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  801959:	83 e0 f0             	and    $0xfffffff0,%eax
  80195c:	29 c4                	sub    %eax,%esp
  80195e:	8d 7c 24 17          	lea    0x17(%esp),%edi
  801962:	83 e7 f0             	and    $0xfffffff0,%edi
  801965:	89 fe                	mov    %edi,%esi
	argv[0] = arg0;
  801967:	8b 45 0c             	mov    0xc(%ebp),%eax
  80196a:	89 07                	mov    %eax,(%edi)
	argv[argc+1] = NULL;
  80196c:	c7 44 8f 04 00 00 00 	movl   $0x0,0x4(%edi,%ecx,4)
  801973:	00 

	va_start(vl, arg0);
  801974:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  801977:	b8 00 00 00 00       	mov    $0x0,%eax
  80197c:	eb 09                	jmp    801987 <spawnl+0x53>
		argv[i+1] = va_arg(vl, const char *);
  80197e:	40                   	inc    %eax
  80197f:	8b 1a                	mov    (%edx),%ebx
  801981:	89 1c 86             	mov    %ebx,(%esi,%eax,4)
  801984:	8d 52 04             	lea    0x4(%edx),%edx
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801987:	39 c8                	cmp    %ecx,%eax
  801989:	75 f3                	jne    80197e <spawnl+0x4a>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  80198b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80198f:	8b 45 08             	mov    0x8(%ebp),%eax
  801992:	89 04 24             	mov    %eax,(%esp)
  801995:	e8 92 f9 ff ff       	call   80132c <spawn>
}
  80199a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80199d:	5b                   	pop    %ebx
  80199e:	5e                   	pop    %esi
  80199f:	5f                   	pop    %edi
  8019a0:	5d                   	pop    %ebp
  8019a1:	c3                   	ret    
	...

008019a4 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8019a4:	55                   	push   %ebp
  8019a5:	89 e5                	mov    %esp,%ebp
  8019a7:	56                   	push   %esi
  8019a8:	53                   	push   %ebx
  8019a9:	83 ec 10             	sub    $0x10,%esp
  8019ac:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  8019af:	85 f6                	test   %esi,%esi
  8019b1:	75 24                	jne    8019d7 <wait+0x33>
  8019b3:	c7 44 24 0c ef 31 80 	movl   $0x8031ef,0xc(%esp)
  8019ba:	00 
  8019bb:	c7 44 24 08 16 31 80 	movl   $0x803116,0x8(%esp)
  8019c2:	00 
  8019c3:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  8019ca:	00 
  8019cb:	c7 04 24 fa 31 80 00 	movl   $0x8031fa,(%esp)
  8019d2:	e8 4d e8 ff ff       	call   800224 <_panic>
	e = &envs[ENVX(envid)];
  8019d7:	89 f3                	mov    %esi,%ebx
  8019d9:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  8019df:	8d 04 9d 00 00 00 00 	lea    0x0(,%ebx,4),%eax
  8019e6:	c1 e3 07             	shl    $0x7,%ebx
  8019e9:	29 c3                	sub    %eax,%ebx
  8019eb:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8019f1:	eb 05                	jmp    8019f8 <wait+0x54>
		sys_yield();
  8019f3:	e8 a2 f2 ff ff       	call   800c9a <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8019f8:	8b 43 48             	mov    0x48(%ebx),%eax
  8019fb:	39 f0                	cmp    %esi,%eax
  8019fd:	75 07                	jne    801a06 <wait+0x62>
  8019ff:	8b 43 54             	mov    0x54(%ebx),%eax
  801a02:	85 c0                	test   %eax,%eax
  801a04:	75 ed                	jne    8019f3 <wait+0x4f>
		sys_yield();
}
  801a06:	83 c4 10             	add    $0x10,%esp
  801a09:	5b                   	pop    %ebx
  801a0a:	5e                   	pop    %esi
  801a0b:	5d                   	pop    %ebp
  801a0c:	c3                   	ret    
  801a0d:	00 00                	add    %al,(%eax)
	...

00801a10 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801a10:	55                   	push   %ebp
  801a11:	89 e5                	mov    %esp,%ebp
  801a13:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801a16:	83 3d 08 50 80 00 00 	cmpl   $0x0,0x805008
  801a1d:	75 58                	jne    801a77 <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.	
		//panic("set_pgfault_handler not implemented");
		
		if (sys_page_alloc(thisenv->env_id,(void *) (UXSTACKTOP - PGSIZE),(PTE_W|PTE_U|PTE_P)) != 0){
  801a1f:	a1 04 50 80 00       	mov    0x805004,%eax
  801a24:	8b 40 48             	mov    0x48(%eax),%eax
  801a27:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801a2e:	00 
  801a2f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801a36:	ee 
  801a37:	89 04 24             	mov    %eax,(%esp)
  801a3a:	e8 7a f2 ff ff       	call   800cb9 <sys_page_alloc>
  801a3f:	85 c0                	test   %eax,%eax
  801a41:	74 1c                	je     801a5f <set_pgfault_handler+0x4f>
			panic("set_pg_fault_handler");
  801a43:	c7 44 24 08 05 32 80 	movl   $0x803205,0x8(%esp)
  801a4a:	00 
  801a4b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801a52:	00 
  801a53:	c7 04 24 1a 32 80 00 	movl   $0x80321a,(%esp)
  801a5a:	e8 c5 e7 ff ff       	call   800224 <_panic>
		}
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801a5f:	a1 04 50 80 00       	mov    0x805004,%eax
  801a64:	8b 40 48             	mov    0x48(%eax),%eax
  801a67:	c7 44 24 04 84 1a 80 	movl   $0x801a84,0x4(%esp)
  801a6e:	00 
  801a6f:	89 04 24             	mov    %eax,(%esp)
  801a72:	e8 e2 f3 ff ff       	call   800e59 <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801a77:	8b 45 08             	mov    0x8(%ebp),%eax
  801a7a:	a3 08 50 80 00       	mov    %eax,0x805008
}
  801a7f:	c9                   	leave  
  801a80:	c3                   	ret    
  801a81:	00 00                	add    %al,(%eax)
	...

00801a84 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801a84:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801a85:	a1 08 50 80 00       	mov    0x805008,%eax
	call *%eax
  801a8a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801a8c:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// Save trap-time eip in eax
	movl 0x28(%esp), %eax
  801a8f:	8b 44 24 28          	mov    0x28(%esp),%eax

	// Save our current stack
	movl %esp, %ebp
  801a93:	89 e5                	mov    %esp,%ebp

	// Switch to trap-time stack
	movl 0x30(%esp), %esp
  801a95:	8b 64 24 30          	mov    0x30(%esp),%esp

	// Push trap-time eip to the trap-time stack
	pushl %eax
  801a99:	50                   	push   %eax

	// We now have to update the trap-time esp with its new value
	movl %esp, 0x30(%ebp)
  801a9a:	89 65 30             	mov    %esp,0x30(%ebp)

	// Go back to our exception stack
	movl %ebp, %esp
  801a9d:	89 ec                	mov    %ebp,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// Pop fault_va and err, both can be ignored
	popl %eax
  801a9f:	58                   	pop    %eax
	popl %eax
  801aa0:	58                   	pop    %eax

	// Pop all registers back
	popal
  801aa1:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// Skip %eip
	addl $0x4, %esp
  801aa2:	83 c4 04             	add    $0x4,%esp

	// Pop eflags back
	popfl
  801aa5:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	
	popl %esp
  801aa6:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  801aa7:	c3                   	ret    

00801aa8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801aa8:	55                   	push   %ebp
  801aa9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801aab:	8b 45 08             	mov    0x8(%ebp),%eax
  801aae:	05 00 00 00 30       	add    $0x30000000,%eax
  801ab3:	c1 e8 0c             	shr    $0xc,%eax
}
  801ab6:	5d                   	pop    %ebp
  801ab7:	c3                   	ret    

00801ab8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801ab8:	55                   	push   %ebp
  801ab9:	89 e5                	mov    %esp,%ebp
  801abb:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801abe:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac1:	89 04 24             	mov    %eax,(%esp)
  801ac4:	e8 df ff ff ff       	call   801aa8 <fd2num>
  801ac9:	05 20 00 0d 00       	add    $0xd0020,%eax
  801ace:	c1 e0 0c             	shl    $0xc,%eax
}
  801ad1:	c9                   	leave  
  801ad2:	c3                   	ret    

00801ad3 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801ad3:	55                   	push   %ebp
  801ad4:	89 e5                	mov    %esp,%ebp
  801ad6:	53                   	push   %ebx
  801ad7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801ada:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801adf:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801ae1:	89 c2                	mov    %eax,%edx
  801ae3:	c1 ea 16             	shr    $0x16,%edx
  801ae6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801aed:	f6 c2 01             	test   $0x1,%dl
  801af0:	74 11                	je     801b03 <fd_alloc+0x30>
  801af2:	89 c2                	mov    %eax,%edx
  801af4:	c1 ea 0c             	shr    $0xc,%edx
  801af7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801afe:	f6 c2 01             	test   $0x1,%dl
  801b01:	75 09                	jne    801b0c <fd_alloc+0x39>
			*fd_store = fd;
  801b03:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801b05:	b8 00 00 00 00       	mov    $0x0,%eax
  801b0a:	eb 17                	jmp    801b23 <fd_alloc+0x50>
  801b0c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801b11:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801b16:	75 c7                	jne    801adf <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801b18:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801b1e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801b23:	5b                   	pop    %ebx
  801b24:	5d                   	pop    %ebp
  801b25:	c3                   	ret    

00801b26 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801b26:	55                   	push   %ebp
  801b27:	89 e5                	mov    %esp,%ebp
  801b29:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801b2c:	83 f8 1f             	cmp    $0x1f,%eax
  801b2f:	77 36                	ja     801b67 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801b31:	05 00 00 0d 00       	add    $0xd0000,%eax
  801b36:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801b39:	89 c2                	mov    %eax,%edx
  801b3b:	c1 ea 16             	shr    $0x16,%edx
  801b3e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801b45:	f6 c2 01             	test   $0x1,%dl
  801b48:	74 24                	je     801b6e <fd_lookup+0x48>
  801b4a:	89 c2                	mov    %eax,%edx
  801b4c:	c1 ea 0c             	shr    $0xc,%edx
  801b4f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801b56:	f6 c2 01             	test   $0x1,%dl
  801b59:	74 1a                	je     801b75 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801b5b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b5e:	89 02                	mov    %eax,(%edx)
	return 0;
  801b60:	b8 00 00 00 00       	mov    $0x0,%eax
  801b65:	eb 13                	jmp    801b7a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801b67:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b6c:	eb 0c                	jmp    801b7a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801b6e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b73:	eb 05                	jmp    801b7a <fd_lookup+0x54>
  801b75:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801b7a:	5d                   	pop    %ebp
  801b7b:	c3                   	ret    

00801b7c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801b7c:	55                   	push   %ebp
  801b7d:	89 e5                	mov    %esp,%ebp
  801b7f:	53                   	push   %ebx
  801b80:	83 ec 14             	sub    $0x14,%esp
  801b83:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b86:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801b89:	ba 00 00 00 00       	mov    $0x0,%edx
  801b8e:	eb 0e                	jmp    801b9e <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801b90:	39 08                	cmp    %ecx,(%eax)
  801b92:	75 09                	jne    801b9d <dev_lookup+0x21>
			*dev = devtab[i];
  801b94:	89 03                	mov    %eax,(%ebx)
			return 0;
  801b96:	b8 00 00 00 00       	mov    $0x0,%eax
  801b9b:	eb 33                	jmp    801bd0 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801b9d:	42                   	inc    %edx
  801b9e:	8b 04 95 a4 32 80 00 	mov    0x8032a4(,%edx,4),%eax
  801ba5:	85 c0                	test   %eax,%eax
  801ba7:	75 e7                	jne    801b90 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801ba9:	a1 04 50 80 00       	mov    0x805004,%eax
  801bae:	8b 40 48             	mov    0x48(%eax),%eax
  801bb1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801bb5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bb9:	c7 04 24 28 32 80 00 	movl   $0x803228,(%esp)
  801bc0:	e8 57 e7 ff ff       	call   80031c <cprintf>
	*dev = 0;
  801bc5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801bcb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801bd0:	83 c4 14             	add    $0x14,%esp
  801bd3:	5b                   	pop    %ebx
  801bd4:	5d                   	pop    %ebp
  801bd5:	c3                   	ret    

00801bd6 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801bd6:	55                   	push   %ebp
  801bd7:	89 e5                	mov    %esp,%ebp
  801bd9:	56                   	push   %esi
  801bda:	53                   	push   %ebx
  801bdb:	83 ec 30             	sub    $0x30,%esp
  801bde:	8b 75 08             	mov    0x8(%ebp),%esi
  801be1:	8a 45 0c             	mov    0xc(%ebp),%al
  801be4:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801be7:	89 34 24             	mov    %esi,(%esp)
  801bea:	e8 b9 fe ff ff       	call   801aa8 <fd2num>
  801bef:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801bf2:	89 54 24 04          	mov    %edx,0x4(%esp)
  801bf6:	89 04 24             	mov    %eax,(%esp)
  801bf9:	e8 28 ff ff ff       	call   801b26 <fd_lookup>
  801bfe:	89 c3                	mov    %eax,%ebx
  801c00:	85 c0                	test   %eax,%eax
  801c02:	78 05                	js     801c09 <fd_close+0x33>
	    || fd != fd2)
  801c04:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801c07:	74 0d                	je     801c16 <fd_close+0x40>
		return (must_exist ? r : 0);
  801c09:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801c0d:	75 46                	jne    801c55 <fd_close+0x7f>
  801c0f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c14:	eb 3f                	jmp    801c55 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801c16:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c19:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c1d:	8b 06                	mov    (%esi),%eax
  801c1f:	89 04 24             	mov    %eax,(%esp)
  801c22:	e8 55 ff ff ff       	call   801b7c <dev_lookup>
  801c27:	89 c3                	mov    %eax,%ebx
  801c29:	85 c0                	test   %eax,%eax
  801c2b:	78 18                	js     801c45 <fd_close+0x6f>
		if (dev->dev_close)
  801c2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c30:	8b 40 10             	mov    0x10(%eax),%eax
  801c33:	85 c0                	test   %eax,%eax
  801c35:	74 09                	je     801c40 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801c37:	89 34 24             	mov    %esi,(%esp)
  801c3a:	ff d0                	call   *%eax
  801c3c:	89 c3                	mov    %eax,%ebx
  801c3e:	eb 05                	jmp    801c45 <fd_close+0x6f>
		else
			r = 0;
  801c40:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801c45:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c49:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c50:	e8 0b f1 ff ff       	call   800d60 <sys_page_unmap>
	return r;
}
  801c55:	89 d8                	mov    %ebx,%eax
  801c57:	83 c4 30             	add    $0x30,%esp
  801c5a:	5b                   	pop    %ebx
  801c5b:	5e                   	pop    %esi
  801c5c:	5d                   	pop    %ebp
  801c5d:	c3                   	ret    

00801c5e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801c5e:	55                   	push   %ebp
  801c5f:	89 e5                	mov    %esp,%ebp
  801c61:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c64:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c67:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c6b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c6e:	89 04 24             	mov    %eax,(%esp)
  801c71:	e8 b0 fe ff ff       	call   801b26 <fd_lookup>
  801c76:	85 c0                	test   %eax,%eax
  801c78:	78 13                	js     801c8d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801c7a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801c81:	00 
  801c82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c85:	89 04 24             	mov    %eax,(%esp)
  801c88:	e8 49 ff ff ff       	call   801bd6 <fd_close>
}
  801c8d:	c9                   	leave  
  801c8e:	c3                   	ret    

00801c8f <close_all>:

void
close_all(void)
{
  801c8f:	55                   	push   %ebp
  801c90:	89 e5                	mov    %esp,%ebp
  801c92:	53                   	push   %ebx
  801c93:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801c96:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801c9b:	89 1c 24             	mov    %ebx,(%esp)
  801c9e:	e8 bb ff ff ff       	call   801c5e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801ca3:	43                   	inc    %ebx
  801ca4:	83 fb 20             	cmp    $0x20,%ebx
  801ca7:	75 f2                	jne    801c9b <close_all+0xc>
		close(i);
}
  801ca9:	83 c4 14             	add    $0x14,%esp
  801cac:	5b                   	pop    %ebx
  801cad:	5d                   	pop    %ebp
  801cae:	c3                   	ret    

00801caf <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801caf:	55                   	push   %ebp
  801cb0:	89 e5                	mov    %esp,%ebp
  801cb2:	57                   	push   %edi
  801cb3:	56                   	push   %esi
  801cb4:	53                   	push   %ebx
  801cb5:	83 ec 4c             	sub    $0x4c,%esp
  801cb8:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801cbb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801cbe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cc2:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc5:	89 04 24             	mov    %eax,(%esp)
  801cc8:	e8 59 fe ff ff       	call   801b26 <fd_lookup>
  801ccd:	89 c3                	mov    %eax,%ebx
  801ccf:	85 c0                	test   %eax,%eax
  801cd1:	0f 88 e1 00 00 00    	js     801db8 <dup+0x109>
		return r;
	close(newfdnum);
  801cd7:	89 3c 24             	mov    %edi,(%esp)
  801cda:	e8 7f ff ff ff       	call   801c5e <close>

	newfd = INDEX2FD(newfdnum);
  801cdf:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801ce5:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801ce8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ceb:	89 04 24             	mov    %eax,(%esp)
  801cee:	e8 c5 fd ff ff       	call   801ab8 <fd2data>
  801cf3:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801cf5:	89 34 24             	mov    %esi,(%esp)
  801cf8:	e8 bb fd ff ff       	call   801ab8 <fd2data>
  801cfd:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801d00:	89 d8                	mov    %ebx,%eax
  801d02:	c1 e8 16             	shr    $0x16,%eax
  801d05:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801d0c:	a8 01                	test   $0x1,%al
  801d0e:	74 46                	je     801d56 <dup+0xa7>
  801d10:	89 d8                	mov    %ebx,%eax
  801d12:	c1 e8 0c             	shr    $0xc,%eax
  801d15:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801d1c:	f6 c2 01             	test   $0x1,%dl
  801d1f:	74 35                	je     801d56 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801d21:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801d28:	25 07 0e 00 00       	and    $0xe07,%eax
  801d2d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801d31:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801d34:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d38:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d3f:	00 
  801d40:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d44:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d4b:	e8 bd ef ff ff       	call   800d0d <sys_page_map>
  801d50:	89 c3                	mov    %eax,%ebx
  801d52:	85 c0                	test   %eax,%eax
  801d54:	78 3b                	js     801d91 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801d56:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d59:	89 c2                	mov    %eax,%edx
  801d5b:	c1 ea 0c             	shr    $0xc,%edx
  801d5e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801d65:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801d6b:	89 54 24 10          	mov    %edx,0x10(%esp)
  801d6f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801d73:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d7a:	00 
  801d7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d7f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d86:	e8 82 ef ff ff       	call   800d0d <sys_page_map>
  801d8b:	89 c3                	mov    %eax,%ebx
  801d8d:	85 c0                	test   %eax,%eax
  801d8f:	79 25                	jns    801db6 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801d91:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d95:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d9c:	e8 bf ef ff ff       	call   800d60 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801da1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801da4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801da8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801daf:	e8 ac ef ff ff       	call   800d60 <sys_page_unmap>
	return r;
  801db4:	eb 02                	jmp    801db8 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801db6:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801db8:	89 d8                	mov    %ebx,%eax
  801dba:	83 c4 4c             	add    $0x4c,%esp
  801dbd:	5b                   	pop    %ebx
  801dbe:	5e                   	pop    %esi
  801dbf:	5f                   	pop    %edi
  801dc0:	5d                   	pop    %ebp
  801dc1:	c3                   	ret    

00801dc2 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801dc2:	55                   	push   %ebp
  801dc3:	89 e5                	mov    %esp,%ebp
  801dc5:	53                   	push   %ebx
  801dc6:	83 ec 24             	sub    $0x24,%esp
  801dc9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801dcc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801dcf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dd3:	89 1c 24             	mov    %ebx,(%esp)
  801dd6:	e8 4b fd ff ff       	call   801b26 <fd_lookup>
  801ddb:	85 c0                	test   %eax,%eax
  801ddd:	78 6d                	js     801e4c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ddf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801de2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801de6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801de9:	8b 00                	mov    (%eax),%eax
  801deb:	89 04 24             	mov    %eax,(%esp)
  801dee:	e8 89 fd ff ff       	call   801b7c <dev_lookup>
  801df3:	85 c0                	test   %eax,%eax
  801df5:	78 55                	js     801e4c <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801df7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dfa:	8b 50 08             	mov    0x8(%eax),%edx
  801dfd:	83 e2 03             	and    $0x3,%edx
  801e00:	83 fa 01             	cmp    $0x1,%edx
  801e03:	75 23                	jne    801e28 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801e05:	a1 04 50 80 00       	mov    0x805004,%eax
  801e0a:	8b 40 48             	mov    0x48(%eax),%eax
  801e0d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e11:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e15:	c7 04 24 69 32 80 00 	movl   $0x803269,(%esp)
  801e1c:	e8 fb e4 ff ff       	call   80031c <cprintf>
		return -E_INVAL;
  801e21:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801e26:	eb 24                	jmp    801e4c <read+0x8a>
	}
	if (!dev->dev_read)
  801e28:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e2b:	8b 52 08             	mov    0x8(%edx),%edx
  801e2e:	85 d2                	test   %edx,%edx
  801e30:	74 15                	je     801e47 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801e32:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801e35:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e3c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801e40:	89 04 24             	mov    %eax,(%esp)
  801e43:	ff d2                	call   *%edx
  801e45:	eb 05                	jmp    801e4c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801e47:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801e4c:	83 c4 24             	add    $0x24,%esp
  801e4f:	5b                   	pop    %ebx
  801e50:	5d                   	pop    %ebp
  801e51:	c3                   	ret    

00801e52 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801e52:	55                   	push   %ebp
  801e53:	89 e5                	mov    %esp,%ebp
  801e55:	57                   	push   %edi
  801e56:	56                   	push   %esi
  801e57:	53                   	push   %ebx
  801e58:	83 ec 1c             	sub    $0x1c,%esp
  801e5b:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e5e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801e61:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e66:	eb 23                	jmp    801e8b <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801e68:	89 f0                	mov    %esi,%eax
  801e6a:	29 d8                	sub    %ebx,%eax
  801e6c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e70:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e73:	01 d8                	add    %ebx,%eax
  801e75:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e79:	89 3c 24             	mov    %edi,(%esp)
  801e7c:	e8 41 ff ff ff       	call   801dc2 <read>
		if (m < 0)
  801e81:	85 c0                	test   %eax,%eax
  801e83:	78 10                	js     801e95 <readn+0x43>
			return m;
		if (m == 0)
  801e85:	85 c0                	test   %eax,%eax
  801e87:	74 0a                	je     801e93 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801e89:	01 c3                	add    %eax,%ebx
  801e8b:	39 f3                	cmp    %esi,%ebx
  801e8d:	72 d9                	jb     801e68 <readn+0x16>
  801e8f:	89 d8                	mov    %ebx,%eax
  801e91:	eb 02                	jmp    801e95 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801e93:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801e95:	83 c4 1c             	add    $0x1c,%esp
  801e98:	5b                   	pop    %ebx
  801e99:	5e                   	pop    %esi
  801e9a:	5f                   	pop    %edi
  801e9b:	5d                   	pop    %ebp
  801e9c:	c3                   	ret    

00801e9d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801e9d:	55                   	push   %ebp
  801e9e:	89 e5                	mov    %esp,%ebp
  801ea0:	53                   	push   %ebx
  801ea1:	83 ec 24             	sub    $0x24,%esp
  801ea4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801ea7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801eaa:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eae:	89 1c 24             	mov    %ebx,(%esp)
  801eb1:	e8 70 fc ff ff       	call   801b26 <fd_lookup>
  801eb6:	85 c0                	test   %eax,%eax
  801eb8:	78 68                	js     801f22 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801eba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ebd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ec1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ec4:	8b 00                	mov    (%eax),%eax
  801ec6:	89 04 24             	mov    %eax,(%esp)
  801ec9:	e8 ae fc ff ff       	call   801b7c <dev_lookup>
  801ece:	85 c0                	test   %eax,%eax
  801ed0:	78 50                	js     801f22 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801ed2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ed5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801ed9:	75 23                	jne    801efe <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801edb:	a1 04 50 80 00       	mov    0x805004,%eax
  801ee0:	8b 40 48             	mov    0x48(%eax),%eax
  801ee3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ee7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eeb:	c7 04 24 85 32 80 00 	movl   $0x803285,(%esp)
  801ef2:	e8 25 e4 ff ff       	call   80031c <cprintf>
		return -E_INVAL;
  801ef7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801efc:	eb 24                	jmp    801f22 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801efe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f01:	8b 52 0c             	mov    0xc(%edx),%edx
  801f04:	85 d2                	test   %edx,%edx
  801f06:	74 15                	je     801f1d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801f08:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801f0b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f12:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801f16:	89 04 24             	mov    %eax,(%esp)
  801f19:	ff d2                	call   *%edx
  801f1b:	eb 05                	jmp    801f22 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801f1d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801f22:	83 c4 24             	add    $0x24,%esp
  801f25:	5b                   	pop    %ebx
  801f26:	5d                   	pop    %ebp
  801f27:	c3                   	ret    

00801f28 <seek>:

int
seek(int fdnum, off_t offset)
{
  801f28:	55                   	push   %ebp
  801f29:	89 e5                	mov    %esp,%ebp
  801f2b:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f2e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801f31:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f35:	8b 45 08             	mov    0x8(%ebp),%eax
  801f38:	89 04 24             	mov    %eax,(%esp)
  801f3b:	e8 e6 fb ff ff       	call   801b26 <fd_lookup>
  801f40:	85 c0                	test   %eax,%eax
  801f42:	78 0e                	js     801f52 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801f44:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801f47:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f4a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801f4d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f52:	c9                   	leave  
  801f53:	c3                   	ret    

00801f54 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801f54:	55                   	push   %ebp
  801f55:	89 e5                	mov    %esp,%ebp
  801f57:	53                   	push   %ebx
  801f58:	83 ec 24             	sub    $0x24,%esp
  801f5b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801f5e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f61:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f65:	89 1c 24             	mov    %ebx,(%esp)
  801f68:	e8 b9 fb ff ff       	call   801b26 <fd_lookup>
  801f6d:	85 c0                	test   %eax,%eax
  801f6f:	78 61                	js     801fd2 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f71:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f74:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f78:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f7b:	8b 00                	mov    (%eax),%eax
  801f7d:	89 04 24             	mov    %eax,(%esp)
  801f80:	e8 f7 fb ff ff       	call   801b7c <dev_lookup>
  801f85:	85 c0                	test   %eax,%eax
  801f87:	78 49                	js     801fd2 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801f89:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f8c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801f90:	75 23                	jne    801fb5 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801f92:	a1 04 50 80 00       	mov    0x805004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801f97:	8b 40 48             	mov    0x48(%eax),%eax
  801f9a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f9e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fa2:	c7 04 24 48 32 80 00 	movl   $0x803248,(%esp)
  801fa9:	e8 6e e3 ff ff       	call   80031c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801fae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801fb3:	eb 1d                	jmp    801fd2 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801fb5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801fb8:	8b 52 18             	mov    0x18(%edx),%edx
  801fbb:	85 d2                	test   %edx,%edx
  801fbd:	74 0e                	je     801fcd <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801fbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fc2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801fc6:	89 04 24             	mov    %eax,(%esp)
  801fc9:	ff d2                	call   *%edx
  801fcb:	eb 05                	jmp    801fd2 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801fcd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801fd2:	83 c4 24             	add    $0x24,%esp
  801fd5:	5b                   	pop    %ebx
  801fd6:	5d                   	pop    %ebp
  801fd7:	c3                   	ret    

00801fd8 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801fd8:	55                   	push   %ebp
  801fd9:	89 e5                	mov    %esp,%ebp
  801fdb:	53                   	push   %ebx
  801fdc:	83 ec 24             	sub    $0x24,%esp
  801fdf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801fe2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801fe5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fe9:	8b 45 08             	mov    0x8(%ebp),%eax
  801fec:	89 04 24             	mov    %eax,(%esp)
  801fef:	e8 32 fb ff ff       	call   801b26 <fd_lookup>
  801ff4:	85 c0                	test   %eax,%eax
  801ff6:	78 52                	js     80204a <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ff8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ffb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802002:	8b 00                	mov    (%eax),%eax
  802004:	89 04 24             	mov    %eax,(%esp)
  802007:	e8 70 fb ff ff       	call   801b7c <dev_lookup>
  80200c:	85 c0                	test   %eax,%eax
  80200e:	78 3a                	js     80204a <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  802010:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802013:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802017:	74 2c                	je     802045 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802019:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80201c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802023:	00 00 00 
	stat->st_isdir = 0;
  802026:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80202d:	00 00 00 
	stat->st_dev = dev;
  802030:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802036:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80203a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80203d:	89 14 24             	mov    %edx,(%esp)
  802040:	ff 50 14             	call   *0x14(%eax)
  802043:	eb 05                	jmp    80204a <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  802045:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80204a:	83 c4 24             	add    $0x24,%esp
  80204d:	5b                   	pop    %ebx
  80204e:	5d                   	pop    %ebp
  80204f:	c3                   	ret    

00802050 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802050:	55                   	push   %ebp
  802051:	89 e5                	mov    %esp,%ebp
  802053:	56                   	push   %esi
  802054:	53                   	push   %ebx
  802055:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802058:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80205f:	00 
  802060:	8b 45 08             	mov    0x8(%ebp),%eax
  802063:	89 04 24             	mov    %eax,(%esp)
  802066:	e8 2d 02 00 00       	call   802298 <open>
  80206b:	89 c3                	mov    %eax,%ebx
  80206d:	85 c0                	test   %eax,%eax
  80206f:	78 1b                	js     80208c <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  802071:	8b 45 0c             	mov    0xc(%ebp),%eax
  802074:	89 44 24 04          	mov    %eax,0x4(%esp)
  802078:	89 1c 24             	mov    %ebx,(%esp)
  80207b:	e8 58 ff ff ff       	call   801fd8 <fstat>
  802080:	89 c6                	mov    %eax,%esi
	close(fd);
  802082:	89 1c 24             	mov    %ebx,(%esp)
  802085:	e8 d4 fb ff ff       	call   801c5e <close>
	return r;
  80208a:	89 f3                	mov    %esi,%ebx
}
  80208c:	89 d8                	mov    %ebx,%eax
  80208e:	83 c4 10             	add    $0x10,%esp
  802091:	5b                   	pop    %ebx
  802092:	5e                   	pop    %esi
  802093:	5d                   	pop    %ebp
  802094:	c3                   	ret    
  802095:	00 00                	add    %al,(%eax)
	...

00802098 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802098:	55                   	push   %ebp
  802099:	89 e5                	mov    %esp,%ebp
  80209b:	56                   	push   %esi
  80209c:	53                   	push   %ebx
  80209d:	83 ec 10             	sub    $0x10,%esp
  8020a0:	89 c3                	mov    %eax,%ebx
  8020a2:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8020a4:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8020ab:	75 11                	jne    8020be <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8020ad:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8020b4:	e8 6e 08 00 00       	call   802927 <ipc_find_env>
  8020b9:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8020be:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8020c5:	00 
  8020c6:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  8020cd:	00 
  8020ce:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8020d2:	a1 00 50 80 00       	mov    0x805000,%eax
  8020d7:	89 04 24             	mov    %eax,(%esp)
  8020da:	e8 da 07 00 00       	call   8028b9 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8020df:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8020e6:	00 
  8020e7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020f2:	e8 59 07 00 00       	call   802850 <ipc_recv>
}
  8020f7:	83 c4 10             	add    $0x10,%esp
  8020fa:	5b                   	pop    %ebx
  8020fb:	5e                   	pop    %esi
  8020fc:	5d                   	pop    %ebp
  8020fd:	c3                   	ret    

008020fe <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8020fe:	55                   	push   %ebp
  8020ff:	89 e5                	mov    %esp,%ebp
  802101:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802104:	8b 45 08             	mov    0x8(%ebp),%eax
  802107:	8b 40 0c             	mov    0xc(%eax),%eax
  80210a:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  80210f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802112:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802117:	ba 00 00 00 00       	mov    $0x0,%edx
  80211c:	b8 02 00 00 00       	mov    $0x2,%eax
  802121:	e8 72 ff ff ff       	call   802098 <fsipc>
}
  802126:	c9                   	leave  
  802127:	c3                   	ret    

00802128 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802128:	55                   	push   %ebp
  802129:	89 e5                	mov    %esp,%ebp
  80212b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80212e:	8b 45 08             	mov    0x8(%ebp),%eax
  802131:	8b 40 0c             	mov    0xc(%eax),%eax
  802134:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  802139:	ba 00 00 00 00       	mov    $0x0,%edx
  80213e:	b8 06 00 00 00       	mov    $0x6,%eax
  802143:	e8 50 ff ff ff       	call   802098 <fsipc>
}
  802148:	c9                   	leave  
  802149:	c3                   	ret    

0080214a <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80214a:	55                   	push   %ebp
  80214b:	89 e5                	mov    %esp,%ebp
  80214d:	53                   	push   %ebx
  80214e:	83 ec 14             	sub    $0x14,%esp
  802151:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802154:	8b 45 08             	mov    0x8(%ebp),%eax
  802157:	8b 40 0c             	mov    0xc(%eax),%eax
  80215a:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80215f:	ba 00 00 00 00       	mov    $0x0,%edx
  802164:	b8 05 00 00 00       	mov    $0x5,%eax
  802169:	e8 2a ff ff ff       	call   802098 <fsipc>
  80216e:	85 c0                	test   %eax,%eax
  802170:	78 2b                	js     80219d <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802172:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  802179:	00 
  80217a:	89 1c 24             	mov    %ebx,(%esp)
  80217d:	e8 45 e7 ff ff       	call   8008c7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802182:	a1 80 60 80 00       	mov    0x806080,%eax
  802187:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80218d:	a1 84 60 80 00       	mov    0x806084,%eax
  802192:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802198:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80219d:	83 c4 14             	add    $0x14,%esp
  8021a0:	5b                   	pop    %ebx
  8021a1:	5d                   	pop    %ebp
  8021a2:	c3                   	ret    

008021a3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8021a3:	55                   	push   %ebp
  8021a4:	89 e5                	mov    %esp,%ebp
  8021a6:	83 ec 18             	sub    $0x18,%esp
  8021a9:	8b 55 10             	mov    0x10(%ebp),%edx
  8021ac:	89 d0                	mov    %edx,%eax
  8021ae:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  8021b4:	76 05                	jbe    8021bb <devfile_write+0x18>
  8021b6:	b8 00 10 00 00       	mov    $0x1000,%eax
	//panic("devfile_write not implemented");
	int r;
	//uint32_t maxsize = BLKSIZE - sizeof(int) - sizeof(size_t);	
	if (n > BLKSIZE)
		n = BLKSIZE;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8021bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8021be:	8b 52 0c             	mov    0xc(%edx),%edx
  8021c1:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  8021c7:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8021cc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021d7:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  8021de:	e8 5d e8 ff ff       	call   800a40 <memmove>
	 
	return fsipc(FSREQ_WRITE, NULL);
  8021e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8021e8:	b8 04 00 00 00       	mov    $0x4,%eax
  8021ed:	e8 a6 fe ff ff       	call   802098 <fsipc>
}
  8021f2:	c9                   	leave  
  8021f3:	c3                   	ret    

008021f4 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8021f4:	55                   	push   %ebp
  8021f5:	89 e5                	mov    %esp,%ebp
  8021f7:	56                   	push   %esi
  8021f8:	53                   	push   %ebx
  8021f9:	83 ec 10             	sub    $0x10,%esp
  8021fc:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8021ff:	8b 45 08             	mov    0x8(%ebp),%eax
  802202:	8b 40 0c             	mov    0xc(%eax),%eax
  802205:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  80220a:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802210:	ba 00 00 00 00       	mov    $0x0,%edx
  802215:	b8 03 00 00 00       	mov    $0x3,%eax
  80221a:	e8 79 fe ff ff       	call   802098 <fsipc>
  80221f:	89 c3                	mov    %eax,%ebx
  802221:	85 c0                	test   %eax,%eax
  802223:	78 6a                	js     80228f <devfile_read+0x9b>
		return r;
	assert(r <= n);
  802225:	39 c6                	cmp    %eax,%esi
  802227:	73 24                	jae    80224d <devfile_read+0x59>
  802229:	c7 44 24 0c b4 32 80 	movl   $0x8032b4,0xc(%esp)
  802230:	00 
  802231:	c7 44 24 08 16 31 80 	movl   $0x803116,0x8(%esp)
  802238:	00 
  802239:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  802240:	00 
  802241:	c7 04 24 bb 32 80 00 	movl   $0x8032bb,(%esp)
  802248:	e8 d7 df ff ff       	call   800224 <_panic>
	assert(r <= PGSIZE);
  80224d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802252:	7e 24                	jle    802278 <devfile_read+0x84>
  802254:	c7 44 24 0c c6 32 80 	movl   $0x8032c6,0xc(%esp)
  80225b:	00 
  80225c:	c7 44 24 08 16 31 80 	movl   $0x803116,0x8(%esp)
  802263:	00 
  802264:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  80226b:	00 
  80226c:	c7 04 24 bb 32 80 00 	movl   $0x8032bb,(%esp)
  802273:	e8 ac df ff ff       	call   800224 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  802278:	89 44 24 08          	mov    %eax,0x8(%esp)
  80227c:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  802283:	00 
  802284:	8b 45 0c             	mov    0xc(%ebp),%eax
  802287:	89 04 24             	mov    %eax,(%esp)
  80228a:	e8 b1 e7 ff ff       	call   800a40 <memmove>
	return r;
}
  80228f:	89 d8                	mov    %ebx,%eax
  802291:	83 c4 10             	add    $0x10,%esp
  802294:	5b                   	pop    %ebx
  802295:	5e                   	pop    %esi
  802296:	5d                   	pop    %ebp
  802297:	c3                   	ret    

00802298 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802298:	55                   	push   %ebp
  802299:	89 e5                	mov    %esp,%ebp
  80229b:	56                   	push   %esi
  80229c:	53                   	push   %ebx
  80229d:	83 ec 20             	sub    $0x20,%esp
  8022a0:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8022a3:	89 34 24             	mov    %esi,(%esp)
  8022a6:	e8 e9 e5 ff ff       	call   800894 <strlen>
  8022ab:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8022b0:	7f 60                	jg     802312 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8022b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022b5:	89 04 24             	mov    %eax,(%esp)
  8022b8:	e8 16 f8 ff ff       	call   801ad3 <fd_alloc>
  8022bd:	89 c3                	mov    %eax,%ebx
  8022bf:	85 c0                	test   %eax,%eax
  8022c1:	78 54                	js     802317 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8022c3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022c7:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  8022ce:	e8 f4 e5 ff ff       	call   8008c7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8022d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022d6:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8022db:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8022de:	b8 01 00 00 00       	mov    $0x1,%eax
  8022e3:	e8 b0 fd ff ff       	call   802098 <fsipc>
  8022e8:	89 c3                	mov    %eax,%ebx
  8022ea:	85 c0                	test   %eax,%eax
  8022ec:	79 15                	jns    802303 <open+0x6b>
		fd_close(fd, 0);
  8022ee:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8022f5:	00 
  8022f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022f9:	89 04 24             	mov    %eax,(%esp)
  8022fc:	e8 d5 f8 ff ff       	call   801bd6 <fd_close>
		return r;
  802301:	eb 14                	jmp    802317 <open+0x7f>
	}

	return fd2num(fd);
  802303:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802306:	89 04 24             	mov    %eax,(%esp)
  802309:	e8 9a f7 ff ff       	call   801aa8 <fd2num>
  80230e:	89 c3                	mov    %eax,%ebx
  802310:	eb 05                	jmp    802317 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  802312:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  802317:	89 d8                	mov    %ebx,%eax
  802319:	83 c4 20             	add    $0x20,%esp
  80231c:	5b                   	pop    %ebx
  80231d:	5e                   	pop    %esi
  80231e:	5d                   	pop    %ebp
  80231f:	c3                   	ret    

00802320 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  802320:	55                   	push   %ebp
  802321:	89 e5                	mov    %esp,%ebp
  802323:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  802326:	ba 00 00 00 00       	mov    $0x0,%edx
  80232b:	b8 08 00 00 00       	mov    $0x8,%eax
  802330:	e8 63 fd ff ff       	call   802098 <fsipc>
}
  802335:	c9                   	leave  
  802336:	c3                   	ret    
	...

00802338 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802338:	55                   	push   %ebp
  802339:	89 e5                	mov    %esp,%ebp
  80233b:	56                   	push   %esi
  80233c:	53                   	push   %ebx
  80233d:	83 ec 10             	sub    $0x10,%esp
  802340:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802343:	8b 45 08             	mov    0x8(%ebp),%eax
  802346:	89 04 24             	mov    %eax,(%esp)
  802349:	e8 6a f7 ff ff       	call   801ab8 <fd2data>
  80234e:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  802350:	c7 44 24 04 d2 32 80 	movl   $0x8032d2,0x4(%esp)
  802357:	00 
  802358:	89 34 24             	mov    %esi,(%esp)
  80235b:	e8 67 e5 ff ff       	call   8008c7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802360:	8b 43 04             	mov    0x4(%ebx),%eax
  802363:	2b 03                	sub    (%ebx),%eax
  802365:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80236b:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  802372:	00 00 00 
	stat->st_dev = &devpipe;
  802375:	c7 86 88 00 00 00 28 	movl   $0x804028,0x88(%esi)
  80237c:	40 80 00 
	return 0;
}
  80237f:	b8 00 00 00 00       	mov    $0x0,%eax
  802384:	83 c4 10             	add    $0x10,%esp
  802387:	5b                   	pop    %ebx
  802388:	5e                   	pop    %esi
  802389:	5d                   	pop    %ebp
  80238a:	c3                   	ret    

0080238b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80238b:	55                   	push   %ebp
  80238c:	89 e5                	mov    %esp,%ebp
  80238e:	53                   	push   %ebx
  80238f:	83 ec 14             	sub    $0x14,%esp
  802392:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802395:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802399:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023a0:	e8 bb e9 ff ff       	call   800d60 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8023a5:	89 1c 24             	mov    %ebx,(%esp)
  8023a8:	e8 0b f7 ff ff       	call   801ab8 <fd2data>
  8023ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023b8:	e8 a3 e9 ff ff       	call   800d60 <sys_page_unmap>
}
  8023bd:	83 c4 14             	add    $0x14,%esp
  8023c0:	5b                   	pop    %ebx
  8023c1:	5d                   	pop    %ebp
  8023c2:	c3                   	ret    

008023c3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8023c3:	55                   	push   %ebp
  8023c4:	89 e5                	mov    %esp,%ebp
  8023c6:	57                   	push   %edi
  8023c7:	56                   	push   %esi
  8023c8:	53                   	push   %ebx
  8023c9:	83 ec 2c             	sub    $0x2c,%esp
  8023cc:	89 c7                	mov    %eax,%edi
  8023ce:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8023d1:	a1 04 50 80 00       	mov    0x805004,%eax
  8023d6:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8023d9:	89 3c 24             	mov    %edi,(%esp)
  8023dc:	e8 8b 05 00 00       	call   80296c <pageref>
  8023e1:	89 c6                	mov    %eax,%esi
  8023e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8023e6:	89 04 24             	mov    %eax,(%esp)
  8023e9:	e8 7e 05 00 00       	call   80296c <pageref>
  8023ee:	39 c6                	cmp    %eax,%esi
  8023f0:	0f 94 c0             	sete   %al
  8023f3:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8023f6:	8b 15 04 50 80 00    	mov    0x805004,%edx
  8023fc:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8023ff:	39 cb                	cmp    %ecx,%ebx
  802401:	75 08                	jne    80240b <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  802403:	83 c4 2c             	add    $0x2c,%esp
  802406:	5b                   	pop    %ebx
  802407:	5e                   	pop    %esi
  802408:	5f                   	pop    %edi
  802409:	5d                   	pop    %ebp
  80240a:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  80240b:	83 f8 01             	cmp    $0x1,%eax
  80240e:	75 c1                	jne    8023d1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802410:	8b 42 58             	mov    0x58(%edx),%eax
  802413:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  80241a:	00 
  80241b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80241f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802423:	c7 04 24 d9 32 80 00 	movl   $0x8032d9,(%esp)
  80242a:	e8 ed de ff ff       	call   80031c <cprintf>
  80242f:	eb a0                	jmp    8023d1 <_pipeisclosed+0xe>

00802431 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802431:	55                   	push   %ebp
  802432:	89 e5                	mov    %esp,%ebp
  802434:	57                   	push   %edi
  802435:	56                   	push   %esi
  802436:	53                   	push   %ebx
  802437:	83 ec 1c             	sub    $0x1c,%esp
  80243a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80243d:	89 34 24             	mov    %esi,(%esp)
  802440:	e8 73 f6 ff ff       	call   801ab8 <fd2data>
  802445:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802447:	bf 00 00 00 00       	mov    $0x0,%edi
  80244c:	eb 3c                	jmp    80248a <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80244e:	89 da                	mov    %ebx,%edx
  802450:	89 f0                	mov    %esi,%eax
  802452:	e8 6c ff ff ff       	call   8023c3 <_pipeisclosed>
  802457:	85 c0                	test   %eax,%eax
  802459:	75 38                	jne    802493 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80245b:	e8 3a e8 ff ff       	call   800c9a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802460:	8b 43 04             	mov    0x4(%ebx),%eax
  802463:	8b 13                	mov    (%ebx),%edx
  802465:	83 c2 20             	add    $0x20,%edx
  802468:	39 d0                	cmp    %edx,%eax
  80246a:	73 e2                	jae    80244e <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80246c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80246f:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  802472:	89 c2                	mov    %eax,%edx
  802474:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  80247a:	79 05                	jns    802481 <devpipe_write+0x50>
  80247c:	4a                   	dec    %edx
  80247d:	83 ca e0             	or     $0xffffffe0,%edx
  802480:	42                   	inc    %edx
  802481:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802485:	40                   	inc    %eax
  802486:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802489:	47                   	inc    %edi
  80248a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80248d:	75 d1                	jne    802460 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80248f:	89 f8                	mov    %edi,%eax
  802491:	eb 05                	jmp    802498 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802493:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802498:	83 c4 1c             	add    $0x1c,%esp
  80249b:	5b                   	pop    %ebx
  80249c:	5e                   	pop    %esi
  80249d:	5f                   	pop    %edi
  80249e:	5d                   	pop    %ebp
  80249f:	c3                   	ret    

008024a0 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8024a0:	55                   	push   %ebp
  8024a1:	89 e5                	mov    %esp,%ebp
  8024a3:	57                   	push   %edi
  8024a4:	56                   	push   %esi
  8024a5:	53                   	push   %ebx
  8024a6:	83 ec 1c             	sub    $0x1c,%esp
  8024a9:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8024ac:	89 3c 24             	mov    %edi,(%esp)
  8024af:	e8 04 f6 ff ff       	call   801ab8 <fd2data>
  8024b4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8024b6:	be 00 00 00 00       	mov    $0x0,%esi
  8024bb:	eb 3a                	jmp    8024f7 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8024bd:	85 f6                	test   %esi,%esi
  8024bf:	74 04                	je     8024c5 <devpipe_read+0x25>
				return i;
  8024c1:	89 f0                	mov    %esi,%eax
  8024c3:	eb 40                	jmp    802505 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8024c5:	89 da                	mov    %ebx,%edx
  8024c7:	89 f8                	mov    %edi,%eax
  8024c9:	e8 f5 fe ff ff       	call   8023c3 <_pipeisclosed>
  8024ce:	85 c0                	test   %eax,%eax
  8024d0:	75 2e                	jne    802500 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8024d2:	e8 c3 e7 ff ff       	call   800c9a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8024d7:	8b 03                	mov    (%ebx),%eax
  8024d9:	3b 43 04             	cmp    0x4(%ebx),%eax
  8024dc:	74 df                	je     8024bd <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8024de:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8024e3:	79 05                	jns    8024ea <devpipe_read+0x4a>
  8024e5:	48                   	dec    %eax
  8024e6:	83 c8 e0             	or     $0xffffffe0,%eax
  8024e9:	40                   	inc    %eax
  8024ea:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8024ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8024f1:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8024f4:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8024f6:	46                   	inc    %esi
  8024f7:	3b 75 10             	cmp    0x10(%ebp),%esi
  8024fa:	75 db                	jne    8024d7 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8024fc:	89 f0                	mov    %esi,%eax
  8024fe:	eb 05                	jmp    802505 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802500:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802505:	83 c4 1c             	add    $0x1c,%esp
  802508:	5b                   	pop    %ebx
  802509:	5e                   	pop    %esi
  80250a:	5f                   	pop    %edi
  80250b:	5d                   	pop    %ebp
  80250c:	c3                   	ret    

0080250d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80250d:	55                   	push   %ebp
  80250e:	89 e5                	mov    %esp,%ebp
  802510:	57                   	push   %edi
  802511:	56                   	push   %esi
  802512:	53                   	push   %ebx
  802513:	83 ec 3c             	sub    $0x3c,%esp
  802516:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802519:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80251c:	89 04 24             	mov    %eax,(%esp)
  80251f:	e8 af f5 ff ff       	call   801ad3 <fd_alloc>
  802524:	89 c3                	mov    %eax,%ebx
  802526:	85 c0                	test   %eax,%eax
  802528:	0f 88 45 01 00 00    	js     802673 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80252e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802535:	00 
  802536:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802539:	89 44 24 04          	mov    %eax,0x4(%esp)
  80253d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802544:	e8 70 e7 ff ff       	call   800cb9 <sys_page_alloc>
  802549:	89 c3                	mov    %eax,%ebx
  80254b:	85 c0                	test   %eax,%eax
  80254d:	0f 88 20 01 00 00    	js     802673 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802553:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802556:	89 04 24             	mov    %eax,(%esp)
  802559:	e8 75 f5 ff ff       	call   801ad3 <fd_alloc>
  80255e:	89 c3                	mov    %eax,%ebx
  802560:	85 c0                	test   %eax,%eax
  802562:	0f 88 f8 00 00 00    	js     802660 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802568:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80256f:	00 
  802570:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802573:	89 44 24 04          	mov    %eax,0x4(%esp)
  802577:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80257e:	e8 36 e7 ff ff       	call   800cb9 <sys_page_alloc>
  802583:	89 c3                	mov    %eax,%ebx
  802585:	85 c0                	test   %eax,%eax
  802587:	0f 88 d3 00 00 00    	js     802660 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80258d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802590:	89 04 24             	mov    %eax,(%esp)
  802593:	e8 20 f5 ff ff       	call   801ab8 <fd2data>
  802598:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80259a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8025a1:	00 
  8025a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8025ad:	e8 07 e7 ff ff       	call   800cb9 <sys_page_alloc>
  8025b2:	89 c3                	mov    %eax,%ebx
  8025b4:	85 c0                	test   %eax,%eax
  8025b6:	0f 88 91 00 00 00    	js     80264d <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8025bc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8025bf:	89 04 24             	mov    %eax,(%esp)
  8025c2:	e8 f1 f4 ff ff       	call   801ab8 <fd2data>
  8025c7:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8025ce:	00 
  8025cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8025d3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8025da:	00 
  8025db:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8025e6:	e8 22 e7 ff ff       	call   800d0d <sys_page_map>
  8025eb:	89 c3                	mov    %eax,%ebx
  8025ed:	85 c0                	test   %eax,%eax
  8025ef:	78 4c                	js     80263d <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8025f1:	8b 15 28 40 80 00    	mov    0x804028,%edx
  8025f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8025fa:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8025fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8025ff:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802606:	8b 15 28 40 80 00    	mov    0x804028,%edx
  80260c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80260f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802611:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802614:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80261b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80261e:	89 04 24             	mov    %eax,(%esp)
  802621:	e8 82 f4 ff ff       	call   801aa8 <fd2num>
  802626:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802628:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80262b:	89 04 24             	mov    %eax,(%esp)
  80262e:	e8 75 f4 ff ff       	call   801aa8 <fd2num>
  802633:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  802636:	bb 00 00 00 00       	mov    $0x0,%ebx
  80263b:	eb 36                	jmp    802673 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  80263d:	89 74 24 04          	mov    %esi,0x4(%esp)
  802641:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802648:	e8 13 e7 ff ff       	call   800d60 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  80264d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802650:	89 44 24 04          	mov    %eax,0x4(%esp)
  802654:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80265b:	e8 00 e7 ff ff       	call   800d60 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802660:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802663:	89 44 24 04          	mov    %eax,0x4(%esp)
  802667:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80266e:	e8 ed e6 ff ff       	call   800d60 <sys_page_unmap>
    err:
	return r;
}
  802673:	89 d8                	mov    %ebx,%eax
  802675:	83 c4 3c             	add    $0x3c,%esp
  802678:	5b                   	pop    %ebx
  802679:	5e                   	pop    %esi
  80267a:	5f                   	pop    %edi
  80267b:	5d                   	pop    %ebp
  80267c:	c3                   	ret    

0080267d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80267d:	55                   	push   %ebp
  80267e:	89 e5                	mov    %esp,%ebp
  802680:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802683:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802686:	89 44 24 04          	mov    %eax,0x4(%esp)
  80268a:	8b 45 08             	mov    0x8(%ebp),%eax
  80268d:	89 04 24             	mov    %eax,(%esp)
  802690:	e8 91 f4 ff ff       	call   801b26 <fd_lookup>
  802695:	85 c0                	test   %eax,%eax
  802697:	78 15                	js     8026ae <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802699:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80269c:	89 04 24             	mov    %eax,(%esp)
  80269f:	e8 14 f4 ff ff       	call   801ab8 <fd2data>
	return _pipeisclosed(fd, p);
  8026a4:	89 c2                	mov    %eax,%edx
  8026a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026a9:	e8 15 fd ff ff       	call   8023c3 <_pipeisclosed>
}
  8026ae:	c9                   	leave  
  8026af:	c3                   	ret    

008026b0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8026b0:	55                   	push   %ebp
  8026b1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8026b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8026b8:	5d                   	pop    %ebp
  8026b9:	c3                   	ret    

008026ba <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8026ba:	55                   	push   %ebp
  8026bb:	89 e5                	mov    %esp,%ebp
  8026bd:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8026c0:	c7 44 24 04 f1 32 80 	movl   $0x8032f1,0x4(%esp)
  8026c7:	00 
  8026c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026cb:	89 04 24             	mov    %eax,(%esp)
  8026ce:	e8 f4 e1 ff ff       	call   8008c7 <strcpy>
	return 0;
}
  8026d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8026d8:	c9                   	leave  
  8026d9:	c3                   	ret    

008026da <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8026da:	55                   	push   %ebp
  8026db:	89 e5                	mov    %esp,%ebp
  8026dd:	57                   	push   %edi
  8026de:	56                   	push   %esi
  8026df:	53                   	push   %ebx
  8026e0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8026e6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8026eb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8026f1:	eb 30                	jmp    802723 <devcons_write+0x49>
		m = n - tot;
  8026f3:	8b 75 10             	mov    0x10(%ebp),%esi
  8026f6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8026f8:	83 fe 7f             	cmp    $0x7f,%esi
  8026fb:	76 05                	jbe    802702 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8026fd:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802702:	89 74 24 08          	mov    %esi,0x8(%esp)
  802706:	03 45 0c             	add    0xc(%ebp),%eax
  802709:	89 44 24 04          	mov    %eax,0x4(%esp)
  80270d:	89 3c 24             	mov    %edi,(%esp)
  802710:	e8 2b e3 ff ff       	call   800a40 <memmove>
		sys_cputs(buf, m);
  802715:	89 74 24 04          	mov    %esi,0x4(%esp)
  802719:	89 3c 24             	mov    %edi,(%esp)
  80271c:	e8 cb e4 ff ff       	call   800bec <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802721:	01 f3                	add    %esi,%ebx
  802723:	89 d8                	mov    %ebx,%eax
  802725:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802728:	72 c9                	jb     8026f3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80272a:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802730:	5b                   	pop    %ebx
  802731:	5e                   	pop    %esi
  802732:	5f                   	pop    %edi
  802733:	5d                   	pop    %ebp
  802734:	c3                   	ret    

00802735 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802735:	55                   	push   %ebp
  802736:	89 e5                	mov    %esp,%ebp
  802738:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  80273b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80273f:	75 07                	jne    802748 <devcons_read+0x13>
  802741:	eb 25                	jmp    802768 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802743:	e8 52 e5 ff ff       	call   800c9a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802748:	e8 bd e4 ff ff       	call   800c0a <sys_cgetc>
  80274d:	85 c0                	test   %eax,%eax
  80274f:	74 f2                	je     802743 <devcons_read+0xe>
  802751:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  802753:	85 c0                	test   %eax,%eax
  802755:	78 1d                	js     802774 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802757:	83 f8 04             	cmp    $0x4,%eax
  80275a:	74 13                	je     80276f <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  80275c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80275f:	88 10                	mov    %dl,(%eax)
	return 1;
  802761:	b8 01 00 00 00       	mov    $0x1,%eax
  802766:	eb 0c                	jmp    802774 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802768:	b8 00 00 00 00       	mov    $0x0,%eax
  80276d:	eb 05                	jmp    802774 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80276f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802774:	c9                   	leave  
  802775:	c3                   	ret    

00802776 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802776:	55                   	push   %ebp
  802777:	89 e5                	mov    %esp,%ebp
  802779:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80277c:	8b 45 08             	mov    0x8(%ebp),%eax
  80277f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802782:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802789:	00 
  80278a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80278d:	89 04 24             	mov    %eax,(%esp)
  802790:	e8 57 e4 ff ff       	call   800bec <sys_cputs>
}
  802795:	c9                   	leave  
  802796:	c3                   	ret    

00802797 <getchar>:

int
getchar(void)
{
  802797:	55                   	push   %ebp
  802798:	89 e5                	mov    %esp,%ebp
  80279a:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80279d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8027a4:	00 
  8027a5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8027a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027ac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8027b3:	e8 0a f6 ff ff       	call   801dc2 <read>
	if (r < 0)
  8027b8:	85 c0                	test   %eax,%eax
  8027ba:	78 0f                	js     8027cb <getchar+0x34>
		return r;
	if (r < 1)
  8027bc:	85 c0                	test   %eax,%eax
  8027be:	7e 06                	jle    8027c6 <getchar+0x2f>
		return -E_EOF;
	return c;
  8027c0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8027c4:	eb 05                	jmp    8027cb <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8027c6:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8027cb:	c9                   	leave  
  8027cc:	c3                   	ret    

008027cd <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8027cd:	55                   	push   %ebp
  8027ce:	89 e5                	mov    %esp,%ebp
  8027d0:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8027d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8027d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027da:	8b 45 08             	mov    0x8(%ebp),%eax
  8027dd:	89 04 24             	mov    %eax,(%esp)
  8027e0:	e8 41 f3 ff ff       	call   801b26 <fd_lookup>
  8027e5:	85 c0                	test   %eax,%eax
  8027e7:	78 11                	js     8027fa <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8027e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8027ec:	8b 15 44 40 80 00    	mov    0x804044,%edx
  8027f2:	39 10                	cmp    %edx,(%eax)
  8027f4:	0f 94 c0             	sete   %al
  8027f7:	0f b6 c0             	movzbl %al,%eax
}
  8027fa:	c9                   	leave  
  8027fb:	c3                   	ret    

008027fc <opencons>:

int
opencons(void)
{
  8027fc:	55                   	push   %ebp
  8027fd:	89 e5                	mov    %esp,%ebp
  8027ff:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802802:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802805:	89 04 24             	mov    %eax,(%esp)
  802808:	e8 c6 f2 ff ff       	call   801ad3 <fd_alloc>
  80280d:	85 c0                	test   %eax,%eax
  80280f:	78 3c                	js     80284d <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802811:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802818:	00 
  802819:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80281c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802820:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802827:	e8 8d e4 ff ff       	call   800cb9 <sys_page_alloc>
  80282c:	85 c0                	test   %eax,%eax
  80282e:	78 1d                	js     80284d <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802830:	8b 15 44 40 80 00    	mov    0x804044,%edx
  802836:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802839:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80283b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80283e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802845:	89 04 24             	mov    %eax,(%esp)
  802848:	e8 5b f2 ff ff       	call   801aa8 <fd2num>
}
  80284d:	c9                   	leave  
  80284e:	c3                   	ret    
	...

00802850 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802850:	55                   	push   %ebp
  802851:	89 e5                	mov    %esp,%ebp
  802853:	56                   	push   %esi
  802854:	53                   	push   %ebx
  802855:	83 ec 10             	sub    $0x10,%esp
  802858:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80285b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80285e:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int r;
		
	r = sys_ipc_recv(pg?pg:(void*)UTOP);
  802861:	85 c0                	test   %eax,%eax
  802863:	75 05                	jne    80286a <ipc_recv+0x1a>
  802865:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80286a:	89 04 24             	mov    %eax,(%esp)
  80286d:	e8 5d e6 ff ff       	call   800ecf <sys_ipc_recv>
	if (from_env_store != NULL)
  802872:	85 db                	test   %ebx,%ebx
  802874:	74 0b                	je     802881 <ipc_recv+0x31>
		*from_env_store = thisenv->env_ipc_from; 
  802876:	8b 15 04 50 80 00    	mov    0x805004,%edx
  80287c:	8b 52 74             	mov    0x74(%edx),%edx
  80287f:	89 13                	mov    %edx,(%ebx)
	if (perm_store != NULL)
  802881:	85 f6                	test   %esi,%esi
  802883:	74 0b                	je     802890 <ipc_recv+0x40>
		*perm_store = thisenv->env_ipc_perm;
  802885:	8b 15 04 50 80 00    	mov    0x805004,%edx
  80288b:	8b 52 78             	mov    0x78(%edx),%edx
  80288e:	89 16                	mov    %edx,(%esi)
	
	if (r < 0){
  802890:	85 c0                	test   %eax,%eax
  802892:	79 16                	jns    8028aa <ipc_recv+0x5a>
		if(from_env_store != NULL)
  802894:	85 db                	test   %ebx,%ebx
  802896:	74 06                	je     80289e <ipc_recv+0x4e>
			*from_env_store = 0;
  802898:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store != NULL)	
  80289e:	85 f6                	test   %esi,%esi
  8028a0:	74 10                	je     8028b2 <ipc_recv+0x62>
			*perm_store = 0;
  8028a2:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8028a8:	eb 08                	jmp    8028b2 <ipc_recv+0x62>
		return r;
	}
	
	return thisenv->env_ipc_value;
  8028aa:	a1 04 50 80 00       	mov    0x805004,%eax
  8028af:	8b 40 70             	mov    0x70(%eax),%eax
}
  8028b2:	83 c4 10             	add    $0x10,%esp
  8028b5:	5b                   	pop    %ebx
  8028b6:	5e                   	pop    %esi
  8028b7:	5d                   	pop    %ebp
  8028b8:	c3                   	ret    

008028b9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8028b9:	55                   	push   %ebp
  8028ba:	89 e5                	mov    %esp,%ebp
  8028bc:	57                   	push   %edi
  8028bd:	56                   	push   %esi
  8028be:	53                   	push   %ebx
  8028bf:	83 ec 1c             	sub    $0x1c,%esp
  8028c2:	8b 75 08             	mov    0x8(%ebp),%esi
  8028c5:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8028c8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  8028cb:	eb 2a                	jmp    8028f7 <ipc_send+0x3e>
		if (r != -E_IPC_NOT_RECV)
  8028cd:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8028d0:	74 20                	je     8028f2 <ipc_send+0x39>
			panic("ipc_send: sys_ipc_try_send failed %e", r);
  8028d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8028d6:	c7 44 24 08 00 33 80 	movl   $0x803300,0x8(%esp)
  8028dd:	00 
  8028de:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  8028e5:	00 
  8028e6:	c7 04 24 28 33 80 00 	movl   $0x803328,(%esp)
  8028ed:	e8 32 d9 ff ff       	call   800224 <_panic>
		sys_yield();
  8028f2:	e8 a3 e3 ff ff       	call   800c9a <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  8028f7:	85 db                	test   %ebx,%ebx
  8028f9:	75 07                	jne    802902 <ipc_send+0x49>
  8028fb:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802900:	eb 02                	jmp    802904 <ipc_send+0x4b>
  802902:	89 d8                	mov    %ebx,%eax
  802904:	8b 55 14             	mov    0x14(%ebp),%edx
  802907:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80290b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80290f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802913:	89 34 24             	mov    %esi,(%esp)
  802916:	e8 91 e5 ff ff       	call   800eac <sys_ipc_try_send>
  80291b:	85 c0                	test   %eax,%eax
  80291d:	78 ae                	js     8028cd <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: sys_ipc_try_send failed %e", r);
		sys_yield();
	}
}
  80291f:	83 c4 1c             	add    $0x1c,%esp
  802922:	5b                   	pop    %ebx
  802923:	5e                   	pop    %esi
  802924:	5f                   	pop    %edi
  802925:	5d                   	pop    %ebp
  802926:	c3                   	ret    

00802927 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802927:	55                   	push   %ebp
  802928:	89 e5                	mov    %esp,%ebp
  80292a:	53                   	push   %ebx
  80292b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  80292e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802933:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  80293a:	89 c2                	mov    %eax,%edx
  80293c:	c1 e2 07             	shl    $0x7,%edx
  80293f:	29 ca                	sub    %ecx,%edx
  802941:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802947:	8b 52 50             	mov    0x50(%edx),%edx
  80294a:	39 da                	cmp    %ebx,%edx
  80294c:	75 0f                	jne    80295d <ipc_find_env+0x36>
			return envs[i].env_id;
  80294e:	c1 e0 07             	shl    $0x7,%eax
  802951:	29 c8                	sub    %ecx,%eax
  802953:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802958:	8b 40 40             	mov    0x40(%eax),%eax
  80295b:	eb 0c                	jmp    802969 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80295d:	40                   	inc    %eax
  80295e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802963:	75 ce                	jne    802933 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802965:	66 b8 00 00          	mov    $0x0,%ax
}
  802969:	5b                   	pop    %ebx
  80296a:	5d                   	pop    %ebp
  80296b:	c3                   	ret    

0080296c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80296c:	55                   	push   %ebp
  80296d:	89 e5                	mov    %esp,%ebp
  80296f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802972:	89 c2                	mov    %eax,%edx
  802974:	c1 ea 16             	shr    $0x16,%edx
  802977:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80297e:	f6 c2 01             	test   $0x1,%dl
  802981:	74 1e                	je     8029a1 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802983:	c1 e8 0c             	shr    $0xc,%eax
  802986:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80298d:	a8 01                	test   $0x1,%al
  80298f:	74 17                	je     8029a8 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802991:	c1 e8 0c             	shr    $0xc,%eax
  802994:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80299b:	ef 
  80299c:	0f b7 c0             	movzwl %ax,%eax
  80299f:	eb 0c                	jmp    8029ad <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8029a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8029a6:	eb 05                	jmp    8029ad <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8029a8:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8029ad:	5d                   	pop    %ebp
  8029ae:	c3                   	ret    
	...

008029b0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8029b0:	55                   	push   %ebp
  8029b1:	57                   	push   %edi
  8029b2:	56                   	push   %esi
  8029b3:	83 ec 10             	sub    $0x10,%esp
  8029b6:	8b 74 24 20          	mov    0x20(%esp),%esi
  8029ba:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8029be:	89 74 24 04          	mov    %esi,0x4(%esp)
  8029c2:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  8029c6:	89 cd                	mov    %ecx,%ebp
  8029c8:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8029cc:	85 c0                	test   %eax,%eax
  8029ce:	75 2c                	jne    8029fc <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8029d0:	39 f9                	cmp    %edi,%ecx
  8029d2:	77 68                	ja     802a3c <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8029d4:	85 c9                	test   %ecx,%ecx
  8029d6:	75 0b                	jne    8029e3 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8029d8:	b8 01 00 00 00       	mov    $0x1,%eax
  8029dd:	31 d2                	xor    %edx,%edx
  8029df:	f7 f1                	div    %ecx
  8029e1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8029e3:	31 d2                	xor    %edx,%edx
  8029e5:	89 f8                	mov    %edi,%eax
  8029e7:	f7 f1                	div    %ecx
  8029e9:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8029eb:	89 f0                	mov    %esi,%eax
  8029ed:	f7 f1                	div    %ecx
  8029ef:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8029f1:	89 f0                	mov    %esi,%eax
  8029f3:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8029f5:	83 c4 10             	add    $0x10,%esp
  8029f8:	5e                   	pop    %esi
  8029f9:	5f                   	pop    %edi
  8029fa:	5d                   	pop    %ebp
  8029fb:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8029fc:	39 f8                	cmp    %edi,%eax
  8029fe:	77 2c                	ja     802a2c <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802a00:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  802a03:	83 f6 1f             	xor    $0x1f,%esi
  802a06:	75 4c                	jne    802a54 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802a08:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802a0a:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802a0f:	72 0a                	jb     802a1b <__udivdi3+0x6b>
  802a11:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802a15:	0f 87 ad 00 00 00    	ja     802ac8 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802a1b:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802a20:	89 f0                	mov    %esi,%eax
  802a22:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802a24:	83 c4 10             	add    $0x10,%esp
  802a27:	5e                   	pop    %esi
  802a28:	5f                   	pop    %edi
  802a29:	5d                   	pop    %ebp
  802a2a:	c3                   	ret    
  802a2b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802a2c:	31 ff                	xor    %edi,%edi
  802a2e:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802a30:	89 f0                	mov    %esi,%eax
  802a32:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802a34:	83 c4 10             	add    $0x10,%esp
  802a37:	5e                   	pop    %esi
  802a38:	5f                   	pop    %edi
  802a39:	5d                   	pop    %ebp
  802a3a:	c3                   	ret    
  802a3b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802a3c:	89 fa                	mov    %edi,%edx
  802a3e:	89 f0                	mov    %esi,%eax
  802a40:	f7 f1                	div    %ecx
  802a42:	89 c6                	mov    %eax,%esi
  802a44:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802a46:	89 f0                	mov    %esi,%eax
  802a48:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802a4a:	83 c4 10             	add    $0x10,%esp
  802a4d:	5e                   	pop    %esi
  802a4e:	5f                   	pop    %edi
  802a4f:	5d                   	pop    %ebp
  802a50:	c3                   	ret    
  802a51:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802a54:	89 f1                	mov    %esi,%ecx
  802a56:	d3 e0                	shl    %cl,%eax
  802a58:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802a5c:	b8 20 00 00 00       	mov    $0x20,%eax
  802a61:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802a63:	89 ea                	mov    %ebp,%edx
  802a65:	88 c1                	mov    %al,%cl
  802a67:	d3 ea                	shr    %cl,%edx
  802a69:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802a6d:	09 ca                	or     %ecx,%edx
  802a6f:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  802a73:	89 f1                	mov    %esi,%ecx
  802a75:	d3 e5                	shl    %cl,%ebp
  802a77:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  802a7b:	89 fd                	mov    %edi,%ebp
  802a7d:	88 c1                	mov    %al,%cl
  802a7f:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802a81:	89 fa                	mov    %edi,%edx
  802a83:	89 f1                	mov    %esi,%ecx
  802a85:	d3 e2                	shl    %cl,%edx
  802a87:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802a8b:	88 c1                	mov    %al,%cl
  802a8d:	d3 ef                	shr    %cl,%edi
  802a8f:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802a91:	89 f8                	mov    %edi,%eax
  802a93:	89 ea                	mov    %ebp,%edx
  802a95:	f7 74 24 08          	divl   0x8(%esp)
  802a99:	89 d1                	mov    %edx,%ecx
  802a9b:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802a9d:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802aa1:	39 d1                	cmp    %edx,%ecx
  802aa3:	72 17                	jb     802abc <__udivdi3+0x10c>
  802aa5:	74 09                	je     802ab0 <__udivdi3+0x100>
  802aa7:	89 fe                	mov    %edi,%esi
  802aa9:	31 ff                	xor    %edi,%edi
  802aab:	e9 41 ff ff ff       	jmp    8029f1 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802ab0:	8b 54 24 04          	mov    0x4(%esp),%edx
  802ab4:	89 f1                	mov    %esi,%ecx
  802ab6:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802ab8:	39 c2                	cmp    %eax,%edx
  802aba:	73 eb                	jae    802aa7 <__udivdi3+0xf7>
		{
		  q0--;
  802abc:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802abf:	31 ff                	xor    %edi,%edi
  802ac1:	e9 2b ff ff ff       	jmp    8029f1 <__udivdi3+0x41>
  802ac6:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802ac8:	31 f6                	xor    %esi,%esi
  802aca:	e9 22 ff ff ff       	jmp    8029f1 <__udivdi3+0x41>
	...

00802ad0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802ad0:	55                   	push   %ebp
  802ad1:	57                   	push   %edi
  802ad2:	56                   	push   %esi
  802ad3:	83 ec 20             	sub    $0x20,%esp
  802ad6:	8b 44 24 30          	mov    0x30(%esp),%eax
  802ada:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802ade:	89 44 24 14          	mov    %eax,0x14(%esp)
  802ae2:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  802ae6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802aea:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802aee:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802af0:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802af2:	85 ed                	test   %ebp,%ebp
  802af4:	75 16                	jne    802b0c <__umoddi3+0x3c>
    {
      if (d0 > n1)
  802af6:	39 f1                	cmp    %esi,%ecx
  802af8:	0f 86 a6 00 00 00    	jbe    802ba4 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802afe:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802b00:	89 d0                	mov    %edx,%eax
  802b02:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802b04:	83 c4 20             	add    $0x20,%esp
  802b07:	5e                   	pop    %esi
  802b08:	5f                   	pop    %edi
  802b09:	5d                   	pop    %ebp
  802b0a:	c3                   	ret    
  802b0b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802b0c:	39 f5                	cmp    %esi,%ebp
  802b0e:	0f 87 ac 00 00 00    	ja     802bc0 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802b14:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  802b17:	83 f0 1f             	xor    $0x1f,%eax
  802b1a:	89 44 24 10          	mov    %eax,0x10(%esp)
  802b1e:	0f 84 a8 00 00 00    	je     802bcc <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802b24:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802b28:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802b2a:	bf 20 00 00 00       	mov    $0x20,%edi
  802b2f:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802b33:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802b37:	89 f9                	mov    %edi,%ecx
  802b39:	d3 e8                	shr    %cl,%eax
  802b3b:	09 e8                	or     %ebp,%eax
  802b3d:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  802b41:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802b45:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802b49:	d3 e0                	shl    %cl,%eax
  802b4b:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802b4f:	89 f2                	mov    %esi,%edx
  802b51:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802b53:	8b 44 24 14          	mov    0x14(%esp),%eax
  802b57:	d3 e0                	shl    %cl,%eax
  802b59:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802b5d:	8b 44 24 14          	mov    0x14(%esp),%eax
  802b61:	89 f9                	mov    %edi,%ecx
  802b63:	d3 e8                	shr    %cl,%eax
  802b65:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802b67:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802b69:	89 f2                	mov    %esi,%edx
  802b6b:	f7 74 24 18          	divl   0x18(%esp)
  802b6f:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802b71:	f7 64 24 0c          	mull   0xc(%esp)
  802b75:	89 c5                	mov    %eax,%ebp
  802b77:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802b79:	39 d6                	cmp    %edx,%esi
  802b7b:	72 67                	jb     802be4 <__umoddi3+0x114>
  802b7d:	74 75                	je     802bf4 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802b7f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802b83:	29 e8                	sub    %ebp,%eax
  802b85:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802b87:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802b8b:	d3 e8                	shr    %cl,%eax
  802b8d:	89 f2                	mov    %esi,%edx
  802b8f:	89 f9                	mov    %edi,%ecx
  802b91:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802b93:	09 d0                	or     %edx,%eax
  802b95:	89 f2                	mov    %esi,%edx
  802b97:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802b9b:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802b9d:	83 c4 20             	add    $0x20,%esp
  802ba0:	5e                   	pop    %esi
  802ba1:	5f                   	pop    %edi
  802ba2:	5d                   	pop    %ebp
  802ba3:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802ba4:	85 c9                	test   %ecx,%ecx
  802ba6:	75 0b                	jne    802bb3 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802ba8:	b8 01 00 00 00       	mov    $0x1,%eax
  802bad:	31 d2                	xor    %edx,%edx
  802baf:	f7 f1                	div    %ecx
  802bb1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802bb3:	89 f0                	mov    %esi,%eax
  802bb5:	31 d2                	xor    %edx,%edx
  802bb7:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802bb9:	89 f8                	mov    %edi,%eax
  802bbb:	e9 3e ff ff ff       	jmp    802afe <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802bc0:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802bc2:	83 c4 20             	add    $0x20,%esp
  802bc5:	5e                   	pop    %esi
  802bc6:	5f                   	pop    %edi
  802bc7:	5d                   	pop    %ebp
  802bc8:	c3                   	ret    
  802bc9:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802bcc:	39 f5                	cmp    %esi,%ebp
  802bce:	72 04                	jb     802bd4 <__umoddi3+0x104>
  802bd0:	39 f9                	cmp    %edi,%ecx
  802bd2:	77 06                	ja     802bda <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802bd4:	89 f2                	mov    %esi,%edx
  802bd6:	29 cf                	sub    %ecx,%edi
  802bd8:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802bda:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802bdc:	83 c4 20             	add    $0x20,%esp
  802bdf:	5e                   	pop    %esi
  802be0:	5f                   	pop    %edi
  802be1:	5d                   	pop    %ebp
  802be2:	c3                   	ret    
  802be3:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802be4:	89 d1                	mov    %edx,%ecx
  802be6:	89 c5                	mov    %eax,%ebp
  802be8:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802bec:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802bf0:	eb 8d                	jmp    802b7f <__umoddi3+0xaf>
  802bf2:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802bf4:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802bf8:	72 ea                	jb     802be4 <__umoddi3+0x114>
  802bfa:	89 f1                	mov    %esi,%ecx
  802bfc:	eb 81                	jmp    802b7f <__umoddi3+0xaf>
