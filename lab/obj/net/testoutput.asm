
obj/net/testoutput:     file format elf32-i386


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
  80002c:	e8 43 03 00 00       	call   800374 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
static struct jif_pkt *pkt = (struct jif_pkt*)REQVA;


void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 14             	sub    $0x14,%esp
	envid_t ns_envid = sys_getenvid();
  80003b:	e8 e7 0d 00 00       	call   800e27 <sys_getenvid>
  800040:	89 c3                	mov    %eax,%ebx
	int i, r;

	binaryname = "testoutput";
  800042:	c7 05 00 30 80 00 00 	movl   $0x801c00,0x803000
  800049:	1c 80 00 

	output_envid = fork();
  80004c:	e8 0e 12 00 00       	call   80125f <fork>
  800051:	a3 00 40 80 00       	mov    %eax,0x804000
	if (output_envid < 0)
  800056:	85 c0                	test   %eax,%eax
  800058:	79 1c                	jns    800076 <umain+0x42>
		panic("error forking");
  80005a:	c7 44 24 08 0b 1c 80 	movl   $0x801c0b,0x8(%esp)
  800061:	00 
  800062:	c7 44 24 04 16 00 00 	movl   $0x16,0x4(%esp)
  800069:	00 
  80006a:	c7 04 24 19 1c 80 00 	movl   $0x801c19,(%esp)
  800071:	e8 5a 03 00 00       	call   8003d0 <_panic>
	else if (output_envid == 0) {
  800076:	85 c0                	test   %eax,%eax
  800078:	75 0d                	jne    800087 <umain+0x53>
		output(ns_envid);
  80007a:	89 1c 24             	mov    %ebx,(%esp)
  80007d:	e8 46 02 00 00       	call   8002c8 <output>
		return;
  800082:	e9 c7 00 00 00       	jmp    80014e <umain+0x11a>
	binaryname = "testoutput";

	output_envid = fork();
	if (output_envid < 0)
		panic("error forking");
	else if (output_envid == 0) {
  800087:	bb 00 00 00 00       	mov    $0x0,%ebx
		output(ns_envid);
		return;
	}

	for (i = 0; i < TESTOUTPUT_COUNT; i++) {
		if ((r = sys_page_alloc(0, pkt, PTE_P|PTE_U|PTE_W)) < 0)
  80008c:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800093:	00 
  800094:	c7 44 24 04 00 b0 fe 	movl   $0xffeb000,0x4(%esp)
  80009b:	0f 
  80009c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a3:	e8 bd 0d 00 00       	call   800e65 <sys_page_alloc>
  8000a8:	85 c0                	test   %eax,%eax
  8000aa:	79 20                	jns    8000cc <umain+0x98>
			panic("sys_page_alloc: %e", r);
  8000ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b0:	c7 44 24 08 2a 1c 80 	movl   $0x801c2a,0x8(%esp)
  8000b7:	00 
  8000b8:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  8000bf:	00 
  8000c0:	c7 04 24 19 1c 80 00 	movl   $0x801c19,(%esp)
  8000c7:	e8 04 03 00 00       	call   8003d0 <_panic>
		pkt->jp_len = snprintf(pkt->jp_data,
  8000cc:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000d0:	c7 44 24 08 3d 1c 80 	movl   $0x801c3d,0x8(%esp)
  8000d7:	00 
  8000d8:	c7 44 24 04 fc 0f 00 	movl   $0xffc,0x4(%esp)
  8000df:	00 
  8000e0:	c7 04 24 04 b0 fe 0f 	movl   $0xffeb004,(%esp)
  8000e7:	e8 29 09 00 00       	call   800a15 <snprintf>
  8000ec:	a3 00 b0 fe 0f       	mov    %eax,0xffeb000
				       PGSIZE - sizeof(pkt->jp_len),
				       "Packet %02d", i);
		cprintf("Transmitting packet %d\n", i);
  8000f1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000f5:	c7 04 24 49 1c 80 00 	movl   $0x801c49,(%esp)
  8000fc:	e8 c7 03 00 00       	call   8004c8 <cprintf>
		ipc_send(output_envid, NSREQ_OUTPUT, pkt, PTE_P|PTE_W|PTE_U);
  800101:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800108:	00 
  800109:	c7 44 24 08 00 b0 fe 	movl   $0xffeb000,0x8(%esp)
  800110:	0f 
  800111:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
  800118:	00 
  800119:	a1 00 40 80 00       	mov    0x804000,%eax
  80011e:	89 04 24             	mov    %eax,(%esp)
  800121:	e8 93 14 00 00       	call   8015b9 <ipc_send>
		sys_page_unmap(0, pkt);
  800126:	c7 44 24 04 00 b0 fe 	movl   $0xffeb000,0x4(%esp)
  80012d:	0f 
  80012e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800135:	e8 d2 0d 00 00       	call   800f0c <sys_page_unmap>
	else if (output_envid == 0) {
		output(ns_envid);
		return;
	}

	for (i = 0; i < TESTOUTPUT_COUNT; i++) {
  80013a:	43                   	inc    %ebx
  80013b:	83 fb 0a             	cmp    $0xa,%ebx
  80013e:	0f 85 48 ff ff ff    	jne    80008c <umain+0x58>
  800144:	b3 14                	mov    $0x14,%bl
		sys_page_unmap(0, pkt);
	}

	// Spin for a while, just in case IPC's or packets need to be flushed
	for (i = 0; i < TESTOUTPUT_COUNT*2; i++)
		sys_yield();
  800146:	e8 fb 0c 00 00       	call   800e46 <sys_yield>
		ipc_send(output_envid, NSREQ_OUTPUT, pkt, PTE_P|PTE_W|PTE_U);
		sys_page_unmap(0, pkt);
	}

	// Spin for a while, just in case IPC's or packets need to be flushed
	for (i = 0; i < TESTOUTPUT_COUNT*2; i++)
  80014b:	4b                   	dec    %ebx
  80014c:	75 f8                	jne    800146 <umain+0x112>
		sys_yield();
}
  80014e:	83 c4 14             	add    $0x14,%esp
  800151:	5b                   	pop    %ebx
  800152:	5d                   	pop    %ebp
  800153:	c3                   	ret    

00800154 <timer>:
#include "ns.h"

void
timer(envid_t ns_envid, uint32_t initial_to) {
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	57                   	push   %edi
  800158:	56                   	push   %esi
  800159:	53                   	push   %ebx
  80015a:	83 ec 2c             	sub    $0x2c,%esp
  80015d:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	uint32_t stop = sys_time_msec() + initial_to;
  800160:	e8 68 0f 00 00       	call   8010cd <sys_time_msec>
  800165:	89 c3                	mov    %eax,%ebx
  800167:	03 5d 0c             	add    0xc(%ebp),%ebx

	binaryname = "ns_timer";
  80016a:	c7 05 00 30 80 00 61 	movl   $0x801c61,0x803000
  800171:	1c 80 00 

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  800174:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800177:	eb 05                	jmp    80017e <timer+0x2a>

	binaryname = "ns_timer";

	while (1) {
		while((r = sys_time_msec()) < stop && r >= 0) {
			sys_yield();
  800179:	e8 c8 0c 00 00       	call   800e46 <sys_yield>
	uint32_t stop = sys_time_msec() + initial_to;

	binaryname = "ns_timer";

	while (1) {
		while((r = sys_time_msec()) < stop && r >= 0) {
  80017e:	e8 4a 0f 00 00       	call   8010cd <sys_time_msec>
  800183:	39 c3                	cmp    %eax,%ebx
  800185:	76 06                	jbe    80018d <timer+0x39>
  800187:	85 c0                	test   %eax,%eax
  800189:	79 ee                	jns    800179 <timer+0x25>
  80018b:	eb 04                	jmp    800191 <timer+0x3d>
			sys_yield();
		}
		if (r < 0)
  80018d:	85 c0                	test   %eax,%eax
  80018f:	79 20                	jns    8001b1 <timer+0x5d>
			panic("sys_time_msec: %e", r);
  800191:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800195:	c7 44 24 08 6a 1c 80 	movl   $0x801c6a,0x8(%esp)
  80019c:	00 
  80019d:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  8001a4:	00 
  8001a5:	c7 04 24 7c 1c 80 00 	movl   $0x801c7c,(%esp)
  8001ac:	e8 1f 02 00 00       	call   8003d0 <_panic>

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);
  8001b1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001b8:	00 
  8001b9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8001c0:	00 
  8001c1:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
  8001c8:	00 
  8001c9:	89 3c 24             	mov    %edi,(%esp)
  8001cc:	e8 e8 13 00 00       	call   8015b9 <ipc_send>

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  8001d1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8001d8:	00 
  8001d9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8001e0:	00 
  8001e1:	89 34 24             	mov    %esi,(%esp)
  8001e4:	e8 67 13 00 00       	call   801550 <ipc_recv>
  8001e9:	89 c3                	mov    %eax,%ebx

			if (whom != ns_envid) {
  8001eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001ee:	39 c7                	cmp    %eax,%edi
  8001f0:	74 12                	je     800204 <timer+0xb0>
				cprintf("NS TIMER: timer thread got IPC message from env %x not NS\n", whom);
  8001f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f6:	c7 04 24 88 1c 80 00 	movl   $0x801c88,(%esp)
  8001fd:	e8 c6 02 00 00       	call   8004c8 <cprintf>
				continue;
			}

			stop = sys_time_msec() + to;
			break;
		}
  800202:	eb cd                	jmp    8001d1 <timer+0x7d>
			if (whom != ns_envid) {
				cprintf("NS TIMER: timer thread got IPC message from env %x not NS\n", whom);
				continue;
			}

			stop = sys_time_msec() + to;
  800204:	e8 c4 0e 00 00       	call   8010cd <sys_time_msec>
  800209:	01 c3                	add    %eax,%ebx
			break;
		}
	}
  80020b:	e9 6e ff ff ff       	jmp    80017e <timer+0x2a>

00800210 <input>:

extern union Nsipc nsipcbuf;

void
input(envid_t ns_envid)
{
  800210:	55                   	push   %ebp
  800211:	89 e5                	mov    %esp,%ebp
  800213:	57                   	push   %edi
  800214:	56                   	push   %esi
  800215:	53                   	push   %ebx
  800216:	81 ec 2c 08 00 00    	sub    $0x82c,%esp
  80021c:	8b 7d 08             	mov    0x8(%ebp),%edi
	binaryname = "ns_input";
  80021f:	c7 05 00 30 80 00 c3 	movl   $0x801cc3,0x803000
  800226:	1c 80 00 
	int perm = PTE_P | PTE_W | PTE_U;
	size_t length;
	char pkt[PKT_SIZE];

	while (1) {
		while (sys_e1000_receive(pkt, &length) == -E_E1000_RXBUF_EMPTY)
  800229:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80022c:	8d 9d e4 f7 ff ff    	lea    -0x81c(%ebp),%ebx
  800232:	89 74 24 04          	mov    %esi,0x4(%esp)
  800236:	89 1c 24             	mov    %ebx,(%esp)
  800239:	e8 cf 0e 00 00       	call   80110d <sys_e1000_receive>
  80023e:	83 f8 ef             	cmp    $0xffffffef,%eax
  800241:	74 ef                	je     800232 <input+0x22>
		  ;

		int r;
		if ((r = sys_page_alloc(0, &nsipcbuf, perm)) < 0)
  800243:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80024a:	00 
  80024b:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800252:	00 
  800253:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80025a:	e8 06 0c 00 00       	call   800e65 <sys_page_alloc>
  80025f:	85 c0                	test   %eax,%eax
  800261:	79 20                	jns    800283 <input+0x73>
		  panic("input: unable to allocate new page, error %e\n", r);
  800263:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800267:	c7 44 24 08 d8 1c 80 	movl   $0x801cd8,0x8(%esp)
  80026e:	00 
  80026f:	c7 44 24 04 1c 00 00 	movl   $0x1c,0x4(%esp)
  800276:	00 
  800277:	c7 04 24 cc 1c 80 00 	movl   $0x801ccc,(%esp)
  80027e:	e8 4d 01 00 00       	call   8003d0 <_panic>

		memmove(nsipcbuf.pkt.jp_data, pkt, length);
  800283:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800286:	89 44 24 08          	mov    %eax,0x8(%esp)
  80028a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80028e:	c7 04 24 04 50 80 00 	movl   $0x805004,(%esp)
  800295:	e8 52 09 00 00       	call   800bec <memmove>
		nsipcbuf.pkt.jp_len = length;
  80029a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80029d:	a3 00 50 80 00       	mov    %eax,0x805000

		ipc_send(ns_envid, NSREQ_INPUT, &nsipcbuf, perm);
  8002a2:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8002a9:	00 
  8002aa:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8002b1:	00 
  8002b2:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
  8002b9:	00 
  8002ba:	89 3c 24             	mov    %edi,(%esp)
  8002bd:	e8 f7 12 00 00       	call   8015b9 <ipc_send>
	}
  8002c2:	e9 6b ff ff ff       	jmp    800232 <input+0x22>
	...

008002c8 <output>:

extern union Nsipc nsipcbuf;

void
output(envid_t ns_envid)
{
  8002c8:	55                   	push   %ebp
  8002c9:	89 e5                	mov    %esp,%ebp
  8002cb:	57                   	push   %edi
  8002cc:	56                   	push   %esi
  8002cd:	53                   	push   %ebx
  8002ce:	83 ec 2c             	sub    $0x2c,%esp
  8002d1:	8b 7d 08             	mov    0x8(%ebp),%edi
	binaryname = "ns_output";
  8002d4:	c7 05 00 30 80 00 06 	movl   $0x801d06,0x803000
  8002db:	1d 80 00 
	//	- send the packet to the device driver
	int r;
	int perm;
	envid_t sender_envid;
	while(1){
		r = ipc_recv(&sender_envid, (void*)&nsipcbuf, &perm);
  8002de:	8d 5d e4             	lea    -0x1c(%ebp),%ebx
  8002e1:	8d 75 e0             	lea    -0x20(%ebp),%esi
  8002e4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002e8:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8002ef:	00 
  8002f0:	89 34 24             	mov    %esi,(%esp)
  8002f3:	e8 58 12 00 00       	call   801550 <ipc_recv>
		if (r < 0 || (uint32_t*)sender_envid == 0){
  8002f8:	85 c0                	test   %eax,%eax
  8002fa:	78 07                	js     800303 <output+0x3b>
  8002fc:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8002ff:	85 d2                	test   %edx,%edx
  800301:	75 12                	jne    800315 <output+0x4d>
			cprintf("output: ipc_recv failed, %e", r);
  800303:	89 44 24 04          	mov    %eax,0x4(%esp)
  800307:	c7 04 24 10 1d 80 00 	movl   $0x801d10,(%esp)
  80030e:	e8 b5 01 00 00       	call   8004c8 <cprintf>
			continue;
  800313:	eb cf                	jmp    8002e4 <output+0x1c>
		}

		if (sender_envid != ns_envid) {
  800315:	39 fa                	cmp    %edi,%edx
  800317:	74 16                	je     80032f <output+0x67>
			cprintf("output: receive from %08x, expect to receive from %08x", sender_envid, ns_envid);
  800319:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80031d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800321:	c7 04 24 48 1d 80 00 	movl   $0x801d48,(%esp)
  800328:	e8 9b 01 00 00       	call   8004c8 <cprintf>
			continue;
  80032d:	eb b5                	jmp    8002e4 <output+0x1c>
		}
		
		if (!(perm & PTE_P)){
  80032f:	f6 45 e4 01          	testb  $0x1,-0x1c(%ebp)
  800333:	75 0e                	jne    800343 <output+0x7b>
			cprintf("output: permission failed");
  800335:	c7 04 24 2c 1d 80 00 	movl   $0x801d2c,(%esp)
  80033c:	e8 87 01 00 00       	call   8004c8 <cprintf>
			continue;
  800341:	eb a1                	jmp    8002e4 <output+0x1c>
		}

		if ((r = sys_e1000_transmit(nsipcbuf.pkt.jp_data, nsipcbuf.pkt.jp_len)) < 0){
  800343:	a1 00 50 80 00       	mov    0x805000,%eax
  800348:	89 44 24 04          	mov    %eax,0x4(%esp)
  80034c:	c7 04 24 04 50 80 00 	movl   $0x805004,(%esp)
  800353:	e8 94 0d 00 00       	call   8010ec <sys_e1000_transmit>
  800358:	85 c0                	test   %eax,%eax
  80035a:	79 88                	jns    8002e4 <output+0x1c>
			cprintf("output: sys_e1000_transmit failed, %e", r);
  80035c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800360:	c7 04 24 80 1d 80 00 	movl   $0x801d80,(%esp)
  800367:	e8 5c 01 00 00       	call   8004c8 <cprintf>
  80036c:	e9 73 ff ff ff       	jmp    8002e4 <output+0x1c>
  800371:	00 00                	add    %al,(%eax)
	...

00800374 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800374:	55                   	push   %ebp
  800375:	89 e5                	mov    %esp,%ebp
  800377:	56                   	push   %esi
  800378:	53                   	push   %ebx
  800379:	83 ec 10             	sub    $0x10,%esp
  80037c:	8b 75 08             	mov    0x8(%ebp),%esi
  80037f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800382:	e8 a0 0a 00 00       	call   800e27 <sys_getenvid>
  800387:	25 ff 03 00 00       	and    $0x3ff,%eax
  80038c:	c1 e0 07             	shl    $0x7,%eax
  80038f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800394:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800399:	85 f6                	test   %esi,%esi
  80039b:	7e 07                	jle    8003a4 <libmain+0x30>
		binaryname = argv[0];
  80039d:	8b 03                	mov    (%ebx),%eax
  80039f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8003a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003a8:	89 34 24             	mov    %esi,(%esp)
  8003ab:	e8 84 fc ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8003b0:	e8 07 00 00 00       	call   8003bc <exit>
}
  8003b5:	83 c4 10             	add    $0x10,%esp
  8003b8:	5b                   	pop    %ebx
  8003b9:	5e                   	pop    %esi
  8003ba:	5d                   	pop    %ebp
  8003bb:	c3                   	ret    

008003bc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8003bc:	55                   	push   %ebp
  8003bd:	89 e5                	mov    %esp,%ebp
  8003bf:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  8003c2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8003c9:	e8 07 0a 00 00       	call   800dd5 <sys_env_destroy>
}
  8003ce:	c9                   	leave  
  8003cf:	c3                   	ret    

008003d0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003d0:	55                   	push   %ebp
  8003d1:	89 e5                	mov    %esp,%ebp
  8003d3:	56                   	push   %esi
  8003d4:	53                   	push   %ebx
  8003d5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8003d8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003db:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8003e1:	e8 41 0a 00 00       	call   800e27 <sys_getenvid>
  8003e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003e9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8003f0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003f4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003fc:	c7 04 24 b0 1d 80 00 	movl   $0x801db0,(%esp)
  800403:	e8 c0 00 00 00       	call   8004c8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800408:	89 74 24 04          	mov    %esi,0x4(%esp)
  80040c:	8b 45 10             	mov    0x10(%ebp),%eax
  80040f:	89 04 24             	mov    %eax,(%esp)
  800412:	e8 50 00 00 00       	call   800467 <vcprintf>
	cprintf("\n");
  800417:	c7 04 24 5f 1c 80 00 	movl   $0x801c5f,(%esp)
  80041e:	e8 a5 00 00 00       	call   8004c8 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800423:	cc                   	int3   
  800424:	eb fd                	jmp    800423 <_panic+0x53>
	...

00800428 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800428:	55                   	push   %ebp
  800429:	89 e5                	mov    %esp,%ebp
  80042b:	53                   	push   %ebx
  80042c:	83 ec 14             	sub    $0x14,%esp
  80042f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800432:	8b 03                	mov    (%ebx),%eax
  800434:	8b 55 08             	mov    0x8(%ebp),%edx
  800437:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80043b:	40                   	inc    %eax
  80043c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80043e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800443:	75 19                	jne    80045e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800445:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80044c:	00 
  80044d:	8d 43 08             	lea    0x8(%ebx),%eax
  800450:	89 04 24             	mov    %eax,(%esp)
  800453:	e8 40 09 00 00       	call   800d98 <sys_cputs>
		b->idx = 0;
  800458:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80045e:	ff 43 04             	incl   0x4(%ebx)
}
  800461:	83 c4 14             	add    $0x14,%esp
  800464:	5b                   	pop    %ebx
  800465:	5d                   	pop    %ebp
  800466:	c3                   	ret    

00800467 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800467:	55                   	push   %ebp
  800468:	89 e5                	mov    %esp,%ebp
  80046a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800470:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800477:	00 00 00 
	b.cnt = 0;
  80047a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800481:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800484:	8b 45 0c             	mov    0xc(%ebp),%eax
  800487:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80048b:	8b 45 08             	mov    0x8(%ebp),%eax
  80048e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800492:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800498:	89 44 24 04          	mov    %eax,0x4(%esp)
  80049c:	c7 04 24 28 04 80 00 	movl   $0x800428,(%esp)
  8004a3:	e8 82 01 00 00       	call   80062a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004a8:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8004ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004b2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004b8:	89 04 24             	mov    %eax,(%esp)
  8004bb:	e8 d8 08 00 00       	call   800d98 <sys_cputs>

	return b.cnt;
}
  8004c0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004c6:	c9                   	leave  
  8004c7:	c3                   	ret    

008004c8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004c8:	55                   	push   %ebp
  8004c9:	89 e5                	mov    %esp,%ebp
  8004cb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004ce:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8004d8:	89 04 24             	mov    %eax,(%esp)
  8004db:	e8 87 ff ff ff       	call   800467 <vcprintf>
	va_end(ap);

	return cnt;
}
  8004e0:	c9                   	leave  
  8004e1:	c3                   	ret    
	...

008004e4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004e4:	55                   	push   %ebp
  8004e5:	89 e5                	mov    %esp,%ebp
  8004e7:	57                   	push   %edi
  8004e8:	56                   	push   %esi
  8004e9:	53                   	push   %ebx
  8004ea:	83 ec 3c             	sub    $0x3c,%esp
  8004ed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004f0:	89 d7                	mov    %edx,%edi
  8004f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004fe:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800501:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800504:	85 c0                	test   %eax,%eax
  800506:	75 08                	jne    800510 <printnum+0x2c>
  800508:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80050b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80050e:	77 57                	ja     800567 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800510:	89 74 24 10          	mov    %esi,0x10(%esp)
  800514:	4b                   	dec    %ebx
  800515:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800519:	8b 45 10             	mov    0x10(%ebp),%eax
  80051c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800520:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800524:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800528:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80052f:	00 
  800530:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800533:	89 04 24             	mov    %eax,(%esp)
  800536:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800539:	89 44 24 04          	mov    %eax,0x4(%esp)
  80053d:	e8 6e 14 00 00       	call   8019b0 <__udivdi3>
  800542:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800546:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80054a:	89 04 24             	mov    %eax,(%esp)
  80054d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800551:	89 fa                	mov    %edi,%edx
  800553:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800556:	e8 89 ff ff ff       	call   8004e4 <printnum>
  80055b:	eb 0f                	jmp    80056c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80055d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800561:	89 34 24             	mov    %esi,(%esp)
  800564:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800567:	4b                   	dec    %ebx
  800568:	85 db                	test   %ebx,%ebx
  80056a:	7f f1                	jg     80055d <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80056c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800570:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800574:	8b 45 10             	mov    0x10(%ebp),%eax
  800577:	89 44 24 08          	mov    %eax,0x8(%esp)
  80057b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800582:	00 
  800583:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800586:	89 04 24             	mov    %eax,(%esp)
  800589:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80058c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800590:	e8 3b 15 00 00       	call   801ad0 <__umoddi3>
  800595:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800599:	0f be 80 d3 1d 80 00 	movsbl 0x801dd3(%eax),%eax
  8005a0:	89 04 24             	mov    %eax,(%esp)
  8005a3:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8005a6:	83 c4 3c             	add    $0x3c,%esp
  8005a9:	5b                   	pop    %ebx
  8005aa:	5e                   	pop    %esi
  8005ab:	5f                   	pop    %edi
  8005ac:	5d                   	pop    %ebp
  8005ad:	c3                   	ret    

008005ae <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8005ae:	55                   	push   %ebp
  8005af:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8005b1:	83 fa 01             	cmp    $0x1,%edx
  8005b4:	7e 0e                	jle    8005c4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8005b6:	8b 10                	mov    (%eax),%edx
  8005b8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8005bb:	89 08                	mov    %ecx,(%eax)
  8005bd:	8b 02                	mov    (%edx),%eax
  8005bf:	8b 52 04             	mov    0x4(%edx),%edx
  8005c2:	eb 22                	jmp    8005e6 <getuint+0x38>
	else if (lflag)
  8005c4:	85 d2                	test   %edx,%edx
  8005c6:	74 10                	je     8005d8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8005c8:	8b 10                	mov    (%eax),%edx
  8005ca:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005cd:	89 08                	mov    %ecx,(%eax)
  8005cf:	8b 02                	mov    (%edx),%eax
  8005d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8005d6:	eb 0e                	jmp    8005e6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005d8:	8b 10                	mov    (%eax),%edx
  8005da:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005dd:	89 08                	mov    %ecx,(%eax)
  8005df:	8b 02                	mov    (%edx),%eax
  8005e1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005e6:	5d                   	pop    %ebp
  8005e7:	c3                   	ret    

008005e8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005e8:	55                   	push   %ebp
  8005e9:	89 e5                	mov    %esp,%ebp
  8005eb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005ee:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8005f1:	8b 10                	mov    (%eax),%edx
  8005f3:	3b 50 04             	cmp    0x4(%eax),%edx
  8005f6:	73 08                	jae    800600 <sprintputch+0x18>
		*b->buf++ = ch;
  8005f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8005fb:	88 0a                	mov    %cl,(%edx)
  8005fd:	42                   	inc    %edx
  8005fe:	89 10                	mov    %edx,(%eax)
}
  800600:	5d                   	pop    %ebp
  800601:	c3                   	ret    

00800602 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800602:	55                   	push   %ebp
  800603:	89 e5                	mov    %esp,%ebp
  800605:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800608:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80060b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80060f:	8b 45 10             	mov    0x10(%ebp),%eax
  800612:	89 44 24 08          	mov    %eax,0x8(%esp)
  800616:	8b 45 0c             	mov    0xc(%ebp),%eax
  800619:	89 44 24 04          	mov    %eax,0x4(%esp)
  80061d:	8b 45 08             	mov    0x8(%ebp),%eax
  800620:	89 04 24             	mov    %eax,(%esp)
  800623:	e8 02 00 00 00       	call   80062a <vprintfmt>
	va_end(ap);
}
  800628:	c9                   	leave  
  800629:	c3                   	ret    

0080062a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80062a:	55                   	push   %ebp
  80062b:	89 e5                	mov    %esp,%ebp
  80062d:	57                   	push   %edi
  80062e:	56                   	push   %esi
  80062f:	53                   	push   %ebx
  800630:	83 ec 4c             	sub    $0x4c,%esp
  800633:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800636:	8b 75 10             	mov    0x10(%ebp),%esi
  800639:	eb 12                	jmp    80064d <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80063b:	85 c0                	test   %eax,%eax
  80063d:	0f 84 6b 03 00 00    	je     8009ae <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800643:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800647:	89 04 24             	mov    %eax,(%esp)
  80064a:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80064d:	0f b6 06             	movzbl (%esi),%eax
  800650:	46                   	inc    %esi
  800651:	83 f8 25             	cmp    $0x25,%eax
  800654:	75 e5                	jne    80063b <vprintfmt+0x11>
  800656:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80065a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800661:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800666:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80066d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800672:	eb 26                	jmp    80069a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800674:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800677:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80067b:	eb 1d                	jmp    80069a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800680:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800684:	eb 14                	jmp    80069a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800686:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800689:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800690:	eb 08                	jmp    80069a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800692:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800695:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069a:	0f b6 06             	movzbl (%esi),%eax
  80069d:	8d 56 01             	lea    0x1(%esi),%edx
  8006a0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8006a3:	8a 16                	mov    (%esi),%dl
  8006a5:	83 ea 23             	sub    $0x23,%edx
  8006a8:	80 fa 55             	cmp    $0x55,%dl
  8006ab:	0f 87 e1 02 00 00    	ja     800992 <vprintfmt+0x368>
  8006b1:	0f b6 d2             	movzbl %dl,%edx
  8006b4:	ff 24 95 20 1f 80 00 	jmp    *0x801f20(,%edx,4)
  8006bb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006be:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8006c3:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8006c6:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8006ca:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8006cd:	8d 50 d0             	lea    -0x30(%eax),%edx
  8006d0:	83 fa 09             	cmp    $0x9,%edx
  8006d3:	77 2a                	ja     8006ff <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8006d5:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8006d6:	eb eb                	jmp    8006c3 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8006d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006db:	8d 50 04             	lea    0x4(%eax),%edx
  8006de:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e1:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8006e6:	eb 17                	jmp    8006ff <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8006e8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006ec:	78 98                	js     800686 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ee:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006f1:	eb a7                	jmp    80069a <vprintfmt+0x70>
  8006f3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006f6:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8006fd:	eb 9b                	jmp    80069a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8006ff:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800703:	79 95                	jns    80069a <vprintfmt+0x70>
  800705:	eb 8b                	jmp    800692 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800707:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800708:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80070b:	eb 8d                	jmp    80069a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80070d:	8b 45 14             	mov    0x14(%ebp),%eax
  800710:	8d 50 04             	lea    0x4(%eax),%edx
  800713:	89 55 14             	mov    %edx,0x14(%ebp)
  800716:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80071a:	8b 00                	mov    (%eax),%eax
  80071c:	89 04 24             	mov    %eax,(%esp)
  80071f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800722:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800725:	e9 23 ff ff ff       	jmp    80064d <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80072a:	8b 45 14             	mov    0x14(%ebp),%eax
  80072d:	8d 50 04             	lea    0x4(%eax),%edx
  800730:	89 55 14             	mov    %edx,0x14(%ebp)
  800733:	8b 00                	mov    (%eax),%eax
  800735:	85 c0                	test   %eax,%eax
  800737:	79 02                	jns    80073b <vprintfmt+0x111>
  800739:	f7 d8                	neg    %eax
  80073b:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80073d:	83 f8 11             	cmp    $0x11,%eax
  800740:	7f 0b                	jg     80074d <vprintfmt+0x123>
  800742:	8b 04 85 80 20 80 00 	mov    0x802080(,%eax,4),%eax
  800749:	85 c0                	test   %eax,%eax
  80074b:	75 23                	jne    800770 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80074d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800751:	c7 44 24 08 eb 1d 80 	movl   $0x801deb,0x8(%esp)
  800758:	00 
  800759:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80075d:	8b 45 08             	mov    0x8(%ebp),%eax
  800760:	89 04 24             	mov    %eax,(%esp)
  800763:	e8 9a fe ff ff       	call   800602 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800768:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80076b:	e9 dd fe ff ff       	jmp    80064d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800770:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800774:	c7 44 24 08 5d 22 80 	movl   $0x80225d,0x8(%esp)
  80077b:	00 
  80077c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800780:	8b 55 08             	mov    0x8(%ebp),%edx
  800783:	89 14 24             	mov    %edx,(%esp)
  800786:	e8 77 fe ff ff       	call   800602 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80078b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80078e:	e9 ba fe ff ff       	jmp    80064d <vprintfmt+0x23>
  800793:	89 f9                	mov    %edi,%ecx
  800795:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800798:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80079b:	8b 45 14             	mov    0x14(%ebp),%eax
  80079e:	8d 50 04             	lea    0x4(%eax),%edx
  8007a1:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a4:	8b 30                	mov    (%eax),%esi
  8007a6:	85 f6                	test   %esi,%esi
  8007a8:	75 05                	jne    8007af <vprintfmt+0x185>
				p = "(null)";
  8007aa:	be e4 1d 80 00       	mov    $0x801de4,%esi
			if (width > 0 && padc != '-')
  8007af:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8007b3:	0f 8e 84 00 00 00    	jle    80083d <vprintfmt+0x213>
  8007b9:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8007bd:	74 7e                	je     80083d <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8007bf:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007c3:	89 34 24             	mov    %esi,(%esp)
  8007c6:	e8 8b 02 00 00       	call   800a56 <strnlen>
  8007cb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007ce:	29 c2                	sub    %eax,%edx
  8007d0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8007d3:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8007d7:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8007da:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8007dd:	89 de                	mov    %ebx,%esi
  8007df:	89 d3                	mov    %edx,%ebx
  8007e1:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007e3:	eb 0b                	jmp    8007f0 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8007e5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007e9:	89 3c 24             	mov    %edi,(%esp)
  8007ec:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007ef:	4b                   	dec    %ebx
  8007f0:	85 db                	test   %ebx,%ebx
  8007f2:	7f f1                	jg     8007e5 <vprintfmt+0x1bb>
  8007f4:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8007f7:	89 f3                	mov    %esi,%ebx
  8007f9:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8007fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007ff:	85 c0                	test   %eax,%eax
  800801:	79 05                	jns    800808 <vprintfmt+0x1de>
  800803:	b8 00 00 00 00       	mov    $0x0,%eax
  800808:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80080b:	29 c2                	sub    %eax,%edx
  80080d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800810:	eb 2b                	jmp    80083d <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800812:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800816:	74 18                	je     800830 <vprintfmt+0x206>
  800818:	8d 50 e0             	lea    -0x20(%eax),%edx
  80081b:	83 fa 5e             	cmp    $0x5e,%edx
  80081e:	76 10                	jbe    800830 <vprintfmt+0x206>
					putch('?', putdat);
  800820:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800824:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80082b:	ff 55 08             	call   *0x8(%ebp)
  80082e:	eb 0a                	jmp    80083a <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800830:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800834:	89 04 24             	mov    %eax,(%esp)
  800837:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80083a:	ff 4d e4             	decl   -0x1c(%ebp)
  80083d:	0f be 06             	movsbl (%esi),%eax
  800840:	46                   	inc    %esi
  800841:	85 c0                	test   %eax,%eax
  800843:	74 21                	je     800866 <vprintfmt+0x23c>
  800845:	85 ff                	test   %edi,%edi
  800847:	78 c9                	js     800812 <vprintfmt+0x1e8>
  800849:	4f                   	dec    %edi
  80084a:	79 c6                	jns    800812 <vprintfmt+0x1e8>
  80084c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80084f:	89 de                	mov    %ebx,%esi
  800851:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800854:	eb 18                	jmp    80086e <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800856:	89 74 24 04          	mov    %esi,0x4(%esp)
  80085a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800861:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800863:	4b                   	dec    %ebx
  800864:	eb 08                	jmp    80086e <vprintfmt+0x244>
  800866:	8b 7d 08             	mov    0x8(%ebp),%edi
  800869:	89 de                	mov    %ebx,%esi
  80086b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80086e:	85 db                	test   %ebx,%ebx
  800870:	7f e4                	jg     800856 <vprintfmt+0x22c>
  800872:	89 7d 08             	mov    %edi,0x8(%ebp)
  800875:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800877:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80087a:	e9 ce fd ff ff       	jmp    80064d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80087f:	83 f9 01             	cmp    $0x1,%ecx
  800882:	7e 10                	jle    800894 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800884:	8b 45 14             	mov    0x14(%ebp),%eax
  800887:	8d 50 08             	lea    0x8(%eax),%edx
  80088a:	89 55 14             	mov    %edx,0x14(%ebp)
  80088d:	8b 30                	mov    (%eax),%esi
  80088f:	8b 78 04             	mov    0x4(%eax),%edi
  800892:	eb 26                	jmp    8008ba <vprintfmt+0x290>
	else if (lflag)
  800894:	85 c9                	test   %ecx,%ecx
  800896:	74 12                	je     8008aa <vprintfmt+0x280>
		return va_arg(*ap, long);
  800898:	8b 45 14             	mov    0x14(%ebp),%eax
  80089b:	8d 50 04             	lea    0x4(%eax),%edx
  80089e:	89 55 14             	mov    %edx,0x14(%ebp)
  8008a1:	8b 30                	mov    (%eax),%esi
  8008a3:	89 f7                	mov    %esi,%edi
  8008a5:	c1 ff 1f             	sar    $0x1f,%edi
  8008a8:	eb 10                	jmp    8008ba <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8008aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ad:	8d 50 04             	lea    0x4(%eax),%edx
  8008b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8008b3:	8b 30                	mov    (%eax),%esi
  8008b5:	89 f7                	mov    %esi,%edi
  8008b7:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8008ba:	85 ff                	test   %edi,%edi
  8008bc:	78 0a                	js     8008c8 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8008be:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008c3:	e9 8c 00 00 00       	jmp    800954 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8008c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008cc:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8008d3:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8008d6:	f7 de                	neg    %esi
  8008d8:	83 d7 00             	adc    $0x0,%edi
  8008db:	f7 df                	neg    %edi
			}
			base = 10;
  8008dd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008e2:	eb 70                	jmp    800954 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8008e4:	89 ca                	mov    %ecx,%edx
  8008e6:	8d 45 14             	lea    0x14(%ebp),%eax
  8008e9:	e8 c0 fc ff ff       	call   8005ae <getuint>
  8008ee:	89 c6                	mov    %eax,%esi
  8008f0:	89 d7                	mov    %edx,%edi
			base = 10;
  8008f2:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8008f7:	eb 5b                	jmp    800954 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  8008f9:	89 ca                	mov    %ecx,%edx
  8008fb:	8d 45 14             	lea    0x14(%ebp),%eax
  8008fe:	e8 ab fc ff ff       	call   8005ae <getuint>
  800903:	89 c6                	mov    %eax,%esi
  800905:	89 d7                	mov    %edx,%edi
			base = 8;
  800907:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80090c:	eb 46                	jmp    800954 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  80090e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800912:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800919:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80091c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800920:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800927:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80092a:	8b 45 14             	mov    0x14(%ebp),%eax
  80092d:	8d 50 04             	lea    0x4(%eax),%edx
  800930:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800933:	8b 30                	mov    (%eax),%esi
  800935:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80093a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80093f:	eb 13                	jmp    800954 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800941:	89 ca                	mov    %ecx,%edx
  800943:	8d 45 14             	lea    0x14(%ebp),%eax
  800946:	e8 63 fc ff ff       	call   8005ae <getuint>
  80094b:	89 c6                	mov    %eax,%esi
  80094d:	89 d7                	mov    %edx,%edi
			base = 16;
  80094f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800954:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800958:	89 54 24 10          	mov    %edx,0x10(%esp)
  80095c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80095f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800963:	89 44 24 08          	mov    %eax,0x8(%esp)
  800967:	89 34 24             	mov    %esi,(%esp)
  80096a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80096e:	89 da                	mov    %ebx,%edx
  800970:	8b 45 08             	mov    0x8(%ebp),%eax
  800973:	e8 6c fb ff ff       	call   8004e4 <printnum>
			break;
  800978:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80097b:	e9 cd fc ff ff       	jmp    80064d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800980:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800984:	89 04 24             	mov    %eax,(%esp)
  800987:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80098a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80098d:	e9 bb fc ff ff       	jmp    80064d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800992:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800996:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80099d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009a0:	eb 01                	jmp    8009a3 <vprintfmt+0x379>
  8009a2:	4e                   	dec    %esi
  8009a3:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8009a7:	75 f9                	jne    8009a2 <vprintfmt+0x378>
  8009a9:	e9 9f fc ff ff       	jmp    80064d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8009ae:	83 c4 4c             	add    $0x4c,%esp
  8009b1:	5b                   	pop    %ebx
  8009b2:	5e                   	pop    %esi
  8009b3:	5f                   	pop    %edi
  8009b4:	5d                   	pop    %ebp
  8009b5:	c3                   	ret    

008009b6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009b6:	55                   	push   %ebp
  8009b7:	89 e5                	mov    %esp,%ebp
  8009b9:	83 ec 28             	sub    $0x28,%esp
  8009bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bf:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009c5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009c9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009cc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009d3:	85 c0                	test   %eax,%eax
  8009d5:	74 30                	je     800a07 <vsnprintf+0x51>
  8009d7:	85 d2                	test   %edx,%edx
  8009d9:	7e 33                	jle    800a0e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009db:	8b 45 14             	mov    0x14(%ebp),%eax
  8009de:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009e2:	8b 45 10             	mov    0x10(%ebp),%eax
  8009e5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009e9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009f0:	c7 04 24 e8 05 80 00 	movl   $0x8005e8,(%esp)
  8009f7:	e8 2e fc ff ff       	call   80062a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009ff:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a05:	eb 0c                	jmp    800a13 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a07:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a0c:	eb 05                	jmp    800a13 <vsnprintf+0x5d>
  800a0e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a13:	c9                   	leave  
  800a14:	c3                   	ret    

00800a15 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a1b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a1e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a22:	8b 45 10             	mov    0x10(%ebp),%eax
  800a25:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a29:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a30:	8b 45 08             	mov    0x8(%ebp),%eax
  800a33:	89 04 24             	mov    %eax,(%esp)
  800a36:	e8 7b ff ff ff       	call   8009b6 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a3b:	c9                   	leave  
  800a3c:	c3                   	ret    
  800a3d:	00 00                	add    %al,(%eax)
	...

00800a40 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a40:	55                   	push   %ebp
  800a41:	89 e5                	mov    %esp,%ebp
  800a43:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a46:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4b:	eb 01                	jmp    800a4e <strlen+0xe>
		n++;
  800a4d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a4e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a52:	75 f9                	jne    800a4d <strlen+0xd>
		n++;
	return n;
}
  800a54:	5d                   	pop    %ebp
  800a55:	c3                   	ret    

00800a56 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a56:	55                   	push   %ebp
  800a57:	89 e5                	mov    %esp,%ebp
  800a59:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800a5c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a5f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a64:	eb 01                	jmp    800a67 <strnlen+0x11>
		n++;
  800a66:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a67:	39 d0                	cmp    %edx,%eax
  800a69:	74 06                	je     800a71 <strnlen+0x1b>
  800a6b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a6f:	75 f5                	jne    800a66 <strnlen+0x10>
		n++;
	return n;
}
  800a71:	5d                   	pop    %ebp
  800a72:	c3                   	ret    

00800a73 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a73:	55                   	push   %ebp
  800a74:	89 e5                	mov    %esp,%ebp
  800a76:	53                   	push   %ebx
  800a77:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a7d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a82:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800a85:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a88:	42                   	inc    %edx
  800a89:	84 c9                	test   %cl,%cl
  800a8b:	75 f5                	jne    800a82 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a8d:	5b                   	pop    %ebx
  800a8e:	5d                   	pop    %ebp
  800a8f:	c3                   	ret    

00800a90 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a90:	55                   	push   %ebp
  800a91:	89 e5                	mov    %esp,%ebp
  800a93:	53                   	push   %ebx
  800a94:	83 ec 08             	sub    $0x8,%esp
  800a97:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a9a:	89 1c 24             	mov    %ebx,(%esp)
  800a9d:	e8 9e ff ff ff       	call   800a40 <strlen>
	strcpy(dst + len, src);
  800aa2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aa5:	89 54 24 04          	mov    %edx,0x4(%esp)
  800aa9:	01 d8                	add    %ebx,%eax
  800aab:	89 04 24             	mov    %eax,(%esp)
  800aae:	e8 c0 ff ff ff       	call   800a73 <strcpy>
	return dst;
}
  800ab3:	89 d8                	mov    %ebx,%eax
  800ab5:	83 c4 08             	add    $0x8,%esp
  800ab8:	5b                   	pop    %ebx
  800ab9:	5d                   	pop    %ebp
  800aba:	c3                   	ret    

00800abb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
  800abe:	56                   	push   %esi
  800abf:	53                   	push   %ebx
  800ac0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ac6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ac9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ace:	eb 0c                	jmp    800adc <strncpy+0x21>
		*dst++ = *src;
  800ad0:	8a 1a                	mov    (%edx),%bl
  800ad2:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ad5:	80 3a 01             	cmpb   $0x1,(%edx)
  800ad8:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800adb:	41                   	inc    %ecx
  800adc:	39 f1                	cmp    %esi,%ecx
  800ade:	75 f0                	jne    800ad0 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ae0:	5b                   	pop    %ebx
  800ae1:	5e                   	pop    %esi
  800ae2:	5d                   	pop    %ebp
  800ae3:	c3                   	ret    

00800ae4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ae4:	55                   	push   %ebp
  800ae5:	89 e5                	mov    %esp,%ebp
  800ae7:	56                   	push   %esi
  800ae8:	53                   	push   %ebx
  800ae9:	8b 75 08             	mov    0x8(%ebp),%esi
  800aec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aef:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800af2:	85 d2                	test   %edx,%edx
  800af4:	75 0a                	jne    800b00 <strlcpy+0x1c>
  800af6:	89 f0                	mov    %esi,%eax
  800af8:	eb 1a                	jmp    800b14 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800afa:	88 18                	mov    %bl,(%eax)
  800afc:	40                   	inc    %eax
  800afd:	41                   	inc    %ecx
  800afe:	eb 02                	jmp    800b02 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b00:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800b02:	4a                   	dec    %edx
  800b03:	74 0a                	je     800b0f <strlcpy+0x2b>
  800b05:	8a 19                	mov    (%ecx),%bl
  800b07:	84 db                	test   %bl,%bl
  800b09:	75 ef                	jne    800afa <strlcpy+0x16>
  800b0b:	89 c2                	mov    %eax,%edx
  800b0d:	eb 02                	jmp    800b11 <strlcpy+0x2d>
  800b0f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800b11:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800b14:	29 f0                	sub    %esi,%eax
}
  800b16:	5b                   	pop    %ebx
  800b17:	5e                   	pop    %esi
  800b18:	5d                   	pop    %ebp
  800b19:	c3                   	ret    

00800b1a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b1a:	55                   	push   %ebp
  800b1b:	89 e5                	mov    %esp,%ebp
  800b1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b20:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b23:	eb 02                	jmp    800b27 <strcmp+0xd>
		p++, q++;
  800b25:	41                   	inc    %ecx
  800b26:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b27:	8a 01                	mov    (%ecx),%al
  800b29:	84 c0                	test   %al,%al
  800b2b:	74 04                	je     800b31 <strcmp+0x17>
  800b2d:	3a 02                	cmp    (%edx),%al
  800b2f:	74 f4                	je     800b25 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b31:	0f b6 c0             	movzbl %al,%eax
  800b34:	0f b6 12             	movzbl (%edx),%edx
  800b37:	29 d0                	sub    %edx,%eax
}
  800b39:	5d                   	pop    %ebp
  800b3a:	c3                   	ret    

00800b3b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
  800b3e:	53                   	push   %ebx
  800b3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b45:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800b48:	eb 03                	jmp    800b4d <strncmp+0x12>
		n--, p++, q++;
  800b4a:	4a                   	dec    %edx
  800b4b:	40                   	inc    %eax
  800b4c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b4d:	85 d2                	test   %edx,%edx
  800b4f:	74 14                	je     800b65 <strncmp+0x2a>
  800b51:	8a 18                	mov    (%eax),%bl
  800b53:	84 db                	test   %bl,%bl
  800b55:	74 04                	je     800b5b <strncmp+0x20>
  800b57:	3a 19                	cmp    (%ecx),%bl
  800b59:	74 ef                	je     800b4a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b5b:	0f b6 00             	movzbl (%eax),%eax
  800b5e:	0f b6 11             	movzbl (%ecx),%edx
  800b61:	29 d0                	sub    %edx,%eax
  800b63:	eb 05                	jmp    800b6a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b65:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b6a:	5b                   	pop    %ebx
  800b6b:	5d                   	pop    %ebp
  800b6c:	c3                   	ret    

00800b6d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b6d:	55                   	push   %ebp
  800b6e:	89 e5                	mov    %esp,%ebp
  800b70:	8b 45 08             	mov    0x8(%ebp),%eax
  800b73:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b76:	eb 05                	jmp    800b7d <strchr+0x10>
		if (*s == c)
  800b78:	38 ca                	cmp    %cl,%dl
  800b7a:	74 0c                	je     800b88 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b7c:	40                   	inc    %eax
  800b7d:	8a 10                	mov    (%eax),%dl
  800b7f:	84 d2                	test   %dl,%dl
  800b81:	75 f5                	jne    800b78 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800b83:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b88:	5d                   	pop    %ebp
  800b89:	c3                   	ret    

00800b8a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b8a:	55                   	push   %ebp
  800b8b:	89 e5                	mov    %esp,%ebp
  800b8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b90:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b93:	eb 05                	jmp    800b9a <strfind+0x10>
		if (*s == c)
  800b95:	38 ca                	cmp    %cl,%dl
  800b97:	74 07                	je     800ba0 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b99:	40                   	inc    %eax
  800b9a:	8a 10                	mov    (%eax),%dl
  800b9c:	84 d2                	test   %dl,%dl
  800b9e:	75 f5                	jne    800b95 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800ba0:	5d                   	pop    %ebp
  800ba1:	c3                   	ret    

00800ba2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	57                   	push   %edi
  800ba6:	56                   	push   %esi
  800ba7:	53                   	push   %ebx
  800ba8:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bab:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bae:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bb1:	85 c9                	test   %ecx,%ecx
  800bb3:	74 30                	je     800be5 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bb5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bbb:	75 25                	jne    800be2 <memset+0x40>
  800bbd:	f6 c1 03             	test   $0x3,%cl
  800bc0:	75 20                	jne    800be2 <memset+0x40>
		c &= 0xFF;
  800bc2:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bc5:	89 d3                	mov    %edx,%ebx
  800bc7:	c1 e3 08             	shl    $0x8,%ebx
  800bca:	89 d6                	mov    %edx,%esi
  800bcc:	c1 e6 18             	shl    $0x18,%esi
  800bcf:	89 d0                	mov    %edx,%eax
  800bd1:	c1 e0 10             	shl    $0x10,%eax
  800bd4:	09 f0                	or     %esi,%eax
  800bd6:	09 d0                	or     %edx,%eax
  800bd8:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bda:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800bdd:	fc                   	cld    
  800bde:	f3 ab                	rep stos %eax,%es:(%edi)
  800be0:	eb 03                	jmp    800be5 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800be2:	fc                   	cld    
  800be3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800be5:	89 f8                	mov    %edi,%eax
  800be7:	5b                   	pop    %ebx
  800be8:	5e                   	pop    %esi
  800be9:	5f                   	pop    %edi
  800bea:	5d                   	pop    %ebp
  800beb:	c3                   	ret    

00800bec <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	57                   	push   %edi
  800bf0:	56                   	push   %esi
  800bf1:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bf7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bfa:	39 c6                	cmp    %eax,%esi
  800bfc:	73 34                	jae    800c32 <memmove+0x46>
  800bfe:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c01:	39 d0                	cmp    %edx,%eax
  800c03:	73 2d                	jae    800c32 <memmove+0x46>
		s += n;
		d += n;
  800c05:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c08:	f6 c2 03             	test   $0x3,%dl
  800c0b:	75 1b                	jne    800c28 <memmove+0x3c>
  800c0d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c13:	75 13                	jne    800c28 <memmove+0x3c>
  800c15:	f6 c1 03             	test   $0x3,%cl
  800c18:	75 0e                	jne    800c28 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c1a:	83 ef 04             	sub    $0x4,%edi
  800c1d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c20:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c23:	fd                   	std    
  800c24:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c26:	eb 07                	jmp    800c2f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c28:	4f                   	dec    %edi
  800c29:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c2c:	fd                   	std    
  800c2d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c2f:	fc                   	cld    
  800c30:	eb 20                	jmp    800c52 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c32:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c38:	75 13                	jne    800c4d <memmove+0x61>
  800c3a:	a8 03                	test   $0x3,%al
  800c3c:	75 0f                	jne    800c4d <memmove+0x61>
  800c3e:	f6 c1 03             	test   $0x3,%cl
  800c41:	75 0a                	jne    800c4d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c43:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c46:	89 c7                	mov    %eax,%edi
  800c48:	fc                   	cld    
  800c49:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c4b:	eb 05                	jmp    800c52 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c4d:	89 c7                	mov    %eax,%edi
  800c4f:	fc                   	cld    
  800c50:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c52:	5e                   	pop    %esi
  800c53:	5f                   	pop    %edi
  800c54:	5d                   	pop    %ebp
  800c55:	c3                   	ret    

00800c56 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c56:	55                   	push   %ebp
  800c57:	89 e5                	mov    %esp,%ebp
  800c59:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c5c:	8b 45 10             	mov    0x10(%ebp),%eax
  800c5f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c63:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c66:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6d:	89 04 24             	mov    %eax,(%esp)
  800c70:	e8 77 ff ff ff       	call   800bec <memmove>
}
  800c75:	c9                   	leave  
  800c76:	c3                   	ret    

00800c77 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c77:	55                   	push   %ebp
  800c78:	89 e5                	mov    %esp,%ebp
  800c7a:	57                   	push   %edi
  800c7b:	56                   	push   %esi
  800c7c:	53                   	push   %ebx
  800c7d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c80:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c83:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c86:	ba 00 00 00 00       	mov    $0x0,%edx
  800c8b:	eb 16                	jmp    800ca3 <memcmp+0x2c>
		if (*s1 != *s2)
  800c8d:	8a 04 17             	mov    (%edi,%edx,1),%al
  800c90:	42                   	inc    %edx
  800c91:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800c95:	38 c8                	cmp    %cl,%al
  800c97:	74 0a                	je     800ca3 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800c99:	0f b6 c0             	movzbl %al,%eax
  800c9c:	0f b6 c9             	movzbl %cl,%ecx
  800c9f:	29 c8                	sub    %ecx,%eax
  800ca1:	eb 09                	jmp    800cac <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ca3:	39 da                	cmp    %ebx,%edx
  800ca5:	75 e6                	jne    800c8d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ca7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cac:	5b                   	pop    %ebx
  800cad:	5e                   	pop    %esi
  800cae:	5f                   	pop    %edi
  800caf:	5d                   	pop    %ebp
  800cb0:	c3                   	ret    

00800cb1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cb1:	55                   	push   %ebp
  800cb2:	89 e5                	mov    %esp,%ebp
  800cb4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800cba:	89 c2                	mov    %eax,%edx
  800cbc:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cbf:	eb 05                	jmp    800cc6 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cc1:	38 08                	cmp    %cl,(%eax)
  800cc3:	74 05                	je     800cca <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cc5:	40                   	inc    %eax
  800cc6:	39 d0                	cmp    %edx,%eax
  800cc8:	72 f7                	jb     800cc1 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800cca:	5d                   	pop    %ebp
  800ccb:	c3                   	ret    

00800ccc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	57                   	push   %edi
  800cd0:	56                   	push   %esi
  800cd1:	53                   	push   %ebx
  800cd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cd8:	eb 01                	jmp    800cdb <strtol+0xf>
		s++;
  800cda:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cdb:	8a 02                	mov    (%edx),%al
  800cdd:	3c 20                	cmp    $0x20,%al
  800cdf:	74 f9                	je     800cda <strtol+0xe>
  800ce1:	3c 09                	cmp    $0x9,%al
  800ce3:	74 f5                	je     800cda <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ce5:	3c 2b                	cmp    $0x2b,%al
  800ce7:	75 08                	jne    800cf1 <strtol+0x25>
		s++;
  800ce9:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cea:	bf 00 00 00 00       	mov    $0x0,%edi
  800cef:	eb 13                	jmp    800d04 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cf1:	3c 2d                	cmp    $0x2d,%al
  800cf3:	75 0a                	jne    800cff <strtol+0x33>
		s++, neg = 1;
  800cf5:	8d 52 01             	lea    0x1(%edx),%edx
  800cf8:	bf 01 00 00 00       	mov    $0x1,%edi
  800cfd:	eb 05                	jmp    800d04 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cff:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d04:	85 db                	test   %ebx,%ebx
  800d06:	74 05                	je     800d0d <strtol+0x41>
  800d08:	83 fb 10             	cmp    $0x10,%ebx
  800d0b:	75 28                	jne    800d35 <strtol+0x69>
  800d0d:	8a 02                	mov    (%edx),%al
  800d0f:	3c 30                	cmp    $0x30,%al
  800d11:	75 10                	jne    800d23 <strtol+0x57>
  800d13:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d17:	75 0a                	jne    800d23 <strtol+0x57>
		s += 2, base = 16;
  800d19:	83 c2 02             	add    $0x2,%edx
  800d1c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d21:	eb 12                	jmp    800d35 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800d23:	85 db                	test   %ebx,%ebx
  800d25:	75 0e                	jne    800d35 <strtol+0x69>
  800d27:	3c 30                	cmp    $0x30,%al
  800d29:	75 05                	jne    800d30 <strtol+0x64>
		s++, base = 8;
  800d2b:	42                   	inc    %edx
  800d2c:	b3 08                	mov    $0x8,%bl
  800d2e:	eb 05                	jmp    800d35 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800d30:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800d35:	b8 00 00 00 00       	mov    $0x0,%eax
  800d3a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d3c:	8a 0a                	mov    (%edx),%cl
  800d3e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d41:	80 fb 09             	cmp    $0x9,%bl
  800d44:	77 08                	ja     800d4e <strtol+0x82>
			dig = *s - '0';
  800d46:	0f be c9             	movsbl %cl,%ecx
  800d49:	83 e9 30             	sub    $0x30,%ecx
  800d4c:	eb 1e                	jmp    800d6c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800d4e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d51:	80 fb 19             	cmp    $0x19,%bl
  800d54:	77 08                	ja     800d5e <strtol+0x92>
			dig = *s - 'a' + 10;
  800d56:	0f be c9             	movsbl %cl,%ecx
  800d59:	83 e9 57             	sub    $0x57,%ecx
  800d5c:	eb 0e                	jmp    800d6c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800d5e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d61:	80 fb 19             	cmp    $0x19,%bl
  800d64:	77 12                	ja     800d78 <strtol+0xac>
			dig = *s - 'A' + 10;
  800d66:	0f be c9             	movsbl %cl,%ecx
  800d69:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d6c:	39 f1                	cmp    %esi,%ecx
  800d6e:	7d 0c                	jge    800d7c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800d70:	42                   	inc    %edx
  800d71:	0f af c6             	imul   %esi,%eax
  800d74:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d76:	eb c4                	jmp    800d3c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d78:	89 c1                	mov    %eax,%ecx
  800d7a:	eb 02                	jmp    800d7e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d7c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d7e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d82:	74 05                	je     800d89 <strtol+0xbd>
		*endptr = (char *) s;
  800d84:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d87:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d89:	85 ff                	test   %edi,%edi
  800d8b:	74 04                	je     800d91 <strtol+0xc5>
  800d8d:	89 c8                	mov    %ecx,%eax
  800d8f:	f7 d8                	neg    %eax
}
  800d91:	5b                   	pop    %ebx
  800d92:	5e                   	pop    %esi
  800d93:	5f                   	pop    %edi
  800d94:	5d                   	pop    %ebp
  800d95:	c3                   	ret    
	...

00800d98 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d98:	55                   	push   %ebp
  800d99:	89 e5                	mov    %esp,%ebp
  800d9b:	57                   	push   %edi
  800d9c:	56                   	push   %esi
  800d9d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9e:	b8 00 00 00 00       	mov    $0x0,%eax
  800da3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da6:	8b 55 08             	mov    0x8(%ebp),%edx
  800da9:	89 c3                	mov    %eax,%ebx
  800dab:	89 c7                	mov    %eax,%edi
  800dad:	89 c6                	mov    %eax,%esi
  800daf:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800db1:	5b                   	pop    %ebx
  800db2:	5e                   	pop    %esi
  800db3:	5f                   	pop    %edi
  800db4:	5d                   	pop    %ebp
  800db5:	c3                   	ret    

00800db6 <sys_cgetc>:

int
sys_cgetc(void)
{
  800db6:	55                   	push   %ebp
  800db7:	89 e5                	mov    %esp,%ebp
  800db9:	57                   	push   %edi
  800dba:	56                   	push   %esi
  800dbb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dbc:	ba 00 00 00 00       	mov    $0x0,%edx
  800dc1:	b8 01 00 00 00       	mov    $0x1,%eax
  800dc6:	89 d1                	mov    %edx,%ecx
  800dc8:	89 d3                	mov    %edx,%ebx
  800dca:	89 d7                	mov    %edx,%edi
  800dcc:	89 d6                	mov    %edx,%esi
  800dce:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800dd0:	5b                   	pop    %ebx
  800dd1:	5e                   	pop    %esi
  800dd2:	5f                   	pop    %edi
  800dd3:	5d                   	pop    %ebp
  800dd4:	c3                   	ret    

00800dd5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800dd5:	55                   	push   %ebp
  800dd6:	89 e5                	mov    %esp,%ebp
  800dd8:	57                   	push   %edi
  800dd9:	56                   	push   %esi
  800dda:	53                   	push   %ebx
  800ddb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dde:	b9 00 00 00 00       	mov    $0x0,%ecx
  800de3:	b8 03 00 00 00       	mov    $0x3,%eax
  800de8:	8b 55 08             	mov    0x8(%ebp),%edx
  800deb:	89 cb                	mov    %ecx,%ebx
  800ded:	89 cf                	mov    %ecx,%edi
  800def:	89 ce                	mov    %ecx,%esi
  800df1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800df3:	85 c0                	test   %eax,%eax
  800df5:	7e 28                	jle    800e1f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dfb:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800e02:	00 
  800e03:	c7 44 24 08 e7 20 80 	movl   $0x8020e7,0x8(%esp)
  800e0a:	00 
  800e0b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e12:	00 
  800e13:	c7 04 24 04 21 80 00 	movl   $0x802104,(%esp)
  800e1a:	e8 b1 f5 ff ff       	call   8003d0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e1f:	83 c4 2c             	add    $0x2c,%esp
  800e22:	5b                   	pop    %ebx
  800e23:	5e                   	pop    %esi
  800e24:	5f                   	pop    %edi
  800e25:	5d                   	pop    %ebp
  800e26:	c3                   	ret    

00800e27 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e27:	55                   	push   %ebp
  800e28:	89 e5                	mov    %esp,%ebp
  800e2a:	57                   	push   %edi
  800e2b:	56                   	push   %esi
  800e2c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2d:	ba 00 00 00 00       	mov    $0x0,%edx
  800e32:	b8 02 00 00 00       	mov    $0x2,%eax
  800e37:	89 d1                	mov    %edx,%ecx
  800e39:	89 d3                	mov    %edx,%ebx
  800e3b:	89 d7                	mov    %edx,%edi
  800e3d:	89 d6                	mov    %edx,%esi
  800e3f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e41:	5b                   	pop    %ebx
  800e42:	5e                   	pop    %esi
  800e43:	5f                   	pop    %edi
  800e44:	5d                   	pop    %ebp
  800e45:	c3                   	ret    

00800e46 <sys_yield>:

void
sys_yield(void)
{
  800e46:	55                   	push   %ebp
  800e47:	89 e5                	mov    %esp,%ebp
  800e49:	57                   	push   %edi
  800e4a:	56                   	push   %esi
  800e4b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4c:	ba 00 00 00 00       	mov    $0x0,%edx
  800e51:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e56:	89 d1                	mov    %edx,%ecx
  800e58:	89 d3                	mov    %edx,%ebx
  800e5a:	89 d7                	mov    %edx,%edi
  800e5c:	89 d6                	mov    %edx,%esi
  800e5e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e60:	5b                   	pop    %ebx
  800e61:	5e                   	pop    %esi
  800e62:	5f                   	pop    %edi
  800e63:	5d                   	pop    %ebp
  800e64:	c3                   	ret    

00800e65 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e65:	55                   	push   %ebp
  800e66:	89 e5                	mov    %esp,%ebp
  800e68:	57                   	push   %edi
  800e69:	56                   	push   %esi
  800e6a:	53                   	push   %ebx
  800e6b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6e:	be 00 00 00 00       	mov    $0x0,%esi
  800e73:	b8 04 00 00 00       	mov    $0x4,%eax
  800e78:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e81:	89 f7                	mov    %esi,%edi
  800e83:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e85:	85 c0                	test   %eax,%eax
  800e87:	7e 28                	jle    800eb1 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e89:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e8d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800e94:	00 
  800e95:	c7 44 24 08 e7 20 80 	movl   $0x8020e7,0x8(%esp)
  800e9c:	00 
  800e9d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ea4:	00 
  800ea5:	c7 04 24 04 21 80 00 	movl   $0x802104,(%esp)
  800eac:	e8 1f f5 ff ff       	call   8003d0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800eb1:	83 c4 2c             	add    $0x2c,%esp
  800eb4:	5b                   	pop    %ebx
  800eb5:	5e                   	pop    %esi
  800eb6:	5f                   	pop    %edi
  800eb7:	5d                   	pop    %ebp
  800eb8:	c3                   	ret    

00800eb9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800eb9:	55                   	push   %ebp
  800eba:	89 e5                	mov    %esp,%ebp
  800ebc:	57                   	push   %edi
  800ebd:	56                   	push   %esi
  800ebe:	53                   	push   %ebx
  800ebf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ec2:	b8 05 00 00 00       	mov    $0x5,%eax
  800ec7:	8b 75 18             	mov    0x18(%ebp),%esi
  800eca:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ecd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ed0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ed8:	85 c0                	test   %eax,%eax
  800eda:	7e 28                	jle    800f04 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800edc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ee0:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800ee7:	00 
  800ee8:	c7 44 24 08 e7 20 80 	movl   $0x8020e7,0x8(%esp)
  800eef:	00 
  800ef0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ef7:	00 
  800ef8:	c7 04 24 04 21 80 00 	movl   $0x802104,(%esp)
  800eff:	e8 cc f4 ff ff       	call   8003d0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f04:	83 c4 2c             	add    $0x2c,%esp
  800f07:	5b                   	pop    %ebx
  800f08:	5e                   	pop    %esi
  800f09:	5f                   	pop    %edi
  800f0a:	5d                   	pop    %ebp
  800f0b:	c3                   	ret    

00800f0c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f0c:	55                   	push   %ebp
  800f0d:	89 e5                	mov    %esp,%ebp
  800f0f:	57                   	push   %edi
  800f10:	56                   	push   %esi
  800f11:	53                   	push   %ebx
  800f12:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f15:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f1a:	b8 06 00 00 00       	mov    $0x6,%eax
  800f1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f22:	8b 55 08             	mov    0x8(%ebp),%edx
  800f25:	89 df                	mov    %ebx,%edi
  800f27:	89 de                	mov    %ebx,%esi
  800f29:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f2b:	85 c0                	test   %eax,%eax
  800f2d:	7e 28                	jle    800f57 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f2f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f33:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f3a:	00 
  800f3b:	c7 44 24 08 e7 20 80 	movl   $0x8020e7,0x8(%esp)
  800f42:	00 
  800f43:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f4a:	00 
  800f4b:	c7 04 24 04 21 80 00 	movl   $0x802104,(%esp)
  800f52:	e8 79 f4 ff ff       	call   8003d0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f57:	83 c4 2c             	add    $0x2c,%esp
  800f5a:	5b                   	pop    %ebx
  800f5b:	5e                   	pop    %esi
  800f5c:	5f                   	pop    %edi
  800f5d:	5d                   	pop    %ebp
  800f5e:	c3                   	ret    

00800f5f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f5f:	55                   	push   %ebp
  800f60:	89 e5                	mov    %esp,%ebp
  800f62:	57                   	push   %edi
  800f63:	56                   	push   %esi
  800f64:	53                   	push   %ebx
  800f65:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f68:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f6d:	b8 08 00 00 00       	mov    $0x8,%eax
  800f72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f75:	8b 55 08             	mov    0x8(%ebp),%edx
  800f78:	89 df                	mov    %ebx,%edi
  800f7a:	89 de                	mov    %ebx,%esi
  800f7c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f7e:	85 c0                	test   %eax,%eax
  800f80:	7e 28                	jle    800faa <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f82:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f86:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f8d:	00 
  800f8e:	c7 44 24 08 e7 20 80 	movl   $0x8020e7,0x8(%esp)
  800f95:	00 
  800f96:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f9d:	00 
  800f9e:	c7 04 24 04 21 80 00 	movl   $0x802104,(%esp)
  800fa5:	e8 26 f4 ff ff       	call   8003d0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800faa:	83 c4 2c             	add    $0x2c,%esp
  800fad:	5b                   	pop    %ebx
  800fae:	5e                   	pop    %esi
  800faf:	5f                   	pop    %edi
  800fb0:	5d                   	pop    %ebp
  800fb1:	c3                   	ret    

00800fb2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800fb2:	55                   	push   %ebp
  800fb3:	89 e5                	mov    %esp,%ebp
  800fb5:	57                   	push   %edi
  800fb6:	56                   	push   %esi
  800fb7:	53                   	push   %ebx
  800fb8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fbb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fc0:	b8 09 00 00 00       	mov    $0x9,%eax
  800fc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800fcb:	89 df                	mov    %ebx,%edi
  800fcd:	89 de                	mov    %ebx,%esi
  800fcf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fd1:	85 c0                	test   %eax,%eax
  800fd3:	7e 28                	jle    800ffd <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fd5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fd9:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800fe0:	00 
  800fe1:	c7 44 24 08 e7 20 80 	movl   $0x8020e7,0x8(%esp)
  800fe8:	00 
  800fe9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ff0:	00 
  800ff1:	c7 04 24 04 21 80 00 	movl   $0x802104,(%esp)
  800ff8:	e8 d3 f3 ff ff       	call   8003d0 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ffd:	83 c4 2c             	add    $0x2c,%esp
  801000:	5b                   	pop    %ebx
  801001:	5e                   	pop    %esi
  801002:	5f                   	pop    %edi
  801003:	5d                   	pop    %ebp
  801004:	c3                   	ret    

00801005 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801005:	55                   	push   %ebp
  801006:	89 e5                	mov    %esp,%ebp
  801008:	57                   	push   %edi
  801009:	56                   	push   %esi
  80100a:	53                   	push   %ebx
  80100b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80100e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801013:	b8 0a 00 00 00       	mov    $0xa,%eax
  801018:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80101b:	8b 55 08             	mov    0x8(%ebp),%edx
  80101e:	89 df                	mov    %ebx,%edi
  801020:	89 de                	mov    %ebx,%esi
  801022:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801024:	85 c0                	test   %eax,%eax
  801026:	7e 28                	jle    801050 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801028:	89 44 24 10          	mov    %eax,0x10(%esp)
  80102c:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801033:	00 
  801034:	c7 44 24 08 e7 20 80 	movl   $0x8020e7,0x8(%esp)
  80103b:	00 
  80103c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801043:	00 
  801044:	c7 04 24 04 21 80 00 	movl   $0x802104,(%esp)
  80104b:	e8 80 f3 ff ff       	call   8003d0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801050:	83 c4 2c             	add    $0x2c,%esp
  801053:	5b                   	pop    %ebx
  801054:	5e                   	pop    %esi
  801055:	5f                   	pop    %edi
  801056:	5d                   	pop    %ebp
  801057:	c3                   	ret    

00801058 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801058:	55                   	push   %ebp
  801059:	89 e5                	mov    %esp,%ebp
  80105b:	57                   	push   %edi
  80105c:	56                   	push   %esi
  80105d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80105e:	be 00 00 00 00       	mov    $0x0,%esi
  801063:	b8 0c 00 00 00       	mov    $0xc,%eax
  801068:	8b 7d 14             	mov    0x14(%ebp),%edi
  80106b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80106e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801071:	8b 55 08             	mov    0x8(%ebp),%edx
  801074:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801076:	5b                   	pop    %ebx
  801077:	5e                   	pop    %esi
  801078:	5f                   	pop    %edi
  801079:	5d                   	pop    %ebp
  80107a:	c3                   	ret    

0080107b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80107b:	55                   	push   %ebp
  80107c:	89 e5                	mov    %esp,%ebp
  80107e:	57                   	push   %edi
  80107f:	56                   	push   %esi
  801080:	53                   	push   %ebx
  801081:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801084:	b9 00 00 00 00       	mov    $0x0,%ecx
  801089:	b8 0d 00 00 00       	mov    $0xd,%eax
  80108e:	8b 55 08             	mov    0x8(%ebp),%edx
  801091:	89 cb                	mov    %ecx,%ebx
  801093:	89 cf                	mov    %ecx,%edi
  801095:	89 ce                	mov    %ecx,%esi
  801097:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801099:	85 c0                	test   %eax,%eax
  80109b:	7e 28                	jle    8010c5 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80109d:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010a1:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8010a8:	00 
  8010a9:	c7 44 24 08 e7 20 80 	movl   $0x8020e7,0x8(%esp)
  8010b0:	00 
  8010b1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010b8:	00 
  8010b9:	c7 04 24 04 21 80 00 	movl   $0x802104,(%esp)
  8010c0:	e8 0b f3 ff ff       	call   8003d0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8010c5:	83 c4 2c             	add    $0x2c,%esp
  8010c8:	5b                   	pop    %ebx
  8010c9:	5e                   	pop    %esi
  8010ca:	5f                   	pop    %edi
  8010cb:	5d                   	pop    %ebp
  8010cc:	c3                   	ret    

008010cd <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8010cd:	55                   	push   %ebp
  8010ce:	89 e5                	mov    %esp,%ebp
  8010d0:	57                   	push   %edi
  8010d1:	56                   	push   %esi
  8010d2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8010d8:	b8 0e 00 00 00       	mov    $0xe,%eax
  8010dd:	89 d1                	mov    %edx,%ecx
  8010df:	89 d3                	mov    %edx,%ebx
  8010e1:	89 d7                	mov    %edx,%edi
  8010e3:	89 d6                	mov    %edx,%esi
  8010e5:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8010e7:	5b                   	pop    %ebx
  8010e8:	5e                   	pop    %esi
  8010e9:	5f                   	pop    %edi
  8010ea:	5d                   	pop    %ebp
  8010eb:	c3                   	ret    

008010ec <sys_e1000_transmit>:

int 
sys_e1000_transmit(char* pck, size_t length){
  8010ec:	55                   	push   %ebp
  8010ed:	89 e5                	mov    %esp,%ebp
  8010ef:	57                   	push   %edi
  8010f0:	56                   	push   %esi
  8010f1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010f2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010f7:	b8 10 00 00 00       	mov    $0x10,%eax
  8010fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ff:	8b 55 08             	mov    0x8(%ebp),%edx
  801102:	89 df                	mov    %ebx,%edi
  801104:	89 de                	mov    %ebx,%esi
  801106:	cd 30                	int    $0x30
}

int 
sys_e1000_transmit(char* pck, size_t length){
	return syscall(SYS_e1000_transmit, 0, (uint32_t)pck, length, 0, 0, 0);
}
  801108:	5b                   	pop    %ebx
  801109:	5e                   	pop    %esi
  80110a:	5f                   	pop    %edi
  80110b:	5d                   	pop    %ebp
  80110c:	c3                   	ret    

0080110d <sys_e1000_receive>:

int 
sys_e1000_receive(char* pck, size_t* length){
  80110d:	55                   	push   %ebp
  80110e:	89 e5                	mov    %esp,%ebp
  801110:	57                   	push   %edi
  801111:	56                   	push   %esi
  801112:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801113:	bb 00 00 00 00       	mov    $0x0,%ebx
  801118:	b8 0f 00 00 00       	mov    $0xf,%eax
  80111d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801120:	8b 55 08             	mov    0x8(%ebp),%edx
  801123:	89 df                	mov    %ebx,%edi
  801125:	89 de                	mov    %ebx,%esi
  801127:	cd 30                	int    $0x30
}

int 
sys_e1000_receive(char* pck, size_t* length){
	return syscall(SYS_e1000_receive, 0, (uint32_t)pck, (uint32_t)length, 0, 0, 0);
}
  801129:	5b                   	pop    %ebx
  80112a:	5e                   	pop    %esi
  80112b:	5f                   	pop    %edi
  80112c:	5d                   	pop    %ebp
  80112d:	c3                   	ret    

0080112e <sys_e1000_get_mac>:

int 
sys_e1000_get_mac(uint8_t* mac_addr){
  80112e:	55                   	push   %ebp
  80112f:	89 e5                	mov    %esp,%ebp
  801131:	57                   	push   %edi
  801132:	56                   	push   %esi
  801133:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801134:	b9 00 00 00 00       	mov    $0x0,%ecx
  801139:	b8 11 00 00 00       	mov    $0x11,%eax
  80113e:	8b 55 08             	mov    0x8(%ebp),%edx
  801141:	89 cb                	mov    %ecx,%ebx
  801143:	89 cf                	mov    %ecx,%edi
  801145:	89 ce                	mov    %ecx,%esi
  801147:	cd 30                	int    $0x30
}

int 
sys_e1000_get_mac(uint8_t* mac_addr){
	return syscall(SYS_e1000_get_mac, 0, (uint32_t)mac_addr, 0, 0, 0, 0);
}
  801149:	5b                   	pop    %ebx
  80114a:	5e                   	pop    %esi
  80114b:	5f                   	pop    %edi
  80114c:	5d                   	pop    %ebp
  80114d:	c3                   	ret    
	...

00801150 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801150:	55                   	push   %ebp
  801151:	89 e5                	mov    %esp,%ebp
  801153:	53                   	push   %ebx
  801154:	83 ec 24             	sub    $0x24,%esp
  801157:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80115a:	8b 18                	mov    (%eax),%ebx
	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	if ((err & FEC_WR) == 0)
  80115c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801160:	75 20                	jne    801182 <pgfault+0x32>
		panic("pgfault: faulting address [%08x] not a write\n", addr);
  801162:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801166:	c7 44 24 08 14 21 80 	movl   $0x802114,0x8(%esp)
  80116d:	00 
  80116e:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  801175:	00 
  801176:	c7 04 24 94 21 80 00 	movl   $0x802194,(%esp)
  80117d:	e8 4e f2 ff ff       	call   8003d0 <_panic>

	void *page_aligned_addr = (void *) ROUNDDOWN(addr, PGSIZE);
  801182:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t page_num = (uint32_t) page_aligned_addr / PGSIZE;
  801188:	89 d8                	mov    %ebx,%eax
  80118a:	c1 e8 0c             	shr    $0xc,%eax
	if (!(uvpt[page_num] & PTE_COW))
  80118d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801194:	f6 c4 08             	test   $0x8,%ah
  801197:	75 1c                	jne    8011b5 <pgfault+0x65>
		panic("pgfault: fault was not on a copy-on-write page\n");
  801199:	c7 44 24 08 44 21 80 	movl   $0x802144,0x8(%esp)
  8011a0:	00 
  8011a1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011a8:	00 
  8011a9:	c7 04 24 94 21 80 00 	movl   $0x802194,(%esp)
  8011b0:	e8 1b f2 ff ff       	call   8003d0 <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.

	// Allocate
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  8011b5:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8011bc:	00 
  8011bd:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8011c4:	00 
  8011c5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011cc:	e8 94 fc ff ff       	call   800e65 <sys_page_alloc>
  8011d1:	85 c0                	test   %eax,%eax
  8011d3:	79 20                	jns    8011f5 <pgfault+0xa5>
		panic("sys_page_alloc: %e\n", r);
  8011d5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011d9:	c7 44 24 08 9f 21 80 	movl   $0x80219f,0x8(%esp)
  8011e0:	00 
  8011e1:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  8011e8:	00 
  8011e9:	c7 04 24 94 21 80 00 	movl   $0x802194,(%esp)
  8011f0:	e8 db f1 ff ff       	call   8003d0 <_panic>

	// Copy over
	void *src_addr = (void *) ROUNDDOWN(addr, PGSIZE);
	memmove(PFTEMP, src_addr, PGSIZE);
  8011f5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8011fc:	00 
  8011fd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801201:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801208:	e8 df f9 ff ff       	call   800bec <memmove>

	// Remap
	if ((r = sys_page_map(0, PFTEMP, 0, src_addr, PTE_P | PTE_U | PTE_W)) < 0)
  80120d:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801214:	00 
  801215:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801219:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801220:	00 
  801221:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801228:	00 
  801229:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801230:	e8 84 fc ff ff       	call   800eb9 <sys_page_map>
  801235:	85 c0                	test   %eax,%eax
  801237:	79 20                	jns    801259 <pgfault+0x109>
		panic("sys_page_map: %e\n", r);
  801239:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80123d:	c7 44 24 08 b3 21 80 	movl   $0x8021b3,0x8(%esp)
  801244:	00 
  801245:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  80124c:	00 
  80124d:	c7 04 24 94 21 80 00 	movl   $0x802194,(%esp)
  801254:	e8 77 f1 ff ff       	call   8003d0 <_panic>

}
  801259:	83 c4 24             	add    $0x24,%esp
  80125c:	5b                   	pop    %ebx
  80125d:	5d                   	pop    %ebp
  80125e:	c3                   	ret    

0080125f <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80125f:	55                   	push   %ebp
  801260:	89 e5                	mov    %esp,%ebp
  801262:	57                   	push   %edi
  801263:	56                   	push   %esi
  801264:	53                   	push   %ebx
  801265:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	int r;
	envid_t child_envid;

	set_pgfault_handler(pgfault);
  801268:	c7 04 24 50 11 80 00 	movl   $0x801150,(%esp)
  80126f:	e8 a4 06 00 00       	call   801918 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801274:	ba 07 00 00 00       	mov    $0x7,%edx
  801279:	89 d0                	mov    %edx,%eax
  80127b:	cd 30                	int    $0x30
  80127d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801280:	89 45 e0             	mov    %eax,-0x20(%ebp)

	child_envid = sys_exofork();
	if (child_envid < 0)
  801283:	85 c0                	test   %eax,%eax
  801285:	79 20                	jns    8012a7 <fork+0x48>
		panic("sys_exofork: %e\n", child_envid);
  801287:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80128b:	c7 44 24 08 c5 21 80 	movl   $0x8021c5,0x8(%esp)
  801292:	00 
  801293:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  80129a:	00 
  80129b:	c7 04 24 94 21 80 00 	movl   $0x802194,(%esp)
  8012a2:	e8 29 f1 ff ff       	call   8003d0 <_panic>
	if (child_envid == 0) { // child
  8012a7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8012ab:	75 1c                	jne    8012c9 <fork+0x6a>
		// Fix thisenv like dumbfork does and return 0
		thisenv = &envs[ENVX(sys_getenvid())];
  8012ad:	e8 75 fb ff ff       	call   800e27 <sys_getenvid>
  8012b2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8012b7:	c1 e0 07             	shl    $0x7,%eax
  8012ba:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8012bf:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  8012c4:	e9 58 02 00 00       	jmp    801521 <fork+0x2c2>
	set_pgfault_handler(pgfault);

	child_envid = sys_exofork();
	if (child_envid < 0)
		panic("sys_exofork: %e\n", child_envid);
	if (child_envid == 0) { // child
  8012c9:	bf 00 00 00 00       	mov    $0x0,%edi
  8012ce:	be 00 00 00 00       	mov    $0x0,%esi
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
  8012d3:	89 f0                	mov    %esi,%eax
  8012d5:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  8012d8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012df:	a8 01                	test   $0x1,%al
  8012e1:	0f 84 7a 01 00 00    	je     801461 <fork+0x202>
			((uvpt[page_num] & PTE_P) == PTE_P)) {
  8012e7:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  8012ee:	a8 01                	test   $0x1,%al
  8012f0:	0f 84 6b 01 00 00    	je     801461 <fork+0x202>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	envid_t this_envid = thisenv->env_id;
  8012f6:	a1 08 40 80 00       	mov    0x804008,%eax
  8012fb:	8b 40 48             	mov    0x48(%eax),%eax
  8012fe:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	if (uvpt[pn] & PTE_SHARE) {
  801301:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801308:	f6 c4 04             	test   $0x4,%ah
  80130b:	74 52                	je     80135f <fork+0x100>
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  80130d:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801314:	25 07 0e 00 00       	and    $0xe07,%eax
  801319:	89 44 24 10          	mov    %eax,0x10(%esp)
  80131d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801321:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801324:	89 44 24 08          	mov    %eax,0x8(%esp)
  801328:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80132c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80132f:	89 04 24             	mov    %eax,(%esp)
  801332:	e8 82 fb ff ff       	call   800eb9 <sys_page_map>
  801337:	85 c0                	test   %eax,%eax
  801339:	0f 89 22 01 00 00    	jns    801461 <fork+0x202>
			panic("sys_page_map: %e\n", r);
  80133f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801343:	c7 44 24 08 b3 21 80 	movl   $0x8021b3,0x8(%esp)
  80134a:	00 
  80134b:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  801352:	00 
  801353:	c7 04 24 94 21 80 00 	movl   $0x802194,(%esp)
  80135a:	e8 71 f0 ff ff       	call   8003d0 <_panic>
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
  80135f:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801366:	f6 c4 08             	test   $0x8,%ah
  801369:	75 0f                	jne    80137a <fork+0x11b>
  80136b:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801372:	a8 02                	test   $0x2,%al
  801374:	0f 84 99 00 00 00    	je     801413 <fork+0x1b4>
		if (uvpt[pn] & PTE_U)
  80137a:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801381:	83 e0 04             	and    $0x4,%eax
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
  801384:	83 f8 01             	cmp    $0x1,%eax
  801387:	19 db                	sbb    %ebx,%ebx
  801389:	83 e3 fc             	and    $0xfffffffc,%ebx
  80138c:	81 c3 05 08 00 00    	add    $0x805,%ebx
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
		if (uvpt[pn] & PTE_U)
			perm |= PTE_U;

		// Map page COW, U and P in child
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), perm)) < 0)
  801392:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801396:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80139a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80139d:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013a1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013a8:	89 04 24             	mov    %eax,(%esp)
  8013ab:	e8 09 fb ff ff       	call   800eb9 <sys_page_map>
  8013b0:	85 c0                	test   %eax,%eax
  8013b2:	79 20                	jns    8013d4 <fork+0x175>
			panic("sys_page_map: %e\n", r);
  8013b4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013b8:	c7 44 24 08 b3 21 80 	movl   $0x8021b3,0x8(%esp)
  8013bf:	00 
  8013c0:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  8013c7:	00 
  8013c8:	c7 04 24 94 21 80 00 	movl   $0x802194,(%esp)
  8013cf:	e8 fc ef ff ff       	call   8003d0 <_panic>

		// Map page COW, U and P in parent
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), this_envid, (void *) (pn*PGSIZE), perm)) < 0)
  8013d4:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8013d8:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8013dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013e3:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013e7:	89 04 24             	mov    %eax,(%esp)
  8013ea:	e8 ca fa ff ff       	call   800eb9 <sys_page_map>
  8013ef:	85 c0                	test   %eax,%eax
  8013f1:	79 6e                	jns    801461 <fork+0x202>
			panic("sys_page_map: %e\n", r);
  8013f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013f7:	c7 44 24 08 b3 21 80 	movl   $0x8021b3,0x8(%esp)
  8013fe:	00 
  8013ff:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  801406:	00 
  801407:	c7 04 24 94 21 80 00 	movl   $0x802194,(%esp)
  80140e:	e8 bd ef ff ff       	call   8003d0 <_panic>

	} else { // map pages that are present but not writable or COW with their original permissions
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  801413:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80141a:	25 07 0e 00 00       	and    $0xe07,%eax
  80141f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801423:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801427:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80142a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80142e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801432:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801435:	89 04 24             	mov    %eax,(%esp)
  801438:	e8 7c fa ff ff       	call   800eb9 <sys_page_map>
  80143d:	85 c0                	test   %eax,%eax
  80143f:	79 20                	jns    801461 <fork+0x202>
			panic("sys_page_map: %e\n", r);
  801441:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801445:	c7 44 24 08 b3 21 80 	movl   $0x8021b3,0x8(%esp)
  80144c:	00 
  80144d:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  801454:	00 
  801455:	c7 04 24 94 21 80 00 	movl   $0x802194,(%esp)
  80145c:	e8 6f ef ff ff       	call   8003d0 <_panic>
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
  801461:	46                   	inc    %esi
  801462:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801468:	81 fe ff eb 0e 00    	cmp    $0xeebff,%esi
  80146e:	0f 85 5f fe ff ff    	jne    8012d3 <fork+0x74>
	}

	// Allocate exception stack space for child. The child can't do this themselves
	// because the mechanism by which it would is to run the pgfault handler, which
	// needs to run on the exception stack (catch 22).
	if ((r = sys_page_alloc(child_envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801474:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80147b:	00 
  80147c:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801483:	ee 
  801484:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801487:	89 04 24             	mov    %eax,(%esp)
  80148a:	e8 d6 f9 ff ff       	call   800e65 <sys_page_alloc>
  80148f:	85 c0                	test   %eax,%eax
  801491:	79 20                	jns    8014b3 <fork+0x254>
		panic("sys_page_alloc: %e\n", r);
  801493:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801497:	c7 44 24 08 9f 21 80 	movl   $0x80219f,0x8(%esp)
  80149e:	00 
  80149f:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  8014a6:	00 
  8014a7:	c7 04 24 94 21 80 00 	movl   $0x802194,(%esp)
  8014ae:	e8 1d ef ff ff       	call   8003d0 <_panic>

	// Set page fault handler for the child
	if ((r = sys_env_set_pgfault_upcall(child_envid, _pgfault_upcall)) < 0)
  8014b3:	c7 44 24 04 8c 19 80 	movl   $0x80198c,0x4(%esp)
  8014ba:	00 
  8014bb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8014be:	89 04 24             	mov    %eax,(%esp)
  8014c1:	e8 3f fb ff ff       	call   801005 <sys_env_set_pgfault_upcall>
  8014c6:	85 c0                	test   %eax,%eax
  8014c8:	79 20                	jns    8014ea <fork+0x28b>
		panic("sys_env_set_pgfault_upcall: %e\n", r);
  8014ca:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014ce:	c7 44 24 08 74 21 80 	movl   $0x802174,0x8(%esp)
  8014d5:	00 
  8014d6:	c7 44 24 04 a1 00 00 	movl   $0xa1,0x4(%esp)
  8014dd:	00 
  8014de:	c7 04 24 94 21 80 00 	movl   $0x802194,(%esp)
  8014e5:	e8 e6 ee ff ff       	call   8003d0 <_panic>

	// Mark child environment as runnable
	if ((r = sys_env_set_status(child_envid, ENV_RUNNABLE)) < 0)
  8014ea:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8014f1:	00 
  8014f2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8014f5:	89 04 24             	mov    %eax,(%esp)
  8014f8:	e8 62 fa ff ff       	call   800f5f <sys_env_set_status>
  8014fd:	85 c0                	test   %eax,%eax
  8014ff:	79 20                	jns    801521 <fork+0x2c2>
		panic("sys_env_set_status: %e\n", r);
  801501:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801505:	c7 44 24 08 d6 21 80 	movl   $0x8021d6,0x8(%esp)
  80150c:	00 
  80150d:	c7 44 24 04 a5 00 00 	movl   $0xa5,0x4(%esp)
  801514:	00 
  801515:	c7 04 24 94 21 80 00 	movl   $0x802194,(%esp)
  80151c:	e8 af ee ff ff       	call   8003d0 <_panic>

	return child_envid;
}
  801521:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801524:	83 c4 3c             	add    $0x3c,%esp
  801527:	5b                   	pop    %ebx
  801528:	5e                   	pop    %esi
  801529:	5f                   	pop    %edi
  80152a:	5d                   	pop    %ebp
  80152b:	c3                   	ret    

0080152c <sfork>:

// Challenge!
int
sfork(void)
{
  80152c:	55                   	push   %ebp
  80152d:	89 e5                	mov    %esp,%ebp
  80152f:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801532:	c7 44 24 08 ee 21 80 	movl   $0x8021ee,0x8(%esp)
  801539:	00 
  80153a:	c7 44 24 04 ae 00 00 	movl   $0xae,0x4(%esp)
  801541:	00 
  801542:	c7 04 24 94 21 80 00 	movl   $0x802194,(%esp)
  801549:	e8 82 ee ff ff       	call   8003d0 <_panic>
	...

00801550 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801550:	55                   	push   %ebp
  801551:	89 e5                	mov    %esp,%ebp
  801553:	56                   	push   %esi
  801554:	53                   	push   %ebx
  801555:	83 ec 10             	sub    $0x10,%esp
  801558:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80155b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80155e:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int r;
		
	r = sys_ipc_recv(pg?pg:(void*)UTOP);
  801561:	85 c0                	test   %eax,%eax
  801563:	75 05                	jne    80156a <ipc_recv+0x1a>
  801565:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80156a:	89 04 24             	mov    %eax,(%esp)
  80156d:	e8 09 fb ff ff       	call   80107b <sys_ipc_recv>
	if (from_env_store != NULL)
  801572:	85 db                	test   %ebx,%ebx
  801574:	74 0b                	je     801581 <ipc_recv+0x31>
		*from_env_store = thisenv->env_ipc_from; 
  801576:	8b 15 08 40 80 00    	mov    0x804008,%edx
  80157c:	8b 52 74             	mov    0x74(%edx),%edx
  80157f:	89 13                	mov    %edx,(%ebx)
	if (perm_store != NULL)
  801581:	85 f6                	test   %esi,%esi
  801583:	74 0b                	je     801590 <ipc_recv+0x40>
		*perm_store = thisenv->env_ipc_perm;
  801585:	8b 15 08 40 80 00    	mov    0x804008,%edx
  80158b:	8b 52 78             	mov    0x78(%edx),%edx
  80158e:	89 16                	mov    %edx,(%esi)
	
	if (r < 0){
  801590:	85 c0                	test   %eax,%eax
  801592:	79 16                	jns    8015aa <ipc_recv+0x5a>
		if(from_env_store != NULL)
  801594:	85 db                	test   %ebx,%ebx
  801596:	74 06                	je     80159e <ipc_recv+0x4e>
			*from_env_store = 0;
  801598:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store != NULL)	
  80159e:	85 f6                	test   %esi,%esi
  8015a0:	74 10                	je     8015b2 <ipc_recv+0x62>
			*perm_store = 0;
  8015a2:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8015a8:	eb 08                	jmp    8015b2 <ipc_recv+0x62>
		return r;
	}
	
	return thisenv->env_ipc_value;
  8015aa:	a1 08 40 80 00       	mov    0x804008,%eax
  8015af:	8b 40 70             	mov    0x70(%eax),%eax
}
  8015b2:	83 c4 10             	add    $0x10,%esp
  8015b5:	5b                   	pop    %ebx
  8015b6:	5e                   	pop    %esi
  8015b7:	5d                   	pop    %ebp
  8015b8:	c3                   	ret    

008015b9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8015b9:	55                   	push   %ebp
  8015ba:	89 e5                	mov    %esp,%ebp
  8015bc:	57                   	push   %edi
  8015bd:	56                   	push   %esi
  8015be:	53                   	push   %ebx
  8015bf:	83 ec 1c             	sub    $0x1c,%esp
  8015c2:	8b 75 08             	mov    0x8(%ebp),%esi
  8015c5:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8015c8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  8015cb:	eb 2a                	jmp    8015f7 <ipc_send+0x3e>
		if (r != -E_IPC_NOT_RECV)
  8015cd:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8015d0:	74 20                	je     8015f2 <ipc_send+0x39>
			panic("ipc_send: sys_ipc_try_send failed %e", r);
  8015d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015d6:	c7 44 24 08 04 22 80 	movl   $0x802204,0x8(%esp)
  8015dd:	00 
  8015de:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  8015e5:	00 
  8015e6:	c7 04 24 2c 22 80 00 	movl   $0x80222c,(%esp)
  8015ed:	e8 de ed ff ff       	call   8003d0 <_panic>
		sys_yield();
  8015f2:	e8 4f f8 ff ff       	call   800e46 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  8015f7:	85 db                	test   %ebx,%ebx
  8015f9:	75 07                	jne    801602 <ipc_send+0x49>
  8015fb:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801600:	eb 02                	jmp    801604 <ipc_send+0x4b>
  801602:	89 d8                	mov    %ebx,%eax
  801604:	8b 55 14             	mov    0x14(%ebp),%edx
  801607:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80160b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80160f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801613:	89 34 24             	mov    %esi,(%esp)
  801616:	e8 3d fa ff ff       	call   801058 <sys_ipc_try_send>
  80161b:	85 c0                	test   %eax,%eax
  80161d:	78 ae                	js     8015cd <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: sys_ipc_try_send failed %e", r);
		sys_yield();
	}
}
  80161f:	83 c4 1c             	add    $0x1c,%esp
  801622:	5b                   	pop    %ebx
  801623:	5e                   	pop    %esi
  801624:	5f                   	pop    %edi
  801625:	5d                   	pop    %ebp
  801626:	c3                   	ret    

00801627 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801627:	55                   	push   %ebp
  801628:	89 e5                	mov    %esp,%ebp
  80162a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80162d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801632:	89 c2                	mov    %eax,%edx
  801634:	c1 e2 07             	shl    $0x7,%edx
  801637:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80163d:	8b 52 50             	mov    0x50(%edx),%edx
  801640:	39 ca                	cmp    %ecx,%edx
  801642:	75 0d                	jne    801651 <ipc_find_env+0x2a>
			return envs[i].env_id;
  801644:	c1 e0 07             	shl    $0x7,%eax
  801647:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  80164c:	8b 40 40             	mov    0x40(%eax),%eax
  80164f:	eb 0c                	jmp    80165d <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801651:	40                   	inc    %eax
  801652:	3d 00 04 00 00       	cmp    $0x400,%eax
  801657:	75 d9                	jne    801632 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801659:	66 b8 00 00          	mov    $0x0,%ax
}
  80165d:	5d                   	pop    %ebp
  80165e:	c3                   	ret    
	...

00801660 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801660:	55                   	push   %ebp
  801661:	89 e5                	mov    %esp,%ebp
  801663:	53                   	push   %ebx
  801664:	83 ec 14             	sub    $0x14,%esp
  801667:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801669:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801670:	75 11                	jne    801683 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801672:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801679:	e8 a9 ff ff ff       	call   801627 <ipc_find_env>
  80167e:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801683:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80168a:	00 
  80168b:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801692:	00 
  801693:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801697:	a1 04 40 80 00       	mov    0x804004,%eax
  80169c:	89 04 24             	mov    %eax,(%esp)
  80169f:	e8 15 ff ff ff       	call   8015b9 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8016a4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016ab:	00 
  8016ac:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8016b3:	00 
  8016b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016bb:	e8 90 fe ff ff       	call   801550 <ipc_recv>
}
  8016c0:	83 c4 14             	add    $0x14,%esp
  8016c3:	5b                   	pop    %ebx
  8016c4:	5d                   	pop    %ebp
  8016c5:	c3                   	ret    

008016c6 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8016c6:	55                   	push   %ebp
  8016c7:	89 e5                	mov    %esp,%ebp
  8016c9:	56                   	push   %esi
  8016ca:	53                   	push   %ebx
  8016cb:	83 ec 10             	sub    $0x10,%esp
  8016ce:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8016d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d4:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8016d9:	8b 06                	mov    (%esi),%eax
  8016db:	a3 04 50 80 00       	mov    %eax,0x805004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8016e0:	b8 01 00 00 00       	mov    $0x1,%eax
  8016e5:	e8 76 ff ff ff       	call   801660 <nsipc>
  8016ea:	89 c3                	mov    %eax,%ebx
  8016ec:	85 c0                	test   %eax,%eax
  8016ee:	78 23                	js     801713 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8016f0:	a1 10 50 80 00       	mov    0x805010,%eax
  8016f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016f9:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801700:	00 
  801701:	8b 45 0c             	mov    0xc(%ebp),%eax
  801704:	89 04 24             	mov    %eax,(%esp)
  801707:	e8 e0 f4 ff ff       	call   800bec <memmove>
		*addrlen = ret->ret_addrlen;
  80170c:	a1 10 50 80 00       	mov    0x805010,%eax
  801711:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801713:	89 d8                	mov    %ebx,%eax
  801715:	83 c4 10             	add    $0x10,%esp
  801718:	5b                   	pop    %ebx
  801719:	5e                   	pop    %esi
  80171a:	5d                   	pop    %ebp
  80171b:	c3                   	ret    

0080171c <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80171c:	55                   	push   %ebp
  80171d:	89 e5                	mov    %esp,%ebp
  80171f:	53                   	push   %ebx
  801720:	83 ec 14             	sub    $0x14,%esp
  801723:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801726:	8b 45 08             	mov    0x8(%ebp),%eax
  801729:	a3 00 50 80 00       	mov    %eax,0x805000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  80172e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801732:	8b 45 0c             	mov    0xc(%ebp),%eax
  801735:	89 44 24 04          	mov    %eax,0x4(%esp)
  801739:	c7 04 24 04 50 80 00 	movl   $0x805004,(%esp)
  801740:	e8 a7 f4 ff ff       	call   800bec <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801745:	89 1d 14 50 80 00    	mov    %ebx,0x805014
	return nsipc(NSREQ_BIND);
  80174b:	b8 02 00 00 00       	mov    $0x2,%eax
  801750:	e8 0b ff ff ff       	call   801660 <nsipc>
}
  801755:	83 c4 14             	add    $0x14,%esp
  801758:	5b                   	pop    %ebx
  801759:	5d                   	pop    %ebp
  80175a:	c3                   	ret    

0080175b <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80175b:	55                   	push   %ebp
  80175c:	89 e5                	mov    %esp,%ebp
  80175e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801761:	8b 45 08             	mov    0x8(%ebp),%eax
  801764:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.shutdown.req_how = how;
  801769:	8b 45 0c             	mov    0xc(%ebp),%eax
  80176c:	a3 04 50 80 00       	mov    %eax,0x805004
	return nsipc(NSREQ_SHUTDOWN);
  801771:	b8 03 00 00 00       	mov    $0x3,%eax
  801776:	e8 e5 fe ff ff       	call   801660 <nsipc>
}
  80177b:	c9                   	leave  
  80177c:	c3                   	ret    

0080177d <nsipc_close>:

int
nsipc_close(int s)
{
  80177d:	55                   	push   %ebp
  80177e:	89 e5                	mov    %esp,%ebp
  801780:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801783:	8b 45 08             	mov    0x8(%ebp),%eax
  801786:	a3 00 50 80 00       	mov    %eax,0x805000
	return nsipc(NSREQ_CLOSE);
  80178b:	b8 04 00 00 00       	mov    $0x4,%eax
  801790:	e8 cb fe ff ff       	call   801660 <nsipc>
}
  801795:	c9                   	leave  
  801796:	c3                   	ret    

00801797 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801797:	55                   	push   %ebp
  801798:	89 e5                	mov    %esp,%ebp
  80179a:	53                   	push   %ebx
  80179b:	83 ec 14             	sub    $0x14,%esp
  80179e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8017a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a4:	a3 00 50 80 00       	mov    %eax,0x805000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8017a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b4:	c7 04 24 04 50 80 00 	movl   $0x805004,(%esp)
  8017bb:	e8 2c f4 ff ff       	call   800bec <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8017c0:	89 1d 14 50 80 00    	mov    %ebx,0x805014
	return nsipc(NSREQ_CONNECT);
  8017c6:	b8 05 00 00 00       	mov    $0x5,%eax
  8017cb:	e8 90 fe ff ff       	call   801660 <nsipc>
}
  8017d0:	83 c4 14             	add    $0x14,%esp
  8017d3:	5b                   	pop    %ebx
  8017d4:	5d                   	pop    %ebp
  8017d5:	c3                   	ret    

008017d6 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8017d6:	55                   	push   %ebp
  8017d7:	89 e5                	mov    %esp,%ebp
  8017d9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8017dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8017df:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.listen.req_backlog = backlog;
  8017e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017e7:	a3 04 50 80 00       	mov    %eax,0x805004
	return nsipc(NSREQ_LISTEN);
  8017ec:	b8 06 00 00 00       	mov    $0x6,%eax
  8017f1:	e8 6a fe ff ff       	call   801660 <nsipc>
}
  8017f6:	c9                   	leave  
  8017f7:	c3                   	ret    

008017f8 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8017f8:	55                   	push   %ebp
  8017f9:	89 e5                	mov    %esp,%ebp
  8017fb:	56                   	push   %esi
  8017fc:	53                   	push   %ebx
  8017fd:	83 ec 10             	sub    $0x10,%esp
  801800:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801803:	8b 45 08             	mov    0x8(%ebp),%eax
  801806:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.recv.req_len = len;
  80180b:	89 35 04 50 80 00    	mov    %esi,0x805004
	nsipcbuf.recv.req_flags = flags;
  801811:	8b 45 14             	mov    0x14(%ebp),%eax
  801814:	a3 08 50 80 00       	mov    %eax,0x805008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801819:	b8 07 00 00 00       	mov    $0x7,%eax
  80181e:	e8 3d fe ff ff       	call   801660 <nsipc>
  801823:	89 c3                	mov    %eax,%ebx
  801825:	85 c0                	test   %eax,%eax
  801827:	78 46                	js     80186f <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801829:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80182e:	7f 04                	jg     801834 <nsipc_recv+0x3c>
  801830:	39 c6                	cmp    %eax,%esi
  801832:	7d 24                	jge    801858 <nsipc_recv+0x60>
  801834:	c7 44 24 0c 36 22 80 	movl   $0x802236,0xc(%esp)
  80183b:	00 
  80183c:	c7 44 24 08 4b 22 80 	movl   $0x80224b,0x8(%esp)
  801843:	00 
  801844:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  80184b:	00 
  80184c:	c7 04 24 60 22 80 00 	movl   $0x802260,(%esp)
  801853:	e8 78 eb ff ff       	call   8003d0 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801858:	89 44 24 08          	mov    %eax,0x8(%esp)
  80185c:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801863:	00 
  801864:	8b 45 0c             	mov    0xc(%ebp),%eax
  801867:	89 04 24             	mov    %eax,(%esp)
  80186a:	e8 7d f3 ff ff       	call   800bec <memmove>
	}

	return r;
}
  80186f:	89 d8                	mov    %ebx,%eax
  801871:	83 c4 10             	add    $0x10,%esp
  801874:	5b                   	pop    %ebx
  801875:	5e                   	pop    %esi
  801876:	5d                   	pop    %ebp
  801877:	c3                   	ret    

00801878 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801878:	55                   	push   %ebp
  801879:	89 e5                	mov    %esp,%ebp
  80187b:	53                   	push   %ebx
  80187c:	83 ec 14             	sub    $0x14,%esp
  80187f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801882:	8b 45 08             	mov    0x8(%ebp),%eax
  801885:	a3 00 50 80 00       	mov    %eax,0x805000
	assert(size < 1600);
  80188a:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801890:	7e 24                	jle    8018b6 <nsipc_send+0x3e>
  801892:	c7 44 24 0c 6c 22 80 	movl   $0x80226c,0xc(%esp)
  801899:	00 
  80189a:	c7 44 24 08 4b 22 80 	movl   $0x80224b,0x8(%esp)
  8018a1:	00 
  8018a2:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  8018a9:	00 
  8018aa:	c7 04 24 60 22 80 00 	movl   $0x802260,(%esp)
  8018b1:	e8 1a eb ff ff       	call   8003d0 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8018b6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018c1:	c7 04 24 0c 50 80 00 	movl   $0x80500c,(%esp)
  8018c8:	e8 1f f3 ff ff       	call   800bec <memmove>
	nsipcbuf.send.req_size = size;
  8018cd:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	nsipcbuf.send.req_flags = flags;
  8018d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8018d6:	a3 08 50 80 00       	mov    %eax,0x805008
	return nsipc(NSREQ_SEND);
  8018db:	b8 08 00 00 00       	mov    $0x8,%eax
  8018e0:	e8 7b fd ff ff       	call   801660 <nsipc>
}
  8018e5:	83 c4 14             	add    $0x14,%esp
  8018e8:	5b                   	pop    %ebx
  8018e9:	5d                   	pop    %ebp
  8018ea:	c3                   	ret    

008018eb <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8018eb:	55                   	push   %ebp
  8018ec:	89 e5                	mov    %esp,%ebp
  8018ee:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8018f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f4:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.socket.req_type = type;
  8018f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018fc:	a3 04 50 80 00       	mov    %eax,0x805004
	nsipcbuf.socket.req_protocol = protocol;
  801901:	8b 45 10             	mov    0x10(%ebp),%eax
  801904:	a3 08 50 80 00       	mov    %eax,0x805008
	return nsipc(NSREQ_SOCKET);
  801909:	b8 09 00 00 00       	mov    $0x9,%eax
  80190e:	e8 4d fd ff ff       	call   801660 <nsipc>
}
  801913:	c9                   	leave  
  801914:	c3                   	ret    
  801915:	00 00                	add    %al,(%eax)
	...

00801918 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801918:	55                   	push   %ebp
  801919:	89 e5                	mov    %esp,%ebp
  80191b:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80191e:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801925:	75 58                	jne    80197f <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.	
		//panic("set_pgfault_handler not implemented");
		
		if (sys_page_alloc(thisenv->env_id,(void *) (UXSTACKTOP - PGSIZE),(PTE_W|PTE_U|PTE_P)) != 0){
  801927:	a1 08 40 80 00       	mov    0x804008,%eax
  80192c:	8b 40 48             	mov    0x48(%eax),%eax
  80192f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801936:	00 
  801937:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80193e:	ee 
  80193f:	89 04 24             	mov    %eax,(%esp)
  801942:	e8 1e f5 ff ff       	call   800e65 <sys_page_alloc>
  801947:	85 c0                	test   %eax,%eax
  801949:	74 1c                	je     801967 <set_pgfault_handler+0x4f>
			panic("set_pg_fault_handler");
  80194b:	c7 44 24 08 78 22 80 	movl   $0x802278,0x8(%esp)
  801952:	00 
  801953:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80195a:	00 
  80195b:	c7 04 24 8d 22 80 00 	movl   $0x80228d,(%esp)
  801962:	e8 69 ea ff ff       	call   8003d0 <_panic>
		}
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801967:	a1 08 40 80 00       	mov    0x804008,%eax
  80196c:	8b 40 48             	mov    0x48(%eax),%eax
  80196f:	c7 44 24 04 8c 19 80 	movl   $0x80198c,0x4(%esp)
  801976:	00 
  801977:	89 04 24             	mov    %eax,(%esp)
  80197a:	e8 86 f6 ff ff       	call   801005 <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80197f:	8b 45 08             	mov    0x8(%ebp),%eax
  801982:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801987:	c9                   	leave  
  801988:	c3                   	ret    
  801989:	00 00                	add    %al,(%eax)
	...

0080198c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80198c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80198d:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801992:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801994:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// Save trap-time eip in eax
	movl 0x28(%esp), %eax
  801997:	8b 44 24 28          	mov    0x28(%esp),%eax

	// Save our current stack
	movl %esp, %ebp
  80199b:	89 e5                	mov    %esp,%ebp

	// Switch to trap-time stack
	movl 0x30(%esp), %esp
  80199d:	8b 64 24 30          	mov    0x30(%esp),%esp

	// Push trap-time eip to the trap-time stack
	pushl %eax
  8019a1:	50                   	push   %eax

	// We now have to update the trap-time esp with its new value
	movl %esp, 0x30(%ebp)
  8019a2:	89 65 30             	mov    %esp,0x30(%ebp)

	// Go back to our exception stack
	movl %ebp, %esp
  8019a5:	89 ec                	mov    %ebp,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// Pop fault_va and err, both can be ignored
	popl %eax
  8019a7:	58                   	pop    %eax
	popl %eax
  8019a8:	58                   	pop    %eax

	// Pop all registers back
	popal
  8019a9:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// Skip %eip
	addl $0x4, %esp
  8019aa:	83 c4 04             	add    $0x4,%esp

	// Pop eflags back
	popfl
  8019ad:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	
	popl %esp
  8019ae:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  8019af:	c3                   	ret    

008019b0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8019b0:	55                   	push   %ebp
  8019b1:	57                   	push   %edi
  8019b2:	56                   	push   %esi
  8019b3:	83 ec 10             	sub    $0x10,%esp
  8019b6:	8b 74 24 20          	mov    0x20(%esp),%esi
  8019ba:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8019be:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019c2:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  8019c6:	89 cd                	mov    %ecx,%ebp
  8019c8:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8019cc:	85 c0                	test   %eax,%eax
  8019ce:	75 2c                	jne    8019fc <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8019d0:	39 f9                	cmp    %edi,%ecx
  8019d2:	77 68                	ja     801a3c <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8019d4:	85 c9                	test   %ecx,%ecx
  8019d6:	75 0b                	jne    8019e3 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8019d8:	b8 01 00 00 00       	mov    $0x1,%eax
  8019dd:	31 d2                	xor    %edx,%edx
  8019df:	f7 f1                	div    %ecx
  8019e1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8019e3:	31 d2                	xor    %edx,%edx
  8019e5:	89 f8                	mov    %edi,%eax
  8019e7:	f7 f1                	div    %ecx
  8019e9:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8019eb:	89 f0                	mov    %esi,%eax
  8019ed:	f7 f1                	div    %ecx
  8019ef:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8019f1:	89 f0                	mov    %esi,%eax
  8019f3:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8019f5:	83 c4 10             	add    $0x10,%esp
  8019f8:	5e                   	pop    %esi
  8019f9:	5f                   	pop    %edi
  8019fa:	5d                   	pop    %ebp
  8019fb:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8019fc:	39 f8                	cmp    %edi,%eax
  8019fe:	77 2c                	ja     801a2c <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801a00:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  801a03:	83 f6 1f             	xor    $0x1f,%esi
  801a06:	75 4c                	jne    801a54 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801a08:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801a0a:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801a0f:	72 0a                	jb     801a1b <__udivdi3+0x6b>
  801a11:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801a15:	0f 87 ad 00 00 00    	ja     801ac8 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801a1b:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801a20:	89 f0                	mov    %esi,%eax
  801a22:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801a24:	83 c4 10             	add    $0x10,%esp
  801a27:	5e                   	pop    %esi
  801a28:	5f                   	pop    %edi
  801a29:	5d                   	pop    %ebp
  801a2a:	c3                   	ret    
  801a2b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801a2c:	31 ff                	xor    %edi,%edi
  801a2e:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801a30:	89 f0                	mov    %esi,%eax
  801a32:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801a34:	83 c4 10             	add    $0x10,%esp
  801a37:	5e                   	pop    %esi
  801a38:	5f                   	pop    %edi
  801a39:	5d                   	pop    %ebp
  801a3a:	c3                   	ret    
  801a3b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801a3c:	89 fa                	mov    %edi,%edx
  801a3e:	89 f0                	mov    %esi,%eax
  801a40:	f7 f1                	div    %ecx
  801a42:	89 c6                	mov    %eax,%esi
  801a44:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801a46:	89 f0                	mov    %esi,%eax
  801a48:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801a4a:	83 c4 10             	add    $0x10,%esp
  801a4d:	5e                   	pop    %esi
  801a4e:	5f                   	pop    %edi
  801a4f:	5d                   	pop    %ebp
  801a50:	c3                   	ret    
  801a51:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801a54:	89 f1                	mov    %esi,%ecx
  801a56:	d3 e0                	shl    %cl,%eax
  801a58:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801a5c:	b8 20 00 00 00       	mov    $0x20,%eax
  801a61:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801a63:	89 ea                	mov    %ebp,%edx
  801a65:	88 c1                	mov    %al,%cl
  801a67:	d3 ea                	shr    %cl,%edx
  801a69:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801a6d:	09 ca                	or     %ecx,%edx
  801a6f:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  801a73:	89 f1                	mov    %esi,%ecx
  801a75:	d3 e5                	shl    %cl,%ebp
  801a77:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  801a7b:	89 fd                	mov    %edi,%ebp
  801a7d:	88 c1                	mov    %al,%cl
  801a7f:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  801a81:	89 fa                	mov    %edi,%edx
  801a83:	89 f1                	mov    %esi,%ecx
  801a85:	d3 e2                	shl    %cl,%edx
  801a87:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801a8b:	88 c1                	mov    %al,%cl
  801a8d:	d3 ef                	shr    %cl,%edi
  801a8f:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801a91:	89 f8                	mov    %edi,%eax
  801a93:	89 ea                	mov    %ebp,%edx
  801a95:	f7 74 24 08          	divl   0x8(%esp)
  801a99:	89 d1                	mov    %edx,%ecx
  801a9b:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  801a9d:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801aa1:	39 d1                	cmp    %edx,%ecx
  801aa3:	72 17                	jb     801abc <__udivdi3+0x10c>
  801aa5:	74 09                	je     801ab0 <__udivdi3+0x100>
  801aa7:	89 fe                	mov    %edi,%esi
  801aa9:	31 ff                	xor    %edi,%edi
  801aab:	e9 41 ff ff ff       	jmp    8019f1 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801ab0:	8b 54 24 04          	mov    0x4(%esp),%edx
  801ab4:	89 f1                	mov    %esi,%ecx
  801ab6:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801ab8:	39 c2                	cmp    %eax,%edx
  801aba:	73 eb                	jae    801aa7 <__udivdi3+0xf7>
		{
		  q0--;
  801abc:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801abf:	31 ff                	xor    %edi,%edi
  801ac1:	e9 2b ff ff ff       	jmp    8019f1 <__udivdi3+0x41>
  801ac6:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801ac8:	31 f6                	xor    %esi,%esi
  801aca:	e9 22 ff ff ff       	jmp    8019f1 <__udivdi3+0x41>
	...

00801ad0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801ad0:	55                   	push   %ebp
  801ad1:	57                   	push   %edi
  801ad2:	56                   	push   %esi
  801ad3:	83 ec 20             	sub    $0x20,%esp
  801ad6:	8b 44 24 30          	mov    0x30(%esp),%eax
  801ada:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801ade:	89 44 24 14          	mov    %eax,0x14(%esp)
  801ae2:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  801ae6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801aea:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801aee:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  801af0:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801af2:	85 ed                	test   %ebp,%ebp
  801af4:	75 16                	jne    801b0c <__umoddi3+0x3c>
    {
      if (d0 > n1)
  801af6:	39 f1                	cmp    %esi,%ecx
  801af8:	0f 86 a6 00 00 00    	jbe    801ba4 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801afe:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801b00:	89 d0                	mov    %edx,%eax
  801b02:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801b04:	83 c4 20             	add    $0x20,%esp
  801b07:	5e                   	pop    %esi
  801b08:	5f                   	pop    %edi
  801b09:	5d                   	pop    %ebp
  801b0a:	c3                   	ret    
  801b0b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801b0c:	39 f5                	cmp    %esi,%ebp
  801b0e:	0f 87 ac 00 00 00    	ja     801bc0 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801b14:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  801b17:	83 f0 1f             	xor    $0x1f,%eax
  801b1a:	89 44 24 10          	mov    %eax,0x10(%esp)
  801b1e:	0f 84 a8 00 00 00    	je     801bcc <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801b24:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801b28:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801b2a:	bf 20 00 00 00       	mov    $0x20,%edi
  801b2f:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801b33:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801b37:	89 f9                	mov    %edi,%ecx
  801b39:	d3 e8                	shr    %cl,%eax
  801b3b:	09 e8                	or     %ebp,%eax
  801b3d:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  801b41:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801b45:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801b49:	d3 e0                	shl    %cl,%eax
  801b4b:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801b4f:	89 f2                	mov    %esi,%edx
  801b51:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801b53:	8b 44 24 14          	mov    0x14(%esp),%eax
  801b57:	d3 e0                	shl    %cl,%eax
  801b59:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801b5d:	8b 44 24 14          	mov    0x14(%esp),%eax
  801b61:	89 f9                	mov    %edi,%ecx
  801b63:	d3 e8                	shr    %cl,%eax
  801b65:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801b67:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801b69:	89 f2                	mov    %esi,%edx
  801b6b:	f7 74 24 18          	divl   0x18(%esp)
  801b6f:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801b71:	f7 64 24 0c          	mull   0xc(%esp)
  801b75:	89 c5                	mov    %eax,%ebp
  801b77:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801b79:	39 d6                	cmp    %edx,%esi
  801b7b:	72 67                	jb     801be4 <__umoddi3+0x114>
  801b7d:	74 75                	je     801bf4 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801b7f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801b83:	29 e8                	sub    %ebp,%eax
  801b85:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801b87:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801b8b:	d3 e8                	shr    %cl,%eax
  801b8d:	89 f2                	mov    %esi,%edx
  801b8f:	89 f9                	mov    %edi,%ecx
  801b91:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801b93:	09 d0                	or     %edx,%eax
  801b95:	89 f2                	mov    %esi,%edx
  801b97:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801b9b:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801b9d:	83 c4 20             	add    $0x20,%esp
  801ba0:	5e                   	pop    %esi
  801ba1:	5f                   	pop    %edi
  801ba2:	5d                   	pop    %ebp
  801ba3:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801ba4:	85 c9                	test   %ecx,%ecx
  801ba6:	75 0b                	jne    801bb3 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801ba8:	b8 01 00 00 00       	mov    $0x1,%eax
  801bad:	31 d2                	xor    %edx,%edx
  801baf:	f7 f1                	div    %ecx
  801bb1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801bb3:	89 f0                	mov    %esi,%eax
  801bb5:	31 d2                	xor    %edx,%edx
  801bb7:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801bb9:	89 f8                	mov    %edi,%eax
  801bbb:	e9 3e ff ff ff       	jmp    801afe <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801bc0:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801bc2:	83 c4 20             	add    $0x20,%esp
  801bc5:	5e                   	pop    %esi
  801bc6:	5f                   	pop    %edi
  801bc7:	5d                   	pop    %ebp
  801bc8:	c3                   	ret    
  801bc9:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801bcc:	39 f5                	cmp    %esi,%ebp
  801bce:	72 04                	jb     801bd4 <__umoddi3+0x104>
  801bd0:	39 f9                	cmp    %edi,%ecx
  801bd2:	77 06                	ja     801bda <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801bd4:	89 f2                	mov    %esi,%edx
  801bd6:	29 cf                	sub    %ecx,%edi
  801bd8:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801bda:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801bdc:	83 c4 20             	add    $0x20,%esp
  801bdf:	5e                   	pop    %esi
  801be0:	5f                   	pop    %edi
  801be1:	5d                   	pop    %ebp
  801be2:	c3                   	ret    
  801be3:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801be4:	89 d1                	mov    %edx,%ecx
  801be6:	89 c5                	mov    %eax,%ebp
  801be8:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801bec:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801bf0:	eb 8d                	jmp    801b7f <__umoddi3+0xaf>
  801bf2:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801bf4:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801bf8:	72 ea                	jb     801be4 <__umoddi3+0x114>
  801bfa:	89 f1                	mov    %esi,%ecx
  801bfc:	eb 81                	jmp    801b7f <__umoddi3+0xaf>
