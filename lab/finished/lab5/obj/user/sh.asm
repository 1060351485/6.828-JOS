
obj/user/sh.debug:     file format elf32-i386


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
  80002c:	e8 9f 09 00 00       	call   8009d0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <_gettoken>:
#define WHITESPACE " \t\r\n"
#define SYMBOLS "<|>&;()"

int
_gettoken(char *s, char **p1, char **p2)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 1c             	sub    $0x1c,%esp
  80003d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800040:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int t;

	if (s == 0) {
  800043:	85 db                	test   %ebx,%ebx
  800045:	75 1e                	jne    800065 <_gettoken+0x31>
		if (debug > 1)
  800047:	83 3d 00 40 80 00 01 	cmpl   $0x1,0x804000
  80004e:	0f 8e 19 01 00 00    	jle    80016d <_gettoken+0x139>
			cprintf("GETTOKEN NULL\n");
  800054:	c7 04 24 00 36 80 00 	movl   $0x803600,(%esp)
  80005b:	e8 d0 0a 00 00       	call   800b30 <cprintf>
  800060:	e9 1b 01 00 00       	jmp    800180 <_gettoken+0x14c>
		return 0;
	}

	if (debug > 1)
  800065:	83 3d 00 40 80 00 01 	cmpl   $0x1,0x804000
  80006c:	7e 10                	jle    80007e <_gettoken+0x4a>
		cprintf("GETTOKEN: %s\n", s);
  80006e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800072:	c7 04 24 0f 36 80 00 	movl   $0x80360f,(%esp)
  800079:	e8 b2 0a 00 00       	call   800b30 <cprintf>

	*p1 = 0;
  80007e:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
	*p2 = 0;
  800084:	8b 45 10             	mov    0x10(%ebp),%eax
  800087:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	while (strchr(WHITESPACE, *s))
  80008d:	eb 04                	jmp    800093 <_gettoken+0x5f>
		*s++ = 0;
  80008f:	c6 03 00             	movb   $0x0,(%ebx)
  800092:	43                   	inc    %ebx
		cprintf("GETTOKEN: %s\n", s);

	*p1 = 0;
	*p2 = 0;

	while (strchr(WHITESPACE, *s))
  800093:	0f be 03             	movsbl (%ebx),%eax
  800096:	89 44 24 04          	mov    %eax,0x4(%esp)
  80009a:	c7 04 24 1d 36 80 00 	movl   $0x80361d,(%esp)
  8000a1:	e8 0f 12 00 00       	call   8012b5 <strchr>
  8000a6:	85 c0                	test   %eax,%eax
  8000a8:	75 e5                	jne    80008f <_gettoken+0x5b>
  8000aa:	89 de                	mov    %ebx,%esi
		*s++ = 0;
	if (*s == 0) {
  8000ac:	8a 03                	mov    (%ebx),%al
  8000ae:	84 c0                	test   %al,%al
  8000b0:	75 23                	jne    8000d5 <_gettoken+0xa1>
		if (debug > 1)
  8000b2:	83 3d 00 40 80 00 01 	cmpl   $0x1,0x804000
  8000b9:	0f 8e b5 00 00 00    	jle    800174 <_gettoken+0x140>
			cprintf("EOL\n");
  8000bf:	c7 04 24 22 36 80 00 	movl   $0x803622,(%esp)
  8000c6:	e8 65 0a 00 00       	call   800b30 <cprintf>
		return 0;
  8000cb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8000d0:	e9 ab 00 00 00       	jmp    800180 <_gettoken+0x14c>
	}
	if (strchr(SYMBOLS, *s)) {
  8000d5:	0f be c0             	movsbl %al,%eax
  8000d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000dc:	c7 04 24 33 36 80 00 	movl   $0x803633,(%esp)
  8000e3:	e8 cd 11 00 00       	call   8012b5 <strchr>
  8000e8:	85 c0                	test   %eax,%eax
  8000ea:	74 29                	je     800115 <_gettoken+0xe1>
		t = *s;
  8000ec:	0f be 1b             	movsbl (%ebx),%ebx
		*p1 = s;
  8000ef:	89 37                	mov    %esi,(%edi)
		*s++ = 0;
  8000f1:	c6 06 00             	movb   $0x0,(%esi)
  8000f4:	46                   	inc    %esi
  8000f5:	8b 55 10             	mov    0x10(%ebp),%edx
  8000f8:	89 32                	mov    %esi,(%edx)
		*p2 = s;
		if (debug > 1)
  8000fa:	83 3d 00 40 80 00 01 	cmpl   $0x1,0x804000
  800101:	7e 7d                	jle    800180 <_gettoken+0x14c>
			cprintf("TOK %c\n", t);
  800103:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800107:	c7 04 24 27 36 80 00 	movl   $0x803627,(%esp)
  80010e:	e8 1d 0a 00 00       	call   800b30 <cprintf>
  800113:	eb 6b                	jmp    800180 <_gettoken+0x14c>
		return t;
	}
	*p1 = s;
  800115:	89 1f                	mov    %ebx,(%edi)
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  800117:	eb 01                	jmp    80011a <_gettoken+0xe6>
		s++;
  800119:	43                   	inc    %ebx
		if (debug > 1)
			cprintf("TOK %c\n", t);
		return t;
	}
	*p1 = s;
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  80011a:	8a 03                	mov    (%ebx),%al
  80011c:	84 c0                	test   %al,%al
  80011e:	74 17                	je     800137 <_gettoken+0x103>
  800120:	0f be c0             	movsbl %al,%eax
  800123:	89 44 24 04          	mov    %eax,0x4(%esp)
  800127:	c7 04 24 2f 36 80 00 	movl   $0x80362f,(%esp)
  80012e:	e8 82 11 00 00       	call   8012b5 <strchr>
  800133:	85 c0                	test   %eax,%eax
  800135:	74 e2                	je     800119 <_gettoken+0xe5>
		s++;
	*p2 = s;
  800137:	8b 45 10             	mov    0x10(%ebp),%eax
  80013a:	89 18                	mov    %ebx,(%eax)
	if (debug > 1) {
  80013c:	83 3d 00 40 80 00 01 	cmpl   $0x1,0x804000
  800143:	7e 36                	jle    80017b <_gettoken+0x147>
		t = **p2;
  800145:	0f b6 33             	movzbl (%ebx),%esi
		**p2 = 0;
  800148:	c6 03 00             	movb   $0x0,(%ebx)
		cprintf("WORD: %s\n", *p1);
  80014b:	8b 07                	mov    (%edi),%eax
  80014d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800151:	c7 04 24 3b 36 80 00 	movl   $0x80363b,(%esp)
  800158:	e8 d3 09 00 00       	call   800b30 <cprintf>
		**p2 = t;
  80015d:	8b 55 10             	mov    0x10(%ebp),%edx
  800160:	8b 02                	mov    (%edx),%eax
  800162:	89 f2                	mov    %esi,%edx
  800164:	88 10                	mov    %dl,(%eax)
	}
	return 'w';
  800166:	bb 77 00 00 00       	mov    $0x77,%ebx
  80016b:	eb 13                	jmp    800180 <_gettoken+0x14c>
	int t;

	if (s == 0) {
		if (debug > 1)
			cprintf("GETTOKEN NULL\n");
		return 0;
  80016d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800172:	eb 0c                	jmp    800180 <_gettoken+0x14c>
	while (strchr(WHITESPACE, *s))
		*s++ = 0;
	if (*s == 0) {
		if (debug > 1)
			cprintf("EOL\n");
		return 0;
  800174:	bb 00 00 00 00       	mov    $0x0,%ebx
  800179:	eb 05                	jmp    800180 <_gettoken+0x14c>
		t = **p2;
		**p2 = 0;
		cprintf("WORD: %s\n", *p1);
		**p2 = t;
	}
	return 'w';
  80017b:	bb 77 00 00 00       	mov    $0x77,%ebx
}
  800180:	89 d8                	mov    %ebx,%eax
  800182:	83 c4 1c             	add    $0x1c,%esp
  800185:	5b                   	pop    %ebx
  800186:	5e                   	pop    %esi
  800187:	5f                   	pop    %edi
  800188:	5d                   	pop    %ebp
  800189:	c3                   	ret    

0080018a <gettoken>:

int
gettoken(char *s, char **p1)
{
  80018a:	55                   	push   %ebp
  80018b:	89 e5                	mov    %esp,%ebp
  80018d:	83 ec 18             	sub    $0x18,%esp
  800190:	8b 45 08             	mov    0x8(%ebp),%eax
	static int c, nc;
	static char* np1, *np2;

	if (s) {
  800193:	85 c0                	test   %eax,%eax
  800195:	74 24                	je     8001bb <gettoken+0x31>
		nc = _gettoken(s, &np1, &np2);
  800197:	c7 44 24 08 04 50 80 	movl   $0x805004,0x8(%esp)
  80019e:	00 
  80019f:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8001a6:	00 
  8001a7:	89 04 24             	mov    %eax,(%esp)
  8001aa:	e8 85 fe ff ff       	call   800034 <_gettoken>
  8001af:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  8001b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8001b9:	eb 3c                	jmp    8001f7 <gettoken+0x6d>
	}
	c = nc;
  8001bb:	a1 08 50 80 00       	mov    0x805008,%eax
  8001c0:	a3 0c 50 80 00       	mov    %eax,0x80500c
	*p1 = np1;
  8001c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001c8:	8b 15 00 50 80 00    	mov    0x805000,%edx
  8001ce:	89 10                	mov    %edx,(%eax)
	nc = _gettoken(np2, &np1, &np2);
  8001d0:	c7 44 24 08 04 50 80 	movl   $0x805004,0x8(%esp)
  8001d7:	00 
  8001d8:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8001df:	00 
  8001e0:	a1 04 50 80 00       	mov    0x805004,%eax
  8001e5:	89 04 24             	mov    %eax,(%esp)
  8001e8:	e8 47 fe ff ff       	call   800034 <_gettoken>
  8001ed:	a3 08 50 80 00       	mov    %eax,0x805008
	return c;
  8001f2:	a1 0c 50 80 00       	mov    0x80500c,%eax
}
  8001f7:	c9                   	leave  
  8001f8:	c3                   	ret    

008001f9 <runcmd>:
// runcmd() is called in a forked child,
// so it's OK to manipulate file descriptor state.
#define MAXARGS 16
void
runcmd(char* s)
{
  8001f9:	55                   	push   %ebp
  8001fa:	89 e5                	mov    %esp,%ebp
  8001fc:	57                   	push   %edi
  8001fd:	56                   	push   %esi
  8001fe:	53                   	push   %ebx
  8001ff:	81 ec 6c 04 00 00    	sub    $0x46c,%esp
	char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	int argc, c, i, r, p[2], fd, pipe_child;

	pipe_child = 0;
	gettoken(s, 0);
  800205:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80020c:	00 
  80020d:	8b 45 08             	mov    0x8(%ebp),%eax
  800210:	89 04 24             	mov    %eax,(%esp)
  800213:	e8 72 ff ff ff       	call   80018a <gettoken>

again:
	argc = 0;
  800218:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		switch ((c = gettoken(0, &t))) {
  80021d:	8d 5d a4             	lea    -0x5c(%ebp),%ebx
  800220:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800224:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80022b:	e8 5a ff ff ff       	call   80018a <gettoken>
  800230:	83 f8 77             	cmp    $0x77,%eax
  800233:	74 2e                	je     800263 <runcmd+0x6a>
  800235:	83 f8 77             	cmp    $0x77,%eax
  800238:	7f 1b                	jg     800255 <runcmd+0x5c>
  80023a:	83 f8 3c             	cmp    $0x3c,%eax
  80023d:	74 44                	je     800283 <runcmd+0x8a>
  80023f:	83 f8 3e             	cmp    $0x3e,%eax
  800242:	0f 84 bd 00 00 00    	je     800305 <runcmd+0x10c>
  800248:	85 c0                	test   %eax,%eax
  80024a:	0f 84 43 02 00 00    	je     800493 <runcmd+0x29a>
  800250:	e9 1e 02 00 00       	jmp    800473 <runcmd+0x27a>
  800255:	83 f8 7c             	cmp    $0x7c,%eax
  800258:	0f 85 15 02 00 00    	jne    800473 <runcmd+0x27a>
  80025e:	e9 23 01 00 00       	jmp    800386 <runcmd+0x18d>

		case 'w':	// Add an argument
			if (argc == MAXARGS) {
  800263:	83 fe 10             	cmp    $0x10,%esi
  800266:	75 11                	jne    800279 <runcmd+0x80>
				cprintf("too many arguments\n");
  800268:	c7 04 24 45 36 80 00 	movl   $0x803645,(%esp)
  80026f:	e8 bc 08 00 00       	call   800b30 <cprintf>
				exit();
  800274:	e8 ab 07 00 00       	call   800a24 <exit>
			}
			argv[argc++] = t;
  800279:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  80027c:	89 44 b5 a8          	mov    %eax,-0x58(%ebp,%esi,4)
  800280:	46                   	inc    %esi
			break;
  800281:	eb 9d                	jmp    800220 <runcmd+0x27>

		case '<':	// Input redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  800283:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800287:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80028e:	e8 f7 fe ff ff       	call   80018a <gettoken>
  800293:	83 f8 77             	cmp    $0x77,%eax
  800296:	74 11                	je     8002a9 <runcmd+0xb0>
				cprintf("syntax error: < not followed by word\n");
  800298:	c7 04 24 98 37 80 00 	movl   $0x803798,(%esp)
  80029f:	e8 8c 08 00 00       	call   800b30 <cprintf>
				exit();
  8002a4:	e8 7b 07 00 00       	call   800a24 <exit>
			// If not, dup 'fd' onto file descriptor 0,
			// then close the original 'fd'.

			// LAB 5: Your code here.
			//panic("< redirection not implemented");
			if ((fd = open(t, O_RDONLY)) < 0) {
  8002a9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8002b0:	00 
  8002b1:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  8002b4:	89 04 24             	mov    %eax,(%esp)
  8002b7:	e8 ac 22 00 00       	call   802568 <open>
  8002bc:	89 c7                	mov    %eax,%edi
  8002be:	85 c0                	test   %eax,%eax
  8002c0:	79 1e                	jns    8002e0 <runcmd+0xe7>
				cprintf("open %s for read: %e", t, fd);
  8002c2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c6:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  8002c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002cd:	c7 04 24 59 36 80 00 	movl   $0x803659,(%esp)
  8002d4:	e8 57 08 00 00       	call   800b30 <cprintf>
				exit();
  8002d9:	e8 46 07 00 00       	call   800a24 <exit>
  8002de:	eb 08                	jmp    8002e8 <runcmd+0xef>
			}
			if (fd != 0) {
  8002e0:	85 c0                	test   %eax,%eax
  8002e2:	0f 84 38 ff ff ff    	je     800220 <runcmd+0x27>
				dup(fd, 0);
  8002e8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8002ef:	00 
  8002f0:	89 3c 24             	mov    %edi,(%esp)
  8002f3:	e8 87 1c 00 00       	call   801f7f <dup>
				close(fd);
  8002f8:	89 3c 24             	mov    %edi,(%esp)
  8002fb:	e8 2e 1c 00 00       	call   801f2e <close>
  800300:	e9 1b ff ff ff       	jmp    800220 <runcmd+0x27>
			}else {}
			break;

		case '>':	// Output redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  800305:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800309:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800310:	e8 75 fe ff ff       	call   80018a <gettoken>
  800315:	83 f8 77             	cmp    $0x77,%eax
  800318:	74 11                	je     80032b <runcmd+0x132>
				cprintf("syntax error: > not followed by word\n");
  80031a:	c7 04 24 c0 37 80 00 	movl   $0x8037c0,(%esp)
  800321:	e8 0a 08 00 00       	call   800b30 <cprintf>
				exit();
  800326:	e8 f9 06 00 00       	call   800a24 <exit>
			}
			if ((fd = open(t, O_WRONLY|O_CREAT|O_TRUNC)) < 0) {
  80032b:	c7 44 24 04 01 03 00 	movl   $0x301,0x4(%esp)
  800332:	00 
  800333:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  800336:	89 04 24             	mov    %eax,(%esp)
  800339:	e8 2a 22 00 00       	call   802568 <open>
  80033e:	89 c7                	mov    %eax,%edi
  800340:	85 c0                	test   %eax,%eax
  800342:	79 1c                	jns    800360 <runcmd+0x167>
				cprintf("open %s for write: %e", t, fd);
  800344:	89 44 24 08          	mov    %eax,0x8(%esp)
  800348:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  80034b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80034f:	c7 04 24 6e 36 80 00 	movl   $0x80366e,(%esp)
  800356:	e8 d5 07 00 00       	call   800b30 <cprintf>
				exit();
  80035b:	e8 c4 06 00 00       	call   800a24 <exit>
			}
			if (fd != 1) {
  800360:	83 ff 01             	cmp    $0x1,%edi
  800363:	0f 84 b7 fe ff ff    	je     800220 <runcmd+0x27>
				dup(fd, 1);
  800369:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800370:	00 
  800371:	89 3c 24             	mov    %edi,(%esp)
  800374:	e8 06 1c 00 00       	call   801f7f <dup>
				close(fd);
  800379:	89 3c 24             	mov    %edi,(%esp)
  80037c:	e8 ad 1b 00 00       	call   801f2e <close>
  800381:	e9 9a fe ff ff       	jmp    800220 <runcmd+0x27>
			}
			break;

		case '|':	// Pipe
			if ((r = pipe(p)) < 0) {
  800386:	8d 85 9c fb ff ff    	lea    -0x464(%ebp),%eax
  80038c:	89 04 24             	mov    %eax,(%esp)
  80038f:	e8 f9 2b 00 00       	call   802f8d <pipe>
  800394:	85 c0                	test   %eax,%eax
  800396:	79 15                	jns    8003ad <runcmd+0x1b4>
				cprintf("pipe: %e", r);
  800398:	89 44 24 04          	mov    %eax,0x4(%esp)
  80039c:	c7 04 24 84 36 80 00 	movl   $0x803684,(%esp)
  8003a3:	e8 88 07 00 00       	call   800b30 <cprintf>
				exit();
  8003a8:	e8 77 06 00 00       	call   800a24 <exit>
			}
			if (debug)
  8003ad:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8003b4:	74 20                	je     8003d6 <runcmd+0x1dd>
				cprintf("PIPE: %d %d\n", p[0], p[1]);
  8003b6:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  8003bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003c0:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  8003c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ca:	c7 04 24 8d 36 80 00 	movl   $0x80368d,(%esp)
  8003d1:	e8 5a 07 00 00       	call   800b30 <cprintf>
			if ((r = fork()) < 0) {
  8003d6:	e8 4c 15 00 00       	call   801927 <fork>
  8003db:	89 c7                	mov    %eax,%edi
  8003dd:	85 c0                	test   %eax,%eax
  8003df:	79 15                	jns    8003f6 <runcmd+0x1fd>
				cprintf("fork: %e", r);
  8003e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003e5:	c7 04 24 9a 36 80 00 	movl   $0x80369a,(%esp)
  8003ec:	e8 3f 07 00 00       	call   800b30 <cprintf>
				exit();
  8003f1:	e8 2e 06 00 00       	call   800a24 <exit>
			}
			if (r == 0) {
  8003f6:	85 ff                	test   %edi,%edi
  8003f8:	75 40                	jne    80043a <runcmd+0x241>
				if (p[0] != 0) {
  8003fa:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  800400:	85 c0                	test   %eax,%eax
  800402:	74 1e                	je     800422 <runcmd+0x229>
					dup(p[0], 0);
  800404:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80040b:	00 
  80040c:	89 04 24             	mov    %eax,(%esp)
  80040f:	e8 6b 1b 00 00       	call   801f7f <dup>
					close(p[0]);
  800414:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  80041a:	89 04 24             	mov    %eax,(%esp)
  80041d:	e8 0c 1b 00 00       	call   801f2e <close>
				}
				close(p[1]);
  800422:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  800428:	89 04 24             	mov    %eax,(%esp)
  80042b:	e8 fe 1a 00 00       	call   801f2e <close>

	pipe_child = 0;
	gettoken(s, 0);

again:
	argc = 0;
  800430:	be 00 00 00 00       	mov    $0x0,%esi
				if (p[0] != 0) {
					dup(p[0], 0);
					close(p[0]);
				}
				close(p[1]);
				goto again;
  800435:	e9 e6 fd ff ff       	jmp    800220 <runcmd+0x27>
			} else {
				pipe_child = r;
				if (p[1] != 1) {
  80043a:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  800440:	83 f8 01             	cmp    $0x1,%eax
  800443:	74 1e                	je     800463 <runcmd+0x26a>
					dup(p[1], 1);
  800445:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80044c:	00 
  80044d:	89 04 24             	mov    %eax,(%esp)
  800450:	e8 2a 1b 00 00       	call   801f7f <dup>
					close(p[1]);
  800455:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  80045b:	89 04 24             	mov    %eax,(%esp)
  80045e:	e8 cb 1a 00 00       	call   801f2e <close>
				}
				close(p[0]);
  800463:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  800469:	89 04 24             	mov    %eax,(%esp)
  80046c:	e8 bd 1a 00 00       	call   801f2e <close>
				goto runit;
  800471:	eb 25                	jmp    800498 <runcmd+0x29f>
		case 0:		// String is complete
			// Run the current command!
			goto runit;

		default:
			panic("bad return %d from gettoken", c);
  800473:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800477:	c7 44 24 08 a3 36 80 	movl   $0x8036a3,0x8(%esp)
  80047e:	00 
  80047f:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
  800486:	00 
  800487:	c7 04 24 bf 36 80 00 	movl   $0x8036bf,(%esp)
  80048e:	e8 a5 05 00 00       	call   800a38 <_panic>
runcmd(char* s)
{
	char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	int argc, c, i, r, p[2], fd, pipe_child;

	pipe_child = 0;
  800493:	bf 00 00 00 00       	mov    $0x0,%edi
		}
	}

runit:
	// Return immediately if command line was empty.
	if(argc == 0) {
  800498:	85 f6                	test   %esi,%esi
  80049a:	75 1e                	jne    8004ba <runcmd+0x2c1>
		if (debug)
  80049c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8004a3:	0f 84 76 01 00 00    	je     80061f <runcmd+0x426>
			cprintf("EMPTY COMMAND\n");
  8004a9:	c7 04 24 c9 36 80 00 	movl   $0x8036c9,(%esp)
  8004b0:	e8 7b 06 00 00       	call   800b30 <cprintf>
  8004b5:	e9 65 01 00 00       	jmp    80061f <runcmd+0x426>

	// Clean up command line.
	// Read all commands from the filesystem: add an initial '/' to
	// the command name.
	// This essentially acts like 'PATH=/'.
	if (argv[0][0] != '/') {
  8004ba:	8b 45 a8             	mov    -0x58(%ebp),%eax
  8004bd:	80 38 2f             	cmpb   $0x2f,(%eax)
  8004c0:	74 22                	je     8004e4 <runcmd+0x2eb>
		argv0buf[0] = '/';
  8004c2:	c6 85 a4 fb ff ff 2f 	movb   $0x2f,-0x45c(%ebp)
		strcpy(argv0buf + 1, argv[0]);
  8004c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004cd:	8d 9d a4 fb ff ff    	lea    -0x45c(%ebp),%ebx
  8004d3:	8d 85 a5 fb ff ff    	lea    -0x45b(%ebp),%eax
  8004d9:	89 04 24             	mov    %eax,(%esp)
  8004dc:	e8 da 0c 00 00       	call   8011bb <strcpy>
		argv[0] = argv0buf;
  8004e1:	89 5d a8             	mov    %ebx,-0x58(%ebp)
	}
	argv[argc] = 0;
  8004e4:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
  8004eb:	00 

	// Print the command.
	if (debug) {
  8004ec:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8004f3:	74 43                	je     800538 <runcmd+0x33f>
		cprintf("[%08x] SPAWN:", thisenv->env_id);
  8004f5:	a1 24 54 80 00       	mov    0x805424,%eax
  8004fa:	8b 40 48             	mov    0x48(%eax),%eax
  8004fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800501:	c7 04 24 d8 36 80 00 	movl   $0x8036d8,(%esp)
  800508:	e8 23 06 00 00       	call   800b30 <cprintf>
  80050d:	8d 5d a8             	lea    -0x58(%ebp),%ebx
		for (i = 0; argv[i]; i++)
  800510:	eb 10                	jmp    800522 <runcmd+0x329>
			cprintf(" %s", argv[i]);
  800512:	89 44 24 04          	mov    %eax,0x4(%esp)
  800516:	c7 04 24 63 37 80 00 	movl   $0x803763,(%esp)
  80051d:	e8 0e 06 00 00       	call   800b30 <cprintf>
  800522:	83 c3 04             	add    $0x4,%ebx
	argv[argc] = 0;

	// Print the command.
	if (debug) {
		cprintf("[%08x] SPAWN:", thisenv->env_id);
		for (i = 0; argv[i]; i++)
  800525:	8b 43 fc             	mov    -0x4(%ebx),%eax
  800528:	85 c0                	test   %eax,%eax
  80052a:	75 e6                	jne    800512 <runcmd+0x319>
			cprintf(" %s", argv[i]);
		cprintf("\n");
  80052c:	c7 04 24 20 36 80 00 	movl   $0x803620,(%esp)
  800533:	e8 f8 05 00 00       	call   800b30 <cprintf>
	}

	// Spawn the command!
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
  800538:	8d 45 a8             	lea    -0x58(%ebp),%eax
  80053b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80053f:	8b 45 a8             	mov    -0x58(%ebp),%eax
  800542:	89 04 24             	mov    %eax,(%esp)
  800545:	e8 f6 21 00 00       	call   802740 <spawn>
  80054a:	89 c3                	mov    %eax,%ebx
  80054c:	85 c0                	test   %eax,%eax
  80054e:	79 1e                	jns    80056e <runcmd+0x375>
		cprintf("spawn %s: %e\n", argv[0], r);
  800550:	89 44 24 08          	mov    %eax,0x8(%esp)
  800554:	8b 45 a8             	mov    -0x58(%ebp),%eax
  800557:	89 44 24 04          	mov    %eax,0x4(%esp)
  80055b:	c7 04 24 e6 36 80 00 	movl   $0x8036e6,(%esp)
  800562:	e8 c9 05 00 00       	call   800b30 <cprintf>

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  800567:	e8 f3 19 00 00       	call   801f5f <close_all>
  80056c:	eb 5a                	jmp    8005c8 <runcmd+0x3cf>
  80056e:	e8 ec 19 00 00       	call   801f5f <close_all>
	if (r >= 0) {
		if (debug)
  800573:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80057a:	74 23                	je     80059f <runcmd+0x3a6>
			cprintf("[%08x] WAIT %s %08x\n", thisenv->env_id, argv[0], r);
  80057c:	a1 24 54 80 00       	mov    0x805424,%eax
  800581:	8b 40 48             	mov    0x48(%eax),%eax
  800584:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800588:	8b 55 a8             	mov    -0x58(%ebp),%edx
  80058b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80058f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800593:	c7 04 24 f4 36 80 00 	movl   $0x8036f4,(%esp)
  80059a:	e8 91 05 00 00       	call   800b30 <cprintf>
		wait(r);
  80059f:	89 1c 24             	mov    %ebx,(%esp)
  8005a2:	e8 89 2b 00 00       	call   803130 <wait>
		if (debug)
  8005a7:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8005ae:	74 18                	je     8005c8 <runcmd+0x3cf>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005b0:	a1 24 54 80 00       	mov    0x805424,%eax
  8005b5:	8b 40 48             	mov    0x48(%eax),%eax
  8005b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005bc:	c7 04 24 09 37 80 00 	movl   $0x803709,(%esp)
  8005c3:	e8 68 05 00 00       	call   800b30 <cprintf>
	}

	// If we were the left-hand part of a pipe,
	// wait for the right-hand part to finish.
	if (pipe_child) {
  8005c8:	85 ff                	test   %edi,%edi
  8005ca:	74 4e                	je     80061a <runcmd+0x421>
		if (debug)
  8005cc:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8005d3:	74 1c                	je     8005f1 <runcmd+0x3f8>
			cprintf("[%08x] WAIT pipe_child %08x\n", thisenv->env_id, pipe_child);
  8005d5:	a1 24 54 80 00       	mov    0x805424,%eax
  8005da:	8b 40 48             	mov    0x48(%eax),%eax
  8005dd:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8005e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e5:	c7 04 24 1f 37 80 00 	movl   $0x80371f,(%esp)
  8005ec:	e8 3f 05 00 00       	call   800b30 <cprintf>
		wait(pipe_child);
  8005f1:	89 3c 24             	mov    %edi,(%esp)
  8005f4:	e8 37 2b 00 00       	call   803130 <wait>
		if (debug)
  8005f9:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800600:	74 18                	je     80061a <runcmd+0x421>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  800602:	a1 24 54 80 00       	mov    0x805424,%eax
  800607:	8b 40 48             	mov    0x48(%eax),%eax
  80060a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80060e:	c7 04 24 09 37 80 00 	movl   $0x803709,(%esp)
  800615:	e8 16 05 00 00       	call   800b30 <cprintf>
	}

	// Done!
	exit();
  80061a:	e8 05 04 00 00       	call   800a24 <exit>
}
  80061f:	81 c4 6c 04 00 00    	add    $0x46c,%esp
  800625:	5b                   	pop    %ebx
  800626:	5e                   	pop    %esi
  800627:	5f                   	pop    %edi
  800628:	5d                   	pop    %ebp
  800629:	c3                   	ret    

0080062a <usage>:
}


void
usage(void)
{
  80062a:	55                   	push   %ebp
  80062b:	89 e5                	mov    %esp,%ebp
  80062d:	83 ec 18             	sub    $0x18,%esp
	cprintf("usage: sh [-dix] [command-file]\n");
  800630:	c7 04 24 e8 37 80 00 	movl   $0x8037e8,(%esp)
  800637:	e8 f4 04 00 00       	call   800b30 <cprintf>
	exit();
  80063c:	e8 e3 03 00 00       	call   800a24 <exit>
}
  800641:	c9                   	leave  
  800642:	c3                   	ret    

00800643 <umain>:

void
umain(int argc, char **argv)
{
  800643:	55                   	push   %ebp
  800644:	89 e5                	mov    %esp,%ebp
  800646:	57                   	push   %edi
  800647:	56                   	push   %esi
  800648:	53                   	push   %ebx
  800649:	83 ec 4c             	sub    $0x4c,%esp
  80064c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
  80064f:	8d 45 d8             	lea    -0x28(%ebp),%eax
  800652:	89 44 24 08          	mov    %eax,0x8(%esp)
  800656:	89 74 24 04          	mov    %esi,0x4(%esp)
  80065a:	8d 45 08             	lea    0x8(%ebp),%eax
  80065d:	89 04 24             	mov    %eax,(%esp)
  800660:	e8 bb 15 00 00       	call   801c20 <argstart>
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
  800665:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
umain(int argc, char **argv)
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
  80066c:	bf 3f 00 00 00       	mov    $0x3f,%edi
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  800671:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  800674:	eb 2e                	jmp    8006a4 <umain+0x61>
		switch (r) {
  800676:	83 f8 69             	cmp    $0x69,%eax
  800679:	74 0c                	je     800687 <umain+0x44>
  80067b:	83 f8 78             	cmp    $0x78,%eax
  80067e:	74 1d                	je     80069d <umain+0x5a>
  800680:	83 f8 64             	cmp    $0x64,%eax
  800683:	75 11                	jne    800696 <umain+0x53>
  800685:	eb 07                	jmp    80068e <umain+0x4b>
		case 'd':
			debug++;
			break;
		case 'i':
			interactive = 1;
  800687:	bf 01 00 00 00       	mov    $0x1,%edi
  80068c:	eb 16                	jmp    8006a4 <umain+0x61>
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
		switch (r) {
		case 'd':
			debug++;
  80068e:	ff 05 00 40 80 00    	incl   0x804000
			break;
  800694:	eb 0e                	jmp    8006a4 <umain+0x61>
			break;
		case 'x':
			echocmds = 1;
			break;
		default:
			usage();
  800696:	e8 8f ff ff ff       	call   80062a <usage>
  80069b:	eb 07                	jmp    8006a4 <umain+0x61>
			break;
		case 'i':
			interactive = 1;
			break;
		case 'x':
			echocmds = 1;
  80069d:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  8006a4:	89 1c 24             	mov    %ebx,(%esp)
  8006a7:	e8 ad 15 00 00       	call   801c59 <argnext>
  8006ac:	85 c0                	test   %eax,%eax
  8006ae:	79 c6                	jns    800676 <umain+0x33>
  8006b0:	89 fb                	mov    %edi,%ebx
			break;
		default:
			usage();
		}

	if (argc > 2)
  8006b2:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  8006b6:	7e 05                	jle    8006bd <umain+0x7a>
		usage();
  8006b8:	e8 6d ff ff ff       	call   80062a <usage>
	if (argc == 2) {
  8006bd:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  8006c1:	75 72                	jne    800735 <umain+0xf2>
		close(0);
  8006c3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006ca:	e8 5f 18 00 00       	call   801f2e <close>
		if ((r = open(argv[1], O_RDONLY)) < 0)
  8006cf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8006d6:	00 
  8006d7:	8b 46 04             	mov    0x4(%esi),%eax
  8006da:	89 04 24             	mov    %eax,(%esp)
  8006dd:	e8 86 1e 00 00       	call   802568 <open>
  8006e2:	85 c0                	test   %eax,%eax
  8006e4:	79 27                	jns    80070d <umain+0xca>
			panic("open %s: %e", argv[1], r);
  8006e6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006ea:	8b 46 04             	mov    0x4(%esi),%eax
  8006ed:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006f1:	c7 44 24 08 3f 37 80 	movl   $0x80373f,0x8(%esp)
  8006f8:	00 
  8006f9:	c7 44 24 04 27 01 00 	movl   $0x127,0x4(%esp)
  800700:	00 
  800701:	c7 04 24 bf 36 80 00 	movl   $0x8036bf,(%esp)
  800708:	e8 2b 03 00 00       	call   800a38 <_panic>
		assert(r == 0);
  80070d:	85 c0                	test   %eax,%eax
  80070f:	74 24                	je     800735 <umain+0xf2>
  800711:	c7 44 24 0c 4b 37 80 	movl   $0x80374b,0xc(%esp)
  800718:	00 
  800719:	c7 44 24 08 52 37 80 	movl   $0x803752,0x8(%esp)
  800720:	00 
  800721:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
  800728:	00 
  800729:	c7 04 24 bf 36 80 00 	movl   $0x8036bf,(%esp)
  800730:	e8 03 03 00 00       	call   800a38 <_panic>
	}
	if (interactive == '?')
  800735:	83 fb 3f             	cmp    $0x3f,%ebx
  800738:	75 0e                	jne    800748 <umain+0x105>
		interactive = iscons(0);
  80073a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800741:	e8 07 02 00 00       	call   80094d <iscons>
  800746:	89 c7                	mov    %eax,%edi

	while (1) {
		char *buf;

		buf = readline(interactive ? "$ " : NULL);
  800748:	85 ff                	test   %edi,%edi
  80074a:	74 07                	je     800753 <umain+0x110>
  80074c:	b8 3c 37 80 00       	mov    $0x80373c,%eax
  800751:	eb 05                	jmp    800758 <umain+0x115>
  800753:	b8 00 00 00 00       	mov    $0x0,%eax
  800758:	89 04 24             	mov    %eax,(%esp)
  80075b:	e8 48 09 00 00       	call   8010a8 <readline>
  800760:	89 c3                	mov    %eax,%ebx
		if (buf == NULL) {
  800762:	85 c0                	test   %eax,%eax
  800764:	75 1a                	jne    800780 <umain+0x13d>
			if (debug)
  800766:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80076d:	74 0c                	je     80077b <umain+0x138>
				cprintf("EXITING\n");
  80076f:	c7 04 24 67 37 80 00 	movl   $0x803767,(%esp)
  800776:	e8 b5 03 00 00       	call   800b30 <cprintf>
			exit();	// end of file
  80077b:	e8 a4 02 00 00       	call   800a24 <exit>
		}
		if (debug)
  800780:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800787:	74 10                	je     800799 <umain+0x156>
			cprintf("LINE: %s\n", buf);
  800789:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80078d:	c7 04 24 70 37 80 00 	movl   $0x803770,(%esp)
  800794:	e8 97 03 00 00       	call   800b30 <cprintf>
		if (buf[0] == '#')
  800799:	80 3b 23             	cmpb   $0x23,(%ebx)
  80079c:	74 aa                	je     800748 <umain+0x105>
			continue;
		if (echocmds)
  80079e:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8007a2:	74 10                	je     8007b4 <umain+0x171>
			printf("# %s\n", buf);
  8007a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a8:	c7 04 24 7a 37 80 00 	movl   $0x80377a,(%esp)
  8007af:	e8 69 1f 00 00       	call   80271d <printf>
		if (debug)
  8007b4:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8007bb:	74 0c                	je     8007c9 <umain+0x186>
			cprintf("BEFORE FORK\n");
  8007bd:	c7 04 24 80 37 80 00 	movl   $0x803780,(%esp)
  8007c4:	e8 67 03 00 00       	call   800b30 <cprintf>
		if ((r = fork()) < 0)
  8007c9:	e8 59 11 00 00       	call   801927 <fork>
  8007ce:	89 c6                	mov    %eax,%esi
  8007d0:	85 c0                	test   %eax,%eax
  8007d2:	79 20                	jns    8007f4 <umain+0x1b1>
			panic("fork: %e", r);
  8007d4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007d8:	c7 44 24 08 9a 36 80 	movl   $0x80369a,0x8(%esp)
  8007df:	00 
  8007e0:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
  8007e7:	00 
  8007e8:	c7 04 24 bf 36 80 00 	movl   $0x8036bf,(%esp)
  8007ef:	e8 44 02 00 00       	call   800a38 <_panic>
		if (debug)
  8007f4:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8007fb:	74 10                	je     80080d <umain+0x1ca>
			cprintf("FORK: %d\n", r);
  8007fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800801:	c7 04 24 8d 37 80 00 	movl   $0x80378d,(%esp)
  800808:	e8 23 03 00 00       	call   800b30 <cprintf>
		if (r == 0) {
  80080d:	85 f6                	test   %esi,%esi
  80080f:	75 12                	jne    800823 <umain+0x1e0>
			runcmd(buf);
  800811:	89 1c 24             	mov    %ebx,(%esp)
  800814:	e8 e0 f9 ff ff       	call   8001f9 <runcmd>
			exit();
  800819:	e8 06 02 00 00       	call   800a24 <exit>
  80081e:	e9 25 ff ff ff       	jmp    800748 <umain+0x105>
		} else
			wait(r);
  800823:	89 34 24             	mov    %esi,(%esp)
  800826:	e8 05 29 00 00       	call   803130 <wait>
  80082b:	e9 18 ff ff ff       	jmp    800748 <umain+0x105>

00800830 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800833:	b8 00 00 00 00       	mov    $0x0,%eax
  800838:	5d                   	pop    %ebp
  800839:	c3                   	ret    

0080083a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  800840:	c7 44 24 04 09 38 80 	movl   $0x803809,0x4(%esp)
  800847:	00 
  800848:	8b 45 0c             	mov    0xc(%ebp),%eax
  80084b:	89 04 24             	mov    %eax,(%esp)
  80084e:	e8 68 09 00 00       	call   8011bb <strcpy>
	return 0;
}
  800853:	b8 00 00 00 00       	mov    $0x0,%eax
  800858:	c9                   	leave  
  800859:	c3                   	ret    

0080085a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80085a:	55                   	push   %ebp
  80085b:	89 e5                	mov    %esp,%ebp
  80085d:	57                   	push   %edi
  80085e:	56                   	push   %esi
  80085f:	53                   	push   %ebx
  800860:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800866:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80086b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800871:	eb 30                	jmp    8008a3 <devcons_write+0x49>
		m = n - tot;
  800873:	8b 75 10             	mov    0x10(%ebp),%esi
  800876:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  800878:	83 fe 7f             	cmp    $0x7f,%esi
  80087b:	76 05                	jbe    800882 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  80087d:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800882:	89 74 24 08          	mov    %esi,0x8(%esp)
  800886:	03 45 0c             	add    0xc(%ebp),%eax
  800889:	89 44 24 04          	mov    %eax,0x4(%esp)
  80088d:	89 3c 24             	mov    %edi,(%esp)
  800890:	e8 9f 0a 00 00       	call   801334 <memmove>
		sys_cputs(buf, m);
  800895:	89 74 24 04          	mov    %esi,0x4(%esp)
  800899:	89 3c 24             	mov    %edi,(%esp)
  80089c:	e8 3f 0c 00 00       	call   8014e0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8008a1:	01 f3                	add    %esi,%ebx
  8008a3:	89 d8                	mov    %ebx,%eax
  8008a5:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8008a8:	72 c9                	jb     800873 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8008aa:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8008b0:	5b                   	pop    %ebx
  8008b1:	5e                   	pop    %esi
  8008b2:	5f                   	pop    %edi
  8008b3:	5d                   	pop    %ebp
  8008b4:	c3                   	ret    

008008b5 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8008b5:	55                   	push   %ebp
  8008b6:	89 e5                	mov    %esp,%ebp
  8008b8:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8008bb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8008bf:	75 07                	jne    8008c8 <devcons_read+0x13>
  8008c1:	eb 25                	jmp    8008e8 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8008c3:	e8 c6 0c 00 00       	call   80158e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8008c8:	e8 31 0c 00 00       	call   8014fe <sys_cgetc>
  8008cd:	85 c0                	test   %eax,%eax
  8008cf:	74 f2                	je     8008c3 <devcons_read+0xe>
  8008d1:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8008d3:	85 c0                	test   %eax,%eax
  8008d5:	78 1d                	js     8008f4 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8008d7:	83 f8 04             	cmp    $0x4,%eax
  8008da:	74 13                	je     8008ef <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8008dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008df:	88 10                	mov    %dl,(%eax)
	return 1;
  8008e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8008e6:	eb 0c                	jmp    8008f4 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8008e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ed:	eb 05                	jmp    8008f4 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8008ef:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8008f4:	c9                   	leave  
  8008f5:	c3                   	ret    

008008f6 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8008f6:	55                   	push   %ebp
  8008f7:	89 e5                	mov    %esp,%ebp
  8008f9:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8008fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ff:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800902:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800909:	00 
  80090a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80090d:	89 04 24             	mov    %eax,(%esp)
  800910:	e8 cb 0b 00 00       	call   8014e0 <sys_cputs>
}
  800915:	c9                   	leave  
  800916:	c3                   	ret    

00800917 <getchar>:

int
getchar(void)
{
  800917:	55                   	push   %ebp
  800918:	89 e5                	mov    %esp,%ebp
  80091a:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80091d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  800924:	00 
  800925:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800928:	89 44 24 04          	mov    %eax,0x4(%esp)
  80092c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800933:	e8 5a 17 00 00       	call   802092 <read>
	if (r < 0)
  800938:	85 c0                	test   %eax,%eax
  80093a:	78 0f                	js     80094b <getchar+0x34>
		return r;
	if (r < 1)
  80093c:	85 c0                	test   %eax,%eax
  80093e:	7e 06                	jle    800946 <getchar+0x2f>
		return -E_EOF;
	return c;
  800940:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800944:	eb 05                	jmp    80094b <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800946:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80094b:	c9                   	leave  
  80094c:	c3                   	ret    

0080094d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80094d:	55                   	push   %ebp
  80094e:	89 e5                	mov    %esp,%ebp
  800950:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800953:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800956:	89 44 24 04          	mov    %eax,0x4(%esp)
  80095a:	8b 45 08             	mov    0x8(%ebp),%eax
  80095d:	89 04 24             	mov    %eax,(%esp)
  800960:	e8 91 14 00 00       	call   801df6 <fd_lookup>
  800965:	85 c0                	test   %eax,%eax
  800967:	78 11                	js     80097a <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800969:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80096c:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800972:	39 10                	cmp    %edx,(%eax)
  800974:	0f 94 c0             	sete   %al
  800977:	0f b6 c0             	movzbl %al,%eax
}
  80097a:	c9                   	leave  
  80097b:	c3                   	ret    

0080097c <opencons>:

int
opencons(void)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800982:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800985:	89 04 24             	mov    %eax,(%esp)
  800988:	e8 16 14 00 00       	call   801da3 <fd_alloc>
  80098d:	85 c0                	test   %eax,%eax
  80098f:	78 3c                	js     8009cd <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800991:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800998:	00 
  800999:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80099c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8009a7:	e8 01 0c 00 00       	call   8015ad <sys_page_alloc>
  8009ac:	85 c0                	test   %eax,%eax
  8009ae:	78 1d                	js     8009cd <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8009b0:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8009b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009b9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8009bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009be:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8009c5:	89 04 24             	mov    %eax,(%esp)
  8009c8:	e8 ab 13 00 00       	call   801d78 <fd2num>
}
  8009cd:	c9                   	leave  
  8009ce:	c3                   	ret    
	...

008009d0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8009d0:	55                   	push   %ebp
  8009d1:	89 e5                	mov    %esp,%ebp
  8009d3:	56                   	push   %esi
  8009d4:	53                   	push   %ebx
  8009d5:	83 ec 10             	sub    $0x10,%esp
  8009d8:	8b 75 08             	mov    0x8(%ebp),%esi
  8009db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8009de:	e8 8c 0b 00 00       	call   80156f <sys_getenvid>
  8009e3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8009e8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8009ef:	c1 e0 07             	shl    $0x7,%eax
  8009f2:	29 d0                	sub    %edx,%eax
  8009f4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8009f9:	a3 24 54 80 00       	mov    %eax,0x805424

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8009fe:	85 f6                	test   %esi,%esi
  800a00:	7e 07                	jle    800a09 <libmain+0x39>
		binaryname = argv[0];
  800a02:	8b 03                	mov    (%ebx),%eax
  800a04:	a3 20 40 80 00       	mov    %eax,0x804020

	// call user main routine
	umain(argc, argv);
  800a09:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a0d:	89 34 24             	mov    %esi,(%esp)
  800a10:	e8 2e fc ff ff       	call   800643 <umain>

	// exit gracefully
	exit();
  800a15:	e8 0a 00 00 00       	call   800a24 <exit>
}
  800a1a:	83 c4 10             	add    $0x10,%esp
  800a1d:	5b                   	pop    %ebx
  800a1e:	5e                   	pop    %esi
  800a1f:	5d                   	pop    %ebp
  800a20:	c3                   	ret    
  800a21:	00 00                	add    %al,(%eax)
	...

00800a24 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800a24:	55                   	push   %ebp
  800a25:	89 e5                	mov    %esp,%ebp
  800a27:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  800a2a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a31:	e8 e7 0a 00 00       	call   80151d <sys_env_destroy>
}
  800a36:	c9                   	leave  
  800a37:	c3                   	ret    

00800a38 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800a38:	55                   	push   %ebp
  800a39:	89 e5                	mov    %esp,%ebp
  800a3b:	56                   	push   %esi
  800a3c:	53                   	push   %ebx
  800a3d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800a40:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800a43:	8b 1d 20 40 80 00    	mov    0x804020,%ebx
  800a49:	e8 21 0b 00 00       	call   80156f <sys_getenvid>
  800a4e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a51:	89 54 24 10          	mov    %edx,0x10(%esp)
  800a55:	8b 55 08             	mov    0x8(%ebp),%edx
  800a58:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a5c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800a60:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a64:	c7 04 24 20 38 80 00 	movl   $0x803820,(%esp)
  800a6b:	e8 c0 00 00 00       	call   800b30 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800a70:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a74:	8b 45 10             	mov    0x10(%ebp),%eax
  800a77:	89 04 24             	mov    %eax,(%esp)
  800a7a:	e8 50 00 00 00       	call   800acf <vcprintf>
	cprintf("\n");
  800a7f:	c7 04 24 20 36 80 00 	movl   $0x803620,(%esp)
  800a86:	e8 a5 00 00 00       	call   800b30 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800a8b:	cc                   	int3   
  800a8c:	eb fd                	jmp    800a8b <_panic+0x53>
	...

00800a90 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800a90:	55                   	push   %ebp
  800a91:	89 e5                	mov    %esp,%ebp
  800a93:	53                   	push   %ebx
  800a94:	83 ec 14             	sub    $0x14,%esp
  800a97:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800a9a:	8b 03                	mov    (%ebx),%eax
  800a9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a9f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800aa3:	40                   	inc    %eax
  800aa4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800aa6:	3d ff 00 00 00       	cmp    $0xff,%eax
  800aab:	75 19                	jne    800ac6 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800aad:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800ab4:	00 
  800ab5:	8d 43 08             	lea    0x8(%ebx),%eax
  800ab8:	89 04 24             	mov    %eax,(%esp)
  800abb:	e8 20 0a 00 00       	call   8014e0 <sys_cputs>
		b->idx = 0;
  800ac0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800ac6:	ff 43 04             	incl   0x4(%ebx)
}
  800ac9:	83 c4 14             	add    $0x14,%esp
  800acc:	5b                   	pop    %ebx
  800acd:	5d                   	pop    %ebp
  800ace:	c3                   	ret    

00800acf <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800acf:	55                   	push   %ebp
  800ad0:	89 e5                	mov    %esp,%ebp
  800ad2:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800ad8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800adf:	00 00 00 
	b.cnt = 0;
  800ae2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800ae9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800aec:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aef:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800af3:	8b 45 08             	mov    0x8(%ebp),%eax
  800af6:	89 44 24 08          	mov    %eax,0x8(%esp)
  800afa:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800b00:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b04:	c7 04 24 90 0a 80 00 	movl   $0x800a90,(%esp)
  800b0b:	e8 82 01 00 00       	call   800c92 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800b10:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800b16:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b1a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800b20:	89 04 24             	mov    %eax,(%esp)
  800b23:	e8 b8 09 00 00       	call   8014e0 <sys_cputs>

	return b.cnt;
}
  800b28:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800b2e:	c9                   	leave  
  800b2f:	c3                   	ret    

00800b30 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800b30:	55                   	push   %ebp
  800b31:	89 e5                	mov    %esp,%ebp
  800b33:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800b36:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800b39:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b40:	89 04 24             	mov    %eax,(%esp)
  800b43:	e8 87 ff ff ff       	call   800acf <vcprintf>
	va_end(ap);

	return cnt;
}
  800b48:	c9                   	leave  
  800b49:	c3                   	ret    
	...

00800b4c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800b4c:	55                   	push   %ebp
  800b4d:	89 e5                	mov    %esp,%ebp
  800b4f:	57                   	push   %edi
  800b50:	56                   	push   %esi
  800b51:	53                   	push   %ebx
  800b52:	83 ec 3c             	sub    $0x3c,%esp
  800b55:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b58:	89 d7                	mov    %edx,%edi
  800b5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800b60:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b63:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b66:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800b69:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800b6c:	85 c0                	test   %eax,%eax
  800b6e:	75 08                	jne    800b78 <printnum+0x2c>
  800b70:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800b73:	39 45 10             	cmp    %eax,0x10(%ebp)
  800b76:	77 57                	ja     800bcf <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800b78:	89 74 24 10          	mov    %esi,0x10(%esp)
  800b7c:	4b                   	dec    %ebx
  800b7d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800b81:	8b 45 10             	mov    0x10(%ebp),%eax
  800b84:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b88:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800b8c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800b90:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800b97:	00 
  800b98:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800b9b:	89 04 24             	mov    %eax,(%esp)
  800b9e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ba1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ba5:	e8 ea 27 00 00       	call   803394 <__udivdi3>
  800baa:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800bae:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800bb2:	89 04 24             	mov    %eax,(%esp)
  800bb5:	89 54 24 04          	mov    %edx,0x4(%esp)
  800bb9:	89 fa                	mov    %edi,%edx
  800bbb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800bbe:	e8 89 ff ff ff       	call   800b4c <printnum>
  800bc3:	eb 0f                	jmp    800bd4 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800bc5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bc9:	89 34 24             	mov    %esi,(%esp)
  800bcc:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800bcf:	4b                   	dec    %ebx
  800bd0:	85 db                	test   %ebx,%ebx
  800bd2:	7f f1                	jg     800bc5 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800bd4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bd8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800bdc:	8b 45 10             	mov    0x10(%ebp),%eax
  800bdf:	89 44 24 08          	mov    %eax,0x8(%esp)
  800be3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800bea:	00 
  800beb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800bee:	89 04 24             	mov    %eax,(%esp)
  800bf1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800bf4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bf8:	e8 b7 28 00 00       	call   8034b4 <__umoddi3>
  800bfd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c01:	0f be 80 43 38 80 00 	movsbl 0x803843(%eax),%eax
  800c08:	89 04 24             	mov    %eax,(%esp)
  800c0b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800c0e:	83 c4 3c             	add    $0x3c,%esp
  800c11:	5b                   	pop    %ebx
  800c12:	5e                   	pop    %esi
  800c13:	5f                   	pop    %edi
  800c14:	5d                   	pop    %ebp
  800c15:	c3                   	ret    

00800c16 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800c16:	55                   	push   %ebp
  800c17:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800c19:	83 fa 01             	cmp    $0x1,%edx
  800c1c:	7e 0e                	jle    800c2c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800c1e:	8b 10                	mov    (%eax),%edx
  800c20:	8d 4a 08             	lea    0x8(%edx),%ecx
  800c23:	89 08                	mov    %ecx,(%eax)
  800c25:	8b 02                	mov    (%edx),%eax
  800c27:	8b 52 04             	mov    0x4(%edx),%edx
  800c2a:	eb 22                	jmp    800c4e <getuint+0x38>
	else if (lflag)
  800c2c:	85 d2                	test   %edx,%edx
  800c2e:	74 10                	je     800c40 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800c30:	8b 10                	mov    (%eax),%edx
  800c32:	8d 4a 04             	lea    0x4(%edx),%ecx
  800c35:	89 08                	mov    %ecx,(%eax)
  800c37:	8b 02                	mov    (%edx),%eax
  800c39:	ba 00 00 00 00       	mov    $0x0,%edx
  800c3e:	eb 0e                	jmp    800c4e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800c40:	8b 10                	mov    (%eax),%edx
  800c42:	8d 4a 04             	lea    0x4(%edx),%ecx
  800c45:	89 08                	mov    %ecx,(%eax)
  800c47:	8b 02                	mov    (%edx),%eax
  800c49:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800c4e:	5d                   	pop    %ebp
  800c4f:	c3                   	ret    

00800c50 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800c50:	55                   	push   %ebp
  800c51:	89 e5                	mov    %esp,%ebp
  800c53:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800c56:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800c59:	8b 10                	mov    (%eax),%edx
  800c5b:	3b 50 04             	cmp    0x4(%eax),%edx
  800c5e:	73 08                	jae    800c68 <sprintputch+0x18>
		*b->buf++ = ch;
  800c60:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c63:	88 0a                	mov    %cl,(%edx)
  800c65:	42                   	inc    %edx
  800c66:	89 10                	mov    %edx,(%eax)
}
  800c68:	5d                   	pop    %ebp
  800c69:	c3                   	ret    

00800c6a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800c6a:	55                   	push   %ebp
  800c6b:	89 e5                	mov    %esp,%ebp
  800c6d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800c70:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800c73:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c77:	8b 45 10             	mov    0x10(%ebp),%eax
  800c7a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c81:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c85:	8b 45 08             	mov    0x8(%ebp),%eax
  800c88:	89 04 24             	mov    %eax,(%esp)
  800c8b:	e8 02 00 00 00       	call   800c92 <vprintfmt>
	va_end(ap);
}
  800c90:	c9                   	leave  
  800c91:	c3                   	ret    

00800c92 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800c92:	55                   	push   %ebp
  800c93:	89 e5                	mov    %esp,%ebp
  800c95:	57                   	push   %edi
  800c96:	56                   	push   %esi
  800c97:	53                   	push   %ebx
  800c98:	83 ec 4c             	sub    $0x4c,%esp
  800c9b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c9e:	8b 75 10             	mov    0x10(%ebp),%esi
  800ca1:	eb 12                	jmp    800cb5 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800ca3:	85 c0                	test   %eax,%eax
  800ca5:	0f 84 6b 03 00 00    	je     801016 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800cab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800caf:	89 04 24             	mov    %eax,(%esp)
  800cb2:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800cb5:	0f b6 06             	movzbl (%esi),%eax
  800cb8:	46                   	inc    %esi
  800cb9:	83 f8 25             	cmp    $0x25,%eax
  800cbc:	75 e5                	jne    800ca3 <vprintfmt+0x11>
  800cbe:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800cc2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800cc9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800cce:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800cd5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cda:	eb 26                	jmp    800d02 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cdc:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800cdf:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800ce3:	eb 1d                	jmp    800d02 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ce5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800ce8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800cec:	eb 14                	jmp    800d02 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cee:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800cf1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800cf8:	eb 08                	jmp    800d02 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800cfa:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800cfd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d02:	0f b6 06             	movzbl (%esi),%eax
  800d05:	8d 56 01             	lea    0x1(%esi),%edx
  800d08:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800d0b:	8a 16                	mov    (%esi),%dl
  800d0d:	83 ea 23             	sub    $0x23,%edx
  800d10:	80 fa 55             	cmp    $0x55,%dl
  800d13:	0f 87 e1 02 00 00    	ja     800ffa <vprintfmt+0x368>
  800d19:	0f b6 d2             	movzbl %dl,%edx
  800d1c:	ff 24 95 80 39 80 00 	jmp    *0x803980(,%edx,4)
  800d23:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800d26:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800d2b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800d2e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800d32:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800d35:	8d 50 d0             	lea    -0x30(%eax),%edx
  800d38:	83 fa 09             	cmp    $0x9,%edx
  800d3b:	77 2a                	ja     800d67 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800d3d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800d3e:	eb eb                	jmp    800d2b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800d40:	8b 45 14             	mov    0x14(%ebp),%eax
  800d43:	8d 50 04             	lea    0x4(%eax),%edx
  800d46:	89 55 14             	mov    %edx,0x14(%ebp)
  800d49:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d4b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800d4e:	eb 17                	jmp    800d67 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800d50:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800d54:	78 98                	js     800cee <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d56:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800d59:	eb a7                	jmp    800d02 <vprintfmt+0x70>
  800d5b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800d5e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800d65:	eb 9b                	jmp    800d02 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800d67:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800d6b:	79 95                	jns    800d02 <vprintfmt+0x70>
  800d6d:	eb 8b                	jmp    800cfa <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800d6f:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d70:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800d73:	eb 8d                	jmp    800d02 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800d75:	8b 45 14             	mov    0x14(%ebp),%eax
  800d78:	8d 50 04             	lea    0x4(%eax),%edx
  800d7b:	89 55 14             	mov    %edx,0x14(%ebp)
  800d7e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d82:	8b 00                	mov    (%eax),%eax
  800d84:	89 04 24             	mov    %eax,(%esp)
  800d87:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d8a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800d8d:	e9 23 ff ff ff       	jmp    800cb5 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800d92:	8b 45 14             	mov    0x14(%ebp),%eax
  800d95:	8d 50 04             	lea    0x4(%eax),%edx
  800d98:	89 55 14             	mov    %edx,0x14(%ebp)
  800d9b:	8b 00                	mov    (%eax),%eax
  800d9d:	85 c0                	test   %eax,%eax
  800d9f:	79 02                	jns    800da3 <vprintfmt+0x111>
  800da1:	f7 d8                	neg    %eax
  800da3:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800da5:	83 f8 0f             	cmp    $0xf,%eax
  800da8:	7f 0b                	jg     800db5 <vprintfmt+0x123>
  800daa:	8b 04 85 e0 3a 80 00 	mov    0x803ae0(,%eax,4),%eax
  800db1:	85 c0                	test   %eax,%eax
  800db3:	75 23                	jne    800dd8 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800db5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800db9:	c7 44 24 08 5b 38 80 	movl   $0x80385b,0x8(%esp)
  800dc0:	00 
  800dc1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800dc5:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc8:	89 04 24             	mov    %eax,(%esp)
  800dcb:	e8 9a fe ff ff       	call   800c6a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800dd0:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800dd3:	e9 dd fe ff ff       	jmp    800cb5 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800dd8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ddc:	c7 44 24 08 64 37 80 	movl   $0x803764,0x8(%esp)
  800de3:	00 
  800de4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800de8:	8b 55 08             	mov    0x8(%ebp),%edx
  800deb:	89 14 24             	mov    %edx,(%esp)
  800dee:	e8 77 fe ff ff       	call   800c6a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800df3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800df6:	e9 ba fe ff ff       	jmp    800cb5 <vprintfmt+0x23>
  800dfb:	89 f9                	mov    %edi,%ecx
  800dfd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e00:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800e03:	8b 45 14             	mov    0x14(%ebp),%eax
  800e06:	8d 50 04             	lea    0x4(%eax),%edx
  800e09:	89 55 14             	mov    %edx,0x14(%ebp)
  800e0c:	8b 30                	mov    (%eax),%esi
  800e0e:	85 f6                	test   %esi,%esi
  800e10:	75 05                	jne    800e17 <vprintfmt+0x185>
				p = "(null)";
  800e12:	be 54 38 80 00       	mov    $0x803854,%esi
			if (width > 0 && padc != '-')
  800e17:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800e1b:	0f 8e 84 00 00 00    	jle    800ea5 <vprintfmt+0x213>
  800e21:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800e25:	74 7e                	je     800ea5 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800e27:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e2b:	89 34 24             	mov    %esi,(%esp)
  800e2e:	e8 6b 03 00 00       	call   80119e <strnlen>
  800e33:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800e36:	29 c2                	sub    %eax,%edx
  800e38:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800e3b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800e3f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800e42:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800e45:	89 de                	mov    %ebx,%esi
  800e47:	89 d3                	mov    %edx,%ebx
  800e49:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800e4b:	eb 0b                	jmp    800e58 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800e4d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e51:	89 3c 24             	mov    %edi,(%esp)
  800e54:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800e57:	4b                   	dec    %ebx
  800e58:	85 db                	test   %ebx,%ebx
  800e5a:	7f f1                	jg     800e4d <vprintfmt+0x1bb>
  800e5c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800e5f:	89 f3                	mov    %esi,%ebx
  800e61:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800e64:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e67:	85 c0                	test   %eax,%eax
  800e69:	79 05                	jns    800e70 <vprintfmt+0x1de>
  800e6b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e70:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800e73:	29 c2                	sub    %eax,%edx
  800e75:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800e78:	eb 2b                	jmp    800ea5 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800e7a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800e7e:	74 18                	je     800e98 <vprintfmt+0x206>
  800e80:	8d 50 e0             	lea    -0x20(%eax),%edx
  800e83:	83 fa 5e             	cmp    $0x5e,%edx
  800e86:	76 10                	jbe    800e98 <vprintfmt+0x206>
					putch('?', putdat);
  800e88:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e8c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800e93:	ff 55 08             	call   *0x8(%ebp)
  800e96:	eb 0a                	jmp    800ea2 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800e98:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e9c:	89 04 24             	mov    %eax,(%esp)
  800e9f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800ea2:	ff 4d e4             	decl   -0x1c(%ebp)
  800ea5:	0f be 06             	movsbl (%esi),%eax
  800ea8:	46                   	inc    %esi
  800ea9:	85 c0                	test   %eax,%eax
  800eab:	74 21                	je     800ece <vprintfmt+0x23c>
  800ead:	85 ff                	test   %edi,%edi
  800eaf:	78 c9                	js     800e7a <vprintfmt+0x1e8>
  800eb1:	4f                   	dec    %edi
  800eb2:	79 c6                	jns    800e7a <vprintfmt+0x1e8>
  800eb4:	8b 7d 08             	mov    0x8(%ebp),%edi
  800eb7:	89 de                	mov    %ebx,%esi
  800eb9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800ebc:	eb 18                	jmp    800ed6 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800ebe:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ec2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800ec9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800ecb:	4b                   	dec    %ebx
  800ecc:	eb 08                	jmp    800ed6 <vprintfmt+0x244>
  800ece:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ed1:	89 de                	mov    %ebx,%esi
  800ed3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800ed6:	85 db                	test   %ebx,%ebx
  800ed8:	7f e4                	jg     800ebe <vprintfmt+0x22c>
  800eda:	89 7d 08             	mov    %edi,0x8(%ebp)
  800edd:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800edf:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800ee2:	e9 ce fd ff ff       	jmp    800cb5 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800ee7:	83 f9 01             	cmp    $0x1,%ecx
  800eea:	7e 10                	jle    800efc <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800eec:	8b 45 14             	mov    0x14(%ebp),%eax
  800eef:	8d 50 08             	lea    0x8(%eax),%edx
  800ef2:	89 55 14             	mov    %edx,0x14(%ebp)
  800ef5:	8b 30                	mov    (%eax),%esi
  800ef7:	8b 78 04             	mov    0x4(%eax),%edi
  800efa:	eb 26                	jmp    800f22 <vprintfmt+0x290>
	else if (lflag)
  800efc:	85 c9                	test   %ecx,%ecx
  800efe:	74 12                	je     800f12 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800f00:	8b 45 14             	mov    0x14(%ebp),%eax
  800f03:	8d 50 04             	lea    0x4(%eax),%edx
  800f06:	89 55 14             	mov    %edx,0x14(%ebp)
  800f09:	8b 30                	mov    (%eax),%esi
  800f0b:	89 f7                	mov    %esi,%edi
  800f0d:	c1 ff 1f             	sar    $0x1f,%edi
  800f10:	eb 10                	jmp    800f22 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800f12:	8b 45 14             	mov    0x14(%ebp),%eax
  800f15:	8d 50 04             	lea    0x4(%eax),%edx
  800f18:	89 55 14             	mov    %edx,0x14(%ebp)
  800f1b:	8b 30                	mov    (%eax),%esi
  800f1d:	89 f7                	mov    %esi,%edi
  800f1f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800f22:	85 ff                	test   %edi,%edi
  800f24:	78 0a                	js     800f30 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800f26:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f2b:	e9 8c 00 00 00       	jmp    800fbc <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800f30:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f34:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800f3b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800f3e:	f7 de                	neg    %esi
  800f40:	83 d7 00             	adc    $0x0,%edi
  800f43:	f7 df                	neg    %edi
			}
			base = 10;
  800f45:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f4a:	eb 70                	jmp    800fbc <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800f4c:	89 ca                	mov    %ecx,%edx
  800f4e:	8d 45 14             	lea    0x14(%ebp),%eax
  800f51:	e8 c0 fc ff ff       	call   800c16 <getuint>
  800f56:	89 c6                	mov    %eax,%esi
  800f58:	89 d7                	mov    %edx,%edi
			base = 10;
  800f5a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800f5f:	eb 5b                	jmp    800fbc <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  800f61:	89 ca                	mov    %ecx,%edx
  800f63:	8d 45 14             	lea    0x14(%ebp),%eax
  800f66:	e8 ab fc ff ff       	call   800c16 <getuint>
  800f6b:	89 c6                	mov    %eax,%esi
  800f6d:	89 d7                	mov    %edx,%edi
			base = 8;
  800f6f:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800f74:	eb 46                	jmp    800fbc <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  800f76:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f7a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800f81:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800f84:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f88:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800f8f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800f92:	8b 45 14             	mov    0x14(%ebp),%eax
  800f95:	8d 50 04             	lea    0x4(%eax),%edx
  800f98:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800f9b:	8b 30                	mov    (%eax),%esi
  800f9d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800fa2:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800fa7:	eb 13                	jmp    800fbc <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800fa9:	89 ca                	mov    %ecx,%edx
  800fab:	8d 45 14             	lea    0x14(%ebp),%eax
  800fae:	e8 63 fc ff ff       	call   800c16 <getuint>
  800fb3:	89 c6                	mov    %eax,%esi
  800fb5:	89 d7                	mov    %edx,%edi
			base = 16;
  800fb7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800fbc:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800fc0:	89 54 24 10          	mov    %edx,0x10(%esp)
  800fc4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800fc7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fcb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fcf:	89 34 24             	mov    %esi,(%esp)
  800fd2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800fd6:	89 da                	mov    %ebx,%edx
  800fd8:	8b 45 08             	mov    0x8(%ebp),%eax
  800fdb:	e8 6c fb ff ff       	call   800b4c <printnum>
			break;
  800fe0:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800fe3:	e9 cd fc ff ff       	jmp    800cb5 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800fe8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800fec:	89 04 24             	mov    %eax,(%esp)
  800fef:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ff2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800ff5:	e9 bb fc ff ff       	jmp    800cb5 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800ffa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ffe:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  801005:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  801008:	eb 01                	jmp    80100b <vprintfmt+0x379>
  80100a:	4e                   	dec    %esi
  80100b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80100f:	75 f9                	jne    80100a <vprintfmt+0x378>
  801011:	e9 9f fc ff ff       	jmp    800cb5 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  801016:	83 c4 4c             	add    $0x4c,%esp
  801019:	5b                   	pop    %ebx
  80101a:	5e                   	pop    %esi
  80101b:	5f                   	pop    %edi
  80101c:	5d                   	pop    %ebp
  80101d:	c3                   	ret    

0080101e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80101e:	55                   	push   %ebp
  80101f:	89 e5                	mov    %esp,%ebp
  801021:	83 ec 28             	sub    $0x28,%esp
  801024:	8b 45 08             	mov    0x8(%ebp),%eax
  801027:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80102a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80102d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801031:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801034:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80103b:	85 c0                	test   %eax,%eax
  80103d:	74 30                	je     80106f <vsnprintf+0x51>
  80103f:	85 d2                	test   %edx,%edx
  801041:	7e 33                	jle    801076 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801043:	8b 45 14             	mov    0x14(%ebp),%eax
  801046:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80104a:	8b 45 10             	mov    0x10(%ebp),%eax
  80104d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801051:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801054:	89 44 24 04          	mov    %eax,0x4(%esp)
  801058:	c7 04 24 50 0c 80 00 	movl   $0x800c50,(%esp)
  80105f:	e8 2e fc ff ff       	call   800c92 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801064:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801067:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80106a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80106d:	eb 0c                	jmp    80107b <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80106f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801074:	eb 05                	jmp    80107b <vsnprintf+0x5d>
  801076:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80107b:	c9                   	leave  
  80107c:	c3                   	ret    

0080107d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80107d:	55                   	push   %ebp
  80107e:	89 e5                	mov    %esp,%ebp
  801080:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801083:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801086:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80108a:	8b 45 10             	mov    0x10(%ebp),%eax
  80108d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801091:	8b 45 0c             	mov    0xc(%ebp),%eax
  801094:	89 44 24 04          	mov    %eax,0x4(%esp)
  801098:	8b 45 08             	mov    0x8(%ebp),%eax
  80109b:	89 04 24             	mov    %eax,(%esp)
  80109e:	e8 7b ff ff ff       	call   80101e <vsnprintf>
	va_end(ap);

	return rc;
}
  8010a3:	c9                   	leave  
  8010a4:	c3                   	ret    
  8010a5:	00 00                	add    %al,(%eax)
	...

008010a8 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  8010a8:	55                   	push   %ebp
  8010a9:	89 e5                	mov    %esp,%ebp
  8010ab:	57                   	push   %edi
  8010ac:	56                   	push   %esi
  8010ad:	53                   	push   %ebx
  8010ae:	83 ec 1c             	sub    $0x1c,%esp
  8010b1:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  8010b4:	85 c0                	test   %eax,%eax
  8010b6:	74 18                	je     8010d0 <readline+0x28>
		fprintf(1, "%s", prompt);
  8010b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010bc:	c7 44 24 04 64 37 80 	movl   $0x803764,0x4(%esp)
  8010c3:	00 
  8010c4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8010cb:	e8 2c 16 00 00       	call   8026fc <fprintf>
#endif

	i = 0;
	echoing = iscons(0);
  8010d0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010d7:	e8 71 f8 ff ff       	call   80094d <iscons>
  8010dc:	89 c7                	mov    %eax,%edi
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  8010de:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  8010e3:	e8 2f f8 ff ff       	call   800917 <getchar>
  8010e8:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  8010ea:	85 c0                	test   %eax,%eax
  8010ec:	79 20                	jns    80110e <readline+0x66>
			if (c != -E_EOF)
  8010ee:	83 f8 f8             	cmp    $0xfffffff8,%eax
  8010f1:	0f 84 82 00 00 00    	je     801179 <readline+0xd1>
				cprintf("read error: %e\n", c);
  8010f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010fb:	c7 04 24 3f 3b 80 00 	movl   $0x803b3f,(%esp)
  801102:	e8 29 fa ff ff       	call   800b30 <cprintf>
			return NULL;
  801107:	b8 00 00 00 00       	mov    $0x0,%eax
  80110c:	eb 70                	jmp    80117e <readline+0xd6>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  80110e:	83 f8 08             	cmp    $0x8,%eax
  801111:	74 05                	je     801118 <readline+0x70>
  801113:	83 f8 7f             	cmp    $0x7f,%eax
  801116:	75 17                	jne    80112f <readline+0x87>
  801118:	85 f6                	test   %esi,%esi
  80111a:	7e 13                	jle    80112f <readline+0x87>
			if (echoing)
  80111c:	85 ff                	test   %edi,%edi
  80111e:	74 0c                	je     80112c <readline+0x84>
				cputchar('\b');
  801120:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  801127:	e8 ca f7 ff ff       	call   8008f6 <cputchar>
			i--;
  80112c:	4e                   	dec    %esi
  80112d:	eb b4                	jmp    8010e3 <readline+0x3b>
		} else if (c >= ' ' && i < BUFLEN-1) {
  80112f:	83 fb 1f             	cmp    $0x1f,%ebx
  801132:	7e 1d                	jle    801151 <readline+0xa9>
  801134:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  80113a:	7f 15                	jg     801151 <readline+0xa9>
			if (echoing)
  80113c:	85 ff                	test   %edi,%edi
  80113e:	74 08                	je     801148 <readline+0xa0>
				cputchar(c);
  801140:	89 1c 24             	mov    %ebx,(%esp)
  801143:	e8 ae f7 ff ff       	call   8008f6 <cputchar>
			buf[i++] = c;
  801148:	88 9e 20 50 80 00    	mov    %bl,0x805020(%esi)
  80114e:	46                   	inc    %esi
  80114f:	eb 92                	jmp    8010e3 <readline+0x3b>
		} else if (c == '\n' || c == '\r') {
  801151:	83 fb 0a             	cmp    $0xa,%ebx
  801154:	74 05                	je     80115b <readline+0xb3>
  801156:	83 fb 0d             	cmp    $0xd,%ebx
  801159:	75 88                	jne    8010e3 <readline+0x3b>
			if (echoing)
  80115b:	85 ff                	test   %edi,%edi
  80115d:	74 0c                	je     80116b <readline+0xc3>
				cputchar('\n');
  80115f:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  801166:	e8 8b f7 ff ff       	call   8008f6 <cputchar>
			buf[i] = 0;
  80116b:	c6 86 20 50 80 00 00 	movb   $0x0,0x805020(%esi)
			return buf;
  801172:	b8 20 50 80 00       	mov    $0x805020,%eax
  801177:	eb 05                	jmp    80117e <readline+0xd6>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  801179:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
  80117e:	83 c4 1c             	add    $0x1c,%esp
  801181:	5b                   	pop    %ebx
  801182:	5e                   	pop    %esi
  801183:	5f                   	pop    %edi
  801184:	5d                   	pop    %ebp
  801185:	c3                   	ret    
	...

00801188 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801188:	55                   	push   %ebp
  801189:	89 e5                	mov    %esp,%ebp
  80118b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80118e:	b8 00 00 00 00       	mov    $0x0,%eax
  801193:	eb 01                	jmp    801196 <strlen+0xe>
		n++;
  801195:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801196:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80119a:	75 f9                	jne    801195 <strlen+0xd>
		n++;
	return n;
}
  80119c:	5d                   	pop    %ebp
  80119d:	c3                   	ret    

0080119e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80119e:	55                   	push   %ebp
  80119f:	89 e5                	mov    %esp,%ebp
  8011a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8011a4:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8011a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ac:	eb 01                	jmp    8011af <strnlen+0x11>
		n++;
  8011ae:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8011af:	39 d0                	cmp    %edx,%eax
  8011b1:	74 06                	je     8011b9 <strnlen+0x1b>
  8011b3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8011b7:	75 f5                	jne    8011ae <strnlen+0x10>
		n++;
	return n;
}
  8011b9:	5d                   	pop    %ebp
  8011ba:	c3                   	ret    

008011bb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8011bb:	55                   	push   %ebp
  8011bc:	89 e5                	mov    %esp,%ebp
  8011be:	53                   	push   %ebx
  8011bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8011c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8011ca:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8011cd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8011d0:	42                   	inc    %edx
  8011d1:	84 c9                	test   %cl,%cl
  8011d3:	75 f5                	jne    8011ca <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8011d5:	5b                   	pop    %ebx
  8011d6:	5d                   	pop    %ebp
  8011d7:	c3                   	ret    

008011d8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8011d8:	55                   	push   %ebp
  8011d9:	89 e5                	mov    %esp,%ebp
  8011db:	53                   	push   %ebx
  8011dc:	83 ec 08             	sub    $0x8,%esp
  8011df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8011e2:	89 1c 24             	mov    %ebx,(%esp)
  8011e5:	e8 9e ff ff ff       	call   801188 <strlen>
	strcpy(dst + len, src);
  8011ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011ed:	89 54 24 04          	mov    %edx,0x4(%esp)
  8011f1:	01 d8                	add    %ebx,%eax
  8011f3:	89 04 24             	mov    %eax,(%esp)
  8011f6:	e8 c0 ff ff ff       	call   8011bb <strcpy>
	return dst;
}
  8011fb:	89 d8                	mov    %ebx,%eax
  8011fd:	83 c4 08             	add    $0x8,%esp
  801200:	5b                   	pop    %ebx
  801201:	5d                   	pop    %ebp
  801202:	c3                   	ret    

00801203 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801203:	55                   	push   %ebp
  801204:	89 e5                	mov    %esp,%ebp
  801206:	56                   	push   %esi
  801207:	53                   	push   %ebx
  801208:	8b 45 08             	mov    0x8(%ebp),%eax
  80120b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80120e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801211:	b9 00 00 00 00       	mov    $0x0,%ecx
  801216:	eb 0c                	jmp    801224 <strncpy+0x21>
		*dst++ = *src;
  801218:	8a 1a                	mov    (%edx),%bl
  80121a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80121d:	80 3a 01             	cmpb   $0x1,(%edx)
  801220:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801223:	41                   	inc    %ecx
  801224:	39 f1                	cmp    %esi,%ecx
  801226:	75 f0                	jne    801218 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801228:	5b                   	pop    %ebx
  801229:	5e                   	pop    %esi
  80122a:	5d                   	pop    %ebp
  80122b:	c3                   	ret    

0080122c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80122c:	55                   	push   %ebp
  80122d:	89 e5                	mov    %esp,%ebp
  80122f:	56                   	push   %esi
  801230:	53                   	push   %ebx
  801231:	8b 75 08             	mov    0x8(%ebp),%esi
  801234:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801237:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80123a:	85 d2                	test   %edx,%edx
  80123c:	75 0a                	jne    801248 <strlcpy+0x1c>
  80123e:	89 f0                	mov    %esi,%eax
  801240:	eb 1a                	jmp    80125c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801242:	88 18                	mov    %bl,(%eax)
  801244:	40                   	inc    %eax
  801245:	41                   	inc    %ecx
  801246:	eb 02                	jmp    80124a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801248:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80124a:	4a                   	dec    %edx
  80124b:	74 0a                	je     801257 <strlcpy+0x2b>
  80124d:	8a 19                	mov    (%ecx),%bl
  80124f:	84 db                	test   %bl,%bl
  801251:	75 ef                	jne    801242 <strlcpy+0x16>
  801253:	89 c2                	mov    %eax,%edx
  801255:	eb 02                	jmp    801259 <strlcpy+0x2d>
  801257:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  801259:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  80125c:	29 f0                	sub    %esi,%eax
}
  80125e:	5b                   	pop    %ebx
  80125f:	5e                   	pop    %esi
  801260:	5d                   	pop    %ebp
  801261:	c3                   	ret    

00801262 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801262:	55                   	push   %ebp
  801263:	89 e5                	mov    %esp,%ebp
  801265:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801268:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80126b:	eb 02                	jmp    80126f <strcmp+0xd>
		p++, q++;
  80126d:	41                   	inc    %ecx
  80126e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80126f:	8a 01                	mov    (%ecx),%al
  801271:	84 c0                	test   %al,%al
  801273:	74 04                	je     801279 <strcmp+0x17>
  801275:	3a 02                	cmp    (%edx),%al
  801277:	74 f4                	je     80126d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801279:	0f b6 c0             	movzbl %al,%eax
  80127c:	0f b6 12             	movzbl (%edx),%edx
  80127f:	29 d0                	sub    %edx,%eax
}
  801281:	5d                   	pop    %ebp
  801282:	c3                   	ret    

00801283 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801283:	55                   	push   %ebp
  801284:	89 e5                	mov    %esp,%ebp
  801286:	53                   	push   %ebx
  801287:	8b 45 08             	mov    0x8(%ebp),%eax
  80128a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80128d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  801290:	eb 03                	jmp    801295 <strncmp+0x12>
		n--, p++, q++;
  801292:	4a                   	dec    %edx
  801293:	40                   	inc    %eax
  801294:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801295:	85 d2                	test   %edx,%edx
  801297:	74 14                	je     8012ad <strncmp+0x2a>
  801299:	8a 18                	mov    (%eax),%bl
  80129b:	84 db                	test   %bl,%bl
  80129d:	74 04                	je     8012a3 <strncmp+0x20>
  80129f:	3a 19                	cmp    (%ecx),%bl
  8012a1:	74 ef                	je     801292 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8012a3:	0f b6 00             	movzbl (%eax),%eax
  8012a6:	0f b6 11             	movzbl (%ecx),%edx
  8012a9:	29 d0                	sub    %edx,%eax
  8012ab:	eb 05                	jmp    8012b2 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8012ad:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8012b2:	5b                   	pop    %ebx
  8012b3:	5d                   	pop    %ebp
  8012b4:	c3                   	ret    

008012b5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8012b5:	55                   	push   %ebp
  8012b6:	89 e5                	mov    %esp,%ebp
  8012b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8012bb:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8012be:	eb 05                	jmp    8012c5 <strchr+0x10>
		if (*s == c)
  8012c0:	38 ca                	cmp    %cl,%dl
  8012c2:	74 0c                	je     8012d0 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8012c4:	40                   	inc    %eax
  8012c5:	8a 10                	mov    (%eax),%dl
  8012c7:	84 d2                	test   %dl,%dl
  8012c9:	75 f5                	jne    8012c0 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8012cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012d0:	5d                   	pop    %ebp
  8012d1:	c3                   	ret    

008012d2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8012d2:	55                   	push   %ebp
  8012d3:	89 e5                	mov    %esp,%ebp
  8012d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8012d8:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8012db:	eb 05                	jmp    8012e2 <strfind+0x10>
		if (*s == c)
  8012dd:	38 ca                	cmp    %cl,%dl
  8012df:	74 07                	je     8012e8 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8012e1:	40                   	inc    %eax
  8012e2:	8a 10                	mov    (%eax),%dl
  8012e4:	84 d2                	test   %dl,%dl
  8012e6:	75 f5                	jne    8012dd <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8012e8:	5d                   	pop    %ebp
  8012e9:	c3                   	ret    

008012ea <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8012ea:	55                   	push   %ebp
  8012eb:	89 e5                	mov    %esp,%ebp
  8012ed:	57                   	push   %edi
  8012ee:	56                   	push   %esi
  8012ef:	53                   	push   %ebx
  8012f0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012f6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8012f9:	85 c9                	test   %ecx,%ecx
  8012fb:	74 30                	je     80132d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8012fd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801303:	75 25                	jne    80132a <memset+0x40>
  801305:	f6 c1 03             	test   $0x3,%cl
  801308:	75 20                	jne    80132a <memset+0x40>
		c &= 0xFF;
  80130a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80130d:	89 d3                	mov    %edx,%ebx
  80130f:	c1 e3 08             	shl    $0x8,%ebx
  801312:	89 d6                	mov    %edx,%esi
  801314:	c1 e6 18             	shl    $0x18,%esi
  801317:	89 d0                	mov    %edx,%eax
  801319:	c1 e0 10             	shl    $0x10,%eax
  80131c:	09 f0                	or     %esi,%eax
  80131e:	09 d0                	or     %edx,%eax
  801320:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801322:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801325:	fc                   	cld    
  801326:	f3 ab                	rep stos %eax,%es:(%edi)
  801328:	eb 03                	jmp    80132d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80132a:	fc                   	cld    
  80132b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80132d:	89 f8                	mov    %edi,%eax
  80132f:	5b                   	pop    %ebx
  801330:	5e                   	pop    %esi
  801331:	5f                   	pop    %edi
  801332:	5d                   	pop    %ebp
  801333:	c3                   	ret    

00801334 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801334:	55                   	push   %ebp
  801335:	89 e5                	mov    %esp,%ebp
  801337:	57                   	push   %edi
  801338:	56                   	push   %esi
  801339:	8b 45 08             	mov    0x8(%ebp),%eax
  80133c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80133f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801342:	39 c6                	cmp    %eax,%esi
  801344:	73 34                	jae    80137a <memmove+0x46>
  801346:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801349:	39 d0                	cmp    %edx,%eax
  80134b:	73 2d                	jae    80137a <memmove+0x46>
		s += n;
		d += n;
  80134d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801350:	f6 c2 03             	test   $0x3,%dl
  801353:	75 1b                	jne    801370 <memmove+0x3c>
  801355:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80135b:	75 13                	jne    801370 <memmove+0x3c>
  80135d:	f6 c1 03             	test   $0x3,%cl
  801360:	75 0e                	jne    801370 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801362:	83 ef 04             	sub    $0x4,%edi
  801365:	8d 72 fc             	lea    -0x4(%edx),%esi
  801368:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80136b:	fd                   	std    
  80136c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80136e:	eb 07                	jmp    801377 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801370:	4f                   	dec    %edi
  801371:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801374:	fd                   	std    
  801375:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801377:	fc                   	cld    
  801378:	eb 20                	jmp    80139a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80137a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801380:	75 13                	jne    801395 <memmove+0x61>
  801382:	a8 03                	test   $0x3,%al
  801384:	75 0f                	jne    801395 <memmove+0x61>
  801386:	f6 c1 03             	test   $0x3,%cl
  801389:	75 0a                	jne    801395 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80138b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80138e:	89 c7                	mov    %eax,%edi
  801390:	fc                   	cld    
  801391:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801393:	eb 05                	jmp    80139a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801395:	89 c7                	mov    %eax,%edi
  801397:	fc                   	cld    
  801398:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80139a:	5e                   	pop    %esi
  80139b:	5f                   	pop    %edi
  80139c:	5d                   	pop    %ebp
  80139d:	c3                   	ret    

0080139e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80139e:	55                   	push   %ebp
  80139f:	89 e5                	mov    %esp,%ebp
  8013a1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8013a4:	8b 45 10             	mov    0x10(%ebp),%eax
  8013a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b5:	89 04 24             	mov    %eax,(%esp)
  8013b8:	e8 77 ff ff ff       	call   801334 <memmove>
}
  8013bd:	c9                   	leave  
  8013be:	c3                   	ret    

008013bf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8013bf:	55                   	push   %ebp
  8013c0:	89 e5                	mov    %esp,%ebp
  8013c2:	57                   	push   %edi
  8013c3:	56                   	push   %esi
  8013c4:	53                   	push   %ebx
  8013c5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013c8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013cb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8013ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8013d3:	eb 16                	jmp    8013eb <memcmp+0x2c>
		if (*s1 != *s2)
  8013d5:	8a 04 17             	mov    (%edi,%edx,1),%al
  8013d8:	42                   	inc    %edx
  8013d9:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8013dd:	38 c8                	cmp    %cl,%al
  8013df:	74 0a                	je     8013eb <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8013e1:	0f b6 c0             	movzbl %al,%eax
  8013e4:	0f b6 c9             	movzbl %cl,%ecx
  8013e7:	29 c8                	sub    %ecx,%eax
  8013e9:	eb 09                	jmp    8013f4 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8013eb:	39 da                	cmp    %ebx,%edx
  8013ed:	75 e6                	jne    8013d5 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8013ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013f4:	5b                   	pop    %ebx
  8013f5:	5e                   	pop    %esi
  8013f6:	5f                   	pop    %edi
  8013f7:	5d                   	pop    %ebp
  8013f8:	c3                   	ret    

008013f9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8013f9:	55                   	push   %ebp
  8013fa:	89 e5                	mov    %esp,%ebp
  8013fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801402:	89 c2                	mov    %eax,%edx
  801404:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801407:	eb 05                	jmp    80140e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  801409:	38 08                	cmp    %cl,(%eax)
  80140b:	74 05                	je     801412 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80140d:	40                   	inc    %eax
  80140e:	39 d0                	cmp    %edx,%eax
  801410:	72 f7                	jb     801409 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801412:	5d                   	pop    %ebp
  801413:	c3                   	ret    

00801414 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801414:	55                   	push   %ebp
  801415:	89 e5                	mov    %esp,%ebp
  801417:	57                   	push   %edi
  801418:	56                   	push   %esi
  801419:	53                   	push   %ebx
  80141a:	8b 55 08             	mov    0x8(%ebp),%edx
  80141d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801420:	eb 01                	jmp    801423 <strtol+0xf>
		s++;
  801422:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801423:	8a 02                	mov    (%edx),%al
  801425:	3c 20                	cmp    $0x20,%al
  801427:	74 f9                	je     801422 <strtol+0xe>
  801429:	3c 09                	cmp    $0x9,%al
  80142b:	74 f5                	je     801422 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80142d:	3c 2b                	cmp    $0x2b,%al
  80142f:	75 08                	jne    801439 <strtol+0x25>
		s++;
  801431:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801432:	bf 00 00 00 00       	mov    $0x0,%edi
  801437:	eb 13                	jmp    80144c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801439:	3c 2d                	cmp    $0x2d,%al
  80143b:	75 0a                	jne    801447 <strtol+0x33>
		s++, neg = 1;
  80143d:	8d 52 01             	lea    0x1(%edx),%edx
  801440:	bf 01 00 00 00       	mov    $0x1,%edi
  801445:	eb 05                	jmp    80144c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801447:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80144c:	85 db                	test   %ebx,%ebx
  80144e:	74 05                	je     801455 <strtol+0x41>
  801450:	83 fb 10             	cmp    $0x10,%ebx
  801453:	75 28                	jne    80147d <strtol+0x69>
  801455:	8a 02                	mov    (%edx),%al
  801457:	3c 30                	cmp    $0x30,%al
  801459:	75 10                	jne    80146b <strtol+0x57>
  80145b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80145f:	75 0a                	jne    80146b <strtol+0x57>
		s += 2, base = 16;
  801461:	83 c2 02             	add    $0x2,%edx
  801464:	bb 10 00 00 00       	mov    $0x10,%ebx
  801469:	eb 12                	jmp    80147d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  80146b:	85 db                	test   %ebx,%ebx
  80146d:	75 0e                	jne    80147d <strtol+0x69>
  80146f:	3c 30                	cmp    $0x30,%al
  801471:	75 05                	jne    801478 <strtol+0x64>
		s++, base = 8;
  801473:	42                   	inc    %edx
  801474:	b3 08                	mov    $0x8,%bl
  801476:	eb 05                	jmp    80147d <strtol+0x69>
	else if (base == 0)
		base = 10;
  801478:	bb 0a 00 00 00       	mov    $0xa,%ebx
  80147d:	b8 00 00 00 00       	mov    $0x0,%eax
  801482:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801484:	8a 0a                	mov    (%edx),%cl
  801486:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801489:	80 fb 09             	cmp    $0x9,%bl
  80148c:	77 08                	ja     801496 <strtol+0x82>
			dig = *s - '0';
  80148e:	0f be c9             	movsbl %cl,%ecx
  801491:	83 e9 30             	sub    $0x30,%ecx
  801494:	eb 1e                	jmp    8014b4 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  801496:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801499:	80 fb 19             	cmp    $0x19,%bl
  80149c:	77 08                	ja     8014a6 <strtol+0x92>
			dig = *s - 'a' + 10;
  80149e:	0f be c9             	movsbl %cl,%ecx
  8014a1:	83 e9 57             	sub    $0x57,%ecx
  8014a4:	eb 0e                	jmp    8014b4 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  8014a6:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  8014a9:	80 fb 19             	cmp    $0x19,%bl
  8014ac:	77 12                	ja     8014c0 <strtol+0xac>
			dig = *s - 'A' + 10;
  8014ae:	0f be c9             	movsbl %cl,%ecx
  8014b1:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8014b4:	39 f1                	cmp    %esi,%ecx
  8014b6:	7d 0c                	jge    8014c4 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  8014b8:	42                   	inc    %edx
  8014b9:	0f af c6             	imul   %esi,%eax
  8014bc:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  8014be:	eb c4                	jmp    801484 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8014c0:	89 c1                	mov    %eax,%ecx
  8014c2:	eb 02                	jmp    8014c6 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8014c4:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8014c6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8014ca:	74 05                	je     8014d1 <strtol+0xbd>
		*endptr = (char *) s;
  8014cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014cf:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8014d1:	85 ff                	test   %edi,%edi
  8014d3:	74 04                	je     8014d9 <strtol+0xc5>
  8014d5:	89 c8                	mov    %ecx,%eax
  8014d7:	f7 d8                	neg    %eax
}
  8014d9:	5b                   	pop    %ebx
  8014da:	5e                   	pop    %esi
  8014db:	5f                   	pop    %edi
  8014dc:	5d                   	pop    %ebp
  8014dd:	c3                   	ret    
	...

008014e0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8014e0:	55                   	push   %ebp
  8014e1:	89 e5                	mov    %esp,%ebp
  8014e3:	57                   	push   %edi
  8014e4:	56                   	push   %esi
  8014e5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8014eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8014f1:	89 c3                	mov    %eax,%ebx
  8014f3:	89 c7                	mov    %eax,%edi
  8014f5:	89 c6                	mov    %eax,%esi
  8014f7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8014f9:	5b                   	pop    %ebx
  8014fa:	5e                   	pop    %esi
  8014fb:	5f                   	pop    %edi
  8014fc:	5d                   	pop    %ebp
  8014fd:	c3                   	ret    

008014fe <sys_cgetc>:

int
sys_cgetc(void)
{
  8014fe:	55                   	push   %ebp
  8014ff:	89 e5                	mov    %esp,%ebp
  801501:	57                   	push   %edi
  801502:	56                   	push   %esi
  801503:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801504:	ba 00 00 00 00       	mov    $0x0,%edx
  801509:	b8 01 00 00 00       	mov    $0x1,%eax
  80150e:	89 d1                	mov    %edx,%ecx
  801510:	89 d3                	mov    %edx,%ebx
  801512:	89 d7                	mov    %edx,%edi
  801514:	89 d6                	mov    %edx,%esi
  801516:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801518:	5b                   	pop    %ebx
  801519:	5e                   	pop    %esi
  80151a:	5f                   	pop    %edi
  80151b:	5d                   	pop    %ebp
  80151c:	c3                   	ret    

0080151d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80151d:	55                   	push   %ebp
  80151e:	89 e5                	mov    %esp,%ebp
  801520:	57                   	push   %edi
  801521:	56                   	push   %esi
  801522:	53                   	push   %ebx
  801523:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801526:	b9 00 00 00 00       	mov    $0x0,%ecx
  80152b:	b8 03 00 00 00       	mov    $0x3,%eax
  801530:	8b 55 08             	mov    0x8(%ebp),%edx
  801533:	89 cb                	mov    %ecx,%ebx
  801535:	89 cf                	mov    %ecx,%edi
  801537:	89 ce                	mov    %ecx,%esi
  801539:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80153b:	85 c0                	test   %eax,%eax
  80153d:	7e 28                	jle    801567 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80153f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801543:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80154a:	00 
  80154b:	c7 44 24 08 4f 3b 80 	movl   $0x803b4f,0x8(%esp)
  801552:	00 
  801553:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80155a:	00 
  80155b:	c7 04 24 6c 3b 80 00 	movl   $0x803b6c,(%esp)
  801562:	e8 d1 f4 ff ff       	call   800a38 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801567:	83 c4 2c             	add    $0x2c,%esp
  80156a:	5b                   	pop    %ebx
  80156b:	5e                   	pop    %esi
  80156c:	5f                   	pop    %edi
  80156d:	5d                   	pop    %ebp
  80156e:	c3                   	ret    

0080156f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80156f:	55                   	push   %ebp
  801570:	89 e5                	mov    %esp,%ebp
  801572:	57                   	push   %edi
  801573:	56                   	push   %esi
  801574:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801575:	ba 00 00 00 00       	mov    $0x0,%edx
  80157a:	b8 02 00 00 00       	mov    $0x2,%eax
  80157f:	89 d1                	mov    %edx,%ecx
  801581:	89 d3                	mov    %edx,%ebx
  801583:	89 d7                	mov    %edx,%edi
  801585:	89 d6                	mov    %edx,%esi
  801587:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801589:	5b                   	pop    %ebx
  80158a:	5e                   	pop    %esi
  80158b:	5f                   	pop    %edi
  80158c:	5d                   	pop    %ebp
  80158d:	c3                   	ret    

0080158e <sys_yield>:

void
sys_yield(void)
{
  80158e:	55                   	push   %ebp
  80158f:	89 e5                	mov    %esp,%ebp
  801591:	57                   	push   %edi
  801592:	56                   	push   %esi
  801593:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801594:	ba 00 00 00 00       	mov    $0x0,%edx
  801599:	b8 0b 00 00 00       	mov    $0xb,%eax
  80159e:	89 d1                	mov    %edx,%ecx
  8015a0:	89 d3                	mov    %edx,%ebx
  8015a2:	89 d7                	mov    %edx,%edi
  8015a4:	89 d6                	mov    %edx,%esi
  8015a6:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8015a8:	5b                   	pop    %ebx
  8015a9:	5e                   	pop    %esi
  8015aa:	5f                   	pop    %edi
  8015ab:	5d                   	pop    %ebp
  8015ac:	c3                   	ret    

008015ad <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8015ad:	55                   	push   %ebp
  8015ae:	89 e5                	mov    %esp,%ebp
  8015b0:	57                   	push   %edi
  8015b1:	56                   	push   %esi
  8015b2:	53                   	push   %ebx
  8015b3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015b6:	be 00 00 00 00       	mov    $0x0,%esi
  8015bb:	b8 04 00 00 00       	mov    $0x4,%eax
  8015c0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8015c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8015c9:	89 f7                	mov    %esi,%edi
  8015cb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8015cd:	85 c0                	test   %eax,%eax
  8015cf:	7e 28                	jle    8015f9 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8015d1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015d5:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8015dc:	00 
  8015dd:	c7 44 24 08 4f 3b 80 	movl   $0x803b4f,0x8(%esp)
  8015e4:	00 
  8015e5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8015ec:	00 
  8015ed:	c7 04 24 6c 3b 80 00 	movl   $0x803b6c,(%esp)
  8015f4:	e8 3f f4 ff ff       	call   800a38 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8015f9:	83 c4 2c             	add    $0x2c,%esp
  8015fc:	5b                   	pop    %ebx
  8015fd:	5e                   	pop    %esi
  8015fe:	5f                   	pop    %edi
  8015ff:	5d                   	pop    %ebp
  801600:	c3                   	ret    

00801601 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801601:	55                   	push   %ebp
  801602:	89 e5                	mov    %esp,%ebp
  801604:	57                   	push   %edi
  801605:	56                   	push   %esi
  801606:	53                   	push   %ebx
  801607:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80160a:	b8 05 00 00 00       	mov    $0x5,%eax
  80160f:	8b 75 18             	mov    0x18(%ebp),%esi
  801612:	8b 7d 14             	mov    0x14(%ebp),%edi
  801615:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801618:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80161b:	8b 55 08             	mov    0x8(%ebp),%edx
  80161e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801620:	85 c0                	test   %eax,%eax
  801622:	7e 28                	jle    80164c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801624:	89 44 24 10          	mov    %eax,0x10(%esp)
  801628:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80162f:	00 
  801630:	c7 44 24 08 4f 3b 80 	movl   $0x803b4f,0x8(%esp)
  801637:	00 
  801638:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80163f:	00 
  801640:	c7 04 24 6c 3b 80 00 	movl   $0x803b6c,(%esp)
  801647:	e8 ec f3 ff ff       	call   800a38 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80164c:	83 c4 2c             	add    $0x2c,%esp
  80164f:	5b                   	pop    %ebx
  801650:	5e                   	pop    %esi
  801651:	5f                   	pop    %edi
  801652:	5d                   	pop    %ebp
  801653:	c3                   	ret    

00801654 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801654:	55                   	push   %ebp
  801655:	89 e5                	mov    %esp,%ebp
  801657:	57                   	push   %edi
  801658:	56                   	push   %esi
  801659:	53                   	push   %ebx
  80165a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80165d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801662:	b8 06 00 00 00       	mov    $0x6,%eax
  801667:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80166a:	8b 55 08             	mov    0x8(%ebp),%edx
  80166d:	89 df                	mov    %ebx,%edi
  80166f:	89 de                	mov    %ebx,%esi
  801671:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801673:	85 c0                	test   %eax,%eax
  801675:	7e 28                	jle    80169f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801677:	89 44 24 10          	mov    %eax,0x10(%esp)
  80167b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801682:	00 
  801683:	c7 44 24 08 4f 3b 80 	movl   $0x803b4f,0x8(%esp)
  80168a:	00 
  80168b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801692:	00 
  801693:	c7 04 24 6c 3b 80 00 	movl   $0x803b6c,(%esp)
  80169a:	e8 99 f3 ff ff       	call   800a38 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80169f:	83 c4 2c             	add    $0x2c,%esp
  8016a2:	5b                   	pop    %ebx
  8016a3:	5e                   	pop    %esi
  8016a4:	5f                   	pop    %edi
  8016a5:	5d                   	pop    %ebp
  8016a6:	c3                   	ret    

008016a7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8016a7:	55                   	push   %ebp
  8016a8:	89 e5                	mov    %esp,%ebp
  8016aa:	57                   	push   %edi
  8016ab:	56                   	push   %esi
  8016ac:	53                   	push   %ebx
  8016ad:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8016b0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016b5:	b8 08 00 00 00       	mov    $0x8,%eax
  8016ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8016c0:	89 df                	mov    %ebx,%edi
  8016c2:	89 de                	mov    %ebx,%esi
  8016c4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8016c6:	85 c0                	test   %eax,%eax
  8016c8:	7e 28                	jle    8016f2 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016ca:	89 44 24 10          	mov    %eax,0x10(%esp)
  8016ce:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8016d5:	00 
  8016d6:	c7 44 24 08 4f 3b 80 	movl   $0x803b4f,0x8(%esp)
  8016dd:	00 
  8016de:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8016e5:	00 
  8016e6:	c7 04 24 6c 3b 80 00 	movl   $0x803b6c,(%esp)
  8016ed:	e8 46 f3 ff ff       	call   800a38 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8016f2:	83 c4 2c             	add    $0x2c,%esp
  8016f5:	5b                   	pop    %ebx
  8016f6:	5e                   	pop    %esi
  8016f7:	5f                   	pop    %edi
  8016f8:	5d                   	pop    %ebp
  8016f9:	c3                   	ret    

008016fa <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8016fa:	55                   	push   %ebp
  8016fb:	89 e5                	mov    %esp,%ebp
  8016fd:	57                   	push   %edi
  8016fe:	56                   	push   %esi
  8016ff:	53                   	push   %ebx
  801700:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801703:	bb 00 00 00 00       	mov    $0x0,%ebx
  801708:	b8 09 00 00 00       	mov    $0x9,%eax
  80170d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801710:	8b 55 08             	mov    0x8(%ebp),%edx
  801713:	89 df                	mov    %ebx,%edi
  801715:	89 de                	mov    %ebx,%esi
  801717:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801719:	85 c0                	test   %eax,%eax
  80171b:	7e 28                	jle    801745 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80171d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801721:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801728:	00 
  801729:	c7 44 24 08 4f 3b 80 	movl   $0x803b4f,0x8(%esp)
  801730:	00 
  801731:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801738:	00 
  801739:	c7 04 24 6c 3b 80 00 	movl   $0x803b6c,(%esp)
  801740:	e8 f3 f2 ff ff       	call   800a38 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801745:	83 c4 2c             	add    $0x2c,%esp
  801748:	5b                   	pop    %ebx
  801749:	5e                   	pop    %esi
  80174a:	5f                   	pop    %edi
  80174b:	5d                   	pop    %ebp
  80174c:	c3                   	ret    

0080174d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80174d:	55                   	push   %ebp
  80174e:	89 e5                	mov    %esp,%ebp
  801750:	57                   	push   %edi
  801751:	56                   	push   %esi
  801752:	53                   	push   %ebx
  801753:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801756:	bb 00 00 00 00       	mov    $0x0,%ebx
  80175b:	b8 0a 00 00 00       	mov    $0xa,%eax
  801760:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801763:	8b 55 08             	mov    0x8(%ebp),%edx
  801766:	89 df                	mov    %ebx,%edi
  801768:	89 de                	mov    %ebx,%esi
  80176a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80176c:	85 c0                	test   %eax,%eax
  80176e:	7e 28                	jle    801798 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801770:	89 44 24 10          	mov    %eax,0x10(%esp)
  801774:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80177b:	00 
  80177c:	c7 44 24 08 4f 3b 80 	movl   $0x803b4f,0x8(%esp)
  801783:	00 
  801784:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80178b:	00 
  80178c:	c7 04 24 6c 3b 80 00 	movl   $0x803b6c,(%esp)
  801793:	e8 a0 f2 ff ff       	call   800a38 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801798:	83 c4 2c             	add    $0x2c,%esp
  80179b:	5b                   	pop    %ebx
  80179c:	5e                   	pop    %esi
  80179d:	5f                   	pop    %edi
  80179e:	5d                   	pop    %ebp
  80179f:	c3                   	ret    

008017a0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8017a0:	55                   	push   %ebp
  8017a1:	89 e5                	mov    %esp,%ebp
  8017a3:	57                   	push   %edi
  8017a4:	56                   	push   %esi
  8017a5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8017a6:	be 00 00 00 00       	mov    $0x0,%esi
  8017ab:	b8 0c 00 00 00       	mov    $0xc,%eax
  8017b0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8017b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8017b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8017bc:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8017be:	5b                   	pop    %ebx
  8017bf:	5e                   	pop    %esi
  8017c0:	5f                   	pop    %edi
  8017c1:	5d                   	pop    %ebp
  8017c2:	c3                   	ret    

008017c3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8017c3:	55                   	push   %ebp
  8017c4:	89 e5                	mov    %esp,%ebp
  8017c6:	57                   	push   %edi
  8017c7:	56                   	push   %esi
  8017c8:	53                   	push   %ebx
  8017c9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8017cc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8017d1:	b8 0d 00 00 00       	mov    $0xd,%eax
  8017d6:	8b 55 08             	mov    0x8(%ebp),%edx
  8017d9:	89 cb                	mov    %ecx,%ebx
  8017db:	89 cf                	mov    %ecx,%edi
  8017dd:	89 ce                	mov    %ecx,%esi
  8017df:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8017e1:	85 c0                	test   %eax,%eax
  8017e3:	7e 28                	jle    80180d <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8017e5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8017e9:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8017f0:	00 
  8017f1:	c7 44 24 08 4f 3b 80 	movl   $0x803b4f,0x8(%esp)
  8017f8:	00 
  8017f9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801800:	00 
  801801:	c7 04 24 6c 3b 80 00 	movl   $0x803b6c,(%esp)
  801808:	e8 2b f2 ff ff       	call   800a38 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80180d:	83 c4 2c             	add    $0x2c,%esp
  801810:	5b                   	pop    %ebx
  801811:	5e                   	pop    %esi
  801812:	5f                   	pop    %edi
  801813:	5d                   	pop    %ebp
  801814:	c3                   	ret    
  801815:	00 00                	add    %al,(%eax)
	...

00801818 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801818:	55                   	push   %ebp
  801819:	89 e5                	mov    %esp,%ebp
  80181b:	53                   	push   %ebx
  80181c:	83 ec 24             	sub    $0x24,%esp
  80181f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801822:	8b 18                	mov    (%eax),%ebx
	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	if ((err & FEC_WR) == 0)
  801824:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801828:	75 20                	jne    80184a <pgfault+0x32>
		panic("pgfault: faulting address [%08x] not a write\n", addr);
  80182a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80182e:	c7 44 24 08 7c 3b 80 	movl   $0x803b7c,0x8(%esp)
  801835:	00 
  801836:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  80183d:	00 
  80183e:	c7 04 24 fc 3b 80 00 	movl   $0x803bfc,(%esp)
  801845:	e8 ee f1 ff ff       	call   800a38 <_panic>

	void *page_aligned_addr = (void *) ROUNDDOWN(addr, PGSIZE);
  80184a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t page_num = (uint32_t) page_aligned_addr / PGSIZE;
  801850:	89 d8                	mov    %ebx,%eax
  801852:	c1 e8 0c             	shr    $0xc,%eax
	if (!(uvpt[page_num] & PTE_COW))
  801855:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80185c:	f6 c4 08             	test   $0x8,%ah
  80185f:	75 1c                	jne    80187d <pgfault+0x65>
		panic("pgfault: fault was not on a copy-on-write page\n");
  801861:	c7 44 24 08 ac 3b 80 	movl   $0x803bac,0x8(%esp)
  801868:	00 
  801869:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801870:	00 
  801871:	c7 04 24 fc 3b 80 00 	movl   $0x803bfc,(%esp)
  801878:	e8 bb f1 ff ff       	call   800a38 <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.

	// Allocate
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  80187d:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801884:	00 
  801885:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80188c:	00 
  80188d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801894:	e8 14 fd ff ff       	call   8015ad <sys_page_alloc>
  801899:	85 c0                	test   %eax,%eax
  80189b:	79 20                	jns    8018bd <pgfault+0xa5>
		panic("sys_page_alloc: %e\n", r);
  80189d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018a1:	c7 44 24 08 07 3c 80 	movl   $0x803c07,0x8(%esp)
  8018a8:	00 
  8018a9:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  8018b0:	00 
  8018b1:	c7 04 24 fc 3b 80 00 	movl   $0x803bfc,(%esp)
  8018b8:	e8 7b f1 ff ff       	call   800a38 <_panic>

	// Copy over
	void *src_addr = (void *) ROUNDDOWN(addr, PGSIZE);
	memmove(PFTEMP, src_addr, PGSIZE);
  8018bd:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8018c4:	00 
  8018c5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018c9:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8018d0:	e8 5f fa ff ff       	call   801334 <memmove>

	// Remap
	if ((r = sys_page_map(0, PFTEMP, 0, src_addr, PTE_P | PTE_U | PTE_W)) < 0)
  8018d5:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8018dc:	00 
  8018dd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8018e1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8018e8:	00 
  8018e9:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8018f0:	00 
  8018f1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018f8:	e8 04 fd ff ff       	call   801601 <sys_page_map>
  8018fd:	85 c0                	test   %eax,%eax
  8018ff:	79 20                	jns    801921 <pgfault+0x109>
		panic("sys_page_map: %e\n", r);
  801901:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801905:	c7 44 24 08 1b 3c 80 	movl   $0x803c1b,0x8(%esp)
  80190c:	00 
  80190d:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  801914:	00 
  801915:	c7 04 24 fc 3b 80 00 	movl   $0x803bfc,(%esp)
  80191c:	e8 17 f1 ff ff       	call   800a38 <_panic>

}
  801921:	83 c4 24             	add    $0x24,%esp
  801924:	5b                   	pop    %ebx
  801925:	5d                   	pop    %ebp
  801926:	c3                   	ret    

00801927 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801927:	55                   	push   %ebp
  801928:	89 e5                	mov    %esp,%ebp
  80192a:	57                   	push   %edi
  80192b:	56                   	push   %esi
  80192c:	53                   	push   %ebx
  80192d:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	int r;
	envid_t child_envid;

	set_pgfault_handler(pgfault);
  801930:	c7 04 24 18 18 80 00 	movl   $0x801818,(%esp)
  801937:	e8 60 18 00 00       	call   80319c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80193c:	ba 07 00 00 00       	mov    $0x7,%edx
  801941:	89 d0                	mov    %edx,%eax
  801943:	cd 30                	int    $0x30
  801945:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801948:	89 45 e0             	mov    %eax,-0x20(%ebp)

	child_envid = sys_exofork();
	if (child_envid < 0)
  80194b:	85 c0                	test   %eax,%eax
  80194d:	79 20                	jns    80196f <fork+0x48>
		panic("sys_exofork: %e\n", child_envid);
  80194f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801953:	c7 44 24 08 2d 3c 80 	movl   $0x803c2d,0x8(%esp)
  80195a:	00 
  80195b:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  801962:	00 
  801963:	c7 04 24 fc 3b 80 00 	movl   $0x803bfc,(%esp)
  80196a:	e8 c9 f0 ff ff       	call   800a38 <_panic>
	if (child_envid == 0) { // child
  80196f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801973:	75 25                	jne    80199a <fork+0x73>
		// Fix thisenv like dumbfork does and return 0
		thisenv = &envs[ENVX(sys_getenvid())];
  801975:	e8 f5 fb ff ff       	call   80156f <sys_getenvid>
  80197a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80197f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801986:	c1 e0 07             	shl    $0x7,%eax
  801989:	29 d0                	sub    %edx,%eax
  80198b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801990:	a3 24 54 80 00       	mov    %eax,0x805424
		return 0;
  801995:	e9 58 02 00 00       	jmp    801bf2 <fork+0x2cb>
	set_pgfault_handler(pgfault);

	child_envid = sys_exofork();
	if (child_envid < 0)
		panic("sys_exofork: %e\n", child_envid);
	if (child_envid == 0) { // child
  80199a:	bf 00 00 00 00       	mov    $0x0,%edi
  80199f:	be 00 00 00 00       	mov    $0x0,%esi
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
  8019a4:	89 f0                	mov    %esi,%eax
  8019a6:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  8019a9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8019b0:	a8 01                	test   $0x1,%al
  8019b2:	0f 84 7a 01 00 00    	je     801b32 <fork+0x20b>
			((uvpt[page_num] & PTE_P) == PTE_P)) {
  8019b8:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  8019bf:	a8 01                	test   $0x1,%al
  8019c1:	0f 84 6b 01 00 00    	je     801b32 <fork+0x20b>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	envid_t this_envid = thisenv->env_id;
  8019c7:	a1 24 54 80 00       	mov    0x805424,%eax
  8019cc:	8b 40 48             	mov    0x48(%eax),%eax
  8019cf:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	if (uvpt[pn] & PTE_SHARE) {
  8019d2:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8019d9:	f6 c4 04             	test   $0x4,%ah
  8019dc:	74 52                	je     801a30 <fork+0x109>
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  8019de:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8019e5:	25 07 0e 00 00       	and    $0xe07,%eax
  8019ea:	89 44 24 10          	mov    %eax,0x10(%esp)
  8019ee:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8019f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8019f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019f9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8019fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a00:	89 04 24             	mov    %eax,(%esp)
  801a03:	e8 f9 fb ff ff       	call   801601 <sys_page_map>
  801a08:	85 c0                	test   %eax,%eax
  801a0a:	0f 89 22 01 00 00    	jns    801b32 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  801a10:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a14:	c7 44 24 08 1b 3c 80 	movl   $0x803c1b,0x8(%esp)
  801a1b:	00 
  801a1c:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  801a23:	00 
  801a24:	c7 04 24 fc 3b 80 00 	movl   $0x803bfc,(%esp)
  801a2b:	e8 08 f0 ff ff       	call   800a38 <_panic>
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
  801a30:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801a37:	f6 c4 08             	test   $0x8,%ah
  801a3a:	75 0f                	jne    801a4b <fork+0x124>
  801a3c:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801a43:	a8 02                	test   $0x2,%al
  801a45:	0f 84 99 00 00 00    	je     801ae4 <fork+0x1bd>
		if (uvpt[pn] & PTE_U)
  801a4b:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801a52:	83 e0 04             	and    $0x4,%eax
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
  801a55:	83 f8 01             	cmp    $0x1,%eax
  801a58:	19 db                	sbb    %ebx,%ebx
  801a5a:	83 e3 fc             	and    $0xfffffffc,%ebx
  801a5d:	81 c3 05 08 00 00    	add    $0x805,%ebx
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
		if (uvpt[pn] & PTE_U)
			perm |= PTE_U;

		// Map page COW, U and P in child
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), perm)) < 0)
  801a63:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801a67:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801a6b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a6e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a72:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801a76:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a79:	89 04 24             	mov    %eax,(%esp)
  801a7c:	e8 80 fb ff ff       	call   801601 <sys_page_map>
  801a81:	85 c0                	test   %eax,%eax
  801a83:	79 20                	jns    801aa5 <fork+0x17e>
			panic("sys_page_map: %e\n", r);
  801a85:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a89:	c7 44 24 08 1b 3c 80 	movl   $0x803c1b,0x8(%esp)
  801a90:	00 
  801a91:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  801a98:	00 
  801a99:	c7 04 24 fc 3b 80 00 	movl   $0x803bfc,(%esp)
  801aa0:	e8 93 ef ff ff       	call   800a38 <_panic>

		// Map page COW, U and P in parent
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), this_envid, (void *) (pn*PGSIZE), perm)) < 0)
  801aa5:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801aa9:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801aad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ab0:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ab4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801ab8:	89 04 24             	mov    %eax,(%esp)
  801abb:	e8 41 fb ff ff       	call   801601 <sys_page_map>
  801ac0:	85 c0                	test   %eax,%eax
  801ac2:	79 6e                	jns    801b32 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  801ac4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ac8:	c7 44 24 08 1b 3c 80 	movl   $0x803c1b,0x8(%esp)
  801acf:	00 
  801ad0:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  801ad7:	00 
  801ad8:	c7 04 24 fc 3b 80 00 	movl   $0x803bfc,(%esp)
  801adf:	e8 54 ef ff ff       	call   800a38 <_panic>

	} else { // map pages that are present but not writable or COW with their original permissions
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  801ae4:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801aeb:	25 07 0e 00 00       	and    $0xe07,%eax
  801af0:	89 44 24 10          	mov    %eax,0x10(%esp)
  801af4:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801af8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801afb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801aff:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801b03:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b06:	89 04 24             	mov    %eax,(%esp)
  801b09:	e8 f3 fa ff ff       	call   801601 <sys_page_map>
  801b0e:	85 c0                	test   %eax,%eax
  801b10:	79 20                	jns    801b32 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  801b12:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b16:	c7 44 24 08 1b 3c 80 	movl   $0x803c1b,0x8(%esp)
  801b1d:	00 
  801b1e:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  801b25:	00 
  801b26:	c7 04 24 fc 3b 80 00 	movl   $0x803bfc,(%esp)
  801b2d:	e8 06 ef ff ff       	call   800a38 <_panic>
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
  801b32:	46                   	inc    %esi
  801b33:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801b39:	81 fe ff eb 0e 00    	cmp    $0xeebff,%esi
  801b3f:	0f 85 5f fe ff ff    	jne    8019a4 <fork+0x7d>
	}

	// Allocate exception stack space for child. The child can't do this themselves
	// because the mechanism by which it would is to run the pgfault handler, which
	// needs to run on the exception stack (catch 22).
	if ((r = sys_page_alloc(child_envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801b45:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801b4c:	00 
  801b4d:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801b54:	ee 
  801b55:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801b58:	89 04 24             	mov    %eax,(%esp)
  801b5b:	e8 4d fa ff ff       	call   8015ad <sys_page_alloc>
  801b60:	85 c0                	test   %eax,%eax
  801b62:	79 20                	jns    801b84 <fork+0x25d>
		panic("sys_page_alloc: %e\n", r);
  801b64:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b68:	c7 44 24 08 07 3c 80 	movl   $0x803c07,0x8(%esp)
  801b6f:	00 
  801b70:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  801b77:	00 
  801b78:	c7 04 24 fc 3b 80 00 	movl   $0x803bfc,(%esp)
  801b7f:	e8 b4 ee ff ff       	call   800a38 <_panic>

	// Set page fault handler for the child
	if ((r = sys_env_set_pgfault_upcall(child_envid, _pgfault_upcall)) < 0)
  801b84:	c7 44 24 04 10 32 80 	movl   $0x803210,0x4(%esp)
  801b8b:	00 
  801b8c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801b8f:	89 04 24             	mov    %eax,(%esp)
  801b92:	e8 b6 fb ff ff       	call   80174d <sys_env_set_pgfault_upcall>
  801b97:	85 c0                	test   %eax,%eax
  801b99:	79 20                	jns    801bbb <fork+0x294>
		panic("sys_env_set_pgfault_upcall: %e\n", r);
  801b9b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b9f:	c7 44 24 08 dc 3b 80 	movl   $0x803bdc,0x8(%esp)
  801ba6:	00 
  801ba7:	c7 44 24 04 a1 00 00 	movl   $0xa1,0x4(%esp)
  801bae:	00 
  801baf:	c7 04 24 fc 3b 80 00 	movl   $0x803bfc,(%esp)
  801bb6:	e8 7d ee ff ff       	call   800a38 <_panic>

	// Mark child environment as runnable
	if ((r = sys_env_set_status(child_envid, ENV_RUNNABLE)) < 0)
  801bbb:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801bc2:	00 
  801bc3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801bc6:	89 04 24             	mov    %eax,(%esp)
  801bc9:	e8 d9 fa ff ff       	call   8016a7 <sys_env_set_status>
  801bce:	85 c0                	test   %eax,%eax
  801bd0:	79 20                	jns    801bf2 <fork+0x2cb>
		panic("sys_env_set_status: %e\n", r);
  801bd2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bd6:	c7 44 24 08 3e 3c 80 	movl   $0x803c3e,0x8(%esp)
  801bdd:	00 
  801bde:	c7 44 24 04 a5 00 00 	movl   $0xa5,0x4(%esp)
  801be5:	00 
  801be6:	c7 04 24 fc 3b 80 00 	movl   $0x803bfc,(%esp)
  801bed:	e8 46 ee ff ff       	call   800a38 <_panic>

	return child_envid;
}
  801bf2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801bf5:	83 c4 3c             	add    $0x3c,%esp
  801bf8:	5b                   	pop    %ebx
  801bf9:	5e                   	pop    %esi
  801bfa:	5f                   	pop    %edi
  801bfb:	5d                   	pop    %ebp
  801bfc:	c3                   	ret    

00801bfd <sfork>:

// Challenge!
int
sfork(void)
{
  801bfd:	55                   	push   %ebp
  801bfe:	89 e5                	mov    %esp,%ebp
  801c00:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801c03:	c7 44 24 08 56 3c 80 	movl   $0x803c56,0x8(%esp)
  801c0a:	00 
  801c0b:	c7 44 24 04 ae 00 00 	movl   $0xae,0x4(%esp)
  801c12:	00 
  801c13:	c7 04 24 fc 3b 80 00 	movl   $0x803bfc,(%esp)
  801c1a:	e8 19 ee ff ff       	call   800a38 <_panic>
	...

00801c20 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801c20:	55                   	push   %ebp
  801c21:	89 e5                	mov    %esp,%ebp
  801c23:	8b 55 08             	mov    0x8(%ebp),%edx
  801c26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c29:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801c2c:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801c2e:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801c31:	83 3a 01             	cmpl   $0x1,(%edx)
  801c34:	7e 0b                	jle    801c41 <argstart+0x21>
  801c36:	85 c9                	test   %ecx,%ecx
  801c38:	75 0e                	jne    801c48 <argstart+0x28>
  801c3a:	ba 00 00 00 00       	mov    $0x0,%edx
  801c3f:	eb 0c                	jmp    801c4d <argstart+0x2d>
  801c41:	ba 00 00 00 00       	mov    $0x0,%edx
  801c46:	eb 05                	jmp    801c4d <argstart+0x2d>
  801c48:	ba 21 36 80 00       	mov    $0x803621,%edx
  801c4d:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801c50:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801c57:	5d                   	pop    %ebp
  801c58:	c3                   	ret    

00801c59 <argnext>:

int
argnext(struct Argstate *args)
{
  801c59:	55                   	push   %ebp
  801c5a:	89 e5                	mov    %esp,%ebp
  801c5c:	53                   	push   %ebx
  801c5d:	83 ec 14             	sub    $0x14,%esp
  801c60:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801c63:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801c6a:	8b 43 08             	mov    0x8(%ebx),%eax
  801c6d:	85 c0                	test   %eax,%eax
  801c6f:	74 6c                	je     801cdd <argnext+0x84>
		return -1;

	if (!*args->curarg) {
  801c71:	80 38 00             	cmpb   $0x0,(%eax)
  801c74:	75 4d                	jne    801cc3 <argnext+0x6a>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801c76:	8b 0b                	mov    (%ebx),%ecx
  801c78:	83 39 01             	cmpl   $0x1,(%ecx)
  801c7b:	74 52                	je     801ccf <argnext+0x76>
		    || args->argv[1][0] != '-'
  801c7d:	8b 53 04             	mov    0x4(%ebx),%edx
  801c80:	8b 42 04             	mov    0x4(%edx),%eax
  801c83:	80 38 2d             	cmpb   $0x2d,(%eax)
  801c86:	75 47                	jne    801ccf <argnext+0x76>
		    || args->argv[1][1] == '\0')
  801c88:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801c8c:	74 41                	je     801ccf <argnext+0x76>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801c8e:	40                   	inc    %eax
  801c8f:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801c92:	8b 01                	mov    (%ecx),%eax
  801c94:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801c9b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c9f:	8d 42 08             	lea    0x8(%edx),%eax
  801ca2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ca6:	83 c2 04             	add    $0x4,%edx
  801ca9:	89 14 24             	mov    %edx,(%esp)
  801cac:	e8 83 f6 ff ff       	call   801334 <memmove>
		(*args->argc)--;
  801cb1:	8b 03                	mov    (%ebx),%eax
  801cb3:	ff 08                	decl   (%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801cb5:	8b 43 08             	mov    0x8(%ebx),%eax
  801cb8:	80 38 2d             	cmpb   $0x2d,(%eax)
  801cbb:	75 06                	jne    801cc3 <argnext+0x6a>
  801cbd:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801cc1:	74 0c                	je     801ccf <argnext+0x76>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801cc3:	8b 53 08             	mov    0x8(%ebx),%edx
  801cc6:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801cc9:	42                   	inc    %edx
  801cca:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801ccd:	eb 13                	jmp    801ce2 <argnext+0x89>

    endofargs:
	args->curarg = 0;
  801ccf:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801cd6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801cdb:	eb 05                	jmp    801ce2 <argnext+0x89>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  801cdd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801ce2:	83 c4 14             	add    $0x14,%esp
  801ce5:	5b                   	pop    %ebx
  801ce6:	5d                   	pop    %ebp
  801ce7:	c3                   	ret    

00801ce8 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801ce8:	55                   	push   %ebp
  801ce9:	89 e5                	mov    %esp,%ebp
  801ceb:	53                   	push   %ebx
  801cec:	83 ec 14             	sub    $0x14,%esp
  801cef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801cf2:	8b 43 08             	mov    0x8(%ebx),%eax
  801cf5:	85 c0                	test   %eax,%eax
  801cf7:	74 59                	je     801d52 <argnextvalue+0x6a>
		return 0;
	if (*args->curarg) {
  801cf9:	80 38 00             	cmpb   $0x0,(%eax)
  801cfc:	74 0c                	je     801d0a <argnextvalue+0x22>
		args->argvalue = args->curarg;
  801cfe:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801d01:	c7 43 08 21 36 80 00 	movl   $0x803621,0x8(%ebx)
  801d08:	eb 43                	jmp    801d4d <argnextvalue+0x65>
	} else if (*args->argc > 1) {
  801d0a:	8b 03                	mov    (%ebx),%eax
  801d0c:	83 38 01             	cmpl   $0x1,(%eax)
  801d0f:	7e 2e                	jle    801d3f <argnextvalue+0x57>
		args->argvalue = args->argv[1];
  801d11:	8b 53 04             	mov    0x4(%ebx),%edx
  801d14:	8b 4a 04             	mov    0x4(%edx),%ecx
  801d17:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801d1a:	8b 00                	mov    (%eax),%eax
  801d1c:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801d23:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d27:	8d 42 08             	lea    0x8(%edx),%eax
  801d2a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d2e:	83 c2 04             	add    $0x4,%edx
  801d31:	89 14 24             	mov    %edx,(%esp)
  801d34:	e8 fb f5 ff ff       	call   801334 <memmove>
		(*args->argc)--;
  801d39:	8b 03                	mov    (%ebx),%eax
  801d3b:	ff 08                	decl   (%eax)
  801d3d:	eb 0e                	jmp    801d4d <argnextvalue+0x65>
	} else {
		args->argvalue = 0;
  801d3f:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801d46:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  801d4d:	8b 43 0c             	mov    0xc(%ebx),%eax
  801d50:	eb 05                	jmp    801d57 <argnextvalue+0x6f>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  801d52:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  801d57:	83 c4 14             	add    $0x14,%esp
  801d5a:	5b                   	pop    %ebx
  801d5b:	5d                   	pop    %ebp
  801d5c:	c3                   	ret    

00801d5d <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  801d5d:	55                   	push   %ebp
  801d5e:	89 e5                	mov    %esp,%ebp
  801d60:	83 ec 18             	sub    $0x18,%esp
  801d63:	8b 55 08             	mov    0x8(%ebp),%edx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801d66:	8b 42 0c             	mov    0xc(%edx),%eax
  801d69:	85 c0                	test   %eax,%eax
  801d6b:	75 08                	jne    801d75 <argvalue+0x18>
  801d6d:	89 14 24             	mov    %edx,(%esp)
  801d70:	e8 73 ff ff ff       	call   801ce8 <argnextvalue>
}
  801d75:	c9                   	leave  
  801d76:	c3                   	ret    
	...

00801d78 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801d78:	55                   	push   %ebp
  801d79:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801d7b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7e:	05 00 00 00 30       	add    $0x30000000,%eax
  801d83:	c1 e8 0c             	shr    $0xc,%eax
}
  801d86:	5d                   	pop    %ebp
  801d87:	c3                   	ret    

00801d88 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801d88:	55                   	push   %ebp
  801d89:	89 e5                	mov    %esp,%ebp
  801d8b:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801d8e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d91:	89 04 24             	mov    %eax,(%esp)
  801d94:	e8 df ff ff ff       	call   801d78 <fd2num>
  801d99:	05 20 00 0d 00       	add    $0xd0020,%eax
  801d9e:	c1 e0 0c             	shl    $0xc,%eax
}
  801da1:	c9                   	leave  
  801da2:	c3                   	ret    

00801da3 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801da3:	55                   	push   %ebp
  801da4:	89 e5                	mov    %esp,%ebp
  801da6:	53                   	push   %ebx
  801da7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801daa:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801daf:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801db1:	89 c2                	mov    %eax,%edx
  801db3:	c1 ea 16             	shr    $0x16,%edx
  801db6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801dbd:	f6 c2 01             	test   $0x1,%dl
  801dc0:	74 11                	je     801dd3 <fd_alloc+0x30>
  801dc2:	89 c2                	mov    %eax,%edx
  801dc4:	c1 ea 0c             	shr    $0xc,%edx
  801dc7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801dce:	f6 c2 01             	test   $0x1,%dl
  801dd1:	75 09                	jne    801ddc <fd_alloc+0x39>
			*fd_store = fd;
  801dd3:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801dd5:	b8 00 00 00 00       	mov    $0x0,%eax
  801dda:	eb 17                	jmp    801df3 <fd_alloc+0x50>
  801ddc:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801de1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801de6:	75 c7                	jne    801daf <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801de8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801dee:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801df3:	5b                   	pop    %ebx
  801df4:	5d                   	pop    %ebp
  801df5:	c3                   	ret    

00801df6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801df6:	55                   	push   %ebp
  801df7:	89 e5                	mov    %esp,%ebp
  801df9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801dfc:	83 f8 1f             	cmp    $0x1f,%eax
  801dff:	77 36                	ja     801e37 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801e01:	05 00 00 0d 00       	add    $0xd0000,%eax
  801e06:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801e09:	89 c2                	mov    %eax,%edx
  801e0b:	c1 ea 16             	shr    $0x16,%edx
  801e0e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801e15:	f6 c2 01             	test   $0x1,%dl
  801e18:	74 24                	je     801e3e <fd_lookup+0x48>
  801e1a:	89 c2                	mov    %eax,%edx
  801e1c:	c1 ea 0c             	shr    $0xc,%edx
  801e1f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801e26:	f6 c2 01             	test   $0x1,%dl
  801e29:	74 1a                	je     801e45 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801e2b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e2e:	89 02                	mov    %eax,(%edx)
	return 0;
  801e30:	b8 00 00 00 00       	mov    $0x0,%eax
  801e35:	eb 13                	jmp    801e4a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801e37:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801e3c:	eb 0c                	jmp    801e4a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801e3e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801e43:	eb 05                	jmp    801e4a <fd_lookup+0x54>
  801e45:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801e4a:	5d                   	pop    %ebp
  801e4b:	c3                   	ret    

00801e4c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801e4c:	55                   	push   %ebp
  801e4d:	89 e5                	mov    %esp,%ebp
  801e4f:	53                   	push   %ebx
  801e50:	83 ec 14             	sub    $0x14,%esp
  801e53:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e56:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801e59:	ba 00 00 00 00       	mov    $0x0,%edx
  801e5e:	eb 0e                	jmp    801e6e <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801e60:	39 08                	cmp    %ecx,(%eax)
  801e62:	75 09                	jne    801e6d <dev_lookup+0x21>
			*dev = devtab[i];
  801e64:	89 03                	mov    %eax,(%ebx)
			return 0;
  801e66:	b8 00 00 00 00       	mov    $0x0,%eax
  801e6b:	eb 33                	jmp    801ea0 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801e6d:	42                   	inc    %edx
  801e6e:	8b 04 95 e8 3c 80 00 	mov    0x803ce8(,%edx,4),%eax
  801e75:	85 c0                	test   %eax,%eax
  801e77:	75 e7                	jne    801e60 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801e79:	a1 24 54 80 00       	mov    0x805424,%eax
  801e7e:	8b 40 48             	mov    0x48(%eax),%eax
  801e81:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e85:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e89:	c7 04 24 6c 3c 80 00 	movl   $0x803c6c,(%esp)
  801e90:	e8 9b ec ff ff       	call   800b30 <cprintf>
	*dev = 0;
  801e95:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801e9b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801ea0:	83 c4 14             	add    $0x14,%esp
  801ea3:	5b                   	pop    %ebx
  801ea4:	5d                   	pop    %ebp
  801ea5:	c3                   	ret    

00801ea6 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801ea6:	55                   	push   %ebp
  801ea7:	89 e5                	mov    %esp,%ebp
  801ea9:	56                   	push   %esi
  801eaa:	53                   	push   %ebx
  801eab:	83 ec 30             	sub    $0x30,%esp
  801eae:	8b 75 08             	mov    0x8(%ebp),%esi
  801eb1:	8a 45 0c             	mov    0xc(%ebp),%al
  801eb4:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801eb7:	89 34 24             	mov    %esi,(%esp)
  801eba:	e8 b9 fe ff ff       	call   801d78 <fd2num>
  801ebf:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801ec2:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ec6:	89 04 24             	mov    %eax,(%esp)
  801ec9:	e8 28 ff ff ff       	call   801df6 <fd_lookup>
  801ece:	89 c3                	mov    %eax,%ebx
  801ed0:	85 c0                	test   %eax,%eax
  801ed2:	78 05                	js     801ed9 <fd_close+0x33>
	    || fd != fd2)
  801ed4:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801ed7:	74 0d                	je     801ee6 <fd_close+0x40>
		return (must_exist ? r : 0);
  801ed9:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801edd:	75 46                	jne    801f25 <fd_close+0x7f>
  801edf:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ee4:	eb 3f                	jmp    801f25 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801ee6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ee9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eed:	8b 06                	mov    (%esi),%eax
  801eef:	89 04 24             	mov    %eax,(%esp)
  801ef2:	e8 55 ff ff ff       	call   801e4c <dev_lookup>
  801ef7:	89 c3                	mov    %eax,%ebx
  801ef9:	85 c0                	test   %eax,%eax
  801efb:	78 18                	js     801f15 <fd_close+0x6f>
		if (dev->dev_close)
  801efd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f00:	8b 40 10             	mov    0x10(%eax),%eax
  801f03:	85 c0                	test   %eax,%eax
  801f05:	74 09                	je     801f10 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801f07:	89 34 24             	mov    %esi,(%esp)
  801f0a:	ff d0                	call   *%eax
  801f0c:	89 c3                	mov    %eax,%ebx
  801f0e:	eb 05                	jmp    801f15 <fd_close+0x6f>
		else
			r = 0;
  801f10:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801f15:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f19:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f20:	e8 2f f7 ff ff       	call   801654 <sys_page_unmap>
	return r;
}
  801f25:	89 d8                	mov    %ebx,%eax
  801f27:	83 c4 30             	add    $0x30,%esp
  801f2a:	5b                   	pop    %ebx
  801f2b:	5e                   	pop    %esi
  801f2c:	5d                   	pop    %ebp
  801f2d:	c3                   	ret    

00801f2e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801f2e:	55                   	push   %ebp
  801f2f:	89 e5                	mov    %esp,%ebp
  801f31:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f34:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f37:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f3b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f3e:	89 04 24             	mov    %eax,(%esp)
  801f41:	e8 b0 fe ff ff       	call   801df6 <fd_lookup>
  801f46:	85 c0                	test   %eax,%eax
  801f48:	78 13                	js     801f5d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801f4a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801f51:	00 
  801f52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f55:	89 04 24             	mov    %eax,(%esp)
  801f58:	e8 49 ff ff ff       	call   801ea6 <fd_close>
}
  801f5d:	c9                   	leave  
  801f5e:	c3                   	ret    

00801f5f <close_all>:

void
close_all(void)
{
  801f5f:	55                   	push   %ebp
  801f60:	89 e5                	mov    %esp,%ebp
  801f62:	53                   	push   %ebx
  801f63:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801f66:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801f6b:	89 1c 24             	mov    %ebx,(%esp)
  801f6e:	e8 bb ff ff ff       	call   801f2e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801f73:	43                   	inc    %ebx
  801f74:	83 fb 20             	cmp    $0x20,%ebx
  801f77:	75 f2                	jne    801f6b <close_all+0xc>
		close(i);
}
  801f79:	83 c4 14             	add    $0x14,%esp
  801f7c:	5b                   	pop    %ebx
  801f7d:	5d                   	pop    %ebp
  801f7e:	c3                   	ret    

00801f7f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801f7f:	55                   	push   %ebp
  801f80:	89 e5                	mov    %esp,%ebp
  801f82:	57                   	push   %edi
  801f83:	56                   	push   %esi
  801f84:	53                   	push   %ebx
  801f85:	83 ec 4c             	sub    $0x4c,%esp
  801f88:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801f8b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801f8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f92:	8b 45 08             	mov    0x8(%ebp),%eax
  801f95:	89 04 24             	mov    %eax,(%esp)
  801f98:	e8 59 fe ff ff       	call   801df6 <fd_lookup>
  801f9d:	89 c3                	mov    %eax,%ebx
  801f9f:	85 c0                	test   %eax,%eax
  801fa1:	0f 88 e1 00 00 00    	js     802088 <dup+0x109>
		return r;
	close(newfdnum);
  801fa7:	89 3c 24             	mov    %edi,(%esp)
  801faa:	e8 7f ff ff ff       	call   801f2e <close>

	newfd = INDEX2FD(newfdnum);
  801faf:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801fb5:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801fb8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fbb:	89 04 24             	mov    %eax,(%esp)
  801fbe:	e8 c5 fd ff ff       	call   801d88 <fd2data>
  801fc3:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801fc5:	89 34 24             	mov    %esi,(%esp)
  801fc8:	e8 bb fd ff ff       	call   801d88 <fd2data>
  801fcd:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801fd0:	89 d8                	mov    %ebx,%eax
  801fd2:	c1 e8 16             	shr    $0x16,%eax
  801fd5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801fdc:	a8 01                	test   $0x1,%al
  801fde:	74 46                	je     802026 <dup+0xa7>
  801fe0:	89 d8                	mov    %ebx,%eax
  801fe2:	c1 e8 0c             	shr    $0xc,%eax
  801fe5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801fec:	f6 c2 01             	test   $0x1,%dl
  801fef:	74 35                	je     802026 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801ff1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801ff8:	25 07 0e 00 00       	and    $0xe07,%eax
  801ffd:	89 44 24 10          	mov    %eax,0x10(%esp)
  802001:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  802004:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802008:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80200f:	00 
  802010:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802014:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80201b:	e8 e1 f5 ff ff       	call   801601 <sys_page_map>
  802020:	89 c3                	mov    %eax,%ebx
  802022:	85 c0                	test   %eax,%eax
  802024:	78 3b                	js     802061 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802026:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802029:	89 c2                	mov    %eax,%edx
  80202b:	c1 ea 0c             	shr    $0xc,%edx
  80202e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802035:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80203b:	89 54 24 10          	mov    %edx,0x10(%esp)
  80203f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  802043:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80204a:	00 
  80204b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80204f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802056:	e8 a6 f5 ff ff       	call   801601 <sys_page_map>
  80205b:	89 c3                	mov    %eax,%ebx
  80205d:	85 c0                	test   %eax,%eax
  80205f:	79 25                	jns    802086 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  802061:	89 74 24 04          	mov    %esi,0x4(%esp)
  802065:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80206c:	e8 e3 f5 ff ff       	call   801654 <sys_page_unmap>
	sys_page_unmap(0, nva);
  802071:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  802074:	89 44 24 04          	mov    %eax,0x4(%esp)
  802078:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80207f:	e8 d0 f5 ff ff       	call   801654 <sys_page_unmap>
	return r;
  802084:	eb 02                	jmp    802088 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  802086:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  802088:	89 d8                	mov    %ebx,%eax
  80208a:	83 c4 4c             	add    $0x4c,%esp
  80208d:	5b                   	pop    %ebx
  80208e:	5e                   	pop    %esi
  80208f:	5f                   	pop    %edi
  802090:	5d                   	pop    %ebp
  802091:	c3                   	ret    

00802092 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  802092:	55                   	push   %ebp
  802093:	89 e5                	mov    %esp,%ebp
  802095:	53                   	push   %ebx
  802096:	83 ec 24             	sub    $0x24,%esp
  802099:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80209c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80209f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020a3:	89 1c 24             	mov    %ebx,(%esp)
  8020a6:	e8 4b fd ff ff       	call   801df6 <fd_lookup>
  8020ab:	85 c0                	test   %eax,%eax
  8020ad:	78 6d                	js     80211c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8020af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020b9:	8b 00                	mov    (%eax),%eax
  8020bb:	89 04 24             	mov    %eax,(%esp)
  8020be:	e8 89 fd ff ff       	call   801e4c <dev_lookup>
  8020c3:	85 c0                	test   %eax,%eax
  8020c5:	78 55                	js     80211c <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8020c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020ca:	8b 50 08             	mov    0x8(%eax),%edx
  8020cd:	83 e2 03             	and    $0x3,%edx
  8020d0:	83 fa 01             	cmp    $0x1,%edx
  8020d3:	75 23                	jne    8020f8 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8020d5:	a1 24 54 80 00       	mov    0x805424,%eax
  8020da:	8b 40 48             	mov    0x48(%eax),%eax
  8020dd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020e5:	c7 04 24 ad 3c 80 00 	movl   $0x803cad,(%esp)
  8020ec:	e8 3f ea ff ff       	call   800b30 <cprintf>
		return -E_INVAL;
  8020f1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8020f6:	eb 24                	jmp    80211c <read+0x8a>
	}
	if (!dev->dev_read)
  8020f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020fb:	8b 52 08             	mov    0x8(%edx),%edx
  8020fe:	85 d2                	test   %edx,%edx
  802100:	74 15                	je     802117 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  802102:	8b 4d 10             	mov    0x10(%ebp),%ecx
  802105:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802109:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80210c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802110:	89 04 24             	mov    %eax,(%esp)
  802113:	ff d2                	call   *%edx
  802115:	eb 05                	jmp    80211c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  802117:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80211c:	83 c4 24             	add    $0x24,%esp
  80211f:	5b                   	pop    %ebx
  802120:	5d                   	pop    %ebp
  802121:	c3                   	ret    

00802122 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  802122:	55                   	push   %ebp
  802123:	89 e5                	mov    %esp,%ebp
  802125:	57                   	push   %edi
  802126:	56                   	push   %esi
  802127:	53                   	push   %ebx
  802128:	83 ec 1c             	sub    $0x1c,%esp
  80212b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80212e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802131:	bb 00 00 00 00       	mov    $0x0,%ebx
  802136:	eb 23                	jmp    80215b <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802138:	89 f0                	mov    %esi,%eax
  80213a:	29 d8                	sub    %ebx,%eax
  80213c:	89 44 24 08          	mov    %eax,0x8(%esp)
  802140:	8b 45 0c             	mov    0xc(%ebp),%eax
  802143:	01 d8                	add    %ebx,%eax
  802145:	89 44 24 04          	mov    %eax,0x4(%esp)
  802149:	89 3c 24             	mov    %edi,(%esp)
  80214c:	e8 41 ff ff ff       	call   802092 <read>
		if (m < 0)
  802151:	85 c0                	test   %eax,%eax
  802153:	78 10                	js     802165 <readn+0x43>
			return m;
		if (m == 0)
  802155:	85 c0                	test   %eax,%eax
  802157:	74 0a                	je     802163 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802159:	01 c3                	add    %eax,%ebx
  80215b:	39 f3                	cmp    %esi,%ebx
  80215d:	72 d9                	jb     802138 <readn+0x16>
  80215f:	89 d8                	mov    %ebx,%eax
  802161:	eb 02                	jmp    802165 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  802163:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  802165:	83 c4 1c             	add    $0x1c,%esp
  802168:	5b                   	pop    %ebx
  802169:	5e                   	pop    %esi
  80216a:	5f                   	pop    %edi
  80216b:	5d                   	pop    %ebp
  80216c:	c3                   	ret    

0080216d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80216d:	55                   	push   %ebp
  80216e:	89 e5                	mov    %esp,%ebp
  802170:	53                   	push   %ebx
  802171:	83 ec 24             	sub    $0x24,%esp
  802174:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802177:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80217a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80217e:	89 1c 24             	mov    %ebx,(%esp)
  802181:	e8 70 fc ff ff       	call   801df6 <fd_lookup>
  802186:	85 c0                	test   %eax,%eax
  802188:	78 68                	js     8021f2 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80218a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80218d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802191:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802194:	8b 00                	mov    (%eax),%eax
  802196:	89 04 24             	mov    %eax,(%esp)
  802199:	e8 ae fc ff ff       	call   801e4c <dev_lookup>
  80219e:	85 c0                	test   %eax,%eax
  8021a0:	78 50                	js     8021f2 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8021a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021a5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8021a9:	75 23                	jne    8021ce <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8021ab:	a1 24 54 80 00       	mov    0x805424,%eax
  8021b0:	8b 40 48             	mov    0x48(%eax),%eax
  8021b3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021bb:	c7 04 24 c9 3c 80 00 	movl   $0x803cc9,(%esp)
  8021c2:	e8 69 e9 ff ff       	call   800b30 <cprintf>
		return -E_INVAL;
  8021c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8021cc:	eb 24                	jmp    8021f2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8021ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8021d1:	8b 52 0c             	mov    0xc(%edx),%edx
  8021d4:	85 d2                	test   %edx,%edx
  8021d6:	74 15                	je     8021ed <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8021d8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8021db:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021e2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8021e6:	89 04 24             	mov    %eax,(%esp)
  8021e9:	ff d2                	call   *%edx
  8021eb:	eb 05                	jmp    8021f2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8021ed:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8021f2:	83 c4 24             	add    $0x24,%esp
  8021f5:	5b                   	pop    %ebx
  8021f6:	5d                   	pop    %ebp
  8021f7:	c3                   	ret    

008021f8 <seek>:

int
seek(int fdnum, off_t offset)
{
  8021f8:	55                   	push   %ebp
  8021f9:	89 e5                	mov    %esp,%ebp
  8021fb:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021fe:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802201:	89 44 24 04          	mov    %eax,0x4(%esp)
  802205:	8b 45 08             	mov    0x8(%ebp),%eax
  802208:	89 04 24             	mov    %eax,(%esp)
  80220b:	e8 e6 fb ff ff       	call   801df6 <fd_lookup>
  802210:	85 c0                	test   %eax,%eax
  802212:	78 0e                	js     802222 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  802214:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802217:	8b 55 0c             	mov    0xc(%ebp),%edx
  80221a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80221d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802222:	c9                   	leave  
  802223:	c3                   	ret    

00802224 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802224:	55                   	push   %ebp
  802225:	89 e5                	mov    %esp,%ebp
  802227:	53                   	push   %ebx
  802228:	83 ec 24             	sub    $0x24,%esp
  80222b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80222e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802231:	89 44 24 04          	mov    %eax,0x4(%esp)
  802235:	89 1c 24             	mov    %ebx,(%esp)
  802238:	e8 b9 fb ff ff       	call   801df6 <fd_lookup>
  80223d:	85 c0                	test   %eax,%eax
  80223f:	78 61                	js     8022a2 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802241:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802244:	89 44 24 04          	mov    %eax,0x4(%esp)
  802248:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80224b:	8b 00                	mov    (%eax),%eax
  80224d:	89 04 24             	mov    %eax,(%esp)
  802250:	e8 f7 fb ff ff       	call   801e4c <dev_lookup>
  802255:	85 c0                	test   %eax,%eax
  802257:	78 49                	js     8022a2 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802259:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80225c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802260:	75 23                	jne    802285 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  802262:	a1 24 54 80 00       	mov    0x805424,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802267:	8b 40 48             	mov    0x48(%eax),%eax
  80226a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80226e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802272:	c7 04 24 8c 3c 80 00 	movl   $0x803c8c,(%esp)
  802279:	e8 b2 e8 ff ff       	call   800b30 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80227e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802283:	eb 1d                	jmp    8022a2 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  802285:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802288:	8b 52 18             	mov    0x18(%edx),%edx
  80228b:	85 d2                	test   %edx,%edx
  80228d:	74 0e                	je     80229d <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80228f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802292:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802296:	89 04 24             	mov    %eax,(%esp)
  802299:	ff d2                	call   *%edx
  80229b:	eb 05                	jmp    8022a2 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80229d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8022a2:	83 c4 24             	add    $0x24,%esp
  8022a5:	5b                   	pop    %ebx
  8022a6:	5d                   	pop    %ebp
  8022a7:	c3                   	ret    

008022a8 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8022a8:	55                   	push   %ebp
  8022a9:	89 e5                	mov    %esp,%ebp
  8022ab:	53                   	push   %ebx
  8022ac:	83 ec 24             	sub    $0x24,%esp
  8022af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8022b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8022b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8022bc:	89 04 24             	mov    %eax,(%esp)
  8022bf:	e8 32 fb ff ff       	call   801df6 <fd_lookup>
  8022c4:	85 c0                	test   %eax,%eax
  8022c6:	78 52                	js     80231a <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8022c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022d2:	8b 00                	mov    (%eax),%eax
  8022d4:	89 04 24             	mov    %eax,(%esp)
  8022d7:	e8 70 fb ff ff       	call   801e4c <dev_lookup>
  8022dc:	85 c0                	test   %eax,%eax
  8022de:	78 3a                	js     80231a <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8022e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022e3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8022e7:	74 2c                	je     802315 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8022e9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8022ec:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8022f3:	00 00 00 
	stat->st_isdir = 0;
  8022f6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8022fd:	00 00 00 
	stat->st_dev = dev;
  802300:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802306:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80230a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80230d:	89 14 24             	mov    %edx,(%esp)
  802310:	ff 50 14             	call   *0x14(%eax)
  802313:	eb 05                	jmp    80231a <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  802315:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80231a:	83 c4 24             	add    $0x24,%esp
  80231d:	5b                   	pop    %ebx
  80231e:	5d                   	pop    %ebp
  80231f:	c3                   	ret    

00802320 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802320:	55                   	push   %ebp
  802321:	89 e5                	mov    %esp,%ebp
  802323:	56                   	push   %esi
  802324:	53                   	push   %ebx
  802325:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802328:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80232f:	00 
  802330:	8b 45 08             	mov    0x8(%ebp),%eax
  802333:	89 04 24             	mov    %eax,(%esp)
  802336:	e8 2d 02 00 00       	call   802568 <open>
  80233b:	89 c3                	mov    %eax,%ebx
  80233d:	85 c0                	test   %eax,%eax
  80233f:	78 1b                	js     80235c <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  802341:	8b 45 0c             	mov    0xc(%ebp),%eax
  802344:	89 44 24 04          	mov    %eax,0x4(%esp)
  802348:	89 1c 24             	mov    %ebx,(%esp)
  80234b:	e8 58 ff ff ff       	call   8022a8 <fstat>
  802350:	89 c6                	mov    %eax,%esi
	close(fd);
  802352:	89 1c 24             	mov    %ebx,(%esp)
  802355:	e8 d4 fb ff ff       	call   801f2e <close>
	return r;
  80235a:	89 f3                	mov    %esi,%ebx
}
  80235c:	89 d8                	mov    %ebx,%eax
  80235e:	83 c4 10             	add    $0x10,%esp
  802361:	5b                   	pop    %ebx
  802362:	5e                   	pop    %esi
  802363:	5d                   	pop    %ebp
  802364:	c3                   	ret    
  802365:	00 00                	add    %al,(%eax)
	...

00802368 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802368:	55                   	push   %ebp
  802369:	89 e5                	mov    %esp,%ebp
  80236b:	56                   	push   %esi
  80236c:	53                   	push   %ebx
  80236d:	83 ec 10             	sub    $0x10,%esp
  802370:	89 c3                	mov    %eax,%ebx
  802372:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  802374:	83 3d 20 54 80 00 00 	cmpl   $0x0,0x805420
  80237b:	75 11                	jne    80238e <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80237d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  802384:	e8 82 0f 00 00       	call   80330b <ipc_find_env>
  802389:	a3 20 54 80 00       	mov    %eax,0x805420
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80238e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  802395:	00 
  802396:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  80239d:	00 
  80239e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8023a2:	a1 20 54 80 00       	mov    0x805420,%eax
  8023a7:	89 04 24             	mov    %eax,(%esp)
  8023aa:	e8 ee 0e 00 00       	call   80329d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8023af:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8023b6:	00 
  8023b7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023c2:	e8 6d 0e 00 00       	call   803234 <ipc_recv>
}
  8023c7:	83 c4 10             	add    $0x10,%esp
  8023ca:	5b                   	pop    %ebx
  8023cb:	5e                   	pop    %esi
  8023cc:	5d                   	pop    %ebp
  8023cd:	c3                   	ret    

008023ce <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8023ce:	55                   	push   %ebp
  8023cf:	89 e5                	mov    %esp,%ebp
  8023d1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8023d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8023d7:	8b 40 0c             	mov    0xc(%eax),%eax
  8023da:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  8023df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023e2:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8023e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8023ec:	b8 02 00 00 00       	mov    $0x2,%eax
  8023f1:	e8 72 ff ff ff       	call   802368 <fsipc>
}
  8023f6:	c9                   	leave  
  8023f7:	c3                   	ret    

008023f8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8023f8:	55                   	push   %ebp
  8023f9:	89 e5                	mov    %esp,%ebp
  8023fb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8023fe:	8b 45 08             	mov    0x8(%ebp),%eax
  802401:	8b 40 0c             	mov    0xc(%eax),%eax
  802404:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  802409:	ba 00 00 00 00       	mov    $0x0,%edx
  80240e:	b8 06 00 00 00       	mov    $0x6,%eax
  802413:	e8 50 ff ff ff       	call   802368 <fsipc>
}
  802418:	c9                   	leave  
  802419:	c3                   	ret    

0080241a <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80241a:	55                   	push   %ebp
  80241b:	89 e5                	mov    %esp,%ebp
  80241d:	53                   	push   %ebx
  80241e:	83 ec 14             	sub    $0x14,%esp
  802421:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802424:	8b 45 08             	mov    0x8(%ebp),%eax
  802427:	8b 40 0c             	mov    0xc(%eax),%eax
  80242a:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80242f:	ba 00 00 00 00       	mov    $0x0,%edx
  802434:	b8 05 00 00 00       	mov    $0x5,%eax
  802439:	e8 2a ff ff ff       	call   802368 <fsipc>
  80243e:	85 c0                	test   %eax,%eax
  802440:	78 2b                	js     80246d <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802442:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  802449:	00 
  80244a:	89 1c 24             	mov    %ebx,(%esp)
  80244d:	e8 69 ed ff ff       	call   8011bb <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802452:	a1 80 60 80 00       	mov    0x806080,%eax
  802457:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80245d:	a1 84 60 80 00       	mov    0x806084,%eax
  802462:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802468:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80246d:	83 c4 14             	add    $0x14,%esp
  802470:	5b                   	pop    %ebx
  802471:	5d                   	pop    %ebp
  802472:	c3                   	ret    

00802473 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802473:	55                   	push   %ebp
  802474:	89 e5                	mov    %esp,%ebp
  802476:	83 ec 18             	sub    $0x18,%esp
  802479:	8b 55 10             	mov    0x10(%ebp),%edx
  80247c:	89 d0                	mov    %edx,%eax
  80247e:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  802484:	76 05                	jbe    80248b <devfile_write+0x18>
  802486:	b8 00 10 00 00       	mov    $0x1000,%eax
	//panic("devfile_write not implemented");
	int r;
	//uint32_t maxsize = BLKSIZE - sizeof(int) - sizeof(size_t);	
	if (n > BLKSIZE)
		n = BLKSIZE;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80248b:	8b 55 08             	mov    0x8(%ebp),%edx
  80248e:	8b 52 0c             	mov    0xc(%edx),%edx
  802491:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  802497:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80249c:	89 44 24 08          	mov    %eax,0x8(%esp)
  8024a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024a7:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  8024ae:	e8 81 ee ff ff       	call   801334 <memmove>
	 
	return fsipc(FSREQ_WRITE, NULL);
  8024b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8024b8:	b8 04 00 00 00       	mov    $0x4,%eax
  8024bd:	e8 a6 fe ff ff       	call   802368 <fsipc>
}
  8024c2:	c9                   	leave  
  8024c3:	c3                   	ret    

008024c4 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8024c4:	55                   	push   %ebp
  8024c5:	89 e5                	mov    %esp,%ebp
  8024c7:	56                   	push   %esi
  8024c8:	53                   	push   %ebx
  8024c9:	83 ec 10             	sub    $0x10,%esp
  8024cc:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8024cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8024d2:	8b 40 0c             	mov    0xc(%eax),%eax
  8024d5:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  8024da:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8024e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8024e5:	b8 03 00 00 00       	mov    $0x3,%eax
  8024ea:	e8 79 fe ff ff       	call   802368 <fsipc>
  8024ef:	89 c3                	mov    %eax,%ebx
  8024f1:	85 c0                	test   %eax,%eax
  8024f3:	78 6a                	js     80255f <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8024f5:	39 c6                	cmp    %eax,%esi
  8024f7:	73 24                	jae    80251d <devfile_read+0x59>
  8024f9:	c7 44 24 0c f8 3c 80 	movl   $0x803cf8,0xc(%esp)
  802500:	00 
  802501:	c7 44 24 08 52 37 80 	movl   $0x803752,0x8(%esp)
  802508:	00 
  802509:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  802510:	00 
  802511:	c7 04 24 ff 3c 80 00 	movl   $0x803cff,(%esp)
  802518:	e8 1b e5 ff ff       	call   800a38 <_panic>
	assert(r <= PGSIZE);
  80251d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802522:	7e 24                	jle    802548 <devfile_read+0x84>
  802524:	c7 44 24 0c 0a 3d 80 	movl   $0x803d0a,0xc(%esp)
  80252b:	00 
  80252c:	c7 44 24 08 52 37 80 	movl   $0x803752,0x8(%esp)
  802533:	00 
  802534:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  80253b:	00 
  80253c:	c7 04 24 ff 3c 80 00 	movl   $0x803cff,(%esp)
  802543:	e8 f0 e4 ff ff       	call   800a38 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  802548:	89 44 24 08          	mov    %eax,0x8(%esp)
  80254c:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  802553:	00 
  802554:	8b 45 0c             	mov    0xc(%ebp),%eax
  802557:	89 04 24             	mov    %eax,(%esp)
  80255a:	e8 d5 ed ff ff       	call   801334 <memmove>
	return r;
}
  80255f:	89 d8                	mov    %ebx,%eax
  802561:	83 c4 10             	add    $0x10,%esp
  802564:	5b                   	pop    %ebx
  802565:	5e                   	pop    %esi
  802566:	5d                   	pop    %ebp
  802567:	c3                   	ret    

00802568 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802568:	55                   	push   %ebp
  802569:	89 e5                	mov    %esp,%ebp
  80256b:	56                   	push   %esi
  80256c:	53                   	push   %ebx
  80256d:	83 ec 20             	sub    $0x20,%esp
  802570:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  802573:	89 34 24             	mov    %esi,(%esp)
  802576:	e8 0d ec ff ff       	call   801188 <strlen>
  80257b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802580:	7f 60                	jg     8025e2 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802582:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802585:	89 04 24             	mov    %eax,(%esp)
  802588:	e8 16 f8 ff ff       	call   801da3 <fd_alloc>
  80258d:	89 c3                	mov    %eax,%ebx
  80258f:	85 c0                	test   %eax,%eax
  802591:	78 54                	js     8025e7 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  802593:	89 74 24 04          	mov    %esi,0x4(%esp)
  802597:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  80259e:	e8 18 ec ff ff       	call   8011bb <strcpy>
	fsipcbuf.open.req_omode = mode;
  8025a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025a6:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8025ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8025ae:	b8 01 00 00 00       	mov    $0x1,%eax
  8025b3:	e8 b0 fd ff ff       	call   802368 <fsipc>
  8025b8:	89 c3                	mov    %eax,%ebx
  8025ba:	85 c0                	test   %eax,%eax
  8025bc:	79 15                	jns    8025d3 <open+0x6b>
		fd_close(fd, 0);
  8025be:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8025c5:	00 
  8025c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025c9:	89 04 24             	mov    %eax,(%esp)
  8025cc:	e8 d5 f8 ff ff       	call   801ea6 <fd_close>
		return r;
  8025d1:	eb 14                	jmp    8025e7 <open+0x7f>
	}

	return fd2num(fd);
  8025d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025d6:	89 04 24             	mov    %eax,(%esp)
  8025d9:	e8 9a f7 ff ff       	call   801d78 <fd2num>
  8025de:	89 c3                	mov    %eax,%ebx
  8025e0:	eb 05                	jmp    8025e7 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8025e2:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8025e7:	89 d8                	mov    %ebx,%eax
  8025e9:	83 c4 20             	add    $0x20,%esp
  8025ec:	5b                   	pop    %ebx
  8025ed:	5e                   	pop    %esi
  8025ee:	5d                   	pop    %ebp
  8025ef:	c3                   	ret    

008025f0 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8025f0:	55                   	push   %ebp
  8025f1:	89 e5                	mov    %esp,%ebp
  8025f3:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8025f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8025fb:	b8 08 00 00 00       	mov    $0x8,%eax
  802600:	e8 63 fd ff ff       	call   802368 <fsipc>
}
  802605:	c9                   	leave  
  802606:	c3                   	ret    
	...

00802608 <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  802608:	55                   	push   %ebp
  802609:	89 e5                	mov    %esp,%ebp
  80260b:	53                   	push   %ebx
  80260c:	83 ec 14             	sub    $0x14,%esp
  80260f:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  802611:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  802615:	7e 32                	jle    802649 <writebuf+0x41>
		ssize_t result = write(b->fd, b->buf, b->idx);
  802617:	8b 40 04             	mov    0x4(%eax),%eax
  80261a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80261e:	8d 43 10             	lea    0x10(%ebx),%eax
  802621:	89 44 24 04          	mov    %eax,0x4(%esp)
  802625:	8b 03                	mov    (%ebx),%eax
  802627:	89 04 24             	mov    %eax,(%esp)
  80262a:	e8 3e fb ff ff       	call   80216d <write>
		if (result > 0)
  80262f:	85 c0                	test   %eax,%eax
  802631:	7e 03                	jle    802636 <writebuf+0x2e>
			b->result += result;
  802633:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  802636:	39 43 04             	cmp    %eax,0x4(%ebx)
  802639:	74 0e                	je     802649 <writebuf+0x41>
			b->error = (result < 0 ? result : 0);
  80263b:	89 c2                	mov    %eax,%edx
  80263d:	85 c0                	test   %eax,%eax
  80263f:	7e 05                	jle    802646 <writebuf+0x3e>
  802641:	ba 00 00 00 00       	mov    $0x0,%edx
  802646:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  802649:	83 c4 14             	add    $0x14,%esp
  80264c:	5b                   	pop    %ebx
  80264d:	5d                   	pop    %ebp
  80264e:	c3                   	ret    

0080264f <putch>:

static void
putch(int ch, void *thunk)
{
  80264f:	55                   	push   %ebp
  802650:	89 e5                	mov    %esp,%ebp
  802652:	53                   	push   %ebx
  802653:	83 ec 04             	sub    $0x4,%esp
  802656:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  802659:	8b 43 04             	mov    0x4(%ebx),%eax
  80265c:	8b 55 08             	mov    0x8(%ebp),%edx
  80265f:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  802663:	40                   	inc    %eax
  802664:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  802667:	3d 00 01 00 00       	cmp    $0x100,%eax
  80266c:	75 0e                	jne    80267c <putch+0x2d>
		writebuf(b);
  80266e:	89 d8                	mov    %ebx,%eax
  802670:	e8 93 ff ff ff       	call   802608 <writebuf>
		b->idx = 0;
  802675:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  80267c:	83 c4 04             	add    $0x4,%esp
  80267f:	5b                   	pop    %ebx
  802680:	5d                   	pop    %ebp
  802681:	c3                   	ret    

00802682 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  802682:	55                   	push   %ebp
  802683:	89 e5                	mov    %esp,%ebp
  802685:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  80268b:	8b 45 08             	mov    0x8(%ebp),%eax
  80268e:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  802694:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  80269b:	00 00 00 
	b.result = 0;
  80269e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8026a5:	00 00 00 
	b.error = 1;
  8026a8:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8026af:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8026b2:	8b 45 10             	mov    0x10(%ebp),%eax
  8026b5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8026b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8026c0:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8026c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026ca:	c7 04 24 4f 26 80 00 	movl   $0x80264f,(%esp)
  8026d1:	e8 bc e5 ff ff       	call   800c92 <vprintfmt>
	if (b.idx > 0)
  8026d6:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8026dd:	7e 0b                	jle    8026ea <vfprintf+0x68>
		writebuf(&b);
  8026df:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8026e5:	e8 1e ff ff ff       	call   802608 <writebuf>

	return (b.result ? b.result : b.error);
  8026ea:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8026f0:	85 c0                	test   %eax,%eax
  8026f2:	75 06                	jne    8026fa <vfprintf+0x78>
  8026f4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8026fa:	c9                   	leave  
  8026fb:	c3                   	ret    

008026fc <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8026fc:	55                   	push   %ebp
  8026fd:	89 e5                	mov    %esp,%ebp
  8026ff:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  802702:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  802705:	89 44 24 08          	mov    %eax,0x8(%esp)
  802709:	8b 45 0c             	mov    0xc(%ebp),%eax
  80270c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802710:	8b 45 08             	mov    0x8(%ebp),%eax
  802713:	89 04 24             	mov    %eax,(%esp)
  802716:	e8 67 ff ff ff       	call   802682 <vfprintf>
	va_end(ap);

	return cnt;
}
  80271b:	c9                   	leave  
  80271c:	c3                   	ret    

0080271d <printf>:

int
printf(const char *fmt, ...)
{
  80271d:	55                   	push   %ebp
  80271e:	89 e5                	mov    %esp,%ebp
  802720:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  802723:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  802726:	89 44 24 08          	mov    %eax,0x8(%esp)
  80272a:	8b 45 08             	mov    0x8(%ebp),%eax
  80272d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802731:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  802738:	e8 45 ff ff ff       	call   802682 <vfprintf>
	va_end(ap);

	return cnt;
}
  80273d:	c9                   	leave  
  80273e:	c3                   	ret    
	...

00802740 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  802740:	55                   	push   %ebp
  802741:	89 e5                	mov    %esp,%ebp
  802743:	57                   	push   %edi
  802744:	56                   	push   %esi
  802745:	53                   	push   %ebx
  802746:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  80274c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802753:	00 
  802754:	8b 45 08             	mov    0x8(%ebp),%eax
  802757:	89 04 24             	mov    %eax,(%esp)
  80275a:	e8 09 fe ff ff       	call   802568 <open>
  80275f:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
  802765:	85 c0                	test   %eax,%eax
  802767:	0f 88 8c 05 00 00    	js     802cf9 <spawn+0x5b9>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  80276d:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  802774:	00 
  802775:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80277b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80277f:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  802785:	89 04 24             	mov    %eax,(%esp)
  802788:	e8 95 f9 ff ff       	call   802122 <readn>
  80278d:	3d 00 02 00 00       	cmp    $0x200,%eax
  802792:	75 0c                	jne    8027a0 <spawn+0x60>
	    || elf->e_magic != ELF_MAGIC) {
  802794:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  80279b:	45 4c 46 
  80279e:	74 3b                	je     8027db <spawn+0x9b>
		close(fd);
  8027a0:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  8027a6:	89 04 24             	mov    %eax,(%esp)
  8027a9:	e8 80 f7 ff ff       	call   801f2e <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8027ae:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  8027b5:	46 
  8027b6:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  8027bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027c0:	c7 04 24 16 3d 80 00 	movl   $0x803d16,(%esp)
  8027c7:	e8 64 e3 ff ff       	call   800b30 <cprintf>
		return -E_NOT_EXEC;
  8027cc:	c7 85 88 fd ff ff f2 	movl   $0xfffffff2,-0x278(%ebp)
  8027d3:	ff ff ff 
  8027d6:	e9 2a 05 00 00       	jmp    802d05 <spawn+0x5c5>
  8027db:	ba 07 00 00 00       	mov    $0x7,%edx
  8027e0:	89 d0                	mov    %edx,%eax
  8027e2:	cd 30                	int    $0x30
  8027e4:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8027ea:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8027f0:	85 c0                	test   %eax,%eax
  8027f2:	0f 88 0d 05 00 00    	js     802d05 <spawn+0x5c5>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8027f8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8027fd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  802804:	c1 e0 07             	shl    $0x7,%eax
  802807:	29 d0                	sub    %edx,%eax
  802809:	8d b0 00 00 c0 ee    	lea    -0x11400000(%eax),%esi
  80280f:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  802815:	b9 11 00 00 00       	mov    $0x11,%ecx
  80281a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  80281c:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  802822:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802828:	be 00 00 00 00       	mov    $0x0,%esi
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  80282d:	bb 00 00 00 00       	mov    $0x0,%ebx
  802832:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802835:	eb 0d                	jmp    802844 <spawn+0x104>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  802837:	89 04 24             	mov    %eax,(%esp)
  80283a:	e8 49 e9 ff ff       	call   801188 <strlen>
  80283f:	8d 5c 18 01          	lea    0x1(%eax,%ebx,1),%ebx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802843:	46                   	inc    %esi
  802844:	89 f2                	mov    %esi,%edx
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  802846:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80284d:	8b 04 b7             	mov    (%edi,%esi,4),%eax
  802850:	85 c0                	test   %eax,%eax
  802852:	75 e3                	jne    802837 <spawn+0xf7>
  802854:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
  80285a:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  802860:	bf 00 10 40 00       	mov    $0x401000,%edi
  802865:	29 df                	sub    %ebx,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  802867:	89 f8                	mov    %edi,%eax
  802869:	83 e0 fc             	and    $0xfffffffc,%eax
  80286c:	f7 d2                	not    %edx
  80286e:	8d 14 90             	lea    (%eax,%edx,4),%edx
  802871:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  802877:	89 d0                	mov    %edx,%eax
  802879:	83 e8 08             	sub    $0x8,%eax
  80287c:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  802881:	0f 86 8f 04 00 00    	jbe    802d16 <spawn+0x5d6>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802887:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80288e:	00 
  80288f:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802896:	00 
  802897:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80289e:	e8 0a ed ff ff       	call   8015ad <sys_page_alloc>
  8028a3:	85 c0                	test   %eax,%eax
  8028a5:	0f 88 70 04 00 00    	js     802d1b <spawn+0x5db>
  8028ab:	bb 00 00 00 00       	mov    $0x0,%ebx
  8028b0:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  8028b6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8028b9:	eb 2e                	jmp    8028e9 <spawn+0x1a9>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  8028bb:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8028c1:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  8028c7:	89 04 9a             	mov    %eax,(%edx,%ebx,4)
		strcpy(string_store, argv[i]);
  8028ca:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  8028cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8028d1:	89 3c 24             	mov    %edi,(%esp)
  8028d4:	e8 e2 e8 ff ff       	call   8011bb <strcpy>
		string_store += strlen(argv[i]) + 1;
  8028d9:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  8028dc:	89 04 24             	mov    %eax,(%esp)
  8028df:	e8 a4 e8 ff ff       	call   801188 <strlen>
  8028e4:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8028e8:	43                   	inc    %ebx
  8028e9:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  8028ef:	7c ca                	jl     8028bb <spawn+0x17b>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  8028f1:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  8028f7:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  8028fd:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  802904:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  80290a:	74 24                	je     802930 <spawn+0x1f0>
  80290c:	c7 44 24 0c a0 3d 80 	movl   $0x803da0,0xc(%esp)
  802913:	00 
  802914:	c7 44 24 08 52 37 80 	movl   $0x803752,0x8(%esp)
  80291b:	00 
  80291c:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
  802923:	00 
  802924:	c7 04 24 30 3d 80 00 	movl   $0x803d30,(%esp)
  80292b:	e8 08 e1 ff ff       	call   800a38 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  802930:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802936:	2d 00 30 80 11       	sub    $0x11803000,%eax
  80293b:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  802941:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  802944:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  80294a:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  80294d:	89 d0                	mov    %edx,%eax
  80294f:	2d 08 30 80 11       	sub    $0x11803008,%eax
  802954:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  80295a:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  802961:	00 
  802962:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  802969:	ee 
  80296a:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802970:	89 44 24 08          	mov    %eax,0x8(%esp)
  802974:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80297b:	00 
  80297c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802983:	e8 79 ec ff ff       	call   801601 <sys_page_map>
  802988:	89 c3                	mov    %eax,%ebx
  80298a:	85 c0                	test   %eax,%eax
  80298c:	78 1a                	js     8029a8 <spawn+0x268>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  80298e:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802995:	00 
  802996:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80299d:	e8 b2 ec ff ff       	call   801654 <sys_page_unmap>
  8029a2:	89 c3                	mov    %eax,%ebx
  8029a4:	85 c0                	test   %eax,%eax
  8029a6:	79 1f                	jns    8029c7 <spawn+0x287>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  8029a8:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8029af:	00 
  8029b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8029b7:	e8 98 ec ff ff       	call   801654 <sys_page_unmap>
	return r;
  8029bc:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  8029c2:	e9 3e 03 00 00       	jmp    802d05 <spawn+0x5c5>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8029c7:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  8029cd:	03 95 04 fe ff ff    	add    -0x1fc(%ebp),%edx
  8029d3:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8029d9:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  8029e0:	00 00 00 
  8029e3:	e9 bb 01 00 00       	jmp    802ba3 <spawn+0x463>
		if (ph->p_type != ELF_PROG_LOAD)
  8029e8:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8029ee:	83 38 01             	cmpl   $0x1,(%eax)
  8029f1:	0f 85 9f 01 00 00    	jne    802b96 <spawn+0x456>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  8029f7:	89 c2                	mov    %eax,%edx
  8029f9:	8b 40 18             	mov    0x18(%eax),%eax
  8029fc:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  8029ff:	83 f8 01             	cmp    $0x1,%eax
  802a02:	19 c0                	sbb    %eax,%eax
  802a04:	83 e0 fe             	and    $0xfffffffe,%eax
  802a07:	83 c0 07             	add    $0x7,%eax
  802a0a:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  802a10:	8b 52 04             	mov    0x4(%edx),%edx
  802a13:	89 95 78 fd ff ff    	mov    %edx,-0x288(%ebp)
  802a19:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802a1f:	8b 40 10             	mov    0x10(%eax),%eax
  802a22:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  802a28:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  802a2e:	8b 52 14             	mov    0x14(%edx),%edx
  802a31:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  802a37:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802a3d:	8b 78 08             	mov    0x8(%eax),%edi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  802a40:	89 f8                	mov    %edi,%eax
  802a42:	25 ff 0f 00 00       	and    $0xfff,%eax
  802a47:	74 16                	je     802a5f <spawn+0x31f>
		va -= i;
  802a49:	29 c7                	sub    %eax,%edi
		memsz += i;
  802a4b:	01 c2                	add    %eax,%edx
  802a4d:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
		filesz += i;
  802a53:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  802a59:	29 85 78 fd ff ff    	sub    %eax,-0x288(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  802a5f:	bb 00 00 00 00       	mov    $0x0,%ebx
  802a64:	e9 1f 01 00 00       	jmp    802b88 <spawn+0x448>
		if (i >= filesz) {
  802a69:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  802a6f:	77 2b                	ja     802a9c <spawn+0x35c>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  802a71:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  802a77:	89 54 24 08          	mov    %edx,0x8(%esp)
  802a7b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802a7f:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802a85:	89 04 24             	mov    %eax,(%esp)
  802a88:	e8 20 eb ff ff       	call   8015ad <sys_page_alloc>
  802a8d:	85 c0                	test   %eax,%eax
  802a8f:	0f 89 e7 00 00 00    	jns    802b7c <spawn+0x43c>
  802a95:	89 c6                	mov    %eax,%esi
  802a97:	e9 39 02 00 00       	jmp    802cd5 <spawn+0x595>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802a9c:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802aa3:	00 
  802aa4:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802aab:	00 
  802aac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802ab3:	e8 f5 ea ff ff       	call   8015ad <sys_page_alloc>
  802ab8:	85 c0                	test   %eax,%eax
  802aba:	0f 88 0b 02 00 00    	js     802ccb <spawn+0x58b>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  802ac0:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  802ac6:	01 f0                	add    %esi,%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802ac8:	89 44 24 04          	mov    %eax,0x4(%esp)
  802acc:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  802ad2:	89 04 24             	mov    %eax,(%esp)
  802ad5:	e8 1e f7 ff ff       	call   8021f8 <seek>
  802ada:	85 c0                	test   %eax,%eax
  802adc:	0f 88 ed 01 00 00    	js     802ccf <spawn+0x58f>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  802ae2:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802ae8:	29 f0                	sub    %esi,%eax
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802aea:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802aef:	76 05                	jbe    802af6 <spawn+0x3b6>
  802af1:	b8 00 10 00 00       	mov    $0x1000,%eax
  802af6:	89 44 24 08          	mov    %eax,0x8(%esp)
  802afa:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802b01:	00 
  802b02:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  802b08:	89 04 24             	mov    %eax,(%esp)
  802b0b:	e8 12 f6 ff ff       	call   802122 <readn>
  802b10:	85 c0                	test   %eax,%eax
  802b12:	0f 88 bb 01 00 00    	js     802cd3 <spawn+0x593>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  802b18:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  802b1e:	89 54 24 10          	mov    %edx,0x10(%esp)
  802b22:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802b26:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802b2c:	89 44 24 08          	mov    %eax,0x8(%esp)
  802b30:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802b37:	00 
  802b38:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802b3f:	e8 bd ea ff ff       	call   801601 <sys_page_map>
  802b44:	85 c0                	test   %eax,%eax
  802b46:	79 20                	jns    802b68 <spawn+0x428>
				panic("spawn: sys_page_map data: %e", r);
  802b48:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802b4c:	c7 44 24 08 3c 3d 80 	movl   $0x803d3c,0x8(%esp)
  802b53:	00 
  802b54:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
  802b5b:	00 
  802b5c:	c7 04 24 30 3d 80 00 	movl   $0x803d30,(%esp)
  802b63:	e8 d0 de ff ff       	call   800a38 <_panic>
			sys_page_unmap(0, UTEMP);
  802b68:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802b6f:	00 
  802b70:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802b77:	e8 d8 ea ff ff       	call   801654 <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  802b7c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802b82:	81 c7 00 10 00 00    	add    $0x1000,%edi
  802b88:	89 de                	mov    %ebx,%esi
  802b8a:	3b 9d 8c fd ff ff    	cmp    -0x274(%ebp),%ebx
  802b90:	0f 82 d3 fe ff ff    	jb     802a69 <spawn+0x329>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802b96:	ff 85 7c fd ff ff    	incl   -0x284(%ebp)
  802b9c:	83 85 80 fd ff ff 20 	addl   $0x20,-0x280(%ebp)
  802ba3:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  802baa:	39 85 7c fd ff ff    	cmp    %eax,-0x284(%ebp)
  802bb0:	0f 8c 32 fe ff ff    	jl     8029e8 <spawn+0x2a8>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  802bb6:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  802bbc:	89 04 24             	mov    %eax,(%esp)
  802bbf:	e8 6a f3 ff ff       	call   801f2e <close>
{
	// LAB 5: Your code here.
	int r;
	uint32_t page_num;
	
	for (page_num = 0; page_num < PGNUM(UTOP); page_num++) {
  802bc4:	be 00 00 00 00       	mov    $0x0,%esi
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES)/NPDENTRIES;
  802bc9:	89 f0                	mov    %esi,%eax
  802bcb:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx]&PTE_P) && (uvpt[page_num]&PTE_P) && (uvpt[page_num]&PTE_SHARE)){
  802bce:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802bd5:	a8 01                	test   $0x1,%al
  802bd7:	0f 84 82 00 00 00    	je     802c5f <spawn+0x51f>
  802bdd:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  802be4:	a8 01                	test   $0x1,%al
  802be6:	74 77                	je     802c5f <spawn+0x51f>
  802be8:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  802bef:	f6 c4 04             	test   $0x4,%ah
  802bf2:	74 6b                	je     802c5f <spawn+0x51f>
			if ((r = sys_page_map(sys_getenvid(), (void*)(page_num*PGSIZE), child, (void*)(page_num*PGSIZE), uvpt[page_num]&PTE_SYSCALL)) < 0){
  802bf4:	8b 3c b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edi
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  802bfb:	89 f3                	mov    %esi,%ebx
  802bfd:	c1 e3 0c             	shl    $0xc,%ebx
	uint32_t page_num;
	
	for (page_num = 0; page_num < PGNUM(UTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES)/NPDENTRIES;
		if ((uvpd[pdx]&PTE_P) && (uvpt[page_num]&PTE_P) && (uvpt[page_num]&PTE_SHARE)){
			if ((r = sys_page_map(sys_getenvid(), (void*)(page_num*PGSIZE), child, (void*)(page_num*PGSIZE), uvpt[page_num]&PTE_SYSCALL)) < 0){
  802c00:	e8 6a e9 ff ff       	call   80156f <sys_getenvid>
  802c05:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  802c0b:	89 7c 24 10          	mov    %edi,0x10(%esp)
  802c0f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  802c13:	8b 95 88 fd ff ff    	mov    -0x278(%ebp),%edx
  802c19:	89 54 24 08          	mov    %edx,0x8(%esp)
  802c1d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802c21:	89 04 24             	mov    %eax,(%esp)
  802c24:	e8 d8 e9 ff ff       	call   801601 <sys_page_map>
  802c29:	85 c0                	test   %eax,%eax
  802c2b:	79 32                	jns    802c5f <spawn+0x51f>
  802c2d:	89 c3                	mov    %eax,%ebx
				cprintf("copy_shared_pages: sys_page_map failed, %e", r);
  802c2f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802c33:	c7 04 24 c8 3d 80 00 	movl   $0x803dc8,(%esp)
  802c3a:	e8 f1 de ff ff       	call   800b30 <cprintf>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  802c3f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  802c43:	c7 44 24 08 59 3d 80 	movl   $0x803d59,0x8(%esp)
  802c4a:	00 
  802c4b:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  802c52:	00 
  802c53:	c7 04 24 30 3d 80 00 	movl   $0x803d30,(%esp)
  802c5a:	e8 d9 dd ff ff       	call   800a38 <_panic>
{
	// LAB 5: Your code here.
	int r;
	uint32_t page_num;
	
	for (page_num = 0; page_num < PGNUM(UTOP); page_num++) {
  802c5f:	46                   	inc    %esi
  802c60:	81 fe 00 ec 0e 00    	cmp    $0xeec00,%esi
  802c66:	0f 85 5d ff ff ff    	jne    802bc9 <spawn+0x489>
  802c6c:	e9 b2 00 00 00       	jmp    802d23 <spawn+0x5e3>
	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  802c71:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802c75:	c7 44 24 08 6f 3d 80 	movl   $0x803d6f,0x8(%esp)
  802c7c:	00 
  802c7d:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  802c84:	00 
  802c85:	c7 04 24 30 3d 80 00 	movl   $0x803d30,(%esp)
  802c8c:	e8 a7 dd ff ff       	call   800a38 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802c91:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  802c98:	00 
  802c99:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802c9f:	89 04 24             	mov    %eax,(%esp)
  802ca2:	e8 00 ea ff ff       	call   8016a7 <sys_env_set_status>
  802ca7:	85 c0                	test   %eax,%eax
  802ca9:	79 5a                	jns    802d05 <spawn+0x5c5>
		panic("sys_env_set_status: %e", r);
  802cab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802caf:	c7 44 24 08 89 3d 80 	movl   $0x803d89,0x8(%esp)
  802cb6:	00 
  802cb7:	c7 44 24 04 88 00 00 	movl   $0x88,0x4(%esp)
  802cbe:	00 
  802cbf:	c7 04 24 30 3d 80 00 	movl   $0x803d30,(%esp)
  802cc6:	e8 6d dd ff ff       	call   800a38 <_panic>
  802ccb:	89 c6                	mov    %eax,%esi
  802ccd:	eb 06                	jmp    802cd5 <spawn+0x595>
  802ccf:	89 c6                	mov    %eax,%esi
  802cd1:	eb 02                	jmp    802cd5 <spawn+0x595>
  802cd3:	89 c6                	mov    %eax,%esi

	return child;

error:
	sys_env_destroy(child);
  802cd5:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802cdb:	89 04 24             	mov    %eax,(%esp)
  802cde:	e8 3a e8 ff ff       	call   80151d <sys_env_destroy>
	close(fd);
  802ce3:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  802ce9:	89 04 24             	mov    %eax,(%esp)
  802cec:	e8 3d f2 ff ff       	call   801f2e <close>
	return r;
  802cf1:	89 b5 88 fd ff ff    	mov    %esi,-0x278(%ebp)
  802cf7:	eb 0c                	jmp    802d05 <spawn+0x5c5>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  802cf9:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  802cff:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  802d05:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802d0b:	81 c4 ac 02 00 00    	add    $0x2ac,%esp
  802d11:	5b                   	pop    %ebx
  802d12:	5e                   	pop    %esi
  802d13:	5f                   	pop    %edi
  802d14:	5d                   	pop    %ebp
  802d15:	c3                   	ret    
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  802d16:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  802d1b:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  802d21:	eb e2                	jmp    802d05 <spawn+0x5c5>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802d23:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802d29:	89 44 24 04          	mov    %eax,0x4(%esp)
  802d2d:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802d33:	89 04 24             	mov    %eax,(%esp)
  802d36:	e8 bf e9 ff ff       	call   8016fa <sys_env_set_trapframe>
  802d3b:	85 c0                	test   %eax,%eax
  802d3d:	0f 89 4e ff ff ff    	jns    802c91 <spawn+0x551>
  802d43:	e9 29 ff ff ff       	jmp    802c71 <spawn+0x531>

00802d48 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802d48:	55                   	push   %ebp
  802d49:	89 e5                	mov    %esp,%ebp
  802d4b:	57                   	push   %edi
  802d4c:	56                   	push   %esi
  802d4d:	53                   	push   %ebx
  802d4e:	83 ec 1c             	sub    $0x1c,%esp
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
  802d51:	8d 45 10             	lea    0x10(%ebp),%eax
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802d54:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802d59:	eb 03                	jmp    802d5e <spawnl+0x16>
		argc++;
  802d5b:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802d5c:	89 d0                	mov    %edx,%eax
  802d5e:	8d 50 04             	lea    0x4(%eax),%edx
  802d61:	83 38 00             	cmpl   $0x0,(%eax)
  802d64:	75 f5                	jne    802d5b <spawnl+0x13>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802d66:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  802d6d:	83 e0 f0             	and    $0xfffffff0,%eax
  802d70:	29 c4                	sub    %eax,%esp
  802d72:	8d 7c 24 17          	lea    0x17(%esp),%edi
  802d76:	83 e7 f0             	and    $0xfffffff0,%edi
  802d79:	89 fe                	mov    %edi,%esi
	argv[0] = arg0;
  802d7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  802d7e:	89 07                	mov    %eax,(%edi)
	argv[argc+1] = NULL;
  802d80:	c7 44 8f 04 00 00 00 	movl   $0x0,0x4(%edi,%ecx,4)
  802d87:	00 

	va_start(vl, arg0);
  802d88:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  802d8b:	b8 00 00 00 00       	mov    $0x0,%eax
  802d90:	eb 09                	jmp    802d9b <spawnl+0x53>
		argv[i+1] = va_arg(vl, const char *);
  802d92:	40                   	inc    %eax
  802d93:	8b 1a                	mov    (%edx),%ebx
  802d95:	89 1c 86             	mov    %ebx,(%esi,%eax,4)
  802d98:	8d 52 04             	lea    0x4(%edx),%edx
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802d9b:	39 c8                	cmp    %ecx,%eax
  802d9d:	75 f3                	jne    802d92 <spawnl+0x4a>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802d9f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802da3:	8b 45 08             	mov    0x8(%ebp),%eax
  802da6:	89 04 24             	mov    %eax,(%esp)
  802da9:	e8 92 f9 ff ff       	call   802740 <spawn>
}
  802dae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802db1:	5b                   	pop    %ebx
  802db2:	5e                   	pop    %esi
  802db3:	5f                   	pop    %edi
  802db4:	5d                   	pop    %ebp
  802db5:	c3                   	ret    
	...

00802db8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802db8:	55                   	push   %ebp
  802db9:	89 e5                	mov    %esp,%ebp
  802dbb:	56                   	push   %esi
  802dbc:	53                   	push   %ebx
  802dbd:	83 ec 10             	sub    $0x10,%esp
  802dc0:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802dc3:	8b 45 08             	mov    0x8(%ebp),%eax
  802dc6:	89 04 24             	mov    %eax,(%esp)
  802dc9:	e8 ba ef ff ff       	call   801d88 <fd2data>
  802dce:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  802dd0:	c7 44 24 04 f3 3d 80 	movl   $0x803df3,0x4(%esp)
  802dd7:	00 
  802dd8:	89 34 24             	mov    %esi,(%esp)
  802ddb:	e8 db e3 ff ff       	call   8011bb <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802de0:	8b 43 04             	mov    0x4(%ebx),%eax
  802de3:	2b 03                	sub    (%ebx),%eax
  802de5:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  802deb:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  802df2:	00 00 00 
	stat->st_dev = &devpipe;
  802df5:	c7 86 88 00 00 00 40 	movl   $0x804040,0x88(%esi)
  802dfc:	40 80 00 
	return 0;
}
  802dff:	b8 00 00 00 00       	mov    $0x0,%eax
  802e04:	83 c4 10             	add    $0x10,%esp
  802e07:	5b                   	pop    %ebx
  802e08:	5e                   	pop    %esi
  802e09:	5d                   	pop    %ebp
  802e0a:	c3                   	ret    

00802e0b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802e0b:	55                   	push   %ebp
  802e0c:	89 e5                	mov    %esp,%ebp
  802e0e:	53                   	push   %ebx
  802e0f:	83 ec 14             	sub    $0x14,%esp
  802e12:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802e15:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802e19:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802e20:	e8 2f e8 ff ff       	call   801654 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802e25:	89 1c 24             	mov    %ebx,(%esp)
  802e28:	e8 5b ef ff ff       	call   801d88 <fd2data>
  802e2d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802e31:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802e38:	e8 17 e8 ff ff       	call   801654 <sys_page_unmap>
}
  802e3d:	83 c4 14             	add    $0x14,%esp
  802e40:	5b                   	pop    %ebx
  802e41:	5d                   	pop    %ebp
  802e42:	c3                   	ret    

00802e43 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802e43:	55                   	push   %ebp
  802e44:	89 e5                	mov    %esp,%ebp
  802e46:	57                   	push   %edi
  802e47:	56                   	push   %esi
  802e48:	53                   	push   %ebx
  802e49:	83 ec 2c             	sub    $0x2c,%esp
  802e4c:	89 c7                	mov    %eax,%edi
  802e4e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802e51:	a1 24 54 80 00       	mov    0x805424,%eax
  802e56:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802e59:	89 3c 24             	mov    %edi,(%esp)
  802e5c:	e8 ef 04 00 00       	call   803350 <pageref>
  802e61:	89 c6                	mov    %eax,%esi
  802e63:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802e66:	89 04 24             	mov    %eax,(%esp)
  802e69:	e8 e2 04 00 00       	call   803350 <pageref>
  802e6e:	39 c6                	cmp    %eax,%esi
  802e70:	0f 94 c0             	sete   %al
  802e73:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  802e76:	8b 15 24 54 80 00    	mov    0x805424,%edx
  802e7c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802e7f:	39 cb                	cmp    %ecx,%ebx
  802e81:	75 08                	jne    802e8b <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  802e83:	83 c4 2c             	add    $0x2c,%esp
  802e86:	5b                   	pop    %ebx
  802e87:	5e                   	pop    %esi
  802e88:	5f                   	pop    %edi
  802e89:	5d                   	pop    %ebp
  802e8a:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  802e8b:	83 f8 01             	cmp    $0x1,%eax
  802e8e:	75 c1                	jne    802e51 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802e90:	8b 42 58             	mov    0x58(%edx),%eax
  802e93:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  802e9a:	00 
  802e9b:	89 44 24 08          	mov    %eax,0x8(%esp)
  802e9f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802ea3:	c7 04 24 fa 3d 80 00 	movl   $0x803dfa,(%esp)
  802eaa:	e8 81 dc ff ff       	call   800b30 <cprintf>
  802eaf:	eb a0                	jmp    802e51 <_pipeisclosed+0xe>

00802eb1 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802eb1:	55                   	push   %ebp
  802eb2:	89 e5                	mov    %esp,%ebp
  802eb4:	57                   	push   %edi
  802eb5:	56                   	push   %esi
  802eb6:	53                   	push   %ebx
  802eb7:	83 ec 1c             	sub    $0x1c,%esp
  802eba:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802ebd:	89 34 24             	mov    %esi,(%esp)
  802ec0:	e8 c3 ee ff ff       	call   801d88 <fd2data>
  802ec5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802ec7:	bf 00 00 00 00       	mov    $0x0,%edi
  802ecc:	eb 3c                	jmp    802f0a <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802ece:	89 da                	mov    %ebx,%edx
  802ed0:	89 f0                	mov    %esi,%eax
  802ed2:	e8 6c ff ff ff       	call   802e43 <_pipeisclosed>
  802ed7:	85 c0                	test   %eax,%eax
  802ed9:	75 38                	jne    802f13 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802edb:	e8 ae e6 ff ff       	call   80158e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802ee0:	8b 43 04             	mov    0x4(%ebx),%eax
  802ee3:	8b 13                	mov    (%ebx),%edx
  802ee5:	83 c2 20             	add    $0x20,%edx
  802ee8:	39 d0                	cmp    %edx,%eax
  802eea:	73 e2                	jae    802ece <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802eec:	8b 55 0c             	mov    0xc(%ebp),%edx
  802eef:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  802ef2:	89 c2                	mov    %eax,%edx
  802ef4:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  802efa:	79 05                	jns    802f01 <devpipe_write+0x50>
  802efc:	4a                   	dec    %edx
  802efd:	83 ca e0             	or     $0xffffffe0,%edx
  802f00:	42                   	inc    %edx
  802f01:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802f05:	40                   	inc    %eax
  802f06:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802f09:	47                   	inc    %edi
  802f0a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802f0d:	75 d1                	jne    802ee0 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802f0f:	89 f8                	mov    %edi,%eax
  802f11:	eb 05                	jmp    802f18 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802f13:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802f18:	83 c4 1c             	add    $0x1c,%esp
  802f1b:	5b                   	pop    %ebx
  802f1c:	5e                   	pop    %esi
  802f1d:	5f                   	pop    %edi
  802f1e:	5d                   	pop    %ebp
  802f1f:	c3                   	ret    

00802f20 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802f20:	55                   	push   %ebp
  802f21:	89 e5                	mov    %esp,%ebp
  802f23:	57                   	push   %edi
  802f24:	56                   	push   %esi
  802f25:	53                   	push   %ebx
  802f26:	83 ec 1c             	sub    $0x1c,%esp
  802f29:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802f2c:	89 3c 24             	mov    %edi,(%esp)
  802f2f:	e8 54 ee ff ff       	call   801d88 <fd2data>
  802f34:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802f36:	be 00 00 00 00       	mov    $0x0,%esi
  802f3b:	eb 3a                	jmp    802f77 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802f3d:	85 f6                	test   %esi,%esi
  802f3f:	74 04                	je     802f45 <devpipe_read+0x25>
				return i;
  802f41:	89 f0                	mov    %esi,%eax
  802f43:	eb 40                	jmp    802f85 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802f45:	89 da                	mov    %ebx,%edx
  802f47:	89 f8                	mov    %edi,%eax
  802f49:	e8 f5 fe ff ff       	call   802e43 <_pipeisclosed>
  802f4e:	85 c0                	test   %eax,%eax
  802f50:	75 2e                	jne    802f80 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802f52:	e8 37 e6 ff ff       	call   80158e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802f57:	8b 03                	mov    (%ebx),%eax
  802f59:	3b 43 04             	cmp    0x4(%ebx),%eax
  802f5c:	74 df                	je     802f3d <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802f5e:	25 1f 00 00 80       	and    $0x8000001f,%eax
  802f63:	79 05                	jns    802f6a <devpipe_read+0x4a>
  802f65:	48                   	dec    %eax
  802f66:	83 c8 e0             	or     $0xffffffe0,%eax
  802f69:	40                   	inc    %eax
  802f6a:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  802f6e:	8b 55 0c             	mov    0xc(%ebp),%edx
  802f71:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  802f74:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802f76:	46                   	inc    %esi
  802f77:	3b 75 10             	cmp    0x10(%ebp),%esi
  802f7a:	75 db                	jne    802f57 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802f7c:	89 f0                	mov    %esi,%eax
  802f7e:	eb 05                	jmp    802f85 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802f80:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802f85:	83 c4 1c             	add    $0x1c,%esp
  802f88:	5b                   	pop    %ebx
  802f89:	5e                   	pop    %esi
  802f8a:	5f                   	pop    %edi
  802f8b:	5d                   	pop    %ebp
  802f8c:	c3                   	ret    

00802f8d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802f8d:	55                   	push   %ebp
  802f8e:	89 e5                	mov    %esp,%ebp
  802f90:	57                   	push   %edi
  802f91:	56                   	push   %esi
  802f92:	53                   	push   %ebx
  802f93:	83 ec 3c             	sub    $0x3c,%esp
  802f96:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802f99:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802f9c:	89 04 24             	mov    %eax,(%esp)
  802f9f:	e8 ff ed ff ff       	call   801da3 <fd_alloc>
  802fa4:	89 c3                	mov    %eax,%ebx
  802fa6:	85 c0                	test   %eax,%eax
  802fa8:	0f 88 45 01 00 00    	js     8030f3 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802fae:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802fb5:	00 
  802fb6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802fb9:	89 44 24 04          	mov    %eax,0x4(%esp)
  802fbd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802fc4:	e8 e4 e5 ff ff       	call   8015ad <sys_page_alloc>
  802fc9:	89 c3                	mov    %eax,%ebx
  802fcb:	85 c0                	test   %eax,%eax
  802fcd:	0f 88 20 01 00 00    	js     8030f3 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802fd3:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802fd6:	89 04 24             	mov    %eax,(%esp)
  802fd9:	e8 c5 ed ff ff       	call   801da3 <fd_alloc>
  802fde:	89 c3                	mov    %eax,%ebx
  802fe0:	85 c0                	test   %eax,%eax
  802fe2:	0f 88 f8 00 00 00    	js     8030e0 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802fe8:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802fef:	00 
  802ff0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802ff3:	89 44 24 04          	mov    %eax,0x4(%esp)
  802ff7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802ffe:	e8 aa e5 ff ff       	call   8015ad <sys_page_alloc>
  803003:	89 c3                	mov    %eax,%ebx
  803005:	85 c0                	test   %eax,%eax
  803007:	0f 88 d3 00 00 00    	js     8030e0 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80300d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803010:	89 04 24             	mov    %eax,(%esp)
  803013:	e8 70 ed ff ff       	call   801d88 <fd2data>
  803018:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80301a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  803021:	00 
  803022:	89 44 24 04          	mov    %eax,0x4(%esp)
  803026:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80302d:	e8 7b e5 ff ff       	call   8015ad <sys_page_alloc>
  803032:	89 c3                	mov    %eax,%ebx
  803034:	85 c0                	test   %eax,%eax
  803036:	0f 88 91 00 00 00    	js     8030cd <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80303c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80303f:	89 04 24             	mov    %eax,(%esp)
  803042:	e8 41 ed ff ff       	call   801d88 <fd2data>
  803047:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  80304e:	00 
  80304f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  803053:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80305a:	00 
  80305b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80305f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803066:	e8 96 e5 ff ff       	call   801601 <sys_page_map>
  80306b:	89 c3                	mov    %eax,%ebx
  80306d:	85 c0                	test   %eax,%eax
  80306f:	78 4c                	js     8030bd <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  803071:	8b 15 40 40 80 00    	mov    0x804040,%edx
  803077:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80307a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80307c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80307f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  803086:	8b 15 40 40 80 00    	mov    0x804040,%edx
  80308c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80308f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  803091:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803094:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80309b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80309e:	89 04 24             	mov    %eax,(%esp)
  8030a1:	e8 d2 ec ff ff       	call   801d78 <fd2num>
  8030a6:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8030a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8030ab:	89 04 24             	mov    %eax,(%esp)
  8030ae:	e8 c5 ec ff ff       	call   801d78 <fd2num>
  8030b3:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8030b6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8030bb:	eb 36                	jmp    8030f3 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  8030bd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8030c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8030c8:	e8 87 e5 ff ff       	call   801654 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8030cd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8030d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8030d4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8030db:	e8 74 e5 ff ff       	call   801654 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8030e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8030e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8030e7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8030ee:	e8 61 e5 ff ff       	call   801654 <sys_page_unmap>
    err:
	return r;
}
  8030f3:	89 d8                	mov    %ebx,%eax
  8030f5:	83 c4 3c             	add    $0x3c,%esp
  8030f8:	5b                   	pop    %ebx
  8030f9:	5e                   	pop    %esi
  8030fa:	5f                   	pop    %edi
  8030fb:	5d                   	pop    %ebp
  8030fc:	c3                   	ret    

008030fd <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8030fd:	55                   	push   %ebp
  8030fe:	89 e5                	mov    %esp,%ebp
  803100:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803103:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803106:	89 44 24 04          	mov    %eax,0x4(%esp)
  80310a:	8b 45 08             	mov    0x8(%ebp),%eax
  80310d:	89 04 24             	mov    %eax,(%esp)
  803110:	e8 e1 ec ff ff       	call   801df6 <fd_lookup>
  803115:	85 c0                	test   %eax,%eax
  803117:	78 15                	js     80312e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  803119:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80311c:	89 04 24             	mov    %eax,(%esp)
  80311f:	e8 64 ec ff ff       	call   801d88 <fd2data>
	return _pipeisclosed(fd, p);
  803124:	89 c2                	mov    %eax,%edx
  803126:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803129:	e8 15 fd ff ff       	call   802e43 <_pipeisclosed>
}
  80312e:	c9                   	leave  
  80312f:	c3                   	ret    

00803130 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  803130:	55                   	push   %ebp
  803131:	89 e5                	mov    %esp,%ebp
  803133:	56                   	push   %esi
  803134:	53                   	push   %ebx
  803135:	83 ec 10             	sub    $0x10,%esp
  803138:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  80313b:	85 f6                	test   %esi,%esi
  80313d:	75 24                	jne    803163 <wait+0x33>
  80313f:	c7 44 24 0c 12 3e 80 	movl   $0x803e12,0xc(%esp)
  803146:	00 
  803147:	c7 44 24 08 52 37 80 	movl   $0x803752,0x8(%esp)
  80314e:	00 
  80314f:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  803156:	00 
  803157:	c7 04 24 1d 3e 80 00 	movl   $0x803e1d,(%esp)
  80315e:	e8 d5 d8 ff ff       	call   800a38 <_panic>
	e = &envs[ENVX(envid)];
  803163:	89 f3                	mov    %esi,%ebx
  803165:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  80316b:	8d 04 9d 00 00 00 00 	lea    0x0(,%ebx,4),%eax
  803172:	c1 e3 07             	shl    $0x7,%ebx
  803175:	29 c3                	sub    %eax,%ebx
  803177:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80317d:	eb 05                	jmp    803184 <wait+0x54>
		sys_yield();
  80317f:	e8 0a e4 ff ff       	call   80158e <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  803184:	8b 43 48             	mov    0x48(%ebx),%eax
  803187:	39 f0                	cmp    %esi,%eax
  803189:	75 07                	jne    803192 <wait+0x62>
  80318b:	8b 43 54             	mov    0x54(%ebx),%eax
  80318e:	85 c0                	test   %eax,%eax
  803190:	75 ed                	jne    80317f <wait+0x4f>
		sys_yield();
}
  803192:	83 c4 10             	add    $0x10,%esp
  803195:	5b                   	pop    %ebx
  803196:	5e                   	pop    %esi
  803197:	5d                   	pop    %ebp
  803198:	c3                   	ret    
  803199:	00 00                	add    %al,(%eax)
	...

0080319c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80319c:	55                   	push   %ebp
  80319d:	89 e5                	mov    %esp,%ebp
  80319f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8031a2:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8031a9:	75 58                	jne    803203 <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.	
		//panic("set_pgfault_handler not implemented");
		
		if (sys_page_alloc(thisenv->env_id,(void *) (UXSTACKTOP - PGSIZE),(PTE_W|PTE_U|PTE_P)) != 0){
  8031ab:	a1 24 54 80 00       	mov    0x805424,%eax
  8031b0:	8b 40 48             	mov    0x48(%eax),%eax
  8031b3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8031ba:	00 
  8031bb:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8031c2:	ee 
  8031c3:	89 04 24             	mov    %eax,(%esp)
  8031c6:	e8 e2 e3 ff ff       	call   8015ad <sys_page_alloc>
  8031cb:	85 c0                	test   %eax,%eax
  8031cd:	74 1c                	je     8031eb <set_pgfault_handler+0x4f>
			panic("set_pg_fault_handler");
  8031cf:	c7 44 24 08 28 3e 80 	movl   $0x803e28,0x8(%esp)
  8031d6:	00 
  8031d7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8031de:	00 
  8031df:	c7 04 24 3d 3e 80 00 	movl   $0x803e3d,(%esp)
  8031e6:	e8 4d d8 ff ff       	call   800a38 <_panic>
		}
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  8031eb:	a1 24 54 80 00       	mov    0x805424,%eax
  8031f0:	8b 40 48             	mov    0x48(%eax),%eax
  8031f3:	c7 44 24 04 10 32 80 	movl   $0x803210,0x4(%esp)
  8031fa:	00 
  8031fb:	89 04 24             	mov    %eax,(%esp)
  8031fe:	e8 4a e5 ff ff       	call   80174d <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  803203:	8b 45 08             	mov    0x8(%ebp),%eax
  803206:	a3 00 70 80 00       	mov    %eax,0x807000
}
  80320b:	c9                   	leave  
  80320c:	c3                   	ret    
  80320d:	00 00                	add    %al,(%eax)
	...

00803210 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  803210:	54                   	push   %esp
	movl _pgfault_handler, %eax
  803211:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  803216:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  803218:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// Save trap-time eip in eax
	movl 0x28(%esp), %eax
  80321b:	8b 44 24 28          	mov    0x28(%esp),%eax

	// Save our current stack
	movl %esp, %ebp
  80321f:	89 e5                	mov    %esp,%ebp

	// Switch to trap-time stack
	movl 0x30(%esp), %esp
  803221:	8b 64 24 30          	mov    0x30(%esp),%esp

	// Push trap-time eip to the trap-time stack
	pushl %eax
  803225:	50                   	push   %eax

	// We now have to update the trap-time esp with its new value
	movl %esp, 0x30(%ebp)
  803226:	89 65 30             	mov    %esp,0x30(%ebp)

	// Go back to our exception stack
	movl %ebp, %esp
  803229:	89 ec                	mov    %ebp,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// Pop fault_va and err, both can be ignored
	popl %eax
  80322b:	58                   	pop    %eax
	popl %eax
  80322c:	58                   	pop    %eax

	// Pop all registers back
	popal
  80322d:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// Skip %eip
	addl $0x4, %esp
  80322e:	83 c4 04             	add    $0x4,%esp

	// Pop eflags back
	popfl
  803231:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	
	popl %esp
  803232:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  803233:	c3                   	ret    

00803234 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  803234:	55                   	push   %ebp
  803235:	89 e5                	mov    %esp,%ebp
  803237:	56                   	push   %esi
  803238:	53                   	push   %ebx
  803239:	83 ec 10             	sub    $0x10,%esp
  80323c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80323f:	8b 45 0c             	mov    0xc(%ebp),%eax
  803242:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int r;
		
	r = sys_ipc_recv(pg?pg:(void*)UTOP);
  803245:	85 c0                	test   %eax,%eax
  803247:	75 05                	jne    80324e <ipc_recv+0x1a>
  803249:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80324e:	89 04 24             	mov    %eax,(%esp)
  803251:	e8 6d e5 ff ff       	call   8017c3 <sys_ipc_recv>
	if (from_env_store != NULL)
  803256:	85 db                	test   %ebx,%ebx
  803258:	74 0b                	je     803265 <ipc_recv+0x31>
		*from_env_store = thisenv->env_ipc_from; 
  80325a:	8b 15 24 54 80 00    	mov    0x805424,%edx
  803260:	8b 52 74             	mov    0x74(%edx),%edx
  803263:	89 13                	mov    %edx,(%ebx)
	if (perm_store != NULL)
  803265:	85 f6                	test   %esi,%esi
  803267:	74 0b                	je     803274 <ipc_recv+0x40>
		*perm_store = thisenv->env_ipc_perm;
  803269:	8b 15 24 54 80 00    	mov    0x805424,%edx
  80326f:	8b 52 78             	mov    0x78(%edx),%edx
  803272:	89 16                	mov    %edx,(%esi)
	
	if (r < 0){
  803274:	85 c0                	test   %eax,%eax
  803276:	79 16                	jns    80328e <ipc_recv+0x5a>
		if(from_env_store != NULL)
  803278:	85 db                	test   %ebx,%ebx
  80327a:	74 06                	je     803282 <ipc_recv+0x4e>
			*from_env_store = 0;
  80327c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store != NULL)	
  803282:	85 f6                	test   %esi,%esi
  803284:	74 10                	je     803296 <ipc_recv+0x62>
			*perm_store = 0;
  803286:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80328c:	eb 08                	jmp    803296 <ipc_recv+0x62>
		return r;
	}
	
	return thisenv->env_ipc_value;
  80328e:	a1 24 54 80 00       	mov    0x805424,%eax
  803293:	8b 40 70             	mov    0x70(%eax),%eax
}
  803296:	83 c4 10             	add    $0x10,%esp
  803299:	5b                   	pop    %ebx
  80329a:	5e                   	pop    %esi
  80329b:	5d                   	pop    %ebp
  80329c:	c3                   	ret    

0080329d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80329d:	55                   	push   %ebp
  80329e:	89 e5                	mov    %esp,%ebp
  8032a0:	57                   	push   %edi
  8032a1:	56                   	push   %esi
  8032a2:	53                   	push   %ebx
  8032a3:	83 ec 1c             	sub    $0x1c,%esp
  8032a6:	8b 75 08             	mov    0x8(%ebp),%esi
  8032a9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8032ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  8032af:	eb 2a                	jmp    8032db <ipc_send+0x3e>
		if (r != -E_IPC_NOT_RECV)
  8032b1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8032b4:	74 20                	je     8032d6 <ipc_send+0x39>
			panic("ipc_send: sys_ipc_try_send failed %e", r);
  8032b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8032ba:	c7 44 24 08 4c 3e 80 	movl   $0x803e4c,0x8(%esp)
  8032c1:	00 
  8032c2:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  8032c9:	00 
  8032ca:	c7 04 24 74 3e 80 00 	movl   $0x803e74,(%esp)
  8032d1:	e8 62 d7 ff ff       	call   800a38 <_panic>
		sys_yield();
  8032d6:	e8 b3 e2 ff ff       	call   80158e <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  8032db:	85 db                	test   %ebx,%ebx
  8032dd:	75 07                	jne    8032e6 <ipc_send+0x49>
  8032df:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8032e4:	eb 02                	jmp    8032e8 <ipc_send+0x4b>
  8032e6:	89 d8                	mov    %ebx,%eax
  8032e8:	8b 55 14             	mov    0x14(%ebp),%edx
  8032eb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8032ef:	89 44 24 08          	mov    %eax,0x8(%esp)
  8032f3:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8032f7:	89 34 24             	mov    %esi,(%esp)
  8032fa:	e8 a1 e4 ff ff       	call   8017a0 <sys_ipc_try_send>
  8032ff:	85 c0                	test   %eax,%eax
  803301:	78 ae                	js     8032b1 <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: sys_ipc_try_send failed %e", r);
		sys_yield();
	}
}
  803303:	83 c4 1c             	add    $0x1c,%esp
  803306:	5b                   	pop    %ebx
  803307:	5e                   	pop    %esi
  803308:	5f                   	pop    %edi
  803309:	5d                   	pop    %ebp
  80330a:	c3                   	ret    

0080330b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80330b:	55                   	push   %ebp
  80330c:	89 e5                	mov    %esp,%ebp
  80330e:	53                   	push   %ebx
  80330f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  803312:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  803317:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  80331e:	89 c2                	mov    %eax,%edx
  803320:	c1 e2 07             	shl    $0x7,%edx
  803323:	29 ca                	sub    %ecx,%edx
  803325:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80332b:	8b 52 50             	mov    0x50(%edx),%edx
  80332e:	39 da                	cmp    %ebx,%edx
  803330:	75 0f                	jne    803341 <ipc_find_env+0x36>
			return envs[i].env_id;
  803332:	c1 e0 07             	shl    $0x7,%eax
  803335:	29 c8                	sub    %ecx,%eax
  803337:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  80333c:	8b 40 40             	mov    0x40(%eax),%eax
  80333f:	eb 0c                	jmp    80334d <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  803341:	40                   	inc    %eax
  803342:	3d 00 04 00 00       	cmp    $0x400,%eax
  803347:	75 ce                	jne    803317 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  803349:	66 b8 00 00          	mov    $0x0,%ax
}
  80334d:	5b                   	pop    %ebx
  80334e:	5d                   	pop    %ebp
  80334f:	c3                   	ret    

00803350 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  803350:	55                   	push   %ebp
  803351:	89 e5                	mov    %esp,%ebp
  803353:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  803356:	89 c2                	mov    %eax,%edx
  803358:	c1 ea 16             	shr    $0x16,%edx
  80335b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  803362:	f6 c2 01             	test   $0x1,%dl
  803365:	74 1e                	je     803385 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  803367:	c1 e8 0c             	shr    $0xc,%eax
  80336a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  803371:	a8 01                	test   $0x1,%al
  803373:	74 17                	je     80338c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  803375:	c1 e8 0c             	shr    $0xc,%eax
  803378:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80337f:	ef 
  803380:	0f b7 c0             	movzwl %ax,%eax
  803383:	eb 0c                	jmp    803391 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  803385:	b8 00 00 00 00       	mov    $0x0,%eax
  80338a:	eb 05                	jmp    803391 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  80338c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  803391:	5d                   	pop    %ebp
  803392:	c3                   	ret    
	...

00803394 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  803394:	55                   	push   %ebp
  803395:	57                   	push   %edi
  803396:	56                   	push   %esi
  803397:	83 ec 10             	sub    $0x10,%esp
  80339a:	8b 74 24 20          	mov    0x20(%esp),%esi
  80339e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8033a2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8033a6:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  8033aa:	89 cd                	mov    %ecx,%ebp
  8033ac:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8033b0:	85 c0                	test   %eax,%eax
  8033b2:	75 2c                	jne    8033e0 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8033b4:	39 f9                	cmp    %edi,%ecx
  8033b6:	77 68                	ja     803420 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8033b8:	85 c9                	test   %ecx,%ecx
  8033ba:	75 0b                	jne    8033c7 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8033bc:	b8 01 00 00 00       	mov    $0x1,%eax
  8033c1:	31 d2                	xor    %edx,%edx
  8033c3:	f7 f1                	div    %ecx
  8033c5:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8033c7:	31 d2                	xor    %edx,%edx
  8033c9:	89 f8                	mov    %edi,%eax
  8033cb:	f7 f1                	div    %ecx
  8033cd:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8033cf:	89 f0                	mov    %esi,%eax
  8033d1:	f7 f1                	div    %ecx
  8033d3:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8033d5:	89 f0                	mov    %esi,%eax
  8033d7:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8033d9:	83 c4 10             	add    $0x10,%esp
  8033dc:	5e                   	pop    %esi
  8033dd:	5f                   	pop    %edi
  8033de:	5d                   	pop    %ebp
  8033df:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8033e0:	39 f8                	cmp    %edi,%eax
  8033e2:	77 2c                	ja     803410 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8033e4:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  8033e7:	83 f6 1f             	xor    $0x1f,%esi
  8033ea:	75 4c                	jne    803438 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8033ec:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8033ee:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8033f3:	72 0a                	jb     8033ff <__udivdi3+0x6b>
  8033f5:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8033f9:	0f 87 ad 00 00 00    	ja     8034ac <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8033ff:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  803404:	89 f0                	mov    %esi,%eax
  803406:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  803408:	83 c4 10             	add    $0x10,%esp
  80340b:	5e                   	pop    %esi
  80340c:	5f                   	pop    %edi
  80340d:	5d                   	pop    %ebp
  80340e:	c3                   	ret    
  80340f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  803410:	31 ff                	xor    %edi,%edi
  803412:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  803414:	89 f0                	mov    %esi,%eax
  803416:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  803418:	83 c4 10             	add    $0x10,%esp
  80341b:	5e                   	pop    %esi
  80341c:	5f                   	pop    %edi
  80341d:	5d                   	pop    %ebp
  80341e:	c3                   	ret    
  80341f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  803420:	89 fa                	mov    %edi,%edx
  803422:	89 f0                	mov    %esi,%eax
  803424:	f7 f1                	div    %ecx
  803426:	89 c6                	mov    %eax,%esi
  803428:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80342a:	89 f0                	mov    %esi,%eax
  80342c:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80342e:	83 c4 10             	add    $0x10,%esp
  803431:	5e                   	pop    %esi
  803432:	5f                   	pop    %edi
  803433:	5d                   	pop    %ebp
  803434:	c3                   	ret    
  803435:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  803438:	89 f1                	mov    %esi,%ecx
  80343a:	d3 e0                	shl    %cl,%eax
  80343c:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  803440:	b8 20 00 00 00       	mov    $0x20,%eax
  803445:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  803447:	89 ea                	mov    %ebp,%edx
  803449:	88 c1                	mov    %al,%cl
  80344b:	d3 ea                	shr    %cl,%edx
  80344d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  803451:	09 ca                	or     %ecx,%edx
  803453:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  803457:	89 f1                	mov    %esi,%ecx
  803459:	d3 e5                	shl    %cl,%ebp
  80345b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  80345f:	89 fd                	mov    %edi,%ebp
  803461:	88 c1                	mov    %al,%cl
  803463:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  803465:	89 fa                	mov    %edi,%edx
  803467:	89 f1                	mov    %esi,%ecx
  803469:	d3 e2                	shl    %cl,%edx
  80346b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80346f:	88 c1                	mov    %al,%cl
  803471:	d3 ef                	shr    %cl,%edi
  803473:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  803475:	89 f8                	mov    %edi,%eax
  803477:	89 ea                	mov    %ebp,%edx
  803479:	f7 74 24 08          	divl   0x8(%esp)
  80347d:	89 d1                	mov    %edx,%ecx
  80347f:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  803481:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  803485:	39 d1                	cmp    %edx,%ecx
  803487:	72 17                	jb     8034a0 <__udivdi3+0x10c>
  803489:	74 09                	je     803494 <__udivdi3+0x100>
  80348b:	89 fe                	mov    %edi,%esi
  80348d:	31 ff                	xor    %edi,%edi
  80348f:	e9 41 ff ff ff       	jmp    8033d5 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  803494:	8b 54 24 04          	mov    0x4(%esp),%edx
  803498:	89 f1                	mov    %esi,%ecx
  80349a:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80349c:	39 c2                	cmp    %eax,%edx
  80349e:	73 eb                	jae    80348b <__udivdi3+0xf7>
		{
		  q0--;
  8034a0:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8034a3:	31 ff                	xor    %edi,%edi
  8034a5:	e9 2b ff ff ff       	jmp    8033d5 <__udivdi3+0x41>
  8034aa:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8034ac:	31 f6                	xor    %esi,%esi
  8034ae:	e9 22 ff ff ff       	jmp    8033d5 <__udivdi3+0x41>
	...

008034b4 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8034b4:	55                   	push   %ebp
  8034b5:	57                   	push   %edi
  8034b6:	56                   	push   %esi
  8034b7:	83 ec 20             	sub    $0x20,%esp
  8034ba:	8b 44 24 30          	mov    0x30(%esp),%eax
  8034be:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8034c2:	89 44 24 14          	mov    %eax,0x14(%esp)
  8034c6:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  8034ca:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8034ce:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8034d2:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  8034d4:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8034d6:	85 ed                	test   %ebp,%ebp
  8034d8:	75 16                	jne    8034f0 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  8034da:	39 f1                	cmp    %esi,%ecx
  8034dc:	0f 86 a6 00 00 00    	jbe    803588 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8034e2:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8034e4:	89 d0                	mov    %edx,%eax
  8034e6:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8034e8:	83 c4 20             	add    $0x20,%esp
  8034eb:	5e                   	pop    %esi
  8034ec:	5f                   	pop    %edi
  8034ed:	5d                   	pop    %ebp
  8034ee:	c3                   	ret    
  8034ef:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8034f0:	39 f5                	cmp    %esi,%ebp
  8034f2:	0f 87 ac 00 00 00    	ja     8035a4 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8034f8:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  8034fb:	83 f0 1f             	xor    $0x1f,%eax
  8034fe:	89 44 24 10          	mov    %eax,0x10(%esp)
  803502:	0f 84 a8 00 00 00    	je     8035b0 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  803508:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80350c:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80350e:	bf 20 00 00 00       	mov    $0x20,%edi
  803513:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  803517:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80351b:	89 f9                	mov    %edi,%ecx
  80351d:	d3 e8                	shr    %cl,%eax
  80351f:	09 e8                	or     %ebp,%eax
  803521:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  803525:	8b 44 24 0c          	mov    0xc(%esp),%eax
  803529:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80352d:	d3 e0                	shl    %cl,%eax
  80352f:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  803533:	89 f2                	mov    %esi,%edx
  803535:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  803537:	8b 44 24 14          	mov    0x14(%esp),%eax
  80353b:	d3 e0                	shl    %cl,%eax
  80353d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  803541:	8b 44 24 14          	mov    0x14(%esp),%eax
  803545:	89 f9                	mov    %edi,%ecx
  803547:	d3 e8                	shr    %cl,%eax
  803549:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80354b:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80354d:	89 f2                	mov    %esi,%edx
  80354f:	f7 74 24 18          	divl   0x18(%esp)
  803553:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  803555:	f7 64 24 0c          	mull   0xc(%esp)
  803559:	89 c5                	mov    %eax,%ebp
  80355b:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80355d:	39 d6                	cmp    %edx,%esi
  80355f:	72 67                	jb     8035c8 <__umoddi3+0x114>
  803561:	74 75                	je     8035d8 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  803563:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  803567:	29 e8                	sub    %ebp,%eax
  803569:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80356b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80356f:	d3 e8                	shr    %cl,%eax
  803571:	89 f2                	mov    %esi,%edx
  803573:	89 f9                	mov    %edi,%ecx
  803575:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  803577:	09 d0                	or     %edx,%eax
  803579:	89 f2                	mov    %esi,%edx
  80357b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80357f:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  803581:	83 c4 20             	add    $0x20,%esp
  803584:	5e                   	pop    %esi
  803585:	5f                   	pop    %edi
  803586:	5d                   	pop    %ebp
  803587:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  803588:	85 c9                	test   %ecx,%ecx
  80358a:	75 0b                	jne    803597 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80358c:	b8 01 00 00 00       	mov    $0x1,%eax
  803591:	31 d2                	xor    %edx,%edx
  803593:	f7 f1                	div    %ecx
  803595:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  803597:	89 f0                	mov    %esi,%eax
  803599:	31 d2                	xor    %edx,%edx
  80359b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80359d:	89 f8                	mov    %edi,%eax
  80359f:	e9 3e ff ff ff       	jmp    8034e2 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8035a4:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8035a6:	83 c4 20             	add    $0x20,%esp
  8035a9:	5e                   	pop    %esi
  8035aa:	5f                   	pop    %edi
  8035ab:	5d                   	pop    %ebp
  8035ac:	c3                   	ret    
  8035ad:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8035b0:	39 f5                	cmp    %esi,%ebp
  8035b2:	72 04                	jb     8035b8 <__umoddi3+0x104>
  8035b4:	39 f9                	cmp    %edi,%ecx
  8035b6:	77 06                	ja     8035be <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8035b8:	89 f2                	mov    %esi,%edx
  8035ba:	29 cf                	sub    %ecx,%edi
  8035bc:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8035be:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8035c0:	83 c4 20             	add    $0x20,%esp
  8035c3:	5e                   	pop    %esi
  8035c4:	5f                   	pop    %edi
  8035c5:	5d                   	pop    %ebp
  8035c6:	c3                   	ret    
  8035c7:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8035c8:	89 d1                	mov    %edx,%ecx
  8035ca:	89 c5                	mov    %eax,%ebp
  8035cc:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8035d0:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8035d4:	eb 8d                	jmp    803563 <__umoddi3+0xaf>
  8035d6:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8035d8:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8035dc:	72 ea                	jb     8035c8 <__umoddi3+0x114>
  8035de:	89 f1                	mov    %esi,%ecx
  8035e0:	eb 81                	jmp    803563 <__umoddi3+0xaf>
