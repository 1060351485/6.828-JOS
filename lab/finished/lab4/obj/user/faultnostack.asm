
obj/user/faultnostack:     file format elf32-i386


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
  80002c:	e8 2b 00 00 00       	call   80005c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  80003a:	c7 44 24 04 a8 03 80 	movl   $0x8003a8,0x4(%esp)
  800041:	00 
  800042:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800049:	e8 90 02 00 00       	call   8002de <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80004e:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800055:	00 00 00 
}
  800058:	c9                   	leave  
  800059:	c3                   	ret    
	...

0080005c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005c:	55                   	push   %ebp
  80005d:	89 e5                	mov    %esp,%ebp
  80005f:	56                   	push   %esi
  800060:	53                   	push   %ebx
  800061:	83 ec 10             	sub    $0x10,%esp
  800064:	8b 75 08             	mov    0x8(%ebp),%esi
  800067:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80006a:	e8 e4 00 00 00       	call   800153 <sys_getenvid>
  80006f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800074:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80007b:	c1 e0 07             	shl    $0x7,%eax
  80007e:	29 d0                	sub    %edx,%eax
  800080:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800085:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008a:	85 f6                	test   %esi,%esi
  80008c:	7e 07                	jle    800095 <libmain+0x39>
		binaryname = argv[0];
  80008e:	8b 03                	mov    (%ebx),%eax
  800090:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800095:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800099:	89 34 24             	mov    %esi,(%esp)
  80009c:	e8 93 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a1:	e8 0a 00 00 00       	call   8000b0 <exit>
}
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	5b                   	pop    %ebx
  8000aa:	5e                   	pop    %esi
  8000ab:	5d                   	pop    %ebp
  8000ac:	c3                   	ret    
  8000ad:	00 00                	add    %al,(%eax)
	...

008000b0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000bd:	e8 3f 00 00 00       	call   800101 <sys_env_destroy>
}
  8000c2:	c9                   	leave  
  8000c3:	c3                   	ret    

008000c4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	57                   	push   %edi
  8000c8:	56                   	push   %esi
  8000c9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8000cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d5:	89 c3                	mov    %eax,%ebx
  8000d7:	89 c7                	mov    %eax,%edi
  8000d9:	89 c6                	mov    %eax,%esi
  8000db:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000dd:	5b                   	pop    %ebx
  8000de:	5e                   	pop    %esi
  8000df:	5f                   	pop    %edi
  8000e0:	5d                   	pop    %ebp
  8000e1:	c3                   	ret    

008000e2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e2:	55                   	push   %ebp
  8000e3:	89 e5                	mov    %esp,%ebp
  8000e5:	57                   	push   %edi
  8000e6:	56                   	push   %esi
  8000e7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ed:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f2:	89 d1                	mov    %edx,%ecx
  8000f4:	89 d3                	mov    %edx,%ebx
  8000f6:	89 d7                	mov    %edx,%edi
  8000f8:	89 d6                	mov    %edx,%esi
  8000fa:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000fc:	5b                   	pop    %ebx
  8000fd:	5e                   	pop    %esi
  8000fe:	5f                   	pop    %edi
  8000ff:	5d                   	pop    %ebp
  800100:	c3                   	ret    

00800101 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800101:	55                   	push   %ebp
  800102:	89 e5                	mov    %esp,%ebp
  800104:	57                   	push   %edi
  800105:	56                   	push   %esi
  800106:	53                   	push   %ebx
  800107:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80010a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80010f:	b8 03 00 00 00       	mov    $0x3,%eax
  800114:	8b 55 08             	mov    0x8(%ebp),%edx
  800117:	89 cb                	mov    %ecx,%ebx
  800119:	89 cf                	mov    %ecx,%edi
  80011b:	89 ce                	mov    %ecx,%esi
  80011d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80011f:	85 c0                	test   %eax,%eax
  800121:	7e 28                	jle    80014b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800123:	89 44 24 10          	mov    %eax,0x10(%esp)
  800127:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80012e:	00 
  80012f:	c7 44 24 08 6a 10 80 	movl   $0x80106a,0x8(%esp)
  800136:	00 
  800137:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80013e:	00 
  80013f:	c7 04 24 87 10 80 00 	movl   $0x801087,(%esp)
  800146:	e8 81 02 00 00       	call   8003cc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80014b:	83 c4 2c             	add    $0x2c,%esp
  80014e:	5b                   	pop    %ebx
  80014f:	5e                   	pop    %esi
  800150:	5f                   	pop    %edi
  800151:	5d                   	pop    %ebp
  800152:	c3                   	ret    

00800153 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	57                   	push   %edi
  800157:	56                   	push   %esi
  800158:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800159:	ba 00 00 00 00       	mov    $0x0,%edx
  80015e:	b8 02 00 00 00       	mov    $0x2,%eax
  800163:	89 d1                	mov    %edx,%ecx
  800165:	89 d3                	mov    %edx,%ebx
  800167:	89 d7                	mov    %edx,%edi
  800169:	89 d6                	mov    %edx,%esi
  80016b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80016d:	5b                   	pop    %ebx
  80016e:	5e                   	pop    %esi
  80016f:	5f                   	pop    %edi
  800170:	5d                   	pop    %ebp
  800171:	c3                   	ret    

00800172 <sys_yield>:

void
sys_yield(void)
{
  800172:	55                   	push   %ebp
  800173:	89 e5                	mov    %esp,%ebp
  800175:	57                   	push   %edi
  800176:	56                   	push   %esi
  800177:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800178:	ba 00 00 00 00       	mov    $0x0,%edx
  80017d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800182:	89 d1                	mov    %edx,%ecx
  800184:	89 d3                	mov    %edx,%ebx
  800186:	89 d7                	mov    %edx,%edi
  800188:	89 d6                	mov    %edx,%esi
  80018a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80018c:	5b                   	pop    %ebx
  80018d:	5e                   	pop    %esi
  80018e:	5f                   	pop    %edi
  80018f:	5d                   	pop    %ebp
  800190:	c3                   	ret    

00800191 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800191:	55                   	push   %ebp
  800192:	89 e5                	mov    %esp,%ebp
  800194:	57                   	push   %edi
  800195:	56                   	push   %esi
  800196:	53                   	push   %ebx
  800197:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80019a:	be 00 00 00 00       	mov    $0x0,%esi
  80019f:	b8 04 00 00 00       	mov    $0x4,%eax
  8001a4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ad:	89 f7                	mov    %esi,%edi
  8001af:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001b1:	85 c0                	test   %eax,%eax
  8001b3:	7e 28                	jle    8001dd <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001b5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001b9:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001c0:	00 
  8001c1:	c7 44 24 08 6a 10 80 	movl   $0x80106a,0x8(%esp)
  8001c8:	00 
  8001c9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001d0:	00 
  8001d1:	c7 04 24 87 10 80 00 	movl   $0x801087,(%esp)
  8001d8:	e8 ef 01 00 00       	call   8003cc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001dd:	83 c4 2c             	add    $0x2c,%esp
  8001e0:	5b                   	pop    %ebx
  8001e1:	5e                   	pop    %esi
  8001e2:	5f                   	pop    %edi
  8001e3:	5d                   	pop    %ebp
  8001e4:	c3                   	ret    

008001e5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001e5:	55                   	push   %ebp
  8001e6:	89 e5                	mov    %esp,%ebp
  8001e8:	57                   	push   %edi
  8001e9:	56                   	push   %esi
  8001ea:	53                   	push   %ebx
  8001eb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ee:	b8 05 00 00 00       	mov    $0x5,%eax
  8001f3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001f6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001f9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ff:	8b 55 08             	mov    0x8(%ebp),%edx
  800202:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800204:	85 c0                	test   %eax,%eax
  800206:	7e 28                	jle    800230 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800208:	89 44 24 10          	mov    %eax,0x10(%esp)
  80020c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800213:	00 
  800214:	c7 44 24 08 6a 10 80 	movl   $0x80106a,0x8(%esp)
  80021b:	00 
  80021c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800223:	00 
  800224:	c7 04 24 87 10 80 00 	movl   $0x801087,(%esp)
  80022b:	e8 9c 01 00 00       	call   8003cc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800230:	83 c4 2c             	add    $0x2c,%esp
  800233:	5b                   	pop    %ebx
  800234:	5e                   	pop    %esi
  800235:	5f                   	pop    %edi
  800236:	5d                   	pop    %ebp
  800237:	c3                   	ret    

00800238 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	57                   	push   %edi
  80023c:	56                   	push   %esi
  80023d:	53                   	push   %ebx
  80023e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800241:	bb 00 00 00 00       	mov    $0x0,%ebx
  800246:	b8 06 00 00 00       	mov    $0x6,%eax
  80024b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80024e:	8b 55 08             	mov    0x8(%ebp),%edx
  800251:	89 df                	mov    %ebx,%edi
  800253:	89 de                	mov    %ebx,%esi
  800255:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800257:	85 c0                	test   %eax,%eax
  800259:	7e 28                	jle    800283 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80025b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80025f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800266:	00 
  800267:	c7 44 24 08 6a 10 80 	movl   $0x80106a,0x8(%esp)
  80026e:	00 
  80026f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800276:	00 
  800277:	c7 04 24 87 10 80 00 	movl   $0x801087,(%esp)
  80027e:	e8 49 01 00 00       	call   8003cc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800283:	83 c4 2c             	add    $0x2c,%esp
  800286:	5b                   	pop    %ebx
  800287:	5e                   	pop    %esi
  800288:	5f                   	pop    %edi
  800289:	5d                   	pop    %ebp
  80028a:	c3                   	ret    

0080028b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80028b:	55                   	push   %ebp
  80028c:	89 e5                	mov    %esp,%ebp
  80028e:	57                   	push   %edi
  80028f:	56                   	push   %esi
  800290:	53                   	push   %ebx
  800291:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800294:	bb 00 00 00 00       	mov    $0x0,%ebx
  800299:	b8 08 00 00 00       	mov    $0x8,%eax
  80029e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a4:	89 df                	mov    %ebx,%edi
  8002a6:	89 de                	mov    %ebx,%esi
  8002a8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002aa:	85 c0                	test   %eax,%eax
  8002ac:	7e 28                	jle    8002d6 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ae:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002b2:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002b9:	00 
  8002ba:	c7 44 24 08 6a 10 80 	movl   $0x80106a,0x8(%esp)
  8002c1:	00 
  8002c2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002c9:	00 
  8002ca:	c7 04 24 87 10 80 00 	movl   $0x801087,(%esp)
  8002d1:	e8 f6 00 00 00       	call   8003cc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002d6:	83 c4 2c             	add    $0x2c,%esp
  8002d9:	5b                   	pop    %ebx
  8002da:	5e                   	pop    %esi
  8002db:	5f                   	pop    %edi
  8002dc:	5d                   	pop    %ebp
  8002dd:	c3                   	ret    

008002de <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002de:	55                   	push   %ebp
  8002df:	89 e5                	mov    %esp,%ebp
  8002e1:	57                   	push   %edi
  8002e2:	56                   	push   %esi
  8002e3:	53                   	push   %ebx
  8002e4:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ec:	b8 09 00 00 00       	mov    $0x9,%eax
  8002f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f7:	89 df                	mov    %ebx,%edi
  8002f9:	89 de                	mov    %ebx,%esi
  8002fb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002fd:	85 c0                	test   %eax,%eax
  8002ff:	7e 28                	jle    800329 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800301:	89 44 24 10          	mov    %eax,0x10(%esp)
  800305:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80030c:	00 
  80030d:	c7 44 24 08 6a 10 80 	movl   $0x80106a,0x8(%esp)
  800314:	00 
  800315:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80031c:	00 
  80031d:	c7 04 24 87 10 80 00 	movl   $0x801087,(%esp)
  800324:	e8 a3 00 00 00       	call   8003cc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800329:	83 c4 2c             	add    $0x2c,%esp
  80032c:	5b                   	pop    %ebx
  80032d:	5e                   	pop    %esi
  80032e:	5f                   	pop    %edi
  80032f:	5d                   	pop    %ebp
  800330:	c3                   	ret    

00800331 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	57                   	push   %edi
  800335:	56                   	push   %esi
  800336:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800337:	be 00 00 00 00       	mov    $0x0,%esi
  80033c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800341:	8b 7d 14             	mov    0x14(%ebp),%edi
  800344:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800347:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80034a:	8b 55 08             	mov    0x8(%ebp),%edx
  80034d:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80034f:	5b                   	pop    %ebx
  800350:	5e                   	pop    %esi
  800351:	5f                   	pop    %edi
  800352:	5d                   	pop    %ebp
  800353:	c3                   	ret    

00800354 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
  800357:	57                   	push   %edi
  800358:	56                   	push   %esi
  800359:	53                   	push   %ebx
  80035a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80035d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800362:	b8 0c 00 00 00       	mov    $0xc,%eax
  800367:	8b 55 08             	mov    0x8(%ebp),%edx
  80036a:	89 cb                	mov    %ecx,%ebx
  80036c:	89 cf                	mov    %ecx,%edi
  80036e:	89 ce                	mov    %ecx,%esi
  800370:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800372:	85 c0                	test   %eax,%eax
  800374:	7e 28                	jle    80039e <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800376:	89 44 24 10          	mov    %eax,0x10(%esp)
  80037a:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800381:	00 
  800382:	c7 44 24 08 6a 10 80 	movl   $0x80106a,0x8(%esp)
  800389:	00 
  80038a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800391:	00 
  800392:	c7 04 24 87 10 80 00 	movl   $0x801087,(%esp)
  800399:	e8 2e 00 00 00       	call   8003cc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80039e:	83 c4 2c             	add    $0x2c,%esp
  8003a1:	5b                   	pop    %ebx
  8003a2:	5e                   	pop    %esi
  8003a3:	5f                   	pop    %edi
  8003a4:	5d                   	pop    %ebp
  8003a5:	c3                   	ret    
	...

008003a8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8003a8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8003a9:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  8003ae:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8003b0:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// Save trap-time eip in eax
	movl 0x28(%esp), %eax
  8003b3:	8b 44 24 28          	mov    0x28(%esp),%eax

	// Save our current stack
	movl %esp, %ebp
  8003b7:	89 e5                	mov    %esp,%ebp

	// Switch to trap-time stack
	movl 0x30(%esp), %esp
  8003b9:	8b 64 24 30          	mov    0x30(%esp),%esp

	// Push trap-time eip to the trap-time stack
	pushl %eax
  8003bd:	50                   	push   %eax

	// We now have to update the trap-time esp with its new value
	movl %esp, 0x30(%ebp)
  8003be:	89 65 30             	mov    %esp,0x30(%ebp)

	// Go back to our exception stack
	movl %ebp, %esp
  8003c1:	89 ec                	mov    %ebp,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// Pop fault_va and err, both can be ignored
	popl %eax
  8003c3:	58                   	pop    %eax
	popl %eax
  8003c4:	58                   	pop    %eax

	// Pop all registers back
	popal
  8003c5:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// Skip %eip
	addl $0x4, %esp
  8003c6:	83 c4 04             	add    $0x4,%esp

	// Pop eflags back
	popfl
  8003c9:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	
	popl %esp
  8003ca:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  8003cb:	c3                   	ret    

008003cc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003cc:	55                   	push   %ebp
  8003cd:	89 e5                	mov    %esp,%ebp
  8003cf:	56                   	push   %esi
  8003d0:	53                   	push   %ebx
  8003d1:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8003d4:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003d7:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8003dd:	e8 71 fd ff ff       	call   800153 <sys_getenvid>
  8003e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003e5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ec:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003f0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003f8:	c7 04 24 98 10 80 00 	movl   $0x801098,(%esp)
  8003ff:	e8 c0 00 00 00       	call   8004c4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800404:	89 74 24 04          	mov    %esi,0x4(%esp)
  800408:	8b 45 10             	mov    0x10(%ebp),%eax
  80040b:	89 04 24             	mov    %eax,(%esp)
  80040e:	e8 50 00 00 00       	call   800463 <vcprintf>
	cprintf("\n");
  800413:	c7 04 24 bc 10 80 00 	movl   $0x8010bc,(%esp)
  80041a:	e8 a5 00 00 00       	call   8004c4 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80041f:	cc                   	int3   
  800420:	eb fd                	jmp    80041f <_panic+0x53>
	...

00800424 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800424:	55                   	push   %ebp
  800425:	89 e5                	mov    %esp,%ebp
  800427:	53                   	push   %ebx
  800428:	83 ec 14             	sub    $0x14,%esp
  80042b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80042e:	8b 03                	mov    (%ebx),%eax
  800430:	8b 55 08             	mov    0x8(%ebp),%edx
  800433:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800437:	40                   	inc    %eax
  800438:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80043a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80043f:	75 19                	jne    80045a <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800441:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800448:	00 
  800449:	8d 43 08             	lea    0x8(%ebx),%eax
  80044c:	89 04 24             	mov    %eax,(%esp)
  80044f:	e8 70 fc ff ff       	call   8000c4 <sys_cputs>
		b->idx = 0;
  800454:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80045a:	ff 43 04             	incl   0x4(%ebx)
}
  80045d:	83 c4 14             	add    $0x14,%esp
  800460:	5b                   	pop    %ebx
  800461:	5d                   	pop    %ebp
  800462:	c3                   	ret    

00800463 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800463:	55                   	push   %ebp
  800464:	89 e5                	mov    %esp,%ebp
  800466:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80046c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800473:	00 00 00 
	b.cnt = 0;
  800476:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80047d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800480:	8b 45 0c             	mov    0xc(%ebp),%eax
  800483:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800487:	8b 45 08             	mov    0x8(%ebp),%eax
  80048a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80048e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800494:	89 44 24 04          	mov    %eax,0x4(%esp)
  800498:	c7 04 24 24 04 80 00 	movl   $0x800424,(%esp)
  80049f:	e8 82 01 00 00       	call   800626 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004a4:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8004aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ae:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004b4:	89 04 24             	mov    %eax,(%esp)
  8004b7:	e8 08 fc ff ff       	call   8000c4 <sys_cputs>

	return b.cnt;
}
  8004bc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004c2:	c9                   	leave  
  8004c3:	c3                   	ret    

008004c4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004c4:	55                   	push   %ebp
  8004c5:	89 e5                	mov    %esp,%ebp
  8004c7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004ca:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8004d4:	89 04 24             	mov    %eax,(%esp)
  8004d7:	e8 87 ff ff ff       	call   800463 <vcprintf>
	va_end(ap);

	return cnt;
}
  8004dc:	c9                   	leave  
  8004dd:	c3                   	ret    
	...

008004e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004e0:	55                   	push   %ebp
  8004e1:	89 e5                	mov    %esp,%ebp
  8004e3:	57                   	push   %edi
  8004e4:	56                   	push   %esi
  8004e5:	53                   	push   %ebx
  8004e6:	83 ec 3c             	sub    $0x3c,%esp
  8004e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004ec:	89 d7                	mov    %edx,%edi
  8004ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004f7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004fa:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004fd:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800500:	85 c0                	test   %eax,%eax
  800502:	75 08                	jne    80050c <printnum+0x2c>
  800504:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800507:	39 45 10             	cmp    %eax,0x10(%ebp)
  80050a:	77 57                	ja     800563 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80050c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800510:	4b                   	dec    %ebx
  800511:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800515:	8b 45 10             	mov    0x10(%ebp),%eax
  800518:	89 44 24 08          	mov    %eax,0x8(%esp)
  80051c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800520:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800524:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80052b:	00 
  80052c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80052f:	89 04 24             	mov    %eax,(%esp)
  800532:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800535:	89 44 24 04          	mov    %eax,0x4(%esp)
  800539:	e8 ca 08 00 00       	call   800e08 <__udivdi3>
  80053e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800542:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800546:	89 04 24             	mov    %eax,(%esp)
  800549:	89 54 24 04          	mov    %edx,0x4(%esp)
  80054d:	89 fa                	mov    %edi,%edx
  80054f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800552:	e8 89 ff ff ff       	call   8004e0 <printnum>
  800557:	eb 0f                	jmp    800568 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800559:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80055d:	89 34 24             	mov    %esi,(%esp)
  800560:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800563:	4b                   	dec    %ebx
  800564:	85 db                	test   %ebx,%ebx
  800566:	7f f1                	jg     800559 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800568:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80056c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800570:	8b 45 10             	mov    0x10(%ebp),%eax
  800573:	89 44 24 08          	mov    %eax,0x8(%esp)
  800577:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80057e:	00 
  80057f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800582:	89 04 24             	mov    %eax,(%esp)
  800585:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800588:	89 44 24 04          	mov    %eax,0x4(%esp)
  80058c:	e8 97 09 00 00       	call   800f28 <__umoddi3>
  800591:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800595:	0f be 80 be 10 80 00 	movsbl 0x8010be(%eax),%eax
  80059c:	89 04 24             	mov    %eax,(%esp)
  80059f:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8005a2:	83 c4 3c             	add    $0x3c,%esp
  8005a5:	5b                   	pop    %ebx
  8005a6:	5e                   	pop    %esi
  8005a7:	5f                   	pop    %edi
  8005a8:	5d                   	pop    %ebp
  8005a9:	c3                   	ret    

008005aa <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8005aa:	55                   	push   %ebp
  8005ab:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8005ad:	83 fa 01             	cmp    $0x1,%edx
  8005b0:	7e 0e                	jle    8005c0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8005b2:	8b 10                	mov    (%eax),%edx
  8005b4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8005b7:	89 08                	mov    %ecx,(%eax)
  8005b9:	8b 02                	mov    (%edx),%eax
  8005bb:	8b 52 04             	mov    0x4(%edx),%edx
  8005be:	eb 22                	jmp    8005e2 <getuint+0x38>
	else if (lflag)
  8005c0:	85 d2                	test   %edx,%edx
  8005c2:	74 10                	je     8005d4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8005c4:	8b 10                	mov    (%eax),%edx
  8005c6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005c9:	89 08                	mov    %ecx,(%eax)
  8005cb:	8b 02                	mov    (%edx),%eax
  8005cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8005d2:	eb 0e                	jmp    8005e2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005d4:	8b 10                	mov    (%eax),%edx
  8005d6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005d9:	89 08                	mov    %ecx,(%eax)
  8005db:	8b 02                	mov    (%edx),%eax
  8005dd:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005e2:	5d                   	pop    %ebp
  8005e3:	c3                   	ret    

008005e4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005e4:	55                   	push   %ebp
  8005e5:	89 e5                	mov    %esp,%ebp
  8005e7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005ea:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8005ed:	8b 10                	mov    (%eax),%edx
  8005ef:	3b 50 04             	cmp    0x4(%eax),%edx
  8005f2:	73 08                	jae    8005fc <sprintputch+0x18>
		*b->buf++ = ch;
  8005f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8005f7:	88 0a                	mov    %cl,(%edx)
  8005f9:	42                   	inc    %edx
  8005fa:	89 10                	mov    %edx,(%eax)
}
  8005fc:	5d                   	pop    %ebp
  8005fd:	c3                   	ret    

008005fe <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005fe:	55                   	push   %ebp
  8005ff:	89 e5                	mov    %esp,%ebp
  800601:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800604:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800607:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80060b:	8b 45 10             	mov    0x10(%ebp),%eax
  80060e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800612:	8b 45 0c             	mov    0xc(%ebp),%eax
  800615:	89 44 24 04          	mov    %eax,0x4(%esp)
  800619:	8b 45 08             	mov    0x8(%ebp),%eax
  80061c:	89 04 24             	mov    %eax,(%esp)
  80061f:	e8 02 00 00 00       	call   800626 <vprintfmt>
	va_end(ap);
}
  800624:	c9                   	leave  
  800625:	c3                   	ret    

00800626 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800626:	55                   	push   %ebp
  800627:	89 e5                	mov    %esp,%ebp
  800629:	57                   	push   %edi
  80062a:	56                   	push   %esi
  80062b:	53                   	push   %ebx
  80062c:	83 ec 4c             	sub    $0x4c,%esp
  80062f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800632:	8b 75 10             	mov    0x10(%ebp),%esi
  800635:	eb 12                	jmp    800649 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800637:	85 c0                	test   %eax,%eax
  800639:	0f 84 6b 03 00 00    	je     8009aa <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80063f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800643:	89 04 24             	mov    %eax,(%esp)
  800646:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800649:	0f b6 06             	movzbl (%esi),%eax
  80064c:	46                   	inc    %esi
  80064d:	83 f8 25             	cmp    $0x25,%eax
  800650:	75 e5                	jne    800637 <vprintfmt+0x11>
  800652:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800656:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80065d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800662:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800669:	b9 00 00 00 00       	mov    $0x0,%ecx
  80066e:	eb 26                	jmp    800696 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800670:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800673:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800677:	eb 1d                	jmp    800696 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800679:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80067c:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800680:	eb 14                	jmp    800696 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800682:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800685:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80068c:	eb 08                	jmp    800696 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80068e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800691:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800696:	0f b6 06             	movzbl (%esi),%eax
  800699:	8d 56 01             	lea    0x1(%esi),%edx
  80069c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80069f:	8a 16                	mov    (%esi),%dl
  8006a1:	83 ea 23             	sub    $0x23,%edx
  8006a4:	80 fa 55             	cmp    $0x55,%dl
  8006a7:	0f 87 e1 02 00 00    	ja     80098e <vprintfmt+0x368>
  8006ad:	0f b6 d2             	movzbl %dl,%edx
  8006b0:	ff 24 95 80 11 80 00 	jmp    *0x801180(,%edx,4)
  8006b7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006ba:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8006bf:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8006c2:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8006c6:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8006c9:	8d 50 d0             	lea    -0x30(%eax),%edx
  8006cc:	83 fa 09             	cmp    $0x9,%edx
  8006cf:	77 2a                	ja     8006fb <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8006d1:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8006d2:	eb eb                	jmp    8006bf <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8006d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d7:	8d 50 04             	lea    0x4(%eax),%edx
  8006da:	89 55 14             	mov    %edx,0x14(%ebp)
  8006dd:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006df:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8006e2:	eb 17                	jmp    8006fb <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8006e4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006e8:	78 98                	js     800682 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ea:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006ed:	eb a7                	jmp    800696 <vprintfmt+0x70>
  8006ef:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006f2:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8006f9:	eb 9b                	jmp    800696 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8006fb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006ff:	79 95                	jns    800696 <vprintfmt+0x70>
  800701:	eb 8b                	jmp    80068e <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800703:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800704:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800707:	eb 8d                	jmp    800696 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800709:	8b 45 14             	mov    0x14(%ebp),%eax
  80070c:	8d 50 04             	lea    0x4(%eax),%edx
  80070f:	89 55 14             	mov    %edx,0x14(%ebp)
  800712:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800716:	8b 00                	mov    (%eax),%eax
  800718:	89 04 24             	mov    %eax,(%esp)
  80071b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80071e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800721:	e9 23 ff ff ff       	jmp    800649 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800726:	8b 45 14             	mov    0x14(%ebp),%eax
  800729:	8d 50 04             	lea    0x4(%eax),%edx
  80072c:	89 55 14             	mov    %edx,0x14(%ebp)
  80072f:	8b 00                	mov    (%eax),%eax
  800731:	85 c0                	test   %eax,%eax
  800733:	79 02                	jns    800737 <vprintfmt+0x111>
  800735:	f7 d8                	neg    %eax
  800737:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800739:	83 f8 09             	cmp    $0x9,%eax
  80073c:	7f 0b                	jg     800749 <vprintfmt+0x123>
  80073e:	8b 04 85 e0 12 80 00 	mov    0x8012e0(,%eax,4),%eax
  800745:	85 c0                	test   %eax,%eax
  800747:	75 23                	jne    80076c <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800749:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80074d:	c7 44 24 08 d6 10 80 	movl   $0x8010d6,0x8(%esp)
  800754:	00 
  800755:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800759:	8b 45 08             	mov    0x8(%ebp),%eax
  80075c:	89 04 24             	mov    %eax,(%esp)
  80075f:	e8 9a fe ff ff       	call   8005fe <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800764:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800767:	e9 dd fe ff ff       	jmp    800649 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80076c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800770:	c7 44 24 08 df 10 80 	movl   $0x8010df,0x8(%esp)
  800777:	00 
  800778:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80077c:	8b 55 08             	mov    0x8(%ebp),%edx
  80077f:	89 14 24             	mov    %edx,(%esp)
  800782:	e8 77 fe ff ff       	call   8005fe <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800787:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80078a:	e9 ba fe ff ff       	jmp    800649 <vprintfmt+0x23>
  80078f:	89 f9                	mov    %edi,%ecx
  800791:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800794:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800797:	8b 45 14             	mov    0x14(%ebp),%eax
  80079a:	8d 50 04             	lea    0x4(%eax),%edx
  80079d:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a0:	8b 30                	mov    (%eax),%esi
  8007a2:	85 f6                	test   %esi,%esi
  8007a4:	75 05                	jne    8007ab <vprintfmt+0x185>
				p = "(null)";
  8007a6:	be cf 10 80 00       	mov    $0x8010cf,%esi
			if (width > 0 && padc != '-')
  8007ab:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8007af:	0f 8e 84 00 00 00    	jle    800839 <vprintfmt+0x213>
  8007b5:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8007b9:	74 7e                	je     800839 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8007bb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007bf:	89 34 24             	mov    %esi,(%esp)
  8007c2:	e8 8b 02 00 00       	call   800a52 <strnlen>
  8007c7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007ca:	29 c2                	sub    %eax,%edx
  8007cc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8007cf:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8007d3:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8007d6:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8007d9:	89 de                	mov    %ebx,%esi
  8007db:	89 d3                	mov    %edx,%ebx
  8007dd:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007df:	eb 0b                	jmp    8007ec <vprintfmt+0x1c6>
					putch(padc, putdat);
  8007e1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007e5:	89 3c 24             	mov    %edi,(%esp)
  8007e8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007eb:	4b                   	dec    %ebx
  8007ec:	85 db                	test   %ebx,%ebx
  8007ee:	7f f1                	jg     8007e1 <vprintfmt+0x1bb>
  8007f0:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8007f3:	89 f3                	mov    %esi,%ebx
  8007f5:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8007f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007fb:	85 c0                	test   %eax,%eax
  8007fd:	79 05                	jns    800804 <vprintfmt+0x1de>
  8007ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800804:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800807:	29 c2                	sub    %eax,%edx
  800809:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80080c:	eb 2b                	jmp    800839 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80080e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800812:	74 18                	je     80082c <vprintfmt+0x206>
  800814:	8d 50 e0             	lea    -0x20(%eax),%edx
  800817:	83 fa 5e             	cmp    $0x5e,%edx
  80081a:	76 10                	jbe    80082c <vprintfmt+0x206>
					putch('?', putdat);
  80081c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800820:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800827:	ff 55 08             	call   *0x8(%ebp)
  80082a:	eb 0a                	jmp    800836 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  80082c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800830:	89 04 24             	mov    %eax,(%esp)
  800833:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800836:	ff 4d e4             	decl   -0x1c(%ebp)
  800839:	0f be 06             	movsbl (%esi),%eax
  80083c:	46                   	inc    %esi
  80083d:	85 c0                	test   %eax,%eax
  80083f:	74 21                	je     800862 <vprintfmt+0x23c>
  800841:	85 ff                	test   %edi,%edi
  800843:	78 c9                	js     80080e <vprintfmt+0x1e8>
  800845:	4f                   	dec    %edi
  800846:	79 c6                	jns    80080e <vprintfmt+0x1e8>
  800848:	8b 7d 08             	mov    0x8(%ebp),%edi
  80084b:	89 de                	mov    %ebx,%esi
  80084d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800850:	eb 18                	jmp    80086a <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800852:	89 74 24 04          	mov    %esi,0x4(%esp)
  800856:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80085d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80085f:	4b                   	dec    %ebx
  800860:	eb 08                	jmp    80086a <vprintfmt+0x244>
  800862:	8b 7d 08             	mov    0x8(%ebp),%edi
  800865:	89 de                	mov    %ebx,%esi
  800867:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80086a:	85 db                	test   %ebx,%ebx
  80086c:	7f e4                	jg     800852 <vprintfmt+0x22c>
  80086e:	89 7d 08             	mov    %edi,0x8(%ebp)
  800871:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800873:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800876:	e9 ce fd ff ff       	jmp    800649 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80087b:	83 f9 01             	cmp    $0x1,%ecx
  80087e:	7e 10                	jle    800890 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800880:	8b 45 14             	mov    0x14(%ebp),%eax
  800883:	8d 50 08             	lea    0x8(%eax),%edx
  800886:	89 55 14             	mov    %edx,0x14(%ebp)
  800889:	8b 30                	mov    (%eax),%esi
  80088b:	8b 78 04             	mov    0x4(%eax),%edi
  80088e:	eb 26                	jmp    8008b6 <vprintfmt+0x290>
	else if (lflag)
  800890:	85 c9                	test   %ecx,%ecx
  800892:	74 12                	je     8008a6 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800894:	8b 45 14             	mov    0x14(%ebp),%eax
  800897:	8d 50 04             	lea    0x4(%eax),%edx
  80089a:	89 55 14             	mov    %edx,0x14(%ebp)
  80089d:	8b 30                	mov    (%eax),%esi
  80089f:	89 f7                	mov    %esi,%edi
  8008a1:	c1 ff 1f             	sar    $0x1f,%edi
  8008a4:	eb 10                	jmp    8008b6 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8008a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a9:	8d 50 04             	lea    0x4(%eax),%edx
  8008ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8008af:	8b 30                	mov    (%eax),%esi
  8008b1:	89 f7                	mov    %esi,%edi
  8008b3:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8008b6:	85 ff                	test   %edi,%edi
  8008b8:	78 0a                	js     8008c4 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8008ba:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008bf:	e9 8c 00 00 00       	jmp    800950 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8008c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008c8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8008cf:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8008d2:	f7 de                	neg    %esi
  8008d4:	83 d7 00             	adc    $0x0,%edi
  8008d7:	f7 df                	neg    %edi
			}
			base = 10;
  8008d9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008de:	eb 70                	jmp    800950 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8008e0:	89 ca                	mov    %ecx,%edx
  8008e2:	8d 45 14             	lea    0x14(%ebp),%eax
  8008e5:	e8 c0 fc ff ff       	call   8005aa <getuint>
  8008ea:	89 c6                	mov    %eax,%esi
  8008ec:	89 d7                	mov    %edx,%edi
			base = 10;
  8008ee:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8008f3:	eb 5b                	jmp    800950 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  8008f5:	89 ca                	mov    %ecx,%edx
  8008f7:	8d 45 14             	lea    0x14(%ebp),%eax
  8008fa:	e8 ab fc ff ff       	call   8005aa <getuint>
  8008ff:	89 c6                	mov    %eax,%esi
  800901:	89 d7                	mov    %edx,%edi
			base = 8;
  800903:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800908:	eb 46                	jmp    800950 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  80090a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80090e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800915:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800918:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80091c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800923:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800926:	8b 45 14             	mov    0x14(%ebp),%eax
  800929:	8d 50 04             	lea    0x4(%eax),%edx
  80092c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80092f:	8b 30                	mov    (%eax),%esi
  800931:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800936:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80093b:	eb 13                	jmp    800950 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80093d:	89 ca                	mov    %ecx,%edx
  80093f:	8d 45 14             	lea    0x14(%ebp),%eax
  800942:	e8 63 fc ff ff       	call   8005aa <getuint>
  800947:	89 c6                	mov    %eax,%esi
  800949:	89 d7                	mov    %edx,%edi
			base = 16;
  80094b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800950:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800954:	89 54 24 10          	mov    %edx,0x10(%esp)
  800958:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80095b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80095f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800963:	89 34 24             	mov    %esi,(%esp)
  800966:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80096a:	89 da                	mov    %ebx,%edx
  80096c:	8b 45 08             	mov    0x8(%ebp),%eax
  80096f:	e8 6c fb ff ff       	call   8004e0 <printnum>
			break;
  800974:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800977:	e9 cd fc ff ff       	jmp    800649 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80097c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800980:	89 04 24             	mov    %eax,(%esp)
  800983:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800986:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800989:	e9 bb fc ff ff       	jmp    800649 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80098e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800992:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800999:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80099c:	eb 01                	jmp    80099f <vprintfmt+0x379>
  80099e:	4e                   	dec    %esi
  80099f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8009a3:	75 f9                	jne    80099e <vprintfmt+0x378>
  8009a5:	e9 9f fc ff ff       	jmp    800649 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8009aa:	83 c4 4c             	add    $0x4c,%esp
  8009ad:	5b                   	pop    %ebx
  8009ae:	5e                   	pop    %esi
  8009af:	5f                   	pop    %edi
  8009b0:	5d                   	pop    %ebp
  8009b1:	c3                   	ret    

008009b2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
  8009b5:	83 ec 28             	sub    $0x28,%esp
  8009b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009be:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009c1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009c5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009c8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009cf:	85 c0                	test   %eax,%eax
  8009d1:	74 30                	je     800a03 <vsnprintf+0x51>
  8009d3:	85 d2                	test   %edx,%edx
  8009d5:	7e 33                	jle    800a0a <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8009da:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009de:	8b 45 10             	mov    0x10(%ebp),%eax
  8009e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009e5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ec:	c7 04 24 e4 05 80 00 	movl   $0x8005e4,(%esp)
  8009f3:	e8 2e fc ff ff       	call   800626 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009fb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a01:	eb 0c                	jmp    800a0f <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a03:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a08:	eb 05                	jmp    800a0f <vsnprintf+0x5d>
  800a0a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a0f:	c9                   	leave  
  800a10:	c3                   	ret    

00800a11 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a11:	55                   	push   %ebp
  800a12:	89 e5                	mov    %esp,%ebp
  800a14:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a17:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a1a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a1e:	8b 45 10             	mov    0x10(%ebp),%eax
  800a21:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a25:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a28:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2f:	89 04 24             	mov    %eax,(%esp)
  800a32:	e8 7b ff ff ff       	call   8009b2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a37:	c9                   	leave  
  800a38:	c3                   	ret    
  800a39:	00 00                	add    %al,(%eax)
	...

00800a3c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a3c:	55                   	push   %ebp
  800a3d:	89 e5                	mov    %esp,%ebp
  800a3f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a42:	b8 00 00 00 00       	mov    $0x0,%eax
  800a47:	eb 01                	jmp    800a4a <strlen+0xe>
		n++;
  800a49:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a4a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a4e:	75 f9                	jne    800a49 <strlen+0xd>
		n++;
	return n;
}
  800a50:	5d                   	pop    %ebp
  800a51:	c3                   	ret    

00800a52 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a52:	55                   	push   %ebp
  800a53:	89 e5                	mov    %esp,%ebp
  800a55:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800a58:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a5b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a60:	eb 01                	jmp    800a63 <strnlen+0x11>
		n++;
  800a62:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a63:	39 d0                	cmp    %edx,%eax
  800a65:	74 06                	je     800a6d <strnlen+0x1b>
  800a67:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a6b:	75 f5                	jne    800a62 <strnlen+0x10>
		n++;
	return n;
}
  800a6d:	5d                   	pop    %ebp
  800a6e:	c3                   	ret    

00800a6f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a6f:	55                   	push   %ebp
  800a70:	89 e5                	mov    %esp,%ebp
  800a72:	53                   	push   %ebx
  800a73:	8b 45 08             	mov    0x8(%ebp),%eax
  800a76:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a79:	ba 00 00 00 00       	mov    $0x0,%edx
  800a7e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800a81:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a84:	42                   	inc    %edx
  800a85:	84 c9                	test   %cl,%cl
  800a87:	75 f5                	jne    800a7e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a89:	5b                   	pop    %ebx
  800a8a:	5d                   	pop    %ebp
  800a8b:	c3                   	ret    

00800a8c <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a8c:	55                   	push   %ebp
  800a8d:	89 e5                	mov    %esp,%ebp
  800a8f:	53                   	push   %ebx
  800a90:	83 ec 08             	sub    $0x8,%esp
  800a93:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a96:	89 1c 24             	mov    %ebx,(%esp)
  800a99:	e8 9e ff ff ff       	call   800a3c <strlen>
	strcpy(dst + len, src);
  800a9e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aa1:	89 54 24 04          	mov    %edx,0x4(%esp)
  800aa5:	01 d8                	add    %ebx,%eax
  800aa7:	89 04 24             	mov    %eax,(%esp)
  800aaa:	e8 c0 ff ff ff       	call   800a6f <strcpy>
	return dst;
}
  800aaf:	89 d8                	mov    %ebx,%eax
  800ab1:	83 c4 08             	add    $0x8,%esp
  800ab4:	5b                   	pop    %ebx
  800ab5:	5d                   	pop    %ebp
  800ab6:	c3                   	ret    

00800ab7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ab7:	55                   	push   %ebp
  800ab8:	89 e5                	mov    %esp,%ebp
  800aba:	56                   	push   %esi
  800abb:	53                   	push   %ebx
  800abc:	8b 45 08             	mov    0x8(%ebp),%eax
  800abf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ac2:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ac5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aca:	eb 0c                	jmp    800ad8 <strncpy+0x21>
		*dst++ = *src;
  800acc:	8a 1a                	mov    (%edx),%bl
  800ace:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ad1:	80 3a 01             	cmpb   $0x1,(%edx)
  800ad4:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ad7:	41                   	inc    %ecx
  800ad8:	39 f1                	cmp    %esi,%ecx
  800ada:	75 f0                	jne    800acc <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800adc:	5b                   	pop    %ebx
  800add:	5e                   	pop    %esi
  800ade:	5d                   	pop    %ebp
  800adf:	c3                   	ret    

00800ae0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ae0:	55                   	push   %ebp
  800ae1:	89 e5                	mov    %esp,%ebp
  800ae3:	56                   	push   %esi
  800ae4:	53                   	push   %ebx
  800ae5:	8b 75 08             	mov    0x8(%ebp),%esi
  800ae8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aeb:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800aee:	85 d2                	test   %edx,%edx
  800af0:	75 0a                	jne    800afc <strlcpy+0x1c>
  800af2:	89 f0                	mov    %esi,%eax
  800af4:	eb 1a                	jmp    800b10 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800af6:	88 18                	mov    %bl,(%eax)
  800af8:	40                   	inc    %eax
  800af9:	41                   	inc    %ecx
  800afa:	eb 02                	jmp    800afe <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800afc:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800afe:	4a                   	dec    %edx
  800aff:	74 0a                	je     800b0b <strlcpy+0x2b>
  800b01:	8a 19                	mov    (%ecx),%bl
  800b03:	84 db                	test   %bl,%bl
  800b05:	75 ef                	jne    800af6 <strlcpy+0x16>
  800b07:	89 c2                	mov    %eax,%edx
  800b09:	eb 02                	jmp    800b0d <strlcpy+0x2d>
  800b0b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800b0d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800b10:	29 f0                	sub    %esi,%eax
}
  800b12:	5b                   	pop    %ebx
  800b13:	5e                   	pop    %esi
  800b14:	5d                   	pop    %ebp
  800b15:	c3                   	ret    

00800b16 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b16:	55                   	push   %ebp
  800b17:	89 e5                	mov    %esp,%ebp
  800b19:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b1c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b1f:	eb 02                	jmp    800b23 <strcmp+0xd>
		p++, q++;
  800b21:	41                   	inc    %ecx
  800b22:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b23:	8a 01                	mov    (%ecx),%al
  800b25:	84 c0                	test   %al,%al
  800b27:	74 04                	je     800b2d <strcmp+0x17>
  800b29:	3a 02                	cmp    (%edx),%al
  800b2b:	74 f4                	je     800b21 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b2d:	0f b6 c0             	movzbl %al,%eax
  800b30:	0f b6 12             	movzbl (%edx),%edx
  800b33:	29 d0                	sub    %edx,%eax
}
  800b35:	5d                   	pop    %ebp
  800b36:	c3                   	ret    

00800b37 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	53                   	push   %ebx
  800b3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b41:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800b44:	eb 03                	jmp    800b49 <strncmp+0x12>
		n--, p++, q++;
  800b46:	4a                   	dec    %edx
  800b47:	40                   	inc    %eax
  800b48:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b49:	85 d2                	test   %edx,%edx
  800b4b:	74 14                	je     800b61 <strncmp+0x2a>
  800b4d:	8a 18                	mov    (%eax),%bl
  800b4f:	84 db                	test   %bl,%bl
  800b51:	74 04                	je     800b57 <strncmp+0x20>
  800b53:	3a 19                	cmp    (%ecx),%bl
  800b55:	74 ef                	je     800b46 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b57:	0f b6 00             	movzbl (%eax),%eax
  800b5a:	0f b6 11             	movzbl (%ecx),%edx
  800b5d:	29 d0                	sub    %edx,%eax
  800b5f:	eb 05                	jmp    800b66 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b61:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b66:	5b                   	pop    %ebx
  800b67:	5d                   	pop    %ebp
  800b68:	c3                   	ret    

00800b69 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b69:	55                   	push   %ebp
  800b6a:	89 e5                	mov    %esp,%ebp
  800b6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b72:	eb 05                	jmp    800b79 <strchr+0x10>
		if (*s == c)
  800b74:	38 ca                	cmp    %cl,%dl
  800b76:	74 0c                	je     800b84 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b78:	40                   	inc    %eax
  800b79:	8a 10                	mov    (%eax),%dl
  800b7b:	84 d2                	test   %dl,%dl
  800b7d:	75 f5                	jne    800b74 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800b7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b84:	5d                   	pop    %ebp
  800b85:	c3                   	ret    

00800b86 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b86:	55                   	push   %ebp
  800b87:	89 e5                	mov    %esp,%ebp
  800b89:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b8f:	eb 05                	jmp    800b96 <strfind+0x10>
		if (*s == c)
  800b91:	38 ca                	cmp    %cl,%dl
  800b93:	74 07                	je     800b9c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b95:	40                   	inc    %eax
  800b96:	8a 10                	mov    (%eax),%dl
  800b98:	84 d2                	test   %dl,%dl
  800b9a:	75 f5                	jne    800b91 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800b9c:	5d                   	pop    %ebp
  800b9d:	c3                   	ret    

00800b9e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b9e:	55                   	push   %ebp
  800b9f:	89 e5                	mov    %esp,%ebp
  800ba1:	57                   	push   %edi
  800ba2:	56                   	push   %esi
  800ba3:	53                   	push   %ebx
  800ba4:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ba7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800baa:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bad:	85 c9                	test   %ecx,%ecx
  800baf:	74 30                	je     800be1 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bb1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bb7:	75 25                	jne    800bde <memset+0x40>
  800bb9:	f6 c1 03             	test   $0x3,%cl
  800bbc:	75 20                	jne    800bde <memset+0x40>
		c &= 0xFF;
  800bbe:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bc1:	89 d3                	mov    %edx,%ebx
  800bc3:	c1 e3 08             	shl    $0x8,%ebx
  800bc6:	89 d6                	mov    %edx,%esi
  800bc8:	c1 e6 18             	shl    $0x18,%esi
  800bcb:	89 d0                	mov    %edx,%eax
  800bcd:	c1 e0 10             	shl    $0x10,%eax
  800bd0:	09 f0                	or     %esi,%eax
  800bd2:	09 d0                	or     %edx,%eax
  800bd4:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bd6:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800bd9:	fc                   	cld    
  800bda:	f3 ab                	rep stos %eax,%es:(%edi)
  800bdc:	eb 03                	jmp    800be1 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bde:	fc                   	cld    
  800bdf:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800be1:	89 f8                	mov    %edi,%eax
  800be3:	5b                   	pop    %ebx
  800be4:	5e                   	pop    %esi
  800be5:	5f                   	pop    %edi
  800be6:	5d                   	pop    %ebp
  800be7:	c3                   	ret    

00800be8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800be8:	55                   	push   %ebp
  800be9:	89 e5                	mov    %esp,%ebp
  800beb:	57                   	push   %edi
  800bec:	56                   	push   %esi
  800bed:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bf3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bf6:	39 c6                	cmp    %eax,%esi
  800bf8:	73 34                	jae    800c2e <memmove+0x46>
  800bfa:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bfd:	39 d0                	cmp    %edx,%eax
  800bff:	73 2d                	jae    800c2e <memmove+0x46>
		s += n;
		d += n;
  800c01:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c04:	f6 c2 03             	test   $0x3,%dl
  800c07:	75 1b                	jne    800c24 <memmove+0x3c>
  800c09:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c0f:	75 13                	jne    800c24 <memmove+0x3c>
  800c11:	f6 c1 03             	test   $0x3,%cl
  800c14:	75 0e                	jne    800c24 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c16:	83 ef 04             	sub    $0x4,%edi
  800c19:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c1c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c1f:	fd                   	std    
  800c20:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c22:	eb 07                	jmp    800c2b <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c24:	4f                   	dec    %edi
  800c25:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c28:	fd                   	std    
  800c29:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c2b:	fc                   	cld    
  800c2c:	eb 20                	jmp    800c4e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c2e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c34:	75 13                	jne    800c49 <memmove+0x61>
  800c36:	a8 03                	test   $0x3,%al
  800c38:	75 0f                	jne    800c49 <memmove+0x61>
  800c3a:	f6 c1 03             	test   $0x3,%cl
  800c3d:	75 0a                	jne    800c49 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c3f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c42:	89 c7                	mov    %eax,%edi
  800c44:	fc                   	cld    
  800c45:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c47:	eb 05                	jmp    800c4e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c49:	89 c7                	mov    %eax,%edi
  800c4b:	fc                   	cld    
  800c4c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c4e:	5e                   	pop    %esi
  800c4f:	5f                   	pop    %edi
  800c50:	5d                   	pop    %ebp
  800c51:	c3                   	ret    

00800c52 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c52:	55                   	push   %ebp
  800c53:	89 e5                	mov    %esp,%ebp
  800c55:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c58:	8b 45 10             	mov    0x10(%ebp),%eax
  800c5b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c62:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c66:	8b 45 08             	mov    0x8(%ebp),%eax
  800c69:	89 04 24             	mov    %eax,(%esp)
  800c6c:	e8 77 ff ff ff       	call   800be8 <memmove>
}
  800c71:	c9                   	leave  
  800c72:	c3                   	ret    

00800c73 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c73:	55                   	push   %ebp
  800c74:	89 e5                	mov    %esp,%ebp
  800c76:	57                   	push   %edi
  800c77:	56                   	push   %esi
  800c78:	53                   	push   %ebx
  800c79:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c7c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c7f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c82:	ba 00 00 00 00       	mov    $0x0,%edx
  800c87:	eb 16                	jmp    800c9f <memcmp+0x2c>
		if (*s1 != *s2)
  800c89:	8a 04 17             	mov    (%edi,%edx,1),%al
  800c8c:	42                   	inc    %edx
  800c8d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800c91:	38 c8                	cmp    %cl,%al
  800c93:	74 0a                	je     800c9f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800c95:	0f b6 c0             	movzbl %al,%eax
  800c98:	0f b6 c9             	movzbl %cl,%ecx
  800c9b:	29 c8                	sub    %ecx,%eax
  800c9d:	eb 09                	jmp    800ca8 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c9f:	39 da                	cmp    %ebx,%edx
  800ca1:	75 e6                	jne    800c89 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ca3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ca8:	5b                   	pop    %ebx
  800ca9:	5e                   	pop    %esi
  800caa:	5f                   	pop    %edi
  800cab:	5d                   	pop    %ebp
  800cac:	c3                   	ret    

00800cad <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cad:	55                   	push   %ebp
  800cae:	89 e5                	mov    %esp,%ebp
  800cb0:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800cb6:	89 c2                	mov    %eax,%edx
  800cb8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cbb:	eb 05                	jmp    800cc2 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cbd:	38 08                	cmp    %cl,(%eax)
  800cbf:	74 05                	je     800cc6 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cc1:	40                   	inc    %eax
  800cc2:	39 d0                	cmp    %edx,%eax
  800cc4:	72 f7                	jb     800cbd <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800cc6:	5d                   	pop    %ebp
  800cc7:	c3                   	ret    

00800cc8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cc8:	55                   	push   %ebp
  800cc9:	89 e5                	mov    %esp,%ebp
  800ccb:	57                   	push   %edi
  800ccc:	56                   	push   %esi
  800ccd:	53                   	push   %ebx
  800cce:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cd4:	eb 01                	jmp    800cd7 <strtol+0xf>
		s++;
  800cd6:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cd7:	8a 02                	mov    (%edx),%al
  800cd9:	3c 20                	cmp    $0x20,%al
  800cdb:	74 f9                	je     800cd6 <strtol+0xe>
  800cdd:	3c 09                	cmp    $0x9,%al
  800cdf:	74 f5                	je     800cd6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ce1:	3c 2b                	cmp    $0x2b,%al
  800ce3:	75 08                	jne    800ced <strtol+0x25>
		s++;
  800ce5:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ce6:	bf 00 00 00 00       	mov    $0x0,%edi
  800ceb:	eb 13                	jmp    800d00 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ced:	3c 2d                	cmp    $0x2d,%al
  800cef:	75 0a                	jne    800cfb <strtol+0x33>
		s++, neg = 1;
  800cf1:	8d 52 01             	lea    0x1(%edx),%edx
  800cf4:	bf 01 00 00 00       	mov    $0x1,%edi
  800cf9:	eb 05                	jmp    800d00 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cfb:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d00:	85 db                	test   %ebx,%ebx
  800d02:	74 05                	je     800d09 <strtol+0x41>
  800d04:	83 fb 10             	cmp    $0x10,%ebx
  800d07:	75 28                	jne    800d31 <strtol+0x69>
  800d09:	8a 02                	mov    (%edx),%al
  800d0b:	3c 30                	cmp    $0x30,%al
  800d0d:	75 10                	jne    800d1f <strtol+0x57>
  800d0f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d13:	75 0a                	jne    800d1f <strtol+0x57>
		s += 2, base = 16;
  800d15:	83 c2 02             	add    $0x2,%edx
  800d18:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d1d:	eb 12                	jmp    800d31 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800d1f:	85 db                	test   %ebx,%ebx
  800d21:	75 0e                	jne    800d31 <strtol+0x69>
  800d23:	3c 30                	cmp    $0x30,%al
  800d25:	75 05                	jne    800d2c <strtol+0x64>
		s++, base = 8;
  800d27:	42                   	inc    %edx
  800d28:	b3 08                	mov    $0x8,%bl
  800d2a:	eb 05                	jmp    800d31 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800d2c:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800d31:	b8 00 00 00 00       	mov    $0x0,%eax
  800d36:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d38:	8a 0a                	mov    (%edx),%cl
  800d3a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d3d:	80 fb 09             	cmp    $0x9,%bl
  800d40:	77 08                	ja     800d4a <strtol+0x82>
			dig = *s - '0';
  800d42:	0f be c9             	movsbl %cl,%ecx
  800d45:	83 e9 30             	sub    $0x30,%ecx
  800d48:	eb 1e                	jmp    800d68 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800d4a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d4d:	80 fb 19             	cmp    $0x19,%bl
  800d50:	77 08                	ja     800d5a <strtol+0x92>
			dig = *s - 'a' + 10;
  800d52:	0f be c9             	movsbl %cl,%ecx
  800d55:	83 e9 57             	sub    $0x57,%ecx
  800d58:	eb 0e                	jmp    800d68 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800d5a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d5d:	80 fb 19             	cmp    $0x19,%bl
  800d60:	77 12                	ja     800d74 <strtol+0xac>
			dig = *s - 'A' + 10;
  800d62:	0f be c9             	movsbl %cl,%ecx
  800d65:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d68:	39 f1                	cmp    %esi,%ecx
  800d6a:	7d 0c                	jge    800d78 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800d6c:	42                   	inc    %edx
  800d6d:	0f af c6             	imul   %esi,%eax
  800d70:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d72:	eb c4                	jmp    800d38 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d74:	89 c1                	mov    %eax,%ecx
  800d76:	eb 02                	jmp    800d7a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d78:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d7a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d7e:	74 05                	je     800d85 <strtol+0xbd>
		*endptr = (char *) s;
  800d80:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d83:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d85:	85 ff                	test   %edi,%edi
  800d87:	74 04                	je     800d8d <strtol+0xc5>
  800d89:	89 c8                	mov    %ecx,%eax
  800d8b:	f7 d8                	neg    %eax
}
  800d8d:	5b                   	pop    %ebx
  800d8e:	5e                   	pop    %esi
  800d8f:	5f                   	pop    %edi
  800d90:	5d                   	pop    %ebp
  800d91:	c3                   	ret    
	...

00800d94 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d94:	55                   	push   %ebp
  800d95:	89 e5                	mov    %esp,%ebp
  800d97:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d9a:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800da1:	75 58                	jne    800dfb <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.	
		//panic("set_pgfault_handler not implemented");
		
		if (sys_page_alloc(thisenv->env_id,(void *) (UXSTACKTOP - PGSIZE),(PTE_W|PTE_U|PTE_P)) != 0){
  800da3:	a1 04 20 80 00       	mov    0x802004,%eax
  800da8:	8b 40 48             	mov    0x48(%eax),%eax
  800dab:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800db2:	00 
  800db3:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800dba:	ee 
  800dbb:	89 04 24             	mov    %eax,(%esp)
  800dbe:	e8 ce f3 ff ff       	call   800191 <sys_page_alloc>
  800dc3:	85 c0                	test   %eax,%eax
  800dc5:	74 1c                	je     800de3 <set_pgfault_handler+0x4f>
			panic("set_pg_fault_handler");
  800dc7:	c7 44 24 08 08 13 80 	movl   $0x801308,0x8(%esp)
  800dce:	00 
  800dcf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dd6:	00 
  800dd7:	c7 04 24 1d 13 80 00 	movl   $0x80131d,(%esp)
  800dde:	e8 e9 f5 ff ff       	call   8003cc <_panic>
		}
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  800de3:	a1 04 20 80 00       	mov    0x802004,%eax
  800de8:	8b 40 48             	mov    0x48(%eax),%eax
  800deb:	c7 44 24 04 a8 03 80 	movl   $0x8003a8,0x4(%esp)
  800df2:	00 
  800df3:	89 04 24             	mov    %eax,(%esp)
  800df6:	e8 e3 f4 ff ff       	call   8002de <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800dfb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfe:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800e03:	c9                   	leave  
  800e04:	c3                   	ret    
  800e05:	00 00                	add    %al,(%eax)
	...

00800e08 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800e08:	55                   	push   %ebp
  800e09:	57                   	push   %edi
  800e0a:	56                   	push   %esi
  800e0b:	83 ec 10             	sub    $0x10,%esp
  800e0e:	8b 74 24 20          	mov    0x20(%esp),%esi
  800e12:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800e16:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e1a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  800e1e:	89 cd                	mov    %ecx,%ebp
  800e20:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e24:	85 c0                	test   %eax,%eax
  800e26:	75 2c                	jne    800e54 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800e28:	39 f9                	cmp    %edi,%ecx
  800e2a:	77 68                	ja     800e94 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800e2c:	85 c9                	test   %ecx,%ecx
  800e2e:	75 0b                	jne    800e3b <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800e30:	b8 01 00 00 00       	mov    $0x1,%eax
  800e35:	31 d2                	xor    %edx,%edx
  800e37:	f7 f1                	div    %ecx
  800e39:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800e3b:	31 d2                	xor    %edx,%edx
  800e3d:	89 f8                	mov    %edi,%eax
  800e3f:	f7 f1                	div    %ecx
  800e41:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e43:	89 f0                	mov    %esi,%eax
  800e45:	f7 f1                	div    %ecx
  800e47:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e49:	89 f0                	mov    %esi,%eax
  800e4b:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e4d:	83 c4 10             	add    $0x10,%esp
  800e50:	5e                   	pop    %esi
  800e51:	5f                   	pop    %edi
  800e52:	5d                   	pop    %ebp
  800e53:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e54:	39 f8                	cmp    %edi,%eax
  800e56:	77 2c                	ja     800e84 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e58:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  800e5b:	83 f6 1f             	xor    $0x1f,%esi
  800e5e:	75 4c                	jne    800eac <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e60:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e62:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e67:	72 0a                	jb     800e73 <__udivdi3+0x6b>
  800e69:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800e6d:	0f 87 ad 00 00 00    	ja     800f20 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e73:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e78:	89 f0                	mov    %esi,%eax
  800e7a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e7c:	83 c4 10             	add    $0x10,%esp
  800e7f:	5e                   	pop    %esi
  800e80:	5f                   	pop    %edi
  800e81:	5d                   	pop    %ebp
  800e82:	c3                   	ret    
  800e83:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e84:	31 ff                	xor    %edi,%edi
  800e86:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e88:	89 f0                	mov    %esi,%eax
  800e8a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e8c:	83 c4 10             	add    $0x10,%esp
  800e8f:	5e                   	pop    %esi
  800e90:	5f                   	pop    %edi
  800e91:	5d                   	pop    %ebp
  800e92:	c3                   	ret    
  800e93:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e94:	89 fa                	mov    %edi,%edx
  800e96:	89 f0                	mov    %esi,%eax
  800e98:	f7 f1                	div    %ecx
  800e9a:	89 c6                	mov    %eax,%esi
  800e9c:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e9e:	89 f0                	mov    %esi,%eax
  800ea0:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800ea2:	83 c4 10             	add    $0x10,%esp
  800ea5:	5e                   	pop    %esi
  800ea6:	5f                   	pop    %edi
  800ea7:	5d                   	pop    %ebp
  800ea8:	c3                   	ret    
  800ea9:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800eac:	89 f1                	mov    %esi,%ecx
  800eae:	d3 e0                	shl    %cl,%eax
  800eb0:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800eb4:	b8 20 00 00 00       	mov    $0x20,%eax
  800eb9:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800ebb:	89 ea                	mov    %ebp,%edx
  800ebd:	88 c1                	mov    %al,%cl
  800ebf:	d3 ea                	shr    %cl,%edx
  800ec1:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800ec5:	09 ca                	or     %ecx,%edx
  800ec7:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  800ecb:	89 f1                	mov    %esi,%ecx
  800ecd:	d3 e5                	shl    %cl,%ebp
  800ecf:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  800ed3:	89 fd                	mov    %edi,%ebp
  800ed5:	88 c1                	mov    %al,%cl
  800ed7:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  800ed9:	89 fa                	mov    %edi,%edx
  800edb:	89 f1                	mov    %esi,%ecx
  800edd:	d3 e2                	shl    %cl,%edx
  800edf:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ee3:	88 c1                	mov    %al,%cl
  800ee5:	d3 ef                	shr    %cl,%edi
  800ee7:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800ee9:	89 f8                	mov    %edi,%eax
  800eeb:	89 ea                	mov    %ebp,%edx
  800eed:	f7 74 24 08          	divl   0x8(%esp)
  800ef1:	89 d1                	mov    %edx,%ecx
  800ef3:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  800ef5:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ef9:	39 d1                	cmp    %edx,%ecx
  800efb:	72 17                	jb     800f14 <__udivdi3+0x10c>
  800efd:	74 09                	je     800f08 <__udivdi3+0x100>
  800eff:	89 fe                	mov    %edi,%esi
  800f01:	31 ff                	xor    %edi,%edi
  800f03:	e9 41 ff ff ff       	jmp    800e49 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800f08:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f0c:	89 f1                	mov    %esi,%ecx
  800f0e:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f10:	39 c2                	cmp    %eax,%edx
  800f12:	73 eb                	jae    800eff <__udivdi3+0xf7>
		{
		  q0--;
  800f14:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f17:	31 ff                	xor    %edi,%edi
  800f19:	e9 2b ff ff ff       	jmp    800e49 <__udivdi3+0x41>
  800f1e:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800f20:	31 f6                	xor    %esi,%esi
  800f22:	e9 22 ff ff ff       	jmp    800e49 <__udivdi3+0x41>
	...

00800f28 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800f28:	55                   	push   %ebp
  800f29:	57                   	push   %edi
  800f2a:	56                   	push   %esi
  800f2b:	83 ec 20             	sub    $0x20,%esp
  800f2e:	8b 44 24 30          	mov    0x30(%esp),%eax
  800f32:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800f36:	89 44 24 14          	mov    %eax,0x14(%esp)
  800f3a:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  800f3e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800f42:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800f46:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  800f48:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800f4a:	85 ed                	test   %ebp,%ebp
  800f4c:	75 16                	jne    800f64 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  800f4e:	39 f1                	cmp    %esi,%ecx
  800f50:	0f 86 a6 00 00 00    	jbe    800ffc <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f56:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800f58:	89 d0                	mov    %edx,%eax
  800f5a:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f5c:	83 c4 20             	add    $0x20,%esp
  800f5f:	5e                   	pop    %esi
  800f60:	5f                   	pop    %edi
  800f61:	5d                   	pop    %ebp
  800f62:	c3                   	ret    
  800f63:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800f64:	39 f5                	cmp    %esi,%ebp
  800f66:	0f 87 ac 00 00 00    	ja     801018 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800f6c:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  800f6f:	83 f0 1f             	xor    $0x1f,%eax
  800f72:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f76:	0f 84 a8 00 00 00    	je     801024 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800f7c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f80:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800f82:	bf 20 00 00 00       	mov    $0x20,%edi
  800f87:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800f8b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f8f:	89 f9                	mov    %edi,%ecx
  800f91:	d3 e8                	shr    %cl,%eax
  800f93:	09 e8                	or     %ebp,%eax
  800f95:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  800f99:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f9d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800fa1:	d3 e0                	shl    %cl,%eax
  800fa3:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800fa7:	89 f2                	mov    %esi,%edx
  800fa9:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800fab:	8b 44 24 14          	mov    0x14(%esp),%eax
  800faf:	d3 e0                	shl    %cl,%eax
  800fb1:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800fb5:	8b 44 24 14          	mov    0x14(%esp),%eax
  800fb9:	89 f9                	mov    %edi,%ecx
  800fbb:	d3 e8                	shr    %cl,%eax
  800fbd:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800fbf:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800fc1:	89 f2                	mov    %esi,%edx
  800fc3:	f7 74 24 18          	divl   0x18(%esp)
  800fc7:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800fc9:	f7 64 24 0c          	mull   0xc(%esp)
  800fcd:	89 c5                	mov    %eax,%ebp
  800fcf:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800fd1:	39 d6                	cmp    %edx,%esi
  800fd3:	72 67                	jb     80103c <__umoddi3+0x114>
  800fd5:	74 75                	je     80104c <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800fd7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800fdb:	29 e8                	sub    %ebp,%eax
  800fdd:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800fdf:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800fe3:	d3 e8                	shr    %cl,%eax
  800fe5:	89 f2                	mov    %esi,%edx
  800fe7:	89 f9                	mov    %edi,%ecx
  800fe9:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800feb:	09 d0                	or     %edx,%eax
  800fed:	89 f2                	mov    %esi,%edx
  800fef:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800ff3:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ff5:	83 c4 20             	add    $0x20,%esp
  800ff8:	5e                   	pop    %esi
  800ff9:	5f                   	pop    %edi
  800ffa:	5d                   	pop    %ebp
  800ffb:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800ffc:	85 c9                	test   %ecx,%ecx
  800ffe:	75 0b                	jne    80100b <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801000:	b8 01 00 00 00       	mov    $0x1,%eax
  801005:	31 d2                	xor    %edx,%edx
  801007:	f7 f1                	div    %ecx
  801009:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80100b:	89 f0                	mov    %esi,%eax
  80100d:	31 d2                	xor    %edx,%edx
  80100f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801011:	89 f8                	mov    %edi,%eax
  801013:	e9 3e ff ff ff       	jmp    800f56 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801018:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80101a:	83 c4 20             	add    $0x20,%esp
  80101d:	5e                   	pop    %esi
  80101e:	5f                   	pop    %edi
  80101f:	5d                   	pop    %ebp
  801020:	c3                   	ret    
  801021:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801024:	39 f5                	cmp    %esi,%ebp
  801026:	72 04                	jb     80102c <__umoddi3+0x104>
  801028:	39 f9                	cmp    %edi,%ecx
  80102a:	77 06                	ja     801032 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80102c:	89 f2                	mov    %esi,%edx
  80102e:	29 cf                	sub    %ecx,%edi
  801030:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801032:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801034:	83 c4 20             	add    $0x20,%esp
  801037:	5e                   	pop    %esi
  801038:	5f                   	pop    %edi
  801039:	5d                   	pop    %ebp
  80103a:	c3                   	ret    
  80103b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80103c:	89 d1                	mov    %edx,%ecx
  80103e:	89 c5                	mov    %eax,%ebp
  801040:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801044:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801048:	eb 8d                	jmp    800fd7 <__umoddi3+0xaf>
  80104a:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80104c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801050:	72 ea                	jb     80103c <__umoddi3+0x114>
  801052:	89 f1                	mov    %esi,%ecx
  801054:	eb 81                	jmp    800fd7 <__umoddi3+0xaf>
