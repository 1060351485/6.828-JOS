
obj/net/testinput:     file format elf32-i386


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
  80002c:	e8 67 09 00 00       	call   800998 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	envid_t ns_envid = sys_getenvid();
  800040:	e8 06 14 00 00       	call   80144b <sys_getenvid>
  800045:	89 c3                	mov    %eax,%ebx
	int i, r, first = 1;

	binaryname = "testinput";
  800047:	c7 05 00 30 80 00 40 	movl   $0x802240,0x803000
  80004e:	22 80 00 

	output_envid = fork();
  800051:	e8 2d 18 00 00       	call   801883 <fork>
  800056:	a3 00 40 80 00       	mov    %eax,0x804000
	if (output_envid < 0)
  80005b:	85 c0                	test   %eax,%eax
  80005d:	79 1c                	jns    80007b <umain+0x47>
		panic("error forking");
  80005f:	c7 44 24 08 4a 22 80 	movl   $0x80224a,0x8(%esp)
  800066:	00 
  800067:	c7 44 24 04 4d 00 00 	movl   $0x4d,0x4(%esp)
  80006e:	00 
  80006f:	c7 04 24 58 22 80 00 	movl   $0x802258,(%esp)
  800076:	e8 79 09 00 00       	call   8009f4 <_panic>
	else if (output_envid == 0) {
  80007b:	85 c0                	test   %eax,%eax
  80007d:	75 0d                	jne    80008c <umain+0x58>
		output(ns_envid);
  80007f:	89 1c 24             	mov    %ebx,(%esp)
  800082:	e8 35 05 00 00       	call   8005bc <output>
		return;
  800087:	e9 af 03 00 00       	jmp    80043b <umain+0x407>
	}

	input_envid = fork();
  80008c:	e8 f2 17 00 00       	call   801883 <fork>
  800091:	a3 04 40 80 00       	mov    %eax,0x804004
	if (input_envid < 0)
  800096:	85 c0                	test   %eax,%eax
  800098:	79 1c                	jns    8000b6 <umain+0x82>
		panic("error forking");
  80009a:	c7 44 24 08 4a 22 80 	movl   $0x80224a,0x8(%esp)
  8000a1:	00 
  8000a2:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
  8000a9:	00 
  8000aa:	c7 04 24 58 22 80 00 	movl   $0x802258,(%esp)
  8000b1:	e8 3e 09 00 00       	call   8009f4 <_panic>
	else if (input_envid == 0) {
  8000b6:	85 c0                	test   %eax,%eax
  8000b8:	75 0d                	jne    8000c7 <umain+0x93>
		input(ns_envid);
  8000ba:	89 1c 24             	mov    %ebx,(%esp)
  8000bd:	e8 42 04 00 00       	call   800504 <input>
		return;
  8000c2:	e9 74 03 00 00       	jmp    80043b <umain+0x407>
	}

	cprintf("Sending ARP announcement...\n");
  8000c7:	c7 04 24 68 22 80 00 	movl   $0x802268,(%esp)
  8000ce:	e8 19 0a 00 00       	call   800aec <cprintf>
	// with ARP requests.  Ideally, we would use gratuitous ARP
	// for this, but QEMU's ARP implementation is dumb and only
	// listens for very specific ARP requests, such as requests
	// for the gateway IP.

	uint8_t mac[6] = {0x52, 0x54, 0x00, 0x12, 0x34, 0x56};
  8000d3:	c6 45 90 52          	movb   $0x52,-0x70(%ebp)
  8000d7:	c6 45 91 54          	movb   $0x54,-0x6f(%ebp)
  8000db:	c6 45 92 00          	movb   $0x0,-0x6e(%ebp)
  8000df:	c6 45 93 12          	movb   $0x12,-0x6d(%ebp)
  8000e3:	c6 45 94 34          	movb   $0x34,-0x6c(%ebp)
  8000e7:	c6 45 95 56          	movb   $0x56,-0x6b(%ebp)
	uint32_t myip = inet_addr(IP);
  8000eb:	c7 04 24 85 22 80 00 	movl   $0x802285,(%esp)
  8000f2:	e8 64 08 00 00       	call   80095b <inet_addr>
  8000f7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uint32_t gwip = inet_addr(DEFAULT);
  8000fa:	c7 04 24 8f 22 80 00 	movl   $0x80228f,(%esp)
  800101:	e8 55 08 00 00       	call   80095b <inet_addr>
  800106:	89 45 e0             	mov    %eax,-0x20(%ebp)
	int r;

	if ((r = sys_page_alloc(0, pkt, PTE_P|PTE_U|PTE_W)) < 0)
  800109:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800110:	00 
  800111:	c7 44 24 04 00 b0 fe 	movl   $0xffeb000,0x4(%esp)
  800118:	0f 
  800119:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800120:	e8 64 13 00 00       	call   801489 <sys_page_alloc>
  800125:	85 c0                	test   %eax,%eax
  800127:	79 20                	jns    800149 <umain+0x115>
		panic("sys_page_map: %e", r);
  800129:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80012d:	c7 44 24 08 98 22 80 	movl   $0x802298,0x8(%esp)
  800134:	00 
  800135:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
  80013c:	00 
  80013d:	c7 04 24 58 22 80 00 	movl   $0x802258,(%esp)
  800144:	e8 ab 08 00 00       	call   8009f4 <_panic>

	struct etharp_hdr *arp = (struct etharp_hdr*)pkt->jp_data;
	pkt->jp_len = sizeof(*arp);
  800149:	c7 05 00 b0 fe 0f 2a 	movl   $0x2a,0xffeb000
  800150:	00 00 00 

	memset(arp->ethhdr.dest.addr, 0xff, ETHARP_HWADDR_LEN);
  800153:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
  80015a:	00 
  80015b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800162:	00 
  800163:	c7 04 24 04 b0 fe 0f 	movl   $0xffeb004,(%esp)
  80016a:	e8 57 10 00 00       	call   8011c6 <memset>
	memcpy(arp->ethhdr.src.addr,  mac,  ETHARP_HWADDR_LEN);
  80016f:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
  800176:	00 
  800177:	8d 5d 90             	lea    -0x70(%ebp),%ebx
  80017a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80017e:	c7 04 24 0a b0 fe 0f 	movl   $0xffeb00a,(%esp)
  800185:	e8 f0 10 00 00       	call   80127a <memcpy>
	arp->ethhdr.type = htons(ETHTYPE_ARP);
  80018a:	c7 04 24 06 08 00 00 	movl   $0x806,(%esp)
  800191:	e8 77 05 00 00       	call   80070d <htons>
  800196:	66 a3 10 b0 fe 0f    	mov    %ax,0xffeb010
	arp->hwtype = htons(1); // Ethernet
  80019c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001a3:	e8 65 05 00 00       	call   80070d <htons>
  8001a8:	66 a3 12 b0 fe 0f    	mov    %ax,0xffeb012
	arp->proto = htons(ETHTYPE_IP);
  8001ae:	c7 04 24 00 08 00 00 	movl   $0x800,(%esp)
  8001b5:	e8 53 05 00 00       	call   80070d <htons>
  8001ba:	66 a3 14 b0 fe 0f    	mov    %ax,0xffeb014
	arp->_hwlen_protolen = htons((ETHARP_HWADDR_LEN << 8) | 4);
  8001c0:	c7 04 24 04 06 00 00 	movl   $0x604,(%esp)
  8001c7:	e8 41 05 00 00       	call   80070d <htons>
  8001cc:	66 a3 16 b0 fe 0f    	mov    %ax,0xffeb016
	arp->opcode = htons(ARP_REQUEST);
  8001d2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001d9:	e8 2f 05 00 00       	call   80070d <htons>
  8001de:	66 a3 18 b0 fe 0f    	mov    %ax,0xffeb018
	memcpy(arp->shwaddr.addr,  mac,   ETHARP_HWADDR_LEN);
  8001e4:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
  8001eb:	00 
  8001ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001f0:	c7 04 24 1a b0 fe 0f 	movl   $0xffeb01a,(%esp)
  8001f7:	e8 7e 10 00 00       	call   80127a <memcpy>
	memcpy(arp->sipaddr.addrw, &myip, 4);
  8001fc:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  800203:	00 
  800204:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800207:	89 44 24 04          	mov    %eax,0x4(%esp)
  80020b:	c7 04 24 20 b0 fe 0f 	movl   $0xffeb020,(%esp)
  800212:	e8 63 10 00 00       	call   80127a <memcpy>
	memset(arp->dhwaddr.addr,  0x00,  ETHARP_HWADDR_LEN);
  800217:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
  80021e:	00 
  80021f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800226:	00 
  800227:	c7 04 24 24 b0 fe 0f 	movl   $0xffeb024,(%esp)
  80022e:	e8 93 0f 00 00       	call   8011c6 <memset>
	memcpy(arp->dipaddr.addrw, &gwip, 4);
  800233:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  80023a:	00 
  80023b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80023e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800242:	c7 04 24 2a b0 fe 0f 	movl   $0xffeb02a,(%esp)
  800249:	e8 2c 10 00 00       	call   80127a <memcpy>

	ipc_send(output_envid, NSREQ_OUTPUT, pkt, PTE_P|PTE_W|PTE_U);
  80024e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800255:	00 
  800256:	c7 44 24 08 00 b0 fe 	movl   $0xffeb000,0x8(%esp)
  80025d:	0f 
  80025e:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
  800265:	00 
  800266:	a1 00 40 80 00       	mov    0x804000,%eax
  80026b:	89 04 24             	mov    %eax,(%esp)
  80026e:	e8 6a 19 00 00       	call   801bdd <ipc_send>
	sys_page_unmap(0, pkt);
  800273:	c7 44 24 04 00 b0 fe 	movl   $0xffeb000,0x4(%esp)
  80027a:	0f 
  80027b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800282:	e8 a9 12 00 00       	call   801530 <sys_page_unmap>

void
umain(int argc, char **argv)
{
	envid_t ns_envid = sys_getenvid();
	int i, r, first = 1;
  800287:	c7 85 78 ff ff ff 01 	movl   $0x1,-0x88(%ebp)
  80028e:	00 00 00 

	while (1) {
		envid_t whom;
		int perm;

		int32_t req = ipc_recv((int32_t *)&whom, pkt, &perm);
  800291:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800294:	89 45 80             	mov    %eax,-0x80(%ebp)
  800297:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80029a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80029e:	c7 44 24 04 00 b0 fe 	movl   $0xffeb000,0x4(%esp)
  8002a5:	0f 
  8002a6:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8002a9:	89 04 24             	mov    %eax,(%esp)
  8002ac:	e8 c3 18 00 00       	call   801b74 <ipc_recv>
		if (req < 0)
  8002b1:	85 c0                	test   %eax,%eax
  8002b3:	79 20                	jns    8002d5 <umain+0x2a1>
			panic("ipc_recv: %e", req);
  8002b5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002b9:	c7 44 24 08 a9 22 80 	movl   $0x8022a9,0x8(%esp)
  8002c0:	00 
  8002c1:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8002c8:	00 
  8002c9:	c7 04 24 58 22 80 00 	movl   $0x802258,(%esp)
  8002d0:	e8 1f 07 00 00       	call   8009f4 <_panic>
		if (whom != input_envid)
  8002d5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8002d8:	3b 15 04 40 80 00    	cmp    0x804004,%edx
  8002de:	74 20                	je     800300 <umain+0x2cc>
			panic("IPC from unexpected environment %08x", whom);
  8002e0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002e4:	c7 44 24 08 00 23 80 	movl   $0x802300,0x8(%esp)
  8002eb:	00 
  8002ec:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
  8002f3:	00 
  8002f4:	c7 04 24 58 22 80 00 	movl   $0x802258,(%esp)
  8002fb:	e8 f4 06 00 00       	call   8009f4 <_panic>
		if (req != NSREQ_INPUT)
  800300:	83 f8 0a             	cmp    $0xa,%eax
  800303:	74 20                	je     800325 <umain+0x2f1>
			panic("Unexpected IPC %d", req);
  800305:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800309:	c7 44 24 08 b6 22 80 	movl   $0x8022b6,0x8(%esp)
  800310:	00 
  800311:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
  800318:	00 
  800319:	c7 04 24 58 22 80 00 	movl   $0x802258,(%esp)
  800320:	e8 cf 06 00 00       	call   8009f4 <_panic>

		hexdump("input: ", pkt->jp_data, pkt->jp_len);
  800325:	a1 00 b0 fe 0f       	mov    0xffeb000,%eax
  80032a:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
hexdump(const char *prefix, const void *data, int len)
{
	int i;
	char buf[80];
	char *end = buf + sizeof(buf);
	char *out = NULL;
  800330:	be 00 00 00 00       	mov    $0x0,%esi
	for (i = 0; i < len; i++) {
  800335:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (i % 16 == 0)
			out = buf + snprintf(buf, end - buf,
  80033a:	8d 45 90             	lea    -0x70(%ebp),%eax
  80033d:	89 45 84             	mov    %eax,-0x7c(%ebp)
  800340:	e9 b6 00 00 00       	jmp    8003fb <umain+0x3c7>
	int i;
	char buf[80];
	char *end = buf + sizeof(buf);
	char *out = NULL;
	for (i = 0; i < len; i++) {
		if (i % 16 == 0)
  800345:	89 df                	mov    %ebx,%edi
  800347:	f6 c3 0f             	test   $0xf,%bl
  80034a:	75 2c                	jne    800378 <umain+0x344>
			out = buf + snprintf(buf, end - buf,
  80034c:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800350:	c7 44 24 0c c8 22 80 	movl   $0x8022c8,0xc(%esp)
  800357:	00 
  800358:	c7 44 24 08 d0 22 80 	movl   $0x8022d0,0x8(%esp)
  80035f:	00 
  800360:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  800367:	00 
  800368:	8d 45 90             	lea    -0x70(%ebp),%eax
  80036b:	89 04 24             	mov    %eax,(%esp)
  80036e:	e8 c6 0c 00 00       	call   801039 <snprintf>
  800373:	8d 75 90             	lea    -0x70(%ebp),%esi
  800376:	01 c6                	add    %eax,%esi
					     "%s%04x   ", prefix, i);
		out += snprintf(out, end - out, "%02x", ((uint8_t*)data)[i]);
  800378:	0f b6 87 04 b0 fe 0f 	movzbl 0xffeb004(%edi),%eax
  80037f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800383:	c7 44 24 08 da 22 80 	movl   $0x8022da,0x8(%esp)
  80038a:	00 
  80038b:	8b 45 80             	mov    -0x80(%ebp),%eax
  80038e:	29 f0                	sub    %esi,%eax
  800390:	89 44 24 04          	mov    %eax,0x4(%esp)
  800394:	89 34 24             	mov    %esi,(%esp)
  800397:	e8 9d 0c 00 00       	call   801039 <snprintf>
  80039c:	01 c6                	add    %eax,%esi
		if (i % 16 == 15 || i == len - 1)
  80039e:	89 d8                	mov    %ebx,%eax
  8003a0:	25 0f 00 00 80       	and    $0x8000000f,%eax
  8003a5:	79 05                	jns    8003ac <umain+0x378>
  8003a7:	48                   	dec    %eax
  8003a8:	83 c8 f0             	or     $0xfffffff0,%eax
  8003ab:	40                   	inc    %eax
  8003ac:	89 c7                	mov    %eax,%edi
  8003ae:	83 f8 0f             	cmp    $0xf,%eax
  8003b1:	74 0b                	je     8003be <umain+0x38a>
  8003b3:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  8003b9:	48                   	dec    %eax
  8003ba:	39 c3                	cmp    %eax,%ebx
  8003bc:	75 1c                	jne    8003da <umain+0x3a6>
			cprintf("%.*s\n", out - buf, buf);
  8003be:	8d 45 90             	lea    -0x70(%ebp),%eax
  8003c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003c5:	89 f0                	mov    %esi,%eax
  8003c7:	2b 45 84             	sub    -0x7c(%ebp),%eax
  8003ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ce:	c7 04 24 df 22 80 00 	movl   $0x8022df,(%esp)
  8003d5:	e8 12 07 00 00       	call   800aec <cprintf>
		if (i % 2 == 1)
  8003da:	89 d8                	mov    %ebx,%eax
  8003dc:	25 01 00 00 80       	and    $0x80000001,%eax
  8003e1:	79 05                	jns    8003e8 <umain+0x3b4>
  8003e3:	48                   	dec    %eax
  8003e4:	83 c8 fe             	or     $0xfffffffe,%eax
  8003e7:	40                   	inc    %eax
  8003e8:	83 f8 01             	cmp    $0x1,%eax
  8003eb:	75 04                	jne    8003f1 <umain+0x3bd>
			*(out++) = ' ';
  8003ed:	c6 06 20             	movb   $0x20,(%esi)
  8003f0:	46                   	inc    %esi
		if (i % 16 == 7)
  8003f1:	83 ff 07             	cmp    $0x7,%edi
  8003f4:	75 04                	jne    8003fa <umain+0x3c6>
			*(out++) = ' ';
  8003f6:	c6 06 20             	movb   $0x20,(%esi)
  8003f9:	46                   	inc    %esi
{
	int i;
	char buf[80];
	char *end = buf + sizeof(buf);
	char *out = NULL;
	for (i = 0; i < len; i++) {
  8003fa:	43                   	inc    %ebx
  8003fb:	39 9d 7c ff ff ff    	cmp    %ebx,-0x84(%ebp)
  800401:	0f 8f 3e ff ff ff    	jg     800345 <umain+0x311>
			panic("IPC from unexpected environment %08x", whom);
		if (req != NSREQ_INPUT)
			panic("Unexpected IPC %d", req);

		hexdump("input: ", pkt->jp_data, pkt->jp_len);
		cprintf("\n");
  800407:	c7 04 24 fb 22 80 00 	movl   $0x8022fb,(%esp)
  80040e:	e8 d9 06 00 00       	call   800aec <cprintf>

		// Only indicate that we're waiting for packets once
		// we've received the ARP reply
		if (first)
  800413:	83 bd 78 ff ff ff 00 	cmpl   $0x0,-0x88(%ebp)
  80041a:	0f 84 77 fe ff ff    	je     800297 <umain+0x263>
			cprintf("Waiting for packets...\n");
  800420:	c7 04 24 e5 22 80 00 	movl   $0x8022e5,(%esp)
  800427:	e8 c0 06 00 00       	call   800aec <cprintf>
		first = 0;
  80042c:	c7 85 78 ff ff ff 00 	movl   $0x0,-0x88(%ebp)
  800433:	00 00 00 
  800436:	e9 5c fe ff ff       	jmp    800297 <umain+0x263>
	}
}
  80043b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  800441:	5b                   	pop    %ebx
  800442:	5e                   	pop    %esi
  800443:	5f                   	pop    %edi
  800444:	5d                   	pop    %ebp
  800445:	c3                   	ret    
	...

00800448 <timer>:
#include "ns.h"

void
timer(envid_t ns_envid, uint32_t initial_to) {
  800448:	55                   	push   %ebp
  800449:	89 e5                	mov    %esp,%ebp
  80044b:	57                   	push   %edi
  80044c:	56                   	push   %esi
  80044d:	53                   	push   %ebx
  80044e:	83 ec 2c             	sub    $0x2c,%esp
  800451:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	uint32_t stop = sys_time_msec() + initial_to;
  800454:	e8 98 12 00 00       	call   8016f1 <sys_time_msec>
  800459:	89 c3                	mov    %eax,%ebx
  80045b:	03 5d 0c             	add    0xc(%ebp),%ebx

	binaryname = "ns_timer";
  80045e:	c7 05 00 30 80 00 25 	movl   $0x802325,0x803000
  800465:	23 80 00 

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  800468:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80046b:	eb 05                	jmp    800472 <timer+0x2a>

	binaryname = "ns_timer";

	while (1) {
		while((r = sys_time_msec()) < stop && r >= 0) {
			sys_yield();
  80046d:	e8 f8 0f 00 00       	call   80146a <sys_yield>
	uint32_t stop = sys_time_msec() + initial_to;

	binaryname = "ns_timer";

	while (1) {
		while((r = sys_time_msec()) < stop && r >= 0) {
  800472:	e8 7a 12 00 00       	call   8016f1 <sys_time_msec>
  800477:	39 c3                	cmp    %eax,%ebx
  800479:	76 06                	jbe    800481 <timer+0x39>
  80047b:	85 c0                	test   %eax,%eax
  80047d:	79 ee                	jns    80046d <timer+0x25>
  80047f:	eb 04                	jmp    800485 <timer+0x3d>
			sys_yield();
		}
		if (r < 0)
  800481:	85 c0                	test   %eax,%eax
  800483:	79 20                	jns    8004a5 <timer+0x5d>
			panic("sys_time_msec: %e", r);
  800485:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800489:	c7 44 24 08 2e 23 80 	movl   $0x80232e,0x8(%esp)
  800490:	00 
  800491:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  800498:	00 
  800499:	c7 04 24 40 23 80 00 	movl   $0x802340,(%esp)
  8004a0:	e8 4f 05 00 00       	call   8009f4 <_panic>

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);
  8004a5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004ac:	00 
  8004ad:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8004b4:	00 
  8004b5:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
  8004bc:	00 
  8004bd:	89 3c 24             	mov    %edi,(%esp)
  8004c0:	e8 18 17 00 00       	call   801bdd <ipc_send>

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  8004c5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8004cc:	00 
  8004cd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8004d4:	00 
  8004d5:	89 34 24             	mov    %esi,(%esp)
  8004d8:	e8 97 16 00 00       	call   801b74 <ipc_recv>
  8004dd:	89 c3                	mov    %eax,%ebx

			if (whom != ns_envid) {
  8004df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004e2:	39 c7                	cmp    %eax,%edi
  8004e4:	74 12                	je     8004f8 <timer+0xb0>
				cprintf("NS TIMER: timer thread got IPC message from env %x not NS\n", whom);
  8004e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ea:	c7 04 24 4c 23 80 00 	movl   $0x80234c,(%esp)
  8004f1:	e8 f6 05 00 00       	call   800aec <cprintf>
				continue;
			}

			stop = sys_time_msec() + to;
			break;
		}
  8004f6:	eb cd                	jmp    8004c5 <timer+0x7d>
			if (whom != ns_envid) {
				cprintf("NS TIMER: timer thread got IPC message from env %x not NS\n", whom);
				continue;
			}

			stop = sys_time_msec() + to;
  8004f8:	e8 f4 11 00 00       	call   8016f1 <sys_time_msec>
  8004fd:	01 c3                	add    %eax,%ebx
			break;
		}
	}
  8004ff:	e9 6e ff ff ff       	jmp    800472 <timer+0x2a>

00800504 <input>:

extern union Nsipc nsipcbuf;

void
input(envid_t ns_envid)
{
  800504:	55                   	push   %ebp
  800505:	89 e5                	mov    %esp,%ebp
  800507:	57                   	push   %edi
  800508:	56                   	push   %esi
  800509:	53                   	push   %ebx
  80050a:	81 ec 2c 08 00 00    	sub    $0x82c,%esp
  800510:	8b 7d 08             	mov    0x8(%ebp),%edi
	binaryname = "ns_input";
  800513:	c7 05 00 30 80 00 87 	movl   $0x802387,0x803000
  80051a:	23 80 00 
	int perm = PTE_P | PTE_W | PTE_U;
	size_t length;
	char pkt[PKT_SIZE];

	while (1) {
		while (sys_e1000_receive(pkt, &length) == -E_E1000_RXBUF_EMPTY)
  80051d:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800520:	8d 9d e4 f7 ff ff    	lea    -0x81c(%ebp),%ebx
  800526:	89 74 24 04          	mov    %esi,0x4(%esp)
  80052a:	89 1c 24             	mov    %ebx,(%esp)
  80052d:	e8 ff 11 00 00       	call   801731 <sys_e1000_receive>
  800532:	83 f8 ef             	cmp    $0xffffffef,%eax
  800535:	74 ef                	je     800526 <input+0x22>
		  ;

		int r;
		if ((r = sys_page_alloc(0, &nsipcbuf, perm)) < 0)
  800537:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80053e:	00 
  80053f:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800546:	00 
  800547:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80054e:	e8 36 0f 00 00       	call   801489 <sys_page_alloc>
  800553:	85 c0                	test   %eax,%eax
  800555:	79 20                	jns    800577 <input+0x73>
		  panic("input: unable to allocate new page, error %e\n", r);
  800557:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80055b:	c7 44 24 08 9c 23 80 	movl   $0x80239c,0x8(%esp)
  800562:	00 
  800563:	c7 44 24 04 1c 00 00 	movl   $0x1c,0x4(%esp)
  80056a:	00 
  80056b:	c7 04 24 90 23 80 00 	movl   $0x802390,(%esp)
  800572:	e8 7d 04 00 00       	call   8009f4 <_panic>

		memmove(nsipcbuf.pkt.jp_data, pkt, length);
  800577:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80057a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80057e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800582:	c7 04 24 04 50 80 00 	movl   $0x805004,(%esp)
  800589:	e8 82 0c 00 00       	call   801210 <memmove>
		nsipcbuf.pkt.jp_len = length;
  80058e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800591:	a3 00 50 80 00       	mov    %eax,0x805000

		ipc_send(ns_envid, NSREQ_INPUT, &nsipcbuf, perm);
  800596:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80059d:	00 
  80059e:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8005a5:	00 
  8005a6:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
  8005ad:	00 
  8005ae:	89 3c 24             	mov    %edi,(%esp)
  8005b1:	e8 27 16 00 00       	call   801bdd <ipc_send>
	}
  8005b6:	e9 6b ff ff ff       	jmp    800526 <input+0x22>
	...

008005bc <output>:

extern union Nsipc nsipcbuf;

void
output(envid_t ns_envid)
{
  8005bc:	55                   	push   %ebp
  8005bd:	89 e5                	mov    %esp,%ebp
  8005bf:	57                   	push   %edi
  8005c0:	56                   	push   %esi
  8005c1:	53                   	push   %ebx
  8005c2:	83 ec 2c             	sub    $0x2c,%esp
  8005c5:	8b 7d 08             	mov    0x8(%ebp),%edi
	binaryname = "ns_output";
  8005c8:	c7 05 00 30 80 00 ca 	movl   $0x8023ca,0x803000
  8005cf:	23 80 00 
	//	- send the packet to the device driver
	int r;
	int perm;
	envid_t sender_envid;
	while(1){
		r = ipc_recv(&sender_envid, (void*)&nsipcbuf, &perm);
  8005d2:	8d 5d e4             	lea    -0x1c(%ebp),%ebx
  8005d5:	8d 75 e0             	lea    -0x20(%ebp),%esi
  8005d8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005dc:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8005e3:	00 
  8005e4:	89 34 24             	mov    %esi,(%esp)
  8005e7:	e8 88 15 00 00       	call   801b74 <ipc_recv>
		if (r < 0 || (uint32_t*)sender_envid == 0){
  8005ec:	85 c0                	test   %eax,%eax
  8005ee:	78 07                	js     8005f7 <output+0x3b>
  8005f0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005f3:	85 d2                	test   %edx,%edx
  8005f5:	75 12                	jne    800609 <output+0x4d>
			cprintf("output: ipc_recv failed, %e", r);
  8005f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005fb:	c7 04 24 d4 23 80 00 	movl   $0x8023d4,(%esp)
  800602:	e8 e5 04 00 00       	call   800aec <cprintf>
			continue;
  800607:	eb cf                	jmp    8005d8 <output+0x1c>
		}

		if (sender_envid != ns_envid) {
  800609:	39 fa                	cmp    %edi,%edx
  80060b:	74 16                	je     800623 <output+0x67>
			cprintf("output: receive from %08x, expect to receive from %08x", sender_envid, ns_envid);
  80060d:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800611:	89 54 24 04          	mov    %edx,0x4(%esp)
  800615:	c7 04 24 0c 24 80 00 	movl   $0x80240c,(%esp)
  80061c:	e8 cb 04 00 00       	call   800aec <cprintf>
			continue;
  800621:	eb b5                	jmp    8005d8 <output+0x1c>
		}
		
		if (!(perm & PTE_P)){
  800623:	f6 45 e4 01          	testb  $0x1,-0x1c(%ebp)
  800627:	75 0e                	jne    800637 <output+0x7b>
			cprintf("output: permission failed");
  800629:	c7 04 24 f0 23 80 00 	movl   $0x8023f0,(%esp)
  800630:	e8 b7 04 00 00       	call   800aec <cprintf>
			continue;
  800635:	eb a1                	jmp    8005d8 <output+0x1c>
		}

		if ((r = sys_e1000_transmit(nsipcbuf.pkt.jp_data, nsipcbuf.pkt.jp_len)) < 0){
  800637:	a1 00 50 80 00       	mov    0x805000,%eax
  80063c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800640:	c7 04 24 04 50 80 00 	movl   $0x805004,(%esp)
  800647:	e8 c4 10 00 00       	call   801710 <sys_e1000_transmit>
  80064c:	85 c0                	test   %eax,%eax
  80064e:	79 88                	jns    8005d8 <output+0x1c>
			cprintf("output: sys_e1000_transmit failed, %e", r);
  800650:	89 44 24 04          	mov    %eax,0x4(%esp)
  800654:	c7 04 24 44 24 80 00 	movl   $0x802444,(%esp)
  80065b:	e8 8c 04 00 00       	call   800aec <cprintf>
  800660:	e9 73 ff ff ff       	jmp    8005d8 <output+0x1c>
  800665:	00 00                	add    %al,(%eax)
	...

00800668 <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  800668:	55                   	push   %ebp
  800669:	89 e5                	mov    %esp,%ebp
  80066b:	57                   	push   %edi
  80066c:	56                   	push   %esi
  80066d:	53                   	push   %ebx
  80066e:	83 ec 1c             	sub    $0x1c,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  800671:	8b 45 08             	mov    0x8(%ebp),%eax
  800674:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  800677:	c6 45 e3 00          	movb   $0x0,-0x1d(%ebp)
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  80067b:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  u8_t *ap;
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  80067e:	c7 45 dc 08 40 80 00 	movl   $0x804008,-0x24(%ebp)
 */
char *
inet_ntoa(struct in_addr addr)
{
  static char str[16];
  u32_t s_addr = addr.s_addr;
  800685:	b2 00                	mov    $0x0,%dl
  800687:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  80068a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80068d:	8a 00                	mov    (%eax),%al
  80068f:	88 45 e2             	mov    %al,-0x1e(%ebp)
      *ap /= (u8_t)10;
  800692:	0f b6 c0             	movzbl %al,%eax
  800695:	8d 34 80             	lea    (%eax,%eax,4),%esi
  800698:	8d 04 f0             	lea    (%eax,%esi,8),%eax
  80069b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80069e:	66 c1 e8 0b          	shr    $0xb,%ax
  8006a2:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8006a5:	88 01                	mov    %al,(%ecx)
      inv[i++] = '0' + rem;
  8006a7:	0f b6 f2             	movzbl %dl,%esi
  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  8006aa:	8d 3c 80             	lea    (%eax,%eax,4),%edi
  8006ad:	d1 e7                	shl    %edi
  8006af:	8a 5d e2             	mov    -0x1e(%ebp),%bl
  8006b2:	89 f9                	mov    %edi,%ecx
  8006b4:	28 cb                	sub    %cl,%bl
  8006b6:	89 df                	mov    %ebx,%edi
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
  8006b8:	8d 4f 30             	lea    0x30(%edi),%ecx
  8006bb:	88 4c 35 ed          	mov    %cl,-0x13(%ebp,%esi,1)
  8006bf:	42                   	inc    %edx
    } while(*ap);
  8006c0:	84 c0                	test   %al,%al
  8006c2:	75 c6                	jne    80068a <inet_ntoa+0x22>
  8006c4:	88 d0                	mov    %dl,%al
  8006c6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006c9:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8006cc:	eb 0b                	jmp    8006d9 <inet_ntoa+0x71>
    while(i--)
  8006ce:	48                   	dec    %eax
      *rp++ = inv[i];
  8006cf:	0f b6 f0             	movzbl %al,%esi
  8006d2:	8a 5c 35 ed          	mov    -0x13(%ebp,%esi,1),%bl
  8006d6:	88 19                	mov    %bl,(%ecx)
  8006d8:	41                   	inc    %ecx
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  8006d9:	84 c0                	test   %al,%al
  8006db:	75 f1                	jne    8006ce <inet_ntoa+0x66>
  8006dd:	89 7d d8             	mov    %edi,-0x28(%ebp)
 * @param addr ip address in network order to convert
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
  8006e0:	0f b6 d2             	movzbl %dl,%edx
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  8006e3:	03 55 dc             	add    -0x24(%ebp),%edx
      *rp++ = inv[i];
    *rp++ = '.';
  8006e6:	c6 02 2e             	movb   $0x2e,(%edx)
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  8006e9:	fe 45 e3             	incb   -0x1d(%ebp)
  8006ec:	80 7d e3 03          	cmpb   $0x3,-0x1d(%ebp)
  8006f0:	77 0b                	ja     8006fd <inet_ntoa+0x95>
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
      *rp++ = inv[i];
    *rp++ = '.';
  8006f2:	42                   	inc    %edx
  8006f3:	89 55 dc             	mov    %edx,-0x24(%ebp)
    ap++;
  8006f6:	ff 45 d8             	incl   -0x28(%ebp)
  8006f9:	88 c2                	mov    %al,%dl
  8006fb:	eb 8d                	jmp    80068a <inet_ntoa+0x22>
  }
  *--rp = 0;
  8006fd:	c6 02 00             	movb   $0x0,(%edx)
  return str;
}
  800700:	b8 08 40 80 00       	mov    $0x804008,%eax
  800705:	83 c4 1c             	add    $0x1c,%esp
  800708:	5b                   	pop    %ebx
  800709:	5e                   	pop    %esi
  80070a:	5f                   	pop    %edi
  80070b:	5d                   	pop    %ebp
  80070c:	c3                   	ret    

0080070d <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  80070d:	55                   	push   %ebp
  80070e:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  800710:	8b 45 08             	mov    0x8(%ebp),%eax
  800713:	66 c1 c0 08          	rol    $0x8,%ax
}
  800717:	5d                   	pop    %ebp
  800718:	c3                   	ret    

00800719 <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  800719:	55                   	push   %ebp
  80071a:	89 e5                	mov    %esp,%ebp
  80071c:	83 ec 04             	sub    $0x4,%esp
  return htons(n);
  80071f:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  800723:	89 04 24             	mov    %eax,(%esp)
  800726:	e8 e2 ff ff ff       	call   80070d <htons>
}
  80072b:	c9                   	leave  
  80072c:	c3                   	ret    

0080072d <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  80072d:	55                   	push   %ebp
  80072e:	89 e5                	mov    %esp,%ebp
  800730:	8b 55 08             	mov    0x8(%ebp),%edx
  return ((n & 0xff) << 24) |
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
  800733:	89 d1                	mov    %edx,%ecx
  800735:	c1 e9 18             	shr    $0x18,%ecx
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  return ((n & 0xff) << 24) |
  800738:	89 d0                	mov    %edx,%eax
  80073a:	c1 e0 18             	shl    $0x18,%eax
  80073d:	09 c8                	or     %ecx,%eax
    ((n & 0xff00) << 8) |
  80073f:	89 d1                	mov    %edx,%ecx
  800741:	81 e1 00 ff 00 00    	and    $0xff00,%ecx
  800747:	c1 e1 08             	shl    $0x8,%ecx
  80074a:	09 c8                	or     %ecx,%eax
    ((n & 0xff0000UL) >> 8) |
  80074c:	81 e2 00 00 ff 00    	and    $0xff0000,%edx
  800752:	c1 ea 08             	shr    $0x8,%edx
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  return ((n & 0xff) << 24) |
  800755:	09 d0                	or     %edx,%eax
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
}
  800757:	5d                   	pop    %ebp
  800758:	c3                   	ret    

00800759 <inet_aton>:
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
{
  800759:	55                   	push   %ebp
  80075a:	89 e5                	mov    %esp,%ebp
  80075c:	57                   	push   %edi
  80075d:	56                   	push   %esi
  80075e:	53                   	push   %ebx
  80075f:	83 ec 24             	sub    $0x24,%esp
  800762:	8b 45 08             	mov    0x8(%ebp),%eax
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;

  c = *cp;
  800765:	0f be 10             	movsbl (%eax),%edx
inet_aton(const char *cp, struct in_addr *addr)
{
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;
  800768:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  80076b:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  80076e:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  800771:	89 5d e0             	mov    %ebx,-0x20(%ebp)
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  800774:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800777:	80 f9 09             	cmp    $0x9,%cl
  80077a:	0f 87 8f 01 00 00    	ja     80090f <inet_aton+0x1b6>
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
  800780:	83 fa 30             	cmp    $0x30,%edx
  800783:	75 28                	jne    8007ad <inet_aton+0x54>
      c = *++cp;
  800785:	0f be 50 01          	movsbl 0x1(%eax),%edx
      if (c == 'x' || c == 'X') {
  800789:	83 fa 78             	cmp    $0x78,%edx
  80078c:	74 0f                	je     80079d <inet_aton+0x44>
  80078e:	83 fa 58             	cmp    $0x58,%edx
  800791:	74 0a                	je     80079d <inet_aton+0x44>
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
  800793:	40                   	inc    %eax
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
      } else
        base = 8;
  800794:	c7 45 dc 08 00 00 00 	movl   $0x8,-0x24(%ebp)
  80079b:	eb 17                	jmp    8007b4 <inet_aton+0x5b>
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
  80079d:	0f be 50 02          	movsbl 0x2(%eax),%edx
  8007a1:	8d 40 02             	lea    0x2(%eax),%eax
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
  8007a4:	c7 45 dc 10 00 00 00 	movl   $0x10,-0x24(%ebp)
        c = *++cp;
  8007ab:	eb 07                	jmp    8007b4 <inet_aton+0x5b>
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
  8007ad:	c7 45 dc 0a 00 00 00 	movl   $0xa,-0x24(%ebp)
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
  8007b4:	40                   	inc    %eax
  8007b5:	be 00 00 00 00       	mov    $0x0,%esi
  8007ba:	eb 01                	jmp    8007bd <inet_aton+0x64>
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
  8007bc:	40                   	inc    %eax
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
  8007bd:	8d 78 ff             	lea    -0x1(%eax),%edi
        c = *++cp;
      } else
        base = 8;
    }
    for (;;) {
      if (isdigit(c)) {
  8007c0:	88 d1                	mov    %dl,%cl
  8007c2:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8007c5:	80 fb 09             	cmp    $0x9,%bl
  8007c8:	77 0d                	ja     8007d7 <inet_aton+0x7e>
        val = (val * base) + (int)(c - '0');
  8007ca:	0f af 75 dc          	imul   -0x24(%ebp),%esi
  8007ce:	8d 74 32 d0          	lea    -0x30(%edx,%esi,1),%esi
        c = *++cp;
  8007d2:	0f be 10             	movsbl (%eax),%edx
  8007d5:	eb e5                	jmp    8007bc <inet_aton+0x63>
      } else if (base == 16 && isxdigit(c)) {
  8007d7:	83 7d dc 10          	cmpl   $0x10,-0x24(%ebp)
  8007db:	75 30                	jne    80080d <inet_aton+0xb4>
  8007dd:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8007e0:	88 5d da             	mov    %bl,-0x26(%ebp)
  8007e3:	80 fb 05             	cmp    $0x5,%bl
  8007e6:	76 08                	jbe    8007f0 <inet_aton+0x97>
  8007e8:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  8007eb:	80 fb 05             	cmp    $0x5,%bl
  8007ee:	77 23                	ja     800813 <inet_aton+0xba>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  8007f0:	89 f1                	mov    %esi,%ecx
  8007f2:	c1 e1 04             	shl    $0x4,%ecx
  8007f5:	8d 72 0a             	lea    0xa(%edx),%esi
  8007f8:	80 7d da 1a          	cmpb   $0x1a,-0x26(%ebp)
  8007fc:	19 d2                	sbb    %edx,%edx
  8007fe:	83 e2 20             	and    $0x20,%edx
  800801:	83 c2 41             	add    $0x41,%edx
  800804:	29 d6                	sub    %edx,%esi
  800806:	09 ce                	or     %ecx,%esi
        c = *++cp;
  800808:	0f be 10             	movsbl (%eax),%edx
  80080b:	eb af                	jmp    8007bc <inet_aton+0x63>
    }
    for (;;) {
      if (isdigit(c)) {
        val = (val * base) + (int)(c - '0');
        c = *++cp;
      } else if (base == 16 && isxdigit(c)) {
  80080d:	89 d0                	mov    %edx,%eax
  80080f:	89 f3                	mov    %esi,%ebx
  800811:	eb 04                	jmp    800817 <inet_aton+0xbe>
  800813:	89 d0                	mov    %edx,%eax
  800815:	89 f3                	mov    %esi,%ebx
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
        c = *++cp;
      } else
        break;
    }
    if (c == '.') {
  800817:	83 f8 2e             	cmp    $0x2e,%eax
  80081a:	75 23                	jne    80083f <inet_aton+0xe6>
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  80081c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80081f:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
  800822:	0f 83 ee 00 00 00    	jae    800916 <inet_aton+0x1bd>
        return (0);
      *pp++ = val;
  800828:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80082b:	89 1a                	mov    %ebx,(%edx)
  80082d:	83 c2 04             	add    $0x4,%edx
  800830:	89 55 d4             	mov    %edx,-0x2c(%ebp)
      c = *++cp;
  800833:	8d 47 01             	lea    0x1(%edi),%eax
  800836:	0f be 57 01          	movsbl 0x1(%edi),%edx
    } else
      break;
  }
  80083a:	e9 35 ff ff ff       	jmp    800774 <inet_aton+0x1b>
  80083f:	89 f3                	mov    %esi,%ebx
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
        c = *++cp;
      } else
        break;
    }
    if (c == '.') {
  800841:	89 f0                	mov    %esi,%eax
      break;
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  800843:	85 d2                	test   %edx,%edx
  800845:	74 33                	je     80087a <inet_aton+0x121>
  800847:	80 f9 1f             	cmp    $0x1f,%cl
  80084a:	0f 86 cd 00 00 00    	jbe    80091d <inet_aton+0x1c4>
  800850:	84 d2                	test   %dl,%dl
  800852:	0f 88 cc 00 00 00    	js     800924 <inet_aton+0x1cb>
  800858:	83 fa 20             	cmp    $0x20,%edx
  80085b:	74 1d                	je     80087a <inet_aton+0x121>
  80085d:	83 fa 0c             	cmp    $0xc,%edx
  800860:	74 18                	je     80087a <inet_aton+0x121>
  800862:	83 fa 0a             	cmp    $0xa,%edx
  800865:	74 13                	je     80087a <inet_aton+0x121>
  800867:	83 fa 0d             	cmp    $0xd,%edx
  80086a:	74 0e                	je     80087a <inet_aton+0x121>
  80086c:	83 fa 09             	cmp    $0x9,%edx
  80086f:	74 09                	je     80087a <inet_aton+0x121>
  800871:	83 fa 0b             	cmp    $0xb,%edx
  800874:	0f 85 b1 00 00 00    	jne    80092b <inet_aton+0x1d2>
    return (0);
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  80087a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80087d:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800880:	29 d1                	sub    %edx,%ecx
  800882:	89 ca                	mov    %ecx,%edx
  800884:	c1 fa 02             	sar    $0x2,%edx
  800887:	42                   	inc    %edx
  switch (n) {
  800888:	83 fa 02             	cmp    $0x2,%edx
  80088b:	74 1b                	je     8008a8 <inet_aton+0x14f>
  80088d:	83 fa 02             	cmp    $0x2,%edx
  800890:	7f 0a                	jg     80089c <inet_aton+0x143>
  800892:	85 d2                	test   %edx,%edx
  800894:	0f 84 98 00 00 00    	je     800932 <inet_aton+0x1d9>
  80089a:	eb 59                	jmp    8008f5 <inet_aton+0x19c>
  80089c:	83 fa 03             	cmp    $0x3,%edx
  80089f:	74 1c                	je     8008bd <inet_aton+0x164>
  8008a1:	83 fa 04             	cmp    $0x4,%edx
  8008a4:	75 4f                	jne    8008f5 <inet_aton+0x19c>
  8008a6:	eb 2e                	jmp    8008d6 <inet_aton+0x17d>

  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
  8008a8:	3d ff ff ff 00       	cmp    $0xffffff,%eax
  8008ad:	0f 87 86 00 00 00    	ja     800939 <inet_aton+0x1e0>
      return (0);
    val |= parts[0] << 24;
  8008b3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8008b6:	c1 e3 18             	shl    $0x18,%ebx
  8008b9:	09 c3                	or     %eax,%ebx
    break;
  8008bb:	eb 38                	jmp    8008f5 <inet_aton+0x19c>

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
  8008bd:	3d ff ff 00 00       	cmp    $0xffff,%eax
  8008c2:	77 7c                	ja     800940 <inet_aton+0x1e7>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
  8008c4:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  8008c7:	c1 e3 10             	shl    $0x10,%ebx
  8008ca:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008cd:	c1 e2 18             	shl    $0x18,%edx
  8008d0:	09 d3                	or     %edx,%ebx
  8008d2:	09 c3                	or     %eax,%ebx
    break;
  8008d4:	eb 1f                	jmp    8008f5 <inet_aton+0x19c>

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
  8008d6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8008db:	77 6a                	ja     800947 <inet_aton+0x1ee>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  8008dd:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  8008e0:	c1 e3 10             	shl    $0x10,%ebx
  8008e3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008e6:	c1 e2 18             	shl    $0x18,%edx
  8008e9:	09 d3                	or     %edx,%ebx
  8008eb:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8008ee:	c1 e2 08             	shl    $0x8,%edx
  8008f1:	09 d3                	or     %edx,%ebx
  8008f3:	09 c3                	or     %eax,%ebx
    break;
  }
  if (addr)
  8008f5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8008f9:	74 53                	je     80094e <inet_aton+0x1f5>
    addr->s_addr = htonl(val);
  8008fb:	89 1c 24             	mov    %ebx,(%esp)
  8008fe:	e8 2a fe ff ff       	call   80072d <htonl>
  800903:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800906:	89 03                	mov    %eax,(%ebx)
  return (1);
  800908:	b8 01 00 00 00       	mov    $0x1,%eax
  80090d:	eb 44                	jmp    800953 <inet_aton+0x1fa>
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
      return (0);
  80090f:	b8 00 00 00 00       	mov    $0x0,%eax
  800914:	eb 3d                	jmp    800953 <inet_aton+0x1fa>
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
        return (0);
  800916:	b8 00 00 00 00       	mov    $0x0,%eax
  80091b:	eb 36                	jmp    800953 <inet_aton+0x1fa>
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
    return (0);
  80091d:	b8 00 00 00 00       	mov    $0x0,%eax
  800922:	eb 2f                	jmp    800953 <inet_aton+0x1fa>
  800924:	b8 00 00 00 00       	mov    $0x0,%eax
  800929:	eb 28                	jmp    800953 <inet_aton+0x1fa>
  80092b:	b8 00 00 00 00       	mov    $0x0,%eax
  800930:	eb 21                	jmp    800953 <inet_aton+0x1fa>
   */
  n = pp - parts + 1;
  switch (n) {

  case 0:
    return (0);       /* initial nondigit */
  800932:	b8 00 00 00 00       	mov    $0x0,%eax
  800937:	eb 1a                	jmp    800953 <inet_aton+0x1fa>
  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
      return (0);
  800939:	b8 00 00 00 00       	mov    $0x0,%eax
  80093e:	eb 13                	jmp    800953 <inet_aton+0x1fa>
    val |= parts[0] << 24;
    break;

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
      return (0);
  800940:	b8 00 00 00 00       	mov    $0x0,%eax
  800945:	eb 0c                	jmp    800953 <inet_aton+0x1fa>
    val |= (parts[0] << 24) | (parts[1] << 16);
    break;

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
      return (0);
  800947:	b8 00 00 00 00       	mov    $0x0,%eax
  80094c:	eb 05                	jmp    800953 <inet_aton+0x1fa>
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
    break;
  }
  if (addr)
    addr->s_addr = htonl(val);
  return (1);
  80094e:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800953:	83 c4 24             	add    $0x24,%esp
  800956:	5b                   	pop    %ebx
  800957:	5e                   	pop    %esi
  800958:	5f                   	pop    %edi
  800959:	5d                   	pop    %ebp
  80095a:	c3                   	ret    

0080095b <inet_addr>:
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @return ip address in network order
 */
u32_t
inet_addr(const char *cp)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	83 ec 18             	sub    $0x18,%esp
  struct in_addr val;

  if (inet_aton(cp, &val)) {
  800961:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800964:	89 44 24 04          	mov    %eax,0x4(%esp)
  800968:	8b 45 08             	mov    0x8(%ebp),%eax
  80096b:	89 04 24             	mov    %eax,(%esp)
  80096e:	e8 e6 fd ff ff       	call   800759 <inet_aton>
  800973:	85 c0                	test   %eax,%eax
  800975:	74 05                	je     80097c <inet_addr+0x21>
    return (val.s_addr);
  800977:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80097a:	eb 05                	jmp    800981 <inet_addr+0x26>
  }
  return (INADDR_NONE);
  80097c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  800981:	c9                   	leave  
  800982:	c3                   	ret    

00800983 <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  800983:	55                   	push   %ebp
  800984:	89 e5                	mov    %esp,%ebp
  800986:	83 ec 04             	sub    $0x4,%esp
  return htonl(n);
  800989:	8b 45 08             	mov    0x8(%ebp),%eax
  80098c:	89 04 24             	mov    %eax,(%esp)
  80098f:	e8 99 fd ff ff       	call   80072d <htonl>
}
  800994:	c9                   	leave  
  800995:	c3                   	ret    
	...

00800998 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800998:	55                   	push   %ebp
  800999:	89 e5                	mov    %esp,%ebp
  80099b:	56                   	push   %esi
  80099c:	53                   	push   %ebx
  80099d:	83 ec 10             	sub    $0x10,%esp
  8009a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8009a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8009a6:	e8 a0 0a 00 00       	call   80144b <sys_getenvid>
  8009ab:	25 ff 03 00 00       	and    $0x3ff,%eax
  8009b0:	c1 e0 07             	shl    $0x7,%eax
  8009b3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8009b8:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8009bd:	85 f6                	test   %esi,%esi
  8009bf:	7e 07                	jle    8009c8 <libmain+0x30>
		binaryname = argv[0];
  8009c1:	8b 03                	mov    (%ebx),%eax
  8009c3:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8009c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009cc:	89 34 24             	mov    %esi,(%esp)
  8009cf:	e8 60 f6 ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8009d4:	e8 07 00 00 00       	call   8009e0 <exit>
}
  8009d9:	83 c4 10             	add    $0x10,%esp
  8009dc:	5b                   	pop    %ebx
  8009dd:	5e                   	pop    %esi
  8009de:	5d                   	pop    %ebp
  8009df:	c3                   	ret    

008009e0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  8009e6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8009ed:	e8 07 0a 00 00       	call   8013f9 <sys_env_destroy>
}
  8009f2:	c9                   	leave  
  8009f3:	c3                   	ret    

008009f4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8009f4:	55                   	push   %ebp
  8009f5:	89 e5                	mov    %esp,%ebp
  8009f7:	56                   	push   %esi
  8009f8:	53                   	push   %ebx
  8009f9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8009fc:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8009ff:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800a05:	e8 41 0a 00 00       	call   80144b <sys_getenvid>
  800a0a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a0d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800a11:	8b 55 08             	mov    0x8(%ebp),%edx
  800a14:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a18:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800a1c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a20:	c7 04 24 74 24 80 00 	movl   $0x802474,(%esp)
  800a27:	e8 c0 00 00 00       	call   800aec <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800a2c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a30:	8b 45 10             	mov    0x10(%ebp),%eax
  800a33:	89 04 24             	mov    %eax,(%esp)
  800a36:	e8 50 00 00 00       	call   800a8b <vcprintf>
	cprintf("\n");
  800a3b:	c7 04 24 fb 22 80 00 	movl   $0x8022fb,(%esp)
  800a42:	e8 a5 00 00 00       	call   800aec <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800a47:	cc                   	int3   
  800a48:	eb fd                	jmp    800a47 <_panic+0x53>
	...

00800a4c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800a4c:	55                   	push   %ebp
  800a4d:	89 e5                	mov    %esp,%ebp
  800a4f:	53                   	push   %ebx
  800a50:	83 ec 14             	sub    $0x14,%esp
  800a53:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800a56:	8b 03                	mov    (%ebx),%eax
  800a58:	8b 55 08             	mov    0x8(%ebp),%edx
  800a5b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800a5f:	40                   	inc    %eax
  800a60:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800a62:	3d ff 00 00 00       	cmp    $0xff,%eax
  800a67:	75 19                	jne    800a82 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800a69:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800a70:	00 
  800a71:	8d 43 08             	lea    0x8(%ebx),%eax
  800a74:	89 04 24             	mov    %eax,(%esp)
  800a77:	e8 40 09 00 00       	call   8013bc <sys_cputs>
		b->idx = 0;
  800a7c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800a82:	ff 43 04             	incl   0x4(%ebx)
}
  800a85:	83 c4 14             	add    $0x14,%esp
  800a88:	5b                   	pop    %ebx
  800a89:	5d                   	pop    %ebp
  800a8a:	c3                   	ret    

00800a8b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800a94:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800a9b:	00 00 00 
	b.cnt = 0;
  800a9e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800aa5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800aa8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800aaf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab2:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ab6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800abc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ac0:	c7 04 24 4c 0a 80 00 	movl   $0x800a4c,(%esp)
  800ac7:	e8 82 01 00 00       	call   800c4e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800acc:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800ad2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ad6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800adc:	89 04 24             	mov    %eax,(%esp)
  800adf:	e8 d8 08 00 00       	call   8013bc <sys_cputs>

	return b.cnt;
}
  800ae4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800aea:	c9                   	leave  
  800aeb:	c3                   	ret    

00800aec <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800aec:	55                   	push   %ebp
  800aed:	89 e5                	mov    %esp,%ebp
  800aef:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800af2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800af5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800af9:	8b 45 08             	mov    0x8(%ebp),%eax
  800afc:	89 04 24             	mov    %eax,(%esp)
  800aff:	e8 87 ff ff ff       	call   800a8b <vcprintf>
	va_end(ap);

	return cnt;
}
  800b04:	c9                   	leave  
  800b05:	c3                   	ret    
	...

00800b08 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800b08:	55                   	push   %ebp
  800b09:	89 e5                	mov    %esp,%ebp
  800b0b:	57                   	push   %edi
  800b0c:	56                   	push   %esi
  800b0d:	53                   	push   %ebx
  800b0e:	83 ec 3c             	sub    $0x3c,%esp
  800b11:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b14:	89 d7                	mov    %edx,%edi
  800b16:	8b 45 08             	mov    0x8(%ebp),%eax
  800b19:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800b1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b1f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b22:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800b25:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800b28:	85 c0                	test   %eax,%eax
  800b2a:	75 08                	jne    800b34 <printnum+0x2c>
  800b2c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800b2f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800b32:	77 57                	ja     800b8b <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800b34:	89 74 24 10          	mov    %esi,0x10(%esp)
  800b38:	4b                   	dec    %ebx
  800b39:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800b3d:	8b 45 10             	mov    0x10(%ebp),%eax
  800b40:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b44:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800b48:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800b4c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800b53:	00 
  800b54:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800b57:	89 04 24             	mov    %eax,(%esp)
  800b5a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800b5d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b61:	e8 6e 14 00 00       	call   801fd4 <__udivdi3>
  800b66:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800b6a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800b6e:	89 04 24             	mov    %eax,(%esp)
  800b71:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b75:	89 fa                	mov    %edi,%edx
  800b77:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800b7a:	e8 89 ff ff ff       	call   800b08 <printnum>
  800b7f:	eb 0f                	jmp    800b90 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800b81:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b85:	89 34 24             	mov    %esi,(%esp)
  800b88:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800b8b:	4b                   	dec    %ebx
  800b8c:	85 db                	test   %ebx,%ebx
  800b8e:	7f f1                	jg     800b81 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800b90:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b94:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800b98:	8b 45 10             	mov    0x10(%ebp),%eax
  800b9b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b9f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ba6:	00 
  800ba7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800baa:	89 04 24             	mov    %eax,(%esp)
  800bad:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800bb0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bb4:	e8 3b 15 00 00       	call   8020f4 <__umoddi3>
  800bb9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bbd:	0f be 80 97 24 80 00 	movsbl 0x802497(%eax),%eax
  800bc4:	89 04 24             	mov    %eax,(%esp)
  800bc7:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800bca:	83 c4 3c             	add    $0x3c,%esp
  800bcd:	5b                   	pop    %ebx
  800bce:	5e                   	pop    %esi
  800bcf:	5f                   	pop    %edi
  800bd0:	5d                   	pop    %ebp
  800bd1:	c3                   	ret    

00800bd2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800bd2:	55                   	push   %ebp
  800bd3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800bd5:	83 fa 01             	cmp    $0x1,%edx
  800bd8:	7e 0e                	jle    800be8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800bda:	8b 10                	mov    (%eax),%edx
  800bdc:	8d 4a 08             	lea    0x8(%edx),%ecx
  800bdf:	89 08                	mov    %ecx,(%eax)
  800be1:	8b 02                	mov    (%edx),%eax
  800be3:	8b 52 04             	mov    0x4(%edx),%edx
  800be6:	eb 22                	jmp    800c0a <getuint+0x38>
	else if (lflag)
  800be8:	85 d2                	test   %edx,%edx
  800bea:	74 10                	je     800bfc <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800bec:	8b 10                	mov    (%eax),%edx
  800bee:	8d 4a 04             	lea    0x4(%edx),%ecx
  800bf1:	89 08                	mov    %ecx,(%eax)
  800bf3:	8b 02                	mov    (%edx),%eax
  800bf5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bfa:	eb 0e                	jmp    800c0a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800bfc:	8b 10                	mov    (%eax),%edx
  800bfe:	8d 4a 04             	lea    0x4(%edx),%ecx
  800c01:	89 08                	mov    %ecx,(%eax)
  800c03:	8b 02                	mov    (%edx),%eax
  800c05:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800c0a:	5d                   	pop    %ebp
  800c0b:	c3                   	ret    

00800c0c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800c0c:	55                   	push   %ebp
  800c0d:	89 e5                	mov    %esp,%ebp
  800c0f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800c12:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800c15:	8b 10                	mov    (%eax),%edx
  800c17:	3b 50 04             	cmp    0x4(%eax),%edx
  800c1a:	73 08                	jae    800c24 <sprintputch+0x18>
		*b->buf++ = ch;
  800c1c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c1f:	88 0a                	mov    %cl,(%edx)
  800c21:	42                   	inc    %edx
  800c22:	89 10                	mov    %edx,(%eax)
}
  800c24:	5d                   	pop    %ebp
  800c25:	c3                   	ret    

00800c26 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800c2c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800c2f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c33:	8b 45 10             	mov    0x10(%ebp),%eax
  800c36:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c3d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c41:	8b 45 08             	mov    0x8(%ebp),%eax
  800c44:	89 04 24             	mov    %eax,(%esp)
  800c47:	e8 02 00 00 00       	call   800c4e <vprintfmt>
	va_end(ap);
}
  800c4c:	c9                   	leave  
  800c4d:	c3                   	ret    

00800c4e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800c4e:	55                   	push   %ebp
  800c4f:	89 e5                	mov    %esp,%ebp
  800c51:	57                   	push   %edi
  800c52:	56                   	push   %esi
  800c53:	53                   	push   %ebx
  800c54:	83 ec 4c             	sub    $0x4c,%esp
  800c57:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c5a:	8b 75 10             	mov    0x10(%ebp),%esi
  800c5d:	eb 12                	jmp    800c71 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800c5f:	85 c0                	test   %eax,%eax
  800c61:	0f 84 6b 03 00 00    	je     800fd2 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800c67:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c6b:	89 04 24             	mov    %eax,(%esp)
  800c6e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800c71:	0f b6 06             	movzbl (%esi),%eax
  800c74:	46                   	inc    %esi
  800c75:	83 f8 25             	cmp    $0x25,%eax
  800c78:	75 e5                	jne    800c5f <vprintfmt+0x11>
  800c7a:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800c7e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800c85:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800c8a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800c91:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c96:	eb 26                	jmp    800cbe <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c98:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800c9b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800c9f:	eb 1d                	jmp    800cbe <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ca1:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800ca4:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800ca8:	eb 14                	jmp    800cbe <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800caa:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800cad:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800cb4:	eb 08                	jmp    800cbe <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800cb6:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800cb9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cbe:	0f b6 06             	movzbl (%esi),%eax
  800cc1:	8d 56 01             	lea    0x1(%esi),%edx
  800cc4:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800cc7:	8a 16                	mov    (%esi),%dl
  800cc9:	83 ea 23             	sub    $0x23,%edx
  800ccc:	80 fa 55             	cmp    $0x55,%dl
  800ccf:	0f 87 e1 02 00 00    	ja     800fb6 <vprintfmt+0x368>
  800cd5:	0f b6 d2             	movzbl %dl,%edx
  800cd8:	ff 24 95 e0 25 80 00 	jmp    *0x8025e0(,%edx,4)
  800cdf:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800ce2:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800ce7:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800cea:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800cee:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800cf1:	8d 50 d0             	lea    -0x30(%eax),%edx
  800cf4:	83 fa 09             	cmp    $0x9,%edx
  800cf7:	77 2a                	ja     800d23 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800cf9:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800cfa:	eb eb                	jmp    800ce7 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800cfc:	8b 45 14             	mov    0x14(%ebp),%eax
  800cff:	8d 50 04             	lea    0x4(%eax),%edx
  800d02:	89 55 14             	mov    %edx,0x14(%ebp)
  800d05:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d07:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800d0a:	eb 17                	jmp    800d23 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800d0c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800d10:	78 98                	js     800caa <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d12:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800d15:	eb a7                	jmp    800cbe <vprintfmt+0x70>
  800d17:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800d1a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800d21:	eb 9b                	jmp    800cbe <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800d23:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800d27:	79 95                	jns    800cbe <vprintfmt+0x70>
  800d29:	eb 8b                	jmp    800cb6 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800d2b:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d2c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800d2f:	eb 8d                	jmp    800cbe <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800d31:	8b 45 14             	mov    0x14(%ebp),%eax
  800d34:	8d 50 04             	lea    0x4(%eax),%edx
  800d37:	89 55 14             	mov    %edx,0x14(%ebp)
  800d3a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d3e:	8b 00                	mov    (%eax),%eax
  800d40:	89 04 24             	mov    %eax,(%esp)
  800d43:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d46:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800d49:	e9 23 ff ff ff       	jmp    800c71 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800d4e:	8b 45 14             	mov    0x14(%ebp),%eax
  800d51:	8d 50 04             	lea    0x4(%eax),%edx
  800d54:	89 55 14             	mov    %edx,0x14(%ebp)
  800d57:	8b 00                	mov    (%eax),%eax
  800d59:	85 c0                	test   %eax,%eax
  800d5b:	79 02                	jns    800d5f <vprintfmt+0x111>
  800d5d:	f7 d8                	neg    %eax
  800d5f:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800d61:	83 f8 11             	cmp    $0x11,%eax
  800d64:	7f 0b                	jg     800d71 <vprintfmt+0x123>
  800d66:	8b 04 85 40 27 80 00 	mov    0x802740(,%eax,4),%eax
  800d6d:	85 c0                	test   %eax,%eax
  800d6f:	75 23                	jne    800d94 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800d71:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800d75:	c7 44 24 08 af 24 80 	movl   $0x8024af,0x8(%esp)
  800d7c:	00 
  800d7d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d81:	8b 45 08             	mov    0x8(%ebp),%eax
  800d84:	89 04 24             	mov    %eax,(%esp)
  800d87:	e8 9a fe ff ff       	call   800c26 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d8c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800d8f:	e9 dd fe ff ff       	jmp    800c71 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800d94:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d98:	c7 44 24 08 1d 29 80 	movl   $0x80291d,0x8(%esp)
  800d9f:	00 
  800da0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800da4:	8b 55 08             	mov    0x8(%ebp),%edx
  800da7:	89 14 24             	mov    %edx,(%esp)
  800daa:	e8 77 fe ff ff       	call   800c26 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800daf:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800db2:	e9 ba fe ff ff       	jmp    800c71 <vprintfmt+0x23>
  800db7:	89 f9                	mov    %edi,%ecx
  800db9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800dbc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800dbf:	8b 45 14             	mov    0x14(%ebp),%eax
  800dc2:	8d 50 04             	lea    0x4(%eax),%edx
  800dc5:	89 55 14             	mov    %edx,0x14(%ebp)
  800dc8:	8b 30                	mov    (%eax),%esi
  800dca:	85 f6                	test   %esi,%esi
  800dcc:	75 05                	jne    800dd3 <vprintfmt+0x185>
				p = "(null)";
  800dce:	be a8 24 80 00       	mov    $0x8024a8,%esi
			if (width > 0 && padc != '-')
  800dd3:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800dd7:	0f 8e 84 00 00 00    	jle    800e61 <vprintfmt+0x213>
  800ddd:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800de1:	74 7e                	je     800e61 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800de3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800de7:	89 34 24             	mov    %esi,(%esp)
  800dea:	e8 8b 02 00 00       	call   80107a <strnlen>
  800def:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800df2:	29 c2                	sub    %eax,%edx
  800df4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800df7:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800dfb:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800dfe:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800e01:	89 de                	mov    %ebx,%esi
  800e03:	89 d3                	mov    %edx,%ebx
  800e05:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800e07:	eb 0b                	jmp    800e14 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800e09:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e0d:	89 3c 24             	mov    %edi,(%esp)
  800e10:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800e13:	4b                   	dec    %ebx
  800e14:	85 db                	test   %ebx,%ebx
  800e16:	7f f1                	jg     800e09 <vprintfmt+0x1bb>
  800e18:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800e1b:	89 f3                	mov    %esi,%ebx
  800e1d:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800e20:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e23:	85 c0                	test   %eax,%eax
  800e25:	79 05                	jns    800e2c <vprintfmt+0x1de>
  800e27:	b8 00 00 00 00       	mov    $0x0,%eax
  800e2c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800e2f:	29 c2                	sub    %eax,%edx
  800e31:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800e34:	eb 2b                	jmp    800e61 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800e36:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800e3a:	74 18                	je     800e54 <vprintfmt+0x206>
  800e3c:	8d 50 e0             	lea    -0x20(%eax),%edx
  800e3f:	83 fa 5e             	cmp    $0x5e,%edx
  800e42:	76 10                	jbe    800e54 <vprintfmt+0x206>
					putch('?', putdat);
  800e44:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e48:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800e4f:	ff 55 08             	call   *0x8(%ebp)
  800e52:	eb 0a                	jmp    800e5e <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800e54:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e58:	89 04 24             	mov    %eax,(%esp)
  800e5b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e5e:	ff 4d e4             	decl   -0x1c(%ebp)
  800e61:	0f be 06             	movsbl (%esi),%eax
  800e64:	46                   	inc    %esi
  800e65:	85 c0                	test   %eax,%eax
  800e67:	74 21                	je     800e8a <vprintfmt+0x23c>
  800e69:	85 ff                	test   %edi,%edi
  800e6b:	78 c9                	js     800e36 <vprintfmt+0x1e8>
  800e6d:	4f                   	dec    %edi
  800e6e:	79 c6                	jns    800e36 <vprintfmt+0x1e8>
  800e70:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e73:	89 de                	mov    %ebx,%esi
  800e75:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800e78:	eb 18                	jmp    800e92 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800e7a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e7e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800e85:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800e87:	4b                   	dec    %ebx
  800e88:	eb 08                	jmp    800e92 <vprintfmt+0x244>
  800e8a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e8d:	89 de                	mov    %ebx,%esi
  800e8f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800e92:	85 db                	test   %ebx,%ebx
  800e94:	7f e4                	jg     800e7a <vprintfmt+0x22c>
  800e96:	89 7d 08             	mov    %edi,0x8(%ebp)
  800e99:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800e9b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800e9e:	e9 ce fd ff ff       	jmp    800c71 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800ea3:	83 f9 01             	cmp    $0x1,%ecx
  800ea6:	7e 10                	jle    800eb8 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800ea8:	8b 45 14             	mov    0x14(%ebp),%eax
  800eab:	8d 50 08             	lea    0x8(%eax),%edx
  800eae:	89 55 14             	mov    %edx,0x14(%ebp)
  800eb1:	8b 30                	mov    (%eax),%esi
  800eb3:	8b 78 04             	mov    0x4(%eax),%edi
  800eb6:	eb 26                	jmp    800ede <vprintfmt+0x290>
	else if (lflag)
  800eb8:	85 c9                	test   %ecx,%ecx
  800eba:	74 12                	je     800ece <vprintfmt+0x280>
		return va_arg(*ap, long);
  800ebc:	8b 45 14             	mov    0x14(%ebp),%eax
  800ebf:	8d 50 04             	lea    0x4(%eax),%edx
  800ec2:	89 55 14             	mov    %edx,0x14(%ebp)
  800ec5:	8b 30                	mov    (%eax),%esi
  800ec7:	89 f7                	mov    %esi,%edi
  800ec9:	c1 ff 1f             	sar    $0x1f,%edi
  800ecc:	eb 10                	jmp    800ede <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800ece:	8b 45 14             	mov    0x14(%ebp),%eax
  800ed1:	8d 50 04             	lea    0x4(%eax),%edx
  800ed4:	89 55 14             	mov    %edx,0x14(%ebp)
  800ed7:	8b 30                	mov    (%eax),%esi
  800ed9:	89 f7                	mov    %esi,%edi
  800edb:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800ede:	85 ff                	test   %edi,%edi
  800ee0:	78 0a                	js     800eec <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800ee2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ee7:	e9 8c 00 00 00       	jmp    800f78 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800eec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ef0:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800ef7:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800efa:	f7 de                	neg    %esi
  800efc:	83 d7 00             	adc    $0x0,%edi
  800eff:	f7 df                	neg    %edi
			}
			base = 10;
  800f01:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f06:	eb 70                	jmp    800f78 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800f08:	89 ca                	mov    %ecx,%edx
  800f0a:	8d 45 14             	lea    0x14(%ebp),%eax
  800f0d:	e8 c0 fc ff ff       	call   800bd2 <getuint>
  800f12:	89 c6                	mov    %eax,%esi
  800f14:	89 d7                	mov    %edx,%edi
			base = 10;
  800f16:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800f1b:	eb 5b                	jmp    800f78 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  800f1d:	89 ca                	mov    %ecx,%edx
  800f1f:	8d 45 14             	lea    0x14(%ebp),%eax
  800f22:	e8 ab fc ff ff       	call   800bd2 <getuint>
  800f27:	89 c6                	mov    %eax,%esi
  800f29:	89 d7                	mov    %edx,%edi
			base = 8;
  800f2b:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800f30:	eb 46                	jmp    800f78 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  800f32:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f36:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800f3d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800f40:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f44:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800f4b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800f4e:	8b 45 14             	mov    0x14(%ebp),%eax
  800f51:	8d 50 04             	lea    0x4(%eax),%edx
  800f54:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800f57:	8b 30                	mov    (%eax),%esi
  800f59:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800f5e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800f63:	eb 13                	jmp    800f78 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800f65:	89 ca                	mov    %ecx,%edx
  800f67:	8d 45 14             	lea    0x14(%ebp),%eax
  800f6a:	e8 63 fc ff ff       	call   800bd2 <getuint>
  800f6f:	89 c6                	mov    %eax,%esi
  800f71:	89 d7                	mov    %edx,%edi
			base = 16;
  800f73:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800f78:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800f7c:	89 54 24 10          	mov    %edx,0x10(%esp)
  800f80:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800f83:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f87:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f8b:	89 34 24             	mov    %esi,(%esp)
  800f8e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800f92:	89 da                	mov    %ebx,%edx
  800f94:	8b 45 08             	mov    0x8(%ebp),%eax
  800f97:	e8 6c fb ff ff       	call   800b08 <printnum>
			break;
  800f9c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800f9f:	e9 cd fc ff ff       	jmp    800c71 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800fa4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800fa8:	89 04 24             	mov    %eax,(%esp)
  800fab:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800fae:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800fb1:	e9 bb fc ff ff       	jmp    800c71 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800fb6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800fba:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800fc1:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800fc4:	eb 01                	jmp    800fc7 <vprintfmt+0x379>
  800fc6:	4e                   	dec    %esi
  800fc7:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800fcb:	75 f9                	jne    800fc6 <vprintfmt+0x378>
  800fcd:	e9 9f fc ff ff       	jmp    800c71 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800fd2:	83 c4 4c             	add    $0x4c,%esp
  800fd5:	5b                   	pop    %ebx
  800fd6:	5e                   	pop    %esi
  800fd7:	5f                   	pop    %edi
  800fd8:	5d                   	pop    %ebp
  800fd9:	c3                   	ret    

00800fda <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800fda:	55                   	push   %ebp
  800fdb:	89 e5                	mov    %esp,%ebp
  800fdd:	83 ec 28             	sub    $0x28,%esp
  800fe0:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800fe6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800fe9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800fed:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ff0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800ff7:	85 c0                	test   %eax,%eax
  800ff9:	74 30                	je     80102b <vsnprintf+0x51>
  800ffb:	85 d2                	test   %edx,%edx
  800ffd:	7e 33                	jle    801032 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800fff:	8b 45 14             	mov    0x14(%ebp),%eax
  801002:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801006:	8b 45 10             	mov    0x10(%ebp),%eax
  801009:	89 44 24 08          	mov    %eax,0x8(%esp)
  80100d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801010:	89 44 24 04          	mov    %eax,0x4(%esp)
  801014:	c7 04 24 0c 0c 80 00 	movl   $0x800c0c,(%esp)
  80101b:	e8 2e fc ff ff       	call   800c4e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801020:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801023:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801026:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801029:	eb 0c                	jmp    801037 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80102b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801030:	eb 05                	jmp    801037 <vsnprintf+0x5d>
  801032:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801037:	c9                   	leave  
  801038:	c3                   	ret    

00801039 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801039:	55                   	push   %ebp
  80103a:	89 e5                	mov    %esp,%ebp
  80103c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80103f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801042:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801046:	8b 45 10             	mov    0x10(%ebp),%eax
  801049:	89 44 24 08          	mov    %eax,0x8(%esp)
  80104d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801050:	89 44 24 04          	mov    %eax,0x4(%esp)
  801054:	8b 45 08             	mov    0x8(%ebp),%eax
  801057:	89 04 24             	mov    %eax,(%esp)
  80105a:	e8 7b ff ff ff       	call   800fda <vsnprintf>
	va_end(ap);

	return rc;
}
  80105f:	c9                   	leave  
  801060:	c3                   	ret    
  801061:	00 00                	add    %al,(%eax)
	...

00801064 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801064:	55                   	push   %ebp
  801065:	89 e5                	mov    %esp,%ebp
  801067:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80106a:	b8 00 00 00 00       	mov    $0x0,%eax
  80106f:	eb 01                	jmp    801072 <strlen+0xe>
		n++;
  801071:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801072:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801076:	75 f9                	jne    801071 <strlen+0xd>
		n++;
	return n;
}
  801078:	5d                   	pop    %ebp
  801079:	c3                   	ret    

0080107a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80107a:	55                   	push   %ebp
  80107b:	89 e5                	mov    %esp,%ebp
  80107d:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  801080:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801083:	b8 00 00 00 00       	mov    $0x0,%eax
  801088:	eb 01                	jmp    80108b <strnlen+0x11>
		n++;
  80108a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80108b:	39 d0                	cmp    %edx,%eax
  80108d:	74 06                	je     801095 <strnlen+0x1b>
  80108f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801093:	75 f5                	jne    80108a <strnlen+0x10>
		n++;
	return n;
}
  801095:	5d                   	pop    %ebp
  801096:	c3                   	ret    

00801097 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801097:	55                   	push   %ebp
  801098:	89 e5                	mov    %esp,%ebp
  80109a:	53                   	push   %ebx
  80109b:	8b 45 08             	mov    0x8(%ebp),%eax
  80109e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8010a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8010a6:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8010a9:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8010ac:	42                   	inc    %edx
  8010ad:	84 c9                	test   %cl,%cl
  8010af:	75 f5                	jne    8010a6 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8010b1:	5b                   	pop    %ebx
  8010b2:	5d                   	pop    %ebp
  8010b3:	c3                   	ret    

008010b4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8010b4:	55                   	push   %ebp
  8010b5:	89 e5                	mov    %esp,%ebp
  8010b7:	53                   	push   %ebx
  8010b8:	83 ec 08             	sub    $0x8,%esp
  8010bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8010be:	89 1c 24             	mov    %ebx,(%esp)
  8010c1:	e8 9e ff ff ff       	call   801064 <strlen>
	strcpy(dst + len, src);
  8010c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010c9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8010cd:	01 d8                	add    %ebx,%eax
  8010cf:	89 04 24             	mov    %eax,(%esp)
  8010d2:	e8 c0 ff ff ff       	call   801097 <strcpy>
	return dst;
}
  8010d7:	89 d8                	mov    %ebx,%eax
  8010d9:	83 c4 08             	add    $0x8,%esp
  8010dc:	5b                   	pop    %ebx
  8010dd:	5d                   	pop    %ebp
  8010de:	c3                   	ret    

008010df <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8010df:	55                   	push   %ebp
  8010e0:	89 e5                	mov    %esp,%ebp
  8010e2:	56                   	push   %esi
  8010e3:	53                   	push   %ebx
  8010e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010ea:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8010ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010f2:	eb 0c                	jmp    801100 <strncpy+0x21>
		*dst++ = *src;
  8010f4:	8a 1a                	mov    (%edx),%bl
  8010f6:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8010f9:	80 3a 01             	cmpb   $0x1,(%edx)
  8010fc:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8010ff:	41                   	inc    %ecx
  801100:	39 f1                	cmp    %esi,%ecx
  801102:	75 f0                	jne    8010f4 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801104:	5b                   	pop    %ebx
  801105:	5e                   	pop    %esi
  801106:	5d                   	pop    %ebp
  801107:	c3                   	ret    

00801108 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801108:	55                   	push   %ebp
  801109:	89 e5                	mov    %esp,%ebp
  80110b:	56                   	push   %esi
  80110c:	53                   	push   %ebx
  80110d:	8b 75 08             	mov    0x8(%ebp),%esi
  801110:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801113:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801116:	85 d2                	test   %edx,%edx
  801118:	75 0a                	jne    801124 <strlcpy+0x1c>
  80111a:	89 f0                	mov    %esi,%eax
  80111c:	eb 1a                	jmp    801138 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80111e:	88 18                	mov    %bl,(%eax)
  801120:	40                   	inc    %eax
  801121:	41                   	inc    %ecx
  801122:	eb 02                	jmp    801126 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801124:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  801126:	4a                   	dec    %edx
  801127:	74 0a                	je     801133 <strlcpy+0x2b>
  801129:	8a 19                	mov    (%ecx),%bl
  80112b:	84 db                	test   %bl,%bl
  80112d:	75 ef                	jne    80111e <strlcpy+0x16>
  80112f:	89 c2                	mov    %eax,%edx
  801131:	eb 02                	jmp    801135 <strlcpy+0x2d>
  801133:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  801135:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  801138:	29 f0                	sub    %esi,%eax
}
  80113a:	5b                   	pop    %ebx
  80113b:	5e                   	pop    %esi
  80113c:	5d                   	pop    %ebp
  80113d:	c3                   	ret    

0080113e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80113e:	55                   	push   %ebp
  80113f:	89 e5                	mov    %esp,%ebp
  801141:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801144:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801147:	eb 02                	jmp    80114b <strcmp+0xd>
		p++, q++;
  801149:	41                   	inc    %ecx
  80114a:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80114b:	8a 01                	mov    (%ecx),%al
  80114d:	84 c0                	test   %al,%al
  80114f:	74 04                	je     801155 <strcmp+0x17>
  801151:	3a 02                	cmp    (%edx),%al
  801153:	74 f4                	je     801149 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801155:	0f b6 c0             	movzbl %al,%eax
  801158:	0f b6 12             	movzbl (%edx),%edx
  80115b:	29 d0                	sub    %edx,%eax
}
  80115d:	5d                   	pop    %ebp
  80115e:	c3                   	ret    

0080115f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80115f:	55                   	push   %ebp
  801160:	89 e5                	mov    %esp,%ebp
  801162:	53                   	push   %ebx
  801163:	8b 45 08             	mov    0x8(%ebp),%eax
  801166:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801169:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  80116c:	eb 03                	jmp    801171 <strncmp+0x12>
		n--, p++, q++;
  80116e:	4a                   	dec    %edx
  80116f:	40                   	inc    %eax
  801170:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801171:	85 d2                	test   %edx,%edx
  801173:	74 14                	je     801189 <strncmp+0x2a>
  801175:	8a 18                	mov    (%eax),%bl
  801177:	84 db                	test   %bl,%bl
  801179:	74 04                	je     80117f <strncmp+0x20>
  80117b:	3a 19                	cmp    (%ecx),%bl
  80117d:	74 ef                	je     80116e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80117f:	0f b6 00             	movzbl (%eax),%eax
  801182:	0f b6 11             	movzbl (%ecx),%edx
  801185:	29 d0                	sub    %edx,%eax
  801187:	eb 05                	jmp    80118e <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801189:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80118e:	5b                   	pop    %ebx
  80118f:	5d                   	pop    %ebp
  801190:	c3                   	ret    

00801191 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801191:	55                   	push   %ebp
  801192:	89 e5                	mov    %esp,%ebp
  801194:	8b 45 08             	mov    0x8(%ebp),%eax
  801197:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80119a:	eb 05                	jmp    8011a1 <strchr+0x10>
		if (*s == c)
  80119c:	38 ca                	cmp    %cl,%dl
  80119e:	74 0c                	je     8011ac <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8011a0:	40                   	inc    %eax
  8011a1:	8a 10                	mov    (%eax),%dl
  8011a3:	84 d2                	test   %dl,%dl
  8011a5:	75 f5                	jne    80119c <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8011a7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011ac:	5d                   	pop    %ebp
  8011ad:	c3                   	ret    

008011ae <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8011ae:	55                   	push   %ebp
  8011af:	89 e5                	mov    %esp,%ebp
  8011b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b4:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8011b7:	eb 05                	jmp    8011be <strfind+0x10>
		if (*s == c)
  8011b9:	38 ca                	cmp    %cl,%dl
  8011bb:	74 07                	je     8011c4 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8011bd:	40                   	inc    %eax
  8011be:	8a 10                	mov    (%eax),%dl
  8011c0:	84 d2                	test   %dl,%dl
  8011c2:	75 f5                	jne    8011b9 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8011c4:	5d                   	pop    %ebp
  8011c5:	c3                   	ret    

008011c6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8011c6:	55                   	push   %ebp
  8011c7:	89 e5                	mov    %esp,%ebp
  8011c9:	57                   	push   %edi
  8011ca:	56                   	push   %esi
  8011cb:	53                   	push   %ebx
  8011cc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011d2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8011d5:	85 c9                	test   %ecx,%ecx
  8011d7:	74 30                	je     801209 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8011d9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8011df:	75 25                	jne    801206 <memset+0x40>
  8011e1:	f6 c1 03             	test   $0x3,%cl
  8011e4:	75 20                	jne    801206 <memset+0x40>
		c &= 0xFF;
  8011e6:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8011e9:	89 d3                	mov    %edx,%ebx
  8011eb:	c1 e3 08             	shl    $0x8,%ebx
  8011ee:	89 d6                	mov    %edx,%esi
  8011f0:	c1 e6 18             	shl    $0x18,%esi
  8011f3:	89 d0                	mov    %edx,%eax
  8011f5:	c1 e0 10             	shl    $0x10,%eax
  8011f8:	09 f0                	or     %esi,%eax
  8011fa:	09 d0                	or     %edx,%eax
  8011fc:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8011fe:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801201:	fc                   	cld    
  801202:	f3 ab                	rep stos %eax,%es:(%edi)
  801204:	eb 03                	jmp    801209 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801206:	fc                   	cld    
  801207:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801209:	89 f8                	mov    %edi,%eax
  80120b:	5b                   	pop    %ebx
  80120c:	5e                   	pop    %esi
  80120d:	5f                   	pop    %edi
  80120e:	5d                   	pop    %ebp
  80120f:	c3                   	ret    

00801210 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801210:	55                   	push   %ebp
  801211:	89 e5                	mov    %esp,%ebp
  801213:	57                   	push   %edi
  801214:	56                   	push   %esi
  801215:	8b 45 08             	mov    0x8(%ebp),%eax
  801218:	8b 75 0c             	mov    0xc(%ebp),%esi
  80121b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80121e:	39 c6                	cmp    %eax,%esi
  801220:	73 34                	jae    801256 <memmove+0x46>
  801222:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801225:	39 d0                	cmp    %edx,%eax
  801227:	73 2d                	jae    801256 <memmove+0x46>
		s += n;
		d += n;
  801229:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80122c:	f6 c2 03             	test   $0x3,%dl
  80122f:	75 1b                	jne    80124c <memmove+0x3c>
  801231:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801237:	75 13                	jne    80124c <memmove+0x3c>
  801239:	f6 c1 03             	test   $0x3,%cl
  80123c:	75 0e                	jne    80124c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80123e:	83 ef 04             	sub    $0x4,%edi
  801241:	8d 72 fc             	lea    -0x4(%edx),%esi
  801244:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801247:	fd                   	std    
  801248:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80124a:	eb 07                	jmp    801253 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80124c:	4f                   	dec    %edi
  80124d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801250:	fd                   	std    
  801251:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801253:	fc                   	cld    
  801254:	eb 20                	jmp    801276 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801256:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80125c:	75 13                	jne    801271 <memmove+0x61>
  80125e:	a8 03                	test   $0x3,%al
  801260:	75 0f                	jne    801271 <memmove+0x61>
  801262:	f6 c1 03             	test   $0x3,%cl
  801265:	75 0a                	jne    801271 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801267:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80126a:	89 c7                	mov    %eax,%edi
  80126c:	fc                   	cld    
  80126d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80126f:	eb 05                	jmp    801276 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801271:	89 c7                	mov    %eax,%edi
  801273:	fc                   	cld    
  801274:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801276:	5e                   	pop    %esi
  801277:	5f                   	pop    %edi
  801278:	5d                   	pop    %ebp
  801279:	c3                   	ret    

0080127a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80127a:	55                   	push   %ebp
  80127b:	89 e5                	mov    %esp,%ebp
  80127d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801280:	8b 45 10             	mov    0x10(%ebp),%eax
  801283:	89 44 24 08          	mov    %eax,0x8(%esp)
  801287:	8b 45 0c             	mov    0xc(%ebp),%eax
  80128a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80128e:	8b 45 08             	mov    0x8(%ebp),%eax
  801291:	89 04 24             	mov    %eax,(%esp)
  801294:	e8 77 ff ff ff       	call   801210 <memmove>
}
  801299:	c9                   	leave  
  80129a:	c3                   	ret    

0080129b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80129b:	55                   	push   %ebp
  80129c:	89 e5                	mov    %esp,%ebp
  80129e:	57                   	push   %edi
  80129f:	56                   	push   %esi
  8012a0:	53                   	push   %ebx
  8012a1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012a4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012a7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8012aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8012af:	eb 16                	jmp    8012c7 <memcmp+0x2c>
		if (*s1 != *s2)
  8012b1:	8a 04 17             	mov    (%edi,%edx,1),%al
  8012b4:	42                   	inc    %edx
  8012b5:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8012b9:	38 c8                	cmp    %cl,%al
  8012bb:	74 0a                	je     8012c7 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8012bd:	0f b6 c0             	movzbl %al,%eax
  8012c0:	0f b6 c9             	movzbl %cl,%ecx
  8012c3:	29 c8                	sub    %ecx,%eax
  8012c5:	eb 09                	jmp    8012d0 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8012c7:	39 da                	cmp    %ebx,%edx
  8012c9:	75 e6                	jne    8012b1 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8012cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012d0:	5b                   	pop    %ebx
  8012d1:	5e                   	pop    %esi
  8012d2:	5f                   	pop    %edi
  8012d3:	5d                   	pop    %ebp
  8012d4:	c3                   	ret    

008012d5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8012d5:	55                   	push   %ebp
  8012d6:	89 e5                	mov    %esp,%ebp
  8012d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8012db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8012de:	89 c2                	mov    %eax,%edx
  8012e0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8012e3:	eb 05                	jmp    8012ea <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8012e5:	38 08                	cmp    %cl,(%eax)
  8012e7:	74 05                	je     8012ee <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8012e9:	40                   	inc    %eax
  8012ea:	39 d0                	cmp    %edx,%eax
  8012ec:	72 f7                	jb     8012e5 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8012ee:	5d                   	pop    %ebp
  8012ef:	c3                   	ret    

008012f0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8012f0:	55                   	push   %ebp
  8012f1:	89 e5                	mov    %esp,%ebp
  8012f3:	57                   	push   %edi
  8012f4:	56                   	push   %esi
  8012f5:	53                   	push   %ebx
  8012f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8012f9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8012fc:	eb 01                	jmp    8012ff <strtol+0xf>
		s++;
  8012fe:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8012ff:	8a 02                	mov    (%edx),%al
  801301:	3c 20                	cmp    $0x20,%al
  801303:	74 f9                	je     8012fe <strtol+0xe>
  801305:	3c 09                	cmp    $0x9,%al
  801307:	74 f5                	je     8012fe <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801309:	3c 2b                	cmp    $0x2b,%al
  80130b:	75 08                	jne    801315 <strtol+0x25>
		s++;
  80130d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80130e:	bf 00 00 00 00       	mov    $0x0,%edi
  801313:	eb 13                	jmp    801328 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801315:	3c 2d                	cmp    $0x2d,%al
  801317:	75 0a                	jne    801323 <strtol+0x33>
		s++, neg = 1;
  801319:	8d 52 01             	lea    0x1(%edx),%edx
  80131c:	bf 01 00 00 00       	mov    $0x1,%edi
  801321:	eb 05                	jmp    801328 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801323:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801328:	85 db                	test   %ebx,%ebx
  80132a:	74 05                	je     801331 <strtol+0x41>
  80132c:	83 fb 10             	cmp    $0x10,%ebx
  80132f:	75 28                	jne    801359 <strtol+0x69>
  801331:	8a 02                	mov    (%edx),%al
  801333:	3c 30                	cmp    $0x30,%al
  801335:	75 10                	jne    801347 <strtol+0x57>
  801337:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80133b:	75 0a                	jne    801347 <strtol+0x57>
		s += 2, base = 16;
  80133d:	83 c2 02             	add    $0x2,%edx
  801340:	bb 10 00 00 00       	mov    $0x10,%ebx
  801345:	eb 12                	jmp    801359 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  801347:	85 db                	test   %ebx,%ebx
  801349:	75 0e                	jne    801359 <strtol+0x69>
  80134b:	3c 30                	cmp    $0x30,%al
  80134d:	75 05                	jne    801354 <strtol+0x64>
		s++, base = 8;
  80134f:	42                   	inc    %edx
  801350:	b3 08                	mov    $0x8,%bl
  801352:	eb 05                	jmp    801359 <strtol+0x69>
	else if (base == 0)
		base = 10;
  801354:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801359:	b8 00 00 00 00       	mov    $0x0,%eax
  80135e:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801360:	8a 0a                	mov    (%edx),%cl
  801362:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801365:	80 fb 09             	cmp    $0x9,%bl
  801368:	77 08                	ja     801372 <strtol+0x82>
			dig = *s - '0';
  80136a:	0f be c9             	movsbl %cl,%ecx
  80136d:	83 e9 30             	sub    $0x30,%ecx
  801370:	eb 1e                	jmp    801390 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  801372:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801375:	80 fb 19             	cmp    $0x19,%bl
  801378:	77 08                	ja     801382 <strtol+0x92>
			dig = *s - 'a' + 10;
  80137a:	0f be c9             	movsbl %cl,%ecx
  80137d:	83 e9 57             	sub    $0x57,%ecx
  801380:	eb 0e                	jmp    801390 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  801382:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  801385:	80 fb 19             	cmp    $0x19,%bl
  801388:	77 12                	ja     80139c <strtol+0xac>
			dig = *s - 'A' + 10;
  80138a:	0f be c9             	movsbl %cl,%ecx
  80138d:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801390:	39 f1                	cmp    %esi,%ecx
  801392:	7d 0c                	jge    8013a0 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  801394:	42                   	inc    %edx
  801395:	0f af c6             	imul   %esi,%eax
  801398:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  80139a:	eb c4                	jmp    801360 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  80139c:	89 c1                	mov    %eax,%ecx
  80139e:	eb 02                	jmp    8013a2 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8013a0:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8013a2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8013a6:	74 05                	je     8013ad <strtol+0xbd>
		*endptr = (char *) s;
  8013a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8013ab:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8013ad:	85 ff                	test   %edi,%edi
  8013af:	74 04                	je     8013b5 <strtol+0xc5>
  8013b1:	89 c8                	mov    %ecx,%eax
  8013b3:	f7 d8                	neg    %eax
}
  8013b5:	5b                   	pop    %ebx
  8013b6:	5e                   	pop    %esi
  8013b7:	5f                   	pop    %edi
  8013b8:	5d                   	pop    %ebp
  8013b9:	c3                   	ret    
	...

008013bc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8013bc:	55                   	push   %ebp
  8013bd:	89 e5                	mov    %esp,%ebp
  8013bf:	57                   	push   %edi
  8013c0:	56                   	push   %esi
  8013c1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8013c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8013cd:	89 c3                	mov    %eax,%ebx
  8013cf:	89 c7                	mov    %eax,%edi
  8013d1:	89 c6                	mov    %eax,%esi
  8013d3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8013d5:	5b                   	pop    %ebx
  8013d6:	5e                   	pop    %esi
  8013d7:	5f                   	pop    %edi
  8013d8:	5d                   	pop    %ebp
  8013d9:	c3                   	ret    

008013da <sys_cgetc>:

int
sys_cgetc(void)
{
  8013da:	55                   	push   %ebp
  8013db:	89 e5                	mov    %esp,%ebp
  8013dd:	57                   	push   %edi
  8013de:	56                   	push   %esi
  8013df:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8013e5:	b8 01 00 00 00       	mov    $0x1,%eax
  8013ea:	89 d1                	mov    %edx,%ecx
  8013ec:	89 d3                	mov    %edx,%ebx
  8013ee:	89 d7                	mov    %edx,%edi
  8013f0:	89 d6                	mov    %edx,%esi
  8013f2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8013f4:	5b                   	pop    %ebx
  8013f5:	5e                   	pop    %esi
  8013f6:	5f                   	pop    %edi
  8013f7:	5d                   	pop    %ebp
  8013f8:	c3                   	ret    

008013f9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8013f9:	55                   	push   %ebp
  8013fa:	89 e5                	mov    %esp,%ebp
  8013fc:	57                   	push   %edi
  8013fd:	56                   	push   %esi
  8013fe:	53                   	push   %ebx
  8013ff:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801402:	b9 00 00 00 00       	mov    $0x0,%ecx
  801407:	b8 03 00 00 00       	mov    $0x3,%eax
  80140c:	8b 55 08             	mov    0x8(%ebp),%edx
  80140f:	89 cb                	mov    %ecx,%ebx
  801411:	89 cf                	mov    %ecx,%edi
  801413:	89 ce                	mov    %ecx,%esi
  801415:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801417:	85 c0                	test   %eax,%eax
  801419:	7e 28                	jle    801443 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80141b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80141f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801426:	00 
  801427:	c7 44 24 08 a7 27 80 	movl   $0x8027a7,0x8(%esp)
  80142e:	00 
  80142f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801436:	00 
  801437:	c7 04 24 c4 27 80 00 	movl   $0x8027c4,(%esp)
  80143e:	e8 b1 f5 ff ff       	call   8009f4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801443:	83 c4 2c             	add    $0x2c,%esp
  801446:	5b                   	pop    %ebx
  801447:	5e                   	pop    %esi
  801448:	5f                   	pop    %edi
  801449:	5d                   	pop    %ebp
  80144a:	c3                   	ret    

0080144b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80144b:	55                   	push   %ebp
  80144c:	89 e5                	mov    %esp,%ebp
  80144e:	57                   	push   %edi
  80144f:	56                   	push   %esi
  801450:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801451:	ba 00 00 00 00       	mov    $0x0,%edx
  801456:	b8 02 00 00 00       	mov    $0x2,%eax
  80145b:	89 d1                	mov    %edx,%ecx
  80145d:	89 d3                	mov    %edx,%ebx
  80145f:	89 d7                	mov    %edx,%edi
  801461:	89 d6                	mov    %edx,%esi
  801463:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801465:	5b                   	pop    %ebx
  801466:	5e                   	pop    %esi
  801467:	5f                   	pop    %edi
  801468:	5d                   	pop    %ebp
  801469:	c3                   	ret    

0080146a <sys_yield>:

void
sys_yield(void)
{
  80146a:	55                   	push   %ebp
  80146b:	89 e5                	mov    %esp,%ebp
  80146d:	57                   	push   %edi
  80146e:	56                   	push   %esi
  80146f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801470:	ba 00 00 00 00       	mov    $0x0,%edx
  801475:	b8 0b 00 00 00       	mov    $0xb,%eax
  80147a:	89 d1                	mov    %edx,%ecx
  80147c:	89 d3                	mov    %edx,%ebx
  80147e:	89 d7                	mov    %edx,%edi
  801480:	89 d6                	mov    %edx,%esi
  801482:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801484:	5b                   	pop    %ebx
  801485:	5e                   	pop    %esi
  801486:	5f                   	pop    %edi
  801487:	5d                   	pop    %ebp
  801488:	c3                   	ret    

00801489 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801489:	55                   	push   %ebp
  80148a:	89 e5                	mov    %esp,%ebp
  80148c:	57                   	push   %edi
  80148d:	56                   	push   %esi
  80148e:	53                   	push   %ebx
  80148f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801492:	be 00 00 00 00       	mov    $0x0,%esi
  801497:	b8 04 00 00 00       	mov    $0x4,%eax
  80149c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80149f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8014a5:	89 f7                	mov    %esi,%edi
  8014a7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8014a9:	85 c0                	test   %eax,%eax
  8014ab:	7e 28                	jle    8014d5 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8014ad:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014b1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8014b8:	00 
  8014b9:	c7 44 24 08 a7 27 80 	movl   $0x8027a7,0x8(%esp)
  8014c0:	00 
  8014c1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8014c8:	00 
  8014c9:	c7 04 24 c4 27 80 00 	movl   $0x8027c4,(%esp)
  8014d0:	e8 1f f5 ff ff       	call   8009f4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8014d5:	83 c4 2c             	add    $0x2c,%esp
  8014d8:	5b                   	pop    %ebx
  8014d9:	5e                   	pop    %esi
  8014da:	5f                   	pop    %edi
  8014db:	5d                   	pop    %ebp
  8014dc:	c3                   	ret    

008014dd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8014dd:	55                   	push   %ebp
  8014de:	89 e5                	mov    %esp,%ebp
  8014e0:	57                   	push   %edi
  8014e1:	56                   	push   %esi
  8014e2:	53                   	push   %ebx
  8014e3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014e6:	b8 05 00 00 00       	mov    $0x5,%eax
  8014eb:	8b 75 18             	mov    0x18(%ebp),%esi
  8014ee:	8b 7d 14             	mov    0x14(%ebp),%edi
  8014f1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8014f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8014fa:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8014fc:	85 c0                	test   %eax,%eax
  8014fe:	7e 28                	jle    801528 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801500:	89 44 24 10          	mov    %eax,0x10(%esp)
  801504:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80150b:	00 
  80150c:	c7 44 24 08 a7 27 80 	movl   $0x8027a7,0x8(%esp)
  801513:	00 
  801514:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80151b:	00 
  80151c:	c7 04 24 c4 27 80 00 	movl   $0x8027c4,(%esp)
  801523:	e8 cc f4 ff ff       	call   8009f4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801528:	83 c4 2c             	add    $0x2c,%esp
  80152b:	5b                   	pop    %ebx
  80152c:	5e                   	pop    %esi
  80152d:	5f                   	pop    %edi
  80152e:	5d                   	pop    %ebp
  80152f:	c3                   	ret    

00801530 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801530:	55                   	push   %ebp
  801531:	89 e5                	mov    %esp,%ebp
  801533:	57                   	push   %edi
  801534:	56                   	push   %esi
  801535:	53                   	push   %ebx
  801536:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801539:	bb 00 00 00 00       	mov    $0x0,%ebx
  80153e:	b8 06 00 00 00       	mov    $0x6,%eax
  801543:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801546:	8b 55 08             	mov    0x8(%ebp),%edx
  801549:	89 df                	mov    %ebx,%edi
  80154b:	89 de                	mov    %ebx,%esi
  80154d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80154f:	85 c0                	test   %eax,%eax
  801551:	7e 28                	jle    80157b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801553:	89 44 24 10          	mov    %eax,0x10(%esp)
  801557:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80155e:	00 
  80155f:	c7 44 24 08 a7 27 80 	movl   $0x8027a7,0x8(%esp)
  801566:	00 
  801567:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80156e:	00 
  80156f:	c7 04 24 c4 27 80 00 	movl   $0x8027c4,(%esp)
  801576:	e8 79 f4 ff ff       	call   8009f4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80157b:	83 c4 2c             	add    $0x2c,%esp
  80157e:	5b                   	pop    %ebx
  80157f:	5e                   	pop    %esi
  801580:	5f                   	pop    %edi
  801581:	5d                   	pop    %ebp
  801582:	c3                   	ret    

00801583 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801583:	55                   	push   %ebp
  801584:	89 e5                	mov    %esp,%ebp
  801586:	57                   	push   %edi
  801587:	56                   	push   %esi
  801588:	53                   	push   %ebx
  801589:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80158c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801591:	b8 08 00 00 00       	mov    $0x8,%eax
  801596:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801599:	8b 55 08             	mov    0x8(%ebp),%edx
  80159c:	89 df                	mov    %ebx,%edi
  80159e:	89 de                	mov    %ebx,%esi
  8015a0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8015a2:	85 c0                	test   %eax,%eax
  8015a4:	7e 28                	jle    8015ce <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8015a6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015aa:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8015b1:	00 
  8015b2:	c7 44 24 08 a7 27 80 	movl   $0x8027a7,0x8(%esp)
  8015b9:	00 
  8015ba:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8015c1:	00 
  8015c2:	c7 04 24 c4 27 80 00 	movl   $0x8027c4,(%esp)
  8015c9:	e8 26 f4 ff ff       	call   8009f4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8015ce:	83 c4 2c             	add    $0x2c,%esp
  8015d1:	5b                   	pop    %ebx
  8015d2:	5e                   	pop    %esi
  8015d3:	5f                   	pop    %edi
  8015d4:	5d                   	pop    %ebp
  8015d5:	c3                   	ret    

008015d6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8015d6:	55                   	push   %ebp
  8015d7:	89 e5                	mov    %esp,%ebp
  8015d9:	57                   	push   %edi
  8015da:	56                   	push   %esi
  8015db:	53                   	push   %ebx
  8015dc:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015df:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015e4:	b8 09 00 00 00       	mov    $0x9,%eax
  8015e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015ec:	8b 55 08             	mov    0x8(%ebp),%edx
  8015ef:	89 df                	mov    %ebx,%edi
  8015f1:	89 de                	mov    %ebx,%esi
  8015f3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8015f5:	85 c0                	test   %eax,%eax
  8015f7:	7e 28                	jle    801621 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8015f9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015fd:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801604:	00 
  801605:	c7 44 24 08 a7 27 80 	movl   $0x8027a7,0x8(%esp)
  80160c:	00 
  80160d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801614:	00 
  801615:	c7 04 24 c4 27 80 00 	movl   $0x8027c4,(%esp)
  80161c:	e8 d3 f3 ff ff       	call   8009f4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801621:	83 c4 2c             	add    $0x2c,%esp
  801624:	5b                   	pop    %ebx
  801625:	5e                   	pop    %esi
  801626:	5f                   	pop    %edi
  801627:	5d                   	pop    %ebp
  801628:	c3                   	ret    

00801629 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801629:	55                   	push   %ebp
  80162a:	89 e5                	mov    %esp,%ebp
  80162c:	57                   	push   %edi
  80162d:	56                   	push   %esi
  80162e:	53                   	push   %ebx
  80162f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801632:	bb 00 00 00 00       	mov    $0x0,%ebx
  801637:	b8 0a 00 00 00       	mov    $0xa,%eax
  80163c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80163f:	8b 55 08             	mov    0x8(%ebp),%edx
  801642:	89 df                	mov    %ebx,%edi
  801644:	89 de                	mov    %ebx,%esi
  801646:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801648:	85 c0                	test   %eax,%eax
  80164a:	7e 28                	jle    801674 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80164c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801650:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801657:	00 
  801658:	c7 44 24 08 a7 27 80 	movl   $0x8027a7,0x8(%esp)
  80165f:	00 
  801660:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801667:	00 
  801668:	c7 04 24 c4 27 80 00 	movl   $0x8027c4,(%esp)
  80166f:	e8 80 f3 ff ff       	call   8009f4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801674:	83 c4 2c             	add    $0x2c,%esp
  801677:	5b                   	pop    %ebx
  801678:	5e                   	pop    %esi
  801679:	5f                   	pop    %edi
  80167a:	5d                   	pop    %ebp
  80167b:	c3                   	ret    

0080167c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80167c:	55                   	push   %ebp
  80167d:	89 e5                	mov    %esp,%ebp
  80167f:	57                   	push   %edi
  801680:	56                   	push   %esi
  801681:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801682:	be 00 00 00 00       	mov    $0x0,%esi
  801687:	b8 0c 00 00 00       	mov    $0xc,%eax
  80168c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80168f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801692:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801695:	8b 55 08             	mov    0x8(%ebp),%edx
  801698:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80169a:	5b                   	pop    %ebx
  80169b:	5e                   	pop    %esi
  80169c:	5f                   	pop    %edi
  80169d:	5d                   	pop    %ebp
  80169e:	c3                   	ret    

0080169f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80169f:	55                   	push   %ebp
  8016a0:	89 e5                	mov    %esp,%ebp
  8016a2:	57                   	push   %edi
  8016a3:	56                   	push   %esi
  8016a4:	53                   	push   %ebx
  8016a5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8016a8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8016ad:	b8 0d 00 00 00       	mov    $0xd,%eax
  8016b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8016b5:	89 cb                	mov    %ecx,%ebx
  8016b7:	89 cf                	mov    %ecx,%edi
  8016b9:	89 ce                	mov    %ecx,%esi
  8016bb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8016bd:	85 c0                	test   %eax,%eax
  8016bf:	7e 28                	jle    8016e9 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016c1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8016c5:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8016cc:	00 
  8016cd:	c7 44 24 08 a7 27 80 	movl   $0x8027a7,0x8(%esp)
  8016d4:	00 
  8016d5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8016dc:	00 
  8016dd:	c7 04 24 c4 27 80 00 	movl   $0x8027c4,(%esp)
  8016e4:	e8 0b f3 ff ff       	call   8009f4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8016e9:	83 c4 2c             	add    $0x2c,%esp
  8016ec:	5b                   	pop    %ebx
  8016ed:	5e                   	pop    %esi
  8016ee:	5f                   	pop    %edi
  8016ef:	5d                   	pop    %ebp
  8016f0:	c3                   	ret    

008016f1 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8016f1:	55                   	push   %ebp
  8016f2:	89 e5                	mov    %esp,%ebp
  8016f4:	57                   	push   %edi
  8016f5:	56                   	push   %esi
  8016f6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8016f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8016fc:	b8 0e 00 00 00       	mov    $0xe,%eax
  801701:	89 d1                	mov    %edx,%ecx
  801703:	89 d3                	mov    %edx,%ebx
  801705:	89 d7                	mov    %edx,%edi
  801707:	89 d6                	mov    %edx,%esi
  801709:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80170b:	5b                   	pop    %ebx
  80170c:	5e                   	pop    %esi
  80170d:	5f                   	pop    %edi
  80170e:	5d                   	pop    %ebp
  80170f:	c3                   	ret    

00801710 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char* pck, size_t length){
  801710:	55                   	push   %ebp
  801711:	89 e5                	mov    %esp,%ebp
  801713:	57                   	push   %edi
  801714:	56                   	push   %esi
  801715:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801716:	bb 00 00 00 00       	mov    $0x0,%ebx
  80171b:	b8 10 00 00 00       	mov    $0x10,%eax
  801720:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801723:	8b 55 08             	mov    0x8(%ebp),%edx
  801726:	89 df                	mov    %ebx,%edi
  801728:	89 de                	mov    %ebx,%esi
  80172a:	cd 30                	int    $0x30
}

int 
sys_e1000_transmit(char* pck, size_t length){
	return syscall(SYS_e1000_transmit, 0, (uint32_t)pck, length, 0, 0, 0);
}
  80172c:	5b                   	pop    %ebx
  80172d:	5e                   	pop    %esi
  80172e:	5f                   	pop    %edi
  80172f:	5d                   	pop    %ebp
  801730:	c3                   	ret    

00801731 <sys_e1000_receive>:

int 
sys_e1000_receive(char* pck, size_t* length){
  801731:	55                   	push   %ebp
  801732:	89 e5                	mov    %esp,%ebp
  801734:	57                   	push   %edi
  801735:	56                   	push   %esi
  801736:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801737:	bb 00 00 00 00       	mov    $0x0,%ebx
  80173c:	b8 0f 00 00 00       	mov    $0xf,%eax
  801741:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801744:	8b 55 08             	mov    0x8(%ebp),%edx
  801747:	89 df                	mov    %ebx,%edi
  801749:	89 de                	mov    %ebx,%esi
  80174b:	cd 30                	int    $0x30
}

int 
sys_e1000_receive(char* pck, size_t* length){
	return syscall(SYS_e1000_receive, 0, (uint32_t)pck, (uint32_t)length, 0, 0, 0);
}
  80174d:	5b                   	pop    %ebx
  80174e:	5e                   	pop    %esi
  80174f:	5f                   	pop    %edi
  801750:	5d                   	pop    %ebp
  801751:	c3                   	ret    

00801752 <sys_e1000_get_mac>:

int 
sys_e1000_get_mac(uint8_t* mac_addr){
  801752:	55                   	push   %ebp
  801753:	89 e5                	mov    %esp,%ebp
  801755:	57                   	push   %edi
  801756:	56                   	push   %esi
  801757:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801758:	b9 00 00 00 00       	mov    $0x0,%ecx
  80175d:	b8 11 00 00 00       	mov    $0x11,%eax
  801762:	8b 55 08             	mov    0x8(%ebp),%edx
  801765:	89 cb                	mov    %ecx,%ebx
  801767:	89 cf                	mov    %ecx,%edi
  801769:	89 ce                	mov    %ecx,%esi
  80176b:	cd 30                	int    $0x30
}

int 
sys_e1000_get_mac(uint8_t* mac_addr){
	return syscall(SYS_e1000_get_mac, 0, (uint32_t)mac_addr, 0, 0, 0, 0);
}
  80176d:	5b                   	pop    %ebx
  80176e:	5e                   	pop    %esi
  80176f:	5f                   	pop    %edi
  801770:	5d                   	pop    %ebp
  801771:	c3                   	ret    
	...

00801774 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801774:	55                   	push   %ebp
  801775:	89 e5                	mov    %esp,%ebp
  801777:	53                   	push   %ebx
  801778:	83 ec 24             	sub    $0x24,%esp
  80177b:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80177e:	8b 18                	mov    (%eax),%ebx
	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	if ((err & FEC_WR) == 0)
  801780:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801784:	75 20                	jne    8017a6 <pgfault+0x32>
		panic("pgfault: faulting address [%08x] not a write\n", addr);
  801786:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80178a:	c7 44 24 08 d4 27 80 	movl   $0x8027d4,0x8(%esp)
  801791:	00 
  801792:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  801799:	00 
  80179a:	c7 04 24 54 28 80 00 	movl   $0x802854,(%esp)
  8017a1:	e8 4e f2 ff ff       	call   8009f4 <_panic>

	void *page_aligned_addr = (void *) ROUNDDOWN(addr, PGSIZE);
  8017a6:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t page_num = (uint32_t) page_aligned_addr / PGSIZE;
  8017ac:	89 d8                	mov    %ebx,%eax
  8017ae:	c1 e8 0c             	shr    $0xc,%eax
	if (!(uvpt[page_num] & PTE_COW))
  8017b1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8017b8:	f6 c4 08             	test   $0x8,%ah
  8017bb:	75 1c                	jne    8017d9 <pgfault+0x65>
		panic("pgfault: fault was not on a copy-on-write page\n");
  8017bd:	c7 44 24 08 04 28 80 	movl   $0x802804,0x8(%esp)
  8017c4:	00 
  8017c5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8017cc:	00 
  8017cd:	c7 04 24 54 28 80 00 	movl   $0x802854,(%esp)
  8017d4:	e8 1b f2 ff ff       	call   8009f4 <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.

	// Allocate
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  8017d9:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8017e0:	00 
  8017e1:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8017e8:	00 
  8017e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017f0:	e8 94 fc ff ff       	call   801489 <sys_page_alloc>
  8017f5:	85 c0                	test   %eax,%eax
  8017f7:	79 20                	jns    801819 <pgfault+0xa5>
		panic("sys_page_alloc: %e\n", r);
  8017f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017fd:	c7 44 24 08 5f 28 80 	movl   $0x80285f,0x8(%esp)
  801804:	00 
  801805:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  80180c:	00 
  80180d:	c7 04 24 54 28 80 00 	movl   $0x802854,(%esp)
  801814:	e8 db f1 ff ff       	call   8009f4 <_panic>

	// Copy over
	void *src_addr = (void *) ROUNDDOWN(addr, PGSIZE);
	memmove(PFTEMP, src_addr, PGSIZE);
  801819:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801820:	00 
  801821:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801825:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  80182c:	e8 df f9 ff ff       	call   801210 <memmove>

	// Remap
	if ((r = sys_page_map(0, PFTEMP, 0, src_addr, PTE_P | PTE_U | PTE_W)) < 0)
  801831:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801838:	00 
  801839:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80183d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801844:	00 
  801845:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80184c:	00 
  80184d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801854:	e8 84 fc ff ff       	call   8014dd <sys_page_map>
  801859:	85 c0                	test   %eax,%eax
  80185b:	79 20                	jns    80187d <pgfault+0x109>
		panic("sys_page_map: %e\n", r);
  80185d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801861:	c7 44 24 08 73 28 80 	movl   $0x802873,0x8(%esp)
  801868:	00 
  801869:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  801870:	00 
  801871:	c7 04 24 54 28 80 00 	movl   $0x802854,(%esp)
  801878:	e8 77 f1 ff ff       	call   8009f4 <_panic>

}
  80187d:	83 c4 24             	add    $0x24,%esp
  801880:	5b                   	pop    %ebx
  801881:	5d                   	pop    %ebp
  801882:	c3                   	ret    

00801883 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801883:	55                   	push   %ebp
  801884:	89 e5                	mov    %esp,%ebp
  801886:	57                   	push   %edi
  801887:	56                   	push   %esi
  801888:	53                   	push   %ebx
  801889:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	int r;
	envid_t child_envid;

	set_pgfault_handler(pgfault);
  80188c:	c7 04 24 74 17 80 00 	movl   $0x801774,(%esp)
  801893:	e8 a4 06 00 00       	call   801f3c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801898:	ba 07 00 00 00       	mov    $0x7,%edx
  80189d:	89 d0                	mov    %edx,%eax
  80189f:	cd 30                	int    $0x30
  8018a1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8018a4:	89 45 e0             	mov    %eax,-0x20(%ebp)

	child_envid = sys_exofork();
	if (child_envid < 0)
  8018a7:	85 c0                	test   %eax,%eax
  8018a9:	79 20                	jns    8018cb <fork+0x48>
		panic("sys_exofork: %e\n", child_envid);
  8018ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018af:	c7 44 24 08 85 28 80 	movl   $0x802885,0x8(%esp)
  8018b6:	00 
  8018b7:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  8018be:	00 
  8018bf:	c7 04 24 54 28 80 00 	movl   $0x802854,(%esp)
  8018c6:	e8 29 f1 ff ff       	call   8009f4 <_panic>
	if (child_envid == 0) { // child
  8018cb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8018cf:	75 1c                	jne    8018ed <fork+0x6a>
		// Fix thisenv like dumbfork does and return 0
		thisenv = &envs[ENVX(sys_getenvid())];
  8018d1:	e8 75 fb ff ff       	call   80144b <sys_getenvid>
  8018d6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8018db:	c1 e0 07             	shl    $0x7,%eax
  8018de:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8018e3:	a3 1c 40 80 00       	mov    %eax,0x80401c
		return 0;
  8018e8:	e9 58 02 00 00       	jmp    801b45 <fork+0x2c2>
	set_pgfault_handler(pgfault);

	child_envid = sys_exofork();
	if (child_envid < 0)
		panic("sys_exofork: %e\n", child_envid);
	if (child_envid == 0) { // child
  8018ed:	bf 00 00 00 00       	mov    $0x0,%edi
  8018f2:	be 00 00 00 00       	mov    $0x0,%esi
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
  8018f7:	89 f0                	mov    %esi,%eax
  8018f9:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  8018fc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801903:	a8 01                	test   $0x1,%al
  801905:	0f 84 7a 01 00 00    	je     801a85 <fork+0x202>
			((uvpt[page_num] & PTE_P) == PTE_P)) {
  80190b:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  801912:	a8 01                	test   $0x1,%al
  801914:	0f 84 6b 01 00 00    	je     801a85 <fork+0x202>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	envid_t this_envid = thisenv->env_id;
  80191a:	a1 1c 40 80 00       	mov    0x80401c,%eax
  80191f:	8b 40 48             	mov    0x48(%eax),%eax
  801922:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	if (uvpt[pn] & PTE_SHARE) {
  801925:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80192c:	f6 c4 04             	test   $0x4,%ah
  80192f:	74 52                	je     801983 <fork+0x100>
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  801931:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801938:	25 07 0e 00 00       	and    $0xe07,%eax
  80193d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801941:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801945:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801948:	89 44 24 08          	mov    %eax,0x8(%esp)
  80194c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801950:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801953:	89 04 24             	mov    %eax,(%esp)
  801956:	e8 82 fb ff ff       	call   8014dd <sys_page_map>
  80195b:	85 c0                	test   %eax,%eax
  80195d:	0f 89 22 01 00 00    	jns    801a85 <fork+0x202>
			panic("sys_page_map: %e\n", r);
  801963:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801967:	c7 44 24 08 73 28 80 	movl   $0x802873,0x8(%esp)
  80196e:	00 
  80196f:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  801976:	00 
  801977:	c7 04 24 54 28 80 00 	movl   $0x802854,(%esp)
  80197e:	e8 71 f0 ff ff       	call   8009f4 <_panic>
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
  801983:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80198a:	f6 c4 08             	test   $0x8,%ah
  80198d:	75 0f                	jne    80199e <fork+0x11b>
  80198f:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801996:	a8 02                	test   $0x2,%al
  801998:	0f 84 99 00 00 00    	je     801a37 <fork+0x1b4>
		if (uvpt[pn] & PTE_U)
  80199e:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8019a5:	83 e0 04             	and    $0x4,%eax
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
  8019a8:	83 f8 01             	cmp    $0x1,%eax
  8019ab:	19 db                	sbb    %ebx,%ebx
  8019ad:	83 e3 fc             	and    $0xfffffffc,%ebx
  8019b0:	81 c3 05 08 00 00    	add    $0x805,%ebx
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
		if (uvpt[pn] & PTE_U)
			perm |= PTE_U;

		// Map page COW, U and P in child
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), perm)) < 0)
  8019b6:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8019ba:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8019be:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8019c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019c5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8019c9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019cc:	89 04 24             	mov    %eax,(%esp)
  8019cf:	e8 09 fb ff ff       	call   8014dd <sys_page_map>
  8019d4:	85 c0                	test   %eax,%eax
  8019d6:	79 20                	jns    8019f8 <fork+0x175>
			panic("sys_page_map: %e\n", r);
  8019d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019dc:	c7 44 24 08 73 28 80 	movl   $0x802873,0x8(%esp)
  8019e3:	00 
  8019e4:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  8019eb:	00 
  8019ec:	c7 04 24 54 28 80 00 	movl   $0x802854,(%esp)
  8019f3:	e8 fc ef ff ff       	call   8009f4 <_panic>

		// Map page COW, U and P in parent
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), this_envid, (void *) (pn*PGSIZE), perm)) < 0)
  8019f8:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8019fc:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801a00:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a03:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a07:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801a0b:	89 04 24             	mov    %eax,(%esp)
  801a0e:	e8 ca fa ff ff       	call   8014dd <sys_page_map>
  801a13:	85 c0                	test   %eax,%eax
  801a15:	79 6e                	jns    801a85 <fork+0x202>
			panic("sys_page_map: %e\n", r);
  801a17:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a1b:	c7 44 24 08 73 28 80 	movl   $0x802873,0x8(%esp)
  801a22:	00 
  801a23:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  801a2a:	00 
  801a2b:	c7 04 24 54 28 80 00 	movl   $0x802854,(%esp)
  801a32:	e8 bd ef ff ff       	call   8009f4 <_panic>

	} else { // map pages that are present but not writable or COW with their original permissions
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  801a37:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801a3e:	25 07 0e 00 00       	and    $0xe07,%eax
  801a43:	89 44 24 10          	mov    %eax,0x10(%esp)
  801a47:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801a4b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a4e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a52:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801a56:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a59:	89 04 24             	mov    %eax,(%esp)
  801a5c:	e8 7c fa ff ff       	call   8014dd <sys_page_map>
  801a61:	85 c0                	test   %eax,%eax
  801a63:	79 20                	jns    801a85 <fork+0x202>
			panic("sys_page_map: %e\n", r);
  801a65:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a69:	c7 44 24 08 73 28 80 	movl   $0x802873,0x8(%esp)
  801a70:	00 
  801a71:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  801a78:	00 
  801a79:	c7 04 24 54 28 80 00 	movl   $0x802854,(%esp)
  801a80:	e8 6f ef ff ff       	call   8009f4 <_panic>
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
  801a85:	46                   	inc    %esi
  801a86:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801a8c:	81 fe ff eb 0e 00    	cmp    $0xeebff,%esi
  801a92:	0f 85 5f fe ff ff    	jne    8018f7 <fork+0x74>
	}

	// Allocate exception stack space for child. The child can't do this themselves
	// because the mechanism by which it would is to run the pgfault handler, which
	// needs to run on the exception stack (catch 22).
	if ((r = sys_page_alloc(child_envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801a98:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801a9f:	00 
  801aa0:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801aa7:	ee 
  801aa8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801aab:	89 04 24             	mov    %eax,(%esp)
  801aae:	e8 d6 f9 ff ff       	call   801489 <sys_page_alloc>
  801ab3:	85 c0                	test   %eax,%eax
  801ab5:	79 20                	jns    801ad7 <fork+0x254>
		panic("sys_page_alloc: %e\n", r);
  801ab7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801abb:	c7 44 24 08 5f 28 80 	movl   $0x80285f,0x8(%esp)
  801ac2:	00 
  801ac3:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  801aca:	00 
  801acb:	c7 04 24 54 28 80 00 	movl   $0x802854,(%esp)
  801ad2:	e8 1d ef ff ff       	call   8009f4 <_panic>

	// Set page fault handler for the child
	if ((r = sys_env_set_pgfault_upcall(child_envid, _pgfault_upcall)) < 0)
  801ad7:	c7 44 24 04 b0 1f 80 	movl   $0x801fb0,0x4(%esp)
  801ade:	00 
  801adf:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801ae2:	89 04 24             	mov    %eax,(%esp)
  801ae5:	e8 3f fb ff ff       	call   801629 <sys_env_set_pgfault_upcall>
  801aea:	85 c0                	test   %eax,%eax
  801aec:	79 20                	jns    801b0e <fork+0x28b>
		panic("sys_env_set_pgfault_upcall: %e\n", r);
  801aee:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801af2:	c7 44 24 08 34 28 80 	movl   $0x802834,0x8(%esp)
  801af9:	00 
  801afa:	c7 44 24 04 a1 00 00 	movl   $0xa1,0x4(%esp)
  801b01:	00 
  801b02:	c7 04 24 54 28 80 00 	movl   $0x802854,(%esp)
  801b09:	e8 e6 ee ff ff       	call   8009f4 <_panic>

	// Mark child environment as runnable
	if ((r = sys_env_set_status(child_envid, ENV_RUNNABLE)) < 0)
  801b0e:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801b15:	00 
  801b16:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801b19:	89 04 24             	mov    %eax,(%esp)
  801b1c:	e8 62 fa ff ff       	call   801583 <sys_env_set_status>
  801b21:	85 c0                	test   %eax,%eax
  801b23:	79 20                	jns    801b45 <fork+0x2c2>
		panic("sys_env_set_status: %e\n", r);
  801b25:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b29:	c7 44 24 08 96 28 80 	movl   $0x802896,0x8(%esp)
  801b30:	00 
  801b31:	c7 44 24 04 a5 00 00 	movl   $0xa5,0x4(%esp)
  801b38:	00 
  801b39:	c7 04 24 54 28 80 00 	movl   $0x802854,(%esp)
  801b40:	e8 af ee ff ff       	call   8009f4 <_panic>

	return child_envid;
}
  801b45:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801b48:	83 c4 3c             	add    $0x3c,%esp
  801b4b:	5b                   	pop    %ebx
  801b4c:	5e                   	pop    %esi
  801b4d:	5f                   	pop    %edi
  801b4e:	5d                   	pop    %ebp
  801b4f:	c3                   	ret    

00801b50 <sfork>:

// Challenge!
int
sfork(void)
{
  801b50:	55                   	push   %ebp
  801b51:	89 e5                	mov    %esp,%ebp
  801b53:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801b56:	c7 44 24 08 ae 28 80 	movl   $0x8028ae,0x8(%esp)
  801b5d:	00 
  801b5e:	c7 44 24 04 ae 00 00 	movl   $0xae,0x4(%esp)
  801b65:	00 
  801b66:	c7 04 24 54 28 80 00 	movl   $0x802854,(%esp)
  801b6d:	e8 82 ee ff ff       	call   8009f4 <_panic>
	...

00801b74 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b74:	55                   	push   %ebp
  801b75:	89 e5                	mov    %esp,%ebp
  801b77:	56                   	push   %esi
  801b78:	53                   	push   %ebx
  801b79:	83 ec 10             	sub    $0x10,%esp
  801b7c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801b7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b82:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int r;
		
	r = sys_ipc_recv(pg?pg:(void*)UTOP);
  801b85:	85 c0                	test   %eax,%eax
  801b87:	75 05                	jne    801b8e <ipc_recv+0x1a>
  801b89:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801b8e:	89 04 24             	mov    %eax,(%esp)
  801b91:	e8 09 fb ff ff       	call   80169f <sys_ipc_recv>
	if (from_env_store != NULL)
  801b96:	85 db                	test   %ebx,%ebx
  801b98:	74 0b                	je     801ba5 <ipc_recv+0x31>
		*from_env_store = thisenv->env_ipc_from; 
  801b9a:	8b 15 1c 40 80 00    	mov    0x80401c,%edx
  801ba0:	8b 52 74             	mov    0x74(%edx),%edx
  801ba3:	89 13                	mov    %edx,(%ebx)
	if (perm_store != NULL)
  801ba5:	85 f6                	test   %esi,%esi
  801ba7:	74 0b                	je     801bb4 <ipc_recv+0x40>
		*perm_store = thisenv->env_ipc_perm;
  801ba9:	8b 15 1c 40 80 00    	mov    0x80401c,%edx
  801baf:	8b 52 78             	mov    0x78(%edx),%edx
  801bb2:	89 16                	mov    %edx,(%esi)
	
	if (r < 0){
  801bb4:	85 c0                	test   %eax,%eax
  801bb6:	79 16                	jns    801bce <ipc_recv+0x5a>
		if(from_env_store != NULL)
  801bb8:	85 db                	test   %ebx,%ebx
  801bba:	74 06                	je     801bc2 <ipc_recv+0x4e>
			*from_env_store = 0;
  801bbc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store != NULL)	
  801bc2:	85 f6                	test   %esi,%esi
  801bc4:	74 10                	je     801bd6 <ipc_recv+0x62>
			*perm_store = 0;
  801bc6:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801bcc:	eb 08                	jmp    801bd6 <ipc_recv+0x62>
		return r;
	}
	
	return thisenv->env_ipc_value;
  801bce:	a1 1c 40 80 00       	mov    0x80401c,%eax
  801bd3:	8b 40 70             	mov    0x70(%eax),%eax
}
  801bd6:	83 c4 10             	add    $0x10,%esp
  801bd9:	5b                   	pop    %ebx
  801bda:	5e                   	pop    %esi
  801bdb:	5d                   	pop    %ebp
  801bdc:	c3                   	ret    

00801bdd <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801bdd:	55                   	push   %ebp
  801bde:	89 e5                	mov    %esp,%ebp
  801be0:	57                   	push   %edi
  801be1:	56                   	push   %esi
  801be2:	53                   	push   %ebx
  801be3:	83 ec 1c             	sub    $0x1c,%esp
  801be6:	8b 75 08             	mov    0x8(%ebp),%esi
  801be9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801bec:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  801bef:	eb 2a                	jmp    801c1b <ipc_send+0x3e>
		if (r != -E_IPC_NOT_RECV)
  801bf1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801bf4:	74 20                	je     801c16 <ipc_send+0x39>
			panic("ipc_send: sys_ipc_try_send failed %e", r);
  801bf6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bfa:	c7 44 24 08 c4 28 80 	movl   $0x8028c4,0x8(%esp)
  801c01:	00 
  801c02:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  801c09:	00 
  801c0a:	c7 04 24 ec 28 80 00 	movl   $0x8028ec,(%esp)
  801c11:	e8 de ed ff ff       	call   8009f4 <_panic>
		sys_yield();
  801c16:	e8 4f f8 ff ff       	call   80146a <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  801c1b:	85 db                	test   %ebx,%ebx
  801c1d:	75 07                	jne    801c26 <ipc_send+0x49>
  801c1f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801c24:	eb 02                	jmp    801c28 <ipc_send+0x4b>
  801c26:	89 d8                	mov    %ebx,%eax
  801c28:	8b 55 14             	mov    0x14(%ebp),%edx
  801c2b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801c2f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c33:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801c37:	89 34 24             	mov    %esi,(%esp)
  801c3a:	e8 3d fa ff ff       	call   80167c <sys_ipc_try_send>
  801c3f:	85 c0                	test   %eax,%eax
  801c41:	78 ae                	js     801bf1 <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: sys_ipc_try_send failed %e", r);
		sys_yield();
	}
}
  801c43:	83 c4 1c             	add    $0x1c,%esp
  801c46:	5b                   	pop    %ebx
  801c47:	5e                   	pop    %esi
  801c48:	5f                   	pop    %edi
  801c49:	5d                   	pop    %ebp
  801c4a:	c3                   	ret    

00801c4b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c4b:	55                   	push   %ebp
  801c4c:	89 e5                	mov    %esp,%ebp
  801c4e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801c51:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c56:	89 c2                	mov    %eax,%edx
  801c58:	c1 e2 07             	shl    $0x7,%edx
  801c5b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c61:	8b 52 50             	mov    0x50(%edx),%edx
  801c64:	39 ca                	cmp    %ecx,%edx
  801c66:	75 0d                	jne    801c75 <ipc_find_env+0x2a>
			return envs[i].env_id;
  801c68:	c1 e0 07             	shl    $0x7,%eax
  801c6b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801c70:	8b 40 40             	mov    0x40(%eax),%eax
  801c73:	eb 0c                	jmp    801c81 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c75:	40                   	inc    %eax
  801c76:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c7b:	75 d9                	jne    801c56 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c7d:	66 b8 00 00          	mov    $0x0,%ax
}
  801c81:	5d                   	pop    %ebp
  801c82:	c3                   	ret    
	...

00801c84 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801c84:	55                   	push   %ebp
  801c85:	89 e5                	mov    %esp,%ebp
  801c87:	53                   	push   %ebx
  801c88:	83 ec 14             	sub    $0x14,%esp
  801c8b:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801c8d:	83 3d 18 40 80 00 00 	cmpl   $0x0,0x804018
  801c94:	75 11                	jne    801ca7 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801c96:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801c9d:	e8 a9 ff ff ff       	call   801c4b <ipc_find_env>
  801ca2:	a3 18 40 80 00       	mov    %eax,0x804018
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801ca7:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801cae:	00 
  801caf:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801cb6:	00 
  801cb7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cbb:	a1 18 40 80 00       	mov    0x804018,%eax
  801cc0:	89 04 24             	mov    %eax,(%esp)
  801cc3:	e8 15 ff ff ff       	call   801bdd <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801cc8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ccf:	00 
  801cd0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801cd7:	00 
  801cd8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cdf:	e8 90 fe ff ff       	call   801b74 <ipc_recv>
}
  801ce4:	83 c4 14             	add    $0x14,%esp
  801ce7:	5b                   	pop    %ebx
  801ce8:	5d                   	pop    %ebp
  801ce9:	c3                   	ret    

00801cea <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801cea:	55                   	push   %ebp
  801ceb:	89 e5                	mov    %esp,%ebp
  801ced:	56                   	push   %esi
  801cee:	53                   	push   %ebx
  801cef:	83 ec 10             	sub    $0x10,%esp
  801cf2:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801cf5:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf8:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801cfd:	8b 06                	mov    (%esi),%eax
  801cff:	a3 04 50 80 00       	mov    %eax,0x805004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801d04:	b8 01 00 00 00       	mov    $0x1,%eax
  801d09:	e8 76 ff ff ff       	call   801c84 <nsipc>
  801d0e:	89 c3                	mov    %eax,%ebx
  801d10:	85 c0                	test   %eax,%eax
  801d12:	78 23                	js     801d37 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801d14:	a1 10 50 80 00       	mov    0x805010,%eax
  801d19:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d1d:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801d24:	00 
  801d25:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d28:	89 04 24             	mov    %eax,(%esp)
  801d2b:	e8 e0 f4 ff ff       	call   801210 <memmove>
		*addrlen = ret->ret_addrlen;
  801d30:	a1 10 50 80 00       	mov    0x805010,%eax
  801d35:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801d37:	89 d8                	mov    %ebx,%eax
  801d39:	83 c4 10             	add    $0x10,%esp
  801d3c:	5b                   	pop    %ebx
  801d3d:	5e                   	pop    %esi
  801d3e:	5d                   	pop    %ebp
  801d3f:	c3                   	ret    

00801d40 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d40:	55                   	push   %ebp
  801d41:	89 e5                	mov    %esp,%ebp
  801d43:	53                   	push   %ebx
  801d44:	83 ec 14             	sub    $0x14,%esp
  801d47:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801d4a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d4d:	a3 00 50 80 00       	mov    %eax,0x805000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801d52:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d56:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d59:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d5d:	c7 04 24 04 50 80 00 	movl   $0x805004,(%esp)
  801d64:	e8 a7 f4 ff ff       	call   801210 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801d69:	89 1d 14 50 80 00    	mov    %ebx,0x805014
	return nsipc(NSREQ_BIND);
  801d6f:	b8 02 00 00 00       	mov    $0x2,%eax
  801d74:	e8 0b ff ff ff       	call   801c84 <nsipc>
}
  801d79:	83 c4 14             	add    $0x14,%esp
  801d7c:	5b                   	pop    %ebx
  801d7d:	5d                   	pop    %ebp
  801d7e:	c3                   	ret    

00801d7f <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801d7f:	55                   	push   %ebp
  801d80:	89 e5                	mov    %esp,%ebp
  801d82:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801d85:	8b 45 08             	mov    0x8(%ebp),%eax
  801d88:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.shutdown.req_how = how;
  801d8d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d90:	a3 04 50 80 00       	mov    %eax,0x805004
	return nsipc(NSREQ_SHUTDOWN);
  801d95:	b8 03 00 00 00       	mov    $0x3,%eax
  801d9a:	e8 e5 fe ff ff       	call   801c84 <nsipc>
}
  801d9f:	c9                   	leave  
  801da0:	c3                   	ret    

00801da1 <nsipc_close>:

int
nsipc_close(int s)
{
  801da1:	55                   	push   %ebp
  801da2:	89 e5                	mov    %esp,%ebp
  801da4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801da7:	8b 45 08             	mov    0x8(%ebp),%eax
  801daa:	a3 00 50 80 00       	mov    %eax,0x805000
	return nsipc(NSREQ_CLOSE);
  801daf:	b8 04 00 00 00       	mov    $0x4,%eax
  801db4:	e8 cb fe ff ff       	call   801c84 <nsipc>
}
  801db9:	c9                   	leave  
  801dba:	c3                   	ret    

00801dbb <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801dbb:	55                   	push   %ebp
  801dbc:	89 e5                	mov    %esp,%ebp
  801dbe:	53                   	push   %ebx
  801dbf:	83 ec 14             	sub    $0x14,%esp
  801dc2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801dc5:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc8:	a3 00 50 80 00       	mov    %eax,0x805000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801dcd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801dd1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dd4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dd8:	c7 04 24 04 50 80 00 	movl   $0x805004,(%esp)
  801ddf:	e8 2c f4 ff ff       	call   801210 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801de4:	89 1d 14 50 80 00    	mov    %ebx,0x805014
	return nsipc(NSREQ_CONNECT);
  801dea:	b8 05 00 00 00       	mov    $0x5,%eax
  801def:	e8 90 fe ff ff       	call   801c84 <nsipc>
}
  801df4:	83 c4 14             	add    $0x14,%esp
  801df7:	5b                   	pop    %ebx
  801df8:	5d                   	pop    %ebp
  801df9:	c3                   	ret    

00801dfa <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801dfa:	55                   	push   %ebp
  801dfb:	89 e5                	mov    %esp,%ebp
  801dfd:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801e00:	8b 45 08             	mov    0x8(%ebp),%eax
  801e03:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.listen.req_backlog = backlog;
  801e08:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e0b:	a3 04 50 80 00       	mov    %eax,0x805004
	return nsipc(NSREQ_LISTEN);
  801e10:	b8 06 00 00 00       	mov    $0x6,%eax
  801e15:	e8 6a fe ff ff       	call   801c84 <nsipc>
}
  801e1a:	c9                   	leave  
  801e1b:	c3                   	ret    

00801e1c <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801e1c:	55                   	push   %ebp
  801e1d:	89 e5                	mov    %esp,%ebp
  801e1f:	56                   	push   %esi
  801e20:	53                   	push   %ebx
  801e21:	83 ec 10             	sub    $0x10,%esp
  801e24:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801e27:	8b 45 08             	mov    0x8(%ebp),%eax
  801e2a:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.recv.req_len = len;
  801e2f:	89 35 04 50 80 00    	mov    %esi,0x805004
	nsipcbuf.recv.req_flags = flags;
  801e35:	8b 45 14             	mov    0x14(%ebp),%eax
  801e38:	a3 08 50 80 00       	mov    %eax,0x805008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801e3d:	b8 07 00 00 00       	mov    $0x7,%eax
  801e42:	e8 3d fe ff ff       	call   801c84 <nsipc>
  801e47:	89 c3                	mov    %eax,%ebx
  801e49:	85 c0                	test   %eax,%eax
  801e4b:	78 46                	js     801e93 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801e4d:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801e52:	7f 04                	jg     801e58 <nsipc_recv+0x3c>
  801e54:	39 c6                	cmp    %eax,%esi
  801e56:	7d 24                	jge    801e7c <nsipc_recv+0x60>
  801e58:	c7 44 24 0c f6 28 80 	movl   $0x8028f6,0xc(%esp)
  801e5f:	00 
  801e60:	c7 44 24 08 0b 29 80 	movl   $0x80290b,0x8(%esp)
  801e67:	00 
  801e68:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  801e6f:	00 
  801e70:	c7 04 24 20 29 80 00 	movl   $0x802920,(%esp)
  801e77:	e8 78 eb ff ff       	call   8009f4 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801e7c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e80:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801e87:	00 
  801e88:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e8b:	89 04 24             	mov    %eax,(%esp)
  801e8e:	e8 7d f3 ff ff       	call   801210 <memmove>
	}

	return r;
}
  801e93:	89 d8                	mov    %ebx,%eax
  801e95:	83 c4 10             	add    $0x10,%esp
  801e98:	5b                   	pop    %ebx
  801e99:	5e                   	pop    %esi
  801e9a:	5d                   	pop    %ebp
  801e9b:	c3                   	ret    

00801e9c <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801e9c:	55                   	push   %ebp
  801e9d:	89 e5                	mov    %esp,%ebp
  801e9f:	53                   	push   %ebx
  801ea0:	83 ec 14             	sub    $0x14,%esp
  801ea3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801ea6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ea9:	a3 00 50 80 00       	mov    %eax,0x805000
	assert(size < 1600);
  801eae:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801eb4:	7e 24                	jle    801eda <nsipc_send+0x3e>
  801eb6:	c7 44 24 0c 2c 29 80 	movl   $0x80292c,0xc(%esp)
  801ebd:	00 
  801ebe:	c7 44 24 08 0b 29 80 	movl   $0x80290b,0x8(%esp)
  801ec5:	00 
  801ec6:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  801ecd:	00 
  801ece:	c7 04 24 20 29 80 00 	movl   $0x802920,(%esp)
  801ed5:	e8 1a eb ff ff       	call   8009f4 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801eda:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ede:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ee1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ee5:	c7 04 24 0c 50 80 00 	movl   $0x80500c,(%esp)
  801eec:	e8 1f f3 ff ff       	call   801210 <memmove>
	nsipcbuf.send.req_size = size;
  801ef1:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	nsipcbuf.send.req_flags = flags;
  801ef7:	8b 45 14             	mov    0x14(%ebp),%eax
  801efa:	a3 08 50 80 00       	mov    %eax,0x805008
	return nsipc(NSREQ_SEND);
  801eff:	b8 08 00 00 00       	mov    $0x8,%eax
  801f04:	e8 7b fd ff ff       	call   801c84 <nsipc>
}
  801f09:	83 c4 14             	add    $0x14,%esp
  801f0c:	5b                   	pop    %ebx
  801f0d:	5d                   	pop    %ebp
  801f0e:	c3                   	ret    

00801f0f <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801f0f:	55                   	push   %ebp
  801f10:	89 e5                	mov    %esp,%ebp
  801f12:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801f15:	8b 45 08             	mov    0x8(%ebp),%eax
  801f18:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.socket.req_type = type;
  801f1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f20:	a3 04 50 80 00       	mov    %eax,0x805004
	nsipcbuf.socket.req_protocol = protocol;
  801f25:	8b 45 10             	mov    0x10(%ebp),%eax
  801f28:	a3 08 50 80 00       	mov    %eax,0x805008
	return nsipc(NSREQ_SOCKET);
  801f2d:	b8 09 00 00 00       	mov    $0x9,%eax
  801f32:	e8 4d fd ff ff       	call   801c84 <nsipc>
}
  801f37:	c9                   	leave  
  801f38:	c3                   	ret    
  801f39:	00 00                	add    %al,(%eax)
	...

00801f3c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f3c:	55                   	push   %ebp
  801f3d:	89 e5                	mov    %esp,%ebp
  801f3f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f42:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f49:	75 58                	jne    801fa3 <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.	
		//panic("set_pgfault_handler not implemented");
		
		if (sys_page_alloc(thisenv->env_id,(void *) (UXSTACKTOP - PGSIZE),(PTE_W|PTE_U|PTE_P)) != 0){
  801f4b:	a1 1c 40 80 00       	mov    0x80401c,%eax
  801f50:	8b 40 48             	mov    0x48(%eax),%eax
  801f53:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801f5a:	00 
  801f5b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801f62:	ee 
  801f63:	89 04 24             	mov    %eax,(%esp)
  801f66:	e8 1e f5 ff ff       	call   801489 <sys_page_alloc>
  801f6b:	85 c0                	test   %eax,%eax
  801f6d:	74 1c                	je     801f8b <set_pgfault_handler+0x4f>
			panic("set_pg_fault_handler");
  801f6f:	c7 44 24 08 38 29 80 	movl   $0x802938,0x8(%esp)
  801f76:	00 
  801f77:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801f7e:	00 
  801f7f:	c7 04 24 4d 29 80 00 	movl   $0x80294d,(%esp)
  801f86:	e8 69 ea ff ff       	call   8009f4 <_panic>
		}
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801f8b:	a1 1c 40 80 00       	mov    0x80401c,%eax
  801f90:	8b 40 48             	mov    0x48(%eax),%eax
  801f93:	c7 44 24 04 b0 1f 80 	movl   $0x801fb0,0x4(%esp)
  801f9a:	00 
  801f9b:	89 04 24             	mov    %eax,(%esp)
  801f9e:	e8 86 f6 ff ff       	call   801629 <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801fa3:	8b 45 08             	mov    0x8(%ebp),%eax
  801fa6:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801fab:	c9                   	leave  
  801fac:	c3                   	ret    
  801fad:	00 00                	add    %al,(%eax)
	...

00801fb0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801fb0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801fb1:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801fb6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801fb8:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// Save trap-time eip in eax
	movl 0x28(%esp), %eax
  801fbb:	8b 44 24 28          	mov    0x28(%esp),%eax

	// Save our current stack
	movl %esp, %ebp
  801fbf:	89 e5                	mov    %esp,%ebp

	// Switch to trap-time stack
	movl 0x30(%esp), %esp
  801fc1:	8b 64 24 30          	mov    0x30(%esp),%esp

	// Push trap-time eip to the trap-time stack
	pushl %eax
  801fc5:	50                   	push   %eax

	// We now have to update the trap-time esp with its new value
	movl %esp, 0x30(%ebp)
  801fc6:	89 65 30             	mov    %esp,0x30(%ebp)

	// Go back to our exception stack
	movl %ebp, %esp
  801fc9:	89 ec                	mov    %ebp,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// Pop fault_va and err, both can be ignored
	popl %eax
  801fcb:	58                   	pop    %eax
	popl %eax
  801fcc:	58                   	pop    %eax

	// Pop all registers back
	popal
  801fcd:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// Skip %eip
	addl $0x4, %esp
  801fce:	83 c4 04             	add    $0x4,%esp

	// Pop eflags back
	popfl
  801fd1:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	
	popl %esp
  801fd2:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  801fd3:	c3                   	ret    

00801fd4 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801fd4:	55                   	push   %ebp
  801fd5:	57                   	push   %edi
  801fd6:	56                   	push   %esi
  801fd7:	83 ec 10             	sub    $0x10,%esp
  801fda:	8b 74 24 20          	mov    0x20(%esp),%esi
  801fde:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801fe2:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fe6:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  801fea:	89 cd                	mov    %ecx,%ebp
  801fec:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801ff0:	85 c0                	test   %eax,%eax
  801ff2:	75 2c                	jne    802020 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801ff4:	39 f9                	cmp    %edi,%ecx
  801ff6:	77 68                	ja     802060 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801ff8:	85 c9                	test   %ecx,%ecx
  801ffa:	75 0b                	jne    802007 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801ffc:	b8 01 00 00 00       	mov    $0x1,%eax
  802001:	31 d2                	xor    %edx,%edx
  802003:	f7 f1                	div    %ecx
  802005:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802007:	31 d2                	xor    %edx,%edx
  802009:	89 f8                	mov    %edi,%eax
  80200b:	f7 f1                	div    %ecx
  80200d:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80200f:	89 f0                	mov    %esi,%eax
  802011:	f7 f1                	div    %ecx
  802013:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802015:	89 f0                	mov    %esi,%eax
  802017:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802019:	83 c4 10             	add    $0x10,%esp
  80201c:	5e                   	pop    %esi
  80201d:	5f                   	pop    %edi
  80201e:	5d                   	pop    %ebp
  80201f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802020:	39 f8                	cmp    %edi,%eax
  802022:	77 2c                	ja     802050 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802024:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  802027:	83 f6 1f             	xor    $0x1f,%esi
  80202a:	75 4c                	jne    802078 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80202c:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80202e:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802033:	72 0a                	jb     80203f <__udivdi3+0x6b>
  802035:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802039:	0f 87 ad 00 00 00    	ja     8020ec <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80203f:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802044:	89 f0                	mov    %esi,%eax
  802046:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802048:	83 c4 10             	add    $0x10,%esp
  80204b:	5e                   	pop    %esi
  80204c:	5f                   	pop    %edi
  80204d:	5d                   	pop    %ebp
  80204e:	c3                   	ret    
  80204f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802050:	31 ff                	xor    %edi,%edi
  802052:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802054:	89 f0                	mov    %esi,%eax
  802056:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802058:	83 c4 10             	add    $0x10,%esp
  80205b:	5e                   	pop    %esi
  80205c:	5f                   	pop    %edi
  80205d:	5d                   	pop    %ebp
  80205e:	c3                   	ret    
  80205f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802060:	89 fa                	mov    %edi,%edx
  802062:	89 f0                	mov    %esi,%eax
  802064:	f7 f1                	div    %ecx
  802066:	89 c6                	mov    %eax,%esi
  802068:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80206a:	89 f0                	mov    %esi,%eax
  80206c:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80206e:	83 c4 10             	add    $0x10,%esp
  802071:	5e                   	pop    %esi
  802072:	5f                   	pop    %edi
  802073:	5d                   	pop    %ebp
  802074:	c3                   	ret    
  802075:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802078:	89 f1                	mov    %esi,%ecx
  80207a:	d3 e0                	shl    %cl,%eax
  80207c:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802080:	b8 20 00 00 00       	mov    $0x20,%eax
  802085:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802087:	89 ea                	mov    %ebp,%edx
  802089:	88 c1                	mov    %al,%cl
  80208b:	d3 ea                	shr    %cl,%edx
  80208d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802091:	09 ca                	or     %ecx,%edx
  802093:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  802097:	89 f1                	mov    %esi,%ecx
  802099:	d3 e5                	shl    %cl,%ebp
  80209b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  80209f:	89 fd                	mov    %edi,%ebp
  8020a1:	88 c1                	mov    %al,%cl
  8020a3:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  8020a5:	89 fa                	mov    %edi,%edx
  8020a7:	89 f1                	mov    %esi,%ecx
  8020a9:	d3 e2                	shl    %cl,%edx
  8020ab:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8020af:	88 c1                	mov    %al,%cl
  8020b1:	d3 ef                	shr    %cl,%edi
  8020b3:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8020b5:	89 f8                	mov    %edi,%eax
  8020b7:	89 ea                	mov    %ebp,%edx
  8020b9:	f7 74 24 08          	divl   0x8(%esp)
  8020bd:	89 d1                	mov    %edx,%ecx
  8020bf:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  8020c1:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8020c5:	39 d1                	cmp    %edx,%ecx
  8020c7:	72 17                	jb     8020e0 <__udivdi3+0x10c>
  8020c9:	74 09                	je     8020d4 <__udivdi3+0x100>
  8020cb:	89 fe                	mov    %edi,%esi
  8020cd:	31 ff                	xor    %edi,%edi
  8020cf:	e9 41 ff ff ff       	jmp    802015 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8020d4:	8b 54 24 04          	mov    0x4(%esp),%edx
  8020d8:	89 f1                	mov    %esi,%ecx
  8020da:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8020dc:	39 c2                	cmp    %eax,%edx
  8020de:	73 eb                	jae    8020cb <__udivdi3+0xf7>
		{
		  q0--;
  8020e0:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8020e3:	31 ff                	xor    %edi,%edi
  8020e5:	e9 2b ff ff ff       	jmp    802015 <__udivdi3+0x41>
  8020ea:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8020ec:	31 f6                	xor    %esi,%esi
  8020ee:	e9 22 ff ff ff       	jmp    802015 <__udivdi3+0x41>
	...

008020f4 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8020f4:	55                   	push   %ebp
  8020f5:	57                   	push   %edi
  8020f6:	56                   	push   %esi
  8020f7:	83 ec 20             	sub    $0x20,%esp
  8020fa:	8b 44 24 30          	mov    0x30(%esp),%eax
  8020fe:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802102:	89 44 24 14          	mov    %eax,0x14(%esp)
  802106:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  80210a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80210e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802112:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802114:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802116:	85 ed                	test   %ebp,%ebp
  802118:	75 16                	jne    802130 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  80211a:	39 f1                	cmp    %esi,%ecx
  80211c:	0f 86 a6 00 00 00    	jbe    8021c8 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802122:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802124:	89 d0                	mov    %edx,%eax
  802126:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802128:	83 c4 20             	add    $0x20,%esp
  80212b:	5e                   	pop    %esi
  80212c:	5f                   	pop    %edi
  80212d:	5d                   	pop    %ebp
  80212e:	c3                   	ret    
  80212f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802130:	39 f5                	cmp    %esi,%ebp
  802132:	0f 87 ac 00 00 00    	ja     8021e4 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802138:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  80213b:	83 f0 1f             	xor    $0x1f,%eax
  80213e:	89 44 24 10          	mov    %eax,0x10(%esp)
  802142:	0f 84 a8 00 00 00    	je     8021f0 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802148:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80214c:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80214e:	bf 20 00 00 00       	mov    $0x20,%edi
  802153:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802157:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80215b:	89 f9                	mov    %edi,%ecx
  80215d:	d3 e8                	shr    %cl,%eax
  80215f:	09 e8                	or     %ebp,%eax
  802161:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  802165:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802169:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80216d:	d3 e0                	shl    %cl,%eax
  80216f:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802173:	89 f2                	mov    %esi,%edx
  802175:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802177:	8b 44 24 14          	mov    0x14(%esp),%eax
  80217b:	d3 e0                	shl    %cl,%eax
  80217d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802181:	8b 44 24 14          	mov    0x14(%esp),%eax
  802185:	89 f9                	mov    %edi,%ecx
  802187:	d3 e8                	shr    %cl,%eax
  802189:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80218b:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80218d:	89 f2                	mov    %esi,%edx
  80218f:	f7 74 24 18          	divl   0x18(%esp)
  802193:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802195:	f7 64 24 0c          	mull   0xc(%esp)
  802199:	89 c5                	mov    %eax,%ebp
  80219b:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80219d:	39 d6                	cmp    %edx,%esi
  80219f:	72 67                	jb     802208 <__umoddi3+0x114>
  8021a1:	74 75                	je     802218 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8021a3:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8021a7:	29 e8                	sub    %ebp,%eax
  8021a9:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8021ab:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8021af:	d3 e8                	shr    %cl,%eax
  8021b1:	89 f2                	mov    %esi,%edx
  8021b3:	89 f9                	mov    %edi,%ecx
  8021b5:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8021b7:	09 d0                	or     %edx,%eax
  8021b9:	89 f2                	mov    %esi,%edx
  8021bb:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8021bf:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8021c1:	83 c4 20             	add    $0x20,%esp
  8021c4:	5e                   	pop    %esi
  8021c5:	5f                   	pop    %edi
  8021c6:	5d                   	pop    %ebp
  8021c7:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8021c8:	85 c9                	test   %ecx,%ecx
  8021ca:	75 0b                	jne    8021d7 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8021cc:	b8 01 00 00 00       	mov    $0x1,%eax
  8021d1:	31 d2                	xor    %edx,%edx
  8021d3:	f7 f1                	div    %ecx
  8021d5:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8021d7:	89 f0                	mov    %esi,%eax
  8021d9:	31 d2                	xor    %edx,%edx
  8021db:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8021dd:	89 f8                	mov    %edi,%eax
  8021df:	e9 3e ff ff ff       	jmp    802122 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8021e4:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8021e6:	83 c4 20             	add    $0x20,%esp
  8021e9:	5e                   	pop    %esi
  8021ea:	5f                   	pop    %edi
  8021eb:	5d                   	pop    %ebp
  8021ec:	c3                   	ret    
  8021ed:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8021f0:	39 f5                	cmp    %esi,%ebp
  8021f2:	72 04                	jb     8021f8 <__umoddi3+0x104>
  8021f4:	39 f9                	cmp    %edi,%ecx
  8021f6:	77 06                	ja     8021fe <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8021f8:	89 f2                	mov    %esi,%edx
  8021fa:	29 cf                	sub    %ecx,%edi
  8021fc:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8021fe:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802200:	83 c4 20             	add    $0x20,%esp
  802203:	5e                   	pop    %esi
  802204:	5f                   	pop    %edi
  802205:	5d                   	pop    %ebp
  802206:	c3                   	ret    
  802207:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802208:	89 d1                	mov    %edx,%ecx
  80220a:	89 c5                	mov    %eax,%ebp
  80220c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802210:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802214:	eb 8d                	jmp    8021a3 <__umoddi3+0xaf>
  802216:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802218:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  80221c:	72 ea                	jb     802208 <__umoddi3+0x114>
  80221e:	89 f1                	mov    %esi,%ecx
  802220:	eb 81                	jmp    8021a3 <__umoddi3+0xaf>
