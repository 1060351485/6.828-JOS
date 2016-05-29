
obj/user/faultwrite.debug:     file format elf32-i386


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
  80002c:	e8 13 00 00 00       	call   800044 <libmain>
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
	*(unsigned*)0 = 0;
  800037:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80003e:	00 00 00 
}
  800041:	5d                   	pop    %ebp
  800042:	c3                   	ret    
	...

00800044 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800044:	55                   	push   %ebp
  800045:	89 e5                	mov    %esp,%ebp
  800047:	56                   	push   %esi
  800048:	53                   	push   %ebx
  800049:	83 ec 10             	sub    $0x10,%esp
  80004c:	8b 75 08             	mov    0x8(%ebp),%esi
  80004f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800052:	e8 d8 00 00 00       	call   80012f <sys_getenvid>
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	c1 e0 07             	shl    $0x7,%eax
  80005f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800064:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800069:	85 f6                	test   %esi,%esi
  80006b:	7e 07                	jle    800074 <libmain+0x30>
		binaryname = argv[0];
  80006d:	8b 03                	mov    (%ebx),%eax
  80006f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800074:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800078:	89 34 24             	mov    %esi,(%esp)
  80007b:	e8 b4 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800080:	e8 07 00 00 00       	call   80008c <exit>
}
  800085:	83 c4 10             	add    $0x10,%esp
  800088:	5b                   	pop    %ebx
  800089:	5e                   	pop    %esi
  80008a:	5d                   	pop    %ebp
  80008b:	c3                   	ret    

0080008c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008c:	55                   	push   %ebp
  80008d:	89 e5                	mov    %esp,%ebp
  80008f:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  800092:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800099:	e8 3f 00 00 00       	call   8000dd <sys_env_destroy>
}
  80009e:	c9                   	leave  
  80009f:	c3                   	ret    

008000a0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	57                   	push   %edi
  8000a4:	56                   	push   %esi
  8000a5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b1:	89 c3                	mov    %eax,%ebx
  8000b3:	89 c7                	mov    %eax,%edi
  8000b5:	89 c6                	mov    %eax,%esi
  8000b7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b9:	5b                   	pop    %ebx
  8000ba:	5e                   	pop    %esi
  8000bb:	5f                   	pop    %edi
  8000bc:	5d                   	pop    %ebp
  8000bd:	c3                   	ret    

008000be <sys_cgetc>:

int
sys_cgetc(void)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	57                   	push   %edi
  8000c2:	56                   	push   %esi
  8000c3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c9:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ce:	89 d1                	mov    %edx,%ecx
  8000d0:	89 d3                	mov    %edx,%ebx
  8000d2:	89 d7                	mov    %edx,%edi
  8000d4:	89 d6                	mov    %edx,%esi
  8000d6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d8:	5b                   	pop    %ebx
  8000d9:	5e                   	pop    %esi
  8000da:	5f                   	pop    %edi
  8000db:	5d                   	pop    %ebp
  8000dc:	c3                   	ret    

008000dd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000dd:	55                   	push   %ebp
  8000de:	89 e5                	mov    %esp,%ebp
  8000e0:	57                   	push   %edi
  8000e1:	56                   	push   %esi
  8000e2:	53                   	push   %ebx
  8000e3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000eb:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f3:	89 cb                	mov    %ecx,%ebx
  8000f5:	89 cf                	mov    %ecx,%edi
  8000f7:	89 ce                	mov    %ecx,%esi
  8000f9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000fb:	85 c0                	test   %eax,%eax
  8000fd:	7e 28                	jle    800127 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000ff:	89 44 24 10          	mov    %eax,0x10(%esp)
  800103:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80010a:	00 
  80010b:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  800112:	00 
  800113:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80011a:	00 
  80011b:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  800122:	e8 31 03 00 00       	call   800458 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800127:	83 c4 2c             	add    $0x2c,%esp
  80012a:	5b                   	pop    %ebx
  80012b:	5e                   	pop    %esi
  80012c:	5f                   	pop    %edi
  80012d:	5d                   	pop    %ebp
  80012e:	c3                   	ret    

0080012f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012f:	55                   	push   %ebp
  800130:	89 e5                	mov    %esp,%ebp
  800132:	57                   	push   %edi
  800133:	56                   	push   %esi
  800134:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800135:	ba 00 00 00 00       	mov    $0x0,%edx
  80013a:	b8 02 00 00 00       	mov    $0x2,%eax
  80013f:	89 d1                	mov    %edx,%ecx
  800141:	89 d3                	mov    %edx,%ebx
  800143:	89 d7                	mov    %edx,%edi
  800145:	89 d6                	mov    %edx,%esi
  800147:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800149:	5b                   	pop    %ebx
  80014a:	5e                   	pop    %esi
  80014b:	5f                   	pop    %edi
  80014c:	5d                   	pop    %ebp
  80014d:	c3                   	ret    

0080014e <sys_yield>:

void
sys_yield(void)
{
  80014e:	55                   	push   %ebp
  80014f:	89 e5                	mov    %esp,%ebp
  800151:	57                   	push   %edi
  800152:	56                   	push   %esi
  800153:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800154:	ba 00 00 00 00       	mov    $0x0,%edx
  800159:	b8 0b 00 00 00       	mov    $0xb,%eax
  80015e:	89 d1                	mov    %edx,%ecx
  800160:	89 d3                	mov    %edx,%ebx
  800162:	89 d7                	mov    %edx,%edi
  800164:	89 d6                	mov    %edx,%esi
  800166:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800168:	5b                   	pop    %ebx
  800169:	5e                   	pop    %esi
  80016a:	5f                   	pop    %edi
  80016b:	5d                   	pop    %ebp
  80016c:	c3                   	ret    

0080016d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80016d:	55                   	push   %ebp
  80016e:	89 e5                	mov    %esp,%ebp
  800170:	57                   	push   %edi
  800171:	56                   	push   %esi
  800172:	53                   	push   %ebx
  800173:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800176:	be 00 00 00 00       	mov    $0x0,%esi
  80017b:	b8 04 00 00 00       	mov    $0x4,%eax
  800180:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800183:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800186:	8b 55 08             	mov    0x8(%ebp),%edx
  800189:	89 f7                	mov    %esi,%edi
  80018b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80018d:	85 c0                	test   %eax,%eax
  80018f:	7e 28                	jle    8001b9 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800191:	89 44 24 10          	mov    %eax,0x10(%esp)
  800195:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  80019c:	00 
  80019d:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  8001a4:	00 
  8001a5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001ac:	00 
  8001ad:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  8001b4:	e8 9f 02 00 00       	call   800458 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001b9:	83 c4 2c             	add    $0x2c,%esp
  8001bc:	5b                   	pop    %ebx
  8001bd:	5e                   	pop    %esi
  8001be:	5f                   	pop    %edi
  8001bf:	5d                   	pop    %ebp
  8001c0:	c3                   	ret    

008001c1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c1:	55                   	push   %ebp
  8001c2:	89 e5                	mov    %esp,%ebp
  8001c4:	57                   	push   %edi
  8001c5:	56                   	push   %esi
  8001c6:	53                   	push   %ebx
  8001c7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ca:	b8 05 00 00 00       	mov    $0x5,%eax
  8001cf:	8b 75 18             	mov    0x18(%ebp),%esi
  8001d2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001d5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001db:	8b 55 08             	mov    0x8(%ebp),%edx
  8001de:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001e0:	85 c0                	test   %eax,%eax
  8001e2:	7e 28                	jle    80020c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001e8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8001ef:	00 
  8001f0:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  8001f7:	00 
  8001f8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001ff:	00 
  800200:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  800207:	e8 4c 02 00 00       	call   800458 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80020c:	83 c4 2c             	add    $0x2c,%esp
  80020f:	5b                   	pop    %ebx
  800210:	5e                   	pop    %esi
  800211:	5f                   	pop    %edi
  800212:	5d                   	pop    %ebp
  800213:	c3                   	ret    

00800214 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	57                   	push   %edi
  800218:	56                   	push   %esi
  800219:	53                   	push   %ebx
  80021a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80021d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800222:	b8 06 00 00 00       	mov    $0x6,%eax
  800227:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80022a:	8b 55 08             	mov    0x8(%ebp),%edx
  80022d:	89 df                	mov    %ebx,%edi
  80022f:	89 de                	mov    %ebx,%esi
  800231:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800233:	85 c0                	test   %eax,%eax
  800235:	7e 28                	jle    80025f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800237:	89 44 24 10          	mov    %eax,0x10(%esp)
  80023b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800242:	00 
  800243:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  80024a:	00 
  80024b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800252:	00 
  800253:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  80025a:	e8 f9 01 00 00       	call   800458 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80025f:	83 c4 2c             	add    $0x2c,%esp
  800262:	5b                   	pop    %ebx
  800263:	5e                   	pop    %esi
  800264:	5f                   	pop    %edi
  800265:	5d                   	pop    %ebp
  800266:	c3                   	ret    

00800267 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800267:	55                   	push   %ebp
  800268:	89 e5                	mov    %esp,%ebp
  80026a:	57                   	push   %edi
  80026b:	56                   	push   %esi
  80026c:	53                   	push   %ebx
  80026d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800270:	bb 00 00 00 00       	mov    $0x0,%ebx
  800275:	b8 08 00 00 00       	mov    $0x8,%eax
  80027a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027d:	8b 55 08             	mov    0x8(%ebp),%edx
  800280:	89 df                	mov    %ebx,%edi
  800282:	89 de                	mov    %ebx,%esi
  800284:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800286:	85 c0                	test   %eax,%eax
  800288:	7e 28                	jle    8002b2 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80028e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800295:	00 
  800296:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  80029d:	00 
  80029e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002a5:	00 
  8002a6:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  8002ad:	e8 a6 01 00 00       	call   800458 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002b2:	83 c4 2c             	add    $0x2c,%esp
  8002b5:	5b                   	pop    %ebx
  8002b6:	5e                   	pop    %esi
  8002b7:	5f                   	pop    %edi
  8002b8:	5d                   	pop    %ebp
  8002b9:	c3                   	ret    

008002ba <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002ba:	55                   	push   %ebp
  8002bb:	89 e5                	mov    %esp,%ebp
  8002bd:	57                   	push   %edi
  8002be:	56                   	push   %esi
  8002bf:	53                   	push   %ebx
  8002c0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002c3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c8:	b8 09 00 00 00       	mov    $0x9,%eax
  8002cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d3:	89 df                	mov    %ebx,%edi
  8002d5:	89 de                	mov    %ebx,%esi
  8002d7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002d9:	85 c0                	test   %eax,%eax
  8002db:	7e 28                	jle    800305 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002dd:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002e1:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002e8:	00 
  8002e9:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  8002f0:	00 
  8002f1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002f8:	00 
  8002f9:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  800300:	e8 53 01 00 00       	call   800458 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800305:	83 c4 2c             	add    $0x2c,%esp
  800308:	5b                   	pop    %ebx
  800309:	5e                   	pop    %esi
  80030a:	5f                   	pop    %edi
  80030b:	5d                   	pop    %ebp
  80030c:	c3                   	ret    

0080030d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80030d:	55                   	push   %ebp
  80030e:	89 e5                	mov    %esp,%ebp
  800310:	57                   	push   %edi
  800311:	56                   	push   %esi
  800312:	53                   	push   %ebx
  800313:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800316:	bb 00 00 00 00       	mov    $0x0,%ebx
  80031b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800320:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800323:	8b 55 08             	mov    0x8(%ebp),%edx
  800326:	89 df                	mov    %ebx,%edi
  800328:	89 de                	mov    %ebx,%esi
  80032a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80032c:	85 c0                	test   %eax,%eax
  80032e:	7e 28                	jle    800358 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800330:	89 44 24 10          	mov    %eax,0x10(%esp)
  800334:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80033b:	00 
  80033c:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  800343:	00 
  800344:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80034b:	00 
  80034c:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  800353:	e8 00 01 00 00       	call   800458 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800358:	83 c4 2c             	add    $0x2c,%esp
  80035b:	5b                   	pop    %ebx
  80035c:	5e                   	pop    %esi
  80035d:	5f                   	pop    %edi
  80035e:	5d                   	pop    %ebp
  80035f:	c3                   	ret    

00800360 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800360:	55                   	push   %ebp
  800361:	89 e5                	mov    %esp,%ebp
  800363:	57                   	push   %edi
  800364:	56                   	push   %esi
  800365:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800366:	be 00 00 00 00       	mov    $0x0,%esi
  80036b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800370:	8b 7d 14             	mov    0x14(%ebp),%edi
  800373:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800376:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800379:	8b 55 08             	mov    0x8(%ebp),%edx
  80037c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80037e:	5b                   	pop    %ebx
  80037f:	5e                   	pop    %esi
  800380:	5f                   	pop    %edi
  800381:	5d                   	pop    %ebp
  800382:	c3                   	ret    

00800383 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800383:	55                   	push   %ebp
  800384:	89 e5                	mov    %esp,%ebp
  800386:	57                   	push   %edi
  800387:	56                   	push   %esi
  800388:	53                   	push   %ebx
  800389:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80038c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800391:	b8 0d 00 00 00       	mov    $0xd,%eax
  800396:	8b 55 08             	mov    0x8(%ebp),%edx
  800399:	89 cb                	mov    %ecx,%ebx
  80039b:	89 cf                	mov    %ecx,%edi
  80039d:	89 ce                	mov    %ecx,%esi
  80039f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003a1:	85 c0                	test   %eax,%eax
  8003a3:	7e 28                	jle    8003cd <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003a5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003a9:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003b0:	00 
  8003b1:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  8003b8:	00 
  8003b9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003c0:	00 
  8003c1:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  8003c8:	e8 8b 00 00 00       	call   800458 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003cd:	83 c4 2c             	add    $0x2c,%esp
  8003d0:	5b                   	pop    %ebx
  8003d1:	5e                   	pop    %esi
  8003d2:	5f                   	pop    %edi
  8003d3:	5d                   	pop    %ebp
  8003d4:	c3                   	ret    

008003d5 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8003d5:	55                   	push   %ebp
  8003d6:	89 e5                	mov    %esp,%ebp
  8003d8:	57                   	push   %edi
  8003d9:	56                   	push   %esi
  8003da:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003db:	ba 00 00 00 00       	mov    $0x0,%edx
  8003e0:	b8 0e 00 00 00       	mov    $0xe,%eax
  8003e5:	89 d1                	mov    %edx,%ecx
  8003e7:	89 d3                	mov    %edx,%ebx
  8003e9:	89 d7                	mov    %edx,%edi
  8003eb:	89 d6                	mov    %edx,%esi
  8003ed:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8003ef:	5b                   	pop    %ebx
  8003f0:	5e                   	pop    %esi
  8003f1:	5f                   	pop    %edi
  8003f2:	5d                   	pop    %ebp
  8003f3:	c3                   	ret    

008003f4 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char* pck, size_t length){
  8003f4:	55                   	push   %ebp
  8003f5:	89 e5                	mov    %esp,%ebp
  8003f7:	57                   	push   %edi
  8003f8:	56                   	push   %esi
  8003f9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003fa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003ff:	b8 10 00 00 00       	mov    $0x10,%eax
  800404:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800407:	8b 55 08             	mov    0x8(%ebp),%edx
  80040a:	89 df                	mov    %ebx,%edi
  80040c:	89 de                	mov    %ebx,%esi
  80040e:	cd 30                	int    $0x30
}

int 
sys_e1000_transmit(char* pck, size_t length){
	return syscall(SYS_e1000_transmit, 0, (uint32_t)pck, length, 0, 0, 0);
}
  800410:	5b                   	pop    %ebx
  800411:	5e                   	pop    %esi
  800412:	5f                   	pop    %edi
  800413:	5d                   	pop    %ebp
  800414:	c3                   	ret    

00800415 <sys_e1000_receive>:

int 
sys_e1000_receive(char* pck, size_t* length){
  800415:	55                   	push   %ebp
  800416:	89 e5                	mov    %esp,%ebp
  800418:	57                   	push   %edi
  800419:	56                   	push   %esi
  80041a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80041b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800420:	b8 0f 00 00 00       	mov    $0xf,%eax
  800425:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800428:	8b 55 08             	mov    0x8(%ebp),%edx
  80042b:	89 df                	mov    %ebx,%edi
  80042d:	89 de                	mov    %ebx,%esi
  80042f:	cd 30                	int    $0x30
}

int 
sys_e1000_receive(char* pck, size_t* length){
	return syscall(SYS_e1000_receive, 0, (uint32_t)pck, (uint32_t)length, 0, 0, 0);
}
  800431:	5b                   	pop    %ebx
  800432:	5e                   	pop    %esi
  800433:	5f                   	pop    %edi
  800434:	5d                   	pop    %ebp
  800435:	c3                   	ret    

00800436 <sys_e1000_get_mac>:

int 
sys_e1000_get_mac(uint8_t* mac_addr){
  800436:	55                   	push   %ebp
  800437:	89 e5                	mov    %esp,%ebp
  800439:	57                   	push   %edi
  80043a:	56                   	push   %esi
  80043b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80043c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800441:	b8 11 00 00 00       	mov    $0x11,%eax
  800446:	8b 55 08             	mov    0x8(%ebp),%edx
  800449:	89 cb                	mov    %ecx,%ebx
  80044b:	89 cf                	mov    %ecx,%edi
  80044d:	89 ce                	mov    %ecx,%esi
  80044f:	cd 30                	int    $0x30
}

int 
sys_e1000_get_mac(uint8_t* mac_addr){
	return syscall(SYS_e1000_get_mac, 0, (uint32_t)mac_addr, 0, 0, 0, 0);
}
  800451:	5b                   	pop    %ebx
  800452:	5e                   	pop    %esi
  800453:	5f                   	pop    %edi
  800454:	5d                   	pop    %ebp
  800455:	c3                   	ret    
	...

00800458 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800458:	55                   	push   %ebp
  800459:	89 e5                	mov    %esp,%ebp
  80045b:	56                   	push   %esi
  80045c:	53                   	push   %ebx
  80045d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800460:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800463:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800469:	e8 c1 fc ff ff       	call   80012f <sys_getenvid>
  80046e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800471:	89 54 24 10          	mov    %edx,0x10(%esp)
  800475:	8b 55 08             	mov    0x8(%ebp),%edx
  800478:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80047c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800480:	89 44 24 04          	mov    %eax,0x4(%esp)
  800484:	c7 04 24 b8 10 80 00 	movl   $0x8010b8,(%esp)
  80048b:	e8 c0 00 00 00       	call   800550 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800490:	89 74 24 04          	mov    %esi,0x4(%esp)
  800494:	8b 45 10             	mov    0x10(%ebp),%eax
  800497:	89 04 24             	mov    %eax,(%esp)
  80049a:	e8 50 00 00 00       	call   8004ef <vcprintf>
	cprintf("\n");
  80049f:	c7 04 24 db 10 80 00 	movl   $0x8010db,(%esp)
  8004a6:	e8 a5 00 00 00       	call   800550 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004ab:	cc                   	int3   
  8004ac:	eb fd                	jmp    8004ab <_panic+0x53>
	...

008004b0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004b0:	55                   	push   %ebp
  8004b1:	89 e5                	mov    %esp,%ebp
  8004b3:	53                   	push   %ebx
  8004b4:	83 ec 14             	sub    $0x14,%esp
  8004b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8004ba:	8b 03                	mov    (%ebx),%eax
  8004bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8004bf:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8004c3:	40                   	inc    %eax
  8004c4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8004c6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004cb:	75 19                	jne    8004e6 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8004cd:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8004d4:	00 
  8004d5:	8d 43 08             	lea    0x8(%ebx),%eax
  8004d8:	89 04 24             	mov    %eax,(%esp)
  8004db:	e8 c0 fb ff ff       	call   8000a0 <sys_cputs>
		b->idx = 0;
  8004e0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8004e6:	ff 43 04             	incl   0x4(%ebx)
}
  8004e9:	83 c4 14             	add    $0x14,%esp
  8004ec:	5b                   	pop    %ebx
  8004ed:	5d                   	pop    %ebp
  8004ee:	c3                   	ret    

008004ef <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004ef:	55                   	push   %ebp
  8004f0:	89 e5                	mov    %esp,%ebp
  8004f2:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8004f8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004ff:	00 00 00 
	b.cnt = 0;
  800502:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800509:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80050c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80050f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800513:	8b 45 08             	mov    0x8(%ebp),%eax
  800516:	89 44 24 08          	mov    %eax,0x8(%esp)
  80051a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800520:	89 44 24 04          	mov    %eax,0x4(%esp)
  800524:	c7 04 24 b0 04 80 00 	movl   $0x8004b0,(%esp)
  80052b:	e8 82 01 00 00       	call   8006b2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800530:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800536:	89 44 24 04          	mov    %eax,0x4(%esp)
  80053a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800540:	89 04 24             	mov    %eax,(%esp)
  800543:	e8 58 fb ff ff       	call   8000a0 <sys_cputs>

	return b.cnt;
}
  800548:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80054e:	c9                   	leave  
  80054f:	c3                   	ret    

00800550 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800550:	55                   	push   %ebp
  800551:	89 e5                	mov    %esp,%ebp
  800553:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800556:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800559:	89 44 24 04          	mov    %eax,0x4(%esp)
  80055d:	8b 45 08             	mov    0x8(%ebp),%eax
  800560:	89 04 24             	mov    %eax,(%esp)
  800563:	e8 87 ff ff ff       	call   8004ef <vcprintf>
	va_end(ap);

	return cnt;
}
  800568:	c9                   	leave  
  800569:	c3                   	ret    
	...

0080056c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80056c:	55                   	push   %ebp
  80056d:	89 e5                	mov    %esp,%ebp
  80056f:	57                   	push   %edi
  800570:	56                   	push   %esi
  800571:	53                   	push   %ebx
  800572:	83 ec 3c             	sub    $0x3c,%esp
  800575:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800578:	89 d7                	mov    %edx,%edi
  80057a:	8b 45 08             	mov    0x8(%ebp),%eax
  80057d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800580:	8b 45 0c             	mov    0xc(%ebp),%eax
  800583:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800586:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800589:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80058c:	85 c0                	test   %eax,%eax
  80058e:	75 08                	jne    800598 <printnum+0x2c>
  800590:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800593:	39 45 10             	cmp    %eax,0x10(%ebp)
  800596:	77 57                	ja     8005ef <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800598:	89 74 24 10          	mov    %esi,0x10(%esp)
  80059c:	4b                   	dec    %ebx
  80059d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8005a1:	8b 45 10             	mov    0x10(%ebp),%eax
  8005a4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005a8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8005ac:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8005b0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005b7:	00 
  8005b8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005bb:	89 04 24             	mov    %eax,(%esp)
  8005be:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005c5:	e8 56 08 00 00       	call   800e20 <__udivdi3>
  8005ca:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005ce:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8005d2:	89 04 24             	mov    %eax,(%esp)
  8005d5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005d9:	89 fa                	mov    %edi,%edx
  8005db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005de:	e8 89 ff ff ff       	call   80056c <printnum>
  8005e3:	eb 0f                	jmp    8005f4 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8005e5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005e9:	89 34 24             	mov    %esi,(%esp)
  8005ec:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005ef:	4b                   	dec    %ebx
  8005f0:	85 db                	test   %ebx,%ebx
  8005f2:	7f f1                	jg     8005e5 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8005f4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005f8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8005fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8005ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800603:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80060a:	00 
  80060b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80060e:	89 04 24             	mov    %eax,(%esp)
  800611:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800614:	89 44 24 04          	mov    %eax,0x4(%esp)
  800618:	e8 23 09 00 00       	call   800f40 <__umoddi3>
  80061d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800621:	0f be 80 dd 10 80 00 	movsbl 0x8010dd(%eax),%eax
  800628:	89 04 24             	mov    %eax,(%esp)
  80062b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80062e:	83 c4 3c             	add    $0x3c,%esp
  800631:	5b                   	pop    %ebx
  800632:	5e                   	pop    %esi
  800633:	5f                   	pop    %edi
  800634:	5d                   	pop    %ebp
  800635:	c3                   	ret    

00800636 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800636:	55                   	push   %ebp
  800637:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800639:	83 fa 01             	cmp    $0x1,%edx
  80063c:	7e 0e                	jle    80064c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80063e:	8b 10                	mov    (%eax),%edx
  800640:	8d 4a 08             	lea    0x8(%edx),%ecx
  800643:	89 08                	mov    %ecx,(%eax)
  800645:	8b 02                	mov    (%edx),%eax
  800647:	8b 52 04             	mov    0x4(%edx),%edx
  80064a:	eb 22                	jmp    80066e <getuint+0x38>
	else if (lflag)
  80064c:	85 d2                	test   %edx,%edx
  80064e:	74 10                	je     800660 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800650:	8b 10                	mov    (%eax),%edx
  800652:	8d 4a 04             	lea    0x4(%edx),%ecx
  800655:	89 08                	mov    %ecx,(%eax)
  800657:	8b 02                	mov    (%edx),%eax
  800659:	ba 00 00 00 00       	mov    $0x0,%edx
  80065e:	eb 0e                	jmp    80066e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800660:	8b 10                	mov    (%eax),%edx
  800662:	8d 4a 04             	lea    0x4(%edx),%ecx
  800665:	89 08                	mov    %ecx,(%eax)
  800667:	8b 02                	mov    (%edx),%eax
  800669:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80066e:	5d                   	pop    %ebp
  80066f:	c3                   	ret    

00800670 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800670:	55                   	push   %ebp
  800671:	89 e5                	mov    %esp,%ebp
  800673:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800676:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800679:	8b 10                	mov    (%eax),%edx
  80067b:	3b 50 04             	cmp    0x4(%eax),%edx
  80067e:	73 08                	jae    800688 <sprintputch+0x18>
		*b->buf++ = ch;
  800680:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800683:	88 0a                	mov    %cl,(%edx)
  800685:	42                   	inc    %edx
  800686:	89 10                	mov    %edx,(%eax)
}
  800688:	5d                   	pop    %ebp
  800689:	c3                   	ret    

0080068a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80068a:	55                   	push   %ebp
  80068b:	89 e5                	mov    %esp,%ebp
  80068d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800690:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800693:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800697:	8b 45 10             	mov    0x10(%ebp),%eax
  80069a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80069e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a8:	89 04 24             	mov    %eax,(%esp)
  8006ab:	e8 02 00 00 00       	call   8006b2 <vprintfmt>
	va_end(ap);
}
  8006b0:	c9                   	leave  
  8006b1:	c3                   	ret    

008006b2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006b2:	55                   	push   %ebp
  8006b3:	89 e5                	mov    %esp,%ebp
  8006b5:	57                   	push   %edi
  8006b6:	56                   	push   %esi
  8006b7:	53                   	push   %ebx
  8006b8:	83 ec 4c             	sub    $0x4c,%esp
  8006bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006be:	8b 75 10             	mov    0x10(%ebp),%esi
  8006c1:	eb 12                	jmp    8006d5 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006c3:	85 c0                	test   %eax,%eax
  8006c5:	0f 84 6b 03 00 00    	je     800a36 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8006cb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006cf:	89 04 24             	mov    %eax,(%esp)
  8006d2:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006d5:	0f b6 06             	movzbl (%esi),%eax
  8006d8:	46                   	inc    %esi
  8006d9:	83 f8 25             	cmp    $0x25,%eax
  8006dc:	75 e5                	jne    8006c3 <vprintfmt+0x11>
  8006de:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8006e2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8006e9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8006ee:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8006f5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006fa:	eb 26                	jmp    800722 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006fc:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8006ff:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800703:	eb 1d                	jmp    800722 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800705:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800708:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80070c:	eb 14                	jmp    800722 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800711:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800718:	eb 08                	jmp    800722 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80071a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80071d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800722:	0f b6 06             	movzbl (%esi),%eax
  800725:	8d 56 01             	lea    0x1(%esi),%edx
  800728:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80072b:	8a 16                	mov    (%esi),%dl
  80072d:	83 ea 23             	sub    $0x23,%edx
  800730:	80 fa 55             	cmp    $0x55,%dl
  800733:	0f 87 e1 02 00 00    	ja     800a1a <vprintfmt+0x368>
  800739:	0f b6 d2             	movzbl %dl,%edx
  80073c:	ff 24 95 20 12 80 00 	jmp    *0x801220(,%edx,4)
  800743:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800746:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80074b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80074e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800752:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800755:	8d 50 d0             	lea    -0x30(%eax),%edx
  800758:	83 fa 09             	cmp    $0x9,%edx
  80075b:	77 2a                	ja     800787 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80075d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80075e:	eb eb                	jmp    80074b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800760:	8b 45 14             	mov    0x14(%ebp),%eax
  800763:	8d 50 04             	lea    0x4(%eax),%edx
  800766:	89 55 14             	mov    %edx,0x14(%ebp)
  800769:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80076b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80076e:	eb 17                	jmp    800787 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800770:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800774:	78 98                	js     80070e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800776:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800779:	eb a7                	jmp    800722 <vprintfmt+0x70>
  80077b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80077e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800785:	eb 9b                	jmp    800722 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800787:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80078b:	79 95                	jns    800722 <vprintfmt+0x70>
  80078d:	eb 8b                	jmp    80071a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80078f:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800790:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800793:	eb 8d                	jmp    800722 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800795:	8b 45 14             	mov    0x14(%ebp),%eax
  800798:	8d 50 04             	lea    0x4(%eax),%edx
  80079b:	89 55 14             	mov    %edx,0x14(%ebp)
  80079e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a2:	8b 00                	mov    (%eax),%eax
  8007a4:	89 04 24             	mov    %eax,(%esp)
  8007a7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007aa:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8007ad:	e9 23 ff ff ff       	jmp    8006d5 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8007b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b5:	8d 50 04             	lea    0x4(%eax),%edx
  8007b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8007bb:	8b 00                	mov    (%eax),%eax
  8007bd:	85 c0                	test   %eax,%eax
  8007bf:	79 02                	jns    8007c3 <vprintfmt+0x111>
  8007c1:	f7 d8                	neg    %eax
  8007c3:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8007c5:	83 f8 11             	cmp    $0x11,%eax
  8007c8:	7f 0b                	jg     8007d5 <vprintfmt+0x123>
  8007ca:	8b 04 85 80 13 80 00 	mov    0x801380(,%eax,4),%eax
  8007d1:	85 c0                	test   %eax,%eax
  8007d3:	75 23                	jne    8007f8 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8007d5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007d9:	c7 44 24 08 f5 10 80 	movl   $0x8010f5,0x8(%esp)
  8007e0:	00 
  8007e1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e8:	89 04 24             	mov    %eax,(%esp)
  8007eb:	e8 9a fe ff ff       	call   80068a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007f0:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8007f3:	e9 dd fe ff ff       	jmp    8006d5 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8007f8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007fc:	c7 44 24 08 fe 10 80 	movl   $0x8010fe,0x8(%esp)
  800803:	00 
  800804:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800808:	8b 55 08             	mov    0x8(%ebp),%edx
  80080b:	89 14 24             	mov    %edx,(%esp)
  80080e:	e8 77 fe ff ff       	call   80068a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800813:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800816:	e9 ba fe ff ff       	jmp    8006d5 <vprintfmt+0x23>
  80081b:	89 f9                	mov    %edi,%ecx
  80081d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800820:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800823:	8b 45 14             	mov    0x14(%ebp),%eax
  800826:	8d 50 04             	lea    0x4(%eax),%edx
  800829:	89 55 14             	mov    %edx,0x14(%ebp)
  80082c:	8b 30                	mov    (%eax),%esi
  80082e:	85 f6                	test   %esi,%esi
  800830:	75 05                	jne    800837 <vprintfmt+0x185>
				p = "(null)";
  800832:	be ee 10 80 00       	mov    $0x8010ee,%esi
			if (width > 0 && padc != '-')
  800837:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80083b:	0f 8e 84 00 00 00    	jle    8008c5 <vprintfmt+0x213>
  800841:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800845:	74 7e                	je     8008c5 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800847:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80084b:	89 34 24             	mov    %esi,(%esp)
  80084e:	e8 8b 02 00 00       	call   800ade <strnlen>
  800853:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800856:	29 c2                	sub    %eax,%edx
  800858:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80085b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80085f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800862:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800865:	89 de                	mov    %ebx,%esi
  800867:	89 d3                	mov    %edx,%ebx
  800869:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80086b:	eb 0b                	jmp    800878 <vprintfmt+0x1c6>
					putch(padc, putdat);
  80086d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800871:	89 3c 24             	mov    %edi,(%esp)
  800874:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800877:	4b                   	dec    %ebx
  800878:	85 db                	test   %ebx,%ebx
  80087a:	7f f1                	jg     80086d <vprintfmt+0x1bb>
  80087c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80087f:	89 f3                	mov    %esi,%ebx
  800881:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800884:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800887:	85 c0                	test   %eax,%eax
  800889:	79 05                	jns    800890 <vprintfmt+0x1de>
  80088b:	b8 00 00 00 00       	mov    $0x0,%eax
  800890:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800893:	29 c2                	sub    %eax,%edx
  800895:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800898:	eb 2b                	jmp    8008c5 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80089a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80089e:	74 18                	je     8008b8 <vprintfmt+0x206>
  8008a0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8008a3:	83 fa 5e             	cmp    $0x5e,%edx
  8008a6:	76 10                	jbe    8008b8 <vprintfmt+0x206>
					putch('?', putdat);
  8008a8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008ac:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8008b3:	ff 55 08             	call   *0x8(%ebp)
  8008b6:	eb 0a                	jmp    8008c2 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8008b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008bc:	89 04 24             	mov    %eax,(%esp)
  8008bf:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008c2:	ff 4d e4             	decl   -0x1c(%ebp)
  8008c5:	0f be 06             	movsbl (%esi),%eax
  8008c8:	46                   	inc    %esi
  8008c9:	85 c0                	test   %eax,%eax
  8008cb:	74 21                	je     8008ee <vprintfmt+0x23c>
  8008cd:	85 ff                	test   %edi,%edi
  8008cf:	78 c9                	js     80089a <vprintfmt+0x1e8>
  8008d1:	4f                   	dec    %edi
  8008d2:	79 c6                	jns    80089a <vprintfmt+0x1e8>
  8008d4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008d7:	89 de                	mov    %ebx,%esi
  8008d9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8008dc:	eb 18                	jmp    8008f6 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8008de:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008e2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8008e9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8008eb:	4b                   	dec    %ebx
  8008ec:	eb 08                	jmp    8008f6 <vprintfmt+0x244>
  8008ee:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008f1:	89 de                	mov    %ebx,%esi
  8008f3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8008f6:	85 db                	test   %ebx,%ebx
  8008f8:	7f e4                	jg     8008de <vprintfmt+0x22c>
  8008fa:	89 7d 08             	mov    %edi,0x8(%ebp)
  8008fd:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ff:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800902:	e9 ce fd ff ff       	jmp    8006d5 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800907:	83 f9 01             	cmp    $0x1,%ecx
  80090a:	7e 10                	jle    80091c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80090c:	8b 45 14             	mov    0x14(%ebp),%eax
  80090f:	8d 50 08             	lea    0x8(%eax),%edx
  800912:	89 55 14             	mov    %edx,0x14(%ebp)
  800915:	8b 30                	mov    (%eax),%esi
  800917:	8b 78 04             	mov    0x4(%eax),%edi
  80091a:	eb 26                	jmp    800942 <vprintfmt+0x290>
	else if (lflag)
  80091c:	85 c9                	test   %ecx,%ecx
  80091e:	74 12                	je     800932 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800920:	8b 45 14             	mov    0x14(%ebp),%eax
  800923:	8d 50 04             	lea    0x4(%eax),%edx
  800926:	89 55 14             	mov    %edx,0x14(%ebp)
  800929:	8b 30                	mov    (%eax),%esi
  80092b:	89 f7                	mov    %esi,%edi
  80092d:	c1 ff 1f             	sar    $0x1f,%edi
  800930:	eb 10                	jmp    800942 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800932:	8b 45 14             	mov    0x14(%ebp),%eax
  800935:	8d 50 04             	lea    0x4(%eax),%edx
  800938:	89 55 14             	mov    %edx,0x14(%ebp)
  80093b:	8b 30                	mov    (%eax),%esi
  80093d:	89 f7                	mov    %esi,%edi
  80093f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800942:	85 ff                	test   %edi,%edi
  800944:	78 0a                	js     800950 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800946:	b8 0a 00 00 00       	mov    $0xa,%eax
  80094b:	e9 8c 00 00 00       	jmp    8009dc <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800950:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800954:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80095b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80095e:	f7 de                	neg    %esi
  800960:	83 d7 00             	adc    $0x0,%edi
  800963:	f7 df                	neg    %edi
			}
			base = 10;
  800965:	b8 0a 00 00 00       	mov    $0xa,%eax
  80096a:	eb 70                	jmp    8009dc <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80096c:	89 ca                	mov    %ecx,%edx
  80096e:	8d 45 14             	lea    0x14(%ebp),%eax
  800971:	e8 c0 fc ff ff       	call   800636 <getuint>
  800976:	89 c6                	mov    %eax,%esi
  800978:	89 d7                	mov    %edx,%edi
			base = 10;
  80097a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80097f:	eb 5b                	jmp    8009dc <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  800981:	89 ca                	mov    %ecx,%edx
  800983:	8d 45 14             	lea    0x14(%ebp),%eax
  800986:	e8 ab fc ff ff       	call   800636 <getuint>
  80098b:	89 c6                	mov    %eax,%esi
  80098d:	89 d7                	mov    %edx,%edi
			base = 8;
  80098f:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800994:	eb 46                	jmp    8009dc <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  800996:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80099a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8009a1:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8009a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009a8:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8009af:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8009b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b5:	8d 50 04             	lea    0x4(%eax),%edx
  8009b8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8009bb:	8b 30                	mov    (%eax),%esi
  8009bd:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8009c2:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8009c7:	eb 13                	jmp    8009dc <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8009c9:	89 ca                	mov    %ecx,%edx
  8009cb:	8d 45 14             	lea    0x14(%ebp),%eax
  8009ce:	e8 63 fc ff ff       	call   800636 <getuint>
  8009d3:	89 c6                	mov    %eax,%esi
  8009d5:	89 d7                	mov    %edx,%edi
			base = 16;
  8009d7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8009dc:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8009e0:	89 54 24 10          	mov    %edx,0x10(%esp)
  8009e4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8009e7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8009eb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009ef:	89 34 24             	mov    %esi,(%esp)
  8009f2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009f6:	89 da                	mov    %ebx,%edx
  8009f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fb:	e8 6c fb ff ff       	call   80056c <printnum>
			break;
  800a00:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800a03:	e9 cd fc ff ff       	jmp    8006d5 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a08:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a0c:	89 04 24             	mov    %eax,(%esp)
  800a0f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a12:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a15:	e9 bb fc ff ff       	jmp    8006d5 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a1a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a1e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a25:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a28:	eb 01                	jmp    800a2b <vprintfmt+0x379>
  800a2a:	4e                   	dec    %esi
  800a2b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800a2f:	75 f9                	jne    800a2a <vprintfmt+0x378>
  800a31:	e9 9f fc ff ff       	jmp    8006d5 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800a36:	83 c4 4c             	add    $0x4c,%esp
  800a39:	5b                   	pop    %ebx
  800a3a:	5e                   	pop    %esi
  800a3b:	5f                   	pop    %edi
  800a3c:	5d                   	pop    %ebp
  800a3d:	c3                   	ret    

00800a3e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a3e:	55                   	push   %ebp
  800a3f:	89 e5                	mov    %esp,%ebp
  800a41:	83 ec 28             	sub    $0x28,%esp
  800a44:	8b 45 08             	mov    0x8(%ebp),%eax
  800a47:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a4a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a4d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a51:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a54:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a5b:	85 c0                	test   %eax,%eax
  800a5d:	74 30                	je     800a8f <vsnprintf+0x51>
  800a5f:	85 d2                	test   %edx,%edx
  800a61:	7e 33                	jle    800a96 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a63:	8b 45 14             	mov    0x14(%ebp),%eax
  800a66:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a6a:	8b 45 10             	mov    0x10(%ebp),%eax
  800a6d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a71:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a74:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a78:	c7 04 24 70 06 80 00 	movl   $0x800670,(%esp)
  800a7f:	e8 2e fc ff ff       	call   8006b2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a84:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a87:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a8d:	eb 0c                	jmp    800a9b <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a8f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a94:	eb 05                	jmp    800a9b <vsnprintf+0x5d>
  800a96:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a9b:	c9                   	leave  
  800a9c:	c3                   	ret    

00800a9d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
  800aa0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800aa3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800aa6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800aaa:	8b 45 10             	mov    0x10(%ebp),%eax
  800aad:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ab1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ab8:	8b 45 08             	mov    0x8(%ebp),%eax
  800abb:	89 04 24             	mov    %eax,(%esp)
  800abe:	e8 7b ff ff ff       	call   800a3e <vsnprintf>
	va_end(ap);

	return rc;
}
  800ac3:	c9                   	leave  
  800ac4:	c3                   	ret    
  800ac5:	00 00                	add    %al,(%eax)
	...

00800ac8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ac8:	55                   	push   %ebp
  800ac9:	89 e5                	mov    %esp,%ebp
  800acb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ace:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad3:	eb 01                	jmp    800ad6 <strlen+0xe>
		n++;
  800ad5:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800ad6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ada:	75 f9                	jne    800ad5 <strlen+0xd>
		n++;
	return n;
}
  800adc:	5d                   	pop    %ebp
  800add:	c3                   	ret    

00800ade <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ade:	55                   	push   %ebp
  800adf:	89 e5                	mov    %esp,%ebp
  800ae1:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800ae4:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ae7:	b8 00 00 00 00       	mov    $0x0,%eax
  800aec:	eb 01                	jmp    800aef <strnlen+0x11>
		n++;
  800aee:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800aef:	39 d0                	cmp    %edx,%eax
  800af1:	74 06                	je     800af9 <strnlen+0x1b>
  800af3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800af7:	75 f5                	jne    800aee <strnlen+0x10>
		n++;
	return n;
}
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	53                   	push   %ebx
  800aff:	8b 45 08             	mov    0x8(%ebp),%eax
  800b02:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b05:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800b0d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800b10:	42                   	inc    %edx
  800b11:	84 c9                	test   %cl,%cl
  800b13:	75 f5                	jne    800b0a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800b15:	5b                   	pop    %ebx
  800b16:	5d                   	pop    %ebp
  800b17:	c3                   	ret    

00800b18 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b18:	55                   	push   %ebp
  800b19:	89 e5                	mov    %esp,%ebp
  800b1b:	53                   	push   %ebx
  800b1c:	83 ec 08             	sub    $0x8,%esp
  800b1f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b22:	89 1c 24             	mov    %ebx,(%esp)
  800b25:	e8 9e ff ff ff       	call   800ac8 <strlen>
	strcpy(dst + len, src);
  800b2a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b2d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b31:	01 d8                	add    %ebx,%eax
  800b33:	89 04 24             	mov    %eax,(%esp)
  800b36:	e8 c0 ff ff ff       	call   800afb <strcpy>
	return dst;
}
  800b3b:	89 d8                	mov    %ebx,%eax
  800b3d:	83 c4 08             	add    $0x8,%esp
  800b40:	5b                   	pop    %ebx
  800b41:	5d                   	pop    %ebp
  800b42:	c3                   	ret    

00800b43 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b43:	55                   	push   %ebp
  800b44:	89 e5                	mov    %esp,%ebp
  800b46:	56                   	push   %esi
  800b47:	53                   	push   %ebx
  800b48:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b4e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b51:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b56:	eb 0c                	jmp    800b64 <strncpy+0x21>
		*dst++ = *src;
  800b58:	8a 1a                	mov    (%edx),%bl
  800b5a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b5d:	80 3a 01             	cmpb   $0x1,(%edx)
  800b60:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b63:	41                   	inc    %ecx
  800b64:	39 f1                	cmp    %esi,%ecx
  800b66:	75 f0                	jne    800b58 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b68:	5b                   	pop    %ebx
  800b69:	5e                   	pop    %esi
  800b6a:	5d                   	pop    %ebp
  800b6b:	c3                   	ret    

00800b6c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	56                   	push   %esi
  800b70:	53                   	push   %ebx
  800b71:	8b 75 08             	mov    0x8(%ebp),%esi
  800b74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b77:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b7a:	85 d2                	test   %edx,%edx
  800b7c:	75 0a                	jne    800b88 <strlcpy+0x1c>
  800b7e:	89 f0                	mov    %esi,%eax
  800b80:	eb 1a                	jmp    800b9c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b82:	88 18                	mov    %bl,(%eax)
  800b84:	40                   	inc    %eax
  800b85:	41                   	inc    %ecx
  800b86:	eb 02                	jmp    800b8a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b88:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800b8a:	4a                   	dec    %edx
  800b8b:	74 0a                	je     800b97 <strlcpy+0x2b>
  800b8d:	8a 19                	mov    (%ecx),%bl
  800b8f:	84 db                	test   %bl,%bl
  800b91:	75 ef                	jne    800b82 <strlcpy+0x16>
  800b93:	89 c2                	mov    %eax,%edx
  800b95:	eb 02                	jmp    800b99 <strlcpy+0x2d>
  800b97:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800b99:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800b9c:	29 f0                	sub    %esi,%eax
}
  800b9e:	5b                   	pop    %ebx
  800b9f:	5e                   	pop    %esi
  800ba0:	5d                   	pop    %ebp
  800ba1:	c3                   	ret    

00800ba2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ba8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bab:	eb 02                	jmp    800baf <strcmp+0xd>
		p++, q++;
  800bad:	41                   	inc    %ecx
  800bae:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800baf:	8a 01                	mov    (%ecx),%al
  800bb1:	84 c0                	test   %al,%al
  800bb3:	74 04                	je     800bb9 <strcmp+0x17>
  800bb5:	3a 02                	cmp    (%edx),%al
  800bb7:	74 f4                	je     800bad <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800bb9:	0f b6 c0             	movzbl %al,%eax
  800bbc:	0f b6 12             	movzbl (%edx),%edx
  800bbf:	29 d0                	sub    %edx,%eax
}
  800bc1:	5d                   	pop    %ebp
  800bc2:	c3                   	ret    

00800bc3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	53                   	push   %ebx
  800bc7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bcd:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800bd0:	eb 03                	jmp    800bd5 <strncmp+0x12>
		n--, p++, q++;
  800bd2:	4a                   	dec    %edx
  800bd3:	40                   	inc    %eax
  800bd4:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800bd5:	85 d2                	test   %edx,%edx
  800bd7:	74 14                	je     800bed <strncmp+0x2a>
  800bd9:	8a 18                	mov    (%eax),%bl
  800bdb:	84 db                	test   %bl,%bl
  800bdd:	74 04                	je     800be3 <strncmp+0x20>
  800bdf:	3a 19                	cmp    (%ecx),%bl
  800be1:	74 ef                	je     800bd2 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800be3:	0f b6 00             	movzbl (%eax),%eax
  800be6:	0f b6 11             	movzbl (%ecx),%edx
  800be9:	29 d0                	sub    %edx,%eax
  800beb:	eb 05                	jmp    800bf2 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800bed:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800bf2:	5b                   	pop    %ebx
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	8b 45 08             	mov    0x8(%ebp),%eax
  800bfb:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800bfe:	eb 05                	jmp    800c05 <strchr+0x10>
		if (*s == c)
  800c00:	38 ca                	cmp    %cl,%dl
  800c02:	74 0c                	je     800c10 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c04:	40                   	inc    %eax
  800c05:	8a 10                	mov    (%eax),%dl
  800c07:	84 d2                	test   %dl,%dl
  800c09:	75 f5                	jne    800c00 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800c0b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c10:	5d                   	pop    %ebp
  800c11:	c3                   	ret    

00800c12 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	8b 45 08             	mov    0x8(%ebp),%eax
  800c18:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800c1b:	eb 05                	jmp    800c22 <strfind+0x10>
		if (*s == c)
  800c1d:	38 ca                	cmp    %cl,%dl
  800c1f:	74 07                	je     800c28 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c21:	40                   	inc    %eax
  800c22:	8a 10                	mov    (%eax),%dl
  800c24:	84 d2                	test   %dl,%dl
  800c26:	75 f5                	jne    800c1d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800c28:	5d                   	pop    %ebp
  800c29:	c3                   	ret    

00800c2a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c2a:	55                   	push   %ebp
  800c2b:	89 e5                	mov    %esp,%ebp
  800c2d:	57                   	push   %edi
  800c2e:	56                   	push   %esi
  800c2f:	53                   	push   %ebx
  800c30:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c33:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c36:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c39:	85 c9                	test   %ecx,%ecx
  800c3b:	74 30                	je     800c6d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c3d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c43:	75 25                	jne    800c6a <memset+0x40>
  800c45:	f6 c1 03             	test   $0x3,%cl
  800c48:	75 20                	jne    800c6a <memset+0x40>
		c &= 0xFF;
  800c4a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c4d:	89 d3                	mov    %edx,%ebx
  800c4f:	c1 e3 08             	shl    $0x8,%ebx
  800c52:	89 d6                	mov    %edx,%esi
  800c54:	c1 e6 18             	shl    $0x18,%esi
  800c57:	89 d0                	mov    %edx,%eax
  800c59:	c1 e0 10             	shl    $0x10,%eax
  800c5c:	09 f0                	or     %esi,%eax
  800c5e:	09 d0                	or     %edx,%eax
  800c60:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c62:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800c65:	fc                   	cld    
  800c66:	f3 ab                	rep stos %eax,%es:(%edi)
  800c68:	eb 03                	jmp    800c6d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c6a:	fc                   	cld    
  800c6b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c6d:	89 f8                	mov    %edi,%eax
  800c6f:	5b                   	pop    %ebx
  800c70:	5e                   	pop    %esi
  800c71:	5f                   	pop    %edi
  800c72:	5d                   	pop    %ebp
  800c73:	c3                   	ret    

00800c74 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	57                   	push   %edi
  800c78:	56                   	push   %esi
  800c79:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c7f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c82:	39 c6                	cmp    %eax,%esi
  800c84:	73 34                	jae    800cba <memmove+0x46>
  800c86:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c89:	39 d0                	cmp    %edx,%eax
  800c8b:	73 2d                	jae    800cba <memmove+0x46>
		s += n;
		d += n;
  800c8d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c90:	f6 c2 03             	test   $0x3,%dl
  800c93:	75 1b                	jne    800cb0 <memmove+0x3c>
  800c95:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c9b:	75 13                	jne    800cb0 <memmove+0x3c>
  800c9d:	f6 c1 03             	test   $0x3,%cl
  800ca0:	75 0e                	jne    800cb0 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ca2:	83 ef 04             	sub    $0x4,%edi
  800ca5:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ca8:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800cab:	fd                   	std    
  800cac:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cae:	eb 07                	jmp    800cb7 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800cb0:	4f                   	dec    %edi
  800cb1:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800cb4:	fd                   	std    
  800cb5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800cb7:	fc                   	cld    
  800cb8:	eb 20                	jmp    800cda <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cba:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cc0:	75 13                	jne    800cd5 <memmove+0x61>
  800cc2:	a8 03                	test   $0x3,%al
  800cc4:	75 0f                	jne    800cd5 <memmove+0x61>
  800cc6:	f6 c1 03             	test   $0x3,%cl
  800cc9:	75 0a                	jne    800cd5 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ccb:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800cce:	89 c7                	mov    %eax,%edi
  800cd0:	fc                   	cld    
  800cd1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cd3:	eb 05                	jmp    800cda <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800cd5:	89 c7                	mov    %eax,%edi
  800cd7:	fc                   	cld    
  800cd8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800cda:	5e                   	pop    %esi
  800cdb:	5f                   	pop    %edi
  800cdc:	5d                   	pop    %ebp
  800cdd:	c3                   	ret    

00800cde <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800cde:	55                   	push   %ebp
  800cdf:	89 e5                	mov    %esp,%ebp
  800ce1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ce4:	8b 45 10             	mov    0x10(%ebp),%eax
  800ce7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ceb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cee:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cf2:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf5:	89 04 24             	mov    %eax,(%esp)
  800cf8:	e8 77 ff ff ff       	call   800c74 <memmove>
}
  800cfd:	c9                   	leave  
  800cfe:	c3                   	ret    

00800cff <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cff:	55                   	push   %ebp
  800d00:	89 e5                	mov    %esp,%ebp
  800d02:	57                   	push   %edi
  800d03:	56                   	push   %esi
  800d04:	53                   	push   %ebx
  800d05:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d08:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d0e:	ba 00 00 00 00       	mov    $0x0,%edx
  800d13:	eb 16                	jmp    800d2b <memcmp+0x2c>
		if (*s1 != *s2)
  800d15:	8a 04 17             	mov    (%edi,%edx,1),%al
  800d18:	42                   	inc    %edx
  800d19:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800d1d:	38 c8                	cmp    %cl,%al
  800d1f:	74 0a                	je     800d2b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800d21:	0f b6 c0             	movzbl %al,%eax
  800d24:	0f b6 c9             	movzbl %cl,%ecx
  800d27:	29 c8                	sub    %ecx,%eax
  800d29:	eb 09                	jmp    800d34 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d2b:	39 da                	cmp    %ebx,%edx
  800d2d:	75 e6                	jne    800d15 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d2f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d34:	5b                   	pop    %ebx
  800d35:	5e                   	pop    %esi
  800d36:	5f                   	pop    %edi
  800d37:	5d                   	pop    %ebp
  800d38:	c3                   	ret    

00800d39 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d39:	55                   	push   %ebp
  800d3a:	89 e5                	mov    %esp,%ebp
  800d3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800d42:	89 c2                	mov    %eax,%edx
  800d44:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d47:	eb 05                	jmp    800d4e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d49:	38 08                	cmp    %cl,(%eax)
  800d4b:	74 05                	je     800d52 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d4d:	40                   	inc    %eax
  800d4e:	39 d0                	cmp    %edx,%eax
  800d50:	72 f7                	jb     800d49 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d52:	5d                   	pop    %ebp
  800d53:	c3                   	ret    

00800d54 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d54:	55                   	push   %ebp
  800d55:	89 e5                	mov    %esp,%ebp
  800d57:	57                   	push   %edi
  800d58:	56                   	push   %esi
  800d59:	53                   	push   %ebx
  800d5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d60:	eb 01                	jmp    800d63 <strtol+0xf>
		s++;
  800d62:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d63:	8a 02                	mov    (%edx),%al
  800d65:	3c 20                	cmp    $0x20,%al
  800d67:	74 f9                	je     800d62 <strtol+0xe>
  800d69:	3c 09                	cmp    $0x9,%al
  800d6b:	74 f5                	je     800d62 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d6d:	3c 2b                	cmp    $0x2b,%al
  800d6f:	75 08                	jne    800d79 <strtol+0x25>
		s++;
  800d71:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d72:	bf 00 00 00 00       	mov    $0x0,%edi
  800d77:	eb 13                	jmp    800d8c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d79:	3c 2d                	cmp    $0x2d,%al
  800d7b:	75 0a                	jne    800d87 <strtol+0x33>
		s++, neg = 1;
  800d7d:	8d 52 01             	lea    0x1(%edx),%edx
  800d80:	bf 01 00 00 00       	mov    $0x1,%edi
  800d85:	eb 05                	jmp    800d8c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d87:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d8c:	85 db                	test   %ebx,%ebx
  800d8e:	74 05                	je     800d95 <strtol+0x41>
  800d90:	83 fb 10             	cmp    $0x10,%ebx
  800d93:	75 28                	jne    800dbd <strtol+0x69>
  800d95:	8a 02                	mov    (%edx),%al
  800d97:	3c 30                	cmp    $0x30,%al
  800d99:	75 10                	jne    800dab <strtol+0x57>
  800d9b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d9f:	75 0a                	jne    800dab <strtol+0x57>
		s += 2, base = 16;
  800da1:	83 c2 02             	add    $0x2,%edx
  800da4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800da9:	eb 12                	jmp    800dbd <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800dab:	85 db                	test   %ebx,%ebx
  800dad:	75 0e                	jne    800dbd <strtol+0x69>
  800daf:	3c 30                	cmp    $0x30,%al
  800db1:	75 05                	jne    800db8 <strtol+0x64>
		s++, base = 8;
  800db3:	42                   	inc    %edx
  800db4:	b3 08                	mov    $0x8,%bl
  800db6:	eb 05                	jmp    800dbd <strtol+0x69>
	else if (base == 0)
		base = 10;
  800db8:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800dbd:	b8 00 00 00 00       	mov    $0x0,%eax
  800dc2:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800dc4:	8a 0a                	mov    (%edx),%cl
  800dc6:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800dc9:	80 fb 09             	cmp    $0x9,%bl
  800dcc:	77 08                	ja     800dd6 <strtol+0x82>
			dig = *s - '0';
  800dce:	0f be c9             	movsbl %cl,%ecx
  800dd1:	83 e9 30             	sub    $0x30,%ecx
  800dd4:	eb 1e                	jmp    800df4 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800dd6:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800dd9:	80 fb 19             	cmp    $0x19,%bl
  800ddc:	77 08                	ja     800de6 <strtol+0x92>
			dig = *s - 'a' + 10;
  800dde:	0f be c9             	movsbl %cl,%ecx
  800de1:	83 e9 57             	sub    $0x57,%ecx
  800de4:	eb 0e                	jmp    800df4 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800de6:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800de9:	80 fb 19             	cmp    $0x19,%bl
  800dec:	77 12                	ja     800e00 <strtol+0xac>
			dig = *s - 'A' + 10;
  800dee:	0f be c9             	movsbl %cl,%ecx
  800df1:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800df4:	39 f1                	cmp    %esi,%ecx
  800df6:	7d 0c                	jge    800e04 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800df8:	42                   	inc    %edx
  800df9:	0f af c6             	imul   %esi,%eax
  800dfc:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800dfe:	eb c4                	jmp    800dc4 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800e00:	89 c1                	mov    %eax,%ecx
  800e02:	eb 02                	jmp    800e06 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800e04:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800e06:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e0a:	74 05                	je     800e11 <strtol+0xbd>
		*endptr = (char *) s;
  800e0c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e0f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800e11:	85 ff                	test   %edi,%edi
  800e13:	74 04                	je     800e19 <strtol+0xc5>
  800e15:	89 c8                	mov    %ecx,%eax
  800e17:	f7 d8                	neg    %eax
}
  800e19:	5b                   	pop    %ebx
  800e1a:	5e                   	pop    %esi
  800e1b:	5f                   	pop    %edi
  800e1c:	5d                   	pop    %ebp
  800e1d:	c3                   	ret    
	...

00800e20 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800e20:	55                   	push   %ebp
  800e21:	57                   	push   %edi
  800e22:	56                   	push   %esi
  800e23:	83 ec 10             	sub    $0x10,%esp
  800e26:	8b 74 24 20          	mov    0x20(%esp),%esi
  800e2a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800e2e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e32:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  800e36:	89 cd                	mov    %ecx,%ebp
  800e38:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e3c:	85 c0                	test   %eax,%eax
  800e3e:	75 2c                	jne    800e6c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800e40:	39 f9                	cmp    %edi,%ecx
  800e42:	77 68                	ja     800eac <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800e44:	85 c9                	test   %ecx,%ecx
  800e46:	75 0b                	jne    800e53 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800e48:	b8 01 00 00 00       	mov    $0x1,%eax
  800e4d:	31 d2                	xor    %edx,%edx
  800e4f:	f7 f1                	div    %ecx
  800e51:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800e53:	31 d2                	xor    %edx,%edx
  800e55:	89 f8                	mov    %edi,%eax
  800e57:	f7 f1                	div    %ecx
  800e59:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e5b:	89 f0                	mov    %esi,%eax
  800e5d:	f7 f1                	div    %ecx
  800e5f:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e61:	89 f0                	mov    %esi,%eax
  800e63:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e65:	83 c4 10             	add    $0x10,%esp
  800e68:	5e                   	pop    %esi
  800e69:	5f                   	pop    %edi
  800e6a:	5d                   	pop    %ebp
  800e6b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e6c:	39 f8                	cmp    %edi,%eax
  800e6e:	77 2c                	ja     800e9c <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e70:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  800e73:	83 f6 1f             	xor    $0x1f,%esi
  800e76:	75 4c                	jne    800ec4 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e78:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e7a:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e7f:	72 0a                	jb     800e8b <__udivdi3+0x6b>
  800e81:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800e85:	0f 87 ad 00 00 00    	ja     800f38 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e8b:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e90:	89 f0                	mov    %esi,%eax
  800e92:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e94:	83 c4 10             	add    $0x10,%esp
  800e97:	5e                   	pop    %esi
  800e98:	5f                   	pop    %edi
  800e99:	5d                   	pop    %ebp
  800e9a:	c3                   	ret    
  800e9b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e9c:	31 ff                	xor    %edi,%edi
  800e9e:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800ea0:	89 f0                	mov    %esi,%eax
  800ea2:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800ea4:	83 c4 10             	add    $0x10,%esp
  800ea7:	5e                   	pop    %esi
  800ea8:	5f                   	pop    %edi
  800ea9:	5d                   	pop    %ebp
  800eaa:	c3                   	ret    
  800eab:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800eac:	89 fa                	mov    %edi,%edx
  800eae:	89 f0                	mov    %esi,%eax
  800eb0:	f7 f1                	div    %ecx
  800eb2:	89 c6                	mov    %eax,%esi
  800eb4:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800eb6:	89 f0                	mov    %esi,%eax
  800eb8:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800eba:	83 c4 10             	add    $0x10,%esp
  800ebd:	5e                   	pop    %esi
  800ebe:	5f                   	pop    %edi
  800ebf:	5d                   	pop    %ebp
  800ec0:	c3                   	ret    
  800ec1:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800ec4:	89 f1                	mov    %esi,%ecx
  800ec6:	d3 e0                	shl    %cl,%eax
  800ec8:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800ecc:	b8 20 00 00 00       	mov    $0x20,%eax
  800ed1:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800ed3:	89 ea                	mov    %ebp,%edx
  800ed5:	88 c1                	mov    %al,%cl
  800ed7:	d3 ea                	shr    %cl,%edx
  800ed9:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800edd:	09 ca                	or     %ecx,%edx
  800edf:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  800ee3:	89 f1                	mov    %esi,%ecx
  800ee5:	d3 e5                	shl    %cl,%ebp
  800ee7:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  800eeb:	89 fd                	mov    %edi,%ebp
  800eed:	88 c1                	mov    %al,%cl
  800eef:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  800ef1:	89 fa                	mov    %edi,%edx
  800ef3:	89 f1                	mov    %esi,%ecx
  800ef5:	d3 e2                	shl    %cl,%edx
  800ef7:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800efb:	88 c1                	mov    %al,%cl
  800efd:	d3 ef                	shr    %cl,%edi
  800eff:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800f01:	89 f8                	mov    %edi,%eax
  800f03:	89 ea                	mov    %ebp,%edx
  800f05:	f7 74 24 08          	divl   0x8(%esp)
  800f09:	89 d1                	mov    %edx,%ecx
  800f0b:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  800f0d:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f11:	39 d1                	cmp    %edx,%ecx
  800f13:	72 17                	jb     800f2c <__udivdi3+0x10c>
  800f15:	74 09                	je     800f20 <__udivdi3+0x100>
  800f17:	89 fe                	mov    %edi,%esi
  800f19:	31 ff                	xor    %edi,%edi
  800f1b:	e9 41 ff ff ff       	jmp    800e61 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800f20:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f24:	89 f1                	mov    %esi,%ecx
  800f26:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f28:	39 c2                	cmp    %eax,%edx
  800f2a:	73 eb                	jae    800f17 <__udivdi3+0xf7>
		{
		  q0--;
  800f2c:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f2f:	31 ff                	xor    %edi,%edi
  800f31:	e9 2b ff ff ff       	jmp    800e61 <__udivdi3+0x41>
  800f36:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800f38:	31 f6                	xor    %esi,%esi
  800f3a:	e9 22 ff ff ff       	jmp    800e61 <__udivdi3+0x41>
	...

00800f40 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800f40:	55                   	push   %ebp
  800f41:	57                   	push   %edi
  800f42:	56                   	push   %esi
  800f43:	83 ec 20             	sub    $0x20,%esp
  800f46:	8b 44 24 30          	mov    0x30(%esp),%eax
  800f4a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800f4e:	89 44 24 14          	mov    %eax,0x14(%esp)
  800f52:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  800f56:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800f5a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800f5e:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  800f60:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800f62:	85 ed                	test   %ebp,%ebp
  800f64:	75 16                	jne    800f7c <__umoddi3+0x3c>
    {
      if (d0 > n1)
  800f66:	39 f1                	cmp    %esi,%ecx
  800f68:	0f 86 a6 00 00 00    	jbe    801014 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f6e:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800f70:	89 d0                	mov    %edx,%eax
  800f72:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f74:	83 c4 20             	add    $0x20,%esp
  800f77:	5e                   	pop    %esi
  800f78:	5f                   	pop    %edi
  800f79:	5d                   	pop    %ebp
  800f7a:	c3                   	ret    
  800f7b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800f7c:	39 f5                	cmp    %esi,%ebp
  800f7e:	0f 87 ac 00 00 00    	ja     801030 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800f84:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  800f87:	83 f0 1f             	xor    $0x1f,%eax
  800f8a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f8e:	0f 84 a8 00 00 00    	je     80103c <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800f94:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f98:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800f9a:	bf 20 00 00 00       	mov    $0x20,%edi
  800f9f:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800fa3:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800fa7:	89 f9                	mov    %edi,%ecx
  800fa9:	d3 e8                	shr    %cl,%eax
  800fab:	09 e8                	or     %ebp,%eax
  800fad:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  800fb1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800fb5:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800fb9:	d3 e0                	shl    %cl,%eax
  800fbb:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800fbf:	89 f2                	mov    %esi,%edx
  800fc1:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800fc3:	8b 44 24 14          	mov    0x14(%esp),%eax
  800fc7:	d3 e0                	shl    %cl,%eax
  800fc9:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800fcd:	8b 44 24 14          	mov    0x14(%esp),%eax
  800fd1:	89 f9                	mov    %edi,%ecx
  800fd3:	d3 e8                	shr    %cl,%eax
  800fd5:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800fd7:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800fd9:	89 f2                	mov    %esi,%edx
  800fdb:	f7 74 24 18          	divl   0x18(%esp)
  800fdf:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800fe1:	f7 64 24 0c          	mull   0xc(%esp)
  800fe5:	89 c5                	mov    %eax,%ebp
  800fe7:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800fe9:	39 d6                	cmp    %edx,%esi
  800feb:	72 67                	jb     801054 <__umoddi3+0x114>
  800fed:	74 75                	je     801064 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800fef:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800ff3:	29 e8                	sub    %ebp,%eax
  800ff5:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800ff7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800ffb:	d3 e8                	shr    %cl,%eax
  800ffd:	89 f2                	mov    %esi,%edx
  800fff:	89 f9                	mov    %edi,%ecx
  801001:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801003:	09 d0                	or     %edx,%eax
  801005:	89 f2                	mov    %esi,%edx
  801007:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80100b:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80100d:	83 c4 20             	add    $0x20,%esp
  801010:	5e                   	pop    %esi
  801011:	5f                   	pop    %edi
  801012:	5d                   	pop    %ebp
  801013:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801014:	85 c9                	test   %ecx,%ecx
  801016:	75 0b                	jne    801023 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801018:	b8 01 00 00 00       	mov    $0x1,%eax
  80101d:	31 d2                	xor    %edx,%edx
  80101f:	f7 f1                	div    %ecx
  801021:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801023:	89 f0                	mov    %esi,%eax
  801025:	31 d2                	xor    %edx,%edx
  801027:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801029:	89 f8                	mov    %edi,%eax
  80102b:	e9 3e ff ff ff       	jmp    800f6e <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801030:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801032:	83 c4 20             	add    $0x20,%esp
  801035:	5e                   	pop    %esi
  801036:	5f                   	pop    %edi
  801037:	5d                   	pop    %ebp
  801038:	c3                   	ret    
  801039:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80103c:	39 f5                	cmp    %esi,%ebp
  80103e:	72 04                	jb     801044 <__umoddi3+0x104>
  801040:	39 f9                	cmp    %edi,%ecx
  801042:	77 06                	ja     80104a <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801044:	89 f2                	mov    %esi,%edx
  801046:	29 cf                	sub    %ecx,%edi
  801048:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  80104a:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80104c:	83 c4 20             	add    $0x20,%esp
  80104f:	5e                   	pop    %esi
  801050:	5f                   	pop    %edi
  801051:	5d                   	pop    %ebp
  801052:	c3                   	ret    
  801053:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801054:	89 d1                	mov    %edx,%ecx
  801056:	89 c5                	mov    %eax,%ebp
  801058:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  80105c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801060:	eb 8d                	jmp    800fef <__umoddi3+0xaf>
  801062:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801064:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801068:	72 ea                	jb     801054 <__umoddi3+0x114>
  80106a:	89 f1                	mov    %esi,%ecx
  80106c:	eb 81                	jmp    800fef <__umoddi3+0xaf>
