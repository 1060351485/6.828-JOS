
obj/user/testfile.debug:     file format elf32-i386


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
  80002c:	e8 3b 07 00 00       	call   80076c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <xopen>:

#define FVA ((struct Fd*)0xCCCCC000)

static int
xopen(const char *path, int mode)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 14             	sub    $0x14,%esp
  80003b:	89 d3                	mov    %edx,%ebx
	extern union Fsipc fsipcbuf;
	envid_t fsenv;
	
	strcpy(fsipcbuf.open.req_path, path);
  80003d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800041:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800048:	e8 2a 0e 00 00       	call   800e77 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80004d:	89 1d 00 54 80 00    	mov    %ebx,0x805400

	fsenv = ipc_find_env(ENV_TYPE_FS);
  800053:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80005a:	e8 4c 15 00 00       	call   8015ab <ipc_find_env>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80005f:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800066:	00 
  800067:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  80006e:	00 
  80006f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800076:	00 
  800077:	89 04 24             	mov    %eax,(%esp)
  80007a:	e8 be 14 00 00       	call   80153d <ipc_send>
	return ipc_recv(NULL, FVA, NULL);
  80007f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800086:	00 
  800087:	c7 44 24 04 00 c0 cc 	movl   $0xccccc000,0x4(%esp)
  80008e:	cc 
  80008f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800096:	e8 39 14 00 00       	call   8014d4 <ipc_recv>
}
  80009b:	83 c4 14             	add    $0x14,%esp
  80009e:	5b                   	pop    %ebx
  80009f:	5d                   	pop    %ebp
  8000a0:	c3                   	ret    

008000a1 <umain>:

void
umain(int argc, char **argv)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	57                   	push   %edi
  8000a5:	56                   	push   %esi
  8000a6:	53                   	push   %ebx
  8000a7:	81 ec cc 02 00 00    	sub    $0x2cc,%esp
	struct Fd fdcopy;
	struct Stat st;
	char buf[512];

	// We open files manually first, to avoid the FD layer
	if ((r = xopen("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  8000ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8000b2:	b8 40 26 80 00       	mov    $0x802640,%eax
  8000b7:	e8 78 ff ff ff       	call   800034 <xopen>
  8000bc:	85 c0                	test   %eax,%eax
  8000be:	79 25                	jns    8000e5 <umain+0x44>
  8000c0:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8000c3:	74 3c                	je     800101 <umain+0x60>
		panic("serve_open /not-found: %e", r);
  8000c5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000c9:	c7 44 24 08 4b 26 80 	movl   $0x80264b,0x8(%esp)
  8000d0:	00 
  8000d1:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8000d8:	00 
  8000d9:	c7 04 24 65 26 80 00 	movl   $0x802665,(%esp)
  8000e0:	e8 ef 06 00 00       	call   8007d4 <_panic>
	else if (r >= 0)
		panic("serve_open /not-found succeeded!");
  8000e5:	c7 44 24 08 00 28 80 	movl   $0x802800,0x8(%esp)
  8000ec:	00 
  8000ed:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8000f4:	00 
  8000f5:	c7 04 24 65 26 80 00 	movl   $0x802665,(%esp)
  8000fc:	e8 d3 06 00 00       	call   8007d4 <_panic>

	if ((r = xopen("/newmotd", O_RDONLY)) < 0)
  800101:	ba 00 00 00 00       	mov    $0x0,%edx
  800106:	b8 75 26 80 00       	mov    $0x802675,%eax
  80010b:	e8 24 ff ff ff       	call   800034 <xopen>
  800110:	85 c0                	test   %eax,%eax
  800112:	79 20                	jns    800134 <umain+0x93>
		panic("serve_open /newmotd: %e", r);
  800114:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800118:	c7 44 24 08 7e 26 80 	movl   $0x80267e,0x8(%esp)
  80011f:	00 
  800120:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800127:	00 
  800128:	c7 04 24 65 26 80 00 	movl   $0x802665,(%esp)
  80012f:	e8 a0 06 00 00       	call   8007d4 <_panic>
	if (FVA->fd_dev_id != 'f' || FVA->fd_offset != 0 || FVA->fd_omode != O_RDONLY)
  800134:	83 3d 00 c0 cc cc 66 	cmpl   $0x66,0xccccc000
  80013b:	75 12                	jne    80014f <umain+0xae>
  80013d:	83 3d 04 c0 cc cc 00 	cmpl   $0x0,0xccccc004
  800144:	75 09                	jne    80014f <umain+0xae>
  800146:	83 3d 08 c0 cc cc 00 	cmpl   $0x0,0xccccc008
  80014d:	74 1c                	je     80016b <umain+0xca>
		panic("serve_open did not fill struct Fd correctly\n");
  80014f:	c7 44 24 08 24 28 80 	movl   $0x802824,0x8(%esp)
  800156:	00 
  800157:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  80015e:	00 
  80015f:	c7 04 24 65 26 80 00 	movl   $0x802665,(%esp)
  800166:	e8 69 06 00 00       	call   8007d4 <_panic>
	cprintf("serve_open is good\n");
  80016b:	c7 04 24 96 26 80 00 	movl   $0x802696,(%esp)
  800172:	e8 55 07 00 00       	call   8008cc <cprintf>

	if ((r = devfile.dev_stat(FVA, &st)) < 0)
  800177:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80017d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800181:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  800188:	ff 15 1c 30 80 00    	call   *0x80301c
  80018e:	85 c0                	test   %eax,%eax
  800190:	79 20                	jns    8001b2 <umain+0x111>
		panic("file_stat: %e", r);
  800192:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800196:	c7 44 24 08 aa 26 80 	movl   $0x8026aa,0x8(%esp)
  80019d:	00 
  80019e:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  8001a5:	00 
  8001a6:	c7 04 24 65 26 80 00 	movl   $0x802665,(%esp)
  8001ad:	e8 22 06 00 00       	call   8007d4 <_panic>
	if (strlen(msg) != st.st_size)
  8001b2:	a1 00 30 80 00       	mov    0x803000,%eax
  8001b7:	89 04 24             	mov    %eax,(%esp)
  8001ba:	e8 85 0c 00 00       	call   800e44 <strlen>
  8001bf:	3b 45 cc             	cmp    -0x34(%ebp),%eax
  8001c2:	74 34                	je     8001f8 <umain+0x157>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
  8001c4:	a1 00 30 80 00       	mov    0x803000,%eax
  8001c9:	89 04 24             	mov    %eax,(%esp)
  8001cc:	e8 73 0c 00 00       	call   800e44 <strlen>
  8001d1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001d5:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8001d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001dc:	c7 44 24 08 54 28 80 	movl   $0x802854,0x8(%esp)
  8001e3:	00 
  8001e4:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  8001eb:	00 
  8001ec:	c7 04 24 65 26 80 00 	movl   $0x802665,(%esp)
  8001f3:	e8 dc 05 00 00       	call   8007d4 <_panic>
	cprintf("file_stat is good\n");
  8001f8:	c7 04 24 b8 26 80 00 	movl   $0x8026b8,(%esp)
  8001ff:	e8 c8 06 00 00       	call   8008cc <cprintf>

	memset(buf, 0, sizeof buf);
  800204:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80020b:	00 
  80020c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800213:	00 
  800214:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  80021a:	89 1c 24             	mov    %ebx,(%esp)
  80021d:	e8 84 0d 00 00       	call   800fa6 <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  800222:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  800229:	00 
  80022a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80022e:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  800235:	ff 15 10 30 80 00    	call   *0x803010
  80023b:	85 c0                	test   %eax,%eax
  80023d:	79 20                	jns    80025f <umain+0x1be>
		panic("file_read: %e", r);
  80023f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800243:	c7 44 24 08 cb 26 80 	movl   $0x8026cb,0x8(%esp)
  80024a:	00 
  80024b:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
  800252:	00 
  800253:	c7 04 24 65 26 80 00 	movl   $0x802665,(%esp)
  80025a:	e8 75 05 00 00       	call   8007d4 <_panic>
	if (strcmp(buf, msg) != 0)
  80025f:	a1 00 30 80 00       	mov    0x803000,%eax
  800264:	89 44 24 04          	mov    %eax,0x4(%esp)
  800268:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  80026e:	89 04 24             	mov    %eax,(%esp)
  800271:	e8 a8 0c 00 00       	call   800f1e <strcmp>
  800276:	85 c0                	test   %eax,%eax
  800278:	74 1c                	je     800296 <umain+0x1f5>
		panic("file_read returned wrong data");
  80027a:	c7 44 24 08 d9 26 80 	movl   $0x8026d9,0x8(%esp)
  800281:	00 
  800282:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  800289:	00 
  80028a:	c7 04 24 65 26 80 00 	movl   $0x802665,(%esp)
  800291:	e8 3e 05 00 00       	call   8007d4 <_panic>
	cprintf("file_read is good\n");
  800296:	c7 04 24 f7 26 80 00 	movl   $0x8026f7,(%esp)
  80029d:	e8 2a 06 00 00       	call   8008cc <cprintf>

	if ((r = devfile.dev_close(FVA)) < 0)
  8002a2:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  8002a9:	ff 15 18 30 80 00    	call   *0x803018
  8002af:	85 c0                	test   %eax,%eax
  8002b1:	79 20                	jns    8002d3 <umain+0x232>
		panic("file_close: %e", r);
  8002b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002b7:	c7 44 24 08 0a 27 80 	movl   $0x80270a,0x8(%esp)
  8002be:	00 
  8002bf:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
  8002c6:	00 
  8002c7:	c7 04 24 65 26 80 00 	movl   $0x802665,(%esp)
  8002ce:	e8 01 05 00 00       	call   8007d4 <_panic>
	cprintf("file_close is good\n");
  8002d3:	c7 04 24 19 27 80 00 	movl   $0x802719,(%esp)
  8002da:	e8 ed 05 00 00       	call   8008cc <cprintf>

	// We're about to unmap the FD, but still need a way to get
	// the stale filenum to serve_read, so we make a local copy.
	// The file server won't think it's stale until we unmap the
	// FD page.
	fdcopy = *FVA;
  8002df:	be 00 c0 cc cc       	mov    $0xccccc000,%esi
  8002e4:	8d 7d d8             	lea    -0x28(%ebp),%edi
  8002e7:	b9 04 00 00 00       	mov    $0x4,%ecx
  8002ec:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	sys_page_unmap(0, FVA);
  8002ee:	c7 44 24 04 00 c0 cc 	movl   $0xccccc000,0x4(%esp)
  8002f5:	cc 
  8002f6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002fd:	e8 0e 10 00 00       	call   801310 <sys_page_unmap>

	if ((r = devfile.dev_read(&fdcopy, buf, sizeof buf)) != -E_INVAL)
  800302:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  800309:	00 
  80030a:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  800310:	89 44 24 04          	mov    %eax,0x4(%esp)
  800314:	8d 45 d8             	lea    -0x28(%ebp),%eax
  800317:	89 04 24             	mov    %eax,(%esp)
  80031a:	ff 15 10 30 80 00    	call   *0x803010
  800320:	83 f8 fd             	cmp    $0xfffffffd,%eax
  800323:	74 20                	je     800345 <umain+0x2a4>
		panic("serve_read does not handle stale fileids correctly: %e", r);
  800325:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800329:	c7 44 24 08 7c 28 80 	movl   $0x80287c,0x8(%esp)
  800330:	00 
  800331:	c7 44 24 04 43 00 00 	movl   $0x43,0x4(%esp)
  800338:	00 
  800339:	c7 04 24 65 26 80 00 	movl   $0x802665,(%esp)
  800340:	e8 8f 04 00 00       	call   8007d4 <_panic>
	cprintf("stale fileid is good\n");
  800345:	c7 04 24 2d 27 80 00 	movl   $0x80272d,(%esp)
  80034c:	e8 7b 05 00 00       	call   8008cc <cprintf>

	// Try writing
	if ((r = xopen("/new-file", O_RDWR|O_CREAT)) < 0)
  800351:	ba 02 01 00 00       	mov    $0x102,%edx
  800356:	b8 43 27 80 00       	mov    $0x802743,%eax
  80035b:	e8 d4 fc ff ff       	call   800034 <xopen>
  800360:	85 c0                	test   %eax,%eax
  800362:	79 20                	jns    800384 <umain+0x2e3>
		panic("serve_open /new-file: %e", r);
  800364:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800368:	c7 44 24 08 4d 27 80 	movl   $0x80274d,0x8(%esp)
  80036f:	00 
  800370:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  800377:	00 
  800378:	c7 04 24 65 26 80 00 	movl   $0x802665,(%esp)
  80037f:	e8 50 04 00 00       	call   8007d4 <_panic>

	if ((r = devfile.dev_write(FVA, msg, strlen(msg))) != strlen(msg))
  800384:	8b 1d 14 30 80 00    	mov    0x803014,%ebx
  80038a:	a1 00 30 80 00       	mov    0x803000,%eax
  80038f:	89 04 24             	mov    %eax,(%esp)
  800392:	e8 ad 0a 00 00       	call   800e44 <strlen>
  800397:	89 44 24 08          	mov    %eax,0x8(%esp)
  80039b:	a1 00 30 80 00       	mov    0x803000,%eax
  8003a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003a4:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  8003ab:	ff d3                	call   *%ebx
  8003ad:	89 c3                	mov    %eax,%ebx
  8003af:	a1 00 30 80 00       	mov    0x803000,%eax
  8003b4:	89 04 24             	mov    %eax,(%esp)
  8003b7:	e8 88 0a 00 00       	call   800e44 <strlen>
  8003bc:	39 c3                	cmp    %eax,%ebx
  8003be:	74 20                	je     8003e0 <umain+0x33f>
		panic("file_write: %e", r);
  8003c0:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003c4:	c7 44 24 08 66 27 80 	movl   $0x802766,0x8(%esp)
  8003cb:	00 
  8003cc:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  8003d3:	00 
  8003d4:	c7 04 24 65 26 80 00 	movl   $0x802665,(%esp)
  8003db:	e8 f4 03 00 00       	call   8007d4 <_panic>
	cprintf("file_write is good\n");
  8003e0:	c7 04 24 75 27 80 00 	movl   $0x802775,(%esp)
  8003e7:	e8 e0 04 00 00       	call   8008cc <cprintf>

	FVA->fd_offset = 0;
  8003ec:	c7 05 04 c0 cc cc 00 	movl   $0x0,0xccccc004
  8003f3:	00 00 00 
	memset(buf, 0, sizeof buf);
  8003f6:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8003fd:	00 
  8003fe:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800405:	00 
  800406:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  80040c:	89 1c 24             	mov    %ebx,(%esp)
  80040f:	e8 92 0b 00 00       	call   800fa6 <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  800414:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80041b:	00 
  80041c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800420:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  800427:	ff 15 10 30 80 00    	call   *0x803010
  80042d:	89 c3                	mov    %eax,%ebx
  80042f:	85 c0                	test   %eax,%eax
  800431:	79 20                	jns    800453 <umain+0x3b2>
		panic("file_read after file_write: %e", r);
  800433:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800437:	c7 44 24 08 b4 28 80 	movl   $0x8028b4,0x8(%esp)
  80043e:	00 
  80043f:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  800446:	00 
  800447:	c7 04 24 65 26 80 00 	movl   $0x802665,(%esp)
  80044e:	e8 81 03 00 00       	call   8007d4 <_panic>
	if (r != strlen(msg))
  800453:	a1 00 30 80 00       	mov    0x803000,%eax
  800458:	89 04 24             	mov    %eax,(%esp)
  80045b:	e8 e4 09 00 00       	call   800e44 <strlen>
  800460:	39 d8                	cmp    %ebx,%eax
  800462:	74 20                	je     800484 <umain+0x3e3>
		panic("file_read after file_write returned wrong length: %d", r);
  800464:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800468:	c7 44 24 08 d4 28 80 	movl   $0x8028d4,0x8(%esp)
  80046f:	00 
  800470:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  800477:	00 
  800478:	c7 04 24 65 26 80 00 	movl   $0x802665,(%esp)
  80047f:	e8 50 03 00 00       	call   8007d4 <_panic>
	if (strcmp(buf, msg) != 0)
  800484:	a1 00 30 80 00       	mov    0x803000,%eax
  800489:	89 44 24 04          	mov    %eax,0x4(%esp)
  80048d:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  800493:	89 04 24             	mov    %eax,(%esp)
  800496:	e8 83 0a 00 00       	call   800f1e <strcmp>
  80049b:	85 c0                	test   %eax,%eax
  80049d:	74 1c                	je     8004bb <umain+0x41a>
		panic("file_read after file_write returned wrong data");
  80049f:	c7 44 24 08 0c 29 80 	movl   $0x80290c,0x8(%esp)
  8004a6:	00 
  8004a7:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
  8004ae:	00 
  8004af:	c7 04 24 65 26 80 00 	movl   $0x802665,(%esp)
  8004b6:	e8 19 03 00 00       	call   8007d4 <_panic>
	cprintf("file_read after file_write is good\n");
  8004bb:	c7 04 24 3c 29 80 00 	movl   $0x80293c,(%esp)
  8004c2:	e8 05 04 00 00       	call   8008cc <cprintf>

	// Now we'll try out open
	if ((r = open("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  8004c7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8004ce:	00 
  8004cf:	c7 04 24 40 26 80 00 	movl   $0x802640,(%esp)
  8004d6:	e8 05 19 00 00       	call   801de0 <open>
  8004db:	85 c0                	test   %eax,%eax
  8004dd:	79 25                	jns    800504 <umain+0x463>
  8004df:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8004e2:	74 3c                	je     800520 <umain+0x47f>
		panic("open /not-found: %e", r);
  8004e4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004e8:	c7 44 24 08 51 26 80 	movl   $0x802651,0x8(%esp)
  8004ef:	00 
  8004f0:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  8004f7:	00 
  8004f8:	c7 04 24 65 26 80 00 	movl   $0x802665,(%esp)
  8004ff:	e8 d0 02 00 00       	call   8007d4 <_panic>
	else if (r >= 0)
		panic("open /not-found succeeded!");
  800504:	c7 44 24 08 89 27 80 	movl   $0x802789,0x8(%esp)
  80050b:	00 
  80050c:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  800513:	00 
  800514:	c7 04 24 65 26 80 00 	movl   $0x802665,(%esp)
  80051b:	e8 b4 02 00 00       	call   8007d4 <_panic>

	if ((r = open("/newmotd", O_RDONLY)) < 0)
  800520:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800527:	00 
  800528:	c7 04 24 75 26 80 00 	movl   $0x802675,(%esp)
  80052f:	e8 ac 18 00 00       	call   801de0 <open>
  800534:	85 c0                	test   %eax,%eax
  800536:	79 20                	jns    800558 <umain+0x4b7>
		panic("open /newmotd: %e", r);
  800538:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80053c:	c7 44 24 08 84 26 80 	movl   $0x802684,0x8(%esp)
  800543:	00 
  800544:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
  80054b:	00 
  80054c:	c7 04 24 65 26 80 00 	movl   $0x802665,(%esp)
  800553:	e8 7c 02 00 00       	call   8007d4 <_panic>
	fd = (struct Fd*) (0xD0000000 + r*PGSIZE);
  800558:	05 00 00 0d 00       	add    $0xd0000,%eax
  80055d:	c1 e0 0c             	shl    $0xc,%eax
	if (fd->fd_dev_id != 'f' || fd->fd_offset != 0 || fd->fd_omode != O_RDONLY)
  800560:	83 38 66             	cmpl   $0x66,(%eax)
  800563:	75 0c                	jne    800571 <umain+0x4d0>
  800565:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
  800569:	75 06                	jne    800571 <umain+0x4d0>
  80056b:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
  80056f:	74 1c                	je     80058d <umain+0x4ec>
		panic("open did not fill struct Fd correctly\n");
  800571:	c7 44 24 08 60 29 80 	movl   $0x802960,0x8(%esp)
  800578:	00 
  800579:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  800580:	00 
  800581:	c7 04 24 65 26 80 00 	movl   $0x802665,(%esp)
  800588:	e8 47 02 00 00       	call   8007d4 <_panic>
	cprintf("open is good\n");
  80058d:	c7 04 24 9c 26 80 00 	movl   $0x80269c,(%esp)
  800594:	e8 33 03 00 00       	call   8008cc <cprintf>

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
  800599:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
  8005a0:	00 
  8005a1:	c7 04 24 a4 27 80 00 	movl   $0x8027a4,(%esp)
  8005a8:	e8 33 18 00 00       	call   801de0 <open>
  8005ad:	89 c7                	mov    %eax,%edi
  8005af:	85 c0                	test   %eax,%eax
  8005b1:	79 20                	jns    8005d3 <umain+0x532>
		panic("creat /big: %e", f);
  8005b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005b7:	c7 44 24 08 a9 27 80 	movl   $0x8027a9,0x8(%esp)
  8005be:	00 
  8005bf:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
  8005c6:	00 
  8005c7:	c7 04 24 65 26 80 00 	movl   $0x802665,(%esp)
  8005ce:	e8 01 02 00 00       	call   8007d4 <_panic>
	memset(buf, 0, sizeof(buf));
  8005d3:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8005da:	00 
  8005db:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8005e2:	00 
  8005e3:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8005e9:	89 04 24             	mov    %eax,(%esp)
  8005ec:	e8 b5 09 00 00       	call   800fa6 <memset>
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  8005f1:	be 00 00 00 00       	mov    $0x0,%esi
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
  8005f6:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  8005fc:	89 b5 4c fd ff ff    	mov    %esi,-0x2b4(%ebp)
		if ((r = write(f, buf, sizeof(buf))) < 0)
  800602:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  800609:	00 
  80060a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80060e:	89 3c 24             	mov    %edi,(%esp)
  800611:	e8 cf 13 00 00       	call   8019e5 <write>
  800616:	85 c0                	test   %eax,%eax
  800618:	79 24                	jns    80063e <umain+0x59d>
			panic("write /big@%d: %e", i, r);
  80061a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80061e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800622:	c7 44 24 08 b8 27 80 	movl   $0x8027b8,0x8(%esp)
  800629:	00 
  80062a:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  800631:	00 
  800632:	c7 04 24 65 26 80 00 	movl   $0x802665,(%esp)
  800639:	e8 96 01 00 00       	call   8007d4 <_panic>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
	return ipc_recv(NULL, FVA, NULL);
}

void
umain(int argc, char **argv)
  80063e:	8d 86 00 02 00 00    	lea    0x200(%esi),%eax
  800644:	89 c6                	mov    %eax,%esi

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  800646:	3d 00 e0 01 00       	cmp    $0x1e000,%eax
  80064b:	75 af                	jne    8005fc <umain+0x55b>
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
			panic("write /big@%d: %e", i, r);
	}
	close(f);
  80064d:	89 3c 24             	mov    %edi,(%esp)
  800650:	e8 51 11 00 00       	call   8017a6 <close>

	if ((f = open("/big", O_RDONLY)) < 0)
  800655:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80065c:	00 
  80065d:	c7 04 24 a4 27 80 00 	movl   $0x8027a4,(%esp)
  800664:	e8 77 17 00 00       	call   801de0 <open>
  800669:	89 c3                	mov    %eax,%ebx
  80066b:	85 c0                	test   %eax,%eax
  80066d:	79 20                	jns    80068f <umain+0x5ee>
		panic("open /big: %e", f);
  80066f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800673:	c7 44 24 08 ca 27 80 	movl   $0x8027ca,0x8(%esp)
  80067a:	00 
  80067b:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
  800682:	00 
  800683:	c7 04 24 65 26 80 00 	movl   $0x802665,(%esp)
  80068a:	e8 45 01 00 00       	call   8007d4 <_panic>
		if ((r = write(f, buf, sizeof(buf))) < 0)
			panic("write /big@%d: %e", i, r);
	}
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
  80068f:	be 00 00 00 00       	mov    $0x0,%esi
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  800694:	8d bd 4c fd ff ff    	lea    -0x2b4(%ebp),%edi
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  80069a:	89 b5 4c fd ff ff    	mov    %esi,-0x2b4(%ebp)
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  8006a0:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8006a7:	00 
  8006a8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006ac:	89 1c 24             	mov    %ebx,(%esp)
  8006af:	e8 e6 12 00 00       	call   80199a <readn>
  8006b4:	85 c0                	test   %eax,%eax
  8006b6:	79 24                	jns    8006dc <umain+0x63b>
			panic("read /big@%d: %e", i, r);
  8006b8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006bc:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8006c0:	c7 44 24 08 d8 27 80 	movl   $0x8027d8,0x8(%esp)
  8006c7:	00 
  8006c8:	c7 44 24 04 75 00 00 	movl   $0x75,0x4(%esp)
  8006cf:	00 
  8006d0:	c7 04 24 65 26 80 00 	movl   $0x802665,(%esp)
  8006d7:	e8 f8 00 00 00       	call   8007d4 <_panic>
		if (r != sizeof(buf))
  8006dc:	3d 00 02 00 00       	cmp    $0x200,%eax
  8006e1:	74 2c                	je     80070f <umain+0x66e>
			panic("read /big from %d returned %d < %d bytes",
  8006e3:	c7 44 24 14 00 02 00 	movl   $0x200,0x14(%esp)
  8006ea:	00 
  8006eb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006ef:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8006f3:	c7 44 24 08 88 29 80 	movl   $0x802988,0x8(%esp)
  8006fa:	00 
  8006fb:	c7 44 24 04 78 00 00 	movl   $0x78,0x4(%esp)
  800702:	00 
  800703:	c7 04 24 65 26 80 00 	movl   $0x802665,(%esp)
  80070a:	e8 c5 00 00 00       	call   8007d4 <_panic>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
  80070f:	8b 07                	mov    (%edi),%eax
  800711:	39 f0                	cmp    %esi,%eax
  800713:	74 24                	je     800739 <umain+0x698>
			panic("read /big from %d returned bad data %d",
  800715:	89 44 24 10          	mov    %eax,0x10(%esp)
  800719:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80071d:	c7 44 24 08 b4 29 80 	movl   $0x8029b4,0x8(%esp)
  800724:	00 
  800725:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  80072c:	00 
  80072d:	c7 04 24 65 26 80 00 	movl   $0x802665,(%esp)
  800734:	e8 9b 00 00 00       	call   8007d4 <_panic>
	}
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  800739:	8d b0 00 02 00 00    	lea    0x200(%eax),%esi
  80073f:	81 fe ff df 01 00    	cmp    $0x1dfff,%esi
  800745:	0f 8e 4f ff ff ff    	jle    80069a <umain+0x5f9>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
			panic("read /big from %d returned bad data %d",
			      i, *(int*)buf);
	}
	close(f);
  80074b:	89 1c 24             	mov    %ebx,(%esp)
  80074e:	e8 53 10 00 00       	call   8017a6 <close>
	cprintf("large file is good\n");
  800753:	c7 04 24 e9 27 80 00 	movl   $0x8027e9,(%esp)
  80075a:	e8 6d 01 00 00       	call   8008cc <cprintf>
}
  80075f:	81 c4 cc 02 00 00    	add    $0x2cc,%esp
  800765:	5b                   	pop    %ebx
  800766:	5e                   	pop    %esi
  800767:	5f                   	pop    %edi
  800768:	5d                   	pop    %ebp
  800769:	c3                   	ret    
	...

0080076c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80076c:	55                   	push   %ebp
  80076d:	89 e5                	mov    %esp,%ebp
  80076f:	56                   	push   %esi
  800770:	53                   	push   %ebx
  800771:	83 ec 10             	sub    $0x10,%esp
  800774:	8b 75 08             	mov    0x8(%ebp),%esi
  800777:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80077a:	e8 ac 0a 00 00       	call   80122b <sys_getenvid>
  80077f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800784:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80078b:	c1 e0 07             	shl    $0x7,%eax
  80078e:	29 d0                	sub    %edx,%eax
  800790:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800795:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80079a:	85 f6                	test   %esi,%esi
  80079c:	7e 07                	jle    8007a5 <libmain+0x39>
		binaryname = argv[0];
  80079e:	8b 03                	mov    (%ebx),%eax
  8007a0:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8007a5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a9:	89 34 24             	mov    %esi,(%esp)
  8007ac:	e8 f0 f8 ff ff       	call   8000a1 <umain>

	// exit gracefully
	exit();
  8007b1:	e8 0a 00 00 00       	call   8007c0 <exit>
}
  8007b6:	83 c4 10             	add    $0x10,%esp
  8007b9:	5b                   	pop    %ebx
  8007ba:	5e                   	pop    %esi
  8007bb:	5d                   	pop    %ebp
  8007bc:	c3                   	ret    
  8007bd:	00 00                	add    %al,(%eax)
	...

008007c0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  8007c6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8007cd:	e8 07 0a 00 00       	call   8011d9 <sys_env_destroy>
}
  8007d2:	c9                   	leave  
  8007d3:	c3                   	ret    

008007d4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8007d4:	55                   	push   %ebp
  8007d5:	89 e5                	mov    %esp,%ebp
  8007d7:	56                   	push   %esi
  8007d8:	53                   	push   %ebx
  8007d9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8007dc:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8007df:	8b 1d 04 30 80 00    	mov    0x803004,%ebx
  8007e5:	e8 41 0a 00 00       	call   80122b <sys_getenvid>
  8007ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ed:	89 54 24 10          	mov    %edx,0x10(%esp)
  8007f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8007f4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007f8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8007fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800800:	c7 04 24 0c 2a 80 00 	movl   $0x802a0c,(%esp)
  800807:	e8 c0 00 00 00       	call   8008cc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80080c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800810:	8b 45 10             	mov    0x10(%ebp),%eax
  800813:	89 04 24             	mov    %eax,(%esp)
  800816:	e8 50 00 00 00       	call   80086b <vcprintf>
	cprintf("\n");
  80081b:	c7 04 24 77 2e 80 00 	movl   $0x802e77,(%esp)
  800822:	e8 a5 00 00 00       	call   8008cc <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800827:	cc                   	int3   
  800828:	eb fd                	jmp    800827 <_panic+0x53>
	...

0080082c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80082c:	55                   	push   %ebp
  80082d:	89 e5                	mov    %esp,%ebp
  80082f:	53                   	push   %ebx
  800830:	83 ec 14             	sub    $0x14,%esp
  800833:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800836:	8b 03                	mov    (%ebx),%eax
  800838:	8b 55 08             	mov    0x8(%ebp),%edx
  80083b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80083f:	40                   	inc    %eax
  800840:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800842:	3d ff 00 00 00       	cmp    $0xff,%eax
  800847:	75 19                	jne    800862 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800849:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800850:	00 
  800851:	8d 43 08             	lea    0x8(%ebx),%eax
  800854:	89 04 24             	mov    %eax,(%esp)
  800857:	e8 40 09 00 00       	call   80119c <sys_cputs>
		b->idx = 0;
  80085c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800862:	ff 43 04             	incl   0x4(%ebx)
}
  800865:	83 c4 14             	add    $0x14,%esp
  800868:	5b                   	pop    %ebx
  800869:	5d                   	pop    %ebp
  80086a:	c3                   	ret    

0080086b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80086b:	55                   	push   %ebp
  80086c:	89 e5                	mov    %esp,%ebp
  80086e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800874:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80087b:	00 00 00 
	b.cnt = 0;
  80087e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800885:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800888:	8b 45 0c             	mov    0xc(%ebp),%eax
  80088b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80088f:	8b 45 08             	mov    0x8(%ebp),%eax
  800892:	89 44 24 08          	mov    %eax,0x8(%esp)
  800896:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80089c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008a0:	c7 04 24 2c 08 80 00 	movl   $0x80082c,(%esp)
  8008a7:	e8 82 01 00 00       	call   800a2e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8008ac:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8008b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8008bc:	89 04 24             	mov    %eax,(%esp)
  8008bf:	e8 d8 08 00 00       	call   80119c <sys_cputs>

	return b.cnt;
}
  8008c4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8008ca:	c9                   	leave  
  8008cb:	c3                   	ret    

008008cc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8008cc:	55                   	push   %ebp
  8008cd:	89 e5                	mov    %esp,%ebp
  8008cf:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8008d2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8008d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008dc:	89 04 24             	mov    %eax,(%esp)
  8008df:	e8 87 ff ff ff       	call   80086b <vcprintf>
	va_end(ap);

	return cnt;
}
  8008e4:	c9                   	leave  
  8008e5:	c3                   	ret    
	...

008008e8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	57                   	push   %edi
  8008ec:	56                   	push   %esi
  8008ed:	53                   	push   %ebx
  8008ee:	83 ec 3c             	sub    $0x3c,%esp
  8008f1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008f4:	89 d7                	mov    %edx,%edi
  8008f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8008fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ff:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800902:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800905:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800908:	85 c0                	test   %eax,%eax
  80090a:	75 08                	jne    800914 <printnum+0x2c>
  80090c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80090f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800912:	77 57                	ja     80096b <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800914:	89 74 24 10          	mov    %esi,0x10(%esp)
  800918:	4b                   	dec    %ebx
  800919:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80091d:	8b 45 10             	mov    0x10(%ebp),%eax
  800920:	89 44 24 08          	mov    %eax,0x8(%esp)
  800924:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800928:	8b 74 24 0c          	mov    0xc(%esp),%esi
  80092c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800933:	00 
  800934:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800937:	89 04 24             	mov    %eax,(%esp)
  80093a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80093d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800941:	e8 96 1a 00 00       	call   8023dc <__udivdi3>
  800946:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80094a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80094e:	89 04 24             	mov    %eax,(%esp)
  800951:	89 54 24 04          	mov    %edx,0x4(%esp)
  800955:	89 fa                	mov    %edi,%edx
  800957:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80095a:	e8 89 ff ff ff       	call   8008e8 <printnum>
  80095f:	eb 0f                	jmp    800970 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800961:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800965:	89 34 24             	mov    %esi,(%esp)
  800968:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80096b:	4b                   	dec    %ebx
  80096c:	85 db                	test   %ebx,%ebx
  80096e:	7f f1                	jg     800961 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800970:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800974:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800978:	8b 45 10             	mov    0x10(%ebp),%eax
  80097b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80097f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800986:	00 
  800987:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80098a:	89 04 24             	mov    %eax,(%esp)
  80098d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800990:	89 44 24 04          	mov    %eax,0x4(%esp)
  800994:	e8 63 1b 00 00       	call   8024fc <__umoddi3>
  800999:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80099d:	0f be 80 2f 2a 80 00 	movsbl 0x802a2f(%eax),%eax
  8009a4:	89 04 24             	mov    %eax,(%esp)
  8009a7:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8009aa:	83 c4 3c             	add    $0x3c,%esp
  8009ad:	5b                   	pop    %ebx
  8009ae:	5e                   	pop    %esi
  8009af:	5f                   	pop    %edi
  8009b0:	5d                   	pop    %ebp
  8009b1:	c3                   	ret    

008009b2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8009b5:	83 fa 01             	cmp    $0x1,%edx
  8009b8:	7e 0e                	jle    8009c8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8009ba:	8b 10                	mov    (%eax),%edx
  8009bc:	8d 4a 08             	lea    0x8(%edx),%ecx
  8009bf:	89 08                	mov    %ecx,(%eax)
  8009c1:	8b 02                	mov    (%edx),%eax
  8009c3:	8b 52 04             	mov    0x4(%edx),%edx
  8009c6:	eb 22                	jmp    8009ea <getuint+0x38>
	else if (lflag)
  8009c8:	85 d2                	test   %edx,%edx
  8009ca:	74 10                	je     8009dc <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8009cc:	8b 10                	mov    (%eax),%edx
  8009ce:	8d 4a 04             	lea    0x4(%edx),%ecx
  8009d1:	89 08                	mov    %ecx,(%eax)
  8009d3:	8b 02                	mov    (%edx),%eax
  8009d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8009da:	eb 0e                	jmp    8009ea <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8009dc:	8b 10                	mov    (%eax),%edx
  8009de:	8d 4a 04             	lea    0x4(%edx),%ecx
  8009e1:	89 08                	mov    %ecx,(%eax)
  8009e3:	8b 02                	mov    (%edx),%eax
  8009e5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8009ea:	5d                   	pop    %ebp
  8009eb:	c3                   	ret    

008009ec <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8009ec:	55                   	push   %ebp
  8009ed:	89 e5                	mov    %esp,%ebp
  8009ef:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8009f2:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8009f5:	8b 10                	mov    (%eax),%edx
  8009f7:	3b 50 04             	cmp    0x4(%eax),%edx
  8009fa:	73 08                	jae    800a04 <sprintputch+0x18>
		*b->buf++ = ch;
  8009fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ff:	88 0a                	mov    %cl,(%edx)
  800a01:	42                   	inc    %edx
  800a02:	89 10                	mov    %edx,(%eax)
}
  800a04:	5d                   	pop    %ebp
  800a05:	c3                   	ret    

00800a06 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800a0c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800a0f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a13:	8b 45 10             	mov    0x10(%ebp),%eax
  800a16:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a21:	8b 45 08             	mov    0x8(%ebp),%eax
  800a24:	89 04 24             	mov    %eax,(%esp)
  800a27:	e8 02 00 00 00       	call   800a2e <vprintfmt>
	va_end(ap);
}
  800a2c:	c9                   	leave  
  800a2d:	c3                   	ret    

00800a2e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800a2e:	55                   	push   %ebp
  800a2f:	89 e5                	mov    %esp,%ebp
  800a31:	57                   	push   %edi
  800a32:	56                   	push   %esi
  800a33:	53                   	push   %ebx
  800a34:	83 ec 4c             	sub    $0x4c,%esp
  800a37:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a3a:	8b 75 10             	mov    0x10(%ebp),%esi
  800a3d:	eb 12                	jmp    800a51 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800a3f:	85 c0                	test   %eax,%eax
  800a41:	0f 84 6b 03 00 00    	je     800db2 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800a47:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a4b:	89 04 24             	mov    %eax,(%esp)
  800a4e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800a51:	0f b6 06             	movzbl (%esi),%eax
  800a54:	46                   	inc    %esi
  800a55:	83 f8 25             	cmp    $0x25,%eax
  800a58:	75 e5                	jne    800a3f <vprintfmt+0x11>
  800a5a:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800a5e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800a65:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800a6a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800a71:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a76:	eb 26                	jmp    800a9e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a78:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800a7b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800a7f:	eb 1d                	jmp    800a9e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a81:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800a84:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800a88:	eb 14                	jmp    800a9e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a8a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800a8d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800a94:	eb 08                	jmp    800a9e <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800a96:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800a99:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a9e:	0f b6 06             	movzbl (%esi),%eax
  800aa1:	8d 56 01             	lea    0x1(%esi),%edx
  800aa4:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800aa7:	8a 16                	mov    (%esi),%dl
  800aa9:	83 ea 23             	sub    $0x23,%edx
  800aac:	80 fa 55             	cmp    $0x55,%dl
  800aaf:	0f 87 e1 02 00 00    	ja     800d96 <vprintfmt+0x368>
  800ab5:	0f b6 d2             	movzbl %dl,%edx
  800ab8:	ff 24 95 80 2b 80 00 	jmp    *0x802b80(,%edx,4)
  800abf:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800ac2:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800ac7:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800aca:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800ace:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800ad1:	8d 50 d0             	lea    -0x30(%eax),%edx
  800ad4:	83 fa 09             	cmp    $0x9,%edx
  800ad7:	77 2a                	ja     800b03 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800ad9:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800ada:	eb eb                	jmp    800ac7 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800adc:	8b 45 14             	mov    0x14(%ebp),%eax
  800adf:	8d 50 04             	lea    0x4(%eax),%edx
  800ae2:	89 55 14             	mov    %edx,0x14(%ebp)
  800ae5:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ae7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800aea:	eb 17                	jmp    800b03 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800aec:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800af0:	78 98                	js     800a8a <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800af2:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800af5:	eb a7                	jmp    800a9e <vprintfmt+0x70>
  800af7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800afa:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800b01:	eb 9b                	jmp    800a9e <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800b03:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800b07:	79 95                	jns    800a9e <vprintfmt+0x70>
  800b09:	eb 8b                	jmp    800a96 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800b0b:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b0c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800b0f:	eb 8d                	jmp    800a9e <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800b11:	8b 45 14             	mov    0x14(%ebp),%eax
  800b14:	8d 50 04             	lea    0x4(%eax),%edx
  800b17:	89 55 14             	mov    %edx,0x14(%ebp)
  800b1a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b1e:	8b 00                	mov    (%eax),%eax
  800b20:	89 04 24             	mov    %eax,(%esp)
  800b23:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b26:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800b29:	e9 23 ff ff ff       	jmp    800a51 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800b2e:	8b 45 14             	mov    0x14(%ebp),%eax
  800b31:	8d 50 04             	lea    0x4(%eax),%edx
  800b34:	89 55 14             	mov    %edx,0x14(%ebp)
  800b37:	8b 00                	mov    (%eax),%eax
  800b39:	85 c0                	test   %eax,%eax
  800b3b:	79 02                	jns    800b3f <vprintfmt+0x111>
  800b3d:	f7 d8                	neg    %eax
  800b3f:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800b41:	83 f8 0f             	cmp    $0xf,%eax
  800b44:	7f 0b                	jg     800b51 <vprintfmt+0x123>
  800b46:	8b 04 85 e0 2c 80 00 	mov    0x802ce0(,%eax,4),%eax
  800b4d:	85 c0                	test   %eax,%eax
  800b4f:	75 23                	jne    800b74 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800b51:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800b55:	c7 44 24 08 47 2a 80 	movl   $0x802a47,0x8(%esp)
  800b5c:	00 
  800b5d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b61:	8b 45 08             	mov    0x8(%ebp),%eax
  800b64:	89 04 24             	mov    %eax,(%esp)
  800b67:	e8 9a fe ff ff       	call   800a06 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b6c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800b6f:	e9 dd fe ff ff       	jmp    800a51 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800b74:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b78:	c7 44 24 08 45 2e 80 	movl   $0x802e45,0x8(%esp)
  800b7f:	00 
  800b80:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b84:	8b 55 08             	mov    0x8(%ebp),%edx
  800b87:	89 14 24             	mov    %edx,(%esp)
  800b8a:	e8 77 fe ff ff       	call   800a06 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b8f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800b92:	e9 ba fe ff ff       	jmp    800a51 <vprintfmt+0x23>
  800b97:	89 f9                	mov    %edi,%ecx
  800b99:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800b9c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800b9f:	8b 45 14             	mov    0x14(%ebp),%eax
  800ba2:	8d 50 04             	lea    0x4(%eax),%edx
  800ba5:	89 55 14             	mov    %edx,0x14(%ebp)
  800ba8:	8b 30                	mov    (%eax),%esi
  800baa:	85 f6                	test   %esi,%esi
  800bac:	75 05                	jne    800bb3 <vprintfmt+0x185>
				p = "(null)";
  800bae:	be 40 2a 80 00       	mov    $0x802a40,%esi
			if (width > 0 && padc != '-')
  800bb3:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800bb7:	0f 8e 84 00 00 00    	jle    800c41 <vprintfmt+0x213>
  800bbd:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800bc1:	74 7e                	je     800c41 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800bc3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800bc7:	89 34 24             	mov    %esi,(%esp)
  800bca:	e8 8b 02 00 00       	call   800e5a <strnlen>
  800bcf:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800bd2:	29 c2                	sub    %eax,%edx
  800bd4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800bd7:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800bdb:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800bde:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800be1:	89 de                	mov    %ebx,%esi
  800be3:	89 d3                	mov    %edx,%ebx
  800be5:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800be7:	eb 0b                	jmp    800bf4 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800be9:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bed:	89 3c 24             	mov    %edi,(%esp)
  800bf0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800bf3:	4b                   	dec    %ebx
  800bf4:	85 db                	test   %ebx,%ebx
  800bf6:	7f f1                	jg     800be9 <vprintfmt+0x1bb>
  800bf8:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800bfb:	89 f3                	mov    %esi,%ebx
  800bfd:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800c00:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c03:	85 c0                	test   %eax,%eax
  800c05:	79 05                	jns    800c0c <vprintfmt+0x1de>
  800c07:	b8 00 00 00 00       	mov    $0x0,%eax
  800c0c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800c0f:	29 c2                	sub    %eax,%edx
  800c11:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800c14:	eb 2b                	jmp    800c41 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800c16:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800c1a:	74 18                	je     800c34 <vprintfmt+0x206>
  800c1c:	8d 50 e0             	lea    -0x20(%eax),%edx
  800c1f:	83 fa 5e             	cmp    $0x5e,%edx
  800c22:	76 10                	jbe    800c34 <vprintfmt+0x206>
					putch('?', putdat);
  800c24:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c28:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800c2f:	ff 55 08             	call   *0x8(%ebp)
  800c32:	eb 0a                	jmp    800c3e <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800c34:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c38:	89 04 24             	mov    %eax,(%esp)
  800c3b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800c3e:	ff 4d e4             	decl   -0x1c(%ebp)
  800c41:	0f be 06             	movsbl (%esi),%eax
  800c44:	46                   	inc    %esi
  800c45:	85 c0                	test   %eax,%eax
  800c47:	74 21                	je     800c6a <vprintfmt+0x23c>
  800c49:	85 ff                	test   %edi,%edi
  800c4b:	78 c9                	js     800c16 <vprintfmt+0x1e8>
  800c4d:	4f                   	dec    %edi
  800c4e:	79 c6                	jns    800c16 <vprintfmt+0x1e8>
  800c50:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c53:	89 de                	mov    %ebx,%esi
  800c55:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800c58:	eb 18                	jmp    800c72 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800c5a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c5e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800c65:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800c67:	4b                   	dec    %ebx
  800c68:	eb 08                	jmp    800c72 <vprintfmt+0x244>
  800c6a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c6d:	89 de                	mov    %ebx,%esi
  800c6f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800c72:	85 db                	test   %ebx,%ebx
  800c74:	7f e4                	jg     800c5a <vprintfmt+0x22c>
  800c76:	89 7d 08             	mov    %edi,0x8(%ebp)
  800c79:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c7b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800c7e:	e9 ce fd ff ff       	jmp    800a51 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800c83:	83 f9 01             	cmp    $0x1,%ecx
  800c86:	7e 10                	jle    800c98 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800c88:	8b 45 14             	mov    0x14(%ebp),%eax
  800c8b:	8d 50 08             	lea    0x8(%eax),%edx
  800c8e:	89 55 14             	mov    %edx,0x14(%ebp)
  800c91:	8b 30                	mov    (%eax),%esi
  800c93:	8b 78 04             	mov    0x4(%eax),%edi
  800c96:	eb 26                	jmp    800cbe <vprintfmt+0x290>
	else if (lflag)
  800c98:	85 c9                	test   %ecx,%ecx
  800c9a:	74 12                	je     800cae <vprintfmt+0x280>
		return va_arg(*ap, long);
  800c9c:	8b 45 14             	mov    0x14(%ebp),%eax
  800c9f:	8d 50 04             	lea    0x4(%eax),%edx
  800ca2:	89 55 14             	mov    %edx,0x14(%ebp)
  800ca5:	8b 30                	mov    (%eax),%esi
  800ca7:	89 f7                	mov    %esi,%edi
  800ca9:	c1 ff 1f             	sar    $0x1f,%edi
  800cac:	eb 10                	jmp    800cbe <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800cae:	8b 45 14             	mov    0x14(%ebp),%eax
  800cb1:	8d 50 04             	lea    0x4(%eax),%edx
  800cb4:	89 55 14             	mov    %edx,0x14(%ebp)
  800cb7:	8b 30                	mov    (%eax),%esi
  800cb9:	89 f7                	mov    %esi,%edi
  800cbb:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800cbe:	85 ff                	test   %edi,%edi
  800cc0:	78 0a                	js     800ccc <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800cc2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cc7:	e9 8c 00 00 00       	jmp    800d58 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800ccc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800cd0:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800cd7:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800cda:	f7 de                	neg    %esi
  800cdc:	83 d7 00             	adc    $0x0,%edi
  800cdf:	f7 df                	neg    %edi
			}
			base = 10;
  800ce1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ce6:	eb 70                	jmp    800d58 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800ce8:	89 ca                	mov    %ecx,%edx
  800cea:	8d 45 14             	lea    0x14(%ebp),%eax
  800ced:	e8 c0 fc ff ff       	call   8009b2 <getuint>
  800cf2:	89 c6                	mov    %eax,%esi
  800cf4:	89 d7                	mov    %edx,%edi
			base = 10;
  800cf6:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800cfb:	eb 5b                	jmp    800d58 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  800cfd:	89 ca                	mov    %ecx,%edx
  800cff:	8d 45 14             	lea    0x14(%ebp),%eax
  800d02:	e8 ab fc ff ff       	call   8009b2 <getuint>
  800d07:	89 c6                	mov    %eax,%esi
  800d09:	89 d7                	mov    %edx,%edi
			base = 8;
  800d0b:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800d10:	eb 46                	jmp    800d58 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  800d12:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d16:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800d1d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800d20:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d24:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800d2b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800d2e:	8b 45 14             	mov    0x14(%ebp),%eax
  800d31:	8d 50 04             	lea    0x4(%eax),%edx
  800d34:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800d37:	8b 30                	mov    (%eax),%esi
  800d39:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800d3e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800d43:	eb 13                	jmp    800d58 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800d45:	89 ca                	mov    %ecx,%edx
  800d47:	8d 45 14             	lea    0x14(%ebp),%eax
  800d4a:	e8 63 fc ff ff       	call   8009b2 <getuint>
  800d4f:	89 c6                	mov    %eax,%esi
  800d51:	89 d7                	mov    %edx,%edi
			base = 16;
  800d53:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800d58:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800d5c:	89 54 24 10          	mov    %edx,0x10(%esp)
  800d60:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800d63:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800d67:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d6b:	89 34 24             	mov    %esi,(%esp)
  800d6e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d72:	89 da                	mov    %ebx,%edx
  800d74:	8b 45 08             	mov    0x8(%ebp),%eax
  800d77:	e8 6c fb ff ff       	call   8008e8 <printnum>
			break;
  800d7c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800d7f:	e9 cd fc ff ff       	jmp    800a51 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800d84:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d88:	89 04 24             	mov    %eax,(%esp)
  800d8b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d8e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800d91:	e9 bb fc ff ff       	jmp    800a51 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800d96:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d9a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800da1:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800da4:	eb 01                	jmp    800da7 <vprintfmt+0x379>
  800da6:	4e                   	dec    %esi
  800da7:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800dab:	75 f9                	jne    800da6 <vprintfmt+0x378>
  800dad:	e9 9f fc ff ff       	jmp    800a51 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800db2:	83 c4 4c             	add    $0x4c,%esp
  800db5:	5b                   	pop    %ebx
  800db6:	5e                   	pop    %esi
  800db7:	5f                   	pop    %edi
  800db8:	5d                   	pop    %ebp
  800db9:	c3                   	ret    

00800dba <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800dba:	55                   	push   %ebp
  800dbb:	89 e5                	mov    %esp,%ebp
  800dbd:	83 ec 28             	sub    $0x28,%esp
  800dc0:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800dc6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800dc9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800dcd:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800dd0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800dd7:	85 c0                	test   %eax,%eax
  800dd9:	74 30                	je     800e0b <vsnprintf+0x51>
  800ddb:	85 d2                	test   %edx,%edx
  800ddd:	7e 33                	jle    800e12 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ddf:	8b 45 14             	mov    0x14(%ebp),%eax
  800de2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800de6:	8b 45 10             	mov    0x10(%ebp),%eax
  800de9:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ded:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800df0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800df4:	c7 04 24 ec 09 80 00 	movl   $0x8009ec,(%esp)
  800dfb:	e8 2e fc ff ff       	call   800a2e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800e00:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e03:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800e06:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e09:	eb 0c                	jmp    800e17 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800e0b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e10:	eb 05                	jmp    800e17 <vsnprintf+0x5d>
  800e12:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800e17:	c9                   	leave  
  800e18:	c3                   	ret    

00800e19 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800e19:	55                   	push   %ebp
  800e1a:	89 e5                	mov    %esp,%ebp
  800e1c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800e1f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800e22:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e26:	8b 45 10             	mov    0x10(%ebp),%eax
  800e29:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e2d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e30:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e34:	8b 45 08             	mov    0x8(%ebp),%eax
  800e37:	89 04 24             	mov    %eax,(%esp)
  800e3a:	e8 7b ff ff ff       	call   800dba <vsnprintf>
	va_end(ap);

	return rc;
}
  800e3f:	c9                   	leave  
  800e40:	c3                   	ret    
  800e41:	00 00                	add    %al,(%eax)
	...

00800e44 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800e44:	55                   	push   %ebp
  800e45:	89 e5                	mov    %esp,%ebp
  800e47:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800e4a:	b8 00 00 00 00       	mov    $0x0,%eax
  800e4f:	eb 01                	jmp    800e52 <strlen+0xe>
		n++;
  800e51:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800e52:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800e56:	75 f9                	jne    800e51 <strlen+0xd>
		n++;
	return n;
}
  800e58:	5d                   	pop    %ebp
  800e59:	c3                   	ret    

00800e5a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800e5a:	55                   	push   %ebp
  800e5b:	89 e5                	mov    %esp,%ebp
  800e5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800e60:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800e63:	b8 00 00 00 00       	mov    $0x0,%eax
  800e68:	eb 01                	jmp    800e6b <strnlen+0x11>
		n++;
  800e6a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800e6b:	39 d0                	cmp    %edx,%eax
  800e6d:	74 06                	je     800e75 <strnlen+0x1b>
  800e6f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800e73:	75 f5                	jne    800e6a <strnlen+0x10>
		n++;
	return n;
}
  800e75:	5d                   	pop    %ebp
  800e76:	c3                   	ret    

00800e77 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800e77:	55                   	push   %ebp
  800e78:	89 e5                	mov    %esp,%ebp
  800e7a:	53                   	push   %ebx
  800e7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800e81:	ba 00 00 00 00       	mov    $0x0,%edx
  800e86:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800e89:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800e8c:	42                   	inc    %edx
  800e8d:	84 c9                	test   %cl,%cl
  800e8f:	75 f5                	jne    800e86 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800e91:	5b                   	pop    %ebx
  800e92:	5d                   	pop    %ebp
  800e93:	c3                   	ret    

00800e94 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800e94:	55                   	push   %ebp
  800e95:	89 e5                	mov    %esp,%ebp
  800e97:	53                   	push   %ebx
  800e98:	83 ec 08             	sub    $0x8,%esp
  800e9b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800e9e:	89 1c 24             	mov    %ebx,(%esp)
  800ea1:	e8 9e ff ff ff       	call   800e44 <strlen>
	strcpy(dst + len, src);
  800ea6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ea9:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ead:	01 d8                	add    %ebx,%eax
  800eaf:	89 04 24             	mov    %eax,(%esp)
  800eb2:	e8 c0 ff ff ff       	call   800e77 <strcpy>
	return dst;
}
  800eb7:	89 d8                	mov    %ebx,%eax
  800eb9:	83 c4 08             	add    $0x8,%esp
  800ebc:	5b                   	pop    %ebx
  800ebd:	5d                   	pop    %ebp
  800ebe:	c3                   	ret    

00800ebf <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ebf:	55                   	push   %ebp
  800ec0:	89 e5                	mov    %esp,%ebp
  800ec2:	56                   	push   %esi
  800ec3:	53                   	push   %ebx
  800ec4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eca:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ecd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ed2:	eb 0c                	jmp    800ee0 <strncpy+0x21>
		*dst++ = *src;
  800ed4:	8a 1a                	mov    (%edx),%bl
  800ed6:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ed9:	80 3a 01             	cmpb   $0x1,(%edx)
  800edc:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800edf:	41                   	inc    %ecx
  800ee0:	39 f1                	cmp    %esi,%ecx
  800ee2:	75 f0                	jne    800ed4 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ee4:	5b                   	pop    %ebx
  800ee5:	5e                   	pop    %esi
  800ee6:	5d                   	pop    %ebp
  800ee7:	c3                   	ret    

00800ee8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ee8:	55                   	push   %ebp
  800ee9:	89 e5                	mov    %esp,%ebp
  800eeb:	56                   	push   %esi
  800eec:	53                   	push   %ebx
  800eed:	8b 75 08             	mov    0x8(%ebp),%esi
  800ef0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef3:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ef6:	85 d2                	test   %edx,%edx
  800ef8:	75 0a                	jne    800f04 <strlcpy+0x1c>
  800efa:	89 f0                	mov    %esi,%eax
  800efc:	eb 1a                	jmp    800f18 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800efe:	88 18                	mov    %bl,(%eax)
  800f00:	40                   	inc    %eax
  800f01:	41                   	inc    %ecx
  800f02:	eb 02                	jmp    800f06 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800f04:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800f06:	4a                   	dec    %edx
  800f07:	74 0a                	je     800f13 <strlcpy+0x2b>
  800f09:	8a 19                	mov    (%ecx),%bl
  800f0b:	84 db                	test   %bl,%bl
  800f0d:	75 ef                	jne    800efe <strlcpy+0x16>
  800f0f:	89 c2                	mov    %eax,%edx
  800f11:	eb 02                	jmp    800f15 <strlcpy+0x2d>
  800f13:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800f15:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800f18:	29 f0                	sub    %esi,%eax
}
  800f1a:	5b                   	pop    %ebx
  800f1b:	5e                   	pop    %esi
  800f1c:	5d                   	pop    %ebp
  800f1d:	c3                   	ret    

00800f1e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800f1e:	55                   	push   %ebp
  800f1f:	89 e5                	mov    %esp,%ebp
  800f21:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f24:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800f27:	eb 02                	jmp    800f2b <strcmp+0xd>
		p++, q++;
  800f29:	41                   	inc    %ecx
  800f2a:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800f2b:	8a 01                	mov    (%ecx),%al
  800f2d:	84 c0                	test   %al,%al
  800f2f:	74 04                	je     800f35 <strcmp+0x17>
  800f31:	3a 02                	cmp    (%edx),%al
  800f33:	74 f4                	je     800f29 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800f35:	0f b6 c0             	movzbl %al,%eax
  800f38:	0f b6 12             	movzbl (%edx),%edx
  800f3b:	29 d0                	sub    %edx,%eax
}
  800f3d:	5d                   	pop    %ebp
  800f3e:	c3                   	ret    

00800f3f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800f3f:	55                   	push   %ebp
  800f40:	89 e5                	mov    %esp,%ebp
  800f42:	53                   	push   %ebx
  800f43:	8b 45 08             	mov    0x8(%ebp),%eax
  800f46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f49:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800f4c:	eb 03                	jmp    800f51 <strncmp+0x12>
		n--, p++, q++;
  800f4e:	4a                   	dec    %edx
  800f4f:	40                   	inc    %eax
  800f50:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800f51:	85 d2                	test   %edx,%edx
  800f53:	74 14                	je     800f69 <strncmp+0x2a>
  800f55:	8a 18                	mov    (%eax),%bl
  800f57:	84 db                	test   %bl,%bl
  800f59:	74 04                	je     800f5f <strncmp+0x20>
  800f5b:	3a 19                	cmp    (%ecx),%bl
  800f5d:	74 ef                	je     800f4e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800f5f:	0f b6 00             	movzbl (%eax),%eax
  800f62:	0f b6 11             	movzbl (%ecx),%edx
  800f65:	29 d0                	sub    %edx,%eax
  800f67:	eb 05                	jmp    800f6e <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800f69:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800f6e:	5b                   	pop    %ebx
  800f6f:	5d                   	pop    %ebp
  800f70:	c3                   	ret    

00800f71 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800f71:	55                   	push   %ebp
  800f72:	89 e5                	mov    %esp,%ebp
  800f74:	8b 45 08             	mov    0x8(%ebp),%eax
  800f77:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800f7a:	eb 05                	jmp    800f81 <strchr+0x10>
		if (*s == c)
  800f7c:	38 ca                	cmp    %cl,%dl
  800f7e:	74 0c                	je     800f8c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800f80:	40                   	inc    %eax
  800f81:	8a 10                	mov    (%eax),%dl
  800f83:	84 d2                	test   %dl,%dl
  800f85:	75 f5                	jne    800f7c <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800f87:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f8c:	5d                   	pop    %ebp
  800f8d:	c3                   	ret    

00800f8e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800f8e:	55                   	push   %ebp
  800f8f:	89 e5                	mov    %esp,%ebp
  800f91:	8b 45 08             	mov    0x8(%ebp),%eax
  800f94:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800f97:	eb 05                	jmp    800f9e <strfind+0x10>
		if (*s == c)
  800f99:	38 ca                	cmp    %cl,%dl
  800f9b:	74 07                	je     800fa4 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800f9d:	40                   	inc    %eax
  800f9e:	8a 10                	mov    (%eax),%dl
  800fa0:	84 d2                	test   %dl,%dl
  800fa2:	75 f5                	jne    800f99 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800fa4:	5d                   	pop    %ebp
  800fa5:	c3                   	ret    

00800fa6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800fa6:	55                   	push   %ebp
  800fa7:	89 e5                	mov    %esp,%ebp
  800fa9:	57                   	push   %edi
  800faa:	56                   	push   %esi
  800fab:	53                   	push   %ebx
  800fac:	8b 7d 08             	mov    0x8(%ebp),%edi
  800faf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fb2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800fb5:	85 c9                	test   %ecx,%ecx
  800fb7:	74 30                	je     800fe9 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800fb9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800fbf:	75 25                	jne    800fe6 <memset+0x40>
  800fc1:	f6 c1 03             	test   $0x3,%cl
  800fc4:	75 20                	jne    800fe6 <memset+0x40>
		c &= 0xFF;
  800fc6:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800fc9:	89 d3                	mov    %edx,%ebx
  800fcb:	c1 e3 08             	shl    $0x8,%ebx
  800fce:	89 d6                	mov    %edx,%esi
  800fd0:	c1 e6 18             	shl    $0x18,%esi
  800fd3:	89 d0                	mov    %edx,%eax
  800fd5:	c1 e0 10             	shl    $0x10,%eax
  800fd8:	09 f0                	or     %esi,%eax
  800fda:	09 d0                	or     %edx,%eax
  800fdc:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800fde:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800fe1:	fc                   	cld    
  800fe2:	f3 ab                	rep stos %eax,%es:(%edi)
  800fe4:	eb 03                	jmp    800fe9 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800fe6:	fc                   	cld    
  800fe7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800fe9:	89 f8                	mov    %edi,%eax
  800feb:	5b                   	pop    %ebx
  800fec:	5e                   	pop    %esi
  800fed:	5f                   	pop    %edi
  800fee:	5d                   	pop    %ebp
  800fef:	c3                   	ret    

00800ff0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ff0:	55                   	push   %ebp
  800ff1:	89 e5                	mov    %esp,%ebp
  800ff3:	57                   	push   %edi
  800ff4:	56                   	push   %esi
  800ff5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ffb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ffe:	39 c6                	cmp    %eax,%esi
  801000:	73 34                	jae    801036 <memmove+0x46>
  801002:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801005:	39 d0                	cmp    %edx,%eax
  801007:	73 2d                	jae    801036 <memmove+0x46>
		s += n;
		d += n;
  801009:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80100c:	f6 c2 03             	test   $0x3,%dl
  80100f:	75 1b                	jne    80102c <memmove+0x3c>
  801011:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801017:	75 13                	jne    80102c <memmove+0x3c>
  801019:	f6 c1 03             	test   $0x3,%cl
  80101c:	75 0e                	jne    80102c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80101e:	83 ef 04             	sub    $0x4,%edi
  801021:	8d 72 fc             	lea    -0x4(%edx),%esi
  801024:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801027:	fd                   	std    
  801028:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80102a:	eb 07                	jmp    801033 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80102c:	4f                   	dec    %edi
  80102d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801030:	fd                   	std    
  801031:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801033:	fc                   	cld    
  801034:	eb 20                	jmp    801056 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801036:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80103c:	75 13                	jne    801051 <memmove+0x61>
  80103e:	a8 03                	test   $0x3,%al
  801040:	75 0f                	jne    801051 <memmove+0x61>
  801042:	f6 c1 03             	test   $0x3,%cl
  801045:	75 0a                	jne    801051 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801047:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80104a:	89 c7                	mov    %eax,%edi
  80104c:	fc                   	cld    
  80104d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80104f:	eb 05                	jmp    801056 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801051:	89 c7                	mov    %eax,%edi
  801053:	fc                   	cld    
  801054:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801056:	5e                   	pop    %esi
  801057:	5f                   	pop    %edi
  801058:	5d                   	pop    %ebp
  801059:	c3                   	ret    

0080105a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80105a:	55                   	push   %ebp
  80105b:	89 e5                	mov    %esp,%ebp
  80105d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801060:	8b 45 10             	mov    0x10(%ebp),%eax
  801063:	89 44 24 08          	mov    %eax,0x8(%esp)
  801067:	8b 45 0c             	mov    0xc(%ebp),%eax
  80106a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80106e:	8b 45 08             	mov    0x8(%ebp),%eax
  801071:	89 04 24             	mov    %eax,(%esp)
  801074:	e8 77 ff ff ff       	call   800ff0 <memmove>
}
  801079:	c9                   	leave  
  80107a:	c3                   	ret    

0080107b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80107b:	55                   	push   %ebp
  80107c:	89 e5                	mov    %esp,%ebp
  80107e:	57                   	push   %edi
  80107f:	56                   	push   %esi
  801080:	53                   	push   %ebx
  801081:	8b 7d 08             	mov    0x8(%ebp),%edi
  801084:	8b 75 0c             	mov    0xc(%ebp),%esi
  801087:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80108a:	ba 00 00 00 00       	mov    $0x0,%edx
  80108f:	eb 16                	jmp    8010a7 <memcmp+0x2c>
		if (*s1 != *s2)
  801091:	8a 04 17             	mov    (%edi,%edx,1),%al
  801094:	42                   	inc    %edx
  801095:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  801099:	38 c8                	cmp    %cl,%al
  80109b:	74 0a                	je     8010a7 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  80109d:	0f b6 c0             	movzbl %al,%eax
  8010a0:	0f b6 c9             	movzbl %cl,%ecx
  8010a3:	29 c8                	sub    %ecx,%eax
  8010a5:	eb 09                	jmp    8010b0 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8010a7:	39 da                	cmp    %ebx,%edx
  8010a9:	75 e6                	jne    801091 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8010ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010b0:	5b                   	pop    %ebx
  8010b1:	5e                   	pop    %esi
  8010b2:	5f                   	pop    %edi
  8010b3:	5d                   	pop    %ebp
  8010b4:	c3                   	ret    

008010b5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8010b5:	55                   	push   %ebp
  8010b6:	89 e5                	mov    %esp,%ebp
  8010b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8010bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8010be:	89 c2                	mov    %eax,%edx
  8010c0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8010c3:	eb 05                	jmp    8010ca <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8010c5:	38 08                	cmp    %cl,(%eax)
  8010c7:	74 05                	je     8010ce <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8010c9:	40                   	inc    %eax
  8010ca:	39 d0                	cmp    %edx,%eax
  8010cc:	72 f7                	jb     8010c5 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8010ce:	5d                   	pop    %ebp
  8010cf:	c3                   	ret    

008010d0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8010d0:	55                   	push   %ebp
  8010d1:	89 e5                	mov    %esp,%ebp
  8010d3:	57                   	push   %edi
  8010d4:	56                   	push   %esi
  8010d5:	53                   	push   %ebx
  8010d6:	8b 55 08             	mov    0x8(%ebp),%edx
  8010d9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8010dc:	eb 01                	jmp    8010df <strtol+0xf>
		s++;
  8010de:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8010df:	8a 02                	mov    (%edx),%al
  8010e1:	3c 20                	cmp    $0x20,%al
  8010e3:	74 f9                	je     8010de <strtol+0xe>
  8010e5:	3c 09                	cmp    $0x9,%al
  8010e7:	74 f5                	je     8010de <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8010e9:	3c 2b                	cmp    $0x2b,%al
  8010eb:	75 08                	jne    8010f5 <strtol+0x25>
		s++;
  8010ed:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8010ee:	bf 00 00 00 00       	mov    $0x0,%edi
  8010f3:	eb 13                	jmp    801108 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8010f5:	3c 2d                	cmp    $0x2d,%al
  8010f7:	75 0a                	jne    801103 <strtol+0x33>
		s++, neg = 1;
  8010f9:	8d 52 01             	lea    0x1(%edx),%edx
  8010fc:	bf 01 00 00 00       	mov    $0x1,%edi
  801101:	eb 05                	jmp    801108 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801103:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801108:	85 db                	test   %ebx,%ebx
  80110a:	74 05                	je     801111 <strtol+0x41>
  80110c:	83 fb 10             	cmp    $0x10,%ebx
  80110f:	75 28                	jne    801139 <strtol+0x69>
  801111:	8a 02                	mov    (%edx),%al
  801113:	3c 30                	cmp    $0x30,%al
  801115:	75 10                	jne    801127 <strtol+0x57>
  801117:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80111b:	75 0a                	jne    801127 <strtol+0x57>
		s += 2, base = 16;
  80111d:	83 c2 02             	add    $0x2,%edx
  801120:	bb 10 00 00 00       	mov    $0x10,%ebx
  801125:	eb 12                	jmp    801139 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  801127:	85 db                	test   %ebx,%ebx
  801129:	75 0e                	jne    801139 <strtol+0x69>
  80112b:	3c 30                	cmp    $0x30,%al
  80112d:	75 05                	jne    801134 <strtol+0x64>
		s++, base = 8;
  80112f:	42                   	inc    %edx
  801130:	b3 08                	mov    $0x8,%bl
  801132:	eb 05                	jmp    801139 <strtol+0x69>
	else if (base == 0)
		base = 10;
  801134:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801139:	b8 00 00 00 00       	mov    $0x0,%eax
  80113e:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801140:	8a 0a                	mov    (%edx),%cl
  801142:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801145:	80 fb 09             	cmp    $0x9,%bl
  801148:	77 08                	ja     801152 <strtol+0x82>
			dig = *s - '0';
  80114a:	0f be c9             	movsbl %cl,%ecx
  80114d:	83 e9 30             	sub    $0x30,%ecx
  801150:	eb 1e                	jmp    801170 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  801152:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801155:	80 fb 19             	cmp    $0x19,%bl
  801158:	77 08                	ja     801162 <strtol+0x92>
			dig = *s - 'a' + 10;
  80115a:	0f be c9             	movsbl %cl,%ecx
  80115d:	83 e9 57             	sub    $0x57,%ecx
  801160:	eb 0e                	jmp    801170 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  801162:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  801165:	80 fb 19             	cmp    $0x19,%bl
  801168:	77 12                	ja     80117c <strtol+0xac>
			dig = *s - 'A' + 10;
  80116a:	0f be c9             	movsbl %cl,%ecx
  80116d:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801170:	39 f1                	cmp    %esi,%ecx
  801172:	7d 0c                	jge    801180 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  801174:	42                   	inc    %edx
  801175:	0f af c6             	imul   %esi,%eax
  801178:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  80117a:	eb c4                	jmp    801140 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  80117c:	89 c1                	mov    %eax,%ecx
  80117e:	eb 02                	jmp    801182 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801180:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801182:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801186:	74 05                	je     80118d <strtol+0xbd>
		*endptr = (char *) s;
  801188:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80118b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  80118d:	85 ff                	test   %edi,%edi
  80118f:	74 04                	je     801195 <strtol+0xc5>
  801191:	89 c8                	mov    %ecx,%eax
  801193:	f7 d8                	neg    %eax
}
  801195:	5b                   	pop    %ebx
  801196:	5e                   	pop    %esi
  801197:	5f                   	pop    %edi
  801198:	5d                   	pop    %ebp
  801199:	c3                   	ret    
	...

0080119c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80119c:	55                   	push   %ebp
  80119d:	89 e5                	mov    %esp,%ebp
  80119f:	57                   	push   %edi
  8011a0:	56                   	push   %esi
  8011a1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8011ad:	89 c3                	mov    %eax,%ebx
  8011af:	89 c7                	mov    %eax,%edi
  8011b1:	89 c6                	mov    %eax,%esi
  8011b3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8011b5:	5b                   	pop    %ebx
  8011b6:	5e                   	pop    %esi
  8011b7:	5f                   	pop    %edi
  8011b8:	5d                   	pop    %ebp
  8011b9:	c3                   	ret    

008011ba <sys_cgetc>:

int
sys_cgetc(void)
{
  8011ba:	55                   	push   %ebp
  8011bb:	89 e5                	mov    %esp,%ebp
  8011bd:	57                   	push   %edi
  8011be:	56                   	push   %esi
  8011bf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8011c5:	b8 01 00 00 00       	mov    $0x1,%eax
  8011ca:	89 d1                	mov    %edx,%ecx
  8011cc:	89 d3                	mov    %edx,%ebx
  8011ce:	89 d7                	mov    %edx,%edi
  8011d0:	89 d6                	mov    %edx,%esi
  8011d2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8011d4:	5b                   	pop    %ebx
  8011d5:	5e                   	pop    %esi
  8011d6:	5f                   	pop    %edi
  8011d7:	5d                   	pop    %ebp
  8011d8:	c3                   	ret    

008011d9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8011d9:	55                   	push   %ebp
  8011da:	89 e5                	mov    %esp,%ebp
  8011dc:	57                   	push   %edi
  8011dd:	56                   	push   %esi
  8011de:	53                   	push   %ebx
  8011df:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011e7:	b8 03 00 00 00       	mov    $0x3,%eax
  8011ec:	8b 55 08             	mov    0x8(%ebp),%edx
  8011ef:	89 cb                	mov    %ecx,%ebx
  8011f1:	89 cf                	mov    %ecx,%edi
  8011f3:	89 ce                	mov    %ecx,%esi
  8011f5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011f7:	85 c0                	test   %eax,%eax
  8011f9:	7e 28                	jle    801223 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011fb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011ff:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801206:	00 
  801207:	c7 44 24 08 3f 2d 80 	movl   $0x802d3f,0x8(%esp)
  80120e:	00 
  80120f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801216:	00 
  801217:	c7 04 24 5c 2d 80 00 	movl   $0x802d5c,(%esp)
  80121e:	e8 b1 f5 ff ff       	call   8007d4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801223:	83 c4 2c             	add    $0x2c,%esp
  801226:	5b                   	pop    %ebx
  801227:	5e                   	pop    %esi
  801228:	5f                   	pop    %edi
  801229:	5d                   	pop    %ebp
  80122a:	c3                   	ret    

0080122b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80122b:	55                   	push   %ebp
  80122c:	89 e5                	mov    %esp,%ebp
  80122e:	57                   	push   %edi
  80122f:	56                   	push   %esi
  801230:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801231:	ba 00 00 00 00       	mov    $0x0,%edx
  801236:	b8 02 00 00 00       	mov    $0x2,%eax
  80123b:	89 d1                	mov    %edx,%ecx
  80123d:	89 d3                	mov    %edx,%ebx
  80123f:	89 d7                	mov    %edx,%edi
  801241:	89 d6                	mov    %edx,%esi
  801243:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801245:	5b                   	pop    %ebx
  801246:	5e                   	pop    %esi
  801247:	5f                   	pop    %edi
  801248:	5d                   	pop    %ebp
  801249:	c3                   	ret    

0080124a <sys_yield>:

void
sys_yield(void)
{
  80124a:	55                   	push   %ebp
  80124b:	89 e5                	mov    %esp,%ebp
  80124d:	57                   	push   %edi
  80124e:	56                   	push   %esi
  80124f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801250:	ba 00 00 00 00       	mov    $0x0,%edx
  801255:	b8 0b 00 00 00       	mov    $0xb,%eax
  80125a:	89 d1                	mov    %edx,%ecx
  80125c:	89 d3                	mov    %edx,%ebx
  80125e:	89 d7                	mov    %edx,%edi
  801260:	89 d6                	mov    %edx,%esi
  801262:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801264:	5b                   	pop    %ebx
  801265:	5e                   	pop    %esi
  801266:	5f                   	pop    %edi
  801267:	5d                   	pop    %ebp
  801268:	c3                   	ret    

00801269 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801269:	55                   	push   %ebp
  80126a:	89 e5                	mov    %esp,%ebp
  80126c:	57                   	push   %edi
  80126d:	56                   	push   %esi
  80126e:	53                   	push   %ebx
  80126f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801272:	be 00 00 00 00       	mov    $0x0,%esi
  801277:	b8 04 00 00 00       	mov    $0x4,%eax
  80127c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80127f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801282:	8b 55 08             	mov    0x8(%ebp),%edx
  801285:	89 f7                	mov    %esi,%edi
  801287:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801289:	85 c0                	test   %eax,%eax
  80128b:	7e 28                	jle    8012b5 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  80128d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801291:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  801298:	00 
  801299:	c7 44 24 08 3f 2d 80 	movl   $0x802d3f,0x8(%esp)
  8012a0:	00 
  8012a1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012a8:	00 
  8012a9:	c7 04 24 5c 2d 80 00 	movl   $0x802d5c,(%esp)
  8012b0:	e8 1f f5 ff ff       	call   8007d4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8012b5:	83 c4 2c             	add    $0x2c,%esp
  8012b8:	5b                   	pop    %ebx
  8012b9:	5e                   	pop    %esi
  8012ba:	5f                   	pop    %edi
  8012bb:	5d                   	pop    %ebp
  8012bc:	c3                   	ret    

008012bd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8012bd:	55                   	push   %ebp
  8012be:	89 e5                	mov    %esp,%ebp
  8012c0:	57                   	push   %edi
  8012c1:	56                   	push   %esi
  8012c2:	53                   	push   %ebx
  8012c3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012c6:	b8 05 00 00 00       	mov    $0x5,%eax
  8012cb:	8b 75 18             	mov    0x18(%ebp),%esi
  8012ce:	8b 7d 14             	mov    0x14(%ebp),%edi
  8012d1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012d7:	8b 55 08             	mov    0x8(%ebp),%edx
  8012da:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8012dc:	85 c0                	test   %eax,%eax
  8012de:	7e 28                	jle    801308 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012e0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012e4:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8012eb:	00 
  8012ec:	c7 44 24 08 3f 2d 80 	movl   $0x802d3f,0x8(%esp)
  8012f3:	00 
  8012f4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012fb:	00 
  8012fc:	c7 04 24 5c 2d 80 00 	movl   $0x802d5c,(%esp)
  801303:	e8 cc f4 ff ff       	call   8007d4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801308:	83 c4 2c             	add    $0x2c,%esp
  80130b:	5b                   	pop    %ebx
  80130c:	5e                   	pop    %esi
  80130d:	5f                   	pop    %edi
  80130e:	5d                   	pop    %ebp
  80130f:	c3                   	ret    

00801310 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801310:	55                   	push   %ebp
  801311:	89 e5                	mov    %esp,%ebp
  801313:	57                   	push   %edi
  801314:	56                   	push   %esi
  801315:	53                   	push   %ebx
  801316:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801319:	bb 00 00 00 00       	mov    $0x0,%ebx
  80131e:	b8 06 00 00 00       	mov    $0x6,%eax
  801323:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801326:	8b 55 08             	mov    0x8(%ebp),%edx
  801329:	89 df                	mov    %ebx,%edi
  80132b:	89 de                	mov    %ebx,%esi
  80132d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80132f:	85 c0                	test   %eax,%eax
  801331:	7e 28                	jle    80135b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801333:	89 44 24 10          	mov    %eax,0x10(%esp)
  801337:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80133e:	00 
  80133f:	c7 44 24 08 3f 2d 80 	movl   $0x802d3f,0x8(%esp)
  801346:	00 
  801347:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80134e:	00 
  80134f:	c7 04 24 5c 2d 80 00 	movl   $0x802d5c,(%esp)
  801356:	e8 79 f4 ff ff       	call   8007d4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80135b:	83 c4 2c             	add    $0x2c,%esp
  80135e:	5b                   	pop    %ebx
  80135f:	5e                   	pop    %esi
  801360:	5f                   	pop    %edi
  801361:	5d                   	pop    %ebp
  801362:	c3                   	ret    

00801363 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801363:	55                   	push   %ebp
  801364:	89 e5                	mov    %esp,%ebp
  801366:	57                   	push   %edi
  801367:	56                   	push   %esi
  801368:	53                   	push   %ebx
  801369:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80136c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801371:	b8 08 00 00 00       	mov    $0x8,%eax
  801376:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801379:	8b 55 08             	mov    0x8(%ebp),%edx
  80137c:	89 df                	mov    %ebx,%edi
  80137e:	89 de                	mov    %ebx,%esi
  801380:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801382:	85 c0                	test   %eax,%eax
  801384:	7e 28                	jle    8013ae <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801386:	89 44 24 10          	mov    %eax,0x10(%esp)
  80138a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  801391:	00 
  801392:	c7 44 24 08 3f 2d 80 	movl   $0x802d3f,0x8(%esp)
  801399:	00 
  80139a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8013a1:	00 
  8013a2:	c7 04 24 5c 2d 80 00 	movl   $0x802d5c,(%esp)
  8013a9:	e8 26 f4 ff ff       	call   8007d4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8013ae:	83 c4 2c             	add    $0x2c,%esp
  8013b1:	5b                   	pop    %ebx
  8013b2:	5e                   	pop    %esi
  8013b3:	5f                   	pop    %edi
  8013b4:	5d                   	pop    %ebp
  8013b5:	c3                   	ret    

008013b6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8013b6:	55                   	push   %ebp
  8013b7:	89 e5                	mov    %esp,%ebp
  8013b9:	57                   	push   %edi
  8013ba:	56                   	push   %esi
  8013bb:	53                   	push   %ebx
  8013bc:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013bf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013c4:	b8 09 00 00 00       	mov    $0x9,%eax
  8013c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8013cf:	89 df                	mov    %ebx,%edi
  8013d1:	89 de                	mov    %ebx,%esi
  8013d3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8013d5:	85 c0                	test   %eax,%eax
  8013d7:	7e 28                	jle    801401 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013d9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013dd:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8013e4:	00 
  8013e5:	c7 44 24 08 3f 2d 80 	movl   $0x802d3f,0x8(%esp)
  8013ec:	00 
  8013ed:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8013f4:	00 
  8013f5:	c7 04 24 5c 2d 80 00 	movl   $0x802d5c,(%esp)
  8013fc:	e8 d3 f3 ff ff       	call   8007d4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801401:	83 c4 2c             	add    $0x2c,%esp
  801404:	5b                   	pop    %ebx
  801405:	5e                   	pop    %esi
  801406:	5f                   	pop    %edi
  801407:	5d                   	pop    %ebp
  801408:	c3                   	ret    

00801409 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801409:	55                   	push   %ebp
  80140a:	89 e5                	mov    %esp,%ebp
  80140c:	57                   	push   %edi
  80140d:	56                   	push   %esi
  80140e:	53                   	push   %ebx
  80140f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801412:	bb 00 00 00 00       	mov    $0x0,%ebx
  801417:	b8 0a 00 00 00       	mov    $0xa,%eax
  80141c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80141f:	8b 55 08             	mov    0x8(%ebp),%edx
  801422:	89 df                	mov    %ebx,%edi
  801424:	89 de                	mov    %ebx,%esi
  801426:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801428:	85 c0                	test   %eax,%eax
  80142a:	7e 28                	jle    801454 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80142c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801430:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801437:	00 
  801438:	c7 44 24 08 3f 2d 80 	movl   $0x802d3f,0x8(%esp)
  80143f:	00 
  801440:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801447:	00 
  801448:	c7 04 24 5c 2d 80 00 	movl   $0x802d5c,(%esp)
  80144f:	e8 80 f3 ff ff       	call   8007d4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801454:	83 c4 2c             	add    $0x2c,%esp
  801457:	5b                   	pop    %ebx
  801458:	5e                   	pop    %esi
  801459:	5f                   	pop    %edi
  80145a:	5d                   	pop    %ebp
  80145b:	c3                   	ret    

0080145c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80145c:	55                   	push   %ebp
  80145d:	89 e5                	mov    %esp,%ebp
  80145f:	57                   	push   %edi
  801460:	56                   	push   %esi
  801461:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801462:	be 00 00 00 00       	mov    $0x0,%esi
  801467:	b8 0c 00 00 00       	mov    $0xc,%eax
  80146c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80146f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801472:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801475:	8b 55 08             	mov    0x8(%ebp),%edx
  801478:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80147a:	5b                   	pop    %ebx
  80147b:	5e                   	pop    %esi
  80147c:	5f                   	pop    %edi
  80147d:	5d                   	pop    %ebp
  80147e:	c3                   	ret    

0080147f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80147f:	55                   	push   %ebp
  801480:	89 e5                	mov    %esp,%ebp
  801482:	57                   	push   %edi
  801483:	56                   	push   %esi
  801484:	53                   	push   %ebx
  801485:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801488:	b9 00 00 00 00       	mov    $0x0,%ecx
  80148d:	b8 0d 00 00 00       	mov    $0xd,%eax
  801492:	8b 55 08             	mov    0x8(%ebp),%edx
  801495:	89 cb                	mov    %ecx,%ebx
  801497:	89 cf                	mov    %ecx,%edi
  801499:	89 ce                	mov    %ecx,%esi
  80149b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80149d:	85 c0                	test   %eax,%eax
  80149f:	7e 28                	jle    8014c9 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8014a1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014a5:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8014ac:	00 
  8014ad:	c7 44 24 08 3f 2d 80 	movl   $0x802d3f,0x8(%esp)
  8014b4:	00 
  8014b5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8014bc:	00 
  8014bd:	c7 04 24 5c 2d 80 00 	movl   $0x802d5c,(%esp)
  8014c4:	e8 0b f3 ff ff       	call   8007d4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8014c9:	83 c4 2c             	add    $0x2c,%esp
  8014cc:	5b                   	pop    %ebx
  8014cd:	5e                   	pop    %esi
  8014ce:	5f                   	pop    %edi
  8014cf:	5d                   	pop    %ebp
  8014d0:	c3                   	ret    
  8014d1:	00 00                	add    %al,(%eax)
	...

008014d4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8014d4:	55                   	push   %ebp
  8014d5:	89 e5                	mov    %esp,%ebp
  8014d7:	56                   	push   %esi
  8014d8:	53                   	push   %ebx
  8014d9:	83 ec 10             	sub    $0x10,%esp
  8014dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8014df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014e2:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int r;
		
	r = sys_ipc_recv(pg?pg:(void*)UTOP);
  8014e5:	85 c0                	test   %eax,%eax
  8014e7:	75 05                	jne    8014ee <ipc_recv+0x1a>
  8014e9:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8014ee:	89 04 24             	mov    %eax,(%esp)
  8014f1:	e8 89 ff ff ff       	call   80147f <sys_ipc_recv>
	if (from_env_store != NULL)
  8014f6:	85 db                	test   %ebx,%ebx
  8014f8:	74 0b                	je     801505 <ipc_recv+0x31>
		*from_env_store = thisenv->env_ipc_from; 
  8014fa:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801500:	8b 52 74             	mov    0x74(%edx),%edx
  801503:	89 13                	mov    %edx,(%ebx)
	if (perm_store != NULL)
  801505:	85 f6                	test   %esi,%esi
  801507:	74 0b                	je     801514 <ipc_recv+0x40>
		*perm_store = thisenv->env_ipc_perm;
  801509:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80150f:	8b 52 78             	mov    0x78(%edx),%edx
  801512:	89 16                	mov    %edx,(%esi)
	
	if (r < 0){
  801514:	85 c0                	test   %eax,%eax
  801516:	79 16                	jns    80152e <ipc_recv+0x5a>
		if(from_env_store != NULL)
  801518:	85 db                	test   %ebx,%ebx
  80151a:	74 06                	je     801522 <ipc_recv+0x4e>
			*from_env_store = 0;
  80151c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store != NULL)	
  801522:	85 f6                	test   %esi,%esi
  801524:	74 10                	je     801536 <ipc_recv+0x62>
			*perm_store = 0;
  801526:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80152c:	eb 08                	jmp    801536 <ipc_recv+0x62>
		return r;
	}
	
	return thisenv->env_ipc_value;
  80152e:	a1 04 40 80 00       	mov    0x804004,%eax
  801533:	8b 40 70             	mov    0x70(%eax),%eax
}
  801536:	83 c4 10             	add    $0x10,%esp
  801539:	5b                   	pop    %ebx
  80153a:	5e                   	pop    %esi
  80153b:	5d                   	pop    %ebp
  80153c:	c3                   	ret    

0080153d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80153d:	55                   	push   %ebp
  80153e:	89 e5                	mov    %esp,%ebp
  801540:	57                   	push   %edi
  801541:	56                   	push   %esi
  801542:	53                   	push   %ebx
  801543:	83 ec 1c             	sub    $0x1c,%esp
  801546:	8b 75 08             	mov    0x8(%ebp),%esi
  801549:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80154c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  80154f:	eb 2a                	jmp    80157b <ipc_send+0x3e>
		if (r != -E_IPC_NOT_RECV)
  801551:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801554:	74 20                	je     801576 <ipc_send+0x39>
			panic("ipc_send: sys_ipc_try_send failed %e", r);
  801556:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80155a:	c7 44 24 08 6c 2d 80 	movl   $0x802d6c,0x8(%esp)
  801561:	00 
  801562:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  801569:	00 
  80156a:	c7 04 24 91 2d 80 00 	movl   $0x802d91,(%esp)
  801571:	e8 5e f2 ff ff       	call   8007d4 <_panic>
		sys_yield();
  801576:	e8 cf fc ff ff       	call   80124a <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  80157b:	85 db                	test   %ebx,%ebx
  80157d:	75 07                	jne    801586 <ipc_send+0x49>
  80157f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801584:	eb 02                	jmp    801588 <ipc_send+0x4b>
  801586:	89 d8                	mov    %ebx,%eax
  801588:	8b 55 14             	mov    0x14(%ebp),%edx
  80158b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80158f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801593:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801597:	89 34 24             	mov    %esi,(%esp)
  80159a:	e8 bd fe ff ff       	call   80145c <sys_ipc_try_send>
  80159f:	85 c0                	test   %eax,%eax
  8015a1:	78 ae                	js     801551 <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: sys_ipc_try_send failed %e", r);
		sys_yield();
	}
}
  8015a3:	83 c4 1c             	add    $0x1c,%esp
  8015a6:	5b                   	pop    %ebx
  8015a7:	5e                   	pop    %esi
  8015a8:	5f                   	pop    %edi
  8015a9:	5d                   	pop    %ebp
  8015aa:	c3                   	ret    

008015ab <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8015ab:	55                   	push   %ebp
  8015ac:	89 e5                	mov    %esp,%ebp
  8015ae:	53                   	push   %ebx
  8015af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  8015b2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8015b7:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8015be:	89 c2                	mov    %eax,%edx
  8015c0:	c1 e2 07             	shl    $0x7,%edx
  8015c3:	29 ca                	sub    %ecx,%edx
  8015c5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8015cb:	8b 52 50             	mov    0x50(%edx),%edx
  8015ce:	39 da                	cmp    %ebx,%edx
  8015d0:	75 0f                	jne    8015e1 <ipc_find_env+0x36>
			return envs[i].env_id;
  8015d2:	c1 e0 07             	shl    $0x7,%eax
  8015d5:	29 c8                	sub    %ecx,%eax
  8015d7:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8015dc:	8b 40 40             	mov    0x40(%eax),%eax
  8015df:	eb 0c                	jmp    8015ed <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8015e1:	40                   	inc    %eax
  8015e2:	3d 00 04 00 00       	cmp    $0x400,%eax
  8015e7:	75 ce                	jne    8015b7 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8015e9:	66 b8 00 00          	mov    $0x0,%ax
}
  8015ed:	5b                   	pop    %ebx
  8015ee:	5d                   	pop    %ebp
  8015ef:	c3                   	ret    

008015f0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8015f0:	55                   	push   %ebp
  8015f1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8015f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f6:	05 00 00 00 30       	add    $0x30000000,%eax
  8015fb:	c1 e8 0c             	shr    $0xc,%eax
}
  8015fe:	5d                   	pop    %ebp
  8015ff:	c3                   	ret    

00801600 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801600:	55                   	push   %ebp
  801601:	89 e5                	mov    %esp,%ebp
  801603:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801606:	8b 45 08             	mov    0x8(%ebp),%eax
  801609:	89 04 24             	mov    %eax,(%esp)
  80160c:	e8 df ff ff ff       	call   8015f0 <fd2num>
  801611:	05 20 00 0d 00       	add    $0xd0020,%eax
  801616:	c1 e0 0c             	shl    $0xc,%eax
}
  801619:	c9                   	leave  
  80161a:	c3                   	ret    

0080161b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80161b:	55                   	push   %ebp
  80161c:	89 e5                	mov    %esp,%ebp
  80161e:	53                   	push   %ebx
  80161f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801622:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801627:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801629:	89 c2                	mov    %eax,%edx
  80162b:	c1 ea 16             	shr    $0x16,%edx
  80162e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801635:	f6 c2 01             	test   $0x1,%dl
  801638:	74 11                	je     80164b <fd_alloc+0x30>
  80163a:	89 c2                	mov    %eax,%edx
  80163c:	c1 ea 0c             	shr    $0xc,%edx
  80163f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801646:	f6 c2 01             	test   $0x1,%dl
  801649:	75 09                	jne    801654 <fd_alloc+0x39>
			*fd_store = fd;
  80164b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80164d:	b8 00 00 00 00       	mov    $0x0,%eax
  801652:	eb 17                	jmp    80166b <fd_alloc+0x50>
  801654:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801659:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80165e:	75 c7                	jne    801627 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801660:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801666:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80166b:	5b                   	pop    %ebx
  80166c:	5d                   	pop    %ebp
  80166d:	c3                   	ret    

0080166e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80166e:	55                   	push   %ebp
  80166f:	89 e5                	mov    %esp,%ebp
  801671:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801674:	83 f8 1f             	cmp    $0x1f,%eax
  801677:	77 36                	ja     8016af <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801679:	05 00 00 0d 00       	add    $0xd0000,%eax
  80167e:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801681:	89 c2                	mov    %eax,%edx
  801683:	c1 ea 16             	shr    $0x16,%edx
  801686:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80168d:	f6 c2 01             	test   $0x1,%dl
  801690:	74 24                	je     8016b6 <fd_lookup+0x48>
  801692:	89 c2                	mov    %eax,%edx
  801694:	c1 ea 0c             	shr    $0xc,%edx
  801697:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80169e:	f6 c2 01             	test   $0x1,%dl
  8016a1:	74 1a                	je     8016bd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8016a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016a6:	89 02                	mov    %eax,(%edx)
	return 0;
  8016a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8016ad:	eb 13                	jmp    8016c2 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8016af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016b4:	eb 0c                	jmp    8016c2 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8016b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016bb:	eb 05                	jmp    8016c2 <fd_lookup+0x54>
  8016bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8016c2:	5d                   	pop    %ebp
  8016c3:	c3                   	ret    

008016c4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8016c4:	55                   	push   %ebp
  8016c5:	89 e5                	mov    %esp,%ebp
  8016c7:	53                   	push   %ebx
  8016c8:	83 ec 14             	sub    $0x14,%esp
  8016cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8016d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d6:	eb 0e                	jmp    8016e6 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8016d8:	39 08                	cmp    %ecx,(%eax)
  8016da:	75 09                	jne    8016e5 <dev_lookup+0x21>
			*dev = devtab[i];
  8016dc:	89 03                	mov    %eax,(%ebx)
			return 0;
  8016de:	b8 00 00 00 00       	mov    $0x0,%eax
  8016e3:	eb 33                	jmp    801718 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8016e5:	42                   	inc    %edx
  8016e6:	8b 04 95 1c 2e 80 00 	mov    0x802e1c(,%edx,4),%eax
  8016ed:	85 c0                	test   %eax,%eax
  8016ef:	75 e7                	jne    8016d8 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8016f1:	a1 04 40 80 00       	mov    0x804004,%eax
  8016f6:	8b 40 48             	mov    0x48(%eax),%eax
  8016f9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8016fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801701:	c7 04 24 9c 2d 80 00 	movl   $0x802d9c,(%esp)
  801708:	e8 bf f1 ff ff       	call   8008cc <cprintf>
	*dev = 0;
  80170d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801713:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801718:	83 c4 14             	add    $0x14,%esp
  80171b:	5b                   	pop    %ebx
  80171c:	5d                   	pop    %ebp
  80171d:	c3                   	ret    

0080171e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80171e:	55                   	push   %ebp
  80171f:	89 e5                	mov    %esp,%ebp
  801721:	56                   	push   %esi
  801722:	53                   	push   %ebx
  801723:	83 ec 30             	sub    $0x30,%esp
  801726:	8b 75 08             	mov    0x8(%ebp),%esi
  801729:	8a 45 0c             	mov    0xc(%ebp),%al
  80172c:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80172f:	89 34 24             	mov    %esi,(%esp)
  801732:	e8 b9 fe ff ff       	call   8015f0 <fd2num>
  801737:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80173a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80173e:	89 04 24             	mov    %eax,(%esp)
  801741:	e8 28 ff ff ff       	call   80166e <fd_lookup>
  801746:	89 c3                	mov    %eax,%ebx
  801748:	85 c0                	test   %eax,%eax
  80174a:	78 05                	js     801751 <fd_close+0x33>
	    || fd != fd2)
  80174c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80174f:	74 0d                	je     80175e <fd_close+0x40>
		return (must_exist ? r : 0);
  801751:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801755:	75 46                	jne    80179d <fd_close+0x7f>
  801757:	bb 00 00 00 00       	mov    $0x0,%ebx
  80175c:	eb 3f                	jmp    80179d <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80175e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801761:	89 44 24 04          	mov    %eax,0x4(%esp)
  801765:	8b 06                	mov    (%esi),%eax
  801767:	89 04 24             	mov    %eax,(%esp)
  80176a:	e8 55 ff ff ff       	call   8016c4 <dev_lookup>
  80176f:	89 c3                	mov    %eax,%ebx
  801771:	85 c0                	test   %eax,%eax
  801773:	78 18                	js     80178d <fd_close+0x6f>
		if (dev->dev_close)
  801775:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801778:	8b 40 10             	mov    0x10(%eax),%eax
  80177b:	85 c0                	test   %eax,%eax
  80177d:	74 09                	je     801788 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80177f:	89 34 24             	mov    %esi,(%esp)
  801782:	ff d0                	call   *%eax
  801784:	89 c3                	mov    %eax,%ebx
  801786:	eb 05                	jmp    80178d <fd_close+0x6f>
		else
			r = 0;
  801788:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80178d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801791:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801798:	e8 73 fb ff ff       	call   801310 <sys_page_unmap>
	return r;
}
  80179d:	89 d8                	mov    %ebx,%eax
  80179f:	83 c4 30             	add    $0x30,%esp
  8017a2:	5b                   	pop    %ebx
  8017a3:	5e                   	pop    %esi
  8017a4:	5d                   	pop    %ebp
  8017a5:	c3                   	ret    

008017a6 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8017a6:	55                   	push   %ebp
  8017a7:	89 e5                	mov    %esp,%ebp
  8017a9:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b6:	89 04 24             	mov    %eax,(%esp)
  8017b9:	e8 b0 fe ff ff       	call   80166e <fd_lookup>
  8017be:	85 c0                	test   %eax,%eax
  8017c0:	78 13                	js     8017d5 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8017c2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8017c9:	00 
  8017ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017cd:	89 04 24             	mov    %eax,(%esp)
  8017d0:	e8 49 ff ff ff       	call   80171e <fd_close>
}
  8017d5:	c9                   	leave  
  8017d6:	c3                   	ret    

008017d7 <close_all>:

void
close_all(void)
{
  8017d7:	55                   	push   %ebp
  8017d8:	89 e5                	mov    %esp,%ebp
  8017da:	53                   	push   %ebx
  8017db:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8017de:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8017e3:	89 1c 24             	mov    %ebx,(%esp)
  8017e6:	e8 bb ff ff ff       	call   8017a6 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8017eb:	43                   	inc    %ebx
  8017ec:	83 fb 20             	cmp    $0x20,%ebx
  8017ef:	75 f2                	jne    8017e3 <close_all+0xc>
		close(i);
}
  8017f1:	83 c4 14             	add    $0x14,%esp
  8017f4:	5b                   	pop    %ebx
  8017f5:	5d                   	pop    %ebp
  8017f6:	c3                   	ret    

008017f7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8017f7:	55                   	push   %ebp
  8017f8:	89 e5                	mov    %esp,%ebp
  8017fa:	57                   	push   %edi
  8017fb:	56                   	push   %esi
  8017fc:	53                   	push   %ebx
  8017fd:	83 ec 4c             	sub    $0x4c,%esp
  801800:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801803:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801806:	89 44 24 04          	mov    %eax,0x4(%esp)
  80180a:	8b 45 08             	mov    0x8(%ebp),%eax
  80180d:	89 04 24             	mov    %eax,(%esp)
  801810:	e8 59 fe ff ff       	call   80166e <fd_lookup>
  801815:	89 c3                	mov    %eax,%ebx
  801817:	85 c0                	test   %eax,%eax
  801819:	0f 88 e1 00 00 00    	js     801900 <dup+0x109>
		return r;
	close(newfdnum);
  80181f:	89 3c 24             	mov    %edi,(%esp)
  801822:	e8 7f ff ff ff       	call   8017a6 <close>

	newfd = INDEX2FD(newfdnum);
  801827:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80182d:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801830:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801833:	89 04 24             	mov    %eax,(%esp)
  801836:	e8 c5 fd ff ff       	call   801600 <fd2data>
  80183b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80183d:	89 34 24             	mov    %esi,(%esp)
  801840:	e8 bb fd ff ff       	call   801600 <fd2data>
  801845:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801848:	89 d8                	mov    %ebx,%eax
  80184a:	c1 e8 16             	shr    $0x16,%eax
  80184d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801854:	a8 01                	test   $0x1,%al
  801856:	74 46                	je     80189e <dup+0xa7>
  801858:	89 d8                	mov    %ebx,%eax
  80185a:	c1 e8 0c             	shr    $0xc,%eax
  80185d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801864:	f6 c2 01             	test   $0x1,%dl
  801867:	74 35                	je     80189e <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801869:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801870:	25 07 0e 00 00       	and    $0xe07,%eax
  801875:	89 44 24 10          	mov    %eax,0x10(%esp)
  801879:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80187c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801880:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801887:	00 
  801888:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80188c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801893:	e8 25 fa ff ff       	call   8012bd <sys_page_map>
  801898:	89 c3                	mov    %eax,%ebx
  80189a:	85 c0                	test   %eax,%eax
  80189c:	78 3b                	js     8018d9 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80189e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018a1:	89 c2                	mov    %eax,%edx
  8018a3:	c1 ea 0c             	shr    $0xc,%edx
  8018a6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8018ad:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8018b3:	89 54 24 10          	mov    %edx,0x10(%esp)
  8018b7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8018bb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8018c2:	00 
  8018c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018ce:	e8 ea f9 ff ff       	call   8012bd <sys_page_map>
  8018d3:	89 c3                	mov    %eax,%ebx
  8018d5:	85 c0                	test   %eax,%eax
  8018d7:	79 25                	jns    8018fe <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8018d9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018dd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018e4:	e8 27 fa ff ff       	call   801310 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8018e9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8018ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018f7:	e8 14 fa ff ff       	call   801310 <sys_page_unmap>
	return r;
  8018fc:	eb 02                	jmp    801900 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8018fe:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801900:	89 d8                	mov    %ebx,%eax
  801902:	83 c4 4c             	add    $0x4c,%esp
  801905:	5b                   	pop    %ebx
  801906:	5e                   	pop    %esi
  801907:	5f                   	pop    %edi
  801908:	5d                   	pop    %ebp
  801909:	c3                   	ret    

0080190a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80190a:	55                   	push   %ebp
  80190b:	89 e5                	mov    %esp,%ebp
  80190d:	53                   	push   %ebx
  80190e:	83 ec 24             	sub    $0x24,%esp
  801911:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801914:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801917:	89 44 24 04          	mov    %eax,0x4(%esp)
  80191b:	89 1c 24             	mov    %ebx,(%esp)
  80191e:	e8 4b fd ff ff       	call   80166e <fd_lookup>
  801923:	85 c0                	test   %eax,%eax
  801925:	78 6d                	js     801994 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801927:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80192a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80192e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801931:	8b 00                	mov    (%eax),%eax
  801933:	89 04 24             	mov    %eax,(%esp)
  801936:	e8 89 fd ff ff       	call   8016c4 <dev_lookup>
  80193b:	85 c0                	test   %eax,%eax
  80193d:	78 55                	js     801994 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80193f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801942:	8b 50 08             	mov    0x8(%eax),%edx
  801945:	83 e2 03             	and    $0x3,%edx
  801948:	83 fa 01             	cmp    $0x1,%edx
  80194b:	75 23                	jne    801970 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80194d:	a1 04 40 80 00       	mov    0x804004,%eax
  801952:	8b 40 48             	mov    0x48(%eax),%eax
  801955:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801959:	89 44 24 04          	mov    %eax,0x4(%esp)
  80195d:	c7 04 24 e0 2d 80 00 	movl   $0x802de0,(%esp)
  801964:	e8 63 ef ff ff       	call   8008cc <cprintf>
		return -E_INVAL;
  801969:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80196e:	eb 24                	jmp    801994 <read+0x8a>
	}
	if (!dev->dev_read)
  801970:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801973:	8b 52 08             	mov    0x8(%edx),%edx
  801976:	85 d2                	test   %edx,%edx
  801978:	74 15                	je     80198f <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80197a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80197d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801981:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801984:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801988:	89 04 24             	mov    %eax,(%esp)
  80198b:	ff d2                	call   *%edx
  80198d:	eb 05                	jmp    801994 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80198f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801994:	83 c4 24             	add    $0x24,%esp
  801997:	5b                   	pop    %ebx
  801998:	5d                   	pop    %ebp
  801999:	c3                   	ret    

0080199a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80199a:	55                   	push   %ebp
  80199b:	89 e5                	mov    %esp,%ebp
  80199d:	57                   	push   %edi
  80199e:	56                   	push   %esi
  80199f:	53                   	push   %ebx
  8019a0:	83 ec 1c             	sub    $0x1c,%esp
  8019a3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8019a6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8019a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019ae:	eb 23                	jmp    8019d3 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8019b0:	89 f0                	mov    %esi,%eax
  8019b2:	29 d8                	sub    %ebx,%eax
  8019b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019bb:	01 d8                	add    %ebx,%eax
  8019bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019c1:	89 3c 24             	mov    %edi,(%esp)
  8019c4:	e8 41 ff ff ff       	call   80190a <read>
		if (m < 0)
  8019c9:	85 c0                	test   %eax,%eax
  8019cb:	78 10                	js     8019dd <readn+0x43>
			return m;
		if (m == 0)
  8019cd:	85 c0                	test   %eax,%eax
  8019cf:	74 0a                	je     8019db <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8019d1:	01 c3                	add    %eax,%ebx
  8019d3:	39 f3                	cmp    %esi,%ebx
  8019d5:	72 d9                	jb     8019b0 <readn+0x16>
  8019d7:	89 d8                	mov    %ebx,%eax
  8019d9:	eb 02                	jmp    8019dd <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8019db:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8019dd:	83 c4 1c             	add    $0x1c,%esp
  8019e0:	5b                   	pop    %ebx
  8019e1:	5e                   	pop    %esi
  8019e2:	5f                   	pop    %edi
  8019e3:	5d                   	pop    %ebp
  8019e4:	c3                   	ret    

008019e5 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8019e5:	55                   	push   %ebp
  8019e6:	89 e5                	mov    %esp,%ebp
  8019e8:	53                   	push   %ebx
  8019e9:	83 ec 24             	sub    $0x24,%esp
  8019ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019f6:	89 1c 24             	mov    %ebx,(%esp)
  8019f9:	e8 70 fc ff ff       	call   80166e <fd_lookup>
  8019fe:	85 c0                	test   %eax,%eax
  801a00:	78 68                	js     801a6a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a02:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a05:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a09:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a0c:	8b 00                	mov    (%eax),%eax
  801a0e:	89 04 24             	mov    %eax,(%esp)
  801a11:	e8 ae fc ff ff       	call   8016c4 <dev_lookup>
  801a16:	85 c0                	test   %eax,%eax
  801a18:	78 50                	js     801a6a <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801a1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a1d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801a21:	75 23                	jne    801a46 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801a23:	a1 04 40 80 00       	mov    0x804004,%eax
  801a28:	8b 40 48             	mov    0x48(%eax),%eax
  801a2b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a2f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a33:	c7 04 24 fc 2d 80 00 	movl   $0x802dfc,(%esp)
  801a3a:	e8 8d ee ff ff       	call   8008cc <cprintf>
		return -E_INVAL;
  801a3f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a44:	eb 24                	jmp    801a6a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801a46:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a49:	8b 52 0c             	mov    0xc(%edx),%edx
  801a4c:	85 d2                	test   %edx,%edx
  801a4e:	74 15                	je     801a65 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801a50:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801a53:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801a57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a5a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801a5e:	89 04 24             	mov    %eax,(%esp)
  801a61:	ff d2                	call   *%edx
  801a63:	eb 05                	jmp    801a6a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801a65:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801a6a:	83 c4 24             	add    $0x24,%esp
  801a6d:	5b                   	pop    %ebx
  801a6e:	5d                   	pop    %ebp
  801a6f:	c3                   	ret    

00801a70 <seek>:

int
seek(int fdnum, off_t offset)
{
  801a70:	55                   	push   %ebp
  801a71:	89 e5                	mov    %esp,%ebp
  801a73:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a76:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801a79:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a7d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a80:	89 04 24             	mov    %eax,(%esp)
  801a83:	e8 e6 fb ff ff       	call   80166e <fd_lookup>
  801a88:	85 c0                	test   %eax,%eax
  801a8a:	78 0e                	js     801a9a <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801a8c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801a8f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a92:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801a95:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a9a:	c9                   	leave  
  801a9b:	c3                   	ret    

00801a9c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801a9c:	55                   	push   %ebp
  801a9d:	89 e5                	mov    %esp,%ebp
  801a9f:	53                   	push   %ebx
  801aa0:	83 ec 24             	sub    $0x24,%esp
  801aa3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801aa6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801aa9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aad:	89 1c 24             	mov    %ebx,(%esp)
  801ab0:	e8 b9 fb ff ff       	call   80166e <fd_lookup>
  801ab5:	85 c0                	test   %eax,%eax
  801ab7:	78 61                	js     801b1a <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ab9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801abc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ac0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ac3:	8b 00                	mov    (%eax),%eax
  801ac5:	89 04 24             	mov    %eax,(%esp)
  801ac8:	e8 f7 fb ff ff       	call   8016c4 <dev_lookup>
  801acd:	85 c0                	test   %eax,%eax
  801acf:	78 49                	js     801b1a <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801ad1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ad4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801ad8:	75 23                	jne    801afd <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801ada:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801adf:	8b 40 48             	mov    0x48(%eax),%eax
  801ae2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ae6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aea:	c7 04 24 bc 2d 80 00 	movl   $0x802dbc,(%esp)
  801af1:	e8 d6 ed ff ff       	call   8008cc <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801af6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801afb:	eb 1d                	jmp    801b1a <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801afd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b00:	8b 52 18             	mov    0x18(%edx),%edx
  801b03:	85 d2                	test   %edx,%edx
  801b05:	74 0e                	je     801b15 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801b07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b0a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801b0e:	89 04 24             	mov    %eax,(%esp)
  801b11:	ff d2                	call   *%edx
  801b13:	eb 05                	jmp    801b1a <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801b15:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801b1a:	83 c4 24             	add    $0x24,%esp
  801b1d:	5b                   	pop    %ebx
  801b1e:	5d                   	pop    %ebp
  801b1f:	c3                   	ret    

00801b20 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801b20:	55                   	push   %ebp
  801b21:	89 e5                	mov    %esp,%ebp
  801b23:	53                   	push   %ebx
  801b24:	83 ec 24             	sub    $0x24,%esp
  801b27:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b2a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b2d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b31:	8b 45 08             	mov    0x8(%ebp),%eax
  801b34:	89 04 24             	mov    %eax,(%esp)
  801b37:	e8 32 fb ff ff       	call   80166e <fd_lookup>
  801b3c:	85 c0                	test   %eax,%eax
  801b3e:	78 52                	js     801b92 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b40:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b43:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b47:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b4a:	8b 00                	mov    (%eax),%eax
  801b4c:	89 04 24             	mov    %eax,(%esp)
  801b4f:	e8 70 fb ff ff       	call   8016c4 <dev_lookup>
  801b54:	85 c0                	test   %eax,%eax
  801b56:	78 3a                	js     801b92 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801b58:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b5b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801b5f:	74 2c                	je     801b8d <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801b61:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801b64:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801b6b:	00 00 00 
	stat->st_isdir = 0;
  801b6e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b75:	00 00 00 
	stat->st_dev = dev;
  801b78:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801b7e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b82:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801b85:	89 14 24             	mov    %edx,(%esp)
  801b88:	ff 50 14             	call   *0x14(%eax)
  801b8b:	eb 05                	jmp    801b92 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801b8d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801b92:	83 c4 24             	add    $0x24,%esp
  801b95:	5b                   	pop    %ebx
  801b96:	5d                   	pop    %ebp
  801b97:	c3                   	ret    

00801b98 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801b98:	55                   	push   %ebp
  801b99:	89 e5                	mov    %esp,%ebp
  801b9b:	56                   	push   %esi
  801b9c:	53                   	push   %ebx
  801b9d:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801ba0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801ba7:	00 
  801ba8:	8b 45 08             	mov    0x8(%ebp),%eax
  801bab:	89 04 24             	mov    %eax,(%esp)
  801bae:	e8 2d 02 00 00       	call   801de0 <open>
  801bb3:	89 c3                	mov    %eax,%ebx
  801bb5:	85 c0                	test   %eax,%eax
  801bb7:	78 1b                	js     801bd4 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801bb9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bbc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bc0:	89 1c 24             	mov    %ebx,(%esp)
  801bc3:	e8 58 ff ff ff       	call   801b20 <fstat>
  801bc8:	89 c6                	mov    %eax,%esi
	close(fd);
  801bca:	89 1c 24             	mov    %ebx,(%esp)
  801bcd:	e8 d4 fb ff ff       	call   8017a6 <close>
	return r;
  801bd2:	89 f3                	mov    %esi,%ebx
}
  801bd4:	89 d8                	mov    %ebx,%eax
  801bd6:	83 c4 10             	add    $0x10,%esp
  801bd9:	5b                   	pop    %ebx
  801bda:	5e                   	pop    %esi
  801bdb:	5d                   	pop    %ebp
  801bdc:	c3                   	ret    
  801bdd:	00 00                	add    %al,(%eax)
	...

00801be0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801be0:	55                   	push   %ebp
  801be1:	89 e5                	mov    %esp,%ebp
  801be3:	56                   	push   %esi
  801be4:	53                   	push   %ebx
  801be5:	83 ec 10             	sub    $0x10,%esp
  801be8:	89 c3                	mov    %eax,%ebx
  801bea:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801bec:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801bf3:	75 11                	jne    801c06 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801bf5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801bfc:	e8 aa f9 ff ff       	call   8015ab <ipc_find_env>
  801c01:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801c06:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801c0d:	00 
  801c0e:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801c15:	00 
  801c16:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c1a:	a1 00 40 80 00       	mov    0x804000,%eax
  801c1f:	89 04 24             	mov    %eax,(%esp)
  801c22:	e8 16 f9 ff ff       	call   80153d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801c27:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c2e:	00 
  801c2f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c33:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c3a:	e8 95 f8 ff ff       	call   8014d4 <ipc_recv>
}
  801c3f:	83 c4 10             	add    $0x10,%esp
  801c42:	5b                   	pop    %ebx
  801c43:	5e                   	pop    %esi
  801c44:	5d                   	pop    %ebp
  801c45:	c3                   	ret    

00801c46 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801c46:	55                   	push   %ebp
  801c47:	89 e5                	mov    %esp,%ebp
  801c49:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801c4c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4f:	8b 40 0c             	mov    0xc(%eax),%eax
  801c52:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801c57:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c5a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801c5f:	ba 00 00 00 00       	mov    $0x0,%edx
  801c64:	b8 02 00 00 00       	mov    $0x2,%eax
  801c69:	e8 72 ff ff ff       	call   801be0 <fsipc>
}
  801c6e:	c9                   	leave  
  801c6f:	c3                   	ret    

00801c70 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801c70:	55                   	push   %ebp
  801c71:	89 e5                	mov    %esp,%ebp
  801c73:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801c76:	8b 45 08             	mov    0x8(%ebp),%eax
  801c79:	8b 40 0c             	mov    0xc(%eax),%eax
  801c7c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801c81:	ba 00 00 00 00       	mov    $0x0,%edx
  801c86:	b8 06 00 00 00       	mov    $0x6,%eax
  801c8b:	e8 50 ff ff ff       	call   801be0 <fsipc>
}
  801c90:	c9                   	leave  
  801c91:	c3                   	ret    

00801c92 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801c92:	55                   	push   %ebp
  801c93:	89 e5                	mov    %esp,%ebp
  801c95:	53                   	push   %ebx
  801c96:	83 ec 14             	sub    $0x14,%esp
  801c99:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801c9c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c9f:	8b 40 0c             	mov    0xc(%eax),%eax
  801ca2:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801ca7:	ba 00 00 00 00       	mov    $0x0,%edx
  801cac:	b8 05 00 00 00       	mov    $0x5,%eax
  801cb1:	e8 2a ff ff ff       	call   801be0 <fsipc>
  801cb6:	85 c0                	test   %eax,%eax
  801cb8:	78 2b                	js     801ce5 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801cba:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801cc1:	00 
  801cc2:	89 1c 24             	mov    %ebx,(%esp)
  801cc5:	e8 ad f1 ff ff       	call   800e77 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801cca:	a1 80 50 80 00       	mov    0x805080,%eax
  801ccf:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801cd5:	a1 84 50 80 00       	mov    0x805084,%eax
  801cda:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801ce0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ce5:	83 c4 14             	add    $0x14,%esp
  801ce8:	5b                   	pop    %ebx
  801ce9:	5d                   	pop    %ebp
  801cea:	c3                   	ret    

00801ceb <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801ceb:	55                   	push   %ebp
  801cec:	89 e5                	mov    %esp,%ebp
  801cee:	83 ec 18             	sub    $0x18,%esp
  801cf1:	8b 55 10             	mov    0x10(%ebp),%edx
  801cf4:	89 d0                	mov    %edx,%eax
  801cf6:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  801cfc:	76 05                	jbe    801d03 <devfile_write+0x18>
  801cfe:	b8 00 10 00 00       	mov    $0x1000,%eax
	//panic("devfile_write not implemented");
	int r;
	//uint32_t maxsize = BLKSIZE - sizeof(int) - sizeof(size_t);	
	if (n > BLKSIZE)
		n = BLKSIZE;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801d03:	8b 55 08             	mov    0x8(%ebp),%edx
  801d06:	8b 52 0c             	mov    0xc(%edx),%edx
  801d09:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801d0f:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801d14:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d18:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d1b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d1f:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801d26:	e8 c5 f2 ff ff       	call   800ff0 <memmove>
	 
	return fsipc(FSREQ_WRITE, NULL);
  801d2b:	ba 00 00 00 00       	mov    $0x0,%edx
  801d30:	b8 04 00 00 00       	mov    $0x4,%eax
  801d35:	e8 a6 fe ff ff       	call   801be0 <fsipc>
}
  801d3a:	c9                   	leave  
  801d3b:	c3                   	ret    

00801d3c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801d3c:	55                   	push   %ebp
  801d3d:	89 e5                	mov    %esp,%ebp
  801d3f:	56                   	push   %esi
  801d40:	53                   	push   %ebx
  801d41:	83 ec 10             	sub    $0x10,%esp
  801d44:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801d47:	8b 45 08             	mov    0x8(%ebp),%eax
  801d4a:	8b 40 0c             	mov    0xc(%eax),%eax
  801d4d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801d52:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801d58:	ba 00 00 00 00       	mov    $0x0,%edx
  801d5d:	b8 03 00 00 00       	mov    $0x3,%eax
  801d62:	e8 79 fe ff ff       	call   801be0 <fsipc>
  801d67:	89 c3                	mov    %eax,%ebx
  801d69:	85 c0                	test   %eax,%eax
  801d6b:	78 6a                	js     801dd7 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801d6d:	39 c6                	cmp    %eax,%esi
  801d6f:	73 24                	jae    801d95 <devfile_read+0x59>
  801d71:	c7 44 24 0c 2c 2e 80 	movl   $0x802e2c,0xc(%esp)
  801d78:	00 
  801d79:	c7 44 24 08 33 2e 80 	movl   $0x802e33,0x8(%esp)
  801d80:	00 
  801d81:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801d88:	00 
  801d89:	c7 04 24 48 2e 80 00 	movl   $0x802e48,(%esp)
  801d90:	e8 3f ea ff ff       	call   8007d4 <_panic>
	assert(r <= PGSIZE);
  801d95:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801d9a:	7e 24                	jle    801dc0 <devfile_read+0x84>
  801d9c:	c7 44 24 0c 53 2e 80 	movl   $0x802e53,0xc(%esp)
  801da3:	00 
  801da4:	c7 44 24 08 33 2e 80 	movl   $0x802e33,0x8(%esp)
  801dab:	00 
  801dac:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801db3:	00 
  801db4:	c7 04 24 48 2e 80 00 	movl   $0x802e48,(%esp)
  801dbb:	e8 14 ea ff ff       	call   8007d4 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801dc0:	89 44 24 08          	mov    %eax,0x8(%esp)
  801dc4:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801dcb:	00 
  801dcc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dcf:	89 04 24             	mov    %eax,(%esp)
  801dd2:	e8 19 f2 ff ff       	call   800ff0 <memmove>
	return r;
}
  801dd7:	89 d8                	mov    %ebx,%eax
  801dd9:	83 c4 10             	add    $0x10,%esp
  801ddc:	5b                   	pop    %ebx
  801ddd:	5e                   	pop    %esi
  801dde:	5d                   	pop    %ebp
  801ddf:	c3                   	ret    

00801de0 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801de0:	55                   	push   %ebp
  801de1:	89 e5                	mov    %esp,%ebp
  801de3:	56                   	push   %esi
  801de4:	53                   	push   %ebx
  801de5:	83 ec 20             	sub    $0x20,%esp
  801de8:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801deb:	89 34 24             	mov    %esi,(%esp)
  801dee:	e8 51 f0 ff ff       	call   800e44 <strlen>
  801df3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801df8:	7f 60                	jg     801e5a <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801dfa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dfd:	89 04 24             	mov    %eax,(%esp)
  801e00:	e8 16 f8 ff ff       	call   80161b <fd_alloc>
  801e05:	89 c3                	mov    %eax,%ebx
  801e07:	85 c0                	test   %eax,%eax
  801e09:	78 54                	js     801e5f <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801e0b:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e0f:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801e16:	e8 5c f0 ff ff       	call   800e77 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801e1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e1e:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801e23:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e26:	b8 01 00 00 00       	mov    $0x1,%eax
  801e2b:	e8 b0 fd ff ff       	call   801be0 <fsipc>
  801e30:	89 c3                	mov    %eax,%ebx
  801e32:	85 c0                	test   %eax,%eax
  801e34:	79 15                	jns    801e4b <open+0x6b>
		fd_close(fd, 0);
  801e36:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801e3d:	00 
  801e3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e41:	89 04 24             	mov    %eax,(%esp)
  801e44:	e8 d5 f8 ff ff       	call   80171e <fd_close>
		return r;
  801e49:	eb 14                	jmp    801e5f <open+0x7f>
	}

	return fd2num(fd);
  801e4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e4e:	89 04 24             	mov    %eax,(%esp)
  801e51:	e8 9a f7 ff ff       	call   8015f0 <fd2num>
  801e56:	89 c3                	mov    %eax,%ebx
  801e58:	eb 05                	jmp    801e5f <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801e5a:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801e5f:	89 d8                	mov    %ebx,%eax
  801e61:	83 c4 20             	add    $0x20,%esp
  801e64:	5b                   	pop    %ebx
  801e65:	5e                   	pop    %esi
  801e66:	5d                   	pop    %ebp
  801e67:	c3                   	ret    

00801e68 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801e68:	55                   	push   %ebp
  801e69:	89 e5                	mov    %esp,%ebp
  801e6b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801e6e:	ba 00 00 00 00       	mov    $0x0,%edx
  801e73:	b8 08 00 00 00       	mov    $0x8,%eax
  801e78:	e8 63 fd ff ff       	call   801be0 <fsipc>
}
  801e7d:	c9                   	leave  
  801e7e:	c3                   	ret    
	...

00801e80 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e80:	55                   	push   %ebp
  801e81:	89 e5                	mov    %esp,%ebp
  801e83:	56                   	push   %esi
  801e84:	53                   	push   %ebx
  801e85:	83 ec 10             	sub    $0x10,%esp
  801e88:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e8e:	89 04 24             	mov    %eax,(%esp)
  801e91:	e8 6a f7 ff ff       	call   801600 <fd2data>
  801e96:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801e98:	c7 44 24 04 5f 2e 80 	movl   $0x802e5f,0x4(%esp)
  801e9f:	00 
  801ea0:	89 34 24             	mov    %esi,(%esp)
  801ea3:	e8 cf ef ff ff       	call   800e77 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ea8:	8b 43 04             	mov    0x4(%ebx),%eax
  801eab:	2b 03                	sub    (%ebx),%eax
  801ead:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801eb3:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801eba:	00 00 00 
	stat->st_dev = &devpipe;
  801ebd:	c7 86 88 00 00 00 24 	movl   $0x803024,0x88(%esi)
  801ec4:	30 80 00 
	return 0;
}
  801ec7:	b8 00 00 00 00       	mov    $0x0,%eax
  801ecc:	83 c4 10             	add    $0x10,%esp
  801ecf:	5b                   	pop    %ebx
  801ed0:	5e                   	pop    %esi
  801ed1:	5d                   	pop    %ebp
  801ed2:	c3                   	ret    

00801ed3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ed3:	55                   	push   %ebp
  801ed4:	89 e5                	mov    %esp,%ebp
  801ed6:	53                   	push   %ebx
  801ed7:	83 ec 14             	sub    $0x14,%esp
  801eda:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801edd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ee1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ee8:	e8 23 f4 ff ff       	call   801310 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801eed:	89 1c 24             	mov    %ebx,(%esp)
  801ef0:	e8 0b f7 ff ff       	call   801600 <fd2data>
  801ef5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ef9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f00:	e8 0b f4 ff ff       	call   801310 <sys_page_unmap>
}
  801f05:	83 c4 14             	add    $0x14,%esp
  801f08:	5b                   	pop    %ebx
  801f09:	5d                   	pop    %ebp
  801f0a:	c3                   	ret    

00801f0b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801f0b:	55                   	push   %ebp
  801f0c:	89 e5                	mov    %esp,%ebp
  801f0e:	57                   	push   %edi
  801f0f:	56                   	push   %esi
  801f10:	53                   	push   %ebx
  801f11:	83 ec 2c             	sub    $0x2c,%esp
  801f14:	89 c7                	mov    %eax,%edi
  801f16:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801f19:	a1 04 40 80 00       	mov    0x804004,%eax
  801f1e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801f21:	89 3c 24             	mov    %edi,(%esp)
  801f24:	e8 6f 04 00 00       	call   802398 <pageref>
  801f29:	89 c6                	mov    %eax,%esi
  801f2b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f2e:	89 04 24             	mov    %eax,(%esp)
  801f31:	e8 62 04 00 00       	call   802398 <pageref>
  801f36:	39 c6                	cmp    %eax,%esi
  801f38:	0f 94 c0             	sete   %al
  801f3b:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801f3e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801f44:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f47:	39 cb                	cmp    %ecx,%ebx
  801f49:	75 08                	jne    801f53 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801f4b:	83 c4 2c             	add    $0x2c,%esp
  801f4e:	5b                   	pop    %ebx
  801f4f:	5e                   	pop    %esi
  801f50:	5f                   	pop    %edi
  801f51:	5d                   	pop    %ebp
  801f52:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801f53:	83 f8 01             	cmp    $0x1,%eax
  801f56:	75 c1                	jne    801f19 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f58:	8b 42 58             	mov    0x58(%edx),%eax
  801f5b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801f62:	00 
  801f63:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f67:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f6b:	c7 04 24 66 2e 80 00 	movl   $0x802e66,(%esp)
  801f72:	e8 55 e9 ff ff       	call   8008cc <cprintf>
  801f77:	eb a0                	jmp    801f19 <_pipeisclosed+0xe>

00801f79 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f79:	55                   	push   %ebp
  801f7a:	89 e5                	mov    %esp,%ebp
  801f7c:	57                   	push   %edi
  801f7d:	56                   	push   %esi
  801f7e:	53                   	push   %ebx
  801f7f:	83 ec 1c             	sub    $0x1c,%esp
  801f82:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f85:	89 34 24             	mov    %esi,(%esp)
  801f88:	e8 73 f6 ff ff       	call   801600 <fd2data>
  801f8d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f8f:	bf 00 00 00 00       	mov    $0x0,%edi
  801f94:	eb 3c                	jmp    801fd2 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f96:	89 da                	mov    %ebx,%edx
  801f98:	89 f0                	mov    %esi,%eax
  801f9a:	e8 6c ff ff ff       	call   801f0b <_pipeisclosed>
  801f9f:	85 c0                	test   %eax,%eax
  801fa1:	75 38                	jne    801fdb <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801fa3:	e8 a2 f2 ff ff       	call   80124a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801fa8:	8b 43 04             	mov    0x4(%ebx),%eax
  801fab:	8b 13                	mov    (%ebx),%edx
  801fad:	83 c2 20             	add    $0x20,%edx
  801fb0:	39 d0                	cmp    %edx,%eax
  801fb2:	73 e2                	jae    801f96 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801fb4:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fb7:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801fba:	89 c2                	mov    %eax,%edx
  801fbc:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801fc2:	79 05                	jns    801fc9 <devpipe_write+0x50>
  801fc4:	4a                   	dec    %edx
  801fc5:	83 ca e0             	or     $0xffffffe0,%edx
  801fc8:	42                   	inc    %edx
  801fc9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801fcd:	40                   	inc    %eax
  801fce:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fd1:	47                   	inc    %edi
  801fd2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801fd5:	75 d1                	jne    801fa8 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801fd7:	89 f8                	mov    %edi,%eax
  801fd9:	eb 05                	jmp    801fe0 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801fdb:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801fe0:	83 c4 1c             	add    $0x1c,%esp
  801fe3:	5b                   	pop    %ebx
  801fe4:	5e                   	pop    %esi
  801fe5:	5f                   	pop    %edi
  801fe6:	5d                   	pop    %ebp
  801fe7:	c3                   	ret    

00801fe8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fe8:	55                   	push   %ebp
  801fe9:	89 e5                	mov    %esp,%ebp
  801feb:	57                   	push   %edi
  801fec:	56                   	push   %esi
  801fed:	53                   	push   %ebx
  801fee:	83 ec 1c             	sub    $0x1c,%esp
  801ff1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ff4:	89 3c 24             	mov    %edi,(%esp)
  801ff7:	e8 04 f6 ff ff       	call   801600 <fd2data>
  801ffc:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ffe:	be 00 00 00 00       	mov    $0x0,%esi
  802003:	eb 3a                	jmp    80203f <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802005:	85 f6                	test   %esi,%esi
  802007:	74 04                	je     80200d <devpipe_read+0x25>
				return i;
  802009:	89 f0                	mov    %esi,%eax
  80200b:	eb 40                	jmp    80204d <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80200d:	89 da                	mov    %ebx,%edx
  80200f:	89 f8                	mov    %edi,%eax
  802011:	e8 f5 fe ff ff       	call   801f0b <_pipeisclosed>
  802016:	85 c0                	test   %eax,%eax
  802018:	75 2e                	jne    802048 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80201a:	e8 2b f2 ff ff       	call   80124a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80201f:	8b 03                	mov    (%ebx),%eax
  802021:	3b 43 04             	cmp    0x4(%ebx),%eax
  802024:	74 df                	je     802005 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802026:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80202b:	79 05                	jns    802032 <devpipe_read+0x4a>
  80202d:	48                   	dec    %eax
  80202e:	83 c8 e0             	or     $0xffffffe0,%eax
  802031:	40                   	inc    %eax
  802032:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  802036:	8b 55 0c             	mov    0xc(%ebp),%edx
  802039:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  80203c:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80203e:	46                   	inc    %esi
  80203f:	3b 75 10             	cmp    0x10(%ebp),%esi
  802042:	75 db                	jne    80201f <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802044:	89 f0                	mov    %esi,%eax
  802046:	eb 05                	jmp    80204d <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802048:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80204d:	83 c4 1c             	add    $0x1c,%esp
  802050:	5b                   	pop    %ebx
  802051:	5e                   	pop    %esi
  802052:	5f                   	pop    %edi
  802053:	5d                   	pop    %ebp
  802054:	c3                   	ret    

00802055 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802055:	55                   	push   %ebp
  802056:	89 e5                	mov    %esp,%ebp
  802058:	57                   	push   %edi
  802059:	56                   	push   %esi
  80205a:	53                   	push   %ebx
  80205b:	83 ec 3c             	sub    $0x3c,%esp
  80205e:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802061:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802064:	89 04 24             	mov    %eax,(%esp)
  802067:	e8 af f5 ff ff       	call   80161b <fd_alloc>
  80206c:	89 c3                	mov    %eax,%ebx
  80206e:	85 c0                	test   %eax,%eax
  802070:	0f 88 45 01 00 00    	js     8021bb <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802076:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80207d:	00 
  80207e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802081:	89 44 24 04          	mov    %eax,0x4(%esp)
  802085:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80208c:	e8 d8 f1 ff ff       	call   801269 <sys_page_alloc>
  802091:	89 c3                	mov    %eax,%ebx
  802093:	85 c0                	test   %eax,%eax
  802095:	0f 88 20 01 00 00    	js     8021bb <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80209b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80209e:	89 04 24             	mov    %eax,(%esp)
  8020a1:	e8 75 f5 ff ff       	call   80161b <fd_alloc>
  8020a6:	89 c3                	mov    %eax,%ebx
  8020a8:	85 c0                	test   %eax,%eax
  8020aa:	0f 88 f8 00 00 00    	js     8021a8 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020b0:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8020b7:	00 
  8020b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8020bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020c6:	e8 9e f1 ff ff       	call   801269 <sys_page_alloc>
  8020cb:	89 c3                	mov    %eax,%ebx
  8020cd:	85 c0                	test   %eax,%eax
  8020cf:	0f 88 d3 00 00 00    	js     8021a8 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8020d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020d8:	89 04 24             	mov    %eax,(%esp)
  8020db:	e8 20 f5 ff ff       	call   801600 <fd2data>
  8020e0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020e2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8020e9:	00 
  8020ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020ee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020f5:	e8 6f f1 ff ff       	call   801269 <sys_page_alloc>
  8020fa:	89 c3                	mov    %eax,%ebx
  8020fc:	85 c0                	test   %eax,%eax
  8020fe:	0f 88 91 00 00 00    	js     802195 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802104:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802107:	89 04 24             	mov    %eax,(%esp)
  80210a:	e8 f1 f4 ff ff       	call   801600 <fd2data>
  80210f:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802116:	00 
  802117:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80211b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802122:	00 
  802123:	89 74 24 04          	mov    %esi,0x4(%esp)
  802127:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80212e:	e8 8a f1 ff ff       	call   8012bd <sys_page_map>
  802133:	89 c3                	mov    %eax,%ebx
  802135:	85 c0                	test   %eax,%eax
  802137:	78 4c                	js     802185 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802139:	8b 15 24 30 80 00    	mov    0x803024,%edx
  80213f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802142:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802144:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802147:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80214e:	8b 15 24 30 80 00    	mov    0x803024,%edx
  802154:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802157:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802159:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80215c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802163:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802166:	89 04 24             	mov    %eax,(%esp)
  802169:	e8 82 f4 ff ff       	call   8015f0 <fd2num>
  80216e:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802170:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802173:	89 04 24             	mov    %eax,(%esp)
  802176:	e8 75 f4 ff ff       	call   8015f0 <fd2num>
  80217b:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  80217e:	bb 00 00 00 00       	mov    $0x0,%ebx
  802183:	eb 36                	jmp    8021bb <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  802185:	89 74 24 04          	mov    %esi,0x4(%esp)
  802189:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802190:	e8 7b f1 ff ff       	call   801310 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802195:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802198:	89 44 24 04          	mov    %eax,0x4(%esp)
  80219c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021a3:	e8 68 f1 ff ff       	call   801310 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8021a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8021ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021b6:	e8 55 f1 ff ff       	call   801310 <sys_page_unmap>
    err:
	return r;
}
  8021bb:	89 d8                	mov    %ebx,%eax
  8021bd:	83 c4 3c             	add    $0x3c,%esp
  8021c0:	5b                   	pop    %ebx
  8021c1:	5e                   	pop    %esi
  8021c2:	5f                   	pop    %edi
  8021c3:	5d                   	pop    %ebp
  8021c4:	c3                   	ret    

008021c5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8021c5:	55                   	push   %ebp
  8021c6:	89 e5                	mov    %esp,%ebp
  8021c8:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8021d5:	89 04 24             	mov    %eax,(%esp)
  8021d8:	e8 91 f4 ff ff       	call   80166e <fd_lookup>
  8021dd:	85 c0                	test   %eax,%eax
  8021df:	78 15                	js     8021f6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8021e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021e4:	89 04 24             	mov    %eax,(%esp)
  8021e7:	e8 14 f4 ff ff       	call   801600 <fd2data>
	return _pipeisclosed(fd, p);
  8021ec:	89 c2                	mov    %eax,%edx
  8021ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021f1:	e8 15 fd ff ff       	call   801f0b <_pipeisclosed>
}
  8021f6:	c9                   	leave  
  8021f7:	c3                   	ret    

008021f8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8021f8:	55                   	push   %ebp
  8021f9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8021fb:	b8 00 00 00 00       	mov    $0x0,%eax
  802200:	5d                   	pop    %ebp
  802201:	c3                   	ret    

00802202 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802202:	55                   	push   %ebp
  802203:	89 e5                	mov    %esp,%ebp
  802205:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802208:	c7 44 24 04 7e 2e 80 	movl   $0x802e7e,0x4(%esp)
  80220f:	00 
  802210:	8b 45 0c             	mov    0xc(%ebp),%eax
  802213:	89 04 24             	mov    %eax,(%esp)
  802216:	e8 5c ec ff ff       	call   800e77 <strcpy>
	return 0;
}
  80221b:	b8 00 00 00 00       	mov    $0x0,%eax
  802220:	c9                   	leave  
  802221:	c3                   	ret    

00802222 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802222:	55                   	push   %ebp
  802223:	89 e5                	mov    %esp,%ebp
  802225:	57                   	push   %edi
  802226:	56                   	push   %esi
  802227:	53                   	push   %ebx
  802228:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80222e:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802233:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802239:	eb 30                	jmp    80226b <devcons_write+0x49>
		m = n - tot;
  80223b:	8b 75 10             	mov    0x10(%ebp),%esi
  80223e:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802240:	83 fe 7f             	cmp    $0x7f,%esi
  802243:	76 05                	jbe    80224a <devcons_write+0x28>
			m = sizeof(buf) - 1;
  802245:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80224a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80224e:	03 45 0c             	add    0xc(%ebp),%eax
  802251:	89 44 24 04          	mov    %eax,0x4(%esp)
  802255:	89 3c 24             	mov    %edi,(%esp)
  802258:	e8 93 ed ff ff       	call   800ff0 <memmove>
		sys_cputs(buf, m);
  80225d:	89 74 24 04          	mov    %esi,0x4(%esp)
  802261:	89 3c 24             	mov    %edi,(%esp)
  802264:	e8 33 ef ff ff       	call   80119c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802269:	01 f3                	add    %esi,%ebx
  80226b:	89 d8                	mov    %ebx,%eax
  80226d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802270:	72 c9                	jb     80223b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802272:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802278:	5b                   	pop    %ebx
  802279:	5e                   	pop    %esi
  80227a:	5f                   	pop    %edi
  80227b:	5d                   	pop    %ebp
  80227c:	c3                   	ret    

0080227d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80227d:	55                   	push   %ebp
  80227e:	89 e5                	mov    %esp,%ebp
  802280:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  802283:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802287:	75 07                	jne    802290 <devcons_read+0x13>
  802289:	eb 25                	jmp    8022b0 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80228b:	e8 ba ef ff ff       	call   80124a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802290:	e8 25 ef ff ff       	call   8011ba <sys_cgetc>
  802295:	85 c0                	test   %eax,%eax
  802297:	74 f2                	je     80228b <devcons_read+0xe>
  802299:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80229b:	85 c0                	test   %eax,%eax
  80229d:	78 1d                	js     8022bc <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80229f:	83 f8 04             	cmp    $0x4,%eax
  8022a2:	74 13                	je     8022b7 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8022a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022a7:	88 10                	mov    %dl,(%eax)
	return 1;
  8022a9:	b8 01 00 00 00       	mov    $0x1,%eax
  8022ae:	eb 0c                	jmp    8022bc <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8022b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8022b5:	eb 05                	jmp    8022bc <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8022b7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8022bc:	c9                   	leave  
  8022bd:	c3                   	ret    

008022be <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8022be:	55                   	push   %ebp
  8022bf:	89 e5                	mov    %esp,%ebp
  8022c1:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8022c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8022c7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8022ca:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8022d1:	00 
  8022d2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022d5:	89 04 24             	mov    %eax,(%esp)
  8022d8:	e8 bf ee ff ff       	call   80119c <sys_cputs>
}
  8022dd:	c9                   	leave  
  8022de:	c3                   	ret    

008022df <getchar>:

int
getchar(void)
{
  8022df:	55                   	push   %ebp
  8022e0:	89 e5                	mov    %esp,%ebp
  8022e2:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8022e5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8022ec:	00 
  8022ed:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022f4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022fb:	e8 0a f6 ff ff       	call   80190a <read>
	if (r < 0)
  802300:	85 c0                	test   %eax,%eax
  802302:	78 0f                	js     802313 <getchar+0x34>
		return r;
	if (r < 1)
  802304:	85 c0                	test   %eax,%eax
  802306:	7e 06                	jle    80230e <getchar+0x2f>
		return -E_EOF;
	return c;
  802308:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80230c:	eb 05                	jmp    802313 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80230e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802313:	c9                   	leave  
  802314:	c3                   	ret    

00802315 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802315:	55                   	push   %ebp
  802316:	89 e5                	mov    %esp,%ebp
  802318:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80231b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80231e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802322:	8b 45 08             	mov    0x8(%ebp),%eax
  802325:	89 04 24             	mov    %eax,(%esp)
  802328:	e8 41 f3 ff ff       	call   80166e <fd_lookup>
  80232d:	85 c0                	test   %eax,%eax
  80232f:	78 11                	js     802342 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802331:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802334:	8b 15 40 30 80 00    	mov    0x803040,%edx
  80233a:	39 10                	cmp    %edx,(%eax)
  80233c:	0f 94 c0             	sete   %al
  80233f:	0f b6 c0             	movzbl %al,%eax
}
  802342:	c9                   	leave  
  802343:	c3                   	ret    

00802344 <opencons>:

int
opencons(void)
{
  802344:	55                   	push   %ebp
  802345:	89 e5                	mov    %esp,%ebp
  802347:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80234a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80234d:	89 04 24             	mov    %eax,(%esp)
  802350:	e8 c6 f2 ff ff       	call   80161b <fd_alloc>
  802355:	85 c0                	test   %eax,%eax
  802357:	78 3c                	js     802395 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802359:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802360:	00 
  802361:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802364:	89 44 24 04          	mov    %eax,0x4(%esp)
  802368:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80236f:	e8 f5 ee ff ff       	call   801269 <sys_page_alloc>
  802374:	85 c0                	test   %eax,%eax
  802376:	78 1d                	js     802395 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802378:	8b 15 40 30 80 00    	mov    0x803040,%edx
  80237e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802381:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802383:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802386:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80238d:	89 04 24             	mov    %eax,(%esp)
  802390:	e8 5b f2 ff ff       	call   8015f0 <fd2num>
}
  802395:	c9                   	leave  
  802396:	c3                   	ret    
	...

00802398 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802398:	55                   	push   %ebp
  802399:	89 e5                	mov    %esp,%ebp
  80239b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80239e:	89 c2                	mov    %eax,%edx
  8023a0:	c1 ea 16             	shr    $0x16,%edx
  8023a3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8023aa:	f6 c2 01             	test   $0x1,%dl
  8023ad:	74 1e                	je     8023cd <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8023af:	c1 e8 0c             	shr    $0xc,%eax
  8023b2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8023b9:	a8 01                	test   $0x1,%al
  8023bb:	74 17                	je     8023d4 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8023bd:	c1 e8 0c             	shr    $0xc,%eax
  8023c0:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8023c7:	ef 
  8023c8:	0f b7 c0             	movzwl %ax,%eax
  8023cb:	eb 0c                	jmp    8023d9 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8023cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8023d2:	eb 05                	jmp    8023d9 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8023d4:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8023d9:	5d                   	pop    %ebp
  8023da:	c3                   	ret    
	...

008023dc <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8023dc:	55                   	push   %ebp
  8023dd:	57                   	push   %edi
  8023de:	56                   	push   %esi
  8023df:	83 ec 10             	sub    $0x10,%esp
  8023e2:	8b 74 24 20          	mov    0x20(%esp),%esi
  8023e6:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8023ea:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023ee:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  8023f2:	89 cd                	mov    %ecx,%ebp
  8023f4:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8023f8:	85 c0                	test   %eax,%eax
  8023fa:	75 2c                	jne    802428 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8023fc:	39 f9                	cmp    %edi,%ecx
  8023fe:	77 68                	ja     802468 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802400:	85 c9                	test   %ecx,%ecx
  802402:	75 0b                	jne    80240f <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802404:	b8 01 00 00 00       	mov    $0x1,%eax
  802409:	31 d2                	xor    %edx,%edx
  80240b:	f7 f1                	div    %ecx
  80240d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80240f:	31 d2                	xor    %edx,%edx
  802411:	89 f8                	mov    %edi,%eax
  802413:	f7 f1                	div    %ecx
  802415:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802417:	89 f0                	mov    %esi,%eax
  802419:	f7 f1                	div    %ecx
  80241b:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80241d:	89 f0                	mov    %esi,%eax
  80241f:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802421:	83 c4 10             	add    $0x10,%esp
  802424:	5e                   	pop    %esi
  802425:	5f                   	pop    %edi
  802426:	5d                   	pop    %ebp
  802427:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802428:	39 f8                	cmp    %edi,%eax
  80242a:	77 2c                	ja     802458 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80242c:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  80242f:	83 f6 1f             	xor    $0x1f,%esi
  802432:	75 4c                	jne    802480 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802434:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802436:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80243b:	72 0a                	jb     802447 <__udivdi3+0x6b>
  80243d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802441:	0f 87 ad 00 00 00    	ja     8024f4 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802447:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80244c:	89 f0                	mov    %esi,%eax
  80244e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802450:	83 c4 10             	add    $0x10,%esp
  802453:	5e                   	pop    %esi
  802454:	5f                   	pop    %edi
  802455:	5d                   	pop    %ebp
  802456:	c3                   	ret    
  802457:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802458:	31 ff                	xor    %edi,%edi
  80245a:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80245c:	89 f0                	mov    %esi,%eax
  80245e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802460:	83 c4 10             	add    $0x10,%esp
  802463:	5e                   	pop    %esi
  802464:	5f                   	pop    %edi
  802465:	5d                   	pop    %ebp
  802466:	c3                   	ret    
  802467:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802468:	89 fa                	mov    %edi,%edx
  80246a:	89 f0                	mov    %esi,%eax
  80246c:	f7 f1                	div    %ecx
  80246e:	89 c6                	mov    %eax,%esi
  802470:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802472:	89 f0                	mov    %esi,%eax
  802474:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802476:	83 c4 10             	add    $0x10,%esp
  802479:	5e                   	pop    %esi
  80247a:	5f                   	pop    %edi
  80247b:	5d                   	pop    %ebp
  80247c:	c3                   	ret    
  80247d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802480:	89 f1                	mov    %esi,%ecx
  802482:	d3 e0                	shl    %cl,%eax
  802484:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802488:	b8 20 00 00 00       	mov    $0x20,%eax
  80248d:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80248f:	89 ea                	mov    %ebp,%edx
  802491:	88 c1                	mov    %al,%cl
  802493:	d3 ea                	shr    %cl,%edx
  802495:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802499:	09 ca                	or     %ecx,%edx
  80249b:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  80249f:	89 f1                	mov    %esi,%ecx
  8024a1:	d3 e5                	shl    %cl,%ebp
  8024a3:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  8024a7:	89 fd                	mov    %edi,%ebp
  8024a9:	88 c1                	mov    %al,%cl
  8024ab:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  8024ad:	89 fa                	mov    %edi,%edx
  8024af:	89 f1                	mov    %esi,%ecx
  8024b1:	d3 e2                	shl    %cl,%edx
  8024b3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8024b7:	88 c1                	mov    %al,%cl
  8024b9:	d3 ef                	shr    %cl,%edi
  8024bb:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8024bd:	89 f8                	mov    %edi,%eax
  8024bf:	89 ea                	mov    %ebp,%edx
  8024c1:	f7 74 24 08          	divl   0x8(%esp)
  8024c5:	89 d1                	mov    %edx,%ecx
  8024c7:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  8024c9:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8024cd:	39 d1                	cmp    %edx,%ecx
  8024cf:	72 17                	jb     8024e8 <__udivdi3+0x10c>
  8024d1:	74 09                	je     8024dc <__udivdi3+0x100>
  8024d3:	89 fe                	mov    %edi,%esi
  8024d5:	31 ff                	xor    %edi,%edi
  8024d7:	e9 41 ff ff ff       	jmp    80241d <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8024dc:	8b 54 24 04          	mov    0x4(%esp),%edx
  8024e0:	89 f1                	mov    %esi,%ecx
  8024e2:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8024e4:	39 c2                	cmp    %eax,%edx
  8024e6:	73 eb                	jae    8024d3 <__udivdi3+0xf7>
		{
		  q0--;
  8024e8:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8024eb:	31 ff                	xor    %edi,%edi
  8024ed:	e9 2b ff ff ff       	jmp    80241d <__udivdi3+0x41>
  8024f2:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8024f4:	31 f6                	xor    %esi,%esi
  8024f6:	e9 22 ff ff ff       	jmp    80241d <__udivdi3+0x41>
	...

008024fc <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8024fc:	55                   	push   %ebp
  8024fd:	57                   	push   %edi
  8024fe:	56                   	push   %esi
  8024ff:	83 ec 20             	sub    $0x20,%esp
  802502:	8b 44 24 30          	mov    0x30(%esp),%eax
  802506:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80250a:	89 44 24 14          	mov    %eax,0x14(%esp)
  80250e:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  802512:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802516:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80251a:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  80251c:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80251e:	85 ed                	test   %ebp,%ebp
  802520:	75 16                	jne    802538 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  802522:	39 f1                	cmp    %esi,%ecx
  802524:	0f 86 a6 00 00 00    	jbe    8025d0 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80252a:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  80252c:	89 d0                	mov    %edx,%eax
  80252e:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802530:	83 c4 20             	add    $0x20,%esp
  802533:	5e                   	pop    %esi
  802534:	5f                   	pop    %edi
  802535:	5d                   	pop    %ebp
  802536:	c3                   	ret    
  802537:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802538:	39 f5                	cmp    %esi,%ebp
  80253a:	0f 87 ac 00 00 00    	ja     8025ec <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802540:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  802543:	83 f0 1f             	xor    $0x1f,%eax
  802546:	89 44 24 10          	mov    %eax,0x10(%esp)
  80254a:	0f 84 a8 00 00 00    	je     8025f8 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802550:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802554:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802556:	bf 20 00 00 00       	mov    $0x20,%edi
  80255b:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80255f:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802563:	89 f9                	mov    %edi,%ecx
  802565:	d3 e8                	shr    %cl,%eax
  802567:	09 e8                	or     %ebp,%eax
  802569:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  80256d:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802571:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802575:	d3 e0                	shl    %cl,%eax
  802577:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80257b:	89 f2                	mov    %esi,%edx
  80257d:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80257f:	8b 44 24 14          	mov    0x14(%esp),%eax
  802583:	d3 e0                	shl    %cl,%eax
  802585:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802589:	8b 44 24 14          	mov    0x14(%esp),%eax
  80258d:	89 f9                	mov    %edi,%ecx
  80258f:	d3 e8                	shr    %cl,%eax
  802591:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802593:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802595:	89 f2                	mov    %esi,%edx
  802597:	f7 74 24 18          	divl   0x18(%esp)
  80259b:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80259d:	f7 64 24 0c          	mull   0xc(%esp)
  8025a1:	89 c5                	mov    %eax,%ebp
  8025a3:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8025a5:	39 d6                	cmp    %edx,%esi
  8025a7:	72 67                	jb     802610 <__umoddi3+0x114>
  8025a9:	74 75                	je     802620 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8025ab:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8025af:	29 e8                	sub    %ebp,%eax
  8025b1:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8025b3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8025b7:	d3 e8                	shr    %cl,%eax
  8025b9:	89 f2                	mov    %esi,%edx
  8025bb:	89 f9                	mov    %edi,%ecx
  8025bd:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8025bf:	09 d0                	or     %edx,%eax
  8025c1:	89 f2                	mov    %esi,%edx
  8025c3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8025c7:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8025c9:	83 c4 20             	add    $0x20,%esp
  8025cc:	5e                   	pop    %esi
  8025cd:	5f                   	pop    %edi
  8025ce:	5d                   	pop    %ebp
  8025cf:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8025d0:	85 c9                	test   %ecx,%ecx
  8025d2:	75 0b                	jne    8025df <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8025d4:	b8 01 00 00 00       	mov    $0x1,%eax
  8025d9:	31 d2                	xor    %edx,%edx
  8025db:	f7 f1                	div    %ecx
  8025dd:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8025df:	89 f0                	mov    %esi,%eax
  8025e1:	31 d2                	xor    %edx,%edx
  8025e3:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8025e5:	89 f8                	mov    %edi,%eax
  8025e7:	e9 3e ff ff ff       	jmp    80252a <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8025ec:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8025ee:	83 c4 20             	add    $0x20,%esp
  8025f1:	5e                   	pop    %esi
  8025f2:	5f                   	pop    %edi
  8025f3:	5d                   	pop    %ebp
  8025f4:	c3                   	ret    
  8025f5:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8025f8:	39 f5                	cmp    %esi,%ebp
  8025fa:	72 04                	jb     802600 <__umoddi3+0x104>
  8025fc:	39 f9                	cmp    %edi,%ecx
  8025fe:	77 06                	ja     802606 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802600:	89 f2                	mov    %esi,%edx
  802602:	29 cf                	sub    %ecx,%edi
  802604:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802606:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802608:	83 c4 20             	add    $0x20,%esp
  80260b:	5e                   	pop    %esi
  80260c:	5f                   	pop    %edi
  80260d:	5d                   	pop    %ebp
  80260e:	c3                   	ret    
  80260f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802610:	89 d1                	mov    %edx,%ecx
  802612:	89 c5                	mov    %eax,%ebp
  802614:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802618:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  80261c:	eb 8d                	jmp    8025ab <__umoddi3+0xaf>
  80261e:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802620:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802624:	72 ea                	jb     802610 <__umoddi3+0x114>
  802626:	89 f1                	mov    %esi,%ecx
  802628:	eb 81                	jmp    8025ab <__umoddi3+0xaf>
