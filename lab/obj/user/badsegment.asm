
obj/user/badsegment.debug:     file format elf32-i386


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
  80002c:	e8 0f 00 00 00       	call   800040 <libmain>
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
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800037:	66 b8 28 00          	mov    $0x28,%ax
  80003b:	8e d8                	mov    %eax,%ds
}
  80003d:	5d                   	pop    %ebp
  80003e:	c3                   	ret    
	...

00800040 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	56                   	push   %esi
  800044:	53                   	push   %ebx
  800045:	83 ec 10             	sub    $0x10,%esp
  800048:	8b 75 08             	mov    0x8(%ebp),%esi
  80004b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80004e:	e8 d8 00 00 00       	call   80012b <sys_getenvid>
  800053:	25 ff 03 00 00       	and    $0x3ff,%eax
  800058:	c1 e0 07             	shl    $0x7,%eax
  80005b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800060:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800065:	85 f6                	test   %esi,%esi
  800067:	7e 07                	jle    800070 <libmain+0x30>
		binaryname = argv[0];
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800070:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800074:	89 34 24             	mov    %esi,(%esp)
  800077:	e8 b8 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80007c:	e8 07 00 00 00       	call   800088 <exit>
}
  800081:	83 c4 10             	add    $0x10,%esp
  800084:	5b                   	pop    %ebx
  800085:	5e                   	pop    %esi
  800086:	5d                   	pop    %ebp
  800087:	c3                   	ret    

00800088 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
  80008b:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  80008e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800095:	e8 3f 00 00 00       	call   8000d9 <sys_env_destroy>
}
  80009a:	c9                   	leave  
  80009b:	c3                   	ret    

0080009c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009c:	55                   	push   %ebp
  80009d:	89 e5                	mov    %esp,%ebp
  80009f:	57                   	push   %edi
  8000a0:	56                   	push   %esi
  8000a1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ad:	89 c3                	mov    %eax,%ebx
  8000af:	89 c7                	mov    %eax,%edi
  8000b1:	89 c6                	mov    %eax,%esi
  8000b3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b5:	5b                   	pop    %ebx
  8000b6:	5e                   	pop    %esi
  8000b7:	5f                   	pop    %edi
  8000b8:	5d                   	pop    %ebp
  8000b9:	c3                   	ret    

008000ba <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ba:	55                   	push   %ebp
  8000bb:	89 e5                	mov    %esp,%ebp
  8000bd:	57                   	push   %edi
  8000be:	56                   	push   %esi
  8000bf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c5:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ca:	89 d1                	mov    %edx,%ecx
  8000cc:	89 d3                	mov    %edx,%ebx
  8000ce:	89 d7                	mov    %edx,%edi
  8000d0:	89 d6                	mov    %edx,%esi
  8000d2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d4:	5b                   	pop    %ebx
  8000d5:	5e                   	pop    %esi
  8000d6:	5f                   	pop    %edi
  8000d7:	5d                   	pop    %ebp
  8000d8:	c3                   	ret    

008000d9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d9:	55                   	push   %ebp
  8000da:	89 e5                	mov    %esp,%ebp
  8000dc:	57                   	push   %edi
  8000dd:	56                   	push   %esi
  8000de:	53                   	push   %ebx
  8000df:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e7:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ec:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ef:	89 cb                	mov    %ecx,%ebx
  8000f1:	89 cf                	mov    %ecx,%edi
  8000f3:	89 ce                	mov    %ecx,%esi
  8000f5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000f7:	85 c0                	test   %eax,%eax
  8000f9:	7e 28                	jle    800123 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000fb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000ff:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800106:	00 
  800107:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  80010e:	00 
  80010f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800116:	00 
  800117:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  80011e:	e8 31 03 00 00       	call   800454 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800123:	83 c4 2c             	add    $0x2c,%esp
  800126:	5b                   	pop    %ebx
  800127:	5e                   	pop    %esi
  800128:	5f                   	pop    %edi
  800129:	5d                   	pop    %ebp
  80012a:	c3                   	ret    

0080012b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012b:	55                   	push   %ebp
  80012c:	89 e5                	mov    %esp,%ebp
  80012e:	57                   	push   %edi
  80012f:	56                   	push   %esi
  800130:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800131:	ba 00 00 00 00       	mov    $0x0,%edx
  800136:	b8 02 00 00 00       	mov    $0x2,%eax
  80013b:	89 d1                	mov    %edx,%ecx
  80013d:	89 d3                	mov    %edx,%ebx
  80013f:	89 d7                	mov    %edx,%edi
  800141:	89 d6                	mov    %edx,%esi
  800143:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800145:	5b                   	pop    %ebx
  800146:	5e                   	pop    %esi
  800147:	5f                   	pop    %edi
  800148:	5d                   	pop    %ebp
  800149:	c3                   	ret    

0080014a <sys_yield>:

void
sys_yield(void)
{
  80014a:	55                   	push   %ebp
  80014b:	89 e5                	mov    %esp,%ebp
  80014d:	57                   	push   %edi
  80014e:	56                   	push   %esi
  80014f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800150:	ba 00 00 00 00       	mov    $0x0,%edx
  800155:	b8 0b 00 00 00       	mov    $0xb,%eax
  80015a:	89 d1                	mov    %edx,%ecx
  80015c:	89 d3                	mov    %edx,%ebx
  80015e:	89 d7                	mov    %edx,%edi
  800160:	89 d6                	mov    %edx,%esi
  800162:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800164:	5b                   	pop    %ebx
  800165:	5e                   	pop    %esi
  800166:	5f                   	pop    %edi
  800167:	5d                   	pop    %ebp
  800168:	c3                   	ret    

00800169 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800169:	55                   	push   %ebp
  80016a:	89 e5                	mov    %esp,%ebp
  80016c:	57                   	push   %edi
  80016d:	56                   	push   %esi
  80016e:	53                   	push   %ebx
  80016f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800172:	be 00 00 00 00       	mov    $0x0,%esi
  800177:	b8 04 00 00 00       	mov    $0x4,%eax
  80017c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800182:	8b 55 08             	mov    0x8(%ebp),%edx
  800185:	89 f7                	mov    %esi,%edi
  800187:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800189:	85 c0                	test   %eax,%eax
  80018b:	7e 28                	jle    8001b5 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  80018d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800191:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800198:	00 
  800199:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  8001a0:	00 
  8001a1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001a8:	00 
  8001a9:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  8001b0:	e8 9f 02 00 00       	call   800454 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001b5:	83 c4 2c             	add    $0x2c,%esp
  8001b8:	5b                   	pop    %ebx
  8001b9:	5e                   	pop    %esi
  8001ba:	5f                   	pop    %edi
  8001bb:	5d                   	pop    %ebp
  8001bc:	c3                   	ret    

008001bd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001bd:	55                   	push   %ebp
  8001be:	89 e5                	mov    %esp,%ebp
  8001c0:	57                   	push   %edi
  8001c1:	56                   	push   %esi
  8001c2:	53                   	push   %ebx
  8001c3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001c6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001cb:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ce:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001d1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001d7:	8b 55 08             	mov    0x8(%ebp),%edx
  8001da:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001dc:	85 c0                	test   %eax,%eax
  8001de:	7e 28                	jle    800208 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001e4:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8001eb:	00 
  8001ec:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  8001f3:	00 
  8001f4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001fb:	00 
  8001fc:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  800203:	e8 4c 02 00 00       	call   800454 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800208:	83 c4 2c             	add    $0x2c,%esp
  80020b:	5b                   	pop    %ebx
  80020c:	5e                   	pop    %esi
  80020d:	5f                   	pop    %edi
  80020e:	5d                   	pop    %ebp
  80020f:	c3                   	ret    

00800210 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800210:	55                   	push   %ebp
  800211:	89 e5                	mov    %esp,%ebp
  800213:	57                   	push   %edi
  800214:	56                   	push   %esi
  800215:	53                   	push   %ebx
  800216:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800219:	bb 00 00 00 00       	mov    $0x0,%ebx
  80021e:	b8 06 00 00 00       	mov    $0x6,%eax
  800223:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800226:	8b 55 08             	mov    0x8(%ebp),%edx
  800229:	89 df                	mov    %ebx,%edi
  80022b:	89 de                	mov    %ebx,%esi
  80022d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80022f:	85 c0                	test   %eax,%eax
  800231:	7e 28                	jle    80025b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800233:	89 44 24 10          	mov    %eax,0x10(%esp)
  800237:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80023e:	00 
  80023f:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  800246:	00 
  800247:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80024e:	00 
  80024f:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  800256:	e8 f9 01 00 00       	call   800454 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80025b:	83 c4 2c             	add    $0x2c,%esp
  80025e:	5b                   	pop    %ebx
  80025f:	5e                   	pop    %esi
  800260:	5f                   	pop    %edi
  800261:	5d                   	pop    %ebp
  800262:	c3                   	ret    

00800263 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
  800266:	57                   	push   %edi
  800267:	56                   	push   %esi
  800268:	53                   	push   %ebx
  800269:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80026c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800271:	b8 08 00 00 00       	mov    $0x8,%eax
  800276:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800279:	8b 55 08             	mov    0x8(%ebp),%edx
  80027c:	89 df                	mov    %ebx,%edi
  80027e:	89 de                	mov    %ebx,%esi
  800280:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800282:	85 c0                	test   %eax,%eax
  800284:	7e 28                	jle    8002ae <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800286:	89 44 24 10          	mov    %eax,0x10(%esp)
  80028a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800291:	00 
  800292:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  800299:	00 
  80029a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002a1:	00 
  8002a2:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  8002a9:	e8 a6 01 00 00       	call   800454 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002ae:	83 c4 2c             	add    $0x2c,%esp
  8002b1:	5b                   	pop    %ebx
  8002b2:	5e                   	pop    %esi
  8002b3:	5f                   	pop    %edi
  8002b4:	5d                   	pop    %ebp
  8002b5:	c3                   	ret    

008002b6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002b6:	55                   	push   %ebp
  8002b7:	89 e5                	mov    %esp,%ebp
  8002b9:	57                   	push   %edi
  8002ba:	56                   	push   %esi
  8002bb:	53                   	push   %ebx
  8002bc:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002bf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c4:	b8 09 00 00 00       	mov    $0x9,%eax
  8002c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8002cf:	89 df                	mov    %ebx,%edi
  8002d1:	89 de                	mov    %ebx,%esi
  8002d3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002d5:	85 c0                	test   %eax,%eax
  8002d7:	7e 28                	jle    800301 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002dd:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002e4:	00 
  8002e5:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  8002ec:	00 
  8002ed:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002f4:	00 
  8002f5:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  8002fc:	e8 53 01 00 00       	call   800454 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800301:	83 c4 2c             	add    $0x2c,%esp
  800304:	5b                   	pop    %ebx
  800305:	5e                   	pop    %esi
  800306:	5f                   	pop    %edi
  800307:	5d                   	pop    %ebp
  800308:	c3                   	ret    

00800309 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800309:	55                   	push   %ebp
  80030a:	89 e5                	mov    %esp,%ebp
  80030c:	57                   	push   %edi
  80030d:	56                   	push   %esi
  80030e:	53                   	push   %ebx
  80030f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800312:	bb 00 00 00 00       	mov    $0x0,%ebx
  800317:	b8 0a 00 00 00       	mov    $0xa,%eax
  80031c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80031f:	8b 55 08             	mov    0x8(%ebp),%edx
  800322:	89 df                	mov    %ebx,%edi
  800324:	89 de                	mov    %ebx,%esi
  800326:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800328:	85 c0                	test   %eax,%eax
  80032a:	7e 28                	jle    800354 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80032c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800330:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800337:	00 
  800338:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  80033f:	00 
  800340:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800347:	00 
  800348:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  80034f:	e8 00 01 00 00       	call   800454 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800354:	83 c4 2c             	add    $0x2c,%esp
  800357:	5b                   	pop    %ebx
  800358:	5e                   	pop    %esi
  800359:	5f                   	pop    %edi
  80035a:	5d                   	pop    %ebp
  80035b:	c3                   	ret    

0080035c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80035c:	55                   	push   %ebp
  80035d:	89 e5                	mov    %esp,%ebp
  80035f:	57                   	push   %edi
  800360:	56                   	push   %esi
  800361:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800362:	be 00 00 00 00       	mov    $0x0,%esi
  800367:	b8 0c 00 00 00       	mov    $0xc,%eax
  80036c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80036f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800372:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800375:	8b 55 08             	mov    0x8(%ebp),%edx
  800378:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80037a:	5b                   	pop    %ebx
  80037b:	5e                   	pop    %esi
  80037c:	5f                   	pop    %edi
  80037d:	5d                   	pop    %ebp
  80037e:	c3                   	ret    

0080037f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80037f:	55                   	push   %ebp
  800380:	89 e5                	mov    %esp,%ebp
  800382:	57                   	push   %edi
  800383:	56                   	push   %esi
  800384:	53                   	push   %ebx
  800385:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800388:	b9 00 00 00 00       	mov    $0x0,%ecx
  80038d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800392:	8b 55 08             	mov    0x8(%ebp),%edx
  800395:	89 cb                	mov    %ecx,%ebx
  800397:	89 cf                	mov    %ecx,%edi
  800399:	89 ce                	mov    %ecx,%esi
  80039b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80039d:	85 c0                	test   %eax,%eax
  80039f:	7e 28                	jle    8003c9 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003a1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003a5:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003ac:	00 
  8003ad:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  8003b4:	00 
  8003b5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003bc:	00 
  8003bd:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  8003c4:	e8 8b 00 00 00       	call   800454 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003c9:	83 c4 2c             	add    $0x2c,%esp
  8003cc:	5b                   	pop    %ebx
  8003cd:	5e                   	pop    %esi
  8003ce:	5f                   	pop    %edi
  8003cf:	5d                   	pop    %ebp
  8003d0:	c3                   	ret    

008003d1 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8003d1:	55                   	push   %ebp
  8003d2:	89 e5                	mov    %esp,%ebp
  8003d4:	57                   	push   %edi
  8003d5:	56                   	push   %esi
  8003d6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8003dc:	b8 0e 00 00 00       	mov    $0xe,%eax
  8003e1:	89 d1                	mov    %edx,%ecx
  8003e3:	89 d3                	mov    %edx,%ebx
  8003e5:	89 d7                	mov    %edx,%edi
  8003e7:	89 d6                	mov    %edx,%esi
  8003e9:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8003eb:	5b                   	pop    %ebx
  8003ec:	5e                   	pop    %esi
  8003ed:	5f                   	pop    %edi
  8003ee:	5d                   	pop    %ebp
  8003ef:	c3                   	ret    

008003f0 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char* pck, size_t length){
  8003f0:	55                   	push   %ebp
  8003f1:	89 e5                	mov    %esp,%ebp
  8003f3:	57                   	push   %edi
  8003f4:	56                   	push   %esi
  8003f5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003fb:	b8 10 00 00 00       	mov    $0x10,%eax
  800400:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800403:	8b 55 08             	mov    0x8(%ebp),%edx
  800406:	89 df                	mov    %ebx,%edi
  800408:	89 de                	mov    %ebx,%esi
  80040a:	cd 30                	int    $0x30
}

int 
sys_e1000_transmit(char* pck, size_t length){
	return syscall(SYS_e1000_transmit, 0, (uint32_t)pck, length, 0, 0, 0);
}
  80040c:	5b                   	pop    %ebx
  80040d:	5e                   	pop    %esi
  80040e:	5f                   	pop    %edi
  80040f:	5d                   	pop    %ebp
  800410:	c3                   	ret    

00800411 <sys_e1000_receive>:

int 
sys_e1000_receive(char* pck, size_t* length){
  800411:	55                   	push   %ebp
  800412:	89 e5                	mov    %esp,%ebp
  800414:	57                   	push   %edi
  800415:	56                   	push   %esi
  800416:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800417:	bb 00 00 00 00       	mov    $0x0,%ebx
  80041c:	b8 0f 00 00 00       	mov    $0xf,%eax
  800421:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800424:	8b 55 08             	mov    0x8(%ebp),%edx
  800427:	89 df                	mov    %ebx,%edi
  800429:	89 de                	mov    %ebx,%esi
  80042b:	cd 30                	int    $0x30
}

int 
sys_e1000_receive(char* pck, size_t* length){
	return syscall(SYS_e1000_receive, 0, (uint32_t)pck, (uint32_t)length, 0, 0, 0);
}
  80042d:	5b                   	pop    %ebx
  80042e:	5e                   	pop    %esi
  80042f:	5f                   	pop    %edi
  800430:	5d                   	pop    %ebp
  800431:	c3                   	ret    

00800432 <sys_e1000_get_mac>:

int 
sys_e1000_get_mac(uint8_t* mac_addr){
  800432:	55                   	push   %ebp
  800433:	89 e5                	mov    %esp,%ebp
  800435:	57                   	push   %edi
  800436:	56                   	push   %esi
  800437:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800438:	b9 00 00 00 00       	mov    $0x0,%ecx
  80043d:	b8 11 00 00 00       	mov    $0x11,%eax
  800442:	8b 55 08             	mov    0x8(%ebp),%edx
  800445:	89 cb                	mov    %ecx,%ebx
  800447:	89 cf                	mov    %ecx,%edi
  800449:	89 ce                	mov    %ecx,%esi
  80044b:	cd 30                	int    $0x30
}

int 
sys_e1000_get_mac(uint8_t* mac_addr){
	return syscall(SYS_e1000_get_mac, 0, (uint32_t)mac_addr, 0, 0, 0, 0);
}
  80044d:	5b                   	pop    %ebx
  80044e:	5e                   	pop    %esi
  80044f:	5f                   	pop    %edi
  800450:	5d                   	pop    %ebp
  800451:	c3                   	ret    
	...

00800454 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800454:	55                   	push   %ebp
  800455:	89 e5                	mov    %esp,%ebp
  800457:	56                   	push   %esi
  800458:	53                   	push   %ebx
  800459:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80045c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80045f:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800465:	e8 c1 fc ff ff       	call   80012b <sys_getenvid>
  80046a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80046d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800471:	8b 55 08             	mov    0x8(%ebp),%edx
  800474:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800478:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80047c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800480:	c7 04 24 b8 10 80 00 	movl   $0x8010b8,(%esp)
  800487:	e8 c0 00 00 00       	call   80054c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80048c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800490:	8b 45 10             	mov    0x10(%ebp),%eax
  800493:	89 04 24             	mov    %eax,(%esp)
  800496:	e8 50 00 00 00       	call   8004eb <vcprintf>
	cprintf("\n");
  80049b:	c7 04 24 db 10 80 00 	movl   $0x8010db,(%esp)
  8004a2:	e8 a5 00 00 00       	call   80054c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004a7:	cc                   	int3   
  8004a8:	eb fd                	jmp    8004a7 <_panic+0x53>
	...

008004ac <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004ac:	55                   	push   %ebp
  8004ad:	89 e5                	mov    %esp,%ebp
  8004af:	53                   	push   %ebx
  8004b0:	83 ec 14             	sub    $0x14,%esp
  8004b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8004b6:	8b 03                	mov    (%ebx),%eax
  8004b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8004bb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8004bf:	40                   	inc    %eax
  8004c0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8004c2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004c7:	75 19                	jne    8004e2 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8004c9:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8004d0:	00 
  8004d1:	8d 43 08             	lea    0x8(%ebx),%eax
  8004d4:	89 04 24             	mov    %eax,(%esp)
  8004d7:	e8 c0 fb ff ff       	call   80009c <sys_cputs>
		b->idx = 0;
  8004dc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8004e2:	ff 43 04             	incl   0x4(%ebx)
}
  8004e5:	83 c4 14             	add    $0x14,%esp
  8004e8:	5b                   	pop    %ebx
  8004e9:	5d                   	pop    %ebp
  8004ea:	c3                   	ret    

008004eb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004eb:	55                   	push   %ebp
  8004ec:	89 e5                	mov    %esp,%ebp
  8004ee:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8004f4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004fb:	00 00 00 
	b.cnt = 0;
  8004fe:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800505:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800508:	8b 45 0c             	mov    0xc(%ebp),%eax
  80050b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80050f:	8b 45 08             	mov    0x8(%ebp),%eax
  800512:	89 44 24 08          	mov    %eax,0x8(%esp)
  800516:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80051c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800520:	c7 04 24 ac 04 80 00 	movl   $0x8004ac,(%esp)
  800527:	e8 82 01 00 00       	call   8006ae <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80052c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800532:	89 44 24 04          	mov    %eax,0x4(%esp)
  800536:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80053c:	89 04 24             	mov    %eax,(%esp)
  80053f:	e8 58 fb ff ff       	call   80009c <sys_cputs>

	return b.cnt;
}
  800544:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80054a:	c9                   	leave  
  80054b:	c3                   	ret    

0080054c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80054c:	55                   	push   %ebp
  80054d:	89 e5                	mov    %esp,%ebp
  80054f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800552:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800555:	89 44 24 04          	mov    %eax,0x4(%esp)
  800559:	8b 45 08             	mov    0x8(%ebp),%eax
  80055c:	89 04 24             	mov    %eax,(%esp)
  80055f:	e8 87 ff ff ff       	call   8004eb <vcprintf>
	va_end(ap);

	return cnt;
}
  800564:	c9                   	leave  
  800565:	c3                   	ret    
	...

00800568 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800568:	55                   	push   %ebp
  800569:	89 e5                	mov    %esp,%ebp
  80056b:	57                   	push   %edi
  80056c:	56                   	push   %esi
  80056d:	53                   	push   %ebx
  80056e:	83 ec 3c             	sub    $0x3c,%esp
  800571:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800574:	89 d7                	mov    %edx,%edi
  800576:	8b 45 08             	mov    0x8(%ebp),%eax
  800579:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80057c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80057f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800582:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800585:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800588:	85 c0                	test   %eax,%eax
  80058a:	75 08                	jne    800594 <printnum+0x2c>
  80058c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80058f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800592:	77 57                	ja     8005eb <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800594:	89 74 24 10          	mov    %esi,0x10(%esp)
  800598:	4b                   	dec    %ebx
  800599:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80059d:	8b 45 10             	mov    0x10(%ebp),%eax
  8005a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005a4:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8005a8:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8005ac:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005b3:	00 
  8005b4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005b7:	89 04 24             	mov    %eax,(%esp)
  8005ba:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005c1:	e8 56 08 00 00       	call   800e1c <__udivdi3>
  8005c6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005ca:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8005ce:	89 04 24             	mov    %eax,(%esp)
  8005d1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005d5:	89 fa                	mov    %edi,%edx
  8005d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005da:	e8 89 ff ff ff       	call   800568 <printnum>
  8005df:	eb 0f                	jmp    8005f0 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8005e1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005e5:	89 34 24             	mov    %esi,(%esp)
  8005e8:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005eb:	4b                   	dec    %ebx
  8005ec:	85 db                	test   %ebx,%ebx
  8005ee:	7f f1                	jg     8005e1 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8005f0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005f4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8005f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8005fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005ff:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800606:	00 
  800607:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80060a:	89 04 24             	mov    %eax,(%esp)
  80060d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800610:	89 44 24 04          	mov    %eax,0x4(%esp)
  800614:	e8 23 09 00 00       	call   800f3c <__umoddi3>
  800619:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80061d:	0f be 80 dd 10 80 00 	movsbl 0x8010dd(%eax),%eax
  800624:	89 04 24             	mov    %eax,(%esp)
  800627:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80062a:	83 c4 3c             	add    $0x3c,%esp
  80062d:	5b                   	pop    %ebx
  80062e:	5e                   	pop    %esi
  80062f:	5f                   	pop    %edi
  800630:	5d                   	pop    %ebp
  800631:	c3                   	ret    

00800632 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800632:	55                   	push   %ebp
  800633:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800635:	83 fa 01             	cmp    $0x1,%edx
  800638:	7e 0e                	jle    800648 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80063a:	8b 10                	mov    (%eax),%edx
  80063c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80063f:	89 08                	mov    %ecx,(%eax)
  800641:	8b 02                	mov    (%edx),%eax
  800643:	8b 52 04             	mov    0x4(%edx),%edx
  800646:	eb 22                	jmp    80066a <getuint+0x38>
	else if (lflag)
  800648:	85 d2                	test   %edx,%edx
  80064a:	74 10                	je     80065c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80064c:	8b 10                	mov    (%eax),%edx
  80064e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800651:	89 08                	mov    %ecx,(%eax)
  800653:	8b 02                	mov    (%edx),%eax
  800655:	ba 00 00 00 00       	mov    $0x0,%edx
  80065a:	eb 0e                	jmp    80066a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80065c:	8b 10                	mov    (%eax),%edx
  80065e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800661:	89 08                	mov    %ecx,(%eax)
  800663:	8b 02                	mov    (%edx),%eax
  800665:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80066a:	5d                   	pop    %ebp
  80066b:	c3                   	ret    

0080066c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80066c:	55                   	push   %ebp
  80066d:	89 e5                	mov    %esp,%ebp
  80066f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800672:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800675:	8b 10                	mov    (%eax),%edx
  800677:	3b 50 04             	cmp    0x4(%eax),%edx
  80067a:	73 08                	jae    800684 <sprintputch+0x18>
		*b->buf++ = ch;
  80067c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80067f:	88 0a                	mov    %cl,(%edx)
  800681:	42                   	inc    %edx
  800682:	89 10                	mov    %edx,(%eax)
}
  800684:	5d                   	pop    %ebp
  800685:	c3                   	ret    

00800686 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800686:	55                   	push   %ebp
  800687:	89 e5                	mov    %esp,%ebp
  800689:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80068c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80068f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800693:	8b 45 10             	mov    0x10(%ebp),%eax
  800696:	89 44 24 08          	mov    %eax,0x8(%esp)
  80069a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80069d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a4:	89 04 24             	mov    %eax,(%esp)
  8006a7:	e8 02 00 00 00       	call   8006ae <vprintfmt>
	va_end(ap);
}
  8006ac:	c9                   	leave  
  8006ad:	c3                   	ret    

008006ae <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006ae:	55                   	push   %ebp
  8006af:	89 e5                	mov    %esp,%ebp
  8006b1:	57                   	push   %edi
  8006b2:	56                   	push   %esi
  8006b3:	53                   	push   %ebx
  8006b4:	83 ec 4c             	sub    $0x4c,%esp
  8006b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006ba:	8b 75 10             	mov    0x10(%ebp),%esi
  8006bd:	eb 12                	jmp    8006d1 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006bf:	85 c0                	test   %eax,%eax
  8006c1:	0f 84 6b 03 00 00    	je     800a32 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8006c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006cb:	89 04 24             	mov    %eax,(%esp)
  8006ce:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006d1:	0f b6 06             	movzbl (%esi),%eax
  8006d4:	46                   	inc    %esi
  8006d5:	83 f8 25             	cmp    $0x25,%eax
  8006d8:	75 e5                	jne    8006bf <vprintfmt+0x11>
  8006da:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8006de:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8006e5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8006ea:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8006f1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f6:	eb 26                	jmp    80071e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f8:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8006fb:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8006ff:	eb 1d                	jmp    80071e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800701:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800704:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800708:	eb 14                	jmp    80071e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80070d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800714:	eb 08                	jmp    80071e <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800716:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800719:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80071e:	0f b6 06             	movzbl (%esi),%eax
  800721:	8d 56 01             	lea    0x1(%esi),%edx
  800724:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800727:	8a 16                	mov    (%esi),%dl
  800729:	83 ea 23             	sub    $0x23,%edx
  80072c:	80 fa 55             	cmp    $0x55,%dl
  80072f:	0f 87 e1 02 00 00    	ja     800a16 <vprintfmt+0x368>
  800735:	0f b6 d2             	movzbl %dl,%edx
  800738:	ff 24 95 20 12 80 00 	jmp    *0x801220(,%edx,4)
  80073f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800742:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800747:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80074a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80074e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800751:	8d 50 d0             	lea    -0x30(%eax),%edx
  800754:	83 fa 09             	cmp    $0x9,%edx
  800757:	77 2a                	ja     800783 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800759:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80075a:	eb eb                	jmp    800747 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80075c:	8b 45 14             	mov    0x14(%ebp),%eax
  80075f:	8d 50 04             	lea    0x4(%eax),%edx
  800762:	89 55 14             	mov    %edx,0x14(%ebp)
  800765:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800767:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80076a:	eb 17                	jmp    800783 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  80076c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800770:	78 98                	js     80070a <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800772:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800775:	eb a7                	jmp    80071e <vprintfmt+0x70>
  800777:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80077a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800781:	eb 9b                	jmp    80071e <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800783:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800787:	79 95                	jns    80071e <vprintfmt+0x70>
  800789:	eb 8b                	jmp    800716 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80078b:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80078c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80078f:	eb 8d                	jmp    80071e <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800791:	8b 45 14             	mov    0x14(%ebp),%eax
  800794:	8d 50 04             	lea    0x4(%eax),%edx
  800797:	89 55 14             	mov    %edx,0x14(%ebp)
  80079a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80079e:	8b 00                	mov    (%eax),%eax
  8007a0:	89 04 24             	mov    %eax,(%esp)
  8007a3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8007a9:	e9 23 ff ff ff       	jmp    8006d1 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8007ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b1:	8d 50 04             	lea    0x4(%eax),%edx
  8007b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8007b7:	8b 00                	mov    (%eax),%eax
  8007b9:	85 c0                	test   %eax,%eax
  8007bb:	79 02                	jns    8007bf <vprintfmt+0x111>
  8007bd:	f7 d8                	neg    %eax
  8007bf:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8007c1:	83 f8 11             	cmp    $0x11,%eax
  8007c4:	7f 0b                	jg     8007d1 <vprintfmt+0x123>
  8007c6:	8b 04 85 80 13 80 00 	mov    0x801380(,%eax,4),%eax
  8007cd:	85 c0                	test   %eax,%eax
  8007cf:	75 23                	jne    8007f4 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8007d1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007d5:	c7 44 24 08 f5 10 80 	movl   $0x8010f5,0x8(%esp)
  8007dc:	00 
  8007dd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e4:	89 04 24             	mov    %eax,(%esp)
  8007e7:	e8 9a fe ff ff       	call   800686 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ec:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8007ef:	e9 dd fe ff ff       	jmp    8006d1 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8007f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007f8:	c7 44 24 08 fe 10 80 	movl   $0x8010fe,0x8(%esp)
  8007ff:	00 
  800800:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800804:	8b 55 08             	mov    0x8(%ebp),%edx
  800807:	89 14 24             	mov    %edx,(%esp)
  80080a:	e8 77 fe ff ff       	call   800686 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80080f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800812:	e9 ba fe ff ff       	jmp    8006d1 <vprintfmt+0x23>
  800817:	89 f9                	mov    %edi,%ecx
  800819:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80081c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80081f:	8b 45 14             	mov    0x14(%ebp),%eax
  800822:	8d 50 04             	lea    0x4(%eax),%edx
  800825:	89 55 14             	mov    %edx,0x14(%ebp)
  800828:	8b 30                	mov    (%eax),%esi
  80082a:	85 f6                	test   %esi,%esi
  80082c:	75 05                	jne    800833 <vprintfmt+0x185>
				p = "(null)";
  80082e:	be ee 10 80 00       	mov    $0x8010ee,%esi
			if (width > 0 && padc != '-')
  800833:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800837:	0f 8e 84 00 00 00    	jle    8008c1 <vprintfmt+0x213>
  80083d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800841:	74 7e                	je     8008c1 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800843:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800847:	89 34 24             	mov    %esi,(%esp)
  80084a:	e8 8b 02 00 00       	call   800ada <strnlen>
  80084f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800852:	29 c2                	sub    %eax,%edx
  800854:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800857:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80085b:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80085e:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800861:	89 de                	mov    %ebx,%esi
  800863:	89 d3                	mov    %edx,%ebx
  800865:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800867:	eb 0b                	jmp    800874 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800869:	89 74 24 04          	mov    %esi,0x4(%esp)
  80086d:	89 3c 24             	mov    %edi,(%esp)
  800870:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800873:	4b                   	dec    %ebx
  800874:	85 db                	test   %ebx,%ebx
  800876:	7f f1                	jg     800869 <vprintfmt+0x1bb>
  800878:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80087b:	89 f3                	mov    %esi,%ebx
  80087d:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800880:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800883:	85 c0                	test   %eax,%eax
  800885:	79 05                	jns    80088c <vprintfmt+0x1de>
  800887:	b8 00 00 00 00       	mov    $0x0,%eax
  80088c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80088f:	29 c2                	sub    %eax,%edx
  800891:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800894:	eb 2b                	jmp    8008c1 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800896:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80089a:	74 18                	je     8008b4 <vprintfmt+0x206>
  80089c:	8d 50 e0             	lea    -0x20(%eax),%edx
  80089f:	83 fa 5e             	cmp    $0x5e,%edx
  8008a2:	76 10                	jbe    8008b4 <vprintfmt+0x206>
					putch('?', putdat);
  8008a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008a8:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8008af:	ff 55 08             	call   *0x8(%ebp)
  8008b2:	eb 0a                	jmp    8008be <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8008b4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008b8:	89 04 24             	mov    %eax,(%esp)
  8008bb:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008be:	ff 4d e4             	decl   -0x1c(%ebp)
  8008c1:	0f be 06             	movsbl (%esi),%eax
  8008c4:	46                   	inc    %esi
  8008c5:	85 c0                	test   %eax,%eax
  8008c7:	74 21                	je     8008ea <vprintfmt+0x23c>
  8008c9:	85 ff                	test   %edi,%edi
  8008cb:	78 c9                	js     800896 <vprintfmt+0x1e8>
  8008cd:	4f                   	dec    %edi
  8008ce:	79 c6                	jns    800896 <vprintfmt+0x1e8>
  8008d0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008d3:	89 de                	mov    %ebx,%esi
  8008d5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8008d8:	eb 18                	jmp    8008f2 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8008da:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008de:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8008e5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8008e7:	4b                   	dec    %ebx
  8008e8:	eb 08                	jmp    8008f2 <vprintfmt+0x244>
  8008ea:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ed:	89 de                	mov    %ebx,%esi
  8008ef:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8008f2:	85 db                	test   %ebx,%ebx
  8008f4:	7f e4                	jg     8008da <vprintfmt+0x22c>
  8008f6:	89 7d 08             	mov    %edi,0x8(%ebp)
  8008f9:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008fb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008fe:	e9 ce fd ff ff       	jmp    8006d1 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800903:	83 f9 01             	cmp    $0x1,%ecx
  800906:	7e 10                	jle    800918 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800908:	8b 45 14             	mov    0x14(%ebp),%eax
  80090b:	8d 50 08             	lea    0x8(%eax),%edx
  80090e:	89 55 14             	mov    %edx,0x14(%ebp)
  800911:	8b 30                	mov    (%eax),%esi
  800913:	8b 78 04             	mov    0x4(%eax),%edi
  800916:	eb 26                	jmp    80093e <vprintfmt+0x290>
	else if (lflag)
  800918:	85 c9                	test   %ecx,%ecx
  80091a:	74 12                	je     80092e <vprintfmt+0x280>
		return va_arg(*ap, long);
  80091c:	8b 45 14             	mov    0x14(%ebp),%eax
  80091f:	8d 50 04             	lea    0x4(%eax),%edx
  800922:	89 55 14             	mov    %edx,0x14(%ebp)
  800925:	8b 30                	mov    (%eax),%esi
  800927:	89 f7                	mov    %esi,%edi
  800929:	c1 ff 1f             	sar    $0x1f,%edi
  80092c:	eb 10                	jmp    80093e <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80092e:	8b 45 14             	mov    0x14(%ebp),%eax
  800931:	8d 50 04             	lea    0x4(%eax),%edx
  800934:	89 55 14             	mov    %edx,0x14(%ebp)
  800937:	8b 30                	mov    (%eax),%esi
  800939:	89 f7                	mov    %esi,%edi
  80093b:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80093e:	85 ff                	test   %edi,%edi
  800940:	78 0a                	js     80094c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800942:	b8 0a 00 00 00       	mov    $0xa,%eax
  800947:	e9 8c 00 00 00       	jmp    8009d8 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80094c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800950:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800957:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80095a:	f7 de                	neg    %esi
  80095c:	83 d7 00             	adc    $0x0,%edi
  80095f:	f7 df                	neg    %edi
			}
			base = 10;
  800961:	b8 0a 00 00 00       	mov    $0xa,%eax
  800966:	eb 70                	jmp    8009d8 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800968:	89 ca                	mov    %ecx,%edx
  80096a:	8d 45 14             	lea    0x14(%ebp),%eax
  80096d:	e8 c0 fc ff ff       	call   800632 <getuint>
  800972:	89 c6                	mov    %eax,%esi
  800974:	89 d7                	mov    %edx,%edi
			base = 10;
  800976:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80097b:	eb 5b                	jmp    8009d8 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  80097d:	89 ca                	mov    %ecx,%edx
  80097f:	8d 45 14             	lea    0x14(%ebp),%eax
  800982:	e8 ab fc ff ff       	call   800632 <getuint>
  800987:	89 c6                	mov    %eax,%esi
  800989:	89 d7                	mov    %edx,%edi
			base = 8;
  80098b:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800990:	eb 46                	jmp    8009d8 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  800992:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800996:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80099d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8009a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009a4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8009ab:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8009ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b1:	8d 50 04             	lea    0x4(%eax),%edx
  8009b4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8009b7:	8b 30                	mov    (%eax),%esi
  8009b9:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8009be:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8009c3:	eb 13                	jmp    8009d8 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8009c5:	89 ca                	mov    %ecx,%edx
  8009c7:	8d 45 14             	lea    0x14(%ebp),%eax
  8009ca:	e8 63 fc ff ff       	call   800632 <getuint>
  8009cf:	89 c6                	mov    %eax,%esi
  8009d1:	89 d7                	mov    %edx,%edi
			base = 16;
  8009d3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8009d8:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8009dc:	89 54 24 10          	mov    %edx,0x10(%esp)
  8009e0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8009e3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8009e7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009eb:	89 34 24             	mov    %esi,(%esp)
  8009ee:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009f2:	89 da                	mov    %ebx,%edx
  8009f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f7:	e8 6c fb ff ff       	call   800568 <printnum>
			break;
  8009fc:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8009ff:	e9 cd fc ff ff       	jmp    8006d1 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a04:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a08:	89 04 24             	mov    %eax,(%esp)
  800a0b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a0e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a11:	e9 bb fc ff ff       	jmp    8006d1 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a16:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a1a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a21:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a24:	eb 01                	jmp    800a27 <vprintfmt+0x379>
  800a26:	4e                   	dec    %esi
  800a27:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800a2b:	75 f9                	jne    800a26 <vprintfmt+0x378>
  800a2d:	e9 9f fc ff ff       	jmp    8006d1 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800a32:	83 c4 4c             	add    $0x4c,%esp
  800a35:	5b                   	pop    %ebx
  800a36:	5e                   	pop    %esi
  800a37:	5f                   	pop    %edi
  800a38:	5d                   	pop    %ebp
  800a39:	c3                   	ret    

00800a3a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a3a:	55                   	push   %ebp
  800a3b:	89 e5                	mov    %esp,%ebp
  800a3d:	83 ec 28             	sub    $0x28,%esp
  800a40:	8b 45 08             	mov    0x8(%ebp),%eax
  800a43:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a46:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a49:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a4d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a50:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a57:	85 c0                	test   %eax,%eax
  800a59:	74 30                	je     800a8b <vsnprintf+0x51>
  800a5b:	85 d2                	test   %edx,%edx
  800a5d:	7e 33                	jle    800a92 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a5f:	8b 45 14             	mov    0x14(%ebp),%eax
  800a62:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a66:	8b 45 10             	mov    0x10(%ebp),%eax
  800a69:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a6d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a70:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a74:	c7 04 24 6c 06 80 00 	movl   $0x80066c,(%esp)
  800a7b:	e8 2e fc ff ff       	call   8006ae <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a80:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a83:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a86:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a89:	eb 0c                	jmp    800a97 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a8b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a90:	eb 05                	jmp    800a97 <vsnprintf+0x5d>
  800a92:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a97:	c9                   	leave  
  800a98:	c3                   	ret    

00800a99 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a99:	55                   	push   %ebp
  800a9a:	89 e5                	mov    %esp,%ebp
  800a9c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a9f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800aa2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800aa6:	8b 45 10             	mov    0x10(%ebp),%eax
  800aa9:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aad:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ab4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab7:	89 04 24             	mov    %eax,(%esp)
  800aba:	e8 7b ff ff ff       	call   800a3a <vsnprintf>
	va_end(ap);

	return rc;
}
  800abf:	c9                   	leave  
  800ac0:	c3                   	ret    
  800ac1:	00 00                	add    %al,(%eax)
	...

00800ac4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ac4:	55                   	push   %ebp
  800ac5:	89 e5                	mov    %esp,%ebp
  800ac7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800aca:	b8 00 00 00 00       	mov    $0x0,%eax
  800acf:	eb 01                	jmp    800ad2 <strlen+0xe>
		n++;
  800ad1:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800ad2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ad6:	75 f9                	jne    800ad1 <strlen+0xd>
		n++;
	return n;
}
  800ad8:	5d                   	pop    %ebp
  800ad9:	c3                   	ret    

00800ada <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ada:	55                   	push   %ebp
  800adb:	89 e5                	mov    %esp,%ebp
  800add:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800ae0:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ae3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae8:	eb 01                	jmp    800aeb <strnlen+0x11>
		n++;
  800aea:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800aeb:	39 d0                	cmp    %edx,%eax
  800aed:	74 06                	je     800af5 <strnlen+0x1b>
  800aef:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800af3:	75 f5                	jne    800aea <strnlen+0x10>
		n++;
	return n;
}
  800af5:	5d                   	pop    %ebp
  800af6:	c3                   	ret    

00800af7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	53                   	push   %ebx
  800afb:	8b 45 08             	mov    0x8(%ebp),%eax
  800afe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b01:	ba 00 00 00 00       	mov    $0x0,%edx
  800b06:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800b09:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800b0c:	42                   	inc    %edx
  800b0d:	84 c9                	test   %cl,%cl
  800b0f:	75 f5                	jne    800b06 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800b11:	5b                   	pop    %ebx
  800b12:	5d                   	pop    %ebp
  800b13:	c3                   	ret    

00800b14 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	53                   	push   %ebx
  800b18:	83 ec 08             	sub    $0x8,%esp
  800b1b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b1e:	89 1c 24             	mov    %ebx,(%esp)
  800b21:	e8 9e ff ff ff       	call   800ac4 <strlen>
	strcpy(dst + len, src);
  800b26:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b29:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b2d:	01 d8                	add    %ebx,%eax
  800b2f:	89 04 24             	mov    %eax,(%esp)
  800b32:	e8 c0 ff ff ff       	call   800af7 <strcpy>
	return dst;
}
  800b37:	89 d8                	mov    %ebx,%eax
  800b39:	83 c4 08             	add    $0x8,%esp
  800b3c:	5b                   	pop    %ebx
  800b3d:	5d                   	pop    %ebp
  800b3e:	c3                   	ret    

00800b3f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b3f:	55                   	push   %ebp
  800b40:	89 e5                	mov    %esp,%ebp
  800b42:	56                   	push   %esi
  800b43:	53                   	push   %ebx
  800b44:	8b 45 08             	mov    0x8(%ebp),%eax
  800b47:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b4a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b4d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b52:	eb 0c                	jmp    800b60 <strncpy+0x21>
		*dst++ = *src;
  800b54:	8a 1a                	mov    (%edx),%bl
  800b56:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b59:	80 3a 01             	cmpb   $0x1,(%edx)
  800b5c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b5f:	41                   	inc    %ecx
  800b60:	39 f1                	cmp    %esi,%ecx
  800b62:	75 f0                	jne    800b54 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b64:	5b                   	pop    %ebx
  800b65:	5e                   	pop    %esi
  800b66:	5d                   	pop    %ebp
  800b67:	c3                   	ret    

00800b68 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b68:	55                   	push   %ebp
  800b69:	89 e5                	mov    %esp,%ebp
  800b6b:	56                   	push   %esi
  800b6c:	53                   	push   %ebx
  800b6d:	8b 75 08             	mov    0x8(%ebp),%esi
  800b70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b73:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b76:	85 d2                	test   %edx,%edx
  800b78:	75 0a                	jne    800b84 <strlcpy+0x1c>
  800b7a:	89 f0                	mov    %esi,%eax
  800b7c:	eb 1a                	jmp    800b98 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b7e:	88 18                	mov    %bl,(%eax)
  800b80:	40                   	inc    %eax
  800b81:	41                   	inc    %ecx
  800b82:	eb 02                	jmp    800b86 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b84:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800b86:	4a                   	dec    %edx
  800b87:	74 0a                	je     800b93 <strlcpy+0x2b>
  800b89:	8a 19                	mov    (%ecx),%bl
  800b8b:	84 db                	test   %bl,%bl
  800b8d:	75 ef                	jne    800b7e <strlcpy+0x16>
  800b8f:	89 c2                	mov    %eax,%edx
  800b91:	eb 02                	jmp    800b95 <strlcpy+0x2d>
  800b93:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800b95:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800b98:	29 f0                	sub    %esi,%eax
}
  800b9a:	5b                   	pop    %ebx
  800b9b:	5e                   	pop    %esi
  800b9c:	5d                   	pop    %ebp
  800b9d:	c3                   	ret    

00800b9e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b9e:	55                   	push   %ebp
  800b9f:	89 e5                	mov    %esp,%ebp
  800ba1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ba4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ba7:	eb 02                	jmp    800bab <strcmp+0xd>
		p++, q++;
  800ba9:	41                   	inc    %ecx
  800baa:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800bab:	8a 01                	mov    (%ecx),%al
  800bad:	84 c0                	test   %al,%al
  800baf:	74 04                	je     800bb5 <strcmp+0x17>
  800bb1:	3a 02                	cmp    (%edx),%al
  800bb3:	74 f4                	je     800ba9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800bb5:	0f b6 c0             	movzbl %al,%eax
  800bb8:	0f b6 12             	movzbl (%edx),%edx
  800bbb:	29 d0                	sub    %edx,%eax
}
  800bbd:	5d                   	pop    %ebp
  800bbe:	c3                   	ret    

00800bbf <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800bbf:	55                   	push   %ebp
  800bc0:	89 e5                	mov    %esp,%ebp
  800bc2:	53                   	push   %ebx
  800bc3:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc9:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800bcc:	eb 03                	jmp    800bd1 <strncmp+0x12>
		n--, p++, q++;
  800bce:	4a                   	dec    %edx
  800bcf:	40                   	inc    %eax
  800bd0:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800bd1:	85 d2                	test   %edx,%edx
  800bd3:	74 14                	je     800be9 <strncmp+0x2a>
  800bd5:	8a 18                	mov    (%eax),%bl
  800bd7:	84 db                	test   %bl,%bl
  800bd9:	74 04                	je     800bdf <strncmp+0x20>
  800bdb:	3a 19                	cmp    (%ecx),%bl
  800bdd:	74 ef                	je     800bce <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800bdf:	0f b6 00             	movzbl (%eax),%eax
  800be2:	0f b6 11             	movzbl (%ecx),%edx
  800be5:	29 d0                	sub    %edx,%eax
  800be7:	eb 05                	jmp    800bee <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800be9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800bee:	5b                   	pop    %ebx
  800bef:	5d                   	pop    %ebp
  800bf0:	c3                   	ret    

00800bf1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf7:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800bfa:	eb 05                	jmp    800c01 <strchr+0x10>
		if (*s == c)
  800bfc:	38 ca                	cmp    %cl,%dl
  800bfe:	74 0c                	je     800c0c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c00:	40                   	inc    %eax
  800c01:	8a 10                	mov    (%eax),%dl
  800c03:	84 d2                	test   %dl,%dl
  800c05:	75 f5                	jne    800bfc <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800c07:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c0c:	5d                   	pop    %ebp
  800c0d:	c3                   	ret    

00800c0e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c0e:	55                   	push   %ebp
  800c0f:	89 e5                	mov    %esp,%ebp
  800c11:	8b 45 08             	mov    0x8(%ebp),%eax
  800c14:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800c17:	eb 05                	jmp    800c1e <strfind+0x10>
		if (*s == c)
  800c19:	38 ca                	cmp    %cl,%dl
  800c1b:	74 07                	je     800c24 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c1d:	40                   	inc    %eax
  800c1e:	8a 10                	mov    (%eax),%dl
  800c20:	84 d2                	test   %dl,%dl
  800c22:	75 f5                	jne    800c19 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800c24:	5d                   	pop    %ebp
  800c25:	c3                   	ret    

00800c26 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	57                   	push   %edi
  800c2a:	56                   	push   %esi
  800c2b:	53                   	push   %ebx
  800c2c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c32:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c35:	85 c9                	test   %ecx,%ecx
  800c37:	74 30                	je     800c69 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c39:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c3f:	75 25                	jne    800c66 <memset+0x40>
  800c41:	f6 c1 03             	test   $0x3,%cl
  800c44:	75 20                	jne    800c66 <memset+0x40>
		c &= 0xFF;
  800c46:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c49:	89 d3                	mov    %edx,%ebx
  800c4b:	c1 e3 08             	shl    $0x8,%ebx
  800c4e:	89 d6                	mov    %edx,%esi
  800c50:	c1 e6 18             	shl    $0x18,%esi
  800c53:	89 d0                	mov    %edx,%eax
  800c55:	c1 e0 10             	shl    $0x10,%eax
  800c58:	09 f0                	or     %esi,%eax
  800c5a:	09 d0                	or     %edx,%eax
  800c5c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c5e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800c61:	fc                   	cld    
  800c62:	f3 ab                	rep stos %eax,%es:(%edi)
  800c64:	eb 03                	jmp    800c69 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c66:	fc                   	cld    
  800c67:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c69:	89 f8                	mov    %edi,%eax
  800c6b:	5b                   	pop    %ebx
  800c6c:	5e                   	pop    %esi
  800c6d:	5f                   	pop    %edi
  800c6e:	5d                   	pop    %ebp
  800c6f:	c3                   	ret    

00800c70 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c70:	55                   	push   %ebp
  800c71:	89 e5                	mov    %esp,%ebp
  800c73:	57                   	push   %edi
  800c74:	56                   	push   %esi
  800c75:	8b 45 08             	mov    0x8(%ebp),%eax
  800c78:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c7b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c7e:	39 c6                	cmp    %eax,%esi
  800c80:	73 34                	jae    800cb6 <memmove+0x46>
  800c82:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c85:	39 d0                	cmp    %edx,%eax
  800c87:	73 2d                	jae    800cb6 <memmove+0x46>
		s += n;
		d += n;
  800c89:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c8c:	f6 c2 03             	test   $0x3,%dl
  800c8f:	75 1b                	jne    800cac <memmove+0x3c>
  800c91:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c97:	75 13                	jne    800cac <memmove+0x3c>
  800c99:	f6 c1 03             	test   $0x3,%cl
  800c9c:	75 0e                	jne    800cac <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c9e:	83 ef 04             	sub    $0x4,%edi
  800ca1:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ca4:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800ca7:	fd                   	std    
  800ca8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800caa:	eb 07                	jmp    800cb3 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800cac:	4f                   	dec    %edi
  800cad:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800cb0:	fd                   	std    
  800cb1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800cb3:	fc                   	cld    
  800cb4:	eb 20                	jmp    800cd6 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cb6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cbc:	75 13                	jne    800cd1 <memmove+0x61>
  800cbe:	a8 03                	test   $0x3,%al
  800cc0:	75 0f                	jne    800cd1 <memmove+0x61>
  800cc2:	f6 c1 03             	test   $0x3,%cl
  800cc5:	75 0a                	jne    800cd1 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800cc7:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800cca:	89 c7                	mov    %eax,%edi
  800ccc:	fc                   	cld    
  800ccd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ccf:	eb 05                	jmp    800cd6 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800cd1:	89 c7                	mov    %eax,%edi
  800cd3:	fc                   	cld    
  800cd4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800cd6:	5e                   	pop    %esi
  800cd7:	5f                   	pop    %edi
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    

00800cda <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ce0:	8b 45 10             	mov    0x10(%ebp),%eax
  800ce3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ce7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cea:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cee:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf1:	89 04 24             	mov    %eax,(%esp)
  800cf4:	e8 77 ff ff ff       	call   800c70 <memmove>
}
  800cf9:	c9                   	leave  
  800cfa:	c3                   	ret    

00800cfb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cfb:	55                   	push   %ebp
  800cfc:	89 e5                	mov    %esp,%ebp
  800cfe:	57                   	push   %edi
  800cff:	56                   	push   %esi
  800d00:	53                   	push   %ebx
  800d01:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d04:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d07:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d0a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d0f:	eb 16                	jmp    800d27 <memcmp+0x2c>
		if (*s1 != *s2)
  800d11:	8a 04 17             	mov    (%edi,%edx,1),%al
  800d14:	42                   	inc    %edx
  800d15:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800d19:	38 c8                	cmp    %cl,%al
  800d1b:	74 0a                	je     800d27 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800d1d:	0f b6 c0             	movzbl %al,%eax
  800d20:	0f b6 c9             	movzbl %cl,%ecx
  800d23:	29 c8                	sub    %ecx,%eax
  800d25:	eb 09                	jmp    800d30 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d27:	39 da                	cmp    %ebx,%edx
  800d29:	75 e6                	jne    800d11 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d2b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d30:	5b                   	pop    %ebx
  800d31:	5e                   	pop    %esi
  800d32:	5f                   	pop    %edi
  800d33:	5d                   	pop    %ebp
  800d34:	c3                   	ret    

00800d35 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d35:	55                   	push   %ebp
  800d36:	89 e5                	mov    %esp,%ebp
  800d38:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800d3e:	89 c2                	mov    %eax,%edx
  800d40:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d43:	eb 05                	jmp    800d4a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d45:	38 08                	cmp    %cl,(%eax)
  800d47:	74 05                	je     800d4e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d49:	40                   	inc    %eax
  800d4a:	39 d0                	cmp    %edx,%eax
  800d4c:	72 f7                	jb     800d45 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d4e:	5d                   	pop    %ebp
  800d4f:	c3                   	ret    

00800d50 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
  800d53:	57                   	push   %edi
  800d54:	56                   	push   %esi
  800d55:	53                   	push   %ebx
  800d56:	8b 55 08             	mov    0x8(%ebp),%edx
  800d59:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d5c:	eb 01                	jmp    800d5f <strtol+0xf>
		s++;
  800d5e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d5f:	8a 02                	mov    (%edx),%al
  800d61:	3c 20                	cmp    $0x20,%al
  800d63:	74 f9                	je     800d5e <strtol+0xe>
  800d65:	3c 09                	cmp    $0x9,%al
  800d67:	74 f5                	je     800d5e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d69:	3c 2b                	cmp    $0x2b,%al
  800d6b:	75 08                	jne    800d75 <strtol+0x25>
		s++;
  800d6d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d6e:	bf 00 00 00 00       	mov    $0x0,%edi
  800d73:	eb 13                	jmp    800d88 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d75:	3c 2d                	cmp    $0x2d,%al
  800d77:	75 0a                	jne    800d83 <strtol+0x33>
		s++, neg = 1;
  800d79:	8d 52 01             	lea    0x1(%edx),%edx
  800d7c:	bf 01 00 00 00       	mov    $0x1,%edi
  800d81:	eb 05                	jmp    800d88 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d83:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d88:	85 db                	test   %ebx,%ebx
  800d8a:	74 05                	je     800d91 <strtol+0x41>
  800d8c:	83 fb 10             	cmp    $0x10,%ebx
  800d8f:	75 28                	jne    800db9 <strtol+0x69>
  800d91:	8a 02                	mov    (%edx),%al
  800d93:	3c 30                	cmp    $0x30,%al
  800d95:	75 10                	jne    800da7 <strtol+0x57>
  800d97:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d9b:	75 0a                	jne    800da7 <strtol+0x57>
		s += 2, base = 16;
  800d9d:	83 c2 02             	add    $0x2,%edx
  800da0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800da5:	eb 12                	jmp    800db9 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800da7:	85 db                	test   %ebx,%ebx
  800da9:	75 0e                	jne    800db9 <strtol+0x69>
  800dab:	3c 30                	cmp    $0x30,%al
  800dad:	75 05                	jne    800db4 <strtol+0x64>
		s++, base = 8;
  800daf:	42                   	inc    %edx
  800db0:	b3 08                	mov    $0x8,%bl
  800db2:	eb 05                	jmp    800db9 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800db4:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800db9:	b8 00 00 00 00       	mov    $0x0,%eax
  800dbe:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800dc0:	8a 0a                	mov    (%edx),%cl
  800dc2:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800dc5:	80 fb 09             	cmp    $0x9,%bl
  800dc8:	77 08                	ja     800dd2 <strtol+0x82>
			dig = *s - '0';
  800dca:	0f be c9             	movsbl %cl,%ecx
  800dcd:	83 e9 30             	sub    $0x30,%ecx
  800dd0:	eb 1e                	jmp    800df0 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800dd2:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800dd5:	80 fb 19             	cmp    $0x19,%bl
  800dd8:	77 08                	ja     800de2 <strtol+0x92>
			dig = *s - 'a' + 10;
  800dda:	0f be c9             	movsbl %cl,%ecx
  800ddd:	83 e9 57             	sub    $0x57,%ecx
  800de0:	eb 0e                	jmp    800df0 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800de2:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800de5:	80 fb 19             	cmp    $0x19,%bl
  800de8:	77 12                	ja     800dfc <strtol+0xac>
			dig = *s - 'A' + 10;
  800dea:	0f be c9             	movsbl %cl,%ecx
  800ded:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800df0:	39 f1                	cmp    %esi,%ecx
  800df2:	7d 0c                	jge    800e00 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800df4:	42                   	inc    %edx
  800df5:	0f af c6             	imul   %esi,%eax
  800df8:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800dfa:	eb c4                	jmp    800dc0 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800dfc:	89 c1                	mov    %eax,%ecx
  800dfe:	eb 02                	jmp    800e02 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800e00:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800e02:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e06:	74 05                	je     800e0d <strtol+0xbd>
		*endptr = (char *) s;
  800e08:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e0b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800e0d:	85 ff                	test   %edi,%edi
  800e0f:	74 04                	je     800e15 <strtol+0xc5>
  800e11:	89 c8                	mov    %ecx,%eax
  800e13:	f7 d8                	neg    %eax
}
  800e15:	5b                   	pop    %ebx
  800e16:	5e                   	pop    %esi
  800e17:	5f                   	pop    %edi
  800e18:	5d                   	pop    %ebp
  800e19:	c3                   	ret    
	...

00800e1c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800e1c:	55                   	push   %ebp
  800e1d:	57                   	push   %edi
  800e1e:	56                   	push   %esi
  800e1f:	83 ec 10             	sub    $0x10,%esp
  800e22:	8b 74 24 20          	mov    0x20(%esp),%esi
  800e26:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800e2a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e2e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  800e32:	89 cd                	mov    %ecx,%ebp
  800e34:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e38:	85 c0                	test   %eax,%eax
  800e3a:	75 2c                	jne    800e68 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800e3c:	39 f9                	cmp    %edi,%ecx
  800e3e:	77 68                	ja     800ea8 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800e40:	85 c9                	test   %ecx,%ecx
  800e42:	75 0b                	jne    800e4f <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800e44:	b8 01 00 00 00       	mov    $0x1,%eax
  800e49:	31 d2                	xor    %edx,%edx
  800e4b:	f7 f1                	div    %ecx
  800e4d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800e4f:	31 d2                	xor    %edx,%edx
  800e51:	89 f8                	mov    %edi,%eax
  800e53:	f7 f1                	div    %ecx
  800e55:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e57:	89 f0                	mov    %esi,%eax
  800e59:	f7 f1                	div    %ecx
  800e5b:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e5d:	89 f0                	mov    %esi,%eax
  800e5f:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e61:	83 c4 10             	add    $0x10,%esp
  800e64:	5e                   	pop    %esi
  800e65:	5f                   	pop    %edi
  800e66:	5d                   	pop    %ebp
  800e67:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e68:	39 f8                	cmp    %edi,%eax
  800e6a:	77 2c                	ja     800e98 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e6c:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  800e6f:	83 f6 1f             	xor    $0x1f,%esi
  800e72:	75 4c                	jne    800ec0 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e74:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e76:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e7b:	72 0a                	jb     800e87 <__udivdi3+0x6b>
  800e7d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800e81:	0f 87 ad 00 00 00    	ja     800f34 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e87:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e8c:	89 f0                	mov    %esi,%eax
  800e8e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e90:	83 c4 10             	add    $0x10,%esp
  800e93:	5e                   	pop    %esi
  800e94:	5f                   	pop    %edi
  800e95:	5d                   	pop    %ebp
  800e96:	c3                   	ret    
  800e97:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e98:	31 ff                	xor    %edi,%edi
  800e9a:	31 f6                	xor    %esi,%esi
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
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ea8:	89 fa                	mov    %edi,%edx
  800eaa:	89 f0                	mov    %esi,%eax
  800eac:	f7 f1                	div    %ecx
  800eae:	89 c6                	mov    %eax,%esi
  800eb0:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800eb2:	89 f0                	mov    %esi,%eax
  800eb4:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800eb6:	83 c4 10             	add    $0x10,%esp
  800eb9:	5e                   	pop    %esi
  800eba:	5f                   	pop    %edi
  800ebb:	5d                   	pop    %ebp
  800ebc:	c3                   	ret    
  800ebd:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800ec0:	89 f1                	mov    %esi,%ecx
  800ec2:	d3 e0                	shl    %cl,%eax
  800ec4:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800ec8:	b8 20 00 00 00       	mov    $0x20,%eax
  800ecd:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800ecf:	89 ea                	mov    %ebp,%edx
  800ed1:	88 c1                	mov    %al,%cl
  800ed3:	d3 ea                	shr    %cl,%edx
  800ed5:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800ed9:	09 ca                	or     %ecx,%edx
  800edb:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  800edf:	89 f1                	mov    %esi,%ecx
  800ee1:	d3 e5                	shl    %cl,%ebp
  800ee3:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  800ee7:	89 fd                	mov    %edi,%ebp
  800ee9:	88 c1                	mov    %al,%cl
  800eeb:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  800eed:	89 fa                	mov    %edi,%edx
  800eef:	89 f1                	mov    %esi,%ecx
  800ef1:	d3 e2                	shl    %cl,%edx
  800ef3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ef7:	88 c1                	mov    %al,%cl
  800ef9:	d3 ef                	shr    %cl,%edi
  800efb:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800efd:	89 f8                	mov    %edi,%eax
  800eff:	89 ea                	mov    %ebp,%edx
  800f01:	f7 74 24 08          	divl   0x8(%esp)
  800f05:	89 d1                	mov    %edx,%ecx
  800f07:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  800f09:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f0d:	39 d1                	cmp    %edx,%ecx
  800f0f:	72 17                	jb     800f28 <__udivdi3+0x10c>
  800f11:	74 09                	je     800f1c <__udivdi3+0x100>
  800f13:	89 fe                	mov    %edi,%esi
  800f15:	31 ff                	xor    %edi,%edi
  800f17:	e9 41 ff ff ff       	jmp    800e5d <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800f1c:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f20:	89 f1                	mov    %esi,%ecx
  800f22:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f24:	39 c2                	cmp    %eax,%edx
  800f26:	73 eb                	jae    800f13 <__udivdi3+0xf7>
		{
		  q0--;
  800f28:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f2b:	31 ff                	xor    %edi,%edi
  800f2d:	e9 2b ff ff ff       	jmp    800e5d <__udivdi3+0x41>
  800f32:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800f34:	31 f6                	xor    %esi,%esi
  800f36:	e9 22 ff ff ff       	jmp    800e5d <__udivdi3+0x41>
	...

00800f3c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800f3c:	55                   	push   %ebp
  800f3d:	57                   	push   %edi
  800f3e:	56                   	push   %esi
  800f3f:	83 ec 20             	sub    $0x20,%esp
  800f42:	8b 44 24 30          	mov    0x30(%esp),%eax
  800f46:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800f4a:	89 44 24 14          	mov    %eax,0x14(%esp)
  800f4e:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  800f52:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800f56:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800f5a:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  800f5c:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800f5e:	85 ed                	test   %ebp,%ebp
  800f60:	75 16                	jne    800f78 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  800f62:	39 f1                	cmp    %esi,%ecx
  800f64:	0f 86 a6 00 00 00    	jbe    801010 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f6a:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800f6c:	89 d0                	mov    %edx,%eax
  800f6e:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f70:	83 c4 20             	add    $0x20,%esp
  800f73:	5e                   	pop    %esi
  800f74:	5f                   	pop    %edi
  800f75:	5d                   	pop    %ebp
  800f76:	c3                   	ret    
  800f77:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800f78:	39 f5                	cmp    %esi,%ebp
  800f7a:	0f 87 ac 00 00 00    	ja     80102c <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800f80:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  800f83:	83 f0 1f             	xor    $0x1f,%eax
  800f86:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f8a:	0f 84 a8 00 00 00    	je     801038 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800f90:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f94:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800f96:	bf 20 00 00 00       	mov    $0x20,%edi
  800f9b:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800f9f:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800fa3:	89 f9                	mov    %edi,%ecx
  800fa5:	d3 e8                	shr    %cl,%eax
  800fa7:	09 e8                	or     %ebp,%eax
  800fa9:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  800fad:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800fb1:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800fb5:	d3 e0                	shl    %cl,%eax
  800fb7:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800fbb:	89 f2                	mov    %esi,%edx
  800fbd:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800fbf:	8b 44 24 14          	mov    0x14(%esp),%eax
  800fc3:	d3 e0                	shl    %cl,%eax
  800fc5:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800fc9:	8b 44 24 14          	mov    0x14(%esp),%eax
  800fcd:	89 f9                	mov    %edi,%ecx
  800fcf:	d3 e8                	shr    %cl,%eax
  800fd1:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800fd3:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800fd5:	89 f2                	mov    %esi,%edx
  800fd7:	f7 74 24 18          	divl   0x18(%esp)
  800fdb:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800fdd:	f7 64 24 0c          	mull   0xc(%esp)
  800fe1:	89 c5                	mov    %eax,%ebp
  800fe3:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800fe5:	39 d6                	cmp    %edx,%esi
  800fe7:	72 67                	jb     801050 <__umoddi3+0x114>
  800fe9:	74 75                	je     801060 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800feb:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800fef:	29 e8                	sub    %ebp,%eax
  800ff1:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800ff3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800ff7:	d3 e8                	shr    %cl,%eax
  800ff9:	89 f2                	mov    %esi,%edx
  800ffb:	89 f9                	mov    %edi,%ecx
  800ffd:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800fff:	09 d0                	or     %edx,%eax
  801001:	89 f2                	mov    %esi,%edx
  801003:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801007:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801009:	83 c4 20             	add    $0x20,%esp
  80100c:	5e                   	pop    %esi
  80100d:	5f                   	pop    %edi
  80100e:	5d                   	pop    %ebp
  80100f:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801010:	85 c9                	test   %ecx,%ecx
  801012:	75 0b                	jne    80101f <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801014:	b8 01 00 00 00       	mov    $0x1,%eax
  801019:	31 d2                	xor    %edx,%edx
  80101b:	f7 f1                	div    %ecx
  80101d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80101f:	89 f0                	mov    %esi,%eax
  801021:	31 d2                	xor    %edx,%edx
  801023:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801025:	89 f8                	mov    %edi,%eax
  801027:	e9 3e ff ff ff       	jmp    800f6a <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  80102c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80102e:	83 c4 20             	add    $0x20,%esp
  801031:	5e                   	pop    %esi
  801032:	5f                   	pop    %edi
  801033:	5d                   	pop    %ebp
  801034:	c3                   	ret    
  801035:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801038:	39 f5                	cmp    %esi,%ebp
  80103a:	72 04                	jb     801040 <__umoddi3+0x104>
  80103c:	39 f9                	cmp    %edi,%ecx
  80103e:	77 06                	ja     801046 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801040:	89 f2                	mov    %esi,%edx
  801042:	29 cf                	sub    %ecx,%edi
  801044:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801046:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801048:	83 c4 20             	add    $0x20,%esp
  80104b:	5e                   	pop    %esi
  80104c:	5f                   	pop    %edi
  80104d:	5d                   	pop    %ebp
  80104e:	c3                   	ret    
  80104f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801050:	89 d1                	mov    %edx,%ecx
  801052:	89 c5                	mov    %eax,%ebp
  801054:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801058:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  80105c:	eb 8d                	jmp    800feb <__umoddi3+0xaf>
  80105e:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801060:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801064:	72 ea                	jb     801050 <__umoddi3+0x114>
  801066:	89 f1                	mov    %esi,%ecx
  801068:	eb 81                	jmp    800feb <__umoddi3+0xaf>
