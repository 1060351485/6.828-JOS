
obj/user/faultnostack.debug:     file format elf32-i386


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
  80003a:	c7 44 24 04 fc 03 80 	movl   $0x8003fc,0x4(%esp)
  800041:	00 
  800042:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800049:	e8 e3 02 00 00       	call   800331 <sys_env_set_pgfault_upcall>
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
	//close_all();
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
  80012f:	c7 44 24 08 ca 10 80 	movl   $0x8010ca,0x8(%esp)
  800136:	00 
  800137:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80013e:	00 
  80013f:	c7 04 24 e7 10 80 00 	movl   $0x8010e7,(%esp)
  800146:	e8 d5 02 00 00       	call   800420 <_panic>

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
  80017d:	b8 0b 00 00 00       	mov    $0xb,%eax
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
  8001c1:	c7 44 24 08 ca 10 80 	movl   $0x8010ca,0x8(%esp)
  8001c8:	00 
  8001c9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001d0:	00 
  8001d1:	c7 04 24 e7 10 80 00 	movl   $0x8010e7,(%esp)
  8001d8:	e8 43 02 00 00       	call   800420 <_panic>

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
  800214:	c7 44 24 08 ca 10 80 	movl   $0x8010ca,0x8(%esp)
  80021b:	00 
  80021c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800223:	00 
  800224:	c7 04 24 e7 10 80 00 	movl   $0x8010e7,(%esp)
  80022b:	e8 f0 01 00 00       	call   800420 <_panic>

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
  800267:	c7 44 24 08 ca 10 80 	movl   $0x8010ca,0x8(%esp)
  80026e:	00 
  80026f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800276:	00 
  800277:	c7 04 24 e7 10 80 00 	movl   $0x8010e7,(%esp)
  80027e:	e8 9d 01 00 00       	call   800420 <_panic>

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
  8002ba:	c7 44 24 08 ca 10 80 	movl   $0x8010ca,0x8(%esp)
  8002c1:	00 
  8002c2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002c9:	00 
  8002ca:	c7 04 24 e7 10 80 00 	movl   $0x8010e7,(%esp)
  8002d1:	e8 4a 01 00 00       	call   800420 <_panic>

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

008002de <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  8002ff:	7e 28                	jle    800329 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800301:	89 44 24 10          	mov    %eax,0x10(%esp)
  800305:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80030c:	00 
  80030d:	c7 44 24 08 ca 10 80 	movl   $0x8010ca,0x8(%esp)
  800314:	00 
  800315:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80031c:	00 
  80031d:	c7 04 24 e7 10 80 00 	movl   $0x8010e7,(%esp)
  800324:	e8 f7 00 00 00       	call   800420 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800329:	83 c4 2c             	add    $0x2c,%esp
  80032c:	5b                   	pop    %ebx
  80032d:	5e                   	pop    %esi
  80032e:	5f                   	pop    %edi
  80032f:	5d                   	pop    %ebp
  800330:	c3                   	ret    

00800331 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	57                   	push   %edi
  800335:	56                   	push   %esi
  800336:	53                   	push   %ebx
  800337:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80033a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80033f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800344:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800347:	8b 55 08             	mov    0x8(%ebp),%edx
  80034a:	89 df                	mov    %ebx,%edi
  80034c:	89 de                	mov    %ebx,%esi
  80034e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800350:	85 c0                	test   %eax,%eax
  800352:	7e 28                	jle    80037c <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800354:	89 44 24 10          	mov    %eax,0x10(%esp)
  800358:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80035f:	00 
  800360:	c7 44 24 08 ca 10 80 	movl   $0x8010ca,0x8(%esp)
  800367:	00 
  800368:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80036f:	00 
  800370:	c7 04 24 e7 10 80 00 	movl   $0x8010e7,(%esp)
  800377:	e8 a4 00 00 00       	call   800420 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80037c:	83 c4 2c             	add    $0x2c,%esp
  80037f:	5b                   	pop    %ebx
  800380:	5e                   	pop    %esi
  800381:	5f                   	pop    %edi
  800382:	5d                   	pop    %ebp
  800383:	c3                   	ret    

00800384 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	57                   	push   %edi
  800388:	56                   	push   %esi
  800389:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80038a:	be 00 00 00 00       	mov    $0x0,%esi
  80038f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800394:	8b 7d 14             	mov    0x14(%ebp),%edi
  800397:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80039a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80039d:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003a2:	5b                   	pop    %ebx
  8003a3:	5e                   	pop    %esi
  8003a4:	5f                   	pop    %edi
  8003a5:	5d                   	pop    %ebp
  8003a6:	c3                   	ret    

008003a7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003a7:	55                   	push   %ebp
  8003a8:	89 e5                	mov    %esp,%ebp
  8003aa:	57                   	push   %edi
  8003ab:	56                   	push   %esi
  8003ac:	53                   	push   %ebx
  8003ad:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003b0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003b5:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8003bd:	89 cb                	mov    %ecx,%ebx
  8003bf:	89 cf                	mov    %ecx,%edi
  8003c1:	89 ce                	mov    %ecx,%esi
  8003c3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003c5:	85 c0                	test   %eax,%eax
  8003c7:	7e 28                	jle    8003f1 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003c9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003cd:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003d4:	00 
  8003d5:	c7 44 24 08 ca 10 80 	movl   $0x8010ca,0x8(%esp)
  8003dc:	00 
  8003dd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003e4:	00 
  8003e5:	c7 04 24 e7 10 80 00 	movl   $0x8010e7,(%esp)
  8003ec:	e8 2f 00 00 00       	call   800420 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003f1:	83 c4 2c             	add    $0x2c,%esp
  8003f4:	5b                   	pop    %ebx
  8003f5:	5e                   	pop    %esi
  8003f6:	5f                   	pop    %edi
  8003f7:	5d                   	pop    %ebp
  8003f8:	c3                   	ret    
  8003f9:	00 00                	add    %al,(%eax)
	...

008003fc <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8003fc:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8003fd:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800402:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800404:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// Save trap-time eip in eax
	movl 0x28(%esp), %eax
  800407:	8b 44 24 28          	mov    0x28(%esp),%eax

	// Save our current stack
	movl %esp, %ebp
  80040b:	89 e5                	mov    %esp,%ebp

	// Switch to trap-time stack
	movl 0x30(%esp), %esp
  80040d:	8b 64 24 30          	mov    0x30(%esp),%esp

	// Push trap-time eip to the trap-time stack
	pushl %eax
  800411:	50                   	push   %eax

	// We now have to update the trap-time esp with its new value
	movl %esp, 0x30(%ebp)
  800412:	89 65 30             	mov    %esp,0x30(%ebp)

	// Go back to our exception stack
	movl %ebp, %esp
  800415:	89 ec                	mov    %ebp,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// Pop fault_va and err, both can be ignored
	popl %eax
  800417:	58                   	pop    %eax
	popl %eax
  800418:	58                   	pop    %eax

	// Pop all registers back
	popal
  800419:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// Skip %eip
	addl $0x4, %esp
  80041a:	83 c4 04             	add    $0x4,%esp

	// Pop eflags back
	popfl
  80041d:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	
	popl %esp
  80041e:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  80041f:	c3                   	ret    

00800420 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800420:	55                   	push   %ebp
  800421:	89 e5                	mov    %esp,%ebp
  800423:	56                   	push   %esi
  800424:	53                   	push   %ebx
  800425:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800428:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80042b:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800431:	e8 1d fd ff ff       	call   800153 <sys_getenvid>
  800436:	8b 55 0c             	mov    0xc(%ebp),%edx
  800439:	89 54 24 10          	mov    %edx,0x10(%esp)
  80043d:	8b 55 08             	mov    0x8(%ebp),%edx
  800440:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800444:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800448:	89 44 24 04          	mov    %eax,0x4(%esp)
  80044c:	c7 04 24 f8 10 80 00 	movl   $0x8010f8,(%esp)
  800453:	e8 c0 00 00 00       	call   800518 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800458:	89 74 24 04          	mov    %esi,0x4(%esp)
  80045c:	8b 45 10             	mov    0x10(%ebp),%eax
  80045f:	89 04 24             	mov    %eax,(%esp)
  800462:	e8 50 00 00 00       	call   8004b7 <vcprintf>
	cprintf("\n");
  800467:	c7 04 24 1b 11 80 00 	movl   $0x80111b,(%esp)
  80046e:	e8 a5 00 00 00       	call   800518 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800473:	cc                   	int3   
  800474:	eb fd                	jmp    800473 <_panic+0x53>
	...

00800478 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800478:	55                   	push   %ebp
  800479:	89 e5                	mov    %esp,%ebp
  80047b:	53                   	push   %ebx
  80047c:	83 ec 14             	sub    $0x14,%esp
  80047f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800482:	8b 03                	mov    (%ebx),%eax
  800484:	8b 55 08             	mov    0x8(%ebp),%edx
  800487:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80048b:	40                   	inc    %eax
  80048c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80048e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800493:	75 19                	jne    8004ae <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800495:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80049c:	00 
  80049d:	8d 43 08             	lea    0x8(%ebx),%eax
  8004a0:	89 04 24             	mov    %eax,(%esp)
  8004a3:	e8 1c fc ff ff       	call   8000c4 <sys_cputs>
		b->idx = 0;
  8004a8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8004ae:	ff 43 04             	incl   0x4(%ebx)
}
  8004b1:	83 c4 14             	add    $0x14,%esp
  8004b4:	5b                   	pop    %ebx
  8004b5:	5d                   	pop    %ebp
  8004b6:	c3                   	ret    

008004b7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004b7:	55                   	push   %ebp
  8004b8:	89 e5                	mov    %esp,%ebp
  8004ba:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8004c0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004c7:	00 00 00 
	b.cnt = 0;
  8004ca:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004d1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004db:	8b 45 08             	mov    0x8(%ebp),%eax
  8004de:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004e2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ec:	c7 04 24 78 04 80 00 	movl   $0x800478,(%esp)
  8004f3:	e8 82 01 00 00       	call   80067a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004f8:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8004fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800502:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800508:	89 04 24             	mov    %eax,(%esp)
  80050b:	e8 b4 fb ff ff       	call   8000c4 <sys_cputs>

	return b.cnt;
}
  800510:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800516:	c9                   	leave  
  800517:	c3                   	ret    

00800518 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800518:	55                   	push   %ebp
  800519:	89 e5                	mov    %esp,%ebp
  80051b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80051e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800521:	89 44 24 04          	mov    %eax,0x4(%esp)
  800525:	8b 45 08             	mov    0x8(%ebp),%eax
  800528:	89 04 24             	mov    %eax,(%esp)
  80052b:	e8 87 ff ff ff       	call   8004b7 <vcprintf>
	va_end(ap);

	return cnt;
}
  800530:	c9                   	leave  
  800531:	c3                   	ret    
	...

00800534 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800534:	55                   	push   %ebp
  800535:	89 e5                	mov    %esp,%ebp
  800537:	57                   	push   %edi
  800538:	56                   	push   %esi
  800539:	53                   	push   %ebx
  80053a:	83 ec 3c             	sub    $0x3c,%esp
  80053d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800540:	89 d7                	mov    %edx,%edi
  800542:	8b 45 08             	mov    0x8(%ebp),%eax
  800545:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800548:	8b 45 0c             	mov    0xc(%ebp),%eax
  80054b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80054e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800551:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800554:	85 c0                	test   %eax,%eax
  800556:	75 08                	jne    800560 <printnum+0x2c>
  800558:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80055b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80055e:	77 57                	ja     8005b7 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800560:	89 74 24 10          	mov    %esi,0x10(%esp)
  800564:	4b                   	dec    %ebx
  800565:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800569:	8b 45 10             	mov    0x10(%ebp),%eax
  80056c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800570:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800574:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800578:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80057f:	00 
  800580:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800583:	89 04 24             	mov    %eax,(%esp)
  800586:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800589:	89 44 24 04          	mov    %eax,0x4(%esp)
  80058d:	e8 ca 08 00 00       	call   800e5c <__udivdi3>
  800592:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800596:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80059a:	89 04 24             	mov    %eax,(%esp)
  80059d:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005a1:	89 fa                	mov    %edi,%edx
  8005a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005a6:	e8 89 ff ff ff       	call   800534 <printnum>
  8005ab:	eb 0f                	jmp    8005bc <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8005ad:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005b1:	89 34 24             	mov    %esi,(%esp)
  8005b4:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005b7:	4b                   	dec    %ebx
  8005b8:	85 db                	test   %ebx,%ebx
  8005ba:	7f f1                	jg     8005ad <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8005bc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005c0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8005c4:	8b 45 10             	mov    0x10(%ebp),%eax
  8005c7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005cb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005d2:	00 
  8005d3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005d6:	89 04 24             	mov    %eax,(%esp)
  8005d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e0:	e8 97 09 00 00       	call   800f7c <__umoddi3>
  8005e5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005e9:	0f be 80 1d 11 80 00 	movsbl 0x80111d(%eax),%eax
  8005f0:	89 04 24             	mov    %eax,(%esp)
  8005f3:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8005f6:	83 c4 3c             	add    $0x3c,%esp
  8005f9:	5b                   	pop    %ebx
  8005fa:	5e                   	pop    %esi
  8005fb:	5f                   	pop    %edi
  8005fc:	5d                   	pop    %ebp
  8005fd:	c3                   	ret    

008005fe <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8005fe:	55                   	push   %ebp
  8005ff:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800601:	83 fa 01             	cmp    $0x1,%edx
  800604:	7e 0e                	jle    800614 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800606:	8b 10                	mov    (%eax),%edx
  800608:	8d 4a 08             	lea    0x8(%edx),%ecx
  80060b:	89 08                	mov    %ecx,(%eax)
  80060d:	8b 02                	mov    (%edx),%eax
  80060f:	8b 52 04             	mov    0x4(%edx),%edx
  800612:	eb 22                	jmp    800636 <getuint+0x38>
	else if (lflag)
  800614:	85 d2                	test   %edx,%edx
  800616:	74 10                	je     800628 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800618:	8b 10                	mov    (%eax),%edx
  80061a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80061d:	89 08                	mov    %ecx,(%eax)
  80061f:	8b 02                	mov    (%edx),%eax
  800621:	ba 00 00 00 00       	mov    $0x0,%edx
  800626:	eb 0e                	jmp    800636 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800628:	8b 10                	mov    (%eax),%edx
  80062a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80062d:	89 08                	mov    %ecx,(%eax)
  80062f:	8b 02                	mov    (%edx),%eax
  800631:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800636:	5d                   	pop    %ebp
  800637:	c3                   	ret    

00800638 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800638:	55                   	push   %ebp
  800639:	89 e5                	mov    %esp,%ebp
  80063b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80063e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800641:	8b 10                	mov    (%eax),%edx
  800643:	3b 50 04             	cmp    0x4(%eax),%edx
  800646:	73 08                	jae    800650 <sprintputch+0x18>
		*b->buf++ = ch;
  800648:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80064b:	88 0a                	mov    %cl,(%edx)
  80064d:	42                   	inc    %edx
  80064e:	89 10                	mov    %edx,(%eax)
}
  800650:	5d                   	pop    %ebp
  800651:	c3                   	ret    

00800652 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800652:	55                   	push   %ebp
  800653:	89 e5                	mov    %esp,%ebp
  800655:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800658:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80065b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80065f:	8b 45 10             	mov    0x10(%ebp),%eax
  800662:	89 44 24 08          	mov    %eax,0x8(%esp)
  800666:	8b 45 0c             	mov    0xc(%ebp),%eax
  800669:	89 44 24 04          	mov    %eax,0x4(%esp)
  80066d:	8b 45 08             	mov    0x8(%ebp),%eax
  800670:	89 04 24             	mov    %eax,(%esp)
  800673:	e8 02 00 00 00       	call   80067a <vprintfmt>
	va_end(ap);
}
  800678:	c9                   	leave  
  800679:	c3                   	ret    

0080067a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80067a:	55                   	push   %ebp
  80067b:	89 e5                	mov    %esp,%ebp
  80067d:	57                   	push   %edi
  80067e:	56                   	push   %esi
  80067f:	53                   	push   %ebx
  800680:	83 ec 4c             	sub    $0x4c,%esp
  800683:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800686:	8b 75 10             	mov    0x10(%ebp),%esi
  800689:	eb 12                	jmp    80069d <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80068b:	85 c0                	test   %eax,%eax
  80068d:	0f 84 6b 03 00 00    	je     8009fe <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800693:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800697:	89 04 24             	mov    %eax,(%esp)
  80069a:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80069d:	0f b6 06             	movzbl (%esi),%eax
  8006a0:	46                   	inc    %esi
  8006a1:	83 f8 25             	cmp    $0x25,%eax
  8006a4:	75 e5                	jne    80068b <vprintfmt+0x11>
  8006a6:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8006aa:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8006b1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8006b6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8006bd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006c2:	eb 26                	jmp    8006ea <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c4:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8006c7:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8006cb:	eb 1d                	jmp    8006ea <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006cd:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8006d0:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8006d4:	eb 14                	jmp    8006ea <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8006d9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8006e0:	eb 08                	jmp    8006ea <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8006e2:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8006e5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ea:	0f b6 06             	movzbl (%esi),%eax
  8006ed:	8d 56 01             	lea    0x1(%esi),%edx
  8006f0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8006f3:	8a 16                	mov    (%esi),%dl
  8006f5:	83 ea 23             	sub    $0x23,%edx
  8006f8:	80 fa 55             	cmp    $0x55,%dl
  8006fb:	0f 87 e1 02 00 00    	ja     8009e2 <vprintfmt+0x368>
  800701:	0f b6 d2             	movzbl %dl,%edx
  800704:	ff 24 95 60 12 80 00 	jmp    *0x801260(,%edx,4)
  80070b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80070e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800713:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800716:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80071a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80071d:	8d 50 d0             	lea    -0x30(%eax),%edx
  800720:	83 fa 09             	cmp    $0x9,%edx
  800723:	77 2a                	ja     80074f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800725:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800726:	eb eb                	jmp    800713 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800728:	8b 45 14             	mov    0x14(%ebp),%eax
  80072b:	8d 50 04             	lea    0x4(%eax),%edx
  80072e:	89 55 14             	mov    %edx,0x14(%ebp)
  800731:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800733:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800736:	eb 17                	jmp    80074f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800738:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80073c:	78 98                	js     8006d6 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80073e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800741:	eb a7                	jmp    8006ea <vprintfmt+0x70>
  800743:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800746:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80074d:	eb 9b                	jmp    8006ea <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80074f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800753:	79 95                	jns    8006ea <vprintfmt+0x70>
  800755:	eb 8b                	jmp    8006e2 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800757:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800758:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80075b:	eb 8d                	jmp    8006ea <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80075d:	8b 45 14             	mov    0x14(%ebp),%eax
  800760:	8d 50 04             	lea    0x4(%eax),%edx
  800763:	89 55 14             	mov    %edx,0x14(%ebp)
  800766:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80076a:	8b 00                	mov    (%eax),%eax
  80076c:	89 04 24             	mov    %eax,(%esp)
  80076f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800772:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800775:	e9 23 ff ff ff       	jmp    80069d <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80077a:	8b 45 14             	mov    0x14(%ebp),%eax
  80077d:	8d 50 04             	lea    0x4(%eax),%edx
  800780:	89 55 14             	mov    %edx,0x14(%ebp)
  800783:	8b 00                	mov    (%eax),%eax
  800785:	85 c0                	test   %eax,%eax
  800787:	79 02                	jns    80078b <vprintfmt+0x111>
  800789:	f7 d8                	neg    %eax
  80078b:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80078d:	83 f8 0f             	cmp    $0xf,%eax
  800790:	7f 0b                	jg     80079d <vprintfmt+0x123>
  800792:	8b 04 85 c0 13 80 00 	mov    0x8013c0(,%eax,4),%eax
  800799:	85 c0                	test   %eax,%eax
  80079b:	75 23                	jne    8007c0 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80079d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007a1:	c7 44 24 08 35 11 80 	movl   $0x801135,0x8(%esp)
  8007a8:	00 
  8007a9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b0:	89 04 24             	mov    %eax,(%esp)
  8007b3:	e8 9a fe ff ff       	call   800652 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b8:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8007bb:	e9 dd fe ff ff       	jmp    80069d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8007c0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007c4:	c7 44 24 08 3e 11 80 	movl   $0x80113e,0x8(%esp)
  8007cb:	00 
  8007cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8007d3:	89 14 24             	mov    %edx,(%esp)
  8007d6:	e8 77 fe ff ff       	call   800652 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007db:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007de:	e9 ba fe ff ff       	jmp    80069d <vprintfmt+0x23>
  8007e3:	89 f9                	mov    %edi,%ecx
  8007e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007e8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8007eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ee:	8d 50 04             	lea    0x4(%eax),%edx
  8007f1:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f4:	8b 30                	mov    (%eax),%esi
  8007f6:	85 f6                	test   %esi,%esi
  8007f8:	75 05                	jne    8007ff <vprintfmt+0x185>
				p = "(null)";
  8007fa:	be 2e 11 80 00       	mov    $0x80112e,%esi
			if (width > 0 && padc != '-')
  8007ff:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800803:	0f 8e 84 00 00 00    	jle    80088d <vprintfmt+0x213>
  800809:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80080d:	74 7e                	je     80088d <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80080f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800813:	89 34 24             	mov    %esi,(%esp)
  800816:	e8 8b 02 00 00       	call   800aa6 <strnlen>
  80081b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80081e:	29 c2                	sub    %eax,%edx
  800820:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800823:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800827:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80082a:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80082d:	89 de                	mov    %ebx,%esi
  80082f:	89 d3                	mov    %edx,%ebx
  800831:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800833:	eb 0b                	jmp    800840 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800835:	89 74 24 04          	mov    %esi,0x4(%esp)
  800839:	89 3c 24             	mov    %edi,(%esp)
  80083c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80083f:	4b                   	dec    %ebx
  800840:	85 db                	test   %ebx,%ebx
  800842:	7f f1                	jg     800835 <vprintfmt+0x1bb>
  800844:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800847:	89 f3                	mov    %esi,%ebx
  800849:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80084c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80084f:	85 c0                	test   %eax,%eax
  800851:	79 05                	jns    800858 <vprintfmt+0x1de>
  800853:	b8 00 00 00 00       	mov    $0x0,%eax
  800858:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80085b:	29 c2                	sub    %eax,%edx
  80085d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800860:	eb 2b                	jmp    80088d <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800862:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800866:	74 18                	je     800880 <vprintfmt+0x206>
  800868:	8d 50 e0             	lea    -0x20(%eax),%edx
  80086b:	83 fa 5e             	cmp    $0x5e,%edx
  80086e:	76 10                	jbe    800880 <vprintfmt+0x206>
					putch('?', putdat);
  800870:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800874:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80087b:	ff 55 08             	call   *0x8(%ebp)
  80087e:	eb 0a                	jmp    80088a <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800880:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800884:	89 04 24             	mov    %eax,(%esp)
  800887:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80088a:	ff 4d e4             	decl   -0x1c(%ebp)
  80088d:	0f be 06             	movsbl (%esi),%eax
  800890:	46                   	inc    %esi
  800891:	85 c0                	test   %eax,%eax
  800893:	74 21                	je     8008b6 <vprintfmt+0x23c>
  800895:	85 ff                	test   %edi,%edi
  800897:	78 c9                	js     800862 <vprintfmt+0x1e8>
  800899:	4f                   	dec    %edi
  80089a:	79 c6                	jns    800862 <vprintfmt+0x1e8>
  80089c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80089f:	89 de                	mov    %ebx,%esi
  8008a1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8008a4:	eb 18                	jmp    8008be <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8008a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008aa:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8008b1:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8008b3:	4b                   	dec    %ebx
  8008b4:	eb 08                	jmp    8008be <vprintfmt+0x244>
  8008b6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008b9:	89 de                	mov    %ebx,%esi
  8008bb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8008be:	85 db                	test   %ebx,%ebx
  8008c0:	7f e4                	jg     8008a6 <vprintfmt+0x22c>
  8008c2:	89 7d 08             	mov    %edi,0x8(%ebp)
  8008c5:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008c7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008ca:	e9 ce fd ff ff       	jmp    80069d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008cf:	83 f9 01             	cmp    $0x1,%ecx
  8008d2:	7e 10                	jle    8008e4 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8008d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d7:	8d 50 08             	lea    0x8(%eax),%edx
  8008da:	89 55 14             	mov    %edx,0x14(%ebp)
  8008dd:	8b 30                	mov    (%eax),%esi
  8008df:	8b 78 04             	mov    0x4(%eax),%edi
  8008e2:	eb 26                	jmp    80090a <vprintfmt+0x290>
	else if (lflag)
  8008e4:	85 c9                	test   %ecx,%ecx
  8008e6:	74 12                	je     8008fa <vprintfmt+0x280>
		return va_arg(*ap, long);
  8008e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008eb:	8d 50 04             	lea    0x4(%eax),%edx
  8008ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8008f1:	8b 30                	mov    (%eax),%esi
  8008f3:	89 f7                	mov    %esi,%edi
  8008f5:	c1 ff 1f             	sar    $0x1f,%edi
  8008f8:	eb 10                	jmp    80090a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8008fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8008fd:	8d 50 04             	lea    0x4(%eax),%edx
  800900:	89 55 14             	mov    %edx,0x14(%ebp)
  800903:	8b 30                	mov    (%eax),%esi
  800905:	89 f7                	mov    %esi,%edi
  800907:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80090a:	85 ff                	test   %edi,%edi
  80090c:	78 0a                	js     800918 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80090e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800913:	e9 8c 00 00 00       	jmp    8009a4 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800918:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80091c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800923:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800926:	f7 de                	neg    %esi
  800928:	83 d7 00             	adc    $0x0,%edi
  80092b:	f7 df                	neg    %edi
			}
			base = 10;
  80092d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800932:	eb 70                	jmp    8009a4 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800934:	89 ca                	mov    %ecx,%edx
  800936:	8d 45 14             	lea    0x14(%ebp),%eax
  800939:	e8 c0 fc ff ff       	call   8005fe <getuint>
  80093e:	89 c6                	mov    %eax,%esi
  800940:	89 d7                	mov    %edx,%edi
			base = 10;
  800942:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800947:	eb 5b                	jmp    8009a4 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  800949:	89 ca                	mov    %ecx,%edx
  80094b:	8d 45 14             	lea    0x14(%ebp),%eax
  80094e:	e8 ab fc ff ff       	call   8005fe <getuint>
  800953:	89 c6                	mov    %eax,%esi
  800955:	89 d7                	mov    %edx,%edi
			base = 8;
  800957:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80095c:	eb 46                	jmp    8009a4 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  80095e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800962:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800969:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80096c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800970:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800977:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80097a:	8b 45 14             	mov    0x14(%ebp),%eax
  80097d:	8d 50 04             	lea    0x4(%eax),%edx
  800980:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800983:	8b 30                	mov    (%eax),%esi
  800985:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80098a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80098f:	eb 13                	jmp    8009a4 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800991:	89 ca                	mov    %ecx,%edx
  800993:	8d 45 14             	lea    0x14(%ebp),%eax
  800996:	e8 63 fc ff ff       	call   8005fe <getuint>
  80099b:	89 c6                	mov    %eax,%esi
  80099d:	89 d7                	mov    %edx,%edi
			base = 16;
  80099f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8009a4:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8009a8:	89 54 24 10          	mov    %edx,0x10(%esp)
  8009ac:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8009af:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8009b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009b7:	89 34 24             	mov    %esi,(%esp)
  8009ba:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009be:	89 da                	mov    %ebx,%edx
  8009c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c3:	e8 6c fb ff ff       	call   800534 <printnum>
			break;
  8009c8:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8009cb:	e9 cd fc ff ff       	jmp    80069d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8009d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009d4:	89 04 24             	mov    %eax,(%esp)
  8009d7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009da:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8009dd:	e9 bb fc ff ff       	jmp    80069d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8009e2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009e6:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8009ed:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009f0:	eb 01                	jmp    8009f3 <vprintfmt+0x379>
  8009f2:	4e                   	dec    %esi
  8009f3:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8009f7:	75 f9                	jne    8009f2 <vprintfmt+0x378>
  8009f9:	e9 9f fc ff ff       	jmp    80069d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8009fe:	83 c4 4c             	add    $0x4c,%esp
  800a01:	5b                   	pop    %ebx
  800a02:	5e                   	pop    %esi
  800a03:	5f                   	pop    %edi
  800a04:	5d                   	pop    %ebp
  800a05:	c3                   	ret    

00800a06 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	83 ec 28             	sub    $0x28,%esp
  800a0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a12:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a15:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a19:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a1c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a23:	85 c0                	test   %eax,%eax
  800a25:	74 30                	je     800a57 <vsnprintf+0x51>
  800a27:	85 d2                	test   %edx,%edx
  800a29:	7e 33                	jle    800a5e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a2b:	8b 45 14             	mov    0x14(%ebp),%eax
  800a2e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a32:	8b 45 10             	mov    0x10(%ebp),%eax
  800a35:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a39:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a3c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a40:	c7 04 24 38 06 80 00 	movl   $0x800638,(%esp)
  800a47:	e8 2e fc ff ff       	call   80067a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a4c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a4f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a55:	eb 0c                	jmp    800a63 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a57:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a5c:	eb 05                	jmp    800a63 <vsnprintf+0x5d>
  800a5e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a63:	c9                   	leave  
  800a64:	c3                   	ret    

00800a65 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a65:	55                   	push   %ebp
  800a66:	89 e5                	mov    %esp,%ebp
  800a68:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a6b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a6e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a72:	8b 45 10             	mov    0x10(%ebp),%eax
  800a75:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a79:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a7c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a80:	8b 45 08             	mov    0x8(%ebp),%eax
  800a83:	89 04 24             	mov    %eax,(%esp)
  800a86:	e8 7b ff ff ff       	call   800a06 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a8b:	c9                   	leave  
  800a8c:	c3                   	ret    
  800a8d:	00 00                	add    %al,(%eax)
	...

00800a90 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a90:	55                   	push   %ebp
  800a91:	89 e5                	mov    %esp,%ebp
  800a93:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a96:	b8 00 00 00 00       	mov    $0x0,%eax
  800a9b:	eb 01                	jmp    800a9e <strlen+0xe>
		n++;
  800a9d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a9e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800aa2:	75 f9                	jne    800a9d <strlen+0xd>
		n++;
	return n;
}
  800aa4:	5d                   	pop    %ebp
  800aa5:	c3                   	ret    

00800aa6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800aa6:	55                   	push   %ebp
  800aa7:	89 e5                	mov    %esp,%ebp
  800aa9:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800aac:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800aaf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab4:	eb 01                	jmp    800ab7 <strnlen+0x11>
		n++;
  800ab6:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ab7:	39 d0                	cmp    %edx,%eax
  800ab9:	74 06                	je     800ac1 <strnlen+0x1b>
  800abb:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800abf:	75 f5                	jne    800ab6 <strnlen+0x10>
		n++;
	return n;
}
  800ac1:	5d                   	pop    %ebp
  800ac2:	c3                   	ret    

00800ac3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800ac3:	55                   	push   %ebp
  800ac4:	89 e5                	mov    %esp,%ebp
  800ac6:	53                   	push   %ebx
  800ac7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800acd:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad2:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800ad5:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800ad8:	42                   	inc    %edx
  800ad9:	84 c9                	test   %cl,%cl
  800adb:	75 f5                	jne    800ad2 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800add:	5b                   	pop    %ebx
  800ade:	5d                   	pop    %ebp
  800adf:	c3                   	ret    

00800ae0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800ae0:	55                   	push   %ebp
  800ae1:	89 e5                	mov    %esp,%ebp
  800ae3:	53                   	push   %ebx
  800ae4:	83 ec 08             	sub    $0x8,%esp
  800ae7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800aea:	89 1c 24             	mov    %ebx,(%esp)
  800aed:	e8 9e ff ff ff       	call   800a90 <strlen>
	strcpy(dst + len, src);
  800af2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800af5:	89 54 24 04          	mov    %edx,0x4(%esp)
  800af9:	01 d8                	add    %ebx,%eax
  800afb:	89 04 24             	mov    %eax,(%esp)
  800afe:	e8 c0 ff ff ff       	call   800ac3 <strcpy>
	return dst;
}
  800b03:	89 d8                	mov    %ebx,%eax
  800b05:	83 c4 08             	add    $0x8,%esp
  800b08:	5b                   	pop    %ebx
  800b09:	5d                   	pop    %ebp
  800b0a:	c3                   	ret    

00800b0b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b0b:	55                   	push   %ebp
  800b0c:	89 e5                	mov    %esp,%ebp
  800b0e:	56                   	push   %esi
  800b0f:	53                   	push   %ebx
  800b10:	8b 45 08             	mov    0x8(%ebp),%eax
  800b13:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b16:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b19:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b1e:	eb 0c                	jmp    800b2c <strncpy+0x21>
		*dst++ = *src;
  800b20:	8a 1a                	mov    (%edx),%bl
  800b22:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b25:	80 3a 01             	cmpb   $0x1,(%edx)
  800b28:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b2b:	41                   	inc    %ecx
  800b2c:	39 f1                	cmp    %esi,%ecx
  800b2e:	75 f0                	jne    800b20 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b30:	5b                   	pop    %ebx
  800b31:	5e                   	pop    %esi
  800b32:	5d                   	pop    %ebp
  800b33:	c3                   	ret    

00800b34 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	56                   	push   %esi
  800b38:	53                   	push   %ebx
  800b39:	8b 75 08             	mov    0x8(%ebp),%esi
  800b3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b3f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b42:	85 d2                	test   %edx,%edx
  800b44:	75 0a                	jne    800b50 <strlcpy+0x1c>
  800b46:	89 f0                	mov    %esi,%eax
  800b48:	eb 1a                	jmp    800b64 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b4a:	88 18                	mov    %bl,(%eax)
  800b4c:	40                   	inc    %eax
  800b4d:	41                   	inc    %ecx
  800b4e:	eb 02                	jmp    800b52 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b50:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800b52:	4a                   	dec    %edx
  800b53:	74 0a                	je     800b5f <strlcpy+0x2b>
  800b55:	8a 19                	mov    (%ecx),%bl
  800b57:	84 db                	test   %bl,%bl
  800b59:	75 ef                	jne    800b4a <strlcpy+0x16>
  800b5b:	89 c2                	mov    %eax,%edx
  800b5d:	eb 02                	jmp    800b61 <strlcpy+0x2d>
  800b5f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800b61:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800b64:	29 f0                	sub    %esi,%eax
}
  800b66:	5b                   	pop    %ebx
  800b67:	5e                   	pop    %esi
  800b68:	5d                   	pop    %ebp
  800b69:	c3                   	ret    

00800b6a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b6a:	55                   	push   %ebp
  800b6b:	89 e5                	mov    %esp,%ebp
  800b6d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b70:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b73:	eb 02                	jmp    800b77 <strcmp+0xd>
		p++, q++;
  800b75:	41                   	inc    %ecx
  800b76:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b77:	8a 01                	mov    (%ecx),%al
  800b79:	84 c0                	test   %al,%al
  800b7b:	74 04                	je     800b81 <strcmp+0x17>
  800b7d:	3a 02                	cmp    (%edx),%al
  800b7f:	74 f4                	je     800b75 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b81:	0f b6 c0             	movzbl %al,%eax
  800b84:	0f b6 12             	movzbl (%edx),%edx
  800b87:	29 d0                	sub    %edx,%eax
}
  800b89:	5d                   	pop    %ebp
  800b8a:	c3                   	ret    

00800b8b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b8b:	55                   	push   %ebp
  800b8c:	89 e5                	mov    %esp,%ebp
  800b8e:	53                   	push   %ebx
  800b8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b95:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800b98:	eb 03                	jmp    800b9d <strncmp+0x12>
		n--, p++, q++;
  800b9a:	4a                   	dec    %edx
  800b9b:	40                   	inc    %eax
  800b9c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b9d:	85 d2                	test   %edx,%edx
  800b9f:	74 14                	je     800bb5 <strncmp+0x2a>
  800ba1:	8a 18                	mov    (%eax),%bl
  800ba3:	84 db                	test   %bl,%bl
  800ba5:	74 04                	je     800bab <strncmp+0x20>
  800ba7:	3a 19                	cmp    (%ecx),%bl
  800ba9:	74 ef                	je     800b9a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800bab:	0f b6 00             	movzbl (%eax),%eax
  800bae:	0f b6 11             	movzbl (%ecx),%edx
  800bb1:	29 d0                	sub    %edx,%eax
  800bb3:	eb 05                	jmp    800bba <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800bb5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800bba:	5b                   	pop    %ebx
  800bbb:	5d                   	pop    %ebp
  800bbc:	c3                   	ret    

00800bbd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800bbd:	55                   	push   %ebp
  800bbe:	89 e5                	mov    %esp,%ebp
  800bc0:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800bc6:	eb 05                	jmp    800bcd <strchr+0x10>
		if (*s == c)
  800bc8:	38 ca                	cmp    %cl,%dl
  800bca:	74 0c                	je     800bd8 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800bcc:	40                   	inc    %eax
  800bcd:	8a 10                	mov    (%eax),%dl
  800bcf:	84 d2                	test   %dl,%dl
  800bd1:	75 f5                	jne    800bc8 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800bd3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bd8:	5d                   	pop    %ebp
  800bd9:	c3                   	ret    

00800bda <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bda:	55                   	push   %ebp
  800bdb:	89 e5                	mov    %esp,%ebp
  800bdd:	8b 45 08             	mov    0x8(%ebp),%eax
  800be0:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800be3:	eb 05                	jmp    800bea <strfind+0x10>
		if (*s == c)
  800be5:	38 ca                	cmp    %cl,%dl
  800be7:	74 07                	je     800bf0 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800be9:	40                   	inc    %eax
  800bea:	8a 10                	mov    (%eax),%dl
  800bec:	84 d2                	test   %dl,%dl
  800bee:	75 f5                	jne    800be5 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800bf0:	5d                   	pop    %ebp
  800bf1:	c3                   	ret    

00800bf2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bf2:	55                   	push   %ebp
  800bf3:	89 e5                	mov    %esp,%ebp
  800bf5:	57                   	push   %edi
  800bf6:	56                   	push   %esi
  800bf7:	53                   	push   %ebx
  800bf8:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bfb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bfe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c01:	85 c9                	test   %ecx,%ecx
  800c03:	74 30                	je     800c35 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c05:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c0b:	75 25                	jne    800c32 <memset+0x40>
  800c0d:	f6 c1 03             	test   $0x3,%cl
  800c10:	75 20                	jne    800c32 <memset+0x40>
		c &= 0xFF;
  800c12:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c15:	89 d3                	mov    %edx,%ebx
  800c17:	c1 e3 08             	shl    $0x8,%ebx
  800c1a:	89 d6                	mov    %edx,%esi
  800c1c:	c1 e6 18             	shl    $0x18,%esi
  800c1f:	89 d0                	mov    %edx,%eax
  800c21:	c1 e0 10             	shl    $0x10,%eax
  800c24:	09 f0                	or     %esi,%eax
  800c26:	09 d0                	or     %edx,%eax
  800c28:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c2a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800c2d:	fc                   	cld    
  800c2e:	f3 ab                	rep stos %eax,%es:(%edi)
  800c30:	eb 03                	jmp    800c35 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c32:	fc                   	cld    
  800c33:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c35:	89 f8                	mov    %edi,%eax
  800c37:	5b                   	pop    %ebx
  800c38:	5e                   	pop    %esi
  800c39:	5f                   	pop    %edi
  800c3a:	5d                   	pop    %ebp
  800c3b:	c3                   	ret    

00800c3c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c3c:	55                   	push   %ebp
  800c3d:	89 e5                	mov    %esp,%ebp
  800c3f:	57                   	push   %edi
  800c40:	56                   	push   %esi
  800c41:	8b 45 08             	mov    0x8(%ebp),%eax
  800c44:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c47:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c4a:	39 c6                	cmp    %eax,%esi
  800c4c:	73 34                	jae    800c82 <memmove+0x46>
  800c4e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c51:	39 d0                	cmp    %edx,%eax
  800c53:	73 2d                	jae    800c82 <memmove+0x46>
		s += n;
		d += n;
  800c55:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c58:	f6 c2 03             	test   $0x3,%dl
  800c5b:	75 1b                	jne    800c78 <memmove+0x3c>
  800c5d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c63:	75 13                	jne    800c78 <memmove+0x3c>
  800c65:	f6 c1 03             	test   $0x3,%cl
  800c68:	75 0e                	jne    800c78 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c6a:	83 ef 04             	sub    $0x4,%edi
  800c6d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c70:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c73:	fd                   	std    
  800c74:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c76:	eb 07                	jmp    800c7f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c78:	4f                   	dec    %edi
  800c79:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c7c:	fd                   	std    
  800c7d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c7f:	fc                   	cld    
  800c80:	eb 20                	jmp    800ca2 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c82:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c88:	75 13                	jne    800c9d <memmove+0x61>
  800c8a:	a8 03                	test   $0x3,%al
  800c8c:	75 0f                	jne    800c9d <memmove+0x61>
  800c8e:	f6 c1 03             	test   $0x3,%cl
  800c91:	75 0a                	jne    800c9d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c93:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c96:	89 c7                	mov    %eax,%edi
  800c98:	fc                   	cld    
  800c99:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c9b:	eb 05                	jmp    800ca2 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c9d:	89 c7                	mov    %eax,%edi
  800c9f:	fc                   	cld    
  800ca0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ca2:	5e                   	pop    %esi
  800ca3:	5f                   	pop    %edi
  800ca4:	5d                   	pop    %ebp
  800ca5:	c3                   	ret    

00800ca6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ca6:	55                   	push   %ebp
  800ca7:	89 e5                	mov    %esp,%ebp
  800ca9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800cac:	8b 45 10             	mov    0x10(%ebp),%eax
  800caf:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cb3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cb6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cba:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbd:	89 04 24             	mov    %eax,(%esp)
  800cc0:	e8 77 ff ff ff       	call   800c3c <memmove>
}
  800cc5:	c9                   	leave  
  800cc6:	c3                   	ret    

00800cc7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cc7:	55                   	push   %ebp
  800cc8:	89 e5                	mov    %esp,%ebp
  800cca:	57                   	push   %edi
  800ccb:	56                   	push   %esi
  800ccc:	53                   	push   %ebx
  800ccd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cd0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cd3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cd6:	ba 00 00 00 00       	mov    $0x0,%edx
  800cdb:	eb 16                	jmp    800cf3 <memcmp+0x2c>
		if (*s1 != *s2)
  800cdd:	8a 04 17             	mov    (%edi,%edx,1),%al
  800ce0:	42                   	inc    %edx
  800ce1:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800ce5:	38 c8                	cmp    %cl,%al
  800ce7:	74 0a                	je     800cf3 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800ce9:	0f b6 c0             	movzbl %al,%eax
  800cec:	0f b6 c9             	movzbl %cl,%ecx
  800cef:	29 c8                	sub    %ecx,%eax
  800cf1:	eb 09                	jmp    800cfc <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cf3:	39 da                	cmp    %ebx,%edx
  800cf5:	75 e6                	jne    800cdd <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800cf7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cfc:	5b                   	pop    %ebx
  800cfd:	5e                   	pop    %esi
  800cfe:	5f                   	pop    %edi
  800cff:	5d                   	pop    %ebp
  800d00:	c3                   	ret    

00800d01 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d01:	55                   	push   %ebp
  800d02:	89 e5                	mov    %esp,%ebp
  800d04:	8b 45 08             	mov    0x8(%ebp),%eax
  800d07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800d0a:	89 c2                	mov    %eax,%edx
  800d0c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d0f:	eb 05                	jmp    800d16 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d11:	38 08                	cmp    %cl,(%eax)
  800d13:	74 05                	je     800d1a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d15:	40                   	inc    %eax
  800d16:	39 d0                	cmp    %edx,%eax
  800d18:	72 f7                	jb     800d11 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d1a:	5d                   	pop    %ebp
  800d1b:	c3                   	ret    

00800d1c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d1c:	55                   	push   %ebp
  800d1d:	89 e5                	mov    %esp,%ebp
  800d1f:	57                   	push   %edi
  800d20:	56                   	push   %esi
  800d21:	53                   	push   %ebx
  800d22:	8b 55 08             	mov    0x8(%ebp),%edx
  800d25:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d28:	eb 01                	jmp    800d2b <strtol+0xf>
		s++;
  800d2a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d2b:	8a 02                	mov    (%edx),%al
  800d2d:	3c 20                	cmp    $0x20,%al
  800d2f:	74 f9                	je     800d2a <strtol+0xe>
  800d31:	3c 09                	cmp    $0x9,%al
  800d33:	74 f5                	je     800d2a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d35:	3c 2b                	cmp    $0x2b,%al
  800d37:	75 08                	jne    800d41 <strtol+0x25>
		s++;
  800d39:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d3a:	bf 00 00 00 00       	mov    $0x0,%edi
  800d3f:	eb 13                	jmp    800d54 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d41:	3c 2d                	cmp    $0x2d,%al
  800d43:	75 0a                	jne    800d4f <strtol+0x33>
		s++, neg = 1;
  800d45:	8d 52 01             	lea    0x1(%edx),%edx
  800d48:	bf 01 00 00 00       	mov    $0x1,%edi
  800d4d:	eb 05                	jmp    800d54 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d4f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d54:	85 db                	test   %ebx,%ebx
  800d56:	74 05                	je     800d5d <strtol+0x41>
  800d58:	83 fb 10             	cmp    $0x10,%ebx
  800d5b:	75 28                	jne    800d85 <strtol+0x69>
  800d5d:	8a 02                	mov    (%edx),%al
  800d5f:	3c 30                	cmp    $0x30,%al
  800d61:	75 10                	jne    800d73 <strtol+0x57>
  800d63:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d67:	75 0a                	jne    800d73 <strtol+0x57>
		s += 2, base = 16;
  800d69:	83 c2 02             	add    $0x2,%edx
  800d6c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d71:	eb 12                	jmp    800d85 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800d73:	85 db                	test   %ebx,%ebx
  800d75:	75 0e                	jne    800d85 <strtol+0x69>
  800d77:	3c 30                	cmp    $0x30,%al
  800d79:	75 05                	jne    800d80 <strtol+0x64>
		s++, base = 8;
  800d7b:	42                   	inc    %edx
  800d7c:	b3 08                	mov    $0x8,%bl
  800d7e:	eb 05                	jmp    800d85 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800d80:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800d85:	b8 00 00 00 00       	mov    $0x0,%eax
  800d8a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d8c:	8a 0a                	mov    (%edx),%cl
  800d8e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d91:	80 fb 09             	cmp    $0x9,%bl
  800d94:	77 08                	ja     800d9e <strtol+0x82>
			dig = *s - '0';
  800d96:	0f be c9             	movsbl %cl,%ecx
  800d99:	83 e9 30             	sub    $0x30,%ecx
  800d9c:	eb 1e                	jmp    800dbc <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800d9e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800da1:	80 fb 19             	cmp    $0x19,%bl
  800da4:	77 08                	ja     800dae <strtol+0x92>
			dig = *s - 'a' + 10;
  800da6:	0f be c9             	movsbl %cl,%ecx
  800da9:	83 e9 57             	sub    $0x57,%ecx
  800dac:	eb 0e                	jmp    800dbc <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800dae:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800db1:	80 fb 19             	cmp    $0x19,%bl
  800db4:	77 12                	ja     800dc8 <strtol+0xac>
			dig = *s - 'A' + 10;
  800db6:	0f be c9             	movsbl %cl,%ecx
  800db9:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800dbc:	39 f1                	cmp    %esi,%ecx
  800dbe:	7d 0c                	jge    800dcc <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800dc0:	42                   	inc    %edx
  800dc1:	0f af c6             	imul   %esi,%eax
  800dc4:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800dc6:	eb c4                	jmp    800d8c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800dc8:	89 c1                	mov    %eax,%ecx
  800dca:	eb 02                	jmp    800dce <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800dcc:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800dce:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dd2:	74 05                	je     800dd9 <strtol+0xbd>
		*endptr = (char *) s;
  800dd4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800dd7:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800dd9:	85 ff                	test   %edi,%edi
  800ddb:	74 04                	je     800de1 <strtol+0xc5>
  800ddd:	89 c8                	mov    %ecx,%eax
  800ddf:	f7 d8                	neg    %eax
}
  800de1:	5b                   	pop    %ebx
  800de2:	5e                   	pop    %esi
  800de3:	5f                   	pop    %edi
  800de4:	5d                   	pop    %ebp
  800de5:	c3                   	ret    
	...

00800de8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800de8:	55                   	push   %ebp
  800de9:	89 e5                	mov    %esp,%ebp
  800deb:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800dee:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800df5:	75 58                	jne    800e4f <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.	
		//panic("set_pgfault_handler not implemented");
		
		if (sys_page_alloc(thisenv->env_id,(void *) (UXSTACKTOP - PGSIZE),(PTE_W|PTE_U|PTE_P)) != 0){
  800df7:	a1 04 20 80 00       	mov    0x802004,%eax
  800dfc:	8b 40 48             	mov    0x48(%eax),%eax
  800dff:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800e06:	00 
  800e07:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800e0e:	ee 
  800e0f:	89 04 24             	mov    %eax,(%esp)
  800e12:	e8 7a f3 ff ff       	call   800191 <sys_page_alloc>
  800e17:	85 c0                	test   %eax,%eax
  800e19:	74 1c                	je     800e37 <set_pgfault_handler+0x4f>
			panic("set_pg_fault_handler");
  800e1b:	c7 44 24 08 20 14 80 	movl   $0x801420,0x8(%esp)
  800e22:	00 
  800e23:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e2a:	00 
  800e2b:	c7 04 24 35 14 80 00 	movl   $0x801435,(%esp)
  800e32:	e8 e9 f5 ff ff       	call   800420 <_panic>
		}
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  800e37:	a1 04 20 80 00       	mov    0x802004,%eax
  800e3c:	8b 40 48             	mov    0x48(%eax),%eax
  800e3f:	c7 44 24 04 fc 03 80 	movl   $0x8003fc,0x4(%esp)
  800e46:	00 
  800e47:	89 04 24             	mov    %eax,(%esp)
  800e4a:	e8 e2 f4 ff ff       	call   800331 <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e52:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800e57:	c9                   	leave  
  800e58:	c3                   	ret    
  800e59:	00 00                	add    %al,(%eax)
	...

00800e5c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800e5c:	55                   	push   %ebp
  800e5d:	57                   	push   %edi
  800e5e:	56                   	push   %esi
  800e5f:	83 ec 10             	sub    $0x10,%esp
  800e62:	8b 74 24 20          	mov    0x20(%esp),%esi
  800e66:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800e6a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e6e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  800e72:	89 cd                	mov    %ecx,%ebp
  800e74:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e78:	85 c0                	test   %eax,%eax
  800e7a:	75 2c                	jne    800ea8 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800e7c:	39 f9                	cmp    %edi,%ecx
  800e7e:	77 68                	ja     800ee8 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800e80:	85 c9                	test   %ecx,%ecx
  800e82:	75 0b                	jne    800e8f <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800e84:	b8 01 00 00 00       	mov    $0x1,%eax
  800e89:	31 d2                	xor    %edx,%edx
  800e8b:	f7 f1                	div    %ecx
  800e8d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800e8f:	31 d2                	xor    %edx,%edx
  800e91:	89 f8                	mov    %edi,%eax
  800e93:	f7 f1                	div    %ecx
  800e95:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e97:	89 f0                	mov    %esi,%eax
  800e99:	f7 f1                	div    %ecx
  800e9b:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e9d:	89 f0                	mov    %esi,%eax
  800e9f:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800ea1:	83 c4 10             	add    $0x10,%esp
  800ea4:	5e                   	pop    %esi
  800ea5:	5f                   	pop    %edi
  800ea6:	5d                   	pop    %ebp
  800ea7:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800ea8:	39 f8                	cmp    %edi,%eax
  800eaa:	77 2c                	ja     800ed8 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800eac:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  800eaf:	83 f6 1f             	xor    $0x1f,%esi
  800eb2:	75 4c                	jne    800f00 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800eb4:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800eb6:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ebb:	72 0a                	jb     800ec7 <__udivdi3+0x6b>
  800ebd:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800ec1:	0f 87 ad 00 00 00    	ja     800f74 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800ec7:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800ecc:	89 f0                	mov    %esi,%eax
  800ece:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800ed0:	83 c4 10             	add    $0x10,%esp
  800ed3:	5e                   	pop    %esi
  800ed4:	5f                   	pop    %edi
  800ed5:	5d                   	pop    %ebp
  800ed6:	c3                   	ret    
  800ed7:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800ed8:	31 ff                	xor    %edi,%edi
  800eda:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800edc:	89 f0                	mov    %esi,%eax
  800ede:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800ee0:	83 c4 10             	add    $0x10,%esp
  800ee3:	5e                   	pop    %esi
  800ee4:	5f                   	pop    %edi
  800ee5:	5d                   	pop    %ebp
  800ee6:	c3                   	ret    
  800ee7:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ee8:	89 fa                	mov    %edi,%edx
  800eea:	89 f0                	mov    %esi,%eax
  800eec:	f7 f1                	div    %ecx
  800eee:	89 c6                	mov    %eax,%esi
  800ef0:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800ef2:	89 f0                	mov    %esi,%eax
  800ef4:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800ef6:	83 c4 10             	add    $0x10,%esp
  800ef9:	5e                   	pop    %esi
  800efa:	5f                   	pop    %edi
  800efb:	5d                   	pop    %ebp
  800efc:	c3                   	ret    
  800efd:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800f00:	89 f1                	mov    %esi,%ecx
  800f02:	d3 e0                	shl    %cl,%eax
  800f04:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800f08:	b8 20 00 00 00       	mov    $0x20,%eax
  800f0d:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800f0f:	89 ea                	mov    %ebp,%edx
  800f11:	88 c1                	mov    %al,%cl
  800f13:	d3 ea                	shr    %cl,%edx
  800f15:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800f19:	09 ca                	or     %ecx,%edx
  800f1b:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  800f1f:	89 f1                	mov    %esi,%ecx
  800f21:	d3 e5                	shl    %cl,%ebp
  800f23:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  800f27:	89 fd                	mov    %edi,%ebp
  800f29:	88 c1                	mov    %al,%cl
  800f2b:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  800f2d:	89 fa                	mov    %edi,%edx
  800f2f:	89 f1                	mov    %esi,%ecx
  800f31:	d3 e2                	shl    %cl,%edx
  800f33:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f37:	88 c1                	mov    %al,%cl
  800f39:	d3 ef                	shr    %cl,%edi
  800f3b:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800f3d:	89 f8                	mov    %edi,%eax
  800f3f:	89 ea                	mov    %ebp,%edx
  800f41:	f7 74 24 08          	divl   0x8(%esp)
  800f45:	89 d1                	mov    %edx,%ecx
  800f47:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  800f49:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f4d:	39 d1                	cmp    %edx,%ecx
  800f4f:	72 17                	jb     800f68 <__udivdi3+0x10c>
  800f51:	74 09                	je     800f5c <__udivdi3+0x100>
  800f53:	89 fe                	mov    %edi,%esi
  800f55:	31 ff                	xor    %edi,%edi
  800f57:	e9 41 ff ff ff       	jmp    800e9d <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800f5c:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f60:	89 f1                	mov    %esi,%ecx
  800f62:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f64:	39 c2                	cmp    %eax,%edx
  800f66:	73 eb                	jae    800f53 <__udivdi3+0xf7>
		{
		  q0--;
  800f68:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f6b:	31 ff                	xor    %edi,%edi
  800f6d:	e9 2b ff ff ff       	jmp    800e9d <__udivdi3+0x41>
  800f72:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800f74:	31 f6                	xor    %esi,%esi
  800f76:	e9 22 ff ff ff       	jmp    800e9d <__udivdi3+0x41>
	...

00800f7c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800f7c:	55                   	push   %ebp
  800f7d:	57                   	push   %edi
  800f7e:	56                   	push   %esi
  800f7f:	83 ec 20             	sub    $0x20,%esp
  800f82:	8b 44 24 30          	mov    0x30(%esp),%eax
  800f86:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800f8a:	89 44 24 14          	mov    %eax,0x14(%esp)
  800f8e:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  800f92:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800f96:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800f9a:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  800f9c:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800f9e:	85 ed                	test   %ebp,%ebp
  800fa0:	75 16                	jne    800fb8 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  800fa2:	39 f1                	cmp    %esi,%ecx
  800fa4:	0f 86 a6 00 00 00    	jbe    801050 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800faa:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800fac:	89 d0                	mov    %edx,%eax
  800fae:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800fb0:	83 c4 20             	add    $0x20,%esp
  800fb3:	5e                   	pop    %esi
  800fb4:	5f                   	pop    %edi
  800fb5:	5d                   	pop    %ebp
  800fb6:	c3                   	ret    
  800fb7:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800fb8:	39 f5                	cmp    %esi,%ebp
  800fba:	0f 87 ac 00 00 00    	ja     80106c <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800fc0:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  800fc3:	83 f0 1f             	xor    $0x1f,%eax
  800fc6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fca:	0f 84 a8 00 00 00    	je     801078 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800fd0:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800fd4:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800fd6:	bf 20 00 00 00       	mov    $0x20,%edi
  800fdb:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800fdf:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800fe3:	89 f9                	mov    %edi,%ecx
  800fe5:	d3 e8                	shr    %cl,%eax
  800fe7:	09 e8                	or     %ebp,%eax
  800fe9:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  800fed:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800ff1:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800ff5:	d3 e0                	shl    %cl,%eax
  800ff7:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800ffb:	89 f2                	mov    %esi,%edx
  800ffd:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800fff:	8b 44 24 14          	mov    0x14(%esp),%eax
  801003:	d3 e0                	shl    %cl,%eax
  801005:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801009:	8b 44 24 14          	mov    0x14(%esp),%eax
  80100d:	89 f9                	mov    %edi,%ecx
  80100f:	d3 e8                	shr    %cl,%eax
  801011:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801013:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801015:	89 f2                	mov    %esi,%edx
  801017:	f7 74 24 18          	divl   0x18(%esp)
  80101b:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80101d:	f7 64 24 0c          	mull   0xc(%esp)
  801021:	89 c5                	mov    %eax,%ebp
  801023:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801025:	39 d6                	cmp    %edx,%esi
  801027:	72 67                	jb     801090 <__umoddi3+0x114>
  801029:	74 75                	je     8010a0 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80102b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80102f:	29 e8                	sub    %ebp,%eax
  801031:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801033:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801037:	d3 e8                	shr    %cl,%eax
  801039:	89 f2                	mov    %esi,%edx
  80103b:	89 f9                	mov    %edi,%ecx
  80103d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80103f:	09 d0                	or     %edx,%eax
  801041:	89 f2                	mov    %esi,%edx
  801043:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801047:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801049:	83 c4 20             	add    $0x20,%esp
  80104c:	5e                   	pop    %esi
  80104d:	5f                   	pop    %edi
  80104e:	5d                   	pop    %ebp
  80104f:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801050:	85 c9                	test   %ecx,%ecx
  801052:	75 0b                	jne    80105f <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801054:	b8 01 00 00 00       	mov    $0x1,%eax
  801059:	31 d2                	xor    %edx,%edx
  80105b:	f7 f1                	div    %ecx
  80105d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80105f:	89 f0                	mov    %esi,%eax
  801061:	31 d2                	xor    %edx,%edx
  801063:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801065:	89 f8                	mov    %edi,%eax
  801067:	e9 3e ff ff ff       	jmp    800faa <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  80106c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80106e:	83 c4 20             	add    $0x20,%esp
  801071:	5e                   	pop    %esi
  801072:	5f                   	pop    %edi
  801073:	5d                   	pop    %ebp
  801074:	c3                   	ret    
  801075:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801078:	39 f5                	cmp    %esi,%ebp
  80107a:	72 04                	jb     801080 <__umoddi3+0x104>
  80107c:	39 f9                	cmp    %edi,%ecx
  80107e:	77 06                	ja     801086 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801080:	89 f2                	mov    %esi,%edx
  801082:	29 cf                	sub    %ecx,%edi
  801084:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801086:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801088:	83 c4 20             	add    $0x20,%esp
  80108b:	5e                   	pop    %esi
  80108c:	5f                   	pop    %edi
  80108d:	5d                   	pop    %ebp
  80108e:	c3                   	ret    
  80108f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801090:	89 d1                	mov    %edx,%ecx
  801092:	89 c5                	mov    %eax,%ebp
  801094:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801098:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  80109c:	eb 8d                	jmp    80102b <__umoddi3+0xaf>
  80109e:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8010a0:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8010a4:	72 ea                	jb     801090 <__umoddi3+0x114>
  8010a6:	89 f1                	mov    %esi,%ecx
  8010a8:	eb 81                	jmp    80102b <__umoddi3+0xaf>
