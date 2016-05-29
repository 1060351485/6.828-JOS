
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
  80004e:	e8 e4 00 00 00       	call   800137 <sys_getenvid>
  800053:	25 ff 03 00 00       	and    $0x3ff,%eax
  800058:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80005f:	c1 e0 07             	shl    $0x7,%eax
  800062:	29 d0                	sub    %edx,%eax
  800064:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800069:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006e:	85 f6                	test   %esi,%esi
  800070:	7e 07                	jle    800079 <libmain+0x39>
		binaryname = argv[0];
  800072:	8b 03                	mov    (%ebx),%eax
  800074:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800079:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80007d:	89 34 24             	mov    %esi,(%esp)
  800080:	e8 af ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800085:	e8 0a 00 00 00       	call   800094 <exit>
}
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	5b                   	pop    %ebx
  80008e:	5e                   	pop    %esi
  80008f:	5d                   	pop    %ebp
  800090:	c3                   	ret    
  800091:	00 00                	add    %al,(%eax)
	...

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
  800113:	c7 44 24 08 0a 10 80 	movl   $0x80100a,0x8(%esp)
  80011a:	00 
  80011b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800122:	00 
  800123:	c7 04 24 27 10 80 00 	movl   $0x801027,(%esp)
  80012a:	e8 b1 02 00 00       	call   8003e0 <_panic>

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
  8001a5:	c7 44 24 08 0a 10 80 	movl   $0x80100a,0x8(%esp)
  8001ac:	00 
  8001ad:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001b4:	00 
  8001b5:	c7 04 24 27 10 80 00 	movl   $0x801027,(%esp)
  8001bc:	e8 1f 02 00 00       	call   8003e0 <_panic>

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
  8001f8:	c7 44 24 08 0a 10 80 	movl   $0x80100a,0x8(%esp)
  8001ff:	00 
  800200:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800207:	00 
  800208:	c7 04 24 27 10 80 00 	movl   $0x801027,(%esp)
  80020f:	e8 cc 01 00 00       	call   8003e0 <_panic>

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
  80024b:	c7 44 24 08 0a 10 80 	movl   $0x80100a,0x8(%esp)
  800252:	00 
  800253:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80025a:	00 
  80025b:	c7 04 24 27 10 80 00 	movl   $0x801027,(%esp)
  800262:	e8 79 01 00 00       	call   8003e0 <_panic>

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
  80029e:	c7 44 24 08 0a 10 80 	movl   $0x80100a,0x8(%esp)
  8002a5:	00 
  8002a6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002ad:	00 
  8002ae:	c7 04 24 27 10 80 00 	movl   $0x801027,(%esp)
  8002b5:	e8 26 01 00 00       	call   8003e0 <_panic>

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
  8002f1:	c7 44 24 08 0a 10 80 	movl   $0x80100a,0x8(%esp)
  8002f8:	00 
  8002f9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800300:	00 
  800301:	c7 04 24 27 10 80 00 	movl   $0x801027,(%esp)
  800308:	e8 d3 00 00 00       	call   8003e0 <_panic>

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
  800344:	c7 44 24 08 0a 10 80 	movl   $0x80100a,0x8(%esp)
  80034b:	00 
  80034c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800353:	00 
  800354:	c7 04 24 27 10 80 00 	movl   $0x801027,(%esp)
  80035b:	e8 80 00 00 00       	call   8003e0 <_panic>

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
  8003b9:	c7 44 24 08 0a 10 80 	movl   $0x80100a,0x8(%esp)
  8003c0:	00 
  8003c1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003c8:	00 
  8003c9:	c7 04 24 27 10 80 00 	movl   $0x801027,(%esp)
  8003d0:	e8 0b 00 00 00       	call   8003e0 <_panic>

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
  8003dd:	00 00                	add    %al,(%eax)
	...

008003e0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
  8003e3:	56                   	push   %esi
  8003e4:	53                   	push   %ebx
  8003e5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8003e8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003eb:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8003f1:	e8 41 fd ff ff       	call   800137 <sys_getenvid>
  8003f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003fd:	8b 55 08             	mov    0x8(%ebp),%edx
  800400:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800404:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800408:	89 44 24 04          	mov    %eax,0x4(%esp)
  80040c:	c7 04 24 38 10 80 00 	movl   $0x801038,(%esp)
  800413:	e8 c0 00 00 00       	call   8004d8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800418:	89 74 24 04          	mov    %esi,0x4(%esp)
  80041c:	8b 45 10             	mov    0x10(%ebp),%eax
  80041f:	89 04 24             	mov    %eax,(%esp)
  800422:	e8 50 00 00 00       	call   800477 <vcprintf>
	cprintf("\n");
  800427:	c7 04 24 5b 10 80 00 	movl   $0x80105b,(%esp)
  80042e:	e8 a5 00 00 00       	call   8004d8 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800433:	cc                   	int3   
  800434:	eb fd                	jmp    800433 <_panic+0x53>
	...

00800438 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800438:	55                   	push   %ebp
  800439:	89 e5                	mov    %esp,%ebp
  80043b:	53                   	push   %ebx
  80043c:	83 ec 14             	sub    $0x14,%esp
  80043f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800442:	8b 03                	mov    (%ebx),%eax
  800444:	8b 55 08             	mov    0x8(%ebp),%edx
  800447:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80044b:	40                   	inc    %eax
  80044c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80044e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800453:	75 19                	jne    80046e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800455:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80045c:	00 
  80045d:	8d 43 08             	lea    0x8(%ebx),%eax
  800460:	89 04 24             	mov    %eax,(%esp)
  800463:	e8 40 fc ff ff       	call   8000a8 <sys_cputs>
		b->idx = 0;
  800468:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80046e:	ff 43 04             	incl   0x4(%ebx)
}
  800471:	83 c4 14             	add    $0x14,%esp
  800474:	5b                   	pop    %ebx
  800475:	5d                   	pop    %ebp
  800476:	c3                   	ret    

00800477 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800477:	55                   	push   %ebp
  800478:	89 e5                	mov    %esp,%ebp
  80047a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800480:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800487:	00 00 00 
	b.cnt = 0;
  80048a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800491:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800494:	8b 45 0c             	mov    0xc(%ebp),%eax
  800497:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80049b:	8b 45 08             	mov    0x8(%ebp),%eax
  80049e:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004a2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ac:	c7 04 24 38 04 80 00 	movl   $0x800438,(%esp)
  8004b3:	e8 82 01 00 00       	call   80063a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004b8:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8004be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004c2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004c8:	89 04 24             	mov    %eax,(%esp)
  8004cb:	e8 d8 fb ff ff       	call   8000a8 <sys_cputs>

	return b.cnt;
}
  8004d0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004d6:	c9                   	leave  
  8004d7:	c3                   	ret    

008004d8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004d8:	55                   	push   %ebp
  8004d9:	89 e5                	mov    %esp,%ebp
  8004db:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004de:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e8:	89 04 24             	mov    %eax,(%esp)
  8004eb:	e8 87 ff ff ff       	call   800477 <vcprintf>
	va_end(ap);

	return cnt;
}
  8004f0:	c9                   	leave  
  8004f1:	c3                   	ret    
	...

008004f4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004f4:	55                   	push   %ebp
  8004f5:	89 e5                	mov    %esp,%ebp
  8004f7:	57                   	push   %edi
  8004f8:	56                   	push   %esi
  8004f9:	53                   	push   %ebx
  8004fa:	83 ec 3c             	sub    $0x3c,%esp
  8004fd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800500:	89 d7                	mov    %edx,%edi
  800502:	8b 45 08             	mov    0x8(%ebp),%eax
  800505:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800508:	8b 45 0c             	mov    0xc(%ebp),%eax
  80050b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80050e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800511:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800514:	85 c0                	test   %eax,%eax
  800516:	75 08                	jne    800520 <printnum+0x2c>
  800518:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80051b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80051e:	77 57                	ja     800577 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800520:	89 74 24 10          	mov    %esi,0x10(%esp)
  800524:	4b                   	dec    %ebx
  800525:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800529:	8b 45 10             	mov    0x10(%ebp),%eax
  80052c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800530:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800534:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800538:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80053f:	00 
  800540:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800543:	89 04 24             	mov    %eax,(%esp)
  800546:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800549:	89 44 24 04          	mov    %eax,0x4(%esp)
  80054d:	e8 56 08 00 00       	call   800da8 <__udivdi3>
  800552:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800556:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80055a:	89 04 24             	mov    %eax,(%esp)
  80055d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800561:	89 fa                	mov    %edi,%edx
  800563:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800566:	e8 89 ff ff ff       	call   8004f4 <printnum>
  80056b:	eb 0f                	jmp    80057c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80056d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800571:	89 34 24             	mov    %esi,(%esp)
  800574:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800577:	4b                   	dec    %ebx
  800578:	85 db                	test   %ebx,%ebx
  80057a:	7f f1                	jg     80056d <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80057c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800580:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800584:	8b 45 10             	mov    0x10(%ebp),%eax
  800587:	89 44 24 08          	mov    %eax,0x8(%esp)
  80058b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800592:	00 
  800593:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800596:	89 04 24             	mov    %eax,(%esp)
  800599:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80059c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005a0:	e8 23 09 00 00       	call   800ec8 <__umoddi3>
  8005a5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005a9:	0f be 80 5d 10 80 00 	movsbl 0x80105d(%eax),%eax
  8005b0:	89 04 24             	mov    %eax,(%esp)
  8005b3:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8005b6:	83 c4 3c             	add    $0x3c,%esp
  8005b9:	5b                   	pop    %ebx
  8005ba:	5e                   	pop    %esi
  8005bb:	5f                   	pop    %edi
  8005bc:	5d                   	pop    %ebp
  8005bd:	c3                   	ret    

008005be <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8005be:	55                   	push   %ebp
  8005bf:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8005c1:	83 fa 01             	cmp    $0x1,%edx
  8005c4:	7e 0e                	jle    8005d4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8005c6:	8b 10                	mov    (%eax),%edx
  8005c8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8005cb:	89 08                	mov    %ecx,(%eax)
  8005cd:	8b 02                	mov    (%edx),%eax
  8005cf:	8b 52 04             	mov    0x4(%edx),%edx
  8005d2:	eb 22                	jmp    8005f6 <getuint+0x38>
	else if (lflag)
  8005d4:	85 d2                	test   %edx,%edx
  8005d6:	74 10                	je     8005e8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8005d8:	8b 10                	mov    (%eax),%edx
  8005da:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005dd:	89 08                	mov    %ecx,(%eax)
  8005df:	8b 02                	mov    (%edx),%eax
  8005e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8005e6:	eb 0e                	jmp    8005f6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005e8:	8b 10                	mov    (%eax),%edx
  8005ea:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005ed:	89 08                	mov    %ecx,(%eax)
  8005ef:	8b 02                	mov    (%edx),%eax
  8005f1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005f6:	5d                   	pop    %ebp
  8005f7:	c3                   	ret    

008005f8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005f8:	55                   	push   %ebp
  8005f9:	89 e5                	mov    %esp,%ebp
  8005fb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005fe:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800601:	8b 10                	mov    (%eax),%edx
  800603:	3b 50 04             	cmp    0x4(%eax),%edx
  800606:	73 08                	jae    800610 <sprintputch+0x18>
		*b->buf++ = ch;
  800608:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80060b:	88 0a                	mov    %cl,(%edx)
  80060d:	42                   	inc    %edx
  80060e:	89 10                	mov    %edx,(%eax)
}
  800610:	5d                   	pop    %ebp
  800611:	c3                   	ret    

00800612 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800612:	55                   	push   %ebp
  800613:	89 e5                	mov    %esp,%ebp
  800615:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800618:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80061b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80061f:	8b 45 10             	mov    0x10(%ebp),%eax
  800622:	89 44 24 08          	mov    %eax,0x8(%esp)
  800626:	8b 45 0c             	mov    0xc(%ebp),%eax
  800629:	89 44 24 04          	mov    %eax,0x4(%esp)
  80062d:	8b 45 08             	mov    0x8(%ebp),%eax
  800630:	89 04 24             	mov    %eax,(%esp)
  800633:	e8 02 00 00 00       	call   80063a <vprintfmt>
	va_end(ap);
}
  800638:	c9                   	leave  
  800639:	c3                   	ret    

0080063a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80063a:	55                   	push   %ebp
  80063b:	89 e5                	mov    %esp,%ebp
  80063d:	57                   	push   %edi
  80063e:	56                   	push   %esi
  80063f:	53                   	push   %ebx
  800640:	83 ec 4c             	sub    $0x4c,%esp
  800643:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800646:	8b 75 10             	mov    0x10(%ebp),%esi
  800649:	eb 12                	jmp    80065d <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80064b:	85 c0                	test   %eax,%eax
  80064d:	0f 84 6b 03 00 00    	je     8009be <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800653:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800657:	89 04 24             	mov    %eax,(%esp)
  80065a:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80065d:	0f b6 06             	movzbl (%esi),%eax
  800660:	46                   	inc    %esi
  800661:	83 f8 25             	cmp    $0x25,%eax
  800664:	75 e5                	jne    80064b <vprintfmt+0x11>
  800666:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80066a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800671:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800676:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80067d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800682:	eb 26                	jmp    8006aa <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800684:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800687:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80068b:	eb 1d                	jmp    8006aa <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800690:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800694:	eb 14                	jmp    8006aa <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800696:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800699:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8006a0:	eb 08                	jmp    8006aa <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8006a2:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8006a5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006aa:	0f b6 06             	movzbl (%esi),%eax
  8006ad:	8d 56 01             	lea    0x1(%esi),%edx
  8006b0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8006b3:	8a 16                	mov    (%esi),%dl
  8006b5:	83 ea 23             	sub    $0x23,%edx
  8006b8:	80 fa 55             	cmp    $0x55,%dl
  8006bb:	0f 87 e1 02 00 00    	ja     8009a2 <vprintfmt+0x368>
  8006c1:	0f b6 d2             	movzbl %dl,%edx
  8006c4:	ff 24 95 a0 11 80 00 	jmp    *0x8011a0(,%edx,4)
  8006cb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006ce:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8006d3:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8006d6:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8006da:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8006dd:	8d 50 d0             	lea    -0x30(%eax),%edx
  8006e0:	83 fa 09             	cmp    $0x9,%edx
  8006e3:	77 2a                	ja     80070f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8006e5:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8006e6:	eb eb                	jmp    8006d3 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8006e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006eb:	8d 50 04             	lea    0x4(%eax),%edx
  8006ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f1:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8006f6:	eb 17                	jmp    80070f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8006f8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006fc:	78 98                	js     800696 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006fe:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800701:	eb a7                	jmp    8006aa <vprintfmt+0x70>
  800703:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800706:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80070d:	eb 9b                	jmp    8006aa <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80070f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800713:	79 95                	jns    8006aa <vprintfmt+0x70>
  800715:	eb 8b                	jmp    8006a2 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800717:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800718:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80071b:	eb 8d                	jmp    8006aa <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80071d:	8b 45 14             	mov    0x14(%ebp),%eax
  800720:	8d 50 04             	lea    0x4(%eax),%edx
  800723:	89 55 14             	mov    %edx,0x14(%ebp)
  800726:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80072a:	8b 00                	mov    (%eax),%eax
  80072c:	89 04 24             	mov    %eax,(%esp)
  80072f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800732:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800735:	e9 23 ff ff ff       	jmp    80065d <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80073a:	8b 45 14             	mov    0x14(%ebp),%eax
  80073d:	8d 50 04             	lea    0x4(%eax),%edx
  800740:	89 55 14             	mov    %edx,0x14(%ebp)
  800743:	8b 00                	mov    (%eax),%eax
  800745:	85 c0                	test   %eax,%eax
  800747:	79 02                	jns    80074b <vprintfmt+0x111>
  800749:	f7 d8                	neg    %eax
  80074b:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80074d:	83 f8 0f             	cmp    $0xf,%eax
  800750:	7f 0b                	jg     80075d <vprintfmt+0x123>
  800752:	8b 04 85 00 13 80 00 	mov    0x801300(,%eax,4),%eax
  800759:	85 c0                	test   %eax,%eax
  80075b:	75 23                	jne    800780 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80075d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800761:	c7 44 24 08 75 10 80 	movl   $0x801075,0x8(%esp)
  800768:	00 
  800769:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80076d:	8b 45 08             	mov    0x8(%ebp),%eax
  800770:	89 04 24             	mov    %eax,(%esp)
  800773:	e8 9a fe ff ff       	call   800612 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800778:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80077b:	e9 dd fe ff ff       	jmp    80065d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800780:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800784:	c7 44 24 08 7e 10 80 	movl   $0x80107e,0x8(%esp)
  80078b:	00 
  80078c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800790:	8b 55 08             	mov    0x8(%ebp),%edx
  800793:	89 14 24             	mov    %edx,(%esp)
  800796:	e8 77 fe ff ff       	call   800612 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80079b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80079e:	e9 ba fe ff ff       	jmp    80065d <vprintfmt+0x23>
  8007a3:	89 f9                	mov    %edi,%ecx
  8007a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007a8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8007ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ae:	8d 50 04             	lea    0x4(%eax),%edx
  8007b1:	89 55 14             	mov    %edx,0x14(%ebp)
  8007b4:	8b 30                	mov    (%eax),%esi
  8007b6:	85 f6                	test   %esi,%esi
  8007b8:	75 05                	jne    8007bf <vprintfmt+0x185>
				p = "(null)";
  8007ba:	be 6e 10 80 00       	mov    $0x80106e,%esi
			if (width > 0 && padc != '-')
  8007bf:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8007c3:	0f 8e 84 00 00 00    	jle    80084d <vprintfmt+0x213>
  8007c9:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8007cd:	74 7e                	je     80084d <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8007cf:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007d3:	89 34 24             	mov    %esi,(%esp)
  8007d6:	e8 8b 02 00 00       	call   800a66 <strnlen>
  8007db:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007de:	29 c2                	sub    %eax,%edx
  8007e0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8007e3:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8007e7:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8007ea:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8007ed:	89 de                	mov    %ebx,%esi
  8007ef:	89 d3                	mov    %edx,%ebx
  8007f1:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007f3:	eb 0b                	jmp    800800 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8007f5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007f9:	89 3c 24             	mov    %edi,(%esp)
  8007fc:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007ff:	4b                   	dec    %ebx
  800800:	85 db                	test   %ebx,%ebx
  800802:	7f f1                	jg     8007f5 <vprintfmt+0x1bb>
  800804:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800807:	89 f3                	mov    %esi,%ebx
  800809:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80080c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80080f:	85 c0                	test   %eax,%eax
  800811:	79 05                	jns    800818 <vprintfmt+0x1de>
  800813:	b8 00 00 00 00       	mov    $0x0,%eax
  800818:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80081b:	29 c2                	sub    %eax,%edx
  80081d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800820:	eb 2b                	jmp    80084d <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800822:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800826:	74 18                	je     800840 <vprintfmt+0x206>
  800828:	8d 50 e0             	lea    -0x20(%eax),%edx
  80082b:	83 fa 5e             	cmp    $0x5e,%edx
  80082e:	76 10                	jbe    800840 <vprintfmt+0x206>
					putch('?', putdat);
  800830:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800834:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80083b:	ff 55 08             	call   *0x8(%ebp)
  80083e:	eb 0a                	jmp    80084a <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800840:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800844:	89 04 24             	mov    %eax,(%esp)
  800847:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80084a:	ff 4d e4             	decl   -0x1c(%ebp)
  80084d:	0f be 06             	movsbl (%esi),%eax
  800850:	46                   	inc    %esi
  800851:	85 c0                	test   %eax,%eax
  800853:	74 21                	je     800876 <vprintfmt+0x23c>
  800855:	85 ff                	test   %edi,%edi
  800857:	78 c9                	js     800822 <vprintfmt+0x1e8>
  800859:	4f                   	dec    %edi
  80085a:	79 c6                	jns    800822 <vprintfmt+0x1e8>
  80085c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80085f:	89 de                	mov    %ebx,%esi
  800861:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800864:	eb 18                	jmp    80087e <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800866:	89 74 24 04          	mov    %esi,0x4(%esp)
  80086a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800871:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800873:	4b                   	dec    %ebx
  800874:	eb 08                	jmp    80087e <vprintfmt+0x244>
  800876:	8b 7d 08             	mov    0x8(%ebp),%edi
  800879:	89 de                	mov    %ebx,%esi
  80087b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80087e:	85 db                	test   %ebx,%ebx
  800880:	7f e4                	jg     800866 <vprintfmt+0x22c>
  800882:	89 7d 08             	mov    %edi,0x8(%ebp)
  800885:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800887:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80088a:	e9 ce fd ff ff       	jmp    80065d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80088f:	83 f9 01             	cmp    $0x1,%ecx
  800892:	7e 10                	jle    8008a4 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800894:	8b 45 14             	mov    0x14(%ebp),%eax
  800897:	8d 50 08             	lea    0x8(%eax),%edx
  80089a:	89 55 14             	mov    %edx,0x14(%ebp)
  80089d:	8b 30                	mov    (%eax),%esi
  80089f:	8b 78 04             	mov    0x4(%eax),%edi
  8008a2:	eb 26                	jmp    8008ca <vprintfmt+0x290>
	else if (lflag)
  8008a4:	85 c9                	test   %ecx,%ecx
  8008a6:	74 12                	je     8008ba <vprintfmt+0x280>
		return va_arg(*ap, long);
  8008a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ab:	8d 50 04             	lea    0x4(%eax),%edx
  8008ae:	89 55 14             	mov    %edx,0x14(%ebp)
  8008b1:	8b 30                	mov    (%eax),%esi
  8008b3:	89 f7                	mov    %esi,%edi
  8008b5:	c1 ff 1f             	sar    $0x1f,%edi
  8008b8:	eb 10                	jmp    8008ca <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8008ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8008bd:	8d 50 04             	lea    0x4(%eax),%edx
  8008c0:	89 55 14             	mov    %edx,0x14(%ebp)
  8008c3:	8b 30                	mov    (%eax),%esi
  8008c5:	89 f7                	mov    %esi,%edi
  8008c7:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8008ca:	85 ff                	test   %edi,%edi
  8008cc:	78 0a                	js     8008d8 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8008ce:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008d3:	e9 8c 00 00 00       	jmp    800964 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8008d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008dc:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8008e3:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8008e6:	f7 de                	neg    %esi
  8008e8:	83 d7 00             	adc    $0x0,%edi
  8008eb:	f7 df                	neg    %edi
			}
			base = 10;
  8008ed:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008f2:	eb 70                	jmp    800964 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8008f4:	89 ca                	mov    %ecx,%edx
  8008f6:	8d 45 14             	lea    0x14(%ebp),%eax
  8008f9:	e8 c0 fc ff ff       	call   8005be <getuint>
  8008fe:	89 c6                	mov    %eax,%esi
  800900:	89 d7                	mov    %edx,%edi
			base = 10;
  800902:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800907:	eb 5b                	jmp    800964 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  800909:	89 ca                	mov    %ecx,%edx
  80090b:	8d 45 14             	lea    0x14(%ebp),%eax
  80090e:	e8 ab fc ff ff       	call   8005be <getuint>
  800913:	89 c6                	mov    %eax,%esi
  800915:	89 d7                	mov    %edx,%edi
			base = 8;
  800917:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80091c:	eb 46                	jmp    800964 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  80091e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800922:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800929:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80092c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800930:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800937:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80093a:	8b 45 14             	mov    0x14(%ebp),%eax
  80093d:	8d 50 04             	lea    0x4(%eax),%edx
  800940:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800943:	8b 30                	mov    (%eax),%esi
  800945:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80094a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80094f:	eb 13                	jmp    800964 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800951:	89 ca                	mov    %ecx,%edx
  800953:	8d 45 14             	lea    0x14(%ebp),%eax
  800956:	e8 63 fc ff ff       	call   8005be <getuint>
  80095b:	89 c6                	mov    %eax,%esi
  80095d:	89 d7                	mov    %edx,%edi
			base = 16;
  80095f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800964:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800968:	89 54 24 10          	mov    %edx,0x10(%esp)
  80096c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80096f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800973:	89 44 24 08          	mov    %eax,0x8(%esp)
  800977:	89 34 24             	mov    %esi,(%esp)
  80097a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80097e:	89 da                	mov    %ebx,%edx
  800980:	8b 45 08             	mov    0x8(%ebp),%eax
  800983:	e8 6c fb ff ff       	call   8004f4 <printnum>
			break;
  800988:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80098b:	e9 cd fc ff ff       	jmp    80065d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800990:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800994:	89 04 24             	mov    %eax,(%esp)
  800997:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80099a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80099d:	e9 bb fc ff ff       	jmp    80065d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8009a2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009a6:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8009ad:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009b0:	eb 01                	jmp    8009b3 <vprintfmt+0x379>
  8009b2:	4e                   	dec    %esi
  8009b3:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8009b7:	75 f9                	jne    8009b2 <vprintfmt+0x378>
  8009b9:	e9 9f fc ff ff       	jmp    80065d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8009be:	83 c4 4c             	add    $0x4c,%esp
  8009c1:	5b                   	pop    %ebx
  8009c2:	5e                   	pop    %esi
  8009c3:	5f                   	pop    %edi
  8009c4:	5d                   	pop    %ebp
  8009c5:	c3                   	ret    

008009c6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
  8009c9:	83 ec 28             	sub    $0x28,%esp
  8009cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cf:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009d2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009d5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009d9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009e3:	85 c0                	test   %eax,%eax
  8009e5:	74 30                	je     800a17 <vsnprintf+0x51>
  8009e7:	85 d2                	test   %edx,%edx
  8009e9:	7e 33                	jle    800a1e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8009ee:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009f2:	8b 45 10             	mov    0x10(%ebp),%eax
  8009f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009f9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a00:	c7 04 24 f8 05 80 00 	movl   $0x8005f8,(%esp)
  800a07:	e8 2e fc ff ff       	call   80063a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a0c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a0f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a15:	eb 0c                	jmp    800a23 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a17:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a1c:	eb 05                	jmp    800a23 <vsnprintf+0x5d>
  800a1e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a23:	c9                   	leave  
  800a24:	c3                   	ret    

00800a25 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a25:	55                   	push   %ebp
  800a26:	89 e5                	mov    %esp,%ebp
  800a28:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a2b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a2e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a32:	8b 45 10             	mov    0x10(%ebp),%eax
  800a35:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a39:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a3c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a40:	8b 45 08             	mov    0x8(%ebp),%eax
  800a43:	89 04 24             	mov    %eax,(%esp)
  800a46:	e8 7b ff ff ff       	call   8009c6 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a4b:	c9                   	leave  
  800a4c:	c3                   	ret    
  800a4d:	00 00                	add    %al,(%eax)
	...

00800a50 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a50:	55                   	push   %ebp
  800a51:	89 e5                	mov    %esp,%ebp
  800a53:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a56:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5b:	eb 01                	jmp    800a5e <strlen+0xe>
		n++;
  800a5d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a5e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a62:	75 f9                	jne    800a5d <strlen+0xd>
		n++;
	return n;
}
  800a64:	5d                   	pop    %ebp
  800a65:	c3                   	ret    

00800a66 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a66:	55                   	push   %ebp
  800a67:	89 e5                	mov    %esp,%ebp
  800a69:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800a6c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a6f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a74:	eb 01                	jmp    800a77 <strnlen+0x11>
		n++;
  800a76:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a77:	39 d0                	cmp    %edx,%eax
  800a79:	74 06                	je     800a81 <strnlen+0x1b>
  800a7b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a7f:	75 f5                	jne    800a76 <strnlen+0x10>
		n++;
	return n;
}
  800a81:	5d                   	pop    %ebp
  800a82:	c3                   	ret    

00800a83 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a83:	55                   	push   %ebp
  800a84:	89 e5                	mov    %esp,%ebp
  800a86:	53                   	push   %ebx
  800a87:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a92:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800a95:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a98:	42                   	inc    %edx
  800a99:	84 c9                	test   %cl,%cl
  800a9b:	75 f5                	jne    800a92 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a9d:	5b                   	pop    %ebx
  800a9e:	5d                   	pop    %ebp
  800a9f:	c3                   	ret    

00800aa0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	53                   	push   %ebx
  800aa4:	83 ec 08             	sub    $0x8,%esp
  800aa7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800aaa:	89 1c 24             	mov    %ebx,(%esp)
  800aad:	e8 9e ff ff ff       	call   800a50 <strlen>
	strcpy(dst + len, src);
  800ab2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ab5:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ab9:	01 d8                	add    %ebx,%eax
  800abb:	89 04 24             	mov    %eax,(%esp)
  800abe:	e8 c0 ff ff ff       	call   800a83 <strcpy>
	return dst;
}
  800ac3:	89 d8                	mov    %ebx,%eax
  800ac5:	83 c4 08             	add    $0x8,%esp
  800ac8:	5b                   	pop    %ebx
  800ac9:	5d                   	pop    %ebp
  800aca:	c3                   	ret    

00800acb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800acb:	55                   	push   %ebp
  800acc:	89 e5                	mov    %esp,%ebp
  800ace:	56                   	push   %esi
  800acf:	53                   	push   %ebx
  800ad0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ad6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ad9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ade:	eb 0c                	jmp    800aec <strncpy+0x21>
		*dst++ = *src;
  800ae0:	8a 1a                	mov    (%edx),%bl
  800ae2:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ae5:	80 3a 01             	cmpb   $0x1,(%edx)
  800ae8:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800aeb:	41                   	inc    %ecx
  800aec:	39 f1                	cmp    %esi,%ecx
  800aee:	75 f0                	jne    800ae0 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800af0:	5b                   	pop    %ebx
  800af1:	5e                   	pop    %esi
  800af2:	5d                   	pop    %ebp
  800af3:	c3                   	ret    

00800af4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800af4:	55                   	push   %ebp
  800af5:	89 e5                	mov    %esp,%ebp
  800af7:	56                   	push   %esi
  800af8:	53                   	push   %ebx
  800af9:	8b 75 08             	mov    0x8(%ebp),%esi
  800afc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aff:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b02:	85 d2                	test   %edx,%edx
  800b04:	75 0a                	jne    800b10 <strlcpy+0x1c>
  800b06:	89 f0                	mov    %esi,%eax
  800b08:	eb 1a                	jmp    800b24 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b0a:	88 18                	mov    %bl,(%eax)
  800b0c:	40                   	inc    %eax
  800b0d:	41                   	inc    %ecx
  800b0e:	eb 02                	jmp    800b12 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b10:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800b12:	4a                   	dec    %edx
  800b13:	74 0a                	je     800b1f <strlcpy+0x2b>
  800b15:	8a 19                	mov    (%ecx),%bl
  800b17:	84 db                	test   %bl,%bl
  800b19:	75 ef                	jne    800b0a <strlcpy+0x16>
  800b1b:	89 c2                	mov    %eax,%edx
  800b1d:	eb 02                	jmp    800b21 <strlcpy+0x2d>
  800b1f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800b21:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800b24:	29 f0                	sub    %esi,%eax
}
  800b26:	5b                   	pop    %ebx
  800b27:	5e                   	pop    %esi
  800b28:	5d                   	pop    %ebp
  800b29:	c3                   	ret    

00800b2a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b2a:	55                   	push   %ebp
  800b2b:	89 e5                	mov    %esp,%ebp
  800b2d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b30:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b33:	eb 02                	jmp    800b37 <strcmp+0xd>
		p++, q++;
  800b35:	41                   	inc    %ecx
  800b36:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b37:	8a 01                	mov    (%ecx),%al
  800b39:	84 c0                	test   %al,%al
  800b3b:	74 04                	je     800b41 <strcmp+0x17>
  800b3d:	3a 02                	cmp    (%edx),%al
  800b3f:	74 f4                	je     800b35 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b41:	0f b6 c0             	movzbl %al,%eax
  800b44:	0f b6 12             	movzbl (%edx),%edx
  800b47:	29 d0                	sub    %edx,%eax
}
  800b49:	5d                   	pop    %ebp
  800b4a:	c3                   	ret    

00800b4b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b4b:	55                   	push   %ebp
  800b4c:	89 e5                	mov    %esp,%ebp
  800b4e:	53                   	push   %ebx
  800b4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b55:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800b58:	eb 03                	jmp    800b5d <strncmp+0x12>
		n--, p++, q++;
  800b5a:	4a                   	dec    %edx
  800b5b:	40                   	inc    %eax
  800b5c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b5d:	85 d2                	test   %edx,%edx
  800b5f:	74 14                	je     800b75 <strncmp+0x2a>
  800b61:	8a 18                	mov    (%eax),%bl
  800b63:	84 db                	test   %bl,%bl
  800b65:	74 04                	je     800b6b <strncmp+0x20>
  800b67:	3a 19                	cmp    (%ecx),%bl
  800b69:	74 ef                	je     800b5a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b6b:	0f b6 00             	movzbl (%eax),%eax
  800b6e:	0f b6 11             	movzbl (%ecx),%edx
  800b71:	29 d0                	sub    %edx,%eax
  800b73:	eb 05                	jmp    800b7a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b75:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b7a:	5b                   	pop    %ebx
  800b7b:	5d                   	pop    %ebp
  800b7c:	c3                   	ret    

00800b7d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	8b 45 08             	mov    0x8(%ebp),%eax
  800b83:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b86:	eb 05                	jmp    800b8d <strchr+0x10>
		if (*s == c)
  800b88:	38 ca                	cmp    %cl,%dl
  800b8a:	74 0c                	je     800b98 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b8c:	40                   	inc    %eax
  800b8d:	8a 10                	mov    (%eax),%dl
  800b8f:	84 d2                	test   %dl,%dl
  800b91:	75 f5                	jne    800b88 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800b93:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    

00800b9a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba0:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800ba3:	eb 05                	jmp    800baa <strfind+0x10>
		if (*s == c)
  800ba5:	38 ca                	cmp    %cl,%dl
  800ba7:	74 07                	je     800bb0 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ba9:	40                   	inc    %eax
  800baa:	8a 10                	mov    (%eax),%dl
  800bac:	84 d2                	test   %dl,%dl
  800bae:	75 f5                	jne    800ba5 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800bb0:	5d                   	pop    %ebp
  800bb1:	c3                   	ret    

00800bb2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bb2:	55                   	push   %ebp
  800bb3:	89 e5                	mov    %esp,%ebp
  800bb5:	57                   	push   %edi
  800bb6:	56                   	push   %esi
  800bb7:	53                   	push   %ebx
  800bb8:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bbb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bbe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bc1:	85 c9                	test   %ecx,%ecx
  800bc3:	74 30                	je     800bf5 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bc5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bcb:	75 25                	jne    800bf2 <memset+0x40>
  800bcd:	f6 c1 03             	test   $0x3,%cl
  800bd0:	75 20                	jne    800bf2 <memset+0x40>
		c &= 0xFF;
  800bd2:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bd5:	89 d3                	mov    %edx,%ebx
  800bd7:	c1 e3 08             	shl    $0x8,%ebx
  800bda:	89 d6                	mov    %edx,%esi
  800bdc:	c1 e6 18             	shl    $0x18,%esi
  800bdf:	89 d0                	mov    %edx,%eax
  800be1:	c1 e0 10             	shl    $0x10,%eax
  800be4:	09 f0                	or     %esi,%eax
  800be6:	09 d0                	or     %edx,%eax
  800be8:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bea:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800bed:	fc                   	cld    
  800bee:	f3 ab                	rep stos %eax,%es:(%edi)
  800bf0:	eb 03                	jmp    800bf5 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bf2:	fc                   	cld    
  800bf3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bf5:	89 f8                	mov    %edi,%eax
  800bf7:	5b                   	pop    %ebx
  800bf8:	5e                   	pop    %esi
  800bf9:	5f                   	pop    %edi
  800bfa:	5d                   	pop    %ebp
  800bfb:	c3                   	ret    

00800bfc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	57                   	push   %edi
  800c00:	56                   	push   %esi
  800c01:	8b 45 08             	mov    0x8(%ebp),%eax
  800c04:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c07:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c0a:	39 c6                	cmp    %eax,%esi
  800c0c:	73 34                	jae    800c42 <memmove+0x46>
  800c0e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c11:	39 d0                	cmp    %edx,%eax
  800c13:	73 2d                	jae    800c42 <memmove+0x46>
		s += n;
		d += n;
  800c15:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c18:	f6 c2 03             	test   $0x3,%dl
  800c1b:	75 1b                	jne    800c38 <memmove+0x3c>
  800c1d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c23:	75 13                	jne    800c38 <memmove+0x3c>
  800c25:	f6 c1 03             	test   $0x3,%cl
  800c28:	75 0e                	jne    800c38 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c2a:	83 ef 04             	sub    $0x4,%edi
  800c2d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c30:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c33:	fd                   	std    
  800c34:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c36:	eb 07                	jmp    800c3f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c38:	4f                   	dec    %edi
  800c39:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c3c:	fd                   	std    
  800c3d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c3f:	fc                   	cld    
  800c40:	eb 20                	jmp    800c62 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c42:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c48:	75 13                	jne    800c5d <memmove+0x61>
  800c4a:	a8 03                	test   $0x3,%al
  800c4c:	75 0f                	jne    800c5d <memmove+0x61>
  800c4e:	f6 c1 03             	test   $0x3,%cl
  800c51:	75 0a                	jne    800c5d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c53:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c56:	89 c7                	mov    %eax,%edi
  800c58:	fc                   	cld    
  800c59:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c5b:	eb 05                	jmp    800c62 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c5d:	89 c7                	mov    %eax,%edi
  800c5f:	fc                   	cld    
  800c60:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c62:	5e                   	pop    %esi
  800c63:	5f                   	pop    %edi
  800c64:	5d                   	pop    %ebp
  800c65:	c3                   	ret    

00800c66 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c66:	55                   	push   %ebp
  800c67:	89 e5                	mov    %esp,%ebp
  800c69:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c6c:	8b 45 10             	mov    0x10(%ebp),%eax
  800c6f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c73:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c76:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7d:	89 04 24             	mov    %eax,(%esp)
  800c80:	e8 77 ff ff ff       	call   800bfc <memmove>
}
  800c85:	c9                   	leave  
  800c86:	c3                   	ret    

00800c87 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	57                   	push   %edi
  800c8b:	56                   	push   %esi
  800c8c:	53                   	push   %ebx
  800c8d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c90:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c93:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c96:	ba 00 00 00 00       	mov    $0x0,%edx
  800c9b:	eb 16                	jmp    800cb3 <memcmp+0x2c>
		if (*s1 != *s2)
  800c9d:	8a 04 17             	mov    (%edi,%edx,1),%al
  800ca0:	42                   	inc    %edx
  800ca1:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800ca5:	38 c8                	cmp    %cl,%al
  800ca7:	74 0a                	je     800cb3 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800ca9:	0f b6 c0             	movzbl %al,%eax
  800cac:	0f b6 c9             	movzbl %cl,%ecx
  800caf:	29 c8                	sub    %ecx,%eax
  800cb1:	eb 09                	jmp    800cbc <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cb3:	39 da                	cmp    %ebx,%edx
  800cb5:	75 e6                	jne    800c9d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800cb7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cbc:	5b                   	pop    %ebx
  800cbd:	5e                   	pop    %esi
  800cbe:	5f                   	pop    %edi
  800cbf:	5d                   	pop    %ebp
  800cc0:	c3                   	ret    

00800cc1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800cca:	89 c2                	mov    %eax,%edx
  800ccc:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ccf:	eb 05                	jmp    800cd6 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cd1:	38 08                	cmp    %cl,(%eax)
  800cd3:	74 05                	je     800cda <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cd5:	40                   	inc    %eax
  800cd6:	39 d0                	cmp    %edx,%eax
  800cd8:	72 f7                	jb     800cd1 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800cda:	5d                   	pop    %ebp
  800cdb:	c3                   	ret    

00800cdc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cdc:	55                   	push   %ebp
  800cdd:	89 e5                	mov    %esp,%ebp
  800cdf:	57                   	push   %edi
  800ce0:	56                   	push   %esi
  800ce1:	53                   	push   %ebx
  800ce2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ce8:	eb 01                	jmp    800ceb <strtol+0xf>
		s++;
  800cea:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ceb:	8a 02                	mov    (%edx),%al
  800ced:	3c 20                	cmp    $0x20,%al
  800cef:	74 f9                	je     800cea <strtol+0xe>
  800cf1:	3c 09                	cmp    $0x9,%al
  800cf3:	74 f5                	je     800cea <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cf5:	3c 2b                	cmp    $0x2b,%al
  800cf7:	75 08                	jne    800d01 <strtol+0x25>
		s++;
  800cf9:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cfa:	bf 00 00 00 00       	mov    $0x0,%edi
  800cff:	eb 13                	jmp    800d14 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d01:	3c 2d                	cmp    $0x2d,%al
  800d03:	75 0a                	jne    800d0f <strtol+0x33>
		s++, neg = 1;
  800d05:	8d 52 01             	lea    0x1(%edx),%edx
  800d08:	bf 01 00 00 00       	mov    $0x1,%edi
  800d0d:	eb 05                	jmp    800d14 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d0f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d14:	85 db                	test   %ebx,%ebx
  800d16:	74 05                	je     800d1d <strtol+0x41>
  800d18:	83 fb 10             	cmp    $0x10,%ebx
  800d1b:	75 28                	jne    800d45 <strtol+0x69>
  800d1d:	8a 02                	mov    (%edx),%al
  800d1f:	3c 30                	cmp    $0x30,%al
  800d21:	75 10                	jne    800d33 <strtol+0x57>
  800d23:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d27:	75 0a                	jne    800d33 <strtol+0x57>
		s += 2, base = 16;
  800d29:	83 c2 02             	add    $0x2,%edx
  800d2c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d31:	eb 12                	jmp    800d45 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800d33:	85 db                	test   %ebx,%ebx
  800d35:	75 0e                	jne    800d45 <strtol+0x69>
  800d37:	3c 30                	cmp    $0x30,%al
  800d39:	75 05                	jne    800d40 <strtol+0x64>
		s++, base = 8;
  800d3b:	42                   	inc    %edx
  800d3c:	b3 08                	mov    $0x8,%bl
  800d3e:	eb 05                	jmp    800d45 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800d40:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800d45:	b8 00 00 00 00       	mov    $0x0,%eax
  800d4a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d4c:	8a 0a                	mov    (%edx),%cl
  800d4e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d51:	80 fb 09             	cmp    $0x9,%bl
  800d54:	77 08                	ja     800d5e <strtol+0x82>
			dig = *s - '0';
  800d56:	0f be c9             	movsbl %cl,%ecx
  800d59:	83 e9 30             	sub    $0x30,%ecx
  800d5c:	eb 1e                	jmp    800d7c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800d5e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d61:	80 fb 19             	cmp    $0x19,%bl
  800d64:	77 08                	ja     800d6e <strtol+0x92>
			dig = *s - 'a' + 10;
  800d66:	0f be c9             	movsbl %cl,%ecx
  800d69:	83 e9 57             	sub    $0x57,%ecx
  800d6c:	eb 0e                	jmp    800d7c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800d6e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d71:	80 fb 19             	cmp    $0x19,%bl
  800d74:	77 12                	ja     800d88 <strtol+0xac>
			dig = *s - 'A' + 10;
  800d76:	0f be c9             	movsbl %cl,%ecx
  800d79:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d7c:	39 f1                	cmp    %esi,%ecx
  800d7e:	7d 0c                	jge    800d8c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800d80:	42                   	inc    %edx
  800d81:	0f af c6             	imul   %esi,%eax
  800d84:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d86:	eb c4                	jmp    800d4c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d88:	89 c1                	mov    %eax,%ecx
  800d8a:	eb 02                	jmp    800d8e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d8c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d8e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d92:	74 05                	je     800d99 <strtol+0xbd>
		*endptr = (char *) s;
  800d94:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d97:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d99:	85 ff                	test   %edi,%edi
  800d9b:	74 04                	je     800da1 <strtol+0xc5>
  800d9d:	89 c8                	mov    %ecx,%eax
  800d9f:	f7 d8                	neg    %eax
}
  800da1:	5b                   	pop    %ebx
  800da2:	5e                   	pop    %esi
  800da3:	5f                   	pop    %edi
  800da4:	5d                   	pop    %ebp
  800da5:	c3                   	ret    
	...

00800da8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800da8:	55                   	push   %ebp
  800da9:	57                   	push   %edi
  800daa:	56                   	push   %esi
  800dab:	83 ec 10             	sub    $0x10,%esp
  800dae:	8b 74 24 20          	mov    0x20(%esp),%esi
  800db2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800db6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800dba:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  800dbe:	89 cd                	mov    %ecx,%ebp
  800dc0:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800dc4:	85 c0                	test   %eax,%eax
  800dc6:	75 2c                	jne    800df4 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800dc8:	39 f9                	cmp    %edi,%ecx
  800dca:	77 68                	ja     800e34 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800dcc:	85 c9                	test   %ecx,%ecx
  800dce:	75 0b                	jne    800ddb <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800dd0:	b8 01 00 00 00       	mov    $0x1,%eax
  800dd5:	31 d2                	xor    %edx,%edx
  800dd7:	f7 f1                	div    %ecx
  800dd9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800ddb:	31 d2                	xor    %edx,%edx
  800ddd:	89 f8                	mov    %edi,%eax
  800ddf:	f7 f1                	div    %ecx
  800de1:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800de3:	89 f0                	mov    %esi,%eax
  800de5:	f7 f1                	div    %ecx
  800de7:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800de9:	89 f0                	mov    %esi,%eax
  800deb:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800ded:	83 c4 10             	add    $0x10,%esp
  800df0:	5e                   	pop    %esi
  800df1:	5f                   	pop    %edi
  800df2:	5d                   	pop    %ebp
  800df3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800df4:	39 f8                	cmp    %edi,%eax
  800df6:	77 2c                	ja     800e24 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800df8:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  800dfb:	83 f6 1f             	xor    $0x1f,%esi
  800dfe:	75 4c                	jne    800e4c <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e00:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e02:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e07:	72 0a                	jb     800e13 <__udivdi3+0x6b>
  800e09:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800e0d:	0f 87 ad 00 00 00    	ja     800ec0 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e13:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e18:	89 f0                	mov    %esi,%eax
  800e1a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e1c:	83 c4 10             	add    $0x10,%esp
  800e1f:	5e                   	pop    %esi
  800e20:	5f                   	pop    %edi
  800e21:	5d                   	pop    %ebp
  800e22:	c3                   	ret    
  800e23:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e24:	31 ff                	xor    %edi,%edi
  800e26:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e28:	89 f0                	mov    %esi,%eax
  800e2a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e2c:	83 c4 10             	add    $0x10,%esp
  800e2f:	5e                   	pop    %esi
  800e30:	5f                   	pop    %edi
  800e31:	5d                   	pop    %ebp
  800e32:	c3                   	ret    
  800e33:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e34:	89 fa                	mov    %edi,%edx
  800e36:	89 f0                	mov    %esi,%eax
  800e38:	f7 f1                	div    %ecx
  800e3a:	89 c6                	mov    %eax,%esi
  800e3c:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e3e:	89 f0                	mov    %esi,%eax
  800e40:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e42:	83 c4 10             	add    $0x10,%esp
  800e45:	5e                   	pop    %esi
  800e46:	5f                   	pop    %edi
  800e47:	5d                   	pop    %ebp
  800e48:	c3                   	ret    
  800e49:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e4c:	89 f1                	mov    %esi,%ecx
  800e4e:	d3 e0                	shl    %cl,%eax
  800e50:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e54:	b8 20 00 00 00       	mov    $0x20,%eax
  800e59:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800e5b:	89 ea                	mov    %ebp,%edx
  800e5d:	88 c1                	mov    %al,%cl
  800e5f:	d3 ea                	shr    %cl,%edx
  800e61:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800e65:	09 ca                	or     %ecx,%edx
  800e67:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  800e6b:	89 f1                	mov    %esi,%ecx
  800e6d:	d3 e5                	shl    %cl,%ebp
  800e6f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  800e73:	89 fd                	mov    %edi,%ebp
  800e75:	88 c1                	mov    %al,%cl
  800e77:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  800e79:	89 fa                	mov    %edi,%edx
  800e7b:	89 f1                	mov    %esi,%ecx
  800e7d:	d3 e2                	shl    %cl,%edx
  800e7f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e83:	88 c1                	mov    %al,%cl
  800e85:	d3 ef                	shr    %cl,%edi
  800e87:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e89:	89 f8                	mov    %edi,%eax
  800e8b:	89 ea                	mov    %ebp,%edx
  800e8d:	f7 74 24 08          	divl   0x8(%esp)
  800e91:	89 d1                	mov    %edx,%ecx
  800e93:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  800e95:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e99:	39 d1                	cmp    %edx,%ecx
  800e9b:	72 17                	jb     800eb4 <__udivdi3+0x10c>
  800e9d:	74 09                	je     800ea8 <__udivdi3+0x100>
  800e9f:	89 fe                	mov    %edi,%esi
  800ea1:	31 ff                	xor    %edi,%edi
  800ea3:	e9 41 ff ff ff       	jmp    800de9 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800ea8:	8b 54 24 04          	mov    0x4(%esp),%edx
  800eac:	89 f1                	mov    %esi,%ecx
  800eae:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800eb0:	39 c2                	cmp    %eax,%edx
  800eb2:	73 eb                	jae    800e9f <__udivdi3+0xf7>
		{
		  q0--;
  800eb4:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800eb7:	31 ff                	xor    %edi,%edi
  800eb9:	e9 2b ff ff ff       	jmp    800de9 <__udivdi3+0x41>
  800ebe:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ec0:	31 f6                	xor    %esi,%esi
  800ec2:	e9 22 ff ff ff       	jmp    800de9 <__udivdi3+0x41>
	...

00800ec8 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800ec8:	55                   	push   %ebp
  800ec9:	57                   	push   %edi
  800eca:	56                   	push   %esi
  800ecb:	83 ec 20             	sub    $0x20,%esp
  800ece:	8b 44 24 30          	mov    0x30(%esp),%eax
  800ed2:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800ed6:	89 44 24 14          	mov    %eax,0x14(%esp)
  800eda:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  800ede:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800ee2:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800ee6:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  800ee8:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800eea:	85 ed                	test   %ebp,%ebp
  800eec:	75 16                	jne    800f04 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  800eee:	39 f1                	cmp    %esi,%ecx
  800ef0:	0f 86 a6 00 00 00    	jbe    800f9c <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ef6:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800ef8:	89 d0                	mov    %edx,%eax
  800efa:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800efc:	83 c4 20             	add    $0x20,%esp
  800eff:	5e                   	pop    %esi
  800f00:	5f                   	pop    %edi
  800f01:	5d                   	pop    %ebp
  800f02:	c3                   	ret    
  800f03:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800f04:	39 f5                	cmp    %esi,%ebp
  800f06:	0f 87 ac 00 00 00    	ja     800fb8 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800f0c:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  800f0f:	83 f0 1f             	xor    $0x1f,%eax
  800f12:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f16:	0f 84 a8 00 00 00    	je     800fc4 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800f1c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f20:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800f22:	bf 20 00 00 00       	mov    $0x20,%edi
  800f27:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800f2b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f2f:	89 f9                	mov    %edi,%ecx
  800f31:	d3 e8                	shr    %cl,%eax
  800f33:	09 e8                	or     %ebp,%eax
  800f35:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  800f39:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f3d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f41:	d3 e0                	shl    %cl,%eax
  800f43:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800f47:	89 f2                	mov    %esi,%edx
  800f49:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800f4b:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f4f:	d3 e0                	shl    %cl,%eax
  800f51:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800f55:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f59:	89 f9                	mov    %edi,%ecx
  800f5b:	d3 e8                	shr    %cl,%eax
  800f5d:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800f5f:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800f61:	89 f2                	mov    %esi,%edx
  800f63:	f7 74 24 18          	divl   0x18(%esp)
  800f67:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800f69:	f7 64 24 0c          	mull   0xc(%esp)
  800f6d:	89 c5                	mov    %eax,%ebp
  800f6f:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f71:	39 d6                	cmp    %edx,%esi
  800f73:	72 67                	jb     800fdc <__umoddi3+0x114>
  800f75:	74 75                	je     800fec <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800f77:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800f7b:	29 e8                	sub    %ebp,%eax
  800f7d:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f7f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f83:	d3 e8                	shr    %cl,%eax
  800f85:	89 f2                	mov    %esi,%edx
  800f87:	89 f9                	mov    %edi,%ecx
  800f89:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800f8b:	09 d0                	or     %edx,%eax
  800f8d:	89 f2                	mov    %esi,%edx
  800f8f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f93:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f95:	83 c4 20             	add    $0x20,%esp
  800f98:	5e                   	pop    %esi
  800f99:	5f                   	pop    %edi
  800f9a:	5d                   	pop    %ebp
  800f9b:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800f9c:	85 c9                	test   %ecx,%ecx
  800f9e:	75 0b                	jne    800fab <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800fa0:	b8 01 00 00 00       	mov    $0x1,%eax
  800fa5:	31 d2                	xor    %edx,%edx
  800fa7:	f7 f1                	div    %ecx
  800fa9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800fab:	89 f0                	mov    %esi,%eax
  800fad:	31 d2                	xor    %edx,%edx
  800faf:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800fb1:	89 f8                	mov    %edi,%eax
  800fb3:	e9 3e ff ff ff       	jmp    800ef6 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800fb8:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800fba:	83 c4 20             	add    $0x20,%esp
  800fbd:	5e                   	pop    %esi
  800fbe:	5f                   	pop    %edi
  800fbf:	5d                   	pop    %ebp
  800fc0:	c3                   	ret    
  800fc1:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800fc4:	39 f5                	cmp    %esi,%ebp
  800fc6:	72 04                	jb     800fcc <__umoddi3+0x104>
  800fc8:	39 f9                	cmp    %edi,%ecx
  800fca:	77 06                	ja     800fd2 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800fcc:	89 f2                	mov    %esi,%edx
  800fce:	29 cf                	sub    %ecx,%edi
  800fd0:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800fd2:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800fd4:	83 c4 20             	add    $0x20,%esp
  800fd7:	5e                   	pop    %esi
  800fd8:	5f                   	pop    %edi
  800fd9:	5d                   	pop    %ebp
  800fda:	c3                   	ret    
  800fdb:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800fdc:	89 d1                	mov    %edx,%ecx
  800fde:	89 c5                	mov    %eax,%ebp
  800fe0:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800fe4:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800fe8:	eb 8d                	jmp    800f77 <__umoddi3+0xaf>
  800fea:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800fec:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800ff0:	72 ea                	jb     800fdc <__umoddi3+0x114>
  800ff2:	89 f1                	mov    %esi,%ecx
  800ff4:	eb 81                	jmp    800f77 <__umoddi3+0xaf>
