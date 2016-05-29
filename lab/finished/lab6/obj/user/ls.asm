
obj/user/ls.debug:     file format elf32-i386


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
  80002c:	e8 f7 02 00 00       	call   800328 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <ls1>:
		panic("error reading directory %s: %e", path, n);
}

void
ls1(const char *prefix, bool isdir, off_t size, const char *name)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 24             	sub    $0x24,%esp
  80003b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80003e:	8a 45 0c             	mov    0xc(%ebp),%al
  800041:	88 45 f7             	mov    %al,-0x9(%ebp)
	const char *sep;

	if(flag['l'])
  800044:	83 3d d0 41 80 00 00 	cmpl   $0x0,0x8041d0
  80004b:	74 21                	je     80006e <ls1+0x3a>
		printf("%11d %c ", size, isdir ? 'd' : '-');
  80004d:	3c 01                	cmp    $0x1,%al
  80004f:	19 c0                	sbb    %eax,%eax
  800051:	83 e0 c9             	and    $0xffffffc9,%eax
  800054:	83 c0 64             	add    $0x64,%eax
  800057:	89 44 24 08          	mov    %eax,0x8(%esp)
  80005b:	8b 45 10             	mov    0x10(%ebp),%eax
  80005e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800062:	c7 04 24 e2 29 80 00 	movl   $0x8029e2,(%esp)
  800069:	e8 93 1b 00 00       	call   801c01 <printf>
	if(prefix) {
  80006e:	85 db                	test   %ebx,%ebx
  800070:	74 3b                	je     8000ad <ls1+0x79>
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
  800072:	80 3b 00             	cmpb   $0x0,(%ebx)
  800075:	74 16                	je     80008d <ls1+0x59>
  800077:	89 1c 24             	mov    %ebx,(%esp)
  80007a:	e8 75 09 00 00       	call   8009f4 <strlen>
  80007f:	80 7c 03 ff 2f       	cmpb   $0x2f,-0x1(%ebx,%eax,1)
  800084:	74 0e                	je     800094 <ls1+0x60>
			sep = "/";
  800086:	b8 e0 29 80 00       	mov    $0x8029e0,%eax
  80008b:	eb 0c                	jmp    800099 <ls1+0x65>
		else
			sep = "";
  80008d:	b8 48 2a 80 00       	mov    $0x802a48,%eax
  800092:	eb 05                	jmp    800099 <ls1+0x65>
  800094:	b8 48 2a 80 00       	mov    $0x802a48,%eax
		printf("%s%s", prefix, sep);
  800099:	89 44 24 08          	mov    %eax,0x8(%esp)
  80009d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000a1:	c7 04 24 eb 29 80 00 	movl   $0x8029eb,(%esp)
  8000a8:	e8 54 1b 00 00       	call   801c01 <printf>
	}
	printf("%s", name);
  8000ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8000b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b4:	c7 04 24 7d 2e 80 00 	movl   $0x802e7d,(%esp)
  8000bb:	e8 41 1b 00 00       	call   801c01 <printf>
	if(flag['F'] && isdir)
  8000c0:	83 3d 38 41 80 00 00 	cmpl   $0x0,0x804138
  8000c7:	74 12                	je     8000db <ls1+0xa7>
  8000c9:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  8000cd:	74 0c                	je     8000db <ls1+0xa7>
		printf("/");
  8000cf:	c7 04 24 e0 29 80 00 	movl   $0x8029e0,(%esp)
  8000d6:	e8 26 1b 00 00       	call   801c01 <printf>
	printf("\n");
  8000db:	c7 04 24 47 2a 80 00 	movl   $0x802a47,(%esp)
  8000e2:	e8 1a 1b 00 00       	call   801c01 <printf>
}
  8000e7:	83 c4 24             	add    $0x24,%esp
  8000ea:	5b                   	pop    %ebx
  8000eb:	5d                   	pop    %ebp
  8000ec:	c3                   	ret    

008000ed <lsdir>:
		ls1(0, st.st_isdir, st.st_size, path);
}

void
lsdir(const char *path, const char *prefix)
{
  8000ed:	55                   	push   %ebp
  8000ee:	89 e5                	mov    %esp,%ebp
  8000f0:	57                   	push   %edi
  8000f1:	56                   	push   %esi
  8000f2:	53                   	push   %ebx
  8000f3:	81 ec 2c 01 00 00    	sub    $0x12c,%esp
  8000f9:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int fd, n;
	struct File f;

	if ((fd = open(path, O_RDONLY)) < 0)
  8000fc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800103:	00 
  800104:	8b 45 08             	mov    0x8(%ebp),%eax
  800107:	89 04 24             	mov    %eax,(%esp)
  80010a:	e8 3d 19 00 00       	call   801a4c <open>
  80010f:	89 c6                	mov    %eax,%esi
  800111:	85 c0                	test   %eax,%eax
  800113:	79 59                	jns    80016e <lsdir+0x81>
		panic("open %s: %e", path, fd);
  800115:	89 44 24 10          	mov    %eax,0x10(%esp)
  800119:	8b 45 08             	mov    0x8(%ebp),%eax
  80011c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800120:	c7 44 24 08 f0 29 80 	movl   $0x8029f0,0x8(%esp)
  800127:	00 
  800128:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  80012f:	00 
  800130:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  800137:	e8 48 02 00 00       	call   800384 <_panic>
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
		if (f.f_name[0])
  80013c:	80 bd e8 fe ff ff 00 	cmpb   $0x0,-0x118(%ebp)
  800143:	74 2f                	je     800174 <lsdir+0x87>
			ls1(prefix, f.f_type==FTYPE_DIR, f.f_size, f.f_name);
  800145:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800149:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
  80014f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800153:	83 bd 6c ff ff ff 01 	cmpl   $0x1,-0x94(%ebp)
  80015a:	0f 94 c0             	sete   %al
  80015d:	0f b6 c0             	movzbl %al,%eax
  800160:	89 44 24 04          	mov    %eax,0x4(%esp)
  800164:	89 3c 24             	mov    %edi,(%esp)
  800167:	e8 c8 fe ff ff       	call   800034 <ls1>
  80016c:	eb 06                	jmp    800174 <lsdir+0x87>
	int fd, n;
	struct File f;

	if ((fd = open(path, O_RDONLY)) < 0)
		panic("open %s: %e", path, fd);
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
  80016e:	8d 9d e8 fe ff ff    	lea    -0x118(%ebp),%ebx
  800174:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
  80017b:	00 
  80017c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800180:	89 34 24             	mov    %esi,(%esp)
  800183:	e8 7e 14 00 00       	call   801606 <readn>
  800188:	3d 00 01 00 00       	cmp    $0x100,%eax
  80018d:	74 ad                	je     80013c <lsdir+0x4f>
		if (f.f_name[0])
			ls1(prefix, f.f_type==FTYPE_DIR, f.f_size, f.f_name);
	if (n > 0)
  80018f:	85 c0                	test   %eax,%eax
  800191:	7e 23                	jle    8001b6 <lsdir+0xc9>
		panic("short read in directory %s", path);
  800193:	8b 45 08             	mov    0x8(%ebp),%eax
  800196:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80019a:	c7 44 24 08 06 2a 80 	movl   $0x802a06,0x8(%esp)
  8001a1:	00 
  8001a2:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8001a9:	00 
  8001aa:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  8001b1:	e8 ce 01 00 00       	call   800384 <_panic>
	if (n < 0)
  8001b6:	85 c0                	test   %eax,%eax
  8001b8:	79 27                	jns    8001e1 <lsdir+0xf4>
		panic("error reading directory %s: %e", path, n);
  8001ba:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001be:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001c5:	c7 44 24 08 4c 2a 80 	movl   $0x802a4c,0x8(%esp)
  8001cc:	00 
  8001cd:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  8001d4:	00 
  8001d5:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  8001dc:	e8 a3 01 00 00       	call   800384 <_panic>
}
  8001e1:	81 c4 2c 01 00 00    	add    $0x12c,%esp
  8001e7:	5b                   	pop    %ebx
  8001e8:	5e                   	pop    %esi
  8001e9:	5f                   	pop    %edi
  8001ea:	5d                   	pop    %ebp
  8001eb:	c3                   	ret    

008001ec <ls>:
void lsdir(const char*, const char*);
void ls1(const char*, bool, off_t, const char*);

void
ls(const char *path, const char *prefix)
{
  8001ec:	55                   	push   %ebp
  8001ed:	89 e5                	mov    %esp,%ebp
  8001ef:	53                   	push   %ebx
  8001f0:	81 ec b4 00 00 00    	sub    $0xb4,%esp
  8001f6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Stat st;

	if ((r = stat(path, &st)) < 0)
  8001f9:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
  8001ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800203:	89 1c 24             	mov    %ebx,(%esp)
  800206:	e8 f9 15 00 00       	call   801804 <stat>
  80020b:	85 c0                	test   %eax,%eax
  80020d:	79 24                	jns    800233 <ls+0x47>
		panic("stat %s: %e", path, r);
  80020f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800213:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800217:	c7 44 24 08 21 2a 80 	movl   $0x802a21,0x8(%esp)
  80021e:	00 
  80021f:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  800226:	00 
  800227:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  80022e:	e8 51 01 00 00       	call   800384 <_panic>
	if (st.st_isdir && !flag['d'])
  800233:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800236:	85 c0                	test   %eax,%eax
  800238:	74 1a                	je     800254 <ls+0x68>
  80023a:	83 3d b0 41 80 00 00 	cmpl   $0x0,0x8041b0
  800241:	75 11                	jne    800254 <ls+0x68>
		lsdir(path, prefix);
  800243:	8b 45 0c             	mov    0xc(%ebp),%eax
  800246:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024a:	89 1c 24             	mov    %ebx,(%esp)
  80024d:	e8 9b fe ff ff       	call   8000ed <lsdir>
  800252:	eb 23                	jmp    800277 <ls+0x8b>
	else
		ls1(0, st.st_isdir, st.st_size, path);
  800254:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800258:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80025b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80025f:	85 c0                	test   %eax,%eax
  800261:	0f 95 c0             	setne  %al
  800264:	0f b6 c0             	movzbl %al,%eax
  800267:	89 44 24 04          	mov    %eax,0x4(%esp)
  80026b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800272:	e8 bd fd ff ff       	call   800034 <ls1>
}
  800277:	81 c4 b4 00 00 00    	add    $0xb4,%esp
  80027d:	5b                   	pop    %ebx
  80027e:	5d                   	pop    %ebp
  80027f:	c3                   	ret    

00800280 <usage>:
	printf("\n");
}

void
usage(void)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	83 ec 18             	sub    $0x18,%esp
	printf("usage: ls [-dFl] [file...]\n");
  800286:	c7 04 24 2d 2a 80 00 	movl   $0x802a2d,(%esp)
  80028d:	e8 6f 19 00 00       	call   801c01 <printf>
	exit();
  800292:	e8 d9 00 00 00       	call   800370 <exit>
}
  800297:	c9                   	leave  
  800298:	c3                   	ret    

00800299 <umain>:

void
umain(int argc, char **argv)
{
  800299:	55                   	push   %ebp
  80029a:	89 e5                	mov    %esp,%ebp
  80029c:	56                   	push   %esi
  80029d:	53                   	push   %ebx
  80029e:	83 ec 20             	sub    $0x20,%esp
  8002a1:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i;
	struct Argstate args;

	argstart(&argc, argv, &args);
  8002a4:	8d 45 e8             	lea    -0x18(%ebp),%eax
  8002a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ab:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002af:	8d 45 08             	lea    0x8(%ebp),%eax
  8002b2:	89 04 24             	mov    %eax,(%esp)
  8002b5:	e8 4a 0e 00 00       	call   801104 <argstart>
	while ((i = argnext(&args)) >= 0)
  8002ba:	8d 5d e8             	lea    -0x18(%ebp),%ebx
  8002bd:	eb 1d                	jmp    8002dc <umain+0x43>
		switch (i) {
  8002bf:	83 f8 64             	cmp    $0x64,%eax
  8002c2:	74 0a                	je     8002ce <umain+0x35>
  8002c4:	83 f8 6c             	cmp    $0x6c,%eax
  8002c7:	74 05                	je     8002ce <umain+0x35>
  8002c9:	83 f8 46             	cmp    $0x46,%eax
  8002cc:	75 09                	jne    8002d7 <umain+0x3e>
		case 'd':
		case 'F':
		case 'l':
			flag[i]++;
  8002ce:	ff 04 85 20 40 80 00 	incl   0x804020(,%eax,4)
			break;
  8002d5:	eb 05                	jmp    8002dc <umain+0x43>
		default:
			usage();
  8002d7:	e8 a4 ff ff ff       	call   800280 <usage>
{
	int i;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  8002dc:	89 1c 24             	mov    %ebx,(%esp)
  8002df:	e8 59 0e 00 00       	call   80113d <argnext>
  8002e4:	85 c0                	test   %eax,%eax
  8002e6:	79 d7                	jns    8002bf <umain+0x26>
			break;
		default:
			usage();
		}

	if (argc == 1)
  8002e8:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  8002ec:	75 28                	jne    800316 <umain+0x7d>
		ls("/", "");
  8002ee:	c7 44 24 04 48 2a 80 	movl   $0x802a48,0x4(%esp)
  8002f5:	00 
  8002f6:	c7 04 24 e0 29 80 00 	movl   $0x8029e0,(%esp)
  8002fd:	e8 ea fe ff ff       	call   8001ec <ls>
  800302:	eb 1c                	jmp    800320 <umain+0x87>
	else {
		for (i = 1; i < argc; i++)
			ls(argv[i], argv[i]);
  800304:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  800307:	89 44 24 04          	mov    %eax,0x4(%esp)
  80030b:	89 04 24             	mov    %eax,(%esp)
  80030e:	e8 d9 fe ff ff       	call   8001ec <ls>
		}

	if (argc == 1)
		ls("/", "");
	else {
		for (i = 1; i < argc; i++)
  800313:	43                   	inc    %ebx
  800314:	eb 05                	jmp    80031b <umain+0x82>
			break;
		default:
			usage();
		}

	if (argc == 1)
  800316:	bb 01 00 00 00       	mov    $0x1,%ebx
		ls("/", "");
	else {
		for (i = 1; i < argc; i++)
  80031b:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  80031e:	7c e4                	jl     800304 <umain+0x6b>
			ls(argv[i], argv[i]);
	}
}
  800320:	83 c4 20             	add    $0x20,%esp
  800323:	5b                   	pop    %ebx
  800324:	5e                   	pop    %esi
  800325:	5d                   	pop    %ebp
  800326:	c3                   	ret    
	...

00800328 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	56                   	push   %esi
  80032c:	53                   	push   %ebx
  80032d:	83 ec 10             	sub    $0x10,%esp
  800330:	8b 75 08             	mov    0x8(%ebp),%esi
  800333:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800336:	e8 a0 0a 00 00       	call   800ddb <sys_getenvid>
  80033b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800340:	c1 e0 07             	shl    $0x7,%eax
  800343:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800348:	a3 20 44 80 00       	mov    %eax,0x804420

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80034d:	85 f6                	test   %esi,%esi
  80034f:	7e 07                	jle    800358 <libmain+0x30>
		binaryname = argv[0];
  800351:	8b 03                	mov    (%ebx),%eax
  800353:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800358:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80035c:	89 34 24             	mov    %esi,(%esp)
  80035f:	e8 35 ff ff ff       	call   800299 <umain>

	// exit gracefully
	exit();
  800364:	e8 07 00 00 00       	call   800370 <exit>
}
  800369:	83 c4 10             	add    $0x10,%esp
  80036c:	5b                   	pop    %ebx
  80036d:	5e                   	pop    %esi
  80036e:	5d                   	pop    %ebp
  80036f:	c3                   	ret    

00800370 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800370:	55                   	push   %ebp
  800371:	89 e5                	mov    %esp,%ebp
  800373:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  800376:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80037d:	e8 07 0a 00 00       	call   800d89 <sys_env_destroy>
}
  800382:	c9                   	leave  
  800383:	c3                   	ret    

00800384 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	56                   	push   %esi
  800388:	53                   	push   %ebx
  800389:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80038c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80038f:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800395:	e8 41 0a 00 00       	call   800ddb <sys_getenvid>
  80039a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80039d:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003a8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b0:	c7 04 24 78 2a 80 00 	movl   $0x802a78,(%esp)
  8003b7:	e8 c0 00 00 00       	call   80047c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003bc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003c0:	8b 45 10             	mov    0x10(%ebp),%eax
  8003c3:	89 04 24             	mov    %eax,(%esp)
  8003c6:	e8 50 00 00 00       	call   80041b <vcprintf>
	cprintf("\n");
  8003cb:	c7 04 24 47 2a 80 00 	movl   $0x802a47,(%esp)
  8003d2:	e8 a5 00 00 00       	call   80047c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003d7:	cc                   	int3   
  8003d8:	eb fd                	jmp    8003d7 <_panic+0x53>
	...

008003dc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003dc:	55                   	push   %ebp
  8003dd:	89 e5                	mov    %esp,%ebp
  8003df:	53                   	push   %ebx
  8003e0:	83 ec 14             	sub    $0x14,%esp
  8003e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003e6:	8b 03                	mov    (%ebx),%eax
  8003e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8003eb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8003ef:	40                   	inc    %eax
  8003f0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8003f2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003f7:	75 19                	jne    800412 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8003f9:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800400:	00 
  800401:	8d 43 08             	lea    0x8(%ebx),%eax
  800404:	89 04 24             	mov    %eax,(%esp)
  800407:	e8 40 09 00 00       	call   800d4c <sys_cputs>
		b->idx = 0;
  80040c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800412:	ff 43 04             	incl   0x4(%ebx)
}
  800415:	83 c4 14             	add    $0x14,%esp
  800418:	5b                   	pop    %ebx
  800419:	5d                   	pop    %ebp
  80041a:	c3                   	ret    

0080041b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80041b:	55                   	push   %ebp
  80041c:	89 e5                	mov    %esp,%ebp
  80041e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800424:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80042b:	00 00 00 
	b.cnt = 0;
  80042e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800435:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800438:	8b 45 0c             	mov    0xc(%ebp),%eax
  80043b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80043f:	8b 45 08             	mov    0x8(%ebp),%eax
  800442:	89 44 24 08          	mov    %eax,0x8(%esp)
  800446:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80044c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800450:	c7 04 24 dc 03 80 00 	movl   $0x8003dc,(%esp)
  800457:	e8 82 01 00 00       	call   8005de <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80045c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800462:	89 44 24 04          	mov    %eax,0x4(%esp)
  800466:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80046c:	89 04 24             	mov    %eax,(%esp)
  80046f:	e8 d8 08 00 00       	call   800d4c <sys_cputs>

	return b.cnt;
}
  800474:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80047a:	c9                   	leave  
  80047b:	c3                   	ret    

0080047c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80047c:	55                   	push   %ebp
  80047d:	89 e5                	mov    %esp,%ebp
  80047f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800482:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800485:	89 44 24 04          	mov    %eax,0x4(%esp)
  800489:	8b 45 08             	mov    0x8(%ebp),%eax
  80048c:	89 04 24             	mov    %eax,(%esp)
  80048f:	e8 87 ff ff ff       	call   80041b <vcprintf>
	va_end(ap);

	return cnt;
}
  800494:	c9                   	leave  
  800495:	c3                   	ret    
	...

00800498 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800498:	55                   	push   %ebp
  800499:	89 e5                	mov    %esp,%ebp
  80049b:	57                   	push   %edi
  80049c:	56                   	push   %esi
  80049d:	53                   	push   %ebx
  80049e:	83 ec 3c             	sub    $0x3c,%esp
  8004a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004a4:	89 d7                	mov    %edx,%edi
  8004a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004af:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b2:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004b5:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004b8:	85 c0                	test   %eax,%eax
  8004ba:	75 08                	jne    8004c4 <printnum+0x2c>
  8004bc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004bf:	39 45 10             	cmp    %eax,0x10(%ebp)
  8004c2:	77 57                	ja     80051b <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004c4:	89 74 24 10          	mov    %esi,0x10(%esp)
  8004c8:	4b                   	dec    %ebx
  8004c9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8004cd:	8b 45 10             	mov    0x10(%ebp),%eax
  8004d0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004d4:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8004d8:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8004dc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004e3:	00 
  8004e4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004e7:	89 04 24             	mov    %eax,(%esp)
  8004ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004f1:	e8 96 22 00 00       	call   80278c <__udivdi3>
  8004f6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8004fa:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8004fe:	89 04 24             	mov    %eax,(%esp)
  800501:	89 54 24 04          	mov    %edx,0x4(%esp)
  800505:	89 fa                	mov    %edi,%edx
  800507:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80050a:	e8 89 ff ff ff       	call   800498 <printnum>
  80050f:	eb 0f                	jmp    800520 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800511:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800515:	89 34 24             	mov    %esi,(%esp)
  800518:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80051b:	4b                   	dec    %ebx
  80051c:	85 db                	test   %ebx,%ebx
  80051e:	7f f1                	jg     800511 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800520:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800524:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800528:	8b 45 10             	mov    0x10(%ebp),%eax
  80052b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80052f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800536:	00 
  800537:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80053a:	89 04 24             	mov    %eax,(%esp)
  80053d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800540:	89 44 24 04          	mov    %eax,0x4(%esp)
  800544:	e8 63 23 00 00       	call   8028ac <__umoddi3>
  800549:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80054d:	0f be 80 9b 2a 80 00 	movsbl 0x802a9b(%eax),%eax
  800554:	89 04 24             	mov    %eax,(%esp)
  800557:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80055a:	83 c4 3c             	add    $0x3c,%esp
  80055d:	5b                   	pop    %ebx
  80055e:	5e                   	pop    %esi
  80055f:	5f                   	pop    %edi
  800560:	5d                   	pop    %ebp
  800561:	c3                   	ret    

00800562 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800562:	55                   	push   %ebp
  800563:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800565:	83 fa 01             	cmp    $0x1,%edx
  800568:	7e 0e                	jle    800578 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80056a:	8b 10                	mov    (%eax),%edx
  80056c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80056f:	89 08                	mov    %ecx,(%eax)
  800571:	8b 02                	mov    (%edx),%eax
  800573:	8b 52 04             	mov    0x4(%edx),%edx
  800576:	eb 22                	jmp    80059a <getuint+0x38>
	else if (lflag)
  800578:	85 d2                	test   %edx,%edx
  80057a:	74 10                	je     80058c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80057c:	8b 10                	mov    (%eax),%edx
  80057e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800581:	89 08                	mov    %ecx,(%eax)
  800583:	8b 02                	mov    (%edx),%eax
  800585:	ba 00 00 00 00       	mov    $0x0,%edx
  80058a:	eb 0e                	jmp    80059a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80058c:	8b 10                	mov    (%eax),%edx
  80058e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800591:	89 08                	mov    %ecx,(%eax)
  800593:	8b 02                	mov    (%edx),%eax
  800595:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80059a:	5d                   	pop    %ebp
  80059b:	c3                   	ret    

0080059c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80059c:	55                   	push   %ebp
  80059d:	89 e5                	mov    %esp,%ebp
  80059f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005a2:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8005a5:	8b 10                	mov    (%eax),%edx
  8005a7:	3b 50 04             	cmp    0x4(%eax),%edx
  8005aa:	73 08                	jae    8005b4 <sprintputch+0x18>
		*b->buf++ = ch;
  8005ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8005af:	88 0a                	mov    %cl,(%edx)
  8005b1:	42                   	inc    %edx
  8005b2:	89 10                	mov    %edx,(%eax)
}
  8005b4:	5d                   	pop    %ebp
  8005b5:	c3                   	ret    

008005b6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005b6:	55                   	push   %ebp
  8005b7:	89 e5                	mov    %esp,%ebp
  8005b9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8005bc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005bf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005c3:	8b 45 10             	mov    0x10(%ebp),%eax
  8005c6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8005d4:	89 04 24             	mov    %eax,(%esp)
  8005d7:	e8 02 00 00 00       	call   8005de <vprintfmt>
	va_end(ap);
}
  8005dc:	c9                   	leave  
  8005dd:	c3                   	ret    

008005de <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8005de:	55                   	push   %ebp
  8005df:	89 e5                	mov    %esp,%ebp
  8005e1:	57                   	push   %edi
  8005e2:	56                   	push   %esi
  8005e3:	53                   	push   %ebx
  8005e4:	83 ec 4c             	sub    $0x4c,%esp
  8005e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005ea:	8b 75 10             	mov    0x10(%ebp),%esi
  8005ed:	eb 12                	jmp    800601 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8005ef:	85 c0                	test   %eax,%eax
  8005f1:	0f 84 6b 03 00 00    	je     800962 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8005f7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005fb:	89 04 24             	mov    %eax,(%esp)
  8005fe:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800601:	0f b6 06             	movzbl (%esi),%eax
  800604:	46                   	inc    %esi
  800605:	83 f8 25             	cmp    $0x25,%eax
  800608:	75 e5                	jne    8005ef <vprintfmt+0x11>
  80060a:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80060e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800615:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80061a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800621:	b9 00 00 00 00       	mov    $0x0,%ecx
  800626:	eb 26                	jmp    80064e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800628:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80062b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80062f:	eb 1d                	jmp    80064e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800631:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800634:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800638:	eb 14                	jmp    80064e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80063d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800644:	eb 08                	jmp    80064e <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800646:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800649:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064e:	0f b6 06             	movzbl (%esi),%eax
  800651:	8d 56 01             	lea    0x1(%esi),%edx
  800654:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800657:	8a 16                	mov    (%esi),%dl
  800659:	83 ea 23             	sub    $0x23,%edx
  80065c:	80 fa 55             	cmp    $0x55,%dl
  80065f:	0f 87 e1 02 00 00    	ja     800946 <vprintfmt+0x368>
  800665:	0f b6 d2             	movzbl %dl,%edx
  800668:	ff 24 95 e0 2b 80 00 	jmp    *0x802be0(,%edx,4)
  80066f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800672:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800677:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80067a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80067e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800681:	8d 50 d0             	lea    -0x30(%eax),%edx
  800684:	83 fa 09             	cmp    $0x9,%edx
  800687:	77 2a                	ja     8006b3 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800689:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80068a:	eb eb                	jmp    800677 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80068c:	8b 45 14             	mov    0x14(%ebp),%eax
  80068f:	8d 50 04             	lea    0x4(%eax),%edx
  800692:	89 55 14             	mov    %edx,0x14(%ebp)
  800695:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800697:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80069a:	eb 17                	jmp    8006b3 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  80069c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006a0:	78 98                	js     80063a <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a2:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006a5:	eb a7                	jmp    80064e <vprintfmt+0x70>
  8006a7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006aa:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8006b1:	eb 9b                	jmp    80064e <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8006b3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006b7:	79 95                	jns    80064e <vprintfmt+0x70>
  8006b9:	eb 8b                	jmp    800646 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006bb:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006bc:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8006bf:	eb 8d                	jmp    80064e <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8006c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c4:	8d 50 04             	lea    0x4(%eax),%edx
  8006c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ce:	8b 00                	mov    (%eax),%eax
  8006d0:	89 04 24             	mov    %eax,(%esp)
  8006d3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8006d9:	e9 23 ff ff ff       	jmp    800601 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006de:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e1:	8d 50 04             	lea    0x4(%eax),%edx
  8006e4:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e7:	8b 00                	mov    (%eax),%eax
  8006e9:	85 c0                	test   %eax,%eax
  8006eb:	79 02                	jns    8006ef <vprintfmt+0x111>
  8006ed:	f7 d8                	neg    %eax
  8006ef:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006f1:	83 f8 11             	cmp    $0x11,%eax
  8006f4:	7f 0b                	jg     800701 <vprintfmt+0x123>
  8006f6:	8b 04 85 40 2d 80 00 	mov    0x802d40(,%eax,4),%eax
  8006fd:	85 c0                	test   %eax,%eax
  8006ff:	75 23                	jne    800724 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800701:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800705:	c7 44 24 08 b3 2a 80 	movl   $0x802ab3,0x8(%esp)
  80070c:	00 
  80070d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800711:	8b 45 08             	mov    0x8(%ebp),%eax
  800714:	89 04 24             	mov    %eax,(%esp)
  800717:	e8 9a fe ff ff       	call   8005b6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80071c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80071f:	e9 dd fe ff ff       	jmp    800601 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800724:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800728:	c7 44 24 08 7d 2e 80 	movl   $0x802e7d,0x8(%esp)
  80072f:	00 
  800730:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800734:	8b 55 08             	mov    0x8(%ebp),%edx
  800737:	89 14 24             	mov    %edx,(%esp)
  80073a:	e8 77 fe ff ff       	call   8005b6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80073f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800742:	e9 ba fe ff ff       	jmp    800601 <vprintfmt+0x23>
  800747:	89 f9                	mov    %edi,%ecx
  800749:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80074c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80074f:	8b 45 14             	mov    0x14(%ebp),%eax
  800752:	8d 50 04             	lea    0x4(%eax),%edx
  800755:	89 55 14             	mov    %edx,0x14(%ebp)
  800758:	8b 30                	mov    (%eax),%esi
  80075a:	85 f6                	test   %esi,%esi
  80075c:	75 05                	jne    800763 <vprintfmt+0x185>
				p = "(null)";
  80075e:	be ac 2a 80 00       	mov    $0x802aac,%esi
			if (width > 0 && padc != '-')
  800763:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800767:	0f 8e 84 00 00 00    	jle    8007f1 <vprintfmt+0x213>
  80076d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800771:	74 7e                	je     8007f1 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800773:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800777:	89 34 24             	mov    %esi,(%esp)
  80077a:	e8 8b 02 00 00       	call   800a0a <strnlen>
  80077f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800782:	29 c2                	sub    %eax,%edx
  800784:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800787:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80078b:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80078e:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800791:	89 de                	mov    %ebx,%esi
  800793:	89 d3                	mov    %edx,%ebx
  800795:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800797:	eb 0b                	jmp    8007a4 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800799:	89 74 24 04          	mov    %esi,0x4(%esp)
  80079d:	89 3c 24             	mov    %edi,(%esp)
  8007a0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007a3:	4b                   	dec    %ebx
  8007a4:	85 db                	test   %ebx,%ebx
  8007a6:	7f f1                	jg     800799 <vprintfmt+0x1bb>
  8007a8:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8007ab:	89 f3                	mov    %esi,%ebx
  8007ad:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8007b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007b3:	85 c0                	test   %eax,%eax
  8007b5:	79 05                	jns    8007bc <vprintfmt+0x1de>
  8007b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007bc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007bf:	29 c2                	sub    %eax,%edx
  8007c1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8007c4:	eb 2b                	jmp    8007f1 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8007c6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007ca:	74 18                	je     8007e4 <vprintfmt+0x206>
  8007cc:	8d 50 e0             	lea    -0x20(%eax),%edx
  8007cf:	83 fa 5e             	cmp    $0x5e,%edx
  8007d2:	76 10                	jbe    8007e4 <vprintfmt+0x206>
					putch('?', putdat);
  8007d4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007d8:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8007df:	ff 55 08             	call   *0x8(%ebp)
  8007e2:	eb 0a                	jmp    8007ee <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8007e4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e8:	89 04 24             	mov    %eax,(%esp)
  8007eb:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007ee:	ff 4d e4             	decl   -0x1c(%ebp)
  8007f1:	0f be 06             	movsbl (%esi),%eax
  8007f4:	46                   	inc    %esi
  8007f5:	85 c0                	test   %eax,%eax
  8007f7:	74 21                	je     80081a <vprintfmt+0x23c>
  8007f9:	85 ff                	test   %edi,%edi
  8007fb:	78 c9                	js     8007c6 <vprintfmt+0x1e8>
  8007fd:	4f                   	dec    %edi
  8007fe:	79 c6                	jns    8007c6 <vprintfmt+0x1e8>
  800800:	8b 7d 08             	mov    0x8(%ebp),%edi
  800803:	89 de                	mov    %ebx,%esi
  800805:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800808:	eb 18                	jmp    800822 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80080a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80080e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800815:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800817:	4b                   	dec    %ebx
  800818:	eb 08                	jmp    800822 <vprintfmt+0x244>
  80081a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80081d:	89 de                	mov    %ebx,%esi
  80081f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800822:	85 db                	test   %ebx,%ebx
  800824:	7f e4                	jg     80080a <vprintfmt+0x22c>
  800826:	89 7d 08             	mov    %edi,0x8(%ebp)
  800829:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80082b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80082e:	e9 ce fd ff ff       	jmp    800601 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800833:	83 f9 01             	cmp    $0x1,%ecx
  800836:	7e 10                	jle    800848 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800838:	8b 45 14             	mov    0x14(%ebp),%eax
  80083b:	8d 50 08             	lea    0x8(%eax),%edx
  80083e:	89 55 14             	mov    %edx,0x14(%ebp)
  800841:	8b 30                	mov    (%eax),%esi
  800843:	8b 78 04             	mov    0x4(%eax),%edi
  800846:	eb 26                	jmp    80086e <vprintfmt+0x290>
	else if (lflag)
  800848:	85 c9                	test   %ecx,%ecx
  80084a:	74 12                	je     80085e <vprintfmt+0x280>
		return va_arg(*ap, long);
  80084c:	8b 45 14             	mov    0x14(%ebp),%eax
  80084f:	8d 50 04             	lea    0x4(%eax),%edx
  800852:	89 55 14             	mov    %edx,0x14(%ebp)
  800855:	8b 30                	mov    (%eax),%esi
  800857:	89 f7                	mov    %esi,%edi
  800859:	c1 ff 1f             	sar    $0x1f,%edi
  80085c:	eb 10                	jmp    80086e <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80085e:	8b 45 14             	mov    0x14(%ebp),%eax
  800861:	8d 50 04             	lea    0x4(%eax),%edx
  800864:	89 55 14             	mov    %edx,0x14(%ebp)
  800867:	8b 30                	mov    (%eax),%esi
  800869:	89 f7                	mov    %esi,%edi
  80086b:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80086e:	85 ff                	test   %edi,%edi
  800870:	78 0a                	js     80087c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800872:	b8 0a 00 00 00       	mov    $0xa,%eax
  800877:	e9 8c 00 00 00       	jmp    800908 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80087c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800880:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800887:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80088a:	f7 de                	neg    %esi
  80088c:	83 d7 00             	adc    $0x0,%edi
  80088f:	f7 df                	neg    %edi
			}
			base = 10;
  800891:	b8 0a 00 00 00       	mov    $0xa,%eax
  800896:	eb 70                	jmp    800908 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800898:	89 ca                	mov    %ecx,%edx
  80089a:	8d 45 14             	lea    0x14(%ebp),%eax
  80089d:	e8 c0 fc ff ff       	call   800562 <getuint>
  8008a2:	89 c6                	mov    %eax,%esi
  8008a4:	89 d7                	mov    %edx,%edi
			base = 10;
  8008a6:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8008ab:	eb 5b                	jmp    800908 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  8008ad:	89 ca                	mov    %ecx,%edx
  8008af:	8d 45 14             	lea    0x14(%ebp),%eax
  8008b2:	e8 ab fc ff ff       	call   800562 <getuint>
  8008b7:	89 c6                	mov    %eax,%esi
  8008b9:	89 d7                	mov    %edx,%edi
			base = 8;
  8008bb:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8008c0:	eb 46                	jmp    800908 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  8008c2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008c6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8008cd:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8008d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008d4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8008db:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008de:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e1:	8d 50 04             	lea    0x4(%eax),%edx
  8008e4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008e7:	8b 30                	mov    (%eax),%esi
  8008e9:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008ee:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008f3:	eb 13                	jmp    800908 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008f5:	89 ca                	mov    %ecx,%edx
  8008f7:	8d 45 14             	lea    0x14(%ebp),%eax
  8008fa:	e8 63 fc ff ff       	call   800562 <getuint>
  8008ff:	89 c6                	mov    %eax,%esi
  800901:	89 d7                	mov    %edx,%edi
			base = 16;
  800903:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800908:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  80090c:	89 54 24 10          	mov    %edx,0x10(%esp)
  800910:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800913:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800917:	89 44 24 08          	mov    %eax,0x8(%esp)
  80091b:	89 34 24             	mov    %esi,(%esp)
  80091e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800922:	89 da                	mov    %ebx,%edx
  800924:	8b 45 08             	mov    0x8(%ebp),%eax
  800927:	e8 6c fb ff ff       	call   800498 <printnum>
			break;
  80092c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80092f:	e9 cd fc ff ff       	jmp    800601 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800934:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800938:	89 04 24             	mov    %eax,(%esp)
  80093b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80093e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800941:	e9 bb fc ff ff       	jmp    800601 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800946:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80094a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800951:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800954:	eb 01                	jmp    800957 <vprintfmt+0x379>
  800956:	4e                   	dec    %esi
  800957:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80095b:	75 f9                	jne    800956 <vprintfmt+0x378>
  80095d:	e9 9f fc ff ff       	jmp    800601 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800962:	83 c4 4c             	add    $0x4c,%esp
  800965:	5b                   	pop    %ebx
  800966:	5e                   	pop    %esi
  800967:	5f                   	pop    %edi
  800968:	5d                   	pop    %ebp
  800969:	c3                   	ret    

0080096a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	83 ec 28             	sub    $0x28,%esp
  800970:	8b 45 08             	mov    0x8(%ebp),%eax
  800973:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800976:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800979:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80097d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800980:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800987:	85 c0                	test   %eax,%eax
  800989:	74 30                	je     8009bb <vsnprintf+0x51>
  80098b:	85 d2                	test   %edx,%edx
  80098d:	7e 33                	jle    8009c2 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80098f:	8b 45 14             	mov    0x14(%ebp),%eax
  800992:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800996:	8b 45 10             	mov    0x10(%ebp),%eax
  800999:	89 44 24 08          	mov    %eax,0x8(%esp)
  80099d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a4:	c7 04 24 9c 05 80 00 	movl   $0x80059c,(%esp)
  8009ab:	e8 2e fc ff ff       	call   8005de <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009b3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009b9:	eb 0c                	jmp    8009c7 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009bb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009c0:	eb 05                	jmp    8009c7 <vsnprintf+0x5d>
  8009c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009c7:	c9                   	leave  
  8009c8:	c3                   	ret    

008009c9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009c9:	55                   	push   %ebp
  8009ca:	89 e5                	mov    %esp,%ebp
  8009cc:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009cf:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009d6:	8b 45 10             	mov    0x10(%ebp),%eax
  8009d9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e7:	89 04 24             	mov    %eax,(%esp)
  8009ea:	e8 7b ff ff ff       	call   80096a <vsnprintf>
	va_end(ap);

	return rc;
}
  8009ef:	c9                   	leave  
  8009f0:	c3                   	ret    
  8009f1:	00 00                	add    %al,(%eax)
	...

008009f4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009f4:	55                   	push   %ebp
  8009f5:	89 e5                	mov    %esp,%ebp
  8009f7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ff:	eb 01                	jmp    800a02 <strlen+0xe>
		n++;
  800a01:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a02:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a06:	75 f9                	jne    800a01 <strlen+0xd>
		n++;
	return n;
}
  800a08:	5d                   	pop    %ebp
  800a09:	c3                   	ret    

00800a0a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a0a:	55                   	push   %ebp
  800a0b:	89 e5                	mov    %esp,%ebp
  800a0d:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800a10:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a13:	b8 00 00 00 00       	mov    $0x0,%eax
  800a18:	eb 01                	jmp    800a1b <strnlen+0x11>
		n++;
  800a1a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a1b:	39 d0                	cmp    %edx,%eax
  800a1d:	74 06                	je     800a25 <strnlen+0x1b>
  800a1f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a23:	75 f5                	jne    800a1a <strnlen+0x10>
		n++;
	return n;
}
  800a25:	5d                   	pop    %ebp
  800a26:	c3                   	ret    

00800a27 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a27:	55                   	push   %ebp
  800a28:	89 e5                	mov    %esp,%ebp
  800a2a:	53                   	push   %ebx
  800a2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a31:	ba 00 00 00 00       	mov    $0x0,%edx
  800a36:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800a39:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a3c:	42                   	inc    %edx
  800a3d:	84 c9                	test   %cl,%cl
  800a3f:	75 f5                	jne    800a36 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a41:	5b                   	pop    %ebx
  800a42:	5d                   	pop    %ebp
  800a43:	c3                   	ret    

00800a44 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a44:	55                   	push   %ebp
  800a45:	89 e5                	mov    %esp,%ebp
  800a47:	53                   	push   %ebx
  800a48:	83 ec 08             	sub    $0x8,%esp
  800a4b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a4e:	89 1c 24             	mov    %ebx,(%esp)
  800a51:	e8 9e ff ff ff       	call   8009f4 <strlen>
	strcpy(dst + len, src);
  800a56:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a59:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a5d:	01 d8                	add    %ebx,%eax
  800a5f:	89 04 24             	mov    %eax,(%esp)
  800a62:	e8 c0 ff ff ff       	call   800a27 <strcpy>
	return dst;
}
  800a67:	89 d8                	mov    %ebx,%eax
  800a69:	83 c4 08             	add    $0x8,%esp
  800a6c:	5b                   	pop    %ebx
  800a6d:	5d                   	pop    %ebp
  800a6e:	c3                   	ret    

00800a6f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a6f:	55                   	push   %ebp
  800a70:	89 e5                	mov    %esp,%ebp
  800a72:	56                   	push   %esi
  800a73:	53                   	push   %ebx
  800a74:	8b 45 08             	mov    0x8(%ebp),%eax
  800a77:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a7a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a7d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a82:	eb 0c                	jmp    800a90 <strncpy+0x21>
		*dst++ = *src;
  800a84:	8a 1a                	mov    (%edx),%bl
  800a86:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a89:	80 3a 01             	cmpb   $0x1,(%edx)
  800a8c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a8f:	41                   	inc    %ecx
  800a90:	39 f1                	cmp    %esi,%ecx
  800a92:	75 f0                	jne    800a84 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a94:	5b                   	pop    %ebx
  800a95:	5e                   	pop    %esi
  800a96:	5d                   	pop    %ebp
  800a97:	c3                   	ret    

00800a98 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a98:	55                   	push   %ebp
  800a99:	89 e5                	mov    %esp,%ebp
  800a9b:	56                   	push   %esi
  800a9c:	53                   	push   %ebx
  800a9d:	8b 75 08             	mov    0x8(%ebp),%esi
  800aa0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aa3:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800aa6:	85 d2                	test   %edx,%edx
  800aa8:	75 0a                	jne    800ab4 <strlcpy+0x1c>
  800aaa:	89 f0                	mov    %esi,%eax
  800aac:	eb 1a                	jmp    800ac8 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800aae:	88 18                	mov    %bl,(%eax)
  800ab0:	40                   	inc    %eax
  800ab1:	41                   	inc    %ecx
  800ab2:	eb 02                	jmp    800ab6 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ab4:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800ab6:	4a                   	dec    %edx
  800ab7:	74 0a                	je     800ac3 <strlcpy+0x2b>
  800ab9:	8a 19                	mov    (%ecx),%bl
  800abb:	84 db                	test   %bl,%bl
  800abd:	75 ef                	jne    800aae <strlcpy+0x16>
  800abf:	89 c2                	mov    %eax,%edx
  800ac1:	eb 02                	jmp    800ac5 <strlcpy+0x2d>
  800ac3:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800ac5:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800ac8:	29 f0                	sub    %esi,%eax
}
  800aca:	5b                   	pop    %ebx
  800acb:	5e                   	pop    %esi
  800acc:	5d                   	pop    %ebp
  800acd:	c3                   	ret    

00800ace <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ace:	55                   	push   %ebp
  800acf:	89 e5                	mov    %esp,%ebp
  800ad1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ad4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ad7:	eb 02                	jmp    800adb <strcmp+0xd>
		p++, q++;
  800ad9:	41                   	inc    %ecx
  800ada:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800adb:	8a 01                	mov    (%ecx),%al
  800add:	84 c0                	test   %al,%al
  800adf:	74 04                	je     800ae5 <strcmp+0x17>
  800ae1:	3a 02                	cmp    (%edx),%al
  800ae3:	74 f4                	je     800ad9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ae5:	0f b6 c0             	movzbl %al,%eax
  800ae8:	0f b6 12             	movzbl (%edx),%edx
  800aeb:	29 d0                	sub    %edx,%eax
}
  800aed:	5d                   	pop    %ebp
  800aee:	c3                   	ret    

00800aef <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800aef:	55                   	push   %ebp
  800af0:	89 e5                	mov    %esp,%ebp
  800af2:	53                   	push   %ebx
  800af3:	8b 45 08             	mov    0x8(%ebp),%eax
  800af6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800af9:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800afc:	eb 03                	jmp    800b01 <strncmp+0x12>
		n--, p++, q++;
  800afe:	4a                   	dec    %edx
  800aff:	40                   	inc    %eax
  800b00:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b01:	85 d2                	test   %edx,%edx
  800b03:	74 14                	je     800b19 <strncmp+0x2a>
  800b05:	8a 18                	mov    (%eax),%bl
  800b07:	84 db                	test   %bl,%bl
  800b09:	74 04                	je     800b0f <strncmp+0x20>
  800b0b:	3a 19                	cmp    (%ecx),%bl
  800b0d:	74 ef                	je     800afe <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b0f:	0f b6 00             	movzbl (%eax),%eax
  800b12:	0f b6 11             	movzbl (%ecx),%edx
  800b15:	29 d0                	sub    %edx,%eax
  800b17:	eb 05                	jmp    800b1e <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b19:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b1e:	5b                   	pop    %ebx
  800b1f:	5d                   	pop    %ebp
  800b20:	c3                   	ret    

00800b21 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	8b 45 08             	mov    0x8(%ebp),%eax
  800b27:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b2a:	eb 05                	jmp    800b31 <strchr+0x10>
		if (*s == c)
  800b2c:	38 ca                	cmp    %cl,%dl
  800b2e:	74 0c                	je     800b3c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b30:	40                   	inc    %eax
  800b31:	8a 10                	mov    (%eax),%dl
  800b33:	84 d2                	test   %dl,%dl
  800b35:	75 f5                	jne    800b2c <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800b37:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b3c:	5d                   	pop    %ebp
  800b3d:	c3                   	ret    

00800b3e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b3e:	55                   	push   %ebp
  800b3f:	89 e5                	mov    %esp,%ebp
  800b41:	8b 45 08             	mov    0x8(%ebp),%eax
  800b44:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b47:	eb 05                	jmp    800b4e <strfind+0x10>
		if (*s == c)
  800b49:	38 ca                	cmp    %cl,%dl
  800b4b:	74 07                	je     800b54 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b4d:	40                   	inc    %eax
  800b4e:	8a 10                	mov    (%eax),%dl
  800b50:	84 d2                	test   %dl,%dl
  800b52:	75 f5                	jne    800b49 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800b54:	5d                   	pop    %ebp
  800b55:	c3                   	ret    

00800b56 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b56:	55                   	push   %ebp
  800b57:	89 e5                	mov    %esp,%ebp
  800b59:	57                   	push   %edi
  800b5a:	56                   	push   %esi
  800b5b:	53                   	push   %ebx
  800b5c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b62:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b65:	85 c9                	test   %ecx,%ecx
  800b67:	74 30                	je     800b99 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b69:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b6f:	75 25                	jne    800b96 <memset+0x40>
  800b71:	f6 c1 03             	test   $0x3,%cl
  800b74:	75 20                	jne    800b96 <memset+0x40>
		c &= 0xFF;
  800b76:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b79:	89 d3                	mov    %edx,%ebx
  800b7b:	c1 e3 08             	shl    $0x8,%ebx
  800b7e:	89 d6                	mov    %edx,%esi
  800b80:	c1 e6 18             	shl    $0x18,%esi
  800b83:	89 d0                	mov    %edx,%eax
  800b85:	c1 e0 10             	shl    $0x10,%eax
  800b88:	09 f0                	or     %esi,%eax
  800b8a:	09 d0                	or     %edx,%eax
  800b8c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b8e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b91:	fc                   	cld    
  800b92:	f3 ab                	rep stos %eax,%es:(%edi)
  800b94:	eb 03                	jmp    800b99 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b96:	fc                   	cld    
  800b97:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b99:	89 f8                	mov    %edi,%eax
  800b9b:	5b                   	pop    %ebx
  800b9c:	5e                   	pop    %esi
  800b9d:	5f                   	pop    %edi
  800b9e:	5d                   	pop    %ebp
  800b9f:	c3                   	ret    

00800ba0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ba0:	55                   	push   %ebp
  800ba1:	89 e5                	mov    %esp,%ebp
  800ba3:	57                   	push   %edi
  800ba4:	56                   	push   %esi
  800ba5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bab:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bae:	39 c6                	cmp    %eax,%esi
  800bb0:	73 34                	jae    800be6 <memmove+0x46>
  800bb2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bb5:	39 d0                	cmp    %edx,%eax
  800bb7:	73 2d                	jae    800be6 <memmove+0x46>
		s += n;
		d += n;
  800bb9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bbc:	f6 c2 03             	test   $0x3,%dl
  800bbf:	75 1b                	jne    800bdc <memmove+0x3c>
  800bc1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bc7:	75 13                	jne    800bdc <memmove+0x3c>
  800bc9:	f6 c1 03             	test   $0x3,%cl
  800bcc:	75 0e                	jne    800bdc <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bce:	83 ef 04             	sub    $0x4,%edi
  800bd1:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bd4:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800bd7:	fd                   	std    
  800bd8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bda:	eb 07                	jmp    800be3 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bdc:	4f                   	dec    %edi
  800bdd:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800be0:	fd                   	std    
  800be1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800be3:	fc                   	cld    
  800be4:	eb 20                	jmp    800c06 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800be6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bec:	75 13                	jne    800c01 <memmove+0x61>
  800bee:	a8 03                	test   $0x3,%al
  800bf0:	75 0f                	jne    800c01 <memmove+0x61>
  800bf2:	f6 c1 03             	test   $0x3,%cl
  800bf5:	75 0a                	jne    800c01 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800bf7:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800bfa:	89 c7                	mov    %eax,%edi
  800bfc:	fc                   	cld    
  800bfd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bff:	eb 05                	jmp    800c06 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c01:	89 c7                	mov    %eax,%edi
  800c03:	fc                   	cld    
  800c04:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c06:	5e                   	pop    %esi
  800c07:	5f                   	pop    %edi
  800c08:	5d                   	pop    %ebp
  800c09:	c3                   	ret    

00800c0a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c10:	8b 45 10             	mov    0x10(%ebp),%eax
  800c13:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c17:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c1a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c21:	89 04 24             	mov    %eax,(%esp)
  800c24:	e8 77 ff ff ff       	call   800ba0 <memmove>
}
  800c29:	c9                   	leave  
  800c2a:	c3                   	ret    

00800c2b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	57                   	push   %edi
  800c2f:	56                   	push   %esi
  800c30:	53                   	push   %ebx
  800c31:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c34:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c37:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c3a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c3f:	eb 16                	jmp    800c57 <memcmp+0x2c>
		if (*s1 != *s2)
  800c41:	8a 04 17             	mov    (%edi,%edx,1),%al
  800c44:	42                   	inc    %edx
  800c45:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800c49:	38 c8                	cmp    %cl,%al
  800c4b:	74 0a                	je     800c57 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800c4d:	0f b6 c0             	movzbl %al,%eax
  800c50:	0f b6 c9             	movzbl %cl,%ecx
  800c53:	29 c8                	sub    %ecx,%eax
  800c55:	eb 09                	jmp    800c60 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c57:	39 da                	cmp    %ebx,%edx
  800c59:	75 e6                	jne    800c41 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c5b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c60:	5b                   	pop    %ebx
  800c61:	5e                   	pop    %esi
  800c62:	5f                   	pop    %edi
  800c63:	5d                   	pop    %ebp
  800c64:	c3                   	ret    

00800c65 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c65:	55                   	push   %ebp
  800c66:	89 e5                	mov    %esp,%ebp
  800c68:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c6e:	89 c2                	mov    %eax,%edx
  800c70:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c73:	eb 05                	jmp    800c7a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c75:	38 08                	cmp    %cl,(%eax)
  800c77:	74 05                	je     800c7e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c79:	40                   	inc    %eax
  800c7a:	39 d0                	cmp    %edx,%eax
  800c7c:	72 f7                	jb     800c75 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c7e:	5d                   	pop    %ebp
  800c7f:	c3                   	ret    

00800c80 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c80:	55                   	push   %ebp
  800c81:	89 e5                	mov    %esp,%ebp
  800c83:	57                   	push   %edi
  800c84:	56                   	push   %esi
  800c85:	53                   	push   %ebx
  800c86:	8b 55 08             	mov    0x8(%ebp),%edx
  800c89:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c8c:	eb 01                	jmp    800c8f <strtol+0xf>
		s++;
  800c8e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c8f:	8a 02                	mov    (%edx),%al
  800c91:	3c 20                	cmp    $0x20,%al
  800c93:	74 f9                	je     800c8e <strtol+0xe>
  800c95:	3c 09                	cmp    $0x9,%al
  800c97:	74 f5                	je     800c8e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c99:	3c 2b                	cmp    $0x2b,%al
  800c9b:	75 08                	jne    800ca5 <strtol+0x25>
		s++;
  800c9d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c9e:	bf 00 00 00 00       	mov    $0x0,%edi
  800ca3:	eb 13                	jmp    800cb8 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ca5:	3c 2d                	cmp    $0x2d,%al
  800ca7:	75 0a                	jne    800cb3 <strtol+0x33>
		s++, neg = 1;
  800ca9:	8d 52 01             	lea    0x1(%edx),%edx
  800cac:	bf 01 00 00 00       	mov    $0x1,%edi
  800cb1:	eb 05                	jmp    800cb8 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cb3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cb8:	85 db                	test   %ebx,%ebx
  800cba:	74 05                	je     800cc1 <strtol+0x41>
  800cbc:	83 fb 10             	cmp    $0x10,%ebx
  800cbf:	75 28                	jne    800ce9 <strtol+0x69>
  800cc1:	8a 02                	mov    (%edx),%al
  800cc3:	3c 30                	cmp    $0x30,%al
  800cc5:	75 10                	jne    800cd7 <strtol+0x57>
  800cc7:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ccb:	75 0a                	jne    800cd7 <strtol+0x57>
		s += 2, base = 16;
  800ccd:	83 c2 02             	add    $0x2,%edx
  800cd0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cd5:	eb 12                	jmp    800ce9 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800cd7:	85 db                	test   %ebx,%ebx
  800cd9:	75 0e                	jne    800ce9 <strtol+0x69>
  800cdb:	3c 30                	cmp    $0x30,%al
  800cdd:	75 05                	jne    800ce4 <strtol+0x64>
		s++, base = 8;
  800cdf:	42                   	inc    %edx
  800ce0:	b3 08                	mov    $0x8,%bl
  800ce2:	eb 05                	jmp    800ce9 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ce4:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ce9:	b8 00 00 00 00       	mov    $0x0,%eax
  800cee:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cf0:	8a 0a                	mov    (%edx),%cl
  800cf2:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800cf5:	80 fb 09             	cmp    $0x9,%bl
  800cf8:	77 08                	ja     800d02 <strtol+0x82>
			dig = *s - '0';
  800cfa:	0f be c9             	movsbl %cl,%ecx
  800cfd:	83 e9 30             	sub    $0x30,%ecx
  800d00:	eb 1e                	jmp    800d20 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800d02:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d05:	80 fb 19             	cmp    $0x19,%bl
  800d08:	77 08                	ja     800d12 <strtol+0x92>
			dig = *s - 'a' + 10;
  800d0a:	0f be c9             	movsbl %cl,%ecx
  800d0d:	83 e9 57             	sub    $0x57,%ecx
  800d10:	eb 0e                	jmp    800d20 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800d12:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d15:	80 fb 19             	cmp    $0x19,%bl
  800d18:	77 12                	ja     800d2c <strtol+0xac>
			dig = *s - 'A' + 10;
  800d1a:	0f be c9             	movsbl %cl,%ecx
  800d1d:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d20:	39 f1                	cmp    %esi,%ecx
  800d22:	7d 0c                	jge    800d30 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800d24:	42                   	inc    %edx
  800d25:	0f af c6             	imul   %esi,%eax
  800d28:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d2a:	eb c4                	jmp    800cf0 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d2c:	89 c1                	mov    %eax,%ecx
  800d2e:	eb 02                	jmp    800d32 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d30:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d32:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d36:	74 05                	je     800d3d <strtol+0xbd>
		*endptr = (char *) s;
  800d38:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d3b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d3d:	85 ff                	test   %edi,%edi
  800d3f:	74 04                	je     800d45 <strtol+0xc5>
  800d41:	89 c8                	mov    %ecx,%eax
  800d43:	f7 d8                	neg    %eax
}
  800d45:	5b                   	pop    %ebx
  800d46:	5e                   	pop    %esi
  800d47:	5f                   	pop    %edi
  800d48:	5d                   	pop    %ebp
  800d49:	c3                   	ret    
	...

00800d4c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d4c:	55                   	push   %ebp
  800d4d:	89 e5                	mov    %esp,%ebp
  800d4f:	57                   	push   %edi
  800d50:	56                   	push   %esi
  800d51:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d52:	b8 00 00 00 00       	mov    $0x0,%eax
  800d57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5d:	89 c3                	mov    %eax,%ebx
  800d5f:	89 c7                	mov    %eax,%edi
  800d61:	89 c6                	mov    %eax,%esi
  800d63:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d65:	5b                   	pop    %ebx
  800d66:	5e                   	pop    %esi
  800d67:	5f                   	pop    %edi
  800d68:	5d                   	pop    %ebp
  800d69:	c3                   	ret    

00800d6a <sys_cgetc>:

int
sys_cgetc(void)
{
  800d6a:	55                   	push   %ebp
  800d6b:	89 e5                	mov    %esp,%ebp
  800d6d:	57                   	push   %edi
  800d6e:	56                   	push   %esi
  800d6f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d70:	ba 00 00 00 00       	mov    $0x0,%edx
  800d75:	b8 01 00 00 00       	mov    $0x1,%eax
  800d7a:	89 d1                	mov    %edx,%ecx
  800d7c:	89 d3                	mov    %edx,%ebx
  800d7e:	89 d7                	mov    %edx,%edi
  800d80:	89 d6                	mov    %edx,%esi
  800d82:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d84:	5b                   	pop    %ebx
  800d85:	5e                   	pop    %esi
  800d86:	5f                   	pop    %edi
  800d87:	5d                   	pop    %ebp
  800d88:	c3                   	ret    

00800d89 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d89:	55                   	push   %ebp
  800d8a:	89 e5                	mov    %esp,%ebp
  800d8c:	57                   	push   %edi
  800d8d:	56                   	push   %esi
  800d8e:	53                   	push   %ebx
  800d8f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d92:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d97:	b8 03 00 00 00       	mov    $0x3,%eax
  800d9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9f:	89 cb                	mov    %ecx,%ebx
  800da1:	89 cf                	mov    %ecx,%edi
  800da3:	89 ce                	mov    %ecx,%esi
  800da5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800da7:	85 c0                	test   %eax,%eax
  800da9:	7e 28                	jle    800dd3 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dab:	89 44 24 10          	mov    %eax,0x10(%esp)
  800daf:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800db6:	00 
  800db7:	c7 44 24 08 a7 2d 80 	movl   $0x802da7,0x8(%esp)
  800dbe:	00 
  800dbf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dc6:	00 
  800dc7:	c7 04 24 c4 2d 80 00 	movl   $0x802dc4,(%esp)
  800dce:	e8 b1 f5 ff ff       	call   800384 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800dd3:	83 c4 2c             	add    $0x2c,%esp
  800dd6:	5b                   	pop    %ebx
  800dd7:	5e                   	pop    %esi
  800dd8:	5f                   	pop    %edi
  800dd9:	5d                   	pop    %ebp
  800dda:	c3                   	ret    

00800ddb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ddb:	55                   	push   %ebp
  800ddc:	89 e5                	mov    %esp,%ebp
  800dde:	57                   	push   %edi
  800ddf:	56                   	push   %esi
  800de0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de1:	ba 00 00 00 00       	mov    $0x0,%edx
  800de6:	b8 02 00 00 00       	mov    $0x2,%eax
  800deb:	89 d1                	mov    %edx,%ecx
  800ded:	89 d3                	mov    %edx,%ebx
  800def:	89 d7                	mov    %edx,%edi
  800df1:	89 d6                	mov    %edx,%esi
  800df3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800df5:	5b                   	pop    %ebx
  800df6:	5e                   	pop    %esi
  800df7:	5f                   	pop    %edi
  800df8:	5d                   	pop    %ebp
  800df9:	c3                   	ret    

00800dfa <sys_yield>:

void
sys_yield(void)
{
  800dfa:	55                   	push   %ebp
  800dfb:	89 e5                	mov    %esp,%ebp
  800dfd:	57                   	push   %edi
  800dfe:	56                   	push   %esi
  800dff:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e00:	ba 00 00 00 00       	mov    $0x0,%edx
  800e05:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e0a:	89 d1                	mov    %edx,%ecx
  800e0c:	89 d3                	mov    %edx,%ebx
  800e0e:	89 d7                	mov    %edx,%edi
  800e10:	89 d6                	mov    %edx,%esi
  800e12:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e14:	5b                   	pop    %ebx
  800e15:	5e                   	pop    %esi
  800e16:	5f                   	pop    %edi
  800e17:	5d                   	pop    %ebp
  800e18:	c3                   	ret    

00800e19 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e19:	55                   	push   %ebp
  800e1a:	89 e5                	mov    %esp,%ebp
  800e1c:	57                   	push   %edi
  800e1d:	56                   	push   %esi
  800e1e:	53                   	push   %ebx
  800e1f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e22:	be 00 00 00 00       	mov    $0x0,%esi
  800e27:	b8 04 00 00 00       	mov    $0x4,%eax
  800e2c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e32:	8b 55 08             	mov    0x8(%ebp),%edx
  800e35:	89 f7                	mov    %esi,%edi
  800e37:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e39:	85 c0                	test   %eax,%eax
  800e3b:	7e 28                	jle    800e65 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e3d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e41:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800e48:	00 
  800e49:	c7 44 24 08 a7 2d 80 	movl   $0x802da7,0x8(%esp)
  800e50:	00 
  800e51:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e58:	00 
  800e59:	c7 04 24 c4 2d 80 00 	movl   $0x802dc4,(%esp)
  800e60:	e8 1f f5 ff ff       	call   800384 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e65:	83 c4 2c             	add    $0x2c,%esp
  800e68:	5b                   	pop    %ebx
  800e69:	5e                   	pop    %esi
  800e6a:	5f                   	pop    %edi
  800e6b:	5d                   	pop    %ebp
  800e6c:	c3                   	ret    

00800e6d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e6d:	55                   	push   %ebp
  800e6e:	89 e5                	mov    %esp,%ebp
  800e70:	57                   	push   %edi
  800e71:	56                   	push   %esi
  800e72:	53                   	push   %ebx
  800e73:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e76:	b8 05 00 00 00       	mov    $0x5,%eax
  800e7b:	8b 75 18             	mov    0x18(%ebp),%esi
  800e7e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e81:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e87:	8b 55 08             	mov    0x8(%ebp),%edx
  800e8a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e8c:	85 c0                	test   %eax,%eax
  800e8e:	7e 28                	jle    800eb8 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e90:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e94:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e9b:	00 
  800e9c:	c7 44 24 08 a7 2d 80 	movl   $0x802da7,0x8(%esp)
  800ea3:	00 
  800ea4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eab:	00 
  800eac:	c7 04 24 c4 2d 80 00 	movl   $0x802dc4,(%esp)
  800eb3:	e8 cc f4 ff ff       	call   800384 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800eb8:	83 c4 2c             	add    $0x2c,%esp
  800ebb:	5b                   	pop    %ebx
  800ebc:	5e                   	pop    %esi
  800ebd:	5f                   	pop    %edi
  800ebe:	5d                   	pop    %ebp
  800ebf:	c3                   	ret    

00800ec0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ec0:	55                   	push   %ebp
  800ec1:	89 e5                	mov    %esp,%ebp
  800ec3:	57                   	push   %edi
  800ec4:	56                   	push   %esi
  800ec5:	53                   	push   %ebx
  800ec6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ec9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ece:	b8 06 00 00 00       	mov    $0x6,%eax
  800ed3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed9:	89 df                	mov    %ebx,%edi
  800edb:	89 de                	mov    %ebx,%esi
  800edd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800edf:	85 c0                	test   %eax,%eax
  800ee1:	7e 28                	jle    800f0b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ee7:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800eee:	00 
  800eef:	c7 44 24 08 a7 2d 80 	movl   $0x802da7,0x8(%esp)
  800ef6:	00 
  800ef7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800efe:	00 
  800eff:	c7 04 24 c4 2d 80 00 	movl   $0x802dc4,(%esp)
  800f06:	e8 79 f4 ff ff       	call   800384 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f0b:	83 c4 2c             	add    $0x2c,%esp
  800f0e:	5b                   	pop    %ebx
  800f0f:	5e                   	pop    %esi
  800f10:	5f                   	pop    %edi
  800f11:	5d                   	pop    %ebp
  800f12:	c3                   	ret    

00800f13 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f13:	55                   	push   %ebp
  800f14:	89 e5                	mov    %esp,%ebp
  800f16:	57                   	push   %edi
  800f17:	56                   	push   %esi
  800f18:	53                   	push   %ebx
  800f19:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f1c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f21:	b8 08 00 00 00       	mov    $0x8,%eax
  800f26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f29:	8b 55 08             	mov    0x8(%ebp),%edx
  800f2c:	89 df                	mov    %ebx,%edi
  800f2e:	89 de                	mov    %ebx,%esi
  800f30:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f32:	85 c0                	test   %eax,%eax
  800f34:	7e 28                	jle    800f5e <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f36:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f3a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f41:	00 
  800f42:	c7 44 24 08 a7 2d 80 	movl   $0x802da7,0x8(%esp)
  800f49:	00 
  800f4a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f51:	00 
  800f52:	c7 04 24 c4 2d 80 00 	movl   $0x802dc4,(%esp)
  800f59:	e8 26 f4 ff ff       	call   800384 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f5e:	83 c4 2c             	add    $0x2c,%esp
  800f61:	5b                   	pop    %ebx
  800f62:	5e                   	pop    %esi
  800f63:	5f                   	pop    %edi
  800f64:	5d                   	pop    %ebp
  800f65:	c3                   	ret    

00800f66 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f66:	55                   	push   %ebp
  800f67:	89 e5                	mov    %esp,%ebp
  800f69:	57                   	push   %edi
  800f6a:	56                   	push   %esi
  800f6b:	53                   	push   %ebx
  800f6c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f6f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f74:	b8 09 00 00 00       	mov    $0x9,%eax
  800f79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f7f:	89 df                	mov    %ebx,%edi
  800f81:	89 de                	mov    %ebx,%esi
  800f83:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f85:	85 c0                	test   %eax,%eax
  800f87:	7e 28                	jle    800fb1 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f89:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f8d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f94:	00 
  800f95:	c7 44 24 08 a7 2d 80 	movl   $0x802da7,0x8(%esp)
  800f9c:	00 
  800f9d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fa4:	00 
  800fa5:	c7 04 24 c4 2d 80 00 	movl   $0x802dc4,(%esp)
  800fac:	e8 d3 f3 ff ff       	call   800384 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800fb1:	83 c4 2c             	add    $0x2c,%esp
  800fb4:	5b                   	pop    %ebx
  800fb5:	5e                   	pop    %esi
  800fb6:	5f                   	pop    %edi
  800fb7:	5d                   	pop    %ebp
  800fb8:	c3                   	ret    

00800fb9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800fb9:	55                   	push   %ebp
  800fba:	89 e5                	mov    %esp,%ebp
  800fbc:	57                   	push   %edi
  800fbd:	56                   	push   %esi
  800fbe:	53                   	push   %ebx
  800fbf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fc2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fc7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fcc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fcf:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd2:	89 df                	mov    %ebx,%edi
  800fd4:	89 de                	mov    %ebx,%esi
  800fd6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fd8:	85 c0                	test   %eax,%eax
  800fda:	7e 28                	jle    801004 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fdc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fe0:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800fe7:	00 
  800fe8:	c7 44 24 08 a7 2d 80 	movl   $0x802da7,0x8(%esp)
  800fef:	00 
  800ff0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ff7:	00 
  800ff8:	c7 04 24 c4 2d 80 00 	movl   $0x802dc4,(%esp)
  800fff:	e8 80 f3 ff ff       	call   800384 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801004:	83 c4 2c             	add    $0x2c,%esp
  801007:	5b                   	pop    %ebx
  801008:	5e                   	pop    %esi
  801009:	5f                   	pop    %edi
  80100a:	5d                   	pop    %ebp
  80100b:	c3                   	ret    

0080100c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80100c:	55                   	push   %ebp
  80100d:	89 e5                	mov    %esp,%ebp
  80100f:	57                   	push   %edi
  801010:	56                   	push   %esi
  801011:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801012:	be 00 00 00 00       	mov    $0x0,%esi
  801017:	b8 0c 00 00 00       	mov    $0xc,%eax
  80101c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80101f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801022:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801025:	8b 55 08             	mov    0x8(%ebp),%edx
  801028:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80102a:	5b                   	pop    %ebx
  80102b:	5e                   	pop    %esi
  80102c:	5f                   	pop    %edi
  80102d:	5d                   	pop    %ebp
  80102e:	c3                   	ret    

0080102f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80102f:	55                   	push   %ebp
  801030:	89 e5                	mov    %esp,%ebp
  801032:	57                   	push   %edi
  801033:	56                   	push   %esi
  801034:	53                   	push   %ebx
  801035:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801038:	b9 00 00 00 00       	mov    $0x0,%ecx
  80103d:	b8 0d 00 00 00       	mov    $0xd,%eax
  801042:	8b 55 08             	mov    0x8(%ebp),%edx
  801045:	89 cb                	mov    %ecx,%ebx
  801047:	89 cf                	mov    %ecx,%edi
  801049:	89 ce                	mov    %ecx,%esi
  80104b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80104d:	85 c0                	test   %eax,%eax
  80104f:	7e 28                	jle    801079 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801051:	89 44 24 10          	mov    %eax,0x10(%esp)
  801055:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  80105c:	00 
  80105d:	c7 44 24 08 a7 2d 80 	movl   $0x802da7,0x8(%esp)
  801064:	00 
  801065:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80106c:	00 
  80106d:	c7 04 24 c4 2d 80 00 	movl   $0x802dc4,(%esp)
  801074:	e8 0b f3 ff ff       	call   800384 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801079:	83 c4 2c             	add    $0x2c,%esp
  80107c:	5b                   	pop    %ebx
  80107d:	5e                   	pop    %esi
  80107e:	5f                   	pop    %edi
  80107f:	5d                   	pop    %ebp
  801080:	c3                   	ret    

00801081 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  801081:	55                   	push   %ebp
  801082:	89 e5                	mov    %esp,%ebp
  801084:	57                   	push   %edi
  801085:	56                   	push   %esi
  801086:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801087:	ba 00 00 00 00       	mov    $0x0,%edx
  80108c:	b8 0e 00 00 00       	mov    $0xe,%eax
  801091:	89 d1                	mov    %edx,%ecx
  801093:	89 d3                	mov    %edx,%ebx
  801095:	89 d7                	mov    %edx,%edi
  801097:	89 d6                	mov    %edx,%esi
  801099:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80109b:	5b                   	pop    %ebx
  80109c:	5e                   	pop    %esi
  80109d:	5f                   	pop    %edi
  80109e:	5d                   	pop    %ebp
  80109f:	c3                   	ret    

008010a0 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char* pck, size_t length){
  8010a0:	55                   	push   %ebp
  8010a1:	89 e5                	mov    %esp,%ebp
  8010a3:	57                   	push   %edi
  8010a4:	56                   	push   %esi
  8010a5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010a6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010ab:	b8 10 00 00 00       	mov    $0x10,%eax
  8010b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8010b6:	89 df                	mov    %ebx,%edi
  8010b8:	89 de                	mov    %ebx,%esi
  8010ba:	cd 30                	int    $0x30
}

int 
sys_e1000_transmit(char* pck, size_t length){
	return syscall(SYS_e1000_transmit, 0, (uint32_t)pck, length, 0, 0, 0);
}
  8010bc:	5b                   	pop    %ebx
  8010bd:	5e                   	pop    %esi
  8010be:	5f                   	pop    %edi
  8010bf:	5d                   	pop    %ebp
  8010c0:	c3                   	ret    

008010c1 <sys_e1000_receive>:

int 
sys_e1000_receive(char* pck, size_t* length){
  8010c1:	55                   	push   %ebp
  8010c2:	89 e5                	mov    %esp,%ebp
  8010c4:	57                   	push   %edi
  8010c5:	56                   	push   %esi
  8010c6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010c7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010cc:	b8 0f 00 00 00       	mov    $0xf,%eax
  8010d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8010d7:	89 df                	mov    %ebx,%edi
  8010d9:	89 de                	mov    %ebx,%esi
  8010db:	cd 30                	int    $0x30
}

int 
sys_e1000_receive(char* pck, size_t* length){
	return syscall(SYS_e1000_receive, 0, (uint32_t)pck, (uint32_t)length, 0, 0, 0);
}
  8010dd:	5b                   	pop    %ebx
  8010de:	5e                   	pop    %esi
  8010df:	5f                   	pop    %edi
  8010e0:	5d                   	pop    %ebp
  8010e1:	c3                   	ret    

008010e2 <sys_e1000_get_mac>:

int 
sys_e1000_get_mac(uint8_t* mac_addr){
  8010e2:	55                   	push   %ebp
  8010e3:	89 e5                	mov    %esp,%ebp
  8010e5:	57                   	push   %edi
  8010e6:	56                   	push   %esi
  8010e7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010ed:	b8 11 00 00 00       	mov    $0x11,%eax
  8010f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f5:	89 cb                	mov    %ecx,%ebx
  8010f7:	89 cf                	mov    %ecx,%edi
  8010f9:	89 ce                	mov    %ecx,%esi
  8010fb:	cd 30                	int    $0x30
}

int 
sys_e1000_get_mac(uint8_t* mac_addr){
	return syscall(SYS_e1000_get_mac, 0, (uint32_t)mac_addr, 0, 0, 0, 0);
}
  8010fd:	5b                   	pop    %ebx
  8010fe:	5e                   	pop    %esi
  8010ff:	5f                   	pop    %edi
  801100:	5d                   	pop    %ebp
  801101:	c3                   	ret    
	...

00801104 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801104:	55                   	push   %ebp
  801105:	89 e5                	mov    %esp,%ebp
  801107:	8b 55 08             	mov    0x8(%ebp),%edx
  80110a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80110d:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801110:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801112:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801115:	83 3a 01             	cmpl   $0x1,(%edx)
  801118:	7e 0b                	jle    801125 <argstart+0x21>
  80111a:	85 c9                	test   %ecx,%ecx
  80111c:	75 0e                	jne    80112c <argstart+0x28>
  80111e:	ba 00 00 00 00       	mov    $0x0,%edx
  801123:	eb 0c                	jmp    801131 <argstart+0x2d>
  801125:	ba 00 00 00 00       	mov    $0x0,%edx
  80112a:	eb 05                	jmp    801131 <argstart+0x2d>
  80112c:	ba 48 2a 80 00       	mov    $0x802a48,%edx
  801131:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801134:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  80113b:	5d                   	pop    %ebp
  80113c:	c3                   	ret    

0080113d <argnext>:

int
argnext(struct Argstate *args)
{
  80113d:	55                   	push   %ebp
  80113e:	89 e5                	mov    %esp,%ebp
  801140:	53                   	push   %ebx
  801141:	83 ec 14             	sub    $0x14,%esp
  801144:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801147:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  80114e:	8b 43 08             	mov    0x8(%ebx),%eax
  801151:	85 c0                	test   %eax,%eax
  801153:	74 6c                	je     8011c1 <argnext+0x84>
		return -1;

	if (!*args->curarg) {
  801155:	80 38 00             	cmpb   $0x0,(%eax)
  801158:	75 4d                	jne    8011a7 <argnext+0x6a>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  80115a:	8b 0b                	mov    (%ebx),%ecx
  80115c:	83 39 01             	cmpl   $0x1,(%ecx)
  80115f:	74 52                	je     8011b3 <argnext+0x76>
		    || args->argv[1][0] != '-'
  801161:	8b 53 04             	mov    0x4(%ebx),%edx
  801164:	8b 42 04             	mov    0x4(%edx),%eax
  801167:	80 38 2d             	cmpb   $0x2d,(%eax)
  80116a:	75 47                	jne    8011b3 <argnext+0x76>
		    || args->argv[1][1] == '\0')
  80116c:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801170:	74 41                	je     8011b3 <argnext+0x76>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801172:	40                   	inc    %eax
  801173:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801176:	8b 01                	mov    (%ecx),%eax
  801178:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  80117f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801183:	8d 42 08             	lea    0x8(%edx),%eax
  801186:	89 44 24 04          	mov    %eax,0x4(%esp)
  80118a:	83 c2 04             	add    $0x4,%edx
  80118d:	89 14 24             	mov    %edx,(%esp)
  801190:	e8 0b fa ff ff       	call   800ba0 <memmove>
		(*args->argc)--;
  801195:	8b 03                	mov    (%ebx),%eax
  801197:	ff 08                	decl   (%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801199:	8b 43 08             	mov    0x8(%ebx),%eax
  80119c:	80 38 2d             	cmpb   $0x2d,(%eax)
  80119f:	75 06                	jne    8011a7 <argnext+0x6a>
  8011a1:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  8011a5:	74 0c                	je     8011b3 <argnext+0x76>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  8011a7:	8b 53 08             	mov    0x8(%ebx),%edx
  8011aa:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  8011ad:	42                   	inc    %edx
  8011ae:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  8011b1:	eb 13                	jmp    8011c6 <argnext+0x89>

    endofargs:
	args->curarg = 0;
  8011b3:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  8011ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8011bf:	eb 05                	jmp    8011c6 <argnext+0x89>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  8011c1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  8011c6:	83 c4 14             	add    $0x14,%esp
  8011c9:	5b                   	pop    %ebx
  8011ca:	5d                   	pop    %ebp
  8011cb:	c3                   	ret    

008011cc <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  8011cc:	55                   	push   %ebp
  8011cd:	89 e5                	mov    %esp,%ebp
  8011cf:	53                   	push   %ebx
  8011d0:	83 ec 14             	sub    $0x14,%esp
  8011d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  8011d6:	8b 43 08             	mov    0x8(%ebx),%eax
  8011d9:	85 c0                	test   %eax,%eax
  8011db:	74 59                	je     801236 <argnextvalue+0x6a>
		return 0;
	if (*args->curarg) {
  8011dd:	80 38 00             	cmpb   $0x0,(%eax)
  8011e0:	74 0c                	je     8011ee <argnextvalue+0x22>
		args->argvalue = args->curarg;
  8011e2:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  8011e5:	c7 43 08 48 2a 80 00 	movl   $0x802a48,0x8(%ebx)
  8011ec:	eb 43                	jmp    801231 <argnextvalue+0x65>
	} else if (*args->argc > 1) {
  8011ee:	8b 03                	mov    (%ebx),%eax
  8011f0:	83 38 01             	cmpl   $0x1,(%eax)
  8011f3:	7e 2e                	jle    801223 <argnextvalue+0x57>
		args->argvalue = args->argv[1];
  8011f5:	8b 53 04             	mov    0x4(%ebx),%edx
  8011f8:	8b 4a 04             	mov    0x4(%edx),%ecx
  8011fb:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  8011fe:	8b 00                	mov    (%eax),%eax
  801200:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801207:	89 44 24 08          	mov    %eax,0x8(%esp)
  80120b:	8d 42 08             	lea    0x8(%edx),%eax
  80120e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801212:	83 c2 04             	add    $0x4,%edx
  801215:	89 14 24             	mov    %edx,(%esp)
  801218:	e8 83 f9 ff ff       	call   800ba0 <memmove>
		(*args->argc)--;
  80121d:	8b 03                	mov    (%ebx),%eax
  80121f:	ff 08                	decl   (%eax)
  801221:	eb 0e                	jmp    801231 <argnextvalue+0x65>
	} else {
		args->argvalue = 0;
  801223:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  80122a:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  801231:	8b 43 0c             	mov    0xc(%ebx),%eax
  801234:	eb 05                	jmp    80123b <argnextvalue+0x6f>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  801236:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  80123b:	83 c4 14             	add    $0x14,%esp
  80123e:	5b                   	pop    %ebx
  80123f:	5d                   	pop    %ebp
  801240:	c3                   	ret    

00801241 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  801241:	55                   	push   %ebp
  801242:	89 e5                	mov    %esp,%ebp
  801244:	83 ec 18             	sub    $0x18,%esp
  801247:	8b 55 08             	mov    0x8(%ebp),%edx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  80124a:	8b 42 0c             	mov    0xc(%edx),%eax
  80124d:	85 c0                	test   %eax,%eax
  80124f:	75 08                	jne    801259 <argvalue+0x18>
  801251:	89 14 24             	mov    %edx,(%esp)
  801254:	e8 73 ff ff ff       	call   8011cc <argnextvalue>
}
  801259:	c9                   	leave  
  80125a:	c3                   	ret    
	...

0080125c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80125c:	55                   	push   %ebp
  80125d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80125f:	8b 45 08             	mov    0x8(%ebp),%eax
  801262:	05 00 00 00 30       	add    $0x30000000,%eax
  801267:	c1 e8 0c             	shr    $0xc,%eax
}
  80126a:	5d                   	pop    %ebp
  80126b:	c3                   	ret    

0080126c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80126c:	55                   	push   %ebp
  80126d:	89 e5                	mov    %esp,%ebp
  80126f:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801272:	8b 45 08             	mov    0x8(%ebp),%eax
  801275:	89 04 24             	mov    %eax,(%esp)
  801278:	e8 df ff ff ff       	call   80125c <fd2num>
  80127d:	05 20 00 0d 00       	add    $0xd0020,%eax
  801282:	c1 e0 0c             	shl    $0xc,%eax
}
  801285:	c9                   	leave  
  801286:	c3                   	ret    

00801287 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801287:	55                   	push   %ebp
  801288:	89 e5                	mov    %esp,%ebp
  80128a:	53                   	push   %ebx
  80128b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80128e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801293:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801295:	89 c2                	mov    %eax,%edx
  801297:	c1 ea 16             	shr    $0x16,%edx
  80129a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012a1:	f6 c2 01             	test   $0x1,%dl
  8012a4:	74 11                	je     8012b7 <fd_alloc+0x30>
  8012a6:	89 c2                	mov    %eax,%edx
  8012a8:	c1 ea 0c             	shr    $0xc,%edx
  8012ab:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012b2:	f6 c2 01             	test   $0x1,%dl
  8012b5:	75 09                	jne    8012c0 <fd_alloc+0x39>
			*fd_store = fd;
  8012b7:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8012b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8012be:	eb 17                	jmp    8012d7 <fd_alloc+0x50>
  8012c0:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012c5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012ca:	75 c7                	jne    801293 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012cc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8012d2:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012d7:	5b                   	pop    %ebx
  8012d8:	5d                   	pop    %ebp
  8012d9:	c3                   	ret    

008012da <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012da:	55                   	push   %ebp
  8012db:	89 e5                	mov    %esp,%ebp
  8012dd:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012e0:	83 f8 1f             	cmp    $0x1f,%eax
  8012e3:	77 36                	ja     80131b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012e5:	05 00 00 0d 00       	add    $0xd0000,%eax
  8012ea:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012ed:	89 c2                	mov    %eax,%edx
  8012ef:	c1 ea 16             	shr    $0x16,%edx
  8012f2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012f9:	f6 c2 01             	test   $0x1,%dl
  8012fc:	74 24                	je     801322 <fd_lookup+0x48>
  8012fe:	89 c2                	mov    %eax,%edx
  801300:	c1 ea 0c             	shr    $0xc,%edx
  801303:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80130a:	f6 c2 01             	test   $0x1,%dl
  80130d:	74 1a                	je     801329 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80130f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801312:	89 02                	mov    %eax,(%edx)
	return 0;
  801314:	b8 00 00 00 00       	mov    $0x0,%eax
  801319:	eb 13                	jmp    80132e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80131b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801320:	eb 0c                	jmp    80132e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801322:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801327:	eb 05                	jmp    80132e <fd_lookup+0x54>
  801329:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80132e:	5d                   	pop    %ebp
  80132f:	c3                   	ret    

00801330 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801330:	55                   	push   %ebp
  801331:	89 e5                	mov    %esp,%ebp
  801333:	53                   	push   %ebx
  801334:	83 ec 14             	sub    $0x14,%esp
  801337:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80133a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  80133d:	ba 00 00 00 00       	mov    $0x0,%edx
  801342:	eb 0e                	jmp    801352 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801344:	39 08                	cmp    %ecx,(%eax)
  801346:	75 09                	jne    801351 <dev_lookup+0x21>
			*dev = devtab[i];
  801348:	89 03                	mov    %eax,(%ebx)
			return 0;
  80134a:	b8 00 00 00 00       	mov    $0x0,%eax
  80134f:	eb 33                	jmp    801384 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801351:	42                   	inc    %edx
  801352:	8b 04 95 50 2e 80 00 	mov    0x802e50(,%edx,4),%eax
  801359:	85 c0                	test   %eax,%eax
  80135b:	75 e7                	jne    801344 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80135d:	a1 20 44 80 00       	mov    0x804420,%eax
  801362:	8b 40 48             	mov    0x48(%eax),%eax
  801365:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801369:	89 44 24 04          	mov    %eax,0x4(%esp)
  80136d:	c7 04 24 d4 2d 80 00 	movl   $0x802dd4,(%esp)
  801374:	e8 03 f1 ff ff       	call   80047c <cprintf>
	*dev = 0;
  801379:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80137f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801384:	83 c4 14             	add    $0x14,%esp
  801387:	5b                   	pop    %ebx
  801388:	5d                   	pop    %ebp
  801389:	c3                   	ret    

0080138a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80138a:	55                   	push   %ebp
  80138b:	89 e5                	mov    %esp,%ebp
  80138d:	56                   	push   %esi
  80138e:	53                   	push   %ebx
  80138f:	83 ec 30             	sub    $0x30,%esp
  801392:	8b 75 08             	mov    0x8(%ebp),%esi
  801395:	8a 45 0c             	mov    0xc(%ebp),%al
  801398:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80139b:	89 34 24             	mov    %esi,(%esp)
  80139e:	e8 b9 fe ff ff       	call   80125c <fd2num>
  8013a3:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8013a6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8013aa:	89 04 24             	mov    %eax,(%esp)
  8013ad:	e8 28 ff ff ff       	call   8012da <fd_lookup>
  8013b2:	89 c3                	mov    %eax,%ebx
  8013b4:	85 c0                	test   %eax,%eax
  8013b6:	78 05                	js     8013bd <fd_close+0x33>
	    || fd != fd2)
  8013b8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013bb:	74 0d                	je     8013ca <fd_close+0x40>
		return (must_exist ? r : 0);
  8013bd:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8013c1:	75 46                	jne    801409 <fd_close+0x7f>
  8013c3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013c8:	eb 3f                	jmp    801409 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013ca:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d1:	8b 06                	mov    (%esi),%eax
  8013d3:	89 04 24             	mov    %eax,(%esp)
  8013d6:	e8 55 ff ff ff       	call   801330 <dev_lookup>
  8013db:	89 c3                	mov    %eax,%ebx
  8013dd:	85 c0                	test   %eax,%eax
  8013df:	78 18                	js     8013f9 <fd_close+0x6f>
		if (dev->dev_close)
  8013e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013e4:	8b 40 10             	mov    0x10(%eax),%eax
  8013e7:	85 c0                	test   %eax,%eax
  8013e9:	74 09                	je     8013f4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8013eb:	89 34 24             	mov    %esi,(%esp)
  8013ee:	ff d0                	call   *%eax
  8013f0:	89 c3                	mov    %eax,%ebx
  8013f2:	eb 05                	jmp    8013f9 <fd_close+0x6f>
		else
			r = 0;
  8013f4:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013f9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013fd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801404:	e8 b7 fa ff ff       	call   800ec0 <sys_page_unmap>
	return r;
}
  801409:	89 d8                	mov    %ebx,%eax
  80140b:	83 c4 30             	add    $0x30,%esp
  80140e:	5b                   	pop    %ebx
  80140f:	5e                   	pop    %esi
  801410:	5d                   	pop    %ebp
  801411:	c3                   	ret    

00801412 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801412:	55                   	push   %ebp
  801413:	89 e5                	mov    %esp,%ebp
  801415:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801418:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80141b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80141f:	8b 45 08             	mov    0x8(%ebp),%eax
  801422:	89 04 24             	mov    %eax,(%esp)
  801425:	e8 b0 fe ff ff       	call   8012da <fd_lookup>
  80142a:	85 c0                	test   %eax,%eax
  80142c:	78 13                	js     801441 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80142e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801435:	00 
  801436:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801439:	89 04 24             	mov    %eax,(%esp)
  80143c:	e8 49 ff ff ff       	call   80138a <fd_close>
}
  801441:	c9                   	leave  
  801442:	c3                   	ret    

00801443 <close_all>:

void
close_all(void)
{
  801443:	55                   	push   %ebp
  801444:	89 e5                	mov    %esp,%ebp
  801446:	53                   	push   %ebx
  801447:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80144a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80144f:	89 1c 24             	mov    %ebx,(%esp)
  801452:	e8 bb ff ff ff       	call   801412 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801457:	43                   	inc    %ebx
  801458:	83 fb 20             	cmp    $0x20,%ebx
  80145b:	75 f2                	jne    80144f <close_all+0xc>
		close(i);
}
  80145d:	83 c4 14             	add    $0x14,%esp
  801460:	5b                   	pop    %ebx
  801461:	5d                   	pop    %ebp
  801462:	c3                   	ret    

00801463 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801463:	55                   	push   %ebp
  801464:	89 e5                	mov    %esp,%ebp
  801466:	57                   	push   %edi
  801467:	56                   	push   %esi
  801468:	53                   	push   %ebx
  801469:	83 ec 4c             	sub    $0x4c,%esp
  80146c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80146f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801472:	89 44 24 04          	mov    %eax,0x4(%esp)
  801476:	8b 45 08             	mov    0x8(%ebp),%eax
  801479:	89 04 24             	mov    %eax,(%esp)
  80147c:	e8 59 fe ff ff       	call   8012da <fd_lookup>
  801481:	89 c3                	mov    %eax,%ebx
  801483:	85 c0                	test   %eax,%eax
  801485:	0f 88 e1 00 00 00    	js     80156c <dup+0x109>
		return r;
	close(newfdnum);
  80148b:	89 3c 24             	mov    %edi,(%esp)
  80148e:	e8 7f ff ff ff       	call   801412 <close>

	newfd = INDEX2FD(newfdnum);
  801493:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801499:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80149c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80149f:	89 04 24             	mov    %eax,(%esp)
  8014a2:	e8 c5 fd ff ff       	call   80126c <fd2data>
  8014a7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8014a9:	89 34 24             	mov    %esi,(%esp)
  8014ac:	e8 bb fd ff ff       	call   80126c <fd2data>
  8014b1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014b4:	89 d8                	mov    %ebx,%eax
  8014b6:	c1 e8 16             	shr    $0x16,%eax
  8014b9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014c0:	a8 01                	test   $0x1,%al
  8014c2:	74 46                	je     80150a <dup+0xa7>
  8014c4:	89 d8                	mov    %ebx,%eax
  8014c6:	c1 e8 0c             	shr    $0xc,%eax
  8014c9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014d0:	f6 c2 01             	test   $0x1,%dl
  8014d3:	74 35                	je     80150a <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014d5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014dc:	25 07 0e 00 00       	and    $0xe07,%eax
  8014e1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014e5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8014e8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014ec:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014f3:	00 
  8014f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014f8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014ff:	e8 69 f9 ff ff       	call   800e6d <sys_page_map>
  801504:	89 c3                	mov    %eax,%ebx
  801506:	85 c0                	test   %eax,%eax
  801508:	78 3b                	js     801545 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80150a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80150d:	89 c2                	mov    %eax,%edx
  80150f:	c1 ea 0c             	shr    $0xc,%edx
  801512:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801519:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80151f:	89 54 24 10          	mov    %edx,0x10(%esp)
  801523:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801527:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80152e:	00 
  80152f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801533:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80153a:	e8 2e f9 ff ff       	call   800e6d <sys_page_map>
  80153f:	89 c3                	mov    %eax,%ebx
  801541:	85 c0                	test   %eax,%eax
  801543:	79 25                	jns    80156a <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801545:	89 74 24 04          	mov    %esi,0x4(%esp)
  801549:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801550:	e8 6b f9 ff ff       	call   800ec0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801555:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801558:	89 44 24 04          	mov    %eax,0x4(%esp)
  80155c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801563:	e8 58 f9 ff ff       	call   800ec0 <sys_page_unmap>
	return r;
  801568:	eb 02                	jmp    80156c <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80156a:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80156c:	89 d8                	mov    %ebx,%eax
  80156e:	83 c4 4c             	add    $0x4c,%esp
  801571:	5b                   	pop    %ebx
  801572:	5e                   	pop    %esi
  801573:	5f                   	pop    %edi
  801574:	5d                   	pop    %ebp
  801575:	c3                   	ret    

00801576 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801576:	55                   	push   %ebp
  801577:	89 e5                	mov    %esp,%ebp
  801579:	53                   	push   %ebx
  80157a:	83 ec 24             	sub    $0x24,%esp
  80157d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801580:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801583:	89 44 24 04          	mov    %eax,0x4(%esp)
  801587:	89 1c 24             	mov    %ebx,(%esp)
  80158a:	e8 4b fd ff ff       	call   8012da <fd_lookup>
  80158f:	85 c0                	test   %eax,%eax
  801591:	78 6d                	js     801600 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801593:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801596:	89 44 24 04          	mov    %eax,0x4(%esp)
  80159a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80159d:	8b 00                	mov    (%eax),%eax
  80159f:	89 04 24             	mov    %eax,(%esp)
  8015a2:	e8 89 fd ff ff       	call   801330 <dev_lookup>
  8015a7:	85 c0                	test   %eax,%eax
  8015a9:	78 55                	js     801600 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ae:	8b 50 08             	mov    0x8(%eax),%edx
  8015b1:	83 e2 03             	and    $0x3,%edx
  8015b4:	83 fa 01             	cmp    $0x1,%edx
  8015b7:	75 23                	jne    8015dc <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015b9:	a1 20 44 80 00       	mov    0x804420,%eax
  8015be:	8b 40 48             	mov    0x48(%eax),%eax
  8015c1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8015c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015c9:	c7 04 24 15 2e 80 00 	movl   $0x802e15,(%esp)
  8015d0:	e8 a7 ee ff ff       	call   80047c <cprintf>
		return -E_INVAL;
  8015d5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015da:	eb 24                	jmp    801600 <read+0x8a>
	}
	if (!dev->dev_read)
  8015dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015df:	8b 52 08             	mov    0x8(%edx),%edx
  8015e2:	85 d2                	test   %edx,%edx
  8015e4:	74 15                	je     8015fb <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015e6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015e9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015f0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8015f4:	89 04 24             	mov    %eax,(%esp)
  8015f7:	ff d2                	call   *%edx
  8015f9:	eb 05                	jmp    801600 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015fb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801600:	83 c4 24             	add    $0x24,%esp
  801603:	5b                   	pop    %ebx
  801604:	5d                   	pop    %ebp
  801605:	c3                   	ret    

00801606 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801606:	55                   	push   %ebp
  801607:	89 e5                	mov    %esp,%ebp
  801609:	57                   	push   %edi
  80160a:	56                   	push   %esi
  80160b:	53                   	push   %ebx
  80160c:	83 ec 1c             	sub    $0x1c,%esp
  80160f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801612:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801615:	bb 00 00 00 00       	mov    $0x0,%ebx
  80161a:	eb 23                	jmp    80163f <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80161c:	89 f0                	mov    %esi,%eax
  80161e:	29 d8                	sub    %ebx,%eax
  801620:	89 44 24 08          	mov    %eax,0x8(%esp)
  801624:	8b 45 0c             	mov    0xc(%ebp),%eax
  801627:	01 d8                	add    %ebx,%eax
  801629:	89 44 24 04          	mov    %eax,0x4(%esp)
  80162d:	89 3c 24             	mov    %edi,(%esp)
  801630:	e8 41 ff ff ff       	call   801576 <read>
		if (m < 0)
  801635:	85 c0                	test   %eax,%eax
  801637:	78 10                	js     801649 <readn+0x43>
			return m;
		if (m == 0)
  801639:	85 c0                	test   %eax,%eax
  80163b:	74 0a                	je     801647 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80163d:	01 c3                	add    %eax,%ebx
  80163f:	39 f3                	cmp    %esi,%ebx
  801641:	72 d9                	jb     80161c <readn+0x16>
  801643:	89 d8                	mov    %ebx,%eax
  801645:	eb 02                	jmp    801649 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801647:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801649:	83 c4 1c             	add    $0x1c,%esp
  80164c:	5b                   	pop    %ebx
  80164d:	5e                   	pop    %esi
  80164e:	5f                   	pop    %edi
  80164f:	5d                   	pop    %ebp
  801650:	c3                   	ret    

00801651 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801651:	55                   	push   %ebp
  801652:	89 e5                	mov    %esp,%ebp
  801654:	53                   	push   %ebx
  801655:	83 ec 24             	sub    $0x24,%esp
  801658:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80165b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80165e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801662:	89 1c 24             	mov    %ebx,(%esp)
  801665:	e8 70 fc ff ff       	call   8012da <fd_lookup>
  80166a:	85 c0                	test   %eax,%eax
  80166c:	78 68                	js     8016d6 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80166e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801671:	89 44 24 04          	mov    %eax,0x4(%esp)
  801675:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801678:	8b 00                	mov    (%eax),%eax
  80167a:	89 04 24             	mov    %eax,(%esp)
  80167d:	e8 ae fc ff ff       	call   801330 <dev_lookup>
  801682:	85 c0                	test   %eax,%eax
  801684:	78 50                	js     8016d6 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801686:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801689:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80168d:	75 23                	jne    8016b2 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80168f:	a1 20 44 80 00       	mov    0x804420,%eax
  801694:	8b 40 48             	mov    0x48(%eax),%eax
  801697:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80169b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80169f:	c7 04 24 31 2e 80 00 	movl   $0x802e31,(%esp)
  8016a6:	e8 d1 ed ff ff       	call   80047c <cprintf>
		return -E_INVAL;
  8016ab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016b0:	eb 24                	jmp    8016d6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016b5:	8b 52 0c             	mov    0xc(%edx),%edx
  8016b8:	85 d2                	test   %edx,%edx
  8016ba:	74 15                	je     8016d1 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016bc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8016bf:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8016c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016c6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8016ca:	89 04 24             	mov    %eax,(%esp)
  8016cd:	ff d2                	call   *%edx
  8016cf:	eb 05                	jmp    8016d6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016d1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8016d6:	83 c4 24             	add    $0x24,%esp
  8016d9:	5b                   	pop    %ebx
  8016da:	5d                   	pop    %ebp
  8016db:	c3                   	ret    

008016dc <seek>:

int
seek(int fdnum, off_t offset)
{
  8016dc:	55                   	push   %ebp
  8016dd:	89 e5                	mov    %esp,%ebp
  8016df:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016e2:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ec:	89 04 24             	mov    %eax,(%esp)
  8016ef:	e8 e6 fb ff ff       	call   8012da <fd_lookup>
  8016f4:	85 c0                	test   %eax,%eax
  8016f6:	78 0e                	js     801706 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8016f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016fe:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801701:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801706:	c9                   	leave  
  801707:	c3                   	ret    

00801708 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801708:	55                   	push   %ebp
  801709:	89 e5                	mov    %esp,%ebp
  80170b:	53                   	push   %ebx
  80170c:	83 ec 24             	sub    $0x24,%esp
  80170f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801712:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801715:	89 44 24 04          	mov    %eax,0x4(%esp)
  801719:	89 1c 24             	mov    %ebx,(%esp)
  80171c:	e8 b9 fb ff ff       	call   8012da <fd_lookup>
  801721:	85 c0                	test   %eax,%eax
  801723:	78 61                	js     801786 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801725:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801728:	89 44 24 04          	mov    %eax,0x4(%esp)
  80172c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80172f:	8b 00                	mov    (%eax),%eax
  801731:	89 04 24             	mov    %eax,(%esp)
  801734:	e8 f7 fb ff ff       	call   801330 <dev_lookup>
  801739:	85 c0                	test   %eax,%eax
  80173b:	78 49                	js     801786 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80173d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801740:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801744:	75 23                	jne    801769 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801746:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80174b:	8b 40 48             	mov    0x48(%eax),%eax
  80174e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801752:	89 44 24 04          	mov    %eax,0x4(%esp)
  801756:	c7 04 24 f4 2d 80 00 	movl   $0x802df4,(%esp)
  80175d:	e8 1a ed ff ff       	call   80047c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801762:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801767:	eb 1d                	jmp    801786 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801769:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80176c:	8b 52 18             	mov    0x18(%edx),%edx
  80176f:	85 d2                	test   %edx,%edx
  801771:	74 0e                	je     801781 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801773:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801776:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80177a:	89 04 24             	mov    %eax,(%esp)
  80177d:	ff d2                	call   *%edx
  80177f:	eb 05                	jmp    801786 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801781:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801786:	83 c4 24             	add    $0x24,%esp
  801789:	5b                   	pop    %ebx
  80178a:	5d                   	pop    %ebp
  80178b:	c3                   	ret    

0080178c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80178c:	55                   	push   %ebp
  80178d:	89 e5                	mov    %esp,%ebp
  80178f:	53                   	push   %ebx
  801790:	83 ec 24             	sub    $0x24,%esp
  801793:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801796:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801799:	89 44 24 04          	mov    %eax,0x4(%esp)
  80179d:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a0:	89 04 24             	mov    %eax,(%esp)
  8017a3:	e8 32 fb ff ff       	call   8012da <fd_lookup>
  8017a8:	85 c0                	test   %eax,%eax
  8017aa:	78 52                	js     8017fe <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017b6:	8b 00                	mov    (%eax),%eax
  8017b8:	89 04 24             	mov    %eax,(%esp)
  8017bb:	e8 70 fb ff ff       	call   801330 <dev_lookup>
  8017c0:	85 c0                	test   %eax,%eax
  8017c2:	78 3a                	js     8017fe <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8017c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017c7:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017cb:	74 2c                	je     8017f9 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017cd:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017d0:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017d7:	00 00 00 
	stat->st_isdir = 0;
  8017da:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017e1:	00 00 00 
	stat->st_dev = dev;
  8017e4:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017ea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017ee:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017f1:	89 14 24             	mov    %edx,(%esp)
  8017f4:	ff 50 14             	call   *0x14(%eax)
  8017f7:	eb 05                	jmp    8017fe <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017f9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017fe:	83 c4 24             	add    $0x24,%esp
  801801:	5b                   	pop    %ebx
  801802:	5d                   	pop    %ebp
  801803:	c3                   	ret    

00801804 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801804:	55                   	push   %ebp
  801805:	89 e5                	mov    %esp,%ebp
  801807:	56                   	push   %esi
  801808:	53                   	push   %ebx
  801809:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80180c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801813:	00 
  801814:	8b 45 08             	mov    0x8(%ebp),%eax
  801817:	89 04 24             	mov    %eax,(%esp)
  80181a:	e8 2d 02 00 00       	call   801a4c <open>
  80181f:	89 c3                	mov    %eax,%ebx
  801821:	85 c0                	test   %eax,%eax
  801823:	78 1b                	js     801840 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801825:	8b 45 0c             	mov    0xc(%ebp),%eax
  801828:	89 44 24 04          	mov    %eax,0x4(%esp)
  80182c:	89 1c 24             	mov    %ebx,(%esp)
  80182f:	e8 58 ff ff ff       	call   80178c <fstat>
  801834:	89 c6                	mov    %eax,%esi
	close(fd);
  801836:	89 1c 24             	mov    %ebx,(%esp)
  801839:	e8 d4 fb ff ff       	call   801412 <close>
	return r;
  80183e:	89 f3                	mov    %esi,%ebx
}
  801840:	89 d8                	mov    %ebx,%eax
  801842:	83 c4 10             	add    $0x10,%esp
  801845:	5b                   	pop    %ebx
  801846:	5e                   	pop    %esi
  801847:	5d                   	pop    %ebp
  801848:	c3                   	ret    
  801849:	00 00                	add    %al,(%eax)
	...

0080184c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80184c:	55                   	push   %ebp
  80184d:	89 e5                	mov    %esp,%ebp
  80184f:	56                   	push   %esi
  801850:	53                   	push   %ebx
  801851:	83 ec 10             	sub    $0x10,%esp
  801854:	89 c3                	mov    %eax,%ebx
  801856:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801858:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80185f:	75 11                	jne    801872 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801861:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801868:	e8 a2 0e 00 00       	call   80270f <ipc_find_env>
  80186d:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801872:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801879:	00 
  80187a:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801881:	00 
  801882:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801886:	a1 00 40 80 00       	mov    0x804000,%eax
  80188b:	89 04 24             	mov    %eax,(%esp)
  80188e:	e8 0e 0e 00 00       	call   8026a1 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801893:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80189a:	00 
  80189b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80189f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018a6:	e8 8d 0d 00 00       	call   802638 <ipc_recv>
}
  8018ab:	83 c4 10             	add    $0x10,%esp
  8018ae:	5b                   	pop    %ebx
  8018af:	5e                   	pop    %esi
  8018b0:	5d                   	pop    %ebp
  8018b1:	c3                   	ret    

008018b2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018b2:	55                   	push   %ebp
  8018b3:	89 e5                	mov    %esp,%ebp
  8018b5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8018bb:	8b 40 0c             	mov    0xc(%eax),%eax
  8018be:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8018c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018c6:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d0:	b8 02 00 00 00       	mov    $0x2,%eax
  8018d5:	e8 72 ff ff ff       	call   80184c <fsipc>
}
  8018da:	c9                   	leave  
  8018db:	c3                   	ret    

008018dc <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018dc:	55                   	push   %ebp
  8018dd:	89 e5                	mov    %esp,%ebp
  8018df:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e5:	8b 40 0c             	mov    0xc(%eax),%eax
  8018e8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f2:	b8 06 00 00 00       	mov    $0x6,%eax
  8018f7:	e8 50 ff ff ff       	call   80184c <fsipc>
}
  8018fc:	c9                   	leave  
  8018fd:	c3                   	ret    

008018fe <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018fe:	55                   	push   %ebp
  8018ff:	89 e5                	mov    %esp,%ebp
  801901:	53                   	push   %ebx
  801902:	83 ec 14             	sub    $0x14,%esp
  801905:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801908:	8b 45 08             	mov    0x8(%ebp),%eax
  80190b:	8b 40 0c             	mov    0xc(%eax),%eax
  80190e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801913:	ba 00 00 00 00       	mov    $0x0,%edx
  801918:	b8 05 00 00 00       	mov    $0x5,%eax
  80191d:	e8 2a ff ff ff       	call   80184c <fsipc>
  801922:	85 c0                	test   %eax,%eax
  801924:	78 2b                	js     801951 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801926:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80192d:	00 
  80192e:	89 1c 24             	mov    %ebx,(%esp)
  801931:	e8 f1 f0 ff ff       	call   800a27 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801936:	a1 80 50 80 00       	mov    0x805080,%eax
  80193b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801941:	a1 84 50 80 00       	mov    0x805084,%eax
  801946:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80194c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801951:	83 c4 14             	add    $0x14,%esp
  801954:	5b                   	pop    %ebx
  801955:	5d                   	pop    %ebp
  801956:	c3                   	ret    

00801957 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801957:	55                   	push   %ebp
  801958:	89 e5                	mov    %esp,%ebp
  80195a:	83 ec 18             	sub    $0x18,%esp
  80195d:	8b 55 10             	mov    0x10(%ebp),%edx
  801960:	89 d0                	mov    %edx,%eax
  801962:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  801968:	76 05                	jbe    80196f <devfile_write+0x18>
  80196a:	b8 00 10 00 00       	mov    $0x1000,%eax
	//panic("devfile_write not implemented");
	int r;
	//uint32_t maxsize = BLKSIZE - sizeof(int) - sizeof(size_t);	
	if (n > BLKSIZE)
		n = BLKSIZE;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80196f:	8b 55 08             	mov    0x8(%ebp),%edx
  801972:	8b 52 0c             	mov    0xc(%edx),%edx
  801975:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80197b:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801980:	89 44 24 08          	mov    %eax,0x8(%esp)
  801984:	8b 45 0c             	mov    0xc(%ebp),%eax
  801987:	89 44 24 04          	mov    %eax,0x4(%esp)
  80198b:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801992:	e8 09 f2 ff ff       	call   800ba0 <memmove>
	 
	return fsipc(FSREQ_WRITE, NULL);
  801997:	ba 00 00 00 00       	mov    $0x0,%edx
  80199c:	b8 04 00 00 00       	mov    $0x4,%eax
  8019a1:	e8 a6 fe ff ff       	call   80184c <fsipc>
}
  8019a6:	c9                   	leave  
  8019a7:	c3                   	ret    

008019a8 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019a8:	55                   	push   %ebp
  8019a9:	89 e5                	mov    %esp,%ebp
  8019ab:	56                   	push   %esi
  8019ac:	53                   	push   %ebx
  8019ad:	83 ec 10             	sub    $0x10,%esp
  8019b0:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b6:	8b 40 0c             	mov    0xc(%eax),%eax
  8019b9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019be:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8019c9:	b8 03 00 00 00       	mov    $0x3,%eax
  8019ce:	e8 79 fe ff ff       	call   80184c <fsipc>
  8019d3:	89 c3                	mov    %eax,%ebx
  8019d5:	85 c0                	test   %eax,%eax
  8019d7:	78 6a                	js     801a43 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8019d9:	39 c6                	cmp    %eax,%esi
  8019db:	73 24                	jae    801a01 <devfile_read+0x59>
  8019dd:	c7 44 24 0c 64 2e 80 	movl   $0x802e64,0xc(%esp)
  8019e4:	00 
  8019e5:	c7 44 24 08 6b 2e 80 	movl   $0x802e6b,0x8(%esp)
  8019ec:	00 
  8019ed:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8019f4:	00 
  8019f5:	c7 04 24 80 2e 80 00 	movl   $0x802e80,(%esp)
  8019fc:	e8 83 e9 ff ff       	call   800384 <_panic>
	assert(r <= PGSIZE);
  801a01:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a06:	7e 24                	jle    801a2c <devfile_read+0x84>
  801a08:	c7 44 24 0c 8b 2e 80 	movl   $0x802e8b,0xc(%esp)
  801a0f:	00 
  801a10:	c7 44 24 08 6b 2e 80 	movl   $0x802e6b,0x8(%esp)
  801a17:	00 
  801a18:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801a1f:	00 
  801a20:	c7 04 24 80 2e 80 00 	movl   $0x802e80,(%esp)
  801a27:	e8 58 e9 ff ff       	call   800384 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a2c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a30:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801a37:	00 
  801a38:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a3b:	89 04 24             	mov    %eax,(%esp)
  801a3e:	e8 5d f1 ff ff       	call   800ba0 <memmove>
	return r;
}
  801a43:	89 d8                	mov    %ebx,%eax
  801a45:	83 c4 10             	add    $0x10,%esp
  801a48:	5b                   	pop    %ebx
  801a49:	5e                   	pop    %esi
  801a4a:	5d                   	pop    %ebp
  801a4b:	c3                   	ret    

00801a4c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a4c:	55                   	push   %ebp
  801a4d:	89 e5                	mov    %esp,%ebp
  801a4f:	56                   	push   %esi
  801a50:	53                   	push   %ebx
  801a51:	83 ec 20             	sub    $0x20,%esp
  801a54:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a57:	89 34 24             	mov    %esi,(%esp)
  801a5a:	e8 95 ef ff ff       	call   8009f4 <strlen>
  801a5f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a64:	7f 60                	jg     801ac6 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a66:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a69:	89 04 24             	mov    %eax,(%esp)
  801a6c:	e8 16 f8 ff ff       	call   801287 <fd_alloc>
  801a71:	89 c3                	mov    %eax,%ebx
  801a73:	85 c0                	test   %eax,%eax
  801a75:	78 54                	js     801acb <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a77:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a7b:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801a82:	e8 a0 ef ff ff       	call   800a27 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a87:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a8a:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a8f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a92:	b8 01 00 00 00       	mov    $0x1,%eax
  801a97:	e8 b0 fd ff ff       	call   80184c <fsipc>
  801a9c:	89 c3                	mov    %eax,%ebx
  801a9e:	85 c0                	test   %eax,%eax
  801aa0:	79 15                	jns    801ab7 <open+0x6b>
		fd_close(fd, 0);
  801aa2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801aa9:	00 
  801aaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aad:	89 04 24             	mov    %eax,(%esp)
  801ab0:	e8 d5 f8 ff ff       	call   80138a <fd_close>
		return r;
  801ab5:	eb 14                	jmp    801acb <open+0x7f>
	}

	return fd2num(fd);
  801ab7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aba:	89 04 24             	mov    %eax,(%esp)
  801abd:	e8 9a f7 ff ff       	call   80125c <fd2num>
  801ac2:	89 c3                	mov    %eax,%ebx
  801ac4:	eb 05                	jmp    801acb <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801ac6:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801acb:	89 d8                	mov    %ebx,%eax
  801acd:	83 c4 20             	add    $0x20,%esp
  801ad0:	5b                   	pop    %ebx
  801ad1:	5e                   	pop    %esi
  801ad2:	5d                   	pop    %ebp
  801ad3:	c3                   	ret    

00801ad4 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801ad4:	55                   	push   %ebp
  801ad5:	89 e5                	mov    %esp,%ebp
  801ad7:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801ada:	ba 00 00 00 00       	mov    $0x0,%edx
  801adf:	b8 08 00 00 00       	mov    $0x8,%eax
  801ae4:	e8 63 fd ff ff       	call   80184c <fsipc>
}
  801ae9:	c9                   	leave  
  801aea:	c3                   	ret    
	...

00801aec <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  801aec:	55                   	push   %ebp
  801aed:	89 e5                	mov    %esp,%ebp
  801aef:	53                   	push   %ebx
  801af0:	83 ec 14             	sub    $0x14,%esp
  801af3:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  801af5:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801af9:	7e 32                	jle    801b2d <writebuf+0x41>
		ssize_t result = write(b->fd, b->buf, b->idx);
  801afb:	8b 40 04             	mov    0x4(%eax),%eax
  801afe:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b02:	8d 43 10             	lea    0x10(%ebx),%eax
  801b05:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b09:	8b 03                	mov    (%ebx),%eax
  801b0b:	89 04 24             	mov    %eax,(%esp)
  801b0e:	e8 3e fb ff ff       	call   801651 <write>
		if (result > 0)
  801b13:	85 c0                	test   %eax,%eax
  801b15:	7e 03                	jle    801b1a <writebuf+0x2e>
			b->result += result;
  801b17:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801b1a:	39 43 04             	cmp    %eax,0x4(%ebx)
  801b1d:	74 0e                	je     801b2d <writebuf+0x41>
			b->error = (result < 0 ? result : 0);
  801b1f:	89 c2                	mov    %eax,%edx
  801b21:	85 c0                	test   %eax,%eax
  801b23:	7e 05                	jle    801b2a <writebuf+0x3e>
  801b25:	ba 00 00 00 00       	mov    $0x0,%edx
  801b2a:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  801b2d:	83 c4 14             	add    $0x14,%esp
  801b30:	5b                   	pop    %ebx
  801b31:	5d                   	pop    %ebp
  801b32:	c3                   	ret    

00801b33 <putch>:

static void
putch(int ch, void *thunk)
{
  801b33:	55                   	push   %ebp
  801b34:	89 e5                	mov    %esp,%ebp
  801b36:	53                   	push   %ebx
  801b37:	83 ec 04             	sub    $0x4,%esp
  801b3a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801b3d:	8b 43 04             	mov    0x4(%ebx),%eax
  801b40:	8b 55 08             	mov    0x8(%ebp),%edx
  801b43:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  801b47:	40                   	inc    %eax
  801b48:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  801b4b:	3d 00 01 00 00       	cmp    $0x100,%eax
  801b50:	75 0e                	jne    801b60 <putch+0x2d>
		writebuf(b);
  801b52:	89 d8                	mov    %ebx,%eax
  801b54:	e8 93 ff ff ff       	call   801aec <writebuf>
		b->idx = 0;
  801b59:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801b60:	83 c4 04             	add    $0x4,%esp
  801b63:	5b                   	pop    %ebx
  801b64:	5d                   	pop    %ebp
  801b65:	c3                   	ret    

00801b66 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801b66:	55                   	push   %ebp
  801b67:	89 e5                	mov    %esp,%ebp
  801b69:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  801b6f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b72:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801b78:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801b7f:	00 00 00 
	b.result = 0;
  801b82:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801b89:	00 00 00 
	b.error = 1;
  801b8c:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801b93:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801b96:	8b 45 10             	mov    0x10(%ebp),%eax
  801b99:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ba0:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ba4:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801baa:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bae:	c7 04 24 33 1b 80 00 	movl   $0x801b33,(%esp)
  801bb5:	e8 24 ea ff ff       	call   8005de <vprintfmt>
	if (b.idx > 0)
  801bba:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801bc1:	7e 0b                	jle    801bce <vfprintf+0x68>
		writebuf(&b);
  801bc3:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801bc9:	e8 1e ff ff ff       	call   801aec <writebuf>

	return (b.result ? b.result : b.error);
  801bce:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801bd4:	85 c0                	test   %eax,%eax
  801bd6:	75 06                	jne    801bde <vfprintf+0x78>
  801bd8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  801bde:	c9                   	leave  
  801bdf:	c3                   	ret    

00801be0 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801be0:	55                   	push   %ebp
  801be1:	89 e5                	mov    %esp,%ebp
  801be3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801be6:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801be9:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bed:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bf0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bf4:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf7:	89 04 24             	mov    %eax,(%esp)
  801bfa:	e8 67 ff ff ff       	call   801b66 <vfprintf>
	va_end(ap);

	return cnt;
}
  801bff:	c9                   	leave  
  801c00:	c3                   	ret    

00801c01 <printf>:

int
printf(const char *fmt, ...)
{
  801c01:	55                   	push   %ebp
  801c02:	89 e5                	mov    %esp,%ebp
  801c04:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801c07:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801c0a:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c0e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c11:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c15:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801c1c:	e8 45 ff ff ff       	call   801b66 <vfprintf>
	va_end(ap);

	return cnt;
}
  801c21:	c9                   	leave  
  801c22:	c3                   	ret    
	...

00801c24 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801c24:	55                   	push   %ebp
  801c25:	89 e5                	mov    %esp,%ebp
  801c27:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801c2a:	c7 44 24 04 97 2e 80 	movl   $0x802e97,0x4(%esp)
  801c31:	00 
  801c32:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c35:	89 04 24             	mov    %eax,(%esp)
  801c38:	e8 ea ed ff ff       	call   800a27 <strcpy>
	return 0;
}
  801c3d:	b8 00 00 00 00       	mov    $0x0,%eax
  801c42:	c9                   	leave  
  801c43:	c3                   	ret    

00801c44 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801c44:	55                   	push   %ebp
  801c45:	89 e5                	mov    %esp,%ebp
  801c47:	53                   	push   %ebx
  801c48:	83 ec 14             	sub    $0x14,%esp
  801c4b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801c4e:	89 1c 24             	mov    %ebx,(%esp)
  801c51:	e8 f2 0a 00 00       	call   802748 <pageref>
  801c56:	83 f8 01             	cmp    $0x1,%eax
  801c59:	75 0d                	jne    801c68 <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  801c5b:	8b 43 0c             	mov    0xc(%ebx),%eax
  801c5e:	89 04 24             	mov    %eax,(%esp)
  801c61:	e8 1f 03 00 00       	call   801f85 <nsipc_close>
  801c66:	eb 05                	jmp    801c6d <devsock_close+0x29>
	else
		return 0;
  801c68:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c6d:	83 c4 14             	add    $0x14,%esp
  801c70:	5b                   	pop    %ebx
  801c71:	5d                   	pop    %ebp
  801c72:	c3                   	ret    

00801c73 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801c73:	55                   	push   %ebp
  801c74:	89 e5                	mov    %esp,%ebp
  801c76:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801c79:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801c80:	00 
  801c81:	8b 45 10             	mov    0x10(%ebp),%eax
  801c84:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c88:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c8f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c92:	8b 40 0c             	mov    0xc(%eax),%eax
  801c95:	89 04 24             	mov    %eax,(%esp)
  801c98:	e8 e3 03 00 00       	call   802080 <nsipc_send>
}
  801c9d:	c9                   	leave  
  801c9e:	c3                   	ret    

00801c9f <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801c9f:	55                   	push   %ebp
  801ca0:	89 e5                	mov    %esp,%ebp
  801ca2:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801ca5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801cac:	00 
  801cad:	8b 45 10             	mov    0x10(%ebp),%eax
  801cb0:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cb4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cb7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cbb:	8b 45 08             	mov    0x8(%ebp),%eax
  801cbe:	8b 40 0c             	mov    0xc(%eax),%eax
  801cc1:	89 04 24             	mov    %eax,(%esp)
  801cc4:	e8 37 03 00 00       	call   802000 <nsipc_recv>
}
  801cc9:	c9                   	leave  
  801cca:	c3                   	ret    

00801ccb <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801ccb:	55                   	push   %ebp
  801ccc:	89 e5                	mov    %esp,%ebp
  801cce:	56                   	push   %esi
  801ccf:	53                   	push   %ebx
  801cd0:	83 ec 20             	sub    $0x20,%esp
  801cd3:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801cd5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cd8:	89 04 24             	mov    %eax,(%esp)
  801cdb:	e8 a7 f5 ff ff       	call   801287 <fd_alloc>
  801ce0:	89 c3                	mov    %eax,%ebx
  801ce2:	85 c0                	test   %eax,%eax
  801ce4:	78 21                	js     801d07 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801ce6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ced:	00 
  801cee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cf5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cfc:	e8 18 f1 ff ff       	call   800e19 <sys_page_alloc>
  801d01:	89 c3                	mov    %eax,%ebx
  801d03:	85 c0                	test   %eax,%eax
  801d05:	79 0a                	jns    801d11 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  801d07:	89 34 24             	mov    %esi,(%esp)
  801d0a:	e8 76 02 00 00       	call   801f85 <nsipc_close>
		return r;
  801d0f:	eb 22                	jmp    801d33 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801d11:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d17:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d1a:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801d1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d1f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801d26:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801d29:	89 04 24             	mov    %eax,(%esp)
  801d2c:	e8 2b f5 ff ff       	call   80125c <fd2num>
  801d31:	89 c3                	mov    %eax,%ebx
}
  801d33:	89 d8                	mov    %ebx,%eax
  801d35:	83 c4 20             	add    $0x20,%esp
  801d38:	5b                   	pop    %ebx
  801d39:	5e                   	pop    %esi
  801d3a:	5d                   	pop    %ebp
  801d3b:	c3                   	ret    

00801d3c <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801d3c:	55                   	push   %ebp
  801d3d:	89 e5                	mov    %esp,%ebp
  801d3f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801d42:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801d45:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d49:	89 04 24             	mov    %eax,(%esp)
  801d4c:	e8 89 f5 ff ff       	call   8012da <fd_lookup>
  801d51:	85 c0                	test   %eax,%eax
  801d53:	78 17                	js     801d6c <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801d55:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d58:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d5e:	39 10                	cmp    %edx,(%eax)
  801d60:	75 05                	jne    801d67 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801d62:	8b 40 0c             	mov    0xc(%eax),%eax
  801d65:	eb 05                	jmp    801d6c <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801d67:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801d6c:	c9                   	leave  
  801d6d:	c3                   	ret    

00801d6e <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d6e:	55                   	push   %ebp
  801d6f:	89 e5                	mov    %esp,%ebp
  801d71:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d74:	8b 45 08             	mov    0x8(%ebp),%eax
  801d77:	e8 c0 ff ff ff       	call   801d3c <fd2sockid>
  801d7c:	85 c0                	test   %eax,%eax
  801d7e:	78 1f                	js     801d9f <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801d80:	8b 55 10             	mov    0x10(%ebp),%edx
  801d83:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d87:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d8a:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d8e:	89 04 24             	mov    %eax,(%esp)
  801d91:	e8 38 01 00 00       	call   801ece <nsipc_accept>
  801d96:	85 c0                	test   %eax,%eax
  801d98:	78 05                	js     801d9f <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801d9a:	e8 2c ff ff ff       	call   801ccb <alloc_sockfd>
}
  801d9f:	c9                   	leave  
  801da0:	c3                   	ret    

00801da1 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801da1:	55                   	push   %ebp
  801da2:	89 e5                	mov    %esp,%ebp
  801da4:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801da7:	8b 45 08             	mov    0x8(%ebp),%eax
  801daa:	e8 8d ff ff ff       	call   801d3c <fd2sockid>
  801daf:	85 c0                	test   %eax,%eax
  801db1:	78 16                	js     801dc9 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801db3:	8b 55 10             	mov    0x10(%ebp),%edx
  801db6:	89 54 24 08          	mov    %edx,0x8(%esp)
  801dba:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dbd:	89 54 24 04          	mov    %edx,0x4(%esp)
  801dc1:	89 04 24             	mov    %eax,(%esp)
  801dc4:	e8 5b 01 00 00       	call   801f24 <nsipc_bind>
}
  801dc9:	c9                   	leave  
  801dca:	c3                   	ret    

00801dcb <shutdown>:

int
shutdown(int s, int how)
{
  801dcb:	55                   	push   %ebp
  801dcc:	89 e5                	mov    %esp,%ebp
  801dce:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dd1:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd4:	e8 63 ff ff ff       	call   801d3c <fd2sockid>
  801dd9:	85 c0                	test   %eax,%eax
  801ddb:	78 0f                	js     801dec <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801ddd:	8b 55 0c             	mov    0xc(%ebp),%edx
  801de0:	89 54 24 04          	mov    %edx,0x4(%esp)
  801de4:	89 04 24             	mov    %eax,(%esp)
  801de7:	e8 77 01 00 00       	call   801f63 <nsipc_shutdown>
}
  801dec:	c9                   	leave  
  801ded:	c3                   	ret    

00801dee <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801dee:	55                   	push   %ebp
  801def:	89 e5                	mov    %esp,%ebp
  801df1:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801df4:	8b 45 08             	mov    0x8(%ebp),%eax
  801df7:	e8 40 ff ff ff       	call   801d3c <fd2sockid>
  801dfc:	85 c0                	test   %eax,%eax
  801dfe:	78 16                	js     801e16 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801e00:	8b 55 10             	mov    0x10(%ebp),%edx
  801e03:	89 54 24 08          	mov    %edx,0x8(%esp)
  801e07:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e0a:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e0e:	89 04 24             	mov    %eax,(%esp)
  801e11:	e8 89 01 00 00       	call   801f9f <nsipc_connect>
}
  801e16:	c9                   	leave  
  801e17:	c3                   	ret    

00801e18 <listen>:

int
listen(int s, int backlog)
{
  801e18:	55                   	push   %ebp
  801e19:	89 e5                	mov    %esp,%ebp
  801e1b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e1e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e21:	e8 16 ff ff ff       	call   801d3c <fd2sockid>
  801e26:	85 c0                	test   %eax,%eax
  801e28:	78 0f                	js     801e39 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801e2a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e2d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e31:	89 04 24             	mov    %eax,(%esp)
  801e34:	e8 a5 01 00 00       	call   801fde <nsipc_listen>
}
  801e39:	c9                   	leave  
  801e3a:	c3                   	ret    

00801e3b <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801e3b:	55                   	push   %ebp
  801e3c:	89 e5                	mov    %esp,%ebp
  801e3e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801e41:	8b 45 10             	mov    0x10(%ebp),%eax
  801e44:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e48:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e4b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e4f:	8b 45 08             	mov    0x8(%ebp),%eax
  801e52:	89 04 24             	mov    %eax,(%esp)
  801e55:	e8 99 02 00 00       	call   8020f3 <nsipc_socket>
  801e5a:	85 c0                	test   %eax,%eax
  801e5c:	78 05                	js     801e63 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801e5e:	e8 68 fe ff ff       	call   801ccb <alloc_sockfd>
}
  801e63:	c9                   	leave  
  801e64:	c3                   	ret    
  801e65:	00 00                	add    %al,(%eax)
	...

00801e68 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801e68:	55                   	push   %ebp
  801e69:	89 e5                	mov    %esp,%ebp
  801e6b:	53                   	push   %ebx
  801e6c:	83 ec 14             	sub    $0x14,%esp
  801e6f:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801e71:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801e78:	75 11                	jne    801e8b <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801e7a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801e81:	e8 89 08 00 00       	call   80270f <ipc_find_env>
  801e86:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801e8b:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801e92:	00 
  801e93:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801e9a:	00 
  801e9b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e9f:	a1 04 40 80 00       	mov    0x804004,%eax
  801ea4:	89 04 24             	mov    %eax,(%esp)
  801ea7:	e8 f5 07 00 00       	call   8026a1 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801eac:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801eb3:	00 
  801eb4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801ebb:	00 
  801ebc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ec3:	e8 70 07 00 00       	call   802638 <ipc_recv>
}
  801ec8:	83 c4 14             	add    $0x14,%esp
  801ecb:	5b                   	pop    %ebx
  801ecc:	5d                   	pop    %ebp
  801ecd:	c3                   	ret    

00801ece <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ece:	55                   	push   %ebp
  801ecf:	89 e5                	mov    %esp,%ebp
  801ed1:	56                   	push   %esi
  801ed2:	53                   	push   %ebx
  801ed3:	83 ec 10             	sub    $0x10,%esp
  801ed6:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801ed9:	8b 45 08             	mov    0x8(%ebp),%eax
  801edc:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801ee1:	8b 06                	mov    (%esi),%eax
  801ee3:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801ee8:	b8 01 00 00 00       	mov    $0x1,%eax
  801eed:	e8 76 ff ff ff       	call   801e68 <nsipc>
  801ef2:	89 c3                	mov    %eax,%ebx
  801ef4:	85 c0                	test   %eax,%eax
  801ef6:	78 23                	js     801f1b <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801ef8:	a1 10 60 80 00       	mov    0x806010,%eax
  801efd:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f01:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801f08:	00 
  801f09:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f0c:	89 04 24             	mov    %eax,(%esp)
  801f0f:	e8 8c ec ff ff       	call   800ba0 <memmove>
		*addrlen = ret->ret_addrlen;
  801f14:	a1 10 60 80 00       	mov    0x806010,%eax
  801f19:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801f1b:	89 d8                	mov    %ebx,%eax
  801f1d:	83 c4 10             	add    $0x10,%esp
  801f20:	5b                   	pop    %ebx
  801f21:	5e                   	pop    %esi
  801f22:	5d                   	pop    %ebp
  801f23:	c3                   	ret    

00801f24 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801f24:	55                   	push   %ebp
  801f25:	89 e5                	mov    %esp,%ebp
  801f27:	53                   	push   %ebx
  801f28:	83 ec 14             	sub    $0x14,%esp
  801f2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801f2e:	8b 45 08             	mov    0x8(%ebp),%eax
  801f31:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801f36:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f3d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f41:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801f48:	e8 53 ec ff ff       	call   800ba0 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801f4d:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801f53:	b8 02 00 00 00       	mov    $0x2,%eax
  801f58:	e8 0b ff ff ff       	call   801e68 <nsipc>
}
  801f5d:	83 c4 14             	add    $0x14,%esp
  801f60:	5b                   	pop    %ebx
  801f61:	5d                   	pop    %ebp
  801f62:	c3                   	ret    

00801f63 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801f63:	55                   	push   %ebp
  801f64:	89 e5                	mov    %esp,%ebp
  801f66:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801f69:	8b 45 08             	mov    0x8(%ebp),%eax
  801f6c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801f71:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f74:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801f79:	b8 03 00 00 00       	mov    $0x3,%eax
  801f7e:	e8 e5 fe ff ff       	call   801e68 <nsipc>
}
  801f83:	c9                   	leave  
  801f84:	c3                   	ret    

00801f85 <nsipc_close>:

int
nsipc_close(int s)
{
  801f85:	55                   	push   %ebp
  801f86:	89 e5                	mov    %esp,%ebp
  801f88:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801f8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f8e:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801f93:	b8 04 00 00 00       	mov    $0x4,%eax
  801f98:	e8 cb fe ff ff       	call   801e68 <nsipc>
}
  801f9d:	c9                   	leave  
  801f9e:	c3                   	ret    

00801f9f <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801f9f:	55                   	push   %ebp
  801fa0:	89 e5                	mov    %esp,%ebp
  801fa2:	53                   	push   %ebx
  801fa3:	83 ec 14             	sub    $0x14,%esp
  801fa6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801fa9:	8b 45 08             	mov    0x8(%ebp),%eax
  801fac:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801fb1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fb5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fb8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fbc:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801fc3:	e8 d8 eb ff ff       	call   800ba0 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801fc8:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801fce:	b8 05 00 00 00       	mov    $0x5,%eax
  801fd3:	e8 90 fe ff ff       	call   801e68 <nsipc>
}
  801fd8:	83 c4 14             	add    $0x14,%esp
  801fdb:	5b                   	pop    %ebx
  801fdc:	5d                   	pop    %ebp
  801fdd:	c3                   	ret    

00801fde <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801fde:	55                   	push   %ebp
  801fdf:	89 e5                	mov    %esp,%ebp
  801fe1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801fe4:	8b 45 08             	mov    0x8(%ebp),%eax
  801fe7:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801fec:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fef:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801ff4:	b8 06 00 00 00       	mov    $0x6,%eax
  801ff9:	e8 6a fe ff ff       	call   801e68 <nsipc>
}
  801ffe:	c9                   	leave  
  801fff:	c3                   	ret    

00802000 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802000:	55                   	push   %ebp
  802001:	89 e5                	mov    %esp,%ebp
  802003:	56                   	push   %esi
  802004:	53                   	push   %ebx
  802005:	83 ec 10             	sub    $0x10,%esp
  802008:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80200b:	8b 45 08             	mov    0x8(%ebp),%eax
  80200e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  802013:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  802019:	8b 45 14             	mov    0x14(%ebp),%eax
  80201c:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802021:	b8 07 00 00 00       	mov    $0x7,%eax
  802026:	e8 3d fe ff ff       	call   801e68 <nsipc>
  80202b:	89 c3                	mov    %eax,%ebx
  80202d:	85 c0                	test   %eax,%eax
  80202f:	78 46                	js     802077 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  802031:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802036:	7f 04                	jg     80203c <nsipc_recv+0x3c>
  802038:	39 c6                	cmp    %eax,%esi
  80203a:	7d 24                	jge    802060 <nsipc_recv+0x60>
  80203c:	c7 44 24 0c a3 2e 80 	movl   $0x802ea3,0xc(%esp)
  802043:	00 
  802044:	c7 44 24 08 6b 2e 80 	movl   $0x802e6b,0x8(%esp)
  80204b:	00 
  80204c:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  802053:	00 
  802054:	c7 04 24 b8 2e 80 00 	movl   $0x802eb8,(%esp)
  80205b:	e8 24 e3 ff ff       	call   800384 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802060:	89 44 24 08          	mov    %eax,0x8(%esp)
  802064:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80206b:	00 
  80206c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80206f:	89 04 24             	mov    %eax,(%esp)
  802072:	e8 29 eb ff ff       	call   800ba0 <memmove>
	}

	return r;
}
  802077:	89 d8                	mov    %ebx,%eax
  802079:	83 c4 10             	add    $0x10,%esp
  80207c:	5b                   	pop    %ebx
  80207d:	5e                   	pop    %esi
  80207e:	5d                   	pop    %ebp
  80207f:	c3                   	ret    

00802080 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802080:	55                   	push   %ebp
  802081:	89 e5                	mov    %esp,%ebp
  802083:	53                   	push   %ebx
  802084:	83 ec 14             	sub    $0x14,%esp
  802087:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80208a:	8b 45 08             	mov    0x8(%ebp),%eax
  80208d:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  802092:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802098:	7e 24                	jle    8020be <nsipc_send+0x3e>
  80209a:	c7 44 24 0c c4 2e 80 	movl   $0x802ec4,0xc(%esp)
  8020a1:	00 
  8020a2:	c7 44 24 08 6b 2e 80 	movl   $0x802e6b,0x8(%esp)
  8020a9:	00 
  8020aa:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  8020b1:	00 
  8020b2:	c7 04 24 b8 2e 80 00 	movl   $0x802eb8,(%esp)
  8020b9:	e8 c6 e2 ff ff       	call   800384 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8020be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020c9:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  8020d0:	e8 cb ea ff ff       	call   800ba0 <memmove>
	nsipcbuf.send.req_size = size;
  8020d5:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8020db:	8b 45 14             	mov    0x14(%ebp),%eax
  8020de:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8020e3:	b8 08 00 00 00       	mov    $0x8,%eax
  8020e8:	e8 7b fd ff ff       	call   801e68 <nsipc>
}
  8020ed:	83 c4 14             	add    $0x14,%esp
  8020f0:	5b                   	pop    %ebx
  8020f1:	5d                   	pop    %ebp
  8020f2:	c3                   	ret    

008020f3 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8020f3:	55                   	push   %ebp
  8020f4:	89 e5                	mov    %esp,%ebp
  8020f6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8020f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8020fc:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  802101:	8b 45 0c             	mov    0xc(%ebp),%eax
  802104:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  802109:	8b 45 10             	mov    0x10(%ebp),%eax
  80210c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  802111:	b8 09 00 00 00       	mov    $0x9,%eax
  802116:	e8 4d fd ff ff       	call   801e68 <nsipc>
}
  80211b:	c9                   	leave  
  80211c:	c3                   	ret    
  80211d:	00 00                	add    %al,(%eax)
	...

00802120 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802120:	55                   	push   %ebp
  802121:	89 e5                	mov    %esp,%ebp
  802123:	56                   	push   %esi
  802124:	53                   	push   %ebx
  802125:	83 ec 10             	sub    $0x10,%esp
  802128:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80212b:	8b 45 08             	mov    0x8(%ebp),%eax
  80212e:	89 04 24             	mov    %eax,(%esp)
  802131:	e8 36 f1 ff ff       	call   80126c <fd2data>
  802136:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  802138:	c7 44 24 04 d0 2e 80 	movl   $0x802ed0,0x4(%esp)
  80213f:	00 
  802140:	89 34 24             	mov    %esi,(%esp)
  802143:	e8 df e8 ff ff       	call   800a27 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802148:	8b 43 04             	mov    0x4(%ebx),%eax
  80214b:	2b 03                	sub    (%ebx),%eax
  80214d:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  802153:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80215a:	00 00 00 
	stat->st_dev = &devpipe;
  80215d:	c7 86 88 00 00 00 3c 	movl   $0x80303c,0x88(%esi)
  802164:	30 80 00 
	return 0;
}
  802167:	b8 00 00 00 00       	mov    $0x0,%eax
  80216c:	83 c4 10             	add    $0x10,%esp
  80216f:	5b                   	pop    %ebx
  802170:	5e                   	pop    %esi
  802171:	5d                   	pop    %ebp
  802172:	c3                   	ret    

00802173 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802173:	55                   	push   %ebp
  802174:	89 e5                	mov    %esp,%ebp
  802176:	53                   	push   %ebx
  802177:	83 ec 14             	sub    $0x14,%esp
  80217a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80217d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802181:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802188:	e8 33 ed ff ff       	call   800ec0 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80218d:	89 1c 24             	mov    %ebx,(%esp)
  802190:	e8 d7 f0 ff ff       	call   80126c <fd2data>
  802195:	89 44 24 04          	mov    %eax,0x4(%esp)
  802199:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021a0:	e8 1b ed ff ff       	call   800ec0 <sys_page_unmap>
}
  8021a5:	83 c4 14             	add    $0x14,%esp
  8021a8:	5b                   	pop    %ebx
  8021a9:	5d                   	pop    %ebp
  8021aa:	c3                   	ret    

008021ab <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8021ab:	55                   	push   %ebp
  8021ac:	89 e5                	mov    %esp,%ebp
  8021ae:	57                   	push   %edi
  8021af:	56                   	push   %esi
  8021b0:	53                   	push   %ebx
  8021b1:	83 ec 2c             	sub    $0x2c,%esp
  8021b4:	89 c7                	mov    %eax,%edi
  8021b6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8021b9:	a1 20 44 80 00       	mov    0x804420,%eax
  8021be:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8021c1:	89 3c 24             	mov    %edi,(%esp)
  8021c4:	e8 7f 05 00 00       	call   802748 <pageref>
  8021c9:	89 c6                	mov    %eax,%esi
  8021cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8021ce:	89 04 24             	mov    %eax,(%esp)
  8021d1:	e8 72 05 00 00       	call   802748 <pageref>
  8021d6:	39 c6                	cmp    %eax,%esi
  8021d8:	0f 94 c0             	sete   %al
  8021db:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8021de:	8b 15 20 44 80 00    	mov    0x804420,%edx
  8021e4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8021e7:	39 cb                	cmp    %ecx,%ebx
  8021e9:	75 08                	jne    8021f3 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8021eb:	83 c4 2c             	add    $0x2c,%esp
  8021ee:	5b                   	pop    %ebx
  8021ef:	5e                   	pop    %esi
  8021f0:	5f                   	pop    %edi
  8021f1:	5d                   	pop    %ebp
  8021f2:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8021f3:	83 f8 01             	cmp    $0x1,%eax
  8021f6:	75 c1                	jne    8021b9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8021f8:	8b 42 58             	mov    0x58(%edx),%eax
  8021fb:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  802202:	00 
  802203:	89 44 24 08          	mov    %eax,0x8(%esp)
  802207:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80220b:	c7 04 24 d7 2e 80 00 	movl   $0x802ed7,(%esp)
  802212:	e8 65 e2 ff ff       	call   80047c <cprintf>
  802217:	eb a0                	jmp    8021b9 <_pipeisclosed+0xe>

00802219 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802219:	55                   	push   %ebp
  80221a:	89 e5                	mov    %esp,%ebp
  80221c:	57                   	push   %edi
  80221d:	56                   	push   %esi
  80221e:	53                   	push   %ebx
  80221f:	83 ec 1c             	sub    $0x1c,%esp
  802222:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802225:	89 34 24             	mov    %esi,(%esp)
  802228:	e8 3f f0 ff ff       	call   80126c <fd2data>
  80222d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80222f:	bf 00 00 00 00       	mov    $0x0,%edi
  802234:	eb 3c                	jmp    802272 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802236:	89 da                	mov    %ebx,%edx
  802238:	89 f0                	mov    %esi,%eax
  80223a:	e8 6c ff ff ff       	call   8021ab <_pipeisclosed>
  80223f:	85 c0                	test   %eax,%eax
  802241:	75 38                	jne    80227b <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802243:	e8 b2 eb ff ff       	call   800dfa <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802248:	8b 43 04             	mov    0x4(%ebx),%eax
  80224b:	8b 13                	mov    (%ebx),%edx
  80224d:	83 c2 20             	add    $0x20,%edx
  802250:	39 d0                	cmp    %edx,%eax
  802252:	73 e2                	jae    802236 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802254:	8b 55 0c             	mov    0xc(%ebp),%edx
  802257:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  80225a:	89 c2                	mov    %eax,%edx
  80225c:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  802262:	79 05                	jns    802269 <devpipe_write+0x50>
  802264:	4a                   	dec    %edx
  802265:	83 ca e0             	or     $0xffffffe0,%edx
  802268:	42                   	inc    %edx
  802269:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80226d:	40                   	inc    %eax
  80226e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802271:	47                   	inc    %edi
  802272:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802275:	75 d1                	jne    802248 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802277:	89 f8                	mov    %edi,%eax
  802279:	eb 05                	jmp    802280 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80227b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802280:	83 c4 1c             	add    $0x1c,%esp
  802283:	5b                   	pop    %ebx
  802284:	5e                   	pop    %esi
  802285:	5f                   	pop    %edi
  802286:	5d                   	pop    %ebp
  802287:	c3                   	ret    

00802288 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802288:	55                   	push   %ebp
  802289:	89 e5                	mov    %esp,%ebp
  80228b:	57                   	push   %edi
  80228c:	56                   	push   %esi
  80228d:	53                   	push   %ebx
  80228e:	83 ec 1c             	sub    $0x1c,%esp
  802291:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802294:	89 3c 24             	mov    %edi,(%esp)
  802297:	e8 d0 ef ff ff       	call   80126c <fd2data>
  80229c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80229e:	be 00 00 00 00       	mov    $0x0,%esi
  8022a3:	eb 3a                	jmp    8022df <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8022a5:	85 f6                	test   %esi,%esi
  8022a7:	74 04                	je     8022ad <devpipe_read+0x25>
				return i;
  8022a9:	89 f0                	mov    %esi,%eax
  8022ab:	eb 40                	jmp    8022ed <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8022ad:	89 da                	mov    %ebx,%edx
  8022af:	89 f8                	mov    %edi,%eax
  8022b1:	e8 f5 fe ff ff       	call   8021ab <_pipeisclosed>
  8022b6:	85 c0                	test   %eax,%eax
  8022b8:	75 2e                	jne    8022e8 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8022ba:	e8 3b eb ff ff       	call   800dfa <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8022bf:	8b 03                	mov    (%ebx),%eax
  8022c1:	3b 43 04             	cmp    0x4(%ebx),%eax
  8022c4:	74 df                	je     8022a5 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8022c6:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8022cb:	79 05                	jns    8022d2 <devpipe_read+0x4a>
  8022cd:	48                   	dec    %eax
  8022ce:	83 c8 e0             	or     $0xffffffe0,%eax
  8022d1:	40                   	inc    %eax
  8022d2:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8022d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022d9:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8022dc:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022de:	46                   	inc    %esi
  8022df:	3b 75 10             	cmp    0x10(%ebp),%esi
  8022e2:	75 db                	jne    8022bf <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8022e4:	89 f0                	mov    %esi,%eax
  8022e6:	eb 05                	jmp    8022ed <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8022e8:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8022ed:	83 c4 1c             	add    $0x1c,%esp
  8022f0:	5b                   	pop    %ebx
  8022f1:	5e                   	pop    %esi
  8022f2:	5f                   	pop    %edi
  8022f3:	5d                   	pop    %ebp
  8022f4:	c3                   	ret    

008022f5 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8022f5:	55                   	push   %ebp
  8022f6:	89 e5                	mov    %esp,%ebp
  8022f8:	57                   	push   %edi
  8022f9:	56                   	push   %esi
  8022fa:	53                   	push   %ebx
  8022fb:	83 ec 3c             	sub    $0x3c,%esp
  8022fe:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802301:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802304:	89 04 24             	mov    %eax,(%esp)
  802307:	e8 7b ef ff ff       	call   801287 <fd_alloc>
  80230c:	89 c3                	mov    %eax,%ebx
  80230e:	85 c0                	test   %eax,%eax
  802310:	0f 88 45 01 00 00    	js     80245b <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802316:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80231d:	00 
  80231e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802321:	89 44 24 04          	mov    %eax,0x4(%esp)
  802325:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80232c:	e8 e8 ea ff ff       	call   800e19 <sys_page_alloc>
  802331:	89 c3                	mov    %eax,%ebx
  802333:	85 c0                	test   %eax,%eax
  802335:	0f 88 20 01 00 00    	js     80245b <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80233b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80233e:	89 04 24             	mov    %eax,(%esp)
  802341:	e8 41 ef ff ff       	call   801287 <fd_alloc>
  802346:	89 c3                	mov    %eax,%ebx
  802348:	85 c0                	test   %eax,%eax
  80234a:	0f 88 f8 00 00 00    	js     802448 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802350:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802357:	00 
  802358:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80235b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80235f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802366:	e8 ae ea ff ff       	call   800e19 <sys_page_alloc>
  80236b:	89 c3                	mov    %eax,%ebx
  80236d:	85 c0                	test   %eax,%eax
  80236f:	0f 88 d3 00 00 00    	js     802448 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802375:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802378:	89 04 24             	mov    %eax,(%esp)
  80237b:	e8 ec ee ff ff       	call   80126c <fd2data>
  802380:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802382:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802389:	00 
  80238a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80238e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802395:	e8 7f ea ff ff       	call   800e19 <sys_page_alloc>
  80239a:	89 c3                	mov    %eax,%ebx
  80239c:	85 c0                	test   %eax,%eax
  80239e:	0f 88 91 00 00 00    	js     802435 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8023a7:	89 04 24             	mov    %eax,(%esp)
  8023aa:	e8 bd ee ff ff       	call   80126c <fd2data>
  8023af:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8023b6:	00 
  8023b7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023bb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8023c2:	00 
  8023c3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023ce:	e8 9a ea ff ff       	call   800e6d <sys_page_map>
  8023d3:	89 c3                	mov    %eax,%ebx
  8023d5:	85 c0                	test   %eax,%eax
  8023d7:	78 4c                	js     802425 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8023d9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8023df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8023e2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8023e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8023e7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8023ee:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8023f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8023f7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8023f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8023fc:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802403:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802406:	89 04 24             	mov    %eax,(%esp)
  802409:	e8 4e ee ff ff       	call   80125c <fd2num>
  80240e:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802410:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802413:	89 04 24             	mov    %eax,(%esp)
  802416:	e8 41 ee ff ff       	call   80125c <fd2num>
  80241b:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  80241e:	bb 00 00 00 00       	mov    $0x0,%ebx
  802423:	eb 36                	jmp    80245b <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  802425:	89 74 24 04          	mov    %esi,0x4(%esp)
  802429:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802430:	e8 8b ea ff ff       	call   800ec0 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802435:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802438:	89 44 24 04          	mov    %eax,0x4(%esp)
  80243c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802443:	e8 78 ea ff ff       	call   800ec0 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802448:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80244b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80244f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802456:	e8 65 ea ff ff       	call   800ec0 <sys_page_unmap>
    err:
	return r;
}
  80245b:	89 d8                	mov    %ebx,%eax
  80245d:	83 c4 3c             	add    $0x3c,%esp
  802460:	5b                   	pop    %ebx
  802461:	5e                   	pop    %esi
  802462:	5f                   	pop    %edi
  802463:	5d                   	pop    %ebp
  802464:	c3                   	ret    

00802465 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802465:	55                   	push   %ebp
  802466:	89 e5                	mov    %esp,%ebp
  802468:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80246b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80246e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802472:	8b 45 08             	mov    0x8(%ebp),%eax
  802475:	89 04 24             	mov    %eax,(%esp)
  802478:	e8 5d ee ff ff       	call   8012da <fd_lookup>
  80247d:	85 c0                	test   %eax,%eax
  80247f:	78 15                	js     802496 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802481:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802484:	89 04 24             	mov    %eax,(%esp)
  802487:	e8 e0 ed ff ff       	call   80126c <fd2data>
	return _pipeisclosed(fd, p);
  80248c:	89 c2                	mov    %eax,%edx
  80248e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802491:	e8 15 fd ff ff       	call   8021ab <_pipeisclosed>
}
  802496:	c9                   	leave  
  802497:	c3                   	ret    

00802498 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802498:	55                   	push   %ebp
  802499:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80249b:	b8 00 00 00 00       	mov    $0x0,%eax
  8024a0:	5d                   	pop    %ebp
  8024a1:	c3                   	ret    

008024a2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8024a2:	55                   	push   %ebp
  8024a3:	89 e5                	mov    %esp,%ebp
  8024a5:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8024a8:	c7 44 24 04 ef 2e 80 	movl   $0x802eef,0x4(%esp)
  8024af:	00 
  8024b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024b3:	89 04 24             	mov    %eax,(%esp)
  8024b6:	e8 6c e5 ff ff       	call   800a27 <strcpy>
	return 0;
}
  8024bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8024c0:	c9                   	leave  
  8024c1:	c3                   	ret    

008024c2 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8024c2:	55                   	push   %ebp
  8024c3:	89 e5                	mov    %esp,%ebp
  8024c5:	57                   	push   %edi
  8024c6:	56                   	push   %esi
  8024c7:	53                   	push   %ebx
  8024c8:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8024ce:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8024d3:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8024d9:	eb 30                	jmp    80250b <devcons_write+0x49>
		m = n - tot;
  8024db:	8b 75 10             	mov    0x10(%ebp),%esi
  8024de:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8024e0:	83 fe 7f             	cmp    $0x7f,%esi
  8024e3:	76 05                	jbe    8024ea <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8024e5:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8024ea:	89 74 24 08          	mov    %esi,0x8(%esp)
  8024ee:	03 45 0c             	add    0xc(%ebp),%eax
  8024f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024f5:	89 3c 24             	mov    %edi,(%esp)
  8024f8:	e8 a3 e6 ff ff       	call   800ba0 <memmove>
		sys_cputs(buf, m);
  8024fd:	89 74 24 04          	mov    %esi,0x4(%esp)
  802501:	89 3c 24             	mov    %edi,(%esp)
  802504:	e8 43 e8 ff ff       	call   800d4c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802509:	01 f3                	add    %esi,%ebx
  80250b:	89 d8                	mov    %ebx,%eax
  80250d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802510:	72 c9                	jb     8024db <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802512:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802518:	5b                   	pop    %ebx
  802519:	5e                   	pop    %esi
  80251a:	5f                   	pop    %edi
  80251b:	5d                   	pop    %ebp
  80251c:	c3                   	ret    

0080251d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80251d:	55                   	push   %ebp
  80251e:	89 e5                	mov    %esp,%ebp
  802520:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  802523:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802527:	75 07                	jne    802530 <devcons_read+0x13>
  802529:	eb 25                	jmp    802550 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80252b:	e8 ca e8 ff ff       	call   800dfa <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802530:	e8 35 e8 ff ff       	call   800d6a <sys_cgetc>
  802535:	85 c0                	test   %eax,%eax
  802537:	74 f2                	je     80252b <devcons_read+0xe>
  802539:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80253b:	85 c0                	test   %eax,%eax
  80253d:	78 1d                	js     80255c <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80253f:	83 f8 04             	cmp    $0x4,%eax
  802542:	74 13                	je     802557 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802544:	8b 45 0c             	mov    0xc(%ebp),%eax
  802547:	88 10                	mov    %dl,(%eax)
	return 1;
  802549:	b8 01 00 00 00       	mov    $0x1,%eax
  80254e:	eb 0c                	jmp    80255c <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802550:	b8 00 00 00 00       	mov    $0x0,%eax
  802555:	eb 05                	jmp    80255c <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802557:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80255c:	c9                   	leave  
  80255d:	c3                   	ret    

0080255e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80255e:	55                   	push   %ebp
  80255f:	89 e5                	mov    %esp,%ebp
  802561:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802564:	8b 45 08             	mov    0x8(%ebp),%eax
  802567:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80256a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802571:	00 
  802572:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802575:	89 04 24             	mov    %eax,(%esp)
  802578:	e8 cf e7 ff ff       	call   800d4c <sys_cputs>
}
  80257d:	c9                   	leave  
  80257e:	c3                   	ret    

0080257f <getchar>:

int
getchar(void)
{
  80257f:	55                   	push   %ebp
  802580:	89 e5                	mov    %esp,%ebp
  802582:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802585:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  80258c:	00 
  80258d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802590:	89 44 24 04          	mov    %eax,0x4(%esp)
  802594:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80259b:	e8 d6 ef ff ff       	call   801576 <read>
	if (r < 0)
  8025a0:	85 c0                	test   %eax,%eax
  8025a2:	78 0f                	js     8025b3 <getchar+0x34>
		return r;
	if (r < 1)
  8025a4:	85 c0                	test   %eax,%eax
  8025a6:	7e 06                	jle    8025ae <getchar+0x2f>
		return -E_EOF;
	return c;
  8025a8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8025ac:	eb 05                	jmp    8025b3 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8025ae:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8025b3:	c9                   	leave  
  8025b4:	c3                   	ret    

008025b5 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8025b5:	55                   	push   %ebp
  8025b6:	89 e5                	mov    %esp,%ebp
  8025b8:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8025bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8025c5:	89 04 24             	mov    %eax,(%esp)
  8025c8:	e8 0d ed ff ff       	call   8012da <fd_lookup>
  8025cd:	85 c0                	test   %eax,%eax
  8025cf:	78 11                	js     8025e2 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8025d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025d4:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8025da:	39 10                	cmp    %edx,(%eax)
  8025dc:	0f 94 c0             	sete   %al
  8025df:	0f b6 c0             	movzbl %al,%eax
}
  8025e2:	c9                   	leave  
  8025e3:	c3                   	ret    

008025e4 <opencons>:

int
opencons(void)
{
  8025e4:	55                   	push   %ebp
  8025e5:	89 e5                	mov    %esp,%ebp
  8025e7:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8025ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025ed:	89 04 24             	mov    %eax,(%esp)
  8025f0:	e8 92 ec ff ff       	call   801287 <fd_alloc>
  8025f5:	85 c0                	test   %eax,%eax
  8025f7:	78 3c                	js     802635 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8025f9:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802600:	00 
  802601:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802604:	89 44 24 04          	mov    %eax,0x4(%esp)
  802608:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80260f:	e8 05 e8 ff ff       	call   800e19 <sys_page_alloc>
  802614:	85 c0                	test   %eax,%eax
  802616:	78 1d                	js     802635 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802618:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80261e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802621:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802623:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802626:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80262d:	89 04 24             	mov    %eax,(%esp)
  802630:	e8 27 ec ff ff       	call   80125c <fd2num>
}
  802635:	c9                   	leave  
  802636:	c3                   	ret    
	...

00802638 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802638:	55                   	push   %ebp
  802639:	89 e5                	mov    %esp,%ebp
  80263b:	56                   	push   %esi
  80263c:	53                   	push   %ebx
  80263d:	83 ec 10             	sub    $0x10,%esp
  802640:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802643:	8b 45 0c             	mov    0xc(%ebp),%eax
  802646:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int r;
		
	r = sys_ipc_recv(pg?pg:(void*)UTOP);
  802649:	85 c0                	test   %eax,%eax
  80264b:	75 05                	jne    802652 <ipc_recv+0x1a>
  80264d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802652:	89 04 24             	mov    %eax,(%esp)
  802655:	e8 d5 e9 ff ff       	call   80102f <sys_ipc_recv>
	if (from_env_store != NULL)
  80265a:	85 db                	test   %ebx,%ebx
  80265c:	74 0b                	je     802669 <ipc_recv+0x31>
		*from_env_store = thisenv->env_ipc_from; 
  80265e:	8b 15 20 44 80 00    	mov    0x804420,%edx
  802664:	8b 52 74             	mov    0x74(%edx),%edx
  802667:	89 13                	mov    %edx,(%ebx)
	if (perm_store != NULL)
  802669:	85 f6                	test   %esi,%esi
  80266b:	74 0b                	je     802678 <ipc_recv+0x40>
		*perm_store = thisenv->env_ipc_perm;
  80266d:	8b 15 20 44 80 00    	mov    0x804420,%edx
  802673:	8b 52 78             	mov    0x78(%edx),%edx
  802676:	89 16                	mov    %edx,(%esi)
	
	if (r < 0){
  802678:	85 c0                	test   %eax,%eax
  80267a:	79 16                	jns    802692 <ipc_recv+0x5a>
		if(from_env_store != NULL)
  80267c:	85 db                	test   %ebx,%ebx
  80267e:	74 06                	je     802686 <ipc_recv+0x4e>
			*from_env_store = 0;
  802680:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store != NULL)	
  802686:	85 f6                	test   %esi,%esi
  802688:	74 10                	je     80269a <ipc_recv+0x62>
			*perm_store = 0;
  80268a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  802690:	eb 08                	jmp    80269a <ipc_recv+0x62>
		return r;
	}
	
	return thisenv->env_ipc_value;
  802692:	a1 20 44 80 00       	mov    0x804420,%eax
  802697:	8b 40 70             	mov    0x70(%eax),%eax
}
  80269a:	83 c4 10             	add    $0x10,%esp
  80269d:	5b                   	pop    %ebx
  80269e:	5e                   	pop    %esi
  80269f:	5d                   	pop    %ebp
  8026a0:	c3                   	ret    

008026a1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8026a1:	55                   	push   %ebp
  8026a2:	89 e5                	mov    %esp,%ebp
  8026a4:	57                   	push   %edi
  8026a5:	56                   	push   %esi
  8026a6:	53                   	push   %ebx
  8026a7:	83 ec 1c             	sub    $0x1c,%esp
  8026aa:	8b 75 08             	mov    0x8(%ebp),%esi
  8026ad:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8026b0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  8026b3:	eb 2a                	jmp    8026df <ipc_send+0x3e>
		if (r != -E_IPC_NOT_RECV)
  8026b5:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8026b8:	74 20                	je     8026da <ipc_send+0x39>
			panic("ipc_send: sys_ipc_try_send failed %e", r);
  8026ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8026be:	c7 44 24 08 fc 2e 80 	movl   $0x802efc,0x8(%esp)
  8026c5:	00 
  8026c6:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  8026cd:	00 
  8026ce:	c7 04 24 24 2f 80 00 	movl   $0x802f24,(%esp)
  8026d5:	e8 aa dc ff ff       	call   800384 <_panic>
		sys_yield();
  8026da:	e8 1b e7 ff ff       	call   800dfa <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  8026df:	85 db                	test   %ebx,%ebx
  8026e1:	75 07                	jne    8026ea <ipc_send+0x49>
  8026e3:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8026e8:	eb 02                	jmp    8026ec <ipc_send+0x4b>
  8026ea:	89 d8                	mov    %ebx,%eax
  8026ec:	8b 55 14             	mov    0x14(%ebp),%edx
  8026ef:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8026f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8026f7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8026fb:	89 34 24             	mov    %esi,(%esp)
  8026fe:	e8 09 e9 ff ff       	call   80100c <sys_ipc_try_send>
  802703:	85 c0                	test   %eax,%eax
  802705:	78 ae                	js     8026b5 <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: sys_ipc_try_send failed %e", r);
		sys_yield();
	}
}
  802707:	83 c4 1c             	add    $0x1c,%esp
  80270a:	5b                   	pop    %ebx
  80270b:	5e                   	pop    %esi
  80270c:	5f                   	pop    %edi
  80270d:	5d                   	pop    %ebp
  80270e:	c3                   	ret    

0080270f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80270f:	55                   	push   %ebp
  802710:	89 e5                	mov    %esp,%ebp
  802712:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802715:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80271a:	89 c2                	mov    %eax,%edx
  80271c:	c1 e2 07             	shl    $0x7,%edx
  80271f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802725:	8b 52 50             	mov    0x50(%edx),%edx
  802728:	39 ca                	cmp    %ecx,%edx
  80272a:	75 0d                	jne    802739 <ipc_find_env+0x2a>
			return envs[i].env_id;
  80272c:	c1 e0 07             	shl    $0x7,%eax
  80272f:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802734:	8b 40 40             	mov    0x40(%eax),%eax
  802737:	eb 0c                	jmp    802745 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802739:	40                   	inc    %eax
  80273a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80273f:	75 d9                	jne    80271a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802741:	66 b8 00 00          	mov    $0x0,%ax
}
  802745:	5d                   	pop    %ebp
  802746:	c3                   	ret    
	...

00802748 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802748:	55                   	push   %ebp
  802749:	89 e5                	mov    %esp,%ebp
  80274b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80274e:	89 c2                	mov    %eax,%edx
  802750:	c1 ea 16             	shr    $0x16,%edx
  802753:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80275a:	f6 c2 01             	test   $0x1,%dl
  80275d:	74 1e                	je     80277d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  80275f:	c1 e8 0c             	shr    $0xc,%eax
  802762:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802769:	a8 01                	test   $0x1,%al
  80276b:	74 17                	je     802784 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80276d:	c1 e8 0c             	shr    $0xc,%eax
  802770:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802777:	ef 
  802778:	0f b7 c0             	movzwl %ax,%eax
  80277b:	eb 0c                	jmp    802789 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  80277d:	b8 00 00 00 00       	mov    $0x0,%eax
  802782:	eb 05                	jmp    802789 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802784:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802789:	5d                   	pop    %ebp
  80278a:	c3                   	ret    
	...

0080278c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  80278c:	55                   	push   %ebp
  80278d:	57                   	push   %edi
  80278e:	56                   	push   %esi
  80278f:	83 ec 10             	sub    $0x10,%esp
  802792:	8b 74 24 20          	mov    0x20(%esp),%esi
  802796:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80279a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80279e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  8027a2:	89 cd                	mov    %ecx,%ebp
  8027a4:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8027a8:	85 c0                	test   %eax,%eax
  8027aa:	75 2c                	jne    8027d8 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8027ac:	39 f9                	cmp    %edi,%ecx
  8027ae:	77 68                	ja     802818 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8027b0:	85 c9                	test   %ecx,%ecx
  8027b2:	75 0b                	jne    8027bf <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8027b4:	b8 01 00 00 00       	mov    $0x1,%eax
  8027b9:	31 d2                	xor    %edx,%edx
  8027bb:	f7 f1                	div    %ecx
  8027bd:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8027bf:	31 d2                	xor    %edx,%edx
  8027c1:	89 f8                	mov    %edi,%eax
  8027c3:	f7 f1                	div    %ecx
  8027c5:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8027c7:	89 f0                	mov    %esi,%eax
  8027c9:	f7 f1                	div    %ecx
  8027cb:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8027cd:	89 f0                	mov    %esi,%eax
  8027cf:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8027d1:	83 c4 10             	add    $0x10,%esp
  8027d4:	5e                   	pop    %esi
  8027d5:	5f                   	pop    %edi
  8027d6:	5d                   	pop    %ebp
  8027d7:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8027d8:	39 f8                	cmp    %edi,%eax
  8027da:	77 2c                	ja     802808 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8027dc:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  8027df:	83 f6 1f             	xor    $0x1f,%esi
  8027e2:	75 4c                	jne    802830 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8027e4:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8027e6:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8027eb:	72 0a                	jb     8027f7 <__udivdi3+0x6b>
  8027ed:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8027f1:	0f 87 ad 00 00 00    	ja     8028a4 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8027f7:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8027fc:	89 f0                	mov    %esi,%eax
  8027fe:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802800:	83 c4 10             	add    $0x10,%esp
  802803:	5e                   	pop    %esi
  802804:	5f                   	pop    %edi
  802805:	5d                   	pop    %ebp
  802806:	c3                   	ret    
  802807:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802808:	31 ff                	xor    %edi,%edi
  80280a:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80280c:	89 f0                	mov    %esi,%eax
  80280e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802810:	83 c4 10             	add    $0x10,%esp
  802813:	5e                   	pop    %esi
  802814:	5f                   	pop    %edi
  802815:	5d                   	pop    %ebp
  802816:	c3                   	ret    
  802817:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802818:	89 fa                	mov    %edi,%edx
  80281a:	89 f0                	mov    %esi,%eax
  80281c:	f7 f1                	div    %ecx
  80281e:	89 c6                	mov    %eax,%esi
  802820:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802822:	89 f0                	mov    %esi,%eax
  802824:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802826:	83 c4 10             	add    $0x10,%esp
  802829:	5e                   	pop    %esi
  80282a:	5f                   	pop    %edi
  80282b:	5d                   	pop    %ebp
  80282c:	c3                   	ret    
  80282d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802830:	89 f1                	mov    %esi,%ecx
  802832:	d3 e0                	shl    %cl,%eax
  802834:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802838:	b8 20 00 00 00       	mov    $0x20,%eax
  80283d:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80283f:	89 ea                	mov    %ebp,%edx
  802841:	88 c1                	mov    %al,%cl
  802843:	d3 ea                	shr    %cl,%edx
  802845:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802849:	09 ca                	or     %ecx,%edx
  80284b:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  80284f:	89 f1                	mov    %esi,%ecx
  802851:	d3 e5                	shl    %cl,%ebp
  802853:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  802857:	89 fd                	mov    %edi,%ebp
  802859:	88 c1                	mov    %al,%cl
  80285b:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  80285d:	89 fa                	mov    %edi,%edx
  80285f:	89 f1                	mov    %esi,%ecx
  802861:	d3 e2                	shl    %cl,%edx
  802863:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802867:	88 c1                	mov    %al,%cl
  802869:	d3 ef                	shr    %cl,%edi
  80286b:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80286d:	89 f8                	mov    %edi,%eax
  80286f:	89 ea                	mov    %ebp,%edx
  802871:	f7 74 24 08          	divl   0x8(%esp)
  802875:	89 d1                	mov    %edx,%ecx
  802877:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802879:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80287d:	39 d1                	cmp    %edx,%ecx
  80287f:	72 17                	jb     802898 <__udivdi3+0x10c>
  802881:	74 09                	je     80288c <__udivdi3+0x100>
  802883:	89 fe                	mov    %edi,%esi
  802885:	31 ff                	xor    %edi,%edi
  802887:	e9 41 ff ff ff       	jmp    8027cd <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  80288c:	8b 54 24 04          	mov    0x4(%esp),%edx
  802890:	89 f1                	mov    %esi,%ecx
  802892:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802894:	39 c2                	cmp    %eax,%edx
  802896:	73 eb                	jae    802883 <__udivdi3+0xf7>
		{
		  q0--;
  802898:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80289b:	31 ff                	xor    %edi,%edi
  80289d:	e9 2b ff ff ff       	jmp    8027cd <__udivdi3+0x41>
  8028a2:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8028a4:	31 f6                	xor    %esi,%esi
  8028a6:	e9 22 ff ff ff       	jmp    8027cd <__udivdi3+0x41>
	...

008028ac <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8028ac:	55                   	push   %ebp
  8028ad:	57                   	push   %edi
  8028ae:	56                   	push   %esi
  8028af:	83 ec 20             	sub    $0x20,%esp
  8028b2:	8b 44 24 30          	mov    0x30(%esp),%eax
  8028b6:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8028ba:	89 44 24 14          	mov    %eax,0x14(%esp)
  8028be:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  8028c2:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8028c6:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8028ca:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  8028cc:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8028ce:	85 ed                	test   %ebp,%ebp
  8028d0:	75 16                	jne    8028e8 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  8028d2:	39 f1                	cmp    %esi,%ecx
  8028d4:	0f 86 a6 00 00 00    	jbe    802980 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8028da:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8028dc:	89 d0                	mov    %edx,%eax
  8028de:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8028e0:	83 c4 20             	add    $0x20,%esp
  8028e3:	5e                   	pop    %esi
  8028e4:	5f                   	pop    %edi
  8028e5:	5d                   	pop    %ebp
  8028e6:	c3                   	ret    
  8028e7:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8028e8:	39 f5                	cmp    %esi,%ebp
  8028ea:	0f 87 ac 00 00 00    	ja     80299c <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8028f0:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  8028f3:	83 f0 1f             	xor    $0x1f,%eax
  8028f6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8028fa:	0f 84 a8 00 00 00    	je     8029a8 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802900:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802904:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802906:	bf 20 00 00 00       	mov    $0x20,%edi
  80290b:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80290f:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802913:	89 f9                	mov    %edi,%ecx
  802915:	d3 e8                	shr    %cl,%eax
  802917:	09 e8                	or     %ebp,%eax
  802919:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  80291d:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802921:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802925:	d3 e0                	shl    %cl,%eax
  802927:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80292b:	89 f2                	mov    %esi,%edx
  80292d:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80292f:	8b 44 24 14          	mov    0x14(%esp),%eax
  802933:	d3 e0                	shl    %cl,%eax
  802935:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802939:	8b 44 24 14          	mov    0x14(%esp),%eax
  80293d:	89 f9                	mov    %edi,%ecx
  80293f:	d3 e8                	shr    %cl,%eax
  802941:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802943:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802945:	89 f2                	mov    %esi,%edx
  802947:	f7 74 24 18          	divl   0x18(%esp)
  80294b:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80294d:	f7 64 24 0c          	mull   0xc(%esp)
  802951:	89 c5                	mov    %eax,%ebp
  802953:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802955:	39 d6                	cmp    %edx,%esi
  802957:	72 67                	jb     8029c0 <__umoddi3+0x114>
  802959:	74 75                	je     8029d0 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80295b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80295f:	29 e8                	sub    %ebp,%eax
  802961:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802963:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802967:	d3 e8                	shr    %cl,%eax
  802969:	89 f2                	mov    %esi,%edx
  80296b:	89 f9                	mov    %edi,%ecx
  80296d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80296f:	09 d0                	or     %edx,%eax
  802971:	89 f2                	mov    %esi,%edx
  802973:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802977:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802979:	83 c4 20             	add    $0x20,%esp
  80297c:	5e                   	pop    %esi
  80297d:	5f                   	pop    %edi
  80297e:	5d                   	pop    %ebp
  80297f:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802980:	85 c9                	test   %ecx,%ecx
  802982:	75 0b                	jne    80298f <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802984:	b8 01 00 00 00       	mov    $0x1,%eax
  802989:	31 d2                	xor    %edx,%edx
  80298b:	f7 f1                	div    %ecx
  80298d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80298f:	89 f0                	mov    %esi,%eax
  802991:	31 d2                	xor    %edx,%edx
  802993:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802995:	89 f8                	mov    %edi,%eax
  802997:	e9 3e ff ff ff       	jmp    8028da <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  80299c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80299e:	83 c4 20             	add    $0x20,%esp
  8029a1:	5e                   	pop    %esi
  8029a2:	5f                   	pop    %edi
  8029a3:	5d                   	pop    %ebp
  8029a4:	c3                   	ret    
  8029a5:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8029a8:	39 f5                	cmp    %esi,%ebp
  8029aa:	72 04                	jb     8029b0 <__umoddi3+0x104>
  8029ac:	39 f9                	cmp    %edi,%ecx
  8029ae:	77 06                	ja     8029b6 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8029b0:	89 f2                	mov    %esi,%edx
  8029b2:	29 cf                	sub    %ecx,%edi
  8029b4:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8029b6:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8029b8:	83 c4 20             	add    $0x20,%esp
  8029bb:	5e                   	pop    %esi
  8029bc:	5f                   	pop    %edi
  8029bd:	5d                   	pop    %ebp
  8029be:	c3                   	ret    
  8029bf:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8029c0:	89 d1                	mov    %edx,%ecx
  8029c2:	89 c5                	mov    %eax,%ebp
  8029c4:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8029c8:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8029cc:	eb 8d                	jmp    80295b <__umoddi3+0xaf>
  8029ce:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8029d0:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8029d4:	72 ea                	jb     8029c0 <__umoddi3+0x114>
  8029d6:	89 f1                	mov    %esi,%ecx
  8029d8:	eb 81                	jmp    80295b <__umoddi3+0xaf>
