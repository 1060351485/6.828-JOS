
obj/user/evilhello.debug:     file format elf32-i386


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
  80002c:	e8 1f 00 00 00       	call   800050 <libmain>
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
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  80003a:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  800041:	00 
  800042:	c7 04 24 0c 00 10 f0 	movl   $0xf010000c,(%esp)
  800049:	e8 5e 00 00 00       	call   8000ac <sys_cputs>
}
  80004e:	c9                   	leave  
  80004f:	c3                   	ret    

00800050 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800050:	55                   	push   %ebp
  800051:	89 e5                	mov    %esp,%ebp
  800053:	56                   	push   %esi
  800054:	53                   	push   %ebx
  800055:	83 ec 10             	sub    $0x10,%esp
  800058:	8b 75 08             	mov    0x8(%ebp),%esi
  80005b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80005e:	e8 d8 00 00 00       	call   80013b <sys_getenvid>
  800063:	25 ff 03 00 00       	and    $0x3ff,%eax
  800068:	c1 e0 07             	shl    $0x7,%eax
  80006b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800070:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800075:	85 f6                	test   %esi,%esi
  800077:	7e 07                	jle    800080 <libmain+0x30>
		binaryname = argv[0];
  800079:	8b 03                	mov    (%ebx),%eax
  80007b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800080:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800084:	89 34 24             	mov    %esi,(%esp)
  800087:	e8 a8 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80008c:	e8 07 00 00 00       	call   800098 <exit>
}
  800091:	83 c4 10             	add    $0x10,%esp
  800094:	5b                   	pop    %ebx
  800095:	5e                   	pop    %esi
  800096:	5d                   	pop    %ebp
  800097:	c3                   	ret    

00800098 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800098:	55                   	push   %ebp
  800099:	89 e5                	mov    %esp,%ebp
  80009b:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  80009e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a5:	e8 3f 00 00 00       	call   8000e9 <sys_env_destroy>
}
  8000aa:	c9                   	leave  
  8000ab:	c3                   	ret    

008000ac <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	57                   	push   %edi
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bd:	89 c3                	mov    %eax,%ebx
  8000bf:	89 c7                	mov    %eax,%edi
  8000c1:	89 c6                	mov    %eax,%esi
  8000c3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c5:	5b                   	pop    %ebx
  8000c6:	5e                   	pop    %esi
  8000c7:	5f                   	pop    %edi
  8000c8:	5d                   	pop    %ebp
  8000c9:	c3                   	ret    

008000ca <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	57                   	push   %edi
  8000ce:	56                   	push   %esi
  8000cf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d5:	b8 01 00 00 00       	mov    $0x1,%eax
  8000da:	89 d1                	mov    %edx,%ecx
  8000dc:	89 d3                	mov    %edx,%ebx
  8000de:	89 d7                	mov    %edx,%edi
  8000e0:	89 d6                	mov    %edx,%esi
  8000e2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e4:	5b                   	pop    %ebx
  8000e5:	5e                   	pop    %esi
  8000e6:	5f                   	pop    %edi
  8000e7:	5d                   	pop    %ebp
  8000e8:	c3                   	ret    

008000e9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e9:	55                   	push   %ebp
  8000ea:	89 e5                	mov    %esp,%ebp
  8000ec:	57                   	push   %edi
  8000ed:	56                   	push   %esi
  8000ee:	53                   	push   %ebx
  8000ef:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f7:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ff:	89 cb                	mov    %ecx,%ebx
  800101:	89 cf                	mov    %ecx,%edi
  800103:	89 ce                	mov    %ecx,%esi
  800105:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800107:	85 c0                	test   %eax,%eax
  800109:	7e 28                	jle    800133 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80010b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80010f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800116:	00 
  800117:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  80011e:	00 
  80011f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800126:	00 
  800127:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  80012e:	e8 31 03 00 00       	call   800464 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800133:	83 c4 2c             	add    $0x2c,%esp
  800136:	5b                   	pop    %ebx
  800137:	5e                   	pop    %esi
  800138:	5f                   	pop    %edi
  800139:	5d                   	pop    %ebp
  80013a:	c3                   	ret    

0080013b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	57                   	push   %edi
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800141:	ba 00 00 00 00       	mov    $0x0,%edx
  800146:	b8 02 00 00 00       	mov    $0x2,%eax
  80014b:	89 d1                	mov    %edx,%ecx
  80014d:	89 d3                	mov    %edx,%ebx
  80014f:	89 d7                	mov    %edx,%edi
  800151:	89 d6                	mov    %edx,%esi
  800153:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800155:	5b                   	pop    %ebx
  800156:	5e                   	pop    %esi
  800157:	5f                   	pop    %edi
  800158:	5d                   	pop    %ebp
  800159:	c3                   	ret    

0080015a <sys_yield>:

void
sys_yield(void)
{
  80015a:	55                   	push   %ebp
  80015b:	89 e5                	mov    %esp,%ebp
  80015d:	57                   	push   %edi
  80015e:	56                   	push   %esi
  80015f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800160:	ba 00 00 00 00       	mov    $0x0,%edx
  800165:	b8 0b 00 00 00       	mov    $0xb,%eax
  80016a:	89 d1                	mov    %edx,%ecx
  80016c:	89 d3                	mov    %edx,%ebx
  80016e:	89 d7                	mov    %edx,%edi
  800170:	89 d6                	mov    %edx,%esi
  800172:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800174:	5b                   	pop    %ebx
  800175:	5e                   	pop    %esi
  800176:	5f                   	pop    %edi
  800177:	5d                   	pop    %ebp
  800178:	c3                   	ret    

00800179 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	57                   	push   %edi
  80017d:	56                   	push   %esi
  80017e:	53                   	push   %ebx
  80017f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800182:	be 00 00 00 00       	mov    $0x0,%esi
  800187:	b8 04 00 00 00       	mov    $0x4,%eax
  80018c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80018f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800192:	8b 55 08             	mov    0x8(%ebp),%edx
  800195:	89 f7                	mov    %esi,%edi
  800197:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800199:	85 c0                	test   %eax,%eax
  80019b:	7e 28                	jle    8001c5 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  80019d:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001a1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001a8:	00 
  8001a9:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  8001b0:	00 
  8001b1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001b8:	00 
  8001b9:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  8001c0:	e8 9f 02 00 00       	call   800464 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001c5:	83 c4 2c             	add    $0x2c,%esp
  8001c8:	5b                   	pop    %ebx
  8001c9:	5e                   	pop    %esi
  8001ca:	5f                   	pop    %edi
  8001cb:	5d                   	pop    %ebp
  8001cc:	c3                   	ret    

008001cd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001cd:	55                   	push   %ebp
  8001ce:	89 e5                	mov    %esp,%ebp
  8001d0:	57                   	push   %edi
  8001d1:	56                   	push   %esi
  8001d2:	53                   	push   %ebx
  8001d3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001d6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001db:	8b 75 18             	mov    0x18(%ebp),%esi
  8001de:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001e1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e7:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ea:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001ec:	85 c0                	test   %eax,%eax
  8001ee:	7e 28                	jle    800218 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001f4:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8001fb:	00 
  8001fc:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  800203:	00 
  800204:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80020b:	00 
  80020c:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  800213:	e8 4c 02 00 00       	call   800464 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800218:	83 c4 2c             	add    $0x2c,%esp
  80021b:	5b                   	pop    %ebx
  80021c:	5e                   	pop    %esi
  80021d:	5f                   	pop    %edi
  80021e:	5d                   	pop    %ebp
  80021f:	c3                   	ret    

00800220 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	57                   	push   %edi
  800224:	56                   	push   %esi
  800225:	53                   	push   %ebx
  800226:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800229:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022e:	b8 06 00 00 00       	mov    $0x6,%eax
  800233:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800236:	8b 55 08             	mov    0x8(%ebp),%edx
  800239:	89 df                	mov    %ebx,%edi
  80023b:	89 de                	mov    %ebx,%esi
  80023d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80023f:	85 c0                	test   %eax,%eax
  800241:	7e 28                	jle    80026b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800243:	89 44 24 10          	mov    %eax,0x10(%esp)
  800247:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80024e:	00 
  80024f:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  800256:	00 
  800257:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80025e:	00 
  80025f:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  800266:	e8 f9 01 00 00       	call   800464 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80026b:	83 c4 2c             	add    $0x2c,%esp
  80026e:	5b                   	pop    %ebx
  80026f:	5e                   	pop    %esi
  800270:	5f                   	pop    %edi
  800271:	5d                   	pop    %ebp
  800272:	c3                   	ret    

00800273 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800273:	55                   	push   %ebp
  800274:	89 e5                	mov    %esp,%ebp
  800276:	57                   	push   %edi
  800277:	56                   	push   %esi
  800278:	53                   	push   %ebx
  800279:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80027c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800281:	b8 08 00 00 00       	mov    $0x8,%eax
  800286:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800289:	8b 55 08             	mov    0x8(%ebp),%edx
  80028c:	89 df                	mov    %ebx,%edi
  80028e:	89 de                	mov    %ebx,%esi
  800290:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800292:	85 c0                	test   %eax,%eax
  800294:	7e 28                	jle    8002be <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800296:	89 44 24 10          	mov    %eax,0x10(%esp)
  80029a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002a1:	00 
  8002a2:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  8002a9:	00 
  8002aa:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002b1:	00 
  8002b2:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  8002b9:	e8 a6 01 00 00       	call   800464 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002be:	83 c4 2c             	add    $0x2c,%esp
  8002c1:	5b                   	pop    %ebx
  8002c2:	5e                   	pop    %esi
  8002c3:	5f                   	pop    %edi
  8002c4:	5d                   	pop    %ebp
  8002c5:	c3                   	ret    

008002c6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
  8002c9:	57                   	push   %edi
  8002ca:	56                   	push   %esi
  8002cb:	53                   	push   %ebx
  8002cc:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002cf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002d4:	b8 09 00 00 00       	mov    $0x9,%eax
  8002d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8002df:	89 df                	mov    %ebx,%edi
  8002e1:	89 de                	mov    %ebx,%esi
  8002e3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002e5:	85 c0                	test   %eax,%eax
  8002e7:	7e 28                	jle    800311 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002ed:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002f4:	00 
  8002f5:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  8002fc:	00 
  8002fd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800304:	00 
  800305:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  80030c:	e8 53 01 00 00       	call   800464 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800311:	83 c4 2c             	add    $0x2c,%esp
  800314:	5b                   	pop    %ebx
  800315:	5e                   	pop    %esi
  800316:	5f                   	pop    %edi
  800317:	5d                   	pop    %ebp
  800318:	c3                   	ret    

00800319 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800319:	55                   	push   %ebp
  80031a:	89 e5                	mov    %esp,%ebp
  80031c:	57                   	push   %edi
  80031d:	56                   	push   %esi
  80031e:	53                   	push   %ebx
  80031f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800322:	bb 00 00 00 00       	mov    $0x0,%ebx
  800327:	b8 0a 00 00 00       	mov    $0xa,%eax
  80032c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80032f:	8b 55 08             	mov    0x8(%ebp),%edx
  800332:	89 df                	mov    %ebx,%edi
  800334:	89 de                	mov    %ebx,%esi
  800336:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800338:	85 c0                	test   %eax,%eax
  80033a:	7e 28                	jle    800364 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80033c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800340:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800347:	00 
  800348:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  80034f:	00 
  800350:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800357:	00 
  800358:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  80035f:	e8 00 01 00 00       	call   800464 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800364:	83 c4 2c             	add    $0x2c,%esp
  800367:	5b                   	pop    %ebx
  800368:	5e                   	pop    %esi
  800369:	5f                   	pop    %edi
  80036a:	5d                   	pop    %ebp
  80036b:	c3                   	ret    

0080036c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80036c:	55                   	push   %ebp
  80036d:	89 e5                	mov    %esp,%ebp
  80036f:	57                   	push   %edi
  800370:	56                   	push   %esi
  800371:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800372:	be 00 00 00 00       	mov    $0x0,%esi
  800377:	b8 0c 00 00 00       	mov    $0xc,%eax
  80037c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80037f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800382:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800385:	8b 55 08             	mov    0x8(%ebp),%edx
  800388:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80038a:	5b                   	pop    %ebx
  80038b:	5e                   	pop    %esi
  80038c:	5f                   	pop    %edi
  80038d:	5d                   	pop    %ebp
  80038e:	c3                   	ret    

0080038f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80038f:	55                   	push   %ebp
  800390:	89 e5                	mov    %esp,%ebp
  800392:	57                   	push   %edi
  800393:	56                   	push   %esi
  800394:	53                   	push   %ebx
  800395:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800398:	b9 00 00 00 00       	mov    $0x0,%ecx
  80039d:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a5:	89 cb                	mov    %ecx,%ebx
  8003a7:	89 cf                	mov    %ecx,%edi
  8003a9:	89 ce                	mov    %ecx,%esi
  8003ab:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003ad:	85 c0                	test   %eax,%eax
  8003af:	7e 28                	jle    8003d9 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003b1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003b5:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003bc:	00 
  8003bd:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  8003c4:	00 
  8003c5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003cc:	00 
  8003cd:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  8003d4:	e8 8b 00 00 00       	call   800464 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003d9:	83 c4 2c             	add    $0x2c,%esp
  8003dc:	5b                   	pop    %ebx
  8003dd:	5e                   	pop    %esi
  8003de:	5f                   	pop    %edi
  8003df:	5d                   	pop    %ebp
  8003e0:	c3                   	ret    

008003e1 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8003e1:	55                   	push   %ebp
  8003e2:	89 e5                	mov    %esp,%ebp
  8003e4:	57                   	push   %edi
  8003e5:	56                   	push   %esi
  8003e6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ec:	b8 0e 00 00 00       	mov    $0xe,%eax
  8003f1:	89 d1                	mov    %edx,%ecx
  8003f3:	89 d3                	mov    %edx,%ebx
  8003f5:	89 d7                	mov    %edx,%edi
  8003f7:	89 d6                	mov    %edx,%esi
  8003f9:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8003fb:	5b                   	pop    %ebx
  8003fc:	5e                   	pop    %esi
  8003fd:	5f                   	pop    %edi
  8003fe:	5d                   	pop    %ebp
  8003ff:	c3                   	ret    

00800400 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char* pck, size_t length){
  800400:	55                   	push   %ebp
  800401:	89 e5                	mov    %esp,%ebp
  800403:	57                   	push   %edi
  800404:	56                   	push   %esi
  800405:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800406:	bb 00 00 00 00       	mov    $0x0,%ebx
  80040b:	b8 10 00 00 00       	mov    $0x10,%eax
  800410:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800413:	8b 55 08             	mov    0x8(%ebp),%edx
  800416:	89 df                	mov    %ebx,%edi
  800418:	89 de                	mov    %ebx,%esi
  80041a:	cd 30                	int    $0x30
}

int 
sys_e1000_transmit(char* pck, size_t length){
	return syscall(SYS_e1000_transmit, 0, (uint32_t)pck, length, 0, 0, 0);
}
  80041c:	5b                   	pop    %ebx
  80041d:	5e                   	pop    %esi
  80041e:	5f                   	pop    %edi
  80041f:	5d                   	pop    %ebp
  800420:	c3                   	ret    

00800421 <sys_e1000_receive>:

int 
sys_e1000_receive(char* pck, size_t* length){
  800421:	55                   	push   %ebp
  800422:	89 e5                	mov    %esp,%ebp
  800424:	57                   	push   %edi
  800425:	56                   	push   %esi
  800426:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800427:	bb 00 00 00 00       	mov    $0x0,%ebx
  80042c:	b8 0f 00 00 00       	mov    $0xf,%eax
  800431:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800434:	8b 55 08             	mov    0x8(%ebp),%edx
  800437:	89 df                	mov    %ebx,%edi
  800439:	89 de                	mov    %ebx,%esi
  80043b:	cd 30                	int    $0x30
}

int 
sys_e1000_receive(char* pck, size_t* length){
	return syscall(SYS_e1000_receive, 0, (uint32_t)pck, (uint32_t)length, 0, 0, 0);
}
  80043d:	5b                   	pop    %ebx
  80043e:	5e                   	pop    %esi
  80043f:	5f                   	pop    %edi
  800440:	5d                   	pop    %ebp
  800441:	c3                   	ret    

00800442 <sys_e1000_get_mac>:

int 
sys_e1000_get_mac(uint8_t* mac_addr){
  800442:	55                   	push   %ebp
  800443:	89 e5                	mov    %esp,%ebp
  800445:	57                   	push   %edi
  800446:	56                   	push   %esi
  800447:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800448:	b9 00 00 00 00       	mov    $0x0,%ecx
  80044d:	b8 11 00 00 00       	mov    $0x11,%eax
  800452:	8b 55 08             	mov    0x8(%ebp),%edx
  800455:	89 cb                	mov    %ecx,%ebx
  800457:	89 cf                	mov    %ecx,%edi
  800459:	89 ce                	mov    %ecx,%esi
  80045b:	cd 30                	int    $0x30
}

int 
sys_e1000_get_mac(uint8_t* mac_addr){
	return syscall(SYS_e1000_get_mac, 0, (uint32_t)mac_addr, 0, 0, 0, 0);
}
  80045d:	5b                   	pop    %ebx
  80045e:	5e                   	pop    %esi
  80045f:	5f                   	pop    %edi
  800460:	5d                   	pop    %ebp
  800461:	c3                   	ret    
	...

00800464 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800464:	55                   	push   %ebp
  800465:	89 e5                	mov    %esp,%ebp
  800467:	56                   	push   %esi
  800468:	53                   	push   %ebx
  800469:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80046c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80046f:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800475:	e8 c1 fc ff ff       	call   80013b <sys_getenvid>
  80047a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80047d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800481:	8b 55 08             	mov    0x8(%ebp),%edx
  800484:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800488:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80048c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800490:	c7 04 24 b8 10 80 00 	movl   $0x8010b8,(%esp)
  800497:	e8 c0 00 00 00       	call   80055c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80049c:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004a0:	8b 45 10             	mov    0x10(%ebp),%eax
  8004a3:	89 04 24             	mov    %eax,(%esp)
  8004a6:	e8 50 00 00 00       	call   8004fb <vcprintf>
	cprintf("\n");
  8004ab:	c7 04 24 db 10 80 00 	movl   $0x8010db,(%esp)
  8004b2:	e8 a5 00 00 00       	call   80055c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004b7:	cc                   	int3   
  8004b8:	eb fd                	jmp    8004b7 <_panic+0x53>
	...

008004bc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004bc:	55                   	push   %ebp
  8004bd:	89 e5                	mov    %esp,%ebp
  8004bf:	53                   	push   %ebx
  8004c0:	83 ec 14             	sub    $0x14,%esp
  8004c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8004c6:	8b 03                	mov    (%ebx),%eax
  8004c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8004cb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8004cf:	40                   	inc    %eax
  8004d0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8004d2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004d7:	75 19                	jne    8004f2 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8004d9:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8004e0:	00 
  8004e1:	8d 43 08             	lea    0x8(%ebx),%eax
  8004e4:	89 04 24             	mov    %eax,(%esp)
  8004e7:	e8 c0 fb ff ff       	call   8000ac <sys_cputs>
		b->idx = 0;
  8004ec:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8004f2:	ff 43 04             	incl   0x4(%ebx)
}
  8004f5:	83 c4 14             	add    $0x14,%esp
  8004f8:	5b                   	pop    %ebx
  8004f9:	5d                   	pop    %ebp
  8004fa:	c3                   	ret    

008004fb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004fb:	55                   	push   %ebp
  8004fc:	89 e5                	mov    %esp,%ebp
  8004fe:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800504:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80050b:	00 00 00 
	b.cnt = 0;
  80050e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800515:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800518:	8b 45 0c             	mov    0xc(%ebp),%eax
  80051b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80051f:	8b 45 08             	mov    0x8(%ebp),%eax
  800522:	89 44 24 08          	mov    %eax,0x8(%esp)
  800526:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80052c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800530:	c7 04 24 bc 04 80 00 	movl   $0x8004bc,(%esp)
  800537:	e8 82 01 00 00       	call   8006be <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80053c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800542:	89 44 24 04          	mov    %eax,0x4(%esp)
  800546:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80054c:	89 04 24             	mov    %eax,(%esp)
  80054f:	e8 58 fb ff ff       	call   8000ac <sys_cputs>

	return b.cnt;
}
  800554:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80055a:	c9                   	leave  
  80055b:	c3                   	ret    

0080055c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80055c:	55                   	push   %ebp
  80055d:	89 e5                	mov    %esp,%ebp
  80055f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800562:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800565:	89 44 24 04          	mov    %eax,0x4(%esp)
  800569:	8b 45 08             	mov    0x8(%ebp),%eax
  80056c:	89 04 24             	mov    %eax,(%esp)
  80056f:	e8 87 ff ff ff       	call   8004fb <vcprintf>
	va_end(ap);

	return cnt;
}
  800574:	c9                   	leave  
  800575:	c3                   	ret    
	...

00800578 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800578:	55                   	push   %ebp
  800579:	89 e5                	mov    %esp,%ebp
  80057b:	57                   	push   %edi
  80057c:	56                   	push   %esi
  80057d:	53                   	push   %ebx
  80057e:	83 ec 3c             	sub    $0x3c,%esp
  800581:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800584:	89 d7                	mov    %edx,%edi
  800586:	8b 45 08             	mov    0x8(%ebp),%eax
  800589:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80058c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80058f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800592:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800595:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800598:	85 c0                	test   %eax,%eax
  80059a:	75 08                	jne    8005a4 <printnum+0x2c>
  80059c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80059f:	39 45 10             	cmp    %eax,0x10(%ebp)
  8005a2:	77 57                	ja     8005fb <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005a4:	89 74 24 10          	mov    %esi,0x10(%esp)
  8005a8:	4b                   	dec    %ebx
  8005a9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8005ad:	8b 45 10             	mov    0x10(%ebp),%eax
  8005b0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005b4:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8005b8:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8005bc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005c3:	00 
  8005c4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005c7:	89 04 24             	mov    %eax,(%esp)
  8005ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005d1:	e8 56 08 00 00       	call   800e2c <__udivdi3>
  8005d6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005da:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8005de:	89 04 24             	mov    %eax,(%esp)
  8005e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005e5:	89 fa                	mov    %edi,%edx
  8005e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005ea:	e8 89 ff ff ff       	call   800578 <printnum>
  8005ef:	eb 0f                	jmp    800600 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8005f1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005f5:	89 34 24             	mov    %esi,(%esp)
  8005f8:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005fb:	4b                   	dec    %ebx
  8005fc:	85 db                	test   %ebx,%ebx
  8005fe:	7f f1                	jg     8005f1 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800600:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800604:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800608:	8b 45 10             	mov    0x10(%ebp),%eax
  80060b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80060f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800616:	00 
  800617:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80061a:	89 04 24             	mov    %eax,(%esp)
  80061d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800620:	89 44 24 04          	mov    %eax,0x4(%esp)
  800624:	e8 23 09 00 00       	call   800f4c <__umoddi3>
  800629:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80062d:	0f be 80 dd 10 80 00 	movsbl 0x8010dd(%eax),%eax
  800634:	89 04 24             	mov    %eax,(%esp)
  800637:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80063a:	83 c4 3c             	add    $0x3c,%esp
  80063d:	5b                   	pop    %ebx
  80063e:	5e                   	pop    %esi
  80063f:	5f                   	pop    %edi
  800640:	5d                   	pop    %ebp
  800641:	c3                   	ret    

00800642 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800642:	55                   	push   %ebp
  800643:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800645:	83 fa 01             	cmp    $0x1,%edx
  800648:	7e 0e                	jle    800658 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80064a:	8b 10                	mov    (%eax),%edx
  80064c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80064f:	89 08                	mov    %ecx,(%eax)
  800651:	8b 02                	mov    (%edx),%eax
  800653:	8b 52 04             	mov    0x4(%edx),%edx
  800656:	eb 22                	jmp    80067a <getuint+0x38>
	else if (lflag)
  800658:	85 d2                	test   %edx,%edx
  80065a:	74 10                	je     80066c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80065c:	8b 10                	mov    (%eax),%edx
  80065e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800661:	89 08                	mov    %ecx,(%eax)
  800663:	8b 02                	mov    (%edx),%eax
  800665:	ba 00 00 00 00       	mov    $0x0,%edx
  80066a:	eb 0e                	jmp    80067a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80066c:	8b 10                	mov    (%eax),%edx
  80066e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800671:	89 08                	mov    %ecx,(%eax)
  800673:	8b 02                	mov    (%edx),%eax
  800675:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80067a:	5d                   	pop    %ebp
  80067b:	c3                   	ret    

0080067c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80067c:	55                   	push   %ebp
  80067d:	89 e5                	mov    %esp,%ebp
  80067f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800682:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800685:	8b 10                	mov    (%eax),%edx
  800687:	3b 50 04             	cmp    0x4(%eax),%edx
  80068a:	73 08                	jae    800694 <sprintputch+0x18>
		*b->buf++ = ch;
  80068c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80068f:	88 0a                	mov    %cl,(%edx)
  800691:	42                   	inc    %edx
  800692:	89 10                	mov    %edx,(%eax)
}
  800694:	5d                   	pop    %ebp
  800695:	c3                   	ret    

00800696 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800696:	55                   	push   %ebp
  800697:	89 e5                	mov    %esp,%ebp
  800699:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80069c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80069f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006a3:	8b 45 10             	mov    0x10(%ebp),%eax
  8006a6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b4:	89 04 24             	mov    %eax,(%esp)
  8006b7:	e8 02 00 00 00       	call   8006be <vprintfmt>
	va_end(ap);
}
  8006bc:	c9                   	leave  
  8006bd:	c3                   	ret    

008006be <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006be:	55                   	push   %ebp
  8006bf:	89 e5                	mov    %esp,%ebp
  8006c1:	57                   	push   %edi
  8006c2:	56                   	push   %esi
  8006c3:	53                   	push   %ebx
  8006c4:	83 ec 4c             	sub    $0x4c,%esp
  8006c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006ca:	8b 75 10             	mov    0x10(%ebp),%esi
  8006cd:	eb 12                	jmp    8006e1 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006cf:	85 c0                	test   %eax,%eax
  8006d1:	0f 84 6b 03 00 00    	je     800a42 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8006d7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006db:	89 04 24             	mov    %eax,(%esp)
  8006de:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006e1:	0f b6 06             	movzbl (%esi),%eax
  8006e4:	46                   	inc    %esi
  8006e5:	83 f8 25             	cmp    $0x25,%eax
  8006e8:	75 e5                	jne    8006cf <vprintfmt+0x11>
  8006ea:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8006ee:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8006f5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8006fa:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800701:	b9 00 00 00 00       	mov    $0x0,%ecx
  800706:	eb 26                	jmp    80072e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800708:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80070b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80070f:	eb 1d                	jmp    80072e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800711:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800714:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800718:	eb 14                	jmp    80072e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80071a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80071d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800724:	eb 08                	jmp    80072e <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800726:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800729:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072e:	0f b6 06             	movzbl (%esi),%eax
  800731:	8d 56 01             	lea    0x1(%esi),%edx
  800734:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800737:	8a 16                	mov    (%esi),%dl
  800739:	83 ea 23             	sub    $0x23,%edx
  80073c:	80 fa 55             	cmp    $0x55,%dl
  80073f:	0f 87 e1 02 00 00    	ja     800a26 <vprintfmt+0x368>
  800745:	0f b6 d2             	movzbl %dl,%edx
  800748:	ff 24 95 20 12 80 00 	jmp    *0x801220(,%edx,4)
  80074f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800752:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800757:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80075a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80075e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800761:	8d 50 d0             	lea    -0x30(%eax),%edx
  800764:	83 fa 09             	cmp    $0x9,%edx
  800767:	77 2a                	ja     800793 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800769:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80076a:	eb eb                	jmp    800757 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80076c:	8b 45 14             	mov    0x14(%ebp),%eax
  80076f:	8d 50 04             	lea    0x4(%eax),%edx
  800772:	89 55 14             	mov    %edx,0x14(%ebp)
  800775:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800777:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80077a:	eb 17                	jmp    800793 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  80077c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800780:	78 98                	js     80071a <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800782:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800785:	eb a7                	jmp    80072e <vprintfmt+0x70>
  800787:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80078a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800791:	eb 9b                	jmp    80072e <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800793:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800797:	79 95                	jns    80072e <vprintfmt+0x70>
  800799:	eb 8b                	jmp    800726 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80079b:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80079c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80079f:	eb 8d                	jmp    80072e <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a4:	8d 50 04             	lea    0x4(%eax),%edx
  8007a7:	89 55 14             	mov    %edx,0x14(%ebp)
  8007aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ae:	8b 00                	mov    (%eax),%eax
  8007b0:	89 04 24             	mov    %eax,(%esp)
  8007b3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8007b9:	e9 23 ff ff ff       	jmp    8006e1 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8007be:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c1:	8d 50 04             	lea    0x4(%eax),%edx
  8007c4:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c7:	8b 00                	mov    (%eax),%eax
  8007c9:	85 c0                	test   %eax,%eax
  8007cb:	79 02                	jns    8007cf <vprintfmt+0x111>
  8007cd:	f7 d8                	neg    %eax
  8007cf:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8007d1:	83 f8 11             	cmp    $0x11,%eax
  8007d4:	7f 0b                	jg     8007e1 <vprintfmt+0x123>
  8007d6:	8b 04 85 80 13 80 00 	mov    0x801380(,%eax,4),%eax
  8007dd:	85 c0                	test   %eax,%eax
  8007df:	75 23                	jne    800804 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8007e1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007e5:	c7 44 24 08 f5 10 80 	movl   $0x8010f5,0x8(%esp)
  8007ec:	00 
  8007ed:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f4:	89 04 24             	mov    %eax,(%esp)
  8007f7:	e8 9a fe ff ff       	call   800696 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007fc:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8007ff:	e9 dd fe ff ff       	jmp    8006e1 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800804:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800808:	c7 44 24 08 fe 10 80 	movl   $0x8010fe,0x8(%esp)
  80080f:	00 
  800810:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800814:	8b 55 08             	mov    0x8(%ebp),%edx
  800817:	89 14 24             	mov    %edx,(%esp)
  80081a:	e8 77 fe ff ff       	call   800696 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80081f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800822:	e9 ba fe ff ff       	jmp    8006e1 <vprintfmt+0x23>
  800827:	89 f9                	mov    %edi,%ecx
  800829:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80082c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80082f:	8b 45 14             	mov    0x14(%ebp),%eax
  800832:	8d 50 04             	lea    0x4(%eax),%edx
  800835:	89 55 14             	mov    %edx,0x14(%ebp)
  800838:	8b 30                	mov    (%eax),%esi
  80083a:	85 f6                	test   %esi,%esi
  80083c:	75 05                	jne    800843 <vprintfmt+0x185>
				p = "(null)";
  80083e:	be ee 10 80 00       	mov    $0x8010ee,%esi
			if (width > 0 && padc != '-')
  800843:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800847:	0f 8e 84 00 00 00    	jle    8008d1 <vprintfmt+0x213>
  80084d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800851:	74 7e                	je     8008d1 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800853:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800857:	89 34 24             	mov    %esi,(%esp)
  80085a:	e8 8b 02 00 00       	call   800aea <strnlen>
  80085f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800862:	29 c2                	sub    %eax,%edx
  800864:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800867:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80086b:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80086e:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800871:	89 de                	mov    %ebx,%esi
  800873:	89 d3                	mov    %edx,%ebx
  800875:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800877:	eb 0b                	jmp    800884 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800879:	89 74 24 04          	mov    %esi,0x4(%esp)
  80087d:	89 3c 24             	mov    %edi,(%esp)
  800880:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800883:	4b                   	dec    %ebx
  800884:	85 db                	test   %ebx,%ebx
  800886:	7f f1                	jg     800879 <vprintfmt+0x1bb>
  800888:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80088b:	89 f3                	mov    %esi,%ebx
  80088d:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800890:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800893:	85 c0                	test   %eax,%eax
  800895:	79 05                	jns    80089c <vprintfmt+0x1de>
  800897:	b8 00 00 00 00       	mov    $0x0,%eax
  80089c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80089f:	29 c2                	sub    %eax,%edx
  8008a1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8008a4:	eb 2b                	jmp    8008d1 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008a6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8008aa:	74 18                	je     8008c4 <vprintfmt+0x206>
  8008ac:	8d 50 e0             	lea    -0x20(%eax),%edx
  8008af:	83 fa 5e             	cmp    $0x5e,%edx
  8008b2:	76 10                	jbe    8008c4 <vprintfmt+0x206>
					putch('?', putdat);
  8008b4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008b8:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8008bf:	ff 55 08             	call   *0x8(%ebp)
  8008c2:	eb 0a                	jmp    8008ce <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8008c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008c8:	89 04 24             	mov    %eax,(%esp)
  8008cb:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008ce:	ff 4d e4             	decl   -0x1c(%ebp)
  8008d1:	0f be 06             	movsbl (%esi),%eax
  8008d4:	46                   	inc    %esi
  8008d5:	85 c0                	test   %eax,%eax
  8008d7:	74 21                	je     8008fa <vprintfmt+0x23c>
  8008d9:	85 ff                	test   %edi,%edi
  8008db:	78 c9                	js     8008a6 <vprintfmt+0x1e8>
  8008dd:	4f                   	dec    %edi
  8008de:	79 c6                	jns    8008a6 <vprintfmt+0x1e8>
  8008e0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e3:	89 de                	mov    %ebx,%esi
  8008e5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8008e8:	eb 18                	jmp    800902 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8008ea:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008ee:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8008f5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8008f7:	4b                   	dec    %ebx
  8008f8:	eb 08                	jmp    800902 <vprintfmt+0x244>
  8008fa:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008fd:	89 de                	mov    %ebx,%esi
  8008ff:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800902:	85 db                	test   %ebx,%ebx
  800904:	7f e4                	jg     8008ea <vprintfmt+0x22c>
  800906:	89 7d 08             	mov    %edi,0x8(%ebp)
  800909:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80090b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80090e:	e9 ce fd ff ff       	jmp    8006e1 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800913:	83 f9 01             	cmp    $0x1,%ecx
  800916:	7e 10                	jle    800928 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800918:	8b 45 14             	mov    0x14(%ebp),%eax
  80091b:	8d 50 08             	lea    0x8(%eax),%edx
  80091e:	89 55 14             	mov    %edx,0x14(%ebp)
  800921:	8b 30                	mov    (%eax),%esi
  800923:	8b 78 04             	mov    0x4(%eax),%edi
  800926:	eb 26                	jmp    80094e <vprintfmt+0x290>
	else if (lflag)
  800928:	85 c9                	test   %ecx,%ecx
  80092a:	74 12                	je     80093e <vprintfmt+0x280>
		return va_arg(*ap, long);
  80092c:	8b 45 14             	mov    0x14(%ebp),%eax
  80092f:	8d 50 04             	lea    0x4(%eax),%edx
  800932:	89 55 14             	mov    %edx,0x14(%ebp)
  800935:	8b 30                	mov    (%eax),%esi
  800937:	89 f7                	mov    %esi,%edi
  800939:	c1 ff 1f             	sar    $0x1f,%edi
  80093c:	eb 10                	jmp    80094e <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80093e:	8b 45 14             	mov    0x14(%ebp),%eax
  800941:	8d 50 04             	lea    0x4(%eax),%edx
  800944:	89 55 14             	mov    %edx,0x14(%ebp)
  800947:	8b 30                	mov    (%eax),%esi
  800949:	89 f7                	mov    %esi,%edi
  80094b:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80094e:	85 ff                	test   %edi,%edi
  800950:	78 0a                	js     80095c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800952:	b8 0a 00 00 00       	mov    $0xa,%eax
  800957:	e9 8c 00 00 00       	jmp    8009e8 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80095c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800960:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800967:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80096a:	f7 de                	neg    %esi
  80096c:	83 d7 00             	adc    $0x0,%edi
  80096f:	f7 df                	neg    %edi
			}
			base = 10;
  800971:	b8 0a 00 00 00       	mov    $0xa,%eax
  800976:	eb 70                	jmp    8009e8 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800978:	89 ca                	mov    %ecx,%edx
  80097a:	8d 45 14             	lea    0x14(%ebp),%eax
  80097d:	e8 c0 fc ff ff       	call   800642 <getuint>
  800982:	89 c6                	mov    %eax,%esi
  800984:	89 d7                	mov    %edx,%edi
			base = 10;
  800986:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80098b:	eb 5b                	jmp    8009e8 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  80098d:	89 ca                	mov    %ecx,%edx
  80098f:	8d 45 14             	lea    0x14(%ebp),%eax
  800992:	e8 ab fc ff ff       	call   800642 <getuint>
  800997:	89 c6                	mov    %eax,%esi
  800999:	89 d7                	mov    %edx,%edi
			base = 8;
  80099b:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8009a0:	eb 46                	jmp    8009e8 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  8009a2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009a6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8009ad:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8009b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009b4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8009bb:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8009be:	8b 45 14             	mov    0x14(%ebp),%eax
  8009c1:	8d 50 04             	lea    0x4(%eax),%edx
  8009c4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8009c7:	8b 30                	mov    (%eax),%esi
  8009c9:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8009ce:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8009d3:	eb 13                	jmp    8009e8 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8009d5:	89 ca                	mov    %ecx,%edx
  8009d7:	8d 45 14             	lea    0x14(%ebp),%eax
  8009da:	e8 63 fc ff ff       	call   800642 <getuint>
  8009df:	89 c6                	mov    %eax,%esi
  8009e1:	89 d7                	mov    %edx,%edi
			base = 16;
  8009e3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8009e8:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8009ec:	89 54 24 10          	mov    %edx,0x10(%esp)
  8009f0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8009f3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8009f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009fb:	89 34 24             	mov    %esi,(%esp)
  8009fe:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a02:	89 da                	mov    %ebx,%edx
  800a04:	8b 45 08             	mov    0x8(%ebp),%eax
  800a07:	e8 6c fb ff ff       	call   800578 <printnum>
			break;
  800a0c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800a0f:	e9 cd fc ff ff       	jmp    8006e1 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a14:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a18:	89 04 24             	mov    %eax,(%esp)
  800a1b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a1e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a21:	e9 bb fc ff ff       	jmp    8006e1 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a26:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a2a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a31:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a34:	eb 01                	jmp    800a37 <vprintfmt+0x379>
  800a36:	4e                   	dec    %esi
  800a37:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800a3b:	75 f9                	jne    800a36 <vprintfmt+0x378>
  800a3d:	e9 9f fc ff ff       	jmp    8006e1 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800a42:	83 c4 4c             	add    $0x4c,%esp
  800a45:	5b                   	pop    %ebx
  800a46:	5e                   	pop    %esi
  800a47:	5f                   	pop    %edi
  800a48:	5d                   	pop    %ebp
  800a49:	c3                   	ret    

00800a4a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a4a:	55                   	push   %ebp
  800a4b:	89 e5                	mov    %esp,%ebp
  800a4d:	83 ec 28             	sub    $0x28,%esp
  800a50:	8b 45 08             	mov    0x8(%ebp),%eax
  800a53:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a56:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a59:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a5d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a60:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a67:	85 c0                	test   %eax,%eax
  800a69:	74 30                	je     800a9b <vsnprintf+0x51>
  800a6b:	85 d2                	test   %edx,%edx
  800a6d:	7e 33                	jle    800aa2 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a6f:	8b 45 14             	mov    0x14(%ebp),%eax
  800a72:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a76:	8b 45 10             	mov    0x10(%ebp),%eax
  800a79:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a7d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a80:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a84:	c7 04 24 7c 06 80 00 	movl   $0x80067c,(%esp)
  800a8b:	e8 2e fc ff ff       	call   8006be <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a90:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a93:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a96:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a99:	eb 0c                	jmp    800aa7 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a9b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800aa0:	eb 05                	jmp    800aa7 <vsnprintf+0x5d>
  800aa2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800aa7:	c9                   	leave  
  800aa8:	c3                   	ret    

00800aa9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800aa9:	55                   	push   %ebp
  800aaa:	89 e5                	mov    %esp,%ebp
  800aac:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800aaf:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800ab2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ab6:	8b 45 10             	mov    0x10(%ebp),%eax
  800ab9:	89 44 24 08          	mov    %eax,0x8(%esp)
  800abd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ac4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac7:	89 04 24             	mov    %eax,(%esp)
  800aca:	e8 7b ff ff ff       	call   800a4a <vsnprintf>
	va_end(ap);

	return rc;
}
  800acf:	c9                   	leave  
  800ad0:	c3                   	ret    
  800ad1:	00 00                	add    %al,(%eax)
	...

00800ad4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ad4:	55                   	push   %ebp
  800ad5:	89 e5                	mov    %esp,%ebp
  800ad7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ada:	b8 00 00 00 00       	mov    $0x0,%eax
  800adf:	eb 01                	jmp    800ae2 <strlen+0xe>
		n++;
  800ae1:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800ae2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ae6:	75 f9                	jne    800ae1 <strlen+0xd>
		n++;
	return n;
}
  800ae8:	5d                   	pop    %ebp
  800ae9:	c3                   	ret    

00800aea <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800aea:	55                   	push   %ebp
  800aeb:	89 e5                	mov    %esp,%ebp
  800aed:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800af0:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800af3:	b8 00 00 00 00       	mov    $0x0,%eax
  800af8:	eb 01                	jmp    800afb <strnlen+0x11>
		n++;
  800afa:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800afb:	39 d0                	cmp    %edx,%eax
  800afd:	74 06                	je     800b05 <strnlen+0x1b>
  800aff:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800b03:	75 f5                	jne    800afa <strnlen+0x10>
		n++;
	return n;
}
  800b05:	5d                   	pop    %ebp
  800b06:	c3                   	ret    

00800b07 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b07:	55                   	push   %ebp
  800b08:	89 e5                	mov    %esp,%ebp
  800b0a:	53                   	push   %ebx
  800b0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b11:	ba 00 00 00 00       	mov    $0x0,%edx
  800b16:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800b19:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800b1c:	42                   	inc    %edx
  800b1d:	84 c9                	test   %cl,%cl
  800b1f:	75 f5                	jne    800b16 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800b21:	5b                   	pop    %ebx
  800b22:	5d                   	pop    %ebp
  800b23:	c3                   	ret    

00800b24 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
  800b27:	53                   	push   %ebx
  800b28:	83 ec 08             	sub    $0x8,%esp
  800b2b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b2e:	89 1c 24             	mov    %ebx,(%esp)
  800b31:	e8 9e ff ff ff       	call   800ad4 <strlen>
	strcpy(dst + len, src);
  800b36:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b39:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b3d:	01 d8                	add    %ebx,%eax
  800b3f:	89 04 24             	mov    %eax,(%esp)
  800b42:	e8 c0 ff ff ff       	call   800b07 <strcpy>
	return dst;
}
  800b47:	89 d8                	mov    %ebx,%eax
  800b49:	83 c4 08             	add    $0x8,%esp
  800b4c:	5b                   	pop    %ebx
  800b4d:	5d                   	pop    %ebp
  800b4e:	c3                   	ret    

00800b4f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b4f:	55                   	push   %ebp
  800b50:	89 e5                	mov    %esp,%ebp
  800b52:	56                   	push   %esi
  800b53:	53                   	push   %ebx
  800b54:	8b 45 08             	mov    0x8(%ebp),%eax
  800b57:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b5a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b5d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b62:	eb 0c                	jmp    800b70 <strncpy+0x21>
		*dst++ = *src;
  800b64:	8a 1a                	mov    (%edx),%bl
  800b66:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b69:	80 3a 01             	cmpb   $0x1,(%edx)
  800b6c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b6f:	41                   	inc    %ecx
  800b70:	39 f1                	cmp    %esi,%ecx
  800b72:	75 f0                	jne    800b64 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b74:	5b                   	pop    %ebx
  800b75:	5e                   	pop    %esi
  800b76:	5d                   	pop    %ebp
  800b77:	c3                   	ret    

00800b78 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b78:	55                   	push   %ebp
  800b79:	89 e5                	mov    %esp,%ebp
  800b7b:	56                   	push   %esi
  800b7c:	53                   	push   %ebx
  800b7d:	8b 75 08             	mov    0x8(%ebp),%esi
  800b80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b83:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b86:	85 d2                	test   %edx,%edx
  800b88:	75 0a                	jne    800b94 <strlcpy+0x1c>
  800b8a:	89 f0                	mov    %esi,%eax
  800b8c:	eb 1a                	jmp    800ba8 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b8e:	88 18                	mov    %bl,(%eax)
  800b90:	40                   	inc    %eax
  800b91:	41                   	inc    %ecx
  800b92:	eb 02                	jmp    800b96 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b94:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800b96:	4a                   	dec    %edx
  800b97:	74 0a                	je     800ba3 <strlcpy+0x2b>
  800b99:	8a 19                	mov    (%ecx),%bl
  800b9b:	84 db                	test   %bl,%bl
  800b9d:	75 ef                	jne    800b8e <strlcpy+0x16>
  800b9f:	89 c2                	mov    %eax,%edx
  800ba1:	eb 02                	jmp    800ba5 <strlcpy+0x2d>
  800ba3:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800ba5:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800ba8:	29 f0                	sub    %esi,%eax
}
  800baa:	5b                   	pop    %ebx
  800bab:	5e                   	pop    %esi
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    

00800bae <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bb4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bb7:	eb 02                	jmp    800bbb <strcmp+0xd>
		p++, q++;
  800bb9:	41                   	inc    %ecx
  800bba:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800bbb:	8a 01                	mov    (%ecx),%al
  800bbd:	84 c0                	test   %al,%al
  800bbf:	74 04                	je     800bc5 <strcmp+0x17>
  800bc1:	3a 02                	cmp    (%edx),%al
  800bc3:	74 f4                	je     800bb9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800bc5:	0f b6 c0             	movzbl %al,%eax
  800bc8:	0f b6 12             	movzbl (%edx),%edx
  800bcb:	29 d0                	sub    %edx,%eax
}
  800bcd:	5d                   	pop    %ebp
  800bce:	c3                   	ret    

00800bcf <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800bcf:	55                   	push   %ebp
  800bd0:	89 e5                	mov    %esp,%ebp
  800bd2:	53                   	push   %ebx
  800bd3:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd9:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800bdc:	eb 03                	jmp    800be1 <strncmp+0x12>
		n--, p++, q++;
  800bde:	4a                   	dec    %edx
  800bdf:	40                   	inc    %eax
  800be0:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800be1:	85 d2                	test   %edx,%edx
  800be3:	74 14                	je     800bf9 <strncmp+0x2a>
  800be5:	8a 18                	mov    (%eax),%bl
  800be7:	84 db                	test   %bl,%bl
  800be9:	74 04                	je     800bef <strncmp+0x20>
  800beb:	3a 19                	cmp    (%ecx),%bl
  800bed:	74 ef                	je     800bde <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800bef:	0f b6 00             	movzbl (%eax),%eax
  800bf2:	0f b6 11             	movzbl (%ecx),%edx
  800bf5:	29 d0                	sub    %edx,%eax
  800bf7:	eb 05                	jmp    800bfe <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800bf9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800bfe:	5b                   	pop    %ebx
  800bff:	5d                   	pop    %ebp
  800c00:	c3                   	ret    

00800c01 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c01:	55                   	push   %ebp
  800c02:	89 e5                	mov    %esp,%ebp
  800c04:	8b 45 08             	mov    0x8(%ebp),%eax
  800c07:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800c0a:	eb 05                	jmp    800c11 <strchr+0x10>
		if (*s == c)
  800c0c:	38 ca                	cmp    %cl,%dl
  800c0e:	74 0c                	je     800c1c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c10:	40                   	inc    %eax
  800c11:	8a 10                	mov    (%eax),%dl
  800c13:	84 d2                	test   %dl,%dl
  800c15:	75 f5                	jne    800c0c <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800c17:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c1c:	5d                   	pop    %ebp
  800c1d:	c3                   	ret    

00800c1e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c1e:	55                   	push   %ebp
  800c1f:	89 e5                	mov    %esp,%ebp
  800c21:	8b 45 08             	mov    0x8(%ebp),%eax
  800c24:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800c27:	eb 05                	jmp    800c2e <strfind+0x10>
		if (*s == c)
  800c29:	38 ca                	cmp    %cl,%dl
  800c2b:	74 07                	je     800c34 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c2d:	40                   	inc    %eax
  800c2e:	8a 10                	mov    (%eax),%dl
  800c30:	84 d2                	test   %dl,%dl
  800c32:	75 f5                	jne    800c29 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800c34:	5d                   	pop    %ebp
  800c35:	c3                   	ret    

00800c36 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c36:	55                   	push   %ebp
  800c37:	89 e5                	mov    %esp,%ebp
  800c39:	57                   	push   %edi
  800c3a:	56                   	push   %esi
  800c3b:	53                   	push   %ebx
  800c3c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c3f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c42:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c45:	85 c9                	test   %ecx,%ecx
  800c47:	74 30                	je     800c79 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c49:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c4f:	75 25                	jne    800c76 <memset+0x40>
  800c51:	f6 c1 03             	test   $0x3,%cl
  800c54:	75 20                	jne    800c76 <memset+0x40>
		c &= 0xFF;
  800c56:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c59:	89 d3                	mov    %edx,%ebx
  800c5b:	c1 e3 08             	shl    $0x8,%ebx
  800c5e:	89 d6                	mov    %edx,%esi
  800c60:	c1 e6 18             	shl    $0x18,%esi
  800c63:	89 d0                	mov    %edx,%eax
  800c65:	c1 e0 10             	shl    $0x10,%eax
  800c68:	09 f0                	or     %esi,%eax
  800c6a:	09 d0                	or     %edx,%eax
  800c6c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c6e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800c71:	fc                   	cld    
  800c72:	f3 ab                	rep stos %eax,%es:(%edi)
  800c74:	eb 03                	jmp    800c79 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c76:	fc                   	cld    
  800c77:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c79:	89 f8                	mov    %edi,%eax
  800c7b:	5b                   	pop    %ebx
  800c7c:	5e                   	pop    %esi
  800c7d:	5f                   	pop    %edi
  800c7e:	5d                   	pop    %ebp
  800c7f:	c3                   	ret    

00800c80 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c80:	55                   	push   %ebp
  800c81:	89 e5                	mov    %esp,%ebp
  800c83:	57                   	push   %edi
  800c84:	56                   	push   %esi
  800c85:	8b 45 08             	mov    0x8(%ebp),%eax
  800c88:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c8b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c8e:	39 c6                	cmp    %eax,%esi
  800c90:	73 34                	jae    800cc6 <memmove+0x46>
  800c92:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c95:	39 d0                	cmp    %edx,%eax
  800c97:	73 2d                	jae    800cc6 <memmove+0x46>
		s += n;
		d += n;
  800c99:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c9c:	f6 c2 03             	test   $0x3,%dl
  800c9f:	75 1b                	jne    800cbc <memmove+0x3c>
  800ca1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ca7:	75 13                	jne    800cbc <memmove+0x3c>
  800ca9:	f6 c1 03             	test   $0x3,%cl
  800cac:	75 0e                	jne    800cbc <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800cae:	83 ef 04             	sub    $0x4,%edi
  800cb1:	8d 72 fc             	lea    -0x4(%edx),%esi
  800cb4:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800cb7:	fd                   	std    
  800cb8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cba:	eb 07                	jmp    800cc3 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800cbc:	4f                   	dec    %edi
  800cbd:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800cc0:	fd                   	std    
  800cc1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800cc3:	fc                   	cld    
  800cc4:	eb 20                	jmp    800ce6 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cc6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ccc:	75 13                	jne    800ce1 <memmove+0x61>
  800cce:	a8 03                	test   $0x3,%al
  800cd0:	75 0f                	jne    800ce1 <memmove+0x61>
  800cd2:	f6 c1 03             	test   $0x3,%cl
  800cd5:	75 0a                	jne    800ce1 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800cd7:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800cda:	89 c7                	mov    %eax,%edi
  800cdc:	fc                   	cld    
  800cdd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cdf:	eb 05                	jmp    800ce6 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ce1:	89 c7                	mov    %eax,%edi
  800ce3:	fc                   	cld    
  800ce4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ce6:	5e                   	pop    %esi
  800ce7:	5f                   	pop    %edi
  800ce8:	5d                   	pop    %ebp
  800ce9:	c3                   	ret    

00800cea <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800cea:	55                   	push   %ebp
  800ceb:	89 e5                	mov    %esp,%ebp
  800ced:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800cf0:	8b 45 10             	mov    0x10(%ebp),%eax
  800cf3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cf7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cfa:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cfe:	8b 45 08             	mov    0x8(%ebp),%eax
  800d01:	89 04 24             	mov    %eax,(%esp)
  800d04:	e8 77 ff ff ff       	call   800c80 <memmove>
}
  800d09:	c9                   	leave  
  800d0a:	c3                   	ret    

00800d0b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d0b:	55                   	push   %ebp
  800d0c:	89 e5                	mov    %esp,%ebp
  800d0e:	57                   	push   %edi
  800d0f:	56                   	push   %esi
  800d10:	53                   	push   %ebx
  800d11:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d14:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d17:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d1a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d1f:	eb 16                	jmp    800d37 <memcmp+0x2c>
		if (*s1 != *s2)
  800d21:	8a 04 17             	mov    (%edi,%edx,1),%al
  800d24:	42                   	inc    %edx
  800d25:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800d29:	38 c8                	cmp    %cl,%al
  800d2b:	74 0a                	je     800d37 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800d2d:	0f b6 c0             	movzbl %al,%eax
  800d30:	0f b6 c9             	movzbl %cl,%ecx
  800d33:	29 c8                	sub    %ecx,%eax
  800d35:	eb 09                	jmp    800d40 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d37:	39 da                	cmp    %ebx,%edx
  800d39:	75 e6                	jne    800d21 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d3b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d40:	5b                   	pop    %ebx
  800d41:	5e                   	pop    %esi
  800d42:	5f                   	pop    %edi
  800d43:	5d                   	pop    %ebp
  800d44:	c3                   	ret    

00800d45 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d45:	55                   	push   %ebp
  800d46:	89 e5                	mov    %esp,%ebp
  800d48:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800d4e:	89 c2                	mov    %eax,%edx
  800d50:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d53:	eb 05                	jmp    800d5a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d55:	38 08                	cmp    %cl,(%eax)
  800d57:	74 05                	je     800d5e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d59:	40                   	inc    %eax
  800d5a:	39 d0                	cmp    %edx,%eax
  800d5c:	72 f7                	jb     800d55 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d5e:	5d                   	pop    %ebp
  800d5f:	c3                   	ret    

00800d60 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d60:	55                   	push   %ebp
  800d61:	89 e5                	mov    %esp,%ebp
  800d63:	57                   	push   %edi
  800d64:	56                   	push   %esi
  800d65:	53                   	push   %ebx
  800d66:	8b 55 08             	mov    0x8(%ebp),%edx
  800d69:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d6c:	eb 01                	jmp    800d6f <strtol+0xf>
		s++;
  800d6e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d6f:	8a 02                	mov    (%edx),%al
  800d71:	3c 20                	cmp    $0x20,%al
  800d73:	74 f9                	je     800d6e <strtol+0xe>
  800d75:	3c 09                	cmp    $0x9,%al
  800d77:	74 f5                	je     800d6e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d79:	3c 2b                	cmp    $0x2b,%al
  800d7b:	75 08                	jne    800d85 <strtol+0x25>
		s++;
  800d7d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d7e:	bf 00 00 00 00       	mov    $0x0,%edi
  800d83:	eb 13                	jmp    800d98 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d85:	3c 2d                	cmp    $0x2d,%al
  800d87:	75 0a                	jne    800d93 <strtol+0x33>
		s++, neg = 1;
  800d89:	8d 52 01             	lea    0x1(%edx),%edx
  800d8c:	bf 01 00 00 00       	mov    $0x1,%edi
  800d91:	eb 05                	jmp    800d98 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d93:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d98:	85 db                	test   %ebx,%ebx
  800d9a:	74 05                	je     800da1 <strtol+0x41>
  800d9c:	83 fb 10             	cmp    $0x10,%ebx
  800d9f:	75 28                	jne    800dc9 <strtol+0x69>
  800da1:	8a 02                	mov    (%edx),%al
  800da3:	3c 30                	cmp    $0x30,%al
  800da5:	75 10                	jne    800db7 <strtol+0x57>
  800da7:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800dab:	75 0a                	jne    800db7 <strtol+0x57>
		s += 2, base = 16;
  800dad:	83 c2 02             	add    $0x2,%edx
  800db0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800db5:	eb 12                	jmp    800dc9 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800db7:	85 db                	test   %ebx,%ebx
  800db9:	75 0e                	jne    800dc9 <strtol+0x69>
  800dbb:	3c 30                	cmp    $0x30,%al
  800dbd:	75 05                	jne    800dc4 <strtol+0x64>
		s++, base = 8;
  800dbf:	42                   	inc    %edx
  800dc0:	b3 08                	mov    $0x8,%bl
  800dc2:	eb 05                	jmp    800dc9 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800dc4:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800dc9:	b8 00 00 00 00       	mov    $0x0,%eax
  800dce:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800dd0:	8a 0a                	mov    (%edx),%cl
  800dd2:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800dd5:	80 fb 09             	cmp    $0x9,%bl
  800dd8:	77 08                	ja     800de2 <strtol+0x82>
			dig = *s - '0';
  800dda:	0f be c9             	movsbl %cl,%ecx
  800ddd:	83 e9 30             	sub    $0x30,%ecx
  800de0:	eb 1e                	jmp    800e00 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800de2:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800de5:	80 fb 19             	cmp    $0x19,%bl
  800de8:	77 08                	ja     800df2 <strtol+0x92>
			dig = *s - 'a' + 10;
  800dea:	0f be c9             	movsbl %cl,%ecx
  800ded:	83 e9 57             	sub    $0x57,%ecx
  800df0:	eb 0e                	jmp    800e00 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800df2:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800df5:	80 fb 19             	cmp    $0x19,%bl
  800df8:	77 12                	ja     800e0c <strtol+0xac>
			dig = *s - 'A' + 10;
  800dfa:	0f be c9             	movsbl %cl,%ecx
  800dfd:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800e00:	39 f1                	cmp    %esi,%ecx
  800e02:	7d 0c                	jge    800e10 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800e04:	42                   	inc    %edx
  800e05:	0f af c6             	imul   %esi,%eax
  800e08:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800e0a:	eb c4                	jmp    800dd0 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800e0c:	89 c1                	mov    %eax,%ecx
  800e0e:	eb 02                	jmp    800e12 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800e10:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800e12:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e16:	74 05                	je     800e1d <strtol+0xbd>
		*endptr = (char *) s;
  800e18:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e1b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800e1d:	85 ff                	test   %edi,%edi
  800e1f:	74 04                	je     800e25 <strtol+0xc5>
  800e21:	89 c8                	mov    %ecx,%eax
  800e23:	f7 d8                	neg    %eax
}
  800e25:	5b                   	pop    %ebx
  800e26:	5e                   	pop    %esi
  800e27:	5f                   	pop    %edi
  800e28:	5d                   	pop    %ebp
  800e29:	c3                   	ret    
	...

00800e2c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800e2c:	55                   	push   %ebp
  800e2d:	57                   	push   %edi
  800e2e:	56                   	push   %esi
  800e2f:	83 ec 10             	sub    $0x10,%esp
  800e32:	8b 74 24 20          	mov    0x20(%esp),%esi
  800e36:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800e3a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e3e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  800e42:	89 cd                	mov    %ecx,%ebp
  800e44:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e48:	85 c0                	test   %eax,%eax
  800e4a:	75 2c                	jne    800e78 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800e4c:	39 f9                	cmp    %edi,%ecx
  800e4e:	77 68                	ja     800eb8 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800e50:	85 c9                	test   %ecx,%ecx
  800e52:	75 0b                	jne    800e5f <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800e54:	b8 01 00 00 00       	mov    $0x1,%eax
  800e59:	31 d2                	xor    %edx,%edx
  800e5b:	f7 f1                	div    %ecx
  800e5d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800e5f:	31 d2                	xor    %edx,%edx
  800e61:	89 f8                	mov    %edi,%eax
  800e63:	f7 f1                	div    %ecx
  800e65:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e67:	89 f0                	mov    %esi,%eax
  800e69:	f7 f1                	div    %ecx
  800e6b:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e6d:	89 f0                	mov    %esi,%eax
  800e6f:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e71:	83 c4 10             	add    $0x10,%esp
  800e74:	5e                   	pop    %esi
  800e75:	5f                   	pop    %edi
  800e76:	5d                   	pop    %ebp
  800e77:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e78:	39 f8                	cmp    %edi,%eax
  800e7a:	77 2c                	ja     800ea8 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e7c:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  800e7f:	83 f6 1f             	xor    $0x1f,%esi
  800e82:	75 4c                	jne    800ed0 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e84:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e86:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e8b:	72 0a                	jb     800e97 <__udivdi3+0x6b>
  800e8d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800e91:	0f 87 ad 00 00 00    	ja     800f44 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e97:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e9c:	89 f0                	mov    %esi,%eax
  800e9e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800ea0:	83 c4 10             	add    $0x10,%esp
  800ea3:	5e                   	pop    %esi
  800ea4:	5f                   	pop    %edi
  800ea5:	5d                   	pop    %ebp
  800ea6:	c3                   	ret    
  800ea7:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800ea8:	31 ff                	xor    %edi,%edi
  800eaa:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800eac:	89 f0                	mov    %esi,%eax
  800eae:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800eb0:	83 c4 10             	add    $0x10,%esp
  800eb3:	5e                   	pop    %esi
  800eb4:	5f                   	pop    %edi
  800eb5:	5d                   	pop    %ebp
  800eb6:	c3                   	ret    
  800eb7:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800eb8:	89 fa                	mov    %edi,%edx
  800eba:	89 f0                	mov    %esi,%eax
  800ebc:	f7 f1                	div    %ecx
  800ebe:	89 c6                	mov    %eax,%esi
  800ec0:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800ec2:	89 f0                	mov    %esi,%eax
  800ec4:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800ec6:	83 c4 10             	add    $0x10,%esp
  800ec9:	5e                   	pop    %esi
  800eca:	5f                   	pop    %edi
  800ecb:	5d                   	pop    %ebp
  800ecc:	c3                   	ret    
  800ecd:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800ed0:	89 f1                	mov    %esi,%ecx
  800ed2:	d3 e0                	shl    %cl,%eax
  800ed4:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800ed8:	b8 20 00 00 00       	mov    $0x20,%eax
  800edd:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800edf:	89 ea                	mov    %ebp,%edx
  800ee1:	88 c1                	mov    %al,%cl
  800ee3:	d3 ea                	shr    %cl,%edx
  800ee5:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800ee9:	09 ca                	or     %ecx,%edx
  800eeb:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  800eef:	89 f1                	mov    %esi,%ecx
  800ef1:	d3 e5                	shl    %cl,%ebp
  800ef3:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  800ef7:	89 fd                	mov    %edi,%ebp
  800ef9:	88 c1                	mov    %al,%cl
  800efb:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  800efd:	89 fa                	mov    %edi,%edx
  800eff:	89 f1                	mov    %esi,%ecx
  800f01:	d3 e2                	shl    %cl,%edx
  800f03:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f07:	88 c1                	mov    %al,%cl
  800f09:	d3 ef                	shr    %cl,%edi
  800f0b:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800f0d:	89 f8                	mov    %edi,%eax
  800f0f:	89 ea                	mov    %ebp,%edx
  800f11:	f7 74 24 08          	divl   0x8(%esp)
  800f15:	89 d1                	mov    %edx,%ecx
  800f17:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  800f19:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f1d:	39 d1                	cmp    %edx,%ecx
  800f1f:	72 17                	jb     800f38 <__udivdi3+0x10c>
  800f21:	74 09                	je     800f2c <__udivdi3+0x100>
  800f23:	89 fe                	mov    %edi,%esi
  800f25:	31 ff                	xor    %edi,%edi
  800f27:	e9 41 ff ff ff       	jmp    800e6d <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800f2c:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f30:	89 f1                	mov    %esi,%ecx
  800f32:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f34:	39 c2                	cmp    %eax,%edx
  800f36:	73 eb                	jae    800f23 <__udivdi3+0xf7>
		{
		  q0--;
  800f38:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f3b:	31 ff                	xor    %edi,%edi
  800f3d:	e9 2b ff ff ff       	jmp    800e6d <__udivdi3+0x41>
  800f42:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800f44:	31 f6                	xor    %esi,%esi
  800f46:	e9 22 ff ff ff       	jmp    800e6d <__udivdi3+0x41>
	...

00800f4c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800f4c:	55                   	push   %ebp
  800f4d:	57                   	push   %edi
  800f4e:	56                   	push   %esi
  800f4f:	83 ec 20             	sub    $0x20,%esp
  800f52:	8b 44 24 30          	mov    0x30(%esp),%eax
  800f56:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800f5a:	89 44 24 14          	mov    %eax,0x14(%esp)
  800f5e:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  800f62:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800f66:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800f6a:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  800f6c:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800f6e:	85 ed                	test   %ebp,%ebp
  800f70:	75 16                	jne    800f88 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  800f72:	39 f1                	cmp    %esi,%ecx
  800f74:	0f 86 a6 00 00 00    	jbe    801020 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f7a:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800f7c:	89 d0                	mov    %edx,%eax
  800f7e:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f80:	83 c4 20             	add    $0x20,%esp
  800f83:	5e                   	pop    %esi
  800f84:	5f                   	pop    %edi
  800f85:	5d                   	pop    %ebp
  800f86:	c3                   	ret    
  800f87:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800f88:	39 f5                	cmp    %esi,%ebp
  800f8a:	0f 87 ac 00 00 00    	ja     80103c <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800f90:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  800f93:	83 f0 1f             	xor    $0x1f,%eax
  800f96:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f9a:	0f 84 a8 00 00 00    	je     801048 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800fa0:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800fa4:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800fa6:	bf 20 00 00 00       	mov    $0x20,%edi
  800fab:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800faf:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800fb3:	89 f9                	mov    %edi,%ecx
  800fb5:	d3 e8                	shr    %cl,%eax
  800fb7:	09 e8                	or     %ebp,%eax
  800fb9:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  800fbd:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800fc1:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800fc5:	d3 e0                	shl    %cl,%eax
  800fc7:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800fcb:	89 f2                	mov    %esi,%edx
  800fcd:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800fcf:	8b 44 24 14          	mov    0x14(%esp),%eax
  800fd3:	d3 e0                	shl    %cl,%eax
  800fd5:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800fd9:	8b 44 24 14          	mov    0x14(%esp),%eax
  800fdd:	89 f9                	mov    %edi,%ecx
  800fdf:	d3 e8                	shr    %cl,%eax
  800fe1:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800fe3:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800fe5:	89 f2                	mov    %esi,%edx
  800fe7:	f7 74 24 18          	divl   0x18(%esp)
  800feb:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800fed:	f7 64 24 0c          	mull   0xc(%esp)
  800ff1:	89 c5                	mov    %eax,%ebp
  800ff3:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ff5:	39 d6                	cmp    %edx,%esi
  800ff7:	72 67                	jb     801060 <__umoddi3+0x114>
  800ff9:	74 75                	je     801070 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800ffb:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800fff:	29 e8                	sub    %ebp,%eax
  801001:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801003:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801007:	d3 e8                	shr    %cl,%eax
  801009:	89 f2                	mov    %esi,%edx
  80100b:	89 f9                	mov    %edi,%ecx
  80100d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80100f:	09 d0                	or     %edx,%eax
  801011:	89 f2                	mov    %esi,%edx
  801013:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801017:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801019:	83 c4 20             	add    $0x20,%esp
  80101c:	5e                   	pop    %esi
  80101d:	5f                   	pop    %edi
  80101e:	5d                   	pop    %ebp
  80101f:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801020:	85 c9                	test   %ecx,%ecx
  801022:	75 0b                	jne    80102f <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801024:	b8 01 00 00 00       	mov    $0x1,%eax
  801029:	31 d2                	xor    %edx,%edx
  80102b:	f7 f1                	div    %ecx
  80102d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80102f:	89 f0                	mov    %esi,%eax
  801031:	31 d2                	xor    %edx,%edx
  801033:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801035:	89 f8                	mov    %edi,%eax
  801037:	e9 3e ff ff ff       	jmp    800f7a <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  80103c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80103e:	83 c4 20             	add    $0x20,%esp
  801041:	5e                   	pop    %esi
  801042:	5f                   	pop    %edi
  801043:	5d                   	pop    %ebp
  801044:	c3                   	ret    
  801045:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801048:	39 f5                	cmp    %esi,%ebp
  80104a:	72 04                	jb     801050 <__umoddi3+0x104>
  80104c:	39 f9                	cmp    %edi,%ecx
  80104e:	77 06                	ja     801056 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801050:	89 f2                	mov    %esi,%edx
  801052:	29 cf                	sub    %ecx,%edi
  801054:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801056:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801058:	83 c4 20             	add    $0x20,%esp
  80105b:	5e                   	pop    %esi
  80105c:	5f                   	pop    %edi
  80105d:	5d                   	pop    %ebp
  80105e:	c3                   	ret    
  80105f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801060:	89 d1                	mov    %edx,%ecx
  801062:	89 c5                	mov    %eax,%ebp
  801064:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801068:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  80106c:	eb 8d                	jmp    800ffb <__umoddi3+0xaf>
  80106e:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801070:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801074:	72 ea                	jb     801060 <__umoddi3+0x114>
  801076:	89 f1                	mov    %esi,%ecx
  801078:	eb 81                	jmp    800ffb <__umoddi3+0xaf>
