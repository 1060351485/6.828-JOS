
obj/user/echo.debug:     file format elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
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
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
  80003d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800040:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i, nflag;

	nflag = 0;
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  800043:	83 ff 01             	cmp    $0x1,%edi
  800046:	7e 24                	jle    80006c <umain+0x38>
  800048:	c7 44 24 04 c0 1f 80 	movl   $0x801fc0,0x4(%esp)
  80004f:	00 
  800050:	8b 46 04             	mov    0x4(%esi),%eax
  800053:	89 04 24             	mov    %eax,(%esp)
  800056:	e8 df 01 00 00       	call   80023a <strcmp>
  80005b:	85 c0                	test   %eax,%eax
  80005d:	75 16                	jne    800075 <umain+0x41>
		nflag = 1;
		argc--;
  80005f:	4f                   	dec    %edi
		argv++;
  800060:	83 c6 04             	add    $0x4,%esi
{
	int i, nflag;

	nflag = 0;
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
		nflag = 1;
  800063:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
  80006a:	eb 10                	jmp    80007c <umain+0x48>
void
umain(int argc, char **argv)
{
	int i, nflag;

	nflag = 0;
  80006c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800073:	eb 07                	jmp    80007c <umain+0x48>
  800075:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
		nflag = 1;
		argc--;
		argv++;
	}
	for (i = 1; i < argc; i++) {
  80007c:	bb 01 00 00 00       	mov    $0x1,%ebx
  800081:	eb 44                	jmp    8000c7 <umain+0x93>
		if (i > 1)
  800083:	83 fb 01             	cmp    $0x1,%ebx
  800086:	7e 1c                	jle    8000a4 <umain+0x70>
			write(1, " ", 1);
  800088:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  80008f:	00 
  800090:	c7 44 24 04 c3 1f 80 	movl   $0x801fc3,0x4(%esp)
  800097:	00 
  800098:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80009f:	e8 41 0b 00 00       	call   800be5 <write>
		write(1, argv[i], strlen(argv[i]));
  8000a4:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  8000a7:	89 04 24             	mov    %eax,(%esp)
  8000aa:	e8 b1 00 00 00       	call   800160 <strlen>
  8000af:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000b3:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  8000b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000ba:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8000c1:	e8 1f 0b 00 00       	call   800be5 <write>
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
		nflag = 1;
		argc--;
		argv++;
	}
	for (i = 1; i < argc; i++) {
  8000c6:	43                   	inc    %ebx
  8000c7:	39 df                	cmp    %ebx,%edi
  8000c9:	7f b8                	jg     800083 <umain+0x4f>
		if (i > 1)
			write(1, " ", 1);
		write(1, argv[i], strlen(argv[i]));
	}
	if (!nflag)
  8000cb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000cf:	75 1c                	jne    8000ed <umain+0xb9>
		write(1, "\n", 1);
  8000d1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8000d8:	00 
  8000d9:	c7 44 24 04 d3 20 80 	movl   $0x8020d3,0x4(%esp)
  8000e0:	00 
  8000e1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8000e8:	e8 f8 0a 00 00       	call   800be5 <write>
}
  8000ed:	83 c4 2c             	add    $0x2c,%esp
  8000f0:	5b                   	pop    %ebx
  8000f1:	5e                   	pop    %esi
  8000f2:	5f                   	pop    %edi
  8000f3:	5d                   	pop    %ebp
  8000f4:	c3                   	ret    
  8000f5:	00 00                	add    %al,(%eax)
	...

008000f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
  8000fd:	83 ec 10             	sub    $0x10,%esp
  800100:	8b 75 08             	mov    0x8(%ebp),%esi
  800103:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800106:	e8 3c 04 00 00       	call   800547 <sys_getenvid>
  80010b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800110:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800117:	c1 e0 07             	shl    $0x7,%eax
  80011a:	29 d0                	sub    %edx,%eax
  80011c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800121:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800126:	85 f6                	test   %esi,%esi
  800128:	7e 07                	jle    800131 <libmain+0x39>
		binaryname = argv[0];
  80012a:	8b 03                	mov    (%ebx),%eax
  80012c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800131:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800135:	89 34 24             	mov    %esi,(%esp)
  800138:	e8 f7 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80013d:	e8 0a 00 00 00       	call   80014c <exit>
}
  800142:	83 c4 10             	add    $0x10,%esp
  800145:	5b                   	pop    %ebx
  800146:	5e                   	pop    %esi
  800147:	5d                   	pop    %ebp
  800148:	c3                   	ret    
  800149:	00 00                	add    %al,(%eax)
	...

0080014c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  800152:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800159:	e8 97 03 00 00       	call   8004f5 <sys_env_destroy>
}
  80015e:	c9                   	leave  
  80015f:	c3                   	ret    

00800160 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800166:	b8 00 00 00 00       	mov    $0x0,%eax
  80016b:	eb 01                	jmp    80016e <strlen+0xe>
		n++;
  80016d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80016e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800172:	75 f9                	jne    80016d <strlen+0xd>
		n++;
	return n;
}
  800174:	5d                   	pop    %ebp
  800175:	c3                   	ret    

00800176 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800176:	55                   	push   %ebp
  800177:	89 e5                	mov    %esp,%ebp
  800179:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  80017c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80017f:	b8 00 00 00 00       	mov    $0x0,%eax
  800184:	eb 01                	jmp    800187 <strnlen+0x11>
		n++;
  800186:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800187:	39 d0                	cmp    %edx,%eax
  800189:	74 06                	je     800191 <strnlen+0x1b>
  80018b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80018f:	75 f5                	jne    800186 <strnlen+0x10>
		n++;
	return n;
}
  800191:	5d                   	pop    %ebp
  800192:	c3                   	ret    

00800193 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800193:	55                   	push   %ebp
  800194:	89 e5                	mov    %esp,%ebp
  800196:	53                   	push   %ebx
  800197:	8b 45 08             	mov    0x8(%ebp),%eax
  80019a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80019d:	ba 00 00 00 00       	mov    $0x0,%edx
  8001a2:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8001a5:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8001a8:	42                   	inc    %edx
  8001a9:	84 c9                	test   %cl,%cl
  8001ab:	75 f5                	jne    8001a2 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8001ad:	5b                   	pop    %ebx
  8001ae:	5d                   	pop    %ebp
  8001af:	c3                   	ret    

008001b0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	53                   	push   %ebx
  8001b4:	83 ec 08             	sub    $0x8,%esp
  8001b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8001ba:	89 1c 24             	mov    %ebx,(%esp)
  8001bd:	e8 9e ff ff ff       	call   800160 <strlen>
	strcpy(dst + len, src);
  8001c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001c9:	01 d8                	add    %ebx,%eax
  8001cb:	89 04 24             	mov    %eax,(%esp)
  8001ce:	e8 c0 ff ff ff       	call   800193 <strcpy>
	return dst;
}
  8001d3:	89 d8                	mov    %ebx,%eax
  8001d5:	83 c4 08             	add    $0x8,%esp
  8001d8:	5b                   	pop    %ebx
  8001d9:	5d                   	pop    %ebp
  8001da:	c3                   	ret    

008001db <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	56                   	push   %esi
  8001df:	53                   	push   %ebx
  8001e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001e6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8001e9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001ee:	eb 0c                	jmp    8001fc <strncpy+0x21>
		*dst++ = *src;
  8001f0:	8a 1a                	mov    (%edx),%bl
  8001f2:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8001f5:	80 3a 01             	cmpb   $0x1,(%edx)
  8001f8:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8001fb:	41                   	inc    %ecx
  8001fc:	39 f1                	cmp    %esi,%ecx
  8001fe:	75 f0                	jne    8001f0 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800200:	5b                   	pop    %ebx
  800201:	5e                   	pop    %esi
  800202:	5d                   	pop    %ebp
  800203:	c3                   	ret    

00800204 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800204:	55                   	push   %ebp
  800205:	89 e5                	mov    %esp,%ebp
  800207:	56                   	push   %esi
  800208:	53                   	push   %ebx
  800209:	8b 75 08             	mov    0x8(%ebp),%esi
  80020c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80020f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800212:	85 d2                	test   %edx,%edx
  800214:	75 0a                	jne    800220 <strlcpy+0x1c>
  800216:	89 f0                	mov    %esi,%eax
  800218:	eb 1a                	jmp    800234 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80021a:	88 18                	mov    %bl,(%eax)
  80021c:	40                   	inc    %eax
  80021d:	41                   	inc    %ecx
  80021e:	eb 02                	jmp    800222 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800220:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800222:	4a                   	dec    %edx
  800223:	74 0a                	je     80022f <strlcpy+0x2b>
  800225:	8a 19                	mov    (%ecx),%bl
  800227:	84 db                	test   %bl,%bl
  800229:	75 ef                	jne    80021a <strlcpy+0x16>
  80022b:	89 c2                	mov    %eax,%edx
  80022d:	eb 02                	jmp    800231 <strlcpy+0x2d>
  80022f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800231:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800234:	29 f0                	sub    %esi,%eax
}
  800236:	5b                   	pop    %ebx
  800237:	5e                   	pop    %esi
  800238:	5d                   	pop    %ebp
  800239:	c3                   	ret    

0080023a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80023a:	55                   	push   %ebp
  80023b:	89 e5                	mov    %esp,%ebp
  80023d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800240:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800243:	eb 02                	jmp    800247 <strcmp+0xd>
		p++, q++;
  800245:	41                   	inc    %ecx
  800246:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800247:	8a 01                	mov    (%ecx),%al
  800249:	84 c0                	test   %al,%al
  80024b:	74 04                	je     800251 <strcmp+0x17>
  80024d:	3a 02                	cmp    (%edx),%al
  80024f:	74 f4                	je     800245 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800251:	0f b6 c0             	movzbl %al,%eax
  800254:	0f b6 12             	movzbl (%edx),%edx
  800257:	29 d0                	sub    %edx,%eax
}
  800259:	5d                   	pop    %ebp
  80025a:	c3                   	ret    

0080025b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80025b:	55                   	push   %ebp
  80025c:	89 e5                	mov    %esp,%ebp
  80025e:	53                   	push   %ebx
  80025f:	8b 45 08             	mov    0x8(%ebp),%eax
  800262:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800265:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800268:	eb 03                	jmp    80026d <strncmp+0x12>
		n--, p++, q++;
  80026a:	4a                   	dec    %edx
  80026b:	40                   	inc    %eax
  80026c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80026d:	85 d2                	test   %edx,%edx
  80026f:	74 14                	je     800285 <strncmp+0x2a>
  800271:	8a 18                	mov    (%eax),%bl
  800273:	84 db                	test   %bl,%bl
  800275:	74 04                	je     80027b <strncmp+0x20>
  800277:	3a 19                	cmp    (%ecx),%bl
  800279:	74 ef                	je     80026a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80027b:	0f b6 00             	movzbl (%eax),%eax
  80027e:	0f b6 11             	movzbl (%ecx),%edx
  800281:	29 d0                	sub    %edx,%eax
  800283:	eb 05                	jmp    80028a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800285:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80028a:	5b                   	pop    %ebx
  80028b:	5d                   	pop    %ebp
  80028c:	c3                   	ret    

0080028d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80028d:	55                   	push   %ebp
  80028e:	89 e5                	mov    %esp,%ebp
  800290:	8b 45 08             	mov    0x8(%ebp),%eax
  800293:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800296:	eb 05                	jmp    80029d <strchr+0x10>
		if (*s == c)
  800298:	38 ca                	cmp    %cl,%dl
  80029a:	74 0c                	je     8002a8 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80029c:	40                   	inc    %eax
  80029d:	8a 10                	mov    (%eax),%dl
  80029f:	84 d2                	test   %dl,%dl
  8002a1:	75 f5                	jne    800298 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8002a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8002a8:	5d                   	pop    %ebp
  8002a9:	c3                   	ret    

008002aa <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8002aa:	55                   	push   %ebp
  8002ab:	89 e5                	mov    %esp,%ebp
  8002ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b0:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8002b3:	eb 05                	jmp    8002ba <strfind+0x10>
		if (*s == c)
  8002b5:	38 ca                	cmp    %cl,%dl
  8002b7:	74 07                	je     8002c0 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8002b9:	40                   	inc    %eax
  8002ba:	8a 10                	mov    (%eax),%dl
  8002bc:	84 d2                	test   %dl,%dl
  8002be:	75 f5                	jne    8002b5 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8002c0:	5d                   	pop    %ebp
  8002c1:	c3                   	ret    

008002c2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8002c2:	55                   	push   %ebp
  8002c3:	89 e5                	mov    %esp,%ebp
  8002c5:	57                   	push   %edi
  8002c6:	56                   	push   %esi
  8002c7:	53                   	push   %ebx
  8002c8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8002cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002ce:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8002d1:	85 c9                	test   %ecx,%ecx
  8002d3:	74 30                	je     800305 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8002d5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8002db:	75 25                	jne    800302 <memset+0x40>
  8002dd:	f6 c1 03             	test   $0x3,%cl
  8002e0:	75 20                	jne    800302 <memset+0x40>
		c &= 0xFF;
  8002e2:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8002e5:	89 d3                	mov    %edx,%ebx
  8002e7:	c1 e3 08             	shl    $0x8,%ebx
  8002ea:	89 d6                	mov    %edx,%esi
  8002ec:	c1 e6 18             	shl    $0x18,%esi
  8002ef:	89 d0                	mov    %edx,%eax
  8002f1:	c1 e0 10             	shl    $0x10,%eax
  8002f4:	09 f0                	or     %esi,%eax
  8002f6:	09 d0                	or     %edx,%eax
  8002f8:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8002fa:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8002fd:	fc                   	cld    
  8002fe:	f3 ab                	rep stos %eax,%es:(%edi)
  800300:	eb 03                	jmp    800305 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800302:	fc                   	cld    
  800303:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800305:	89 f8                	mov    %edi,%eax
  800307:	5b                   	pop    %ebx
  800308:	5e                   	pop    %esi
  800309:	5f                   	pop    %edi
  80030a:	5d                   	pop    %ebp
  80030b:	c3                   	ret    

0080030c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80030c:	55                   	push   %ebp
  80030d:	89 e5                	mov    %esp,%ebp
  80030f:	57                   	push   %edi
  800310:	56                   	push   %esi
  800311:	8b 45 08             	mov    0x8(%ebp),%eax
  800314:	8b 75 0c             	mov    0xc(%ebp),%esi
  800317:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80031a:	39 c6                	cmp    %eax,%esi
  80031c:	73 34                	jae    800352 <memmove+0x46>
  80031e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800321:	39 d0                	cmp    %edx,%eax
  800323:	73 2d                	jae    800352 <memmove+0x46>
		s += n;
		d += n;
  800325:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800328:	f6 c2 03             	test   $0x3,%dl
  80032b:	75 1b                	jne    800348 <memmove+0x3c>
  80032d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800333:	75 13                	jne    800348 <memmove+0x3c>
  800335:	f6 c1 03             	test   $0x3,%cl
  800338:	75 0e                	jne    800348 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80033a:	83 ef 04             	sub    $0x4,%edi
  80033d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800340:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800343:	fd                   	std    
  800344:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800346:	eb 07                	jmp    80034f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800348:	4f                   	dec    %edi
  800349:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80034c:	fd                   	std    
  80034d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80034f:	fc                   	cld    
  800350:	eb 20                	jmp    800372 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800352:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800358:	75 13                	jne    80036d <memmove+0x61>
  80035a:	a8 03                	test   $0x3,%al
  80035c:	75 0f                	jne    80036d <memmove+0x61>
  80035e:	f6 c1 03             	test   $0x3,%cl
  800361:	75 0a                	jne    80036d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800363:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800366:	89 c7                	mov    %eax,%edi
  800368:	fc                   	cld    
  800369:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80036b:	eb 05                	jmp    800372 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80036d:	89 c7                	mov    %eax,%edi
  80036f:	fc                   	cld    
  800370:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800372:	5e                   	pop    %esi
  800373:	5f                   	pop    %edi
  800374:	5d                   	pop    %ebp
  800375:	c3                   	ret    

00800376 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800376:	55                   	push   %ebp
  800377:	89 e5                	mov    %esp,%ebp
  800379:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80037c:	8b 45 10             	mov    0x10(%ebp),%eax
  80037f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800383:	8b 45 0c             	mov    0xc(%ebp),%eax
  800386:	89 44 24 04          	mov    %eax,0x4(%esp)
  80038a:	8b 45 08             	mov    0x8(%ebp),%eax
  80038d:	89 04 24             	mov    %eax,(%esp)
  800390:	e8 77 ff ff ff       	call   80030c <memmove>
}
  800395:	c9                   	leave  
  800396:	c3                   	ret    

00800397 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800397:	55                   	push   %ebp
  800398:	89 e5                	mov    %esp,%ebp
  80039a:	57                   	push   %edi
  80039b:	56                   	push   %esi
  80039c:	53                   	push   %ebx
  80039d:	8b 7d 08             	mov    0x8(%ebp),%edi
  8003a0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003a3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8003a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ab:	eb 16                	jmp    8003c3 <memcmp+0x2c>
		if (*s1 != *s2)
  8003ad:	8a 04 17             	mov    (%edi,%edx,1),%al
  8003b0:	42                   	inc    %edx
  8003b1:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8003b5:	38 c8                	cmp    %cl,%al
  8003b7:	74 0a                	je     8003c3 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8003b9:	0f b6 c0             	movzbl %al,%eax
  8003bc:	0f b6 c9             	movzbl %cl,%ecx
  8003bf:	29 c8                	sub    %ecx,%eax
  8003c1:	eb 09                	jmp    8003cc <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8003c3:	39 da                	cmp    %ebx,%edx
  8003c5:	75 e6                	jne    8003ad <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8003c7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003cc:	5b                   	pop    %ebx
  8003cd:	5e                   	pop    %esi
  8003ce:	5f                   	pop    %edi
  8003cf:	5d                   	pop    %ebp
  8003d0:	c3                   	ret    

008003d1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8003d1:	55                   	push   %ebp
  8003d2:	89 e5                	mov    %esp,%ebp
  8003d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8003da:	89 c2                	mov    %eax,%edx
  8003dc:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8003df:	eb 05                	jmp    8003e6 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8003e1:	38 08                	cmp    %cl,(%eax)
  8003e3:	74 05                	je     8003ea <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8003e5:	40                   	inc    %eax
  8003e6:	39 d0                	cmp    %edx,%eax
  8003e8:	72 f7                	jb     8003e1 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8003ea:	5d                   	pop    %ebp
  8003eb:	c3                   	ret    

008003ec <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8003ec:	55                   	push   %ebp
  8003ed:	89 e5                	mov    %esp,%ebp
  8003ef:	57                   	push   %edi
  8003f0:	56                   	push   %esi
  8003f1:	53                   	push   %ebx
  8003f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8003f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8003f8:	eb 01                	jmp    8003fb <strtol+0xf>
		s++;
  8003fa:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8003fb:	8a 02                	mov    (%edx),%al
  8003fd:	3c 20                	cmp    $0x20,%al
  8003ff:	74 f9                	je     8003fa <strtol+0xe>
  800401:	3c 09                	cmp    $0x9,%al
  800403:	74 f5                	je     8003fa <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800405:	3c 2b                	cmp    $0x2b,%al
  800407:	75 08                	jne    800411 <strtol+0x25>
		s++;
  800409:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80040a:	bf 00 00 00 00       	mov    $0x0,%edi
  80040f:	eb 13                	jmp    800424 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800411:	3c 2d                	cmp    $0x2d,%al
  800413:	75 0a                	jne    80041f <strtol+0x33>
		s++, neg = 1;
  800415:	8d 52 01             	lea    0x1(%edx),%edx
  800418:	bf 01 00 00 00       	mov    $0x1,%edi
  80041d:	eb 05                	jmp    800424 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80041f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800424:	85 db                	test   %ebx,%ebx
  800426:	74 05                	je     80042d <strtol+0x41>
  800428:	83 fb 10             	cmp    $0x10,%ebx
  80042b:	75 28                	jne    800455 <strtol+0x69>
  80042d:	8a 02                	mov    (%edx),%al
  80042f:	3c 30                	cmp    $0x30,%al
  800431:	75 10                	jne    800443 <strtol+0x57>
  800433:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800437:	75 0a                	jne    800443 <strtol+0x57>
		s += 2, base = 16;
  800439:	83 c2 02             	add    $0x2,%edx
  80043c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800441:	eb 12                	jmp    800455 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800443:	85 db                	test   %ebx,%ebx
  800445:	75 0e                	jne    800455 <strtol+0x69>
  800447:	3c 30                	cmp    $0x30,%al
  800449:	75 05                	jne    800450 <strtol+0x64>
		s++, base = 8;
  80044b:	42                   	inc    %edx
  80044c:	b3 08                	mov    $0x8,%bl
  80044e:	eb 05                	jmp    800455 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800450:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800455:	b8 00 00 00 00       	mov    $0x0,%eax
  80045a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80045c:	8a 0a                	mov    (%edx),%cl
  80045e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800461:	80 fb 09             	cmp    $0x9,%bl
  800464:	77 08                	ja     80046e <strtol+0x82>
			dig = *s - '0';
  800466:	0f be c9             	movsbl %cl,%ecx
  800469:	83 e9 30             	sub    $0x30,%ecx
  80046c:	eb 1e                	jmp    80048c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  80046e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800471:	80 fb 19             	cmp    $0x19,%bl
  800474:	77 08                	ja     80047e <strtol+0x92>
			dig = *s - 'a' + 10;
  800476:	0f be c9             	movsbl %cl,%ecx
  800479:	83 e9 57             	sub    $0x57,%ecx
  80047c:	eb 0e                	jmp    80048c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  80047e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800481:	80 fb 19             	cmp    $0x19,%bl
  800484:	77 12                	ja     800498 <strtol+0xac>
			dig = *s - 'A' + 10;
  800486:	0f be c9             	movsbl %cl,%ecx
  800489:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  80048c:	39 f1                	cmp    %esi,%ecx
  80048e:	7d 0c                	jge    80049c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800490:	42                   	inc    %edx
  800491:	0f af c6             	imul   %esi,%eax
  800494:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800496:	eb c4                	jmp    80045c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800498:	89 c1                	mov    %eax,%ecx
  80049a:	eb 02                	jmp    80049e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  80049c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  80049e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8004a2:	74 05                	je     8004a9 <strtol+0xbd>
		*endptr = (char *) s;
  8004a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004a7:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8004a9:	85 ff                	test   %edi,%edi
  8004ab:	74 04                	je     8004b1 <strtol+0xc5>
  8004ad:	89 c8                	mov    %ecx,%eax
  8004af:	f7 d8                	neg    %eax
}
  8004b1:	5b                   	pop    %ebx
  8004b2:	5e                   	pop    %esi
  8004b3:	5f                   	pop    %edi
  8004b4:	5d                   	pop    %ebp
  8004b5:	c3                   	ret    
	...

008004b8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8004b8:	55                   	push   %ebp
  8004b9:	89 e5                	mov    %esp,%ebp
  8004bb:	57                   	push   %edi
  8004bc:	56                   	push   %esi
  8004bd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004be:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8004c9:	89 c3                	mov    %eax,%ebx
  8004cb:	89 c7                	mov    %eax,%edi
  8004cd:	89 c6                	mov    %eax,%esi
  8004cf:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8004d1:	5b                   	pop    %ebx
  8004d2:	5e                   	pop    %esi
  8004d3:	5f                   	pop    %edi
  8004d4:	5d                   	pop    %ebp
  8004d5:	c3                   	ret    

008004d6 <sys_cgetc>:

int
sys_cgetc(void)
{
  8004d6:	55                   	push   %ebp
  8004d7:	89 e5                	mov    %esp,%ebp
  8004d9:	57                   	push   %edi
  8004da:	56                   	push   %esi
  8004db:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8004e6:	89 d1                	mov    %edx,%ecx
  8004e8:	89 d3                	mov    %edx,%ebx
  8004ea:	89 d7                	mov    %edx,%edi
  8004ec:	89 d6                	mov    %edx,%esi
  8004ee:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8004f0:	5b                   	pop    %ebx
  8004f1:	5e                   	pop    %esi
  8004f2:	5f                   	pop    %edi
  8004f3:	5d                   	pop    %ebp
  8004f4:	c3                   	ret    

008004f5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8004f5:	55                   	push   %ebp
  8004f6:	89 e5                	mov    %esp,%ebp
  8004f8:	57                   	push   %edi
  8004f9:	56                   	push   %esi
  8004fa:	53                   	push   %ebx
  8004fb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800503:	b8 03 00 00 00       	mov    $0x3,%eax
  800508:	8b 55 08             	mov    0x8(%ebp),%edx
  80050b:	89 cb                	mov    %ecx,%ebx
  80050d:	89 cf                	mov    %ecx,%edi
  80050f:	89 ce                	mov    %ecx,%esi
  800511:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800513:	85 c0                	test   %eax,%eax
  800515:	7e 28                	jle    80053f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800517:	89 44 24 10          	mov    %eax,0x10(%esp)
  80051b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800522:	00 
  800523:	c7 44 24 08 cf 1f 80 	movl   $0x801fcf,0x8(%esp)
  80052a:	00 
  80052b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800532:	00 
  800533:	c7 04 24 ec 1f 80 00 	movl   $0x801fec,(%esp)
  80053a:	e8 59 10 00 00       	call   801598 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80053f:	83 c4 2c             	add    $0x2c,%esp
  800542:	5b                   	pop    %ebx
  800543:	5e                   	pop    %esi
  800544:	5f                   	pop    %edi
  800545:	5d                   	pop    %ebp
  800546:	c3                   	ret    

00800547 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800547:	55                   	push   %ebp
  800548:	89 e5                	mov    %esp,%ebp
  80054a:	57                   	push   %edi
  80054b:	56                   	push   %esi
  80054c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80054d:	ba 00 00 00 00       	mov    $0x0,%edx
  800552:	b8 02 00 00 00       	mov    $0x2,%eax
  800557:	89 d1                	mov    %edx,%ecx
  800559:	89 d3                	mov    %edx,%ebx
  80055b:	89 d7                	mov    %edx,%edi
  80055d:	89 d6                	mov    %edx,%esi
  80055f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800561:	5b                   	pop    %ebx
  800562:	5e                   	pop    %esi
  800563:	5f                   	pop    %edi
  800564:	5d                   	pop    %ebp
  800565:	c3                   	ret    

00800566 <sys_yield>:

void
sys_yield(void)
{
  800566:	55                   	push   %ebp
  800567:	89 e5                	mov    %esp,%ebp
  800569:	57                   	push   %edi
  80056a:	56                   	push   %esi
  80056b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80056c:	ba 00 00 00 00       	mov    $0x0,%edx
  800571:	b8 0b 00 00 00       	mov    $0xb,%eax
  800576:	89 d1                	mov    %edx,%ecx
  800578:	89 d3                	mov    %edx,%ebx
  80057a:	89 d7                	mov    %edx,%edi
  80057c:	89 d6                	mov    %edx,%esi
  80057e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800580:	5b                   	pop    %ebx
  800581:	5e                   	pop    %esi
  800582:	5f                   	pop    %edi
  800583:	5d                   	pop    %ebp
  800584:	c3                   	ret    

00800585 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800585:	55                   	push   %ebp
  800586:	89 e5                	mov    %esp,%ebp
  800588:	57                   	push   %edi
  800589:	56                   	push   %esi
  80058a:	53                   	push   %ebx
  80058b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80058e:	be 00 00 00 00       	mov    $0x0,%esi
  800593:	b8 04 00 00 00       	mov    $0x4,%eax
  800598:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80059b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80059e:	8b 55 08             	mov    0x8(%ebp),%edx
  8005a1:	89 f7                	mov    %esi,%edi
  8005a3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8005a5:	85 c0                	test   %eax,%eax
  8005a7:	7e 28                	jle    8005d1 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8005a9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8005ad:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8005b4:	00 
  8005b5:	c7 44 24 08 cf 1f 80 	movl   $0x801fcf,0x8(%esp)
  8005bc:	00 
  8005bd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8005c4:	00 
  8005c5:	c7 04 24 ec 1f 80 00 	movl   $0x801fec,(%esp)
  8005cc:	e8 c7 0f 00 00       	call   801598 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8005d1:	83 c4 2c             	add    $0x2c,%esp
  8005d4:	5b                   	pop    %ebx
  8005d5:	5e                   	pop    %esi
  8005d6:	5f                   	pop    %edi
  8005d7:	5d                   	pop    %ebp
  8005d8:	c3                   	ret    

008005d9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8005d9:	55                   	push   %ebp
  8005da:	89 e5                	mov    %esp,%ebp
  8005dc:	57                   	push   %edi
  8005dd:	56                   	push   %esi
  8005de:	53                   	push   %ebx
  8005df:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8005e2:	b8 05 00 00 00       	mov    $0x5,%eax
  8005e7:	8b 75 18             	mov    0x18(%ebp),%esi
  8005ea:	8b 7d 14             	mov    0x14(%ebp),%edi
  8005ed:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8005f6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8005f8:	85 c0                	test   %eax,%eax
  8005fa:	7e 28                	jle    800624 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8005fc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800600:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800607:	00 
  800608:	c7 44 24 08 cf 1f 80 	movl   $0x801fcf,0x8(%esp)
  80060f:	00 
  800610:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800617:	00 
  800618:	c7 04 24 ec 1f 80 00 	movl   $0x801fec,(%esp)
  80061f:	e8 74 0f 00 00       	call   801598 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800624:	83 c4 2c             	add    $0x2c,%esp
  800627:	5b                   	pop    %ebx
  800628:	5e                   	pop    %esi
  800629:	5f                   	pop    %edi
  80062a:	5d                   	pop    %ebp
  80062b:	c3                   	ret    

0080062c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80062c:	55                   	push   %ebp
  80062d:	89 e5                	mov    %esp,%ebp
  80062f:	57                   	push   %edi
  800630:	56                   	push   %esi
  800631:	53                   	push   %ebx
  800632:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800635:	bb 00 00 00 00       	mov    $0x0,%ebx
  80063a:	b8 06 00 00 00       	mov    $0x6,%eax
  80063f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800642:	8b 55 08             	mov    0x8(%ebp),%edx
  800645:	89 df                	mov    %ebx,%edi
  800647:	89 de                	mov    %ebx,%esi
  800649:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80064b:	85 c0                	test   %eax,%eax
  80064d:	7e 28                	jle    800677 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80064f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800653:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80065a:	00 
  80065b:	c7 44 24 08 cf 1f 80 	movl   $0x801fcf,0x8(%esp)
  800662:	00 
  800663:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80066a:	00 
  80066b:	c7 04 24 ec 1f 80 00 	movl   $0x801fec,(%esp)
  800672:	e8 21 0f 00 00       	call   801598 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800677:	83 c4 2c             	add    $0x2c,%esp
  80067a:	5b                   	pop    %ebx
  80067b:	5e                   	pop    %esi
  80067c:	5f                   	pop    %edi
  80067d:	5d                   	pop    %ebp
  80067e:	c3                   	ret    

0080067f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80067f:	55                   	push   %ebp
  800680:	89 e5                	mov    %esp,%ebp
  800682:	57                   	push   %edi
  800683:	56                   	push   %esi
  800684:	53                   	push   %ebx
  800685:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800688:	bb 00 00 00 00       	mov    $0x0,%ebx
  80068d:	b8 08 00 00 00       	mov    $0x8,%eax
  800692:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800695:	8b 55 08             	mov    0x8(%ebp),%edx
  800698:	89 df                	mov    %ebx,%edi
  80069a:	89 de                	mov    %ebx,%esi
  80069c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80069e:	85 c0                	test   %eax,%eax
  8006a0:	7e 28                	jle    8006ca <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006a2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006a6:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8006ad:	00 
  8006ae:	c7 44 24 08 cf 1f 80 	movl   $0x801fcf,0x8(%esp)
  8006b5:	00 
  8006b6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8006bd:	00 
  8006be:	c7 04 24 ec 1f 80 00 	movl   $0x801fec,(%esp)
  8006c5:	e8 ce 0e 00 00       	call   801598 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8006ca:	83 c4 2c             	add    $0x2c,%esp
  8006cd:	5b                   	pop    %ebx
  8006ce:	5e                   	pop    %esi
  8006cf:	5f                   	pop    %edi
  8006d0:	5d                   	pop    %ebp
  8006d1:	c3                   	ret    

008006d2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8006d2:	55                   	push   %ebp
  8006d3:	89 e5                	mov    %esp,%ebp
  8006d5:	57                   	push   %edi
  8006d6:	56                   	push   %esi
  8006d7:	53                   	push   %ebx
  8006d8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8006db:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006e0:	b8 09 00 00 00       	mov    $0x9,%eax
  8006e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8006eb:	89 df                	mov    %ebx,%edi
  8006ed:	89 de                	mov    %ebx,%esi
  8006ef:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8006f1:	85 c0                	test   %eax,%eax
  8006f3:	7e 28                	jle    80071d <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006f5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006f9:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800700:	00 
  800701:	c7 44 24 08 cf 1f 80 	movl   $0x801fcf,0x8(%esp)
  800708:	00 
  800709:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800710:	00 
  800711:	c7 04 24 ec 1f 80 00 	movl   $0x801fec,(%esp)
  800718:	e8 7b 0e 00 00       	call   801598 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80071d:	83 c4 2c             	add    $0x2c,%esp
  800720:	5b                   	pop    %ebx
  800721:	5e                   	pop    %esi
  800722:	5f                   	pop    %edi
  800723:	5d                   	pop    %ebp
  800724:	c3                   	ret    

00800725 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800725:	55                   	push   %ebp
  800726:	89 e5                	mov    %esp,%ebp
  800728:	57                   	push   %edi
  800729:	56                   	push   %esi
  80072a:	53                   	push   %ebx
  80072b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80072e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800733:	b8 0a 00 00 00       	mov    $0xa,%eax
  800738:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80073b:	8b 55 08             	mov    0x8(%ebp),%edx
  80073e:	89 df                	mov    %ebx,%edi
  800740:	89 de                	mov    %ebx,%esi
  800742:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800744:	85 c0                	test   %eax,%eax
  800746:	7e 28                	jle    800770 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800748:	89 44 24 10          	mov    %eax,0x10(%esp)
  80074c:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800753:	00 
  800754:	c7 44 24 08 cf 1f 80 	movl   $0x801fcf,0x8(%esp)
  80075b:	00 
  80075c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800763:	00 
  800764:	c7 04 24 ec 1f 80 00 	movl   $0x801fec,(%esp)
  80076b:	e8 28 0e 00 00       	call   801598 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800770:	83 c4 2c             	add    $0x2c,%esp
  800773:	5b                   	pop    %ebx
  800774:	5e                   	pop    %esi
  800775:	5f                   	pop    %edi
  800776:	5d                   	pop    %ebp
  800777:	c3                   	ret    

00800778 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
  80077b:	57                   	push   %edi
  80077c:	56                   	push   %esi
  80077d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80077e:	be 00 00 00 00       	mov    $0x0,%esi
  800783:	b8 0c 00 00 00       	mov    $0xc,%eax
  800788:	8b 7d 14             	mov    0x14(%ebp),%edi
  80078b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80078e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800791:	8b 55 08             	mov    0x8(%ebp),%edx
  800794:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800796:	5b                   	pop    %ebx
  800797:	5e                   	pop    %esi
  800798:	5f                   	pop    %edi
  800799:	5d                   	pop    %ebp
  80079a:	c3                   	ret    

0080079b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80079b:	55                   	push   %ebp
  80079c:	89 e5                	mov    %esp,%ebp
  80079e:	57                   	push   %edi
  80079f:	56                   	push   %esi
  8007a0:	53                   	push   %ebx
  8007a1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8007a4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007a9:	b8 0d 00 00 00       	mov    $0xd,%eax
  8007ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8007b1:	89 cb                	mov    %ecx,%ebx
  8007b3:	89 cf                	mov    %ecx,%edi
  8007b5:	89 ce                	mov    %ecx,%esi
  8007b7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8007b9:	85 c0                	test   %eax,%eax
  8007bb:	7e 28                	jle    8007e5 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8007bd:	89 44 24 10          	mov    %eax,0x10(%esp)
  8007c1:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8007c8:	00 
  8007c9:	c7 44 24 08 cf 1f 80 	movl   $0x801fcf,0x8(%esp)
  8007d0:	00 
  8007d1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8007d8:	00 
  8007d9:	c7 04 24 ec 1f 80 00 	movl   $0x801fec,(%esp)
  8007e0:	e8 b3 0d 00 00       	call   801598 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8007e5:	83 c4 2c             	add    $0x2c,%esp
  8007e8:	5b                   	pop    %ebx
  8007e9:	5e                   	pop    %esi
  8007ea:	5f                   	pop    %edi
  8007eb:	5d                   	pop    %ebp
  8007ec:	c3                   	ret    
  8007ed:	00 00                	add    %al,(%eax)
	...

008007f0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8007f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f6:	05 00 00 00 30       	add    $0x30000000,%eax
  8007fb:	c1 e8 0c             	shr    $0xc,%eax
}
  8007fe:	5d                   	pop    %ebp
  8007ff:	c3                   	ret    

00800800 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800806:	8b 45 08             	mov    0x8(%ebp),%eax
  800809:	89 04 24             	mov    %eax,(%esp)
  80080c:	e8 df ff ff ff       	call   8007f0 <fd2num>
  800811:	05 20 00 0d 00       	add    $0xd0020,%eax
  800816:	c1 e0 0c             	shl    $0xc,%eax
}
  800819:	c9                   	leave  
  80081a:	c3                   	ret    

0080081b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	53                   	push   %ebx
  80081f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800822:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800827:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800829:	89 c2                	mov    %eax,%edx
  80082b:	c1 ea 16             	shr    $0x16,%edx
  80082e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800835:	f6 c2 01             	test   $0x1,%dl
  800838:	74 11                	je     80084b <fd_alloc+0x30>
  80083a:	89 c2                	mov    %eax,%edx
  80083c:	c1 ea 0c             	shr    $0xc,%edx
  80083f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800846:	f6 c2 01             	test   $0x1,%dl
  800849:	75 09                	jne    800854 <fd_alloc+0x39>
			*fd_store = fd;
  80084b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80084d:	b8 00 00 00 00       	mov    $0x0,%eax
  800852:	eb 17                	jmp    80086b <fd_alloc+0x50>
  800854:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800859:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80085e:	75 c7                	jne    800827 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800860:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800866:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80086b:	5b                   	pop    %ebx
  80086c:	5d                   	pop    %ebp
  80086d:	c3                   	ret    

0080086e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80086e:	55                   	push   %ebp
  80086f:	89 e5                	mov    %esp,%ebp
  800871:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800874:	83 f8 1f             	cmp    $0x1f,%eax
  800877:	77 36                	ja     8008af <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800879:	05 00 00 0d 00       	add    $0xd0000,%eax
  80087e:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800881:	89 c2                	mov    %eax,%edx
  800883:	c1 ea 16             	shr    $0x16,%edx
  800886:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80088d:	f6 c2 01             	test   $0x1,%dl
  800890:	74 24                	je     8008b6 <fd_lookup+0x48>
  800892:	89 c2                	mov    %eax,%edx
  800894:	c1 ea 0c             	shr    $0xc,%edx
  800897:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80089e:	f6 c2 01             	test   $0x1,%dl
  8008a1:	74 1a                	je     8008bd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8008a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a6:	89 02                	mov    %eax,(%edx)
	return 0;
  8008a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ad:	eb 13                	jmp    8008c2 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8008af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008b4:	eb 0c                	jmp    8008c2 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8008b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008bb:	eb 05                	jmp    8008c2 <fd_lookup+0x54>
  8008bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8008c2:	5d                   	pop    %ebp
  8008c3:	c3                   	ret    

008008c4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8008c4:	55                   	push   %ebp
  8008c5:	89 e5                	mov    %esp,%ebp
  8008c7:	53                   	push   %ebx
  8008c8:	83 ec 14             	sub    $0x14,%esp
  8008cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8008d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8008d6:	eb 0e                	jmp    8008e6 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8008d8:	39 08                	cmp    %ecx,(%eax)
  8008da:	75 09                	jne    8008e5 <dev_lookup+0x21>
			*dev = devtab[i];
  8008dc:	89 03                	mov    %eax,(%ebx)
			return 0;
  8008de:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e3:	eb 33                	jmp    800918 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8008e5:	42                   	inc    %edx
  8008e6:	8b 04 95 78 20 80 00 	mov    0x802078(,%edx,4),%eax
  8008ed:	85 c0                	test   %eax,%eax
  8008ef:	75 e7                	jne    8008d8 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8008f1:	a1 04 40 80 00       	mov    0x804004,%eax
  8008f6:	8b 40 48             	mov    0x48(%eax),%eax
  8008f9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8008fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800901:	c7 04 24 fc 1f 80 00 	movl   $0x801ffc,(%esp)
  800908:	e8 83 0d 00 00       	call   801690 <cprintf>
	*dev = 0;
  80090d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800913:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800918:	83 c4 14             	add    $0x14,%esp
  80091b:	5b                   	pop    %ebx
  80091c:	5d                   	pop    %ebp
  80091d:	c3                   	ret    

0080091e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	56                   	push   %esi
  800922:	53                   	push   %ebx
  800923:	83 ec 30             	sub    $0x30,%esp
  800926:	8b 75 08             	mov    0x8(%ebp),%esi
  800929:	8a 45 0c             	mov    0xc(%ebp),%al
  80092c:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80092f:	89 34 24             	mov    %esi,(%esp)
  800932:	e8 b9 fe ff ff       	call   8007f0 <fd2num>
  800937:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80093a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80093e:	89 04 24             	mov    %eax,(%esp)
  800941:	e8 28 ff ff ff       	call   80086e <fd_lookup>
  800946:	89 c3                	mov    %eax,%ebx
  800948:	85 c0                	test   %eax,%eax
  80094a:	78 05                	js     800951 <fd_close+0x33>
	    || fd != fd2)
  80094c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80094f:	74 0d                	je     80095e <fd_close+0x40>
		return (must_exist ? r : 0);
  800951:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800955:	75 46                	jne    80099d <fd_close+0x7f>
  800957:	bb 00 00 00 00       	mov    $0x0,%ebx
  80095c:	eb 3f                	jmp    80099d <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80095e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800961:	89 44 24 04          	mov    %eax,0x4(%esp)
  800965:	8b 06                	mov    (%esi),%eax
  800967:	89 04 24             	mov    %eax,(%esp)
  80096a:	e8 55 ff ff ff       	call   8008c4 <dev_lookup>
  80096f:	89 c3                	mov    %eax,%ebx
  800971:	85 c0                	test   %eax,%eax
  800973:	78 18                	js     80098d <fd_close+0x6f>
		if (dev->dev_close)
  800975:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800978:	8b 40 10             	mov    0x10(%eax),%eax
  80097b:	85 c0                	test   %eax,%eax
  80097d:	74 09                	je     800988 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80097f:	89 34 24             	mov    %esi,(%esp)
  800982:	ff d0                	call   *%eax
  800984:	89 c3                	mov    %eax,%ebx
  800986:	eb 05                	jmp    80098d <fd_close+0x6f>
		else
			r = 0;
  800988:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80098d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800991:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800998:	e8 8f fc ff ff       	call   80062c <sys_page_unmap>
	return r;
}
  80099d:	89 d8                	mov    %ebx,%eax
  80099f:	83 c4 30             	add    $0x30,%esp
  8009a2:	5b                   	pop    %ebx
  8009a3:	5e                   	pop    %esi
  8009a4:	5d                   	pop    %ebp
  8009a5:	c3                   	ret    

008009a6 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
  8009a9:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8009ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b6:	89 04 24             	mov    %eax,(%esp)
  8009b9:	e8 b0 fe ff ff       	call   80086e <fd_lookup>
  8009be:	85 c0                	test   %eax,%eax
  8009c0:	78 13                	js     8009d5 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8009c2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8009c9:	00 
  8009ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009cd:	89 04 24             	mov    %eax,(%esp)
  8009d0:	e8 49 ff ff ff       	call   80091e <fd_close>
}
  8009d5:	c9                   	leave  
  8009d6:	c3                   	ret    

008009d7 <close_all>:

void
close_all(void)
{
  8009d7:	55                   	push   %ebp
  8009d8:	89 e5                	mov    %esp,%ebp
  8009da:	53                   	push   %ebx
  8009db:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8009de:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8009e3:	89 1c 24             	mov    %ebx,(%esp)
  8009e6:	e8 bb ff ff ff       	call   8009a6 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8009eb:	43                   	inc    %ebx
  8009ec:	83 fb 20             	cmp    $0x20,%ebx
  8009ef:	75 f2                	jne    8009e3 <close_all+0xc>
		close(i);
}
  8009f1:	83 c4 14             	add    $0x14,%esp
  8009f4:	5b                   	pop    %ebx
  8009f5:	5d                   	pop    %ebp
  8009f6:	c3                   	ret    

008009f7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	57                   	push   %edi
  8009fb:	56                   	push   %esi
  8009fc:	53                   	push   %ebx
  8009fd:	83 ec 4c             	sub    $0x4c,%esp
  800a00:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800a03:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800a06:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0d:	89 04 24             	mov    %eax,(%esp)
  800a10:	e8 59 fe ff ff       	call   80086e <fd_lookup>
  800a15:	89 c3                	mov    %eax,%ebx
  800a17:	85 c0                	test   %eax,%eax
  800a19:	0f 88 e1 00 00 00    	js     800b00 <dup+0x109>
		return r;
	close(newfdnum);
  800a1f:	89 3c 24             	mov    %edi,(%esp)
  800a22:	e8 7f ff ff ff       	call   8009a6 <close>

	newfd = INDEX2FD(newfdnum);
  800a27:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800a2d:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800a30:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a33:	89 04 24             	mov    %eax,(%esp)
  800a36:	e8 c5 fd ff ff       	call   800800 <fd2data>
  800a3b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800a3d:	89 34 24             	mov    %esi,(%esp)
  800a40:	e8 bb fd ff ff       	call   800800 <fd2data>
  800a45:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800a48:	89 d8                	mov    %ebx,%eax
  800a4a:	c1 e8 16             	shr    $0x16,%eax
  800a4d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800a54:	a8 01                	test   $0x1,%al
  800a56:	74 46                	je     800a9e <dup+0xa7>
  800a58:	89 d8                	mov    %ebx,%eax
  800a5a:	c1 e8 0c             	shr    $0xc,%eax
  800a5d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800a64:	f6 c2 01             	test   $0x1,%dl
  800a67:	74 35                	je     800a9e <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800a69:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800a70:	25 07 0e 00 00       	and    $0xe07,%eax
  800a75:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a79:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800a7c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a80:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a87:	00 
  800a88:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a8c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a93:	e8 41 fb ff ff       	call   8005d9 <sys_page_map>
  800a98:	89 c3                	mov    %eax,%ebx
  800a9a:	85 c0                	test   %eax,%eax
  800a9c:	78 3b                	js     800ad9 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800a9e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800aa1:	89 c2                	mov    %eax,%edx
  800aa3:	c1 ea 0c             	shr    $0xc,%edx
  800aa6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800aad:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800ab3:	89 54 24 10          	mov    %edx,0x10(%esp)
  800ab7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800abb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ac2:	00 
  800ac3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ac7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ace:	e8 06 fb ff ff       	call   8005d9 <sys_page_map>
  800ad3:	89 c3                	mov    %eax,%ebx
  800ad5:	85 c0                	test   %eax,%eax
  800ad7:	79 25                	jns    800afe <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800ad9:	89 74 24 04          	mov    %esi,0x4(%esp)
  800add:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ae4:	e8 43 fb ff ff       	call   80062c <sys_page_unmap>
	sys_page_unmap(0, nva);
  800ae9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800aec:	89 44 24 04          	mov    %eax,0x4(%esp)
  800af0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800af7:	e8 30 fb ff ff       	call   80062c <sys_page_unmap>
	return r;
  800afc:	eb 02                	jmp    800b00 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  800afe:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800b00:	89 d8                	mov    %ebx,%eax
  800b02:	83 c4 4c             	add    $0x4c,%esp
  800b05:	5b                   	pop    %ebx
  800b06:	5e                   	pop    %esi
  800b07:	5f                   	pop    %edi
  800b08:	5d                   	pop    %ebp
  800b09:	c3                   	ret    

00800b0a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
  800b0d:	53                   	push   %ebx
  800b0e:	83 ec 24             	sub    $0x24,%esp
  800b11:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b14:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b17:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b1b:	89 1c 24             	mov    %ebx,(%esp)
  800b1e:	e8 4b fd ff ff       	call   80086e <fd_lookup>
  800b23:	85 c0                	test   %eax,%eax
  800b25:	78 6d                	js     800b94 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b27:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b2a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b31:	8b 00                	mov    (%eax),%eax
  800b33:	89 04 24             	mov    %eax,(%esp)
  800b36:	e8 89 fd ff ff       	call   8008c4 <dev_lookup>
  800b3b:	85 c0                	test   %eax,%eax
  800b3d:	78 55                	js     800b94 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800b3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b42:	8b 50 08             	mov    0x8(%eax),%edx
  800b45:	83 e2 03             	and    $0x3,%edx
  800b48:	83 fa 01             	cmp    $0x1,%edx
  800b4b:	75 23                	jne    800b70 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800b4d:	a1 04 40 80 00       	mov    0x804004,%eax
  800b52:	8b 40 48             	mov    0x48(%eax),%eax
  800b55:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800b59:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b5d:	c7 04 24 3d 20 80 00 	movl   $0x80203d,(%esp)
  800b64:	e8 27 0b 00 00       	call   801690 <cprintf>
		return -E_INVAL;
  800b69:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b6e:	eb 24                	jmp    800b94 <read+0x8a>
	}
	if (!dev->dev_read)
  800b70:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b73:	8b 52 08             	mov    0x8(%edx),%edx
  800b76:	85 d2                	test   %edx,%edx
  800b78:	74 15                	je     800b8f <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800b7a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b7d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800b81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b84:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800b88:	89 04 24             	mov    %eax,(%esp)
  800b8b:	ff d2                	call   *%edx
  800b8d:	eb 05                	jmp    800b94 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800b8f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  800b94:	83 c4 24             	add    $0x24,%esp
  800b97:	5b                   	pop    %ebx
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    

00800b9a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	57                   	push   %edi
  800b9e:	56                   	push   %esi
  800b9f:	53                   	push   %ebx
  800ba0:	83 ec 1c             	sub    $0x1c,%esp
  800ba3:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ba6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800ba9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bae:	eb 23                	jmp    800bd3 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800bb0:	89 f0                	mov    %esi,%eax
  800bb2:	29 d8                	sub    %ebx,%eax
  800bb4:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bb8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bbb:	01 d8                	add    %ebx,%eax
  800bbd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bc1:	89 3c 24             	mov    %edi,(%esp)
  800bc4:	e8 41 ff ff ff       	call   800b0a <read>
		if (m < 0)
  800bc9:	85 c0                	test   %eax,%eax
  800bcb:	78 10                	js     800bdd <readn+0x43>
			return m;
		if (m == 0)
  800bcd:	85 c0                	test   %eax,%eax
  800bcf:	74 0a                	je     800bdb <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800bd1:	01 c3                	add    %eax,%ebx
  800bd3:	39 f3                	cmp    %esi,%ebx
  800bd5:	72 d9                	jb     800bb0 <readn+0x16>
  800bd7:	89 d8                	mov    %ebx,%eax
  800bd9:	eb 02                	jmp    800bdd <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  800bdb:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  800bdd:	83 c4 1c             	add    $0x1c,%esp
  800be0:	5b                   	pop    %ebx
  800be1:	5e                   	pop    %esi
  800be2:	5f                   	pop    %edi
  800be3:	5d                   	pop    %ebp
  800be4:	c3                   	ret    

00800be5 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800be5:	55                   	push   %ebp
  800be6:	89 e5                	mov    %esp,%ebp
  800be8:	53                   	push   %ebx
  800be9:	83 ec 24             	sub    $0x24,%esp
  800bec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800bef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800bf2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bf6:	89 1c 24             	mov    %ebx,(%esp)
  800bf9:	e8 70 fc ff ff       	call   80086e <fd_lookup>
  800bfe:	85 c0                	test   %eax,%eax
  800c00:	78 68                	js     800c6a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c02:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c05:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c09:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c0c:	8b 00                	mov    (%eax),%eax
  800c0e:	89 04 24             	mov    %eax,(%esp)
  800c11:	e8 ae fc ff ff       	call   8008c4 <dev_lookup>
  800c16:	85 c0                	test   %eax,%eax
  800c18:	78 50                	js     800c6a <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800c1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c1d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800c21:	75 23                	jne    800c46 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800c23:	a1 04 40 80 00       	mov    0x804004,%eax
  800c28:	8b 40 48             	mov    0x48(%eax),%eax
  800c2b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800c2f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c33:	c7 04 24 59 20 80 00 	movl   $0x802059,(%esp)
  800c3a:	e8 51 0a 00 00       	call   801690 <cprintf>
		return -E_INVAL;
  800c3f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c44:	eb 24                	jmp    800c6a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800c46:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c49:	8b 52 0c             	mov    0xc(%edx),%edx
  800c4c:	85 d2                	test   %edx,%edx
  800c4e:	74 15                	je     800c65 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800c50:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c53:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800c57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800c5e:	89 04 24             	mov    %eax,(%esp)
  800c61:	ff d2                	call   *%edx
  800c63:	eb 05                	jmp    800c6a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800c65:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  800c6a:	83 c4 24             	add    $0x24,%esp
  800c6d:	5b                   	pop    %ebx
  800c6e:	5d                   	pop    %ebp
  800c6f:	c3                   	ret    

00800c70 <seek>:

int
seek(int fdnum, off_t offset)
{
  800c70:	55                   	push   %ebp
  800c71:	89 e5                	mov    %esp,%ebp
  800c73:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800c76:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800c79:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c80:	89 04 24             	mov    %eax,(%esp)
  800c83:	e8 e6 fb ff ff       	call   80086e <fd_lookup>
  800c88:	85 c0                	test   %eax,%eax
  800c8a:	78 0e                	js     800c9a <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  800c8c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c8f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c92:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800c95:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c9a:	c9                   	leave  
  800c9b:	c3                   	ret    

00800c9c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800c9c:	55                   	push   %ebp
  800c9d:	89 e5                	mov    %esp,%ebp
  800c9f:	53                   	push   %ebx
  800ca0:	83 ec 24             	sub    $0x24,%esp
  800ca3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800ca6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ca9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cad:	89 1c 24             	mov    %ebx,(%esp)
  800cb0:	e8 b9 fb ff ff       	call   80086e <fd_lookup>
  800cb5:	85 c0                	test   %eax,%eax
  800cb7:	78 61                	js     800d1a <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800cb9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800cbc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cc3:	8b 00                	mov    (%eax),%eax
  800cc5:	89 04 24             	mov    %eax,(%esp)
  800cc8:	e8 f7 fb ff ff       	call   8008c4 <dev_lookup>
  800ccd:	85 c0                	test   %eax,%eax
  800ccf:	78 49                	js     800d1a <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800cd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cd4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800cd8:	75 23                	jne    800cfd <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800cda:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800cdf:	8b 40 48             	mov    0x48(%eax),%eax
  800ce2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ce6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cea:	c7 04 24 1c 20 80 00 	movl   $0x80201c,(%esp)
  800cf1:	e8 9a 09 00 00       	call   801690 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800cf6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800cfb:	eb 1d                	jmp    800d1a <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  800cfd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d00:	8b 52 18             	mov    0x18(%edx),%edx
  800d03:	85 d2                	test   %edx,%edx
  800d05:	74 0e                	je     800d15 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800d07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800d0e:	89 04 24             	mov    %eax,(%esp)
  800d11:	ff d2                	call   *%edx
  800d13:	eb 05                	jmp    800d1a <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800d15:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800d1a:	83 c4 24             	add    $0x24,%esp
  800d1d:	5b                   	pop    %ebx
  800d1e:	5d                   	pop    %ebp
  800d1f:	c3                   	ret    

00800d20 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800d20:	55                   	push   %ebp
  800d21:	89 e5                	mov    %esp,%ebp
  800d23:	53                   	push   %ebx
  800d24:	83 ec 24             	sub    $0x24,%esp
  800d27:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800d2a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d2d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d31:	8b 45 08             	mov    0x8(%ebp),%eax
  800d34:	89 04 24             	mov    %eax,(%esp)
  800d37:	e8 32 fb ff ff       	call   80086e <fd_lookup>
  800d3c:	85 c0                	test   %eax,%eax
  800d3e:	78 52                	js     800d92 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d40:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d43:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d47:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d4a:	8b 00                	mov    (%eax),%eax
  800d4c:	89 04 24             	mov    %eax,(%esp)
  800d4f:	e8 70 fb ff ff       	call   8008c4 <dev_lookup>
  800d54:	85 c0                	test   %eax,%eax
  800d56:	78 3a                	js     800d92 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  800d58:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d5b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800d5f:	74 2c                	je     800d8d <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800d61:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800d64:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800d6b:	00 00 00 
	stat->st_isdir = 0;
  800d6e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800d75:	00 00 00 
	stat->st_dev = dev;
  800d78:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800d7e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d82:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800d85:	89 14 24             	mov    %edx,(%esp)
  800d88:	ff 50 14             	call   *0x14(%eax)
  800d8b:	eb 05                	jmp    800d92 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800d8d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800d92:	83 c4 24             	add    $0x24,%esp
  800d95:	5b                   	pop    %ebx
  800d96:	5d                   	pop    %ebp
  800d97:	c3                   	ret    

00800d98 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800d98:	55                   	push   %ebp
  800d99:	89 e5                	mov    %esp,%ebp
  800d9b:	56                   	push   %esi
  800d9c:	53                   	push   %ebx
  800d9d:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800da0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800da7:	00 
  800da8:	8b 45 08             	mov    0x8(%ebp),%eax
  800dab:	89 04 24             	mov    %eax,(%esp)
  800dae:	e8 2d 02 00 00       	call   800fe0 <open>
  800db3:	89 c3                	mov    %eax,%ebx
  800db5:	85 c0                	test   %eax,%eax
  800db7:	78 1b                	js     800dd4 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  800db9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dbc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dc0:	89 1c 24             	mov    %ebx,(%esp)
  800dc3:	e8 58 ff ff ff       	call   800d20 <fstat>
  800dc8:	89 c6                	mov    %eax,%esi
	close(fd);
  800dca:	89 1c 24             	mov    %ebx,(%esp)
  800dcd:	e8 d4 fb ff ff       	call   8009a6 <close>
	return r;
  800dd2:	89 f3                	mov    %esi,%ebx
}
  800dd4:	89 d8                	mov    %ebx,%eax
  800dd6:	83 c4 10             	add    $0x10,%esp
  800dd9:	5b                   	pop    %ebx
  800dda:	5e                   	pop    %esi
  800ddb:	5d                   	pop    %ebp
  800ddc:	c3                   	ret    
  800ddd:	00 00                	add    %al,(%eax)
	...

00800de0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800de0:	55                   	push   %ebp
  800de1:	89 e5                	mov    %esp,%ebp
  800de3:	56                   	push   %esi
  800de4:	53                   	push   %ebx
  800de5:	83 ec 10             	sub    $0x10,%esp
  800de8:	89 c3                	mov    %eax,%ebx
  800dea:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800dec:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800df3:	75 11                	jne    800e06 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800df5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800dfc:	e8 de 0e 00 00       	call   801cdf <ipc_find_env>
  800e01:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800e06:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800e0d:	00 
  800e0e:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800e15:	00 
  800e16:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e1a:	a1 00 40 80 00       	mov    0x804000,%eax
  800e1f:	89 04 24             	mov    %eax,(%esp)
  800e22:	e8 4a 0e 00 00       	call   801c71 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800e27:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e2e:	00 
  800e2f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e33:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e3a:	e8 c9 0d 00 00       	call   801c08 <ipc_recv>
}
  800e3f:	83 c4 10             	add    $0x10,%esp
  800e42:	5b                   	pop    %ebx
  800e43:	5e                   	pop    %esi
  800e44:	5d                   	pop    %ebp
  800e45:	c3                   	ret    

00800e46 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800e46:	55                   	push   %ebp
  800e47:	89 e5                	mov    %esp,%ebp
  800e49:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800e4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4f:	8b 40 0c             	mov    0xc(%eax),%eax
  800e52:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800e57:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e5a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800e5f:	ba 00 00 00 00       	mov    $0x0,%edx
  800e64:	b8 02 00 00 00       	mov    $0x2,%eax
  800e69:	e8 72 ff ff ff       	call   800de0 <fsipc>
}
  800e6e:	c9                   	leave  
  800e6f:	c3                   	ret    

00800e70 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800e70:	55                   	push   %ebp
  800e71:	89 e5                	mov    %esp,%ebp
  800e73:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800e76:	8b 45 08             	mov    0x8(%ebp),%eax
  800e79:	8b 40 0c             	mov    0xc(%eax),%eax
  800e7c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800e81:	ba 00 00 00 00       	mov    $0x0,%edx
  800e86:	b8 06 00 00 00       	mov    $0x6,%eax
  800e8b:	e8 50 ff ff ff       	call   800de0 <fsipc>
}
  800e90:	c9                   	leave  
  800e91:	c3                   	ret    

00800e92 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800e92:	55                   	push   %ebp
  800e93:	89 e5                	mov    %esp,%ebp
  800e95:	53                   	push   %ebx
  800e96:	83 ec 14             	sub    $0x14,%esp
  800e99:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800e9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9f:	8b 40 0c             	mov    0xc(%eax),%eax
  800ea2:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800ea7:	ba 00 00 00 00       	mov    $0x0,%edx
  800eac:	b8 05 00 00 00       	mov    $0x5,%eax
  800eb1:	e8 2a ff ff ff       	call   800de0 <fsipc>
  800eb6:	85 c0                	test   %eax,%eax
  800eb8:	78 2b                	js     800ee5 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800eba:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800ec1:	00 
  800ec2:	89 1c 24             	mov    %ebx,(%esp)
  800ec5:	e8 c9 f2 ff ff       	call   800193 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800eca:	a1 80 50 80 00       	mov    0x805080,%eax
  800ecf:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800ed5:	a1 84 50 80 00       	mov    0x805084,%eax
  800eda:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800ee0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ee5:	83 c4 14             	add    $0x14,%esp
  800ee8:	5b                   	pop    %ebx
  800ee9:	5d                   	pop    %ebp
  800eea:	c3                   	ret    

00800eeb <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800eeb:	55                   	push   %ebp
  800eec:	89 e5                	mov    %esp,%ebp
  800eee:	83 ec 18             	sub    $0x18,%esp
  800ef1:	8b 55 10             	mov    0x10(%ebp),%edx
  800ef4:	89 d0                	mov    %edx,%eax
  800ef6:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  800efc:	76 05                	jbe    800f03 <devfile_write+0x18>
  800efe:	b8 00 10 00 00       	mov    $0x1000,%eax
	//panic("devfile_write not implemented");
	int r;
	//uint32_t maxsize = BLKSIZE - sizeof(int) - sizeof(size_t);	
	if (n > BLKSIZE)
		n = BLKSIZE;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800f03:	8b 55 08             	mov    0x8(%ebp),%edx
  800f06:	8b 52 0c             	mov    0xc(%edx),%edx
  800f09:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800f0f:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800f14:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f18:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f1b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f1f:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  800f26:	e8 e1 f3 ff ff       	call   80030c <memmove>
	 
	return fsipc(FSREQ_WRITE, NULL);
  800f2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800f30:	b8 04 00 00 00       	mov    $0x4,%eax
  800f35:	e8 a6 fe ff ff       	call   800de0 <fsipc>
}
  800f3a:	c9                   	leave  
  800f3b:	c3                   	ret    

00800f3c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800f3c:	55                   	push   %ebp
  800f3d:	89 e5                	mov    %esp,%ebp
  800f3f:	56                   	push   %esi
  800f40:	53                   	push   %ebx
  800f41:	83 ec 10             	sub    $0x10,%esp
  800f44:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800f47:	8b 45 08             	mov    0x8(%ebp),%eax
  800f4a:	8b 40 0c             	mov    0xc(%eax),%eax
  800f4d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800f52:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800f58:	ba 00 00 00 00       	mov    $0x0,%edx
  800f5d:	b8 03 00 00 00       	mov    $0x3,%eax
  800f62:	e8 79 fe ff ff       	call   800de0 <fsipc>
  800f67:	89 c3                	mov    %eax,%ebx
  800f69:	85 c0                	test   %eax,%eax
  800f6b:	78 6a                	js     800fd7 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  800f6d:	39 c6                	cmp    %eax,%esi
  800f6f:	73 24                	jae    800f95 <devfile_read+0x59>
  800f71:	c7 44 24 0c 88 20 80 	movl   $0x802088,0xc(%esp)
  800f78:	00 
  800f79:	c7 44 24 08 8f 20 80 	movl   $0x80208f,0x8(%esp)
  800f80:	00 
  800f81:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  800f88:	00 
  800f89:	c7 04 24 a4 20 80 00 	movl   $0x8020a4,(%esp)
  800f90:	e8 03 06 00 00       	call   801598 <_panic>
	assert(r <= PGSIZE);
  800f95:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800f9a:	7e 24                	jle    800fc0 <devfile_read+0x84>
  800f9c:	c7 44 24 0c af 20 80 	movl   $0x8020af,0xc(%esp)
  800fa3:	00 
  800fa4:	c7 44 24 08 8f 20 80 	movl   $0x80208f,0x8(%esp)
  800fab:	00 
  800fac:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  800fb3:	00 
  800fb4:	c7 04 24 a4 20 80 00 	movl   $0x8020a4,(%esp)
  800fbb:	e8 d8 05 00 00       	call   801598 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800fc0:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fc4:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800fcb:	00 
  800fcc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fcf:	89 04 24             	mov    %eax,(%esp)
  800fd2:	e8 35 f3 ff ff       	call   80030c <memmove>
	return r;
}
  800fd7:	89 d8                	mov    %ebx,%eax
  800fd9:	83 c4 10             	add    $0x10,%esp
  800fdc:	5b                   	pop    %ebx
  800fdd:	5e                   	pop    %esi
  800fde:	5d                   	pop    %ebp
  800fdf:	c3                   	ret    

00800fe0 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800fe0:	55                   	push   %ebp
  800fe1:	89 e5                	mov    %esp,%ebp
  800fe3:	56                   	push   %esi
  800fe4:	53                   	push   %ebx
  800fe5:	83 ec 20             	sub    $0x20,%esp
  800fe8:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800feb:	89 34 24             	mov    %esi,(%esp)
  800fee:	e8 6d f1 ff ff       	call   800160 <strlen>
  800ff3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ff8:	7f 60                	jg     80105a <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ffa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ffd:	89 04 24             	mov    %eax,(%esp)
  801000:	e8 16 f8 ff ff       	call   80081b <fd_alloc>
  801005:	89 c3                	mov    %eax,%ebx
  801007:	85 c0                	test   %eax,%eax
  801009:	78 54                	js     80105f <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80100b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80100f:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801016:	e8 78 f1 ff ff       	call   800193 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80101b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80101e:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801023:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801026:	b8 01 00 00 00       	mov    $0x1,%eax
  80102b:	e8 b0 fd ff ff       	call   800de0 <fsipc>
  801030:	89 c3                	mov    %eax,%ebx
  801032:	85 c0                	test   %eax,%eax
  801034:	79 15                	jns    80104b <open+0x6b>
		fd_close(fd, 0);
  801036:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80103d:	00 
  80103e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801041:	89 04 24             	mov    %eax,(%esp)
  801044:	e8 d5 f8 ff ff       	call   80091e <fd_close>
		return r;
  801049:	eb 14                	jmp    80105f <open+0x7f>
	}

	return fd2num(fd);
  80104b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80104e:	89 04 24             	mov    %eax,(%esp)
  801051:	e8 9a f7 ff ff       	call   8007f0 <fd2num>
  801056:	89 c3                	mov    %eax,%ebx
  801058:	eb 05                	jmp    80105f <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80105a:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80105f:	89 d8                	mov    %ebx,%eax
  801061:	83 c4 20             	add    $0x20,%esp
  801064:	5b                   	pop    %ebx
  801065:	5e                   	pop    %esi
  801066:	5d                   	pop    %ebp
  801067:	c3                   	ret    

00801068 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801068:	55                   	push   %ebp
  801069:	89 e5                	mov    %esp,%ebp
  80106b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80106e:	ba 00 00 00 00       	mov    $0x0,%edx
  801073:	b8 08 00 00 00       	mov    $0x8,%eax
  801078:	e8 63 fd ff ff       	call   800de0 <fsipc>
}
  80107d:	c9                   	leave  
  80107e:	c3                   	ret    
	...

00801080 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801080:	55                   	push   %ebp
  801081:	89 e5                	mov    %esp,%ebp
  801083:	56                   	push   %esi
  801084:	53                   	push   %ebx
  801085:	83 ec 10             	sub    $0x10,%esp
  801088:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80108b:	8b 45 08             	mov    0x8(%ebp),%eax
  80108e:	89 04 24             	mov    %eax,(%esp)
  801091:	e8 6a f7 ff ff       	call   800800 <fd2data>
  801096:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801098:	c7 44 24 04 bb 20 80 	movl   $0x8020bb,0x4(%esp)
  80109f:	00 
  8010a0:	89 34 24             	mov    %esi,(%esp)
  8010a3:	e8 eb f0 ff ff       	call   800193 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8010a8:	8b 43 04             	mov    0x4(%ebx),%eax
  8010ab:	2b 03                	sub    (%ebx),%eax
  8010ad:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8010b3:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8010ba:	00 00 00 
	stat->st_dev = &devpipe;
  8010bd:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  8010c4:	30 80 00 
	return 0;
}
  8010c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8010cc:	83 c4 10             	add    $0x10,%esp
  8010cf:	5b                   	pop    %ebx
  8010d0:	5e                   	pop    %esi
  8010d1:	5d                   	pop    %ebp
  8010d2:	c3                   	ret    

008010d3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8010d3:	55                   	push   %ebp
  8010d4:	89 e5                	mov    %esp,%ebp
  8010d6:	53                   	push   %ebx
  8010d7:	83 ec 14             	sub    $0x14,%esp
  8010da:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8010dd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8010e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010e8:	e8 3f f5 ff ff       	call   80062c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8010ed:	89 1c 24             	mov    %ebx,(%esp)
  8010f0:	e8 0b f7 ff ff       	call   800800 <fd2data>
  8010f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010f9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801100:	e8 27 f5 ff ff       	call   80062c <sys_page_unmap>
}
  801105:	83 c4 14             	add    $0x14,%esp
  801108:	5b                   	pop    %ebx
  801109:	5d                   	pop    %ebp
  80110a:	c3                   	ret    

0080110b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80110b:	55                   	push   %ebp
  80110c:	89 e5                	mov    %esp,%ebp
  80110e:	57                   	push   %edi
  80110f:	56                   	push   %esi
  801110:	53                   	push   %ebx
  801111:	83 ec 2c             	sub    $0x2c,%esp
  801114:	89 c7                	mov    %eax,%edi
  801116:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801119:	a1 04 40 80 00       	mov    0x804004,%eax
  80111e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801121:	89 3c 24             	mov    %edi,(%esp)
  801124:	e8 fb 0b 00 00       	call   801d24 <pageref>
  801129:	89 c6                	mov    %eax,%esi
  80112b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80112e:	89 04 24             	mov    %eax,(%esp)
  801131:	e8 ee 0b 00 00       	call   801d24 <pageref>
  801136:	39 c6                	cmp    %eax,%esi
  801138:	0f 94 c0             	sete   %al
  80113b:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  80113e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801144:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801147:	39 cb                	cmp    %ecx,%ebx
  801149:	75 08                	jne    801153 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  80114b:	83 c4 2c             	add    $0x2c,%esp
  80114e:	5b                   	pop    %ebx
  80114f:	5e                   	pop    %esi
  801150:	5f                   	pop    %edi
  801151:	5d                   	pop    %ebp
  801152:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801153:	83 f8 01             	cmp    $0x1,%eax
  801156:	75 c1                	jne    801119 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801158:	8b 42 58             	mov    0x58(%edx),%eax
  80115b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801162:	00 
  801163:	89 44 24 08          	mov    %eax,0x8(%esp)
  801167:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80116b:	c7 04 24 c2 20 80 00 	movl   $0x8020c2,(%esp)
  801172:	e8 19 05 00 00       	call   801690 <cprintf>
  801177:	eb a0                	jmp    801119 <_pipeisclosed+0xe>

00801179 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801179:	55                   	push   %ebp
  80117a:	89 e5                	mov    %esp,%ebp
  80117c:	57                   	push   %edi
  80117d:	56                   	push   %esi
  80117e:	53                   	push   %ebx
  80117f:	83 ec 1c             	sub    $0x1c,%esp
  801182:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801185:	89 34 24             	mov    %esi,(%esp)
  801188:	e8 73 f6 ff ff       	call   800800 <fd2data>
  80118d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80118f:	bf 00 00 00 00       	mov    $0x0,%edi
  801194:	eb 3c                	jmp    8011d2 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801196:	89 da                	mov    %ebx,%edx
  801198:	89 f0                	mov    %esi,%eax
  80119a:	e8 6c ff ff ff       	call   80110b <_pipeisclosed>
  80119f:	85 c0                	test   %eax,%eax
  8011a1:	75 38                	jne    8011db <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8011a3:	e8 be f3 ff ff       	call   800566 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8011a8:	8b 43 04             	mov    0x4(%ebx),%eax
  8011ab:	8b 13                	mov    (%ebx),%edx
  8011ad:	83 c2 20             	add    $0x20,%edx
  8011b0:	39 d0                	cmp    %edx,%eax
  8011b2:	73 e2                	jae    801196 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8011b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011b7:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  8011ba:	89 c2                	mov    %eax,%edx
  8011bc:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8011c2:	79 05                	jns    8011c9 <devpipe_write+0x50>
  8011c4:	4a                   	dec    %edx
  8011c5:	83 ca e0             	or     $0xffffffe0,%edx
  8011c8:	42                   	inc    %edx
  8011c9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8011cd:	40                   	inc    %eax
  8011ce:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011d1:	47                   	inc    %edi
  8011d2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8011d5:	75 d1                	jne    8011a8 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8011d7:	89 f8                	mov    %edi,%eax
  8011d9:	eb 05                	jmp    8011e0 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011db:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8011e0:	83 c4 1c             	add    $0x1c,%esp
  8011e3:	5b                   	pop    %ebx
  8011e4:	5e                   	pop    %esi
  8011e5:	5f                   	pop    %edi
  8011e6:	5d                   	pop    %ebp
  8011e7:	c3                   	ret    

008011e8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8011e8:	55                   	push   %ebp
  8011e9:	89 e5                	mov    %esp,%ebp
  8011eb:	57                   	push   %edi
  8011ec:	56                   	push   %esi
  8011ed:	53                   	push   %ebx
  8011ee:	83 ec 1c             	sub    $0x1c,%esp
  8011f1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8011f4:	89 3c 24             	mov    %edi,(%esp)
  8011f7:	e8 04 f6 ff ff       	call   800800 <fd2data>
  8011fc:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011fe:	be 00 00 00 00       	mov    $0x0,%esi
  801203:	eb 3a                	jmp    80123f <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801205:	85 f6                	test   %esi,%esi
  801207:	74 04                	je     80120d <devpipe_read+0x25>
				return i;
  801209:	89 f0                	mov    %esi,%eax
  80120b:	eb 40                	jmp    80124d <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80120d:	89 da                	mov    %ebx,%edx
  80120f:	89 f8                	mov    %edi,%eax
  801211:	e8 f5 fe ff ff       	call   80110b <_pipeisclosed>
  801216:	85 c0                	test   %eax,%eax
  801218:	75 2e                	jne    801248 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80121a:	e8 47 f3 ff ff       	call   800566 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80121f:	8b 03                	mov    (%ebx),%eax
  801221:	3b 43 04             	cmp    0x4(%ebx),%eax
  801224:	74 df                	je     801205 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801226:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80122b:	79 05                	jns    801232 <devpipe_read+0x4a>
  80122d:	48                   	dec    %eax
  80122e:	83 c8 e0             	or     $0xffffffe0,%eax
  801231:	40                   	inc    %eax
  801232:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801236:	8b 55 0c             	mov    0xc(%ebp),%edx
  801239:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  80123c:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80123e:	46                   	inc    %esi
  80123f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801242:	75 db                	jne    80121f <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801244:	89 f0                	mov    %esi,%eax
  801246:	eb 05                	jmp    80124d <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801248:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80124d:	83 c4 1c             	add    $0x1c,%esp
  801250:	5b                   	pop    %ebx
  801251:	5e                   	pop    %esi
  801252:	5f                   	pop    %edi
  801253:	5d                   	pop    %ebp
  801254:	c3                   	ret    

00801255 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801255:	55                   	push   %ebp
  801256:	89 e5                	mov    %esp,%ebp
  801258:	57                   	push   %edi
  801259:	56                   	push   %esi
  80125a:	53                   	push   %ebx
  80125b:	83 ec 3c             	sub    $0x3c,%esp
  80125e:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801261:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801264:	89 04 24             	mov    %eax,(%esp)
  801267:	e8 af f5 ff ff       	call   80081b <fd_alloc>
  80126c:	89 c3                	mov    %eax,%ebx
  80126e:	85 c0                	test   %eax,%eax
  801270:	0f 88 45 01 00 00    	js     8013bb <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801276:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80127d:	00 
  80127e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801281:	89 44 24 04          	mov    %eax,0x4(%esp)
  801285:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80128c:	e8 f4 f2 ff ff       	call   800585 <sys_page_alloc>
  801291:	89 c3                	mov    %eax,%ebx
  801293:	85 c0                	test   %eax,%eax
  801295:	0f 88 20 01 00 00    	js     8013bb <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80129b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80129e:	89 04 24             	mov    %eax,(%esp)
  8012a1:	e8 75 f5 ff ff       	call   80081b <fd_alloc>
  8012a6:	89 c3                	mov    %eax,%ebx
  8012a8:	85 c0                	test   %eax,%eax
  8012aa:	0f 88 f8 00 00 00    	js     8013a8 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012b0:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8012b7:	00 
  8012b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012c6:	e8 ba f2 ff ff       	call   800585 <sys_page_alloc>
  8012cb:	89 c3                	mov    %eax,%ebx
  8012cd:	85 c0                	test   %eax,%eax
  8012cf:	0f 88 d3 00 00 00    	js     8013a8 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8012d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012d8:	89 04 24             	mov    %eax,(%esp)
  8012db:	e8 20 f5 ff ff       	call   800800 <fd2data>
  8012e0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012e2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8012e9:	00 
  8012ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012f5:	e8 8b f2 ff ff       	call   800585 <sys_page_alloc>
  8012fa:	89 c3                	mov    %eax,%ebx
  8012fc:	85 c0                	test   %eax,%eax
  8012fe:	0f 88 91 00 00 00    	js     801395 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801304:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801307:	89 04 24             	mov    %eax,(%esp)
  80130a:	e8 f1 f4 ff ff       	call   800800 <fd2data>
  80130f:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801316:	00 
  801317:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80131b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801322:	00 
  801323:	89 74 24 04          	mov    %esi,0x4(%esp)
  801327:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80132e:	e8 a6 f2 ff ff       	call   8005d9 <sys_page_map>
  801333:	89 c3                	mov    %eax,%ebx
  801335:	85 c0                	test   %eax,%eax
  801337:	78 4c                	js     801385 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801339:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80133f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801342:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801344:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801347:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80134e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801354:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801357:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801359:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80135c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801363:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801366:	89 04 24             	mov    %eax,(%esp)
  801369:	e8 82 f4 ff ff       	call   8007f0 <fd2num>
  80136e:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801370:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801373:	89 04 24             	mov    %eax,(%esp)
  801376:	e8 75 f4 ff ff       	call   8007f0 <fd2num>
  80137b:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  80137e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801383:	eb 36                	jmp    8013bb <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801385:	89 74 24 04          	mov    %esi,0x4(%esp)
  801389:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801390:	e8 97 f2 ff ff       	call   80062c <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801395:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801398:	89 44 24 04          	mov    %eax,0x4(%esp)
  80139c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013a3:	e8 84 f2 ff ff       	call   80062c <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8013a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013b6:	e8 71 f2 ff ff       	call   80062c <sys_page_unmap>
    err:
	return r;
}
  8013bb:	89 d8                	mov    %ebx,%eax
  8013bd:	83 c4 3c             	add    $0x3c,%esp
  8013c0:	5b                   	pop    %ebx
  8013c1:	5e                   	pop    %esi
  8013c2:	5f                   	pop    %edi
  8013c3:	5d                   	pop    %ebp
  8013c4:	c3                   	ret    

008013c5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8013c5:	55                   	push   %ebp
  8013c6:	89 e5                	mov    %esp,%ebp
  8013c8:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d5:	89 04 24             	mov    %eax,(%esp)
  8013d8:	e8 91 f4 ff ff       	call   80086e <fd_lookup>
  8013dd:	85 c0                	test   %eax,%eax
  8013df:	78 15                	js     8013f6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8013e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013e4:	89 04 24             	mov    %eax,(%esp)
  8013e7:	e8 14 f4 ff ff       	call   800800 <fd2data>
	return _pipeisclosed(fd, p);
  8013ec:	89 c2                	mov    %eax,%edx
  8013ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013f1:	e8 15 fd ff ff       	call   80110b <_pipeisclosed>
}
  8013f6:	c9                   	leave  
  8013f7:	c3                   	ret    

008013f8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8013f8:	55                   	push   %ebp
  8013f9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8013fb:	b8 00 00 00 00       	mov    $0x0,%eax
  801400:	5d                   	pop    %ebp
  801401:	c3                   	ret    

00801402 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801402:	55                   	push   %ebp
  801403:	89 e5                	mov    %esp,%ebp
  801405:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801408:	c7 44 24 04 da 20 80 	movl   $0x8020da,0x4(%esp)
  80140f:	00 
  801410:	8b 45 0c             	mov    0xc(%ebp),%eax
  801413:	89 04 24             	mov    %eax,(%esp)
  801416:	e8 78 ed ff ff       	call   800193 <strcpy>
	return 0;
}
  80141b:	b8 00 00 00 00       	mov    $0x0,%eax
  801420:	c9                   	leave  
  801421:	c3                   	ret    

00801422 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801422:	55                   	push   %ebp
  801423:	89 e5                	mov    %esp,%ebp
  801425:	57                   	push   %edi
  801426:	56                   	push   %esi
  801427:	53                   	push   %ebx
  801428:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80142e:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801433:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801439:	eb 30                	jmp    80146b <devcons_write+0x49>
		m = n - tot;
  80143b:	8b 75 10             	mov    0x10(%ebp),%esi
  80143e:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801440:	83 fe 7f             	cmp    $0x7f,%esi
  801443:	76 05                	jbe    80144a <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801445:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80144a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80144e:	03 45 0c             	add    0xc(%ebp),%eax
  801451:	89 44 24 04          	mov    %eax,0x4(%esp)
  801455:	89 3c 24             	mov    %edi,(%esp)
  801458:	e8 af ee ff ff       	call   80030c <memmove>
		sys_cputs(buf, m);
  80145d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801461:	89 3c 24             	mov    %edi,(%esp)
  801464:	e8 4f f0 ff ff       	call   8004b8 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801469:	01 f3                	add    %esi,%ebx
  80146b:	89 d8                	mov    %ebx,%eax
  80146d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801470:	72 c9                	jb     80143b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801472:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801478:	5b                   	pop    %ebx
  801479:	5e                   	pop    %esi
  80147a:	5f                   	pop    %edi
  80147b:	5d                   	pop    %ebp
  80147c:	c3                   	ret    

0080147d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80147d:	55                   	push   %ebp
  80147e:	89 e5                	mov    %esp,%ebp
  801480:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801483:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801487:	75 07                	jne    801490 <devcons_read+0x13>
  801489:	eb 25                	jmp    8014b0 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80148b:	e8 d6 f0 ff ff       	call   800566 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801490:	e8 41 f0 ff ff       	call   8004d6 <sys_cgetc>
  801495:	85 c0                	test   %eax,%eax
  801497:	74 f2                	je     80148b <devcons_read+0xe>
  801499:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80149b:	85 c0                	test   %eax,%eax
  80149d:	78 1d                	js     8014bc <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80149f:	83 f8 04             	cmp    $0x4,%eax
  8014a2:	74 13                	je     8014b7 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8014a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014a7:	88 10                	mov    %dl,(%eax)
	return 1;
  8014a9:	b8 01 00 00 00       	mov    $0x1,%eax
  8014ae:	eb 0c                	jmp    8014bc <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8014b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8014b5:	eb 05                	jmp    8014bc <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8014b7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8014bc:	c9                   	leave  
  8014bd:	c3                   	ret    

008014be <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8014be:	55                   	push   %ebp
  8014bf:	89 e5                	mov    %esp,%ebp
  8014c1:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8014c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8014ca:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8014d1:	00 
  8014d2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8014d5:	89 04 24             	mov    %eax,(%esp)
  8014d8:	e8 db ef ff ff       	call   8004b8 <sys_cputs>
}
  8014dd:	c9                   	leave  
  8014de:	c3                   	ret    

008014df <getchar>:

int
getchar(void)
{
  8014df:	55                   	push   %ebp
  8014e0:	89 e5                	mov    %esp,%ebp
  8014e2:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8014e5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8014ec:	00 
  8014ed:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8014f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014f4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014fb:	e8 0a f6 ff ff       	call   800b0a <read>
	if (r < 0)
  801500:	85 c0                	test   %eax,%eax
  801502:	78 0f                	js     801513 <getchar+0x34>
		return r;
	if (r < 1)
  801504:	85 c0                	test   %eax,%eax
  801506:	7e 06                	jle    80150e <getchar+0x2f>
		return -E_EOF;
	return c;
  801508:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80150c:	eb 05                	jmp    801513 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80150e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801513:	c9                   	leave  
  801514:	c3                   	ret    

00801515 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801515:	55                   	push   %ebp
  801516:	89 e5                	mov    %esp,%ebp
  801518:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80151b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80151e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801522:	8b 45 08             	mov    0x8(%ebp),%eax
  801525:	89 04 24             	mov    %eax,(%esp)
  801528:	e8 41 f3 ff ff       	call   80086e <fd_lookup>
  80152d:	85 c0                	test   %eax,%eax
  80152f:	78 11                	js     801542 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801531:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801534:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80153a:	39 10                	cmp    %edx,(%eax)
  80153c:	0f 94 c0             	sete   %al
  80153f:	0f b6 c0             	movzbl %al,%eax
}
  801542:	c9                   	leave  
  801543:	c3                   	ret    

00801544 <opencons>:

int
opencons(void)
{
  801544:	55                   	push   %ebp
  801545:	89 e5                	mov    %esp,%ebp
  801547:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80154a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80154d:	89 04 24             	mov    %eax,(%esp)
  801550:	e8 c6 f2 ff ff       	call   80081b <fd_alloc>
  801555:	85 c0                	test   %eax,%eax
  801557:	78 3c                	js     801595 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801559:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801560:	00 
  801561:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801564:	89 44 24 04          	mov    %eax,0x4(%esp)
  801568:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80156f:	e8 11 f0 ff ff       	call   800585 <sys_page_alloc>
  801574:	85 c0                	test   %eax,%eax
  801576:	78 1d                	js     801595 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801578:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80157e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801581:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801583:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801586:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80158d:	89 04 24             	mov    %eax,(%esp)
  801590:	e8 5b f2 ff ff       	call   8007f0 <fd2num>
}
  801595:	c9                   	leave  
  801596:	c3                   	ret    
	...

00801598 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801598:	55                   	push   %ebp
  801599:	89 e5                	mov    %esp,%ebp
  80159b:	56                   	push   %esi
  80159c:	53                   	push   %ebx
  80159d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8015a0:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8015a3:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8015a9:	e8 99 ef ff ff       	call   800547 <sys_getenvid>
  8015ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015b1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8015b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8015b8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8015bc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8015c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015c4:	c7 04 24 e8 20 80 00 	movl   $0x8020e8,(%esp)
  8015cb:	e8 c0 00 00 00       	call   801690 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8015d0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8015d7:	89 04 24             	mov    %eax,(%esp)
  8015da:	e8 50 00 00 00       	call   80162f <vcprintf>
	cprintf("\n");
  8015df:	c7 04 24 d3 20 80 00 	movl   $0x8020d3,(%esp)
  8015e6:	e8 a5 00 00 00       	call   801690 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8015eb:	cc                   	int3   
  8015ec:	eb fd                	jmp    8015eb <_panic+0x53>
	...

008015f0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8015f0:	55                   	push   %ebp
  8015f1:	89 e5                	mov    %esp,%ebp
  8015f3:	53                   	push   %ebx
  8015f4:	83 ec 14             	sub    $0x14,%esp
  8015f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8015fa:	8b 03                	mov    (%ebx),%eax
  8015fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8015ff:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  801603:	40                   	inc    %eax
  801604:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  801606:	3d ff 00 00 00       	cmp    $0xff,%eax
  80160b:	75 19                	jne    801626 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80160d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  801614:	00 
  801615:	8d 43 08             	lea    0x8(%ebx),%eax
  801618:	89 04 24             	mov    %eax,(%esp)
  80161b:	e8 98 ee ff ff       	call   8004b8 <sys_cputs>
		b->idx = 0;
  801620:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  801626:	ff 43 04             	incl   0x4(%ebx)
}
  801629:	83 c4 14             	add    $0x14,%esp
  80162c:	5b                   	pop    %ebx
  80162d:	5d                   	pop    %ebp
  80162e:	c3                   	ret    

0080162f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80162f:	55                   	push   %ebp
  801630:	89 e5                	mov    %esp,%ebp
  801632:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  801638:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80163f:	00 00 00 
	b.cnt = 0;
  801642:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801649:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80164c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80164f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801653:	8b 45 08             	mov    0x8(%ebp),%eax
  801656:	89 44 24 08          	mov    %eax,0x8(%esp)
  80165a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801660:	89 44 24 04          	mov    %eax,0x4(%esp)
  801664:	c7 04 24 f0 15 80 00 	movl   $0x8015f0,(%esp)
  80166b:	e8 82 01 00 00       	call   8017f2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801670:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801676:	89 44 24 04          	mov    %eax,0x4(%esp)
  80167a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801680:	89 04 24             	mov    %eax,(%esp)
  801683:	e8 30 ee ff ff       	call   8004b8 <sys_cputs>

	return b.cnt;
}
  801688:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80168e:	c9                   	leave  
  80168f:	c3                   	ret    

00801690 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801690:	55                   	push   %ebp
  801691:	89 e5                	mov    %esp,%ebp
  801693:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801696:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801699:	89 44 24 04          	mov    %eax,0x4(%esp)
  80169d:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a0:	89 04 24             	mov    %eax,(%esp)
  8016a3:	e8 87 ff ff ff       	call   80162f <vcprintf>
	va_end(ap);

	return cnt;
}
  8016a8:	c9                   	leave  
  8016a9:	c3                   	ret    
	...

008016ac <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8016ac:	55                   	push   %ebp
  8016ad:	89 e5                	mov    %esp,%ebp
  8016af:	57                   	push   %edi
  8016b0:	56                   	push   %esi
  8016b1:	53                   	push   %ebx
  8016b2:	83 ec 3c             	sub    $0x3c,%esp
  8016b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016b8:	89 d7                	mov    %edx,%edi
  8016ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8016bd:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8016c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016c6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8016c9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8016cc:	85 c0                	test   %eax,%eax
  8016ce:	75 08                	jne    8016d8 <printnum+0x2c>
  8016d0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8016d3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8016d6:	77 57                	ja     80172f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8016d8:	89 74 24 10          	mov    %esi,0x10(%esp)
  8016dc:	4b                   	dec    %ebx
  8016dd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8016e1:	8b 45 10             	mov    0x10(%ebp),%eax
  8016e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016e8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8016ec:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8016f0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8016f7:	00 
  8016f8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8016fb:	89 04 24             	mov    %eax,(%esp)
  8016fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801701:	89 44 24 04          	mov    %eax,0x4(%esp)
  801705:	e8 5e 06 00 00       	call   801d68 <__udivdi3>
  80170a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80170e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801712:	89 04 24             	mov    %eax,(%esp)
  801715:	89 54 24 04          	mov    %edx,0x4(%esp)
  801719:	89 fa                	mov    %edi,%edx
  80171b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80171e:	e8 89 ff ff ff       	call   8016ac <printnum>
  801723:	eb 0f                	jmp    801734 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801725:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801729:	89 34 24             	mov    %esi,(%esp)
  80172c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80172f:	4b                   	dec    %ebx
  801730:	85 db                	test   %ebx,%ebx
  801732:	7f f1                	jg     801725 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801734:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801738:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80173c:	8b 45 10             	mov    0x10(%ebp),%eax
  80173f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801743:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80174a:	00 
  80174b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80174e:	89 04 24             	mov    %eax,(%esp)
  801751:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801754:	89 44 24 04          	mov    %eax,0x4(%esp)
  801758:	e8 2b 07 00 00       	call   801e88 <__umoddi3>
  80175d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801761:	0f be 80 0b 21 80 00 	movsbl 0x80210b(%eax),%eax
  801768:	89 04 24             	mov    %eax,(%esp)
  80176b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80176e:	83 c4 3c             	add    $0x3c,%esp
  801771:	5b                   	pop    %ebx
  801772:	5e                   	pop    %esi
  801773:	5f                   	pop    %edi
  801774:	5d                   	pop    %ebp
  801775:	c3                   	ret    

00801776 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801776:	55                   	push   %ebp
  801777:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801779:	83 fa 01             	cmp    $0x1,%edx
  80177c:	7e 0e                	jle    80178c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80177e:	8b 10                	mov    (%eax),%edx
  801780:	8d 4a 08             	lea    0x8(%edx),%ecx
  801783:	89 08                	mov    %ecx,(%eax)
  801785:	8b 02                	mov    (%edx),%eax
  801787:	8b 52 04             	mov    0x4(%edx),%edx
  80178a:	eb 22                	jmp    8017ae <getuint+0x38>
	else if (lflag)
  80178c:	85 d2                	test   %edx,%edx
  80178e:	74 10                	je     8017a0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801790:	8b 10                	mov    (%eax),%edx
  801792:	8d 4a 04             	lea    0x4(%edx),%ecx
  801795:	89 08                	mov    %ecx,(%eax)
  801797:	8b 02                	mov    (%edx),%eax
  801799:	ba 00 00 00 00       	mov    $0x0,%edx
  80179e:	eb 0e                	jmp    8017ae <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8017a0:	8b 10                	mov    (%eax),%edx
  8017a2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8017a5:	89 08                	mov    %ecx,(%eax)
  8017a7:	8b 02                	mov    (%edx),%eax
  8017a9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8017ae:	5d                   	pop    %ebp
  8017af:	c3                   	ret    

008017b0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8017b0:	55                   	push   %ebp
  8017b1:	89 e5                	mov    %esp,%ebp
  8017b3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8017b6:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8017b9:	8b 10                	mov    (%eax),%edx
  8017bb:	3b 50 04             	cmp    0x4(%eax),%edx
  8017be:	73 08                	jae    8017c8 <sprintputch+0x18>
		*b->buf++ = ch;
  8017c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017c3:	88 0a                	mov    %cl,(%edx)
  8017c5:	42                   	inc    %edx
  8017c6:	89 10                	mov    %edx,(%eax)
}
  8017c8:	5d                   	pop    %ebp
  8017c9:	c3                   	ret    

008017ca <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8017ca:	55                   	push   %ebp
  8017cb:	89 e5                	mov    %esp,%ebp
  8017cd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8017d0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8017d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017d7:	8b 45 10             	mov    0x10(%ebp),%eax
  8017da:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e8:	89 04 24             	mov    %eax,(%esp)
  8017eb:	e8 02 00 00 00       	call   8017f2 <vprintfmt>
	va_end(ap);
}
  8017f0:	c9                   	leave  
  8017f1:	c3                   	ret    

008017f2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8017f2:	55                   	push   %ebp
  8017f3:	89 e5                	mov    %esp,%ebp
  8017f5:	57                   	push   %edi
  8017f6:	56                   	push   %esi
  8017f7:	53                   	push   %ebx
  8017f8:	83 ec 4c             	sub    $0x4c,%esp
  8017fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8017fe:	8b 75 10             	mov    0x10(%ebp),%esi
  801801:	eb 12                	jmp    801815 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801803:	85 c0                	test   %eax,%eax
  801805:	0f 84 6b 03 00 00    	je     801b76 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80180b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80180f:	89 04 24             	mov    %eax,(%esp)
  801812:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801815:	0f b6 06             	movzbl (%esi),%eax
  801818:	46                   	inc    %esi
  801819:	83 f8 25             	cmp    $0x25,%eax
  80181c:	75 e5                	jne    801803 <vprintfmt+0x11>
  80181e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  801822:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  801829:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80182e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  801835:	b9 00 00 00 00       	mov    $0x0,%ecx
  80183a:	eb 26                	jmp    801862 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80183c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80183f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  801843:	eb 1d                	jmp    801862 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801845:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801848:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80184c:	eb 14                	jmp    801862 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80184e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  801851:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801858:	eb 08                	jmp    801862 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80185a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80185d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801862:	0f b6 06             	movzbl (%esi),%eax
  801865:	8d 56 01             	lea    0x1(%esi),%edx
  801868:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80186b:	8a 16                	mov    (%esi),%dl
  80186d:	83 ea 23             	sub    $0x23,%edx
  801870:	80 fa 55             	cmp    $0x55,%dl
  801873:	0f 87 e1 02 00 00    	ja     801b5a <vprintfmt+0x368>
  801879:	0f b6 d2             	movzbl %dl,%edx
  80187c:	ff 24 95 40 22 80 00 	jmp    *0x802240(,%edx,4)
  801883:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801886:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80188b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80188e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  801892:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  801895:	8d 50 d0             	lea    -0x30(%eax),%edx
  801898:	83 fa 09             	cmp    $0x9,%edx
  80189b:	77 2a                	ja     8018c7 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80189d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80189e:	eb eb                	jmp    80188b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8018a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8018a3:	8d 50 04             	lea    0x4(%eax),%edx
  8018a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8018a9:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018ab:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8018ae:	eb 17                	jmp    8018c7 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8018b0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8018b4:	78 98                	js     80184e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018b6:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8018b9:	eb a7                	jmp    801862 <vprintfmt+0x70>
  8018bb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8018be:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8018c5:	eb 9b                	jmp    801862 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8018c7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8018cb:	79 95                	jns    801862 <vprintfmt+0x70>
  8018cd:	eb 8b                	jmp    80185a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8018cf:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018d0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8018d3:	eb 8d                	jmp    801862 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8018d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8018d8:	8d 50 04             	lea    0x4(%eax),%edx
  8018db:	89 55 14             	mov    %edx,0x14(%ebp)
  8018de:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018e2:	8b 00                	mov    (%eax),%eax
  8018e4:	89 04 24             	mov    %eax,(%esp)
  8018e7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018ea:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8018ed:	e9 23 ff ff ff       	jmp    801815 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8018f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8018f5:	8d 50 04             	lea    0x4(%eax),%edx
  8018f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8018fb:	8b 00                	mov    (%eax),%eax
  8018fd:	85 c0                	test   %eax,%eax
  8018ff:	79 02                	jns    801903 <vprintfmt+0x111>
  801901:	f7 d8                	neg    %eax
  801903:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801905:	83 f8 0f             	cmp    $0xf,%eax
  801908:	7f 0b                	jg     801915 <vprintfmt+0x123>
  80190a:	8b 04 85 a0 23 80 00 	mov    0x8023a0(,%eax,4),%eax
  801911:	85 c0                	test   %eax,%eax
  801913:	75 23                	jne    801938 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  801915:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801919:	c7 44 24 08 23 21 80 	movl   $0x802123,0x8(%esp)
  801920:	00 
  801921:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801925:	8b 45 08             	mov    0x8(%ebp),%eax
  801928:	89 04 24             	mov    %eax,(%esp)
  80192b:	e8 9a fe ff ff       	call   8017ca <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801930:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801933:	e9 dd fe ff ff       	jmp    801815 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  801938:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80193c:	c7 44 24 08 a1 20 80 	movl   $0x8020a1,0x8(%esp)
  801943:	00 
  801944:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801948:	8b 55 08             	mov    0x8(%ebp),%edx
  80194b:	89 14 24             	mov    %edx,(%esp)
  80194e:	e8 77 fe ff ff       	call   8017ca <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801953:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801956:	e9 ba fe ff ff       	jmp    801815 <vprintfmt+0x23>
  80195b:	89 f9                	mov    %edi,%ecx
  80195d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801960:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801963:	8b 45 14             	mov    0x14(%ebp),%eax
  801966:	8d 50 04             	lea    0x4(%eax),%edx
  801969:	89 55 14             	mov    %edx,0x14(%ebp)
  80196c:	8b 30                	mov    (%eax),%esi
  80196e:	85 f6                	test   %esi,%esi
  801970:	75 05                	jne    801977 <vprintfmt+0x185>
				p = "(null)";
  801972:	be 1c 21 80 00       	mov    $0x80211c,%esi
			if (width > 0 && padc != '-')
  801977:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80197b:	0f 8e 84 00 00 00    	jle    801a05 <vprintfmt+0x213>
  801981:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  801985:	74 7e                	je     801a05 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  801987:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80198b:	89 34 24             	mov    %esi,(%esp)
  80198e:	e8 e3 e7 ff ff       	call   800176 <strnlen>
  801993:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801996:	29 c2                	sub    %eax,%edx
  801998:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80199b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80199f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8019a2:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8019a5:	89 de                	mov    %ebx,%esi
  8019a7:	89 d3                	mov    %edx,%ebx
  8019a9:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8019ab:	eb 0b                	jmp    8019b8 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8019ad:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019b1:	89 3c 24             	mov    %edi,(%esp)
  8019b4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8019b7:	4b                   	dec    %ebx
  8019b8:	85 db                	test   %ebx,%ebx
  8019ba:	7f f1                	jg     8019ad <vprintfmt+0x1bb>
  8019bc:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8019bf:	89 f3                	mov    %esi,%ebx
  8019c1:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8019c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019c7:	85 c0                	test   %eax,%eax
  8019c9:	79 05                	jns    8019d0 <vprintfmt+0x1de>
  8019cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8019d0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8019d3:	29 c2                	sub    %eax,%edx
  8019d5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8019d8:	eb 2b                	jmp    801a05 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8019da:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8019de:	74 18                	je     8019f8 <vprintfmt+0x206>
  8019e0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8019e3:	83 fa 5e             	cmp    $0x5e,%edx
  8019e6:	76 10                	jbe    8019f8 <vprintfmt+0x206>
					putch('?', putdat);
  8019e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019ec:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8019f3:	ff 55 08             	call   *0x8(%ebp)
  8019f6:	eb 0a                	jmp    801a02 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8019f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019fc:	89 04 24             	mov    %eax,(%esp)
  8019ff:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801a02:	ff 4d e4             	decl   -0x1c(%ebp)
  801a05:	0f be 06             	movsbl (%esi),%eax
  801a08:	46                   	inc    %esi
  801a09:	85 c0                	test   %eax,%eax
  801a0b:	74 21                	je     801a2e <vprintfmt+0x23c>
  801a0d:	85 ff                	test   %edi,%edi
  801a0f:	78 c9                	js     8019da <vprintfmt+0x1e8>
  801a11:	4f                   	dec    %edi
  801a12:	79 c6                	jns    8019da <vprintfmt+0x1e8>
  801a14:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a17:	89 de                	mov    %ebx,%esi
  801a19:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  801a1c:	eb 18                	jmp    801a36 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801a1e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a22:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801a29:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801a2b:	4b                   	dec    %ebx
  801a2c:	eb 08                	jmp    801a36 <vprintfmt+0x244>
  801a2e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a31:	89 de                	mov    %ebx,%esi
  801a33:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  801a36:	85 db                	test   %ebx,%ebx
  801a38:	7f e4                	jg     801a1e <vprintfmt+0x22c>
  801a3a:	89 7d 08             	mov    %edi,0x8(%ebp)
  801a3d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a3f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801a42:	e9 ce fd ff ff       	jmp    801815 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801a47:	83 f9 01             	cmp    $0x1,%ecx
  801a4a:	7e 10                	jle    801a5c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  801a4c:	8b 45 14             	mov    0x14(%ebp),%eax
  801a4f:	8d 50 08             	lea    0x8(%eax),%edx
  801a52:	89 55 14             	mov    %edx,0x14(%ebp)
  801a55:	8b 30                	mov    (%eax),%esi
  801a57:	8b 78 04             	mov    0x4(%eax),%edi
  801a5a:	eb 26                	jmp    801a82 <vprintfmt+0x290>
	else if (lflag)
  801a5c:	85 c9                	test   %ecx,%ecx
  801a5e:	74 12                	je     801a72 <vprintfmt+0x280>
		return va_arg(*ap, long);
  801a60:	8b 45 14             	mov    0x14(%ebp),%eax
  801a63:	8d 50 04             	lea    0x4(%eax),%edx
  801a66:	89 55 14             	mov    %edx,0x14(%ebp)
  801a69:	8b 30                	mov    (%eax),%esi
  801a6b:	89 f7                	mov    %esi,%edi
  801a6d:	c1 ff 1f             	sar    $0x1f,%edi
  801a70:	eb 10                	jmp    801a82 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  801a72:	8b 45 14             	mov    0x14(%ebp),%eax
  801a75:	8d 50 04             	lea    0x4(%eax),%edx
  801a78:	89 55 14             	mov    %edx,0x14(%ebp)
  801a7b:	8b 30                	mov    (%eax),%esi
  801a7d:	89 f7                	mov    %esi,%edi
  801a7f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801a82:	85 ff                	test   %edi,%edi
  801a84:	78 0a                	js     801a90 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801a86:	b8 0a 00 00 00       	mov    $0xa,%eax
  801a8b:	e9 8c 00 00 00       	jmp    801b1c <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  801a90:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a94:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  801a9b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  801a9e:	f7 de                	neg    %esi
  801aa0:	83 d7 00             	adc    $0x0,%edi
  801aa3:	f7 df                	neg    %edi
			}
			base = 10;
  801aa5:	b8 0a 00 00 00       	mov    $0xa,%eax
  801aaa:	eb 70                	jmp    801b1c <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801aac:	89 ca                	mov    %ecx,%edx
  801aae:	8d 45 14             	lea    0x14(%ebp),%eax
  801ab1:	e8 c0 fc ff ff       	call   801776 <getuint>
  801ab6:	89 c6                	mov    %eax,%esi
  801ab8:	89 d7                	mov    %edx,%edi
			base = 10;
  801aba:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  801abf:	eb 5b                	jmp    801b1c <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  801ac1:	89 ca                	mov    %ecx,%edx
  801ac3:	8d 45 14             	lea    0x14(%ebp),%eax
  801ac6:	e8 ab fc ff ff       	call   801776 <getuint>
  801acb:	89 c6                	mov    %eax,%esi
  801acd:	89 d7                	mov    %edx,%edi
			base = 8;
  801acf:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  801ad4:	eb 46                	jmp    801b1c <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  801ad6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ada:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801ae1:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  801ae4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ae8:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  801aef:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801af2:	8b 45 14             	mov    0x14(%ebp),%eax
  801af5:	8d 50 04             	lea    0x4(%eax),%edx
  801af8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801afb:	8b 30                	mov    (%eax),%esi
  801afd:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801b02:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801b07:	eb 13                	jmp    801b1c <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801b09:	89 ca                	mov    %ecx,%edx
  801b0b:	8d 45 14             	lea    0x14(%ebp),%eax
  801b0e:	e8 63 fc ff ff       	call   801776 <getuint>
  801b13:	89 c6                	mov    %eax,%esi
  801b15:	89 d7                	mov    %edx,%edi
			base = 16;
  801b17:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801b1c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  801b20:	89 54 24 10          	mov    %edx,0x10(%esp)
  801b24:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801b27:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801b2b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b2f:	89 34 24             	mov    %esi,(%esp)
  801b32:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801b36:	89 da                	mov    %ebx,%edx
  801b38:	8b 45 08             	mov    0x8(%ebp),%eax
  801b3b:	e8 6c fb ff ff       	call   8016ac <printnum>
			break;
  801b40:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801b43:	e9 cd fc ff ff       	jmp    801815 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801b48:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b4c:	89 04 24             	mov    %eax,(%esp)
  801b4f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b52:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801b55:	e9 bb fc ff ff       	jmp    801815 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801b5a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b5e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  801b65:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  801b68:	eb 01                	jmp    801b6b <vprintfmt+0x379>
  801b6a:	4e                   	dec    %esi
  801b6b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  801b6f:	75 f9                	jne    801b6a <vprintfmt+0x378>
  801b71:	e9 9f fc ff ff       	jmp    801815 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  801b76:	83 c4 4c             	add    $0x4c,%esp
  801b79:	5b                   	pop    %ebx
  801b7a:	5e                   	pop    %esi
  801b7b:	5f                   	pop    %edi
  801b7c:	5d                   	pop    %ebp
  801b7d:	c3                   	ret    

00801b7e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801b7e:	55                   	push   %ebp
  801b7f:	89 e5                	mov    %esp,%ebp
  801b81:	83 ec 28             	sub    $0x28,%esp
  801b84:	8b 45 08             	mov    0x8(%ebp),%eax
  801b87:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801b8a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b8d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801b91:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b94:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801b9b:	85 c0                	test   %eax,%eax
  801b9d:	74 30                	je     801bcf <vsnprintf+0x51>
  801b9f:	85 d2                	test   %edx,%edx
  801ba1:	7e 33                	jle    801bd6 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801ba3:	8b 45 14             	mov    0x14(%ebp),%eax
  801ba6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801baa:	8b 45 10             	mov    0x10(%ebp),%eax
  801bad:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bb1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801bb4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bb8:	c7 04 24 b0 17 80 00 	movl   $0x8017b0,(%esp)
  801bbf:	e8 2e fc ff ff       	call   8017f2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801bc4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801bc7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801bca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bcd:	eb 0c                	jmp    801bdb <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801bcf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801bd4:	eb 05                	jmp    801bdb <vsnprintf+0x5d>
  801bd6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801bdb:	c9                   	leave  
  801bdc:	c3                   	ret    

00801bdd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801bdd:	55                   	push   %ebp
  801bde:	89 e5                	mov    %esp,%ebp
  801be0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801be3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801be6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bea:	8b 45 10             	mov    0x10(%ebp),%eax
  801bed:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bf1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bf4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bf8:	8b 45 08             	mov    0x8(%ebp),%eax
  801bfb:	89 04 24             	mov    %eax,(%esp)
  801bfe:	e8 7b ff ff ff       	call   801b7e <vsnprintf>
	va_end(ap);

	return rc;
}
  801c03:	c9                   	leave  
  801c04:	c3                   	ret    
  801c05:	00 00                	add    %al,(%eax)
	...

00801c08 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801c08:	55                   	push   %ebp
  801c09:	89 e5                	mov    %esp,%ebp
  801c0b:	56                   	push   %esi
  801c0c:	53                   	push   %ebx
  801c0d:	83 ec 10             	sub    $0x10,%esp
  801c10:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801c13:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c16:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int r;
		
	r = sys_ipc_recv(pg?pg:(void*)UTOP);
  801c19:	85 c0                	test   %eax,%eax
  801c1b:	75 05                	jne    801c22 <ipc_recv+0x1a>
  801c1d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801c22:	89 04 24             	mov    %eax,(%esp)
  801c25:	e8 71 eb ff ff       	call   80079b <sys_ipc_recv>
	if (from_env_store != NULL)
  801c2a:	85 db                	test   %ebx,%ebx
  801c2c:	74 0b                	je     801c39 <ipc_recv+0x31>
		*from_env_store = thisenv->env_ipc_from; 
  801c2e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801c34:	8b 52 74             	mov    0x74(%edx),%edx
  801c37:	89 13                	mov    %edx,(%ebx)
	if (perm_store != NULL)
  801c39:	85 f6                	test   %esi,%esi
  801c3b:	74 0b                	je     801c48 <ipc_recv+0x40>
		*perm_store = thisenv->env_ipc_perm;
  801c3d:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801c43:	8b 52 78             	mov    0x78(%edx),%edx
  801c46:	89 16                	mov    %edx,(%esi)
	
	if (r < 0){
  801c48:	85 c0                	test   %eax,%eax
  801c4a:	79 16                	jns    801c62 <ipc_recv+0x5a>
		if(from_env_store != NULL)
  801c4c:	85 db                	test   %ebx,%ebx
  801c4e:	74 06                	je     801c56 <ipc_recv+0x4e>
			*from_env_store = 0;
  801c50:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store != NULL)	
  801c56:	85 f6                	test   %esi,%esi
  801c58:	74 10                	je     801c6a <ipc_recv+0x62>
			*perm_store = 0;
  801c5a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801c60:	eb 08                	jmp    801c6a <ipc_recv+0x62>
		return r;
	}
	
	return thisenv->env_ipc_value;
  801c62:	a1 04 40 80 00       	mov    0x804004,%eax
  801c67:	8b 40 70             	mov    0x70(%eax),%eax
}
  801c6a:	83 c4 10             	add    $0x10,%esp
  801c6d:	5b                   	pop    %ebx
  801c6e:	5e                   	pop    %esi
  801c6f:	5d                   	pop    %ebp
  801c70:	c3                   	ret    

00801c71 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c71:	55                   	push   %ebp
  801c72:	89 e5                	mov    %esp,%ebp
  801c74:	57                   	push   %edi
  801c75:	56                   	push   %esi
  801c76:	53                   	push   %ebx
  801c77:	83 ec 1c             	sub    $0x1c,%esp
  801c7a:	8b 75 08             	mov    0x8(%ebp),%esi
  801c7d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801c80:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  801c83:	eb 2a                	jmp    801caf <ipc_send+0x3e>
		if (r != -E_IPC_NOT_RECV)
  801c85:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c88:	74 20                	je     801caa <ipc_send+0x39>
			panic("ipc_send: sys_ipc_try_send failed %e", r);
  801c8a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c8e:	c7 44 24 08 00 24 80 	movl   $0x802400,0x8(%esp)
  801c95:	00 
  801c96:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  801c9d:	00 
  801c9e:	c7 04 24 28 24 80 00 	movl   $0x802428,(%esp)
  801ca5:	e8 ee f8 ff ff       	call   801598 <_panic>
		sys_yield();
  801caa:	e8 b7 e8 ff ff       	call   800566 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  801caf:	85 db                	test   %ebx,%ebx
  801cb1:	75 07                	jne    801cba <ipc_send+0x49>
  801cb3:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801cb8:	eb 02                	jmp    801cbc <ipc_send+0x4b>
  801cba:	89 d8                	mov    %ebx,%eax
  801cbc:	8b 55 14             	mov    0x14(%ebp),%edx
  801cbf:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801cc3:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cc7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801ccb:	89 34 24             	mov    %esi,(%esp)
  801cce:	e8 a5 ea ff ff       	call   800778 <sys_ipc_try_send>
  801cd3:	85 c0                	test   %eax,%eax
  801cd5:	78 ae                	js     801c85 <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: sys_ipc_try_send failed %e", r);
		sys_yield();
	}
}
  801cd7:	83 c4 1c             	add    $0x1c,%esp
  801cda:	5b                   	pop    %ebx
  801cdb:	5e                   	pop    %esi
  801cdc:	5f                   	pop    %edi
  801cdd:	5d                   	pop    %ebp
  801cde:	c3                   	ret    

00801cdf <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801cdf:	55                   	push   %ebp
  801ce0:	89 e5                	mov    %esp,%ebp
  801ce2:	53                   	push   %ebx
  801ce3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801ce6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ceb:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801cf2:	89 c2                	mov    %eax,%edx
  801cf4:	c1 e2 07             	shl    $0x7,%edx
  801cf7:	29 ca                	sub    %ecx,%edx
  801cf9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801cff:	8b 52 50             	mov    0x50(%edx),%edx
  801d02:	39 da                	cmp    %ebx,%edx
  801d04:	75 0f                	jne    801d15 <ipc_find_env+0x36>
			return envs[i].env_id;
  801d06:	c1 e0 07             	shl    $0x7,%eax
  801d09:	29 c8                	sub    %ecx,%eax
  801d0b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801d10:	8b 40 40             	mov    0x40(%eax),%eax
  801d13:	eb 0c                	jmp    801d21 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d15:	40                   	inc    %eax
  801d16:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d1b:	75 ce                	jne    801ceb <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801d1d:	66 b8 00 00          	mov    $0x0,%ax
}
  801d21:	5b                   	pop    %ebx
  801d22:	5d                   	pop    %ebp
  801d23:	c3                   	ret    

00801d24 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d24:	55                   	push   %ebp
  801d25:	89 e5                	mov    %esp,%ebp
  801d27:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d2a:	89 c2                	mov    %eax,%edx
  801d2c:	c1 ea 16             	shr    $0x16,%edx
  801d2f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801d36:	f6 c2 01             	test   $0x1,%dl
  801d39:	74 1e                	je     801d59 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801d3b:	c1 e8 0c             	shr    $0xc,%eax
  801d3e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801d45:	a8 01                	test   $0x1,%al
  801d47:	74 17                	je     801d60 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d49:	c1 e8 0c             	shr    $0xc,%eax
  801d4c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801d53:	ef 
  801d54:	0f b7 c0             	movzwl %ax,%eax
  801d57:	eb 0c                	jmp    801d65 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801d59:	b8 00 00 00 00       	mov    $0x0,%eax
  801d5e:	eb 05                	jmp    801d65 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801d60:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801d65:	5d                   	pop    %ebp
  801d66:	c3                   	ret    
	...

00801d68 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801d68:	55                   	push   %ebp
  801d69:	57                   	push   %edi
  801d6a:	56                   	push   %esi
  801d6b:	83 ec 10             	sub    $0x10,%esp
  801d6e:	8b 74 24 20          	mov    0x20(%esp),%esi
  801d72:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801d76:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d7a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  801d7e:	89 cd                	mov    %ecx,%ebp
  801d80:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801d84:	85 c0                	test   %eax,%eax
  801d86:	75 2c                	jne    801db4 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801d88:	39 f9                	cmp    %edi,%ecx
  801d8a:	77 68                	ja     801df4 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801d8c:	85 c9                	test   %ecx,%ecx
  801d8e:	75 0b                	jne    801d9b <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801d90:	b8 01 00 00 00       	mov    $0x1,%eax
  801d95:	31 d2                	xor    %edx,%edx
  801d97:	f7 f1                	div    %ecx
  801d99:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801d9b:	31 d2                	xor    %edx,%edx
  801d9d:	89 f8                	mov    %edi,%eax
  801d9f:	f7 f1                	div    %ecx
  801da1:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801da3:	89 f0                	mov    %esi,%eax
  801da5:	f7 f1                	div    %ecx
  801da7:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801da9:	89 f0                	mov    %esi,%eax
  801dab:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801dad:	83 c4 10             	add    $0x10,%esp
  801db0:	5e                   	pop    %esi
  801db1:	5f                   	pop    %edi
  801db2:	5d                   	pop    %ebp
  801db3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801db4:	39 f8                	cmp    %edi,%eax
  801db6:	77 2c                	ja     801de4 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801db8:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  801dbb:	83 f6 1f             	xor    $0x1f,%esi
  801dbe:	75 4c                	jne    801e0c <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801dc0:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801dc2:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801dc7:	72 0a                	jb     801dd3 <__udivdi3+0x6b>
  801dc9:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801dcd:	0f 87 ad 00 00 00    	ja     801e80 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801dd3:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801dd8:	89 f0                	mov    %esi,%eax
  801dda:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801ddc:	83 c4 10             	add    $0x10,%esp
  801ddf:	5e                   	pop    %esi
  801de0:	5f                   	pop    %edi
  801de1:	5d                   	pop    %ebp
  801de2:	c3                   	ret    
  801de3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801de4:	31 ff                	xor    %edi,%edi
  801de6:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801de8:	89 f0                	mov    %esi,%eax
  801dea:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801dec:	83 c4 10             	add    $0x10,%esp
  801def:	5e                   	pop    %esi
  801df0:	5f                   	pop    %edi
  801df1:	5d                   	pop    %ebp
  801df2:	c3                   	ret    
  801df3:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801df4:	89 fa                	mov    %edi,%edx
  801df6:	89 f0                	mov    %esi,%eax
  801df8:	f7 f1                	div    %ecx
  801dfa:	89 c6                	mov    %eax,%esi
  801dfc:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801dfe:	89 f0                	mov    %esi,%eax
  801e00:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801e02:	83 c4 10             	add    $0x10,%esp
  801e05:	5e                   	pop    %esi
  801e06:	5f                   	pop    %edi
  801e07:	5d                   	pop    %ebp
  801e08:	c3                   	ret    
  801e09:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801e0c:	89 f1                	mov    %esi,%ecx
  801e0e:	d3 e0                	shl    %cl,%eax
  801e10:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801e14:	b8 20 00 00 00       	mov    $0x20,%eax
  801e19:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801e1b:	89 ea                	mov    %ebp,%edx
  801e1d:	88 c1                	mov    %al,%cl
  801e1f:	d3 ea                	shr    %cl,%edx
  801e21:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801e25:	09 ca                	or     %ecx,%edx
  801e27:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  801e2b:	89 f1                	mov    %esi,%ecx
  801e2d:	d3 e5                	shl    %cl,%ebp
  801e2f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  801e33:	89 fd                	mov    %edi,%ebp
  801e35:	88 c1                	mov    %al,%cl
  801e37:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  801e39:	89 fa                	mov    %edi,%edx
  801e3b:	89 f1                	mov    %esi,%ecx
  801e3d:	d3 e2                	shl    %cl,%edx
  801e3f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801e43:	88 c1                	mov    %al,%cl
  801e45:	d3 ef                	shr    %cl,%edi
  801e47:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801e49:	89 f8                	mov    %edi,%eax
  801e4b:	89 ea                	mov    %ebp,%edx
  801e4d:	f7 74 24 08          	divl   0x8(%esp)
  801e51:	89 d1                	mov    %edx,%ecx
  801e53:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  801e55:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e59:	39 d1                	cmp    %edx,%ecx
  801e5b:	72 17                	jb     801e74 <__udivdi3+0x10c>
  801e5d:	74 09                	je     801e68 <__udivdi3+0x100>
  801e5f:	89 fe                	mov    %edi,%esi
  801e61:	31 ff                	xor    %edi,%edi
  801e63:	e9 41 ff ff ff       	jmp    801da9 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801e68:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e6c:	89 f1                	mov    %esi,%ecx
  801e6e:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e70:	39 c2                	cmp    %eax,%edx
  801e72:	73 eb                	jae    801e5f <__udivdi3+0xf7>
		{
		  q0--;
  801e74:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801e77:	31 ff                	xor    %edi,%edi
  801e79:	e9 2b ff ff ff       	jmp    801da9 <__udivdi3+0x41>
  801e7e:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801e80:	31 f6                	xor    %esi,%esi
  801e82:	e9 22 ff ff ff       	jmp    801da9 <__udivdi3+0x41>
	...

00801e88 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801e88:	55                   	push   %ebp
  801e89:	57                   	push   %edi
  801e8a:	56                   	push   %esi
  801e8b:	83 ec 20             	sub    $0x20,%esp
  801e8e:	8b 44 24 30          	mov    0x30(%esp),%eax
  801e92:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801e96:	89 44 24 14          	mov    %eax,0x14(%esp)
  801e9a:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  801e9e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801ea2:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801ea6:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  801ea8:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801eaa:	85 ed                	test   %ebp,%ebp
  801eac:	75 16                	jne    801ec4 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  801eae:	39 f1                	cmp    %esi,%ecx
  801eb0:	0f 86 a6 00 00 00    	jbe    801f5c <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801eb6:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801eb8:	89 d0                	mov    %edx,%eax
  801eba:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801ebc:	83 c4 20             	add    $0x20,%esp
  801ebf:	5e                   	pop    %esi
  801ec0:	5f                   	pop    %edi
  801ec1:	5d                   	pop    %ebp
  801ec2:	c3                   	ret    
  801ec3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801ec4:	39 f5                	cmp    %esi,%ebp
  801ec6:	0f 87 ac 00 00 00    	ja     801f78 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801ecc:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  801ecf:	83 f0 1f             	xor    $0x1f,%eax
  801ed2:	89 44 24 10          	mov    %eax,0x10(%esp)
  801ed6:	0f 84 a8 00 00 00    	je     801f84 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801edc:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801ee0:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801ee2:	bf 20 00 00 00       	mov    $0x20,%edi
  801ee7:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801eeb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801eef:	89 f9                	mov    %edi,%ecx
  801ef1:	d3 e8                	shr    %cl,%eax
  801ef3:	09 e8                	or     %ebp,%eax
  801ef5:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  801ef9:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801efd:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f01:	d3 e0                	shl    %cl,%eax
  801f03:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801f07:	89 f2                	mov    %esi,%edx
  801f09:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801f0b:	8b 44 24 14          	mov    0x14(%esp),%eax
  801f0f:	d3 e0                	shl    %cl,%eax
  801f11:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801f15:	8b 44 24 14          	mov    0x14(%esp),%eax
  801f19:	89 f9                	mov    %edi,%ecx
  801f1b:	d3 e8                	shr    %cl,%eax
  801f1d:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801f1f:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801f21:	89 f2                	mov    %esi,%edx
  801f23:	f7 74 24 18          	divl   0x18(%esp)
  801f27:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801f29:	f7 64 24 0c          	mull   0xc(%esp)
  801f2d:	89 c5                	mov    %eax,%ebp
  801f2f:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801f31:	39 d6                	cmp    %edx,%esi
  801f33:	72 67                	jb     801f9c <__umoddi3+0x114>
  801f35:	74 75                	je     801fac <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801f37:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801f3b:	29 e8                	sub    %ebp,%eax
  801f3d:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801f3f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f43:	d3 e8                	shr    %cl,%eax
  801f45:	89 f2                	mov    %esi,%edx
  801f47:	89 f9                	mov    %edi,%ecx
  801f49:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801f4b:	09 d0                	or     %edx,%eax
  801f4d:	89 f2                	mov    %esi,%edx
  801f4f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f53:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f55:	83 c4 20             	add    $0x20,%esp
  801f58:	5e                   	pop    %esi
  801f59:	5f                   	pop    %edi
  801f5a:	5d                   	pop    %ebp
  801f5b:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801f5c:	85 c9                	test   %ecx,%ecx
  801f5e:	75 0b                	jne    801f6b <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801f60:	b8 01 00 00 00       	mov    $0x1,%eax
  801f65:	31 d2                	xor    %edx,%edx
  801f67:	f7 f1                	div    %ecx
  801f69:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801f6b:	89 f0                	mov    %esi,%eax
  801f6d:	31 d2                	xor    %edx,%edx
  801f6f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801f71:	89 f8                	mov    %edi,%eax
  801f73:	e9 3e ff ff ff       	jmp    801eb6 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801f78:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f7a:	83 c4 20             	add    $0x20,%esp
  801f7d:	5e                   	pop    %esi
  801f7e:	5f                   	pop    %edi
  801f7f:	5d                   	pop    %ebp
  801f80:	c3                   	ret    
  801f81:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801f84:	39 f5                	cmp    %esi,%ebp
  801f86:	72 04                	jb     801f8c <__umoddi3+0x104>
  801f88:	39 f9                	cmp    %edi,%ecx
  801f8a:	77 06                	ja     801f92 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801f8c:	89 f2                	mov    %esi,%edx
  801f8e:	29 cf                	sub    %ecx,%edi
  801f90:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801f92:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f94:	83 c4 20             	add    $0x20,%esp
  801f97:	5e                   	pop    %esi
  801f98:	5f                   	pop    %edi
  801f99:	5d                   	pop    %ebp
  801f9a:	c3                   	ret    
  801f9b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801f9c:	89 d1                	mov    %edx,%ecx
  801f9e:	89 c5                	mov    %eax,%ebp
  801fa0:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801fa4:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801fa8:	eb 8d                	jmp    801f37 <__umoddi3+0xaf>
  801faa:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801fac:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801fb0:	72 ea                	jb     801f9c <__umoddi3+0x114>
  801fb2:	89 f1                	mov    %esi,%ecx
  801fb4:	eb 81                	jmp    801f37 <__umoddi3+0xaf>
