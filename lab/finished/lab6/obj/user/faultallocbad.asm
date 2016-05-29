
obj/user/faultallocbad.debug:     file format elf32-i386


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
  80002c:	e8 b3 00 00 00       	call   8000e4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 24             	sub    $0x24,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003b:	8b 45 08             	mov    0x8(%ebp),%eax
  80003e:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  800040:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800044:	c7 04 24 c0 11 80 00 	movl   $0x8011c0,(%esp)
  80004b:	e8 e8 01 00 00       	call   800238 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  800050:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800057:	00 
  800058:	89 d8                	mov    %ebx,%eax
  80005a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800063:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80006a:	e8 66 0b 00 00       	call   800bd5 <sys_page_alloc>
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 24                	jns    800097 <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800073:	89 44 24 10          	mov    %eax,0x10(%esp)
  800077:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80007b:	c7 44 24 08 e0 11 80 	movl   $0x8011e0,0x8(%esp)
  800082:	00 
  800083:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  80008a:	00 
  80008b:	c7 04 24 ca 11 80 00 	movl   $0x8011ca,(%esp)
  800092:	e8 a9 00 00 00       	call   800140 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800097:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80009b:	c7 44 24 08 0c 12 80 	movl   $0x80120c,0x8(%esp)
  8000a2:	00 
  8000a3:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000aa:	00 
  8000ab:	89 1c 24             	mov    %ebx,(%esp)
  8000ae:	e8 d2 06 00 00       	call   800785 <snprintf>
}
  8000b3:	83 c4 24             	add    $0x24,%esp
  8000b6:	5b                   	pop    %ebx
  8000b7:	5d                   	pop    %ebp
  8000b8:	c3                   	ret    

008000b9 <umain>:

void
umain(int argc, char **argv)
{
  8000b9:	55                   	push   %ebp
  8000ba:	89 e5                	mov    %esp,%ebp
  8000bc:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  8000bf:	c7 04 24 34 00 80 00 	movl   $0x800034,(%esp)
  8000c6:	e8 f5 0d 00 00       	call   800ec0 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000cb:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  8000d2:	00 
  8000d3:	c7 04 24 ef be ad de 	movl   $0xdeadbeef,(%esp)
  8000da:	e8 29 0a 00 00       	call   800b08 <sys_cputs>
}
  8000df:	c9                   	leave  
  8000e0:	c3                   	ret    
  8000e1:	00 00                	add    %al,(%eax)
	...

008000e4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
  8000e9:	83 ec 10             	sub    $0x10,%esp
  8000ec:	8b 75 08             	mov    0x8(%ebp),%esi
  8000ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000f2:	e8 a0 0a 00 00       	call   800b97 <sys_getenvid>
  8000f7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000fc:	c1 e0 07             	shl    $0x7,%eax
  8000ff:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800104:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800109:	85 f6                	test   %esi,%esi
  80010b:	7e 07                	jle    800114 <libmain+0x30>
		binaryname = argv[0];
  80010d:	8b 03                	mov    (%ebx),%eax
  80010f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800114:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800118:	89 34 24             	mov    %esi,(%esp)
  80011b:	e8 99 ff ff ff       	call   8000b9 <umain>

	// exit gracefully
	exit();
  800120:	e8 07 00 00 00       	call   80012c <exit>
}
  800125:	83 c4 10             	add    $0x10,%esp
  800128:	5b                   	pop    %ebx
  800129:	5e                   	pop    %esi
  80012a:	5d                   	pop    %ebp
  80012b:	c3                   	ret    

0080012c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  800132:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800139:	e8 07 0a 00 00       	call   800b45 <sys_env_destroy>
}
  80013e:	c9                   	leave  
  80013f:	c3                   	ret    

00800140 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
  800143:	56                   	push   %esi
  800144:	53                   	push   %ebx
  800145:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800148:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80014b:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800151:	e8 41 0a 00 00       	call   800b97 <sys_getenvid>
  800156:	8b 55 0c             	mov    0xc(%ebp),%edx
  800159:	89 54 24 10          	mov    %edx,0x10(%esp)
  80015d:	8b 55 08             	mov    0x8(%ebp),%edx
  800160:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800164:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800168:	89 44 24 04          	mov    %eax,0x4(%esp)
  80016c:	c7 04 24 38 12 80 00 	movl   $0x801238,(%esp)
  800173:	e8 c0 00 00 00       	call   800238 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800178:	89 74 24 04          	mov    %esi,0x4(%esp)
  80017c:	8b 45 10             	mov    0x10(%ebp),%eax
  80017f:	89 04 24             	mov    %eax,(%esp)
  800182:	e8 50 00 00 00       	call   8001d7 <vcprintf>
	cprintf("\n");
  800187:	c7 04 24 c8 11 80 00 	movl   $0x8011c8,(%esp)
  80018e:	e8 a5 00 00 00       	call   800238 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800193:	cc                   	int3   
  800194:	eb fd                	jmp    800193 <_panic+0x53>
	...

00800198 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	53                   	push   %ebx
  80019c:	83 ec 14             	sub    $0x14,%esp
  80019f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a2:	8b 03                	mov    (%ebx),%eax
  8001a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001ab:	40                   	inc    %eax
  8001ac:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001ae:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001b3:	75 19                	jne    8001ce <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001b5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001bc:	00 
  8001bd:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c0:	89 04 24             	mov    %eax,(%esp)
  8001c3:	e8 40 09 00 00       	call   800b08 <sys_cputs>
		b->idx = 0;
  8001c8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001ce:	ff 43 04             	incl   0x4(%ebx)
}
  8001d1:	83 c4 14             	add    $0x14,%esp
  8001d4:	5b                   	pop    %ebx
  8001d5:	5d                   	pop    %ebp
  8001d6:	c3                   	ret    

008001d7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d7:	55                   	push   %ebp
  8001d8:	89 e5                	mov    %esp,%ebp
  8001da:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001e0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e7:	00 00 00 
	b.cnt = 0;
  8001ea:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001f1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001f7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8001fe:	89 44 24 08          	mov    %eax,0x8(%esp)
  800202:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800208:	89 44 24 04          	mov    %eax,0x4(%esp)
  80020c:	c7 04 24 98 01 80 00 	movl   $0x800198,(%esp)
  800213:	e8 82 01 00 00       	call   80039a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800218:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80021e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800222:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800228:	89 04 24             	mov    %eax,(%esp)
  80022b:	e8 d8 08 00 00       	call   800b08 <sys_cputs>

	return b.cnt;
}
  800230:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800236:	c9                   	leave  
  800237:	c3                   	ret    

00800238 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80023e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800241:	89 44 24 04          	mov    %eax,0x4(%esp)
  800245:	8b 45 08             	mov    0x8(%ebp),%eax
  800248:	89 04 24             	mov    %eax,(%esp)
  80024b:	e8 87 ff ff ff       	call   8001d7 <vcprintf>
	va_end(ap);

	return cnt;
}
  800250:	c9                   	leave  
  800251:	c3                   	ret    
	...

00800254 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800254:	55                   	push   %ebp
  800255:	89 e5                	mov    %esp,%ebp
  800257:	57                   	push   %edi
  800258:	56                   	push   %esi
  800259:	53                   	push   %ebx
  80025a:	83 ec 3c             	sub    $0x3c,%esp
  80025d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800260:	89 d7                	mov    %edx,%edi
  800262:	8b 45 08             	mov    0x8(%ebp),%eax
  800265:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800268:	8b 45 0c             	mov    0xc(%ebp),%eax
  80026b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80026e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800271:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800274:	85 c0                	test   %eax,%eax
  800276:	75 08                	jne    800280 <printnum+0x2c>
  800278:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80027b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80027e:	77 57                	ja     8002d7 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800280:	89 74 24 10          	mov    %esi,0x10(%esp)
  800284:	4b                   	dec    %ebx
  800285:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800289:	8b 45 10             	mov    0x10(%ebp),%eax
  80028c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800290:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800294:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800298:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80029f:	00 
  8002a0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002a3:	89 04 24             	mov    %eax,(%esp)
  8002a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ad:	e8 a6 0c 00 00       	call   800f58 <__udivdi3>
  8002b2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002b6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002ba:	89 04 24             	mov    %eax,(%esp)
  8002bd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002c1:	89 fa                	mov    %edi,%edx
  8002c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002c6:	e8 89 ff ff ff       	call   800254 <printnum>
  8002cb:	eb 0f                	jmp    8002dc <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002cd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002d1:	89 34 24             	mov    %esi,(%esp)
  8002d4:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002d7:	4b                   	dec    %ebx
  8002d8:	85 db                	test   %ebx,%ebx
  8002da:	7f f1                	jg     8002cd <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002dc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002e0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002e4:	8b 45 10             	mov    0x10(%ebp),%eax
  8002e7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002eb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002f2:	00 
  8002f3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002f6:	89 04 24             	mov    %eax,(%esp)
  8002f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800300:	e8 73 0d 00 00       	call   801078 <__umoddi3>
  800305:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800309:	0f be 80 5b 12 80 00 	movsbl 0x80125b(%eax),%eax
  800310:	89 04 24             	mov    %eax,(%esp)
  800313:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800316:	83 c4 3c             	add    $0x3c,%esp
  800319:	5b                   	pop    %ebx
  80031a:	5e                   	pop    %esi
  80031b:	5f                   	pop    %edi
  80031c:	5d                   	pop    %ebp
  80031d:	c3                   	ret    

0080031e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80031e:	55                   	push   %ebp
  80031f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800321:	83 fa 01             	cmp    $0x1,%edx
  800324:	7e 0e                	jle    800334 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800326:	8b 10                	mov    (%eax),%edx
  800328:	8d 4a 08             	lea    0x8(%edx),%ecx
  80032b:	89 08                	mov    %ecx,(%eax)
  80032d:	8b 02                	mov    (%edx),%eax
  80032f:	8b 52 04             	mov    0x4(%edx),%edx
  800332:	eb 22                	jmp    800356 <getuint+0x38>
	else if (lflag)
  800334:	85 d2                	test   %edx,%edx
  800336:	74 10                	je     800348 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800338:	8b 10                	mov    (%eax),%edx
  80033a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80033d:	89 08                	mov    %ecx,(%eax)
  80033f:	8b 02                	mov    (%edx),%eax
  800341:	ba 00 00 00 00       	mov    $0x0,%edx
  800346:	eb 0e                	jmp    800356 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800348:	8b 10                	mov    (%eax),%edx
  80034a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80034d:	89 08                	mov    %ecx,(%eax)
  80034f:	8b 02                	mov    (%edx),%eax
  800351:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800356:	5d                   	pop    %ebp
  800357:	c3                   	ret    

00800358 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800358:	55                   	push   %ebp
  800359:	89 e5                	mov    %esp,%ebp
  80035b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80035e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800361:	8b 10                	mov    (%eax),%edx
  800363:	3b 50 04             	cmp    0x4(%eax),%edx
  800366:	73 08                	jae    800370 <sprintputch+0x18>
		*b->buf++ = ch;
  800368:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80036b:	88 0a                	mov    %cl,(%edx)
  80036d:	42                   	inc    %edx
  80036e:	89 10                	mov    %edx,(%eax)
}
  800370:	5d                   	pop    %ebp
  800371:	c3                   	ret    

00800372 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800372:	55                   	push   %ebp
  800373:	89 e5                	mov    %esp,%ebp
  800375:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800378:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80037b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80037f:	8b 45 10             	mov    0x10(%ebp),%eax
  800382:	89 44 24 08          	mov    %eax,0x8(%esp)
  800386:	8b 45 0c             	mov    0xc(%ebp),%eax
  800389:	89 44 24 04          	mov    %eax,0x4(%esp)
  80038d:	8b 45 08             	mov    0x8(%ebp),%eax
  800390:	89 04 24             	mov    %eax,(%esp)
  800393:	e8 02 00 00 00       	call   80039a <vprintfmt>
	va_end(ap);
}
  800398:	c9                   	leave  
  800399:	c3                   	ret    

0080039a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80039a:	55                   	push   %ebp
  80039b:	89 e5                	mov    %esp,%ebp
  80039d:	57                   	push   %edi
  80039e:	56                   	push   %esi
  80039f:	53                   	push   %ebx
  8003a0:	83 ec 4c             	sub    $0x4c,%esp
  8003a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003a6:	8b 75 10             	mov    0x10(%ebp),%esi
  8003a9:	eb 12                	jmp    8003bd <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003ab:	85 c0                	test   %eax,%eax
  8003ad:	0f 84 6b 03 00 00    	je     80071e <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8003b3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003b7:	89 04 24             	mov    %eax,(%esp)
  8003ba:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003bd:	0f b6 06             	movzbl (%esi),%eax
  8003c0:	46                   	inc    %esi
  8003c1:	83 f8 25             	cmp    $0x25,%eax
  8003c4:	75 e5                	jne    8003ab <vprintfmt+0x11>
  8003c6:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003ca:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8003d1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003d6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003dd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003e2:	eb 26                	jmp    80040a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e4:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003e7:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8003eb:	eb 1d                	jmp    80040a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ed:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003f0:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8003f4:	eb 14                	jmp    80040a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003f9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800400:	eb 08                	jmp    80040a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800402:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800405:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040a:	0f b6 06             	movzbl (%esi),%eax
  80040d:	8d 56 01             	lea    0x1(%esi),%edx
  800410:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800413:	8a 16                	mov    (%esi),%dl
  800415:	83 ea 23             	sub    $0x23,%edx
  800418:	80 fa 55             	cmp    $0x55,%dl
  80041b:	0f 87 e1 02 00 00    	ja     800702 <vprintfmt+0x368>
  800421:	0f b6 d2             	movzbl %dl,%edx
  800424:	ff 24 95 a0 13 80 00 	jmp    *0x8013a0(,%edx,4)
  80042b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80042e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800433:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800436:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80043a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80043d:	8d 50 d0             	lea    -0x30(%eax),%edx
  800440:	83 fa 09             	cmp    $0x9,%edx
  800443:	77 2a                	ja     80046f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800445:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800446:	eb eb                	jmp    800433 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800448:	8b 45 14             	mov    0x14(%ebp),%eax
  80044b:	8d 50 04             	lea    0x4(%eax),%edx
  80044e:	89 55 14             	mov    %edx,0x14(%ebp)
  800451:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800453:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800456:	eb 17                	jmp    80046f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800458:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80045c:	78 98                	js     8003f6 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800461:	eb a7                	jmp    80040a <vprintfmt+0x70>
  800463:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800466:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80046d:	eb 9b                	jmp    80040a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80046f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800473:	79 95                	jns    80040a <vprintfmt+0x70>
  800475:	eb 8b                	jmp    800402 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800477:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800478:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80047b:	eb 8d                	jmp    80040a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80047d:	8b 45 14             	mov    0x14(%ebp),%eax
  800480:	8d 50 04             	lea    0x4(%eax),%edx
  800483:	89 55 14             	mov    %edx,0x14(%ebp)
  800486:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80048a:	8b 00                	mov    (%eax),%eax
  80048c:	89 04 24             	mov    %eax,(%esp)
  80048f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800492:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800495:	e9 23 ff ff ff       	jmp    8003bd <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80049a:	8b 45 14             	mov    0x14(%ebp),%eax
  80049d:	8d 50 04             	lea    0x4(%eax),%edx
  8004a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a3:	8b 00                	mov    (%eax),%eax
  8004a5:	85 c0                	test   %eax,%eax
  8004a7:	79 02                	jns    8004ab <vprintfmt+0x111>
  8004a9:	f7 d8                	neg    %eax
  8004ab:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004ad:	83 f8 11             	cmp    $0x11,%eax
  8004b0:	7f 0b                	jg     8004bd <vprintfmt+0x123>
  8004b2:	8b 04 85 00 15 80 00 	mov    0x801500(,%eax,4),%eax
  8004b9:	85 c0                	test   %eax,%eax
  8004bb:	75 23                	jne    8004e0 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004bd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004c1:	c7 44 24 08 73 12 80 	movl   $0x801273,0x8(%esp)
  8004c8:	00 
  8004c9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8004d0:	89 04 24             	mov    %eax,(%esp)
  8004d3:	e8 9a fe ff ff       	call   800372 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d8:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004db:	e9 dd fe ff ff       	jmp    8003bd <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8004e0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004e4:	c7 44 24 08 7c 12 80 	movl   $0x80127c,0x8(%esp)
  8004eb:	00 
  8004ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8004f3:	89 14 24             	mov    %edx,(%esp)
  8004f6:	e8 77 fe ff ff       	call   800372 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004fe:	e9 ba fe ff ff       	jmp    8003bd <vprintfmt+0x23>
  800503:	89 f9                	mov    %edi,%ecx
  800505:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800508:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80050b:	8b 45 14             	mov    0x14(%ebp),%eax
  80050e:	8d 50 04             	lea    0x4(%eax),%edx
  800511:	89 55 14             	mov    %edx,0x14(%ebp)
  800514:	8b 30                	mov    (%eax),%esi
  800516:	85 f6                	test   %esi,%esi
  800518:	75 05                	jne    80051f <vprintfmt+0x185>
				p = "(null)";
  80051a:	be 6c 12 80 00       	mov    $0x80126c,%esi
			if (width > 0 && padc != '-')
  80051f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800523:	0f 8e 84 00 00 00    	jle    8005ad <vprintfmt+0x213>
  800529:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80052d:	74 7e                	je     8005ad <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80052f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800533:	89 34 24             	mov    %esi,(%esp)
  800536:	e8 8b 02 00 00       	call   8007c6 <strnlen>
  80053b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80053e:	29 c2                	sub    %eax,%edx
  800540:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800543:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800547:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80054a:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80054d:	89 de                	mov    %ebx,%esi
  80054f:	89 d3                	mov    %edx,%ebx
  800551:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800553:	eb 0b                	jmp    800560 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800555:	89 74 24 04          	mov    %esi,0x4(%esp)
  800559:	89 3c 24             	mov    %edi,(%esp)
  80055c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80055f:	4b                   	dec    %ebx
  800560:	85 db                	test   %ebx,%ebx
  800562:	7f f1                	jg     800555 <vprintfmt+0x1bb>
  800564:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800567:	89 f3                	mov    %esi,%ebx
  800569:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80056c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80056f:	85 c0                	test   %eax,%eax
  800571:	79 05                	jns    800578 <vprintfmt+0x1de>
  800573:	b8 00 00 00 00       	mov    $0x0,%eax
  800578:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80057b:	29 c2                	sub    %eax,%edx
  80057d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800580:	eb 2b                	jmp    8005ad <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800582:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800586:	74 18                	je     8005a0 <vprintfmt+0x206>
  800588:	8d 50 e0             	lea    -0x20(%eax),%edx
  80058b:	83 fa 5e             	cmp    $0x5e,%edx
  80058e:	76 10                	jbe    8005a0 <vprintfmt+0x206>
					putch('?', putdat);
  800590:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800594:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80059b:	ff 55 08             	call   *0x8(%ebp)
  80059e:	eb 0a                	jmp    8005aa <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8005a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a4:	89 04 24             	mov    %eax,(%esp)
  8005a7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005aa:	ff 4d e4             	decl   -0x1c(%ebp)
  8005ad:	0f be 06             	movsbl (%esi),%eax
  8005b0:	46                   	inc    %esi
  8005b1:	85 c0                	test   %eax,%eax
  8005b3:	74 21                	je     8005d6 <vprintfmt+0x23c>
  8005b5:	85 ff                	test   %edi,%edi
  8005b7:	78 c9                	js     800582 <vprintfmt+0x1e8>
  8005b9:	4f                   	dec    %edi
  8005ba:	79 c6                	jns    800582 <vprintfmt+0x1e8>
  8005bc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005bf:	89 de                	mov    %ebx,%esi
  8005c1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005c4:	eb 18                	jmp    8005de <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005ca:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005d1:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005d3:	4b                   	dec    %ebx
  8005d4:	eb 08                	jmp    8005de <vprintfmt+0x244>
  8005d6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005d9:	89 de                	mov    %ebx,%esi
  8005db:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005de:	85 db                	test   %ebx,%ebx
  8005e0:	7f e4                	jg     8005c6 <vprintfmt+0x22c>
  8005e2:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005e5:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005ea:	e9 ce fd ff ff       	jmp    8003bd <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ef:	83 f9 01             	cmp    $0x1,%ecx
  8005f2:	7e 10                	jle    800604 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8005f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f7:	8d 50 08             	lea    0x8(%eax),%edx
  8005fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fd:	8b 30                	mov    (%eax),%esi
  8005ff:	8b 78 04             	mov    0x4(%eax),%edi
  800602:	eb 26                	jmp    80062a <vprintfmt+0x290>
	else if (lflag)
  800604:	85 c9                	test   %ecx,%ecx
  800606:	74 12                	je     80061a <vprintfmt+0x280>
		return va_arg(*ap, long);
  800608:	8b 45 14             	mov    0x14(%ebp),%eax
  80060b:	8d 50 04             	lea    0x4(%eax),%edx
  80060e:	89 55 14             	mov    %edx,0x14(%ebp)
  800611:	8b 30                	mov    (%eax),%esi
  800613:	89 f7                	mov    %esi,%edi
  800615:	c1 ff 1f             	sar    $0x1f,%edi
  800618:	eb 10                	jmp    80062a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80061a:	8b 45 14             	mov    0x14(%ebp),%eax
  80061d:	8d 50 04             	lea    0x4(%eax),%edx
  800620:	89 55 14             	mov    %edx,0x14(%ebp)
  800623:	8b 30                	mov    (%eax),%esi
  800625:	89 f7                	mov    %esi,%edi
  800627:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80062a:	85 ff                	test   %edi,%edi
  80062c:	78 0a                	js     800638 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80062e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800633:	e9 8c 00 00 00       	jmp    8006c4 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800638:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80063c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800643:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800646:	f7 de                	neg    %esi
  800648:	83 d7 00             	adc    $0x0,%edi
  80064b:	f7 df                	neg    %edi
			}
			base = 10;
  80064d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800652:	eb 70                	jmp    8006c4 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800654:	89 ca                	mov    %ecx,%edx
  800656:	8d 45 14             	lea    0x14(%ebp),%eax
  800659:	e8 c0 fc ff ff       	call   80031e <getuint>
  80065e:	89 c6                	mov    %eax,%esi
  800660:	89 d7                	mov    %edx,%edi
			base = 10;
  800662:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800667:	eb 5b                	jmp    8006c4 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  800669:	89 ca                	mov    %ecx,%edx
  80066b:	8d 45 14             	lea    0x14(%ebp),%eax
  80066e:	e8 ab fc ff ff       	call   80031e <getuint>
  800673:	89 c6                	mov    %eax,%esi
  800675:	89 d7                	mov    %edx,%edi
			base = 8;
  800677:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80067c:	eb 46                	jmp    8006c4 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  80067e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800682:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800689:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80068c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800690:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800697:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80069a:	8b 45 14             	mov    0x14(%ebp),%eax
  80069d:	8d 50 04             	lea    0x4(%eax),%edx
  8006a0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006a3:	8b 30                	mov    (%eax),%esi
  8006a5:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006aa:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006af:	eb 13                	jmp    8006c4 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006b1:	89 ca                	mov    %ecx,%edx
  8006b3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b6:	e8 63 fc ff ff       	call   80031e <getuint>
  8006bb:	89 c6                	mov    %eax,%esi
  8006bd:	89 d7                	mov    %edx,%edi
			base = 16;
  8006bf:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006c4:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8006c8:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006cc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006cf:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006d3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006d7:	89 34 24             	mov    %esi,(%esp)
  8006da:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006de:	89 da                	mov    %ebx,%edx
  8006e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e3:	e8 6c fb ff ff       	call   800254 <printnum>
			break;
  8006e8:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006eb:	e9 cd fc ff ff       	jmp    8003bd <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f4:	89 04 24             	mov    %eax,(%esp)
  8006f7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006fa:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006fd:	e9 bb fc ff ff       	jmp    8003bd <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800702:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800706:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80070d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800710:	eb 01                	jmp    800713 <vprintfmt+0x379>
  800712:	4e                   	dec    %esi
  800713:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800717:	75 f9                	jne    800712 <vprintfmt+0x378>
  800719:	e9 9f fc ff ff       	jmp    8003bd <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80071e:	83 c4 4c             	add    $0x4c,%esp
  800721:	5b                   	pop    %ebx
  800722:	5e                   	pop    %esi
  800723:	5f                   	pop    %edi
  800724:	5d                   	pop    %ebp
  800725:	c3                   	ret    

00800726 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800726:	55                   	push   %ebp
  800727:	89 e5                	mov    %esp,%ebp
  800729:	83 ec 28             	sub    $0x28,%esp
  80072c:	8b 45 08             	mov    0x8(%ebp),%eax
  80072f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800732:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800735:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800739:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80073c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800743:	85 c0                	test   %eax,%eax
  800745:	74 30                	je     800777 <vsnprintf+0x51>
  800747:	85 d2                	test   %edx,%edx
  800749:	7e 33                	jle    80077e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80074b:	8b 45 14             	mov    0x14(%ebp),%eax
  80074e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800752:	8b 45 10             	mov    0x10(%ebp),%eax
  800755:	89 44 24 08          	mov    %eax,0x8(%esp)
  800759:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80075c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800760:	c7 04 24 58 03 80 00 	movl   $0x800358,(%esp)
  800767:	e8 2e fc ff ff       	call   80039a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80076c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80076f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800772:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800775:	eb 0c                	jmp    800783 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800777:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80077c:	eb 05                	jmp    800783 <vsnprintf+0x5d>
  80077e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800783:	c9                   	leave  
  800784:	c3                   	ret    

00800785 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800785:	55                   	push   %ebp
  800786:	89 e5                	mov    %esp,%ebp
  800788:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80078b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80078e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800792:	8b 45 10             	mov    0x10(%ebp),%eax
  800795:	89 44 24 08          	mov    %eax,0x8(%esp)
  800799:	8b 45 0c             	mov    0xc(%ebp),%eax
  80079c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a3:	89 04 24             	mov    %eax,(%esp)
  8007a6:	e8 7b ff ff ff       	call   800726 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007ab:	c9                   	leave  
  8007ac:	c3                   	ret    
  8007ad:	00 00                	add    %al,(%eax)
	...

008007b0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007b0:	55                   	push   %ebp
  8007b1:	89 e5                	mov    %esp,%ebp
  8007b3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007bb:	eb 01                	jmp    8007be <strlen+0xe>
		n++;
  8007bd:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007be:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007c2:	75 f9                	jne    8007bd <strlen+0xd>
		n++;
	return n;
}
  8007c4:	5d                   	pop    %ebp
  8007c5:	c3                   	ret    

008007c6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007c6:	55                   	push   %ebp
  8007c7:	89 e5                	mov    %esp,%ebp
  8007c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8007cc:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d4:	eb 01                	jmp    8007d7 <strnlen+0x11>
		n++;
  8007d6:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d7:	39 d0                	cmp    %edx,%eax
  8007d9:	74 06                	je     8007e1 <strnlen+0x1b>
  8007db:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007df:	75 f5                	jne    8007d6 <strnlen+0x10>
		n++;
	return n;
}
  8007e1:	5d                   	pop    %ebp
  8007e2:	c3                   	ret    

008007e3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007e3:	55                   	push   %ebp
  8007e4:	89 e5                	mov    %esp,%ebp
  8007e6:	53                   	push   %ebx
  8007e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8007f2:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007f5:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007f8:	42                   	inc    %edx
  8007f9:	84 c9                	test   %cl,%cl
  8007fb:	75 f5                	jne    8007f2 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007fd:	5b                   	pop    %ebx
  8007fe:	5d                   	pop    %ebp
  8007ff:	c3                   	ret    

00800800 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	53                   	push   %ebx
  800804:	83 ec 08             	sub    $0x8,%esp
  800807:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80080a:	89 1c 24             	mov    %ebx,(%esp)
  80080d:	e8 9e ff ff ff       	call   8007b0 <strlen>
	strcpy(dst + len, src);
  800812:	8b 55 0c             	mov    0xc(%ebp),%edx
  800815:	89 54 24 04          	mov    %edx,0x4(%esp)
  800819:	01 d8                	add    %ebx,%eax
  80081b:	89 04 24             	mov    %eax,(%esp)
  80081e:	e8 c0 ff ff ff       	call   8007e3 <strcpy>
	return dst;
}
  800823:	89 d8                	mov    %ebx,%eax
  800825:	83 c4 08             	add    $0x8,%esp
  800828:	5b                   	pop    %ebx
  800829:	5d                   	pop    %ebp
  80082a:	c3                   	ret    

0080082b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80082b:	55                   	push   %ebp
  80082c:	89 e5                	mov    %esp,%ebp
  80082e:	56                   	push   %esi
  80082f:	53                   	push   %ebx
  800830:	8b 45 08             	mov    0x8(%ebp),%eax
  800833:	8b 55 0c             	mov    0xc(%ebp),%edx
  800836:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800839:	b9 00 00 00 00       	mov    $0x0,%ecx
  80083e:	eb 0c                	jmp    80084c <strncpy+0x21>
		*dst++ = *src;
  800840:	8a 1a                	mov    (%edx),%bl
  800842:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800845:	80 3a 01             	cmpb   $0x1,(%edx)
  800848:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80084b:	41                   	inc    %ecx
  80084c:	39 f1                	cmp    %esi,%ecx
  80084e:	75 f0                	jne    800840 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800850:	5b                   	pop    %ebx
  800851:	5e                   	pop    %esi
  800852:	5d                   	pop    %ebp
  800853:	c3                   	ret    

00800854 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800854:	55                   	push   %ebp
  800855:	89 e5                	mov    %esp,%ebp
  800857:	56                   	push   %esi
  800858:	53                   	push   %ebx
  800859:	8b 75 08             	mov    0x8(%ebp),%esi
  80085c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80085f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800862:	85 d2                	test   %edx,%edx
  800864:	75 0a                	jne    800870 <strlcpy+0x1c>
  800866:	89 f0                	mov    %esi,%eax
  800868:	eb 1a                	jmp    800884 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80086a:	88 18                	mov    %bl,(%eax)
  80086c:	40                   	inc    %eax
  80086d:	41                   	inc    %ecx
  80086e:	eb 02                	jmp    800872 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800870:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800872:	4a                   	dec    %edx
  800873:	74 0a                	je     80087f <strlcpy+0x2b>
  800875:	8a 19                	mov    (%ecx),%bl
  800877:	84 db                	test   %bl,%bl
  800879:	75 ef                	jne    80086a <strlcpy+0x16>
  80087b:	89 c2                	mov    %eax,%edx
  80087d:	eb 02                	jmp    800881 <strlcpy+0x2d>
  80087f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800881:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800884:	29 f0                	sub    %esi,%eax
}
  800886:	5b                   	pop    %ebx
  800887:	5e                   	pop    %esi
  800888:	5d                   	pop    %ebp
  800889:	c3                   	ret    

0080088a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800890:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800893:	eb 02                	jmp    800897 <strcmp+0xd>
		p++, q++;
  800895:	41                   	inc    %ecx
  800896:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800897:	8a 01                	mov    (%ecx),%al
  800899:	84 c0                	test   %al,%al
  80089b:	74 04                	je     8008a1 <strcmp+0x17>
  80089d:	3a 02                	cmp    (%edx),%al
  80089f:	74 f4                	je     800895 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a1:	0f b6 c0             	movzbl %al,%eax
  8008a4:	0f b6 12             	movzbl (%edx),%edx
  8008a7:	29 d0                	sub    %edx,%eax
}
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    

008008ab <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	53                   	push   %ebx
  8008af:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008b5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008b8:	eb 03                	jmp    8008bd <strncmp+0x12>
		n--, p++, q++;
  8008ba:	4a                   	dec    %edx
  8008bb:	40                   	inc    %eax
  8008bc:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008bd:	85 d2                	test   %edx,%edx
  8008bf:	74 14                	je     8008d5 <strncmp+0x2a>
  8008c1:	8a 18                	mov    (%eax),%bl
  8008c3:	84 db                	test   %bl,%bl
  8008c5:	74 04                	je     8008cb <strncmp+0x20>
  8008c7:	3a 19                	cmp    (%ecx),%bl
  8008c9:	74 ef                	je     8008ba <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008cb:	0f b6 00             	movzbl (%eax),%eax
  8008ce:	0f b6 11             	movzbl (%ecx),%edx
  8008d1:	29 d0                	sub    %edx,%eax
  8008d3:	eb 05                	jmp    8008da <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008d5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008da:	5b                   	pop    %ebx
  8008db:	5d                   	pop    %ebp
  8008dc:	c3                   	ret    

008008dd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008dd:	55                   	push   %ebp
  8008de:	89 e5                	mov    %esp,%ebp
  8008e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008e6:	eb 05                	jmp    8008ed <strchr+0x10>
		if (*s == c)
  8008e8:	38 ca                	cmp    %cl,%dl
  8008ea:	74 0c                	je     8008f8 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008ec:	40                   	inc    %eax
  8008ed:	8a 10                	mov    (%eax),%dl
  8008ef:	84 d2                	test   %dl,%dl
  8008f1:	75 f5                	jne    8008e8 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8008f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800900:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800903:	eb 05                	jmp    80090a <strfind+0x10>
		if (*s == c)
  800905:	38 ca                	cmp    %cl,%dl
  800907:	74 07                	je     800910 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800909:	40                   	inc    %eax
  80090a:	8a 10                	mov    (%eax),%dl
  80090c:	84 d2                	test   %dl,%dl
  80090e:	75 f5                	jne    800905 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800910:	5d                   	pop    %ebp
  800911:	c3                   	ret    

00800912 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	57                   	push   %edi
  800916:	56                   	push   %esi
  800917:	53                   	push   %ebx
  800918:	8b 7d 08             	mov    0x8(%ebp),%edi
  80091b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80091e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800921:	85 c9                	test   %ecx,%ecx
  800923:	74 30                	je     800955 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800925:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80092b:	75 25                	jne    800952 <memset+0x40>
  80092d:	f6 c1 03             	test   $0x3,%cl
  800930:	75 20                	jne    800952 <memset+0x40>
		c &= 0xFF;
  800932:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800935:	89 d3                	mov    %edx,%ebx
  800937:	c1 e3 08             	shl    $0x8,%ebx
  80093a:	89 d6                	mov    %edx,%esi
  80093c:	c1 e6 18             	shl    $0x18,%esi
  80093f:	89 d0                	mov    %edx,%eax
  800941:	c1 e0 10             	shl    $0x10,%eax
  800944:	09 f0                	or     %esi,%eax
  800946:	09 d0                	or     %edx,%eax
  800948:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80094a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80094d:	fc                   	cld    
  80094e:	f3 ab                	rep stos %eax,%es:(%edi)
  800950:	eb 03                	jmp    800955 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800952:	fc                   	cld    
  800953:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800955:	89 f8                	mov    %edi,%eax
  800957:	5b                   	pop    %ebx
  800958:	5e                   	pop    %esi
  800959:	5f                   	pop    %edi
  80095a:	5d                   	pop    %ebp
  80095b:	c3                   	ret    

0080095c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80095c:	55                   	push   %ebp
  80095d:	89 e5                	mov    %esp,%ebp
  80095f:	57                   	push   %edi
  800960:	56                   	push   %esi
  800961:	8b 45 08             	mov    0x8(%ebp),%eax
  800964:	8b 75 0c             	mov    0xc(%ebp),%esi
  800967:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80096a:	39 c6                	cmp    %eax,%esi
  80096c:	73 34                	jae    8009a2 <memmove+0x46>
  80096e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800971:	39 d0                	cmp    %edx,%eax
  800973:	73 2d                	jae    8009a2 <memmove+0x46>
		s += n;
		d += n;
  800975:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800978:	f6 c2 03             	test   $0x3,%dl
  80097b:	75 1b                	jne    800998 <memmove+0x3c>
  80097d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800983:	75 13                	jne    800998 <memmove+0x3c>
  800985:	f6 c1 03             	test   $0x3,%cl
  800988:	75 0e                	jne    800998 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80098a:	83 ef 04             	sub    $0x4,%edi
  80098d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800990:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800993:	fd                   	std    
  800994:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800996:	eb 07                	jmp    80099f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800998:	4f                   	dec    %edi
  800999:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80099c:	fd                   	std    
  80099d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80099f:	fc                   	cld    
  8009a0:	eb 20                	jmp    8009c2 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009a8:	75 13                	jne    8009bd <memmove+0x61>
  8009aa:	a8 03                	test   $0x3,%al
  8009ac:	75 0f                	jne    8009bd <memmove+0x61>
  8009ae:	f6 c1 03             	test   $0x3,%cl
  8009b1:	75 0a                	jne    8009bd <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009b3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009b6:	89 c7                	mov    %eax,%edi
  8009b8:	fc                   	cld    
  8009b9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009bb:	eb 05                	jmp    8009c2 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009bd:	89 c7                	mov    %eax,%edi
  8009bf:	fc                   	cld    
  8009c0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009c2:	5e                   	pop    %esi
  8009c3:	5f                   	pop    %edi
  8009c4:	5d                   	pop    %ebp
  8009c5:	c3                   	ret    

008009c6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
  8009c9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009cc:	8b 45 10             	mov    0x10(%ebp),%eax
  8009cf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009da:	8b 45 08             	mov    0x8(%ebp),%eax
  8009dd:	89 04 24             	mov    %eax,(%esp)
  8009e0:	e8 77 ff ff ff       	call   80095c <memmove>
}
  8009e5:	c9                   	leave  
  8009e6:	c3                   	ret    

008009e7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009e7:	55                   	push   %ebp
  8009e8:	89 e5                	mov    %esp,%ebp
  8009ea:	57                   	push   %edi
  8009eb:	56                   	push   %esi
  8009ec:	53                   	push   %ebx
  8009ed:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009f0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009f3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8009fb:	eb 16                	jmp    800a13 <memcmp+0x2c>
		if (*s1 != *s2)
  8009fd:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a00:	42                   	inc    %edx
  800a01:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a05:	38 c8                	cmp    %cl,%al
  800a07:	74 0a                	je     800a13 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a09:	0f b6 c0             	movzbl %al,%eax
  800a0c:	0f b6 c9             	movzbl %cl,%ecx
  800a0f:	29 c8                	sub    %ecx,%eax
  800a11:	eb 09                	jmp    800a1c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a13:	39 da                	cmp    %ebx,%edx
  800a15:	75 e6                	jne    8009fd <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a17:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a1c:	5b                   	pop    %ebx
  800a1d:	5e                   	pop    %esi
  800a1e:	5f                   	pop    %edi
  800a1f:	5d                   	pop    %ebp
  800a20:	c3                   	ret    

00800a21 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a21:	55                   	push   %ebp
  800a22:	89 e5                	mov    %esp,%ebp
  800a24:	8b 45 08             	mov    0x8(%ebp),%eax
  800a27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a2a:	89 c2                	mov    %eax,%edx
  800a2c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a2f:	eb 05                	jmp    800a36 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a31:	38 08                	cmp    %cl,(%eax)
  800a33:	74 05                	je     800a3a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a35:	40                   	inc    %eax
  800a36:	39 d0                	cmp    %edx,%eax
  800a38:	72 f7                	jb     800a31 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a3a:	5d                   	pop    %ebp
  800a3b:	c3                   	ret    

00800a3c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a3c:	55                   	push   %ebp
  800a3d:	89 e5                	mov    %esp,%ebp
  800a3f:	57                   	push   %edi
  800a40:	56                   	push   %esi
  800a41:	53                   	push   %ebx
  800a42:	8b 55 08             	mov    0x8(%ebp),%edx
  800a45:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a48:	eb 01                	jmp    800a4b <strtol+0xf>
		s++;
  800a4a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a4b:	8a 02                	mov    (%edx),%al
  800a4d:	3c 20                	cmp    $0x20,%al
  800a4f:	74 f9                	je     800a4a <strtol+0xe>
  800a51:	3c 09                	cmp    $0x9,%al
  800a53:	74 f5                	je     800a4a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a55:	3c 2b                	cmp    $0x2b,%al
  800a57:	75 08                	jne    800a61 <strtol+0x25>
		s++;
  800a59:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a5a:	bf 00 00 00 00       	mov    $0x0,%edi
  800a5f:	eb 13                	jmp    800a74 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a61:	3c 2d                	cmp    $0x2d,%al
  800a63:	75 0a                	jne    800a6f <strtol+0x33>
		s++, neg = 1;
  800a65:	8d 52 01             	lea    0x1(%edx),%edx
  800a68:	bf 01 00 00 00       	mov    $0x1,%edi
  800a6d:	eb 05                	jmp    800a74 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a6f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a74:	85 db                	test   %ebx,%ebx
  800a76:	74 05                	je     800a7d <strtol+0x41>
  800a78:	83 fb 10             	cmp    $0x10,%ebx
  800a7b:	75 28                	jne    800aa5 <strtol+0x69>
  800a7d:	8a 02                	mov    (%edx),%al
  800a7f:	3c 30                	cmp    $0x30,%al
  800a81:	75 10                	jne    800a93 <strtol+0x57>
  800a83:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a87:	75 0a                	jne    800a93 <strtol+0x57>
		s += 2, base = 16;
  800a89:	83 c2 02             	add    $0x2,%edx
  800a8c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a91:	eb 12                	jmp    800aa5 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a93:	85 db                	test   %ebx,%ebx
  800a95:	75 0e                	jne    800aa5 <strtol+0x69>
  800a97:	3c 30                	cmp    $0x30,%al
  800a99:	75 05                	jne    800aa0 <strtol+0x64>
		s++, base = 8;
  800a9b:	42                   	inc    %edx
  800a9c:	b3 08                	mov    $0x8,%bl
  800a9e:	eb 05                	jmp    800aa5 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800aa0:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800aa5:	b8 00 00 00 00       	mov    $0x0,%eax
  800aaa:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800aac:	8a 0a                	mov    (%edx),%cl
  800aae:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ab1:	80 fb 09             	cmp    $0x9,%bl
  800ab4:	77 08                	ja     800abe <strtol+0x82>
			dig = *s - '0';
  800ab6:	0f be c9             	movsbl %cl,%ecx
  800ab9:	83 e9 30             	sub    $0x30,%ecx
  800abc:	eb 1e                	jmp    800adc <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800abe:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ac1:	80 fb 19             	cmp    $0x19,%bl
  800ac4:	77 08                	ja     800ace <strtol+0x92>
			dig = *s - 'a' + 10;
  800ac6:	0f be c9             	movsbl %cl,%ecx
  800ac9:	83 e9 57             	sub    $0x57,%ecx
  800acc:	eb 0e                	jmp    800adc <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800ace:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800ad1:	80 fb 19             	cmp    $0x19,%bl
  800ad4:	77 12                	ja     800ae8 <strtol+0xac>
			dig = *s - 'A' + 10;
  800ad6:	0f be c9             	movsbl %cl,%ecx
  800ad9:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800adc:	39 f1                	cmp    %esi,%ecx
  800ade:	7d 0c                	jge    800aec <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800ae0:	42                   	inc    %edx
  800ae1:	0f af c6             	imul   %esi,%eax
  800ae4:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800ae6:	eb c4                	jmp    800aac <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ae8:	89 c1                	mov    %eax,%ecx
  800aea:	eb 02                	jmp    800aee <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800aec:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800aee:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800af2:	74 05                	je     800af9 <strtol+0xbd>
		*endptr = (char *) s;
  800af4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800af7:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800af9:	85 ff                	test   %edi,%edi
  800afb:	74 04                	je     800b01 <strtol+0xc5>
  800afd:	89 c8                	mov    %ecx,%eax
  800aff:	f7 d8                	neg    %eax
}
  800b01:	5b                   	pop    %ebx
  800b02:	5e                   	pop    %esi
  800b03:	5f                   	pop    %edi
  800b04:	5d                   	pop    %ebp
  800b05:	c3                   	ret    
	...

00800b08 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b08:	55                   	push   %ebp
  800b09:	89 e5                	mov    %esp,%ebp
  800b0b:	57                   	push   %edi
  800b0c:	56                   	push   %esi
  800b0d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b16:	8b 55 08             	mov    0x8(%ebp),%edx
  800b19:	89 c3                	mov    %eax,%ebx
  800b1b:	89 c7                	mov    %eax,%edi
  800b1d:	89 c6                	mov    %eax,%esi
  800b1f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b21:	5b                   	pop    %ebx
  800b22:	5e                   	pop    %esi
  800b23:	5f                   	pop    %edi
  800b24:	5d                   	pop    %ebp
  800b25:	c3                   	ret    

00800b26 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b26:	55                   	push   %ebp
  800b27:	89 e5                	mov    %esp,%ebp
  800b29:	57                   	push   %edi
  800b2a:	56                   	push   %esi
  800b2b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b31:	b8 01 00 00 00       	mov    $0x1,%eax
  800b36:	89 d1                	mov    %edx,%ecx
  800b38:	89 d3                	mov    %edx,%ebx
  800b3a:	89 d7                	mov    %edx,%edi
  800b3c:	89 d6                	mov    %edx,%esi
  800b3e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b40:	5b                   	pop    %ebx
  800b41:	5e                   	pop    %esi
  800b42:	5f                   	pop    %edi
  800b43:	5d                   	pop    %ebp
  800b44:	c3                   	ret    

00800b45 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b45:	55                   	push   %ebp
  800b46:	89 e5                	mov    %esp,%ebp
  800b48:	57                   	push   %edi
  800b49:	56                   	push   %esi
  800b4a:	53                   	push   %ebx
  800b4b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b53:	b8 03 00 00 00       	mov    $0x3,%eax
  800b58:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5b:	89 cb                	mov    %ecx,%ebx
  800b5d:	89 cf                	mov    %ecx,%edi
  800b5f:	89 ce                	mov    %ecx,%esi
  800b61:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b63:	85 c0                	test   %eax,%eax
  800b65:	7e 28                	jle    800b8f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b67:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b6b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b72:	00 
  800b73:	c7 44 24 08 68 15 80 	movl   $0x801568,0x8(%esp)
  800b7a:	00 
  800b7b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b82:	00 
  800b83:	c7 04 24 85 15 80 00 	movl   $0x801585,(%esp)
  800b8a:	e8 b1 f5 ff ff       	call   800140 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b8f:	83 c4 2c             	add    $0x2c,%esp
  800b92:	5b                   	pop    %ebx
  800b93:	5e                   	pop    %esi
  800b94:	5f                   	pop    %edi
  800b95:	5d                   	pop    %ebp
  800b96:	c3                   	ret    

00800b97 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b97:	55                   	push   %ebp
  800b98:	89 e5                	mov    %esp,%ebp
  800b9a:	57                   	push   %edi
  800b9b:	56                   	push   %esi
  800b9c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9d:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba2:	b8 02 00 00 00       	mov    $0x2,%eax
  800ba7:	89 d1                	mov    %edx,%ecx
  800ba9:	89 d3                	mov    %edx,%ebx
  800bab:	89 d7                	mov    %edx,%edi
  800bad:	89 d6                	mov    %edx,%esi
  800baf:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bb1:	5b                   	pop    %ebx
  800bb2:	5e                   	pop    %esi
  800bb3:	5f                   	pop    %edi
  800bb4:	5d                   	pop    %ebp
  800bb5:	c3                   	ret    

00800bb6 <sys_yield>:

void
sys_yield(void)
{
  800bb6:	55                   	push   %ebp
  800bb7:	89 e5                	mov    %esp,%ebp
  800bb9:	57                   	push   %edi
  800bba:	56                   	push   %esi
  800bbb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbc:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc1:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bc6:	89 d1                	mov    %edx,%ecx
  800bc8:	89 d3                	mov    %edx,%ebx
  800bca:	89 d7                	mov    %edx,%edi
  800bcc:	89 d6                	mov    %edx,%esi
  800bce:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bd0:	5b                   	pop    %ebx
  800bd1:	5e                   	pop    %esi
  800bd2:	5f                   	pop    %edi
  800bd3:	5d                   	pop    %ebp
  800bd4:	c3                   	ret    

00800bd5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bd5:	55                   	push   %ebp
  800bd6:	89 e5                	mov    %esp,%ebp
  800bd8:	57                   	push   %edi
  800bd9:	56                   	push   %esi
  800bda:	53                   	push   %ebx
  800bdb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bde:	be 00 00 00 00       	mov    $0x0,%esi
  800be3:	b8 04 00 00 00       	mov    $0x4,%eax
  800be8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800beb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bee:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf1:	89 f7                	mov    %esi,%edi
  800bf3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bf5:	85 c0                	test   %eax,%eax
  800bf7:	7e 28                	jle    800c21 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bfd:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c04:	00 
  800c05:	c7 44 24 08 68 15 80 	movl   $0x801568,0x8(%esp)
  800c0c:	00 
  800c0d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c14:	00 
  800c15:	c7 04 24 85 15 80 00 	movl   $0x801585,(%esp)
  800c1c:	e8 1f f5 ff ff       	call   800140 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c21:	83 c4 2c             	add    $0x2c,%esp
  800c24:	5b                   	pop    %ebx
  800c25:	5e                   	pop    %esi
  800c26:	5f                   	pop    %edi
  800c27:	5d                   	pop    %ebp
  800c28:	c3                   	ret    

00800c29 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800c32:	b8 05 00 00 00       	mov    $0x5,%eax
  800c37:	8b 75 18             	mov    0x18(%ebp),%esi
  800c3a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c3d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c43:	8b 55 08             	mov    0x8(%ebp),%edx
  800c46:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c48:	85 c0                	test   %eax,%eax
  800c4a:	7e 28                	jle    800c74 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c50:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c57:	00 
  800c58:	c7 44 24 08 68 15 80 	movl   $0x801568,0x8(%esp)
  800c5f:	00 
  800c60:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c67:	00 
  800c68:	c7 04 24 85 15 80 00 	movl   $0x801585,(%esp)
  800c6f:	e8 cc f4 ff ff       	call   800140 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c74:	83 c4 2c             	add    $0x2c,%esp
  800c77:	5b                   	pop    %ebx
  800c78:	5e                   	pop    %esi
  800c79:	5f                   	pop    %edi
  800c7a:	5d                   	pop    %ebp
  800c7b:	c3                   	ret    

00800c7c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c7c:	55                   	push   %ebp
  800c7d:	89 e5                	mov    %esp,%ebp
  800c7f:	57                   	push   %edi
  800c80:	56                   	push   %esi
  800c81:	53                   	push   %ebx
  800c82:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c85:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8a:	b8 06 00 00 00       	mov    $0x6,%eax
  800c8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c92:	8b 55 08             	mov    0x8(%ebp),%edx
  800c95:	89 df                	mov    %ebx,%edi
  800c97:	89 de                	mov    %ebx,%esi
  800c99:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c9b:	85 c0                	test   %eax,%eax
  800c9d:	7e 28                	jle    800cc7 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ca3:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800caa:	00 
  800cab:	c7 44 24 08 68 15 80 	movl   $0x801568,0x8(%esp)
  800cb2:	00 
  800cb3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cba:	00 
  800cbb:	c7 04 24 85 15 80 00 	movl   $0x801585,(%esp)
  800cc2:	e8 79 f4 ff ff       	call   800140 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cc7:	83 c4 2c             	add    $0x2c,%esp
  800cca:	5b                   	pop    %ebx
  800ccb:	5e                   	pop    %esi
  800ccc:	5f                   	pop    %edi
  800ccd:	5d                   	pop    %ebp
  800cce:	c3                   	ret    

00800ccf <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ccf:	55                   	push   %ebp
  800cd0:	89 e5                	mov    %esp,%ebp
  800cd2:	57                   	push   %edi
  800cd3:	56                   	push   %esi
  800cd4:	53                   	push   %ebx
  800cd5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cdd:	b8 08 00 00 00       	mov    $0x8,%eax
  800ce2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce8:	89 df                	mov    %ebx,%edi
  800cea:	89 de                	mov    %ebx,%esi
  800cec:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cee:	85 c0                	test   %eax,%eax
  800cf0:	7e 28                	jle    800d1a <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cf6:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800cfd:	00 
  800cfe:	c7 44 24 08 68 15 80 	movl   $0x801568,0x8(%esp)
  800d05:	00 
  800d06:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d0d:	00 
  800d0e:	c7 04 24 85 15 80 00 	movl   $0x801585,(%esp)
  800d15:	e8 26 f4 ff ff       	call   800140 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d1a:	83 c4 2c             	add    $0x2c,%esp
  800d1d:	5b                   	pop    %ebx
  800d1e:	5e                   	pop    %esi
  800d1f:	5f                   	pop    %edi
  800d20:	5d                   	pop    %ebp
  800d21:	c3                   	ret    

00800d22 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d22:	55                   	push   %ebp
  800d23:	89 e5                	mov    %esp,%ebp
  800d25:	57                   	push   %edi
  800d26:	56                   	push   %esi
  800d27:	53                   	push   %ebx
  800d28:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d30:	b8 09 00 00 00       	mov    $0x9,%eax
  800d35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d38:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3b:	89 df                	mov    %ebx,%edi
  800d3d:	89 de                	mov    %ebx,%esi
  800d3f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d41:	85 c0                	test   %eax,%eax
  800d43:	7e 28                	jle    800d6d <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d45:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d49:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d50:	00 
  800d51:	c7 44 24 08 68 15 80 	movl   $0x801568,0x8(%esp)
  800d58:	00 
  800d59:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d60:	00 
  800d61:	c7 04 24 85 15 80 00 	movl   $0x801585,(%esp)
  800d68:	e8 d3 f3 ff ff       	call   800140 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d6d:	83 c4 2c             	add    $0x2c,%esp
  800d70:	5b                   	pop    %ebx
  800d71:	5e                   	pop    %esi
  800d72:	5f                   	pop    %edi
  800d73:	5d                   	pop    %ebp
  800d74:	c3                   	ret    

00800d75 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d75:	55                   	push   %ebp
  800d76:	89 e5                	mov    %esp,%ebp
  800d78:	57                   	push   %edi
  800d79:	56                   	push   %esi
  800d7a:	53                   	push   %ebx
  800d7b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d83:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8e:	89 df                	mov    %ebx,%edi
  800d90:	89 de                	mov    %ebx,%esi
  800d92:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d94:	85 c0                	test   %eax,%eax
  800d96:	7e 28                	jle    800dc0 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d98:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d9c:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800da3:	00 
  800da4:	c7 44 24 08 68 15 80 	movl   $0x801568,0x8(%esp)
  800dab:	00 
  800dac:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800db3:	00 
  800db4:	c7 04 24 85 15 80 00 	movl   $0x801585,(%esp)
  800dbb:	e8 80 f3 ff ff       	call   800140 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dc0:	83 c4 2c             	add    $0x2c,%esp
  800dc3:	5b                   	pop    %ebx
  800dc4:	5e                   	pop    %esi
  800dc5:	5f                   	pop    %edi
  800dc6:	5d                   	pop    %ebp
  800dc7:	c3                   	ret    

00800dc8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	57                   	push   %edi
  800dcc:	56                   	push   %esi
  800dcd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dce:	be 00 00 00 00       	mov    $0x0,%esi
  800dd3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dd8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ddb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de1:	8b 55 08             	mov    0x8(%ebp),%edx
  800de4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800de6:	5b                   	pop    %ebx
  800de7:	5e                   	pop    %esi
  800de8:	5f                   	pop    %edi
  800de9:	5d                   	pop    %ebp
  800dea:	c3                   	ret    

00800deb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800deb:	55                   	push   %ebp
  800dec:	89 e5                	mov    %esp,%ebp
  800dee:	57                   	push   %edi
  800def:	56                   	push   %esi
  800df0:	53                   	push   %ebx
  800df1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800df9:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800e01:	89 cb                	mov    %ecx,%ebx
  800e03:	89 cf                	mov    %ecx,%edi
  800e05:	89 ce                	mov    %ecx,%esi
  800e07:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e09:	85 c0                	test   %eax,%eax
  800e0b:	7e 28                	jle    800e35 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e11:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e18:	00 
  800e19:	c7 44 24 08 68 15 80 	movl   $0x801568,0x8(%esp)
  800e20:	00 
  800e21:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e28:	00 
  800e29:	c7 04 24 85 15 80 00 	movl   $0x801585,(%esp)
  800e30:	e8 0b f3 ff ff       	call   800140 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e35:	83 c4 2c             	add    $0x2c,%esp
  800e38:	5b                   	pop    %ebx
  800e39:	5e                   	pop    %esi
  800e3a:	5f                   	pop    %edi
  800e3b:	5d                   	pop    %ebp
  800e3c:	c3                   	ret    

00800e3d <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e3d:	55                   	push   %ebp
  800e3e:	89 e5                	mov    %esp,%ebp
  800e40:	57                   	push   %edi
  800e41:	56                   	push   %esi
  800e42:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e43:	ba 00 00 00 00       	mov    $0x0,%edx
  800e48:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e4d:	89 d1                	mov    %edx,%ecx
  800e4f:	89 d3                	mov    %edx,%ebx
  800e51:	89 d7                	mov    %edx,%edi
  800e53:	89 d6                	mov    %edx,%esi
  800e55:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e57:	5b                   	pop    %ebx
  800e58:	5e                   	pop    %esi
  800e59:	5f                   	pop    %edi
  800e5a:	5d                   	pop    %ebp
  800e5b:	c3                   	ret    

00800e5c <sys_e1000_transmit>:

int 
sys_e1000_transmit(char* pck, size_t length){
  800e5c:	55                   	push   %ebp
  800e5d:	89 e5                	mov    %esp,%ebp
  800e5f:	57                   	push   %edi
  800e60:	56                   	push   %esi
  800e61:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e62:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e67:	b8 10 00 00 00       	mov    $0x10,%eax
  800e6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e72:	89 df                	mov    %ebx,%edi
  800e74:	89 de                	mov    %ebx,%esi
  800e76:	cd 30                	int    $0x30
}

int 
sys_e1000_transmit(char* pck, size_t length){
	return syscall(SYS_e1000_transmit, 0, (uint32_t)pck, length, 0, 0, 0);
}
  800e78:	5b                   	pop    %ebx
  800e79:	5e                   	pop    %esi
  800e7a:	5f                   	pop    %edi
  800e7b:	5d                   	pop    %ebp
  800e7c:	c3                   	ret    

00800e7d <sys_e1000_receive>:

int 
sys_e1000_receive(char* pck, size_t* length){
  800e7d:	55                   	push   %ebp
  800e7e:	89 e5                	mov    %esp,%ebp
  800e80:	57                   	push   %edi
  800e81:	56                   	push   %esi
  800e82:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e83:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e88:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e90:	8b 55 08             	mov    0x8(%ebp),%edx
  800e93:	89 df                	mov    %ebx,%edi
  800e95:	89 de                	mov    %ebx,%esi
  800e97:	cd 30                	int    $0x30
}

int 
sys_e1000_receive(char* pck, size_t* length){
	return syscall(SYS_e1000_receive, 0, (uint32_t)pck, (uint32_t)length, 0, 0, 0);
}
  800e99:	5b                   	pop    %ebx
  800e9a:	5e                   	pop    %esi
  800e9b:	5f                   	pop    %edi
  800e9c:	5d                   	pop    %ebp
  800e9d:	c3                   	ret    

00800e9e <sys_e1000_get_mac>:

int 
sys_e1000_get_mac(uint8_t* mac_addr){
  800e9e:	55                   	push   %ebp
  800e9f:	89 e5                	mov    %esp,%ebp
  800ea1:	57                   	push   %edi
  800ea2:	56                   	push   %esi
  800ea3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ea9:	b8 11 00 00 00       	mov    $0x11,%eax
  800eae:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb1:	89 cb                	mov    %ecx,%ebx
  800eb3:	89 cf                	mov    %ecx,%edi
  800eb5:	89 ce                	mov    %ecx,%esi
  800eb7:	cd 30                	int    $0x30
}

int 
sys_e1000_get_mac(uint8_t* mac_addr){
	return syscall(SYS_e1000_get_mac, 0, (uint32_t)mac_addr, 0, 0, 0, 0);
}
  800eb9:	5b                   	pop    %ebx
  800eba:	5e                   	pop    %esi
  800ebb:	5f                   	pop    %edi
  800ebc:	5d                   	pop    %ebp
  800ebd:	c3                   	ret    
	...

00800ec0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800ec0:	55                   	push   %ebp
  800ec1:	89 e5                	mov    %esp,%ebp
  800ec3:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800ec6:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800ecd:	75 58                	jne    800f27 <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.	
		//panic("set_pgfault_handler not implemented");
		
		if (sys_page_alloc(thisenv->env_id,(void *) (UXSTACKTOP - PGSIZE),(PTE_W|PTE_U|PTE_P)) != 0){
  800ecf:	a1 04 20 80 00       	mov    0x802004,%eax
  800ed4:	8b 40 48             	mov    0x48(%eax),%eax
  800ed7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800ede:	00 
  800edf:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800ee6:	ee 
  800ee7:	89 04 24             	mov    %eax,(%esp)
  800eea:	e8 e6 fc ff ff       	call   800bd5 <sys_page_alloc>
  800eef:	85 c0                	test   %eax,%eax
  800ef1:	74 1c                	je     800f0f <set_pgfault_handler+0x4f>
			panic("set_pg_fault_handler");
  800ef3:	c7 44 24 08 93 15 80 	movl   $0x801593,0x8(%esp)
  800efa:	00 
  800efb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f02:	00 
  800f03:	c7 04 24 a8 15 80 00 	movl   $0x8015a8,(%esp)
  800f0a:	e8 31 f2 ff ff       	call   800140 <_panic>
		}
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  800f0f:	a1 04 20 80 00       	mov    0x802004,%eax
  800f14:	8b 40 48             	mov    0x48(%eax),%eax
  800f17:	c7 44 24 04 34 0f 80 	movl   $0x800f34,0x4(%esp)
  800f1e:	00 
  800f1f:	89 04 24             	mov    %eax,(%esp)
  800f22:	e8 4e fe ff ff       	call   800d75 <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800f27:	8b 45 08             	mov    0x8(%ebp),%eax
  800f2a:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800f2f:	c9                   	leave  
  800f30:	c3                   	ret    
  800f31:	00 00                	add    %al,(%eax)
	...

00800f34 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800f34:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800f35:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800f3a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800f3c:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// Save trap-time eip in eax
	movl 0x28(%esp), %eax
  800f3f:	8b 44 24 28          	mov    0x28(%esp),%eax

	// Save our current stack
	movl %esp, %ebp
  800f43:	89 e5                	mov    %esp,%ebp

	// Switch to trap-time stack
	movl 0x30(%esp), %esp
  800f45:	8b 64 24 30          	mov    0x30(%esp),%esp

	// Push trap-time eip to the trap-time stack
	pushl %eax
  800f49:	50                   	push   %eax

	// We now have to update the trap-time esp with its new value
	movl %esp, 0x30(%ebp)
  800f4a:	89 65 30             	mov    %esp,0x30(%ebp)

	// Go back to our exception stack
	movl %ebp, %esp
  800f4d:	89 ec                	mov    %ebp,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// Pop fault_va and err, both can be ignored
	popl %eax
  800f4f:	58                   	pop    %eax
	popl %eax
  800f50:	58                   	pop    %eax

	// Pop all registers back
	popal
  800f51:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// Skip %eip
	addl $0x4, %esp
  800f52:	83 c4 04             	add    $0x4,%esp

	// Pop eflags back
	popfl
  800f55:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	
	popl %esp
  800f56:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  800f57:	c3                   	ret    

00800f58 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800f58:	55                   	push   %ebp
  800f59:	57                   	push   %edi
  800f5a:	56                   	push   %esi
  800f5b:	83 ec 10             	sub    $0x10,%esp
  800f5e:	8b 74 24 20          	mov    0x20(%esp),%esi
  800f62:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800f66:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f6a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  800f6e:	89 cd                	mov    %ecx,%ebp
  800f70:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800f74:	85 c0                	test   %eax,%eax
  800f76:	75 2c                	jne    800fa4 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800f78:	39 f9                	cmp    %edi,%ecx
  800f7a:	77 68                	ja     800fe4 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800f7c:	85 c9                	test   %ecx,%ecx
  800f7e:	75 0b                	jne    800f8b <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800f80:	b8 01 00 00 00       	mov    $0x1,%eax
  800f85:	31 d2                	xor    %edx,%edx
  800f87:	f7 f1                	div    %ecx
  800f89:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800f8b:	31 d2                	xor    %edx,%edx
  800f8d:	89 f8                	mov    %edi,%eax
  800f8f:	f7 f1                	div    %ecx
  800f91:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f93:	89 f0                	mov    %esi,%eax
  800f95:	f7 f1                	div    %ecx
  800f97:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800f99:	89 f0                	mov    %esi,%eax
  800f9b:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800f9d:	83 c4 10             	add    $0x10,%esp
  800fa0:	5e                   	pop    %esi
  800fa1:	5f                   	pop    %edi
  800fa2:	5d                   	pop    %ebp
  800fa3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800fa4:	39 f8                	cmp    %edi,%eax
  800fa6:	77 2c                	ja     800fd4 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800fa8:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  800fab:	83 f6 1f             	xor    $0x1f,%esi
  800fae:	75 4c                	jne    800ffc <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800fb0:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800fb2:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800fb7:	72 0a                	jb     800fc3 <__udivdi3+0x6b>
  800fb9:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800fbd:	0f 87 ad 00 00 00    	ja     801070 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800fc3:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800fc8:	89 f0                	mov    %esi,%eax
  800fca:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800fcc:	83 c4 10             	add    $0x10,%esp
  800fcf:	5e                   	pop    %esi
  800fd0:	5f                   	pop    %edi
  800fd1:	5d                   	pop    %ebp
  800fd2:	c3                   	ret    
  800fd3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800fd4:	31 ff                	xor    %edi,%edi
  800fd6:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800fd8:	89 f0                	mov    %esi,%eax
  800fda:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800fdc:	83 c4 10             	add    $0x10,%esp
  800fdf:	5e                   	pop    %esi
  800fe0:	5f                   	pop    %edi
  800fe1:	5d                   	pop    %ebp
  800fe2:	c3                   	ret    
  800fe3:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800fe4:	89 fa                	mov    %edi,%edx
  800fe6:	89 f0                	mov    %esi,%eax
  800fe8:	f7 f1                	div    %ecx
  800fea:	89 c6                	mov    %eax,%esi
  800fec:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800fee:	89 f0                	mov    %esi,%eax
  800ff0:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800ff2:	83 c4 10             	add    $0x10,%esp
  800ff5:	5e                   	pop    %esi
  800ff6:	5f                   	pop    %edi
  800ff7:	5d                   	pop    %ebp
  800ff8:	c3                   	ret    
  800ff9:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800ffc:	89 f1                	mov    %esi,%ecx
  800ffe:	d3 e0                	shl    %cl,%eax
  801000:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801004:	b8 20 00 00 00       	mov    $0x20,%eax
  801009:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80100b:	89 ea                	mov    %ebp,%edx
  80100d:	88 c1                	mov    %al,%cl
  80100f:	d3 ea                	shr    %cl,%edx
  801011:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801015:	09 ca                	or     %ecx,%edx
  801017:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  80101b:	89 f1                	mov    %esi,%ecx
  80101d:	d3 e5                	shl    %cl,%ebp
  80101f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  801023:	89 fd                	mov    %edi,%ebp
  801025:	88 c1                	mov    %al,%cl
  801027:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  801029:	89 fa                	mov    %edi,%edx
  80102b:	89 f1                	mov    %esi,%ecx
  80102d:	d3 e2                	shl    %cl,%edx
  80102f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801033:	88 c1                	mov    %al,%cl
  801035:	d3 ef                	shr    %cl,%edi
  801037:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801039:	89 f8                	mov    %edi,%eax
  80103b:	89 ea                	mov    %ebp,%edx
  80103d:	f7 74 24 08          	divl   0x8(%esp)
  801041:	89 d1                	mov    %edx,%ecx
  801043:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  801045:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801049:	39 d1                	cmp    %edx,%ecx
  80104b:	72 17                	jb     801064 <__udivdi3+0x10c>
  80104d:	74 09                	je     801058 <__udivdi3+0x100>
  80104f:	89 fe                	mov    %edi,%esi
  801051:	31 ff                	xor    %edi,%edi
  801053:	e9 41 ff ff ff       	jmp    800f99 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801058:	8b 54 24 04          	mov    0x4(%esp),%edx
  80105c:	89 f1                	mov    %esi,%ecx
  80105e:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801060:	39 c2                	cmp    %eax,%edx
  801062:	73 eb                	jae    80104f <__udivdi3+0xf7>
		{
		  q0--;
  801064:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801067:	31 ff                	xor    %edi,%edi
  801069:	e9 2b ff ff ff       	jmp    800f99 <__udivdi3+0x41>
  80106e:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801070:	31 f6                	xor    %esi,%esi
  801072:	e9 22 ff ff ff       	jmp    800f99 <__udivdi3+0x41>
	...

00801078 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801078:	55                   	push   %ebp
  801079:	57                   	push   %edi
  80107a:	56                   	push   %esi
  80107b:	83 ec 20             	sub    $0x20,%esp
  80107e:	8b 44 24 30          	mov    0x30(%esp),%eax
  801082:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801086:	89 44 24 14          	mov    %eax,0x14(%esp)
  80108a:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  80108e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801092:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801096:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  801098:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80109a:	85 ed                	test   %ebp,%ebp
  80109c:	75 16                	jne    8010b4 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  80109e:	39 f1                	cmp    %esi,%ecx
  8010a0:	0f 86 a6 00 00 00    	jbe    80114c <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8010a6:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8010a8:	89 d0                	mov    %edx,%eax
  8010aa:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8010ac:	83 c4 20             	add    $0x20,%esp
  8010af:	5e                   	pop    %esi
  8010b0:	5f                   	pop    %edi
  8010b1:	5d                   	pop    %ebp
  8010b2:	c3                   	ret    
  8010b3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8010b4:	39 f5                	cmp    %esi,%ebp
  8010b6:	0f 87 ac 00 00 00    	ja     801168 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8010bc:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  8010bf:	83 f0 1f             	xor    $0x1f,%eax
  8010c2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010c6:	0f 84 a8 00 00 00    	je     801174 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8010cc:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8010d0:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8010d2:	bf 20 00 00 00       	mov    $0x20,%edi
  8010d7:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8010db:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8010df:	89 f9                	mov    %edi,%ecx
  8010e1:	d3 e8                	shr    %cl,%eax
  8010e3:	09 e8                	or     %ebp,%eax
  8010e5:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  8010e9:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8010ed:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8010f1:	d3 e0                	shl    %cl,%eax
  8010f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8010f7:	89 f2                	mov    %esi,%edx
  8010f9:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8010fb:	8b 44 24 14          	mov    0x14(%esp),%eax
  8010ff:	d3 e0                	shl    %cl,%eax
  801101:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801105:	8b 44 24 14          	mov    0x14(%esp),%eax
  801109:	89 f9                	mov    %edi,%ecx
  80110b:	d3 e8                	shr    %cl,%eax
  80110d:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80110f:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801111:	89 f2                	mov    %esi,%edx
  801113:	f7 74 24 18          	divl   0x18(%esp)
  801117:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801119:	f7 64 24 0c          	mull   0xc(%esp)
  80111d:	89 c5                	mov    %eax,%ebp
  80111f:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801121:	39 d6                	cmp    %edx,%esi
  801123:	72 67                	jb     80118c <__umoddi3+0x114>
  801125:	74 75                	je     80119c <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801127:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80112b:	29 e8                	sub    %ebp,%eax
  80112d:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80112f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801133:	d3 e8                	shr    %cl,%eax
  801135:	89 f2                	mov    %esi,%edx
  801137:	89 f9                	mov    %edi,%ecx
  801139:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80113b:	09 d0                	or     %edx,%eax
  80113d:	89 f2                	mov    %esi,%edx
  80113f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801143:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801145:	83 c4 20             	add    $0x20,%esp
  801148:	5e                   	pop    %esi
  801149:	5f                   	pop    %edi
  80114a:	5d                   	pop    %ebp
  80114b:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80114c:	85 c9                	test   %ecx,%ecx
  80114e:	75 0b                	jne    80115b <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801150:	b8 01 00 00 00       	mov    $0x1,%eax
  801155:	31 d2                	xor    %edx,%edx
  801157:	f7 f1                	div    %ecx
  801159:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80115b:	89 f0                	mov    %esi,%eax
  80115d:	31 d2                	xor    %edx,%edx
  80115f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801161:	89 f8                	mov    %edi,%eax
  801163:	e9 3e ff ff ff       	jmp    8010a6 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801168:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80116a:	83 c4 20             	add    $0x20,%esp
  80116d:	5e                   	pop    %esi
  80116e:	5f                   	pop    %edi
  80116f:	5d                   	pop    %ebp
  801170:	c3                   	ret    
  801171:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801174:	39 f5                	cmp    %esi,%ebp
  801176:	72 04                	jb     80117c <__umoddi3+0x104>
  801178:	39 f9                	cmp    %edi,%ecx
  80117a:	77 06                	ja     801182 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80117c:	89 f2                	mov    %esi,%edx
  80117e:	29 cf                	sub    %ecx,%edi
  801180:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801182:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801184:	83 c4 20             	add    $0x20,%esp
  801187:	5e                   	pop    %esi
  801188:	5f                   	pop    %edi
  801189:	5d                   	pop    %ebp
  80118a:	c3                   	ret    
  80118b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80118c:	89 d1                	mov    %edx,%ecx
  80118e:	89 c5                	mov    %eax,%ebp
  801190:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801194:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801198:	eb 8d                	jmp    801127 <__umoddi3+0xaf>
  80119a:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80119c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8011a0:	72 ea                	jb     80118c <__umoddi3+0x114>
  8011a2:	89 f1                	mov    %esi,%ecx
  8011a4:	eb 81                	jmp    801127 <__umoddi3+0xaf>
