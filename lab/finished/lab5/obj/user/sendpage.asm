
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
  80003a:	e8 c0 0f 00 00       	call   800fff <fork>
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
  800060:	e8 93 12 00 00       	call   8012f8 <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  800065:	c7 44 24 08 00 00 b0 	movl   $0xb00000,0x8(%esp)
  80006c:	00 
  80006d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800070:	89 44 24 04          	mov    %eax,0x4(%esp)
  800074:	c7 04 24 60 17 80 00 	movl   $0x801760,(%esp)
  80007b:	e8 68 02 00 00       	call   8002e8 <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800080:	a1 04 20 80 00       	mov    0x802004,%eax
  800085:	89 04 24             	mov    %eax,(%esp)
  800088:	e8 d3 07 00 00       	call   800860 <strlen>
  80008d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800091:	a1 04 20 80 00       	mov    0x802004,%eax
  800096:	89 44 24 04          	mov    %eax,0x4(%esp)
  80009a:	c7 04 24 00 00 b0 00 	movl   $0xb00000,(%esp)
  8000a1:	e8 b5 08 00 00       	call   80095b <strncmp>
  8000a6:	85 c0                	test   %eax,%eax
  8000a8:	75 0c                	jne    8000b6 <umain+0x82>
			cprintf("child received correct message\n");
  8000aa:	c7 04 24 74 17 80 00 	movl   $0x801774,(%esp)
  8000b1:	e8 32 02 00 00       	call   8002e8 <cprintf>

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  8000b6:	a1 00 20 80 00       	mov    0x802000,%eax
  8000bb:	89 04 24             	mov    %eax,(%esp)
  8000be:	e8 9d 07 00 00       	call   800860 <strlen>
  8000c3:	40                   	inc    %eax
  8000c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000c8:	a1 00 20 80 00       	mov    0x802000,%eax
  8000cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000d1:	c7 04 24 00 00 b0 00 	movl   $0xb00000,(%esp)
  8000d8:	e8 99 09 00 00       	call   800a76 <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000dd:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8000e4:	00 
  8000e5:	c7 44 24 08 00 00 b0 	movl   $0xb00000,0x8(%esp)
  8000ec:	00 
  8000ed:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000f4:	00 
  8000f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000f8:	89 04 24             	mov    %eax,(%esp)
  8000fb:	e8 61 12 00 00       	call   801361 <ipc_send>
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
  800120:	e8 60 0b 00 00       	call   800c85 <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800125:	a1 04 20 80 00       	mov    0x802004,%eax
  80012a:	89 04 24             	mov    %eax,(%esp)
  80012d:	e8 2e 07 00 00       	call   800860 <strlen>
  800132:	40                   	inc    %eax
  800133:	89 44 24 08          	mov    %eax,0x8(%esp)
  800137:	a1 04 20 80 00       	mov    0x802004,%eax
  80013c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800140:	c7 04 24 00 00 a0 00 	movl   $0xa00000,(%esp)
  800147:	e8 2a 09 00 00       	call   800a76 <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  80014c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800153:	00 
  800154:	c7 44 24 08 00 00 a0 	movl   $0xa00000,0x8(%esp)
  80015b:	00 
  80015c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800163:	00 
  800164:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800167:	89 04 24             	mov    %eax,(%esp)
  80016a:	e8 f2 11 00 00       	call   801361 <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  80016f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800176:	00 
  800177:	c7 44 24 04 00 00 a0 	movl   $0xa00000,0x4(%esp)
  80017e:	00 
  80017f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800182:	89 04 24             	mov    %eax,(%esp)
  800185:	e8 6e 11 00 00       	call   8012f8 <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  80018a:	c7 44 24 08 00 00 a0 	movl   $0xa00000,0x8(%esp)
  800191:	00 
  800192:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800195:	89 44 24 04          	mov    %eax,0x4(%esp)
  800199:	c7 04 24 60 17 80 00 	movl   $0x801760,(%esp)
  8001a0:	e8 43 01 00 00       	call   8002e8 <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  8001a5:	a1 00 20 80 00       	mov    0x802000,%eax
  8001aa:	89 04 24             	mov    %eax,(%esp)
  8001ad:	e8 ae 06 00 00       	call   800860 <strlen>
  8001b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001b6:	a1 00 20 80 00       	mov    0x802000,%eax
  8001bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001bf:	c7 04 24 00 00 a0 00 	movl   $0xa00000,(%esp)
  8001c6:	e8 90 07 00 00       	call   80095b <strncmp>
  8001cb:	85 c0                	test   %eax,%eax
  8001cd:	75 0c                	jne    8001db <umain+0x1a7>
		cprintf("parent received correct message\n");
  8001cf:	c7 04 24 94 17 80 00 	movl   $0x801794,(%esp)
  8001d6:	e8 0d 01 00 00       	call   8002e8 <cprintf>
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
  8001ee:	e8 54 0a 00 00       	call   800c47 <sys_getenvid>
  8001f3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001f8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8001ff:	c1 e0 07             	shl    $0x7,%eax
  800202:	29 d0                	sub    %edx,%eax
  800204:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800209:	a3 0c 20 80 00       	mov    %eax,0x80200c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80020e:	85 f6                	test   %esi,%esi
  800210:	7e 07                	jle    800219 <libmain+0x39>
		binaryname = argv[0];
  800212:	8b 03                	mov    (%ebx),%eax
  800214:	a3 08 20 80 00       	mov    %eax,0x802008

	// call user main routine
	umain(argc, argv);
  800219:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80021d:	89 34 24             	mov    %esi,(%esp)
  800220:	e8 0f fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800225:	e8 0a 00 00 00       	call   800234 <exit>
}
  80022a:	83 c4 10             	add    $0x10,%esp
  80022d:	5b                   	pop    %ebx
  80022e:	5e                   	pop    %esi
  80022f:	5d                   	pop    %ebp
  800230:	c3                   	ret    
  800231:	00 00                	add    %al,(%eax)
	...

00800234 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
  800237:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  80023a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800241:	e8 af 09 00 00       	call   800bf5 <sys_env_destroy>
}
  800246:	c9                   	leave  
  800247:	c3                   	ret    

00800248 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	53                   	push   %ebx
  80024c:	83 ec 14             	sub    $0x14,%esp
  80024f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800252:	8b 03                	mov    (%ebx),%eax
  800254:	8b 55 08             	mov    0x8(%ebp),%edx
  800257:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80025b:	40                   	inc    %eax
  80025c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80025e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800263:	75 19                	jne    80027e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800265:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80026c:	00 
  80026d:	8d 43 08             	lea    0x8(%ebx),%eax
  800270:	89 04 24             	mov    %eax,(%esp)
  800273:	e8 40 09 00 00       	call   800bb8 <sys_cputs>
		b->idx = 0;
  800278:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80027e:	ff 43 04             	incl   0x4(%ebx)
}
  800281:	83 c4 14             	add    $0x14,%esp
  800284:	5b                   	pop    %ebx
  800285:	5d                   	pop    %ebp
  800286:	c3                   	ret    

00800287 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800287:	55                   	push   %ebp
  800288:	89 e5                	mov    %esp,%ebp
  80028a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800290:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800297:	00 00 00 
	b.cnt = 0;
  80029a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002a1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ae:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002bc:	c7 04 24 48 02 80 00 	movl   $0x800248,(%esp)
  8002c3:	e8 82 01 00 00       	call   80044a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002c8:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002d8:	89 04 24             	mov    %eax,(%esp)
  8002db:	e8 d8 08 00 00       	call   800bb8 <sys_cputs>

	return b.cnt;
}
  8002e0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002e6:	c9                   	leave  
  8002e7:	c3                   	ret    

008002e8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002e8:	55                   	push   %ebp
  8002e9:	89 e5                	mov    %esp,%ebp
  8002eb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002ee:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f8:	89 04 24             	mov    %eax,(%esp)
  8002fb:	e8 87 ff ff ff       	call   800287 <vcprintf>
	va_end(ap);

	return cnt;
}
  800300:	c9                   	leave  
  800301:	c3                   	ret    
	...

00800304 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800304:	55                   	push   %ebp
  800305:	89 e5                	mov    %esp,%ebp
  800307:	57                   	push   %edi
  800308:	56                   	push   %esi
  800309:	53                   	push   %ebx
  80030a:	83 ec 3c             	sub    $0x3c,%esp
  80030d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800310:	89 d7                	mov    %edx,%edi
  800312:	8b 45 08             	mov    0x8(%ebp),%eax
  800315:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800318:	8b 45 0c             	mov    0xc(%ebp),%eax
  80031b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80031e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800321:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800324:	85 c0                	test   %eax,%eax
  800326:	75 08                	jne    800330 <printnum+0x2c>
  800328:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80032b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80032e:	77 57                	ja     800387 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800330:	89 74 24 10          	mov    %esi,0x10(%esp)
  800334:	4b                   	dec    %ebx
  800335:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800339:	8b 45 10             	mov    0x10(%ebp),%eax
  80033c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800340:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800344:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800348:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80034f:	00 
  800350:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800353:	89 04 24             	mov    %eax,(%esp)
  800356:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800359:	89 44 24 04          	mov    %eax,0x4(%esp)
  80035d:	e8 a2 11 00 00       	call   801504 <__udivdi3>
  800362:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800366:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80036a:	89 04 24             	mov    %eax,(%esp)
  80036d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800371:	89 fa                	mov    %edi,%edx
  800373:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800376:	e8 89 ff ff ff       	call   800304 <printnum>
  80037b:	eb 0f                	jmp    80038c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80037d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800381:	89 34 24             	mov    %esi,(%esp)
  800384:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800387:	4b                   	dec    %ebx
  800388:	85 db                	test   %ebx,%ebx
  80038a:	7f f1                	jg     80037d <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80038c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800390:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800394:	8b 45 10             	mov    0x10(%ebp),%eax
  800397:	89 44 24 08          	mov    %eax,0x8(%esp)
  80039b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003a2:	00 
  8003a3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003a6:	89 04 24             	mov    %eax,(%esp)
  8003a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b0:	e8 6f 12 00 00       	call   801624 <__umoddi3>
  8003b5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003b9:	0f be 80 0c 18 80 00 	movsbl 0x80180c(%eax),%eax
  8003c0:	89 04 24             	mov    %eax,(%esp)
  8003c3:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8003c6:	83 c4 3c             	add    $0x3c,%esp
  8003c9:	5b                   	pop    %ebx
  8003ca:	5e                   	pop    %esi
  8003cb:	5f                   	pop    %edi
  8003cc:	5d                   	pop    %ebp
  8003cd:	c3                   	ret    

008003ce <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003ce:	55                   	push   %ebp
  8003cf:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003d1:	83 fa 01             	cmp    $0x1,%edx
  8003d4:	7e 0e                	jle    8003e4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003d6:	8b 10                	mov    (%eax),%edx
  8003d8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003db:	89 08                	mov    %ecx,(%eax)
  8003dd:	8b 02                	mov    (%edx),%eax
  8003df:	8b 52 04             	mov    0x4(%edx),%edx
  8003e2:	eb 22                	jmp    800406 <getuint+0x38>
	else if (lflag)
  8003e4:	85 d2                	test   %edx,%edx
  8003e6:	74 10                	je     8003f8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003e8:	8b 10                	mov    (%eax),%edx
  8003ea:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ed:	89 08                	mov    %ecx,(%eax)
  8003ef:	8b 02                	mov    (%edx),%eax
  8003f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f6:	eb 0e                	jmp    800406 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003f8:	8b 10                	mov    (%eax),%edx
  8003fa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003fd:	89 08                	mov    %ecx,(%eax)
  8003ff:	8b 02                	mov    (%edx),%eax
  800401:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800406:	5d                   	pop    %ebp
  800407:	c3                   	ret    

00800408 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800408:	55                   	push   %ebp
  800409:	89 e5                	mov    %esp,%ebp
  80040b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80040e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800411:	8b 10                	mov    (%eax),%edx
  800413:	3b 50 04             	cmp    0x4(%eax),%edx
  800416:	73 08                	jae    800420 <sprintputch+0x18>
		*b->buf++ = ch;
  800418:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80041b:	88 0a                	mov    %cl,(%edx)
  80041d:	42                   	inc    %edx
  80041e:	89 10                	mov    %edx,(%eax)
}
  800420:	5d                   	pop    %ebp
  800421:	c3                   	ret    

00800422 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800422:	55                   	push   %ebp
  800423:	89 e5                	mov    %esp,%ebp
  800425:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800428:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80042b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80042f:	8b 45 10             	mov    0x10(%ebp),%eax
  800432:	89 44 24 08          	mov    %eax,0x8(%esp)
  800436:	8b 45 0c             	mov    0xc(%ebp),%eax
  800439:	89 44 24 04          	mov    %eax,0x4(%esp)
  80043d:	8b 45 08             	mov    0x8(%ebp),%eax
  800440:	89 04 24             	mov    %eax,(%esp)
  800443:	e8 02 00 00 00       	call   80044a <vprintfmt>
	va_end(ap);
}
  800448:	c9                   	leave  
  800449:	c3                   	ret    

0080044a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80044a:	55                   	push   %ebp
  80044b:	89 e5                	mov    %esp,%ebp
  80044d:	57                   	push   %edi
  80044e:	56                   	push   %esi
  80044f:	53                   	push   %ebx
  800450:	83 ec 4c             	sub    $0x4c,%esp
  800453:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800456:	8b 75 10             	mov    0x10(%ebp),%esi
  800459:	eb 12                	jmp    80046d <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80045b:	85 c0                	test   %eax,%eax
  80045d:	0f 84 6b 03 00 00    	je     8007ce <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800463:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800467:	89 04 24             	mov    %eax,(%esp)
  80046a:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80046d:	0f b6 06             	movzbl (%esi),%eax
  800470:	46                   	inc    %esi
  800471:	83 f8 25             	cmp    $0x25,%eax
  800474:	75 e5                	jne    80045b <vprintfmt+0x11>
  800476:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80047a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800481:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800486:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80048d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800492:	eb 26                	jmp    8004ba <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800494:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800497:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80049b:	eb 1d                	jmp    8004ba <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004a0:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8004a4:	eb 14                	jmp    8004ba <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8004a9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004b0:	eb 08                	jmp    8004ba <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004b2:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8004b5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ba:	0f b6 06             	movzbl (%esi),%eax
  8004bd:	8d 56 01             	lea    0x1(%esi),%edx
  8004c0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004c3:	8a 16                	mov    (%esi),%dl
  8004c5:	83 ea 23             	sub    $0x23,%edx
  8004c8:	80 fa 55             	cmp    $0x55,%dl
  8004cb:	0f 87 e1 02 00 00    	ja     8007b2 <vprintfmt+0x368>
  8004d1:	0f b6 d2             	movzbl %dl,%edx
  8004d4:	ff 24 95 60 19 80 00 	jmp    *0x801960(,%edx,4)
  8004db:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004de:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004e3:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8004e6:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8004ea:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004ed:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004f0:	83 fa 09             	cmp    $0x9,%edx
  8004f3:	77 2a                	ja     80051f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004f5:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004f6:	eb eb                	jmp    8004e3 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fb:	8d 50 04             	lea    0x4(%eax),%edx
  8004fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800501:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800503:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800506:	eb 17                	jmp    80051f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800508:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80050c:	78 98                	js     8004a6 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800511:	eb a7                	jmp    8004ba <vprintfmt+0x70>
  800513:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800516:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80051d:	eb 9b                	jmp    8004ba <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80051f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800523:	79 95                	jns    8004ba <vprintfmt+0x70>
  800525:	eb 8b                	jmp    8004b2 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800527:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800528:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80052b:	eb 8d                	jmp    8004ba <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80052d:	8b 45 14             	mov    0x14(%ebp),%eax
  800530:	8d 50 04             	lea    0x4(%eax),%edx
  800533:	89 55 14             	mov    %edx,0x14(%ebp)
  800536:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80053a:	8b 00                	mov    (%eax),%eax
  80053c:	89 04 24             	mov    %eax,(%esp)
  80053f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800542:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800545:	e9 23 ff ff ff       	jmp    80046d <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80054a:	8b 45 14             	mov    0x14(%ebp),%eax
  80054d:	8d 50 04             	lea    0x4(%eax),%edx
  800550:	89 55 14             	mov    %edx,0x14(%ebp)
  800553:	8b 00                	mov    (%eax),%eax
  800555:	85 c0                	test   %eax,%eax
  800557:	79 02                	jns    80055b <vprintfmt+0x111>
  800559:	f7 d8                	neg    %eax
  80055b:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80055d:	83 f8 0f             	cmp    $0xf,%eax
  800560:	7f 0b                	jg     80056d <vprintfmt+0x123>
  800562:	8b 04 85 c0 1a 80 00 	mov    0x801ac0(,%eax,4),%eax
  800569:	85 c0                	test   %eax,%eax
  80056b:	75 23                	jne    800590 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80056d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800571:	c7 44 24 08 24 18 80 	movl   $0x801824,0x8(%esp)
  800578:	00 
  800579:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80057d:	8b 45 08             	mov    0x8(%ebp),%eax
  800580:	89 04 24             	mov    %eax,(%esp)
  800583:	e8 9a fe ff ff       	call   800422 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800588:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80058b:	e9 dd fe ff ff       	jmp    80046d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800590:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800594:	c7 44 24 08 2d 18 80 	movl   $0x80182d,0x8(%esp)
  80059b:	00 
  80059c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8005a3:	89 14 24             	mov    %edx,(%esp)
  8005a6:	e8 77 fe ff ff       	call   800422 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ab:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005ae:	e9 ba fe ff ff       	jmp    80046d <vprintfmt+0x23>
  8005b3:	89 f9                	mov    %edi,%ecx
  8005b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005b8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005be:	8d 50 04             	lea    0x4(%eax),%edx
  8005c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c4:	8b 30                	mov    (%eax),%esi
  8005c6:	85 f6                	test   %esi,%esi
  8005c8:	75 05                	jne    8005cf <vprintfmt+0x185>
				p = "(null)";
  8005ca:	be 1d 18 80 00       	mov    $0x80181d,%esi
			if (width > 0 && padc != '-')
  8005cf:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005d3:	0f 8e 84 00 00 00    	jle    80065d <vprintfmt+0x213>
  8005d9:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8005dd:	74 7e                	je     80065d <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005df:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005e3:	89 34 24             	mov    %esi,(%esp)
  8005e6:	e8 8b 02 00 00       	call   800876 <strnlen>
  8005eb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005ee:	29 c2                	sub    %eax,%edx
  8005f0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8005f3:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8005f7:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8005fa:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8005fd:	89 de                	mov    %ebx,%esi
  8005ff:	89 d3                	mov    %edx,%ebx
  800601:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800603:	eb 0b                	jmp    800610 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800605:	89 74 24 04          	mov    %esi,0x4(%esp)
  800609:	89 3c 24             	mov    %edi,(%esp)
  80060c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80060f:	4b                   	dec    %ebx
  800610:	85 db                	test   %ebx,%ebx
  800612:	7f f1                	jg     800605 <vprintfmt+0x1bb>
  800614:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800617:	89 f3                	mov    %esi,%ebx
  800619:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80061c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80061f:	85 c0                	test   %eax,%eax
  800621:	79 05                	jns    800628 <vprintfmt+0x1de>
  800623:	b8 00 00 00 00       	mov    $0x0,%eax
  800628:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80062b:	29 c2                	sub    %eax,%edx
  80062d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800630:	eb 2b                	jmp    80065d <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800632:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800636:	74 18                	je     800650 <vprintfmt+0x206>
  800638:	8d 50 e0             	lea    -0x20(%eax),%edx
  80063b:	83 fa 5e             	cmp    $0x5e,%edx
  80063e:	76 10                	jbe    800650 <vprintfmt+0x206>
					putch('?', putdat);
  800640:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800644:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80064b:	ff 55 08             	call   *0x8(%ebp)
  80064e:	eb 0a                	jmp    80065a <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800650:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800654:	89 04 24             	mov    %eax,(%esp)
  800657:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80065a:	ff 4d e4             	decl   -0x1c(%ebp)
  80065d:	0f be 06             	movsbl (%esi),%eax
  800660:	46                   	inc    %esi
  800661:	85 c0                	test   %eax,%eax
  800663:	74 21                	je     800686 <vprintfmt+0x23c>
  800665:	85 ff                	test   %edi,%edi
  800667:	78 c9                	js     800632 <vprintfmt+0x1e8>
  800669:	4f                   	dec    %edi
  80066a:	79 c6                	jns    800632 <vprintfmt+0x1e8>
  80066c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80066f:	89 de                	mov    %ebx,%esi
  800671:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800674:	eb 18                	jmp    80068e <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800676:	89 74 24 04          	mov    %esi,0x4(%esp)
  80067a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800681:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800683:	4b                   	dec    %ebx
  800684:	eb 08                	jmp    80068e <vprintfmt+0x244>
  800686:	8b 7d 08             	mov    0x8(%ebp),%edi
  800689:	89 de                	mov    %ebx,%esi
  80068b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80068e:	85 db                	test   %ebx,%ebx
  800690:	7f e4                	jg     800676 <vprintfmt+0x22c>
  800692:	89 7d 08             	mov    %edi,0x8(%ebp)
  800695:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800697:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80069a:	e9 ce fd ff ff       	jmp    80046d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80069f:	83 f9 01             	cmp    $0x1,%ecx
  8006a2:	7e 10                	jle    8006b4 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8006a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a7:	8d 50 08             	lea    0x8(%eax),%edx
  8006aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ad:	8b 30                	mov    (%eax),%esi
  8006af:	8b 78 04             	mov    0x4(%eax),%edi
  8006b2:	eb 26                	jmp    8006da <vprintfmt+0x290>
	else if (lflag)
  8006b4:	85 c9                	test   %ecx,%ecx
  8006b6:	74 12                	je     8006ca <vprintfmt+0x280>
		return va_arg(*ap, long);
  8006b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bb:	8d 50 04             	lea    0x4(%eax),%edx
  8006be:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c1:	8b 30                	mov    (%eax),%esi
  8006c3:	89 f7                	mov    %esi,%edi
  8006c5:	c1 ff 1f             	sar    $0x1f,%edi
  8006c8:	eb 10                	jmp    8006da <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8006ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cd:	8d 50 04             	lea    0x4(%eax),%edx
  8006d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d3:	8b 30                	mov    (%eax),%esi
  8006d5:	89 f7                	mov    %esi,%edi
  8006d7:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006da:	85 ff                	test   %edi,%edi
  8006dc:	78 0a                	js     8006e8 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006de:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006e3:	e9 8c 00 00 00       	jmp    800774 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8006e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ec:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006f3:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006f6:	f7 de                	neg    %esi
  8006f8:	83 d7 00             	adc    $0x0,%edi
  8006fb:	f7 df                	neg    %edi
			}
			base = 10;
  8006fd:	b8 0a 00 00 00       	mov    $0xa,%eax
  800702:	eb 70                	jmp    800774 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800704:	89 ca                	mov    %ecx,%edx
  800706:	8d 45 14             	lea    0x14(%ebp),%eax
  800709:	e8 c0 fc ff ff       	call   8003ce <getuint>
  80070e:	89 c6                	mov    %eax,%esi
  800710:	89 d7                	mov    %edx,%edi
			base = 10;
  800712:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800717:	eb 5b                	jmp    800774 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  800719:	89 ca                	mov    %ecx,%edx
  80071b:	8d 45 14             	lea    0x14(%ebp),%eax
  80071e:	e8 ab fc ff ff       	call   8003ce <getuint>
  800723:	89 c6                	mov    %eax,%esi
  800725:	89 d7                	mov    %edx,%edi
			base = 8;
  800727:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80072c:	eb 46                	jmp    800774 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  80072e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800732:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800739:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80073c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800740:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800747:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80074a:	8b 45 14             	mov    0x14(%ebp),%eax
  80074d:	8d 50 04             	lea    0x4(%eax),%edx
  800750:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800753:	8b 30                	mov    (%eax),%esi
  800755:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80075a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80075f:	eb 13                	jmp    800774 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800761:	89 ca                	mov    %ecx,%edx
  800763:	8d 45 14             	lea    0x14(%ebp),%eax
  800766:	e8 63 fc ff ff       	call   8003ce <getuint>
  80076b:	89 c6                	mov    %eax,%esi
  80076d:	89 d7                	mov    %edx,%edi
			base = 16;
  80076f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800774:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800778:	89 54 24 10          	mov    %edx,0x10(%esp)
  80077c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80077f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800783:	89 44 24 08          	mov    %eax,0x8(%esp)
  800787:	89 34 24             	mov    %esi,(%esp)
  80078a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80078e:	89 da                	mov    %ebx,%edx
  800790:	8b 45 08             	mov    0x8(%ebp),%eax
  800793:	e8 6c fb ff ff       	call   800304 <printnum>
			break;
  800798:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80079b:	e9 cd fc ff ff       	jmp    80046d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a4:	89 04 24             	mov    %eax,(%esp)
  8007a7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007aa:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007ad:	e9 bb fc ff ff       	jmp    80046d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007b2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007b6:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007bd:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007c0:	eb 01                	jmp    8007c3 <vprintfmt+0x379>
  8007c2:	4e                   	dec    %esi
  8007c3:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007c7:	75 f9                	jne    8007c2 <vprintfmt+0x378>
  8007c9:	e9 9f fc ff ff       	jmp    80046d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8007ce:	83 c4 4c             	add    $0x4c,%esp
  8007d1:	5b                   	pop    %ebx
  8007d2:	5e                   	pop    %esi
  8007d3:	5f                   	pop    %edi
  8007d4:	5d                   	pop    %ebp
  8007d5:	c3                   	ret    

008007d6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007d6:	55                   	push   %ebp
  8007d7:	89 e5                	mov    %esp,%ebp
  8007d9:	83 ec 28             	sub    $0x28,%esp
  8007dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007df:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007e2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007e5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007e9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007ec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007f3:	85 c0                	test   %eax,%eax
  8007f5:	74 30                	je     800827 <vsnprintf+0x51>
  8007f7:	85 d2                	test   %edx,%edx
  8007f9:	7e 33                	jle    80082e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800802:	8b 45 10             	mov    0x10(%ebp),%eax
  800805:	89 44 24 08          	mov    %eax,0x8(%esp)
  800809:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80080c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800810:	c7 04 24 08 04 80 00 	movl   $0x800408,(%esp)
  800817:	e8 2e fc ff ff       	call   80044a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80081c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80081f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800822:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800825:	eb 0c                	jmp    800833 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800827:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80082c:	eb 05                	jmp    800833 <vsnprintf+0x5d>
  80082e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800833:	c9                   	leave  
  800834:	c3                   	ret    

00800835 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800835:	55                   	push   %ebp
  800836:	89 e5                	mov    %esp,%ebp
  800838:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80083b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80083e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800842:	8b 45 10             	mov    0x10(%ebp),%eax
  800845:	89 44 24 08          	mov    %eax,0x8(%esp)
  800849:	8b 45 0c             	mov    0xc(%ebp),%eax
  80084c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800850:	8b 45 08             	mov    0x8(%ebp),%eax
  800853:	89 04 24             	mov    %eax,(%esp)
  800856:	e8 7b ff ff ff       	call   8007d6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80085b:	c9                   	leave  
  80085c:	c3                   	ret    
  80085d:	00 00                	add    %al,(%eax)
	...

00800860 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800866:	b8 00 00 00 00       	mov    $0x0,%eax
  80086b:	eb 01                	jmp    80086e <strlen+0xe>
		n++;
  80086d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80086e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800872:	75 f9                	jne    80086d <strlen+0xd>
		n++;
	return n;
}
  800874:	5d                   	pop    %ebp
  800875:	c3                   	ret    

00800876 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  80087c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80087f:	b8 00 00 00 00       	mov    $0x0,%eax
  800884:	eb 01                	jmp    800887 <strnlen+0x11>
		n++;
  800886:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800887:	39 d0                	cmp    %edx,%eax
  800889:	74 06                	je     800891 <strnlen+0x1b>
  80088b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80088f:	75 f5                	jne    800886 <strnlen+0x10>
		n++;
	return n;
}
  800891:	5d                   	pop    %ebp
  800892:	c3                   	ret    

00800893 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800893:	55                   	push   %ebp
  800894:	89 e5                	mov    %esp,%ebp
  800896:	53                   	push   %ebx
  800897:	8b 45 08             	mov    0x8(%ebp),%eax
  80089a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80089d:	ba 00 00 00 00       	mov    $0x0,%edx
  8008a2:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8008a5:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008a8:	42                   	inc    %edx
  8008a9:	84 c9                	test   %cl,%cl
  8008ab:	75 f5                	jne    8008a2 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008ad:	5b                   	pop    %ebx
  8008ae:	5d                   	pop    %ebp
  8008af:	c3                   	ret    

008008b0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	53                   	push   %ebx
  8008b4:	83 ec 08             	sub    $0x8,%esp
  8008b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008ba:	89 1c 24             	mov    %ebx,(%esp)
  8008bd:	e8 9e ff ff ff       	call   800860 <strlen>
	strcpy(dst + len, src);
  8008c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008c9:	01 d8                	add    %ebx,%eax
  8008cb:	89 04 24             	mov    %eax,(%esp)
  8008ce:	e8 c0 ff ff ff       	call   800893 <strcpy>
	return dst;
}
  8008d3:	89 d8                	mov    %ebx,%eax
  8008d5:	83 c4 08             	add    $0x8,%esp
  8008d8:	5b                   	pop    %ebx
  8008d9:	5d                   	pop    %ebp
  8008da:	c3                   	ret    

008008db <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	56                   	push   %esi
  8008df:	53                   	push   %ebx
  8008e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008e9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008ee:	eb 0c                	jmp    8008fc <strncpy+0x21>
		*dst++ = *src;
  8008f0:	8a 1a                	mov    (%edx),%bl
  8008f2:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008f5:	80 3a 01             	cmpb   $0x1,(%edx)
  8008f8:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008fb:	41                   	inc    %ecx
  8008fc:	39 f1                	cmp    %esi,%ecx
  8008fe:	75 f0                	jne    8008f0 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800900:	5b                   	pop    %ebx
  800901:	5e                   	pop    %esi
  800902:	5d                   	pop    %ebp
  800903:	c3                   	ret    

00800904 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	56                   	push   %esi
  800908:	53                   	push   %ebx
  800909:	8b 75 08             	mov    0x8(%ebp),%esi
  80090c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80090f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800912:	85 d2                	test   %edx,%edx
  800914:	75 0a                	jne    800920 <strlcpy+0x1c>
  800916:	89 f0                	mov    %esi,%eax
  800918:	eb 1a                	jmp    800934 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80091a:	88 18                	mov    %bl,(%eax)
  80091c:	40                   	inc    %eax
  80091d:	41                   	inc    %ecx
  80091e:	eb 02                	jmp    800922 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800920:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800922:	4a                   	dec    %edx
  800923:	74 0a                	je     80092f <strlcpy+0x2b>
  800925:	8a 19                	mov    (%ecx),%bl
  800927:	84 db                	test   %bl,%bl
  800929:	75 ef                	jne    80091a <strlcpy+0x16>
  80092b:	89 c2                	mov    %eax,%edx
  80092d:	eb 02                	jmp    800931 <strlcpy+0x2d>
  80092f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800931:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800934:	29 f0                	sub    %esi,%eax
}
  800936:	5b                   	pop    %ebx
  800937:	5e                   	pop    %esi
  800938:	5d                   	pop    %ebp
  800939:	c3                   	ret    

0080093a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800940:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800943:	eb 02                	jmp    800947 <strcmp+0xd>
		p++, q++;
  800945:	41                   	inc    %ecx
  800946:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800947:	8a 01                	mov    (%ecx),%al
  800949:	84 c0                	test   %al,%al
  80094b:	74 04                	je     800951 <strcmp+0x17>
  80094d:	3a 02                	cmp    (%edx),%al
  80094f:	74 f4                	je     800945 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800951:	0f b6 c0             	movzbl %al,%eax
  800954:	0f b6 12             	movzbl (%edx),%edx
  800957:	29 d0                	sub    %edx,%eax
}
  800959:	5d                   	pop    %ebp
  80095a:	c3                   	ret    

0080095b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	53                   	push   %ebx
  80095f:	8b 45 08             	mov    0x8(%ebp),%eax
  800962:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800965:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800968:	eb 03                	jmp    80096d <strncmp+0x12>
		n--, p++, q++;
  80096a:	4a                   	dec    %edx
  80096b:	40                   	inc    %eax
  80096c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80096d:	85 d2                	test   %edx,%edx
  80096f:	74 14                	je     800985 <strncmp+0x2a>
  800971:	8a 18                	mov    (%eax),%bl
  800973:	84 db                	test   %bl,%bl
  800975:	74 04                	je     80097b <strncmp+0x20>
  800977:	3a 19                	cmp    (%ecx),%bl
  800979:	74 ef                	je     80096a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80097b:	0f b6 00             	movzbl (%eax),%eax
  80097e:	0f b6 11             	movzbl (%ecx),%edx
  800981:	29 d0                	sub    %edx,%eax
  800983:	eb 05                	jmp    80098a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800985:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80098a:	5b                   	pop    %ebx
  80098b:	5d                   	pop    %ebp
  80098c:	c3                   	ret    

0080098d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80098d:	55                   	push   %ebp
  80098e:	89 e5                	mov    %esp,%ebp
  800990:	8b 45 08             	mov    0x8(%ebp),%eax
  800993:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800996:	eb 05                	jmp    80099d <strchr+0x10>
		if (*s == c)
  800998:	38 ca                	cmp    %cl,%dl
  80099a:	74 0c                	je     8009a8 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80099c:	40                   	inc    %eax
  80099d:	8a 10                	mov    (%eax),%dl
  80099f:	84 d2                	test   %dl,%dl
  8009a1:	75 f5                	jne    800998 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8009a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009a8:	5d                   	pop    %ebp
  8009a9:	c3                   	ret    

008009aa <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009aa:	55                   	push   %ebp
  8009ab:	89 e5                	mov    %esp,%ebp
  8009ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b0:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009b3:	eb 05                	jmp    8009ba <strfind+0x10>
		if (*s == c)
  8009b5:	38 ca                	cmp    %cl,%dl
  8009b7:	74 07                	je     8009c0 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009b9:	40                   	inc    %eax
  8009ba:	8a 10                	mov    (%eax),%dl
  8009bc:	84 d2                	test   %dl,%dl
  8009be:	75 f5                	jne    8009b5 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8009c0:	5d                   	pop    %ebp
  8009c1:	c3                   	ret    

008009c2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009c2:	55                   	push   %ebp
  8009c3:	89 e5                	mov    %esp,%ebp
  8009c5:	57                   	push   %edi
  8009c6:	56                   	push   %esi
  8009c7:	53                   	push   %ebx
  8009c8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ce:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009d1:	85 c9                	test   %ecx,%ecx
  8009d3:	74 30                	je     800a05 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009d5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009db:	75 25                	jne    800a02 <memset+0x40>
  8009dd:	f6 c1 03             	test   $0x3,%cl
  8009e0:	75 20                	jne    800a02 <memset+0x40>
		c &= 0xFF;
  8009e2:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009e5:	89 d3                	mov    %edx,%ebx
  8009e7:	c1 e3 08             	shl    $0x8,%ebx
  8009ea:	89 d6                	mov    %edx,%esi
  8009ec:	c1 e6 18             	shl    $0x18,%esi
  8009ef:	89 d0                	mov    %edx,%eax
  8009f1:	c1 e0 10             	shl    $0x10,%eax
  8009f4:	09 f0                	or     %esi,%eax
  8009f6:	09 d0                	or     %edx,%eax
  8009f8:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009fa:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009fd:	fc                   	cld    
  8009fe:	f3 ab                	rep stos %eax,%es:(%edi)
  800a00:	eb 03                	jmp    800a05 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a02:	fc                   	cld    
  800a03:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a05:	89 f8                	mov    %edi,%eax
  800a07:	5b                   	pop    %ebx
  800a08:	5e                   	pop    %esi
  800a09:	5f                   	pop    %edi
  800a0a:	5d                   	pop    %ebp
  800a0b:	c3                   	ret    

00800a0c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a0c:	55                   	push   %ebp
  800a0d:	89 e5                	mov    %esp,%ebp
  800a0f:	57                   	push   %edi
  800a10:	56                   	push   %esi
  800a11:	8b 45 08             	mov    0x8(%ebp),%eax
  800a14:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a17:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a1a:	39 c6                	cmp    %eax,%esi
  800a1c:	73 34                	jae    800a52 <memmove+0x46>
  800a1e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a21:	39 d0                	cmp    %edx,%eax
  800a23:	73 2d                	jae    800a52 <memmove+0x46>
		s += n;
		d += n;
  800a25:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a28:	f6 c2 03             	test   $0x3,%dl
  800a2b:	75 1b                	jne    800a48 <memmove+0x3c>
  800a2d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a33:	75 13                	jne    800a48 <memmove+0x3c>
  800a35:	f6 c1 03             	test   $0x3,%cl
  800a38:	75 0e                	jne    800a48 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a3a:	83 ef 04             	sub    $0x4,%edi
  800a3d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a40:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a43:	fd                   	std    
  800a44:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a46:	eb 07                	jmp    800a4f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a48:	4f                   	dec    %edi
  800a49:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a4c:	fd                   	std    
  800a4d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a4f:	fc                   	cld    
  800a50:	eb 20                	jmp    800a72 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a52:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a58:	75 13                	jne    800a6d <memmove+0x61>
  800a5a:	a8 03                	test   $0x3,%al
  800a5c:	75 0f                	jne    800a6d <memmove+0x61>
  800a5e:	f6 c1 03             	test   $0x3,%cl
  800a61:	75 0a                	jne    800a6d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a63:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a66:	89 c7                	mov    %eax,%edi
  800a68:	fc                   	cld    
  800a69:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a6b:	eb 05                	jmp    800a72 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a6d:	89 c7                	mov    %eax,%edi
  800a6f:	fc                   	cld    
  800a70:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a72:	5e                   	pop    %esi
  800a73:	5f                   	pop    %edi
  800a74:	5d                   	pop    %ebp
  800a75:	c3                   	ret    

00800a76 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a76:	55                   	push   %ebp
  800a77:	89 e5                	mov    %esp,%ebp
  800a79:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a7c:	8b 45 10             	mov    0x10(%ebp),%eax
  800a7f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a83:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a86:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8d:	89 04 24             	mov    %eax,(%esp)
  800a90:	e8 77 ff ff ff       	call   800a0c <memmove>
}
  800a95:	c9                   	leave  
  800a96:	c3                   	ret    

00800a97 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a97:	55                   	push   %ebp
  800a98:	89 e5                	mov    %esp,%ebp
  800a9a:	57                   	push   %edi
  800a9b:	56                   	push   %esi
  800a9c:	53                   	push   %ebx
  800a9d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aa0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aa6:	ba 00 00 00 00       	mov    $0x0,%edx
  800aab:	eb 16                	jmp    800ac3 <memcmp+0x2c>
		if (*s1 != *s2)
  800aad:	8a 04 17             	mov    (%edi,%edx,1),%al
  800ab0:	42                   	inc    %edx
  800ab1:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800ab5:	38 c8                	cmp    %cl,%al
  800ab7:	74 0a                	je     800ac3 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800ab9:	0f b6 c0             	movzbl %al,%eax
  800abc:	0f b6 c9             	movzbl %cl,%ecx
  800abf:	29 c8                	sub    %ecx,%eax
  800ac1:	eb 09                	jmp    800acc <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ac3:	39 da                	cmp    %ebx,%edx
  800ac5:	75 e6                	jne    800aad <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ac7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800acc:	5b                   	pop    %ebx
  800acd:	5e                   	pop    %esi
  800ace:	5f                   	pop    %edi
  800acf:	5d                   	pop    %ebp
  800ad0:	c3                   	ret    

00800ad1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ad1:	55                   	push   %ebp
  800ad2:	89 e5                	mov    %esp,%ebp
  800ad4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ada:	89 c2                	mov    %eax,%edx
  800adc:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800adf:	eb 05                	jmp    800ae6 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ae1:	38 08                	cmp    %cl,(%eax)
  800ae3:	74 05                	je     800aea <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ae5:	40                   	inc    %eax
  800ae6:	39 d0                	cmp    %edx,%eax
  800ae8:	72 f7                	jb     800ae1 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800aea:	5d                   	pop    %ebp
  800aeb:	c3                   	ret    

00800aec <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aec:	55                   	push   %ebp
  800aed:	89 e5                	mov    %esp,%ebp
  800aef:	57                   	push   %edi
  800af0:	56                   	push   %esi
  800af1:	53                   	push   %ebx
  800af2:	8b 55 08             	mov    0x8(%ebp),%edx
  800af5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800af8:	eb 01                	jmp    800afb <strtol+0xf>
		s++;
  800afa:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800afb:	8a 02                	mov    (%edx),%al
  800afd:	3c 20                	cmp    $0x20,%al
  800aff:	74 f9                	je     800afa <strtol+0xe>
  800b01:	3c 09                	cmp    $0x9,%al
  800b03:	74 f5                	je     800afa <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b05:	3c 2b                	cmp    $0x2b,%al
  800b07:	75 08                	jne    800b11 <strtol+0x25>
		s++;
  800b09:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b0a:	bf 00 00 00 00       	mov    $0x0,%edi
  800b0f:	eb 13                	jmp    800b24 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b11:	3c 2d                	cmp    $0x2d,%al
  800b13:	75 0a                	jne    800b1f <strtol+0x33>
		s++, neg = 1;
  800b15:	8d 52 01             	lea    0x1(%edx),%edx
  800b18:	bf 01 00 00 00       	mov    $0x1,%edi
  800b1d:	eb 05                	jmp    800b24 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b1f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b24:	85 db                	test   %ebx,%ebx
  800b26:	74 05                	je     800b2d <strtol+0x41>
  800b28:	83 fb 10             	cmp    $0x10,%ebx
  800b2b:	75 28                	jne    800b55 <strtol+0x69>
  800b2d:	8a 02                	mov    (%edx),%al
  800b2f:	3c 30                	cmp    $0x30,%al
  800b31:	75 10                	jne    800b43 <strtol+0x57>
  800b33:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b37:	75 0a                	jne    800b43 <strtol+0x57>
		s += 2, base = 16;
  800b39:	83 c2 02             	add    $0x2,%edx
  800b3c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b41:	eb 12                	jmp    800b55 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b43:	85 db                	test   %ebx,%ebx
  800b45:	75 0e                	jne    800b55 <strtol+0x69>
  800b47:	3c 30                	cmp    $0x30,%al
  800b49:	75 05                	jne    800b50 <strtol+0x64>
		s++, base = 8;
  800b4b:	42                   	inc    %edx
  800b4c:	b3 08                	mov    $0x8,%bl
  800b4e:	eb 05                	jmp    800b55 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b50:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b55:	b8 00 00 00 00       	mov    $0x0,%eax
  800b5a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b5c:	8a 0a                	mov    (%edx),%cl
  800b5e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b61:	80 fb 09             	cmp    $0x9,%bl
  800b64:	77 08                	ja     800b6e <strtol+0x82>
			dig = *s - '0';
  800b66:	0f be c9             	movsbl %cl,%ecx
  800b69:	83 e9 30             	sub    $0x30,%ecx
  800b6c:	eb 1e                	jmp    800b8c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b6e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b71:	80 fb 19             	cmp    $0x19,%bl
  800b74:	77 08                	ja     800b7e <strtol+0x92>
			dig = *s - 'a' + 10;
  800b76:	0f be c9             	movsbl %cl,%ecx
  800b79:	83 e9 57             	sub    $0x57,%ecx
  800b7c:	eb 0e                	jmp    800b8c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b7e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b81:	80 fb 19             	cmp    $0x19,%bl
  800b84:	77 12                	ja     800b98 <strtol+0xac>
			dig = *s - 'A' + 10;
  800b86:	0f be c9             	movsbl %cl,%ecx
  800b89:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b8c:	39 f1                	cmp    %esi,%ecx
  800b8e:	7d 0c                	jge    800b9c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b90:	42                   	inc    %edx
  800b91:	0f af c6             	imul   %esi,%eax
  800b94:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b96:	eb c4                	jmp    800b5c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b98:	89 c1                	mov    %eax,%ecx
  800b9a:	eb 02                	jmp    800b9e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b9c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b9e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ba2:	74 05                	je     800ba9 <strtol+0xbd>
		*endptr = (char *) s;
  800ba4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ba7:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ba9:	85 ff                	test   %edi,%edi
  800bab:	74 04                	je     800bb1 <strtol+0xc5>
  800bad:	89 c8                	mov    %ecx,%eax
  800baf:	f7 d8                	neg    %eax
}
  800bb1:	5b                   	pop    %ebx
  800bb2:	5e                   	pop    %esi
  800bb3:	5f                   	pop    %edi
  800bb4:	5d                   	pop    %ebp
  800bb5:	c3                   	ret    
	...

00800bb8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	57                   	push   %edi
  800bbc:	56                   	push   %esi
  800bbd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbe:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc9:	89 c3                	mov    %eax,%ebx
  800bcb:	89 c7                	mov    %eax,%edi
  800bcd:	89 c6                	mov    %eax,%esi
  800bcf:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bd1:	5b                   	pop    %ebx
  800bd2:	5e                   	pop    %esi
  800bd3:	5f                   	pop    %edi
  800bd4:	5d                   	pop    %ebp
  800bd5:	c3                   	ret    

00800bd6 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	57                   	push   %edi
  800bda:	56                   	push   %esi
  800bdb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdc:	ba 00 00 00 00       	mov    $0x0,%edx
  800be1:	b8 01 00 00 00       	mov    $0x1,%eax
  800be6:	89 d1                	mov    %edx,%ecx
  800be8:	89 d3                	mov    %edx,%ebx
  800bea:	89 d7                	mov    %edx,%edi
  800bec:	89 d6                	mov    %edx,%esi
  800bee:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bf0:	5b                   	pop    %ebx
  800bf1:	5e                   	pop    %esi
  800bf2:	5f                   	pop    %edi
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	57                   	push   %edi
  800bf9:	56                   	push   %esi
  800bfa:	53                   	push   %ebx
  800bfb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c03:	b8 03 00 00 00       	mov    $0x3,%eax
  800c08:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0b:	89 cb                	mov    %ecx,%ebx
  800c0d:	89 cf                	mov    %ecx,%edi
  800c0f:	89 ce                	mov    %ecx,%esi
  800c11:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c13:	85 c0                	test   %eax,%eax
  800c15:	7e 28                	jle    800c3f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c17:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c1b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c22:	00 
  800c23:	c7 44 24 08 1f 1b 80 	movl   $0x801b1f,0x8(%esp)
  800c2a:	00 
  800c2b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c32:	00 
  800c33:	c7 04 24 3c 1b 80 00 	movl   $0x801b3c,(%esp)
  800c3a:	e8 d5 07 00 00       	call   801414 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c3f:	83 c4 2c             	add    $0x2c,%esp
  800c42:	5b                   	pop    %ebx
  800c43:	5e                   	pop    %esi
  800c44:	5f                   	pop    %edi
  800c45:	5d                   	pop    %ebp
  800c46:	c3                   	ret    

00800c47 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c47:	55                   	push   %ebp
  800c48:	89 e5                	mov    %esp,%ebp
  800c4a:	57                   	push   %edi
  800c4b:	56                   	push   %esi
  800c4c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c52:	b8 02 00 00 00       	mov    $0x2,%eax
  800c57:	89 d1                	mov    %edx,%ecx
  800c59:	89 d3                	mov    %edx,%ebx
  800c5b:	89 d7                	mov    %edx,%edi
  800c5d:	89 d6                	mov    %edx,%esi
  800c5f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c61:	5b                   	pop    %ebx
  800c62:	5e                   	pop    %esi
  800c63:	5f                   	pop    %edi
  800c64:	5d                   	pop    %ebp
  800c65:	c3                   	ret    

00800c66 <sys_yield>:

void
sys_yield(void)
{
  800c66:	55                   	push   %ebp
  800c67:	89 e5                	mov    %esp,%ebp
  800c69:	57                   	push   %edi
  800c6a:	56                   	push   %esi
  800c6b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c71:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c76:	89 d1                	mov    %edx,%ecx
  800c78:	89 d3                	mov    %edx,%ebx
  800c7a:	89 d7                	mov    %edx,%edi
  800c7c:	89 d6                	mov    %edx,%esi
  800c7e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c80:	5b                   	pop    %ebx
  800c81:	5e                   	pop    %esi
  800c82:	5f                   	pop    %edi
  800c83:	5d                   	pop    %ebp
  800c84:	c3                   	ret    

00800c85 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c85:	55                   	push   %ebp
  800c86:	89 e5                	mov    %esp,%ebp
  800c88:	57                   	push   %edi
  800c89:	56                   	push   %esi
  800c8a:	53                   	push   %ebx
  800c8b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8e:	be 00 00 00 00       	mov    $0x0,%esi
  800c93:	b8 04 00 00 00       	mov    $0x4,%eax
  800c98:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca1:	89 f7                	mov    %esi,%edi
  800ca3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca5:	85 c0                	test   %eax,%eax
  800ca7:	7e 28                	jle    800cd1 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cad:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800cb4:	00 
  800cb5:	c7 44 24 08 1f 1b 80 	movl   $0x801b1f,0x8(%esp)
  800cbc:	00 
  800cbd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cc4:	00 
  800cc5:	c7 04 24 3c 1b 80 00 	movl   $0x801b3c,(%esp)
  800ccc:	e8 43 07 00 00       	call   801414 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cd1:	83 c4 2c             	add    $0x2c,%esp
  800cd4:	5b                   	pop    %ebx
  800cd5:	5e                   	pop    %esi
  800cd6:	5f                   	pop    %edi
  800cd7:	5d                   	pop    %ebp
  800cd8:	c3                   	ret    

00800cd9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cd9:	55                   	push   %ebp
  800cda:	89 e5                	mov    %esp,%ebp
  800cdc:	57                   	push   %edi
  800cdd:	56                   	push   %esi
  800cde:	53                   	push   %ebx
  800cdf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce2:	b8 05 00 00 00       	mov    $0x5,%eax
  800ce7:	8b 75 18             	mov    0x18(%ebp),%esi
  800cea:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ced:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cf8:	85 c0                	test   %eax,%eax
  800cfa:	7e 28                	jle    800d24 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d00:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d07:	00 
  800d08:	c7 44 24 08 1f 1b 80 	movl   $0x801b1f,0x8(%esp)
  800d0f:	00 
  800d10:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d17:	00 
  800d18:	c7 04 24 3c 1b 80 00 	movl   $0x801b3c,(%esp)
  800d1f:	e8 f0 06 00 00       	call   801414 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d24:	83 c4 2c             	add    $0x2c,%esp
  800d27:	5b                   	pop    %ebx
  800d28:	5e                   	pop    %esi
  800d29:	5f                   	pop    %edi
  800d2a:	5d                   	pop    %ebp
  800d2b:	c3                   	ret    

00800d2c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d2c:	55                   	push   %ebp
  800d2d:	89 e5                	mov    %esp,%ebp
  800d2f:	57                   	push   %edi
  800d30:	56                   	push   %esi
  800d31:	53                   	push   %ebx
  800d32:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d35:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d3a:	b8 06 00 00 00       	mov    $0x6,%eax
  800d3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d42:	8b 55 08             	mov    0x8(%ebp),%edx
  800d45:	89 df                	mov    %ebx,%edi
  800d47:	89 de                	mov    %ebx,%esi
  800d49:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d4b:	85 c0                	test   %eax,%eax
  800d4d:	7e 28                	jle    800d77 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d53:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d5a:	00 
  800d5b:	c7 44 24 08 1f 1b 80 	movl   $0x801b1f,0x8(%esp)
  800d62:	00 
  800d63:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d6a:	00 
  800d6b:	c7 04 24 3c 1b 80 00 	movl   $0x801b3c,(%esp)
  800d72:	e8 9d 06 00 00       	call   801414 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d77:	83 c4 2c             	add    $0x2c,%esp
  800d7a:	5b                   	pop    %ebx
  800d7b:	5e                   	pop    %esi
  800d7c:	5f                   	pop    %edi
  800d7d:	5d                   	pop    %ebp
  800d7e:	c3                   	ret    

00800d7f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d7f:	55                   	push   %ebp
  800d80:	89 e5                	mov    %esp,%ebp
  800d82:	57                   	push   %edi
  800d83:	56                   	push   %esi
  800d84:	53                   	push   %ebx
  800d85:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d88:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d8d:	b8 08 00 00 00       	mov    $0x8,%eax
  800d92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d95:	8b 55 08             	mov    0x8(%ebp),%edx
  800d98:	89 df                	mov    %ebx,%edi
  800d9a:	89 de                	mov    %ebx,%esi
  800d9c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d9e:	85 c0                	test   %eax,%eax
  800da0:	7e 28                	jle    800dca <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800da6:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800dad:	00 
  800dae:	c7 44 24 08 1f 1b 80 	movl   $0x801b1f,0x8(%esp)
  800db5:	00 
  800db6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dbd:	00 
  800dbe:	c7 04 24 3c 1b 80 00 	movl   $0x801b3c,(%esp)
  800dc5:	e8 4a 06 00 00       	call   801414 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dca:	83 c4 2c             	add    $0x2c,%esp
  800dcd:	5b                   	pop    %ebx
  800dce:	5e                   	pop    %esi
  800dcf:	5f                   	pop    %edi
  800dd0:	5d                   	pop    %ebp
  800dd1:	c3                   	ret    

00800dd2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dd2:	55                   	push   %ebp
  800dd3:	89 e5                	mov    %esp,%ebp
  800dd5:	57                   	push   %edi
  800dd6:	56                   	push   %esi
  800dd7:	53                   	push   %ebx
  800dd8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ddb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800de0:	b8 09 00 00 00       	mov    $0x9,%eax
  800de5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de8:	8b 55 08             	mov    0x8(%ebp),%edx
  800deb:	89 df                	mov    %ebx,%edi
  800ded:	89 de                	mov    %ebx,%esi
  800def:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800df1:	85 c0                	test   %eax,%eax
  800df3:	7e 28                	jle    800e1d <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800df9:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e00:	00 
  800e01:	c7 44 24 08 1f 1b 80 	movl   $0x801b1f,0x8(%esp)
  800e08:	00 
  800e09:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e10:	00 
  800e11:	c7 04 24 3c 1b 80 00 	movl   $0x801b3c,(%esp)
  800e18:	e8 f7 05 00 00       	call   801414 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e1d:	83 c4 2c             	add    $0x2c,%esp
  800e20:	5b                   	pop    %ebx
  800e21:	5e                   	pop    %esi
  800e22:	5f                   	pop    %edi
  800e23:	5d                   	pop    %ebp
  800e24:	c3                   	ret    

00800e25 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e25:	55                   	push   %ebp
  800e26:	89 e5                	mov    %esp,%ebp
  800e28:	57                   	push   %edi
  800e29:	56                   	push   %esi
  800e2a:	53                   	push   %ebx
  800e2b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e33:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3e:	89 df                	mov    %ebx,%edi
  800e40:	89 de                	mov    %ebx,%esi
  800e42:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e44:	85 c0                	test   %eax,%eax
  800e46:	7e 28                	jle    800e70 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e48:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e4c:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e53:	00 
  800e54:	c7 44 24 08 1f 1b 80 	movl   $0x801b1f,0x8(%esp)
  800e5b:	00 
  800e5c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e63:	00 
  800e64:	c7 04 24 3c 1b 80 00 	movl   $0x801b3c,(%esp)
  800e6b:	e8 a4 05 00 00       	call   801414 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e70:	83 c4 2c             	add    $0x2c,%esp
  800e73:	5b                   	pop    %ebx
  800e74:	5e                   	pop    %esi
  800e75:	5f                   	pop    %edi
  800e76:	5d                   	pop    %ebp
  800e77:	c3                   	ret    

00800e78 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e78:	55                   	push   %ebp
  800e79:	89 e5                	mov    %esp,%ebp
  800e7b:	57                   	push   %edi
  800e7c:	56                   	push   %esi
  800e7d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e7e:	be 00 00 00 00       	mov    $0x0,%esi
  800e83:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e88:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e8b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e91:	8b 55 08             	mov    0x8(%ebp),%edx
  800e94:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e96:	5b                   	pop    %ebx
  800e97:	5e                   	pop    %esi
  800e98:	5f                   	pop    %edi
  800e99:	5d                   	pop    %ebp
  800e9a:	c3                   	ret    

00800e9b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e9b:	55                   	push   %ebp
  800e9c:	89 e5                	mov    %esp,%ebp
  800e9e:	57                   	push   %edi
  800e9f:	56                   	push   %esi
  800ea0:	53                   	push   %ebx
  800ea1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ea9:	b8 0d 00 00 00       	mov    $0xd,%eax
  800eae:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb1:	89 cb                	mov    %ecx,%ebx
  800eb3:	89 cf                	mov    %ecx,%edi
  800eb5:	89 ce                	mov    %ecx,%esi
  800eb7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eb9:	85 c0                	test   %eax,%eax
  800ebb:	7e 28                	jle    800ee5 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ebd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ec1:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800ec8:	00 
  800ec9:	c7 44 24 08 1f 1b 80 	movl   $0x801b1f,0x8(%esp)
  800ed0:	00 
  800ed1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ed8:	00 
  800ed9:	c7 04 24 3c 1b 80 00 	movl   $0x801b3c,(%esp)
  800ee0:	e8 2f 05 00 00       	call   801414 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ee5:	83 c4 2c             	add    $0x2c,%esp
  800ee8:	5b                   	pop    %ebx
  800ee9:	5e                   	pop    %esi
  800eea:	5f                   	pop    %edi
  800eeb:	5d                   	pop    %ebp
  800eec:	c3                   	ret    
  800eed:	00 00                	add    %al,(%eax)
	...

00800ef0 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ef0:	55                   	push   %ebp
  800ef1:	89 e5                	mov    %esp,%ebp
  800ef3:	53                   	push   %ebx
  800ef4:	83 ec 24             	sub    $0x24,%esp
  800ef7:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800efa:	8b 18                	mov    (%eax),%ebx
	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	if ((err & FEC_WR) == 0)
  800efc:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f00:	75 20                	jne    800f22 <pgfault+0x32>
		panic("pgfault: faulting address [%08x] not a write\n", addr);
  800f02:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f06:	c7 44 24 08 4c 1b 80 	movl   $0x801b4c,0x8(%esp)
  800f0d:	00 
  800f0e:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  800f15:	00 
  800f16:	c7 04 24 cc 1b 80 00 	movl   $0x801bcc,(%esp)
  800f1d:	e8 f2 04 00 00       	call   801414 <_panic>

	void *page_aligned_addr = (void *) ROUNDDOWN(addr, PGSIZE);
  800f22:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t page_num = (uint32_t) page_aligned_addr / PGSIZE;
  800f28:	89 d8                	mov    %ebx,%eax
  800f2a:	c1 e8 0c             	shr    $0xc,%eax
	if (!(uvpt[page_num] & PTE_COW))
  800f2d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f34:	f6 c4 08             	test   $0x8,%ah
  800f37:	75 1c                	jne    800f55 <pgfault+0x65>
		panic("pgfault: fault was not on a copy-on-write page\n");
  800f39:	c7 44 24 08 7c 1b 80 	movl   $0x801b7c,0x8(%esp)
  800f40:	00 
  800f41:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f48:	00 
  800f49:	c7 04 24 cc 1b 80 00 	movl   $0x801bcc,(%esp)
  800f50:	e8 bf 04 00 00       	call   801414 <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.

	// Allocate
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800f55:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800f5c:	00 
  800f5d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f64:	00 
  800f65:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f6c:	e8 14 fd ff ff       	call   800c85 <sys_page_alloc>
  800f71:	85 c0                	test   %eax,%eax
  800f73:	79 20                	jns    800f95 <pgfault+0xa5>
		panic("sys_page_alloc: %e\n", r);
  800f75:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f79:	c7 44 24 08 d7 1b 80 	movl   $0x801bd7,0x8(%esp)
  800f80:	00 
  800f81:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  800f88:	00 
  800f89:	c7 04 24 cc 1b 80 00 	movl   $0x801bcc,(%esp)
  800f90:	e8 7f 04 00 00       	call   801414 <_panic>

	// Copy over
	void *src_addr = (void *) ROUNDDOWN(addr, PGSIZE);
	memmove(PFTEMP, src_addr, PGSIZE);
  800f95:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800f9c:	00 
  800f9d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800fa1:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800fa8:	e8 5f fa ff ff       	call   800a0c <memmove>

	// Remap
	if ((r = sys_page_map(0, PFTEMP, 0, src_addr, PTE_P | PTE_U | PTE_W)) < 0)
  800fad:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800fb4:	00 
  800fb5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800fb9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fc0:	00 
  800fc1:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800fc8:	00 
  800fc9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fd0:	e8 04 fd ff ff       	call   800cd9 <sys_page_map>
  800fd5:	85 c0                	test   %eax,%eax
  800fd7:	79 20                	jns    800ff9 <pgfault+0x109>
		panic("sys_page_map: %e\n", r);
  800fd9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fdd:	c7 44 24 08 eb 1b 80 	movl   $0x801beb,0x8(%esp)
  800fe4:	00 
  800fe5:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  800fec:	00 
  800fed:	c7 04 24 cc 1b 80 00 	movl   $0x801bcc,(%esp)
  800ff4:	e8 1b 04 00 00       	call   801414 <_panic>

}
  800ff9:	83 c4 24             	add    $0x24,%esp
  800ffc:	5b                   	pop    %ebx
  800ffd:	5d                   	pop    %ebp
  800ffe:	c3                   	ret    

00800fff <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fff:	55                   	push   %ebp
  801000:	89 e5                	mov    %esp,%ebp
  801002:	57                   	push   %edi
  801003:	56                   	push   %esi
  801004:	53                   	push   %ebx
  801005:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	int r;
	envid_t child_envid;

	set_pgfault_handler(pgfault);
  801008:	c7 04 24 f0 0e 80 00 	movl   $0x800ef0,(%esp)
  80100f:	e8 58 04 00 00       	call   80146c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801014:	ba 07 00 00 00       	mov    $0x7,%edx
  801019:	89 d0                	mov    %edx,%eax
  80101b:	cd 30                	int    $0x30
  80101d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801020:	89 45 e0             	mov    %eax,-0x20(%ebp)

	child_envid = sys_exofork();
	if (child_envid < 0)
  801023:	85 c0                	test   %eax,%eax
  801025:	79 20                	jns    801047 <fork+0x48>
		panic("sys_exofork: %e\n", child_envid);
  801027:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80102b:	c7 44 24 08 fd 1b 80 	movl   $0x801bfd,0x8(%esp)
  801032:	00 
  801033:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  80103a:	00 
  80103b:	c7 04 24 cc 1b 80 00 	movl   $0x801bcc,(%esp)
  801042:	e8 cd 03 00 00       	call   801414 <_panic>
	if (child_envid == 0) { // child
  801047:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80104b:	75 25                	jne    801072 <fork+0x73>
		// Fix thisenv like dumbfork does and return 0
		thisenv = &envs[ENVX(sys_getenvid())];
  80104d:	e8 f5 fb ff ff       	call   800c47 <sys_getenvid>
  801052:	25 ff 03 00 00       	and    $0x3ff,%eax
  801057:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80105e:	c1 e0 07             	shl    $0x7,%eax
  801061:	29 d0                	sub    %edx,%eax
  801063:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801068:	a3 0c 20 80 00       	mov    %eax,0x80200c
		return 0;
  80106d:	e9 58 02 00 00       	jmp    8012ca <fork+0x2cb>
	set_pgfault_handler(pgfault);

	child_envid = sys_exofork();
	if (child_envid < 0)
		panic("sys_exofork: %e\n", child_envid);
	if (child_envid == 0) { // child
  801072:	bf 00 00 00 00       	mov    $0x0,%edi
  801077:	be 00 00 00 00       	mov    $0x0,%esi
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
  80107c:	89 f0                	mov    %esi,%eax
  80107e:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  801081:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801088:	a8 01                	test   $0x1,%al
  80108a:	0f 84 7a 01 00 00    	je     80120a <fork+0x20b>
			((uvpt[page_num] & PTE_P) == PTE_P)) {
  801090:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  801097:	a8 01                	test   $0x1,%al
  801099:	0f 84 6b 01 00 00    	je     80120a <fork+0x20b>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	envid_t this_envid = thisenv->env_id;
  80109f:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8010a4:	8b 40 48             	mov    0x48(%eax),%eax
  8010a7:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	if (uvpt[pn] & PTE_SHARE) {
  8010aa:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010b1:	f6 c4 04             	test   $0x4,%ah
  8010b4:	74 52                	je     801108 <fork+0x109>
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  8010b6:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010bd:	25 07 0e 00 00       	and    $0xe07,%eax
  8010c2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010c6:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8010cd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010d1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8010d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010d8:	89 04 24             	mov    %eax,(%esp)
  8010db:	e8 f9 fb ff ff       	call   800cd9 <sys_page_map>
  8010e0:	85 c0                	test   %eax,%eax
  8010e2:	0f 89 22 01 00 00    	jns    80120a <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  8010e8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010ec:	c7 44 24 08 eb 1b 80 	movl   $0x801beb,0x8(%esp)
  8010f3:	00 
  8010f4:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  8010fb:	00 
  8010fc:	c7 04 24 cc 1b 80 00 	movl   $0x801bcc,(%esp)
  801103:	e8 0c 03 00 00       	call   801414 <_panic>
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
  801108:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80110f:	f6 c4 08             	test   $0x8,%ah
  801112:	75 0f                	jne    801123 <fork+0x124>
  801114:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80111b:	a8 02                	test   $0x2,%al
  80111d:	0f 84 99 00 00 00    	je     8011bc <fork+0x1bd>
		if (uvpt[pn] & PTE_U)
  801123:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80112a:	83 e0 04             	and    $0x4,%eax
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
  80112d:	83 f8 01             	cmp    $0x1,%eax
  801130:	19 db                	sbb    %ebx,%ebx
  801132:	83 e3 fc             	and    $0xfffffffc,%ebx
  801135:	81 c3 05 08 00 00    	add    $0x805,%ebx
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
		if (uvpt[pn] & PTE_U)
			perm |= PTE_U;

		// Map page COW, U and P in child
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), perm)) < 0)
  80113b:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80113f:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801143:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801146:	89 44 24 08          	mov    %eax,0x8(%esp)
  80114a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80114e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801151:	89 04 24             	mov    %eax,(%esp)
  801154:	e8 80 fb ff ff       	call   800cd9 <sys_page_map>
  801159:	85 c0                	test   %eax,%eax
  80115b:	79 20                	jns    80117d <fork+0x17e>
			panic("sys_page_map: %e\n", r);
  80115d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801161:	c7 44 24 08 eb 1b 80 	movl   $0x801beb,0x8(%esp)
  801168:	00 
  801169:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  801170:	00 
  801171:	c7 04 24 cc 1b 80 00 	movl   $0x801bcc,(%esp)
  801178:	e8 97 02 00 00       	call   801414 <_panic>

		// Map page COW, U and P in parent
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), this_envid, (void *) (pn*PGSIZE), perm)) < 0)
  80117d:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801181:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801185:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801188:	89 44 24 08          	mov    %eax,0x8(%esp)
  80118c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801190:	89 04 24             	mov    %eax,(%esp)
  801193:	e8 41 fb ff ff       	call   800cd9 <sys_page_map>
  801198:	85 c0                	test   %eax,%eax
  80119a:	79 6e                	jns    80120a <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  80119c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011a0:	c7 44 24 08 eb 1b 80 	movl   $0x801beb,0x8(%esp)
  8011a7:	00 
  8011a8:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  8011af:	00 
  8011b0:	c7 04 24 cc 1b 80 00 	movl   $0x801bcc,(%esp)
  8011b7:	e8 58 02 00 00       	call   801414 <_panic>

	} else { // map pages that are present but not writable or COW with their original permissions
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  8011bc:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011c3:	25 07 0e 00 00       	and    $0xe07,%eax
  8011c8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011cc:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8011d3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011d7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011de:	89 04 24             	mov    %eax,(%esp)
  8011e1:	e8 f3 fa ff ff       	call   800cd9 <sys_page_map>
  8011e6:	85 c0                	test   %eax,%eax
  8011e8:	79 20                	jns    80120a <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  8011ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011ee:	c7 44 24 08 eb 1b 80 	movl   $0x801beb,0x8(%esp)
  8011f5:	00 
  8011f6:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  8011fd:	00 
  8011fe:	c7 04 24 cc 1b 80 00 	movl   $0x801bcc,(%esp)
  801205:	e8 0a 02 00 00       	call   801414 <_panic>
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
  80120a:	46                   	inc    %esi
  80120b:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801211:	81 fe ff eb 0e 00    	cmp    $0xeebff,%esi
  801217:	0f 85 5f fe ff ff    	jne    80107c <fork+0x7d>
	}

	// Allocate exception stack space for child. The child can't do this themselves
	// because the mechanism by which it would is to run the pgfault handler, which
	// needs to run on the exception stack (catch 22).
	if ((r = sys_page_alloc(child_envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  80121d:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801224:	00 
  801225:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80122c:	ee 
  80122d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801230:	89 04 24             	mov    %eax,(%esp)
  801233:	e8 4d fa ff ff       	call   800c85 <sys_page_alloc>
  801238:	85 c0                	test   %eax,%eax
  80123a:	79 20                	jns    80125c <fork+0x25d>
		panic("sys_page_alloc: %e\n", r);
  80123c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801240:	c7 44 24 08 d7 1b 80 	movl   $0x801bd7,0x8(%esp)
  801247:	00 
  801248:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  80124f:	00 
  801250:	c7 04 24 cc 1b 80 00 	movl   $0x801bcc,(%esp)
  801257:	e8 b8 01 00 00       	call   801414 <_panic>

	// Set page fault handler for the child
	if ((r = sys_env_set_pgfault_upcall(child_envid, _pgfault_upcall)) < 0)
  80125c:	c7 44 24 04 e0 14 80 	movl   $0x8014e0,0x4(%esp)
  801263:	00 
  801264:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801267:	89 04 24             	mov    %eax,(%esp)
  80126a:	e8 b6 fb ff ff       	call   800e25 <sys_env_set_pgfault_upcall>
  80126f:	85 c0                	test   %eax,%eax
  801271:	79 20                	jns    801293 <fork+0x294>
		panic("sys_env_set_pgfault_upcall: %e\n", r);
  801273:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801277:	c7 44 24 08 ac 1b 80 	movl   $0x801bac,0x8(%esp)
  80127e:	00 
  80127f:	c7 44 24 04 a1 00 00 	movl   $0xa1,0x4(%esp)
  801286:	00 
  801287:	c7 04 24 cc 1b 80 00 	movl   $0x801bcc,(%esp)
  80128e:	e8 81 01 00 00       	call   801414 <_panic>

	// Mark child environment as runnable
	if ((r = sys_env_set_status(child_envid, ENV_RUNNABLE)) < 0)
  801293:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80129a:	00 
  80129b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80129e:	89 04 24             	mov    %eax,(%esp)
  8012a1:	e8 d9 fa ff ff       	call   800d7f <sys_env_set_status>
  8012a6:	85 c0                	test   %eax,%eax
  8012a8:	79 20                	jns    8012ca <fork+0x2cb>
		panic("sys_env_set_status: %e\n", r);
  8012aa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012ae:	c7 44 24 08 0e 1c 80 	movl   $0x801c0e,0x8(%esp)
  8012b5:	00 
  8012b6:	c7 44 24 04 a5 00 00 	movl   $0xa5,0x4(%esp)
  8012bd:	00 
  8012be:	c7 04 24 cc 1b 80 00 	movl   $0x801bcc,(%esp)
  8012c5:	e8 4a 01 00 00       	call   801414 <_panic>

	return child_envid;
}
  8012ca:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012cd:	83 c4 3c             	add    $0x3c,%esp
  8012d0:	5b                   	pop    %ebx
  8012d1:	5e                   	pop    %esi
  8012d2:	5f                   	pop    %edi
  8012d3:	5d                   	pop    %ebp
  8012d4:	c3                   	ret    

008012d5 <sfork>:

// Challenge!
int
sfork(void)
{
  8012d5:	55                   	push   %ebp
  8012d6:	89 e5                	mov    %esp,%ebp
  8012d8:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8012db:	c7 44 24 08 26 1c 80 	movl   $0x801c26,0x8(%esp)
  8012e2:	00 
  8012e3:	c7 44 24 04 ae 00 00 	movl   $0xae,0x4(%esp)
  8012ea:	00 
  8012eb:	c7 04 24 cc 1b 80 00 	movl   $0x801bcc,(%esp)
  8012f2:	e8 1d 01 00 00       	call   801414 <_panic>
	...

008012f8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8012f8:	55                   	push   %ebp
  8012f9:	89 e5                	mov    %esp,%ebp
  8012fb:	56                   	push   %esi
  8012fc:	53                   	push   %ebx
  8012fd:	83 ec 10             	sub    $0x10,%esp
  801300:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801303:	8b 45 0c             	mov    0xc(%ebp),%eax
  801306:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int r;
		
	r = sys_ipc_recv(pg?pg:(void*)UTOP);
  801309:	85 c0                	test   %eax,%eax
  80130b:	75 05                	jne    801312 <ipc_recv+0x1a>
  80130d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801312:	89 04 24             	mov    %eax,(%esp)
  801315:	e8 81 fb ff ff       	call   800e9b <sys_ipc_recv>
	if (from_env_store != NULL)
  80131a:	85 db                	test   %ebx,%ebx
  80131c:	74 0b                	je     801329 <ipc_recv+0x31>
		*from_env_store = thisenv->env_ipc_from; 
  80131e:	8b 15 0c 20 80 00    	mov    0x80200c,%edx
  801324:	8b 52 74             	mov    0x74(%edx),%edx
  801327:	89 13                	mov    %edx,(%ebx)
	if (perm_store != NULL)
  801329:	85 f6                	test   %esi,%esi
  80132b:	74 0b                	je     801338 <ipc_recv+0x40>
		*perm_store = thisenv->env_ipc_perm;
  80132d:	8b 15 0c 20 80 00    	mov    0x80200c,%edx
  801333:	8b 52 78             	mov    0x78(%edx),%edx
  801336:	89 16                	mov    %edx,(%esi)
	
	if (r < 0){
  801338:	85 c0                	test   %eax,%eax
  80133a:	79 16                	jns    801352 <ipc_recv+0x5a>
		if(from_env_store != NULL)
  80133c:	85 db                	test   %ebx,%ebx
  80133e:	74 06                	je     801346 <ipc_recv+0x4e>
			*from_env_store = 0;
  801340:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store != NULL)	
  801346:	85 f6                	test   %esi,%esi
  801348:	74 10                	je     80135a <ipc_recv+0x62>
			*perm_store = 0;
  80134a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801350:	eb 08                	jmp    80135a <ipc_recv+0x62>
		return r;
	}
	
	return thisenv->env_ipc_value;
  801352:	a1 0c 20 80 00       	mov    0x80200c,%eax
  801357:	8b 40 70             	mov    0x70(%eax),%eax
}
  80135a:	83 c4 10             	add    $0x10,%esp
  80135d:	5b                   	pop    %ebx
  80135e:	5e                   	pop    %esi
  80135f:	5d                   	pop    %ebp
  801360:	c3                   	ret    

00801361 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801361:	55                   	push   %ebp
  801362:	89 e5                	mov    %esp,%ebp
  801364:	57                   	push   %edi
  801365:	56                   	push   %esi
  801366:	53                   	push   %ebx
  801367:	83 ec 1c             	sub    $0x1c,%esp
  80136a:	8b 75 08             	mov    0x8(%ebp),%esi
  80136d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801370:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  801373:	eb 2a                	jmp    80139f <ipc_send+0x3e>
		if (r != -E_IPC_NOT_RECV)
  801375:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801378:	74 20                	je     80139a <ipc_send+0x39>
			panic("ipc_send: sys_ipc_try_send failed %e", r);
  80137a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80137e:	c7 44 24 08 3c 1c 80 	movl   $0x801c3c,0x8(%esp)
  801385:	00 
  801386:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  80138d:	00 
  80138e:	c7 04 24 61 1c 80 00 	movl   $0x801c61,(%esp)
  801395:	e8 7a 00 00 00       	call   801414 <_panic>
		sys_yield();
  80139a:	e8 c7 f8 ff ff       	call   800c66 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  80139f:	85 db                	test   %ebx,%ebx
  8013a1:	75 07                	jne    8013aa <ipc_send+0x49>
  8013a3:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8013a8:	eb 02                	jmp    8013ac <ipc_send+0x4b>
  8013aa:	89 d8                	mov    %ebx,%eax
  8013ac:	8b 55 14             	mov    0x14(%ebp),%edx
  8013af:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8013b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013b7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013bb:	89 34 24             	mov    %esi,(%esp)
  8013be:	e8 b5 fa ff ff       	call   800e78 <sys_ipc_try_send>
  8013c3:	85 c0                	test   %eax,%eax
  8013c5:	78 ae                	js     801375 <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: sys_ipc_try_send failed %e", r);
		sys_yield();
	}
}
  8013c7:	83 c4 1c             	add    $0x1c,%esp
  8013ca:	5b                   	pop    %ebx
  8013cb:	5e                   	pop    %esi
  8013cc:	5f                   	pop    %edi
  8013cd:	5d                   	pop    %ebp
  8013ce:	c3                   	ret    

008013cf <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8013cf:	55                   	push   %ebp
  8013d0:	89 e5                	mov    %esp,%ebp
  8013d2:	53                   	push   %ebx
  8013d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  8013d6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8013db:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8013e2:	89 c2                	mov    %eax,%edx
  8013e4:	c1 e2 07             	shl    $0x7,%edx
  8013e7:	29 ca                	sub    %ecx,%edx
  8013e9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8013ef:	8b 52 50             	mov    0x50(%edx),%edx
  8013f2:	39 da                	cmp    %ebx,%edx
  8013f4:	75 0f                	jne    801405 <ipc_find_env+0x36>
			return envs[i].env_id;
  8013f6:	c1 e0 07             	shl    $0x7,%eax
  8013f9:	29 c8                	sub    %ecx,%eax
  8013fb:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801400:	8b 40 40             	mov    0x40(%eax),%eax
  801403:	eb 0c                	jmp    801411 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801405:	40                   	inc    %eax
  801406:	3d 00 04 00 00       	cmp    $0x400,%eax
  80140b:	75 ce                	jne    8013db <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80140d:	66 b8 00 00          	mov    $0x0,%ax
}
  801411:	5b                   	pop    %ebx
  801412:	5d                   	pop    %ebp
  801413:	c3                   	ret    

00801414 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801414:	55                   	push   %ebp
  801415:	89 e5                	mov    %esp,%ebp
  801417:	56                   	push   %esi
  801418:	53                   	push   %ebx
  801419:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80141c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80141f:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  801425:	e8 1d f8 ff ff       	call   800c47 <sys_getenvid>
  80142a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80142d:	89 54 24 10          	mov    %edx,0x10(%esp)
  801431:	8b 55 08             	mov    0x8(%ebp),%edx
  801434:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801438:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80143c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801440:	c7 04 24 6c 1c 80 00 	movl   $0x801c6c,(%esp)
  801447:	e8 9c ee ff ff       	call   8002e8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80144c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801450:	8b 45 10             	mov    0x10(%ebp),%eax
  801453:	89 04 24             	mov    %eax,(%esp)
  801456:	e8 2c ee ff ff       	call   800287 <vcprintf>
	cprintf("\n");
  80145b:	c7 04 24 e9 1b 80 00 	movl   $0x801be9,(%esp)
  801462:	e8 81 ee ff ff       	call   8002e8 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801467:	cc                   	int3   
  801468:	eb fd                	jmp    801467 <_panic+0x53>
	...

0080146c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80146c:	55                   	push   %ebp
  80146d:	89 e5                	mov    %esp,%ebp
  80146f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801472:	83 3d 10 20 80 00 00 	cmpl   $0x0,0x802010
  801479:	75 58                	jne    8014d3 <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.	
		//panic("set_pgfault_handler not implemented");
		
		if (sys_page_alloc(thisenv->env_id,(void *) (UXSTACKTOP - PGSIZE),(PTE_W|PTE_U|PTE_P)) != 0){
  80147b:	a1 0c 20 80 00       	mov    0x80200c,%eax
  801480:	8b 40 48             	mov    0x48(%eax),%eax
  801483:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80148a:	00 
  80148b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801492:	ee 
  801493:	89 04 24             	mov    %eax,(%esp)
  801496:	e8 ea f7 ff ff       	call   800c85 <sys_page_alloc>
  80149b:	85 c0                	test   %eax,%eax
  80149d:	74 1c                	je     8014bb <set_pgfault_handler+0x4f>
			panic("set_pg_fault_handler");
  80149f:	c7 44 24 08 90 1c 80 	movl   $0x801c90,0x8(%esp)
  8014a6:	00 
  8014a7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8014ae:	00 
  8014af:	c7 04 24 a5 1c 80 00 	movl   $0x801ca5,(%esp)
  8014b6:	e8 59 ff ff ff       	call   801414 <_panic>
		}
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  8014bb:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8014c0:	8b 40 48             	mov    0x48(%eax),%eax
  8014c3:	c7 44 24 04 e0 14 80 	movl   $0x8014e0,0x4(%esp)
  8014ca:	00 
  8014cb:	89 04 24             	mov    %eax,(%esp)
  8014ce:	e8 52 f9 ff ff       	call   800e25 <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8014d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d6:	a3 10 20 80 00       	mov    %eax,0x802010
}
  8014db:	c9                   	leave  
  8014dc:	c3                   	ret    
  8014dd:	00 00                	add    %al,(%eax)
	...

008014e0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8014e0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8014e1:	a1 10 20 80 00       	mov    0x802010,%eax
	call *%eax
  8014e6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8014e8:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// Save trap-time eip in eax
	movl 0x28(%esp), %eax
  8014eb:	8b 44 24 28          	mov    0x28(%esp),%eax

	// Save our current stack
	movl %esp, %ebp
  8014ef:	89 e5                	mov    %esp,%ebp

	// Switch to trap-time stack
	movl 0x30(%esp), %esp
  8014f1:	8b 64 24 30          	mov    0x30(%esp),%esp

	// Push trap-time eip to the trap-time stack
	pushl %eax
  8014f5:	50                   	push   %eax

	// We now have to update the trap-time esp with its new value
	movl %esp, 0x30(%ebp)
  8014f6:	89 65 30             	mov    %esp,0x30(%ebp)

	// Go back to our exception stack
	movl %ebp, %esp
  8014f9:	89 ec                	mov    %ebp,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// Pop fault_va and err, both can be ignored
	popl %eax
  8014fb:	58                   	pop    %eax
	popl %eax
  8014fc:	58                   	pop    %eax

	// Pop all registers back
	popal
  8014fd:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// Skip %eip
	addl $0x4, %esp
  8014fe:	83 c4 04             	add    $0x4,%esp

	// Pop eflags back
	popfl
  801501:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	
	popl %esp
  801502:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  801503:	c3                   	ret    

00801504 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801504:	55                   	push   %ebp
  801505:	57                   	push   %edi
  801506:	56                   	push   %esi
  801507:	83 ec 10             	sub    $0x10,%esp
  80150a:	8b 74 24 20          	mov    0x20(%esp),%esi
  80150e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801512:	89 74 24 04          	mov    %esi,0x4(%esp)
  801516:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  80151a:	89 cd                	mov    %ecx,%ebp
  80151c:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801520:	85 c0                	test   %eax,%eax
  801522:	75 2c                	jne    801550 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801524:	39 f9                	cmp    %edi,%ecx
  801526:	77 68                	ja     801590 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801528:	85 c9                	test   %ecx,%ecx
  80152a:	75 0b                	jne    801537 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80152c:	b8 01 00 00 00       	mov    $0x1,%eax
  801531:	31 d2                	xor    %edx,%edx
  801533:	f7 f1                	div    %ecx
  801535:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801537:	31 d2                	xor    %edx,%edx
  801539:	89 f8                	mov    %edi,%eax
  80153b:	f7 f1                	div    %ecx
  80153d:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80153f:	89 f0                	mov    %esi,%eax
  801541:	f7 f1                	div    %ecx
  801543:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801545:	89 f0                	mov    %esi,%eax
  801547:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801549:	83 c4 10             	add    $0x10,%esp
  80154c:	5e                   	pop    %esi
  80154d:	5f                   	pop    %edi
  80154e:	5d                   	pop    %ebp
  80154f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801550:	39 f8                	cmp    %edi,%eax
  801552:	77 2c                	ja     801580 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801554:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  801557:	83 f6 1f             	xor    $0x1f,%esi
  80155a:	75 4c                	jne    8015a8 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80155c:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80155e:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801563:	72 0a                	jb     80156f <__udivdi3+0x6b>
  801565:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801569:	0f 87 ad 00 00 00    	ja     80161c <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80156f:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801574:	89 f0                	mov    %esi,%eax
  801576:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801578:	83 c4 10             	add    $0x10,%esp
  80157b:	5e                   	pop    %esi
  80157c:	5f                   	pop    %edi
  80157d:	5d                   	pop    %ebp
  80157e:	c3                   	ret    
  80157f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801580:	31 ff                	xor    %edi,%edi
  801582:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801584:	89 f0                	mov    %esi,%eax
  801586:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801588:	83 c4 10             	add    $0x10,%esp
  80158b:	5e                   	pop    %esi
  80158c:	5f                   	pop    %edi
  80158d:	5d                   	pop    %ebp
  80158e:	c3                   	ret    
  80158f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801590:	89 fa                	mov    %edi,%edx
  801592:	89 f0                	mov    %esi,%eax
  801594:	f7 f1                	div    %ecx
  801596:	89 c6                	mov    %eax,%esi
  801598:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80159a:	89 f0                	mov    %esi,%eax
  80159c:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80159e:	83 c4 10             	add    $0x10,%esp
  8015a1:	5e                   	pop    %esi
  8015a2:	5f                   	pop    %edi
  8015a3:	5d                   	pop    %ebp
  8015a4:	c3                   	ret    
  8015a5:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8015a8:	89 f1                	mov    %esi,%ecx
  8015aa:	d3 e0                	shl    %cl,%eax
  8015ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8015b0:	b8 20 00 00 00       	mov    $0x20,%eax
  8015b5:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8015b7:	89 ea                	mov    %ebp,%edx
  8015b9:	88 c1                	mov    %al,%cl
  8015bb:	d3 ea                	shr    %cl,%edx
  8015bd:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8015c1:	09 ca                	or     %ecx,%edx
  8015c3:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  8015c7:	89 f1                	mov    %esi,%ecx
  8015c9:	d3 e5                	shl    %cl,%ebp
  8015cb:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  8015cf:	89 fd                	mov    %edi,%ebp
  8015d1:	88 c1                	mov    %al,%cl
  8015d3:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  8015d5:	89 fa                	mov    %edi,%edx
  8015d7:	89 f1                	mov    %esi,%ecx
  8015d9:	d3 e2                	shl    %cl,%edx
  8015db:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8015df:	88 c1                	mov    %al,%cl
  8015e1:	d3 ef                	shr    %cl,%edi
  8015e3:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8015e5:	89 f8                	mov    %edi,%eax
  8015e7:	89 ea                	mov    %ebp,%edx
  8015e9:	f7 74 24 08          	divl   0x8(%esp)
  8015ed:	89 d1                	mov    %edx,%ecx
  8015ef:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  8015f1:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8015f5:	39 d1                	cmp    %edx,%ecx
  8015f7:	72 17                	jb     801610 <__udivdi3+0x10c>
  8015f9:	74 09                	je     801604 <__udivdi3+0x100>
  8015fb:	89 fe                	mov    %edi,%esi
  8015fd:	31 ff                	xor    %edi,%edi
  8015ff:	e9 41 ff ff ff       	jmp    801545 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801604:	8b 54 24 04          	mov    0x4(%esp),%edx
  801608:	89 f1                	mov    %esi,%ecx
  80160a:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80160c:	39 c2                	cmp    %eax,%edx
  80160e:	73 eb                	jae    8015fb <__udivdi3+0xf7>
		{
		  q0--;
  801610:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801613:	31 ff                	xor    %edi,%edi
  801615:	e9 2b ff ff ff       	jmp    801545 <__udivdi3+0x41>
  80161a:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80161c:	31 f6                	xor    %esi,%esi
  80161e:	e9 22 ff ff ff       	jmp    801545 <__udivdi3+0x41>
	...

00801624 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801624:	55                   	push   %ebp
  801625:	57                   	push   %edi
  801626:	56                   	push   %esi
  801627:	83 ec 20             	sub    $0x20,%esp
  80162a:	8b 44 24 30          	mov    0x30(%esp),%eax
  80162e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801632:	89 44 24 14          	mov    %eax,0x14(%esp)
  801636:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  80163a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80163e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801642:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  801644:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801646:	85 ed                	test   %ebp,%ebp
  801648:	75 16                	jne    801660 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  80164a:	39 f1                	cmp    %esi,%ecx
  80164c:	0f 86 a6 00 00 00    	jbe    8016f8 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801652:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801654:	89 d0                	mov    %edx,%eax
  801656:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801658:	83 c4 20             	add    $0x20,%esp
  80165b:	5e                   	pop    %esi
  80165c:	5f                   	pop    %edi
  80165d:	5d                   	pop    %ebp
  80165e:	c3                   	ret    
  80165f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801660:	39 f5                	cmp    %esi,%ebp
  801662:	0f 87 ac 00 00 00    	ja     801714 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801668:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  80166b:	83 f0 1f             	xor    $0x1f,%eax
  80166e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801672:	0f 84 a8 00 00 00    	je     801720 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801678:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80167c:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80167e:	bf 20 00 00 00       	mov    $0x20,%edi
  801683:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801687:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80168b:	89 f9                	mov    %edi,%ecx
  80168d:	d3 e8                	shr    %cl,%eax
  80168f:	09 e8                	or     %ebp,%eax
  801691:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  801695:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801699:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80169d:	d3 e0                	shl    %cl,%eax
  80169f:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8016a3:	89 f2                	mov    %esi,%edx
  8016a5:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8016a7:	8b 44 24 14          	mov    0x14(%esp),%eax
  8016ab:	d3 e0                	shl    %cl,%eax
  8016ad:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8016b1:	8b 44 24 14          	mov    0x14(%esp),%eax
  8016b5:	89 f9                	mov    %edi,%ecx
  8016b7:	d3 e8                	shr    %cl,%eax
  8016b9:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8016bb:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8016bd:	89 f2                	mov    %esi,%edx
  8016bf:	f7 74 24 18          	divl   0x18(%esp)
  8016c3:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8016c5:	f7 64 24 0c          	mull   0xc(%esp)
  8016c9:	89 c5                	mov    %eax,%ebp
  8016cb:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8016cd:	39 d6                	cmp    %edx,%esi
  8016cf:	72 67                	jb     801738 <__umoddi3+0x114>
  8016d1:	74 75                	je     801748 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8016d3:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8016d7:	29 e8                	sub    %ebp,%eax
  8016d9:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8016db:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8016df:	d3 e8                	shr    %cl,%eax
  8016e1:	89 f2                	mov    %esi,%edx
  8016e3:	89 f9                	mov    %edi,%ecx
  8016e5:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8016e7:	09 d0                	or     %edx,%eax
  8016e9:	89 f2                	mov    %esi,%edx
  8016eb:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8016ef:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8016f1:	83 c4 20             	add    $0x20,%esp
  8016f4:	5e                   	pop    %esi
  8016f5:	5f                   	pop    %edi
  8016f6:	5d                   	pop    %ebp
  8016f7:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8016f8:	85 c9                	test   %ecx,%ecx
  8016fa:	75 0b                	jne    801707 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8016fc:	b8 01 00 00 00       	mov    $0x1,%eax
  801701:	31 d2                	xor    %edx,%edx
  801703:	f7 f1                	div    %ecx
  801705:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801707:	89 f0                	mov    %esi,%eax
  801709:	31 d2                	xor    %edx,%edx
  80170b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80170d:	89 f8                	mov    %edi,%eax
  80170f:	e9 3e ff ff ff       	jmp    801652 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801714:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801716:	83 c4 20             	add    $0x20,%esp
  801719:	5e                   	pop    %esi
  80171a:	5f                   	pop    %edi
  80171b:	5d                   	pop    %ebp
  80171c:	c3                   	ret    
  80171d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801720:	39 f5                	cmp    %esi,%ebp
  801722:	72 04                	jb     801728 <__umoddi3+0x104>
  801724:	39 f9                	cmp    %edi,%ecx
  801726:	77 06                	ja     80172e <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801728:	89 f2                	mov    %esi,%edx
  80172a:	29 cf                	sub    %ecx,%edi
  80172c:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  80172e:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801730:	83 c4 20             	add    $0x20,%esp
  801733:	5e                   	pop    %esi
  801734:	5f                   	pop    %edi
  801735:	5d                   	pop    %ebp
  801736:	c3                   	ret    
  801737:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801738:	89 d1                	mov    %edx,%ecx
  80173a:	89 c5                	mov    %eax,%ebp
  80173c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801740:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801744:	eb 8d                	jmp    8016d3 <__umoddi3+0xaf>
  801746:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801748:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  80174c:	72 ea                	jb     801738 <__umoddi3+0x114>
  80174e:	89 f1                	mov    %esi,%ecx
  801750:	eb 81                	jmp    8016d3 <__umoddi3+0xaf>
