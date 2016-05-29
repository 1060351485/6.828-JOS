
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
  800049:	e8 6a 00 00 00       	call   8000b8 <sys_cputs>
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
  80005e:	e8 e4 00 00 00       	call   800147 <sys_getenvid>
  800063:	25 ff 03 00 00       	and    $0x3ff,%eax
  800068:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80006f:	c1 e0 07             	shl    $0x7,%eax
  800072:	29 d0                	sub    %edx,%eax
  800074:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800079:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007e:	85 f6                	test   %esi,%esi
  800080:	7e 07                	jle    800089 <libmain+0x39>
		binaryname = argv[0];
  800082:	8b 03                	mov    (%ebx),%eax
  800084:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800089:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80008d:	89 34 24             	mov    %esi,(%esp)
  800090:	e8 9f ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800095:	e8 0a 00 00 00       	call   8000a4 <exit>
}
  80009a:	83 c4 10             	add    $0x10,%esp
  80009d:	5b                   	pop    %ebx
  80009e:	5e                   	pop    %esi
  80009f:	5d                   	pop    %ebp
  8000a0:	c3                   	ret    
  8000a1:	00 00                	add    %al,(%eax)
	...

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
  800123:	c7 44 24 08 2a 10 80 	movl   $0x80102a,0x8(%esp)
  80012a:	00 
  80012b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800132:	00 
  800133:	c7 04 24 47 10 80 00 	movl   $0x801047,(%esp)
  80013a:	e8 b1 02 00 00       	call   8003f0 <_panic>

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
  8001b5:	c7 44 24 08 2a 10 80 	movl   $0x80102a,0x8(%esp)
  8001bc:	00 
  8001bd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001c4:	00 
  8001c5:	c7 04 24 47 10 80 00 	movl   $0x801047,(%esp)
  8001cc:	e8 1f 02 00 00       	call   8003f0 <_panic>

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
  800208:	c7 44 24 08 2a 10 80 	movl   $0x80102a,0x8(%esp)
  80020f:	00 
  800210:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800217:	00 
  800218:	c7 04 24 47 10 80 00 	movl   $0x801047,(%esp)
  80021f:	e8 cc 01 00 00       	call   8003f0 <_panic>

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
  80025b:	c7 44 24 08 2a 10 80 	movl   $0x80102a,0x8(%esp)
  800262:	00 
  800263:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80026a:	00 
  80026b:	c7 04 24 47 10 80 00 	movl   $0x801047,(%esp)
  800272:	e8 79 01 00 00       	call   8003f0 <_panic>

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
  8002ae:	c7 44 24 08 2a 10 80 	movl   $0x80102a,0x8(%esp)
  8002b5:	00 
  8002b6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002bd:	00 
  8002be:	c7 04 24 47 10 80 00 	movl   $0x801047,(%esp)
  8002c5:	e8 26 01 00 00       	call   8003f0 <_panic>

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
  800301:	c7 44 24 08 2a 10 80 	movl   $0x80102a,0x8(%esp)
  800308:	00 
  800309:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800310:	00 
  800311:	c7 04 24 47 10 80 00 	movl   $0x801047,(%esp)
  800318:	e8 d3 00 00 00       	call   8003f0 <_panic>

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
  800354:	c7 44 24 08 2a 10 80 	movl   $0x80102a,0x8(%esp)
  80035b:	00 
  80035c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800363:	00 
  800364:	c7 04 24 47 10 80 00 	movl   $0x801047,(%esp)
  80036b:	e8 80 00 00 00       	call   8003f0 <_panic>

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
  8003c9:	c7 44 24 08 2a 10 80 	movl   $0x80102a,0x8(%esp)
  8003d0:	00 
  8003d1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003d8:	00 
  8003d9:	c7 04 24 47 10 80 00 	movl   $0x801047,(%esp)
  8003e0:	e8 0b 00 00 00       	call   8003f0 <_panic>

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
  8003ed:	00 00                	add    %al,(%eax)
	...

008003f0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003f0:	55                   	push   %ebp
  8003f1:	89 e5                	mov    %esp,%ebp
  8003f3:	56                   	push   %esi
  8003f4:	53                   	push   %ebx
  8003f5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8003f8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003fb:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800401:	e8 41 fd ff ff       	call   800147 <sys_getenvid>
  800406:	8b 55 0c             	mov    0xc(%ebp),%edx
  800409:	89 54 24 10          	mov    %edx,0x10(%esp)
  80040d:	8b 55 08             	mov    0x8(%ebp),%edx
  800410:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800414:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800418:	89 44 24 04          	mov    %eax,0x4(%esp)
  80041c:	c7 04 24 58 10 80 00 	movl   $0x801058,(%esp)
  800423:	e8 c0 00 00 00       	call   8004e8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800428:	89 74 24 04          	mov    %esi,0x4(%esp)
  80042c:	8b 45 10             	mov    0x10(%ebp),%eax
  80042f:	89 04 24             	mov    %eax,(%esp)
  800432:	e8 50 00 00 00       	call   800487 <vcprintf>
	cprintf("\n");
  800437:	c7 04 24 7b 10 80 00 	movl   $0x80107b,(%esp)
  80043e:	e8 a5 00 00 00       	call   8004e8 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800443:	cc                   	int3   
  800444:	eb fd                	jmp    800443 <_panic+0x53>
	...

00800448 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800448:	55                   	push   %ebp
  800449:	89 e5                	mov    %esp,%ebp
  80044b:	53                   	push   %ebx
  80044c:	83 ec 14             	sub    $0x14,%esp
  80044f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800452:	8b 03                	mov    (%ebx),%eax
  800454:	8b 55 08             	mov    0x8(%ebp),%edx
  800457:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80045b:	40                   	inc    %eax
  80045c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80045e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800463:	75 19                	jne    80047e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800465:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80046c:	00 
  80046d:	8d 43 08             	lea    0x8(%ebx),%eax
  800470:	89 04 24             	mov    %eax,(%esp)
  800473:	e8 40 fc ff ff       	call   8000b8 <sys_cputs>
		b->idx = 0;
  800478:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80047e:	ff 43 04             	incl   0x4(%ebx)
}
  800481:	83 c4 14             	add    $0x14,%esp
  800484:	5b                   	pop    %ebx
  800485:	5d                   	pop    %ebp
  800486:	c3                   	ret    

00800487 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800487:	55                   	push   %ebp
  800488:	89 e5                	mov    %esp,%ebp
  80048a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800490:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800497:	00 00 00 
	b.cnt = 0;
  80049a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004a1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ae:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004b2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004bc:	c7 04 24 48 04 80 00 	movl   $0x800448,(%esp)
  8004c3:	e8 82 01 00 00       	call   80064a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004c8:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8004ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004d2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004d8:	89 04 24             	mov    %eax,(%esp)
  8004db:	e8 d8 fb ff ff       	call   8000b8 <sys_cputs>

	return b.cnt;
}
  8004e0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004e6:	c9                   	leave  
  8004e7:	c3                   	ret    

008004e8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004e8:	55                   	push   %ebp
  8004e9:	89 e5                	mov    %esp,%ebp
  8004eb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004ee:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f8:	89 04 24             	mov    %eax,(%esp)
  8004fb:	e8 87 ff ff ff       	call   800487 <vcprintf>
	va_end(ap);

	return cnt;
}
  800500:	c9                   	leave  
  800501:	c3                   	ret    
	...

00800504 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800504:	55                   	push   %ebp
  800505:	89 e5                	mov    %esp,%ebp
  800507:	57                   	push   %edi
  800508:	56                   	push   %esi
  800509:	53                   	push   %ebx
  80050a:	83 ec 3c             	sub    $0x3c,%esp
  80050d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800510:	89 d7                	mov    %edx,%edi
  800512:	8b 45 08             	mov    0x8(%ebp),%eax
  800515:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800518:	8b 45 0c             	mov    0xc(%ebp),%eax
  80051b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80051e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800521:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800524:	85 c0                	test   %eax,%eax
  800526:	75 08                	jne    800530 <printnum+0x2c>
  800528:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80052b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80052e:	77 57                	ja     800587 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800530:	89 74 24 10          	mov    %esi,0x10(%esp)
  800534:	4b                   	dec    %ebx
  800535:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800539:	8b 45 10             	mov    0x10(%ebp),%eax
  80053c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800540:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800544:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800548:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80054f:	00 
  800550:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800553:	89 04 24             	mov    %eax,(%esp)
  800556:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800559:	89 44 24 04          	mov    %eax,0x4(%esp)
  80055d:	e8 56 08 00 00       	call   800db8 <__udivdi3>
  800562:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800566:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80056a:	89 04 24             	mov    %eax,(%esp)
  80056d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800571:	89 fa                	mov    %edi,%edx
  800573:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800576:	e8 89 ff ff ff       	call   800504 <printnum>
  80057b:	eb 0f                	jmp    80058c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80057d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800581:	89 34 24             	mov    %esi,(%esp)
  800584:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800587:	4b                   	dec    %ebx
  800588:	85 db                	test   %ebx,%ebx
  80058a:	7f f1                	jg     80057d <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80058c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800590:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800594:	8b 45 10             	mov    0x10(%ebp),%eax
  800597:	89 44 24 08          	mov    %eax,0x8(%esp)
  80059b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005a2:	00 
  8005a3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005a6:	89 04 24             	mov    %eax,(%esp)
  8005a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005b0:	e8 23 09 00 00       	call   800ed8 <__umoddi3>
  8005b5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005b9:	0f be 80 7d 10 80 00 	movsbl 0x80107d(%eax),%eax
  8005c0:	89 04 24             	mov    %eax,(%esp)
  8005c3:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8005c6:	83 c4 3c             	add    $0x3c,%esp
  8005c9:	5b                   	pop    %ebx
  8005ca:	5e                   	pop    %esi
  8005cb:	5f                   	pop    %edi
  8005cc:	5d                   	pop    %ebp
  8005cd:	c3                   	ret    

008005ce <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8005ce:	55                   	push   %ebp
  8005cf:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8005d1:	83 fa 01             	cmp    $0x1,%edx
  8005d4:	7e 0e                	jle    8005e4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8005d6:	8b 10                	mov    (%eax),%edx
  8005d8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8005db:	89 08                	mov    %ecx,(%eax)
  8005dd:	8b 02                	mov    (%edx),%eax
  8005df:	8b 52 04             	mov    0x4(%edx),%edx
  8005e2:	eb 22                	jmp    800606 <getuint+0x38>
	else if (lflag)
  8005e4:	85 d2                	test   %edx,%edx
  8005e6:	74 10                	je     8005f8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8005e8:	8b 10                	mov    (%eax),%edx
  8005ea:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005ed:	89 08                	mov    %ecx,(%eax)
  8005ef:	8b 02                	mov    (%edx),%eax
  8005f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8005f6:	eb 0e                	jmp    800606 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005f8:	8b 10                	mov    (%eax),%edx
  8005fa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005fd:	89 08                	mov    %ecx,(%eax)
  8005ff:	8b 02                	mov    (%edx),%eax
  800601:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800606:	5d                   	pop    %ebp
  800607:	c3                   	ret    

00800608 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800608:	55                   	push   %ebp
  800609:	89 e5                	mov    %esp,%ebp
  80060b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80060e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800611:	8b 10                	mov    (%eax),%edx
  800613:	3b 50 04             	cmp    0x4(%eax),%edx
  800616:	73 08                	jae    800620 <sprintputch+0x18>
		*b->buf++ = ch;
  800618:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80061b:	88 0a                	mov    %cl,(%edx)
  80061d:	42                   	inc    %edx
  80061e:	89 10                	mov    %edx,(%eax)
}
  800620:	5d                   	pop    %ebp
  800621:	c3                   	ret    

00800622 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800622:	55                   	push   %ebp
  800623:	89 e5                	mov    %esp,%ebp
  800625:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800628:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80062b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80062f:	8b 45 10             	mov    0x10(%ebp),%eax
  800632:	89 44 24 08          	mov    %eax,0x8(%esp)
  800636:	8b 45 0c             	mov    0xc(%ebp),%eax
  800639:	89 44 24 04          	mov    %eax,0x4(%esp)
  80063d:	8b 45 08             	mov    0x8(%ebp),%eax
  800640:	89 04 24             	mov    %eax,(%esp)
  800643:	e8 02 00 00 00       	call   80064a <vprintfmt>
	va_end(ap);
}
  800648:	c9                   	leave  
  800649:	c3                   	ret    

0080064a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80064a:	55                   	push   %ebp
  80064b:	89 e5                	mov    %esp,%ebp
  80064d:	57                   	push   %edi
  80064e:	56                   	push   %esi
  80064f:	53                   	push   %ebx
  800650:	83 ec 4c             	sub    $0x4c,%esp
  800653:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800656:	8b 75 10             	mov    0x10(%ebp),%esi
  800659:	eb 12                	jmp    80066d <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80065b:	85 c0                	test   %eax,%eax
  80065d:	0f 84 6b 03 00 00    	je     8009ce <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800663:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800667:	89 04 24             	mov    %eax,(%esp)
  80066a:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80066d:	0f b6 06             	movzbl (%esi),%eax
  800670:	46                   	inc    %esi
  800671:	83 f8 25             	cmp    $0x25,%eax
  800674:	75 e5                	jne    80065b <vprintfmt+0x11>
  800676:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80067a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800681:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800686:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80068d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800692:	eb 26                	jmp    8006ba <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800694:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800697:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80069b:	eb 1d                	jmp    8006ba <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8006a0:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8006a4:	eb 14                	jmp    8006ba <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8006a9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8006b0:	eb 08                	jmp    8006ba <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8006b2:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8006b5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ba:	0f b6 06             	movzbl (%esi),%eax
  8006bd:	8d 56 01             	lea    0x1(%esi),%edx
  8006c0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8006c3:	8a 16                	mov    (%esi),%dl
  8006c5:	83 ea 23             	sub    $0x23,%edx
  8006c8:	80 fa 55             	cmp    $0x55,%dl
  8006cb:	0f 87 e1 02 00 00    	ja     8009b2 <vprintfmt+0x368>
  8006d1:	0f b6 d2             	movzbl %dl,%edx
  8006d4:	ff 24 95 c0 11 80 00 	jmp    *0x8011c0(,%edx,4)
  8006db:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006de:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8006e3:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8006e6:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8006ea:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8006ed:	8d 50 d0             	lea    -0x30(%eax),%edx
  8006f0:	83 fa 09             	cmp    $0x9,%edx
  8006f3:	77 2a                	ja     80071f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8006f5:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8006f6:	eb eb                	jmp    8006e3 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8006f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fb:	8d 50 04             	lea    0x4(%eax),%edx
  8006fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800701:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800703:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800706:	eb 17                	jmp    80071f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800708:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80070c:	78 98                	js     8006a6 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800711:	eb a7                	jmp    8006ba <vprintfmt+0x70>
  800713:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800716:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80071d:	eb 9b                	jmp    8006ba <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80071f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800723:	79 95                	jns    8006ba <vprintfmt+0x70>
  800725:	eb 8b                	jmp    8006b2 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800727:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800728:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80072b:	eb 8d                	jmp    8006ba <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80072d:	8b 45 14             	mov    0x14(%ebp),%eax
  800730:	8d 50 04             	lea    0x4(%eax),%edx
  800733:	89 55 14             	mov    %edx,0x14(%ebp)
  800736:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80073a:	8b 00                	mov    (%eax),%eax
  80073c:	89 04 24             	mov    %eax,(%esp)
  80073f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800742:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800745:	e9 23 ff ff ff       	jmp    80066d <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80074a:	8b 45 14             	mov    0x14(%ebp),%eax
  80074d:	8d 50 04             	lea    0x4(%eax),%edx
  800750:	89 55 14             	mov    %edx,0x14(%ebp)
  800753:	8b 00                	mov    (%eax),%eax
  800755:	85 c0                	test   %eax,%eax
  800757:	79 02                	jns    80075b <vprintfmt+0x111>
  800759:	f7 d8                	neg    %eax
  80075b:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80075d:	83 f8 0f             	cmp    $0xf,%eax
  800760:	7f 0b                	jg     80076d <vprintfmt+0x123>
  800762:	8b 04 85 20 13 80 00 	mov    0x801320(,%eax,4),%eax
  800769:	85 c0                	test   %eax,%eax
  80076b:	75 23                	jne    800790 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80076d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800771:	c7 44 24 08 95 10 80 	movl   $0x801095,0x8(%esp)
  800778:	00 
  800779:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80077d:	8b 45 08             	mov    0x8(%ebp),%eax
  800780:	89 04 24             	mov    %eax,(%esp)
  800783:	e8 9a fe ff ff       	call   800622 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800788:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80078b:	e9 dd fe ff ff       	jmp    80066d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800790:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800794:	c7 44 24 08 9e 10 80 	movl   $0x80109e,0x8(%esp)
  80079b:	00 
  80079c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8007a3:	89 14 24             	mov    %edx,(%esp)
  8007a6:	e8 77 fe ff ff       	call   800622 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ab:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007ae:	e9 ba fe ff ff       	jmp    80066d <vprintfmt+0x23>
  8007b3:	89 f9                	mov    %edi,%ecx
  8007b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007b8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8007bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007be:	8d 50 04             	lea    0x4(%eax),%edx
  8007c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c4:	8b 30                	mov    (%eax),%esi
  8007c6:	85 f6                	test   %esi,%esi
  8007c8:	75 05                	jne    8007cf <vprintfmt+0x185>
				p = "(null)";
  8007ca:	be 8e 10 80 00       	mov    $0x80108e,%esi
			if (width > 0 && padc != '-')
  8007cf:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8007d3:	0f 8e 84 00 00 00    	jle    80085d <vprintfmt+0x213>
  8007d9:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8007dd:	74 7e                	je     80085d <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8007df:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007e3:	89 34 24             	mov    %esi,(%esp)
  8007e6:	e8 8b 02 00 00       	call   800a76 <strnlen>
  8007eb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007ee:	29 c2                	sub    %eax,%edx
  8007f0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8007f3:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8007f7:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8007fa:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8007fd:	89 de                	mov    %ebx,%esi
  8007ff:	89 d3                	mov    %edx,%ebx
  800801:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800803:	eb 0b                	jmp    800810 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800805:	89 74 24 04          	mov    %esi,0x4(%esp)
  800809:	89 3c 24             	mov    %edi,(%esp)
  80080c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80080f:	4b                   	dec    %ebx
  800810:	85 db                	test   %ebx,%ebx
  800812:	7f f1                	jg     800805 <vprintfmt+0x1bb>
  800814:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800817:	89 f3                	mov    %esi,%ebx
  800819:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80081c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80081f:	85 c0                	test   %eax,%eax
  800821:	79 05                	jns    800828 <vprintfmt+0x1de>
  800823:	b8 00 00 00 00       	mov    $0x0,%eax
  800828:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80082b:	29 c2                	sub    %eax,%edx
  80082d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800830:	eb 2b                	jmp    80085d <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800832:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800836:	74 18                	je     800850 <vprintfmt+0x206>
  800838:	8d 50 e0             	lea    -0x20(%eax),%edx
  80083b:	83 fa 5e             	cmp    $0x5e,%edx
  80083e:	76 10                	jbe    800850 <vprintfmt+0x206>
					putch('?', putdat);
  800840:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800844:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80084b:	ff 55 08             	call   *0x8(%ebp)
  80084e:	eb 0a                	jmp    80085a <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800850:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800854:	89 04 24             	mov    %eax,(%esp)
  800857:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80085a:	ff 4d e4             	decl   -0x1c(%ebp)
  80085d:	0f be 06             	movsbl (%esi),%eax
  800860:	46                   	inc    %esi
  800861:	85 c0                	test   %eax,%eax
  800863:	74 21                	je     800886 <vprintfmt+0x23c>
  800865:	85 ff                	test   %edi,%edi
  800867:	78 c9                	js     800832 <vprintfmt+0x1e8>
  800869:	4f                   	dec    %edi
  80086a:	79 c6                	jns    800832 <vprintfmt+0x1e8>
  80086c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80086f:	89 de                	mov    %ebx,%esi
  800871:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800874:	eb 18                	jmp    80088e <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800876:	89 74 24 04          	mov    %esi,0x4(%esp)
  80087a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800881:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800883:	4b                   	dec    %ebx
  800884:	eb 08                	jmp    80088e <vprintfmt+0x244>
  800886:	8b 7d 08             	mov    0x8(%ebp),%edi
  800889:	89 de                	mov    %ebx,%esi
  80088b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80088e:	85 db                	test   %ebx,%ebx
  800890:	7f e4                	jg     800876 <vprintfmt+0x22c>
  800892:	89 7d 08             	mov    %edi,0x8(%ebp)
  800895:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800897:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80089a:	e9 ce fd ff ff       	jmp    80066d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80089f:	83 f9 01             	cmp    $0x1,%ecx
  8008a2:	7e 10                	jle    8008b4 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8008a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a7:	8d 50 08             	lea    0x8(%eax),%edx
  8008aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8008ad:	8b 30                	mov    (%eax),%esi
  8008af:	8b 78 04             	mov    0x4(%eax),%edi
  8008b2:	eb 26                	jmp    8008da <vprintfmt+0x290>
	else if (lflag)
  8008b4:	85 c9                	test   %ecx,%ecx
  8008b6:	74 12                	je     8008ca <vprintfmt+0x280>
		return va_arg(*ap, long);
  8008b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008bb:	8d 50 04             	lea    0x4(%eax),%edx
  8008be:	89 55 14             	mov    %edx,0x14(%ebp)
  8008c1:	8b 30                	mov    (%eax),%esi
  8008c3:	89 f7                	mov    %esi,%edi
  8008c5:	c1 ff 1f             	sar    $0x1f,%edi
  8008c8:	eb 10                	jmp    8008da <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8008ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8008cd:	8d 50 04             	lea    0x4(%eax),%edx
  8008d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8008d3:	8b 30                	mov    (%eax),%esi
  8008d5:	89 f7                	mov    %esi,%edi
  8008d7:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8008da:	85 ff                	test   %edi,%edi
  8008dc:	78 0a                	js     8008e8 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8008de:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008e3:	e9 8c 00 00 00       	jmp    800974 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8008e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008ec:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8008f3:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8008f6:	f7 de                	neg    %esi
  8008f8:	83 d7 00             	adc    $0x0,%edi
  8008fb:	f7 df                	neg    %edi
			}
			base = 10;
  8008fd:	b8 0a 00 00 00       	mov    $0xa,%eax
  800902:	eb 70                	jmp    800974 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800904:	89 ca                	mov    %ecx,%edx
  800906:	8d 45 14             	lea    0x14(%ebp),%eax
  800909:	e8 c0 fc ff ff       	call   8005ce <getuint>
  80090e:	89 c6                	mov    %eax,%esi
  800910:	89 d7                	mov    %edx,%edi
			base = 10;
  800912:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800917:	eb 5b                	jmp    800974 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  800919:	89 ca                	mov    %ecx,%edx
  80091b:	8d 45 14             	lea    0x14(%ebp),%eax
  80091e:	e8 ab fc ff ff       	call   8005ce <getuint>
  800923:	89 c6                	mov    %eax,%esi
  800925:	89 d7                	mov    %edx,%edi
			base = 8;
  800927:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80092c:	eb 46                	jmp    800974 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  80092e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800932:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800939:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80093c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800940:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800947:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80094a:	8b 45 14             	mov    0x14(%ebp),%eax
  80094d:	8d 50 04             	lea    0x4(%eax),%edx
  800950:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800953:	8b 30                	mov    (%eax),%esi
  800955:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80095a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80095f:	eb 13                	jmp    800974 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800961:	89 ca                	mov    %ecx,%edx
  800963:	8d 45 14             	lea    0x14(%ebp),%eax
  800966:	e8 63 fc ff ff       	call   8005ce <getuint>
  80096b:	89 c6                	mov    %eax,%esi
  80096d:	89 d7                	mov    %edx,%edi
			base = 16;
  80096f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800974:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800978:	89 54 24 10          	mov    %edx,0x10(%esp)
  80097c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80097f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800983:	89 44 24 08          	mov    %eax,0x8(%esp)
  800987:	89 34 24             	mov    %esi,(%esp)
  80098a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80098e:	89 da                	mov    %ebx,%edx
  800990:	8b 45 08             	mov    0x8(%ebp),%eax
  800993:	e8 6c fb ff ff       	call   800504 <printnum>
			break;
  800998:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80099b:	e9 cd fc ff ff       	jmp    80066d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8009a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009a4:	89 04 24             	mov    %eax,(%esp)
  8009a7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009aa:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8009ad:	e9 bb fc ff ff       	jmp    80066d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8009b2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009b6:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8009bd:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009c0:	eb 01                	jmp    8009c3 <vprintfmt+0x379>
  8009c2:	4e                   	dec    %esi
  8009c3:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8009c7:	75 f9                	jne    8009c2 <vprintfmt+0x378>
  8009c9:	e9 9f fc ff ff       	jmp    80066d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8009ce:	83 c4 4c             	add    $0x4c,%esp
  8009d1:	5b                   	pop    %ebx
  8009d2:	5e                   	pop    %esi
  8009d3:	5f                   	pop    %edi
  8009d4:	5d                   	pop    %ebp
  8009d5:	c3                   	ret    

008009d6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009d6:	55                   	push   %ebp
  8009d7:	89 e5                	mov    %esp,%ebp
  8009d9:	83 ec 28             	sub    $0x28,%esp
  8009dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009df:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009e2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009e5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009e9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009ec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009f3:	85 c0                	test   %eax,%eax
  8009f5:	74 30                	je     800a27 <vsnprintf+0x51>
  8009f7:	85 d2                	test   %edx,%edx
  8009f9:	7e 33                	jle    800a2e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8009fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a02:	8b 45 10             	mov    0x10(%ebp),%eax
  800a05:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a09:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a0c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a10:	c7 04 24 08 06 80 00 	movl   $0x800608,(%esp)
  800a17:	e8 2e fc ff ff       	call   80064a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a1c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a1f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a25:	eb 0c                	jmp    800a33 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a27:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a2c:	eb 05                	jmp    800a33 <vsnprintf+0x5d>
  800a2e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a33:	c9                   	leave  
  800a34:	c3                   	ret    

00800a35 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a35:	55                   	push   %ebp
  800a36:	89 e5                	mov    %esp,%ebp
  800a38:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a3b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a3e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a42:	8b 45 10             	mov    0x10(%ebp),%eax
  800a45:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a49:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a50:	8b 45 08             	mov    0x8(%ebp),%eax
  800a53:	89 04 24             	mov    %eax,(%esp)
  800a56:	e8 7b ff ff ff       	call   8009d6 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a5b:	c9                   	leave  
  800a5c:	c3                   	ret    
  800a5d:	00 00                	add    %al,(%eax)
	...

00800a60 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a60:	55                   	push   %ebp
  800a61:	89 e5                	mov    %esp,%ebp
  800a63:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a66:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6b:	eb 01                	jmp    800a6e <strlen+0xe>
		n++;
  800a6d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a6e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a72:	75 f9                	jne    800a6d <strlen+0xd>
		n++;
	return n;
}
  800a74:	5d                   	pop    %ebp
  800a75:	c3                   	ret    

00800a76 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a76:	55                   	push   %ebp
  800a77:	89 e5                	mov    %esp,%ebp
  800a79:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800a7c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a7f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a84:	eb 01                	jmp    800a87 <strnlen+0x11>
		n++;
  800a86:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a87:	39 d0                	cmp    %edx,%eax
  800a89:	74 06                	je     800a91 <strnlen+0x1b>
  800a8b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a8f:	75 f5                	jne    800a86 <strnlen+0x10>
		n++;
	return n;
}
  800a91:	5d                   	pop    %ebp
  800a92:	c3                   	ret    

00800a93 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a93:	55                   	push   %ebp
  800a94:	89 e5                	mov    %esp,%ebp
  800a96:	53                   	push   %ebx
  800a97:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a9d:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa2:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800aa5:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800aa8:	42                   	inc    %edx
  800aa9:	84 c9                	test   %cl,%cl
  800aab:	75 f5                	jne    800aa2 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800aad:	5b                   	pop    %ebx
  800aae:	5d                   	pop    %ebp
  800aaf:	c3                   	ret    

00800ab0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	53                   	push   %ebx
  800ab4:	83 ec 08             	sub    $0x8,%esp
  800ab7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800aba:	89 1c 24             	mov    %ebx,(%esp)
  800abd:	e8 9e ff ff ff       	call   800a60 <strlen>
	strcpy(dst + len, src);
  800ac2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ac5:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ac9:	01 d8                	add    %ebx,%eax
  800acb:	89 04 24             	mov    %eax,(%esp)
  800ace:	e8 c0 ff ff ff       	call   800a93 <strcpy>
	return dst;
}
  800ad3:	89 d8                	mov    %ebx,%eax
  800ad5:	83 c4 08             	add    $0x8,%esp
  800ad8:	5b                   	pop    %ebx
  800ad9:	5d                   	pop    %ebp
  800ada:	c3                   	ret    

00800adb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	56                   	push   %esi
  800adf:	53                   	push   %ebx
  800ae0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ae6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ae9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aee:	eb 0c                	jmp    800afc <strncpy+0x21>
		*dst++ = *src;
  800af0:	8a 1a                	mov    (%edx),%bl
  800af2:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800af5:	80 3a 01             	cmpb   $0x1,(%edx)
  800af8:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800afb:	41                   	inc    %ecx
  800afc:	39 f1                	cmp    %esi,%ecx
  800afe:	75 f0                	jne    800af0 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b00:	5b                   	pop    %ebx
  800b01:	5e                   	pop    %esi
  800b02:	5d                   	pop    %ebp
  800b03:	c3                   	ret    

00800b04 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b04:	55                   	push   %ebp
  800b05:	89 e5                	mov    %esp,%ebp
  800b07:	56                   	push   %esi
  800b08:	53                   	push   %ebx
  800b09:	8b 75 08             	mov    0x8(%ebp),%esi
  800b0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b0f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b12:	85 d2                	test   %edx,%edx
  800b14:	75 0a                	jne    800b20 <strlcpy+0x1c>
  800b16:	89 f0                	mov    %esi,%eax
  800b18:	eb 1a                	jmp    800b34 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b1a:	88 18                	mov    %bl,(%eax)
  800b1c:	40                   	inc    %eax
  800b1d:	41                   	inc    %ecx
  800b1e:	eb 02                	jmp    800b22 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b20:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800b22:	4a                   	dec    %edx
  800b23:	74 0a                	je     800b2f <strlcpy+0x2b>
  800b25:	8a 19                	mov    (%ecx),%bl
  800b27:	84 db                	test   %bl,%bl
  800b29:	75 ef                	jne    800b1a <strlcpy+0x16>
  800b2b:	89 c2                	mov    %eax,%edx
  800b2d:	eb 02                	jmp    800b31 <strlcpy+0x2d>
  800b2f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800b31:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800b34:	29 f0                	sub    %esi,%eax
}
  800b36:	5b                   	pop    %ebx
  800b37:	5e                   	pop    %esi
  800b38:	5d                   	pop    %ebp
  800b39:	c3                   	ret    

00800b3a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b3a:	55                   	push   %ebp
  800b3b:	89 e5                	mov    %esp,%ebp
  800b3d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b40:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b43:	eb 02                	jmp    800b47 <strcmp+0xd>
		p++, q++;
  800b45:	41                   	inc    %ecx
  800b46:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b47:	8a 01                	mov    (%ecx),%al
  800b49:	84 c0                	test   %al,%al
  800b4b:	74 04                	je     800b51 <strcmp+0x17>
  800b4d:	3a 02                	cmp    (%edx),%al
  800b4f:	74 f4                	je     800b45 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b51:	0f b6 c0             	movzbl %al,%eax
  800b54:	0f b6 12             	movzbl (%edx),%edx
  800b57:	29 d0                	sub    %edx,%eax
}
  800b59:	5d                   	pop    %ebp
  800b5a:	c3                   	ret    

00800b5b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b5b:	55                   	push   %ebp
  800b5c:	89 e5                	mov    %esp,%ebp
  800b5e:	53                   	push   %ebx
  800b5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b65:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800b68:	eb 03                	jmp    800b6d <strncmp+0x12>
		n--, p++, q++;
  800b6a:	4a                   	dec    %edx
  800b6b:	40                   	inc    %eax
  800b6c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b6d:	85 d2                	test   %edx,%edx
  800b6f:	74 14                	je     800b85 <strncmp+0x2a>
  800b71:	8a 18                	mov    (%eax),%bl
  800b73:	84 db                	test   %bl,%bl
  800b75:	74 04                	je     800b7b <strncmp+0x20>
  800b77:	3a 19                	cmp    (%ecx),%bl
  800b79:	74 ef                	je     800b6a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b7b:	0f b6 00             	movzbl (%eax),%eax
  800b7e:	0f b6 11             	movzbl (%ecx),%edx
  800b81:	29 d0                	sub    %edx,%eax
  800b83:	eb 05                	jmp    800b8a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b85:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b8a:	5b                   	pop    %ebx
  800b8b:	5d                   	pop    %ebp
  800b8c:	c3                   	ret    

00800b8d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b8d:	55                   	push   %ebp
  800b8e:	89 e5                	mov    %esp,%ebp
  800b90:	8b 45 08             	mov    0x8(%ebp),%eax
  800b93:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b96:	eb 05                	jmp    800b9d <strchr+0x10>
		if (*s == c)
  800b98:	38 ca                	cmp    %cl,%dl
  800b9a:	74 0c                	je     800ba8 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b9c:	40                   	inc    %eax
  800b9d:	8a 10                	mov    (%eax),%dl
  800b9f:	84 d2                	test   %dl,%dl
  800ba1:	75 f5                	jne    800b98 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800ba3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ba8:	5d                   	pop    %ebp
  800ba9:	c3                   	ret    

00800baa <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800baa:	55                   	push   %ebp
  800bab:	89 e5                	mov    %esp,%ebp
  800bad:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb0:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800bb3:	eb 05                	jmp    800bba <strfind+0x10>
		if (*s == c)
  800bb5:	38 ca                	cmp    %cl,%dl
  800bb7:	74 07                	je     800bc0 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800bb9:	40                   	inc    %eax
  800bba:	8a 10                	mov    (%eax),%dl
  800bbc:	84 d2                	test   %dl,%dl
  800bbe:	75 f5                	jne    800bb5 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800bc0:	5d                   	pop    %ebp
  800bc1:	c3                   	ret    

00800bc2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	57                   	push   %edi
  800bc6:	56                   	push   %esi
  800bc7:	53                   	push   %ebx
  800bc8:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bcb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bce:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bd1:	85 c9                	test   %ecx,%ecx
  800bd3:	74 30                	je     800c05 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bd5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bdb:	75 25                	jne    800c02 <memset+0x40>
  800bdd:	f6 c1 03             	test   $0x3,%cl
  800be0:	75 20                	jne    800c02 <memset+0x40>
		c &= 0xFF;
  800be2:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800be5:	89 d3                	mov    %edx,%ebx
  800be7:	c1 e3 08             	shl    $0x8,%ebx
  800bea:	89 d6                	mov    %edx,%esi
  800bec:	c1 e6 18             	shl    $0x18,%esi
  800bef:	89 d0                	mov    %edx,%eax
  800bf1:	c1 e0 10             	shl    $0x10,%eax
  800bf4:	09 f0                	or     %esi,%eax
  800bf6:	09 d0                	or     %edx,%eax
  800bf8:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bfa:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800bfd:	fc                   	cld    
  800bfe:	f3 ab                	rep stos %eax,%es:(%edi)
  800c00:	eb 03                	jmp    800c05 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c02:	fc                   	cld    
  800c03:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c05:	89 f8                	mov    %edi,%eax
  800c07:	5b                   	pop    %ebx
  800c08:	5e                   	pop    %esi
  800c09:	5f                   	pop    %edi
  800c0a:	5d                   	pop    %ebp
  800c0b:	c3                   	ret    

00800c0c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c0c:	55                   	push   %ebp
  800c0d:	89 e5                	mov    %esp,%ebp
  800c0f:	57                   	push   %edi
  800c10:	56                   	push   %esi
  800c11:	8b 45 08             	mov    0x8(%ebp),%eax
  800c14:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c17:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c1a:	39 c6                	cmp    %eax,%esi
  800c1c:	73 34                	jae    800c52 <memmove+0x46>
  800c1e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c21:	39 d0                	cmp    %edx,%eax
  800c23:	73 2d                	jae    800c52 <memmove+0x46>
		s += n;
		d += n;
  800c25:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c28:	f6 c2 03             	test   $0x3,%dl
  800c2b:	75 1b                	jne    800c48 <memmove+0x3c>
  800c2d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c33:	75 13                	jne    800c48 <memmove+0x3c>
  800c35:	f6 c1 03             	test   $0x3,%cl
  800c38:	75 0e                	jne    800c48 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c3a:	83 ef 04             	sub    $0x4,%edi
  800c3d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c40:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c43:	fd                   	std    
  800c44:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c46:	eb 07                	jmp    800c4f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c48:	4f                   	dec    %edi
  800c49:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c4c:	fd                   	std    
  800c4d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c4f:	fc                   	cld    
  800c50:	eb 20                	jmp    800c72 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c52:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c58:	75 13                	jne    800c6d <memmove+0x61>
  800c5a:	a8 03                	test   $0x3,%al
  800c5c:	75 0f                	jne    800c6d <memmove+0x61>
  800c5e:	f6 c1 03             	test   $0x3,%cl
  800c61:	75 0a                	jne    800c6d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c63:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c66:	89 c7                	mov    %eax,%edi
  800c68:	fc                   	cld    
  800c69:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c6b:	eb 05                	jmp    800c72 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c6d:	89 c7                	mov    %eax,%edi
  800c6f:	fc                   	cld    
  800c70:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c72:	5e                   	pop    %esi
  800c73:	5f                   	pop    %edi
  800c74:	5d                   	pop    %ebp
  800c75:	c3                   	ret    

00800c76 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c76:	55                   	push   %ebp
  800c77:	89 e5                	mov    %esp,%ebp
  800c79:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c7c:	8b 45 10             	mov    0x10(%ebp),%eax
  800c7f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c83:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c86:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8d:	89 04 24             	mov    %eax,(%esp)
  800c90:	e8 77 ff ff ff       	call   800c0c <memmove>
}
  800c95:	c9                   	leave  
  800c96:	c3                   	ret    

00800c97 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	57                   	push   %edi
  800c9b:	56                   	push   %esi
  800c9c:	53                   	push   %ebx
  800c9d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ca0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ca3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ca6:	ba 00 00 00 00       	mov    $0x0,%edx
  800cab:	eb 16                	jmp    800cc3 <memcmp+0x2c>
		if (*s1 != *s2)
  800cad:	8a 04 17             	mov    (%edi,%edx,1),%al
  800cb0:	42                   	inc    %edx
  800cb1:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800cb5:	38 c8                	cmp    %cl,%al
  800cb7:	74 0a                	je     800cc3 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800cb9:	0f b6 c0             	movzbl %al,%eax
  800cbc:	0f b6 c9             	movzbl %cl,%ecx
  800cbf:	29 c8                	sub    %ecx,%eax
  800cc1:	eb 09                	jmp    800ccc <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cc3:	39 da                	cmp    %ebx,%edx
  800cc5:	75 e6                	jne    800cad <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800cc7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ccc:	5b                   	pop    %ebx
  800ccd:	5e                   	pop    %esi
  800cce:	5f                   	pop    %edi
  800ccf:	5d                   	pop    %ebp
  800cd0:	c3                   	ret    

00800cd1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cd1:	55                   	push   %ebp
  800cd2:	89 e5                	mov    %esp,%ebp
  800cd4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800cda:	89 c2                	mov    %eax,%edx
  800cdc:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cdf:	eb 05                	jmp    800ce6 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ce1:	38 08                	cmp    %cl,(%eax)
  800ce3:	74 05                	je     800cea <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ce5:	40                   	inc    %eax
  800ce6:	39 d0                	cmp    %edx,%eax
  800ce8:	72 f7                	jb     800ce1 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    

00800cec <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	57                   	push   %edi
  800cf0:	56                   	push   %esi
  800cf1:	53                   	push   %ebx
  800cf2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cf8:	eb 01                	jmp    800cfb <strtol+0xf>
		s++;
  800cfa:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cfb:	8a 02                	mov    (%edx),%al
  800cfd:	3c 20                	cmp    $0x20,%al
  800cff:	74 f9                	je     800cfa <strtol+0xe>
  800d01:	3c 09                	cmp    $0x9,%al
  800d03:	74 f5                	je     800cfa <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d05:	3c 2b                	cmp    $0x2b,%al
  800d07:	75 08                	jne    800d11 <strtol+0x25>
		s++;
  800d09:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d0a:	bf 00 00 00 00       	mov    $0x0,%edi
  800d0f:	eb 13                	jmp    800d24 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d11:	3c 2d                	cmp    $0x2d,%al
  800d13:	75 0a                	jne    800d1f <strtol+0x33>
		s++, neg = 1;
  800d15:	8d 52 01             	lea    0x1(%edx),%edx
  800d18:	bf 01 00 00 00       	mov    $0x1,%edi
  800d1d:	eb 05                	jmp    800d24 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d1f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d24:	85 db                	test   %ebx,%ebx
  800d26:	74 05                	je     800d2d <strtol+0x41>
  800d28:	83 fb 10             	cmp    $0x10,%ebx
  800d2b:	75 28                	jne    800d55 <strtol+0x69>
  800d2d:	8a 02                	mov    (%edx),%al
  800d2f:	3c 30                	cmp    $0x30,%al
  800d31:	75 10                	jne    800d43 <strtol+0x57>
  800d33:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d37:	75 0a                	jne    800d43 <strtol+0x57>
		s += 2, base = 16;
  800d39:	83 c2 02             	add    $0x2,%edx
  800d3c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d41:	eb 12                	jmp    800d55 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800d43:	85 db                	test   %ebx,%ebx
  800d45:	75 0e                	jne    800d55 <strtol+0x69>
  800d47:	3c 30                	cmp    $0x30,%al
  800d49:	75 05                	jne    800d50 <strtol+0x64>
		s++, base = 8;
  800d4b:	42                   	inc    %edx
  800d4c:	b3 08                	mov    $0x8,%bl
  800d4e:	eb 05                	jmp    800d55 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800d50:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800d55:	b8 00 00 00 00       	mov    $0x0,%eax
  800d5a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d5c:	8a 0a                	mov    (%edx),%cl
  800d5e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d61:	80 fb 09             	cmp    $0x9,%bl
  800d64:	77 08                	ja     800d6e <strtol+0x82>
			dig = *s - '0';
  800d66:	0f be c9             	movsbl %cl,%ecx
  800d69:	83 e9 30             	sub    $0x30,%ecx
  800d6c:	eb 1e                	jmp    800d8c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800d6e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d71:	80 fb 19             	cmp    $0x19,%bl
  800d74:	77 08                	ja     800d7e <strtol+0x92>
			dig = *s - 'a' + 10;
  800d76:	0f be c9             	movsbl %cl,%ecx
  800d79:	83 e9 57             	sub    $0x57,%ecx
  800d7c:	eb 0e                	jmp    800d8c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800d7e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d81:	80 fb 19             	cmp    $0x19,%bl
  800d84:	77 12                	ja     800d98 <strtol+0xac>
			dig = *s - 'A' + 10;
  800d86:	0f be c9             	movsbl %cl,%ecx
  800d89:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d8c:	39 f1                	cmp    %esi,%ecx
  800d8e:	7d 0c                	jge    800d9c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800d90:	42                   	inc    %edx
  800d91:	0f af c6             	imul   %esi,%eax
  800d94:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d96:	eb c4                	jmp    800d5c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d98:	89 c1                	mov    %eax,%ecx
  800d9a:	eb 02                	jmp    800d9e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d9c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d9e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800da2:	74 05                	je     800da9 <strtol+0xbd>
		*endptr = (char *) s;
  800da4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800da7:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800da9:	85 ff                	test   %edi,%edi
  800dab:	74 04                	je     800db1 <strtol+0xc5>
  800dad:	89 c8                	mov    %ecx,%eax
  800daf:	f7 d8                	neg    %eax
}
  800db1:	5b                   	pop    %ebx
  800db2:	5e                   	pop    %esi
  800db3:	5f                   	pop    %edi
  800db4:	5d                   	pop    %ebp
  800db5:	c3                   	ret    
	...

00800db8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800db8:	55                   	push   %ebp
  800db9:	57                   	push   %edi
  800dba:	56                   	push   %esi
  800dbb:	83 ec 10             	sub    $0x10,%esp
  800dbe:	8b 74 24 20          	mov    0x20(%esp),%esi
  800dc2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800dc6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800dca:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  800dce:	89 cd                	mov    %ecx,%ebp
  800dd0:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800dd4:	85 c0                	test   %eax,%eax
  800dd6:	75 2c                	jne    800e04 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800dd8:	39 f9                	cmp    %edi,%ecx
  800dda:	77 68                	ja     800e44 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800ddc:	85 c9                	test   %ecx,%ecx
  800dde:	75 0b                	jne    800deb <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800de0:	b8 01 00 00 00       	mov    $0x1,%eax
  800de5:	31 d2                	xor    %edx,%edx
  800de7:	f7 f1                	div    %ecx
  800de9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800deb:	31 d2                	xor    %edx,%edx
  800ded:	89 f8                	mov    %edi,%eax
  800def:	f7 f1                	div    %ecx
  800df1:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800df3:	89 f0                	mov    %esi,%eax
  800df5:	f7 f1                	div    %ecx
  800df7:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800df9:	89 f0                	mov    %esi,%eax
  800dfb:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800dfd:	83 c4 10             	add    $0x10,%esp
  800e00:	5e                   	pop    %esi
  800e01:	5f                   	pop    %edi
  800e02:	5d                   	pop    %ebp
  800e03:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e04:	39 f8                	cmp    %edi,%eax
  800e06:	77 2c                	ja     800e34 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e08:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  800e0b:	83 f6 1f             	xor    $0x1f,%esi
  800e0e:	75 4c                	jne    800e5c <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e10:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e12:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e17:	72 0a                	jb     800e23 <__udivdi3+0x6b>
  800e19:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800e1d:	0f 87 ad 00 00 00    	ja     800ed0 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e23:	be 01 00 00 00       	mov    $0x1,%esi
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
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e34:	31 ff                	xor    %edi,%edi
  800e36:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e38:	89 f0                	mov    %esi,%eax
  800e3a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e3c:	83 c4 10             	add    $0x10,%esp
  800e3f:	5e                   	pop    %esi
  800e40:	5f                   	pop    %edi
  800e41:	5d                   	pop    %ebp
  800e42:	c3                   	ret    
  800e43:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e44:	89 fa                	mov    %edi,%edx
  800e46:	89 f0                	mov    %esi,%eax
  800e48:	f7 f1                	div    %ecx
  800e4a:	89 c6                	mov    %eax,%esi
  800e4c:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e4e:	89 f0                	mov    %esi,%eax
  800e50:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e52:	83 c4 10             	add    $0x10,%esp
  800e55:	5e                   	pop    %esi
  800e56:	5f                   	pop    %edi
  800e57:	5d                   	pop    %ebp
  800e58:	c3                   	ret    
  800e59:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e5c:	89 f1                	mov    %esi,%ecx
  800e5e:	d3 e0                	shl    %cl,%eax
  800e60:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e64:	b8 20 00 00 00       	mov    $0x20,%eax
  800e69:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800e6b:	89 ea                	mov    %ebp,%edx
  800e6d:	88 c1                	mov    %al,%cl
  800e6f:	d3 ea                	shr    %cl,%edx
  800e71:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800e75:	09 ca                	or     %ecx,%edx
  800e77:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  800e7b:	89 f1                	mov    %esi,%ecx
  800e7d:	d3 e5                	shl    %cl,%ebp
  800e7f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  800e83:	89 fd                	mov    %edi,%ebp
  800e85:	88 c1                	mov    %al,%cl
  800e87:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  800e89:	89 fa                	mov    %edi,%edx
  800e8b:	89 f1                	mov    %esi,%ecx
  800e8d:	d3 e2                	shl    %cl,%edx
  800e8f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e93:	88 c1                	mov    %al,%cl
  800e95:	d3 ef                	shr    %cl,%edi
  800e97:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e99:	89 f8                	mov    %edi,%eax
  800e9b:	89 ea                	mov    %ebp,%edx
  800e9d:	f7 74 24 08          	divl   0x8(%esp)
  800ea1:	89 d1                	mov    %edx,%ecx
  800ea3:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  800ea5:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ea9:	39 d1                	cmp    %edx,%ecx
  800eab:	72 17                	jb     800ec4 <__udivdi3+0x10c>
  800ead:	74 09                	je     800eb8 <__udivdi3+0x100>
  800eaf:	89 fe                	mov    %edi,%esi
  800eb1:	31 ff                	xor    %edi,%edi
  800eb3:	e9 41 ff ff ff       	jmp    800df9 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800eb8:	8b 54 24 04          	mov    0x4(%esp),%edx
  800ebc:	89 f1                	mov    %esi,%ecx
  800ebe:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ec0:	39 c2                	cmp    %eax,%edx
  800ec2:	73 eb                	jae    800eaf <__udivdi3+0xf7>
		{
		  q0--;
  800ec4:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800ec7:	31 ff                	xor    %edi,%edi
  800ec9:	e9 2b ff ff ff       	jmp    800df9 <__udivdi3+0x41>
  800ece:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ed0:	31 f6                	xor    %esi,%esi
  800ed2:	e9 22 ff ff ff       	jmp    800df9 <__udivdi3+0x41>
	...

00800ed8 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800ed8:	55                   	push   %ebp
  800ed9:	57                   	push   %edi
  800eda:	56                   	push   %esi
  800edb:	83 ec 20             	sub    $0x20,%esp
  800ede:	8b 44 24 30          	mov    0x30(%esp),%eax
  800ee2:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800ee6:	89 44 24 14          	mov    %eax,0x14(%esp)
  800eea:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  800eee:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800ef2:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800ef6:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  800ef8:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800efa:	85 ed                	test   %ebp,%ebp
  800efc:	75 16                	jne    800f14 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  800efe:	39 f1                	cmp    %esi,%ecx
  800f00:	0f 86 a6 00 00 00    	jbe    800fac <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f06:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800f08:	89 d0                	mov    %edx,%eax
  800f0a:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f0c:	83 c4 20             	add    $0x20,%esp
  800f0f:	5e                   	pop    %esi
  800f10:	5f                   	pop    %edi
  800f11:	5d                   	pop    %ebp
  800f12:	c3                   	ret    
  800f13:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800f14:	39 f5                	cmp    %esi,%ebp
  800f16:	0f 87 ac 00 00 00    	ja     800fc8 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800f1c:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  800f1f:	83 f0 1f             	xor    $0x1f,%eax
  800f22:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f26:	0f 84 a8 00 00 00    	je     800fd4 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800f2c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f30:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800f32:	bf 20 00 00 00       	mov    $0x20,%edi
  800f37:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800f3b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f3f:	89 f9                	mov    %edi,%ecx
  800f41:	d3 e8                	shr    %cl,%eax
  800f43:	09 e8                	or     %ebp,%eax
  800f45:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  800f49:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f4d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f51:	d3 e0                	shl    %cl,%eax
  800f53:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800f57:	89 f2                	mov    %esi,%edx
  800f59:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800f5b:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f5f:	d3 e0                	shl    %cl,%eax
  800f61:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800f65:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f69:	89 f9                	mov    %edi,%ecx
  800f6b:	d3 e8                	shr    %cl,%eax
  800f6d:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800f6f:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800f71:	89 f2                	mov    %esi,%edx
  800f73:	f7 74 24 18          	divl   0x18(%esp)
  800f77:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800f79:	f7 64 24 0c          	mull   0xc(%esp)
  800f7d:	89 c5                	mov    %eax,%ebp
  800f7f:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f81:	39 d6                	cmp    %edx,%esi
  800f83:	72 67                	jb     800fec <__umoddi3+0x114>
  800f85:	74 75                	je     800ffc <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800f87:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800f8b:	29 e8                	sub    %ebp,%eax
  800f8d:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f8f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f93:	d3 e8                	shr    %cl,%eax
  800f95:	89 f2                	mov    %esi,%edx
  800f97:	89 f9                	mov    %edi,%ecx
  800f99:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800f9b:	09 d0                	or     %edx,%eax
  800f9d:	89 f2                	mov    %esi,%edx
  800f9f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800fa3:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800fa5:	83 c4 20             	add    $0x20,%esp
  800fa8:	5e                   	pop    %esi
  800fa9:	5f                   	pop    %edi
  800faa:	5d                   	pop    %ebp
  800fab:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800fac:	85 c9                	test   %ecx,%ecx
  800fae:	75 0b                	jne    800fbb <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800fb0:	b8 01 00 00 00       	mov    $0x1,%eax
  800fb5:	31 d2                	xor    %edx,%edx
  800fb7:	f7 f1                	div    %ecx
  800fb9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800fbb:	89 f0                	mov    %esi,%eax
  800fbd:	31 d2                	xor    %edx,%edx
  800fbf:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800fc1:	89 f8                	mov    %edi,%eax
  800fc3:	e9 3e ff ff ff       	jmp    800f06 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800fc8:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800fca:	83 c4 20             	add    $0x20,%esp
  800fcd:	5e                   	pop    %esi
  800fce:	5f                   	pop    %edi
  800fcf:	5d                   	pop    %ebp
  800fd0:	c3                   	ret    
  800fd1:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800fd4:	39 f5                	cmp    %esi,%ebp
  800fd6:	72 04                	jb     800fdc <__umoddi3+0x104>
  800fd8:	39 f9                	cmp    %edi,%ecx
  800fda:	77 06                	ja     800fe2 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800fdc:	89 f2                	mov    %esi,%edx
  800fde:	29 cf                	sub    %ecx,%edi
  800fe0:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800fe2:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800fe4:	83 c4 20             	add    $0x20,%esp
  800fe7:	5e                   	pop    %esi
  800fe8:	5f                   	pop    %edi
  800fe9:	5d                   	pop    %ebp
  800fea:	c3                   	ret    
  800feb:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800fec:	89 d1                	mov    %edx,%ecx
  800fee:	89 c5                	mov    %eax,%ebp
  800ff0:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800ff4:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800ff8:	eb 8d                	jmp    800f87 <__umoddi3+0xaf>
  800ffa:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ffc:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801000:	72 ea                	jb     800fec <__umoddi3+0x114>
  801002:	89 f1                	mov    %esi,%ecx
  801004:	eb 81                	jmp    800f87 <__umoddi3+0xaf>
