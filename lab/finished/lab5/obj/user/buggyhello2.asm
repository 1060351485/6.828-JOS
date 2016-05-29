
obj/user/buggyhello2.debug:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_cputs(hello, 1024*1024);
  80003a:	c7 44 24 04 00 00 10 	movl   $0x100000,0x4(%esp)
  800041:	00 
  800042:	a1 00 20 80 00       	mov    0x802000,%eax
  800047:	89 04 24             	mov    %eax,(%esp)
  80004a:	e8 6d 00 00 00       	call   8000bc <sys_cputs>
}
  80004f:	c9                   	leave  
  800050:	c3                   	ret    
  800051:	00 00                	add    %al,(%eax)
	...

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	56                   	push   %esi
  800058:	53                   	push   %ebx
  800059:	83 ec 10             	sub    $0x10,%esp
  80005c:	8b 75 08             	mov    0x8(%ebp),%esi
  80005f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800062:	e8 e4 00 00 00       	call   80014b <sys_getenvid>
  800067:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800073:	c1 e0 07             	shl    $0x7,%eax
  800076:	29 d0                	sub    %edx,%eax
  800078:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007d:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800082:	85 f6                	test   %esi,%esi
  800084:	7e 07                	jle    80008d <libmain+0x39>
		binaryname = argv[0];
  800086:	8b 03                	mov    (%ebx),%eax
  800088:	a3 04 20 80 00       	mov    %eax,0x802004

	// call user main routine
	umain(argc, argv);
  80008d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800091:	89 34 24             	mov    %esi,(%esp)
  800094:	e8 9b ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800099:	e8 0a 00 00 00       	call   8000a8 <exit>
}
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	5b                   	pop    %ebx
  8000a2:	5e                   	pop    %esi
  8000a3:	5d                   	pop    %ebp
  8000a4:	c3                   	ret    
  8000a5:	00 00                	add    %al,(%eax)
	...

008000a8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  8000ae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b5:	e8 3f 00 00 00       	call   8000f9 <sys_env_destroy>
}
  8000ba:	c9                   	leave  
  8000bb:	c3                   	ret    

008000bc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	57                   	push   %edi
  8000c0:	56                   	push   %esi
  8000c1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8000cd:	89 c3                	mov    %eax,%ebx
  8000cf:	89 c7                	mov    %eax,%edi
  8000d1:	89 c6                	mov    %eax,%esi
  8000d3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d5:	5b                   	pop    %ebx
  8000d6:	5e                   	pop    %esi
  8000d7:	5f                   	pop    %edi
  8000d8:	5d                   	pop    %ebp
  8000d9:	c3                   	ret    

008000da <sys_cgetc>:

int
sys_cgetc(void)
{
  8000da:	55                   	push   %ebp
  8000db:	89 e5                	mov    %esp,%ebp
  8000dd:	57                   	push   %edi
  8000de:	56                   	push   %esi
  8000df:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e5:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ea:	89 d1                	mov    %edx,%ecx
  8000ec:	89 d3                	mov    %edx,%ebx
  8000ee:	89 d7                	mov    %edx,%edi
  8000f0:	89 d6                	mov    %edx,%esi
  8000f2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f4:	5b                   	pop    %ebx
  8000f5:	5e                   	pop    %esi
  8000f6:	5f                   	pop    %edi
  8000f7:	5d                   	pop    %ebp
  8000f8:	c3                   	ret    

008000f9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f9:	55                   	push   %ebp
  8000fa:	89 e5                	mov    %esp,%ebp
  8000fc:	57                   	push   %edi
  8000fd:	56                   	push   %esi
  8000fe:	53                   	push   %ebx
  8000ff:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800102:	b9 00 00 00 00       	mov    $0x0,%ecx
  800107:	b8 03 00 00 00       	mov    $0x3,%eax
  80010c:	8b 55 08             	mov    0x8(%ebp),%edx
  80010f:	89 cb                	mov    %ecx,%ebx
  800111:	89 cf                	mov    %ecx,%edi
  800113:	89 ce                	mov    %ecx,%esi
  800115:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800117:	85 c0                	test   %eax,%eax
  800119:	7e 28                	jle    800143 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80011b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80011f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800126:	00 
  800127:	c7 44 24 08 38 10 80 	movl   $0x801038,0x8(%esp)
  80012e:	00 
  80012f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800136:	00 
  800137:	c7 04 24 55 10 80 00 	movl   $0x801055,(%esp)
  80013e:	e8 b1 02 00 00       	call   8003f4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800143:	83 c4 2c             	add    $0x2c,%esp
  800146:	5b                   	pop    %ebx
  800147:	5e                   	pop    %esi
  800148:	5f                   	pop    %edi
  800149:	5d                   	pop    %ebp
  80014a:	c3                   	ret    

0080014b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	57                   	push   %edi
  80014f:	56                   	push   %esi
  800150:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800151:	ba 00 00 00 00       	mov    $0x0,%edx
  800156:	b8 02 00 00 00       	mov    $0x2,%eax
  80015b:	89 d1                	mov    %edx,%ecx
  80015d:	89 d3                	mov    %edx,%ebx
  80015f:	89 d7                	mov    %edx,%edi
  800161:	89 d6                	mov    %edx,%esi
  800163:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800165:	5b                   	pop    %ebx
  800166:	5e                   	pop    %esi
  800167:	5f                   	pop    %edi
  800168:	5d                   	pop    %ebp
  800169:	c3                   	ret    

0080016a <sys_yield>:

void
sys_yield(void)
{
  80016a:	55                   	push   %ebp
  80016b:	89 e5                	mov    %esp,%ebp
  80016d:	57                   	push   %edi
  80016e:	56                   	push   %esi
  80016f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800170:	ba 00 00 00 00       	mov    $0x0,%edx
  800175:	b8 0b 00 00 00       	mov    $0xb,%eax
  80017a:	89 d1                	mov    %edx,%ecx
  80017c:	89 d3                	mov    %edx,%ebx
  80017e:	89 d7                	mov    %edx,%edi
  800180:	89 d6                	mov    %edx,%esi
  800182:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800184:	5b                   	pop    %ebx
  800185:	5e                   	pop    %esi
  800186:	5f                   	pop    %edi
  800187:	5d                   	pop    %ebp
  800188:	c3                   	ret    

00800189 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800189:	55                   	push   %ebp
  80018a:	89 e5                	mov    %esp,%ebp
  80018c:	57                   	push   %edi
  80018d:	56                   	push   %esi
  80018e:	53                   	push   %ebx
  80018f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800192:	be 00 00 00 00       	mov    $0x0,%esi
  800197:	b8 04 00 00 00       	mov    $0x4,%eax
  80019c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80019f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a5:	89 f7                	mov    %esi,%edi
  8001a7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001a9:	85 c0                	test   %eax,%eax
  8001ab:	7e 28                	jle    8001d5 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ad:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001b1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001b8:	00 
  8001b9:	c7 44 24 08 38 10 80 	movl   $0x801038,0x8(%esp)
  8001c0:	00 
  8001c1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001c8:	00 
  8001c9:	c7 04 24 55 10 80 00 	movl   $0x801055,(%esp)
  8001d0:	e8 1f 02 00 00       	call   8003f4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001d5:	83 c4 2c             	add    $0x2c,%esp
  8001d8:	5b                   	pop    %ebx
  8001d9:	5e                   	pop    %esi
  8001da:	5f                   	pop    %edi
  8001db:	5d                   	pop    %ebp
  8001dc:	c3                   	ret    

008001dd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001dd:	55                   	push   %ebp
  8001de:	89 e5                	mov    %esp,%ebp
  8001e0:	57                   	push   %edi
  8001e1:	56                   	push   %esi
  8001e2:	53                   	push   %ebx
  8001e3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001eb:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ee:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001f1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fa:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001fc:	85 c0                	test   %eax,%eax
  8001fe:	7e 28                	jle    800228 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800200:	89 44 24 10          	mov    %eax,0x10(%esp)
  800204:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80020b:	00 
  80020c:	c7 44 24 08 38 10 80 	movl   $0x801038,0x8(%esp)
  800213:	00 
  800214:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80021b:	00 
  80021c:	c7 04 24 55 10 80 00 	movl   $0x801055,(%esp)
  800223:	e8 cc 01 00 00       	call   8003f4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800228:	83 c4 2c             	add    $0x2c,%esp
  80022b:	5b                   	pop    %ebx
  80022c:	5e                   	pop    %esi
  80022d:	5f                   	pop    %edi
  80022e:	5d                   	pop    %ebp
  80022f:	c3                   	ret    

00800230 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	57                   	push   %edi
  800234:	56                   	push   %esi
  800235:	53                   	push   %ebx
  800236:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800239:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023e:	b8 06 00 00 00       	mov    $0x6,%eax
  800243:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800246:	8b 55 08             	mov    0x8(%ebp),%edx
  800249:	89 df                	mov    %ebx,%edi
  80024b:	89 de                	mov    %ebx,%esi
  80024d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80024f:	85 c0                	test   %eax,%eax
  800251:	7e 28                	jle    80027b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800253:	89 44 24 10          	mov    %eax,0x10(%esp)
  800257:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80025e:	00 
  80025f:	c7 44 24 08 38 10 80 	movl   $0x801038,0x8(%esp)
  800266:	00 
  800267:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80026e:	00 
  80026f:	c7 04 24 55 10 80 00 	movl   $0x801055,(%esp)
  800276:	e8 79 01 00 00       	call   8003f4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80027b:	83 c4 2c             	add    $0x2c,%esp
  80027e:	5b                   	pop    %ebx
  80027f:	5e                   	pop    %esi
  800280:	5f                   	pop    %edi
  800281:	5d                   	pop    %ebp
  800282:	c3                   	ret    

00800283 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800283:	55                   	push   %ebp
  800284:	89 e5                	mov    %esp,%ebp
  800286:	57                   	push   %edi
  800287:	56                   	push   %esi
  800288:	53                   	push   %ebx
  800289:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80028c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800291:	b8 08 00 00 00       	mov    $0x8,%eax
  800296:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800299:	8b 55 08             	mov    0x8(%ebp),%edx
  80029c:	89 df                	mov    %ebx,%edi
  80029e:	89 de                	mov    %ebx,%esi
  8002a0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002a2:	85 c0                	test   %eax,%eax
  8002a4:	7e 28                	jle    8002ce <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002a6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002aa:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002b1:	00 
  8002b2:	c7 44 24 08 38 10 80 	movl   $0x801038,0x8(%esp)
  8002b9:	00 
  8002ba:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002c1:	00 
  8002c2:	c7 04 24 55 10 80 00 	movl   $0x801055,(%esp)
  8002c9:	e8 26 01 00 00       	call   8003f4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002ce:	83 c4 2c             	add    $0x2c,%esp
  8002d1:	5b                   	pop    %ebx
  8002d2:	5e                   	pop    %esi
  8002d3:	5f                   	pop    %edi
  8002d4:	5d                   	pop    %ebp
  8002d5:	c3                   	ret    

008002d6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002d6:	55                   	push   %ebp
  8002d7:	89 e5                	mov    %esp,%ebp
  8002d9:	57                   	push   %edi
  8002da:	56                   	push   %esi
  8002db:	53                   	push   %ebx
  8002dc:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002df:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002e4:	b8 09 00 00 00       	mov    $0x9,%eax
  8002e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ec:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ef:	89 df                	mov    %ebx,%edi
  8002f1:	89 de                	mov    %ebx,%esi
  8002f3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002f5:	85 c0                	test   %eax,%eax
  8002f7:	7e 28                	jle    800321 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002fd:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800304:	00 
  800305:	c7 44 24 08 38 10 80 	movl   $0x801038,0x8(%esp)
  80030c:	00 
  80030d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800314:	00 
  800315:	c7 04 24 55 10 80 00 	movl   $0x801055,(%esp)
  80031c:	e8 d3 00 00 00       	call   8003f4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800321:	83 c4 2c             	add    $0x2c,%esp
  800324:	5b                   	pop    %ebx
  800325:	5e                   	pop    %esi
  800326:	5f                   	pop    %edi
  800327:	5d                   	pop    %ebp
  800328:	c3                   	ret    

00800329 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800329:	55                   	push   %ebp
  80032a:	89 e5                	mov    %esp,%ebp
  80032c:	57                   	push   %edi
  80032d:	56                   	push   %esi
  80032e:	53                   	push   %ebx
  80032f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800332:	bb 00 00 00 00       	mov    $0x0,%ebx
  800337:	b8 0a 00 00 00       	mov    $0xa,%eax
  80033c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80033f:	8b 55 08             	mov    0x8(%ebp),%edx
  800342:	89 df                	mov    %ebx,%edi
  800344:	89 de                	mov    %ebx,%esi
  800346:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800348:	85 c0                	test   %eax,%eax
  80034a:	7e 28                	jle    800374 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80034c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800350:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800357:	00 
  800358:	c7 44 24 08 38 10 80 	movl   $0x801038,0x8(%esp)
  80035f:	00 
  800360:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800367:	00 
  800368:	c7 04 24 55 10 80 00 	movl   $0x801055,(%esp)
  80036f:	e8 80 00 00 00       	call   8003f4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800374:	83 c4 2c             	add    $0x2c,%esp
  800377:	5b                   	pop    %ebx
  800378:	5e                   	pop    %esi
  800379:	5f                   	pop    %edi
  80037a:	5d                   	pop    %ebp
  80037b:	c3                   	ret    

0080037c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80037c:	55                   	push   %ebp
  80037d:	89 e5                	mov    %esp,%ebp
  80037f:	57                   	push   %edi
  800380:	56                   	push   %esi
  800381:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800382:	be 00 00 00 00       	mov    $0x0,%esi
  800387:	b8 0c 00 00 00       	mov    $0xc,%eax
  80038c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80038f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800392:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800395:	8b 55 08             	mov    0x8(%ebp),%edx
  800398:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80039a:	5b                   	pop    %ebx
  80039b:	5e                   	pop    %esi
  80039c:	5f                   	pop    %edi
  80039d:	5d                   	pop    %ebp
  80039e:	c3                   	ret    

0080039f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80039f:	55                   	push   %ebp
  8003a0:	89 e5                	mov    %esp,%ebp
  8003a2:	57                   	push   %edi
  8003a3:	56                   	push   %esi
  8003a4:	53                   	push   %ebx
  8003a5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003a8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ad:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b5:	89 cb                	mov    %ecx,%ebx
  8003b7:	89 cf                	mov    %ecx,%edi
  8003b9:	89 ce                	mov    %ecx,%esi
  8003bb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003bd:	85 c0                	test   %eax,%eax
  8003bf:	7e 28                	jle    8003e9 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003c1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003c5:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003cc:	00 
  8003cd:	c7 44 24 08 38 10 80 	movl   $0x801038,0x8(%esp)
  8003d4:	00 
  8003d5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003dc:	00 
  8003dd:	c7 04 24 55 10 80 00 	movl   $0x801055,(%esp)
  8003e4:	e8 0b 00 00 00       	call   8003f4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003e9:	83 c4 2c             	add    $0x2c,%esp
  8003ec:	5b                   	pop    %ebx
  8003ed:	5e                   	pop    %esi
  8003ee:	5f                   	pop    %edi
  8003ef:	5d                   	pop    %ebp
  8003f0:	c3                   	ret    
  8003f1:	00 00                	add    %al,(%eax)
	...

008003f4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003f4:	55                   	push   %ebp
  8003f5:	89 e5                	mov    %esp,%ebp
  8003f7:	56                   	push   %esi
  8003f8:	53                   	push   %ebx
  8003f9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8003fc:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003ff:	8b 1d 04 20 80 00    	mov    0x802004,%ebx
  800405:	e8 41 fd ff ff       	call   80014b <sys_getenvid>
  80040a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80040d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800411:	8b 55 08             	mov    0x8(%ebp),%edx
  800414:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800418:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80041c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800420:	c7 04 24 64 10 80 00 	movl   $0x801064,(%esp)
  800427:	e8 c0 00 00 00       	call   8004ec <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80042c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800430:	8b 45 10             	mov    0x10(%ebp),%eax
  800433:	89 04 24             	mov    %eax,(%esp)
  800436:	e8 50 00 00 00       	call   80048b <vcprintf>
	cprintf("\n");
  80043b:	c7 04 24 2c 10 80 00 	movl   $0x80102c,(%esp)
  800442:	e8 a5 00 00 00       	call   8004ec <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800447:	cc                   	int3   
  800448:	eb fd                	jmp    800447 <_panic+0x53>
	...

0080044c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80044c:	55                   	push   %ebp
  80044d:	89 e5                	mov    %esp,%ebp
  80044f:	53                   	push   %ebx
  800450:	83 ec 14             	sub    $0x14,%esp
  800453:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800456:	8b 03                	mov    (%ebx),%eax
  800458:	8b 55 08             	mov    0x8(%ebp),%edx
  80045b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80045f:	40                   	inc    %eax
  800460:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800462:	3d ff 00 00 00       	cmp    $0xff,%eax
  800467:	75 19                	jne    800482 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800469:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800470:	00 
  800471:	8d 43 08             	lea    0x8(%ebx),%eax
  800474:	89 04 24             	mov    %eax,(%esp)
  800477:	e8 40 fc ff ff       	call   8000bc <sys_cputs>
		b->idx = 0;
  80047c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800482:	ff 43 04             	incl   0x4(%ebx)
}
  800485:	83 c4 14             	add    $0x14,%esp
  800488:	5b                   	pop    %ebx
  800489:	5d                   	pop    %ebp
  80048a:	c3                   	ret    

0080048b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80048b:	55                   	push   %ebp
  80048c:	89 e5                	mov    %esp,%ebp
  80048e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800494:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80049b:	00 00 00 
	b.cnt = 0;
  80049e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004a5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004af:	8b 45 08             	mov    0x8(%ebp),%eax
  8004b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004b6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004c0:	c7 04 24 4c 04 80 00 	movl   $0x80044c,(%esp)
  8004c7:	e8 82 01 00 00       	call   80064e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004cc:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8004d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004d6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004dc:	89 04 24             	mov    %eax,(%esp)
  8004df:	e8 d8 fb ff ff       	call   8000bc <sys_cputs>

	return b.cnt;
}
  8004e4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004ea:	c9                   	leave  
  8004eb:	c3                   	ret    

008004ec <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004ec:	55                   	push   %ebp
  8004ed:	89 e5                	mov    %esp,%ebp
  8004ef:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004f2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fc:	89 04 24             	mov    %eax,(%esp)
  8004ff:	e8 87 ff ff ff       	call   80048b <vcprintf>
	va_end(ap);

	return cnt;
}
  800504:	c9                   	leave  
  800505:	c3                   	ret    
	...

00800508 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800508:	55                   	push   %ebp
  800509:	89 e5                	mov    %esp,%ebp
  80050b:	57                   	push   %edi
  80050c:	56                   	push   %esi
  80050d:	53                   	push   %ebx
  80050e:	83 ec 3c             	sub    $0x3c,%esp
  800511:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800514:	89 d7                	mov    %edx,%edi
  800516:	8b 45 08             	mov    0x8(%ebp),%eax
  800519:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80051c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80051f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800522:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800525:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800528:	85 c0                	test   %eax,%eax
  80052a:	75 08                	jne    800534 <printnum+0x2c>
  80052c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80052f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800532:	77 57                	ja     80058b <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800534:	89 74 24 10          	mov    %esi,0x10(%esp)
  800538:	4b                   	dec    %ebx
  800539:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80053d:	8b 45 10             	mov    0x10(%ebp),%eax
  800540:	89 44 24 08          	mov    %eax,0x8(%esp)
  800544:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800548:	8b 74 24 0c          	mov    0xc(%esp),%esi
  80054c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800553:	00 
  800554:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800557:	89 04 24             	mov    %eax,(%esp)
  80055a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80055d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800561:	e8 56 08 00 00       	call   800dbc <__udivdi3>
  800566:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80056a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80056e:	89 04 24             	mov    %eax,(%esp)
  800571:	89 54 24 04          	mov    %edx,0x4(%esp)
  800575:	89 fa                	mov    %edi,%edx
  800577:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80057a:	e8 89 ff ff ff       	call   800508 <printnum>
  80057f:	eb 0f                	jmp    800590 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800581:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800585:	89 34 24             	mov    %esi,(%esp)
  800588:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80058b:	4b                   	dec    %ebx
  80058c:	85 db                	test   %ebx,%ebx
  80058e:	7f f1                	jg     800581 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800590:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800594:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800598:	8b 45 10             	mov    0x10(%ebp),%eax
  80059b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80059f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005a6:	00 
  8005a7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005aa:	89 04 24             	mov    %eax,(%esp)
  8005ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005b4:	e8 23 09 00 00       	call   800edc <__umoddi3>
  8005b9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005bd:	0f be 80 87 10 80 00 	movsbl 0x801087(%eax),%eax
  8005c4:	89 04 24             	mov    %eax,(%esp)
  8005c7:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8005ca:	83 c4 3c             	add    $0x3c,%esp
  8005cd:	5b                   	pop    %ebx
  8005ce:	5e                   	pop    %esi
  8005cf:	5f                   	pop    %edi
  8005d0:	5d                   	pop    %ebp
  8005d1:	c3                   	ret    

008005d2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8005d2:	55                   	push   %ebp
  8005d3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8005d5:	83 fa 01             	cmp    $0x1,%edx
  8005d8:	7e 0e                	jle    8005e8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8005da:	8b 10                	mov    (%eax),%edx
  8005dc:	8d 4a 08             	lea    0x8(%edx),%ecx
  8005df:	89 08                	mov    %ecx,(%eax)
  8005e1:	8b 02                	mov    (%edx),%eax
  8005e3:	8b 52 04             	mov    0x4(%edx),%edx
  8005e6:	eb 22                	jmp    80060a <getuint+0x38>
	else if (lflag)
  8005e8:	85 d2                	test   %edx,%edx
  8005ea:	74 10                	je     8005fc <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8005ec:	8b 10                	mov    (%eax),%edx
  8005ee:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005f1:	89 08                	mov    %ecx,(%eax)
  8005f3:	8b 02                	mov    (%edx),%eax
  8005f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8005fa:	eb 0e                	jmp    80060a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005fc:	8b 10                	mov    (%eax),%edx
  8005fe:	8d 4a 04             	lea    0x4(%edx),%ecx
  800601:	89 08                	mov    %ecx,(%eax)
  800603:	8b 02                	mov    (%edx),%eax
  800605:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80060a:	5d                   	pop    %ebp
  80060b:	c3                   	ret    

0080060c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80060c:	55                   	push   %ebp
  80060d:	89 e5                	mov    %esp,%ebp
  80060f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800612:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800615:	8b 10                	mov    (%eax),%edx
  800617:	3b 50 04             	cmp    0x4(%eax),%edx
  80061a:	73 08                	jae    800624 <sprintputch+0x18>
		*b->buf++ = ch;
  80061c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80061f:	88 0a                	mov    %cl,(%edx)
  800621:	42                   	inc    %edx
  800622:	89 10                	mov    %edx,(%eax)
}
  800624:	5d                   	pop    %ebp
  800625:	c3                   	ret    

00800626 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800626:	55                   	push   %ebp
  800627:	89 e5                	mov    %esp,%ebp
  800629:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80062c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80062f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800633:	8b 45 10             	mov    0x10(%ebp),%eax
  800636:	89 44 24 08          	mov    %eax,0x8(%esp)
  80063a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80063d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800641:	8b 45 08             	mov    0x8(%ebp),%eax
  800644:	89 04 24             	mov    %eax,(%esp)
  800647:	e8 02 00 00 00       	call   80064e <vprintfmt>
	va_end(ap);
}
  80064c:	c9                   	leave  
  80064d:	c3                   	ret    

0080064e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80064e:	55                   	push   %ebp
  80064f:	89 e5                	mov    %esp,%ebp
  800651:	57                   	push   %edi
  800652:	56                   	push   %esi
  800653:	53                   	push   %ebx
  800654:	83 ec 4c             	sub    $0x4c,%esp
  800657:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80065a:	8b 75 10             	mov    0x10(%ebp),%esi
  80065d:	eb 12                	jmp    800671 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80065f:	85 c0                	test   %eax,%eax
  800661:	0f 84 6b 03 00 00    	je     8009d2 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800667:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80066b:	89 04 24             	mov    %eax,(%esp)
  80066e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800671:	0f b6 06             	movzbl (%esi),%eax
  800674:	46                   	inc    %esi
  800675:	83 f8 25             	cmp    $0x25,%eax
  800678:	75 e5                	jne    80065f <vprintfmt+0x11>
  80067a:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80067e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800685:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80068a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800691:	b9 00 00 00 00       	mov    $0x0,%ecx
  800696:	eb 26                	jmp    8006be <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800698:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80069b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80069f:	eb 1d                	jmp    8006be <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a1:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8006a4:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8006a8:	eb 14                	jmp    8006be <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006aa:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8006ad:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8006b4:	eb 08                	jmp    8006be <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8006b6:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8006b9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006be:	0f b6 06             	movzbl (%esi),%eax
  8006c1:	8d 56 01             	lea    0x1(%esi),%edx
  8006c4:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8006c7:	8a 16                	mov    (%esi),%dl
  8006c9:	83 ea 23             	sub    $0x23,%edx
  8006cc:	80 fa 55             	cmp    $0x55,%dl
  8006cf:	0f 87 e1 02 00 00    	ja     8009b6 <vprintfmt+0x368>
  8006d5:	0f b6 d2             	movzbl %dl,%edx
  8006d8:	ff 24 95 c0 11 80 00 	jmp    *0x8011c0(,%edx,4)
  8006df:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006e2:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8006e7:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8006ea:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8006ee:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8006f1:	8d 50 d0             	lea    -0x30(%eax),%edx
  8006f4:	83 fa 09             	cmp    $0x9,%edx
  8006f7:	77 2a                	ja     800723 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8006f9:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8006fa:	eb eb                	jmp    8006e7 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8006fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ff:	8d 50 04             	lea    0x4(%eax),%edx
  800702:	89 55 14             	mov    %edx,0x14(%ebp)
  800705:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800707:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80070a:	eb 17                	jmp    800723 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  80070c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800710:	78 98                	js     8006aa <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800712:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800715:	eb a7                	jmp    8006be <vprintfmt+0x70>
  800717:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80071a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800721:	eb 9b                	jmp    8006be <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800723:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800727:	79 95                	jns    8006be <vprintfmt+0x70>
  800729:	eb 8b                	jmp    8006b6 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80072b:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80072f:	eb 8d                	jmp    8006be <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800731:	8b 45 14             	mov    0x14(%ebp),%eax
  800734:	8d 50 04             	lea    0x4(%eax),%edx
  800737:	89 55 14             	mov    %edx,0x14(%ebp)
  80073a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80073e:	8b 00                	mov    (%eax),%eax
  800740:	89 04 24             	mov    %eax,(%esp)
  800743:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800746:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800749:	e9 23 ff ff ff       	jmp    800671 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80074e:	8b 45 14             	mov    0x14(%ebp),%eax
  800751:	8d 50 04             	lea    0x4(%eax),%edx
  800754:	89 55 14             	mov    %edx,0x14(%ebp)
  800757:	8b 00                	mov    (%eax),%eax
  800759:	85 c0                	test   %eax,%eax
  80075b:	79 02                	jns    80075f <vprintfmt+0x111>
  80075d:	f7 d8                	neg    %eax
  80075f:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800761:	83 f8 0f             	cmp    $0xf,%eax
  800764:	7f 0b                	jg     800771 <vprintfmt+0x123>
  800766:	8b 04 85 20 13 80 00 	mov    0x801320(,%eax,4),%eax
  80076d:	85 c0                	test   %eax,%eax
  80076f:	75 23                	jne    800794 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800771:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800775:	c7 44 24 08 9f 10 80 	movl   $0x80109f,0x8(%esp)
  80077c:	00 
  80077d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800781:	8b 45 08             	mov    0x8(%ebp),%eax
  800784:	89 04 24             	mov    %eax,(%esp)
  800787:	e8 9a fe ff ff       	call   800626 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80078c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80078f:	e9 dd fe ff ff       	jmp    800671 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800794:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800798:	c7 44 24 08 a8 10 80 	movl   $0x8010a8,0x8(%esp)
  80079f:	00 
  8007a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8007a7:	89 14 24             	mov    %edx,(%esp)
  8007aa:	e8 77 fe ff ff       	call   800626 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007af:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007b2:	e9 ba fe ff ff       	jmp    800671 <vprintfmt+0x23>
  8007b7:	89 f9                	mov    %edi,%ecx
  8007b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007bc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8007bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c2:	8d 50 04             	lea    0x4(%eax),%edx
  8007c5:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c8:	8b 30                	mov    (%eax),%esi
  8007ca:	85 f6                	test   %esi,%esi
  8007cc:	75 05                	jne    8007d3 <vprintfmt+0x185>
				p = "(null)";
  8007ce:	be 98 10 80 00       	mov    $0x801098,%esi
			if (width > 0 && padc != '-')
  8007d3:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8007d7:	0f 8e 84 00 00 00    	jle    800861 <vprintfmt+0x213>
  8007dd:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8007e1:	74 7e                	je     800861 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8007e3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007e7:	89 34 24             	mov    %esi,(%esp)
  8007ea:	e8 8b 02 00 00       	call   800a7a <strnlen>
  8007ef:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007f2:	29 c2                	sub    %eax,%edx
  8007f4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8007f7:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8007fb:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8007fe:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800801:	89 de                	mov    %ebx,%esi
  800803:	89 d3                	mov    %edx,%ebx
  800805:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800807:	eb 0b                	jmp    800814 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800809:	89 74 24 04          	mov    %esi,0x4(%esp)
  80080d:	89 3c 24             	mov    %edi,(%esp)
  800810:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800813:	4b                   	dec    %ebx
  800814:	85 db                	test   %ebx,%ebx
  800816:	7f f1                	jg     800809 <vprintfmt+0x1bb>
  800818:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80081b:	89 f3                	mov    %esi,%ebx
  80081d:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800820:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800823:	85 c0                	test   %eax,%eax
  800825:	79 05                	jns    80082c <vprintfmt+0x1de>
  800827:	b8 00 00 00 00       	mov    $0x0,%eax
  80082c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80082f:	29 c2                	sub    %eax,%edx
  800831:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800834:	eb 2b                	jmp    800861 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800836:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80083a:	74 18                	je     800854 <vprintfmt+0x206>
  80083c:	8d 50 e0             	lea    -0x20(%eax),%edx
  80083f:	83 fa 5e             	cmp    $0x5e,%edx
  800842:	76 10                	jbe    800854 <vprintfmt+0x206>
					putch('?', putdat);
  800844:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800848:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80084f:	ff 55 08             	call   *0x8(%ebp)
  800852:	eb 0a                	jmp    80085e <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800854:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800858:	89 04 24             	mov    %eax,(%esp)
  80085b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80085e:	ff 4d e4             	decl   -0x1c(%ebp)
  800861:	0f be 06             	movsbl (%esi),%eax
  800864:	46                   	inc    %esi
  800865:	85 c0                	test   %eax,%eax
  800867:	74 21                	je     80088a <vprintfmt+0x23c>
  800869:	85 ff                	test   %edi,%edi
  80086b:	78 c9                	js     800836 <vprintfmt+0x1e8>
  80086d:	4f                   	dec    %edi
  80086e:	79 c6                	jns    800836 <vprintfmt+0x1e8>
  800870:	8b 7d 08             	mov    0x8(%ebp),%edi
  800873:	89 de                	mov    %ebx,%esi
  800875:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800878:	eb 18                	jmp    800892 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80087a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80087e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800885:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800887:	4b                   	dec    %ebx
  800888:	eb 08                	jmp    800892 <vprintfmt+0x244>
  80088a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80088d:	89 de                	mov    %ebx,%esi
  80088f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800892:	85 db                	test   %ebx,%ebx
  800894:	7f e4                	jg     80087a <vprintfmt+0x22c>
  800896:	89 7d 08             	mov    %edi,0x8(%ebp)
  800899:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80089b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80089e:	e9 ce fd ff ff       	jmp    800671 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008a3:	83 f9 01             	cmp    $0x1,%ecx
  8008a6:	7e 10                	jle    8008b8 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8008a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ab:	8d 50 08             	lea    0x8(%eax),%edx
  8008ae:	89 55 14             	mov    %edx,0x14(%ebp)
  8008b1:	8b 30                	mov    (%eax),%esi
  8008b3:	8b 78 04             	mov    0x4(%eax),%edi
  8008b6:	eb 26                	jmp    8008de <vprintfmt+0x290>
	else if (lflag)
  8008b8:	85 c9                	test   %ecx,%ecx
  8008ba:	74 12                	je     8008ce <vprintfmt+0x280>
		return va_arg(*ap, long);
  8008bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8008bf:	8d 50 04             	lea    0x4(%eax),%edx
  8008c2:	89 55 14             	mov    %edx,0x14(%ebp)
  8008c5:	8b 30                	mov    (%eax),%esi
  8008c7:	89 f7                	mov    %esi,%edi
  8008c9:	c1 ff 1f             	sar    $0x1f,%edi
  8008cc:	eb 10                	jmp    8008de <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8008ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d1:	8d 50 04             	lea    0x4(%eax),%edx
  8008d4:	89 55 14             	mov    %edx,0x14(%ebp)
  8008d7:	8b 30                	mov    (%eax),%esi
  8008d9:	89 f7                	mov    %esi,%edi
  8008db:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8008de:	85 ff                	test   %edi,%edi
  8008e0:	78 0a                	js     8008ec <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8008e2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008e7:	e9 8c 00 00 00       	jmp    800978 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8008ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008f0:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8008f7:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8008fa:	f7 de                	neg    %esi
  8008fc:	83 d7 00             	adc    $0x0,%edi
  8008ff:	f7 df                	neg    %edi
			}
			base = 10;
  800901:	b8 0a 00 00 00       	mov    $0xa,%eax
  800906:	eb 70                	jmp    800978 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800908:	89 ca                	mov    %ecx,%edx
  80090a:	8d 45 14             	lea    0x14(%ebp),%eax
  80090d:	e8 c0 fc ff ff       	call   8005d2 <getuint>
  800912:	89 c6                	mov    %eax,%esi
  800914:	89 d7                	mov    %edx,%edi
			base = 10;
  800916:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80091b:	eb 5b                	jmp    800978 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  80091d:	89 ca                	mov    %ecx,%edx
  80091f:	8d 45 14             	lea    0x14(%ebp),%eax
  800922:	e8 ab fc ff ff       	call   8005d2 <getuint>
  800927:	89 c6                	mov    %eax,%esi
  800929:	89 d7                	mov    %edx,%edi
			base = 8;
  80092b:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800930:	eb 46                	jmp    800978 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  800932:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800936:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80093d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800940:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800944:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80094b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80094e:	8b 45 14             	mov    0x14(%ebp),%eax
  800951:	8d 50 04             	lea    0x4(%eax),%edx
  800954:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800957:	8b 30                	mov    (%eax),%esi
  800959:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80095e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800963:	eb 13                	jmp    800978 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800965:	89 ca                	mov    %ecx,%edx
  800967:	8d 45 14             	lea    0x14(%ebp),%eax
  80096a:	e8 63 fc ff ff       	call   8005d2 <getuint>
  80096f:	89 c6                	mov    %eax,%esi
  800971:	89 d7                	mov    %edx,%edi
			base = 16;
  800973:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800978:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  80097c:	89 54 24 10          	mov    %edx,0x10(%esp)
  800980:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800983:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800987:	89 44 24 08          	mov    %eax,0x8(%esp)
  80098b:	89 34 24             	mov    %esi,(%esp)
  80098e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800992:	89 da                	mov    %ebx,%edx
  800994:	8b 45 08             	mov    0x8(%ebp),%eax
  800997:	e8 6c fb ff ff       	call   800508 <printnum>
			break;
  80099c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80099f:	e9 cd fc ff ff       	jmp    800671 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8009a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009a8:	89 04 24             	mov    %eax,(%esp)
  8009ab:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009ae:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8009b1:	e9 bb fc ff ff       	jmp    800671 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8009b6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009ba:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8009c1:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009c4:	eb 01                	jmp    8009c7 <vprintfmt+0x379>
  8009c6:	4e                   	dec    %esi
  8009c7:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8009cb:	75 f9                	jne    8009c6 <vprintfmt+0x378>
  8009cd:	e9 9f fc ff ff       	jmp    800671 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8009d2:	83 c4 4c             	add    $0x4c,%esp
  8009d5:	5b                   	pop    %ebx
  8009d6:	5e                   	pop    %esi
  8009d7:	5f                   	pop    %edi
  8009d8:	5d                   	pop    %ebp
  8009d9:	c3                   	ret    

008009da <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009da:	55                   	push   %ebp
  8009db:	89 e5                	mov    %esp,%ebp
  8009dd:	83 ec 28             	sub    $0x28,%esp
  8009e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009e6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009e9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009ed:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009f0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009f7:	85 c0                	test   %eax,%eax
  8009f9:	74 30                	je     800a2b <vsnprintf+0x51>
  8009fb:	85 d2                	test   %edx,%edx
  8009fd:	7e 33                	jle    800a32 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800a02:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a06:	8b 45 10             	mov    0x10(%ebp),%eax
  800a09:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a0d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a10:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a14:	c7 04 24 0c 06 80 00 	movl   $0x80060c,(%esp)
  800a1b:	e8 2e fc ff ff       	call   80064e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a20:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a23:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a26:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a29:	eb 0c                	jmp    800a37 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a2b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a30:	eb 05                	jmp    800a37 <vsnprintf+0x5d>
  800a32:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a37:	c9                   	leave  
  800a38:	c3                   	ret    

00800a39 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a39:	55                   	push   %ebp
  800a3a:	89 e5                	mov    %esp,%ebp
  800a3c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a3f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a42:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a46:	8b 45 10             	mov    0x10(%ebp),%eax
  800a49:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a4d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a50:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a54:	8b 45 08             	mov    0x8(%ebp),%eax
  800a57:	89 04 24             	mov    %eax,(%esp)
  800a5a:	e8 7b ff ff ff       	call   8009da <vsnprintf>
	va_end(ap);

	return rc;
}
  800a5f:	c9                   	leave  
  800a60:	c3                   	ret    
  800a61:	00 00                	add    %al,(%eax)
	...

00800a64 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a64:	55                   	push   %ebp
  800a65:	89 e5                	mov    %esp,%ebp
  800a67:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a6a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6f:	eb 01                	jmp    800a72 <strlen+0xe>
		n++;
  800a71:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a72:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a76:	75 f9                	jne    800a71 <strlen+0xd>
		n++;
	return n;
}
  800a78:	5d                   	pop    %ebp
  800a79:	c3                   	ret    

00800a7a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
  800a7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800a80:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a83:	b8 00 00 00 00       	mov    $0x0,%eax
  800a88:	eb 01                	jmp    800a8b <strnlen+0x11>
		n++;
  800a8a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a8b:	39 d0                	cmp    %edx,%eax
  800a8d:	74 06                	je     800a95 <strnlen+0x1b>
  800a8f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a93:	75 f5                	jne    800a8a <strnlen+0x10>
		n++;
	return n;
}
  800a95:	5d                   	pop    %ebp
  800a96:	c3                   	ret    

00800a97 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a97:	55                   	push   %ebp
  800a98:	89 e5                	mov    %esp,%ebp
  800a9a:	53                   	push   %ebx
  800a9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800aa1:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa6:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800aa9:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800aac:	42                   	inc    %edx
  800aad:	84 c9                	test   %cl,%cl
  800aaf:	75 f5                	jne    800aa6 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800ab1:	5b                   	pop    %ebx
  800ab2:	5d                   	pop    %ebp
  800ab3:	c3                   	ret    

00800ab4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800ab4:	55                   	push   %ebp
  800ab5:	89 e5                	mov    %esp,%ebp
  800ab7:	53                   	push   %ebx
  800ab8:	83 ec 08             	sub    $0x8,%esp
  800abb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800abe:	89 1c 24             	mov    %ebx,(%esp)
  800ac1:	e8 9e ff ff ff       	call   800a64 <strlen>
	strcpy(dst + len, src);
  800ac6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ac9:	89 54 24 04          	mov    %edx,0x4(%esp)
  800acd:	01 d8                	add    %ebx,%eax
  800acf:	89 04 24             	mov    %eax,(%esp)
  800ad2:	e8 c0 ff ff ff       	call   800a97 <strcpy>
	return dst;
}
  800ad7:	89 d8                	mov    %ebx,%eax
  800ad9:	83 c4 08             	add    $0x8,%esp
  800adc:	5b                   	pop    %ebx
  800add:	5d                   	pop    %ebp
  800ade:	c3                   	ret    

00800adf <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800adf:	55                   	push   %ebp
  800ae0:	89 e5                	mov    %esp,%ebp
  800ae2:	56                   	push   %esi
  800ae3:	53                   	push   %ebx
  800ae4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aea:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800aed:	b9 00 00 00 00       	mov    $0x0,%ecx
  800af2:	eb 0c                	jmp    800b00 <strncpy+0x21>
		*dst++ = *src;
  800af4:	8a 1a                	mov    (%edx),%bl
  800af6:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800af9:	80 3a 01             	cmpb   $0x1,(%edx)
  800afc:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800aff:	41                   	inc    %ecx
  800b00:	39 f1                	cmp    %esi,%ecx
  800b02:	75 f0                	jne    800af4 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b04:	5b                   	pop    %ebx
  800b05:	5e                   	pop    %esi
  800b06:	5d                   	pop    %ebp
  800b07:	c3                   	ret    

00800b08 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b08:	55                   	push   %ebp
  800b09:	89 e5                	mov    %esp,%ebp
  800b0b:	56                   	push   %esi
  800b0c:	53                   	push   %ebx
  800b0d:	8b 75 08             	mov    0x8(%ebp),%esi
  800b10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b13:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b16:	85 d2                	test   %edx,%edx
  800b18:	75 0a                	jne    800b24 <strlcpy+0x1c>
  800b1a:	89 f0                	mov    %esi,%eax
  800b1c:	eb 1a                	jmp    800b38 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b1e:	88 18                	mov    %bl,(%eax)
  800b20:	40                   	inc    %eax
  800b21:	41                   	inc    %ecx
  800b22:	eb 02                	jmp    800b26 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b24:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800b26:	4a                   	dec    %edx
  800b27:	74 0a                	je     800b33 <strlcpy+0x2b>
  800b29:	8a 19                	mov    (%ecx),%bl
  800b2b:	84 db                	test   %bl,%bl
  800b2d:	75 ef                	jne    800b1e <strlcpy+0x16>
  800b2f:	89 c2                	mov    %eax,%edx
  800b31:	eb 02                	jmp    800b35 <strlcpy+0x2d>
  800b33:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800b35:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800b38:	29 f0                	sub    %esi,%eax
}
  800b3a:	5b                   	pop    %ebx
  800b3b:	5e                   	pop    %esi
  800b3c:	5d                   	pop    %ebp
  800b3d:	c3                   	ret    

00800b3e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b3e:	55                   	push   %ebp
  800b3f:	89 e5                	mov    %esp,%ebp
  800b41:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b44:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b47:	eb 02                	jmp    800b4b <strcmp+0xd>
		p++, q++;
  800b49:	41                   	inc    %ecx
  800b4a:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b4b:	8a 01                	mov    (%ecx),%al
  800b4d:	84 c0                	test   %al,%al
  800b4f:	74 04                	je     800b55 <strcmp+0x17>
  800b51:	3a 02                	cmp    (%edx),%al
  800b53:	74 f4                	je     800b49 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b55:	0f b6 c0             	movzbl %al,%eax
  800b58:	0f b6 12             	movzbl (%edx),%edx
  800b5b:	29 d0                	sub    %edx,%eax
}
  800b5d:	5d                   	pop    %ebp
  800b5e:	c3                   	ret    

00800b5f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	53                   	push   %ebx
  800b63:	8b 45 08             	mov    0x8(%ebp),%eax
  800b66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b69:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800b6c:	eb 03                	jmp    800b71 <strncmp+0x12>
		n--, p++, q++;
  800b6e:	4a                   	dec    %edx
  800b6f:	40                   	inc    %eax
  800b70:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b71:	85 d2                	test   %edx,%edx
  800b73:	74 14                	je     800b89 <strncmp+0x2a>
  800b75:	8a 18                	mov    (%eax),%bl
  800b77:	84 db                	test   %bl,%bl
  800b79:	74 04                	je     800b7f <strncmp+0x20>
  800b7b:	3a 19                	cmp    (%ecx),%bl
  800b7d:	74 ef                	je     800b6e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b7f:	0f b6 00             	movzbl (%eax),%eax
  800b82:	0f b6 11             	movzbl (%ecx),%edx
  800b85:	29 d0                	sub    %edx,%eax
  800b87:	eb 05                	jmp    800b8e <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b89:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b8e:	5b                   	pop    %ebx
  800b8f:	5d                   	pop    %ebp
  800b90:	c3                   	ret    

00800b91 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b91:	55                   	push   %ebp
  800b92:	89 e5                	mov    %esp,%ebp
  800b94:	8b 45 08             	mov    0x8(%ebp),%eax
  800b97:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b9a:	eb 05                	jmp    800ba1 <strchr+0x10>
		if (*s == c)
  800b9c:	38 ca                	cmp    %cl,%dl
  800b9e:	74 0c                	je     800bac <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ba0:	40                   	inc    %eax
  800ba1:	8a 10                	mov    (%eax),%dl
  800ba3:	84 d2                	test   %dl,%dl
  800ba5:	75 f5                	jne    800b9c <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800ba7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    

00800bae <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb4:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800bb7:	eb 05                	jmp    800bbe <strfind+0x10>
		if (*s == c)
  800bb9:	38 ca                	cmp    %cl,%dl
  800bbb:	74 07                	je     800bc4 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800bbd:	40                   	inc    %eax
  800bbe:	8a 10                	mov    (%eax),%dl
  800bc0:	84 d2                	test   %dl,%dl
  800bc2:	75 f5                	jne    800bb9 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800bc4:	5d                   	pop    %ebp
  800bc5:	c3                   	ret    

00800bc6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	57                   	push   %edi
  800bca:	56                   	push   %esi
  800bcb:	53                   	push   %ebx
  800bcc:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bcf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bd2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bd5:	85 c9                	test   %ecx,%ecx
  800bd7:	74 30                	je     800c09 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bd9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bdf:	75 25                	jne    800c06 <memset+0x40>
  800be1:	f6 c1 03             	test   $0x3,%cl
  800be4:	75 20                	jne    800c06 <memset+0x40>
		c &= 0xFF;
  800be6:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800be9:	89 d3                	mov    %edx,%ebx
  800beb:	c1 e3 08             	shl    $0x8,%ebx
  800bee:	89 d6                	mov    %edx,%esi
  800bf0:	c1 e6 18             	shl    $0x18,%esi
  800bf3:	89 d0                	mov    %edx,%eax
  800bf5:	c1 e0 10             	shl    $0x10,%eax
  800bf8:	09 f0                	or     %esi,%eax
  800bfa:	09 d0                	or     %edx,%eax
  800bfc:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bfe:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800c01:	fc                   	cld    
  800c02:	f3 ab                	rep stos %eax,%es:(%edi)
  800c04:	eb 03                	jmp    800c09 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c06:	fc                   	cld    
  800c07:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c09:	89 f8                	mov    %edi,%eax
  800c0b:	5b                   	pop    %ebx
  800c0c:	5e                   	pop    %esi
  800c0d:	5f                   	pop    %edi
  800c0e:	5d                   	pop    %ebp
  800c0f:	c3                   	ret    

00800c10 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c10:	55                   	push   %ebp
  800c11:	89 e5                	mov    %esp,%ebp
  800c13:	57                   	push   %edi
  800c14:	56                   	push   %esi
  800c15:	8b 45 08             	mov    0x8(%ebp),%eax
  800c18:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c1b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c1e:	39 c6                	cmp    %eax,%esi
  800c20:	73 34                	jae    800c56 <memmove+0x46>
  800c22:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c25:	39 d0                	cmp    %edx,%eax
  800c27:	73 2d                	jae    800c56 <memmove+0x46>
		s += n;
		d += n;
  800c29:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c2c:	f6 c2 03             	test   $0x3,%dl
  800c2f:	75 1b                	jne    800c4c <memmove+0x3c>
  800c31:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c37:	75 13                	jne    800c4c <memmove+0x3c>
  800c39:	f6 c1 03             	test   $0x3,%cl
  800c3c:	75 0e                	jne    800c4c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c3e:	83 ef 04             	sub    $0x4,%edi
  800c41:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c44:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c47:	fd                   	std    
  800c48:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c4a:	eb 07                	jmp    800c53 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c4c:	4f                   	dec    %edi
  800c4d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c50:	fd                   	std    
  800c51:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c53:	fc                   	cld    
  800c54:	eb 20                	jmp    800c76 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c56:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c5c:	75 13                	jne    800c71 <memmove+0x61>
  800c5e:	a8 03                	test   $0x3,%al
  800c60:	75 0f                	jne    800c71 <memmove+0x61>
  800c62:	f6 c1 03             	test   $0x3,%cl
  800c65:	75 0a                	jne    800c71 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c67:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c6a:	89 c7                	mov    %eax,%edi
  800c6c:	fc                   	cld    
  800c6d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c6f:	eb 05                	jmp    800c76 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c71:	89 c7                	mov    %eax,%edi
  800c73:	fc                   	cld    
  800c74:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c76:	5e                   	pop    %esi
  800c77:	5f                   	pop    %edi
  800c78:	5d                   	pop    %ebp
  800c79:	c3                   	ret    

00800c7a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c7a:	55                   	push   %ebp
  800c7b:	89 e5                	mov    %esp,%ebp
  800c7d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c80:	8b 45 10             	mov    0x10(%ebp),%eax
  800c83:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c87:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c8a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c91:	89 04 24             	mov    %eax,(%esp)
  800c94:	e8 77 ff ff ff       	call   800c10 <memmove>
}
  800c99:	c9                   	leave  
  800c9a:	c3                   	ret    

00800c9b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c9b:	55                   	push   %ebp
  800c9c:	89 e5                	mov    %esp,%ebp
  800c9e:	57                   	push   %edi
  800c9f:	56                   	push   %esi
  800ca0:	53                   	push   %ebx
  800ca1:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ca4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ca7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800caa:	ba 00 00 00 00       	mov    $0x0,%edx
  800caf:	eb 16                	jmp    800cc7 <memcmp+0x2c>
		if (*s1 != *s2)
  800cb1:	8a 04 17             	mov    (%edi,%edx,1),%al
  800cb4:	42                   	inc    %edx
  800cb5:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800cb9:	38 c8                	cmp    %cl,%al
  800cbb:	74 0a                	je     800cc7 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800cbd:	0f b6 c0             	movzbl %al,%eax
  800cc0:	0f b6 c9             	movzbl %cl,%ecx
  800cc3:	29 c8                	sub    %ecx,%eax
  800cc5:	eb 09                	jmp    800cd0 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cc7:	39 da                	cmp    %ebx,%edx
  800cc9:	75 e6                	jne    800cb1 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ccb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cd0:	5b                   	pop    %ebx
  800cd1:	5e                   	pop    %esi
  800cd2:	5f                   	pop    %edi
  800cd3:	5d                   	pop    %ebp
  800cd4:	c3                   	ret    

00800cd5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cd5:	55                   	push   %ebp
  800cd6:	89 e5                	mov    %esp,%ebp
  800cd8:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800cde:	89 c2                	mov    %eax,%edx
  800ce0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ce3:	eb 05                	jmp    800cea <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ce5:	38 08                	cmp    %cl,(%eax)
  800ce7:	74 05                	je     800cee <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ce9:	40                   	inc    %eax
  800cea:	39 d0                	cmp    %edx,%eax
  800cec:	72 f7                	jb     800ce5 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800cee:	5d                   	pop    %ebp
  800cef:	c3                   	ret    

00800cf0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cf0:	55                   	push   %ebp
  800cf1:	89 e5                	mov    %esp,%ebp
  800cf3:	57                   	push   %edi
  800cf4:	56                   	push   %esi
  800cf5:	53                   	push   %ebx
  800cf6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cfc:	eb 01                	jmp    800cff <strtol+0xf>
		s++;
  800cfe:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cff:	8a 02                	mov    (%edx),%al
  800d01:	3c 20                	cmp    $0x20,%al
  800d03:	74 f9                	je     800cfe <strtol+0xe>
  800d05:	3c 09                	cmp    $0x9,%al
  800d07:	74 f5                	je     800cfe <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d09:	3c 2b                	cmp    $0x2b,%al
  800d0b:	75 08                	jne    800d15 <strtol+0x25>
		s++;
  800d0d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d0e:	bf 00 00 00 00       	mov    $0x0,%edi
  800d13:	eb 13                	jmp    800d28 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d15:	3c 2d                	cmp    $0x2d,%al
  800d17:	75 0a                	jne    800d23 <strtol+0x33>
		s++, neg = 1;
  800d19:	8d 52 01             	lea    0x1(%edx),%edx
  800d1c:	bf 01 00 00 00       	mov    $0x1,%edi
  800d21:	eb 05                	jmp    800d28 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d23:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d28:	85 db                	test   %ebx,%ebx
  800d2a:	74 05                	je     800d31 <strtol+0x41>
  800d2c:	83 fb 10             	cmp    $0x10,%ebx
  800d2f:	75 28                	jne    800d59 <strtol+0x69>
  800d31:	8a 02                	mov    (%edx),%al
  800d33:	3c 30                	cmp    $0x30,%al
  800d35:	75 10                	jne    800d47 <strtol+0x57>
  800d37:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d3b:	75 0a                	jne    800d47 <strtol+0x57>
		s += 2, base = 16;
  800d3d:	83 c2 02             	add    $0x2,%edx
  800d40:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d45:	eb 12                	jmp    800d59 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800d47:	85 db                	test   %ebx,%ebx
  800d49:	75 0e                	jne    800d59 <strtol+0x69>
  800d4b:	3c 30                	cmp    $0x30,%al
  800d4d:	75 05                	jne    800d54 <strtol+0x64>
		s++, base = 8;
  800d4f:	42                   	inc    %edx
  800d50:	b3 08                	mov    $0x8,%bl
  800d52:	eb 05                	jmp    800d59 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800d54:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800d59:	b8 00 00 00 00       	mov    $0x0,%eax
  800d5e:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d60:	8a 0a                	mov    (%edx),%cl
  800d62:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d65:	80 fb 09             	cmp    $0x9,%bl
  800d68:	77 08                	ja     800d72 <strtol+0x82>
			dig = *s - '0';
  800d6a:	0f be c9             	movsbl %cl,%ecx
  800d6d:	83 e9 30             	sub    $0x30,%ecx
  800d70:	eb 1e                	jmp    800d90 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800d72:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d75:	80 fb 19             	cmp    $0x19,%bl
  800d78:	77 08                	ja     800d82 <strtol+0x92>
			dig = *s - 'a' + 10;
  800d7a:	0f be c9             	movsbl %cl,%ecx
  800d7d:	83 e9 57             	sub    $0x57,%ecx
  800d80:	eb 0e                	jmp    800d90 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800d82:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d85:	80 fb 19             	cmp    $0x19,%bl
  800d88:	77 12                	ja     800d9c <strtol+0xac>
			dig = *s - 'A' + 10;
  800d8a:	0f be c9             	movsbl %cl,%ecx
  800d8d:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d90:	39 f1                	cmp    %esi,%ecx
  800d92:	7d 0c                	jge    800da0 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800d94:	42                   	inc    %edx
  800d95:	0f af c6             	imul   %esi,%eax
  800d98:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d9a:	eb c4                	jmp    800d60 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d9c:	89 c1                	mov    %eax,%ecx
  800d9e:	eb 02                	jmp    800da2 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800da0:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800da2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800da6:	74 05                	je     800dad <strtol+0xbd>
		*endptr = (char *) s;
  800da8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800dab:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800dad:	85 ff                	test   %edi,%edi
  800daf:	74 04                	je     800db5 <strtol+0xc5>
  800db1:	89 c8                	mov    %ecx,%eax
  800db3:	f7 d8                	neg    %eax
}
  800db5:	5b                   	pop    %ebx
  800db6:	5e                   	pop    %esi
  800db7:	5f                   	pop    %edi
  800db8:	5d                   	pop    %ebp
  800db9:	c3                   	ret    
	...

00800dbc <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800dbc:	55                   	push   %ebp
  800dbd:	57                   	push   %edi
  800dbe:	56                   	push   %esi
  800dbf:	83 ec 10             	sub    $0x10,%esp
  800dc2:	8b 74 24 20          	mov    0x20(%esp),%esi
  800dc6:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800dca:	89 74 24 04          	mov    %esi,0x4(%esp)
  800dce:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  800dd2:	89 cd                	mov    %ecx,%ebp
  800dd4:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800dd8:	85 c0                	test   %eax,%eax
  800dda:	75 2c                	jne    800e08 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800ddc:	39 f9                	cmp    %edi,%ecx
  800dde:	77 68                	ja     800e48 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800de0:	85 c9                	test   %ecx,%ecx
  800de2:	75 0b                	jne    800def <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800de4:	b8 01 00 00 00       	mov    $0x1,%eax
  800de9:	31 d2                	xor    %edx,%edx
  800deb:	f7 f1                	div    %ecx
  800ded:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800def:	31 d2                	xor    %edx,%edx
  800df1:	89 f8                	mov    %edi,%eax
  800df3:	f7 f1                	div    %ecx
  800df5:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800df7:	89 f0                	mov    %esi,%eax
  800df9:	f7 f1                	div    %ecx
  800dfb:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800dfd:	89 f0                	mov    %esi,%eax
  800dff:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e01:	83 c4 10             	add    $0x10,%esp
  800e04:	5e                   	pop    %esi
  800e05:	5f                   	pop    %edi
  800e06:	5d                   	pop    %ebp
  800e07:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e08:	39 f8                	cmp    %edi,%eax
  800e0a:	77 2c                	ja     800e38 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e0c:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  800e0f:	83 f6 1f             	xor    $0x1f,%esi
  800e12:	75 4c                	jne    800e60 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e14:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e16:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e1b:	72 0a                	jb     800e27 <__udivdi3+0x6b>
  800e1d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800e21:	0f 87 ad 00 00 00    	ja     800ed4 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e27:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e2c:	89 f0                	mov    %esi,%eax
  800e2e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e30:	83 c4 10             	add    $0x10,%esp
  800e33:	5e                   	pop    %esi
  800e34:	5f                   	pop    %edi
  800e35:	5d                   	pop    %ebp
  800e36:	c3                   	ret    
  800e37:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e38:	31 ff                	xor    %edi,%edi
  800e3a:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e3c:	89 f0                	mov    %esi,%eax
  800e3e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e40:	83 c4 10             	add    $0x10,%esp
  800e43:	5e                   	pop    %esi
  800e44:	5f                   	pop    %edi
  800e45:	5d                   	pop    %ebp
  800e46:	c3                   	ret    
  800e47:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e48:	89 fa                	mov    %edi,%edx
  800e4a:	89 f0                	mov    %esi,%eax
  800e4c:	f7 f1                	div    %ecx
  800e4e:	89 c6                	mov    %eax,%esi
  800e50:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e52:	89 f0                	mov    %esi,%eax
  800e54:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e56:	83 c4 10             	add    $0x10,%esp
  800e59:	5e                   	pop    %esi
  800e5a:	5f                   	pop    %edi
  800e5b:	5d                   	pop    %ebp
  800e5c:	c3                   	ret    
  800e5d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e60:	89 f1                	mov    %esi,%ecx
  800e62:	d3 e0                	shl    %cl,%eax
  800e64:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e68:	b8 20 00 00 00       	mov    $0x20,%eax
  800e6d:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800e6f:	89 ea                	mov    %ebp,%edx
  800e71:	88 c1                	mov    %al,%cl
  800e73:	d3 ea                	shr    %cl,%edx
  800e75:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800e79:	09 ca                	or     %ecx,%edx
  800e7b:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  800e7f:	89 f1                	mov    %esi,%ecx
  800e81:	d3 e5                	shl    %cl,%ebp
  800e83:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  800e87:	89 fd                	mov    %edi,%ebp
  800e89:	88 c1                	mov    %al,%cl
  800e8b:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  800e8d:	89 fa                	mov    %edi,%edx
  800e8f:	89 f1                	mov    %esi,%ecx
  800e91:	d3 e2                	shl    %cl,%edx
  800e93:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e97:	88 c1                	mov    %al,%cl
  800e99:	d3 ef                	shr    %cl,%edi
  800e9b:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e9d:	89 f8                	mov    %edi,%eax
  800e9f:	89 ea                	mov    %ebp,%edx
  800ea1:	f7 74 24 08          	divl   0x8(%esp)
  800ea5:	89 d1                	mov    %edx,%ecx
  800ea7:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  800ea9:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ead:	39 d1                	cmp    %edx,%ecx
  800eaf:	72 17                	jb     800ec8 <__udivdi3+0x10c>
  800eb1:	74 09                	je     800ebc <__udivdi3+0x100>
  800eb3:	89 fe                	mov    %edi,%esi
  800eb5:	31 ff                	xor    %edi,%edi
  800eb7:	e9 41 ff ff ff       	jmp    800dfd <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800ebc:	8b 54 24 04          	mov    0x4(%esp),%edx
  800ec0:	89 f1                	mov    %esi,%ecx
  800ec2:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ec4:	39 c2                	cmp    %eax,%edx
  800ec6:	73 eb                	jae    800eb3 <__udivdi3+0xf7>
		{
		  q0--;
  800ec8:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800ecb:	31 ff                	xor    %edi,%edi
  800ecd:	e9 2b ff ff ff       	jmp    800dfd <__udivdi3+0x41>
  800ed2:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ed4:	31 f6                	xor    %esi,%esi
  800ed6:	e9 22 ff ff ff       	jmp    800dfd <__udivdi3+0x41>
	...

00800edc <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800edc:	55                   	push   %ebp
  800edd:	57                   	push   %edi
  800ede:	56                   	push   %esi
  800edf:	83 ec 20             	sub    $0x20,%esp
  800ee2:	8b 44 24 30          	mov    0x30(%esp),%eax
  800ee6:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800eea:	89 44 24 14          	mov    %eax,0x14(%esp)
  800eee:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  800ef2:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800ef6:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800efa:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  800efc:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800efe:	85 ed                	test   %ebp,%ebp
  800f00:	75 16                	jne    800f18 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  800f02:	39 f1                	cmp    %esi,%ecx
  800f04:	0f 86 a6 00 00 00    	jbe    800fb0 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f0a:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800f0c:	89 d0                	mov    %edx,%eax
  800f0e:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f10:	83 c4 20             	add    $0x20,%esp
  800f13:	5e                   	pop    %esi
  800f14:	5f                   	pop    %edi
  800f15:	5d                   	pop    %ebp
  800f16:	c3                   	ret    
  800f17:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800f18:	39 f5                	cmp    %esi,%ebp
  800f1a:	0f 87 ac 00 00 00    	ja     800fcc <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800f20:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  800f23:	83 f0 1f             	xor    $0x1f,%eax
  800f26:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f2a:	0f 84 a8 00 00 00    	je     800fd8 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800f30:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f34:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800f36:	bf 20 00 00 00       	mov    $0x20,%edi
  800f3b:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800f3f:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f43:	89 f9                	mov    %edi,%ecx
  800f45:	d3 e8                	shr    %cl,%eax
  800f47:	09 e8                	or     %ebp,%eax
  800f49:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  800f4d:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f51:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f55:	d3 e0                	shl    %cl,%eax
  800f57:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800f5b:	89 f2                	mov    %esi,%edx
  800f5d:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800f5f:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f63:	d3 e0                	shl    %cl,%eax
  800f65:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800f69:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f6d:	89 f9                	mov    %edi,%ecx
  800f6f:	d3 e8                	shr    %cl,%eax
  800f71:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800f73:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800f75:	89 f2                	mov    %esi,%edx
  800f77:	f7 74 24 18          	divl   0x18(%esp)
  800f7b:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800f7d:	f7 64 24 0c          	mull   0xc(%esp)
  800f81:	89 c5                	mov    %eax,%ebp
  800f83:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f85:	39 d6                	cmp    %edx,%esi
  800f87:	72 67                	jb     800ff0 <__umoddi3+0x114>
  800f89:	74 75                	je     801000 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800f8b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800f8f:	29 e8                	sub    %ebp,%eax
  800f91:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f93:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f97:	d3 e8                	shr    %cl,%eax
  800f99:	89 f2                	mov    %esi,%edx
  800f9b:	89 f9                	mov    %edi,%ecx
  800f9d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800f9f:	09 d0                	or     %edx,%eax
  800fa1:	89 f2                	mov    %esi,%edx
  800fa3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800fa7:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800fa9:	83 c4 20             	add    $0x20,%esp
  800fac:	5e                   	pop    %esi
  800fad:	5f                   	pop    %edi
  800fae:	5d                   	pop    %ebp
  800faf:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800fb0:	85 c9                	test   %ecx,%ecx
  800fb2:	75 0b                	jne    800fbf <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800fb4:	b8 01 00 00 00       	mov    $0x1,%eax
  800fb9:	31 d2                	xor    %edx,%edx
  800fbb:	f7 f1                	div    %ecx
  800fbd:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800fbf:	89 f0                	mov    %esi,%eax
  800fc1:	31 d2                	xor    %edx,%edx
  800fc3:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800fc5:	89 f8                	mov    %edi,%eax
  800fc7:	e9 3e ff ff ff       	jmp    800f0a <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800fcc:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800fce:	83 c4 20             	add    $0x20,%esp
  800fd1:	5e                   	pop    %esi
  800fd2:	5f                   	pop    %edi
  800fd3:	5d                   	pop    %ebp
  800fd4:	c3                   	ret    
  800fd5:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800fd8:	39 f5                	cmp    %esi,%ebp
  800fda:	72 04                	jb     800fe0 <__umoddi3+0x104>
  800fdc:	39 f9                	cmp    %edi,%ecx
  800fde:	77 06                	ja     800fe6 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800fe0:	89 f2                	mov    %esi,%edx
  800fe2:	29 cf                	sub    %ecx,%edi
  800fe4:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800fe6:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800fe8:	83 c4 20             	add    $0x20,%esp
  800feb:	5e                   	pop    %esi
  800fec:	5f                   	pop    %edi
  800fed:	5d                   	pop    %ebp
  800fee:	c3                   	ret    
  800fef:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800ff0:	89 d1                	mov    %edx,%ecx
  800ff2:	89 c5                	mov    %eax,%ebp
  800ff4:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800ff8:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800ffc:	eb 8d                	jmp    800f8b <__umoddi3+0xaf>
  800ffe:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801000:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801004:	72 ea                	jb     800ff0 <__umoddi3+0x114>
  801006:	89 f1                	mov    %esi,%ecx
  801008:	eb 81                	jmp    800f8b <__umoddi3+0xaf>
