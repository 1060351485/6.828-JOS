
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
  800047:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  80004e:	0f 8e 19 01 00 00    	jle    80016d <_gettoken+0x139>
			cprintf("GETTOKEN NULL\n");
  800054:	c7 04 24 40 3b 80 00 	movl   $0x803b40,(%esp)
  80005b:	e8 c4 0a 00 00       	call   800b24 <cprintf>
  800060:	e9 1b 01 00 00       	jmp    800180 <_gettoken+0x14c>
		return 0;
	}

	if (debug > 1)
  800065:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  80006c:	7e 10                	jle    80007e <_gettoken+0x4a>
		cprintf("GETTOKEN: %s\n", s);
  80006e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800072:	c7 04 24 4f 3b 80 00 	movl   $0x803b4f,(%esp)
  800079:	e8 a6 0a 00 00       	call   800b24 <cprintf>

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
  80009a:	c7 04 24 5d 3b 80 00 	movl   $0x803b5d,(%esp)
  8000a1:	e8 03 12 00 00       	call   8012a9 <strchr>
  8000a6:	85 c0                	test   %eax,%eax
  8000a8:	75 e5                	jne    80008f <_gettoken+0x5b>
  8000aa:	89 de                	mov    %ebx,%esi
		*s++ = 0;
	if (*s == 0) {
  8000ac:	8a 03                	mov    (%ebx),%al
  8000ae:	84 c0                	test   %al,%al
  8000b0:	75 23                	jne    8000d5 <_gettoken+0xa1>
		if (debug > 1)
  8000b2:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  8000b9:	0f 8e b5 00 00 00    	jle    800174 <_gettoken+0x140>
			cprintf("EOL\n");
  8000bf:	c7 04 24 62 3b 80 00 	movl   $0x803b62,(%esp)
  8000c6:	e8 59 0a 00 00       	call   800b24 <cprintf>
		return 0;
  8000cb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8000d0:	e9 ab 00 00 00       	jmp    800180 <_gettoken+0x14c>
	}
	if (strchr(SYMBOLS, *s)) {
  8000d5:	0f be c0             	movsbl %al,%eax
  8000d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000dc:	c7 04 24 73 3b 80 00 	movl   $0x803b73,(%esp)
  8000e3:	e8 c1 11 00 00       	call   8012a9 <strchr>
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
  8000fa:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800101:	7e 7d                	jle    800180 <_gettoken+0x14c>
			cprintf("TOK %c\n", t);
  800103:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800107:	c7 04 24 67 3b 80 00 	movl   $0x803b67,(%esp)
  80010e:	e8 11 0a 00 00       	call   800b24 <cprintf>
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
  800127:	c7 04 24 6f 3b 80 00 	movl   $0x803b6f,(%esp)
  80012e:	e8 76 11 00 00       	call   8012a9 <strchr>
  800133:	85 c0                	test   %eax,%eax
  800135:	74 e2                	je     800119 <_gettoken+0xe5>
		s++;
	*p2 = s;
  800137:	8b 45 10             	mov    0x10(%ebp),%eax
  80013a:	89 18                	mov    %ebx,(%eax)
	if (debug > 1) {
  80013c:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800143:	7e 36                	jle    80017b <_gettoken+0x147>
		t = **p2;
  800145:	0f b6 33             	movzbl (%ebx),%esi
		**p2 = 0;
  800148:	c6 03 00             	movb   $0x0,(%ebx)
		cprintf("WORD: %s\n", *p1);
  80014b:	8b 07                	mov    (%edi),%eax
  80014d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800151:	c7 04 24 7b 3b 80 00 	movl   $0x803b7b,(%esp)
  800158:	e8 c7 09 00 00       	call   800b24 <cprintf>
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
  800197:	c7 44 24 08 04 60 80 	movl   $0x806004,0x8(%esp)
  80019e:	00 
  80019f:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  8001a6:	00 
  8001a7:	89 04 24             	mov    %eax,(%esp)
  8001aa:	e8 85 fe ff ff       	call   800034 <_gettoken>
  8001af:	a3 08 60 80 00       	mov    %eax,0x806008
		return 0;
  8001b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8001b9:	eb 3c                	jmp    8001f7 <gettoken+0x6d>
	}
	c = nc;
  8001bb:	a1 08 60 80 00       	mov    0x806008,%eax
  8001c0:	a3 0c 60 80 00       	mov    %eax,0x80600c
	*p1 = np1;
  8001c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001c8:	8b 15 00 60 80 00    	mov    0x806000,%edx
  8001ce:	89 10                	mov    %edx,(%eax)
	nc = _gettoken(np2, &np1, &np2);
  8001d0:	c7 44 24 08 04 60 80 	movl   $0x806004,0x8(%esp)
  8001d7:	00 
  8001d8:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  8001df:	00 
  8001e0:	a1 04 60 80 00       	mov    0x806004,%eax
  8001e5:	89 04 24             	mov    %eax,(%esp)
  8001e8:	e8 47 fe ff ff       	call   800034 <_gettoken>
  8001ed:	a3 08 60 80 00       	mov    %eax,0x806008
	return c;
  8001f2:	a1 0c 60 80 00       	mov    0x80600c,%eax
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
  800268:	c7 04 24 85 3b 80 00 	movl   $0x803b85,(%esp)
  80026f:	e8 b0 08 00 00       	call   800b24 <cprintf>
				exit();
  800274:	e8 9f 07 00 00       	call   800a18 <exit>
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
  800298:	c7 04 24 d8 3c 80 00 	movl   $0x803cd8,(%esp)
  80029f:	e8 80 08 00 00       	call   800b24 <cprintf>
				exit();
  8002a4:	e8 6f 07 00 00       	call   800a18 <exit>
			// If not, dup 'fd' onto file descriptor 0,
			// then close the original 'fd'.

			// LAB 5: Your code here.
			//panic("< redirection not implemented");
			if ((fd = open(t, O_RDONLY)) < 0) {
  8002a9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8002b0:	00 
  8002b1:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  8002b4:	89 04 24             	mov    %eax,(%esp)
  8002b7:	e8 18 23 00 00       	call   8025d4 <open>
  8002bc:	89 c7                	mov    %eax,%edi
  8002be:	85 c0                	test   %eax,%eax
  8002c0:	79 1e                	jns    8002e0 <runcmd+0xe7>
				cprintf("open %s for read: %e", t, fd);
  8002c2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c6:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  8002c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002cd:	c7 04 24 99 3b 80 00 	movl   $0x803b99,(%esp)
  8002d4:	e8 4b 08 00 00       	call   800b24 <cprintf>
				exit();
  8002d9:	e8 3a 07 00 00       	call   800a18 <exit>
  8002de:	eb 08                	jmp    8002e8 <runcmd+0xef>
			}
			if (fd != 0) {
  8002e0:	85 c0                	test   %eax,%eax
  8002e2:	0f 84 38 ff ff ff    	je     800220 <runcmd+0x27>
				dup(fd, 0);
  8002e8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8002ef:	00 
  8002f0:	89 3c 24             	mov    %edi,(%esp)
  8002f3:	e8 f3 1c 00 00       	call   801feb <dup>
				close(fd);
  8002f8:	89 3c 24             	mov    %edi,(%esp)
  8002fb:	e8 9a 1c 00 00       	call   801f9a <close>
  800300:	e9 1b ff ff ff       	jmp    800220 <runcmd+0x27>
			}
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
  80031a:	c7 04 24 00 3d 80 00 	movl   $0x803d00,(%esp)
  800321:	e8 fe 07 00 00       	call   800b24 <cprintf>
				exit();
  800326:	e8 ed 06 00 00       	call   800a18 <exit>
			}
			if ((fd = open(t, O_WRONLY|O_CREAT|O_TRUNC)) < 0) {
  80032b:	c7 44 24 04 01 03 00 	movl   $0x301,0x4(%esp)
  800332:	00 
  800333:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  800336:	89 04 24             	mov    %eax,(%esp)
  800339:	e8 96 22 00 00       	call   8025d4 <open>
  80033e:	89 c7                	mov    %eax,%edi
  800340:	85 c0                	test   %eax,%eax
  800342:	79 1c                	jns    800360 <runcmd+0x167>
				cprintf("open %s for write: %e", t, fd);
  800344:	89 44 24 08          	mov    %eax,0x8(%esp)
  800348:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  80034b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80034f:	c7 04 24 ae 3b 80 00 	movl   $0x803bae,(%esp)
  800356:	e8 c9 07 00 00       	call   800b24 <cprintf>
				exit();
  80035b:	e8 b8 06 00 00       	call   800a18 <exit>
			}
			if (fd != 1) {
  800360:	83 ff 01             	cmp    $0x1,%edi
  800363:	0f 84 b7 fe ff ff    	je     800220 <runcmd+0x27>
				dup(fd, 1);
  800369:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800370:	00 
  800371:	89 3c 24             	mov    %edi,(%esp)
  800374:	e8 72 1c 00 00       	call   801feb <dup>
				close(fd);
  800379:	89 3c 24             	mov    %edi,(%esp)
  80037c:	e8 19 1c 00 00       	call   801f9a <close>
  800381:	e9 9a fe ff ff       	jmp    800220 <runcmd+0x27>
			}
			break;

		case '|':	// Pipe
			if ((r = pipe(p)) < 0) {
  800386:	8d 85 9c fb ff ff    	lea    -0x464(%ebp),%eax
  80038c:	89 04 24             	mov    %eax,(%esp)
  80038f:	e8 59 31 00 00       	call   8034ed <pipe>
  800394:	85 c0                	test   %eax,%eax
  800396:	79 15                	jns    8003ad <runcmd+0x1b4>
				cprintf("pipe: %e", r);
  800398:	89 44 24 04          	mov    %eax,0x4(%esp)
  80039c:	c7 04 24 c4 3b 80 00 	movl   $0x803bc4,(%esp)
  8003a3:	e8 7c 07 00 00       	call   800b24 <cprintf>
				exit();
  8003a8:	e8 6b 06 00 00       	call   800a18 <exit>
			}
			if (debug)
  8003ad:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8003b4:	74 20                	je     8003d6 <runcmd+0x1dd>
				cprintf("PIPE: %d %d\n", p[0], p[1]);
  8003b6:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  8003bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003c0:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  8003c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ca:	c7 04 24 cd 3b 80 00 	movl   $0x803bcd,(%esp)
  8003d1:	e8 4e 07 00 00       	call   800b24 <cprintf>
			if ((r = fork()) < 0) {
  8003d6:	e8 c0 15 00 00       	call   80199b <fork>
  8003db:	89 c7                	mov    %eax,%edi
  8003dd:	85 c0                	test   %eax,%eax
  8003df:	79 15                	jns    8003f6 <runcmd+0x1fd>
				cprintf("fork: %e", r);
  8003e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003e5:	c7 04 24 da 3b 80 00 	movl   $0x803bda,(%esp)
  8003ec:	e8 33 07 00 00       	call   800b24 <cprintf>
				exit();
  8003f1:	e8 22 06 00 00       	call   800a18 <exit>
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
  80040f:	e8 d7 1b 00 00       	call   801feb <dup>
					close(p[0]);
  800414:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  80041a:	89 04 24             	mov    %eax,(%esp)
  80041d:	e8 78 1b 00 00       	call   801f9a <close>
				}
				close(p[1]);
  800422:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  800428:	89 04 24             	mov    %eax,(%esp)
  80042b:	e8 6a 1b 00 00       	call   801f9a <close>

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
  800450:	e8 96 1b 00 00       	call   801feb <dup>
					close(p[1]);
  800455:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  80045b:	89 04 24             	mov    %eax,(%esp)
  80045e:	e8 37 1b 00 00       	call   801f9a <close>
				}
				close(p[0]);
  800463:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  800469:	89 04 24             	mov    %eax,(%esp)
  80046c:	e8 29 1b 00 00       	call   801f9a <close>
				goto runit;
  800471:	eb 25                	jmp    800498 <runcmd+0x29f>
		case 0:		// String is complete
			// Run the current command!
			goto runit;

		default:
			panic("bad return %d from gettoken", c);
  800473:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800477:	c7 44 24 08 e3 3b 80 	movl   $0x803be3,0x8(%esp)
  80047e:	00 
  80047f:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
  800486:	00 
  800487:	c7 04 24 ff 3b 80 00 	movl   $0x803bff,(%esp)
  80048e:	e8 99 05 00 00       	call   800a2c <_panic>
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
  80049c:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8004a3:	0f 84 76 01 00 00    	je     80061f <runcmd+0x426>
			cprintf("EMPTY COMMAND\n");
  8004a9:	c7 04 24 09 3c 80 00 	movl   $0x803c09,(%esp)
  8004b0:	e8 6f 06 00 00       	call   800b24 <cprintf>
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
  8004dc:	e8 ce 0c 00 00       	call   8011af <strcpy>
		argv[0] = argv0buf;
  8004e1:	89 5d a8             	mov    %ebx,-0x58(%ebp)
	}
	argv[argc] = 0;
  8004e4:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
  8004eb:	00 

	// Print the command.
	if (debug) {
  8004ec:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8004f3:	74 43                	je     800538 <runcmd+0x33f>
		cprintf("[%08x] SPAWN:", thisenv->env_id);
  8004f5:	a1 28 64 80 00       	mov    0x806428,%eax
  8004fa:	8b 40 48             	mov    0x48(%eax),%eax
  8004fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800501:	c7 04 24 18 3c 80 00 	movl   $0x803c18,(%esp)
  800508:	e8 17 06 00 00       	call   800b24 <cprintf>
  80050d:	8d 5d a8             	lea    -0x58(%ebp),%ebx
		for (i = 0; argv[i]; i++)
  800510:	eb 10                	jmp    800522 <runcmd+0x329>
			cprintf(" %s", argv[i]);
  800512:	89 44 24 04          	mov    %eax,0x4(%esp)
  800516:	c7 04 24 a3 3c 80 00 	movl   $0x803ca3,(%esp)
  80051d:	e8 02 06 00 00       	call   800b24 <cprintf>
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
  80052c:	c7 04 24 60 3b 80 00 	movl   $0x803b60,(%esp)
  800533:	e8 ec 05 00 00       	call   800b24 <cprintf>
	}

	// Spawn the command!
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
  800538:	8d 45 a8             	lea    -0x58(%ebp),%eax
  80053b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80053f:	8b 45 a8             	mov    -0x58(%ebp),%eax
  800542:	89 04 24             	mov    %eax,(%esp)
  800545:	e8 62 22 00 00       	call   8027ac <spawn>
  80054a:	89 c3                	mov    %eax,%ebx
  80054c:	85 c0                	test   %eax,%eax
  80054e:	79 1e                	jns    80056e <runcmd+0x375>
		cprintf("spawn %s: %e\n", argv[0], r);
  800550:	89 44 24 08          	mov    %eax,0x8(%esp)
  800554:	8b 45 a8             	mov    -0x58(%ebp),%eax
  800557:	89 44 24 04          	mov    %eax,0x4(%esp)
  80055b:	c7 04 24 26 3c 80 00 	movl   $0x803c26,(%esp)
  800562:	e8 bd 05 00 00       	call   800b24 <cprintf>

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  800567:	e8 5f 1a 00 00       	call   801fcb <close_all>
  80056c:	eb 5a                	jmp    8005c8 <runcmd+0x3cf>
  80056e:	e8 58 1a 00 00       	call   801fcb <close_all>
	if (r >= 0) {
		if (debug)
  800573:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80057a:	74 23                	je     80059f <runcmd+0x3a6>
			cprintf("[%08x] WAIT %s %08x\n", thisenv->env_id, argv[0], r);
  80057c:	a1 28 64 80 00       	mov    0x806428,%eax
  800581:	8b 40 48             	mov    0x48(%eax),%eax
  800584:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800588:	8b 55 a8             	mov    -0x58(%ebp),%edx
  80058b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80058f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800593:	c7 04 24 34 3c 80 00 	movl   $0x803c34,(%esp)
  80059a:	e8 85 05 00 00       	call   800b24 <cprintf>
		wait(r);
  80059f:	89 1c 24             	mov    %ebx,(%esp)
  8005a2:	e8 e9 30 00 00       	call   803690 <wait>
		if (debug)
  8005a7:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005ae:	74 18                	je     8005c8 <runcmd+0x3cf>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005b0:	a1 28 64 80 00       	mov    0x806428,%eax
  8005b5:	8b 40 48             	mov    0x48(%eax),%eax
  8005b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005bc:	c7 04 24 49 3c 80 00 	movl   $0x803c49,(%esp)
  8005c3:	e8 5c 05 00 00       	call   800b24 <cprintf>
	}

	// If we were the left-hand part of a pipe,
	// wait for the right-hand part to finish.
	if (pipe_child) {
  8005c8:	85 ff                	test   %edi,%edi
  8005ca:	74 4e                	je     80061a <runcmd+0x421>
		if (debug)
  8005cc:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005d3:	74 1c                	je     8005f1 <runcmd+0x3f8>
			cprintf("[%08x] WAIT pipe_child %08x\n", thisenv->env_id, pipe_child);
  8005d5:	a1 28 64 80 00       	mov    0x806428,%eax
  8005da:	8b 40 48             	mov    0x48(%eax),%eax
  8005dd:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8005e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e5:	c7 04 24 5f 3c 80 00 	movl   $0x803c5f,(%esp)
  8005ec:	e8 33 05 00 00       	call   800b24 <cprintf>
		wait(pipe_child);
  8005f1:	89 3c 24             	mov    %edi,(%esp)
  8005f4:	e8 97 30 00 00       	call   803690 <wait>
		if (debug)
  8005f9:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800600:	74 18                	je     80061a <runcmd+0x421>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  800602:	a1 28 64 80 00       	mov    0x806428,%eax
  800607:	8b 40 48             	mov    0x48(%eax),%eax
  80060a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80060e:	c7 04 24 49 3c 80 00 	movl   $0x803c49,(%esp)
  800615:	e8 0a 05 00 00       	call   800b24 <cprintf>
	}

	// Done!
	exit();
  80061a:	e8 f9 03 00 00       	call   800a18 <exit>
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
  800630:	c7 04 24 28 3d 80 00 	movl   $0x803d28,(%esp)
  800637:	e8 e8 04 00 00       	call   800b24 <cprintf>
	exit();
  80063c:	e8 d7 03 00 00       	call   800a18 <exit>
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
  800660:	e8 27 16 00 00       	call   801c8c <argstart>
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
  80068e:	ff 05 00 50 80 00    	incl   0x805000
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
  8006a7:	e8 19 16 00 00       	call   801cc5 <argnext>
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
  8006ca:	e8 cb 18 00 00       	call   801f9a <close>
		if ((r = open(argv[1], O_RDONLY)) < 0)
  8006cf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8006d6:	00 
  8006d7:	8b 46 04             	mov    0x4(%esi),%eax
  8006da:	89 04 24             	mov    %eax,(%esp)
  8006dd:	e8 f2 1e 00 00       	call   8025d4 <open>
  8006e2:	85 c0                	test   %eax,%eax
  8006e4:	79 27                	jns    80070d <umain+0xca>
			panic("open %s: %e", argv[1], r);
  8006e6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006ea:	8b 46 04             	mov    0x4(%esi),%eax
  8006ed:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006f1:	c7 44 24 08 7f 3c 80 	movl   $0x803c7f,0x8(%esp)
  8006f8:	00 
  8006f9:	c7 44 24 04 27 01 00 	movl   $0x127,0x4(%esp)
  800700:	00 
  800701:	c7 04 24 ff 3b 80 00 	movl   $0x803bff,(%esp)
  800708:	e8 1f 03 00 00       	call   800a2c <_panic>
		assert(r == 0);
  80070d:	85 c0                	test   %eax,%eax
  80070f:	74 24                	je     800735 <umain+0xf2>
  800711:	c7 44 24 0c 8b 3c 80 	movl   $0x803c8b,0xc(%esp)
  800718:	00 
  800719:	c7 44 24 08 92 3c 80 	movl   $0x803c92,0x8(%esp)
  800720:	00 
  800721:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
  800728:	00 
  800729:	c7 04 24 ff 3b 80 00 	movl   $0x803bff,(%esp)
  800730:	e8 f7 02 00 00       	call   800a2c <_panic>
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
  80074c:	b8 7c 3c 80 00       	mov    $0x803c7c,%eax
  800751:	eb 05                	jmp    800758 <umain+0x115>
  800753:	b8 00 00 00 00       	mov    $0x0,%eax
  800758:	89 04 24             	mov    %eax,(%esp)
  80075b:	e8 3c 09 00 00       	call   80109c <readline>
  800760:	89 c3                	mov    %eax,%ebx
		if (buf == NULL) {
  800762:	85 c0                	test   %eax,%eax
  800764:	75 1a                	jne    800780 <umain+0x13d>
			if (debug)
  800766:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80076d:	74 0c                	je     80077b <umain+0x138>
				cprintf("EXITING\n");
  80076f:	c7 04 24 a7 3c 80 00 	movl   $0x803ca7,(%esp)
  800776:	e8 a9 03 00 00       	call   800b24 <cprintf>
			exit();	// end of file
  80077b:	e8 98 02 00 00       	call   800a18 <exit>
		}
		if (debug)
  800780:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800787:	74 10                	je     800799 <umain+0x156>
			cprintf("LINE: %s\n", buf);
  800789:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80078d:	c7 04 24 b0 3c 80 00 	movl   $0x803cb0,(%esp)
  800794:	e8 8b 03 00 00       	call   800b24 <cprintf>
		if (buf[0] == '#')
  800799:	80 3b 23             	cmpb   $0x23,(%ebx)
  80079c:	74 aa                	je     800748 <umain+0x105>
			continue;
		if (echocmds)
  80079e:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8007a2:	74 10                	je     8007b4 <umain+0x171>
			printf("# %s\n", buf);
  8007a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a8:	c7 04 24 ba 3c 80 00 	movl   $0x803cba,(%esp)
  8007af:	e8 d5 1f 00 00       	call   802789 <printf>
		if (debug)
  8007b4:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007bb:	74 0c                	je     8007c9 <umain+0x186>
			cprintf("BEFORE FORK\n");
  8007bd:	c7 04 24 c0 3c 80 00 	movl   $0x803cc0,(%esp)
  8007c4:	e8 5b 03 00 00       	call   800b24 <cprintf>
		if ((r = fork()) < 0)
  8007c9:	e8 cd 11 00 00       	call   80199b <fork>
  8007ce:	89 c6                	mov    %eax,%esi
  8007d0:	85 c0                	test   %eax,%eax
  8007d2:	79 20                	jns    8007f4 <umain+0x1b1>
			panic("fork: %e", r);
  8007d4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007d8:	c7 44 24 08 da 3b 80 	movl   $0x803bda,0x8(%esp)
  8007df:	00 
  8007e0:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
  8007e7:	00 
  8007e8:	c7 04 24 ff 3b 80 00 	movl   $0x803bff,(%esp)
  8007ef:	e8 38 02 00 00       	call   800a2c <_panic>
		if (debug)
  8007f4:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007fb:	74 10                	je     80080d <umain+0x1ca>
			cprintf("FORK: %d\n", r);
  8007fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800801:	c7 04 24 cd 3c 80 00 	movl   $0x803ccd,(%esp)
  800808:	e8 17 03 00 00       	call   800b24 <cprintf>
		if (r == 0) {
  80080d:	85 f6                	test   %esi,%esi
  80080f:	75 12                	jne    800823 <umain+0x1e0>
			runcmd(buf);
  800811:	89 1c 24             	mov    %ebx,(%esp)
  800814:	e8 e0 f9 ff ff       	call   8001f9 <runcmd>
			exit();
  800819:	e8 fa 01 00 00       	call   800a18 <exit>
  80081e:	e9 25 ff ff ff       	jmp    800748 <umain+0x105>
		} else
			wait(r);
  800823:	89 34 24             	mov    %esi,(%esp)
  800826:	e8 65 2e 00 00       	call   803690 <wait>
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
  800840:	c7 44 24 04 49 3d 80 	movl   $0x803d49,0x4(%esp)
  800847:	00 
  800848:	8b 45 0c             	mov    0xc(%ebp),%eax
  80084b:	89 04 24             	mov    %eax,(%esp)
  80084e:	e8 5c 09 00 00       	call   8011af <strcpy>
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
  800890:	e8 93 0a 00 00       	call   801328 <memmove>
		sys_cputs(buf, m);
  800895:	89 74 24 04          	mov    %esi,0x4(%esp)
  800899:	89 3c 24             	mov    %edi,(%esp)
  80089c:	e8 33 0c 00 00       	call   8014d4 <sys_cputs>
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
  8008c3:	e8 ba 0c 00 00       	call   801582 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8008c8:	e8 25 0c 00 00       	call   8014f2 <sys_cgetc>
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
  800910:	e8 bf 0b 00 00       	call   8014d4 <sys_cputs>
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
  800933:	e8 c6 17 00 00       	call   8020fe <read>
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
  800960:	e8 fd 14 00 00       	call   801e62 <fd_lookup>
  800965:	85 c0                	test   %eax,%eax
  800967:	78 11                	js     80097a <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800969:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80096c:	8b 15 04 50 80 00    	mov    0x805004,%edx
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
  800988:	e8 82 14 00 00       	call   801e0f <fd_alloc>
  80098d:	85 c0                	test   %eax,%eax
  80098f:	78 3c                	js     8009cd <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800991:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800998:	00 
  800999:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80099c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8009a7:	e8 f5 0b 00 00       	call   8015a1 <sys_page_alloc>
  8009ac:	85 c0                	test   %eax,%eax
  8009ae:	78 1d                	js     8009cd <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8009b0:	8b 15 04 50 80 00    	mov    0x805004,%edx
  8009b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009b9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8009bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009be:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8009c5:	89 04 24             	mov    %eax,(%esp)
  8009c8:	e8 17 14 00 00       	call   801de4 <fd2num>
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
  8009de:	e8 80 0b 00 00       	call   801563 <sys_getenvid>
  8009e3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8009e8:	c1 e0 07             	shl    $0x7,%eax
  8009eb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8009f0:	a3 28 64 80 00       	mov    %eax,0x806428

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8009f5:	85 f6                	test   %esi,%esi
  8009f7:	7e 07                	jle    800a00 <libmain+0x30>
		binaryname = argv[0];
  8009f9:	8b 03                	mov    (%ebx),%eax
  8009fb:	a3 20 50 80 00       	mov    %eax,0x805020

	// call user main routine
	umain(argc, argv);
  800a00:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a04:	89 34 24             	mov    %esi,(%esp)
  800a07:	e8 37 fc ff ff       	call   800643 <umain>

	// exit gracefully
	exit();
  800a0c:	e8 07 00 00 00       	call   800a18 <exit>
}
  800a11:	83 c4 10             	add    $0x10,%esp
  800a14:	5b                   	pop    %ebx
  800a15:	5e                   	pop    %esi
  800a16:	5d                   	pop    %ebp
  800a17:	c3                   	ret    

00800a18 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800a18:	55                   	push   %ebp
  800a19:	89 e5                	mov    %esp,%ebp
  800a1b:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  800a1e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a25:	e8 e7 0a 00 00       	call   801511 <sys_env_destroy>
}
  800a2a:	c9                   	leave  
  800a2b:	c3                   	ret    

00800a2c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800a2c:	55                   	push   %ebp
  800a2d:	89 e5                	mov    %esp,%ebp
  800a2f:	56                   	push   %esi
  800a30:	53                   	push   %ebx
  800a31:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800a34:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800a37:	8b 1d 20 50 80 00    	mov    0x805020,%ebx
  800a3d:	e8 21 0b 00 00       	call   801563 <sys_getenvid>
  800a42:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a45:	89 54 24 10          	mov    %edx,0x10(%esp)
  800a49:	8b 55 08             	mov    0x8(%ebp),%edx
  800a4c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a50:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800a54:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a58:	c7 04 24 60 3d 80 00 	movl   $0x803d60,(%esp)
  800a5f:	e8 c0 00 00 00       	call   800b24 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800a64:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a68:	8b 45 10             	mov    0x10(%ebp),%eax
  800a6b:	89 04 24             	mov    %eax,(%esp)
  800a6e:	e8 50 00 00 00       	call   800ac3 <vcprintf>
	cprintf("\n");
  800a73:	c7 04 24 60 3b 80 00 	movl   $0x803b60,(%esp)
  800a7a:	e8 a5 00 00 00       	call   800b24 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800a7f:	cc                   	int3   
  800a80:	eb fd                	jmp    800a7f <_panic+0x53>
	...

00800a84 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	53                   	push   %ebx
  800a88:	83 ec 14             	sub    $0x14,%esp
  800a8b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800a8e:	8b 03                	mov    (%ebx),%eax
  800a90:	8b 55 08             	mov    0x8(%ebp),%edx
  800a93:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800a97:	40                   	inc    %eax
  800a98:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800a9a:	3d ff 00 00 00       	cmp    $0xff,%eax
  800a9f:	75 19                	jne    800aba <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800aa1:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800aa8:	00 
  800aa9:	8d 43 08             	lea    0x8(%ebx),%eax
  800aac:	89 04 24             	mov    %eax,(%esp)
  800aaf:	e8 20 0a 00 00       	call   8014d4 <sys_cputs>
		b->idx = 0;
  800ab4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800aba:	ff 43 04             	incl   0x4(%ebx)
}
  800abd:	83 c4 14             	add    $0x14,%esp
  800ac0:	5b                   	pop    %ebx
  800ac1:	5d                   	pop    %ebp
  800ac2:	c3                   	ret    

00800ac3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800ac3:	55                   	push   %ebp
  800ac4:	89 e5                	mov    %esp,%ebp
  800ac6:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800acc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800ad3:	00 00 00 
	b.cnt = 0;
  800ad6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800add:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800ae0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ae7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aea:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aee:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800af4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800af8:	c7 04 24 84 0a 80 00 	movl   $0x800a84,(%esp)
  800aff:	e8 82 01 00 00       	call   800c86 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800b04:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800b0a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b0e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800b14:	89 04 24             	mov    %eax,(%esp)
  800b17:	e8 b8 09 00 00       	call   8014d4 <sys_cputs>

	return b.cnt;
}
  800b1c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800b22:	c9                   	leave  
  800b23:	c3                   	ret    

00800b24 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
  800b27:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800b2a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800b2d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b31:	8b 45 08             	mov    0x8(%ebp),%eax
  800b34:	89 04 24             	mov    %eax,(%esp)
  800b37:	e8 87 ff ff ff       	call   800ac3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800b3c:	c9                   	leave  
  800b3d:	c3                   	ret    
	...

00800b40 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	57                   	push   %edi
  800b44:	56                   	push   %esi
  800b45:	53                   	push   %ebx
  800b46:	83 ec 3c             	sub    $0x3c,%esp
  800b49:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b4c:	89 d7                	mov    %edx,%edi
  800b4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b51:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800b54:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b57:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b5a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800b5d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800b60:	85 c0                	test   %eax,%eax
  800b62:	75 08                	jne    800b6c <printnum+0x2c>
  800b64:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800b67:	39 45 10             	cmp    %eax,0x10(%ebp)
  800b6a:	77 57                	ja     800bc3 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800b6c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800b70:	4b                   	dec    %ebx
  800b71:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800b75:	8b 45 10             	mov    0x10(%ebp),%eax
  800b78:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b7c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800b80:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800b84:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800b8b:	00 
  800b8c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800b8f:	89 04 24             	mov    %eax,(%esp)
  800b92:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800b95:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b99:	e8 3e 2d 00 00       	call   8038dc <__udivdi3>
  800b9e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ba2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800ba6:	89 04 24             	mov    %eax,(%esp)
  800ba9:	89 54 24 04          	mov    %edx,0x4(%esp)
  800bad:	89 fa                	mov    %edi,%edx
  800baf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800bb2:	e8 89 ff ff ff       	call   800b40 <printnum>
  800bb7:	eb 0f                	jmp    800bc8 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800bb9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bbd:	89 34 24             	mov    %esi,(%esp)
  800bc0:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800bc3:	4b                   	dec    %ebx
  800bc4:	85 db                	test   %ebx,%ebx
  800bc6:	7f f1                	jg     800bb9 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800bc8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bcc:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800bd0:	8b 45 10             	mov    0x10(%ebp),%eax
  800bd3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bd7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800bde:	00 
  800bdf:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800be2:	89 04 24             	mov    %eax,(%esp)
  800be5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800be8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bec:	e8 0b 2e 00 00       	call   8039fc <__umoddi3>
  800bf1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bf5:	0f be 80 83 3d 80 00 	movsbl 0x803d83(%eax),%eax
  800bfc:	89 04 24             	mov    %eax,(%esp)
  800bff:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800c02:	83 c4 3c             	add    $0x3c,%esp
  800c05:	5b                   	pop    %ebx
  800c06:	5e                   	pop    %esi
  800c07:	5f                   	pop    %edi
  800c08:	5d                   	pop    %ebp
  800c09:	c3                   	ret    

00800c0a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800c0d:	83 fa 01             	cmp    $0x1,%edx
  800c10:	7e 0e                	jle    800c20 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800c12:	8b 10                	mov    (%eax),%edx
  800c14:	8d 4a 08             	lea    0x8(%edx),%ecx
  800c17:	89 08                	mov    %ecx,(%eax)
  800c19:	8b 02                	mov    (%edx),%eax
  800c1b:	8b 52 04             	mov    0x4(%edx),%edx
  800c1e:	eb 22                	jmp    800c42 <getuint+0x38>
	else if (lflag)
  800c20:	85 d2                	test   %edx,%edx
  800c22:	74 10                	je     800c34 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800c24:	8b 10                	mov    (%eax),%edx
  800c26:	8d 4a 04             	lea    0x4(%edx),%ecx
  800c29:	89 08                	mov    %ecx,(%eax)
  800c2b:	8b 02                	mov    (%edx),%eax
  800c2d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c32:	eb 0e                	jmp    800c42 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800c34:	8b 10                	mov    (%eax),%edx
  800c36:	8d 4a 04             	lea    0x4(%edx),%ecx
  800c39:	89 08                	mov    %ecx,(%eax)
  800c3b:	8b 02                	mov    (%edx),%eax
  800c3d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800c42:	5d                   	pop    %ebp
  800c43:	c3                   	ret    

00800c44 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800c4a:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800c4d:	8b 10                	mov    (%eax),%edx
  800c4f:	3b 50 04             	cmp    0x4(%eax),%edx
  800c52:	73 08                	jae    800c5c <sprintputch+0x18>
		*b->buf++ = ch;
  800c54:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c57:	88 0a                	mov    %cl,(%edx)
  800c59:	42                   	inc    %edx
  800c5a:	89 10                	mov    %edx,(%eax)
}
  800c5c:	5d                   	pop    %ebp
  800c5d:	c3                   	ret    

00800c5e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800c5e:	55                   	push   %ebp
  800c5f:	89 e5                	mov    %esp,%ebp
  800c61:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800c64:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800c67:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c6b:	8b 45 10             	mov    0x10(%ebp),%eax
  800c6e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c72:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c75:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c79:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7c:	89 04 24             	mov    %eax,(%esp)
  800c7f:	e8 02 00 00 00       	call   800c86 <vprintfmt>
	va_end(ap);
}
  800c84:	c9                   	leave  
  800c85:	c3                   	ret    

00800c86 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800c86:	55                   	push   %ebp
  800c87:	89 e5                	mov    %esp,%ebp
  800c89:	57                   	push   %edi
  800c8a:	56                   	push   %esi
  800c8b:	53                   	push   %ebx
  800c8c:	83 ec 4c             	sub    $0x4c,%esp
  800c8f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c92:	8b 75 10             	mov    0x10(%ebp),%esi
  800c95:	eb 12                	jmp    800ca9 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800c97:	85 c0                	test   %eax,%eax
  800c99:	0f 84 6b 03 00 00    	je     80100a <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800c9f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ca3:	89 04 24             	mov    %eax,(%esp)
  800ca6:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800ca9:	0f b6 06             	movzbl (%esi),%eax
  800cac:	46                   	inc    %esi
  800cad:	83 f8 25             	cmp    $0x25,%eax
  800cb0:	75 e5                	jne    800c97 <vprintfmt+0x11>
  800cb2:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800cb6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800cbd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800cc2:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800cc9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cce:	eb 26                	jmp    800cf6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cd0:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800cd3:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800cd7:	eb 1d                	jmp    800cf6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cd9:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800cdc:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800ce0:	eb 14                	jmp    800cf6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ce2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800ce5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800cec:	eb 08                	jmp    800cf6 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800cee:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800cf1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cf6:	0f b6 06             	movzbl (%esi),%eax
  800cf9:	8d 56 01             	lea    0x1(%esi),%edx
  800cfc:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800cff:	8a 16                	mov    (%esi),%dl
  800d01:	83 ea 23             	sub    $0x23,%edx
  800d04:	80 fa 55             	cmp    $0x55,%dl
  800d07:	0f 87 e1 02 00 00    	ja     800fee <vprintfmt+0x368>
  800d0d:	0f b6 d2             	movzbl %dl,%edx
  800d10:	ff 24 95 c0 3e 80 00 	jmp    *0x803ec0(,%edx,4)
  800d17:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800d1a:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800d1f:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800d22:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800d26:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800d29:	8d 50 d0             	lea    -0x30(%eax),%edx
  800d2c:	83 fa 09             	cmp    $0x9,%edx
  800d2f:	77 2a                	ja     800d5b <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800d31:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800d32:	eb eb                	jmp    800d1f <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800d34:	8b 45 14             	mov    0x14(%ebp),%eax
  800d37:	8d 50 04             	lea    0x4(%eax),%edx
  800d3a:	89 55 14             	mov    %edx,0x14(%ebp)
  800d3d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d3f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800d42:	eb 17                	jmp    800d5b <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800d44:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800d48:	78 98                	js     800ce2 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d4a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800d4d:	eb a7                	jmp    800cf6 <vprintfmt+0x70>
  800d4f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800d52:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800d59:	eb 9b                	jmp    800cf6 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800d5b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800d5f:	79 95                	jns    800cf6 <vprintfmt+0x70>
  800d61:	eb 8b                	jmp    800cee <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800d63:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d64:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800d67:	eb 8d                	jmp    800cf6 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800d69:	8b 45 14             	mov    0x14(%ebp),%eax
  800d6c:	8d 50 04             	lea    0x4(%eax),%edx
  800d6f:	89 55 14             	mov    %edx,0x14(%ebp)
  800d72:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d76:	8b 00                	mov    (%eax),%eax
  800d78:	89 04 24             	mov    %eax,(%esp)
  800d7b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d7e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800d81:	e9 23 ff ff ff       	jmp    800ca9 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800d86:	8b 45 14             	mov    0x14(%ebp),%eax
  800d89:	8d 50 04             	lea    0x4(%eax),%edx
  800d8c:	89 55 14             	mov    %edx,0x14(%ebp)
  800d8f:	8b 00                	mov    (%eax),%eax
  800d91:	85 c0                	test   %eax,%eax
  800d93:	79 02                	jns    800d97 <vprintfmt+0x111>
  800d95:	f7 d8                	neg    %eax
  800d97:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800d99:	83 f8 11             	cmp    $0x11,%eax
  800d9c:	7f 0b                	jg     800da9 <vprintfmt+0x123>
  800d9e:	8b 04 85 20 40 80 00 	mov    0x804020(,%eax,4),%eax
  800da5:	85 c0                	test   %eax,%eax
  800da7:	75 23                	jne    800dcc <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800da9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800dad:	c7 44 24 08 9b 3d 80 	movl   $0x803d9b,0x8(%esp)
  800db4:	00 
  800db5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800db9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbc:	89 04 24             	mov    %eax,(%esp)
  800dbf:	e8 9a fe ff ff       	call   800c5e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800dc4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800dc7:	e9 dd fe ff ff       	jmp    800ca9 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800dcc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800dd0:	c7 44 24 08 a4 3c 80 	movl   $0x803ca4,0x8(%esp)
  800dd7:	00 
  800dd8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ddc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddf:	89 14 24             	mov    %edx,(%esp)
  800de2:	e8 77 fe ff ff       	call   800c5e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800de7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800dea:	e9 ba fe ff ff       	jmp    800ca9 <vprintfmt+0x23>
  800def:	89 f9                	mov    %edi,%ecx
  800df1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800df4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800df7:	8b 45 14             	mov    0x14(%ebp),%eax
  800dfa:	8d 50 04             	lea    0x4(%eax),%edx
  800dfd:	89 55 14             	mov    %edx,0x14(%ebp)
  800e00:	8b 30                	mov    (%eax),%esi
  800e02:	85 f6                	test   %esi,%esi
  800e04:	75 05                	jne    800e0b <vprintfmt+0x185>
				p = "(null)";
  800e06:	be 94 3d 80 00       	mov    $0x803d94,%esi
			if (width > 0 && padc != '-')
  800e0b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800e0f:	0f 8e 84 00 00 00    	jle    800e99 <vprintfmt+0x213>
  800e15:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800e19:	74 7e                	je     800e99 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800e1b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e1f:	89 34 24             	mov    %esi,(%esp)
  800e22:	e8 6b 03 00 00       	call   801192 <strnlen>
  800e27:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800e2a:	29 c2                	sub    %eax,%edx
  800e2c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800e2f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800e33:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800e36:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800e39:	89 de                	mov    %ebx,%esi
  800e3b:	89 d3                	mov    %edx,%ebx
  800e3d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800e3f:	eb 0b                	jmp    800e4c <vprintfmt+0x1c6>
					putch(padc, putdat);
  800e41:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e45:	89 3c 24             	mov    %edi,(%esp)
  800e48:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800e4b:	4b                   	dec    %ebx
  800e4c:	85 db                	test   %ebx,%ebx
  800e4e:	7f f1                	jg     800e41 <vprintfmt+0x1bb>
  800e50:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800e53:	89 f3                	mov    %esi,%ebx
  800e55:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800e58:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e5b:	85 c0                	test   %eax,%eax
  800e5d:	79 05                	jns    800e64 <vprintfmt+0x1de>
  800e5f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e64:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800e67:	29 c2                	sub    %eax,%edx
  800e69:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800e6c:	eb 2b                	jmp    800e99 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800e6e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800e72:	74 18                	je     800e8c <vprintfmt+0x206>
  800e74:	8d 50 e0             	lea    -0x20(%eax),%edx
  800e77:	83 fa 5e             	cmp    $0x5e,%edx
  800e7a:	76 10                	jbe    800e8c <vprintfmt+0x206>
					putch('?', putdat);
  800e7c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e80:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800e87:	ff 55 08             	call   *0x8(%ebp)
  800e8a:	eb 0a                	jmp    800e96 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800e8c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e90:	89 04 24             	mov    %eax,(%esp)
  800e93:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e96:	ff 4d e4             	decl   -0x1c(%ebp)
  800e99:	0f be 06             	movsbl (%esi),%eax
  800e9c:	46                   	inc    %esi
  800e9d:	85 c0                	test   %eax,%eax
  800e9f:	74 21                	je     800ec2 <vprintfmt+0x23c>
  800ea1:	85 ff                	test   %edi,%edi
  800ea3:	78 c9                	js     800e6e <vprintfmt+0x1e8>
  800ea5:	4f                   	dec    %edi
  800ea6:	79 c6                	jns    800e6e <vprintfmt+0x1e8>
  800ea8:	8b 7d 08             	mov    0x8(%ebp),%edi
  800eab:	89 de                	mov    %ebx,%esi
  800ead:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800eb0:	eb 18                	jmp    800eca <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800eb2:	89 74 24 04          	mov    %esi,0x4(%esp)
  800eb6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800ebd:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800ebf:	4b                   	dec    %ebx
  800ec0:	eb 08                	jmp    800eca <vprintfmt+0x244>
  800ec2:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ec5:	89 de                	mov    %ebx,%esi
  800ec7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800eca:	85 db                	test   %ebx,%ebx
  800ecc:	7f e4                	jg     800eb2 <vprintfmt+0x22c>
  800ece:	89 7d 08             	mov    %edi,0x8(%ebp)
  800ed1:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ed3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800ed6:	e9 ce fd ff ff       	jmp    800ca9 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800edb:	83 f9 01             	cmp    $0x1,%ecx
  800ede:	7e 10                	jle    800ef0 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800ee0:	8b 45 14             	mov    0x14(%ebp),%eax
  800ee3:	8d 50 08             	lea    0x8(%eax),%edx
  800ee6:	89 55 14             	mov    %edx,0x14(%ebp)
  800ee9:	8b 30                	mov    (%eax),%esi
  800eeb:	8b 78 04             	mov    0x4(%eax),%edi
  800eee:	eb 26                	jmp    800f16 <vprintfmt+0x290>
	else if (lflag)
  800ef0:	85 c9                	test   %ecx,%ecx
  800ef2:	74 12                	je     800f06 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800ef4:	8b 45 14             	mov    0x14(%ebp),%eax
  800ef7:	8d 50 04             	lea    0x4(%eax),%edx
  800efa:	89 55 14             	mov    %edx,0x14(%ebp)
  800efd:	8b 30                	mov    (%eax),%esi
  800eff:	89 f7                	mov    %esi,%edi
  800f01:	c1 ff 1f             	sar    $0x1f,%edi
  800f04:	eb 10                	jmp    800f16 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800f06:	8b 45 14             	mov    0x14(%ebp),%eax
  800f09:	8d 50 04             	lea    0x4(%eax),%edx
  800f0c:	89 55 14             	mov    %edx,0x14(%ebp)
  800f0f:	8b 30                	mov    (%eax),%esi
  800f11:	89 f7                	mov    %esi,%edi
  800f13:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800f16:	85 ff                	test   %edi,%edi
  800f18:	78 0a                	js     800f24 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800f1a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f1f:	e9 8c 00 00 00       	jmp    800fb0 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800f24:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f28:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800f2f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800f32:	f7 de                	neg    %esi
  800f34:	83 d7 00             	adc    $0x0,%edi
  800f37:	f7 df                	neg    %edi
			}
			base = 10;
  800f39:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f3e:	eb 70                	jmp    800fb0 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800f40:	89 ca                	mov    %ecx,%edx
  800f42:	8d 45 14             	lea    0x14(%ebp),%eax
  800f45:	e8 c0 fc ff ff       	call   800c0a <getuint>
  800f4a:	89 c6                	mov    %eax,%esi
  800f4c:	89 d7                	mov    %edx,%edi
			base = 10;
  800f4e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800f53:	eb 5b                	jmp    800fb0 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  800f55:	89 ca                	mov    %ecx,%edx
  800f57:	8d 45 14             	lea    0x14(%ebp),%eax
  800f5a:	e8 ab fc ff ff       	call   800c0a <getuint>
  800f5f:	89 c6                	mov    %eax,%esi
  800f61:	89 d7                	mov    %edx,%edi
			base = 8;
  800f63:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800f68:	eb 46                	jmp    800fb0 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  800f6a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f6e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800f75:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800f78:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f7c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800f83:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800f86:	8b 45 14             	mov    0x14(%ebp),%eax
  800f89:	8d 50 04             	lea    0x4(%eax),%edx
  800f8c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800f8f:	8b 30                	mov    (%eax),%esi
  800f91:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800f96:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800f9b:	eb 13                	jmp    800fb0 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800f9d:	89 ca                	mov    %ecx,%edx
  800f9f:	8d 45 14             	lea    0x14(%ebp),%eax
  800fa2:	e8 63 fc ff ff       	call   800c0a <getuint>
  800fa7:	89 c6                	mov    %eax,%esi
  800fa9:	89 d7                	mov    %edx,%edi
			base = 16;
  800fab:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800fb0:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800fb4:	89 54 24 10          	mov    %edx,0x10(%esp)
  800fb8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800fbb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fbf:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fc3:	89 34 24             	mov    %esi,(%esp)
  800fc6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800fca:	89 da                	mov    %ebx,%edx
  800fcc:	8b 45 08             	mov    0x8(%ebp),%eax
  800fcf:	e8 6c fb ff ff       	call   800b40 <printnum>
			break;
  800fd4:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800fd7:	e9 cd fc ff ff       	jmp    800ca9 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800fdc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800fe0:	89 04 24             	mov    %eax,(%esp)
  800fe3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800fe6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800fe9:	e9 bb fc ff ff       	jmp    800ca9 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800fee:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ff2:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800ff9:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800ffc:	eb 01                	jmp    800fff <vprintfmt+0x379>
  800ffe:	4e                   	dec    %esi
  800fff:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  801003:	75 f9                	jne    800ffe <vprintfmt+0x378>
  801005:	e9 9f fc ff ff       	jmp    800ca9 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80100a:	83 c4 4c             	add    $0x4c,%esp
  80100d:	5b                   	pop    %ebx
  80100e:	5e                   	pop    %esi
  80100f:	5f                   	pop    %edi
  801010:	5d                   	pop    %ebp
  801011:	c3                   	ret    

00801012 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801012:	55                   	push   %ebp
  801013:	89 e5                	mov    %esp,%ebp
  801015:	83 ec 28             	sub    $0x28,%esp
  801018:	8b 45 08             	mov    0x8(%ebp),%eax
  80101b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80101e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801021:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801025:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801028:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80102f:	85 c0                	test   %eax,%eax
  801031:	74 30                	je     801063 <vsnprintf+0x51>
  801033:	85 d2                	test   %edx,%edx
  801035:	7e 33                	jle    80106a <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801037:	8b 45 14             	mov    0x14(%ebp),%eax
  80103a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80103e:	8b 45 10             	mov    0x10(%ebp),%eax
  801041:	89 44 24 08          	mov    %eax,0x8(%esp)
  801045:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801048:	89 44 24 04          	mov    %eax,0x4(%esp)
  80104c:	c7 04 24 44 0c 80 00 	movl   $0x800c44,(%esp)
  801053:	e8 2e fc ff ff       	call   800c86 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801058:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80105b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80105e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801061:	eb 0c                	jmp    80106f <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801063:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801068:	eb 05                	jmp    80106f <vsnprintf+0x5d>
  80106a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80106f:	c9                   	leave  
  801070:	c3                   	ret    

00801071 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801071:	55                   	push   %ebp
  801072:	89 e5                	mov    %esp,%ebp
  801074:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801077:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80107a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80107e:	8b 45 10             	mov    0x10(%ebp),%eax
  801081:	89 44 24 08          	mov    %eax,0x8(%esp)
  801085:	8b 45 0c             	mov    0xc(%ebp),%eax
  801088:	89 44 24 04          	mov    %eax,0x4(%esp)
  80108c:	8b 45 08             	mov    0x8(%ebp),%eax
  80108f:	89 04 24             	mov    %eax,(%esp)
  801092:	e8 7b ff ff ff       	call   801012 <vsnprintf>
	va_end(ap);

	return rc;
}
  801097:	c9                   	leave  
  801098:	c3                   	ret    
  801099:	00 00                	add    %al,(%eax)
	...

0080109c <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  80109c:	55                   	push   %ebp
  80109d:	89 e5                	mov    %esp,%ebp
  80109f:	57                   	push   %edi
  8010a0:	56                   	push   %esi
  8010a1:	53                   	push   %ebx
  8010a2:	83 ec 1c             	sub    $0x1c,%esp
  8010a5:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  8010a8:	85 c0                	test   %eax,%eax
  8010aa:	74 18                	je     8010c4 <readline+0x28>
		fprintf(1, "%s", prompt);
  8010ac:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010b0:	c7 44 24 04 a4 3c 80 	movl   $0x803ca4,0x4(%esp)
  8010b7:	00 
  8010b8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8010bf:	e8 a4 16 00 00       	call   802768 <fprintf>
#endif

	i = 0;
	echoing = iscons(0);
  8010c4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010cb:	e8 7d f8 ff ff       	call   80094d <iscons>
  8010d0:	89 c7                	mov    %eax,%edi
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  8010d2:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  8010d7:	e8 3b f8 ff ff       	call   800917 <getchar>
  8010dc:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  8010de:	85 c0                	test   %eax,%eax
  8010e0:	79 20                	jns    801102 <readline+0x66>
			if (c != -E_EOF)
  8010e2:	83 f8 f8             	cmp    $0xfffffff8,%eax
  8010e5:	0f 84 82 00 00 00    	je     80116d <readline+0xd1>
				cprintf("read error: %e\n", c);
  8010eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010ef:	c7 04 24 87 40 80 00 	movl   $0x804087,(%esp)
  8010f6:	e8 29 fa ff ff       	call   800b24 <cprintf>
			return NULL;
  8010fb:	b8 00 00 00 00       	mov    $0x0,%eax
  801100:	eb 70                	jmp    801172 <readline+0xd6>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  801102:	83 f8 08             	cmp    $0x8,%eax
  801105:	74 05                	je     80110c <readline+0x70>
  801107:	83 f8 7f             	cmp    $0x7f,%eax
  80110a:	75 17                	jne    801123 <readline+0x87>
  80110c:	85 f6                	test   %esi,%esi
  80110e:	7e 13                	jle    801123 <readline+0x87>
			if (echoing)
  801110:	85 ff                	test   %edi,%edi
  801112:	74 0c                	je     801120 <readline+0x84>
				cputchar('\b');
  801114:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  80111b:	e8 d6 f7 ff ff       	call   8008f6 <cputchar>
			i--;
  801120:	4e                   	dec    %esi
  801121:	eb b4                	jmp    8010d7 <readline+0x3b>
		} else if (c >= ' ' && i < BUFLEN-1) {
  801123:	83 fb 1f             	cmp    $0x1f,%ebx
  801126:	7e 1d                	jle    801145 <readline+0xa9>
  801128:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  80112e:	7f 15                	jg     801145 <readline+0xa9>
			if (echoing)
  801130:	85 ff                	test   %edi,%edi
  801132:	74 08                	je     80113c <readline+0xa0>
				cputchar(c);
  801134:	89 1c 24             	mov    %ebx,(%esp)
  801137:	e8 ba f7 ff ff       	call   8008f6 <cputchar>
			buf[i++] = c;
  80113c:	88 9e 20 60 80 00    	mov    %bl,0x806020(%esi)
  801142:	46                   	inc    %esi
  801143:	eb 92                	jmp    8010d7 <readline+0x3b>
		} else if (c == '\n' || c == '\r') {
  801145:	83 fb 0a             	cmp    $0xa,%ebx
  801148:	74 05                	je     80114f <readline+0xb3>
  80114a:	83 fb 0d             	cmp    $0xd,%ebx
  80114d:	75 88                	jne    8010d7 <readline+0x3b>
			if (echoing)
  80114f:	85 ff                	test   %edi,%edi
  801151:	74 0c                	je     80115f <readline+0xc3>
				cputchar('\n');
  801153:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  80115a:	e8 97 f7 ff ff       	call   8008f6 <cputchar>
			buf[i] = 0;
  80115f:	c6 86 20 60 80 00 00 	movb   $0x0,0x806020(%esi)
			return buf;
  801166:	b8 20 60 80 00       	mov    $0x806020,%eax
  80116b:	eb 05                	jmp    801172 <readline+0xd6>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  80116d:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
  801172:	83 c4 1c             	add    $0x1c,%esp
  801175:	5b                   	pop    %ebx
  801176:	5e                   	pop    %esi
  801177:	5f                   	pop    %edi
  801178:	5d                   	pop    %ebp
  801179:	c3                   	ret    
	...

0080117c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80117c:	55                   	push   %ebp
  80117d:	89 e5                	mov    %esp,%ebp
  80117f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801182:	b8 00 00 00 00       	mov    $0x0,%eax
  801187:	eb 01                	jmp    80118a <strlen+0xe>
		n++;
  801189:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80118a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80118e:	75 f9                	jne    801189 <strlen+0xd>
		n++;
	return n;
}
  801190:	5d                   	pop    %ebp
  801191:	c3                   	ret    

00801192 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801192:	55                   	push   %ebp
  801193:	89 e5                	mov    %esp,%ebp
  801195:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  801198:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80119b:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a0:	eb 01                	jmp    8011a3 <strnlen+0x11>
		n++;
  8011a2:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8011a3:	39 d0                	cmp    %edx,%eax
  8011a5:	74 06                	je     8011ad <strnlen+0x1b>
  8011a7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8011ab:	75 f5                	jne    8011a2 <strnlen+0x10>
		n++;
	return n;
}
  8011ad:	5d                   	pop    %ebp
  8011ae:	c3                   	ret    

008011af <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8011af:	55                   	push   %ebp
  8011b0:	89 e5                	mov    %esp,%ebp
  8011b2:	53                   	push   %ebx
  8011b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8011b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8011be:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8011c1:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8011c4:	42                   	inc    %edx
  8011c5:	84 c9                	test   %cl,%cl
  8011c7:	75 f5                	jne    8011be <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8011c9:	5b                   	pop    %ebx
  8011ca:	5d                   	pop    %ebp
  8011cb:	c3                   	ret    

008011cc <strcat>:

char *
strcat(char *dst, const char *src)
{
  8011cc:	55                   	push   %ebp
  8011cd:	89 e5                	mov    %esp,%ebp
  8011cf:	53                   	push   %ebx
  8011d0:	83 ec 08             	sub    $0x8,%esp
  8011d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8011d6:	89 1c 24             	mov    %ebx,(%esp)
  8011d9:	e8 9e ff ff ff       	call   80117c <strlen>
	strcpy(dst + len, src);
  8011de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8011e5:	01 d8                	add    %ebx,%eax
  8011e7:	89 04 24             	mov    %eax,(%esp)
  8011ea:	e8 c0 ff ff ff       	call   8011af <strcpy>
	return dst;
}
  8011ef:	89 d8                	mov    %ebx,%eax
  8011f1:	83 c4 08             	add    $0x8,%esp
  8011f4:	5b                   	pop    %ebx
  8011f5:	5d                   	pop    %ebp
  8011f6:	c3                   	ret    

008011f7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8011f7:	55                   	push   %ebp
  8011f8:	89 e5                	mov    %esp,%ebp
  8011fa:	56                   	push   %esi
  8011fb:	53                   	push   %ebx
  8011fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  801202:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801205:	b9 00 00 00 00       	mov    $0x0,%ecx
  80120a:	eb 0c                	jmp    801218 <strncpy+0x21>
		*dst++ = *src;
  80120c:	8a 1a                	mov    (%edx),%bl
  80120e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801211:	80 3a 01             	cmpb   $0x1,(%edx)
  801214:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801217:	41                   	inc    %ecx
  801218:	39 f1                	cmp    %esi,%ecx
  80121a:	75 f0                	jne    80120c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80121c:	5b                   	pop    %ebx
  80121d:	5e                   	pop    %esi
  80121e:	5d                   	pop    %ebp
  80121f:	c3                   	ret    

00801220 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801220:	55                   	push   %ebp
  801221:	89 e5                	mov    %esp,%ebp
  801223:	56                   	push   %esi
  801224:	53                   	push   %ebx
  801225:	8b 75 08             	mov    0x8(%ebp),%esi
  801228:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80122b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80122e:	85 d2                	test   %edx,%edx
  801230:	75 0a                	jne    80123c <strlcpy+0x1c>
  801232:	89 f0                	mov    %esi,%eax
  801234:	eb 1a                	jmp    801250 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801236:	88 18                	mov    %bl,(%eax)
  801238:	40                   	inc    %eax
  801239:	41                   	inc    %ecx
  80123a:	eb 02                	jmp    80123e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80123c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80123e:	4a                   	dec    %edx
  80123f:	74 0a                	je     80124b <strlcpy+0x2b>
  801241:	8a 19                	mov    (%ecx),%bl
  801243:	84 db                	test   %bl,%bl
  801245:	75 ef                	jne    801236 <strlcpy+0x16>
  801247:	89 c2                	mov    %eax,%edx
  801249:	eb 02                	jmp    80124d <strlcpy+0x2d>
  80124b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  80124d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  801250:	29 f0                	sub    %esi,%eax
}
  801252:	5b                   	pop    %ebx
  801253:	5e                   	pop    %esi
  801254:	5d                   	pop    %ebp
  801255:	c3                   	ret    

00801256 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801256:	55                   	push   %ebp
  801257:	89 e5                	mov    %esp,%ebp
  801259:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80125c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80125f:	eb 02                	jmp    801263 <strcmp+0xd>
		p++, q++;
  801261:	41                   	inc    %ecx
  801262:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801263:	8a 01                	mov    (%ecx),%al
  801265:	84 c0                	test   %al,%al
  801267:	74 04                	je     80126d <strcmp+0x17>
  801269:	3a 02                	cmp    (%edx),%al
  80126b:	74 f4                	je     801261 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80126d:	0f b6 c0             	movzbl %al,%eax
  801270:	0f b6 12             	movzbl (%edx),%edx
  801273:	29 d0                	sub    %edx,%eax
}
  801275:	5d                   	pop    %ebp
  801276:	c3                   	ret    

00801277 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801277:	55                   	push   %ebp
  801278:	89 e5                	mov    %esp,%ebp
  80127a:	53                   	push   %ebx
  80127b:	8b 45 08             	mov    0x8(%ebp),%eax
  80127e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801281:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  801284:	eb 03                	jmp    801289 <strncmp+0x12>
		n--, p++, q++;
  801286:	4a                   	dec    %edx
  801287:	40                   	inc    %eax
  801288:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801289:	85 d2                	test   %edx,%edx
  80128b:	74 14                	je     8012a1 <strncmp+0x2a>
  80128d:	8a 18                	mov    (%eax),%bl
  80128f:	84 db                	test   %bl,%bl
  801291:	74 04                	je     801297 <strncmp+0x20>
  801293:	3a 19                	cmp    (%ecx),%bl
  801295:	74 ef                	je     801286 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801297:	0f b6 00             	movzbl (%eax),%eax
  80129a:	0f b6 11             	movzbl (%ecx),%edx
  80129d:	29 d0                	sub    %edx,%eax
  80129f:	eb 05                	jmp    8012a6 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8012a1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8012a6:	5b                   	pop    %ebx
  8012a7:	5d                   	pop    %ebp
  8012a8:	c3                   	ret    

008012a9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8012a9:	55                   	push   %ebp
  8012aa:	89 e5                	mov    %esp,%ebp
  8012ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8012af:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8012b2:	eb 05                	jmp    8012b9 <strchr+0x10>
		if (*s == c)
  8012b4:	38 ca                	cmp    %cl,%dl
  8012b6:	74 0c                	je     8012c4 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8012b8:	40                   	inc    %eax
  8012b9:	8a 10                	mov    (%eax),%dl
  8012bb:	84 d2                	test   %dl,%dl
  8012bd:	75 f5                	jne    8012b4 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8012bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012c4:	5d                   	pop    %ebp
  8012c5:	c3                   	ret    

008012c6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8012c6:	55                   	push   %ebp
  8012c7:	89 e5                	mov    %esp,%ebp
  8012c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8012cc:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8012cf:	eb 05                	jmp    8012d6 <strfind+0x10>
		if (*s == c)
  8012d1:	38 ca                	cmp    %cl,%dl
  8012d3:	74 07                	je     8012dc <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8012d5:	40                   	inc    %eax
  8012d6:	8a 10                	mov    (%eax),%dl
  8012d8:	84 d2                	test   %dl,%dl
  8012da:	75 f5                	jne    8012d1 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8012dc:	5d                   	pop    %ebp
  8012dd:	c3                   	ret    

008012de <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8012de:	55                   	push   %ebp
  8012df:	89 e5                	mov    %esp,%ebp
  8012e1:	57                   	push   %edi
  8012e2:	56                   	push   %esi
  8012e3:	53                   	push   %ebx
  8012e4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8012ed:	85 c9                	test   %ecx,%ecx
  8012ef:	74 30                	je     801321 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8012f1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8012f7:	75 25                	jne    80131e <memset+0x40>
  8012f9:	f6 c1 03             	test   $0x3,%cl
  8012fc:	75 20                	jne    80131e <memset+0x40>
		c &= 0xFF;
  8012fe:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801301:	89 d3                	mov    %edx,%ebx
  801303:	c1 e3 08             	shl    $0x8,%ebx
  801306:	89 d6                	mov    %edx,%esi
  801308:	c1 e6 18             	shl    $0x18,%esi
  80130b:	89 d0                	mov    %edx,%eax
  80130d:	c1 e0 10             	shl    $0x10,%eax
  801310:	09 f0                	or     %esi,%eax
  801312:	09 d0                	or     %edx,%eax
  801314:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801316:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801319:	fc                   	cld    
  80131a:	f3 ab                	rep stos %eax,%es:(%edi)
  80131c:	eb 03                	jmp    801321 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80131e:	fc                   	cld    
  80131f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801321:	89 f8                	mov    %edi,%eax
  801323:	5b                   	pop    %ebx
  801324:	5e                   	pop    %esi
  801325:	5f                   	pop    %edi
  801326:	5d                   	pop    %ebp
  801327:	c3                   	ret    

00801328 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801328:	55                   	push   %ebp
  801329:	89 e5                	mov    %esp,%ebp
  80132b:	57                   	push   %edi
  80132c:	56                   	push   %esi
  80132d:	8b 45 08             	mov    0x8(%ebp),%eax
  801330:	8b 75 0c             	mov    0xc(%ebp),%esi
  801333:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801336:	39 c6                	cmp    %eax,%esi
  801338:	73 34                	jae    80136e <memmove+0x46>
  80133a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80133d:	39 d0                	cmp    %edx,%eax
  80133f:	73 2d                	jae    80136e <memmove+0x46>
		s += n;
		d += n;
  801341:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801344:	f6 c2 03             	test   $0x3,%dl
  801347:	75 1b                	jne    801364 <memmove+0x3c>
  801349:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80134f:	75 13                	jne    801364 <memmove+0x3c>
  801351:	f6 c1 03             	test   $0x3,%cl
  801354:	75 0e                	jne    801364 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801356:	83 ef 04             	sub    $0x4,%edi
  801359:	8d 72 fc             	lea    -0x4(%edx),%esi
  80135c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80135f:	fd                   	std    
  801360:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801362:	eb 07                	jmp    80136b <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801364:	4f                   	dec    %edi
  801365:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801368:	fd                   	std    
  801369:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80136b:	fc                   	cld    
  80136c:	eb 20                	jmp    80138e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80136e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801374:	75 13                	jne    801389 <memmove+0x61>
  801376:	a8 03                	test   $0x3,%al
  801378:	75 0f                	jne    801389 <memmove+0x61>
  80137a:	f6 c1 03             	test   $0x3,%cl
  80137d:	75 0a                	jne    801389 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80137f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801382:	89 c7                	mov    %eax,%edi
  801384:	fc                   	cld    
  801385:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801387:	eb 05                	jmp    80138e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801389:	89 c7                	mov    %eax,%edi
  80138b:	fc                   	cld    
  80138c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80138e:	5e                   	pop    %esi
  80138f:	5f                   	pop    %edi
  801390:	5d                   	pop    %ebp
  801391:	c3                   	ret    

00801392 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801392:	55                   	push   %ebp
  801393:	89 e5                	mov    %esp,%ebp
  801395:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801398:	8b 45 10             	mov    0x10(%ebp),%eax
  80139b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80139f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a9:	89 04 24             	mov    %eax,(%esp)
  8013ac:	e8 77 ff ff ff       	call   801328 <memmove>
}
  8013b1:	c9                   	leave  
  8013b2:	c3                   	ret    

008013b3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8013b3:	55                   	push   %ebp
  8013b4:	89 e5                	mov    %esp,%ebp
  8013b6:	57                   	push   %edi
  8013b7:	56                   	push   %esi
  8013b8:	53                   	push   %ebx
  8013b9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013bc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8013c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8013c7:	eb 16                	jmp    8013df <memcmp+0x2c>
		if (*s1 != *s2)
  8013c9:	8a 04 17             	mov    (%edi,%edx,1),%al
  8013cc:	42                   	inc    %edx
  8013cd:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8013d1:	38 c8                	cmp    %cl,%al
  8013d3:	74 0a                	je     8013df <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8013d5:	0f b6 c0             	movzbl %al,%eax
  8013d8:	0f b6 c9             	movzbl %cl,%ecx
  8013db:	29 c8                	sub    %ecx,%eax
  8013dd:	eb 09                	jmp    8013e8 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8013df:	39 da                	cmp    %ebx,%edx
  8013e1:	75 e6                	jne    8013c9 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8013e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013e8:	5b                   	pop    %ebx
  8013e9:	5e                   	pop    %esi
  8013ea:	5f                   	pop    %edi
  8013eb:	5d                   	pop    %ebp
  8013ec:	c3                   	ret    

008013ed <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8013ed:	55                   	push   %ebp
  8013ee:	89 e5                	mov    %esp,%ebp
  8013f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8013f6:	89 c2                	mov    %eax,%edx
  8013f8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8013fb:	eb 05                	jmp    801402 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8013fd:	38 08                	cmp    %cl,(%eax)
  8013ff:	74 05                	je     801406 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801401:	40                   	inc    %eax
  801402:	39 d0                	cmp    %edx,%eax
  801404:	72 f7                	jb     8013fd <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801406:	5d                   	pop    %ebp
  801407:	c3                   	ret    

00801408 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801408:	55                   	push   %ebp
  801409:	89 e5                	mov    %esp,%ebp
  80140b:	57                   	push   %edi
  80140c:	56                   	push   %esi
  80140d:	53                   	push   %ebx
  80140e:	8b 55 08             	mov    0x8(%ebp),%edx
  801411:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801414:	eb 01                	jmp    801417 <strtol+0xf>
		s++;
  801416:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801417:	8a 02                	mov    (%edx),%al
  801419:	3c 20                	cmp    $0x20,%al
  80141b:	74 f9                	je     801416 <strtol+0xe>
  80141d:	3c 09                	cmp    $0x9,%al
  80141f:	74 f5                	je     801416 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801421:	3c 2b                	cmp    $0x2b,%al
  801423:	75 08                	jne    80142d <strtol+0x25>
		s++;
  801425:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801426:	bf 00 00 00 00       	mov    $0x0,%edi
  80142b:	eb 13                	jmp    801440 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80142d:	3c 2d                	cmp    $0x2d,%al
  80142f:	75 0a                	jne    80143b <strtol+0x33>
		s++, neg = 1;
  801431:	8d 52 01             	lea    0x1(%edx),%edx
  801434:	bf 01 00 00 00       	mov    $0x1,%edi
  801439:	eb 05                	jmp    801440 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80143b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801440:	85 db                	test   %ebx,%ebx
  801442:	74 05                	je     801449 <strtol+0x41>
  801444:	83 fb 10             	cmp    $0x10,%ebx
  801447:	75 28                	jne    801471 <strtol+0x69>
  801449:	8a 02                	mov    (%edx),%al
  80144b:	3c 30                	cmp    $0x30,%al
  80144d:	75 10                	jne    80145f <strtol+0x57>
  80144f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801453:	75 0a                	jne    80145f <strtol+0x57>
		s += 2, base = 16;
  801455:	83 c2 02             	add    $0x2,%edx
  801458:	bb 10 00 00 00       	mov    $0x10,%ebx
  80145d:	eb 12                	jmp    801471 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  80145f:	85 db                	test   %ebx,%ebx
  801461:	75 0e                	jne    801471 <strtol+0x69>
  801463:	3c 30                	cmp    $0x30,%al
  801465:	75 05                	jne    80146c <strtol+0x64>
		s++, base = 8;
  801467:	42                   	inc    %edx
  801468:	b3 08                	mov    $0x8,%bl
  80146a:	eb 05                	jmp    801471 <strtol+0x69>
	else if (base == 0)
		base = 10;
  80146c:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801471:	b8 00 00 00 00       	mov    $0x0,%eax
  801476:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801478:	8a 0a                	mov    (%edx),%cl
  80147a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  80147d:	80 fb 09             	cmp    $0x9,%bl
  801480:	77 08                	ja     80148a <strtol+0x82>
			dig = *s - '0';
  801482:	0f be c9             	movsbl %cl,%ecx
  801485:	83 e9 30             	sub    $0x30,%ecx
  801488:	eb 1e                	jmp    8014a8 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  80148a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  80148d:	80 fb 19             	cmp    $0x19,%bl
  801490:	77 08                	ja     80149a <strtol+0x92>
			dig = *s - 'a' + 10;
  801492:	0f be c9             	movsbl %cl,%ecx
  801495:	83 e9 57             	sub    $0x57,%ecx
  801498:	eb 0e                	jmp    8014a8 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  80149a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  80149d:	80 fb 19             	cmp    $0x19,%bl
  8014a0:	77 12                	ja     8014b4 <strtol+0xac>
			dig = *s - 'A' + 10;
  8014a2:	0f be c9             	movsbl %cl,%ecx
  8014a5:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8014a8:	39 f1                	cmp    %esi,%ecx
  8014aa:	7d 0c                	jge    8014b8 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  8014ac:	42                   	inc    %edx
  8014ad:	0f af c6             	imul   %esi,%eax
  8014b0:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  8014b2:	eb c4                	jmp    801478 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8014b4:	89 c1                	mov    %eax,%ecx
  8014b6:	eb 02                	jmp    8014ba <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8014b8:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8014ba:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8014be:	74 05                	je     8014c5 <strtol+0xbd>
		*endptr = (char *) s;
  8014c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014c3:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8014c5:	85 ff                	test   %edi,%edi
  8014c7:	74 04                	je     8014cd <strtol+0xc5>
  8014c9:	89 c8                	mov    %ecx,%eax
  8014cb:	f7 d8                	neg    %eax
}
  8014cd:	5b                   	pop    %ebx
  8014ce:	5e                   	pop    %esi
  8014cf:	5f                   	pop    %edi
  8014d0:	5d                   	pop    %ebp
  8014d1:	c3                   	ret    
	...

008014d4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8014d4:	55                   	push   %ebp
  8014d5:	89 e5                	mov    %esp,%ebp
  8014d7:	57                   	push   %edi
  8014d8:	56                   	push   %esi
  8014d9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014da:	b8 00 00 00 00       	mov    $0x0,%eax
  8014df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8014e5:	89 c3                	mov    %eax,%ebx
  8014e7:	89 c7                	mov    %eax,%edi
  8014e9:	89 c6                	mov    %eax,%esi
  8014eb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8014ed:	5b                   	pop    %ebx
  8014ee:	5e                   	pop    %esi
  8014ef:	5f                   	pop    %edi
  8014f0:	5d                   	pop    %ebp
  8014f1:	c3                   	ret    

008014f2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8014f2:	55                   	push   %ebp
  8014f3:	89 e5                	mov    %esp,%ebp
  8014f5:	57                   	push   %edi
  8014f6:	56                   	push   %esi
  8014f7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8014fd:	b8 01 00 00 00       	mov    $0x1,%eax
  801502:	89 d1                	mov    %edx,%ecx
  801504:	89 d3                	mov    %edx,%ebx
  801506:	89 d7                	mov    %edx,%edi
  801508:	89 d6                	mov    %edx,%esi
  80150a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80150c:	5b                   	pop    %ebx
  80150d:	5e                   	pop    %esi
  80150e:	5f                   	pop    %edi
  80150f:	5d                   	pop    %ebp
  801510:	c3                   	ret    

00801511 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801511:	55                   	push   %ebp
  801512:	89 e5                	mov    %esp,%ebp
  801514:	57                   	push   %edi
  801515:	56                   	push   %esi
  801516:	53                   	push   %ebx
  801517:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80151a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80151f:	b8 03 00 00 00       	mov    $0x3,%eax
  801524:	8b 55 08             	mov    0x8(%ebp),%edx
  801527:	89 cb                	mov    %ecx,%ebx
  801529:	89 cf                	mov    %ecx,%edi
  80152b:	89 ce                	mov    %ecx,%esi
  80152d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80152f:	85 c0                	test   %eax,%eax
  801531:	7e 28                	jle    80155b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801533:	89 44 24 10          	mov    %eax,0x10(%esp)
  801537:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80153e:	00 
  80153f:	c7 44 24 08 97 40 80 	movl   $0x804097,0x8(%esp)
  801546:	00 
  801547:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80154e:	00 
  80154f:	c7 04 24 b4 40 80 00 	movl   $0x8040b4,(%esp)
  801556:	e8 d1 f4 ff ff       	call   800a2c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80155b:	83 c4 2c             	add    $0x2c,%esp
  80155e:	5b                   	pop    %ebx
  80155f:	5e                   	pop    %esi
  801560:	5f                   	pop    %edi
  801561:	5d                   	pop    %ebp
  801562:	c3                   	ret    

00801563 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801563:	55                   	push   %ebp
  801564:	89 e5                	mov    %esp,%ebp
  801566:	57                   	push   %edi
  801567:	56                   	push   %esi
  801568:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801569:	ba 00 00 00 00       	mov    $0x0,%edx
  80156e:	b8 02 00 00 00       	mov    $0x2,%eax
  801573:	89 d1                	mov    %edx,%ecx
  801575:	89 d3                	mov    %edx,%ebx
  801577:	89 d7                	mov    %edx,%edi
  801579:	89 d6                	mov    %edx,%esi
  80157b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80157d:	5b                   	pop    %ebx
  80157e:	5e                   	pop    %esi
  80157f:	5f                   	pop    %edi
  801580:	5d                   	pop    %ebp
  801581:	c3                   	ret    

00801582 <sys_yield>:

void
sys_yield(void)
{
  801582:	55                   	push   %ebp
  801583:	89 e5                	mov    %esp,%ebp
  801585:	57                   	push   %edi
  801586:	56                   	push   %esi
  801587:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801588:	ba 00 00 00 00       	mov    $0x0,%edx
  80158d:	b8 0b 00 00 00       	mov    $0xb,%eax
  801592:	89 d1                	mov    %edx,%ecx
  801594:	89 d3                	mov    %edx,%ebx
  801596:	89 d7                	mov    %edx,%edi
  801598:	89 d6                	mov    %edx,%esi
  80159a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80159c:	5b                   	pop    %ebx
  80159d:	5e                   	pop    %esi
  80159e:	5f                   	pop    %edi
  80159f:	5d                   	pop    %ebp
  8015a0:	c3                   	ret    

008015a1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8015a1:	55                   	push   %ebp
  8015a2:	89 e5                	mov    %esp,%ebp
  8015a4:	57                   	push   %edi
  8015a5:	56                   	push   %esi
  8015a6:	53                   	push   %ebx
  8015a7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015aa:	be 00 00 00 00       	mov    $0x0,%esi
  8015af:	b8 04 00 00 00       	mov    $0x4,%eax
  8015b4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8015b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8015bd:	89 f7                	mov    %esi,%edi
  8015bf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8015c1:	85 c0                	test   %eax,%eax
  8015c3:	7e 28                	jle    8015ed <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8015c5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015c9:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8015d0:	00 
  8015d1:	c7 44 24 08 97 40 80 	movl   $0x804097,0x8(%esp)
  8015d8:	00 
  8015d9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8015e0:	00 
  8015e1:	c7 04 24 b4 40 80 00 	movl   $0x8040b4,(%esp)
  8015e8:	e8 3f f4 ff ff       	call   800a2c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8015ed:	83 c4 2c             	add    $0x2c,%esp
  8015f0:	5b                   	pop    %ebx
  8015f1:	5e                   	pop    %esi
  8015f2:	5f                   	pop    %edi
  8015f3:	5d                   	pop    %ebp
  8015f4:	c3                   	ret    

008015f5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8015f5:	55                   	push   %ebp
  8015f6:	89 e5                	mov    %esp,%ebp
  8015f8:	57                   	push   %edi
  8015f9:	56                   	push   %esi
  8015fa:	53                   	push   %ebx
  8015fb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015fe:	b8 05 00 00 00       	mov    $0x5,%eax
  801603:	8b 75 18             	mov    0x18(%ebp),%esi
  801606:	8b 7d 14             	mov    0x14(%ebp),%edi
  801609:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80160c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80160f:	8b 55 08             	mov    0x8(%ebp),%edx
  801612:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801614:	85 c0                	test   %eax,%eax
  801616:	7e 28                	jle    801640 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801618:	89 44 24 10          	mov    %eax,0x10(%esp)
  80161c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801623:	00 
  801624:	c7 44 24 08 97 40 80 	movl   $0x804097,0x8(%esp)
  80162b:	00 
  80162c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801633:	00 
  801634:	c7 04 24 b4 40 80 00 	movl   $0x8040b4,(%esp)
  80163b:	e8 ec f3 ff ff       	call   800a2c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801640:	83 c4 2c             	add    $0x2c,%esp
  801643:	5b                   	pop    %ebx
  801644:	5e                   	pop    %esi
  801645:	5f                   	pop    %edi
  801646:	5d                   	pop    %ebp
  801647:	c3                   	ret    

00801648 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801648:	55                   	push   %ebp
  801649:	89 e5                	mov    %esp,%ebp
  80164b:	57                   	push   %edi
  80164c:	56                   	push   %esi
  80164d:	53                   	push   %ebx
  80164e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801651:	bb 00 00 00 00       	mov    $0x0,%ebx
  801656:	b8 06 00 00 00       	mov    $0x6,%eax
  80165b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80165e:	8b 55 08             	mov    0x8(%ebp),%edx
  801661:	89 df                	mov    %ebx,%edi
  801663:	89 de                	mov    %ebx,%esi
  801665:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801667:	85 c0                	test   %eax,%eax
  801669:	7e 28                	jle    801693 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80166b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80166f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801676:	00 
  801677:	c7 44 24 08 97 40 80 	movl   $0x804097,0x8(%esp)
  80167e:	00 
  80167f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801686:	00 
  801687:	c7 04 24 b4 40 80 00 	movl   $0x8040b4,(%esp)
  80168e:	e8 99 f3 ff ff       	call   800a2c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801693:	83 c4 2c             	add    $0x2c,%esp
  801696:	5b                   	pop    %ebx
  801697:	5e                   	pop    %esi
  801698:	5f                   	pop    %edi
  801699:	5d                   	pop    %ebp
  80169a:	c3                   	ret    

0080169b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80169b:	55                   	push   %ebp
  80169c:	89 e5                	mov    %esp,%ebp
  80169e:	57                   	push   %edi
  80169f:	56                   	push   %esi
  8016a0:	53                   	push   %ebx
  8016a1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8016a4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016a9:	b8 08 00 00 00       	mov    $0x8,%eax
  8016ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8016b4:	89 df                	mov    %ebx,%edi
  8016b6:	89 de                	mov    %ebx,%esi
  8016b8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8016ba:	85 c0                	test   %eax,%eax
  8016bc:	7e 28                	jle    8016e6 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016be:	89 44 24 10          	mov    %eax,0x10(%esp)
  8016c2:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8016c9:	00 
  8016ca:	c7 44 24 08 97 40 80 	movl   $0x804097,0x8(%esp)
  8016d1:	00 
  8016d2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8016d9:	00 
  8016da:	c7 04 24 b4 40 80 00 	movl   $0x8040b4,(%esp)
  8016e1:	e8 46 f3 ff ff       	call   800a2c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8016e6:	83 c4 2c             	add    $0x2c,%esp
  8016e9:	5b                   	pop    %ebx
  8016ea:	5e                   	pop    %esi
  8016eb:	5f                   	pop    %edi
  8016ec:	5d                   	pop    %ebp
  8016ed:	c3                   	ret    

008016ee <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8016ee:	55                   	push   %ebp
  8016ef:	89 e5                	mov    %esp,%ebp
  8016f1:	57                   	push   %edi
  8016f2:	56                   	push   %esi
  8016f3:	53                   	push   %ebx
  8016f4:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8016f7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016fc:	b8 09 00 00 00       	mov    $0x9,%eax
  801701:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801704:	8b 55 08             	mov    0x8(%ebp),%edx
  801707:	89 df                	mov    %ebx,%edi
  801709:	89 de                	mov    %ebx,%esi
  80170b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80170d:	85 c0                	test   %eax,%eax
  80170f:	7e 28                	jle    801739 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801711:	89 44 24 10          	mov    %eax,0x10(%esp)
  801715:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80171c:	00 
  80171d:	c7 44 24 08 97 40 80 	movl   $0x804097,0x8(%esp)
  801724:	00 
  801725:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80172c:	00 
  80172d:	c7 04 24 b4 40 80 00 	movl   $0x8040b4,(%esp)
  801734:	e8 f3 f2 ff ff       	call   800a2c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801739:	83 c4 2c             	add    $0x2c,%esp
  80173c:	5b                   	pop    %ebx
  80173d:	5e                   	pop    %esi
  80173e:	5f                   	pop    %edi
  80173f:	5d                   	pop    %ebp
  801740:	c3                   	ret    

00801741 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801741:	55                   	push   %ebp
  801742:	89 e5                	mov    %esp,%ebp
  801744:	57                   	push   %edi
  801745:	56                   	push   %esi
  801746:	53                   	push   %ebx
  801747:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80174a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80174f:	b8 0a 00 00 00       	mov    $0xa,%eax
  801754:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801757:	8b 55 08             	mov    0x8(%ebp),%edx
  80175a:	89 df                	mov    %ebx,%edi
  80175c:	89 de                	mov    %ebx,%esi
  80175e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801760:	85 c0                	test   %eax,%eax
  801762:	7e 28                	jle    80178c <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801764:	89 44 24 10          	mov    %eax,0x10(%esp)
  801768:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80176f:	00 
  801770:	c7 44 24 08 97 40 80 	movl   $0x804097,0x8(%esp)
  801777:	00 
  801778:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80177f:	00 
  801780:	c7 04 24 b4 40 80 00 	movl   $0x8040b4,(%esp)
  801787:	e8 a0 f2 ff ff       	call   800a2c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80178c:	83 c4 2c             	add    $0x2c,%esp
  80178f:	5b                   	pop    %ebx
  801790:	5e                   	pop    %esi
  801791:	5f                   	pop    %edi
  801792:	5d                   	pop    %ebp
  801793:	c3                   	ret    

00801794 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801794:	55                   	push   %ebp
  801795:	89 e5                	mov    %esp,%ebp
  801797:	57                   	push   %edi
  801798:	56                   	push   %esi
  801799:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80179a:	be 00 00 00 00       	mov    $0x0,%esi
  80179f:	b8 0c 00 00 00       	mov    $0xc,%eax
  8017a4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8017a7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8017aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8017b0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8017b2:	5b                   	pop    %ebx
  8017b3:	5e                   	pop    %esi
  8017b4:	5f                   	pop    %edi
  8017b5:	5d                   	pop    %ebp
  8017b6:	c3                   	ret    

008017b7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8017b7:	55                   	push   %ebp
  8017b8:	89 e5                	mov    %esp,%ebp
  8017ba:	57                   	push   %edi
  8017bb:	56                   	push   %esi
  8017bc:	53                   	push   %ebx
  8017bd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8017c0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8017c5:	b8 0d 00 00 00       	mov    $0xd,%eax
  8017ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8017cd:	89 cb                	mov    %ecx,%ebx
  8017cf:	89 cf                	mov    %ecx,%edi
  8017d1:	89 ce                	mov    %ecx,%esi
  8017d3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8017d5:	85 c0                	test   %eax,%eax
  8017d7:	7e 28                	jle    801801 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8017d9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8017dd:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8017e4:	00 
  8017e5:	c7 44 24 08 97 40 80 	movl   $0x804097,0x8(%esp)
  8017ec:	00 
  8017ed:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8017f4:	00 
  8017f5:	c7 04 24 b4 40 80 00 	movl   $0x8040b4,(%esp)
  8017fc:	e8 2b f2 ff ff       	call   800a2c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801801:	83 c4 2c             	add    $0x2c,%esp
  801804:	5b                   	pop    %ebx
  801805:	5e                   	pop    %esi
  801806:	5f                   	pop    %edi
  801807:	5d                   	pop    %ebp
  801808:	c3                   	ret    

00801809 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  801809:	55                   	push   %ebp
  80180a:	89 e5                	mov    %esp,%ebp
  80180c:	57                   	push   %edi
  80180d:	56                   	push   %esi
  80180e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80180f:	ba 00 00 00 00       	mov    $0x0,%edx
  801814:	b8 0e 00 00 00       	mov    $0xe,%eax
  801819:	89 d1                	mov    %edx,%ecx
  80181b:	89 d3                	mov    %edx,%ebx
  80181d:	89 d7                	mov    %edx,%edi
  80181f:	89 d6                	mov    %edx,%esi
  801821:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801823:	5b                   	pop    %ebx
  801824:	5e                   	pop    %esi
  801825:	5f                   	pop    %edi
  801826:	5d                   	pop    %ebp
  801827:	c3                   	ret    

00801828 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char* pck, size_t length){
  801828:	55                   	push   %ebp
  801829:	89 e5                	mov    %esp,%ebp
  80182b:	57                   	push   %edi
  80182c:	56                   	push   %esi
  80182d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80182e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801833:	b8 10 00 00 00       	mov    $0x10,%eax
  801838:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80183b:	8b 55 08             	mov    0x8(%ebp),%edx
  80183e:	89 df                	mov    %ebx,%edi
  801840:	89 de                	mov    %ebx,%esi
  801842:	cd 30                	int    $0x30
}

int 
sys_e1000_transmit(char* pck, size_t length){
	return syscall(SYS_e1000_transmit, 0, (uint32_t)pck, length, 0, 0, 0);
}
  801844:	5b                   	pop    %ebx
  801845:	5e                   	pop    %esi
  801846:	5f                   	pop    %edi
  801847:	5d                   	pop    %ebp
  801848:	c3                   	ret    

00801849 <sys_e1000_receive>:

int 
sys_e1000_receive(char* pck, size_t* length){
  801849:	55                   	push   %ebp
  80184a:	89 e5                	mov    %esp,%ebp
  80184c:	57                   	push   %edi
  80184d:	56                   	push   %esi
  80184e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80184f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801854:	b8 0f 00 00 00       	mov    $0xf,%eax
  801859:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80185c:	8b 55 08             	mov    0x8(%ebp),%edx
  80185f:	89 df                	mov    %ebx,%edi
  801861:	89 de                	mov    %ebx,%esi
  801863:	cd 30                	int    $0x30
}

int 
sys_e1000_receive(char* pck, size_t* length){
	return syscall(SYS_e1000_receive, 0, (uint32_t)pck, (uint32_t)length, 0, 0, 0);
}
  801865:	5b                   	pop    %ebx
  801866:	5e                   	pop    %esi
  801867:	5f                   	pop    %edi
  801868:	5d                   	pop    %ebp
  801869:	c3                   	ret    

0080186a <sys_e1000_get_mac>:

int 
sys_e1000_get_mac(uint8_t* mac_addr){
  80186a:	55                   	push   %ebp
  80186b:	89 e5                	mov    %esp,%ebp
  80186d:	57                   	push   %edi
  80186e:	56                   	push   %esi
  80186f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801870:	b9 00 00 00 00       	mov    $0x0,%ecx
  801875:	b8 11 00 00 00       	mov    $0x11,%eax
  80187a:	8b 55 08             	mov    0x8(%ebp),%edx
  80187d:	89 cb                	mov    %ecx,%ebx
  80187f:	89 cf                	mov    %ecx,%edi
  801881:	89 ce                	mov    %ecx,%esi
  801883:	cd 30                	int    $0x30
}

int 
sys_e1000_get_mac(uint8_t* mac_addr){
	return syscall(SYS_e1000_get_mac, 0, (uint32_t)mac_addr, 0, 0, 0, 0);
}
  801885:	5b                   	pop    %ebx
  801886:	5e                   	pop    %esi
  801887:	5f                   	pop    %edi
  801888:	5d                   	pop    %ebp
  801889:	c3                   	ret    
	...

0080188c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80188c:	55                   	push   %ebp
  80188d:	89 e5                	mov    %esp,%ebp
  80188f:	53                   	push   %ebx
  801890:	83 ec 24             	sub    $0x24,%esp
  801893:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801896:	8b 18                	mov    (%eax),%ebx
	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	if ((err & FEC_WR) == 0)
  801898:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  80189c:	75 20                	jne    8018be <pgfault+0x32>
		panic("pgfault: faulting address [%08x] not a write\n", addr);
  80189e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8018a2:	c7 44 24 08 c4 40 80 	movl   $0x8040c4,0x8(%esp)
  8018a9:	00 
  8018aa:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  8018b1:	00 
  8018b2:	c7 04 24 44 41 80 00 	movl   $0x804144,(%esp)
  8018b9:	e8 6e f1 ff ff       	call   800a2c <_panic>

	void *page_aligned_addr = (void *) ROUNDDOWN(addr, PGSIZE);
  8018be:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t page_num = (uint32_t) page_aligned_addr / PGSIZE;
  8018c4:	89 d8                	mov    %ebx,%eax
  8018c6:	c1 e8 0c             	shr    $0xc,%eax
	if (!(uvpt[page_num] & PTE_COW))
  8018c9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018d0:	f6 c4 08             	test   $0x8,%ah
  8018d3:	75 1c                	jne    8018f1 <pgfault+0x65>
		panic("pgfault: fault was not on a copy-on-write page\n");
  8018d5:	c7 44 24 08 f4 40 80 	movl   $0x8040f4,0x8(%esp)
  8018dc:	00 
  8018dd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8018e4:	00 
  8018e5:	c7 04 24 44 41 80 00 	movl   $0x804144,(%esp)
  8018ec:	e8 3b f1 ff ff       	call   800a2c <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.

	// Allocate
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  8018f1:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8018f8:	00 
  8018f9:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801900:	00 
  801901:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801908:	e8 94 fc ff ff       	call   8015a1 <sys_page_alloc>
  80190d:	85 c0                	test   %eax,%eax
  80190f:	79 20                	jns    801931 <pgfault+0xa5>
		panic("sys_page_alloc: %e\n", r);
  801911:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801915:	c7 44 24 08 4f 41 80 	movl   $0x80414f,0x8(%esp)
  80191c:	00 
  80191d:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  801924:	00 
  801925:	c7 04 24 44 41 80 00 	movl   $0x804144,(%esp)
  80192c:	e8 fb f0 ff ff       	call   800a2c <_panic>

	// Copy over
	void *src_addr = (void *) ROUNDDOWN(addr, PGSIZE);
	memmove(PFTEMP, src_addr, PGSIZE);
  801931:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801938:	00 
  801939:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80193d:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801944:	e8 df f9 ff ff       	call   801328 <memmove>

	// Remap
	if ((r = sys_page_map(0, PFTEMP, 0, src_addr, PTE_P | PTE_U | PTE_W)) < 0)
  801949:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801950:	00 
  801951:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801955:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80195c:	00 
  80195d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801964:	00 
  801965:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80196c:	e8 84 fc ff ff       	call   8015f5 <sys_page_map>
  801971:	85 c0                	test   %eax,%eax
  801973:	79 20                	jns    801995 <pgfault+0x109>
		panic("sys_page_map: %e\n", r);
  801975:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801979:	c7 44 24 08 63 41 80 	movl   $0x804163,0x8(%esp)
  801980:	00 
  801981:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  801988:	00 
  801989:	c7 04 24 44 41 80 00 	movl   $0x804144,(%esp)
  801990:	e8 97 f0 ff ff       	call   800a2c <_panic>

}
  801995:	83 c4 24             	add    $0x24,%esp
  801998:	5b                   	pop    %ebx
  801999:	5d                   	pop    %ebp
  80199a:	c3                   	ret    

0080199b <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80199b:	55                   	push   %ebp
  80199c:	89 e5                	mov    %esp,%ebp
  80199e:	57                   	push   %edi
  80199f:	56                   	push   %esi
  8019a0:	53                   	push   %ebx
  8019a1:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	int r;
	envid_t child_envid;

	set_pgfault_handler(pgfault);
  8019a4:	c7 04 24 8c 18 80 00 	movl   $0x80188c,(%esp)
  8019ab:	e8 40 1d 00 00       	call   8036f0 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8019b0:	ba 07 00 00 00       	mov    $0x7,%edx
  8019b5:	89 d0                	mov    %edx,%eax
  8019b7:	cd 30                	int    $0x30
  8019b9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8019bc:	89 45 e0             	mov    %eax,-0x20(%ebp)

	child_envid = sys_exofork();
	if (child_envid < 0)
  8019bf:	85 c0                	test   %eax,%eax
  8019c1:	79 20                	jns    8019e3 <fork+0x48>
		panic("sys_exofork: %e\n", child_envid);
  8019c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019c7:	c7 44 24 08 75 41 80 	movl   $0x804175,0x8(%esp)
  8019ce:	00 
  8019cf:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  8019d6:	00 
  8019d7:	c7 04 24 44 41 80 00 	movl   $0x804144,(%esp)
  8019de:	e8 49 f0 ff ff       	call   800a2c <_panic>
	if (child_envid == 0) { // child
  8019e3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8019e7:	75 1c                	jne    801a05 <fork+0x6a>
		// Fix thisenv like dumbfork does and return 0
		thisenv = &envs[ENVX(sys_getenvid())];
  8019e9:	e8 75 fb ff ff       	call   801563 <sys_getenvid>
  8019ee:	25 ff 03 00 00       	and    $0x3ff,%eax
  8019f3:	c1 e0 07             	shl    $0x7,%eax
  8019f6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8019fb:	a3 28 64 80 00       	mov    %eax,0x806428
		return 0;
  801a00:	e9 58 02 00 00       	jmp    801c5d <fork+0x2c2>
	set_pgfault_handler(pgfault);

	child_envid = sys_exofork();
	if (child_envid < 0)
		panic("sys_exofork: %e\n", child_envid);
	if (child_envid == 0) { // child
  801a05:	bf 00 00 00 00       	mov    $0x0,%edi
  801a0a:	be 00 00 00 00       	mov    $0x0,%esi
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
  801a0f:	89 f0                	mov    %esi,%eax
  801a11:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  801a14:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801a1b:	a8 01                	test   $0x1,%al
  801a1d:	0f 84 7a 01 00 00    	je     801b9d <fork+0x202>
			((uvpt[page_num] & PTE_P) == PTE_P)) {
  801a23:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  801a2a:	a8 01                	test   $0x1,%al
  801a2c:	0f 84 6b 01 00 00    	je     801b9d <fork+0x202>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	envid_t this_envid = thisenv->env_id;
  801a32:	a1 28 64 80 00       	mov    0x806428,%eax
  801a37:	8b 40 48             	mov    0x48(%eax),%eax
  801a3a:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	if (uvpt[pn] & PTE_SHARE) {
  801a3d:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801a44:	f6 c4 04             	test   $0x4,%ah
  801a47:	74 52                	je     801a9b <fork+0x100>
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  801a49:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801a50:	25 07 0e 00 00       	and    $0xe07,%eax
  801a55:	89 44 24 10          	mov    %eax,0x10(%esp)
  801a59:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801a5d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a60:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a64:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801a68:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a6b:	89 04 24             	mov    %eax,(%esp)
  801a6e:	e8 82 fb ff ff       	call   8015f5 <sys_page_map>
  801a73:	85 c0                	test   %eax,%eax
  801a75:	0f 89 22 01 00 00    	jns    801b9d <fork+0x202>
			panic("sys_page_map: %e\n", r);
  801a7b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a7f:	c7 44 24 08 63 41 80 	movl   $0x804163,0x8(%esp)
  801a86:	00 
  801a87:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  801a8e:	00 
  801a8f:	c7 04 24 44 41 80 00 	movl   $0x804144,(%esp)
  801a96:	e8 91 ef ff ff       	call   800a2c <_panic>
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
  801a9b:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801aa2:	f6 c4 08             	test   $0x8,%ah
  801aa5:	75 0f                	jne    801ab6 <fork+0x11b>
  801aa7:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801aae:	a8 02                	test   $0x2,%al
  801ab0:	0f 84 99 00 00 00    	je     801b4f <fork+0x1b4>
		if (uvpt[pn] & PTE_U)
  801ab6:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801abd:	83 e0 04             	and    $0x4,%eax
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
  801ac0:	83 f8 01             	cmp    $0x1,%eax
  801ac3:	19 db                	sbb    %ebx,%ebx
  801ac5:	83 e3 fc             	and    $0xfffffffc,%ebx
  801ac8:	81 c3 05 08 00 00    	add    $0x805,%ebx
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
		if (uvpt[pn] & PTE_U)
			perm |= PTE_U;

		// Map page COW, U and P in child
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), perm)) < 0)
  801ace:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801ad2:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801ad6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ad9:	89 44 24 08          	mov    %eax,0x8(%esp)
  801add:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801ae1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ae4:	89 04 24             	mov    %eax,(%esp)
  801ae7:	e8 09 fb ff ff       	call   8015f5 <sys_page_map>
  801aec:	85 c0                	test   %eax,%eax
  801aee:	79 20                	jns    801b10 <fork+0x175>
			panic("sys_page_map: %e\n", r);
  801af0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801af4:	c7 44 24 08 63 41 80 	movl   $0x804163,0x8(%esp)
  801afb:	00 
  801afc:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  801b03:	00 
  801b04:	c7 04 24 44 41 80 00 	movl   $0x804144,(%esp)
  801b0b:	e8 1c ef ff ff       	call   800a2c <_panic>

		// Map page COW, U and P in parent
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), this_envid, (void *) (pn*PGSIZE), perm)) < 0)
  801b10:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801b14:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801b18:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b1b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b1f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801b23:	89 04 24             	mov    %eax,(%esp)
  801b26:	e8 ca fa ff ff       	call   8015f5 <sys_page_map>
  801b2b:	85 c0                	test   %eax,%eax
  801b2d:	79 6e                	jns    801b9d <fork+0x202>
			panic("sys_page_map: %e\n", r);
  801b2f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b33:	c7 44 24 08 63 41 80 	movl   $0x804163,0x8(%esp)
  801b3a:	00 
  801b3b:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  801b42:	00 
  801b43:	c7 04 24 44 41 80 00 	movl   $0x804144,(%esp)
  801b4a:	e8 dd ee ff ff       	call   800a2c <_panic>

	} else { // map pages that are present but not writable or COW with their original permissions
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  801b4f:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801b56:	25 07 0e 00 00       	and    $0xe07,%eax
  801b5b:	89 44 24 10          	mov    %eax,0x10(%esp)
  801b5f:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801b63:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b66:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b6a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801b6e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b71:	89 04 24             	mov    %eax,(%esp)
  801b74:	e8 7c fa ff ff       	call   8015f5 <sys_page_map>
  801b79:	85 c0                	test   %eax,%eax
  801b7b:	79 20                	jns    801b9d <fork+0x202>
			panic("sys_page_map: %e\n", r);
  801b7d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b81:	c7 44 24 08 63 41 80 	movl   $0x804163,0x8(%esp)
  801b88:	00 
  801b89:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  801b90:	00 
  801b91:	c7 04 24 44 41 80 00 	movl   $0x804144,(%esp)
  801b98:	e8 8f ee ff ff       	call   800a2c <_panic>
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
  801b9d:	46                   	inc    %esi
  801b9e:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801ba4:	81 fe ff eb 0e 00    	cmp    $0xeebff,%esi
  801baa:	0f 85 5f fe ff ff    	jne    801a0f <fork+0x74>
	}

	// Allocate exception stack space for child. The child can't do this themselves
	// because the mechanism by which it would is to run the pgfault handler, which
	// needs to run on the exception stack (catch 22).
	if ((r = sys_page_alloc(child_envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801bb0:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801bb7:	00 
  801bb8:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801bbf:	ee 
  801bc0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801bc3:	89 04 24             	mov    %eax,(%esp)
  801bc6:	e8 d6 f9 ff ff       	call   8015a1 <sys_page_alloc>
  801bcb:	85 c0                	test   %eax,%eax
  801bcd:	79 20                	jns    801bef <fork+0x254>
		panic("sys_page_alloc: %e\n", r);
  801bcf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bd3:	c7 44 24 08 4f 41 80 	movl   $0x80414f,0x8(%esp)
  801bda:	00 
  801bdb:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  801be2:	00 
  801be3:	c7 04 24 44 41 80 00 	movl   $0x804144,(%esp)
  801bea:	e8 3d ee ff ff       	call   800a2c <_panic>

	// Set page fault handler for the child
	if ((r = sys_env_set_pgfault_upcall(child_envid, _pgfault_upcall)) < 0)
  801bef:	c7 44 24 04 64 37 80 	movl   $0x803764,0x4(%esp)
  801bf6:	00 
  801bf7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801bfa:	89 04 24             	mov    %eax,(%esp)
  801bfd:	e8 3f fb ff ff       	call   801741 <sys_env_set_pgfault_upcall>
  801c02:	85 c0                	test   %eax,%eax
  801c04:	79 20                	jns    801c26 <fork+0x28b>
		panic("sys_env_set_pgfault_upcall: %e\n", r);
  801c06:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c0a:	c7 44 24 08 24 41 80 	movl   $0x804124,0x8(%esp)
  801c11:	00 
  801c12:	c7 44 24 04 a1 00 00 	movl   $0xa1,0x4(%esp)
  801c19:	00 
  801c1a:	c7 04 24 44 41 80 00 	movl   $0x804144,(%esp)
  801c21:	e8 06 ee ff ff       	call   800a2c <_panic>

	// Mark child environment as runnable
	if ((r = sys_env_set_status(child_envid, ENV_RUNNABLE)) < 0)
  801c26:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801c2d:	00 
  801c2e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801c31:	89 04 24             	mov    %eax,(%esp)
  801c34:	e8 62 fa ff ff       	call   80169b <sys_env_set_status>
  801c39:	85 c0                	test   %eax,%eax
  801c3b:	79 20                	jns    801c5d <fork+0x2c2>
		panic("sys_env_set_status: %e\n", r);
  801c3d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c41:	c7 44 24 08 86 41 80 	movl   $0x804186,0x8(%esp)
  801c48:	00 
  801c49:	c7 44 24 04 a5 00 00 	movl   $0xa5,0x4(%esp)
  801c50:	00 
  801c51:	c7 04 24 44 41 80 00 	movl   $0x804144,(%esp)
  801c58:	e8 cf ed ff ff       	call   800a2c <_panic>

	return child_envid;
}
  801c5d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801c60:	83 c4 3c             	add    $0x3c,%esp
  801c63:	5b                   	pop    %ebx
  801c64:	5e                   	pop    %esi
  801c65:	5f                   	pop    %edi
  801c66:	5d                   	pop    %ebp
  801c67:	c3                   	ret    

00801c68 <sfork>:

// Challenge!
int
sfork(void)
{
  801c68:	55                   	push   %ebp
  801c69:	89 e5                	mov    %esp,%ebp
  801c6b:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801c6e:	c7 44 24 08 9e 41 80 	movl   $0x80419e,0x8(%esp)
  801c75:	00 
  801c76:	c7 44 24 04 ae 00 00 	movl   $0xae,0x4(%esp)
  801c7d:	00 
  801c7e:	c7 04 24 44 41 80 00 	movl   $0x804144,(%esp)
  801c85:	e8 a2 ed ff ff       	call   800a2c <_panic>
	...

00801c8c <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801c8c:	55                   	push   %ebp
  801c8d:	89 e5                	mov    %esp,%ebp
  801c8f:	8b 55 08             	mov    0x8(%ebp),%edx
  801c92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c95:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801c98:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801c9a:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801c9d:	83 3a 01             	cmpl   $0x1,(%edx)
  801ca0:	7e 0b                	jle    801cad <argstart+0x21>
  801ca2:	85 c9                	test   %ecx,%ecx
  801ca4:	75 0e                	jne    801cb4 <argstart+0x28>
  801ca6:	ba 00 00 00 00       	mov    $0x0,%edx
  801cab:	eb 0c                	jmp    801cb9 <argstart+0x2d>
  801cad:	ba 00 00 00 00       	mov    $0x0,%edx
  801cb2:	eb 05                	jmp    801cb9 <argstart+0x2d>
  801cb4:	ba 61 3b 80 00       	mov    $0x803b61,%edx
  801cb9:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801cbc:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801cc3:	5d                   	pop    %ebp
  801cc4:	c3                   	ret    

00801cc5 <argnext>:

int
argnext(struct Argstate *args)
{
  801cc5:	55                   	push   %ebp
  801cc6:	89 e5                	mov    %esp,%ebp
  801cc8:	53                   	push   %ebx
  801cc9:	83 ec 14             	sub    $0x14,%esp
  801ccc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801ccf:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801cd6:	8b 43 08             	mov    0x8(%ebx),%eax
  801cd9:	85 c0                	test   %eax,%eax
  801cdb:	74 6c                	je     801d49 <argnext+0x84>
		return -1;

	if (!*args->curarg) {
  801cdd:	80 38 00             	cmpb   $0x0,(%eax)
  801ce0:	75 4d                	jne    801d2f <argnext+0x6a>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801ce2:	8b 0b                	mov    (%ebx),%ecx
  801ce4:	83 39 01             	cmpl   $0x1,(%ecx)
  801ce7:	74 52                	je     801d3b <argnext+0x76>
		    || args->argv[1][0] != '-'
  801ce9:	8b 53 04             	mov    0x4(%ebx),%edx
  801cec:	8b 42 04             	mov    0x4(%edx),%eax
  801cef:	80 38 2d             	cmpb   $0x2d,(%eax)
  801cf2:	75 47                	jne    801d3b <argnext+0x76>
		    || args->argv[1][1] == '\0')
  801cf4:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801cf8:	74 41                	je     801d3b <argnext+0x76>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801cfa:	40                   	inc    %eax
  801cfb:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801cfe:	8b 01                	mov    (%ecx),%eax
  801d00:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801d07:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d0b:	8d 42 08             	lea    0x8(%edx),%eax
  801d0e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d12:	83 c2 04             	add    $0x4,%edx
  801d15:	89 14 24             	mov    %edx,(%esp)
  801d18:	e8 0b f6 ff ff       	call   801328 <memmove>
		(*args->argc)--;
  801d1d:	8b 03                	mov    (%ebx),%eax
  801d1f:	ff 08                	decl   (%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801d21:	8b 43 08             	mov    0x8(%ebx),%eax
  801d24:	80 38 2d             	cmpb   $0x2d,(%eax)
  801d27:	75 06                	jne    801d2f <argnext+0x6a>
  801d29:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801d2d:	74 0c                	je     801d3b <argnext+0x76>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801d2f:	8b 53 08             	mov    0x8(%ebx),%edx
  801d32:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801d35:	42                   	inc    %edx
  801d36:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801d39:	eb 13                	jmp    801d4e <argnext+0x89>

    endofargs:
	args->curarg = 0;
  801d3b:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801d42:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801d47:	eb 05                	jmp    801d4e <argnext+0x89>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  801d49:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801d4e:	83 c4 14             	add    $0x14,%esp
  801d51:	5b                   	pop    %ebx
  801d52:	5d                   	pop    %ebp
  801d53:	c3                   	ret    

00801d54 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801d54:	55                   	push   %ebp
  801d55:	89 e5                	mov    %esp,%ebp
  801d57:	53                   	push   %ebx
  801d58:	83 ec 14             	sub    $0x14,%esp
  801d5b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801d5e:	8b 43 08             	mov    0x8(%ebx),%eax
  801d61:	85 c0                	test   %eax,%eax
  801d63:	74 59                	je     801dbe <argnextvalue+0x6a>
		return 0;
	if (*args->curarg) {
  801d65:	80 38 00             	cmpb   $0x0,(%eax)
  801d68:	74 0c                	je     801d76 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  801d6a:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801d6d:	c7 43 08 61 3b 80 00 	movl   $0x803b61,0x8(%ebx)
  801d74:	eb 43                	jmp    801db9 <argnextvalue+0x65>
	} else if (*args->argc > 1) {
  801d76:	8b 03                	mov    (%ebx),%eax
  801d78:	83 38 01             	cmpl   $0x1,(%eax)
  801d7b:	7e 2e                	jle    801dab <argnextvalue+0x57>
		args->argvalue = args->argv[1];
  801d7d:	8b 53 04             	mov    0x4(%ebx),%edx
  801d80:	8b 4a 04             	mov    0x4(%edx),%ecx
  801d83:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801d86:	8b 00                	mov    (%eax),%eax
  801d88:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801d8f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d93:	8d 42 08             	lea    0x8(%edx),%eax
  801d96:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d9a:	83 c2 04             	add    $0x4,%edx
  801d9d:	89 14 24             	mov    %edx,(%esp)
  801da0:	e8 83 f5 ff ff       	call   801328 <memmove>
		(*args->argc)--;
  801da5:	8b 03                	mov    (%ebx),%eax
  801da7:	ff 08                	decl   (%eax)
  801da9:	eb 0e                	jmp    801db9 <argnextvalue+0x65>
	} else {
		args->argvalue = 0;
  801dab:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801db2:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  801db9:	8b 43 0c             	mov    0xc(%ebx),%eax
  801dbc:	eb 05                	jmp    801dc3 <argnextvalue+0x6f>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  801dbe:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  801dc3:	83 c4 14             	add    $0x14,%esp
  801dc6:	5b                   	pop    %ebx
  801dc7:	5d                   	pop    %ebp
  801dc8:	c3                   	ret    

00801dc9 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  801dc9:	55                   	push   %ebp
  801dca:	89 e5                	mov    %esp,%ebp
  801dcc:	83 ec 18             	sub    $0x18,%esp
  801dcf:	8b 55 08             	mov    0x8(%ebp),%edx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801dd2:	8b 42 0c             	mov    0xc(%edx),%eax
  801dd5:	85 c0                	test   %eax,%eax
  801dd7:	75 08                	jne    801de1 <argvalue+0x18>
  801dd9:	89 14 24             	mov    %edx,(%esp)
  801ddc:	e8 73 ff ff ff       	call   801d54 <argnextvalue>
}
  801de1:	c9                   	leave  
  801de2:	c3                   	ret    
	...

00801de4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801de4:	55                   	push   %ebp
  801de5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801de7:	8b 45 08             	mov    0x8(%ebp),%eax
  801dea:	05 00 00 00 30       	add    $0x30000000,%eax
  801def:	c1 e8 0c             	shr    $0xc,%eax
}
  801df2:	5d                   	pop    %ebp
  801df3:	c3                   	ret    

00801df4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801df4:	55                   	push   %ebp
  801df5:	89 e5                	mov    %esp,%ebp
  801df7:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801dfa:	8b 45 08             	mov    0x8(%ebp),%eax
  801dfd:	89 04 24             	mov    %eax,(%esp)
  801e00:	e8 df ff ff ff       	call   801de4 <fd2num>
  801e05:	05 20 00 0d 00       	add    $0xd0020,%eax
  801e0a:	c1 e0 0c             	shl    $0xc,%eax
}
  801e0d:	c9                   	leave  
  801e0e:	c3                   	ret    

00801e0f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801e0f:	55                   	push   %ebp
  801e10:	89 e5                	mov    %esp,%ebp
  801e12:	53                   	push   %ebx
  801e13:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801e16:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801e1b:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801e1d:	89 c2                	mov    %eax,%edx
  801e1f:	c1 ea 16             	shr    $0x16,%edx
  801e22:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801e29:	f6 c2 01             	test   $0x1,%dl
  801e2c:	74 11                	je     801e3f <fd_alloc+0x30>
  801e2e:	89 c2                	mov    %eax,%edx
  801e30:	c1 ea 0c             	shr    $0xc,%edx
  801e33:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801e3a:	f6 c2 01             	test   $0x1,%dl
  801e3d:	75 09                	jne    801e48 <fd_alloc+0x39>
			*fd_store = fd;
  801e3f:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801e41:	b8 00 00 00 00       	mov    $0x0,%eax
  801e46:	eb 17                	jmp    801e5f <fd_alloc+0x50>
  801e48:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801e4d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801e52:	75 c7                	jne    801e1b <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801e54:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801e5a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801e5f:	5b                   	pop    %ebx
  801e60:	5d                   	pop    %ebp
  801e61:	c3                   	ret    

00801e62 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801e62:	55                   	push   %ebp
  801e63:	89 e5                	mov    %esp,%ebp
  801e65:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801e68:	83 f8 1f             	cmp    $0x1f,%eax
  801e6b:	77 36                	ja     801ea3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801e6d:	05 00 00 0d 00       	add    $0xd0000,%eax
  801e72:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801e75:	89 c2                	mov    %eax,%edx
  801e77:	c1 ea 16             	shr    $0x16,%edx
  801e7a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801e81:	f6 c2 01             	test   $0x1,%dl
  801e84:	74 24                	je     801eaa <fd_lookup+0x48>
  801e86:	89 c2                	mov    %eax,%edx
  801e88:	c1 ea 0c             	shr    $0xc,%edx
  801e8b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801e92:	f6 c2 01             	test   $0x1,%dl
  801e95:	74 1a                	je     801eb1 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801e97:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e9a:	89 02                	mov    %eax,(%edx)
	return 0;
  801e9c:	b8 00 00 00 00       	mov    $0x0,%eax
  801ea1:	eb 13                	jmp    801eb6 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801ea3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801ea8:	eb 0c                	jmp    801eb6 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801eaa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801eaf:	eb 05                	jmp    801eb6 <fd_lookup+0x54>
  801eb1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801eb6:	5d                   	pop    %ebp
  801eb7:	c3                   	ret    

00801eb8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801eb8:	55                   	push   %ebp
  801eb9:	89 e5                	mov    %esp,%ebp
  801ebb:	53                   	push   %ebx
  801ebc:	83 ec 14             	sub    $0x14,%esp
  801ebf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ec2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801ec5:	ba 00 00 00 00       	mov    $0x0,%edx
  801eca:	eb 0e                	jmp    801eda <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801ecc:	39 08                	cmp    %ecx,(%eax)
  801ece:	75 09                	jne    801ed9 <dev_lookup+0x21>
			*dev = devtab[i];
  801ed0:	89 03                	mov    %eax,(%ebx)
			return 0;
  801ed2:	b8 00 00 00 00       	mov    $0x0,%eax
  801ed7:	eb 33                	jmp    801f0c <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801ed9:	42                   	inc    %edx
  801eda:	8b 04 95 30 42 80 00 	mov    0x804230(,%edx,4),%eax
  801ee1:	85 c0                	test   %eax,%eax
  801ee3:	75 e7                	jne    801ecc <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801ee5:	a1 28 64 80 00       	mov    0x806428,%eax
  801eea:	8b 40 48             	mov    0x48(%eax),%eax
  801eed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ef1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ef5:	c7 04 24 b4 41 80 00 	movl   $0x8041b4,(%esp)
  801efc:	e8 23 ec ff ff       	call   800b24 <cprintf>
	*dev = 0;
  801f01:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801f07:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801f0c:	83 c4 14             	add    $0x14,%esp
  801f0f:	5b                   	pop    %ebx
  801f10:	5d                   	pop    %ebp
  801f11:	c3                   	ret    

00801f12 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801f12:	55                   	push   %ebp
  801f13:	89 e5                	mov    %esp,%ebp
  801f15:	56                   	push   %esi
  801f16:	53                   	push   %ebx
  801f17:	83 ec 30             	sub    $0x30,%esp
  801f1a:	8b 75 08             	mov    0x8(%ebp),%esi
  801f1d:	8a 45 0c             	mov    0xc(%ebp),%al
  801f20:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801f23:	89 34 24             	mov    %esi,(%esp)
  801f26:	e8 b9 fe ff ff       	call   801de4 <fd2num>
  801f2b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801f2e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f32:	89 04 24             	mov    %eax,(%esp)
  801f35:	e8 28 ff ff ff       	call   801e62 <fd_lookup>
  801f3a:	89 c3                	mov    %eax,%ebx
  801f3c:	85 c0                	test   %eax,%eax
  801f3e:	78 05                	js     801f45 <fd_close+0x33>
	    || fd != fd2)
  801f40:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801f43:	74 0d                	je     801f52 <fd_close+0x40>
		return (must_exist ? r : 0);
  801f45:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801f49:	75 46                	jne    801f91 <fd_close+0x7f>
  801f4b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f50:	eb 3f                	jmp    801f91 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801f52:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f55:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f59:	8b 06                	mov    (%esi),%eax
  801f5b:	89 04 24             	mov    %eax,(%esp)
  801f5e:	e8 55 ff ff ff       	call   801eb8 <dev_lookup>
  801f63:	89 c3                	mov    %eax,%ebx
  801f65:	85 c0                	test   %eax,%eax
  801f67:	78 18                	js     801f81 <fd_close+0x6f>
		if (dev->dev_close)
  801f69:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f6c:	8b 40 10             	mov    0x10(%eax),%eax
  801f6f:	85 c0                	test   %eax,%eax
  801f71:	74 09                	je     801f7c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801f73:	89 34 24             	mov    %esi,(%esp)
  801f76:	ff d0                	call   *%eax
  801f78:	89 c3                	mov    %eax,%ebx
  801f7a:	eb 05                	jmp    801f81 <fd_close+0x6f>
		else
			r = 0;
  801f7c:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801f81:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f85:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f8c:	e8 b7 f6 ff ff       	call   801648 <sys_page_unmap>
	return r;
}
  801f91:	89 d8                	mov    %ebx,%eax
  801f93:	83 c4 30             	add    $0x30,%esp
  801f96:	5b                   	pop    %ebx
  801f97:	5e                   	pop    %esi
  801f98:	5d                   	pop    %ebp
  801f99:	c3                   	ret    

00801f9a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801f9a:	55                   	push   %ebp
  801f9b:	89 e5                	mov    %esp,%ebp
  801f9d:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fa0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fa3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fa7:	8b 45 08             	mov    0x8(%ebp),%eax
  801faa:	89 04 24             	mov    %eax,(%esp)
  801fad:	e8 b0 fe ff ff       	call   801e62 <fd_lookup>
  801fb2:	85 c0                	test   %eax,%eax
  801fb4:	78 13                	js     801fc9 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801fb6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801fbd:	00 
  801fbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fc1:	89 04 24             	mov    %eax,(%esp)
  801fc4:	e8 49 ff ff ff       	call   801f12 <fd_close>
}
  801fc9:	c9                   	leave  
  801fca:	c3                   	ret    

00801fcb <close_all>:

void
close_all(void)
{
  801fcb:	55                   	push   %ebp
  801fcc:	89 e5                	mov    %esp,%ebp
  801fce:	53                   	push   %ebx
  801fcf:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801fd2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801fd7:	89 1c 24             	mov    %ebx,(%esp)
  801fda:	e8 bb ff ff ff       	call   801f9a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801fdf:	43                   	inc    %ebx
  801fe0:	83 fb 20             	cmp    $0x20,%ebx
  801fe3:	75 f2                	jne    801fd7 <close_all+0xc>
		close(i);
}
  801fe5:	83 c4 14             	add    $0x14,%esp
  801fe8:	5b                   	pop    %ebx
  801fe9:	5d                   	pop    %ebp
  801fea:	c3                   	ret    

00801feb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801feb:	55                   	push   %ebp
  801fec:	89 e5                	mov    %esp,%ebp
  801fee:	57                   	push   %edi
  801fef:	56                   	push   %esi
  801ff0:	53                   	push   %ebx
  801ff1:	83 ec 4c             	sub    $0x4c,%esp
  801ff4:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801ff7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801ffa:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ffe:	8b 45 08             	mov    0x8(%ebp),%eax
  802001:	89 04 24             	mov    %eax,(%esp)
  802004:	e8 59 fe ff ff       	call   801e62 <fd_lookup>
  802009:	89 c3                	mov    %eax,%ebx
  80200b:	85 c0                	test   %eax,%eax
  80200d:	0f 88 e1 00 00 00    	js     8020f4 <dup+0x109>
		return r;
	close(newfdnum);
  802013:	89 3c 24             	mov    %edi,(%esp)
  802016:	e8 7f ff ff ff       	call   801f9a <close>

	newfd = INDEX2FD(newfdnum);
  80201b:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  802021:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  802024:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802027:	89 04 24             	mov    %eax,(%esp)
  80202a:	e8 c5 fd ff ff       	call   801df4 <fd2data>
  80202f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  802031:	89 34 24             	mov    %esi,(%esp)
  802034:	e8 bb fd ff ff       	call   801df4 <fd2data>
  802039:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80203c:	89 d8                	mov    %ebx,%eax
  80203e:	c1 e8 16             	shr    $0x16,%eax
  802041:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802048:	a8 01                	test   $0x1,%al
  80204a:	74 46                	je     802092 <dup+0xa7>
  80204c:	89 d8                	mov    %ebx,%eax
  80204e:	c1 e8 0c             	shr    $0xc,%eax
  802051:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802058:	f6 c2 01             	test   $0x1,%dl
  80205b:	74 35                	je     802092 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80205d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802064:	25 07 0e 00 00       	and    $0xe07,%eax
  802069:	89 44 24 10          	mov    %eax,0x10(%esp)
  80206d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  802070:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802074:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80207b:	00 
  80207c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802080:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802087:	e8 69 f5 ff ff       	call   8015f5 <sys_page_map>
  80208c:	89 c3                	mov    %eax,%ebx
  80208e:	85 c0                	test   %eax,%eax
  802090:	78 3b                	js     8020cd <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802092:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802095:	89 c2                	mov    %eax,%edx
  802097:	c1 ea 0c             	shr    $0xc,%edx
  80209a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8020a1:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8020a7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8020ab:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8020af:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8020b6:	00 
  8020b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020c2:	e8 2e f5 ff ff       	call   8015f5 <sys_page_map>
  8020c7:	89 c3                	mov    %eax,%ebx
  8020c9:	85 c0                	test   %eax,%eax
  8020cb:	79 25                	jns    8020f2 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8020cd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020d8:	e8 6b f5 ff ff       	call   801648 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8020dd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8020e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020eb:	e8 58 f5 ff ff       	call   801648 <sys_page_unmap>
	return r;
  8020f0:	eb 02                	jmp    8020f4 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8020f2:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8020f4:	89 d8                	mov    %ebx,%eax
  8020f6:	83 c4 4c             	add    $0x4c,%esp
  8020f9:	5b                   	pop    %ebx
  8020fa:	5e                   	pop    %esi
  8020fb:	5f                   	pop    %edi
  8020fc:	5d                   	pop    %ebp
  8020fd:	c3                   	ret    

008020fe <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8020fe:	55                   	push   %ebp
  8020ff:	89 e5                	mov    %esp,%ebp
  802101:	53                   	push   %ebx
  802102:	83 ec 24             	sub    $0x24,%esp
  802105:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802108:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80210b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80210f:	89 1c 24             	mov    %ebx,(%esp)
  802112:	e8 4b fd ff ff       	call   801e62 <fd_lookup>
  802117:	85 c0                	test   %eax,%eax
  802119:	78 6d                	js     802188 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80211b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80211e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802122:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802125:	8b 00                	mov    (%eax),%eax
  802127:	89 04 24             	mov    %eax,(%esp)
  80212a:	e8 89 fd ff ff       	call   801eb8 <dev_lookup>
  80212f:	85 c0                	test   %eax,%eax
  802131:	78 55                	js     802188 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802133:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802136:	8b 50 08             	mov    0x8(%eax),%edx
  802139:	83 e2 03             	and    $0x3,%edx
  80213c:	83 fa 01             	cmp    $0x1,%edx
  80213f:	75 23                	jne    802164 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  802141:	a1 28 64 80 00       	mov    0x806428,%eax
  802146:	8b 40 48             	mov    0x48(%eax),%eax
  802149:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80214d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802151:	c7 04 24 f5 41 80 00 	movl   $0x8041f5,(%esp)
  802158:	e8 c7 e9 ff ff       	call   800b24 <cprintf>
		return -E_INVAL;
  80215d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802162:	eb 24                	jmp    802188 <read+0x8a>
	}
	if (!dev->dev_read)
  802164:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802167:	8b 52 08             	mov    0x8(%edx),%edx
  80216a:	85 d2                	test   %edx,%edx
  80216c:	74 15                	je     802183 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80216e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  802171:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802175:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802178:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80217c:	89 04 24             	mov    %eax,(%esp)
  80217f:	ff d2                	call   *%edx
  802181:	eb 05                	jmp    802188 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  802183:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  802188:	83 c4 24             	add    $0x24,%esp
  80218b:	5b                   	pop    %ebx
  80218c:	5d                   	pop    %ebp
  80218d:	c3                   	ret    

0080218e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80218e:	55                   	push   %ebp
  80218f:	89 e5                	mov    %esp,%ebp
  802191:	57                   	push   %edi
  802192:	56                   	push   %esi
  802193:	53                   	push   %ebx
  802194:	83 ec 1c             	sub    $0x1c,%esp
  802197:	8b 7d 08             	mov    0x8(%ebp),%edi
  80219a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80219d:	bb 00 00 00 00       	mov    $0x0,%ebx
  8021a2:	eb 23                	jmp    8021c7 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8021a4:	89 f0                	mov    %esi,%eax
  8021a6:	29 d8                	sub    %ebx,%eax
  8021a8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021af:	01 d8                	add    %ebx,%eax
  8021b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021b5:	89 3c 24             	mov    %edi,(%esp)
  8021b8:	e8 41 ff ff ff       	call   8020fe <read>
		if (m < 0)
  8021bd:	85 c0                	test   %eax,%eax
  8021bf:	78 10                	js     8021d1 <readn+0x43>
			return m;
		if (m == 0)
  8021c1:	85 c0                	test   %eax,%eax
  8021c3:	74 0a                	je     8021cf <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8021c5:	01 c3                	add    %eax,%ebx
  8021c7:	39 f3                	cmp    %esi,%ebx
  8021c9:	72 d9                	jb     8021a4 <readn+0x16>
  8021cb:	89 d8                	mov    %ebx,%eax
  8021cd:	eb 02                	jmp    8021d1 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8021cf:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8021d1:	83 c4 1c             	add    $0x1c,%esp
  8021d4:	5b                   	pop    %ebx
  8021d5:	5e                   	pop    %esi
  8021d6:	5f                   	pop    %edi
  8021d7:	5d                   	pop    %ebp
  8021d8:	c3                   	ret    

008021d9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8021d9:	55                   	push   %ebp
  8021da:	89 e5                	mov    %esp,%ebp
  8021dc:	53                   	push   %ebx
  8021dd:	83 ec 24             	sub    $0x24,%esp
  8021e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8021e3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8021e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021ea:	89 1c 24             	mov    %ebx,(%esp)
  8021ed:	e8 70 fc ff ff       	call   801e62 <fd_lookup>
  8021f2:	85 c0                	test   %eax,%eax
  8021f4:	78 68                	js     80225e <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8021f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802200:	8b 00                	mov    (%eax),%eax
  802202:	89 04 24             	mov    %eax,(%esp)
  802205:	e8 ae fc ff ff       	call   801eb8 <dev_lookup>
  80220a:	85 c0                	test   %eax,%eax
  80220c:	78 50                	js     80225e <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80220e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802211:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802215:	75 23                	jne    80223a <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802217:	a1 28 64 80 00       	mov    0x806428,%eax
  80221c:	8b 40 48             	mov    0x48(%eax),%eax
  80221f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802223:	89 44 24 04          	mov    %eax,0x4(%esp)
  802227:	c7 04 24 11 42 80 00 	movl   $0x804211,(%esp)
  80222e:	e8 f1 e8 ff ff       	call   800b24 <cprintf>
		return -E_INVAL;
  802233:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802238:	eb 24                	jmp    80225e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80223a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80223d:	8b 52 0c             	mov    0xc(%edx),%edx
  802240:	85 d2                	test   %edx,%edx
  802242:	74 15                	je     802259 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802244:	8b 4d 10             	mov    0x10(%ebp),%ecx
  802247:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80224b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80224e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802252:	89 04 24             	mov    %eax,(%esp)
  802255:	ff d2                	call   *%edx
  802257:	eb 05                	jmp    80225e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  802259:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80225e:	83 c4 24             	add    $0x24,%esp
  802261:	5b                   	pop    %ebx
  802262:	5d                   	pop    %ebp
  802263:	c3                   	ret    

00802264 <seek>:

int
seek(int fdnum, off_t offset)
{
  802264:	55                   	push   %ebp
  802265:	89 e5                	mov    %esp,%ebp
  802267:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80226a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80226d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802271:	8b 45 08             	mov    0x8(%ebp),%eax
  802274:	89 04 24             	mov    %eax,(%esp)
  802277:	e8 e6 fb ff ff       	call   801e62 <fd_lookup>
  80227c:	85 c0                	test   %eax,%eax
  80227e:	78 0e                	js     80228e <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  802280:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802283:	8b 55 0c             	mov    0xc(%ebp),%edx
  802286:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802289:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80228e:	c9                   	leave  
  80228f:	c3                   	ret    

00802290 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802290:	55                   	push   %ebp
  802291:	89 e5                	mov    %esp,%ebp
  802293:	53                   	push   %ebx
  802294:	83 ec 24             	sub    $0x24,%esp
  802297:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80229a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80229d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022a1:	89 1c 24             	mov    %ebx,(%esp)
  8022a4:	e8 b9 fb ff ff       	call   801e62 <fd_lookup>
  8022a9:	85 c0                	test   %eax,%eax
  8022ab:	78 61                	js     80230e <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8022ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022b7:	8b 00                	mov    (%eax),%eax
  8022b9:	89 04 24             	mov    %eax,(%esp)
  8022bc:	e8 f7 fb ff ff       	call   801eb8 <dev_lookup>
  8022c1:	85 c0                	test   %eax,%eax
  8022c3:	78 49                	js     80230e <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8022c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022c8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8022cc:	75 23                	jne    8022f1 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8022ce:	a1 28 64 80 00       	mov    0x806428,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8022d3:	8b 40 48             	mov    0x48(%eax),%eax
  8022d6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022de:	c7 04 24 d4 41 80 00 	movl   $0x8041d4,(%esp)
  8022e5:	e8 3a e8 ff ff       	call   800b24 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8022ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8022ef:	eb 1d                	jmp    80230e <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8022f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8022f4:	8b 52 18             	mov    0x18(%edx),%edx
  8022f7:	85 d2                	test   %edx,%edx
  8022f9:	74 0e                	je     802309 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8022fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8022fe:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802302:	89 04 24             	mov    %eax,(%esp)
  802305:	ff d2                	call   *%edx
  802307:	eb 05                	jmp    80230e <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  802309:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80230e:	83 c4 24             	add    $0x24,%esp
  802311:	5b                   	pop    %ebx
  802312:	5d                   	pop    %ebp
  802313:	c3                   	ret    

00802314 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802314:	55                   	push   %ebp
  802315:	89 e5                	mov    %esp,%ebp
  802317:	53                   	push   %ebx
  802318:	83 ec 24             	sub    $0x24,%esp
  80231b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80231e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802321:	89 44 24 04          	mov    %eax,0x4(%esp)
  802325:	8b 45 08             	mov    0x8(%ebp),%eax
  802328:	89 04 24             	mov    %eax,(%esp)
  80232b:	e8 32 fb ff ff       	call   801e62 <fd_lookup>
  802330:	85 c0                	test   %eax,%eax
  802332:	78 52                	js     802386 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802334:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802337:	89 44 24 04          	mov    %eax,0x4(%esp)
  80233b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80233e:	8b 00                	mov    (%eax),%eax
  802340:	89 04 24             	mov    %eax,(%esp)
  802343:	e8 70 fb ff ff       	call   801eb8 <dev_lookup>
  802348:	85 c0                	test   %eax,%eax
  80234a:	78 3a                	js     802386 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  80234c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80234f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802353:	74 2c                	je     802381 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802355:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802358:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80235f:	00 00 00 
	stat->st_isdir = 0;
  802362:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802369:	00 00 00 
	stat->st_dev = dev;
  80236c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802372:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802376:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802379:	89 14 24             	mov    %edx,(%esp)
  80237c:	ff 50 14             	call   *0x14(%eax)
  80237f:	eb 05                	jmp    802386 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  802381:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  802386:	83 c4 24             	add    $0x24,%esp
  802389:	5b                   	pop    %ebx
  80238a:	5d                   	pop    %ebp
  80238b:	c3                   	ret    

0080238c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80238c:	55                   	push   %ebp
  80238d:	89 e5                	mov    %esp,%ebp
  80238f:	56                   	push   %esi
  802390:	53                   	push   %ebx
  802391:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802394:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80239b:	00 
  80239c:	8b 45 08             	mov    0x8(%ebp),%eax
  80239f:	89 04 24             	mov    %eax,(%esp)
  8023a2:	e8 2d 02 00 00       	call   8025d4 <open>
  8023a7:	89 c3                	mov    %eax,%ebx
  8023a9:	85 c0                	test   %eax,%eax
  8023ab:	78 1b                	js     8023c8 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8023ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023b4:	89 1c 24             	mov    %ebx,(%esp)
  8023b7:	e8 58 ff ff ff       	call   802314 <fstat>
  8023bc:	89 c6                	mov    %eax,%esi
	close(fd);
  8023be:	89 1c 24             	mov    %ebx,(%esp)
  8023c1:	e8 d4 fb ff ff       	call   801f9a <close>
	return r;
  8023c6:	89 f3                	mov    %esi,%ebx
}
  8023c8:	89 d8                	mov    %ebx,%eax
  8023ca:	83 c4 10             	add    $0x10,%esp
  8023cd:	5b                   	pop    %ebx
  8023ce:	5e                   	pop    %esi
  8023cf:	5d                   	pop    %ebp
  8023d0:	c3                   	ret    
  8023d1:	00 00                	add    %al,(%eax)
	...

008023d4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8023d4:	55                   	push   %ebp
  8023d5:	89 e5                	mov    %esp,%ebp
  8023d7:	56                   	push   %esi
  8023d8:	53                   	push   %ebx
  8023d9:	83 ec 10             	sub    $0x10,%esp
  8023dc:	89 c3                	mov    %eax,%ebx
  8023de:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8023e0:	83 3d 20 64 80 00 00 	cmpl   $0x0,0x806420
  8023e7:	75 11                	jne    8023fa <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8023e9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8023f0:	e8 6a 14 00 00       	call   80385f <ipc_find_env>
  8023f5:	a3 20 64 80 00       	mov    %eax,0x806420
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8023fa:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  802401:	00 
  802402:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  802409:	00 
  80240a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80240e:	a1 20 64 80 00       	mov    0x806420,%eax
  802413:	89 04 24             	mov    %eax,(%esp)
  802416:	e8 d6 13 00 00       	call   8037f1 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80241b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802422:	00 
  802423:	89 74 24 04          	mov    %esi,0x4(%esp)
  802427:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80242e:	e8 55 13 00 00       	call   803788 <ipc_recv>
}
  802433:	83 c4 10             	add    $0x10,%esp
  802436:	5b                   	pop    %ebx
  802437:	5e                   	pop    %esi
  802438:	5d                   	pop    %ebp
  802439:	c3                   	ret    

0080243a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80243a:	55                   	push   %ebp
  80243b:	89 e5                	mov    %esp,%ebp
  80243d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802440:	8b 45 08             	mov    0x8(%ebp),%eax
  802443:	8b 40 0c             	mov    0xc(%eax),%eax
  802446:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  80244b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80244e:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802453:	ba 00 00 00 00       	mov    $0x0,%edx
  802458:	b8 02 00 00 00       	mov    $0x2,%eax
  80245d:	e8 72 ff ff ff       	call   8023d4 <fsipc>
}
  802462:	c9                   	leave  
  802463:	c3                   	ret    

00802464 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802464:	55                   	push   %ebp
  802465:	89 e5                	mov    %esp,%ebp
  802467:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80246a:	8b 45 08             	mov    0x8(%ebp),%eax
  80246d:	8b 40 0c             	mov    0xc(%eax),%eax
  802470:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  802475:	ba 00 00 00 00       	mov    $0x0,%edx
  80247a:	b8 06 00 00 00       	mov    $0x6,%eax
  80247f:	e8 50 ff ff ff       	call   8023d4 <fsipc>
}
  802484:	c9                   	leave  
  802485:	c3                   	ret    

00802486 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  802486:	55                   	push   %ebp
  802487:	89 e5                	mov    %esp,%ebp
  802489:	53                   	push   %ebx
  80248a:	83 ec 14             	sub    $0x14,%esp
  80248d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802490:	8b 45 08             	mov    0x8(%ebp),%eax
  802493:	8b 40 0c             	mov    0xc(%eax),%eax
  802496:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80249b:	ba 00 00 00 00       	mov    $0x0,%edx
  8024a0:	b8 05 00 00 00       	mov    $0x5,%eax
  8024a5:	e8 2a ff ff ff       	call   8023d4 <fsipc>
  8024aa:	85 c0                	test   %eax,%eax
  8024ac:	78 2b                	js     8024d9 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8024ae:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8024b5:	00 
  8024b6:	89 1c 24             	mov    %ebx,(%esp)
  8024b9:	e8 f1 ec ff ff       	call   8011af <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8024be:	a1 80 70 80 00       	mov    0x807080,%eax
  8024c3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8024c9:	a1 84 70 80 00       	mov    0x807084,%eax
  8024ce:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8024d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8024d9:	83 c4 14             	add    $0x14,%esp
  8024dc:	5b                   	pop    %ebx
  8024dd:	5d                   	pop    %ebp
  8024de:	c3                   	ret    

008024df <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8024df:	55                   	push   %ebp
  8024e0:	89 e5                	mov    %esp,%ebp
  8024e2:	83 ec 18             	sub    $0x18,%esp
  8024e5:	8b 55 10             	mov    0x10(%ebp),%edx
  8024e8:	89 d0                	mov    %edx,%eax
  8024ea:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  8024f0:	76 05                	jbe    8024f7 <devfile_write+0x18>
  8024f2:	b8 00 10 00 00       	mov    $0x1000,%eax
	//panic("devfile_write not implemented");
	int r;
	//uint32_t maxsize = BLKSIZE - sizeof(int) - sizeof(size_t);	
	if (n > BLKSIZE)
		n = BLKSIZE;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8024f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8024fa:	8b 52 0c             	mov    0xc(%edx),%edx
  8024fd:	89 15 00 70 80 00    	mov    %edx,0x807000
	fsipcbuf.write.req_n = n;
  802503:	a3 04 70 80 00       	mov    %eax,0x807004
	memmove(fsipcbuf.write.req_buf, buf, n);
  802508:	89 44 24 08          	mov    %eax,0x8(%esp)
  80250c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80250f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802513:	c7 04 24 08 70 80 00 	movl   $0x807008,(%esp)
  80251a:	e8 09 ee ff ff       	call   801328 <memmove>
	 
	return fsipc(FSREQ_WRITE, NULL);
  80251f:	ba 00 00 00 00       	mov    $0x0,%edx
  802524:	b8 04 00 00 00       	mov    $0x4,%eax
  802529:	e8 a6 fe ff ff       	call   8023d4 <fsipc>
}
  80252e:	c9                   	leave  
  80252f:	c3                   	ret    

00802530 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802530:	55                   	push   %ebp
  802531:	89 e5                	mov    %esp,%ebp
  802533:	56                   	push   %esi
  802534:	53                   	push   %ebx
  802535:	83 ec 10             	sub    $0x10,%esp
  802538:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80253b:	8b 45 08             	mov    0x8(%ebp),%eax
  80253e:	8b 40 0c             	mov    0xc(%eax),%eax
  802541:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  802546:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80254c:	ba 00 00 00 00       	mov    $0x0,%edx
  802551:	b8 03 00 00 00       	mov    $0x3,%eax
  802556:	e8 79 fe ff ff       	call   8023d4 <fsipc>
  80255b:	89 c3                	mov    %eax,%ebx
  80255d:	85 c0                	test   %eax,%eax
  80255f:	78 6a                	js     8025cb <devfile_read+0x9b>
		return r;
	assert(r <= n);
  802561:	39 c6                	cmp    %eax,%esi
  802563:	73 24                	jae    802589 <devfile_read+0x59>
  802565:	c7 44 24 0c 44 42 80 	movl   $0x804244,0xc(%esp)
  80256c:	00 
  80256d:	c7 44 24 08 92 3c 80 	movl   $0x803c92,0x8(%esp)
  802574:	00 
  802575:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  80257c:	00 
  80257d:	c7 04 24 4b 42 80 00 	movl   $0x80424b,(%esp)
  802584:	e8 a3 e4 ff ff       	call   800a2c <_panic>
	assert(r <= PGSIZE);
  802589:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80258e:	7e 24                	jle    8025b4 <devfile_read+0x84>
  802590:	c7 44 24 0c 56 42 80 	movl   $0x804256,0xc(%esp)
  802597:	00 
  802598:	c7 44 24 08 92 3c 80 	movl   $0x803c92,0x8(%esp)
  80259f:	00 
  8025a0:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8025a7:	00 
  8025a8:	c7 04 24 4b 42 80 00 	movl   $0x80424b,(%esp)
  8025af:	e8 78 e4 ff ff       	call   800a2c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8025b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8025b8:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8025bf:	00 
  8025c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025c3:	89 04 24             	mov    %eax,(%esp)
  8025c6:	e8 5d ed ff ff       	call   801328 <memmove>
	return r;
}
  8025cb:	89 d8                	mov    %ebx,%eax
  8025cd:	83 c4 10             	add    $0x10,%esp
  8025d0:	5b                   	pop    %ebx
  8025d1:	5e                   	pop    %esi
  8025d2:	5d                   	pop    %ebp
  8025d3:	c3                   	ret    

008025d4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8025d4:	55                   	push   %ebp
  8025d5:	89 e5                	mov    %esp,%ebp
  8025d7:	56                   	push   %esi
  8025d8:	53                   	push   %ebx
  8025d9:	83 ec 20             	sub    $0x20,%esp
  8025dc:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8025df:	89 34 24             	mov    %esi,(%esp)
  8025e2:	e8 95 eb ff ff       	call   80117c <strlen>
  8025e7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8025ec:	7f 60                	jg     80264e <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8025ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025f1:	89 04 24             	mov    %eax,(%esp)
  8025f4:	e8 16 f8 ff ff       	call   801e0f <fd_alloc>
  8025f9:	89 c3                	mov    %eax,%ebx
  8025fb:	85 c0                	test   %eax,%eax
  8025fd:	78 54                	js     802653 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8025ff:	89 74 24 04          	mov    %esi,0x4(%esp)
  802603:	c7 04 24 00 70 80 00 	movl   $0x807000,(%esp)
  80260a:	e8 a0 eb ff ff       	call   8011af <strcpy>
	fsipcbuf.open.req_omode = mode;
  80260f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802612:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  802617:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80261a:	b8 01 00 00 00       	mov    $0x1,%eax
  80261f:	e8 b0 fd ff ff       	call   8023d4 <fsipc>
  802624:	89 c3                	mov    %eax,%ebx
  802626:	85 c0                	test   %eax,%eax
  802628:	79 15                	jns    80263f <open+0x6b>
		fd_close(fd, 0);
  80262a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802631:	00 
  802632:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802635:	89 04 24             	mov    %eax,(%esp)
  802638:	e8 d5 f8 ff ff       	call   801f12 <fd_close>
		return r;
  80263d:	eb 14                	jmp    802653 <open+0x7f>
	}

	return fd2num(fd);
  80263f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802642:	89 04 24             	mov    %eax,(%esp)
  802645:	e8 9a f7 ff ff       	call   801de4 <fd2num>
  80264a:	89 c3                	mov    %eax,%ebx
  80264c:	eb 05                	jmp    802653 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80264e:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  802653:	89 d8                	mov    %ebx,%eax
  802655:	83 c4 20             	add    $0x20,%esp
  802658:	5b                   	pop    %ebx
  802659:	5e                   	pop    %esi
  80265a:	5d                   	pop    %ebp
  80265b:	c3                   	ret    

0080265c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80265c:	55                   	push   %ebp
  80265d:	89 e5                	mov    %esp,%ebp
  80265f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  802662:	ba 00 00 00 00       	mov    $0x0,%edx
  802667:	b8 08 00 00 00       	mov    $0x8,%eax
  80266c:	e8 63 fd ff ff       	call   8023d4 <fsipc>
}
  802671:	c9                   	leave  
  802672:	c3                   	ret    
	...

00802674 <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  802674:	55                   	push   %ebp
  802675:	89 e5                	mov    %esp,%ebp
  802677:	53                   	push   %ebx
  802678:	83 ec 14             	sub    $0x14,%esp
  80267b:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  80267d:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  802681:	7e 32                	jle    8026b5 <writebuf+0x41>
		ssize_t result = write(b->fd, b->buf, b->idx);
  802683:	8b 40 04             	mov    0x4(%eax),%eax
  802686:	89 44 24 08          	mov    %eax,0x8(%esp)
  80268a:	8d 43 10             	lea    0x10(%ebx),%eax
  80268d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802691:	8b 03                	mov    (%ebx),%eax
  802693:	89 04 24             	mov    %eax,(%esp)
  802696:	e8 3e fb ff ff       	call   8021d9 <write>
		if (result > 0)
  80269b:	85 c0                	test   %eax,%eax
  80269d:	7e 03                	jle    8026a2 <writebuf+0x2e>
			b->result += result;
  80269f:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8026a2:	39 43 04             	cmp    %eax,0x4(%ebx)
  8026a5:	74 0e                	je     8026b5 <writebuf+0x41>
			b->error = (result < 0 ? result : 0);
  8026a7:	89 c2                	mov    %eax,%edx
  8026a9:	85 c0                	test   %eax,%eax
  8026ab:	7e 05                	jle    8026b2 <writebuf+0x3e>
  8026ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8026b2:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  8026b5:	83 c4 14             	add    $0x14,%esp
  8026b8:	5b                   	pop    %ebx
  8026b9:	5d                   	pop    %ebp
  8026ba:	c3                   	ret    

008026bb <putch>:

static void
putch(int ch, void *thunk)
{
  8026bb:	55                   	push   %ebp
  8026bc:	89 e5                	mov    %esp,%ebp
  8026be:	53                   	push   %ebx
  8026bf:	83 ec 04             	sub    $0x4,%esp
  8026c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8026c5:	8b 43 04             	mov    0x4(%ebx),%eax
  8026c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8026cb:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  8026cf:	40                   	inc    %eax
  8026d0:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  8026d3:	3d 00 01 00 00       	cmp    $0x100,%eax
  8026d8:	75 0e                	jne    8026e8 <putch+0x2d>
		writebuf(b);
  8026da:	89 d8                	mov    %ebx,%eax
  8026dc:	e8 93 ff ff ff       	call   802674 <writebuf>
		b->idx = 0;
  8026e1:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8026e8:	83 c4 04             	add    $0x4,%esp
  8026eb:	5b                   	pop    %ebx
  8026ec:	5d                   	pop    %ebp
  8026ed:	c3                   	ret    

008026ee <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8026ee:	55                   	push   %ebp
  8026ef:	89 e5                	mov    %esp,%ebp
  8026f1:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  8026f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8026fa:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  802700:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  802707:	00 00 00 
	b.result = 0;
  80270a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  802711:	00 00 00 
	b.error = 1;
  802714:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  80271b:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  80271e:	8b 45 10             	mov    0x10(%ebp),%eax
  802721:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802725:	8b 45 0c             	mov    0xc(%ebp),%eax
  802728:	89 44 24 08          	mov    %eax,0x8(%esp)
  80272c:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  802732:	89 44 24 04          	mov    %eax,0x4(%esp)
  802736:	c7 04 24 bb 26 80 00 	movl   $0x8026bb,(%esp)
  80273d:	e8 44 e5 ff ff       	call   800c86 <vprintfmt>
	if (b.idx > 0)
  802742:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  802749:	7e 0b                	jle    802756 <vfprintf+0x68>
		writebuf(&b);
  80274b:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  802751:	e8 1e ff ff ff       	call   802674 <writebuf>

	return (b.result ? b.result : b.error);
  802756:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80275c:	85 c0                	test   %eax,%eax
  80275e:	75 06                	jne    802766 <vfprintf+0x78>
  802760:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  802766:	c9                   	leave  
  802767:	c3                   	ret    

00802768 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  802768:	55                   	push   %ebp
  802769:	89 e5                	mov    %esp,%ebp
  80276b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80276e:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  802771:	89 44 24 08          	mov    %eax,0x8(%esp)
  802775:	8b 45 0c             	mov    0xc(%ebp),%eax
  802778:	89 44 24 04          	mov    %eax,0x4(%esp)
  80277c:	8b 45 08             	mov    0x8(%ebp),%eax
  80277f:	89 04 24             	mov    %eax,(%esp)
  802782:	e8 67 ff ff ff       	call   8026ee <vfprintf>
	va_end(ap);

	return cnt;
}
  802787:	c9                   	leave  
  802788:	c3                   	ret    

00802789 <printf>:

int
printf(const char *fmt, ...)
{
  802789:	55                   	push   %ebp
  80278a:	89 e5                	mov    %esp,%ebp
  80278c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80278f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  802792:	89 44 24 08          	mov    %eax,0x8(%esp)
  802796:	8b 45 08             	mov    0x8(%ebp),%eax
  802799:	89 44 24 04          	mov    %eax,0x4(%esp)
  80279d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8027a4:	e8 45 ff ff ff       	call   8026ee <vfprintf>
	va_end(ap);

	return cnt;
}
  8027a9:	c9                   	leave  
  8027aa:	c3                   	ret    
	...

008027ac <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8027ac:	55                   	push   %ebp
  8027ad:	89 e5                	mov    %esp,%ebp
  8027af:	57                   	push   %edi
  8027b0:	56                   	push   %esi
  8027b1:	53                   	push   %ebx
  8027b2:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8027b8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8027bf:	00 
  8027c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8027c3:	89 04 24             	mov    %eax,(%esp)
  8027c6:	e8 09 fe ff ff       	call   8025d4 <open>
  8027cb:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
  8027d1:	85 c0                	test   %eax,%eax
  8027d3:	0f 88 86 05 00 00    	js     802d5f <spawn+0x5b3>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8027d9:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8027e0:	00 
  8027e1:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8027e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027eb:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  8027f1:	89 04 24             	mov    %eax,(%esp)
  8027f4:	e8 95 f9 ff ff       	call   80218e <readn>
  8027f9:	3d 00 02 00 00       	cmp    $0x200,%eax
  8027fe:	75 0c                	jne    80280c <spawn+0x60>
	    || elf->e_magic != ELF_MAGIC) {
  802800:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  802807:	45 4c 46 
  80280a:	74 3b                	je     802847 <spawn+0x9b>
		close(fd);
  80280c:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  802812:	89 04 24             	mov    %eax,(%esp)
  802815:	e8 80 f7 ff ff       	call   801f9a <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  80281a:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  802821:	46 
  802822:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  802828:	89 44 24 04          	mov    %eax,0x4(%esp)
  80282c:	c7 04 24 62 42 80 00 	movl   $0x804262,(%esp)
  802833:	e8 ec e2 ff ff       	call   800b24 <cprintf>
		return -E_NOT_EXEC;
  802838:	c7 85 88 fd ff ff f2 	movl   $0xfffffff2,-0x278(%ebp)
  80283f:	ff ff ff 
  802842:	e9 24 05 00 00       	jmp    802d6b <spawn+0x5bf>
  802847:	ba 07 00 00 00       	mov    $0x7,%edx
  80284c:	89 d0                	mov    %edx,%eax
  80284e:	cd 30                	int    $0x30
  802850:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  802856:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  80285c:	85 c0                	test   %eax,%eax
  80285e:	0f 88 07 05 00 00    	js     802d6b <spawn+0x5bf>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  802864:	89 c6                	mov    %eax,%esi
  802866:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  80286c:	c1 e6 07             	shl    $0x7,%esi
  80286f:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  802875:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  80287b:	b9 11 00 00 00       	mov    $0x11,%ecx
  802880:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  802882:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  802888:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80288e:	be 00 00 00 00       	mov    $0x0,%esi
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  802893:	bb 00 00 00 00       	mov    $0x0,%ebx
  802898:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80289b:	eb 0d                	jmp    8028aa <spawn+0xfe>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  80289d:	89 04 24             	mov    %eax,(%esp)
  8028a0:	e8 d7 e8 ff ff       	call   80117c <strlen>
  8028a5:	8d 5c 18 01          	lea    0x1(%eax,%ebx,1),%ebx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8028a9:	46                   	inc    %esi
  8028aa:	89 f2                	mov    %esi,%edx
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  8028ac:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8028b3:	8b 04 b7             	mov    (%edi,%esi,4),%eax
  8028b6:	85 c0                	test   %eax,%eax
  8028b8:	75 e3                	jne    80289d <spawn+0xf1>
  8028ba:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
  8028c0:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8028c6:	bf 00 10 40 00       	mov    $0x401000,%edi
  8028cb:	29 df                	sub    %ebx,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8028cd:	89 f8                	mov    %edi,%eax
  8028cf:	83 e0 fc             	and    $0xfffffffc,%eax
  8028d2:	f7 d2                	not    %edx
  8028d4:	8d 14 90             	lea    (%eax,%edx,4),%edx
  8028d7:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8028dd:	89 d0                	mov    %edx,%eax
  8028df:	83 e8 08             	sub    $0x8,%eax
  8028e2:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8028e7:	0f 86 8f 04 00 00    	jbe    802d7c <spawn+0x5d0>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8028ed:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8028f4:	00 
  8028f5:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8028fc:	00 
  8028fd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802904:	e8 98 ec ff ff       	call   8015a1 <sys_page_alloc>
  802909:	85 c0                	test   %eax,%eax
  80290b:	0f 88 70 04 00 00    	js     802d81 <spawn+0x5d5>
  802911:	bb 00 00 00 00       	mov    $0x0,%ebx
  802916:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  80291c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80291f:	eb 2e                	jmp    80294f <spawn+0x1a3>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  802921:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  802927:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  80292d:	89 04 9a             	mov    %eax,(%edx,%ebx,4)
		strcpy(string_store, argv[i]);
  802930:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  802933:	89 44 24 04          	mov    %eax,0x4(%esp)
  802937:	89 3c 24             	mov    %edi,(%esp)
  80293a:	e8 70 e8 ff ff       	call   8011af <strcpy>
		string_store += strlen(argv[i]) + 1;
  80293f:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  802942:	89 04 24             	mov    %eax,(%esp)
  802945:	e8 32 e8 ff ff       	call   80117c <strlen>
  80294a:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  80294e:	43                   	inc    %ebx
  80294f:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  802955:	7c ca                	jl     802921 <spawn+0x175>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  802957:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  80295d:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  802963:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  80296a:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  802970:	74 24                	je     802996 <spawn+0x1ea>
  802972:	c7 44 24 0c ec 42 80 	movl   $0x8042ec,0xc(%esp)
  802979:	00 
  80297a:	c7 44 24 08 92 3c 80 	movl   $0x803c92,0x8(%esp)
  802981:	00 
  802982:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
  802989:	00 
  80298a:	c7 04 24 7c 42 80 00 	movl   $0x80427c,(%esp)
  802991:	e8 96 e0 ff ff       	call   800a2c <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  802996:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  80299c:	2d 00 30 80 11       	sub    $0x11803000,%eax
  8029a1:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  8029a7:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  8029aa:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8029b0:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  8029b3:	89 d0                	mov    %edx,%eax
  8029b5:	2d 08 30 80 11       	sub    $0x11803008,%eax
  8029ba:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8029c0:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8029c7:	00 
  8029c8:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  8029cf:	ee 
  8029d0:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8029d6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8029da:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8029e1:	00 
  8029e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8029e9:	e8 07 ec ff ff       	call   8015f5 <sys_page_map>
  8029ee:	89 c3                	mov    %eax,%ebx
  8029f0:	85 c0                	test   %eax,%eax
  8029f2:	78 1a                	js     802a0e <spawn+0x262>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8029f4:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8029fb:	00 
  8029fc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802a03:	e8 40 ec ff ff       	call   801648 <sys_page_unmap>
  802a08:	89 c3                	mov    %eax,%ebx
  802a0a:	85 c0                	test   %eax,%eax
  802a0c:	79 1f                	jns    802a2d <spawn+0x281>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802a0e:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802a15:	00 
  802a16:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802a1d:	e8 26 ec ff ff       	call   801648 <sys_page_unmap>
	return r;
  802a22:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  802a28:	e9 3e 03 00 00       	jmp    802d6b <spawn+0x5bf>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  802a2d:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  802a33:	03 95 04 fe ff ff    	add    -0x1fc(%ebp),%edx
  802a39:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802a3f:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  802a46:	00 00 00 
  802a49:	e9 bb 01 00 00       	jmp    802c09 <spawn+0x45d>
		if (ph->p_type != ELF_PROG_LOAD)
  802a4e:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802a54:	83 38 01             	cmpl   $0x1,(%eax)
  802a57:	0f 85 9f 01 00 00    	jne    802bfc <spawn+0x450>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  802a5d:	89 c2                	mov    %eax,%edx
  802a5f:	8b 40 18             	mov    0x18(%eax),%eax
  802a62:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  802a65:	83 f8 01             	cmp    $0x1,%eax
  802a68:	19 c0                	sbb    %eax,%eax
  802a6a:	83 e0 fe             	and    $0xfffffffe,%eax
  802a6d:	83 c0 07             	add    $0x7,%eax
  802a70:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  802a76:	8b 52 04             	mov    0x4(%edx),%edx
  802a79:	89 95 78 fd ff ff    	mov    %edx,-0x288(%ebp)
  802a7f:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802a85:	8b 40 10             	mov    0x10(%eax),%eax
  802a88:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  802a8e:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  802a94:	8b 52 14             	mov    0x14(%edx),%edx
  802a97:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  802a9d:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802aa3:	8b 78 08             	mov    0x8(%eax),%edi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  802aa6:	89 f8                	mov    %edi,%eax
  802aa8:	25 ff 0f 00 00       	and    $0xfff,%eax
  802aad:	74 16                	je     802ac5 <spawn+0x319>
		va -= i;
  802aaf:	29 c7                	sub    %eax,%edi
		memsz += i;
  802ab1:	01 c2                	add    %eax,%edx
  802ab3:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
		filesz += i;
  802ab9:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  802abf:	29 85 78 fd ff ff    	sub    %eax,-0x288(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  802ac5:	bb 00 00 00 00       	mov    $0x0,%ebx
  802aca:	e9 1f 01 00 00       	jmp    802bee <spawn+0x442>
		if (i >= filesz) {
  802acf:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  802ad5:	77 2b                	ja     802b02 <spawn+0x356>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  802ad7:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  802add:	89 54 24 08          	mov    %edx,0x8(%esp)
  802ae1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802ae5:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802aeb:	89 04 24             	mov    %eax,(%esp)
  802aee:	e8 ae ea ff ff       	call   8015a1 <sys_page_alloc>
  802af3:	85 c0                	test   %eax,%eax
  802af5:	0f 89 e7 00 00 00    	jns    802be2 <spawn+0x436>
  802afb:	89 c6                	mov    %eax,%esi
  802afd:	e9 39 02 00 00       	jmp    802d3b <spawn+0x58f>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802b02:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802b09:	00 
  802b0a:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802b11:	00 
  802b12:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802b19:	e8 83 ea ff ff       	call   8015a1 <sys_page_alloc>
  802b1e:	85 c0                	test   %eax,%eax
  802b20:	0f 88 0b 02 00 00    	js     802d31 <spawn+0x585>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  802b26:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  802b2c:	01 f0                	add    %esi,%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802b2e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802b32:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  802b38:	89 04 24             	mov    %eax,(%esp)
  802b3b:	e8 24 f7 ff ff       	call   802264 <seek>
  802b40:	85 c0                	test   %eax,%eax
  802b42:	0f 88 ed 01 00 00    	js     802d35 <spawn+0x589>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  802b48:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802b4e:	29 f0                	sub    %esi,%eax
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802b50:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802b55:	76 05                	jbe    802b5c <spawn+0x3b0>
  802b57:	b8 00 10 00 00       	mov    $0x1000,%eax
  802b5c:	89 44 24 08          	mov    %eax,0x8(%esp)
  802b60:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802b67:	00 
  802b68:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  802b6e:	89 04 24             	mov    %eax,(%esp)
  802b71:	e8 18 f6 ff ff       	call   80218e <readn>
  802b76:	85 c0                	test   %eax,%eax
  802b78:	0f 88 bb 01 00 00    	js     802d39 <spawn+0x58d>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  802b7e:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  802b84:	89 54 24 10          	mov    %edx,0x10(%esp)
  802b88:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802b8c:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802b92:	89 44 24 08          	mov    %eax,0x8(%esp)
  802b96:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802b9d:	00 
  802b9e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802ba5:	e8 4b ea ff ff       	call   8015f5 <sys_page_map>
  802baa:	85 c0                	test   %eax,%eax
  802bac:	79 20                	jns    802bce <spawn+0x422>
				panic("spawn: sys_page_map data: %e", r);
  802bae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802bb2:	c7 44 24 08 88 42 80 	movl   $0x804288,0x8(%esp)
  802bb9:	00 
  802bba:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
  802bc1:	00 
  802bc2:	c7 04 24 7c 42 80 00 	movl   $0x80427c,(%esp)
  802bc9:	e8 5e de ff ff       	call   800a2c <_panic>
			sys_page_unmap(0, UTEMP);
  802bce:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802bd5:	00 
  802bd6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802bdd:	e8 66 ea ff ff       	call   801648 <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  802be2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802be8:	81 c7 00 10 00 00    	add    $0x1000,%edi
  802bee:	89 de                	mov    %ebx,%esi
  802bf0:	3b 9d 8c fd ff ff    	cmp    -0x274(%ebp),%ebx
  802bf6:	0f 82 d3 fe ff ff    	jb     802acf <spawn+0x323>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802bfc:	ff 85 7c fd ff ff    	incl   -0x284(%ebp)
  802c02:	83 85 80 fd ff ff 20 	addl   $0x20,-0x280(%ebp)
  802c09:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  802c10:	39 85 7c fd ff ff    	cmp    %eax,-0x284(%ebp)
  802c16:	0f 8c 32 fe ff ff    	jl     802a4e <spawn+0x2a2>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  802c1c:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  802c22:	89 04 24             	mov    %eax,(%esp)
  802c25:	e8 70 f3 ff ff       	call   801f9a <close>
{
	// LAB 5: Your code here.
	int r;
	uint32_t page_num;
	
	for (page_num = 0; page_num < PGNUM(UTOP); page_num++) {
  802c2a:	be 00 00 00 00       	mov    $0x0,%esi
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES)/NPDENTRIES;
  802c2f:	89 f0                	mov    %esi,%eax
  802c31:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx]&PTE_P) && (uvpt[page_num]&PTE_P) && (uvpt[page_num]&PTE_SHARE)){
  802c34:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802c3b:	a8 01                	test   $0x1,%al
  802c3d:	0f 84 82 00 00 00    	je     802cc5 <spawn+0x519>
  802c43:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  802c4a:	a8 01                	test   $0x1,%al
  802c4c:	74 77                	je     802cc5 <spawn+0x519>
  802c4e:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  802c55:	f6 c4 04             	test   $0x4,%ah
  802c58:	74 6b                	je     802cc5 <spawn+0x519>
			if ((r = sys_page_map(sys_getenvid(), (void*)(page_num*PGSIZE), child, (void*)(page_num*PGSIZE), uvpt[page_num]&PTE_SYSCALL)) < 0){
  802c5a:	8b 3c b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edi
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  802c61:	89 f3                	mov    %esi,%ebx
  802c63:	c1 e3 0c             	shl    $0xc,%ebx
	uint32_t page_num;
	
	for (page_num = 0; page_num < PGNUM(UTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES)/NPDENTRIES;
		if ((uvpd[pdx]&PTE_P) && (uvpt[page_num]&PTE_P) && (uvpt[page_num]&PTE_SHARE)){
			if ((r = sys_page_map(sys_getenvid(), (void*)(page_num*PGSIZE), child, (void*)(page_num*PGSIZE), uvpt[page_num]&PTE_SYSCALL)) < 0){
  802c66:	e8 f8 e8 ff ff       	call   801563 <sys_getenvid>
  802c6b:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  802c71:	89 7c 24 10          	mov    %edi,0x10(%esp)
  802c75:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  802c79:	8b 95 88 fd ff ff    	mov    -0x278(%ebp),%edx
  802c7f:	89 54 24 08          	mov    %edx,0x8(%esp)
  802c83:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802c87:	89 04 24             	mov    %eax,(%esp)
  802c8a:	e8 66 e9 ff ff       	call   8015f5 <sys_page_map>
  802c8f:	85 c0                	test   %eax,%eax
  802c91:	79 32                	jns    802cc5 <spawn+0x519>
  802c93:	89 c3                	mov    %eax,%ebx
				cprintf("copy_shared_pages: sys_page_map failed, %e", r);
  802c95:	89 44 24 04          	mov    %eax,0x4(%esp)
  802c99:	c7 04 24 14 43 80 00 	movl   $0x804314,(%esp)
  802ca0:	e8 7f de ff ff       	call   800b24 <cprintf>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  802ca5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  802ca9:	c7 44 24 08 a5 42 80 	movl   $0x8042a5,0x8(%esp)
  802cb0:	00 
  802cb1:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  802cb8:	00 
  802cb9:	c7 04 24 7c 42 80 00 	movl   $0x80427c,(%esp)
  802cc0:	e8 67 dd ff ff       	call   800a2c <_panic>
{
	// LAB 5: Your code here.
	int r;
	uint32_t page_num;
	
	for (page_num = 0; page_num < PGNUM(UTOP); page_num++) {
  802cc5:	46                   	inc    %esi
  802cc6:	81 fe 00 ec 0e 00    	cmp    $0xeec00,%esi
  802ccc:	0f 85 5d ff ff ff    	jne    802c2f <spawn+0x483>
  802cd2:	e9 b2 00 00 00       	jmp    802d89 <spawn+0x5dd>
	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  802cd7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802cdb:	c7 44 24 08 bb 42 80 	movl   $0x8042bb,0x8(%esp)
  802ce2:	00 
  802ce3:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  802cea:	00 
  802ceb:	c7 04 24 7c 42 80 00 	movl   $0x80427c,(%esp)
  802cf2:	e8 35 dd ff ff       	call   800a2c <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802cf7:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  802cfe:	00 
  802cff:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802d05:	89 04 24             	mov    %eax,(%esp)
  802d08:	e8 8e e9 ff ff       	call   80169b <sys_env_set_status>
  802d0d:	85 c0                	test   %eax,%eax
  802d0f:	79 5a                	jns    802d6b <spawn+0x5bf>
		panic("sys_env_set_status: %e", r);
  802d11:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802d15:	c7 44 24 08 d5 42 80 	movl   $0x8042d5,0x8(%esp)
  802d1c:	00 
  802d1d:	c7 44 24 04 88 00 00 	movl   $0x88,0x4(%esp)
  802d24:	00 
  802d25:	c7 04 24 7c 42 80 00 	movl   $0x80427c,(%esp)
  802d2c:	e8 fb dc ff ff       	call   800a2c <_panic>
  802d31:	89 c6                	mov    %eax,%esi
  802d33:	eb 06                	jmp    802d3b <spawn+0x58f>
  802d35:	89 c6                	mov    %eax,%esi
  802d37:	eb 02                	jmp    802d3b <spawn+0x58f>
  802d39:	89 c6                	mov    %eax,%esi

	return child;

error:
	sys_env_destroy(child);
  802d3b:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802d41:	89 04 24             	mov    %eax,(%esp)
  802d44:	e8 c8 e7 ff ff       	call   801511 <sys_env_destroy>
	close(fd);
  802d49:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  802d4f:	89 04 24             	mov    %eax,(%esp)
  802d52:	e8 43 f2 ff ff       	call   801f9a <close>
	return r;
  802d57:	89 b5 88 fd ff ff    	mov    %esi,-0x278(%ebp)
  802d5d:	eb 0c                	jmp    802d6b <spawn+0x5bf>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  802d5f:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  802d65:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  802d6b:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802d71:	81 c4 ac 02 00 00    	add    $0x2ac,%esp
  802d77:	5b                   	pop    %ebx
  802d78:	5e                   	pop    %esi
  802d79:	5f                   	pop    %edi
  802d7a:	5d                   	pop    %ebp
  802d7b:	c3                   	ret    
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  802d7c:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  802d81:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  802d87:	eb e2                	jmp    802d6b <spawn+0x5bf>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802d89:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802d8f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802d93:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802d99:	89 04 24             	mov    %eax,(%esp)
  802d9c:	e8 4d e9 ff ff       	call   8016ee <sys_env_set_trapframe>
  802da1:	85 c0                	test   %eax,%eax
  802da3:	0f 89 4e ff ff ff    	jns    802cf7 <spawn+0x54b>
  802da9:	e9 29 ff ff ff       	jmp    802cd7 <spawn+0x52b>

00802dae <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802dae:	55                   	push   %ebp
  802daf:	89 e5                	mov    %esp,%ebp
  802db1:	57                   	push   %edi
  802db2:	56                   	push   %esi
  802db3:	53                   	push   %ebx
  802db4:	83 ec 1c             	sub    $0x1c,%esp
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
  802db7:	8d 45 10             	lea    0x10(%ebp),%eax
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802dba:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802dbf:	eb 03                	jmp    802dc4 <spawnl+0x16>
		argc++;
  802dc1:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802dc2:	89 d0                	mov    %edx,%eax
  802dc4:	8d 50 04             	lea    0x4(%eax),%edx
  802dc7:	83 38 00             	cmpl   $0x0,(%eax)
  802dca:	75 f5                	jne    802dc1 <spawnl+0x13>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802dcc:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  802dd3:	83 e0 f0             	and    $0xfffffff0,%eax
  802dd6:	29 c4                	sub    %eax,%esp
  802dd8:	8d 7c 24 17          	lea    0x17(%esp),%edi
  802ddc:	83 e7 f0             	and    $0xfffffff0,%edi
  802ddf:	89 fe                	mov    %edi,%esi
	argv[0] = arg0;
  802de1:	8b 45 0c             	mov    0xc(%ebp),%eax
  802de4:	89 07                	mov    %eax,(%edi)
	argv[argc+1] = NULL;
  802de6:	c7 44 8f 04 00 00 00 	movl   $0x0,0x4(%edi,%ecx,4)
  802ded:	00 

	va_start(vl, arg0);
  802dee:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  802df1:	b8 00 00 00 00       	mov    $0x0,%eax
  802df6:	eb 09                	jmp    802e01 <spawnl+0x53>
		argv[i+1] = va_arg(vl, const char *);
  802df8:	40                   	inc    %eax
  802df9:	8b 1a                	mov    (%edx),%ebx
  802dfb:	89 1c 86             	mov    %ebx,(%esi,%eax,4)
  802dfe:	8d 52 04             	lea    0x4(%edx),%edx
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802e01:	39 c8                	cmp    %ecx,%eax
  802e03:	75 f3                	jne    802df8 <spawnl+0x4a>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802e05:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802e09:	8b 45 08             	mov    0x8(%ebp),%eax
  802e0c:	89 04 24             	mov    %eax,(%esp)
  802e0f:	e8 98 f9 ff ff       	call   8027ac <spawn>
}
  802e14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802e17:	5b                   	pop    %ebx
  802e18:	5e                   	pop    %esi
  802e19:	5f                   	pop    %edi
  802e1a:	5d                   	pop    %ebp
  802e1b:	c3                   	ret    

00802e1c <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802e1c:	55                   	push   %ebp
  802e1d:	89 e5                	mov    %esp,%ebp
  802e1f:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  802e22:	c7 44 24 04 3f 43 80 	movl   $0x80433f,0x4(%esp)
  802e29:	00 
  802e2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  802e2d:	89 04 24             	mov    %eax,(%esp)
  802e30:	e8 7a e3 ff ff       	call   8011af <strcpy>
	return 0;
}
  802e35:	b8 00 00 00 00       	mov    $0x0,%eax
  802e3a:	c9                   	leave  
  802e3b:	c3                   	ret    

00802e3c <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  802e3c:	55                   	push   %ebp
  802e3d:	89 e5                	mov    %esp,%ebp
  802e3f:	53                   	push   %ebx
  802e40:	83 ec 14             	sub    $0x14,%esp
  802e43:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  802e46:	89 1c 24             	mov    %ebx,(%esp)
  802e49:	e8 4a 0a 00 00       	call   803898 <pageref>
  802e4e:	83 f8 01             	cmp    $0x1,%eax
  802e51:	75 0d                	jne    802e60 <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  802e53:	8b 43 0c             	mov    0xc(%ebx),%eax
  802e56:	89 04 24             	mov    %eax,(%esp)
  802e59:	e8 1f 03 00 00       	call   80317d <nsipc_close>
  802e5e:	eb 05                	jmp    802e65 <devsock_close+0x29>
	else
		return 0;
  802e60:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802e65:	83 c4 14             	add    $0x14,%esp
  802e68:	5b                   	pop    %ebx
  802e69:	5d                   	pop    %ebp
  802e6a:	c3                   	ret    

00802e6b <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  802e6b:	55                   	push   %ebp
  802e6c:	89 e5                	mov    %esp,%ebp
  802e6e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  802e71:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802e78:	00 
  802e79:	8b 45 10             	mov    0x10(%ebp),%eax
  802e7c:	89 44 24 08          	mov    %eax,0x8(%esp)
  802e80:	8b 45 0c             	mov    0xc(%ebp),%eax
  802e83:	89 44 24 04          	mov    %eax,0x4(%esp)
  802e87:	8b 45 08             	mov    0x8(%ebp),%eax
  802e8a:	8b 40 0c             	mov    0xc(%eax),%eax
  802e8d:	89 04 24             	mov    %eax,(%esp)
  802e90:	e8 e3 03 00 00       	call   803278 <nsipc_send>
}
  802e95:	c9                   	leave  
  802e96:	c3                   	ret    

00802e97 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  802e97:	55                   	push   %ebp
  802e98:	89 e5                	mov    %esp,%ebp
  802e9a:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802e9d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802ea4:	00 
  802ea5:	8b 45 10             	mov    0x10(%ebp),%eax
  802ea8:	89 44 24 08          	mov    %eax,0x8(%esp)
  802eac:	8b 45 0c             	mov    0xc(%ebp),%eax
  802eaf:	89 44 24 04          	mov    %eax,0x4(%esp)
  802eb3:	8b 45 08             	mov    0x8(%ebp),%eax
  802eb6:	8b 40 0c             	mov    0xc(%eax),%eax
  802eb9:	89 04 24             	mov    %eax,(%esp)
  802ebc:	e8 37 03 00 00       	call   8031f8 <nsipc_recv>
}
  802ec1:	c9                   	leave  
  802ec2:	c3                   	ret    

00802ec3 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  802ec3:	55                   	push   %ebp
  802ec4:	89 e5                	mov    %esp,%ebp
  802ec6:	56                   	push   %esi
  802ec7:	53                   	push   %ebx
  802ec8:	83 ec 20             	sub    $0x20,%esp
  802ecb:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  802ecd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802ed0:	89 04 24             	mov    %eax,(%esp)
  802ed3:	e8 37 ef ff ff       	call   801e0f <fd_alloc>
  802ed8:	89 c3                	mov    %eax,%ebx
  802eda:	85 c0                	test   %eax,%eax
  802edc:	78 21                	js     802eff <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  802ede:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802ee5:	00 
  802ee6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802ee9:	89 44 24 04          	mov    %eax,0x4(%esp)
  802eed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802ef4:	e8 a8 e6 ff ff       	call   8015a1 <sys_page_alloc>
  802ef9:	89 c3                	mov    %eax,%ebx
  802efb:	85 c0                	test   %eax,%eax
  802efd:	79 0a                	jns    802f09 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  802eff:	89 34 24             	mov    %esi,(%esp)
  802f02:	e8 76 02 00 00       	call   80317d <nsipc_close>
		return r;
  802f07:	eb 22                	jmp    802f2b <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  802f09:	8b 15 40 50 80 00    	mov    0x805040,%edx
  802f0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802f12:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  802f14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802f17:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  802f1e:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  802f21:	89 04 24             	mov    %eax,(%esp)
  802f24:	e8 bb ee ff ff       	call   801de4 <fd2num>
  802f29:	89 c3                	mov    %eax,%ebx
}
  802f2b:	89 d8                	mov    %ebx,%eax
  802f2d:	83 c4 20             	add    $0x20,%esp
  802f30:	5b                   	pop    %ebx
  802f31:	5e                   	pop    %esi
  802f32:	5d                   	pop    %ebp
  802f33:	c3                   	ret    

00802f34 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  802f34:	55                   	push   %ebp
  802f35:	89 e5                	mov    %esp,%ebp
  802f37:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  802f3a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802f3d:	89 54 24 04          	mov    %edx,0x4(%esp)
  802f41:	89 04 24             	mov    %eax,(%esp)
  802f44:	e8 19 ef ff ff       	call   801e62 <fd_lookup>
  802f49:	85 c0                	test   %eax,%eax
  802f4b:	78 17                	js     802f64 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  802f4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802f50:	8b 15 40 50 80 00    	mov    0x805040,%edx
  802f56:	39 10                	cmp    %edx,(%eax)
  802f58:	75 05                	jne    802f5f <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  802f5a:	8b 40 0c             	mov    0xc(%eax),%eax
  802f5d:	eb 05                	jmp    802f64 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  802f5f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  802f64:	c9                   	leave  
  802f65:	c3                   	ret    

00802f66 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802f66:	55                   	push   %ebp
  802f67:	89 e5                	mov    %esp,%ebp
  802f69:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802f6c:	8b 45 08             	mov    0x8(%ebp),%eax
  802f6f:	e8 c0 ff ff ff       	call   802f34 <fd2sockid>
  802f74:	85 c0                	test   %eax,%eax
  802f76:	78 1f                	js     802f97 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802f78:	8b 55 10             	mov    0x10(%ebp),%edx
  802f7b:	89 54 24 08          	mov    %edx,0x8(%esp)
  802f7f:	8b 55 0c             	mov    0xc(%ebp),%edx
  802f82:	89 54 24 04          	mov    %edx,0x4(%esp)
  802f86:	89 04 24             	mov    %eax,(%esp)
  802f89:	e8 38 01 00 00       	call   8030c6 <nsipc_accept>
  802f8e:	85 c0                	test   %eax,%eax
  802f90:	78 05                	js     802f97 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  802f92:	e8 2c ff ff ff       	call   802ec3 <alloc_sockfd>
}
  802f97:	c9                   	leave  
  802f98:	c3                   	ret    

00802f99 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802f99:	55                   	push   %ebp
  802f9a:	89 e5                	mov    %esp,%ebp
  802f9c:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802f9f:	8b 45 08             	mov    0x8(%ebp),%eax
  802fa2:	e8 8d ff ff ff       	call   802f34 <fd2sockid>
  802fa7:	85 c0                	test   %eax,%eax
  802fa9:	78 16                	js     802fc1 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  802fab:	8b 55 10             	mov    0x10(%ebp),%edx
  802fae:	89 54 24 08          	mov    %edx,0x8(%esp)
  802fb2:	8b 55 0c             	mov    0xc(%ebp),%edx
  802fb5:	89 54 24 04          	mov    %edx,0x4(%esp)
  802fb9:	89 04 24             	mov    %eax,(%esp)
  802fbc:	e8 5b 01 00 00       	call   80311c <nsipc_bind>
}
  802fc1:	c9                   	leave  
  802fc2:	c3                   	ret    

00802fc3 <shutdown>:

int
shutdown(int s, int how)
{
  802fc3:	55                   	push   %ebp
  802fc4:	89 e5                	mov    %esp,%ebp
  802fc6:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802fc9:	8b 45 08             	mov    0x8(%ebp),%eax
  802fcc:	e8 63 ff ff ff       	call   802f34 <fd2sockid>
  802fd1:	85 c0                	test   %eax,%eax
  802fd3:	78 0f                	js     802fe4 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  802fd5:	8b 55 0c             	mov    0xc(%ebp),%edx
  802fd8:	89 54 24 04          	mov    %edx,0x4(%esp)
  802fdc:	89 04 24             	mov    %eax,(%esp)
  802fdf:	e8 77 01 00 00       	call   80315b <nsipc_shutdown>
}
  802fe4:	c9                   	leave  
  802fe5:	c3                   	ret    

00802fe6 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802fe6:	55                   	push   %ebp
  802fe7:	89 e5                	mov    %esp,%ebp
  802fe9:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802fec:	8b 45 08             	mov    0x8(%ebp),%eax
  802fef:	e8 40 ff ff ff       	call   802f34 <fd2sockid>
  802ff4:	85 c0                	test   %eax,%eax
  802ff6:	78 16                	js     80300e <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  802ff8:	8b 55 10             	mov    0x10(%ebp),%edx
  802ffb:	89 54 24 08          	mov    %edx,0x8(%esp)
  802fff:	8b 55 0c             	mov    0xc(%ebp),%edx
  803002:	89 54 24 04          	mov    %edx,0x4(%esp)
  803006:	89 04 24             	mov    %eax,(%esp)
  803009:	e8 89 01 00 00       	call   803197 <nsipc_connect>
}
  80300e:	c9                   	leave  
  80300f:	c3                   	ret    

00803010 <listen>:

int
listen(int s, int backlog)
{
  803010:	55                   	push   %ebp
  803011:	89 e5                	mov    %esp,%ebp
  803013:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  803016:	8b 45 08             	mov    0x8(%ebp),%eax
  803019:	e8 16 ff ff ff       	call   802f34 <fd2sockid>
  80301e:	85 c0                	test   %eax,%eax
  803020:	78 0f                	js     803031 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  803022:	8b 55 0c             	mov    0xc(%ebp),%edx
  803025:	89 54 24 04          	mov    %edx,0x4(%esp)
  803029:	89 04 24             	mov    %eax,(%esp)
  80302c:	e8 a5 01 00 00       	call   8031d6 <nsipc_listen>
}
  803031:	c9                   	leave  
  803032:	c3                   	ret    

00803033 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  803033:	55                   	push   %ebp
  803034:	89 e5                	mov    %esp,%ebp
  803036:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  803039:	8b 45 10             	mov    0x10(%ebp),%eax
  80303c:	89 44 24 08          	mov    %eax,0x8(%esp)
  803040:	8b 45 0c             	mov    0xc(%ebp),%eax
  803043:	89 44 24 04          	mov    %eax,0x4(%esp)
  803047:	8b 45 08             	mov    0x8(%ebp),%eax
  80304a:	89 04 24             	mov    %eax,(%esp)
  80304d:	e8 99 02 00 00       	call   8032eb <nsipc_socket>
  803052:	85 c0                	test   %eax,%eax
  803054:	78 05                	js     80305b <socket+0x28>
		return r;
	return alloc_sockfd(r);
  803056:	e8 68 fe ff ff       	call   802ec3 <alloc_sockfd>
}
  80305b:	c9                   	leave  
  80305c:	c3                   	ret    
  80305d:	00 00                	add    %al,(%eax)
	...

00803060 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  803060:	55                   	push   %ebp
  803061:	89 e5                	mov    %esp,%ebp
  803063:	53                   	push   %ebx
  803064:	83 ec 14             	sub    $0x14,%esp
  803067:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  803069:	83 3d 24 64 80 00 00 	cmpl   $0x0,0x806424
  803070:	75 11                	jne    803083 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  803072:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  803079:	e8 e1 07 00 00       	call   80385f <ipc_find_env>
  80307e:	a3 24 64 80 00       	mov    %eax,0x806424
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  803083:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80308a:	00 
  80308b:	c7 44 24 08 00 80 80 	movl   $0x808000,0x8(%esp)
  803092:	00 
  803093:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  803097:	a1 24 64 80 00       	mov    0x806424,%eax
  80309c:	89 04 24             	mov    %eax,(%esp)
  80309f:	e8 4d 07 00 00       	call   8037f1 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8030a4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8030ab:	00 
  8030ac:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8030b3:	00 
  8030b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8030bb:	e8 c8 06 00 00       	call   803788 <ipc_recv>
}
  8030c0:	83 c4 14             	add    $0x14,%esp
  8030c3:	5b                   	pop    %ebx
  8030c4:	5d                   	pop    %ebp
  8030c5:	c3                   	ret    

008030c6 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8030c6:	55                   	push   %ebp
  8030c7:	89 e5                	mov    %esp,%ebp
  8030c9:	56                   	push   %esi
  8030ca:	53                   	push   %ebx
  8030cb:	83 ec 10             	sub    $0x10,%esp
  8030ce:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8030d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8030d4:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8030d9:	8b 06                	mov    (%esi),%eax
  8030db:	a3 04 80 80 00       	mov    %eax,0x808004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8030e0:	b8 01 00 00 00       	mov    $0x1,%eax
  8030e5:	e8 76 ff ff ff       	call   803060 <nsipc>
  8030ea:	89 c3                	mov    %eax,%ebx
  8030ec:	85 c0                	test   %eax,%eax
  8030ee:	78 23                	js     803113 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8030f0:	a1 10 80 80 00       	mov    0x808010,%eax
  8030f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8030f9:	c7 44 24 04 00 80 80 	movl   $0x808000,0x4(%esp)
  803100:	00 
  803101:	8b 45 0c             	mov    0xc(%ebp),%eax
  803104:	89 04 24             	mov    %eax,(%esp)
  803107:	e8 1c e2 ff ff       	call   801328 <memmove>
		*addrlen = ret->ret_addrlen;
  80310c:	a1 10 80 80 00       	mov    0x808010,%eax
  803111:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  803113:	89 d8                	mov    %ebx,%eax
  803115:	83 c4 10             	add    $0x10,%esp
  803118:	5b                   	pop    %ebx
  803119:	5e                   	pop    %esi
  80311a:	5d                   	pop    %ebp
  80311b:	c3                   	ret    

0080311c <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80311c:	55                   	push   %ebp
  80311d:	89 e5                	mov    %esp,%ebp
  80311f:	53                   	push   %ebx
  803120:	83 ec 14             	sub    $0x14,%esp
  803123:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  803126:	8b 45 08             	mov    0x8(%ebp),%eax
  803129:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  80312e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803132:	8b 45 0c             	mov    0xc(%ebp),%eax
  803135:	89 44 24 04          	mov    %eax,0x4(%esp)
  803139:	c7 04 24 04 80 80 00 	movl   $0x808004,(%esp)
  803140:	e8 e3 e1 ff ff       	call   801328 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  803145:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_BIND);
  80314b:	b8 02 00 00 00       	mov    $0x2,%eax
  803150:	e8 0b ff ff ff       	call   803060 <nsipc>
}
  803155:	83 c4 14             	add    $0x14,%esp
  803158:	5b                   	pop    %ebx
  803159:	5d                   	pop    %ebp
  80315a:	c3                   	ret    

0080315b <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80315b:	55                   	push   %ebp
  80315c:	89 e5                	mov    %esp,%ebp
  80315e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  803161:	8b 45 08             	mov    0x8(%ebp),%eax
  803164:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.shutdown.req_how = how;
  803169:	8b 45 0c             	mov    0xc(%ebp),%eax
  80316c:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_SHUTDOWN);
  803171:	b8 03 00 00 00       	mov    $0x3,%eax
  803176:	e8 e5 fe ff ff       	call   803060 <nsipc>
}
  80317b:	c9                   	leave  
  80317c:	c3                   	ret    

0080317d <nsipc_close>:

int
nsipc_close(int s)
{
  80317d:	55                   	push   %ebp
  80317e:	89 e5                	mov    %esp,%ebp
  803180:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  803183:	8b 45 08             	mov    0x8(%ebp),%eax
  803186:	a3 00 80 80 00       	mov    %eax,0x808000
	return nsipc(NSREQ_CLOSE);
  80318b:	b8 04 00 00 00       	mov    $0x4,%eax
  803190:	e8 cb fe ff ff       	call   803060 <nsipc>
}
  803195:	c9                   	leave  
  803196:	c3                   	ret    

00803197 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  803197:	55                   	push   %ebp
  803198:	89 e5                	mov    %esp,%ebp
  80319a:	53                   	push   %ebx
  80319b:	83 ec 14             	sub    $0x14,%esp
  80319e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8031a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8031a4:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8031a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8031ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8031b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8031b4:	c7 04 24 04 80 80 00 	movl   $0x808004,(%esp)
  8031bb:	e8 68 e1 ff ff       	call   801328 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8031c0:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_CONNECT);
  8031c6:	b8 05 00 00 00       	mov    $0x5,%eax
  8031cb:	e8 90 fe ff ff       	call   803060 <nsipc>
}
  8031d0:	83 c4 14             	add    $0x14,%esp
  8031d3:	5b                   	pop    %ebx
  8031d4:	5d                   	pop    %ebp
  8031d5:	c3                   	ret    

008031d6 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8031d6:	55                   	push   %ebp
  8031d7:	89 e5                	mov    %esp,%ebp
  8031d9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8031dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8031df:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.listen.req_backlog = backlog;
  8031e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8031e7:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_LISTEN);
  8031ec:	b8 06 00 00 00       	mov    $0x6,%eax
  8031f1:	e8 6a fe ff ff       	call   803060 <nsipc>
}
  8031f6:	c9                   	leave  
  8031f7:	c3                   	ret    

008031f8 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8031f8:	55                   	push   %ebp
  8031f9:	89 e5                	mov    %esp,%ebp
  8031fb:	56                   	push   %esi
  8031fc:	53                   	push   %ebx
  8031fd:	83 ec 10             	sub    $0x10,%esp
  803200:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  803203:	8b 45 08             	mov    0x8(%ebp),%eax
  803206:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.recv.req_len = len;
  80320b:	89 35 04 80 80 00    	mov    %esi,0x808004
	nsipcbuf.recv.req_flags = flags;
  803211:	8b 45 14             	mov    0x14(%ebp),%eax
  803214:	a3 08 80 80 00       	mov    %eax,0x808008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  803219:	b8 07 00 00 00       	mov    $0x7,%eax
  80321e:	e8 3d fe ff ff       	call   803060 <nsipc>
  803223:	89 c3                	mov    %eax,%ebx
  803225:	85 c0                	test   %eax,%eax
  803227:	78 46                	js     80326f <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  803229:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80322e:	7f 04                	jg     803234 <nsipc_recv+0x3c>
  803230:	39 c6                	cmp    %eax,%esi
  803232:	7d 24                	jge    803258 <nsipc_recv+0x60>
  803234:	c7 44 24 0c 4b 43 80 	movl   $0x80434b,0xc(%esp)
  80323b:	00 
  80323c:	c7 44 24 08 92 3c 80 	movl   $0x803c92,0x8(%esp)
  803243:	00 
  803244:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  80324b:	00 
  80324c:	c7 04 24 60 43 80 00 	movl   $0x804360,(%esp)
  803253:	e8 d4 d7 ff ff       	call   800a2c <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  803258:	89 44 24 08          	mov    %eax,0x8(%esp)
  80325c:	c7 44 24 04 00 80 80 	movl   $0x808000,0x4(%esp)
  803263:	00 
  803264:	8b 45 0c             	mov    0xc(%ebp),%eax
  803267:	89 04 24             	mov    %eax,(%esp)
  80326a:	e8 b9 e0 ff ff       	call   801328 <memmove>
	}

	return r;
}
  80326f:	89 d8                	mov    %ebx,%eax
  803271:	83 c4 10             	add    $0x10,%esp
  803274:	5b                   	pop    %ebx
  803275:	5e                   	pop    %esi
  803276:	5d                   	pop    %ebp
  803277:	c3                   	ret    

00803278 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  803278:	55                   	push   %ebp
  803279:	89 e5                	mov    %esp,%ebp
  80327b:	53                   	push   %ebx
  80327c:	83 ec 14             	sub    $0x14,%esp
  80327f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  803282:	8b 45 08             	mov    0x8(%ebp),%eax
  803285:	a3 00 80 80 00       	mov    %eax,0x808000
	assert(size < 1600);
  80328a:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  803290:	7e 24                	jle    8032b6 <nsipc_send+0x3e>
  803292:	c7 44 24 0c 6c 43 80 	movl   $0x80436c,0xc(%esp)
  803299:	00 
  80329a:	c7 44 24 08 92 3c 80 	movl   $0x803c92,0x8(%esp)
  8032a1:	00 
  8032a2:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  8032a9:	00 
  8032aa:	c7 04 24 60 43 80 00 	movl   $0x804360,(%esp)
  8032b1:	e8 76 d7 ff ff       	call   800a2c <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8032b6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8032ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8032bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8032c1:	c7 04 24 0c 80 80 00 	movl   $0x80800c,(%esp)
  8032c8:	e8 5b e0 ff ff       	call   801328 <memmove>
	nsipcbuf.send.req_size = size;
  8032cd:	89 1d 04 80 80 00    	mov    %ebx,0x808004
	nsipcbuf.send.req_flags = flags;
  8032d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8032d6:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SEND);
  8032db:	b8 08 00 00 00       	mov    $0x8,%eax
  8032e0:	e8 7b fd ff ff       	call   803060 <nsipc>
}
  8032e5:	83 c4 14             	add    $0x14,%esp
  8032e8:	5b                   	pop    %ebx
  8032e9:	5d                   	pop    %ebp
  8032ea:	c3                   	ret    

008032eb <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8032eb:	55                   	push   %ebp
  8032ec:	89 e5                	mov    %esp,%ebp
  8032ee:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8032f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8032f4:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.socket.req_type = type;
  8032f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8032fc:	a3 04 80 80 00       	mov    %eax,0x808004
	nsipcbuf.socket.req_protocol = protocol;
  803301:	8b 45 10             	mov    0x10(%ebp),%eax
  803304:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SOCKET);
  803309:	b8 09 00 00 00       	mov    $0x9,%eax
  80330e:	e8 4d fd ff ff       	call   803060 <nsipc>
}
  803313:	c9                   	leave  
  803314:	c3                   	ret    
  803315:	00 00                	add    %al,(%eax)
	...

00803318 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  803318:	55                   	push   %ebp
  803319:	89 e5                	mov    %esp,%ebp
  80331b:	56                   	push   %esi
  80331c:	53                   	push   %ebx
  80331d:	83 ec 10             	sub    $0x10,%esp
  803320:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  803323:	8b 45 08             	mov    0x8(%ebp),%eax
  803326:	89 04 24             	mov    %eax,(%esp)
  803329:	e8 c6 ea ff ff       	call   801df4 <fd2data>
  80332e:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  803330:	c7 44 24 04 78 43 80 	movl   $0x804378,0x4(%esp)
  803337:	00 
  803338:	89 34 24             	mov    %esi,(%esp)
  80333b:	e8 6f de ff ff       	call   8011af <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  803340:	8b 43 04             	mov    0x4(%ebx),%eax
  803343:	2b 03                	sub    (%ebx),%eax
  803345:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80334b:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  803352:	00 00 00 
	stat->st_dev = &devpipe;
  803355:	c7 86 88 00 00 00 5c 	movl   $0x80505c,0x88(%esi)
  80335c:	50 80 00 
	return 0;
}
  80335f:	b8 00 00 00 00       	mov    $0x0,%eax
  803364:	83 c4 10             	add    $0x10,%esp
  803367:	5b                   	pop    %ebx
  803368:	5e                   	pop    %esi
  803369:	5d                   	pop    %ebp
  80336a:	c3                   	ret    

0080336b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80336b:	55                   	push   %ebp
  80336c:	89 e5                	mov    %esp,%ebp
  80336e:	53                   	push   %ebx
  80336f:	83 ec 14             	sub    $0x14,%esp
  803372:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  803375:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  803379:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803380:	e8 c3 e2 ff ff       	call   801648 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  803385:	89 1c 24             	mov    %ebx,(%esp)
  803388:	e8 67 ea ff ff       	call   801df4 <fd2data>
  80338d:	89 44 24 04          	mov    %eax,0x4(%esp)
  803391:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803398:	e8 ab e2 ff ff       	call   801648 <sys_page_unmap>
}
  80339d:	83 c4 14             	add    $0x14,%esp
  8033a0:	5b                   	pop    %ebx
  8033a1:	5d                   	pop    %ebp
  8033a2:	c3                   	ret    

008033a3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8033a3:	55                   	push   %ebp
  8033a4:	89 e5                	mov    %esp,%ebp
  8033a6:	57                   	push   %edi
  8033a7:	56                   	push   %esi
  8033a8:	53                   	push   %ebx
  8033a9:	83 ec 2c             	sub    $0x2c,%esp
  8033ac:	89 c7                	mov    %eax,%edi
  8033ae:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8033b1:	a1 28 64 80 00       	mov    0x806428,%eax
  8033b6:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8033b9:	89 3c 24             	mov    %edi,(%esp)
  8033bc:	e8 d7 04 00 00       	call   803898 <pageref>
  8033c1:	89 c6                	mov    %eax,%esi
  8033c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8033c6:	89 04 24             	mov    %eax,(%esp)
  8033c9:	e8 ca 04 00 00       	call   803898 <pageref>
  8033ce:	39 c6                	cmp    %eax,%esi
  8033d0:	0f 94 c0             	sete   %al
  8033d3:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8033d6:	8b 15 28 64 80 00    	mov    0x806428,%edx
  8033dc:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8033df:	39 cb                	cmp    %ecx,%ebx
  8033e1:	75 08                	jne    8033eb <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8033e3:	83 c4 2c             	add    $0x2c,%esp
  8033e6:	5b                   	pop    %ebx
  8033e7:	5e                   	pop    %esi
  8033e8:	5f                   	pop    %edi
  8033e9:	5d                   	pop    %ebp
  8033ea:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8033eb:	83 f8 01             	cmp    $0x1,%eax
  8033ee:	75 c1                	jne    8033b1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8033f0:	8b 42 58             	mov    0x58(%edx),%eax
  8033f3:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  8033fa:	00 
  8033fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8033ff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  803403:	c7 04 24 7f 43 80 00 	movl   $0x80437f,(%esp)
  80340a:	e8 15 d7 ff ff       	call   800b24 <cprintf>
  80340f:	eb a0                	jmp    8033b1 <_pipeisclosed+0xe>

00803411 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  803411:	55                   	push   %ebp
  803412:	89 e5                	mov    %esp,%ebp
  803414:	57                   	push   %edi
  803415:	56                   	push   %esi
  803416:	53                   	push   %ebx
  803417:	83 ec 1c             	sub    $0x1c,%esp
  80341a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80341d:	89 34 24             	mov    %esi,(%esp)
  803420:	e8 cf e9 ff ff       	call   801df4 <fd2data>
  803425:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803427:	bf 00 00 00 00       	mov    $0x0,%edi
  80342c:	eb 3c                	jmp    80346a <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80342e:	89 da                	mov    %ebx,%edx
  803430:	89 f0                	mov    %esi,%eax
  803432:	e8 6c ff ff ff       	call   8033a3 <_pipeisclosed>
  803437:	85 c0                	test   %eax,%eax
  803439:	75 38                	jne    803473 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80343b:	e8 42 e1 ff ff       	call   801582 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  803440:	8b 43 04             	mov    0x4(%ebx),%eax
  803443:	8b 13                	mov    (%ebx),%edx
  803445:	83 c2 20             	add    $0x20,%edx
  803448:	39 d0                	cmp    %edx,%eax
  80344a:	73 e2                	jae    80342e <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80344c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80344f:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  803452:	89 c2                	mov    %eax,%edx
  803454:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  80345a:	79 05                	jns    803461 <devpipe_write+0x50>
  80345c:	4a                   	dec    %edx
  80345d:	83 ca e0             	or     $0xffffffe0,%edx
  803460:	42                   	inc    %edx
  803461:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  803465:	40                   	inc    %eax
  803466:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803469:	47                   	inc    %edi
  80346a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80346d:	75 d1                	jne    803440 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80346f:	89 f8                	mov    %edi,%eax
  803471:	eb 05                	jmp    803478 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  803473:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  803478:	83 c4 1c             	add    $0x1c,%esp
  80347b:	5b                   	pop    %ebx
  80347c:	5e                   	pop    %esi
  80347d:	5f                   	pop    %edi
  80347e:	5d                   	pop    %ebp
  80347f:	c3                   	ret    

00803480 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  803480:	55                   	push   %ebp
  803481:	89 e5                	mov    %esp,%ebp
  803483:	57                   	push   %edi
  803484:	56                   	push   %esi
  803485:	53                   	push   %ebx
  803486:	83 ec 1c             	sub    $0x1c,%esp
  803489:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80348c:	89 3c 24             	mov    %edi,(%esp)
  80348f:	e8 60 e9 ff ff       	call   801df4 <fd2data>
  803494:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803496:	be 00 00 00 00       	mov    $0x0,%esi
  80349b:	eb 3a                	jmp    8034d7 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80349d:	85 f6                	test   %esi,%esi
  80349f:	74 04                	je     8034a5 <devpipe_read+0x25>
				return i;
  8034a1:	89 f0                	mov    %esi,%eax
  8034a3:	eb 40                	jmp    8034e5 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8034a5:	89 da                	mov    %ebx,%edx
  8034a7:	89 f8                	mov    %edi,%eax
  8034a9:	e8 f5 fe ff ff       	call   8033a3 <_pipeisclosed>
  8034ae:	85 c0                	test   %eax,%eax
  8034b0:	75 2e                	jne    8034e0 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8034b2:	e8 cb e0 ff ff       	call   801582 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8034b7:	8b 03                	mov    (%ebx),%eax
  8034b9:	3b 43 04             	cmp    0x4(%ebx),%eax
  8034bc:	74 df                	je     80349d <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8034be:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8034c3:	79 05                	jns    8034ca <devpipe_read+0x4a>
  8034c5:	48                   	dec    %eax
  8034c6:	83 c8 e0             	or     $0xffffffe0,%eax
  8034c9:	40                   	inc    %eax
  8034ca:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8034ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8034d1:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8034d4:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8034d6:	46                   	inc    %esi
  8034d7:	3b 75 10             	cmp    0x10(%ebp),%esi
  8034da:	75 db                	jne    8034b7 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8034dc:	89 f0                	mov    %esi,%eax
  8034de:	eb 05                	jmp    8034e5 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8034e0:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8034e5:	83 c4 1c             	add    $0x1c,%esp
  8034e8:	5b                   	pop    %ebx
  8034e9:	5e                   	pop    %esi
  8034ea:	5f                   	pop    %edi
  8034eb:	5d                   	pop    %ebp
  8034ec:	c3                   	ret    

008034ed <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8034ed:	55                   	push   %ebp
  8034ee:	89 e5                	mov    %esp,%ebp
  8034f0:	57                   	push   %edi
  8034f1:	56                   	push   %esi
  8034f2:	53                   	push   %ebx
  8034f3:	83 ec 3c             	sub    $0x3c,%esp
  8034f6:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8034f9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8034fc:	89 04 24             	mov    %eax,(%esp)
  8034ff:	e8 0b e9 ff ff       	call   801e0f <fd_alloc>
  803504:	89 c3                	mov    %eax,%ebx
  803506:	85 c0                	test   %eax,%eax
  803508:	0f 88 45 01 00 00    	js     803653 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80350e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  803515:	00 
  803516:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803519:	89 44 24 04          	mov    %eax,0x4(%esp)
  80351d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803524:	e8 78 e0 ff ff       	call   8015a1 <sys_page_alloc>
  803529:	89 c3                	mov    %eax,%ebx
  80352b:	85 c0                	test   %eax,%eax
  80352d:	0f 88 20 01 00 00    	js     803653 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  803533:	8d 45 e0             	lea    -0x20(%ebp),%eax
  803536:	89 04 24             	mov    %eax,(%esp)
  803539:	e8 d1 e8 ff ff       	call   801e0f <fd_alloc>
  80353e:	89 c3                	mov    %eax,%ebx
  803540:	85 c0                	test   %eax,%eax
  803542:	0f 88 f8 00 00 00    	js     803640 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803548:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80354f:	00 
  803550:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803553:	89 44 24 04          	mov    %eax,0x4(%esp)
  803557:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80355e:	e8 3e e0 ff ff       	call   8015a1 <sys_page_alloc>
  803563:	89 c3                	mov    %eax,%ebx
  803565:	85 c0                	test   %eax,%eax
  803567:	0f 88 d3 00 00 00    	js     803640 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80356d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803570:	89 04 24             	mov    %eax,(%esp)
  803573:	e8 7c e8 ff ff       	call   801df4 <fd2data>
  803578:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80357a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  803581:	00 
  803582:	89 44 24 04          	mov    %eax,0x4(%esp)
  803586:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80358d:	e8 0f e0 ff ff       	call   8015a1 <sys_page_alloc>
  803592:	89 c3                	mov    %eax,%ebx
  803594:	85 c0                	test   %eax,%eax
  803596:	0f 88 91 00 00 00    	js     80362d <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80359c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80359f:	89 04 24             	mov    %eax,(%esp)
  8035a2:	e8 4d e8 ff ff       	call   801df4 <fd2data>
  8035a7:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8035ae:	00 
  8035af:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8035b3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8035ba:	00 
  8035bb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8035bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8035c6:	e8 2a e0 ff ff       	call   8015f5 <sys_page_map>
  8035cb:	89 c3                	mov    %eax,%ebx
  8035cd:	85 c0                	test   %eax,%eax
  8035cf:	78 4c                	js     80361d <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8035d1:	8b 15 5c 50 80 00    	mov    0x80505c,%edx
  8035d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8035da:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8035dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8035df:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8035e6:	8b 15 5c 50 80 00    	mov    0x80505c,%edx
  8035ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8035ef:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8035f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8035f4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8035fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8035fe:	89 04 24             	mov    %eax,(%esp)
  803601:	e8 de e7 ff ff       	call   801de4 <fd2num>
  803606:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  803608:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80360b:	89 04 24             	mov    %eax,(%esp)
  80360e:	e8 d1 e7 ff ff       	call   801de4 <fd2num>
  803613:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  803616:	bb 00 00 00 00       	mov    $0x0,%ebx
  80361b:	eb 36                	jmp    803653 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  80361d:	89 74 24 04          	mov    %esi,0x4(%esp)
  803621:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803628:	e8 1b e0 ff ff       	call   801648 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  80362d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803630:	89 44 24 04          	mov    %eax,0x4(%esp)
  803634:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80363b:	e8 08 e0 ff ff       	call   801648 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  803640:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803643:	89 44 24 04          	mov    %eax,0x4(%esp)
  803647:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80364e:	e8 f5 df ff ff       	call   801648 <sys_page_unmap>
    err:
	return r;
}
  803653:	89 d8                	mov    %ebx,%eax
  803655:	83 c4 3c             	add    $0x3c,%esp
  803658:	5b                   	pop    %ebx
  803659:	5e                   	pop    %esi
  80365a:	5f                   	pop    %edi
  80365b:	5d                   	pop    %ebp
  80365c:	c3                   	ret    

0080365d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80365d:	55                   	push   %ebp
  80365e:	89 e5                	mov    %esp,%ebp
  803660:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803663:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803666:	89 44 24 04          	mov    %eax,0x4(%esp)
  80366a:	8b 45 08             	mov    0x8(%ebp),%eax
  80366d:	89 04 24             	mov    %eax,(%esp)
  803670:	e8 ed e7 ff ff       	call   801e62 <fd_lookup>
  803675:	85 c0                	test   %eax,%eax
  803677:	78 15                	js     80368e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  803679:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80367c:	89 04 24             	mov    %eax,(%esp)
  80367f:	e8 70 e7 ff ff       	call   801df4 <fd2data>
	return _pipeisclosed(fd, p);
  803684:	89 c2                	mov    %eax,%edx
  803686:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803689:	e8 15 fd ff ff       	call   8033a3 <_pipeisclosed>
}
  80368e:	c9                   	leave  
  80368f:	c3                   	ret    

00803690 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  803690:	55                   	push   %ebp
  803691:	89 e5                	mov    %esp,%ebp
  803693:	56                   	push   %esi
  803694:	53                   	push   %ebx
  803695:	83 ec 10             	sub    $0x10,%esp
  803698:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  80369b:	85 f6                	test   %esi,%esi
  80369d:	75 24                	jne    8036c3 <wait+0x33>
  80369f:	c7 44 24 0c 97 43 80 	movl   $0x804397,0xc(%esp)
  8036a6:	00 
  8036a7:	c7 44 24 08 92 3c 80 	movl   $0x803c92,0x8(%esp)
  8036ae:	00 
  8036af:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  8036b6:	00 
  8036b7:	c7 04 24 a2 43 80 00 	movl   $0x8043a2,(%esp)
  8036be:	e8 69 d3 ff ff       	call   800a2c <_panic>
	e = &envs[ENVX(envid)];
  8036c3:	89 f3                	mov    %esi,%ebx
  8036c5:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  8036cb:	c1 e3 07             	shl    $0x7,%ebx
  8036ce:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8036d4:	eb 05                	jmp    8036db <wait+0x4b>
		sys_yield();
  8036d6:	e8 a7 de ff ff       	call   801582 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8036db:	8b 43 48             	mov    0x48(%ebx),%eax
  8036de:	39 f0                	cmp    %esi,%eax
  8036e0:	75 07                	jne    8036e9 <wait+0x59>
  8036e2:	8b 43 54             	mov    0x54(%ebx),%eax
  8036e5:	85 c0                	test   %eax,%eax
  8036e7:	75 ed                	jne    8036d6 <wait+0x46>
		sys_yield();
}
  8036e9:	83 c4 10             	add    $0x10,%esp
  8036ec:	5b                   	pop    %ebx
  8036ed:	5e                   	pop    %esi
  8036ee:	5d                   	pop    %ebp
  8036ef:	c3                   	ret    

008036f0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8036f0:	55                   	push   %ebp
  8036f1:	89 e5                	mov    %esp,%ebp
  8036f3:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8036f6:	83 3d 00 90 80 00 00 	cmpl   $0x0,0x809000
  8036fd:	75 58                	jne    803757 <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.	
		//panic("set_pgfault_handler not implemented");
		
		if (sys_page_alloc(thisenv->env_id,(void *) (UXSTACKTOP - PGSIZE),(PTE_W|PTE_U|PTE_P)) != 0){
  8036ff:	a1 28 64 80 00       	mov    0x806428,%eax
  803704:	8b 40 48             	mov    0x48(%eax),%eax
  803707:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80370e:	00 
  80370f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  803716:	ee 
  803717:	89 04 24             	mov    %eax,(%esp)
  80371a:	e8 82 de ff ff       	call   8015a1 <sys_page_alloc>
  80371f:	85 c0                	test   %eax,%eax
  803721:	74 1c                	je     80373f <set_pgfault_handler+0x4f>
			panic("set_pg_fault_handler");
  803723:	c7 44 24 08 ad 43 80 	movl   $0x8043ad,0x8(%esp)
  80372a:	00 
  80372b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  803732:	00 
  803733:	c7 04 24 c2 43 80 00 	movl   $0x8043c2,(%esp)
  80373a:	e8 ed d2 ff ff       	call   800a2c <_panic>
		}
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  80373f:	a1 28 64 80 00       	mov    0x806428,%eax
  803744:	8b 40 48             	mov    0x48(%eax),%eax
  803747:	c7 44 24 04 64 37 80 	movl   $0x803764,0x4(%esp)
  80374e:	00 
  80374f:	89 04 24             	mov    %eax,(%esp)
  803752:	e8 ea df ff ff       	call   801741 <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  803757:	8b 45 08             	mov    0x8(%ebp),%eax
  80375a:	a3 00 90 80 00       	mov    %eax,0x809000
}
  80375f:	c9                   	leave  
  803760:	c3                   	ret    
  803761:	00 00                	add    %al,(%eax)
	...

00803764 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  803764:	54                   	push   %esp
	movl _pgfault_handler, %eax
  803765:	a1 00 90 80 00       	mov    0x809000,%eax
	call *%eax
  80376a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80376c:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// Save trap-time eip in eax
	movl 0x28(%esp), %eax
  80376f:	8b 44 24 28          	mov    0x28(%esp),%eax

	// Save our current stack
	movl %esp, %ebp
  803773:	89 e5                	mov    %esp,%ebp

	// Switch to trap-time stack
	movl 0x30(%esp), %esp
  803775:	8b 64 24 30          	mov    0x30(%esp),%esp

	// Push trap-time eip to the trap-time stack
	pushl %eax
  803779:	50                   	push   %eax

	// We now have to update the trap-time esp with its new value
	movl %esp, 0x30(%ebp)
  80377a:	89 65 30             	mov    %esp,0x30(%ebp)

	// Go back to our exception stack
	movl %ebp, %esp
  80377d:	89 ec                	mov    %ebp,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// Pop fault_va and err, both can be ignored
	popl %eax
  80377f:	58                   	pop    %eax
	popl %eax
  803780:	58                   	pop    %eax

	// Pop all registers back
	popal
  803781:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// Skip %eip
	addl $0x4, %esp
  803782:	83 c4 04             	add    $0x4,%esp

	// Pop eflags back
	popfl
  803785:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	
	popl %esp
  803786:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  803787:	c3                   	ret    

00803788 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  803788:	55                   	push   %ebp
  803789:	89 e5                	mov    %esp,%ebp
  80378b:	56                   	push   %esi
  80378c:	53                   	push   %ebx
  80378d:	83 ec 10             	sub    $0x10,%esp
  803790:	8b 5d 08             	mov    0x8(%ebp),%ebx
  803793:	8b 45 0c             	mov    0xc(%ebp),%eax
  803796:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int r;
		
	r = sys_ipc_recv(pg?pg:(void*)UTOP);
  803799:	85 c0                	test   %eax,%eax
  80379b:	75 05                	jne    8037a2 <ipc_recv+0x1a>
  80379d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8037a2:	89 04 24             	mov    %eax,(%esp)
  8037a5:	e8 0d e0 ff ff       	call   8017b7 <sys_ipc_recv>
	if (from_env_store != NULL)
  8037aa:	85 db                	test   %ebx,%ebx
  8037ac:	74 0b                	je     8037b9 <ipc_recv+0x31>
		*from_env_store = thisenv->env_ipc_from; 
  8037ae:	8b 15 28 64 80 00    	mov    0x806428,%edx
  8037b4:	8b 52 74             	mov    0x74(%edx),%edx
  8037b7:	89 13                	mov    %edx,(%ebx)
	if (perm_store != NULL)
  8037b9:	85 f6                	test   %esi,%esi
  8037bb:	74 0b                	je     8037c8 <ipc_recv+0x40>
		*perm_store = thisenv->env_ipc_perm;
  8037bd:	8b 15 28 64 80 00    	mov    0x806428,%edx
  8037c3:	8b 52 78             	mov    0x78(%edx),%edx
  8037c6:	89 16                	mov    %edx,(%esi)
	
	if (r < 0){
  8037c8:	85 c0                	test   %eax,%eax
  8037ca:	79 16                	jns    8037e2 <ipc_recv+0x5a>
		if(from_env_store != NULL)
  8037cc:	85 db                	test   %ebx,%ebx
  8037ce:	74 06                	je     8037d6 <ipc_recv+0x4e>
			*from_env_store = 0;
  8037d0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store != NULL)	
  8037d6:	85 f6                	test   %esi,%esi
  8037d8:	74 10                	je     8037ea <ipc_recv+0x62>
			*perm_store = 0;
  8037da:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8037e0:	eb 08                	jmp    8037ea <ipc_recv+0x62>
		return r;
	}
	
	return thisenv->env_ipc_value;
  8037e2:	a1 28 64 80 00       	mov    0x806428,%eax
  8037e7:	8b 40 70             	mov    0x70(%eax),%eax
}
  8037ea:	83 c4 10             	add    $0x10,%esp
  8037ed:	5b                   	pop    %ebx
  8037ee:	5e                   	pop    %esi
  8037ef:	5d                   	pop    %ebp
  8037f0:	c3                   	ret    

008037f1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8037f1:	55                   	push   %ebp
  8037f2:	89 e5                	mov    %esp,%ebp
  8037f4:	57                   	push   %edi
  8037f5:	56                   	push   %esi
  8037f6:	53                   	push   %ebx
  8037f7:	83 ec 1c             	sub    $0x1c,%esp
  8037fa:	8b 75 08             	mov    0x8(%ebp),%esi
  8037fd:	8b 7d 0c             	mov    0xc(%ebp),%edi
  803800:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  803803:	eb 2a                	jmp    80382f <ipc_send+0x3e>
		if (r != -E_IPC_NOT_RECV)
  803805:	83 f8 f9             	cmp    $0xfffffff9,%eax
  803808:	74 20                	je     80382a <ipc_send+0x39>
			panic("ipc_send: sys_ipc_try_send failed %e", r);
  80380a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80380e:	c7 44 24 08 d0 43 80 	movl   $0x8043d0,0x8(%esp)
  803815:	00 
  803816:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  80381d:	00 
  80381e:	c7 04 24 f8 43 80 00 	movl   $0x8043f8,(%esp)
  803825:	e8 02 d2 ff ff       	call   800a2c <_panic>
		sys_yield();
  80382a:	e8 53 dd ff ff       	call   801582 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  80382f:	85 db                	test   %ebx,%ebx
  803831:	75 07                	jne    80383a <ipc_send+0x49>
  803833:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  803838:	eb 02                	jmp    80383c <ipc_send+0x4b>
  80383a:	89 d8                	mov    %ebx,%eax
  80383c:	8b 55 14             	mov    0x14(%ebp),%edx
  80383f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  803843:	89 44 24 08          	mov    %eax,0x8(%esp)
  803847:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80384b:	89 34 24             	mov    %esi,(%esp)
  80384e:	e8 41 df ff ff       	call   801794 <sys_ipc_try_send>
  803853:	85 c0                	test   %eax,%eax
  803855:	78 ae                	js     803805 <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: sys_ipc_try_send failed %e", r);
		sys_yield();
	}
}
  803857:	83 c4 1c             	add    $0x1c,%esp
  80385a:	5b                   	pop    %ebx
  80385b:	5e                   	pop    %esi
  80385c:	5f                   	pop    %edi
  80385d:	5d                   	pop    %ebp
  80385e:	c3                   	ret    

0080385f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80385f:	55                   	push   %ebp
  803860:	89 e5                	mov    %esp,%ebp
  803862:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  803865:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80386a:	89 c2                	mov    %eax,%edx
  80386c:	c1 e2 07             	shl    $0x7,%edx
  80386f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  803875:	8b 52 50             	mov    0x50(%edx),%edx
  803878:	39 ca                	cmp    %ecx,%edx
  80387a:	75 0d                	jne    803889 <ipc_find_env+0x2a>
			return envs[i].env_id;
  80387c:	c1 e0 07             	shl    $0x7,%eax
  80387f:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  803884:	8b 40 40             	mov    0x40(%eax),%eax
  803887:	eb 0c                	jmp    803895 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  803889:	40                   	inc    %eax
  80388a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80388f:	75 d9                	jne    80386a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  803891:	66 b8 00 00          	mov    $0x0,%ax
}
  803895:	5d                   	pop    %ebp
  803896:	c3                   	ret    
	...

00803898 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  803898:	55                   	push   %ebp
  803899:	89 e5                	mov    %esp,%ebp
  80389b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80389e:	89 c2                	mov    %eax,%edx
  8038a0:	c1 ea 16             	shr    $0x16,%edx
  8038a3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8038aa:	f6 c2 01             	test   $0x1,%dl
  8038ad:	74 1e                	je     8038cd <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8038af:	c1 e8 0c             	shr    $0xc,%eax
  8038b2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8038b9:	a8 01                	test   $0x1,%al
  8038bb:	74 17                	je     8038d4 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8038bd:	c1 e8 0c             	shr    $0xc,%eax
  8038c0:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8038c7:	ef 
  8038c8:	0f b7 c0             	movzwl %ax,%eax
  8038cb:	eb 0c                	jmp    8038d9 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8038cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8038d2:	eb 05                	jmp    8038d9 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8038d4:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8038d9:	5d                   	pop    %ebp
  8038da:	c3                   	ret    
	...

008038dc <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8038dc:	55                   	push   %ebp
  8038dd:	57                   	push   %edi
  8038de:	56                   	push   %esi
  8038df:	83 ec 10             	sub    $0x10,%esp
  8038e2:	8b 74 24 20          	mov    0x20(%esp),%esi
  8038e6:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8038ea:	89 74 24 04          	mov    %esi,0x4(%esp)
  8038ee:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  8038f2:	89 cd                	mov    %ecx,%ebp
  8038f4:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8038f8:	85 c0                	test   %eax,%eax
  8038fa:	75 2c                	jne    803928 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8038fc:	39 f9                	cmp    %edi,%ecx
  8038fe:	77 68                	ja     803968 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  803900:	85 c9                	test   %ecx,%ecx
  803902:	75 0b                	jne    80390f <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  803904:	b8 01 00 00 00       	mov    $0x1,%eax
  803909:	31 d2                	xor    %edx,%edx
  80390b:	f7 f1                	div    %ecx
  80390d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80390f:	31 d2                	xor    %edx,%edx
  803911:	89 f8                	mov    %edi,%eax
  803913:	f7 f1                	div    %ecx
  803915:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  803917:	89 f0                	mov    %esi,%eax
  803919:	f7 f1                	div    %ecx
  80391b:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80391d:	89 f0                	mov    %esi,%eax
  80391f:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  803921:	83 c4 10             	add    $0x10,%esp
  803924:	5e                   	pop    %esi
  803925:	5f                   	pop    %edi
  803926:	5d                   	pop    %ebp
  803927:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  803928:	39 f8                	cmp    %edi,%eax
  80392a:	77 2c                	ja     803958 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80392c:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  80392f:	83 f6 1f             	xor    $0x1f,%esi
  803932:	75 4c                	jne    803980 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  803934:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  803936:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80393b:	72 0a                	jb     803947 <__udivdi3+0x6b>
  80393d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  803941:	0f 87 ad 00 00 00    	ja     8039f4 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  803947:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80394c:	89 f0                	mov    %esi,%eax
  80394e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  803950:	83 c4 10             	add    $0x10,%esp
  803953:	5e                   	pop    %esi
  803954:	5f                   	pop    %edi
  803955:	5d                   	pop    %ebp
  803956:	c3                   	ret    
  803957:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  803958:	31 ff                	xor    %edi,%edi
  80395a:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80395c:	89 f0                	mov    %esi,%eax
  80395e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  803960:	83 c4 10             	add    $0x10,%esp
  803963:	5e                   	pop    %esi
  803964:	5f                   	pop    %edi
  803965:	5d                   	pop    %ebp
  803966:	c3                   	ret    
  803967:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  803968:	89 fa                	mov    %edi,%edx
  80396a:	89 f0                	mov    %esi,%eax
  80396c:	f7 f1                	div    %ecx
  80396e:	89 c6                	mov    %eax,%esi
  803970:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  803972:	89 f0                	mov    %esi,%eax
  803974:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  803976:	83 c4 10             	add    $0x10,%esp
  803979:	5e                   	pop    %esi
  80397a:	5f                   	pop    %edi
  80397b:	5d                   	pop    %ebp
  80397c:	c3                   	ret    
  80397d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  803980:	89 f1                	mov    %esi,%ecx
  803982:	d3 e0                	shl    %cl,%eax
  803984:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  803988:	b8 20 00 00 00       	mov    $0x20,%eax
  80398d:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80398f:	89 ea                	mov    %ebp,%edx
  803991:	88 c1                	mov    %al,%cl
  803993:	d3 ea                	shr    %cl,%edx
  803995:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  803999:	09 ca                	or     %ecx,%edx
  80399b:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  80399f:	89 f1                	mov    %esi,%ecx
  8039a1:	d3 e5                	shl    %cl,%ebp
  8039a3:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  8039a7:	89 fd                	mov    %edi,%ebp
  8039a9:	88 c1                	mov    %al,%cl
  8039ab:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  8039ad:	89 fa                	mov    %edi,%edx
  8039af:	89 f1                	mov    %esi,%ecx
  8039b1:	d3 e2                	shl    %cl,%edx
  8039b3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8039b7:	88 c1                	mov    %al,%cl
  8039b9:	d3 ef                	shr    %cl,%edi
  8039bb:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8039bd:	89 f8                	mov    %edi,%eax
  8039bf:	89 ea                	mov    %ebp,%edx
  8039c1:	f7 74 24 08          	divl   0x8(%esp)
  8039c5:	89 d1                	mov    %edx,%ecx
  8039c7:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  8039c9:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8039cd:	39 d1                	cmp    %edx,%ecx
  8039cf:	72 17                	jb     8039e8 <__udivdi3+0x10c>
  8039d1:	74 09                	je     8039dc <__udivdi3+0x100>
  8039d3:	89 fe                	mov    %edi,%esi
  8039d5:	31 ff                	xor    %edi,%edi
  8039d7:	e9 41 ff ff ff       	jmp    80391d <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8039dc:	8b 54 24 04          	mov    0x4(%esp),%edx
  8039e0:	89 f1                	mov    %esi,%ecx
  8039e2:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8039e4:	39 c2                	cmp    %eax,%edx
  8039e6:	73 eb                	jae    8039d3 <__udivdi3+0xf7>
		{
		  q0--;
  8039e8:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8039eb:	31 ff                	xor    %edi,%edi
  8039ed:	e9 2b ff ff ff       	jmp    80391d <__udivdi3+0x41>
  8039f2:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8039f4:	31 f6                	xor    %esi,%esi
  8039f6:	e9 22 ff ff ff       	jmp    80391d <__udivdi3+0x41>
	...

008039fc <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8039fc:	55                   	push   %ebp
  8039fd:	57                   	push   %edi
  8039fe:	56                   	push   %esi
  8039ff:	83 ec 20             	sub    $0x20,%esp
  803a02:	8b 44 24 30          	mov    0x30(%esp),%eax
  803a06:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  803a0a:	89 44 24 14          	mov    %eax,0x14(%esp)
  803a0e:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  803a12:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  803a16:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  803a1a:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  803a1c:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  803a1e:	85 ed                	test   %ebp,%ebp
  803a20:	75 16                	jne    803a38 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  803a22:	39 f1                	cmp    %esi,%ecx
  803a24:	0f 86 a6 00 00 00    	jbe    803ad0 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  803a2a:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  803a2c:	89 d0                	mov    %edx,%eax
  803a2e:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  803a30:	83 c4 20             	add    $0x20,%esp
  803a33:	5e                   	pop    %esi
  803a34:	5f                   	pop    %edi
  803a35:	5d                   	pop    %ebp
  803a36:	c3                   	ret    
  803a37:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  803a38:	39 f5                	cmp    %esi,%ebp
  803a3a:	0f 87 ac 00 00 00    	ja     803aec <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  803a40:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  803a43:	83 f0 1f             	xor    $0x1f,%eax
  803a46:	89 44 24 10          	mov    %eax,0x10(%esp)
  803a4a:	0f 84 a8 00 00 00    	je     803af8 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  803a50:	8a 4c 24 10          	mov    0x10(%esp),%cl
  803a54:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  803a56:	bf 20 00 00 00       	mov    $0x20,%edi
  803a5b:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  803a5f:	8b 44 24 0c          	mov    0xc(%esp),%eax
  803a63:	89 f9                	mov    %edi,%ecx
  803a65:	d3 e8                	shr    %cl,%eax
  803a67:	09 e8                	or     %ebp,%eax
  803a69:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  803a6d:	8b 44 24 0c          	mov    0xc(%esp),%eax
  803a71:	8a 4c 24 10          	mov    0x10(%esp),%cl
  803a75:	d3 e0                	shl    %cl,%eax
  803a77:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  803a7b:	89 f2                	mov    %esi,%edx
  803a7d:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  803a7f:	8b 44 24 14          	mov    0x14(%esp),%eax
  803a83:	d3 e0                	shl    %cl,%eax
  803a85:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  803a89:	8b 44 24 14          	mov    0x14(%esp),%eax
  803a8d:	89 f9                	mov    %edi,%ecx
  803a8f:	d3 e8                	shr    %cl,%eax
  803a91:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  803a93:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  803a95:	89 f2                	mov    %esi,%edx
  803a97:	f7 74 24 18          	divl   0x18(%esp)
  803a9b:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  803a9d:	f7 64 24 0c          	mull   0xc(%esp)
  803aa1:	89 c5                	mov    %eax,%ebp
  803aa3:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  803aa5:	39 d6                	cmp    %edx,%esi
  803aa7:	72 67                	jb     803b10 <__umoddi3+0x114>
  803aa9:	74 75                	je     803b20 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  803aab:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  803aaf:	29 e8                	sub    %ebp,%eax
  803ab1:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  803ab3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  803ab7:	d3 e8                	shr    %cl,%eax
  803ab9:	89 f2                	mov    %esi,%edx
  803abb:	89 f9                	mov    %edi,%ecx
  803abd:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  803abf:	09 d0                	or     %edx,%eax
  803ac1:	89 f2                	mov    %esi,%edx
  803ac3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  803ac7:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  803ac9:	83 c4 20             	add    $0x20,%esp
  803acc:	5e                   	pop    %esi
  803acd:	5f                   	pop    %edi
  803ace:	5d                   	pop    %ebp
  803acf:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  803ad0:	85 c9                	test   %ecx,%ecx
  803ad2:	75 0b                	jne    803adf <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  803ad4:	b8 01 00 00 00       	mov    $0x1,%eax
  803ad9:	31 d2                	xor    %edx,%edx
  803adb:	f7 f1                	div    %ecx
  803add:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  803adf:	89 f0                	mov    %esi,%eax
  803ae1:	31 d2                	xor    %edx,%edx
  803ae3:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  803ae5:	89 f8                	mov    %edi,%eax
  803ae7:	e9 3e ff ff ff       	jmp    803a2a <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  803aec:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  803aee:	83 c4 20             	add    $0x20,%esp
  803af1:	5e                   	pop    %esi
  803af2:	5f                   	pop    %edi
  803af3:	5d                   	pop    %ebp
  803af4:	c3                   	ret    
  803af5:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  803af8:	39 f5                	cmp    %esi,%ebp
  803afa:	72 04                	jb     803b00 <__umoddi3+0x104>
  803afc:	39 f9                	cmp    %edi,%ecx
  803afe:	77 06                	ja     803b06 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  803b00:	89 f2                	mov    %esi,%edx
  803b02:	29 cf                	sub    %ecx,%edi
  803b04:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  803b06:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  803b08:	83 c4 20             	add    $0x20,%esp
  803b0b:	5e                   	pop    %esi
  803b0c:	5f                   	pop    %edi
  803b0d:	5d                   	pop    %ebp
  803b0e:	c3                   	ret    
  803b0f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  803b10:	89 d1                	mov    %edx,%ecx
  803b12:	89 c5                	mov    %eax,%ebp
  803b14:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  803b18:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  803b1c:	eb 8d                	jmp    803aab <__umoddi3+0xaf>
  803b1e:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  803b20:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  803b24:	72 ea                	jb     803b10 <__umoddi3+0x114>
  803b26:	89 f1                	mov    %esi,%ecx
  803b28:	eb 81                	jmp    803aab <__umoddi3+0xaf>
