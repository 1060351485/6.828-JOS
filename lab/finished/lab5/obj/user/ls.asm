
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
  800062:	c7 04 24 82 24 80 00 	movl   $0x802482,(%esp)
  800069:	e8 1f 1b 00 00       	call   801b8d <printf>
	if(prefix) {
  80006e:	85 db                	test   %ebx,%ebx
  800070:	74 3b                	je     8000ad <ls1+0x79>
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
  800072:	80 3b 00             	cmpb   $0x0,(%ebx)
  800075:	74 16                	je     80008d <ls1+0x59>
  800077:	89 1c 24             	mov    %ebx,(%esp)
  80007a:	e8 81 09 00 00       	call   800a00 <strlen>
  80007f:	80 7c 03 ff 2f       	cmpb   $0x2f,-0x1(%ebx,%eax,1)
  800084:	74 0e                	je     800094 <ls1+0x60>
			sep = "/";
  800086:	b8 80 24 80 00       	mov    $0x802480,%eax
  80008b:	eb 0c                	jmp    800099 <ls1+0x65>
		else
			sep = "";
  80008d:	b8 e8 24 80 00       	mov    $0x8024e8,%eax
  800092:	eb 05                	jmp    800099 <ls1+0x65>
  800094:	b8 e8 24 80 00       	mov    $0x8024e8,%eax
		printf("%s%s", prefix, sep);
  800099:	89 44 24 08          	mov    %eax,0x8(%esp)
  80009d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000a1:	c7 04 24 8b 24 80 00 	movl   $0x80248b,(%esp)
  8000a8:	e8 e0 1a 00 00       	call   801b8d <printf>
	}
	printf("%s", name);
  8000ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8000b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b4:	c7 04 24 11 29 80 00 	movl   $0x802911,(%esp)
  8000bb:	e8 cd 1a 00 00       	call   801b8d <printf>
	if(flag['F'] && isdir)
  8000c0:	83 3d 38 41 80 00 00 	cmpl   $0x0,0x804138
  8000c7:	74 12                	je     8000db <ls1+0xa7>
  8000c9:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  8000cd:	74 0c                	je     8000db <ls1+0xa7>
		printf("/");
  8000cf:	c7 04 24 80 24 80 00 	movl   $0x802480,(%esp)
  8000d6:	e8 b2 1a 00 00       	call   801b8d <printf>
	printf("\n");
  8000db:	c7 04 24 e7 24 80 00 	movl   $0x8024e7,(%esp)
  8000e2:	e8 a6 1a 00 00       	call   801b8d <printf>
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
  80010a:	e8 c9 18 00 00       	call   8019d8 <open>
  80010f:	89 c6                	mov    %eax,%esi
  800111:	85 c0                	test   %eax,%eax
  800113:	79 59                	jns    80016e <lsdir+0x81>
		panic("open %s: %e", path, fd);
  800115:	89 44 24 10          	mov    %eax,0x10(%esp)
  800119:	8b 45 08             	mov    0x8(%ebp),%eax
  80011c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800120:	c7 44 24 08 90 24 80 	movl   $0x802490,0x8(%esp)
  800127:	00 
  800128:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  80012f:	00 
  800130:	c7 04 24 9c 24 80 00 	movl   $0x80249c,(%esp)
  800137:	e8 54 02 00 00       	call   800390 <_panic>
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
  800183:	e8 0a 14 00 00       	call   801592 <readn>
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
  80019a:	c7 44 24 08 a6 24 80 	movl   $0x8024a6,0x8(%esp)
  8001a1:	00 
  8001a2:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8001a9:	00 
  8001aa:	c7 04 24 9c 24 80 00 	movl   $0x80249c,(%esp)
  8001b1:	e8 da 01 00 00       	call   800390 <_panic>
	if (n < 0)
  8001b6:	85 c0                	test   %eax,%eax
  8001b8:	79 27                	jns    8001e1 <lsdir+0xf4>
		panic("error reading directory %s: %e", path, n);
  8001ba:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001be:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001c5:	c7 44 24 08 ec 24 80 	movl   $0x8024ec,0x8(%esp)
  8001cc:	00 
  8001cd:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  8001d4:	00 
  8001d5:	c7 04 24 9c 24 80 00 	movl   $0x80249c,(%esp)
  8001dc:	e8 af 01 00 00       	call   800390 <_panic>
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
  800206:	e8 85 15 00 00       	call   801790 <stat>
  80020b:	85 c0                	test   %eax,%eax
  80020d:	79 24                	jns    800233 <ls+0x47>
		panic("stat %s: %e", path, r);
  80020f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800213:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800217:	c7 44 24 08 c1 24 80 	movl   $0x8024c1,0x8(%esp)
  80021e:	00 
  80021f:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  800226:	00 
  800227:	c7 04 24 9c 24 80 00 	movl   $0x80249c,(%esp)
  80022e:	e8 5d 01 00 00       	call   800390 <_panic>
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
  800286:	c7 04 24 cd 24 80 00 	movl   $0x8024cd,(%esp)
  80028d:	e8 fb 18 00 00       	call   801b8d <printf>
	exit();
  800292:	e8 e5 00 00 00       	call   80037c <exit>
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
  8002b5:	e8 d6 0d 00 00       	call   801090 <argstart>
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
  8002df:	e8 e5 0d 00 00       	call   8010c9 <argnext>
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
  8002ee:	c7 44 24 04 e8 24 80 	movl   $0x8024e8,0x4(%esp)
  8002f5:	00 
  8002f6:	c7 04 24 80 24 80 00 	movl   $0x802480,(%esp)
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
  800336:	e8 ac 0a 00 00       	call   800de7 <sys_getenvid>
  80033b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800340:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800347:	c1 e0 07             	shl    $0x7,%eax
  80034a:	29 d0                	sub    %edx,%eax
  80034c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800351:	a3 20 44 80 00       	mov    %eax,0x804420

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800356:	85 f6                	test   %esi,%esi
  800358:	7e 07                	jle    800361 <libmain+0x39>
		binaryname = argv[0];
  80035a:	8b 03                	mov    (%ebx),%eax
  80035c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800361:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800365:	89 34 24             	mov    %esi,(%esp)
  800368:	e8 2c ff ff ff       	call   800299 <umain>

	// exit gracefully
	exit();
  80036d:	e8 0a 00 00 00       	call   80037c <exit>
}
  800372:	83 c4 10             	add    $0x10,%esp
  800375:	5b                   	pop    %ebx
  800376:	5e                   	pop    %esi
  800377:	5d                   	pop    %ebp
  800378:	c3                   	ret    
  800379:	00 00                	add    %al,(%eax)
	...

0080037c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80037c:	55                   	push   %ebp
  80037d:	89 e5                	mov    %esp,%ebp
  80037f:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  800382:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800389:	e8 07 0a 00 00       	call   800d95 <sys_env_destroy>
}
  80038e:	c9                   	leave  
  80038f:	c3                   	ret    

00800390 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800390:	55                   	push   %ebp
  800391:	89 e5                	mov    %esp,%ebp
  800393:	56                   	push   %esi
  800394:	53                   	push   %ebx
  800395:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800398:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80039b:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8003a1:	e8 41 0a 00 00       	call   800de7 <sys_getenvid>
  8003a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003a9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003b4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003bc:	c7 04 24 18 25 80 00 	movl   $0x802518,(%esp)
  8003c3:	e8 c0 00 00 00       	call   800488 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003c8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003cc:	8b 45 10             	mov    0x10(%ebp),%eax
  8003cf:	89 04 24             	mov    %eax,(%esp)
  8003d2:	e8 50 00 00 00       	call   800427 <vcprintf>
	cprintf("\n");
  8003d7:	c7 04 24 e7 24 80 00 	movl   $0x8024e7,(%esp)
  8003de:	e8 a5 00 00 00       	call   800488 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003e3:	cc                   	int3   
  8003e4:	eb fd                	jmp    8003e3 <_panic+0x53>
	...

008003e8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003e8:	55                   	push   %ebp
  8003e9:	89 e5                	mov    %esp,%ebp
  8003eb:	53                   	push   %ebx
  8003ec:	83 ec 14             	sub    $0x14,%esp
  8003ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003f2:	8b 03                	mov    (%ebx),%eax
  8003f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8003f7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8003fb:	40                   	inc    %eax
  8003fc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8003fe:	3d ff 00 00 00       	cmp    $0xff,%eax
  800403:	75 19                	jne    80041e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800405:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80040c:	00 
  80040d:	8d 43 08             	lea    0x8(%ebx),%eax
  800410:	89 04 24             	mov    %eax,(%esp)
  800413:	e8 40 09 00 00       	call   800d58 <sys_cputs>
		b->idx = 0;
  800418:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80041e:	ff 43 04             	incl   0x4(%ebx)
}
  800421:	83 c4 14             	add    $0x14,%esp
  800424:	5b                   	pop    %ebx
  800425:	5d                   	pop    %ebp
  800426:	c3                   	ret    

00800427 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800427:	55                   	push   %ebp
  800428:	89 e5                	mov    %esp,%ebp
  80042a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800430:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800437:	00 00 00 
	b.cnt = 0;
  80043a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800441:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800444:	8b 45 0c             	mov    0xc(%ebp),%eax
  800447:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80044b:	8b 45 08             	mov    0x8(%ebp),%eax
  80044e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800452:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800458:	89 44 24 04          	mov    %eax,0x4(%esp)
  80045c:	c7 04 24 e8 03 80 00 	movl   $0x8003e8,(%esp)
  800463:	e8 82 01 00 00       	call   8005ea <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800468:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80046e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800472:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800478:	89 04 24             	mov    %eax,(%esp)
  80047b:	e8 d8 08 00 00       	call   800d58 <sys_cputs>

	return b.cnt;
}
  800480:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800486:	c9                   	leave  
  800487:	c3                   	ret    

00800488 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800488:	55                   	push   %ebp
  800489:	89 e5                	mov    %esp,%ebp
  80048b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80048e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800491:	89 44 24 04          	mov    %eax,0x4(%esp)
  800495:	8b 45 08             	mov    0x8(%ebp),%eax
  800498:	89 04 24             	mov    %eax,(%esp)
  80049b:	e8 87 ff ff ff       	call   800427 <vcprintf>
	va_end(ap);

	return cnt;
}
  8004a0:	c9                   	leave  
  8004a1:	c3                   	ret    
	...

008004a4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004a4:	55                   	push   %ebp
  8004a5:	89 e5                	mov    %esp,%ebp
  8004a7:	57                   	push   %edi
  8004a8:	56                   	push   %esi
  8004a9:	53                   	push   %ebx
  8004aa:	83 ec 3c             	sub    $0x3c,%esp
  8004ad:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004b0:	89 d7                	mov    %edx,%edi
  8004b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8004b5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004bb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004be:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004c1:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004c4:	85 c0                	test   %eax,%eax
  8004c6:	75 08                	jne    8004d0 <printnum+0x2c>
  8004c8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004cb:	39 45 10             	cmp    %eax,0x10(%ebp)
  8004ce:	77 57                	ja     800527 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004d0:	89 74 24 10          	mov    %esi,0x10(%esp)
  8004d4:	4b                   	dec    %ebx
  8004d5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8004d9:	8b 45 10             	mov    0x10(%ebp),%eax
  8004dc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004e0:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8004e4:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8004e8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004ef:	00 
  8004f0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004f3:	89 04 24             	mov    %eax,(%esp)
  8004f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004fd:	e8 26 1d 00 00       	call   802228 <__udivdi3>
  800502:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800506:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80050a:	89 04 24             	mov    %eax,(%esp)
  80050d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800511:	89 fa                	mov    %edi,%edx
  800513:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800516:	e8 89 ff ff ff       	call   8004a4 <printnum>
  80051b:	eb 0f                	jmp    80052c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80051d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800521:	89 34 24             	mov    %esi,(%esp)
  800524:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800527:	4b                   	dec    %ebx
  800528:	85 db                	test   %ebx,%ebx
  80052a:	7f f1                	jg     80051d <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80052c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800530:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800534:	8b 45 10             	mov    0x10(%ebp),%eax
  800537:	89 44 24 08          	mov    %eax,0x8(%esp)
  80053b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800542:	00 
  800543:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800546:	89 04 24             	mov    %eax,(%esp)
  800549:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80054c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800550:	e8 f3 1d 00 00       	call   802348 <__umoddi3>
  800555:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800559:	0f be 80 3b 25 80 00 	movsbl 0x80253b(%eax),%eax
  800560:	89 04 24             	mov    %eax,(%esp)
  800563:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800566:	83 c4 3c             	add    $0x3c,%esp
  800569:	5b                   	pop    %ebx
  80056a:	5e                   	pop    %esi
  80056b:	5f                   	pop    %edi
  80056c:	5d                   	pop    %ebp
  80056d:	c3                   	ret    

0080056e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80056e:	55                   	push   %ebp
  80056f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800571:	83 fa 01             	cmp    $0x1,%edx
  800574:	7e 0e                	jle    800584 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800576:	8b 10                	mov    (%eax),%edx
  800578:	8d 4a 08             	lea    0x8(%edx),%ecx
  80057b:	89 08                	mov    %ecx,(%eax)
  80057d:	8b 02                	mov    (%edx),%eax
  80057f:	8b 52 04             	mov    0x4(%edx),%edx
  800582:	eb 22                	jmp    8005a6 <getuint+0x38>
	else if (lflag)
  800584:	85 d2                	test   %edx,%edx
  800586:	74 10                	je     800598 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800588:	8b 10                	mov    (%eax),%edx
  80058a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80058d:	89 08                	mov    %ecx,(%eax)
  80058f:	8b 02                	mov    (%edx),%eax
  800591:	ba 00 00 00 00       	mov    $0x0,%edx
  800596:	eb 0e                	jmp    8005a6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800598:	8b 10                	mov    (%eax),%edx
  80059a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80059d:	89 08                	mov    %ecx,(%eax)
  80059f:	8b 02                	mov    (%edx),%eax
  8005a1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005a6:	5d                   	pop    %ebp
  8005a7:	c3                   	ret    

008005a8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005a8:	55                   	push   %ebp
  8005a9:	89 e5                	mov    %esp,%ebp
  8005ab:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005ae:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8005b1:	8b 10                	mov    (%eax),%edx
  8005b3:	3b 50 04             	cmp    0x4(%eax),%edx
  8005b6:	73 08                	jae    8005c0 <sprintputch+0x18>
		*b->buf++ = ch;
  8005b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8005bb:	88 0a                	mov    %cl,(%edx)
  8005bd:	42                   	inc    %edx
  8005be:	89 10                	mov    %edx,(%eax)
}
  8005c0:	5d                   	pop    %ebp
  8005c1:	c3                   	ret    

008005c2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005c2:	55                   	push   %ebp
  8005c3:	89 e5                	mov    %esp,%ebp
  8005c5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8005c8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005cf:	8b 45 10             	mov    0x10(%ebp),%eax
  8005d2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e0:	89 04 24             	mov    %eax,(%esp)
  8005e3:	e8 02 00 00 00       	call   8005ea <vprintfmt>
	va_end(ap);
}
  8005e8:	c9                   	leave  
  8005e9:	c3                   	ret    

008005ea <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8005ea:	55                   	push   %ebp
  8005eb:	89 e5                	mov    %esp,%ebp
  8005ed:	57                   	push   %edi
  8005ee:	56                   	push   %esi
  8005ef:	53                   	push   %ebx
  8005f0:	83 ec 4c             	sub    $0x4c,%esp
  8005f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005f6:	8b 75 10             	mov    0x10(%ebp),%esi
  8005f9:	eb 12                	jmp    80060d <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8005fb:	85 c0                	test   %eax,%eax
  8005fd:	0f 84 6b 03 00 00    	je     80096e <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800603:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800607:	89 04 24             	mov    %eax,(%esp)
  80060a:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80060d:	0f b6 06             	movzbl (%esi),%eax
  800610:	46                   	inc    %esi
  800611:	83 f8 25             	cmp    $0x25,%eax
  800614:	75 e5                	jne    8005fb <vprintfmt+0x11>
  800616:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80061a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800621:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800626:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80062d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800632:	eb 26                	jmp    80065a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800634:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800637:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80063b:	eb 1d                	jmp    80065a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800640:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800644:	eb 14                	jmp    80065a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800646:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800649:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800650:	eb 08                	jmp    80065a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800652:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800655:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065a:	0f b6 06             	movzbl (%esi),%eax
  80065d:	8d 56 01             	lea    0x1(%esi),%edx
  800660:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800663:	8a 16                	mov    (%esi),%dl
  800665:	83 ea 23             	sub    $0x23,%edx
  800668:	80 fa 55             	cmp    $0x55,%dl
  80066b:	0f 87 e1 02 00 00    	ja     800952 <vprintfmt+0x368>
  800671:	0f b6 d2             	movzbl %dl,%edx
  800674:	ff 24 95 80 26 80 00 	jmp    *0x802680(,%edx,4)
  80067b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80067e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800683:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800686:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80068a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80068d:	8d 50 d0             	lea    -0x30(%eax),%edx
  800690:	83 fa 09             	cmp    $0x9,%edx
  800693:	77 2a                	ja     8006bf <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800695:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800696:	eb eb                	jmp    800683 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800698:	8b 45 14             	mov    0x14(%ebp),%eax
  80069b:	8d 50 04             	lea    0x4(%eax),%edx
  80069e:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a1:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8006a6:	eb 17                	jmp    8006bf <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8006a8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006ac:	78 98                	js     800646 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ae:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006b1:	eb a7                	jmp    80065a <vprintfmt+0x70>
  8006b3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006b6:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8006bd:	eb 9b                	jmp    80065a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8006bf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006c3:	79 95                	jns    80065a <vprintfmt+0x70>
  8006c5:	eb 8b                	jmp    800652 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006c7:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c8:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8006cb:	eb 8d                	jmp    80065a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8006cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d0:	8d 50 04             	lea    0x4(%eax),%edx
  8006d3:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006da:	8b 00                	mov    (%eax),%eax
  8006dc:	89 04 24             	mov    %eax,(%esp)
  8006df:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8006e5:	e9 23 ff ff ff       	jmp    80060d <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ed:	8d 50 04             	lea    0x4(%eax),%edx
  8006f0:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f3:	8b 00                	mov    (%eax),%eax
  8006f5:	85 c0                	test   %eax,%eax
  8006f7:	79 02                	jns    8006fb <vprintfmt+0x111>
  8006f9:	f7 d8                	neg    %eax
  8006fb:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006fd:	83 f8 0f             	cmp    $0xf,%eax
  800700:	7f 0b                	jg     80070d <vprintfmt+0x123>
  800702:	8b 04 85 e0 27 80 00 	mov    0x8027e0(,%eax,4),%eax
  800709:	85 c0                	test   %eax,%eax
  80070b:	75 23                	jne    800730 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80070d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800711:	c7 44 24 08 53 25 80 	movl   $0x802553,0x8(%esp)
  800718:	00 
  800719:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80071d:	8b 45 08             	mov    0x8(%ebp),%eax
  800720:	89 04 24             	mov    %eax,(%esp)
  800723:	e8 9a fe ff ff       	call   8005c2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800728:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80072b:	e9 dd fe ff ff       	jmp    80060d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800730:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800734:	c7 44 24 08 11 29 80 	movl   $0x802911,0x8(%esp)
  80073b:	00 
  80073c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800740:	8b 55 08             	mov    0x8(%ebp),%edx
  800743:	89 14 24             	mov    %edx,(%esp)
  800746:	e8 77 fe ff ff       	call   8005c2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80074b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80074e:	e9 ba fe ff ff       	jmp    80060d <vprintfmt+0x23>
  800753:	89 f9                	mov    %edi,%ecx
  800755:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800758:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80075b:	8b 45 14             	mov    0x14(%ebp),%eax
  80075e:	8d 50 04             	lea    0x4(%eax),%edx
  800761:	89 55 14             	mov    %edx,0x14(%ebp)
  800764:	8b 30                	mov    (%eax),%esi
  800766:	85 f6                	test   %esi,%esi
  800768:	75 05                	jne    80076f <vprintfmt+0x185>
				p = "(null)";
  80076a:	be 4c 25 80 00       	mov    $0x80254c,%esi
			if (width > 0 && padc != '-')
  80076f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800773:	0f 8e 84 00 00 00    	jle    8007fd <vprintfmt+0x213>
  800779:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80077d:	74 7e                	je     8007fd <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80077f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800783:	89 34 24             	mov    %esi,(%esp)
  800786:	e8 8b 02 00 00       	call   800a16 <strnlen>
  80078b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80078e:	29 c2                	sub    %eax,%edx
  800790:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800793:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800797:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80079a:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80079d:	89 de                	mov    %ebx,%esi
  80079f:	89 d3                	mov    %edx,%ebx
  8007a1:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007a3:	eb 0b                	jmp    8007b0 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8007a5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007a9:	89 3c 24             	mov    %edi,(%esp)
  8007ac:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007af:	4b                   	dec    %ebx
  8007b0:	85 db                	test   %ebx,%ebx
  8007b2:	7f f1                	jg     8007a5 <vprintfmt+0x1bb>
  8007b4:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8007b7:	89 f3                	mov    %esi,%ebx
  8007b9:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8007bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007bf:	85 c0                	test   %eax,%eax
  8007c1:	79 05                	jns    8007c8 <vprintfmt+0x1de>
  8007c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007cb:	29 c2                	sub    %eax,%edx
  8007cd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8007d0:	eb 2b                	jmp    8007fd <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8007d2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007d6:	74 18                	je     8007f0 <vprintfmt+0x206>
  8007d8:	8d 50 e0             	lea    -0x20(%eax),%edx
  8007db:	83 fa 5e             	cmp    $0x5e,%edx
  8007de:	76 10                	jbe    8007f0 <vprintfmt+0x206>
					putch('?', putdat);
  8007e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8007eb:	ff 55 08             	call   *0x8(%ebp)
  8007ee:	eb 0a                	jmp    8007fa <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8007f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007f4:	89 04 24             	mov    %eax,(%esp)
  8007f7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007fa:	ff 4d e4             	decl   -0x1c(%ebp)
  8007fd:	0f be 06             	movsbl (%esi),%eax
  800800:	46                   	inc    %esi
  800801:	85 c0                	test   %eax,%eax
  800803:	74 21                	je     800826 <vprintfmt+0x23c>
  800805:	85 ff                	test   %edi,%edi
  800807:	78 c9                	js     8007d2 <vprintfmt+0x1e8>
  800809:	4f                   	dec    %edi
  80080a:	79 c6                	jns    8007d2 <vprintfmt+0x1e8>
  80080c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80080f:	89 de                	mov    %ebx,%esi
  800811:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800814:	eb 18                	jmp    80082e <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800816:	89 74 24 04          	mov    %esi,0x4(%esp)
  80081a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800821:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800823:	4b                   	dec    %ebx
  800824:	eb 08                	jmp    80082e <vprintfmt+0x244>
  800826:	8b 7d 08             	mov    0x8(%ebp),%edi
  800829:	89 de                	mov    %ebx,%esi
  80082b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80082e:	85 db                	test   %ebx,%ebx
  800830:	7f e4                	jg     800816 <vprintfmt+0x22c>
  800832:	89 7d 08             	mov    %edi,0x8(%ebp)
  800835:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800837:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80083a:	e9 ce fd ff ff       	jmp    80060d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80083f:	83 f9 01             	cmp    $0x1,%ecx
  800842:	7e 10                	jle    800854 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800844:	8b 45 14             	mov    0x14(%ebp),%eax
  800847:	8d 50 08             	lea    0x8(%eax),%edx
  80084a:	89 55 14             	mov    %edx,0x14(%ebp)
  80084d:	8b 30                	mov    (%eax),%esi
  80084f:	8b 78 04             	mov    0x4(%eax),%edi
  800852:	eb 26                	jmp    80087a <vprintfmt+0x290>
	else if (lflag)
  800854:	85 c9                	test   %ecx,%ecx
  800856:	74 12                	je     80086a <vprintfmt+0x280>
		return va_arg(*ap, long);
  800858:	8b 45 14             	mov    0x14(%ebp),%eax
  80085b:	8d 50 04             	lea    0x4(%eax),%edx
  80085e:	89 55 14             	mov    %edx,0x14(%ebp)
  800861:	8b 30                	mov    (%eax),%esi
  800863:	89 f7                	mov    %esi,%edi
  800865:	c1 ff 1f             	sar    $0x1f,%edi
  800868:	eb 10                	jmp    80087a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80086a:	8b 45 14             	mov    0x14(%ebp),%eax
  80086d:	8d 50 04             	lea    0x4(%eax),%edx
  800870:	89 55 14             	mov    %edx,0x14(%ebp)
  800873:	8b 30                	mov    (%eax),%esi
  800875:	89 f7                	mov    %esi,%edi
  800877:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80087a:	85 ff                	test   %edi,%edi
  80087c:	78 0a                	js     800888 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80087e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800883:	e9 8c 00 00 00       	jmp    800914 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800888:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80088c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800893:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800896:	f7 de                	neg    %esi
  800898:	83 d7 00             	adc    $0x0,%edi
  80089b:	f7 df                	neg    %edi
			}
			base = 10;
  80089d:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008a2:	eb 70                	jmp    800914 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8008a4:	89 ca                	mov    %ecx,%edx
  8008a6:	8d 45 14             	lea    0x14(%ebp),%eax
  8008a9:	e8 c0 fc ff ff       	call   80056e <getuint>
  8008ae:	89 c6                	mov    %eax,%esi
  8008b0:	89 d7                	mov    %edx,%edi
			base = 10;
  8008b2:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8008b7:	eb 5b                	jmp    800914 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  8008b9:	89 ca                	mov    %ecx,%edx
  8008bb:	8d 45 14             	lea    0x14(%ebp),%eax
  8008be:	e8 ab fc ff ff       	call   80056e <getuint>
  8008c3:	89 c6                	mov    %eax,%esi
  8008c5:	89 d7                	mov    %edx,%edi
			base = 8;
  8008c7:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8008cc:	eb 46                	jmp    800914 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  8008ce:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008d2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8008d9:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8008dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008e0:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8008e7:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ed:	8d 50 04             	lea    0x4(%eax),%edx
  8008f0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008f3:	8b 30                	mov    (%eax),%esi
  8008f5:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008fa:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008ff:	eb 13                	jmp    800914 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800901:	89 ca                	mov    %ecx,%edx
  800903:	8d 45 14             	lea    0x14(%ebp),%eax
  800906:	e8 63 fc ff ff       	call   80056e <getuint>
  80090b:	89 c6                	mov    %eax,%esi
  80090d:	89 d7                	mov    %edx,%edi
			base = 16;
  80090f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800914:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800918:	89 54 24 10          	mov    %edx,0x10(%esp)
  80091c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80091f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800923:	89 44 24 08          	mov    %eax,0x8(%esp)
  800927:	89 34 24             	mov    %esi,(%esp)
  80092a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80092e:	89 da                	mov    %ebx,%edx
  800930:	8b 45 08             	mov    0x8(%ebp),%eax
  800933:	e8 6c fb ff ff       	call   8004a4 <printnum>
			break;
  800938:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80093b:	e9 cd fc ff ff       	jmp    80060d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800940:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800944:	89 04 24             	mov    %eax,(%esp)
  800947:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80094a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80094d:	e9 bb fc ff ff       	jmp    80060d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800952:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800956:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80095d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800960:	eb 01                	jmp    800963 <vprintfmt+0x379>
  800962:	4e                   	dec    %esi
  800963:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800967:	75 f9                	jne    800962 <vprintfmt+0x378>
  800969:	e9 9f fc ff ff       	jmp    80060d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80096e:	83 c4 4c             	add    $0x4c,%esp
  800971:	5b                   	pop    %ebx
  800972:	5e                   	pop    %esi
  800973:	5f                   	pop    %edi
  800974:	5d                   	pop    %ebp
  800975:	c3                   	ret    

00800976 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800976:	55                   	push   %ebp
  800977:	89 e5                	mov    %esp,%ebp
  800979:	83 ec 28             	sub    $0x28,%esp
  80097c:	8b 45 08             	mov    0x8(%ebp),%eax
  80097f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800982:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800985:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800989:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80098c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800993:	85 c0                	test   %eax,%eax
  800995:	74 30                	je     8009c7 <vsnprintf+0x51>
  800997:	85 d2                	test   %edx,%edx
  800999:	7e 33                	jle    8009ce <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80099b:	8b 45 14             	mov    0x14(%ebp),%eax
  80099e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009a2:	8b 45 10             	mov    0x10(%ebp),%eax
  8009a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009a9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009b0:	c7 04 24 a8 05 80 00 	movl   $0x8005a8,(%esp)
  8009b7:	e8 2e fc ff ff       	call   8005ea <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009bf:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009c5:	eb 0c                	jmp    8009d3 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009cc:	eb 05                	jmp    8009d3 <vsnprintf+0x5d>
  8009ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009d3:	c9                   	leave  
  8009d4:	c3                   	ret    

008009d5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009d5:	55                   	push   %ebp
  8009d6:	89 e5                	mov    %esp,%ebp
  8009d8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009db:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009de:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009e2:	8b 45 10             	mov    0x10(%ebp),%eax
  8009e5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f3:	89 04 24             	mov    %eax,(%esp)
  8009f6:	e8 7b ff ff ff       	call   800976 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009fb:	c9                   	leave  
  8009fc:	c3                   	ret    
  8009fd:	00 00                	add    %al,(%eax)
	...

00800a00 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a06:	b8 00 00 00 00       	mov    $0x0,%eax
  800a0b:	eb 01                	jmp    800a0e <strlen+0xe>
		n++;
  800a0d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a0e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a12:	75 f9                	jne    800a0d <strlen+0xd>
		n++;
	return n;
}
  800a14:	5d                   	pop    %ebp
  800a15:	c3                   	ret    

00800a16 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a16:	55                   	push   %ebp
  800a17:	89 e5                	mov    %esp,%ebp
  800a19:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800a1c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a1f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a24:	eb 01                	jmp    800a27 <strnlen+0x11>
		n++;
  800a26:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a27:	39 d0                	cmp    %edx,%eax
  800a29:	74 06                	je     800a31 <strnlen+0x1b>
  800a2b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a2f:	75 f5                	jne    800a26 <strnlen+0x10>
		n++;
	return n;
}
  800a31:	5d                   	pop    %ebp
  800a32:	c3                   	ret    

00800a33 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a33:	55                   	push   %ebp
  800a34:	89 e5                	mov    %esp,%ebp
  800a36:	53                   	push   %ebx
  800a37:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a3d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a42:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800a45:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a48:	42                   	inc    %edx
  800a49:	84 c9                	test   %cl,%cl
  800a4b:	75 f5                	jne    800a42 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a4d:	5b                   	pop    %ebx
  800a4e:	5d                   	pop    %ebp
  800a4f:	c3                   	ret    

00800a50 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a50:	55                   	push   %ebp
  800a51:	89 e5                	mov    %esp,%ebp
  800a53:	53                   	push   %ebx
  800a54:	83 ec 08             	sub    $0x8,%esp
  800a57:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a5a:	89 1c 24             	mov    %ebx,(%esp)
  800a5d:	e8 9e ff ff ff       	call   800a00 <strlen>
	strcpy(dst + len, src);
  800a62:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a65:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a69:	01 d8                	add    %ebx,%eax
  800a6b:	89 04 24             	mov    %eax,(%esp)
  800a6e:	e8 c0 ff ff ff       	call   800a33 <strcpy>
	return dst;
}
  800a73:	89 d8                	mov    %ebx,%eax
  800a75:	83 c4 08             	add    $0x8,%esp
  800a78:	5b                   	pop    %ebx
  800a79:	5d                   	pop    %ebp
  800a7a:	c3                   	ret    

00800a7b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a7b:	55                   	push   %ebp
  800a7c:	89 e5                	mov    %esp,%ebp
  800a7e:	56                   	push   %esi
  800a7f:	53                   	push   %ebx
  800a80:	8b 45 08             	mov    0x8(%ebp),%eax
  800a83:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a86:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a89:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a8e:	eb 0c                	jmp    800a9c <strncpy+0x21>
		*dst++ = *src;
  800a90:	8a 1a                	mov    (%edx),%bl
  800a92:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a95:	80 3a 01             	cmpb   $0x1,(%edx)
  800a98:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a9b:	41                   	inc    %ecx
  800a9c:	39 f1                	cmp    %esi,%ecx
  800a9e:	75 f0                	jne    800a90 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800aa0:	5b                   	pop    %ebx
  800aa1:	5e                   	pop    %esi
  800aa2:	5d                   	pop    %ebp
  800aa3:	c3                   	ret    

00800aa4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800aa4:	55                   	push   %ebp
  800aa5:	89 e5                	mov    %esp,%ebp
  800aa7:	56                   	push   %esi
  800aa8:	53                   	push   %ebx
  800aa9:	8b 75 08             	mov    0x8(%ebp),%esi
  800aac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aaf:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ab2:	85 d2                	test   %edx,%edx
  800ab4:	75 0a                	jne    800ac0 <strlcpy+0x1c>
  800ab6:	89 f0                	mov    %esi,%eax
  800ab8:	eb 1a                	jmp    800ad4 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800aba:	88 18                	mov    %bl,(%eax)
  800abc:	40                   	inc    %eax
  800abd:	41                   	inc    %ecx
  800abe:	eb 02                	jmp    800ac2 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ac0:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800ac2:	4a                   	dec    %edx
  800ac3:	74 0a                	je     800acf <strlcpy+0x2b>
  800ac5:	8a 19                	mov    (%ecx),%bl
  800ac7:	84 db                	test   %bl,%bl
  800ac9:	75 ef                	jne    800aba <strlcpy+0x16>
  800acb:	89 c2                	mov    %eax,%edx
  800acd:	eb 02                	jmp    800ad1 <strlcpy+0x2d>
  800acf:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800ad1:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800ad4:	29 f0                	sub    %esi,%eax
}
  800ad6:	5b                   	pop    %ebx
  800ad7:	5e                   	pop    %esi
  800ad8:	5d                   	pop    %ebp
  800ad9:	c3                   	ret    

00800ada <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ada:	55                   	push   %ebp
  800adb:	89 e5                	mov    %esp,%ebp
  800add:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ae0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ae3:	eb 02                	jmp    800ae7 <strcmp+0xd>
		p++, q++;
  800ae5:	41                   	inc    %ecx
  800ae6:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ae7:	8a 01                	mov    (%ecx),%al
  800ae9:	84 c0                	test   %al,%al
  800aeb:	74 04                	je     800af1 <strcmp+0x17>
  800aed:	3a 02                	cmp    (%edx),%al
  800aef:	74 f4                	je     800ae5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800af1:	0f b6 c0             	movzbl %al,%eax
  800af4:	0f b6 12             	movzbl (%edx),%edx
  800af7:	29 d0                	sub    %edx,%eax
}
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	53                   	push   %ebx
  800aff:	8b 45 08             	mov    0x8(%ebp),%eax
  800b02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b05:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800b08:	eb 03                	jmp    800b0d <strncmp+0x12>
		n--, p++, q++;
  800b0a:	4a                   	dec    %edx
  800b0b:	40                   	inc    %eax
  800b0c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b0d:	85 d2                	test   %edx,%edx
  800b0f:	74 14                	je     800b25 <strncmp+0x2a>
  800b11:	8a 18                	mov    (%eax),%bl
  800b13:	84 db                	test   %bl,%bl
  800b15:	74 04                	je     800b1b <strncmp+0x20>
  800b17:	3a 19                	cmp    (%ecx),%bl
  800b19:	74 ef                	je     800b0a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b1b:	0f b6 00             	movzbl (%eax),%eax
  800b1e:	0f b6 11             	movzbl (%ecx),%edx
  800b21:	29 d0                	sub    %edx,%eax
  800b23:	eb 05                	jmp    800b2a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b25:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b2a:	5b                   	pop    %ebx
  800b2b:	5d                   	pop    %ebp
  800b2c:	c3                   	ret    

00800b2d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b2d:	55                   	push   %ebp
  800b2e:	89 e5                	mov    %esp,%ebp
  800b30:	8b 45 08             	mov    0x8(%ebp),%eax
  800b33:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b36:	eb 05                	jmp    800b3d <strchr+0x10>
		if (*s == c)
  800b38:	38 ca                	cmp    %cl,%dl
  800b3a:	74 0c                	je     800b48 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b3c:	40                   	inc    %eax
  800b3d:	8a 10                	mov    (%eax),%dl
  800b3f:	84 d2                	test   %dl,%dl
  800b41:	75 f5                	jne    800b38 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800b43:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b48:	5d                   	pop    %ebp
  800b49:	c3                   	ret    

00800b4a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b4a:	55                   	push   %ebp
  800b4b:	89 e5                	mov    %esp,%ebp
  800b4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b50:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b53:	eb 05                	jmp    800b5a <strfind+0x10>
		if (*s == c)
  800b55:	38 ca                	cmp    %cl,%dl
  800b57:	74 07                	je     800b60 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b59:	40                   	inc    %eax
  800b5a:	8a 10                	mov    (%eax),%dl
  800b5c:	84 d2                	test   %dl,%dl
  800b5e:	75 f5                	jne    800b55 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800b60:	5d                   	pop    %ebp
  800b61:	c3                   	ret    

00800b62 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	57                   	push   %edi
  800b66:	56                   	push   %esi
  800b67:	53                   	push   %ebx
  800b68:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b6e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b71:	85 c9                	test   %ecx,%ecx
  800b73:	74 30                	je     800ba5 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b75:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b7b:	75 25                	jne    800ba2 <memset+0x40>
  800b7d:	f6 c1 03             	test   $0x3,%cl
  800b80:	75 20                	jne    800ba2 <memset+0x40>
		c &= 0xFF;
  800b82:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b85:	89 d3                	mov    %edx,%ebx
  800b87:	c1 e3 08             	shl    $0x8,%ebx
  800b8a:	89 d6                	mov    %edx,%esi
  800b8c:	c1 e6 18             	shl    $0x18,%esi
  800b8f:	89 d0                	mov    %edx,%eax
  800b91:	c1 e0 10             	shl    $0x10,%eax
  800b94:	09 f0                	or     %esi,%eax
  800b96:	09 d0                	or     %edx,%eax
  800b98:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b9a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b9d:	fc                   	cld    
  800b9e:	f3 ab                	rep stos %eax,%es:(%edi)
  800ba0:	eb 03                	jmp    800ba5 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ba2:	fc                   	cld    
  800ba3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ba5:	89 f8                	mov    %edi,%eax
  800ba7:	5b                   	pop    %ebx
  800ba8:	5e                   	pop    %esi
  800ba9:	5f                   	pop    %edi
  800baa:	5d                   	pop    %ebp
  800bab:	c3                   	ret    

00800bac <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bac:	55                   	push   %ebp
  800bad:	89 e5                	mov    %esp,%ebp
  800baf:	57                   	push   %edi
  800bb0:	56                   	push   %esi
  800bb1:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bb7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bba:	39 c6                	cmp    %eax,%esi
  800bbc:	73 34                	jae    800bf2 <memmove+0x46>
  800bbe:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bc1:	39 d0                	cmp    %edx,%eax
  800bc3:	73 2d                	jae    800bf2 <memmove+0x46>
		s += n;
		d += n;
  800bc5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bc8:	f6 c2 03             	test   $0x3,%dl
  800bcb:	75 1b                	jne    800be8 <memmove+0x3c>
  800bcd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bd3:	75 13                	jne    800be8 <memmove+0x3c>
  800bd5:	f6 c1 03             	test   $0x3,%cl
  800bd8:	75 0e                	jne    800be8 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bda:	83 ef 04             	sub    $0x4,%edi
  800bdd:	8d 72 fc             	lea    -0x4(%edx),%esi
  800be0:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800be3:	fd                   	std    
  800be4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800be6:	eb 07                	jmp    800bef <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800be8:	4f                   	dec    %edi
  800be9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bec:	fd                   	std    
  800bed:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bef:	fc                   	cld    
  800bf0:	eb 20                	jmp    800c12 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bf2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bf8:	75 13                	jne    800c0d <memmove+0x61>
  800bfa:	a8 03                	test   $0x3,%al
  800bfc:	75 0f                	jne    800c0d <memmove+0x61>
  800bfe:	f6 c1 03             	test   $0x3,%cl
  800c01:	75 0a                	jne    800c0d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c03:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c06:	89 c7                	mov    %eax,%edi
  800c08:	fc                   	cld    
  800c09:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c0b:	eb 05                	jmp    800c12 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c0d:	89 c7                	mov    %eax,%edi
  800c0f:	fc                   	cld    
  800c10:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c12:	5e                   	pop    %esi
  800c13:	5f                   	pop    %edi
  800c14:	5d                   	pop    %ebp
  800c15:	c3                   	ret    

00800c16 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c16:	55                   	push   %ebp
  800c17:	89 e5                	mov    %esp,%ebp
  800c19:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c1c:	8b 45 10             	mov    0x10(%ebp),%eax
  800c1f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c23:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c26:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2d:	89 04 24             	mov    %eax,(%esp)
  800c30:	e8 77 ff ff ff       	call   800bac <memmove>
}
  800c35:	c9                   	leave  
  800c36:	c3                   	ret    

00800c37 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	57                   	push   %edi
  800c3b:	56                   	push   %esi
  800c3c:	53                   	push   %ebx
  800c3d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c40:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c43:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c46:	ba 00 00 00 00       	mov    $0x0,%edx
  800c4b:	eb 16                	jmp    800c63 <memcmp+0x2c>
		if (*s1 != *s2)
  800c4d:	8a 04 17             	mov    (%edi,%edx,1),%al
  800c50:	42                   	inc    %edx
  800c51:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800c55:	38 c8                	cmp    %cl,%al
  800c57:	74 0a                	je     800c63 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800c59:	0f b6 c0             	movzbl %al,%eax
  800c5c:	0f b6 c9             	movzbl %cl,%ecx
  800c5f:	29 c8                	sub    %ecx,%eax
  800c61:	eb 09                	jmp    800c6c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c63:	39 da                	cmp    %ebx,%edx
  800c65:	75 e6                	jne    800c4d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c67:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c6c:	5b                   	pop    %ebx
  800c6d:	5e                   	pop    %esi
  800c6e:	5f                   	pop    %edi
  800c6f:	5d                   	pop    %ebp
  800c70:	c3                   	ret    

00800c71 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c71:	55                   	push   %ebp
  800c72:	89 e5                	mov    %esp,%ebp
  800c74:	8b 45 08             	mov    0x8(%ebp),%eax
  800c77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c7a:	89 c2                	mov    %eax,%edx
  800c7c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c7f:	eb 05                	jmp    800c86 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c81:	38 08                	cmp    %cl,(%eax)
  800c83:	74 05                	je     800c8a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c85:	40                   	inc    %eax
  800c86:	39 d0                	cmp    %edx,%eax
  800c88:	72 f7                	jb     800c81 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c8a:	5d                   	pop    %ebp
  800c8b:	c3                   	ret    

00800c8c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c8c:	55                   	push   %ebp
  800c8d:	89 e5                	mov    %esp,%ebp
  800c8f:	57                   	push   %edi
  800c90:	56                   	push   %esi
  800c91:	53                   	push   %ebx
  800c92:	8b 55 08             	mov    0x8(%ebp),%edx
  800c95:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c98:	eb 01                	jmp    800c9b <strtol+0xf>
		s++;
  800c9a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c9b:	8a 02                	mov    (%edx),%al
  800c9d:	3c 20                	cmp    $0x20,%al
  800c9f:	74 f9                	je     800c9a <strtol+0xe>
  800ca1:	3c 09                	cmp    $0x9,%al
  800ca3:	74 f5                	je     800c9a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ca5:	3c 2b                	cmp    $0x2b,%al
  800ca7:	75 08                	jne    800cb1 <strtol+0x25>
		s++;
  800ca9:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800caa:	bf 00 00 00 00       	mov    $0x0,%edi
  800caf:	eb 13                	jmp    800cc4 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cb1:	3c 2d                	cmp    $0x2d,%al
  800cb3:	75 0a                	jne    800cbf <strtol+0x33>
		s++, neg = 1;
  800cb5:	8d 52 01             	lea    0x1(%edx),%edx
  800cb8:	bf 01 00 00 00       	mov    $0x1,%edi
  800cbd:	eb 05                	jmp    800cc4 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cbf:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cc4:	85 db                	test   %ebx,%ebx
  800cc6:	74 05                	je     800ccd <strtol+0x41>
  800cc8:	83 fb 10             	cmp    $0x10,%ebx
  800ccb:	75 28                	jne    800cf5 <strtol+0x69>
  800ccd:	8a 02                	mov    (%edx),%al
  800ccf:	3c 30                	cmp    $0x30,%al
  800cd1:	75 10                	jne    800ce3 <strtol+0x57>
  800cd3:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800cd7:	75 0a                	jne    800ce3 <strtol+0x57>
		s += 2, base = 16;
  800cd9:	83 c2 02             	add    $0x2,%edx
  800cdc:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ce1:	eb 12                	jmp    800cf5 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800ce3:	85 db                	test   %ebx,%ebx
  800ce5:	75 0e                	jne    800cf5 <strtol+0x69>
  800ce7:	3c 30                	cmp    $0x30,%al
  800ce9:	75 05                	jne    800cf0 <strtol+0x64>
		s++, base = 8;
  800ceb:	42                   	inc    %edx
  800cec:	b3 08                	mov    $0x8,%bl
  800cee:	eb 05                	jmp    800cf5 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800cf0:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800cf5:	b8 00 00 00 00       	mov    $0x0,%eax
  800cfa:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cfc:	8a 0a                	mov    (%edx),%cl
  800cfe:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d01:	80 fb 09             	cmp    $0x9,%bl
  800d04:	77 08                	ja     800d0e <strtol+0x82>
			dig = *s - '0';
  800d06:	0f be c9             	movsbl %cl,%ecx
  800d09:	83 e9 30             	sub    $0x30,%ecx
  800d0c:	eb 1e                	jmp    800d2c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800d0e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d11:	80 fb 19             	cmp    $0x19,%bl
  800d14:	77 08                	ja     800d1e <strtol+0x92>
			dig = *s - 'a' + 10;
  800d16:	0f be c9             	movsbl %cl,%ecx
  800d19:	83 e9 57             	sub    $0x57,%ecx
  800d1c:	eb 0e                	jmp    800d2c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800d1e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d21:	80 fb 19             	cmp    $0x19,%bl
  800d24:	77 12                	ja     800d38 <strtol+0xac>
			dig = *s - 'A' + 10;
  800d26:	0f be c9             	movsbl %cl,%ecx
  800d29:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d2c:	39 f1                	cmp    %esi,%ecx
  800d2e:	7d 0c                	jge    800d3c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800d30:	42                   	inc    %edx
  800d31:	0f af c6             	imul   %esi,%eax
  800d34:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d36:	eb c4                	jmp    800cfc <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d38:	89 c1                	mov    %eax,%ecx
  800d3a:	eb 02                	jmp    800d3e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d3c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d3e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d42:	74 05                	je     800d49 <strtol+0xbd>
		*endptr = (char *) s;
  800d44:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d47:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d49:	85 ff                	test   %edi,%edi
  800d4b:	74 04                	je     800d51 <strtol+0xc5>
  800d4d:	89 c8                	mov    %ecx,%eax
  800d4f:	f7 d8                	neg    %eax
}
  800d51:	5b                   	pop    %ebx
  800d52:	5e                   	pop    %esi
  800d53:	5f                   	pop    %edi
  800d54:	5d                   	pop    %ebp
  800d55:	c3                   	ret    
	...

00800d58 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d58:	55                   	push   %ebp
  800d59:	89 e5                	mov    %esp,%ebp
  800d5b:	57                   	push   %edi
  800d5c:	56                   	push   %esi
  800d5d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5e:	b8 00 00 00 00       	mov    $0x0,%eax
  800d63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d66:	8b 55 08             	mov    0x8(%ebp),%edx
  800d69:	89 c3                	mov    %eax,%ebx
  800d6b:	89 c7                	mov    %eax,%edi
  800d6d:	89 c6                	mov    %eax,%esi
  800d6f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d71:	5b                   	pop    %ebx
  800d72:	5e                   	pop    %esi
  800d73:	5f                   	pop    %edi
  800d74:	5d                   	pop    %ebp
  800d75:	c3                   	ret    

00800d76 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d76:	55                   	push   %ebp
  800d77:	89 e5                	mov    %esp,%ebp
  800d79:	57                   	push   %edi
  800d7a:	56                   	push   %esi
  800d7b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7c:	ba 00 00 00 00       	mov    $0x0,%edx
  800d81:	b8 01 00 00 00       	mov    $0x1,%eax
  800d86:	89 d1                	mov    %edx,%ecx
  800d88:	89 d3                	mov    %edx,%ebx
  800d8a:	89 d7                	mov    %edx,%edi
  800d8c:	89 d6                	mov    %edx,%esi
  800d8e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d90:	5b                   	pop    %ebx
  800d91:	5e                   	pop    %esi
  800d92:	5f                   	pop    %edi
  800d93:	5d                   	pop    %ebp
  800d94:	c3                   	ret    

00800d95 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d95:	55                   	push   %ebp
  800d96:	89 e5                	mov    %esp,%ebp
  800d98:	57                   	push   %edi
  800d99:	56                   	push   %esi
  800d9a:	53                   	push   %ebx
  800d9b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800da3:	b8 03 00 00 00       	mov    $0x3,%eax
  800da8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dab:	89 cb                	mov    %ecx,%ebx
  800dad:	89 cf                	mov    %ecx,%edi
  800daf:	89 ce                	mov    %ecx,%esi
  800db1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800db3:	85 c0                	test   %eax,%eax
  800db5:	7e 28                	jle    800ddf <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dbb:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800dc2:	00 
  800dc3:	c7 44 24 08 3f 28 80 	movl   $0x80283f,0x8(%esp)
  800dca:	00 
  800dcb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dd2:	00 
  800dd3:	c7 04 24 5c 28 80 00 	movl   $0x80285c,(%esp)
  800dda:	e8 b1 f5 ff ff       	call   800390 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ddf:	83 c4 2c             	add    $0x2c,%esp
  800de2:	5b                   	pop    %ebx
  800de3:	5e                   	pop    %esi
  800de4:	5f                   	pop    %edi
  800de5:	5d                   	pop    %ebp
  800de6:	c3                   	ret    

00800de7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800de7:	55                   	push   %ebp
  800de8:	89 e5                	mov    %esp,%ebp
  800dea:	57                   	push   %edi
  800deb:	56                   	push   %esi
  800dec:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ded:	ba 00 00 00 00       	mov    $0x0,%edx
  800df2:	b8 02 00 00 00       	mov    $0x2,%eax
  800df7:	89 d1                	mov    %edx,%ecx
  800df9:	89 d3                	mov    %edx,%ebx
  800dfb:	89 d7                	mov    %edx,%edi
  800dfd:	89 d6                	mov    %edx,%esi
  800dff:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e01:	5b                   	pop    %ebx
  800e02:	5e                   	pop    %esi
  800e03:	5f                   	pop    %edi
  800e04:	5d                   	pop    %ebp
  800e05:	c3                   	ret    

00800e06 <sys_yield>:

void
sys_yield(void)
{
  800e06:	55                   	push   %ebp
  800e07:	89 e5                	mov    %esp,%ebp
  800e09:	57                   	push   %edi
  800e0a:	56                   	push   %esi
  800e0b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0c:	ba 00 00 00 00       	mov    $0x0,%edx
  800e11:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e16:	89 d1                	mov    %edx,%ecx
  800e18:	89 d3                	mov    %edx,%ebx
  800e1a:	89 d7                	mov    %edx,%edi
  800e1c:	89 d6                	mov    %edx,%esi
  800e1e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e20:	5b                   	pop    %ebx
  800e21:	5e                   	pop    %esi
  800e22:	5f                   	pop    %edi
  800e23:	5d                   	pop    %ebp
  800e24:	c3                   	ret    

00800e25 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e25:	55                   	push   %ebp
  800e26:	89 e5                	mov    %esp,%ebp
  800e28:	57                   	push   %edi
  800e29:	56                   	push   %esi
  800e2a:	53                   	push   %ebx
  800e2b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2e:	be 00 00 00 00       	mov    $0x0,%esi
  800e33:	b8 04 00 00 00       	mov    $0x4,%eax
  800e38:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e41:	89 f7                	mov    %esi,%edi
  800e43:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e45:	85 c0                	test   %eax,%eax
  800e47:	7e 28                	jle    800e71 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e49:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e4d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800e54:	00 
  800e55:	c7 44 24 08 3f 28 80 	movl   $0x80283f,0x8(%esp)
  800e5c:	00 
  800e5d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e64:	00 
  800e65:	c7 04 24 5c 28 80 00 	movl   $0x80285c,(%esp)
  800e6c:	e8 1f f5 ff ff       	call   800390 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e71:	83 c4 2c             	add    $0x2c,%esp
  800e74:	5b                   	pop    %ebx
  800e75:	5e                   	pop    %esi
  800e76:	5f                   	pop    %edi
  800e77:	5d                   	pop    %ebp
  800e78:	c3                   	ret    

00800e79 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e79:	55                   	push   %ebp
  800e7a:	89 e5                	mov    %esp,%ebp
  800e7c:	57                   	push   %edi
  800e7d:	56                   	push   %esi
  800e7e:	53                   	push   %ebx
  800e7f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e82:	b8 05 00 00 00       	mov    $0x5,%eax
  800e87:	8b 75 18             	mov    0x18(%ebp),%esi
  800e8a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e8d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e93:	8b 55 08             	mov    0x8(%ebp),%edx
  800e96:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e98:	85 c0                	test   %eax,%eax
  800e9a:	7e 28                	jle    800ec4 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e9c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ea0:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800ea7:	00 
  800ea8:	c7 44 24 08 3f 28 80 	movl   $0x80283f,0x8(%esp)
  800eaf:	00 
  800eb0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eb7:	00 
  800eb8:	c7 04 24 5c 28 80 00 	movl   $0x80285c,(%esp)
  800ebf:	e8 cc f4 ff ff       	call   800390 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ec4:	83 c4 2c             	add    $0x2c,%esp
  800ec7:	5b                   	pop    %ebx
  800ec8:	5e                   	pop    %esi
  800ec9:	5f                   	pop    %edi
  800eca:	5d                   	pop    %ebp
  800ecb:	c3                   	ret    

00800ecc <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ecc:	55                   	push   %ebp
  800ecd:	89 e5                	mov    %esp,%ebp
  800ecf:	57                   	push   %edi
  800ed0:	56                   	push   %esi
  800ed1:	53                   	push   %ebx
  800ed2:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eda:	b8 06 00 00 00       	mov    $0x6,%eax
  800edf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee5:	89 df                	mov    %ebx,%edi
  800ee7:	89 de                	mov    %ebx,%esi
  800ee9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eeb:	85 c0                	test   %eax,%eax
  800eed:	7e 28                	jle    800f17 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eef:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ef3:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800efa:	00 
  800efb:	c7 44 24 08 3f 28 80 	movl   $0x80283f,0x8(%esp)
  800f02:	00 
  800f03:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f0a:	00 
  800f0b:	c7 04 24 5c 28 80 00 	movl   $0x80285c,(%esp)
  800f12:	e8 79 f4 ff ff       	call   800390 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f17:	83 c4 2c             	add    $0x2c,%esp
  800f1a:	5b                   	pop    %ebx
  800f1b:	5e                   	pop    %esi
  800f1c:	5f                   	pop    %edi
  800f1d:	5d                   	pop    %ebp
  800f1e:	c3                   	ret    

00800f1f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f1f:	55                   	push   %ebp
  800f20:	89 e5                	mov    %esp,%ebp
  800f22:	57                   	push   %edi
  800f23:	56                   	push   %esi
  800f24:	53                   	push   %ebx
  800f25:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f28:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f2d:	b8 08 00 00 00       	mov    $0x8,%eax
  800f32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f35:	8b 55 08             	mov    0x8(%ebp),%edx
  800f38:	89 df                	mov    %ebx,%edi
  800f3a:	89 de                	mov    %ebx,%esi
  800f3c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f3e:	85 c0                	test   %eax,%eax
  800f40:	7e 28                	jle    800f6a <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f42:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f46:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f4d:	00 
  800f4e:	c7 44 24 08 3f 28 80 	movl   $0x80283f,0x8(%esp)
  800f55:	00 
  800f56:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f5d:	00 
  800f5e:	c7 04 24 5c 28 80 00 	movl   $0x80285c,(%esp)
  800f65:	e8 26 f4 ff ff       	call   800390 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f6a:	83 c4 2c             	add    $0x2c,%esp
  800f6d:	5b                   	pop    %ebx
  800f6e:	5e                   	pop    %esi
  800f6f:	5f                   	pop    %edi
  800f70:	5d                   	pop    %ebp
  800f71:	c3                   	ret    

00800f72 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f72:	55                   	push   %ebp
  800f73:	89 e5                	mov    %esp,%ebp
  800f75:	57                   	push   %edi
  800f76:	56                   	push   %esi
  800f77:	53                   	push   %ebx
  800f78:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f7b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f80:	b8 09 00 00 00       	mov    $0x9,%eax
  800f85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f88:	8b 55 08             	mov    0x8(%ebp),%edx
  800f8b:	89 df                	mov    %ebx,%edi
  800f8d:	89 de                	mov    %ebx,%esi
  800f8f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f91:	85 c0                	test   %eax,%eax
  800f93:	7e 28                	jle    800fbd <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f95:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f99:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800fa0:	00 
  800fa1:	c7 44 24 08 3f 28 80 	movl   $0x80283f,0x8(%esp)
  800fa8:	00 
  800fa9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fb0:	00 
  800fb1:	c7 04 24 5c 28 80 00 	movl   $0x80285c,(%esp)
  800fb8:	e8 d3 f3 ff ff       	call   800390 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800fbd:	83 c4 2c             	add    $0x2c,%esp
  800fc0:	5b                   	pop    %ebx
  800fc1:	5e                   	pop    %esi
  800fc2:	5f                   	pop    %edi
  800fc3:	5d                   	pop    %ebp
  800fc4:	c3                   	ret    

00800fc5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800fc5:	55                   	push   %ebp
  800fc6:	89 e5                	mov    %esp,%ebp
  800fc8:	57                   	push   %edi
  800fc9:	56                   	push   %esi
  800fca:	53                   	push   %ebx
  800fcb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fce:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fd3:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fdb:	8b 55 08             	mov    0x8(%ebp),%edx
  800fde:	89 df                	mov    %ebx,%edi
  800fe0:	89 de                	mov    %ebx,%esi
  800fe2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fe4:	85 c0                	test   %eax,%eax
  800fe6:	7e 28                	jle    801010 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fe8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fec:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800ff3:	00 
  800ff4:	c7 44 24 08 3f 28 80 	movl   $0x80283f,0x8(%esp)
  800ffb:	00 
  800ffc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801003:	00 
  801004:	c7 04 24 5c 28 80 00 	movl   $0x80285c,(%esp)
  80100b:	e8 80 f3 ff ff       	call   800390 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801010:	83 c4 2c             	add    $0x2c,%esp
  801013:	5b                   	pop    %ebx
  801014:	5e                   	pop    %esi
  801015:	5f                   	pop    %edi
  801016:	5d                   	pop    %ebp
  801017:	c3                   	ret    

00801018 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801018:	55                   	push   %ebp
  801019:	89 e5                	mov    %esp,%ebp
  80101b:	57                   	push   %edi
  80101c:	56                   	push   %esi
  80101d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80101e:	be 00 00 00 00       	mov    $0x0,%esi
  801023:	b8 0c 00 00 00       	mov    $0xc,%eax
  801028:	8b 7d 14             	mov    0x14(%ebp),%edi
  80102b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80102e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801031:	8b 55 08             	mov    0x8(%ebp),%edx
  801034:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801036:	5b                   	pop    %ebx
  801037:	5e                   	pop    %esi
  801038:	5f                   	pop    %edi
  801039:	5d                   	pop    %ebp
  80103a:	c3                   	ret    

0080103b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80103b:	55                   	push   %ebp
  80103c:	89 e5                	mov    %esp,%ebp
  80103e:	57                   	push   %edi
  80103f:	56                   	push   %esi
  801040:	53                   	push   %ebx
  801041:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801044:	b9 00 00 00 00       	mov    $0x0,%ecx
  801049:	b8 0d 00 00 00       	mov    $0xd,%eax
  80104e:	8b 55 08             	mov    0x8(%ebp),%edx
  801051:	89 cb                	mov    %ecx,%ebx
  801053:	89 cf                	mov    %ecx,%edi
  801055:	89 ce                	mov    %ecx,%esi
  801057:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801059:	85 c0                	test   %eax,%eax
  80105b:	7e 28                	jle    801085 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80105d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801061:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801068:	00 
  801069:	c7 44 24 08 3f 28 80 	movl   $0x80283f,0x8(%esp)
  801070:	00 
  801071:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801078:	00 
  801079:	c7 04 24 5c 28 80 00 	movl   $0x80285c,(%esp)
  801080:	e8 0b f3 ff ff       	call   800390 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801085:	83 c4 2c             	add    $0x2c,%esp
  801088:	5b                   	pop    %ebx
  801089:	5e                   	pop    %esi
  80108a:	5f                   	pop    %edi
  80108b:	5d                   	pop    %ebp
  80108c:	c3                   	ret    
  80108d:	00 00                	add    %al,(%eax)
	...

00801090 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801090:	55                   	push   %ebp
  801091:	89 e5                	mov    %esp,%ebp
  801093:	8b 55 08             	mov    0x8(%ebp),%edx
  801096:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801099:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  80109c:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  80109e:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  8010a1:	83 3a 01             	cmpl   $0x1,(%edx)
  8010a4:	7e 0b                	jle    8010b1 <argstart+0x21>
  8010a6:	85 c9                	test   %ecx,%ecx
  8010a8:	75 0e                	jne    8010b8 <argstart+0x28>
  8010aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8010af:	eb 0c                	jmp    8010bd <argstart+0x2d>
  8010b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8010b6:	eb 05                	jmp    8010bd <argstart+0x2d>
  8010b8:	ba e8 24 80 00       	mov    $0x8024e8,%edx
  8010bd:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  8010c0:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  8010c7:	5d                   	pop    %ebp
  8010c8:	c3                   	ret    

008010c9 <argnext>:

int
argnext(struct Argstate *args)
{
  8010c9:	55                   	push   %ebp
  8010ca:	89 e5                	mov    %esp,%ebp
  8010cc:	53                   	push   %ebx
  8010cd:	83 ec 14             	sub    $0x14,%esp
  8010d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  8010d3:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  8010da:	8b 43 08             	mov    0x8(%ebx),%eax
  8010dd:	85 c0                	test   %eax,%eax
  8010df:	74 6c                	je     80114d <argnext+0x84>
		return -1;

	if (!*args->curarg) {
  8010e1:	80 38 00             	cmpb   $0x0,(%eax)
  8010e4:	75 4d                	jne    801133 <argnext+0x6a>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  8010e6:	8b 0b                	mov    (%ebx),%ecx
  8010e8:	83 39 01             	cmpl   $0x1,(%ecx)
  8010eb:	74 52                	je     80113f <argnext+0x76>
		    || args->argv[1][0] != '-'
  8010ed:	8b 53 04             	mov    0x4(%ebx),%edx
  8010f0:	8b 42 04             	mov    0x4(%edx),%eax
  8010f3:	80 38 2d             	cmpb   $0x2d,(%eax)
  8010f6:	75 47                	jne    80113f <argnext+0x76>
		    || args->argv[1][1] == '\0')
  8010f8:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  8010fc:	74 41                	je     80113f <argnext+0x76>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  8010fe:	40                   	inc    %eax
  8010ff:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801102:	8b 01                	mov    (%ecx),%eax
  801104:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  80110b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80110f:	8d 42 08             	lea    0x8(%edx),%eax
  801112:	89 44 24 04          	mov    %eax,0x4(%esp)
  801116:	83 c2 04             	add    $0x4,%edx
  801119:	89 14 24             	mov    %edx,(%esp)
  80111c:	e8 8b fa ff ff       	call   800bac <memmove>
		(*args->argc)--;
  801121:	8b 03                	mov    (%ebx),%eax
  801123:	ff 08                	decl   (%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801125:	8b 43 08             	mov    0x8(%ebx),%eax
  801128:	80 38 2d             	cmpb   $0x2d,(%eax)
  80112b:	75 06                	jne    801133 <argnext+0x6a>
  80112d:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801131:	74 0c                	je     80113f <argnext+0x76>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801133:	8b 53 08             	mov    0x8(%ebx),%edx
  801136:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801139:	42                   	inc    %edx
  80113a:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  80113d:	eb 13                	jmp    801152 <argnext+0x89>

    endofargs:
	args->curarg = 0;
  80113f:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801146:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80114b:	eb 05                	jmp    801152 <argnext+0x89>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  80114d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801152:	83 c4 14             	add    $0x14,%esp
  801155:	5b                   	pop    %ebx
  801156:	5d                   	pop    %ebp
  801157:	c3                   	ret    

00801158 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801158:	55                   	push   %ebp
  801159:	89 e5                	mov    %esp,%ebp
  80115b:	53                   	push   %ebx
  80115c:	83 ec 14             	sub    $0x14,%esp
  80115f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801162:	8b 43 08             	mov    0x8(%ebx),%eax
  801165:	85 c0                	test   %eax,%eax
  801167:	74 59                	je     8011c2 <argnextvalue+0x6a>
		return 0;
	if (*args->curarg) {
  801169:	80 38 00             	cmpb   $0x0,(%eax)
  80116c:	74 0c                	je     80117a <argnextvalue+0x22>
		args->argvalue = args->curarg;
  80116e:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801171:	c7 43 08 e8 24 80 00 	movl   $0x8024e8,0x8(%ebx)
  801178:	eb 43                	jmp    8011bd <argnextvalue+0x65>
	} else if (*args->argc > 1) {
  80117a:	8b 03                	mov    (%ebx),%eax
  80117c:	83 38 01             	cmpl   $0x1,(%eax)
  80117f:	7e 2e                	jle    8011af <argnextvalue+0x57>
		args->argvalue = args->argv[1];
  801181:	8b 53 04             	mov    0x4(%ebx),%edx
  801184:	8b 4a 04             	mov    0x4(%edx),%ecx
  801187:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  80118a:	8b 00                	mov    (%eax),%eax
  80118c:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801193:	89 44 24 08          	mov    %eax,0x8(%esp)
  801197:	8d 42 08             	lea    0x8(%edx),%eax
  80119a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80119e:	83 c2 04             	add    $0x4,%edx
  8011a1:	89 14 24             	mov    %edx,(%esp)
  8011a4:	e8 03 fa ff ff       	call   800bac <memmove>
		(*args->argc)--;
  8011a9:	8b 03                	mov    (%ebx),%eax
  8011ab:	ff 08                	decl   (%eax)
  8011ad:	eb 0e                	jmp    8011bd <argnextvalue+0x65>
	} else {
		args->argvalue = 0;
  8011af:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  8011b6:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  8011bd:	8b 43 0c             	mov    0xc(%ebx),%eax
  8011c0:	eb 05                	jmp    8011c7 <argnextvalue+0x6f>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  8011c2:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  8011c7:	83 c4 14             	add    $0x14,%esp
  8011ca:	5b                   	pop    %ebx
  8011cb:	5d                   	pop    %ebp
  8011cc:	c3                   	ret    

008011cd <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  8011cd:	55                   	push   %ebp
  8011ce:	89 e5                	mov    %esp,%ebp
  8011d0:	83 ec 18             	sub    $0x18,%esp
  8011d3:	8b 55 08             	mov    0x8(%ebp),%edx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  8011d6:	8b 42 0c             	mov    0xc(%edx),%eax
  8011d9:	85 c0                	test   %eax,%eax
  8011db:	75 08                	jne    8011e5 <argvalue+0x18>
  8011dd:	89 14 24             	mov    %edx,(%esp)
  8011e0:	e8 73 ff ff ff       	call   801158 <argnextvalue>
}
  8011e5:	c9                   	leave  
  8011e6:	c3                   	ret    
	...

008011e8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011e8:	55                   	push   %ebp
  8011e9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ee:	05 00 00 00 30       	add    $0x30000000,%eax
  8011f3:	c1 e8 0c             	shr    $0xc,%eax
}
  8011f6:	5d                   	pop    %ebp
  8011f7:	c3                   	ret    

008011f8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011f8:	55                   	push   %ebp
  8011f9:	89 e5                	mov    %esp,%ebp
  8011fb:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8011fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801201:	89 04 24             	mov    %eax,(%esp)
  801204:	e8 df ff ff ff       	call   8011e8 <fd2num>
  801209:	05 20 00 0d 00       	add    $0xd0020,%eax
  80120e:	c1 e0 0c             	shl    $0xc,%eax
}
  801211:	c9                   	leave  
  801212:	c3                   	ret    

00801213 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801213:	55                   	push   %ebp
  801214:	89 e5                	mov    %esp,%ebp
  801216:	53                   	push   %ebx
  801217:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80121a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80121f:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801221:	89 c2                	mov    %eax,%edx
  801223:	c1 ea 16             	shr    $0x16,%edx
  801226:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80122d:	f6 c2 01             	test   $0x1,%dl
  801230:	74 11                	je     801243 <fd_alloc+0x30>
  801232:	89 c2                	mov    %eax,%edx
  801234:	c1 ea 0c             	shr    $0xc,%edx
  801237:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80123e:	f6 c2 01             	test   $0x1,%dl
  801241:	75 09                	jne    80124c <fd_alloc+0x39>
			*fd_store = fd;
  801243:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801245:	b8 00 00 00 00       	mov    $0x0,%eax
  80124a:	eb 17                	jmp    801263 <fd_alloc+0x50>
  80124c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801251:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801256:	75 c7                	jne    80121f <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801258:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80125e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801263:	5b                   	pop    %ebx
  801264:	5d                   	pop    %ebp
  801265:	c3                   	ret    

00801266 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801266:	55                   	push   %ebp
  801267:	89 e5                	mov    %esp,%ebp
  801269:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80126c:	83 f8 1f             	cmp    $0x1f,%eax
  80126f:	77 36                	ja     8012a7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801271:	05 00 00 0d 00       	add    $0xd0000,%eax
  801276:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801279:	89 c2                	mov    %eax,%edx
  80127b:	c1 ea 16             	shr    $0x16,%edx
  80127e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801285:	f6 c2 01             	test   $0x1,%dl
  801288:	74 24                	je     8012ae <fd_lookup+0x48>
  80128a:	89 c2                	mov    %eax,%edx
  80128c:	c1 ea 0c             	shr    $0xc,%edx
  80128f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801296:	f6 c2 01             	test   $0x1,%dl
  801299:	74 1a                	je     8012b5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80129b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80129e:	89 02                	mov    %eax,(%edx)
	return 0;
  8012a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a5:	eb 13                	jmp    8012ba <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012ac:	eb 0c                	jmp    8012ba <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012b3:	eb 05                	jmp    8012ba <fd_lookup+0x54>
  8012b5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012ba:	5d                   	pop    %ebp
  8012bb:	c3                   	ret    

008012bc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012bc:	55                   	push   %ebp
  8012bd:	89 e5                	mov    %esp,%ebp
  8012bf:	53                   	push   %ebx
  8012c0:	83 ec 14             	sub    $0x14,%esp
  8012c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8012c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8012ce:	eb 0e                	jmp    8012de <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8012d0:	39 08                	cmp    %ecx,(%eax)
  8012d2:	75 09                	jne    8012dd <dev_lookup+0x21>
			*dev = devtab[i];
  8012d4:	89 03                	mov    %eax,(%ebx)
			return 0;
  8012d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8012db:	eb 33                	jmp    801310 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012dd:	42                   	inc    %edx
  8012de:	8b 04 95 e8 28 80 00 	mov    0x8028e8(,%edx,4),%eax
  8012e5:	85 c0                	test   %eax,%eax
  8012e7:	75 e7                	jne    8012d0 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012e9:	a1 20 44 80 00       	mov    0x804420,%eax
  8012ee:	8b 40 48             	mov    0x48(%eax),%eax
  8012f1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012f9:	c7 04 24 6c 28 80 00 	movl   $0x80286c,(%esp)
  801300:	e8 83 f1 ff ff       	call   800488 <cprintf>
	*dev = 0;
  801305:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80130b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801310:	83 c4 14             	add    $0x14,%esp
  801313:	5b                   	pop    %ebx
  801314:	5d                   	pop    %ebp
  801315:	c3                   	ret    

00801316 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801316:	55                   	push   %ebp
  801317:	89 e5                	mov    %esp,%ebp
  801319:	56                   	push   %esi
  80131a:	53                   	push   %ebx
  80131b:	83 ec 30             	sub    $0x30,%esp
  80131e:	8b 75 08             	mov    0x8(%ebp),%esi
  801321:	8a 45 0c             	mov    0xc(%ebp),%al
  801324:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801327:	89 34 24             	mov    %esi,(%esp)
  80132a:	e8 b9 fe ff ff       	call   8011e8 <fd2num>
  80132f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801332:	89 54 24 04          	mov    %edx,0x4(%esp)
  801336:	89 04 24             	mov    %eax,(%esp)
  801339:	e8 28 ff ff ff       	call   801266 <fd_lookup>
  80133e:	89 c3                	mov    %eax,%ebx
  801340:	85 c0                	test   %eax,%eax
  801342:	78 05                	js     801349 <fd_close+0x33>
	    || fd != fd2)
  801344:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801347:	74 0d                	je     801356 <fd_close+0x40>
		return (must_exist ? r : 0);
  801349:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80134d:	75 46                	jne    801395 <fd_close+0x7f>
  80134f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801354:	eb 3f                	jmp    801395 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801356:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801359:	89 44 24 04          	mov    %eax,0x4(%esp)
  80135d:	8b 06                	mov    (%esi),%eax
  80135f:	89 04 24             	mov    %eax,(%esp)
  801362:	e8 55 ff ff ff       	call   8012bc <dev_lookup>
  801367:	89 c3                	mov    %eax,%ebx
  801369:	85 c0                	test   %eax,%eax
  80136b:	78 18                	js     801385 <fd_close+0x6f>
		if (dev->dev_close)
  80136d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801370:	8b 40 10             	mov    0x10(%eax),%eax
  801373:	85 c0                	test   %eax,%eax
  801375:	74 09                	je     801380 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801377:	89 34 24             	mov    %esi,(%esp)
  80137a:	ff d0                	call   *%eax
  80137c:	89 c3                	mov    %eax,%ebx
  80137e:	eb 05                	jmp    801385 <fd_close+0x6f>
		else
			r = 0;
  801380:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801385:	89 74 24 04          	mov    %esi,0x4(%esp)
  801389:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801390:	e8 37 fb ff ff       	call   800ecc <sys_page_unmap>
	return r;
}
  801395:	89 d8                	mov    %ebx,%eax
  801397:	83 c4 30             	add    $0x30,%esp
  80139a:	5b                   	pop    %ebx
  80139b:	5e                   	pop    %esi
  80139c:	5d                   	pop    %ebp
  80139d:	c3                   	ret    

0080139e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80139e:	55                   	push   %ebp
  80139f:	89 e5                	mov    %esp,%ebp
  8013a1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ae:	89 04 24             	mov    %eax,(%esp)
  8013b1:	e8 b0 fe ff ff       	call   801266 <fd_lookup>
  8013b6:	85 c0                	test   %eax,%eax
  8013b8:	78 13                	js     8013cd <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8013ba:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8013c1:	00 
  8013c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013c5:	89 04 24             	mov    %eax,(%esp)
  8013c8:	e8 49 ff ff ff       	call   801316 <fd_close>
}
  8013cd:	c9                   	leave  
  8013ce:	c3                   	ret    

008013cf <close_all>:

void
close_all(void)
{
  8013cf:	55                   	push   %ebp
  8013d0:	89 e5                	mov    %esp,%ebp
  8013d2:	53                   	push   %ebx
  8013d3:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013d6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013db:	89 1c 24             	mov    %ebx,(%esp)
  8013de:	e8 bb ff ff ff       	call   80139e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013e3:	43                   	inc    %ebx
  8013e4:	83 fb 20             	cmp    $0x20,%ebx
  8013e7:	75 f2                	jne    8013db <close_all+0xc>
		close(i);
}
  8013e9:	83 c4 14             	add    $0x14,%esp
  8013ec:	5b                   	pop    %ebx
  8013ed:	5d                   	pop    %ebp
  8013ee:	c3                   	ret    

008013ef <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013ef:	55                   	push   %ebp
  8013f0:	89 e5                	mov    %esp,%ebp
  8013f2:	57                   	push   %edi
  8013f3:	56                   	push   %esi
  8013f4:	53                   	push   %ebx
  8013f5:	83 ec 4c             	sub    $0x4c,%esp
  8013f8:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013fb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801402:	8b 45 08             	mov    0x8(%ebp),%eax
  801405:	89 04 24             	mov    %eax,(%esp)
  801408:	e8 59 fe ff ff       	call   801266 <fd_lookup>
  80140d:	89 c3                	mov    %eax,%ebx
  80140f:	85 c0                	test   %eax,%eax
  801411:	0f 88 e1 00 00 00    	js     8014f8 <dup+0x109>
		return r;
	close(newfdnum);
  801417:	89 3c 24             	mov    %edi,(%esp)
  80141a:	e8 7f ff ff ff       	call   80139e <close>

	newfd = INDEX2FD(newfdnum);
  80141f:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801425:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801428:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80142b:	89 04 24             	mov    %eax,(%esp)
  80142e:	e8 c5 fd ff ff       	call   8011f8 <fd2data>
  801433:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801435:	89 34 24             	mov    %esi,(%esp)
  801438:	e8 bb fd ff ff       	call   8011f8 <fd2data>
  80143d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801440:	89 d8                	mov    %ebx,%eax
  801442:	c1 e8 16             	shr    $0x16,%eax
  801445:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80144c:	a8 01                	test   $0x1,%al
  80144e:	74 46                	je     801496 <dup+0xa7>
  801450:	89 d8                	mov    %ebx,%eax
  801452:	c1 e8 0c             	shr    $0xc,%eax
  801455:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80145c:	f6 c2 01             	test   $0x1,%dl
  80145f:	74 35                	je     801496 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801461:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801468:	25 07 0e 00 00       	and    $0xe07,%eax
  80146d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801471:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801474:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801478:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80147f:	00 
  801480:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801484:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80148b:	e8 e9 f9 ff ff       	call   800e79 <sys_page_map>
  801490:	89 c3                	mov    %eax,%ebx
  801492:	85 c0                	test   %eax,%eax
  801494:	78 3b                	js     8014d1 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801496:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801499:	89 c2                	mov    %eax,%edx
  80149b:	c1 ea 0c             	shr    $0xc,%edx
  80149e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014a5:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8014ab:	89 54 24 10          	mov    %edx,0x10(%esp)
  8014af:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8014b3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014ba:	00 
  8014bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014c6:	e8 ae f9 ff ff       	call   800e79 <sys_page_map>
  8014cb:	89 c3                	mov    %eax,%ebx
  8014cd:	85 c0                	test   %eax,%eax
  8014cf:	79 25                	jns    8014f6 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014d1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014dc:	e8 eb f9 ff ff       	call   800ecc <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014e1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8014e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014ef:	e8 d8 f9 ff ff       	call   800ecc <sys_page_unmap>
	return r;
  8014f4:	eb 02                	jmp    8014f8 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8014f6:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8014f8:	89 d8                	mov    %ebx,%eax
  8014fa:	83 c4 4c             	add    $0x4c,%esp
  8014fd:	5b                   	pop    %ebx
  8014fe:	5e                   	pop    %esi
  8014ff:	5f                   	pop    %edi
  801500:	5d                   	pop    %ebp
  801501:	c3                   	ret    

00801502 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801502:	55                   	push   %ebp
  801503:	89 e5                	mov    %esp,%ebp
  801505:	53                   	push   %ebx
  801506:	83 ec 24             	sub    $0x24,%esp
  801509:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80150c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80150f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801513:	89 1c 24             	mov    %ebx,(%esp)
  801516:	e8 4b fd ff ff       	call   801266 <fd_lookup>
  80151b:	85 c0                	test   %eax,%eax
  80151d:	78 6d                	js     80158c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80151f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801522:	89 44 24 04          	mov    %eax,0x4(%esp)
  801526:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801529:	8b 00                	mov    (%eax),%eax
  80152b:	89 04 24             	mov    %eax,(%esp)
  80152e:	e8 89 fd ff ff       	call   8012bc <dev_lookup>
  801533:	85 c0                	test   %eax,%eax
  801535:	78 55                	js     80158c <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801537:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80153a:	8b 50 08             	mov    0x8(%eax),%edx
  80153d:	83 e2 03             	and    $0x3,%edx
  801540:	83 fa 01             	cmp    $0x1,%edx
  801543:	75 23                	jne    801568 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801545:	a1 20 44 80 00       	mov    0x804420,%eax
  80154a:	8b 40 48             	mov    0x48(%eax),%eax
  80154d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801551:	89 44 24 04          	mov    %eax,0x4(%esp)
  801555:	c7 04 24 ad 28 80 00 	movl   $0x8028ad,(%esp)
  80155c:	e8 27 ef ff ff       	call   800488 <cprintf>
		return -E_INVAL;
  801561:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801566:	eb 24                	jmp    80158c <read+0x8a>
	}
	if (!dev->dev_read)
  801568:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80156b:	8b 52 08             	mov    0x8(%edx),%edx
  80156e:	85 d2                	test   %edx,%edx
  801570:	74 15                	je     801587 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801572:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801575:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801579:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80157c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801580:	89 04 24             	mov    %eax,(%esp)
  801583:	ff d2                	call   *%edx
  801585:	eb 05                	jmp    80158c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801587:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80158c:	83 c4 24             	add    $0x24,%esp
  80158f:	5b                   	pop    %ebx
  801590:	5d                   	pop    %ebp
  801591:	c3                   	ret    

00801592 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801592:	55                   	push   %ebp
  801593:	89 e5                	mov    %esp,%ebp
  801595:	57                   	push   %edi
  801596:	56                   	push   %esi
  801597:	53                   	push   %ebx
  801598:	83 ec 1c             	sub    $0x1c,%esp
  80159b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80159e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015a1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015a6:	eb 23                	jmp    8015cb <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015a8:	89 f0                	mov    %esi,%eax
  8015aa:	29 d8                	sub    %ebx,%eax
  8015ac:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015b3:	01 d8                	add    %ebx,%eax
  8015b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015b9:	89 3c 24             	mov    %edi,(%esp)
  8015bc:	e8 41 ff ff ff       	call   801502 <read>
		if (m < 0)
  8015c1:	85 c0                	test   %eax,%eax
  8015c3:	78 10                	js     8015d5 <readn+0x43>
			return m;
		if (m == 0)
  8015c5:	85 c0                	test   %eax,%eax
  8015c7:	74 0a                	je     8015d3 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015c9:	01 c3                	add    %eax,%ebx
  8015cb:	39 f3                	cmp    %esi,%ebx
  8015cd:	72 d9                	jb     8015a8 <readn+0x16>
  8015cf:	89 d8                	mov    %ebx,%eax
  8015d1:	eb 02                	jmp    8015d5 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8015d3:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8015d5:	83 c4 1c             	add    $0x1c,%esp
  8015d8:	5b                   	pop    %ebx
  8015d9:	5e                   	pop    %esi
  8015da:	5f                   	pop    %edi
  8015db:	5d                   	pop    %ebp
  8015dc:	c3                   	ret    

008015dd <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015dd:	55                   	push   %ebp
  8015de:	89 e5                	mov    %esp,%ebp
  8015e0:	53                   	push   %ebx
  8015e1:	83 ec 24             	sub    $0x24,%esp
  8015e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015e7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015ee:	89 1c 24             	mov    %ebx,(%esp)
  8015f1:	e8 70 fc ff ff       	call   801266 <fd_lookup>
  8015f6:	85 c0                	test   %eax,%eax
  8015f8:	78 68                	js     801662 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801601:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801604:	8b 00                	mov    (%eax),%eax
  801606:	89 04 24             	mov    %eax,(%esp)
  801609:	e8 ae fc ff ff       	call   8012bc <dev_lookup>
  80160e:	85 c0                	test   %eax,%eax
  801610:	78 50                	js     801662 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801612:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801615:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801619:	75 23                	jne    80163e <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80161b:	a1 20 44 80 00       	mov    0x804420,%eax
  801620:	8b 40 48             	mov    0x48(%eax),%eax
  801623:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801627:	89 44 24 04          	mov    %eax,0x4(%esp)
  80162b:	c7 04 24 c9 28 80 00 	movl   $0x8028c9,(%esp)
  801632:	e8 51 ee ff ff       	call   800488 <cprintf>
		return -E_INVAL;
  801637:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80163c:	eb 24                	jmp    801662 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80163e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801641:	8b 52 0c             	mov    0xc(%edx),%edx
  801644:	85 d2                	test   %edx,%edx
  801646:	74 15                	je     80165d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801648:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80164b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80164f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801652:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801656:	89 04 24             	mov    %eax,(%esp)
  801659:	ff d2                	call   *%edx
  80165b:	eb 05                	jmp    801662 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80165d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801662:	83 c4 24             	add    $0x24,%esp
  801665:	5b                   	pop    %ebx
  801666:	5d                   	pop    %ebp
  801667:	c3                   	ret    

00801668 <seek>:

int
seek(int fdnum, off_t offset)
{
  801668:	55                   	push   %ebp
  801669:	89 e5                	mov    %esp,%ebp
  80166b:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80166e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801671:	89 44 24 04          	mov    %eax,0x4(%esp)
  801675:	8b 45 08             	mov    0x8(%ebp),%eax
  801678:	89 04 24             	mov    %eax,(%esp)
  80167b:	e8 e6 fb ff ff       	call   801266 <fd_lookup>
  801680:	85 c0                	test   %eax,%eax
  801682:	78 0e                	js     801692 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801684:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801687:	8b 55 0c             	mov    0xc(%ebp),%edx
  80168a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80168d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801692:	c9                   	leave  
  801693:	c3                   	ret    

00801694 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801694:	55                   	push   %ebp
  801695:	89 e5                	mov    %esp,%ebp
  801697:	53                   	push   %ebx
  801698:	83 ec 24             	sub    $0x24,%esp
  80169b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80169e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016a5:	89 1c 24             	mov    %ebx,(%esp)
  8016a8:	e8 b9 fb ff ff       	call   801266 <fd_lookup>
  8016ad:	85 c0                	test   %eax,%eax
  8016af:	78 61                	js     801712 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016bb:	8b 00                	mov    (%eax),%eax
  8016bd:	89 04 24             	mov    %eax,(%esp)
  8016c0:	e8 f7 fb ff ff       	call   8012bc <dev_lookup>
  8016c5:	85 c0                	test   %eax,%eax
  8016c7:	78 49                	js     801712 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016cc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016d0:	75 23                	jne    8016f5 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016d2:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016d7:	8b 40 48             	mov    0x48(%eax),%eax
  8016da:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016e2:	c7 04 24 8c 28 80 00 	movl   $0x80288c,(%esp)
  8016e9:	e8 9a ed ff ff       	call   800488 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016f3:	eb 1d                	jmp    801712 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8016f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016f8:	8b 52 18             	mov    0x18(%edx),%edx
  8016fb:	85 d2                	test   %edx,%edx
  8016fd:	74 0e                	je     80170d <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801702:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801706:	89 04 24             	mov    %eax,(%esp)
  801709:	ff d2                	call   *%edx
  80170b:	eb 05                	jmp    801712 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80170d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801712:	83 c4 24             	add    $0x24,%esp
  801715:	5b                   	pop    %ebx
  801716:	5d                   	pop    %ebp
  801717:	c3                   	ret    

00801718 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801718:	55                   	push   %ebp
  801719:	89 e5                	mov    %esp,%ebp
  80171b:	53                   	push   %ebx
  80171c:	83 ec 24             	sub    $0x24,%esp
  80171f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801722:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801725:	89 44 24 04          	mov    %eax,0x4(%esp)
  801729:	8b 45 08             	mov    0x8(%ebp),%eax
  80172c:	89 04 24             	mov    %eax,(%esp)
  80172f:	e8 32 fb ff ff       	call   801266 <fd_lookup>
  801734:	85 c0                	test   %eax,%eax
  801736:	78 52                	js     80178a <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801738:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80173b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80173f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801742:	8b 00                	mov    (%eax),%eax
  801744:	89 04 24             	mov    %eax,(%esp)
  801747:	e8 70 fb ff ff       	call   8012bc <dev_lookup>
  80174c:	85 c0                	test   %eax,%eax
  80174e:	78 3a                	js     80178a <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801750:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801753:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801757:	74 2c                	je     801785 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801759:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80175c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801763:	00 00 00 
	stat->st_isdir = 0;
  801766:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80176d:	00 00 00 
	stat->st_dev = dev;
  801770:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801776:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80177a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80177d:	89 14 24             	mov    %edx,(%esp)
  801780:	ff 50 14             	call   *0x14(%eax)
  801783:	eb 05                	jmp    80178a <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801785:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80178a:	83 c4 24             	add    $0x24,%esp
  80178d:	5b                   	pop    %ebx
  80178e:	5d                   	pop    %ebp
  80178f:	c3                   	ret    

00801790 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801790:	55                   	push   %ebp
  801791:	89 e5                	mov    %esp,%ebp
  801793:	56                   	push   %esi
  801794:	53                   	push   %ebx
  801795:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801798:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80179f:	00 
  8017a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a3:	89 04 24             	mov    %eax,(%esp)
  8017a6:	e8 2d 02 00 00       	call   8019d8 <open>
  8017ab:	89 c3                	mov    %eax,%ebx
  8017ad:	85 c0                	test   %eax,%eax
  8017af:	78 1b                	js     8017cc <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8017b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b8:	89 1c 24             	mov    %ebx,(%esp)
  8017bb:	e8 58 ff ff ff       	call   801718 <fstat>
  8017c0:	89 c6                	mov    %eax,%esi
	close(fd);
  8017c2:	89 1c 24             	mov    %ebx,(%esp)
  8017c5:	e8 d4 fb ff ff       	call   80139e <close>
	return r;
  8017ca:	89 f3                	mov    %esi,%ebx
}
  8017cc:	89 d8                	mov    %ebx,%eax
  8017ce:	83 c4 10             	add    $0x10,%esp
  8017d1:	5b                   	pop    %ebx
  8017d2:	5e                   	pop    %esi
  8017d3:	5d                   	pop    %ebp
  8017d4:	c3                   	ret    
  8017d5:	00 00                	add    %al,(%eax)
	...

008017d8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017d8:	55                   	push   %ebp
  8017d9:	89 e5                	mov    %esp,%ebp
  8017db:	56                   	push   %esi
  8017dc:	53                   	push   %ebx
  8017dd:	83 ec 10             	sub    $0x10,%esp
  8017e0:	89 c3                	mov    %eax,%ebx
  8017e2:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8017e4:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017eb:	75 11                	jne    8017fe <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017ed:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8017f4:	e8 a6 09 00 00       	call   80219f <ipc_find_env>
  8017f9:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017fe:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801805:	00 
  801806:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  80180d:	00 
  80180e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801812:	a1 00 40 80 00       	mov    0x804000,%eax
  801817:	89 04 24             	mov    %eax,(%esp)
  80181a:	e8 12 09 00 00       	call   802131 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80181f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801826:	00 
  801827:	89 74 24 04          	mov    %esi,0x4(%esp)
  80182b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801832:	e8 91 08 00 00       	call   8020c8 <ipc_recv>
}
  801837:	83 c4 10             	add    $0x10,%esp
  80183a:	5b                   	pop    %ebx
  80183b:	5e                   	pop    %esi
  80183c:	5d                   	pop    %ebp
  80183d:	c3                   	ret    

0080183e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80183e:	55                   	push   %ebp
  80183f:	89 e5                	mov    %esp,%ebp
  801841:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801844:	8b 45 08             	mov    0x8(%ebp),%eax
  801847:	8b 40 0c             	mov    0xc(%eax),%eax
  80184a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80184f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801852:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801857:	ba 00 00 00 00       	mov    $0x0,%edx
  80185c:	b8 02 00 00 00       	mov    $0x2,%eax
  801861:	e8 72 ff ff ff       	call   8017d8 <fsipc>
}
  801866:	c9                   	leave  
  801867:	c3                   	ret    

00801868 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801868:	55                   	push   %ebp
  801869:	89 e5                	mov    %esp,%ebp
  80186b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80186e:	8b 45 08             	mov    0x8(%ebp),%eax
  801871:	8b 40 0c             	mov    0xc(%eax),%eax
  801874:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801879:	ba 00 00 00 00       	mov    $0x0,%edx
  80187e:	b8 06 00 00 00       	mov    $0x6,%eax
  801883:	e8 50 ff ff ff       	call   8017d8 <fsipc>
}
  801888:	c9                   	leave  
  801889:	c3                   	ret    

0080188a <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80188a:	55                   	push   %ebp
  80188b:	89 e5                	mov    %esp,%ebp
  80188d:	53                   	push   %ebx
  80188e:	83 ec 14             	sub    $0x14,%esp
  801891:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801894:	8b 45 08             	mov    0x8(%ebp),%eax
  801897:	8b 40 0c             	mov    0xc(%eax),%eax
  80189a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80189f:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a4:	b8 05 00 00 00       	mov    $0x5,%eax
  8018a9:	e8 2a ff ff ff       	call   8017d8 <fsipc>
  8018ae:	85 c0                	test   %eax,%eax
  8018b0:	78 2b                	js     8018dd <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018b2:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8018b9:	00 
  8018ba:	89 1c 24             	mov    %ebx,(%esp)
  8018bd:	e8 71 f1 ff ff       	call   800a33 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018c2:	a1 80 50 80 00       	mov    0x805080,%eax
  8018c7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018cd:	a1 84 50 80 00       	mov    0x805084,%eax
  8018d2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018d8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018dd:	83 c4 14             	add    $0x14,%esp
  8018e0:	5b                   	pop    %ebx
  8018e1:	5d                   	pop    %ebp
  8018e2:	c3                   	ret    

008018e3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018e3:	55                   	push   %ebp
  8018e4:	89 e5                	mov    %esp,%ebp
  8018e6:	83 ec 18             	sub    $0x18,%esp
  8018e9:	8b 55 10             	mov    0x10(%ebp),%edx
  8018ec:	89 d0                	mov    %edx,%eax
  8018ee:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  8018f4:	76 05                	jbe    8018fb <devfile_write+0x18>
  8018f6:	b8 00 10 00 00       	mov    $0x1000,%eax
	//panic("devfile_write not implemented");
	int r;
	//uint32_t maxsize = BLKSIZE - sizeof(int) - sizeof(size_t);	
	if (n > BLKSIZE)
		n = BLKSIZE;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8018fe:	8b 52 0c             	mov    0xc(%edx),%edx
  801901:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801907:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80190c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801910:	8b 45 0c             	mov    0xc(%ebp),%eax
  801913:	89 44 24 04          	mov    %eax,0x4(%esp)
  801917:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  80191e:	e8 89 f2 ff ff       	call   800bac <memmove>
	 
	return fsipc(FSREQ_WRITE, NULL);
  801923:	ba 00 00 00 00       	mov    $0x0,%edx
  801928:	b8 04 00 00 00       	mov    $0x4,%eax
  80192d:	e8 a6 fe ff ff       	call   8017d8 <fsipc>
}
  801932:	c9                   	leave  
  801933:	c3                   	ret    

00801934 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801934:	55                   	push   %ebp
  801935:	89 e5                	mov    %esp,%ebp
  801937:	56                   	push   %esi
  801938:	53                   	push   %ebx
  801939:	83 ec 10             	sub    $0x10,%esp
  80193c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80193f:	8b 45 08             	mov    0x8(%ebp),%eax
  801942:	8b 40 0c             	mov    0xc(%eax),%eax
  801945:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80194a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801950:	ba 00 00 00 00       	mov    $0x0,%edx
  801955:	b8 03 00 00 00       	mov    $0x3,%eax
  80195a:	e8 79 fe ff ff       	call   8017d8 <fsipc>
  80195f:	89 c3                	mov    %eax,%ebx
  801961:	85 c0                	test   %eax,%eax
  801963:	78 6a                	js     8019cf <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801965:	39 c6                	cmp    %eax,%esi
  801967:	73 24                	jae    80198d <devfile_read+0x59>
  801969:	c7 44 24 0c f8 28 80 	movl   $0x8028f8,0xc(%esp)
  801970:	00 
  801971:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  801978:	00 
  801979:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801980:	00 
  801981:	c7 04 24 14 29 80 00 	movl   $0x802914,(%esp)
  801988:	e8 03 ea ff ff       	call   800390 <_panic>
	assert(r <= PGSIZE);
  80198d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801992:	7e 24                	jle    8019b8 <devfile_read+0x84>
  801994:	c7 44 24 0c 1f 29 80 	movl   $0x80291f,0xc(%esp)
  80199b:	00 
  80199c:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  8019a3:	00 
  8019a4:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8019ab:	00 
  8019ac:	c7 04 24 14 29 80 00 	movl   $0x802914,(%esp)
  8019b3:	e8 d8 e9 ff ff       	call   800390 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019bc:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8019c3:	00 
  8019c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019c7:	89 04 24             	mov    %eax,(%esp)
  8019ca:	e8 dd f1 ff ff       	call   800bac <memmove>
	return r;
}
  8019cf:	89 d8                	mov    %ebx,%eax
  8019d1:	83 c4 10             	add    $0x10,%esp
  8019d4:	5b                   	pop    %ebx
  8019d5:	5e                   	pop    %esi
  8019d6:	5d                   	pop    %ebp
  8019d7:	c3                   	ret    

008019d8 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019d8:	55                   	push   %ebp
  8019d9:	89 e5                	mov    %esp,%ebp
  8019db:	56                   	push   %esi
  8019dc:	53                   	push   %ebx
  8019dd:	83 ec 20             	sub    $0x20,%esp
  8019e0:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019e3:	89 34 24             	mov    %esi,(%esp)
  8019e6:	e8 15 f0 ff ff       	call   800a00 <strlen>
  8019eb:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019f0:	7f 60                	jg     801a52 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019f5:	89 04 24             	mov    %eax,(%esp)
  8019f8:	e8 16 f8 ff ff       	call   801213 <fd_alloc>
  8019fd:	89 c3                	mov    %eax,%ebx
  8019ff:	85 c0                	test   %eax,%eax
  801a01:	78 54                	js     801a57 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a03:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a07:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801a0e:	e8 20 f0 ff ff       	call   800a33 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a13:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a16:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a1b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a1e:	b8 01 00 00 00       	mov    $0x1,%eax
  801a23:	e8 b0 fd ff ff       	call   8017d8 <fsipc>
  801a28:	89 c3                	mov    %eax,%ebx
  801a2a:	85 c0                	test   %eax,%eax
  801a2c:	79 15                	jns    801a43 <open+0x6b>
		fd_close(fd, 0);
  801a2e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a35:	00 
  801a36:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a39:	89 04 24             	mov    %eax,(%esp)
  801a3c:	e8 d5 f8 ff ff       	call   801316 <fd_close>
		return r;
  801a41:	eb 14                	jmp    801a57 <open+0x7f>
	}

	return fd2num(fd);
  801a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a46:	89 04 24             	mov    %eax,(%esp)
  801a49:	e8 9a f7 ff ff       	call   8011e8 <fd2num>
  801a4e:	89 c3                	mov    %eax,%ebx
  801a50:	eb 05                	jmp    801a57 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a52:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a57:	89 d8                	mov    %ebx,%eax
  801a59:	83 c4 20             	add    $0x20,%esp
  801a5c:	5b                   	pop    %ebx
  801a5d:	5e                   	pop    %esi
  801a5e:	5d                   	pop    %ebp
  801a5f:	c3                   	ret    

00801a60 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a60:	55                   	push   %ebp
  801a61:	89 e5                	mov    %esp,%ebp
  801a63:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a66:	ba 00 00 00 00       	mov    $0x0,%edx
  801a6b:	b8 08 00 00 00       	mov    $0x8,%eax
  801a70:	e8 63 fd ff ff       	call   8017d8 <fsipc>
}
  801a75:	c9                   	leave  
  801a76:	c3                   	ret    
	...

00801a78 <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  801a78:	55                   	push   %ebp
  801a79:	89 e5                	mov    %esp,%ebp
  801a7b:	53                   	push   %ebx
  801a7c:	83 ec 14             	sub    $0x14,%esp
  801a7f:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  801a81:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801a85:	7e 32                	jle    801ab9 <writebuf+0x41>
		ssize_t result = write(b->fd, b->buf, b->idx);
  801a87:	8b 40 04             	mov    0x4(%eax),%eax
  801a8a:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a8e:	8d 43 10             	lea    0x10(%ebx),%eax
  801a91:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a95:	8b 03                	mov    (%ebx),%eax
  801a97:	89 04 24             	mov    %eax,(%esp)
  801a9a:	e8 3e fb ff ff       	call   8015dd <write>
		if (result > 0)
  801a9f:	85 c0                	test   %eax,%eax
  801aa1:	7e 03                	jle    801aa6 <writebuf+0x2e>
			b->result += result;
  801aa3:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801aa6:	39 43 04             	cmp    %eax,0x4(%ebx)
  801aa9:	74 0e                	je     801ab9 <writebuf+0x41>
			b->error = (result < 0 ? result : 0);
  801aab:	89 c2                	mov    %eax,%edx
  801aad:	85 c0                	test   %eax,%eax
  801aaf:	7e 05                	jle    801ab6 <writebuf+0x3e>
  801ab1:	ba 00 00 00 00       	mov    $0x0,%edx
  801ab6:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  801ab9:	83 c4 14             	add    $0x14,%esp
  801abc:	5b                   	pop    %ebx
  801abd:	5d                   	pop    %ebp
  801abe:	c3                   	ret    

00801abf <putch>:

static void
putch(int ch, void *thunk)
{
  801abf:	55                   	push   %ebp
  801ac0:	89 e5                	mov    %esp,%ebp
  801ac2:	53                   	push   %ebx
  801ac3:	83 ec 04             	sub    $0x4,%esp
  801ac6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801ac9:	8b 43 04             	mov    0x4(%ebx),%eax
  801acc:	8b 55 08             	mov    0x8(%ebp),%edx
  801acf:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  801ad3:	40                   	inc    %eax
  801ad4:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  801ad7:	3d 00 01 00 00       	cmp    $0x100,%eax
  801adc:	75 0e                	jne    801aec <putch+0x2d>
		writebuf(b);
  801ade:	89 d8                	mov    %ebx,%eax
  801ae0:	e8 93 ff ff ff       	call   801a78 <writebuf>
		b->idx = 0;
  801ae5:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801aec:	83 c4 04             	add    $0x4,%esp
  801aef:	5b                   	pop    %ebx
  801af0:	5d                   	pop    %ebp
  801af1:	c3                   	ret    

00801af2 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801af2:	55                   	push   %ebp
  801af3:	89 e5                	mov    %esp,%ebp
  801af5:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  801afb:	8b 45 08             	mov    0x8(%ebp),%eax
  801afe:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801b04:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801b0b:	00 00 00 
	b.result = 0;
  801b0e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801b15:	00 00 00 
	b.error = 1;
  801b18:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801b1f:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801b22:	8b 45 10             	mov    0x10(%ebp),%eax
  801b25:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b29:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b2c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b30:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801b36:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b3a:	c7 04 24 bf 1a 80 00 	movl   $0x801abf,(%esp)
  801b41:	e8 a4 ea ff ff       	call   8005ea <vprintfmt>
	if (b.idx > 0)
  801b46:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801b4d:	7e 0b                	jle    801b5a <vfprintf+0x68>
		writebuf(&b);
  801b4f:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801b55:	e8 1e ff ff ff       	call   801a78 <writebuf>

	return (b.result ? b.result : b.error);
  801b5a:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801b60:	85 c0                	test   %eax,%eax
  801b62:	75 06                	jne    801b6a <vfprintf+0x78>
  801b64:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  801b6a:	c9                   	leave  
  801b6b:	c3                   	ret    

00801b6c <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801b6c:	55                   	push   %ebp
  801b6d:	89 e5                	mov    %esp,%ebp
  801b6f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801b72:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801b75:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b79:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b7c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b80:	8b 45 08             	mov    0x8(%ebp),%eax
  801b83:	89 04 24             	mov    %eax,(%esp)
  801b86:	e8 67 ff ff ff       	call   801af2 <vfprintf>
	va_end(ap);

	return cnt;
}
  801b8b:	c9                   	leave  
  801b8c:	c3                   	ret    

00801b8d <printf>:

int
printf(const char *fmt, ...)
{
  801b8d:	55                   	push   %ebp
  801b8e:	89 e5                	mov    %esp,%ebp
  801b90:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801b93:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801b96:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b9a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b9d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ba1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801ba8:	e8 45 ff ff ff       	call   801af2 <vfprintf>
	va_end(ap);

	return cnt;
}
  801bad:	c9                   	leave  
  801bae:	c3                   	ret    
	...

00801bb0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801bb0:	55                   	push   %ebp
  801bb1:	89 e5                	mov    %esp,%ebp
  801bb3:	56                   	push   %esi
  801bb4:	53                   	push   %ebx
  801bb5:	83 ec 10             	sub    $0x10,%esp
  801bb8:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801bbb:	8b 45 08             	mov    0x8(%ebp),%eax
  801bbe:	89 04 24             	mov    %eax,(%esp)
  801bc1:	e8 32 f6 ff ff       	call   8011f8 <fd2data>
  801bc6:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801bc8:	c7 44 24 04 2b 29 80 	movl   $0x80292b,0x4(%esp)
  801bcf:	00 
  801bd0:	89 34 24             	mov    %esi,(%esp)
  801bd3:	e8 5b ee ff ff       	call   800a33 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801bd8:	8b 43 04             	mov    0x4(%ebx),%eax
  801bdb:	2b 03                	sub    (%ebx),%eax
  801bdd:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801be3:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801bea:	00 00 00 
	stat->st_dev = &devpipe;
  801bed:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801bf4:	30 80 00 
	return 0;
}
  801bf7:	b8 00 00 00 00       	mov    $0x0,%eax
  801bfc:	83 c4 10             	add    $0x10,%esp
  801bff:	5b                   	pop    %ebx
  801c00:	5e                   	pop    %esi
  801c01:	5d                   	pop    %ebp
  801c02:	c3                   	ret    

00801c03 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c03:	55                   	push   %ebp
  801c04:	89 e5                	mov    %esp,%ebp
  801c06:	53                   	push   %ebx
  801c07:	83 ec 14             	sub    $0x14,%esp
  801c0a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c0d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c11:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c18:	e8 af f2 ff ff       	call   800ecc <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c1d:	89 1c 24             	mov    %ebx,(%esp)
  801c20:	e8 d3 f5 ff ff       	call   8011f8 <fd2data>
  801c25:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c29:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c30:	e8 97 f2 ff ff       	call   800ecc <sys_page_unmap>
}
  801c35:	83 c4 14             	add    $0x14,%esp
  801c38:	5b                   	pop    %ebx
  801c39:	5d                   	pop    %ebp
  801c3a:	c3                   	ret    

00801c3b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c3b:	55                   	push   %ebp
  801c3c:	89 e5                	mov    %esp,%ebp
  801c3e:	57                   	push   %edi
  801c3f:	56                   	push   %esi
  801c40:	53                   	push   %ebx
  801c41:	83 ec 2c             	sub    $0x2c,%esp
  801c44:	89 c7                	mov    %eax,%edi
  801c46:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c49:	a1 20 44 80 00       	mov    0x804420,%eax
  801c4e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801c51:	89 3c 24             	mov    %edi,(%esp)
  801c54:	e8 8b 05 00 00       	call   8021e4 <pageref>
  801c59:	89 c6                	mov    %eax,%esi
  801c5b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c5e:	89 04 24             	mov    %eax,(%esp)
  801c61:	e8 7e 05 00 00       	call   8021e4 <pageref>
  801c66:	39 c6                	cmp    %eax,%esi
  801c68:	0f 94 c0             	sete   %al
  801c6b:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801c6e:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801c74:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c77:	39 cb                	cmp    %ecx,%ebx
  801c79:	75 08                	jne    801c83 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801c7b:	83 c4 2c             	add    $0x2c,%esp
  801c7e:	5b                   	pop    %ebx
  801c7f:	5e                   	pop    %esi
  801c80:	5f                   	pop    %edi
  801c81:	5d                   	pop    %ebp
  801c82:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801c83:	83 f8 01             	cmp    $0x1,%eax
  801c86:	75 c1                	jne    801c49 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c88:	8b 42 58             	mov    0x58(%edx),%eax
  801c8b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801c92:	00 
  801c93:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c97:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c9b:	c7 04 24 32 29 80 00 	movl   $0x802932,(%esp)
  801ca2:	e8 e1 e7 ff ff       	call   800488 <cprintf>
  801ca7:	eb a0                	jmp    801c49 <_pipeisclosed+0xe>

00801ca9 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ca9:	55                   	push   %ebp
  801caa:	89 e5                	mov    %esp,%ebp
  801cac:	57                   	push   %edi
  801cad:	56                   	push   %esi
  801cae:	53                   	push   %ebx
  801caf:	83 ec 1c             	sub    $0x1c,%esp
  801cb2:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801cb5:	89 34 24             	mov    %esi,(%esp)
  801cb8:	e8 3b f5 ff ff       	call   8011f8 <fd2data>
  801cbd:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cbf:	bf 00 00 00 00       	mov    $0x0,%edi
  801cc4:	eb 3c                	jmp    801d02 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801cc6:	89 da                	mov    %ebx,%edx
  801cc8:	89 f0                	mov    %esi,%eax
  801cca:	e8 6c ff ff ff       	call   801c3b <_pipeisclosed>
  801ccf:	85 c0                	test   %eax,%eax
  801cd1:	75 38                	jne    801d0b <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801cd3:	e8 2e f1 ff ff       	call   800e06 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801cd8:	8b 43 04             	mov    0x4(%ebx),%eax
  801cdb:	8b 13                	mov    (%ebx),%edx
  801cdd:	83 c2 20             	add    $0x20,%edx
  801ce0:	39 d0                	cmp    %edx,%eax
  801ce2:	73 e2                	jae    801cc6 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ce4:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ce7:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801cea:	89 c2                	mov    %eax,%edx
  801cec:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801cf2:	79 05                	jns    801cf9 <devpipe_write+0x50>
  801cf4:	4a                   	dec    %edx
  801cf5:	83 ca e0             	or     $0xffffffe0,%edx
  801cf8:	42                   	inc    %edx
  801cf9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801cfd:	40                   	inc    %eax
  801cfe:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d01:	47                   	inc    %edi
  801d02:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d05:	75 d1                	jne    801cd8 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d07:	89 f8                	mov    %edi,%eax
  801d09:	eb 05                	jmp    801d10 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d0b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d10:	83 c4 1c             	add    $0x1c,%esp
  801d13:	5b                   	pop    %ebx
  801d14:	5e                   	pop    %esi
  801d15:	5f                   	pop    %edi
  801d16:	5d                   	pop    %ebp
  801d17:	c3                   	ret    

00801d18 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d18:	55                   	push   %ebp
  801d19:	89 e5                	mov    %esp,%ebp
  801d1b:	57                   	push   %edi
  801d1c:	56                   	push   %esi
  801d1d:	53                   	push   %ebx
  801d1e:	83 ec 1c             	sub    $0x1c,%esp
  801d21:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d24:	89 3c 24             	mov    %edi,(%esp)
  801d27:	e8 cc f4 ff ff       	call   8011f8 <fd2data>
  801d2c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d2e:	be 00 00 00 00       	mov    $0x0,%esi
  801d33:	eb 3a                	jmp    801d6f <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d35:	85 f6                	test   %esi,%esi
  801d37:	74 04                	je     801d3d <devpipe_read+0x25>
				return i;
  801d39:	89 f0                	mov    %esi,%eax
  801d3b:	eb 40                	jmp    801d7d <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d3d:	89 da                	mov    %ebx,%edx
  801d3f:	89 f8                	mov    %edi,%eax
  801d41:	e8 f5 fe ff ff       	call   801c3b <_pipeisclosed>
  801d46:	85 c0                	test   %eax,%eax
  801d48:	75 2e                	jne    801d78 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d4a:	e8 b7 f0 ff ff       	call   800e06 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d4f:	8b 03                	mov    (%ebx),%eax
  801d51:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d54:	74 df                	je     801d35 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d56:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801d5b:	79 05                	jns    801d62 <devpipe_read+0x4a>
  801d5d:	48                   	dec    %eax
  801d5e:	83 c8 e0             	or     $0xffffffe0,%eax
  801d61:	40                   	inc    %eax
  801d62:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801d66:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d69:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801d6c:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d6e:	46                   	inc    %esi
  801d6f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d72:	75 db                	jne    801d4f <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d74:	89 f0                	mov    %esi,%eax
  801d76:	eb 05                	jmp    801d7d <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d78:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d7d:	83 c4 1c             	add    $0x1c,%esp
  801d80:	5b                   	pop    %ebx
  801d81:	5e                   	pop    %esi
  801d82:	5f                   	pop    %edi
  801d83:	5d                   	pop    %ebp
  801d84:	c3                   	ret    

00801d85 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d85:	55                   	push   %ebp
  801d86:	89 e5                	mov    %esp,%ebp
  801d88:	57                   	push   %edi
  801d89:	56                   	push   %esi
  801d8a:	53                   	push   %ebx
  801d8b:	83 ec 3c             	sub    $0x3c,%esp
  801d8e:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d91:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801d94:	89 04 24             	mov    %eax,(%esp)
  801d97:	e8 77 f4 ff ff       	call   801213 <fd_alloc>
  801d9c:	89 c3                	mov    %eax,%ebx
  801d9e:	85 c0                	test   %eax,%eax
  801da0:	0f 88 45 01 00 00    	js     801eeb <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801da6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801dad:	00 
  801dae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801db1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801db5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dbc:	e8 64 f0 ff ff       	call   800e25 <sys_page_alloc>
  801dc1:	89 c3                	mov    %eax,%ebx
  801dc3:	85 c0                	test   %eax,%eax
  801dc5:	0f 88 20 01 00 00    	js     801eeb <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801dcb:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801dce:	89 04 24             	mov    %eax,(%esp)
  801dd1:	e8 3d f4 ff ff       	call   801213 <fd_alloc>
  801dd6:	89 c3                	mov    %eax,%ebx
  801dd8:	85 c0                	test   %eax,%eax
  801dda:	0f 88 f8 00 00 00    	js     801ed8 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801de0:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801de7:	00 
  801de8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801deb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801def:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801df6:	e8 2a f0 ff ff       	call   800e25 <sys_page_alloc>
  801dfb:	89 c3                	mov    %eax,%ebx
  801dfd:	85 c0                	test   %eax,%eax
  801dff:	0f 88 d3 00 00 00    	js     801ed8 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e05:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e08:	89 04 24             	mov    %eax,(%esp)
  801e0b:	e8 e8 f3 ff ff       	call   8011f8 <fd2data>
  801e10:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e12:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e19:	00 
  801e1a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e1e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e25:	e8 fb ef ff ff       	call   800e25 <sys_page_alloc>
  801e2a:	89 c3                	mov    %eax,%ebx
  801e2c:	85 c0                	test   %eax,%eax
  801e2e:	0f 88 91 00 00 00    	js     801ec5 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e34:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e37:	89 04 24             	mov    %eax,(%esp)
  801e3a:	e8 b9 f3 ff ff       	call   8011f8 <fd2data>
  801e3f:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801e46:	00 
  801e47:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e4b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801e52:	00 
  801e53:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e57:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e5e:	e8 16 f0 ff ff       	call   800e79 <sys_page_map>
  801e63:	89 c3                	mov    %eax,%ebx
  801e65:	85 c0                	test   %eax,%eax
  801e67:	78 4c                	js     801eb5 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e69:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e6f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e72:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e74:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e77:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e7e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e84:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e87:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e89:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e8c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e93:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e96:	89 04 24             	mov    %eax,(%esp)
  801e99:	e8 4a f3 ff ff       	call   8011e8 <fd2num>
  801e9e:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801ea0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ea3:	89 04 24             	mov    %eax,(%esp)
  801ea6:	e8 3d f3 ff ff       	call   8011e8 <fd2num>
  801eab:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801eae:	bb 00 00 00 00       	mov    $0x0,%ebx
  801eb3:	eb 36                	jmp    801eeb <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801eb5:	89 74 24 04          	mov    %esi,0x4(%esp)
  801eb9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ec0:	e8 07 f0 ff ff       	call   800ecc <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801ec5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ec8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ecc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ed3:	e8 f4 ef ff ff       	call   800ecc <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801ed8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801edb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801edf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ee6:	e8 e1 ef ff ff       	call   800ecc <sys_page_unmap>
    err:
	return r;
}
  801eeb:	89 d8                	mov    %ebx,%eax
  801eed:	83 c4 3c             	add    $0x3c,%esp
  801ef0:	5b                   	pop    %ebx
  801ef1:	5e                   	pop    %esi
  801ef2:	5f                   	pop    %edi
  801ef3:	5d                   	pop    %ebp
  801ef4:	c3                   	ret    

00801ef5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ef5:	55                   	push   %ebp
  801ef6:	89 e5                	mov    %esp,%ebp
  801ef8:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801efb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801efe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f02:	8b 45 08             	mov    0x8(%ebp),%eax
  801f05:	89 04 24             	mov    %eax,(%esp)
  801f08:	e8 59 f3 ff ff       	call   801266 <fd_lookup>
  801f0d:	85 c0                	test   %eax,%eax
  801f0f:	78 15                	js     801f26 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f11:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f14:	89 04 24             	mov    %eax,(%esp)
  801f17:	e8 dc f2 ff ff       	call   8011f8 <fd2data>
	return _pipeisclosed(fd, p);
  801f1c:	89 c2                	mov    %eax,%edx
  801f1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f21:	e8 15 fd ff ff       	call   801c3b <_pipeisclosed>
}
  801f26:	c9                   	leave  
  801f27:	c3                   	ret    

00801f28 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f28:	55                   	push   %ebp
  801f29:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f2b:	b8 00 00 00 00       	mov    $0x0,%eax
  801f30:	5d                   	pop    %ebp
  801f31:	c3                   	ret    

00801f32 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f32:	55                   	push   %ebp
  801f33:	89 e5                	mov    %esp,%ebp
  801f35:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801f38:	c7 44 24 04 4a 29 80 	movl   $0x80294a,0x4(%esp)
  801f3f:	00 
  801f40:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f43:	89 04 24             	mov    %eax,(%esp)
  801f46:	e8 e8 ea ff ff       	call   800a33 <strcpy>
	return 0;
}
  801f4b:	b8 00 00 00 00       	mov    $0x0,%eax
  801f50:	c9                   	leave  
  801f51:	c3                   	ret    

00801f52 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f52:	55                   	push   %ebp
  801f53:	89 e5                	mov    %esp,%ebp
  801f55:	57                   	push   %edi
  801f56:	56                   	push   %esi
  801f57:	53                   	push   %ebx
  801f58:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f5e:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f63:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f69:	eb 30                	jmp    801f9b <devcons_write+0x49>
		m = n - tot;
  801f6b:	8b 75 10             	mov    0x10(%ebp),%esi
  801f6e:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801f70:	83 fe 7f             	cmp    $0x7f,%esi
  801f73:	76 05                	jbe    801f7a <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801f75:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801f7a:	89 74 24 08          	mov    %esi,0x8(%esp)
  801f7e:	03 45 0c             	add    0xc(%ebp),%eax
  801f81:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f85:	89 3c 24             	mov    %edi,(%esp)
  801f88:	e8 1f ec ff ff       	call   800bac <memmove>
		sys_cputs(buf, m);
  801f8d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f91:	89 3c 24             	mov    %edi,(%esp)
  801f94:	e8 bf ed ff ff       	call   800d58 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f99:	01 f3                	add    %esi,%ebx
  801f9b:	89 d8                	mov    %ebx,%eax
  801f9d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801fa0:	72 c9                	jb     801f6b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801fa2:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801fa8:	5b                   	pop    %ebx
  801fa9:	5e                   	pop    %esi
  801faa:	5f                   	pop    %edi
  801fab:	5d                   	pop    %ebp
  801fac:	c3                   	ret    

00801fad <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fad:	55                   	push   %ebp
  801fae:	89 e5                	mov    %esp,%ebp
  801fb0:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801fb3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801fb7:	75 07                	jne    801fc0 <devcons_read+0x13>
  801fb9:	eb 25                	jmp    801fe0 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801fbb:	e8 46 ee ff ff       	call   800e06 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801fc0:	e8 b1 ed ff ff       	call   800d76 <sys_cgetc>
  801fc5:	85 c0                	test   %eax,%eax
  801fc7:	74 f2                	je     801fbb <devcons_read+0xe>
  801fc9:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801fcb:	85 c0                	test   %eax,%eax
  801fcd:	78 1d                	js     801fec <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801fcf:	83 f8 04             	cmp    $0x4,%eax
  801fd2:	74 13                	je     801fe7 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801fd4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fd7:	88 10                	mov    %dl,(%eax)
	return 1;
  801fd9:	b8 01 00 00 00       	mov    $0x1,%eax
  801fde:	eb 0c                	jmp    801fec <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801fe0:	b8 00 00 00 00       	mov    $0x0,%eax
  801fe5:	eb 05                	jmp    801fec <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801fe7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801fec:	c9                   	leave  
  801fed:	c3                   	ret    

00801fee <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801fee:	55                   	push   %ebp
  801fef:	89 e5                	mov    %esp,%ebp
  801ff1:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801ff4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ff7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ffa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802001:	00 
  802002:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802005:	89 04 24             	mov    %eax,(%esp)
  802008:	e8 4b ed ff ff       	call   800d58 <sys_cputs>
}
  80200d:	c9                   	leave  
  80200e:	c3                   	ret    

0080200f <getchar>:

int
getchar(void)
{
  80200f:	55                   	push   %ebp
  802010:	89 e5                	mov    %esp,%ebp
  802012:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802015:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  80201c:	00 
  80201d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802020:	89 44 24 04          	mov    %eax,0x4(%esp)
  802024:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80202b:	e8 d2 f4 ff ff       	call   801502 <read>
	if (r < 0)
  802030:	85 c0                	test   %eax,%eax
  802032:	78 0f                	js     802043 <getchar+0x34>
		return r;
	if (r < 1)
  802034:	85 c0                	test   %eax,%eax
  802036:	7e 06                	jle    80203e <getchar+0x2f>
		return -E_EOF;
	return c;
  802038:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80203c:	eb 05                	jmp    802043 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80203e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802043:	c9                   	leave  
  802044:	c3                   	ret    

00802045 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802045:	55                   	push   %ebp
  802046:	89 e5                	mov    %esp,%ebp
  802048:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80204b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80204e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802052:	8b 45 08             	mov    0x8(%ebp),%eax
  802055:	89 04 24             	mov    %eax,(%esp)
  802058:	e8 09 f2 ff ff       	call   801266 <fd_lookup>
  80205d:	85 c0                	test   %eax,%eax
  80205f:	78 11                	js     802072 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802061:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802064:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80206a:	39 10                	cmp    %edx,(%eax)
  80206c:	0f 94 c0             	sete   %al
  80206f:	0f b6 c0             	movzbl %al,%eax
}
  802072:	c9                   	leave  
  802073:	c3                   	ret    

00802074 <opencons>:

int
opencons(void)
{
  802074:	55                   	push   %ebp
  802075:	89 e5                	mov    %esp,%ebp
  802077:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80207a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80207d:	89 04 24             	mov    %eax,(%esp)
  802080:	e8 8e f1 ff ff       	call   801213 <fd_alloc>
  802085:	85 c0                	test   %eax,%eax
  802087:	78 3c                	js     8020c5 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802089:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802090:	00 
  802091:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802094:	89 44 24 04          	mov    %eax,0x4(%esp)
  802098:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80209f:	e8 81 ed ff ff       	call   800e25 <sys_page_alloc>
  8020a4:	85 c0                	test   %eax,%eax
  8020a6:	78 1d                	js     8020c5 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8020a8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020b1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8020b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020b6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8020bd:	89 04 24             	mov    %eax,(%esp)
  8020c0:	e8 23 f1 ff ff       	call   8011e8 <fd2num>
}
  8020c5:	c9                   	leave  
  8020c6:	c3                   	ret    
	...

008020c8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020c8:	55                   	push   %ebp
  8020c9:	89 e5                	mov    %esp,%ebp
  8020cb:	56                   	push   %esi
  8020cc:	53                   	push   %ebx
  8020cd:	83 ec 10             	sub    $0x10,%esp
  8020d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8020d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020d6:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int r;
		
	r = sys_ipc_recv(pg?pg:(void*)UTOP);
  8020d9:	85 c0                	test   %eax,%eax
  8020db:	75 05                	jne    8020e2 <ipc_recv+0x1a>
  8020dd:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8020e2:	89 04 24             	mov    %eax,(%esp)
  8020e5:	e8 51 ef ff ff       	call   80103b <sys_ipc_recv>
	if (from_env_store != NULL)
  8020ea:	85 db                	test   %ebx,%ebx
  8020ec:	74 0b                	je     8020f9 <ipc_recv+0x31>
		*from_env_store = thisenv->env_ipc_from; 
  8020ee:	8b 15 20 44 80 00    	mov    0x804420,%edx
  8020f4:	8b 52 74             	mov    0x74(%edx),%edx
  8020f7:	89 13                	mov    %edx,(%ebx)
	if (perm_store != NULL)
  8020f9:	85 f6                	test   %esi,%esi
  8020fb:	74 0b                	je     802108 <ipc_recv+0x40>
		*perm_store = thisenv->env_ipc_perm;
  8020fd:	8b 15 20 44 80 00    	mov    0x804420,%edx
  802103:	8b 52 78             	mov    0x78(%edx),%edx
  802106:	89 16                	mov    %edx,(%esi)
	
	if (r < 0){
  802108:	85 c0                	test   %eax,%eax
  80210a:	79 16                	jns    802122 <ipc_recv+0x5a>
		if(from_env_store != NULL)
  80210c:	85 db                	test   %ebx,%ebx
  80210e:	74 06                	je     802116 <ipc_recv+0x4e>
			*from_env_store = 0;
  802110:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store != NULL)	
  802116:	85 f6                	test   %esi,%esi
  802118:	74 10                	je     80212a <ipc_recv+0x62>
			*perm_store = 0;
  80211a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  802120:	eb 08                	jmp    80212a <ipc_recv+0x62>
		return r;
	}
	
	return thisenv->env_ipc_value;
  802122:	a1 20 44 80 00       	mov    0x804420,%eax
  802127:	8b 40 70             	mov    0x70(%eax),%eax
}
  80212a:	83 c4 10             	add    $0x10,%esp
  80212d:	5b                   	pop    %ebx
  80212e:	5e                   	pop    %esi
  80212f:	5d                   	pop    %ebp
  802130:	c3                   	ret    

00802131 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802131:	55                   	push   %ebp
  802132:	89 e5                	mov    %esp,%ebp
  802134:	57                   	push   %edi
  802135:	56                   	push   %esi
  802136:	53                   	push   %ebx
  802137:	83 ec 1c             	sub    $0x1c,%esp
  80213a:	8b 75 08             	mov    0x8(%ebp),%esi
  80213d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802140:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  802143:	eb 2a                	jmp    80216f <ipc_send+0x3e>
		if (r != -E_IPC_NOT_RECV)
  802145:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802148:	74 20                	je     80216a <ipc_send+0x39>
			panic("ipc_send: sys_ipc_try_send failed %e", r);
  80214a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80214e:	c7 44 24 08 58 29 80 	movl   $0x802958,0x8(%esp)
  802155:	00 
  802156:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  80215d:	00 
  80215e:	c7 04 24 80 29 80 00 	movl   $0x802980,(%esp)
  802165:	e8 26 e2 ff ff       	call   800390 <_panic>
		sys_yield();
  80216a:	e8 97 ec ff ff       	call   800e06 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  80216f:	85 db                	test   %ebx,%ebx
  802171:	75 07                	jne    80217a <ipc_send+0x49>
  802173:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802178:	eb 02                	jmp    80217c <ipc_send+0x4b>
  80217a:	89 d8                	mov    %ebx,%eax
  80217c:	8b 55 14             	mov    0x14(%ebp),%edx
  80217f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802183:	89 44 24 08          	mov    %eax,0x8(%esp)
  802187:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80218b:	89 34 24             	mov    %esi,(%esp)
  80218e:	e8 85 ee ff ff       	call   801018 <sys_ipc_try_send>
  802193:	85 c0                	test   %eax,%eax
  802195:	78 ae                	js     802145 <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: sys_ipc_try_send failed %e", r);
		sys_yield();
	}
}
  802197:	83 c4 1c             	add    $0x1c,%esp
  80219a:	5b                   	pop    %ebx
  80219b:	5e                   	pop    %esi
  80219c:	5f                   	pop    %edi
  80219d:	5d                   	pop    %ebp
  80219e:	c3                   	ret    

0080219f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80219f:	55                   	push   %ebp
  8021a0:	89 e5                	mov    %esp,%ebp
  8021a2:	53                   	push   %ebx
  8021a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  8021a6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8021ab:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8021b2:	89 c2                	mov    %eax,%edx
  8021b4:	c1 e2 07             	shl    $0x7,%edx
  8021b7:	29 ca                	sub    %ecx,%edx
  8021b9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8021bf:	8b 52 50             	mov    0x50(%edx),%edx
  8021c2:	39 da                	cmp    %ebx,%edx
  8021c4:	75 0f                	jne    8021d5 <ipc_find_env+0x36>
			return envs[i].env_id;
  8021c6:	c1 e0 07             	shl    $0x7,%eax
  8021c9:	29 c8                	sub    %ecx,%eax
  8021cb:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8021d0:	8b 40 40             	mov    0x40(%eax),%eax
  8021d3:	eb 0c                	jmp    8021e1 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8021d5:	40                   	inc    %eax
  8021d6:	3d 00 04 00 00       	cmp    $0x400,%eax
  8021db:	75 ce                	jne    8021ab <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8021dd:	66 b8 00 00          	mov    $0x0,%ax
}
  8021e1:	5b                   	pop    %ebx
  8021e2:	5d                   	pop    %ebp
  8021e3:	c3                   	ret    

008021e4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021e4:	55                   	push   %ebp
  8021e5:	89 e5                	mov    %esp,%ebp
  8021e7:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021ea:	89 c2                	mov    %eax,%edx
  8021ec:	c1 ea 16             	shr    $0x16,%edx
  8021ef:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8021f6:	f6 c2 01             	test   $0x1,%dl
  8021f9:	74 1e                	je     802219 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021fb:	c1 e8 0c             	shr    $0xc,%eax
  8021fe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802205:	a8 01                	test   $0x1,%al
  802207:	74 17                	je     802220 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802209:	c1 e8 0c             	shr    $0xc,%eax
  80220c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802213:	ef 
  802214:	0f b7 c0             	movzwl %ax,%eax
  802217:	eb 0c                	jmp    802225 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802219:	b8 00 00 00 00       	mov    $0x0,%eax
  80221e:	eb 05                	jmp    802225 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802220:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802225:	5d                   	pop    %ebp
  802226:	c3                   	ret    
	...

00802228 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802228:	55                   	push   %ebp
  802229:	57                   	push   %edi
  80222a:	56                   	push   %esi
  80222b:	83 ec 10             	sub    $0x10,%esp
  80222e:	8b 74 24 20          	mov    0x20(%esp),%esi
  802232:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802236:	89 74 24 04          	mov    %esi,0x4(%esp)
  80223a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  80223e:	89 cd                	mov    %ecx,%ebp
  802240:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802244:	85 c0                	test   %eax,%eax
  802246:	75 2c                	jne    802274 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802248:	39 f9                	cmp    %edi,%ecx
  80224a:	77 68                	ja     8022b4 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80224c:	85 c9                	test   %ecx,%ecx
  80224e:	75 0b                	jne    80225b <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802250:	b8 01 00 00 00       	mov    $0x1,%eax
  802255:	31 d2                	xor    %edx,%edx
  802257:	f7 f1                	div    %ecx
  802259:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80225b:	31 d2                	xor    %edx,%edx
  80225d:	89 f8                	mov    %edi,%eax
  80225f:	f7 f1                	div    %ecx
  802261:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802263:	89 f0                	mov    %esi,%eax
  802265:	f7 f1                	div    %ecx
  802267:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802269:	89 f0                	mov    %esi,%eax
  80226b:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80226d:	83 c4 10             	add    $0x10,%esp
  802270:	5e                   	pop    %esi
  802271:	5f                   	pop    %edi
  802272:	5d                   	pop    %ebp
  802273:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802274:	39 f8                	cmp    %edi,%eax
  802276:	77 2c                	ja     8022a4 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802278:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  80227b:	83 f6 1f             	xor    $0x1f,%esi
  80227e:	75 4c                	jne    8022cc <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802280:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802282:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802287:	72 0a                	jb     802293 <__udivdi3+0x6b>
  802289:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  80228d:	0f 87 ad 00 00 00    	ja     802340 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802293:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802298:	89 f0                	mov    %esi,%eax
  80229a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80229c:	83 c4 10             	add    $0x10,%esp
  80229f:	5e                   	pop    %esi
  8022a0:	5f                   	pop    %edi
  8022a1:	5d                   	pop    %ebp
  8022a2:	c3                   	ret    
  8022a3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8022a4:	31 ff                	xor    %edi,%edi
  8022a6:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8022a8:	89 f0                	mov    %esi,%eax
  8022aa:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8022ac:	83 c4 10             	add    $0x10,%esp
  8022af:	5e                   	pop    %esi
  8022b0:	5f                   	pop    %edi
  8022b1:	5d                   	pop    %ebp
  8022b2:	c3                   	ret    
  8022b3:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8022b4:	89 fa                	mov    %edi,%edx
  8022b6:	89 f0                	mov    %esi,%eax
  8022b8:	f7 f1                	div    %ecx
  8022ba:	89 c6                	mov    %eax,%esi
  8022bc:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8022be:	89 f0                	mov    %esi,%eax
  8022c0:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8022c2:	83 c4 10             	add    $0x10,%esp
  8022c5:	5e                   	pop    %esi
  8022c6:	5f                   	pop    %edi
  8022c7:	5d                   	pop    %ebp
  8022c8:	c3                   	ret    
  8022c9:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8022cc:	89 f1                	mov    %esi,%ecx
  8022ce:	d3 e0                	shl    %cl,%eax
  8022d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8022d4:	b8 20 00 00 00       	mov    $0x20,%eax
  8022d9:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8022db:	89 ea                	mov    %ebp,%edx
  8022dd:	88 c1                	mov    %al,%cl
  8022df:	d3 ea                	shr    %cl,%edx
  8022e1:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8022e5:	09 ca                	or     %ecx,%edx
  8022e7:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  8022eb:	89 f1                	mov    %esi,%ecx
  8022ed:	d3 e5                	shl    %cl,%ebp
  8022ef:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  8022f3:	89 fd                	mov    %edi,%ebp
  8022f5:	88 c1                	mov    %al,%cl
  8022f7:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  8022f9:	89 fa                	mov    %edi,%edx
  8022fb:	89 f1                	mov    %esi,%ecx
  8022fd:	d3 e2                	shl    %cl,%edx
  8022ff:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802303:	88 c1                	mov    %al,%cl
  802305:	d3 ef                	shr    %cl,%edi
  802307:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802309:	89 f8                	mov    %edi,%eax
  80230b:	89 ea                	mov    %ebp,%edx
  80230d:	f7 74 24 08          	divl   0x8(%esp)
  802311:	89 d1                	mov    %edx,%ecx
  802313:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802315:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802319:	39 d1                	cmp    %edx,%ecx
  80231b:	72 17                	jb     802334 <__udivdi3+0x10c>
  80231d:	74 09                	je     802328 <__udivdi3+0x100>
  80231f:	89 fe                	mov    %edi,%esi
  802321:	31 ff                	xor    %edi,%edi
  802323:	e9 41 ff ff ff       	jmp    802269 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802328:	8b 54 24 04          	mov    0x4(%esp),%edx
  80232c:	89 f1                	mov    %esi,%ecx
  80232e:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802330:	39 c2                	cmp    %eax,%edx
  802332:	73 eb                	jae    80231f <__udivdi3+0xf7>
		{
		  q0--;
  802334:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802337:	31 ff                	xor    %edi,%edi
  802339:	e9 2b ff ff ff       	jmp    802269 <__udivdi3+0x41>
  80233e:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802340:	31 f6                	xor    %esi,%esi
  802342:	e9 22 ff ff ff       	jmp    802269 <__udivdi3+0x41>
	...

00802348 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802348:	55                   	push   %ebp
  802349:	57                   	push   %edi
  80234a:	56                   	push   %esi
  80234b:	83 ec 20             	sub    $0x20,%esp
  80234e:	8b 44 24 30          	mov    0x30(%esp),%eax
  802352:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802356:	89 44 24 14          	mov    %eax,0x14(%esp)
  80235a:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  80235e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802362:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802366:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802368:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80236a:	85 ed                	test   %ebp,%ebp
  80236c:	75 16                	jne    802384 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  80236e:	39 f1                	cmp    %esi,%ecx
  802370:	0f 86 a6 00 00 00    	jbe    80241c <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802376:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802378:	89 d0                	mov    %edx,%eax
  80237a:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80237c:	83 c4 20             	add    $0x20,%esp
  80237f:	5e                   	pop    %esi
  802380:	5f                   	pop    %edi
  802381:	5d                   	pop    %ebp
  802382:	c3                   	ret    
  802383:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802384:	39 f5                	cmp    %esi,%ebp
  802386:	0f 87 ac 00 00 00    	ja     802438 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80238c:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  80238f:	83 f0 1f             	xor    $0x1f,%eax
  802392:	89 44 24 10          	mov    %eax,0x10(%esp)
  802396:	0f 84 a8 00 00 00    	je     802444 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80239c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8023a0:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8023a2:	bf 20 00 00 00       	mov    $0x20,%edi
  8023a7:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8023ab:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8023af:	89 f9                	mov    %edi,%ecx
  8023b1:	d3 e8                	shr    %cl,%eax
  8023b3:	09 e8                	or     %ebp,%eax
  8023b5:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  8023b9:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8023bd:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8023c1:	d3 e0                	shl    %cl,%eax
  8023c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8023c7:	89 f2                	mov    %esi,%edx
  8023c9:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8023cb:	8b 44 24 14          	mov    0x14(%esp),%eax
  8023cf:	d3 e0                	shl    %cl,%eax
  8023d1:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8023d5:	8b 44 24 14          	mov    0x14(%esp),%eax
  8023d9:	89 f9                	mov    %edi,%ecx
  8023db:	d3 e8                	shr    %cl,%eax
  8023dd:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8023df:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8023e1:	89 f2                	mov    %esi,%edx
  8023e3:	f7 74 24 18          	divl   0x18(%esp)
  8023e7:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8023e9:	f7 64 24 0c          	mull   0xc(%esp)
  8023ed:	89 c5                	mov    %eax,%ebp
  8023ef:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8023f1:	39 d6                	cmp    %edx,%esi
  8023f3:	72 67                	jb     80245c <__umoddi3+0x114>
  8023f5:	74 75                	je     80246c <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8023f7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8023fb:	29 e8                	sub    %ebp,%eax
  8023fd:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8023ff:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802403:	d3 e8                	shr    %cl,%eax
  802405:	89 f2                	mov    %esi,%edx
  802407:	89 f9                	mov    %edi,%ecx
  802409:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80240b:	09 d0                	or     %edx,%eax
  80240d:	89 f2                	mov    %esi,%edx
  80240f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802413:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802415:	83 c4 20             	add    $0x20,%esp
  802418:	5e                   	pop    %esi
  802419:	5f                   	pop    %edi
  80241a:	5d                   	pop    %ebp
  80241b:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80241c:	85 c9                	test   %ecx,%ecx
  80241e:	75 0b                	jne    80242b <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802420:	b8 01 00 00 00       	mov    $0x1,%eax
  802425:	31 d2                	xor    %edx,%edx
  802427:	f7 f1                	div    %ecx
  802429:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80242b:	89 f0                	mov    %esi,%eax
  80242d:	31 d2                	xor    %edx,%edx
  80242f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802431:	89 f8                	mov    %edi,%eax
  802433:	e9 3e ff ff ff       	jmp    802376 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802438:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80243a:	83 c4 20             	add    $0x20,%esp
  80243d:	5e                   	pop    %esi
  80243e:	5f                   	pop    %edi
  80243f:	5d                   	pop    %ebp
  802440:	c3                   	ret    
  802441:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802444:	39 f5                	cmp    %esi,%ebp
  802446:	72 04                	jb     80244c <__umoddi3+0x104>
  802448:	39 f9                	cmp    %edi,%ecx
  80244a:	77 06                	ja     802452 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80244c:	89 f2                	mov    %esi,%edx
  80244e:	29 cf                	sub    %ecx,%edi
  802450:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802452:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802454:	83 c4 20             	add    $0x20,%esp
  802457:	5e                   	pop    %esi
  802458:	5f                   	pop    %edi
  802459:	5d                   	pop    %ebp
  80245a:	c3                   	ret    
  80245b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80245c:	89 d1                	mov    %edx,%ecx
  80245e:	89 c5                	mov    %eax,%ebp
  802460:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802464:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802468:	eb 8d                	jmp    8023f7 <__umoddi3+0xaf>
  80246a:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80246c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802470:	72 ea                	jb     80245c <__umoddi3+0x114>
  802472:	89 f1                	mov    %esi,%ecx
  802474:	eb 81                	jmp    8023f7 <__umoddi3+0xaf>
