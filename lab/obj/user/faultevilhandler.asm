
obj/user/faultevilhandler.debug:     file format elf32-i386


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
  80002c:	e8 47 00 00 00       	call   800078 <libmain>
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
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  80003a:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800041:	00 
  800042:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800049:	ee 
  80004a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800051:	e8 4b 01 00 00       	call   8001a1 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xF0100020);
  800056:	c7 44 24 04 20 00 10 	movl   $0xf0100020,0x4(%esp)
  80005d:	f0 
  80005e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800065:	e8 d7 02 00 00       	call   800341 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80006a:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800071:	00 00 00 
}
  800074:	c9                   	leave  
  800075:	c3                   	ret    
	...

00800078 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800078:	55                   	push   %ebp
  800079:	89 e5                	mov    %esp,%ebp
  80007b:	56                   	push   %esi
  80007c:	53                   	push   %ebx
  80007d:	83 ec 10             	sub    $0x10,%esp
  800080:	8b 75 08             	mov    0x8(%ebp),%esi
  800083:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800086:	e8 d8 00 00 00       	call   800163 <sys_getenvid>
  80008b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800090:	c1 e0 07             	shl    $0x7,%eax
  800093:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800098:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80009d:	85 f6                	test   %esi,%esi
  80009f:	7e 07                	jle    8000a8 <libmain+0x30>
		binaryname = argv[0];
  8000a1:	8b 03                	mov    (%ebx),%eax
  8000a3:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000a8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000ac:	89 34 24             	mov    %esi,(%esp)
  8000af:	e8 80 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000b4:	e8 07 00 00 00       	call   8000c0 <exit>
}
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	5b                   	pop    %ebx
  8000bd:	5e                   	pop    %esi
  8000be:	5d                   	pop    %ebp
  8000bf:	c3                   	ret    

008000c0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  8000c6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000cd:	e8 3f 00 00 00       	call   800111 <sys_env_destroy>
}
  8000d2:	c9                   	leave  
  8000d3:	c3                   	ret    

008000d4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000d4:	55                   	push   %ebp
  8000d5:	89 e5                	mov    %esp,%ebp
  8000d7:	57                   	push   %edi
  8000d8:	56                   	push   %esi
  8000d9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000da:	b8 00 00 00 00       	mov    $0x0,%eax
  8000df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e5:	89 c3                	mov    %eax,%ebx
  8000e7:	89 c7                	mov    %eax,%edi
  8000e9:	89 c6                	mov    %eax,%esi
  8000eb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ed:	5b                   	pop    %ebx
  8000ee:	5e                   	pop    %esi
  8000ef:	5f                   	pop    %edi
  8000f0:	5d                   	pop    %ebp
  8000f1:	c3                   	ret    

008000f2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000f2:	55                   	push   %ebp
  8000f3:	89 e5                	mov    %esp,%ebp
  8000f5:	57                   	push   %edi
  8000f6:	56                   	push   %esi
  8000f7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000fd:	b8 01 00 00 00       	mov    $0x1,%eax
  800102:	89 d1                	mov    %edx,%ecx
  800104:	89 d3                	mov    %edx,%ebx
  800106:	89 d7                	mov    %edx,%edi
  800108:	89 d6                	mov    %edx,%esi
  80010a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80010c:	5b                   	pop    %ebx
  80010d:	5e                   	pop    %esi
  80010e:	5f                   	pop    %edi
  80010f:	5d                   	pop    %ebp
  800110:	c3                   	ret    

00800111 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800111:	55                   	push   %ebp
  800112:	89 e5                	mov    %esp,%ebp
  800114:	57                   	push   %edi
  800115:	56                   	push   %esi
  800116:	53                   	push   %ebx
  800117:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80011f:	b8 03 00 00 00       	mov    $0x3,%eax
  800124:	8b 55 08             	mov    0x8(%ebp),%edx
  800127:	89 cb                	mov    %ecx,%ebx
  800129:	89 cf                	mov    %ecx,%edi
  80012b:	89 ce                	mov    %ecx,%esi
  80012d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80012f:	85 c0                	test   %eax,%eax
  800131:	7e 28                	jle    80015b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800133:	89 44 24 10          	mov    %eax,0x10(%esp)
  800137:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80013e:	00 
  80013f:	c7 44 24 08 ca 10 80 	movl   $0x8010ca,0x8(%esp)
  800146:	00 
  800147:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80014e:	00 
  80014f:	c7 04 24 e7 10 80 00 	movl   $0x8010e7,(%esp)
  800156:	e8 31 03 00 00       	call   80048c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80015b:	83 c4 2c             	add    $0x2c,%esp
  80015e:	5b                   	pop    %ebx
  80015f:	5e                   	pop    %esi
  800160:	5f                   	pop    %edi
  800161:	5d                   	pop    %ebp
  800162:	c3                   	ret    

00800163 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	57                   	push   %edi
  800167:	56                   	push   %esi
  800168:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800169:	ba 00 00 00 00       	mov    $0x0,%edx
  80016e:	b8 02 00 00 00       	mov    $0x2,%eax
  800173:	89 d1                	mov    %edx,%ecx
  800175:	89 d3                	mov    %edx,%ebx
  800177:	89 d7                	mov    %edx,%edi
  800179:	89 d6                	mov    %edx,%esi
  80017b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80017d:	5b                   	pop    %ebx
  80017e:	5e                   	pop    %esi
  80017f:	5f                   	pop    %edi
  800180:	5d                   	pop    %ebp
  800181:	c3                   	ret    

00800182 <sys_yield>:

void
sys_yield(void)
{
  800182:	55                   	push   %ebp
  800183:	89 e5                	mov    %esp,%ebp
  800185:	57                   	push   %edi
  800186:	56                   	push   %esi
  800187:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800188:	ba 00 00 00 00       	mov    $0x0,%edx
  80018d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800192:	89 d1                	mov    %edx,%ecx
  800194:	89 d3                	mov    %edx,%ebx
  800196:	89 d7                	mov    %edx,%edi
  800198:	89 d6                	mov    %edx,%esi
  80019a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80019c:	5b                   	pop    %ebx
  80019d:	5e                   	pop    %esi
  80019e:	5f                   	pop    %edi
  80019f:	5d                   	pop    %ebp
  8001a0:	c3                   	ret    

008001a1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	57                   	push   %edi
  8001a5:	56                   	push   %esi
  8001a6:	53                   	push   %ebx
  8001a7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001aa:	be 00 00 00 00       	mov    $0x0,%esi
  8001af:	b8 04 00 00 00       	mov    $0x4,%eax
  8001b4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bd:	89 f7                	mov    %esi,%edi
  8001bf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001c1:	85 c0                	test   %eax,%eax
  8001c3:	7e 28                	jle    8001ed <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001c9:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001d0:	00 
  8001d1:	c7 44 24 08 ca 10 80 	movl   $0x8010ca,0x8(%esp)
  8001d8:	00 
  8001d9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001e0:	00 
  8001e1:	c7 04 24 e7 10 80 00 	movl   $0x8010e7,(%esp)
  8001e8:	e8 9f 02 00 00       	call   80048c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001ed:	83 c4 2c             	add    $0x2c,%esp
  8001f0:	5b                   	pop    %ebx
  8001f1:	5e                   	pop    %esi
  8001f2:	5f                   	pop    %edi
  8001f3:	5d                   	pop    %ebp
  8001f4:	c3                   	ret    

008001f5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001f5:	55                   	push   %ebp
  8001f6:	89 e5                	mov    %esp,%ebp
  8001f8:	57                   	push   %edi
  8001f9:	56                   	push   %esi
  8001fa:	53                   	push   %ebx
  8001fb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001fe:	b8 05 00 00 00       	mov    $0x5,%eax
  800203:	8b 75 18             	mov    0x18(%ebp),%esi
  800206:	8b 7d 14             	mov    0x14(%ebp),%edi
  800209:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80020c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80020f:	8b 55 08             	mov    0x8(%ebp),%edx
  800212:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800214:	85 c0                	test   %eax,%eax
  800216:	7e 28                	jle    800240 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800218:	89 44 24 10          	mov    %eax,0x10(%esp)
  80021c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800223:	00 
  800224:	c7 44 24 08 ca 10 80 	movl   $0x8010ca,0x8(%esp)
  80022b:	00 
  80022c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800233:	00 
  800234:	c7 04 24 e7 10 80 00 	movl   $0x8010e7,(%esp)
  80023b:	e8 4c 02 00 00       	call   80048c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800240:	83 c4 2c             	add    $0x2c,%esp
  800243:	5b                   	pop    %ebx
  800244:	5e                   	pop    %esi
  800245:	5f                   	pop    %edi
  800246:	5d                   	pop    %ebp
  800247:	c3                   	ret    

00800248 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	57                   	push   %edi
  80024c:	56                   	push   %esi
  80024d:	53                   	push   %ebx
  80024e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800251:	bb 00 00 00 00       	mov    $0x0,%ebx
  800256:	b8 06 00 00 00       	mov    $0x6,%eax
  80025b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80025e:	8b 55 08             	mov    0x8(%ebp),%edx
  800261:	89 df                	mov    %ebx,%edi
  800263:	89 de                	mov    %ebx,%esi
  800265:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800267:	85 c0                	test   %eax,%eax
  800269:	7e 28                	jle    800293 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80026b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80026f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800276:	00 
  800277:	c7 44 24 08 ca 10 80 	movl   $0x8010ca,0x8(%esp)
  80027e:	00 
  80027f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800286:	00 
  800287:	c7 04 24 e7 10 80 00 	movl   $0x8010e7,(%esp)
  80028e:	e8 f9 01 00 00       	call   80048c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800293:	83 c4 2c             	add    $0x2c,%esp
  800296:	5b                   	pop    %ebx
  800297:	5e                   	pop    %esi
  800298:	5f                   	pop    %edi
  800299:	5d                   	pop    %ebp
  80029a:	c3                   	ret    

0080029b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80029b:	55                   	push   %ebp
  80029c:	89 e5                	mov    %esp,%ebp
  80029e:	57                   	push   %edi
  80029f:	56                   	push   %esi
  8002a0:	53                   	push   %ebx
  8002a1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002a4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002a9:	b8 08 00 00 00       	mov    $0x8,%eax
  8002ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b4:	89 df                	mov    %ebx,%edi
  8002b6:	89 de                	mov    %ebx,%esi
  8002b8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002ba:	85 c0                	test   %eax,%eax
  8002bc:	7e 28                	jle    8002e6 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002be:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002c2:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002c9:	00 
  8002ca:	c7 44 24 08 ca 10 80 	movl   $0x8010ca,0x8(%esp)
  8002d1:	00 
  8002d2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002d9:	00 
  8002da:	c7 04 24 e7 10 80 00 	movl   $0x8010e7,(%esp)
  8002e1:	e8 a6 01 00 00       	call   80048c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002e6:	83 c4 2c             	add    $0x2c,%esp
  8002e9:	5b                   	pop    %ebx
  8002ea:	5e                   	pop    %esi
  8002eb:	5f                   	pop    %edi
  8002ec:	5d                   	pop    %ebp
  8002ed:	c3                   	ret    

008002ee <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
  8002f1:	57                   	push   %edi
  8002f2:	56                   	push   %esi
  8002f3:	53                   	push   %ebx
  8002f4:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002fc:	b8 09 00 00 00       	mov    $0x9,%eax
  800301:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800304:	8b 55 08             	mov    0x8(%ebp),%edx
  800307:	89 df                	mov    %ebx,%edi
  800309:	89 de                	mov    %ebx,%esi
  80030b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80030d:	85 c0                	test   %eax,%eax
  80030f:	7e 28                	jle    800339 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800311:	89 44 24 10          	mov    %eax,0x10(%esp)
  800315:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80031c:	00 
  80031d:	c7 44 24 08 ca 10 80 	movl   $0x8010ca,0x8(%esp)
  800324:	00 
  800325:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80032c:	00 
  80032d:	c7 04 24 e7 10 80 00 	movl   $0x8010e7,(%esp)
  800334:	e8 53 01 00 00       	call   80048c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800339:	83 c4 2c             	add    $0x2c,%esp
  80033c:	5b                   	pop    %ebx
  80033d:	5e                   	pop    %esi
  80033e:	5f                   	pop    %edi
  80033f:	5d                   	pop    %ebp
  800340:	c3                   	ret    

00800341 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800341:	55                   	push   %ebp
  800342:	89 e5                	mov    %esp,%ebp
  800344:	57                   	push   %edi
  800345:	56                   	push   %esi
  800346:	53                   	push   %ebx
  800347:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80034a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80034f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800354:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800357:	8b 55 08             	mov    0x8(%ebp),%edx
  80035a:	89 df                	mov    %ebx,%edi
  80035c:	89 de                	mov    %ebx,%esi
  80035e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800360:	85 c0                	test   %eax,%eax
  800362:	7e 28                	jle    80038c <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800364:	89 44 24 10          	mov    %eax,0x10(%esp)
  800368:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80036f:	00 
  800370:	c7 44 24 08 ca 10 80 	movl   $0x8010ca,0x8(%esp)
  800377:	00 
  800378:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80037f:	00 
  800380:	c7 04 24 e7 10 80 00 	movl   $0x8010e7,(%esp)
  800387:	e8 00 01 00 00       	call   80048c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80038c:	83 c4 2c             	add    $0x2c,%esp
  80038f:	5b                   	pop    %ebx
  800390:	5e                   	pop    %esi
  800391:	5f                   	pop    %edi
  800392:	5d                   	pop    %ebp
  800393:	c3                   	ret    

00800394 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800394:	55                   	push   %ebp
  800395:	89 e5                	mov    %esp,%ebp
  800397:	57                   	push   %edi
  800398:	56                   	push   %esi
  800399:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80039a:	be 00 00 00 00       	mov    $0x0,%esi
  80039f:	b8 0c 00 00 00       	mov    $0xc,%eax
  8003a4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8003a7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003b2:	5b                   	pop    %ebx
  8003b3:	5e                   	pop    %esi
  8003b4:	5f                   	pop    %edi
  8003b5:	5d                   	pop    %ebp
  8003b6:	c3                   	ret    

008003b7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003b7:	55                   	push   %ebp
  8003b8:	89 e5                	mov    %esp,%ebp
  8003ba:	57                   	push   %edi
  8003bb:	56                   	push   %esi
  8003bc:	53                   	push   %ebx
  8003bd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003c0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003c5:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8003cd:	89 cb                	mov    %ecx,%ebx
  8003cf:	89 cf                	mov    %ecx,%edi
  8003d1:	89 ce                	mov    %ecx,%esi
  8003d3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003d5:	85 c0                	test   %eax,%eax
  8003d7:	7e 28                	jle    800401 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003d9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003dd:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003e4:	00 
  8003e5:	c7 44 24 08 ca 10 80 	movl   $0x8010ca,0x8(%esp)
  8003ec:	00 
  8003ed:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003f4:	00 
  8003f5:	c7 04 24 e7 10 80 00 	movl   $0x8010e7,(%esp)
  8003fc:	e8 8b 00 00 00       	call   80048c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800401:	83 c4 2c             	add    $0x2c,%esp
  800404:	5b                   	pop    %ebx
  800405:	5e                   	pop    %esi
  800406:	5f                   	pop    %edi
  800407:	5d                   	pop    %ebp
  800408:	c3                   	ret    

00800409 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800409:	55                   	push   %ebp
  80040a:	89 e5                	mov    %esp,%ebp
  80040c:	57                   	push   %edi
  80040d:	56                   	push   %esi
  80040e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80040f:	ba 00 00 00 00       	mov    $0x0,%edx
  800414:	b8 0e 00 00 00       	mov    $0xe,%eax
  800419:	89 d1                	mov    %edx,%ecx
  80041b:	89 d3                	mov    %edx,%ebx
  80041d:	89 d7                	mov    %edx,%edi
  80041f:	89 d6                	mov    %edx,%esi
  800421:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800423:	5b                   	pop    %ebx
  800424:	5e                   	pop    %esi
  800425:	5f                   	pop    %edi
  800426:	5d                   	pop    %ebp
  800427:	c3                   	ret    

00800428 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char* pck, size_t length){
  800428:	55                   	push   %ebp
  800429:	89 e5                	mov    %esp,%ebp
  80042b:	57                   	push   %edi
  80042c:	56                   	push   %esi
  80042d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80042e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800433:	b8 10 00 00 00       	mov    $0x10,%eax
  800438:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80043b:	8b 55 08             	mov    0x8(%ebp),%edx
  80043e:	89 df                	mov    %ebx,%edi
  800440:	89 de                	mov    %ebx,%esi
  800442:	cd 30                	int    $0x30
}

int 
sys_e1000_transmit(char* pck, size_t length){
	return syscall(SYS_e1000_transmit, 0, (uint32_t)pck, length, 0, 0, 0);
}
  800444:	5b                   	pop    %ebx
  800445:	5e                   	pop    %esi
  800446:	5f                   	pop    %edi
  800447:	5d                   	pop    %ebp
  800448:	c3                   	ret    

00800449 <sys_e1000_receive>:

int 
sys_e1000_receive(char* pck, size_t* length){
  800449:	55                   	push   %ebp
  80044a:	89 e5                	mov    %esp,%ebp
  80044c:	57                   	push   %edi
  80044d:	56                   	push   %esi
  80044e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80044f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800454:	b8 0f 00 00 00       	mov    $0xf,%eax
  800459:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80045c:	8b 55 08             	mov    0x8(%ebp),%edx
  80045f:	89 df                	mov    %ebx,%edi
  800461:	89 de                	mov    %ebx,%esi
  800463:	cd 30                	int    $0x30
}

int 
sys_e1000_receive(char* pck, size_t* length){
	return syscall(SYS_e1000_receive, 0, (uint32_t)pck, (uint32_t)length, 0, 0, 0);
}
  800465:	5b                   	pop    %ebx
  800466:	5e                   	pop    %esi
  800467:	5f                   	pop    %edi
  800468:	5d                   	pop    %ebp
  800469:	c3                   	ret    

0080046a <sys_e1000_get_mac>:

int 
sys_e1000_get_mac(uint8_t* mac_addr){
  80046a:	55                   	push   %ebp
  80046b:	89 e5                	mov    %esp,%ebp
  80046d:	57                   	push   %edi
  80046e:	56                   	push   %esi
  80046f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800470:	b9 00 00 00 00       	mov    $0x0,%ecx
  800475:	b8 11 00 00 00       	mov    $0x11,%eax
  80047a:	8b 55 08             	mov    0x8(%ebp),%edx
  80047d:	89 cb                	mov    %ecx,%ebx
  80047f:	89 cf                	mov    %ecx,%edi
  800481:	89 ce                	mov    %ecx,%esi
  800483:	cd 30                	int    $0x30
}

int 
sys_e1000_get_mac(uint8_t* mac_addr){
	return syscall(SYS_e1000_get_mac, 0, (uint32_t)mac_addr, 0, 0, 0, 0);
}
  800485:	5b                   	pop    %ebx
  800486:	5e                   	pop    %esi
  800487:	5f                   	pop    %edi
  800488:	5d                   	pop    %ebp
  800489:	c3                   	ret    
	...

0080048c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80048c:	55                   	push   %ebp
  80048d:	89 e5                	mov    %esp,%ebp
  80048f:	56                   	push   %esi
  800490:	53                   	push   %ebx
  800491:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800494:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800497:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80049d:	e8 c1 fc ff ff       	call   800163 <sys_getenvid>
  8004a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004a5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8004a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8004ac:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004b0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8004b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004b8:	c7 04 24 f8 10 80 00 	movl   $0x8010f8,(%esp)
  8004bf:	e8 c0 00 00 00       	call   800584 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8004c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004c8:	8b 45 10             	mov    0x10(%ebp),%eax
  8004cb:	89 04 24             	mov    %eax,(%esp)
  8004ce:	e8 50 00 00 00       	call   800523 <vcprintf>
	cprintf("\n");
  8004d3:	c7 04 24 1b 11 80 00 	movl   $0x80111b,(%esp)
  8004da:	e8 a5 00 00 00       	call   800584 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004df:	cc                   	int3   
  8004e0:	eb fd                	jmp    8004df <_panic+0x53>
	...

008004e4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004e4:	55                   	push   %ebp
  8004e5:	89 e5                	mov    %esp,%ebp
  8004e7:	53                   	push   %ebx
  8004e8:	83 ec 14             	sub    $0x14,%esp
  8004eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8004ee:	8b 03                	mov    (%ebx),%eax
  8004f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8004f3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8004f7:	40                   	inc    %eax
  8004f8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8004fa:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004ff:	75 19                	jne    80051a <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800501:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800508:	00 
  800509:	8d 43 08             	lea    0x8(%ebx),%eax
  80050c:	89 04 24             	mov    %eax,(%esp)
  80050f:	e8 c0 fb ff ff       	call   8000d4 <sys_cputs>
		b->idx = 0;
  800514:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80051a:	ff 43 04             	incl   0x4(%ebx)
}
  80051d:	83 c4 14             	add    $0x14,%esp
  800520:	5b                   	pop    %ebx
  800521:	5d                   	pop    %ebp
  800522:	c3                   	ret    

00800523 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800523:	55                   	push   %ebp
  800524:	89 e5                	mov    %esp,%ebp
  800526:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80052c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800533:	00 00 00 
	b.cnt = 0;
  800536:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80053d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800540:	8b 45 0c             	mov    0xc(%ebp),%eax
  800543:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800547:	8b 45 08             	mov    0x8(%ebp),%eax
  80054a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80054e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800554:	89 44 24 04          	mov    %eax,0x4(%esp)
  800558:	c7 04 24 e4 04 80 00 	movl   $0x8004e4,(%esp)
  80055f:	e8 82 01 00 00       	call   8006e6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800564:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80056a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80056e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800574:	89 04 24             	mov    %eax,(%esp)
  800577:	e8 58 fb ff ff       	call   8000d4 <sys_cputs>

	return b.cnt;
}
  80057c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800582:	c9                   	leave  
  800583:	c3                   	ret    

00800584 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800584:	55                   	push   %ebp
  800585:	89 e5                	mov    %esp,%ebp
  800587:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80058a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80058d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800591:	8b 45 08             	mov    0x8(%ebp),%eax
  800594:	89 04 24             	mov    %eax,(%esp)
  800597:	e8 87 ff ff ff       	call   800523 <vcprintf>
	va_end(ap);

	return cnt;
}
  80059c:	c9                   	leave  
  80059d:	c3                   	ret    
	...

008005a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005a0:	55                   	push   %ebp
  8005a1:	89 e5                	mov    %esp,%ebp
  8005a3:	57                   	push   %edi
  8005a4:	56                   	push   %esi
  8005a5:	53                   	push   %ebx
  8005a6:	83 ec 3c             	sub    $0x3c,%esp
  8005a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005ac:	89 d7                	mov    %edx,%edi
  8005ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8005b1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8005b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005b7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005ba:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8005bd:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005c0:	85 c0                	test   %eax,%eax
  8005c2:	75 08                	jne    8005cc <printnum+0x2c>
  8005c4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005c7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8005ca:	77 57                	ja     800623 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005cc:	89 74 24 10          	mov    %esi,0x10(%esp)
  8005d0:	4b                   	dec    %ebx
  8005d1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8005d5:	8b 45 10             	mov    0x10(%ebp),%eax
  8005d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005dc:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8005e0:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8005e4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005eb:	00 
  8005ec:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005ef:	89 04 24             	mov    %eax,(%esp)
  8005f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005f9:	e8 56 08 00 00       	call   800e54 <__udivdi3>
  8005fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800602:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800606:	89 04 24             	mov    %eax,(%esp)
  800609:	89 54 24 04          	mov    %edx,0x4(%esp)
  80060d:	89 fa                	mov    %edi,%edx
  80060f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800612:	e8 89 ff ff ff       	call   8005a0 <printnum>
  800617:	eb 0f                	jmp    800628 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800619:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80061d:	89 34 24             	mov    %esi,(%esp)
  800620:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800623:	4b                   	dec    %ebx
  800624:	85 db                	test   %ebx,%ebx
  800626:	7f f1                	jg     800619 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800628:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80062c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800630:	8b 45 10             	mov    0x10(%ebp),%eax
  800633:	89 44 24 08          	mov    %eax,0x8(%esp)
  800637:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80063e:	00 
  80063f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800642:	89 04 24             	mov    %eax,(%esp)
  800645:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800648:	89 44 24 04          	mov    %eax,0x4(%esp)
  80064c:	e8 23 09 00 00       	call   800f74 <__umoddi3>
  800651:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800655:	0f be 80 1d 11 80 00 	movsbl 0x80111d(%eax),%eax
  80065c:	89 04 24             	mov    %eax,(%esp)
  80065f:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800662:	83 c4 3c             	add    $0x3c,%esp
  800665:	5b                   	pop    %ebx
  800666:	5e                   	pop    %esi
  800667:	5f                   	pop    %edi
  800668:	5d                   	pop    %ebp
  800669:	c3                   	ret    

0080066a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80066a:	55                   	push   %ebp
  80066b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80066d:	83 fa 01             	cmp    $0x1,%edx
  800670:	7e 0e                	jle    800680 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800672:	8b 10                	mov    (%eax),%edx
  800674:	8d 4a 08             	lea    0x8(%edx),%ecx
  800677:	89 08                	mov    %ecx,(%eax)
  800679:	8b 02                	mov    (%edx),%eax
  80067b:	8b 52 04             	mov    0x4(%edx),%edx
  80067e:	eb 22                	jmp    8006a2 <getuint+0x38>
	else if (lflag)
  800680:	85 d2                	test   %edx,%edx
  800682:	74 10                	je     800694 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800684:	8b 10                	mov    (%eax),%edx
  800686:	8d 4a 04             	lea    0x4(%edx),%ecx
  800689:	89 08                	mov    %ecx,(%eax)
  80068b:	8b 02                	mov    (%edx),%eax
  80068d:	ba 00 00 00 00       	mov    $0x0,%edx
  800692:	eb 0e                	jmp    8006a2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800694:	8b 10                	mov    (%eax),%edx
  800696:	8d 4a 04             	lea    0x4(%edx),%ecx
  800699:	89 08                	mov    %ecx,(%eax)
  80069b:	8b 02                	mov    (%edx),%eax
  80069d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006a2:	5d                   	pop    %ebp
  8006a3:	c3                   	ret    

008006a4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8006a4:	55                   	push   %ebp
  8006a5:	89 e5                	mov    %esp,%ebp
  8006a7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006aa:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8006ad:	8b 10                	mov    (%eax),%edx
  8006af:	3b 50 04             	cmp    0x4(%eax),%edx
  8006b2:	73 08                	jae    8006bc <sprintputch+0x18>
		*b->buf++ = ch;
  8006b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006b7:	88 0a                	mov    %cl,(%edx)
  8006b9:	42                   	inc    %edx
  8006ba:	89 10                	mov    %edx,(%eax)
}
  8006bc:	5d                   	pop    %ebp
  8006bd:	c3                   	ret    

008006be <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006be:	55                   	push   %ebp
  8006bf:	89 e5                	mov    %esp,%ebp
  8006c1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8006c4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006cb:	8b 45 10             	mov    0x10(%ebp),%eax
  8006ce:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006dc:	89 04 24             	mov    %eax,(%esp)
  8006df:	e8 02 00 00 00       	call   8006e6 <vprintfmt>
	va_end(ap);
}
  8006e4:	c9                   	leave  
  8006e5:	c3                   	ret    

008006e6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006e6:	55                   	push   %ebp
  8006e7:	89 e5                	mov    %esp,%ebp
  8006e9:	57                   	push   %edi
  8006ea:	56                   	push   %esi
  8006eb:	53                   	push   %ebx
  8006ec:	83 ec 4c             	sub    $0x4c,%esp
  8006ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006f2:	8b 75 10             	mov    0x10(%ebp),%esi
  8006f5:	eb 12                	jmp    800709 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006f7:	85 c0                	test   %eax,%eax
  8006f9:	0f 84 6b 03 00 00    	je     800a6a <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8006ff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800703:	89 04 24             	mov    %eax,(%esp)
  800706:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800709:	0f b6 06             	movzbl (%esi),%eax
  80070c:	46                   	inc    %esi
  80070d:	83 f8 25             	cmp    $0x25,%eax
  800710:	75 e5                	jne    8006f7 <vprintfmt+0x11>
  800712:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800716:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80071d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800722:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800729:	b9 00 00 00 00       	mov    $0x0,%ecx
  80072e:	eb 26                	jmp    800756 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800730:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800733:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800737:	eb 1d                	jmp    800756 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800739:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80073c:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800740:	eb 14                	jmp    800756 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800742:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800745:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80074c:	eb 08                	jmp    800756 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80074e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800751:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800756:	0f b6 06             	movzbl (%esi),%eax
  800759:	8d 56 01             	lea    0x1(%esi),%edx
  80075c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80075f:	8a 16                	mov    (%esi),%dl
  800761:	83 ea 23             	sub    $0x23,%edx
  800764:	80 fa 55             	cmp    $0x55,%dl
  800767:	0f 87 e1 02 00 00    	ja     800a4e <vprintfmt+0x368>
  80076d:	0f b6 d2             	movzbl %dl,%edx
  800770:	ff 24 95 60 12 80 00 	jmp    *0x801260(,%edx,4)
  800777:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80077a:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80077f:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800782:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800786:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800789:	8d 50 d0             	lea    -0x30(%eax),%edx
  80078c:	83 fa 09             	cmp    $0x9,%edx
  80078f:	77 2a                	ja     8007bb <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800791:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800792:	eb eb                	jmp    80077f <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800794:	8b 45 14             	mov    0x14(%ebp),%eax
  800797:	8d 50 04             	lea    0x4(%eax),%edx
  80079a:	89 55 14             	mov    %edx,0x14(%ebp)
  80079d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80079f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8007a2:	eb 17                	jmp    8007bb <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8007a4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007a8:	78 98                	js     800742 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007aa:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007ad:	eb a7                	jmp    800756 <vprintfmt+0x70>
  8007af:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8007b2:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8007b9:	eb 9b                	jmp    800756 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8007bb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007bf:	79 95                	jns    800756 <vprintfmt+0x70>
  8007c1:	eb 8b                	jmp    80074e <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007c3:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c4:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8007c7:	eb 8d                	jmp    800756 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cc:	8d 50 04             	lea    0x4(%eax),%edx
  8007cf:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007d6:	8b 00                	mov    (%eax),%eax
  8007d8:	89 04 24             	mov    %eax,(%esp)
  8007db:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007de:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8007e1:	e9 23 ff ff ff       	jmp    800709 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8007e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e9:	8d 50 04             	lea    0x4(%eax),%edx
  8007ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ef:	8b 00                	mov    (%eax),%eax
  8007f1:	85 c0                	test   %eax,%eax
  8007f3:	79 02                	jns    8007f7 <vprintfmt+0x111>
  8007f5:	f7 d8                	neg    %eax
  8007f7:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8007f9:	83 f8 11             	cmp    $0x11,%eax
  8007fc:	7f 0b                	jg     800809 <vprintfmt+0x123>
  8007fe:	8b 04 85 c0 13 80 00 	mov    0x8013c0(,%eax,4),%eax
  800805:	85 c0                	test   %eax,%eax
  800807:	75 23                	jne    80082c <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800809:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80080d:	c7 44 24 08 35 11 80 	movl   $0x801135,0x8(%esp)
  800814:	00 
  800815:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800819:	8b 45 08             	mov    0x8(%ebp),%eax
  80081c:	89 04 24             	mov    %eax,(%esp)
  80081f:	e8 9a fe ff ff       	call   8006be <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800824:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800827:	e9 dd fe ff ff       	jmp    800709 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80082c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800830:	c7 44 24 08 3e 11 80 	movl   $0x80113e,0x8(%esp)
  800837:	00 
  800838:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80083c:	8b 55 08             	mov    0x8(%ebp),%edx
  80083f:	89 14 24             	mov    %edx,(%esp)
  800842:	e8 77 fe ff ff       	call   8006be <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800847:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80084a:	e9 ba fe ff ff       	jmp    800709 <vprintfmt+0x23>
  80084f:	89 f9                	mov    %edi,%ecx
  800851:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800854:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800857:	8b 45 14             	mov    0x14(%ebp),%eax
  80085a:	8d 50 04             	lea    0x4(%eax),%edx
  80085d:	89 55 14             	mov    %edx,0x14(%ebp)
  800860:	8b 30                	mov    (%eax),%esi
  800862:	85 f6                	test   %esi,%esi
  800864:	75 05                	jne    80086b <vprintfmt+0x185>
				p = "(null)";
  800866:	be 2e 11 80 00       	mov    $0x80112e,%esi
			if (width > 0 && padc != '-')
  80086b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80086f:	0f 8e 84 00 00 00    	jle    8008f9 <vprintfmt+0x213>
  800875:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800879:	74 7e                	je     8008f9 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80087b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80087f:	89 34 24             	mov    %esi,(%esp)
  800882:	e8 8b 02 00 00       	call   800b12 <strnlen>
  800887:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80088a:	29 c2                	sub    %eax,%edx
  80088c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80088f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800893:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800896:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800899:	89 de                	mov    %ebx,%esi
  80089b:	89 d3                	mov    %edx,%ebx
  80089d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80089f:	eb 0b                	jmp    8008ac <vprintfmt+0x1c6>
					putch(padc, putdat);
  8008a1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008a5:	89 3c 24             	mov    %edi,(%esp)
  8008a8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008ab:	4b                   	dec    %ebx
  8008ac:	85 db                	test   %ebx,%ebx
  8008ae:	7f f1                	jg     8008a1 <vprintfmt+0x1bb>
  8008b0:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8008b3:	89 f3                	mov    %esi,%ebx
  8008b5:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8008b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8008bb:	85 c0                	test   %eax,%eax
  8008bd:	79 05                	jns    8008c4 <vprintfmt+0x1de>
  8008bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008c7:	29 c2                	sub    %eax,%edx
  8008c9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8008cc:	eb 2b                	jmp    8008f9 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008ce:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8008d2:	74 18                	je     8008ec <vprintfmt+0x206>
  8008d4:	8d 50 e0             	lea    -0x20(%eax),%edx
  8008d7:	83 fa 5e             	cmp    $0x5e,%edx
  8008da:	76 10                	jbe    8008ec <vprintfmt+0x206>
					putch('?', putdat);
  8008dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008e0:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8008e7:	ff 55 08             	call   *0x8(%ebp)
  8008ea:	eb 0a                	jmp    8008f6 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8008ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008f0:	89 04 24             	mov    %eax,(%esp)
  8008f3:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008f6:	ff 4d e4             	decl   -0x1c(%ebp)
  8008f9:	0f be 06             	movsbl (%esi),%eax
  8008fc:	46                   	inc    %esi
  8008fd:	85 c0                	test   %eax,%eax
  8008ff:	74 21                	je     800922 <vprintfmt+0x23c>
  800901:	85 ff                	test   %edi,%edi
  800903:	78 c9                	js     8008ce <vprintfmt+0x1e8>
  800905:	4f                   	dec    %edi
  800906:	79 c6                	jns    8008ce <vprintfmt+0x1e8>
  800908:	8b 7d 08             	mov    0x8(%ebp),%edi
  80090b:	89 de                	mov    %ebx,%esi
  80090d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800910:	eb 18                	jmp    80092a <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800912:	89 74 24 04          	mov    %esi,0x4(%esp)
  800916:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80091d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80091f:	4b                   	dec    %ebx
  800920:	eb 08                	jmp    80092a <vprintfmt+0x244>
  800922:	8b 7d 08             	mov    0x8(%ebp),%edi
  800925:	89 de                	mov    %ebx,%esi
  800927:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80092a:	85 db                	test   %ebx,%ebx
  80092c:	7f e4                	jg     800912 <vprintfmt+0x22c>
  80092e:	89 7d 08             	mov    %edi,0x8(%ebp)
  800931:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800933:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800936:	e9 ce fd ff ff       	jmp    800709 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80093b:	83 f9 01             	cmp    $0x1,%ecx
  80093e:	7e 10                	jle    800950 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800940:	8b 45 14             	mov    0x14(%ebp),%eax
  800943:	8d 50 08             	lea    0x8(%eax),%edx
  800946:	89 55 14             	mov    %edx,0x14(%ebp)
  800949:	8b 30                	mov    (%eax),%esi
  80094b:	8b 78 04             	mov    0x4(%eax),%edi
  80094e:	eb 26                	jmp    800976 <vprintfmt+0x290>
	else if (lflag)
  800950:	85 c9                	test   %ecx,%ecx
  800952:	74 12                	je     800966 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800954:	8b 45 14             	mov    0x14(%ebp),%eax
  800957:	8d 50 04             	lea    0x4(%eax),%edx
  80095a:	89 55 14             	mov    %edx,0x14(%ebp)
  80095d:	8b 30                	mov    (%eax),%esi
  80095f:	89 f7                	mov    %esi,%edi
  800961:	c1 ff 1f             	sar    $0x1f,%edi
  800964:	eb 10                	jmp    800976 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800966:	8b 45 14             	mov    0x14(%ebp),%eax
  800969:	8d 50 04             	lea    0x4(%eax),%edx
  80096c:	89 55 14             	mov    %edx,0x14(%ebp)
  80096f:	8b 30                	mov    (%eax),%esi
  800971:	89 f7                	mov    %esi,%edi
  800973:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800976:	85 ff                	test   %edi,%edi
  800978:	78 0a                	js     800984 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80097a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80097f:	e9 8c 00 00 00       	jmp    800a10 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800984:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800988:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80098f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800992:	f7 de                	neg    %esi
  800994:	83 d7 00             	adc    $0x0,%edi
  800997:	f7 df                	neg    %edi
			}
			base = 10;
  800999:	b8 0a 00 00 00       	mov    $0xa,%eax
  80099e:	eb 70                	jmp    800a10 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009a0:	89 ca                	mov    %ecx,%edx
  8009a2:	8d 45 14             	lea    0x14(%ebp),%eax
  8009a5:	e8 c0 fc ff ff       	call   80066a <getuint>
  8009aa:	89 c6                	mov    %eax,%esi
  8009ac:	89 d7                	mov    %edx,%edi
			base = 10;
  8009ae:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8009b3:	eb 5b                	jmp    800a10 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  8009b5:	89 ca                	mov    %ecx,%edx
  8009b7:	8d 45 14             	lea    0x14(%ebp),%eax
  8009ba:	e8 ab fc ff ff       	call   80066a <getuint>
  8009bf:	89 c6                	mov    %eax,%esi
  8009c1:	89 d7                	mov    %edx,%edi
			base = 8;
  8009c3:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8009c8:	eb 46                	jmp    800a10 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  8009ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009ce:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8009d5:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8009d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009dc:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8009e3:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8009e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8009e9:	8d 50 04             	lea    0x4(%eax),%edx
  8009ec:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8009ef:	8b 30                	mov    (%eax),%esi
  8009f1:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8009f6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8009fb:	eb 13                	jmp    800a10 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8009fd:	89 ca                	mov    %ecx,%edx
  8009ff:	8d 45 14             	lea    0x14(%ebp),%eax
  800a02:	e8 63 fc ff ff       	call   80066a <getuint>
  800a07:	89 c6                	mov    %eax,%esi
  800a09:	89 d7                	mov    %edx,%edi
			base = 16;
  800a0b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a10:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800a14:	89 54 24 10          	mov    %edx,0x10(%esp)
  800a18:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a1b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a1f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a23:	89 34 24             	mov    %esi,(%esp)
  800a26:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a2a:	89 da                	mov    %ebx,%edx
  800a2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2f:	e8 6c fb ff ff       	call   8005a0 <printnum>
			break;
  800a34:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800a37:	e9 cd fc ff ff       	jmp    800709 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a3c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a40:	89 04 24             	mov    %eax,(%esp)
  800a43:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a46:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a49:	e9 bb fc ff ff       	jmp    800709 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a4e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a52:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a59:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a5c:	eb 01                	jmp    800a5f <vprintfmt+0x379>
  800a5e:	4e                   	dec    %esi
  800a5f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800a63:	75 f9                	jne    800a5e <vprintfmt+0x378>
  800a65:	e9 9f fc ff ff       	jmp    800709 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800a6a:	83 c4 4c             	add    $0x4c,%esp
  800a6d:	5b                   	pop    %ebx
  800a6e:	5e                   	pop    %esi
  800a6f:	5f                   	pop    %edi
  800a70:	5d                   	pop    %ebp
  800a71:	c3                   	ret    

00800a72 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a72:	55                   	push   %ebp
  800a73:	89 e5                	mov    %esp,%ebp
  800a75:	83 ec 28             	sub    $0x28,%esp
  800a78:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a7e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a81:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a85:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a88:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a8f:	85 c0                	test   %eax,%eax
  800a91:	74 30                	je     800ac3 <vsnprintf+0x51>
  800a93:	85 d2                	test   %edx,%edx
  800a95:	7e 33                	jle    800aca <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a97:	8b 45 14             	mov    0x14(%ebp),%eax
  800a9a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a9e:	8b 45 10             	mov    0x10(%ebp),%eax
  800aa1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aa5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800aa8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aac:	c7 04 24 a4 06 80 00 	movl   $0x8006a4,(%esp)
  800ab3:	e8 2e fc ff ff       	call   8006e6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ab8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800abb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800abe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ac1:	eb 0c                	jmp    800acf <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800ac3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ac8:	eb 05                	jmp    800acf <vsnprintf+0x5d>
  800aca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800acf:	c9                   	leave  
  800ad0:	c3                   	ret    

00800ad1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800ad1:	55                   	push   %ebp
  800ad2:	89 e5                	mov    %esp,%ebp
  800ad4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800ad7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800ada:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ade:	8b 45 10             	mov    0x10(%ebp),%eax
  800ae1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ae5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aec:	8b 45 08             	mov    0x8(%ebp),%eax
  800aef:	89 04 24             	mov    %eax,(%esp)
  800af2:	e8 7b ff ff ff       	call   800a72 <vsnprintf>
	va_end(ap);

	return rc;
}
  800af7:	c9                   	leave  
  800af8:	c3                   	ret    
  800af9:	00 00                	add    %al,(%eax)
	...

00800afc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800afc:	55                   	push   %ebp
  800afd:	89 e5                	mov    %esp,%ebp
  800aff:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b02:	b8 00 00 00 00       	mov    $0x0,%eax
  800b07:	eb 01                	jmp    800b0a <strlen+0xe>
		n++;
  800b09:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b0a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b0e:	75 f9                	jne    800b09 <strlen+0xd>
		n++;
	return n;
}
  800b10:	5d                   	pop    %ebp
  800b11:	c3                   	ret    

00800b12 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b12:	55                   	push   %ebp
  800b13:	89 e5                	mov    %esp,%ebp
  800b15:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800b18:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b1b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b20:	eb 01                	jmp    800b23 <strnlen+0x11>
		n++;
  800b22:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b23:	39 d0                	cmp    %edx,%eax
  800b25:	74 06                	je     800b2d <strnlen+0x1b>
  800b27:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800b2b:	75 f5                	jne    800b22 <strnlen+0x10>
		n++;
	return n;
}
  800b2d:	5d                   	pop    %ebp
  800b2e:	c3                   	ret    

00800b2f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	53                   	push   %ebx
  800b33:	8b 45 08             	mov    0x8(%ebp),%eax
  800b36:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b39:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800b41:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800b44:	42                   	inc    %edx
  800b45:	84 c9                	test   %cl,%cl
  800b47:	75 f5                	jne    800b3e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800b49:	5b                   	pop    %ebx
  800b4a:	5d                   	pop    %ebp
  800b4b:	c3                   	ret    

00800b4c <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b4c:	55                   	push   %ebp
  800b4d:	89 e5                	mov    %esp,%ebp
  800b4f:	53                   	push   %ebx
  800b50:	83 ec 08             	sub    $0x8,%esp
  800b53:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b56:	89 1c 24             	mov    %ebx,(%esp)
  800b59:	e8 9e ff ff ff       	call   800afc <strlen>
	strcpy(dst + len, src);
  800b5e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b61:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b65:	01 d8                	add    %ebx,%eax
  800b67:	89 04 24             	mov    %eax,(%esp)
  800b6a:	e8 c0 ff ff ff       	call   800b2f <strcpy>
	return dst;
}
  800b6f:	89 d8                	mov    %ebx,%eax
  800b71:	83 c4 08             	add    $0x8,%esp
  800b74:	5b                   	pop    %ebx
  800b75:	5d                   	pop    %ebp
  800b76:	c3                   	ret    

00800b77 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b77:	55                   	push   %ebp
  800b78:	89 e5                	mov    %esp,%ebp
  800b7a:	56                   	push   %esi
  800b7b:	53                   	push   %ebx
  800b7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b82:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b85:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b8a:	eb 0c                	jmp    800b98 <strncpy+0x21>
		*dst++ = *src;
  800b8c:	8a 1a                	mov    (%edx),%bl
  800b8e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b91:	80 3a 01             	cmpb   $0x1,(%edx)
  800b94:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b97:	41                   	inc    %ecx
  800b98:	39 f1                	cmp    %esi,%ecx
  800b9a:	75 f0                	jne    800b8c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b9c:	5b                   	pop    %ebx
  800b9d:	5e                   	pop    %esi
  800b9e:	5d                   	pop    %ebp
  800b9f:	c3                   	ret    

00800ba0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ba0:	55                   	push   %ebp
  800ba1:	89 e5                	mov    %esp,%ebp
  800ba3:	56                   	push   %esi
  800ba4:	53                   	push   %ebx
  800ba5:	8b 75 08             	mov    0x8(%ebp),%esi
  800ba8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bab:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800bae:	85 d2                	test   %edx,%edx
  800bb0:	75 0a                	jne    800bbc <strlcpy+0x1c>
  800bb2:	89 f0                	mov    %esi,%eax
  800bb4:	eb 1a                	jmp    800bd0 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800bb6:	88 18                	mov    %bl,(%eax)
  800bb8:	40                   	inc    %eax
  800bb9:	41                   	inc    %ecx
  800bba:	eb 02                	jmp    800bbe <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800bbc:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800bbe:	4a                   	dec    %edx
  800bbf:	74 0a                	je     800bcb <strlcpy+0x2b>
  800bc1:	8a 19                	mov    (%ecx),%bl
  800bc3:	84 db                	test   %bl,%bl
  800bc5:	75 ef                	jne    800bb6 <strlcpy+0x16>
  800bc7:	89 c2                	mov    %eax,%edx
  800bc9:	eb 02                	jmp    800bcd <strlcpy+0x2d>
  800bcb:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800bcd:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800bd0:	29 f0                	sub    %esi,%eax
}
  800bd2:	5b                   	pop    %ebx
  800bd3:	5e                   	pop    %esi
  800bd4:	5d                   	pop    %ebp
  800bd5:	c3                   	ret    

00800bd6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bdc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bdf:	eb 02                	jmp    800be3 <strcmp+0xd>
		p++, q++;
  800be1:	41                   	inc    %ecx
  800be2:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800be3:	8a 01                	mov    (%ecx),%al
  800be5:	84 c0                	test   %al,%al
  800be7:	74 04                	je     800bed <strcmp+0x17>
  800be9:	3a 02                	cmp    (%edx),%al
  800beb:	74 f4                	je     800be1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800bed:	0f b6 c0             	movzbl %al,%eax
  800bf0:	0f b6 12             	movzbl (%edx),%edx
  800bf3:	29 d0                	sub    %edx,%eax
}
  800bf5:	5d                   	pop    %ebp
  800bf6:	c3                   	ret    

00800bf7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800bf7:	55                   	push   %ebp
  800bf8:	89 e5                	mov    %esp,%ebp
  800bfa:	53                   	push   %ebx
  800bfb:	8b 45 08             	mov    0x8(%ebp),%eax
  800bfe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c01:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800c04:	eb 03                	jmp    800c09 <strncmp+0x12>
		n--, p++, q++;
  800c06:	4a                   	dec    %edx
  800c07:	40                   	inc    %eax
  800c08:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c09:	85 d2                	test   %edx,%edx
  800c0b:	74 14                	je     800c21 <strncmp+0x2a>
  800c0d:	8a 18                	mov    (%eax),%bl
  800c0f:	84 db                	test   %bl,%bl
  800c11:	74 04                	je     800c17 <strncmp+0x20>
  800c13:	3a 19                	cmp    (%ecx),%bl
  800c15:	74 ef                	je     800c06 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c17:	0f b6 00             	movzbl (%eax),%eax
  800c1a:	0f b6 11             	movzbl (%ecx),%edx
  800c1d:	29 d0                	sub    %edx,%eax
  800c1f:	eb 05                	jmp    800c26 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c21:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c26:	5b                   	pop    %ebx
  800c27:	5d                   	pop    %ebp
  800c28:	c3                   	ret    

00800c29 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c29:	55                   	push   %ebp
  800c2a:	89 e5                	mov    %esp,%ebp
  800c2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800c32:	eb 05                	jmp    800c39 <strchr+0x10>
		if (*s == c)
  800c34:	38 ca                	cmp    %cl,%dl
  800c36:	74 0c                	je     800c44 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c38:	40                   	inc    %eax
  800c39:	8a 10                	mov    (%eax),%dl
  800c3b:	84 d2                	test   %dl,%dl
  800c3d:	75 f5                	jne    800c34 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800c3f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c44:	5d                   	pop    %ebp
  800c45:	c3                   	ret    

00800c46 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c46:	55                   	push   %ebp
  800c47:	89 e5                	mov    %esp,%ebp
  800c49:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800c4f:	eb 05                	jmp    800c56 <strfind+0x10>
		if (*s == c)
  800c51:	38 ca                	cmp    %cl,%dl
  800c53:	74 07                	je     800c5c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c55:	40                   	inc    %eax
  800c56:	8a 10                	mov    (%eax),%dl
  800c58:	84 d2                	test   %dl,%dl
  800c5a:	75 f5                	jne    800c51 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800c5c:	5d                   	pop    %ebp
  800c5d:	c3                   	ret    

00800c5e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c5e:	55                   	push   %ebp
  800c5f:	89 e5                	mov    %esp,%ebp
  800c61:	57                   	push   %edi
  800c62:	56                   	push   %esi
  800c63:	53                   	push   %ebx
  800c64:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c67:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c6a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c6d:	85 c9                	test   %ecx,%ecx
  800c6f:	74 30                	je     800ca1 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c71:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c77:	75 25                	jne    800c9e <memset+0x40>
  800c79:	f6 c1 03             	test   $0x3,%cl
  800c7c:	75 20                	jne    800c9e <memset+0x40>
		c &= 0xFF;
  800c7e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c81:	89 d3                	mov    %edx,%ebx
  800c83:	c1 e3 08             	shl    $0x8,%ebx
  800c86:	89 d6                	mov    %edx,%esi
  800c88:	c1 e6 18             	shl    $0x18,%esi
  800c8b:	89 d0                	mov    %edx,%eax
  800c8d:	c1 e0 10             	shl    $0x10,%eax
  800c90:	09 f0                	or     %esi,%eax
  800c92:	09 d0                	or     %edx,%eax
  800c94:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c96:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800c99:	fc                   	cld    
  800c9a:	f3 ab                	rep stos %eax,%es:(%edi)
  800c9c:	eb 03                	jmp    800ca1 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c9e:	fc                   	cld    
  800c9f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ca1:	89 f8                	mov    %edi,%eax
  800ca3:	5b                   	pop    %ebx
  800ca4:	5e                   	pop    %esi
  800ca5:	5f                   	pop    %edi
  800ca6:	5d                   	pop    %ebp
  800ca7:	c3                   	ret    

00800ca8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ca8:	55                   	push   %ebp
  800ca9:	89 e5                	mov    %esp,%ebp
  800cab:	57                   	push   %edi
  800cac:	56                   	push   %esi
  800cad:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cb3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800cb6:	39 c6                	cmp    %eax,%esi
  800cb8:	73 34                	jae    800cee <memmove+0x46>
  800cba:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800cbd:	39 d0                	cmp    %edx,%eax
  800cbf:	73 2d                	jae    800cee <memmove+0x46>
		s += n;
		d += n;
  800cc1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cc4:	f6 c2 03             	test   $0x3,%dl
  800cc7:	75 1b                	jne    800ce4 <memmove+0x3c>
  800cc9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ccf:	75 13                	jne    800ce4 <memmove+0x3c>
  800cd1:	f6 c1 03             	test   $0x3,%cl
  800cd4:	75 0e                	jne    800ce4 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800cd6:	83 ef 04             	sub    $0x4,%edi
  800cd9:	8d 72 fc             	lea    -0x4(%edx),%esi
  800cdc:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800cdf:	fd                   	std    
  800ce0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ce2:	eb 07                	jmp    800ceb <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ce4:	4f                   	dec    %edi
  800ce5:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ce8:	fd                   	std    
  800ce9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ceb:	fc                   	cld    
  800cec:	eb 20                	jmp    800d0e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cee:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cf4:	75 13                	jne    800d09 <memmove+0x61>
  800cf6:	a8 03                	test   $0x3,%al
  800cf8:	75 0f                	jne    800d09 <memmove+0x61>
  800cfa:	f6 c1 03             	test   $0x3,%cl
  800cfd:	75 0a                	jne    800d09 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800cff:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800d02:	89 c7                	mov    %eax,%edi
  800d04:	fc                   	cld    
  800d05:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d07:	eb 05                	jmp    800d0e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d09:	89 c7                	mov    %eax,%edi
  800d0b:	fc                   	cld    
  800d0c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d0e:	5e                   	pop    %esi
  800d0f:	5f                   	pop    %edi
  800d10:	5d                   	pop    %ebp
  800d11:	c3                   	ret    

00800d12 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d12:	55                   	push   %ebp
  800d13:	89 e5                	mov    %esp,%ebp
  800d15:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d18:	8b 45 10             	mov    0x10(%ebp),%eax
  800d1b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d22:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d26:	8b 45 08             	mov    0x8(%ebp),%eax
  800d29:	89 04 24             	mov    %eax,(%esp)
  800d2c:	e8 77 ff ff ff       	call   800ca8 <memmove>
}
  800d31:	c9                   	leave  
  800d32:	c3                   	ret    

00800d33 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d33:	55                   	push   %ebp
  800d34:	89 e5                	mov    %esp,%ebp
  800d36:	57                   	push   %edi
  800d37:	56                   	push   %esi
  800d38:	53                   	push   %ebx
  800d39:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d3c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d42:	ba 00 00 00 00       	mov    $0x0,%edx
  800d47:	eb 16                	jmp    800d5f <memcmp+0x2c>
		if (*s1 != *s2)
  800d49:	8a 04 17             	mov    (%edi,%edx,1),%al
  800d4c:	42                   	inc    %edx
  800d4d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800d51:	38 c8                	cmp    %cl,%al
  800d53:	74 0a                	je     800d5f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800d55:	0f b6 c0             	movzbl %al,%eax
  800d58:	0f b6 c9             	movzbl %cl,%ecx
  800d5b:	29 c8                	sub    %ecx,%eax
  800d5d:	eb 09                	jmp    800d68 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d5f:	39 da                	cmp    %ebx,%edx
  800d61:	75 e6                	jne    800d49 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d63:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d68:	5b                   	pop    %ebx
  800d69:	5e                   	pop    %esi
  800d6a:	5f                   	pop    %edi
  800d6b:	5d                   	pop    %ebp
  800d6c:	c3                   	ret    

00800d6d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d6d:	55                   	push   %ebp
  800d6e:	89 e5                	mov    %esp,%ebp
  800d70:	8b 45 08             	mov    0x8(%ebp),%eax
  800d73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800d76:	89 c2                	mov    %eax,%edx
  800d78:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d7b:	eb 05                	jmp    800d82 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d7d:	38 08                	cmp    %cl,(%eax)
  800d7f:	74 05                	je     800d86 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d81:	40                   	inc    %eax
  800d82:	39 d0                	cmp    %edx,%eax
  800d84:	72 f7                	jb     800d7d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d86:	5d                   	pop    %ebp
  800d87:	c3                   	ret    

00800d88 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	57                   	push   %edi
  800d8c:	56                   	push   %esi
  800d8d:	53                   	push   %ebx
  800d8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d91:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d94:	eb 01                	jmp    800d97 <strtol+0xf>
		s++;
  800d96:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d97:	8a 02                	mov    (%edx),%al
  800d99:	3c 20                	cmp    $0x20,%al
  800d9b:	74 f9                	je     800d96 <strtol+0xe>
  800d9d:	3c 09                	cmp    $0x9,%al
  800d9f:	74 f5                	je     800d96 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800da1:	3c 2b                	cmp    $0x2b,%al
  800da3:	75 08                	jne    800dad <strtol+0x25>
		s++;
  800da5:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800da6:	bf 00 00 00 00       	mov    $0x0,%edi
  800dab:	eb 13                	jmp    800dc0 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800dad:	3c 2d                	cmp    $0x2d,%al
  800daf:	75 0a                	jne    800dbb <strtol+0x33>
		s++, neg = 1;
  800db1:	8d 52 01             	lea    0x1(%edx),%edx
  800db4:	bf 01 00 00 00       	mov    $0x1,%edi
  800db9:	eb 05                	jmp    800dc0 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800dbb:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800dc0:	85 db                	test   %ebx,%ebx
  800dc2:	74 05                	je     800dc9 <strtol+0x41>
  800dc4:	83 fb 10             	cmp    $0x10,%ebx
  800dc7:	75 28                	jne    800df1 <strtol+0x69>
  800dc9:	8a 02                	mov    (%edx),%al
  800dcb:	3c 30                	cmp    $0x30,%al
  800dcd:	75 10                	jne    800ddf <strtol+0x57>
  800dcf:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800dd3:	75 0a                	jne    800ddf <strtol+0x57>
		s += 2, base = 16;
  800dd5:	83 c2 02             	add    $0x2,%edx
  800dd8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ddd:	eb 12                	jmp    800df1 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800ddf:	85 db                	test   %ebx,%ebx
  800de1:	75 0e                	jne    800df1 <strtol+0x69>
  800de3:	3c 30                	cmp    $0x30,%al
  800de5:	75 05                	jne    800dec <strtol+0x64>
		s++, base = 8;
  800de7:	42                   	inc    %edx
  800de8:	b3 08                	mov    $0x8,%bl
  800dea:	eb 05                	jmp    800df1 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800dec:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800df1:	b8 00 00 00 00       	mov    $0x0,%eax
  800df6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800df8:	8a 0a                	mov    (%edx),%cl
  800dfa:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800dfd:	80 fb 09             	cmp    $0x9,%bl
  800e00:	77 08                	ja     800e0a <strtol+0x82>
			dig = *s - '0';
  800e02:	0f be c9             	movsbl %cl,%ecx
  800e05:	83 e9 30             	sub    $0x30,%ecx
  800e08:	eb 1e                	jmp    800e28 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800e0a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800e0d:	80 fb 19             	cmp    $0x19,%bl
  800e10:	77 08                	ja     800e1a <strtol+0x92>
			dig = *s - 'a' + 10;
  800e12:	0f be c9             	movsbl %cl,%ecx
  800e15:	83 e9 57             	sub    $0x57,%ecx
  800e18:	eb 0e                	jmp    800e28 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800e1a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800e1d:	80 fb 19             	cmp    $0x19,%bl
  800e20:	77 12                	ja     800e34 <strtol+0xac>
			dig = *s - 'A' + 10;
  800e22:	0f be c9             	movsbl %cl,%ecx
  800e25:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800e28:	39 f1                	cmp    %esi,%ecx
  800e2a:	7d 0c                	jge    800e38 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800e2c:	42                   	inc    %edx
  800e2d:	0f af c6             	imul   %esi,%eax
  800e30:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800e32:	eb c4                	jmp    800df8 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800e34:	89 c1                	mov    %eax,%ecx
  800e36:	eb 02                	jmp    800e3a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800e38:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800e3a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e3e:	74 05                	je     800e45 <strtol+0xbd>
		*endptr = (char *) s;
  800e40:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e43:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800e45:	85 ff                	test   %edi,%edi
  800e47:	74 04                	je     800e4d <strtol+0xc5>
  800e49:	89 c8                	mov    %ecx,%eax
  800e4b:	f7 d8                	neg    %eax
}
  800e4d:	5b                   	pop    %ebx
  800e4e:	5e                   	pop    %esi
  800e4f:	5f                   	pop    %edi
  800e50:	5d                   	pop    %ebp
  800e51:	c3                   	ret    
	...

00800e54 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800e54:	55                   	push   %ebp
  800e55:	57                   	push   %edi
  800e56:	56                   	push   %esi
  800e57:	83 ec 10             	sub    $0x10,%esp
  800e5a:	8b 74 24 20          	mov    0x20(%esp),%esi
  800e5e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800e62:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e66:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  800e6a:	89 cd                	mov    %ecx,%ebp
  800e6c:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e70:	85 c0                	test   %eax,%eax
  800e72:	75 2c                	jne    800ea0 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800e74:	39 f9                	cmp    %edi,%ecx
  800e76:	77 68                	ja     800ee0 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800e78:	85 c9                	test   %ecx,%ecx
  800e7a:	75 0b                	jne    800e87 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800e7c:	b8 01 00 00 00       	mov    $0x1,%eax
  800e81:	31 d2                	xor    %edx,%edx
  800e83:	f7 f1                	div    %ecx
  800e85:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800e87:	31 d2                	xor    %edx,%edx
  800e89:	89 f8                	mov    %edi,%eax
  800e8b:	f7 f1                	div    %ecx
  800e8d:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e8f:	89 f0                	mov    %esi,%eax
  800e91:	f7 f1                	div    %ecx
  800e93:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e95:	89 f0                	mov    %esi,%eax
  800e97:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e99:	83 c4 10             	add    $0x10,%esp
  800e9c:	5e                   	pop    %esi
  800e9d:	5f                   	pop    %edi
  800e9e:	5d                   	pop    %ebp
  800e9f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800ea0:	39 f8                	cmp    %edi,%eax
  800ea2:	77 2c                	ja     800ed0 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800ea4:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  800ea7:	83 f6 1f             	xor    $0x1f,%esi
  800eaa:	75 4c                	jne    800ef8 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800eac:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800eae:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800eb3:	72 0a                	jb     800ebf <__udivdi3+0x6b>
  800eb5:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800eb9:	0f 87 ad 00 00 00    	ja     800f6c <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800ebf:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800ec4:	89 f0                	mov    %esi,%eax
  800ec6:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800ec8:	83 c4 10             	add    $0x10,%esp
  800ecb:	5e                   	pop    %esi
  800ecc:	5f                   	pop    %edi
  800ecd:	5d                   	pop    %ebp
  800ece:	c3                   	ret    
  800ecf:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800ed0:	31 ff                	xor    %edi,%edi
  800ed2:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800ed4:	89 f0                	mov    %esi,%eax
  800ed6:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800ed8:	83 c4 10             	add    $0x10,%esp
  800edb:	5e                   	pop    %esi
  800edc:	5f                   	pop    %edi
  800edd:	5d                   	pop    %ebp
  800ede:	c3                   	ret    
  800edf:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ee0:	89 fa                	mov    %edi,%edx
  800ee2:	89 f0                	mov    %esi,%eax
  800ee4:	f7 f1                	div    %ecx
  800ee6:	89 c6                	mov    %eax,%esi
  800ee8:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800eea:	89 f0                	mov    %esi,%eax
  800eec:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800eee:	83 c4 10             	add    $0x10,%esp
  800ef1:	5e                   	pop    %esi
  800ef2:	5f                   	pop    %edi
  800ef3:	5d                   	pop    %ebp
  800ef4:	c3                   	ret    
  800ef5:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800ef8:	89 f1                	mov    %esi,%ecx
  800efa:	d3 e0                	shl    %cl,%eax
  800efc:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800f00:	b8 20 00 00 00       	mov    $0x20,%eax
  800f05:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800f07:	89 ea                	mov    %ebp,%edx
  800f09:	88 c1                	mov    %al,%cl
  800f0b:	d3 ea                	shr    %cl,%edx
  800f0d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800f11:	09 ca                	or     %ecx,%edx
  800f13:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  800f17:	89 f1                	mov    %esi,%ecx
  800f19:	d3 e5                	shl    %cl,%ebp
  800f1b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  800f1f:	89 fd                	mov    %edi,%ebp
  800f21:	88 c1                	mov    %al,%cl
  800f23:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  800f25:	89 fa                	mov    %edi,%edx
  800f27:	89 f1                	mov    %esi,%ecx
  800f29:	d3 e2                	shl    %cl,%edx
  800f2b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f2f:	88 c1                	mov    %al,%cl
  800f31:	d3 ef                	shr    %cl,%edi
  800f33:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800f35:	89 f8                	mov    %edi,%eax
  800f37:	89 ea                	mov    %ebp,%edx
  800f39:	f7 74 24 08          	divl   0x8(%esp)
  800f3d:	89 d1                	mov    %edx,%ecx
  800f3f:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  800f41:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f45:	39 d1                	cmp    %edx,%ecx
  800f47:	72 17                	jb     800f60 <__udivdi3+0x10c>
  800f49:	74 09                	je     800f54 <__udivdi3+0x100>
  800f4b:	89 fe                	mov    %edi,%esi
  800f4d:	31 ff                	xor    %edi,%edi
  800f4f:	e9 41 ff ff ff       	jmp    800e95 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800f54:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f58:	89 f1                	mov    %esi,%ecx
  800f5a:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f5c:	39 c2                	cmp    %eax,%edx
  800f5e:	73 eb                	jae    800f4b <__udivdi3+0xf7>
		{
		  q0--;
  800f60:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f63:	31 ff                	xor    %edi,%edi
  800f65:	e9 2b ff ff ff       	jmp    800e95 <__udivdi3+0x41>
  800f6a:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800f6c:	31 f6                	xor    %esi,%esi
  800f6e:	e9 22 ff ff ff       	jmp    800e95 <__udivdi3+0x41>
	...

00800f74 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800f74:	55                   	push   %ebp
  800f75:	57                   	push   %edi
  800f76:	56                   	push   %esi
  800f77:	83 ec 20             	sub    $0x20,%esp
  800f7a:	8b 44 24 30          	mov    0x30(%esp),%eax
  800f7e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800f82:	89 44 24 14          	mov    %eax,0x14(%esp)
  800f86:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  800f8a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800f8e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800f92:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  800f94:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800f96:	85 ed                	test   %ebp,%ebp
  800f98:	75 16                	jne    800fb0 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  800f9a:	39 f1                	cmp    %esi,%ecx
  800f9c:	0f 86 a6 00 00 00    	jbe    801048 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800fa2:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800fa4:	89 d0                	mov    %edx,%eax
  800fa6:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800fa8:	83 c4 20             	add    $0x20,%esp
  800fab:	5e                   	pop    %esi
  800fac:	5f                   	pop    %edi
  800fad:	5d                   	pop    %ebp
  800fae:	c3                   	ret    
  800faf:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800fb0:	39 f5                	cmp    %esi,%ebp
  800fb2:	0f 87 ac 00 00 00    	ja     801064 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800fb8:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  800fbb:	83 f0 1f             	xor    $0x1f,%eax
  800fbe:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fc2:	0f 84 a8 00 00 00    	je     801070 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800fc8:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800fcc:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800fce:	bf 20 00 00 00       	mov    $0x20,%edi
  800fd3:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800fd7:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800fdb:	89 f9                	mov    %edi,%ecx
  800fdd:	d3 e8                	shr    %cl,%eax
  800fdf:	09 e8                	or     %ebp,%eax
  800fe1:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  800fe5:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800fe9:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800fed:	d3 e0                	shl    %cl,%eax
  800fef:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800ff3:	89 f2                	mov    %esi,%edx
  800ff5:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800ff7:	8b 44 24 14          	mov    0x14(%esp),%eax
  800ffb:	d3 e0                	shl    %cl,%eax
  800ffd:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801001:	8b 44 24 14          	mov    0x14(%esp),%eax
  801005:	89 f9                	mov    %edi,%ecx
  801007:	d3 e8                	shr    %cl,%eax
  801009:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80100b:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80100d:	89 f2                	mov    %esi,%edx
  80100f:	f7 74 24 18          	divl   0x18(%esp)
  801013:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801015:	f7 64 24 0c          	mull   0xc(%esp)
  801019:	89 c5                	mov    %eax,%ebp
  80101b:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80101d:	39 d6                	cmp    %edx,%esi
  80101f:	72 67                	jb     801088 <__umoddi3+0x114>
  801021:	74 75                	je     801098 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801023:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801027:	29 e8                	sub    %ebp,%eax
  801029:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80102b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80102f:	d3 e8                	shr    %cl,%eax
  801031:	89 f2                	mov    %esi,%edx
  801033:	89 f9                	mov    %edi,%ecx
  801035:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801037:	09 d0                	or     %edx,%eax
  801039:	89 f2                	mov    %esi,%edx
  80103b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80103f:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801041:	83 c4 20             	add    $0x20,%esp
  801044:	5e                   	pop    %esi
  801045:	5f                   	pop    %edi
  801046:	5d                   	pop    %ebp
  801047:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801048:	85 c9                	test   %ecx,%ecx
  80104a:	75 0b                	jne    801057 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80104c:	b8 01 00 00 00       	mov    $0x1,%eax
  801051:	31 d2                	xor    %edx,%edx
  801053:	f7 f1                	div    %ecx
  801055:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801057:	89 f0                	mov    %esi,%eax
  801059:	31 d2                	xor    %edx,%edx
  80105b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80105d:	89 f8                	mov    %edi,%eax
  80105f:	e9 3e ff ff ff       	jmp    800fa2 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801064:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801066:	83 c4 20             	add    $0x20,%esp
  801069:	5e                   	pop    %esi
  80106a:	5f                   	pop    %edi
  80106b:	5d                   	pop    %ebp
  80106c:	c3                   	ret    
  80106d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801070:	39 f5                	cmp    %esi,%ebp
  801072:	72 04                	jb     801078 <__umoddi3+0x104>
  801074:	39 f9                	cmp    %edi,%ecx
  801076:	77 06                	ja     80107e <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801078:	89 f2                	mov    %esi,%edx
  80107a:	29 cf                	sub    %ecx,%edi
  80107c:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  80107e:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801080:	83 c4 20             	add    $0x20,%esp
  801083:	5e                   	pop    %esi
  801084:	5f                   	pop    %edi
  801085:	5d                   	pop    %ebp
  801086:	c3                   	ret    
  801087:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801088:	89 d1                	mov    %edx,%ecx
  80108a:	89 c5                	mov    %eax,%ebp
  80108c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801090:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801094:	eb 8d                	jmp    801023 <__umoddi3+0xaf>
  801096:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801098:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  80109c:	72 ea                	jb     801088 <__umoddi3+0x114>
  80109e:	89 f1                	mov    %esi,%ecx
  8010a0:	eb 81                	jmp    801023 <__umoddi3+0xaf>
