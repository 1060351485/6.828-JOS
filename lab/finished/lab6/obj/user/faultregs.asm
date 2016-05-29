
obj/user/faultregs.debug:     file format elf32-i386


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
  80002c:	e8 2f 05 00 00       	call   800560 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 1c             	sub    $0x1c,%esp
  80003d:	89 c3                	mov    %eax,%ebx
  80003f:	89 ce                	mov    %ecx,%esi
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800041:	8b 45 08             	mov    0x8(%ebp),%eax
  800044:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800048:	89 54 24 08          	mov    %edx,0x8(%esp)
  80004c:	c7 44 24 04 71 16 80 	movl   $0x801671,0x4(%esp)
  800053:	00 
  800054:	c7 04 24 40 16 80 00 	movl   $0x801640,(%esp)
  80005b:	e8 54 06 00 00       	call   8006b4 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800060:	8b 06                	mov    (%esi),%eax
  800062:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800066:	8b 03                	mov    (%ebx),%eax
  800068:	89 44 24 08          	mov    %eax,0x8(%esp)
  80006c:	c7 44 24 04 50 16 80 	movl   $0x801650,0x4(%esp)
  800073:	00 
  800074:	c7 04 24 54 16 80 00 	movl   $0x801654,(%esp)
  80007b:	e8 34 06 00 00       	call   8006b4 <cprintf>
  800080:	8b 06                	mov    (%esi),%eax
  800082:	39 03                	cmp    %eax,(%ebx)
  800084:	75 13                	jne    800099 <check_regs+0x65>
  800086:	c7 04 24 64 16 80 00 	movl   $0x801664,(%esp)
  80008d:	e8 22 06 00 00       	call   8006b4 <cprintf>

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
	int mismatch = 0;
  800092:	bf 00 00 00 00       	mov    $0x0,%edi
  800097:	eb 11                	jmp    8000aa <check_regs+0x76>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800099:	c7 04 24 68 16 80 00 	movl   $0x801668,(%esp)
  8000a0:	e8 0f 06 00 00       	call   8006b4 <cprintf>
  8000a5:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  8000aa:	8b 46 04             	mov    0x4(%esi),%eax
  8000ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b1:	8b 43 04             	mov    0x4(%ebx),%eax
  8000b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000b8:	c7 44 24 04 72 16 80 	movl   $0x801672,0x4(%esp)
  8000bf:	00 
  8000c0:	c7 04 24 54 16 80 00 	movl   $0x801654,(%esp)
  8000c7:	e8 e8 05 00 00       	call   8006b4 <cprintf>
  8000cc:	8b 46 04             	mov    0x4(%esi),%eax
  8000cf:	39 43 04             	cmp    %eax,0x4(%ebx)
  8000d2:	75 0e                	jne    8000e2 <check_regs+0xae>
  8000d4:	c7 04 24 64 16 80 00 	movl   $0x801664,(%esp)
  8000db:	e8 d4 05 00 00       	call   8006b4 <cprintf>
  8000e0:	eb 11                	jmp    8000f3 <check_regs+0xbf>
  8000e2:	c7 04 24 68 16 80 00 	movl   $0x801668,(%esp)
  8000e9:	e8 c6 05 00 00       	call   8006b4 <cprintf>
  8000ee:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000f3:	8b 46 08             	mov    0x8(%esi),%eax
  8000f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000fa:	8b 43 08             	mov    0x8(%ebx),%eax
  8000fd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800101:	c7 44 24 04 76 16 80 	movl   $0x801676,0x4(%esp)
  800108:	00 
  800109:	c7 04 24 54 16 80 00 	movl   $0x801654,(%esp)
  800110:	e8 9f 05 00 00       	call   8006b4 <cprintf>
  800115:	8b 46 08             	mov    0x8(%esi),%eax
  800118:	39 43 08             	cmp    %eax,0x8(%ebx)
  80011b:	75 0e                	jne    80012b <check_regs+0xf7>
  80011d:	c7 04 24 64 16 80 00 	movl   $0x801664,(%esp)
  800124:	e8 8b 05 00 00       	call   8006b4 <cprintf>
  800129:	eb 11                	jmp    80013c <check_regs+0x108>
  80012b:	c7 04 24 68 16 80 00 	movl   $0x801668,(%esp)
  800132:	e8 7d 05 00 00       	call   8006b4 <cprintf>
  800137:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  80013c:	8b 46 10             	mov    0x10(%esi),%eax
  80013f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800143:	8b 43 10             	mov    0x10(%ebx),%eax
  800146:	89 44 24 08          	mov    %eax,0x8(%esp)
  80014a:	c7 44 24 04 7a 16 80 	movl   $0x80167a,0x4(%esp)
  800151:	00 
  800152:	c7 04 24 54 16 80 00 	movl   $0x801654,(%esp)
  800159:	e8 56 05 00 00       	call   8006b4 <cprintf>
  80015e:	8b 46 10             	mov    0x10(%esi),%eax
  800161:	39 43 10             	cmp    %eax,0x10(%ebx)
  800164:	75 0e                	jne    800174 <check_regs+0x140>
  800166:	c7 04 24 64 16 80 00 	movl   $0x801664,(%esp)
  80016d:	e8 42 05 00 00       	call   8006b4 <cprintf>
  800172:	eb 11                	jmp    800185 <check_regs+0x151>
  800174:	c7 04 24 68 16 80 00 	movl   $0x801668,(%esp)
  80017b:	e8 34 05 00 00       	call   8006b4 <cprintf>
  800180:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800185:	8b 46 14             	mov    0x14(%esi),%eax
  800188:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80018c:	8b 43 14             	mov    0x14(%ebx),%eax
  80018f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800193:	c7 44 24 04 7e 16 80 	movl   $0x80167e,0x4(%esp)
  80019a:	00 
  80019b:	c7 04 24 54 16 80 00 	movl   $0x801654,(%esp)
  8001a2:	e8 0d 05 00 00       	call   8006b4 <cprintf>
  8001a7:	8b 46 14             	mov    0x14(%esi),%eax
  8001aa:	39 43 14             	cmp    %eax,0x14(%ebx)
  8001ad:	75 0e                	jne    8001bd <check_regs+0x189>
  8001af:	c7 04 24 64 16 80 00 	movl   $0x801664,(%esp)
  8001b6:	e8 f9 04 00 00       	call   8006b4 <cprintf>
  8001bb:	eb 11                	jmp    8001ce <check_regs+0x19a>
  8001bd:	c7 04 24 68 16 80 00 	movl   $0x801668,(%esp)
  8001c4:	e8 eb 04 00 00       	call   8006b4 <cprintf>
  8001c9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001ce:	8b 46 18             	mov    0x18(%esi),%eax
  8001d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d5:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001dc:	c7 44 24 04 82 16 80 	movl   $0x801682,0x4(%esp)
  8001e3:	00 
  8001e4:	c7 04 24 54 16 80 00 	movl   $0x801654,(%esp)
  8001eb:	e8 c4 04 00 00       	call   8006b4 <cprintf>
  8001f0:	8b 46 18             	mov    0x18(%esi),%eax
  8001f3:	39 43 18             	cmp    %eax,0x18(%ebx)
  8001f6:	75 0e                	jne    800206 <check_regs+0x1d2>
  8001f8:	c7 04 24 64 16 80 00 	movl   $0x801664,(%esp)
  8001ff:	e8 b0 04 00 00       	call   8006b4 <cprintf>
  800204:	eb 11                	jmp    800217 <check_regs+0x1e3>
  800206:	c7 04 24 68 16 80 00 	movl   $0x801668,(%esp)
  80020d:	e8 a2 04 00 00       	call   8006b4 <cprintf>
  800212:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  800217:	8b 46 1c             	mov    0x1c(%esi),%eax
  80021a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80021e:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800221:	89 44 24 08          	mov    %eax,0x8(%esp)
  800225:	c7 44 24 04 86 16 80 	movl   $0x801686,0x4(%esp)
  80022c:	00 
  80022d:	c7 04 24 54 16 80 00 	movl   $0x801654,(%esp)
  800234:	e8 7b 04 00 00       	call   8006b4 <cprintf>
  800239:	8b 46 1c             	mov    0x1c(%esi),%eax
  80023c:	39 43 1c             	cmp    %eax,0x1c(%ebx)
  80023f:	75 0e                	jne    80024f <check_regs+0x21b>
  800241:	c7 04 24 64 16 80 00 	movl   $0x801664,(%esp)
  800248:	e8 67 04 00 00       	call   8006b4 <cprintf>
  80024d:	eb 11                	jmp    800260 <check_regs+0x22c>
  80024f:	c7 04 24 68 16 80 00 	movl   $0x801668,(%esp)
  800256:	e8 59 04 00 00       	call   8006b4 <cprintf>
  80025b:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  800260:	8b 46 20             	mov    0x20(%esi),%eax
  800263:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800267:	8b 43 20             	mov    0x20(%ebx),%eax
  80026a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80026e:	c7 44 24 04 8a 16 80 	movl   $0x80168a,0x4(%esp)
  800275:	00 
  800276:	c7 04 24 54 16 80 00 	movl   $0x801654,(%esp)
  80027d:	e8 32 04 00 00       	call   8006b4 <cprintf>
  800282:	8b 46 20             	mov    0x20(%esi),%eax
  800285:	39 43 20             	cmp    %eax,0x20(%ebx)
  800288:	75 0e                	jne    800298 <check_regs+0x264>
  80028a:	c7 04 24 64 16 80 00 	movl   $0x801664,(%esp)
  800291:	e8 1e 04 00 00       	call   8006b4 <cprintf>
  800296:	eb 11                	jmp    8002a9 <check_regs+0x275>
  800298:	c7 04 24 68 16 80 00 	movl   $0x801668,(%esp)
  80029f:	e8 10 04 00 00       	call   8006b4 <cprintf>
  8002a4:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  8002a9:	8b 46 24             	mov    0x24(%esi),%eax
  8002ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002b0:	8b 43 24             	mov    0x24(%ebx),%eax
  8002b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b7:	c7 44 24 04 8e 16 80 	movl   $0x80168e,0x4(%esp)
  8002be:	00 
  8002bf:	c7 04 24 54 16 80 00 	movl   $0x801654,(%esp)
  8002c6:	e8 e9 03 00 00       	call   8006b4 <cprintf>
  8002cb:	8b 46 24             	mov    0x24(%esi),%eax
  8002ce:	39 43 24             	cmp    %eax,0x24(%ebx)
  8002d1:	75 0e                	jne    8002e1 <check_regs+0x2ad>
  8002d3:	c7 04 24 64 16 80 00 	movl   $0x801664,(%esp)
  8002da:	e8 d5 03 00 00       	call   8006b4 <cprintf>
  8002df:	eb 11                	jmp    8002f2 <check_regs+0x2be>
  8002e1:	c7 04 24 68 16 80 00 	movl   $0x801668,(%esp)
  8002e8:	e8 c7 03 00 00       	call   8006b4 <cprintf>
  8002ed:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esp, esp);
  8002f2:	8b 46 28             	mov    0x28(%esi),%eax
  8002f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002f9:	8b 43 28             	mov    0x28(%ebx),%eax
  8002fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800300:	c7 44 24 04 95 16 80 	movl   $0x801695,0x4(%esp)
  800307:	00 
  800308:	c7 04 24 54 16 80 00 	movl   $0x801654,(%esp)
  80030f:	e8 a0 03 00 00       	call   8006b4 <cprintf>
  800314:	8b 46 28             	mov    0x28(%esi),%eax
  800317:	39 43 28             	cmp    %eax,0x28(%ebx)
  80031a:	75 25                	jne    800341 <check_regs+0x30d>
  80031c:	c7 04 24 64 16 80 00 	movl   $0x801664,(%esp)
  800323:	e8 8c 03 00 00       	call   8006b4 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800328:	8b 45 0c             	mov    0xc(%ebp),%eax
  80032b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032f:	c7 04 24 99 16 80 00 	movl   $0x801699,(%esp)
  800336:	e8 79 03 00 00       	call   8006b4 <cprintf>
	if (!mismatch)
  80033b:	85 ff                	test   %edi,%edi
  80033d:	74 23                	je     800362 <check_regs+0x32e>
  80033f:	eb 2f                	jmp    800370 <check_regs+0x33c>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800341:	c7 04 24 68 16 80 00 	movl   $0x801668,(%esp)
  800348:	e8 67 03 00 00       	call   8006b4 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  80034d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800350:	89 44 24 04          	mov    %eax,0x4(%esp)
  800354:	c7 04 24 99 16 80 00 	movl   $0x801699,(%esp)
  80035b:	e8 54 03 00 00       	call   8006b4 <cprintf>
  800360:	eb 0e                	jmp    800370 <check_regs+0x33c>
	if (!mismatch)
		cprintf("OK\n");
  800362:	c7 04 24 64 16 80 00 	movl   $0x801664,(%esp)
  800369:	e8 46 03 00 00       	call   8006b4 <cprintf>
  80036e:	eb 0c                	jmp    80037c <check_regs+0x348>
	else
		cprintf("MISMATCH\n");
  800370:	c7 04 24 68 16 80 00 	movl   $0x801668,(%esp)
  800377:	e8 38 03 00 00       	call   8006b4 <cprintf>
}
  80037c:	83 c4 1c             	add    $0x1c,%esp
  80037f:	5b                   	pop    %ebx
  800380:	5e                   	pop    %esi
  800381:	5f                   	pop    %edi
  800382:	5d                   	pop    %ebp
  800383:	c3                   	ret    

00800384 <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	57                   	push   %edi
  800388:	56                   	push   %esi
  800389:	83 ec 20             	sub    $0x20,%esp
  80038c:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  80038f:	8b 10                	mov    (%eax),%edx
  800391:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  800397:	74 27                	je     8003c0 <pgfault+0x3c>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  800399:	8b 40 28             	mov    0x28(%eax),%eax
  80039c:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003a0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003a4:	c7 44 24 08 00 17 80 	movl   $0x801700,0x8(%esp)
  8003ab:	00 
  8003ac:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8003b3:	00 
  8003b4:	c7 04 24 a7 16 80 00 	movl   $0x8016a7,(%esp)
  8003bb:	e8 fc 01 00 00       	call   8005bc <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003c0:	bf a0 20 80 00       	mov    $0x8020a0,%edi
  8003c5:	8d 70 08             	lea    0x8(%eax),%esi
  8003c8:	b9 08 00 00 00       	mov    $0x8,%ecx
  8003cd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	during.eip = utf->utf_eip;
  8003cf:	8b 50 28             	mov    0x28(%eax),%edx
  8003d2:	89 17                	mov    %edx,(%edi)
	during.eflags = utf->utf_eflags;
  8003d4:	8b 50 2c             	mov    0x2c(%eax),%edx
  8003d7:	89 15 c4 20 80 00    	mov    %edx,0x8020c4
	during.esp = utf->utf_esp;
  8003dd:	8b 40 30             	mov    0x30(%eax),%eax
  8003e0:	a3 c8 20 80 00       	mov    %eax,0x8020c8
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  8003e5:	c7 44 24 04 bf 16 80 	movl   $0x8016bf,0x4(%esp)
  8003ec:	00 
  8003ed:	c7 04 24 cd 16 80 00 	movl   $0x8016cd,(%esp)
  8003f4:	b9 a0 20 80 00       	mov    $0x8020a0,%ecx
  8003f9:	ba b8 16 80 00       	mov    $0x8016b8,%edx
  8003fe:	b8 20 20 80 00       	mov    $0x802020,%eax
  800403:	e8 2c fc ff ff       	call   800034 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800408:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80040f:	00 
  800410:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  800417:	00 
  800418:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80041f:	e8 2d 0c 00 00       	call   801051 <sys_page_alloc>
  800424:	85 c0                	test   %eax,%eax
  800426:	79 20                	jns    800448 <pgfault+0xc4>
		panic("sys_page_alloc: %e", r);
  800428:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80042c:	c7 44 24 08 d4 16 80 	movl   $0x8016d4,0x8(%esp)
  800433:	00 
  800434:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  80043b:	00 
  80043c:	c7 04 24 a7 16 80 00 	movl   $0x8016a7,(%esp)
  800443:	e8 74 01 00 00       	call   8005bc <_panic>
}
  800448:	83 c4 20             	add    $0x20,%esp
  80044b:	5e                   	pop    %esi
  80044c:	5f                   	pop    %edi
  80044d:	5d                   	pop    %ebp
  80044e:	c3                   	ret    

0080044f <umain>:

void
umain(int argc, char **argv)
{
  80044f:	55                   	push   %ebp
  800450:	89 e5                	mov    %esp,%ebp
  800452:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(pgfault);
  800455:	c7 04 24 84 03 80 00 	movl   $0x800384,(%esp)
  80045c:	e8 db 0e 00 00       	call   80133c <set_pgfault_handler>

	__asm __volatile(
  800461:	50                   	push   %eax
  800462:	9c                   	pushf  
  800463:	58                   	pop    %eax
  800464:	0d d5 08 00 00       	or     $0x8d5,%eax
  800469:	50                   	push   %eax
  80046a:	9d                   	popf   
  80046b:	a3 44 20 80 00       	mov    %eax,0x802044
  800470:	8d 05 ab 04 80 00    	lea    0x8004ab,%eax
  800476:	a3 40 20 80 00       	mov    %eax,0x802040
  80047b:	58                   	pop    %eax
  80047c:	89 3d 20 20 80 00    	mov    %edi,0x802020
  800482:	89 35 24 20 80 00    	mov    %esi,0x802024
  800488:	89 2d 28 20 80 00    	mov    %ebp,0x802028
  80048e:	89 1d 30 20 80 00    	mov    %ebx,0x802030
  800494:	89 15 34 20 80 00    	mov    %edx,0x802034
  80049a:	89 0d 38 20 80 00    	mov    %ecx,0x802038
  8004a0:	a3 3c 20 80 00       	mov    %eax,0x80203c
  8004a5:	89 25 48 20 80 00    	mov    %esp,0x802048
  8004ab:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8004b2:	00 00 00 
  8004b5:	89 3d 60 20 80 00    	mov    %edi,0x802060
  8004bb:	89 35 64 20 80 00    	mov    %esi,0x802064
  8004c1:	89 2d 68 20 80 00    	mov    %ebp,0x802068
  8004c7:	89 1d 70 20 80 00    	mov    %ebx,0x802070
  8004cd:	89 15 74 20 80 00    	mov    %edx,0x802074
  8004d3:	89 0d 78 20 80 00    	mov    %ecx,0x802078
  8004d9:	a3 7c 20 80 00       	mov    %eax,0x80207c
  8004de:	89 25 88 20 80 00    	mov    %esp,0x802088
  8004e4:	8b 3d 20 20 80 00    	mov    0x802020,%edi
  8004ea:	8b 35 24 20 80 00    	mov    0x802024,%esi
  8004f0:	8b 2d 28 20 80 00    	mov    0x802028,%ebp
  8004f6:	8b 1d 30 20 80 00    	mov    0x802030,%ebx
  8004fc:	8b 15 34 20 80 00    	mov    0x802034,%edx
  800502:	8b 0d 38 20 80 00    	mov    0x802038,%ecx
  800508:	a1 3c 20 80 00       	mov    0x80203c,%eax
  80050d:	8b 25 48 20 80 00    	mov    0x802048,%esp
  800513:	50                   	push   %eax
  800514:	9c                   	pushf  
  800515:	58                   	pop    %eax
  800516:	a3 84 20 80 00       	mov    %eax,0x802084
  80051b:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  80051c:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  800523:	74 0c                	je     800531 <umain+0xe2>
		cprintf("EIP after page-fault MISMATCH\n");
  800525:	c7 04 24 34 17 80 00 	movl   $0x801734,(%esp)
  80052c:	e8 83 01 00 00       	call   8006b4 <cprintf>
	after.eip = before.eip;
  800531:	a1 40 20 80 00       	mov    0x802040,%eax
  800536:	a3 80 20 80 00       	mov    %eax,0x802080

	check_regs(&before, "before", &after, "after", "after page-fault");
  80053b:	c7 44 24 04 e7 16 80 	movl   $0x8016e7,0x4(%esp)
  800542:	00 
  800543:	c7 04 24 f8 16 80 00 	movl   $0x8016f8,(%esp)
  80054a:	b9 60 20 80 00       	mov    $0x802060,%ecx
  80054f:	ba b8 16 80 00       	mov    $0x8016b8,%edx
  800554:	b8 20 20 80 00       	mov    $0x802020,%eax
  800559:	e8 d6 fa ff ff       	call   800034 <check_regs>
}
  80055e:	c9                   	leave  
  80055f:	c3                   	ret    

00800560 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800560:	55                   	push   %ebp
  800561:	89 e5                	mov    %esp,%ebp
  800563:	56                   	push   %esi
  800564:	53                   	push   %ebx
  800565:	83 ec 10             	sub    $0x10,%esp
  800568:	8b 75 08             	mov    0x8(%ebp),%esi
  80056b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80056e:	e8 a0 0a 00 00       	call   801013 <sys_getenvid>
  800573:	25 ff 03 00 00       	and    $0x3ff,%eax
  800578:	c1 e0 07             	shl    $0x7,%eax
  80057b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800580:	a3 cc 20 80 00       	mov    %eax,0x8020cc

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800585:	85 f6                	test   %esi,%esi
  800587:	7e 07                	jle    800590 <libmain+0x30>
		binaryname = argv[0];
  800589:	8b 03                	mov    (%ebx),%eax
  80058b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800590:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800594:	89 34 24             	mov    %esi,(%esp)
  800597:	e8 b3 fe ff ff       	call   80044f <umain>

	// exit gracefully
	exit();
  80059c:	e8 07 00 00 00       	call   8005a8 <exit>
}
  8005a1:	83 c4 10             	add    $0x10,%esp
  8005a4:	5b                   	pop    %ebx
  8005a5:	5e                   	pop    %esi
  8005a6:	5d                   	pop    %ebp
  8005a7:	c3                   	ret    

008005a8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8005a8:	55                   	push   %ebp
  8005a9:	89 e5                	mov    %esp,%ebp
  8005ab:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  8005ae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8005b5:	e8 07 0a 00 00       	call   800fc1 <sys_env_destroy>
}
  8005ba:	c9                   	leave  
  8005bb:	c3                   	ret    

008005bc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005bc:	55                   	push   %ebp
  8005bd:	89 e5                	mov    %esp,%ebp
  8005bf:	56                   	push   %esi
  8005c0:	53                   	push   %ebx
  8005c1:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8005c4:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8005c7:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8005cd:	e8 41 0a 00 00       	call   801013 <sys_getenvid>
  8005d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005d5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8005d9:	8b 55 08             	mov    0x8(%ebp),%edx
  8005dc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005e0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e8:	c7 04 24 60 17 80 00 	movl   $0x801760,(%esp)
  8005ef:	e8 c0 00 00 00       	call   8006b4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8005f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8005fb:	89 04 24             	mov    %eax,(%esp)
  8005fe:	e8 50 00 00 00       	call   800653 <vcprintf>
	cprintf("\n");
  800603:	c7 04 24 70 16 80 00 	movl   $0x801670,(%esp)
  80060a:	e8 a5 00 00 00       	call   8006b4 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80060f:	cc                   	int3   
  800610:	eb fd                	jmp    80060f <_panic+0x53>
	...

00800614 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800614:	55                   	push   %ebp
  800615:	89 e5                	mov    %esp,%ebp
  800617:	53                   	push   %ebx
  800618:	83 ec 14             	sub    $0x14,%esp
  80061b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80061e:	8b 03                	mov    (%ebx),%eax
  800620:	8b 55 08             	mov    0x8(%ebp),%edx
  800623:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800627:	40                   	inc    %eax
  800628:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80062a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80062f:	75 19                	jne    80064a <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800631:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800638:	00 
  800639:	8d 43 08             	lea    0x8(%ebx),%eax
  80063c:	89 04 24             	mov    %eax,(%esp)
  80063f:	e8 40 09 00 00       	call   800f84 <sys_cputs>
		b->idx = 0;
  800644:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80064a:	ff 43 04             	incl   0x4(%ebx)
}
  80064d:	83 c4 14             	add    $0x14,%esp
  800650:	5b                   	pop    %ebx
  800651:	5d                   	pop    %ebp
  800652:	c3                   	ret    

00800653 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800653:	55                   	push   %ebp
  800654:	89 e5                	mov    %esp,%ebp
  800656:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80065c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800663:	00 00 00 
	b.cnt = 0;
  800666:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80066d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800670:	8b 45 0c             	mov    0xc(%ebp),%eax
  800673:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800677:	8b 45 08             	mov    0x8(%ebp),%eax
  80067a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80067e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800684:	89 44 24 04          	mov    %eax,0x4(%esp)
  800688:	c7 04 24 14 06 80 00 	movl   $0x800614,(%esp)
  80068f:	e8 82 01 00 00       	call   800816 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800694:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80069a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80069e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006a4:	89 04 24             	mov    %eax,(%esp)
  8006a7:	e8 d8 08 00 00       	call   800f84 <sys_cputs>

	return b.cnt;
}
  8006ac:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006b2:	c9                   	leave  
  8006b3:	c3                   	ret    

008006b4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006b4:	55                   	push   %ebp
  8006b5:	89 e5                	mov    %esp,%ebp
  8006b7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006ba:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8006bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c4:	89 04 24             	mov    %eax,(%esp)
  8006c7:	e8 87 ff ff ff       	call   800653 <vcprintf>
	va_end(ap);

	return cnt;
}
  8006cc:	c9                   	leave  
  8006cd:	c3                   	ret    
	...

008006d0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8006d0:	55                   	push   %ebp
  8006d1:	89 e5                	mov    %esp,%ebp
  8006d3:	57                   	push   %edi
  8006d4:	56                   	push   %esi
  8006d5:	53                   	push   %ebx
  8006d6:	83 ec 3c             	sub    $0x3c,%esp
  8006d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006dc:	89 d7                	mov    %edx,%edi
  8006de:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006e7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006ea:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8006ed:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8006f0:	85 c0                	test   %eax,%eax
  8006f2:	75 08                	jne    8006fc <printnum+0x2c>
  8006f4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8006f7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8006fa:	77 57                	ja     800753 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8006fc:	89 74 24 10          	mov    %esi,0x10(%esp)
  800700:	4b                   	dec    %ebx
  800701:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800705:	8b 45 10             	mov    0x10(%ebp),%eax
  800708:	89 44 24 08          	mov    %eax,0x8(%esp)
  80070c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800710:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800714:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80071b:	00 
  80071c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80071f:	89 04 24             	mov    %eax,(%esp)
  800722:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800725:	89 44 24 04          	mov    %eax,0x4(%esp)
  800729:	e8 a6 0c 00 00       	call   8013d4 <__udivdi3>
  80072e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800732:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800736:	89 04 24             	mov    %eax,(%esp)
  800739:	89 54 24 04          	mov    %edx,0x4(%esp)
  80073d:	89 fa                	mov    %edi,%edx
  80073f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800742:	e8 89 ff ff ff       	call   8006d0 <printnum>
  800747:	eb 0f                	jmp    800758 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800749:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80074d:	89 34 24             	mov    %esi,(%esp)
  800750:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800753:	4b                   	dec    %ebx
  800754:	85 db                	test   %ebx,%ebx
  800756:	7f f1                	jg     800749 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800758:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80075c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800760:	8b 45 10             	mov    0x10(%ebp),%eax
  800763:	89 44 24 08          	mov    %eax,0x8(%esp)
  800767:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80076e:	00 
  80076f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800772:	89 04 24             	mov    %eax,(%esp)
  800775:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800778:	89 44 24 04          	mov    %eax,0x4(%esp)
  80077c:	e8 73 0d 00 00       	call   8014f4 <__umoddi3>
  800781:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800785:	0f be 80 83 17 80 00 	movsbl 0x801783(%eax),%eax
  80078c:	89 04 24             	mov    %eax,(%esp)
  80078f:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800792:	83 c4 3c             	add    $0x3c,%esp
  800795:	5b                   	pop    %ebx
  800796:	5e                   	pop    %esi
  800797:	5f                   	pop    %edi
  800798:	5d                   	pop    %ebp
  800799:	c3                   	ret    

0080079a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80079a:	55                   	push   %ebp
  80079b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80079d:	83 fa 01             	cmp    $0x1,%edx
  8007a0:	7e 0e                	jle    8007b0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8007a2:	8b 10                	mov    (%eax),%edx
  8007a4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8007a7:	89 08                	mov    %ecx,(%eax)
  8007a9:	8b 02                	mov    (%edx),%eax
  8007ab:	8b 52 04             	mov    0x4(%edx),%edx
  8007ae:	eb 22                	jmp    8007d2 <getuint+0x38>
	else if (lflag)
  8007b0:	85 d2                	test   %edx,%edx
  8007b2:	74 10                	je     8007c4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8007b4:	8b 10                	mov    (%eax),%edx
  8007b6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007b9:	89 08                	mov    %ecx,(%eax)
  8007bb:	8b 02                	mov    (%edx),%eax
  8007bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8007c2:	eb 0e                	jmp    8007d2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8007c4:	8b 10                	mov    (%eax),%edx
  8007c6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007c9:	89 08                	mov    %ecx,(%eax)
  8007cb:	8b 02                	mov    (%edx),%eax
  8007cd:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007d2:	5d                   	pop    %ebp
  8007d3:	c3                   	ret    

008007d4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007d4:	55                   	push   %ebp
  8007d5:	89 e5                	mov    %esp,%ebp
  8007d7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007da:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8007dd:	8b 10                	mov    (%eax),%edx
  8007df:	3b 50 04             	cmp    0x4(%eax),%edx
  8007e2:	73 08                	jae    8007ec <sprintputch+0x18>
		*b->buf++ = ch;
  8007e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e7:	88 0a                	mov    %cl,(%edx)
  8007e9:	42                   	inc    %edx
  8007ea:	89 10                	mov    %edx,(%eax)
}
  8007ec:	5d                   	pop    %ebp
  8007ed:	c3                   	ret    

008007ee <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007ee:	55                   	push   %ebp
  8007ef:	89 e5                	mov    %esp,%ebp
  8007f1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8007f4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007f7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007fb:	8b 45 10             	mov    0x10(%ebp),%eax
  8007fe:	89 44 24 08          	mov    %eax,0x8(%esp)
  800802:	8b 45 0c             	mov    0xc(%ebp),%eax
  800805:	89 44 24 04          	mov    %eax,0x4(%esp)
  800809:	8b 45 08             	mov    0x8(%ebp),%eax
  80080c:	89 04 24             	mov    %eax,(%esp)
  80080f:	e8 02 00 00 00       	call   800816 <vprintfmt>
	va_end(ap);
}
  800814:	c9                   	leave  
  800815:	c3                   	ret    

00800816 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800816:	55                   	push   %ebp
  800817:	89 e5                	mov    %esp,%ebp
  800819:	57                   	push   %edi
  80081a:	56                   	push   %esi
  80081b:	53                   	push   %ebx
  80081c:	83 ec 4c             	sub    $0x4c,%esp
  80081f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800822:	8b 75 10             	mov    0x10(%ebp),%esi
  800825:	eb 12                	jmp    800839 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800827:	85 c0                	test   %eax,%eax
  800829:	0f 84 6b 03 00 00    	je     800b9a <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80082f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800833:	89 04 24             	mov    %eax,(%esp)
  800836:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800839:	0f b6 06             	movzbl (%esi),%eax
  80083c:	46                   	inc    %esi
  80083d:	83 f8 25             	cmp    $0x25,%eax
  800840:	75 e5                	jne    800827 <vprintfmt+0x11>
  800842:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800846:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80084d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800852:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800859:	b9 00 00 00 00       	mov    $0x0,%ecx
  80085e:	eb 26                	jmp    800886 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800860:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800863:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800867:	eb 1d                	jmp    800886 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800869:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80086c:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800870:	eb 14                	jmp    800886 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800872:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800875:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80087c:	eb 08                	jmp    800886 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80087e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800881:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800886:	0f b6 06             	movzbl (%esi),%eax
  800889:	8d 56 01             	lea    0x1(%esi),%edx
  80088c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80088f:	8a 16                	mov    (%esi),%dl
  800891:	83 ea 23             	sub    $0x23,%edx
  800894:	80 fa 55             	cmp    $0x55,%dl
  800897:	0f 87 e1 02 00 00    	ja     800b7e <vprintfmt+0x368>
  80089d:	0f b6 d2             	movzbl %dl,%edx
  8008a0:	ff 24 95 c0 18 80 00 	jmp    *0x8018c0(,%edx,4)
  8008a7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008aa:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8008af:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8008b2:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8008b6:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8008b9:	8d 50 d0             	lea    -0x30(%eax),%edx
  8008bc:	83 fa 09             	cmp    $0x9,%edx
  8008bf:	77 2a                	ja     8008eb <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8008c1:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8008c2:	eb eb                	jmp    8008af <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c7:	8d 50 04             	lea    0x4(%eax),%edx
  8008ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8008cd:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008cf:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008d2:	eb 17                	jmp    8008eb <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8008d4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008d8:	78 98                	js     800872 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008da:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008dd:	eb a7                	jmp    800886 <vprintfmt+0x70>
  8008df:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008e2:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8008e9:	eb 9b                	jmp    800886 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8008eb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008ef:	79 95                	jns    800886 <vprintfmt+0x70>
  8008f1:	eb 8b                	jmp    80087e <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8008f3:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008f4:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8008f7:	eb 8d                	jmp    800886 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8008f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8008fc:	8d 50 04             	lea    0x4(%eax),%edx
  8008ff:	89 55 14             	mov    %edx,0x14(%ebp)
  800902:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800906:	8b 00                	mov    (%eax),%eax
  800908:	89 04 24             	mov    %eax,(%esp)
  80090b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80090e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800911:	e9 23 ff ff ff       	jmp    800839 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800916:	8b 45 14             	mov    0x14(%ebp),%eax
  800919:	8d 50 04             	lea    0x4(%eax),%edx
  80091c:	89 55 14             	mov    %edx,0x14(%ebp)
  80091f:	8b 00                	mov    (%eax),%eax
  800921:	85 c0                	test   %eax,%eax
  800923:	79 02                	jns    800927 <vprintfmt+0x111>
  800925:	f7 d8                	neg    %eax
  800927:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800929:	83 f8 11             	cmp    $0x11,%eax
  80092c:	7f 0b                	jg     800939 <vprintfmt+0x123>
  80092e:	8b 04 85 20 1a 80 00 	mov    0x801a20(,%eax,4),%eax
  800935:	85 c0                	test   %eax,%eax
  800937:	75 23                	jne    80095c <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800939:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80093d:	c7 44 24 08 9b 17 80 	movl   $0x80179b,0x8(%esp)
  800944:	00 
  800945:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800949:	8b 45 08             	mov    0x8(%ebp),%eax
  80094c:	89 04 24             	mov    %eax,(%esp)
  80094f:	e8 9a fe ff ff       	call   8007ee <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800954:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800957:	e9 dd fe ff ff       	jmp    800839 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80095c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800960:	c7 44 24 08 a4 17 80 	movl   $0x8017a4,0x8(%esp)
  800967:	00 
  800968:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80096c:	8b 55 08             	mov    0x8(%ebp),%edx
  80096f:	89 14 24             	mov    %edx,(%esp)
  800972:	e8 77 fe ff ff       	call   8007ee <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800977:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80097a:	e9 ba fe ff ff       	jmp    800839 <vprintfmt+0x23>
  80097f:	89 f9                	mov    %edi,%ecx
  800981:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800984:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800987:	8b 45 14             	mov    0x14(%ebp),%eax
  80098a:	8d 50 04             	lea    0x4(%eax),%edx
  80098d:	89 55 14             	mov    %edx,0x14(%ebp)
  800990:	8b 30                	mov    (%eax),%esi
  800992:	85 f6                	test   %esi,%esi
  800994:	75 05                	jne    80099b <vprintfmt+0x185>
				p = "(null)";
  800996:	be 94 17 80 00       	mov    $0x801794,%esi
			if (width > 0 && padc != '-')
  80099b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80099f:	0f 8e 84 00 00 00    	jle    800a29 <vprintfmt+0x213>
  8009a5:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8009a9:	74 7e                	je     800a29 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8009ab:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8009af:	89 34 24             	mov    %esi,(%esp)
  8009b2:	e8 8b 02 00 00       	call   800c42 <strnlen>
  8009b7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8009ba:	29 c2                	sub    %eax,%edx
  8009bc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8009bf:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8009c3:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8009c6:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8009c9:	89 de                	mov    %ebx,%esi
  8009cb:	89 d3                	mov    %edx,%ebx
  8009cd:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009cf:	eb 0b                	jmp    8009dc <vprintfmt+0x1c6>
					putch(padc, putdat);
  8009d1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009d5:	89 3c 24             	mov    %edi,(%esp)
  8009d8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009db:	4b                   	dec    %ebx
  8009dc:	85 db                	test   %ebx,%ebx
  8009de:	7f f1                	jg     8009d1 <vprintfmt+0x1bb>
  8009e0:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8009e3:	89 f3                	mov    %esi,%ebx
  8009e5:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8009e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8009eb:	85 c0                	test   %eax,%eax
  8009ed:	79 05                	jns    8009f4 <vprintfmt+0x1de>
  8009ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8009f7:	29 c2                	sub    %eax,%edx
  8009f9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8009fc:	eb 2b                	jmp    800a29 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8009fe:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800a02:	74 18                	je     800a1c <vprintfmt+0x206>
  800a04:	8d 50 e0             	lea    -0x20(%eax),%edx
  800a07:	83 fa 5e             	cmp    $0x5e,%edx
  800a0a:	76 10                	jbe    800a1c <vprintfmt+0x206>
					putch('?', putdat);
  800a0c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a10:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800a17:	ff 55 08             	call   *0x8(%ebp)
  800a1a:	eb 0a                	jmp    800a26 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800a1c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a20:	89 04 24             	mov    %eax,(%esp)
  800a23:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a26:	ff 4d e4             	decl   -0x1c(%ebp)
  800a29:	0f be 06             	movsbl (%esi),%eax
  800a2c:	46                   	inc    %esi
  800a2d:	85 c0                	test   %eax,%eax
  800a2f:	74 21                	je     800a52 <vprintfmt+0x23c>
  800a31:	85 ff                	test   %edi,%edi
  800a33:	78 c9                	js     8009fe <vprintfmt+0x1e8>
  800a35:	4f                   	dec    %edi
  800a36:	79 c6                	jns    8009fe <vprintfmt+0x1e8>
  800a38:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a3b:	89 de                	mov    %ebx,%esi
  800a3d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800a40:	eb 18                	jmp    800a5a <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a42:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a46:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800a4d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a4f:	4b                   	dec    %ebx
  800a50:	eb 08                	jmp    800a5a <vprintfmt+0x244>
  800a52:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a55:	89 de                	mov    %ebx,%esi
  800a57:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800a5a:	85 db                	test   %ebx,%ebx
  800a5c:	7f e4                	jg     800a42 <vprintfmt+0x22c>
  800a5e:	89 7d 08             	mov    %edi,0x8(%ebp)
  800a61:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a63:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800a66:	e9 ce fd ff ff       	jmp    800839 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a6b:	83 f9 01             	cmp    $0x1,%ecx
  800a6e:	7e 10                	jle    800a80 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800a70:	8b 45 14             	mov    0x14(%ebp),%eax
  800a73:	8d 50 08             	lea    0x8(%eax),%edx
  800a76:	89 55 14             	mov    %edx,0x14(%ebp)
  800a79:	8b 30                	mov    (%eax),%esi
  800a7b:	8b 78 04             	mov    0x4(%eax),%edi
  800a7e:	eb 26                	jmp    800aa6 <vprintfmt+0x290>
	else if (lflag)
  800a80:	85 c9                	test   %ecx,%ecx
  800a82:	74 12                	je     800a96 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800a84:	8b 45 14             	mov    0x14(%ebp),%eax
  800a87:	8d 50 04             	lea    0x4(%eax),%edx
  800a8a:	89 55 14             	mov    %edx,0x14(%ebp)
  800a8d:	8b 30                	mov    (%eax),%esi
  800a8f:	89 f7                	mov    %esi,%edi
  800a91:	c1 ff 1f             	sar    $0x1f,%edi
  800a94:	eb 10                	jmp    800aa6 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800a96:	8b 45 14             	mov    0x14(%ebp),%eax
  800a99:	8d 50 04             	lea    0x4(%eax),%edx
  800a9c:	89 55 14             	mov    %edx,0x14(%ebp)
  800a9f:	8b 30                	mov    (%eax),%esi
  800aa1:	89 f7                	mov    %esi,%edi
  800aa3:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800aa6:	85 ff                	test   %edi,%edi
  800aa8:	78 0a                	js     800ab4 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800aaa:	b8 0a 00 00 00       	mov    $0xa,%eax
  800aaf:	e9 8c 00 00 00       	jmp    800b40 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800ab4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ab8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800abf:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800ac2:	f7 de                	neg    %esi
  800ac4:	83 d7 00             	adc    $0x0,%edi
  800ac7:	f7 df                	neg    %edi
			}
			base = 10;
  800ac9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ace:	eb 70                	jmp    800b40 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800ad0:	89 ca                	mov    %ecx,%edx
  800ad2:	8d 45 14             	lea    0x14(%ebp),%eax
  800ad5:	e8 c0 fc ff ff       	call   80079a <getuint>
  800ada:	89 c6                	mov    %eax,%esi
  800adc:	89 d7                	mov    %edx,%edi
			base = 10;
  800ade:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800ae3:	eb 5b                	jmp    800b40 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  800ae5:	89 ca                	mov    %ecx,%edx
  800ae7:	8d 45 14             	lea    0x14(%ebp),%eax
  800aea:	e8 ab fc ff ff       	call   80079a <getuint>
  800aef:	89 c6                	mov    %eax,%esi
  800af1:	89 d7                	mov    %edx,%edi
			base = 8;
  800af3:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800af8:	eb 46                	jmp    800b40 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  800afa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800afe:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800b05:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800b08:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b0c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800b13:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b16:	8b 45 14             	mov    0x14(%ebp),%eax
  800b19:	8d 50 04             	lea    0x4(%eax),%edx
  800b1c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b1f:	8b 30                	mov    (%eax),%esi
  800b21:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b26:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800b2b:	eb 13                	jmp    800b40 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b2d:	89 ca                	mov    %ecx,%edx
  800b2f:	8d 45 14             	lea    0x14(%ebp),%eax
  800b32:	e8 63 fc ff ff       	call   80079a <getuint>
  800b37:	89 c6                	mov    %eax,%esi
  800b39:	89 d7                	mov    %edx,%edi
			base = 16;
  800b3b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b40:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800b44:	89 54 24 10          	mov    %edx,0x10(%esp)
  800b48:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800b4b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800b4f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b53:	89 34 24             	mov    %esi,(%esp)
  800b56:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b5a:	89 da                	mov    %ebx,%edx
  800b5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5f:	e8 6c fb ff ff       	call   8006d0 <printnum>
			break;
  800b64:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800b67:	e9 cd fc ff ff       	jmp    800839 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b6c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b70:	89 04 24             	mov    %eax,(%esp)
  800b73:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b76:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800b79:	e9 bb fc ff ff       	jmp    800839 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b7e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b82:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800b89:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b8c:	eb 01                	jmp    800b8f <vprintfmt+0x379>
  800b8e:	4e                   	dec    %esi
  800b8f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800b93:	75 f9                	jne    800b8e <vprintfmt+0x378>
  800b95:	e9 9f fc ff ff       	jmp    800839 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800b9a:	83 c4 4c             	add    $0x4c,%esp
  800b9d:	5b                   	pop    %ebx
  800b9e:	5e                   	pop    %esi
  800b9f:	5f                   	pop    %edi
  800ba0:	5d                   	pop    %ebp
  800ba1:	c3                   	ret    

00800ba2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	83 ec 28             	sub    $0x28,%esp
  800ba8:	8b 45 08             	mov    0x8(%ebp),%eax
  800bab:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800bae:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800bb1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800bb5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800bb8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800bbf:	85 c0                	test   %eax,%eax
  800bc1:	74 30                	je     800bf3 <vsnprintf+0x51>
  800bc3:	85 d2                	test   %edx,%edx
  800bc5:	7e 33                	jle    800bfa <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800bc7:	8b 45 14             	mov    0x14(%ebp),%eax
  800bca:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bce:	8b 45 10             	mov    0x10(%ebp),%eax
  800bd1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bd5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800bd8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bdc:	c7 04 24 d4 07 80 00 	movl   $0x8007d4,(%esp)
  800be3:	e8 2e fc ff ff       	call   800816 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800be8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800beb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800bee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bf1:	eb 0c                	jmp    800bff <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800bf3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800bf8:	eb 05                	jmp    800bff <vsnprintf+0x5d>
  800bfa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800bff:	c9                   	leave  
  800c00:	c3                   	ret    

00800c01 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c01:	55                   	push   %ebp
  800c02:	89 e5                	mov    %esp,%ebp
  800c04:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c07:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c0a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c0e:	8b 45 10             	mov    0x10(%ebp),%eax
  800c11:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c15:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c18:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c1c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1f:	89 04 24             	mov    %eax,(%esp)
  800c22:	e8 7b ff ff ff       	call   800ba2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800c27:	c9                   	leave  
  800c28:	c3                   	ret    
  800c29:	00 00                	add    %al,(%eax)
	...

00800c2c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c2c:	55                   	push   %ebp
  800c2d:	89 e5                	mov    %esp,%ebp
  800c2f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c32:	b8 00 00 00 00       	mov    $0x0,%eax
  800c37:	eb 01                	jmp    800c3a <strlen+0xe>
		n++;
  800c39:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c3a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c3e:	75 f9                	jne    800c39 <strlen+0xd>
		n++;
	return n;
}
  800c40:	5d                   	pop    %ebp
  800c41:	c3                   	ret    

00800c42 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c42:	55                   	push   %ebp
  800c43:	89 e5                	mov    %esp,%ebp
  800c45:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800c48:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c4b:	b8 00 00 00 00       	mov    $0x0,%eax
  800c50:	eb 01                	jmp    800c53 <strnlen+0x11>
		n++;
  800c52:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c53:	39 d0                	cmp    %edx,%eax
  800c55:	74 06                	je     800c5d <strnlen+0x1b>
  800c57:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800c5b:	75 f5                	jne    800c52 <strnlen+0x10>
		n++;
	return n;
}
  800c5d:	5d                   	pop    %ebp
  800c5e:	c3                   	ret    

00800c5f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c5f:	55                   	push   %ebp
  800c60:	89 e5                	mov    %esp,%ebp
  800c62:	53                   	push   %ebx
  800c63:	8b 45 08             	mov    0x8(%ebp),%eax
  800c66:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c69:	ba 00 00 00 00       	mov    $0x0,%edx
  800c6e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800c71:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800c74:	42                   	inc    %edx
  800c75:	84 c9                	test   %cl,%cl
  800c77:	75 f5                	jne    800c6e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800c79:	5b                   	pop    %ebx
  800c7a:	5d                   	pop    %ebp
  800c7b:	c3                   	ret    

00800c7c <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c7c:	55                   	push   %ebp
  800c7d:	89 e5                	mov    %esp,%ebp
  800c7f:	53                   	push   %ebx
  800c80:	83 ec 08             	sub    $0x8,%esp
  800c83:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800c86:	89 1c 24             	mov    %ebx,(%esp)
  800c89:	e8 9e ff ff ff       	call   800c2c <strlen>
	strcpy(dst + len, src);
  800c8e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c91:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c95:	01 d8                	add    %ebx,%eax
  800c97:	89 04 24             	mov    %eax,(%esp)
  800c9a:	e8 c0 ff ff ff       	call   800c5f <strcpy>
	return dst;
}
  800c9f:	89 d8                	mov    %ebx,%eax
  800ca1:	83 c4 08             	add    $0x8,%esp
  800ca4:	5b                   	pop    %ebx
  800ca5:	5d                   	pop    %ebp
  800ca6:	c3                   	ret    

00800ca7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ca7:	55                   	push   %ebp
  800ca8:	89 e5                	mov    %esp,%ebp
  800caa:	56                   	push   %esi
  800cab:	53                   	push   %ebx
  800cac:	8b 45 08             	mov    0x8(%ebp),%eax
  800caf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cb2:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cb5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cba:	eb 0c                	jmp    800cc8 <strncpy+0x21>
		*dst++ = *src;
  800cbc:	8a 1a                	mov    (%edx),%bl
  800cbe:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800cc1:	80 3a 01             	cmpb   $0x1,(%edx)
  800cc4:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cc7:	41                   	inc    %ecx
  800cc8:	39 f1                	cmp    %esi,%ecx
  800cca:	75 f0                	jne    800cbc <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ccc:	5b                   	pop    %ebx
  800ccd:	5e                   	pop    %esi
  800cce:	5d                   	pop    %ebp
  800ccf:	c3                   	ret    

00800cd0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800cd0:	55                   	push   %ebp
  800cd1:	89 e5                	mov    %esp,%ebp
  800cd3:	56                   	push   %esi
  800cd4:	53                   	push   %ebx
  800cd5:	8b 75 08             	mov    0x8(%ebp),%esi
  800cd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdb:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800cde:	85 d2                	test   %edx,%edx
  800ce0:	75 0a                	jne    800cec <strlcpy+0x1c>
  800ce2:	89 f0                	mov    %esi,%eax
  800ce4:	eb 1a                	jmp    800d00 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800ce6:	88 18                	mov    %bl,(%eax)
  800ce8:	40                   	inc    %eax
  800ce9:	41                   	inc    %ecx
  800cea:	eb 02                	jmp    800cee <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800cec:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800cee:	4a                   	dec    %edx
  800cef:	74 0a                	je     800cfb <strlcpy+0x2b>
  800cf1:	8a 19                	mov    (%ecx),%bl
  800cf3:	84 db                	test   %bl,%bl
  800cf5:	75 ef                	jne    800ce6 <strlcpy+0x16>
  800cf7:	89 c2                	mov    %eax,%edx
  800cf9:	eb 02                	jmp    800cfd <strlcpy+0x2d>
  800cfb:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800cfd:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800d00:	29 f0                	sub    %esi,%eax
}
  800d02:	5b                   	pop    %ebx
  800d03:	5e                   	pop    %esi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d0c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d0f:	eb 02                	jmp    800d13 <strcmp+0xd>
		p++, q++;
  800d11:	41                   	inc    %ecx
  800d12:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d13:	8a 01                	mov    (%ecx),%al
  800d15:	84 c0                	test   %al,%al
  800d17:	74 04                	je     800d1d <strcmp+0x17>
  800d19:	3a 02                	cmp    (%edx),%al
  800d1b:	74 f4                	je     800d11 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d1d:	0f b6 c0             	movzbl %al,%eax
  800d20:	0f b6 12             	movzbl (%edx),%edx
  800d23:	29 d0                	sub    %edx,%eax
}
  800d25:	5d                   	pop    %ebp
  800d26:	c3                   	ret    

00800d27 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d27:	55                   	push   %ebp
  800d28:	89 e5                	mov    %esp,%ebp
  800d2a:	53                   	push   %ebx
  800d2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d31:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800d34:	eb 03                	jmp    800d39 <strncmp+0x12>
		n--, p++, q++;
  800d36:	4a                   	dec    %edx
  800d37:	40                   	inc    %eax
  800d38:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d39:	85 d2                	test   %edx,%edx
  800d3b:	74 14                	je     800d51 <strncmp+0x2a>
  800d3d:	8a 18                	mov    (%eax),%bl
  800d3f:	84 db                	test   %bl,%bl
  800d41:	74 04                	je     800d47 <strncmp+0x20>
  800d43:	3a 19                	cmp    (%ecx),%bl
  800d45:	74 ef                	je     800d36 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d47:	0f b6 00             	movzbl (%eax),%eax
  800d4a:	0f b6 11             	movzbl (%ecx),%edx
  800d4d:	29 d0                	sub    %edx,%eax
  800d4f:	eb 05                	jmp    800d56 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800d51:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800d56:	5b                   	pop    %ebx
  800d57:	5d                   	pop    %ebp
  800d58:	c3                   	ret    

00800d59 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d59:	55                   	push   %ebp
  800d5a:	89 e5                	mov    %esp,%ebp
  800d5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800d62:	eb 05                	jmp    800d69 <strchr+0x10>
		if (*s == c)
  800d64:	38 ca                	cmp    %cl,%dl
  800d66:	74 0c                	je     800d74 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d68:	40                   	inc    %eax
  800d69:	8a 10                	mov    (%eax),%dl
  800d6b:	84 d2                	test   %dl,%dl
  800d6d:	75 f5                	jne    800d64 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800d6f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d74:	5d                   	pop    %ebp
  800d75:	c3                   	ret    

00800d76 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d76:	55                   	push   %ebp
  800d77:	89 e5                	mov    %esp,%ebp
  800d79:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800d7f:	eb 05                	jmp    800d86 <strfind+0x10>
		if (*s == c)
  800d81:	38 ca                	cmp    %cl,%dl
  800d83:	74 07                	je     800d8c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800d85:	40                   	inc    %eax
  800d86:	8a 10                	mov    (%eax),%dl
  800d88:	84 d2                	test   %dl,%dl
  800d8a:	75 f5                	jne    800d81 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800d8c:	5d                   	pop    %ebp
  800d8d:	c3                   	ret    

00800d8e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d8e:	55                   	push   %ebp
  800d8f:	89 e5                	mov    %esp,%ebp
  800d91:	57                   	push   %edi
  800d92:	56                   	push   %esi
  800d93:	53                   	push   %ebx
  800d94:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d97:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d9a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d9d:	85 c9                	test   %ecx,%ecx
  800d9f:	74 30                	je     800dd1 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800da1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800da7:	75 25                	jne    800dce <memset+0x40>
  800da9:	f6 c1 03             	test   $0x3,%cl
  800dac:	75 20                	jne    800dce <memset+0x40>
		c &= 0xFF;
  800dae:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800db1:	89 d3                	mov    %edx,%ebx
  800db3:	c1 e3 08             	shl    $0x8,%ebx
  800db6:	89 d6                	mov    %edx,%esi
  800db8:	c1 e6 18             	shl    $0x18,%esi
  800dbb:	89 d0                	mov    %edx,%eax
  800dbd:	c1 e0 10             	shl    $0x10,%eax
  800dc0:	09 f0                	or     %esi,%eax
  800dc2:	09 d0                	or     %edx,%eax
  800dc4:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800dc6:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800dc9:	fc                   	cld    
  800dca:	f3 ab                	rep stos %eax,%es:(%edi)
  800dcc:	eb 03                	jmp    800dd1 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800dce:	fc                   	cld    
  800dcf:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800dd1:	89 f8                	mov    %edi,%eax
  800dd3:	5b                   	pop    %ebx
  800dd4:	5e                   	pop    %esi
  800dd5:	5f                   	pop    %edi
  800dd6:	5d                   	pop    %ebp
  800dd7:	c3                   	ret    

00800dd8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800dd8:	55                   	push   %ebp
  800dd9:	89 e5                	mov    %esp,%ebp
  800ddb:	57                   	push   %edi
  800ddc:	56                   	push   %esi
  800ddd:	8b 45 08             	mov    0x8(%ebp),%eax
  800de0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800de3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800de6:	39 c6                	cmp    %eax,%esi
  800de8:	73 34                	jae    800e1e <memmove+0x46>
  800dea:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ded:	39 d0                	cmp    %edx,%eax
  800def:	73 2d                	jae    800e1e <memmove+0x46>
		s += n;
		d += n;
  800df1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800df4:	f6 c2 03             	test   $0x3,%dl
  800df7:	75 1b                	jne    800e14 <memmove+0x3c>
  800df9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800dff:	75 13                	jne    800e14 <memmove+0x3c>
  800e01:	f6 c1 03             	test   $0x3,%cl
  800e04:	75 0e                	jne    800e14 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800e06:	83 ef 04             	sub    $0x4,%edi
  800e09:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e0c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800e0f:	fd                   	std    
  800e10:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e12:	eb 07                	jmp    800e1b <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800e14:	4f                   	dec    %edi
  800e15:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e18:	fd                   	std    
  800e19:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e1b:	fc                   	cld    
  800e1c:	eb 20                	jmp    800e3e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e1e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e24:	75 13                	jne    800e39 <memmove+0x61>
  800e26:	a8 03                	test   $0x3,%al
  800e28:	75 0f                	jne    800e39 <memmove+0x61>
  800e2a:	f6 c1 03             	test   $0x3,%cl
  800e2d:	75 0a                	jne    800e39 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800e2f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800e32:	89 c7                	mov    %eax,%edi
  800e34:	fc                   	cld    
  800e35:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e37:	eb 05                	jmp    800e3e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e39:	89 c7                	mov    %eax,%edi
  800e3b:	fc                   	cld    
  800e3c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e3e:	5e                   	pop    %esi
  800e3f:	5f                   	pop    %edi
  800e40:	5d                   	pop    %ebp
  800e41:	c3                   	ret    

00800e42 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e42:	55                   	push   %ebp
  800e43:	89 e5                	mov    %esp,%ebp
  800e45:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800e48:	8b 45 10             	mov    0x10(%ebp),%eax
  800e4b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e4f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e52:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e56:	8b 45 08             	mov    0x8(%ebp),%eax
  800e59:	89 04 24             	mov    %eax,(%esp)
  800e5c:	e8 77 ff ff ff       	call   800dd8 <memmove>
}
  800e61:	c9                   	leave  
  800e62:	c3                   	ret    

00800e63 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e63:	55                   	push   %ebp
  800e64:	89 e5                	mov    %esp,%ebp
  800e66:	57                   	push   %edi
  800e67:	56                   	push   %esi
  800e68:	53                   	push   %ebx
  800e69:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e6c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e6f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e72:	ba 00 00 00 00       	mov    $0x0,%edx
  800e77:	eb 16                	jmp    800e8f <memcmp+0x2c>
		if (*s1 != *s2)
  800e79:	8a 04 17             	mov    (%edi,%edx,1),%al
  800e7c:	42                   	inc    %edx
  800e7d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800e81:	38 c8                	cmp    %cl,%al
  800e83:	74 0a                	je     800e8f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800e85:	0f b6 c0             	movzbl %al,%eax
  800e88:	0f b6 c9             	movzbl %cl,%ecx
  800e8b:	29 c8                	sub    %ecx,%eax
  800e8d:	eb 09                	jmp    800e98 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e8f:	39 da                	cmp    %ebx,%edx
  800e91:	75 e6                	jne    800e79 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e93:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e98:	5b                   	pop    %ebx
  800e99:	5e                   	pop    %esi
  800e9a:	5f                   	pop    %edi
  800e9b:	5d                   	pop    %ebp
  800e9c:	c3                   	ret    

00800e9d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e9d:	55                   	push   %ebp
  800e9e:	89 e5                	mov    %esp,%ebp
  800ea0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ea6:	89 c2                	mov    %eax,%edx
  800ea8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800eab:	eb 05                	jmp    800eb2 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ead:	38 08                	cmp    %cl,(%eax)
  800eaf:	74 05                	je     800eb6 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800eb1:	40                   	inc    %eax
  800eb2:	39 d0                	cmp    %edx,%eax
  800eb4:	72 f7                	jb     800ead <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800eb6:	5d                   	pop    %ebp
  800eb7:	c3                   	ret    

00800eb8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800eb8:	55                   	push   %ebp
  800eb9:	89 e5                	mov    %esp,%ebp
  800ebb:	57                   	push   %edi
  800ebc:	56                   	push   %esi
  800ebd:	53                   	push   %ebx
  800ebe:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ec4:	eb 01                	jmp    800ec7 <strtol+0xf>
		s++;
  800ec6:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ec7:	8a 02                	mov    (%edx),%al
  800ec9:	3c 20                	cmp    $0x20,%al
  800ecb:	74 f9                	je     800ec6 <strtol+0xe>
  800ecd:	3c 09                	cmp    $0x9,%al
  800ecf:	74 f5                	je     800ec6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ed1:	3c 2b                	cmp    $0x2b,%al
  800ed3:	75 08                	jne    800edd <strtol+0x25>
		s++;
  800ed5:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ed6:	bf 00 00 00 00       	mov    $0x0,%edi
  800edb:	eb 13                	jmp    800ef0 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800edd:	3c 2d                	cmp    $0x2d,%al
  800edf:	75 0a                	jne    800eeb <strtol+0x33>
		s++, neg = 1;
  800ee1:	8d 52 01             	lea    0x1(%edx),%edx
  800ee4:	bf 01 00 00 00       	mov    $0x1,%edi
  800ee9:	eb 05                	jmp    800ef0 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800eeb:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ef0:	85 db                	test   %ebx,%ebx
  800ef2:	74 05                	je     800ef9 <strtol+0x41>
  800ef4:	83 fb 10             	cmp    $0x10,%ebx
  800ef7:	75 28                	jne    800f21 <strtol+0x69>
  800ef9:	8a 02                	mov    (%edx),%al
  800efb:	3c 30                	cmp    $0x30,%al
  800efd:	75 10                	jne    800f0f <strtol+0x57>
  800eff:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800f03:	75 0a                	jne    800f0f <strtol+0x57>
		s += 2, base = 16;
  800f05:	83 c2 02             	add    $0x2,%edx
  800f08:	bb 10 00 00 00       	mov    $0x10,%ebx
  800f0d:	eb 12                	jmp    800f21 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800f0f:	85 db                	test   %ebx,%ebx
  800f11:	75 0e                	jne    800f21 <strtol+0x69>
  800f13:	3c 30                	cmp    $0x30,%al
  800f15:	75 05                	jne    800f1c <strtol+0x64>
		s++, base = 8;
  800f17:	42                   	inc    %edx
  800f18:	b3 08                	mov    $0x8,%bl
  800f1a:	eb 05                	jmp    800f21 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800f1c:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800f21:	b8 00 00 00 00       	mov    $0x0,%eax
  800f26:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f28:	8a 0a                	mov    (%edx),%cl
  800f2a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800f2d:	80 fb 09             	cmp    $0x9,%bl
  800f30:	77 08                	ja     800f3a <strtol+0x82>
			dig = *s - '0';
  800f32:	0f be c9             	movsbl %cl,%ecx
  800f35:	83 e9 30             	sub    $0x30,%ecx
  800f38:	eb 1e                	jmp    800f58 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800f3a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800f3d:	80 fb 19             	cmp    $0x19,%bl
  800f40:	77 08                	ja     800f4a <strtol+0x92>
			dig = *s - 'a' + 10;
  800f42:	0f be c9             	movsbl %cl,%ecx
  800f45:	83 e9 57             	sub    $0x57,%ecx
  800f48:	eb 0e                	jmp    800f58 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800f4a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800f4d:	80 fb 19             	cmp    $0x19,%bl
  800f50:	77 12                	ja     800f64 <strtol+0xac>
			dig = *s - 'A' + 10;
  800f52:	0f be c9             	movsbl %cl,%ecx
  800f55:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800f58:	39 f1                	cmp    %esi,%ecx
  800f5a:	7d 0c                	jge    800f68 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800f5c:	42                   	inc    %edx
  800f5d:	0f af c6             	imul   %esi,%eax
  800f60:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800f62:	eb c4                	jmp    800f28 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800f64:	89 c1                	mov    %eax,%ecx
  800f66:	eb 02                	jmp    800f6a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800f68:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800f6a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f6e:	74 05                	je     800f75 <strtol+0xbd>
		*endptr = (char *) s;
  800f70:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f73:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800f75:	85 ff                	test   %edi,%edi
  800f77:	74 04                	je     800f7d <strtol+0xc5>
  800f79:	89 c8                	mov    %ecx,%eax
  800f7b:	f7 d8                	neg    %eax
}
  800f7d:	5b                   	pop    %ebx
  800f7e:	5e                   	pop    %esi
  800f7f:	5f                   	pop    %edi
  800f80:	5d                   	pop    %ebp
  800f81:	c3                   	ret    
	...

00800f84 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800f84:	55                   	push   %ebp
  800f85:	89 e5                	mov    %esp,%ebp
  800f87:	57                   	push   %edi
  800f88:	56                   	push   %esi
  800f89:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f8a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f92:	8b 55 08             	mov    0x8(%ebp),%edx
  800f95:	89 c3                	mov    %eax,%ebx
  800f97:	89 c7                	mov    %eax,%edi
  800f99:	89 c6                	mov    %eax,%esi
  800f9b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800f9d:	5b                   	pop    %ebx
  800f9e:	5e                   	pop    %esi
  800f9f:	5f                   	pop    %edi
  800fa0:	5d                   	pop    %ebp
  800fa1:	c3                   	ret    

00800fa2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800fa2:	55                   	push   %ebp
  800fa3:	89 e5                	mov    %esp,%ebp
  800fa5:	57                   	push   %edi
  800fa6:	56                   	push   %esi
  800fa7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fa8:	ba 00 00 00 00       	mov    $0x0,%edx
  800fad:	b8 01 00 00 00       	mov    $0x1,%eax
  800fb2:	89 d1                	mov    %edx,%ecx
  800fb4:	89 d3                	mov    %edx,%ebx
  800fb6:	89 d7                	mov    %edx,%edi
  800fb8:	89 d6                	mov    %edx,%esi
  800fba:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800fbc:	5b                   	pop    %ebx
  800fbd:	5e                   	pop    %esi
  800fbe:	5f                   	pop    %edi
  800fbf:	5d                   	pop    %ebp
  800fc0:	c3                   	ret    

00800fc1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800fc1:	55                   	push   %ebp
  800fc2:	89 e5                	mov    %esp,%ebp
  800fc4:	57                   	push   %edi
  800fc5:	56                   	push   %esi
  800fc6:	53                   	push   %ebx
  800fc7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fca:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fcf:	b8 03 00 00 00       	mov    $0x3,%eax
  800fd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd7:	89 cb                	mov    %ecx,%ebx
  800fd9:	89 cf                	mov    %ecx,%edi
  800fdb:	89 ce                	mov    %ecx,%esi
  800fdd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fdf:	85 c0                	test   %eax,%eax
  800fe1:	7e 28                	jle    80100b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fe3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fe7:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800fee:	00 
  800fef:	c7 44 24 08 88 1a 80 	movl   $0x801a88,0x8(%esp)
  800ff6:	00 
  800ff7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ffe:	00 
  800fff:	c7 04 24 a5 1a 80 00 	movl   $0x801aa5,(%esp)
  801006:	e8 b1 f5 ff ff       	call   8005bc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80100b:	83 c4 2c             	add    $0x2c,%esp
  80100e:	5b                   	pop    %ebx
  80100f:	5e                   	pop    %esi
  801010:	5f                   	pop    %edi
  801011:	5d                   	pop    %ebp
  801012:	c3                   	ret    

00801013 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801013:	55                   	push   %ebp
  801014:	89 e5                	mov    %esp,%ebp
  801016:	57                   	push   %edi
  801017:	56                   	push   %esi
  801018:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801019:	ba 00 00 00 00       	mov    $0x0,%edx
  80101e:	b8 02 00 00 00       	mov    $0x2,%eax
  801023:	89 d1                	mov    %edx,%ecx
  801025:	89 d3                	mov    %edx,%ebx
  801027:	89 d7                	mov    %edx,%edi
  801029:	89 d6                	mov    %edx,%esi
  80102b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80102d:	5b                   	pop    %ebx
  80102e:	5e                   	pop    %esi
  80102f:	5f                   	pop    %edi
  801030:	5d                   	pop    %ebp
  801031:	c3                   	ret    

00801032 <sys_yield>:

void
sys_yield(void)
{
  801032:	55                   	push   %ebp
  801033:	89 e5                	mov    %esp,%ebp
  801035:	57                   	push   %edi
  801036:	56                   	push   %esi
  801037:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801038:	ba 00 00 00 00       	mov    $0x0,%edx
  80103d:	b8 0b 00 00 00       	mov    $0xb,%eax
  801042:	89 d1                	mov    %edx,%ecx
  801044:	89 d3                	mov    %edx,%ebx
  801046:	89 d7                	mov    %edx,%edi
  801048:	89 d6                	mov    %edx,%esi
  80104a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80104c:	5b                   	pop    %ebx
  80104d:	5e                   	pop    %esi
  80104e:	5f                   	pop    %edi
  80104f:	5d                   	pop    %ebp
  801050:	c3                   	ret    

00801051 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801051:	55                   	push   %ebp
  801052:	89 e5                	mov    %esp,%ebp
  801054:	57                   	push   %edi
  801055:	56                   	push   %esi
  801056:	53                   	push   %ebx
  801057:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80105a:	be 00 00 00 00       	mov    $0x0,%esi
  80105f:	b8 04 00 00 00       	mov    $0x4,%eax
  801064:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801067:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80106a:	8b 55 08             	mov    0x8(%ebp),%edx
  80106d:	89 f7                	mov    %esi,%edi
  80106f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801071:	85 c0                	test   %eax,%eax
  801073:	7e 28                	jle    80109d <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  801075:	89 44 24 10          	mov    %eax,0x10(%esp)
  801079:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  801080:	00 
  801081:	c7 44 24 08 88 1a 80 	movl   $0x801a88,0x8(%esp)
  801088:	00 
  801089:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801090:	00 
  801091:	c7 04 24 a5 1a 80 00 	movl   $0x801aa5,(%esp)
  801098:	e8 1f f5 ff ff       	call   8005bc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80109d:	83 c4 2c             	add    $0x2c,%esp
  8010a0:	5b                   	pop    %ebx
  8010a1:	5e                   	pop    %esi
  8010a2:	5f                   	pop    %edi
  8010a3:	5d                   	pop    %ebp
  8010a4:	c3                   	ret    

008010a5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8010a5:	55                   	push   %ebp
  8010a6:	89 e5                	mov    %esp,%ebp
  8010a8:	57                   	push   %edi
  8010a9:	56                   	push   %esi
  8010aa:	53                   	push   %ebx
  8010ab:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ae:	b8 05 00 00 00       	mov    $0x5,%eax
  8010b3:	8b 75 18             	mov    0x18(%ebp),%esi
  8010b6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010b9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8010c2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010c4:	85 c0                	test   %eax,%eax
  8010c6:	7e 28                	jle    8010f0 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010c8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010cc:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8010d3:	00 
  8010d4:	c7 44 24 08 88 1a 80 	movl   $0x801a88,0x8(%esp)
  8010db:	00 
  8010dc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010e3:	00 
  8010e4:	c7 04 24 a5 1a 80 00 	movl   $0x801aa5,(%esp)
  8010eb:	e8 cc f4 ff ff       	call   8005bc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8010f0:	83 c4 2c             	add    $0x2c,%esp
  8010f3:	5b                   	pop    %ebx
  8010f4:	5e                   	pop    %esi
  8010f5:	5f                   	pop    %edi
  8010f6:	5d                   	pop    %ebp
  8010f7:	c3                   	ret    

008010f8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8010f8:	55                   	push   %ebp
  8010f9:	89 e5                	mov    %esp,%ebp
  8010fb:	57                   	push   %edi
  8010fc:	56                   	push   %esi
  8010fd:	53                   	push   %ebx
  8010fe:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801101:	bb 00 00 00 00       	mov    $0x0,%ebx
  801106:	b8 06 00 00 00       	mov    $0x6,%eax
  80110b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80110e:	8b 55 08             	mov    0x8(%ebp),%edx
  801111:	89 df                	mov    %ebx,%edi
  801113:	89 de                	mov    %ebx,%esi
  801115:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801117:	85 c0                	test   %eax,%eax
  801119:	7e 28                	jle    801143 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80111b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80111f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801126:	00 
  801127:	c7 44 24 08 88 1a 80 	movl   $0x801a88,0x8(%esp)
  80112e:	00 
  80112f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801136:	00 
  801137:	c7 04 24 a5 1a 80 00 	movl   $0x801aa5,(%esp)
  80113e:	e8 79 f4 ff ff       	call   8005bc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801143:	83 c4 2c             	add    $0x2c,%esp
  801146:	5b                   	pop    %ebx
  801147:	5e                   	pop    %esi
  801148:	5f                   	pop    %edi
  801149:	5d                   	pop    %ebp
  80114a:	c3                   	ret    

0080114b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80114b:	55                   	push   %ebp
  80114c:	89 e5                	mov    %esp,%ebp
  80114e:	57                   	push   %edi
  80114f:	56                   	push   %esi
  801150:	53                   	push   %ebx
  801151:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801154:	bb 00 00 00 00       	mov    $0x0,%ebx
  801159:	b8 08 00 00 00       	mov    $0x8,%eax
  80115e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801161:	8b 55 08             	mov    0x8(%ebp),%edx
  801164:	89 df                	mov    %ebx,%edi
  801166:	89 de                	mov    %ebx,%esi
  801168:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80116a:	85 c0                	test   %eax,%eax
  80116c:	7e 28                	jle    801196 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80116e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801172:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  801179:	00 
  80117a:	c7 44 24 08 88 1a 80 	movl   $0x801a88,0x8(%esp)
  801181:	00 
  801182:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801189:	00 
  80118a:	c7 04 24 a5 1a 80 00 	movl   $0x801aa5,(%esp)
  801191:	e8 26 f4 ff ff       	call   8005bc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801196:	83 c4 2c             	add    $0x2c,%esp
  801199:	5b                   	pop    %ebx
  80119a:	5e                   	pop    %esi
  80119b:	5f                   	pop    %edi
  80119c:	5d                   	pop    %ebp
  80119d:	c3                   	ret    

0080119e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80119e:	55                   	push   %ebp
  80119f:	89 e5                	mov    %esp,%ebp
  8011a1:	57                   	push   %edi
  8011a2:	56                   	push   %esi
  8011a3:	53                   	push   %ebx
  8011a4:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011a7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011ac:	b8 09 00 00 00       	mov    $0x9,%eax
  8011b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8011b7:	89 df                	mov    %ebx,%edi
  8011b9:	89 de                	mov    %ebx,%esi
  8011bb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011bd:	85 c0                	test   %eax,%eax
  8011bf:	7e 28                	jle    8011e9 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011c1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011c5:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8011cc:	00 
  8011cd:	c7 44 24 08 88 1a 80 	movl   $0x801a88,0x8(%esp)
  8011d4:	00 
  8011d5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011dc:	00 
  8011dd:	c7 04 24 a5 1a 80 00 	movl   $0x801aa5,(%esp)
  8011e4:	e8 d3 f3 ff ff       	call   8005bc <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8011e9:	83 c4 2c             	add    $0x2c,%esp
  8011ec:	5b                   	pop    %ebx
  8011ed:	5e                   	pop    %esi
  8011ee:	5f                   	pop    %edi
  8011ef:	5d                   	pop    %ebp
  8011f0:	c3                   	ret    

008011f1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8011f1:	55                   	push   %ebp
  8011f2:	89 e5                	mov    %esp,%ebp
  8011f4:	57                   	push   %edi
  8011f5:	56                   	push   %esi
  8011f6:	53                   	push   %ebx
  8011f7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011fa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011ff:	b8 0a 00 00 00       	mov    $0xa,%eax
  801204:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801207:	8b 55 08             	mov    0x8(%ebp),%edx
  80120a:	89 df                	mov    %ebx,%edi
  80120c:	89 de                	mov    %ebx,%esi
  80120e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801210:	85 c0                	test   %eax,%eax
  801212:	7e 28                	jle    80123c <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801214:	89 44 24 10          	mov    %eax,0x10(%esp)
  801218:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80121f:	00 
  801220:	c7 44 24 08 88 1a 80 	movl   $0x801a88,0x8(%esp)
  801227:	00 
  801228:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80122f:	00 
  801230:	c7 04 24 a5 1a 80 00 	movl   $0x801aa5,(%esp)
  801237:	e8 80 f3 ff ff       	call   8005bc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80123c:	83 c4 2c             	add    $0x2c,%esp
  80123f:	5b                   	pop    %ebx
  801240:	5e                   	pop    %esi
  801241:	5f                   	pop    %edi
  801242:	5d                   	pop    %ebp
  801243:	c3                   	ret    

00801244 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801244:	55                   	push   %ebp
  801245:	89 e5                	mov    %esp,%ebp
  801247:	57                   	push   %edi
  801248:	56                   	push   %esi
  801249:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80124a:	be 00 00 00 00       	mov    $0x0,%esi
  80124f:	b8 0c 00 00 00       	mov    $0xc,%eax
  801254:	8b 7d 14             	mov    0x14(%ebp),%edi
  801257:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80125a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80125d:	8b 55 08             	mov    0x8(%ebp),%edx
  801260:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801262:	5b                   	pop    %ebx
  801263:	5e                   	pop    %esi
  801264:	5f                   	pop    %edi
  801265:	5d                   	pop    %ebp
  801266:	c3                   	ret    

00801267 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801267:	55                   	push   %ebp
  801268:	89 e5                	mov    %esp,%ebp
  80126a:	57                   	push   %edi
  80126b:	56                   	push   %esi
  80126c:	53                   	push   %ebx
  80126d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801270:	b9 00 00 00 00       	mov    $0x0,%ecx
  801275:	b8 0d 00 00 00       	mov    $0xd,%eax
  80127a:	8b 55 08             	mov    0x8(%ebp),%edx
  80127d:	89 cb                	mov    %ecx,%ebx
  80127f:	89 cf                	mov    %ecx,%edi
  801281:	89 ce                	mov    %ecx,%esi
  801283:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801285:	85 c0                	test   %eax,%eax
  801287:	7e 28                	jle    8012b1 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801289:	89 44 24 10          	mov    %eax,0x10(%esp)
  80128d:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801294:	00 
  801295:	c7 44 24 08 88 1a 80 	movl   $0x801a88,0x8(%esp)
  80129c:	00 
  80129d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012a4:	00 
  8012a5:	c7 04 24 a5 1a 80 00 	movl   $0x801aa5,(%esp)
  8012ac:	e8 0b f3 ff ff       	call   8005bc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8012b1:	83 c4 2c             	add    $0x2c,%esp
  8012b4:	5b                   	pop    %ebx
  8012b5:	5e                   	pop    %esi
  8012b6:	5f                   	pop    %edi
  8012b7:	5d                   	pop    %ebp
  8012b8:	c3                   	ret    

008012b9 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8012b9:	55                   	push   %ebp
  8012ba:	89 e5                	mov    %esp,%ebp
  8012bc:	57                   	push   %edi
  8012bd:	56                   	push   %esi
  8012be:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8012c4:	b8 0e 00 00 00       	mov    $0xe,%eax
  8012c9:	89 d1                	mov    %edx,%ecx
  8012cb:	89 d3                	mov    %edx,%ebx
  8012cd:	89 d7                	mov    %edx,%edi
  8012cf:	89 d6                	mov    %edx,%esi
  8012d1:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8012d3:	5b                   	pop    %ebx
  8012d4:	5e                   	pop    %esi
  8012d5:	5f                   	pop    %edi
  8012d6:	5d                   	pop    %ebp
  8012d7:	c3                   	ret    

008012d8 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char* pck, size_t length){
  8012d8:	55                   	push   %ebp
  8012d9:	89 e5                	mov    %esp,%ebp
  8012db:	57                   	push   %edi
  8012dc:	56                   	push   %esi
  8012dd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012de:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012e3:	b8 10 00 00 00       	mov    $0x10,%eax
  8012e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8012ee:	89 df                	mov    %ebx,%edi
  8012f0:	89 de                	mov    %ebx,%esi
  8012f2:	cd 30                	int    $0x30
}

int 
sys_e1000_transmit(char* pck, size_t length){
	return syscall(SYS_e1000_transmit, 0, (uint32_t)pck, length, 0, 0, 0);
}
  8012f4:	5b                   	pop    %ebx
  8012f5:	5e                   	pop    %esi
  8012f6:	5f                   	pop    %edi
  8012f7:	5d                   	pop    %ebp
  8012f8:	c3                   	ret    

008012f9 <sys_e1000_receive>:

int 
sys_e1000_receive(char* pck, size_t* length){
  8012f9:	55                   	push   %ebp
  8012fa:	89 e5                	mov    %esp,%ebp
  8012fc:	57                   	push   %edi
  8012fd:	56                   	push   %esi
  8012fe:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012ff:	bb 00 00 00 00       	mov    $0x0,%ebx
  801304:	b8 0f 00 00 00       	mov    $0xf,%eax
  801309:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80130c:	8b 55 08             	mov    0x8(%ebp),%edx
  80130f:	89 df                	mov    %ebx,%edi
  801311:	89 de                	mov    %ebx,%esi
  801313:	cd 30                	int    $0x30
}

int 
sys_e1000_receive(char* pck, size_t* length){
	return syscall(SYS_e1000_receive, 0, (uint32_t)pck, (uint32_t)length, 0, 0, 0);
}
  801315:	5b                   	pop    %ebx
  801316:	5e                   	pop    %esi
  801317:	5f                   	pop    %edi
  801318:	5d                   	pop    %ebp
  801319:	c3                   	ret    

0080131a <sys_e1000_get_mac>:

int 
sys_e1000_get_mac(uint8_t* mac_addr){
  80131a:	55                   	push   %ebp
  80131b:	89 e5                	mov    %esp,%ebp
  80131d:	57                   	push   %edi
  80131e:	56                   	push   %esi
  80131f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801320:	b9 00 00 00 00       	mov    $0x0,%ecx
  801325:	b8 11 00 00 00       	mov    $0x11,%eax
  80132a:	8b 55 08             	mov    0x8(%ebp),%edx
  80132d:	89 cb                	mov    %ecx,%ebx
  80132f:	89 cf                	mov    %ecx,%edi
  801331:	89 ce                	mov    %ecx,%esi
  801333:	cd 30                	int    $0x30
}

int 
sys_e1000_get_mac(uint8_t* mac_addr){
	return syscall(SYS_e1000_get_mac, 0, (uint32_t)mac_addr, 0, 0, 0, 0);
}
  801335:	5b                   	pop    %ebx
  801336:	5e                   	pop    %esi
  801337:	5f                   	pop    %edi
  801338:	5d                   	pop    %ebp
  801339:	c3                   	ret    
	...

0080133c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80133c:	55                   	push   %ebp
  80133d:	89 e5                	mov    %esp,%ebp
  80133f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801342:	83 3d d0 20 80 00 00 	cmpl   $0x0,0x8020d0
  801349:	75 58                	jne    8013a3 <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.	
		//panic("set_pgfault_handler not implemented");
		
		if (sys_page_alloc(thisenv->env_id,(void *) (UXSTACKTOP - PGSIZE),(PTE_W|PTE_U|PTE_P)) != 0){
  80134b:	a1 cc 20 80 00       	mov    0x8020cc,%eax
  801350:	8b 40 48             	mov    0x48(%eax),%eax
  801353:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80135a:	00 
  80135b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801362:	ee 
  801363:	89 04 24             	mov    %eax,(%esp)
  801366:	e8 e6 fc ff ff       	call   801051 <sys_page_alloc>
  80136b:	85 c0                	test   %eax,%eax
  80136d:	74 1c                	je     80138b <set_pgfault_handler+0x4f>
			panic("set_pg_fault_handler");
  80136f:	c7 44 24 08 b3 1a 80 	movl   $0x801ab3,0x8(%esp)
  801376:	00 
  801377:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80137e:	00 
  80137f:	c7 04 24 c8 1a 80 00 	movl   $0x801ac8,(%esp)
  801386:	e8 31 f2 ff ff       	call   8005bc <_panic>
		}
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  80138b:	a1 cc 20 80 00       	mov    0x8020cc,%eax
  801390:	8b 40 48             	mov    0x48(%eax),%eax
  801393:	c7 44 24 04 b0 13 80 	movl   $0x8013b0,0x4(%esp)
  80139a:	00 
  80139b:	89 04 24             	mov    %eax,(%esp)
  80139e:	e8 4e fe ff ff       	call   8011f1 <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8013a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a6:	a3 d0 20 80 00       	mov    %eax,0x8020d0
}
  8013ab:	c9                   	leave  
  8013ac:	c3                   	ret    
  8013ad:	00 00                	add    %al,(%eax)
	...

008013b0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8013b0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8013b1:	a1 d0 20 80 00       	mov    0x8020d0,%eax
	call *%eax
  8013b6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8013b8:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// Save trap-time eip in eax
	movl 0x28(%esp), %eax
  8013bb:	8b 44 24 28          	mov    0x28(%esp),%eax

	// Save our current stack
	movl %esp, %ebp
  8013bf:	89 e5                	mov    %esp,%ebp

	// Switch to trap-time stack
	movl 0x30(%esp), %esp
  8013c1:	8b 64 24 30          	mov    0x30(%esp),%esp

	// Push trap-time eip to the trap-time stack
	pushl %eax
  8013c5:	50                   	push   %eax

	// We now have to update the trap-time esp with its new value
	movl %esp, 0x30(%ebp)
  8013c6:	89 65 30             	mov    %esp,0x30(%ebp)

	// Go back to our exception stack
	movl %ebp, %esp
  8013c9:	89 ec                	mov    %ebp,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// Pop fault_va and err, both can be ignored
	popl %eax
  8013cb:	58                   	pop    %eax
	popl %eax
  8013cc:	58                   	pop    %eax

	// Pop all registers back
	popal
  8013cd:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// Skip %eip
	addl $0x4, %esp
  8013ce:	83 c4 04             	add    $0x4,%esp

	// Pop eflags back
	popfl
  8013d1:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	
	popl %esp
  8013d2:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  8013d3:	c3                   	ret    

008013d4 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8013d4:	55                   	push   %ebp
  8013d5:	57                   	push   %edi
  8013d6:	56                   	push   %esi
  8013d7:	83 ec 10             	sub    $0x10,%esp
  8013da:	8b 74 24 20          	mov    0x20(%esp),%esi
  8013de:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8013e2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013e6:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  8013ea:	89 cd                	mov    %ecx,%ebp
  8013ec:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8013f0:	85 c0                	test   %eax,%eax
  8013f2:	75 2c                	jne    801420 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8013f4:	39 f9                	cmp    %edi,%ecx
  8013f6:	77 68                	ja     801460 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8013f8:	85 c9                	test   %ecx,%ecx
  8013fa:	75 0b                	jne    801407 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8013fc:	b8 01 00 00 00       	mov    $0x1,%eax
  801401:	31 d2                	xor    %edx,%edx
  801403:	f7 f1                	div    %ecx
  801405:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801407:	31 d2                	xor    %edx,%edx
  801409:	89 f8                	mov    %edi,%eax
  80140b:	f7 f1                	div    %ecx
  80140d:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80140f:	89 f0                	mov    %esi,%eax
  801411:	f7 f1                	div    %ecx
  801413:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801415:	89 f0                	mov    %esi,%eax
  801417:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801419:	83 c4 10             	add    $0x10,%esp
  80141c:	5e                   	pop    %esi
  80141d:	5f                   	pop    %edi
  80141e:	5d                   	pop    %ebp
  80141f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801420:	39 f8                	cmp    %edi,%eax
  801422:	77 2c                	ja     801450 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801424:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  801427:	83 f6 1f             	xor    $0x1f,%esi
  80142a:	75 4c                	jne    801478 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80142c:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80142e:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801433:	72 0a                	jb     80143f <__udivdi3+0x6b>
  801435:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801439:	0f 87 ad 00 00 00    	ja     8014ec <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80143f:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801444:	89 f0                	mov    %esi,%eax
  801446:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801448:	83 c4 10             	add    $0x10,%esp
  80144b:	5e                   	pop    %esi
  80144c:	5f                   	pop    %edi
  80144d:	5d                   	pop    %ebp
  80144e:	c3                   	ret    
  80144f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801450:	31 ff                	xor    %edi,%edi
  801452:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801454:	89 f0                	mov    %esi,%eax
  801456:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801458:	83 c4 10             	add    $0x10,%esp
  80145b:	5e                   	pop    %esi
  80145c:	5f                   	pop    %edi
  80145d:	5d                   	pop    %ebp
  80145e:	c3                   	ret    
  80145f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801460:	89 fa                	mov    %edi,%edx
  801462:	89 f0                	mov    %esi,%eax
  801464:	f7 f1                	div    %ecx
  801466:	89 c6                	mov    %eax,%esi
  801468:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80146a:	89 f0                	mov    %esi,%eax
  80146c:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80146e:	83 c4 10             	add    $0x10,%esp
  801471:	5e                   	pop    %esi
  801472:	5f                   	pop    %edi
  801473:	5d                   	pop    %ebp
  801474:	c3                   	ret    
  801475:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801478:	89 f1                	mov    %esi,%ecx
  80147a:	d3 e0                	shl    %cl,%eax
  80147c:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801480:	b8 20 00 00 00       	mov    $0x20,%eax
  801485:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801487:	89 ea                	mov    %ebp,%edx
  801489:	88 c1                	mov    %al,%cl
  80148b:	d3 ea                	shr    %cl,%edx
  80148d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801491:	09 ca                	or     %ecx,%edx
  801493:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  801497:	89 f1                	mov    %esi,%ecx
  801499:	d3 e5                	shl    %cl,%ebp
  80149b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  80149f:	89 fd                	mov    %edi,%ebp
  8014a1:	88 c1                	mov    %al,%cl
  8014a3:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  8014a5:	89 fa                	mov    %edi,%edx
  8014a7:	89 f1                	mov    %esi,%ecx
  8014a9:	d3 e2                	shl    %cl,%edx
  8014ab:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8014af:	88 c1                	mov    %al,%cl
  8014b1:	d3 ef                	shr    %cl,%edi
  8014b3:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8014b5:	89 f8                	mov    %edi,%eax
  8014b7:	89 ea                	mov    %ebp,%edx
  8014b9:	f7 74 24 08          	divl   0x8(%esp)
  8014bd:	89 d1                	mov    %edx,%ecx
  8014bf:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  8014c1:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8014c5:	39 d1                	cmp    %edx,%ecx
  8014c7:	72 17                	jb     8014e0 <__udivdi3+0x10c>
  8014c9:	74 09                	je     8014d4 <__udivdi3+0x100>
  8014cb:	89 fe                	mov    %edi,%esi
  8014cd:	31 ff                	xor    %edi,%edi
  8014cf:	e9 41 ff ff ff       	jmp    801415 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8014d4:	8b 54 24 04          	mov    0x4(%esp),%edx
  8014d8:	89 f1                	mov    %esi,%ecx
  8014da:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8014dc:	39 c2                	cmp    %eax,%edx
  8014de:	73 eb                	jae    8014cb <__udivdi3+0xf7>
		{
		  q0--;
  8014e0:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8014e3:	31 ff                	xor    %edi,%edi
  8014e5:	e9 2b ff ff ff       	jmp    801415 <__udivdi3+0x41>
  8014ea:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8014ec:	31 f6                	xor    %esi,%esi
  8014ee:	e9 22 ff ff ff       	jmp    801415 <__udivdi3+0x41>
	...

008014f4 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8014f4:	55                   	push   %ebp
  8014f5:	57                   	push   %edi
  8014f6:	56                   	push   %esi
  8014f7:	83 ec 20             	sub    $0x20,%esp
  8014fa:	8b 44 24 30          	mov    0x30(%esp),%eax
  8014fe:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801502:	89 44 24 14          	mov    %eax,0x14(%esp)
  801506:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  80150a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80150e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801512:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  801514:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801516:	85 ed                	test   %ebp,%ebp
  801518:	75 16                	jne    801530 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  80151a:	39 f1                	cmp    %esi,%ecx
  80151c:	0f 86 a6 00 00 00    	jbe    8015c8 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801522:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801524:	89 d0                	mov    %edx,%eax
  801526:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801528:	83 c4 20             	add    $0x20,%esp
  80152b:	5e                   	pop    %esi
  80152c:	5f                   	pop    %edi
  80152d:	5d                   	pop    %ebp
  80152e:	c3                   	ret    
  80152f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801530:	39 f5                	cmp    %esi,%ebp
  801532:	0f 87 ac 00 00 00    	ja     8015e4 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801538:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  80153b:	83 f0 1f             	xor    $0x1f,%eax
  80153e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801542:	0f 84 a8 00 00 00    	je     8015f0 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801548:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80154c:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80154e:	bf 20 00 00 00       	mov    $0x20,%edi
  801553:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801557:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80155b:	89 f9                	mov    %edi,%ecx
  80155d:	d3 e8                	shr    %cl,%eax
  80155f:	09 e8                	or     %ebp,%eax
  801561:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  801565:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801569:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80156d:	d3 e0                	shl    %cl,%eax
  80156f:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801573:	89 f2                	mov    %esi,%edx
  801575:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801577:	8b 44 24 14          	mov    0x14(%esp),%eax
  80157b:	d3 e0                	shl    %cl,%eax
  80157d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801581:	8b 44 24 14          	mov    0x14(%esp),%eax
  801585:	89 f9                	mov    %edi,%ecx
  801587:	d3 e8                	shr    %cl,%eax
  801589:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80158b:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80158d:	89 f2                	mov    %esi,%edx
  80158f:	f7 74 24 18          	divl   0x18(%esp)
  801593:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801595:	f7 64 24 0c          	mull   0xc(%esp)
  801599:	89 c5                	mov    %eax,%ebp
  80159b:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80159d:	39 d6                	cmp    %edx,%esi
  80159f:	72 67                	jb     801608 <__umoddi3+0x114>
  8015a1:	74 75                	je     801618 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8015a3:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8015a7:	29 e8                	sub    %ebp,%eax
  8015a9:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8015ab:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8015af:	d3 e8                	shr    %cl,%eax
  8015b1:	89 f2                	mov    %esi,%edx
  8015b3:	89 f9                	mov    %edi,%ecx
  8015b5:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8015b7:	09 d0                	or     %edx,%eax
  8015b9:	89 f2                	mov    %esi,%edx
  8015bb:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8015bf:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8015c1:	83 c4 20             	add    $0x20,%esp
  8015c4:	5e                   	pop    %esi
  8015c5:	5f                   	pop    %edi
  8015c6:	5d                   	pop    %ebp
  8015c7:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8015c8:	85 c9                	test   %ecx,%ecx
  8015ca:	75 0b                	jne    8015d7 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8015cc:	b8 01 00 00 00       	mov    $0x1,%eax
  8015d1:	31 d2                	xor    %edx,%edx
  8015d3:	f7 f1                	div    %ecx
  8015d5:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8015d7:	89 f0                	mov    %esi,%eax
  8015d9:	31 d2                	xor    %edx,%edx
  8015db:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8015dd:	89 f8                	mov    %edi,%eax
  8015df:	e9 3e ff ff ff       	jmp    801522 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8015e4:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8015e6:	83 c4 20             	add    $0x20,%esp
  8015e9:	5e                   	pop    %esi
  8015ea:	5f                   	pop    %edi
  8015eb:	5d                   	pop    %ebp
  8015ec:	c3                   	ret    
  8015ed:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8015f0:	39 f5                	cmp    %esi,%ebp
  8015f2:	72 04                	jb     8015f8 <__umoddi3+0x104>
  8015f4:	39 f9                	cmp    %edi,%ecx
  8015f6:	77 06                	ja     8015fe <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8015f8:	89 f2                	mov    %esi,%edx
  8015fa:	29 cf                	sub    %ecx,%edi
  8015fc:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8015fe:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801600:	83 c4 20             	add    $0x20,%esp
  801603:	5e                   	pop    %esi
  801604:	5f                   	pop    %edi
  801605:	5d                   	pop    %ebp
  801606:	c3                   	ret    
  801607:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801608:	89 d1                	mov    %edx,%ecx
  80160a:	89 c5                	mov    %eax,%ebp
  80160c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801610:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801614:	eb 8d                	jmp    8015a3 <__umoddi3+0xaf>
  801616:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801618:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  80161c:	72 ea                	jb     801608 <__umoddi3+0x114>
  80161e:	89 f1                	mov    %esi,%ecx
  801620:	eb 81                	jmp    8015a3 <__umoddi3+0xaf>
