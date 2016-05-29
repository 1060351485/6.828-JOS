
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
  800041:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  800048:	e8 1e 0e 00 00       	call   800e6b <strcpy>
	fsipcbuf.open.req_omode = mode;
  80004d:	89 1d 00 64 80 00    	mov    %ebx,0x806400

	fsenv = ipc_find_env(ENV_TYPE_FS);
  800053:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80005a:	e8 c0 15 00 00       	call   80161f <ipc_find_env>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80005f:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800066:	00 
  800067:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  80006e:	00 
  80006f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800076:	00 
  800077:	89 04 24             	mov    %eax,(%esp)
  80007a:	e8 32 15 00 00       	call   8015b1 <ipc_send>
	return ipc_recv(NULL, FVA, NULL);
  80007f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800086:	00 
  800087:	c7 44 24 04 00 c0 cc 	movl   $0xccccc000,0x4(%esp)
  80008e:	cc 
  80008f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800096:	e8 ad 14 00 00       	call   801548 <ipc_recv>
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
  8000b2:	b8 a0 2b 80 00       	mov    $0x802ba0,%eax
  8000b7:	e8 78 ff ff ff       	call   800034 <xopen>
  8000bc:	85 c0                	test   %eax,%eax
  8000be:	79 25                	jns    8000e5 <umain+0x44>
  8000c0:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8000c3:	74 3c                	je     800101 <umain+0x60>
		panic("serve_open /not-found: %e", r);
  8000c5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000c9:	c7 44 24 08 ab 2b 80 	movl   $0x802bab,0x8(%esp)
  8000d0:	00 
  8000d1:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8000d8:	00 
  8000d9:	c7 04 24 c5 2b 80 00 	movl   $0x802bc5,(%esp)
  8000e0:	e8 e3 06 00 00       	call   8007c8 <_panic>
	else if (r >= 0)
		panic("serve_open /not-found succeeded!");
  8000e5:	c7 44 24 08 60 2d 80 	movl   $0x802d60,0x8(%esp)
  8000ec:	00 
  8000ed:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8000f4:	00 
  8000f5:	c7 04 24 c5 2b 80 00 	movl   $0x802bc5,(%esp)
  8000fc:	e8 c7 06 00 00       	call   8007c8 <_panic>

	if ((r = xopen("/newmotd", O_RDONLY)) < 0)
  800101:	ba 00 00 00 00       	mov    $0x0,%edx
  800106:	b8 d5 2b 80 00       	mov    $0x802bd5,%eax
  80010b:	e8 24 ff ff ff       	call   800034 <xopen>
  800110:	85 c0                	test   %eax,%eax
  800112:	79 20                	jns    800134 <umain+0x93>
		panic("serve_open /newmotd: %e", r);
  800114:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800118:	c7 44 24 08 de 2b 80 	movl   $0x802bde,0x8(%esp)
  80011f:	00 
  800120:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800127:	00 
  800128:	c7 04 24 c5 2b 80 00 	movl   $0x802bc5,(%esp)
  80012f:	e8 94 06 00 00       	call   8007c8 <_panic>
	if (FVA->fd_dev_id != 'f' || FVA->fd_offset != 0 || FVA->fd_omode != O_RDONLY)
  800134:	83 3d 00 c0 cc cc 66 	cmpl   $0x66,0xccccc000
  80013b:	75 12                	jne    80014f <umain+0xae>
  80013d:	83 3d 04 c0 cc cc 00 	cmpl   $0x0,0xccccc004
  800144:	75 09                	jne    80014f <umain+0xae>
  800146:	83 3d 08 c0 cc cc 00 	cmpl   $0x0,0xccccc008
  80014d:	74 1c                	je     80016b <umain+0xca>
		panic("serve_open did not fill struct Fd correctly\n");
  80014f:	c7 44 24 08 84 2d 80 	movl   $0x802d84,0x8(%esp)
  800156:	00 
  800157:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  80015e:	00 
  80015f:	c7 04 24 c5 2b 80 00 	movl   $0x802bc5,(%esp)
  800166:	e8 5d 06 00 00       	call   8007c8 <_panic>
	cprintf("serve_open is good\n");
  80016b:	c7 04 24 f6 2b 80 00 	movl   $0x802bf6,(%esp)
  800172:	e8 49 07 00 00       	call   8008c0 <cprintf>

	if ((r = devfile.dev_stat(FVA, &st)) < 0)
  800177:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80017d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800181:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  800188:	ff 15 1c 40 80 00    	call   *0x80401c
  80018e:	85 c0                	test   %eax,%eax
  800190:	79 20                	jns    8001b2 <umain+0x111>
		panic("file_stat: %e", r);
  800192:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800196:	c7 44 24 08 0a 2c 80 	movl   $0x802c0a,0x8(%esp)
  80019d:	00 
  80019e:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  8001a5:	00 
  8001a6:	c7 04 24 c5 2b 80 00 	movl   $0x802bc5,(%esp)
  8001ad:	e8 16 06 00 00       	call   8007c8 <_panic>
	if (strlen(msg) != st.st_size)
  8001b2:	a1 00 40 80 00       	mov    0x804000,%eax
  8001b7:	89 04 24             	mov    %eax,(%esp)
  8001ba:	e8 79 0c 00 00       	call   800e38 <strlen>
  8001bf:	3b 45 cc             	cmp    -0x34(%ebp),%eax
  8001c2:	74 34                	je     8001f8 <umain+0x157>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
  8001c4:	a1 00 40 80 00       	mov    0x804000,%eax
  8001c9:	89 04 24             	mov    %eax,(%esp)
  8001cc:	e8 67 0c 00 00       	call   800e38 <strlen>
  8001d1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001d5:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8001d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001dc:	c7 44 24 08 b4 2d 80 	movl   $0x802db4,0x8(%esp)
  8001e3:	00 
  8001e4:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  8001eb:	00 
  8001ec:	c7 04 24 c5 2b 80 00 	movl   $0x802bc5,(%esp)
  8001f3:	e8 d0 05 00 00       	call   8007c8 <_panic>
	cprintf("file_stat is good\n");
  8001f8:	c7 04 24 18 2c 80 00 	movl   $0x802c18,(%esp)
  8001ff:	e8 bc 06 00 00       	call   8008c0 <cprintf>

	memset(buf, 0, sizeof buf);
  800204:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80020b:	00 
  80020c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800213:	00 
  800214:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  80021a:	89 1c 24             	mov    %ebx,(%esp)
  80021d:	e8 78 0d 00 00       	call   800f9a <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  800222:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  800229:	00 
  80022a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80022e:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  800235:	ff 15 10 40 80 00    	call   *0x804010
  80023b:	85 c0                	test   %eax,%eax
  80023d:	79 20                	jns    80025f <umain+0x1be>
		panic("file_read: %e", r);
  80023f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800243:	c7 44 24 08 2b 2c 80 	movl   $0x802c2b,0x8(%esp)
  80024a:	00 
  80024b:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
  800252:	00 
  800253:	c7 04 24 c5 2b 80 00 	movl   $0x802bc5,(%esp)
  80025a:	e8 69 05 00 00       	call   8007c8 <_panic>
	if (strcmp(buf, msg) != 0)
  80025f:	a1 00 40 80 00       	mov    0x804000,%eax
  800264:	89 44 24 04          	mov    %eax,0x4(%esp)
  800268:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  80026e:	89 04 24             	mov    %eax,(%esp)
  800271:	e8 9c 0c 00 00       	call   800f12 <strcmp>
  800276:	85 c0                	test   %eax,%eax
  800278:	74 1c                	je     800296 <umain+0x1f5>
		panic("file_read returned wrong data");
  80027a:	c7 44 24 08 39 2c 80 	movl   $0x802c39,0x8(%esp)
  800281:	00 
  800282:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  800289:	00 
  80028a:	c7 04 24 c5 2b 80 00 	movl   $0x802bc5,(%esp)
  800291:	e8 32 05 00 00       	call   8007c8 <_panic>
	cprintf("file_read is good\n");
  800296:	c7 04 24 57 2c 80 00 	movl   $0x802c57,(%esp)
  80029d:	e8 1e 06 00 00       	call   8008c0 <cprintf>

	if ((r = devfile.dev_close(FVA)) < 0)
  8002a2:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  8002a9:	ff 15 18 40 80 00    	call   *0x804018
  8002af:	85 c0                	test   %eax,%eax
  8002b1:	79 20                	jns    8002d3 <umain+0x232>
		panic("file_close: %e", r);
  8002b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002b7:	c7 44 24 08 6a 2c 80 	movl   $0x802c6a,0x8(%esp)
  8002be:	00 
  8002bf:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
  8002c6:	00 
  8002c7:	c7 04 24 c5 2b 80 00 	movl   $0x802bc5,(%esp)
  8002ce:	e8 f5 04 00 00       	call   8007c8 <_panic>
	cprintf("file_close is good\n");
  8002d3:	c7 04 24 79 2c 80 00 	movl   $0x802c79,(%esp)
  8002da:	e8 e1 05 00 00       	call   8008c0 <cprintf>

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
  8002fd:	e8 02 10 00 00       	call   801304 <sys_page_unmap>

	if ((r = devfile.dev_read(&fdcopy, buf, sizeof buf)) != -E_INVAL)
  800302:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  800309:	00 
  80030a:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  800310:	89 44 24 04          	mov    %eax,0x4(%esp)
  800314:	8d 45 d8             	lea    -0x28(%ebp),%eax
  800317:	89 04 24             	mov    %eax,(%esp)
  80031a:	ff 15 10 40 80 00    	call   *0x804010
  800320:	83 f8 fd             	cmp    $0xfffffffd,%eax
  800323:	74 20                	je     800345 <umain+0x2a4>
		panic("serve_read does not handle stale fileids correctly: %e", r);
  800325:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800329:	c7 44 24 08 dc 2d 80 	movl   $0x802ddc,0x8(%esp)
  800330:	00 
  800331:	c7 44 24 04 43 00 00 	movl   $0x43,0x4(%esp)
  800338:	00 
  800339:	c7 04 24 c5 2b 80 00 	movl   $0x802bc5,(%esp)
  800340:	e8 83 04 00 00       	call   8007c8 <_panic>
	cprintf("stale fileid is good\n");
  800345:	c7 04 24 8d 2c 80 00 	movl   $0x802c8d,(%esp)
  80034c:	e8 6f 05 00 00       	call   8008c0 <cprintf>

	// Try writing
	if ((r = xopen("/new-file", O_RDWR|O_CREAT)) < 0)
  800351:	ba 02 01 00 00       	mov    $0x102,%edx
  800356:	b8 a3 2c 80 00       	mov    $0x802ca3,%eax
  80035b:	e8 d4 fc ff ff       	call   800034 <xopen>
  800360:	85 c0                	test   %eax,%eax
  800362:	79 20                	jns    800384 <umain+0x2e3>
		panic("serve_open /new-file: %e", r);
  800364:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800368:	c7 44 24 08 ad 2c 80 	movl   $0x802cad,0x8(%esp)
  80036f:	00 
  800370:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  800377:	00 
  800378:	c7 04 24 c5 2b 80 00 	movl   $0x802bc5,(%esp)
  80037f:	e8 44 04 00 00       	call   8007c8 <_panic>

	if ((r = devfile.dev_write(FVA, msg, strlen(msg))) != strlen(msg))
  800384:	8b 1d 14 40 80 00    	mov    0x804014,%ebx
  80038a:	a1 00 40 80 00       	mov    0x804000,%eax
  80038f:	89 04 24             	mov    %eax,(%esp)
  800392:	e8 a1 0a 00 00       	call   800e38 <strlen>
  800397:	89 44 24 08          	mov    %eax,0x8(%esp)
  80039b:	a1 00 40 80 00       	mov    0x804000,%eax
  8003a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003a4:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  8003ab:	ff d3                	call   *%ebx
  8003ad:	89 c3                	mov    %eax,%ebx
  8003af:	a1 00 40 80 00       	mov    0x804000,%eax
  8003b4:	89 04 24             	mov    %eax,(%esp)
  8003b7:	e8 7c 0a 00 00       	call   800e38 <strlen>
  8003bc:	39 c3                	cmp    %eax,%ebx
  8003be:	74 20                	je     8003e0 <umain+0x33f>
		panic("file_write: %e", r);
  8003c0:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003c4:	c7 44 24 08 c6 2c 80 	movl   $0x802cc6,0x8(%esp)
  8003cb:	00 
  8003cc:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  8003d3:	00 
  8003d4:	c7 04 24 c5 2b 80 00 	movl   $0x802bc5,(%esp)
  8003db:	e8 e8 03 00 00       	call   8007c8 <_panic>
	cprintf("file_write is good\n");
  8003e0:	c7 04 24 d5 2c 80 00 	movl   $0x802cd5,(%esp)
  8003e7:	e8 d4 04 00 00       	call   8008c0 <cprintf>

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
  80040f:	e8 86 0b 00 00       	call   800f9a <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  800414:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80041b:	00 
  80041c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800420:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  800427:	ff 15 10 40 80 00    	call   *0x804010
  80042d:	89 c3                	mov    %eax,%ebx
  80042f:	85 c0                	test   %eax,%eax
  800431:	79 20                	jns    800453 <umain+0x3b2>
		panic("file_read after file_write: %e", r);
  800433:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800437:	c7 44 24 08 14 2e 80 	movl   $0x802e14,0x8(%esp)
  80043e:	00 
  80043f:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  800446:	00 
  800447:	c7 04 24 c5 2b 80 00 	movl   $0x802bc5,(%esp)
  80044e:	e8 75 03 00 00       	call   8007c8 <_panic>
	if (r != strlen(msg))
  800453:	a1 00 40 80 00       	mov    0x804000,%eax
  800458:	89 04 24             	mov    %eax,(%esp)
  80045b:	e8 d8 09 00 00       	call   800e38 <strlen>
  800460:	39 d8                	cmp    %ebx,%eax
  800462:	74 20                	je     800484 <umain+0x3e3>
		panic("file_read after file_write returned wrong length: %d", r);
  800464:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800468:	c7 44 24 08 34 2e 80 	movl   $0x802e34,0x8(%esp)
  80046f:	00 
  800470:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  800477:	00 
  800478:	c7 04 24 c5 2b 80 00 	movl   $0x802bc5,(%esp)
  80047f:	e8 44 03 00 00       	call   8007c8 <_panic>
	if (strcmp(buf, msg) != 0)
  800484:	a1 00 40 80 00       	mov    0x804000,%eax
  800489:	89 44 24 04          	mov    %eax,0x4(%esp)
  80048d:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  800493:	89 04 24             	mov    %eax,(%esp)
  800496:	e8 77 0a 00 00       	call   800f12 <strcmp>
  80049b:	85 c0                	test   %eax,%eax
  80049d:	74 1c                	je     8004bb <umain+0x41a>
		panic("file_read after file_write returned wrong data");
  80049f:	c7 44 24 08 6c 2e 80 	movl   $0x802e6c,0x8(%esp)
  8004a6:	00 
  8004a7:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
  8004ae:	00 
  8004af:	c7 04 24 c5 2b 80 00 	movl   $0x802bc5,(%esp)
  8004b6:	e8 0d 03 00 00       	call   8007c8 <_panic>
	cprintf("file_read after file_write is good\n");
  8004bb:	c7 04 24 9c 2e 80 00 	movl   $0x802e9c,(%esp)
  8004c2:	e8 f9 03 00 00       	call   8008c0 <cprintf>

	// Now we'll try out open
	if ((r = open("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  8004c7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8004ce:	00 
  8004cf:	c7 04 24 a0 2b 80 00 	movl   $0x802ba0,(%esp)
  8004d6:	e8 6d 19 00 00       	call   801e48 <open>
  8004db:	85 c0                	test   %eax,%eax
  8004dd:	79 25                	jns    800504 <umain+0x463>
  8004df:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8004e2:	74 3c                	je     800520 <umain+0x47f>
		panic("open /not-found: %e", r);
  8004e4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004e8:	c7 44 24 08 b1 2b 80 	movl   $0x802bb1,0x8(%esp)
  8004ef:	00 
  8004f0:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  8004f7:	00 
  8004f8:	c7 04 24 c5 2b 80 00 	movl   $0x802bc5,(%esp)
  8004ff:	e8 c4 02 00 00       	call   8007c8 <_panic>
	else if (r >= 0)
		panic("open /not-found succeeded!");
  800504:	c7 44 24 08 e9 2c 80 	movl   $0x802ce9,0x8(%esp)
  80050b:	00 
  80050c:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  800513:	00 
  800514:	c7 04 24 c5 2b 80 00 	movl   $0x802bc5,(%esp)
  80051b:	e8 a8 02 00 00       	call   8007c8 <_panic>

	if ((r = open("/newmotd", O_RDONLY)) < 0)
  800520:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800527:	00 
  800528:	c7 04 24 d5 2b 80 00 	movl   $0x802bd5,(%esp)
  80052f:	e8 14 19 00 00       	call   801e48 <open>
  800534:	85 c0                	test   %eax,%eax
  800536:	79 20                	jns    800558 <umain+0x4b7>
		panic("open /newmotd: %e", r);
  800538:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80053c:	c7 44 24 08 e4 2b 80 	movl   $0x802be4,0x8(%esp)
  800543:	00 
  800544:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
  80054b:	00 
  80054c:	c7 04 24 c5 2b 80 00 	movl   $0x802bc5,(%esp)
  800553:	e8 70 02 00 00       	call   8007c8 <_panic>
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
  800571:	c7 44 24 08 c0 2e 80 	movl   $0x802ec0,0x8(%esp)
  800578:	00 
  800579:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  800580:	00 
  800581:	c7 04 24 c5 2b 80 00 	movl   $0x802bc5,(%esp)
  800588:	e8 3b 02 00 00       	call   8007c8 <_panic>
	cprintf("open is good\n");
  80058d:	c7 04 24 fc 2b 80 00 	movl   $0x802bfc,(%esp)
  800594:	e8 27 03 00 00       	call   8008c0 <cprintf>

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
  800599:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
  8005a0:	00 
  8005a1:	c7 04 24 04 2d 80 00 	movl   $0x802d04,(%esp)
  8005a8:	e8 9b 18 00 00       	call   801e48 <open>
  8005ad:	89 c7                	mov    %eax,%edi
  8005af:	85 c0                	test   %eax,%eax
  8005b1:	79 20                	jns    8005d3 <umain+0x532>
		panic("creat /big: %e", f);
  8005b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005b7:	c7 44 24 08 09 2d 80 	movl   $0x802d09,0x8(%esp)
  8005be:	00 
  8005bf:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
  8005c6:	00 
  8005c7:	c7 04 24 c5 2b 80 00 	movl   $0x802bc5,(%esp)
  8005ce:	e8 f5 01 00 00       	call   8007c8 <_panic>
	memset(buf, 0, sizeof(buf));
  8005d3:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8005da:	00 
  8005db:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8005e2:	00 
  8005e3:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8005e9:	89 04 24             	mov    %eax,(%esp)
  8005ec:	e8 a9 09 00 00       	call   800f9a <memset>
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
  800611:	e8 37 14 00 00       	call   801a4d <write>
  800616:	85 c0                	test   %eax,%eax
  800618:	79 24                	jns    80063e <umain+0x59d>
			panic("write /big@%d: %e", i, r);
  80061a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80061e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800622:	c7 44 24 08 18 2d 80 	movl   $0x802d18,0x8(%esp)
  800629:	00 
  80062a:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  800631:	00 
  800632:	c7 04 24 c5 2b 80 00 	movl   $0x802bc5,(%esp)
  800639:	e8 8a 01 00 00       	call   8007c8 <_panic>
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
  800650:	e8 b9 11 00 00       	call   80180e <close>

	if ((f = open("/big", O_RDONLY)) < 0)
  800655:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80065c:	00 
  80065d:	c7 04 24 04 2d 80 00 	movl   $0x802d04,(%esp)
  800664:	e8 df 17 00 00       	call   801e48 <open>
  800669:	89 c3                	mov    %eax,%ebx
  80066b:	85 c0                	test   %eax,%eax
  80066d:	79 20                	jns    80068f <umain+0x5ee>
		panic("open /big: %e", f);
  80066f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800673:	c7 44 24 08 2a 2d 80 	movl   $0x802d2a,0x8(%esp)
  80067a:	00 
  80067b:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
  800682:	00 
  800683:	c7 04 24 c5 2b 80 00 	movl   $0x802bc5,(%esp)
  80068a:	e8 39 01 00 00       	call   8007c8 <_panic>
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
  8006af:	e8 4e 13 00 00       	call   801a02 <readn>
  8006b4:	85 c0                	test   %eax,%eax
  8006b6:	79 24                	jns    8006dc <umain+0x63b>
			panic("read /big@%d: %e", i, r);
  8006b8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006bc:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8006c0:	c7 44 24 08 38 2d 80 	movl   $0x802d38,0x8(%esp)
  8006c7:	00 
  8006c8:	c7 44 24 04 75 00 00 	movl   $0x75,0x4(%esp)
  8006cf:	00 
  8006d0:	c7 04 24 c5 2b 80 00 	movl   $0x802bc5,(%esp)
  8006d7:	e8 ec 00 00 00       	call   8007c8 <_panic>
		if (r != sizeof(buf))
  8006dc:	3d 00 02 00 00       	cmp    $0x200,%eax
  8006e1:	74 2c                	je     80070f <umain+0x66e>
			panic("read /big from %d returned %d < %d bytes",
  8006e3:	c7 44 24 14 00 02 00 	movl   $0x200,0x14(%esp)
  8006ea:	00 
  8006eb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006ef:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8006f3:	c7 44 24 08 e8 2e 80 	movl   $0x802ee8,0x8(%esp)
  8006fa:	00 
  8006fb:	c7 44 24 04 78 00 00 	movl   $0x78,0x4(%esp)
  800702:	00 
  800703:	c7 04 24 c5 2b 80 00 	movl   $0x802bc5,(%esp)
  80070a:	e8 b9 00 00 00       	call   8007c8 <_panic>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
  80070f:	8b 07                	mov    (%edi),%eax
  800711:	39 f0                	cmp    %esi,%eax
  800713:	74 24                	je     800739 <umain+0x698>
			panic("read /big from %d returned bad data %d",
  800715:	89 44 24 10          	mov    %eax,0x10(%esp)
  800719:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80071d:	c7 44 24 08 14 2f 80 	movl   $0x802f14,0x8(%esp)
  800724:	00 
  800725:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  80072c:	00 
  80072d:	c7 04 24 c5 2b 80 00 	movl   $0x802bc5,(%esp)
  800734:	e8 8f 00 00 00       	call   8007c8 <_panic>
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
  80074e:	e8 bb 10 00 00       	call   80180e <close>
	cprintf("large file is good\n");
  800753:	c7 04 24 49 2d 80 00 	movl   $0x802d49,(%esp)
  80075a:	e8 61 01 00 00       	call   8008c0 <cprintf>
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
  80077a:	e8 a0 0a 00 00       	call   80121f <sys_getenvid>
  80077f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800784:	c1 e0 07             	shl    $0x7,%eax
  800787:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80078c:	a3 08 50 80 00       	mov    %eax,0x805008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800791:	85 f6                	test   %esi,%esi
  800793:	7e 07                	jle    80079c <libmain+0x30>
		binaryname = argv[0];
  800795:	8b 03                	mov    (%ebx),%eax
  800797:	a3 04 40 80 00       	mov    %eax,0x804004

	// call user main routine
	umain(argc, argv);
  80079c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a0:	89 34 24             	mov    %esi,(%esp)
  8007a3:	e8 f9 f8 ff ff       	call   8000a1 <umain>

	// exit gracefully
	exit();
  8007a8:	e8 07 00 00 00       	call   8007b4 <exit>
}
  8007ad:	83 c4 10             	add    $0x10,%esp
  8007b0:	5b                   	pop    %ebx
  8007b1:	5e                   	pop    %esi
  8007b2:	5d                   	pop    %ebp
  8007b3:	c3                   	ret    

008007b4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  8007ba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8007c1:	e8 07 0a 00 00       	call   8011cd <sys_env_destroy>
}
  8007c6:	c9                   	leave  
  8007c7:	c3                   	ret    

008007c8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8007c8:	55                   	push   %ebp
  8007c9:	89 e5                	mov    %esp,%ebp
  8007cb:	56                   	push   %esi
  8007cc:	53                   	push   %ebx
  8007cd:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8007d0:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8007d3:	8b 1d 04 40 80 00    	mov    0x804004,%ebx
  8007d9:	e8 41 0a 00 00       	call   80121f <sys_getenvid>
  8007de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8007e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8007e8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007ec:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8007f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007f4:	c7 04 24 6c 2f 80 00 	movl   $0x802f6c,(%esp)
  8007fb:	e8 c0 00 00 00       	call   8008c0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800800:	89 74 24 04          	mov    %esi,0x4(%esp)
  800804:	8b 45 10             	mov    0x10(%ebp),%eax
  800807:	89 04 24             	mov    %eax,(%esp)
  80080a:	e8 50 00 00 00       	call   80085f <vcprintf>
	cprintf("\n");
  80080f:	c7 04 24 1c 34 80 00 	movl   $0x80341c,(%esp)
  800816:	e8 a5 00 00 00       	call   8008c0 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80081b:	cc                   	int3   
  80081c:	eb fd                	jmp    80081b <_panic+0x53>
	...

00800820 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	53                   	push   %ebx
  800824:	83 ec 14             	sub    $0x14,%esp
  800827:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80082a:	8b 03                	mov    (%ebx),%eax
  80082c:	8b 55 08             	mov    0x8(%ebp),%edx
  80082f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800833:	40                   	inc    %eax
  800834:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800836:	3d ff 00 00 00       	cmp    $0xff,%eax
  80083b:	75 19                	jne    800856 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80083d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800844:	00 
  800845:	8d 43 08             	lea    0x8(%ebx),%eax
  800848:	89 04 24             	mov    %eax,(%esp)
  80084b:	e8 40 09 00 00       	call   801190 <sys_cputs>
		b->idx = 0;
  800850:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800856:	ff 43 04             	incl   0x4(%ebx)
}
  800859:	83 c4 14             	add    $0x14,%esp
  80085c:	5b                   	pop    %ebx
  80085d:	5d                   	pop    %ebp
  80085e:	c3                   	ret    

0080085f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800868:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80086f:	00 00 00 
	b.cnt = 0;
  800872:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800879:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80087c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80087f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800883:	8b 45 08             	mov    0x8(%ebp),%eax
  800886:	89 44 24 08          	mov    %eax,0x8(%esp)
  80088a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800890:	89 44 24 04          	mov    %eax,0x4(%esp)
  800894:	c7 04 24 20 08 80 00 	movl   $0x800820,(%esp)
  80089b:	e8 82 01 00 00       	call   800a22 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8008a0:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8008a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008aa:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8008b0:	89 04 24             	mov    %eax,(%esp)
  8008b3:	e8 d8 08 00 00       	call   801190 <sys_cputs>

	return b.cnt;
}
  8008b8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8008be:	c9                   	leave  
  8008bf:	c3                   	ret    

008008c0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8008c6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8008c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d0:	89 04 24             	mov    %eax,(%esp)
  8008d3:	e8 87 ff ff ff       	call   80085f <vcprintf>
	va_end(ap);

	return cnt;
}
  8008d8:	c9                   	leave  
  8008d9:	c3                   	ret    
	...

008008dc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8008dc:	55                   	push   %ebp
  8008dd:	89 e5                	mov    %esp,%ebp
  8008df:	57                   	push   %edi
  8008e0:	56                   	push   %esi
  8008e1:	53                   	push   %ebx
  8008e2:	83 ec 3c             	sub    $0x3c,%esp
  8008e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008e8:	89 d7                	mov    %edx,%edi
  8008ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ed:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8008f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008f6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8008f9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8008fc:	85 c0                	test   %eax,%eax
  8008fe:	75 08                	jne    800908 <printnum+0x2c>
  800900:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800903:	39 45 10             	cmp    %eax,0x10(%ebp)
  800906:	77 57                	ja     80095f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800908:	89 74 24 10          	mov    %esi,0x10(%esp)
  80090c:	4b                   	dec    %ebx
  80090d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800911:	8b 45 10             	mov    0x10(%ebp),%eax
  800914:	89 44 24 08          	mov    %eax,0x8(%esp)
  800918:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80091c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800920:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800927:	00 
  800928:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80092b:	89 04 24             	mov    %eax,(%esp)
  80092e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800931:	89 44 24 04          	mov    %eax,0x4(%esp)
  800935:	e8 06 20 00 00       	call   802940 <__udivdi3>
  80093a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80093e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800942:	89 04 24             	mov    %eax,(%esp)
  800945:	89 54 24 04          	mov    %edx,0x4(%esp)
  800949:	89 fa                	mov    %edi,%edx
  80094b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80094e:	e8 89 ff ff ff       	call   8008dc <printnum>
  800953:	eb 0f                	jmp    800964 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800955:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800959:	89 34 24             	mov    %esi,(%esp)
  80095c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80095f:	4b                   	dec    %ebx
  800960:	85 db                	test   %ebx,%ebx
  800962:	7f f1                	jg     800955 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800964:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800968:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80096c:	8b 45 10             	mov    0x10(%ebp),%eax
  80096f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800973:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80097a:	00 
  80097b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80097e:	89 04 24             	mov    %eax,(%esp)
  800981:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800984:	89 44 24 04          	mov    %eax,0x4(%esp)
  800988:	e8 d3 20 00 00       	call   802a60 <__umoddi3>
  80098d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800991:	0f be 80 8f 2f 80 00 	movsbl 0x802f8f(%eax),%eax
  800998:	89 04 24             	mov    %eax,(%esp)
  80099b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80099e:	83 c4 3c             	add    $0x3c,%esp
  8009a1:	5b                   	pop    %ebx
  8009a2:	5e                   	pop    %esi
  8009a3:	5f                   	pop    %edi
  8009a4:	5d                   	pop    %ebp
  8009a5:	c3                   	ret    

008009a6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8009a9:	83 fa 01             	cmp    $0x1,%edx
  8009ac:	7e 0e                	jle    8009bc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8009ae:	8b 10                	mov    (%eax),%edx
  8009b0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8009b3:	89 08                	mov    %ecx,(%eax)
  8009b5:	8b 02                	mov    (%edx),%eax
  8009b7:	8b 52 04             	mov    0x4(%edx),%edx
  8009ba:	eb 22                	jmp    8009de <getuint+0x38>
	else if (lflag)
  8009bc:	85 d2                	test   %edx,%edx
  8009be:	74 10                	je     8009d0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8009c0:	8b 10                	mov    (%eax),%edx
  8009c2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8009c5:	89 08                	mov    %ecx,(%eax)
  8009c7:	8b 02                	mov    (%edx),%eax
  8009c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ce:	eb 0e                	jmp    8009de <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8009d0:	8b 10                	mov    (%eax),%edx
  8009d2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8009d5:	89 08                	mov    %ecx,(%eax)
  8009d7:	8b 02                	mov    (%edx),%eax
  8009d9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8009de:	5d                   	pop    %ebp
  8009df:	c3                   	ret    

008009e0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8009e6:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8009e9:	8b 10                	mov    (%eax),%edx
  8009eb:	3b 50 04             	cmp    0x4(%eax),%edx
  8009ee:	73 08                	jae    8009f8 <sprintputch+0x18>
		*b->buf++ = ch;
  8009f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f3:	88 0a                	mov    %cl,(%edx)
  8009f5:	42                   	inc    %edx
  8009f6:	89 10                	mov    %edx,(%eax)
}
  8009f8:	5d                   	pop    %ebp
  8009f9:	c3                   	ret    

008009fa <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800a00:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800a03:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a07:	8b 45 10             	mov    0x10(%ebp),%eax
  800a0a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a11:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a15:	8b 45 08             	mov    0x8(%ebp),%eax
  800a18:	89 04 24             	mov    %eax,(%esp)
  800a1b:	e8 02 00 00 00       	call   800a22 <vprintfmt>
	va_end(ap);
}
  800a20:	c9                   	leave  
  800a21:	c3                   	ret    

00800a22 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800a22:	55                   	push   %ebp
  800a23:	89 e5                	mov    %esp,%ebp
  800a25:	57                   	push   %edi
  800a26:	56                   	push   %esi
  800a27:	53                   	push   %ebx
  800a28:	83 ec 4c             	sub    $0x4c,%esp
  800a2b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a2e:	8b 75 10             	mov    0x10(%ebp),%esi
  800a31:	eb 12                	jmp    800a45 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800a33:	85 c0                	test   %eax,%eax
  800a35:	0f 84 6b 03 00 00    	je     800da6 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800a3b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a3f:	89 04 24             	mov    %eax,(%esp)
  800a42:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800a45:	0f b6 06             	movzbl (%esi),%eax
  800a48:	46                   	inc    %esi
  800a49:	83 f8 25             	cmp    $0x25,%eax
  800a4c:	75 e5                	jne    800a33 <vprintfmt+0x11>
  800a4e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800a52:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800a59:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800a5e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800a65:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a6a:	eb 26                	jmp    800a92 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a6c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800a6f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800a73:	eb 1d                	jmp    800a92 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a75:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800a78:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800a7c:	eb 14                	jmp    800a92 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a7e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800a81:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800a88:	eb 08                	jmp    800a92 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800a8a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800a8d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a92:	0f b6 06             	movzbl (%esi),%eax
  800a95:	8d 56 01             	lea    0x1(%esi),%edx
  800a98:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800a9b:	8a 16                	mov    (%esi),%dl
  800a9d:	83 ea 23             	sub    $0x23,%edx
  800aa0:	80 fa 55             	cmp    $0x55,%dl
  800aa3:	0f 87 e1 02 00 00    	ja     800d8a <vprintfmt+0x368>
  800aa9:	0f b6 d2             	movzbl %dl,%edx
  800aac:	ff 24 95 e0 30 80 00 	jmp    *0x8030e0(,%edx,4)
  800ab3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800ab6:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800abb:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800abe:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800ac2:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800ac5:	8d 50 d0             	lea    -0x30(%eax),%edx
  800ac8:	83 fa 09             	cmp    $0x9,%edx
  800acb:	77 2a                	ja     800af7 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800acd:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800ace:	eb eb                	jmp    800abb <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800ad0:	8b 45 14             	mov    0x14(%ebp),%eax
  800ad3:	8d 50 04             	lea    0x4(%eax),%edx
  800ad6:	89 55 14             	mov    %edx,0x14(%ebp)
  800ad9:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800adb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800ade:	eb 17                	jmp    800af7 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800ae0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ae4:	78 98                	js     800a7e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ae6:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800ae9:	eb a7                	jmp    800a92 <vprintfmt+0x70>
  800aeb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800aee:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800af5:	eb 9b                	jmp    800a92 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800af7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800afb:	79 95                	jns    800a92 <vprintfmt+0x70>
  800afd:	eb 8b                	jmp    800a8a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800aff:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b00:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800b03:	eb 8d                	jmp    800a92 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800b05:	8b 45 14             	mov    0x14(%ebp),%eax
  800b08:	8d 50 04             	lea    0x4(%eax),%edx
  800b0b:	89 55 14             	mov    %edx,0x14(%ebp)
  800b0e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b12:	8b 00                	mov    (%eax),%eax
  800b14:	89 04 24             	mov    %eax,(%esp)
  800b17:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b1a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800b1d:	e9 23 ff ff ff       	jmp    800a45 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800b22:	8b 45 14             	mov    0x14(%ebp),%eax
  800b25:	8d 50 04             	lea    0x4(%eax),%edx
  800b28:	89 55 14             	mov    %edx,0x14(%ebp)
  800b2b:	8b 00                	mov    (%eax),%eax
  800b2d:	85 c0                	test   %eax,%eax
  800b2f:	79 02                	jns    800b33 <vprintfmt+0x111>
  800b31:	f7 d8                	neg    %eax
  800b33:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800b35:	83 f8 11             	cmp    $0x11,%eax
  800b38:	7f 0b                	jg     800b45 <vprintfmt+0x123>
  800b3a:	8b 04 85 40 32 80 00 	mov    0x803240(,%eax,4),%eax
  800b41:	85 c0                	test   %eax,%eax
  800b43:	75 23                	jne    800b68 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800b45:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800b49:	c7 44 24 08 a7 2f 80 	movl   $0x802fa7,0x8(%esp)
  800b50:	00 
  800b51:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b55:	8b 45 08             	mov    0x8(%ebp),%eax
  800b58:	89 04 24             	mov    %eax,(%esp)
  800b5b:	e8 9a fe ff ff       	call   8009fa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b60:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800b63:	e9 dd fe ff ff       	jmp    800a45 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800b68:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b6c:	c7 44 24 08 b1 33 80 	movl   $0x8033b1,0x8(%esp)
  800b73:	00 
  800b74:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b78:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7b:	89 14 24             	mov    %edx,(%esp)
  800b7e:	e8 77 fe ff ff       	call   8009fa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b83:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800b86:	e9 ba fe ff ff       	jmp    800a45 <vprintfmt+0x23>
  800b8b:	89 f9                	mov    %edi,%ecx
  800b8d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800b90:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800b93:	8b 45 14             	mov    0x14(%ebp),%eax
  800b96:	8d 50 04             	lea    0x4(%eax),%edx
  800b99:	89 55 14             	mov    %edx,0x14(%ebp)
  800b9c:	8b 30                	mov    (%eax),%esi
  800b9e:	85 f6                	test   %esi,%esi
  800ba0:	75 05                	jne    800ba7 <vprintfmt+0x185>
				p = "(null)";
  800ba2:	be a0 2f 80 00       	mov    $0x802fa0,%esi
			if (width > 0 && padc != '-')
  800ba7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800bab:	0f 8e 84 00 00 00    	jle    800c35 <vprintfmt+0x213>
  800bb1:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800bb5:	74 7e                	je     800c35 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800bb7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800bbb:	89 34 24             	mov    %esi,(%esp)
  800bbe:	e8 8b 02 00 00       	call   800e4e <strnlen>
  800bc3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800bc6:	29 c2                	sub    %eax,%edx
  800bc8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800bcb:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800bcf:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800bd2:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800bd5:	89 de                	mov    %ebx,%esi
  800bd7:	89 d3                	mov    %edx,%ebx
  800bd9:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800bdb:	eb 0b                	jmp    800be8 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800bdd:	89 74 24 04          	mov    %esi,0x4(%esp)
  800be1:	89 3c 24             	mov    %edi,(%esp)
  800be4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800be7:	4b                   	dec    %ebx
  800be8:	85 db                	test   %ebx,%ebx
  800bea:	7f f1                	jg     800bdd <vprintfmt+0x1bb>
  800bec:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800bef:	89 f3                	mov    %esi,%ebx
  800bf1:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800bf4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800bf7:	85 c0                	test   %eax,%eax
  800bf9:	79 05                	jns    800c00 <vprintfmt+0x1de>
  800bfb:	b8 00 00 00 00       	mov    $0x0,%eax
  800c00:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800c03:	29 c2                	sub    %eax,%edx
  800c05:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800c08:	eb 2b                	jmp    800c35 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800c0a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800c0e:	74 18                	je     800c28 <vprintfmt+0x206>
  800c10:	8d 50 e0             	lea    -0x20(%eax),%edx
  800c13:	83 fa 5e             	cmp    $0x5e,%edx
  800c16:	76 10                	jbe    800c28 <vprintfmt+0x206>
					putch('?', putdat);
  800c18:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c1c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800c23:	ff 55 08             	call   *0x8(%ebp)
  800c26:	eb 0a                	jmp    800c32 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800c28:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c2c:	89 04 24             	mov    %eax,(%esp)
  800c2f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800c32:	ff 4d e4             	decl   -0x1c(%ebp)
  800c35:	0f be 06             	movsbl (%esi),%eax
  800c38:	46                   	inc    %esi
  800c39:	85 c0                	test   %eax,%eax
  800c3b:	74 21                	je     800c5e <vprintfmt+0x23c>
  800c3d:	85 ff                	test   %edi,%edi
  800c3f:	78 c9                	js     800c0a <vprintfmt+0x1e8>
  800c41:	4f                   	dec    %edi
  800c42:	79 c6                	jns    800c0a <vprintfmt+0x1e8>
  800c44:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c47:	89 de                	mov    %ebx,%esi
  800c49:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800c4c:	eb 18                	jmp    800c66 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800c4e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c52:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800c59:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800c5b:	4b                   	dec    %ebx
  800c5c:	eb 08                	jmp    800c66 <vprintfmt+0x244>
  800c5e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c61:	89 de                	mov    %ebx,%esi
  800c63:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800c66:	85 db                	test   %ebx,%ebx
  800c68:	7f e4                	jg     800c4e <vprintfmt+0x22c>
  800c6a:	89 7d 08             	mov    %edi,0x8(%ebp)
  800c6d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c6f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800c72:	e9 ce fd ff ff       	jmp    800a45 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800c77:	83 f9 01             	cmp    $0x1,%ecx
  800c7a:	7e 10                	jle    800c8c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800c7c:	8b 45 14             	mov    0x14(%ebp),%eax
  800c7f:	8d 50 08             	lea    0x8(%eax),%edx
  800c82:	89 55 14             	mov    %edx,0x14(%ebp)
  800c85:	8b 30                	mov    (%eax),%esi
  800c87:	8b 78 04             	mov    0x4(%eax),%edi
  800c8a:	eb 26                	jmp    800cb2 <vprintfmt+0x290>
	else if (lflag)
  800c8c:	85 c9                	test   %ecx,%ecx
  800c8e:	74 12                	je     800ca2 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800c90:	8b 45 14             	mov    0x14(%ebp),%eax
  800c93:	8d 50 04             	lea    0x4(%eax),%edx
  800c96:	89 55 14             	mov    %edx,0x14(%ebp)
  800c99:	8b 30                	mov    (%eax),%esi
  800c9b:	89 f7                	mov    %esi,%edi
  800c9d:	c1 ff 1f             	sar    $0x1f,%edi
  800ca0:	eb 10                	jmp    800cb2 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800ca2:	8b 45 14             	mov    0x14(%ebp),%eax
  800ca5:	8d 50 04             	lea    0x4(%eax),%edx
  800ca8:	89 55 14             	mov    %edx,0x14(%ebp)
  800cab:	8b 30                	mov    (%eax),%esi
  800cad:	89 f7                	mov    %esi,%edi
  800caf:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800cb2:	85 ff                	test   %edi,%edi
  800cb4:	78 0a                	js     800cc0 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800cb6:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cbb:	e9 8c 00 00 00       	jmp    800d4c <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800cc0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800cc4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800ccb:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800cce:	f7 de                	neg    %esi
  800cd0:	83 d7 00             	adc    $0x0,%edi
  800cd3:	f7 df                	neg    %edi
			}
			base = 10;
  800cd5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cda:	eb 70                	jmp    800d4c <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800cdc:	89 ca                	mov    %ecx,%edx
  800cde:	8d 45 14             	lea    0x14(%ebp),%eax
  800ce1:	e8 c0 fc ff ff       	call   8009a6 <getuint>
  800ce6:	89 c6                	mov    %eax,%esi
  800ce8:	89 d7                	mov    %edx,%edi
			base = 10;
  800cea:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800cef:	eb 5b                	jmp    800d4c <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  800cf1:	89 ca                	mov    %ecx,%edx
  800cf3:	8d 45 14             	lea    0x14(%ebp),%eax
  800cf6:	e8 ab fc ff ff       	call   8009a6 <getuint>
  800cfb:	89 c6                	mov    %eax,%esi
  800cfd:	89 d7                	mov    %edx,%edi
			base = 8;
  800cff:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800d04:	eb 46                	jmp    800d4c <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  800d06:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d0a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800d11:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800d14:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d18:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800d1f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800d22:	8b 45 14             	mov    0x14(%ebp),%eax
  800d25:	8d 50 04             	lea    0x4(%eax),%edx
  800d28:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800d2b:	8b 30                	mov    (%eax),%esi
  800d2d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800d32:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800d37:	eb 13                	jmp    800d4c <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800d39:	89 ca                	mov    %ecx,%edx
  800d3b:	8d 45 14             	lea    0x14(%ebp),%eax
  800d3e:	e8 63 fc ff ff       	call   8009a6 <getuint>
  800d43:	89 c6                	mov    %eax,%esi
  800d45:	89 d7                	mov    %edx,%edi
			base = 16;
  800d47:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800d4c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800d50:	89 54 24 10          	mov    %edx,0x10(%esp)
  800d54:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800d57:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800d5b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d5f:	89 34 24             	mov    %esi,(%esp)
  800d62:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d66:	89 da                	mov    %ebx,%edx
  800d68:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6b:	e8 6c fb ff ff       	call   8008dc <printnum>
			break;
  800d70:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800d73:	e9 cd fc ff ff       	jmp    800a45 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800d78:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d7c:	89 04 24             	mov    %eax,(%esp)
  800d7f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d82:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800d85:	e9 bb fc ff ff       	jmp    800a45 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800d8a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d8e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800d95:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800d98:	eb 01                	jmp    800d9b <vprintfmt+0x379>
  800d9a:	4e                   	dec    %esi
  800d9b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800d9f:	75 f9                	jne    800d9a <vprintfmt+0x378>
  800da1:	e9 9f fc ff ff       	jmp    800a45 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800da6:	83 c4 4c             	add    $0x4c,%esp
  800da9:	5b                   	pop    %ebx
  800daa:	5e                   	pop    %esi
  800dab:	5f                   	pop    %edi
  800dac:	5d                   	pop    %ebp
  800dad:	c3                   	ret    

00800dae <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800dae:	55                   	push   %ebp
  800daf:	89 e5                	mov    %esp,%ebp
  800db1:	83 ec 28             	sub    $0x28,%esp
  800db4:	8b 45 08             	mov    0x8(%ebp),%eax
  800db7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800dba:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800dbd:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800dc1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800dc4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800dcb:	85 c0                	test   %eax,%eax
  800dcd:	74 30                	je     800dff <vsnprintf+0x51>
  800dcf:	85 d2                	test   %edx,%edx
  800dd1:	7e 33                	jle    800e06 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800dd3:	8b 45 14             	mov    0x14(%ebp),%eax
  800dd6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800dda:	8b 45 10             	mov    0x10(%ebp),%eax
  800ddd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800de1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800de4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800de8:	c7 04 24 e0 09 80 00 	movl   $0x8009e0,(%esp)
  800def:	e8 2e fc ff ff       	call   800a22 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800df4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800df7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800dfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dfd:	eb 0c                	jmp    800e0b <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800dff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e04:	eb 05                	jmp    800e0b <vsnprintf+0x5d>
  800e06:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800e0b:	c9                   	leave  
  800e0c:	c3                   	ret    

00800e0d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800e0d:	55                   	push   %ebp
  800e0e:	89 e5                	mov    %esp,%ebp
  800e10:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800e13:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800e16:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e1a:	8b 45 10             	mov    0x10(%ebp),%eax
  800e1d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e21:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e24:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e28:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2b:	89 04 24             	mov    %eax,(%esp)
  800e2e:	e8 7b ff ff ff       	call   800dae <vsnprintf>
	va_end(ap);

	return rc;
}
  800e33:	c9                   	leave  
  800e34:	c3                   	ret    
  800e35:	00 00                	add    %al,(%eax)
	...

00800e38 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800e38:	55                   	push   %ebp
  800e39:	89 e5                	mov    %esp,%ebp
  800e3b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800e3e:	b8 00 00 00 00       	mov    $0x0,%eax
  800e43:	eb 01                	jmp    800e46 <strlen+0xe>
		n++;
  800e45:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800e46:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800e4a:	75 f9                	jne    800e45 <strlen+0xd>
		n++;
	return n;
}
  800e4c:	5d                   	pop    %ebp
  800e4d:	c3                   	ret    

00800e4e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800e4e:	55                   	push   %ebp
  800e4f:	89 e5                	mov    %esp,%ebp
  800e51:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800e54:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800e57:	b8 00 00 00 00       	mov    $0x0,%eax
  800e5c:	eb 01                	jmp    800e5f <strnlen+0x11>
		n++;
  800e5e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800e5f:	39 d0                	cmp    %edx,%eax
  800e61:	74 06                	je     800e69 <strnlen+0x1b>
  800e63:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800e67:	75 f5                	jne    800e5e <strnlen+0x10>
		n++;
	return n;
}
  800e69:	5d                   	pop    %ebp
  800e6a:	c3                   	ret    

00800e6b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800e6b:	55                   	push   %ebp
  800e6c:	89 e5                	mov    %esp,%ebp
  800e6e:	53                   	push   %ebx
  800e6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e72:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800e75:	ba 00 00 00 00       	mov    $0x0,%edx
  800e7a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800e7d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800e80:	42                   	inc    %edx
  800e81:	84 c9                	test   %cl,%cl
  800e83:	75 f5                	jne    800e7a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800e85:	5b                   	pop    %ebx
  800e86:	5d                   	pop    %ebp
  800e87:	c3                   	ret    

00800e88 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800e88:	55                   	push   %ebp
  800e89:	89 e5                	mov    %esp,%ebp
  800e8b:	53                   	push   %ebx
  800e8c:	83 ec 08             	sub    $0x8,%esp
  800e8f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800e92:	89 1c 24             	mov    %ebx,(%esp)
  800e95:	e8 9e ff ff ff       	call   800e38 <strlen>
	strcpy(dst + len, src);
  800e9a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e9d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ea1:	01 d8                	add    %ebx,%eax
  800ea3:	89 04 24             	mov    %eax,(%esp)
  800ea6:	e8 c0 ff ff ff       	call   800e6b <strcpy>
	return dst;
}
  800eab:	89 d8                	mov    %ebx,%eax
  800ead:	83 c4 08             	add    $0x8,%esp
  800eb0:	5b                   	pop    %ebx
  800eb1:	5d                   	pop    %ebp
  800eb2:	c3                   	ret    

00800eb3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800eb3:	55                   	push   %ebp
  800eb4:	89 e5                	mov    %esp,%ebp
  800eb6:	56                   	push   %esi
  800eb7:	53                   	push   %ebx
  800eb8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ebb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ebe:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ec1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ec6:	eb 0c                	jmp    800ed4 <strncpy+0x21>
		*dst++ = *src;
  800ec8:	8a 1a                	mov    (%edx),%bl
  800eca:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ecd:	80 3a 01             	cmpb   $0x1,(%edx)
  800ed0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ed3:	41                   	inc    %ecx
  800ed4:	39 f1                	cmp    %esi,%ecx
  800ed6:	75 f0                	jne    800ec8 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ed8:	5b                   	pop    %ebx
  800ed9:	5e                   	pop    %esi
  800eda:	5d                   	pop    %ebp
  800edb:	c3                   	ret    

00800edc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800edc:	55                   	push   %ebp
  800edd:	89 e5                	mov    %esp,%ebp
  800edf:	56                   	push   %esi
  800ee0:	53                   	push   %ebx
  800ee1:	8b 75 08             	mov    0x8(%ebp),%esi
  800ee4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee7:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800eea:	85 d2                	test   %edx,%edx
  800eec:	75 0a                	jne    800ef8 <strlcpy+0x1c>
  800eee:	89 f0                	mov    %esi,%eax
  800ef0:	eb 1a                	jmp    800f0c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800ef2:	88 18                	mov    %bl,(%eax)
  800ef4:	40                   	inc    %eax
  800ef5:	41                   	inc    %ecx
  800ef6:	eb 02                	jmp    800efa <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ef8:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800efa:	4a                   	dec    %edx
  800efb:	74 0a                	je     800f07 <strlcpy+0x2b>
  800efd:	8a 19                	mov    (%ecx),%bl
  800eff:	84 db                	test   %bl,%bl
  800f01:	75 ef                	jne    800ef2 <strlcpy+0x16>
  800f03:	89 c2                	mov    %eax,%edx
  800f05:	eb 02                	jmp    800f09 <strlcpy+0x2d>
  800f07:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800f09:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800f0c:	29 f0                	sub    %esi,%eax
}
  800f0e:	5b                   	pop    %ebx
  800f0f:	5e                   	pop    %esi
  800f10:	5d                   	pop    %ebp
  800f11:	c3                   	ret    

00800f12 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800f12:	55                   	push   %ebp
  800f13:	89 e5                	mov    %esp,%ebp
  800f15:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f18:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800f1b:	eb 02                	jmp    800f1f <strcmp+0xd>
		p++, q++;
  800f1d:	41                   	inc    %ecx
  800f1e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800f1f:	8a 01                	mov    (%ecx),%al
  800f21:	84 c0                	test   %al,%al
  800f23:	74 04                	je     800f29 <strcmp+0x17>
  800f25:	3a 02                	cmp    (%edx),%al
  800f27:	74 f4                	je     800f1d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800f29:	0f b6 c0             	movzbl %al,%eax
  800f2c:	0f b6 12             	movzbl (%edx),%edx
  800f2f:	29 d0                	sub    %edx,%eax
}
  800f31:	5d                   	pop    %ebp
  800f32:	c3                   	ret    

00800f33 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800f33:	55                   	push   %ebp
  800f34:	89 e5                	mov    %esp,%ebp
  800f36:	53                   	push   %ebx
  800f37:	8b 45 08             	mov    0x8(%ebp),%eax
  800f3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f3d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800f40:	eb 03                	jmp    800f45 <strncmp+0x12>
		n--, p++, q++;
  800f42:	4a                   	dec    %edx
  800f43:	40                   	inc    %eax
  800f44:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800f45:	85 d2                	test   %edx,%edx
  800f47:	74 14                	je     800f5d <strncmp+0x2a>
  800f49:	8a 18                	mov    (%eax),%bl
  800f4b:	84 db                	test   %bl,%bl
  800f4d:	74 04                	je     800f53 <strncmp+0x20>
  800f4f:	3a 19                	cmp    (%ecx),%bl
  800f51:	74 ef                	je     800f42 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800f53:	0f b6 00             	movzbl (%eax),%eax
  800f56:	0f b6 11             	movzbl (%ecx),%edx
  800f59:	29 d0                	sub    %edx,%eax
  800f5b:	eb 05                	jmp    800f62 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800f5d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800f62:	5b                   	pop    %ebx
  800f63:	5d                   	pop    %ebp
  800f64:	c3                   	ret    

00800f65 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800f65:	55                   	push   %ebp
  800f66:	89 e5                	mov    %esp,%ebp
  800f68:	8b 45 08             	mov    0x8(%ebp),%eax
  800f6b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800f6e:	eb 05                	jmp    800f75 <strchr+0x10>
		if (*s == c)
  800f70:	38 ca                	cmp    %cl,%dl
  800f72:	74 0c                	je     800f80 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800f74:	40                   	inc    %eax
  800f75:	8a 10                	mov    (%eax),%dl
  800f77:	84 d2                	test   %dl,%dl
  800f79:	75 f5                	jne    800f70 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800f7b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f80:	5d                   	pop    %ebp
  800f81:	c3                   	ret    

00800f82 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800f82:	55                   	push   %ebp
  800f83:	89 e5                	mov    %esp,%ebp
  800f85:	8b 45 08             	mov    0x8(%ebp),%eax
  800f88:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800f8b:	eb 05                	jmp    800f92 <strfind+0x10>
		if (*s == c)
  800f8d:	38 ca                	cmp    %cl,%dl
  800f8f:	74 07                	je     800f98 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800f91:	40                   	inc    %eax
  800f92:	8a 10                	mov    (%eax),%dl
  800f94:	84 d2                	test   %dl,%dl
  800f96:	75 f5                	jne    800f8d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800f98:	5d                   	pop    %ebp
  800f99:	c3                   	ret    

00800f9a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800f9a:	55                   	push   %ebp
  800f9b:	89 e5                	mov    %esp,%ebp
  800f9d:	57                   	push   %edi
  800f9e:	56                   	push   %esi
  800f9f:	53                   	push   %ebx
  800fa0:	8b 7d 08             	mov    0x8(%ebp),%edi
  800fa3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fa6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800fa9:	85 c9                	test   %ecx,%ecx
  800fab:	74 30                	je     800fdd <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800fad:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800fb3:	75 25                	jne    800fda <memset+0x40>
  800fb5:	f6 c1 03             	test   $0x3,%cl
  800fb8:	75 20                	jne    800fda <memset+0x40>
		c &= 0xFF;
  800fba:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800fbd:	89 d3                	mov    %edx,%ebx
  800fbf:	c1 e3 08             	shl    $0x8,%ebx
  800fc2:	89 d6                	mov    %edx,%esi
  800fc4:	c1 e6 18             	shl    $0x18,%esi
  800fc7:	89 d0                	mov    %edx,%eax
  800fc9:	c1 e0 10             	shl    $0x10,%eax
  800fcc:	09 f0                	or     %esi,%eax
  800fce:	09 d0                	or     %edx,%eax
  800fd0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800fd2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800fd5:	fc                   	cld    
  800fd6:	f3 ab                	rep stos %eax,%es:(%edi)
  800fd8:	eb 03                	jmp    800fdd <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800fda:	fc                   	cld    
  800fdb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800fdd:	89 f8                	mov    %edi,%eax
  800fdf:	5b                   	pop    %ebx
  800fe0:	5e                   	pop    %esi
  800fe1:	5f                   	pop    %edi
  800fe2:	5d                   	pop    %ebp
  800fe3:	c3                   	ret    

00800fe4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800fe4:	55                   	push   %ebp
  800fe5:	89 e5                	mov    %esp,%ebp
  800fe7:	57                   	push   %edi
  800fe8:	56                   	push   %esi
  800fe9:	8b 45 08             	mov    0x8(%ebp),%eax
  800fec:	8b 75 0c             	mov    0xc(%ebp),%esi
  800fef:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ff2:	39 c6                	cmp    %eax,%esi
  800ff4:	73 34                	jae    80102a <memmove+0x46>
  800ff6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ff9:	39 d0                	cmp    %edx,%eax
  800ffb:	73 2d                	jae    80102a <memmove+0x46>
		s += n;
		d += n;
  800ffd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801000:	f6 c2 03             	test   $0x3,%dl
  801003:	75 1b                	jne    801020 <memmove+0x3c>
  801005:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80100b:	75 13                	jne    801020 <memmove+0x3c>
  80100d:	f6 c1 03             	test   $0x3,%cl
  801010:	75 0e                	jne    801020 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801012:	83 ef 04             	sub    $0x4,%edi
  801015:	8d 72 fc             	lea    -0x4(%edx),%esi
  801018:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80101b:	fd                   	std    
  80101c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80101e:	eb 07                	jmp    801027 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801020:	4f                   	dec    %edi
  801021:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801024:	fd                   	std    
  801025:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801027:	fc                   	cld    
  801028:	eb 20                	jmp    80104a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80102a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801030:	75 13                	jne    801045 <memmove+0x61>
  801032:	a8 03                	test   $0x3,%al
  801034:	75 0f                	jne    801045 <memmove+0x61>
  801036:	f6 c1 03             	test   $0x3,%cl
  801039:	75 0a                	jne    801045 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80103b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80103e:	89 c7                	mov    %eax,%edi
  801040:	fc                   	cld    
  801041:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801043:	eb 05                	jmp    80104a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801045:	89 c7                	mov    %eax,%edi
  801047:	fc                   	cld    
  801048:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80104a:	5e                   	pop    %esi
  80104b:	5f                   	pop    %edi
  80104c:	5d                   	pop    %ebp
  80104d:	c3                   	ret    

0080104e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80104e:	55                   	push   %ebp
  80104f:	89 e5                	mov    %esp,%ebp
  801051:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801054:	8b 45 10             	mov    0x10(%ebp),%eax
  801057:	89 44 24 08          	mov    %eax,0x8(%esp)
  80105b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80105e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801062:	8b 45 08             	mov    0x8(%ebp),%eax
  801065:	89 04 24             	mov    %eax,(%esp)
  801068:	e8 77 ff ff ff       	call   800fe4 <memmove>
}
  80106d:	c9                   	leave  
  80106e:	c3                   	ret    

0080106f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80106f:	55                   	push   %ebp
  801070:	89 e5                	mov    %esp,%ebp
  801072:	57                   	push   %edi
  801073:	56                   	push   %esi
  801074:	53                   	push   %ebx
  801075:	8b 7d 08             	mov    0x8(%ebp),%edi
  801078:	8b 75 0c             	mov    0xc(%ebp),%esi
  80107b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80107e:	ba 00 00 00 00       	mov    $0x0,%edx
  801083:	eb 16                	jmp    80109b <memcmp+0x2c>
		if (*s1 != *s2)
  801085:	8a 04 17             	mov    (%edi,%edx,1),%al
  801088:	42                   	inc    %edx
  801089:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  80108d:	38 c8                	cmp    %cl,%al
  80108f:	74 0a                	je     80109b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  801091:	0f b6 c0             	movzbl %al,%eax
  801094:	0f b6 c9             	movzbl %cl,%ecx
  801097:	29 c8                	sub    %ecx,%eax
  801099:	eb 09                	jmp    8010a4 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80109b:	39 da                	cmp    %ebx,%edx
  80109d:	75 e6                	jne    801085 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80109f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010a4:	5b                   	pop    %ebx
  8010a5:	5e                   	pop    %esi
  8010a6:	5f                   	pop    %edi
  8010a7:	5d                   	pop    %ebp
  8010a8:	c3                   	ret    

008010a9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8010a9:	55                   	push   %ebp
  8010aa:	89 e5                	mov    %esp,%ebp
  8010ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8010af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8010b2:	89 c2                	mov    %eax,%edx
  8010b4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8010b7:	eb 05                	jmp    8010be <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8010b9:	38 08                	cmp    %cl,(%eax)
  8010bb:	74 05                	je     8010c2 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8010bd:	40                   	inc    %eax
  8010be:	39 d0                	cmp    %edx,%eax
  8010c0:	72 f7                	jb     8010b9 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8010c2:	5d                   	pop    %ebp
  8010c3:	c3                   	ret    

008010c4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8010c4:	55                   	push   %ebp
  8010c5:	89 e5                	mov    %esp,%ebp
  8010c7:	57                   	push   %edi
  8010c8:	56                   	push   %esi
  8010c9:	53                   	push   %ebx
  8010ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8010cd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8010d0:	eb 01                	jmp    8010d3 <strtol+0xf>
		s++;
  8010d2:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8010d3:	8a 02                	mov    (%edx),%al
  8010d5:	3c 20                	cmp    $0x20,%al
  8010d7:	74 f9                	je     8010d2 <strtol+0xe>
  8010d9:	3c 09                	cmp    $0x9,%al
  8010db:	74 f5                	je     8010d2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8010dd:	3c 2b                	cmp    $0x2b,%al
  8010df:	75 08                	jne    8010e9 <strtol+0x25>
		s++;
  8010e1:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8010e2:	bf 00 00 00 00       	mov    $0x0,%edi
  8010e7:	eb 13                	jmp    8010fc <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8010e9:	3c 2d                	cmp    $0x2d,%al
  8010eb:	75 0a                	jne    8010f7 <strtol+0x33>
		s++, neg = 1;
  8010ed:	8d 52 01             	lea    0x1(%edx),%edx
  8010f0:	bf 01 00 00 00       	mov    $0x1,%edi
  8010f5:	eb 05                	jmp    8010fc <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8010f7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010fc:	85 db                	test   %ebx,%ebx
  8010fe:	74 05                	je     801105 <strtol+0x41>
  801100:	83 fb 10             	cmp    $0x10,%ebx
  801103:	75 28                	jne    80112d <strtol+0x69>
  801105:	8a 02                	mov    (%edx),%al
  801107:	3c 30                	cmp    $0x30,%al
  801109:	75 10                	jne    80111b <strtol+0x57>
  80110b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80110f:	75 0a                	jne    80111b <strtol+0x57>
		s += 2, base = 16;
  801111:	83 c2 02             	add    $0x2,%edx
  801114:	bb 10 00 00 00       	mov    $0x10,%ebx
  801119:	eb 12                	jmp    80112d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  80111b:	85 db                	test   %ebx,%ebx
  80111d:	75 0e                	jne    80112d <strtol+0x69>
  80111f:	3c 30                	cmp    $0x30,%al
  801121:	75 05                	jne    801128 <strtol+0x64>
		s++, base = 8;
  801123:	42                   	inc    %edx
  801124:	b3 08                	mov    $0x8,%bl
  801126:	eb 05                	jmp    80112d <strtol+0x69>
	else if (base == 0)
		base = 10;
  801128:	bb 0a 00 00 00       	mov    $0xa,%ebx
  80112d:	b8 00 00 00 00       	mov    $0x0,%eax
  801132:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801134:	8a 0a                	mov    (%edx),%cl
  801136:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801139:	80 fb 09             	cmp    $0x9,%bl
  80113c:	77 08                	ja     801146 <strtol+0x82>
			dig = *s - '0';
  80113e:	0f be c9             	movsbl %cl,%ecx
  801141:	83 e9 30             	sub    $0x30,%ecx
  801144:	eb 1e                	jmp    801164 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  801146:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801149:	80 fb 19             	cmp    $0x19,%bl
  80114c:	77 08                	ja     801156 <strtol+0x92>
			dig = *s - 'a' + 10;
  80114e:	0f be c9             	movsbl %cl,%ecx
  801151:	83 e9 57             	sub    $0x57,%ecx
  801154:	eb 0e                	jmp    801164 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  801156:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  801159:	80 fb 19             	cmp    $0x19,%bl
  80115c:	77 12                	ja     801170 <strtol+0xac>
			dig = *s - 'A' + 10;
  80115e:	0f be c9             	movsbl %cl,%ecx
  801161:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801164:	39 f1                	cmp    %esi,%ecx
  801166:	7d 0c                	jge    801174 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  801168:	42                   	inc    %edx
  801169:	0f af c6             	imul   %esi,%eax
  80116c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  80116e:	eb c4                	jmp    801134 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  801170:	89 c1                	mov    %eax,%ecx
  801172:	eb 02                	jmp    801176 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801174:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801176:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80117a:	74 05                	je     801181 <strtol+0xbd>
		*endptr = (char *) s;
  80117c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80117f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801181:	85 ff                	test   %edi,%edi
  801183:	74 04                	je     801189 <strtol+0xc5>
  801185:	89 c8                	mov    %ecx,%eax
  801187:	f7 d8                	neg    %eax
}
  801189:	5b                   	pop    %ebx
  80118a:	5e                   	pop    %esi
  80118b:	5f                   	pop    %edi
  80118c:	5d                   	pop    %ebp
  80118d:	c3                   	ret    
	...

00801190 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801190:	55                   	push   %ebp
  801191:	89 e5                	mov    %esp,%ebp
  801193:	57                   	push   %edi
  801194:	56                   	push   %esi
  801195:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801196:	b8 00 00 00 00       	mov    $0x0,%eax
  80119b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80119e:	8b 55 08             	mov    0x8(%ebp),%edx
  8011a1:	89 c3                	mov    %eax,%ebx
  8011a3:	89 c7                	mov    %eax,%edi
  8011a5:	89 c6                	mov    %eax,%esi
  8011a7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8011a9:	5b                   	pop    %ebx
  8011aa:	5e                   	pop    %esi
  8011ab:	5f                   	pop    %edi
  8011ac:	5d                   	pop    %ebp
  8011ad:	c3                   	ret    

008011ae <sys_cgetc>:

int
sys_cgetc(void)
{
  8011ae:	55                   	push   %ebp
  8011af:	89 e5                	mov    %esp,%ebp
  8011b1:	57                   	push   %edi
  8011b2:	56                   	push   %esi
  8011b3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8011b9:	b8 01 00 00 00       	mov    $0x1,%eax
  8011be:	89 d1                	mov    %edx,%ecx
  8011c0:	89 d3                	mov    %edx,%ebx
  8011c2:	89 d7                	mov    %edx,%edi
  8011c4:	89 d6                	mov    %edx,%esi
  8011c6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8011c8:	5b                   	pop    %ebx
  8011c9:	5e                   	pop    %esi
  8011ca:	5f                   	pop    %edi
  8011cb:	5d                   	pop    %ebp
  8011cc:	c3                   	ret    

008011cd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8011cd:	55                   	push   %ebp
  8011ce:	89 e5                	mov    %esp,%ebp
  8011d0:	57                   	push   %edi
  8011d1:	56                   	push   %esi
  8011d2:	53                   	push   %ebx
  8011d3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011d6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011db:	b8 03 00 00 00       	mov    $0x3,%eax
  8011e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8011e3:	89 cb                	mov    %ecx,%ebx
  8011e5:	89 cf                	mov    %ecx,%edi
  8011e7:	89 ce                	mov    %ecx,%esi
  8011e9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011eb:	85 c0                	test   %eax,%eax
  8011ed:	7e 28                	jle    801217 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011ef:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011f3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8011fa:	00 
  8011fb:	c7 44 24 08 a7 32 80 	movl   $0x8032a7,0x8(%esp)
  801202:	00 
  801203:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80120a:	00 
  80120b:	c7 04 24 c4 32 80 00 	movl   $0x8032c4,(%esp)
  801212:	e8 b1 f5 ff ff       	call   8007c8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801217:	83 c4 2c             	add    $0x2c,%esp
  80121a:	5b                   	pop    %ebx
  80121b:	5e                   	pop    %esi
  80121c:	5f                   	pop    %edi
  80121d:	5d                   	pop    %ebp
  80121e:	c3                   	ret    

0080121f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80121f:	55                   	push   %ebp
  801220:	89 e5                	mov    %esp,%ebp
  801222:	57                   	push   %edi
  801223:	56                   	push   %esi
  801224:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801225:	ba 00 00 00 00       	mov    $0x0,%edx
  80122a:	b8 02 00 00 00       	mov    $0x2,%eax
  80122f:	89 d1                	mov    %edx,%ecx
  801231:	89 d3                	mov    %edx,%ebx
  801233:	89 d7                	mov    %edx,%edi
  801235:	89 d6                	mov    %edx,%esi
  801237:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801239:	5b                   	pop    %ebx
  80123a:	5e                   	pop    %esi
  80123b:	5f                   	pop    %edi
  80123c:	5d                   	pop    %ebp
  80123d:	c3                   	ret    

0080123e <sys_yield>:

void
sys_yield(void)
{
  80123e:	55                   	push   %ebp
  80123f:	89 e5                	mov    %esp,%ebp
  801241:	57                   	push   %edi
  801242:	56                   	push   %esi
  801243:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801244:	ba 00 00 00 00       	mov    $0x0,%edx
  801249:	b8 0b 00 00 00       	mov    $0xb,%eax
  80124e:	89 d1                	mov    %edx,%ecx
  801250:	89 d3                	mov    %edx,%ebx
  801252:	89 d7                	mov    %edx,%edi
  801254:	89 d6                	mov    %edx,%esi
  801256:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801258:	5b                   	pop    %ebx
  801259:	5e                   	pop    %esi
  80125a:	5f                   	pop    %edi
  80125b:	5d                   	pop    %ebp
  80125c:	c3                   	ret    

0080125d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80125d:	55                   	push   %ebp
  80125e:	89 e5                	mov    %esp,%ebp
  801260:	57                   	push   %edi
  801261:	56                   	push   %esi
  801262:	53                   	push   %ebx
  801263:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801266:	be 00 00 00 00       	mov    $0x0,%esi
  80126b:	b8 04 00 00 00       	mov    $0x4,%eax
  801270:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801273:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801276:	8b 55 08             	mov    0x8(%ebp),%edx
  801279:	89 f7                	mov    %esi,%edi
  80127b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80127d:	85 c0                	test   %eax,%eax
  80127f:	7e 28                	jle    8012a9 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  801281:	89 44 24 10          	mov    %eax,0x10(%esp)
  801285:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  80128c:	00 
  80128d:	c7 44 24 08 a7 32 80 	movl   $0x8032a7,0x8(%esp)
  801294:	00 
  801295:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80129c:	00 
  80129d:	c7 04 24 c4 32 80 00 	movl   $0x8032c4,(%esp)
  8012a4:	e8 1f f5 ff ff       	call   8007c8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8012a9:	83 c4 2c             	add    $0x2c,%esp
  8012ac:	5b                   	pop    %ebx
  8012ad:	5e                   	pop    %esi
  8012ae:	5f                   	pop    %edi
  8012af:	5d                   	pop    %ebp
  8012b0:	c3                   	ret    

008012b1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8012b1:	55                   	push   %ebp
  8012b2:	89 e5                	mov    %esp,%ebp
  8012b4:	57                   	push   %edi
  8012b5:	56                   	push   %esi
  8012b6:	53                   	push   %ebx
  8012b7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012ba:	b8 05 00 00 00       	mov    $0x5,%eax
  8012bf:	8b 75 18             	mov    0x18(%ebp),%esi
  8012c2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8012c5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8012ce:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8012d0:	85 c0                	test   %eax,%eax
  8012d2:	7e 28                	jle    8012fc <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012d4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012d8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8012df:	00 
  8012e0:	c7 44 24 08 a7 32 80 	movl   $0x8032a7,0x8(%esp)
  8012e7:	00 
  8012e8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012ef:	00 
  8012f0:	c7 04 24 c4 32 80 00 	movl   $0x8032c4,(%esp)
  8012f7:	e8 cc f4 ff ff       	call   8007c8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8012fc:	83 c4 2c             	add    $0x2c,%esp
  8012ff:	5b                   	pop    %ebx
  801300:	5e                   	pop    %esi
  801301:	5f                   	pop    %edi
  801302:	5d                   	pop    %ebp
  801303:	c3                   	ret    

00801304 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801304:	55                   	push   %ebp
  801305:	89 e5                	mov    %esp,%ebp
  801307:	57                   	push   %edi
  801308:	56                   	push   %esi
  801309:	53                   	push   %ebx
  80130a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80130d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801312:	b8 06 00 00 00       	mov    $0x6,%eax
  801317:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80131a:	8b 55 08             	mov    0x8(%ebp),%edx
  80131d:	89 df                	mov    %ebx,%edi
  80131f:	89 de                	mov    %ebx,%esi
  801321:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801323:	85 c0                	test   %eax,%eax
  801325:	7e 28                	jle    80134f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801327:	89 44 24 10          	mov    %eax,0x10(%esp)
  80132b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801332:	00 
  801333:	c7 44 24 08 a7 32 80 	movl   $0x8032a7,0x8(%esp)
  80133a:	00 
  80133b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801342:	00 
  801343:	c7 04 24 c4 32 80 00 	movl   $0x8032c4,(%esp)
  80134a:	e8 79 f4 ff ff       	call   8007c8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80134f:	83 c4 2c             	add    $0x2c,%esp
  801352:	5b                   	pop    %ebx
  801353:	5e                   	pop    %esi
  801354:	5f                   	pop    %edi
  801355:	5d                   	pop    %ebp
  801356:	c3                   	ret    

00801357 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801357:	55                   	push   %ebp
  801358:	89 e5                	mov    %esp,%ebp
  80135a:	57                   	push   %edi
  80135b:	56                   	push   %esi
  80135c:	53                   	push   %ebx
  80135d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801360:	bb 00 00 00 00       	mov    $0x0,%ebx
  801365:	b8 08 00 00 00       	mov    $0x8,%eax
  80136a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80136d:	8b 55 08             	mov    0x8(%ebp),%edx
  801370:	89 df                	mov    %ebx,%edi
  801372:	89 de                	mov    %ebx,%esi
  801374:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801376:	85 c0                	test   %eax,%eax
  801378:	7e 28                	jle    8013a2 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80137a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80137e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  801385:	00 
  801386:	c7 44 24 08 a7 32 80 	movl   $0x8032a7,0x8(%esp)
  80138d:	00 
  80138e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801395:	00 
  801396:	c7 04 24 c4 32 80 00 	movl   $0x8032c4,(%esp)
  80139d:	e8 26 f4 ff ff       	call   8007c8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8013a2:	83 c4 2c             	add    $0x2c,%esp
  8013a5:	5b                   	pop    %ebx
  8013a6:	5e                   	pop    %esi
  8013a7:	5f                   	pop    %edi
  8013a8:	5d                   	pop    %ebp
  8013a9:	c3                   	ret    

008013aa <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8013aa:	55                   	push   %ebp
  8013ab:	89 e5                	mov    %esp,%ebp
  8013ad:	57                   	push   %edi
  8013ae:	56                   	push   %esi
  8013af:	53                   	push   %ebx
  8013b0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013b3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013b8:	b8 09 00 00 00       	mov    $0x9,%eax
  8013bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8013c3:	89 df                	mov    %ebx,%edi
  8013c5:	89 de                	mov    %ebx,%esi
  8013c7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8013c9:	85 c0                	test   %eax,%eax
  8013cb:	7e 28                	jle    8013f5 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013cd:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013d1:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8013d8:	00 
  8013d9:	c7 44 24 08 a7 32 80 	movl   $0x8032a7,0x8(%esp)
  8013e0:	00 
  8013e1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8013e8:	00 
  8013e9:	c7 04 24 c4 32 80 00 	movl   $0x8032c4,(%esp)
  8013f0:	e8 d3 f3 ff ff       	call   8007c8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8013f5:	83 c4 2c             	add    $0x2c,%esp
  8013f8:	5b                   	pop    %ebx
  8013f9:	5e                   	pop    %esi
  8013fa:	5f                   	pop    %edi
  8013fb:	5d                   	pop    %ebp
  8013fc:	c3                   	ret    

008013fd <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8013fd:	55                   	push   %ebp
  8013fe:	89 e5                	mov    %esp,%ebp
  801400:	57                   	push   %edi
  801401:	56                   	push   %esi
  801402:	53                   	push   %ebx
  801403:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801406:	bb 00 00 00 00       	mov    $0x0,%ebx
  80140b:	b8 0a 00 00 00       	mov    $0xa,%eax
  801410:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801413:	8b 55 08             	mov    0x8(%ebp),%edx
  801416:	89 df                	mov    %ebx,%edi
  801418:	89 de                	mov    %ebx,%esi
  80141a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80141c:	85 c0                	test   %eax,%eax
  80141e:	7e 28                	jle    801448 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801420:	89 44 24 10          	mov    %eax,0x10(%esp)
  801424:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80142b:	00 
  80142c:	c7 44 24 08 a7 32 80 	movl   $0x8032a7,0x8(%esp)
  801433:	00 
  801434:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80143b:	00 
  80143c:	c7 04 24 c4 32 80 00 	movl   $0x8032c4,(%esp)
  801443:	e8 80 f3 ff ff       	call   8007c8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801448:	83 c4 2c             	add    $0x2c,%esp
  80144b:	5b                   	pop    %ebx
  80144c:	5e                   	pop    %esi
  80144d:	5f                   	pop    %edi
  80144e:	5d                   	pop    %ebp
  80144f:	c3                   	ret    

00801450 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801450:	55                   	push   %ebp
  801451:	89 e5                	mov    %esp,%ebp
  801453:	57                   	push   %edi
  801454:	56                   	push   %esi
  801455:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801456:	be 00 00 00 00       	mov    $0x0,%esi
  80145b:	b8 0c 00 00 00       	mov    $0xc,%eax
  801460:	8b 7d 14             	mov    0x14(%ebp),%edi
  801463:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801466:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801469:	8b 55 08             	mov    0x8(%ebp),%edx
  80146c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80146e:	5b                   	pop    %ebx
  80146f:	5e                   	pop    %esi
  801470:	5f                   	pop    %edi
  801471:	5d                   	pop    %ebp
  801472:	c3                   	ret    

00801473 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801473:	55                   	push   %ebp
  801474:	89 e5                	mov    %esp,%ebp
  801476:	57                   	push   %edi
  801477:	56                   	push   %esi
  801478:	53                   	push   %ebx
  801479:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80147c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801481:	b8 0d 00 00 00       	mov    $0xd,%eax
  801486:	8b 55 08             	mov    0x8(%ebp),%edx
  801489:	89 cb                	mov    %ecx,%ebx
  80148b:	89 cf                	mov    %ecx,%edi
  80148d:	89 ce                	mov    %ecx,%esi
  80148f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801491:	85 c0                	test   %eax,%eax
  801493:	7e 28                	jle    8014bd <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801495:	89 44 24 10          	mov    %eax,0x10(%esp)
  801499:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8014a0:	00 
  8014a1:	c7 44 24 08 a7 32 80 	movl   $0x8032a7,0x8(%esp)
  8014a8:	00 
  8014a9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8014b0:	00 
  8014b1:	c7 04 24 c4 32 80 00 	movl   $0x8032c4,(%esp)
  8014b8:	e8 0b f3 ff ff       	call   8007c8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8014bd:	83 c4 2c             	add    $0x2c,%esp
  8014c0:	5b                   	pop    %ebx
  8014c1:	5e                   	pop    %esi
  8014c2:	5f                   	pop    %edi
  8014c3:	5d                   	pop    %ebp
  8014c4:	c3                   	ret    

008014c5 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8014c5:	55                   	push   %ebp
  8014c6:	89 e5                	mov    %esp,%ebp
  8014c8:	57                   	push   %edi
  8014c9:	56                   	push   %esi
  8014ca:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d0:	b8 0e 00 00 00       	mov    $0xe,%eax
  8014d5:	89 d1                	mov    %edx,%ecx
  8014d7:	89 d3                	mov    %edx,%ebx
  8014d9:	89 d7                	mov    %edx,%edi
  8014db:	89 d6                	mov    %edx,%esi
  8014dd:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8014df:	5b                   	pop    %ebx
  8014e0:	5e                   	pop    %esi
  8014e1:	5f                   	pop    %edi
  8014e2:	5d                   	pop    %ebp
  8014e3:	c3                   	ret    

008014e4 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char* pck, size_t length){
  8014e4:	55                   	push   %ebp
  8014e5:	89 e5                	mov    %esp,%ebp
  8014e7:	57                   	push   %edi
  8014e8:	56                   	push   %esi
  8014e9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014ea:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014ef:	b8 10 00 00 00       	mov    $0x10,%eax
  8014f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8014fa:	89 df                	mov    %ebx,%edi
  8014fc:	89 de                	mov    %ebx,%esi
  8014fe:	cd 30                	int    $0x30
}

int 
sys_e1000_transmit(char* pck, size_t length){
	return syscall(SYS_e1000_transmit, 0, (uint32_t)pck, length, 0, 0, 0);
}
  801500:	5b                   	pop    %ebx
  801501:	5e                   	pop    %esi
  801502:	5f                   	pop    %edi
  801503:	5d                   	pop    %ebp
  801504:	c3                   	ret    

00801505 <sys_e1000_receive>:

int 
sys_e1000_receive(char* pck, size_t* length){
  801505:	55                   	push   %ebp
  801506:	89 e5                	mov    %esp,%ebp
  801508:	57                   	push   %edi
  801509:	56                   	push   %esi
  80150a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80150b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801510:	b8 0f 00 00 00       	mov    $0xf,%eax
  801515:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801518:	8b 55 08             	mov    0x8(%ebp),%edx
  80151b:	89 df                	mov    %ebx,%edi
  80151d:	89 de                	mov    %ebx,%esi
  80151f:	cd 30                	int    $0x30
}

int 
sys_e1000_receive(char* pck, size_t* length){
	return syscall(SYS_e1000_receive, 0, (uint32_t)pck, (uint32_t)length, 0, 0, 0);
}
  801521:	5b                   	pop    %ebx
  801522:	5e                   	pop    %esi
  801523:	5f                   	pop    %edi
  801524:	5d                   	pop    %ebp
  801525:	c3                   	ret    

00801526 <sys_e1000_get_mac>:

int 
sys_e1000_get_mac(uint8_t* mac_addr){
  801526:	55                   	push   %ebp
  801527:	89 e5                	mov    %esp,%ebp
  801529:	57                   	push   %edi
  80152a:	56                   	push   %esi
  80152b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80152c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801531:	b8 11 00 00 00       	mov    $0x11,%eax
  801536:	8b 55 08             	mov    0x8(%ebp),%edx
  801539:	89 cb                	mov    %ecx,%ebx
  80153b:	89 cf                	mov    %ecx,%edi
  80153d:	89 ce                	mov    %ecx,%esi
  80153f:	cd 30                	int    $0x30
}

int 
sys_e1000_get_mac(uint8_t* mac_addr){
	return syscall(SYS_e1000_get_mac, 0, (uint32_t)mac_addr, 0, 0, 0, 0);
}
  801541:	5b                   	pop    %ebx
  801542:	5e                   	pop    %esi
  801543:	5f                   	pop    %edi
  801544:	5d                   	pop    %ebp
  801545:	c3                   	ret    
	...

00801548 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801548:	55                   	push   %ebp
  801549:	89 e5                	mov    %esp,%ebp
  80154b:	56                   	push   %esi
  80154c:	53                   	push   %ebx
  80154d:	83 ec 10             	sub    $0x10,%esp
  801550:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801553:	8b 45 0c             	mov    0xc(%ebp),%eax
  801556:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int r;
		
	r = sys_ipc_recv(pg?pg:(void*)UTOP);
  801559:	85 c0                	test   %eax,%eax
  80155b:	75 05                	jne    801562 <ipc_recv+0x1a>
  80155d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801562:	89 04 24             	mov    %eax,(%esp)
  801565:	e8 09 ff ff ff       	call   801473 <sys_ipc_recv>
	if (from_env_store != NULL)
  80156a:	85 db                	test   %ebx,%ebx
  80156c:	74 0b                	je     801579 <ipc_recv+0x31>
		*from_env_store = thisenv->env_ipc_from; 
  80156e:	8b 15 08 50 80 00    	mov    0x805008,%edx
  801574:	8b 52 74             	mov    0x74(%edx),%edx
  801577:	89 13                	mov    %edx,(%ebx)
	if (perm_store != NULL)
  801579:	85 f6                	test   %esi,%esi
  80157b:	74 0b                	je     801588 <ipc_recv+0x40>
		*perm_store = thisenv->env_ipc_perm;
  80157d:	8b 15 08 50 80 00    	mov    0x805008,%edx
  801583:	8b 52 78             	mov    0x78(%edx),%edx
  801586:	89 16                	mov    %edx,(%esi)
	
	if (r < 0){
  801588:	85 c0                	test   %eax,%eax
  80158a:	79 16                	jns    8015a2 <ipc_recv+0x5a>
		if(from_env_store != NULL)
  80158c:	85 db                	test   %ebx,%ebx
  80158e:	74 06                	je     801596 <ipc_recv+0x4e>
			*from_env_store = 0;
  801590:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store != NULL)	
  801596:	85 f6                	test   %esi,%esi
  801598:	74 10                	je     8015aa <ipc_recv+0x62>
			*perm_store = 0;
  80159a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8015a0:	eb 08                	jmp    8015aa <ipc_recv+0x62>
		return r;
	}
	
	return thisenv->env_ipc_value;
  8015a2:	a1 08 50 80 00       	mov    0x805008,%eax
  8015a7:	8b 40 70             	mov    0x70(%eax),%eax
}
  8015aa:	83 c4 10             	add    $0x10,%esp
  8015ad:	5b                   	pop    %ebx
  8015ae:	5e                   	pop    %esi
  8015af:	5d                   	pop    %ebp
  8015b0:	c3                   	ret    

008015b1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8015b1:	55                   	push   %ebp
  8015b2:	89 e5                	mov    %esp,%ebp
  8015b4:	57                   	push   %edi
  8015b5:	56                   	push   %esi
  8015b6:	53                   	push   %ebx
  8015b7:	83 ec 1c             	sub    $0x1c,%esp
  8015ba:	8b 75 08             	mov    0x8(%ebp),%esi
  8015bd:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8015c0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  8015c3:	eb 2a                	jmp    8015ef <ipc_send+0x3e>
		if (r != -E_IPC_NOT_RECV)
  8015c5:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8015c8:	74 20                	je     8015ea <ipc_send+0x39>
			panic("ipc_send: sys_ipc_try_send failed %e", r);
  8015ca:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015ce:	c7 44 24 08 d4 32 80 	movl   $0x8032d4,0x8(%esp)
  8015d5:	00 
  8015d6:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  8015dd:	00 
  8015de:	c7 04 24 f9 32 80 00 	movl   $0x8032f9,(%esp)
  8015e5:	e8 de f1 ff ff       	call   8007c8 <_panic>
		sys_yield();
  8015ea:	e8 4f fc ff ff       	call   80123e <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  8015ef:	85 db                	test   %ebx,%ebx
  8015f1:	75 07                	jne    8015fa <ipc_send+0x49>
  8015f3:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8015f8:	eb 02                	jmp    8015fc <ipc_send+0x4b>
  8015fa:	89 d8                	mov    %ebx,%eax
  8015fc:	8b 55 14             	mov    0x14(%ebp),%edx
  8015ff:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801603:	89 44 24 08          	mov    %eax,0x8(%esp)
  801607:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80160b:	89 34 24             	mov    %esi,(%esp)
  80160e:	e8 3d fe ff ff       	call   801450 <sys_ipc_try_send>
  801613:	85 c0                	test   %eax,%eax
  801615:	78 ae                	js     8015c5 <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: sys_ipc_try_send failed %e", r);
		sys_yield();
	}
}
  801617:	83 c4 1c             	add    $0x1c,%esp
  80161a:	5b                   	pop    %ebx
  80161b:	5e                   	pop    %esi
  80161c:	5f                   	pop    %edi
  80161d:	5d                   	pop    %ebp
  80161e:	c3                   	ret    

0080161f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80161f:	55                   	push   %ebp
  801620:	89 e5                	mov    %esp,%ebp
  801622:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801625:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80162a:	89 c2                	mov    %eax,%edx
  80162c:	c1 e2 07             	shl    $0x7,%edx
  80162f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801635:	8b 52 50             	mov    0x50(%edx),%edx
  801638:	39 ca                	cmp    %ecx,%edx
  80163a:	75 0d                	jne    801649 <ipc_find_env+0x2a>
			return envs[i].env_id;
  80163c:	c1 e0 07             	shl    $0x7,%eax
  80163f:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801644:	8b 40 40             	mov    0x40(%eax),%eax
  801647:	eb 0c                	jmp    801655 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801649:	40                   	inc    %eax
  80164a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80164f:	75 d9                	jne    80162a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801651:	66 b8 00 00          	mov    $0x0,%ax
}
  801655:	5d                   	pop    %ebp
  801656:	c3                   	ret    
	...

00801658 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801658:	55                   	push   %ebp
  801659:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80165b:	8b 45 08             	mov    0x8(%ebp),%eax
  80165e:	05 00 00 00 30       	add    $0x30000000,%eax
  801663:	c1 e8 0c             	shr    $0xc,%eax
}
  801666:	5d                   	pop    %ebp
  801667:	c3                   	ret    

00801668 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801668:	55                   	push   %ebp
  801669:	89 e5                	mov    %esp,%ebp
  80166b:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  80166e:	8b 45 08             	mov    0x8(%ebp),%eax
  801671:	89 04 24             	mov    %eax,(%esp)
  801674:	e8 df ff ff ff       	call   801658 <fd2num>
  801679:	05 20 00 0d 00       	add    $0xd0020,%eax
  80167e:	c1 e0 0c             	shl    $0xc,%eax
}
  801681:	c9                   	leave  
  801682:	c3                   	ret    

00801683 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801683:	55                   	push   %ebp
  801684:	89 e5                	mov    %esp,%ebp
  801686:	53                   	push   %ebx
  801687:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80168a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80168f:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801691:	89 c2                	mov    %eax,%edx
  801693:	c1 ea 16             	shr    $0x16,%edx
  801696:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80169d:	f6 c2 01             	test   $0x1,%dl
  8016a0:	74 11                	je     8016b3 <fd_alloc+0x30>
  8016a2:	89 c2                	mov    %eax,%edx
  8016a4:	c1 ea 0c             	shr    $0xc,%edx
  8016a7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8016ae:	f6 c2 01             	test   $0x1,%dl
  8016b1:	75 09                	jne    8016bc <fd_alloc+0x39>
			*fd_store = fd;
  8016b3:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8016b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8016ba:	eb 17                	jmp    8016d3 <fd_alloc+0x50>
  8016bc:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8016c1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8016c6:	75 c7                	jne    80168f <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8016c8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8016ce:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8016d3:	5b                   	pop    %ebx
  8016d4:	5d                   	pop    %ebp
  8016d5:	c3                   	ret    

008016d6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8016d6:	55                   	push   %ebp
  8016d7:	89 e5                	mov    %esp,%ebp
  8016d9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8016dc:	83 f8 1f             	cmp    $0x1f,%eax
  8016df:	77 36                	ja     801717 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8016e1:	05 00 00 0d 00       	add    $0xd0000,%eax
  8016e6:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8016e9:	89 c2                	mov    %eax,%edx
  8016eb:	c1 ea 16             	shr    $0x16,%edx
  8016ee:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8016f5:	f6 c2 01             	test   $0x1,%dl
  8016f8:	74 24                	je     80171e <fd_lookup+0x48>
  8016fa:	89 c2                	mov    %eax,%edx
  8016fc:	c1 ea 0c             	shr    $0xc,%edx
  8016ff:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801706:	f6 c2 01             	test   $0x1,%dl
  801709:	74 1a                	je     801725 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80170b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80170e:	89 02                	mov    %eax,(%edx)
	return 0;
  801710:	b8 00 00 00 00       	mov    $0x0,%eax
  801715:	eb 13                	jmp    80172a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801717:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80171c:	eb 0c                	jmp    80172a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80171e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801723:	eb 05                	jmp    80172a <fd_lookup+0x54>
  801725:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80172a:	5d                   	pop    %ebp
  80172b:	c3                   	ret    

0080172c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80172c:	55                   	push   %ebp
  80172d:	89 e5                	mov    %esp,%ebp
  80172f:	53                   	push   %ebx
  801730:	83 ec 14             	sub    $0x14,%esp
  801733:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801736:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801739:	ba 00 00 00 00       	mov    $0x0,%edx
  80173e:	eb 0e                	jmp    80174e <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801740:	39 08                	cmp    %ecx,(%eax)
  801742:	75 09                	jne    80174d <dev_lookup+0x21>
			*dev = devtab[i];
  801744:	89 03                	mov    %eax,(%ebx)
			return 0;
  801746:	b8 00 00 00 00       	mov    $0x0,%eax
  80174b:	eb 33                	jmp    801780 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80174d:	42                   	inc    %edx
  80174e:	8b 04 95 84 33 80 00 	mov    0x803384(,%edx,4),%eax
  801755:	85 c0                	test   %eax,%eax
  801757:	75 e7                	jne    801740 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801759:	a1 08 50 80 00       	mov    0x805008,%eax
  80175e:	8b 40 48             	mov    0x48(%eax),%eax
  801761:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801765:	89 44 24 04          	mov    %eax,0x4(%esp)
  801769:	c7 04 24 04 33 80 00 	movl   $0x803304,(%esp)
  801770:	e8 4b f1 ff ff       	call   8008c0 <cprintf>
	*dev = 0;
  801775:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80177b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801780:	83 c4 14             	add    $0x14,%esp
  801783:	5b                   	pop    %ebx
  801784:	5d                   	pop    %ebp
  801785:	c3                   	ret    

00801786 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801786:	55                   	push   %ebp
  801787:	89 e5                	mov    %esp,%ebp
  801789:	56                   	push   %esi
  80178a:	53                   	push   %ebx
  80178b:	83 ec 30             	sub    $0x30,%esp
  80178e:	8b 75 08             	mov    0x8(%ebp),%esi
  801791:	8a 45 0c             	mov    0xc(%ebp),%al
  801794:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801797:	89 34 24             	mov    %esi,(%esp)
  80179a:	e8 b9 fe ff ff       	call   801658 <fd2num>
  80179f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8017a2:	89 54 24 04          	mov    %edx,0x4(%esp)
  8017a6:	89 04 24             	mov    %eax,(%esp)
  8017a9:	e8 28 ff ff ff       	call   8016d6 <fd_lookup>
  8017ae:	89 c3                	mov    %eax,%ebx
  8017b0:	85 c0                	test   %eax,%eax
  8017b2:	78 05                	js     8017b9 <fd_close+0x33>
	    || fd != fd2)
  8017b4:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8017b7:	74 0d                	je     8017c6 <fd_close+0x40>
		return (must_exist ? r : 0);
  8017b9:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8017bd:	75 46                	jne    801805 <fd_close+0x7f>
  8017bf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017c4:	eb 3f                	jmp    801805 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8017c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017cd:	8b 06                	mov    (%esi),%eax
  8017cf:	89 04 24             	mov    %eax,(%esp)
  8017d2:	e8 55 ff ff ff       	call   80172c <dev_lookup>
  8017d7:	89 c3                	mov    %eax,%ebx
  8017d9:	85 c0                	test   %eax,%eax
  8017db:	78 18                	js     8017f5 <fd_close+0x6f>
		if (dev->dev_close)
  8017dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017e0:	8b 40 10             	mov    0x10(%eax),%eax
  8017e3:	85 c0                	test   %eax,%eax
  8017e5:	74 09                	je     8017f0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8017e7:	89 34 24             	mov    %esi,(%esp)
  8017ea:	ff d0                	call   *%eax
  8017ec:	89 c3                	mov    %eax,%ebx
  8017ee:	eb 05                	jmp    8017f5 <fd_close+0x6f>
		else
			r = 0;
  8017f0:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8017f5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017f9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801800:	e8 ff fa ff ff       	call   801304 <sys_page_unmap>
	return r;
}
  801805:	89 d8                	mov    %ebx,%eax
  801807:	83 c4 30             	add    $0x30,%esp
  80180a:	5b                   	pop    %ebx
  80180b:	5e                   	pop    %esi
  80180c:	5d                   	pop    %ebp
  80180d:	c3                   	ret    

0080180e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80180e:	55                   	push   %ebp
  80180f:	89 e5                	mov    %esp,%ebp
  801811:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801814:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801817:	89 44 24 04          	mov    %eax,0x4(%esp)
  80181b:	8b 45 08             	mov    0x8(%ebp),%eax
  80181e:	89 04 24             	mov    %eax,(%esp)
  801821:	e8 b0 fe ff ff       	call   8016d6 <fd_lookup>
  801826:	85 c0                	test   %eax,%eax
  801828:	78 13                	js     80183d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80182a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801831:	00 
  801832:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801835:	89 04 24             	mov    %eax,(%esp)
  801838:	e8 49 ff ff ff       	call   801786 <fd_close>
}
  80183d:	c9                   	leave  
  80183e:	c3                   	ret    

0080183f <close_all>:

void
close_all(void)
{
  80183f:	55                   	push   %ebp
  801840:	89 e5                	mov    %esp,%ebp
  801842:	53                   	push   %ebx
  801843:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801846:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80184b:	89 1c 24             	mov    %ebx,(%esp)
  80184e:	e8 bb ff ff ff       	call   80180e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801853:	43                   	inc    %ebx
  801854:	83 fb 20             	cmp    $0x20,%ebx
  801857:	75 f2                	jne    80184b <close_all+0xc>
		close(i);
}
  801859:	83 c4 14             	add    $0x14,%esp
  80185c:	5b                   	pop    %ebx
  80185d:	5d                   	pop    %ebp
  80185e:	c3                   	ret    

0080185f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80185f:	55                   	push   %ebp
  801860:	89 e5                	mov    %esp,%ebp
  801862:	57                   	push   %edi
  801863:	56                   	push   %esi
  801864:	53                   	push   %ebx
  801865:	83 ec 4c             	sub    $0x4c,%esp
  801868:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80186b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80186e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801872:	8b 45 08             	mov    0x8(%ebp),%eax
  801875:	89 04 24             	mov    %eax,(%esp)
  801878:	e8 59 fe ff ff       	call   8016d6 <fd_lookup>
  80187d:	89 c3                	mov    %eax,%ebx
  80187f:	85 c0                	test   %eax,%eax
  801881:	0f 88 e1 00 00 00    	js     801968 <dup+0x109>
		return r;
	close(newfdnum);
  801887:	89 3c 24             	mov    %edi,(%esp)
  80188a:	e8 7f ff ff ff       	call   80180e <close>

	newfd = INDEX2FD(newfdnum);
  80188f:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801895:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801898:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80189b:	89 04 24             	mov    %eax,(%esp)
  80189e:	e8 c5 fd ff ff       	call   801668 <fd2data>
  8018a3:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8018a5:	89 34 24             	mov    %esi,(%esp)
  8018a8:	e8 bb fd ff ff       	call   801668 <fd2data>
  8018ad:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8018b0:	89 d8                	mov    %ebx,%eax
  8018b2:	c1 e8 16             	shr    $0x16,%eax
  8018b5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8018bc:	a8 01                	test   $0x1,%al
  8018be:	74 46                	je     801906 <dup+0xa7>
  8018c0:	89 d8                	mov    %ebx,%eax
  8018c2:	c1 e8 0c             	shr    $0xc,%eax
  8018c5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8018cc:	f6 c2 01             	test   $0x1,%dl
  8018cf:	74 35                	je     801906 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8018d1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018d8:	25 07 0e 00 00       	and    $0xe07,%eax
  8018dd:	89 44 24 10          	mov    %eax,0x10(%esp)
  8018e1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8018e4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018e8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8018ef:	00 
  8018f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018f4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018fb:	e8 b1 f9 ff ff       	call   8012b1 <sys_page_map>
  801900:	89 c3                	mov    %eax,%ebx
  801902:	85 c0                	test   %eax,%eax
  801904:	78 3b                	js     801941 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801906:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801909:	89 c2                	mov    %eax,%edx
  80190b:	c1 ea 0c             	shr    $0xc,%edx
  80190e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801915:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80191b:	89 54 24 10          	mov    %edx,0x10(%esp)
  80191f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801923:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80192a:	00 
  80192b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80192f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801936:	e8 76 f9 ff ff       	call   8012b1 <sys_page_map>
  80193b:	89 c3                	mov    %eax,%ebx
  80193d:	85 c0                	test   %eax,%eax
  80193f:	79 25                	jns    801966 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801941:	89 74 24 04          	mov    %esi,0x4(%esp)
  801945:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80194c:	e8 b3 f9 ff ff       	call   801304 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801951:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801954:	89 44 24 04          	mov    %eax,0x4(%esp)
  801958:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80195f:	e8 a0 f9 ff ff       	call   801304 <sys_page_unmap>
	return r;
  801964:	eb 02                	jmp    801968 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801966:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801968:	89 d8                	mov    %ebx,%eax
  80196a:	83 c4 4c             	add    $0x4c,%esp
  80196d:	5b                   	pop    %ebx
  80196e:	5e                   	pop    %esi
  80196f:	5f                   	pop    %edi
  801970:	5d                   	pop    %ebp
  801971:	c3                   	ret    

00801972 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801972:	55                   	push   %ebp
  801973:	89 e5                	mov    %esp,%ebp
  801975:	53                   	push   %ebx
  801976:	83 ec 24             	sub    $0x24,%esp
  801979:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80197c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80197f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801983:	89 1c 24             	mov    %ebx,(%esp)
  801986:	e8 4b fd ff ff       	call   8016d6 <fd_lookup>
  80198b:	85 c0                	test   %eax,%eax
  80198d:	78 6d                	js     8019fc <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80198f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801992:	89 44 24 04          	mov    %eax,0x4(%esp)
  801996:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801999:	8b 00                	mov    (%eax),%eax
  80199b:	89 04 24             	mov    %eax,(%esp)
  80199e:	e8 89 fd ff ff       	call   80172c <dev_lookup>
  8019a3:	85 c0                	test   %eax,%eax
  8019a5:	78 55                	js     8019fc <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8019a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019aa:	8b 50 08             	mov    0x8(%eax),%edx
  8019ad:	83 e2 03             	and    $0x3,%edx
  8019b0:	83 fa 01             	cmp    $0x1,%edx
  8019b3:	75 23                	jne    8019d8 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8019b5:	a1 08 50 80 00       	mov    0x805008,%eax
  8019ba:	8b 40 48             	mov    0x48(%eax),%eax
  8019bd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019c5:	c7 04 24 48 33 80 00 	movl   $0x803348,(%esp)
  8019cc:	e8 ef ee ff ff       	call   8008c0 <cprintf>
		return -E_INVAL;
  8019d1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019d6:	eb 24                	jmp    8019fc <read+0x8a>
	}
	if (!dev->dev_read)
  8019d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019db:	8b 52 08             	mov    0x8(%edx),%edx
  8019de:	85 d2                	test   %edx,%edx
  8019e0:	74 15                	je     8019f7 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8019e2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8019e5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8019e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019ec:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8019f0:	89 04 24             	mov    %eax,(%esp)
  8019f3:	ff d2                	call   *%edx
  8019f5:	eb 05                	jmp    8019fc <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8019f7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8019fc:	83 c4 24             	add    $0x24,%esp
  8019ff:	5b                   	pop    %ebx
  801a00:	5d                   	pop    %ebp
  801a01:	c3                   	ret    

00801a02 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801a02:	55                   	push   %ebp
  801a03:	89 e5                	mov    %esp,%ebp
  801a05:	57                   	push   %edi
  801a06:	56                   	push   %esi
  801a07:	53                   	push   %ebx
  801a08:	83 ec 1c             	sub    $0x1c,%esp
  801a0b:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a0e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801a11:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a16:	eb 23                	jmp    801a3b <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801a18:	89 f0                	mov    %esi,%eax
  801a1a:	29 d8                	sub    %ebx,%eax
  801a1c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a20:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a23:	01 d8                	add    %ebx,%eax
  801a25:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a29:	89 3c 24             	mov    %edi,(%esp)
  801a2c:	e8 41 ff ff ff       	call   801972 <read>
		if (m < 0)
  801a31:	85 c0                	test   %eax,%eax
  801a33:	78 10                	js     801a45 <readn+0x43>
			return m;
		if (m == 0)
  801a35:	85 c0                	test   %eax,%eax
  801a37:	74 0a                	je     801a43 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801a39:	01 c3                	add    %eax,%ebx
  801a3b:	39 f3                	cmp    %esi,%ebx
  801a3d:	72 d9                	jb     801a18 <readn+0x16>
  801a3f:	89 d8                	mov    %ebx,%eax
  801a41:	eb 02                	jmp    801a45 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801a43:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801a45:	83 c4 1c             	add    $0x1c,%esp
  801a48:	5b                   	pop    %ebx
  801a49:	5e                   	pop    %esi
  801a4a:	5f                   	pop    %edi
  801a4b:	5d                   	pop    %ebp
  801a4c:	c3                   	ret    

00801a4d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801a4d:	55                   	push   %ebp
  801a4e:	89 e5                	mov    %esp,%ebp
  801a50:	53                   	push   %ebx
  801a51:	83 ec 24             	sub    $0x24,%esp
  801a54:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a57:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a5a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a5e:	89 1c 24             	mov    %ebx,(%esp)
  801a61:	e8 70 fc ff ff       	call   8016d6 <fd_lookup>
  801a66:	85 c0                	test   %eax,%eax
  801a68:	78 68                	js     801ad2 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a6a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a6d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a71:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a74:	8b 00                	mov    (%eax),%eax
  801a76:	89 04 24             	mov    %eax,(%esp)
  801a79:	e8 ae fc ff ff       	call   80172c <dev_lookup>
  801a7e:	85 c0                	test   %eax,%eax
  801a80:	78 50                	js     801ad2 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801a82:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a85:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801a89:	75 23                	jne    801aae <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801a8b:	a1 08 50 80 00       	mov    0x805008,%eax
  801a90:	8b 40 48             	mov    0x48(%eax),%eax
  801a93:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a97:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a9b:	c7 04 24 64 33 80 00 	movl   $0x803364,(%esp)
  801aa2:	e8 19 ee ff ff       	call   8008c0 <cprintf>
		return -E_INVAL;
  801aa7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801aac:	eb 24                	jmp    801ad2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801aae:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ab1:	8b 52 0c             	mov    0xc(%edx),%edx
  801ab4:	85 d2                	test   %edx,%edx
  801ab6:	74 15                	je     801acd <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801ab8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801abb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801abf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ac2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801ac6:	89 04 24             	mov    %eax,(%esp)
  801ac9:	ff d2                	call   *%edx
  801acb:	eb 05                	jmp    801ad2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801acd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801ad2:	83 c4 24             	add    $0x24,%esp
  801ad5:	5b                   	pop    %ebx
  801ad6:	5d                   	pop    %ebp
  801ad7:	c3                   	ret    

00801ad8 <seek>:

int
seek(int fdnum, off_t offset)
{
  801ad8:	55                   	push   %ebp
  801ad9:	89 e5                	mov    %esp,%ebp
  801adb:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ade:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801ae1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ae5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae8:	89 04 24             	mov    %eax,(%esp)
  801aeb:	e8 e6 fb ff ff       	call   8016d6 <fd_lookup>
  801af0:	85 c0                	test   %eax,%eax
  801af2:	78 0e                	js     801b02 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801af4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801af7:	8b 55 0c             	mov    0xc(%ebp),%edx
  801afa:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801afd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b02:	c9                   	leave  
  801b03:	c3                   	ret    

00801b04 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801b04:	55                   	push   %ebp
  801b05:	89 e5                	mov    %esp,%ebp
  801b07:	53                   	push   %ebx
  801b08:	83 ec 24             	sub    $0x24,%esp
  801b0b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b0e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b11:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b15:	89 1c 24             	mov    %ebx,(%esp)
  801b18:	e8 b9 fb ff ff       	call   8016d6 <fd_lookup>
  801b1d:	85 c0                	test   %eax,%eax
  801b1f:	78 61                	js     801b82 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b21:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b24:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b28:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b2b:	8b 00                	mov    (%eax),%eax
  801b2d:	89 04 24             	mov    %eax,(%esp)
  801b30:	e8 f7 fb ff ff       	call   80172c <dev_lookup>
  801b35:	85 c0                	test   %eax,%eax
  801b37:	78 49                	js     801b82 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801b39:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b3c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801b40:	75 23                	jne    801b65 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801b42:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801b47:	8b 40 48             	mov    0x48(%eax),%eax
  801b4a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b52:	c7 04 24 24 33 80 00 	movl   $0x803324,(%esp)
  801b59:	e8 62 ed ff ff       	call   8008c0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801b5e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b63:	eb 1d                	jmp    801b82 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801b65:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b68:	8b 52 18             	mov    0x18(%edx),%edx
  801b6b:	85 d2                	test   %edx,%edx
  801b6d:	74 0e                	je     801b7d <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801b6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b72:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801b76:	89 04 24             	mov    %eax,(%esp)
  801b79:	ff d2                	call   *%edx
  801b7b:	eb 05                	jmp    801b82 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801b7d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801b82:	83 c4 24             	add    $0x24,%esp
  801b85:	5b                   	pop    %ebx
  801b86:	5d                   	pop    %ebp
  801b87:	c3                   	ret    

00801b88 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801b88:	55                   	push   %ebp
  801b89:	89 e5                	mov    %esp,%ebp
  801b8b:	53                   	push   %ebx
  801b8c:	83 ec 24             	sub    $0x24,%esp
  801b8f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b92:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b95:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b99:	8b 45 08             	mov    0x8(%ebp),%eax
  801b9c:	89 04 24             	mov    %eax,(%esp)
  801b9f:	e8 32 fb ff ff       	call   8016d6 <fd_lookup>
  801ba4:	85 c0                	test   %eax,%eax
  801ba6:	78 52                	js     801bfa <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ba8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bab:	89 44 24 04          	mov    %eax,0x4(%esp)
  801baf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bb2:	8b 00                	mov    (%eax),%eax
  801bb4:	89 04 24             	mov    %eax,(%esp)
  801bb7:	e8 70 fb ff ff       	call   80172c <dev_lookup>
  801bbc:	85 c0                	test   %eax,%eax
  801bbe:	78 3a                	js     801bfa <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801bc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bc3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801bc7:	74 2c                	je     801bf5 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801bc9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801bcc:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801bd3:	00 00 00 
	stat->st_isdir = 0;
  801bd6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801bdd:	00 00 00 
	stat->st_dev = dev;
  801be0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801be6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801bea:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801bed:	89 14 24             	mov    %edx,(%esp)
  801bf0:	ff 50 14             	call   *0x14(%eax)
  801bf3:	eb 05                	jmp    801bfa <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801bf5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801bfa:	83 c4 24             	add    $0x24,%esp
  801bfd:	5b                   	pop    %ebx
  801bfe:	5d                   	pop    %ebp
  801bff:	c3                   	ret    

00801c00 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801c00:	55                   	push   %ebp
  801c01:	89 e5                	mov    %esp,%ebp
  801c03:	56                   	push   %esi
  801c04:	53                   	push   %ebx
  801c05:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801c08:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c0f:	00 
  801c10:	8b 45 08             	mov    0x8(%ebp),%eax
  801c13:	89 04 24             	mov    %eax,(%esp)
  801c16:	e8 2d 02 00 00       	call   801e48 <open>
  801c1b:	89 c3                	mov    %eax,%ebx
  801c1d:	85 c0                	test   %eax,%eax
  801c1f:	78 1b                	js     801c3c <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801c21:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c24:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c28:	89 1c 24             	mov    %ebx,(%esp)
  801c2b:	e8 58 ff ff ff       	call   801b88 <fstat>
  801c30:	89 c6                	mov    %eax,%esi
	close(fd);
  801c32:	89 1c 24             	mov    %ebx,(%esp)
  801c35:	e8 d4 fb ff ff       	call   80180e <close>
	return r;
  801c3a:	89 f3                	mov    %esi,%ebx
}
  801c3c:	89 d8                	mov    %ebx,%eax
  801c3e:	83 c4 10             	add    $0x10,%esp
  801c41:	5b                   	pop    %ebx
  801c42:	5e                   	pop    %esi
  801c43:	5d                   	pop    %ebp
  801c44:	c3                   	ret    
  801c45:	00 00                	add    %al,(%eax)
	...

00801c48 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801c48:	55                   	push   %ebp
  801c49:	89 e5                	mov    %esp,%ebp
  801c4b:	56                   	push   %esi
  801c4c:	53                   	push   %ebx
  801c4d:	83 ec 10             	sub    $0x10,%esp
  801c50:	89 c3                	mov    %eax,%ebx
  801c52:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801c54:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801c5b:	75 11                	jne    801c6e <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801c5d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801c64:	e8 b6 f9 ff ff       	call   80161f <ipc_find_env>
  801c69:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801c6e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801c75:	00 
  801c76:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801c7d:	00 
  801c7e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c82:	a1 00 50 80 00       	mov    0x805000,%eax
  801c87:	89 04 24             	mov    %eax,(%esp)
  801c8a:	e8 22 f9 ff ff       	call   8015b1 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801c8f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c96:	00 
  801c97:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c9b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ca2:	e8 a1 f8 ff ff       	call   801548 <ipc_recv>
}
  801ca7:	83 c4 10             	add    $0x10,%esp
  801caa:	5b                   	pop    %ebx
  801cab:	5e                   	pop    %esi
  801cac:	5d                   	pop    %ebp
  801cad:	c3                   	ret    

00801cae <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801cae:	55                   	push   %ebp
  801caf:	89 e5                	mov    %esp,%ebp
  801cb1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801cb4:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb7:	8b 40 0c             	mov    0xc(%eax),%eax
  801cba:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801cbf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cc2:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801cc7:	ba 00 00 00 00       	mov    $0x0,%edx
  801ccc:	b8 02 00 00 00       	mov    $0x2,%eax
  801cd1:	e8 72 ff ff ff       	call   801c48 <fsipc>
}
  801cd6:	c9                   	leave  
  801cd7:	c3                   	ret    

00801cd8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801cd8:	55                   	push   %ebp
  801cd9:	89 e5                	mov    %esp,%ebp
  801cdb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801cde:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce1:	8b 40 0c             	mov    0xc(%eax),%eax
  801ce4:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801ce9:	ba 00 00 00 00       	mov    $0x0,%edx
  801cee:	b8 06 00 00 00       	mov    $0x6,%eax
  801cf3:	e8 50 ff ff ff       	call   801c48 <fsipc>
}
  801cf8:	c9                   	leave  
  801cf9:	c3                   	ret    

00801cfa <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801cfa:	55                   	push   %ebp
  801cfb:	89 e5                	mov    %esp,%ebp
  801cfd:	53                   	push   %ebx
  801cfe:	83 ec 14             	sub    $0x14,%esp
  801d01:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801d04:	8b 45 08             	mov    0x8(%ebp),%eax
  801d07:	8b 40 0c             	mov    0xc(%eax),%eax
  801d0a:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801d0f:	ba 00 00 00 00       	mov    $0x0,%edx
  801d14:	b8 05 00 00 00       	mov    $0x5,%eax
  801d19:	e8 2a ff ff ff       	call   801c48 <fsipc>
  801d1e:	85 c0                	test   %eax,%eax
  801d20:	78 2b                	js     801d4d <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801d22:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801d29:	00 
  801d2a:	89 1c 24             	mov    %ebx,(%esp)
  801d2d:	e8 39 f1 ff ff       	call   800e6b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801d32:	a1 80 60 80 00       	mov    0x806080,%eax
  801d37:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801d3d:	a1 84 60 80 00       	mov    0x806084,%eax
  801d42:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801d48:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d4d:	83 c4 14             	add    $0x14,%esp
  801d50:	5b                   	pop    %ebx
  801d51:	5d                   	pop    %ebp
  801d52:	c3                   	ret    

00801d53 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801d53:	55                   	push   %ebp
  801d54:	89 e5                	mov    %esp,%ebp
  801d56:	83 ec 18             	sub    $0x18,%esp
  801d59:	8b 55 10             	mov    0x10(%ebp),%edx
  801d5c:	89 d0                	mov    %edx,%eax
  801d5e:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  801d64:	76 05                	jbe    801d6b <devfile_write+0x18>
  801d66:	b8 00 10 00 00       	mov    $0x1000,%eax
	//panic("devfile_write not implemented");
	int r;
	//uint32_t maxsize = BLKSIZE - sizeof(int) - sizeof(size_t);	
	if (n > BLKSIZE)
		n = BLKSIZE;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801d6b:	8b 55 08             	mov    0x8(%ebp),%edx
  801d6e:	8b 52 0c             	mov    0xc(%edx),%edx
  801d71:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801d77:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801d7c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d80:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d83:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d87:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  801d8e:	e8 51 f2 ff ff       	call   800fe4 <memmove>
	 
	return fsipc(FSREQ_WRITE, NULL);
  801d93:	ba 00 00 00 00       	mov    $0x0,%edx
  801d98:	b8 04 00 00 00       	mov    $0x4,%eax
  801d9d:	e8 a6 fe ff ff       	call   801c48 <fsipc>
}
  801da2:	c9                   	leave  
  801da3:	c3                   	ret    

00801da4 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801da4:	55                   	push   %ebp
  801da5:	89 e5                	mov    %esp,%ebp
  801da7:	56                   	push   %esi
  801da8:	53                   	push   %ebx
  801da9:	83 ec 10             	sub    $0x10,%esp
  801dac:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801daf:	8b 45 08             	mov    0x8(%ebp),%eax
  801db2:	8b 40 0c             	mov    0xc(%eax),%eax
  801db5:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801dba:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801dc0:	ba 00 00 00 00       	mov    $0x0,%edx
  801dc5:	b8 03 00 00 00       	mov    $0x3,%eax
  801dca:	e8 79 fe ff ff       	call   801c48 <fsipc>
  801dcf:	89 c3                	mov    %eax,%ebx
  801dd1:	85 c0                	test   %eax,%eax
  801dd3:	78 6a                	js     801e3f <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801dd5:	39 c6                	cmp    %eax,%esi
  801dd7:	73 24                	jae    801dfd <devfile_read+0x59>
  801dd9:	c7 44 24 0c 98 33 80 	movl   $0x803398,0xc(%esp)
  801de0:	00 
  801de1:	c7 44 24 08 9f 33 80 	movl   $0x80339f,0x8(%esp)
  801de8:	00 
  801de9:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801df0:	00 
  801df1:	c7 04 24 b4 33 80 00 	movl   $0x8033b4,(%esp)
  801df8:	e8 cb e9 ff ff       	call   8007c8 <_panic>
	assert(r <= PGSIZE);
  801dfd:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801e02:	7e 24                	jle    801e28 <devfile_read+0x84>
  801e04:	c7 44 24 0c bf 33 80 	movl   $0x8033bf,0xc(%esp)
  801e0b:	00 
  801e0c:	c7 44 24 08 9f 33 80 	movl   $0x80339f,0x8(%esp)
  801e13:	00 
  801e14:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801e1b:	00 
  801e1c:	c7 04 24 b4 33 80 00 	movl   $0x8033b4,(%esp)
  801e23:	e8 a0 e9 ff ff       	call   8007c8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801e28:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e2c:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801e33:	00 
  801e34:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e37:	89 04 24             	mov    %eax,(%esp)
  801e3a:	e8 a5 f1 ff ff       	call   800fe4 <memmove>
	return r;
}
  801e3f:	89 d8                	mov    %ebx,%eax
  801e41:	83 c4 10             	add    $0x10,%esp
  801e44:	5b                   	pop    %ebx
  801e45:	5e                   	pop    %esi
  801e46:	5d                   	pop    %ebp
  801e47:	c3                   	ret    

00801e48 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801e48:	55                   	push   %ebp
  801e49:	89 e5                	mov    %esp,%ebp
  801e4b:	56                   	push   %esi
  801e4c:	53                   	push   %ebx
  801e4d:	83 ec 20             	sub    $0x20,%esp
  801e50:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801e53:	89 34 24             	mov    %esi,(%esp)
  801e56:	e8 dd ef ff ff       	call   800e38 <strlen>
  801e5b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801e60:	7f 60                	jg     801ec2 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801e62:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e65:	89 04 24             	mov    %eax,(%esp)
  801e68:	e8 16 f8 ff ff       	call   801683 <fd_alloc>
  801e6d:	89 c3                	mov    %eax,%ebx
  801e6f:	85 c0                	test   %eax,%eax
  801e71:	78 54                	js     801ec7 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801e73:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e77:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801e7e:	e8 e8 ef ff ff       	call   800e6b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801e83:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e86:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801e8b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e8e:	b8 01 00 00 00       	mov    $0x1,%eax
  801e93:	e8 b0 fd ff ff       	call   801c48 <fsipc>
  801e98:	89 c3                	mov    %eax,%ebx
  801e9a:	85 c0                	test   %eax,%eax
  801e9c:	79 15                	jns    801eb3 <open+0x6b>
		fd_close(fd, 0);
  801e9e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801ea5:	00 
  801ea6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ea9:	89 04 24             	mov    %eax,(%esp)
  801eac:	e8 d5 f8 ff ff       	call   801786 <fd_close>
		return r;
  801eb1:	eb 14                	jmp    801ec7 <open+0x7f>
	}

	return fd2num(fd);
  801eb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eb6:	89 04 24             	mov    %eax,(%esp)
  801eb9:	e8 9a f7 ff ff       	call   801658 <fd2num>
  801ebe:	89 c3                	mov    %eax,%ebx
  801ec0:	eb 05                	jmp    801ec7 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801ec2:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801ec7:	89 d8                	mov    %ebx,%eax
  801ec9:	83 c4 20             	add    $0x20,%esp
  801ecc:	5b                   	pop    %ebx
  801ecd:	5e                   	pop    %esi
  801ece:	5d                   	pop    %ebp
  801ecf:	c3                   	ret    

00801ed0 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801ed0:	55                   	push   %ebp
  801ed1:	89 e5                	mov    %esp,%ebp
  801ed3:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801ed6:	ba 00 00 00 00       	mov    $0x0,%edx
  801edb:	b8 08 00 00 00       	mov    $0x8,%eax
  801ee0:	e8 63 fd ff ff       	call   801c48 <fsipc>
}
  801ee5:	c9                   	leave  
  801ee6:	c3                   	ret    
	...

00801ee8 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801ee8:	55                   	push   %ebp
  801ee9:	89 e5                	mov    %esp,%ebp
  801eeb:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801eee:	c7 44 24 04 cb 33 80 	movl   $0x8033cb,0x4(%esp)
  801ef5:	00 
  801ef6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ef9:	89 04 24             	mov    %eax,(%esp)
  801efc:	e8 6a ef ff ff       	call   800e6b <strcpy>
	return 0;
}
  801f01:	b8 00 00 00 00       	mov    $0x0,%eax
  801f06:	c9                   	leave  
  801f07:	c3                   	ret    

00801f08 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801f08:	55                   	push   %ebp
  801f09:	89 e5                	mov    %esp,%ebp
  801f0b:	53                   	push   %ebx
  801f0c:	83 ec 14             	sub    $0x14,%esp
  801f0f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801f12:	89 1c 24             	mov    %ebx,(%esp)
  801f15:	e8 e2 09 00 00       	call   8028fc <pageref>
  801f1a:	83 f8 01             	cmp    $0x1,%eax
  801f1d:	75 0d                	jne    801f2c <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  801f1f:	8b 43 0c             	mov    0xc(%ebx),%eax
  801f22:	89 04 24             	mov    %eax,(%esp)
  801f25:	e8 1f 03 00 00       	call   802249 <nsipc_close>
  801f2a:	eb 05                	jmp    801f31 <devsock_close+0x29>
	else
		return 0;
  801f2c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f31:	83 c4 14             	add    $0x14,%esp
  801f34:	5b                   	pop    %ebx
  801f35:	5d                   	pop    %ebp
  801f36:	c3                   	ret    

00801f37 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801f37:	55                   	push   %ebp
  801f38:	89 e5                	mov    %esp,%ebp
  801f3a:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801f3d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801f44:	00 
  801f45:	8b 45 10             	mov    0x10(%ebp),%eax
  801f48:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f4c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f4f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f53:	8b 45 08             	mov    0x8(%ebp),%eax
  801f56:	8b 40 0c             	mov    0xc(%eax),%eax
  801f59:	89 04 24             	mov    %eax,(%esp)
  801f5c:	e8 e3 03 00 00       	call   802344 <nsipc_send>
}
  801f61:	c9                   	leave  
  801f62:	c3                   	ret    

00801f63 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801f63:	55                   	push   %ebp
  801f64:	89 e5                	mov    %esp,%ebp
  801f66:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801f69:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801f70:	00 
  801f71:	8b 45 10             	mov    0x10(%ebp),%eax
  801f74:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f78:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f7f:	8b 45 08             	mov    0x8(%ebp),%eax
  801f82:	8b 40 0c             	mov    0xc(%eax),%eax
  801f85:	89 04 24             	mov    %eax,(%esp)
  801f88:	e8 37 03 00 00       	call   8022c4 <nsipc_recv>
}
  801f8d:	c9                   	leave  
  801f8e:	c3                   	ret    

00801f8f <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801f8f:	55                   	push   %ebp
  801f90:	89 e5                	mov    %esp,%ebp
  801f92:	56                   	push   %esi
  801f93:	53                   	push   %ebx
  801f94:	83 ec 20             	sub    $0x20,%esp
  801f97:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801f99:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f9c:	89 04 24             	mov    %eax,(%esp)
  801f9f:	e8 df f6 ff ff       	call   801683 <fd_alloc>
  801fa4:	89 c3                	mov    %eax,%ebx
  801fa6:	85 c0                	test   %eax,%eax
  801fa8:	78 21                	js     801fcb <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801faa:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801fb1:	00 
  801fb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fb9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fc0:	e8 98 f2 ff ff       	call   80125d <sys_page_alloc>
  801fc5:	89 c3                	mov    %eax,%ebx
  801fc7:	85 c0                	test   %eax,%eax
  801fc9:	79 0a                	jns    801fd5 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  801fcb:	89 34 24             	mov    %esi,(%esp)
  801fce:	e8 76 02 00 00       	call   802249 <nsipc_close>
		return r;
  801fd3:	eb 22                	jmp    801ff7 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801fd5:	8b 15 24 40 80 00    	mov    0x804024,%edx
  801fdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fde:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801fe0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fe3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801fea:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801fed:	89 04 24             	mov    %eax,(%esp)
  801ff0:	e8 63 f6 ff ff       	call   801658 <fd2num>
  801ff5:	89 c3                	mov    %eax,%ebx
}
  801ff7:	89 d8                	mov    %ebx,%eax
  801ff9:	83 c4 20             	add    $0x20,%esp
  801ffc:	5b                   	pop    %ebx
  801ffd:	5e                   	pop    %esi
  801ffe:	5d                   	pop    %ebp
  801fff:	c3                   	ret    

00802000 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  802000:	55                   	push   %ebp
  802001:	89 e5                	mov    %esp,%ebp
  802003:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  802006:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802009:	89 54 24 04          	mov    %edx,0x4(%esp)
  80200d:	89 04 24             	mov    %eax,(%esp)
  802010:	e8 c1 f6 ff ff       	call   8016d6 <fd_lookup>
  802015:	85 c0                	test   %eax,%eax
  802017:	78 17                	js     802030 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  802019:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80201c:	8b 15 24 40 80 00    	mov    0x804024,%edx
  802022:	39 10                	cmp    %edx,(%eax)
  802024:	75 05                	jne    80202b <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  802026:	8b 40 0c             	mov    0xc(%eax),%eax
  802029:	eb 05                	jmp    802030 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  80202b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  802030:	c9                   	leave  
  802031:	c3                   	ret    

00802032 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802032:	55                   	push   %ebp
  802033:	89 e5                	mov    %esp,%ebp
  802035:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802038:	8b 45 08             	mov    0x8(%ebp),%eax
  80203b:	e8 c0 ff ff ff       	call   802000 <fd2sockid>
  802040:	85 c0                	test   %eax,%eax
  802042:	78 1f                	js     802063 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802044:	8b 55 10             	mov    0x10(%ebp),%edx
  802047:	89 54 24 08          	mov    %edx,0x8(%esp)
  80204b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80204e:	89 54 24 04          	mov    %edx,0x4(%esp)
  802052:	89 04 24             	mov    %eax,(%esp)
  802055:	e8 38 01 00 00       	call   802192 <nsipc_accept>
  80205a:	85 c0                	test   %eax,%eax
  80205c:	78 05                	js     802063 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  80205e:	e8 2c ff ff ff       	call   801f8f <alloc_sockfd>
}
  802063:	c9                   	leave  
  802064:	c3                   	ret    

00802065 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802065:	55                   	push   %ebp
  802066:	89 e5                	mov    %esp,%ebp
  802068:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80206b:	8b 45 08             	mov    0x8(%ebp),%eax
  80206e:	e8 8d ff ff ff       	call   802000 <fd2sockid>
  802073:	85 c0                	test   %eax,%eax
  802075:	78 16                	js     80208d <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  802077:	8b 55 10             	mov    0x10(%ebp),%edx
  80207a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80207e:	8b 55 0c             	mov    0xc(%ebp),%edx
  802081:	89 54 24 04          	mov    %edx,0x4(%esp)
  802085:	89 04 24             	mov    %eax,(%esp)
  802088:	e8 5b 01 00 00       	call   8021e8 <nsipc_bind>
}
  80208d:	c9                   	leave  
  80208e:	c3                   	ret    

0080208f <shutdown>:

int
shutdown(int s, int how)
{
  80208f:	55                   	push   %ebp
  802090:	89 e5                	mov    %esp,%ebp
  802092:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802095:	8b 45 08             	mov    0x8(%ebp),%eax
  802098:	e8 63 ff ff ff       	call   802000 <fd2sockid>
  80209d:	85 c0                	test   %eax,%eax
  80209f:	78 0f                	js     8020b0 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8020a1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020a4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8020a8:	89 04 24             	mov    %eax,(%esp)
  8020ab:	e8 77 01 00 00       	call   802227 <nsipc_shutdown>
}
  8020b0:	c9                   	leave  
  8020b1:	c3                   	ret    

008020b2 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8020b2:	55                   	push   %ebp
  8020b3:	89 e5                	mov    %esp,%ebp
  8020b5:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8020b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8020bb:	e8 40 ff ff ff       	call   802000 <fd2sockid>
  8020c0:	85 c0                	test   %eax,%eax
  8020c2:	78 16                	js     8020da <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  8020c4:	8b 55 10             	mov    0x10(%ebp),%edx
  8020c7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8020cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020ce:	89 54 24 04          	mov    %edx,0x4(%esp)
  8020d2:	89 04 24             	mov    %eax,(%esp)
  8020d5:	e8 89 01 00 00       	call   802263 <nsipc_connect>
}
  8020da:	c9                   	leave  
  8020db:	c3                   	ret    

008020dc <listen>:

int
listen(int s, int backlog)
{
  8020dc:	55                   	push   %ebp
  8020dd:	89 e5                	mov    %esp,%ebp
  8020df:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8020e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8020e5:	e8 16 ff ff ff       	call   802000 <fd2sockid>
  8020ea:	85 c0                	test   %eax,%eax
  8020ec:	78 0f                	js     8020fd <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8020ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020f1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8020f5:	89 04 24             	mov    %eax,(%esp)
  8020f8:	e8 a5 01 00 00       	call   8022a2 <nsipc_listen>
}
  8020fd:	c9                   	leave  
  8020fe:	c3                   	ret    

008020ff <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8020ff:	55                   	push   %ebp
  802100:	89 e5                	mov    %esp,%ebp
  802102:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  802105:	8b 45 10             	mov    0x10(%ebp),%eax
  802108:	89 44 24 08          	mov    %eax,0x8(%esp)
  80210c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80210f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802113:	8b 45 08             	mov    0x8(%ebp),%eax
  802116:	89 04 24             	mov    %eax,(%esp)
  802119:	e8 99 02 00 00       	call   8023b7 <nsipc_socket>
  80211e:	85 c0                	test   %eax,%eax
  802120:	78 05                	js     802127 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  802122:	e8 68 fe ff ff       	call   801f8f <alloc_sockfd>
}
  802127:	c9                   	leave  
  802128:	c3                   	ret    
  802129:	00 00                	add    %al,(%eax)
	...

0080212c <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  80212c:	55                   	push   %ebp
  80212d:	89 e5                	mov    %esp,%ebp
  80212f:	53                   	push   %ebx
  802130:	83 ec 14             	sub    $0x14,%esp
  802133:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802135:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  80213c:	75 11                	jne    80214f <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80213e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  802145:	e8 d5 f4 ff ff       	call   80161f <ipc_find_env>
  80214a:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80214f:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  802156:	00 
  802157:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  80215e:	00 
  80215f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802163:	a1 04 50 80 00       	mov    0x805004,%eax
  802168:	89 04 24             	mov    %eax,(%esp)
  80216b:	e8 41 f4 ff ff       	call   8015b1 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802170:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802177:	00 
  802178:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80217f:	00 
  802180:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802187:	e8 bc f3 ff ff       	call   801548 <ipc_recv>
}
  80218c:	83 c4 14             	add    $0x14,%esp
  80218f:	5b                   	pop    %ebx
  802190:	5d                   	pop    %ebp
  802191:	c3                   	ret    

00802192 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802192:	55                   	push   %ebp
  802193:	89 e5                	mov    %esp,%ebp
  802195:	56                   	push   %esi
  802196:	53                   	push   %ebx
  802197:	83 ec 10             	sub    $0x10,%esp
  80219a:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80219d:	8b 45 08             	mov    0x8(%ebp),%eax
  8021a0:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8021a5:	8b 06                	mov    (%esi),%eax
  8021a7:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8021ac:	b8 01 00 00 00       	mov    $0x1,%eax
  8021b1:	e8 76 ff ff ff       	call   80212c <nsipc>
  8021b6:	89 c3                	mov    %eax,%ebx
  8021b8:	85 c0                	test   %eax,%eax
  8021ba:	78 23                	js     8021df <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8021bc:	a1 10 70 80 00       	mov    0x807010,%eax
  8021c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021c5:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8021cc:	00 
  8021cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021d0:	89 04 24             	mov    %eax,(%esp)
  8021d3:	e8 0c ee ff ff       	call   800fe4 <memmove>
		*addrlen = ret->ret_addrlen;
  8021d8:	a1 10 70 80 00       	mov    0x807010,%eax
  8021dd:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  8021df:	89 d8                	mov    %ebx,%eax
  8021e1:	83 c4 10             	add    $0x10,%esp
  8021e4:	5b                   	pop    %ebx
  8021e5:	5e                   	pop    %esi
  8021e6:	5d                   	pop    %ebp
  8021e7:	c3                   	ret    

008021e8 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8021e8:	55                   	push   %ebp
  8021e9:	89 e5                	mov    %esp,%ebp
  8021eb:	53                   	push   %ebx
  8021ec:	83 ec 14             	sub    $0x14,%esp
  8021ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8021f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8021f5:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8021fa:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  802201:	89 44 24 04          	mov    %eax,0x4(%esp)
  802205:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  80220c:	e8 d3 ed ff ff       	call   800fe4 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802211:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  802217:	b8 02 00 00 00       	mov    $0x2,%eax
  80221c:	e8 0b ff ff ff       	call   80212c <nsipc>
}
  802221:	83 c4 14             	add    $0x14,%esp
  802224:	5b                   	pop    %ebx
  802225:	5d                   	pop    %ebp
  802226:	c3                   	ret    

00802227 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  802227:	55                   	push   %ebp
  802228:	89 e5                	mov    %esp,%ebp
  80222a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80222d:	8b 45 08             	mov    0x8(%ebp),%eax
  802230:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  802235:	8b 45 0c             	mov    0xc(%ebp),%eax
  802238:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  80223d:	b8 03 00 00 00       	mov    $0x3,%eax
  802242:	e8 e5 fe ff ff       	call   80212c <nsipc>
}
  802247:	c9                   	leave  
  802248:	c3                   	ret    

00802249 <nsipc_close>:

int
nsipc_close(int s)
{
  802249:	55                   	push   %ebp
  80224a:	89 e5                	mov    %esp,%ebp
  80224c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80224f:	8b 45 08             	mov    0x8(%ebp),%eax
  802252:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  802257:	b8 04 00 00 00       	mov    $0x4,%eax
  80225c:	e8 cb fe ff ff       	call   80212c <nsipc>
}
  802261:	c9                   	leave  
  802262:	c3                   	ret    

00802263 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802263:	55                   	push   %ebp
  802264:	89 e5                	mov    %esp,%ebp
  802266:	53                   	push   %ebx
  802267:	83 ec 14             	sub    $0x14,%esp
  80226a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80226d:	8b 45 08             	mov    0x8(%ebp),%eax
  802270:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802275:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802279:	8b 45 0c             	mov    0xc(%ebp),%eax
  80227c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802280:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802287:	e8 58 ed ff ff       	call   800fe4 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80228c:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  802292:	b8 05 00 00 00       	mov    $0x5,%eax
  802297:	e8 90 fe ff ff       	call   80212c <nsipc>
}
  80229c:	83 c4 14             	add    $0x14,%esp
  80229f:	5b                   	pop    %ebx
  8022a0:	5d                   	pop    %ebp
  8022a1:	c3                   	ret    

008022a2 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8022a2:	55                   	push   %ebp
  8022a3:	89 e5                	mov    %esp,%ebp
  8022a5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8022a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8022ab:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  8022b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022b3:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  8022b8:	b8 06 00 00 00       	mov    $0x6,%eax
  8022bd:	e8 6a fe ff ff       	call   80212c <nsipc>
}
  8022c2:	c9                   	leave  
  8022c3:	c3                   	ret    

008022c4 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8022c4:	55                   	push   %ebp
  8022c5:	89 e5                	mov    %esp,%ebp
  8022c7:	56                   	push   %esi
  8022c8:	53                   	push   %ebx
  8022c9:	83 ec 10             	sub    $0x10,%esp
  8022cc:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8022cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8022d2:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  8022d7:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  8022dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8022e0:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8022e5:	b8 07 00 00 00       	mov    $0x7,%eax
  8022ea:	e8 3d fe ff ff       	call   80212c <nsipc>
  8022ef:	89 c3                	mov    %eax,%ebx
  8022f1:	85 c0                	test   %eax,%eax
  8022f3:	78 46                	js     80233b <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  8022f5:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8022fa:	7f 04                	jg     802300 <nsipc_recv+0x3c>
  8022fc:	39 c6                	cmp    %eax,%esi
  8022fe:	7d 24                	jge    802324 <nsipc_recv+0x60>
  802300:	c7 44 24 0c d7 33 80 	movl   $0x8033d7,0xc(%esp)
  802307:	00 
  802308:	c7 44 24 08 9f 33 80 	movl   $0x80339f,0x8(%esp)
  80230f:	00 
  802310:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  802317:	00 
  802318:	c7 04 24 ec 33 80 00 	movl   $0x8033ec,(%esp)
  80231f:	e8 a4 e4 ff ff       	call   8007c8 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802324:	89 44 24 08          	mov    %eax,0x8(%esp)
  802328:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  80232f:	00 
  802330:	8b 45 0c             	mov    0xc(%ebp),%eax
  802333:	89 04 24             	mov    %eax,(%esp)
  802336:	e8 a9 ec ff ff       	call   800fe4 <memmove>
	}

	return r;
}
  80233b:	89 d8                	mov    %ebx,%eax
  80233d:	83 c4 10             	add    $0x10,%esp
  802340:	5b                   	pop    %ebx
  802341:	5e                   	pop    %esi
  802342:	5d                   	pop    %ebp
  802343:	c3                   	ret    

00802344 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802344:	55                   	push   %ebp
  802345:	89 e5                	mov    %esp,%ebp
  802347:	53                   	push   %ebx
  802348:	83 ec 14             	sub    $0x14,%esp
  80234b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80234e:	8b 45 08             	mov    0x8(%ebp),%eax
  802351:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  802356:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80235c:	7e 24                	jle    802382 <nsipc_send+0x3e>
  80235e:	c7 44 24 0c f8 33 80 	movl   $0x8033f8,0xc(%esp)
  802365:	00 
  802366:	c7 44 24 08 9f 33 80 	movl   $0x80339f,0x8(%esp)
  80236d:	00 
  80236e:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  802375:	00 
  802376:	c7 04 24 ec 33 80 00 	movl   $0x8033ec,(%esp)
  80237d:	e8 46 e4 ff ff       	call   8007c8 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802382:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802386:	8b 45 0c             	mov    0xc(%ebp),%eax
  802389:	89 44 24 04          	mov    %eax,0x4(%esp)
  80238d:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  802394:	e8 4b ec ff ff       	call   800fe4 <memmove>
	nsipcbuf.send.req_size = size;
  802399:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  80239f:	8b 45 14             	mov    0x14(%ebp),%eax
  8023a2:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  8023a7:	b8 08 00 00 00       	mov    $0x8,%eax
  8023ac:	e8 7b fd ff ff       	call   80212c <nsipc>
}
  8023b1:	83 c4 14             	add    $0x14,%esp
  8023b4:	5b                   	pop    %ebx
  8023b5:	5d                   	pop    %ebp
  8023b6:	c3                   	ret    

008023b7 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8023b7:	55                   	push   %ebp
  8023b8:	89 e5                	mov    %esp,%ebp
  8023ba:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8023bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8023c0:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  8023c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023c8:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  8023cd:	8b 45 10             	mov    0x10(%ebp),%eax
  8023d0:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  8023d5:	b8 09 00 00 00       	mov    $0x9,%eax
  8023da:	e8 4d fd ff ff       	call   80212c <nsipc>
}
  8023df:	c9                   	leave  
  8023e0:	c3                   	ret    
  8023e1:	00 00                	add    %al,(%eax)
	...

008023e4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8023e4:	55                   	push   %ebp
  8023e5:	89 e5                	mov    %esp,%ebp
  8023e7:	56                   	push   %esi
  8023e8:	53                   	push   %ebx
  8023e9:	83 ec 10             	sub    $0x10,%esp
  8023ec:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8023ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8023f2:	89 04 24             	mov    %eax,(%esp)
  8023f5:	e8 6e f2 ff ff       	call   801668 <fd2data>
  8023fa:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8023fc:	c7 44 24 04 04 34 80 	movl   $0x803404,0x4(%esp)
  802403:	00 
  802404:	89 34 24             	mov    %esi,(%esp)
  802407:	e8 5f ea ff ff       	call   800e6b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80240c:	8b 43 04             	mov    0x4(%ebx),%eax
  80240f:	2b 03                	sub    (%ebx),%eax
  802411:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  802417:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80241e:	00 00 00 
	stat->st_dev = &devpipe;
  802421:	c7 86 88 00 00 00 40 	movl   $0x804040,0x88(%esi)
  802428:	40 80 00 
	return 0;
}
  80242b:	b8 00 00 00 00       	mov    $0x0,%eax
  802430:	83 c4 10             	add    $0x10,%esp
  802433:	5b                   	pop    %ebx
  802434:	5e                   	pop    %esi
  802435:	5d                   	pop    %ebp
  802436:	c3                   	ret    

00802437 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802437:	55                   	push   %ebp
  802438:	89 e5                	mov    %esp,%ebp
  80243a:	53                   	push   %ebx
  80243b:	83 ec 14             	sub    $0x14,%esp
  80243e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802441:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802445:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80244c:	e8 b3 ee ff ff       	call   801304 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802451:	89 1c 24             	mov    %ebx,(%esp)
  802454:	e8 0f f2 ff ff       	call   801668 <fd2data>
  802459:	89 44 24 04          	mov    %eax,0x4(%esp)
  80245d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802464:	e8 9b ee ff ff       	call   801304 <sys_page_unmap>
}
  802469:	83 c4 14             	add    $0x14,%esp
  80246c:	5b                   	pop    %ebx
  80246d:	5d                   	pop    %ebp
  80246e:	c3                   	ret    

0080246f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80246f:	55                   	push   %ebp
  802470:	89 e5                	mov    %esp,%ebp
  802472:	57                   	push   %edi
  802473:	56                   	push   %esi
  802474:	53                   	push   %ebx
  802475:	83 ec 2c             	sub    $0x2c,%esp
  802478:	89 c7                	mov    %eax,%edi
  80247a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80247d:	a1 08 50 80 00       	mov    0x805008,%eax
  802482:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802485:	89 3c 24             	mov    %edi,(%esp)
  802488:	e8 6f 04 00 00       	call   8028fc <pageref>
  80248d:	89 c6                	mov    %eax,%esi
  80248f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802492:	89 04 24             	mov    %eax,(%esp)
  802495:	e8 62 04 00 00       	call   8028fc <pageref>
  80249a:	39 c6                	cmp    %eax,%esi
  80249c:	0f 94 c0             	sete   %al
  80249f:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8024a2:	8b 15 08 50 80 00    	mov    0x805008,%edx
  8024a8:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8024ab:	39 cb                	cmp    %ecx,%ebx
  8024ad:	75 08                	jne    8024b7 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8024af:	83 c4 2c             	add    $0x2c,%esp
  8024b2:	5b                   	pop    %ebx
  8024b3:	5e                   	pop    %esi
  8024b4:	5f                   	pop    %edi
  8024b5:	5d                   	pop    %ebp
  8024b6:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8024b7:	83 f8 01             	cmp    $0x1,%eax
  8024ba:	75 c1                	jne    80247d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8024bc:	8b 42 58             	mov    0x58(%edx),%eax
  8024bf:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  8024c6:	00 
  8024c7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8024cb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8024cf:	c7 04 24 0b 34 80 00 	movl   $0x80340b,(%esp)
  8024d6:	e8 e5 e3 ff ff       	call   8008c0 <cprintf>
  8024db:	eb a0                	jmp    80247d <_pipeisclosed+0xe>

008024dd <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8024dd:	55                   	push   %ebp
  8024de:	89 e5                	mov    %esp,%ebp
  8024e0:	57                   	push   %edi
  8024e1:	56                   	push   %esi
  8024e2:	53                   	push   %ebx
  8024e3:	83 ec 1c             	sub    $0x1c,%esp
  8024e6:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8024e9:	89 34 24             	mov    %esi,(%esp)
  8024ec:	e8 77 f1 ff ff       	call   801668 <fd2data>
  8024f1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8024f3:	bf 00 00 00 00       	mov    $0x0,%edi
  8024f8:	eb 3c                	jmp    802536 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8024fa:	89 da                	mov    %ebx,%edx
  8024fc:	89 f0                	mov    %esi,%eax
  8024fe:	e8 6c ff ff ff       	call   80246f <_pipeisclosed>
  802503:	85 c0                	test   %eax,%eax
  802505:	75 38                	jne    80253f <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802507:	e8 32 ed ff ff       	call   80123e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80250c:	8b 43 04             	mov    0x4(%ebx),%eax
  80250f:	8b 13                	mov    (%ebx),%edx
  802511:	83 c2 20             	add    $0x20,%edx
  802514:	39 d0                	cmp    %edx,%eax
  802516:	73 e2                	jae    8024fa <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802518:	8b 55 0c             	mov    0xc(%ebp),%edx
  80251b:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  80251e:	89 c2                	mov    %eax,%edx
  802520:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  802526:	79 05                	jns    80252d <devpipe_write+0x50>
  802528:	4a                   	dec    %edx
  802529:	83 ca e0             	or     $0xffffffe0,%edx
  80252c:	42                   	inc    %edx
  80252d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802531:	40                   	inc    %eax
  802532:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802535:	47                   	inc    %edi
  802536:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802539:	75 d1                	jne    80250c <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80253b:	89 f8                	mov    %edi,%eax
  80253d:	eb 05                	jmp    802544 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80253f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802544:	83 c4 1c             	add    $0x1c,%esp
  802547:	5b                   	pop    %ebx
  802548:	5e                   	pop    %esi
  802549:	5f                   	pop    %edi
  80254a:	5d                   	pop    %ebp
  80254b:	c3                   	ret    

0080254c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80254c:	55                   	push   %ebp
  80254d:	89 e5                	mov    %esp,%ebp
  80254f:	57                   	push   %edi
  802550:	56                   	push   %esi
  802551:	53                   	push   %ebx
  802552:	83 ec 1c             	sub    $0x1c,%esp
  802555:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802558:	89 3c 24             	mov    %edi,(%esp)
  80255b:	e8 08 f1 ff ff       	call   801668 <fd2data>
  802560:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802562:	be 00 00 00 00       	mov    $0x0,%esi
  802567:	eb 3a                	jmp    8025a3 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802569:	85 f6                	test   %esi,%esi
  80256b:	74 04                	je     802571 <devpipe_read+0x25>
				return i;
  80256d:	89 f0                	mov    %esi,%eax
  80256f:	eb 40                	jmp    8025b1 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802571:	89 da                	mov    %ebx,%edx
  802573:	89 f8                	mov    %edi,%eax
  802575:	e8 f5 fe ff ff       	call   80246f <_pipeisclosed>
  80257a:	85 c0                	test   %eax,%eax
  80257c:	75 2e                	jne    8025ac <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80257e:	e8 bb ec ff ff       	call   80123e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802583:	8b 03                	mov    (%ebx),%eax
  802585:	3b 43 04             	cmp    0x4(%ebx),%eax
  802588:	74 df                	je     802569 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80258a:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80258f:	79 05                	jns    802596 <devpipe_read+0x4a>
  802591:	48                   	dec    %eax
  802592:	83 c8 e0             	or     $0xffffffe0,%eax
  802595:	40                   	inc    %eax
  802596:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80259a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80259d:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8025a0:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8025a2:	46                   	inc    %esi
  8025a3:	3b 75 10             	cmp    0x10(%ebp),%esi
  8025a6:	75 db                	jne    802583 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8025a8:	89 f0                	mov    %esi,%eax
  8025aa:	eb 05                	jmp    8025b1 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8025ac:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8025b1:	83 c4 1c             	add    $0x1c,%esp
  8025b4:	5b                   	pop    %ebx
  8025b5:	5e                   	pop    %esi
  8025b6:	5f                   	pop    %edi
  8025b7:	5d                   	pop    %ebp
  8025b8:	c3                   	ret    

008025b9 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8025b9:	55                   	push   %ebp
  8025ba:	89 e5                	mov    %esp,%ebp
  8025bc:	57                   	push   %edi
  8025bd:	56                   	push   %esi
  8025be:	53                   	push   %ebx
  8025bf:	83 ec 3c             	sub    $0x3c,%esp
  8025c2:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8025c5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8025c8:	89 04 24             	mov    %eax,(%esp)
  8025cb:	e8 b3 f0 ff ff       	call   801683 <fd_alloc>
  8025d0:	89 c3                	mov    %eax,%ebx
  8025d2:	85 c0                	test   %eax,%eax
  8025d4:	0f 88 45 01 00 00    	js     80271f <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8025da:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8025e1:	00 
  8025e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8025e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8025f0:	e8 68 ec ff ff       	call   80125d <sys_page_alloc>
  8025f5:	89 c3                	mov    %eax,%ebx
  8025f7:	85 c0                	test   %eax,%eax
  8025f9:	0f 88 20 01 00 00    	js     80271f <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8025ff:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802602:	89 04 24             	mov    %eax,(%esp)
  802605:	e8 79 f0 ff ff       	call   801683 <fd_alloc>
  80260a:	89 c3                	mov    %eax,%ebx
  80260c:	85 c0                	test   %eax,%eax
  80260e:	0f 88 f8 00 00 00    	js     80270c <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802614:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80261b:	00 
  80261c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80261f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802623:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80262a:	e8 2e ec ff ff       	call   80125d <sys_page_alloc>
  80262f:	89 c3                	mov    %eax,%ebx
  802631:	85 c0                	test   %eax,%eax
  802633:	0f 88 d3 00 00 00    	js     80270c <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802639:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80263c:	89 04 24             	mov    %eax,(%esp)
  80263f:	e8 24 f0 ff ff       	call   801668 <fd2data>
  802644:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802646:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80264d:	00 
  80264e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802652:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802659:	e8 ff eb ff ff       	call   80125d <sys_page_alloc>
  80265e:	89 c3                	mov    %eax,%ebx
  802660:	85 c0                	test   %eax,%eax
  802662:	0f 88 91 00 00 00    	js     8026f9 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802668:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80266b:	89 04 24             	mov    %eax,(%esp)
  80266e:	e8 f5 ef ff ff       	call   801668 <fd2data>
  802673:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  80267a:	00 
  80267b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80267f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802686:	00 
  802687:	89 74 24 04          	mov    %esi,0x4(%esp)
  80268b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802692:	e8 1a ec ff ff       	call   8012b1 <sys_page_map>
  802697:	89 c3                	mov    %eax,%ebx
  802699:	85 c0                	test   %eax,%eax
  80269b:	78 4c                	js     8026e9 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80269d:	8b 15 40 40 80 00    	mov    0x804040,%edx
  8026a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8026a6:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8026a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8026ab:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8026b2:	8b 15 40 40 80 00    	mov    0x804040,%edx
  8026b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8026bb:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8026bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8026c0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8026c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8026ca:	89 04 24             	mov    %eax,(%esp)
  8026cd:	e8 86 ef ff ff       	call   801658 <fd2num>
  8026d2:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8026d4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8026d7:	89 04 24             	mov    %eax,(%esp)
  8026da:	e8 79 ef ff ff       	call   801658 <fd2num>
  8026df:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8026e2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8026e7:	eb 36                	jmp    80271f <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  8026e9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026ed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8026f4:	e8 0b ec ff ff       	call   801304 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8026f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8026fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  802700:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802707:	e8 f8 eb ff ff       	call   801304 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  80270c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80270f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802713:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80271a:	e8 e5 eb ff ff       	call   801304 <sys_page_unmap>
    err:
	return r;
}
  80271f:	89 d8                	mov    %ebx,%eax
  802721:	83 c4 3c             	add    $0x3c,%esp
  802724:	5b                   	pop    %ebx
  802725:	5e                   	pop    %esi
  802726:	5f                   	pop    %edi
  802727:	5d                   	pop    %ebp
  802728:	c3                   	ret    

00802729 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802729:	55                   	push   %ebp
  80272a:	89 e5                	mov    %esp,%ebp
  80272c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80272f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802732:	89 44 24 04          	mov    %eax,0x4(%esp)
  802736:	8b 45 08             	mov    0x8(%ebp),%eax
  802739:	89 04 24             	mov    %eax,(%esp)
  80273c:	e8 95 ef ff ff       	call   8016d6 <fd_lookup>
  802741:	85 c0                	test   %eax,%eax
  802743:	78 15                	js     80275a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802745:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802748:	89 04 24             	mov    %eax,(%esp)
  80274b:	e8 18 ef ff ff       	call   801668 <fd2data>
	return _pipeisclosed(fd, p);
  802750:	89 c2                	mov    %eax,%edx
  802752:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802755:	e8 15 fd ff ff       	call   80246f <_pipeisclosed>
}
  80275a:	c9                   	leave  
  80275b:	c3                   	ret    

0080275c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80275c:	55                   	push   %ebp
  80275d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80275f:	b8 00 00 00 00       	mov    $0x0,%eax
  802764:	5d                   	pop    %ebp
  802765:	c3                   	ret    

00802766 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802766:	55                   	push   %ebp
  802767:	89 e5                	mov    %esp,%ebp
  802769:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  80276c:	c7 44 24 04 23 34 80 	movl   $0x803423,0x4(%esp)
  802773:	00 
  802774:	8b 45 0c             	mov    0xc(%ebp),%eax
  802777:	89 04 24             	mov    %eax,(%esp)
  80277a:	e8 ec e6 ff ff       	call   800e6b <strcpy>
	return 0;
}
  80277f:	b8 00 00 00 00       	mov    $0x0,%eax
  802784:	c9                   	leave  
  802785:	c3                   	ret    

00802786 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802786:	55                   	push   %ebp
  802787:	89 e5                	mov    %esp,%ebp
  802789:	57                   	push   %edi
  80278a:	56                   	push   %esi
  80278b:	53                   	push   %ebx
  80278c:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802792:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802797:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80279d:	eb 30                	jmp    8027cf <devcons_write+0x49>
		m = n - tot;
  80279f:	8b 75 10             	mov    0x10(%ebp),%esi
  8027a2:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8027a4:	83 fe 7f             	cmp    $0x7f,%esi
  8027a7:	76 05                	jbe    8027ae <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8027a9:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8027ae:	89 74 24 08          	mov    %esi,0x8(%esp)
  8027b2:	03 45 0c             	add    0xc(%ebp),%eax
  8027b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027b9:	89 3c 24             	mov    %edi,(%esp)
  8027bc:	e8 23 e8 ff ff       	call   800fe4 <memmove>
		sys_cputs(buf, m);
  8027c1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8027c5:	89 3c 24             	mov    %edi,(%esp)
  8027c8:	e8 c3 e9 ff ff       	call   801190 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8027cd:	01 f3                	add    %esi,%ebx
  8027cf:	89 d8                	mov    %ebx,%eax
  8027d1:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8027d4:	72 c9                	jb     80279f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8027d6:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8027dc:	5b                   	pop    %ebx
  8027dd:	5e                   	pop    %esi
  8027de:	5f                   	pop    %edi
  8027df:	5d                   	pop    %ebp
  8027e0:	c3                   	ret    

008027e1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8027e1:	55                   	push   %ebp
  8027e2:	89 e5                	mov    %esp,%ebp
  8027e4:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8027e7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8027eb:	75 07                	jne    8027f4 <devcons_read+0x13>
  8027ed:	eb 25                	jmp    802814 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8027ef:	e8 4a ea ff ff       	call   80123e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8027f4:	e8 b5 e9 ff ff       	call   8011ae <sys_cgetc>
  8027f9:	85 c0                	test   %eax,%eax
  8027fb:	74 f2                	je     8027ef <devcons_read+0xe>
  8027fd:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8027ff:	85 c0                	test   %eax,%eax
  802801:	78 1d                	js     802820 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802803:	83 f8 04             	cmp    $0x4,%eax
  802806:	74 13                	je     80281b <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802808:	8b 45 0c             	mov    0xc(%ebp),%eax
  80280b:	88 10                	mov    %dl,(%eax)
	return 1;
  80280d:	b8 01 00 00 00       	mov    $0x1,%eax
  802812:	eb 0c                	jmp    802820 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802814:	b8 00 00 00 00       	mov    $0x0,%eax
  802819:	eb 05                	jmp    802820 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80281b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802820:	c9                   	leave  
  802821:	c3                   	ret    

00802822 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802822:	55                   	push   %ebp
  802823:	89 e5                	mov    %esp,%ebp
  802825:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802828:	8b 45 08             	mov    0x8(%ebp),%eax
  80282b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80282e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802835:	00 
  802836:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802839:	89 04 24             	mov    %eax,(%esp)
  80283c:	e8 4f e9 ff ff       	call   801190 <sys_cputs>
}
  802841:	c9                   	leave  
  802842:	c3                   	ret    

00802843 <getchar>:

int
getchar(void)
{
  802843:	55                   	push   %ebp
  802844:	89 e5                	mov    %esp,%ebp
  802846:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802849:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802850:	00 
  802851:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802854:	89 44 24 04          	mov    %eax,0x4(%esp)
  802858:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80285f:	e8 0e f1 ff ff       	call   801972 <read>
	if (r < 0)
  802864:	85 c0                	test   %eax,%eax
  802866:	78 0f                	js     802877 <getchar+0x34>
		return r;
	if (r < 1)
  802868:	85 c0                	test   %eax,%eax
  80286a:	7e 06                	jle    802872 <getchar+0x2f>
		return -E_EOF;
	return c;
  80286c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802870:	eb 05                	jmp    802877 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802872:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802877:	c9                   	leave  
  802878:	c3                   	ret    

00802879 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802879:	55                   	push   %ebp
  80287a:	89 e5                	mov    %esp,%ebp
  80287c:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80287f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802882:	89 44 24 04          	mov    %eax,0x4(%esp)
  802886:	8b 45 08             	mov    0x8(%ebp),%eax
  802889:	89 04 24             	mov    %eax,(%esp)
  80288c:	e8 45 ee ff ff       	call   8016d6 <fd_lookup>
  802891:	85 c0                	test   %eax,%eax
  802893:	78 11                	js     8028a6 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802895:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802898:	8b 15 5c 40 80 00    	mov    0x80405c,%edx
  80289e:	39 10                	cmp    %edx,(%eax)
  8028a0:	0f 94 c0             	sete   %al
  8028a3:	0f b6 c0             	movzbl %al,%eax
}
  8028a6:	c9                   	leave  
  8028a7:	c3                   	ret    

008028a8 <opencons>:

int
opencons(void)
{
  8028a8:	55                   	push   %ebp
  8028a9:	89 e5                	mov    %esp,%ebp
  8028ab:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8028ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8028b1:	89 04 24             	mov    %eax,(%esp)
  8028b4:	e8 ca ed ff ff       	call   801683 <fd_alloc>
  8028b9:	85 c0                	test   %eax,%eax
  8028bb:	78 3c                	js     8028f9 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8028bd:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8028c4:	00 
  8028c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8028cc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8028d3:	e8 85 e9 ff ff       	call   80125d <sys_page_alloc>
  8028d8:	85 c0                	test   %eax,%eax
  8028da:	78 1d                	js     8028f9 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8028dc:	8b 15 5c 40 80 00    	mov    0x80405c,%edx
  8028e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028e5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8028e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028ea:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8028f1:	89 04 24             	mov    %eax,(%esp)
  8028f4:	e8 5f ed ff ff       	call   801658 <fd2num>
}
  8028f9:	c9                   	leave  
  8028fa:	c3                   	ret    
	...

008028fc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8028fc:	55                   	push   %ebp
  8028fd:	89 e5                	mov    %esp,%ebp
  8028ff:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802902:	89 c2                	mov    %eax,%edx
  802904:	c1 ea 16             	shr    $0x16,%edx
  802907:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80290e:	f6 c2 01             	test   $0x1,%dl
  802911:	74 1e                	je     802931 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802913:	c1 e8 0c             	shr    $0xc,%eax
  802916:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80291d:	a8 01                	test   $0x1,%al
  80291f:	74 17                	je     802938 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802921:	c1 e8 0c             	shr    $0xc,%eax
  802924:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80292b:	ef 
  80292c:	0f b7 c0             	movzwl %ax,%eax
  80292f:	eb 0c                	jmp    80293d <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802931:	b8 00 00 00 00       	mov    $0x0,%eax
  802936:	eb 05                	jmp    80293d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802938:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  80293d:	5d                   	pop    %ebp
  80293e:	c3                   	ret    
	...

00802940 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802940:	55                   	push   %ebp
  802941:	57                   	push   %edi
  802942:	56                   	push   %esi
  802943:	83 ec 10             	sub    $0x10,%esp
  802946:	8b 74 24 20          	mov    0x20(%esp),%esi
  80294a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80294e:	89 74 24 04          	mov    %esi,0x4(%esp)
  802952:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  802956:	89 cd                	mov    %ecx,%ebp
  802958:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80295c:	85 c0                	test   %eax,%eax
  80295e:	75 2c                	jne    80298c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802960:	39 f9                	cmp    %edi,%ecx
  802962:	77 68                	ja     8029cc <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802964:	85 c9                	test   %ecx,%ecx
  802966:	75 0b                	jne    802973 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802968:	b8 01 00 00 00       	mov    $0x1,%eax
  80296d:	31 d2                	xor    %edx,%edx
  80296f:	f7 f1                	div    %ecx
  802971:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802973:	31 d2                	xor    %edx,%edx
  802975:	89 f8                	mov    %edi,%eax
  802977:	f7 f1                	div    %ecx
  802979:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80297b:	89 f0                	mov    %esi,%eax
  80297d:	f7 f1                	div    %ecx
  80297f:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802981:	89 f0                	mov    %esi,%eax
  802983:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802985:	83 c4 10             	add    $0x10,%esp
  802988:	5e                   	pop    %esi
  802989:	5f                   	pop    %edi
  80298a:	5d                   	pop    %ebp
  80298b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80298c:	39 f8                	cmp    %edi,%eax
  80298e:	77 2c                	ja     8029bc <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802990:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  802993:	83 f6 1f             	xor    $0x1f,%esi
  802996:	75 4c                	jne    8029e4 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802998:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80299a:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80299f:	72 0a                	jb     8029ab <__udivdi3+0x6b>
  8029a1:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8029a5:	0f 87 ad 00 00 00    	ja     802a58 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8029ab:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8029b0:	89 f0                	mov    %esi,%eax
  8029b2:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8029b4:	83 c4 10             	add    $0x10,%esp
  8029b7:	5e                   	pop    %esi
  8029b8:	5f                   	pop    %edi
  8029b9:	5d                   	pop    %ebp
  8029ba:	c3                   	ret    
  8029bb:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8029bc:	31 ff                	xor    %edi,%edi
  8029be:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8029c0:	89 f0                	mov    %esi,%eax
  8029c2:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8029c4:	83 c4 10             	add    $0x10,%esp
  8029c7:	5e                   	pop    %esi
  8029c8:	5f                   	pop    %edi
  8029c9:	5d                   	pop    %ebp
  8029ca:	c3                   	ret    
  8029cb:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8029cc:	89 fa                	mov    %edi,%edx
  8029ce:	89 f0                	mov    %esi,%eax
  8029d0:	f7 f1                	div    %ecx
  8029d2:	89 c6                	mov    %eax,%esi
  8029d4:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8029d6:	89 f0                	mov    %esi,%eax
  8029d8:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8029da:	83 c4 10             	add    $0x10,%esp
  8029dd:	5e                   	pop    %esi
  8029de:	5f                   	pop    %edi
  8029df:	5d                   	pop    %ebp
  8029e0:	c3                   	ret    
  8029e1:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8029e4:	89 f1                	mov    %esi,%ecx
  8029e6:	d3 e0                	shl    %cl,%eax
  8029e8:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8029ec:	b8 20 00 00 00       	mov    $0x20,%eax
  8029f1:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8029f3:	89 ea                	mov    %ebp,%edx
  8029f5:	88 c1                	mov    %al,%cl
  8029f7:	d3 ea                	shr    %cl,%edx
  8029f9:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8029fd:	09 ca                	or     %ecx,%edx
  8029ff:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  802a03:	89 f1                	mov    %esi,%ecx
  802a05:	d3 e5                	shl    %cl,%ebp
  802a07:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  802a0b:	89 fd                	mov    %edi,%ebp
  802a0d:	88 c1                	mov    %al,%cl
  802a0f:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802a11:	89 fa                	mov    %edi,%edx
  802a13:	89 f1                	mov    %esi,%ecx
  802a15:	d3 e2                	shl    %cl,%edx
  802a17:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802a1b:	88 c1                	mov    %al,%cl
  802a1d:	d3 ef                	shr    %cl,%edi
  802a1f:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802a21:	89 f8                	mov    %edi,%eax
  802a23:	89 ea                	mov    %ebp,%edx
  802a25:	f7 74 24 08          	divl   0x8(%esp)
  802a29:	89 d1                	mov    %edx,%ecx
  802a2b:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802a2d:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802a31:	39 d1                	cmp    %edx,%ecx
  802a33:	72 17                	jb     802a4c <__udivdi3+0x10c>
  802a35:	74 09                	je     802a40 <__udivdi3+0x100>
  802a37:	89 fe                	mov    %edi,%esi
  802a39:	31 ff                	xor    %edi,%edi
  802a3b:	e9 41 ff ff ff       	jmp    802981 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802a40:	8b 54 24 04          	mov    0x4(%esp),%edx
  802a44:	89 f1                	mov    %esi,%ecx
  802a46:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802a48:	39 c2                	cmp    %eax,%edx
  802a4a:	73 eb                	jae    802a37 <__udivdi3+0xf7>
		{
		  q0--;
  802a4c:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802a4f:	31 ff                	xor    %edi,%edi
  802a51:	e9 2b ff ff ff       	jmp    802981 <__udivdi3+0x41>
  802a56:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802a58:	31 f6                	xor    %esi,%esi
  802a5a:	e9 22 ff ff ff       	jmp    802981 <__udivdi3+0x41>
	...

00802a60 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802a60:	55                   	push   %ebp
  802a61:	57                   	push   %edi
  802a62:	56                   	push   %esi
  802a63:	83 ec 20             	sub    $0x20,%esp
  802a66:	8b 44 24 30          	mov    0x30(%esp),%eax
  802a6a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802a6e:	89 44 24 14          	mov    %eax,0x14(%esp)
  802a72:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  802a76:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802a7a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802a7e:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802a80:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802a82:	85 ed                	test   %ebp,%ebp
  802a84:	75 16                	jne    802a9c <__umoddi3+0x3c>
    {
      if (d0 > n1)
  802a86:	39 f1                	cmp    %esi,%ecx
  802a88:	0f 86 a6 00 00 00    	jbe    802b34 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802a8e:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802a90:	89 d0                	mov    %edx,%eax
  802a92:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802a94:	83 c4 20             	add    $0x20,%esp
  802a97:	5e                   	pop    %esi
  802a98:	5f                   	pop    %edi
  802a99:	5d                   	pop    %ebp
  802a9a:	c3                   	ret    
  802a9b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802a9c:	39 f5                	cmp    %esi,%ebp
  802a9e:	0f 87 ac 00 00 00    	ja     802b50 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802aa4:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  802aa7:	83 f0 1f             	xor    $0x1f,%eax
  802aaa:	89 44 24 10          	mov    %eax,0x10(%esp)
  802aae:	0f 84 a8 00 00 00    	je     802b5c <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802ab4:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802ab8:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802aba:	bf 20 00 00 00       	mov    $0x20,%edi
  802abf:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802ac3:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802ac7:	89 f9                	mov    %edi,%ecx
  802ac9:	d3 e8                	shr    %cl,%eax
  802acb:	09 e8                	or     %ebp,%eax
  802acd:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  802ad1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802ad5:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802ad9:	d3 e0                	shl    %cl,%eax
  802adb:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802adf:	89 f2                	mov    %esi,%edx
  802ae1:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802ae3:	8b 44 24 14          	mov    0x14(%esp),%eax
  802ae7:	d3 e0                	shl    %cl,%eax
  802ae9:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802aed:	8b 44 24 14          	mov    0x14(%esp),%eax
  802af1:	89 f9                	mov    %edi,%ecx
  802af3:	d3 e8                	shr    %cl,%eax
  802af5:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802af7:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802af9:	89 f2                	mov    %esi,%edx
  802afb:	f7 74 24 18          	divl   0x18(%esp)
  802aff:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802b01:	f7 64 24 0c          	mull   0xc(%esp)
  802b05:	89 c5                	mov    %eax,%ebp
  802b07:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802b09:	39 d6                	cmp    %edx,%esi
  802b0b:	72 67                	jb     802b74 <__umoddi3+0x114>
  802b0d:	74 75                	je     802b84 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802b0f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802b13:	29 e8                	sub    %ebp,%eax
  802b15:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802b17:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802b1b:	d3 e8                	shr    %cl,%eax
  802b1d:	89 f2                	mov    %esi,%edx
  802b1f:	89 f9                	mov    %edi,%ecx
  802b21:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802b23:	09 d0                	or     %edx,%eax
  802b25:	89 f2                	mov    %esi,%edx
  802b27:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802b2b:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802b2d:	83 c4 20             	add    $0x20,%esp
  802b30:	5e                   	pop    %esi
  802b31:	5f                   	pop    %edi
  802b32:	5d                   	pop    %ebp
  802b33:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802b34:	85 c9                	test   %ecx,%ecx
  802b36:	75 0b                	jne    802b43 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802b38:	b8 01 00 00 00       	mov    $0x1,%eax
  802b3d:	31 d2                	xor    %edx,%edx
  802b3f:	f7 f1                	div    %ecx
  802b41:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802b43:	89 f0                	mov    %esi,%eax
  802b45:	31 d2                	xor    %edx,%edx
  802b47:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802b49:	89 f8                	mov    %edi,%eax
  802b4b:	e9 3e ff ff ff       	jmp    802a8e <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802b50:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802b52:	83 c4 20             	add    $0x20,%esp
  802b55:	5e                   	pop    %esi
  802b56:	5f                   	pop    %edi
  802b57:	5d                   	pop    %ebp
  802b58:	c3                   	ret    
  802b59:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802b5c:	39 f5                	cmp    %esi,%ebp
  802b5e:	72 04                	jb     802b64 <__umoddi3+0x104>
  802b60:	39 f9                	cmp    %edi,%ecx
  802b62:	77 06                	ja     802b6a <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802b64:	89 f2                	mov    %esi,%edx
  802b66:	29 cf                	sub    %ecx,%edi
  802b68:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802b6a:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802b6c:	83 c4 20             	add    $0x20,%esp
  802b6f:	5e                   	pop    %esi
  802b70:	5f                   	pop    %edi
  802b71:	5d                   	pop    %ebp
  802b72:	c3                   	ret    
  802b73:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802b74:	89 d1                	mov    %edx,%ecx
  802b76:	89 c5                	mov    %eax,%ebp
  802b78:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802b7c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802b80:	eb 8d                	jmp    802b0f <__umoddi3+0xaf>
  802b82:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802b84:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802b88:	72 ea                	jb     802b74 <__umoddi3+0x114>
  802b8a:	89 f1                	mov    %esi,%ecx
  802b8c:	eb 81                	jmp    802b0f <__umoddi3+0xaf>
