
obj/user/softint.debug:     file format elf32-i386


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
  80002c:	e8 0b 00 00 00       	call   80003c <libmain>
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
	asm volatile("int $14");	// page fault
  800037:	cd 0e                	int    $0xe
}
  800039:	5d                   	pop    %ebp
  80003a:	c3                   	ret    
	...

0080003c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003c:	55                   	push   %ebp
  80003d:	89 e5                	mov    %esp,%ebp
  80003f:	56                   	push   %esi
  800040:	53                   	push   %ebx
  800041:	83 ec 10             	sub    $0x10,%esp
  800044:	8b 75 08             	mov    0x8(%ebp),%esi
  800047:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80004a:	e8 d8 00 00 00       	call   800127 <sys_getenvid>
  80004f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800054:	c1 e0 07             	shl    $0x7,%eax
  800057:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005c:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800061:	85 f6                	test   %esi,%esi
  800063:	7e 07                	jle    80006c <libmain+0x30>
		binaryname = argv[0];
  800065:	8b 03                	mov    (%ebx),%eax
  800067:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80006c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800070:	89 34 24             	mov    %esi,(%esp)
  800073:	e8 bc ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800078:	e8 07 00 00 00       	call   800084 <exit>
}
  80007d:	83 c4 10             	add    $0x10,%esp
  800080:	5b                   	pop    %ebx
  800081:	5e                   	pop    %esi
  800082:	5d                   	pop    %ebp
  800083:	c3                   	ret    

00800084 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800084:	55                   	push   %ebp
  800085:	89 e5                	mov    %esp,%ebp
  800087:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  80008a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800091:	e8 3f 00 00 00       	call   8000d5 <sys_env_destroy>
}
  800096:	c9                   	leave  
  800097:	c3                   	ret    

00800098 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800098:	55                   	push   %ebp
  800099:	89 e5                	mov    %esp,%ebp
  80009b:	57                   	push   %edi
  80009c:	56                   	push   %esi
  80009d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80009e:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a9:	89 c3                	mov    %eax,%ebx
  8000ab:	89 c7                	mov    %eax,%edi
  8000ad:	89 c6                	mov    %eax,%esi
  8000af:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b1:	5b                   	pop    %ebx
  8000b2:	5e                   	pop    %esi
  8000b3:	5f                   	pop    %edi
  8000b4:	5d                   	pop    %ebp
  8000b5:	c3                   	ret    

008000b6 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b6:	55                   	push   %ebp
  8000b7:	89 e5                	mov    %esp,%ebp
  8000b9:	57                   	push   %edi
  8000ba:	56                   	push   %esi
  8000bb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c6:	89 d1                	mov    %edx,%ecx
  8000c8:	89 d3                	mov    %edx,%ebx
  8000ca:	89 d7                	mov    %edx,%edi
  8000cc:	89 d6                	mov    %edx,%esi
  8000ce:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d0:	5b                   	pop    %ebx
  8000d1:	5e                   	pop    %esi
  8000d2:	5f                   	pop    %edi
  8000d3:	5d                   	pop    %ebp
  8000d4:	c3                   	ret    

008000d5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d5:	55                   	push   %ebp
  8000d6:	89 e5                	mov    %esp,%ebp
  8000d8:	57                   	push   %edi
  8000d9:	56                   	push   %esi
  8000da:	53                   	push   %ebx
  8000db:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000de:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e3:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000eb:	89 cb                	mov    %ecx,%ebx
  8000ed:	89 cf                	mov    %ecx,%edi
  8000ef:	89 ce                	mov    %ecx,%esi
  8000f1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000f3:	85 c0                	test   %eax,%eax
  8000f5:	7e 28                	jle    80011f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000fb:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800102:	00 
  800103:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  80010a:	00 
  80010b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800112:	00 
  800113:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  80011a:	e8 31 03 00 00       	call   800450 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011f:	83 c4 2c             	add    $0x2c,%esp
  800122:	5b                   	pop    %ebx
  800123:	5e                   	pop    %esi
  800124:	5f                   	pop    %edi
  800125:	5d                   	pop    %ebp
  800126:	c3                   	ret    

00800127 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800127:	55                   	push   %ebp
  800128:	89 e5                	mov    %esp,%ebp
  80012a:	57                   	push   %edi
  80012b:	56                   	push   %esi
  80012c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012d:	ba 00 00 00 00       	mov    $0x0,%edx
  800132:	b8 02 00 00 00       	mov    $0x2,%eax
  800137:	89 d1                	mov    %edx,%ecx
  800139:	89 d3                	mov    %edx,%ebx
  80013b:	89 d7                	mov    %edx,%edi
  80013d:	89 d6                	mov    %edx,%esi
  80013f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800141:	5b                   	pop    %ebx
  800142:	5e                   	pop    %esi
  800143:	5f                   	pop    %edi
  800144:	5d                   	pop    %ebp
  800145:	c3                   	ret    

00800146 <sys_yield>:

void
sys_yield(void)
{
  800146:	55                   	push   %ebp
  800147:	89 e5                	mov    %esp,%ebp
  800149:	57                   	push   %edi
  80014a:	56                   	push   %esi
  80014b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014c:	ba 00 00 00 00       	mov    $0x0,%edx
  800151:	b8 0b 00 00 00       	mov    $0xb,%eax
  800156:	89 d1                	mov    %edx,%ecx
  800158:	89 d3                	mov    %edx,%ebx
  80015a:	89 d7                	mov    %edx,%edi
  80015c:	89 d6                	mov    %edx,%esi
  80015e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800160:	5b                   	pop    %ebx
  800161:	5e                   	pop    %esi
  800162:	5f                   	pop    %edi
  800163:	5d                   	pop    %ebp
  800164:	c3                   	ret    

00800165 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	57                   	push   %edi
  800169:	56                   	push   %esi
  80016a:	53                   	push   %ebx
  80016b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016e:	be 00 00 00 00       	mov    $0x0,%esi
  800173:	b8 04 00 00 00       	mov    $0x4,%eax
  800178:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80017e:	8b 55 08             	mov    0x8(%ebp),%edx
  800181:	89 f7                	mov    %esi,%edi
  800183:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800185:	85 c0                	test   %eax,%eax
  800187:	7e 28                	jle    8001b1 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800189:	89 44 24 10          	mov    %eax,0x10(%esp)
  80018d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800194:	00 
  800195:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  80019c:	00 
  80019d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001a4:	00 
  8001a5:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  8001ac:	e8 9f 02 00 00       	call   800450 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001b1:	83 c4 2c             	add    $0x2c,%esp
  8001b4:	5b                   	pop    %ebx
  8001b5:	5e                   	pop    %esi
  8001b6:	5f                   	pop    %edi
  8001b7:	5d                   	pop    %ebp
  8001b8:	c3                   	ret    

008001b9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001b9:	55                   	push   %ebp
  8001ba:	89 e5                	mov    %esp,%ebp
  8001bc:	57                   	push   %edi
  8001bd:	56                   	push   %esi
  8001be:	53                   	push   %ebx
  8001bf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001c2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001c7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ca:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001cd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001d8:	85 c0                	test   %eax,%eax
  8001da:	7e 28                	jle    800204 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001dc:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001e0:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8001e7:	00 
  8001e8:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  8001ef:	00 
  8001f0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001f7:	00 
  8001f8:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  8001ff:	e8 4c 02 00 00       	call   800450 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800204:	83 c4 2c             	add    $0x2c,%esp
  800207:	5b                   	pop    %ebx
  800208:	5e                   	pop    %esi
  800209:	5f                   	pop    %edi
  80020a:	5d                   	pop    %ebp
  80020b:	c3                   	ret    

0080020c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
  80020f:	57                   	push   %edi
  800210:	56                   	push   %esi
  800211:	53                   	push   %ebx
  800212:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800215:	bb 00 00 00 00       	mov    $0x0,%ebx
  80021a:	b8 06 00 00 00       	mov    $0x6,%eax
  80021f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800222:	8b 55 08             	mov    0x8(%ebp),%edx
  800225:	89 df                	mov    %ebx,%edi
  800227:	89 de                	mov    %ebx,%esi
  800229:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80022b:	85 c0                	test   %eax,%eax
  80022d:	7e 28                	jle    800257 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80022f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800233:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80023a:	00 
  80023b:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  800242:	00 
  800243:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80024a:	00 
  80024b:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  800252:	e8 f9 01 00 00       	call   800450 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800257:	83 c4 2c             	add    $0x2c,%esp
  80025a:	5b                   	pop    %ebx
  80025b:	5e                   	pop    %esi
  80025c:	5f                   	pop    %edi
  80025d:	5d                   	pop    %ebp
  80025e:	c3                   	ret    

0080025f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80025f:	55                   	push   %ebp
  800260:	89 e5                	mov    %esp,%ebp
  800262:	57                   	push   %edi
  800263:	56                   	push   %esi
  800264:	53                   	push   %ebx
  800265:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800268:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026d:	b8 08 00 00 00       	mov    $0x8,%eax
  800272:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800275:	8b 55 08             	mov    0x8(%ebp),%edx
  800278:	89 df                	mov    %ebx,%edi
  80027a:	89 de                	mov    %ebx,%esi
  80027c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80027e:	85 c0                	test   %eax,%eax
  800280:	7e 28                	jle    8002aa <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800282:	89 44 24 10          	mov    %eax,0x10(%esp)
  800286:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80028d:	00 
  80028e:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  800295:	00 
  800296:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80029d:	00 
  80029e:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  8002a5:	e8 a6 01 00 00       	call   800450 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002aa:	83 c4 2c             	add    $0x2c,%esp
  8002ad:	5b                   	pop    %ebx
  8002ae:	5e                   	pop    %esi
  8002af:	5f                   	pop    %edi
  8002b0:	5d                   	pop    %ebp
  8002b1:	c3                   	ret    

008002b2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002b2:	55                   	push   %ebp
  8002b3:	89 e5                	mov    %esp,%ebp
  8002b5:	57                   	push   %edi
  8002b6:	56                   	push   %esi
  8002b7:	53                   	push   %ebx
  8002b8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002bb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c0:	b8 09 00 00 00       	mov    $0x9,%eax
  8002c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8002cb:	89 df                	mov    %ebx,%edi
  8002cd:	89 de                	mov    %ebx,%esi
  8002cf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002d1:	85 c0                	test   %eax,%eax
  8002d3:	7e 28                	jle    8002fd <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002d9:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002e0:	00 
  8002e1:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  8002e8:	00 
  8002e9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002f0:	00 
  8002f1:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  8002f8:	e8 53 01 00 00       	call   800450 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002fd:	83 c4 2c             	add    $0x2c,%esp
  800300:	5b                   	pop    %ebx
  800301:	5e                   	pop    %esi
  800302:	5f                   	pop    %edi
  800303:	5d                   	pop    %ebp
  800304:	c3                   	ret    

00800305 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	57                   	push   %edi
  800309:	56                   	push   %esi
  80030a:	53                   	push   %ebx
  80030b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80030e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800313:	b8 0a 00 00 00       	mov    $0xa,%eax
  800318:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80031b:	8b 55 08             	mov    0x8(%ebp),%edx
  80031e:	89 df                	mov    %ebx,%edi
  800320:	89 de                	mov    %ebx,%esi
  800322:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800324:	85 c0                	test   %eax,%eax
  800326:	7e 28                	jle    800350 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800328:	89 44 24 10          	mov    %eax,0x10(%esp)
  80032c:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800333:	00 
  800334:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  80033b:	00 
  80033c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800343:	00 
  800344:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  80034b:	e8 00 01 00 00       	call   800450 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800350:	83 c4 2c             	add    $0x2c,%esp
  800353:	5b                   	pop    %ebx
  800354:	5e                   	pop    %esi
  800355:	5f                   	pop    %edi
  800356:	5d                   	pop    %ebp
  800357:	c3                   	ret    

00800358 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800358:	55                   	push   %ebp
  800359:	89 e5                	mov    %esp,%ebp
  80035b:	57                   	push   %edi
  80035c:	56                   	push   %esi
  80035d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80035e:	be 00 00 00 00       	mov    $0x0,%esi
  800363:	b8 0c 00 00 00       	mov    $0xc,%eax
  800368:	8b 7d 14             	mov    0x14(%ebp),%edi
  80036b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80036e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800371:	8b 55 08             	mov    0x8(%ebp),%edx
  800374:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800376:	5b                   	pop    %ebx
  800377:	5e                   	pop    %esi
  800378:	5f                   	pop    %edi
  800379:	5d                   	pop    %ebp
  80037a:	c3                   	ret    

0080037b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80037b:	55                   	push   %ebp
  80037c:	89 e5                	mov    %esp,%ebp
  80037e:	57                   	push   %edi
  80037f:	56                   	push   %esi
  800380:	53                   	push   %ebx
  800381:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800384:	b9 00 00 00 00       	mov    $0x0,%ecx
  800389:	b8 0d 00 00 00       	mov    $0xd,%eax
  80038e:	8b 55 08             	mov    0x8(%ebp),%edx
  800391:	89 cb                	mov    %ecx,%ebx
  800393:	89 cf                	mov    %ecx,%edi
  800395:	89 ce                	mov    %ecx,%esi
  800397:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800399:	85 c0                	test   %eax,%eax
  80039b:	7e 28                	jle    8003c5 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80039d:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003a1:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003a8:	00 
  8003a9:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  8003b0:	00 
  8003b1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003b8:	00 
  8003b9:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  8003c0:	e8 8b 00 00 00       	call   800450 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003c5:	83 c4 2c             	add    $0x2c,%esp
  8003c8:	5b                   	pop    %ebx
  8003c9:	5e                   	pop    %esi
  8003ca:	5f                   	pop    %edi
  8003cb:	5d                   	pop    %ebp
  8003cc:	c3                   	ret    

008003cd <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8003cd:	55                   	push   %ebp
  8003ce:	89 e5                	mov    %esp,%ebp
  8003d0:	57                   	push   %edi
  8003d1:	56                   	push   %esi
  8003d2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8003d8:	b8 0e 00 00 00       	mov    $0xe,%eax
  8003dd:	89 d1                	mov    %edx,%ecx
  8003df:	89 d3                	mov    %edx,%ebx
  8003e1:	89 d7                	mov    %edx,%edi
  8003e3:	89 d6                	mov    %edx,%esi
  8003e5:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8003e7:	5b                   	pop    %ebx
  8003e8:	5e                   	pop    %esi
  8003e9:	5f                   	pop    %edi
  8003ea:	5d                   	pop    %ebp
  8003eb:	c3                   	ret    

008003ec <sys_e1000_transmit>:

int 
sys_e1000_transmit(char* pck, size_t length){
  8003ec:	55                   	push   %ebp
  8003ed:	89 e5                	mov    %esp,%ebp
  8003ef:	57                   	push   %edi
  8003f0:	56                   	push   %esi
  8003f1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003f2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003f7:	b8 10 00 00 00       	mov    $0x10,%eax
  8003fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003ff:	8b 55 08             	mov    0x8(%ebp),%edx
  800402:	89 df                	mov    %ebx,%edi
  800404:	89 de                	mov    %ebx,%esi
  800406:	cd 30                	int    $0x30
}

int 
sys_e1000_transmit(char* pck, size_t length){
	return syscall(SYS_e1000_transmit, 0, (uint32_t)pck, length, 0, 0, 0);
}
  800408:	5b                   	pop    %ebx
  800409:	5e                   	pop    %esi
  80040a:	5f                   	pop    %edi
  80040b:	5d                   	pop    %ebp
  80040c:	c3                   	ret    

0080040d <sys_e1000_receive>:

int 
sys_e1000_receive(char* pck, size_t* length){
  80040d:	55                   	push   %ebp
  80040e:	89 e5                	mov    %esp,%ebp
  800410:	57                   	push   %edi
  800411:	56                   	push   %esi
  800412:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800413:	bb 00 00 00 00       	mov    $0x0,%ebx
  800418:	b8 0f 00 00 00       	mov    $0xf,%eax
  80041d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800420:	8b 55 08             	mov    0x8(%ebp),%edx
  800423:	89 df                	mov    %ebx,%edi
  800425:	89 de                	mov    %ebx,%esi
  800427:	cd 30                	int    $0x30
}

int 
sys_e1000_receive(char* pck, size_t* length){
	return syscall(SYS_e1000_receive, 0, (uint32_t)pck, (uint32_t)length, 0, 0, 0);
}
  800429:	5b                   	pop    %ebx
  80042a:	5e                   	pop    %esi
  80042b:	5f                   	pop    %edi
  80042c:	5d                   	pop    %ebp
  80042d:	c3                   	ret    

0080042e <sys_e1000_get_mac>:

int 
sys_e1000_get_mac(uint8_t* mac_addr){
  80042e:	55                   	push   %ebp
  80042f:	89 e5                	mov    %esp,%ebp
  800431:	57                   	push   %edi
  800432:	56                   	push   %esi
  800433:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800434:	b9 00 00 00 00       	mov    $0x0,%ecx
  800439:	b8 11 00 00 00       	mov    $0x11,%eax
  80043e:	8b 55 08             	mov    0x8(%ebp),%edx
  800441:	89 cb                	mov    %ecx,%ebx
  800443:	89 cf                	mov    %ecx,%edi
  800445:	89 ce                	mov    %ecx,%esi
  800447:	cd 30                	int    $0x30
}

int 
sys_e1000_get_mac(uint8_t* mac_addr){
	return syscall(SYS_e1000_get_mac, 0, (uint32_t)mac_addr, 0, 0, 0, 0);
}
  800449:	5b                   	pop    %ebx
  80044a:	5e                   	pop    %esi
  80044b:	5f                   	pop    %edi
  80044c:	5d                   	pop    %ebp
  80044d:	c3                   	ret    
	...

00800450 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800450:	55                   	push   %ebp
  800451:	89 e5                	mov    %esp,%ebp
  800453:	56                   	push   %esi
  800454:	53                   	push   %ebx
  800455:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800458:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80045b:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800461:	e8 c1 fc ff ff       	call   800127 <sys_getenvid>
  800466:	8b 55 0c             	mov    0xc(%ebp),%edx
  800469:	89 54 24 10          	mov    %edx,0x10(%esp)
  80046d:	8b 55 08             	mov    0x8(%ebp),%edx
  800470:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800474:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800478:	89 44 24 04          	mov    %eax,0x4(%esp)
  80047c:	c7 04 24 b8 10 80 00 	movl   $0x8010b8,(%esp)
  800483:	e8 c0 00 00 00       	call   800548 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800488:	89 74 24 04          	mov    %esi,0x4(%esp)
  80048c:	8b 45 10             	mov    0x10(%ebp),%eax
  80048f:	89 04 24             	mov    %eax,(%esp)
  800492:	e8 50 00 00 00       	call   8004e7 <vcprintf>
	cprintf("\n");
  800497:	c7 04 24 db 10 80 00 	movl   $0x8010db,(%esp)
  80049e:	e8 a5 00 00 00       	call   800548 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004a3:	cc                   	int3   
  8004a4:	eb fd                	jmp    8004a3 <_panic+0x53>
	...

008004a8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004a8:	55                   	push   %ebp
  8004a9:	89 e5                	mov    %esp,%ebp
  8004ab:	53                   	push   %ebx
  8004ac:	83 ec 14             	sub    $0x14,%esp
  8004af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8004b2:	8b 03                	mov    (%ebx),%eax
  8004b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8004b7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8004bb:	40                   	inc    %eax
  8004bc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8004be:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004c3:	75 19                	jne    8004de <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8004c5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8004cc:	00 
  8004cd:	8d 43 08             	lea    0x8(%ebx),%eax
  8004d0:	89 04 24             	mov    %eax,(%esp)
  8004d3:	e8 c0 fb ff ff       	call   800098 <sys_cputs>
		b->idx = 0;
  8004d8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8004de:	ff 43 04             	incl   0x4(%ebx)
}
  8004e1:	83 c4 14             	add    $0x14,%esp
  8004e4:	5b                   	pop    %ebx
  8004e5:	5d                   	pop    %ebp
  8004e6:	c3                   	ret    

008004e7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004e7:	55                   	push   %ebp
  8004e8:	89 e5                	mov    %esp,%ebp
  8004ea:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8004f0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004f7:	00 00 00 
	b.cnt = 0;
  8004fa:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800501:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800504:	8b 45 0c             	mov    0xc(%ebp),%eax
  800507:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80050b:	8b 45 08             	mov    0x8(%ebp),%eax
  80050e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800512:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800518:	89 44 24 04          	mov    %eax,0x4(%esp)
  80051c:	c7 04 24 a8 04 80 00 	movl   $0x8004a8,(%esp)
  800523:	e8 82 01 00 00       	call   8006aa <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800528:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80052e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800532:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800538:	89 04 24             	mov    %eax,(%esp)
  80053b:	e8 58 fb ff ff       	call   800098 <sys_cputs>

	return b.cnt;
}
  800540:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800546:	c9                   	leave  
  800547:	c3                   	ret    

00800548 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800548:	55                   	push   %ebp
  800549:	89 e5                	mov    %esp,%ebp
  80054b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80054e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800551:	89 44 24 04          	mov    %eax,0x4(%esp)
  800555:	8b 45 08             	mov    0x8(%ebp),%eax
  800558:	89 04 24             	mov    %eax,(%esp)
  80055b:	e8 87 ff ff ff       	call   8004e7 <vcprintf>
	va_end(ap);

	return cnt;
}
  800560:	c9                   	leave  
  800561:	c3                   	ret    
	...

00800564 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800564:	55                   	push   %ebp
  800565:	89 e5                	mov    %esp,%ebp
  800567:	57                   	push   %edi
  800568:	56                   	push   %esi
  800569:	53                   	push   %ebx
  80056a:	83 ec 3c             	sub    $0x3c,%esp
  80056d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800570:	89 d7                	mov    %edx,%edi
  800572:	8b 45 08             	mov    0x8(%ebp),%eax
  800575:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800578:	8b 45 0c             	mov    0xc(%ebp),%eax
  80057b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80057e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800581:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800584:	85 c0                	test   %eax,%eax
  800586:	75 08                	jne    800590 <printnum+0x2c>
  800588:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80058b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80058e:	77 57                	ja     8005e7 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800590:	89 74 24 10          	mov    %esi,0x10(%esp)
  800594:	4b                   	dec    %ebx
  800595:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800599:	8b 45 10             	mov    0x10(%ebp),%eax
  80059c:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005a0:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8005a4:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8005a8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005af:	00 
  8005b0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005b3:	89 04 24             	mov    %eax,(%esp)
  8005b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005bd:	e8 56 08 00 00       	call   800e18 <__udivdi3>
  8005c2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005c6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8005ca:	89 04 24             	mov    %eax,(%esp)
  8005cd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005d1:	89 fa                	mov    %edi,%edx
  8005d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005d6:	e8 89 ff ff ff       	call   800564 <printnum>
  8005db:	eb 0f                	jmp    8005ec <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8005dd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005e1:	89 34 24             	mov    %esi,(%esp)
  8005e4:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005e7:	4b                   	dec    %ebx
  8005e8:	85 db                	test   %ebx,%ebx
  8005ea:	7f f1                	jg     8005dd <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8005ec:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005f0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8005f4:	8b 45 10             	mov    0x10(%ebp),%eax
  8005f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005fb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800602:	00 
  800603:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800606:	89 04 24             	mov    %eax,(%esp)
  800609:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80060c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800610:	e8 23 09 00 00       	call   800f38 <__umoddi3>
  800615:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800619:	0f be 80 dd 10 80 00 	movsbl 0x8010dd(%eax),%eax
  800620:	89 04 24             	mov    %eax,(%esp)
  800623:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800626:	83 c4 3c             	add    $0x3c,%esp
  800629:	5b                   	pop    %ebx
  80062a:	5e                   	pop    %esi
  80062b:	5f                   	pop    %edi
  80062c:	5d                   	pop    %ebp
  80062d:	c3                   	ret    

0080062e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80062e:	55                   	push   %ebp
  80062f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800631:	83 fa 01             	cmp    $0x1,%edx
  800634:	7e 0e                	jle    800644 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800636:	8b 10                	mov    (%eax),%edx
  800638:	8d 4a 08             	lea    0x8(%edx),%ecx
  80063b:	89 08                	mov    %ecx,(%eax)
  80063d:	8b 02                	mov    (%edx),%eax
  80063f:	8b 52 04             	mov    0x4(%edx),%edx
  800642:	eb 22                	jmp    800666 <getuint+0x38>
	else if (lflag)
  800644:	85 d2                	test   %edx,%edx
  800646:	74 10                	je     800658 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800648:	8b 10                	mov    (%eax),%edx
  80064a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80064d:	89 08                	mov    %ecx,(%eax)
  80064f:	8b 02                	mov    (%edx),%eax
  800651:	ba 00 00 00 00       	mov    $0x0,%edx
  800656:	eb 0e                	jmp    800666 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800658:	8b 10                	mov    (%eax),%edx
  80065a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80065d:	89 08                	mov    %ecx,(%eax)
  80065f:	8b 02                	mov    (%edx),%eax
  800661:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800666:	5d                   	pop    %ebp
  800667:	c3                   	ret    

00800668 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800668:	55                   	push   %ebp
  800669:	89 e5                	mov    %esp,%ebp
  80066b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80066e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800671:	8b 10                	mov    (%eax),%edx
  800673:	3b 50 04             	cmp    0x4(%eax),%edx
  800676:	73 08                	jae    800680 <sprintputch+0x18>
		*b->buf++ = ch;
  800678:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80067b:	88 0a                	mov    %cl,(%edx)
  80067d:	42                   	inc    %edx
  80067e:	89 10                	mov    %edx,(%eax)
}
  800680:	5d                   	pop    %ebp
  800681:	c3                   	ret    

00800682 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800682:	55                   	push   %ebp
  800683:	89 e5                	mov    %esp,%ebp
  800685:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800688:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80068b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80068f:	8b 45 10             	mov    0x10(%ebp),%eax
  800692:	89 44 24 08          	mov    %eax,0x8(%esp)
  800696:	8b 45 0c             	mov    0xc(%ebp),%eax
  800699:	89 44 24 04          	mov    %eax,0x4(%esp)
  80069d:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a0:	89 04 24             	mov    %eax,(%esp)
  8006a3:	e8 02 00 00 00       	call   8006aa <vprintfmt>
	va_end(ap);
}
  8006a8:	c9                   	leave  
  8006a9:	c3                   	ret    

008006aa <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006aa:	55                   	push   %ebp
  8006ab:	89 e5                	mov    %esp,%ebp
  8006ad:	57                   	push   %edi
  8006ae:	56                   	push   %esi
  8006af:	53                   	push   %ebx
  8006b0:	83 ec 4c             	sub    $0x4c,%esp
  8006b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006b6:	8b 75 10             	mov    0x10(%ebp),%esi
  8006b9:	eb 12                	jmp    8006cd <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006bb:	85 c0                	test   %eax,%eax
  8006bd:	0f 84 6b 03 00 00    	je     800a2e <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8006c3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c7:	89 04 24             	mov    %eax,(%esp)
  8006ca:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006cd:	0f b6 06             	movzbl (%esi),%eax
  8006d0:	46                   	inc    %esi
  8006d1:	83 f8 25             	cmp    $0x25,%eax
  8006d4:	75 e5                	jne    8006bb <vprintfmt+0x11>
  8006d6:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8006da:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8006e1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8006e6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8006ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f2:	eb 26                	jmp    80071a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f4:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8006f7:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8006fb:	eb 1d                	jmp    80071a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006fd:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800700:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800704:	eb 14                	jmp    80071a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800706:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800709:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800710:	eb 08                	jmp    80071a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800712:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800715:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80071a:	0f b6 06             	movzbl (%esi),%eax
  80071d:	8d 56 01             	lea    0x1(%esi),%edx
  800720:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800723:	8a 16                	mov    (%esi),%dl
  800725:	83 ea 23             	sub    $0x23,%edx
  800728:	80 fa 55             	cmp    $0x55,%dl
  80072b:	0f 87 e1 02 00 00    	ja     800a12 <vprintfmt+0x368>
  800731:	0f b6 d2             	movzbl %dl,%edx
  800734:	ff 24 95 20 12 80 00 	jmp    *0x801220(,%edx,4)
  80073b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80073e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800743:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800746:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80074a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80074d:	8d 50 d0             	lea    -0x30(%eax),%edx
  800750:	83 fa 09             	cmp    $0x9,%edx
  800753:	77 2a                	ja     80077f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800755:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800756:	eb eb                	jmp    800743 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800758:	8b 45 14             	mov    0x14(%ebp),%eax
  80075b:	8d 50 04             	lea    0x4(%eax),%edx
  80075e:	89 55 14             	mov    %edx,0x14(%ebp)
  800761:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800763:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800766:	eb 17                	jmp    80077f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800768:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80076c:	78 98                	js     800706 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80076e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800771:	eb a7                	jmp    80071a <vprintfmt+0x70>
  800773:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800776:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80077d:	eb 9b                	jmp    80071a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80077f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800783:	79 95                	jns    80071a <vprintfmt+0x70>
  800785:	eb 8b                	jmp    800712 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800787:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800788:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80078b:	eb 8d                	jmp    80071a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80078d:	8b 45 14             	mov    0x14(%ebp),%eax
  800790:	8d 50 04             	lea    0x4(%eax),%edx
  800793:	89 55 14             	mov    %edx,0x14(%ebp)
  800796:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80079a:	8b 00                	mov    (%eax),%eax
  80079c:	89 04 24             	mov    %eax,(%esp)
  80079f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8007a5:	e9 23 ff ff ff       	jmp    8006cd <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8007aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ad:	8d 50 04             	lea    0x4(%eax),%edx
  8007b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8007b3:	8b 00                	mov    (%eax),%eax
  8007b5:	85 c0                	test   %eax,%eax
  8007b7:	79 02                	jns    8007bb <vprintfmt+0x111>
  8007b9:	f7 d8                	neg    %eax
  8007bb:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8007bd:	83 f8 11             	cmp    $0x11,%eax
  8007c0:	7f 0b                	jg     8007cd <vprintfmt+0x123>
  8007c2:	8b 04 85 80 13 80 00 	mov    0x801380(,%eax,4),%eax
  8007c9:	85 c0                	test   %eax,%eax
  8007cb:	75 23                	jne    8007f0 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8007cd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007d1:	c7 44 24 08 f5 10 80 	movl   $0x8010f5,0x8(%esp)
  8007d8:	00 
  8007d9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e0:	89 04 24             	mov    %eax,(%esp)
  8007e3:	e8 9a fe ff ff       	call   800682 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007e8:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8007eb:	e9 dd fe ff ff       	jmp    8006cd <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8007f0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007f4:	c7 44 24 08 fe 10 80 	movl   $0x8010fe,0x8(%esp)
  8007fb:	00 
  8007fc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800800:	8b 55 08             	mov    0x8(%ebp),%edx
  800803:	89 14 24             	mov    %edx,(%esp)
  800806:	e8 77 fe ff ff       	call   800682 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80080b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80080e:	e9 ba fe ff ff       	jmp    8006cd <vprintfmt+0x23>
  800813:	89 f9                	mov    %edi,%ecx
  800815:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800818:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80081b:	8b 45 14             	mov    0x14(%ebp),%eax
  80081e:	8d 50 04             	lea    0x4(%eax),%edx
  800821:	89 55 14             	mov    %edx,0x14(%ebp)
  800824:	8b 30                	mov    (%eax),%esi
  800826:	85 f6                	test   %esi,%esi
  800828:	75 05                	jne    80082f <vprintfmt+0x185>
				p = "(null)";
  80082a:	be ee 10 80 00       	mov    $0x8010ee,%esi
			if (width > 0 && padc != '-')
  80082f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800833:	0f 8e 84 00 00 00    	jle    8008bd <vprintfmt+0x213>
  800839:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80083d:	74 7e                	je     8008bd <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80083f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800843:	89 34 24             	mov    %esi,(%esp)
  800846:	e8 8b 02 00 00       	call   800ad6 <strnlen>
  80084b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80084e:	29 c2                	sub    %eax,%edx
  800850:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800853:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800857:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80085a:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80085d:	89 de                	mov    %ebx,%esi
  80085f:	89 d3                	mov    %edx,%ebx
  800861:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800863:	eb 0b                	jmp    800870 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800865:	89 74 24 04          	mov    %esi,0x4(%esp)
  800869:	89 3c 24             	mov    %edi,(%esp)
  80086c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80086f:	4b                   	dec    %ebx
  800870:	85 db                	test   %ebx,%ebx
  800872:	7f f1                	jg     800865 <vprintfmt+0x1bb>
  800874:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800877:	89 f3                	mov    %esi,%ebx
  800879:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80087c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80087f:	85 c0                	test   %eax,%eax
  800881:	79 05                	jns    800888 <vprintfmt+0x1de>
  800883:	b8 00 00 00 00       	mov    $0x0,%eax
  800888:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80088b:	29 c2                	sub    %eax,%edx
  80088d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800890:	eb 2b                	jmp    8008bd <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800892:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800896:	74 18                	je     8008b0 <vprintfmt+0x206>
  800898:	8d 50 e0             	lea    -0x20(%eax),%edx
  80089b:	83 fa 5e             	cmp    $0x5e,%edx
  80089e:	76 10                	jbe    8008b0 <vprintfmt+0x206>
					putch('?', putdat);
  8008a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008a4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8008ab:	ff 55 08             	call   *0x8(%ebp)
  8008ae:	eb 0a                	jmp    8008ba <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8008b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008b4:	89 04 24             	mov    %eax,(%esp)
  8008b7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008ba:	ff 4d e4             	decl   -0x1c(%ebp)
  8008bd:	0f be 06             	movsbl (%esi),%eax
  8008c0:	46                   	inc    %esi
  8008c1:	85 c0                	test   %eax,%eax
  8008c3:	74 21                	je     8008e6 <vprintfmt+0x23c>
  8008c5:	85 ff                	test   %edi,%edi
  8008c7:	78 c9                	js     800892 <vprintfmt+0x1e8>
  8008c9:	4f                   	dec    %edi
  8008ca:	79 c6                	jns    800892 <vprintfmt+0x1e8>
  8008cc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008cf:	89 de                	mov    %ebx,%esi
  8008d1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8008d4:	eb 18                	jmp    8008ee <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8008d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008da:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8008e1:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8008e3:	4b                   	dec    %ebx
  8008e4:	eb 08                	jmp    8008ee <vprintfmt+0x244>
  8008e6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e9:	89 de                	mov    %ebx,%esi
  8008eb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8008ee:	85 db                	test   %ebx,%ebx
  8008f0:	7f e4                	jg     8008d6 <vprintfmt+0x22c>
  8008f2:	89 7d 08             	mov    %edi,0x8(%ebp)
  8008f5:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008f7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008fa:	e9 ce fd ff ff       	jmp    8006cd <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008ff:	83 f9 01             	cmp    $0x1,%ecx
  800902:	7e 10                	jle    800914 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800904:	8b 45 14             	mov    0x14(%ebp),%eax
  800907:	8d 50 08             	lea    0x8(%eax),%edx
  80090a:	89 55 14             	mov    %edx,0x14(%ebp)
  80090d:	8b 30                	mov    (%eax),%esi
  80090f:	8b 78 04             	mov    0x4(%eax),%edi
  800912:	eb 26                	jmp    80093a <vprintfmt+0x290>
	else if (lflag)
  800914:	85 c9                	test   %ecx,%ecx
  800916:	74 12                	je     80092a <vprintfmt+0x280>
		return va_arg(*ap, long);
  800918:	8b 45 14             	mov    0x14(%ebp),%eax
  80091b:	8d 50 04             	lea    0x4(%eax),%edx
  80091e:	89 55 14             	mov    %edx,0x14(%ebp)
  800921:	8b 30                	mov    (%eax),%esi
  800923:	89 f7                	mov    %esi,%edi
  800925:	c1 ff 1f             	sar    $0x1f,%edi
  800928:	eb 10                	jmp    80093a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80092a:	8b 45 14             	mov    0x14(%ebp),%eax
  80092d:	8d 50 04             	lea    0x4(%eax),%edx
  800930:	89 55 14             	mov    %edx,0x14(%ebp)
  800933:	8b 30                	mov    (%eax),%esi
  800935:	89 f7                	mov    %esi,%edi
  800937:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80093a:	85 ff                	test   %edi,%edi
  80093c:	78 0a                	js     800948 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80093e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800943:	e9 8c 00 00 00       	jmp    8009d4 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800948:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80094c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800953:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800956:	f7 de                	neg    %esi
  800958:	83 d7 00             	adc    $0x0,%edi
  80095b:	f7 df                	neg    %edi
			}
			base = 10;
  80095d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800962:	eb 70                	jmp    8009d4 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800964:	89 ca                	mov    %ecx,%edx
  800966:	8d 45 14             	lea    0x14(%ebp),%eax
  800969:	e8 c0 fc ff ff       	call   80062e <getuint>
  80096e:	89 c6                	mov    %eax,%esi
  800970:	89 d7                	mov    %edx,%edi
			base = 10;
  800972:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800977:	eb 5b                	jmp    8009d4 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  800979:	89 ca                	mov    %ecx,%edx
  80097b:	8d 45 14             	lea    0x14(%ebp),%eax
  80097e:	e8 ab fc ff ff       	call   80062e <getuint>
  800983:	89 c6                	mov    %eax,%esi
  800985:	89 d7                	mov    %edx,%edi
			base = 8;
  800987:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80098c:	eb 46                	jmp    8009d4 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  80098e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800992:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800999:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80099c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009a0:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8009a7:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8009aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8009ad:	8d 50 04             	lea    0x4(%eax),%edx
  8009b0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8009b3:	8b 30                	mov    (%eax),%esi
  8009b5:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8009ba:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8009bf:	eb 13                	jmp    8009d4 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8009c1:	89 ca                	mov    %ecx,%edx
  8009c3:	8d 45 14             	lea    0x14(%ebp),%eax
  8009c6:	e8 63 fc ff ff       	call   80062e <getuint>
  8009cb:	89 c6                	mov    %eax,%esi
  8009cd:	89 d7                	mov    %edx,%edi
			base = 16;
  8009cf:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8009d4:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8009d8:	89 54 24 10          	mov    %edx,0x10(%esp)
  8009dc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8009df:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8009e3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009e7:	89 34 24             	mov    %esi,(%esp)
  8009ea:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009ee:	89 da                	mov    %ebx,%edx
  8009f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f3:	e8 6c fb ff ff       	call   800564 <printnum>
			break;
  8009f8:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8009fb:	e9 cd fc ff ff       	jmp    8006cd <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a00:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a04:	89 04 24             	mov    %eax,(%esp)
  800a07:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a0a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a0d:	e9 bb fc ff ff       	jmp    8006cd <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a12:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a16:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a1d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a20:	eb 01                	jmp    800a23 <vprintfmt+0x379>
  800a22:	4e                   	dec    %esi
  800a23:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800a27:	75 f9                	jne    800a22 <vprintfmt+0x378>
  800a29:	e9 9f fc ff ff       	jmp    8006cd <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800a2e:	83 c4 4c             	add    $0x4c,%esp
  800a31:	5b                   	pop    %ebx
  800a32:	5e                   	pop    %esi
  800a33:	5f                   	pop    %edi
  800a34:	5d                   	pop    %ebp
  800a35:	c3                   	ret    

00800a36 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a36:	55                   	push   %ebp
  800a37:	89 e5                	mov    %esp,%ebp
  800a39:	83 ec 28             	sub    $0x28,%esp
  800a3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a42:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a45:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a49:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a4c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a53:	85 c0                	test   %eax,%eax
  800a55:	74 30                	je     800a87 <vsnprintf+0x51>
  800a57:	85 d2                	test   %edx,%edx
  800a59:	7e 33                	jle    800a8e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a5b:	8b 45 14             	mov    0x14(%ebp),%eax
  800a5e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a62:	8b 45 10             	mov    0x10(%ebp),%eax
  800a65:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a69:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a6c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a70:	c7 04 24 68 06 80 00 	movl   $0x800668,(%esp)
  800a77:	e8 2e fc ff ff       	call   8006aa <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a7c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a7f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a85:	eb 0c                	jmp    800a93 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a87:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a8c:	eb 05                	jmp    800a93 <vsnprintf+0x5d>
  800a8e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a93:	c9                   	leave  
  800a94:	c3                   	ret    

00800a95 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a95:	55                   	push   %ebp
  800a96:	89 e5                	mov    %esp,%ebp
  800a98:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a9b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a9e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800aa2:	8b 45 10             	mov    0x10(%ebp),%eax
  800aa5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aa9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aac:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ab0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab3:	89 04 24             	mov    %eax,(%esp)
  800ab6:	e8 7b ff ff ff       	call   800a36 <vsnprintf>
	va_end(ap);

	return rc;
}
  800abb:	c9                   	leave  
  800abc:	c3                   	ret    
  800abd:	00 00                	add    %al,(%eax)
	...

00800ac0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ac0:	55                   	push   %ebp
  800ac1:	89 e5                	mov    %esp,%ebp
  800ac3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ac6:	b8 00 00 00 00       	mov    $0x0,%eax
  800acb:	eb 01                	jmp    800ace <strlen+0xe>
		n++;
  800acd:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800ace:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ad2:	75 f9                	jne    800acd <strlen+0xd>
		n++;
	return n;
}
  800ad4:	5d                   	pop    %ebp
  800ad5:	c3                   	ret    

00800ad6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ad6:	55                   	push   %ebp
  800ad7:	89 e5                	mov    %esp,%ebp
  800ad9:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800adc:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800adf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae4:	eb 01                	jmp    800ae7 <strnlen+0x11>
		n++;
  800ae6:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ae7:	39 d0                	cmp    %edx,%eax
  800ae9:	74 06                	je     800af1 <strnlen+0x1b>
  800aeb:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800aef:	75 f5                	jne    800ae6 <strnlen+0x10>
		n++;
	return n;
}
  800af1:	5d                   	pop    %ebp
  800af2:	c3                   	ret    

00800af3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	53                   	push   %ebx
  800af7:	8b 45 08             	mov    0x8(%ebp),%eax
  800afa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800afd:	ba 00 00 00 00       	mov    $0x0,%edx
  800b02:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800b05:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800b08:	42                   	inc    %edx
  800b09:	84 c9                	test   %cl,%cl
  800b0b:	75 f5                	jne    800b02 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800b0d:	5b                   	pop    %ebx
  800b0e:	5d                   	pop    %ebp
  800b0f:	c3                   	ret    

00800b10 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b10:	55                   	push   %ebp
  800b11:	89 e5                	mov    %esp,%ebp
  800b13:	53                   	push   %ebx
  800b14:	83 ec 08             	sub    $0x8,%esp
  800b17:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b1a:	89 1c 24             	mov    %ebx,(%esp)
  800b1d:	e8 9e ff ff ff       	call   800ac0 <strlen>
	strcpy(dst + len, src);
  800b22:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b25:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b29:	01 d8                	add    %ebx,%eax
  800b2b:	89 04 24             	mov    %eax,(%esp)
  800b2e:	e8 c0 ff ff ff       	call   800af3 <strcpy>
	return dst;
}
  800b33:	89 d8                	mov    %ebx,%eax
  800b35:	83 c4 08             	add    $0x8,%esp
  800b38:	5b                   	pop    %ebx
  800b39:	5d                   	pop    %ebp
  800b3a:	c3                   	ret    

00800b3b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
  800b3e:	56                   	push   %esi
  800b3f:	53                   	push   %ebx
  800b40:	8b 45 08             	mov    0x8(%ebp),%eax
  800b43:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b46:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b49:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b4e:	eb 0c                	jmp    800b5c <strncpy+0x21>
		*dst++ = *src;
  800b50:	8a 1a                	mov    (%edx),%bl
  800b52:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b55:	80 3a 01             	cmpb   $0x1,(%edx)
  800b58:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b5b:	41                   	inc    %ecx
  800b5c:	39 f1                	cmp    %esi,%ecx
  800b5e:	75 f0                	jne    800b50 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b60:	5b                   	pop    %ebx
  800b61:	5e                   	pop    %esi
  800b62:	5d                   	pop    %ebp
  800b63:	c3                   	ret    

00800b64 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b64:	55                   	push   %ebp
  800b65:	89 e5                	mov    %esp,%ebp
  800b67:	56                   	push   %esi
  800b68:	53                   	push   %ebx
  800b69:	8b 75 08             	mov    0x8(%ebp),%esi
  800b6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b6f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b72:	85 d2                	test   %edx,%edx
  800b74:	75 0a                	jne    800b80 <strlcpy+0x1c>
  800b76:	89 f0                	mov    %esi,%eax
  800b78:	eb 1a                	jmp    800b94 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b7a:	88 18                	mov    %bl,(%eax)
  800b7c:	40                   	inc    %eax
  800b7d:	41                   	inc    %ecx
  800b7e:	eb 02                	jmp    800b82 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b80:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800b82:	4a                   	dec    %edx
  800b83:	74 0a                	je     800b8f <strlcpy+0x2b>
  800b85:	8a 19                	mov    (%ecx),%bl
  800b87:	84 db                	test   %bl,%bl
  800b89:	75 ef                	jne    800b7a <strlcpy+0x16>
  800b8b:	89 c2                	mov    %eax,%edx
  800b8d:	eb 02                	jmp    800b91 <strlcpy+0x2d>
  800b8f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800b91:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800b94:	29 f0                	sub    %esi,%eax
}
  800b96:	5b                   	pop    %ebx
  800b97:	5e                   	pop    %esi
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    

00800b9a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ba0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ba3:	eb 02                	jmp    800ba7 <strcmp+0xd>
		p++, q++;
  800ba5:	41                   	inc    %ecx
  800ba6:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ba7:	8a 01                	mov    (%ecx),%al
  800ba9:	84 c0                	test   %al,%al
  800bab:	74 04                	je     800bb1 <strcmp+0x17>
  800bad:	3a 02                	cmp    (%edx),%al
  800baf:	74 f4                	je     800ba5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800bb1:	0f b6 c0             	movzbl %al,%eax
  800bb4:	0f b6 12             	movzbl (%edx),%edx
  800bb7:	29 d0                	sub    %edx,%eax
}
  800bb9:	5d                   	pop    %ebp
  800bba:	c3                   	ret    

00800bbb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800bbb:	55                   	push   %ebp
  800bbc:	89 e5                	mov    %esp,%ebp
  800bbe:	53                   	push   %ebx
  800bbf:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800bc8:	eb 03                	jmp    800bcd <strncmp+0x12>
		n--, p++, q++;
  800bca:	4a                   	dec    %edx
  800bcb:	40                   	inc    %eax
  800bcc:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800bcd:	85 d2                	test   %edx,%edx
  800bcf:	74 14                	je     800be5 <strncmp+0x2a>
  800bd1:	8a 18                	mov    (%eax),%bl
  800bd3:	84 db                	test   %bl,%bl
  800bd5:	74 04                	je     800bdb <strncmp+0x20>
  800bd7:	3a 19                	cmp    (%ecx),%bl
  800bd9:	74 ef                	je     800bca <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800bdb:	0f b6 00             	movzbl (%eax),%eax
  800bde:	0f b6 11             	movzbl (%ecx),%edx
  800be1:	29 d0                	sub    %edx,%eax
  800be3:	eb 05                	jmp    800bea <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800be5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800bea:	5b                   	pop    %ebx
  800beb:	5d                   	pop    %ebp
  800bec:	c3                   	ret    

00800bed <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800bed:	55                   	push   %ebp
  800bee:	89 e5                	mov    %esp,%ebp
  800bf0:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800bf6:	eb 05                	jmp    800bfd <strchr+0x10>
		if (*s == c)
  800bf8:	38 ca                	cmp    %cl,%dl
  800bfa:	74 0c                	je     800c08 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800bfc:	40                   	inc    %eax
  800bfd:	8a 10                	mov    (%eax),%dl
  800bff:	84 d2                	test   %dl,%dl
  800c01:	75 f5                	jne    800bf8 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800c03:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c08:	5d                   	pop    %ebp
  800c09:	c3                   	ret    

00800c0a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c10:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800c13:	eb 05                	jmp    800c1a <strfind+0x10>
		if (*s == c)
  800c15:	38 ca                	cmp    %cl,%dl
  800c17:	74 07                	je     800c20 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c19:	40                   	inc    %eax
  800c1a:	8a 10                	mov    (%eax),%dl
  800c1c:	84 d2                	test   %dl,%dl
  800c1e:	75 f5                	jne    800c15 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800c20:	5d                   	pop    %ebp
  800c21:	c3                   	ret    

00800c22 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c22:	55                   	push   %ebp
  800c23:	89 e5                	mov    %esp,%ebp
  800c25:	57                   	push   %edi
  800c26:	56                   	push   %esi
  800c27:	53                   	push   %ebx
  800c28:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c2e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c31:	85 c9                	test   %ecx,%ecx
  800c33:	74 30                	je     800c65 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c35:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c3b:	75 25                	jne    800c62 <memset+0x40>
  800c3d:	f6 c1 03             	test   $0x3,%cl
  800c40:	75 20                	jne    800c62 <memset+0x40>
		c &= 0xFF;
  800c42:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c45:	89 d3                	mov    %edx,%ebx
  800c47:	c1 e3 08             	shl    $0x8,%ebx
  800c4a:	89 d6                	mov    %edx,%esi
  800c4c:	c1 e6 18             	shl    $0x18,%esi
  800c4f:	89 d0                	mov    %edx,%eax
  800c51:	c1 e0 10             	shl    $0x10,%eax
  800c54:	09 f0                	or     %esi,%eax
  800c56:	09 d0                	or     %edx,%eax
  800c58:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c5a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800c5d:	fc                   	cld    
  800c5e:	f3 ab                	rep stos %eax,%es:(%edi)
  800c60:	eb 03                	jmp    800c65 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c62:	fc                   	cld    
  800c63:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c65:	89 f8                	mov    %edi,%eax
  800c67:	5b                   	pop    %ebx
  800c68:	5e                   	pop    %esi
  800c69:	5f                   	pop    %edi
  800c6a:	5d                   	pop    %ebp
  800c6b:	c3                   	ret    

00800c6c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c6c:	55                   	push   %ebp
  800c6d:	89 e5                	mov    %esp,%ebp
  800c6f:	57                   	push   %edi
  800c70:	56                   	push   %esi
  800c71:	8b 45 08             	mov    0x8(%ebp),%eax
  800c74:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c77:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c7a:	39 c6                	cmp    %eax,%esi
  800c7c:	73 34                	jae    800cb2 <memmove+0x46>
  800c7e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c81:	39 d0                	cmp    %edx,%eax
  800c83:	73 2d                	jae    800cb2 <memmove+0x46>
		s += n;
		d += n;
  800c85:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c88:	f6 c2 03             	test   $0x3,%dl
  800c8b:	75 1b                	jne    800ca8 <memmove+0x3c>
  800c8d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c93:	75 13                	jne    800ca8 <memmove+0x3c>
  800c95:	f6 c1 03             	test   $0x3,%cl
  800c98:	75 0e                	jne    800ca8 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c9a:	83 ef 04             	sub    $0x4,%edi
  800c9d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ca0:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800ca3:	fd                   	std    
  800ca4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ca6:	eb 07                	jmp    800caf <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ca8:	4f                   	dec    %edi
  800ca9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800cac:	fd                   	std    
  800cad:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800caf:	fc                   	cld    
  800cb0:	eb 20                	jmp    800cd2 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cb2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cb8:	75 13                	jne    800ccd <memmove+0x61>
  800cba:	a8 03                	test   $0x3,%al
  800cbc:	75 0f                	jne    800ccd <memmove+0x61>
  800cbe:	f6 c1 03             	test   $0x3,%cl
  800cc1:	75 0a                	jne    800ccd <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800cc3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800cc6:	89 c7                	mov    %eax,%edi
  800cc8:	fc                   	cld    
  800cc9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ccb:	eb 05                	jmp    800cd2 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ccd:	89 c7                	mov    %eax,%edi
  800ccf:	fc                   	cld    
  800cd0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800cd2:	5e                   	pop    %esi
  800cd3:	5f                   	pop    %edi
  800cd4:	5d                   	pop    %ebp
  800cd5:	c3                   	ret    

00800cd6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800cd6:	55                   	push   %ebp
  800cd7:	89 e5                	mov    %esp,%ebp
  800cd9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800cdc:	8b 45 10             	mov    0x10(%ebp),%eax
  800cdf:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ce3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ce6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cea:	8b 45 08             	mov    0x8(%ebp),%eax
  800ced:	89 04 24             	mov    %eax,(%esp)
  800cf0:	e8 77 ff ff ff       	call   800c6c <memmove>
}
  800cf5:	c9                   	leave  
  800cf6:	c3                   	ret    

00800cf7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cf7:	55                   	push   %ebp
  800cf8:	89 e5                	mov    %esp,%ebp
  800cfa:	57                   	push   %edi
  800cfb:	56                   	push   %esi
  800cfc:	53                   	push   %ebx
  800cfd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d00:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d03:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d06:	ba 00 00 00 00       	mov    $0x0,%edx
  800d0b:	eb 16                	jmp    800d23 <memcmp+0x2c>
		if (*s1 != *s2)
  800d0d:	8a 04 17             	mov    (%edi,%edx,1),%al
  800d10:	42                   	inc    %edx
  800d11:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800d15:	38 c8                	cmp    %cl,%al
  800d17:	74 0a                	je     800d23 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800d19:	0f b6 c0             	movzbl %al,%eax
  800d1c:	0f b6 c9             	movzbl %cl,%ecx
  800d1f:	29 c8                	sub    %ecx,%eax
  800d21:	eb 09                	jmp    800d2c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d23:	39 da                	cmp    %ebx,%edx
  800d25:	75 e6                	jne    800d0d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d27:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d2c:	5b                   	pop    %ebx
  800d2d:	5e                   	pop    %esi
  800d2e:	5f                   	pop    %edi
  800d2f:	5d                   	pop    %ebp
  800d30:	c3                   	ret    

00800d31 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d31:	55                   	push   %ebp
  800d32:	89 e5                	mov    %esp,%ebp
  800d34:	8b 45 08             	mov    0x8(%ebp),%eax
  800d37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800d3a:	89 c2                	mov    %eax,%edx
  800d3c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d3f:	eb 05                	jmp    800d46 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d41:	38 08                	cmp    %cl,(%eax)
  800d43:	74 05                	je     800d4a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d45:	40                   	inc    %eax
  800d46:	39 d0                	cmp    %edx,%eax
  800d48:	72 f7                	jb     800d41 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d4a:	5d                   	pop    %ebp
  800d4b:	c3                   	ret    

00800d4c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d4c:	55                   	push   %ebp
  800d4d:	89 e5                	mov    %esp,%ebp
  800d4f:	57                   	push   %edi
  800d50:	56                   	push   %esi
  800d51:	53                   	push   %ebx
  800d52:	8b 55 08             	mov    0x8(%ebp),%edx
  800d55:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d58:	eb 01                	jmp    800d5b <strtol+0xf>
		s++;
  800d5a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d5b:	8a 02                	mov    (%edx),%al
  800d5d:	3c 20                	cmp    $0x20,%al
  800d5f:	74 f9                	je     800d5a <strtol+0xe>
  800d61:	3c 09                	cmp    $0x9,%al
  800d63:	74 f5                	je     800d5a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d65:	3c 2b                	cmp    $0x2b,%al
  800d67:	75 08                	jne    800d71 <strtol+0x25>
		s++;
  800d69:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d6a:	bf 00 00 00 00       	mov    $0x0,%edi
  800d6f:	eb 13                	jmp    800d84 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d71:	3c 2d                	cmp    $0x2d,%al
  800d73:	75 0a                	jne    800d7f <strtol+0x33>
		s++, neg = 1;
  800d75:	8d 52 01             	lea    0x1(%edx),%edx
  800d78:	bf 01 00 00 00       	mov    $0x1,%edi
  800d7d:	eb 05                	jmp    800d84 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d7f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d84:	85 db                	test   %ebx,%ebx
  800d86:	74 05                	je     800d8d <strtol+0x41>
  800d88:	83 fb 10             	cmp    $0x10,%ebx
  800d8b:	75 28                	jne    800db5 <strtol+0x69>
  800d8d:	8a 02                	mov    (%edx),%al
  800d8f:	3c 30                	cmp    $0x30,%al
  800d91:	75 10                	jne    800da3 <strtol+0x57>
  800d93:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d97:	75 0a                	jne    800da3 <strtol+0x57>
		s += 2, base = 16;
  800d99:	83 c2 02             	add    $0x2,%edx
  800d9c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800da1:	eb 12                	jmp    800db5 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800da3:	85 db                	test   %ebx,%ebx
  800da5:	75 0e                	jne    800db5 <strtol+0x69>
  800da7:	3c 30                	cmp    $0x30,%al
  800da9:	75 05                	jne    800db0 <strtol+0x64>
		s++, base = 8;
  800dab:	42                   	inc    %edx
  800dac:	b3 08                	mov    $0x8,%bl
  800dae:	eb 05                	jmp    800db5 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800db0:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800db5:	b8 00 00 00 00       	mov    $0x0,%eax
  800dba:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800dbc:	8a 0a                	mov    (%edx),%cl
  800dbe:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800dc1:	80 fb 09             	cmp    $0x9,%bl
  800dc4:	77 08                	ja     800dce <strtol+0x82>
			dig = *s - '0';
  800dc6:	0f be c9             	movsbl %cl,%ecx
  800dc9:	83 e9 30             	sub    $0x30,%ecx
  800dcc:	eb 1e                	jmp    800dec <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800dce:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800dd1:	80 fb 19             	cmp    $0x19,%bl
  800dd4:	77 08                	ja     800dde <strtol+0x92>
			dig = *s - 'a' + 10;
  800dd6:	0f be c9             	movsbl %cl,%ecx
  800dd9:	83 e9 57             	sub    $0x57,%ecx
  800ddc:	eb 0e                	jmp    800dec <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800dde:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800de1:	80 fb 19             	cmp    $0x19,%bl
  800de4:	77 12                	ja     800df8 <strtol+0xac>
			dig = *s - 'A' + 10;
  800de6:	0f be c9             	movsbl %cl,%ecx
  800de9:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800dec:	39 f1                	cmp    %esi,%ecx
  800dee:	7d 0c                	jge    800dfc <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800df0:	42                   	inc    %edx
  800df1:	0f af c6             	imul   %esi,%eax
  800df4:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800df6:	eb c4                	jmp    800dbc <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800df8:	89 c1                	mov    %eax,%ecx
  800dfa:	eb 02                	jmp    800dfe <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800dfc:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800dfe:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e02:	74 05                	je     800e09 <strtol+0xbd>
		*endptr = (char *) s;
  800e04:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e07:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800e09:	85 ff                	test   %edi,%edi
  800e0b:	74 04                	je     800e11 <strtol+0xc5>
  800e0d:	89 c8                	mov    %ecx,%eax
  800e0f:	f7 d8                	neg    %eax
}
  800e11:	5b                   	pop    %ebx
  800e12:	5e                   	pop    %esi
  800e13:	5f                   	pop    %edi
  800e14:	5d                   	pop    %ebp
  800e15:	c3                   	ret    
	...

00800e18 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800e18:	55                   	push   %ebp
  800e19:	57                   	push   %edi
  800e1a:	56                   	push   %esi
  800e1b:	83 ec 10             	sub    $0x10,%esp
  800e1e:	8b 74 24 20          	mov    0x20(%esp),%esi
  800e22:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800e26:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e2a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  800e2e:	89 cd                	mov    %ecx,%ebp
  800e30:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e34:	85 c0                	test   %eax,%eax
  800e36:	75 2c                	jne    800e64 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800e38:	39 f9                	cmp    %edi,%ecx
  800e3a:	77 68                	ja     800ea4 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800e3c:	85 c9                	test   %ecx,%ecx
  800e3e:	75 0b                	jne    800e4b <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800e40:	b8 01 00 00 00       	mov    $0x1,%eax
  800e45:	31 d2                	xor    %edx,%edx
  800e47:	f7 f1                	div    %ecx
  800e49:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800e4b:	31 d2                	xor    %edx,%edx
  800e4d:	89 f8                	mov    %edi,%eax
  800e4f:	f7 f1                	div    %ecx
  800e51:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e53:	89 f0                	mov    %esi,%eax
  800e55:	f7 f1                	div    %ecx
  800e57:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e59:	89 f0                	mov    %esi,%eax
  800e5b:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e5d:	83 c4 10             	add    $0x10,%esp
  800e60:	5e                   	pop    %esi
  800e61:	5f                   	pop    %edi
  800e62:	5d                   	pop    %ebp
  800e63:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e64:	39 f8                	cmp    %edi,%eax
  800e66:	77 2c                	ja     800e94 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e68:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  800e6b:	83 f6 1f             	xor    $0x1f,%esi
  800e6e:	75 4c                	jne    800ebc <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e70:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e72:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e77:	72 0a                	jb     800e83 <__udivdi3+0x6b>
  800e79:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800e7d:	0f 87 ad 00 00 00    	ja     800f30 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e83:	be 01 00 00 00       	mov    $0x1,%esi
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
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e94:	31 ff                	xor    %edi,%edi
  800e96:	31 f6                	xor    %esi,%esi
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
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ea4:	89 fa                	mov    %edi,%edx
  800ea6:	89 f0                	mov    %esi,%eax
  800ea8:	f7 f1                	div    %ecx
  800eaa:	89 c6                	mov    %eax,%esi
  800eac:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800eae:	89 f0                	mov    %esi,%eax
  800eb0:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800eb2:	83 c4 10             	add    $0x10,%esp
  800eb5:	5e                   	pop    %esi
  800eb6:	5f                   	pop    %edi
  800eb7:	5d                   	pop    %ebp
  800eb8:	c3                   	ret    
  800eb9:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800ebc:	89 f1                	mov    %esi,%ecx
  800ebe:	d3 e0                	shl    %cl,%eax
  800ec0:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800ec4:	b8 20 00 00 00       	mov    $0x20,%eax
  800ec9:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800ecb:	89 ea                	mov    %ebp,%edx
  800ecd:	88 c1                	mov    %al,%cl
  800ecf:	d3 ea                	shr    %cl,%edx
  800ed1:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800ed5:	09 ca                	or     %ecx,%edx
  800ed7:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  800edb:	89 f1                	mov    %esi,%ecx
  800edd:	d3 e5                	shl    %cl,%ebp
  800edf:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  800ee3:	89 fd                	mov    %edi,%ebp
  800ee5:	88 c1                	mov    %al,%cl
  800ee7:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  800ee9:	89 fa                	mov    %edi,%edx
  800eeb:	89 f1                	mov    %esi,%ecx
  800eed:	d3 e2                	shl    %cl,%edx
  800eef:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ef3:	88 c1                	mov    %al,%cl
  800ef5:	d3 ef                	shr    %cl,%edi
  800ef7:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800ef9:	89 f8                	mov    %edi,%eax
  800efb:	89 ea                	mov    %ebp,%edx
  800efd:	f7 74 24 08          	divl   0x8(%esp)
  800f01:	89 d1                	mov    %edx,%ecx
  800f03:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  800f05:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f09:	39 d1                	cmp    %edx,%ecx
  800f0b:	72 17                	jb     800f24 <__udivdi3+0x10c>
  800f0d:	74 09                	je     800f18 <__udivdi3+0x100>
  800f0f:	89 fe                	mov    %edi,%esi
  800f11:	31 ff                	xor    %edi,%edi
  800f13:	e9 41 ff ff ff       	jmp    800e59 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800f18:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f1c:	89 f1                	mov    %esi,%ecx
  800f1e:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f20:	39 c2                	cmp    %eax,%edx
  800f22:	73 eb                	jae    800f0f <__udivdi3+0xf7>
		{
		  q0--;
  800f24:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f27:	31 ff                	xor    %edi,%edi
  800f29:	e9 2b ff ff ff       	jmp    800e59 <__udivdi3+0x41>
  800f2e:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800f30:	31 f6                	xor    %esi,%esi
  800f32:	e9 22 ff ff ff       	jmp    800e59 <__udivdi3+0x41>
	...

00800f38 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800f38:	55                   	push   %ebp
  800f39:	57                   	push   %edi
  800f3a:	56                   	push   %esi
  800f3b:	83 ec 20             	sub    $0x20,%esp
  800f3e:	8b 44 24 30          	mov    0x30(%esp),%eax
  800f42:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800f46:	89 44 24 14          	mov    %eax,0x14(%esp)
  800f4a:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  800f4e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800f52:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800f56:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  800f58:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800f5a:	85 ed                	test   %ebp,%ebp
  800f5c:	75 16                	jne    800f74 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  800f5e:	39 f1                	cmp    %esi,%ecx
  800f60:	0f 86 a6 00 00 00    	jbe    80100c <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f66:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800f68:	89 d0                	mov    %edx,%eax
  800f6a:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f6c:	83 c4 20             	add    $0x20,%esp
  800f6f:	5e                   	pop    %esi
  800f70:	5f                   	pop    %edi
  800f71:	5d                   	pop    %ebp
  800f72:	c3                   	ret    
  800f73:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800f74:	39 f5                	cmp    %esi,%ebp
  800f76:	0f 87 ac 00 00 00    	ja     801028 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800f7c:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  800f7f:	83 f0 1f             	xor    $0x1f,%eax
  800f82:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f86:	0f 84 a8 00 00 00    	je     801034 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800f8c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f90:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800f92:	bf 20 00 00 00       	mov    $0x20,%edi
  800f97:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800f9b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f9f:	89 f9                	mov    %edi,%ecx
  800fa1:	d3 e8                	shr    %cl,%eax
  800fa3:	09 e8                	or     %ebp,%eax
  800fa5:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  800fa9:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800fad:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800fb1:	d3 e0                	shl    %cl,%eax
  800fb3:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800fb7:	89 f2                	mov    %esi,%edx
  800fb9:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800fbb:	8b 44 24 14          	mov    0x14(%esp),%eax
  800fbf:	d3 e0                	shl    %cl,%eax
  800fc1:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800fc5:	8b 44 24 14          	mov    0x14(%esp),%eax
  800fc9:	89 f9                	mov    %edi,%ecx
  800fcb:	d3 e8                	shr    %cl,%eax
  800fcd:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800fcf:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800fd1:	89 f2                	mov    %esi,%edx
  800fd3:	f7 74 24 18          	divl   0x18(%esp)
  800fd7:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800fd9:	f7 64 24 0c          	mull   0xc(%esp)
  800fdd:	89 c5                	mov    %eax,%ebp
  800fdf:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800fe1:	39 d6                	cmp    %edx,%esi
  800fe3:	72 67                	jb     80104c <__umoddi3+0x114>
  800fe5:	74 75                	je     80105c <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800fe7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800feb:	29 e8                	sub    %ebp,%eax
  800fed:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800fef:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800ff3:	d3 e8                	shr    %cl,%eax
  800ff5:	89 f2                	mov    %esi,%edx
  800ff7:	89 f9                	mov    %edi,%ecx
  800ff9:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800ffb:	09 d0                	or     %edx,%eax
  800ffd:	89 f2                	mov    %esi,%edx
  800fff:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801003:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801005:	83 c4 20             	add    $0x20,%esp
  801008:	5e                   	pop    %esi
  801009:	5f                   	pop    %edi
  80100a:	5d                   	pop    %ebp
  80100b:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80100c:	85 c9                	test   %ecx,%ecx
  80100e:	75 0b                	jne    80101b <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801010:	b8 01 00 00 00       	mov    $0x1,%eax
  801015:	31 d2                	xor    %edx,%edx
  801017:	f7 f1                	div    %ecx
  801019:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80101b:	89 f0                	mov    %esi,%eax
  80101d:	31 d2                	xor    %edx,%edx
  80101f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801021:	89 f8                	mov    %edi,%eax
  801023:	e9 3e ff ff ff       	jmp    800f66 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801028:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80102a:	83 c4 20             	add    $0x20,%esp
  80102d:	5e                   	pop    %esi
  80102e:	5f                   	pop    %edi
  80102f:	5d                   	pop    %ebp
  801030:	c3                   	ret    
  801031:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801034:	39 f5                	cmp    %esi,%ebp
  801036:	72 04                	jb     80103c <__umoddi3+0x104>
  801038:	39 f9                	cmp    %edi,%ecx
  80103a:	77 06                	ja     801042 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80103c:	89 f2                	mov    %esi,%edx
  80103e:	29 cf                	sub    %ecx,%edi
  801040:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801042:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801044:	83 c4 20             	add    $0x20,%esp
  801047:	5e                   	pop    %esi
  801048:	5f                   	pop    %edi
  801049:	5d                   	pop    %ebp
  80104a:	c3                   	ret    
  80104b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80104c:	89 d1                	mov    %edx,%ecx
  80104e:	89 c5                	mov    %eax,%ebp
  801050:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801054:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801058:	eb 8d                	jmp    800fe7 <__umoddi3+0xaf>
  80105a:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80105c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801060:	72 ea                	jb     80104c <__umoddi3+0x114>
  801062:	89 f1                	mov    %esi,%ecx
  801064:	eb 81                	jmp    800fe7 <__umoddi3+0xaf>
