
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
  80003a:	c7 44 24 04 70 04 80 	movl   $0x800470,0x4(%esp)
  800041:	00 
  800042:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800049:	e8 d7 02 00 00       	call   800325 <sys_env_set_pgfault_upcall>
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
  80006a:	e8 d8 00 00 00       	call   800147 <sys_getenvid>
  80006f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800074:	c1 e0 07             	shl    $0x7,%eax
  800077:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007c:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800081:	85 f6                	test   %esi,%esi
  800083:	7e 07                	jle    80008c <libmain+0x30>
		binaryname = argv[0];
  800085:	8b 03                	mov    (%ebx),%eax
  800087:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80008c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800090:	89 34 24             	mov    %esi,(%esp)
  800093:	e8 9c ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800098:	e8 07 00 00 00       	call   8000a4 <exit>
}
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	5b                   	pop    %ebx
  8000a1:	5e                   	pop    %esi
  8000a2:	5d                   	pop    %ebp
  8000a3:	c3                   	ret    

008000a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  8000aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b1:	e8 3f 00 00 00       	call   8000f5 <sys_env_destroy>
}
  8000b6:	c9                   	leave  
  8000b7:	c3                   	ret    

008000b8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	57                   	push   %edi
  8000bc:	56                   	push   %esi
  8000bd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000be:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c9:	89 c3                	mov    %eax,%ebx
  8000cb:	89 c7                	mov    %eax,%edi
  8000cd:	89 c6                	mov    %eax,%esi
  8000cf:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d1:	5b                   	pop    %ebx
  8000d2:	5e                   	pop    %esi
  8000d3:	5f                   	pop    %edi
  8000d4:	5d                   	pop    %ebp
  8000d5:	c3                   	ret    

008000d6 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d6:	55                   	push   %ebp
  8000d7:	89 e5                	mov    %esp,%ebp
  8000d9:	57                   	push   %edi
  8000da:	56                   	push   %esi
  8000db:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e6:	89 d1                	mov    %edx,%ecx
  8000e8:	89 d3                	mov    %edx,%ebx
  8000ea:	89 d7                	mov    %edx,%edi
  8000ec:	89 d6                	mov    %edx,%esi
  8000ee:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f0:	5b                   	pop    %ebx
  8000f1:	5e                   	pop    %esi
  8000f2:	5f                   	pop    %edi
  8000f3:	5d                   	pop    %ebp
  8000f4:	c3                   	ret    

008000f5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f5:	55                   	push   %ebp
  8000f6:	89 e5                	mov    %esp,%ebp
  8000f8:	57                   	push   %edi
  8000f9:	56                   	push   %esi
  8000fa:	53                   	push   %ebx
  8000fb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800103:	b8 03 00 00 00       	mov    $0x3,%eax
  800108:	8b 55 08             	mov    0x8(%ebp),%edx
  80010b:	89 cb                	mov    %ecx,%ebx
  80010d:	89 cf                	mov    %ecx,%edi
  80010f:	89 ce                	mov    %ecx,%esi
  800111:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800113:	85 c0                	test   %eax,%eax
  800115:	7e 28                	jle    80013f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800117:	89 44 24 10          	mov    %eax,0x10(%esp)
  80011b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800122:	00 
  800123:	c7 44 24 08 2a 11 80 	movl   $0x80112a,0x8(%esp)
  80012a:	00 
  80012b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800132:	00 
  800133:	c7 04 24 47 11 80 00 	movl   $0x801147,(%esp)
  80013a:	e8 55 03 00 00       	call   800494 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80013f:	83 c4 2c             	add    $0x2c,%esp
  800142:	5b                   	pop    %ebx
  800143:	5e                   	pop    %esi
  800144:	5f                   	pop    %edi
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    

00800147 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	57                   	push   %edi
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014d:	ba 00 00 00 00       	mov    $0x0,%edx
  800152:	b8 02 00 00 00       	mov    $0x2,%eax
  800157:	89 d1                	mov    %edx,%ecx
  800159:	89 d3                	mov    %edx,%ebx
  80015b:	89 d7                	mov    %edx,%edi
  80015d:	89 d6                	mov    %edx,%esi
  80015f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800161:	5b                   	pop    %ebx
  800162:	5e                   	pop    %esi
  800163:	5f                   	pop    %edi
  800164:	5d                   	pop    %ebp
  800165:	c3                   	ret    

00800166 <sys_yield>:

void
sys_yield(void)
{
  800166:	55                   	push   %ebp
  800167:	89 e5                	mov    %esp,%ebp
  800169:	57                   	push   %edi
  80016a:	56                   	push   %esi
  80016b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016c:	ba 00 00 00 00       	mov    $0x0,%edx
  800171:	b8 0b 00 00 00       	mov    $0xb,%eax
  800176:	89 d1                	mov    %edx,%ecx
  800178:	89 d3                	mov    %edx,%ebx
  80017a:	89 d7                	mov    %edx,%edi
  80017c:	89 d6                	mov    %edx,%esi
  80017e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800180:	5b                   	pop    %ebx
  800181:	5e                   	pop    %esi
  800182:	5f                   	pop    %edi
  800183:	5d                   	pop    %ebp
  800184:	c3                   	ret    

00800185 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800185:	55                   	push   %ebp
  800186:	89 e5                	mov    %esp,%ebp
  800188:	57                   	push   %edi
  800189:	56                   	push   %esi
  80018a:	53                   	push   %ebx
  80018b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80018e:	be 00 00 00 00       	mov    $0x0,%esi
  800193:	b8 04 00 00 00       	mov    $0x4,%eax
  800198:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80019b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80019e:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a1:	89 f7                	mov    %esi,%edi
  8001a3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001a5:	85 c0                	test   %eax,%eax
  8001a7:	7e 28                	jle    8001d1 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001ad:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001b4:	00 
  8001b5:	c7 44 24 08 2a 11 80 	movl   $0x80112a,0x8(%esp)
  8001bc:	00 
  8001bd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001c4:	00 
  8001c5:	c7 04 24 47 11 80 00 	movl   $0x801147,(%esp)
  8001cc:	e8 c3 02 00 00       	call   800494 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001d1:	83 c4 2c             	add    $0x2c,%esp
  8001d4:	5b                   	pop    %ebx
  8001d5:	5e                   	pop    %esi
  8001d6:	5f                   	pop    %edi
  8001d7:	5d                   	pop    %ebp
  8001d8:	c3                   	ret    

008001d9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001d9:	55                   	push   %ebp
  8001da:	89 e5                	mov    %esp,%ebp
  8001dc:	57                   	push   %edi
  8001dd:	56                   	push   %esi
  8001de:	53                   	push   %ebx
  8001df:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001e7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ea:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001ed:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001f8:	85 c0                	test   %eax,%eax
  8001fa:	7e 28                	jle    800224 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800200:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800207:	00 
  800208:	c7 44 24 08 2a 11 80 	movl   $0x80112a,0x8(%esp)
  80020f:	00 
  800210:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800217:	00 
  800218:	c7 04 24 47 11 80 00 	movl   $0x801147,(%esp)
  80021f:	e8 70 02 00 00       	call   800494 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800224:	83 c4 2c             	add    $0x2c,%esp
  800227:	5b                   	pop    %ebx
  800228:	5e                   	pop    %esi
  800229:	5f                   	pop    %edi
  80022a:	5d                   	pop    %ebp
  80022b:	c3                   	ret    

0080022c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80022c:	55                   	push   %ebp
  80022d:	89 e5                	mov    %esp,%ebp
  80022f:	57                   	push   %edi
  800230:	56                   	push   %esi
  800231:	53                   	push   %ebx
  800232:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800235:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023a:	b8 06 00 00 00       	mov    $0x6,%eax
  80023f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800242:	8b 55 08             	mov    0x8(%ebp),%edx
  800245:	89 df                	mov    %ebx,%edi
  800247:	89 de                	mov    %ebx,%esi
  800249:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80024b:	85 c0                	test   %eax,%eax
  80024d:	7e 28                	jle    800277 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80024f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800253:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80025a:	00 
  80025b:	c7 44 24 08 2a 11 80 	movl   $0x80112a,0x8(%esp)
  800262:	00 
  800263:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80026a:	00 
  80026b:	c7 04 24 47 11 80 00 	movl   $0x801147,(%esp)
  800272:	e8 1d 02 00 00       	call   800494 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800277:	83 c4 2c             	add    $0x2c,%esp
  80027a:	5b                   	pop    %ebx
  80027b:	5e                   	pop    %esi
  80027c:	5f                   	pop    %edi
  80027d:	5d                   	pop    %ebp
  80027e:	c3                   	ret    

0080027f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80027f:	55                   	push   %ebp
  800280:	89 e5                	mov    %esp,%ebp
  800282:	57                   	push   %edi
  800283:	56                   	push   %esi
  800284:	53                   	push   %ebx
  800285:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800288:	bb 00 00 00 00       	mov    $0x0,%ebx
  80028d:	b8 08 00 00 00       	mov    $0x8,%eax
  800292:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800295:	8b 55 08             	mov    0x8(%ebp),%edx
  800298:	89 df                	mov    %ebx,%edi
  80029a:	89 de                	mov    %ebx,%esi
  80029c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80029e:	85 c0                	test   %eax,%eax
  8002a0:	7e 28                	jle    8002ca <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002a2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002a6:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002ad:	00 
  8002ae:	c7 44 24 08 2a 11 80 	movl   $0x80112a,0x8(%esp)
  8002b5:	00 
  8002b6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002bd:	00 
  8002be:	c7 04 24 47 11 80 00 	movl   $0x801147,(%esp)
  8002c5:	e8 ca 01 00 00       	call   800494 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002ca:	83 c4 2c             	add    $0x2c,%esp
  8002cd:	5b                   	pop    %ebx
  8002ce:	5e                   	pop    %esi
  8002cf:	5f                   	pop    %edi
  8002d0:	5d                   	pop    %ebp
  8002d1:	c3                   	ret    

008002d2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	57                   	push   %edi
  8002d6:	56                   	push   %esi
  8002d7:	53                   	push   %ebx
  8002d8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002db:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002e0:	b8 09 00 00 00       	mov    $0x9,%eax
  8002e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8002eb:	89 df                	mov    %ebx,%edi
  8002ed:	89 de                	mov    %ebx,%esi
  8002ef:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002f1:	85 c0                	test   %eax,%eax
  8002f3:	7e 28                	jle    80031d <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002f9:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800300:	00 
  800301:	c7 44 24 08 2a 11 80 	movl   $0x80112a,0x8(%esp)
  800308:	00 
  800309:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800310:	00 
  800311:	c7 04 24 47 11 80 00 	movl   $0x801147,(%esp)
  800318:	e8 77 01 00 00       	call   800494 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80031d:	83 c4 2c             	add    $0x2c,%esp
  800320:	5b                   	pop    %ebx
  800321:	5e                   	pop    %esi
  800322:	5f                   	pop    %edi
  800323:	5d                   	pop    %ebp
  800324:	c3                   	ret    

00800325 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800325:	55                   	push   %ebp
  800326:	89 e5                	mov    %esp,%ebp
  800328:	57                   	push   %edi
  800329:	56                   	push   %esi
  80032a:	53                   	push   %ebx
  80032b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80032e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800333:	b8 0a 00 00 00       	mov    $0xa,%eax
  800338:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80033b:	8b 55 08             	mov    0x8(%ebp),%edx
  80033e:	89 df                	mov    %ebx,%edi
  800340:	89 de                	mov    %ebx,%esi
  800342:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800344:	85 c0                	test   %eax,%eax
  800346:	7e 28                	jle    800370 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800348:	89 44 24 10          	mov    %eax,0x10(%esp)
  80034c:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800353:	00 
  800354:	c7 44 24 08 2a 11 80 	movl   $0x80112a,0x8(%esp)
  80035b:	00 
  80035c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800363:	00 
  800364:	c7 04 24 47 11 80 00 	movl   $0x801147,(%esp)
  80036b:	e8 24 01 00 00       	call   800494 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800370:	83 c4 2c             	add    $0x2c,%esp
  800373:	5b                   	pop    %ebx
  800374:	5e                   	pop    %esi
  800375:	5f                   	pop    %edi
  800376:	5d                   	pop    %ebp
  800377:	c3                   	ret    

00800378 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800378:	55                   	push   %ebp
  800379:	89 e5                	mov    %esp,%ebp
  80037b:	57                   	push   %edi
  80037c:	56                   	push   %esi
  80037d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80037e:	be 00 00 00 00       	mov    $0x0,%esi
  800383:	b8 0c 00 00 00       	mov    $0xc,%eax
  800388:	8b 7d 14             	mov    0x14(%ebp),%edi
  80038b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80038e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800391:	8b 55 08             	mov    0x8(%ebp),%edx
  800394:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800396:	5b                   	pop    %ebx
  800397:	5e                   	pop    %esi
  800398:	5f                   	pop    %edi
  800399:	5d                   	pop    %ebp
  80039a:	c3                   	ret    

0080039b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80039b:	55                   	push   %ebp
  80039c:	89 e5                	mov    %esp,%ebp
  80039e:	57                   	push   %edi
  80039f:	56                   	push   %esi
  8003a0:	53                   	push   %ebx
  8003a1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003a4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003a9:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b1:	89 cb                	mov    %ecx,%ebx
  8003b3:	89 cf                	mov    %ecx,%edi
  8003b5:	89 ce                	mov    %ecx,%esi
  8003b7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003b9:	85 c0                	test   %eax,%eax
  8003bb:	7e 28                	jle    8003e5 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003bd:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003c1:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003c8:	00 
  8003c9:	c7 44 24 08 2a 11 80 	movl   $0x80112a,0x8(%esp)
  8003d0:	00 
  8003d1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003d8:	00 
  8003d9:	c7 04 24 47 11 80 00 	movl   $0x801147,(%esp)
  8003e0:	e8 af 00 00 00       	call   800494 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003e5:	83 c4 2c             	add    $0x2c,%esp
  8003e8:	5b                   	pop    %ebx
  8003e9:	5e                   	pop    %esi
  8003ea:	5f                   	pop    %edi
  8003eb:	5d                   	pop    %ebp
  8003ec:	c3                   	ret    

008003ed <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8003ed:	55                   	push   %ebp
  8003ee:	89 e5                	mov    %esp,%ebp
  8003f0:	57                   	push   %edi
  8003f1:	56                   	push   %esi
  8003f2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f8:	b8 0e 00 00 00       	mov    $0xe,%eax
  8003fd:	89 d1                	mov    %edx,%ecx
  8003ff:	89 d3                	mov    %edx,%ebx
  800401:	89 d7                	mov    %edx,%edi
  800403:	89 d6                	mov    %edx,%esi
  800405:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800407:	5b                   	pop    %ebx
  800408:	5e                   	pop    %esi
  800409:	5f                   	pop    %edi
  80040a:	5d                   	pop    %ebp
  80040b:	c3                   	ret    

0080040c <sys_e1000_transmit>:

int 
sys_e1000_transmit(char* pck, size_t length){
  80040c:	55                   	push   %ebp
  80040d:	89 e5                	mov    %esp,%ebp
  80040f:	57                   	push   %edi
  800410:	56                   	push   %esi
  800411:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800412:	bb 00 00 00 00       	mov    $0x0,%ebx
  800417:	b8 10 00 00 00       	mov    $0x10,%eax
  80041c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80041f:	8b 55 08             	mov    0x8(%ebp),%edx
  800422:	89 df                	mov    %ebx,%edi
  800424:	89 de                	mov    %ebx,%esi
  800426:	cd 30                	int    $0x30
}

int 
sys_e1000_transmit(char* pck, size_t length){
	return syscall(SYS_e1000_transmit, 0, (uint32_t)pck, length, 0, 0, 0);
}
  800428:	5b                   	pop    %ebx
  800429:	5e                   	pop    %esi
  80042a:	5f                   	pop    %edi
  80042b:	5d                   	pop    %ebp
  80042c:	c3                   	ret    

0080042d <sys_e1000_receive>:

int 
sys_e1000_receive(char* pck, size_t* length){
  80042d:	55                   	push   %ebp
  80042e:	89 e5                	mov    %esp,%ebp
  800430:	57                   	push   %edi
  800431:	56                   	push   %esi
  800432:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800433:	bb 00 00 00 00       	mov    $0x0,%ebx
  800438:	b8 0f 00 00 00       	mov    $0xf,%eax
  80043d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800440:	8b 55 08             	mov    0x8(%ebp),%edx
  800443:	89 df                	mov    %ebx,%edi
  800445:	89 de                	mov    %ebx,%esi
  800447:	cd 30                	int    $0x30
}

int 
sys_e1000_receive(char* pck, size_t* length){
	return syscall(SYS_e1000_receive, 0, (uint32_t)pck, (uint32_t)length, 0, 0, 0);
}
  800449:	5b                   	pop    %ebx
  80044a:	5e                   	pop    %esi
  80044b:	5f                   	pop    %edi
  80044c:	5d                   	pop    %ebp
  80044d:	c3                   	ret    

0080044e <sys_e1000_get_mac>:

int 
sys_e1000_get_mac(uint8_t* mac_addr){
  80044e:	55                   	push   %ebp
  80044f:	89 e5                	mov    %esp,%ebp
  800451:	57                   	push   %edi
  800452:	56                   	push   %esi
  800453:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800454:	b9 00 00 00 00       	mov    $0x0,%ecx
  800459:	b8 11 00 00 00       	mov    $0x11,%eax
  80045e:	8b 55 08             	mov    0x8(%ebp),%edx
  800461:	89 cb                	mov    %ecx,%ebx
  800463:	89 cf                	mov    %ecx,%edi
  800465:	89 ce                	mov    %ecx,%esi
  800467:	cd 30                	int    $0x30
}

int 
sys_e1000_get_mac(uint8_t* mac_addr){
	return syscall(SYS_e1000_get_mac, 0, (uint32_t)mac_addr, 0, 0, 0, 0);
}
  800469:	5b                   	pop    %ebx
  80046a:	5e                   	pop    %esi
  80046b:	5f                   	pop    %edi
  80046c:	5d                   	pop    %ebp
  80046d:	c3                   	ret    
	...

00800470 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800470:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800471:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800476:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800478:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// Save trap-time eip in eax
	movl 0x28(%esp), %eax
  80047b:	8b 44 24 28          	mov    0x28(%esp),%eax

	// Save our current stack
	movl %esp, %ebp
  80047f:	89 e5                	mov    %esp,%ebp

	// Switch to trap-time stack
	movl 0x30(%esp), %esp
  800481:	8b 64 24 30          	mov    0x30(%esp),%esp

	// Push trap-time eip to the trap-time stack
	pushl %eax
  800485:	50                   	push   %eax

	// We now have to update the trap-time esp with its new value
	movl %esp, 0x30(%ebp)
  800486:	89 65 30             	mov    %esp,0x30(%ebp)

	// Go back to our exception stack
	movl %ebp, %esp
  800489:	89 ec                	mov    %ebp,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// Pop fault_va and err, both can be ignored
	popl %eax
  80048b:	58                   	pop    %eax
	popl %eax
  80048c:	58                   	pop    %eax

	// Pop all registers back
	popal
  80048d:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// Skip %eip
	addl $0x4, %esp
  80048e:	83 c4 04             	add    $0x4,%esp

	// Pop eflags back
	popfl
  800491:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	
	popl %esp
  800492:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  800493:	c3                   	ret    

00800494 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800494:	55                   	push   %ebp
  800495:	89 e5                	mov    %esp,%ebp
  800497:	56                   	push   %esi
  800498:	53                   	push   %ebx
  800499:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80049c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80049f:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8004a5:	e8 9d fc ff ff       	call   800147 <sys_getenvid>
  8004aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004ad:	89 54 24 10          	mov    %edx,0x10(%esp)
  8004b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8004b4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004b8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8004bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004c0:	c7 04 24 58 11 80 00 	movl   $0x801158,(%esp)
  8004c7:	e8 c0 00 00 00       	call   80058c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8004cc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004d0:	8b 45 10             	mov    0x10(%ebp),%eax
  8004d3:	89 04 24             	mov    %eax,(%esp)
  8004d6:	e8 50 00 00 00       	call   80052b <vcprintf>
	cprintf("\n");
  8004db:	c7 04 24 7b 11 80 00 	movl   $0x80117b,(%esp)
  8004e2:	e8 a5 00 00 00       	call   80058c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004e7:	cc                   	int3   
  8004e8:	eb fd                	jmp    8004e7 <_panic+0x53>
	...

008004ec <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004ec:	55                   	push   %ebp
  8004ed:	89 e5                	mov    %esp,%ebp
  8004ef:	53                   	push   %ebx
  8004f0:	83 ec 14             	sub    $0x14,%esp
  8004f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8004f6:	8b 03                	mov    (%ebx),%eax
  8004f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8004fb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8004ff:	40                   	inc    %eax
  800500:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800502:	3d ff 00 00 00       	cmp    $0xff,%eax
  800507:	75 19                	jne    800522 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800509:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800510:	00 
  800511:	8d 43 08             	lea    0x8(%ebx),%eax
  800514:	89 04 24             	mov    %eax,(%esp)
  800517:	e8 9c fb ff ff       	call   8000b8 <sys_cputs>
		b->idx = 0;
  80051c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800522:	ff 43 04             	incl   0x4(%ebx)
}
  800525:	83 c4 14             	add    $0x14,%esp
  800528:	5b                   	pop    %ebx
  800529:	5d                   	pop    %ebp
  80052a:	c3                   	ret    

0080052b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80052b:	55                   	push   %ebp
  80052c:	89 e5                	mov    %esp,%ebp
  80052e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800534:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80053b:	00 00 00 
	b.cnt = 0;
  80053e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800545:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800548:	8b 45 0c             	mov    0xc(%ebp),%eax
  80054b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80054f:	8b 45 08             	mov    0x8(%ebp),%eax
  800552:	89 44 24 08          	mov    %eax,0x8(%esp)
  800556:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80055c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800560:	c7 04 24 ec 04 80 00 	movl   $0x8004ec,(%esp)
  800567:	e8 82 01 00 00       	call   8006ee <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80056c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800572:	89 44 24 04          	mov    %eax,0x4(%esp)
  800576:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80057c:	89 04 24             	mov    %eax,(%esp)
  80057f:	e8 34 fb ff ff       	call   8000b8 <sys_cputs>

	return b.cnt;
}
  800584:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80058a:	c9                   	leave  
  80058b:	c3                   	ret    

0080058c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80058c:	55                   	push   %ebp
  80058d:	89 e5                	mov    %esp,%ebp
  80058f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800592:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800595:	89 44 24 04          	mov    %eax,0x4(%esp)
  800599:	8b 45 08             	mov    0x8(%ebp),%eax
  80059c:	89 04 24             	mov    %eax,(%esp)
  80059f:	e8 87 ff ff ff       	call   80052b <vcprintf>
	va_end(ap);

	return cnt;
}
  8005a4:	c9                   	leave  
  8005a5:	c3                   	ret    
	...

008005a8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005a8:	55                   	push   %ebp
  8005a9:	89 e5                	mov    %esp,%ebp
  8005ab:	57                   	push   %edi
  8005ac:	56                   	push   %esi
  8005ad:	53                   	push   %ebx
  8005ae:	83 ec 3c             	sub    $0x3c,%esp
  8005b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005b4:	89 d7                	mov    %edx,%edi
  8005b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8005b9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8005bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005bf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005c2:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8005c5:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005c8:	85 c0                	test   %eax,%eax
  8005ca:	75 08                	jne    8005d4 <printnum+0x2c>
  8005cc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005cf:	39 45 10             	cmp    %eax,0x10(%ebp)
  8005d2:	77 57                	ja     80062b <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005d4:	89 74 24 10          	mov    %esi,0x10(%esp)
  8005d8:	4b                   	dec    %ebx
  8005d9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8005dd:	8b 45 10             	mov    0x10(%ebp),%eax
  8005e0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005e4:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8005e8:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8005ec:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005f3:	00 
  8005f4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005f7:	89 04 24             	mov    %eax,(%esp)
  8005fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800601:	e8 ca 08 00 00       	call   800ed0 <__udivdi3>
  800606:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80060a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80060e:	89 04 24             	mov    %eax,(%esp)
  800611:	89 54 24 04          	mov    %edx,0x4(%esp)
  800615:	89 fa                	mov    %edi,%edx
  800617:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80061a:	e8 89 ff ff ff       	call   8005a8 <printnum>
  80061f:	eb 0f                	jmp    800630 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800621:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800625:	89 34 24             	mov    %esi,(%esp)
  800628:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80062b:	4b                   	dec    %ebx
  80062c:	85 db                	test   %ebx,%ebx
  80062e:	7f f1                	jg     800621 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800630:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800634:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800638:	8b 45 10             	mov    0x10(%ebp),%eax
  80063b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80063f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800646:	00 
  800647:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80064a:	89 04 24             	mov    %eax,(%esp)
  80064d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800650:	89 44 24 04          	mov    %eax,0x4(%esp)
  800654:	e8 97 09 00 00       	call   800ff0 <__umoddi3>
  800659:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80065d:	0f be 80 7d 11 80 00 	movsbl 0x80117d(%eax),%eax
  800664:	89 04 24             	mov    %eax,(%esp)
  800667:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80066a:	83 c4 3c             	add    $0x3c,%esp
  80066d:	5b                   	pop    %ebx
  80066e:	5e                   	pop    %esi
  80066f:	5f                   	pop    %edi
  800670:	5d                   	pop    %ebp
  800671:	c3                   	ret    

00800672 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800672:	55                   	push   %ebp
  800673:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800675:	83 fa 01             	cmp    $0x1,%edx
  800678:	7e 0e                	jle    800688 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80067a:	8b 10                	mov    (%eax),%edx
  80067c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80067f:	89 08                	mov    %ecx,(%eax)
  800681:	8b 02                	mov    (%edx),%eax
  800683:	8b 52 04             	mov    0x4(%edx),%edx
  800686:	eb 22                	jmp    8006aa <getuint+0x38>
	else if (lflag)
  800688:	85 d2                	test   %edx,%edx
  80068a:	74 10                	je     80069c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80068c:	8b 10                	mov    (%eax),%edx
  80068e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800691:	89 08                	mov    %ecx,(%eax)
  800693:	8b 02                	mov    (%edx),%eax
  800695:	ba 00 00 00 00       	mov    $0x0,%edx
  80069a:	eb 0e                	jmp    8006aa <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80069c:	8b 10                	mov    (%eax),%edx
  80069e:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006a1:	89 08                	mov    %ecx,(%eax)
  8006a3:	8b 02                	mov    (%edx),%eax
  8006a5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006aa:	5d                   	pop    %ebp
  8006ab:	c3                   	ret    

008006ac <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8006ac:	55                   	push   %ebp
  8006ad:	89 e5                	mov    %esp,%ebp
  8006af:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006b2:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8006b5:	8b 10                	mov    (%eax),%edx
  8006b7:	3b 50 04             	cmp    0x4(%eax),%edx
  8006ba:	73 08                	jae    8006c4 <sprintputch+0x18>
		*b->buf++ = ch;
  8006bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006bf:	88 0a                	mov    %cl,(%edx)
  8006c1:	42                   	inc    %edx
  8006c2:	89 10                	mov    %edx,(%eax)
}
  8006c4:	5d                   	pop    %ebp
  8006c5:	c3                   	ret    

008006c6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006c6:	55                   	push   %ebp
  8006c7:	89 e5                	mov    %esp,%ebp
  8006c9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8006cc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006d3:	8b 45 10             	mov    0x10(%ebp),%eax
  8006d6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e4:	89 04 24             	mov    %eax,(%esp)
  8006e7:	e8 02 00 00 00       	call   8006ee <vprintfmt>
	va_end(ap);
}
  8006ec:	c9                   	leave  
  8006ed:	c3                   	ret    

008006ee <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006ee:	55                   	push   %ebp
  8006ef:	89 e5                	mov    %esp,%ebp
  8006f1:	57                   	push   %edi
  8006f2:	56                   	push   %esi
  8006f3:	53                   	push   %ebx
  8006f4:	83 ec 4c             	sub    $0x4c,%esp
  8006f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006fa:	8b 75 10             	mov    0x10(%ebp),%esi
  8006fd:	eb 12                	jmp    800711 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006ff:	85 c0                	test   %eax,%eax
  800701:	0f 84 6b 03 00 00    	je     800a72 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800707:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80070b:	89 04 24             	mov    %eax,(%esp)
  80070e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800711:	0f b6 06             	movzbl (%esi),%eax
  800714:	46                   	inc    %esi
  800715:	83 f8 25             	cmp    $0x25,%eax
  800718:	75 e5                	jne    8006ff <vprintfmt+0x11>
  80071a:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80071e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800725:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80072a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800731:	b9 00 00 00 00       	mov    $0x0,%ecx
  800736:	eb 26                	jmp    80075e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800738:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80073b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80073f:	eb 1d                	jmp    80075e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800741:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800744:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800748:	eb 14                	jmp    80075e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80074a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80074d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800754:	eb 08                	jmp    80075e <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800756:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800759:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80075e:	0f b6 06             	movzbl (%esi),%eax
  800761:	8d 56 01             	lea    0x1(%esi),%edx
  800764:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800767:	8a 16                	mov    (%esi),%dl
  800769:	83 ea 23             	sub    $0x23,%edx
  80076c:	80 fa 55             	cmp    $0x55,%dl
  80076f:	0f 87 e1 02 00 00    	ja     800a56 <vprintfmt+0x368>
  800775:	0f b6 d2             	movzbl %dl,%edx
  800778:	ff 24 95 c0 12 80 00 	jmp    *0x8012c0(,%edx,4)
  80077f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800782:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800787:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80078a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80078e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800791:	8d 50 d0             	lea    -0x30(%eax),%edx
  800794:	83 fa 09             	cmp    $0x9,%edx
  800797:	77 2a                	ja     8007c3 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800799:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80079a:	eb eb                	jmp    800787 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80079c:	8b 45 14             	mov    0x14(%ebp),%eax
  80079f:	8d 50 04             	lea    0x4(%eax),%edx
  8007a2:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a5:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8007aa:	eb 17                	jmp    8007c3 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8007ac:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007b0:	78 98                	js     80074a <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b2:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007b5:	eb a7                	jmp    80075e <vprintfmt+0x70>
  8007b7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8007ba:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8007c1:	eb 9b                	jmp    80075e <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8007c3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007c7:	79 95                	jns    80075e <vprintfmt+0x70>
  8007c9:	eb 8b                	jmp    800756 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007cb:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007cc:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8007cf:	eb 8d                	jmp    80075e <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d4:	8d 50 04             	lea    0x4(%eax),%edx
  8007d7:	89 55 14             	mov    %edx,0x14(%ebp)
  8007da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007de:	8b 00                	mov    (%eax),%eax
  8007e0:	89 04 24             	mov    %eax,(%esp)
  8007e3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007e6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8007e9:	e9 23 ff ff ff       	jmp    800711 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8007ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f1:	8d 50 04             	lea    0x4(%eax),%edx
  8007f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f7:	8b 00                	mov    (%eax),%eax
  8007f9:	85 c0                	test   %eax,%eax
  8007fb:	79 02                	jns    8007ff <vprintfmt+0x111>
  8007fd:	f7 d8                	neg    %eax
  8007ff:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800801:	83 f8 11             	cmp    $0x11,%eax
  800804:	7f 0b                	jg     800811 <vprintfmt+0x123>
  800806:	8b 04 85 20 14 80 00 	mov    0x801420(,%eax,4),%eax
  80080d:	85 c0                	test   %eax,%eax
  80080f:	75 23                	jne    800834 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800811:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800815:	c7 44 24 08 95 11 80 	movl   $0x801195,0x8(%esp)
  80081c:	00 
  80081d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800821:	8b 45 08             	mov    0x8(%ebp),%eax
  800824:	89 04 24             	mov    %eax,(%esp)
  800827:	e8 9a fe ff ff       	call   8006c6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80082c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80082f:	e9 dd fe ff ff       	jmp    800711 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800834:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800838:	c7 44 24 08 9e 11 80 	movl   $0x80119e,0x8(%esp)
  80083f:	00 
  800840:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800844:	8b 55 08             	mov    0x8(%ebp),%edx
  800847:	89 14 24             	mov    %edx,(%esp)
  80084a:	e8 77 fe ff ff       	call   8006c6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80084f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800852:	e9 ba fe ff ff       	jmp    800711 <vprintfmt+0x23>
  800857:	89 f9                	mov    %edi,%ecx
  800859:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80085c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80085f:	8b 45 14             	mov    0x14(%ebp),%eax
  800862:	8d 50 04             	lea    0x4(%eax),%edx
  800865:	89 55 14             	mov    %edx,0x14(%ebp)
  800868:	8b 30                	mov    (%eax),%esi
  80086a:	85 f6                	test   %esi,%esi
  80086c:	75 05                	jne    800873 <vprintfmt+0x185>
				p = "(null)";
  80086e:	be 8e 11 80 00       	mov    $0x80118e,%esi
			if (width > 0 && padc != '-')
  800873:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800877:	0f 8e 84 00 00 00    	jle    800901 <vprintfmt+0x213>
  80087d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800881:	74 7e                	je     800901 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800883:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800887:	89 34 24             	mov    %esi,(%esp)
  80088a:	e8 8b 02 00 00       	call   800b1a <strnlen>
  80088f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800892:	29 c2                	sub    %eax,%edx
  800894:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800897:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80089b:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80089e:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8008a1:	89 de                	mov    %ebx,%esi
  8008a3:	89 d3                	mov    %edx,%ebx
  8008a5:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008a7:	eb 0b                	jmp    8008b4 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8008a9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008ad:	89 3c 24             	mov    %edi,(%esp)
  8008b0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008b3:	4b                   	dec    %ebx
  8008b4:	85 db                	test   %ebx,%ebx
  8008b6:	7f f1                	jg     8008a9 <vprintfmt+0x1bb>
  8008b8:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8008bb:	89 f3                	mov    %esi,%ebx
  8008bd:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8008c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8008c3:	85 c0                	test   %eax,%eax
  8008c5:	79 05                	jns    8008cc <vprintfmt+0x1de>
  8008c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8008cc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008cf:	29 c2                	sub    %eax,%edx
  8008d1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8008d4:	eb 2b                	jmp    800901 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008d6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8008da:	74 18                	je     8008f4 <vprintfmt+0x206>
  8008dc:	8d 50 e0             	lea    -0x20(%eax),%edx
  8008df:	83 fa 5e             	cmp    $0x5e,%edx
  8008e2:	76 10                	jbe    8008f4 <vprintfmt+0x206>
					putch('?', putdat);
  8008e4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008e8:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8008ef:	ff 55 08             	call   *0x8(%ebp)
  8008f2:	eb 0a                	jmp    8008fe <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8008f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008f8:	89 04 24             	mov    %eax,(%esp)
  8008fb:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008fe:	ff 4d e4             	decl   -0x1c(%ebp)
  800901:	0f be 06             	movsbl (%esi),%eax
  800904:	46                   	inc    %esi
  800905:	85 c0                	test   %eax,%eax
  800907:	74 21                	je     80092a <vprintfmt+0x23c>
  800909:	85 ff                	test   %edi,%edi
  80090b:	78 c9                	js     8008d6 <vprintfmt+0x1e8>
  80090d:	4f                   	dec    %edi
  80090e:	79 c6                	jns    8008d6 <vprintfmt+0x1e8>
  800910:	8b 7d 08             	mov    0x8(%ebp),%edi
  800913:	89 de                	mov    %ebx,%esi
  800915:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800918:	eb 18                	jmp    800932 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80091a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80091e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800925:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800927:	4b                   	dec    %ebx
  800928:	eb 08                	jmp    800932 <vprintfmt+0x244>
  80092a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80092d:	89 de                	mov    %ebx,%esi
  80092f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800932:	85 db                	test   %ebx,%ebx
  800934:	7f e4                	jg     80091a <vprintfmt+0x22c>
  800936:	89 7d 08             	mov    %edi,0x8(%ebp)
  800939:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80093b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80093e:	e9 ce fd ff ff       	jmp    800711 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800943:	83 f9 01             	cmp    $0x1,%ecx
  800946:	7e 10                	jle    800958 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800948:	8b 45 14             	mov    0x14(%ebp),%eax
  80094b:	8d 50 08             	lea    0x8(%eax),%edx
  80094e:	89 55 14             	mov    %edx,0x14(%ebp)
  800951:	8b 30                	mov    (%eax),%esi
  800953:	8b 78 04             	mov    0x4(%eax),%edi
  800956:	eb 26                	jmp    80097e <vprintfmt+0x290>
	else if (lflag)
  800958:	85 c9                	test   %ecx,%ecx
  80095a:	74 12                	je     80096e <vprintfmt+0x280>
		return va_arg(*ap, long);
  80095c:	8b 45 14             	mov    0x14(%ebp),%eax
  80095f:	8d 50 04             	lea    0x4(%eax),%edx
  800962:	89 55 14             	mov    %edx,0x14(%ebp)
  800965:	8b 30                	mov    (%eax),%esi
  800967:	89 f7                	mov    %esi,%edi
  800969:	c1 ff 1f             	sar    $0x1f,%edi
  80096c:	eb 10                	jmp    80097e <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80096e:	8b 45 14             	mov    0x14(%ebp),%eax
  800971:	8d 50 04             	lea    0x4(%eax),%edx
  800974:	89 55 14             	mov    %edx,0x14(%ebp)
  800977:	8b 30                	mov    (%eax),%esi
  800979:	89 f7                	mov    %esi,%edi
  80097b:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80097e:	85 ff                	test   %edi,%edi
  800980:	78 0a                	js     80098c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800982:	b8 0a 00 00 00       	mov    $0xa,%eax
  800987:	e9 8c 00 00 00       	jmp    800a18 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80098c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800990:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800997:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80099a:	f7 de                	neg    %esi
  80099c:	83 d7 00             	adc    $0x0,%edi
  80099f:	f7 df                	neg    %edi
			}
			base = 10;
  8009a1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009a6:	eb 70                	jmp    800a18 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009a8:	89 ca                	mov    %ecx,%edx
  8009aa:	8d 45 14             	lea    0x14(%ebp),%eax
  8009ad:	e8 c0 fc ff ff       	call   800672 <getuint>
  8009b2:	89 c6                	mov    %eax,%esi
  8009b4:	89 d7                	mov    %edx,%edi
			base = 10;
  8009b6:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8009bb:	eb 5b                	jmp    800a18 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  8009bd:	89 ca                	mov    %ecx,%edx
  8009bf:	8d 45 14             	lea    0x14(%ebp),%eax
  8009c2:	e8 ab fc ff ff       	call   800672 <getuint>
  8009c7:	89 c6                	mov    %eax,%esi
  8009c9:	89 d7                	mov    %edx,%edi
			base = 8;
  8009cb:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8009d0:	eb 46                	jmp    800a18 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  8009d2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009d6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8009dd:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8009e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009e4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8009eb:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8009ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8009f1:	8d 50 04             	lea    0x4(%eax),%edx
  8009f4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8009f7:	8b 30                	mov    (%eax),%esi
  8009f9:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8009fe:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800a03:	eb 13                	jmp    800a18 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a05:	89 ca                	mov    %ecx,%edx
  800a07:	8d 45 14             	lea    0x14(%ebp),%eax
  800a0a:	e8 63 fc ff ff       	call   800672 <getuint>
  800a0f:	89 c6                	mov    %eax,%esi
  800a11:	89 d7                	mov    %edx,%edi
			base = 16;
  800a13:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a18:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800a1c:	89 54 24 10          	mov    %edx,0x10(%esp)
  800a20:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a23:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a27:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a2b:	89 34 24             	mov    %esi,(%esp)
  800a2e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a32:	89 da                	mov    %ebx,%edx
  800a34:	8b 45 08             	mov    0x8(%ebp),%eax
  800a37:	e8 6c fb ff ff       	call   8005a8 <printnum>
			break;
  800a3c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800a3f:	e9 cd fc ff ff       	jmp    800711 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a44:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a48:	89 04 24             	mov    %eax,(%esp)
  800a4b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a4e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a51:	e9 bb fc ff ff       	jmp    800711 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a56:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a5a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a61:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a64:	eb 01                	jmp    800a67 <vprintfmt+0x379>
  800a66:	4e                   	dec    %esi
  800a67:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800a6b:	75 f9                	jne    800a66 <vprintfmt+0x378>
  800a6d:	e9 9f fc ff ff       	jmp    800711 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800a72:	83 c4 4c             	add    $0x4c,%esp
  800a75:	5b                   	pop    %ebx
  800a76:	5e                   	pop    %esi
  800a77:	5f                   	pop    %edi
  800a78:	5d                   	pop    %ebp
  800a79:	c3                   	ret    

00800a7a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
  800a7d:	83 ec 28             	sub    $0x28,%esp
  800a80:	8b 45 08             	mov    0x8(%ebp),%eax
  800a83:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a86:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a89:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a8d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a90:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a97:	85 c0                	test   %eax,%eax
  800a99:	74 30                	je     800acb <vsnprintf+0x51>
  800a9b:	85 d2                	test   %edx,%edx
  800a9d:	7e 33                	jle    800ad2 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a9f:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800aa6:	8b 45 10             	mov    0x10(%ebp),%eax
  800aa9:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aad:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800ab0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ab4:	c7 04 24 ac 06 80 00 	movl   $0x8006ac,(%esp)
  800abb:	e8 2e fc ff ff       	call   8006ee <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ac0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ac3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800ac6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ac9:	eb 0c                	jmp    800ad7 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800acb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ad0:	eb 05                	jmp    800ad7 <vsnprintf+0x5d>
  800ad2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800ad7:	c9                   	leave  
  800ad8:	c3                   	ret    

00800ad9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800ad9:	55                   	push   %ebp
  800ada:	89 e5                	mov    %esp,%ebp
  800adc:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800adf:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800ae2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ae6:	8b 45 10             	mov    0x10(%ebp),%eax
  800ae9:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aed:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800af4:	8b 45 08             	mov    0x8(%ebp),%eax
  800af7:	89 04 24             	mov    %eax,(%esp)
  800afa:	e8 7b ff ff ff       	call   800a7a <vsnprintf>
	va_end(ap);

	return rc;
}
  800aff:	c9                   	leave  
  800b00:	c3                   	ret    
  800b01:	00 00                	add    %al,(%eax)
	...

00800b04 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b04:	55                   	push   %ebp
  800b05:	89 e5                	mov    %esp,%ebp
  800b07:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b0a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b0f:	eb 01                	jmp    800b12 <strlen+0xe>
		n++;
  800b11:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b12:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b16:	75 f9                	jne    800b11 <strlen+0xd>
		n++;
	return n;
}
  800b18:	5d                   	pop    %ebp
  800b19:	c3                   	ret    

00800b1a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b1a:	55                   	push   %ebp
  800b1b:	89 e5                	mov    %esp,%ebp
  800b1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800b20:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b23:	b8 00 00 00 00       	mov    $0x0,%eax
  800b28:	eb 01                	jmp    800b2b <strnlen+0x11>
		n++;
  800b2a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b2b:	39 d0                	cmp    %edx,%eax
  800b2d:	74 06                	je     800b35 <strnlen+0x1b>
  800b2f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800b33:	75 f5                	jne    800b2a <strnlen+0x10>
		n++;
	return n;
}
  800b35:	5d                   	pop    %ebp
  800b36:	c3                   	ret    

00800b37 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	53                   	push   %ebx
  800b3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b41:	ba 00 00 00 00       	mov    $0x0,%edx
  800b46:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800b49:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800b4c:	42                   	inc    %edx
  800b4d:	84 c9                	test   %cl,%cl
  800b4f:	75 f5                	jne    800b46 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800b51:	5b                   	pop    %ebx
  800b52:	5d                   	pop    %ebp
  800b53:	c3                   	ret    

00800b54 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b54:	55                   	push   %ebp
  800b55:	89 e5                	mov    %esp,%ebp
  800b57:	53                   	push   %ebx
  800b58:	83 ec 08             	sub    $0x8,%esp
  800b5b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b5e:	89 1c 24             	mov    %ebx,(%esp)
  800b61:	e8 9e ff ff ff       	call   800b04 <strlen>
	strcpy(dst + len, src);
  800b66:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b69:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b6d:	01 d8                	add    %ebx,%eax
  800b6f:	89 04 24             	mov    %eax,(%esp)
  800b72:	e8 c0 ff ff ff       	call   800b37 <strcpy>
	return dst;
}
  800b77:	89 d8                	mov    %ebx,%eax
  800b79:	83 c4 08             	add    $0x8,%esp
  800b7c:	5b                   	pop    %ebx
  800b7d:	5d                   	pop    %ebp
  800b7e:	c3                   	ret    

00800b7f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b7f:	55                   	push   %ebp
  800b80:	89 e5                	mov    %esp,%ebp
  800b82:	56                   	push   %esi
  800b83:	53                   	push   %ebx
  800b84:	8b 45 08             	mov    0x8(%ebp),%eax
  800b87:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b8a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b8d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b92:	eb 0c                	jmp    800ba0 <strncpy+0x21>
		*dst++ = *src;
  800b94:	8a 1a                	mov    (%edx),%bl
  800b96:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b99:	80 3a 01             	cmpb   $0x1,(%edx)
  800b9c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b9f:	41                   	inc    %ecx
  800ba0:	39 f1                	cmp    %esi,%ecx
  800ba2:	75 f0                	jne    800b94 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ba4:	5b                   	pop    %ebx
  800ba5:	5e                   	pop    %esi
  800ba6:	5d                   	pop    %ebp
  800ba7:	c3                   	ret    

00800ba8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ba8:	55                   	push   %ebp
  800ba9:	89 e5                	mov    %esp,%ebp
  800bab:	56                   	push   %esi
  800bac:	53                   	push   %ebx
  800bad:	8b 75 08             	mov    0x8(%ebp),%esi
  800bb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb3:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800bb6:	85 d2                	test   %edx,%edx
  800bb8:	75 0a                	jne    800bc4 <strlcpy+0x1c>
  800bba:	89 f0                	mov    %esi,%eax
  800bbc:	eb 1a                	jmp    800bd8 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800bbe:	88 18                	mov    %bl,(%eax)
  800bc0:	40                   	inc    %eax
  800bc1:	41                   	inc    %ecx
  800bc2:	eb 02                	jmp    800bc6 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800bc4:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800bc6:	4a                   	dec    %edx
  800bc7:	74 0a                	je     800bd3 <strlcpy+0x2b>
  800bc9:	8a 19                	mov    (%ecx),%bl
  800bcb:	84 db                	test   %bl,%bl
  800bcd:	75 ef                	jne    800bbe <strlcpy+0x16>
  800bcf:	89 c2                	mov    %eax,%edx
  800bd1:	eb 02                	jmp    800bd5 <strlcpy+0x2d>
  800bd3:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800bd5:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800bd8:	29 f0                	sub    %esi,%eax
}
  800bda:	5b                   	pop    %ebx
  800bdb:	5e                   	pop    %esi
  800bdc:	5d                   	pop    %ebp
  800bdd:	c3                   	ret    

00800bde <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800be4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800be7:	eb 02                	jmp    800beb <strcmp+0xd>
		p++, q++;
  800be9:	41                   	inc    %ecx
  800bea:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800beb:	8a 01                	mov    (%ecx),%al
  800bed:	84 c0                	test   %al,%al
  800bef:	74 04                	je     800bf5 <strcmp+0x17>
  800bf1:	3a 02                	cmp    (%edx),%al
  800bf3:	74 f4                	je     800be9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800bf5:	0f b6 c0             	movzbl %al,%eax
  800bf8:	0f b6 12             	movzbl (%edx),%edx
  800bfb:	29 d0                	sub    %edx,%eax
}
  800bfd:	5d                   	pop    %ebp
  800bfe:	c3                   	ret    

00800bff <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800bff:	55                   	push   %ebp
  800c00:	89 e5                	mov    %esp,%ebp
  800c02:	53                   	push   %ebx
  800c03:	8b 45 08             	mov    0x8(%ebp),%eax
  800c06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c09:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800c0c:	eb 03                	jmp    800c11 <strncmp+0x12>
		n--, p++, q++;
  800c0e:	4a                   	dec    %edx
  800c0f:	40                   	inc    %eax
  800c10:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c11:	85 d2                	test   %edx,%edx
  800c13:	74 14                	je     800c29 <strncmp+0x2a>
  800c15:	8a 18                	mov    (%eax),%bl
  800c17:	84 db                	test   %bl,%bl
  800c19:	74 04                	je     800c1f <strncmp+0x20>
  800c1b:	3a 19                	cmp    (%ecx),%bl
  800c1d:	74 ef                	je     800c0e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c1f:	0f b6 00             	movzbl (%eax),%eax
  800c22:	0f b6 11             	movzbl (%ecx),%edx
  800c25:	29 d0                	sub    %edx,%eax
  800c27:	eb 05                	jmp    800c2e <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c29:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c2e:	5b                   	pop    %ebx
  800c2f:	5d                   	pop    %ebp
  800c30:	c3                   	ret    

00800c31 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c31:	55                   	push   %ebp
  800c32:	89 e5                	mov    %esp,%ebp
  800c34:	8b 45 08             	mov    0x8(%ebp),%eax
  800c37:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800c3a:	eb 05                	jmp    800c41 <strchr+0x10>
		if (*s == c)
  800c3c:	38 ca                	cmp    %cl,%dl
  800c3e:	74 0c                	je     800c4c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c40:	40                   	inc    %eax
  800c41:	8a 10                	mov    (%eax),%dl
  800c43:	84 d2                	test   %dl,%dl
  800c45:	75 f5                	jne    800c3c <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800c47:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c4c:	5d                   	pop    %ebp
  800c4d:	c3                   	ret    

00800c4e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c4e:	55                   	push   %ebp
  800c4f:	89 e5                	mov    %esp,%ebp
  800c51:	8b 45 08             	mov    0x8(%ebp),%eax
  800c54:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800c57:	eb 05                	jmp    800c5e <strfind+0x10>
		if (*s == c)
  800c59:	38 ca                	cmp    %cl,%dl
  800c5b:	74 07                	je     800c64 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c5d:	40                   	inc    %eax
  800c5e:	8a 10                	mov    (%eax),%dl
  800c60:	84 d2                	test   %dl,%dl
  800c62:	75 f5                	jne    800c59 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800c64:	5d                   	pop    %ebp
  800c65:	c3                   	ret    

00800c66 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c66:	55                   	push   %ebp
  800c67:	89 e5                	mov    %esp,%ebp
  800c69:	57                   	push   %edi
  800c6a:	56                   	push   %esi
  800c6b:	53                   	push   %ebx
  800c6c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c6f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c72:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c75:	85 c9                	test   %ecx,%ecx
  800c77:	74 30                	je     800ca9 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c79:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c7f:	75 25                	jne    800ca6 <memset+0x40>
  800c81:	f6 c1 03             	test   $0x3,%cl
  800c84:	75 20                	jne    800ca6 <memset+0x40>
		c &= 0xFF;
  800c86:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c89:	89 d3                	mov    %edx,%ebx
  800c8b:	c1 e3 08             	shl    $0x8,%ebx
  800c8e:	89 d6                	mov    %edx,%esi
  800c90:	c1 e6 18             	shl    $0x18,%esi
  800c93:	89 d0                	mov    %edx,%eax
  800c95:	c1 e0 10             	shl    $0x10,%eax
  800c98:	09 f0                	or     %esi,%eax
  800c9a:	09 d0                	or     %edx,%eax
  800c9c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c9e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ca1:	fc                   	cld    
  800ca2:	f3 ab                	rep stos %eax,%es:(%edi)
  800ca4:	eb 03                	jmp    800ca9 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ca6:	fc                   	cld    
  800ca7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ca9:	89 f8                	mov    %edi,%eax
  800cab:	5b                   	pop    %ebx
  800cac:	5e                   	pop    %esi
  800cad:	5f                   	pop    %edi
  800cae:	5d                   	pop    %ebp
  800caf:	c3                   	ret    

00800cb0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800cb0:	55                   	push   %ebp
  800cb1:	89 e5                	mov    %esp,%ebp
  800cb3:	57                   	push   %edi
  800cb4:	56                   	push   %esi
  800cb5:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cbb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800cbe:	39 c6                	cmp    %eax,%esi
  800cc0:	73 34                	jae    800cf6 <memmove+0x46>
  800cc2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800cc5:	39 d0                	cmp    %edx,%eax
  800cc7:	73 2d                	jae    800cf6 <memmove+0x46>
		s += n;
		d += n;
  800cc9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ccc:	f6 c2 03             	test   $0x3,%dl
  800ccf:	75 1b                	jne    800cec <memmove+0x3c>
  800cd1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800cd7:	75 13                	jne    800cec <memmove+0x3c>
  800cd9:	f6 c1 03             	test   $0x3,%cl
  800cdc:	75 0e                	jne    800cec <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800cde:	83 ef 04             	sub    $0x4,%edi
  800ce1:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ce4:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800ce7:	fd                   	std    
  800ce8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cea:	eb 07                	jmp    800cf3 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800cec:	4f                   	dec    %edi
  800ced:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800cf0:	fd                   	std    
  800cf1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800cf3:	fc                   	cld    
  800cf4:	eb 20                	jmp    800d16 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cf6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cfc:	75 13                	jne    800d11 <memmove+0x61>
  800cfe:	a8 03                	test   $0x3,%al
  800d00:	75 0f                	jne    800d11 <memmove+0x61>
  800d02:	f6 c1 03             	test   $0x3,%cl
  800d05:	75 0a                	jne    800d11 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800d07:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800d0a:	89 c7                	mov    %eax,%edi
  800d0c:	fc                   	cld    
  800d0d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d0f:	eb 05                	jmp    800d16 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d11:	89 c7                	mov    %eax,%edi
  800d13:	fc                   	cld    
  800d14:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d16:	5e                   	pop    %esi
  800d17:	5f                   	pop    %edi
  800d18:	5d                   	pop    %ebp
  800d19:	c3                   	ret    

00800d1a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d1a:	55                   	push   %ebp
  800d1b:	89 e5                	mov    %esp,%ebp
  800d1d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d20:	8b 45 10             	mov    0x10(%ebp),%eax
  800d23:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d27:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d2a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d31:	89 04 24             	mov    %eax,(%esp)
  800d34:	e8 77 ff ff ff       	call   800cb0 <memmove>
}
  800d39:	c9                   	leave  
  800d3a:	c3                   	ret    

00800d3b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	57                   	push   %edi
  800d3f:	56                   	push   %esi
  800d40:	53                   	push   %ebx
  800d41:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d44:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d47:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d4a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d4f:	eb 16                	jmp    800d67 <memcmp+0x2c>
		if (*s1 != *s2)
  800d51:	8a 04 17             	mov    (%edi,%edx,1),%al
  800d54:	42                   	inc    %edx
  800d55:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800d59:	38 c8                	cmp    %cl,%al
  800d5b:	74 0a                	je     800d67 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800d5d:	0f b6 c0             	movzbl %al,%eax
  800d60:	0f b6 c9             	movzbl %cl,%ecx
  800d63:	29 c8                	sub    %ecx,%eax
  800d65:	eb 09                	jmp    800d70 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d67:	39 da                	cmp    %ebx,%edx
  800d69:	75 e6                	jne    800d51 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d6b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d70:	5b                   	pop    %ebx
  800d71:	5e                   	pop    %esi
  800d72:	5f                   	pop    %edi
  800d73:	5d                   	pop    %ebp
  800d74:	c3                   	ret    

00800d75 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d75:	55                   	push   %ebp
  800d76:	89 e5                	mov    %esp,%ebp
  800d78:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800d7e:	89 c2                	mov    %eax,%edx
  800d80:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d83:	eb 05                	jmp    800d8a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d85:	38 08                	cmp    %cl,(%eax)
  800d87:	74 05                	je     800d8e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d89:	40                   	inc    %eax
  800d8a:	39 d0                	cmp    %edx,%eax
  800d8c:	72 f7                	jb     800d85 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d8e:	5d                   	pop    %ebp
  800d8f:	c3                   	ret    

00800d90 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
  800d93:	57                   	push   %edi
  800d94:	56                   	push   %esi
  800d95:	53                   	push   %ebx
  800d96:	8b 55 08             	mov    0x8(%ebp),%edx
  800d99:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d9c:	eb 01                	jmp    800d9f <strtol+0xf>
		s++;
  800d9e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d9f:	8a 02                	mov    (%edx),%al
  800da1:	3c 20                	cmp    $0x20,%al
  800da3:	74 f9                	je     800d9e <strtol+0xe>
  800da5:	3c 09                	cmp    $0x9,%al
  800da7:	74 f5                	je     800d9e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800da9:	3c 2b                	cmp    $0x2b,%al
  800dab:	75 08                	jne    800db5 <strtol+0x25>
		s++;
  800dad:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800dae:	bf 00 00 00 00       	mov    $0x0,%edi
  800db3:	eb 13                	jmp    800dc8 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800db5:	3c 2d                	cmp    $0x2d,%al
  800db7:	75 0a                	jne    800dc3 <strtol+0x33>
		s++, neg = 1;
  800db9:	8d 52 01             	lea    0x1(%edx),%edx
  800dbc:	bf 01 00 00 00       	mov    $0x1,%edi
  800dc1:	eb 05                	jmp    800dc8 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800dc3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800dc8:	85 db                	test   %ebx,%ebx
  800dca:	74 05                	je     800dd1 <strtol+0x41>
  800dcc:	83 fb 10             	cmp    $0x10,%ebx
  800dcf:	75 28                	jne    800df9 <strtol+0x69>
  800dd1:	8a 02                	mov    (%edx),%al
  800dd3:	3c 30                	cmp    $0x30,%al
  800dd5:	75 10                	jne    800de7 <strtol+0x57>
  800dd7:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ddb:	75 0a                	jne    800de7 <strtol+0x57>
		s += 2, base = 16;
  800ddd:	83 c2 02             	add    $0x2,%edx
  800de0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800de5:	eb 12                	jmp    800df9 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800de7:	85 db                	test   %ebx,%ebx
  800de9:	75 0e                	jne    800df9 <strtol+0x69>
  800deb:	3c 30                	cmp    $0x30,%al
  800ded:	75 05                	jne    800df4 <strtol+0x64>
		s++, base = 8;
  800def:	42                   	inc    %edx
  800df0:	b3 08                	mov    $0x8,%bl
  800df2:	eb 05                	jmp    800df9 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800df4:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800df9:	b8 00 00 00 00       	mov    $0x0,%eax
  800dfe:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e00:	8a 0a                	mov    (%edx),%cl
  800e02:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800e05:	80 fb 09             	cmp    $0x9,%bl
  800e08:	77 08                	ja     800e12 <strtol+0x82>
			dig = *s - '0';
  800e0a:	0f be c9             	movsbl %cl,%ecx
  800e0d:	83 e9 30             	sub    $0x30,%ecx
  800e10:	eb 1e                	jmp    800e30 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800e12:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800e15:	80 fb 19             	cmp    $0x19,%bl
  800e18:	77 08                	ja     800e22 <strtol+0x92>
			dig = *s - 'a' + 10;
  800e1a:	0f be c9             	movsbl %cl,%ecx
  800e1d:	83 e9 57             	sub    $0x57,%ecx
  800e20:	eb 0e                	jmp    800e30 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800e22:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800e25:	80 fb 19             	cmp    $0x19,%bl
  800e28:	77 12                	ja     800e3c <strtol+0xac>
			dig = *s - 'A' + 10;
  800e2a:	0f be c9             	movsbl %cl,%ecx
  800e2d:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800e30:	39 f1                	cmp    %esi,%ecx
  800e32:	7d 0c                	jge    800e40 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800e34:	42                   	inc    %edx
  800e35:	0f af c6             	imul   %esi,%eax
  800e38:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800e3a:	eb c4                	jmp    800e00 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800e3c:	89 c1                	mov    %eax,%ecx
  800e3e:	eb 02                	jmp    800e42 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800e40:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800e42:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e46:	74 05                	je     800e4d <strtol+0xbd>
		*endptr = (char *) s;
  800e48:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e4b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800e4d:	85 ff                	test   %edi,%edi
  800e4f:	74 04                	je     800e55 <strtol+0xc5>
  800e51:	89 c8                	mov    %ecx,%eax
  800e53:	f7 d8                	neg    %eax
}
  800e55:	5b                   	pop    %ebx
  800e56:	5e                   	pop    %esi
  800e57:	5f                   	pop    %edi
  800e58:	5d                   	pop    %ebp
  800e59:	c3                   	ret    
	...

00800e5c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e5c:	55                   	push   %ebp
  800e5d:	89 e5                	mov    %esp,%ebp
  800e5f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800e62:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800e69:	75 58                	jne    800ec3 <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.	
		//panic("set_pgfault_handler not implemented");
		
		if (sys_page_alloc(thisenv->env_id,(void *) (UXSTACKTOP - PGSIZE),(PTE_W|PTE_U|PTE_P)) != 0){
  800e6b:	a1 04 20 80 00       	mov    0x802004,%eax
  800e70:	8b 40 48             	mov    0x48(%eax),%eax
  800e73:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800e7a:	00 
  800e7b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800e82:	ee 
  800e83:	89 04 24             	mov    %eax,(%esp)
  800e86:	e8 fa f2 ff ff       	call   800185 <sys_page_alloc>
  800e8b:	85 c0                	test   %eax,%eax
  800e8d:	74 1c                	je     800eab <set_pgfault_handler+0x4f>
			panic("set_pg_fault_handler");
  800e8f:	c7 44 24 08 88 14 80 	movl   $0x801488,0x8(%esp)
  800e96:	00 
  800e97:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e9e:	00 
  800e9f:	c7 04 24 9d 14 80 00 	movl   $0x80149d,(%esp)
  800ea6:	e8 e9 f5 ff ff       	call   800494 <_panic>
		}
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  800eab:	a1 04 20 80 00       	mov    0x802004,%eax
  800eb0:	8b 40 48             	mov    0x48(%eax),%eax
  800eb3:	c7 44 24 04 70 04 80 	movl   $0x800470,0x4(%esp)
  800eba:	00 
  800ebb:	89 04 24             	mov    %eax,(%esp)
  800ebe:	e8 62 f4 ff ff       	call   800325 <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800ec3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec6:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800ecb:	c9                   	leave  
  800ecc:	c3                   	ret    
  800ecd:	00 00                	add    %al,(%eax)
	...

00800ed0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800ed0:	55                   	push   %ebp
  800ed1:	57                   	push   %edi
  800ed2:	56                   	push   %esi
  800ed3:	83 ec 10             	sub    $0x10,%esp
  800ed6:	8b 74 24 20          	mov    0x20(%esp),%esi
  800eda:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800ede:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ee2:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  800ee6:	89 cd                	mov    %ecx,%ebp
  800ee8:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800eec:	85 c0                	test   %eax,%eax
  800eee:	75 2c                	jne    800f1c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800ef0:	39 f9                	cmp    %edi,%ecx
  800ef2:	77 68                	ja     800f5c <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800ef4:	85 c9                	test   %ecx,%ecx
  800ef6:	75 0b                	jne    800f03 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800ef8:	b8 01 00 00 00       	mov    $0x1,%eax
  800efd:	31 d2                	xor    %edx,%edx
  800eff:	f7 f1                	div    %ecx
  800f01:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800f03:	31 d2                	xor    %edx,%edx
  800f05:	89 f8                	mov    %edi,%eax
  800f07:	f7 f1                	div    %ecx
  800f09:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f0b:	89 f0                	mov    %esi,%eax
  800f0d:	f7 f1                	div    %ecx
  800f0f:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800f11:	89 f0                	mov    %esi,%eax
  800f13:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800f15:	83 c4 10             	add    $0x10,%esp
  800f18:	5e                   	pop    %esi
  800f19:	5f                   	pop    %edi
  800f1a:	5d                   	pop    %ebp
  800f1b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800f1c:	39 f8                	cmp    %edi,%eax
  800f1e:	77 2c                	ja     800f4c <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800f20:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  800f23:	83 f6 1f             	xor    $0x1f,%esi
  800f26:	75 4c                	jne    800f74 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800f28:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800f2a:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800f2f:	72 0a                	jb     800f3b <__udivdi3+0x6b>
  800f31:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800f35:	0f 87 ad 00 00 00    	ja     800fe8 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800f3b:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800f40:	89 f0                	mov    %esi,%eax
  800f42:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800f44:	83 c4 10             	add    $0x10,%esp
  800f47:	5e                   	pop    %esi
  800f48:	5f                   	pop    %edi
  800f49:	5d                   	pop    %ebp
  800f4a:	c3                   	ret    
  800f4b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800f4c:	31 ff                	xor    %edi,%edi
  800f4e:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800f50:	89 f0                	mov    %esi,%eax
  800f52:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800f54:	83 c4 10             	add    $0x10,%esp
  800f57:	5e                   	pop    %esi
  800f58:	5f                   	pop    %edi
  800f59:	5d                   	pop    %ebp
  800f5a:	c3                   	ret    
  800f5b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f5c:	89 fa                	mov    %edi,%edx
  800f5e:	89 f0                	mov    %esi,%eax
  800f60:	f7 f1                	div    %ecx
  800f62:	89 c6                	mov    %eax,%esi
  800f64:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800f66:	89 f0                	mov    %esi,%eax
  800f68:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800f6a:	83 c4 10             	add    $0x10,%esp
  800f6d:	5e                   	pop    %esi
  800f6e:	5f                   	pop    %edi
  800f6f:	5d                   	pop    %ebp
  800f70:	c3                   	ret    
  800f71:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800f74:	89 f1                	mov    %esi,%ecx
  800f76:	d3 e0                	shl    %cl,%eax
  800f78:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800f7c:	b8 20 00 00 00       	mov    $0x20,%eax
  800f81:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800f83:	89 ea                	mov    %ebp,%edx
  800f85:	88 c1                	mov    %al,%cl
  800f87:	d3 ea                	shr    %cl,%edx
  800f89:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800f8d:	09 ca                	or     %ecx,%edx
  800f8f:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  800f93:	89 f1                	mov    %esi,%ecx
  800f95:	d3 e5                	shl    %cl,%ebp
  800f97:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  800f9b:	89 fd                	mov    %edi,%ebp
  800f9d:	88 c1                	mov    %al,%cl
  800f9f:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  800fa1:	89 fa                	mov    %edi,%edx
  800fa3:	89 f1                	mov    %esi,%ecx
  800fa5:	d3 e2                	shl    %cl,%edx
  800fa7:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fab:	88 c1                	mov    %al,%cl
  800fad:	d3 ef                	shr    %cl,%edi
  800faf:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800fb1:	89 f8                	mov    %edi,%eax
  800fb3:	89 ea                	mov    %ebp,%edx
  800fb5:	f7 74 24 08          	divl   0x8(%esp)
  800fb9:	89 d1                	mov    %edx,%ecx
  800fbb:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  800fbd:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800fc1:	39 d1                	cmp    %edx,%ecx
  800fc3:	72 17                	jb     800fdc <__udivdi3+0x10c>
  800fc5:	74 09                	je     800fd0 <__udivdi3+0x100>
  800fc7:	89 fe                	mov    %edi,%esi
  800fc9:	31 ff                	xor    %edi,%edi
  800fcb:	e9 41 ff ff ff       	jmp    800f11 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800fd0:	8b 54 24 04          	mov    0x4(%esp),%edx
  800fd4:	89 f1                	mov    %esi,%ecx
  800fd6:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800fd8:	39 c2                	cmp    %eax,%edx
  800fda:	73 eb                	jae    800fc7 <__udivdi3+0xf7>
		{
		  q0--;
  800fdc:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800fdf:	31 ff                	xor    %edi,%edi
  800fe1:	e9 2b ff ff ff       	jmp    800f11 <__udivdi3+0x41>
  800fe6:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800fe8:	31 f6                	xor    %esi,%esi
  800fea:	e9 22 ff ff ff       	jmp    800f11 <__udivdi3+0x41>
	...

00800ff0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800ff0:	55                   	push   %ebp
  800ff1:	57                   	push   %edi
  800ff2:	56                   	push   %esi
  800ff3:	83 ec 20             	sub    $0x20,%esp
  800ff6:	8b 44 24 30          	mov    0x30(%esp),%eax
  800ffa:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800ffe:	89 44 24 14          	mov    %eax,0x14(%esp)
  801002:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  801006:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80100a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80100e:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  801010:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801012:	85 ed                	test   %ebp,%ebp
  801014:	75 16                	jne    80102c <__umoddi3+0x3c>
    {
      if (d0 > n1)
  801016:	39 f1                	cmp    %esi,%ecx
  801018:	0f 86 a6 00 00 00    	jbe    8010c4 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80101e:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801020:	89 d0                	mov    %edx,%eax
  801022:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801024:	83 c4 20             	add    $0x20,%esp
  801027:	5e                   	pop    %esi
  801028:	5f                   	pop    %edi
  801029:	5d                   	pop    %ebp
  80102a:	c3                   	ret    
  80102b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80102c:	39 f5                	cmp    %esi,%ebp
  80102e:	0f 87 ac 00 00 00    	ja     8010e0 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801034:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  801037:	83 f0 1f             	xor    $0x1f,%eax
  80103a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80103e:	0f 84 a8 00 00 00    	je     8010ec <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801044:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801048:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80104a:	bf 20 00 00 00       	mov    $0x20,%edi
  80104f:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801053:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801057:	89 f9                	mov    %edi,%ecx
  801059:	d3 e8                	shr    %cl,%eax
  80105b:	09 e8                	or     %ebp,%eax
  80105d:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  801061:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801065:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801069:	d3 e0                	shl    %cl,%eax
  80106b:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80106f:	89 f2                	mov    %esi,%edx
  801071:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801073:	8b 44 24 14          	mov    0x14(%esp),%eax
  801077:	d3 e0                	shl    %cl,%eax
  801079:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80107d:	8b 44 24 14          	mov    0x14(%esp),%eax
  801081:	89 f9                	mov    %edi,%ecx
  801083:	d3 e8                	shr    %cl,%eax
  801085:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801087:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801089:	89 f2                	mov    %esi,%edx
  80108b:	f7 74 24 18          	divl   0x18(%esp)
  80108f:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801091:	f7 64 24 0c          	mull   0xc(%esp)
  801095:	89 c5                	mov    %eax,%ebp
  801097:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801099:	39 d6                	cmp    %edx,%esi
  80109b:	72 67                	jb     801104 <__umoddi3+0x114>
  80109d:	74 75                	je     801114 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80109f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8010a3:	29 e8                	sub    %ebp,%eax
  8010a5:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8010a7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8010ab:	d3 e8                	shr    %cl,%eax
  8010ad:	89 f2                	mov    %esi,%edx
  8010af:	89 f9                	mov    %edi,%ecx
  8010b1:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8010b3:	09 d0                	or     %edx,%eax
  8010b5:	89 f2                	mov    %esi,%edx
  8010b7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8010bb:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8010bd:	83 c4 20             	add    $0x20,%esp
  8010c0:	5e                   	pop    %esi
  8010c1:	5f                   	pop    %edi
  8010c2:	5d                   	pop    %ebp
  8010c3:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8010c4:	85 c9                	test   %ecx,%ecx
  8010c6:	75 0b                	jne    8010d3 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8010c8:	b8 01 00 00 00       	mov    $0x1,%eax
  8010cd:	31 d2                	xor    %edx,%edx
  8010cf:	f7 f1                	div    %ecx
  8010d1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8010d3:	89 f0                	mov    %esi,%eax
  8010d5:	31 d2                	xor    %edx,%edx
  8010d7:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8010d9:	89 f8                	mov    %edi,%eax
  8010db:	e9 3e ff ff ff       	jmp    80101e <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8010e0:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8010e2:	83 c4 20             	add    $0x20,%esp
  8010e5:	5e                   	pop    %esi
  8010e6:	5f                   	pop    %edi
  8010e7:	5d                   	pop    %ebp
  8010e8:	c3                   	ret    
  8010e9:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8010ec:	39 f5                	cmp    %esi,%ebp
  8010ee:	72 04                	jb     8010f4 <__umoddi3+0x104>
  8010f0:	39 f9                	cmp    %edi,%ecx
  8010f2:	77 06                	ja     8010fa <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8010f4:	89 f2                	mov    %esi,%edx
  8010f6:	29 cf                	sub    %ecx,%edi
  8010f8:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8010fa:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8010fc:	83 c4 20             	add    $0x20,%esp
  8010ff:	5e                   	pop    %esi
  801100:	5f                   	pop    %edi
  801101:	5d                   	pop    %ebp
  801102:	c3                   	ret    
  801103:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801104:	89 d1                	mov    %edx,%ecx
  801106:	89 c5                	mov    %eax,%ebp
  801108:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  80110c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801110:	eb 8d                	jmp    80109f <__umoddi3+0xaf>
  801112:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801114:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801118:	72 ea                	jb     801104 <__umoddi3+0x114>
  80111a:	89 f1                	mov    %esi,%ecx
  80111c:	eb 81                	jmp    80109f <__umoddi3+0xaf>
