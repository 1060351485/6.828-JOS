
obj/user/sendpage.debug:     file format elf32-i386


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
  80002c:	e8 af 01 00 00       	call   8001e0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
#define TEMP_ADDR	((char*)0xa00000)
#define TEMP_ADDR_CHILD	((char*)0xb00000)

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 28             	sub    $0x28,%esp
	envid_t who;

	if ((who = fork()) == 0) {
  80003a:	e8 34 10 00 00       	call   801073 <fork>
  80003f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800042:	85 c0                	test   %eax,%eax
  800044:	0f 85 bb 00 00 00    	jne    800105 <umain+0xd1>
		// Child
		ipc_recv(&who, TEMP_ADDR_CHILD, 0);
  80004a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800051:	00 
  800052:	c7 44 24 04 00 00 b0 	movl   $0xb00000,0x4(%esp)
  800059:	00 
  80005a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80005d:	89 04 24             	mov    %eax,(%esp)
  800060:	e8 ff 12 00 00       	call   801364 <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  800065:	c7 44 24 08 00 00 b0 	movl   $0xb00000,0x8(%esp)
  80006c:	00 
  80006d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800070:	89 44 24 04          	mov    %eax,0x4(%esp)
  800074:	c7 04 24 c0 17 80 00 	movl   $0x8017c0,(%esp)
  80007b:	e8 5c 02 00 00       	call   8002dc <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800080:	a1 04 20 80 00       	mov    0x802004,%eax
  800085:	89 04 24             	mov    %eax,(%esp)
  800088:	e8 c7 07 00 00       	call   800854 <strlen>
  80008d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800091:	a1 04 20 80 00       	mov    0x802004,%eax
  800096:	89 44 24 04          	mov    %eax,0x4(%esp)
  80009a:	c7 04 24 00 00 b0 00 	movl   $0xb00000,(%esp)
  8000a1:	e8 a9 08 00 00       	call   80094f <strncmp>
  8000a6:	85 c0                	test   %eax,%eax
  8000a8:	75 0c                	jne    8000b6 <umain+0x82>
			cprintf("child received correct message\n");
  8000aa:	c7 04 24 d4 17 80 00 	movl   $0x8017d4,(%esp)
  8000b1:	e8 26 02 00 00       	call   8002dc <cprintf>

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  8000b6:	a1 00 20 80 00       	mov    0x802000,%eax
  8000bb:	89 04 24             	mov    %eax,(%esp)
  8000be:	e8 91 07 00 00       	call   800854 <strlen>
  8000c3:	40                   	inc    %eax
  8000c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000c8:	a1 00 20 80 00       	mov    0x802000,%eax
  8000cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000d1:	c7 04 24 00 00 b0 00 	movl   $0xb00000,(%esp)
  8000d8:	e8 8d 09 00 00       	call   800a6a <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000dd:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8000e4:	00 
  8000e5:	c7 44 24 08 00 00 b0 	movl   $0xb00000,0x8(%esp)
  8000ec:	00 
  8000ed:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000f4:	00 
  8000f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000f8:	89 04 24             	mov    %eax,(%esp)
  8000fb:	e8 cd 12 00 00       	call   8013cd <ipc_send>
		return;
  800100:	e9 d6 00 00 00       	jmp    8001db <umain+0x1a7>
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800105:	a1 0c 20 80 00       	mov    0x80200c,%eax
  80010a:	8b 40 48             	mov    0x48(%eax),%eax
  80010d:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800114:	00 
  800115:	c7 44 24 04 00 00 a0 	movl   $0xa00000,0x4(%esp)
  80011c:	00 
  80011d:	89 04 24             	mov    %eax,(%esp)
  800120:	e8 54 0b 00 00       	call   800c79 <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800125:	a1 04 20 80 00       	mov    0x802004,%eax
  80012a:	89 04 24             	mov    %eax,(%esp)
  80012d:	e8 22 07 00 00       	call   800854 <strlen>
  800132:	40                   	inc    %eax
  800133:	89 44 24 08          	mov    %eax,0x8(%esp)
  800137:	a1 04 20 80 00       	mov    0x802004,%eax
  80013c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800140:	c7 04 24 00 00 a0 00 	movl   $0xa00000,(%esp)
  800147:	e8 1e 09 00 00       	call   800a6a <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  80014c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800153:	00 
  800154:	c7 44 24 08 00 00 a0 	movl   $0xa00000,0x8(%esp)
  80015b:	00 
  80015c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800163:	00 
  800164:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800167:	89 04 24             	mov    %eax,(%esp)
  80016a:	e8 5e 12 00 00       	call   8013cd <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  80016f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800176:	00 
  800177:	c7 44 24 04 00 00 a0 	movl   $0xa00000,0x4(%esp)
  80017e:	00 
  80017f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800182:	89 04 24             	mov    %eax,(%esp)
  800185:	e8 da 11 00 00       	call   801364 <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  80018a:	c7 44 24 08 00 00 a0 	movl   $0xa00000,0x8(%esp)
  800191:	00 
  800192:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800195:	89 44 24 04          	mov    %eax,0x4(%esp)
  800199:	c7 04 24 c0 17 80 00 	movl   $0x8017c0,(%esp)
  8001a0:	e8 37 01 00 00       	call   8002dc <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  8001a5:	a1 00 20 80 00       	mov    0x802000,%eax
  8001aa:	89 04 24             	mov    %eax,(%esp)
  8001ad:	e8 a2 06 00 00       	call   800854 <strlen>
  8001b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001b6:	a1 00 20 80 00       	mov    0x802000,%eax
  8001bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001bf:	c7 04 24 00 00 a0 00 	movl   $0xa00000,(%esp)
  8001c6:	e8 84 07 00 00       	call   80094f <strncmp>
  8001cb:	85 c0                	test   %eax,%eax
  8001cd:	75 0c                	jne    8001db <umain+0x1a7>
		cprintf("parent received correct message\n");
  8001cf:	c7 04 24 f4 17 80 00 	movl   $0x8017f4,(%esp)
  8001d6:	e8 01 01 00 00       	call   8002dc <cprintf>
	return;
}
  8001db:	c9                   	leave  
  8001dc:	c3                   	ret    
  8001dd:	00 00                	add    %al,(%eax)
	...

008001e0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	56                   	push   %esi
  8001e4:	53                   	push   %ebx
  8001e5:	83 ec 10             	sub    $0x10,%esp
  8001e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8001eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001ee:	e8 48 0a 00 00       	call   800c3b <sys_getenvid>
  8001f3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001f8:	c1 e0 07             	shl    $0x7,%eax
  8001fb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800200:	a3 0c 20 80 00       	mov    %eax,0x80200c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800205:	85 f6                	test   %esi,%esi
  800207:	7e 07                	jle    800210 <libmain+0x30>
		binaryname = argv[0];
  800209:	8b 03                	mov    (%ebx),%eax
  80020b:	a3 08 20 80 00       	mov    %eax,0x802008

	// call user main routine
	umain(argc, argv);
  800210:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800214:	89 34 24             	mov    %esi,(%esp)
  800217:	e8 18 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80021c:	e8 07 00 00 00       	call   800228 <exit>
}
  800221:	83 c4 10             	add    $0x10,%esp
  800224:	5b                   	pop    %ebx
  800225:	5e                   	pop    %esi
  800226:	5d                   	pop    %ebp
  800227:	c3                   	ret    

00800228 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800228:	55                   	push   %ebp
  800229:	89 e5                	mov    %esp,%ebp
  80022b:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  80022e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800235:	e8 af 09 00 00       	call   800be9 <sys_env_destroy>
}
  80023a:	c9                   	leave  
  80023b:	c3                   	ret    

0080023c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80023c:	55                   	push   %ebp
  80023d:	89 e5                	mov    %esp,%ebp
  80023f:	53                   	push   %ebx
  800240:	83 ec 14             	sub    $0x14,%esp
  800243:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800246:	8b 03                	mov    (%ebx),%eax
  800248:	8b 55 08             	mov    0x8(%ebp),%edx
  80024b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80024f:	40                   	inc    %eax
  800250:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800252:	3d ff 00 00 00       	cmp    $0xff,%eax
  800257:	75 19                	jne    800272 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800259:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800260:	00 
  800261:	8d 43 08             	lea    0x8(%ebx),%eax
  800264:	89 04 24             	mov    %eax,(%esp)
  800267:	e8 40 09 00 00       	call   800bac <sys_cputs>
		b->idx = 0;
  80026c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800272:	ff 43 04             	incl   0x4(%ebx)
}
  800275:	83 c4 14             	add    $0x14,%esp
  800278:	5b                   	pop    %ebx
  800279:	5d                   	pop    %ebp
  80027a:	c3                   	ret    

0080027b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80027b:	55                   	push   %ebp
  80027c:	89 e5                	mov    %esp,%ebp
  80027e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800284:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80028b:	00 00 00 
	b.cnt = 0;
  80028e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800295:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800298:	8b 45 0c             	mov    0xc(%ebp),%eax
  80029b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80029f:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002a6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b0:	c7 04 24 3c 02 80 00 	movl   $0x80023c,(%esp)
  8002b7:	e8 82 01 00 00       	call   80043e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002bc:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002cc:	89 04 24             	mov    %eax,(%esp)
  8002cf:	e8 d8 08 00 00       	call   800bac <sys_cputs>

	return b.cnt;
}
  8002d4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002da:	c9                   	leave  
  8002db:	c3                   	ret    

008002dc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002dc:	55                   	push   %ebp
  8002dd:	89 e5                	mov    %esp,%ebp
  8002df:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002e2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ec:	89 04 24             	mov    %eax,(%esp)
  8002ef:	e8 87 ff ff ff       	call   80027b <vcprintf>
	va_end(ap);

	return cnt;
}
  8002f4:	c9                   	leave  
  8002f5:	c3                   	ret    
	...

008002f8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	57                   	push   %edi
  8002fc:	56                   	push   %esi
  8002fd:	53                   	push   %ebx
  8002fe:	83 ec 3c             	sub    $0x3c,%esp
  800301:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800304:	89 d7                	mov    %edx,%edi
  800306:	8b 45 08             	mov    0x8(%ebp),%eax
  800309:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80030c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80030f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800312:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800315:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800318:	85 c0                	test   %eax,%eax
  80031a:	75 08                	jne    800324 <printnum+0x2c>
  80031c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80031f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800322:	77 57                	ja     80037b <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800324:	89 74 24 10          	mov    %esi,0x10(%esp)
  800328:	4b                   	dec    %ebx
  800329:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80032d:	8b 45 10             	mov    0x10(%ebp),%eax
  800330:	89 44 24 08          	mov    %eax,0x8(%esp)
  800334:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800338:	8b 74 24 0c          	mov    0xc(%esp),%esi
  80033c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800343:	00 
  800344:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800347:	89 04 24             	mov    %eax,(%esp)
  80034a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80034d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800351:	e8 0e 12 00 00       	call   801564 <__udivdi3>
  800356:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80035a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80035e:	89 04 24             	mov    %eax,(%esp)
  800361:	89 54 24 04          	mov    %edx,0x4(%esp)
  800365:	89 fa                	mov    %edi,%edx
  800367:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80036a:	e8 89 ff ff ff       	call   8002f8 <printnum>
  80036f:	eb 0f                	jmp    800380 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800371:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800375:	89 34 24             	mov    %esi,(%esp)
  800378:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80037b:	4b                   	dec    %ebx
  80037c:	85 db                	test   %ebx,%ebx
  80037e:	7f f1                	jg     800371 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800380:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800384:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800388:	8b 45 10             	mov    0x10(%ebp),%eax
  80038b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80038f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800396:	00 
  800397:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80039a:	89 04 24             	mov    %eax,(%esp)
  80039d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003a4:	e8 db 12 00 00       	call   801684 <__umoddi3>
  8003a9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003ad:	0f be 80 6c 18 80 00 	movsbl 0x80186c(%eax),%eax
  8003b4:	89 04 24             	mov    %eax,(%esp)
  8003b7:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8003ba:	83 c4 3c             	add    $0x3c,%esp
  8003bd:	5b                   	pop    %ebx
  8003be:	5e                   	pop    %esi
  8003bf:	5f                   	pop    %edi
  8003c0:	5d                   	pop    %ebp
  8003c1:	c3                   	ret    

008003c2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003c2:	55                   	push   %ebp
  8003c3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003c5:	83 fa 01             	cmp    $0x1,%edx
  8003c8:	7e 0e                	jle    8003d8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003ca:	8b 10                	mov    (%eax),%edx
  8003cc:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003cf:	89 08                	mov    %ecx,(%eax)
  8003d1:	8b 02                	mov    (%edx),%eax
  8003d3:	8b 52 04             	mov    0x4(%edx),%edx
  8003d6:	eb 22                	jmp    8003fa <getuint+0x38>
	else if (lflag)
  8003d8:	85 d2                	test   %edx,%edx
  8003da:	74 10                	je     8003ec <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003dc:	8b 10                	mov    (%eax),%edx
  8003de:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003e1:	89 08                	mov    %ecx,(%eax)
  8003e3:	8b 02                	mov    (%edx),%eax
  8003e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ea:	eb 0e                	jmp    8003fa <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003ec:	8b 10                	mov    (%eax),%edx
  8003ee:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f1:	89 08                	mov    %ecx,(%eax)
  8003f3:	8b 02                	mov    (%edx),%eax
  8003f5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003fa:	5d                   	pop    %ebp
  8003fb:	c3                   	ret    

008003fc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003fc:	55                   	push   %ebp
  8003fd:	89 e5                	mov    %esp,%ebp
  8003ff:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800402:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800405:	8b 10                	mov    (%eax),%edx
  800407:	3b 50 04             	cmp    0x4(%eax),%edx
  80040a:	73 08                	jae    800414 <sprintputch+0x18>
		*b->buf++ = ch;
  80040c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80040f:	88 0a                	mov    %cl,(%edx)
  800411:	42                   	inc    %edx
  800412:	89 10                	mov    %edx,(%eax)
}
  800414:	5d                   	pop    %ebp
  800415:	c3                   	ret    

00800416 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800416:	55                   	push   %ebp
  800417:	89 e5                	mov    %esp,%ebp
  800419:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80041c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80041f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800423:	8b 45 10             	mov    0x10(%ebp),%eax
  800426:	89 44 24 08          	mov    %eax,0x8(%esp)
  80042a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80042d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800431:	8b 45 08             	mov    0x8(%ebp),%eax
  800434:	89 04 24             	mov    %eax,(%esp)
  800437:	e8 02 00 00 00       	call   80043e <vprintfmt>
	va_end(ap);
}
  80043c:	c9                   	leave  
  80043d:	c3                   	ret    

0080043e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80043e:	55                   	push   %ebp
  80043f:	89 e5                	mov    %esp,%ebp
  800441:	57                   	push   %edi
  800442:	56                   	push   %esi
  800443:	53                   	push   %ebx
  800444:	83 ec 4c             	sub    $0x4c,%esp
  800447:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80044a:	8b 75 10             	mov    0x10(%ebp),%esi
  80044d:	eb 12                	jmp    800461 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80044f:	85 c0                	test   %eax,%eax
  800451:	0f 84 6b 03 00 00    	je     8007c2 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800457:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80045b:	89 04 24             	mov    %eax,(%esp)
  80045e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800461:	0f b6 06             	movzbl (%esi),%eax
  800464:	46                   	inc    %esi
  800465:	83 f8 25             	cmp    $0x25,%eax
  800468:	75 e5                	jne    80044f <vprintfmt+0x11>
  80046a:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80046e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800475:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80047a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800481:	b9 00 00 00 00       	mov    $0x0,%ecx
  800486:	eb 26                	jmp    8004ae <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800488:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80048b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80048f:	eb 1d                	jmp    8004ae <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800491:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800494:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800498:	eb 14                	jmp    8004ae <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80049d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004a4:	eb 08                	jmp    8004ae <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004a6:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8004a9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ae:	0f b6 06             	movzbl (%esi),%eax
  8004b1:	8d 56 01             	lea    0x1(%esi),%edx
  8004b4:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004b7:	8a 16                	mov    (%esi),%dl
  8004b9:	83 ea 23             	sub    $0x23,%edx
  8004bc:	80 fa 55             	cmp    $0x55,%dl
  8004bf:	0f 87 e1 02 00 00    	ja     8007a6 <vprintfmt+0x368>
  8004c5:	0f b6 d2             	movzbl %dl,%edx
  8004c8:	ff 24 95 c0 19 80 00 	jmp    *0x8019c0(,%edx,4)
  8004cf:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004d2:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004d7:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8004da:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8004de:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004e1:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004e4:	83 fa 09             	cmp    $0x9,%edx
  8004e7:	77 2a                	ja     800513 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004e9:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004ea:	eb eb                	jmp    8004d7 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ef:	8d 50 04             	lea    0x4(%eax),%edx
  8004f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f5:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004fa:	eb 17                	jmp    800513 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8004fc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800500:	78 98                	js     80049a <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800502:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800505:	eb a7                	jmp    8004ae <vprintfmt+0x70>
  800507:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80050a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800511:	eb 9b                	jmp    8004ae <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800513:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800517:	79 95                	jns    8004ae <vprintfmt+0x70>
  800519:	eb 8b                	jmp    8004a6 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80051b:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80051f:	eb 8d                	jmp    8004ae <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800521:	8b 45 14             	mov    0x14(%ebp),%eax
  800524:	8d 50 04             	lea    0x4(%eax),%edx
  800527:	89 55 14             	mov    %edx,0x14(%ebp)
  80052a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80052e:	8b 00                	mov    (%eax),%eax
  800530:	89 04 24             	mov    %eax,(%esp)
  800533:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800536:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800539:	e9 23 ff ff ff       	jmp    800461 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80053e:	8b 45 14             	mov    0x14(%ebp),%eax
  800541:	8d 50 04             	lea    0x4(%eax),%edx
  800544:	89 55 14             	mov    %edx,0x14(%ebp)
  800547:	8b 00                	mov    (%eax),%eax
  800549:	85 c0                	test   %eax,%eax
  80054b:	79 02                	jns    80054f <vprintfmt+0x111>
  80054d:	f7 d8                	neg    %eax
  80054f:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800551:	83 f8 11             	cmp    $0x11,%eax
  800554:	7f 0b                	jg     800561 <vprintfmt+0x123>
  800556:	8b 04 85 20 1b 80 00 	mov    0x801b20(,%eax,4),%eax
  80055d:	85 c0                	test   %eax,%eax
  80055f:	75 23                	jne    800584 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800561:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800565:	c7 44 24 08 84 18 80 	movl   $0x801884,0x8(%esp)
  80056c:	00 
  80056d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800571:	8b 45 08             	mov    0x8(%ebp),%eax
  800574:	89 04 24             	mov    %eax,(%esp)
  800577:	e8 9a fe ff ff       	call   800416 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80057f:	e9 dd fe ff ff       	jmp    800461 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800584:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800588:	c7 44 24 08 8d 18 80 	movl   $0x80188d,0x8(%esp)
  80058f:	00 
  800590:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800594:	8b 55 08             	mov    0x8(%ebp),%edx
  800597:	89 14 24             	mov    %edx,(%esp)
  80059a:	e8 77 fe ff ff       	call   800416 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005a2:	e9 ba fe ff ff       	jmp    800461 <vprintfmt+0x23>
  8005a7:	89 f9                	mov    %edi,%ecx
  8005a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005ac:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005af:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b2:	8d 50 04             	lea    0x4(%eax),%edx
  8005b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b8:	8b 30                	mov    (%eax),%esi
  8005ba:	85 f6                	test   %esi,%esi
  8005bc:	75 05                	jne    8005c3 <vprintfmt+0x185>
				p = "(null)";
  8005be:	be 7d 18 80 00       	mov    $0x80187d,%esi
			if (width > 0 && padc != '-')
  8005c3:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005c7:	0f 8e 84 00 00 00    	jle    800651 <vprintfmt+0x213>
  8005cd:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8005d1:	74 7e                	je     800651 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005d7:	89 34 24             	mov    %esi,(%esp)
  8005da:	e8 8b 02 00 00       	call   80086a <strnlen>
  8005df:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005e2:	29 c2                	sub    %eax,%edx
  8005e4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8005e7:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8005eb:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8005ee:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8005f1:	89 de                	mov    %ebx,%esi
  8005f3:	89 d3                	mov    %edx,%ebx
  8005f5:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f7:	eb 0b                	jmp    800604 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8005f9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005fd:	89 3c 24             	mov    %edi,(%esp)
  800600:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800603:	4b                   	dec    %ebx
  800604:	85 db                	test   %ebx,%ebx
  800606:	7f f1                	jg     8005f9 <vprintfmt+0x1bb>
  800608:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80060b:	89 f3                	mov    %esi,%ebx
  80060d:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800610:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800613:	85 c0                	test   %eax,%eax
  800615:	79 05                	jns    80061c <vprintfmt+0x1de>
  800617:	b8 00 00 00 00       	mov    $0x0,%eax
  80061c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80061f:	29 c2                	sub    %eax,%edx
  800621:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800624:	eb 2b                	jmp    800651 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800626:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80062a:	74 18                	je     800644 <vprintfmt+0x206>
  80062c:	8d 50 e0             	lea    -0x20(%eax),%edx
  80062f:	83 fa 5e             	cmp    $0x5e,%edx
  800632:	76 10                	jbe    800644 <vprintfmt+0x206>
					putch('?', putdat);
  800634:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800638:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80063f:	ff 55 08             	call   *0x8(%ebp)
  800642:	eb 0a                	jmp    80064e <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800644:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800648:	89 04 24             	mov    %eax,(%esp)
  80064b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80064e:	ff 4d e4             	decl   -0x1c(%ebp)
  800651:	0f be 06             	movsbl (%esi),%eax
  800654:	46                   	inc    %esi
  800655:	85 c0                	test   %eax,%eax
  800657:	74 21                	je     80067a <vprintfmt+0x23c>
  800659:	85 ff                	test   %edi,%edi
  80065b:	78 c9                	js     800626 <vprintfmt+0x1e8>
  80065d:	4f                   	dec    %edi
  80065e:	79 c6                	jns    800626 <vprintfmt+0x1e8>
  800660:	8b 7d 08             	mov    0x8(%ebp),%edi
  800663:	89 de                	mov    %ebx,%esi
  800665:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800668:	eb 18                	jmp    800682 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80066a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80066e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800675:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800677:	4b                   	dec    %ebx
  800678:	eb 08                	jmp    800682 <vprintfmt+0x244>
  80067a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80067d:	89 de                	mov    %ebx,%esi
  80067f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800682:	85 db                	test   %ebx,%ebx
  800684:	7f e4                	jg     80066a <vprintfmt+0x22c>
  800686:	89 7d 08             	mov    %edi,0x8(%ebp)
  800689:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80068e:	e9 ce fd ff ff       	jmp    800461 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800693:	83 f9 01             	cmp    $0x1,%ecx
  800696:	7e 10                	jle    8006a8 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800698:	8b 45 14             	mov    0x14(%ebp),%eax
  80069b:	8d 50 08             	lea    0x8(%eax),%edx
  80069e:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a1:	8b 30                	mov    (%eax),%esi
  8006a3:	8b 78 04             	mov    0x4(%eax),%edi
  8006a6:	eb 26                	jmp    8006ce <vprintfmt+0x290>
	else if (lflag)
  8006a8:	85 c9                	test   %ecx,%ecx
  8006aa:	74 12                	je     8006be <vprintfmt+0x280>
		return va_arg(*ap, long);
  8006ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8006af:	8d 50 04             	lea    0x4(%eax),%edx
  8006b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b5:	8b 30                	mov    (%eax),%esi
  8006b7:	89 f7                	mov    %esi,%edi
  8006b9:	c1 ff 1f             	sar    $0x1f,%edi
  8006bc:	eb 10                	jmp    8006ce <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8006be:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c1:	8d 50 04             	lea    0x4(%eax),%edx
  8006c4:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c7:	8b 30                	mov    (%eax),%esi
  8006c9:	89 f7                	mov    %esi,%edi
  8006cb:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006ce:	85 ff                	test   %edi,%edi
  8006d0:	78 0a                	js     8006dc <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006d2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006d7:	e9 8c 00 00 00       	jmp    800768 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8006dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e0:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006e7:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006ea:	f7 de                	neg    %esi
  8006ec:	83 d7 00             	adc    $0x0,%edi
  8006ef:	f7 df                	neg    %edi
			}
			base = 10;
  8006f1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006f6:	eb 70                	jmp    800768 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006f8:	89 ca                	mov    %ecx,%edx
  8006fa:	8d 45 14             	lea    0x14(%ebp),%eax
  8006fd:	e8 c0 fc ff ff       	call   8003c2 <getuint>
  800702:	89 c6                	mov    %eax,%esi
  800704:	89 d7                	mov    %edx,%edi
			base = 10;
  800706:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80070b:	eb 5b                	jmp    800768 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  80070d:	89 ca                	mov    %ecx,%edx
  80070f:	8d 45 14             	lea    0x14(%ebp),%eax
  800712:	e8 ab fc ff ff       	call   8003c2 <getuint>
  800717:	89 c6                	mov    %eax,%esi
  800719:	89 d7                	mov    %edx,%edi
			base = 8;
  80071b:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800720:	eb 46                	jmp    800768 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  800722:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800726:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80072d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800730:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800734:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80073b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80073e:	8b 45 14             	mov    0x14(%ebp),%eax
  800741:	8d 50 04             	lea    0x4(%eax),%edx
  800744:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800747:	8b 30                	mov    (%eax),%esi
  800749:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80074e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800753:	eb 13                	jmp    800768 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800755:	89 ca                	mov    %ecx,%edx
  800757:	8d 45 14             	lea    0x14(%ebp),%eax
  80075a:	e8 63 fc ff ff       	call   8003c2 <getuint>
  80075f:	89 c6                	mov    %eax,%esi
  800761:	89 d7                	mov    %edx,%edi
			base = 16;
  800763:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800768:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  80076c:	89 54 24 10          	mov    %edx,0x10(%esp)
  800770:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800773:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800777:	89 44 24 08          	mov    %eax,0x8(%esp)
  80077b:	89 34 24             	mov    %esi,(%esp)
  80077e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800782:	89 da                	mov    %ebx,%edx
  800784:	8b 45 08             	mov    0x8(%ebp),%eax
  800787:	e8 6c fb ff ff       	call   8002f8 <printnum>
			break;
  80078c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80078f:	e9 cd fc ff ff       	jmp    800461 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800794:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800798:	89 04 24             	mov    %eax,(%esp)
  80079b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80079e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007a1:	e9 bb fc ff ff       	jmp    800461 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007a6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007aa:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007b1:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007b4:	eb 01                	jmp    8007b7 <vprintfmt+0x379>
  8007b6:	4e                   	dec    %esi
  8007b7:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007bb:	75 f9                	jne    8007b6 <vprintfmt+0x378>
  8007bd:	e9 9f fc ff ff       	jmp    800461 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8007c2:	83 c4 4c             	add    $0x4c,%esp
  8007c5:	5b                   	pop    %ebx
  8007c6:	5e                   	pop    %esi
  8007c7:	5f                   	pop    %edi
  8007c8:	5d                   	pop    %ebp
  8007c9:	c3                   	ret    

008007ca <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007ca:	55                   	push   %ebp
  8007cb:	89 e5                	mov    %esp,%ebp
  8007cd:	83 ec 28             	sub    $0x28,%esp
  8007d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007d6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007d9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007dd:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007e0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007e7:	85 c0                	test   %eax,%eax
  8007e9:	74 30                	je     80081b <vsnprintf+0x51>
  8007eb:	85 d2                	test   %edx,%edx
  8007ed:	7e 33                	jle    800822 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007f6:	8b 45 10             	mov    0x10(%ebp),%eax
  8007f9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007fd:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800800:	89 44 24 04          	mov    %eax,0x4(%esp)
  800804:	c7 04 24 fc 03 80 00 	movl   $0x8003fc,(%esp)
  80080b:	e8 2e fc ff ff       	call   80043e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800810:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800813:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800816:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800819:	eb 0c                	jmp    800827 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80081b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800820:	eb 05                	jmp    800827 <vsnprintf+0x5d>
  800822:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800827:	c9                   	leave  
  800828:	c3                   	ret    

00800829 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800829:	55                   	push   %ebp
  80082a:	89 e5                	mov    %esp,%ebp
  80082c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80082f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800832:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800836:	8b 45 10             	mov    0x10(%ebp),%eax
  800839:	89 44 24 08          	mov    %eax,0x8(%esp)
  80083d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800840:	89 44 24 04          	mov    %eax,0x4(%esp)
  800844:	8b 45 08             	mov    0x8(%ebp),%eax
  800847:	89 04 24             	mov    %eax,(%esp)
  80084a:	e8 7b ff ff ff       	call   8007ca <vsnprintf>
	va_end(ap);

	return rc;
}
  80084f:	c9                   	leave  
  800850:	c3                   	ret    
  800851:	00 00                	add    %al,(%eax)
	...

00800854 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800854:	55                   	push   %ebp
  800855:	89 e5                	mov    %esp,%ebp
  800857:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80085a:	b8 00 00 00 00       	mov    $0x0,%eax
  80085f:	eb 01                	jmp    800862 <strlen+0xe>
		n++;
  800861:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800862:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800866:	75 f9                	jne    800861 <strlen+0xd>
		n++;
	return n;
}
  800868:	5d                   	pop    %ebp
  800869:	c3                   	ret    

0080086a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800870:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800873:	b8 00 00 00 00       	mov    $0x0,%eax
  800878:	eb 01                	jmp    80087b <strnlen+0x11>
		n++;
  80087a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80087b:	39 d0                	cmp    %edx,%eax
  80087d:	74 06                	je     800885 <strnlen+0x1b>
  80087f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800883:	75 f5                	jne    80087a <strnlen+0x10>
		n++;
	return n;
}
  800885:	5d                   	pop    %ebp
  800886:	c3                   	ret    

00800887 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	53                   	push   %ebx
  80088b:	8b 45 08             	mov    0x8(%ebp),%eax
  80088e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800891:	ba 00 00 00 00       	mov    $0x0,%edx
  800896:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800899:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80089c:	42                   	inc    %edx
  80089d:	84 c9                	test   %cl,%cl
  80089f:	75 f5                	jne    800896 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008a1:	5b                   	pop    %ebx
  8008a2:	5d                   	pop    %ebp
  8008a3:	c3                   	ret    

008008a4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008a4:	55                   	push   %ebp
  8008a5:	89 e5                	mov    %esp,%ebp
  8008a7:	53                   	push   %ebx
  8008a8:	83 ec 08             	sub    $0x8,%esp
  8008ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008ae:	89 1c 24             	mov    %ebx,(%esp)
  8008b1:	e8 9e ff ff ff       	call   800854 <strlen>
	strcpy(dst + len, src);
  8008b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008bd:	01 d8                	add    %ebx,%eax
  8008bf:	89 04 24             	mov    %eax,(%esp)
  8008c2:	e8 c0 ff ff ff       	call   800887 <strcpy>
	return dst;
}
  8008c7:	89 d8                	mov    %ebx,%eax
  8008c9:	83 c4 08             	add    $0x8,%esp
  8008cc:	5b                   	pop    %ebx
  8008cd:	5d                   	pop    %ebp
  8008ce:	c3                   	ret    

008008cf <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008cf:	55                   	push   %ebp
  8008d0:	89 e5                	mov    %esp,%ebp
  8008d2:	56                   	push   %esi
  8008d3:	53                   	push   %ebx
  8008d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008da:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008dd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008e2:	eb 0c                	jmp    8008f0 <strncpy+0x21>
		*dst++ = *src;
  8008e4:	8a 1a                	mov    (%edx),%bl
  8008e6:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008e9:	80 3a 01             	cmpb   $0x1,(%edx)
  8008ec:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008ef:	41                   	inc    %ecx
  8008f0:	39 f1                	cmp    %esi,%ecx
  8008f2:	75 f0                	jne    8008e4 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008f4:	5b                   	pop    %ebx
  8008f5:	5e                   	pop    %esi
  8008f6:	5d                   	pop    %ebp
  8008f7:	c3                   	ret    

008008f8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008f8:	55                   	push   %ebp
  8008f9:	89 e5                	mov    %esp,%ebp
  8008fb:	56                   	push   %esi
  8008fc:	53                   	push   %ebx
  8008fd:	8b 75 08             	mov    0x8(%ebp),%esi
  800900:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800903:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800906:	85 d2                	test   %edx,%edx
  800908:	75 0a                	jne    800914 <strlcpy+0x1c>
  80090a:	89 f0                	mov    %esi,%eax
  80090c:	eb 1a                	jmp    800928 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80090e:	88 18                	mov    %bl,(%eax)
  800910:	40                   	inc    %eax
  800911:	41                   	inc    %ecx
  800912:	eb 02                	jmp    800916 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800914:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800916:	4a                   	dec    %edx
  800917:	74 0a                	je     800923 <strlcpy+0x2b>
  800919:	8a 19                	mov    (%ecx),%bl
  80091b:	84 db                	test   %bl,%bl
  80091d:	75 ef                	jne    80090e <strlcpy+0x16>
  80091f:	89 c2                	mov    %eax,%edx
  800921:	eb 02                	jmp    800925 <strlcpy+0x2d>
  800923:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800925:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800928:	29 f0                	sub    %esi,%eax
}
  80092a:	5b                   	pop    %ebx
  80092b:	5e                   	pop    %esi
  80092c:	5d                   	pop    %ebp
  80092d:	c3                   	ret    

0080092e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80092e:	55                   	push   %ebp
  80092f:	89 e5                	mov    %esp,%ebp
  800931:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800934:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800937:	eb 02                	jmp    80093b <strcmp+0xd>
		p++, q++;
  800939:	41                   	inc    %ecx
  80093a:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80093b:	8a 01                	mov    (%ecx),%al
  80093d:	84 c0                	test   %al,%al
  80093f:	74 04                	je     800945 <strcmp+0x17>
  800941:	3a 02                	cmp    (%edx),%al
  800943:	74 f4                	je     800939 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800945:	0f b6 c0             	movzbl %al,%eax
  800948:	0f b6 12             	movzbl (%edx),%edx
  80094b:	29 d0                	sub    %edx,%eax
}
  80094d:	5d                   	pop    %ebp
  80094e:	c3                   	ret    

0080094f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80094f:	55                   	push   %ebp
  800950:	89 e5                	mov    %esp,%ebp
  800952:	53                   	push   %ebx
  800953:	8b 45 08             	mov    0x8(%ebp),%eax
  800956:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800959:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  80095c:	eb 03                	jmp    800961 <strncmp+0x12>
		n--, p++, q++;
  80095e:	4a                   	dec    %edx
  80095f:	40                   	inc    %eax
  800960:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800961:	85 d2                	test   %edx,%edx
  800963:	74 14                	je     800979 <strncmp+0x2a>
  800965:	8a 18                	mov    (%eax),%bl
  800967:	84 db                	test   %bl,%bl
  800969:	74 04                	je     80096f <strncmp+0x20>
  80096b:	3a 19                	cmp    (%ecx),%bl
  80096d:	74 ef                	je     80095e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80096f:	0f b6 00             	movzbl (%eax),%eax
  800972:	0f b6 11             	movzbl (%ecx),%edx
  800975:	29 d0                	sub    %edx,%eax
  800977:	eb 05                	jmp    80097e <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800979:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80097e:	5b                   	pop    %ebx
  80097f:	5d                   	pop    %ebp
  800980:	c3                   	ret    

00800981 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800981:	55                   	push   %ebp
  800982:	89 e5                	mov    %esp,%ebp
  800984:	8b 45 08             	mov    0x8(%ebp),%eax
  800987:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80098a:	eb 05                	jmp    800991 <strchr+0x10>
		if (*s == c)
  80098c:	38 ca                	cmp    %cl,%dl
  80098e:	74 0c                	je     80099c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800990:	40                   	inc    %eax
  800991:	8a 10                	mov    (%eax),%dl
  800993:	84 d2                	test   %dl,%dl
  800995:	75 f5                	jne    80098c <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800997:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80099c:	5d                   	pop    %ebp
  80099d:	c3                   	ret    

0080099e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
  8009a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a4:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009a7:	eb 05                	jmp    8009ae <strfind+0x10>
		if (*s == c)
  8009a9:	38 ca                	cmp    %cl,%dl
  8009ab:	74 07                	je     8009b4 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009ad:	40                   	inc    %eax
  8009ae:	8a 10                	mov    (%eax),%dl
  8009b0:	84 d2                	test   %dl,%dl
  8009b2:	75 f5                	jne    8009a9 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8009b4:	5d                   	pop    %ebp
  8009b5:	c3                   	ret    

008009b6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009b6:	55                   	push   %ebp
  8009b7:	89 e5                	mov    %esp,%ebp
  8009b9:	57                   	push   %edi
  8009ba:	56                   	push   %esi
  8009bb:	53                   	push   %ebx
  8009bc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009c5:	85 c9                	test   %ecx,%ecx
  8009c7:	74 30                	je     8009f9 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009c9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009cf:	75 25                	jne    8009f6 <memset+0x40>
  8009d1:	f6 c1 03             	test   $0x3,%cl
  8009d4:	75 20                	jne    8009f6 <memset+0x40>
		c &= 0xFF;
  8009d6:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009d9:	89 d3                	mov    %edx,%ebx
  8009db:	c1 e3 08             	shl    $0x8,%ebx
  8009de:	89 d6                	mov    %edx,%esi
  8009e0:	c1 e6 18             	shl    $0x18,%esi
  8009e3:	89 d0                	mov    %edx,%eax
  8009e5:	c1 e0 10             	shl    $0x10,%eax
  8009e8:	09 f0                	or     %esi,%eax
  8009ea:	09 d0                	or     %edx,%eax
  8009ec:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009ee:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009f1:	fc                   	cld    
  8009f2:	f3 ab                	rep stos %eax,%es:(%edi)
  8009f4:	eb 03                	jmp    8009f9 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009f6:	fc                   	cld    
  8009f7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009f9:	89 f8                	mov    %edi,%eax
  8009fb:	5b                   	pop    %ebx
  8009fc:	5e                   	pop    %esi
  8009fd:	5f                   	pop    %edi
  8009fe:	5d                   	pop    %ebp
  8009ff:	c3                   	ret    

00800a00 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	57                   	push   %edi
  800a04:	56                   	push   %esi
  800a05:	8b 45 08             	mov    0x8(%ebp),%eax
  800a08:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a0b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a0e:	39 c6                	cmp    %eax,%esi
  800a10:	73 34                	jae    800a46 <memmove+0x46>
  800a12:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a15:	39 d0                	cmp    %edx,%eax
  800a17:	73 2d                	jae    800a46 <memmove+0x46>
		s += n;
		d += n;
  800a19:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a1c:	f6 c2 03             	test   $0x3,%dl
  800a1f:	75 1b                	jne    800a3c <memmove+0x3c>
  800a21:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a27:	75 13                	jne    800a3c <memmove+0x3c>
  800a29:	f6 c1 03             	test   $0x3,%cl
  800a2c:	75 0e                	jne    800a3c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a2e:	83 ef 04             	sub    $0x4,%edi
  800a31:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a34:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a37:	fd                   	std    
  800a38:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a3a:	eb 07                	jmp    800a43 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a3c:	4f                   	dec    %edi
  800a3d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a40:	fd                   	std    
  800a41:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a43:	fc                   	cld    
  800a44:	eb 20                	jmp    800a66 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a46:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a4c:	75 13                	jne    800a61 <memmove+0x61>
  800a4e:	a8 03                	test   $0x3,%al
  800a50:	75 0f                	jne    800a61 <memmove+0x61>
  800a52:	f6 c1 03             	test   $0x3,%cl
  800a55:	75 0a                	jne    800a61 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a57:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a5a:	89 c7                	mov    %eax,%edi
  800a5c:	fc                   	cld    
  800a5d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a5f:	eb 05                	jmp    800a66 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a61:	89 c7                	mov    %eax,%edi
  800a63:	fc                   	cld    
  800a64:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a66:	5e                   	pop    %esi
  800a67:	5f                   	pop    %edi
  800a68:	5d                   	pop    %ebp
  800a69:	c3                   	ret    

00800a6a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a6a:	55                   	push   %ebp
  800a6b:	89 e5                	mov    %esp,%ebp
  800a6d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a70:	8b 45 10             	mov    0x10(%ebp),%eax
  800a73:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a77:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a7a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a81:	89 04 24             	mov    %eax,(%esp)
  800a84:	e8 77 ff ff ff       	call   800a00 <memmove>
}
  800a89:	c9                   	leave  
  800a8a:	c3                   	ret    

00800a8b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	57                   	push   %edi
  800a8f:	56                   	push   %esi
  800a90:	53                   	push   %ebx
  800a91:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a94:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a97:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a9a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9f:	eb 16                	jmp    800ab7 <memcmp+0x2c>
		if (*s1 != *s2)
  800aa1:	8a 04 17             	mov    (%edi,%edx,1),%al
  800aa4:	42                   	inc    %edx
  800aa5:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800aa9:	38 c8                	cmp    %cl,%al
  800aab:	74 0a                	je     800ab7 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800aad:	0f b6 c0             	movzbl %al,%eax
  800ab0:	0f b6 c9             	movzbl %cl,%ecx
  800ab3:	29 c8                	sub    %ecx,%eax
  800ab5:	eb 09                	jmp    800ac0 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ab7:	39 da                	cmp    %ebx,%edx
  800ab9:	75 e6                	jne    800aa1 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800abb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ac0:	5b                   	pop    %ebx
  800ac1:	5e                   	pop    %esi
  800ac2:	5f                   	pop    %edi
  800ac3:	5d                   	pop    %ebp
  800ac4:	c3                   	ret    

00800ac5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ac5:	55                   	push   %ebp
  800ac6:	89 e5                	mov    %esp,%ebp
  800ac8:	8b 45 08             	mov    0x8(%ebp),%eax
  800acb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ace:	89 c2                	mov    %eax,%edx
  800ad0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ad3:	eb 05                	jmp    800ada <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ad5:	38 08                	cmp    %cl,(%eax)
  800ad7:	74 05                	je     800ade <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ad9:	40                   	inc    %eax
  800ada:	39 d0                	cmp    %edx,%eax
  800adc:	72 f7                	jb     800ad5 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ade:	5d                   	pop    %ebp
  800adf:	c3                   	ret    

00800ae0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ae0:	55                   	push   %ebp
  800ae1:	89 e5                	mov    %esp,%ebp
  800ae3:	57                   	push   %edi
  800ae4:	56                   	push   %esi
  800ae5:	53                   	push   %ebx
  800ae6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aec:	eb 01                	jmp    800aef <strtol+0xf>
		s++;
  800aee:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aef:	8a 02                	mov    (%edx),%al
  800af1:	3c 20                	cmp    $0x20,%al
  800af3:	74 f9                	je     800aee <strtol+0xe>
  800af5:	3c 09                	cmp    $0x9,%al
  800af7:	74 f5                	je     800aee <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800af9:	3c 2b                	cmp    $0x2b,%al
  800afb:	75 08                	jne    800b05 <strtol+0x25>
		s++;
  800afd:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800afe:	bf 00 00 00 00       	mov    $0x0,%edi
  800b03:	eb 13                	jmp    800b18 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b05:	3c 2d                	cmp    $0x2d,%al
  800b07:	75 0a                	jne    800b13 <strtol+0x33>
		s++, neg = 1;
  800b09:	8d 52 01             	lea    0x1(%edx),%edx
  800b0c:	bf 01 00 00 00       	mov    $0x1,%edi
  800b11:	eb 05                	jmp    800b18 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b13:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b18:	85 db                	test   %ebx,%ebx
  800b1a:	74 05                	je     800b21 <strtol+0x41>
  800b1c:	83 fb 10             	cmp    $0x10,%ebx
  800b1f:	75 28                	jne    800b49 <strtol+0x69>
  800b21:	8a 02                	mov    (%edx),%al
  800b23:	3c 30                	cmp    $0x30,%al
  800b25:	75 10                	jne    800b37 <strtol+0x57>
  800b27:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b2b:	75 0a                	jne    800b37 <strtol+0x57>
		s += 2, base = 16;
  800b2d:	83 c2 02             	add    $0x2,%edx
  800b30:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b35:	eb 12                	jmp    800b49 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b37:	85 db                	test   %ebx,%ebx
  800b39:	75 0e                	jne    800b49 <strtol+0x69>
  800b3b:	3c 30                	cmp    $0x30,%al
  800b3d:	75 05                	jne    800b44 <strtol+0x64>
		s++, base = 8;
  800b3f:	42                   	inc    %edx
  800b40:	b3 08                	mov    $0x8,%bl
  800b42:	eb 05                	jmp    800b49 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b44:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b49:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4e:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b50:	8a 0a                	mov    (%edx),%cl
  800b52:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b55:	80 fb 09             	cmp    $0x9,%bl
  800b58:	77 08                	ja     800b62 <strtol+0x82>
			dig = *s - '0';
  800b5a:	0f be c9             	movsbl %cl,%ecx
  800b5d:	83 e9 30             	sub    $0x30,%ecx
  800b60:	eb 1e                	jmp    800b80 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b62:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b65:	80 fb 19             	cmp    $0x19,%bl
  800b68:	77 08                	ja     800b72 <strtol+0x92>
			dig = *s - 'a' + 10;
  800b6a:	0f be c9             	movsbl %cl,%ecx
  800b6d:	83 e9 57             	sub    $0x57,%ecx
  800b70:	eb 0e                	jmp    800b80 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b72:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b75:	80 fb 19             	cmp    $0x19,%bl
  800b78:	77 12                	ja     800b8c <strtol+0xac>
			dig = *s - 'A' + 10;
  800b7a:	0f be c9             	movsbl %cl,%ecx
  800b7d:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b80:	39 f1                	cmp    %esi,%ecx
  800b82:	7d 0c                	jge    800b90 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b84:	42                   	inc    %edx
  800b85:	0f af c6             	imul   %esi,%eax
  800b88:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b8a:	eb c4                	jmp    800b50 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b8c:	89 c1                	mov    %eax,%ecx
  800b8e:	eb 02                	jmp    800b92 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b90:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b92:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b96:	74 05                	je     800b9d <strtol+0xbd>
		*endptr = (char *) s;
  800b98:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b9b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b9d:	85 ff                	test   %edi,%edi
  800b9f:	74 04                	je     800ba5 <strtol+0xc5>
  800ba1:	89 c8                	mov    %ecx,%eax
  800ba3:	f7 d8                	neg    %eax
}
  800ba5:	5b                   	pop    %ebx
  800ba6:	5e                   	pop    %esi
  800ba7:	5f                   	pop    %edi
  800ba8:	5d                   	pop    %ebp
  800ba9:	c3                   	ret    
	...

00800bac <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bac:	55                   	push   %ebp
  800bad:	89 e5                	mov    %esp,%ebp
  800baf:	57                   	push   %edi
  800bb0:	56                   	push   %esi
  800bb1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb2:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bba:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbd:	89 c3                	mov    %eax,%ebx
  800bbf:	89 c7                	mov    %eax,%edi
  800bc1:	89 c6                	mov    %eax,%esi
  800bc3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bc5:	5b                   	pop    %ebx
  800bc6:	5e                   	pop    %esi
  800bc7:	5f                   	pop    %edi
  800bc8:	5d                   	pop    %ebp
  800bc9:	c3                   	ret    

00800bca <sys_cgetc>:

int
sys_cgetc(void)
{
  800bca:	55                   	push   %ebp
  800bcb:	89 e5                	mov    %esp,%ebp
  800bcd:	57                   	push   %edi
  800bce:	56                   	push   %esi
  800bcf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd5:	b8 01 00 00 00       	mov    $0x1,%eax
  800bda:	89 d1                	mov    %edx,%ecx
  800bdc:	89 d3                	mov    %edx,%ebx
  800bde:	89 d7                	mov    %edx,%edi
  800be0:	89 d6                	mov    %edx,%esi
  800be2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800be4:	5b                   	pop    %ebx
  800be5:	5e                   	pop    %esi
  800be6:	5f                   	pop    %edi
  800be7:	5d                   	pop    %ebp
  800be8:	c3                   	ret    

00800be9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
  800bec:	57                   	push   %edi
  800bed:	56                   	push   %esi
  800bee:	53                   	push   %ebx
  800bef:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bf7:	b8 03 00 00 00       	mov    $0x3,%eax
  800bfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800bff:	89 cb                	mov    %ecx,%ebx
  800c01:	89 cf                	mov    %ecx,%edi
  800c03:	89 ce                	mov    %ecx,%esi
  800c05:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c07:	85 c0                	test   %eax,%eax
  800c09:	7e 28                	jle    800c33 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c0f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c16:	00 
  800c17:	c7 44 24 08 87 1b 80 	movl   $0x801b87,0x8(%esp)
  800c1e:	00 
  800c1f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c26:	00 
  800c27:	c7 04 24 a4 1b 80 00 	movl   $0x801ba4,(%esp)
  800c2e:	e8 41 08 00 00       	call   801474 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c33:	83 c4 2c             	add    $0x2c,%esp
  800c36:	5b                   	pop    %ebx
  800c37:	5e                   	pop    %esi
  800c38:	5f                   	pop    %edi
  800c39:	5d                   	pop    %ebp
  800c3a:	c3                   	ret    

00800c3b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	57                   	push   %edi
  800c3f:	56                   	push   %esi
  800c40:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c41:	ba 00 00 00 00       	mov    $0x0,%edx
  800c46:	b8 02 00 00 00       	mov    $0x2,%eax
  800c4b:	89 d1                	mov    %edx,%ecx
  800c4d:	89 d3                	mov    %edx,%ebx
  800c4f:	89 d7                	mov    %edx,%edi
  800c51:	89 d6                	mov    %edx,%esi
  800c53:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c55:	5b                   	pop    %ebx
  800c56:	5e                   	pop    %esi
  800c57:	5f                   	pop    %edi
  800c58:	5d                   	pop    %ebp
  800c59:	c3                   	ret    

00800c5a <sys_yield>:

void
sys_yield(void)
{
  800c5a:	55                   	push   %ebp
  800c5b:	89 e5                	mov    %esp,%ebp
  800c5d:	57                   	push   %edi
  800c5e:	56                   	push   %esi
  800c5f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c60:	ba 00 00 00 00       	mov    $0x0,%edx
  800c65:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c6a:	89 d1                	mov    %edx,%ecx
  800c6c:	89 d3                	mov    %edx,%ebx
  800c6e:	89 d7                	mov    %edx,%edi
  800c70:	89 d6                	mov    %edx,%esi
  800c72:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c74:	5b                   	pop    %ebx
  800c75:	5e                   	pop    %esi
  800c76:	5f                   	pop    %edi
  800c77:	5d                   	pop    %ebp
  800c78:	c3                   	ret    

00800c79 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c79:	55                   	push   %ebp
  800c7a:	89 e5                	mov    %esp,%ebp
  800c7c:	57                   	push   %edi
  800c7d:	56                   	push   %esi
  800c7e:	53                   	push   %ebx
  800c7f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c82:	be 00 00 00 00       	mov    $0x0,%esi
  800c87:	b8 04 00 00 00       	mov    $0x4,%eax
  800c8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c92:	8b 55 08             	mov    0x8(%ebp),%edx
  800c95:	89 f7                	mov    %esi,%edi
  800c97:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c99:	85 c0                	test   %eax,%eax
  800c9b:	7e 28                	jle    800cc5 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ca1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800ca8:	00 
  800ca9:	c7 44 24 08 87 1b 80 	movl   $0x801b87,0x8(%esp)
  800cb0:	00 
  800cb1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cb8:	00 
  800cb9:	c7 04 24 a4 1b 80 00 	movl   $0x801ba4,(%esp)
  800cc0:	e8 af 07 00 00       	call   801474 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cc5:	83 c4 2c             	add    $0x2c,%esp
  800cc8:	5b                   	pop    %ebx
  800cc9:	5e                   	pop    %esi
  800cca:	5f                   	pop    %edi
  800ccb:	5d                   	pop    %ebp
  800ccc:	c3                   	ret    

00800ccd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ccd:	55                   	push   %ebp
  800cce:	89 e5                	mov    %esp,%ebp
  800cd0:	57                   	push   %edi
  800cd1:	56                   	push   %esi
  800cd2:	53                   	push   %ebx
  800cd3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd6:	b8 05 00 00 00       	mov    $0x5,%eax
  800cdb:	8b 75 18             	mov    0x18(%ebp),%esi
  800cde:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ce1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cea:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cec:	85 c0                	test   %eax,%eax
  800cee:	7e 28                	jle    800d18 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cf4:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800cfb:	00 
  800cfc:	c7 44 24 08 87 1b 80 	movl   $0x801b87,0x8(%esp)
  800d03:	00 
  800d04:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d0b:	00 
  800d0c:	c7 04 24 a4 1b 80 00 	movl   $0x801ba4,(%esp)
  800d13:	e8 5c 07 00 00       	call   801474 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d18:	83 c4 2c             	add    $0x2c,%esp
  800d1b:	5b                   	pop    %ebx
  800d1c:	5e                   	pop    %esi
  800d1d:	5f                   	pop    %edi
  800d1e:	5d                   	pop    %ebp
  800d1f:	c3                   	ret    

00800d20 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d20:	55                   	push   %ebp
  800d21:	89 e5                	mov    %esp,%ebp
  800d23:	57                   	push   %edi
  800d24:	56                   	push   %esi
  800d25:	53                   	push   %ebx
  800d26:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d29:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2e:	b8 06 00 00 00       	mov    $0x6,%eax
  800d33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d36:	8b 55 08             	mov    0x8(%ebp),%edx
  800d39:	89 df                	mov    %ebx,%edi
  800d3b:	89 de                	mov    %ebx,%esi
  800d3d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d3f:	85 c0                	test   %eax,%eax
  800d41:	7e 28                	jle    800d6b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d43:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d47:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d4e:	00 
  800d4f:	c7 44 24 08 87 1b 80 	movl   $0x801b87,0x8(%esp)
  800d56:	00 
  800d57:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d5e:	00 
  800d5f:	c7 04 24 a4 1b 80 00 	movl   $0x801ba4,(%esp)
  800d66:	e8 09 07 00 00       	call   801474 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d6b:	83 c4 2c             	add    $0x2c,%esp
  800d6e:	5b                   	pop    %ebx
  800d6f:	5e                   	pop    %esi
  800d70:	5f                   	pop    %edi
  800d71:	5d                   	pop    %ebp
  800d72:	c3                   	ret    

00800d73 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d73:	55                   	push   %ebp
  800d74:	89 e5                	mov    %esp,%ebp
  800d76:	57                   	push   %edi
  800d77:	56                   	push   %esi
  800d78:	53                   	push   %ebx
  800d79:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d81:	b8 08 00 00 00       	mov    $0x8,%eax
  800d86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d89:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8c:	89 df                	mov    %ebx,%edi
  800d8e:	89 de                	mov    %ebx,%esi
  800d90:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d92:	85 c0                	test   %eax,%eax
  800d94:	7e 28                	jle    800dbe <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d96:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d9a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800da1:	00 
  800da2:	c7 44 24 08 87 1b 80 	movl   $0x801b87,0x8(%esp)
  800da9:	00 
  800daa:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800db1:	00 
  800db2:	c7 04 24 a4 1b 80 00 	movl   $0x801ba4,(%esp)
  800db9:	e8 b6 06 00 00       	call   801474 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dbe:	83 c4 2c             	add    $0x2c,%esp
  800dc1:	5b                   	pop    %ebx
  800dc2:	5e                   	pop    %esi
  800dc3:	5f                   	pop    %edi
  800dc4:	5d                   	pop    %ebp
  800dc5:	c3                   	ret    

00800dc6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dc6:	55                   	push   %ebp
  800dc7:	89 e5                	mov    %esp,%ebp
  800dc9:	57                   	push   %edi
  800dca:	56                   	push   %esi
  800dcb:	53                   	push   %ebx
  800dcc:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd4:	b8 09 00 00 00       	mov    $0x9,%eax
  800dd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ddc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddf:	89 df                	mov    %ebx,%edi
  800de1:	89 de                	mov    %ebx,%esi
  800de3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800de5:	85 c0                	test   %eax,%eax
  800de7:	7e 28                	jle    800e11 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ded:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800df4:	00 
  800df5:	c7 44 24 08 87 1b 80 	movl   $0x801b87,0x8(%esp)
  800dfc:	00 
  800dfd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e04:	00 
  800e05:	c7 04 24 a4 1b 80 00 	movl   $0x801ba4,(%esp)
  800e0c:	e8 63 06 00 00       	call   801474 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e11:	83 c4 2c             	add    $0x2c,%esp
  800e14:	5b                   	pop    %ebx
  800e15:	5e                   	pop    %esi
  800e16:	5f                   	pop    %edi
  800e17:	5d                   	pop    %ebp
  800e18:	c3                   	ret    

00800e19 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e19:	55                   	push   %ebp
  800e1a:	89 e5                	mov    %esp,%ebp
  800e1c:	57                   	push   %edi
  800e1d:	56                   	push   %esi
  800e1e:	53                   	push   %ebx
  800e1f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e22:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e27:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e32:	89 df                	mov    %ebx,%edi
  800e34:	89 de                	mov    %ebx,%esi
  800e36:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e38:	85 c0                	test   %eax,%eax
  800e3a:	7e 28                	jle    800e64 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e3c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e40:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e47:	00 
  800e48:	c7 44 24 08 87 1b 80 	movl   $0x801b87,0x8(%esp)
  800e4f:	00 
  800e50:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e57:	00 
  800e58:	c7 04 24 a4 1b 80 00 	movl   $0x801ba4,(%esp)
  800e5f:	e8 10 06 00 00       	call   801474 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e64:	83 c4 2c             	add    $0x2c,%esp
  800e67:	5b                   	pop    %ebx
  800e68:	5e                   	pop    %esi
  800e69:	5f                   	pop    %edi
  800e6a:	5d                   	pop    %ebp
  800e6b:	c3                   	ret    

00800e6c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e6c:	55                   	push   %ebp
  800e6d:	89 e5                	mov    %esp,%ebp
  800e6f:	57                   	push   %edi
  800e70:	56                   	push   %esi
  800e71:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e72:	be 00 00 00 00       	mov    $0x0,%esi
  800e77:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e7c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e7f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e85:	8b 55 08             	mov    0x8(%ebp),%edx
  800e88:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e8a:	5b                   	pop    %ebx
  800e8b:	5e                   	pop    %esi
  800e8c:	5f                   	pop    %edi
  800e8d:	5d                   	pop    %ebp
  800e8e:	c3                   	ret    

00800e8f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e8f:	55                   	push   %ebp
  800e90:	89 e5                	mov    %esp,%ebp
  800e92:	57                   	push   %edi
  800e93:	56                   	push   %esi
  800e94:	53                   	push   %ebx
  800e95:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e98:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e9d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ea2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea5:	89 cb                	mov    %ecx,%ebx
  800ea7:	89 cf                	mov    %ecx,%edi
  800ea9:	89 ce                	mov    %ecx,%esi
  800eab:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ead:	85 c0                	test   %eax,%eax
  800eaf:	7e 28                	jle    800ed9 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eb5:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800ebc:	00 
  800ebd:	c7 44 24 08 87 1b 80 	movl   $0x801b87,0x8(%esp)
  800ec4:	00 
  800ec5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ecc:	00 
  800ecd:	c7 04 24 a4 1b 80 00 	movl   $0x801ba4,(%esp)
  800ed4:	e8 9b 05 00 00       	call   801474 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ed9:	83 c4 2c             	add    $0x2c,%esp
  800edc:	5b                   	pop    %ebx
  800edd:	5e                   	pop    %esi
  800ede:	5f                   	pop    %edi
  800edf:	5d                   	pop    %ebp
  800ee0:	c3                   	ret    

00800ee1 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800ee1:	55                   	push   %ebp
  800ee2:	89 e5                	mov    %esp,%ebp
  800ee4:	57                   	push   %edi
  800ee5:	56                   	push   %esi
  800ee6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ee7:	ba 00 00 00 00       	mov    $0x0,%edx
  800eec:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ef1:	89 d1                	mov    %edx,%ecx
  800ef3:	89 d3                	mov    %edx,%ebx
  800ef5:	89 d7                	mov    %edx,%edi
  800ef7:	89 d6                	mov    %edx,%esi
  800ef9:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800efb:	5b                   	pop    %ebx
  800efc:	5e                   	pop    %esi
  800efd:	5f                   	pop    %edi
  800efe:	5d                   	pop    %ebp
  800eff:	c3                   	ret    

00800f00 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char* pck, size_t length){
  800f00:	55                   	push   %ebp
  800f01:	89 e5                	mov    %esp,%ebp
  800f03:	57                   	push   %edi
  800f04:	56                   	push   %esi
  800f05:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f06:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f0b:	b8 10 00 00 00       	mov    $0x10,%eax
  800f10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f13:	8b 55 08             	mov    0x8(%ebp),%edx
  800f16:	89 df                	mov    %ebx,%edi
  800f18:	89 de                	mov    %ebx,%esi
  800f1a:	cd 30                	int    $0x30
}

int 
sys_e1000_transmit(char* pck, size_t length){
	return syscall(SYS_e1000_transmit, 0, (uint32_t)pck, length, 0, 0, 0);
}
  800f1c:	5b                   	pop    %ebx
  800f1d:	5e                   	pop    %esi
  800f1e:	5f                   	pop    %edi
  800f1f:	5d                   	pop    %ebp
  800f20:	c3                   	ret    

00800f21 <sys_e1000_receive>:

int 
sys_e1000_receive(char* pck, size_t* length){
  800f21:	55                   	push   %ebp
  800f22:	89 e5                	mov    %esp,%ebp
  800f24:	57                   	push   %edi
  800f25:	56                   	push   %esi
  800f26:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f27:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f2c:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f34:	8b 55 08             	mov    0x8(%ebp),%edx
  800f37:	89 df                	mov    %ebx,%edi
  800f39:	89 de                	mov    %ebx,%esi
  800f3b:	cd 30                	int    $0x30
}

int 
sys_e1000_receive(char* pck, size_t* length){
	return syscall(SYS_e1000_receive, 0, (uint32_t)pck, (uint32_t)length, 0, 0, 0);
}
  800f3d:	5b                   	pop    %ebx
  800f3e:	5e                   	pop    %esi
  800f3f:	5f                   	pop    %edi
  800f40:	5d                   	pop    %ebp
  800f41:	c3                   	ret    

00800f42 <sys_e1000_get_mac>:

int 
sys_e1000_get_mac(uint8_t* mac_addr){
  800f42:	55                   	push   %ebp
  800f43:	89 e5                	mov    %esp,%ebp
  800f45:	57                   	push   %edi
  800f46:	56                   	push   %esi
  800f47:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f48:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f4d:	b8 11 00 00 00       	mov    $0x11,%eax
  800f52:	8b 55 08             	mov    0x8(%ebp),%edx
  800f55:	89 cb                	mov    %ecx,%ebx
  800f57:	89 cf                	mov    %ecx,%edi
  800f59:	89 ce                	mov    %ecx,%esi
  800f5b:	cd 30                	int    $0x30
}

int 
sys_e1000_get_mac(uint8_t* mac_addr){
	return syscall(SYS_e1000_get_mac, 0, (uint32_t)mac_addr, 0, 0, 0, 0);
}
  800f5d:	5b                   	pop    %ebx
  800f5e:	5e                   	pop    %esi
  800f5f:	5f                   	pop    %edi
  800f60:	5d                   	pop    %ebp
  800f61:	c3                   	ret    
	...

00800f64 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f64:	55                   	push   %ebp
  800f65:	89 e5                	mov    %esp,%ebp
  800f67:	53                   	push   %ebx
  800f68:	83 ec 24             	sub    $0x24,%esp
  800f6b:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f6e:	8b 18                	mov    (%eax),%ebx
	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	if ((err & FEC_WR) == 0)
  800f70:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f74:	75 20                	jne    800f96 <pgfault+0x32>
		panic("pgfault: faulting address [%08x] not a write\n", addr);
  800f76:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f7a:	c7 44 24 08 b4 1b 80 	movl   $0x801bb4,0x8(%esp)
  800f81:	00 
  800f82:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  800f89:	00 
  800f8a:	c7 04 24 34 1c 80 00 	movl   $0x801c34,(%esp)
  800f91:	e8 de 04 00 00       	call   801474 <_panic>

	void *page_aligned_addr = (void *) ROUNDDOWN(addr, PGSIZE);
  800f96:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t page_num = (uint32_t) page_aligned_addr / PGSIZE;
  800f9c:	89 d8                	mov    %ebx,%eax
  800f9e:	c1 e8 0c             	shr    $0xc,%eax
	if (!(uvpt[page_num] & PTE_COW))
  800fa1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fa8:	f6 c4 08             	test   $0x8,%ah
  800fab:	75 1c                	jne    800fc9 <pgfault+0x65>
		panic("pgfault: fault was not on a copy-on-write page\n");
  800fad:	c7 44 24 08 e4 1b 80 	movl   $0x801be4,0x8(%esp)
  800fb4:	00 
  800fb5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fbc:	00 
  800fbd:	c7 04 24 34 1c 80 00 	movl   $0x801c34,(%esp)
  800fc4:	e8 ab 04 00 00       	call   801474 <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.

	// Allocate
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800fc9:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800fd0:	00 
  800fd1:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800fd8:	00 
  800fd9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fe0:	e8 94 fc ff ff       	call   800c79 <sys_page_alloc>
  800fe5:	85 c0                	test   %eax,%eax
  800fe7:	79 20                	jns    801009 <pgfault+0xa5>
		panic("sys_page_alloc: %e\n", r);
  800fe9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fed:	c7 44 24 08 3f 1c 80 	movl   $0x801c3f,0x8(%esp)
  800ff4:	00 
  800ff5:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  800ffc:	00 
  800ffd:	c7 04 24 34 1c 80 00 	movl   $0x801c34,(%esp)
  801004:	e8 6b 04 00 00       	call   801474 <_panic>

	// Copy over
	void *src_addr = (void *) ROUNDDOWN(addr, PGSIZE);
	memmove(PFTEMP, src_addr, PGSIZE);
  801009:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801010:	00 
  801011:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801015:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  80101c:	e8 df f9 ff ff       	call   800a00 <memmove>

	// Remap
	if ((r = sys_page_map(0, PFTEMP, 0, src_addr, PTE_P | PTE_U | PTE_W)) < 0)
  801021:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801028:	00 
  801029:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80102d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801034:	00 
  801035:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80103c:	00 
  80103d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801044:	e8 84 fc ff ff       	call   800ccd <sys_page_map>
  801049:	85 c0                	test   %eax,%eax
  80104b:	79 20                	jns    80106d <pgfault+0x109>
		panic("sys_page_map: %e\n", r);
  80104d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801051:	c7 44 24 08 53 1c 80 	movl   $0x801c53,0x8(%esp)
  801058:	00 
  801059:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  801060:	00 
  801061:	c7 04 24 34 1c 80 00 	movl   $0x801c34,(%esp)
  801068:	e8 07 04 00 00       	call   801474 <_panic>

}
  80106d:	83 c4 24             	add    $0x24,%esp
  801070:	5b                   	pop    %ebx
  801071:	5d                   	pop    %ebp
  801072:	c3                   	ret    

00801073 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801073:	55                   	push   %ebp
  801074:	89 e5                	mov    %esp,%ebp
  801076:	57                   	push   %edi
  801077:	56                   	push   %esi
  801078:	53                   	push   %ebx
  801079:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	int r;
	envid_t child_envid;

	set_pgfault_handler(pgfault);
  80107c:	c7 04 24 64 0f 80 00 	movl   $0x800f64,(%esp)
  801083:	e8 44 04 00 00       	call   8014cc <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801088:	ba 07 00 00 00       	mov    $0x7,%edx
  80108d:	89 d0                	mov    %edx,%eax
  80108f:	cd 30                	int    $0x30
  801091:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801094:	89 45 e0             	mov    %eax,-0x20(%ebp)

	child_envid = sys_exofork();
	if (child_envid < 0)
  801097:	85 c0                	test   %eax,%eax
  801099:	79 20                	jns    8010bb <fork+0x48>
		panic("sys_exofork: %e\n", child_envid);
  80109b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80109f:	c7 44 24 08 65 1c 80 	movl   $0x801c65,0x8(%esp)
  8010a6:	00 
  8010a7:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  8010ae:	00 
  8010af:	c7 04 24 34 1c 80 00 	movl   $0x801c34,(%esp)
  8010b6:	e8 b9 03 00 00       	call   801474 <_panic>
	if (child_envid == 0) { // child
  8010bb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8010bf:	75 1c                	jne    8010dd <fork+0x6a>
		// Fix thisenv like dumbfork does and return 0
		thisenv = &envs[ENVX(sys_getenvid())];
  8010c1:	e8 75 fb ff ff       	call   800c3b <sys_getenvid>
  8010c6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010cb:	c1 e0 07             	shl    $0x7,%eax
  8010ce:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010d3:	a3 0c 20 80 00       	mov    %eax,0x80200c
		return 0;
  8010d8:	e9 58 02 00 00       	jmp    801335 <fork+0x2c2>
	set_pgfault_handler(pgfault);

	child_envid = sys_exofork();
	if (child_envid < 0)
		panic("sys_exofork: %e\n", child_envid);
	if (child_envid == 0) { // child
  8010dd:	bf 00 00 00 00       	mov    $0x0,%edi
  8010e2:	be 00 00 00 00       	mov    $0x0,%esi
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
  8010e7:	89 f0                	mov    %esi,%eax
  8010e9:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  8010ec:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010f3:	a8 01                	test   $0x1,%al
  8010f5:	0f 84 7a 01 00 00    	je     801275 <fork+0x202>
			((uvpt[page_num] & PTE_P) == PTE_P)) {
  8010fb:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  801102:	a8 01                	test   $0x1,%al
  801104:	0f 84 6b 01 00 00    	je     801275 <fork+0x202>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	envid_t this_envid = thisenv->env_id;
  80110a:	a1 0c 20 80 00       	mov    0x80200c,%eax
  80110f:	8b 40 48             	mov    0x48(%eax),%eax
  801112:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	if (uvpt[pn] & PTE_SHARE) {
  801115:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80111c:	f6 c4 04             	test   $0x4,%ah
  80111f:	74 52                	je     801173 <fork+0x100>
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  801121:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801128:	25 07 0e 00 00       	and    $0xe07,%eax
  80112d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801131:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801135:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801138:	89 44 24 08          	mov    %eax,0x8(%esp)
  80113c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801140:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801143:	89 04 24             	mov    %eax,(%esp)
  801146:	e8 82 fb ff ff       	call   800ccd <sys_page_map>
  80114b:	85 c0                	test   %eax,%eax
  80114d:	0f 89 22 01 00 00    	jns    801275 <fork+0x202>
			panic("sys_page_map: %e\n", r);
  801153:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801157:	c7 44 24 08 53 1c 80 	movl   $0x801c53,0x8(%esp)
  80115e:	00 
  80115f:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  801166:	00 
  801167:	c7 04 24 34 1c 80 00 	movl   $0x801c34,(%esp)
  80116e:	e8 01 03 00 00       	call   801474 <_panic>
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
  801173:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80117a:	f6 c4 08             	test   $0x8,%ah
  80117d:	75 0f                	jne    80118e <fork+0x11b>
  80117f:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801186:	a8 02                	test   $0x2,%al
  801188:	0f 84 99 00 00 00    	je     801227 <fork+0x1b4>
		if (uvpt[pn] & PTE_U)
  80118e:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801195:	83 e0 04             	and    $0x4,%eax
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
  801198:	83 f8 01             	cmp    $0x1,%eax
  80119b:	19 db                	sbb    %ebx,%ebx
  80119d:	83 e3 fc             	and    $0xfffffffc,%ebx
  8011a0:	81 c3 05 08 00 00    	add    $0x805,%ebx
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
		if (uvpt[pn] & PTE_U)
			perm |= PTE_U;

		// Map page COW, U and P in child
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), perm)) < 0)
  8011a6:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8011aa:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011ae:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8011b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011b5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011bc:	89 04 24             	mov    %eax,(%esp)
  8011bf:	e8 09 fb ff ff       	call   800ccd <sys_page_map>
  8011c4:	85 c0                	test   %eax,%eax
  8011c6:	79 20                	jns    8011e8 <fork+0x175>
			panic("sys_page_map: %e\n", r);
  8011c8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011cc:	c7 44 24 08 53 1c 80 	movl   $0x801c53,0x8(%esp)
  8011d3:	00 
  8011d4:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  8011db:	00 
  8011dc:	c7 04 24 34 1c 80 00 	movl   $0x801c34,(%esp)
  8011e3:	e8 8c 02 00 00       	call   801474 <_panic>

		// Map page COW, U and P in parent
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), this_envid, (void *) (pn*PGSIZE), perm)) < 0)
  8011e8:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8011ec:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011f7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011fb:	89 04 24             	mov    %eax,(%esp)
  8011fe:	e8 ca fa ff ff       	call   800ccd <sys_page_map>
  801203:	85 c0                	test   %eax,%eax
  801205:	79 6e                	jns    801275 <fork+0x202>
			panic("sys_page_map: %e\n", r);
  801207:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80120b:	c7 44 24 08 53 1c 80 	movl   $0x801c53,0x8(%esp)
  801212:	00 
  801213:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  80121a:	00 
  80121b:	c7 04 24 34 1c 80 00 	movl   $0x801c34,(%esp)
  801222:	e8 4d 02 00 00       	call   801474 <_panic>

	} else { // map pages that are present but not writable or COW with their original permissions
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  801227:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80122e:	25 07 0e 00 00       	and    $0xe07,%eax
  801233:	89 44 24 10          	mov    %eax,0x10(%esp)
  801237:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80123b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80123e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801242:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801246:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801249:	89 04 24             	mov    %eax,(%esp)
  80124c:	e8 7c fa ff ff       	call   800ccd <sys_page_map>
  801251:	85 c0                	test   %eax,%eax
  801253:	79 20                	jns    801275 <fork+0x202>
			panic("sys_page_map: %e\n", r);
  801255:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801259:	c7 44 24 08 53 1c 80 	movl   $0x801c53,0x8(%esp)
  801260:	00 
  801261:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  801268:	00 
  801269:	c7 04 24 34 1c 80 00 	movl   $0x801c34,(%esp)
  801270:	e8 ff 01 00 00       	call   801474 <_panic>
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
  801275:	46                   	inc    %esi
  801276:	81 c7 00 10 00 00    	add    $0x1000,%edi
  80127c:	81 fe ff eb 0e 00    	cmp    $0xeebff,%esi
  801282:	0f 85 5f fe ff ff    	jne    8010e7 <fork+0x74>
	}

	// Allocate exception stack space for child. The child can't do this themselves
	// because the mechanism by which it would is to run the pgfault handler, which
	// needs to run on the exception stack (catch 22).
	if ((r = sys_page_alloc(child_envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801288:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80128f:	00 
  801290:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801297:	ee 
  801298:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80129b:	89 04 24             	mov    %eax,(%esp)
  80129e:	e8 d6 f9 ff ff       	call   800c79 <sys_page_alloc>
  8012a3:	85 c0                	test   %eax,%eax
  8012a5:	79 20                	jns    8012c7 <fork+0x254>
		panic("sys_page_alloc: %e\n", r);
  8012a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012ab:	c7 44 24 08 3f 1c 80 	movl   $0x801c3f,0x8(%esp)
  8012b2:	00 
  8012b3:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  8012ba:	00 
  8012bb:	c7 04 24 34 1c 80 00 	movl   $0x801c34,(%esp)
  8012c2:	e8 ad 01 00 00       	call   801474 <_panic>

	// Set page fault handler for the child
	if ((r = sys_env_set_pgfault_upcall(child_envid, _pgfault_upcall)) < 0)
  8012c7:	c7 44 24 04 40 15 80 	movl   $0x801540,0x4(%esp)
  8012ce:	00 
  8012cf:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012d2:	89 04 24             	mov    %eax,(%esp)
  8012d5:	e8 3f fb ff ff       	call   800e19 <sys_env_set_pgfault_upcall>
  8012da:	85 c0                	test   %eax,%eax
  8012dc:	79 20                	jns    8012fe <fork+0x28b>
		panic("sys_env_set_pgfault_upcall: %e\n", r);
  8012de:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012e2:	c7 44 24 08 14 1c 80 	movl   $0x801c14,0x8(%esp)
  8012e9:	00 
  8012ea:	c7 44 24 04 a1 00 00 	movl   $0xa1,0x4(%esp)
  8012f1:	00 
  8012f2:	c7 04 24 34 1c 80 00 	movl   $0x801c34,(%esp)
  8012f9:	e8 76 01 00 00       	call   801474 <_panic>

	// Mark child environment as runnable
	if ((r = sys_env_set_status(child_envid, ENV_RUNNABLE)) < 0)
  8012fe:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801305:	00 
  801306:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801309:	89 04 24             	mov    %eax,(%esp)
  80130c:	e8 62 fa ff ff       	call   800d73 <sys_env_set_status>
  801311:	85 c0                	test   %eax,%eax
  801313:	79 20                	jns    801335 <fork+0x2c2>
		panic("sys_env_set_status: %e\n", r);
  801315:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801319:	c7 44 24 08 76 1c 80 	movl   $0x801c76,0x8(%esp)
  801320:	00 
  801321:	c7 44 24 04 a5 00 00 	movl   $0xa5,0x4(%esp)
  801328:	00 
  801329:	c7 04 24 34 1c 80 00 	movl   $0x801c34,(%esp)
  801330:	e8 3f 01 00 00       	call   801474 <_panic>

	return child_envid;
}
  801335:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801338:	83 c4 3c             	add    $0x3c,%esp
  80133b:	5b                   	pop    %ebx
  80133c:	5e                   	pop    %esi
  80133d:	5f                   	pop    %edi
  80133e:	5d                   	pop    %ebp
  80133f:	c3                   	ret    

00801340 <sfork>:

// Challenge!
int
sfork(void)
{
  801340:	55                   	push   %ebp
  801341:	89 e5                	mov    %esp,%ebp
  801343:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801346:	c7 44 24 08 8e 1c 80 	movl   $0x801c8e,0x8(%esp)
  80134d:	00 
  80134e:	c7 44 24 04 ae 00 00 	movl   $0xae,0x4(%esp)
  801355:	00 
  801356:	c7 04 24 34 1c 80 00 	movl   $0x801c34,(%esp)
  80135d:	e8 12 01 00 00       	call   801474 <_panic>
	...

00801364 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801364:	55                   	push   %ebp
  801365:	89 e5                	mov    %esp,%ebp
  801367:	56                   	push   %esi
  801368:	53                   	push   %ebx
  801369:	83 ec 10             	sub    $0x10,%esp
  80136c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80136f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801372:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int r;
		
	r = sys_ipc_recv(pg?pg:(void*)UTOP);
  801375:	85 c0                	test   %eax,%eax
  801377:	75 05                	jne    80137e <ipc_recv+0x1a>
  801379:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80137e:	89 04 24             	mov    %eax,(%esp)
  801381:	e8 09 fb ff ff       	call   800e8f <sys_ipc_recv>
	if (from_env_store != NULL)
  801386:	85 db                	test   %ebx,%ebx
  801388:	74 0b                	je     801395 <ipc_recv+0x31>
		*from_env_store = thisenv->env_ipc_from; 
  80138a:	8b 15 0c 20 80 00    	mov    0x80200c,%edx
  801390:	8b 52 74             	mov    0x74(%edx),%edx
  801393:	89 13                	mov    %edx,(%ebx)
	if (perm_store != NULL)
  801395:	85 f6                	test   %esi,%esi
  801397:	74 0b                	je     8013a4 <ipc_recv+0x40>
		*perm_store = thisenv->env_ipc_perm;
  801399:	8b 15 0c 20 80 00    	mov    0x80200c,%edx
  80139f:	8b 52 78             	mov    0x78(%edx),%edx
  8013a2:	89 16                	mov    %edx,(%esi)
	
	if (r < 0){
  8013a4:	85 c0                	test   %eax,%eax
  8013a6:	79 16                	jns    8013be <ipc_recv+0x5a>
		if(from_env_store != NULL)
  8013a8:	85 db                	test   %ebx,%ebx
  8013aa:	74 06                	je     8013b2 <ipc_recv+0x4e>
			*from_env_store = 0;
  8013ac:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store != NULL)	
  8013b2:	85 f6                	test   %esi,%esi
  8013b4:	74 10                	je     8013c6 <ipc_recv+0x62>
			*perm_store = 0;
  8013b6:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8013bc:	eb 08                	jmp    8013c6 <ipc_recv+0x62>
		return r;
	}
	
	return thisenv->env_ipc_value;
  8013be:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8013c3:	8b 40 70             	mov    0x70(%eax),%eax
}
  8013c6:	83 c4 10             	add    $0x10,%esp
  8013c9:	5b                   	pop    %ebx
  8013ca:	5e                   	pop    %esi
  8013cb:	5d                   	pop    %ebp
  8013cc:	c3                   	ret    

008013cd <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8013cd:	55                   	push   %ebp
  8013ce:	89 e5                	mov    %esp,%ebp
  8013d0:	57                   	push   %edi
  8013d1:	56                   	push   %esi
  8013d2:	53                   	push   %ebx
  8013d3:	83 ec 1c             	sub    $0x1c,%esp
  8013d6:	8b 75 08             	mov    0x8(%ebp),%esi
  8013d9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8013dc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  8013df:	eb 2a                	jmp    80140b <ipc_send+0x3e>
		if (r != -E_IPC_NOT_RECV)
  8013e1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8013e4:	74 20                	je     801406 <ipc_send+0x39>
			panic("ipc_send: sys_ipc_try_send failed %e", r);
  8013e6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013ea:	c7 44 24 08 a4 1c 80 	movl   $0x801ca4,0x8(%esp)
  8013f1:	00 
  8013f2:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  8013f9:	00 
  8013fa:	c7 04 24 c9 1c 80 00 	movl   $0x801cc9,(%esp)
  801401:	e8 6e 00 00 00       	call   801474 <_panic>
		sys_yield();
  801406:	e8 4f f8 ff ff       	call   800c5a <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  80140b:	85 db                	test   %ebx,%ebx
  80140d:	75 07                	jne    801416 <ipc_send+0x49>
  80140f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801414:	eb 02                	jmp    801418 <ipc_send+0x4b>
  801416:	89 d8                	mov    %ebx,%eax
  801418:	8b 55 14             	mov    0x14(%ebp),%edx
  80141b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80141f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801423:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801427:	89 34 24             	mov    %esi,(%esp)
  80142a:	e8 3d fa ff ff       	call   800e6c <sys_ipc_try_send>
  80142f:	85 c0                	test   %eax,%eax
  801431:	78 ae                	js     8013e1 <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: sys_ipc_try_send failed %e", r);
		sys_yield();
	}
}
  801433:	83 c4 1c             	add    $0x1c,%esp
  801436:	5b                   	pop    %ebx
  801437:	5e                   	pop    %esi
  801438:	5f                   	pop    %edi
  801439:	5d                   	pop    %ebp
  80143a:	c3                   	ret    

0080143b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80143b:	55                   	push   %ebp
  80143c:	89 e5                	mov    %esp,%ebp
  80143e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801441:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801446:	89 c2                	mov    %eax,%edx
  801448:	c1 e2 07             	shl    $0x7,%edx
  80144b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801451:	8b 52 50             	mov    0x50(%edx),%edx
  801454:	39 ca                	cmp    %ecx,%edx
  801456:	75 0d                	jne    801465 <ipc_find_env+0x2a>
			return envs[i].env_id;
  801458:	c1 e0 07             	shl    $0x7,%eax
  80145b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801460:	8b 40 40             	mov    0x40(%eax),%eax
  801463:	eb 0c                	jmp    801471 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801465:	40                   	inc    %eax
  801466:	3d 00 04 00 00       	cmp    $0x400,%eax
  80146b:	75 d9                	jne    801446 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80146d:	66 b8 00 00          	mov    $0x0,%ax
}
  801471:	5d                   	pop    %ebp
  801472:	c3                   	ret    
	...

00801474 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801474:	55                   	push   %ebp
  801475:	89 e5                	mov    %esp,%ebp
  801477:	56                   	push   %esi
  801478:	53                   	push   %ebx
  801479:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80147c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80147f:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  801485:	e8 b1 f7 ff ff       	call   800c3b <sys_getenvid>
  80148a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80148d:	89 54 24 10          	mov    %edx,0x10(%esp)
  801491:	8b 55 08             	mov    0x8(%ebp),%edx
  801494:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801498:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80149c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014a0:	c7 04 24 d4 1c 80 00 	movl   $0x801cd4,(%esp)
  8014a7:	e8 30 ee ff ff       	call   8002dc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8014ac:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014b0:	8b 45 10             	mov    0x10(%ebp),%eax
  8014b3:	89 04 24             	mov    %eax,(%esp)
  8014b6:	e8 c0 ed ff ff       	call   80027b <vcprintf>
	cprintf("\n");
  8014bb:	c7 04 24 51 1c 80 00 	movl   $0x801c51,(%esp)
  8014c2:	e8 15 ee ff ff       	call   8002dc <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8014c7:	cc                   	int3   
  8014c8:	eb fd                	jmp    8014c7 <_panic+0x53>
	...

008014cc <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8014cc:	55                   	push   %ebp
  8014cd:	89 e5                	mov    %esp,%ebp
  8014cf:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8014d2:	83 3d 10 20 80 00 00 	cmpl   $0x0,0x802010
  8014d9:	75 58                	jne    801533 <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.	
		//panic("set_pgfault_handler not implemented");
		
		if (sys_page_alloc(thisenv->env_id,(void *) (UXSTACKTOP - PGSIZE),(PTE_W|PTE_U|PTE_P)) != 0){
  8014db:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8014e0:	8b 40 48             	mov    0x48(%eax),%eax
  8014e3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8014ea:	00 
  8014eb:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8014f2:	ee 
  8014f3:	89 04 24             	mov    %eax,(%esp)
  8014f6:	e8 7e f7 ff ff       	call   800c79 <sys_page_alloc>
  8014fb:	85 c0                	test   %eax,%eax
  8014fd:	74 1c                	je     80151b <set_pgfault_handler+0x4f>
			panic("set_pg_fault_handler");
  8014ff:	c7 44 24 08 f8 1c 80 	movl   $0x801cf8,0x8(%esp)
  801506:	00 
  801507:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80150e:	00 
  80150f:	c7 04 24 0d 1d 80 00 	movl   $0x801d0d,(%esp)
  801516:	e8 59 ff ff ff       	call   801474 <_panic>
		}
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  80151b:	a1 0c 20 80 00       	mov    0x80200c,%eax
  801520:	8b 40 48             	mov    0x48(%eax),%eax
  801523:	c7 44 24 04 40 15 80 	movl   $0x801540,0x4(%esp)
  80152a:	00 
  80152b:	89 04 24             	mov    %eax,(%esp)
  80152e:	e8 e6 f8 ff ff       	call   800e19 <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801533:	8b 45 08             	mov    0x8(%ebp),%eax
  801536:	a3 10 20 80 00       	mov    %eax,0x802010
}
  80153b:	c9                   	leave  
  80153c:	c3                   	ret    
  80153d:	00 00                	add    %al,(%eax)
	...

00801540 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801540:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801541:	a1 10 20 80 00       	mov    0x802010,%eax
	call *%eax
  801546:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801548:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// Save trap-time eip in eax
	movl 0x28(%esp), %eax
  80154b:	8b 44 24 28          	mov    0x28(%esp),%eax

	// Save our current stack
	movl %esp, %ebp
  80154f:	89 e5                	mov    %esp,%ebp

	// Switch to trap-time stack
	movl 0x30(%esp), %esp
  801551:	8b 64 24 30          	mov    0x30(%esp),%esp

	// Push trap-time eip to the trap-time stack
	pushl %eax
  801555:	50                   	push   %eax

	// We now have to update the trap-time esp with its new value
	movl %esp, 0x30(%ebp)
  801556:	89 65 30             	mov    %esp,0x30(%ebp)

	// Go back to our exception stack
	movl %ebp, %esp
  801559:	89 ec                	mov    %ebp,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// Pop fault_va and err, both can be ignored
	popl %eax
  80155b:	58                   	pop    %eax
	popl %eax
  80155c:	58                   	pop    %eax

	// Pop all registers back
	popal
  80155d:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// Skip %eip
	addl $0x4, %esp
  80155e:	83 c4 04             	add    $0x4,%esp

	// Pop eflags back
	popfl
  801561:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	
	popl %esp
  801562:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  801563:	c3                   	ret    

00801564 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801564:	55                   	push   %ebp
  801565:	57                   	push   %edi
  801566:	56                   	push   %esi
  801567:	83 ec 10             	sub    $0x10,%esp
  80156a:	8b 74 24 20          	mov    0x20(%esp),%esi
  80156e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801572:	89 74 24 04          	mov    %esi,0x4(%esp)
  801576:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  80157a:	89 cd                	mov    %ecx,%ebp
  80157c:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801580:	85 c0                	test   %eax,%eax
  801582:	75 2c                	jne    8015b0 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801584:	39 f9                	cmp    %edi,%ecx
  801586:	77 68                	ja     8015f0 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801588:	85 c9                	test   %ecx,%ecx
  80158a:	75 0b                	jne    801597 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80158c:	b8 01 00 00 00       	mov    $0x1,%eax
  801591:	31 d2                	xor    %edx,%edx
  801593:	f7 f1                	div    %ecx
  801595:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801597:	31 d2                	xor    %edx,%edx
  801599:	89 f8                	mov    %edi,%eax
  80159b:	f7 f1                	div    %ecx
  80159d:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80159f:	89 f0                	mov    %esi,%eax
  8015a1:	f7 f1                	div    %ecx
  8015a3:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8015a5:	89 f0                	mov    %esi,%eax
  8015a7:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8015a9:	83 c4 10             	add    $0x10,%esp
  8015ac:	5e                   	pop    %esi
  8015ad:	5f                   	pop    %edi
  8015ae:	5d                   	pop    %ebp
  8015af:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8015b0:	39 f8                	cmp    %edi,%eax
  8015b2:	77 2c                	ja     8015e0 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8015b4:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  8015b7:	83 f6 1f             	xor    $0x1f,%esi
  8015ba:	75 4c                	jne    801608 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8015bc:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8015be:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8015c3:	72 0a                	jb     8015cf <__udivdi3+0x6b>
  8015c5:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8015c9:	0f 87 ad 00 00 00    	ja     80167c <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8015cf:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8015d4:	89 f0                	mov    %esi,%eax
  8015d6:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8015d8:	83 c4 10             	add    $0x10,%esp
  8015db:	5e                   	pop    %esi
  8015dc:	5f                   	pop    %edi
  8015dd:	5d                   	pop    %ebp
  8015de:	c3                   	ret    
  8015df:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8015e0:	31 ff                	xor    %edi,%edi
  8015e2:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8015e4:	89 f0                	mov    %esi,%eax
  8015e6:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8015e8:	83 c4 10             	add    $0x10,%esp
  8015eb:	5e                   	pop    %esi
  8015ec:	5f                   	pop    %edi
  8015ed:	5d                   	pop    %ebp
  8015ee:	c3                   	ret    
  8015ef:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8015f0:	89 fa                	mov    %edi,%edx
  8015f2:	89 f0                	mov    %esi,%eax
  8015f4:	f7 f1                	div    %ecx
  8015f6:	89 c6                	mov    %eax,%esi
  8015f8:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8015fa:	89 f0                	mov    %esi,%eax
  8015fc:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8015fe:	83 c4 10             	add    $0x10,%esp
  801601:	5e                   	pop    %esi
  801602:	5f                   	pop    %edi
  801603:	5d                   	pop    %ebp
  801604:	c3                   	ret    
  801605:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801608:	89 f1                	mov    %esi,%ecx
  80160a:	d3 e0                	shl    %cl,%eax
  80160c:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801610:	b8 20 00 00 00       	mov    $0x20,%eax
  801615:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801617:	89 ea                	mov    %ebp,%edx
  801619:	88 c1                	mov    %al,%cl
  80161b:	d3 ea                	shr    %cl,%edx
  80161d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801621:	09 ca                	or     %ecx,%edx
  801623:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  801627:	89 f1                	mov    %esi,%ecx
  801629:	d3 e5                	shl    %cl,%ebp
  80162b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  80162f:	89 fd                	mov    %edi,%ebp
  801631:	88 c1                	mov    %al,%cl
  801633:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  801635:	89 fa                	mov    %edi,%edx
  801637:	89 f1                	mov    %esi,%ecx
  801639:	d3 e2                	shl    %cl,%edx
  80163b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80163f:	88 c1                	mov    %al,%cl
  801641:	d3 ef                	shr    %cl,%edi
  801643:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801645:	89 f8                	mov    %edi,%eax
  801647:	89 ea                	mov    %ebp,%edx
  801649:	f7 74 24 08          	divl   0x8(%esp)
  80164d:	89 d1                	mov    %edx,%ecx
  80164f:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  801651:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801655:	39 d1                	cmp    %edx,%ecx
  801657:	72 17                	jb     801670 <__udivdi3+0x10c>
  801659:	74 09                	je     801664 <__udivdi3+0x100>
  80165b:	89 fe                	mov    %edi,%esi
  80165d:	31 ff                	xor    %edi,%edi
  80165f:	e9 41 ff ff ff       	jmp    8015a5 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801664:	8b 54 24 04          	mov    0x4(%esp),%edx
  801668:	89 f1                	mov    %esi,%ecx
  80166a:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80166c:	39 c2                	cmp    %eax,%edx
  80166e:	73 eb                	jae    80165b <__udivdi3+0xf7>
		{
		  q0--;
  801670:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801673:	31 ff                	xor    %edi,%edi
  801675:	e9 2b ff ff ff       	jmp    8015a5 <__udivdi3+0x41>
  80167a:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80167c:	31 f6                	xor    %esi,%esi
  80167e:	e9 22 ff ff ff       	jmp    8015a5 <__udivdi3+0x41>
	...

00801684 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801684:	55                   	push   %ebp
  801685:	57                   	push   %edi
  801686:	56                   	push   %esi
  801687:	83 ec 20             	sub    $0x20,%esp
  80168a:	8b 44 24 30          	mov    0x30(%esp),%eax
  80168e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801692:	89 44 24 14          	mov    %eax,0x14(%esp)
  801696:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  80169a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80169e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8016a2:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  8016a4:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8016a6:	85 ed                	test   %ebp,%ebp
  8016a8:	75 16                	jne    8016c0 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  8016aa:	39 f1                	cmp    %esi,%ecx
  8016ac:	0f 86 a6 00 00 00    	jbe    801758 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8016b2:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8016b4:	89 d0                	mov    %edx,%eax
  8016b6:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8016b8:	83 c4 20             	add    $0x20,%esp
  8016bb:	5e                   	pop    %esi
  8016bc:	5f                   	pop    %edi
  8016bd:	5d                   	pop    %ebp
  8016be:	c3                   	ret    
  8016bf:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8016c0:	39 f5                	cmp    %esi,%ebp
  8016c2:	0f 87 ac 00 00 00    	ja     801774 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8016c8:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  8016cb:	83 f0 1f             	xor    $0x1f,%eax
  8016ce:	89 44 24 10          	mov    %eax,0x10(%esp)
  8016d2:	0f 84 a8 00 00 00    	je     801780 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8016d8:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8016dc:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8016de:	bf 20 00 00 00       	mov    $0x20,%edi
  8016e3:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8016e7:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8016eb:	89 f9                	mov    %edi,%ecx
  8016ed:	d3 e8                	shr    %cl,%eax
  8016ef:	09 e8                	or     %ebp,%eax
  8016f1:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  8016f5:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8016f9:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8016fd:	d3 e0                	shl    %cl,%eax
  8016ff:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801703:	89 f2                	mov    %esi,%edx
  801705:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801707:	8b 44 24 14          	mov    0x14(%esp),%eax
  80170b:	d3 e0                	shl    %cl,%eax
  80170d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801711:	8b 44 24 14          	mov    0x14(%esp),%eax
  801715:	89 f9                	mov    %edi,%ecx
  801717:	d3 e8                	shr    %cl,%eax
  801719:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80171b:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80171d:	89 f2                	mov    %esi,%edx
  80171f:	f7 74 24 18          	divl   0x18(%esp)
  801723:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801725:	f7 64 24 0c          	mull   0xc(%esp)
  801729:	89 c5                	mov    %eax,%ebp
  80172b:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80172d:	39 d6                	cmp    %edx,%esi
  80172f:	72 67                	jb     801798 <__umoddi3+0x114>
  801731:	74 75                	je     8017a8 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801733:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801737:	29 e8                	sub    %ebp,%eax
  801739:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80173b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80173f:	d3 e8                	shr    %cl,%eax
  801741:	89 f2                	mov    %esi,%edx
  801743:	89 f9                	mov    %edi,%ecx
  801745:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801747:	09 d0                	or     %edx,%eax
  801749:	89 f2                	mov    %esi,%edx
  80174b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80174f:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801751:	83 c4 20             	add    $0x20,%esp
  801754:	5e                   	pop    %esi
  801755:	5f                   	pop    %edi
  801756:	5d                   	pop    %ebp
  801757:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801758:	85 c9                	test   %ecx,%ecx
  80175a:	75 0b                	jne    801767 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80175c:	b8 01 00 00 00       	mov    $0x1,%eax
  801761:	31 d2                	xor    %edx,%edx
  801763:	f7 f1                	div    %ecx
  801765:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801767:	89 f0                	mov    %esi,%eax
  801769:	31 d2                	xor    %edx,%edx
  80176b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80176d:	89 f8                	mov    %edi,%eax
  80176f:	e9 3e ff ff ff       	jmp    8016b2 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801774:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801776:	83 c4 20             	add    $0x20,%esp
  801779:	5e                   	pop    %esi
  80177a:	5f                   	pop    %edi
  80177b:	5d                   	pop    %ebp
  80177c:	c3                   	ret    
  80177d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801780:	39 f5                	cmp    %esi,%ebp
  801782:	72 04                	jb     801788 <__umoddi3+0x104>
  801784:	39 f9                	cmp    %edi,%ecx
  801786:	77 06                	ja     80178e <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801788:	89 f2                	mov    %esi,%edx
  80178a:	29 cf                	sub    %ecx,%edi
  80178c:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  80178e:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801790:	83 c4 20             	add    $0x20,%esp
  801793:	5e                   	pop    %esi
  801794:	5f                   	pop    %edi
  801795:	5d                   	pop    %ebp
  801796:	c3                   	ret    
  801797:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801798:	89 d1                	mov    %edx,%ecx
  80179a:	89 c5                	mov    %eax,%ebp
  80179c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8017a0:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8017a4:	eb 8d                	jmp    801733 <__umoddi3+0xaf>
  8017a6:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8017a8:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8017ac:	72 ea                	jb     801798 <__umoddi3+0x114>
  8017ae:	89 f1                	mov    %esi,%ecx
  8017b0:	eb 81                	jmp    801733 <__umoddi3+0xaf>
