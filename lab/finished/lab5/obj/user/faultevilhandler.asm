
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
  800051:	e8 57 01 00 00       	call   8001ad <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xF0100020);
  800056:	c7 44 24 04 20 00 10 	movl   $0xf0100020,0x4(%esp)
  80005d:	f0 
  80005e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800065:	e8 e3 02 00 00       	call   80034d <sys_env_set_pgfault_upcall>
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
  800086:	e8 e4 00 00 00       	call   80016f <sys_getenvid>
  80008b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800090:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800097:	c1 e0 07             	shl    $0x7,%eax
  80009a:	29 d0                	sub    %edx,%eax
  80009c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000a1:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a6:	85 f6                	test   %esi,%esi
  8000a8:	7e 07                	jle    8000b1 <libmain+0x39>
		binaryname = argv[0];
  8000aa:	8b 03                	mov    (%ebx),%eax
  8000ac:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000b1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000b5:	89 34 24             	mov    %esi,(%esp)
  8000b8:	e8 77 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000bd:	e8 0a 00 00 00       	call   8000cc <exit>
}
  8000c2:	83 c4 10             	add    $0x10,%esp
  8000c5:	5b                   	pop    %ebx
  8000c6:	5e                   	pop    %esi
  8000c7:	5d                   	pop    %ebp
  8000c8:	c3                   	ret    
  8000c9:	00 00                	add    %al,(%eax)
	...

008000cc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  8000d2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000d9:	e8 3f 00 00 00       	call   80011d <sys_env_destroy>
}
  8000de:	c9                   	leave  
  8000df:	c3                   	ret    

008000e0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	57                   	push   %edi
  8000e4:	56                   	push   %esi
  8000e5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8000eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f1:	89 c3                	mov    %eax,%ebx
  8000f3:	89 c7                	mov    %eax,%edi
  8000f5:	89 c6                	mov    %eax,%esi
  8000f7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000f9:	5b                   	pop    %ebx
  8000fa:	5e                   	pop    %esi
  8000fb:	5f                   	pop    %edi
  8000fc:	5d                   	pop    %ebp
  8000fd:	c3                   	ret    

008000fe <sys_cgetc>:

int
sys_cgetc(void)
{
  8000fe:	55                   	push   %ebp
  8000ff:	89 e5                	mov    %esp,%ebp
  800101:	57                   	push   %edi
  800102:	56                   	push   %esi
  800103:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800104:	ba 00 00 00 00       	mov    $0x0,%edx
  800109:	b8 01 00 00 00       	mov    $0x1,%eax
  80010e:	89 d1                	mov    %edx,%ecx
  800110:	89 d3                	mov    %edx,%ebx
  800112:	89 d7                	mov    %edx,%edi
  800114:	89 d6                	mov    %edx,%esi
  800116:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800118:	5b                   	pop    %ebx
  800119:	5e                   	pop    %esi
  80011a:	5f                   	pop    %edi
  80011b:	5d                   	pop    %ebp
  80011c:	c3                   	ret    

0080011d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80011d:	55                   	push   %ebp
  80011e:	89 e5                	mov    %esp,%ebp
  800120:	57                   	push   %edi
  800121:	56                   	push   %esi
  800122:	53                   	push   %ebx
  800123:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800126:	b9 00 00 00 00       	mov    $0x0,%ecx
  80012b:	b8 03 00 00 00       	mov    $0x3,%eax
  800130:	8b 55 08             	mov    0x8(%ebp),%edx
  800133:	89 cb                	mov    %ecx,%ebx
  800135:	89 cf                	mov    %ecx,%edi
  800137:	89 ce                	mov    %ecx,%esi
  800139:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80013b:	85 c0                	test   %eax,%eax
  80013d:	7e 28                	jle    800167 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80013f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800143:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80014a:	00 
  80014b:	c7 44 24 08 4a 10 80 	movl   $0x80104a,0x8(%esp)
  800152:	00 
  800153:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80015a:	00 
  80015b:	c7 04 24 67 10 80 00 	movl   $0x801067,(%esp)
  800162:	e8 b1 02 00 00       	call   800418 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800167:	83 c4 2c             	add    $0x2c,%esp
  80016a:	5b                   	pop    %ebx
  80016b:	5e                   	pop    %esi
  80016c:	5f                   	pop    %edi
  80016d:	5d                   	pop    %ebp
  80016e:	c3                   	ret    

0080016f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80016f:	55                   	push   %ebp
  800170:	89 e5                	mov    %esp,%ebp
  800172:	57                   	push   %edi
  800173:	56                   	push   %esi
  800174:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800175:	ba 00 00 00 00       	mov    $0x0,%edx
  80017a:	b8 02 00 00 00       	mov    $0x2,%eax
  80017f:	89 d1                	mov    %edx,%ecx
  800181:	89 d3                	mov    %edx,%ebx
  800183:	89 d7                	mov    %edx,%edi
  800185:	89 d6                	mov    %edx,%esi
  800187:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800189:	5b                   	pop    %ebx
  80018a:	5e                   	pop    %esi
  80018b:	5f                   	pop    %edi
  80018c:	5d                   	pop    %ebp
  80018d:	c3                   	ret    

0080018e <sys_yield>:

void
sys_yield(void)
{
  80018e:	55                   	push   %ebp
  80018f:	89 e5                	mov    %esp,%ebp
  800191:	57                   	push   %edi
  800192:	56                   	push   %esi
  800193:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800194:	ba 00 00 00 00       	mov    $0x0,%edx
  800199:	b8 0b 00 00 00       	mov    $0xb,%eax
  80019e:	89 d1                	mov    %edx,%ecx
  8001a0:	89 d3                	mov    %edx,%ebx
  8001a2:	89 d7                	mov    %edx,%edi
  8001a4:	89 d6                	mov    %edx,%esi
  8001a6:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001a8:	5b                   	pop    %ebx
  8001a9:	5e                   	pop    %esi
  8001aa:	5f                   	pop    %edi
  8001ab:	5d                   	pop    %ebp
  8001ac:	c3                   	ret    

008001ad <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001ad:	55                   	push   %ebp
  8001ae:	89 e5                	mov    %esp,%ebp
  8001b0:	57                   	push   %edi
  8001b1:	56                   	push   %esi
  8001b2:	53                   	push   %ebx
  8001b3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b6:	be 00 00 00 00       	mov    $0x0,%esi
  8001bb:	b8 04 00 00 00       	mov    $0x4,%eax
  8001c0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c9:	89 f7                	mov    %esi,%edi
  8001cb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001cd:	85 c0                	test   %eax,%eax
  8001cf:	7e 28                	jle    8001f9 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001d5:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001dc:	00 
  8001dd:	c7 44 24 08 4a 10 80 	movl   $0x80104a,0x8(%esp)
  8001e4:	00 
  8001e5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001ec:	00 
  8001ed:	c7 04 24 67 10 80 00 	movl   $0x801067,(%esp)
  8001f4:	e8 1f 02 00 00       	call   800418 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001f9:	83 c4 2c             	add    $0x2c,%esp
  8001fc:	5b                   	pop    %ebx
  8001fd:	5e                   	pop    %esi
  8001fe:	5f                   	pop    %edi
  8001ff:	5d                   	pop    %ebp
  800200:	c3                   	ret    

00800201 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800201:	55                   	push   %ebp
  800202:	89 e5                	mov    %esp,%ebp
  800204:	57                   	push   %edi
  800205:	56                   	push   %esi
  800206:	53                   	push   %ebx
  800207:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80020a:	b8 05 00 00 00       	mov    $0x5,%eax
  80020f:	8b 75 18             	mov    0x18(%ebp),%esi
  800212:	8b 7d 14             	mov    0x14(%ebp),%edi
  800215:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800218:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80021b:	8b 55 08             	mov    0x8(%ebp),%edx
  80021e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800220:	85 c0                	test   %eax,%eax
  800222:	7e 28                	jle    80024c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800224:	89 44 24 10          	mov    %eax,0x10(%esp)
  800228:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80022f:	00 
  800230:	c7 44 24 08 4a 10 80 	movl   $0x80104a,0x8(%esp)
  800237:	00 
  800238:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80023f:	00 
  800240:	c7 04 24 67 10 80 00 	movl   $0x801067,(%esp)
  800247:	e8 cc 01 00 00       	call   800418 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80024c:	83 c4 2c             	add    $0x2c,%esp
  80024f:	5b                   	pop    %ebx
  800250:	5e                   	pop    %esi
  800251:	5f                   	pop    %edi
  800252:	5d                   	pop    %ebp
  800253:	c3                   	ret    

00800254 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800254:	55                   	push   %ebp
  800255:	89 e5                	mov    %esp,%ebp
  800257:	57                   	push   %edi
  800258:	56                   	push   %esi
  800259:	53                   	push   %ebx
  80025a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80025d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800262:	b8 06 00 00 00       	mov    $0x6,%eax
  800267:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80026a:	8b 55 08             	mov    0x8(%ebp),%edx
  80026d:	89 df                	mov    %ebx,%edi
  80026f:	89 de                	mov    %ebx,%esi
  800271:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800273:	85 c0                	test   %eax,%eax
  800275:	7e 28                	jle    80029f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800277:	89 44 24 10          	mov    %eax,0x10(%esp)
  80027b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800282:	00 
  800283:	c7 44 24 08 4a 10 80 	movl   $0x80104a,0x8(%esp)
  80028a:	00 
  80028b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800292:	00 
  800293:	c7 04 24 67 10 80 00 	movl   $0x801067,(%esp)
  80029a:	e8 79 01 00 00       	call   800418 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80029f:	83 c4 2c             	add    $0x2c,%esp
  8002a2:	5b                   	pop    %ebx
  8002a3:	5e                   	pop    %esi
  8002a4:	5f                   	pop    %edi
  8002a5:	5d                   	pop    %ebp
  8002a6:	c3                   	ret    

008002a7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002a7:	55                   	push   %ebp
  8002a8:	89 e5                	mov    %esp,%ebp
  8002aa:	57                   	push   %edi
  8002ab:	56                   	push   %esi
  8002ac:	53                   	push   %ebx
  8002ad:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b5:	b8 08 00 00 00       	mov    $0x8,%eax
  8002ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c0:	89 df                	mov    %ebx,%edi
  8002c2:	89 de                	mov    %ebx,%esi
  8002c4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002c6:	85 c0                	test   %eax,%eax
  8002c8:	7e 28                	jle    8002f2 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ca:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002ce:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002d5:	00 
  8002d6:	c7 44 24 08 4a 10 80 	movl   $0x80104a,0x8(%esp)
  8002dd:	00 
  8002de:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002e5:	00 
  8002e6:	c7 04 24 67 10 80 00 	movl   $0x801067,(%esp)
  8002ed:	e8 26 01 00 00       	call   800418 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002f2:	83 c4 2c             	add    $0x2c,%esp
  8002f5:	5b                   	pop    %ebx
  8002f6:	5e                   	pop    %esi
  8002f7:	5f                   	pop    %edi
  8002f8:	5d                   	pop    %ebp
  8002f9:	c3                   	ret    

008002fa <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002fa:	55                   	push   %ebp
  8002fb:	89 e5                	mov    %esp,%ebp
  8002fd:	57                   	push   %edi
  8002fe:	56                   	push   %esi
  8002ff:	53                   	push   %ebx
  800300:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800303:	bb 00 00 00 00       	mov    $0x0,%ebx
  800308:	b8 09 00 00 00       	mov    $0x9,%eax
  80030d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800310:	8b 55 08             	mov    0x8(%ebp),%edx
  800313:	89 df                	mov    %ebx,%edi
  800315:	89 de                	mov    %ebx,%esi
  800317:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800319:	85 c0                	test   %eax,%eax
  80031b:	7e 28                	jle    800345 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80031d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800321:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800328:	00 
  800329:	c7 44 24 08 4a 10 80 	movl   $0x80104a,0x8(%esp)
  800330:	00 
  800331:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800338:	00 
  800339:	c7 04 24 67 10 80 00 	movl   $0x801067,(%esp)
  800340:	e8 d3 00 00 00       	call   800418 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800345:	83 c4 2c             	add    $0x2c,%esp
  800348:	5b                   	pop    %ebx
  800349:	5e                   	pop    %esi
  80034a:	5f                   	pop    %edi
  80034b:	5d                   	pop    %ebp
  80034c:	c3                   	ret    

0080034d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80034d:	55                   	push   %ebp
  80034e:	89 e5                	mov    %esp,%ebp
  800350:	57                   	push   %edi
  800351:	56                   	push   %esi
  800352:	53                   	push   %ebx
  800353:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800356:	bb 00 00 00 00       	mov    $0x0,%ebx
  80035b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800360:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800363:	8b 55 08             	mov    0x8(%ebp),%edx
  800366:	89 df                	mov    %ebx,%edi
  800368:	89 de                	mov    %ebx,%esi
  80036a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80036c:	85 c0                	test   %eax,%eax
  80036e:	7e 28                	jle    800398 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800370:	89 44 24 10          	mov    %eax,0x10(%esp)
  800374:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80037b:	00 
  80037c:	c7 44 24 08 4a 10 80 	movl   $0x80104a,0x8(%esp)
  800383:	00 
  800384:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80038b:	00 
  80038c:	c7 04 24 67 10 80 00 	movl   $0x801067,(%esp)
  800393:	e8 80 00 00 00       	call   800418 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800398:	83 c4 2c             	add    $0x2c,%esp
  80039b:	5b                   	pop    %ebx
  80039c:	5e                   	pop    %esi
  80039d:	5f                   	pop    %edi
  80039e:	5d                   	pop    %ebp
  80039f:	c3                   	ret    

008003a0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
  8003a3:	57                   	push   %edi
  8003a4:	56                   	push   %esi
  8003a5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003a6:	be 00 00 00 00       	mov    $0x0,%esi
  8003ab:	b8 0c 00 00 00       	mov    $0xc,%eax
  8003b0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8003b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8003bc:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003be:	5b                   	pop    %ebx
  8003bf:	5e                   	pop    %esi
  8003c0:	5f                   	pop    %edi
  8003c1:	5d                   	pop    %ebp
  8003c2:	c3                   	ret    

008003c3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003c3:	55                   	push   %ebp
  8003c4:	89 e5                	mov    %esp,%ebp
  8003c6:	57                   	push   %edi
  8003c7:	56                   	push   %esi
  8003c8:	53                   	push   %ebx
  8003c9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003cc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003d1:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003d6:	8b 55 08             	mov    0x8(%ebp),%edx
  8003d9:	89 cb                	mov    %ecx,%ebx
  8003db:	89 cf                	mov    %ecx,%edi
  8003dd:	89 ce                	mov    %ecx,%esi
  8003df:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003e1:	85 c0                	test   %eax,%eax
  8003e3:	7e 28                	jle    80040d <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003e5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003e9:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003f0:	00 
  8003f1:	c7 44 24 08 4a 10 80 	movl   $0x80104a,0x8(%esp)
  8003f8:	00 
  8003f9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800400:	00 
  800401:	c7 04 24 67 10 80 00 	movl   $0x801067,(%esp)
  800408:	e8 0b 00 00 00       	call   800418 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80040d:	83 c4 2c             	add    $0x2c,%esp
  800410:	5b                   	pop    %ebx
  800411:	5e                   	pop    %esi
  800412:	5f                   	pop    %edi
  800413:	5d                   	pop    %ebp
  800414:	c3                   	ret    
  800415:	00 00                	add    %al,(%eax)
	...

00800418 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800418:	55                   	push   %ebp
  800419:	89 e5                	mov    %esp,%ebp
  80041b:	56                   	push   %esi
  80041c:	53                   	push   %ebx
  80041d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800420:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800423:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800429:	e8 41 fd ff ff       	call   80016f <sys_getenvid>
  80042e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800431:	89 54 24 10          	mov    %edx,0x10(%esp)
  800435:	8b 55 08             	mov    0x8(%ebp),%edx
  800438:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80043c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800440:	89 44 24 04          	mov    %eax,0x4(%esp)
  800444:	c7 04 24 78 10 80 00 	movl   $0x801078,(%esp)
  80044b:	e8 c0 00 00 00       	call   800510 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800450:	89 74 24 04          	mov    %esi,0x4(%esp)
  800454:	8b 45 10             	mov    0x10(%ebp),%eax
  800457:	89 04 24             	mov    %eax,(%esp)
  80045a:	e8 50 00 00 00       	call   8004af <vcprintf>
	cprintf("\n");
  80045f:	c7 04 24 9b 10 80 00 	movl   $0x80109b,(%esp)
  800466:	e8 a5 00 00 00       	call   800510 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80046b:	cc                   	int3   
  80046c:	eb fd                	jmp    80046b <_panic+0x53>
	...

00800470 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800470:	55                   	push   %ebp
  800471:	89 e5                	mov    %esp,%ebp
  800473:	53                   	push   %ebx
  800474:	83 ec 14             	sub    $0x14,%esp
  800477:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80047a:	8b 03                	mov    (%ebx),%eax
  80047c:	8b 55 08             	mov    0x8(%ebp),%edx
  80047f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800483:	40                   	inc    %eax
  800484:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800486:	3d ff 00 00 00       	cmp    $0xff,%eax
  80048b:	75 19                	jne    8004a6 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80048d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800494:	00 
  800495:	8d 43 08             	lea    0x8(%ebx),%eax
  800498:	89 04 24             	mov    %eax,(%esp)
  80049b:	e8 40 fc ff ff       	call   8000e0 <sys_cputs>
		b->idx = 0;
  8004a0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8004a6:	ff 43 04             	incl   0x4(%ebx)
}
  8004a9:	83 c4 14             	add    $0x14,%esp
  8004ac:	5b                   	pop    %ebx
  8004ad:	5d                   	pop    %ebp
  8004ae:	c3                   	ret    

008004af <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004af:	55                   	push   %ebp
  8004b0:	89 e5                	mov    %esp,%ebp
  8004b2:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8004b8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004bf:	00 00 00 
	b.cnt = 0;
  8004c2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004c9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8004d6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004da:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004e4:	c7 04 24 70 04 80 00 	movl   $0x800470,(%esp)
  8004eb:	e8 82 01 00 00       	call   800672 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004f0:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8004f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004fa:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800500:	89 04 24             	mov    %eax,(%esp)
  800503:	e8 d8 fb ff ff       	call   8000e0 <sys_cputs>

	return b.cnt;
}
  800508:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80050e:	c9                   	leave  
  80050f:	c3                   	ret    

00800510 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800510:	55                   	push   %ebp
  800511:	89 e5                	mov    %esp,%ebp
  800513:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800516:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800519:	89 44 24 04          	mov    %eax,0x4(%esp)
  80051d:	8b 45 08             	mov    0x8(%ebp),%eax
  800520:	89 04 24             	mov    %eax,(%esp)
  800523:	e8 87 ff ff ff       	call   8004af <vcprintf>
	va_end(ap);

	return cnt;
}
  800528:	c9                   	leave  
  800529:	c3                   	ret    
	...

0080052c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80052c:	55                   	push   %ebp
  80052d:	89 e5                	mov    %esp,%ebp
  80052f:	57                   	push   %edi
  800530:	56                   	push   %esi
  800531:	53                   	push   %ebx
  800532:	83 ec 3c             	sub    $0x3c,%esp
  800535:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800538:	89 d7                	mov    %edx,%edi
  80053a:	8b 45 08             	mov    0x8(%ebp),%eax
  80053d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800540:	8b 45 0c             	mov    0xc(%ebp),%eax
  800543:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800546:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800549:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80054c:	85 c0                	test   %eax,%eax
  80054e:	75 08                	jne    800558 <printnum+0x2c>
  800550:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800553:	39 45 10             	cmp    %eax,0x10(%ebp)
  800556:	77 57                	ja     8005af <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800558:	89 74 24 10          	mov    %esi,0x10(%esp)
  80055c:	4b                   	dec    %ebx
  80055d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800561:	8b 45 10             	mov    0x10(%ebp),%eax
  800564:	89 44 24 08          	mov    %eax,0x8(%esp)
  800568:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80056c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800570:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800577:	00 
  800578:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80057b:	89 04 24             	mov    %eax,(%esp)
  80057e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800581:	89 44 24 04          	mov    %eax,0x4(%esp)
  800585:	e8 56 08 00 00       	call   800de0 <__udivdi3>
  80058a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80058e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800592:	89 04 24             	mov    %eax,(%esp)
  800595:	89 54 24 04          	mov    %edx,0x4(%esp)
  800599:	89 fa                	mov    %edi,%edx
  80059b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80059e:	e8 89 ff ff ff       	call   80052c <printnum>
  8005a3:	eb 0f                	jmp    8005b4 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8005a5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005a9:	89 34 24             	mov    %esi,(%esp)
  8005ac:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005af:	4b                   	dec    %ebx
  8005b0:	85 db                	test   %ebx,%ebx
  8005b2:	7f f1                	jg     8005a5 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8005b4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005b8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8005bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8005bf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005c3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005ca:	00 
  8005cb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005ce:	89 04 24             	mov    %eax,(%esp)
  8005d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005d8:	e8 23 09 00 00       	call   800f00 <__umoddi3>
  8005dd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005e1:	0f be 80 9d 10 80 00 	movsbl 0x80109d(%eax),%eax
  8005e8:	89 04 24             	mov    %eax,(%esp)
  8005eb:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8005ee:	83 c4 3c             	add    $0x3c,%esp
  8005f1:	5b                   	pop    %ebx
  8005f2:	5e                   	pop    %esi
  8005f3:	5f                   	pop    %edi
  8005f4:	5d                   	pop    %ebp
  8005f5:	c3                   	ret    

008005f6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8005f6:	55                   	push   %ebp
  8005f7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8005f9:	83 fa 01             	cmp    $0x1,%edx
  8005fc:	7e 0e                	jle    80060c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8005fe:	8b 10                	mov    (%eax),%edx
  800600:	8d 4a 08             	lea    0x8(%edx),%ecx
  800603:	89 08                	mov    %ecx,(%eax)
  800605:	8b 02                	mov    (%edx),%eax
  800607:	8b 52 04             	mov    0x4(%edx),%edx
  80060a:	eb 22                	jmp    80062e <getuint+0x38>
	else if (lflag)
  80060c:	85 d2                	test   %edx,%edx
  80060e:	74 10                	je     800620 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800610:	8b 10                	mov    (%eax),%edx
  800612:	8d 4a 04             	lea    0x4(%edx),%ecx
  800615:	89 08                	mov    %ecx,(%eax)
  800617:	8b 02                	mov    (%edx),%eax
  800619:	ba 00 00 00 00       	mov    $0x0,%edx
  80061e:	eb 0e                	jmp    80062e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800620:	8b 10                	mov    (%eax),%edx
  800622:	8d 4a 04             	lea    0x4(%edx),%ecx
  800625:	89 08                	mov    %ecx,(%eax)
  800627:	8b 02                	mov    (%edx),%eax
  800629:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80062e:	5d                   	pop    %ebp
  80062f:	c3                   	ret    

00800630 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800630:	55                   	push   %ebp
  800631:	89 e5                	mov    %esp,%ebp
  800633:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800636:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800639:	8b 10                	mov    (%eax),%edx
  80063b:	3b 50 04             	cmp    0x4(%eax),%edx
  80063e:	73 08                	jae    800648 <sprintputch+0x18>
		*b->buf++ = ch;
  800640:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800643:	88 0a                	mov    %cl,(%edx)
  800645:	42                   	inc    %edx
  800646:	89 10                	mov    %edx,(%eax)
}
  800648:	5d                   	pop    %ebp
  800649:	c3                   	ret    

0080064a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80064a:	55                   	push   %ebp
  80064b:	89 e5                	mov    %esp,%ebp
  80064d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800650:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800653:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800657:	8b 45 10             	mov    0x10(%ebp),%eax
  80065a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80065e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800661:	89 44 24 04          	mov    %eax,0x4(%esp)
  800665:	8b 45 08             	mov    0x8(%ebp),%eax
  800668:	89 04 24             	mov    %eax,(%esp)
  80066b:	e8 02 00 00 00       	call   800672 <vprintfmt>
	va_end(ap);
}
  800670:	c9                   	leave  
  800671:	c3                   	ret    

00800672 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800672:	55                   	push   %ebp
  800673:	89 e5                	mov    %esp,%ebp
  800675:	57                   	push   %edi
  800676:	56                   	push   %esi
  800677:	53                   	push   %ebx
  800678:	83 ec 4c             	sub    $0x4c,%esp
  80067b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80067e:	8b 75 10             	mov    0x10(%ebp),%esi
  800681:	eb 12                	jmp    800695 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800683:	85 c0                	test   %eax,%eax
  800685:	0f 84 6b 03 00 00    	je     8009f6 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80068b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80068f:	89 04 24             	mov    %eax,(%esp)
  800692:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800695:	0f b6 06             	movzbl (%esi),%eax
  800698:	46                   	inc    %esi
  800699:	83 f8 25             	cmp    $0x25,%eax
  80069c:	75 e5                	jne    800683 <vprintfmt+0x11>
  80069e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8006a2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8006a9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8006ae:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8006b5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ba:	eb 26                	jmp    8006e2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006bc:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8006bf:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8006c3:	eb 1d                	jmp    8006e2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8006c8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8006cc:	eb 14                	jmp    8006e2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ce:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8006d1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8006d8:	eb 08                	jmp    8006e2 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8006da:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8006dd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e2:	0f b6 06             	movzbl (%esi),%eax
  8006e5:	8d 56 01             	lea    0x1(%esi),%edx
  8006e8:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8006eb:	8a 16                	mov    (%esi),%dl
  8006ed:	83 ea 23             	sub    $0x23,%edx
  8006f0:	80 fa 55             	cmp    $0x55,%dl
  8006f3:	0f 87 e1 02 00 00    	ja     8009da <vprintfmt+0x368>
  8006f9:	0f b6 d2             	movzbl %dl,%edx
  8006fc:	ff 24 95 e0 11 80 00 	jmp    *0x8011e0(,%edx,4)
  800703:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800706:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80070b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80070e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800712:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800715:	8d 50 d0             	lea    -0x30(%eax),%edx
  800718:	83 fa 09             	cmp    $0x9,%edx
  80071b:	77 2a                	ja     800747 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80071d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80071e:	eb eb                	jmp    80070b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800720:	8b 45 14             	mov    0x14(%ebp),%eax
  800723:	8d 50 04             	lea    0x4(%eax),%edx
  800726:	89 55 14             	mov    %edx,0x14(%ebp)
  800729:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80072e:	eb 17                	jmp    800747 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800730:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800734:	78 98                	js     8006ce <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800736:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800739:	eb a7                	jmp    8006e2 <vprintfmt+0x70>
  80073b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80073e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800745:	eb 9b                	jmp    8006e2 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800747:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80074b:	79 95                	jns    8006e2 <vprintfmt+0x70>
  80074d:	eb 8b                	jmp    8006da <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80074f:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800750:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800753:	eb 8d                	jmp    8006e2 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800755:	8b 45 14             	mov    0x14(%ebp),%eax
  800758:	8d 50 04             	lea    0x4(%eax),%edx
  80075b:	89 55 14             	mov    %edx,0x14(%ebp)
  80075e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800762:	8b 00                	mov    (%eax),%eax
  800764:	89 04 24             	mov    %eax,(%esp)
  800767:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80076a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80076d:	e9 23 ff ff ff       	jmp    800695 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800772:	8b 45 14             	mov    0x14(%ebp),%eax
  800775:	8d 50 04             	lea    0x4(%eax),%edx
  800778:	89 55 14             	mov    %edx,0x14(%ebp)
  80077b:	8b 00                	mov    (%eax),%eax
  80077d:	85 c0                	test   %eax,%eax
  80077f:	79 02                	jns    800783 <vprintfmt+0x111>
  800781:	f7 d8                	neg    %eax
  800783:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800785:	83 f8 0f             	cmp    $0xf,%eax
  800788:	7f 0b                	jg     800795 <vprintfmt+0x123>
  80078a:	8b 04 85 40 13 80 00 	mov    0x801340(,%eax,4),%eax
  800791:	85 c0                	test   %eax,%eax
  800793:	75 23                	jne    8007b8 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800795:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800799:	c7 44 24 08 b5 10 80 	movl   $0x8010b5,0x8(%esp)
  8007a0:	00 
  8007a1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a8:	89 04 24             	mov    %eax,(%esp)
  8007ab:	e8 9a fe ff ff       	call   80064a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b0:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8007b3:	e9 dd fe ff ff       	jmp    800695 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8007b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007bc:	c7 44 24 08 be 10 80 	movl   $0x8010be,0x8(%esp)
  8007c3:	00 
  8007c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8007cb:	89 14 24             	mov    %edx,(%esp)
  8007ce:	e8 77 fe ff ff       	call   80064a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007d6:	e9 ba fe ff ff       	jmp    800695 <vprintfmt+0x23>
  8007db:	89 f9                	mov    %edi,%ecx
  8007dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007e0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8007e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e6:	8d 50 04             	lea    0x4(%eax),%edx
  8007e9:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ec:	8b 30                	mov    (%eax),%esi
  8007ee:	85 f6                	test   %esi,%esi
  8007f0:	75 05                	jne    8007f7 <vprintfmt+0x185>
				p = "(null)";
  8007f2:	be ae 10 80 00       	mov    $0x8010ae,%esi
			if (width > 0 && padc != '-')
  8007f7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8007fb:	0f 8e 84 00 00 00    	jle    800885 <vprintfmt+0x213>
  800801:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800805:	74 7e                	je     800885 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800807:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80080b:	89 34 24             	mov    %esi,(%esp)
  80080e:	e8 8b 02 00 00       	call   800a9e <strnlen>
  800813:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800816:	29 c2                	sub    %eax,%edx
  800818:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80081b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80081f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800822:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800825:	89 de                	mov    %ebx,%esi
  800827:	89 d3                	mov    %edx,%ebx
  800829:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80082b:	eb 0b                	jmp    800838 <vprintfmt+0x1c6>
					putch(padc, putdat);
  80082d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800831:	89 3c 24             	mov    %edi,(%esp)
  800834:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800837:	4b                   	dec    %ebx
  800838:	85 db                	test   %ebx,%ebx
  80083a:	7f f1                	jg     80082d <vprintfmt+0x1bb>
  80083c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80083f:	89 f3                	mov    %esi,%ebx
  800841:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800844:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800847:	85 c0                	test   %eax,%eax
  800849:	79 05                	jns    800850 <vprintfmt+0x1de>
  80084b:	b8 00 00 00 00       	mov    $0x0,%eax
  800850:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800853:	29 c2                	sub    %eax,%edx
  800855:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800858:	eb 2b                	jmp    800885 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80085a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80085e:	74 18                	je     800878 <vprintfmt+0x206>
  800860:	8d 50 e0             	lea    -0x20(%eax),%edx
  800863:	83 fa 5e             	cmp    $0x5e,%edx
  800866:	76 10                	jbe    800878 <vprintfmt+0x206>
					putch('?', putdat);
  800868:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80086c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800873:	ff 55 08             	call   *0x8(%ebp)
  800876:	eb 0a                	jmp    800882 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800878:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80087c:	89 04 24             	mov    %eax,(%esp)
  80087f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800882:	ff 4d e4             	decl   -0x1c(%ebp)
  800885:	0f be 06             	movsbl (%esi),%eax
  800888:	46                   	inc    %esi
  800889:	85 c0                	test   %eax,%eax
  80088b:	74 21                	je     8008ae <vprintfmt+0x23c>
  80088d:	85 ff                	test   %edi,%edi
  80088f:	78 c9                	js     80085a <vprintfmt+0x1e8>
  800891:	4f                   	dec    %edi
  800892:	79 c6                	jns    80085a <vprintfmt+0x1e8>
  800894:	8b 7d 08             	mov    0x8(%ebp),%edi
  800897:	89 de                	mov    %ebx,%esi
  800899:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80089c:	eb 18                	jmp    8008b6 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80089e:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008a2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8008a9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8008ab:	4b                   	dec    %ebx
  8008ac:	eb 08                	jmp    8008b6 <vprintfmt+0x244>
  8008ae:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008b1:	89 de                	mov    %ebx,%esi
  8008b3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8008b6:	85 db                	test   %ebx,%ebx
  8008b8:	7f e4                	jg     80089e <vprintfmt+0x22c>
  8008ba:	89 7d 08             	mov    %edi,0x8(%ebp)
  8008bd:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008bf:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008c2:	e9 ce fd ff ff       	jmp    800695 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008c7:	83 f9 01             	cmp    $0x1,%ecx
  8008ca:	7e 10                	jle    8008dc <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8008cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8008cf:	8d 50 08             	lea    0x8(%eax),%edx
  8008d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8008d5:	8b 30                	mov    (%eax),%esi
  8008d7:	8b 78 04             	mov    0x4(%eax),%edi
  8008da:	eb 26                	jmp    800902 <vprintfmt+0x290>
	else if (lflag)
  8008dc:	85 c9                	test   %ecx,%ecx
  8008de:	74 12                	je     8008f2 <vprintfmt+0x280>
		return va_arg(*ap, long);
  8008e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e3:	8d 50 04             	lea    0x4(%eax),%edx
  8008e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8008e9:	8b 30                	mov    (%eax),%esi
  8008eb:	89 f7                	mov    %esi,%edi
  8008ed:	c1 ff 1f             	sar    $0x1f,%edi
  8008f0:	eb 10                	jmp    800902 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8008f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f5:	8d 50 04             	lea    0x4(%eax),%edx
  8008f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8008fb:	8b 30                	mov    (%eax),%esi
  8008fd:	89 f7                	mov    %esi,%edi
  8008ff:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800902:	85 ff                	test   %edi,%edi
  800904:	78 0a                	js     800910 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800906:	b8 0a 00 00 00       	mov    $0xa,%eax
  80090b:	e9 8c 00 00 00       	jmp    80099c <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800910:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800914:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80091b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80091e:	f7 de                	neg    %esi
  800920:	83 d7 00             	adc    $0x0,%edi
  800923:	f7 df                	neg    %edi
			}
			base = 10;
  800925:	b8 0a 00 00 00       	mov    $0xa,%eax
  80092a:	eb 70                	jmp    80099c <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80092c:	89 ca                	mov    %ecx,%edx
  80092e:	8d 45 14             	lea    0x14(%ebp),%eax
  800931:	e8 c0 fc ff ff       	call   8005f6 <getuint>
  800936:	89 c6                	mov    %eax,%esi
  800938:	89 d7                	mov    %edx,%edi
			base = 10;
  80093a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80093f:	eb 5b                	jmp    80099c <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  800941:	89 ca                	mov    %ecx,%edx
  800943:	8d 45 14             	lea    0x14(%ebp),%eax
  800946:	e8 ab fc ff ff       	call   8005f6 <getuint>
  80094b:	89 c6                	mov    %eax,%esi
  80094d:	89 d7                	mov    %edx,%edi
			base = 8;
  80094f:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800954:	eb 46                	jmp    80099c <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  800956:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80095a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800961:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800964:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800968:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80096f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800972:	8b 45 14             	mov    0x14(%ebp),%eax
  800975:	8d 50 04             	lea    0x4(%eax),%edx
  800978:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80097b:	8b 30                	mov    (%eax),%esi
  80097d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800982:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800987:	eb 13                	jmp    80099c <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800989:	89 ca                	mov    %ecx,%edx
  80098b:	8d 45 14             	lea    0x14(%ebp),%eax
  80098e:	e8 63 fc ff ff       	call   8005f6 <getuint>
  800993:	89 c6                	mov    %eax,%esi
  800995:	89 d7                	mov    %edx,%edi
			base = 16;
  800997:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80099c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8009a0:	89 54 24 10          	mov    %edx,0x10(%esp)
  8009a4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8009a7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8009ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009af:	89 34 24             	mov    %esi,(%esp)
  8009b2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009b6:	89 da                	mov    %ebx,%edx
  8009b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bb:	e8 6c fb ff ff       	call   80052c <printnum>
			break;
  8009c0:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8009c3:	e9 cd fc ff ff       	jmp    800695 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8009c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009cc:	89 04 24             	mov    %eax,(%esp)
  8009cf:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009d2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8009d5:	e9 bb fc ff ff       	jmp    800695 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8009da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009de:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8009e5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009e8:	eb 01                	jmp    8009eb <vprintfmt+0x379>
  8009ea:	4e                   	dec    %esi
  8009eb:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8009ef:	75 f9                	jne    8009ea <vprintfmt+0x378>
  8009f1:	e9 9f fc ff ff       	jmp    800695 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8009f6:	83 c4 4c             	add    $0x4c,%esp
  8009f9:	5b                   	pop    %ebx
  8009fa:	5e                   	pop    %esi
  8009fb:	5f                   	pop    %edi
  8009fc:	5d                   	pop    %ebp
  8009fd:	c3                   	ret    

008009fe <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009fe:	55                   	push   %ebp
  8009ff:	89 e5                	mov    %esp,%ebp
  800a01:	83 ec 28             	sub    $0x28,%esp
  800a04:	8b 45 08             	mov    0x8(%ebp),%eax
  800a07:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a0a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a0d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a11:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a14:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a1b:	85 c0                	test   %eax,%eax
  800a1d:	74 30                	je     800a4f <vsnprintf+0x51>
  800a1f:	85 d2                	test   %edx,%edx
  800a21:	7e 33                	jle    800a56 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a23:	8b 45 14             	mov    0x14(%ebp),%eax
  800a26:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a2a:	8b 45 10             	mov    0x10(%ebp),%eax
  800a2d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a31:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a34:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a38:	c7 04 24 30 06 80 00 	movl   $0x800630,(%esp)
  800a3f:	e8 2e fc ff ff       	call   800672 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a44:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a47:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a4d:	eb 0c                	jmp    800a5b <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a4f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a54:	eb 05                	jmp    800a5b <vsnprintf+0x5d>
  800a56:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a5b:	c9                   	leave  
  800a5c:	c3                   	ret    

00800a5d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a5d:	55                   	push   %ebp
  800a5e:	89 e5                	mov    %esp,%ebp
  800a60:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a63:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a66:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a6a:	8b 45 10             	mov    0x10(%ebp),%eax
  800a6d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a71:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a74:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a78:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7b:	89 04 24             	mov    %eax,(%esp)
  800a7e:	e8 7b ff ff ff       	call   8009fe <vsnprintf>
	va_end(ap);

	return rc;
}
  800a83:	c9                   	leave  
  800a84:	c3                   	ret    
  800a85:	00 00                	add    %al,(%eax)
	...

00800a88 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a88:	55                   	push   %ebp
  800a89:	89 e5                	mov    %esp,%ebp
  800a8b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a8e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a93:	eb 01                	jmp    800a96 <strlen+0xe>
		n++;
  800a95:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a96:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a9a:	75 f9                	jne    800a95 <strlen+0xd>
		n++;
	return n;
}
  800a9c:	5d                   	pop    %ebp
  800a9d:	c3                   	ret    

00800a9e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a9e:	55                   	push   %ebp
  800a9f:	89 e5                	mov    %esp,%ebp
  800aa1:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800aa4:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800aa7:	b8 00 00 00 00       	mov    $0x0,%eax
  800aac:	eb 01                	jmp    800aaf <strnlen+0x11>
		n++;
  800aae:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800aaf:	39 d0                	cmp    %edx,%eax
  800ab1:	74 06                	je     800ab9 <strnlen+0x1b>
  800ab3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800ab7:	75 f5                	jne    800aae <strnlen+0x10>
		n++;
	return n;
}
  800ab9:	5d                   	pop    %ebp
  800aba:	c3                   	ret    

00800abb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
  800abe:	53                   	push   %ebx
  800abf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ac5:	ba 00 00 00 00       	mov    $0x0,%edx
  800aca:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800acd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800ad0:	42                   	inc    %edx
  800ad1:	84 c9                	test   %cl,%cl
  800ad3:	75 f5                	jne    800aca <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800ad5:	5b                   	pop    %ebx
  800ad6:	5d                   	pop    %ebp
  800ad7:	c3                   	ret    

00800ad8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	53                   	push   %ebx
  800adc:	83 ec 08             	sub    $0x8,%esp
  800adf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ae2:	89 1c 24             	mov    %ebx,(%esp)
  800ae5:	e8 9e ff ff ff       	call   800a88 <strlen>
	strcpy(dst + len, src);
  800aea:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aed:	89 54 24 04          	mov    %edx,0x4(%esp)
  800af1:	01 d8                	add    %ebx,%eax
  800af3:	89 04 24             	mov    %eax,(%esp)
  800af6:	e8 c0 ff ff ff       	call   800abb <strcpy>
	return dst;
}
  800afb:	89 d8                	mov    %ebx,%eax
  800afd:	83 c4 08             	add    $0x8,%esp
  800b00:	5b                   	pop    %ebx
  800b01:	5d                   	pop    %ebp
  800b02:	c3                   	ret    

00800b03 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b03:	55                   	push   %ebp
  800b04:	89 e5                	mov    %esp,%ebp
  800b06:	56                   	push   %esi
  800b07:	53                   	push   %ebx
  800b08:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b0e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b11:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b16:	eb 0c                	jmp    800b24 <strncpy+0x21>
		*dst++ = *src;
  800b18:	8a 1a                	mov    (%edx),%bl
  800b1a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b1d:	80 3a 01             	cmpb   $0x1,(%edx)
  800b20:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b23:	41                   	inc    %ecx
  800b24:	39 f1                	cmp    %esi,%ecx
  800b26:	75 f0                	jne    800b18 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b28:	5b                   	pop    %ebx
  800b29:	5e                   	pop    %esi
  800b2a:	5d                   	pop    %ebp
  800b2b:	c3                   	ret    

00800b2c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b2c:	55                   	push   %ebp
  800b2d:	89 e5                	mov    %esp,%ebp
  800b2f:	56                   	push   %esi
  800b30:	53                   	push   %ebx
  800b31:	8b 75 08             	mov    0x8(%ebp),%esi
  800b34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b37:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b3a:	85 d2                	test   %edx,%edx
  800b3c:	75 0a                	jne    800b48 <strlcpy+0x1c>
  800b3e:	89 f0                	mov    %esi,%eax
  800b40:	eb 1a                	jmp    800b5c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b42:	88 18                	mov    %bl,(%eax)
  800b44:	40                   	inc    %eax
  800b45:	41                   	inc    %ecx
  800b46:	eb 02                	jmp    800b4a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b48:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800b4a:	4a                   	dec    %edx
  800b4b:	74 0a                	je     800b57 <strlcpy+0x2b>
  800b4d:	8a 19                	mov    (%ecx),%bl
  800b4f:	84 db                	test   %bl,%bl
  800b51:	75 ef                	jne    800b42 <strlcpy+0x16>
  800b53:	89 c2                	mov    %eax,%edx
  800b55:	eb 02                	jmp    800b59 <strlcpy+0x2d>
  800b57:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800b59:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800b5c:	29 f0                	sub    %esi,%eax
}
  800b5e:	5b                   	pop    %ebx
  800b5f:	5e                   	pop    %esi
  800b60:	5d                   	pop    %ebp
  800b61:	c3                   	ret    

00800b62 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b68:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b6b:	eb 02                	jmp    800b6f <strcmp+0xd>
		p++, q++;
  800b6d:	41                   	inc    %ecx
  800b6e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b6f:	8a 01                	mov    (%ecx),%al
  800b71:	84 c0                	test   %al,%al
  800b73:	74 04                	je     800b79 <strcmp+0x17>
  800b75:	3a 02                	cmp    (%edx),%al
  800b77:	74 f4                	je     800b6d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b79:	0f b6 c0             	movzbl %al,%eax
  800b7c:	0f b6 12             	movzbl (%edx),%edx
  800b7f:	29 d0                	sub    %edx,%eax
}
  800b81:	5d                   	pop    %ebp
  800b82:	c3                   	ret    

00800b83 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b83:	55                   	push   %ebp
  800b84:	89 e5                	mov    %esp,%ebp
  800b86:	53                   	push   %ebx
  800b87:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800b90:	eb 03                	jmp    800b95 <strncmp+0x12>
		n--, p++, q++;
  800b92:	4a                   	dec    %edx
  800b93:	40                   	inc    %eax
  800b94:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b95:	85 d2                	test   %edx,%edx
  800b97:	74 14                	je     800bad <strncmp+0x2a>
  800b99:	8a 18                	mov    (%eax),%bl
  800b9b:	84 db                	test   %bl,%bl
  800b9d:	74 04                	je     800ba3 <strncmp+0x20>
  800b9f:	3a 19                	cmp    (%ecx),%bl
  800ba1:	74 ef                	je     800b92 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ba3:	0f b6 00             	movzbl (%eax),%eax
  800ba6:	0f b6 11             	movzbl (%ecx),%edx
  800ba9:	29 d0                	sub    %edx,%eax
  800bab:	eb 05                	jmp    800bb2 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800bad:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800bb2:	5b                   	pop    %ebx
  800bb3:	5d                   	pop    %ebp
  800bb4:	c3                   	ret    

00800bb5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800bb5:	55                   	push   %ebp
  800bb6:	89 e5                	mov    %esp,%ebp
  800bb8:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbb:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800bbe:	eb 05                	jmp    800bc5 <strchr+0x10>
		if (*s == c)
  800bc0:	38 ca                	cmp    %cl,%dl
  800bc2:	74 0c                	je     800bd0 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800bc4:	40                   	inc    %eax
  800bc5:	8a 10                	mov    (%eax),%dl
  800bc7:	84 d2                	test   %dl,%dl
  800bc9:	75 f5                	jne    800bc0 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800bcb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bd0:	5d                   	pop    %ebp
  800bd1:	c3                   	ret    

00800bd2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bd2:	55                   	push   %ebp
  800bd3:	89 e5                	mov    %esp,%ebp
  800bd5:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd8:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800bdb:	eb 05                	jmp    800be2 <strfind+0x10>
		if (*s == c)
  800bdd:	38 ca                	cmp    %cl,%dl
  800bdf:	74 07                	je     800be8 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800be1:	40                   	inc    %eax
  800be2:	8a 10                	mov    (%eax),%dl
  800be4:	84 d2                	test   %dl,%dl
  800be6:	75 f5                	jne    800bdd <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800be8:	5d                   	pop    %ebp
  800be9:	c3                   	ret    

00800bea <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bea:	55                   	push   %ebp
  800beb:	89 e5                	mov    %esp,%ebp
  800bed:	57                   	push   %edi
  800bee:	56                   	push   %esi
  800bef:	53                   	push   %ebx
  800bf0:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bf3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bf6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bf9:	85 c9                	test   %ecx,%ecx
  800bfb:	74 30                	je     800c2d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bfd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c03:	75 25                	jne    800c2a <memset+0x40>
  800c05:	f6 c1 03             	test   $0x3,%cl
  800c08:	75 20                	jne    800c2a <memset+0x40>
		c &= 0xFF;
  800c0a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c0d:	89 d3                	mov    %edx,%ebx
  800c0f:	c1 e3 08             	shl    $0x8,%ebx
  800c12:	89 d6                	mov    %edx,%esi
  800c14:	c1 e6 18             	shl    $0x18,%esi
  800c17:	89 d0                	mov    %edx,%eax
  800c19:	c1 e0 10             	shl    $0x10,%eax
  800c1c:	09 f0                	or     %esi,%eax
  800c1e:	09 d0                	or     %edx,%eax
  800c20:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c22:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800c25:	fc                   	cld    
  800c26:	f3 ab                	rep stos %eax,%es:(%edi)
  800c28:	eb 03                	jmp    800c2d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c2a:	fc                   	cld    
  800c2b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c2d:	89 f8                	mov    %edi,%eax
  800c2f:	5b                   	pop    %ebx
  800c30:	5e                   	pop    %esi
  800c31:	5f                   	pop    %edi
  800c32:	5d                   	pop    %ebp
  800c33:	c3                   	ret    

00800c34 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	57                   	push   %edi
  800c38:	56                   	push   %esi
  800c39:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c3f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c42:	39 c6                	cmp    %eax,%esi
  800c44:	73 34                	jae    800c7a <memmove+0x46>
  800c46:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c49:	39 d0                	cmp    %edx,%eax
  800c4b:	73 2d                	jae    800c7a <memmove+0x46>
		s += n;
		d += n;
  800c4d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c50:	f6 c2 03             	test   $0x3,%dl
  800c53:	75 1b                	jne    800c70 <memmove+0x3c>
  800c55:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c5b:	75 13                	jne    800c70 <memmove+0x3c>
  800c5d:	f6 c1 03             	test   $0x3,%cl
  800c60:	75 0e                	jne    800c70 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c62:	83 ef 04             	sub    $0x4,%edi
  800c65:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c68:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c6b:	fd                   	std    
  800c6c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c6e:	eb 07                	jmp    800c77 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c70:	4f                   	dec    %edi
  800c71:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c74:	fd                   	std    
  800c75:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c77:	fc                   	cld    
  800c78:	eb 20                	jmp    800c9a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c7a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c80:	75 13                	jne    800c95 <memmove+0x61>
  800c82:	a8 03                	test   $0x3,%al
  800c84:	75 0f                	jne    800c95 <memmove+0x61>
  800c86:	f6 c1 03             	test   $0x3,%cl
  800c89:	75 0a                	jne    800c95 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c8b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c8e:	89 c7                	mov    %eax,%edi
  800c90:	fc                   	cld    
  800c91:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c93:	eb 05                	jmp    800c9a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c95:	89 c7                	mov    %eax,%edi
  800c97:	fc                   	cld    
  800c98:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c9a:	5e                   	pop    %esi
  800c9b:	5f                   	pop    %edi
  800c9c:	5d                   	pop    %ebp
  800c9d:	c3                   	ret    

00800c9e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c9e:	55                   	push   %ebp
  800c9f:	89 e5                	mov    %esp,%ebp
  800ca1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ca4:	8b 45 10             	mov    0x10(%ebp),%eax
  800ca7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cab:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cae:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cb2:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb5:	89 04 24             	mov    %eax,(%esp)
  800cb8:	e8 77 ff ff ff       	call   800c34 <memmove>
}
  800cbd:	c9                   	leave  
  800cbe:	c3                   	ret    

00800cbf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cbf:	55                   	push   %ebp
  800cc0:	89 e5                	mov    %esp,%ebp
  800cc2:	57                   	push   %edi
  800cc3:	56                   	push   %esi
  800cc4:	53                   	push   %ebx
  800cc5:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cc8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ccb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cce:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd3:	eb 16                	jmp    800ceb <memcmp+0x2c>
		if (*s1 != *s2)
  800cd5:	8a 04 17             	mov    (%edi,%edx,1),%al
  800cd8:	42                   	inc    %edx
  800cd9:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800cdd:	38 c8                	cmp    %cl,%al
  800cdf:	74 0a                	je     800ceb <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800ce1:	0f b6 c0             	movzbl %al,%eax
  800ce4:	0f b6 c9             	movzbl %cl,%ecx
  800ce7:	29 c8                	sub    %ecx,%eax
  800ce9:	eb 09                	jmp    800cf4 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ceb:	39 da                	cmp    %ebx,%edx
  800ced:	75 e6                	jne    800cd5 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800cef:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cf4:	5b                   	pop    %ebx
  800cf5:	5e                   	pop    %esi
  800cf6:	5f                   	pop    %edi
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    

00800cf9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cf9:	55                   	push   %ebp
  800cfa:	89 e5                	mov    %esp,%ebp
  800cfc:	8b 45 08             	mov    0x8(%ebp),%eax
  800cff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800d02:	89 c2                	mov    %eax,%edx
  800d04:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d07:	eb 05                	jmp    800d0e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d09:	38 08                	cmp    %cl,(%eax)
  800d0b:	74 05                	je     800d12 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d0d:	40                   	inc    %eax
  800d0e:	39 d0                	cmp    %edx,%eax
  800d10:	72 f7                	jb     800d09 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d12:	5d                   	pop    %ebp
  800d13:	c3                   	ret    

00800d14 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d14:	55                   	push   %ebp
  800d15:	89 e5                	mov    %esp,%ebp
  800d17:	57                   	push   %edi
  800d18:	56                   	push   %esi
  800d19:	53                   	push   %ebx
  800d1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d20:	eb 01                	jmp    800d23 <strtol+0xf>
		s++;
  800d22:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d23:	8a 02                	mov    (%edx),%al
  800d25:	3c 20                	cmp    $0x20,%al
  800d27:	74 f9                	je     800d22 <strtol+0xe>
  800d29:	3c 09                	cmp    $0x9,%al
  800d2b:	74 f5                	je     800d22 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d2d:	3c 2b                	cmp    $0x2b,%al
  800d2f:	75 08                	jne    800d39 <strtol+0x25>
		s++;
  800d31:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d32:	bf 00 00 00 00       	mov    $0x0,%edi
  800d37:	eb 13                	jmp    800d4c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d39:	3c 2d                	cmp    $0x2d,%al
  800d3b:	75 0a                	jne    800d47 <strtol+0x33>
		s++, neg = 1;
  800d3d:	8d 52 01             	lea    0x1(%edx),%edx
  800d40:	bf 01 00 00 00       	mov    $0x1,%edi
  800d45:	eb 05                	jmp    800d4c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d47:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d4c:	85 db                	test   %ebx,%ebx
  800d4e:	74 05                	je     800d55 <strtol+0x41>
  800d50:	83 fb 10             	cmp    $0x10,%ebx
  800d53:	75 28                	jne    800d7d <strtol+0x69>
  800d55:	8a 02                	mov    (%edx),%al
  800d57:	3c 30                	cmp    $0x30,%al
  800d59:	75 10                	jne    800d6b <strtol+0x57>
  800d5b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d5f:	75 0a                	jne    800d6b <strtol+0x57>
		s += 2, base = 16;
  800d61:	83 c2 02             	add    $0x2,%edx
  800d64:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d69:	eb 12                	jmp    800d7d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800d6b:	85 db                	test   %ebx,%ebx
  800d6d:	75 0e                	jne    800d7d <strtol+0x69>
  800d6f:	3c 30                	cmp    $0x30,%al
  800d71:	75 05                	jne    800d78 <strtol+0x64>
		s++, base = 8;
  800d73:	42                   	inc    %edx
  800d74:	b3 08                	mov    $0x8,%bl
  800d76:	eb 05                	jmp    800d7d <strtol+0x69>
	else if (base == 0)
		base = 10;
  800d78:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800d7d:	b8 00 00 00 00       	mov    $0x0,%eax
  800d82:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d84:	8a 0a                	mov    (%edx),%cl
  800d86:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d89:	80 fb 09             	cmp    $0x9,%bl
  800d8c:	77 08                	ja     800d96 <strtol+0x82>
			dig = *s - '0';
  800d8e:	0f be c9             	movsbl %cl,%ecx
  800d91:	83 e9 30             	sub    $0x30,%ecx
  800d94:	eb 1e                	jmp    800db4 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800d96:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d99:	80 fb 19             	cmp    $0x19,%bl
  800d9c:	77 08                	ja     800da6 <strtol+0x92>
			dig = *s - 'a' + 10;
  800d9e:	0f be c9             	movsbl %cl,%ecx
  800da1:	83 e9 57             	sub    $0x57,%ecx
  800da4:	eb 0e                	jmp    800db4 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800da6:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800da9:	80 fb 19             	cmp    $0x19,%bl
  800dac:	77 12                	ja     800dc0 <strtol+0xac>
			dig = *s - 'A' + 10;
  800dae:	0f be c9             	movsbl %cl,%ecx
  800db1:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800db4:	39 f1                	cmp    %esi,%ecx
  800db6:	7d 0c                	jge    800dc4 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800db8:	42                   	inc    %edx
  800db9:	0f af c6             	imul   %esi,%eax
  800dbc:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800dbe:	eb c4                	jmp    800d84 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800dc0:	89 c1                	mov    %eax,%ecx
  800dc2:	eb 02                	jmp    800dc6 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800dc4:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800dc6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dca:	74 05                	je     800dd1 <strtol+0xbd>
		*endptr = (char *) s;
  800dcc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800dcf:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800dd1:	85 ff                	test   %edi,%edi
  800dd3:	74 04                	je     800dd9 <strtol+0xc5>
  800dd5:	89 c8                	mov    %ecx,%eax
  800dd7:	f7 d8                	neg    %eax
}
  800dd9:	5b                   	pop    %ebx
  800dda:	5e                   	pop    %esi
  800ddb:	5f                   	pop    %edi
  800ddc:	5d                   	pop    %ebp
  800ddd:	c3                   	ret    
	...

00800de0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800de0:	55                   	push   %ebp
  800de1:	57                   	push   %edi
  800de2:	56                   	push   %esi
  800de3:	83 ec 10             	sub    $0x10,%esp
  800de6:	8b 74 24 20          	mov    0x20(%esp),%esi
  800dea:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800dee:	89 74 24 04          	mov    %esi,0x4(%esp)
  800df2:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  800df6:	89 cd                	mov    %ecx,%ebp
  800df8:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800dfc:	85 c0                	test   %eax,%eax
  800dfe:	75 2c                	jne    800e2c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800e00:	39 f9                	cmp    %edi,%ecx
  800e02:	77 68                	ja     800e6c <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800e04:	85 c9                	test   %ecx,%ecx
  800e06:	75 0b                	jne    800e13 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800e08:	b8 01 00 00 00       	mov    $0x1,%eax
  800e0d:	31 d2                	xor    %edx,%edx
  800e0f:	f7 f1                	div    %ecx
  800e11:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800e13:	31 d2                	xor    %edx,%edx
  800e15:	89 f8                	mov    %edi,%eax
  800e17:	f7 f1                	div    %ecx
  800e19:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e1b:	89 f0                	mov    %esi,%eax
  800e1d:	f7 f1                	div    %ecx
  800e1f:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e21:	89 f0                	mov    %esi,%eax
  800e23:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e25:	83 c4 10             	add    $0x10,%esp
  800e28:	5e                   	pop    %esi
  800e29:	5f                   	pop    %edi
  800e2a:	5d                   	pop    %ebp
  800e2b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e2c:	39 f8                	cmp    %edi,%eax
  800e2e:	77 2c                	ja     800e5c <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e30:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  800e33:	83 f6 1f             	xor    $0x1f,%esi
  800e36:	75 4c                	jne    800e84 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e38:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e3a:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e3f:	72 0a                	jb     800e4b <__udivdi3+0x6b>
  800e41:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800e45:	0f 87 ad 00 00 00    	ja     800ef8 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e4b:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e50:	89 f0                	mov    %esi,%eax
  800e52:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e54:	83 c4 10             	add    $0x10,%esp
  800e57:	5e                   	pop    %esi
  800e58:	5f                   	pop    %edi
  800e59:	5d                   	pop    %ebp
  800e5a:	c3                   	ret    
  800e5b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e5c:	31 ff                	xor    %edi,%edi
  800e5e:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e60:	89 f0                	mov    %esi,%eax
  800e62:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e64:	83 c4 10             	add    $0x10,%esp
  800e67:	5e                   	pop    %esi
  800e68:	5f                   	pop    %edi
  800e69:	5d                   	pop    %ebp
  800e6a:	c3                   	ret    
  800e6b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e6c:	89 fa                	mov    %edi,%edx
  800e6e:	89 f0                	mov    %esi,%eax
  800e70:	f7 f1                	div    %ecx
  800e72:	89 c6                	mov    %eax,%esi
  800e74:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e76:	89 f0                	mov    %esi,%eax
  800e78:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e7a:	83 c4 10             	add    $0x10,%esp
  800e7d:	5e                   	pop    %esi
  800e7e:	5f                   	pop    %edi
  800e7f:	5d                   	pop    %ebp
  800e80:	c3                   	ret    
  800e81:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e84:	89 f1                	mov    %esi,%ecx
  800e86:	d3 e0                	shl    %cl,%eax
  800e88:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e8c:	b8 20 00 00 00       	mov    $0x20,%eax
  800e91:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800e93:	89 ea                	mov    %ebp,%edx
  800e95:	88 c1                	mov    %al,%cl
  800e97:	d3 ea                	shr    %cl,%edx
  800e99:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800e9d:	09 ca                	or     %ecx,%edx
  800e9f:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  800ea3:	89 f1                	mov    %esi,%ecx
  800ea5:	d3 e5                	shl    %cl,%ebp
  800ea7:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  800eab:	89 fd                	mov    %edi,%ebp
  800ead:	88 c1                	mov    %al,%cl
  800eaf:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  800eb1:	89 fa                	mov    %edi,%edx
  800eb3:	89 f1                	mov    %esi,%ecx
  800eb5:	d3 e2                	shl    %cl,%edx
  800eb7:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ebb:	88 c1                	mov    %al,%cl
  800ebd:	d3 ef                	shr    %cl,%edi
  800ebf:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800ec1:	89 f8                	mov    %edi,%eax
  800ec3:	89 ea                	mov    %ebp,%edx
  800ec5:	f7 74 24 08          	divl   0x8(%esp)
  800ec9:	89 d1                	mov    %edx,%ecx
  800ecb:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  800ecd:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ed1:	39 d1                	cmp    %edx,%ecx
  800ed3:	72 17                	jb     800eec <__udivdi3+0x10c>
  800ed5:	74 09                	je     800ee0 <__udivdi3+0x100>
  800ed7:	89 fe                	mov    %edi,%esi
  800ed9:	31 ff                	xor    %edi,%edi
  800edb:	e9 41 ff ff ff       	jmp    800e21 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800ee0:	8b 54 24 04          	mov    0x4(%esp),%edx
  800ee4:	89 f1                	mov    %esi,%ecx
  800ee6:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ee8:	39 c2                	cmp    %eax,%edx
  800eea:	73 eb                	jae    800ed7 <__udivdi3+0xf7>
		{
		  q0--;
  800eec:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800eef:	31 ff                	xor    %edi,%edi
  800ef1:	e9 2b ff ff ff       	jmp    800e21 <__udivdi3+0x41>
  800ef6:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ef8:	31 f6                	xor    %esi,%esi
  800efa:	e9 22 ff ff ff       	jmp    800e21 <__udivdi3+0x41>
	...

00800f00 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800f00:	55                   	push   %ebp
  800f01:	57                   	push   %edi
  800f02:	56                   	push   %esi
  800f03:	83 ec 20             	sub    $0x20,%esp
  800f06:	8b 44 24 30          	mov    0x30(%esp),%eax
  800f0a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800f0e:	89 44 24 14          	mov    %eax,0x14(%esp)
  800f12:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  800f16:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800f1a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800f1e:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  800f20:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800f22:	85 ed                	test   %ebp,%ebp
  800f24:	75 16                	jne    800f3c <__umoddi3+0x3c>
    {
      if (d0 > n1)
  800f26:	39 f1                	cmp    %esi,%ecx
  800f28:	0f 86 a6 00 00 00    	jbe    800fd4 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f2e:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800f30:	89 d0                	mov    %edx,%eax
  800f32:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f34:	83 c4 20             	add    $0x20,%esp
  800f37:	5e                   	pop    %esi
  800f38:	5f                   	pop    %edi
  800f39:	5d                   	pop    %ebp
  800f3a:	c3                   	ret    
  800f3b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800f3c:	39 f5                	cmp    %esi,%ebp
  800f3e:	0f 87 ac 00 00 00    	ja     800ff0 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800f44:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  800f47:	83 f0 1f             	xor    $0x1f,%eax
  800f4a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f4e:	0f 84 a8 00 00 00    	je     800ffc <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800f54:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f58:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800f5a:	bf 20 00 00 00       	mov    $0x20,%edi
  800f5f:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800f63:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f67:	89 f9                	mov    %edi,%ecx
  800f69:	d3 e8                	shr    %cl,%eax
  800f6b:	09 e8                	or     %ebp,%eax
  800f6d:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  800f71:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f75:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f79:	d3 e0                	shl    %cl,%eax
  800f7b:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800f7f:	89 f2                	mov    %esi,%edx
  800f81:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800f83:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f87:	d3 e0                	shl    %cl,%eax
  800f89:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800f8d:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f91:	89 f9                	mov    %edi,%ecx
  800f93:	d3 e8                	shr    %cl,%eax
  800f95:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800f97:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800f99:	89 f2                	mov    %esi,%edx
  800f9b:	f7 74 24 18          	divl   0x18(%esp)
  800f9f:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800fa1:	f7 64 24 0c          	mull   0xc(%esp)
  800fa5:	89 c5                	mov    %eax,%ebp
  800fa7:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800fa9:	39 d6                	cmp    %edx,%esi
  800fab:	72 67                	jb     801014 <__umoddi3+0x114>
  800fad:	74 75                	je     801024 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800faf:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800fb3:	29 e8                	sub    %ebp,%eax
  800fb5:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800fb7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800fbb:	d3 e8                	shr    %cl,%eax
  800fbd:	89 f2                	mov    %esi,%edx
  800fbf:	89 f9                	mov    %edi,%ecx
  800fc1:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800fc3:	09 d0                	or     %edx,%eax
  800fc5:	89 f2                	mov    %esi,%edx
  800fc7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800fcb:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800fcd:	83 c4 20             	add    $0x20,%esp
  800fd0:	5e                   	pop    %esi
  800fd1:	5f                   	pop    %edi
  800fd2:	5d                   	pop    %ebp
  800fd3:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800fd4:	85 c9                	test   %ecx,%ecx
  800fd6:	75 0b                	jne    800fe3 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800fd8:	b8 01 00 00 00       	mov    $0x1,%eax
  800fdd:	31 d2                	xor    %edx,%edx
  800fdf:	f7 f1                	div    %ecx
  800fe1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800fe3:	89 f0                	mov    %esi,%eax
  800fe5:	31 d2                	xor    %edx,%edx
  800fe7:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800fe9:	89 f8                	mov    %edi,%eax
  800feb:	e9 3e ff ff ff       	jmp    800f2e <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800ff0:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ff2:	83 c4 20             	add    $0x20,%esp
  800ff5:	5e                   	pop    %esi
  800ff6:	5f                   	pop    %edi
  800ff7:	5d                   	pop    %ebp
  800ff8:	c3                   	ret    
  800ff9:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ffc:	39 f5                	cmp    %esi,%ebp
  800ffe:	72 04                	jb     801004 <__umoddi3+0x104>
  801000:	39 f9                	cmp    %edi,%ecx
  801002:	77 06                	ja     80100a <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801004:	89 f2                	mov    %esi,%edx
  801006:	29 cf                	sub    %ecx,%edi
  801008:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  80100a:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80100c:	83 c4 20             	add    $0x20,%esp
  80100f:	5e                   	pop    %esi
  801010:	5f                   	pop    %edi
  801011:	5d                   	pop    %ebp
  801012:	c3                   	ret    
  801013:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801014:	89 d1                	mov    %edx,%ecx
  801016:	89 c5                	mov    %eax,%ebp
  801018:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  80101c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801020:	eb 8d                	jmp    800faf <__umoddi3+0xaf>
  801022:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801024:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801028:	72 ea                	jb     801014 <__umoddi3+0x114>
  80102a:	89 f1                	mov    %esi,%ecx
  80102c:	eb 81                	jmp    800faf <__umoddi3+0xaf>
