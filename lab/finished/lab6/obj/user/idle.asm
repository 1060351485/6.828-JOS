
obj/user/idle.debug:     file format elf32-i386


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
  80002c:	e8 1b 00 00 00       	call   80004c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
#include <inc/x86.h>
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 08             	sub    $0x8,%esp
	binaryname = "idle";
  80003a:	c7 05 00 20 80 00 80 	movl   $0x801080,0x802000
  800041:	10 80 00 
	// Instead of busy-waiting like this,
	// a better way would be to use the processor's HLT instruction
	// to cause the processor to stop executing until the next interrupt -
	// doing so allows the processor to conserve power more effectively.
	while (1) {
		sys_yield();
  800044:	e8 0d 01 00 00       	call   800156 <sys_yield>
  800049:	eb f9                	jmp    800044 <umain+0x10>
	...

0080004c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004c:	55                   	push   %ebp
  80004d:	89 e5                	mov    %esp,%ebp
  80004f:	56                   	push   %esi
  800050:	53                   	push   %ebx
  800051:	83 ec 10             	sub    $0x10,%esp
  800054:	8b 75 08             	mov    0x8(%ebp),%esi
  800057:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80005a:	e8 d8 00 00 00       	call   800137 <sys_getenvid>
  80005f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800064:	c1 e0 07             	shl    $0x7,%eax
  800067:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006c:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800071:	85 f6                	test   %esi,%esi
  800073:	7e 07                	jle    80007c <libmain+0x30>
		binaryname = argv[0];
  800075:	8b 03                	mov    (%ebx),%eax
  800077:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80007c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800080:	89 34 24             	mov    %esi,(%esp)
  800083:	e8 ac ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800088:	e8 07 00 00 00       	call   800094 <exit>
}
  80008d:	83 c4 10             	add    $0x10,%esp
  800090:	5b                   	pop    %ebx
  800091:	5e                   	pop    %esi
  800092:	5d                   	pop    %ebp
  800093:	c3                   	ret    

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  80009a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a1:	e8 3f 00 00 00       	call   8000e5 <sys_env_destroy>
}
  8000a6:	c9                   	leave  
  8000a7:	c3                   	ret    

008000a8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	57                   	push   %edi
  8000ac:	56                   	push   %esi
  8000ad:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b9:	89 c3                	mov    %eax,%ebx
  8000bb:	89 c7                	mov    %eax,%edi
  8000bd:	89 c6                	mov    %eax,%esi
  8000bf:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c1:	5b                   	pop    %ebx
  8000c2:	5e                   	pop    %esi
  8000c3:	5f                   	pop    %edi
  8000c4:	5d                   	pop    %ebp
  8000c5:	c3                   	ret    

008000c6 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c6:	55                   	push   %ebp
  8000c7:	89 e5                	mov    %esp,%ebp
  8000c9:	57                   	push   %edi
  8000ca:	56                   	push   %esi
  8000cb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d6:	89 d1                	mov    %edx,%ecx
  8000d8:	89 d3                	mov    %edx,%ebx
  8000da:	89 d7                	mov    %edx,%edi
  8000dc:	89 d6                	mov    %edx,%esi
  8000de:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e0:	5b                   	pop    %ebx
  8000e1:	5e                   	pop    %esi
  8000e2:	5f                   	pop    %edi
  8000e3:	5d                   	pop    %ebp
  8000e4:	c3                   	ret    

008000e5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e5:	55                   	push   %ebp
  8000e6:	89 e5                	mov    %esp,%ebp
  8000e8:	57                   	push   %edi
  8000e9:	56                   	push   %esi
  8000ea:	53                   	push   %ebx
  8000eb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ee:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f3:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fb:	89 cb                	mov    %ecx,%ebx
  8000fd:	89 cf                	mov    %ecx,%edi
  8000ff:	89 ce                	mov    %ecx,%esi
  800101:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800103:	85 c0                	test   %eax,%eax
  800105:	7e 28                	jle    80012f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800107:	89 44 24 10          	mov    %eax,0x10(%esp)
  80010b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800112:	00 
  800113:	c7 44 24 08 8f 10 80 	movl   $0x80108f,0x8(%esp)
  80011a:	00 
  80011b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800122:	00 
  800123:	c7 04 24 ac 10 80 00 	movl   $0x8010ac,(%esp)
  80012a:	e8 31 03 00 00       	call   800460 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80012f:	83 c4 2c             	add    $0x2c,%esp
  800132:	5b                   	pop    %ebx
  800133:	5e                   	pop    %esi
  800134:	5f                   	pop    %edi
  800135:	5d                   	pop    %ebp
  800136:	c3                   	ret    

00800137 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800137:	55                   	push   %ebp
  800138:	89 e5                	mov    %esp,%ebp
  80013a:	57                   	push   %edi
  80013b:	56                   	push   %esi
  80013c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80013d:	ba 00 00 00 00       	mov    $0x0,%edx
  800142:	b8 02 00 00 00       	mov    $0x2,%eax
  800147:	89 d1                	mov    %edx,%ecx
  800149:	89 d3                	mov    %edx,%ebx
  80014b:	89 d7                	mov    %edx,%edi
  80014d:	89 d6                	mov    %edx,%esi
  80014f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800151:	5b                   	pop    %ebx
  800152:	5e                   	pop    %esi
  800153:	5f                   	pop    %edi
  800154:	5d                   	pop    %ebp
  800155:	c3                   	ret    

00800156 <sys_yield>:

void
sys_yield(void)
{
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	57                   	push   %edi
  80015a:	56                   	push   %esi
  80015b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80015c:	ba 00 00 00 00       	mov    $0x0,%edx
  800161:	b8 0b 00 00 00       	mov    $0xb,%eax
  800166:	89 d1                	mov    %edx,%ecx
  800168:	89 d3                	mov    %edx,%ebx
  80016a:	89 d7                	mov    %edx,%edi
  80016c:	89 d6                	mov    %edx,%esi
  80016e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800170:	5b                   	pop    %ebx
  800171:	5e                   	pop    %esi
  800172:	5f                   	pop    %edi
  800173:	5d                   	pop    %ebp
  800174:	c3                   	ret    

00800175 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800175:	55                   	push   %ebp
  800176:	89 e5                	mov    %esp,%ebp
  800178:	57                   	push   %edi
  800179:	56                   	push   %esi
  80017a:	53                   	push   %ebx
  80017b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80017e:	be 00 00 00 00       	mov    $0x0,%esi
  800183:	b8 04 00 00 00       	mov    $0x4,%eax
  800188:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80018b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80018e:	8b 55 08             	mov    0x8(%ebp),%edx
  800191:	89 f7                	mov    %esi,%edi
  800193:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800195:	85 c0                	test   %eax,%eax
  800197:	7e 28                	jle    8001c1 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800199:	89 44 24 10          	mov    %eax,0x10(%esp)
  80019d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001a4:	00 
  8001a5:	c7 44 24 08 8f 10 80 	movl   $0x80108f,0x8(%esp)
  8001ac:	00 
  8001ad:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001b4:	00 
  8001b5:	c7 04 24 ac 10 80 00 	movl   $0x8010ac,(%esp)
  8001bc:	e8 9f 02 00 00       	call   800460 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001c1:	83 c4 2c             	add    $0x2c,%esp
  8001c4:	5b                   	pop    %ebx
  8001c5:	5e                   	pop    %esi
  8001c6:	5f                   	pop    %edi
  8001c7:	5d                   	pop    %ebp
  8001c8:	c3                   	ret    

008001c9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c9:	55                   	push   %ebp
  8001ca:	89 e5                	mov    %esp,%ebp
  8001cc:	57                   	push   %edi
  8001cd:	56                   	push   %esi
  8001ce:	53                   	push   %ebx
  8001cf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001d2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001d7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001da:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001dd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001e8:	85 c0                	test   %eax,%eax
  8001ea:	7e 28                	jle    800214 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ec:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001f0:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8001f7:	00 
  8001f8:	c7 44 24 08 8f 10 80 	movl   $0x80108f,0x8(%esp)
  8001ff:	00 
  800200:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800207:	00 
  800208:	c7 04 24 ac 10 80 00 	movl   $0x8010ac,(%esp)
  80020f:	e8 4c 02 00 00       	call   800460 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800214:	83 c4 2c             	add    $0x2c,%esp
  800217:	5b                   	pop    %ebx
  800218:	5e                   	pop    %esi
  800219:	5f                   	pop    %edi
  80021a:	5d                   	pop    %ebp
  80021b:	c3                   	ret    

0080021c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	57                   	push   %edi
  800220:	56                   	push   %esi
  800221:	53                   	push   %ebx
  800222:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800225:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022a:	b8 06 00 00 00       	mov    $0x6,%eax
  80022f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800232:	8b 55 08             	mov    0x8(%ebp),%edx
  800235:	89 df                	mov    %ebx,%edi
  800237:	89 de                	mov    %ebx,%esi
  800239:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80023b:	85 c0                	test   %eax,%eax
  80023d:	7e 28                	jle    800267 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80023f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800243:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80024a:	00 
  80024b:	c7 44 24 08 8f 10 80 	movl   $0x80108f,0x8(%esp)
  800252:	00 
  800253:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80025a:	00 
  80025b:	c7 04 24 ac 10 80 00 	movl   $0x8010ac,(%esp)
  800262:	e8 f9 01 00 00       	call   800460 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800267:	83 c4 2c             	add    $0x2c,%esp
  80026a:	5b                   	pop    %ebx
  80026b:	5e                   	pop    %esi
  80026c:	5f                   	pop    %edi
  80026d:	5d                   	pop    %ebp
  80026e:	c3                   	ret    

0080026f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
  800272:	57                   	push   %edi
  800273:	56                   	push   %esi
  800274:	53                   	push   %ebx
  800275:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800278:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027d:	b8 08 00 00 00       	mov    $0x8,%eax
  800282:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800285:	8b 55 08             	mov    0x8(%ebp),%edx
  800288:	89 df                	mov    %ebx,%edi
  80028a:	89 de                	mov    %ebx,%esi
  80028c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80028e:	85 c0                	test   %eax,%eax
  800290:	7e 28                	jle    8002ba <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800292:	89 44 24 10          	mov    %eax,0x10(%esp)
  800296:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80029d:	00 
  80029e:	c7 44 24 08 8f 10 80 	movl   $0x80108f,0x8(%esp)
  8002a5:	00 
  8002a6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002ad:	00 
  8002ae:	c7 04 24 ac 10 80 00 	movl   $0x8010ac,(%esp)
  8002b5:	e8 a6 01 00 00       	call   800460 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002ba:	83 c4 2c             	add    $0x2c,%esp
  8002bd:	5b                   	pop    %ebx
  8002be:	5e                   	pop    %esi
  8002bf:	5f                   	pop    %edi
  8002c0:	5d                   	pop    %ebp
  8002c1:	c3                   	ret    

008002c2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002c2:	55                   	push   %ebp
  8002c3:	89 e5                	mov    %esp,%ebp
  8002c5:	57                   	push   %edi
  8002c6:	56                   	push   %esi
  8002c7:	53                   	push   %ebx
  8002c8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002cb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002d0:	b8 09 00 00 00       	mov    $0x9,%eax
  8002d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8002db:	89 df                	mov    %ebx,%edi
  8002dd:	89 de                	mov    %ebx,%esi
  8002df:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002e1:	85 c0                	test   %eax,%eax
  8002e3:	7e 28                	jle    80030d <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002e9:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002f0:	00 
  8002f1:	c7 44 24 08 8f 10 80 	movl   $0x80108f,0x8(%esp)
  8002f8:	00 
  8002f9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800300:	00 
  800301:	c7 04 24 ac 10 80 00 	movl   $0x8010ac,(%esp)
  800308:	e8 53 01 00 00       	call   800460 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80030d:	83 c4 2c             	add    $0x2c,%esp
  800310:	5b                   	pop    %ebx
  800311:	5e                   	pop    %esi
  800312:	5f                   	pop    %edi
  800313:	5d                   	pop    %ebp
  800314:	c3                   	ret    

00800315 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800315:	55                   	push   %ebp
  800316:	89 e5                	mov    %esp,%ebp
  800318:	57                   	push   %edi
  800319:	56                   	push   %esi
  80031a:	53                   	push   %ebx
  80031b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80031e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800323:	b8 0a 00 00 00       	mov    $0xa,%eax
  800328:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80032b:	8b 55 08             	mov    0x8(%ebp),%edx
  80032e:	89 df                	mov    %ebx,%edi
  800330:	89 de                	mov    %ebx,%esi
  800332:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800334:	85 c0                	test   %eax,%eax
  800336:	7e 28                	jle    800360 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800338:	89 44 24 10          	mov    %eax,0x10(%esp)
  80033c:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800343:	00 
  800344:	c7 44 24 08 8f 10 80 	movl   $0x80108f,0x8(%esp)
  80034b:	00 
  80034c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800353:	00 
  800354:	c7 04 24 ac 10 80 00 	movl   $0x8010ac,(%esp)
  80035b:	e8 00 01 00 00       	call   800460 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800360:	83 c4 2c             	add    $0x2c,%esp
  800363:	5b                   	pop    %ebx
  800364:	5e                   	pop    %esi
  800365:	5f                   	pop    %edi
  800366:	5d                   	pop    %ebp
  800367:	c3                   	ret    

00800368 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800368:	55                   	push   %ebp
  800369:	89 e5                	mov    %esp,%ebp
  80036b:	57                   	push   %edi
  80036c:	56                   	push   %esi
  80036d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80036e:	be 00 00 00 00       	mov    $0x0,%esi
  800373:	b8 0c 00 00 00       	mov    $0xc,%eax
  800378:	8b 7d 14             	mov    0x14(%ebp),%edi
  80037b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80037e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800381:	8b 55 08             	mov    0x8(%ebp),%edx
  800384:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800386:	5b                   	pop    %ebx
  800387:	5e                   	pop    %esi
  800388:	5f                   	pop    %edi
  800389:	5d                   	pop    %ebp
  80038a:	c3                   	ret    

0080038b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80038b:	55                   	push   %ebp
  80038c:	89 e5                	mov    %esp,%ebp
  80038e:	57                   	push   %edi
  80038f:	56                   	push   %esi
  800390:	53                   	push   %ebx
  800391:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800394:	b9 00 00 00 00       	mov    $0x0,%ecx
  800399:	b8 0d 00 00 00       	mov    $0xd,%eax
  80039e:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a1:	89 cb                	mov    %ecx,%ebx
  8003a3:	89 cf                	mov    %ecx,%edi
  8003a5:	89 ce                	mov    %ecx,%esi
  8003a7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003a9:	85 c0                	test   %eax,%eax
  8003ab:	7e 28                	jle    8003d5 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003ad:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003b1:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003b8:	00 
  8003b9:	c7 44 24 08 8f 10 80 	movl   $0x80108f,0x8(%esp)
  8003c0:	00 
  8003c1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003c8:	00 
  8003c9:	c7 04 24 ac 10 80 00 	movl   $0x8010ac,(%esp)
  8003d0:	e8 8b 00 00 00       	call   800460 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003d5:	83 c4 2c             	add    $0x2c,%esp
  8003d8:	5b                   	pop    %ebx
  8003d9:	5e                   	pop    %esi
  8003da:	5f                   	pop    %edi
  8003db:	5d                   	pop    %ebp
  8003dc:	c3                   	ret    

008003dd <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8003dd:	55                   	push   %ebp
  8003de:	89 e5                	mov    %esp,%ebp
  8003e0:	57                   	push   %edi
  8003e1:	56                   	push   %esi
  8003e2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8003e8:	b8 0e 00 00 00       	mov    $0xe,%eax
  8003ed:	89 d1                	mov    %edx,%ecx
  8003ef:	89 d3                	mov    %edx,%ebx
  8003f1:	89 d7                	mov    %edx,%edi
  8003f3:	89 d6                	mov    %edx,%esi
  8003f5:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8003f7:	5b                   	pop    %ebx
  8003f8:	5e                   	pop    %esi
  8003f9:	5f                   	pop    %edi
  8003fa:	5d                   	pop    %ebp
  8003fb:	c3                   	ret    

008003fc <sys_e1000_transmit>:

int 
sys_e1000_transmit(char* pck, size_t length){
  8003fc:	55                   	push   %ebp
  8003fd:	89 e5                	mov    %esp,%ebp
  8003ff:	57                   	push   %edi
  800400:	56                   	push   %esi
  800401:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800402:	bb 00 00 00 00       	mov    $0x0,%ebx
  800407:	b8 10 00 00 00       	mov    $0x10,%eax
  80040c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80040f:	8b 55 08             	mov    0x8(%ebp),%edx
  800412:	89 df                	mov    %ebx,%edi
  800414:	89 de                	mov    %ebx,%esi
  800416:	cd 30                	int    $0x30
}

int 
sys_e1000_transmit(char* pck, size_t length){
	return syscall(SYS_e1000_transmit, 0, (uint32_t)pck, length, 0, 0, 0);
}
  800418:	5b                   	pop    %ebx
  800419:	5e                   	pop    %esi
  80041a:	5f                   	pop    %edi
  80041b:	5d                   	pop    %ebp
  80041c:	c3                   	ret    

0080041d <sys_e1000_receive>:

int 
sys_e1000_receive(char* pck, size_t* length){
  80041d:	55                   	push   %ebp
  80041e:	89 e5                	mov    %esp,%ebp
  800420:	57                   	push   %edi
  800421:	56                   	push   %esi
  800422:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800423:	bb 00 00 00 00       	mov    $0x0,%ebx
  800428:	b8 0f 00 00 00       	mov    $0xf,%eax
  80042d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800430:	8b 55 08             	mov    0x8(%ebp),%edx
  800433:	89 df                	mov    %ebx,%edi
  800435:	89 de                	mov    %ebx,%esi
  800437:	cd 30                	int    $0x30
}

int 
sys_e1000_receive(char* pck, size_t* length){
	return syscall(SYS_e1000_receive, 0, (uint32_t)pck, (uint32_t)length, 0, 0, 0);
}
  800439:	5b                   	pop    %ebx
  80043a:	5e                   	pop    %esi
  80043b:	5f                   	pop    %edi
  80043c:	5d                   	pop    %ebp
  80043d:	c3                   	ret    

0080043e <sys_e1000_get_mac>:

int 
sys_e1000_get_mac(uint8_t* mac_addr){
  80043e:	55                   	push   %ebp
  80043f:	89 e5                	mov    %esp,%ebp
  800441:	57                   	push   %edi
  800442:	56                   	push   %esi
  800443:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800444:	b9 00 00 00 00       	mov    $0x0,%ecx
  800449:	b8 11 00 00 00       	mov    $0x11,%eax
  80044e:	8b 55 08             	mov    0x8(%ebp),%edx
  800451:	89 cb                	mov    %ecx,%ebx
  800453:	89 cf                	mov    %ecx,%edi
  800455:	89 ce                	mov    %ecx,%esi
  800457:	cd 30                	int    $0x30
}

int 
sys_e1000_get_mac(uint8_t* mac_addr){
	return syscall(SYS_e1000_get_mac, 0, (uint32_t)mac_addr, 0, 0, 0, 0);
}
  800459:	5b                   	pop    %ebx
  80045a:	5e                   	pop    %esi
  80045b:	5f                   	pop    %edi
  80045c:	5d                   	pop    %ebp
  80045d:	c3                   	ret    
	...

00800460 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800460:	55                   	push   %ebp
  800461:	89 e5                	mov    %esp,%ebp
  800463:	56                   	push   %esi
  800464:	53                   	push   %ebx
  800465:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800468:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80046b:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800471:	e8 c1 fc ff ff       	call   800137 <sys_getenvid>
  800476:	8b 55 0c             	mov    0xc(%ebp),%edx
  800479:	89 54 24 10          	mov    %edx,0x10(%esp)
  80047d:	8b 55 08             	mov    0x8(%ebp),%edx
  800480:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800484:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800488:	89 44 24 04          	mov    %eax,0x4(%esp)
  80048c:	c7 04 24 bc 10 80 00 	movl   $0x8010bc,(%esp)
  800493:	e8 c0 00 00 00       	call   800558 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800498:	89 74 24 04          	mov    %esi,0x4(%esp)
  80049c:	8b 45 10             	mov    0x10(%ebp),%eax
  80049f:	89 04 24             	mov    %eax,(%esp)
  8004a2:	e8 50 00 00 00       	call   8004f7 <vcprintf>
	cprintf("\n");
  8004a7:	c7 04 24 df 10 80 00 	movl   $0x8010df,(%esp)
  8004ae:	e8 a5 00 00 00       	call   800558 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004b3:	cc                   	int3   
  8004b4:	eb fd                	jmp    8004b3 <_panic+0x53>
	...

008004b8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004b8:	55                   	push   %ebp
  8004b9:	89 e5                	mov    %esp,%ebp
  8004bb:	53                   	push   %ebx
  8004bc:	83 ec 14             	sub    $0x14,%esp
  8004bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8004c2:	8b 03                	mov    (%ebx),%eax
  8004c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8004c7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8004cb:	40                   	inc    %eax
  8004cc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8004ce:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004d3:	75 19                	jne    8004ee <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8004d5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8004dc:	00 
  8004dd:	8d 43 08             	lea    0x8(%ebx),%eax
  8004e0:	89 04 24             	mov    %eax,(%esp)
  8004e3:	e8 c0 fb ff ff       	call   8000a8 <sys_cputs>
		b->idx = 0;
  8004e8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8004ee:	ff 43 04             	incl   0x4(%ebx)
}
  8004f1:	83 c4 14             	add    $0x14,%esp
  8004f4:	5b                   	pop    %ebx
  8004f5:	5d                   	pop    %ebp
  8004f6:	c3                   	ret    

008004f7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004f7:	55                   	push   %ebp
  8004f8:	89 e5                	mov    %esp,%ebp
  8004fa:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800500:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800507:	00 00 00 
	b.cnt = 0;
  80050a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800511:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800514:	8b 45 0c             	mov    0xc(%ebp),%eax
  800517:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80051b:	8b 45 08             	mov    0x8(%ebp),%eax
  80051e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800522:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800528:	89 44 24 04          	mov    %eax,0x4(%esp)
  80052c:	c7 04 24 b8 04 80 00 	movl   $0x8004b8,(%esp)
  800533:	e8 82 01 00 00       	call   8006ba <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800538:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80053e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800542:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800548:	89 04 24             	mov    %eax,(%esp)
  80054b:	e8 58 fb ff ff       	call   8000a8 <sys_cputs>

	return b.cnt;
}
  800550:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800556:	c9                   	leave  
  800557:	c3                   	ret    

00800558 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800558:	55                   	push   %ebp
  800559:	89 e5                	mov    %esp,%ebp
  80055b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80055e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800561:	89 44 24 04          	mov    %eax,0x4(%esp)
  800565:	8b 45 08             	mov    0x8(%ebp),%eax
  800568:	89 04 24             	mov    %eax,(%esp)
  80056b:	e8 87 ff ff ff       	call   8004f7 <vcprintf>
	va_end(ap);

	return cnt;
}
  800570:	c9                   	leave  
  800571:	c3                   	ret    
	...

00800574 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800574:	55                   	push   %ebp
  800575:	89 e5                	mov    %esp,%ebp
  800577:	57                   	push   %edi
  800578:	56                   	push   %esi
  800579:	53                   	push   %ebx
  80057a:	83 ec 3c             	sub    $0x3c,%esp
  80057d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800580:	89 d7                	mov    %edx,%edi
  800582:	8b 45 08             	mov    0x8(%ebp),%eax
  800585:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800588:	8b 45 0c             	mov    0xc(%ebp),%eax
  80058b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80058e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800591:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800594:	85 c0                	test   %eax,%eax
  800596:	75 08                	jne    8005a0 <printnum+0x2c>
  800598:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80059b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80059e:	77 57                	ja     8005f7 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005a0:	89 74 24 10          	mov    %esi,0x10(%esp)
  8005a4:	4b                   	dec    %ebx
  8005a5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8005a9:	8b 45 10             	mov    0x10(%ebp),%eax
  8005ac:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005b0:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8005b4:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8005b8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005bf:	00 
  8005c0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005c3:	89 04 24             	mov    %eax,(%esp)
  8005c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005cd:	e8 56 08 00 00       	call   800e28 <__udivdi3>
  8005d2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005d6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8005da:	89 04 24             	mov    %eax,(%esp)
  8005dd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005e1:	89 fa                	mov    %edi,%edx
  8005e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005e6:	e8 89 ff ff ff       	call   800574 <printnum>
  8005eb:	eb 0f                	jmp    8005fc <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8005ed:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005f1:	89 34 24             	mov    %esi,(%esp)
  8005f4:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005f7:	4b                   	dec    %ebx
  8005f8:	85 db                	test   %ebx,%ebx
  8005fa:	7f f1                	jg     8005ed <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8005fc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800600:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800604:	8b 45 10             	mov    0x10(%ebp),%eax
  800607:	89 44 24 08          	mov    %eax,0x8(%esp)
  80060b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800612:	00 
  800613:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800616:	89 04 24             	mov    %eax,(%esp)
  800619:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80061c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800620:	e8 23 09 00 00       	call   800f48 <__umoddi3>
  800625:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800629:	0f be 80 e1 10 80 00 	movsbl 0x8010e1(%eax),%eax
  800630:	89 04 24             	mov    %eax,(%esp)
  800633:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800636:	83 c4 3c             	add    $0x3c,%esp
  800639:	5b                   	pop    %ebx
  80063a:	5e                   	pop    %esi
  80063b:	5f                   	pop    %edi
  80063c:	5d                   	pop    %ebp
  80063d:	c3                   	ret    

0080063e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80063e:	55                   	push   %ebp
  80063f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800641:	83 fa 01             	cmp    $0x1,%edx
  800644:	7e 0e                	jle    800654 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800646:	8b 10                	mov    (%eax),%edx
  800648:	8d 4a 08             	lea    0x8(%edx),%ecx
  80064b:	89 08                	mov    %ecx,(%eax)
  80064d:	8b 02                	mov    (%edx),%eax
  80064f:	8b 52 04             	mov    0x4(%edx),%edx
  800652:	eb 22                	jmp    800676 <getuint+0x38>
	else if (lflag)
  800654:	85 d2                	test   %edx,%edx
  800656:	74 10                	je     800668 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800658:	8b 10                	mov    (%eax),%edx
  80065a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80065d:	89 08                	mov    %ecx,(%eax)
  80065f:	8b 02                	mov    (%edx),%eax
  800661:	ba 00 00 00 00       	mov    $0x0,%edx
  800666:	eb 0e                	jmp    800676 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800668:	8b 10                	mov    (%eax),%edx
  80066a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80066d:	89 08                	mov    %ecx,(%eax)
  80066f:	8b 02                	mov    (%edx),%eax
  800671:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800676:	5d                   	pop    %ebp
  800677:	c3                   	ret    

00800678 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800678:	55                   	push   %ebp
  800679:	89 e5                	mov    %esp,%ebp
  80067b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80067e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800681:	8b 10                	mov    (%eax),%edx
  800683:	3b 50 04             	cmp    0x4(%eax),%edx
  800686:	73 08                	jae    800690 <sprintputch+0x18>
		*b->buf++ = ch;
  800688:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80068b:	88 0a                	mov    %cl,(%edx)
  80068d:	42                   	inc    %edx
  80068e:	89 10                	mov    %edx,(%eax)
}
  800690:	5d                   	pop    %ebp
  800691:	c3                   	ret    

00800692 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800692:	55                   	push   %ebp
  800693:	89 e5                	mov    %esp,%ebp
  800695:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800698:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80069b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80069f:	8b 45 10             	mov    0x10(%ebp),%eax
  8006a2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b0:	89 04 24             	mov    %eax,(%esp)
  8006b3:	e8 02 00 00 00       	call   8006ba <vprintfmt>
	va_end(ap);
}
  8006b8:	c9                   	leave  
  8006b9:	c3                   	ret    

008006ba <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006ba:	55                   	push   %ebp
  8006bb:	89 e5                	mov    %esp,%ebp
  8006bd:	57                   	push   %edi
  8006be:	56                   	push   %esi
  8006bf:	53                   	push   %ebx
  8006c0:	83 ec 4c             	sub    $0x4c,%esp
  8006c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006c6:	8b 75 10             	mov    0x10(%ebp),%esi
  8006c9:	eb 12                	jmp    8006dd <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006cb:	85 c0                	test   %eax,%eax
  8006cd:	0f 84 6b 03 00 00    	je     800a3e <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8006d3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006d7:	89 04 24             	mov    %eax,(%esp)
  8006da:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006dd:	0f b6 06             	movzbl (%esi),%eax
  8006e0:	46                   	inc    %esi
  8006e1:	83 f8 25             	cmp    $0x25,%eax
  8006e4:	75 e5                	jne    8006cb <vprintfmt+0x11>
  8006e6:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8006ea:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8006f1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8006f6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8006fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800702:	eb 26                	jmp    80072a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800704:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800707:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80070b:	eb 1d                	jmp    80072a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800710:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800714:	eb 14                	jmp    80072a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800716:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800719:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800720:	eb 08                	jmp    80072a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800722:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800725:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072a:	0f b6 06             	movzbl (%esi),%eax
  80072d:	8d 56 01             	lea    0x1(%esi),%edx
  800730:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800733:	8a 16                	mov    (%esi),%dl
  800735:	83 ea 23             	sub    $0x23,%edx
  800738:	80 fa 55             	cmp    $0x55,%dl
  80073b:	0f 87 e1 02 00 00    	ja     800a22 <vprintfmt+0x368>
  800741:	0f b6 d2             	movzbl %dl,%edx
  800744:	ff 24 95 20 12 80 00 	jmp    *0x801220(,%edx,4)
  80074b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80074e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800753:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800756:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80075a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80075d:	8d 50 d0             	lea    -0x30(%eax),%edx
  800760:	83 fa 09             	cmp    $0x9,%edx
  800763:	77 2a                	ja     80078f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800765:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800766:	eb eb                	jmp    800753 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800768:	8b 45 14             	mov    0x14(%ebp),%eax
  80076b:	8d 50 04             	lea    0x4(%eax),%edx
  80076e:	89 55 14             	mov    %edx,0x14(%ebp)
  800771:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800773:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800776:	eb 17                	jmp    80078f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800778:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80077c:	78 98                	js     800716 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80077e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800781:	eb a7                	jmp    80072a <vprintfmt+0x70>
  800783:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800786:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80078d:	eb 9b                	jmp    80072a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80078f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800793:	79 95                	jns    80072a <vprintfmt+0x70>
  800795:	eb 8b                	jmp    800722 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800797:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800798:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80079b:	eb 8d                	jmp    80072a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80079d:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a0:	8d 50 04             	lea    0x4(%eax),%edx
  8007a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007aa:	8b 00                	mov    (%eax),%eax
  8007ac:	89 04 24             	mov    %eax,(%esp)
  8007af:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8007b5:	e9 23 ff ff ff       	jmp    8006dd <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8007ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bd:	8d 50 04             	lea    0x4(%eax),%edx
  8007c0:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c3:	8b 00                	mov    (%eax),%eax
  8007c5:	85 c0                	test   %eax,%eax
  8007c7:	79 02                	jns    8007cb <vprintfmt+0x111>
  8007c9:	f7 d8                	neg    %eax
  8007cb:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8007cd:	83 f8 11             	cmp    $0x11,%eax
  8007d0:	7f 0b                	jg     8007dd <vprintfmt+0x123>
  8007d2:	8b 04 85 80 13 80 00 	mov    0x801380(,%eax,4),%eax
  8007d9:	85 c0                	test   %eax,%eax
  8007db:	75 23                	jne    800800 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8007dd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007e1:	c7 44 24 08 f9 10 80 	movl   $0x8010f9,0x8(%esp)
  8007e8:	00 
  8007e9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f0:	89 04 24             	mov    %eax,(%esp)
  8007f3:	e8 9a fe ff ff       	call   800692 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007f8:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8007fb:	e9 dd fe ff ff       	jmp    8006dd <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800800:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800804:	c7 44 24 08 02 11 80 	movl   $0x801102,0x8(%esp)
  80080b:	00 
  80080c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800810:	8b 55 08             	mov    0x8(%ebp),%edx
  800813:	89 14 24             	mov    %edx,(%esp)
  800816:	e8 77 fe ff ff       	call   800692 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80081b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80081e:	e9 ba fe ff ff       	jmp    8006dd <vprintfmt+0x23>
  800823:	89 f9                	mov    %edi,%ecx
  800825:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800828:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80082b:	8b 45 14             	mov    0x14(%ebp),%eax
  80082e:	8d 50 04             	lea    0x4(%eax),%edx
  800831:	89 55 14             	mov    %edx,0x14(%ebp)
  800834:	8b 30                	mov    (%eax),%esi
  800836:	85 f6                	test   %esi,%esi
  800838:	75 05                	jne    80083f <vprintfmt+0x185>
				p = "(null)";
  80083a:	be f2 10 80 00       	mov    $0x8010f2,%esi
			if (width > 0 && padc != '-')
  80083f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800843:	0f 8e 84 00 00 00    	jle    8008cd <vprintfmt+0x213>
  800849:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80084d:	74 7e                	je     8008cd <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80084f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800853:	89 34 24             	mov    %esi,(%esp)
  800856:	e8 8b 02 00 00       	call   800ae6 <strnlen>
  80085b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80085e:	29 c2                	sub    %eax,%edx
  800860:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800863:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800867:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80086a:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80086d:	89 de                	mov    %ebx,%esi
  80086f:	89 d3                	mov    %edx,%ebx
  800871:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800873:	eb 0b                	jmp    800880 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800875:	89 74 24 04          	mov    %esi,0x4(%esp)
  800879:	89 3c 24             	mov    %edi,(%esp)
  80087c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80087f:	4b                   	dec    %ebx
  800880:	85 db                	test   %ebx,%ebx
  800882:	7f f1                	jg     800875 <vprintfmt+0x1bb>
  800884:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800887:	89 f3                	mov    %esi,%ebx
  800889:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80088c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80088f:	85 c0                	test   %eax,%eax
  800891:	79 05                	jns    800898 <vprintfmt+0x1de>
  800893:	b8 00 00 00 00       	mov    $0x0,%eax
  800898:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80089b:	29 c2                	sub    %eax,%edx
  80089d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8008a0:	eb 2b                	jmp    8008cd <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008a2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8008a6:	74 18                	je     8008c0 <vprintfmt+0x206>
  8008a8:	8d 50 e0             	lea    -0x20(%eax),%edx
  8008ab:	83 fa 5e             	cmp    $0x5e,%edx
  8008ae:	76 10                	jbe    8008c0 <vprintfmt+0x206>
					putch('?', putdat);
  8008b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008b4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8008bb:	ff 55 08             	call   *0x8(%ebp)
  8008be:	eb 0a                	jmp    8008ca <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8008c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008c4:	89 04 24             	mov    %eax,(%esp)
  8008c7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008ca:	ff 4d e4             	decl   -0x1c(%ebp)
  8008cd:	0f be 06             	movsbl (%esi),%eax
  8008d0:	46                   	inc    %esi
  8008d1:	85 c0                	test   %eax,%eax
  8008d3:	74 21                	je     8008f6 <vprintfmt+0x23c>
  8008d5:	85 ff                	test   %edi,%edi
  8008d7:	78 c9                	js     8008a2 <vprintfmt+0x1e8>
  8008d9:	4f                   	dec    %edi
  8008da:	79 c6                	jns    8008a2 <vprintfmt+0x1e8>
  8008dc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008df:	89 de                	mov    %ebx,%esi
  8008e1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8008e4:	eb 18                	jmp    8008fe <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8008e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008ea:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8008f1:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8008f3:	4b                   	dec    %ebx
  8008f4:	eb 08                	jmp    8008fe <vprintfmt+0x244>
  8008f6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008f9:	89 de                	mov    %ebx,%esi
  8008fb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8008fe:	85 db                	test   %ebx,%ebx
  800900:	7f e4                	jg     8008e6 <vprintfmt+0x22c>
  800902:	89 7d 08             	mov    %edi,0x8(%ebp)
  800905:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800907:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80090a:	e9 ce fd ff ff       	jmp    8006dd <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80090f:	83 f9 01             	cmp    $0x1,%ecx
  800912:	7e 10                	jle    800924 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800914:	8b 45 14             	mov    0x14(%ebp),%eax
  800917:	8d 50 08             	lea    0x8(%eax),%edx
  80091a:	89 55 14             	mov    %edx,0x14(%ebp)
  80091d:	8b 30                	mov    (%eax),%esi
  80091f:	8b 78 04             	mov    0x4(%eax),%edi
  800922:	eb 26                	jmp    80094a <vprintfmt+0x290>
	else if (lflag)
  800924:	85 c9                	test   %ecx,%ecx
  800926:	74 12                	je     80093a <vprintfmt+0x280>
		return va_arg(*ap, long);
  800928:	8b 45 14             	mov    0x14(%ebp),%eax
  80092b:	8d 50 04             	lea    0x4(%eax),%edx
  80092e:	89 55 14             	mov    %edx,0x14(%ebp)
  800931:	8b 30                	mov    (%eax),%esi
  800933:	89 f7                	mov    %esi,%edi
  800935:	c1 ff 1f             	sar    $0x1f,%edi
  800938:	eb 10                	jmp    80094a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80093a:	8b 45 14             	mov    0x14(%ebp),%eax
  80093d:	8d 50 04             	lea    0x4(%eax),%edx
  800940:	89 55 14             	mov    %edx,0x14(%ebp)
  800943:	8b 30                	mov    (%eax),%esi
  800945:	89 f7                	mov    %esi,%edi
  800947:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80094a:	85 ff                	test   %edi,%edi
  80094c:	78 0a                	js     800958 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80094e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800953:	e9 8c 00 00 00       	jmp    8009e4 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800958:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80095c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800963:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800966:	f7 de                	neg    %esi
  800968:	83 d7 00             	adc    $0x0,%edi
  80096b:	f7 df                	neg    %edi
			}
			base = 10;
  80096d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800972:	eb 70                	jmp    8009e4 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800974:	89 ca                	mov    %ecx,%edx
  800976:	8d 45 14             	lea    0x14(%ebp),%eax
  800979:	e8 c0 fc ff ff       	call   80063e <getuint>
  80097e:	89 c6                	mov    %eax,%esi
  800980:	89 d7                	mov    %edx,%edi
			base = 10;
  800982:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800987:	eb 5b                	jmp    8009e4 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  800989:	89 ca                	mov    %ecx,%edx
  80098b:	8d 45 14             	lea    0x14(%ebp),%eax
  80098e:	e8 ab fc ff ff       	call   80063e <getuint>
  800993:	89 c6                	mov    %eax,%esi
  800995:	89 d7                	mov    %edx,%edi
			base = 8;
  800997:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80099c:	eb 46                	jmp    8009e4 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  80099e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009a2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8009a9:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8009ac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009b0:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8009b7:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8009ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8009bd:	8d 50 04             	lea    0x4(%eax),%edx
  8009c0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8009c3:	8b 30                	mov    (%eax),%esi
  8009c5:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8009ca:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8009cf:	eb 13                	jmp    8009e4 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8009d1:	89 ca                	mov    %ecx,%edx
  8009d3:	8d 45 14             	lea    0x14(%ebp),%eax
  8009d6:	e8 63 fc ff ff       	call   80063e <getuint>
  8009db:	89 c6                	mov    %eax,%esi
  8009dd:	89 d7                	mov    %edx,%edi
			base = 16;
  8009df:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8009e4:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8009e8:	89 54 24 10          	mov    %edx,0x10(%esp)
  8009ec:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8009ef:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8009f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009f7:	89 34 24             	mov    %esi,(%esp)
  8009fa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009fe:	89 da                	mov    %ebx,%edx
  800a00:	8b 45 08             	mov    0x8(%ebp),%eax
  800a03:	e8 6c fb ff ff       	call   800574 <printnum>
			break;
  800a08:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800a0b:	e9 cd fc ff ff       	jmp    8006dd <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a10:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a14:	89 04 24             	mov    %eax,(%esp)
  800a17:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a1a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a1d:	e9 bb fc ff ff       	jmp    8006dd <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a22:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a26:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a2d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a30:	eb 01                	jmp    800a33 <vprintfmt+0x379>
  800a32:	4e                   	dec    %esi
  800a33:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800a37:	75 f9                	jne    800a32 <vprintfmt+0x378>
  800a39:	e9 9f fc ff ff       	jmp    8006dd <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800a3e:	83 c4 4c             	add    $0x4c,%esp
  800a41:	5b                   	pop    %ebx
  800a42:	5e                   	pop    %esi
  800a43:	5f                   	pop    %edi
  800a44:	5d                   	pop    %ebp
  800a45:	c3                   	ret    

00800a46 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	83 ec 28             	sub    $0x28,%esp
  800a4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a52:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a55:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a59:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a5c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a63:	85 c0                	test   %eax,%eax
  800a65:	74 30                	je     800a97 <vsnprintf+0x51>
  800a67:	85 d2                	test   %edx,%edx
  800a69:	7e 33                	jle    800a9e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a6b:	8b 45 14             	mov    0x14(%ebp),%eax
  800a6e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a72:	8b 45 10             	mov    0x10(%ebp),%eax
  800a75:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a79:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a7c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a80:	c7 04 24 78 06 80 00 	movl   $0x800678,(%esp)
  800a87:	e8 2e fc ff ff       	call   8006ba <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a8c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a8f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a95:	eb 0c                	jmp    800aa3 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a97:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a9c:	eb 05                	jmp    800aa3 <vsnprintf+0x5d>
  800a9e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800aa3:	c9                   	leave  
  800aa4:	c3                   	ret    

00800aa5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800aa5:	55                   	push   %ebp
  800aa6:	89 e5                	mov    %esp,%ebp
  800aa8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800aab:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800aae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ab2:	8b 45 10             	mov    0x10(%ebp),%eax
  800ab5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ab9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800abc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ac0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac3:	89 04 24             	mov    %eax,(%esp)
  800ac6:	e8 7b ff ff ff       	call   800a46 <vsnprintf>
	va_end(ap);

	return rc;
}
  800acb:	c9                   	leave  
  800acc:	c3                   	ret    
  800acd:	00 00                	add    %al,(%eax)
	...

00800ad0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ad0:	55                   	push   %ebp
  800ad1:	89 e5                	mov    %esp,%ebp
  800ad3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ad6:	b8 00 00 00 00       	mov    $0x0,%eax
  800adb:	eb 01                	jmp    800ade <strlen+0xe>
		n++;
  800add:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800ade:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ae2:	75 f9                	jne    800add <strlen+0xd>
		n++;
	return n;
}
  800ae4:	5d                   	pop    %ebp
  800ae5:	c3                   	ret    

00800ae6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
  800ae9:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800aec:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800aef:	b8 00 00 00 00       	mov    $0x0,%eax
  800af4:	eb 01                	jmp    800af7 <strnlen+0x11>
		n++;
  800af6:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800af7:	39 d0                	cmp    %edx,%eax
  800af9:	74 06                	je     800b01 <strnlen+0x1b>
  800afb:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800aff:	75 f5                	jne    800af6 <strnlen+0x10>
		n++;
	return n;
}
  800b01:	5d                   	pop    %ebp
  800b02:	c3                   	ret    

00800b03 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b03:	55                   	push   %ebp
  800b04:	89 e5                	mov    %esp,%ebp
  800b06:	53                   	push   %ebx
  800b07:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b0d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b12:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800b15:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800b18:	42                   	inc    %edx
  800b19:	84 c9                	test   %cl,%cl
  800b1b:	75 f5                	jne    800b12 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800b1d:	5b                   	pop    %ebx
  800b1e:	5d                   	pop    %ebp
  800b1f:	c3                   	ret    

00800b20 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	53                   	push   %ebx
  800b24:	83 ec 08             	sub    $0x8,%esp
  800b27:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b2a:	89 1c 24             	mov    %ebx,(%esp)
  800b2d:	e8 9e ff ff ff       	call   800ad0 <strlen>
	strcpy(dst + len, src);
  800b32:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b35:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b39:	01 d8                	add    %ebx,%eax
  800b3b:	89 04 24             	mov    %eax,(%esp)
  800b3e:	e8 c0 ff ff ff       	call   800b03 <strcpy>
	return dst;
}
  800b43:	89 d8                	mov    %ebx,%eax
  800b45:	83 c4 08             	add    $0x8,%esp
  800b48:	5b                   	pop    %ebx
  800b49:	5d                   	pop    %ebp
  800b4a:	c3                   	ret    

00800b4b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b4b:	55                   	push   %ebp
  800b4c:	89 e5                	mov    %esp,%ebp
  800b4e:	56                   	push   %esi
  800b4f:	53                   	push   %ebx
  800b50:	8b 45 08             	mov    0x8(%ebp),%eax
  800b53:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b56:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b59:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b5e:	eb 0c                	jmp    800b6c <strncpy+0x21>
		*dst++ = *src;
  800b60:	8a 1a                	mov    (%edx),%bl
  800b62:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b65:	80 3a 01             	cmpb   $0x1,(%edx)
  800b68:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b6b:	41                   	inc    %ecx
  800b6c:	39 f1                	cmp    %esi,%ecx
  800b6e:	75 f0                	jne    800b60 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b70:	5b                   	pop    %ebx
  800b71:	5e                   	pop    %esi
  800b72:	5d                   	pop    %ebp
  800b73:	c3                   	ret    

00800b74 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b74:	55                   	push   %ebp
  800b75:	89 e5                	mov    %esp,%ebp
  800b77:	56                   	push   %esi
  800b78:	53                   	push   %ebx
  800b79:	8b 75 08             	mov    0x8(%ebp),%esi
  800b7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b7f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b82:	85 d2                	test   %edx,%edx
  800b84:	75 0a                	jne    800b90 <strlcpy+0x1c>
  800b86:	89 f0                	mov    %esi,%eax
  800b88:	eb 1a                	jmp    800ba4 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b8a:	88 18                	mov    %bl,(%eax)
  800b8c:	40                   	inc    %eax
  800b8d:	41                   	inc    %ecx
  800b8e:	eb 02                	jmp    800b92 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b90:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800b92:	4a                   	dec    %edx
  800b93:	74 0a                	je     800b9f <strlcpy+0x2b>
  800b95:	8a 19                	mov    (%ecx),%bl
  800b97:	84 db                	test   %bl,%bl
  800b99:	75 ef                	jne    800b8a <strlcpy+0x16>
  800b9b:	89 c2                	mov    %eax,%edx
  800b9d:	eb 02                	jmp    800ba1 <strlcpy+0x2d>
  800b9f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800ba1:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800ba4:	29 f0                	sub    %esi,%eax
}
  800ba6:	5b                   	pop    %ebx
  800ba7:	5e                   	pop    %esi
  800ba8:	5d                   	pop    %ebp
  800ba9:	c3                   	ret    

00800baa <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800baa:	55                   	push   %ebp
  800bab:	89 e5                	mov    %esp,%ebp
  800bad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bb0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bb3:	eb 02                	jmp    800bb7 <strcmp+0xd>
		p++, q++;
  800bb5:	41                   	inc    %ecx
  800bb6:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800bb7:	8a 01                	mov    (%ecx),%al
  800bb9:	84 c0                	test   %al,%al
  800bbb:	74 04                	je     800bc1 <strcmp+0x17>
  800bbd:	3a 02                	cmp    (%edx),%al
  800bbf:	74 f4                	je     800bb5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800bc1:	0f b6 c0             	movzbl %al,%eax
  800bc4:	0f b6 12             	movzbl (%edx),%edx
  800bc7:	29 d0                	sub    %edx,%eax
}
  800bc9:	5d                   	pop    %ebp
  800bca:	c3                   	ret    

00800bcb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	53                   	push   %ebx
  800bcf:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800bd8:	eb 03                	jmp    800bdd <strncmp+0x12>
		n--, p++, q++;
  800bda:	4a                   	dec    %edx
  800bdb:	40                   	inc    %eax
  800bdc:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800bdd:	85 d2                	test   %edx,%edx
  800bdf:	74 14                	je     800bf5 <strncmp+0x2a>
  800be1:	8a 18                	mov    (%eax),%bl
  800be3:	84 db                	test   %bl,%bl
  800be5:	74 04                	je     800beb <strncmp+0x20>
  800be7:	3a 19                	cmp    (%ecx),%bl
  800be9:	74 ef                	je     800bda <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800beb:	0f b6 00             	movzbl (%eax),%eax
  800bee:	0f b6 11             	movzbl (%ecx),%edx
  800bf1:	29 d0                	sub    %edx,%eax
  800bf3:	eb 05                	jmp    800bfa <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800bf5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800bfa:	5b                   	pop    %ebx
  800bfb:	5d                   	pop    %ebp
  800bfc:	c3                   	ret    

00800bfd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800bfd:	55                   	push   %ebp
  800bfe:	89 e5                	mov    %esp,%ebp
  800c00:	8b 45 08             	mov    0x8(%ebp),%eax
  800c03:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800c06:	eb 05                	jmp    800c0d <strchr+0x10>
		if (*s == c)
  800c08:	38 ca                	cmp    %cl,%dl
  800c0a:	74 0c                	je     800c18 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c0c:	40                   	inc    %eax
  800c0d:	8a 10                	mov    (%eax),%dl
  800c0f:	84 d2                	test   %dl,%dl
  800c11:	75 f5                	jne    800c08 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800c13:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c18:	5d                   	pop    %ebp
  800c19:	c3                   	ret    

00800c1a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c1a:	55                   	push   %ebp
  800c1b:	89 e5                	mov    %esp,%ebp
  800c1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c20:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800c23:	eb 05                	jmp    800c2a <strfind+0x10>
		if (*s == c)
  800c25:	38 ca                	cmp    %cl,%dl
  800c27:	74 07                	je     800c30 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c29:	40                   	inc    %eax
  800c2a:	8a 10                	mov    (%eax),%dl
  800c2c:	84 d2                	test   %dl,%dl
  800c2e:	75 f5                	jne    800c25 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800c30:	5d                   	pop    %ebp
  800c31:	c3                   	ret    

00800c32 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c32:	55                   	push   %ebp
  800c33:	89 e5                	mov    %esp,%ebp
  800c35:	57                   	push   %edi
  800c36:	56                   	push   %esi
  800c37:	53                   	push   %ebx
  800c38:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c3e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c41:	85 c9                	test   %ecx,%ecx
  800c43:	74 30                	je     800c75 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c45:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c4b:	75 25                	jne    800c72 <memset+0x40>
  800c4d:	f6 c1 03             	test   $0x3,%cl
  800c50:	75 20                	jne    800c72 <memset+0x40>
		c &= 0xFF;
  800c52:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c55:	89 d3                	mov    %edx,%ebx
  800c57:	c1 e3 08             	shl    $0x8,%ebx
  800c5a:	89 d6                	mov    %edx,%esi
  800c5c:	c1 e6 18             	shl    $0x18,%esi
  800c5f:	89 d0                	mov    %edx,%eax
  800c61:	c1 e0 10             	shl    $0x10,%eax
  800c64:	09 f0                	or     %esi,%eax
  800c66:	09 d0                	or     %edx,%eax
  800c68:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c6a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800c6d:	fc                   	cld    
  800c6e:	f3 ab                	rep stos %eax,%es:(%edi)
  800c70:	eb 03                	jmp    800c75 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c72:	fc                   	cld    
  800c73:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c75:	89 f8                	mov    %edi,%eax
  800c77:	5b                   	pop    %ebx
  800c78:	5e                   	pop    %esi
  800c79:	5f                   	pop    %edi
  800c7a:	5d                   	pop    %ebp
  800c7b:	c3                   	ret    

00800c7c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c7c:	55                   	push   %ebp
  800c7d:	89 e5                	mov    %esp,%ebp
  800c7f:	57                   	push   %edi
  800c80:	56                   	push   %esi
  800c81:	8b 45 08             	mov    0x8(%ebp),%eax
  800c84:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c87:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c8a:	39 c6                	cmp    %eax,%esi
  800c8c:	73 34                	jae    800cc2 <memmove+0x46>
  800c8e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c91:	39 d0                	cmp    %edx,%eax
  800c93:	73 2d                	jae    800cc2 <memmove+0x46>
		s += n;
		d += n;
  800c95:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c98:	f6 c2 03             	test   $0x3,%dl
  800c9b:	75 1b                	jne    800cb8 <memmove+0x3c>
  800c9d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ca3:	75 13                	jne    800cb8 <memmove+0x3c>
  800ca5:	f6 c1 03             	test   $0x3,%cl
  800ca8:	75 0e                	jne    800cb8 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800caa:	83 ef 04             	sub    $0x4,%edi
  800cad:	8d 72 fc             	lea    -0x4(%edx),%esi
  800cb0:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800cb3:	fd                   	std    
  800cb4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cb6:	eb 07                	jmp    800cbf <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800cb8:	4f                   	dec    %edi
  800cb9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800cbc:	fd                   	std    
  800cbd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800cbf:	fc                   	cld    
  800cc0:	eb 20                	jmp    800ce2 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cc2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cc8:	75 13                	jne    800cdd <memmove+0x61>
  800cca:	a8 03                	test   $0x3,%al
  800ccc:	75 0f                	jne    800cdd <memmove+0x61>
  800cce:	f6 c1 03             	test   $0x3,%cl
  800cd1:	75 0a                	jne    800cdd <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800cd3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800cd6:	89 c7                	mov    %eax,%edi
  800cd8:	fc                   	cld    
  800cd9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cdb:	eb 05                	jmp    800ce2 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800cdd:	89 c7                	mov    %eax,%edi
  800cdf:	fc                   	cld    
  800ce0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ce2:	5e                   	pop    %esi
  800ce3:	5f                   	pop    %edi
  800ce4:	5d                   	pop    %ebp
  800ce5:	c3                   	ret    

00800ce6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ce6:	55                   	push   %ebp
  800ce7:	89 e5                	mov    %esp,%ebp
  800ce9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800cec:	8b 45 10             	mov    0x10(%ebp),%eax
  800cef:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cf3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cf6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cfa:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfd:	89 04 24             	mov    %eax,(%esp)
  800d00:	e8 77 ff ff ff       	call   800c7c <memmove>
}
  800d05:	c9                   	leave  
  800d06:	c3                   	ret    

00800d07 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d07:	55                   	push   %ebp
  800d08:	89 e5                	mov    %esp,%ebp
  800d0a:	57                   	push   %edi
  800d0b:	56                   	push   %esi
  800d0c:	53                   	push   %ebx
  800d0d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d10:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d13:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d16:	ba 00 00 00 00       	mov    $0x0,%edx
  800d1b:	eb 16                	jmp    800d33 <memcmp+0x2c>
		if (*s1 != *s2)
  800d1d:	8a 04 17             	mov    (%edi,%edx,1),%al
  800d20:	42                   	inc    %edx
  800d21:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800d25:	38 c8                	cmp    %cl,%al
  800d27:	74 0a                	je     800d33 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800d29:	0f b6 c0             	movzbl %al,%eax
  800d2c:	0f b6 c9             	movzbl %cl,%ecx
  800d2f:	29 c8                	sub    %ecx,%eax
  800d31:	eb 09                	jmp    800d3c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d33:	39 da                	cmp    %ebx,%edx
  800d35:	75 e6                	jne    800d1d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d37:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d3c:	5b                   	pop    %ebx
  800d3d:	5e                   	pop    %esi
  800d3e:	5f                   	pop    %edi
  800d3f:	5d                   	pop    %ebp
  800d40:	c3                   	ret    

00800d41 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d41:	55                   	push   %ebp
  800d42:	89 e5                	mov    %esp,%ebp
  800d44:	8b 45 08             	mov    0x8(%ebp),%eax
  800d47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800d4a:	89 c2                	mov    %eax,%edx
  800d4c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d4f:	eb 05                	jmp    800d56 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d51:	38 08                	cmp    %cl,(%eax)
  800d53:	74 05                	je     800d5a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d55:	40                   	inc    %eax
  800d56:	39 d0                	cmp    %edx,%eax
  800d58:	72 f7                	jb     800d51 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d5a:	5d                   	pop    %ebp
  800d5b:	c3                   	ret    

00800d5c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d5c:	55                   	push   %ebp
  800d5d:	89 e5                	mov    %esp,%ebp
  800d5f:	57                   	push   %edi
  800d60:	56                   	push   %esi
  800d61:	53                   	push   %ebx
  800d62:	8b 55 08             	mov    0x8(%ebp),%edx
  800d65:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d68:	eb 01                	jmp    800d6b <strtol+0xf>
		s++;
  800d6a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d6b:	8a 02                	mov    (%edx),%al
  800d6d:	3c 20                	cmp    $0x20,%al
  800d6f:	74 f9                	je     800d6a <strtol+0xe>
  800d71:	3c 09                	cmp    $0x9,%al
  800d73:	74 f5                	je     800d6a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d75:	3c 2b                	cmp    $0x2b,%al
  800d77:	75 08                	jne    800d81 <strtol+0x25>
		s++;
  800d79:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d7a:	bf 00 00 00 00       	mov    $0x0,%edi
  800d7f:	eb 13                	jmp    800d94 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d81:	3c 2d                	cmp    $0x2d,%al
  800d83:	75 0a                	jne    800d8f <strtol+0x33>
		s++, neg = 1;
  800d85:	8d 52 01             	lea    0x1(%edx),%edx
  800d88:	bf 01 00 00 00       	mov    $0x1,%edi
  800d8d:	eb 05                	jmp    800d94 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d8f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d94:	85 db                	test   %ebx,%ebx
  800d96:	74 05                	je     800d9d <strtol+0x41>
  800d98:	83 fb 10             	cmp    $0x10,%ebx
  800d9b:	75 28                	jne    800dc5 <strtol+0x69>
  800d9d:	8a 02                	mov    (%edx),%al
  800d9f:	3c 30                	cmp    $0x30,%al
  800da1:	75 10                	jne    800db3 <strtol+0x57>
  800da3:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800da7:	75 0a                	jne    800db3 <strtol+0x57>
		s += 2, base = 16;
  800da9:	83 c2 02             	add    $0x2,%edx
  800dac:	bb 10 00 00 00       	mov    $0x10,%ebx
  800db1:	eb 12                	jmp    800dc5 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800db3:	85 db                	test   %ebx,%ebx
  800db5:	75 0e                	jne    800dc5 <strtol+0x69>
  800db7:	3c 30                	cmp    $0x30,%al
  800db9:	75 05                	jne    800dc0 <strtol+0x64>
		s++, base = 8;
  800dbb:	42                   	inc    %edx
  800dbc:	b3 08                	mov    $0x8,%bl
  800dbe:	eb 05                	jmp    800dc5 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800dc0:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800dc5:	b8 00 00 00 00       	mov    $0x0,%eax
  800dca:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800dcc:	8a 0a                	mov    (%edx),%cl
  800dce:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800dd1:	80 fb 09             	cmp    $0x9,%bl
  800dd4:	77 08                	ja     800dde <strtol+0x82>
			dig = *s - '0';
  800dd6:	0f be c9             	movsbl %cl,%ecx
  800dd9:	83 e9 30             	sub    $0x30,%ecx
  800ddc:	eb 1e                	jmp    800dfc <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800dde:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800de1:	80 fb 19             	cmp    $0x19,%bl
  800de4:	77 08                	ja     800dee <strtol+0x92>
			dig = *s - 'a' + 10;
  800de6:	0f be c9             	movsbl %cl,%ecx
  800de9:	83 e9 57             	sub    $0x57,%ecx
  800dec:	eb 0e                	jmp    800dfc <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800dee:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800df1:	80 fb 19             	cmp    $0x19,%bl
  800df4:	77 12                	ja     800e08 <strtol+0xac>
			dig = *s - 'A' + 10;
  800df6:	0f be c9             	movsbl %cl,%ecx
  800df9:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800dfc:	39 f1                	cmp    %esi,%ecx
  800dfe:	7d 0c                	jge    800e0c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800e00:	42                   	inc    %edx
  800e01:	0f af c6             	imul   %esi,%eax
  800e04:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800e06:	eb c4                	jmp    800dcc <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800e08:	89 c1                	mov    %eax,%ecx
  800e0a:	eb 02                	jmp    800e0e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800e0c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800e0e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e12:	74 05                	je     800e19 <strtol+0xbd>
		*endptr = (char *) s;
  800e14:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e17:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800e19:	85 ff                	test   %edi,%edi
  800e1b:	74 04                	je     800e21 <strtol+0xc5>
  800e1d:	89 c8                	mov    %ecx,%eax
  800e1f:	f7 d8                	neg    %eax
}
  800e21:	5b                   	pop    %ebx
  800e22:	5e                   	pop    %esi
  800e23:	5f                   	pop    %edi
  800e24:	5d                   	pop    %ebp
  800e25:	c3                   	ret    
	...

00800e28 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800e28:	55                   	push   %ebp
  800e29:	57                   	push   %edi
  800e2a:	56                   	push   %esi
  800e2b:	83 ec 10             	sub    $0x10,%esp
  800e2e:	8b 74 24 20          	mov    0x20(%esp),%esi
  800e32:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800e36:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e3a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  800e3e:	89 cd                	mov    %ecx,%ebp
  800e40:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e44:	85 c0                	test   %eax,%eax
  800e46:	75 2c                	jne    800e74 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800e48:	39 f9                	cmp    %edi,%ecx
  800e4a:	77 68                	ja     800eb4 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800e4c:	85 c9                	test   %ecx,%ecx
  800e4e:	75 0b                	jne    800e5b <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800e50:	b8 01 00 00 00       	mov    $0x1,%eax
  800e55:	31 d2                	xor    %edx,%edx
  800e57:	f7 f1                	div    %ecx
  800e59:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800e5b:	31 d2                	xor    %edx,%edx
  800e5d:	89 f8                	mov    %edi,%eax
  800e5f:	f7 f1                	div    %ecx
  800e61:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e63:	89 f0                	mov    %esi,%eax
  800e65:	f7 f1                	div    %ecx
  800e67:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e69:	89 f0                	mov    %esi,%eax
  800e6b:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e6d:	83 c4 10             	add    $0x10,%esp
  800e70:	5e                   	pop    %esi
  800e71:	5f                   	pop    %edi
  800e72:	5d                   	pop    %ebp
  800e73:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e74:	39 f8                	cmp    %edi,%eax
  800e76:	77 2c                	ja     800ea4 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e78:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  800e7b:	83 f6 1f             	xor    $0x1f,%esi
  800e7e:	75 4c                	jne    800ecc <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e80:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e82:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e87:	72 0a                	jb     800e93 <__udivdi3+0x6b>
  800e89:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800e8d:	0f 87 ad 00 00 00    	ja     800f40 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e93:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e98:	89 f0                	mov    %esi,%eax
  800e9a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e9c:	83 c4 10             	add    $0x10,%esp
  800e9f:	5e                   	pop    %esi
  800ea0:	5f                   	pop    %edi
  800ea1:	5d                   	pop    %ebp
  800ea2:	c3                   	ret    
  800ea3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800ea4:	31 ff                	xor    %edi,%edi
  800ea6:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800ea8:	89 f0                	mov    %esi,%eax
  800eaa:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800eac:	83 c4 10             	add    $0x10,%esp
  800eaf:	5e                   	pop    %esi
  800eb0:	5f                   	pop    %edi
  800eb1:	5d                   	pop    %ebp
  800eb2:	c3                   	ret    
  800eb3:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800eb4:	89 fa                	mov    %edi,%edx
  800eb6:	89 f0                	mov    %esi,%eax
  800eb8:	f7 f1                	div    %ecx
  800eba:	89 c6                	mov    %eax,%esi
  800ebc:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800ebe:	89 f0                	mov    %esi,%eax
  800ec0:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800ec2:	83 c4 10             	add    $0x10,%esp
  800ec5:	5e                   	pop    %esi
  800ec6:	5f                   	pop    %edi
  800ec7:	5d                   	pop    %ebp
  800ec8:	c3                   	ret    
  800ec9:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800ecc:	89 f1                	mov    %esi,%ecx
  800ece:	d3 e0                	shl    %cl,%eax
  800ed0:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800ed4:	b8 20 00 00 00       	mov    $0x20,%eax
  800ed9:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800edb:	89 ea                	mov    %ebp,%edx
  800edd:	88 c1                	mov    %al,%cl
  800edf:	d3 ea                	shr    %cl,%edx
  800ee1:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800ee5:	09 ca                	or     %ecx,%edx
  800ee7:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  800eeb:	89 f1                	mov    %esi,%ecx
  800eed:	d3 e5                	shl    %cl,%ebp
  800eef:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  800ef3:	89 fd                	mov    %edi,%ebp
  800ef5:	88 c1                	mov    %al,%cl
  800ef7:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  800ef9:	89 fa                	mov    %edi,%edx
  800efb:	89 f1                	mov    %esi,%ecx
  800efd:	d3 e2                	shl    %cl,%edx
  800eff:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f03:	88 c1                	mov    %al,%cl
  800f05:	d3 ef                	shr    %cl,%edi
  800f07:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800f09:	89 f8                	mov    %edi,%eax
  800f0b:	89 ea                	mov    %ebp,%edx
  800f0d:	f7 74 24 08          	divl   0x8(%esp)
  800f11:	89 d1                	mov    %edx,%ecx
  800f13:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  800f15:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f19:	39 d1                	cmp    %edx,%ecx
  800f1b:	72 17                	jb     800f34 <__udivdi3+0x10c>
  800f1d:	74 09                	je     800f28 <__udivdi3+0x100>
  800f1f:	89 fe                	mov    %edi,%esi
  800f21:	31 ff                	xor    %edi,%edi
  800f23:	e9 41 ff ff ff       	jmp    800e69 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800f28:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f2c:	89 f1                	mov    %esi,%ecx
  800f2e:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f30:	39 c2                	cmp    %eax,%edx
  800f32:	73 eb                	jae    800f1f <__udivdi3+0xf7>
		{
		  q0--;
  800f34:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f37:	31 ff                	xor    %edi,%edi
  800f39:	e9 2b ff ff ff       	jmp    800e69 <__udivdi3+0x41>
  800f3e:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800f40:	31 f6                	xor    %esi,%esi
  800f42:	e9 22 ff ff ff       	jmp    800e69 <__udivdi3+0x41>
	...

00800f48 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800f48:	55                   	push   %ebp
  800f49:	57                   	push   %edi
  800f4a:	56                   	push   %esi
  800f4b:	83 ec 20             	sub    $0x20,%esp
  800f4e:	8b 44 24 30          	mov    0x30(%esp),%eax
  800f52:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800f56:	89 44 24 14          	mov    %eax,0x14(%esp)
  800f5a:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  800f5e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800f62:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800f66:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  800f68:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800f6a:	85 ed                	test   %ebp,%ebp
  800f6c:	75 16                	jne    800f84 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  800f6e:	39 f1                	cmp    %esi,%ecx
  800f70:	0f 86 a6 00 00 00    	jbe    80101c <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f76:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800f78:	89 d0                	mov    %edx,%eax
  800f7a:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f7c:	83 c4 20             	add    $0x20,%esp
  800f7f:	5e                   	pop    %esi
  800f80:	5f                   	pop    %edi
  800f81:	5d                   	pop    %ebp
  800f82:	c3                   	ret    
  800f83:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800f84:	39 f5                	cmp    %esi,%ebp
  800f86:	0f 87 ac 00 00 00    	ja     801038 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800f8c:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  800f8f:	83 f0 1f             	xor    $0x1f,%eax
  800f92:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f96:	0f 84 a8 00 00 00    	je     801044 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800f9c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800fa0:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800fa2:	bf 20 00 00 00       	mov    $0x20,%edi
  800fa7:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800fab:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800faf:	89 f9                	mov    %edi,%ecx
  800fb1:	d3 e8                	shr    %cl,%eax
  800fb3:	09 e8                	or     %ebp,%eax
  800fb5:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  800fb9:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800fbd:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800fc1:	d3 e0                	shl    %cl,%eax
  800fc3:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800fc7:	89 f2                	mov    %esi,%edx
  800fc9:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800fcb:	8b 44 24 14          	mov    0x14(%esp),%eax
  800fcf:	d3 e0                	shl    %cl,%eax
  800fd1:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800fd5:	8b 44 24 14          	mov    0x14(%esp),%eax
  800fd9:	89 f9                	mov    %edi,%ecx
  800fdb:	d3 e8                	shr    %cl,%eax
  800fdd:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800fdf:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800fe1:	89 f2                	mov    %esi,%edx
  800fe3:	f7 74 24 18          	divl   0x18(%esp)
  800fe7:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800fe9:	f7 64 24 0c          	mull   0xc(%esp)
  800fed:	89 c5                	mov    %eax,%ebp
  800fef:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ff1:	39 d6                	cmp    %edx,%esi
  800ff3:	72 67                	jb     80105c <__umoddi3+0x114>
  800ff5:	74 75                	je     80106c <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800ff7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800ffb:	29 e8                	sub    %ebp,%eax
  800ffd:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800fff:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801003:	d3 e8                	shr    %cl,%eax
  801005:	89 f2                	mov    %esi,%edx
  801007:	89 f9                	mov    %edi,%ecx
  801009:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80100b:	09 d0                	or     %edx,%eax
  80100d:	89 f2                	mov    %esi,%edx
  80100f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801013:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801015:	83 c4 20             	add    $0x20,%esp
  801018:	5e                   	pop    %esi
  801019:	5f                   	pop    %edi
  80101a:	5d                   	pop    %ebp
  80101b:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80101c:	85 c9                	test   %ecx,%ecx
  80101e:	75 0b                	jne    80102b <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801020:	b8 01 00 00 00       	mov    $0x1,%eax
  801025:	31 d2                	xor    %edx,%edx
  801027:	f7 f1                	div    %ecx
  801029:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80102b:	89 f0                	mov    %esi,%eax
  80102d:	31 d2                	xor    %edx,%edx
  80102f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801031:	89 f8                	mov    %edi,%eax
  801033:	e9 3e ff ff ff       	jmp    800f76 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801038:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80103a:	83 c4 20             	add    $0x20,%esp
  80103d:	5e                   	pop    %esi
  80103e:	5f                   	pop    %edi
  80103f:	5d                   	pop    %ebp
  801040:	c3                   	ret    
  801041:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801044:	39 f5                	cmp    %esi,%ebp
  801046:	72 04                	jb     80104c <__umoddi3+0x104>
  801048:	39 f9                	cmp    %edi,%ecx
  80104a:	77 06                	ja     801052 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80104c:	89 f2                	mov    %esi,%edx
  80104e:	29 cf                	sub    %ecx,%edi
  801050:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801052:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801054:	83 c4 20             	add    $0x20,%esp
  801057:	5e                   	pop    %esi
  801058:	5f                   	pop    %edi
  801059:	5d                   	pop    %ebp
  80105a:	c3                   	ret    
  80105b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80105c:	89 d1                	mov    %edx,%ecx
  80105e:	89 c5                	mov    %eax,%ebp
  801060:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801064:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801068:	eb 8d                	jmp    800ff7 <__umoddi3+0xaf>
  80106a:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80106c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801070:	72 ea                	jb     80105c <__umoddi3+0x114>
  801072:	89 f1                	mov    %esi,%ecx
  801074:	eb 81                	jmp    800ff7 <__umoddi3+0xaf>
