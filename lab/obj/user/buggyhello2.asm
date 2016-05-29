
obj/user/buggyhello2.debug:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_cputs(hello, 1024*1024);
  80003a:	c7 44 24 04 00 00 10 	movl   $0x100000,0x4(%esp)
  800041:	00 
  800042:	a1 00 20 80 00       	mov    0x802000,%eax
  800047:	89 04 24             	mov    %eax,(%esp)
  80004a:	e8 61 00 00 00       	call   8000b0 <sys_cputs>
}
  80004f:	c9                   	leave  
  800050:	c3                   	ret    
  800051:	00 00                	add    %al,(%eax)
	...

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	56                   	push   %esi
  800058:	53                   	push   %ebx
  800059:	83 ec 10             	sub    $0x10,%esp
  80005c:	8b 75 08             	mov    0x8(%ebp),%esi
  80005f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800062:	e8 d8 00 00 00       	call   80013f <sys_getenvid>
  800067:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006c:	c1 e0 07             	shl    $0x7,%eax
  80006f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800074:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800079:	85 f6                	test   %esi,%esi
  80007b:	7e 07                	jle    800084 <libmain+0x30>
		binaryname = argv[0];
  80007d:	8b 03                	mov    (%ebx),%eax
  80007f:	a3 04 20 80 00       	mov    %eax,0x802004

	// call user main routine
	umain(argc, argv);
  800084:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800088:	89 34 24             	mov    %esi,(%esp)
  80008b:	e8 a4 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800090:	e8 07 00 00 00       	call   80009c <exit>
}
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	5b                   	pop    %ebx
  800099:	5e                   	pop    %esi
  80009a:	5d                   	pop    %ebp
  80009b:	c3                   	ret    

0080009c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009c:	55                   	push   %ebp
  80009d:	89 e5                	mov    %esp,%ebp
  80009f:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  8000a2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a9:	e8 3f 00 00 00       	call   8000ed <sys_env_destroy>
}
  8000ae:	c9                   	leave  
  8000af:	c3                   	ret    

008000b0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	57                   	push   %edi
  8000b4:	56                   	push   %esi
  8000b5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8000bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000be:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c1:	89 c3                	mov    %eax,%ebx
  8000c3:	89 c7                	mov    %eax,%edi
  8000c5:	89 c6                	mov    %eax,%esi
  8000c7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c9:	5b                   	pop    %ebx
  8000ca:	5e                   	pop    %esi
  8000cb:	5f                   	pop    %edi
  8000cc:	5d                   	pop    %ebp
  8000cd:	c3                   	ret    

008000ce <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ce:	55                   	push   %ebp
  8000cf:	89 e5                	mov    %esp,%ebp
  8000d1:	57                   	push   %edi
  8000d2:	56                   	push   %esi
  8000d3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d9:	b8 01 00 00 00       	mov    $0x1,%eax
  8000de:	89 d1                	mov    %edx,%ecx
  8000e0:	89 d3                	mov    %edx,%ebx
  8000e2:	89 d7                	mov    %edx,%edi
  8000e4:	89 d6                	mov    %edx,%esi
  8000e6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e8:	5b                   	pop    %ebx
  8000e9:	5e                   	pop    %esi
  8000ea:	5f                   	pop    %edi
  8000eb:	5d                   	pop    %ebp
  8000ec:	c3                   	ret    

008000ed <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000ed:	55                   	push   %ebp
  8000ee:	89 e5                	mov    %esp,%ebp
  8000f0:	57                   	push   %edi
  8000f1:	56                   	push   %esi
  8000f2:	53                   	push   %ebx
  8000f3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000fb:	b8 03 00 00 00       	mov    $0x3,%eax
  800100:	8b 55 08             	mov    0x8(%ebp),%edx
  800103:	89 cb                	mov    %ecx,%ebx
  800105:	89 cf                	mov    %ecx,%edi
  800107:	89 ce                	mov    %ecx,%esi
  800109:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80010b:	85 c0                	test   %eax,%eax
  80010d:	7e 28                	jle    800137 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80010f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800113:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80011a:	00 
  80011b:	c7 44 24 08 98 10 80 	movl   $0x801098,0x8(%esp)
  800122:	00 
  800123:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80012a:	00 
  80012b:	c7 04 24 b5 10 80 00 	movl   $0x8010b5,(%esp)
  800132:	e8 31 03 00 00       	call   800468 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800137:	83 c4 2c             	add    $0x2c,%esp
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5f                   	pop    %edi
  80013d:	5d                   	pop    %ebp
  80013e:	c3                   	ret    

0080013f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	57                   	push   %edi
  800143:	56                   	push   %esi
  800144:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800145:	ba 00 00 00 00       	mov    $0x0,%edx
  80014a:	b8 02 00 00 00       	mov    $0x2,%eax
  80014f:	89 d1                	mov    %edx,%ecx
  800151:	89 d3                	mov    %edx,%ebx
  800153:	89 d7                	mov    %edx,%edi
  800155:	89 d6                	mov    %edx,%esi
  800157:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800159:	5b                   	pop    %ebx
  80015a:	5e                   	pop    %esi
  80015b:	5f                   	pop    %edi
  80015c:	5d                   	pop    %ebp
  80015d:	c3                   	ret    

0080015e <sys_yield>:

void
sys_yield(void)
{
  80015e:	55                   	push   %ebp
  80015f:	89 e5                	mov    %esp,%ebp
  800161:	57                   	push   %edi
  800162:	56                   	push   %esi
  800163:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800164:	ba 00 00 00 00       	mov    $0x0,%edx
  800169:	b8 0b 00 00 00       	mov    $0xb,%eax
  80016e:	89 d1                	mov    %edx,%ecx
  800170:	89 d3                	mov    %edx,%ebx
  800172:	89 d7                	mov    %edx,%edi
  800174:	89 d6                	mov    %edx,%esi
  800176:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800178:	5b                   	pop    %ebx
  800179:	5e                   	pop    %esi
  80017a:	5f                   	pop    %edi
  80017b:	5d                   	pop    %ebp
  80017c:	c3                   	ret    

0080017d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80017d:	55                   	push   %ebp
  80017e:	89 e5                	mov    %esp,%ebp
  800180:	57                   	push   %edi
  800181:	56                   	push   %esi
  800182:	53                   	push   %ebx
  800183:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800186:	be 00 00 00 00       	mov    $0x0,%esi
  80018b:	b8 04 00 00 00       	mov    $0x4,%eax
  800190:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800193:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800196:	8b 55 08             	mov    0x8(%ebp),%edx
  800199:	89 f7                	mov    %esi,%edi
  80019b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80019d:	85 c0                	test   %eax,%eax
  80019f:	7e 28                	jle    8001c9 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001a5:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001ac:	00 
  8001ad:	c7 44 24 08 98 10 80 	movl   $0x801098,0x8(%esp)
  8001b4:	00 
  8001b5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001bc:	00 
  8001bd:	c7 04 24 b5 10 80 00 	movl   $0x8010b5,(%esp)
  8001c4:	e8 9f 02 00 00       	call   800468 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001c9:	83 c4 2c             	add    $0x2c,%esp
  8001cc:	5b                   	pop    %ebx
  8001cd:	5e                   	pop    %esi
  8001ce:	5f                   	pop    %edi
  8001cf:	5d                   	pop    %ebp
  8001d0:	c3                   	ret    

008001d1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001d1:	55                   	push   %ebp
  8001d2:	89 e5                	mov    %esp,%ebp
  8001d4:	57                   	push   %edi
  8001d5:	56                   	push   %esi
  8001d6:	53                   	push   %ebx
  8001d7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001da:	b8 05 00 00 00       	mov    $0x5,%eax
  8001df:	8b 75 18             	mov    0x18(%ebp),%esi
  8001e2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001e5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ee:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001f0:	85 c0                	test   %eax,%eax
  8001f2:	7e 28                	jle    80021c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001f8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8001ff:	00 
  800200:	c7 44 24 08 98 10 80 	movl   $0x801098,0x8(%esp)
  800207:	00 
  800208:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80020f:	00 
  800210:	c7 04 24 b5 10 80 00 	movl   $0x8010b5,(%esp)
  800217:	e8 4c 02 00 00       	call   800468 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80021c:	83 c4 2c             	add    $0x2c,%esp
  80021f:	5b                   	pop    %ebx
  800220:	5e                   	pop    %esi
  800221:	5f                   	pop    %edi
  800222:	5d                   	pop    %ebp
  800223:	c3                   	ret    

00800224 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800224:	55                   	push   %ebp
  800225:	89 e5                	mov    %esp,%ebp
  800227:	57                   	push   %edi
  800228:	56                   	push   %esi
  800229:	53                   	push   %ebx
  80022a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800232:	b8 06 00 00 00       	mov    $0x6,%eax
  800237:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023a:	8b 55 08             	mov    0x8(%ebp),%edx
  80023d:	89 df                	mov    %ebx,%edi
  80023f:	89 de                	mov    %ebx,%esi
  800241:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800243:	85 c0                	test   %eax,%eax
  800245:	7e 28                	jle    80026f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800247:	89 44 24 10          	mov    %eax,0x10(%esp)
  80024b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800252:	00 
  800253:	c7 44 24 08 98 10 80 	movl   $0x801098,0x8(%esp)
  80025a:	00 
  80025b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800262:	00 
  800263:	c7 04 24 b5 10 80 00 	movl   $0x8010b5,(%esp)
  80026a:	e8 f9 01 00 00       	call   800468 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80026f:	83 c4 2c             	add    $0x2c,%esp
  800272:	5b                   	pop    %ebx
  800273:	5e                   	pop    %esi
  800274:	5f                   	pop    %edi
  800275:	5d                   	pop    %ebp
  800276:	c3                   	ret    

00800277 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800277:	55                   	push   %ebp
  800278:	89 e5                	mov    %esp,%ebp
  80027a:	57                   	push   %edi
  80027b:	56                   	push   %esi
  80027c:	53                   	push   %ebx
  80027d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800280:	bb 00 00 00 00       	mov    $0x0,%ebx
  800285:	b8 08 00 00 00       	mov    $0x8,%eax
  80028a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80028d:	8b 55 08             	mov    0x8(%ebp),%edx
  800290:	89 df                	mov    %ebx,%edi
  800292:	89 de                	mov    %ebx,%esi
  800294:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800296:	85 c0                	test   %eax,%eax
  800298:	7e 28                	jle    8002c2 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80029a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80029e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002a5:	00 
  8002a6:	c7 44 24 08 98 10 80 	movl   $0x801098,0x8(%esp)
  8002ad:	00 
  8002ae:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002b5:	00 
  8002b6:	c7 04 24 b5 10 80 00 	movl   $0x8010b5,(%esp)
  8002bd:	e8 a6 01 00 00       	call   800468 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002c2:	83 c4 2c             	add    $0x2c,%esp
  8002c5:	5b                   	pop    %ebx
  8002c6:	5e                   	pop    %esi
  8002c7:	5f                   	pop    %edi
  8002c8:	5d                   	pop    %ebp
  8002c9:	c3                   	ret    

008002ca <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002ca:	55                   	push   %ebp
  8002cb:	89 e5                	mov    %esp,%ebp
  8002cd:	57                   	push   %edi
  8002ce:	56                   	push   %esi
  8002cf:	53                   	push   %ebx
  8002d0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002d8:	b8 09 00 00 00       	mov    $0x9,%eax
  8002dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e3:	89 df                	mov    %ebx,%edi
  8002e5:	89 de                	mov    %ebx,%esi
  8002e7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002e9:	85 c0                	test   %eax,%eax
  8002eb:	7e 28                	jle    800315 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ed:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002f1:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002f8:	00 
  8002f9:	c7 44 24 08 98 10 80 	movl   $0x801098,0x8(%esp)
  800300:	00 
  800301:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800308:	00 
  800309:	c7 04 24 b5 10 80 00 	movl   $0x8010b5,(%esp)
  800310:	e8 53 01 00 00       	call   800468 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800315:	83 c4 2c             	add    $0x2c,%esp
  800318:	5b                   	pop    %ebx
  800319:	5e                   	pop    %esi
  80031a:	5f                   	pop    %edi
  80031b:	5d                   	pop    %ebp
  80031c:	c3                   	ret    

0080031d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80031d:	55                   	push   %ebp
  80031e:	89 e5                	mov    %esp,%ebp
  800320:	57                   	push   %edi
  800321:	56                   	push   %esi
  800322:	53                   	push   %ebx
  800323:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800326:	bb 00 00 00 00       	mov    $0x0,%ebx
  80032b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800330:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800333:	8b 55 08             	mov    0x8(%ebp),%edx
  800336:	89 df                	mov    %ebx,%edi
  800338:	89 de                	mov    %ebx,%esi
  80033a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80033c:	85 c0                	test   %eax,%eax
  80033e:	7e 28                	jle    800368 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800340:	89 44 24 10          	mov    %eax,0x10(%esp)
  800344:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80034b:	00 
  80034c:	c7 44 24 08 98 10 80 	movl   $0x801098,0x8(%esp)
  800353:	00 
  800354:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80035b:	00 
  80035c:	c7 04 24 b5 10 80 00 	movl   $0x8010b5,(%esp)
  800363:	e8 00 01 00 00       	call   800468 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800368:	83 c4 2c             	add    $0x2c,%esp
  80036b:	5b                   	pop    %ebx
  80036c:	5e                   	pop    %esi
  80036d:	5f                   	pop    %edi
  80036e:	5d                   	pop    %ebp
  80036f:	c3                   	ret    

00800370 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800370:	55                   	push   %ebp
  800371:	89 e5                	mov    %esp,%ebp
  800373:	57                   	push   %edi
  800374:	56                   	push   %esi
  800375:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800376:	be 00 00 00 00       	mov    $0x0,%esi
  80037b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800380:	8b 7d 14             	mov    0x14(%ebp),%edi
  800383:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800386:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800389:	8b 55 08             	mov    0x8(%ebp),%edx
  80038c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80038e:	5b                   	pop    %ebx
  80038f:	5e                   	pop    %esi
  800390:	5f                   	pop    %edi
  800391:	5d                   	pop    %ebp
  800392:	c3                   	ret    

00800393 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800393:	55                   	push   %ebp
  800394:	89 e5                	mov    %esp,%ebp
  800396:	57                   	push   %edi
  800397:	56                   	push   %esi
  800398:	53                   	push   %ebx
  800399:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80039c:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003a1:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a9:	89 cb                	mov    %ecx,%ebx
  8003ab:	89 cf                	mov    %ecx,%edi
  8003ad:	89 ce                	mov    %ecx,%esi
  8003af:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003b1:	85 c0                	test   %eax,%eax
  8003b3:	7e 28                	jle    8003dd <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003b5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003b9:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003c0:	00 
  8003c1:	c7 44 24 08 98 10 80 	movl   $0x801098,0x8(%esp)
  8003c8:	00 
  8003c9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003d0:	00 
  8003d1:	c7 04 24 b5 10 80 00 	movl   $0x8010b5,(%esp)
  8003d8:	e8 8b 00 00 00       	call   800468 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003dd:	83 c4 2c             	add    $0x2c,%esp
  8003e0:	5b                   	pop    %ebx
  8003e1:	5e                   	pop    %esi
  8003e2:	5f                   	pop    %edi
  8003e3:	5d                   	pop    %ebp
  8003e4:	c3                   	ret    

008003e5 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8003e5:	55                   	push   %ebp
  8003e6:	89 e5                	mov    %esp,%ebp
  8003e8:	57                   	push   %edi
  8003e9:	56                   	push   %esi
  8003ea:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f0:	b8 0e 00 00 00       	mov    $0xe,%eax
  8003f5:	89 d1                	mov    %edx,%ecx
  8003f7:	89 d3                	mov    %edx,%ebx
  8003f9:	89 d7                	mov    %edx,%edi
  8003fb:	89 d6                	mov    %edx,%esi
  8003fd:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8003ff:	5b                   	pop    %ebx
  800400:	5e                   	pop    %esi
  800401:	5f                   	pop    %edi
  800402:	5d                   	pop    %ebp
  800403:	c3                   	ret    

00800404 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char* pck, size_t length){
  800404:	55                   	push   %ebp
  800405:	89 e5                	mov    %esp,%ebp
  800407:	57                   	push   %edi
  800408:	56                   	push   %esi
  800409:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80040a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80040f:	b8 10 00 00 00       	mov    $0x10,%eax
  800414:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800417:	8b 55 08             	mov    0x8(%ebp),%edx
  80041a:	89 df                	mov    %ebx,%edi
  80041c:	89 de                	mov    %ebx,%esi
  80041e:	cd 30                	int    $0x30
}

int 
sys_e1000_transmit(char* pck, size_t length){
	return syscall(SYS_e1000_transmit, 0, (uint32_t)pck, length, 0, 0, 0);
}
  800420:	5b                   	pop    %ebx
  800421:	5e                   	pop    %esi
  800422:	5f                   	pop    %edi
  800423:	5d                   	pop    %ebp
  800424:	c3                   	ret    

00800425 <sys_e1000_receive>:

int 
sys_e1000_receive(char* pck, size_t* length){
  800425:	55                   	push   %ebp
  800426:	89 e5                	mov    %esp,%ebp
  800428:	57                   	push   %edi
  800429:	56                   	push   %esi
  80042a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80042b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800430:	b8 0f 00 00 00       	mov    $0xf,%eax
  800435:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800438:	8b 55 08             	mov    0x8(%ebp),%edx
  80043b:	89 df                	mov    %ebx,%edi
  80043d:	89 de                	mov    %ebx,%esi
  80043f:	cd 30                	int    $0x30
}

int 
sys_e1000_receive(char* pck, size_t* length){
	return syscall(SYS_e1000_receive, 0, (uint32_t)pck, (uint32_t)length, 0, 0, 0);
}
  800441:	5b                   	pop    %ebx
  800442:	5e                   	pop    %esi
  800443:	5f                   	pop    %edi
  800444:	5d                   	pop    %ebp
  800445:	c3                   	ret    

00800446 <sys_e1000_get_mac>:

int 
sys_e1000_get_mac(uint8_t* mac_addr){
  800446:	55                   	push   %ebp
  800447:	89 e5                	mov    %esp,%ebp
  800449:	57                   	push   %edi
  80044a:	56                   	push   %esi
  80044b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80044c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800451:	b8 11 00 00 00       	mov    $0x11,%eax
  800456:	8b 55 08             	mov    0x8(%ebp),%edx
  800459:	89 cb                	mov    %ecx,%ebx
  80045b:	89 cf                	mov    %ecx,%edi
  80045d:	89 ce                	mov    %ecx,%esi
  80045f:	cd 30                	int    $0x30
}

int 
sys_e1000_get_mac(uint8_t* mac_addr){
	return syscall(SYS_e1000_get_mac, 0, (uint32_t)mac_addr, 0, 0, 0, 0);
}
  800461:	5b                   	pop    %ebx
  800462:	5e                   	pop    %esi
  800463:	5f                   	pop    %edi
  800464:	5d                   	pop    %ebp
  800465:	c3                   	ret    
	...

00800468 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800468:	55                   	push   %ebp
  800469:	89 e5                	mov    %esp,%ebp
  80046b:	56                   	push   %esi
  80046c:	53                   	push   %ebx
  80046d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800470:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800473:	8b 1d 04 20 80 00    	mov    0x802004,%ebx
  800479:	e8 c1 fc ff ff       	call   80013f <sys_getenvid>
  80047e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800481:	89 54 24 10          	mov    %edx,0x10(%esp)
  800485:	8b 55 08             	mov    0x8(%ebp),%edx
  800488:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80048c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800490:	89 44 24 04          	mov    %eax,0x4(%esp)
  800494:	c7 04 24 c4 10 80 00 	movl   $0x8010c4,(%esp)
  80049b:	e8 c0 00 00 00       	call   800560 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8004a0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004a4:	8b 45 10             	mov    0x10(%ebp),%eax
  8004a7:	89 04 24             	mov    %eax,(%esp)
  8004aa:	e8 50 00 00 00       	call   8004ff <vcprintf>
	cprintf("\n");
  8004af:	c7 04 24 8c 10 80 00 	movl   $0x80108c,(%esp)
  8004b6:	e8 a5 00 00 00       	call   800560 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004bb:	cc                   	int3   
  8004bc:	eb fd                	jmp    8004bb <_panic+0x53>
	...

008004c0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004c0:	55                   	push   %ebp
  8004c1:	89 e5                	mov    %esp,%ebp
  8004c3:	53                   	push   %ebx
  8004c4:	83 ec 14             	sub    $0x14,%esp
  8004c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8004ca:	8b 03                	mov    (%ebx),%eax
  8004cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8004cf:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8004d3:	40                   	inc    %eax
  8004d4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8004d6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004db:	75 19                	jne    8004f6 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8004dd:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8004e4:	00 
  8004e5:	8d 43 08             	lea    0x8(%ebx),%eax
  8004e8:	89 04 24             	mov    %eax,(%esp)
  8004eb:	e8 c0 fb ff ff       	call   8000b0 <sys_cputs>
		b->idx = 0;
  8004f0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8004f6:	ff 43 04             	incl   0x4(%ebx)
}
  8004f9:	83 c4 14             	add    $0x14,%esp
  8004fc:	5b                   	pop    %ebx
  8004fd:	5d                   	pop    %ebp
  8004fe:	c3                   	ret    

008004ff <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004ff:	55                   	push   %ebp
  800500:	89 e5                	mov    %esp,%ebp
  800502:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800508:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80050f:	00 00 00 
	b.cnt = 0;
  800512:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800519:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80051c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80051f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800523:	8b 45 08             	mov    0x8(%ebp),%eax
  800526:	89 44 24 08          	mov    %eax,0x8(%esp)
  80052a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800530:	89 44 24 04          	mov    %eax,0x4(%esp)
  800534:	c7 04 24 c0 04 80 00 	movl   $0x8004c0,(%esp)
  80053b:	e8 82 01 00 00       	call   8006c2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800540:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800546:	89 44 24 04          	mov    %eax,0x4(%esp)
  80054a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800550:	89 04 24             	mov    %eax,(%esp)
  800553:	e8 58 fb ff ff       	call   8000b0 <sys_cputs>

	return b.cnt;
}
  800558:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80055e:	c9                   	leave  
  80055f:	c3                   	ret    

00800560 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800560:	55                   	push   %ebp
  800561:	89 e5                	mov    %esp,%ebp
  800563:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800566:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800569:	89 44 24 04          	mov    %eax,0x4(%esp)
  80056d:	8b 45 08             	mov    0x8(%ebp),%eax
  800570:	89 04 24             	mov    %eax,(%esp)
  800573:	e8 87 ff ff ff       	call   8004ff <vcprintf>
	va_end(ap);

	return cnt;
}
  800578:	c9                   	leave  
  800579:	c3                   	ret    
	...

0080057c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80057c:	55                   	push   %ebp
  80057d:	89 e5                	mov    %esp,%ebp
  80057f:	57                   	push   %edi
  800580:	56                   	push   %esi
  800581:	53                   	push   %ebx
  800582:	83 ec 3c             	sub    $0x3c,%esp
  800585:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800588:	89 d7                	mov    %edx,%edi
  80058a:	8b 45 08             	mov    0x8(%ebp),%eax
  80058d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800590:	8b 45 0c             	mov    0xc(%ebp),%eax
  800593:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800596:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800599:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80059c:	85 c0                	test   %eax,%eax
  80059e:	75 08                	jne    8005a8 <printnum+0x2c>
  8005a0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005a3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8005a6:	77 57                	ja     8005ff <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005a8:	89 74 24 10          	mov    %esi,0x10(%esp)
  8005ac:	4b                   	dec    %ebx
  8005ad:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8005b1:	8b 45 10             	mov    0x10(%ebp),%eax
  8005b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005b8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8005bc:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8005c0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005c7:	00 
  8005c8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005cb:	89 04 24             	mov    %eax,(%esp)
  8005ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005d5:	e8 56 08 00 00       	call   800e30 <__udivdi3>
  8005da:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005de:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8005e2:	89 04 24             	mov    %eax,(%esp)
  8005e5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005e9:	89 fa                	mov    %edi,%edx
  8005eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005ee:	e8 89 ff ff ff       	call   80057c <printnum>
  8005f3:	eb 0f                	jmp    800604 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8005f5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005f9:	89 34 24             	mov    %esi,(%esp)
  8005fc:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005ff:	4b                   	dec    %ebx
  800600:	85 db                	test   %ebx,%ebx
  800602:	7f f1                	jg     8005f5 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800604:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800608:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80060c:	8b 45 10             	mov    0x10(%ebp),%eax
  80060f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800613:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80061a:	00 
  80061b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80061e:	89 04 24             	mov    %eax,(%esp)
  800621:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800624:	89 44 24 04          	mov    %eax,0x4(%esp)
  800628:	e8 23 09 00 00       	call   800f50 <__umoddi3>
  80062d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800631:	0f be 80 e7 10 80 00 	movsbl 0x8010e7(%eax),%eax
  800638:	89 04 24             	mov    %eax,(%esp)
  80063b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80063e:	83 c4 3c             	add    $0x3c,%esp
  800641:	5b                   	pop    %ebx
  800642:	5e                   	pop    %esi
  800643:	5f                   	pop    %edi
  800644:	5d                   	pop    %ebp
  800645:	c3                   	ret    

00800646 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800646:	55                   	push   %ebp
  800647:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800649:	83 fa 01             	cmp    $0x1,%edx
  80064c:	7e 0e                	jle    80065c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80064e:	8b 10                	mov    (%eax),%edx
  800650:	8d 4a 08             	lea    0x8(%edx),%ecx
  800653:	89 08                	mov    %ecx,(%eax)
  800655:	8b 02                	mov    (%edx),%eax
  800657:	8b 52 04             	mov    0x4(%edx),%edx
  80065a:	eb 22                	jmp    80067e <getuint+0x38>
	else if (lflag)
  80065c:	85 d2                	test   %edx,%edx
  80065e:	74 10                	je     800670 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800660:	8b 10                	mov    (%eax),%edx
  800662:	8d 4a 04             	lea    0x4(%edx),%ecx
  800665:	89 08                	mov    %ecx,(%eax)
  800667:	8b 02                	mov    (%edx),%eax
  800669:	ba 00 00 00 00       	mov    $0x0,%edx
  80066e:	eb 0e                	jmp    80067e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800670:	8b 10                	mov    (%eax),%edx
  800672:	8d 4a 04             	lea    0x4(%edx),%ecx
  800675:	89 08                	mov    %ecx,(%eax)
  800677:	8b 02                	mov    (%edx),%eax
  800679:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80067e:	5d                   	pop    %ebp
  80067f:	c3                   	ret    

00800680 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800680:	55                   	push   %ebp
  800681:	89 e5                	mov    %esp,%ebp
  800683:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800686:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800689:	8b 10                	mov    (%eax),%edx
  80068b:	3b 50 04             	cmp    0x4(%eax),%edx
  80068e:	73 08                	jae    800698 <sprintputch+0x18>
		*b->buf++ = ch;
  800690:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800693:	88 0a                	mov    %cl,(%edx)
  800695:	42                   	inc    %edx
  800696:	89 10                	mov    %edx,(%eax)
}
  800698:	5d                   	pop    %ebp
  800699:	c3                   	ret    

0080069a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80069a:	55                   	push   %ebp
  80069b:	89 e5                	mov    %esp,%ebp
  80069d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8006a0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006a7:	8b 45 10             	mov    0x10(%ebp),%eax
  8006aa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b8:	89 04 24             	mov    %eax,(%esp)
  8006bb:	e8 02 00 00 00       	call   8006c2 <vprintfmt>
	va_end(ap);
}
  8006c0:	c9                   	leave  
  8006c1:	c3                   	ret    

008006c2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006c2:	55                   	push   %ebp
  8006c3:	89 e5                	mov    %esp,%ebp
  8006c5:	57                   	push   %edi
  8006c6:	56                   	push   %esi
  8006c7:	53                   	push   %ebx
  8006c8:	83 ec 4c             	sub    $0x4c,%esp
  8006cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006ce:	8b 75 10             	mov    0x10(%ebp),%esi
  8006d1:	eb 12                	jmp    8006e5 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006d3:	85 c0                	test   %eax,%eax
  8006d5:	0f 84 6b 03 00 00    	je     800a46 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8006db:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006df:	89 04 24             	mov    %eax,(%esp)
  8006e2:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006e5:	0f b6 06             	movzbl (%esi),%eax
  8006e8:	46                   	inc    %esi
  8006e9:	83 f8 25             	cmp    $0x25,%eax
  8006ec:	75 e5                	jne    8006d3 <vprintfmt+0x11>
  8006ee:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8006f2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8006f9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8006fe:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800705:	b9 00 00 00 00       	mov    $0x0,%ecx
  80070a:	eb 26                	jmp    800732 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80070f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800713:	eb 1d                	jmp    800732 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800715:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800718:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80071c:	eb 14                	jmp    800732 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80071e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800721:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800728:	eb 08                	jmp    800732 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80072a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80072d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800732:	0f b6 06             	movzbl (%esi),%eax
  800735:	8d 56 01             	lea    0x1(%esi),%edx
  800738:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80073b:	8a 16                	mov    (%esi),%dl
  80073d:	83 ea 23             	sub    $0x23,%edx
  800740:	80 fa 55             	cmp    $0x55,%dl
  800743:	0f 87 e1 02 00 00    	ja     800a2a <vprintfmt+0x368>
  800749:	0f b6 d2             	movzbl %dl,%edx
  80074c:	ff 24 95 20 12 80 00 	jmp    *0x801220(,%edx,4)
  800753:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800756:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80075b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80075e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800762:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800765:	8d 50 d0             	lea    -0x30(%eax),%edx
  800768:	83 fa 09             	cmp    $0x9,%edx
  80076b:	77 2a                	ja     800797 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80076d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80076e:	eb eb                	jmp    80075b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800770:	8b 45 14             	mov    0x14(%ebp),%eax
  800773:	8d 50 04             	lea    0x4(%eax),%edx
  800776:	89 55 14             	mov    %edx,0x14(%ebp)
  800779:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80077b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80077e:	eb 17                	jmp    800797 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800780:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800784:	78 98                	js     80071e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800786:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800789:	eb a7                	jmp    800732 <vprintfmt+0x70>
  80078b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80078e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800795:	eb 9b                	jmp    800732 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800797:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80079b:	79 95                	jns    800732 <vprintfmt+0x70>
  80079d:	eb 8b                	jmp    80072a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80079f:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8007a3:	eb 8d                	jmp    800732 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a8:	8d 50 04             	lea    0x4(%eax),%edx
  8007ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007b2:	8b 00                	mov    (%eax),%eax
  8007b4:	89 04 24             	mov    %eax,(%esp)
  8007b7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ba:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8007bd:	e9 23 ff ff ff       	jmp    8006e5 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8007c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c5:	8d 50 04             	lea    0x4(%eax),%edx
  8007c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8007cb:	8b 00                	mov    (%eax),%eax
  8007cd:	85 c0                	test   %eax,%eax
  8007cf:	79 02                	jns    8007d3 <vprintfmt+0x111>
  8007d1:	f7 d8                	neg    %eax
  8007d3:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8007d5:	83 f8 11             	cmp    $0x11,%eax
  8007d8:	7f 0b                	jg     8007e5 <vprintfmt+0x123>
  8007da:	8b 04 85 80 13 80 00 	mov    0x801380(,%eax,4),%eax
  8007e1:	85 c0                	test   %eax,%eax
  8007e3:	75 23                	jne    800808 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8007e5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007e9:	c7 44 24 08 ff 10 80 	movl   $0x8010ff,0x8(%esp)
  8007f0:	00 
  8007f1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f8:	89 04 24             	mov    %eax,(%esp)
  8007fb:	e8 9a fe ff ff       	call   80069a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800800:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800803:	e9 dd fe ff ff       	jmp    8006e5 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800808:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80080c:	c7 44 24 08 08 11 80 	movl   $0x801108,0x8(%esp)
  800813:	00 
  800814:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800818:	8b 55 08             	mov    0x8(%ebp),%edx
  80081b:	89 14 24             	mov    %edx,(%esp)
  80081e:	e8 77 fe ff ff       	call   80069a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800823:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800826:	e9 ba fe ff ff       	jmp    8006e5 <vprintfmt+0x23>
  80082b:	89 f9                	mov    %edi,%ecx
  80082d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800830:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800833:	8b 45 14             	mov    0x14(%ebp),%eax
  800836:	8d 50 04             	lea    0x4(%eax),%edx
  800839:	89 55 14             	mov    %edx,0x14(%ebp)
  80083c:	8b 30                	mov    (%eax),%esi
  80083e:	85 f6                	test   %esi,%esi
  800840:	75 05                	jne    800847 <vprintfmt+0x185>
				p = "(null)";
  800842:	be f8 10 80 00       	mov    $0x8010f8,%esi
			if (width > 0 && padc != '-')
  800847:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80084b:	0f 8e 84 00 00 00    	jle    8008d5 <vprintfmt+0x213>
  800851:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800855:	74 7e                	je     8008d5 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800857:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80085b:	89 34 24             	mov    %esi,(%esp)
  80085e:	e8 8b 02 00 00       	call   800aee <strnlen>
  800863:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800866:	29 c2                	sub    %eax,%edx
  800868:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80086b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80086f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800872:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800875:	89 de                	mov    %ebx,%esi
  800877:	89 d3                	mov    %edx,%ebx
  800879:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80087b:	eb 0b                	jmp    800888 <vprintfmt+0x1c6>
					putch(padc, putdat);
  80087d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800881:	89 3c 24             	mov    %edi,(%esp)
  800884:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800887:	4b                   	dec    %ebx
  800888:	85 db                	test   %ebx,%ebx
  80088a:	7f f1                	jg     80087d <vprintfmt+0x1bb>
  80088c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80088f:	89 f3                	mov    %esi,%ebx
  800891:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800894:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800897:	85 c0                	test   %eax,%eax
  800899:	79 05                	jns    8008a0 <vprintfmt+0x1de>
  80089b:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008a3:	29 c2                	sub    %eax,%edx
  8008a5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8008a8:	eb 2b                	jmp    8008d5 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008aa:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8008ae:	74 18                	je     8008c8 <vprintfmt+0x206>
  8008b0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8008b3:	83 fa 5e             	cmp    $0x5e,%edx
  8008b6:	76 10                	jbe    8008c8 <vprintfmt+0x206>
					putch('?', putdat);
  8008b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008bc:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8008c3:	ff 55 08             	call   *0x8(%ebp)
  8008c6:	eb 0a                	jmp    8008d2 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8008c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008cc:	89 04 24             	mov    %eax,(%esp)
  8008cf:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008d2:	ff 4d e4             	decl   -0x1c(%ebp)
  8008d5:	0f be 06             	movsbl (%esi),%eax
  8008d8:	46                   	inc    %esi
  8008d9:	85 c0                	test   %eax,%eax
  8008db:	74 21                	je     8008fe <vprintfmt+0x23c>
  8008dd:	85 ff                	test   %edi,%edi
  8008df:	78 c9                	js     8008aa <vprintfmt+0x1e8>
  8008e1:	4f                   	dec    %edi
  8008e2:	79 c6                	jns    8008aa <vprintfmt+0x1e8>
  8008e4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e7:	89 de                	mov    %ebx,%esi
  8008e9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8008ec:	eb 18                	jmp    800906 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8008ee:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008f2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8008f9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8008fb:	4b                   	dec    %ebx
  8008fc:	eb 08                	jmp    800906 <vprintfmt+0x244>
  8008fe:	8b 7d 08             	mov    0x8(%ebp),%edi
  800901:	89 de                	mov    %ebx,%esi
  800903:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800906:	85 db                	test   %ebx,%ebx
  800908:	7f e4                	jg     8008ee <vprintfmt+0x22c>
  80090a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80090d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80090f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800912:	e9 ce fd ff ff       	jmp    8006e5 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800917:	83 f9 01             	cmp    $0x1,%ecx
  80091a:	7e 10                	jle    80092c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80091c:	8b 45 14             	mov    0x14(%ebp),%eax
  80091f:	8d 50 08             	lea    0x8(%eax),%edx
  800922:	89 55 14             	mov    %edx,0x14(%ebp)
  800925:	8b 30                	mov    (%eax),%esi
  800927:	8b 78 04             	mov    0x4(%eax),%edi
  80092a:	eb 26                	jmp    800952 <vprintfmt+0x290>
	else if (lflag)
  80092c:	85 c9                	test   %ecx,%ecx
  80092e:	74 12                	je     800942 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800930:	8b 45 14             	mov    0x14(%ebp),%eax
  800933:	8d 50 04             	lea    0x4(%eax),%edx
  800936:	89 55 14             	mov    %edx,0x14(%ebp)
  800939:	8b 30                	mov    (%eax),%esi
  80093b:	89 f7                	mov    %esi,%edi
  80093d:	c1 ff 1f             	sar    $0x1f,%edi
  800940:	eb 10                	jmp    800952 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800942:	8b 45 14             	mov    0x14(%ebp),%eax
  800945:	8d 50 04             	lea    0x4(%eax),%edx
  800948:	89 55 14             	mov    %edx,0x14(%ebp)
  80094b:	8b 30                	mov    (%eax),%esi
  80094d:	89 f7                	mov    %esi,%edi
  80094f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800952:	85 ff                	test   %edi,%edi
  800954:	78 0a                	js     800960 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800956:	b8 0a 00 00 00       	mov    $0xa,%eax
  80095b:	e9 8c 00 00 00       	jmp    8009ec <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800960:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800964:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80096b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80096e:	f7 de                	neg    %esi
  800970:	83 d7 00             	adc    $0x0,%edi
  800973:	f7 df                	neg    %edi
			}
			base = 10;
  800975:	b8 0a 00 00 00       	mov    $0xa,%eax
  80097a:	eb 70                	jmp    8009ec <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80097c:	89 ca                	mov    %ecx,%edx
  80097e:	8d 45 14             	lea    0x14(%ebp),%eax
  800981:	e8 c0 fc ff ff       	call   800646 <getuint>
  800986:	89 c6                	mov    %eax,%esi
  800988:	89 d7                	mov    %edx,%edi
			base = 10;
  80098a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80098f:	eb 5b                	jmp    8009ec <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  800991:	89 ca                	mov    %ecx,%edx
  800993:	8d 45 14             	lea    0x14(%ebp),%eax
  800996:	e8 ab fc ff ff       	call   800646 <getuint>
  80099b:	89 c6                	mov    %eax,%esi
  80099d:	89 d7                	mov    %edx,%edi
			base = 8;
  80099f:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8009a4:	eb 46                	jmp    8009ec <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  8009a6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009aa:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8009b1:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8009b4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009b8:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8009bf:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8009c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8009c5:	8d 50 04             	lea    0x4(%eax),%edx
  8009c8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8009cb:	8b 30                	mov    (%eax),%esi
  8009cd:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8009d2:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8009d7:	eb 13                	jmp    8009ec <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8009d9:	89 ca                	mov    %ecx,%edx
  8009db:	8d 45 14             	lea    0x14(%ebp),%eax
  8009de:	e8 63 fc ff ff       	call   800646 <getuint>
  8009e3:	89 c6                	mov    %eax,%esi
  8009e5:	89 d7                	mov    %edx,%edi
			base = 16;
  8009e7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8009ec:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8009f0:	89 54 24 10          	mov    %edx,0x10(%esp)
  8009f4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8009f7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8009fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009ff:	89 34 24             	mov    %esi,(%esp)
  800a02:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a06:	89 da                	mov    %ebx,%edx
  800a08:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0b:	e8 6c fb ff ff       	call   80057c <printnum>
			break;
  800a10:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800a13:	e9 cd fc ff ff       	jmp    8006e5 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a18:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a1c:	89 04 24             	mov    %eax,(%esp)
  800a1f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a22:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a25:	e9 bb fc ff ff       	jmp    8006e5 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a2a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a2e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a35:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a38:	eb 01                	jmp    800a3b <vprintfmt+0x379>
  800a3a:	4e                   	dec    %esi
  800a3b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800a3f:	75 f9                	jne    800a3a <vprintfmt+0x378>
  800a41:	e9 9f fc ff ff       	jmp    8006e5 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800a46:	83 c4 4c             	add    $0x4c,%esp
  800a49:	5b                   	pop    %ebx
  800a4a:	5e                   	pop    %esi
  800a4b:	5f                   	pop    %edi
  800a4c:	5d                   	pop    %ebp
  800a4d:	c3                   	ret    

00800a4e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a4e:	55                   	push   %ebp
  800a4f:	89 e5                	mov    %esp,%ebp
  800a51:	83 ec 28             	sub    $0x28,%esp
  800a54:	8b 45 08             	mov    0x8(%ebp),%eax
  800a57:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a5a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a5d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a61:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a64:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a6b:	85 c0                	test   %eax,%eax
  800a6d:	74 30                	je     800a9f <vsnprintf+0x51>
  800a6f:	85 d2                	test   %edx,%edx
  800a71:	7e 33                	jle    800aa6 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a73:	8b 45 14             	mov    0x14(%ebp),%eax
  800a76:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a7a:	8b 45 10             	mov    0x10(%ebp),%eax
  800a7d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a81:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a84:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a88:	c7 04 24 80 06 80 00 	movl   $0x800680,(%esp)
  800a8f:	e8 2e fc ff ff       	call   8006c2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a94:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a97:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a9d:	eb 0c                	jmp    800aab <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a9f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800aa4:	eb 05                	jmp    800aab <vsnprintf+0x5d>
  800aa6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800aab:	c9                   	leave  
  800aac:	c3                   	ret    

00800aad <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800aad:	55                   	push   %ebp
  800aae:	89 e5                	mov    %esp,%ebp
  800ab0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800ab3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800ab6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800aba:	8b 45 10             	mov    0x10(%ebp),%eax
  800abd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ac1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ac8:	8b 45 08             	mov    0x8(%ebp),%eax
  800acb:	89 04 24             	mov    %eax,(%esp)
  800ace:	e8 7b ff ff ff       	call   800a4e <vsnprintf>
	va_end(ap);

	return rc;
}
  800ad3:	c9                   	leave  
  800ad4:	c3                   	ret    
  800ad5:	00 00                	add    %al,(%eax)
	...

00800ad8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ade:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae3:	eb 01                	jmp    800ae6 <strlen+0xe>
		n++;
  800ae5:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800ae6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800aea:	75 f9                	jne    800ae5 <strlen+0xd>
		n++;
	return n;
}
  800aec:	5d                   	pop    %ebp
  800aed:	c3                   	ret    

00800aee <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800af4:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800af7:	b8 00 00 00 00       	mov    $0x0,%eax
  800afc:	eb 01                	jmp    800aff <strnlen+0x11>
		n++;
  800afe:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800aff:	39 d0                	cmp    %edx,%eax
  800b01:	74 06                	je     800b09 <strnlen+0x1b>
  800b03:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800b07:	75 f5                	jne    800afe <strnlen+0x10>
		n++;
	return n;
}
  800b09:	5d                   	pop    %ebp
  800b0a:	c3                   	ret    

00800b0b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b0b:	55                   	push   %ebp
  800b0c:	89 e5                	mov    %esp,%ebp
  800b0e:	53                   	push   %ebx
  800b0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b12:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b15:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800b1d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800b20:	42                   	inc    %edx
  800b21:	84 c9                	test   %cl,%cl
  800b23:	75 f5                	jne    800b1a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800b25:	5b                   	pop    %ebx
  800b26:	5d                   	pop    %ebp
  800b27:	c3                   	ret    

00800b28 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b28:	55                   	push   %ebp
  800b29:	89 e5                	mov    %esp,%ebp
  800b2b:	53                   	push   %ebx
  800b2c:	83 ec 08             	sub    $0x8,%esp
  800b2f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b32:	89 1c 24             	mov    %ebx,(%esp)
  800b35:	e8 9e ff ff ff       	call   800ad8 <strlen>
	strcpy(dst + len, src);
  800b3a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b3d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b41:	01 d8                	add    %ebx,%eax
  800b43:	89 04 24             	mov    %eax,(%esp)
  800b46:	e8 c0 ff ff ff       	call   800b0b <strcpy>
	return dst;
}
  800b4b:	89 d8                	mov    %ebx,%eax
  800b4d:	83 c4 08             	add    $0x8,%esp
  800b50:	5b                   	pop    %ebx
  800b51:	5d                   	pop    %ebp
  800b52:	c3                   	ret    

00800b53 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b53:	55                   	push   %ebp
  800b54:	89 e5                	mov    %esp,%ebp
  800b56:	56                   	push   %esi
  800b57:	53                   	push   %ebx
  800b58:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b5e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b61:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b66:	eb 0c                	jmp    800b74 <strncpy+0x21>
		*dst++ = *src;
  800b68:	8a 1a                	mov    (%edx),%bl
  800b6a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b6d:	80 3a 01             	cmpb   $0x1,(%edx)
  800b70:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b73:	41                   	inc    %ecx
  800b74:	39 f1                	cmp    %esi,%ecx
  800b76:	75 f0                	jne    800b68 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b78:	5b                   	pop    %ebx
  800b79:	5e                   	pop    %esi
  800b7a:	5d                   	pop    %ebp
  800b7b:	c3                   	ret    

00800b7c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	56                   	push   %esi
  800b80:	53                   	push   %ebx
  800b81:	8b 75 08             	mov    0x8(%ebp),%esi
  800b84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b87:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b8a:	85 d2                	test   %edx,%edx
  800b8c:	75 0a                	jne    800b98 <strlcpy+0x1c>
  800b8e:	89 f0                	mov    %esi,%eax
  800b90:	eb 1a                	jmp    800bac <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b92:	88 18                	mov    %bl,(%eax)
  800b94:	40                   	inc    %eax
  800b95:	41                   	inc    %ecx
  800b96:	eb 02                	jmp    800b9a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b98:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800b9a:	4a                   	dec    %edx
  800b9b:	74 0a                	je     800ba7 <strlcpy+0x2b>
  800b9d:	8a 19                	mov    (%ecx),%bl
  800b9f:	84 db                	test   %bl,%bl
  800ba1:	75 ef                	jne    800b92 <strlcpy+0x16>
  800ba3:	89 c2                	mov    %eax,%edx
  800ba5:	eb 02                	jmp    800ba9 <strlcpy+0x2d>
  800ba7:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800ba9:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800bac:	29 f0                	sub    %esi,%eax
}
  800bae:	5b                   	pop    %ebx
  800baf:	5e                   	pop    %esi
  800bb0:	5d                   	pop    %ebp
  800bb1:	c3                   	ret    

00800bb2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bb2:	55                   	push   %ebp
  800bb3:	89 e5                	mov    %esp,%ebp
  800bb5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bb8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bbb:	eb 02                	jmp    800bbf <strcmp+0xd>
		p++, q++;
  800bbd:	41                   	inc    %ecx
  800bbe:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800bbf:	8a 01                	mov    (%ecx),%al
  800bc1:	84 c0                	test   %al,%al
  800bc3:	74 04                	je     800bc9 <strcmp+0x17>
  800bc5:	3a 02                	cmp    (%edx),%al
  800bc7:	74 f4                	je     800bbd <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800bc9:	0f b6 c0             	movzbl %al,%eax
  800bcc:	0f b6 12             	movzbl (%edx),%edx
  800bcf:	29 d0                	sub    %edx,%eax
}
  800bd1:	5d                   	pop    %ebp
  800bd2:	c3                   	ret    

00800bd3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800bd3:	55                   	push   %ebp
  800bd4:	89 e5                	mov    %esp,%ebp
  800bd6:	53                   	push   %ebx
  800bd7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bdd:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800be0:	eb 03                	jmp    800be5 <strncmp+0x12>
		n--, p++, q++;
  800be2:	4a                   	dec    %edx
  800be3:	40                   	inc    %eax
  800be4:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800be5:	85 d2                	test   %edx,%edx
  800be7:	74 14                	je     800bfd <strncmp+0x2a>
  800be9:	8a 18                	mov    (%eax),%bl
  800beb:	84 db                	test   %bl,%bl
  800bed:	74 04                	je     800bf3 <strncmp+0x20>
  800bef:	3a 19                	cmp    (%ecx),%bl
  800bf1:	74 ef                	je     800be2 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800bf3:	0f b6 00             	movzbl (%eax),%eax
  800bf6:	0f b6 11             	movzbl (%ecx),%edx
  800bf9:	29 d0                	sub    %edx,%eax
  800bfb:	eb 05                	jmp    800c02 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800bfd:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c02:	5b                   	pop    %ebx
  800c03:	5d                   	pop    %ebp
  800c04:	c3                   	ret    

00800c05 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800c0e:	eb 05                	jmp    800c15 <strchr+0x10>
		if (*s == c)
  800c10:	38 ca                	cmp    %cl,%dl
  800c12:	74 0c                	je     800c20 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c14:	40                   	inc    %eax
  800c15:	8a 10                	mov    (%eax),%dl
  800c17:	84 d2                	test   %dl,%dl
  800c19:	75 f5                	jne    800c10 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800c1b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c20:	5d                   	pop    %ebp
  800c21:	c3                   	ret    

00800c22 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c22:	55                   	push   %ebp
  800c23:	89 e5                	mov    %esp,%ebp
  800c25:	8b 45 08             	mov    0x8(%ebp),%eax
  800c28:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800c2b:	eb 05                	jmp    800c32 <strfind+0x10>
		if (*s == c)
  800c2d:	38 ca                	cmp    %cl,%dl
  800c2f:	74 07                	je     800c38 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c31:	40                   	inc    %eax
  800c32:	8a 10                	mov    (%eax),%dl
  800c34:	84 d2                	test   %dl,%dl
  800c36:	75 f5                	jne    800c2d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800c38:	5d                   	pop    %ebp
  800c39:	c3                   	ret    

00800c3a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c3a:	55                   	push   %ebp
  800c3b:	89 e5                	mov    %esp,%ebp
  800c3d:	57                   	push   %edi
  800c3e:	56                   	push   %esi
  800c3f:	53                   	push   %ebx
  800c40:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c43:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c46:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c49:	85 c9                	test   %ecx,%ecx
  800c4b:	74 30                	je     800c7d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c4d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c53:	75 25                	jne    800c7a <memset+0x40>
  800c55:	f6 c1 03             	test   $0x3,%cl
  800c58:	75 20                	jne    800c7a <memset+0x40>
		c &= 0xFF;
  800c5a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c5d:	89 d3                	mov    %edx,%ebx
  800c5f:	c1 e3 08             	shl    $0x8,%ebx
  800c62:	89 d6                	mov    %edx,%esi
  800c64:	c1 e6 18             	shl    $0x18,%esi
  800c67:	89 d0                	mov    %edx,%eax
  800c69:	c1 e0 10             	shl    $0x10,%eax
  800c6c:	09 f0                	or     %esi,%eax
  800c6e:	09 d0                	or     %edx,%eax
  800c70:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c72:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800c75:	fc                   	cld    
  800c76:	f3 ab                	rep stos %eax,%es:(%edi)
  800c78:	eb 03                	jmp    800c7d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c7a:	fc                   	cld    
  800c7b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c7d:	89 f8                	mov    %edi,%eax
  800c7f:	5b                   	pop    %ebx
  800c80:	5e                   	pop    %esi
  800c81:	5f                   	pop    %edi
  800c82:	5d                   	pop    %ebp
  800c83:	c3                   	ret    

00800c84 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	57                   	push   %edi
  800c88:	56                   	push   %esi
  800c89:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c8f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c92:	39 c6                	cmp    %eax,%esi
  800c94:	73 34                	jae    800cca <memmove+0x46>
  800c96:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c99:	39 d0                	cmp    %edx,%eax
  800c9b:	73 2d                	jae    800cca <memmove+0x46>
		s += n;
		d += n;
  800c9d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ca0:	f6 c2 03             	test   $0x3,%dl
  800ca3:	75 1b                	jne    800cc0 <memmove+0x3c>
  800ca5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800cab:	75 13                	jne    800cc0 <memmove+0x3c>
  800cad:	f6 c1 03             	test   $0x3,%cl
  800cb0:	75 0e                	jne    800cc0 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800cb2:	83 ef 04             	sub    $0x4,%edi
  800cb5:	8d 72 fc             	lea    -0x4(%edx),%esi
  800cb8:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800cbb:	fd                   	std    
  800cbc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cbe:	eb 07                	jmp    800cc7 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800cc0:	4f                   	dec    %edi
  800cc1:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800cc4:	fd                   	std    
  800cc5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800cc7:	fc                   	cld    
  800cc8:	eb 20                	jmp    800cea <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cca:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cd0:	75 13                	jne    800ce5 <memmove+0x61>
  800cd2:	a8 03                	test   $0x3,%al
  800cd4:	75 0f                	jne    800ce5 <memmove+0x61>
  800cd6:	f6 c1 03             	test   $0x3,%cl
  800cd9:	75 0a                	jne    800ce5 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800cdb:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800cde:	89 c7                	mov    %eax,%edi
  800ce0:	fc                   	cld    
  800ce1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ce3:	eb 05                	jmp    800cea <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ce5:	89 c7                	mov    %eax,%edi
  800ce7:	fc                   	cld    
  800ce8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800cea:	5e                   	pop    %esi
  800ceb:	5f                   	pop    %edi
  800cec:	5d                   	pop    %ebp
  800ced:	c3                   	ret    

00800cee <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800cee:	55                   	push   %ebp
  800cef:	89 e5                	mov    %esp,%ebp
  800cf1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800cf4:	8b 45 10             	mov    0x10(%ebp),%eax
  800cf7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cfb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cfe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d02:	8b 45 08             	mov    0x8(%ebp),%eax
  800d05:	89 04 24             	mov    %eax,(%esp)
  800d08:	e8 77 ff ff ff       	call   800c84 <memmove>
}
  800d0d:	c9                   	leave  
  800d0e:	c3                   	ret    

00800d0f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d0f:	55                   	push   %ebp
  800d10:	89 e5                	mov    %esp,%ebp
  800d12:	57                   	push   %edi
  800d13:	56                   	push   %esi
  800d14:	53                   	push   %ebx
  800d15:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d18:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d1e:	ba 00 00 00 00       	mov    $0x0,%edx
  800d23:	eb 16                	jmp    800d3b <memcmp+0x2c>
		if (*s1 != *s2)
  800d25:	8a 04 17             	mov    (%edi,%edx,1),%al
  800d28:	42                   	inc    %edx
  800d29:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800d2d:	38 c8                	cmp    %cl,%al
  800d2f:	74 0a                	je     800d3b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800d31:	0f b6 c0             	movzbl %al,%eax
  800d34:	0f b6 c9             	movzbl %cl,%ecx
  800d37:	29 c8                	sub    %ecx,%eax
  800d39:	eb 09                	jmp    800d44 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d3b:	39 da                	cmp    %ebx,%edx
  800d3d:	75 e6                	jne    800d25 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d3f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d44:	5b                   	pop    %ebx
  800d45:	5e                   	pop    %esi
  800d46:	5f                   	pop    %edi
  800d47:	5d                   	pop    %ebp
  800d48:	c3                   	ret    

00800d49 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d49:	55                   	push   %ebp
  800d4a:	89 e5                	mov    %esp,%ebp
  800d4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800d52:	89 c2                	mov    %eax,%edx
  800d54:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d57:	eb 05                	jmp    800d5e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d59:	38 08                	cmp    %cl,(%eax)
  800d5b:	74 05                	je     800d62 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d5d:	40                   	inc    %eax
  800d5e:	39 d0                	cmp    %edx,%eax
  800d60:	72 f7                	jb     800d59 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d62:	5d                   	pop    %ebp
  800d63:	c3                   	ret    

00800d64 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d64:	55                   	push   %ebp
  800d65:	89 e5                	mov    %esp,%ebp
  800d67:	57                   	push   %edi
  800d68:	56                   	push   %esi
  800d69:	53                   	push   %ebx
  800d6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d70:	eb 01                	jmp    800d73 <strtol+0xf>
		s++;
  800d72:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d73:	8a 02                	mov    (%edx),%al
  800d75:	3c 20                	cmp    $0x20,%al
  800d77:	74 f9                	je     800d72 <strtol+0xe>
  800d79:	3c 09                	cmp    $0x9,%al
  800d7b:	74 f5                	je     800d72 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d7d:	3c 2b                	cmp    $0x2b,%al
  800d7f:	75 08                	jne    800d89 <strtol+0x25>
		s++;
  800d81:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d82:	bf 00 00 00 00       	mov    $0x0,%edi
  800d87:	eb 13                	jmp    800d9c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d89:	3c 2d                	cmp    $0x2d,%al
  800d8b:	75 0a                	jne    800d97 <strtol+0x33>
		s++, neg = 1;
  800d8d:	8d 52 01             	lea    0x1(%edx),%edx
  800d90:	bf 01 00 00 00       	mov    $0x1,%edi
  800d95:	eb 05                	jmp    800d9c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d97:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d9c:	85 db                	test   %ebx,%ebx
  800d9e:	74 05                	je     800da5 <strtol+0x41>
  800da0:	83 fb 10             	cmp    $0x10,%ebx
  800da3:	75 28                	jne    800dcd <strtol+0x69>
  800da5:	8a 02                	mov    (%edx),%al
  800da7:	3c 30                	cmp    $0x30,%al
  800da9:	75 10                	jne    800dbb <strtol+0x57>
  800dab:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800daf:	75 0a                	jne    800dbb <strtol+0x57>
		s += 2, base = 16;
  800db1:	83 c2 02             	add    $0x2,%edx
  800db4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800db9:	eb 12                	jmp    800dcd <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800dbb:	85 db                	test   %ebx,%ebx
  800dbd:	75 0e                	jne    800dcd <strtol+0x69>
  800dbf:	3c 30                	cmp    $0x30,%al
  800dc1:	75 05                	jne    800dc8 <strtol+0x64>
		s++, base = 8;
  800dc3:	42                   	inc    %edx
  800dc4:	b3 08                	mov    $0x8,%bl
  800dc6:	eb 05                	jmp    800dcd <strtol+0x69>
	else if (base == 0)
		base = 10;
  800dc8:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800dcd:	b8 00 00 00 00       	mov    $0x0,%eax
  800dd2:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800dd4:	8a 0a                	mov    (%edx),%cl
  800dd6:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800dd9:	80 fb 09             	cmp    $0x9,%bl
  800ddc:	77 08                	ja     800de6 <strtol+0x82>
			dig = *s - '0';
  800dde:	0f be c9             	movsbl %cl,%ecx
  800de1:	83 e9 30             	sub    $0x30,%ecx
  800de4:	eb 1e                	jmp    800e04 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800de6:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800de9:	80 fb 19             	cmp    $0x19,%bl
  800dec:	77 08                	ja     800df6 <strtol+0x92>
			dig = *s - 'a' + 10;
  800dee:	0f be c9             	movsbl %cl,%ecx
  800df1:	83 e9 57             	sub    $0x57,%ecx
  800df4:	eb 0e                	jmp    800e04 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800df6:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800df9:	80 fb 19             	cmp    $0x19,%bl
  800dfc:	77 12                	ja     800e10 <strtol+0xac>
			dig = *s - 'A' + 10;
  800dfe:	0f be c9             	movsbl %cl,%ecx
  800e01:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800e04:	39 f1                	cmp    %esi,%ecx
  800e06:	7d 0c                	jge    800e14 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800e08:	42                   	inc    %edx
  800e09:	0f af c6             	imul   %esi,%eax
  800e0c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800e0e:	eb c4                	jmp    800dd4 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800e10:	89 c1                	mov    %eax,%ecx
  800e12:	eb 02                	jmp    800e16 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800e14:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800e16:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e1a:	74 05                	je     800e21 <strtol+0xbd>
		*endptr = (char *) s;
  800e1c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e1f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800e21:	85 ff                	test   %edi,%edi
  800e23:	74 04                	je     800e29 <strtol+0xc5>
  800e25:	89 c8                	mov    %ecx,%eax
  800e27:	f7 d8                	neg    %eax
}
  800e29:	5b                   	pop    %ebx
  800e2a:	5e                   	pop    %esi
  800e2b:	5f                   	pop    %edi
  800e2c:	5d                   	pop    %ebp
  800e2d:	c3                   	ret    
	...

00800e30 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800e30:	55                   	push   %ebp
  800e31:	57                   	push   %edi
  800e32:	56                   	push   %esi
  800e33:	83 ec 10             	sub    $0x10,%esp
  800e36:	8b 74 24 20          	mov    0x20(%esp),%esi
  800e3a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800e3e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e42:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  800e46:	89 cd                	mov    %ecx,%ebp
  800e48:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e4c:	85 c0                	test   %eax,%eax
  800e4e:	75 2c                	jne    800e7c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800e50:	39 f9                	cmp    %edi,%ecx
  800e52:	77 68                	ja     800ebc <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800e54:	85 c9                	test   %ecx,%ecx
  800e56:	75 0b                	jne    800e63 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800e58:	b8 01 00 00 00       	mov    $0x1,%eax
  800e5d:	31 d2                	xor    %edx,%edx
  800e5f:	f7 f1                	div    %ecx
  800e61:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800e63:	31 d2                	xor    %edx,%edx
  800e65:	89 f8                	mov    %edi,%eax
  800e67:	f7 f1                	div    %ecx
  800e69:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e6b:	89 f0                	mov    %esi,%eax
  800e6d:	f7 f1                	div    %ecx
  800e6f:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e71:	89 f0                	mov    %esi,%eax
  800e73:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e75:	83 c4 10             	add    $0x10,%esp
  800e78:	5e                   	pop    %esi
  800e79:	5f                   	pop    %edi
  800e7a:	5d                   	pop    %ebp
  800e7b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e7c:	39 f8                	cmp    %edi,%eax
  800e7e:	77 2c                	ja     800eac <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e80:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  800e83:	83 f6 1f             	xor    $0x1f,%esi
  800e86:	75 4c                	jne    800ed4 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e88:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e8a:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e8f:	72 0a                	jb     800e9b <__udivdi3+0x6b>
  800e91:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800e95:	0f 87 ad 00 00 00    	ja     800f48 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e9b:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800ea0:	89 f0                	mov    %esi,%eax
  800ea2:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800ea4:	83 c4 10             	add    $0x10,%esp
  800ea7:	5e                   	pop    %esi
  800ea8:	5f                   	pop    %edi
  800ea9:	5d                   	pop    %ebp
  800eaa:	c3                   	ret    
  800eab:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800eac:	31 ff                	xor    %edi,%edi
  800eae:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800eb0:	89 f0                	mov    %esi,%eax
  800eb2:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800eb4:	83 c4 10             	add    $0x10,%esp
  800eb7:	5e                   	pop    %esi
  800eb8:	5f                   	pop    %edi
  800eb9:	5d                   	pop    %ebp
  800eba:	c3                   	ret    
  800ebb:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ebc:	89 fa                	mov    %edi,%edx
  800ebe:	89 f0                	mov    %esi,%eax
  800ec0:	f7 f1                	div    %ecx
  800ec2:	89 c6                	mov    %eax,%esi
  800ec4:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800ec6:	89 f0                	mov    %esi,%eax
  800ec8:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800eca:	83 c4 10             	add    $0x10,%esp
  800ecd:	5e                   	pop    %esi
  800ece:	5f                   	pop    %edi
  800ecf:	5d                   	pop    %ebp
  800ed0:	c3                   	ret    
  800ed1:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800ed4:	89 f1                	mov    %esi,%ecx
  800ed6:	d3 e0                	shl    %cl,%eax
  800ed8:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800edc:	b8 20 00 00 00       	mov    $0x20,%eax
  800ee1:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800ee3:	89 ea                	mov    %ebp,%edx
  800ee5:	88 c1                	mov    %al,%cl
  800ee7:	d3 ea                	shr    %cl,%edx
  800ee9:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800eed:	09 ca                	or     %ecx,%edx
  800eef:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  800ef3:	89 f1                	mov    %esi,%ecx
  800ef5:	d3 e5                	shl    %cl,%ebp
  800ef7:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  800efb:	89 fd                	mov    %edi,%ebp
  800efd:	88 c1                	mov    %al,%cl
  800eff:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  800f01:	89 fa                	mov    %edi,%edx
  800f03:	89 f1                	mov    %esi,%ecx
  800f05:	d3 e2                	shl    %cl,%edx
  800f07:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f0b:	88 c1                	mov    %al,%cl
  800f0d:	d3 ef                	shr    %cl,%edi
  800f0f:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800f11:	89 f8                	mov    %edi,%eax
  800f13:	89 ea                	mov    %ebp,%edx
  800f15:	f7 74 24 08          	divl   0x8(%esp)
  800f19:	89 d1                	mov    %edx,%ecx
  800f1b:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  800f1d:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f21:	39 d1                	cmp    %edx,%ecx
  800f23:	72 17                	jb     800f3c <__udivdi3+0x10c>
  800f25:	74 09                	je     800f30 <__udivdi3+0x100>
  800f27:	89 fe                	mov    %edi,%esi
  800f29:	31 ff                	xor    %edi,%edi
  800f2b:	e9 41 ff ff ff       	jmp    800e71 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800f30:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f34:	89 f1                	mov    %esi,%ecx
  800f36:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f38:	39 c2                	cmp    %eax,%edx
  800f3a:	73 eb                	jae    800f27 <__udivdi3+0xf7>
		{
		  q0--;
  800f3c:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f3f:	31 ff                	xor    %edi,%edi
  800f41:	e9 2b ff ff ff       	jmp    800e71 <__udivdi3+0x41>
  800f46:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800f48:	31 f6                	xor    %esi,%esi
  800f4a:	e9 22 ff ff ff       	jmp    800e71 <__udivdi3+0x41>
	...

00800f50 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800f50:	55                   	push   %ebp
  800f51:	57                   	push   %edi
  800f52:	56                   	push   %esi
  800f53:	83 ec 20             	sub    $0x20,%esp
  800f56:	8b 44 24 30          	mov    0x30(%esp),%eax
  800f5a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800f5e:	89 44 24 14          	mov    %eax,0x14(%esp)
  800f62:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  800f66:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800f6a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800f6e:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  800f70:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800f72:	85 ed                	test   %ebp,%ebp
  800f74:	75 16                	jne    800f8c <__umoddi3+0x3c>
    {
      if (d0 > n1)
  800f76:	39 f1                	cmp    %esi,%ecx
  800f78:	0f 86 a6 00 00 00    	jbe    801024 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f7e:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800f80:	89 d0                	mov    %edx,%eax
  800f82:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f84:	83 c4 20             	add    $0x20,%esp
  800f87:	5e                   	pop    %esi
  800f88:	5f                   	pop    %edi
  800f89:	5d                   	pop    %ebp
  800f8a:	c3                   	ret    
  800f8b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800f8c:	39 f5                	cmp    %esi,%ebp
  800f8e:	0f 87 ac 00 00 00    	ja     801040 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800f94:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  800f97:	83 f0 1f             	xor    $0x1f,%eax
  800f9a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f9e:	0f 84 a8 00 00 00    	je     80104c <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800fa4:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800fa8:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800faa:	bf 20 00 00 00       	mov    $0x20,%edi
  800faf:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800fb3:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800fb7:	89 f9                	mov    %edi,%ecx
  800fb9:	d3 e8                	shr    %cl,%eax
  800fbb:	09 e8                	or     %ebp,%eax
  800fbd:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  800fc1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800fc5:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800fc9:	d3 e0                	shl    %cl,%eax
  800fcb:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800fcf:	89 f2                	mov    %esi,%edx
  800fd1:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800fd3:	8b 44 24 14          	mov    0x14(%esp),%eax
  800fd7:	d3 e0                	shl    %cl,%eax
  800fd9:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800fdd:	8b 44 24 14          	mov    0x14(%esp),%eax
  800fe1:	89 f9                	mov    %edi,%ecx
  800fe3:	d3 e8                	shr    %cl,%eax
  800fe5:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800fe7:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800fe9:	89 f2                	mov    %esi,%edx
  800feb:	f7 74 24 18          	divl   0x18(%esp)
  800fef:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800ff1:	f7 64 24 0c          	mull   0xc(%esp)
  800ff5:	89 c5                	mov    %eax,%ebp
  800ff7:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ff9:	39 d6                	cmp    %edx,%esi
  800ffb:	72 67                	jb     801064 <__umoddi3+0x114>
  800ffd:	74 75                	je     801074 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800fff:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801003:	29 e8                	sub    %ebp,%eax
  801005:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801007:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80100b:	d3 e8                	shr    %cl,%eax
  80100d:	89 f2                	mov    %esi,%edx
  80100f:	89 f9                	mov    %edi,%ecx
  801011:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801013:	09 d0                	or     %edx,%eax
  801015:	89 f2                	mov    %esi,%edx
  801017:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80101b:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80101d:	83 c4 20             	add    $0x20,%esp
  801020:	5e                   	pop    %esi
  801021:	5f                   	pop    %edi
  801022:	5d                   	pop    %ebp
  801023:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801024:	85 c9                	test   %ecx,%ecx
  801026:	75 0b                	jne    801033 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801028:	b8 01 00 00 00       	mov    $0x1,%eax
  80102d:	31 d2                	xor    %edx,%edx
  80102f:	f7 f1                	div    %ecx
  801031:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801033:	89 f0                	mov    %esi,%eax
  801035:	31 d2                	xor    %edx,%edx
  801037:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801039:	89 f8                	mov    %edi,%eax
  80103b:	e9 3e ff ff ff       	jmp    800f7e <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801040:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801042:	83 c4 20             	add    $0x20,%esp
  801045:	5e                   	pop    %esi
  801046:	5f                   	pop    %edi
  801047:	5d                   	pop    %ebp
  801048:	c3                   	ret    
  801049:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80104c:	39 f5                	cmp    %esi,%ebp
  80104e:	72 04                	jb     801054 <__umoddi3+0x104>
  801050:	39 f9                	cmp    %edi,%ecx
  801052:	77 06                	ja     80105a <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801054:	89 f2                	mov    %esi,%edx
  801056:	29 cf                	sub    %ecx,%edi
  801058:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  80105a:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80105c:	83 c4 20             	add    $0x20,%esp
  80105f:	5e                   	pop    %esi
  801060:	5f                   	pop    %edi
  801061:	5d                   	pop    %ebp
  801062:	c3                   	ret    
  801063:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801064:	89 d1                	mov    %edx,%ecx
  801066:	89 c5                	mov    %eax,%ebp
  801068:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  80106c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801070:	eb 8d                	jmp    800fff <__umoddi3+0xaf>
  801072:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801074:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801078:	72 ea                	jb     801064 <__umoddi3+0x114>
  80107a:	89 f1                	mov    %esi,%ecx
  80107c:	eb 81                	jmp    800fff <__umoddi3+0xaf>
