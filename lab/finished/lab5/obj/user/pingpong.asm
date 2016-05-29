
obj/user/pingpong.debug:     file format elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
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
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003d:	e8 d5 0e 00 00       	call   800f17 <fork>
  800042:	89 c3                	mov    %eax,%ebx
  800044:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800047:	85 c0                	test   %eax,%eax
  800049:	74 3c                	je     800087 <umain+0x53>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004b:	e8 0f 0b 00 00       	call   800b5f <sys_getenvid>
  800050:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800054:	89 44 24 04          	mov    %eax,0x4(%esp)
  800058:	c7 04 24 80 16 80 00 	movl   $0x801680,(%esp)
  80005f:	e8 9c 01 00 00       	call   800200 <cprintf>
		ipc_send(who, 0, 0, 0);
  800064:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80006b:	00 
  80006c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800073:	00 
  800074:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80007b:	00 
  80007c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80007f:	89 04 24             	mov    %eax,(%esp)
  800082:	e8 f2 11 00 00       	call   801279 <ipc_send>
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  800087:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  80008a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800091:	00 
  800092:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800099:	00 
  80009a:	89 3c 24             	mov    %edi,(%esp)
  80009d:	e8 6e 11 00 00       	call   801210 <ipc_recv>
  8000a2:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  8000a4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000a7:	e8 b3 0a 00 00       	call   800b5f <sys_getenvid>
  8000ac:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8000b0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b8:	c7 04 24 96 16 80 00 	movl   $0x801696,(%esp)
  8000bf:	e8 3c 01 00 00       	call   800200 <cprintf>
		if (i == 10)
  8000c4:	83 fb 0a             	cmp    $0xa,%ebx
  8000c7:	74 25                	je     8000ee <umain+0xba>
			return;
		i++;
  8000c9:	43                   	inc    %ebx
		ipc_send(who, i, 0, 0);
  8000ca:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000d1:	00 
  8000d2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000d9:	00 
  8000da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000e1:	89 04 24             	mov    %eax,(%esp)
  8000e4:	e8 90 11 00 00       	call   801279 <ipc_send>
		if (i == 10)
  8000e9:	83 fb 0a             	cmp    $0xa,%ebx
  8000ec:	75 9c                	jne    80008a <umain+0x56>
			return;
	}

}
  8000ee:	83 c4 2c             	add    $0x2c,%esp
  8000f1:	5b                   	pop    %ebx
  8000f2:	5e                   	pop    %esi
  8000f3:	5f                   	pop    %edi
  8000f4:	5d                   	pop    %ebp
  8000f5:	c3                   	ret    
	...

008000f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
  8000fd:	83 ec 10             	sub    $0x10,%esp
  800100:	8b 75 08             	mov    0x8(%ebp),%esi
  800103:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800106:	e8 54 0a 00 00       	call   800b5f <sys_getenvid>
  80010b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800110:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800117:	c1 e0 07             	shl    $0x7,%eax
  80011a:	29 d0                	sub    %edx,%eax
  80011c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800121:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800126:	85 f6                	test   %esi,%esi
  800128:	7e 07                	jle    800131 <libmain+0x39>
		binaryname = argv[0];
  80012a:	8b 03                	mov    (%ebx),%eax
  80012c:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800131:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800135:	89 34 24             	mov    %esi,(%esp)
  800138:	e8 f7 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80013d:	e8 0a 00 00 00       	call   80014c <exit>
}
  800142:	83 c4 10             	add    $0x10,%esp
  800145:	5b                   	pop    %ebx
  800146:	5e                   	pop    %esi
  800147:	5d                   	pop    %ebp
  800148:	c3                   	ret    
  800149:	00 00                	add    %al,(%eax)
	...

0080014c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  800152:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800159:	e8 af 09 00 00       	call   800b0d <sys_env_destroy>
}
  80015e:	c9                   	leave  
  80015f:	c3                   	ret    

00800160 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	53                   	push   %ebx
  800164:	83 ec 14             	sub    $0x14,%esp
  800167:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80016a:	8b 03                	mov    (%ebx),%eax
  80016c:	8b 55 08             	mov    0x8(%ebp),%edx
  80016f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800173:	40                   	inc    %eax
  800174:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800176:	3d ff 00 00 00       	cmp    $0xff,%eax
  80017b:	75 19                	jne    800196 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80017d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800184:	00 
  800185:	8d 43 08             	lea    0x8(%ebx),%eax
  800188:	89 04 24             	mov    %eax,(%esp)
  80018b:	e8 40 09 00 00       	call   800ad0 <sys_cputs>
		b->idx = 0;
  800190:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800196:	ff 43 04             	incl   0x4(%ebx)
}
  800199:	83 c4 14             	add    $0x14,%esp
  80019c:	5b                   	pop    %ebx
  80019d:	5d                   	pop    %ebp
  80019e:	c3                   	ret    

0080019f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80019f:	55                   	push   %ebp
  8001a0:	89 e5                	mov    %esp,%ebp
  8001a2:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001a8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001af:	00 00 00 
	b.cnt = 0;
  8001b2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001bf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001ca:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d4:	c7 04 24 60 01 80 00 	movl   $0x800160,(%esp)
  8001db:	e8 82 01 00 00       	call   800362 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e0:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ea:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f0:	89 04 24             	mov    %eax,(%esp)
  8001f3:	e8 d8 08 00 00       	call   800ad0 <sys_cputs>

	return b.cnt;
}
  8001f8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001fe:	c9                   	leave  
  8001ff:	c3                   	ret    

00800200 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800200:	55                   	push   %ebp
  800201:	89 e5                	mov    %esp,%ebp
  800203:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800206:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800209:	89 44 24 04          	mov    %eax,0x4(%esp)
  80020d:	8b 45 08             	mov    0x8(%ebp),%eax
  800210:	89 04 24             	mov    %eax,(%esp)
  800213:	e8 87 ff ff ff       	call   80019f <vcprintf>
	va_end(ap);

	return cnt;
}
  800218:	c9                   	leave  
  800219:	c3                   	ret    
	...

0080021c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	57                   	push   %edi
  800220:	56                   	push   %esi
  800221:	53                   	push   %ebx
  800222:	83 ec 3c             	sub    $0x3c,%esp
  800225:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800228:	89 d7                	mov    %edx,%edi
  80022a:	8b 45 08             	mov    0x8(%ebp),%eax
  80022d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800230:	8b 45 0c             	mov    0xc(%ebp),%eax
  800233:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800236:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800239:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80023c:	85 c0                	test   %eax,%eax
  80023e:	75 08                	jne    800248 <printnum+0x2c>
  800240:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800243:	39 45 10             	cmp    %eax,0x10(%ebp)
  800246:	77 57                	ja     80029f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800248:	89 74 24 10          	mov    %esi,0x10(%esp)
  80024c:	4b                   	dec    %ebx
  80024d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800251:	8b 45 10             	mov    0x10(%ebp),%eax
  800254:	89 44 24 08          	mov    %eax,0x8(%esp)
  800258:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80025c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800260:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800267:	00 
  800268:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80026b:	89 04 24             	mov    %eax,(%esp)
  80026e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800271:	89 44 24 04          	mov    %eax,0x4(%esp)
  800275:	e8 a2 11 00 00       	call   80141c <__udivdi3>
  80027a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80027e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800282:	89 04 24             	mov    %eax,(%esp)
  800285:	89 54 24 04          	mov    %edx,0x4(%esp)
  800289:	89 fa                	mov    %edi,%edx
  80028b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80028e:	e8 89 ff ff ff       	call   80021c <printnum>
  800293:	eb 0f                	jmp    8002a4 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800295:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800299:	89 34 24             	mov    %esi,(%esp)
  80029c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80029f:	4b                   	dec    %ebx
  8002a0:	85 db                	test   %ebx,%ebx
  8002a2:	7f f1                	jg     800295 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002a8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8002af:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002ba:	00 
  8002bb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002be:	89 04 24             	mov    %eax,(%esp)
  8002c1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c8:	e8 6f 12 00 00       	call   80153c <__umoddi3>
  8002cd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002d1:	0f be 80 b3 16 80 00 	movsbl 0x8016b3(%eax),%eax
  8002d8:	89 04 24             	mov    %eax,(%esp)
  8002db:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002de:	83 c4 3c             	add    $0x3c,%esp
  8002e1:	5b                   	pop    %ebx
  8002e2:	5e                   	pop    %esi
  8002e3:	5f                   	pop    %edi
  8002e4:	5d                   	pop    %ebp
  8002e5:	c3                   	ret    

008002e6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002e6:	55                   	push   %ebp
  8002e7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002e9:	83 fa 01             	cmp    $0x1,%edx
  8002ec:	7e 0e                	jle    8002fc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002ee:	8b 10                	mov    (%eax),%edx
  8002f0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002f3:	89 08                	mov    %ecx,(%eax)
  8002f5:	8b 02                	mov    (%edx),%eax
  8002f7:	8b 52 04             	mov    0x4(%edx),%edx
  8002fa:	eb 22                	jmp    80031e <getuint+0x38>
	else if (lflag)
  8002fc:	85 d2                	test   %edx,%edx
  8002fe:	74 10                	je     800310 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800300:	8b 10                	mov    (%eax),%edx
  800302:	8d 4a 04             	lea    0x4(%edx),%ecx
  800305:	89 08                	mov    %ecx,(%eax)
  800307:	8b 02                	mov    (%edx),%eax
  800309:	ba 00 00 00 00       	mov    $0x0,%edx
  80030e:	eb 0e                	jmp    80031e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800310:	8b 10                	mov    (%eax),%edx
  800312:	8d 4a 04             	lea    0x4(%edx),%ecx
  800315:	89 08                	mov    %ecx,(%eax)
  800317:	8b 02                	mov    (%edx),%eax
  800319:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80031e:	5d                   	pop    %ebp
  80031f:	c3                   	ret    

00800320 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800326:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800329:	8b 10                	mov    (%eax),%edx
  80032b:	3b 50 04             	cmp    0x4(%eax),%edx
  80032e:	73 08                	jae    800338 <sprintputch+0x18>
		*b->buf++ = ch;
  800330:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800333:	88 0a                	mov    %cl,(%edx)
  800335:	42                   	inc    %edx
  800336:	89 10                	mov    %edx,(%eax)
}
  800338:	5d                   	pop    %ebp
  800339:	c3                   	ret    

0080033a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80033a:	55                   	push   %ebp
  80033b:	89 e5                	mov    %esp,%ebp
  80033d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800340:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800343:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800347:	8b 45 10             	mov    0x10(%ebp),%eax
  80034a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80034e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800351:	89 44 24 04          	mov    %eax,0x4(%esp)
  800355:	8b 45 08             	mov    0x8(%ebp),%eax
  800358:	89 04 24             	mov    %eax,(%esp)
  80035b:	e8 02 00 00 00       	call   800362 <vprintfmt>
	va_end(ap);
}
  800360:	c9                   	leave  
  800361:	c3                   	ret    

00800362 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800362:	55                   	push   %ebp
  800363:	89 e5                	mov    %esp,%ebp
  800365:	57                   	push   %edi
  800366:	56                   	push   %esi
  800367:	53                   	push   %ebx
  800368:	83 ec 4c             	sub    $0x4c,%esp
  80036b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80036e:	8b 75 10             	mov    0x10(%ebp),%esi
  800371:	eb 12                	jmp    800385 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800373:	85 c0                	test   %eax,%eax
  800375:	0f 84 6b 03 00 00    	je     8006e6 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80037b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80037f:	89 04 24             	mov    %eax,(%esp)
  800382:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800385:	0f b6 06             	movzbl (%esi),%eax
  800388:	46                   	inc    %esi
  800389:	83 f8 25             	cmp    $0x25,%eax
  80038c:	75 e5                	jne    800373 <vprintfmt+0x11>
  80038e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800392:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800399:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80039e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003a5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003aa:	eb 26                	jmp    8003d2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ac:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003af:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8003b3:	eb 1d                	jmp    8003d2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003b8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8003bc:	eb 14                	jmp    8003d2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003be:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003c1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003c8:	eb 08                	jmp    8003d2 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003ca:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8003cd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d2:	0f b6 06             	movzbl (%esi),%eax
  8003d5:	8d 56 01             	lea    0x1(%esi),%edx
  8003d8:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8003db:	8a 16                	mov    (%esi),%dl
  8003dd:	83 ea 23             	sub    $0x23,%edx
  8003e0:	80 fa 55             	cmp    $0x55,%dl
  8003e3:	0f 87 e1 02 00 00    	ja     8006ca <vprintfmt+0x368>
  8003e9:	0f b6 d2             	movzbl %dl,%edx
  8003ec:	ff 24 95 00 18 80 00 	jmp    *0x801800(,%edx,4)
  8003f3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003f6:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003fb:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8003fe:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800402:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800405:	8d 50 d0             	lea    -0x30(%eax),%edx
  800408:	83 fa 09             	cmp    $0x9,%edx
  80040b:	77 2a                	ja     800437 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80040d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80040e:	eb eb                	jmp    8003fb <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800410:	8b 45 14             	mov    0x14(%ebp),%eax
  800413:	8d 50 04             	lea    0x4(%eax),%edx
  800416:	89 55 14             	mov    %edx,0x14(%ebp)
  800419:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80041e:	eb 17                	jmp    800437 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800420:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800424:	78 98                	js     8003be <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800426:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800429:	eb a7                	jmp    8003d2 <vprintfmt+0x70>
  80042b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80042e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800435:	eb 9b                	jmp    8003d2 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800437:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80043b:	79 95                	jns    8003d2 <vprintfmt+0x70>
  80043d:	eb 8b                	jmp    8003ca <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80043f:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800440:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800443:	eb 8d                	jmp    8003d2 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800445:	8b 45 14             	mov    0x14(%ebp),%eax
  800448:	8d 50 04             	lea    0x4(%eax),%edx
  80044b:	89 55 14             	mov    %edx,0x14(%ebp)
  80044e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800452:	8b 00                	mov    (%eax),%eax
  800454:	89 04 24             	mov    %eax,(%esp)
  800457:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80045d:	e9 23 ff ff ff       	jmp    800385 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800462:	8b 45 14             	mov    0x14(%ebp),%eax
  800465:	8d 50 04             	lea    0x4(%eax),%edx
  800468:	89 55 14             	mov    %edx,0x14(%ebp)
  80046b:	8b 00                	mov    (%eax),%eax
  80046d:	85 c0                	test   %eax,%eax
  80046f:	79 02                	jns    800473 <vprintfmt+0x111>
  800471:	f7 d8                	neg    %eax
  800473:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800475:	83 f8 0f             	cmp    $0xf,%eax
  800478:	7f 0b                	jg     800485 <vprintfmt+0x123>
  80047a:	8b 04 85 60 19 80 00 	mov    0x801960(,%eax,4),%eax
  800481:	85 c0                	test   %eax,%eax
  800483:	75 23                	jne    8004a8 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800485:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800489:	c7 44 24 08 cb 16 80 	movl   $0x8016cb,0x8(%esp)
  800490:	00 
  800491:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800495:	8b 45 08             	mov    0x8(%ebp),%eax
  800498:	89 04 24             	mov    %eax,(%esp)
  80049b:	e8 9a fe ff ff       	call   80033a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a0:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004a3:	e9 dd fe ff ff       	jmp    800385 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8004a8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004ac:	c7 44 24 08 d4 16 80 	movl   $0x8016d4,0x8(%esp)
  8004b3:	00 
  8004b4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8004bb:	89 14 24             	mov    %edx,(%esp)
  8004be:	e8 77 fe ff ff       	call   80033a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004c6:	e9 ba fe ff ff       	jmp    800385 <vprintfmt+0x23>
  8004cb:	89 f9                	mov    %edi,%ecx
  8004cd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004d0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d6:	8d 50 04             	lea    0x4(%eax),%edx
  8004d9:	89 55 14             	mov    %edx,0x14(%ebp)
  8004dc:	8b 30                	mov    (%eax),%esi
  8004de:	85 f6                	test   %esi,%esi
  8004e0:	75 05                	jne    8004e7 <vprintfmt+0x185>
				p = "(null)";
  8004e2:	be c4 16 80 00       	mov    $0x8016c4,%esi
			if (width > 0 && padc != '-')
  8004e7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004eb:	0f 8e 84 00 00 00    	jle    800575 <vprintfmt+0x213>
  8004f1:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004f5:	74 7e                	je     800575 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004fb:	89 34 24             	mov    %esi,(%esp)
  8004fe:	e8 8b 02 00 00       	call   80078e <strnlen>
  800503:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800506:	29 c2                	sub    %eax,%edx
  800508:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80050b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80050f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800512:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800515:	89 de                	mov    %ebx,%esi
  800517:	89 d3                	mov    %edx,%ebx
  800519:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80051b:	eb 0b                	jmp    800528 <vprintfmt+0x1c6>
					putch(padc, putdat);
  80051d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800521:	89 3c 24             	mov    %edi,(%esp)
  800524:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800527:	4b                   	dec    %ebx
  800528:	85 db                	test   %ebx,%ebx
  80052a:	7f f1                	jg     80051d <vprintfmt+0x1bb>
  80052c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80052f:	89 f3                	mov    %esi,%ebx
  800531:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800534:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800537:	85 c0                	test   %eax,%eax
  800539:	79 05                	jns    800540 <vprintfmt+0x1de>
  80053b:	b8 00 00 00 00       	mov    $0x0,%eax
  800540:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800543:	29 c2                	sub    %eax,%edx
  800545:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800548:	eb 2b                	jmp    800575 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80054a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80054e:	74 18                	je     800568 <vprintfmt+0x206>
  800550:	8d 50 e0             	lea    -0x20(%eax),%edx
  800553:	83 fa 5e             	cmp    $0x5e,%edx
  800556:	76 10                	jbe    800568 <vprintfmt+0x206>
					putch('?', putdat);
  800558:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80055c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800563:	ff 55 08             	call   *0x8(%ebp)
  800566:	eb 0a                	jmp    800572 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800568:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80056c:	89 04 24             	mov    %eax,(%esp)
  80056f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800572:	ff 4d e4             	decl   -0x1c(%ebp)
  800575:	0f be 06             	movsbl (%esi),%eax
  800578:	46                   	inc    %esi
  800579:	85 c0                	test   %eax,%eax
  80057b:	74 21                	je     80059e <vprintfmt+0x23c>
  80057d:	85 ff                	test   %edi,%edi
  80057f:	78 c9                	js     80054a <vprintfmt+0x1e8>
  800581:	4f                   	dec    %edi
  800582:	79 c6                	jns    80054a <vprintfmt+0x1e8>
  800584:	8b 7d 08             	mov    0x8(%ebp),%edi
  800587:	89 de                	mov    %ebx,%esi
  800589:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80058c:	eb 18                	jmp    8005a6 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80058e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800592:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800599:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80059b:	4b                   	dec    %ebx
  80059c:	eb 08                	jmp    8005a6 <vprintfmt+0x244>
  80059e:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005a1:	89 de                	mov    %ebx,%esi
  8005a3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005a6:	85 db                	test   %ebx,%ebx
  8005a8:	7f e4                	jg     80058e <vprintfmt+0x22c>
  8005aa:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005ad:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005af:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005b2:	e9 ce fd ff ff       	jmp    800385 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005b7:	83 f9 01             	cmp    $0x1,%ecx
  8005ba:	7e 10                	jle    8005cc <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8005bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bf:	8d 50 08             	lea    0x8(%eax),%edx
  8005c2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c5:	8b 30                	mov    (%eax),%esi
  8005c7:	8b 78 04             	mov    0x4(%eax),%edi
  8005ca:	eb 26                	jmp    8005f2 <vprintfmt+0x290>
	else if (lflag)
  8005cc:	85 c9                	test   %ecx,%ecx
  8005ce:	74 12                	je     8005e2 <vprintfmt+0x280>
		return va_arg(*ap, long);
  8005d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d3:	8d 50 04             	lea    0x4(%eax),%edx
  8005d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d9:	8b 30                	mov    (%eax),%esi
  8005db:	89 f7                	mov    %esi,%edi
  8005dd:	c1 ff 1f             	sar    $0x1f,%edi
  8005e0:	eb 10                	jmp    8005f2 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8005e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e5:	8d 50 04             	lea    0x4(%eax),%edx
  8005e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005eb:	8b 30                	mov    (%eax),%esi
  8005ed:	89 f7                	mov    %esi,%edi
  8005ef:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005f2:	85 ff                	test   %edi,%edi
  8005f4:	78 0a                	js     800600 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005f6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005fb:	e9 8c 00 00 00       	jmp    80068c <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800600:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800604:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80060b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80060e:	f7 de                	neg    %esi
  800610:	83 d7 00             	adc    $0x0,%edi
  800613:	f7 df                	neg    %edi
			}
			base = 10;
  800615:	b8 0a 00 00 00       	mov    $0xa,%eax
  80061a:	eb 70                	jmp    80068c <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80061c:	89 ca                	mov    %ecx,%edx
  80061e:	8d 45 14             	lea    0x14(%ebp),%eax
  800621:	e8 c0 fc ff ff       	call   8002e6 <getuint>
  800626:	89 c6                	mov    %eax,%esi
  800628:	89 d7                	mov    %edx,%edi
			base = 10;
  80062a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80062f:	eb 5b                	jmp    80068c <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  800631:	89 ca                	mov    %ecx,%edx
  800633:	8d 45 14             	lea    0x14(%ebp),%eax
  800636:	e8 ab fc ff ff       	call   8002e6 <getuint>
  80063b:	89 c6                	mov    %eax,%esi
  80063d:	89 d7                	mov    %edx,%edi
			base = 8;
  80063f:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800644:	eb 46                	jmp    80068c <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  800646:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80064a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800651:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800654:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800658:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80065f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800662:	8b 45 14             	mov    0x14(%ebp),%eax
  800665:	8d 50 04             	lea    0x4(%eax),%edx
  800668:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80066b:	8b 30                	mov    (%eax),%esi
  80066d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800672:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800677:	eb 13                	jmp    80068c <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800679:	89 ca                	mov    %ecx,%edx
  80067b:	8d 45 14             	lea    0x14(%ebp),%eax
  80067e:	e8 63 fc ff ff       	call   8002e6 <getuint>
  800683:	89 c6                	mov    %eax,%esi
  800685:	89 d7                	mov    %edx,%edi
			base = 16;
  800687:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80068c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800690:	89 54 24 10          	mov    %edx,0x10(%esp)
  800694:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800697:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80069b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80069f:	89 34 24             	mov    %esi,(%esp)
  8006a2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006a6:	89 da                	mov    %ebx,%edx
  8006a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ab:	e8 6c fb ff ff       	call   80021c <printnum>
			break;
  8006b0:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006b3:	e9 cd fc ff ff       	jmp    800385 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006bc:	89 04 24             	mov    %eax,(%esp)
  8006bf:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006c5:	e9 bb fc ff ff       	jmp    800385 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ce:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006d5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006d8:	eb 01                	jmp    8006db <vprintfmt+0x379>
  8006da:	4e                   	dec    %esi
  8006db:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006df:	75 f9                	jne    8006da <vprintfmt+0x378>
  8006e1:	e9 9f fc ff ff       	jmp    800385 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8006e6:	83 c4 4c             	add    $0x4c,%esp
  8006e9:	5b                   	pop    %ebx
  8006ea:	5e                   	pop    %esi
  8006eb:	5f                   	pop    %edi
  8006ec:	5d                   	pop    %ebp
  8006ed:	c3                   	ret    

008006ee <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006ee:	55                   	push   %ebp
  8006ef:	89 e5                	mov    %esp,%ebp
  8006f1:	83 ec 28             	sub    $0x28,%esp
  8006f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006fa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006fd:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800701:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800704:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80070b:	85 c0                	test   %eax,%eax
  80070d:	74 30                	je     80073f <vsnprintf+0x51>
  80070f:	85 d2                	test   %edx,%edx
  800711:	7e 33                	jle    800746 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800713:	8b 45 14             	mov    0x14(%ebp),%eax
  800716:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80071a:	8b 45 10             	mov    0x10(%ebp),%eax
  80071d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800721:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800724:	89 44 24 04          	mov    %eax,0x4(%esp)
  800728:	c7 04 24 20 03 80 00 	movl   $0x800320,(%esp)
  80072f:	e8 2e fc ff ff       	call   800362 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800734:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800737:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80073a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80073d:	eb 0c                	jmp    80074b <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80073f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800744:	eb 05                	jmp    80074b <vsnprintf+0x5d>
  800746:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80074b:	c9                   	leave  
  80074c:	c3                   	ret    

0080074d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80074d:	55                   	push   %ebp
  80074e:	89 e5                	mov    %esp,%ebp
  800750:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800753:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800756:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80075a:	8b 45 10             	mov    0x10(%ebp),%eax
  80075d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800761:	8b 45 0c             	mov    0xc(%ebp),%eax
  800764:	89 44 24 04          	mov    %eax,0x4(%esp)
  800768:	8b 45 08             	mov    0x8(%ebp),%eax
  80076b:	89 04 24             	mov    %eax,(%esp)
  80076e:	e8 7b ff ff ff       	call   8006ee <vsnprintf>
	va_end(ap);

	return rc;
}
  800773:	c9                   	leave  
  800774:	c3                   	ret    
  800775:	00 00                	add    %al,(%eax)
	...

00800778 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
  80077b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80077e:	b8 00 00 00 00       	mov    $0x0,%eax
  800783:	eb 01                	jmp    800786 <strlen+0xe>
		n++;
  800785:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800786:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80078a:	75 f9                	jne    800785 <strlen+0xd>
		n++;
	return n;
}
  80078c:	5d                   	pop    %ebp
  80078d:	c3                   	ret    

0080078e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80078e:	55                   	push   %ebp
  80078f:	89 e5                	mov    %esp,%ebp
  800791:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800794:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800797:	b8 00 00 00 00       	mov    $0x0,%eax
  80079c:	eb 01                	jmp    80079f <strnlen+0x11>
		n++;
  80079e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079f:	39 d0                	cmp    %edx,%eax
  8007a1:	74 06                	je     8007a9 <strnlen+0x1b>
  8007a3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007a7:	75 f5                	jne    80079e <strnlen+0x10>
		n++;
	return n;
}
  8007a9:	5d                   	pop    %ebp
  8007aa:	c3                   	ret    

008007ab <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ab:	55                   	push   %ebp
  8007ac:	89 e5                	mov    %esp,%ebp
  8007ae:	53                   	push   %ebx
  8007af:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8007ba:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007bd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007c0:	42                   	inc    %edx
  8007c1:	84 c9                	test   %cl,%cl
  8007c3:	75 f5                	jne    8007ba <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007c5:	5b                   	pop    %ebx
  8007c6:	5d                   	pop    %ebp
  8007c7:	c3                   	ret    

008007c8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007c8:	55                   	push   %ebp
  8007c9:	89 e5                	mov    %esp,%ebp
  8007cb:	53                   	push   %ebx
  8007cc:	83 ec 08             	sub    $0x8,%esp
  8007cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007d2:	89 1c 24             	mov    %ebx,(%esp)
  8007d5:	e8 9e ff ff ff       	call   800778 <strlen>
	strcpy(dst + len, src);
  8007da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007dd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007e1:	01 d8                	add    %ebx,%eax
  8007e3:	89 04 24             	mov    %eax,(%esp)
  8007e6:	e8 c0 ff ff ff       	call   8007ab <strcpy>
	return dst;
}
  8007eb:	89 d8                	mov    %ebx,%eax
  8007ed:	83 c4 08             	add    $0x8,%esp
  8007f0:	5b                   	pop    %ebx
  8007f1:	5d                   	pop    %ebp
  8007f2:	c3                   	ret    

008007f3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007f3:	55                   	push   %ebp
  8007f4:	89 e5                	mov    %esp,%ebp
  8007f6:	56                   	push   %esi
  8007f7:	53                   	push   %ebx
  8007f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007fe:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800801:	b9 00 00 00 00       	mov    $0x0,%ecx
  800806:	eb 0c                	jmp    800814 <strncpy+0x21>
		*dst++ = *src;
  800808:	8a 1a                	mov    (%edx),%bl
  80080a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80080d:	80 3a 01             	cmpb   $0x1,(%edx)
  800810:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800813:	41                   	inc    %ecx
  800814:	39 f1                	cmp    %esi,%ecx
  800816:	75 f0                	jne    800808 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800818:	5b                   	pop    %ebx
  800819:	5e                   	pop    %esi
  80081a:	5d                   	pop    %ebp
  80081b:	c3                   	ret    

0080081c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80081c:	55                   	push   %ebp
  80081d:	89 e5                	mov    %esp,%ebp
  80081f:	56                   	push   %esi
  800820:	53                   	push   %ebx
  800821:	8b 75 08             	mov    0x8(%ebp),%esi
  800824:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800827:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80082a:	85 d2                	test   %edx,%edx
  80082c:	75 0a                	jne    800838 <strlcpy+0x1c>
  80082e:	89 f0                	mov    %esi,%eax
  800830:	eb 1a                	jmp    80084c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800832:	88 18                	mov    %bl,(%eax)
  800834:	40                   	inc    %eax
  800835:	41                   	inc    %ecx
  800836:	eb 02                	jmp    80083a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800838:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80083a:	4a                   	dec    %edx
  80083b:	74 0a                	je     800847 <strlcpy+0x2b>
  80083d:	8a 19                	mov    (%ecx),%bl
  80083f:	84 db                	test   %bl,%bl
  800841:	75 ef                	jne    800832 <strlcpy+0x16>
  800843:	89 c2                	mov    %eax,%edx
  800845:	eb 02                	jmp    800849 <strlcpy+0x2d>
  800847:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800849:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  80084c:	29 f0                	sub    %esi,%eax
}
  80084e:	5b                   	pop    %ebx
  80084f:	5e                   	pop    %esi
  800850:	5d                   	pop    %ebp
  800851:	c3                   	ret    

00800852 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800858:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80085b:	eb 02                	jmp    80085f <strcmp+0xd>
		p++, q++;
  80085d:	41                   	inc    %ecx
  80085e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80085f:	8a 01                	mov    (%ecx),%al
  800861:	84 c0                	test   %al,%al
  800863:	74 04                	je     800869 <strcmp+0x17>
  800865:	3a 02                	cmp    (%edx),%al
  800867:	74 f4                	je     80085d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800869:	0f b6 c0             	movzbl %al,%eax
  80086c:	0f b6 12             	movzbl (%edx),%edx
  80086f:	29 d0                	sub    %edx,%eax
}
  800871:	5d                   	pop    %ebp
  800872:	c3                   	ret    

00800873 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800873:	55                   	push   %ebp
  800874:	89 e5                	mov    %esp,%ebp
  800876:	53                   	push   %ebx
  800877:	8b 45 08             	mov    0x8(%ebp),%eax
  80087a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80087d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800880:	eb 03                	jmp    800885 <strncmp+0x12>
		n--, p++, q++;
  800882:	4a                   	dec    %edx
  800883:	40                   	inc    %eax
  800884:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800885:	85 d2                	test   %edx,%edx
  800887:	74 14                	je     80089d <strncmp+0x2a>
  800889:	8a 18                	mov    (%eax),%bl
  80088b:	84 db                	test   %bl,%bl
  80088d:	74 04                	je     800893 <strncmp+0x20>
  80088f:	3a 19                	cmp    (%ecx),%bl
  800891:	74 ef                	je     800882 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800893:	0f b6 00             	movzbl (%eax),%eax
  800896:	0f b6 11             	movzbl (%ecx),%edx
  800899:	29 d0                	sub    %edx,%eax
  80089b:	eb 05                	jmp    8008a2 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80089d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008a2:	5b                   	pop    %ebx
  8008a3:	5d                   	pop    %ebp
  8008a4:	c3                   	ret    

008008a5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008a5:	55                   	push   %ebp
  8008a6:	89 e5                	mov    %esp,%ebp
  8008a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ab:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008ae:	eb 05                	jmp    8008b5 <strchr+0x10>
		if (*s == c)
  8008b0:	38 ca                	cmp    %cl,%dl
  8008b2:	74 0c                	je     8008c0 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008b4:	40                   	inc    %eax
  8008b5:	8a 10                	mov    (%eax),%dl
  8008b7:	84 d2                	test   %dl,%dl
  8008b9:	75 f5                	jne    8008b0 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8008bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c8:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008cb:	eb 05                	jmp    8008d2 <strfind+0x10>
		if (*s == c)
  8008cd:	38 ca                	cmp    %cl,%dl
  8008cf:	74 07                	je     8008d8 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008d1:	40                   	inc    %eax
  8008d2:	8a 10                	mov    (%eax),%dl
  8008d4:	84 d2                	test   %dl,%dl
  8008d6:	75 f5                	jne    8008cd <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8008d8:	5d                   	pop    %ebp
  8008d9:	c3                   	ret    

008008da <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008da:	55                   	push   %ebp
  8008db:	89 e5                	mov    %esp,%ebp
  8008dd:	57                   	push   %edi
  8008de:	56                   	push   %esi
  8008df:	53                   	push   %ebx
  8008e0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008e9:	85 c9                	test   %ecx,%ecx
  8008eb:	74 30                	je     80091d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008ed:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008f3:	75 25                	jne    80091a <memset+0x40>
  8008f5:	f6 c1 03             	test   $0x3,%cl
  8008f8:	75 20                	jne    80091a <memset+0x40>
		c &= 0xFF;
  8008fa:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008fd:	89 d3                	mov    %edx,%ebx
  8008ff:	c1 e3 08             	shl    $0x8,%ebx
  800902:	89 d6                	mov    %edx,%esi
  800904:	c1 e6 18             	shl    $0x18,%esi
  800907:	89 d0                	mov    %edx,%eax
  800909:	c1 e0 10             	shl    $0x10,%eax
  80090c:	09 f0                	or     %esi,%eax
  80090e:	09 d0                	or     %edx,%eax
  800910:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800912:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800915:	fc                   	cld    
  800916:	f3 ab                	rep stos %eax,%es:(%edi)
  800918:	eb 03                	jmp    80091d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80091a:	fc                   	cld    
  80091b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80091d:	89 f8                	mov    %edi,%eax
  80091f:	5b                   	pop    %ebx
  800920:	5e                   	pop    %esi
  800921:	5f                   	pop    %edi
  800922:	5d                   	pop    %ebp
  800923:	c3                   	ret    

00800924 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800924:	55                   	push   %ebp
  800925:	89 e5                	mov    %esp,%ebp
  800927:	57                   	push   %edi
  800928:	56                   	push   %esi
  800929:	8b 45 08             	mov    0x8(%ebp),%eax
  80092c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80092f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800932:	39 c6                	cmp    %eax,%esi
  800934:	73 34                	jae    80096a <memmove+0x46>
  800936:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800939:	39 d0                	cmp    %edx,%eax
  80093b:	73 2d                	jae    80096a <memmove+0x46>
		s += n;
		d += n;
  80093d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800940:	f6 c2 03             	test   $0x3,%dl
  800943:	75 1b                	jne    800960 <memmove+0x3c>
  800945:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80094b:	75 13                	jne    800960 <memmove+0x3c>
  80094d:	f6 c1 03             	test   $0x3,%cl
  800950:	75 0e                	jne    800960 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800952:	83 ef 04             	sub    $0x4,%edi
  800955:	8d 72 fc             	lea    -0x4(%edx),%esi
  800958:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80095b:	fd                   	std    
  80095c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80095e:	eb 07                	jmp    800967 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800960:	4f                   	dec    %edi
  800961:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800964:	fd                   	std    
  800965:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800967:	fc                   	cld    
  800968:	eb 20                	jmp    80098a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800970:	75 13                	jne    800985 <memmove+0x61>
  800972:	a8 03                	test   $0x3,%al
  800974:	75 0f                	jne    800985 <memmove+0x61>
  800976:	f6 c1 03             	test   $0x3,%cl
  800979:	75 0a                	jne    800985 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80097b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80097e:	89 c7                	mov    %eax,%edi
  800980:	fc                   	cld    
  800981:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800983:	eb 05                	jmp    80098a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800985:	89 c7                	mov    %eax,%edi
  800987:	fc                   	cld    
  800988:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80098a:	5e                   	pop    %esi
  80098b:	5f                   	pop    %edi
  80098c:	5d                   	pop    %ebp
  80098d:	c3                   	ret    

0080098e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80098e:	55                   	push   %ebp
  80098f:	89 e5                	mov    %esp,%ebp
  800991:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800994:	8b 45 10             	mov    0x10(%ebp),%eax
  800997:	89 44 24 08          	mov    %eax,0x8(%esp)
  80099b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a5:	89 04 24             	mov    %eax,(%esp)
  8009a8:	e8 77 ff ff ff       	call   800924 <memmove>
}
  8009ad:	c9                   	leave  
  8009ae:	c3                   	ret    

008009af <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009af:	55                   	push   %ebp
  8009b0:	89 e5                	mov    %esp,%ebp
  8009b2:	57                   	push   %edi
  8009b3:	56                   	push   %esi
  8009b4:	53                   	push   %ebx
  8009b5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009b8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009bb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009be:	ba 00 00 00 00       	mov    $0x0,%edx
  8009c3:	eb 16                	jmp    8009db <memcmp+0x2c>
		if (*s1 != *s2)
  8009c5:	8a 04 17             	mov    (%edi,%edx,1),%al
  8009c8:	42                   	inc    %edx
  8009c9:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8009cd:	38 c8                	cmp    %cl,%al
  8009cf:	74 0a                	je     8009db <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8009d1:	0f b6 c0             	movzbl %al,%eax
  8009d4:	0f b6 c9             	movzbl %cl,%ecx
  8009d7:	29 c8                	sub    %ecx,%eax
  8009d9:	eb 09                	jmp    8009e4 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009db:	39 da                	cmp    %ebx,%edx
  8009dd:	75 e6                	jne    8009c5 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009df:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e4:	5b                   	pop    %ebx
  8009e5:	5e                   	pop    %esi
  8009e6:	5f                   	pop    %edi
  8009e7:	5d                   	pop    %ebp
  8009e8:	c3                   	ret    

008009e9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009e9:	55                   	push   %ebp
  8009ea:	89 e5                	mov    %esp,%ebp
  8009ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009f2:	89 c2                	mov    %eax,%edx
  8009f4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009f7:	eb 05                	jmp    8009fe <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009f9:	38 08                	cmp    %cl,(%eax)
  8009fb:	74 05                	je     800a02 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009fd:	40                   	inc    %eax
  8009fe:	39 d0                	cmp    %edx,%eax
  800a00:	72 f7                	jb     8009f9 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a02:	5d                   	pop    %ebp
  800a03:	c3                   	ret    

00800a04 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
  800a07:	57                   	push   %edi
  800a08:	56                   	push   %esi
  800a09:	53                   	push   %ebx
  800a0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a0d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a10:	eb 01                	jmp    800a13 <strtol+0xf>
		s++;
  800a12:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a13:	8a 02                	mov    (%edx),%al
  800a15:	3c 20                	cmp    $0x20,%al
  800a17:	74 f9                	je     800a12 <strtol+0xe>
  800a19:	3c 09                	cmp    $0x9,%al
  800a1b:	74 f5                	je     800a12 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a1d:	3c 2b                	cmp    $0x2b,%al
  800a1f:	75 08                	jne    800a29 <strtol+0x25>
		s++;
  800a21:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a22:	bf 00 00 00 00       	mov    $0x0,%edi
  800a27:	eb 13                	jmp    800a3c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a29:	3c 2d                	cmp    $0x2d,%al
  800a2b:	75 0a                	jne    800a37 <strtol+0x33>
		s++, neg = 1;
  800a2d:	8d 52 01             	lea    0x1(%edx),%edx
  800a30:	bf 01 00 00 00       	mov    $0x1,%edi
  800a35:	eb 05                	jmp    800a3c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a37:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a3c:	85 db                	test   %ebx,%ebx
  800a3e:	74 05                	je     800a45 <strtol+0x41>
  800a40:	83 fb 10             	cmp    $0x10,%ebx
  800a43:	75 28                	jne    800a6d <strtol+0x69>
  800a45:	8a 02                	mov    (%edx),%al
  800a47:	3c 30                	cmp    $0x30,%al
  800a49:	75 10                	jne    800a5b <strtol+0x57>
  800a4b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a4f:	75 0a                	jne    800a5b <strtol+0x57>
		s += 2, base = 16;
  800a51:	83 c2 02             	add    $0x2,%edx
  800a54:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a59:	eb 12                	jmp    800a6d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a5b:	85 db                	test   %ebx,%ebx
  800a5d:	75 0e                	jne    800a6d <strtol+0x69>
  800a5f:	3c 30                	cmp    $0x30,%al
  800a61:	75 05                	jne    800a68 <strtol+0x64>
		s++, base = 8;
  800a63:	42                   	inc    %edx
  800a64:	b3 08                	mov    $0x8,%bl
  800a66:	eb 05                	jmp    800a6d <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a68:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a6d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a72:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a74:	8a 0a                	mov    (%edx),%cl
  800a76:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a79:	80 fb 09             	cmp    $0x9,%bl
  800a7c:	77 08                	ja     800a86 <strtol+0x82>
			dig = *s - '0';
  800a7e:	0f be c9             	movsbl %cl,%ecx
  800a81:	83 e9 30             	sub    $0x30,%ecx
  800a84:	eb 1e                	jmp    800aa4 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a86:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a89:	80 fb 19             	cmp    $0x19,%bl
  800a8c:	77 08                	ja     800a96 <strtol+0x92>
			dig = *s - 'a' + 10;
  800a8e:	0f be c9             	movsbl %cl,%ecx
  800a91:	83 e9 57             	sub    $0x57,%ecx
  800a94:	eb 0e                	jmp    800aa4 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a96:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a99:	80 fb 19             	cmp    $0x19,%bl
  800a9c:	77 12                	ja     800ab0 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a9e:	0f be c9             	movsbl %cl,%ecx
  800aa1:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800aa4:	39 f1                	cmp    %esi,%ecx
  800aa6:	7d 0c                	jge    800ab4 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800aa8:	42                   	inc    %edx
  800aa9:	0f af c6             	imul   %esi,%eax
  800aac:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800aae:	eb c4                	jmp    800a74 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ab0:	89 c1                	mov    %eax,%ecx
  800ab2:	eb 02                	jmp    800ab6 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ab4:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800ab6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aba:	74 05                	je     800ac1 <strtol+0xbd>
		*endptr = (char *) s;
  800abc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800abf:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ac1:	85 ff                	test   %edi,%edi
  800ac3:	74 04                	je     800ac9 <strtol+0xc5>
  800ac5:	89 c8                	mov    %ecx,%eax
  800ac7:	f7 d8                	neg    %eax
}
  800ac9:	5b                   	pop    %ebx
  800aca:	5e                   	pop    %esi
  800acb:	5f                   	pop    %edi
  800acc:	5d                   	pop    %ebp
  800acd:	c3                   	ret    
	...

00800ad0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ad0:	55                   	push   %ebp
  800ad1:	89 e5                	mov    %esp,%ebp
  800ad3:	57                   	push   %edi
  800ad4:	56                   	push   %esi
  800ad5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad6:	b8 00 00 00 00       	mov    $0x0,%eax
  800adb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ade:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae1:	89 c3                	mov    %eax,%ebx
  800ae3:	89 c7                	mov    %eax,%edi
  800ae5:	89 c6                	mov    %eax,%esi
  800ae7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ae9:	5b                   	pop    %ebx
  800aea:	5e                   	pop    %esi
  800aeb:	5f                   	pop    %edi
  800aec:	5d                   	pop    %ebp
  800aed:	c3                   	ret    

00800aee <sys_cgetc>:

int
sys_cgetc(void)
{
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	57                   	push   %edi
  800af2:	56                   	push   %esi
  800af3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af4:	ba 00 00 00 00       	mov    $0x0,%edx
  800af9:	b8 01 00 00 00       	mov    $0x1,%eax
  800afe:	89 d1                	mov    %edx,%ecx
  800b00:	89 d3                	mov    %edx,%ebx
  800b02:	89 d7                	mov    %edx,%edi
  800b04:	89 d6                	mov    %edx,%esi
  800b06:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b08:	5b                   	pop    %ebx
  800b09:	5e                   	pop    %esi
  800b0a:	5f                   	pop    %edi
  800b0b:	5d                   	pop    %ebp
  800b0c:	c3                   	ret    

00800b0d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b0d:	55                   	push   %ebp
  800b0e:	89 e5                	mov    %esp,%ebp
  800b10:	57                   	push   %edi
  800b11:	56                   	push   %esi
  800b12:	53                   	push   %ebx
  800b13:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b16:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b1b:	b8 03 00 00 00       	mov    $0x3,%eax
  800b20:	8b 55 08             	mov    0x8(%ebp),%edx
  800b23:	89 cb                	mov    %ecx,%ebx
  800b25:	89 cf                	mov    %ecx,%edi
  800b27:	89 ce                	mov    %ecx,%esi
  800b29:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b2b:	85 c0                	test   %eax,%eax
  800b2d:	7e 28                	jle    800b57 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b2f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b33:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b3a:	00 
  800b3b:	c7 44 24 08 bf 19 80 	movl   $0x8019bf,0x8(%esp)
  800b42:	00 
  800b43:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b4a:	00 
  800b4b:	c7 04 24 dc 19 80 00 	movl   $0x8019dc,(%esp)
  800b52:	e8 d5 07 00 00       	call   80132c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b57:	83 c4 2c             	add    $0x2c,%esp
  800b5a:	5b                   	pop    %ebx
  800b5b:	5e                   	pop    %esi
  800b5c:	5f                   	pop    %edi
  800b5d:	5d                   	pop    %ebp
  800b5e:	c3                   	ret    

00800b5f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	57                   	push   %edi
  800b63:	56                   	push   %esi
  800b64:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b65:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6a:	b8 02 00 00 00       	mov    $0x2,%eax
  800b6f:	89 d1                	mov    %edx,%ecx
  800b71:	89 d3                	mov    %edx,%ebx
  800b73:	89 d7                	mov    %edx,%edi
  800b75:	89 d6                	mov    %edx,%esi
  800b77:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b79:	5b                   	pop    %ebx
  800b7a:	5e                   	pop    %esi
  800b7b:	5f                   	pop    %edi
  800b7c:	5d                   	pop    %ebp
  800b7d:	c3                   	ret    

00800b7e <sys_yield>:

void
sys_yield(void)
{
  800b7e:	55                   	push   %ebp
  800b7f:	89 e5                	mov    %esp,%ebp
  800b81:	57                   	push   %edi
  800b82:	56                   	push   %esi
  800b83:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b84:	ba 00 00 00 00       	mov    $0x0,%edx
  800b89:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b8e:	89 d1                	mov    %edx,%ecx
  800b90:	89 d3                	mov    %edx,%ebx
  800b92:	89 d7                	mov    %edx,%edi
  800b94:	89 d6                	mov    %edx,%esi
  800b96:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b98:	5b                   	pop    %ebx
  800b99:	5e                   	pop    %esi
  800b9a:	5f                   	pop    %edi
  800b9b:	5d                   	pop    %ebp
  800b9c:	c3                   	ret    

00800b9d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	57                   	push   %edi
  800ba1:	56                   	push   %esi
  800ba2:	53                   	push   %ebx
  800ba3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba6:	be 00 00 00 00       	mov    $0x0,%esi
  800bab:	b8 04 00 00 00       	mov    $0x4,%eax
  800bb0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb9:	89 f7                	mov    %esi,%edi
  800bbb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bbd:	85 c0                	test   %eax,%eax
  800bbf:	7e 28                	jle    800be9 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bc5:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800bcc:	00 
  800bcd:	c7 44 24 08 bf 19 80 	movl   $0x8019bf,0x8(%esp)
  800bd4:	00 
  800bd5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bdc:	00 
  800bdd:	c7 04 24 dc 19 80 00 	movl   $0x8019dc,(%esp)
  800be4:	e8 43 07 00 00       	call   80132c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800be9:	83 c4 2c             	add    $0x2c,%esp
  800bec:	5b                   	pop    %ebx
  800bed:	5e                   	pop    %esi
  800bee:	5f                   	pop    %edi
  800bef:	5d                   	pop    %ebp
  800bf0:	c3                   	ret    

00800bf1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	57                   	push   %edi
  800bf5:	56                   	push   %esi
  800bf6:	53                   	push   %ebx
  800bf7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfa:	b8 05 00 00 00       	mov    $0x5,%eax
  800bff:	8b 75 18             	mov    0x18(%ebp),%esi
  800c02:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c05:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c10:	85 c0                	test   %eax,%eax
  800c12:	7e 28                	jle    800c3c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c14:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c18:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c1f:	00 
  800c20:	c7 44 24 08 bf 19 80 	movl   $0x8019bf,0x8(%esp)
  800c27:	00 
  800c28:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c2f:	00 
  800c30:	c7 04 24 dc 19 80 00 	movl   $0x8019dc,(%esp)
  800c37:	e8 f0 06 00 00       	call   80132c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c3c:	83 c4 2c             	add    $0x2c,%esp
  800c3f:	5b                   	pop    %ebx
  800c40:	5e                   	pop    %esi
  800c41:	5f                   	pop    %edi
  800c42:	5d                   	pop    %ebp
  800c43:	c3                   	ret    

00800c44 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	57                   	push   %edi
  800c48:	56                   	push   %esi
  800c49:	53                   	push   %ebx
  800c4a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c52:	b8 06 00 00 00       	mov    $0x6,%eax
  800c57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5d:	89 df                	mov    %ebx,%edi
  800c5f:	89 de                	mov    %ebx,%esi
  800c61:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c63:	85 c0                	test   %eax,%eax
  800c65:	7e 28                	jle    800c8f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c67:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c6b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c72:	00 
  800c73:	c7 44 24 08 bf 19 80 	movl   $0x8019bf,0x8(%esp)
  800c7a:	00 
  800c7b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c82:	00 
  800c83:	c7 04 24 dc 19 80 00 	movl   $0x8019dc,(%esp)
  800c8a:	e8 9d 06 00 00       	call   80132c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c8f:	83 c4 2c             	add    $0x2c,%esp
  800c92:	5b                   	pop    %ebx
  800c93:	5e                   	pop    %esi
  800c94:	5f                   	pop    %edi
  800c95:	5d                   	pop    %ebp
  800c96:	c3                   	ret    

00800c97 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	57                   	push   %edi
  800c9b:	56                   	push   %esi
  800c9c:	53                   	push   %ebx
  800c9d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca5:	b8 08 00 00 00       	mov    $0x8,%eax
  800caa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cad:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb0:	89 df                	mov    %ebx,%edi
  800cb2:	89 de                	mov    %ebx,%esi
  800cb4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb6:	85 c0                	test   %eax,%eax
  800cb8:	7e 28                	jle    800ce2 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cba:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cbe:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800cc5:	00 
  800cc6:	c7 44 24 08 bf 19 80 	movl   $0x8019bf,0x8(%esp)
  800ccd:	00 
  800cce:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cd5:	00 
  800cd6:	c7 04 24 dc 19 80 00 	movl   $0x8019dc,(%esp)
  800cdd:	e8 4a 06 00 00       	call   80132c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ce2:	83 c4 2c             	add    $0x2c,%esp
  800ce5:	5b                   	pop    %ebx
  800ce6:	5e                   	pop    %esi
  800ce7:	5f                   	pop    %edi
  800ce8:	5d                   	pop    %ebp
  800ce9:	c3                   	ret    

00800cea <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cea:	55                   	push   %ebp
  800ceb:	89 e5                	mov    %esp,%ebp
  800ced:	57                   	push   %edi
  800cee:	56                   	push   %esi
  800cef:	53                   	push   %ebx
  800cf0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf8:	b8 09 00 00 00       	mov    $0x9,%eax
  800cfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d00:	8b 55 08             	mov    0x8(%ebp),%edx
  800d03:	89 df                	mov    %ebx,%edi
  800d05:	89 de                	mov    %ebx,%esi
  800d07:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d09:	85 c0                	test   %eax,%eax
  800d0b:	7e 28                	jle    800d35 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d11:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d18:	00 
  800d19:	c7 44 24 08 bf 19 80 	movl   $0x8019bf,0x8(%esp)
  800d20:	00 
  800d21:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d28:	00 
  800d29:	c7 04 24 dc 19 80 00 	movl   $0x8019dc,(%esp)
  800d30:	e8 f7 05 00 00       	call   80132c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d35:	83 c4 2c             	add    $0x2c,%esp
  800d38:	5b                   	pop    %ebx
  800d39:	5e                   	pop    %esi
  800d3a:	5f                   	pop    %edi
  800d3b:	5d                   	pop    %ebp
  800d3c:	c3                   	ret    

00800d3d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d3d:	55                   	push   %ebp
  800d3e:	89 e5                	mov    %esp,%ebp
  800d40:	57                   	push   %edi
  800d41:	56                   	push   %esi
  800d42:	53                   	push   %ebx
  800d43:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d46:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d4b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d53:	8b 55 08             	mov    0x8(%ebp),%edx
  800d56:	89 df                	mov    %ebx,%edi
  800d58:	89 de                	mov    %ebx,%esi
  800d5a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d5c:	85 c0                	test   %eax,%eax
  800d5e:	7e 28                	jle    800d88 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d60:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d64:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800d6b:	00 
  800d6c:	c7 44 24 08 bf 19 80 	movl   $0x8019bf,0x8(%esp)
  800d73:	00 
  800d74:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d7b:	00 
  800d7c:	c7 04 24 dc 19 80 00 	movl   $0x8019dc,(%esp)
  800d83:	e8 a4 05 00 00       	call   80132c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d88:	83 c4 2c             	add    $0x2c,%esp
  800d8b:	5b                   	pop    %ebx
  800d8c:	5e                   	pop    %esi
  800d8d:	5f                   	pop    %edi
  800d8e:	5d                   	pop    %ebp
  800d8f:	c3                   	ret    

00800d90 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
  800d93:	57                   	push   %edi
  800d94:	56                   	push   %esi
  800d95:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d96:	be 00 00 00 00       	mov    $0x0,%esi
  800d9b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800da0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800da3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800da6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dac:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dae:	5b                   	pop    %ebx
  800daf:	5e                   	pop    %esi
  800db0:	5f                   	pop    %edi
  800db1:	5d                   	pop    %ebp
  800db2:	c3                   	ret    

00800db3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
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
  800dbc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dc1:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc9:	89 cb                	mov    %ecx,%ebx
  800dcb:	89 cf                	mov    %ecx,%edi
  800dcd:	89 ce                	mov    %ecx,%esi
  800dcf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dd1:	85 c0                	test   %eax,%eax
  800dd3:	7e 28                	jle    800dfd <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dd9:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800de0:	00 
  800de1:	c7 44 24 08 bf 19 80 	movl   $0x8019bf,0x8(%esp)
  800de8:	00 
  800de9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800df0:	00 
  800df1:	c7 04 24 dc 19 80 00 	movl   $0x8019dc,(%esp)
  800df8:	e8 2f 05 00 00       	call   80132c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dfd:	83 c4 2c             	add    $0x2c,%esp
  800e00:	5b                   	pop    %ebx
  800e01:	5e                   	pop    %esi
  800e02:	5f                   	pop    %edi
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    
  800e05:	00 00                	add    %al,(%eax)
	...

00800e08 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e08:	55                   	push   %ebp
  800e09:	89 e5                	mov    %esp,%ebp
  800e0b:	53                   	push   %ebx
  800e0c:	83 ec 24             	sub    $0x24,%esp
  800e0f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e12:	8b 18                	mov    (%eax),%ebx
	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	if ((err & FEC_WR) == 0)
  800e14:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e18:	75 20                	jne    800e3a <pgfault+0x32>
		panic("pgfault: faulting address [%08x] not a write\n", addr);
  800e1a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e1e:	c7 44 24 08 ec 19 80 	movl   $0x8019ec,0x8(%esp)
  800e25:	00 
  800e26:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  800e2d:	00 
  800e2e:	c7 04 24 6c 1a 80 00 	movl   $0x801a6c,(%esp)
  800e35:	e8 f2 04 00 00       	call   80132c <_panic>

	void *page_aligned_addr = (void *) ROUNDDOWN(addr, PGSIZE);
  800e3a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t page_num = (uint32_t) page_aligned_addr / PGSIZE;
  800e40:	89 d8                	mov    %ebx,%eax
  800e42:	c1 e8 0c             	shr    $0xc,%eax
	if (!(uvpt[page_num] & PTE_COW))
  800e45:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e4c:	f6 c4 08             	test   $0x8,%ah
  800e4f:	75 1c                	jne    800e6d <pgfault+0x65>
		panic("pgfault: fault was not on a copy-on-write page\n");
  800e51:	c7 44 24 08 1c 1a 80 	movl   $0x801a1c,0x8(%esp)
  800e58:	00 
  800e59:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e60:	00 
  800e61:	c7 04 24 6c 1a 80 00 	movl   $0x801a6c,(%esp)
  800e68:	e8 bf 04 00 00       	call   80132c <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.

	// Allocate
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800e6d:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800e74:	00 
  800e75:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800e7c:	00 
  800e7d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e84:	e8 14 fd ff ff       	call   800b9d <sys_page_alloc>
  800e89:	85 c0                	test   %eax,%eax
  800e8b:	79 20                	jns    800ead <pgfault+0xa5>
		panic("sys_page_alloc: %e\n", r);
  800e8d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e91:	c7 44 24 08 77 1a 80 	movl   $0x801a77,0x8(%esp)
  800e98:	00 
  800e99:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  800ea0:	00 
  800ea1:	c7 04 24 6c 1a 80 00 	movl   $0x801a6c,(%esp)
  800ea8:	e8 7f 04 00 00       	call   80132c <_panic>

	// Copy over
	void *src_addr = (void *) ROUNDDOWN(addr, PGSIZE);
	memmove(PFTEMP, src_addr, PGSIZE);
  800ead:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800eb4:	00 
  800eb5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800eb9:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800ec0:	e8 5f fa ff ff       	call   800924 <memmove>

	// Remap
	if ((r = sys_page_map(0, PFTEMP, 0, src_addr, PTE_P | PTE_U | PTE_W)) < 0)
  800ec5:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800ecc:	00 
  800ecd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800ed1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ed8:	00 
  800ed9:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800ee0:	00 
  800ee1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ee8:	e8 04 fd ff ff       	call   800bf1 <sys_page_map>
  800eed:	85 c0                	test   %eax,%eax
  800eef:	79 20                	jns    800f11 <pgfault+0x109>
		panic("sys_page_map: %e\n", r);
  800ef1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ef5:	c7 44 24 08 8b 1a 80 	movl   $0x801a8b,0x8(%esp)
  800efc:	00 
  800efd:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  800f04:	00 
  800f05:	c7 04 24 6c 1a 80 00 	movl   $0x801a6c,(%esp)
  800f0c:	e8 1b 04 00 00       	call   80132c <_panic>

}
  800f11:	83 c4 24             	add    $0x24,%esp
  800f14:	5b                   	pop    %ebx
  800f15:	5d                   	pop    %ebp
  800f16:	c3                   	ret    

00800f17 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f17:	55                   	push   %ebp
  800f18:	89 e5                	mov    %esp,%ebp
  800f1a:	57                   	push   %edi
  800f1b:	56                   	push   %esi
  800f1c:	53                   	push   %ebx
  800f1d:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	int r;
	envid_t child_envid;

	set_pgfault_handler(pgfault);
  800f20:	c7 04 24 08 0e 80 00 	movl   $0x800e08,(%esp)
  800f27:	e8 58 04 00 00       	call   801384 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f2c:	ba 07 00 00 00       	mov    $0x7,%edx
  800f31:	89 d0                	mov    %edx,%eax
  800f33:	cd 30                	int    $0x30
  800f35:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800f38:	89 45 e0             	mov    %eax,-0x20(%ebp)

	child_envid = sys_exofork();
	if (child_envid < 0)
  800f3b:	85 c0                	test   %eax,%eax
  800f3d:	79 20                	jns    800f5f <fork+0x48>
		panic("sys_exofork: %e\n", child_envid);
  800f3f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f43:	c7 44 24 08 9d 1a 80 	movl   $0x801a9d,0x8(%esp)
  800f4a:	00 
  800f4b:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  800f52:	00 
  800f53:	c7 04 24 6c 1a 80 00 	movl   $0x801a6c,(%esp)
  800f5a:	e8 cd 03 00 00       	call   80132c <_panic>
	if (child_envid == 0) { // child
  800f5f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800f63:	75 25                	jne    800f8a <fork+0x73>
		// Fix thisenv like dumbfork does and return 0
		thisenv = &envs[ENVX(sys_getenvid())];
  800f65:	e8 f5 fb ff ff       	call   800b5f <sys_getenvid>
  800f6a:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f6f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800f76:	c1 e0 07             	shl    $0x7,%eax
  800f79:	29 d0                	sub    %edx,%eax
  800f7b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f80:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800f85:	e9 58 02 00 00       	jmp    8011e2 <fork+0x2cb>
	set_pgfault_handler(pgfault);

	child_envid = sys_exofork();
	if (child_envid < 0)
		panic("sys_exofork: %e\n", child_envid);
	if (child_envid == 0) { // child
  800f8a:	bf 00 00 00 00       	mov    $0x0,%edi
  800f8f:	be 00 00 00 00       	mov    $0x0,%esi
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
  800f94:	89 f0                	mov    %esi,%eax
  800f96:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  800f99:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fa0:	a8 01                	test   $0x1,%al
  800fa2:	0f 84 7a 01 00 00    	je     801122 <fork+0x20b>
			((uvpt[page_num] & PTE_P) == PTE_P)) {
  800fa8:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  800faf:	a8 01                	test   $0x1,%al
  800fb1:	0f 84 6b 01 00 00    	je     801122 <fork+0x20b>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	envid_t this_envid = thisenv->env_id;
  800fb7:	a1 04 20 80 00       	mov    0x802004,%eax
  800fbc:	8b 40 48             	mov    0x48(%eax),%eax
  800fbf:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	if (uvpt[pn] & PTE_SHARE) {
  800fc2:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fc9:	f6 c4 04             	test   $0x4,%ah
  800fcc:	74 52                	je     801020 <fork+0x109>
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  800fce:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fd5:	25 07 0e 00 00       	and    $0xe07,%eax
  800fda:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fde:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800fe2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fe5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fe9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800fed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ff0:	89 04 24             	mov    %eax,(%esp)
  800ff3:	e8 f9 fb ff ff       	call   800bf1 <sys_page_map>
  800ff8:	85 c0                	test   %eax,%eax
  800ffa:	0f 89 22 01 00 00    	jns    801122 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  801000:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801004:	c7 44 24 08 8b 1a 80 	movl   $0x801a8b,0x8(%esp)
  80100b:	00 
  80100c:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  801013:	00 
  801014:	c7 04 24 6c 1a 80 00 	movl   $0x801a6c,(%esp)
  80101b:	e8 0c 03 00 00       	call   80132c <_panic>
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
  801020:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801027:	f6 c4 08             	test   $0x8,%ah
  80102a:	75 0f                	jne    80103b <fork+0x124>
  80102c:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801033:	a8 02                	test   $0x2,%al
  801035:	0f 84 99 00 00 00    	je     8010d4 <fork+0x1bd>
		if (uvpt[pn] & PTE_U)
  80103b:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801042:	83 e0 04             	and    $0x4,%eax
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
  801045:	83 f8 01             	cmp    $0x1,%eax
  801048:	19 db                	sbb    %ebx,%ebx
  80104a:	83 e3 fc             	and    $0xfffffffc,%ebx
  80104d:	81 c3 05 08 00 00    	add    $0x805,%ebx
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
		if (uvpt[pn] & PTE_U)
			perm |= PTE_U;

		// Map page COW, U and P in child
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), perm)) < 0)
  801053:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801057:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80105b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80105e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801062:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801066:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801069:	89 04 24             	mov    %eax,(%esp)
  80106c:	e8 80 fb ff ff       	call   800bf1 <sys_page_map>
  801071:	85 c0                	test   %eax,%eax
  801073:	79 20                	jns    801095 <fork+0x17e>
			panic("sys_page_map: %e\n", r);
  801075:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801079:	c7 44 24 08 8b 1a 80 	movl   $0x801a8b,0x8(%esp)
  801080:	00 
  801081:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  801088:	00 
  801089:	c7 04 24 6c 1a 80 00 	movl   $0x801a6c,(%esp)
  801090:	e8 97 02 00 00       	call   80132c <_panic>

		// Map page COW, U and P in parent
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), this_envid, (void *) (pn*PGSIZE), perm)) < 0)
  801095:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801099:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80109d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010a4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8010a8:	89 04 24             	mov    %eax,(%esp)
  8010ab:	e8 41 fb ff ff       	call   800bf1 <sys_page_map>
  8010b0:	85 c0                	test   %eax,%eax
  8010b2:	79 6e                	jns    801122 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  8010b4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010b8:	c7 44 24 08 8b 1a 80 	movl   $0x801a8b,0x8(%esp)
  8010bf:	00 
  8010c0:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  8010c7:	00 
  8010c8:	c7 04 24 6c 1a 80 00 	movl   $0x801a6c,(%esp)
  8010cf:	e8 58 02 00 00       	call   80132c <_panic>

	} else { // map pages that are present but not writable or COW with their original permissions
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  8010d4:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010db:	25 07 0e 00 00       	and    $0xe07,%eax
  8010e0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010e4:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8010eb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010ef:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8010f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010f6:	89 04 24             	mov    %eax,(%esp)
  8010f9:	e8 f3 fa ff ff       	call   800bf1 <sys_page_map>
  8010fe:	85 c0                	test   %eax,%eax
  801100:	79 20                	jns    801122 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  801102:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801106:	c7 44 24 08 8b 1a 80 	movl   $0x801a8b,0x8(%esp)
  80110d:	00 
  80110e:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  801115:	00 
  801116:	c7 04 24 6c 1a 80 00 	movl   $0x801a6c,(%esp)
  80111d:	e8 0a 02 00 00       	call   80132c <_panic>
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
  801122:	46                   	inc    %esi
  801123:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801129:	81 fe ff eb 0e 00    	cmp    $0xeebff,%esi
  80112f:	0f 85 5f fe ff ff    	jne    800f94 <fork+0x7d>
	}

	// Allocate exception stack space for child. The child can't do this themselves
	// because the mechanism by which it would is to run the pgfault handler, which
	// needs to run on the exception stack (catch 22).
	if ((r = sys_page_alloc(child_envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801135:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80113c:	00 
  80113d:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801144:	ee 
  801145:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801148:	89 04 24             	mov    %eax,(%esp)
  80114b:	e8 4d fa ff ff       	call   800b9d <sys_page_alloc>
  801150:	85 c0                	test   %eax,%eax
  801152:	79 20                	jns    801174 <fork+0x25d>
		panic("sys_page_alloc: %e\n", r);
  801154:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801158:	c7 44 24 08 77 1a 80 	movl   $0x801a77,0x8(%esp)
  80115f:	00 
  801160:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  801167:	00 
  801168:	c7 04 24 6c 1a 80 00 	movl   $0x801a6c,(%esp)
  80116f:	e8 b8 01 00 00       	call   80132c <_panic>

	// Set page fault handler for the child
	if ((r = sys_env_set_pgfault_upcall(child_envid, _pgfault_upcall)) < 0)
  801174:	c7 44 24 04 f8 13 80 	movl   $0x8013f8,0x4(%esp)
  80117b:	00 
  80117c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80117f:	89 04 24             	mov    %eax,(%esp)
  801182:	e8 b6 fb ff ff       	call   800d3d <sys_env_set_pgfault_upcall>
  801187:	85 c0                	test   %eax,%eax
  801189:	79 20                	jns    8011ab <fork+0x294>
		panic("sys_env_set_pgfault_upcall: %e\n", r);
  80118b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80118f:	c7 44 24 08 4c 1a 80 	movl   $0x801a4c,0x8(%esp)
  801196:	00 
  801197:	c7 44 24 04 a1 00 00 	movl   $0xa1,0x4(%esp)
  80119e:	00 
  80119f:	c7 04 24 6c 1a 80 00 	movl   $0x801a6c,(%esp)
  8011a6:	e8 81 01 00 00       	call   80132c <_panic>

	// Mark child environment as runnable
	if ((r = sys_env_set_status(child_envid, ENV_RUNNABLE)) < 0)
  8011ab:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8011b2:	00 
  8011b3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011b6:	89 04 24             	mov    %eax,(%esp)
  8011b9:	e8 d9 fa ff ff       	call   800c97 <sys_env_set_status>
  8011be:	85 c0                	test   %eax,%eax
  8011c0:	79 20                	jns    8011e2 <fork+0x2cb>
		panic("sys_env_set_status: %e\n", r);
  8011c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011c6:	c7 44 24 08 ae 1a 80 	movl   $0x801aae,0x8(%esp)
  8011cd:	00 
  8011ce:	c7 44 24 04 a5 00 00 	movl   $0xa5,0x4(%esp)
  8011d5:	00 
  8011d6:	c7 04 24 6c 1a 80 00 	movl   $0x801a6c,(%esp)
  8011dd:	e8 4a 01 00 00       	call   80132c <_panic>

	return child_envid;
}
  8011e2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011e5:	83 c4 3c             	add    $0x3c,%esp
  8011e8:	5b                   	pop    %ebx
  8011e9:	5e                   	pop    %esi
  8011ea:	5f                   	pop    %edi
  8011eb:	5d                   	pop    %ebp
  8011ec:	c3                   	ret    

008011ed <sfork>:

// Challenge!
int
sfork(void)
{
  8011ed:	55                   	push   %ebp
  8011ee:	89 e5                	mov    %esp,%ebp
  8011f0:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8011f3:	c7 44 24 08 c6 1a 80 	movl   $0x801ac6,0x8(%esp)
  8011fa:	00 
  8011fb:	c7 44 24 04 ae 00 00 	movl   $0xae,0x4(%esp)
  801202:	00 
  801203:	c7 04 24 6c 1a 80 00 	movl   $0x801a6c,(%esp)
  80120a:	e8 1d 01 00 00       	call   80132c <_panic>
	...

00801210 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801210:	55                   	push   %ebp
  801211:	89 e5                	mov    %esp,%ebp
  801213:	56                   	push   %esi
  801214:	53                   	push   %ebx
  801215:	83 ec 10             	sub    $0x10,%esp
  801218:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80121b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80121e:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int r;
		
	r = sys_ipc_recv(pg?pg:(void*)UTOP);
  801221:	85 c0                	test   %eax,%eax
  801223:	75 05                	jne    80122a <ipc_recv+0x1a>
  801225:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80122a:	89 04 24             	mov    %eax,(%esp)
  80122d:	e8 81 fb ff ff       	call   800db3 <sys_ipc_recv>
	if (from_env_store != NULL)
  801232:	85 db                	test   %ebx,%ebx
  801234:	74 0b                	je     801241 <ipc_recv+0x31>
		*from_env_store = thisenv->env_ipc_from; 
  801236:	8b 15 04 20 80 00    	mov    0x802004,%edx
  80123c:	8b 52 74             	mov    0x74(%edx),%edx
  80123f:	89 13                	mov    %edx,(%ebx)
	if (perm_store != NULL)
  801241:	85 f6                	test   %esi,%esi
  801243:	74 0b                	je     801250 <ipc_recv+0x40>
		*perm_store = thisenv->env_ipc_perm;
  801245:	8b 15 04 20 80 00    	mov    0x802004,%edx
  80124b:	8b 52 78             	mov    0x78(%edx),%edx
  80124e:	89 16                	mov    %edx,(%esi)
	
	if (r < 0){
  801250:	85 c0                	test   %eax,%eax
  801252:	79 16                	jns    80126a <ipc_recv+0x5a>
		if(from_env_store != NULL)
  801254:	85 db                	test   %ebx,%ebx
  801256:	74 06                	je     80125e <ipc_recv+0x4e>
			*from_env_store = 0;
  801258:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store != NULL)	
  80125e:	85 f6                	test   %esi,%esi
  801260:	74 10                	je     801272 <ipc_recv+0x62>
			*perm_store = 0;
  801262:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801268:	eb 08                	jmp    801272 <ipc_recv+0x62>
		return r;
	}
	
	return thisenv->env_ipc_value;
  80126a:	a1 04 20 80 00       	mov    0x802004,%eax
  80126f:	8b 40 70             	mov    0x70(%eax),%eax
}
  801272:	83 c4 10             	add    $0x10,%esp
  801275:	5b                   	pop    %ebx
  801276:	5e                   	pop    %esi
  801277:	5d                   	pop    %ebp
  801278:	c3                   	ret    

00801279 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801279:	55                   	push   %ebp
  80127a:	89 e5                	mov    %esp,%ebp
  80127c:	57                   	push   %edi
  80127d:	56                   	push   %esi
  80127e:	53                   	push   %ebx
  80127f:	83 ec 1c             	sub    $0x1c,%esp
  801282:	8b 75 08             	mov    0x8(%ebp),%esi
  801285:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801288:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  80128b:	eb 2a                	jmp    8012b7 <ipc_send+0x3e>
		if (r != -E_IPC_NOT_RECV)
  80128d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801290:	74 20                	je     8012b2 <ipc_send+0x39>
			panic("ipc_send: sys_ipc_try_send failed %e", r);
  801292:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801296:	c7 44 24 08 dc 1a 80 	movl   $0x801adc,0x8(%esp)
  80129d:	00 
  80129e:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  8012a5:	00 
  8012a6:	c7 04 24 01 1b 80 00 	movl   $0x801b01,(%esp)
  8012ad:	e8 7a 00 00 00       	call   80132c <_panic>
		sys_yield();
  8012b2:	e8 c7 f8 ff ff       	call   800b7e <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  8012b7:	85 db                	test   %ebx,%ebx
  8012b9:	75 07                	jne    8012c2 <ipc_send+0x49>
  8012bb:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8012c0:	eb 02                	jmp    8012c4 <ipc_send+0x4b>
  8012c2:	89 d8                	mov    %ebx,%eax
  8012c4:	8b 55 14             	mov    0x14(%ebp),%edx
  8012c7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8012cb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012cf:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012d3:	89 34 24             	mov    %esi,(%esp)
  8012d6:	e8 b5 fa ff ff       	call   800d90 <sys_ipc_try_send>
  8012db:	85 c0                	test   %eax,%eax
  8012dd:	78 ae                	js     80128d <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: sys_ipc_try_send failed %e", r);
		sys_yield();
	}
}
  8012df:	83 c4 1c             	add    $0x1c,%esp
  8012e2:	5b                   	pop    %ebx
  8012e3:	5e                   	pop    %esi
  8012e4:	5f                   	pop    %edi
  8012e5:	5d                   	pop    %ebp
  8012e6:	c3                   	ret    

008012e7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8012e7:	55                   	push   %ebp
  8012e8:	89 e5                	mov    %esp,%ebp
  8012ea:	53                   	push   %ebx
  8012eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  8012ee:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8012f3:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8012fa:	89 c2                	mov    %eax,%edx
  8012fc:	c1 e2 07             	shl    $0x7,%edx
  8012ff:	29 ca                	sub    %ecx,%edx
  801301:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801307:	8b 52 50             	mov    0x50(%edx),%edx
  80130a:	39 da                	cmp    %ebx,%edx
  80130c:	75 0f                	jne    80131d <ipc_find_env+0x36>
			return envs[i].env_id;
  80130e:	c1 e0 07             	shl    $0x7,%eax
  801311:	29 c8                	sub    %ecx,%eax
  801313:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801318:	8b 40 40             	mov    0x40(%eax),%eax
  80131b:	eb 0c                	jmp    801329 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80131d:	40                   	inc    %eax
  80131e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801323:	75 ce                	jne    8012f3 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801325:	66 b8 00 00          	mov    $0x0,%ax
}
  801329:	5b                   	pop    %ebx
  80132a:	5d                   	pop    %ebp
  80132b:	c3                   	ret    

0080132c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80132c:	55                   	push   %ebp
  80132d:	89 e5                	mov    %esp,%ebp
  80132f:	56                   	push   %esi
  801330:	53                   	push   %ebx
  801331:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801334:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801337:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80133d:	e8 1d f8 ff ff       	call   800b5f <sys_getenvid>
  801342:	8b 55 0c             	mov    0xc(%ebp),%edx
  801345:	89 54 24 10          	mov    %edx,0x10(%esp)
  801349:	8b 55 08             	mov    0x8(%ebp),%edx
  80134c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801350:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801354:	89 44 24 04          	mov    %eax,0x4(%esp)
  801358:	c7 04 24 0c 1b 80 00 	movl   $0x801b0c,(%esp)
  80135f:	e8 9c ee ff ff       	call   800200 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801364:	89 74 24 04          	mov    %esi,0x4(%esp)
  801368:	8b 45 10             	mov    0x10(%ebp),%eax
  80136b:	89 04 24             	mov    %eax,(%esp)
  80136e:	e8 2c ee ff ff       	call   80019f <vcprintf>
	cprintf("\n");
  801373:	c7 04 24 89 1a 80 00 	movl   $0x801a89,(%esp)
  80137a:	e8 81 ee ff ff       	call   800200 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80137f:	cc                   	int3   
  801380:	eb fd                	jmp    80137f <_panic+0x53>
	...

00801384 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801384:	55                   	push   %ebp
  801385:	89 e5                	mov    %esp,%ebp
  801387:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80138a:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  801391:	75 58                	jne    8013eb <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.	
		//panic("set_pgfault_handler not implemented");
		
		if (sys_page_alloc(thisenv->env_id,(void *) (UXSTACKTOP - PGSIZE),(PTE_W|PTE_U|PTE_P)) != 0){
  801393:	a1 04 20 80 00       	mov    0x802004,%eax
  801398:	8b 40 48             	mov    0x48(%eax),%eax
  80139b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8013a2:	00 
  8013a3:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8013aa:	ee 
  8013ab:	89 04 24             	mov    %eax,(%esp)
  8013ae:	e8 ea f7 ff ff       	call   800b9d <sys_page_alloc>
  8013b3:	85 c0                	test   %eax,%eax
  8013b5:	74 1c                	je     8013d3 <set_pgfault_handler+0x4f>
			panic("set_pg_fault_handler");
  8013b7:	c7 44 24 08 30 1b 80 	movl   $0x801b30,0x8(%esp)
  8013be:	00 
  8013bf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8013c6:	00 
  8013c7:	c7 04 24 45 1b 80 00 	movl   $0x801b45,(%esp)
  8013ce:	e8 59 ff ff ff       	call   80132c <_panic>
		}
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  8013d3:	a1 04 20 80 00       	mov    0x802004,%eax
  8013d8:	8b 40 48             	mov    0x48(%eax),%eax
  8013db:	c7 44 24 04 f8 13 80 	movl   $0x8013f8,0x4(%esp)
  8013e2:	00 
  8013e3:	89 04 24             	mov    %eax,(%esp)
  8013e6:	e8 52 f9 ff ff       	call   800d3d <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8013eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ee:	a3 08 20 80 00       	mov    %eax,0x802008
}
  8013f3:	c9                   	leave  
  8013f4:	c3                   	ret    
  8013f5:	00 00                	add    %al,(%eax)
	...

008013f8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8013f8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8013f9:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  8013fe:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801400:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// Save trap-time eip in eax
	movl 0x28(%esp), %eax
  801403:	8b 44 24 28          	mov    0x28(%esp),%eax

	// Save our current stack
	movl %esp, %ebp
  801407:	89 e5                	mov    %esp,%ebp

	// Switch to trap-time stack
	movl 0x30(%esp), %esp
  801409:	8b 64 24 30          	mov    0x30(%esp),%esp

	// Push trap-time eip to the trap-time stack
	pushl %eax
  80140d:	50                   	push   %eax

	// We now have to update the trap-time esp with its new value
	movl %esp, 0x30(%ebp)
  80140e:	89 65 30             	mov    %esp,0x30(%ebp)

	// Go back to our exception stack
	movl %ebp, %esp
  801411:	89 ec                	mov    %ebp,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// Pop fault_va and err, both can be ignored
	popl %eax
  801413:	58                   	pop    %eax
	popl %eax
  801414:	58                   	pop    %eax

	// Pop all registers back
	popal
  801415:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// Skip %eip
	addl $0x4, %esp
  801416:	83 c4 04             	add    $0x4,%esp

	// Pop eflags back
	popfl
  801419:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	
	popl %esp
  80141a:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  80141b:	c3                   	ret    

0080141c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  80141c:	55                   	push   %ebp
  80141d:	57                   	push   %edi
  80141e:	56                   	push   %esi
  80141f:	83 ec 10             	sub    $0x10,%esp
  801422:	8b 74 24 20          	mov    0x20(%esp),%esi
  801426:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80142a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80142e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  801432:	89 cd                	mov    %ecx,%ebp
  801434:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801438:	85 c0                	test   %eax,%eax
  80143a:	75 2c                	jne    801468 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  80143c:	39 f9                	cmp    %edi,%ecx
  80143e:	77 68                	ja     8014a8 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801440:	85 c9                	test   %ecx,%ecx
  801442:	75 0b                	jne    80144f <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801444:	b8 01 00 00 00       	mov    $0x1,%eax
  801449:	31 d2                	xor    %edx,%edx
  80144b:	f7 f1                	div    %ecx
  80144d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80144f:	31 d2                	xor    %edx,%edx
  801451:	89 f8                	mov    %edi,%eax
  801453:	f7 f1                	div    %ecx
  801455:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801457:	89 f0                	mov    %esi,%eax
  801459:	f7 f1                	div    %ecx
  80145b:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80145d:	89 f0                	mov    %esi,%eax
  80145f:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801461:	83 c4 10             	add    $0x10,%esp
  801464:	5e                   	pop    %esi
  801465:	5f                   	pop    %edi
  801466:	5d                   	pop    %ebp
  801467:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801468:	39 f8                	cmp    %edi,%eax
  80146a:	77 2c                	ja     801498 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80146c:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  80146f:	83 f6 1f             	xor    $0x1f,%esi
  801472:	75 4c                	jne    8014c0 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801474:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801476:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80147b:	72 0a                	jb     801487 <__udivdi3+0x6b>
  80147d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801481:	0f 87 ad 00 00 00    	ja     801534 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801487:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80148c:	89 f0                	mov    %esi,%eax
  80148e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801490:	83 c4 10             	add    $0x10,%esp
  801493:	5e                   	pop    %esi
  801494:	5f                   	pop    %edi
  801495:	5d                   	pop    %ebp
  801496:	c3                   	ret    
  801497:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801498:	31 ff                	xor    %edi,%edi
  80149a:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80149c:	89 f0                	mov    %esi,%eax
  80149e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8014a0:	83 c4 10             	add    $0x10,%esp
  8014a3:	5e                   	pop    %esi
  8014a4:	5f                   	pop    %edi
  8014a5:	5d                   	pop    %ebp
  8014a6:	c3                   	ret    
  8014a7:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8014a8:	89 fa                	mov    %edi,%edx
  8014aa:	89 f0                	mov    %esi,%eax
  8014ac:	f7 f1                	div    %ecx
  8014ae:	89 c6                	mov    %eax,%esi
  8014b0:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8014b2:	89 f0                	mov    %esi,%eax
  8014b4:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8014b6:	83 c4 10             	add    $0x10,%esp
  8014b9:	5e                   	pop    %esi
  8014ba:	5f                   	pop    %edi
  8014bb:	5d                   	pop    %ebp
  8014bc:	c3                   	ret    
  8014bd:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8014c0:	89 f1                	mov    %esi,%ecx
  8014c2:	d3 e0                	shl    %cl,%eax
  8014c4:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8014c8:	b8 20 00 00 00       	mov    $0x20,%eax
  8014cd:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8014cf:	89 ea                	mov    %ebp,%edx
  8014d1:	88 c1                	mov    %al,%cl
  8014d3:	d3 ea                	shr    %cl,%edx
  8014d5:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8014d9:	09 ca                	or     %ecx,%edx
  8014db:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  8014df:	89 f1                	mov    %esi,%ecx
  8014e1:	d3 e5                	shl    %cl,%ebp
  8014e3:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  8014e7:	89 fd                	mov    %edi,%ebp
  8014e9:	88 c1                	mov    %al,%cl
  8014eb:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  8014ed:	89 fa                	mov    %edi,%edx
  8014ef:	89 f1                	mov    %esi,%ecx
  8014f1:	d3 e2                	shl    %cl,%edx
  8014f3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8014f7:	88 c1                	mov    %al,%cl
  8014f9:	d3 ef                	shr    %cl,%edi
  8014fb:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8014fd:	89 f8                	mov    %edi,%eax
  8014ff:	89 ea                	mov    %ebp,%edx
  801501:	f7 74 24 08          	divl   0x8(%esp)
  801505:	89 d1                	mov    %edx,%ecx
  801507:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  801509:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80150d:	39 d1                	cmp    %edx,%ecx
  80150f:	72 17                	jb     801528 <__udivdi3+0x10c>
  801511:	74 09                	je     80151c <__udivdi3+0x100>
  801513:	89 fe                	mov    %edi,%esi
  801515:	31 ff                	xor    %edi,%edi
  801517:	e9 41 ff ff ff       	jmp    80145d <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  80151c:	8b 54 24 04          	mov    0x4(%esp),%edx
  801520:	89 f1                	mov    %esi,%ecx
  801522:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801524:	39 c2                	cmp    %eax,%edx
  801526:	73 eb                	jae    801513 <__udivdi3+0xf7>
		{
		  q0--;
  801528:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80152b:	31 ff                	xor    %edi,%edi
  80152d:	e9 2b ff ff ff       	jmp    80145d <__udivdi3+0x41>
  801532:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801534:	31 f6                	xor    %esi,%esi
  801536:	e9 22 ff ff ff       	jmp    80145d <__udivdi3+0x41>
	...

0080153c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  80153c:	55                   	push   %ebp
  80153d:	57                   	push   %edi
  80153e:	56                   	push   %esi
  80153f:	83 ec 20             	sub    $0x20,%esp
  801542:	8b 44 24 30          	mov    0x30(%esp),%eax
  801546:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80154a:	89 44 24 14          	mov    %eax,0x14(%esp)
  80154e:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  801552:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801556:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80155a:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  80155c:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80155e:	85 ed                	test   %ebp,%ebp
  801560:	75 16                	jne    801578 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  801562:	39 f1                	cmp    %esi,%ecx
  801564:	0f 86 a6 00 00 00    	jbe    801610 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80156a:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  80156c:	89 d0                	mov    %edx,%eax
  80156e:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801570:	83 c4 20             	add    $0x20,%esp
  801573:	5e                   	pop    %esi
  801574:	5f                   	pop    %edi
  801575:	5d                   	pop    %ebp
  801576:	c3                   	ret    
  801577:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801578:	39 f5                	cmp    %esi,%ebp
  80157a:	0f 87 ac 00 00 00    	ja     80162c <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801580:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  801583:	83 f0 1f             	xor    $0x1f,%eax
  801586:	89 44 24 10          	mov    %eax,0x10(%esp)
  80158a:	0f 84 a8 00 00 00    	je     801638 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801590:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801594:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801596:	bf 20 00 00 00       	mov    $0x20,%edi
  80159b:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80159f:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8015a3:	89 f9                	mov    %edi,%ecx
  8015a5:	d3 e8                	shr    %cl,%eax
  8015a7:	09 e8                	or     %ebp,%eax
  8015a9:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  8015ad:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8015b1:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8015b5:	d3 e0                	shl    %cl,%eax
  8015b7:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8015bb:	89 f2                	mov    %esi,%edx
  8015bd:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8015bf:	8b 44 24 14          	mov    0x14(%esp),%eax
  8015c3:	d3 e0                	shl    %cl,%eax
  8015c5:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8015c9:	8b 44 24 14          	mov    0x14(%esp),%eax
  8015cd:	89 f9                	mov    %edi,%ecx
  8015cf:	d3 e8                	shr    %cl,%eax
  8015d1:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8015d3:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8015d5:	89 f2                	mov    %esi,%edx
  8015d7:	f7 74 24 18          	divl   0x18(%esp)
  8015db:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8015dd:	f7 64 24 0c          	mull   0xc(%esp)
  8015e1:	89 c5                	mov    %eax,%ebp
  8015e3:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8015e5:	39 d6                	cmp    %edx,%esi
  8015e7:	72 67                	jb     801650 <__umoddi3+0x114>
  8015e9:	74 75                	je     801660 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8015eb:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8015ef:	29 e8                	sub    %ebp,%eax
  8015f1:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8015f3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8015f7:	d3 e8                	shr    %cl,%eax
  8015f9:	89 f2                	mov    %esi,%edx
  8015fb:	89 f9                	mov    %edi,%ecx
  8015fd:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8015ff:	09 d0                	or     %edx,%eax
  801601:	89 f2                	mov    %esi,%edx
  801603:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801607:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801609:	83 c4 20             	add    $0x20,%esp
  80160c:	5e                   	pop    %esi
  80160d:	5f                   	pop    %edi
  80160e:	5d                   	pop    %ebp
  80160f:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801610:	85 c9                	test   %ecx,%ecx
  801612:	75 0b                	jne    80161f <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801614:	b8 01 00 00 00       	mov    $0x1,%eax
  801619:	31 d2                	xor    %edx,%edx
  80161b:	f7 f1                	div    %ecx
  80161d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80161f:	89 f0                	mov    %esi,%eax
  801621:	31 d2                	xor    %edx,%edx
  801623:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801625:	89 f8                	mov    %edi,%eax
  801627:	e9 3e ff ff ff       	jmp    80156a <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  80162c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80162e:	83 c4 20             	add    $0x20,%esp
  801631:	5e                   	pop    %esi
  801632:	5f                   	pop    %edi
  801633:	5d                   	pop    %ebp
  801634:	c3                   	ret    
  801635:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801638:	39 f5                	cmp    %esi,%ebp
  80163a:	72 04                	jb     801640 <__umoddi3+0x104>
  80163c:	39 f9                	cmp    %edi,%ecx
  80163e:	77 06                	ja     801646 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801640:	89 f2                	mov    %esi,%edx
  801642:	29 cf                	sub    %ecx,%edi
  801644:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801646:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801648:	83 c4 20             	add    $0x20,%esp
  80164b:	5e                   	pop    %esi
  80164c:	5f                   	pop    %edi
  80164d:	5d                   	pop    %ebp
  80164e:	c3                   	ret    
  80164f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801650:	89 d1                	mov    %edx,%ecx
  801652:	89 c5                	mov    %eax,%ebp
  801654:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801658:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  80165c:	eb 8d                	jmp    8015eb <__umoddi3+0xaf>
  80165e:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801660:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801664:	72 ea                	jb     801650 <__umoddi3+0x114>
  801666:	89 f1                	mov    %esi,%ecx
  801668:	eb 81                	jmp    8015eb <__umoddi3+0xaf>
