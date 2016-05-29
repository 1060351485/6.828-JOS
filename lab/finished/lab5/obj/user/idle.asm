
obj/user/idle.debug:     file format elf32-i386


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
  80002c:	e8 1b 00 00 00       	call   80004c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
#include <inc/x86.h>
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 08             	sub    $0x8,%esp
	binaryname = "idle";
  80003a:	c7 05 00 20 80 00 20 	movl   $0x801020,0x802000
  800041:	10 80 00 
	// Instead of busy-waiting like this,
	// a better way would be to use the processor's HLT instruction
	// to cause the processor to stop executing until the next interrupt -
	// doing so allows the processor to conserve power more effectively.
	while (1) {
		sys_yield();
  800044:	e8 19 01 00 00       	call   800162 <sys_yield>
  800049:	eb f9                	jmp    800044 <umain+0x10>
	...

0080004c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004c:	55                   	push   %ebp
  80004d:	89 e5                	mov    %esp,%ebp
  80004f:	56                   	push   %esi
  800050:	53                   	push   %ebx
  800051:	83 ec 10             	sub    $0x10,%esp
  800054:	8b 75 08             	mov    0x8(%ebp),%esi
  800057:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80005a:	e8 e4 00 00 00       	call   800143 <sys_getenvid>
  80005f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800064:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80006b:	c1 e0 07             	shl    $0x7,%eax
  80006e:	29 d0                	sub    %edx,%eax
  800070:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800075:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007a:	85 f6                	test   %esi,%esi
  80007c:	7e 07                	jle    800085 <libmain+0x39>
		binaryname = argv[0];
  80007e:	8b 03                	mov    (%ebx),%eax
  800080:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800085:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800089:	89 34 24             	mov    %esi,(%esp)
  80008c:	e8 a3 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800091:	e8 0a 00 00 00       	call   8000a0 <exit>
}
  800096:	83 c4 10             	add    $0x10,%esp
  800099:	5b                   	pop    %ebx
  80009a:	5e                   	pop    %esi
  80009b:	5d                   	pop    %ebp
  80009c:	c3                   	ret    
  80009d:	00 00                	add    %al,(%eax)
	...

008000a0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  8000a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ad:	e8 3f 00 00 00       	call   8000f1 <sys_env_destroy>
}
  8000b2:	c9                   	leave  
  8000b3:	c3                   	ret    

008000b4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	57                   	push   %edi
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8000bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c5:	89 c3                	mov    %eax,%ebx
  8000c7:	89 c7                	mov    %eax,%edi
  8000c9:	89 c6                	mov    %eax,%esi
  8000cb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5f                   	pop    %edi
  8000d0:	5d                   	pop    %ebp
  8000d1:	c3                   	ret    

008000d2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d2:	55                   	push   %ebp
  8000d3:	89 e5                	mov    %esp,%ebp
  8000d5:	57                   	push   %edi
  8000d6:	56                   	push   %esi
  8000d7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000dd:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e2:	89 d1                	mov    %edx,%ecx
  8000e4:	89 d3                	mov    %edx,%ebx
  8000e6:	89 d7                	mov    %edx,%edi
  8000e8:	89 d6                	mov    %edx,%esi
  8000ea:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ec:	5b                   	pop    %ebx
  8000ed:	5e                   	pop    %esi
  8000ee:	5f                   	pop    %edi
  8000ef:	5d                   	pop    %ebp
  8000f0:	c3                   	ret    

008000f1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f1:	55                   	push   %ebp
  8000f2:	89 e5                	mov    %esp,%ebp
  8000f4:	57                   	push   %edi
  8000f5:	56                   	push   %esi
  8000f6:	53                   	push   %ebx
  8000f7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ff:	b8 03 00 00 00       	mov    $0x3,%eax
  800104:	8b 55 08             	mov    0x8(%ebp),%edx
  800107:	89 cb                	mov    %ecx,%ebx
  800109:	89 cf                	mov    %ecx,%edi
  80010b:	89 ce                	mov    %ecx,%esi
  80010d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80010f:	85 c0                	test   %eax,%eax
  800111:	7e 28                	jle    80013b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800113:	89 44 24 10          	mov    %eax,0x10(%esp)
  800117:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80011e:	00 
  80011f:	c7 44 24 08 2f 10 80 	movl   $0x80102f,0x8(%esp)
  800126:	00 
  800127:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80012e:	00 
  80012f:	c7 04 24 4c 10 80 00 	movl   $0x80104c,(%esp)
  800136:	e8 b1 02 00 00       	call   8003ec <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80013b:	83 c4 2c             	add    $0x2c,%esp
  80013e:	5b                   	pop    %ebx
  80013f:	5e                   	pop    %esi
  800140:	5f                   	pop    %edi
  800141:	5d                   	pop    %ebp
  800142:	c3                   	ret    

00800143 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	57                   	push   %edi
  800147:	56                   	push   %esi
  800148:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800149:	ba 00 00 00 00       	mov    $0x0,%edx
  80014e:	b8 02 00 00 00       	mov    $0x2,%eax
  800153:	89 d1                	mov    %edx,%ecx
  800155:	89 d3                	mov    %edx,%ebx
  800157:	89 d7                	mov    %edx,%edi
  800159:	89 d6                	mov    %edx,%esi
  80015b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <sys_yield>:

void
sys_yield(void)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	57                   	push   %edi
  800166:	56                   	push   %esi
  800167:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800168:	ba 00 00 00 00       	mov    $0x0,%edx
  80016d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800172:	89 d1                	mov    %edx,%ecx
  800174:	89 d3                	mov    %edx,%ebx
  800176:	89 d7                	mov    %edx,%edi
  800178:	89 d6                	mov    %edx,%esi
  80017a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80017c:	5b                   	pop    %ebx
  80017d:	5e                   	pop    %esi
  80017e:	5f                   	pop    %edi
  80017f:	5d                   	pop    %ebp
  800180:	c3                   	ret    

00800181 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800181:	55                   	push   %ebp
  800182:	89 e5                	mov    %esp,%ebp
  800184:	57                   	push   %edi
  800185:	56                   	push   %esi
  800186:	53                   	push   %ebx
  800187:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80018a:	be 00 00 00 00       	mov    $0x0,%esi
  80018f:	b8 04 00 00 00       	mov    $0x4,%eax
  800194:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800197:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80019a:	8b 55 08             	mov    0x8(%ebp),%edx
  80019d:	89 f7                	mov    %esi,%edi
  80019f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001a1:	85 c0                	test   %eax,%eax
  8001a3:	7e 28                	jle    8001cd <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001a9:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001b0:	00 
  8001b1:	c7 44 24 08 2f 10 80 	movl   $0x80102f,0x8(%esp)
  8001b8:	00 
  8001b9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001c0:	00 
  8001c1:	c7 04 24 4c 10 80 00 	movl   $0x80104c,(%esp)
  8001c8:	e8 1f 02 00 00       	call   8003ec <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001cd:	83 c4 2c             	add    $0x2c,%esp
  8001d0:	5b                   	pop    %ebx
  8001d1:	5e                   	pop    %esi
  8001d2:	5f                   	pop    %edi
  8001d3:	5d                   	pop    %ebp
  8001d4:	c3                   	ret    

008001d5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001d5:	55                   	push   %ebp
  8001d6:	89 e5                	mov    %esp,%ebp
  8001d8:	57                   	push   %edi
  8001d9:	56                   	push   %esi
  8001da:	53                   	push   %ebx
  8001db:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001de:	b8 05 00 00 00       	mov    $0x5,%eax
  8001e3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001e6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001f4:	85 c0                	test   %eax,%eax
  8001f6:	7e 28                	jle    800220 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001fc:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800203:	00 
  800204:	c7 44 24 08 2f 10 80 	movl   $0x80102f,0x8(%esp)
  80020b:	00 
  80020c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800213:	00 
  800214:	c7 04 24 4c 10 80 00 	movl   $0x80104c,(%esp)
  80021b:	e8 cc 01 00 00       	call   8003ec <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800220:	83 c4 2c             	add    $0x2c,%esp
  800223:	5b                   	pop    %ebx
  800224:	5e                   	pop    %esi
  800225:	5f                   	pop    %edi
  800226:	5d                   	pop    %ebp
  800227:	c3                   	ret    

00800228 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800228:	55                   	push   %ebp
  800229:	89 e5                	mov    %esp,%ebp
  80022b:	57                   	push   %edi
  80022c:	56                   	push   %esi
  80022d:	53                   	push   %ebx
  80022e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800231:	bb 00 00 00 00       	mov    $0x0,%ebx
  800236:	b8 06 00 00 00       	mov    $0x6,%eax
  80023b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023e:	8b 55 08             	mov    0x8(%ebp),%edx
  800241:	89 df                	mov    %ebx,%edi
  800243:	89 de                	mov    %ebx,%esi
  800245:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800247:	85 c0                	test   %eax,%eax
  800249:	7e 28                	jle    800273 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80024b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80024f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800256:	00 
  800257:	c7 44 24 08 2f 10 80 	movl   $0x80102f,0x8(%esp)
  80025e:	00 
  80025f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800266:	00 
  800267:	c7 04 24 4c 10 80 00 	movl   $0x80104c,(%esp)
  80026e:	e8 79 01 00 00       	call   8003ec <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800273:	83 c4 2c             	add    $0x2c,%esp
  800276:	5b                   	pop    %ebx
  800277:	5e                   	pop    %esi
  800278:	5f                   	pop    %edi
  800279:	5d                   	pop    %ebp
  80027a:	c3                   	ret    

0080027b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80027b:	55                   	push   %ebp
  80027c:	89 e5                	mov    %esp,%ebp
  80027e:	57                   	push   %edi
  80027f:	56                   	push   %esi
  800280:	53                   	push   %ebx
  800281:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800284:	bb 00 00 00 00       	mov    $0x0,%ebx
  800289:	b8 08 00 00 00       	mov    $0x8,%eax
  80028e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800291:	8b 55 08             	mov    0x8(%ebp),%edx
  800294:	89 df                	mov    %ebx,%edi
  800296:	89 de                	mov    %ebx,%esi
  800298:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80029a:	85 c0                	test   %eax,%eax
  80029c:	7e 28                	jle    8002c6 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80029e:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002a2:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002a9:	00 
  8002aa:	c7 44 24 08 2f 10 80 	movl   $0x80102f,0x8(%esp)
  8002b1:	00 
  8002b2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002b9:	00 
  8002ba:	c7 04 24 4c 10 80 00 	movl   $0x80104c,(%esp)
  8002c1:	e8 26 01 00 00       	call   8003ec <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002c6:	83 c4 2c             	add    $0x2c,%esp
  8002c9:	5b                   	pop    %ebx
  8002ca:	5e                   	pop    %esi
  8002cb:	5f                   	pop    %edi
  8002cc:	5d                   	pop    %ebp
  8002cd:	c3                   	ret    

008002ce <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002ce:	55                   	push   %ebp
  8002cf:	89 e5                	mov    %esp,%ebp
  8002d1:	57                   	push   %edi
  8002d2:	56                   	push   %esi
  8002d3:	53                   	push   %ebx
  8002d4:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002dc:	b8 09 00 00 00       	mov    $0x9,%eax
  8002e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e7:	89 df                	mov    %ebx,%edi
  8002e9:	89 de                	mov    %ebx,%esi
  8002eb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002ed:	85 c0                	test   %eax,%eax
  8002ef:	7e 28                	jle    800319 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002f5:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002fc:	00 
  8002fd:	c7 44 24 08 2f 10 80 	movl   $0x80102f,0x8(%esp)
  800304:	00 
  800305:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80030c:	00 
  80030d:	c7 04 24 4c 10 80 00 	movl   $0x80104c,(%esp)
  800314:	e8 d3 00 00 00       	call   8003ec <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800319:	83 c4 2c             	add    $0x2c,%esp
  80031c:	5b                   	pop    %ebx
  80031d:	5e                   	pop    %esi
  80031e:	5f                   	pop    %edi
  80031f:	5d                   	pop    %ebp
  800320:	c3                   	ret    

00800321 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800321:	55                   	push   %ebp
  800322:	89 e5                	mov    %esp,%ebp
  800324:	57                   	push   %edi
  800325:	56                   	push   %esi
  800326:	53                   	push   %ebx
  800327:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80032a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80032f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800334:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800337:	8b 55 08             	mov    0x8(%ebp),%edx
  80033a:	89 df                	mov    %ebx,%edi
  80033c:	89 de                	mov    %ebx,%esi
  80033e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800340:	85 c0                	test   %eax,%eax
  800342:	7e 28                	jle    80036c <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800344:	89 44 24 10          	mov    %eax,0x10(%esp)
  800348:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80034f:	00 
  800350:	c7 44 24 08 2f 10 80 	movl   $0x80102f,0x8(%esp)
  800357:	00 
  800358:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80035f:	00 
  800360:	c7 04 24 4c 10 80 00 	movl   $0x80104c,(%esp)
  800367:	e8 80 00 00 00       	call   8003ec <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80036c:	83 c4 2c             	add    $0x2c,%esp
  80036f:	5b                   	pop    %ebx
  800370:	5e                   	pop    %esi
  800371:	5f                   	pop    %edi
  800372:	5d                   	pop    %ebp
  800373:	c3                   	ret    

00800374 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800374:	55                   	push   %ebp
  800375:	89 e5                	mov    %esp,%ebp
  800377:	57                   	push   %edi
  800378:	56                   	push   %esi
  800379:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80037a:	be 00 00 00 00       	mov    $0x0,%esi
  80037f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800384:	8b 7d 14             	mov    0x14(%ebp),%edi
  800387:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80038a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80038d:	8b 55 08             	mov    0x8(%ebp),%edx
  800390:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800392:	5b                   	pop    %ebx
  800393:	5e                   	pop    %esi
  800394:	5f                   	pop    %edi
  800395:	5d                   	pop    %ebp
  800396:	c3                   	ret    

00800397 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800397:	55                   	push   %ebp
  800398:	89 e5                	mov    %esp,%ebp
  80039a:	57                   	push   %edi
  80039b:	56                   	push   %esi
  80039c:	53                   	push   %ebx
  80039d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003a0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003a5:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ad:	89 cb                	mov    %ecx,%ebx
  8003af:	89 cf                	mov    %ecx,%edi
  8003b1:	89 ce                	mov    %ecx,%esi
  8003b3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003b5:	85 c0                	test   %eax,%eax
  8003b7:	7e 28                	jle    8003e1 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003b9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003bd:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003c4:	00 
  8003c5:	c7 44 24 08 2f 10 80 	movl   $0x80102f,0x8(%esp)
  8003cc:	00 
  8003cd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003d4:	00 
  8003d5:	c7 04 24 4c 10 80 00 	movl   $0x80104c,(%esp)
  8003dc:	e8 0b 00 00 00       	call   8003ec <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003e1:	83 c4 2c             	add    $0x2c,%esp
  8003e4:	5b                   	pop    %ebx
  8003e5:	5e                   	pop    %esi
  8003e6:	5f                   	pop    %edi
  8003e7:	5d                   	pop    %ebp
  8003e8:	c3                   	ret    
  8003e9:	00 00                	add    %al,(%eax)
	...

008003ec <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003ec:	55                   	push   %ebp
  8003ed:	89 e5                	mov    %esp,%ebp
  8003ef:	56                   	push   %esi
  8003f0:	53                   	push   %ebx
  8003f1:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8003f4:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003f7:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8003fd:	e8 41 fd ff ff       	call   800143 <sys_getenvid>
  800402:	8b 55 0c             	mov    0xc(%ebp),%edx
  800405:	89 54 24 10          	mov    %edx,0x10(%esp)
  800409:	8b 55 08             	mov    0x8(%ebp),%edx
  80040c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800410:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800414:	89 44 24 04          	mov    %eax,0x4(%esp)
  800418:	c7 04 24 5c 10 80 00 	movl   $0x80105c,(%esp)
  80041f:	e8 c0 00 00 00       	call   8004e4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800424:	89 74 24 04          	mov    %esi,0x4(%esp)
  800428:	8b 45 10             	mov    0x10(%ebp),%eax
  80042b:	89 04 24             	mov    %eax,(%esp)
  80042e:	e8 50 00 00 00       	call   800483 <vcprintf>
	cprintf("\n");
  800433:	c7 04 24 7f 10 80 00 	movl   $0x80107f,(%esp)
  80043a:	e8 a5 00 00 00       	call   8004e4 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80043f:	cc                   	int3   
  800440:	eb fd                	jmp    80043f <_panic+0x53>
	...

00800444 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800444:	55                   	push   %ebp
  800445:	89 e5                	mov    %esp,%ebp
  800447:	53                   	push   %ebx
  800448:	83 ec 14             	sub    $0x14,%esp
  80044b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80044e:	8b 03                	mov    (%ebx),%eax
  800450:	8b 55 08             	mov    0x8(%ebp),%edx
  800453:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800457:	40                   	inc    %eax
  800458:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80045a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80045f:	75 19                	jne    80047a <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800461:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800468:	00 
  800469:	8d 43 08             	lea    0x8(%ebx),%eax
  80046c:	89 04 24             	mov    %eax,(%esp)
  80046f:	e8 40 fc ff ff       	call   8000b4 <sys_cputs>
		b->idx = 0;
  800474:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80047a:	ff 43 04             	incl   0x4(%ebx)
}
  80047d:	83 c4 14             	add    $0x14,%esp
  800480:	5b                   	pop    %ebx
  800481:	5d                   	pop    %ebp
  800482:	c3                   	ret    

00800483 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800483:	55                   	push   %ebp
  800484:	89 e5                	mov    %esp,%ebp
  800486:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80048c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800493:	00 00 00 
	b.cnt = 0;
  800496:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80049d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8004aa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004ae:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004b8:	c7 04 24 44 04 80 00 	movl   $0x800444,(%esp)
  8004bf:	e8 82 01 00 00       	call   800646 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004c4:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8004ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ce:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004d4:	89 04 24             	mov    %eax,(%esp)
  8004d7:	e8 d8 fb ff ff       	call   8000b4 <sys_cputs>

	return b.cnt;
}
  8004dc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004e2:	c9                   	leave  
  8004e3:	c3                   	ret    

008004e4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004e4:	55                   	push   %ebp
  8004e5:	89 e5                	mov    %esp,%ebp
  8004e7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004ea:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f4:	89 04 24             	mov    %eax,(%esp)
  8004f7:	e8 87 ff ff ff       	call   800483 <vcprintf>
	va_end(ap);

	return cnt;
}
  8004fc:	c9                   	leave  
  8004fd:	c3                   	ret    
	...

00800500 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800500:	55                   	push   %ebp
  800501:	89 e5                	mov    %esp,%ebp
  800503:	57                   	push   %edi
  800504:	56                   	push   %esi
  800505:	53                   	push   %ebx
  800506:	83 ec 3c             	sub    $0x3c,%esp
  800509:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80050c:	89 d7                	mov    %edx,%edi
  80050e:	8b 45 08             	mov    0x8(%ebp),%eax
  800511:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800514:	8b 45 0c             	mov    0xc(%ebp),%eax
  800517:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80051a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80051d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800520:	85 c0                	test   %eax,%eax
  800522:	75 08                	jne    80052c <printnum+0x2c>
  800524:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800527:	39 45 10             	cmp    %eax,0x10(%ebp)
  80052a:	77 57                	ja     800583 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80052c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800530:	4b                   	dec    %ebx
  800531:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800535:	8b 45 10             	mov    0x10(%ebp),%eax
  800538:	89 44 24 08          	mov    %eax,0x8(%esp)
  80053c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800540:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800544:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80054b:	00 
  80054c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80054f:	89 04 24             	mov    %eax,(%esp)
  800552:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800555:	89 44 24 04          	mov    %eax,0x4(%esp)
  800559:	e8 56 08 00 00       	call   800db4 <__udivdi3>
  80055e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800562:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800566:	89 04 24             	mov    %eax,(%esp)
  800569:	89 54 24 04          	mov    %edx,0x4(%esp)
  80056d:	89 fa                	mov    %edi,%edx
  80056f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800572:	e8 89 ff ff ff       	call   800500 <printnum>
  800577:	eb 0f                	jmp    800588 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800579:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80057d:	89 34 24             	mov    %esi,(%esp)
  800580:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800583:	4b                   	dec    %ebx
  800584:	85 db                	test   %ebx,%ebx
  800586:	7f f1                	jg     800579 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800588:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80058c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800590:	8b 45 10             	mov    0x10(%ebp),%eax
  800593:	89 44 24 08          	mov    %eax,0x8(%esp)
  800597:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80059e:	00 
  80059f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005a2:	89 04 24             	mov    %eax,(%esp)
  8005a5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ac:	e8 23 09 00 00       	call   800ed4 <__umoddi3>
  8005b1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005b5:	0f be 80 81 10 80 00 	movsbl 0x801081(%eax),%eax
  8005bc:	89 04 24             	mov    %eax,(%esp)
  8005bf:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8005c2:	83 c4 3c             	add    $0x3c,%esp
  8005c5:	5b                   	pop    %ebx
  8005c6:	5e                   	pop    %esi
  8005c7:	5f                   	pop    %edi
  8005c8:	5d                   	pop    %ebp
  8005c9:	c3                   	ret    

008005ca <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8005ca:	55                   	push   %ebp
  8005cb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8005cd:	83 fa 01             	cmp    $0x1,%edx
  8005d0:	7e 0e                	jle    8005e0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8005d2:	8b 10                	mov    (%eax),%edx
  8005d4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8005d7:	89 08                	mov    %ecx,(%eax)
  8005d9:	8b 02                	mov    (%edx),%eax
  8005db:	8b 52 04             	mov    0x4(%edx),%edx
  8005de:	eb 22                	jmp    800602 <getuint+0x38>
	else if (lflag)
  8005e0:	85 d2                	test   %edx,%edx
  8005e2:	74 10                	je     8005f4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8005e4:	8b 10                	mov    (%eax),%edx
  8005e6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005e9:	89 08                	mov    %ecx,(%eax)
  8005eb:	8b 02                	mov    (%edx),%eax
  8005ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8005f2:	eb 0e                	jmp    800602 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005f4:	8b 10                	mov    (%eax),%edx
  8005f6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005f9:	89 08                	mov    %ecx,(%eax)
  8005fb:	8b 02                	mov    (%edx),%eax
  8005fd:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800602:	5d                   	pop    %ebp
  800603:	c3                   	ret    

00800604 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800604:	55                   	push   %ebp
  800605:	89 e5                	mov    %esp,%ebp
  800607:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80060a:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80060d:	8b 10                	mov    (%eax),%edx
  80060f:	3b 50 04             	cmp    0x4(%eax),%edx
  800612:	73 08                	jae    80061c <sprintputch+0x18>
		*b->buf++ = ch;
  800614:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800617:	88 0a                	mov    %cl,(%edx)
  800619:	42                   	inc    %edx
  80061a:	89 10                	mov    %edx,(%eax)
}
  80061c:	5d                   	pop    %ebp
  80061d:	c3                   	ret    

0080061e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80061e:	55                   	push   %ebp
  80061f:	89 e5                	mov    %esp,%ebp
  800621:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800624:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800627:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80062b:	8b 45 10             	mov    0x10(%ebp),%eax
  80062e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800632:	8b 45 0c             	mov    0xc(%ebp),%eax
  800635:	89 44 24 04          	mov    %eax,0x4(%esp)
  800639:	8b 45 08             	mov    0x8(%ebp),%eax
  80063c:	89 04 24             	mov    %eax,(%esp)
  80063f:	e8 02 00 00 00       	call   800646 <vprintfmt>
	va_end(ap);
}
  800644:	c9                   	leave  
  800645:	c3                   	ret    

00800646 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800646:	55                   	push   %ebp
  800647:	89 e5                	mov    %esp,%ebp
  800649:	57                   	push   %edi
  80064a:	56                   	push   %esi
  80064b:	53                   	push   %ebx
  80064c:	83 ec 4c             	sub    $0x4c,%esp
  80064f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800652:	8b 75 10             	mov    0x10(%ebp),%esi
  800655:	eb 12                	jmp    800669 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800657:	85 c0                	test   %eax,%eax
  800659:	0f 84 6b 03 00 00    	je     8009ca <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80065f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800663:	89 04 24             	mov    %eax,(%esp)
  800666:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800669:	0f b6 06             	movzbl (%esi),%eax
  80066c:	46                   	inc    %esi
  80066d:	83 f8 25             	cmp    $0x25,%eax
  800670:	75 e5                	jne    800657 <vprintfmt+0x11>
  800672:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800676:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80067d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800682:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800689:	b9 00 00 00 00       	mov    $0x0,%ecx
  80068e:	eb 26                	jmp    8006b6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800690:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800693:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800697:	eb 1d                	jmp    8006b6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800699:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80069c:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8006a0:	eb 14                	jmp    8006b6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8006a5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8006ac:	eb 08                	jmp    8006b6 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8006ae:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8006b1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b6:	0f b6 06             	movzbl (%esi),%eax
  8006b9:	8d 56 01             	lea    0x1(%esi),%edx
  8006bc:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8006bf:	8a 16                	mov    (%esi),%dl
  8006c1:	83 ea 23             	sub    $0x23,%edx
  8006c4:	80 fa 55             	cmp    $0x55,%dl
  8006c7:	0f 87 e1 02 00 00    	ja     8009ae <vprintfmt+0x368>
  8006cd:	0f b6 d2             	movzbl %dl,%edx
  8006d0:	ff 24 95 c0 11 80 00 	jmp    *0x8011c0(,%edx,4)
  8006d7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006da:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8006df:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8006e2:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8006e6:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8006e9:	8d 50 d0             	lea    -0x30(%eax),%edx
  8006ec:	83 fa 09             	cmp    $0x9,%edx
  8006ef:	77 2a                	ja     80071b <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8006f1:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8006f2:	eb eb                	jmp    8006df <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8006f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f7:	8d 50 04             	lea    0x4(%eax),%edx
  8006fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8006fd:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ff:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800702:	eb 17                	jmp    80071b <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800704:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800708:	78 98                	js     8006a2 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80070d:	eb a7                	jmp    8006b6 <vprintfmt+0x70>
  80070f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800712:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800719:	eb 9b                	jmp    8006b6 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80071b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80071f:	79 95                	jns    8006b6 <vprintfmt+0x70>
  800721:	eb 8b                	jmp    8006ae <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800723:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800724:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800727:	eb 8d                	jmp    8006b6 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800729:	8b 45 14             	mov    0x14(%ebp),%eax
  80072c:	8d 50 04             	lea    0x4(%eax),%edx
  80072f:	89 55 14             	mov    %edx,0x14(%ebp)
  800732:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800736:	8b 00                	mov    (%eax),%eax
  800738:	89 04 24             	mov    %eax,(%esp)
  80073b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80073e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800741:	e9 23 ff ff ff       	jmp    800669 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800746:	8b 45 14             	mov    0x14(%ebp),%eax
  800749:	8d 50 04             	lea    0x4(%eax),%edx
  80074c:	89 55 14             	mov    %edx,0x14(%ebp)
  80074f:	8b 00                	mov    (%eax),%eax
  800751:	85 c0                	test   %eax,%eax
  800753:	79 02                	jns    800757 <vprintfmt+0x111>
  800755:	f7 d8                	neg    %eax
  800757:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800759:	83 f8 0f             	cmp    $0xf,%eax
  80075c:	7f 0b                	jg     800769 <vprintfmt+0x123>
  80075e:	8b 04 85 20 13 80 00 	mov    0x801320(,%eax,4),%eax
  800765:	85 c0                	test   %eax,%eax
  800767:	75 23                	jne    80078c <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800769:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80076d:	c7 44 24 08 99 10 80 	movl   $0x801099,0x8(%esp)
  800774:	00 
  800775:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800779:	8b 45 08             	mov    0x8(%ebp),%eax
  80077c:	89 04 24             	mov    %eax,(%esp)
  80077f:	e8 9a fe ff ff       	call   80061e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800784:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800787:	e9 dd fe ff ff       	jmp    800669 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80078c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800790:	c7 44 24 08 a2 10 80 	movl   $0x8010a2,0x8(%esp)
  800797:	00 
  800798:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80079c:	8b 55 08             	mov    0x8(%ebp),%edx
  80079f:	89 14 24             	mov    %edx,(%esp)
  8007a2:	e8 77 fe ff ff       	call   80061e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007aa:	e9 ba fe ff ff       	jmp    800669 <vprintfmt+0x23>
  8007af:	89 f9                	mov    %edi,%ecx
  8007b1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007b4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8007b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ba:	8d 50 04             	lea    0x4(%eax),%edx
  8007bd:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c0:	8b 30                	mov    (%eax),%esi
  8007c2:	85 f6                	test   %esi,%esi
  8007c4:	75 05                	jne    8007cb <vprintfmt+0x185>
				p = "(null)";
  8007c6:	be 92 10 80 00       	mov    $0x801092,%esi
			if (width > 0 && padc != '-')
  8007cb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8007cf:	0f 8e 84 00 00 00    	jle    800859 <vprintfmt+0x213>
  8007d5:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8007d9:	74 7e                	je     800859 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8007db:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007df:	89 34 24             	mov    %esi,(%esp)
  8007e2:	e8 8b 02 00 00       	call   800a72 <strnlen>
  8007e7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007ea:	29 c2                	sub    %eax,%edx
  8007ec:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8007ef:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8007f3:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8007f6:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8007f9:	89 de                	mov    %ebx,%esi
  8007fb:	89 d3                	mov    %edx,%ebx
  8007fd:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007ff:	eb 0b                	jmp    80080c <vprintfmt+0x1c6>
					putch(padc, putdat);
  800801:	89 74 24 04          	mov    %esi,0x4(%esp)
  800805:	89 3c 24             	mov    %edi,(%esp)
  800808:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80080b:	4b                   	dec    %ebx
  80080c:	85 db                	test   %ebx,%ebx
  80080e:	7f f1                	jg     800801 <vprintfmt+0x1bb>
  800810:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800813:	89 f3                	mov    %esi,%ebx
  800815:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800818:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80081b:	85 c0                	test   %eax,%eax
  80081d:	79 05                	jns    800824 <vprintfmt+0x1de>
  80081f:	b8 00 00 00 00       	mov    $0x0,%eax
  800824:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800827:	29 c2                	sub    %eax,%edx
  800829:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80082c:	eb 2b                	jmp    800859 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80082e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800832:	74 18                	je     80084c <vprintfmt+0x206>
  800834:	8d 50 e0             	lea    -0x20(%eax),%edx
  800837:	83 fa 5e             	cmp    $0x5e,%edx
  80083a:	76 10                	jbe    80084c <vprintfmt+0x206>
					putch('?', putdat);
  80083c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800840:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800847:	ff 55 08             	call   *0x8(%ebp)
  80084a:	eb 0a                	jmp    800856 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  80084c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800850:	89 04 24             	mov    %eax,(%esp)
  800853:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800856:	ff 4d e4             	decl   -0x1c(%ebp)
  800859:	0f be 06             	movsbl (%esi),%eax
  80085c:	46                   	inc    %esi
  80085d:	85 c0                	test   %eax,%eax
  80085f:	74 21                	je     800882 <vprintfmt+0x23c>
  800861:	85 ff                	test   %edi,%edi
  800863:	78 c9                	js     80082e <vprintfmt+0x1e8>
  800865:	4f                   	dec    %edi
  800866:	79 c6                	jns    80082e <vprintfmt+0x1e8>
  800868:	8b 7d 08             	mov    0x8(%ebp),%edi
  80086b:	89 de                	mov    %ebx,%esi
  80086d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800870:	eb 18                	jmp    80088a <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800872:	89 74 24 04          	mov    %esi,0x4(%esp)
  800876:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80087d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80087f:	4b                   	dec    %ebx
  800880:	eb 08                	jmp    80088a <vprintfmt+0x244>
  800882:	8b 7d 08             	mov    0x8(%ebp),%edi
  800885:	89 de                	mov    %ebx,%esi
  800887:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80088a:	85 db                	test   %ebx,%ebx
  80088c:	7f e4                	jg     800872 <vprintfmt+0x22c>
  80088e:	89 7d 08             	mov    %edi,0x8(%ebp)
  800891:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800893:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800896:	e9 ce fd ff ff       	jmp    800669 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80089b:	83 f9 01             	cmp    $0x1,%ecx
  80089e:	7e 10                	jle    8008b0 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8008a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a3:	8d 50 08             	lea    0x8(%eax),%edx
  8008a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8008a9:	8b 30                	mov    (%eax),%esi
  8008ab:	8b 78 04             	mov    0x4(%eax),%edi
  8008ae:	eb 26                	jmp    8008d6 <vprintfmt+0x290>
	else if (lflag)
  8008b0:	85 c9                	test   %ecx,%ecx
  8008b2:	74 12                	je     8008c6 <vprintfmt+0x280>
		return va_arg(*ap, long);
  8008b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b7:	8d 50 04             	lea    0x4(%eax),%edx
  8008ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8008bd:	8b 30                	mov    (%eax),%esi
  8008bf:	89 f7                	mov    %esi,%edi
  8008c1:	c1 ff 1f             	sar    $0x1f,%edi
  8008c4:	eb 10                	jmp    8008d6 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8008c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c9:	8d 50 04             	lea    0x4(%eax),%edx
  8008cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8008cf:	8b 30                	mov    (%eax),%esi
  8008d1:	89 f7                	mov    %esi,%edi
  8008d3:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8008d6:	85 ff                	test   %edi,%edi
  8008d8:	78 0a                	js     8008e4 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8008da:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008df:	e9 8c 00 00 00       	jmp    800970 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8008e4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008e8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8008ef:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8008f2:	f7 de                	neg    %esi
  8008f4:	83 d7 00             	adc    $0x0,%edi
  8008f7:	f7 df                	neg    %edi
			}
			base = 10;
  8008f9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008fe:	eb 70                	jmp    800970 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800900:	89 ca                	mov    %ecx,%edx
  800902:	8d 45 14             	lea    0x14(%ebp),%eax
  800905:	e8 c0 fc ff ff       	call   8005ca <getuint>
  80090a:	89 c6                	mov    %eax,%esi
  80090c:	89 d7                	mov    %edx,%edi
			base = 10;
  80090e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800913:	eb 5b                	jmp    800970 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  800915:	89 ca                	mov    %ecx,%edx
  800917:	8d 45 14             	lea    0x14(%ebp),%eax
  80091a:	e8 ab fc ff ff       	call   8005ca <getuint>
  80091f:	89 c6                	mov    %eax,%esi
  800921:	89 d7                	mov    %edx,%edi
			base = 8;
  800923:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800928:	eb 46                	jmp    800970 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  80092a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80092e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800935:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800938:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80093c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800943:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800946:	8b 45 14             	mov    0x14(%ebp),%eax
  800949:	8d 50 04             	lea    0x4(%eax),%edx
  80094c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80094f:	8b 30                	mov    (%eax),%esi
  800951:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800956:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80095b:	eb 13                	jmp    800970 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80095d:	89 ca                	mov    %ecx,%edx
  80095f:	8d 45 14             	lea    0x14(%ebp),%eax
  800962:	e8 63 fc ff ff       	call   8005ca <getuint>
  800967:	89 c6                	mov    %eax,%esi
  800969:	89 d7                	mov    %edx,%edi
			base = 16;
  80096b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800970:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800974:	89 54 24 10          	mov    %edx,0x10(%esp)
  800978:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80097b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80097f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800983:	89 34 24             	mov    %esi,(%esp)
  800986:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80098a:	89 da                	mov    %ebx,%edx
  80098c:	8b 45 08             	mov    0x8(%ebp),%eax
  80098f:	e8 6c fb ff ff       	call   800500 <printnum>
			break;
  800994:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800997:	e9 cd fc ff ff       	jmp    800669 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80099c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009a0:	89 04 24             	mov    %eax,(%esp)
  8009a3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009a6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8009a9:	e9 bb fc ff ff       	jmp    800669 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8009ae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009b2:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8009b9:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009bc:	eb 01                	jmp    8009bf <vprintfmt+0x379>
  8009be:	4e                   	dec    %esi
  8009bf:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8009c3:	75 f9                	jne    8009be <vprintfmt+0x378>
  8009c5:	e9 9f fc ff ff       	jmp    800669 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8009ca:	83 c4 4c             	add    $0x4c,%esp
  8009cd:	5b                   	pop    %ebx
  8009ce:	5e                   	pop    %esi
  8009cf:	5f                   	pop    %edi
  8009d0:	5d                   	pop    %ebp
  8009d1:	c3                   	ret    

008009d2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009d2:	55                   	push   %ebp
  8009d3:	89 e5                	mov    %esp,%ebp
  8009d5:	83 ec 28             	sub    $0x28,%esp
  8009d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009db:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009de:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009e1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009e5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009e8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009ef:	85 c0                	test   %eax,%eax
  8009f1:	74 30                	je     800a23 <vsnprintf+0x51>
  8009f3:	85 d2                	test   %edx,%edx
  8009f5:	7e 33                	jle    800a2a <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8009fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009fe:	8b 45 10             	mov    0x10(%ebp),%eax
  800a01:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a05:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a08:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a0c:	c7 04 24 04 06 80 00 	movl   $0x800604,(%esp)
  800a13:	e8 2e fc ff ff       	call   800646 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a18:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a1b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a21:	eb 0c                	jmp    800a2f <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a23:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a28:	eb 05                	jmp    800a2f <vsnprintf+0x5d>
  800a2a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a2f:	c9                   	leave  
  800a30:	c3                   	ret    

00800a31 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a31:	55                   	push   %ebp
  800a32:	89 e5                	mov    %esp,%ebp
  800a34:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a37:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a3a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a3e:	8b 45 10             	mov    0x10(%ebp),%eax
  800a41:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a45:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a48:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4f:	89 04 24             	mov    %eax,(%esp)
  800a52:	e8 7b ff ff ff       	call   8009d2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a57:	c9                   	leave  
  800a58:	c3                   	ret    
  800a59:	00 00                	add    %al,(%eax)
	...

00800a5c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a5c:	55                   	push   %ebp
  800a5d:	89 e5                	mov    %esp,%ebp
  800a5f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a62:	b8 00 00 00 00       	mov    $0x0,%eax
  800a67:	eb 01                	jmp    800a6a <strlen+0xe>
		n++;
  800a69:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a6a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a6e:	75 f9                	jne    800a69 <strlen+0xd>
		n++;
	return n;
}
  800a70:	5d                   	pop    %ebp
  800a71:	c3                   	ret    

00800a72 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a72:	55                   	push   %ebp
  800a73:	89 e5                	mov    %esp,%ebp
  800a75:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800a78:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a7b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a80:	eb 01                	jmp    800a83 <strnlen+0x11>
		n++;
  800a82:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a83:	39 d0                	cmp    %edx,%eax
  800a85:	74 06                	je     800a8d <strnlen+0x1b>
  800a87:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a8b:	75 f5                	jne    800a82 <strnlen+0x10>
		n++;
	return n;
}
  800a8d:	5d                   	pop    %ebp
  800a8e:	c3                   	ret    

00800a8f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a8f:	55                   	push   %ebp
  800a90:	89 e5                	mov    %esp,%ebp
  800a92:	53                   	push   %ebx
  800a93:	8b 45 08             	mov    0x8(%ebp),%eax
  800a96:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a99:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800aa1:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800aa4:	42                   	inc    %edx
  800aa5:	84 c9                	test   %cl,%cl
  800aa7:	75 f5                	jne    800a9e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800aa9:	5b                   	pop    %ebx
  800aaa:	5d                   	pop    %ebp
  800aab:	c3                   	ret    

00800aac <strcat>:

char *
strcat(char *dst, const char *src)
{
  800aac:	55                   	push   %ebp
  800aad:	89 e5                	mov    %esp,%ebp
  800aaf:	53                   	push   %ebx
  800ab0:	83 ec 08             	sub    $0x8,%esp
  800ab3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ab6:	89 1c 24             	mov    %ebx,(%esp)
  800ab9:	e8 9e ff ff ff       	call   800a5c <strlen>
	strcpy(dst + len, src);
  800abe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ac1:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ac5:	01 d8                	add    %ebx,%eax
  800ac7:	89 04 24             	mov    %eax,(%esp)
  800aca:	e8 c0 ff ff ff       	call   800a8f <strcpy>
	return dst;
}
  800acf:	89 d8                	mov    %ebx,%eax
  800ad1:	83 c4 08             	add    $0x8,%esp
  800ad4:	5b                   	pop    %ebx
  800ad5:	5d                   	pop    %ebp
  800ad6:	c3                   	ret    

00800ad7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ad7:	55                   	push   %ebp
  800ad8:	89 e5                	mov    %esp,%ebp
  800ada:	56                   	push   %esi
  800adb:	53                   	push   %ebx
  800adc:	8b 45 08             	mov    0x8(%ebp),%eax
  800adf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ae2:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ae5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aea:	eb 0c                	jmp    800af8 <strncpy+0x21>
		*dst++ = *src;
  800aec:	8a 1a                	mov    (%edx),%bl
  800aee:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800af1:	80 3a 01             	cmpb   $0x1,(%edx)
  800af4:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800af7:	41                   	inc    %ecx
  800af8:	39 f1                	cmp    %esi,%ecx
  800afa:	75 f0                	jne    800aec <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800afc:	5b                   	pop    %ebx
  800afd:	5e                   	pop    %esi
  800afe:	5d                   	pop    %ebp
  800aff:	c3                   	ret    

00800b00 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b00:	55                   	push   %ebp
  800b01:	89 e5                	mov    %esp,%ebp
  800b03:	56                   	push   %esi
  800b04:	53                   	push   %ebx
  800b05:	8b 75 08             	mov    0x8(%ebp),%esi
  800b08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b0b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b0e:	85 d2                	test   %edx,%edx
  800b10:	75 0a                	jne    800b1c <strlcpy+0x1c>
  800b12:	89 f0                	mov    %esi,%eax
  800b14:	eb 1a                	jmp    800b30 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b16:	88 18                	mov    %bl,(%eax)
  800b18:	40                   	inc    %eax
  800b19:	41                   	inc    %ecx
  800b1a:	eb 02                	jmp    800b1e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b1c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800b1e:	4a                   	dec    %edx
  800b1f:	74 0a                	je     800b2b <strlcpy+0x2b>
  800b21:	8a 19                	mov    (%ecx),%bl
  800b23:	84 db                	test   %bl,%bl
  800b25:	75 ef                	jne    800b16 <strlcpy+0x16>
  800b27:	89 c2                	mov    %eax,%edx
  800b29:	eb 02                	jmp    800b2d <strlcpy+0x2d>
  800b2b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800b2d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800b30:	29 f0                	sub    %esi,%eax
}
  800b32:	5b                   	pop    %ebx
  800b33:	5e                   	pop    %esi
  800b34:	5d                   	pop    %ebp
  800b35:	c3                   	ret    

00800b36 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b36:	55                   	push   %ebp
  800b37:	89 e5                	mov    %esp,%ebp
  800b39:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b3c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b3f:	eb 02                	jmp    800b43 <strcmp+0xd>
		p++, q++;
  800b41:	41                   	inc    %ecx
  800b42:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b43:	8a 01                	mov    (%ecx),%al
  800b45:	84 c0                	test   %al,%al
  800b47:	74 04                	je     800b4d <strcmp+0x17>
  800b49:	3a 02                	cmp    (%edx),%al
  800b4b:	74 f4                	je     800b41 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b4d:	0f b6 c0             	movzbl %al,%eax
  800b50:	0f b6 12             	movzbl (%edx),%edx
  800b53:	29 d0                	sub    %edx,%eax
}
  800b55:	5d                   	pop    %ebp
  800b56:	c3                   	ret    

00800b57 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b57:	55                   	push   %ebp
  800b58:	89 e5                	mov    %esp,%ebp
  800b5a:	53                   	push   %ebx
  800b5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b61:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800b64:	eb 03                	jmp    800b69 <strncmp+0x12>
		n--, p++, q++;
  800b66:	4a                   	dec    %edx
  800b67:	40                   	inc    %eax
  800b68:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b69:	85 d2                	test   %edx,%edx
  800b6b:	74 14                	je     800b81 <strncmp+0x2a>
  800b6d:	8a 18                	mov    (%eax),%bl
  800b6f:	84 db                	test   %bl,%bl
  800b71:	74 04                	je     800b77 <strncmp+0x20>
  800b73:	3a 19                	cmp    (%ecx),%bl
  800b75:	74 ef                	je     800b66 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b77:	0f b6 00             	movzbl (%eax),%eax
  800b7a:	0f b6 11             	movzbl (%ecx),%edx
  800b7d:	29 d0                	sub    %edx,%eax
  800b7f:	eb 05                	jmp    800b86 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b81:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b86:	5b                   	pop    %ebx
  800b87:	5d                   	pop    %ebp
  800b88:	c3                   	ret    

00800b89 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b89:	55                   	push   %ebp
  800b8a:	89 e5                	mov    %esp,%ebp
  800b8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b92:	eb 05                	jmp    800b99 <strchr+0x10>
		if (*s == c)
  800b94:	38 ca                	cmp    %cl,%dl
  800b96:	74 0c                	je     800ba4 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b98:	40                   	inc    %eax
  800b99:	8a 10                	mov    (%eax),%dl
  800b9b:	84 d2                	test   %dl,%dl
  800b9d:	75 f5                	jne    800b94 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800b9f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ba4:	5d                   	pop    %ebp
  800ba5:	c3                   	ret    

00800ba6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bac:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800baf:	eb 05                	jmp    800bb6 <strfind+0x10>
		if (*s == c)
  800bb1:	38 ca                	cmp    %cl,%dl
  800bb3:	74 07                	je     800bbc <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800bb5:	40                   	inc    %eax
  800bb6:	8a 10                	mov    (%eax),%dl
  800bb8:	84 d2                	test   %dl,%dl
  800bba:	75 f5                	jne    800bb1 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800bbc:	5d                   	pop    %ebp
  800bbd:	c3                   	ret    

00800bbe <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bbe:	55                   	push   %ebp
  800bbf:	89 e5                	mov    %esp,%ebp
  800bc1:	57                   	push   %edi
  800bc2:	56                   	push   %esi
  800bc3:	53                   	push   %ebx
  800bc4:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bc7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bca:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bcd:	85 c9                	test   %ecx,%ecx
  800bcf:	74 30                	je     800c01 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bd1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bd7:	75 25                	jne    800bfe <memset+0x40>
  800bd9:	f6 c1 03             	test   $0x3,%cl
  800bdc:	75 20                	jne    800bfe <memset+0x40>
		c &= 0xFF;
  800bde:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800be1:	89 d3                	mov    %edx,%ebx
  800be3:	c1 e3 08             	shl    $0x8,%ebx
  800be6:	89 d6                	mov    %edx,%esi
  800be8:	c1 e6 18             	shl    $0x18,%esi
  800beb:	89 d0                	mov    %edx,%eax
  800bed:	c1 e0 10             	shl    $0x10,%eax
  800bf0:	09 f0                	or     %esi,%eax
  800bf2:	09 d0                	or     %edx,%eax
  800bf4:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bf6:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800bf9:	fc                   	cld    
  800bfa:	f3 ab                	rep stos %eax,%es:(%edi)
  800bfc:	eb 03                	jmp    800c01 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bfe:	fc                   	cld    
  800bff:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c01:	89 f8                	mov    %edi,%eax
  800c03:	5b                   	pop    %ebx
  800c04:	5e                   	pop    %esi
  800c05:	5f                   	pop    %edi
  800c06:	5d                   	pop    %ebp
  800c07:	c3                   	ret    

00800c08 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	57                   	push   %edi
  800c0c:	56                   	push   %esi
  800c0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c10:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c13:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c16:	39 c6                	cmp    %eax,%esi
  800c18:	73 34                	jae    800c4e <memmove+0x46>
  800c1a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c1d:	39 d0                	cmp    %edx,%eax
  800c1f:	73 2d                	jae    800c4e <memmove+0x46>
		s += n;
		d += n;
  800c21:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c24:	f6 c2 03             	test   $0x3,%dl
  800c27:	75 1b                	jne    800c44 <memmove+0x3c>
  800c29:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c2f:	75 13                	jne    800c44 <memmove+0x3c>
  800c31:	f6 c1 03             	test   $0x3,%cl
  800c34:	75 0e                	jne    800c44 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c36:	83 ef 04             	sub    $0x4,%edi
  800c39:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c3c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c3f:	fd                   	std    
  800c40:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c42:	eb 07                	jmp    800c4b <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c44:	4f                   	dec    %edi
  800c45:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c48:	fd                   	std    
  800c49:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c4b:	fc                   	cld    
  800c4c:	eb 20                	jmp    800c6e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c4e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c54:	75 13                	jne    800c69 <memmove+0x61>
  800c56:	a8 03                	test   $0x3,%al
  800c58:	75 0f                	jne    800c69 <memmove+0x61>
  800c5a:	f6 c1 03             	test   $0x3,%cl
  800c5d:	75 0a                	jne    800c69 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c5f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c62:	89 c7                	mov    %eax,%edi
  800c64:	fc                   	cld    
  800c65:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c67:	eb 05                	jmp    800c6e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c69:	89 c7                	mov    %eax,%edi
  800c6b:	fc                   	cld    
  800c6c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c6e:	5e                   	pop    %esi
  800c6f:	5f                   	pop    %edi
  800c70:	5d                   	pop    %ebp
  800c71:	c3                   	ret    

00800c72 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c72:	55                   	push   %ebp
  800c73:	89 e5                	mov    %esp,%ebp
  800c75:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c78:	8b 45 10             	mov    0x10(%ebp),%eax
  800c7b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c82:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c86:	8b 45 08             	mov    0x8(%ebp),%eax
  800c89:	89 04 24             	mov    %eax,(%esp)
  800c8c:	e8 77 ff ff ff       	call   800c08 <memmove>
}
  800c91:	c9                   	leave  
  800c92:	c3                   	ret    

00800c93 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	57                   	push   %edi
  800c97:	56                   	push   %esi
  800c98:	53                   	push   %ebx
  800c99:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c9c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c9f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ca2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca7:	eb 16                	jmp    800cbf <memcmp+0x2c>
		if (*s1 != *s2)
  800ca9:	8a 04 17             	mov    (%edi,%edx,1),%al
  800cac:	42                   	inc    %edx
  800cad:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800cb1:	38 c8                	cmp    %cl,%al
  800cb3:	74 0a                	je     800cbf <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800cb5:	0f b6 c0             	movzbl %al,%eax
  800cb8:	0f b6 c9             	movzbl %cl,%ecx
  800cbb:	29 c8                	sub    %ecx,%eax
  800cbd:	eb 09                	jmp    800cc8 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cbf:	39 da                	cmp    %ebx,%edx
  800cc1:	75 e6                	jne    800ca9 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800cc3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cc8:	5b                   	pop    %ebx
  800cc9:	5e                   	pop    %esi
  800cca:	5f                   	pop    %edi
  800ccb:	5d                   	pop    %ebp
  800ccc:	c3                   	ret    

00800ccd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ccd:	55                   	push   %ebp
  800cce:	89 e5                	mov    %esp,%ebp
  800cd0:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800cd6:	89 c2                	mov    %eax,%edx
  800cd8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cdb:	eb 05                	jmp    800ce2 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cdd:	38 08                	cmp    %cl,(%eax)
  800cdf:	74 05                	je     800ce6 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ce1:	40                   	inc    %eax
  800ce2:	39 d0                	cmp    %edx,%eax
  800ce4:	72 f7                	jb     800cdd <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ce6:	5d                   	pop    %ebp
  800ce7:	c3                   	ret    

00800ce8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ce8:	55                   	push   %ebp
  800ce9:	89 e5                	mov    %esp,%ebp
  800ceb:	57                   	push   %edi
  800cec:	56                   	push   %esi
  800ced:	53                   	push   %ebx
  800cee:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cf4:	eb 01                	jmp    800cf7 <strtol+0xf>
		s++;
  800cf6:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cf7:	8a 02                	mov    (%edx),%al
  800cf9:	3c 20                	cmp    $0x20,%al
  800cfb:	74 f9                	je     800cf6 <strtol+0xe>
  800cfd:	3c 09                	cmp    $0x9,%al
  800cff:	74 f5                	je     800cf6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d01:	3c 2b                	cmp    $0x2b,%al
  800d03:	75 08                	jne    800d0d <strtol+0x25>
		s++;
  800d05:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d06:	bf 00 00 00 00       	mov    $0x0,%edi
  800d0b:	eb 13                	jmp    800d20 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d0d:	3c 2d                	cmp    $0x2d,%al
  800d0f:	75 0a                	jne    800d1b <strtol+0x33>
		s++, neg = 1;
  800d11:	8d 52 01             	lea    0x1(%edx),%edx
  800d14:	bf 01 00 00 00       	mov    $0x1,%edi
  800d19:	eb 05                	jmp    800d20 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d1b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d20:	85 db                	test   %ebx,%ebx
  800d22:	74 05                	je     800d29 <strtol+0x41>
  800d24:	83 fb 10             	cmp    $0x10,%ebx
  800d27:	75 28                	jne    800d51 <strtol+0x69>
  800d29:	8a 02                	mov    (%edx),%al
  800d2b:	3c 30                	cmp    $0x30,%al
  800d2d:	75 10                	jne    800d3f <strtol+0x57>
  800d2f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d33:	75 0a                	jne    800d3f <strtol+0x57>
		s += 2, base = 16;
  800d35:	83 c2 02             	add    $0x2,%edx
  800d38:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d3d:	eb 12                	jmp    800d51 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800d3f:	85 db                	test   %ebx,%ebx
  800d41:	75 0e                	jne    800d51 <strtol+0x69>
  800d43:	3c 30                	cmp    $0x30,%al
  800d45:	75 05                	jne    800d4c <strtol+0x64>
		s++, base = 8;
  800d47:	42                   	inc    %edx
  800d48:	b3 08                	mov    $0x8,%bl
  800d4a:	eb 05                	jmp    800d51 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800d4c:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800d51:	b8 00 00 00 00       	mov    $0x0,%eax
  800d56:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d58:	8a 0a                	mov    (%edx),%cl
  800d5a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d5d:	80 fb 09             	cmp    $0x9,%bl
  800d60:	77 08                	ja     800d6a <strtol+0x82>
			dig = *s - '0';
  800d62:	0f be c9             	movsbl %cl,%ecx
  800d65:	83 e9 30             	sub    $0x30,%ecx
  800d68:	eb 1e                	jmp    800d88 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800d6a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d6d:	80 fb 19             	cmp    $0x19,%bl
  800d70:	77 08                	ja     800d7a <strtol+0x92>
			dig = *s - 'a' + 10;
  800d72:	0f be c9             	movsbl %cl,%ecx
  800d75:	83 e9 57             	sub    $0x57,%ecx
  800d78:	eb 0e                	jmp    800d88 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800d7a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d7d:	80 fb 19             	cmp    $0x19,%bl
  800d80:	77 12                	ja     800d94 <strtol+0xac>
			dig = *s - 'A' + 10;
  800d82:	0f be c9             	movsbl %cl,%ecx
  800d85:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d88:	39 f1                	cmp    %esi,%ecx
  800d8a:	7d 0c                	jge    800d98 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800d8c:	42                   	inc    %edx
  800d8d:	0f af c6             	imul   %esi,%eax
  800d90:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d92:	eb c4                	jmp    800d58 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d94:	89 c1                	mov    %eax,%ecx
  800d96:	eb 02                	jmp    800d9a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d98:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d9a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d9e:	74 05                	je     800da5 <strtol+0xbd>
		*endptr = (char *) s;
  800da0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800da3:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800da5:	85 ff                	test   %edi,%edi
  800da7:	74 04                	je     800dad <strtol+0xc5>
  800da9:	89 c8                	mov    %ecx,%eax
  800dab:	f7 d8                	neg    %eax
}
  800dad:	5b                   	pop    %ebx
  800dae:	5e                   	pop    %esi
  800daf:	5f                   	pop    %edi
  800db0:	5d                   	pop    %ebp
  800db1:	c3                   	ret    
	...

00800db4 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800db4:	55                   	push   %ebp
  800db5:	57                   	push   %edi
  800db6:	56                   	push   %esi
  800db7:	83 ec 10             	sub    $0x10,%esp
  800dba:	8b 74 24 20          	mov    0x20(%esp),%esi
  800dbe:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800dc2:	89 74 24 04          	mov    %esi,0x4(%esp)
  800dc6:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  800dca:	89 cd                	mov    %ecx,%ebp
  800dcc:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800dd0:	85 c0                	test   %eax,%eax
  800dd2:	75 2c                	jne    800e00 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800dd4:	39 f9                	cmp    %edi,%ecx
  800dd6:	77 68                	ja     800e40 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800dd8:	85 c9                	test   %ecx,%ecx
  800dda:	75 0b                	jne    800de7 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800ddc:	b8 01 00 00 00       	mov    $0x1,%eax
  800de1:	31 d2                	xor    %edx,%edx
  800de3:	f7 f1                	div    %ecx
  800de5:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800de7:	31 d2                	xor    %edx,%edx
  800de9:	89 f8                	mov    %edi,%eax
  800deb:	f7 f1                	div    %ecx
  800ded:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800def:	89 f0                	mov    %esi,%eax
  800df1:	f7 f1                	div    %ecx
  800df3:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800df5:	89 f0                	mov    %esi,%eax
  800df7:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800df9:	83 c4 10             	add    $0x10,%esp
  800dfc:	5e                   	pop    %esi
  800dfd:	5f                   	pop    %edi
  800dfe:	5d                   	pop    %ebp
  800dff:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e00:	39 f8                	cmp    %edi,%eax
  800e02:	77 2c                	ja     800e30 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e04:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  800e07:	83 f6 1f             	xor    $0x1f,%esi
  800e0a:	75 4c                	jne    800e58 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e0c:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e0e:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e13:	72 0a                	jb     800e1f <__udivdi3+0x6b>
  800e15:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800e19:	0f 87 ad 00 00 00    	ja     800ecc <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e1f:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e24:	89 f0                	mov    %esi,%eax
  800e26:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e28:	83 c4 10             	add    $0x10,%esp
  800e2b:	5e                   	pop    %esi
  800e2c:	5f                   	pop    %edi
  800e2d:	5d                   	pop    %ebp
  800e2e:	c3                   	ret    
  800e2f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e30:	31 ff                	xor    %edi,%edi
  800e32:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e34:	89 f0                	mov    %esi,%eax
  800e36:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e38:	83 c4 10             	add    $0x10,%esp
  800e3b:	5e                   	pop    %esi
  800e3c:	5f                   	pop    %edi
  800e3d:	5d                   	pop    %ebp
  800e3e:	c3                   	ret    
  800e3f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e40:	89 fa                	mov    %edi,%edx
  800e42:	89 f0                	mov    %esi,%eax
  800e44:	f7 f1                	div    %ecx
  800e46:	89 c6                	mov    %eax,%esi
  800e48:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e4a:	89 f0                	mov    %esi,%eax
  800e4c:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e4e:	83 c4 10             	add    $0x10,%esp
  800e51:	5e                   	pop    %esi
  800e52:	5f                   	pop    %edi
  800e53:	5d                   	pop    %ebp
  800e54:	c3                   	ret    
  800e55:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e58:	89 f1                	mov    %esi,%ecx
  800e5a:	d3 e0                	shl    %cl,%eax
  800e5c:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e60:	b8 20 00 00 00       	mov    $0x20,%eax
  800e65:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800e67:	89 ea                	mov    %ebp,%edx
  800e69:	88 c1                	mov    %al,%cl
  800e6b:	d3 ea                	shr    %cl,%edx
  800e6d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800e71:	09 ca                	or     %ecx,%edx
  800e73:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  800e77:	89 f1                	mov    %esi,%ecx
  800e79:	d3 e5                	shl    %cl,%ebp
  800e7b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  800e7f:	89 fd                	mov    %edi,%ebp
  800e81:	88 c1                	mov    %al,%cl
  800e83:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  800e85:	89 fa                	mov    %edi,%edx
  800e87:	89 f1                	mov    %esi,%ecx
  800e89:	d3 e2                	shl    %cl,%edx
  800e8b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e8f:	88 c1                	mov    %al,%cl
  800e91:	d3 ef                	shr    %cl,%edi
  800e93:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e95:	89 f8                	mov    %edi,%eax
  800e97:	89 ea                	mov    %ebp,%edx
  800e99:	f7 74 24 08          	divl   0x8(%esp)
  800e9d:	89 d1                	mov    %edx,%ecx
  800e9f:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  800ea1:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ea5:	39 d1                	cmp    %edx,%ecx
  800ea7:	72 17                	jb     800ec0 <__udivdi3+0x10c>
  800ea9:	74 09                	je     800eb4 <__udivdi3+0x100>
  800eab:	89 fe                	mov    %edi,%esi
  800ead:	31 ff                	xor    %edi,%edi
  800eaf:	e9 41 ff ff ff       	jmp    800df5 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800eb4:	8b 54 24 04          	mov    0x4(%esp),%edx
  800eb8:	89 f1                	mov    %esi,%ecx
  800eba:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ebc:	39 c2                	cmp    %eax,%edx
  800ebe:	73 eb                	jae    800eab <__udivdi3+0xf7>
		{
		  q0--;
  800ec0:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800ec3:	31 ff                	xor    %edi,%edi
  800ec5:	e9 2b ff ff ff       	jmp    800df5 <__udivdi3+0x41>
  800eca:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ecc:	31 f6                	xor    %esi,%esi
  800ece:	e9 22 ff ff ff       	jmp    800df5 <__udivdi3+0x41>
	...

00800ed4 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800ed4:	55                   	push   %ebp
  800ed5:	57                   	push   %edi
  800ed6:	56                   	push   %esi
  800ed7:	83 ec 20             	sub    $0x20,%esp
  800eda:	8b 44 24 30          	mov    0x30(%esp),%eax
  800ede:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800ee2:	89 44 24 14          	mov    %eax,0x14(%esp)
  800ee6:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  800eea:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800eee:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800ef2:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  800ef4:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800ef6:	85 ed                	test   %ebp,%ebp
  800ef8:	75 16                	jne    800f10 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  800efa:	39 f1                	cmp    %esi,%ecx
  800efc:	0f 86 a6 00 00 00    	jbe    800fa8 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f02:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800f04:	89 d0                	mov    %edx,%eax
  800f06:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f08:	83 c4 20             	add    $0x20,%esp
  800f0b:	5e                   	pop    %esi
  800f0c:	5f                   	pop    %edi
  800f0d:	5d                   	pop    %ebp
  800f0e:	c3                   	ret    
  800f0f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800f10:	39 f5                	cmp    %esi,%ebp
  800f12:	0f 87 ac 00 00 00    	ja     800fc4 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800f18:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  800f1b:	83 f0 1f             	xor    $0x1f,%eax
  800f1e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f22:	0f 84 a8 00 00 00    	je     800fd0 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800f28:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f2c:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800f2e:	bf 20 00 00 00       	mov    $0x20,%edi
  800f33:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800f37:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f3b:	89 f9                	mov    %edi,%ecx
  800f3d:	d3 e8                	shr    %cl,%eax
  800f3f:	09 e8                	or     %ebp,%eax
  800f41:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  800f45:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f49:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f4d:	d3 e0                	shl    %cl,%eax
  800f4f:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800f53:	89 f2                	mov    %esi,%edx
  800f55:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800f57:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f5b:	d3 e0                	shl    %cl,%eax
  800f5d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800f61:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f65:	89 f9                	mov    %edi,%ecx
  800f67:	d3 e8                	shr    %cl,%eax
  800f69:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800f6b:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800f6d:	89 f2                	mov    %esi,%edx
  800f6f:	f7 74 24 18          	divl   0x18(%esp)
  800f73:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800f75:	f7 64 24 0c          	mull   0xc(%esp)
  800f79:	89 c5                	mov    %eax,%ebp
  800f7b:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f7d:	39 d6                	cmp    %edx,%esi
  800f7f:	72 67                	jb     800fe8 <__umoddi3+0x114>
  800f81:	74 75                	je     800ff8 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800f83:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800f87:	29 e8                	sub    %ebp,%eax
  800f89:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f8b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f8f:	d3 e8                	shr    %cl,%eax
  800f91:	89 f2                	mov    %esi,%edx
  800f93:	89 f9                	mov    %edi,%ecx
  800f95:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800f97:	09 d0                	or     %edx,%eax
  800f99:	89 f2                	mov    %esi,%edx
  800f9b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f9f:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800fa1:	83 c4 20             	add    $0x20,%esp
  800fa4:	5e                   	pop    %esi
  800fa5:	5f                   	pop    %edi
  800fa6:	5d                   	pop    %ebp
  800fa7:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800fa8:	85 c9                	test   %ecx,%ecx
  800faa:	75 0b                	jne    800fb7 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800fac:	b8 01 00 00 00       	mov    $0x1,%eax
  800fb1:	31 d2                	xor    %edx,%edx
  800fb3:	f7 f1                	div    %ecx
  800fb5:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800fb7:	89 f0                	mov    %esi,%eax
  800fb9:	31 d2                	xor    %edx,%edx
  800fbb:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800fbd:	89 f8                	mov    %edi,%eax
  800fbf:	e9 3e ff ff ff       	jmp    800f02 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800fc4:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800fc6:	83 c4 20             	add    $0x20,%esp
  800fc9:	5e                   	pop    %esi
  800fca:	5f                   	pop    %edi
  800fcb:	5d                   	pop    %ebp
  800fcc:	c3                   	ret    
  800fcd:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800fd0:	39 f5                	cmp    %esi,%ebp
  800fd2:	72 04                	jb     800fd8 <__umoddi3+0x104>
  800fd4:	39 f9                	cmp    %edi,%ecx
  800fd6:	77 06                	ja     800fde <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800fd8:	89 f2                	mov    %esi,%edx
  800fda:	29 cf                	sub    %ecx,%edi
  800fdc:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800fde:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800fe0:	83 c4 20             	add    $0x20,%esp
  800fe3:	5e                   	pop    %esi
  800fe4:	5f                   	pop    %edi
  800fe5:	5d                   	pop    %ebp
  800fe6:	c3                   	ret    
  800fe7:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800fe8:	89 d1                	mov    %edx,%ecx
  800fea:	89 c5                	mov    %eax,%ebp
  800fec:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800ff0:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800ff4:	eb 8d                	jmp    800f83 <__umoddi3+0xaf>
  800ff6:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ff8:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800ffc:	72 ea                	jb     800fe8 <__umoddi3+0x114>
  800ffe:	89 f1                	mov    %esi,%ecx
  801000:	eb 81                	jmp    800f83 <__umoddi3+0xaf>
