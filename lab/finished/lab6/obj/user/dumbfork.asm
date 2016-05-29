
obj/user/dumbfork.debug:     file format elf32-i386


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
  80002c:	e8 0b 02 00 00       	call   80023c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 20             	sub    $0x20,%esp
  80003c:	8b 75 08             	mov    0x8(%ebp),%esi
  80003f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800042:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800049:	00 
  80004a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80004e:	89 34 24             	mov    %esi,(%esp)
  800051:	e8 d7 0c 00 00       	call   800d2d <sys_page_alloc>
  800056:	85 c0                	test   %eax,%eax
  800058:	79 20                	jns    80007a <duppage+0x46>
		panic("sys_page_alloc: %e", r);
  80005a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005e:	c7 44 24 08 80 12 80 	movl   $0x801280,0x8(%esp)
  800065:	00 
  800066:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  80006d:	00 
  80006e:	c7 04 24 93 12 80 00 	movl   $0x801293,(%esp)
  800075:	e8 1e 02 00 00       	call   800298 <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80007a:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800081:	00 
  800082:	c7 44 24 0c 00 00 40 	movl   $0x400000,0xc(%esp)
  800089:	00 
  80008a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800091:	00 
  800092:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800096:	89 34 24             	mov    %esi,(%esp)
  800099:	e8 e3 0c 00 00       	call   800d81 <sys_page_map>
  80009e:	85 c0                	test   %eax,%eax
  8000a0:	79 20                	jns    8000c2 <duppage+0x8e>
		panic("sys_page_map: %e", r);
  8000a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000a6:	c7 44 24 08 a3 12 80 	movl   $0x8012a3,0x8(%esp)
  8000ad:	00 
  8000ae:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8000b5:	00 
  8000b6:	c7 04 24 93 12 80 00 	movl   $0x801293,(%esp)
  8000bd:	e8 d6 01 00 00       	call   800298 <_panic>
	memmove(UTEMP, addr, PGSIZE);
  8000c2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8000c9:	00 
  8000ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000ce:	c7 04 24 00 00 40 00 	movl   $0x400000,(%esp)
  8000d5:	e8 da 09 00 00       	call   800ab4 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000da:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8000e1:	00 
  8000e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000e9:	e8 e6 0c 00 00       	call   800dd4 <sys_page_unmap>
  8000ee:	85 c0                	test   %eax,%eax
  8000f0:	79 20                	jns    800112 <duppage+0xde>
		panic("sys_page_unmap: %e", r);
  8000f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000f6:	c7 44 24 08 b4 12 80 	movl   $0x8012b4,0x8(%esp)
  8000fd:	00 
  8000fe:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800105:	00 
  800106:	c7 04 24 93 12 80 00 	movl   $0x801293,(%esp)
  80010d:	e8 86 01 00 00       	call   800298 <_panic>
}
  800112:	83 c4 20             	add    $0x20,%esp
  800115:	5b                   	pop    %ebx
  800116:	5e                   	pop    %esi
  800117:	5d                   	pop    %ebp
  800118:	c3                   	ret    

00800119 <dumbfork>:

envid_t
dumbfork(void)
{
  800119:	55                   	push   %ebp
  80011a:	89 e5                	mov    %esp,%ebp
  80011c:	56                   	push   %esi
  80011d:	53                   	push   %ebx
  80011e:	83 ec 20             	sub    $0x20,%esp
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800121:	be 07 00 00 00       	mov    $0x7,%esi
  800126:	89 f0                	mov    %esi,%eax
  800128:	cd 30                	int    $0x30
  80012a:	89 c6                	mov    %eax,%esi
  80012c:	89 c3                	mov    %eax,%ebx
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  80012e:	85 c0                	test   %eax,%eax
  800130:	79 20                	jns    800152 <dumbfork+0x39>
		panic("sys_exofork: %e", envid);
  800132:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800136:	c7 44 24 08 c7 12 80 	movl   $0x8012c7,0x8(%esp)
  80013d:	00 
  80013e:	c7 44 24 04 37 00 00 	movl   $0x37,0x4(%esp)
  800145:	00 
  800146:	c7 04 24 93 12 80 00 	movl   $0x801293,(%esp)
  80014d:	e8 46 01 00 00       	call   800298 <_panic>
	if (envid == 0) {
  800152:	85 c0                	test   %eax,%eax
  800154:	75 19                	jne    80016f <dumbfork+0x56>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800156:	e8 94 0b 00 00       	call   800cef <sys_getenvid>
  80015b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800160:	c1 e0 07             	shl    $0x7,%eax
  800163:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800168:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  80016d:	eb 6e                	jmp    8001dd <dumbfork+0xc4>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80016f:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800176:	eb 13                	jmp    80018b <dumbfork+0x72>
		duppage(envid, addr);
  800178:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017c:	89 1c 24             	mov    %ebx,(%esp)
  80017f:	e8 b0 fe ff ff       	call   800034 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800184:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  80018b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80018e:	3d 08 20 80 00       	cmp    $0x802008,%eax
  800193:	72 e3                	jb     800178 <dumbfork+0x5f>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  800195:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800198:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80019d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a1:	89 34 24             	mov    %esi,(%esp)
  8001a4:	e8 8b fe ff ff       	call   800034 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8001a9:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8001b0:	00 
  8001b1:	89 34 24             	mov    %esi,(%esp)
  8001b4:	e8 6e 0c 00 00       	call   800e27 <sys_env_set_status>
  8001b9:	85 c0                	test   %eax,%eax
  8001bb:	79 20                	jns    8001dd <dumbfork+0xc4>
		panic("sys_env_set_status: %e", r);
  8001bd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001c1:	c7 44 24 08 d7 12 80 	movl   $0x8012d7,0x8(%esp)
  8001c8:	00 
  8001c9:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  8001d0:	00 
  8001d1:	c7 04 24 93 12 80 00 	movl   $0x801293,(%esp)
  8001d8:	e8 bb 00 00 00       	call   800298 <_panic>

	return envid;
}
  8001dd:	89 f0                	mov    %esi,%eax
  8001df:	83 c4 20             	add    $0x20,%esp
  8001e2:	5b                   	pop    %ebx
  8001e3:	5e                   	pop    %esi
  8001e4:	5d                   	pop    %ebp
  8001e5:	c3                   	ret    

008001e6 <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  8001e6:	55                   	push   %ebp
  8001e7:	89 e5                	mov    %esp,%ebp
  8001e9:	56                   	push   %esi
  8001ea:	53                   	push   %ebx
  8001eb:	83 ec 10             	sub    $0x10,%esp
	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  8001ee:	e8 26 ff ff ff       	call   800119 <dumbfork>
  8001f3:	89 c3                	mov    %eax,%ebx

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001f5:	be 00 00 00 00       	mov    $0x0,%esi
  8001fa:	eb 2a                	jmp    800226 <umain+0x40>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  8001fc:	85 db                	test   %ebx,%ebx
  8001fe:	74 07                	je     800207 <umain+0x21>
  800200:	b8 ee 12 80 00       	mov    $0x8012ee,%eax
  800205:	eb 05                	jmp    80020c <umain+0x26>
  800207:	b8 f5 12 80 00       	mov    $0x8012f5,%eax
  80020c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800210:	89 74 24 04          	mov    %esi,0x4(%esp)
  800214:	c7 04 24 fb 12 80 00 	movl   $0x8012fb,(%esp)
  80021b:	e8 70 01 00 00       	call   800390 <cprintf>
		sys_yield();
  800220:	e8 e9 0a 00 00       	call   800d0e <sys_yield>

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800225:	46                   	inc    %esi
  800226:	83 fb 01             	cmp    $0x1,%ebx
  800229:	19 c0                	sbb    %eax,%eax
  80022b:	83 e0 0a             	and    $0xa,%eax
  80022e:	83 c0 0a             	add    $0xa,%eax
  800231:	39 c6                	cmp    %eax,%esi
  800233:	7c c7                	jl     8001fc <umain+0x16>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	5b                   	pop    %ebx
  800239:	5e                   	pop    %esi
  80023a:	5d                   	pop    %ebp
  80023b:	c3                   	ret    

0080023c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80023c:	55                   	push   %ebp
  80023d:	89 e5                	mov    %esp,%ebp
  80023f:	56                   	push   %esi
  800240:	53                   	push   %ebx
  800241:	83 ec 10             	sub    $0x10,%esp
  800244:	8b 75 08             	mov    0x8(%ebp),%esi
  800247:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80024a:	e8 a0 0a 00 00       	call   800cef <sys_getenvid>
  80024f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800254:	c1 e0 07             	shl    $0x7,%eax
  800257:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80025c:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800261:	85 f6                	test   %esi,%esi
  800263:	7e 07                	jle    80026c <libmain+0x30>
		binaryname = argv[0];
  800265:	8b 03                	mov    (%ebx),%eax
  800267:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80026c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800270:	89 34 24             	mov    %esi,(%esp)
  800273:	e8 6e ff ff ff       	call   8001e6 <umain>

	// exit gracefully
	exit();
  800278:	e8 07 00 00 00       	call   800284 <exit>
}
  80027d:	83 c4 10             	add    $0x10,%esp
  800280:	5b                   	pop    %ebx
  800281:	5e                   	pop    %esi
  800282:	5d                   	pop    %ebp
  800283:	c3                   	ret    

00800284 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  800287:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  80028a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800291:	e8 07 0a 00 00       	call   800c9d <sys_env_destroy>
}
  800296:	c9                   	leave  
  800297:	c3                   	ret    

00800298 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	56                   	push   %esi
  80029c:	53                   	push   %ebx
  80029d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8002a0:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002a3:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8002a9:	e8 41 0a 00 00       	call   800cef <sys_getenvid>
  8002ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002bc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c4:	c7 04 24 18 13 80 00 	movl   $0x801318,(%esp)
  8002cb:	e8 c0 00 00 00       	call   800390 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002d0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8002d7:	89 04 24             	mov    %eax,(%esp)
  8002da:	e8 50 00 00 00       	call   80032f <vcprintf>
	cprintf("\n");
  8002df:	c7 04 24 0b 13 80 00 	movl   $0x80130b,(%esp)
  8002e6:	e8 a5 00 00 00       	call   800390 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002eb:	cc                   	int3   
  8002ec:	eb fd                	jmp    8002eb <_panic+0x53>
	...

008002f0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	53                   	push   %ebx
  8002f4:	83 ec 14             	sub    $0x14,%esp
  8002f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002fa:	8b 03                	mov    (%ebx),%eax
  8002fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ff:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800303:	40                   	inc    %eax
  800304:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800306:	3d ff 00 00 00       	cmp    $0xff,%eax
  80030b:	75 19                	jne    800326 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80030d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800314:	00 
  800315:	8d 43 08             	lea    0x8(%ebx),%eax
  800318:	89 04 24             	mov    %eax,(%esp)
  80031b:	e8 40 09 00 00       	call   800c60 <sys_cputs>
		b->idx = 0;
  800320:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800326:	ff 43 04             	incl   0x4(%ebx)
}
  800329:	83 c4 14             	add    $0x14,%esp
  80032c:	5b                   	pop    %ebx
  80032d:	5d                   	pop    %ebp
  80032e:	c3                   	ret    

0080032f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80032f:	55                   	push   %ebp
  800330:	89 e5                	mov    %esp,%ebp
  800332:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800338:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80033f:	00 00 00 
	b.cnt = 0;
  800342:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800349:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80034c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80034f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800353:	8b 45 08             	mov    0x8(%ebp),%eax
  800356:	89 44 24 08          	mov    %eax,0x8(%esp)
  80035a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800360:	89 44 24 04          	mov    %eax,0x4(%esp)
  800364:	c7 04 24 f0 02 80 00 	movl   $0x8002f0,(%esp)
  80036b:	e8 82 01 00 00       	call   8004f2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800370:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800376:	89 44 24 04          	mov    %eax,0x4(%esp)
  80037a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800380:	89 04 24             	mov    %eax,(%esp)
  800383:	e8 d8 08 00 00       	call   800c60 <sys_cputs>

	return b.cnt;
}
  800388:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80038e:	c9                   	leave  
  80038f:	c3                   	ret    

00800390 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800390:	55                   	push   %ebp
  800391:	89 e5                	mov    %esp,%ebp
  800393:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800396:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800399:	89 44 24 04          	mov    %eax,0x4(%esp)
  80039d:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a0:	89 04 24             	mov    %eax,(%esp)
  8003a3:	e8 87 ff ff ff       	call   80032f <vcprintf>
	va_end(ap);

	return cnt;
}
  8003a8:	c9                   	leave  
  8003a9:	c3                   	ret    
	...

008003ac <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003ac:	55                   	push   %ebp
  8003ad:	89 e5                	mov    %esp,%ebp
  8003af:	57                   	push   %edi
  8003b0:	56                   	push   %esi
  8003b1:	53                   	push   %ebx
  8003b2:	83 ec 3c             	sub    $0x3c,%esp
  8003b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003b8:	89 d7                	mov    %edx,%edi
  8003ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8003bd:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8003c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003c6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003c9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003cc:	85 c0                	test   %eax,%eax
  8003ce:	75 08                	jne    8003d8 <printnum+0x2c>
  8003d0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003d3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003d6:	77 57                	ja     80042f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003d8:	89 74 24 10          	mov    %esi,0x10(%esp)
  8003dc:	4b                   	dec    %ebx
  8003dd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003e1:	8b 45 10             	mov    0x10(%ebp),%eax
  8003e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003e8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8003ec:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8003f0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003f7:	00 
  8003f8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003fb:	89 04 24             	mov    %eax,(%esp)
  8003fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800401:	89 44 24 04          	mov    %eax,0x4(%esp)
  800405:	e8 0e 0c 00 00       	call   801018 <__udivdi3>
  80040a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80040e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800412:	89 04 24             	mov    %eax,(%esp)
  800415:	89 54 24 04          	mov    %edx,0x4(%esp)
  800419:	89 fa                	mov    %edi,%edx
  80041b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80041e:	e8 89 ff ff ff       	call   8003ac <printnum>
  800423:	eb 0f                	jmp    800434 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800425:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800429:	89 34 24             	mov    %esi,(%esp)
  80042c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80042f:	4b                   	dec    %ebx
  800430:	85 db                	test   %ebx,%ebx
  800432:	7f f1                	jg     800425 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800434:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800438:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80043c:	8b 45 10             	mov    0x10(%ebp),%eax
  80043f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800443:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80044a:	00 
  80044b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80044e:	89 04 24             	mov    %eax,(%esp)
  800451:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800454:	89 44 24 04          	mov    %eax,0x4(%esp)
  800458:	e8 db 0c 00 00       	call   801138 <__umoddi3>
  80045d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800461:	0f be 80 3b 13 80 00 	movsbl 0x80133b(%eax),%eax
  800468:	89 04 24             	mov    %eax,(%esp)
  80046b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80046e:	83 c4 3c             	add    $0x3c,%esp
  800471:	5b                   	pop    %ebx
  800472:	5e                   	pop    %esi
  800473:	5f                   	pop    %edi
  800474:	5d                   	pop    %ebp
  800475:	c3                   	ret    

00800476 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800476:	55                   	push   %ebp
  800477:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800479:	83 fa 01             	cmp    $0x1,%edx
  80047c:	7e 0e                	jle    80048c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80047e:	8b 10                	mov    (%eax),%edx
  800480:	8d 4a 08             	lea    0x8(%edx),%ecx
  800483:	89 08                	mov    %ecx,(%eax)
  800485:	8b 02                	mov    (%edx),%eax
  800487:	8b 52 04             	mov    0x4(%edx),%edx
  80048a:	eb 22                	jmp    8004ae <getuint+0x38>
	else if (lflag)
  80048c:	85 d2                	test   %edx,%edx
  80048e:	74 10                	je     8004a0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800490:	8b 10                	mov    (%eax),%edx
  800492:	8d 4a 04             	lea    0x4(%edx),%ecx
  800495:	89 08                	mov    %ecx,(%eax)
  800497:	8b 02                	mov    (%edx),%eax
  800499:	ba 00 00 00 00       	mov    $0x0,%edx
  80049e:	eb 0e                	jmp    8004ae <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004a0:	8b 10                	mov    (%eax),%edx
  8004a2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004a5:	89 08                	mov    %ecx,(%eax)
  8004a7:	8b 02                	mov    (%edx),%eax
  8004a9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004ae:	5d                   	pop    %ebp
  8004af:	c3                   	ret    

008004b0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004b0:	55                   	push   %ebp
  8004b1:	89 e5                	mov    %esp,%ebp
  8004b3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004b6:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8004b9:	8b 10                	mov    (%eax),%edx
  8004bb:	3b 50 04             	cmp    0x4(%eax),%edx
  8004be:	73 08                	jae    8004c8 <sprintputch+0x18>
		*b->buf++ = ch;
  8004c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004c3:	88 0a                	mov    %cl,(%edx)
  8004c5:	42                   	inc    %edx
  8004c6:	89 10                	mov    %edx,(%eax)
}
  8004c8:	5d                   	pop    %ebp
  8004c9:	c3                   	ret    

008004ca <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004ca:	55                   	push   %ebp
  8004cb:	89 e5                	mov    %esp,%ebp
  8004cd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8004d0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004d7:	8b 45 10             	mov    0x10(%ebp),%eax
  8004da:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e8:	89 04 24             	mov    %eax,(%esp)
  8004eb:	e8 02 00 00 00       	call   8004f2 <vprintfmt>
	va_end(ap);
}
  8004f0:	c9                   	leave  
  8004f1:	c3                   	ret    

008004f2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004f2:	55                   	push   %ebp
  8004f3:	89 e5                	mov    %esp,%ebp
  8004f5:	57                   	push   %edi
  8004f6:	56                   	push   %esi
  8004f7:	53                   	push   %ebx
  8004f8:	83 ec 4c             	sub    $0x4c,%esp
  8004fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004fe:	8b 75 10             	mov    0x10(%ebp),%esi
  800501:	eb 12                	jmp    800515 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800503:	85 c0                	test   %eax,%eax
  800505:	0f 84 6b 03 00 00    	je     800876 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80050b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80050f:	89 04 24             	mov    %eax,(%esp)
  800512:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800515:	0f b6 06             	movzbl (%esi),%eax
  800518:	46                   	inc    %esi
  800519:	83 f8 25             	cmp    $0x25,%eax
  80051c:	75 e5                	jne    800503 <vprintfmt+0x11>
  80051e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800522:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800529:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80052e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800535:	b9 00 00 00 00       	mov    $0x0,%ecx
  80053a:	eb 26                	jmp    800562 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80053f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800543:	eb 1d                	jmp    800562 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800545:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800548:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80054c:	eb 14                	jmp    800562 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800551:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800558:	eb 08                	jmp    800562 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80055a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80055d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800562:	0f b6 06             	movzbl (%esi),%eax
  800565:	8d 56 01             	lea    0x1(%esi),%edx
  800568:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80056b:	8a 16                	mov    (%esi),%dl
  80056d:	83 ea 23             	sub    $0x23,%edx
  800570:	80 fa 55             	cmp    $0x55,%dl
  800573:	0f 87 e1 02 00 00    	ja     80085a <vprintfmt+0x368>
  800579:	0f b6 d2             	movzbl %dl,%edx
  80057c:	ff 24 95 80 14 80 00 	jmp    *0x801480(,%edx,4)
  800583:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800586:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80058b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80058e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800592:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800595:	8d 50 d0             	lea    -0x30(%eax),%edx
  800598:	83 fa 09             	cmp    $0x9,%edx
  80059b:	77 2a                	ja     8005c7 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80059d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80059e:	eb eb                	jmp    80058b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a3:	8d 50 04             	lea    0x4(%eax),%edx
  8005a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a9:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ab:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005ae:	eb 17                	jmp    8005c7 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8005b0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005b4:	78 98                	js     80054e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b6:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005b9:	eb a7                	jmp    800562 <vprintfmt+0x70>
  8005bb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005be:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8005c5:	eb 9b                	jmp    800562 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8005c7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005cb:	79 95                	jns    800562 <vprintfmt+0x70>
  8005cd:	eb 8b                	jmp    80055a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005cf:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005d3:	eb 8d                	jmp    800562 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d8:	8d 50 04             	lea    0x4(%eax),%edx
  8005db:	89 55 14             	mov    %edx,0x14(%ebp)
  8005de:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005e2:	8b 00                	mov    (%eax),%eax
  8005e4:	89 04 24             	mov    %eax,(%esp)
  8005e7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ea:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005ed:	e9 23 ff ff ff       	jmp    800515 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f5:	8d 50 04             	lea    0x4(%eax),%edx
  8005f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fb:	8b 00                	mov    (%eax),%eax
  8005fd:	85 c0                	test   %eax,%eax
  8005ff:	79 02                	jns    800603 <vprintfmt+0x111>
  800601:	f7 d8                	neg    %eax
  800603:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800605:	83 f8 11             	cmp    $0x11,%eax
  800608:	7f 0b                	jg     800615 <vprintfmt+0x123>
  80060a:	8b 04 85 e0 15 80 00 	mov    0x8015e0(,%eax,4),%eax
  800611:	85 c0                	test   %eax,%eax
  800613:	75 23                	jne    800638 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800615:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800619:	c7 44 24 08 53 13 80 	movl   $0x801353,0x8(%esp)
  800620:	00 
  800621:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800625:	8b 45 08             	mov    0x8(%ebp),%eax
  800628:	89 04 24             	mov    %eax,(%esp)
  80062b:	e8 9a fe ff ff       	call   8004ca <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800630:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800633:	e9 dd fe ff ff       	jmp    800515 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800638:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80063c:	c7 44 24 08 5c 13 80 	movl   $0x80135c,0x8(%esp)
  800643:	00 
  800644:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800648:	8b 55 08             	mov    0x8(%ebp),%edx
  80064b:	89 14 24             	mov    %edx,(%esp)
  80064e:	e8 77 fe ff ff       	call   8004ca <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800653:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800656:	e9 ba fe ff ff       	jmp    800515 <vprintfmt+0x23>
  80065b:	89 f9                	mov    %edi,%ecx
  80065d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800660:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800663:	8b 45 14             	mov    0x14(%ebp),%eax
  800666:	8d 50 04             	lea    0x4(%eax),%edx
  800669:	89 55 14             	mov    %edx,0x14(%ebp)
  80066c:	8b 30                	mov    (%eax),%esi
  80066e:	85 f6                	test   %esi,%esi
  800670:	75 05                	jne    800677 <vprintfmt+0x185>
				p = "(null)";
  800672:	be 4c 13 80 00       	mov    $0x80134c,%esi
			if (width > 0 && padc != '-')
  800677:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80067b:	0f 8e 84 00 00 00    	jle    800705 <vprintfmt+0x213>
  800681:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800685:	74 7e                	je     800705 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800687:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80068b:	89 34 24             	mov    %esi,(%esp)
  80068e:	e8 8b 02 00 00       	call   80091e <strnlen>
  800693:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800696:	29 c2                	sub    %eax,%edx
  800698:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80069b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80069f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8006a2:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8006a5:	89 de                	mov    %ebx,%esi
  8006a7:	89 d3                	mov    %edx,%ebx
  8006a9:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ab:	eb 0b                	jmp    8006b8 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8006ad:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006b1:	89 3c 24             	mov    %edi,(%esp)
  8006b4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b7:	4b                   	dec    %ebx
  8006b8:	85 db                	test   %ebx,%ebx
  8006ba:	7f f1                	jg     8006ad <vprintfmt+0x1bb>
  8006bc:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8006bf:	89 f3                	mov    %esi,%ebx
  8006c1:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8006c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006c7:	85 c0                	test   %eax,%eax
  8006c9:	79 05                	jns    8006d0 <vprintfmt+0x1de>
  8006cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8006d0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006d3:	29 c2                	sub    %eax,%edx
  8006d5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8006d8:	eb 2b                	jmp    800705 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006da:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006de:	74 18                	je     8006f8 <vprintfmt+0x206>
  8006e0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8006e3:	83 fa 5e             	cmp    $0x5e,%edx
  8006e6:	76 10                	jbe    8006f8 <vprintfmt+0x206>
					putch('?', putdat);
  8006e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ec:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8006f3:	ff 55 08             	call   *0x8(%ebp)
  8006f6:	eb 0a                	jmp    800702 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8006f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006fc:	89 04 24             	mov    %eax,(%esp)
  8006ff:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800702:	ff 4d e4             	decl   -0x1c(%ebp)
  800705:	0f be 06             	movsbl (%esi),%eax
  800708:	46                   	inc    %esi
  800709:	85 c0                	test   %eax,%eax
  80070b:	74 21                	je     80072e <vprintfmt+0x23c>
  80070d:	85 ff                	test   %edi,%edi
  80070f:	78 c9                	js     8006da <vprintfmt+0x1e8>
  800711:	4f                   	dec    %edi
  800712:	79 c6                	jns    8006da <vprintfmt+0x1e8>
  800714:	8b 7d 08             	mov    0x8(%ebp),%edi
  800717:	89 de                	mov    %ebx,%esi
  800719:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80071c:	eb 18                	jmp    800736 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80071e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800722:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800729:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80072b:	4b                   	dec    %ebx
  80072c:	eb 08                	jmp    800736 <vprintfmt+0x244>
  80072e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800731:	89 de                	mov    %ebx,%esi
  800733:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800736:	85 db                	test   %ebx,%ebx
  800738:	7f e4                	jg     80071e <vprintfmt+0x22c>
  80073a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80073d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80073f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800742:	e9 ce fd ff ff       	jmp    800515 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800747:	83 f9 01             	cmp    $0x1,%ecx
  80074a:	7e 10                	jle    80075c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80074c:	8b 45 14             	mov    0x14(%ebp),%eax
  80074f:	8d 50 08             	lea    0x8(%eax),%edx
  800752:	89 55 14             	mov    %edx,0x14(%ebp)
  800755:	8b 30                	mov    (%eax),%esi
  800757:	8b 78 04             	mov    0x4(%eax),%edi
  80075a:	eb 26                	jmp    800782 <vprintfmt+0x290>
	else if (lflag)
  80075c:	85 c9                	test   %ecx,%ecx
  80075e:	74 12                	je     800772 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800760:	8b 45 14             	mov    0x14(%ebp),%eax
  800763:	8d 50 04             	lea    0x4(%eax),%edx
  800766:	89 55 14             	mov    %edx,0x14(%ebp)
  800769:	8b 30                	mov    (%eax),%esi
  80076b:	89 f7                	mov    %esi,%edi
  80076d:	c1 ff 1f             	sar    $0x1f,%edi
  800770:	eb 10                	jmp    800782 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800772:	8b 45 14             	mov    0x14(%ebp),%eax
  800775:	8d 50 04             	lea    0x4(%eax),%edx
  800778:	89 55 14             	mov    %edx,0x14(%ebp)
  80077b:	8b 30                	mov    (%eax),%esi
  80077d:	89 f7                	mov    %esi,%edi
  80077f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800782:	85 ff                	test   %edi,%edi
  800784:	78 0a                	js     800790 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800786:	b8 0a 00 00 00       	mov    $0xa,%eax
  80078b:	e9 8c 00 00 00       	jmp    80081c <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800790:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800794:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80079b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80079e:	f7 de                	neg    %esi
  8007a0:	83 d7 00             	adc    $0x0,%edi
  8007a3:	f7 df                	neg    %edi
			}
			base = 10;
  8007a5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007aa:	eb 70                	jmp    80081c <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007ac:	89 ca                	mov    %ecx,%edx
  8007ae:	8d 45 14             	lea    0x14(%ebp),%eax
  8007b1:	e8 c0 fc ff ff       	call   800476 <getuint>
  8007b6:	89 c6                	mov    %eax,%esi
  8007b8:	89 d7                	mov    %edx,%edi
			base = 10;
  8007ba:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8007bf:	eb 5b                	jmp    80081c <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  8007c1:	89 ca                	mov    %ecx,%edx
  8007c3:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c6:	e8 ab fc ff ff       	call   800476 <getuint>
  8007cb:	89 c6                	mov    %eax,%esi
  8007cd:	89 d7                	mov    %edx,%edi
			base = 8;
  8007cf:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8007d4:	eb 46                	jmp    80081c <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  8007d6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007da:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007e1:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007e4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e8:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007ef:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f5:	8d 50 04             	lea    0x4(%eax),%edx
  8007f8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007fb:	8b 30                	mov    (%eax),%esi
  8007fd:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800802:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800807:	eb 13                	jmp    80081c <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800809:	89 ca                	mov    %ecx,%edx
  80080b:	8d 45 14             	lea    0x14(%ebp),%eax
  80080e:	e8 63 fc ff ff       	call   800476 <getuint>
  800813:	89 c6                	mov    %eax,%esi
  800815:	89 d7                	mov    %edx,%edi
			base = 16;
  800817:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80081c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800820:	89 54 24 10          	mov    %edx,0x10(%esp)
  800824:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800827:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80082b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80082f:	89 34 24             	mov    %esi,(%esp)
  800832:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800836:	89 da                	mov    %ebx,%edx
  800838:	8b 45 08             	mov    0x8(%ebp),%eax
  80083b:	e8 6c fb ff ff       	call   8003ac <printnum>
			break;
  800840:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800843:	e9 cd fc ff ff       	jmp    800515 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800848:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80084c:	89 04 24             	mov    %eax,(%esp)
  80084f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800852:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800855:	e9 bb fc ff ff       	jmp    800515 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80085a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80085e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800865:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800868:	eb 01                	jmp    80086b <vprintfmt+0x379>
  80086a:	4e                   	dec    %esi
  80086b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80086f:	75 f9                	jne    80086a <vprintfmt+0x378>
  800871:	e9 9f fc ff ff       	jmp    800515 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800876:	83 c4 4c             	add    $0x4c,%esp
  800879:	5b                   	pop    %ebx
  80087a:	5e                   	pop    %esi
  80087b:	5f                   	pop    %edi
  80087c:	5d                   	pop    %ebp
  80087d:	c3                   	ret    

0080087e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80087e:	55                   	push   %ebp
  80087f:	89 e5                	mov    %esp,%ebp
  800881:	83 ec 28             	sub    $0x28,%esp
  800884:	8b 45 08             	mov    0x8(%ebp),%eax
  800887:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80088a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80088d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800891:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800894:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80089b:	85 c0                	test   %eax,%eax
  80089d:	74 30                	je     8008cf <vsnprintf+0x51>
  80089f:	85 d2                	test   %edx,%edx
  8008a1:	7e 33                	jle    8008d6 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8008ad:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008b1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b8:	c7 04 24 b0 04 80 00 	movl   $0x8004b0,(%esp)
  8008bf:	e8 2e fc ff ff       	call   8004f2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008c7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008cd:	eb 0c                	jmp    8008db <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008d4:	eb 05                	jmp    8008db <vsnprintf+0x5d>
  8008d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008db:	c9                   	leave  
  8008dc:	c3                   	ret    

008008dd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008dd:	55                   	push   %ebp
  8008de:	89 e5                	mov    %esp,%ebp
  8008e0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008e3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008e6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8008ed:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fb:	89 04 24             	mov    %eax,(%esp)
  8008fe:	e8 7b ff ff ff       	call   80087e <vsnprintf>
	va_end(ap);

	return rc;
}
  800903:	c9                   	leave  
  800904:	c3                   	ret    
  800905:	00 00                	add    %al,(%eax)
	...

00800908 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800908:	55                   	push   %ebp
  800909:	89 e5                	mov    %esp,%ebp
  80090b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80090e:	b8 00 00 00 00       	mov    $0x0,%eax
  800913:	eb 01                	jmp    800916 <strlen+0xe>
		n++;
  800915:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800916:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80091a:	75 f9                	jne    800915 <strlen+0xd>
		n++;
	return n;
}
  80091c:	5d                   	pop    %ebp
  80091d:	c3                   	ret    

0080091e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800924:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800927:	b8 00 00 00 00       	mov    $0x0,%eax
  80092c:	eb 01                	jmp    80092f <strnlen+0x11>
		n++;
  80092e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80092f:	39 d0                	cmp    %edx,%eax
  800931:	74 06                	je     800939 <strnlen+0x1b>
  800933:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800937:	75 f5                	jne    80092e <strnlen+0x10>
		n++;
	return n;
}
  800939:	5d                   	pop    %ebp
  80093a:	c3                   	ret    

0080093b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80093b:	55                   	push   %ebp
  80093c:	89 e5                	mov    %esp,%ebp
  80093e:	53                   	push   %ebx
  80093f:	8b 45 08             	mov    0x8(%ebp),%eax
  800942:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800945:	ba 00 00 00 00       	mov    $0x0,%edx
  80094a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80094d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800950:	42                   	inc    %edx
  800951:	84 c9                	test   %cl,%cl
  800953:	75 f5                	jne    80094a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800955:	5b                   	pop    %ebx
  800956:	5d                   	pop    %ebp
  800957:	c3                   	ret    

00800958 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	53                   	push   %ebx
  80095c:	83 ec 08             	sub    $0x8,%esp
  80095f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800962:	89 1c 24             	mov    %ebx,(%esp)
  800965:	e8 9e ff ff ff       	call   800908 <strlen>
	strcpy(dst + len, src);
  80096a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800971:	01 d8                	add    %ebx,%eax
  800973:	89 04 24             	mov    %eax,(%esp)
  800976:	e8 c0 ff ff ff       	call   80093b <strcpy>
	return dst;
}
  80097b:	89 d8                	mov    %ebx,%eax
  80097d:	83 c4 08             	add    $0x8,%esp
  800980:	5b                   	pop    %ebx
  800981:	5d                   	pop    %ebp
  800982:	c3                   	ret    

00800983 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800983:	55                   	push   %ebp
  800984:	89 e5                	mov    %esp,%ebp
  800986:	56                   	push   %esi
  800987:	53                   	push   %ebx
  800988:	8b 45 08             	mov    0x8(%ebp),%eax
  80098b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800991:	b9 00 00 00 00       	mov    $0x0,%ecx
  800996:	eb 0c                	jmp    8009a4 <strncpy+0x21>
		*dst++ = *src;
  800998:	8a 1a                	mov    (%edx),%bl
  80099a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80099d:	80 3a 01             	cmpb   $0x1,(%edx)
  8009a0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009a3:	41                   	inc    %ecx
  8009a4:	39 f1                	cmp    %esi,%ecx
  8009a6:	75 f0                	jne    800998 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009a8:	5b                   	pop    %ebx
  8009a9:	5e                   	pop    %esi
  8009aa:	5d                   	pop    %ebp
  8009ab:	c3                   	ret    

008009ac <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009ac:	55                   	push   %ebp
  8009ad:	89 e5                	mov    %esp,%ebp
  8009af:	56                   	push   %esi
  8009b0:	53                   	push   %ebx
  8009b1:	8b 75 08             	mov    0x8(%ebp),%esi
  8009b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009b7:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009ba:	85 d2                	test   %edx,%edx
  8009bc:	75 0a                	jne    8009c8 <strlcpy+0x1c>
  8009be:	89 f0                	mov    %esi,%eax
  8009c0:	eb 1a                	jmp    8009dc <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009c2:	88 18                	mov    %bl,(%eax)
  8009c4:	40                   	inc    %eax
  8009c5:	41                   	inc    %ecx
  8009c6:	eb 02                	jmp    8009ca <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009c8:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8009ca:	4a                   	dec    %edx
  8009cb:	74 0a                	je     8009d7 <strlcpy+0x2b>
  8009cd:	8a 19                	mov    (%ecx),%bl
  8009cf:	84 db                	test   %bl,%bl
  8009d1:	75 ef                	jne    8009c2 <strlcpy+0x16>
  8009d3:	89 c2                	mov    %eax,%edx
  8009d5:	eb 02                	jmp    8009d9 <strlcpy+0x2d>
  8009d7:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8009d9:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8009dc:	29 f0                	sub    %esi,%eax
}
  8009de:	5b                   	pop    %ebx
  8009df:	5e                   	pop    %esi
  8009e0:	5d                   	pop    %ebp
  8009e1:	c3                   	ret    

008009e2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009e2:	55                   	push   %ebp
  8009e3:	89 e5                	mov    %esp,%ebp
  8009e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009e8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009eb:	eb 02                	jmp    8009ef <strcmp+0xd>
		p++, q++;
  8009ed:	41                   	inc    %ecx
  8009ee:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009ef:	8a 01                	mov    (%ecx),%al
  8009f1:	84 c0                	test   %al,%al
  8009f3:	74 04                	je     8009f9 <strcmp+0x17>
  8009f5:	3a 02                	cmp    (%edx),%al
  8009f7:	74 f4                	je     8009ed <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009f9:	0f b6 c0             	movzbl %al,%eax
  8009fc:	0f b6 12             	movzbl (%edx),%edx
  8009ff:	29 d0                	sub    %edx,%eax
}
  800a01:	5d                   	pop    %ebp
  800a02:	c3                   	ret    

00800a03 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a03:	55                   	push   %ebp
  800a04:	89 e5                	mov    %esp,%ebp
  800a06:	53                   	push   %ebx
  800a07:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a0d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800a10:	eb 03                	jmp    800a15 <strncmp+0x12>
		n--, p++, q++;
  800a12:	4a                   	dec    %edx
  800a13:	40                   	inc    %eax
  800a14:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a15:	85 d2                	test   %edx,%edx
  800a17:	74 14                	je     800a2d <strncmp+0x2a>
  800a19:	8a 18                	mov    (%eax),%bl
  800a1b:	84 db                	test   %bl,%bl
  800a1d:	74 04                	je     800a23 <strncmp+0x20>
  800a1f:	3a 19                	cmp    (%ecx),%bl
  800a21:	74 ef                	je     800a12 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a23:	0f b6 00             	movzbl (%eax),%eax
  800a26:	0f b6 11             	movzbl (%ecx),%edx
  800a29:	29 d0                	sub    %edx,%eax
  800a2b:	eb 05                	jmp    800a32 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a2d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a32:	5b                   	pop    %ebx
  800a33:	5d                   	pop    %ebp
  800a34:	c3                   	ret    

00800a35 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a35:	55                   	push   %ebp
  800a36:	89 e5                	mov    %esp,%ebp
  800a38:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a3e:	eb 05                	jmp    800a45 <strchr+0x10>
		if (*s == c)
  800a40:	38 ca                	cmp    %cl,%dl
  800a42:	74 0c                	je     800a50 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a44:	40                   	inc    %eax
  800a45:	8a 10                	mov    (%eax),%dl
  800a47:	84 d2                	test   %dl,%dl
  800a49:	75 f5                	jne    800a40 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800a4b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a50:	5d                   	pop    %ebp
  800a51:	c3                   	ret    

00800a52 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a52:	55                   	push   %ebp
  800a53:	89 e5                	mov    %esp,%ebp
  800a55:	8b 45 08             	mov    0x8(%ebp),%eax
  800a58:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a5b:	eb 05                	jmp    800a62 <strfind+0x10>
		if (*s == c)
  800a5d:	38 ca                	cmp    %cl,%dl
  800a5f:	74 07                	je     800a68 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a61:	40                   	inc    %eax
  800a62:	8a 10                	mov    (%eax),%dl
  800a64:	84 d2                	test   %dl,%dl
  800a66:	75 f5                	jne    800a5d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800a68:	5d                   	pop    %ebp
  800a69:	c3                   	ret    

00800a6a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a6a:	55                   	push   %ebp
  800a6b:	89 e5                	mov    %esp,%ebp
  800a6d:	57                   	push   %edi
  800a6e:	56                   	push   %esi
  800a6f:	53                   	push   %ebx
  800a70:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a73:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a76:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a79:	85 c9                	test   %ecx,%ecx
  800a7b:	74 30                	je     800aad <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a7d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a83:	75 25                	jne    800aaa <memset+0x40>
  800a85:	f6 c1 03             	test   $0x3,%cl
  800a88:	75 20                	jne    800aaa <memset+0x40>
		c &= 0xFF;
  800a8a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a8d:	89 d3                	mov    %edx,%ebx
  800a8f:	c1 e3 08             	shl    $0x8,%ebx
  800a92:	89 d6                	mov    %edx,%esi
  800a94:	c1 e6 18             	shl    $0x18,%esi
  800a97:	89 d0                	mov    %edx,%eax
  800a99:	c1 e0 10             	shl    $0x10,%eax
  800a9c:	09 f0                	or     %esi,%eax
  800a9e:	09 d0                	or     %edx,%eax
  800aa0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800aa2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800aa5:	fc                   	cld    
  800aa6:	f3 ab                	rep stos %eax,%es:(%edi)
  800aa8:	eb 03                	jmp    800aad <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800aaa:	fc                   	cld    
  800aab:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800aad:	89 f8                	mov    %edi,%eax
  800aaf:	5b                   	pop    %ebx
  800ab0:	5e                   	pop    %esi
  800ab1:	5f                   	pop    %edi
  800ab2:	5d                   	pop    %ebp
  800ab3:	c3                   	ret    

00800ab4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ab4:	55                   	push   %ebp
  800ab5:	89 e5                	mov    %esp,%ebp
  800ab7:	57                   	push   %edi
  800ab8:	56                   	push   %esi
  800ab9:	8b 45 08             	mov    0x8(%ebp),%eax
  800abc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800abf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ac2:	39 c6                	cmp    %eax,%esi
  800ac4:	73 34                	jae    800afa <memmove+0x46>
  800ac6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ac9:	39 d0                	cmp    %edx,%eax
  800acb:	73 2d                	jae    800afa <memmove+0x46>
		s += n;
		d += n;
  800acd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad0:	f6 c2 03             	test   $0x3,%dl
  800ad3:	75 1b                	jne    800af0 <memmove+0x3c>
  800ad5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800adb:	75 13                	jne    800af0 <memmove+0x3c>
  800add:	f6 c1 03             	test   $0x3,%cl
  800ae0:	75 0e                	jne    800af0 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ae2:	83 ef 04             	sub    $0x4,%edi
  800ae5:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ae8:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800aeb:	fd                   	std    
  800aec:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aee:	eb 07                	jmp    800af7 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800af0:	4f                   	dec    %edi
  800af1:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800af4:	fd                   	std    
  800af5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800af7:	fc                   	cld    
  800af8:	eb 20                	jmp    800b1a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800afa:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b00:	75 13                	jne    800b15 <memmove+0x61>
  800b02:	a8 03                	test   $0x3,%al
  800b04:	75 0f                	jne    800b15 <memmove+0x61>
  800b06:	f6 c1 03             	test   $0x3,%cl
  800b09:	75 0a                	jne    800b15 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b0b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b0e:	89 c7                	mov    %eax,%edi
  800b10:	fc                   	cld    
  800b11:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b13:	eb 05                	jmp    800b1a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b15:	89 c7                	mov    %eax,%edi
  800b17:	fc                   	cld    
  800b18:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b1a:	5e                   	pop    %esi
  800b1b:	5f                   	pop    %edi
  800b1c:	5d                   	pop    %ebp
  800b1d:	c3                   	ret    

00800b1e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b1e:	55                   	push   %ebp
  800b1f:	89 e5                	mov    %esp,%ebp
  800b21:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b24:	8b 45 10             	mov    0x10(%ebp),%eax
  800b27:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b32:	8b 45 08             	mov    0x8(%ebp),%eax
  800b35:	89 04 24             	mov    %eax,(%esp)
  800b38:	e8 77 ff ff ff       	call   800ab4 <memmove>
}
  800b3d:	c9                   	leave  
  800b3e:	c3                   	ret    

00800b3f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b3f:	55                   	push   %ebp
  800b40:	89 e5                	mov    %esp,%ebp
  800b42:	57                   	push   %edi
  800b43:	56                   	push   %esi
  800b44:	53                   	push   %ebx
  800b45:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b48:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b4e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b53:	eb 16                	jmp    800b6b <memcmp+0x2c>
		if (*s1 != *s2)
  800b55:	8a 04 17             	mov    (%edi,%edx,1),%al
  800b58:	42                   	inc    %edx
  800b59:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800b5d:	38 c8                	cmp    %cl,%al
  800b5f:	74 0a                	je     800b6b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800b61:	0f b6 c0             	movzbl %al,%eax
  800b64:	0f b6 c9             	movzbl %cl,%ecx
  800b67:	29 c8                	sub    %ecx,%eax
  800b69:	eb 09                	jmp    800b74 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b6b:	39 da                	cmp    %ebx,%edx
  800b6d:	75 e6                	jne    800b55 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b6f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b74:	5b                   	pop    %ebx
  800b75:	5e                   	pop    %esi
  800b76:	5f                   	pop    %edi
  800b77:	5d                   	pop    %ebp
  800b78:	c3                   	ret    

00800b79 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b79:	55                   	push   %ebp
  800b7a:	89 e5                	mov    %esp,%ebp
  800b7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b82:	89 c2                	mov    %eax,%edx
  800b84:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b87:	eb 05                	jmp    800b8e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b89:	38 08                	cmp    %cl,(%eax)
  800b8b:	74 05                	je     800b92 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b8d:	40                   	inc    %eax
  800b8e:	39 d0                	cmp    %edx,%eax
  800b90:	72 f7                	jb     800b89 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b92:	5d                   	pop    %ebp
  800b93:	c3                   	ret    

00800b94 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b94:	55                   	push   %ebp
  800b95:	89 e5                	mov    %esp,%ebp
  800b97:	57                   	push   %edi
  800b98:	56                   	push   %esi
  800b99:	53                   	push   %ebx
  800b9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ba0:	eb 01                	jmp    800ba3 <strtol+0xf>
		s++;
  800ba2:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ba3:	8a 02                	mov    (%edx),%al
  800ba5:	3c 20                	cmp    $0x20,%al
  800ba7:	74 f9                	je     800ba2 <strtol+0xe>
  800ba9:	3c 09                	cmp    $0x9,%al
  800bab:	74 f5                	je     800ba2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bad:	3c 2b                	cmp    $0x2b,%al
  800baf:	75 08                	jne    800bb9 <strtol+0x25>
		s++;
  800bb1:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bb2:	bf 00 00 00 00       	mov    $0x0,%edi
  800bb7:	eb 13                	jmp    800bcc <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bb9:	3c 2d                	cmp    $0x2d,%al
  800bbb:	75 0a                	jne    800bc7 <strtol+0x33>
		s++, neg = 1;
  800bbd:	8d 52 01             	lea    0x1(%edx),%edx
  800bc0:	bf 01 00 00 00       	mov    $0x1,%edi
  800bc5:	eb 05                	jmp    800bcc <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bc7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bcc:	85 db                	test   %ebx,%ebx
  800bce:	74 05                	je     800bd5 <strtol+0x41>
  800bd0:	83 fb 10             	cmp    $0x10,%ebx
  800bd3:	75 28                	jne    800bfd <strtol+0x69>
  800bd5:	8a 02                	mov    (%edx),%al
  800bd7:	3c 30                	cmp    $0x30,%al
  800bd9:	75 10                	jne    800beb <strtol+0x57>
  800bdb:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bdf:	75 0a                	jne    800beb <strtol+0x57>
		s += 2, base = 16;
  800be1:	83 c2 02             	add    $0x2,%edx
  800be4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800be9:	eb 12                	jmp    800bfd <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800beb:	85 db                	test   %ebx,%ebx
  800bed:	75 0e                	jne    800bfd <strtol+0x69>
  800bef:	3c 30                	cmp    $0x30,%al
  800bf1:	75 05                	jne    800bf8 <strtol+0x64>
		s++, base = 8;
  800bf3:	42                   	inc    %edx
  800bf4:	b3 08                	mov    $0x8,%bl
  800bf6:	eb 05                	jmp    800bfd <strtol+0x69>
	else if (base == 0)
		base = 10;
  800bf8:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800bfd:	b8 00 00 00 00       	mov    $0x0,%eax
  800c02:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c04:	8a 0a                	mov    (%edx),%cl
  800c06:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c09:	80 fb 09             	cmp    $0x9,%bl
  800c0c:	77 08                	ja     800c16 <strtol+0x82>
			dig = *s - '0';
  800c0e:	0f be c9             	movsbl %cl,%ecx
  800c11:	83 e9 30             	sub    $0x30,%ecx
  800c14:	eb 1e                	jmp    800c34 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800c16:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c19:	80 fb 19             	cmp    $0x19,%bl
  800c1c:	77 08                	ja     800c26 <strtol+0x92>
			dig = *s - 'a' + 10;
  800c1e:	0f be c9             	movsbl %cl,%ecx
  800c21:	83 e9 57             	sub    $0x57,%ecx
  800c24:	eb 0e                	jmp    800c34 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800c26:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c29:	80 fb 19             	cmp    $0x19,%bl
  800c2c:	77 12                	ja     800c40 <strtol+0xac>
			dig = *s - 'A' + 10;
  800c2e:	0f be c9             	movsbl %cl,%ecx
  800c31:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c34:	39 f1                	cmp    %esi,%ecx
  800c36:	7d 0c                	jge    800c44 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800c38:	42                   	inc    %edx
  800c39:	0f af c6             	imul   %esi,%eax
  800c3c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800c3e:	eb c4                	jmp    800c04 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c40:	89 c1                	mov    %eax,%ecx
  800c42:	eb 02                	jmp    800c46 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c44:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c46:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c4a:	74 05                	je     800c51 <strtol+0xbd>
		*endptr = (char *) s;
  800c4c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c4f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c51:	85 ff                	test   %edi,%edi
  800c53:	74 04                	je     800c59 <strtol+0xc5>
  800c55:	89 c8                	mov    %ecx,%eax
  800c57:	f7 d8                	neg    %eax
}
  800c59:	5b                   	pop    %ebx
  800c5a:	5e                   	pop    %esi
  800c5b:	5f                   	pop    %edi
  800c5c:	5d                   	pop    %ebp
  800c5d:	c3                   	ret    
	...

00800c60 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	57                   	push   %edi
  800c64:	56                   	push   %esi
  800c65:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c66:	b8 00 00 00 00       	mov    $0x0,%eax
  800c6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c71:	89 c3                	mov    %eax,%ebx
  800c73:	89 c7                	mov    %eax,%edi
  800c75:	89 c6                	mov    %eax,%esi
  800c77:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c79:	5b                   	pop    %ebx
  800c7a:	5e                   	pop    %esi
  800c7b:	5f                   	pop    %edi
  800c7c:	5d                   	pop    %ebp
  800c7d:	c3                   	ret    

00800c7e <sys_cgetc>:

int
sys_cgetc(void)
{
  800c7e:	55                   	push   %ebp
  800c7f:	89 e5                	mov    %esp,%ebp
  800c81:	57                   	push   %edi
  800c82:	56                   	push   %esi
  800c83:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c84:	ba 00 00 00 00       	mov    $0x0,%edx
  800c89:	b8 01 00 00 00       	mov    $0x1,%eax
  800c8e:	89 d1                	mov    %edx,%ecx
  800c90:	89 d3                	mov    %edx,%ebx
  800c92:	89 d7                	mov    %edx,%edi
  800c94:	89 d6                	mov    %edx,%esi
  800c96:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c98:	5b                   	pop    %ebx
  800c99:	5e                   	pop    %esi
  800c9a:	5f                   	pop    %edi
  800c9b:	5d                   	pop    %ebp
  800c9c:	c3                   	ret    

00800c9d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c9d:	55                   	push   %ebp
  800c9e:	89 e5                	mov    %esp,%ebp
  800ca0:	57                   	push   %edi
  800ca1:	56                   	push   %esi
  800ca2:	53                   	push   %ebx
  800ca3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cab:	b8 03 00 00 00       	mov    $0x3,%eax
  800cb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb3:	89 cb                	mov    %ecx,%ebx
  800cb5:	89 cf                	mov    %ecx,%edi
  800cb7:	89 ce                	mov    %ecx,%esi
  800cb9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cbb:	85 c0                	test   %eax,%eax
  800cbd:	7e 28                	jle    800ce7 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cc3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800cca:	00 
  800ccb:	c7 44 24 08 48 16 80 	movl   $0x801648,0x8(%esp)
  800cd2:	00 
  800cd3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cda:	00 
  800cdb:	c7 04 24 65 16 80 00 	movl   $0x801665,(%esp)
  800ce2:	e8 b1 f5 ff ff       	call   800298 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ce7:	83 c4 2c             	add    $0x2c,%esp
  800cea:	5b                   	pop    %ebx
  800ceb:	5e                   	pop    %esi
  800cec:	5f                   	pop    %edi
  800ced:	5d                   	pop    %ebp
  800cee:	c3                   	ret    

00800cef <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cef:	55                   	push   %ebp
  800cf0:	89 e5                	mov    %esp,%ebp
  800cf2:	57                   	push   %edi
  800cf3:	56                   	push   %esi
  800cf4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf5:	ba 00 00 00 00       	mov    $0x0,%edx
  800cfa:	b8 02 00 00 00       	mov    $0x2,%eax
  800cff:	89 d1                	mov    %edx,%ecx
  800d01:	89 d3                	mov    %edx,%ebx
  800d03:	89 d7                	mov    %edx,%edi
  800d05:	89 d6                	mov    %edx,%esi
  800d07:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d09:	5b                   	pop    %ebx
  800d0a:	5e                   	pop    %esi
  800d0b:	5f                   	pop    %edi
  800d0c:	5d                   	pop    %ebp
  800d0d:	c3                   	ret    

00800d0e <sys_yield>:

void
sys_yield(void)
{
  800d0e:	55                   	push   %ebp
  800d0f:	89 e5                	mov    %esp,%ebp
  800d11:	57                   	push   %edi
  800d12:	56                   	push   %esi
  800d13:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d14:	ba 00 00 00 00       	mov    $0x0,%edx
  800d19:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d1e:	89 d1                	mov    %edx,%ecx
  800d20:	89 d3                	mov    %edx,%ebx
  800d22:	89 d7                	mov    %edx,%edi
  800d24:	89 d6                	mov    %edx,%esi
  800d26:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d28:	5b                   	pop    %ebx
  800d29:	5e                   	pop    %esi
  800d2a:	5f                   	pop    %edi
  800d2b:	5d                   	pop    %ebp
  800d2c:	c3                   	ret    

00800d2d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d2d:	55                   	push   %ebp
  800d2e:	89 e5                	mov    %esp,%ebp
  800d30:	57                   	push   %edi
  800d31:	56                   	push   %esi
  800d32:	53                   	push   %ebx
  800d33:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d36:	be 00 00 00 00       	mov    $0x0,%esi
  800d3b:	b8 04 00 00 00       	mov    $0x4,%eax
  800d40:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d46:	8b 55 08             	mov    0x8(%ebp),%edx
  800d49:	89 f7                	mov    %esi,%edi
  800d4b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d4d:	85 c0                	test   %eax,%eax
  800d4f:	7e 28                	jle    800d79 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d51:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d55:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d5c:	00 
  800d5d:	c7 44 24 08 48 16 80 	movl   $0x801648,0x8(%esp)
  800d64:	00 
  800d65:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d6c:	00 
  800d6d:	c7 04 24 65 16 80 00 	movl   $0x801665,(%esp)
  800d74:	e8 1f f5 ff ff       	call   800298 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d79:	83 c4 2c             	add    $0x2c,%esp
  800d7c:	5b                   	pop    %ebx
  800d7d:	5e                   	pop    %esi
  800d7e:	5f                   	pop    %edi
  800d7f:	5d                   	pop    %ebp
  800d80:	c3                   	ret    

00800d81 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d81:	55                   	push   %ebp
  800d82:	89 e5                	mov    %esp,%ebp
  800d84:	57                   	push   %edi
  800d85:	56                   	push   %esi
  800d86:	53                   	push   %ebx
  800d87:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8a:	b8 05 00 00 00       	mov    $0x5,%eax
  800d8f:	8b 75 18             	mov    0x18(%ebp),%esi
  800d92:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d95:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800da0:	85 c0                	test   %eax,%eax
  800da2:	7e 28                	jle    800dcc <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800da8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800daf:	00 
  800db0:	c7 44 24 08 48 16 80 	movl   $0x801648,0x8(%esp)
  800db7:	00 
  800db8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dbf:	00 
  800dc0:	c7 04 24 65 16 80 00 	movl   $0x801665,(%esp)
  800dc7:	e8 cc f4 ff ff       	call   800298 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800dcc:	83 c4 2c             	add    $0x2c,%esp
  800dcf:	5b                   	pop    %ebx
  800dd0:	5e                   	pop    %esi
  800dd1:	5f                   	pop    %edi
  800dd2:	5d                   	pop    %ebp
  800dd3:	c3                   	ret    

00800dd4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dd4:	55                   	push   %ebp
  800dd5:	89 e5                	mov    %esp,%ebp
  800dd7:	57                   	push   %edi
  800dd8:	56                   	push   %esi
  800dd9:	53                   	push   %ebx
  800dda:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ddd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800de2:	b8 06 00 00 00       	mov    $0x6,%eax
  800de7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dea:	8b 55 08             	mov    0x8(%ebp),%edx
  800ded:	89 df                	mov    %ebx,%edi
  800def:	89 de                	mov    %ebx,%esi
  800df1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800df3:	85 c0                	test   %eax,%eax
  800df5:	7e 28                	jle    800e1f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dfb:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e02:	00 
  800e03:	c7 44 24 08 48 16 80 	movl   $0x801648,0x8(%esp)
  800e0a:	00 
  800e0b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e12:	00 
  800e13:	c7 04 24 65 16 80 00 	movl   $0x801665,(%esp)
  800e1a:	e8 79 f4 ff ff       	call   800298 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e1f:	83 c4 2c             	add    $0x2c,%esp
  800e22:	5b                   	pop    %ebx
  800e23:	5e                   	pop    %esi
  800e24:	5f                   	pop    %edi
  800e25:	5d                   	pop    %ebp
  800e26:	c3                   	ret    

00800e27 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e27:	55                   	push   %ebp
  800e28:	89 e5                	mov    %esp,%ebp
  800e2a:	57                   	push   %edi
  800e2b:	56                   	push   %esi
  800e2c:	53                   	push   %ebx
  800e2d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e30:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e35:	b8 08 00 00 00       	mov    $0x8,%eax
  800e3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e40:	89 df                	mov    %ebx,%edi
  800e42:	89 de                	mov    %ebx,%esi
  800e44:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e46:	85 c0                	test   %eax,%eax
  800e48:	7e 28                	jle    800e72 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e4a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e4e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e55:	00 
  800e56:	c7 44 24 08 48 16 80 	movl   $0x801648,0x8(%esp)
  800e5d:	00 
  800e5e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e65:	00 
  800e66:	c7 04 24 65 16 80 00 	movl   $0x801665,(%esp)
  800e6d:	e8 26 f4 ff ff       	call   800298 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e72:	83 c4 2c             	add    $0x2c,%esp
  800e75:	5b                   	pop    %ebx
  800e76:	5e                   	pop    %esi
  800e77:	5f                   	pop    %edi
  800e78:	5d                   	pop    %ebp
  800e79:	c3                   	ret    

00800e7a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e7a:	55                   	push   %ebp
  800e7b:	89 e5                	mov    %esp,%ebp
  800e7d:	57                   	push   %edi
  800e7e:	56                   	push   %esi
  800e7f:	53                   	push   %ebx
  800e80:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e83:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e88:	b8 09 00 00 00       	mov    $0x9,%eax
  800e8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e90:	8b 55 08             	mov    0x8(%ebp),%edx
  800e93:	89 df                	mov    %ebx,%edi
  800e95:	89 de                	mov    %ebx,%esi
  800e97:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e99:	85 c0                	test   %eax,%eax
  800e9b:	7e 28                	jle    800ec5 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e9d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ea1:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ea8:	00 
  800ea9:	c7 44 24 08 48 16 80 	movl   $0x801648,0x8(%esp)
  800eb0:	00 
  800eb1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eb8:	00 
  800eb9:	c7 04 24 65 16 80 00 	movl   $0x801665,(%esp)
  800ec0:	e8 d3 f3 ff ff       	call   800298 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ec5:	83 c4 2c             	add    $0x2c,%esp
  800ec8:	5b                   	pop    %ebx
  800ec9:	5e                   	pop    %esi
  800eca:	5f                   	pop    %edi
  800ecb:	5d                   	pop    %ebp
  800ecc:	c3                   	ret    

00800ecd <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ecd:	55                   	push   %ebp
  800ece:	89 e5                	mov    %esp,%ebp
  800ed0:	57                   	push   %edi
  800ed1:	56                   	push   %esi
  800ed2:	53                   	push   %ebx
  800ed3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800edb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ee0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee6:	89 df                	mov    %ebx,%edi
  800ee8:	89 de                	mov    %ebx,%esi
  800eea:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eec:	85 c0                	test   %eax,%eax
  800eee:	7e 28                	jle    800f18 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ef0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ef4:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800efb:	00 
  800efc:	c7 44 24 08 48 16 80 	movl   $0x801648,0x8(%esp)
  800f03:	00 
  800f04:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f0b:	00 
  800f0c:	c7 04 24 65 16 80 00 	movl   $0x801665,(%esp)
  800f13:	e8 80 f3 ff ff       	call   800298 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f18:	83 c4 2c             	add    $0x2c,%esp
  800f1b:	5b                   	pop    %ebx
  800f1c:	5e                   	pop    %esi
  800f1d:	5f                   	pop    %edi
  800f1e:	5d                   	pop    %ebp
  800f1f:	c3                   	ret    

00800f20 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f20:	55                   	push   %ebp
  800f21:	89 e5                	mov    %esp,%ebp
  800f23:	57                   	push   %edi
  800f24:	56                   	push   %esi
  800f25:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f26:	be 00 00 00 00       	mov    $0x0,%esi
  800f2b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f30:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f33:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f39:	8b 55 08             	mov    0x8(%ebp),%edx
  800f3c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f3e:	5b                   	pop    %ebx
  800f3f:	5e                   	pop    %esi
  800f40:	5f                   	pop    %edi
  800f41:	5d                   	pop    %ebp
  800f42:	c3                   	ret    

00800f43 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f43:	55                   	push   %ebp
  800f44:	89 e5                	mov    %esp,%ebp
  800f46:	57                   	push   %edi
  800f47:	56                   	push   %esi
  800f48:	53                   	push   %ebx
  800f49:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f4c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f51:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f56:	8b 55 08             	mov    0x8(%ebp),%edx
  800f59:	89 cb                	mov    %ecx,%ebx
  800f5b:	89 cf                	mov    %ecx,%edi
  800f5d:	89 ce                	mov    %ecx,%esi
  800f5f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f61:	85 c0                	test   %eax,%eax
  800f63:	7e 28                	jle    800f8d <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f65:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f69:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f70:	00 
  800f71:	c7 44 24 08 48 16 80 	movl   $0x801648,0x8(%esp)
  800f78:	00 
  800f79:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f80:	00 
  800f81:	c7 04 24 65 16 80 00 	movl   $0x801665,(%esp)
  800f88:	e8 0b f3 ff ff       	call   800298 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f8d:	83 c4 2c             	add    $0x2c,%esp
  800f90:	5b                   	pop    %ebx
  800f91:	5e                   	pop    %esi
  800f92:	5f                   	pop    %edi
  800f93:	5d                   	pop    %ebp
  800f94:	c3                   	ret    

00800f95 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800f95:	55                   	push   %ebp
  800f96:	89 e5                	mov    %esp,%ebp
  800f98:	57                   	push   %edi
  800f99:	56                   	push   %esi
  800f9a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f9b:	ba 00 00 00 00       	mov    $0x0,%edx
  800fa0:	b8 0e 00 00 00       	mov    $0xe,%eax
  800fa5:	89 d1                	mov    %edx,%ecx
  800fa7:	89 d3                	mov    %edx,%ebx
  800fa9:	89 d7                	mov    %edx,%edi
  800fab:	89 d6                	mov    %edx,%esi
  800fad:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800faf:	5b                   	pop    %ebx
  800fb0:	5e                   	pop    %esi
  800fb1:	5f                   	pop    %edi
  800fb2:	5d                   	pop    %ebp
  800fb3:	c3                   	ret    

00800fb4 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char* pck, size_t length){
  800fb4:	55                   	push   %ebp
  800fb5:	89 e5                	mov    %esp,%ebp
  800fb7:	57                   	push   %edi
  800fb8:	56                   	push   %esi
  800fb9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fba:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fbf:	b8 10 00 00 00       	mov    $0x10,%eax
  800fc4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc7:	8b 55 08             	mov    0x8(%ebp),%edx
  800fca:	89 df                	mov    %ebx,%edi
  800fcc:	89 de                	mov    %ebx,%esi
  800fce:	cd 30                	int    $0x30
}

int 
sys_e1000_transmit(char* pck, size_t length){
	return syscall(SYS_e1000_transmit, 0, (uint32_t)pck, length, 0, 0, 0);
}
  800fd0:	5b                   	pop    %ebx
  800fd1:	5e                   	pop    %esi
  800fd2:	5f                   	pop    %edi
  800fd3:	5d                   	pop    %ebp
  800fd4:	c3                   	ret    

00800fd5 <sys_e1000_receive>:

int 
sys_e1000_receive(char* pck, size_t* length){
  800fd5:	55                   	push   %ebp
  800fd6:	89 e5                	mov    %esp,%ebp
  800fd8:	57                   	push   %edi
  800fd9:	56                   	push   %esi
  800fda:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fdb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fe0:	b8 0f 00 00 00       	mov    $0xf,%eax
  800fe5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe8:	8b 55 08             	mov    0x8(%ebp),%edx
  800feb:	89 df                	mov    %ebx,%edi
  800fed:	89 de                	mov    %ebx,%esi
  800fef:	cd 30                	int    $0x30
}

int 
sys_e1000_receive(char* pck, size_t* length){
	return syscall(SYS_e1000_receive, 0, (uint32_t)pck, (uint32_t)length, 0, 0, 0);
}
  800ff1:	5b                   	pop    %ebx
  800ff2:	5e                   	pop    %esi
  800ff3:	5f                   	pop    %edi
  800ff4:	5d                   	pop    %ebp
  800ff5:	c3                   	ret    

00800ff6 <sys_e1000_get_mac>:

int 
sys_e1000_get_mac(uint8_t* mac_addr){
  800ff6:	55                   	push   %ebp
  800ff7:	89 e5                	mov    %esp,%ebp
  800ff9:	57                   	push   %edi
  800ffa:	56                   	push   %esi
  800ffb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ffc:	b9 00 00 00 00       	mov    $0x0,%ecx
  801001:	b8 11 00 00 00       	mov    $0x11,%eax
  801006:	8b 55 08             	mov    0x8(%ebp),%edx
  801009:	89 cb                	mov    %ecx,%ebx
  80100b:	89 cf                	mov    %ecx,%edi
  80100d:	89 ce                	mov    %ecx,%esi
  80100f:	cd 30                	int    $0x30
}

int 
sys_e1000_get_mac(uint8_t* mac_addr){
	return syscall(SYS_e1000_get_mac, 0, (uint32_t)mac_addr, 0, 0, 0, 0);
}
  801011:	5b                   	pop    %ebx
  801012:	5e                   	pop    %esi
  801013:	5f                   	pop    %edi
  801014:	5d                   	pop    %ebp
  801015:	c3                   	ret    
	...

00801018 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801018:	55                   	push   %ebp
  801019:	57                   	push   %edi
  80101a:	56                   	push   %esi
  80101b:	83 ec 10             	sub    $0x10,%esp
  80101e:	8b 74 24 20          	mov    0x20(%esp),%esi
  801022:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801026:	89 74 24 04          	mov    %esi,0x4(%esp)
  80102a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  80102e:	89 cd                	mov    %ecx,%ebp
  801030:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801034:	85 c0                	test   %eax,%eax
  801036:	75 2c                	jne    801064 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801038:	39 f9                	cmp    %edi,%ecx
  80103a:	77 68                	ja     8010a4 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80103c:	85 c9                	test   %ecx,%ecx
  80103e:	75 0b                	jne    80104b <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801040:	b8 01 00 00 00       	mov    $0x1,%eax
  801045:	31 d2                	xor    %edx,%edx
  801047:	f7 f1                	div    %ecx
  801049:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80104b:	31 d2                	xor    %edx,%edx
  80104d:	89 f8                	mov    %edi,%eax
  80104f:	f7 f1                	div    %ecx
  801051:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801053:	89 f0                	mov    %esi,%eax
  801055:	f7 f1                	div    %ecx
  801057:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801059:	89 f0                	mov    %esi,%eax
  80105b:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80105d:	83 c4 10             	add    $0x10,%esp
  801060:	5e                   	pop    %esi
  801061:	5f                   	pop    %edi
  801062:	5d                   	pop    %ebp
  801063:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801064:	39 f8                	cmp    %edi,%eax
  801066:	77 2c                	ja     801094 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801068:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  80106b:	83 f6 1f             	xor    $0x1f,%esi
  80106e:	75 4c                	jne    8010bc <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801070:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801072:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801077:	72 0a                	jb     801083 <__udivdi3+0x6b>
  801079:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  80107d:	0f 87 ad 00 00 00    	ja     801130 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801083:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801088:	89 f0                	mov    %esi,%eax
  80108a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80108c:	83 c4 10             	add    $0x10,%esp
  80108f:	5e                   	pop    %esi
  801090:	5f                   	pop    %edi
  801091:	5d                   	pop    %ebp
  801092:	c3                   	ret    
  801093:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801094:	31 ff                	xor    %edi,%edi
  801096:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801098:	89 f0                	mov    %esi,%eax
  80109a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80109c:	83 c4 10             	add    $0x10,%esp
  80109f:	5e                   	pop    %esi
  8010a0:	5f                   	pop    %edi
  8010a1:	5d                   	pop    %ebp
  8010a2:	c3                   	ret    
  8010a3:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8010a4:	89 fa                	mov    %edi,%edx
  8010a6:	89 f0                	mov    %esi,%eax
  8010a8:	f7 f1                	div    %ecx
  8010aa:	89 c6                	mov    %eax,%esi
  8010ac:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8010ae:	89 f0                	mov    %esi,%eax
  8010b0:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8010b2:	83 c4 10             	add    $0x10,%esp
  8010b5:	5e                   	pop    %esi
  8010b6:	5f                   	pop    %edi
  8010b7:	5d                   	pop    %ebp
  8010b8:	c3                   	ret    
  8010b9:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8010bc:	89 f1                	mov    %esi,%ecx
  8010be:	d3 e0                	shl    %cl,%eax
  8010c0:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8010c4:	b8 20 00 00 00       	mov    $0x20,%eax
  8010c9:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8010cb:	89 ea                	mov    %ebp,%edx
  8010cd:	88 c1                	mov    %al,%cl
  8010cf:	d3 ea                	shr    %cl,%edx
  8010d1:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8010d5:	09 ca                	or     %ecx,%edx
  8010d7:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  8010db:	89 f1                	mov    %esi,%ecx
  8010dd:	d3 e5                	shl    %cl,%ebp
  8010df:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  8010e3:	89 fd                	mov    %edi,%ebp
  8010e5:	88 c1                	mov    %al,%cl
  8010e7:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  8010e9:	89 fa                	mov    %edi,%edx
  8010eb:	89 f1                	mov    %esi,%ecx
  8010ed:	d3 e2                	shl    %cl,%edx
  8010ef:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8010f3:	88 c1                	mov    %al,%cl
  8010f5:	d3 ef                	shr    %cl,%edi
  8010f7:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8010f9:	89 f8                	mov    %edi,%eax
  8010fb:	89 ea                	mov    %ebp,%edx
  8010fd:	f7 74 24 08          	divl   0x8(%esp)
  801101:	89 d1                	mov    %edx,%ecx
  801103:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  801105:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801109:	39 d1                	cmp    %edx,%ecx
  80110b:	72 17                	jb     801124 <__udivdi3+0x10c>
  80110d:	74 09                	je     801118 <__udivdi3+0x100>
  80110f:	89 fe                	mov    %edi,%esi
  801111:	31 ff                	xor    %edi,%edi
  801113:	e9 41 ff ff ff       	jmp    801059 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801118:	8b 54 24 04          	mov    0x4(%esp),%edx
  80111c:	89 f1                	mov    %esi,%ecx
  80111e:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801120:	39 c2                	cmp    %eax,%edx
  801122:	73 eb                	jae    80110f <__udivdi3+0xf7>
		{
		  q0--;
  801124:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801127:	31 ff                	xor    %edi,%edi
  801129:	e9 2b ff ff ff       	jmp    801059 <__udivdi3+0x41>
  80112e:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801130:	31 f6                	xor    %esi,%esi
  801132:	e9 22 ff ff ff       	jmp    801059 <__udivdi3+0x41>
	...

00801138 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801138:	55                   	push   %ebp
  801139:	57                   	push   %edi
  80113a:	56                   	push   %esi
  80113b:	83 ec 20             	sub    $0x20,%esp
  80113e:	8b 44 24 30          	mov    0x30(%esp),%eax
  801142:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801146:	89 44 24 14          	mov    %eax,0x14(%esp)
  80114a:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  80114e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801152:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801156:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  801158:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80115a:	85 ed                	test   %ebp,%ebp
  80115c:	75 16                	jne    801174 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  80115e:	39 f1                	cmp    %esi,%ecx
  801160:	0f 86 a6 00 00 00    	jbe    80120c <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801166:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801168:	89 d0                	mov    %edx,%eax
  80116a:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80116c:	83 c4 20             	add    $0x20,%esp
  80116f:	5e                   	pop    %esi
  801170:	5f                   	pop    %edi
  801171:	5d                   	pop    %ebp
  801172:	c3                   	ret    
  801173:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801174:	39 f5                	cmp    %esi,%ebp
  801176:	0f 87 ac 00 00 00    	ja     801228 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80117c:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  80117f:	83 f0 1f             	xor    $0x1f,%eax
  801182:	89 44 24 10          	mov    %eax,0x10(%esp)
  801186:	0f 84 a8 00 00 00    	je     801234 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80118c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801190:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801192:	bf 20 00 00 00       	mov    $0x20,%edi
  801197:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80119b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80119f:	89 f9                	mov    %edi,%ecx
  8011a1:	d3 e8                	shr    %cl,%eax
  8011a3:	09 e8                	or     %ebp,%eax
  8011a5:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  8011a9:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8011ad:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8011b1:	d3 e0                	shl    %cl,%eax
  8011b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8011b7:	89 f2                	mov    %esi,%edx
  8011b9:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8011bb:	8b 44 24 14          	mov    0x14(%esp),%eax
  8011bf:	d3 e0                	shl    %cl,%eax
  8011c1:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8011c5:	8b 44 24 14          	mov    0x14(%esp),%eax
  8011c9:	89 f9                	mov    %edi,%ecx
  8011cb:	d3 e8                	shr    %cl,%eax
  8011cd:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8011cf:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8011d1:	89 f2                	mov    %esi,%edx
  8011d3:	f7 74 24 18          	divl   0x18(%esp)
  8011d7:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8011d9:	f7 64 24 0c          	mull   0xc(%esp)
  8011dd:	89 c5                	mov    %eax,%ebp
  8011df:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8011e1:	39 d6                	cmp    %edx,%esi
  8011e3:	72 67                	jb     80124c <__umoddi3+0x114>
  8011e5:	74 75                	je     80125c <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8011e7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8011eb:	29 e8                	sub    %ebp,%eax
  8011ed:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8011ef:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8011f3:	d3 e8                	shr    %cl,%eax
  8011f5:	89 f2                	mov    %esi,%edx
  8011f7:	89 f9                	mov    %edi,%ecx
  8011f9:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8011fb:	09 d0                	or     %edx,%eax
  8011fd:	89 f2                	mov    %esi,%edx
  8011ff:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801203:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801205:	83 c4 20             	add    $0x20,%esp
  801208:	5e                   	pop    %esi
  801209:	5f                   	pop    %edi
  80120a:	5d                   	pop    %ebp
  80120b:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80120c:	85 c9                	test   %ecx,%ecx
  80120e:	75 0b                	jne    80121b <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801210:	b8 01 00 00 00       	mov    $0x1,%eax
  801215:	31 d2                	xor    %edx,%edx
  801217:	f7 f1                	div    %ecx
  801219:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80121b:	89 f0                	mov    %esi,%eax
  80121d:	31 d2                	xor    %edx,%edx
  80121f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801221:	89 f8                	mov    %edi,%eax
  801223:	e9 3e ff ff ff       	jmp    801166 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801228:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80122a:	83 c4 20             	add    $0x20,%esp
  80122d:	5e                   	pop    %esi
  80122e:	5f                   	pop    %edi
  80122f:	5d                   	pop    %ebp
  801230:	c3                   	ret    
  801231:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801234:	39 f5                	cmp    %esi,%ebp
  801236:	72 04                	jb     80123c <__umoddi3+0x104>
  801238:	39 f9                	cmp    %edi,%ecx
  80123a:	77 06                	ja     801242 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80123c:	89 f2                	mov    %esi,%edx
  80123e:	29 cf                	sub    %ecx,%edi
  801240:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801242:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801244:	83 c4 20             	add    $0x20,%esp
  801247:	5e                   	pop    %esi
  801248:	5f                   	pop    %edi
  801249:	5d                   	pop    %ebp
  80124a:	c3                   	ret    
  80124b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80124c:	89 d1                	mov    %edx,%ecx
  80124e:	89 c5                	mov    %eax,%ebp
  801250:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801254:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801258:	eb 8d                	jmp    8011e7 <__umoddi3+0xaf>
  80125a:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80125c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801260:	72 ea                	jb     80124c <__umoddi3+0x114>
  801262:	89 f1                	mov    %esi,%ecx
  801264:	eb 81                	jmp    8011e7 <__umoddi3+0xaf>
